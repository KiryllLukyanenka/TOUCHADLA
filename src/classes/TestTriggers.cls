@isTest
public class TestTriggers {

    @isTest(SeeAllData=true) static void testAccountTrigger(){
        String accountRTId = getRecordTypeId('Account', 'Partner Account');
        
        Quote[] quotes = [Select Id, Contact.AccountId, Contact.Account.Margin_Discount__c from Quote 
                            where RecordType.Name = 'New VAR Partner Quote' 
                            and Contact.AccountId != null
                            and Contact.Account.RecordTypeId = :accountRTId
                            and Opportunity.StageName <> 'L10 - Closed Lost'
                            and Opportunity.StageName <> 'W10 - Closed/Won'
                            and Opportunity.StageName <> 'I12 - Inactive' limit 1];
        if(!quotes.isEmpty()){
            Quote quote = quotes[0];
            if(quote.Contact.Account.Margin_Discount__c == null){
                quote.Contact.Account.Margin_Discount__c = 100;
            }
            else{
                quote.Contact.Account.Margin_Discount__c += 1;
            }
            update quote.Contact.Account;
        }
    }
    
    @isTest static void testContactAfterTrigger(){
        User user = [select Id from User where AccountId != null and IsActive = true limit 1];
        System.runAs(user){
            Contact con = new Contact(LastName = 'test method');
            insert con;
        }
    }
    
    /*@isTest static void testCeligoUpdateOpportunity(){
        User[] users = [select Id from User where IsActive = true and Profile.Name = 'AD Partner User'];
        User[] fsr = [select Id from User where IsActive = true and Profile.Name = 'AppD FSR'];
        User[] isr = [select Id from User where IsActive = true and Profile.Name = 'AppD ISR'];
        
        if(users.size() > 0 && fsr.size() > 0  && isr.size() > 0){
            System.runAs(users[0]){
                Account parent = new Account(Name = 'parent');
                insert parent;
                Account acc = new Account(Name = 'account', ParentId = parent.Id);
                insert acc;
                Opportunity oppt = new Opportunity(AccountId = acc.Id, Name = 'oppt', CloseDate = System.today(), StageName = 'Closed Won');
                oppt.Celigo_Update__c = false;
                oppt.Booked_Date__c = System.today();
                oppt.FSR__c = fsr[0].Id;
                oppt.ISR__c = isr[0].Id;
                insert oppt;
            }
        }
        else{
            Account acc = new Account(Name = 'account');
            insert acc;
            Opportunity oppt = new Opportunity(AccountId = acc.Id, Name = 'oppt', CloseDate = System.today(), StageName = 'Closed Won');
            oppt.Celigo_Update__c = false;
            oppt.Booked_Date__c = System.today();
            insert oppt;
        }
    }
    */
    @isTest static void testContactCampaignsTrigger(){
        Campaign campaign = new Campaign(Name = 'test', StartDate = System.today(), EndDate = System.today());
        insert campaign;
        Contact con = new Contact(LastName = 'con', LeadSource = 'x', Contact_Status__c = 'x', Lead_Source_Detail__c = 'x');
        insert con;
        CampaignMember cm = new CampaignMember(CampaignId = campaign.Id, ContactId = con.Id, Lead_Source_Detail__c = 'y');
        cm.Lead_Source__c = 'y';
        cm.Lead_Status__c = 'y';
        insert cm;
        update con;
    }
    
    private static String getRecordTypeId(String objName, String typeName){
        RecordType[] types = [Select Id from RecordType where SObjectType = :objName and Name = :typeName];
        if(types.size() > 0){
            return types[0].Id;
        }
        return null;
    }
}