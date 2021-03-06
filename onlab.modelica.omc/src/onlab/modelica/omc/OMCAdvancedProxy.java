package onlab.modelica.omc;

import org.apache.log4j.Logger;
import org.modelica.mdt.core.ICompilerResult;
import org.modelica.mdt.core.List;
import org.modelica.mdt.core.ModelicaParserException;
import org.modelica.mdt.core.compiler.ConnectException;
import org.modelica.mdt.core.compiler.UnexpectedReplyException;
import org.modelica.mdt.omc.OMCProxy;

import onlab.modelica.omc.AnswerListParser.ListType;

public class OMCAdvancedProxy extends OMCProxy {
	
	private static Logger log = Logger.getLogger(OMCAdvancedProxy.class.getName());
	
	@Override
	public ICompilerResult getNthImport(String className, int n) throws ConnectException, UnexpectedReplyException {
		ICompilerResult res = sendExpression("getNthImport(" + className + ", " + n + ")", true);
		sendExpression("tmpImportName := " + res.getFirstResult(), true);
		ICompilerResult res3 = sendExpression("stringTypeName(tmpImportName[1])", true);
		res3.trimFirstResult();

		return res3;
	}

	@Override
	public List getComponents(String className) throws ConnectException, UnexpectedReplyException {
		ICompilerResult res = sendExpression("getComponents("+ className +")", true);
		List list = null;
		try {
			list = AnswerListParser.parseList(res.getFirstResult(), ListType.COMPONENT_ELEMENT);
		}
		catch (ModelicaParserException e) {
			throw new UnexpectedReplyException("Unable to parse list: "
					+ e.getMessage());
		}
		
		return list;
	}

	@Override
	public ICompilerResult sendExpression(String command, boolean showInConsole) throws ConnectException {
		ICompilerResult result = super.sendExpression(command, showInConsole);

		
		String str = String.join(", ", result.getResult()) + "\n";
		str = str.replaceAll("\\}(.)\\{", "},\n{");
		
		log.debug(String.format("						Command: %-160.160s \n", command));
		log.debug(String.format("						Reply: %s \n", str));
		if(result.getResult() == null || result.getFirstResult() == null || result.getFirstResult().equals("")){
			throw new ConnectException("Reply to the command is empty. The Command is: " + command);
		}
		

		return result;
	}
	
	@Override
	public List getExtendsModifierNames(String subClass, String superclass) throws ConnectException, UnexpectedReplyException{
		String command = "getExtendsModifierNames(" + subClass + "," + superclass + ")";
		ICompilerResult result = sendExpression(command, true);
		
		List list = null;		
		try {
			list = AnswerListParser.parseList(result.getFirstResult(), ListType.EXTENDS_MODIFIER);
		}
		catch (ModelicaParserException e) {
			throw new UnexpectedReplyException("Unable to parse list: "
					+ e.getMessage());
		}
		
		return list;
	}
	
	@Override
	public ICompilerResult getExtendsModifierValue(String subClass, String superclass, String modifiers) throws ConnectException{
		String command = "getExtendsModifierValue(" + subClass + "," + superclass + "," + modifiers + ")";
		ICompilerResult result = sendExpression(command, true);
		
		return result;
	}
	
	@Override
	public Boolean isEnumeration(String subClass) throws ConnectException{
		String command = "isEnumeration(" + subClass + ")";
		ICompilerResult result = sendExpression(command, true);
		
		return result.getFirstResult().trim().equals("true");
	}
	
	@Override
	public List getLoadedLibraries() throws ConnectException, UnexpectedReplyException{
		String command = "getLoadedLibraries()";
		ICompilerResult result = sendExpression(command, true);
		
		List list = null;		
		try {
			list = AnswerListParser.parseList(result.getFirstResult(), ListType.LOADED_LIBRARY);
		}
		catch (ModelicaParserException e) {
			throw new UnexpectedReplyException("Unable to parse list: "
					+ e.getMessage());
		}
		
		return list;
	}
	
	@Override
	public ICompilerResult getParameterValue(String className, String parameter)
			throws ConnectException
	{
		String command = "getParameterValue(" + className + ", \"" + parameter + "\")";
		ICompilerResult result = sendExpression(command, true);		
		
		return result;
	}
	
}

