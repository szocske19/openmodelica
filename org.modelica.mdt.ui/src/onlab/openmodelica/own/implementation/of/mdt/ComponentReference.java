
package onlab.openmodelica.own.implementation.of.mdt;

import org.modelica.mdt.core.ComponentElement;

public class ComponentReference
{
	private ComponentElement component;
	private TreeNode treeNode;
	
	public ComponentReference(ComponentElement component, TreeNode treeNode){
		this.component = component;
		this.treeNode = treeNode;
	}

	public ComponentElement getComponent()
	{
		return component;
	}

	public TreeNode getTreeNode()
	{
		return treeNode;
	}
	
	
	
	
}
