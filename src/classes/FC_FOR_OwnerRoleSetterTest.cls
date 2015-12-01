@isTest (SeeAllData=true)
public class FC_FOR_OwnerRoleSetterTest {

    static testMethod void testOnLead() 
    {      
        
        List<Lead> lds = initTestLeads('lds', 1);
        insert lds;
        
        List<Campaign> camps = initTestCampaigns('cmp', lds.size());
        insert camps;        
        
        FCRM.FCR_SupportAPI.TreatNextCampaignAssociationsAsResponsePrompts();
        CampaignMember cm = new CampaignMember(Status='Responded', FCRM__FCR_Response_Date__c=Date.today() - 2, LeadID = lds[0].id, CampaignID = camps[0].id);        
        
        Test.startTest();
        insert cm;
        Test.stopTest();
                
        String queryStr = 'Select Id, CFCR_First_Owner_Assigned_Role__c From CampaignMember Where Id = \'' + cm.Id + '\'';        
        CampaignMember response = Database.query(queryStr);
               
        system.assert(response.CFCR_First_Owner_Assigned_Role__c != null);             
    } 

    static testMethod void testOnLeadConvert() 
    {      
        
        List<Lead> lds = initTestLeads('lds', 1);
        insert lds;
        
        List<Campaign> camps = initTestCampaigns('cmp', lds.size());
        insert camps;         
        
        FCRM.FCR_SupportAPI.TreatNextCampaignAssociationsAsResponsePrompts();
        CampaignMember cm = new CampaignMember(Status='Responded', FCRM__FCR_Response_Date__c=Date.today() - 2, LeadID = lds[0].id, CampaignID = camps[0].id);        
        
        insert cm;
        
        // Convert the Lead
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lds[0].id);
        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);         
                               
        Test.startTest();
		Database.LeadConvertResult lcr = Database.convertLead(lc); 
        Test.stopTest();
                
        String queryStr = 'Select Id, CFCR_First_Owner_Assigned_Role__c, CFCR_First_Owner_Worked_Role__c, CFCR_SAL_Owner_Role__c From CampaignMember Where Id = \'' + cm.Id + '\'';        
        CampaignMember response = Database.query(queryStr);
               
        system.assert(response.CFCR_First_Owner_Assigned_Role__c != null); 
        system.assert(response.CFCR_First_Owner_Worked_Role__c != null); 
        system.assert(response.CFCR_SAL_Owner_Role__c != null);             
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