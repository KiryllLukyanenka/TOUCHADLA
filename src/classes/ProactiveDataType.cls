public with sharing class ProactiveDataType {
	
	//[{"feature":"APP_DASHBOARD","score":3},{"feature":"EVENTS","score":2},{"feature":"HOME_PAGE","score":1},{"feature":"LOGIN","score":2},{"feature":"TIER_DAHBOARD","score":1},{"feature":"TROUBLESHOOT","score":399}]
	public class UsageTrend extends PortalGenericMap{
		public String feature{
			get;
			set{
				feature = value;
				setValue('Feature',value);
			}
		}
		
		public Integer score{
			get;
			set{
				score = value;
				setValue('Score',value);
			}
		}
	}
	
	//{"id":"0018000000muy64AAA","name":"BSkyB","s1ticketsCount":0,"s2TicketCount":9,"experience":null,"customerRelationStatus":null,"status":"Risk","cumulativeScore":{"sfAdoptionScore":50,"paapAdoptionScore":0,"bonusAdoptionScore":0,"zendeskScore":-45,"downloadScore":20,"experienceScore":0,"crScore":0,"bonusScore":0,"adoptionScore":50,"totalScore":25},"totalScore":25,"ruleSummeries":[{"id":null,"accountVO":null,"ruleSummary":"Score from salesforce adoption level 2.0","ruleScore":50},{"id":null,"accountVO":null,"ruleSummary":"Score from urgent tickets Count: 0","ruleScore":0},{"id":null,"accountVO":null,"ruleSummary":"Score from high tickets Count: 9","ruleScore":-45},{"id":null,"accountVO":null,"ruleSummary":"Score from download activities (MAX 20) Count: 39","ruleScore":20},{"id":null,"accountVO":null,"ruleSummary":"Total Score","ruleScore":25}],"downloadCount":39,"renewalPossible":null,"expansionPossible":null,"expansionAmount":null,"dealAmount":1060224.0,"paapAdoptionLevel":null,"sfAdoptionLevel":2.0,"tam":"Jose Ramon Bronet","totalTicket":49,"owner":"Parminder Uppal","subscribed":false}
	
	public class AccountSummary extends PortalGenericMap{
		public String id { get;
			set{
				id = value;
				setValue('Salesforce Account ID', value);
			}
		}
		public String name { get;
			set{
				name = value;
				setValue('Salesforce Account Name', value);
			}
		}
		public Integer s1ticketsCount {get;
			set{
				s1ticketsCount = value;
				setValue('#of S1 Tickets', value);		
			}
		}
		public Integer s2TicketCount {get;
			set{
				s2TicketCount = value;
				setValue('#of S2 Tickets', value);		
			}
		}
		public Integer totalTicket {get;
			set{
				totalTicket = value;
				setValue('Total # of Tickets', value);		
			}
		}
		
		public String experience {get;
			set{
				experience = value;
				setValue('Experience', value);		
			}
		}
		public String customerRelationStatus {get;
			set{
				customerRelationStatus = value;
				setValue('Customer Relation Status', value);		
			}
		}
		public String status {get;
			set{
				status = value;
				setValue('Status', value);		
			}
		}
		
		public Integer downloadCount {get;
			set{
				downloadCount = value;
				setValue('# of Downloads', value);		
			}
		}
		
		public Double dealAmount {get;
			set{
				dealAmount = value;
				setValue('Deal Amount', value);		
			}
		}
		
		public Integer totalScore {
			get;
			set{
				totalScore = value;
				setValue('Total Score',value);
			}
		}
		
		public list<RuleSummary> ruleSummeries {get;set;} 
	}
	
	public class RuleSummary extends PortalGenericMap{
		public String ruleSummary{
			get;
			set{
				ruleSummary = value;
				setValue('Summary',value);
			}
		}
		public String ruleScore{
			get;
			set{
				ruleScore = value;
				setValue('Score',value);
			}
		}
	}
	
	
	public virtual class AccountStatList extends PortalGenericMapList{
		public AccountStatList(list<ProactiveDataType.AccountStat> accountStats){
			super(accountStats,new map<Integer,String>{
				0 => 'Controller URL',
				1 => 'Account Name',
				2 => 'Application'
			});
		}
	}
	
	
	//[{"id":8215,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"Adaptive Learning - Int","btCount":72,"dotNetNodes":3,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8216,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"Adaptive Learning - Prod","btCount":209,"dotNetNodes":3,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8217,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"BlueSky-PQA","btCount":25,"dotNetNodes":8,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8218,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"BOS03_MMND_PROD","btCount":1462,"dotNetNodes":88,"javaNodes":8,"phpNodes":0,"nodeJsNodes":0},{"id":8219,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"BOS03_MMND_Staging","btCount":618,"dotNetNodes":70,"javaNodes":12,"phpNodes":0,"nodeJsNodes":0},{"id":8220,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"Console_Test","btCount":22,"dotNetNodes":0,"javaNodes":0,"phpNodes":0,"nodeJsNodes":2},{"id":8221,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"Contineo-PPE","btCount":34,"dotNetNodes":20,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8222,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"Contineo-Prod","btCount":28,"dotNetNodes":20,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8223,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"EPIC PPE","btCount":143,"dotNetNodes":14,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8224,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"EPIC PROD","btCount":162,"dotNetNodes":14,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8225,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"Equella","btCount":1005,"dotNetNodes":82,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8226,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"Equella - Staging","btCount":603,"dotNetNodes":3,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8227,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"ETEXT PPE","btCount":208,"dotNetNodes":43,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8228,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"GRID","btCount":2,"dotNetNodes":9,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8229,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"GRID - Staging","btCount":2,"dotNetNodes":25,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8230,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"HED_NextGen_PROD","btCount":2,"dotNetNodes":8,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8231,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"HED_NextGen_STG","btCount":23,"dotNetNodes":21,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8232,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"K12RS_INT","btCount":34,"dotNetNodes":0,"javaNodes":4,"phpNodes":0,"nodeJsNodes":0},{"id":8233,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"K12RS_TEST","btCount":34,"dotNetNodes":0,"javaNodes":2,"phpNodes":0,"nodeJsNodes":0},{"id":8234,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"MMND","btCount":2007,"dotNetNodes":20,"javaNodes":3508,"phpNodes":0,"nodeJsNodes":0},{"id":8235,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"MMND - Staging","btCount":1437,"dotNetNodes":53,"javaNodes":707,"phpNodes":0,"nodeJsNodes":0},{"id":8236,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"MMND PPE","btCount":49,"dotNetNodes":1,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8237,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"MMND PROD","btCount":721,"dotNetNodes":33,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8238,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"MMND_CERT","btCount":621,"dotNetNodes":18,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8239,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"MMND_CERT2","btCount":101,"dotNetNodes":1,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8240,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"MMND-DEV","btCount":601,"dotNetNodes":2,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8241,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"OLE CERT","btCount":71,"dotNetNodes":3,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8242,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"OLE PPE","btCount":103,"dotNetNodes":23,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8243,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"OLE PROD","btCount":132,"dotNetNodes":25,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8244,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"PAF_PROD","btCount":79,"dotNetNodes":112,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8245,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"PAF_STG","btCount":601,"dotNetNodes":112,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8246,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"Pegasus PPE","btCount":108,"dotNetNodes":0,"javaNodes":154,"phpNodes":0,"nodeJsNodes":0},{"id":8247,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"Pegasus PQA","btCount":5,"dotNetNodes":0,"javaNodes":6,"phpNodes":0,"nodeJsNodes":0},{"id":8248,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"Pegasus PROD","btCount":604,"dotNetNodes":0,"javaNodes":416,"phpNodes":0,"nodeJsNodes":0},{"id":8249,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"PIF_Adapter_STG","btCount":19,"dotNetNodes":1,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8250,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"PSN-FTEST","btCount":570,"dotNetNodes":5,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8251,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"PSN-ITEST","btCount":49,"dotNetNodes":5,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8252,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"PWC CERT","btCount":249,"dotNetNodes":2,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8253,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"PWC_PPE","btCount":83,"dotNetNodes":4,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8254,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"PWC_PROD","btCount":128,"dotNetNodes":4,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8255,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"PXESDK_Staging","btCount":2,"dotNetNodes":4,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8256,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"REALIZE CERT","btCount":137,"dotNetNodes":5,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8257,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"REALIZE DEV","btCount":602,"dotNetNodes":4,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8258,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"REALIZE EDITORIAL A","btCount":69,"dotNetNodes":3,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8259,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"REALIZE EDITORIAL B","btCount":47,"dotNetNodes":10,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8260,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"REALIZE PERF","btCount":99,"dotNetNodes":5,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8261,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"REALIZE PERF A","btCount":605,"dotNetNodes":59,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8262,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"REALIZE PPE A","btCount":35,"dotNetNodes":5,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8263,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"REALIZE PPE B","btCount":63,"dotNetNodes":37,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8264,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"REALIZE PROD A","btCount":91,"dotNetNodes":17,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8265,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"REALIZE PROD B","btCount":113,"dotNetNodes":67,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8266,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"REALIZE STAGING","btCount":197,"dotNetNodes":49,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8267,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"Revel_PROD","btCount":23,"dotNetNodes":8,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8268,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"RUMBA INT","btCount":601,"dotNetNodes":13,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8269,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"RUMBA OSB","btCount":7,"dotNetNodes":1,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8270,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"RUMBA PPE","btCount":162,"dotNetNodes":83,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8271,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"RUMBA PROD","btCount":741,"dotNetNodes":87,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8272,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"Rundeck","btCount":31,"dotNetNodes":1,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8273,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"Storefronts Production","btCount":626,"dotNetNodes":3,"javaNodes":266,"phpNodes":0,"nodeJsNodes":0},{"id":8274,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"Storefronts QA","btCount":624,"dotNetNodes":1,"javaNodes":44,"phpNodes":0,"nodeJsNodes":0},{"id":8275,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"test","btCount":299,"dotNetNodes":13,"javaNodes":0,"phpNodes":0,"nodeJsNodes":2},{"id":8276,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"WSOD_Staging","btCount":603,"dotNetNodes":0,"javaNodes":34,"phpNodes":0,"nodeJsNodes":0},{"id":8277,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"XL - Cert","btCount":97,"dotNetNodes":0,"javaNodes":7,"phpNodes":0,"nodeJsNodes":0},{"id":8278,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"XL - Global","btCount":448,"dotNetNodes":0,"javaNodes":23,"phpNodes":0,"nodeJsNodes":0},{"id":8279,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"XL - HigherEd","btCount":604,"dotNetNodes":0,"javaNodes":24,"phpNodes":0,"nodeJsNodes":0},{"id":8280,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"XL - nPPE","btCount":603,"dotNetNodes":0,"javaNodes":25,"phpNodes":0,"nodeJsNodes":0},{"id":8281,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"XL - School","btCount":602,"dotNetNodes":0,"javaNodes":35,"phpNodes":0,"nodeJsNodes":0},{"id":8282,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"XL Dash - Prod","btCount":108,"dotNetNodes":4,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8283,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"xldash","btCount":278,"dotNetNodes":2,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":8284,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"xldash-dev","btCount":20,"dotNetNodes":1,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":29416,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"REALIZE STAGING A","btCount":1,"dotNetNodes":1,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":59414,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"Seer - Stg","btCount":1,"dotNetNodes":1,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":67640,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"REALIZE PROD","btCount":2,"dotNetNodes":1,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":71919,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"REALIZE NIGHTLY A","btCount":2,"dotNetNodes":2,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":88529,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"NIGHTLY","btCount":4,"dotNetNodes":1,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":88538,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"PI_APPS","btCount":2,"dotNetNodes":2,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":88539,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"piapi-legacy-cas","btCount":1,"dotNetNodes":1,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":88540,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"piapi-legacy-userlifecycle","btCount":2,"dotNetNodes":1,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":92695,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"PXESDK_PROD","btCount":1,"dotNetNodes":4,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":138702,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"Union_PPE","btCount":3,"dotNetNodes":1,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":155743,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"REALIZE CERT A","btCount":17,"dotNetNodes":2,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":164468,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"XL Dash - Int","btCount":1,"dotNetNodes":4,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":212395,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"PI_APPS_STG","btCount":1,"dotNetNodes":8,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":239060,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"REALIZE PPE","btCount":58,"dotNetNodes":2,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":269509,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"XL Item Players - PPE","btCount":1,"dotNetNodes":0,"javaNodes":3,"phpNodes":0,"nodeJsNodes":0},{"id":296416,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"Analytics - Staging","btCount":6,"dotNetNodes":3,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":320906,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"REALIZE NIGHTLY PREPROD A","btCount":5,"dotNetNodes":5,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":328693,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"Union_PRD","btCount":4,"dotNetNodes":6,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":332731,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"XL Item Players - Prod","btCount":13,"dotNetNodes":0,"javaNodes":1,"phpNodes":0,"nodeJsNodes":0},{"id":336733,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"Pearson POC","btCount":7,"dotNetNodes":0,"javaNodes":1,"phpNodes":0,"nodeJsNodes":0},{"id":385220,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"3PL_Staging","btCount":19,"dotNetNodes":2,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0},{"id":389718,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"Exchange","btCount":12,"dotNetNodes":0,"javaNodes":0,"phpNodes":0,"nodeJsNodes":9},{"id":393819,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"Exchange - Staging","btCount":28,"dotNetNodes":0,"javaNodes":0,"phpNodes":0,"nodeJsNodes":4},{"id":443024,"controllerURL":"prdprscontrdb1a","account":"pearson","application":"REALIZE NIGHTLY PROD A","btCount":14,"dotNetNodes":6,"javaNodes":0,"phpNodes":0,"nodeJsNodes":0}]
	
	/*
	 * 
	 */
	public class AccountStat extends PortalGenericMap{
		public String id {
			get;
			set{
				id = value;
				setValue('Account ID',value);
			}
		}
		public String controllerURL {get;
			set{
				controllerURL = value;
				setValue('Controller URL',value);
			}
		}
		public String account {get;
			set{
				account = value;
				setValue('Account Name',value);
			}
		}
		public String application {get;
			set{
				application = value;
				setValue('Application',value);
			}
		}
		public Integer btCount {get;
			set{
				btCount = value;
				setValue('# of BTs',value);
			}
		}
		public Integer dotNetNodes {
			get;
			set{
				dotNetNodes = value;
				setValue('# of .Net Nodes',value);
			}
		}
		public Integer javaNodes {get;
			set{
				javaNodes = value;
				setValue('# of Java Nodes',value);
			}
		}
		public Integer phpNodes {get;
			set{
				phpNodes = value;
				setValue('# of PHP Nodes',value);
			}
		}
		public Integer nodeJsNodes {get;
			set{
				nodeJsNodes = value;
				setValue('# of NodeJs Nodes',value);
			}
		}
		
		/*public override list<String> keySet(){
			return new String[]{
								'Account ID',
								'Controller URL',
								'Account Name',
								'Application',
								'# of BTs',
								'# of Java Nodes',
								'# of .Net Nodes',
								'# of PHP Nodes',
								'# of NodeJs Nodes'
							};
		}*/
	}
	
	public virtual class LoginStatList extends PortalGenericMapList{
		public LoginStatList(list<ProactiveDataType.LoginStat> loginStats){
			super(loginStats,new map<Integer,String>{
				0 => 'Controller URL',
				1 => 'Account'
			});
		}
	}
	
	//[{"id":2535,"controllerURL":"prdcontr23a","account":"expediacore","email":"omsprod@expedia.com","lastLogin":1409293278000,"loginCountToday":3432},{"id":6594,"controllerURL":"prdcontr10b","account":"ean-test","email":"eanops@expedia.com","lastLogin":1409847498000,"loginCountToday":36},{"id":2533,"controllerURL":"prdcontr23a","account":"expediacore","email":"gptprd@expedia.com","lastLogin":1409282775000,"loginCountToday":17},{"id":2211,"controllerURL":"prdcontr10b","account":"customer1","email":"andy@bash.sh","lastLogin":1409236373000,"loginCountToday":11},{"id":2217,"controllerURL":"prdcontr10b","account":"customer1","email":"readonly@test.com","lastLogin":1409236373000,"loginCountToday":11},{"id":1862,"controllerURL":"prdcontr19b","account":"hcom","email":"\\N","lastLogin":1409240620000,"loginCountToday":11},{"id":1863,"controllerURL":"prdcontr19b","account":"hcom","email":"","lastLogin":1409234689000,"loginCountToday":8},{"id":10777,"controllerURL":"prdcontr53b","account":"expedia_vci","email":"vciappen@expedia.com","lastLogin":1410302394000,"loginCountToday":8},{"id":2530,"controllerURL":"prdcontr23a","account":"expediacore","email":"bgovindarajan@expedia.com","lastLogin":1409291706000,"loginCountToday":6},{"id":41422,"controllerURL":"prdcontr10b","account":"customer1","email":"josepjones@expedia.com","lastLogin":1413917611000,"loginCountToday":6},{"id":2532,"controllerURL":"prdcontr23a","account":"expediacore","email":"esprod@expedia.com","lastLogin":1409284759000,"loginCountToday":5},{"id":10776,"controllerURL":"prdcontr53b","account":"expedia_vci","email":"mcraig@expedia.com","lastLogin":1410299252000,"loginCountToday":5},{"id":6780,"controllerURL":"prdcontr53b","account":"Voyager","email":"zricketts@expedia.com","lastLogin":1409866580000,"loginCountToday":4},{"id":32389,"controllerURL":"prdcontr10b","account":"customer1","email":"bshalander@hotels.com","lastLogin":1412696445000,"loginCountToday":4},{"id":2539,"controllerURL":"prdcontr23a","account":"expediacore","email":"vikgupta@expedia.com","lastLogin":1409283433000,"loginCountToday":4},{"id":4092,"controllerURL":"prdcontr10b","account":"customer1","email":"dakennedy@expedia.com","lastLogin":1409559812000,"loginCountToday":4},{"id":2218,"controllerURL":"prdcontr10b","account":"Customer1","email":"skesterson@expedia.com","lastLogin":1409238769000,"loginCountToday":4},{"id":18686,"controllerURL":"prdcontr10b","account":"customer1","email":"lmayes@expedia.com","lastLogin":1411059854000,"loginCountToday":4},{"id":5899,"controllerURL":"prdcontr23a","account":"ts-sandbox","email":"_sjk@expedia.com","lastLogin":1409786237000,"loginCountToday":4},{"id":27282,"controllerURL":"prdcontr10b","account":"Customer1","email":"wanichols@expedia.com","lastLogin":1412104827000,"loginCountToday":4},{"id":2543,"controllerURL":"prdcontr23a","account":"GIS","email":"daviwilliams@expedia.com","lastLogin":1409248748000,"loginCountToday":4},{"id":4097,"controllerURL":"prdcontr10b","account":"customer1","email":"gadavis@expedia.com","lastLogin":1409593182000,"loginCountToday":4},{"id":8954,"controllerURL":"prdcontr53b","account":"voyager","email":"mrafique@expedia.com","lastLogin":1410200513000,"loginCountToday":3},{"id":1867,"controllerURL":"prdcontr19b","account":"hcom","email":"msartori@expedia.com","lastLogin":1409234689000,"loginCountToday":3},{"id":8949,"controllerURL":"prdcontr53b","account":"GIS-IPS","email":"noreply@expedia.com","lastLogin":1410235960000,"loginCountToday":3},{"id":2219,"controllerURL":"prdcontr10b","account":"customer1","email":"vdadia@hotels.com","lastLogin":1409235549000,"loginCountToday":3},{"id":67901,"controllerURL":"prdcontr53a","account":"hotwire","email":"abarylo@hotwire.com","lastLogin":1416874293000,"loginCountToday":3},{"id":1865,"controllerURL":"prdcontr19b","account":"hcom","email":"kgovindarajan@expedia.com","lastLogin":1409220230000,"loginCountToday":3},{"id":51187,"controllerURL":"prdcontr53a","account":"hotwire_CRG","email":"crprdsup@expedia.com","lastLogin":1415047618000,"loginCountToday":3},{"id":3916,"controllerURL":"prdcontr19b","account":"hcom","email":"nmistry@expedia.com","lastLogin":1409589573000,"loginCountToday":3},{"id":2534,"controllerURL":"prdcontr23a","account":"expediacore","email":"iwang@expedia.com","lastLogin":1409290875000,"loginCountToday":3},{"id":2544,"controllerURL":"prdcontr23a","account":"GIS","email":"e2eteam@expedia.com","lastLogin":1409262788000,"loginCountToday":3},{"id":43388,"controllerURL":"prdcontr10b","account":"customer1","email":"jbaird@expedia.com","lastLogin":1414082622000,"loginCountToday":2},{"id":2443,"controllerURL":"prdcontr53a","account":"voyager","email":"harora@expedia.com","lastLogin":1409291508000,"loginCountToday":2},{"id":68793,"controllerURL":"prdcontr10a","account":"customer1","email":"a-jdilley@expedia.com","lastLogin":1416932901000,"loginCountToday":2},{"id":3255,"controllerURL":"prdcontr53a","account":"voyager","email":"tweis@expedia.com","lastLogin":1409340373000,"loginCountToday":2},{"id":4094,"controllerURL":"prdcontr10b","account":"customer1","email":"dlovelace@expedia.com","lastLogin":1409579624000,"loginCountToday":2},{"id":5528,"controllerURL":"prdcontr31a","account":"bigbrother_egencia","email":"d.hollick@egencia.com","lastLogin":1409738137000,"loginCountToday":2},{"id":6589,"controllerURL":"prdcontr10b","account":"customer1","email":"rdiaconescu@expedia.com","lastLogin":1409823165000,"loginCountToday":2},{"id":24870,"controllerURL":"prdcontr10b","account":"customer1","email":"a-spokkunuri@expedia.com","lastLogin":1411770173000,"loginCountToday":2},{"id":46535,"controllerURL":"prdcontr10b","account":"Customer1","email":"bodell@hotels.com","lastLogin":1414521573000,"loginCountToday":2},{"id":63853,"controllerURL":"prdcontr16a","account":"horus_egencia","email":"v-kburramukku@expedia.com","lastLogin":1416393856000,"loginCountToday":2},{"id":4969,"controllerURL":"prdcontr23a","account":"ts-sandbox","email":"skeever@expedia.com","lastLogin":1409685527000,"loginCountToday":2},{"id":6586,"controllerURL":"prdcontr10b","account":"Customer1","email":"jakcollins@expedia.com","lastLogin":1409828771000,"loginCountToday":2},{"id":12652,"controllerURL":"prdcontr16a","account":"horus_egencia","email":"aallegret@egencia.com","lastLogin":1410450622000,"loginCountToday":2},{"id":24869,"controllerURL":"prdcontr10b","account":"customer1","email":"a-psarniak@expedia.com","lastLogin":1411770193000,"loginCountToday":2},{"id":2440,"controllerURL":"prdcontr53a","account":"Voyager","email":"a-jlemaster@expedia.com","lastLogin":1409249978000,"loginCountToday":2},{"id":2538,"controllerURL":"prdcontr23a","account":"expediacore","email":"v-vshantarenka@expedia.com","lastLogin":1409287698000,"loginCountToday":2},{"id":4759,"controllerURL":"prdcontr10b","account":"ean-test","email":"itodoran@expedia.com","lastLogin":1409658875000,"loginCountToday":2},{"id":6769,"controllerURL":"prdcontr53b","account":"GIS-IPS","email":"rdelph@expedia.com","lastLogin":1409892911000,"loginCountToday":2},{"id":8385,"controllerURL":"prdcontr16a","account":"horus_egencia","email":"hneelakantan@egencia.com","lastLogin":1410212563000,"loginCountToday":2},{"id":24868,"controllerURL":"prdcontr10b","account":"customer1","email":"a-maellison@expedia.com","lastLogin":1411770173000,"loginCountToday":2},{"id":2439,"controllerURL":"prdcontr53a","account":"voyager","email":"a-bndze@expedia.com","lastLogin":1409265752000,"loginCountToday":2},{"id":2537,"controllerURL":"prdcontr23a","account":"expediacore","email":"tstech@expedia.com","lastLogin":1409247634000,"loginCountToday":2},{"id":65407,"controllerURL":"prdcontr10a","account":"ean-test","email":"dhasenoehrl@expedia.com","lastLogin":1416498880000,"loginCountToday":2},{"id":4755,"controllerURL":"prdcontr10b","account":"customer1","email":"psteward@expedia.com","lastLogin":1409705335000,"loginCountToday":2},{"id":6767,"controllerURL":"prdcontr53b","account":"expedia_ca","email":"lcsdevsp@expedia.com","lastLogin":1409864446000,"loginCountToday":2},{"id":8384,"controllerURL":"prdcontr16a","account":"horus_egencia","email":"ectappen@expedia.com","lastLogin":1410214404000,"loginCountToday":2},{"id":42560,"controllerURL":"prdcontr53b","account":"hotwire","email":"smikhaltchouk@hotwire.com","lastLogin":1414043466000,"loginCountToday":2},{"id":64456,"controllerURL":"prdcontr53a","account":"hotwire_CRG","email":"gyork@expedia.com","lastLogin":1416427190000,"loginCountToday":2},{"id":4628,"controllerURL":"prdcontr31a","account":"bigbrother_egencia","email":"bsama@egencia.com","lastLogin":1409673327000,"loginCountToday":2},{"id":6599,"controllerURL":"prdcontr10b","account":"ean-test","email":"robevans@expedia.com","lastLogin":1409845184000,"loginCountToday":2},{"id":10778,"controllerURL":"prdcontr53b","account":"gis-ips","email":"jkelly@expedia.com","lastLogin":1410280977000,"loginCountToday":2},{"id":22897,"controllerURL":"prdcontr10b","account":"customer1","email":"hhogue@hotels.com","lastLogin":1411578328000,"loginCountToday":2},{"id":43553,"controllerURL":"prdcontr53b","account":"atlab","email":"stnorton@expedia.com","lastLogin":1414105783000,"loginCountToday":2},{"id":6597,"controllerURL":"prdcontr10b","account":"ean-test","email":"nengland@expedia.com","lastLogin":1409864946000,"loginCountToday":2},{"id":16653,"controllerURL":"prdcontr53b","account":"voyager","email":"a-jkenney@expedia.com","lastLogin":1410902966000,"loginCountToday":2},{"id":28241,"controllerURL":"prdcontr10b","account":"customer1","email":"nweibel@hotels.com","lastLogin":1412172660000,"loginCountToday":2},{"id":1919,"controllerURL":"prdcontr83a","account":"hotwire","email":"nreddy@hotwire.com","lastLogin":1409266539000,"loginCountToday":2},{"id":69851,"controllerURL":"prdcontr53a","account":"hotwire_CRG","email":"crengg@expedia.com","lastLogin":1417049470000,"loginCountToday":2},{"id":4099,"controllerURL":"prdcontr10b","account":"Customer1","email":"sfernandes@expedia.com","lastLogin":1409566467000,"loginCountToday":2},{"id":5671,"controllerURL":"prdcontr10b","account":"customer1","email":"twalters@expedia.com","lastLogin":1409756913000,"loginCountToday":2},{"id":6596,"controllerURL":"prdcontr10b","account":"ean-test","email":"nemgland@expedia.com","lastLogin":1409864946000,"loginCountToday":2},{"id":16453,"controllerURL":"prdcontr10b","account":"ean-test","email":"rscudder@expedia.com","lastLogin":1410908636000,"loginCountToday":2},{"id":21184,"controllerURL":"prdcontr53b","account":"Hotwire","email":"avenkiteswara@hotwire.com","lastLogin":1411421625000,"loginCountToday":2},{"id":41434,"controllerURL":"prdcontr10b","account":"Customer1","email":"wjackson@expedia.com","lastLogin":1413912882000,"loginCountToday":2},{"id":46666,"controllerURL":"prdcontr53b","account":"Voyager","email":"jstastny@expedia.com","lastLogin":1414551859000,"loginCountToday":2},{"id":5665,"controllerURL":"prdcontr10b","account":"customer1","email":"bhubbell@expedia.com","lastLogin":1409773858000,"loginCountToday":2},{"id":16441,"controllerURL":"prdcontr10b","account":"customer1","email":"ikershaw@expedia.com","lastLogin":1410868057000,"loginCountToday":2},{"id":26282,"controllerURL":"prdcontr10b","account":"ean-test","email":"dconaway@expedia.com","lastLogin":1412007668000,"loginCountToday":2},{"id":2213,"controllerURL":"prdcontr10b","account":"Customer1","email":"dsymons@expedia.com","lastLogin":1409224915000,"loginCountToday":2},{"id":2220,"controllerURL":"prdcontr10b","account":"ean-test","email":"p120@expedia.com","lastLogin":1409281304000,"loginCountToday":1},{"id":46655,"controllerURL":"prdcontr53b","account":"expedia_ca","email":"rmewanou@expedia.com","lastLogin":1414529122000,"loginCountToday":1},{"id":54295,"controllerURL":"prdcontr53a","account":"hotwire","email":"hlalefar@hotwire.com","lastLogin":1415297538000,"loginCountToday":1},{"id":64446,"controllerURL":"prdcontr53a","account":"ATLab","email":"milind@expedia.com","lastLogin":1416427629000,"loginCountToday":1},{"id":2542,"controllerURL":"prdcontr23a","account":"GIS","email":"becole@expedia.com","lastLogin":1409268203000,"loginCountToday":1},{"id":12917,"controllerURL":"prdcontr31b","account":"bigbrother_egencia","email":"eae@egencia.eu","lastLogin":1410449278000,"loginCountToday":1},{"id":16260,"controllerURL":"prdcontr31b","account":"bigbrother_egencia","email":"b.chea@egencia.fr","lastLogin":1410869789000,"loginCountToday":1},{"id":17914,"controllerURL":"prdcontr53b","account":"Voyager","email":"akhasan@expedia.com","lastLogin":1411018944000,"loginCountToday":1},{"id":19770,"controllerURL":"prdcontr53b","account":"hotwire","email":"mstalnaker@hotwire.com","lastLogin":1411145937000,"loginCountToday":1},{"id":40591,"controllerURL":"prdcontr53b","account":"Hotwire","email":"rshanbhogue@hotwire.com","lastLogin":1413822828000,"loginCountToday":1},{"id":2212,"controllerURL":"prdcontr10b","account":"customer1","email":"dcreswell@expedia.com","lastLogin":1409214433000,"loginCountToday":1},{"id":2441,"controllerURL":"prdcontr53a","account":"voyager","email":"a-mrafique@expedia.com","lastLogin":1409239834000,"loginCountToday":1},{"id":53303,"controllerURL":"prdcontr53a","account":"hotwire","email":"v-akadushko@hotwire.com","lastLogin":1415225403000,"loginCountToday":1},{"id":2531,"controllerURL":"prdcontr23a","account":"expediacore","email":"dsarver@expedia.com","lastLogin":1409239302000,"loginCountToday":1},{"id":67909,"controllerURL":"prdcontr53a","account":"Voyager","email":"nahuja@expedia.com","lastLogin":1416895970000,"loginCountToday":1},{"id":3254,"controllerURL":"prdcontr53a","account":"Voyager","email":"nocops@expedia.com","lastLogin":1409350755000,"loginCountToday":1},{"id":6779,"controllerURL":"prdcontr53b","account":"voyager","email":"torndorff@expedia.com","lastLogin":1409864482000,"loginCountToday":1},{"id":15332,"controllerURL":"prdcontr53b","account":"voyager","email":"svajpayee@expedia.com","lastLogin":1410776127000,"loginCountToday":1},{"id":17909,"controllerURL":"prdcontr53b","account":"hotwire","email":"honng@hotwire.com","lastLogin":1410985659000,"loginCountToday":1},{"id":19267,"controllerURL":"prdcontr31b","account":"bigbrother_egencia","email":"eucarteam@egencia.eu","lastLogin":1411116168000,"loginCountToday":1},{"id":29129,"controllerURL":"prdcontr10b","account":"customer1","email":"phari@expedia.com","lastLogin":1412241774000,"loginCountToday":1},{"id":1866,"controllerURL":"prdcontr19b","account":"hcom","email":"mmian@expedia.com","lastLogin":1409216600000,"loginCountToday":1},{"id":39556,"controllerURL":"prdcontr23a","account":"expediacore","email":"lelim@expedia.com","lastLogin":1413656188000,"loginCountToday":1},{"id":42958,"controllerURL":"prdcontr31b","account":"via_egencia","email":"monitoring@viaegencia.com","lastLogin":1414129302000,"loginCountToday":1},{"id":43912,"controllerURL":"prdcontr31b","account":"via_egencia","email":"alexander.schou@viaegencia.com","lastLogin":1414151800000,"loginCountToday":1},{"id":53301,"controllerURL":"prdcontr53a","account":"hotwire","email":"fportolano@hotwire.com","lastLogin":1415224284000,"loginCountToday":1},{"id":59034,"controllerURL":"prdcontr19a","account":"hcom","email":"gafry@expedia.com","lastLogin":1415890224000,"loginCountToday":1},{"id":3248,"controllerURL":"prdcontr53a","account":"Hotwire","email":"aguthrie@hotwire.com","lastLogin":1409333895000,"loginCountToday":1},{"id":4039,"controllerURL":"prdcontr31a","account":"bigbrother_egencia","email":"globalairteam@egencia.eu","lastLogin":1409574911000,"loginCountToday":1},{"id":6441,"controllerURL":"prdcontr31b","account":"bigbrother_egencia","email":"y.lachgar@egencia.fr","lastLogin":1409841784000,"loginCountToday":1},{"id":11083,"controllerURL":"prdcontr19b","account":"hcom","email":"tpflicke@expedia.com","lastLogin":1410391413000,"loginCountToday":1},{"id":14403,"controllerURL":"prdcontr53b","account":"voyager","email":"dchowdhury@expedia.com","lastLogin":1410596581000,"loginCountToday":1},{"id":17701,"controllerURL":"prdcontr10b","account":"customer1","email":"pdenning@expedia.com","lastLogin":1410987651000,"loginCountToday":1},{"id":19265,"controllerURL":"prdcontr31b","account":"bigbrother_egencia","email":"b.vrac@egencia.com","lastLogin":1411143980000,"loginCountToday":1},{"id":28690,"controllerURL":"prdcontr19b","account":"hcom","email":"witomlin@expedia.com","lastLogin":1412235122000,"loginCountToday":1},{"id":39188,"controllerURL":"prdcontr53b","account":"Voyager","email":"wantosz@expedia.com","lastLogin":1413575816000,"loginCountToday":1},{"id":2116,"controllerURL":"prdcontr31a","account":"via_egencia","email":"jankare.arnesen@viaegencia.com","lastLogin":1409210296000,"loginCountToday":1},{"id":42956,"controllerURL":"prdcontr31b","account":"via_egencia","email":"frode.molstad@viaegencia.com","lastLogin":1414130118000,"loginCountToday":1},{"id":43566,"controllerURL":"prdcontr53b","account":"voyager","email":"mravella@expedia.com","lastLogin":1414098942000,"loginCountToday":1},{"id":51649,"controllerURL":"prdcontr19a","account":"hcom","email":"kshrubb@expedia.com","lastLogin":1415131632000,"loginCountToday":1},{"id":2529,"controllerURL":"prdcontr23a","account":"expediacore","email":"askhan@expedia.com","lastLogin":1409216979000,"loginCountToday":1},{"id":57585,"controllerURL":"prdcontr53a","account":"voyager","email":"rsullivan@expedia.com","lastLogin":1415745037000,"loginCountToday":1},{"id":3106,"controllerURL":"prdcontr10b","account":"ean-test","email":"dhay@hotels.com","lastLogin":1409325210000,"loginCountToday":1},{"id":3922,"controllerURL":"prdcontr19b","account":"hcomNP","email":"vcanumalla@expedia.com","lastLogin":1409563716000,"loginCountToday":1},{"id":6440,"controllerURL":"prdcontr31b","account":"bigbrother_egencia","email":"pusharma@egencia.com","lastLogin":1409867570000,"loginCountToday":1},{"id":10783,"controllerURL":"prdcontr53b","account":"Voyager","email":"a-mahali@expedia.com","lastLogin":1410298580000,"loginCountToday":1},{"id":14158,"controllerURL":"prdcontr23a","account":"GIS","email":"mlindemnn@expedia.com","lastLogin":1410525775000,"loginCountToday":1},{"id":17250,"controllerURL":"prdcontr16a","account":"horus_egencia","email":"Maquillan","lastLogin":1410988441000,"loginCountToday":1},{"id":18900,"controllerURL":"prdcontr53b","account":"voyager","email":"mmurthy@expedia.com","lastLogin":1411096937000,"loginCountToday":1},{"id":23447,"controllerURL":"prdcontr16a","account":"horus_egencia","email":"hoteldev@expedia.com","lastLogin":1411630217000,"loginCountToday":1},{"id":28245,"controllerURL":"prdcontr10b","account":"customer1","email":"treidl@hotels.com","lastLogin":1412172917000,"loginCountToday":1},{"id":1864,"controllerURL":"prdcontr19b","account":"hcom","email":"elinington@expedia.com","lastLogin":1409214159000,"loginCountToday":1},{"id":36535,"controllerURL":"prdcontr53b","account":"GIS-IPS","email":"dweatherford@expedia.com","lastLogin":1413299403000,"loginCountToday":1},{"id":2115,"controllerURL":"prdcontr31a","account":"bigbrother_egencia","email":"o.martinez@egencia.com","lastLogin":1409255739000,"loginCountToday":1},{"id":43563,"controllerURL":"prdcontr53b","account":"Voyager","email":"akamath@expedia.com","lastLogin":1414093048000,"loginCountToday":1},{"id":2438,"controllerURL":"prdcontr53a","account":"hotwire","email":"v-rchepurnyi@hotwire.com","lastLogin":1409270827000,"loginCountToday":1},{"id":2528,"controllerURL":"prdcontr23a","account":"expediacore","email":"a-mtomandl@expedia.com","lastLogin":1409237694000,"loginCountToday":1},{"id":55191,"controllerURL":"prdcontr53a","account":"Hotwire","email":"sobanerjee@hotwire.com","lastLogin":1415399195000,"loginCountToday":1},{"id":2536,"controllerURL":"prdcontr23a","account":"expediacore","email":"sosharma@expedia.com","lastLogin":1409280514000,"loginCountToday":1},{"id":3105,"controllerURL":"prdcontr10b","account":"ean-test","email":"dhay@expedia.com","lastLogin":1409325210000,"loginCountToday":1},{"id":3919,"controllerURL":"prdcontr19b","account":"hcomNP","email":"dallison@expedia.com","lastLogin":1409593426000,"loginCountToday":1},{"id":6436,"controllerURL":"prdcontr31b","account":"bigbrother_egencia","email":"elllin@expedia.com","lastLogin":1409855046000,"loginCountToday":1},{"id":7640,"controllerURL":"prdcontr53b","account":"GIS-IPS","email":"kydavis@expedia.com","lastLogin":1409937234000,"loginCountToday":1},{"id":14157,"controllerURL":"prdcontr23a","account":"GIS","email":"mlindemann@expedia.com","lastLogin":1410525775000,"loginCountToday":1},{"id":17245,"controllerURL":"prdcontr19b","account":"hcom","email":"sconwayrahman@expedia.com","lastLogin":1410950014000,"loginCountToday":1},{"id":28244,"controllerURL":"prdcontr10b","account":"customer1","email":"treid@hotels.com","lastLogin":1412172917000,"loginCountToday":1},{"id":36340,"controllerURL":"prdcontr10b","account":"customer1","email":"madawson@expedia.com","lastLogin":1413293934000,"loginCountToday":1},{"id":2114,"controllerURL":"prdcontr31a","account":"bigbrother_egencia","email":"aryo@egencia.com","lastLogin":1409229541000,"loginCountToday":1},{"id":42556,"controllerURL":"prdcontr53b","account":"expedia_vci","email":"tgash@expedia.com","lastLogin":1414009275000,"loginCountToday":1},{"id":2216,"controllerURL":"prdcontr10b","account":"customer1","email":"jyoakum@hotels.com","lastLogin":1409257668000,"loginCountToday":1},{"id":2436,"controllerURL":"prdcontr53a","account":"expedia_ca","email":"lcdevw@expedia.com","lastLogin":1409260764000,"loginCountToday":1},{"id":49808,"controllerURL":"prdcontr53a","account":"VOYAGER","email":"a-hsimon@expedia.com","lastLogin":1414785566000,"loginCountToday":1},{"id":2446,"controllerURL":"prdcontr53a","account":"voyager","email":"rjones@expedia.com","lastLogin":1409262100000,"loginCountToday":1},{"id":54300,"controllerURL":"prdcontr53a","account":"voyager","email":"a-bjore@expedia.com","lastLogin":1415311736000,"loginCountToday":1},{"id":64454,"controllerURL":"prdcontr53a","account":"hotwire_CRG","email":"ahirekatur@hotwire.com","lastLogin":1416427250000,"loginCountToday":1},{"id":2792,"controllerURL":"prdcontr19b","account":"hcom","email":"smansourfarag@expedia.com","lastLogin":1409322844000,"loginCountToday":1},{"id":72238,"controllerURL":"prdcontr53a","account":"hotwire_CRG","email":"crprodan@expedia.com","lastLogin":1417470369000,"loginCountToday":1},{"id":4207,"controllerURL":"prdcontr53b","account":"expedia_vci","email":"bdeboer@expedia.com","lastLogin":1409592904000,"loginCountToday":1},{"id":7484,"controllerURL":"prdcontr10b","account":"customer1","email":"lbyers@hotels.com","lastLogin":1409934108000,"loginCountToday":1},{"id":14109,"controllerURL":"prdcontr53b","account":"hotwire_CRG","email":"v-rajgupta@hotwire.com","lastLogin":1410544449000,"loginCountToday":1},{"id":18676,"controllerURL":"prdcontr10b","account":"customer1","email":"akor@expedia.com","lastLogin":1411059370000,"loginCountToday":1},{"id":22140,"controllerURL":"prdcontr53b","account":"Hotwire","email":"rzhilkibaev@hotwire.com","lastLogin":1411510267000,"loginCountToday":1},{"id":35478,"controllerURL":"prdcontr53b","account":"hotwire","email":"prbhat@expedia.com","lastLogin":1413239118000,"loginCountToday":1},{"id":41898,"controllerURL":"prdcontr16b","account":"horus_egencia","email":"o.klarman@egencia.com","lastLogin":1413970439000,"loginCountToday":1},{"id":2215,"controllerURL":"prdcontr10b","account":"customer1","email":"jyoakum@expedia.com","lastLogin":1409257668000,"loginCountToday":1},{"id":43399,"controllerURL":"prdcontr10b","account":"Customer1","email":"stpitts@expedial.com","lastLogin":1414076813000,"loginCountToday":1},{"id":2435,"controllerURL":"prdcontr53a","account":"expedia_ca","email":"cnstruct@expedia.com","lastLogin":1409241472000,"loginCountToday":1},{"id":47602,"controllerURL":"prdcontr10b","account":"ean-test","email":"rasvan.vuscan@xoomworks.com","lastLogin":1414590083000,"loginCountToday":1},{"id":2445,"controllerURL":"prdcontr53a","account":"voyager","email":"mpopescu@expedia.com","lastLogin":1409209603000,"loginCountToday":1},{"id":54298,"controllerURL":"prdcontr53a","account":"hotwire","email":"vbokka@hotwire.com","lastLogin":1415301155000,"loginCountToday":1},{"id":64450,"controllerURL":"prdcontr53a","account":"expedia_vci","email":"rhilfers@expedia.com","lastLogin":1416422730000,"loginCountToday":1},{"id":3914,"controllerURL":"prdcontr19b","account":"hcom","email":"bestokes@expedia.com","lastLogin":1409579679000,"loginCountToday":1},{"id":7135,"controllerURL":"prdcontr16a","account":"horus_egencia","email":"ellin@egencia.com","lastLogin":1409955820000,"loginCountToday":1},{"id":13030,"controllerURL":"prdcontr10b","account":"ean-test","email":"andrei.iacob@xoomworks.com","lastLogin":1410451740000,"loginCountToday":1},{"id":18675,"controllerURL":"prdcontr10b","account":"customer1","email":"aklor@expedia.com","lastLogin":1411059370000,"loginCountToday":1},{"id":34724,"controllerURL":"prdcontr23a","account":"GIS","email":"istanding@expedia.com","lastLogin":1412849097000,"loginCountToday":1},{"id":1876,"controllerURL":"prdcontr16a","account":"horus_egencia","email":"snakhawa@expedia.com","lastLogin":1409263786000,"loginCountToday":1},{"id":2214,"controllerURL":"prdcontr10b","account":"Customer1","email":"eanhdsup@expedia.com","lastLogin":1409220047000,"loginCountToday":1},{"id":43398,"controllerURL":"prdcontr10b","account":"Customer1","email":"stpitts@expedia.com","lastLogin":1414076813000,"loginCountToday":1},{"id":2237,"controllerURL":"prdcontr78a","account":"LPMS_Gaia","email":"dphillips@expedia.com","lastLogin":1409237430000,"loginCountToday":1},{"id":2444,"controllerURL":"prdcontr53a","account":"voyager","email":"hbansal@expedia.com","lastLogin":1409209264000,"loginCountToday":1},{"id":54297,"controllerURL":"prdcontr53a","account":"Hotwire","email":"v-vsukhomlinov@hotwire.com","lastLogin":1415310369000,"loginCountToday":1},{"id":64447,"controllerURL":"prdcontr53a","account":"atlab","email":"thossain@expedia.com","lastLogin":1416435321000,"loginCountToday":1},{"id":68815,"controllerURL":"prdcontr10a","account":"customer1","email":"tdeas@expedia.com","lastLogin":1416933948000,"loginCountToday":1},{"id":3698,"controllerURL":"prdcontr31a","account":"bigbrother_egencia","email":"jchawla@expedia.com","lastLogin":1409552160000,"loginCountToday":1},{"id":7112,"controllerURL":"prdcontr19b","account":"hcom","email":"mshursen@expedia.com","lastLogin":1409941334000,"loginCountToday":1},{"id":10518,"controllerURL":"prdcontr10b","account":"Customer1","email":"ejelinek@expedia.com","lastLogin":1410296014000,"loginCountToday":1},{"id":12921,"controllerURL":"prdcontr31b","account":"bigbrother_egencia","email":"team-supervision@egencia.eu","lastLogin":1410491055000,"loginCountToday":1},{"id":17920,"controllerURL":"prdcontr53b","account":"voyager","email":"pmalhotra@expedia.com","lastLogin":1411018689000,"loginCountToday":1},{"id":20961,"controllerURL":"prdcontr10b","account":"customer1","email":"sehardy@expedia.com","lastLogin":1411421986000,"loginCountToday":1},{"id":34314,"controllerURL":"prdcontr10b","account":"customer1","email":"damyers@expedia.com","lastLogin":1412878519000,"loginCountToday":1},{"id":1875,"controllerURL":"prdcontr16a","account":"horus_egencia","email":"egnmobbl@expedia.com","lastLogin":1409268235000,"loginCountToday":1}]
	
	/*
	 * 
	 */
	public class LoginStat extends PortalGenericMap{
		public String id {get;
			set{
				id = value;
				setValue('ID',value);
			}
		}
		public String controllerURL {get;
			set{
				controllerURL = value;
				setValue('Controller URL',value);
			}
		}
		public String account {get;
			set{
				account = value;
				setValue('Account',value);
			}
		}
		public String name {get;
			set{
				name = value;
				setValue('Name',value);
			}
		}
		public Long lastLogin {get;
			set{
				lastLogin = value;
				setValue('Last Login',Datetime.newInstance(value).format());
			}
		}
		
		public Long loginCountToday {get;
			set{
				loginCountToday = value;
				setValue('Login Count',value);
			}
		}
	}
	
	
	/*public class LicenseUsageUI extends PortalGenericMap{
		
		public String timestamp {get;
			set{
				timestamp = value;
				setValue('Usage Time',value);
			}
		}
		
		public Double javaCount{
			get{
				if(javaCount==Null){
					return 0.0;
				}
				return javaCount;
			}
			set{
				javaCount = value;
				setValue('Java Units Used',value);
			}
		}
		public Double javaProvisioned{
			get{
				if(javaProvisioned==Null){
					return 0.0;
				}
				return javaProvisioned;
			}
			set{
				javaProvisioned = value;
				setValue('Java Units Provisioned',value);
			}
		}
		
		
		public Double dotNetCount{
			get{
				if(dotNetCount==Null){
					return 0.0;
				}
				return dotNetCount;
			}
			set{
				dotNetCount = value;
				setValue('.Net Units Used',value);
			}
		}
		public Double dotNetProvisioned{
			get{
				if(dotNetProvisioned==Null){
					return 0.0;
				}
				return dotNetProvisioned;
			}
			set{
				dotNetProvisioned = value;
				setValue('.Net Units Provisioned',value);
			}
		}
		
		public Double phpCount{
			get{
				if(phpCount==Null){
					return 0.0;
				}
				return phpCount;
			}
			set{
				phpCount = value;
				setValue('PHP Units Used',value);
			}
		}
		public Double phpProvisioned{
			get{
				if(phpProvisioned==Null){
					return 0.0;
				}
				return phpProvisioned;
			}
			set{
				phpProvisioned = value;
				setValue('PHP Units Provisioned',value);
			}
		}
		
		public Double dbCount{
			get{
				if(dbCount==Null){
					return 0.0;
				}
				return dbCount;
			}
			set{
				dbCount = value;
				setValue('Database Units Used',value);
			}
		}
		public Double dbProvisioned{
			get{
				if(dbProvisioned==Null){
					return 0.0;
				}
				return dbProvisioned;
			}
			set{
				dbProvisioned = value;
				setValue('Database Units Provisioned',value);
			}
		}
		
		public Double nodeJsCount{
			get{
				if(nodeJsCount==Null){
					return 0.0;
				}
				return nodeJsCount;
			}
			set{
				nodeJsCount = value;
				setValue('NodeJs Units Used',value);
			}
		}
		public Double nodeJsProvisioned{
			get{
				if(nodeJsProvisioned==Null){
					return 0.0;
				}
				return nodeJsProvisioned;
			}
			set{
				nodeJsProvisioned = value;
				setValue('NodeJs Units Provisioned',value);
			}
		}
		
		
		public Double machineCount{
			get{
				if(machineCount==Null){
					return 0.0;
				}
				return machineCount;
			}
			set{
				machineCount = value;
				setValue('Machine Units Used',value);
			}
		}
		public Double machineProvisioned{
			get{
				if(machineProvisioned==Null){
					return 0.0;
				}
				return machineProvisioned;
			}
			set{
				machineProvisioned = value;
				setValue('Machine Units Provisioned',value);
			}
		}
		
		
		public Double webEUMCount{
			get{
				if(webEUMCount==Null){
					return 0.0;
				}
				return webEUMCount;
			}
			set{
				webEUMCount = value;
				setValue('Web EUM Units Used',value);
			}
		}
		public Double webEUMProvisioned{
			get{
				if(webEUMProvisioned==Null){
					return 0.0;
				}
				return webEUMProvisioned;
			}
			set{
				webEUMProvisioned = value;
				setValue('Web EUM Units Provisioned',value);
			}
		}
		
		
		public Double mobileEUMCount{
			get{
				if(mobileEUMCount==Null){
					return 0.0;
				}
				return mobileEUMCount;
			}
			set{
				mobileEUMCount = value;
				setValue('Mobile EUM Units Used',value);
			}
		}
		public Double mobileEUMProvisioned{
			get{
				if(mobileEUMProvisioned==Null){
					return 0.0;
				}
				return mobileEUMProvisioned;
			}
			set{
				mobileEUMProvisioned = value;
				setValue('Mobile EUM Units Provisioned',value);
			}
		}

		public LicenseUsageUI(LicenseUsage usageFromBackend){
			this.timestamp = usageFromBackend.timestamp;
			if(usageFromBackend.agents!=null){
				if(usageFromBackend.agents.java!=null){
					this.javaCount = usageFromBackend.agents.java.count;
					this.javaProvisioned = usageFromBackend.agents.java.provisioned;
				}else{
					this.javaCount = 0.0;
					this.javaProvisioned = 0.0;
				}
				this.dotNetCount = (usageFromBackend.agents.dotnet!=null)?usageFromBackend.agents.dotnet.count:0.0;
				this.dotNetProvisioned = (usageFromBackend.agents.dotnet!=null)?usageFromBackend.agents.dotnet.provisioned:0.0;
				
				this.phpCount = (usageFromBackend.agents.php!=null)?usageFromBackend.agents.php.count:0.0;
				this.phpProvisioned = (usageFromBackend.agents.php!=null)?usageFromBackend.agents.php.provisioned:0.0;	
				
				this.nodejsCount = (usageFromBackend.agents.nodejs!=null)?usageFromBackend.agents.nodejs.count:0.0;
				this.nodejsProvisioned = (usageFromBackend.agents.nodejs!=null)?usageFromBackend.agents.nodejs.provisioned:0.0;
				
				this.dbCount = (usageFromBackend.agents.database!=null)?usageFromBackend.agents.database.count:0.0;
				this.dbProvisioned = (usageFromBackend.agents.database!=null)?usageFromBackend.agents.database.provisioned:0.0;
				
				this.machineCount = (usageFromBackend.agents.machine!=null)?usageFromBackend.agents.machine.count:0.0;
				this.machineProvisioned = (usageFromBackend.agents.machine!=null)?usageFromBackend.agents.machine.provisioned:0.0;
				
				this.webEumCount = (usageFromBackend.agents.web_eum!=null)?usageFromBackend.agents.web_eum.count:0.0;
				this.webEumProvisioned = (usageFromBackend.agents.web_eum!=null)?usageFromBackend.agents.web_eum.provisioned:0.0;
				
				this.mobileEUMCount = (usageFromBackend.agents.mobile_eum!=null)?usageFromBackend.agents.mobile_eum.count:0.0;
				this.mobileEUMCount = (usageFromBackend.agents.mobile_eum!=null)?usageFromBackend.agents.mobile_eum.count:0.0;
			}
			
			this.columnNames=new String[]{'Usage Time',
											'Java Units Used','Java Units Provisioned',
											'.Net Units Used','.Net Units Provisioned',
											'PHP Units Used','PHP Units Provisioned',
											'NodeJs Units Used','NodeJs Units Provisioned'
											};
			if(this.javaProvisioned == 0 && this.dotNetProvisioned==0 && this.nodeJsProvisioned==0){
				throw new ValidatorUtil.ValidationException('No Usage Data');
			}
		}
		
		public Boolean hasData{
			get{
				return javaProvisioned!=0.0 || dotNetProvisioned!=0.0 || phpProvisioned!=0.0 || dbProvisioned!=0.0 || nodeJsProvisioned!=0.0;	
			}
		}
	}
	*/
	
	//[{"timestamp": "2014-11-07T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-07T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-08T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-09T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-10T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-11T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-12T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-13T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-14T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-15T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-16T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-17T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-18T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-19T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-20T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-21T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-22T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-23T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-24T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-25T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-26T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-27T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-28T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-29T23:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T00:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T01:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T02:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T03:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T04:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T05:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T06:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T07:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T08:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T09:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T10:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T11:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T12:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T13:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T14:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T15:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T16:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T17:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T18:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T19:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T20:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T21:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T22:00:00Z", "agents": {}}, {"timestamp": "2014-11-30T23:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T00:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T01:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T02:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T03:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T04:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T05:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T06:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T07:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T08:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T09:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T10:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T11:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T12:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T13:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T14:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T15:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T16:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T17:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T18:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T19:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T20:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T21:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T22:00:00Z", "agents": {}}, {"timestamp": "2014-12-01T23:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T00:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T01:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T02:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T03:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T04:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T05:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T06:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T07:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T08:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T09:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T10:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T11:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T12:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T13:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T14:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T15:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T16:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T17:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T18:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T19:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T20:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T21:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T22:00:00Z", "agents": {}}, {"timestamp": "2014-12-02T23:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T00:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T01:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T02:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T03:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T04:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T05:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T06:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T07:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T08:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T09:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T10:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T11:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T12:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T13:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T14:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T15:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T16:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T17:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T18:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T19:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T20:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T21:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T22:00:00Z", "agents": {}}, {"timestamp": "2014-12-03T23:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T00:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T01:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T02:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T03:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T04:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T05:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T06:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T07:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T08:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T09:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T10:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T11:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T12:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T13:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T14:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T15:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T16:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T17:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T18:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T19:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T20:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T21:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T22:00:00Z", "agents": {}}, {"timestamp": "2014-12-04T23:00:00Z", "agents": {"log_analytics": {"count": 0.0, "provisioned": 100}, "transaction_analytics": {"count": 0.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T00:00:00Z", "agents": {"log_analytics": {"count": 0.0, "provisioned": 100}, "transaction_analytics": {"count": 0.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T01:00:00Z", "agents": {"java": {"count": 0, "provisioned": 10}, "nodejs": {"count": 0, "provisioned": 10}, "log_analytics": {"count": 0.0, "provisioned": 100}, "database": {"count": 0, "provisioned": 10}, "machine": {"count": 0, "provisioned": 10}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}, "transaction_analytics": {"count": 0.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T02:00:00Z", "agents": {"java": {"count": 0, "provisioned": 10}, "nodejs": {"count": 0, "provisioned": 10}, "log_analytics": {"count": 0.0, "provisioned": 100}, "database": {"count": 0, "provisioned": 10}, "machine": {"count": 0, "provisioned": 10}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}, "transaction_analytics": {"count": 0.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T03:00:00Z", "agents": {"java": {"count": 0, "provisioned": 10}, "nodejs": {"count": 0, "provisioned": 10}, "log_analytics": {"count": 0.0, "provisioned": 100}, "database": {"count": 0, "provisioned": 10}, "machine": {"count": 0, "provisioned": 10}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}, "transaction_analytics": {"count": 0.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T04:00:00Z", "agents": {"java": {"count": 0, "provisioned": 10}, "nodejs": {"count": 0, "provisioned": 10}, "log_analytics": {"count": 0.0, "provisioned": 100}, "database": {"count": 0, "provisioned": 10}, "machine": {"count": 0, "provisioned": 10}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}, "transaction_analytics": {"count": 0.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T05:00:00Z", "agents": {"java": {"count": 0, "provisioned": 10}, "nodejs": {"count": 0, "provisioned": 10}, "log_analytics": {"count": 0.0, "provisioned": 100}, "database": {"count": 0, "provisioned": 10}, "machine": {"count": 0, "provisioned": 10}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}, "transaction_analytics": {"count": 0.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T06:00:00Z", "agents": {"java": {"count": 0, "provisioned": 10}, "nodejs": {"count": 0, "provisioned": 10}, "log_analytics": {"count": 0.0, "provisioned": 100}, "database": {"count": 0, "provisioned": 10}, "machine": {"count": 0, "provisioned": 10}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}, "transaction_analytics": {"count": 0.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T07:00:00Z", "agents": {"java": {"count": 0, "provisioned": 10}, "nodejs": {"count": 0, "provisioned": 10}, "log_analytics": {"count": 0.0, "provisioned": 100}, "database": {"count": 0, "provisioned": 10}, "machine": {"count": 0, "provisioned": 10}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}, "transaction_analytics": {"count": 0.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T08:00:00Z", "agents": {"java": {"count": 0, "provisioned": 10}, "nodejs": {"count": 0, "provisioned": 10}, "log_analytics": {"count": 0.0, "provisioned": 100}, "database": {"count": 0, "provisioned": 10}, "machine": {"count": 0, "provisioned": 10}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}, "transaction_analytics": {"count": 0.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T09:00:00Z", "agents": {"java": {"count": 0, "provisioned": 10}, "nodejs": {"count": 0, "provisioned": 10}, "log_analytics": {"count": 0.0, "provisioned": 100}, "database": {"count": 0, "provisioned": 10}, "machine": {"count": 0, "provisioned": 10}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}, "transaction_analytics": {"count": 0.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T10:00:00Z", "agents": {"java": {"count": 0, "provisioned": 10}, "nodejs": {"count": 0, "provisioned": 10}, "log_analytics": {"count": 0.0, "provisioned": 100}, "database": {"count": 0, "provisioned": 10}, "machine": {"count": 0, "provisioned": 10}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}, "transaction_analytics": {"count": 0.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T11:00:00Z", "agents": {"java": {"count": 0, "provisioned": 10}, "nodejs": {"count": 0, "provisioned": 10}, "log_analytics": {"count": 0.0, "provisioned": 100}, "database": {"count": 0, "provisioned": 10}, "machine": {"count": 0, "provisioned": 10}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}, "transaction_analytics": {"count": 0.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T12:00:00Z", "agents": {"java": {"count": 0, "provisioned": 10}, "nodejs": {"count": 0, "provisioned": 10}, "log_analytics": {"count": 0.0, "provisioned": 100}, "database": {"count": 0, "provisioned": 10}, "machine": {"count": 0, "provisioned": 10}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}, "transaction_analytics": {"count": 0.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T13:00:00Z", "agents": {"java": {"count": 0, "provisioned": 10}, "nodejs": {"count": 0, "provisioned": 10}, "log_analytics": {"count": 0.0, "provisioned": 100}, "database": {"count": 0, "provisioned": 10}, "machine": {"count": 0, "provisioned": 10}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}, "transaction_analytics": {"count": 0.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T14:00:00Z", "agents": {"java": {"count": 0, "provisioned": 10}, "nodejs": {"count": 0, "provisioned": 10}, "log_analytics": {"count": 0.0, "provisioned": 100}, "database": {"count": 0, "provisioned": 10}, "machine": {"count": 0, "provisioned": 10}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}, "transaction_analytics": {"count": 0.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T15:00:00Z", "agents": {"java": {"count": 0, "provisioned": 10}, "nodejs": {"count": 0, "provisioned": 10}, "log_analytics": {"count": 0.0, "provisioned": 100}, "database": {"count": 0, "provisioned": 10}, "machine": {"count": 0, "provisioned": 10}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}, "transaction_analytics": {"count": 0.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T16:00:00Z", "agents": {"java": {"count": 0, "provisioned": 10}, "nodejs": {"count": 0, "provisioned": 10}, "log_analytics": {"count": 0.0, "provisioned": 100}, "database": {"count": 0, "provisioned": 10}, "machine": {"count": 0, "provisioned": 10}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}, "transaction_analytics": {"count": 0.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T17:00:00Z", "agents": {"java": {"count": 0, "provisioned": 10}, "nodejs": {"count": 0, "provisioned": 10}, "database": {"count": 0, "provisioned": 10}, "machine": {"count": 0, "provisioned": 10}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}}}, {"timestamp": "2014-12-05T18:00:00Z", "agents": {"java": {"count": 0, "provisioned": 10}, "nodejs": {"count": 0, "provisioned": 10}, "log_analytics": {"count": 0.005, "provisioned": 100}, "database": {"count": 0, "provisioned": 10}, "machine": {"count": 0, "provisioned": 10}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}, "transaction_analytics": {"count": 35308.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T19:00:00Z", "agents": {"java": {"count": 1, "provisioned": 10}, "nodejs": {"count": 5, "provisioned": 10}, "log_analytics": {"count": 0.01, "provisioned": 100}, "database": {"count": 3, "provisioned": 10}, "machine": {"count": 1, "provisioned": 10}, "mobile_eum": {"count": 0.0, "provisioned": 75}, "web_eum": {"count": 0.0, "provisioned": 875000000}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}, "transaction_analytics": {"count": 69851.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T20:00:00Z", "agents": {"java": {"count": 1, "provisioned": 10}, "nodejs": {"count": 5, "provisioned": 10}, "log_analytics": {"count": 0.01, "provisioned": 100}, "database": {"count": 3, "provisioned": 10}, "machine": {"count": 1, "provisioned": 10}, "mobile_eum": {"count": 0.0, "provisioned": 100}, "web_eum": {"count": 0.0, "provisioned": 1000000000}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}, "transaction_analytics": {"count": 69918.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T21:00:00Z", "agents": {"java": {"count": 1, "provisioned": 10}, "nodejs": {"count": 5, "provisioned": 10}, "log_analytics": {"count": 0.01, "provisioned": 100}, "database": {"count": 3, "provisioned": 10}, "machine": {"count": 1, "provisioned": 10}, "mobile_eum": {"count": 0.0, "provisioned": 100}, "web_eum": {"count": 0.0, "provisioned": 1000000000}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}, "transaction_analytics": {"count": 69908.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T22:00:00Z", "agents": {"java": {"count": 1, "provisioned": 10}, "nodejs": {"count": 5, "provisioned": 10}, "log_analytics": {"count": 0.01, "provisioned": 100}, "database": {"count": 3, "provisioned": 10}, "machine": {"count": 1, "provisioned": 10}, "mobile_eum": {"count": 0.0, "provisioned": 100}, "web_eum": {"count": 0.0, "provisioned": 1000000000}, "dotnet": {"count": 0, "provisioned": 10}, "php": {"count": 0, "provisioned": 10}, "transaction_analytics": {"count": 69815.0, "provisioned": 100}}}, {"timestamp": "2014-12-05T23:00:00Z", "agents": {"java": {"count": 1, "provisioned": 10}, "nodejs": {"count": 5, "provisioned": 10}, "database": {"count": 3, "provisioned": 7}, "machine": {"count": 2, "provisioned": 7}, "mobile_eum": {"count": 0.0, "provisioned": 100}, "web_eum": {"count": 348.0, "provisioned": 1000000000}, "dotnet": {"count": 1, "provisioned": 7}, "php": {"count": 0, "provisioned": 10}}}]
	
	/*
	 * 
	 */
	/*public class LicenseUsage extends PortalGenericMap{
		public String timestamp {get;
			set{
				timestamp = value;
				setValue('Usage Time',value);
			}
		}
		public LicenseUsageAgents agents {get;
			set{
				agents = value;
				setValue('Agent Usage Data',value);
			}
		}
		/*public override list<String> keySet(){
			return new String[]{
								'Usage Time',
								'Agent Usage Data'
							};
		}*/
	/*}*/
	
	//"agents": {"java": {"count": 1, "provisioned": 10}, "nodejs": {"count": 5, "provisioned": 10}, "database": {"count": 3, "provisioned": 7}, "machine": {"count": 2, "provisioned": 7}, "mobile_eum": {"count": 0.0, "provisioned": 100}, "web_eum": {"count": 348.0, "provisioned": 1000000000}, "dotnet": {"count": 1, "provisioned": 7}, "php": {"count": 0, "provisioned": 10}}}]
	/*public class LicenseUsageAgents extends PortalGenericMap{
		public LicenseUsageAgentUsageData java {get;
			set{
				java = value;
				setValue('Java',value);
			}
		}
		public LicenseUsageAgentUsageData nodejs {get;
			set{
				nodejs = value;
				setValue('NodeJs',value);
			}
		}
		public LicenseUsageAgentUsageData database {get;
			set{
				database = value;
				setValue('NodeJs',value);
			}
		}
		
		public LicenseUsageAgentUsageData machine {get;
			set{
				machine = value;
				setValue('Machine',value);
			}
		}
		public LicenseUsageAgentUsageData mobile_eum {get;
			set{
				mobile_eum = value;
				setValue('Mobile EUM',value);
			}
		}
		public LicenseUsageAgentUsageData web_eum {get;
			set{
				web_eum = value;
				setValue('Web EUM',value);
			}
		}
		public LicenseUsageAgentUsageData dotnet {get;
			set{
				dotnet = value;
				setValue('.Net',value);
			}
		}
		public LicenseUsageAgentUsageData php {get;
			set{
				php = value;
				setValue('PHP',value);
			}
		}
		/*public override list<String> keySet(){
			return new String[]{
								'Java',
								'.Net',
								'PHP',
								'NodeJs',
								'Database',
								'Mobile EUM',
								'Web EUM',
								'Machine'
							};
		}*/
	/*}*/
	
	//{"count": 1, "provisioned": 10}
	/*public class LicenseUsageAgentUsageData extends PortalGenericMap{
		public Double count{get;
			set{
				count = value;
				setValue('Units Used',value);
			}
		}
		public Double provisioned{get;
			set{
				provisioned = value;
				setValue('Units Provisioned',value);
			}
		}
	}*/
	
	
	/*public class LicenseStats extends PortalGenericMap{
		public String id{get;
			set{
				id = value;
				setValue('ID',value);
			}
		}
		public String portal_id{get;
			set{
				portal_id = value;
				setValue('portal_id',value);
			}
		}
		
		public String deployment{get;
			set{
				deployment = value;
				setValue('Deployment Option',value);
			}
		}
		
		public String stage{get;
			set{
				stage = value;
				setValue('Stage',value);
			}
		}
		
		public String expiration_date{get;
			set{
				expiration_date = value;
				setValue('Expiration Date',value);
			}
		}
		
		public String saas_url{get;
			set{
				saas_url = value;
				setValue('SAAS URL',value);
			}
		}
		
		public String saas_account{get;
			set{
				saas_account = value;
				setValue('SAAS Account',value);
			}
		}
		
		public String mac_address{get;
			set{
				mac_address = value;
				setValue('MAC Address',value);
			}
		}
		
		public Decimal java{get;
			set{
				java = value;
				setValue('# of Java Units',value);
			}
		}
		
		public Decimal dot_net{get;
			set{
				dot_net = value;
				setValue('# of .Net Units',value);
			}
		}
		
		public Decimal php{get;
			set{
				php = value;
				setValue('# of PHP Units',value);
			}
		}
		
		public Decimal nodejs{get;
			set{
				nodejs = value;
				setValue('# of NodeJs Units',value);
			}
		}
		
		public Decimal database{get;
			set{
				database = value;
				setValue('# of Database Units',value);
			}
		}
		
		public Decimal machine{get;
			set{
				machine = value;
				setValue('# of Machine Units',value);
			}
		}
		
		public LicenseStats(LicenseDetail__c lic){
			id = lic.Id;
			portal_id = lic.License_BackendID__c;
			deployment = lic.Product_Type__c;
			stage = lic.Stage__c;
			expiration_date = String.valueOf(lic.License_Expiry_Date__c);
			saas_url = lic.Custom_URL_Name__c;
			saas_account = lic.SaaS_Account__c;
			mac_address = lic.Mac_Address__c;
			Decimal total_count = 0;
			for(License_Agent__c licAgent:lic.License_Agents__r){
				if('Java'.equals(licAgent.Agent_Type__c)){
					java = licAgent.Count__c;
					total_count += licAgent.Count__c;
				}else if('.Net'.equals(licAgent.Agent_Type__c)){
					dot_net = licAgent.Count__c;
					total_count += licAgent.Count__c;
				}else if('PHP'.equals(licAgent.Agent_Type__c)){
					php = licAgent.Count__c;
					total_count += licAgent.Count__c;
				}else if('NodeJs'.equals(licAgent.Agent_Type__c)){
					nodejs = licAgent.Count__c;
					total_count += licAgent.Count__c;
				}else if('Database'.equals(licAgent.Agent_Type__c)){
					database = licAgent.Count__c;
				}else if('Machine'.equals(licAgent.Agent_Type__c)){
					total_count += licAgent.Count__c;
				}
			}
			machine = total_count;
		}
	}*/
}