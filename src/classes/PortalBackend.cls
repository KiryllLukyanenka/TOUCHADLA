public with sharing class PortalBackend {
	private String serverURL = 'https://portal-staging.saastest.appdynamics.com';
	private String loginURL = 'https://login-staging.saastest.appdynamics.com';
	
	private String loginEndpoint = '/sso/login/';
	private String usageDataEndPoint = '';
	
	public String userName{
		get{
			return 'superuser@tarams.com';
		}
		set;
	}
	public String password{
		get{
			return 'Tarams123';
		}
		set;
	}
	
	
	public void login(){
		HttpResponse res = makePortalCall(loginURL+loginEndpoint,BackendConstants.REQ_METHOD_POST,'username='+userName+'&password='+password,null);
		String[] headerKeys = res.getHeaderKeys();
		map<String,String> headers = new map<String,String>();
		for(String key:headerKeys){
			if(key!=null && key.equals('Set-Cookie')){
				headers.put(key,res.getHeader(key));
			}
		}
		headers.put('Content-Type','application/json');
		headers.put('Accept','application/json');
		system.debug('Headers:'+headers);
		HttpResponse res1 = makePortalCall(serverURL+'/api/rest/v0.1/licenses/141774153668DJW/usage',BackendConstants.REQ_METHOD_GET,null,headers);
		System.debug(LoggingLevel.Info,'RESPONSE FOR GET USAGE API:'+res1.getBody());
	}
	
	public String getUsage(String requestURL){
		login();
		HttpResponse response = makePortalCall(serverURL+requestURL,BackendConstants.REQ_METHOD_GET,null,null);
		
		return response.getBody();
	}
	
	private HTTP http;
	
	private HttpResponse makePortalCall(String url,String requestMethod,String requestBody,Map<String,String>headers){
		if(http==null){
			http = new Http();
		}
		HttpRequest request = new Httprequest();
		request.setTimeout(1000*60*2);
		request.setEndpoint(url);
		
		Long timestamp = DateTime.now().getTime();
		
		if(requestBody!=null){
			request.setBody(requestBody);
		}
		//request.setMethod('get');//requestMethod);
		//request.setHeader("Auth", authString);
		if(requestMethod!=null){
			request.setMethod(requestMethod);
		}
		Integer retryCount = 0;
		Exception ex=null;
		
		if(headers!=null){
			for(String headerKey:headers.keySet()){
				system.debug(LoggingLevel.Info,'Setting header['+headerKey+'] = '+headers.get(headerKey));
				request.setHeader(headerKey,headers.get(headerKey));
				if(headerKey.equals('Set-Cookie')){
					request.setHeader('Cookie',headers.get(headerKey));
				}
			}
		}
		
		HttpResponse res = http.send(request);
		String headerValue = res.getHeader('Cookie');
		list<String> headerNames = res.getHeaderKeys();
		if(headerNames!=null){
			for(String headerName:headerNames){
				if(headerName!=null){
					System.debug(LoggingLevel.Info,'Header Name:'+headerName);
					System.debug(LoggingLevel.Info,'Header['+headerName+'] Value='+res.getHeader(headerName));
				}
			}
		}
		
		
		
		System.debug(LoggingLevel.Info,'COOKIE VALUE:'+headerValue);
		System.debug(LoggingLevel.Info,'COOKIE VALUE:'+res.getHeader('Vary'));
		System.debug(LoggingLevel.Info,'COOKIE VALUE:'+res.getHeader('Set-Cookie'));
		return res;	
	}
}