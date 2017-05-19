package onlab.openmodelica.own.waitlist;

import java.util.ArrayDeque;
import java.util.Deque;

import onlab.openmodelica.own.implementation.of.mdt.TreeNode;

public final class LifoWaitlist implements Waitlist {

	private final Deque<TreeNode> nodes;

	public LifoWaitlist() {
		nodes = new ArrayDeque<>();
	}

	public static LifoWaitlist create() {
		return new LifoWaitlist();
	}

	@Override
	public void add(final TreeNode node) {
		nodes.add(node);
	}

	@Override
	public TreeNode remove() {
		
		return nodes.pop();
	}
	
	@Override
	public TreeNode getFirst() {		
		return nodes.getFirst();
	}

	@Override
	public int size() {
		return nodes.size();
	}

}
