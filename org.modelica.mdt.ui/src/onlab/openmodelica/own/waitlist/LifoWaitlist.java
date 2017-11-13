package onlab.openmodelica.own.waitlist;

import java.util.ArrayDeque;
import java.util.Deque;

import openmodelica.ComponentPrototype;

public final class LifoWaitlist implements Waitlist {

	private final Deque<ComponentPrototype> nodes;

	public LifoWaitlist() {
		nodes = new ArrayDeque<>();
	}

	public static LifoWaitlist create() {
		return new LifoWaitlist();
	}

	@Override
	public void add(final ComponentPrototype node) {
		nodes.add(node);
	}

	@Override
	public ComponentPrototype remove() {
		
		return nodes.pop();
	}
	
	@Override
	public ComponentPrototype getFirst() {		
		return nodes.getFirst();
	}

	@Override
	public int size() {
		return nodes.size();
	}
	
	@Override
	public void print() {
		System.out.println("Print start");
		for (ComponentPrototype cp : nodes)
		{
			cp.toString();			
		}
		System.out.println("Print end");
	}

}
