package cs263project.cs263project;


/**
 * This simple class holds data representing a message to
 * be sent to a chat room from a ChannelServlet.
 *
 */
public class Message {

	/**
	 * The type of the message.
	 */
	String type;
	
	/**
	 * The name of the user sending the message.
	 */
	String username;
	
	/**
	 * The content of the message.
	 */
	String content;
	
	/**
	 * The time the message was received.
	 */
	String time;
	
	public Message(String type, String username, String content, String time) {
		this.type = type;
		this.username = username;
		this.content = content;
		this.time = time;
	}
	
}
