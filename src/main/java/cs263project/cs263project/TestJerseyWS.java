package cs263project.cs263project;

import javax.ws.rs.GET;
import javax.ws.rs.Path;

@Path("/jerseyws")
public class TestJerseyWS {

    @GET
    @Path("/test")
    public String testMethod() {
        return "this is a test yeah well";
    }
}
