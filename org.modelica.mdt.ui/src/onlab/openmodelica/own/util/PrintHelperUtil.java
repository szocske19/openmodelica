package onlab.openmodelica.own.util;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import org.apache.log4j.FileAppender;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;

public class PrintHelperUtil
{
	private static FileAppender fa = new FileAppender();
	
	public static void setUpLogging(String className){
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
		fa.setFile("C:\\runtime-New_configuration\\log\\" 
				+ className + "_" + reportDate + ".log");
		// fa.setLayout(new PatternLayout("%d %-5p [%c{1}] %m%n"));
		fa.setLayout(new PatternLayout("%m%n"));

		fa.setThreshold(Level.DEBUG);
		fa.setAppend(true);
		fa.activateOptions();

		//add appender to any Logger (here is root)
		Logger logger = Logger.getRootLogger();
//		BasicConfigurator.configure();

		logger.addAppender(fa);
		logger.setLevel(Level.DEBUG);
		//repeat with all other desired appenders
//		PropertyConfigurator.configure("log4j.properties");
		
	}
}
