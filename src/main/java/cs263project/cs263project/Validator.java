package cs263project.cs263project;

import java.util.regex.Pattern;

/**
 * This class contains various static helper methods for 
 * doing different kinds of validations. 
 *
 */
public class Validator {

	private static final Pattern cityPattern =  Pattern.compile(
	        "^[a-z]([a-z\\d\\.\\- ]{0,18}[a-z\\d])?$", Pattern.CASE_INSENSITIVE);
	private static final Pattern namePattern = Pattern.compile("[^a-zA-Z0-9]");
	
	/**
	 * Validates user and room names, allowing only names with letters 
	 * and numbers. Must contain at least 1 character.
	 * @param name The user or room name to be validated.
	 * @return True if the name is valid, false otherwise.
	 */
	public static boolean isValidName(String name) {
	        boolean hasSpecialChar = namePattern.matcher(name).find();
	        return !hasSpecialChar && name.length()>0;
	}
	
	/**
	 * Validates city names, allowing only names starting with a letter,
	 * followed by characters, letters, numbers, dots, dashes and spaces,
	 * and ending with a letter. (Hopefully this fits all the cases of
	 * Google's X-Appengine-City header.)
	 * Maximum size is 20 characters, must contain at least 1 character.
	 * @param name The city name to be validated.
	 * @return True if the name is valid, false otherwise.
	 */
	public static boolean isValidCityName(String name) {
		boolean hasNoSpecialChar = cityPattern.matcher(name).find();
        return hasNoSpecialChar && name.length()>0;
}
	/**
	 * Validates a string supposed to represent a number.
	 * @param str The number to be validated.
	 * @return True if the string is a valid numeric, false otherwise.
	 */
	public static boolean isNumeric(String str)
	{
		//match a number with optional '-' and decimal.
		return str.matches("-?\\d+(\\.\\d+)?"); 
	}
	
	/**
	 * Validates a number supposed to represent a latitude.
	 * @param lat The number to be validated.
	 * @return True if the number is a valid latitude, false otherwise.
	 */
	public static boolean isValidLatitude(float lat) {
		return lat<=90 && lat>=-90;
	}
	
	/**
	 * Validates a number supposed to represent a longitude.
	 * @param lon The number to be validated.
	 * @return True if the number is a valid longitude, false otherwise.
	 */
	public static boolean isValidLongitude(float lon) {
		return lon<=180 && lon>=-180;
	}
	
}
