
package onlab.openmodelica.own.implementation.of.mdt;

import onlab.modelica.omc.ComponentElement;
import openmodelica.ComponentPrototype;

public class ComponentReference
{
	private ComponentElement containmentProperites;
	private ComponentPrototype cp;
	
	public ComponentReference(ComponentElement containmentProperites, ComponentPrototype cp){
		this.containmentProperites = containmentProperites;
		this.cp = cp;
	}

	public ComponentElement getProperites()
	{
		return containmentProperites;
	}

	public ComponentPrototype getComponent()
	{
		return cp;
	}
	
	
	
	
}
