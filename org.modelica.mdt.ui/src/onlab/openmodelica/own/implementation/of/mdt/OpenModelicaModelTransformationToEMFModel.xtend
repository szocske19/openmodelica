package onlab.openmodelica.own.implementation.of.mdt

import java.io.IOException
import java.io.PrintStream
import java.nio.file.Files
import java.nio.file.Paths
import java.nio.file.StandardOpenOption
import java.util.ArrayList
import java.util.Collections
import java.util.LinkedHashMap
import java.util.Map
import onlab.openmodelica.own.implementation.of.mdt.OwnModelicaGraphAnalyzer.SearchStrategy
import onlab.openmodelica.own.waitlist.Waitlist
import openmodelica.ComponentPrototype
import openmodelica.OpenmodelicaFactory
import openmodelica.OpenmodelicaPackage
import openmodelica.Package
import openmodelica.impl.BlockImpl
import openmodelica.impl.ClassImpl
import openmodelica.impl.ConnectorImpl
import openmodelica.impl.ModelImpl
import openmodelica.impl.PackageImpl
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.viatra.transformation.runtime.emf.modelmanipulation.IModelManipulations
import org.eclipse.viatra.transformation.runtime.emf.rules.batch.BatchTransformationRuleFactory
import org.eclipse.viatra.transformation.runtime.emf.transformation.batch.BatchTransformation
import org.eclipse.viatra.transformation.runtime.emf.transformation.batch.BatchTransformationStatements
import org.modelica.mdt.core.compiler.CompilerInstantiationException
import org.modelica.mdt.core.compiler.IModelicaCompiler
import org.modelica.mdt.internal.core.CompilerProxy
import openmodelica.impl.TypeImpl
import java.awt.event.ComponentEvent
import org.modelica.mdt.core.ComponentElement

class OpenModelicaModelTransformationToEMFModel {

	private extension val OpenmodelicaFactory modelicaFactory = OpenmodelicaFactory.eINSTANCE
	private extension static OpenmodelicaPackage modelicaPackage = OpenmodelicaPackage.eINSTANCE;
	private final int MAX_LEVEL = 10

	private String fileName;
	private IPath filePath;
	private IPath fileLocation;
	private static final SearchStrategy STRATEGY = SearchStrategy.BREADTH_FIRST;

	private static Waitlist waitlist;
	private static Map<String, TreeNode> metaClassMap
	private static ArrayList<ArrayList<TreeNode>> levelList;

	private static IModelicaCompiler currentCompiler;

	/* Transformation-related extensions */
	extension BatchTransformation transformation
	extension BatchTransformationStatements statements

	/* Transformation rule-related extensions */
	extension BatchTransformationRuleFactory = new BatchTransformationRuleFactory

	extension IModelManipulations manipulation

	new(String fileName, IPath filePath, IPath fileLocation) {
		this.fileName = fileName
		this.filePath = filePath
		this.fileLocation = fileLocation
//		prepare(engine)
		createTransformation

		metaClassMap = new LinkedHashMap<String, TreeNode>(10, 2, false);

		try {
			// initiate compiler
			currentCompiler = CompilerProxy.getCompiler();
		} catch (CompilerInstantiationException e) {
			e.printStackTrace();
		}

		levelList = new ArrayList<ArrayList<TreeNode>>();
		for (var i = 0; i <= MAX_LEVEL; i++) {
			levelList.add(new ArrayList<TreeNode>());
		}

	}

	private def createTransformation() {
//		// Create VIATRA model manipulations
//		this.manipulation = new SimpleModelManipulations(engine)
//		// Create VIATRA Batch transformation
//		transformation = BatchTransformation.forEngine(engine).build
//		// Initialize batch transformation statements
//		statements = transformation.transformationStatements
	}

	def dispose() {
		if (transformation != null) {
			transformation.ruleEngine.dispose
		}
		transformation = null
		return
	}

	public def execute() {
		val classPath = fileLocation.toString();

		// load modelica file
		currentCompiler.loadFile(classPath);

		// lists local classes of the file
		val classList = currentCompiler.parseFile(classPath);

		waitlist = STRATEGY.createWaitlist();

		currentCompiler.getStandardLibrary();

		for (class : classList) {
			val className = class.toString();

			val treeNode = createTreeNode(className, 0, null)

			treeNode.addOrIgnoreNode

			while (!waitlist.isEmpty()) {
				//waitlist.print
				val CurrentNode = waitlist.remove();
				if (CurrentNode.getLevel() < MAX_LEVEL) {
					expandNode(CurrentNode);
				}
			}

			val rootPackage = treeNode.createEMFModel
			rootPackage.createEMFModelFile

		}

	}

	// if the node is already in the tree, then it will be ignored.
	def addOrIgnoreNode(TreeNode treeNode) {
		if (!metaClassMap.containsKey(treeNode.getName())) {
			levelList.get(treeNode.getLevel()).add(treeNode);
			metaClassMap.put(treeNode.getName(), treeNode);
			waitlist.add(treeNode);
			loadModel(treeNode.name);
		}
	}

	def TreeNode createTreeNode(String className, int level, TreeNode parent) {
		val type = getTypeOfClass(className)
		val componentPrototype = createComponentPrototype(type)

		val treeNode = new TreeNode(className, level, parent, componentPrototype)

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

	def ComponentPrototype createComponentPrototype(int type) {
		switch (type) {
			case OpenmodelicaPackage.CLASS: createClass()
			case OpenmodelicaPackage.PACKAGE: createPackage()
			case OpenmodelicaPackage.EXTERNAL_OBJECT: createExternalObject()
			case OpenmodelicaPackage.MODEL: createModel()
			case OpenmodelicaPackage.BLOCK: createBlock()
			case OpenmodelicaPackage.CONNECTOR: createConnector()
			case OpenmodelicaPackage.FUNCTION: createFunction()
			case OpenmodelicaPackage.RECORD: createRecord()
			case OpenmodelicaPackage.TYPE: createType()
			default:
				throw new IllegalArgumentException("The type '" + type + "' is not a valid classifier")
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
		for (TreeNode treeNode : listOfChildren) {
			treeNode.setProperties

		}
		parant.setChildren(listOfChildren);
	}

	def ArrayList<TreeNode> getChildrenOfNode(TreeNode parent) {
		val level = parent.getLevel() + 1;

		val treeNodeList = new ArrayList<TreeNode>();

		val className = parent.getName();

		val componentList = currentCompiler.getComponents(className);
		for (component : componentList) {
			val name = (component as ComponentElement).className
			if(!isPrimitive(name)){
				val treeNode = createTreeNode(name, level, parent)
				treeNodeList.add(treeNode)
				addOrIgnoreNode(treeNode)			
			}
		}

		return treeNodeList;
	}

	def setProperties(TreeNode treeNode) {
			
		switch (treeNode.componentPrototype.getClass().getSimpleName()) {
			case BlockImpl.getSimpleName():
				println("TreeNode: " + treeNode.name + ", type: Block")
			case ClassImpl.getSimpleName():
				println("TreeNode: " + treeNode.name + ", type: Class")
			case ModelImpl.getSimpleName():
				println("TreeNode: " + treeNode.name + ", type: Model")
			case PackageImpl.getSimpleName():
				println("TreeNode: " + treeNode.name + ", type: Package")
			case ConnectorImpl.getSimpleName():
				println("TreeNode: " + treeNode.name + ", type: Connector")
			case TypeImpl.getSimpleName():
				println("TreeNode: " + treeNode.name + ", type: Type")
			default:
				println("TreeNode: " + treeNode.name + ", type: unknown: " +
					treeNode.componentPrototype.getClass().getSimpleName())
		}
		treeNode.componentPrototype.name = treeNode.name;

	}
	
	def loadModel(String sourceName){
		val modelPath = currentCompiler.getClassLocation(sourceName).getPath().toString();
		currentCompiler.loadFile(modelPath);
	}

	def createEMFModel(TreeNode rootTreeNode) {

		val rootPackage = createPackage() => [ package |
			package.name = "Root"
		]

		val dependency = createPackage() => [ package |
			package.name = "dependency"
		]

		rootPackage.componentprototype.add(dependency)

		val reverseOrderedKeys = new ArrayList<String>(metaClassMap.keySet())
		Collections.reverse(reverseOrderedKeys)
		for (String key : reverseOrderedKeys) {
			val treeNode = metaClassMap.get(key)
			dependency.componentprototype.add(treeNode.componentPrototype)
		}

		return rootPackage

	}

	def createEMFModelFile(Package rootPackage) {
		// platform:/resource/Test/generated/advancedThermostat/modelDescription_cs.xml
		val eclipseProject = getContainingProject(rootPackage)

		val fmuXmlUri = URI.createPlatformResourceURI(eclipseProject.name + "/generated/" + fileName + ".openmodelica",
			true);
		// val fmuXmlUri = URI.createPlatformResourceURI(filePath + "/gen"+ fileName + ".openmodelica", true)
		val resSet = new ResourceSetImpl();

		// Get the resource
		val resource = resSet.createResource(fmuXmlUri);

		// val fmuXmlResource = getOrCreateResource(fmuXmlUri, resourceSet)
		resource.contents.add(rootPackage)

		saveResource(resource)
	}

	def getContainingProject(Package rootPackage) {
		/*System.out.println(System.getProperty("user.dir"))
		val workingDirectory=Paths.get(".").toAbsolutePath();
		val relativePath = URI.createURI(filePath.toString)
		val project = relativePath.segment(1)
		return ResourcesPlugin.getWorkspace().getRoot().getProject(project)*/
		
		
		ResourcesPlugin.getPlugin()
		
		val relativePath = URI.createURI(filePath.toString)
       	val path = new Path(relativePath.toString)
		
		val workspace = ResourcesPlugin.getWorkspace()
		val root = workspace.getRoot()
		
		val umlModelIFile = root.getFile(path)
		umlModelIFile.parent
        val project = umlModelIFile.getProject();
        
        //getProjectRelativePath()
        return project		
	}

	def Resource getOrCreateResource(URI uri, ResourceSet rs) {
		val existingResource = rs.getResource(uri, false)
		if (existingResource != null) {
			existingResource.contents.clear
			return existingResource
		} else {
			return rs.createResource(uri)
		}
	}

	def saveResource(Resource resource) {
		try {
			resource.save(null)
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	def createFileWithContent(IProject eclipseProject, Path file, String content) {
		val eclipseProjectPath = eclipseProject.location.toOSString
		val fullPath = Paths.get(eclipseProjectPath, file.toString)

		Files.createDirectories(fullPath.parent);

		if (Files.notExists(fullPath)) {
			val fileOutputStream = Files.newOutputStream(fullPath, StandardOpenOption::CREATE_NEW)
			val printStream = new PrintStream(fileOutputStream);
			printStream.print(content);
			printStream.close;
		} else {
			val fileOutputStream = Files.newOutputStream(fullPath, StandardOpenOption::TRUNCATE_EXISTING)
			val printStream = new PrintStream(fileOutputStream);
			printStream.print(content);
			printStream.close;
		}
	}
}
