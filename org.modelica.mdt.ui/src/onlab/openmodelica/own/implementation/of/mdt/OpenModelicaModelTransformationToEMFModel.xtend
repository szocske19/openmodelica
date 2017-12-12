package onlab.openmodelica.own.implementation.of.mdt

import java.util.ArrayList
import java.util.LinkedHashMap
import java.util.Map
import onlab.modelica.omc.ComponentElement
import onlab.modelica.omc.LoadedLibrary
import onlab.openmodelica.own.implementation.of.mdt.OwnModelicaGraphAnalyzer.SearchStrategy
import onlab.openmodelica.own.waitlist.Waitlist
import openmodelica.MoClass
import openmodelica.OpenmodelicaPackage
import openmodelica.impl.MoTypeImpl
import org.eclipse.core.runtime.IPath
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.transaction.TransactionalEditingDomain
import org.modelica.mdt.core.compiler.CompilerInstantiationException
import org.modelica.mdt.core.compiler.IModelicaCompiler
import org.modelica.mdt.internal.core.CompilerProxy
import org.modelica.mdt.core.compiler.UnexpectedReplyException
import org.modelica.mdt.core.List
import onlab.openmodelica.own.util.PrintHelperUtil

class OpenModelicaModelTransformationToEMFModel {	
	private extension CreateEMFFileProvider createEMFFileProvider = new CreateEMFFileProvider();
	private extension CreateEMFModelProvider createEMFModelProvider
	
	//Parameters:
	private final boolean EXPAND_PARENT = true;
	private static final SearchStrategy STRATEGY = SearchStrategy.BREADTH_FIRST;

	private String fileName;
	private IPath filePath;
	private IPath fileLocation;

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

		PrintHelperUtil.setUpLogging(fileName)
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

			createMoClassAndAddToHierarchy("ExternalObject", null, OpenmodelicaPackage.MO_CLASS, false)

			val componentPrototype = createOrGetMoClass(className, null, true)
			
			while (!waitlist.isEmpty()) {
				//waitlist.print
				val currentComponent = waitlist.remove();
				if(!isPrimitive(currentComponent.name)){
					expandNode(currentComponent);
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
	
	def MoClass createOrGetMoClass(String className, String parent, boolean addToWaitList){		
		
		var errorMsg = ""	
	
		val moClass = if(metaClassMap.containsKey(className)){
//			if(!(OpenmodelicaPackage.MO_FUNCTION == type)){		
			try {
				metaClassMap.get(className).addParent(metaClassMap.get(parent))
			} catch (IllegalArgumentException e)	{
				errorMsg = e.message					
			}
			metaClassMap.get(className).cp
		} else {
			val type = try {
				if (isPrimitive(className)) 
					className.getTypeofPrimitivClass else className.getTypeOfClass
			} catch (IllegalArgumentException e) {
				errorMsg = e.message 	
				OpenmodelicaPackage.MO_CLASS
			}
			if( OpenmodelicaPackage.PRIMITIVES === type){
				if(currentCompiler.isEnumeration(className)){
					createMoClassAndAddToHierarchy(className, parent, OpenmodelicaPackage.ENUMERATION, addToWaitList)
				} else {	
					val listOfSuperClasses = getSuperTypeListAtDFT(className)
					val superType = getTypeOfComponent(listOfSuperClasses.get(0).getSuperClass)
					val cp = createMoClassAndAddToHierarchy(className, parent, superType, addToWaitList)					
					cp.setExtension(listOfSuperClasses)
					cp
				}
			} else {				
				createMoClassAndAddToHierarchy(className, parent, type, addToWaitList)
			}
		}
		if(!errorMsg.equals("")){
			createErrorNode(moClass, errorMsg)	
		}
		return moClass
	}
	
	def MoClass createMoClassAndAddToHierarchy(String className, String parent, int type, boolean addToWaitList){
		val dummyPackageList = newArrayList()	
		if(className.contains(".")){
			
			val packageName = className.substring(0, className.lastIndexOf("."))
			dummyPackageList.add(createOrGetMoClass(packageName, null, EXPAND_PARENT))
		}

		val componentPrototype = createMoClass(type)
		
		
		componentPrototype.name = className
		val parentNode = metaClassMap.get(parent)
		val isFunction = OpenmodelicaPackage.MO_FUNCTION == type  //TODO Do we need this?
		val levelNode = new LevelNode(componentPrototype, parentNode, isFunction)
		metaClassMap.put(className, levelNode);
		
		if(addToWaitList){
			waitlist.add(componentPrototype);
			if(!isPrimitive(className)){
				if(OpenModelicaModelTransformationToEMFModel.loadedLibraries.containsKey(className)){
					loadModel(className);
				}			
			}		
		}
		if(dummyPackageList.size == 1){	
			dummyPackageList.head.packagedClasses.add(componentPrototype)
			createOrGetMoClass(className, dummyPackageList.head.name, EXPAND_PARENT) //EXPAND_PARENT don't care
		}
		return componentPrototype
	}
	
	def getPackageNameList(String className){
		val packageNameList = newArrayList()
		for (var index = className.indexOf(".");
		     index >= 0;
		     index = className.indexOf(".", index + 1))
		{
		    packageNameList.add(className.substring(0, index))
		}
		packageNameList
	}
	
	def ArrayList<ExtensionReference> getSuperTypeListAtDFT(String className){
		//className is name of an Type 
		val extensionReferenceList = new ArrayList<ExtensionReference>();		
		
		val num = currentCompiler.getInheritanceCount(className);
		for (var i = 1; i <= num; i++) {
			val res = currentCompiler.getNthInheritedClass(className, i).firstResult;
			
			val superCp = createOrGetMoClass(res, className, true)
			val extensionReference = new ExtensionReference(superCp)
			extensionReferenceList.add(extensionReference)				
		}		
		return extensionReferenceList
	}
	
	def expandNode(MoClass cp) {
		val classList = getClassOfPackage(cp)
		cp.addClass(classList)
		
		val listOfChildren = getChildrenOfNode(cp)	
		cp.setChildren(listOfChildren)	
		
		
		if( !(cp instanceof MoTypeImpl) || currentCompiler.isEnumeration(cp.name)){	
			val listOfSuperClasses = getSuperTypeList(cp)		
			cp.setExtension(listOfSuperClasses)
		}		
	}
	
	def ArrayList<MoClass> getClassOfPackage(MoClass packageCP) {
		val packageName = packageCP.getName()
		val cpList = new ArrayList<MoClass>()
		

		val classNameList = currentCompiler.getClassNames(packageName);
		for (className : classNameList) {
			val child = createOrGetMoClass(packageName + "." + className.toString, packageName, true)
			cpList.add(child)
		}

		return cpList;
	}

	def ArrayList<ComponentReference> getChildrenOfNode(MoClass parent) {
		val className = parent.getName()
		val componentReferenceList = new ArrayList<ComponentReference>()

		val componentList = try {
			currentCompiler.getComponents(className);
		} catch (UnexpectedReplyException e) {			
			createErrorNode(parent, e.message)
			new List();
		}
		for (component : componentList) {
			val componentElement = component as ComponentElement
			val child = createOrGetMoClass(componentElement.className, className, true)
			val componentReference = new ComponentReference(componentElement, child)
			componentReferenceList.add(componentReference)	

		}

		return componentReferenceList;
	}
	
	def ArrayList<ExtensionReference> getSuperTypeList(MoClass subClass){
		val className = subClass.getName();
		val extensionReferenceList = new ArrayList<ExtensionReference>();		
		
		val num = currentCompiler.getInheritanceCount(className);
		for (var i = 1; i <= num; i++) {
			val res = currentCompiler.getNthInheritedClass(className, i).firstResult;
			
			val superTreeNode = createOrGetMoClass(res, className, true)
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
			case "Enumeration",
			case "ExternalObject":
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
			case "ExternalObject": OpenmodelicaPackage.MO_CLASS
			default:
				throw new IllegalArgumentException(
					"The primitive class '" + className + "' is not a valid classifier.")
		}
	}
}
