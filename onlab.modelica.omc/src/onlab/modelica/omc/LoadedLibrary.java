package onlab.modelica.omc;

import org.modelica.mdt.core.Element;

public class LoadedLibrary extends Element {
	
	private String libraryName;
	private String source;
	
	public String getLibraryName() {
		return libraryName;
	}
	
	public LoadedLibrary(String[] atributes) {
		super(atributes[0]);
		libraryName =  atributes[0];
		source =  atributes[1];		
	}
	
	public void print(){
		System.out.println(toString());
	}
	
	@Override
	public String toString(){
		String tab = "		";
		String returnString = "";
		returnString += tab + "libraryName: " + libraryName + "\n";
		returnString += tab + "source: " + source + "\n";
		
		return returnString;
	}

}
