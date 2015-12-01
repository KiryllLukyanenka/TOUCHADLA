@isTest
global class MockDnBHttpResponse implements HttpCalloutMock 
{    
    global HTTPResponse respond(HTTPRequest req) 
    {        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Authorization', 'authorization');
        res.setBody('{"mockHttpResponse":"response"}');
        res.setStatusCode(200);
        return res; 
    }
}