package cs263project.cs263project;

import java.util.ArrayList;
import java.util.Calendar;

import com.google.gson.Gson;

public class Test {

	
	public static void main(String[] args) {
		Gson gson = new Gson();
		String roomname = "Room1";
		String username = "hotgrl18";
		String content = "tazt priv?";
		String time = ""+Calendar.getInstance().get(Calendar.HOUR_OF_DAY) + ":" +  Calendar.getInstance().get(Calendar.MINUTE);
		Message msg = new Message("CHAT_MESSAGE", username, content, time);
		System.out.println(gson.toJson(msg));

		System.out.println(Utils.getInstance().isValidCityName("."));
	}
	
}
