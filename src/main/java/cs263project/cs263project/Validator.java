package cs263project.cs263project;

import java.util.regex.Pattern;

public class Validator {

	private static final Pattern cityPattern =  Pattern.compile(
	        "^[a-z]([a-z\\d\\.\\- ]{0,18}[a-z\\d])?$", Pattern.CASE_INSENSITIVE);
	private static final Pattern namePattern = Pattern.compile("[^a-zA-Z0-9]");
	public static boolean isValidName(String name) {
	        boolean hasSpecialChar = namePattern.matcher(name).find();
	        return !hasSpecialChar && name.length()>0;
	}
	
	public static boolean isValidCityName(String name) {
		boolean hasNoSpecialChar = cityPattern.matcher(name).find();
        return hasNoSpecialChar && name.length()>0;
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
