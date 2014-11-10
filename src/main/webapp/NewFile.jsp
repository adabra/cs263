<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
<link href="//maxcdn.bootstrapcdn.com/bootswatch/3.2.0/cyborg/bootstrap.min.css" rel="stylesheet">
<link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
<script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.0/js/bootstrap.min.js"></script>
</head>
<body>

	<input type='text' id='username' value ='' /><br>
	<textarea rows='4' cols='50' id='chatbox' style='color: white; background-color: darkgrey' readonly></textarea> 
	<br>
	<input type='text' id='userInput' value='' />
	<input type='button' onclick='updatetext()' value='send'/>
	
	<script type='text/javascript'>
		function updatetext(){
			var userInput = document.getElementById('userInput').value;
			var date = new Date();
		
			var textarea = document.getElementById('chatbox');
		
			textarea.innerHTML += '\n'
				+'['+date.getHours()+':'+date.getMinutes()+']['
				+document.getElementById('username').value+']: '
				+userInput;
		
			textarea.scrollTop = textarea.scrollHeight;
		}
	
	</script>

</body>
</html>