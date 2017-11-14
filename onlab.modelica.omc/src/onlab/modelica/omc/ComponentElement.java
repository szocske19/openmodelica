package onlab.modelica.omc;

import org.modelica.mdt.core.Element;

public class ComponentElement extends Element {
	
	private String className;
	private String name;
	private String comment;
	private Boolean isProtected;
	private Boolean isFinal;
	private Boolean isFlow;
	private Boolean isStream;
	private Boolean isReplaceable;
	private String variability; //"'constant', 'parameter', 'discrete', ''";
	private String innerOuter; // "'inner', 'outer', ''";
	private String inputOutput; //"'input', 'output', ''";
	private String dimensions;
	
	public ComponentElement(String str) {
		super(str);
	}
	
	public ComponentElement(String[] atributes) {
		super(atributes[0]);
		className =  atributes[0];
		name =  atributes[1];
		comment =  atributes[2];
		isProtected = atributes[3] == "public";
		isFinal =  atributes[4] == "true";
		isFlow =  atributes[5] == "true";
		isStream =  atributes[6] == "true";
		isReplaceable =  atributes[7] == "true";
		variability =  atributes[8];
		innerOuter =  atributes[9];
		inputOutput =  atributes[10];
		dimensions =  atributes[11];		
	}
	

	public String getClassName() {
		return className;
	}

	public String getName() {
		return name;
	}

	public String getComment() {
		return comment;
	}

	public Boolean getIsProtected() {
		return isProtected;
	}

	public Boolean getIsFinal() {
		return isFinal;
	}

	public Boolean getIsFlow() {
		return isFlow;
	}

	public Boolean getIsStream() {
		return isStream;
	}

	public Boolean getIsReplaceable() {
		return isReplaceable;
	}

	public String getVariability() {
		return variability;
	}

	public String getInnerOuter() {
		return innerOuter;
	}

	public String getInputOutput() {
		return inputOutput;
	}

	public String getDimensions() {
		return dimensions;
	}
	
	public void print(){
		System.out.println(toString());
	}
	
	@Override
	public String toString(){
		String tab = "		";
		String returnString = "";
		returnString += tab + "className: " + className + "\n";
		returnString += tab + "name: " + name + "\n";
		returnString += tab + "comment: " + comment + "\n";
		returnString += tab + "isProtected: " + isProtected + "\n";
		returnString += tab + "isFinal: " + isFinal + "\n";
		returnString += tab + "isFlow: " + isFlow + "\n";
		returnString += tab + "isStream: " + isStream + "\n";
		returnString += tab + "isReplaceable: " + isReplaceable + "\n";
		returnString += tab + "variability: " + variability + "\n";
		returnString += tab + "innerOuter: " + innerOuter + "\n";
		returnString += tab + "inputOutput: " + inputOutput + "\n";
		returnString += tab + "dimensions: " + dimensions + "\n";
		
		return returnString;
	}

}
