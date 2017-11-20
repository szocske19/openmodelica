package onlab.openmodelica.own.waitlist;

import openmodelica.MoClass;;

public interface Waitlist {

	void add(final MoClass node);

	MoClass remove();

	int size();
	
	MoClass getFirst();
		

	default void addAll(final Iterable<? extends MoClass> nodes) {
		nodes.forEach(this::add);
	}

	default boolean isEmpty() {
		return size() == 0;
	}
	
	void print();

}
