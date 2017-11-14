package onlab.modelica.omc;

import org.modelica.mdt.core.ICompilerResult;
import org.modelica.mdt.core.List;
import org.modelica.mdt.core.ModelicaParserException;
import org.modelica.mdt.core.compiler.ConnectException;
import org.modelica.mdt.core.compiler.UnexpectedReplyException;
import org.modelica.mdt.omc.OMCProxy;

public class OMCAdvancedProxy extends OMCProxy {
	
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
			list = ComponentAdvancedParser.parseList(res.getFirstResult());
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

		System.out.printf("						Command: %-160.160s \n", command);
		System.out.printf("						Reply: %s \n", String.join(",", result.getResult()));

		return result;
	}
	
	@Override
	public ICompilerResult getExtendsModifierNames(String subClass, String superclass) throws ConnectException{
		String command = "getExtendsModifierNames(" + subClass + "," + superclass + ")";
		ICompilerResult result = sendExpression(command, true);
		
		return result;
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
			list = LoadedLibrariesParser.parseList(result.getFirstResult());
		}
		catch (ModelicaParserException e) {
			throw new UnexpectedReplyException("Unable to parse list: "
					+ e.getMessage());
		}
		
		return list;
	}
	
}

