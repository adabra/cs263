package cs263project.cs263project;

import java.io.IOException;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Query;

public class Upload extends HttpServlet {
    private BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();

    @Override
    public void doPost(HttpServletRequest req, HttpServletResponse res)
        throws ServletException, IOException {

    	String roomname = req.getPathInfo().substring(1);
    	roomname = roomname.split("/")[0];
    	String username = (String)req.getSession().getAttribute(roomname);
		
    	//Check if user is in room
    	if (username == null) {
    		res.sendRedirect("/");
    		return;
    	}
    	
    	
    	
        Map<String, BlobKey> blobs = blobstoreService.getUploadedBlobs(req);
        BlobKey blobKey = blobs.get("image");

        if (blobKey == null) {
            res.sendRedirect("/blobs.jsp");
        } else {
        	DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
        	Key roomKey = KeyFactory.createKey("Room", roomname);
        	Entity image = new Entity("Image", roomKey);
			image.setProperty("user", username);
			image.setProperty("Blobkey", blobKey.getKeyString());
			datastore.put(image);
			
			res.sendRedirect("/gallery/"+roomname);
//            res.sendRedirect("/serve?blob-key=" + blobKey.getKeyString());
        }
    }
}


