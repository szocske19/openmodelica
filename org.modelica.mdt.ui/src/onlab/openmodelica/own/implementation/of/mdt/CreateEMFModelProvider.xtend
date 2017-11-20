package onlab.openmodelica.own.implementation.of.mdt

import java.util.ArrayList
import java.util.Collections
import java.util.Map
import openmodelica.InnerOuter
import openmodelica.InputOutput
import openmodelica.MoClass
import openmodelica.MoPackage
import openmodelica.OpenmodelicaFactory
import openmodelica.OpenmodelicaPackage
import openmodelica.Variability
import openmodelica.impl.BooleanImpl
import openmodelica.impl.EnumerationImpl
import openmodelica.impl.IntegerImpl
import openmodelica.impl.RealImpl
import openmodelica.impl.StringImpl
import org.eclipse.emf.common.util.Enumerator
import org.modelica.mdt.core.compiler.IModelicaCompiler

class CreateEMFModelProvider {

	private extension OpenmodelicaFactory modelicaFactory = OpenmodelicaFactory.eINSTANCE
	private static IModelicaCompiler currentCompiler;

	new(IModelicaCompiler _currentCompiler) {
		currentCompiler = _currentCompiler;
	}

	def createEMFModel(MoClass rootComponent, Map<String, LevelNode> metaClassMap) {
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
			while (listOflevelList.size <= level) {
				listOflevelList.add(new ArrayList<String>)
			}
			listOflevelList.get(level).add(key)
		}
		Collections.reverse(listOflevelList)

		println("\nOrdered order")
		for (var i = 0; i < listOflevelList.size; i++) {
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
			if (!key.equals(rootComponent.name)) {
				root.dependencies.add(componentPrototype)
			} else {
				root.mainClass = componentPrototype
			}
		}

		return root
	}

	def MoClass createMoClass(int prototypeType) {
		switch prototypeType {
			case OpenmodelicaPackage.MO_BLOCK:
				modelicaFactory.createMoBlock()
			case OpenmodelicaPackage.MO_CLASS:
				modelicaFactory.createMoClass()
			case OpenmodelicaPackage.MO_CONNECTOR:
				modelicaFactory.createMoConnector()
			case OpenmodelicaPackage.MO_EXPANDABLE_CONNECTOR:
				modelicaFactory.createMoExpandableConnector()
			case OpenmodelicaPackage.MO_FUNCTION:
				modelicaFactory.createMoFunction()
			case OpenmodelicaPackage.MO_MODEL:
				modelicaFactory.createMoModel()
			case OpenmodelicaPackage.MO_OPERATOR:
				modelicaFactory.createMoOperator()
			case OpenmodelicaPackage.MO_OPERATOR_FUNCTION:
				modelicaFactory.createMoOperatorFunction()
			case OpenmodelicaPackage.MO_OPERATOR_RECORD:
				modelicaFactory.createMoOperatorRecord()
			case OpenmodelicaPackage.MO_PACKAGE:
				modelicaFactory.createMoPackage()
			case OpenmodelicaPackage.MO_RECORD:
				modelicaFactory.createMoRecord()
				
				
				
			case OpenmodelicaPackage.BOOLEAN:
				modelicaFactory.createBoolean()
			case OpenmodelicaPackage.ENUMERATION:
				modelicaFactory.createEnumeration()
			case OpenmodelicaPackage.INTEGER:
				modelicaFactory.createInteger()
			case OpenmodelicaPackage.REAL:
				modelicaFactory.createReal()
			case OpenmodelicaPackage.STRING:
				modelicaFactory.createString()
			default:
				throw new IllegalArgumentException("The type '" + prototypeType + "' is not a valid classifier")
		}
	}

	def setChildren(MoClass cp, ArrayList<ComponentReference> comRefList) {
		for (child : comRefList) {
			val componentInstance = createComponentInstance() =>
				[ instace |
					instace.is_a = child.component
					instace.name = child.properites.name
					instace.comment = child.properites.comment
					instace.isProtected = child.properites.isProtected
					instace.isFinal = child.properites.isFinal
					instace.isStream = child.properites.isStream
					instace.isReplaceable = child.properites.isReplaceable
					instace.dimensions = child.properites.dimensions

					val innerOuterEnum = EnumChecker(InnerOuter.get(child.properites.innerOuter), "InnerOuter",
						child.properites.innerOuter)
					val variabilityEnum = EnumChecker(Variability.get(child.properites.variability), "Variability",
						child.properites.variability)
					val inputOutputEnum = EnumChecker(InputOutput.get(child.properites.inputOutput), "InputOutput",
						child.properites.inputOutput)

					instace.innerOuter = innerOuterEnum as InnerOuter
					instace.variability = variabilityEnum as Variability
					instace.inputOutput = inputOutputEnum as InputOutput

				]
			cp.children.add(componentInstance)
		}
	}

	def Enumerator EnumChecker(Enumerator enumerator, String enumType, String element) {
		if (enumerator === null) {
			throw new IllegalArgumentException("The '" + element + "' is not a valid " + enumType)
		} else {
			enumerator
		}
	}

	def setExtension(MoClass cp, ArrayList<ExtensionReference> extRefList) {
		for (superClass : extRefList) {
			val modelicaExtension = createExtension() => [ modelicaExtension |
				modelicaExtension.superClass = superClass.superClass
			]
			cp.extension.add(modelicaExtension)
		}
	}

	def addClass(MoPackage modelicaPackage, ArrayList<MoClass> cpList) {
		if (modelicaPackage instanceof Package) {
			for (subcp : cpList) {
				modelicaPackage.packagedClass.add(subcp)
			}
		}
	}

	def inflate(MoClass cp) {
		cp.setInitValue
		cp.setInheritedVariables
	}

	def setInitValue(MoClass cp) {
		for (instance : cp.children) {
			if (instance.variability == Variability.PARAMETER || instance.variability == Variability.CONSTANT) {
				val value = currentCompiler.getParameterValue(cp.name, instance.name).getFirstResult().replace("\"","").trim();
				val valueElement = getValueElement(getTypeOfComponent(instance.is_a))
				valueElement.valueInString = value
			}
		}
	}

	def getValueElement(int type) {
		switch type {
			case OpenmodelicaPackage.BOOLEAN:
				modelicaFactory.createBooleanValue
			case OpenmodelicaPackage.ENUMERATION:
				modelicaFactory.createEnumerationValue
			case OpenmodelicaPackage.INTEGER:
				modelicaFactory.createIntegerValue
			case OpenmodelicaPackage.REAL:
				modelicaFactory.createRealValue
			case OpenmodelicaPackage.STRING:
				modelicaFactory.createStringValue
			default:
				throw new IllegalArgumentException("The type '" + type + "' is not a valid value classifier")
		}
	}
	
	def int getTypeOfComponent(MoClass cp) {
		if (cp instanceof RealImpl) {
			OpenmodelicaPackage.REAL
		} else if (cp instanceof IntegerImpl) {
			OpenmodelicaPackage.INTEGER
		} else if (cp instanceof BooleanImpl) {
			OpenmodelicaPackage.BOOLEAN
		} else if (cp instanceof StringImpl) {
			OpenmodelicaPackage.STRING
		} else if (cp instanceof EnumerationImpl) {
			OpenmodelicaPackage.ENUMERATION
		} else {
			throw new IllegalArgumentException("The class '" + cp.name + "' must be primitive class.")
		}
	}
	
	def setInheritedVariables(MoClass cp){
		for(ext: cp.getExtension){			
			val modifierNames = currentCompiler.getExtendsModifierNames(cp.name, ext.superClass.name)
//			for(modifierNames)
		}
	}

}
