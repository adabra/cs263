package cs263project.cs263project;

import java.util.regex.Pattern;

public class Utils {

	static Utils utils;
	private Pattern pattern;
	
	private Utils() {
		pattern = Pattern.compile("[^a-zA-Z0-9]");
	}
	
	public static Utils getInstance() {
		if (utils==null){
			utils = new Utils();
		}
		return utils;
	}
	
	public boolean isValidName(String name) {
		 
	        boolean hasSpecialChar = pattern.matcher(name).find();
	        return !hasSpecialChar && name.length()>0;
	}
	
	public boolean isNumeric(String str)
	{
		//match a number with optional '-' and decimal.
		return str.matches("-?\\d+(\\.\\d+)?"); 
	}
	
}
