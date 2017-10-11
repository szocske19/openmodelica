package onlab.openmodelica.own.waitlist;

import java.util.ArrayDeque;
import java.util.Queue;

import onlab.openmodelica.own.implementation.of.mdt.TreeNode;

public final class FifoWaitlist implements Waitlist {

	private final Queue<TreeNode> nodes;

	private FifoWaitlist() {
		nodes = new ArrayDeque<>();
	}

	public static FifoWaitlist create() {
		return new FifoWaitlist();
	}

	@Override
	public void add(final TreeNode node) {
		nodes.add(node);
	}

	@Override
	public TreeNode remove() {
		return nodes.remove();
	}
	
	@Override
	public TreeNode getFirst() {		
		return nodes.element();
	}

	@Override
	public int size() {
		return nodes.size();
	}
	
	@Override
	public void print() {
		System.out.println("Print start");
		for (TreeNode treeNode : nodes)
		{
			treeNode.print();			
		}
		System.out.println("Print end");
	}

}
