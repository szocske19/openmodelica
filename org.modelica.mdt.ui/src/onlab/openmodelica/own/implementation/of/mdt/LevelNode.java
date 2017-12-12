
package onlab.openmodelica.own.implementation.of.mdt;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import openmodelica.MoClass;

public class LevelNode
{
	private ArrayList<LevelNode> parents;
	private ArrayList<LevelNode> children;
	private int level;
	private MoClass cp;
	private boolean alreadyCalled;

	public LevelNode(MoClass cp, LevelNode parent, boolean isFunction){
		this.level = -1;
		this.cp = cp;
		this.parents = new ArrayList<LevelNode>();		
		this.children = new ArrayList<LevelNode>();
		alreadyCalled = false;
		
		if(parent != null && !isFunction){
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
		if(level != -1){
			return level;
		}
		if(!alreadyCalled){
			setLevel();
		}
		return level;
	}
	
	public void setLevel(){
		alreadyCalled = true;
		List<Integer> parentsLevel = new ArrayList<Integer>();
		for (LevelNode parent : parents){
			if(parent != null){
				int x = parent.getLevel();
				if(!children.contains(parent)){
					x += 1;
				}
				parentsLevel.add(x);
			}
		}
		
		if(parentsLevel.size() == 0){
			level = 0;
		} else {
			Collections.sort(parentsLevel);
			level = parentsLevel.get(parentsLevel.size()-1);
		}				
	}
	
	public void addParent(LevelNode newParent){
		if(newParent != null){
			if(!newParent.parents.contains(this)){
				parents.add(newParent);
				newParent.children.add(this);
			} else {
				throw new IllegalArgumentException("Circular reference: Child = " + cp.getName() + " newParent = " + newParent.cp.getName());
			}
		}
//		if(newLevel > level){
//			System.out.println("raiseLevel:");
//			raiseLevel(newLevel);
//		}
	}
	

//	private void raiseLevel(int newLevel){
//		System.out.println("cp: " + cp.getName() + ", old level: " + level + ", new level: " + newLevel );
//		if(newLevel > level){
//			level = newLevel;
//			for (LevelNode child : children)
//			{
//				System.out.println("Child of " + cp.getName());
//				child.raiseLevel(newLevel+1);			
//			}
//		}
//	}

}
