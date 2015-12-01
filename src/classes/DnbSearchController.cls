public with sharing class DnbSearchController
{
    private final String USERNAME = 'P100000ED057F6007F64CD19041DB25A';
    private final String PASSWORD = 'AD3zero3_Summer2014';
    private String key;
    public DnbSearchController()
    {
        Map<String, String> params = ApexPages.currentPage().getParameters();        
        if(params.containsKey('term'))
        {
            key = params.get('term');
        }
    }
    public String SearchResult
    {
        get
        {
            if(String.isBlank(key))
            {
                return null;
            }
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint('https://maxcvservices.dnb.com/rest/Authentication');
            req.setHeader('x-dnb-user', USERNAME);
            req.setHeader('x-dnb-pwd', PASSWORD);
            HttpResponse response = http.send(req);
            
            String authCode = response.getHeader('Authorization');
            HttpRequest req2 = new HttpRequest();
            req2.setMethod('GET');
            req2.setEndpoint('https://maxcvservices.dnb.com/V6.0/organizations?SearchModeDescription=Basic&findcompany=true&KeywordText=' + key);
            req2.setHeader('Authorization', authCode);
            HttpResponse response2 = http.send(req2);
            return response2.getBody();
        }  
    }  
}