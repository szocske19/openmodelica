
package onlab.openmodelica.own.implementation.of.mdt;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Deque;
import java.util.HashMap;
import java.util.Map;

import org.apache.log4j.ConsoleAppender;
import org.apache.log4j.FileAppender;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;
import org.eclipse.core.internal.expressions.WithExpression;
import org.eclipse.core.runtime.IPath;
import org.eclipse.emf.ecore.util.Switch;
import org.eclipse.swt.SWT;
import org.modelica.mdt.core.ICompilerResult;
import org.modelica.mdt.core.List;
import org.modelica.mdt.core.compiler.CompilerInstantiationException;
import org.modelica.mdt.core.compiler.ConnectException;
import org.modelica.mdt.core.compiler.IModelicaCompiler;
import org.modelica.mdt.core.compiler.InvocationError;
import org.modelica.mdt.core.compiler.UnexpectedReplyException;
import org.modelica.mdt.internal.core.CompilerProxy;
import org.modelica.mdt.ui.graph.ModelicaGraphAnalyzer;
import org.modelica.mdt.ui.graph.ModelicaGraphGenerator;
import org.modelica.mdt.ui.graph.ModelicaGraphView;
import org.modelica.mdt.ui.graph.ModelicaNode;

import openmodelica.OpenmodelicaFactory;
import openmodelica.OpenmodelicaPackage;
import openmodelica.Package;
import openmodelica.Class;

public class OwnModelicaGraphAnalyzer
{
	// Collect all needed classes exactly once
	private static Map<String, ClassContent> classContentMap = new HashMap();
	
	private static Deque<ClassContent> classContentDeque;
	
	
	
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
			
			int classType = getTypeOfClass(className, classPath);	
			Class mClass = getClass(classType);			
			mClass.setName(className);
			
			
			setCurrentClassContent(mClass);
			
			
			buildClass(mClass);
			
			log.debug("className: " + className);

			
		}
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
	
	private static void setCurrentClassContent(Class A)
			throws ConnectException, UnexpectedReplyException, InvocationError {
		currentCompiler.loadFile(classPath);
		
		String className = A.getName();
		

		// Find the underlying classes of a package
		if(currentCompiler.isPackage(className)) {
			List classList = currentCompiler.getClassNames(className);
			log.debug("\t<Package>");
			for (int j = 0; j < classList.size(); j++) {
				String name = classList.elementAt(j).toString();
//				classContentMap.add()
//				createBond(className, className + "." + name, recursive, prevID, SWT.LINE_DASH, SWT.COLOR_GRAY);
				
			}
			log.debug("\t</Package>");
		}
		
		

		log.debug("\t<Import>");
		// Find service-dependencies among imports
		int num =  currentCompiler.getImportCount(className);
		for (int i = 0; i < num; i++) {
			ICompilerResult res = currentCompiler.getNthImport(className, i+1);
//			createBond(className, res.getFirstResult(), recursive, prevID, SWT.LINE_SOLID, SWT.COLOR_DARK_RED);
		}
		log.debug("\t</Import>");

		log.debug("\t<Inheritance>");
		// Find inheritance-dependencies
		num =  currentCompiler.getInheritanceCount(className);
		for (int i = 0; i < num; i++) {
			ICompilerResult res = currentCompiler.getNthInheritedClass(className, i+1);
//			createBond(className, res.getFirstResult(), recursive, prevID, SWT.LINE_SOLID, SWT.COLOR_GREEN);
		}
		log.debug("\t</Inheritance>");

		log.debug("\t<Components>");
		// Find component-dependencies
		List componentList = currentCompiler.getComponents(className);
		for (int j = 0; j < componentList.size(); j++) {
			String nam = componentList.elementAt(j).toString();
//			createBond(className, nam, recursive, prevID, SWT.LINE_SOLID, SWT.COLOR_DARK_GREEN);
		}
		log.debug("\t</Components>");

		log.debug("\t<AlgorithmItem>");
		// Find function-call-dependencies among algorithms
		num =  currentCompiler.getAlgorithmItemsCount(className);
		for (int i = 0; i < num; i++) {
			ICompilerResult res = currentCompiler.getNthAlgorithmItem(className, i+1);
			String trimRes = res.getFirstResult();
//			checkExist(className, trimRes, recursive, prevID);
		}
		log.debug("\t</AlgorithmItem>");

		log.debug("\t<EquationItems>");
		// Find function-call-dependencies among equations
		num =  currentCompiler.getEquationItemsCount(className);
		for (int i = 0; i < num; i++) {
			ICompilerResult res = currentCompiler.getNthEquationItem(className, i+1);
			String trimRes = res.getFirstResult();
//			checkExist(className, trimRes, recursive, prevID);
		}
		log.debug("\t</EquationItems>");

		// Check if this has a dependency from a package
//		log.debug("\t<Parent>");
//		analyzeParent(prevID, className, false);
//		log.debug("\t</Parent>");
	}
	
	private static int getTypeOfClass(String className, String classPath)
			throws ConnectException, UnexpectedReplyException
	{
		String classType = currentCompiler.getClassRestriction(className)
				.getFirstResult().replace("\"", "");

		switch (classType.trim())
		{
		case "block":
			return OpenmodelicaPackage.BLOCK;
		case "class":
			return OpenmodelicaPackage.CLASS;
		default:
			throw new IllegalArgumentException(
					"The class '" + className + "' is not a valid classifier");
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
		default:
			throw new IllegalArgumentException(
					"The type '" + type + "' is not a valid classifier");

		}
	}
	
	private static void buildClass(Class mClass){
		
	}

}
