global class shareCOntactsTopartnerUsers implements Database.Batchable<sObject>
{
    global final String query; 
    global shareCOntactsTopartnerUsers(String q)
    {
        this.query=q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    { 
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    { 
        for(sobject s : scope)
        { 
            User portalUser = (User)s;
            Id currentAccountId = portalUser.AccountId;
            List<Contact> contacts = [select Id, OwnerId, Owner.AccountId from Contact where Owner.AccountId = :currentAccountId];      
            List<ContactShare> contactShares = new List<ContactShare>();
            for(Contact contact : contacts)
            {
              if(contact.OwnerId != portalUser.Id)
              {
                contactShares.add(new ContactShare(ContactId = contact.Id, UserOrGroupId = portalUser.Id, ContactAccessLevel = 'Edit'));
              }
            }
            insert contactShares;
        }
    }
    
    global void finish(Database.BatchableContext BC){ }
    
    @istest
   static void testBatchJob()
   {
       String query = 'select Id, AccountId from User where ContactId != null and IsActive = true limit 1';
       Test.startTest();
       shareCOntactsTopartnerUsers batchJob = new shareCOntactsTopartnerUsers(query);
       Database.executeBatch(batchJob);
       Test.stopTest();
   }
}