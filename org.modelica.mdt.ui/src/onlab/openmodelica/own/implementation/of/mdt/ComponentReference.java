
package onlab.openmodelica.own.implementation.of.mdt;

import onlab.modelica.omc.ComponentElement;
import openmodelica.MoClass;

public class ComponentReference
{
	private ComponentElement containmentProperites;
	private MoClass cp;
	
	public ComponentReference(ComponentElement containmentProperites, MoClass cp){
		this.containmentProperites = containmentProperites;
		this.cp = cp;
	}

	public ComponentElement getProperites()
	{
		return containmentProperites;
	}

	public MoClass getComponent()
	{
		return cp;
	}
	
	
	
	
}
