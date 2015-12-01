@isTest (SeeAllData=true)
public class FC_GSR_ScoreReevaluatorTest {

    static testMethod void testRescoreReevaluationOnContact() 
    {
    	FCRM.FCR_SupportAPI.SetRepeatResponseUserForContext();
    	
    	// Get custom setting
    	RM_Score_Evaluation_Setting__c setting = getCustomSetting('default');      
        
        // Bypass scoring requirement because scoring field not visible in test
        FC_GSR_ScoreReevaluator.bypassScoreRequirement = true;
        
        List<Contact> cts = initTestContacts('cts', 1);
        insert cts;
        
        List<Campaign> camps = initTestCampaigns('cmp', cts.size());
        insert camps;        
        
        List<String> unanimatedStatusValues = setting.Response_Status_Values__c.split(',');
        CampaignMember cm = new CampaignMember(Status='Responded', FCRM__FCR_Response_Date__c=Date.today() - 2, FCRM__FCR_Response_Status__c = unanimatedStatusValues[0], ContactID = cts[0].id, CampaignID = camps[0].id);        
        
        insert cm;
        
        cts[0].put(setting.Contact_Trigger_Field__c, 'new value');
        Test.startTest();
        update cts[0];
        Test.stopTest();
                
        CampaignMember response = [Select FCRM__FCR_Response_Status__c From CampaignMember Where Id = :cm.Id];
               
        system.assert(response.FCRM__FCR_Response_Status__c == setting.Contact_Status_after_Response__c);             
    }
    
    static testMethod void testInsertDefaultCampaign() 
    {
    	FCRM.FCR_SupportAPI.SetRepeatResponseUserForContext();
    	
    	// Get custom setting
    	RM_Score_Evaluation_Setting__c setting = getCustomSetting('default');      
        
        // Bypass scoring requirement because scoring field not visible in test
        FC_GSR_ScoreReevaluator.bypassScoreRequirement = true;
        
        List<Contact> cts = initTestContacts('cts', 1);
        insert cts;
        
        List<Campaign> camps = initTestCampaigns('cmp', cts.size());        
        insert camps;  
              
        setting.Default_Campaign_ID__c = camps[0].Id;
        upsert setting;                
        
        cts[0].put(setting.Contact_Trigger_Field__c, 'new value');
        Test.startTest();
        update cts[0];
        Test.stopTest();
                
        List<CampaignMember> responses = [Select FCRM__FCR_Response_Status__c From CampaignMember Where ContactId = :cts[0].Id];
               
        system.assert(responses.size() > 0);             
    }              
    
    static testMethod void testRescoreReevaluationOnContactAsync() 
    {
    	FCRM.FCR_SupportAPI.SetRepeatResponseUserForContext();
    	
    	// Get custom setting
    	RM_Score_Evaluation_Setting__c setting = getCustomSetting('default');
    	
    	// Register Plugin            
        installPlugin('FC_GSR_AsyncPlugin');              
        
        // Bypass scoring requirement because scoring field not visible in test
        FC_GSR_ScoreReevaluator.bypassScoreRequirement = true;
        
        List<Contact> cts = initTestContacts('cts', 1);
        insert cts;
        
        List<Campaign> camps = initTestCampaigns('cmp', cts.size());
        insert camps;        
        
        List<String> unanimatedStatusValues = setting.Response_Status_Values__c.split(',');
        CampaignMember cm = new CampaignMember(Status='Responded', FCRM__FCR_Response_Date__c=Date.today() - 2, FCRM__FCR_Response_Status__c = unanimatedStatusValues[0], ContactID = cts[0].id, CampaignID = camps[0].id);        
        
        insert cm;
        
        FC_GSR_AsyncPlugin plugin = new FC_GSR_AsyncPlugin();
        Test.startTest();
        plugin.ExtensibilityEvent('TimedAsync', getArgs(new List<Id>{cts[0].Id}));
        Test.stopTest();
                
        CampaignMember response = [Select FCRM__FCR_Response_Status__c From CampaignMember Where Id = :cm.Id];
               
        system.assert(response.FCRM__FCR_Response_Status__c == setting.Contact_Status_after_Response__c);             
    }    
    
    static testMethod void testRescoreReevaluationOnConvertedLead() 
    {
    	FCRM.FCR_SupportAPI.SetRepeatResponseUserForContext();
    	
    	// Get custom setting
    	RM_Score_Evaluation_Setting__c setting = getCustomSetting('default');  
    	setting.Follow_Converted_Lead__c = true; 
    	upsert setting;   
        
        // Bypass scoring requirement because scoring field not visible in test
        FC_GSR_ScoreReevaluator.bypassScoreRequirement = true;
        
        List<Lead> lds = initTestLeads('lds', 1);
        insert lds;
        
        List<Campaign> camps = initTestCampaigns('cmp', lds.size());
        insert camps;         
        
        List<String> unanimatedStatusValues = setting.Response_Status_Values__c.split(',');
        CampaignMember cm = new CampaignMember(Status='Responded', FCRM__FCR_Response_Date__c=Date.today() - 2, FCRM__FCR_Response_Status__c = unanimatedStatusValues[0], LeadID = lds[0].id, CampaignID = camps[0].id);        
        
        insert cm;
        
        // Convert the Lead
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lds[0].id);
        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);         
        Database.LeadConvertResult lcr = Database.convertLead(lc);                
        
        FC_GSR_AsyncPlugin plugin = new FC_GSR_AsyncPlugin();
        Test.startTest();
		plugin.ExtensibilityEvent('TimedAsync', getArgs(new List<Id>{lds[0].Id}));
        Test.stopTest();
                
        CampaignMember response = [Select FCRM__FCR_Response_Status__c From CampaignMember Where Id = :cm.Id];
               
        system.assert(response.FCRM__FCR_Response_Status__c == setting.Lead_Status_after_Response__c);             
    }       
    
    static testMethod void testRescoreReevaluationOnLead() 
    {
    	FCRM.FCR_SupportAPI.SetRepeatResponseUserForContext();
    	
    	// Get custom setting
    	RM_Score_Evaluation_Setting__c setting = getCustomSetting('default');      
        
        // Bypass scoring requirement because scoring field not visible in test
        FC_GSR_ScoreReevaluator.bypassScoreRequirement = true;
        
        List<Lead> lds = initTestLeads('lds', 1);
        insert lds;
        
        List<Campaign> camps = initTestCampaigns('cmp', lds.size());
        insert camps;        
        
        List<String> unanimatedStatusValues = setting.Response_Status_Values__c.split(',');
        CampaignMember cm = new CampaignMember(Status='Responded', FCRM__FCR_Response_Date__c=Date.today() - 2, FCRM__FCR_Response_Status__c = unanimatedStatusValues[0], LeadID = lds[0].id, CampaignID = camps[0].id);        
        
        insert cm;
        
        lds[0].put(setting.Lead_Trigger_Field__c, 'new value');
        Test.startTest();
        update lds[0];
        Test.stopTest();
                
        CampaignMember response = [Select FCRM__FCR_Response_Status__c From CampaignMember Where Id = :cm.Id];
               
        system.assert(response.FCRM__FCR_Response_Status__c == setting.Lead_Status_after_Response__c);             
    }    

    // Args class used for testing the plugin
    public Class Args implements FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs
    {
        public List<List<Sobject>> Recordlists;
        public List<Map<ID, Sobject>> RecordMaps;
        public List<List<ID>> RecordIds;
        
        public List<List<Sobject>> getRecordLists() { return RecordLists; }
        public List<Map<ID, Sobject>> getRecordMaps() { return RecordMaps; }
        public List<List<ID>> getRecordIds() { return RecordIds; }
        public List<Object> getAdditionalParams() {return null; }
        public void setRaiseFuture() {  }
        public String getXMLdata() {
            List<String> personIdList = new List<String>();
            for (String id : this.getRecordIds()[0]) personIdList.add(id);          
            return String.join(personIdList, ',');
        }
        
        public Args(){}
                
    } 
    
    public static Args getArgs(List<Id> taskIdList) 
    {
        Args args = new Args();
        args.RecordIds = new List<List<Id>>();
        args.RecordIds.add(taskIdList);
        return args;
    }    

    public static RM_Score_Evaluation_Setting__c getCustomSetting(String name)
    {
    	RM_Score_Evaluation_Setting__c setting = RM_Score_Evaluation_Setting__c.getInstance(name);
    	if (setting == null) setting = new RM_Score_Evaluation_Setting__c(name = name); 
		setting.Lead_Status_after_Response__c = 'Open - Not Contacted';
		setting.Contact_Status_after_Response__c = 'Open - Not Contacted';
		setting.Default_Member_Status__c = 'Responded';
		setting.Contact_Trigger_Field__c = 'Title';
		setting.Lead_Trigger_Field__c = 'Industry';    	
		setting.Response_Status_Values__c = 'Resolved - Already Engaged,Resolved - No Action Required';
		setting.Time_Delay_for_Evaluation__c = 0;
    	upsert setting; 
    	return setting;
    } 
    
    public static void installPlugin(String pluginname)
    {
        FCRM.FCR_ExtensibilityAPI.EnablePluginsForTest = new Set<String>{pluginname};
        FCRM.FCR_ExtensibilityAPI.InstallPluginClass(pluginname);
    }    

    public static List<Contact> initTestContacts(String prefix, Integer count)  
    {    
        List<Contact>cts = new List<Contact>();    
        for(Integer x=1;x<count+1;x++)    
        {      
          cts.add(new Contact(LastName = prefix + '_' + String.valueOf(x)));
        }
        return cts;  
    }
    
    public static List<Account> initTestAccounts(String prefix, Integer count)
    {
	  List<Account> accounts = new List<Account>();
	  for(Integer x=1; x<count + 1; x++)
	  {
	    accounts.add(new Account(Name= prefix + '_' + String.valueOf(x)));    
	  }
	  return accounts;
    }
    
   public static List<Lead> initTestLeads(String prefix, Integer count)  
   {    
		List<Lead>lds = new List<Lead>();    
		for(Integer x=1;x<count+1;x++)    
		{      
		  lds.add(new Lead(Company= prefix + '_' + String.valueOf(x), LastName = prefix + '_' + String.valueOf(x), Status='Nurture/Marketing'));    
		}    
		return lds;  
   }    
        
    
    public static List<Campaign> initTestCampaigns(String prefix, Integer count)
    {
        List<Campaign> camps = new List<Campaign>();
        for(Integer x=1; x<count+1; x++)
        {
          camps.add(new Campaign(Name = prefix+'_'+ String.ValueOf(x), FCRM__FCR_Repeat_Responses_Allowed__c=true, IsActive = true));
        }
        return camps;
    }    

}