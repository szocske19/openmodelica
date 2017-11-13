package onlab.openmodelica.own.implementation.of.mdt

import java.util.ArrayList
import java.util.LinkedHashMap
import java.util.Map
import onlab.openmodelica.own.implementation.of.mdt.OwnModelicaGraphAnalyzer.SearchStrategy
import onlab.openmodelica.own.waitlist.Waitlist
import openmodelica.ComponentPrototype
import openmodelica.OpenmodelicaPackage
import org.eclipse.core.runtime.IPath
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.transaction.TransactionalEditingDomain
import org.modelica.mdt.core.ComponentElement
import org.modelica.mdt.core.compiler.CompilerInstantiationException
import org.modelica.mdt.core.compiler.IModelicaCompiler
import org.modelica.mdt.internal.core.CompilerProxy
import openmodelica.impl.RealImpl
import openmodelica.impl.IntegerImpl
import openmodelica.impl.BooleanImpl
import openmodelica.impl.StringImpl
import openmodelica.impl.EnumerationImpl

class OpenModelicaModelTransformationToEMFModel {	
	private extension CreateEMFFileProvider createEMFFileProvider = new CreateEMFFileProvider();
	private extension CreateEMFModelProvider createEMFModelProvider = new CreateEMFModelProvider();
	private final int MAX_LEVEL = 10

	private String fileName;
	private IPath filePath;
	private IPath fileLocation;
	private static final SearchStrategy STRATEGY = SearchStrategy.BREADTH_FIRST;

	private static Waitlist waitlist;
	private static Map<String, ComponentPrototype> metaClassMap
	private static Map<String, Integer> levelList;

	private static IModelicaCompiler currentCompiler;
	  
    private TransactionalEditingDomain editingDomain
    
    private ResourceSet resSet;

	new(String fileName, IPath filePath, IPath fileLocation) {
		this.fileName = fileName
		this.filePath = filePath
		this.fileLocation = fileLocation

		editingDomain = TransactionalEditingDomain.Factory.INSTANCE.createEditingDomain();
//    	val rset = editingDomain.getResourceSet();

		metaClassMap = new LinkedHashMap<String, ComponentPrototype>(10, 2, false);
		levelList = new LinkedHashMap<String, Integer>(10, 2, false);

		try {
			// initiate compiler
//			currentCompiler = CompilerProxy.getCompiler();
			val compilerProxy = CompilerProxy.getCompiler();
			currentCompiler = compilerProxy
//			if(compilerProxy instanceof OMCProxy){
//				currentCompiler = new OMCAdvancedProxy(compilerProxy)
//			}
		} catch (CompilerInstantiationException e) {
			e.printStackTrace();
		}
		
		resSet = new ResourceSetImpl();
		
		waitlist = STRATEGY.createWaitlist();
	}

	public def execute() {
		val classPath = fileLocation.toString();

		// load modelica file
		currentCompiler.loadFile(classPath);

		// lists local classes of the file
		val classList = currentCompiler.parseFile(classPath);

		currentCompiler.getStandardLibrary();

		for (class : classList) {
			val className = class.toString();

			val componentPrototype = createOrGetComponentPrototype(className, 0)

			while (!waitlist.isEmpty()) {
				//waitlist.print
				val currentComponent = waitlist.remove();
				if (levelList.get(currentComponent.name) < MAX_LEVEL) {
					if(!isPrimitive(currentComponent.name)){
						expandNode(currentComponent);					
					}
				}
			}
			EditingDomainHelperUtility.runWithTransaction(editingDomain,
				[createEMFModelAndFile(componentPrototype)]
			);
			
			println("#######################################################")
			println("		EMF Model: " + className + " created" )
			println("#######################################################")
		}
	}
	
	def createEMFModelAndFile(ComponentPrototype treeNode){
		val rootPackage = createEMFModel(treeNode, metaClassMap)
		createEMFFile(resSet, rootPackage, filePath, fileName)
	}
	
	def ComponentPrototype createOrGetComponentPrototype(String className, int level){
		if(metaClassMap.containsKey(className)){
			return metaClassMap.get(className)
		} else {
			val type = if (isPrimitive(className)) 
				className.getTypeofPrimitivClass else className.getTypeOfClass
			if( OpenmodelicaPackage.TYPE === type){
				if(currentCompiler.isEnumeration(className)){
					createComponentPrototypeAndToHierarchy(className, level, OpenmodelicaPackage.ENUMERATION)
				} else {	
					val listOfSuperClasses = getSuperTypeListAtDFT(className, level + 1)
					val superType = getTypeOfComponent(listOfSuperClasses.get(0).getSuperClass)
					val cp = createComponentPrototypeAndToHierarchy(className, level, superType)					
					cp.setExtension(listOfSuperClasses)
					cp
				}
			} else {				
				createComponentPrototypeAndToHierarchy(className, level, type)
			}
		}
	}
	
	def ComponentPrototype createComponentPrototypeAndToHierarchy(String className, int level, int type){
		val componentPrototype = createComponentPrototype(type)
		componentPrototype.name = className
		levelList.put(componentPrototype.getName(), level);
		metaClassMap.put(componentPrototype.getName(), componentPrototype);
		waitlist.add(componentPrototype);
		if(!isPrimitive(className)){
			loadModel(componentPrototype.name);			
		}
		return componentPrototype
	}
	
	def ArrayList<ExtensionReference> getSuperTypeListAtDFT(String className, int level){
		//className is name of an Type 
		val extensionReferenceList = new ArrayList<ExtensionReference>();		
		
		val num = currentCompiler.getInheritanceCount(className);
		for (var i = 1; i <= num; i++) {
			val res = currentCompiler.getNthInheritedClass(className, i).firstResult;
			
			val superCp = createOrGetComponentPrototype(res, level)
			val extensionReference = new ExtensionReference(superCp)
			extensionReferenceList.add(extensionReference)				
		}		
		return extensionReferenceList
	}
	
	def int getTypeOfComponent(ComponentPrototype cp){
		if( cp instanceof RealImpl){
			OpenmodelicaPackage.REAL
		} else if( cp instanceof IntegerImpl){
			OpenmodelicaPackage.INTEGER
		} else if( cp instanceof BooleanImpl){
			OpenmodelicaPackage.BOOLEAN
		} else if( cp instanceof StringImpl){
			OpenmodelicaPackage.STRING
		} else if( cp instanceof EnumerationImpl){
			OpenmodelicaPackage.ENUMERATION
		} else {
			throw new IllegalArgumentException(
					"The class '" + cp.name + "' must be primitive class.")
		}
	}


	def expandNode(ComponentPrototype cp) {
		val listOfChildren = getChildrenOfNode(cp)	
		cp.setChildren(listOfChildren)	
		
		val listOfSuperClasses = getSuperTypeList(cp)		
		cp.setExtension(listOfSuperClasses)
	}

	def ArrayList<ComponentReference> getChildrenOfNode(ComponentPrototype parent) {
		val className = parent.getName();
		val level = levelList.get(className) + 1;		
		val componentReferenceList = new ArrayList<ComponentReference>();
		

		val componentList = currentCompiler.getComponents(className);
		for (component : componentList) {
			val componentElement = component as ComponentElement
			val child = createOrGetComponentPrototype(componentElement.className, level)
			val componentReference = new ComponentReference(componentElement, child)
			componentReferenceList.add(componentReference)	

		}

		return componentReferenceList;
	}
	
	def ArrayList<ExtensionReference> getSuperTypeList(ComponentPrototype subClass){
		val className = subClass.getName();
		val level = levelList.get(className) + 1;
		val extensionReferenceList = new ArrayList<ExtensionReference>();		
		
		val num = currentCompiler.getInheritanceCount(className);
		for (var i = 1; i <= num; i++) {
			val res = currentCompiler.getNthInheritedClass(className, i).firstResult;
			
			val superTreeNode = createOrGetComponentPrototype(res, level)
			val extensionReference = new ExtensionReference(superTreeNode)
			extensionReferenceList.add(extensionReference)	
			
		}		
		return extensionReferenceList
	}
	
	def loadModel(String sourceName){
		val modelPath = currentCompiler.getClassLocation(sourceName).getPath().toString();
		currentCompiler.loadFile(modelPath);
	}	
	
	def isPrimitive(String className) {
		switch (className) {
			case "Boolean",
			case "Real",
			case "String",
			case "Integer",
			case "Enumeration":
				true
			default:
				false
		}
	}

	def int getTypeOfClass(String className) {
		val classType = currentCompiler.getClassRestriction(className).getFirstResult().replace("\"", "").trim();

		switch (classType) {
			case "block":
				OpenmodelicaPackage.BLOCK
			case "class":
				OpenmodelicaPackage.CLASS
			case "model":
				OpenmodelicaPackage.MODEL
			case "package":
				OpenmodelicaPackage.PACKAGE
			case "expandable connector",	
			case "connector":
				OpenmodelicaPackage.CONNECTOR
			case "type":
				OpenmodelicaPackage.TYPE
			case "record":	
				OpenmodelicaPackage.RECORD
				
			default:
				throw new IllegalArgumentException(
					"The class '" + className + "' is not a valid classifier with " + classType)
		}
	}
	
	def int getTypeofPrimitivClass(String className){
		switch (className) {
			case "Boolean": OpenmodelicaPackage.BOOLEAN
			case "Real": OpenmodelicaPackage.REAL
			case "String": OpenmodelicaPackage.STRING
			case "Integer": OpenmodelicaPackage.INTEGER
			case "Enumeration": OpenmodelicaPackage.ENUMERATION
			default:
				throw new IllegalArgumentException(
					"The primitive class '" + className + "' is not a valid classifier.")
		}
	}
}
