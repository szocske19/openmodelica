
package onlab.openmodelica.own.implementation.of.mdt;

import java.util.ArrayList;

import openmodelica.MoClass;

public class LevelNode
{
	private ArrayList<LevelNode> parents;
	private ArrayList<LevelNode> children;
	private int level;
	private MoClass cp;

	public LevelNode(MoClass cp, LevelNode parent, int level){
		this.level = level;
		this.cp = cp;
		this.parents = new ArrayList<LevelNode>();		
		this.children = new ArrayList<LevelNode>();
		
		if(parent != null){
			this.parents.add(parent);
			parent.children.add(this);
		}
	}
	
	public MoClass getCp()
	{
		return cp;
	}

	public int getLevel()
	{
		return level;
	}
	
	public void raiseLevelAndChangeParent(LevelNode newParent, int newLevel){
		if(newParent != null){
			parents.add(newParent);
			newParent.children.add(this);
		}
		raiseLevel(newLevel);
	}	

	private void raiseLevel(int newLevel){
		System.out.println("cp: " + cp.getName() + ", old level: " + level + ", new level: " + newLevel );
		if(newLevel > level){
			level = newLevel;
			for (LevelNode child : children)
			{
				child.raiseLevel(newLevel+1);			
			}
		}
	}

}
