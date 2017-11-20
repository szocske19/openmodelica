
package org.modelica.mdt.ui.graph;

import java.io.File;
import java.io.FileNotFoundException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.log4j.ConsoleAppender;
import org.apache.log4j.FileAppender;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.swt.SWT;
import org.modelica.mdt.core.ICompilerResult;
import org.modelica.mdt.core.List;
import org.modelica.mdt.core.compiler.CompilerInstantiationException;
import org.modelica.mdt.core.compiler.ConnectException;
import org.modelica.mdt.core.compiler.IModelicaCompiler;
import org.modelica.mdt.core.compiler.InvocationError;
import org.modelica.mdt.core.compiler.UnexpectedReplyException;
import org.modelica.mdt.internal.core.CompilerProxy;

import openmodelica.Extension;
import openmodelica.OpenmodelicaFactory;
import openmodelica.OpenmodelicaPackage;


/**
 * This class analyze the code of a file and to extract class-/package-dependencies,
 * and then send it onwards to org.modelica.mdt.ui.graph.GraphGenerator.
 *
 * @author: Magnus Sjöstrand
 */
public class ModelicaGraphAnalyzer {

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
	

	/**
	 * This will start the analyze process by initiating the compiler
	 * and set up the local modelica environment in order to
	 * be able to perform calls of the API. When that is done it will
	 * start the analyze by calling analyzeClasses.
	 *
	 * @param fileName
	 *            the file name with file-extension
	 * @param filePath
	 *            the path to the file
	 * @exception ConnectException
	 *                if the Modelica compiler can't be loaded
	 * @exception UnexpectedReplyException
	 *                if the Modelica compiler returns something strange
	 * @exception InvocationException
	 *                if the Modelica compiler replies with an unexpected error in results
	 */
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

		for (int j = 0; j < classList.size(); j++) {
			className = classList.elementAt(j).toString();
			setUpLogging(className, "traversal");
			
			log.debug("className: " + className);

			// Creates root node
			if (!nodesContains(className)) {
				nid += 1;
				if(currentCompiler.isPackage(className)) {
					coreNode = new ModelicaNode(nid, className, SWT.COLOR_GRAY);
				} else {
					coreNode = new ModelicaNode(nid, className, SWT.COLOR_GREEN);
				}
				setToolTipInfo(coreNode, className, classPath);
				createClass(coreNode, className, classPath);

				coreNode.expandable = false;
				ModelicaGraphGenerator.nodes.add(coreNode);
				ModelicaGraphGenerator.nodesMap.put(coreNode.getName(),coreNode);
			}

//			analyzeClasses(nid, className, false);
//			TODO init can be recursive?
			analyzeClasses(nid, className, true);
			setUpLogging(className, "graph");
			String graph = ModelicaGraphGenerator.makeGraph();
			log.debug(graph);
		}
		

//		Block block1 = mmf.createBlock();
//		block1.setName("Block1");
//		
//		Block block2 = mmf.createBlock();
//		block2.setName("Block2");
//		
//		ComponentInstance cInstance = mmf.createComponentInstance();
//		cInstance.setIs_a(block2);
//		
//		block1.getChildren().add(cInstance);
//		
//		Block block3 = mmf.createBlock();
//		block3.setName("Block3");
		
		Extension extension = mmf.createExtension();

//		block3.setExtension(extension);
		
		
		
		
		
		
 
	    

	    /*Resource.Factory.Registry reg = Resource.Factory.Registry.INSTANCE;
	    Map<String, Object> m = reg.getExtensionToFactoryMap();
	    /*add default .ecore extension for ecore file
	    m.put(EcorePackage.eNAME, new XMIResourceFactoryImpl());*/

	    ResourceSetImpl resourceSet = new ResourceSetImpl();
	    // Obtain a new resource set
	    ResourceSet resSet = resourceSet;
	    // create a resource
	    Resource resource = null;
	    try {
	        resource = resSet.createResource(URI.createFileURI("C:/runtime-New_configuration/Test/src/mygen.openmodelica"));
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	    
//	    resource.getContents().add(block3);
	    
	    try {
		    resource.save(Collections.EMPTY_MAP);
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	}
	
	public static void setUpLogging(String className, String type){
		Logger.getRootLogger().removeAllAppenders();		
//		console = new ConsoleAppender(); // create appender
//		
//		// configure the appender
////		String PATTERN = "%d [%p|%c|%C{1}] %m%n";
//		String PATTERN = "%m%n";
//		console.setLayout(new PatternLayout(PATTERN));
//		console.setThreshold(Level.DEBUG);
//		console.activateOptions();
//		// add appender to any Logger (here is root)
//		Logger.getRootLogger().addAppender(console);
		
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

	/**
	 * Iterates over code by using the results from Modelica API, through
	 * calls to OMC.
	 *
	 * @param prevId
	 *            the ID of the previous node that started a dependency to this node
	 * @param className
	 *            the name of this class
	 * @param recursive
	 *            tells whether or not the analyze should be performed recursively
	 * @return the prevID that was used for the current analyze iteration
	 * @exception ConnectException
	 *                if the Modelica compiler can't be loaded
	 * @exception UnexpectedReplyException
	 *                if the Modelica compiler returns something strange
	 * @exception InvocationException
	 *                if the Modelica compiler replies with an unexpected error in results
	 */
	public static int analyzeClasses(int prevID, String className, boolean recursive)
			throws ConnectException, UnexpectedReplyException, InvocationError {
//		log.debug("\n\nTESTING: " + className);
		currentCompiler.loadFile(classPath);
		

		
//		Package model = mmf.createPackage();
//		model.setName(className);
		

		// Find the underlying classes of a package
		if(currentCompiler.isPackage(className)) {
			
			
			
			
			
			List classList = currentCompiler.getClassNames(className);
			log.debug("\t<Package>");
			for (int j = 0; j < classList.size(); j++) {
				String name = classList.elementAt(j).toString();
				createBond(className, className + "." + name, recursive, prevID, SWT.LINE_DASH, SWT.COLOR_GRAY);
			}
			log.debug("\t</Package>");
		}
		
		

		log.debug("\t<Import>");
		// Find service-dependencies among imports
		int num =  currentCompiler.getImportCount(className);
		for (int i = 0; i < num; i++) {
			ICompilerResult res = currentCompiler.getNthImport(className, i+1);
			createBond(className, res.getFirstResult(), recursive, prevID, SWT.LINE_SOLID, SWT.COLOR_DARK_RED);
		}
		log.debug("\t</Import>");

		log.debug("\t<Inheritance>");
		// Find inheritance-dependencies
		num =  currentCompiler.getInheritanceCount(className);
		for (int i = 0; i < num; i++) {
			ICompilerResult res = currentCompiler.getNthInheritedClass(className, i+1);
			createBond(className, res.getFirstResult(), recursive, prevID, SWT.LINE_SOLID, SWT.COLOR_GREEN);
		}
		log.debug("\t</Inheritance>");

		log.debug("\t<Components>");
		// Find component-dependencies
		List componentList = currentCompiler.getComponents(className);
		for (int j = 0; j < componentList.size(); j++) {
			String nam = componentList.elementAt(j).toString();
			createBond(className, nam, recursive, prevID, SWT.LINE_SOLID, SWT.COLOR_DARK_GREEN);
		}
		log.debug("\t</Components>");

		log.debug("\t<AlgorithmItem>");
		// Find function-call-dependencies among algorithms
		num =  currentCompiler.getAlgorithmItemsCount(className);
		for (int i = 0; i < num; i++) {
			ICompilerResult res = currentCompiler.getNthAlgorithmItem(className, i+1);
			String trimRes = res.getFirstResult();
			checkExist(className, trimRes, recursive, prevID);
		}
		log.debug("\t</AlgorithmItem>");

		log.debug("\t<EquationItems>");
		// Find function-call-dependencies among equations
		num =  currentCompiler.getEquationItemsCount(className);
		for (int i = 0; i < num; i++) {
			ICompilerResult res = currentCompiler.getNthEquationItem(className, i+1);
			String trimRes = res.getFirstResult();
			checkExist(className, trimRes, recursive, prevID);
		}
		log.debug("\t</EquationItems>");

		// Check if this has a dependency from a package
//		log.debug("\t<Parent>");
//		analyzeParent(prevID, className, false);
//		log.debug("\t</Parent>");
		return prevID;
	}

	/**
	 * Provides the information of the tooltip for the given node, using results
	 * from Modelica API.
	 *
	 * @param node
	 *            the ModelicaNode that stores all information about every node
	 * @param className
	 *            the name of this class
	 * @param filePath
	 *            the path to the file
	 * @exception ConnectException
	 *                if the Modelica compiler can't be loaded
	 * @exception UnexpectedReplyException
	 *                if the Modelica compiler returns something strange
	 */
	private static void setToolTipInfo(ModelicaNode node, String className, String classPath)
			throws ConnectException, UnexpectedReplyException {
		// loads the file in order to perform new OMC calls on this specific file
		currentCompiler.loadFile(classPath);

		String classType = currentCompiler.getClassRestriction(className).getFirstResult().replace("\"", "");
		classType = classType.trim();
		String classComment = currentCompiler.getClassComment(className).getFirstResult().replace("\"", "");
		classComment = classComment.trim();
		node.setClassName(className);

		// extract substring of full class name
		if (className.contains(".")){
			node.setClassName(className.substring(className.lastIndexOf(".")+1, className.length()));
		}

		// extract the class type if there is any
		if (!classType.isEmpty())
			node.setClassType(classType.substring(0, 1).toUpperCase() + classType.substring(1, classType.length()));

		node.setClassDescription(classComment);
		node.setClassPosition(className);
		node.setClassPath(classPath);		
	}
	
	

	private static EObject createClass(ModelicaNode node, String className, String classPath)
			throws ConnectException, UnexpectedReplyException
	{
		currentCompiler.loadFile(classPath);

		String classType = currentCompiler.getClassRestriction(className)
				.getFirstResult().replace("\"", "");
		classType = classType.trim();

		// extract the class type if there is any
		if (!classType.isEmpty())
			node.setClassType(classType.substring(0, 1).toUpperCase()
					+ classType.substring(1, classType.length()));
		
		
//		switch (classType)
//		{
//		case "Block":
//			Block blockImpl = mmf.createBlock();
//			blockImpl.setName(className);
//			return blockImpl;
//		case "Connector":
//			Connector connectorImpl = mmf
//					.createConnector();
//			connectorImpl.setName(className);
//			return connectorImpl;
//		case "Function":
//			Function functionImpl = mmf
//					.createFunction();
//			functionImpl.setName(className);
//			return functionImpl;
//		case "Package":
//			Package packageImpl = mmf
//					.createPackage();
//			packageImpl.setName(className);
//			return packageImpl;
//		}

		return null;
	}

	/**
	 * Parse the line of code in order to find any function calls that
	 * inflicts dependencies
	 *
	 * @param className
	 *            the name of this class
	 * @param trimRes
	 *            the trimmed string that resulted of a OMC call
	 * @param recursive
	 *            tells whether or not the analyze should be performed recursively
	 * @exception ConnectException
	 *                if the Modelica compiler can't be loaded
	 * @exception UnexpectedReplyException
	 *                if the Modelica compiler returns something strange
	 * @exception InvocationException
	 *                if the Modelica compiler replies with an unexpected error in results
	 */
	private static void checkExist(String className, String trimRes, boolean recursive, int prevID)
			throws ConnectException, UnexpectedReplyException, InvocationError {
		int lastIndex = 0;
		int count = 0;

		while (lastIndex != -1) {
			lastIndex = trimRes.indexOf("(", lastIndex);
			if (lastIndex != -1) {
				count++;
				lastIndex++;
			}
		}

		// Removes all unnecessary stuff
		trimRes = trimRes.replaceAll("\"","");
		while (count > 0){
			String tempRes = trimRes.substring(0, trimRes.indexOf('('));
			trimRes = trimRes.substring(tempRes.length()+1, trimRes.length());

			trimRes.replaceAll("\\s\\+\\-\\*\\=\\<\\>\\:", "");
			tempRes = tempRes.trim();
			tempRes = tempRes.substring(tempRes.lastIndexOf(" ")+1,tempRes.length());

			// TODO: Keep track of what has been found before?

			// Create a connection from this found function dependency
			if (tempRes.length() != 0 && currentCompiler.existClass(tempRes))
				createBond(className, tempRes, recursive, prevID, SWT.LINE_DOT, SWT.COLOR_GREEN);
			count -=1;
		}
	}

	/**
	 * Analyzes if something comes from a package. If it does then we need
	 * to create a new connection from this dependency
	 *
	 * @param prevId
	 *            the ID of the previous node that started a dependency to this node
	 * @param fullName
	 *            the name of this class, including all . characters
	 * @param recursive
	 *            tells whether or not the analyze should be performed recursively
	 * @exception ConnectException
	 *                if the Modelica compiler can't be loaded
	 * @exception UnexpectedReplyException
	 *                if the Modelica compiler returns something strange
	 * @exception InvocationException
	 *                if the Modelica compiler replies with an unexpected error in results
	 */
	public static void analyzeParent(int prevID, String fullName, boolean recursive)
			throws ConnectException, UnexpectedReplyException, InvocationError {
		if (fullName.contains(".") && currentCompiler.isPackage(fullName.substring(0, fullName.lastIndexOf(".")))){
			String packageName = fullName.substring(0, fullName.lastIndexOf("."));
			createBond(fullName, packageName, recursive, prevID, SWT.LINE_DASH, SWT.COLOR_GRAY);
		}
	}

	
	private static boolean isNumeric(String str)
	{
	  return str.matches("-?\\d+(\\.\\d+)?");  //match a number with optional '-' and decimal.
	}
	
	/**
	 * Creates a connection
	 *
	 * @param sourceName
	 *            the name of the object that inflicts the dependency
	 * @param targetName
	 *            the name of the object the dependency should point to
	 * @param rec
	 *            tells whether or not the analyze should be performed recursively
	 * @param prev
	 *            the ID of the previous node that started the dependency
	 * @param style
	 *            tells what style the connection should have
	 * @param color
	 *            tells what color the target node should have
	 * @exception ConnectException
	 *                if the Modelica compiler can't be loaded
	 * @exception UnexpectedReplyException
	 *                if the Modelica compiler returns something strange
	 * @exception InvocationException
	 *                if the Modelica compiler replies with an unexpected error in results
	 */
	public static void createBond(String sourceName, String targetName, boolean recursive, int prev, int style, int color)
			throws ConnectException, UnexpectedReplyException, InvocationError {

		log.debug("\t\t<CreatingBond name=" + targetName + ">");
		if(sourceName.equals(targetName)){
			log.debug("\t\t<SourceEqualsTarget/>");
			log.debug("\t\t</CreatingBond>");
			return;
		}
		
		
//		String testedPackage = "Blocks";
//		if(!targetName.contains(testedPackage)){
//			log.debug("\t\t<TargetNotIn"+ testedPackage + "/>");
//			
//			log.debug("\t\t</CreatingBond>");
//			return;
//			
//		}
		
		
		// TODO: OpenModelica is missing a good way of checking for a Keyword
		if (targetName.equals("Real") ||
			targetName.equals("assert") ||
			targetName.equals("Integer") ||
			targetName.equals("Boolean") ||
			isNumeric(targetName)){
			log.debug("\t\t<TargetEqualsSomePimitive/>");
			
			log.debug("\t\t</CreatingBond>");
			return;
		}
		String tmp = targetName.toLowerCase();
		//Pattern.compile("stores.*store.*product").matcher(tmp).find();
		if(tmp.contains("(") ||
				tmp.contains("{") ||
				tmp.contains("$") ||
				tmp.contains(":"))	{
			log.debug("\t\t<TargetContainsModString/>");
			
			log.debug("\t\t</CreatingBond>");
			return;
		}

		String myPath = (new Path(ModelicaGraphAnalyzer.currentCompiler.getClassLocation(sourceName).getPath()).toString());
		ArrayList<Integer> lineNumbers = findLineNumber(myPath, targetName);
		boolean familiar = true;

		
		
		if (!nodesContains(targetName))
		{
			nid += 1;
			ModelicaNode node = new ModelicaNode(nid, targetName, color);
			ModelicaGraphGenerator.nodes.add(node);
			ModelicaGraphGenerator.nodesMap.put(node.getName(),node);
			familiar = false;
			setToolTipInfo(node, targetName, myPath);
			EObject ClassModel = createClass(node, targetName, myPath);
			
			
			// recursive
//			if (recursive && counter < LIMIT)
			if (recursive)
			{
				counter++;
				analyzeClasses(nid, targetName, recursive);
			}
		}
		
		

		int n = 0;
		// Fix for handling analyze of multiple trees of classes
		if(!nodesContains(targetName))
			n = nid;
		else {
			int j;
			for(j = 0; j < ModelicaGraphGenerator.nodes.size(); j++)
			   if (ModelicaGraphGenerator.nodes.get(j).getName().equals(targetName))
					   n = j;
		}

		ModelicaNode currentNode = ModelicaGraphGenerator.nodes.get(n);
		ModelicaNode prevNode = ModelicaGraphGenerator.nodes.get(prev);

		if (familiar) {
			ModelicaNode instantNode = null;
			for (int i = 0; i < ModelicaGraphGenerator.nodes.size(); i++)
				instantNode = ModelicaGraphGenerator.nodes.get(i);
			if (instantNode.getName().endsWith(targetName))
				n = instantNode.getId();
		}

		// Connection exist in opposite direction
		if (connectionsContains(currentNode.getName(), prevNode.getName()) &&
				!prevNode.getName().equals(currentNode.getName())) {
			// Bend what is already there
			// TODO: This has to be regenerated somehow as well in order to be visualized

			ModelicaConnection instantConnection = null;
			for (int i = 0; i < ModelicaGraphGenerator.connections.size(); i++) {
				instantConnection = ModelicaGraphGenerator.connections.get(i);
				if (instantConnection.getSource().getName().equals(currentNode.getName()) &&
						instantConnection.getDestination().getName().equals(prevNode.getName()))
					instantConnection.setBending();
			}

			// Bend the new connection at the same place
			ModelicaConnection connect = new ModelicaConnection(
					Integer.toString(cid), "test", prevNode, currentNode, style, targetName, lineNumbers);
			connect.setBending();
			ModelicaGraphGenerator.connections.add(connect);
			cid += 1;
		}

		// Connection doesn't exist in neither direction
		else if (!connectionsContains(prevNode.getName(), currentNode.getName()) &&
				!prevNode.getName().equals(currentNode.getName())) {
			ModelicaConnection connect = new ModelicaConnection(
					Integer.toString(cid), "test", prevNode, currentNode, style, targetName, lineNumbers);
			ModelicaGraphGenerator.connections.add(connect);
			cid += 1;
		}
		log.debug("\t\t</CreatingBond>");
	}

	/**
	 * This will iterate over all the stored nodes and check if a name
	 * exist among them.
	 *
	 * @param comparingString
	 *            the name that should be found among the stored nodes
	 * @return true if it was found, otherwise false
	 */
	public static boolean nodesContains(String comparingString) {
		return null != ModelicaGraphGenerator.nodesMap.get(comparingString);
		/*for (int i = 0; i < ModelicaGraphGenerator.nodes.size(); i++) {
			ModelicaNode currentNode = ModelicaGraphGenerator.nodes.get(i);
			if (currentNode.getName().equals(comparingString)) {
				return true;
			}
		}
		return false;*/
	}

	/**
	 * This will iterate over all the stored connections and check if a connection
	 * exist among them with a specific source and a specific target.
	 *
	 * @param comparingSource
	 *            the source of a connection that should be found
	 * @param comparingTarget
	 *            the target of a connection that should be found
	 * @return true if it was found, otherwise false
	 */
	public static boolean connectionsContains(String comparingSource, String comparingDestination) {
		for (int i = 0; i < ModelicaGraphGenerator.connections.size(); i++) {
			ModelicaConnection currentConnection = ModelicaGraphGenerator.connections.get(i);
			if (currentConnection.getSource().getName().equals(comparingSource) &&
					currentConnection.getDestination().getName().equals(comparingDestination))
				return true;
		}
		return false;
	}

	/**
	 * Parse a file to find all lines where a certain string exist
	 *
	 * @param file
	 *            the name of this file
	 * @param text
	 *            the text that should be found
	 * @return an array of line numbers where the text was found
	 * @exception ConnectException
	 *                if the Modelica compiler can't be loaded
	 * @exception UnexpectedReplyException
	 *                if the Modelica compiler returns something strange
	 */
	private static ArrayList<Integer> findLineNumber(String file, String text) throws ConnectException, UnexpectedReplyException {
		Scanner fileScanner = null;
		try
		{
			fileScanner = new Scanner(new File(file));
		} catch (FileNotFoundException e)
		{
			e.printStackTrace();
		}
		int lineID = 0;
		ArrayList<Integer> lineNumbers = new ArrayList<Integer>();
		Pattern pattern =  Pattern.compile("\\b" + text);
		Matcher matcher = null;

		while(fileScanner.hasNextLine()){
			String line = fileScanner.nextLine();
			lineID++;
			matcher = pattern.matcher(line);
			if(matcher.find()){
				lineNumbers.add(lineID);
			}
		}
		return lineNumbers;
	}

	/**
	 * Finds out what connections needs to be destroyed and in some
	 * cases even the destroy the node pointed at
	 *
	 * @param sourceID
	 *            the ID of the source to the dependency/pointer
	 * @param className
	 *            the name of the class
	 * @return an array of the IDs that were destroyed non-visually
	 */
	public static ArrayList<Integer> destructClasses(int sourceID, String className) {
		ArrayList<Integer> destroyedConnections = new ArrayList<Integer>();
		for(int i = 0; i < ModelicaGraphGenerator.connections.size(); i++) {
			if(ModelicaGraphGenerator.connections.get(i).getSource().getName().equals(className)) {
				destroyedConnections.add(i);
			}
		}

		for(int i = destroyedConnections.size()-1; i >= 0; i--) {
			if (ModelicaGraphGenerator.connections.get(destroyedConnections.get(i)).getDestination().isExpandable())
			{
				// We can possibly also remove the node pointed at
				ModelicaGraphGenerator.nodes.remove(ModelicaGraphGenerator.connections.get(destroyedConnections.get(i)).getDestination().getId());

				// Update all the old nodes with a id larger than the the destroyed one that they have to be reduced
				for(int j = ModelicaGraphGenerator.connections.get(destroyedConnections.get(i)).getDestination().getId(); j < ModelicaGraphGenerator.nodes.size(); j++)
					ModelicaGraphGenerator.nodes.get(j).setId(ModelicaGraphGenerator.nodes.get(j).getId()-1);
				nid -= 1;
			}
			int resulting = destroyedConnections.get(i);
			ModelicaGraphGenerator.connections.remove(resulting);
			cid -= 1;
		}
		return destroyedConnections;
	}

	// Restricted access to some of the private variables
	public static IModelicaCompiler getModelicaCompiler() { return currentCompiler; }
	public static void setNid(int n) { nid = n; }
	public static void setCid(int c) { cid = c; }
}
