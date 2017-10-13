package onlab.modelica.omc;

import java.io.File;
import java.io.OutputStream;
import java.util.Collection;

import org.eclipse.core.resources.IFile;
import org.modelica.mdt.core.ICompilerResult;
import org.modelica.mdt.core.IModelicaClass.Restriction;
import org.modelica.mdt.core.List;
import org.modelica.mdt.core.ModelicaParserException;
import org.modelica.mdt.core.compiler.ComponentParser;
import org.modelica.mdt.core.compiler.ConnectException;
import org.modelica.mdt.core.compiler.ElementInfo;
import org.modelica.mdt.core.compiler.IClassInfo;
import org.modelica.mdt.core.compiler.IModelicaCompiler;
import org.modelica.mdt.core.compiler.InvocationError;
import org.modelica.mdt.core.compiler.UnexpectedReplyException;
import org.modelica.mdt.internal.core.DefinitionLocation;
import org.modelica.mdt.omc.OMCProxy;
import org.modelica.mdt.omc.internal.ParseResults;

public class OMCAdvancedProxy extends OMCProxy {

	private OMCProxy omcProxy;

	public OMCAdvancedProxy(OMCProxy omcProxy) {
		this.omcProxy = omcProxy;
	}

	@Override
	public ICompilerResult getNthImport(String className, int n) throws ConnectException, UnexpectedReplyException {
		ICompilerResult res = omcProxy.sendExpression("getNthImport(" + className + ", " + n + ")", true);
		ICompilerResult res2 = omcProxy.sendExpression("tmpImportName := " + res.getFirstResult(), true);
		ICompilerResult res3 = omcProxy.sendExpression("stringTypeName(tmpImportName[1])", true);
		res3.trimFirstResult();

		return res3;
	}

	@Override
	public File[] getOmcBinaryPaths() throws ConnectException {
		return omcProxy.getOmcBinaryPaths();
	}

	@Override
	public void setConsoleOutputStream(OutputStream outputStream) {
		omcProxy.setConsoleOutputStream(outputStream);
	}

	@Override
	public List getClassNames(String className) throws ConnectException, UnexpectedReplyException {

		return omcProxy.getClassNames(className);
	}

	@Override
	public Restriction getRestriction(String className) throws ConnectException, UnexpectedReplyException {

		return omcProxy.getRestriction(className);
	}

	@Override
	public boolean isError(String retval) {

		return omcProxy.isError(retval);
	}

	@Override
	public ParseResults loadSourceFile(IFile file) throws ConnectException, UnexpectedReplyException {

		return omcProxy.loadSourceFile(file);
	}

	@Override
	public DefinitionLocation getClassLocation(String className)
			throws ConnectException, UnexpectedReplyException, InvocationError {

		return omcProxy.getClassLocation(className);
	}

	@Override
	public boolean isPackage(String className) throws ConnectException {

		return omcProxy.isPackage(className);
	}

	@Override
	public Collection<ElementInfo> getElements(String className)
			throws ConnectException, InvocationError, UnexpectedReplyException {

		return omcProxy.getElements(className);
	}

	@Override
	public IClassInfo getClassInfo(String className) throws ConnectException, UnexpectedReplyException {

		return omcProxy.getClassInfo(className);
	}

	@Override
	public String getCompilerVersion() throws ConnectException {

		return omcProxy.getCompilerVersion();
	}

	@Override
	public String getCompilerName() {

		return omcProxy.getCompilerName();
	}

	@Override
	public String[] getStandardLibrary() throws ConnectException {

		return omcProxy.getStandardLibrary();
	}

	@Override
	public ICompilerResult getClassString(String className) throws ConnectException, UnexpectedReplyException {

		return omcProxy.getClassString(className);
	}

	@Override
	public boolean isRunning() {

		return omcProxy.isRunning();
	}

	@Override
	public ICompilerResult getNthInheritedClass(String className, int n)
			throws ConnectException, UnexpectedReplyException {

		return omcProxy.getNthInheritedClass(className, n);
	}

	@Override
	public int getInheritanceCount(String className) throws ConnectException, UnexpectedReplyException {

		return omcProxy.getInheritanceCount(className);
	}

	@Override
	public ICompilerResult getNthAlgorithmItem(String className, int n)
			throws ConnectException, UnexpectedReplyException {

		return omcProxy.getNthAlgorithmItem(className, n);
	}

	@Override
	public int getAlgorithmItemsCount(String className) throws ConnectException, UnexpectedReplyException {

		return omcProxy.getAlgorithmItemsCount(className);
	}

	@Override
	public ICompilerResult getNthEquationItem(String className, int n)
			throws ConnectException, UnexpectedReplyException {

		return omcProxy.getNthEquationItem(className, n);
	}

	@Override
	public int getEquationItemsCount(String className) throws ConnectException, UnexpectedReplyException {

		return omcProxy.getEquationItemsCount(className);
	}

	@Override
	public List getComponents(String className) throws ConnectException, UnexpectedReplyException {
		ICompilerResult res = omcProxy.sendExpression("getComponents("+ className +")", true);
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
	public boolean existClass(String className) throws ConnectException, UnexpectedReplyException {

		return omcProxy.existClass(className);
	}

	@Override
	public ICompilerResult getErrorString() throws ConnectException, UnexpectedReplyException {

		return omcProxy.getErrorString();
	}

	@Override
	public ICompilerResult loadFile(String classPath) throws ConnectException, UnexpectedReplyException {

		return omcProxy.loadFile(classPath);
	}

	@Override
	public ICompilerResult getSourceFile(String className) throws ConnectException, UnexpectedReplyException {

		return omcProxy.getSourceFile(className);
	}

	@Override
	public List parseFile(String fileName) throws ConnectException, UnexpectedReplyException {

		return omcProxy.parseFile(fileName);
	}

	@Override
	public ICompilerResult getClassRestriction(String className) throws ConnectException, UnexpectedReplyException {

		return omcProxy.getClassRestriction(className);
	}

	@Override
	public ICompilerResult getClassComment(String className) throws ConnectException, UnexpectedReplyException {

		return omcProxy.getClassComment(className);
	}

	@Override
	public ICompilerResult buildModel(String className) throws ConnectException, UnexpectedReplyException {

		return omcProxy.buildModel(className);
	}

	@Override
	public int getImportCount(String className) throws ConnectException, UnexpectedReplyException {

		return omcProxy.getImportCount(className);
	}

	@Override
	public String getModelicaPath() throws ConnectException, UnexpectedReplyException {

		return omcProxy.getModelicaPath();
	}

	@Override
	public ICompilerResult sendExpression(String command, boolean showInConsole) throws ConnectException {
		ICompilerResult result = omcProxy.sendExpression(command, showInConsole);

		System.out.printf("						Command: %-160.160s \n", command);
		System.out.printf("						Reply: %s \n", result.getResult().toString());

		return result;
	}
}
