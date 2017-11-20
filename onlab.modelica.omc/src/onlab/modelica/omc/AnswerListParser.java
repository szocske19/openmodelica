package onlab.modelica.omc;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.modelica.mdt.core.Element;
import org.modelica.mdt.core.List;
import org.modelica.mdt.core.ModelicaParserException;

public class AnswerListParser {
	public static enum ListType {
		LOADED_LIBRARY {
			LoadedLibrary list;
			
			@Override
			Element createElement(String[] atributes) {
				list = new LoadedLibrary(atributes);
				return list;
			}
			
			@Override
			Element getElement() {
				return list;
			}
			
			@Override
			String getRegex() {
				return "\"[^\"]*\",?";
			}
			
			@Override
			int getElementDimension() {
				return 2;
			}
			
			@Override
			void print() {
				list.print();
			}
		},

		COMPONENT_ELEMENT {
			ComponentElement list;
			
			@Override
			Element createElement(String[] atributes) {
				list = new ComponentElement(atributes);
				return list;
			}
			
			@Override
			Element getElement() {
				return list;
			}
			
			@Override
			String getRegex() {
				return "(" + 
						"\\[[^\\]]*\\],|" + 
						"\\([^\\)]*\\),|" + 
						"\\{[^\\}]*\\},?|" + 
      					"\"(\\\\\\\"|[^\\\\\\\"])*\",|" +
						"[^\"\\(\\{\\[][^,]*," 
					+ ")";
			}
			
			@Override
			int getElementDimension() {
				return 12;
			}
			
			@Override
			void print() {
				list.print();
			}
		},
		
		EXTENDS_MODIFIER {
			ExtendsModifier list;
			
			@Override
			Element createElement(String[] atributes) {
				list = new ExtendsModifier(atributes);
				return list;
			}
			
			@Override
			Element getElement() {
				return list;
			}
			
			@Override
			String getRegex() {
				return "\"[^\"]*\",?";
			}
			
			@Override
			int getElementDimension() {
				return 1;
			}
			
			@Override
			void print() {
				list.print();
			}
		};

		
		
		abstract Element createElement(String[] atributes);
		abstract Element getElement();
		abstract String getRegex();
		abstract int getElementDimension();
		abstract void print();
	}
	
	public static List parseList(String str, ListType listType) throws ModelicaParserException {
		List elements = new List();

		/* Remove whitespace before and after */
		str = str.trim();

		/* Make sure this string is not empty */
		if (str.length() < 3) {
			return new List();
			// throw new ModelicaParserException("Empty list: [" + str + "]");
		}

		String dummy = str.substring(2, str.length() - 2);

		String[] tokens = dummy.split("\\},\\{");

		Pattern pattern = Pattern.compile(listType.getRegex());
		
		int elementDimension = listType.getElementDimension();

		for (int i = 0; i < tokens.length; i++) {
			Matcher matcher = pattern.matcher(tokens[i]);

			int matchCount = 0;
			while (matcher.find())
				matchCount++;
			if (matchCount == elementDimension) {
				String[] atributes = new String[elementDimension];
				int j = 0;
				matcher.reset();
				while (matcher.find()) {
					atributes[j] = matcher.group();
					atributes[j] = atributes[j].replace("\\\"", "\"");
					atributes[j] = atributes[j].trim();
					if (atributes[j].endsWith(",")) {
						atributes[j] = atributes[j].substring(0, atributes[j].length() - 1);
					}
					if (atributes[j].startsWith("\"") && atributes[j].endsWith("\"") ){
						atributes[j] = atributes[j].substring(1, atributes[j].length() - 1);
					}
					j++;
				}
				listType.createElement(atributes);
			} else {
				throw new ModelicaParserException("matchCount = " + matchCount + " != " + elementDimension);
			}
			listType.print();
			elements.append(listType.getElement());

		}
		return elements;
	}
}
