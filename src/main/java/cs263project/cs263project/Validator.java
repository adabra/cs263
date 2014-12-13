package cs263project.cs263project;

import java.util.regex.Pattern;

public class Validator {

	
	public static boolean isValidName(String name) {
		 	Pattern pattern = Pattern.compile("[^a-zA-Z0-9]");
	        boolean hasSpecialChar = pattern.matcher(name).find();
	        return !hasSpecialChar && name.length()>0;
	}
	
	public static boolean isValidCityName(String name) {
		 
        return name.length()>0;
}
	
	public static boolean isNumeric(String str)
	{
		//match a number with optional '-' and decimal.
		return str.matches("-?\\d+(\\.\\d+)?"); 
	}
	
	public static boolean isValidLatitude(float lat) {
		return lat<=90 && lat>=-90;
	}
	
	public static boolean isValidLongitude(float lon) {
		return lon<=180 && lon>=-180;
	}
	
}
