
package onlab.openmodelica.own.implementation.of.mdt;

import openmodelica.ComponentPrototype;

public class ExtensionReference
{
	private ComponentPrototype superClass;

	public ComponentPrototype getSuperClass()
	{
		return superClass;
	}

	public ExtensionReference(ComponentPrototype superClass)
	{
		this.superClass = superClass;
	}
	
	
}
