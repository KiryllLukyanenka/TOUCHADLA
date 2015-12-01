public with sharing class ProactiveStatsController extends ProactiveController{
	public ProactiveStatsController(){
		
	}

	public Integer daysSince{get;set;}

	public override void buildRequest(){
		if(metric=='ACCOUNT_STATS'){ 
			proactiveRequest =  new ProactiveRequest.AccountStats(accountId);
		}else if(metric=='LOGIN_STATS'){
			proactiveRequest =  new ProactiveRequest.LoginStats(accountId); 
		}else if(metric=='SUMMARY'){
			proactiveRequest =  new ProactiveRequest.Summary(accountId);//'{"id":"0018000000h3S5AAAU","name":"Expedia, Inc.","s1ticketsCount":5,"s2TicketCount":6,"experience":null,"customerRelationStatus":null,"status":"Risk","cumulativeScore":{"sfAdoptionScore":75,"paapAdoptionScore":0,"bonusAdoptionScore":0,"zendeskScore":-80,"downloadScore":0,"experienceScore":0,"crScore":0,"bonusScore":0,"adoptionScore":75,"totalScore":-5},"totalScore":-5,"ruleSummeries":[{"id":null,"accountVO":null,"ruleSummary":"Score from salesforce adoption level 3.0","ruleScore":75},{"id":null,"accountVO":null,"ruleSummary":"Score from urgent tickets Count: 5","ruleScore":-50},{"id":null,"accountVO":null,"ruleSummary":"Score from high tickets Count: 6","ruleScore":-30},{"id":null,"accountVO":null,"ruleSummary":"Total Score","ruleScore":-5}],"downloadCount":null,"renewalPossible":null,"expansionPossible":null,"expansionAmount":null,"dealAmount":4816366.0,"paapAdoptionLevel":null,"sfAdoptionLevel":3.0,"tam":"Fabian Gonzales","totalTicket":64,"owner":"Evan Blake","subscribed":false}');
		}else if(metric=='USAGE_TREND'){
			/*if(daysSince!=null && daysSince>0){
				proactiveRequest =  new ProactiveRequest.UsageTrend(accountId, daysSince);
			}else
			{*/
				proactiveRequest =  new ProactiveRequest.UsageTrend(accountId);
			//}
		}
	}
	
	public override void buildResponse(){
		if(metric=='ACCOUNT_STATS'){
			proactiveResponse = new ProactiveResponse.AccountStats();
		}else if(metric=='LOGIN_STATS'){
			proactiveResponse =  new ProactiveResponse.LoginStats();
		}else if(metric=='SUMMARY'){
			proactiveResponse =  new ProactiveResponse.Summary();
		}else if(metric=='USAGE_TREND'){
			proactiveResponse =  new ProactiveResponse.UsageTrend();
		}
	}
	
	public override ProactiveBackend buildProactiveBackend(){
		ProactiveBackend bkend = ProactiveBackend.instance(proactiveRequest,proactiveResponse);
		/*new ProactiveBackend.ProactiveBackend_HTTP();
		proactiveBackend.request = proactiveRequest;
		proactiveBackend.proactiveResponse = proactiveResponse;*/
		return bkend;
	}
	
	public PortalGenericMapList getRuleSummaryList(){
		if(statsDataList!=null && statsDataList.size()>0){
			return new PortalGenericMapList(((ProactiveDataType.AccountSummary)statsDataList[0]).ruleSummeries);
		}
		return null;
	}
	
	public String getHealthSummary(){
		if(statsDataList!=null && statsDataList.size()>0){
			return (((ProactiveDataType.AccountSummary)statsDataList[0]).status);
		}
		return null;
	}
	
	public Integer getHealthScore(){
		if(statsDataList!=null && statsDataList.size()>0){
			return  ((ProactiveDataType.AccountSummary)statsDataList[0]).totalScore;
		}
		return null;
	}
}