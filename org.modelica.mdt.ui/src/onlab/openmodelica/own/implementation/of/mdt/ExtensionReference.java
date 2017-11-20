
package onlab.openmodelica.own.implementation.of.mdt;

import openmodelica.MoClass;

public class ExtensionReference
{
	private MoClass superClass;

	public MoClass getSuperClass()
	{
		return superClass;
	}

	public ExtensionReference(MoClass superClass)
	{
		this.superClass = superClass;
	}
	
	
}
