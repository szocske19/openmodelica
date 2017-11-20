package onlab.openmodelica.own.implementation.of.mdt

import java.util.ArrayList
import java.util.LinkedHashMap
import java.util.Map
import onlab.modelica.omc.ComponentElement
import onlab.modelica.omc.LoadedLibrary
import onlab.openmodelica.own.implementation.of.mdt.OwnModelicaGraphAnalyzer.SearchStrategy
import onlab.openmodelica.own.waitlist.Waitlist
import openmodelica.MoClass
import openmodelica.MoPackage
import openmodelica.OpenmodelicaPackage
import openmodelica.impl.MoTypeImpl
import org.eclipse.core.runtime.IPath
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.transaction.TransactionalEditingDomain
import org.modelica.mdt.core.compiler.CompilerInstantiationException
import org.modelica.mdt.core.compiler.IModelicaCompiler
import org.modelica.mdt.internal.core.CompilerProxy

class OpenModelicaModelTransformationToEMFModel {	
	private extension CreateEMFFileProvider createEMFFileProvider = new CreateEMFFileProvider();
	private extension CreateEMFModelProvider createEMFModelProvider
	private final int MAX_LEVEL = 100000

	private String fileName;
	private IPath filePath;
	private IPath fileLocation;
	private static final SearchStrategy STRATEGY = SearchStrategy.DEPTH_FIRST;

	private static Waitlist waitlist;
	private static Map<String, LevelNode> metaClassMap
	private static Map<String, LoadedLibrary> loadedLibraries

	private static IModelicaCompiler currentCompiler;
	  
    private TransactionalEditingDomain editingDomain
    
    private ResourceSet resSet;

	new(String fileName, IPath filePath, IPath fileLocation) {
		this.fileName = fileName
		this.filePath = filePath
		this.fileLocation = fileLocation

		editingDomain = TransactionalEditingDomain.Factory.INSTANCE.createEditingDomain();
//    	val rset = editingDomain.getResourceSet();

		metaClassMap = new LinkedHashMap<String, LevelNode>(10, 2, false);
		loadedLibraries = new LinkedHashMap<String, LoadedLibrary>(10, 2, false);

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
		createEMFModelProvider = new CreateEMFModelProvider(currentCompiler);
		
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
		
		setupLoadedLibraries()

		for (class : classList) {
			val className = class.toString();

			createMoClassAndToHierarchy("ExternalObject", null, 1, OpenmodelicaPackage.MO_CLASS)

			val componentPrototype = createOrGetMoClass(className, null, 0)
			
			while (!waitlist.isEmpty()) {
				//waitlist.print
				val currentComponent = waitlist.remove();
				if (metaClassMap.get(currentComponent.name).level < MAX_LEVEL) {
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
	
	def createEMFModelAndFile(MoClass treeNode){
		val rootPackage = createEMFModel(treeNode, metaClassMap)
		createEMFFile(resSet, rootPackage, filePath, fileName)
	}
	
	def MoClass createOrGetMoClass(String className, String parent, int level){
		if(metaClassMap.containsKey(className)){
			if(metaClassMap.get(className).level < level){
				println("raiseLevel:")
				metaClassMap.get(className).raiseLevelAndChangeParent(metaClassMap.get(parent), level)
			}
			return metaClassMap.get(className).cp
		} else {
			val type = if (isPrimitive(className)) 
				className.getTypeofPrimitivClass else className.getTypeOfClass
			if( OpenmodelicaPackage.PRIMITIVES === type){
				if(currentCompiler.isEnumeration(className)){
					createMoClassAndToHierarchy(className, parent, level, OpenmodelicaPackage.ENUMERATION)
				} else {	
					val listOfSuperClasses = getSuperTypeListAtDFT(className, level + 1)
					val superType = getTypeOfComponent(listOfSuperClasses.get(0).getSuperClass)
					val cp = createMoClassAndToHierarchy(className, parent, level, superType)					
					cp.setExtension(listOfSuperClasses)
					cp
				}
			} else {				
				createMoClassAndToHierarchy(className, parent, level, type)
			}
		}
	}
	
	def MoClass createMoClassAndToHierarchy(String className, String parent, int level, int type){
		val componentPrototype = createMoClass(type)
		componentPrototype.name = className
		val parentNode = metaClassMap.get(parent)
		val levelNode = new LevelNode(componentPrototype, parentNode,  level)
		metaClassMap.put(className, levelNode);
		if(!className.equals("ExternalObject")){
			waitlist.add(componentPrototype);
			if(!isPrimitive(className)){
				if(OpenModelicaModelTransformationToEMFModel.loadedLibraries.containsKey(className)){
					loadModel(className);
				}			
			}		
		}
		return componentPrototype
	}
	
	def ArrayList<ExtensionReference> getSuperTypeListAtDFT(String className, int level){
		//className is name of an Type 
		val extensionReferenceList = new ArrayList<ExtensionReference>();		
		
		val num = currentCompiler.getInheritanceCount(className);
		for (var i = 1; i <= num; i++) {
			val res = currentCompiler.getNthInheritedClass(className, i).firstResult;
			
			val superCp = createOrGetMoClass(res, className, level)
			val extensionReference = new ExtensionReference(superCp)
			extensionReferenceList.add(extensionReference)				
		}		
		return extensionReferenceList
	}
	
	


	def expandNode(MoClass cp) {
		if(cp instanceof MoPackage){
			val classList = getClassOfPackage(cp)
			cp.addClass(classList)
		}
		
		val listOfChildren = getChildrenOfNode(cp)	
		cp.setChildren(listOfChildren)	
		
		
		if( !(cp instanceof MoTypeImpl) || currentCompiler.isEnumeration(cp.name)){	
			val listOfSuperClasses = getSuperTypeList(cp)		
			cp.setExtension(listOfSuperClasses)
		}		
	}
	
	def ArrayList<MoClass> getClassOfPackage(MoClass packageCP) {
		val packageName = packageCP.getName()
		val level = metaClassMap.get(packageName).level + 1
		val cpList = new ArrayList<MoClass>()
		

		val classNameList = currentCompiler.getClassNames(packageName);
		for (className : classNameList) {
			val child = createOrGetMoClass(packageName + "." + className.toString, packageName, level)
			cpList.add(child)
		}

		return cpList;
	}

	def ArrayList<ComponentReference> getChildrenOfNode(MoClass parent) {
		val className = parent.getName()
		val level = metaClassMap.get(className).level + 1	
		val componentReferenceList = new ArrayList<ComponentReference>()
		

		val componentList = currentCompiler.getComponents(className);
		for (component : componentList) {
			val componentElement = component as ComponentElement
			val child = createOrGetMoClass(componentElement.className, className, level)
			val componentReference = new ComponentReference(componentElement, child)
			componentReferenceList.add(componentReference)	

		}

		return componentReferenceList;
	}
	
	def ArrayList<ExtensionReference> getSuperTypeList(MoClass subClass){
		val className = subClass.getName();
		val level = metaClassMap.get(className).level + 1
		val extensionReferenceList = new ArrayList<ExtensionReference>();		
		
		val num = currentCompiler.getInheritanceCount(className);
		for (var i = 1; i <= num; i++) {
			val res = currentCompiler.getNthInheritedClass(className, i).firstResult;
			
			val superTreeNode = createOrGetMoClass(res, className, level)
			val extensionReference = new ExtensionReference(superTreeNode)
			extensionReferenceList.add(extensionReference)	
			
		}		
		return extensionReferenceList
	}
	
	def loadModel(String sourceName){
		val modelPath = currentCompiler.getClassLocation(sourceName).getPath().toString();
		currentCompiler.loadFile(modelPath);
		val lib = new LoadedLibrary(#[sourceName,modelPath])
		loadedLibraries.put(lib.libraryName, lib)
	}
		   
	def setupLoadedLibraries(){
		val libList = currentCompiler.getLoadedLibraries();
		for (libElement : libList) {
			val lib = libElement as LoadedLibrary
			loadedLibraries.put(lib.libraryName, lib)
		}
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
				OpenmodelicaPackage.MO_BLOCK
			case "class":
				OpenmodelicaPackage.MO_CLASS
			case "connector":
				OpenmodelicaPackage.MO_CONNECTOR			
			case "expandable connector":
				OpenmodelicaPackage.MO_EXPANDABLE_CONNECTOR		
			case "function":
				OpenmodelicaPackage.MO_FUNCTION	
			case "model":
				OpenmodelicaPackage.MO_MODEL
			case "operator":
				OpenmodelicaPackage.MO_OPERATOR
			case "operator function":
				OpenmodelicaPackage.MO_OPERATOR_FUNCTION
			case "operator record":
				OpenmodelicaPackage.MO_OPERATOR_RECORD
			case "package":
				OpenmodelicaPackage.MO_PACKAGE				
			case "record":	
				OpenmodelicaPackage.MO_RECORD
			case "type":
				OpenmodelicaPackage.PRIMITIVES
				
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
