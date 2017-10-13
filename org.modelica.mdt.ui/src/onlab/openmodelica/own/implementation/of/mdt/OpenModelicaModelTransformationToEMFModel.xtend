package onlab.openmodelica.own.implementation.of.mdt

import java.util.ArrayList
import java.util.LinkedHashMap
import java.util.Map
import onlab.openmodelica.own.implementation.of.mdt.OwnModelicaGraphAnalyzer.SearchStrategy
import onlab.openmodelica.own.waitlist.Waitlist
import openmodelica.OpenmodelicaPackage
import org.eclipse.core.runtime.IPath
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.transaction.TransactionalEditingDomain
import org.modelica.mdt.core.ComponentElement
import org.modelica.mdt.core.compiler.CompilerInstantiationException
import org.modelica.mdt.core.compiler.IModelicaCompiler
import org.modelica.mdt.internal.core.CompilerProxy
import org.modelica.mdt.core.ICompilerResult
import onlab.modelica.omc.OMCAdvancedProxy
import org.modelica.mdt.omc.OMCProxy

class OpenModelicaModelTransformationToEMFModel {	
	private extension CreateEMFFileProvider createEMFFileProvider = new CreateEMFFileProvider();
	private extension CreateEMFModelProvider createEMFModelProvider = new CreateEMFModelProvider();
	private final int MAX_LEVEL = 10

	private String fileName;
	private IPath filePath;
	private IPath fileLocation;
	private static final SearchStrategy STRATEGY = SearchStrategy.BREADTH_FIRST;

	private static Waitlist waitlist;
	private static Map<String, TreeNode> metaClassMap
	private static ArrayList<ArrayList<TreeNode>> levelList;

	private static IModelicaCompiler currentCompiler;
	  
    private TransactionalEditingDomain editingDomain
    
    private ResourceSet resSet;

	new(String fileName, IPath filePath, IPath fileLocation) {
		this.fileName = fileName
		this.filePath = filePath
		this.fileLocation = fileLocation

		editingDomain = TransactionalEditingDomain.Factory.INSTANCE.createEditingDomain();
//    	val rset = editingDomain.getResourceSet();

		metaClassMap = new LinkedHashMap<String, TreeNode>(10, 2, false);

		try {
			// initiate compiler
//			currentCompiler = CompilerProxy.getCompiler();
			val compilerProxy = CompilerProxy.getCompiler();
			currentCompiler = compilerProxy
			if(compilerProxy instanceof OMCProxy){
				currentCompiler = new OMCAdvancedProxy(compilerProxy)
			}
		} catch (CompilerInstantiationException e) {
			e.printStackTrace();
		}

		levelList = new ArrayList<ArrayList<TreeNode>>();
		for (var i = 0; i <= MAX_LEVEL; i++) {
			levelList.add(new ArrayList<TreeNode>());
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

			val treeNode = createOrGetTreeNode(className, 0, null)

			while (!waitlist.isEmpty()) {
				//waitlist.print
				val currentNode = waitlist.remove();
				if (currentNode.getLevel() < MAX_LEVEL) {
					expandNode(currentNode);
				}
				setSuperType(currentNode)
			}
			EditingDomainHelperUtility.runWithTransaction(editingDomain,
				[createEMFModelAndFile(treeNode)]
			);
			
			println("#######################################################")
			println("		EMF Model: " + className + " created" )
			println("#######################################################")
		}
	}
	def setSuperType(TreeNode treeNode){
		val num =  currentCompiler.getInheritanceCount(treeNode.name);
		for (var i = 0; i < num; i++) {
			val res = currentCompiler.getNthInheritedClass(treeNode.name, i+1);
		}
	}
	
	def createEMFModelAndFile(TreeNode treeNode){
		val rootPackage = createEMFModel(treeNode, metaClassMap)
		createEMFFile(resSet, rootPackage, filePath, fileName)
	}
	
	def TreeNode createOrGetTreeNode(String className, int level, TreeNode parent){
		if(isInMetaClassMap(className)){
			return metaClassMap.get(className)
		} else {
			val treeNode = createTreeNode(className, level, parent)
			levelList.get(treeNode.getLevel()).add(treeNode);
			metaClassMap.put(treeNode.getName(), treeNode);
			waitlist.add(treeNode);
			loadModel(treeNode.name);
			return treeNode
		}
	}
	
	def boolean isInMetaClassMap(String treeNodeName) {
		metaClassMap.containsKey(treeNodeName)
	}

	def TreeNode createTreeNode(String className, int level, TreeNode parent) {
		val type = getTypeOfClass(className)

		val treeNode = new TreeNode(className, level, parent, type)
		
		return treeNode
	}

	def isPrimitive(String className) {
		switch (className) {
			case "Boolean",
			case "Real",
			case "String",
			case "Integer":
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

	def expandNode(TreeNode parant) {
		val listOfChildren = getChildrenOfNode(parant);
		for (ComponentReference componentReference : listOfChildren) {

		}
		parant.setChildren(listOfChildren);
	}

	def ArrayList<ComponentReference> getChildrenOfNode(TreeNode parent) {
		val level = parent.getLevel() + 1;

		val componentReferenceList = new ArrayList<ComponentReference>();

		val className = parent.getName();

		val componentList = currentCompiler.getComponents(className);
		for (component : componentList) {
			val componentElement = component as ComponentElement
			if(!isPrimitive(componentElement.className)){
				val treeNode = createOrGetTreeNode(componentElement.className, level, parent)
				val componentReference = new ComponentReference(componentElement, treeNode)
				componentReferenceList.add(componentReference)	
			}
		}

		return componentReferenceList;
	}
	
	def loadModel(String sourceName){
		val modelPath = currentCompiler.getClassLocation(sourceName).getPath().toString();
		currentCompiler.loadFile(modelPath);
	}	
}
