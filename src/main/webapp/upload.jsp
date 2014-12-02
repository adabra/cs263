<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
    <%@ page
	import="com.google.appengine.api.blobstore.BlobstoreServiceFactory"%>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreService"%>

<%
	BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<script src='//code.jquery.com/jquery-1.11.1.min.js'></script>
<script src="http://malsup.github.com/jquery.form.js"></script> 
<title>Insert title here</title>
</head>
<body>

	<form id="upload_file" action="<%=blobstoreService.createUploadUrl("/gallery/1")%>" enctype="multipart/form-data" method="post">
        <input type="file" name="file">
        <input type="button" name="submit" value="Submit">
	</form>
	
	<script type="text/javascript">
		$('#upload_file').submit(function() { 
		    var options = { 
		        clearForm: true        // clear all form fields after successful submit 
		    }; 
		    $(this).ajaxSubmit(options);
		    return false; 
		});
		
		$('[name=submit]').click(function(){
		    $('#upload_file').submit();        
		});
	</script>
</body>
</html>