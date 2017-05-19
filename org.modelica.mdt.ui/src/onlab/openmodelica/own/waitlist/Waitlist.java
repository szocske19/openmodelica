package onlab.openmodelica.own.waitlist;

import onlab.openmodelica.own.implementation.of.mdt.TreeNode;

public interface Waitlist {

	void add(final TreeNode node);

	TreeNode remove();

	int size();
	
	TreeNode getFirst();
		

	default void addAll(final Iterable<? extends TreeNode> nodes) {
		nodes.forEach(this::add);
	}

	default boolean isEmpty() {
		return size() == 0;
	}

}
