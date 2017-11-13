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
	
	def createEMFModel(ComponentPrototype rootComponent, Map<String, ComponentPrototype> metaClassMap) {
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
			val componentPrototype = metaClassMap.get(key)
			if(!key.equals(rootComponent.name)){				
				dependency.componentprototype.add(componentPrototype)				
			} else {
				rootPackage.componentprototype.add(componentPrototype)	
			}
		}

		return rootPackage
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
			case OpenmodelicaPackage.BOOLEAN: modelicaFactory.createBoolean()
			case OpenmodelicaPackage.INTEGER: modelicaFactory.createInteger()
			case OpenmodelicaPackage.REAL: modelicaFactory.createReal()
			case OpenmodelicaPackage.STRING: modelicaFactory.createString()
			case OpenmodelicaPackage.ENUMERATION: modelicaFactory.createEnumeration()
			
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
	
//	def setInheritedVariables(ComponentPrototype cp){
//		for(ext: cp.getExtension){
//			ext
//		}
//	}
	
	
}