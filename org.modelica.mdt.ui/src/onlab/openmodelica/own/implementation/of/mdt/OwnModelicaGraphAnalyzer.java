
package onlab.openmodelica.own.implementation.of.mdt;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.apache.log4j.ConsoleAppender;
import org.apache.log4j.FileAppender;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;
import org.eclipse.core.runtime.IPath;
import org.eclipse.swt.SWT;
import org.modelica.mdt.core.ICompilerResult;
import org.modelica.mdt.core.List;
import org.modelica.mdt.core.compiler.CompilerInstantiationException;
import org.modelica.mdt.core.compiler.ConnectException;
import org.modelica.mdt.core.compiler.IModelicaCompiler;
import org.modelica.mdt.core.compiler.InvocationError;
import org.modelica.mdt.core.compiler.UnexpectedReplyException;
import org.modelica.mdt.internal.core.CompilerProxy;
import org.modelica.mdt.ui.graph.ModelicaConnection;
import org.modelica.mdt.ui.graph.ModelicaGraphAnalyzer;
import org.modelica.mdt.ui.graph.ModelicaGraphGenerator;
import org.modelica.mdt.ui.graph.ModelicaGraphView;
import org.modelica.mdt.ui.graph.ModelicaNode;

import onlab.openmodelica.own.waitlist.FifoWaitlist;
import onlab.openmodelica.own.waitlist.LifoWaitlist;
import onlab.openmodelica.own.waitlist.Waitlist;
import openmodelica.Class;
import openmodelica.OpenmodelicaFactory;
import openmodelica.OpenmodelicaPackage;

public class OwnModelicaGraphAnalyzer
{
	// Collect all needed classes exactly once
	private static Map<String, TreeNode> classContentMap = new HashMap<String, TreeNode>();
	private static ArrayList<ArrayList<TreeNode>> levelList = new ArrayList<ArrayList<TreeNode>>();
	private static Waitlist waitlist;
	
	private static final SearchStrategy STRATEGY = SearchStrategy.BREADTH_FIRST;
	private static OpenModelicaModelTransformationToEMFModel tranformation;
	
	
	
	
	// Keeps track of the loaded compiler
	private static IModelicaCompiler currentCompiler;

	// Keeps track of the class path
	public static String classPath;

	// Index over nodes and connections
	private static int nid = 0;
	private static int cid = 0;
	private static int counter = 0;
	public static double elapsedTimeLines = 0.0;
	public static double elapsedTimeNodes = 0.0;
	public static double elapsedTimeConnections = 0.0;
	public static double elapsedTimeFamiliar = 0.0;
	private static Logger log = Logger.getLogger(ModelicaGraphAnalyzer.class.getName());
	private static ConsoleAppender console = new ConsoleAppender(); // create appender
	private static FileAppender fa = new FileAppender();
	
	private static OpenmodelicaFactory mmf;	
	private static OpenmodelicaPackage mmp;
	
	private static TreeNode treeNodeRoot;
	
	public static void initAnalyze(String fileName, IPath filePath)
			throws ConnectException, UnexpectedReplyException, InvocationError {
		
		
		String className;
		ModelicaNode coreNode;	
		
		mmf = OpenmodelicaFactory.eINSTANCE;
		mmp = OpenmodelicaPackage.eINSTANCE;
			
		try
		{
			// initiate compiler
			currentCompiler = CompilerProxy.getCompiler();
		} catch (CompilerInstantiationException e)
		{
			e.printStackTrace();
		}

		// Load Modelica library only one time
		if (!ModelicaGraphView.loadedModelica){
				currentCompiler.getStandardLibrary();
				ModelicaGraphView.loadedModelica = true;				
		}
		classPath = filePath.toString();

		// load modelica file
		currentCompiler.loadFile(classPath);

		// lists local classes of the file
		List classList = currentCompiler.parseFile(classPath);

		nid = -1;
		
		waitlist = STRATEGY.createWaitlist();
		
		classContentMap.clear();
		levelList.clear();

		for (int j = 0; j < classList.size(); j++) {
			className = classList.elementAt(j).toString();
			/*setUpLogging(className, "traversal");
			
			int classType = getTypeOfClass(className, classPath);	
			Class mClass = getClass(classType);			
			mClass.setName(className);*/
			
			long startTime = System.currentTimeMillis();
			
			
			currentCompiler.loadFile(classPath);
			boolean isPackage = false;
			
			for (int i = 0; i < 1000; i++)
			{
				isPackage = currentCompiler.isPackage(className);
			}
			
			
			
			long elapsedTime = System.currentTimeMillis() - startTime;	
			
			long second = (elapsedTime / 1000) % 60;
			long minute = (elapsedTime / (1000 * 60)) % 60;
			long hour = (elapsedTime / (1000 * 60 * 60)) % 24;

			String time = String.format("%02d:%02d:%02d:%d", hour, minute, second, elapsedTime % 1000);
			
			System.out.println("isPackage: " + isPackage);
			System.out.println("elapsedTime: " + time);
			
			
			/*treeNodeRoot = new TreeNode(className,0, null);
			
			final int MAX_LEVEL = 10;
			levelList.clear();
			for (int i = 0; i <= MAX_LEVEL; i++)
			{
				levelList.add(new ArrayList<TreeNode>());			
			}
			
			if(!classContentMap.containsKey(treeNodeRoot.getName())){
				classContentMap.put(treeNodeRoot.getName(), treeNodeRoot);
				levelList.get(treeNodeRoot.getLevel()).add(treeNodeRoot);
				waitlist.add(treeNodeRoot);
			}
			expandNode(treeNodeRoot);
			
			while(!waitlist.isEmpty()){
				TreeNode CurrentNode = waitlist.remove();
				if(CurrentNode.getLevel() < MAX_LEVEL){
					expandNode(CurrentNode);
				}
				
			}
			
			tranformation.createOpenModelicaModel(treeNodeRoot);
			String graph = makeGraph();
			log.debug(graph);
			
			
			log.debug("className: " + className);*/

			
		}
	}
	
	private static void expandNode(TreeNode node) throws ConnectException, UnexpectedReplyException, InvocationError{
		ArrayList<TreeNode> tmp = getChildrenOfNode(node);
		for (TreeNode treeNode : tmp)
		{
			if(!classContentMap.containsKey(treeNode.getName())){
				classContentMap.put(treeNode.getName(), treeNode);
				levelList.get(node.getLevel()+1).add(treeNode);
//				waitlist.add(treeNode);
			}
			
		}
//		TODO TreeNode children changed, but this code not updated
//		node.setChildren(tmp);
		
	}
	
	public static void setUpLogging(String className, String type){
		Logger.getRootLogger().removeAllAppenders();
		
		// Create an instance of SimpleDateFormat used for formatting
		// the string representation of date (month/day/year)
		DateFormat df = new SimpleDateFormat("MM_dd_HH_mm_ss");

		// Get the date today using Calendar object.
		Date today = Calendar.getInstance().getTime();
		// Using DateFormat format method we can create a string
		// representation of a date with the defined format.
		String reportDate = df.format(today);
		fa = new FileAppender();
		fa.setName("FileLogger");
		fa.setFile("C:\\runtime-New_configuration\\log\\" + className + "_"
				+ type + "_" + reportDate + ".log");
		// fa.setLayout(new PatternLayout("%d %-5p [%c{1}] %m%n"));
		fa.setLayout(new PatternLayout("%m%n"));

		fa.setThreshold(Level.DEBUG);
		fa.setAppend(true);
		fa.activateOptions();

		//add appender to any Logger (here is root)
		Logger.getRootLogger().addAppender(fa);
		//repeat with all other desired appenders
//		PropertyConfigurator.configure("log4j.properties");
	}
	
	private static int getTypeOfClass(String className, String classPath)
			throws ConnectException, UnexpectedReplyException
	{
		String classType = currentCompiler.getClassRestriction(className)
				.getFirstResult().replace("\"", "");

		switch (classType.trim())
		{
		case "Blocks":
			return OpenmodelicaPackage.BLOCK;
		case "class":
			return OpenmodelicaPackage.CLASS;
		case "model":
			return OpenmodelicaPackage.MODEL;
		case "package":
			return OpenmodelicaPackage.PACKAGE;
		default:
			throw new IllegalArgumentException(
					"The class '" + className + "' is not a valid classifier with " + classType.trim());
		}
	}
	
	
	private static Class getClass(int type)
	{
		switch (type)
		{
		case OpenmodelicaPackage.BLOCK:
			return mmf.createBlock();
		case OpenmodelicaPackage.CLASS:
			return mmf.createClass();
		case OpenmodelicaPackage.MODEL:
			return mmf.createModel();
		default:
			throw new IllegalArgumentException(
					"The type '" + type + "' is not a valid classifier");

		}
	}
	
	private static ArrayList<TreeNode> getChildrenOfNode(TreeNode parent)
			throws ConnectException, UnexpectedReplyException, InvocationError {
		int level = parent.getLevel()+1;
		
		
		ArrayList<TreeNode> treeNodeList = new ArrayList<TreeNode>();
		
		
		
		
			currentCompiler.loadFile(classPath);
			
			String className = parent.getName();
			

			// Find the underlying classes of a package
			if(currentCompiler.isPackage(className)) {
				List classList = currentCompiler.getClassNames(className);
				log.debug("\t<Package>");
				for (int j = 0; j < classList.size(); j++) {
					String name = classList.elementAt(j).toString();
					treeNodeList.add(new TreeNode(className + "." + name, level, parent)); 
				}
				log.debug("\t</Package>");
			}
			
			

			log.debug("\t<Import>");
			// Find service-dependencies among imports
			int num =  currentCompiler.getImportCount(className);
			for (int i = 0; i < num; i++) {
				ICompilerResult res = currentCompiler.getNthImport(className, i+1);
				treeNodeList.add(new TreeNode(res.getFirstResult(), level, parent)); 
			}
			log.debug("\t</Import>");

			log.debug("\t<Inheritance>");
			// Find inheritance-dependencies
			num =  currentCompiler.getInheritanceCount(className);
			for (int i = 0; i < num; i++) {
				ICompilerResult res = currentCompiler.getNthInheritedClass(className, i+1);
				treeNodeList.add(new TreeNode(res.getFirstResult(), level, parent));
			}
			log.debug("\t</Inheritance>");

			log.debug("\t<Components>");
			// Find component-dependencies
			List componentList = currentCompiler.getComponents(className);
			for (int j = 0; j < componentList.size(); j++) {
				String name = componentList.elementAt(j).toString();
				treeNodeList.add(new TreeNode(name, level, parent));
			}
			log.debug("\t</Components>");		
		return treeNodeList;
	}
	
	public static enum SearchStrategy {
		BREADTH_FIRST {
			@Override
			Waitlist createWaitlist() {
				return FifoWaitlist.create();
			}
		},

		DEPTH_FIRST {
			@Override
			Waitlist createWaitlist() {
				return LifoWaitlist.create();
			}
		};

		abstract Waitlist createWaitlist();
	}
	
	public static String makeGraph(){

		String graph = "digraph \"modelGraph\" {";
		graph += "graph [	fontname = \"Helvetica-Oblique\", ";
		graph += "fontsize = 36,";
		graph += "label = \"Tree of "   + treeNodeRoot.getName() +  "\",";
		graph += "size = \"120,120\" ];";
		graph += "node [	shape = polygon,";
		graph += "sides = 4,";
		graph += "distortion = \"0.0\",";
		graph += "orientation = \"0.0\",";
		graph += "skew = \"0.0\",";
		graph += "color = white,";
		graph += "style = filled,";
		graph += "fontname = \"Helvetica-Outline\" ];";
		
		for(Map.Entry<String, TreeNode> entry : classContentMap.entrySet()) {
		    String key = entry.getKey();
		    
		    graph += "\"" + key + "\"[color=greenyellow];\n";
		}
		
		for(Map.Entry<String, TreeNode> entry : classContentMap.entrySet()) {
		    String key = entry.getKey();
		    TreeNode value = entry.getValue();
//			TODO TreeNode children changed, but this code not updated
//		    for (TreeNode treeNode: value.getChildren()) {
//		    	graph += "\"" + key + "\" -> \"" + treeNode.getName() + "\";\n";
//		    }
		    
		}
		graph += "}";
		System.out.println("Number of nodes: " + classContentMap.size());
		int dontHaveChild = 0;
		int theDeepestLevel = 0;
		for(Map.Entry<String, TreeNode> entry : classContentMap.entrySet()) {
		    TreeNode value = entry.getValue();
		    
		    if(value.getChildren().size() == 0){
		    	dontHaveChild++;
		    }
		    if(value.getLevel() > theDeepestLevel){
		    	theDeepestLevel = value.getLevel();
		    }
		}
		System.out.println("Number of leaf: " + dontHaveChild);
		System.out.println("The deepest level: " + theDeepestLevel);
		
		
		String levels = "";
		int levelCounter = 0;
		
		for(ArrayList<TreeNode> level : levelList ){			
			levels += levelCounter + ". level: \n";
			for(TreeNode treeNode : level){
				levels += "    " + treeNode.getName() + "\n";
			}
			levelCounter++;
		}
		System.out.println(levels);
		System.out.println(graph);
		return graph;
	}

}
