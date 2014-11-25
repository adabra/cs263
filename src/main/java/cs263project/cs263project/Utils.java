package cs263project.cs263project;

import java.util.regex.Pattern;

public class Utils {

	static Utils utils;
	private Pattern pattern;
	
	private Utils() {
		pattern = Pattern.compile("[^a-zA-Z0-9]");
	}
	
	static Utils getInstance() {
		if (utils==null){
			utils = new Utils();
		}
		return utils;
	}
	
	boolean isValidName(String name) {
		 
	        boolean hasSpecialChar = pattern.matcher(name).find();
	        return !hasSpecialChar;
	}
	
}
