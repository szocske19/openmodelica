package onlab.openmodelica.own.waitlist;

import java.util.ArrayDeque;
import java.util.Queue;

import openmodelica.MoClass;

public final class FifoWaitlist implements Waitlist {

	private final Queue<MoClass> nodes;

	private FifoWaitlist() {
		nodes = new ArrayDeque<>();
	}

	public static FifoWaitlist create() {
		return new FifoWaitlist();
	}

	@Override
	public void add(final MoClass node) {
		nodes.add(node);
	}

	@Override
	public MoClass remove() {
		return nodes.remove();
	}
	
	@Override
	public MoClass getFirst() {		
		return nodes.element();
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
