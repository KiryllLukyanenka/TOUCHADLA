@isTest (SeeAllData=true)
public with sharing class FC_ResponseReanimatorTest {

    private static FC_ResponseReanimateManager__c setting {
    	get {
    		if (setting == null)
    		{
    			FC_ResponseReanimateManager__c newsetting = FC_ResponseReanimateManager__c.getInstance('default');
    			if (newsetting == null)
    			{
    				newsetting.Last_X_Days_Responded_For_Reopen__c = 45;
    				newsetting.Response_Active_Status_Value__c = 'Open';
    				newsetting.Response_Status_Values_to_Consider__c = 'Disqualified';
    			}
    			setting = newsetting;
    		}
    		return setting;    		
    	}
    	set;
    }
    
    static testMethod void TestResponsePromptInsert() 
    {
        FCRM.FCR_SupportAPI.SetRepeatResponseUserForContext();
        
        List<Contact> cts = initTestContacts('cts', 1);
        insert cts;
        
        List<Campaign> camps = initTestCampaigns('cmp', cts.size());
        insert camps;        
        
        List<String> unanimatedStatusValues = setting.Response_Status_Values_to_Consider__c.split(';');
        CampaignMember cm = new CampaignMember(Status='Responded', FCRM__FCR_Response_Date__c=Date.today() - 2, FCRM__FCR_Response_Status__c = unanimatedStatusValues[0], ContactID = cts[0].id, CampaignID = camps[0].id);        
        
        FCRM.FCR_SupportAPI.DisableApplicationForContext();
        insert cm;
        FCRM.FCR_SupportAPI.UndoDisableApplicationForContext();
        
        Set<Id> respPromptCampaignIds = FCRM.FCR_SupportAPI.GetResponsePromptCampaignIDs();
        List<Id> respPromptCampaignIdList = new List<Id>();
        for (Id cid : respPromptCampaignIds) respPromptCampaignIdList.add(cid); 
        List<Campaign> respPromptCamps = [Select Id, FC_Defer_to_Reanimation__c, FC_Exclude_from_Reanimation__c From Campaign Where Id IN :respPromptCampaignIdList];
                  
        respPromptCamps[0].FC_Defer_to_Reanimation__c = true; 
        respPromptCamps[0].FC_Exclude_from_Reanimation__c = false;
        update respPromptCamps[0];
        
        CampaignMember responsePrompt = new CampaignMember(Status='Responded', ContactID = cts[0].id,  CampaignID = respPromptCamps[0].id);       
        
        Test.startTest();   
        insert responsePrompt; 
        Test.stopTest();  
                
        //List<CampaignMember> responses = [Select FCRM__FCR_Response_Status__c, FCRM__FCR_Campaign_Repeat_Parent__c From CampaignMember Where ContactId = :cts[0].id];    
        //system.assertEquals(setting.Response_Active_Status_Value__c, responses[0].FCRM__FCR_Response_Status__c);                   
                        
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


    public static List<Campaign> initTestCampaigns(String prefix, Integer count)
    {
        List<Campaign> camps = new List<Campaign>();
        for(Integer x=1; x<count+1; x++)
        {
          camps.add(new Campaign(Name = prefix+'_'+ String.ValueOf(x), FC_Exclude_from_Reanimation__c=false, 
            FC_Defer_to_Reanimation__c=true, FCRM__FCR_Repeat_Responses_Allowed__c=true, FCRM__FCR_Bypass_Nurture_Timeout__c=true, IsActive = true));
        }
        return camps;
    } 

}