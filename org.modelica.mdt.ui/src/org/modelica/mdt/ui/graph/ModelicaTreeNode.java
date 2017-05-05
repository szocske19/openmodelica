
package org.modelica.mdt.ui.graph;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ModelicaTreeNode {

	private List<ModelicaTreeNode> children;
	private ModelicaTreeNode parentNode;
	private ModelicaNode modelicaNode;
	private static Map<ModelicaNode,ModelicaTreeNode> map = new HashMap<ModelicaNode, ModelicaTreeNode>();

	public ModelicaTreeNode(ModelicaTreeNode parent, ModelicaNode modelicaNode) {
		this.parentNode = parent;
		this.modelicaNode = modelicaNode;
		map.put(modelicaNode, this);
	}
	
	public void addNewNode(ModelicaTreeNode child) {
		children.add(child);
	}
	
	public ModelicaTreeNode getParentNode() {
		return parentNode;
	}
	
	public ModelicaTreeNode getNthChild(int n) {
		return children.get(n);
	}
	
	public List<ModelicaTreeNode> getChildren() {
		return children;
	}

}
