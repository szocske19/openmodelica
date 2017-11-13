package onlab.modelica.omc;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.modelica.mdt.core.ComponentElement;
import org.modelica.mdt.core.List;
import org.modelica.mdt.core.ModelicaParserException;

public class ComponentAdvancedParser {
	public static List parseList(String str) throws ModelicaParserException {
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

		String regex = "(" + 
					"\\[[^\\]]*\\],|" + 
					"\\([^\\)]*\\),|" + 
					"\\{[^\\}]*\\},?|" + 
					"\"[^\"]*\",|" +
					"[^(\"|\\(|\\{|\\[)][^,]*," 
				+ ")";

		Pattern pattern = Pattern.compile(regex);

		for (int i = 0; i < tokens.length; i++) {
			ComponentElement componentElement = null;
			Matcher matcher = pattern.matcher(tokens[i]);

			int matchCount = 0;
			while (matcher.find())
				matchCount++;
			if (matchCount == 12) {
				String[] atributes = new String[12];
				int j = 0;
				matcher.reset();
				while (matcher.find()) {
					atributes[j] = matcher.group();
					atributes[j] = atributes[j].trim();
					if (atributes[j].endsWith(",")) {
						atributes[j] = atributes[j].substring(0, atributes[j].length() - 1);
					}
					if (atributes[j].startsWith("\"") && atributes[j].endsWith("\"") ){
						atributes[j] = atributes[j].substring(1, atributes[j].length() - 1);
					}
					j++;
				}
				componentElement = new ComponentElement(atributes);
			} else {
				throw new ModelicaParserException("matchCount = " + matchCount + " != 12");
			}
			componentElement.print();
			elements.append(componentElement);

		}
		return elements;
	}
}
