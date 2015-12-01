@isTest (SeeAllData=true)
public class FC_SFC_SyncFieldClearerTest {

    static testMethod void testFieldClearOnLead() 
    {
    	installPlugin('FC_SFC_SyncFieldClearer');
    	enableSyncFieldClearer();
    	FC_SFC_SyncFieldClearer.testFieldToClear = 'Title';
    	
        List<Lead> lds = initTestLeads('lds', 1);
        lds[0].put('Title', 'Title Value To Clear');
        insert lds;
        
        List<Campaign> camps = initTestCampaigns('cmp', lds.size());
        insert camps;        
        
        FCRM.FCR_SupportAPI.TreatNextCampaignAssociationsAsResponsePrompts();
        CampaignMember cm = new CampaignMember(Status='Responded', FCRM__FCR_Response_Date__c=Date.today() - 2, LeadID = lds[0].id, CampaignID = camps[0].id);        

        Test.startTest();
        insert cm;
        Test.stopTest();
                
        Lead updatedLead = [Select Title, Id From Lead Where Id = :lds[0].Id];
               
        system.assert(updatedLead.Title == null);             
    } 

    static testMethod void testFieldClearOnContact() 
    {
    	installPlugin('FC_SFC_SyncFieldClearer');
    	enableSyncFieldClearer();
    	FC_SFC_SyncFieldClearer.testFieldToClear = 'Title';
    	
        List<Contact> cts = initTestContacts('cts', 1);
        cts[0].put('Title', 'Title Value To Clear');
        insert cts;
        
        List<Campaign> camps = initTestCampaigns('cmp', cts.size());
        insert camps;        
        
        FCRM.FCR_SupportAPI.TreatNextCampaignAssociationsAsResponsePrompts();
        CampaignMember cm = new CampaignMember(Status='Responded', FCRM__FCR_Response_Date__c=Date.today() - 2, ContactId = cts[0].id, CampaignID = camps[0].id);        

        Test.startTest();
        insert cm;
        Test.stopTest();
                
        Contact updatedcontact = [Select Title, Id From Contact Where Id = :cts[0].Id];
               
        system.assert(updatedcontact.Title == null);             
    } 

    public static void enableSyncFieldClearer()
    {
    	FC_SFC_Sync_Field_Clear_Setting__c globalSetting = FC_SFC_Sync_Field_Clear_Setting__c.getOrgDefaults();
    	if (globalSetting == null) globalSetting = new FC_SFC_Sync_Field_Clear_Setting__c(); 
    	globalSetting.Active_For_Contacts__c = true;
    	globalSetting.Active_For_Leads__c = true;
    	upsert globalSetting; 
    } 
    
    public static void installPlugin(String pluginname)
    {
    	// FC_SFC_SyncFieldClearer
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