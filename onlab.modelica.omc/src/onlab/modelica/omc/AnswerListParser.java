package onlab.modelica.omc;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.log4j.Logger;
import org.modelica.mdt.core.Element;
import org.modelica.mdt.core.List;
import org.modelica.mdt.core.ModelicaParserException;

public class AnswerListParser {

	private static Logger log = Logger.getRootLogger();

	public static enum ListType {
		LOADED_LIBRARY(2, 
				"\"[^\"]*\",?") {

			@Override
			void createElement(String[] atributes) {
				list = new LoadedLibrary(atributes);
			}
		},

		COMPONENT_ELEMENT(12, "(" 
				+ "\\[[^\\]]*\\],|"
				+ "\\([^\\)]*\\),|" 
				+ "\\{[^\\}]*\\},?|"
				+ "\"(\\\\\\\"|[^\\\\\\\"])*\",|"
				+ "[^\"\\(\\{\\[][^,]*,"
				+ ")") {

			@Override
			void createElement(String[] atributes) {
				list = new ComponentElement(atributes);
			}
		},

		EXTENDS_MODIFIER(1, 
				"\"[^\"]*\",?") {

			@Override
			void createElement(String[] atributes) {
				list = new ExtendsModifier(atributes);
			}
		};

		Element list;
		int elementDimension;
		String regex;

		ListType(int elementDimension, String regex) {
			this.elementDimension = elementDimension;
			this.regex = regex;
		}

		abstract void createElement(String[] atributes);

		void print() {
			log.debug(list.toString());
		}
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

		Pattern pattern = Pattern.compile(listType.regex);

		int elementDimension = listType.elementDimension;

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
					if (atributes[j].startsWith("\"") && atributes[j].endsWith("\"")) {
						atributes[j] = atributes[j].substring(1, atributes[j].length() - 1);
					}
					j++;
				}
				listType.createElement(atributes);
			} else {
				throw new ModelicaParserException("matchCount = " + matchCount + " != " + elementDimension);
			}
			listType.print();
			elements.append(listType.list);

		}
		return elements;
	}
}
