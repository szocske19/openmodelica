
package onlab.openmodelica.own.implementation.of.mdt;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IPath;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.handlers.HandlerUtil;
import org.modelica.mdt.internal.core.ModelicaSourceFile;

public class ModelicaTransfromHandler extends AbstractHandler
{
	OpenModelicaModelTransformationToEMFModel transformation;
	
	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException
	{
		IStructuredSelection selection = (IStructuredSelection) HandlerUtil.getCurrentSelection(event);
		
		String objName = "";
		try {
			IStructuredSelection newSelection = (IStructuredSelection) selection;
			Object obj = newSelection.getFirstElement();
			objName = obj.getClass().getName();
			if (objName.equals("org.modelica.mdt.internal.core.ModelicaSourceFile")) {
				System.out.println("[Change Selection] Found a Modelica-file!");
				
				IStructuredSelection selectedFileSelection = (IStructuredSelection) selection;
				ModelicaSourceFile selectedFile=(ModelicaSourceFile)selectedFileSelection.getFirstElement();
				
				String selectedString = selectedFile.getElementName();
				IFile selectedIFile = selectedFile.getResource();
				IPath selectedPath = selectedIFile.getFullPath();
				IPath selectedLocation = selectedIFile.getLocation();
				String fileName = selectedString.replace(".mo", "");
				
//				ModelicaSourceFile model = getUmlmodelPackage(selection);
				
//				ResourceSet resSet = new ResourceSetImpl();
				
				System.out.println("fileName: " + fileName + ", selectedPath: " + selectedPath + "\n");
				
				//ViatraQueryEngine engine = ViatraQueryEngine.on(new EMFScope(((EObject)selectedFile).eResource().getResourceSet()));
				
				//ResourceSet rs = model.eResource().getResourceSet();
				//ViatraQueryEngine engine = ViatraQueryEngine.on(new EMFScope(rs));
	            //transformation = new OpenModelicaModelTransformationToEMFModel(fileName, selectedPath, engine, rs);
	            transformation = new OpenModelicaModelTransformationToEMFModel(fileName, selectedPath, selectedLocation);
			}
			else {
				System.out.println("[Change Selection] Not a Modelia-file");
			}           
            
		} catch (ClassCastException e) {
			throw new ExecutionException(e.getMessage(), e);			
		}
		transformation.execute();

        return null;
	}

}
