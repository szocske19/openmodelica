package onlab.openmodelica.own.implementation.of.mdt

import java.util.ArrayList
import java.util.Collections
import java.util.Map
import openmodelica.OpenmodelicaFactory
import openmodelica.ComponentPrototype
import openmodelica.OpenmodelicaPackage

class CreateEMFModelProvider {
	
	private extension OpenmodelicaFactory modelicaFactory = OpenmodelicaFactory.eINSTANCE
	
	def createEMFModel(TreeNode rootTreeNode, Map<String, TreeNode> metaClassMap) {
		val rootPackage = createPackage() => [ package |
			package.name = "Root"
		]

		val dependency = createPackage() => [ package |
			package.name = "dependency"
		]	
			
		rootPackage.componentprototype.add(dependency)
		
		val orderedKeys = new ArrayList<String>(metaClassMap.keySet())		
		Collections.reverse(orderedKeys)
		
		for (String key : orderedKeys) {
			val treeNode = metaClassMap.get(key)
			populateComponentPrototype(treeNode)
			if(!key.equals(rootTreeNode.name)){				
				dependency.componentprototype.add(treeNode.getOrCreateComponent)				
			} else {
				rootPackage.componentprototype.add(treeNode.getOrCreateComponent)	
			}
		}

		return rootPackage
	}
	
	def populateComponentPrototype(TreeNode treeNode){		
		for (child : treeNode.children) {
			val componentInstance = createComponentInstance() => [ instace |
				instace.is_a = child.treeNode.getOrCreateComponent
				instace.name = child.component.name
			]			
			treeNode.getOrCreateComponent.children.add(componentInstance)
		}		
	}
	
	def getOrCreateComponent(TreeNode treeNode){
		if(treeNode.componentPrototype === null){			
			try {
				treeNode.setComponentPrototype(createComponentPrototype(treeNode.prototypeType))
			} catch (IllegalArgumentException e){
				treeNode.setComponentPrototype(modelicaFactory.createClass())
				System.out.println(e.toString());				
			}
			setComponentProperties(treeNode)
		}
		treeNode.componentPrototype
	}
	
	def ComponentPrototype createComponentPrototype(int prototypeType){
		switch prototypeType {
			case OpenmodelicaPackage.CLASS: modelicaFactory.createClass()
			case OpenmodelicaPackage.PACKAGE: modelicaFactory.createPackage()
			case OpenmodelicaPackage.EXTERNAL_OBJECT: modelicaFactory.createExternalObject()
			case OpenmodelicaPackage.MODEL: modelicaFactory.createModel()
			case OpenmodelicaPackage.BLOCK: modelicaFactory.createBlock()
			case OpenmodelicaPackage.CONNECTOR: modelicaFactory.createConnector()
			case OpenmodelicaPackage.FUNCTION: modelicaFactory.createFunction()
			case OpenmodelicaPackage.RECORD: modelicaFactory.createRecord()
			case OpenmodelicaPackage.TYPE: modelicaFactory.createType()
			default:
				throw new IllegalArgumentException("The type '" + prototypeType
						+ "' is not a valid classifier")
		}
	}
	
	def setComponentProperties(TreeNode treeNode){
		treeNode.componentPrototype.name = treeNode.name
	}
}