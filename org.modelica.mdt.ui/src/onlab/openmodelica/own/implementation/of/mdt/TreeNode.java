
package onlab.openmodelica.own.implementation.of.mdt;

import java.util.ArrayList;

import openmodelica.ComponentPrototype;
import openmodelica.OpenmodelicaFactory;

public class TreeNode
{
	private ArrayList<ComponentReference> children;
	private ArrayList<ExtensionReference> extension;
	private TreeNode parent;
	private String name; // key
	private int level;
	private ComponentPrototype componentPrototype;
	private int prototypeType;

	public void setExtension(ArrayList<ExtensionReference> extension)
	{
		this.extension = extension;
	}
	
	public TreeNode getParent()
	{
		return parent;
	}

	public int getPrototypeType()
	{
		return prototypeType;
	}
	
	public void setPrototypeType(int prototypeType)
	{
		this.prototypeType = prototypeType;
	}

	public ComponentPrototype getComponentPrototype()
	{
		return componentPrototype;
	}

	public void setComponentPrototype(ComponentPrototype componentPrototype)
	{
		this.componentPrototype = componentPrototype;
	}

	public int getLevel()
	{
		return level;
	}

	public String getName()
	{
		return name;
	}

	public ArrayList<ComponentReference> getChildren()
	{
		return children;
	}

	public void setChildren(ArrayList<ComponentReference> children)
	{
		this.children = children;
	}

	public void addChild(ComponentReference child)
	{
		children.add(child);
	}

	public TreeNode(String className, int level, TreeNode parent)
	{
		this.name = className;
		this.level = level;
		this.parent = parent;
		this.children = new ArrayList<ComponentReference>();
	}

	public void print()
	{
		System.out.println(
				"	name: " + name + " level: " + level + " children:\n");
		for (ComponentReference componentReference : children)
		{
			System.out.print("		" + componentReference.toString());
		}
	}

}
