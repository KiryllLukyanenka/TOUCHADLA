public virtual class RESTAPI {
	public transient HttpRequest request{get;set;}
	public transient HttpResponse response{get;set;}	
	public static Boolean unitTestMode=false;
	public transient String serviceURL{get;set;}
	public transient String requestMethod{get;set;}
	public transient String requestBody{get;set;}
	public transient Map<String,String>headers{get;set;}
	
	/**
	*
	*/
	public void invoke()
	{
		Http http = new Http();
		request = new Httprequest();
		request.setTimeout(1000*60*2);
		request.setEndpoint(serviceURL);
		
		Long timestamp = DateTime.now().getTime();
		if(headers!=null){
			for(String headerKey:headers.keySet()){
				if(headers.get(headerKey)!=null){
					request.setHeader(headerKey,headers.get(headerKey));
				}
			}
		}
		
		if(requestBody!=null)
		{
			request.setBody(requestBody);
		}
		//request.setMethod('get');//requestMethod);
		//request.setHeader("Auth", authString);
		if(requestMethod!=null){
			request.setMethod(requestMethod);
		}
		if(unitTestMode)
		{
			response = new Httpresponse();
			if(serviceURL!=null && !serviceURL.trim().equals(''))
			{
				response.SetStatusCode(200);
			}
			else
			{
				response.SetStatusCode(400);
			}
			if(requestMethod==null){
				response=null;
			}
		}
		else
		{
			Integer retryCount = 0;
			Exception ex=null;
			
			response = http.send(request);
			
				
			
			/*while(retryCount<3){
				try{
					response = http.send(request);
					ex=null;
					break;
				}catch(Exception e){
					ex=e;
					retryCount++;
					EmailUtil.notifyError(e, null);
				}
			}
			if(ex!=null){
				throw ex;
			}*/
		}	
	}
}