
package onlab.openmodelica.own.implementation.of.mdt;

import java.util.ArrayList;

public class TreeNode
{
	private ArrayList<TreeNode> children;
	private TreeNode parent;
	private String name;
	private int level;
	
	public int getLevel()
	{
		return level;
	}

	public String getName()
	{
		return name;
	}

	public ArrayList<TreeNode> getChildren()
	{
		return children;
	}

	public void setChildren(ArrayList<TreeNode> children)
	{
		this.children = children;
	}
	
	public void addChild(TreeNode child){
		children.add(child);
	}
	
	public TreeNode(String name, int level, TreeNode parent)
	{
		this.name = name;
		this.level = level;
		this.parent = parent;
		this.children = new ArrayList<TreeNode>();
	}
	
	
}
