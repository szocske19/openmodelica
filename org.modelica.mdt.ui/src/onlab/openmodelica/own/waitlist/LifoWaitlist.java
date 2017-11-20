package onlab.openmodelica.own.waitlist;

import java.util.ArrayDeque;
import java.util.Deque;

import openmodelica.MoClass;

public final class LifoWaitlist implements Waitlist {

	private final Deque<MoClass> nodes;

	public LifoWaitlist() {
		nodes = new ArrayDeque<>();
	}

	public static LifoWaitlist create() {
		return new LifoWaitlist();
	}

	@Override
	public void add(final MoClass node) {
		nodes.add(node);
	}

	@Override
	public MoClass remove() {
		
		return nodes.pop();
	}
	
	@Override
	public MoClass getFirst() {		
		return nodes.getFirst();
	}

	@Override
	public int size() {
		return nodes.size();
	}
	
	@Override
	public void print() {
		System.out.println("Print start");
		for (MoClass cp : nodes)
		{
			cp.toString();			
		}
		System.out.println("Print end");
	}

}
