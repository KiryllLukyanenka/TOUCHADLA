@isTest
public class TestUtil {
    public static List<Quote> createQuotes( Integer numToInsert, Id contactId, Id oppId, Boolean doInsert ) {
        RecordType rec = [ Select Id from RecordType where SObjectType='Quote' and Name = 'New Customer Quote'][0];
        List<Quote> quotes = new List<Quote>();
        for( Integer i=0; i< numToInsert; i++ ) {
            Quote q = new Quote();
            q.Name = 'TestQuote'+i;
            q.ContactId = contactId;
            q.RecordTypeId = rec.Id;
            q.OpportunityId = oppId;
            q.One_Time_Discount_Percentage__c = 0;
            quotes.add(q);
        }
        if( doInsert )
            insert quotes;
        return quotes;
    }
    
    public static List<QuoteLineItem> createQLIs( Integer numToInsert, Id quoteId ,Id priceBookEntryId, Boolean doInsert ) {
        List<QuoteLineItem> qlis = new List<QuoteLineItem>();
        for( Integer i=0; i< numToInsert; i++ ) {
            QuoteLineItem q = new QuoteLineItem();
            q.priceBookEntryId = priceBookEntryId;
            q.quoteId = quoteId;
            q.Quantity = 1;
            q.UnitPrice = 100;
            q.Volume_Discount__c = 0;
            q.Partner_Margin__c = 0;
            q.One_Time_Discount__c = 0;
            qlis.add( q );
        }
        if( doInsert )
            insert qlis;
        return qlis;
    }
    
    public static List<Contact> createContacts( Integer numToInsert, Id accountId, Boolean doInsert  ) {
        List<Contact> contacts = new List<Contact>();
        for( Integer i=0; i< numToInsert; i++ ){
            Contact c = new Contact();
            c.FirstName = 'Test';
            c.LastName = 'Name' + i;
            c.AccountId = accountId;
            c.MailingStreet = '302 Second Street';
            c.MailingCity = 'San Francisco';
            c.MailingPostalCode = '94100';
            c.MailingState = 'CA';
            c.MailingCountry = 'United States';
            
            contacts.add( c );
        }
        
        if( doInsert )
            insert contacts;
        return contacts;
    }
    
    public static List<Account> createAccounts( Integer numToInsert, Boolean doInsert  ) {
        List<Account> accounts = new List<Account>();
        
        Territory_AppD__c t = new Territory_AppD__c(Name = 'Test Territory',
                                                 Geo__c = 'North America',
                                                 Region__c = 'West',
                                                 Assigned_To_ID__c = '00580000006Aq0QAAS');
        insert t;
        
        for( Integer i=0; i< numToInsert; i++ ){
            Account a = new Account();
            a.Name = 'Test Account' + i;
            a.BillingStreet = '303 2nd Street';
            a.BillingCity = 'San Francisco';
            a.BillingState = 'CA'; 
            a.BillingCountry= 'United States'; 
            //a.Territory_AppD__c = 'a1k34000001se1MAAQ';
            a.Territory_AppD__c = t.Id;
            a.Subsidiary__c = 'AppDynamics, Inc.';
            a.Margin_Discount__c = 0;// Enhancement - This margin discount will be copied over to Quote & Quote Line items
            accounts.add( a );
        }
        
        if( doInsert )
            insert accounts;
        return accounts;
    }
    
    public static List<Opportunity> createOpps( Integer numToInsert, Id accId, Boolean doInsert  ) {
        List<Opportunity> opps = new List<Opportunity>();
        for( Integer i=0; i< numToInsert; i++ ){
            Opportunity o = new Opportunity();
            o.Name = 'Test Opp' + i;
            o.StageName = 'New';
            o.CloseDate = Date.Today().addMonths(1);
            o.AccountId = accId;
            opps.add( o );
        }
        
        if( doInsert )
            insert opps;
        return opps;
    }
    
}