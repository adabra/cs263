<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ page
	import="com.google.appengine.api.blobstore.BlobstoreServiceFactory"%>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreService"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
	<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
	 <link href="http://maxcdn.bootstrapcdn.com/bootswatch/3.3.0/slate/bootstrap.min.css" rel="stylesheet">
      <script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
      <link rel="stylesheet" type="text/css" href="/stylesheets/main.css">

</head>
<%
	BlobstoreService blobstoreService = BlobstoreServiceFactory
			.getBlobstoreService();
%>

<body>


	<div class="col-lg-6 col-lg-offset-3">
		<div class="bs-component">
			<div class="well well-lg" style="height: 20vh;">
				Look, I'm in a large well!
			</div>
		</div>
	</div>

	<div class="col-lg-6 col-lg-offset-3">
		<div class="bs-component">
			<div class="well well-lg" style="height: 60vh">
			Look, I'm in a large well!
			</div>
		</div>
	</div>

	<div class='col-lg-6 col-lg-offset-3'>
		<div class="well bs-component" style="height: 20vh">
			<form class="form-horizontal"
				action="<%=blobstoreService.createUploadUrl("/upload")%>"
				method="post" enctype="multipart/form-data">
				<fieldset>
					<legend>Upload to gallery</legend>
					<div class="form-group">
						<label for="inputTitle" class="col-lg-2 control-label">Title</label>
						<div class="col-lg-10">
							<input type="text" class="form-control" id="inputTitle"
								placeholder="Title">
						</div>
					</div>
					<div class="form-group">
						<label for="inputFile" class="col-lg-2 control-label">File</label>
						<div class="col-lg-10">
							<input type="file" id="inputFile" placeholder="File"
								style="color: white">
						</div>
						<div class="form-group">
							<div class="col-lg-10 col-lg-offset-10">
        						<button type="submit" class="btn btn-primary">Submit</button>
      						</div>
      					</div>
   				 	</div>
  				</fieldset>
			</form>
		</div>
	</div>

</body>
</html>