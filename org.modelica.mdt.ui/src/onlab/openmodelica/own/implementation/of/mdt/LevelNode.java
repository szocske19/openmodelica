
package onlab.openmodelica.own.implementation.of.mdt;

import java.util.ArrayList;

import openmodelica.ComponentPrototype;

public class LevelNode
{
	private LevelNode parent;
	private ArrayList<LevelNode> children;
	private int level;
	private ComponentPrototype cp;

	public LevelNode(ComponentPrototype cp, LevelNode parent, int level){
		this.level = level;
		this.cp = cp;
		this.parent = parent;
		children = new ArrayList<LevelNode>();
		
		if(this.parent != null){
			this.parent.children.add(this);
		}
	}
	
	public ComponentPrototype getCp()
	{
		return cp;
	}

	public int getLevel()
	{
		return level;
	}
	
	public void raiseLevelAndChangeParent(LevelNode newParent, int levelDifference){
		if(parent != null){
			parent.children.remove(this);
		}
		parent = newParent;
		parent.children.add(this);
		raiseLevel(levelDifference);
	}	

	private void raiseLevel(int levelDifference){
		System.out.println("cp: " + cp.getName() + ", old level: " + level + ", new level: " + ( level + levelDifference ) );
		level += levelDifference;
		if(children != null){
			for (LevelNode child : children)
			{
				child.raiseLevel(levelDifference);			
			}
		}
	}

}
