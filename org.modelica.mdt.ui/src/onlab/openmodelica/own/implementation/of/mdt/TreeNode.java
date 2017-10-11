
package onlab.openmodelica.own.implementation.of.mdt;

import java.awt.Component;
import java.util.ArrayList;

import openmodelica.ComponentPrototype;

public class TreeNode
{
	private ArrayList<TreeNode> children;
	private TreeNode parent;
	private String name; //key
	private int level;
	private ComponentPrototype componentPrototype;
	
	public ComponentPrototype getComponentPrototype()
	{
		return componentPrototype;
	}

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
	
	public TreeNode(String name, int level, TreeNode parent, ComponentPrototype componentPrototype)
	{
		this.name = name;
		this.level = level;
		this.parent = parent;
		this.children = new ArrayList<TreeNode>();
		this.componentPrototype= componentPrototype; 
	}
	
	public void print(){
		System.out.println("	name: " + name + " level: " + level + " children:\n");
		for (TreeNode treeNode : children)
		{
			System.out.print("		" + treeNode.name);
		}
	}
	
	
}
