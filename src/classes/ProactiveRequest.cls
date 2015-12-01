public virtual class ProactiveRequest {
	public map<String,String> headers{
		get{
			if(headers==null){
				headers = new map<String, String>();
			}
			return headers;
		}
		set;
	}
	public String serverURL {
		get{
			if(serverURL==null){
				serverURL = 'https://proactive.appdynamics.com/';
			}
			return serverURL;
		}
		set;
	}
	public String endPoint{get;set;}
	public String operation{get;set;}
	public String requestData{get;set;}
	
	public virtual class HTTP extends ProactiveRequest{
		public HTTP chainedRequest{get;set;}
		public HTTP(){
			headers.put('secret-key','3MVG9CVKiXR7Ri5oDxPuFYnzIy0Kh9H_Viv4C8BbTw2E4z3LB22c1CxHfSUMdScHeGtif6t_nRrsA.bE_1Obo');
			operation = 'GET';
		}
	}
	
	public virtual class FakeHTTP extends HTTP{
		public  String fakeResponse;
		public FakeHTTP(String fakeResponse){
			super();
			this.fakeResponse = fakeResponse;
		}
	}
	
	public class AccountStats extends HTTP{
		public AccountStats(String accountID){
			super();
			this.endpoint = '/api/public/account/stats/usages/'+accountID;
		}
	}
	
	public class LoginStats extends HTTP{
		public LoginStats(String accountID){
			super();
			this.endpoint = '/api/public/account/stats/login/'+accountID;
		}
	}
	
	public class Summary extends HTTP{
		public Summary(String accountID){
			super();
			this.endpoint = 'api/public/account/score/summary/'+accountID;
		}
	}
	
	public class UsageTrend extends HTTP{
		public UsageTrend(String accountID){
			super();
			this.endpoint = '/api/public/account/usages/splunk?accountId='+accountID+'&daysSince=1';
		}
		/*public UsageTrend(String accountID, integer days){
			super();
			this.endpoint = '/api/public/account/usages/splunk?accountId='+accountID+'&daysSince='+days;
		}*/
	}
	
	/*public class FakeSummary extends FakeHTTP{
		public FakeSummary(String accountID){
			super('{"id":"0018000000h3S5AAAU","name":"Expedia, Inc.","s1ticketsCount":5,"s2TicketCount":6,"experience":null,"customerRelationStatus":null,"status":"Risk","cumulativeScore":{"sfAdoptionScore":75,"paapAdoptionScore":0,"bonusAdoptionScore":0,"zendeskScore":-80,"downloadScore":0,"experienceScore":0,"crScore":0,"bonusScore":0,"adoptionScore":75,"totalScore":-5},"totalScore":-5,"ruleSummeries":[{"id":null,"accountVO":null,"ruleSummary":"Score from salesforce adoption level 3.0","ruleScore":75},{"id":null,"accountVO":null,"ruleSummary":"Score from urgent tickets Count: 5","ruleScore":-50},{"id":null,"accountVO":null,"ruleSummary":"Score from high tickets Count: 6","ruleScore":-30},{"id":null,"accountVO":null,"ruleSummary":"Total Score","ruleScore":-5}],"downloadCount":null,"renewalPossible":null,"expansionPossible":null,"expansionAmount":null,"dealAmount":4816366.0,"paapAdoptionLevel":null,"sfAdoptionLevel":3.0,"tam":"Fabian Gonzales","totalTicket":64,"owner":"Evan Blake","subscribed":false}');
			this.endpoint = '/api/public/summary/account?accountId='+accountID;
		}
	}
	
	public class FakeUsage extends FakeHTTP{
		public FakeUsage(String accountID){
			super('[{"feature":"APP_DASHBOARD","score":3},{"feature":"EVENTS","score":2},{"feature":"HOME_PAGE","score":1},{"feature":"LOGIN","score":2},{"feature":"TIER_DAHBOARD","score":1},{"feature":"TROUBLESHOOT","score":399}]');
			this.endpoint = '/api/public/summary/account?accountId='+accountID;
		}
	}*/
	
	/*public virtual class Login extends HTTP{
		public String loginServer = 'https://login.appdynamics.com';
		public String loginEndpoint = '/sso/login/';
		public String userName = EncodingUtil.base64Decode('c3JpbmlkaGkuYWNoYXJ5YUBhcHBkeW5hbWljcy5jb20=').toString();
		public String password = EncodingUtil.base64Decode('VGFyYW1zNDU2').toString();
		public Login(){
			serverURL = loginServer;
			endPoint = loginEndpoint;
			requestData = 'username='+userName+'&password='+password;
			operation = BackendConstants.REQ_METHOD_POST;
		}
	}*/
	
	
	/*public class LicenseUsage extends HTTP{
		public String portalServer = 'https://portal.appdynamics.com/';
		public LicenseUsage(String portalLicenseId){
			super();
			serverUrl = portalServer;
			this.chainedRequest = new Login();
			this.endpoint = '/api/rest/v0.1/licenses/'+portalLicenseId+'/usage/';
			this.headers.put('Accept','application/json');
		}
	}*/
	
	/*public virtual class SOQL extends ProactiveRequest{
		public SOQL(){
			operation = 'SELECT';
		}
	}
	
	public class LicenseStats extends SOQL{
		public LicenseStats(String accountID){
			super();
			this.endpoint = 'SELECT (Select Id,'+
									'Agent_Type__c, '+
									'Count__c,'+
									'License__c,'+
									'Licensing_Model__c,'+
									'Expiration_Date__c,'+
									'Max_Agents__c,'+
									'Category__c,'+
									'Retention_Period__c,'+
									'Edition__c,'+
									'Enabled__c'+
									' from License_Agents__r order by CreatedDate),'+
									'CreatedById,'+
									'Manual_SaaS_Fields__c,'+
									'SaaS_Access_Key__c,'+
									'Support__c,'+
									'Controller_Id__c,'+
									'HA_Source_License__c,'+
									'LastOpCode__c,'+
									'License_Time__c,Last_License_User__c,'+
									' LastModifiedDate,Account_Manager__c,'+
									'Technical_Owner__c, Sales_Rep__c,'+
									' Ad_hoc_Email_Ids__c,Machine_Agents_Rollup__c,'+
									'PHP_Agents_Rollup__c,Is_Permanent__c,'+
									'Is_Perpetual__c,Net_Agents_Rollup__c,Reason__c,'+
									' Id,Stage__c, Name, License_BackendID__c, '+
									'MAC_Address__c, Product_Type__c, '+
									'Java_Agents_Rollup__c, ProcessState__c,'+
									' Custom_URL_Name__c, Is_HA__c, Transaction_ID__c,'+
									' License_Expiry_Date__c,SaaS_Account__c,'+
									'SaaS_UserName__c,SaaS_Password__c,'+
									'(select Access_Key__c, AccountName__c,License__c,'+
									'RUM_Enabled__c,State__c from License_EUM_Details__r),'+
									' (Select Opportunity__r.Account.Id, '+
									'Opportunity__r.Account.Name,Opportunity__r.Id,'+
									'Opportunity__r.Name from Opportunities__r) '+
									'from LicenseDetail__c where ID in '+
									'(Select License__c from License_Opportunity__c '+
									'where Opportunity__r.Account.Id = \''+accountID+'\')';
		}
	}*/
	
}