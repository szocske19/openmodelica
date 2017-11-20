package onlab.modelica.omc;

import org.modelica.mdt.core.Element;

public class ExtendsModifier extends Element {
	
	private String variableName;
	
	public String getLibraryName() {
		return variableName;
	}
	
	public ExtendsModifier(String[] atributes) {
		super(atributes[0]);
		variableName =  atributes[0];
	}
	
	public void print(){
		System.out.println(toString());
	}
	
	@Override
	public String toString(){
		String tab = "		";
		String returnString = "";
		returnString += tab + "variableName: " + variableName + "\n";
		
		return returnString;
	}

}
