
package onlab.openmodelica.own.implementation.of.mdt;

import openmodelica.MoClass;

public class ClassContent
{
	private LinkType linkType;
	private MoClass node;
	

	public LinkType getLinkType()
	{
		return linkType;
	}

	public void setLinkType(LinkType linkType)
	{
		this.linkType = linkType;
	}

	public MoClass getNode()
	{
		return node;
	}

	public void setNode(MoClass node)
	{
		this.node = node;
	}
}
