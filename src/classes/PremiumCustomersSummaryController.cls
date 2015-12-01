public with sharing class PremiumCustomersSummaryController {
	public static final String ALL = 'all';
	public static final String LAST3='last3';
	public static final String LAST6='last6';
	public static final String LAST6PLUS='6plus';
	public String query{get;set;}
	
	public String startDate{get;set;}
	public String endDate{get;set;}
	
	public Boolean showTrackingStatus{get;set;}
	public String trackingStatus{get;set;}
	public Boolean showAdoptionLevel2Percentage{get;set;}
	public String adoptionLevel2PlusPercentage{get;set;}
	public Boolean showAdoptionLevel3Percentage{get;set;}
	public String adoptionLevel3PlusPercentage{get;set;}
	public String pageTitleSuffix{get;set;}

	public PremiumCustomersSummaryController(){
	}
	
	private Boolean currentYear;
	public Boolean getCurrentYear(){
		return currentYear;
	}
	public void setCurrentYear(Boolean currentYear){
		this.currentYear = currentYear;
	}
	
	private String duration;
	public String getDuration(){
		return duration;
	}
	public void setDuration(String duration){
		this.duration = duration;
	}
	
	private Boolean refreshData;
	public Boolean getRefreshData(){
		return refreshData;
	}
	public void setRefreshData(Boolean refreshData){
		this.refreshData = refreshData;
		if(refreshData){
			reload();			
		}
	}
	
	public void reload(){
		String whereCondition=' Technical_Account_Manager__c!=null and Adoption_Score__c!=null and Support_Level__c !=\'Blue\' and Type IN (\'Customer\',\'Target Account\')';
		
		//if(currentYear){
			whereCondition +=' AND USD_SUM_Amount__c>=250000.00 ';
		//}
		pageTitleSuffix='';
		if(!ALL.equals(duration)){
			whereCondition +=' AND ';
			
			if(LAST3.equals(duration)){
				if(currentYear){
					if(startDate!=null && endDate!=null){
						pageTitleSuffix = 'from: '+startDate+' to: '+endDate;
						whereCondition+=' Date_TAM_Assigned_to_Account__c>'+startDate+ ' AND Date_TAM_Assigned_to_Account__c < '+endDate;
					}else{
						whereCondition+='Date_TAM_Assigned_to_Account__c>2014-01-31 AND Date_TAM_Assigned_to_Account__c < 2014-05-01';
					}
				}else{
					whereCondition+='Date_TAM_Assigned_to_Account__c=LAST_90_DAYS';
				}
				
			}else if(LAST6.equals(duration)){
				if(currentYear){
					if(startDate!=null){
						pageTitleSuffix = ' before: '+startDate;
						whereCondition+='Date_TAM_Assigned_to_Account__c<'+startDate;	
					}else{
						whereCondition+='Date_TAM_Assigned_to_Account__c<2014-02-01';
					}
				}else{
					whereCondition+='Date_TAM_Assigned_to_Account__c<LAST_90_DAYS';
				}
			}
		}else{
			if(currentYear){
				if(endDate!=null){
					pageTitleSuffix = ' upto : '+endDate;
					whereCondition+=' AND Date_TAM_Assigned_to_Account__c<'+endDate;	
				}else{
					whereCondition+=' AND Date_TAM_Assigned_to_Account__c<2014-02-01';
				}
			}else{
				whereCondition+=' AND Date_TAM_Assigned_to_Account__c<TODAY';
			}
		}
		query = 'SELECT Date_TAM_Assigned_to_Account__c, Support_Level__c,Adoption_Score__c,Name,Technical_Account_Manager__c,NEW_CUSTOMER_ACQUISITION_DATE__c from Account ';
		if(!whereCondition.equals('')){
			query+=' WHERE '+whereCondition;
		}
		System.debug(query);
		try{
			supportLevelAdoptionLevelCountMap = new map<String,map<Integer,Integer>>{
				'Diamond'=> new map<integer,integer>{
					0 => 0,
					1 => 0,
					2 => 0,
					3 => 0
				},'Gold'=> new map<integer,integer>{
					0 => 0,
					1 => 0,
					2 => 0,
					3 => 0
				},'Platinum'=> new map<integer,integer>{
					0 => 0,
					1 => 0,
					2 => 0,
					3 => 0
				},'Total'=> new map<integer,integer>{
					0 => 0,
					1 => 0,
					2 => 0,
					3 => 0
				}
			};
			
			list<SObject> sobjects = Database.query(query);
			for(SObject obj:sobjects){
				Account acc = (Account) obj;
				for(String supportLevel:premiumLevelsSupported){
					Map<Integer,Integer> adoptionLevelCountMap = supportLevelAdoptionLevelCountMap.get(supportLevel);
					if(adoptionLevelCountMap==null){
						adoptionLevelCountMap = new Map<Integer,Integer>();
					}
					if(supportLevel.equals(acc.Support_Level__c)){
						double adoptionScore = acc.Adoption_Score__c;
						integer adoptionScoreInt = (integer) adoptionScore;
						integer adoptionlevelCount = adoptionLevelCountMap.get(adoptionScoreInt);
						if(adoptionlevelCount==null || adoptionlevelcount==0){
							adoptionlevelCount=0;
						}
						adoptionlevelCount++;
						adoptionLevelCountMap.put(adoptionScoreInt,adoptionlevelCount);
					}
				}
			}
			
			
			integer totalLevel0=0;
			integer totalLevel1=0;
			integer totalLevel2=0;
			integer totalLevel3=0;
			for(String supportLevel:premiumLevelsSupported){
				totalLevel0+=supportLevelAdoptionLevelCountMap.get(supportLevel).get(0);
				totalLevel1+=supportLevelAdoptionLevelCountMap.get(supportLevel).get(1);
				totalLevel2+=supportLevelAdoptionLevelCountMap.get(supportLevel).get(2);
				totalLevel3+=supportLevelAdoptionLevelCountMap.get(supportLevel).get(3);
			}
			
			integer totalAccounts = totalLevel0+totalLevel1+totalLevel2+totalLevel3;
			
			
			double percentage2Plus = 0;
			double percentage3Plus = 0;

			if(totalAccounts!=0){
				percentage2Plus = ((totalLevel2)*100/totalAccounts);
				percentage3Plus = ((totalLevel3)*100/totalAccounts);
			}
			
			adoptionLevel2PlusPercentage = percentage2Plus+' % ('+totalLevel2+'/'+ totalAccounts+')';
			adoptionLevel3PlusPercentage = percentage3Plus+' % ('+totalLevel3+'/'+ totalAccounts+')';
			
			showTrackingStatus = false;
			showAdoptionLevel2Percentage=true;
			showAdoptionLevel3Percentage=true;
			trackingStatus='Normal';
			if(LAST3.equals(duration)){
				showTrackingStatus=true;
				if(percentage2Plus<50.0){
					trackingStatus = 'Critical';
				}
			}else if(LAST6.equals(duration)){
				showTrackingStatus=true;
				if(percentage2Plus<75.0 && percentage3Plus<20.0){
					trackingStatus = 'Critical';
				}
			}
			
			supportLevelAdoptionLevelCountMap.put('Total',new map<integer,integer>{
					0 => totalLevel0,
					1 => totalLevel1,
					2 => totalLevel2,
					3 => totalLevel3
				});
			
		}catch(Exception e){
			//EmailUtil.notifyError(e,null);
			System.debug('ERROR:'+e.getStackTraceString());
			try{
				SObject sobj = Database.query(query);
			}catch(Exception ex){
				//EmailUtil.notifyError(ex,null);
			}
		}
	}
	public Map<String,Map<Integer,Integer>> supportLevelAdoptionLevelCountMap = new Map<String,Map<Integer,Integer>>();
	private list<Integer> adoptionLevelsSupported = new list<Integer>{ 0,1,2,3};
	private list<String> premiumLevelsSupported = new list<String>{'Diamond','Gold','Platinum','Total'};
	public list<Integer> getAdoptionLevelsSupported(){
		return adoptionLevelsSupported;
	}
	public list<String> getPremiumLevelsSupported(){
		return premiumLevelsSupported;
	}
	
	public Map<String,Map<Integer,Integer>> getSupportLevelAdoptionLevelCountMap(){
		return supportLevelAdoptionLevelCountMap;
	}

	private List<AdoptionChartData> adoptionChartData;

	public list<AdoptionChartData> getAdoptionChartData(){
		
		adoptionChartData=new list<AdoptionChartData>();
		{

			if(supportLevelAdoptionLevelCountMap!=null){
				
				for(String premiumLevel:supportLevelAdoptionLevelCountMap.keySet()){
					map<Integer,Integer> adoptionLevelCountMap = supportLevelAdoptionLevelCountMap.get(premiumLevel);
					AdoptionChartData adChartData = new AdoptionChartData();
					adChartData.premiumLevel = premiumLevel;
					adChartData.level0Count = adoptionLevelCountMap.get(0);
					adChartData.level1Count = adoptionLevelCountMap.get(1);
					adChartData.level2Count = adoptionLevelCountMap.get(2);
					adChartData.level3Count = adoptionLevelCountMap.get(3);
					adoptionChartData.add(adChartData);
				}
			}
		}
		return adoptionChartData;
	}
	
	public class AdoptionChartData{
		public String premiumLevel{get;set;}
		public Integer level0Count{get;set;}
		public Integer level1Count{get;set;}
		public Integer level2Count{get;set;}
		public Integer level3Count{get;set;}
	}
}