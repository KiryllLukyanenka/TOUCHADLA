public abstract class ProactiveBackend {
	
	public static ProactiveBackend instance(ProactiveRequest request, ProactiveResponse response){
		ProactiveBackend bkend = null;
		System.debug('REQUEST IS '+request);
		if(request instanceof ProactiveRequest.FakeHTTP){
			bkend = new FakeHTTP();
			bkend.request = request;
			bkend.proactiveResponse = response;
		}else if(request instanceof ProactiveRequest.HTTP){
			bkend = new HTTP();
			bkend.request = request;
			bkend.proactiveResponse = response;
		}/*else if(request instanceof ProactiveRequest.SOQL){
			bkend = new SOQL();
			bkend.request = request;
			bkend.proactiveResponse = response;
		}*/
		return bkend;
	}
	
	public ProactiveRequest request;
	
	public ProactiveResponse proactiveResponse;
	
	public abstract void invoke();
	
	
	/*public virtual class SOQL extends ProactiveBackend{
		public override void invoke(){
			list<SObject> queryResult = Database.query(request.endpoint);
			if(queryResult!=null){
				proactiveResponse.deserialize(queryResult);
			}
			//proactiveResponse.responseStr = '';
		}
	} */
	
	public virtual class HTTP extends ProactiveBackend{
		public virtual override void invoke(){
			ProactiveRequest.HTTP httpReq = (ProactiveRequest.HTTP) request;
			/*HttpResponse chainedResponse = null;
			if(httpReq.chainedRequest!=null){
				HTTP chainedBackend = new HTTP();
				chainedBackend.request = httpReq.chainedRequest;
				ProactiveResponse.HTTP httpResp = new ProactiveResponse.HTTP();
				chainedBackend.proactiveResponse = httpResp;
				chainedBackend.invoke();
				System.debug(LoggingLevel.Info,'Chained Res:'+httpResp.responseObj);
				//System.debug(LoggingLevel.Info,'Chained Res:'+httpResp.responseObj.getBody());
				chainedResponse = httpResp.responseObj;
			}
			if(chainedResponse!=null){
				String setCookieHeader = chainedResponse.getHeader('Set-Cookie');
				String cookieHeader = chainedResponse.getHeader('Cookie');
				System.debug(LoggingLevel.Info,'Set Cookie:'+setCookieHeader);
				System.debug(LoggingLevel.Info,'Cookie:'+setCookieHeader);
				request.headers.put('Set-Cookie',setCookieHeader);
				request.headers.put('Cookie',setCookieHeader);
			}*/
			RESTAPI callOut = new RESTAPI();
			callOut.serviceURL = request.serverURL+request.endPoint;
		 	callOut.requestMethod = request.operation;
			callout.headers = request.headers;
			callout.requestBody = request.requestData;
			callout.invoke();
			if(callout.response!=null){
				//proactiveResponse.response = responseStr;
				try{
					proactiveResponse.deserialize(callout.response);
				}catch(Exception e){
					System.debug(LoggingLevel.info,'Actual CallOut Exception:'+e.getMessage()+','+e.getStackTraceString());
				}
			}
		}
	}
	
	
	public virtual class FakeHTTP extends ProactiveBackend{
		
		public virtual override void invoke(){
			ProactiveRequest.FakeHTTP httpReq = (ProactiveRequest.FakeHTTP) request;
			RESTAPI callOut = new RESTAPI();
			callout.response = new HttpResponse();
			System.debug(LoggingLevel.Info,'DEBUG Of Response:'+httpReq.fakeResponse);
			callout.response.setBody(httpReq.fakeResponse);
			try{
				proactiveResponse.deserialize(callout.response);
			}catch(Exception e){
				System.debug(LoggingLevel.info,'REQ is :'+httpReq.fakeResponse+' CallOut Exception:'+e.getMessage()+','+e.getStackTraceString());
			}
		}
	
	}
}