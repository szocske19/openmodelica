package onlab.openmodelica.own.implementation.of.mdt;

import org.eclipse.emf.transaction.RecordingCommand;
import org.eclipse.emf.transaction.TransactionalEditingDomain;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure0;

public class EditingDomainHelperUtility {
    
    public static void runWithTransaction(TransactionalEditingDomain editingDomain, Procedure0 procedure) {
        editingDomain.getCommandStack().execute(new RecordingCommand(editingDomain) {
            @Override
            protected void doExecute() {
                procedure.apply();
            }
        });
    }
}

