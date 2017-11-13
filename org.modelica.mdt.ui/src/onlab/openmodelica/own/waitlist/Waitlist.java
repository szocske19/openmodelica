package onlab.openmodelica.own.waitlist;

import openmodelica.ComponentPrototype;

public interface Waitlist {

	void add(final ComponentPrototype node);

	ComponentPrototype remove();

	int size();
	
	ComponentPrototype getFirst();
		

	default void addAll(final Iterable<? extends ComponentPrototype> nodes) {
		nodes.forEach(this::add);
	}

	default boolean isEmpty() {
		return size() == 0;
	}
	
	void print();

}
