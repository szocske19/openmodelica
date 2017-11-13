package onlab.openmodelica.own.waitlist;

import java.util.ArrayDeque;
import java.util.Queue;

import openmodelica.ComponentPrototype;

public final class FifoWaitlist implements Waitlist {

	private final Queue<ComponentPrototype> nodes;

	private FifoWaitlist() {
		nodes = new ArrayDeque<>();
	}

	public static FifoWaitlist create() {
		return new FifoWaitlist();
	}

	@Override
	public void add(final ComponentPrototype node) {
		nodes.add(node);
	}

	@Override
	public ComponentPrototype remove() {
		return nodes.remove();
	}
	
	@Override
	public ComponentPrototype getFirst() {		
		return nodes.element();
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
