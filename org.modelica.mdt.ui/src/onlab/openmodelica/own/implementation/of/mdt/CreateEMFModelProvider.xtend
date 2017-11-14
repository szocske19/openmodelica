package onlab.openmodelica.own.implementation.of.mdt

import java.util.ArrayList
import java.util.Collections
import java.util.Map
import openmodelica.ComponentPrototype
import openmodelica.InnerOuter
import openmodelica.InputOutput
import openmodelica.OpenmodelicaFactory
import openmodelica.OpenmodelicaPackage
import openmodelica.Variability
import org.eclipse.emf.common.util.Enumerator

class CreateEMFModelProvider {
	
	private extension OpenmodelicaFactory modelicaFactory = OpenmodelicaFactory.eINSTANCE
	
	def createEMFModel(ComponentPrototype rootComponent, Map<String, LevelNode> metaClassMap) {
		val root = createRoot() => [ root |
			root.name = "Root"
		]
		
		val keys = new ArrayList<String>(metaClassMap.keySet())	
		val listOflevelList = new ArrayList<ArrayList<String>>
		val orderedKeys = new ArrayList<String>	
		
		
		println("\nOriginal order:")
		for (key : keys) {
			println(key)
			val level = metaClassMap.get(key).level
			while(listOflevelList.size <= level){
				listOflevelList.add(new ArrayList<String>)				
			}
			listOflevelList.get(level).add(key)
		}
		Collections.reverse(listOflevelList)		
				
			
		println("\nOrdered order")
		for(var i = 0 ; i < listOflevelList.size ; i++){	
			println("Level:" + i)			
			for (key : listOflevelList.get(i)) {
				println(key)
				orderedKeys.add(key)
			}			
		}		
		
		println("\nAdding dependencies:")
		for (String key : orderedKeys) {
			println(key)
			val componentPrototype = metaClassMap.get(key).cp
			if(!key.equals(rootComponent.name)){				
				root.dependencies.add(componentPrototype)				
			} else {
				root.mainClass = componentPrototype	
			}
		}

		return root
	}
	
	def ComponentPrototype createComponentPrototype(int prototypeType){
		switch prototypeType {
			case OpenmodelicaPackage.BLOCK: modelicaFactory.createBlock()
			case OpenmodelicaPackage.CLASS: modelicaFactory.createClass()
			case OpenmodelicaPackage.CONNECTOR: modelicaFactory.createConnector()
			case OpenmodelicaPackage.EXTERNAL_OBJECT: modelicaFactory.createExternalObject()
			case OpenmodelicaPackage.FUNCTION: modelicaFactory.createFunction()
			case OpenmodelicaPackage.MODEL: modelicaFactory.createModel()
			case OpenmodelicaPackage.PACKAGE: modelicaFactory.createPackage()
			case OpenmodelicaPackage.RECORD: modelicaFactory.createRecord()
			
			case OpenmodelicaPackage.BOOLEAN: modelicaFactory.createBoolean()
			case OpenmodelicaPackage.ENUMERATION: modelicaFactory.createEnumeration()
			case OpenmodelicaPackage.INTEGER: modelicaFactory.createInteger()
			case OpenmodelicaPackage.REAL: modelicaFactory.createReal()
			case OpenmodelicaPackage.STRING: modelicaFactory.createString()
			
//			case OpenmodelicaPackage.TYPE: modelicaFactory.createType()
			default:
				throw new IllegalArgumentException("The type '" + prototypeType
						+ "' is not a valid classifier")
		}
	}
	
	def setChildren(ComponentPrototype cp, ArrayList<ComponentReference> comRefList){
		for (child : comRefList) {
			val componentInstance = createComponentInstance() => [ instace |
				instace.is_a = child.component
				instace.name = child.properites.name
				instace.comment = child.properites.comment
				instace.isProtected = child.properites.isProtected
				instace.isFinal = child.properites.isFinal
				instace.isStream = child.properites.isStream
				instace.isReplaceable = child.properites.isReplaceable
				instace.dimensions = child.properites.dimensions
				
				val innerOuterEnum = EnumChecker(InnerOuter.get(child.properites.innerOuter), "InnerOuter", child.properites.innerOuter)
				val variabilityEnum = EnumChecker(Variability.get(child.properites.variability), "Variability", child.properites.variability)
				val inputOutputEnum = EnumChecker(InputOutput.get(child.properites.inputOutput), "InputOutput", child.properites.inputOutput)
				
				
				instace.innerOuter = innerOuterEnum as InnerOuter
				instace.variability = variabilityEnum as Variability
				instace.inputOutput = inputOutputEnum as InputOutput
				
			]			
			cp.children.add(componentInstance)
		}
	}
	
	def Enumerator EnumChecker(Enumerator enumerator, String enumType, String element) {		
		if(enumerator === null){
			throw new IllegalArgumentException("The '" + element	+ "' is not a valid " + enumType)			
		} else {
			enumerator
		}
	}
	
	def setExtension(ComponentPrototype cp, ArrayList<ExtensionReference> extRefList){
		for (superClass : extRefList) {
			val modelicaExtension = createExtension() => [ modelicaExtension |
				modelicaExtension.superClass = superClass.superClass
			]			
			cp.extension.add(modelicaExtension)
		}
	}
	
	def addClass(ComponentPrototype modelicaPackage, ArrayList<ComponentPrototype> cpList){
		if(modelicaPackage instanceof openmodelica.Package ){
			for (subcp : cpList) {						
				modelicaPackage.componentprototype.add(subcp)
			}		
		}
	}
	
//	def setInheritedVariables(ComponentPrototype cp){
//		for(ext: cp.getExtension){
//			ext
//		}
//	}
	
	
}