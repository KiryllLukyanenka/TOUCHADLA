// Enhancement - Handler for Account Trigger

public class AccountTriggerHandler
{
    public void onAfterUpdate(Map<Id,Account> oldMap, Map<Id,Account> newMap)
    {
        try
        {
            //Enhancement - To copy over the Partner Margin Discount value to other VAR Partner Quotes
            
            Set<Id> copyToQuoteAccIds = new Set<Id>();
            
            Id partnerRecTypeId = getAccountRecordType('Partner Account');
            
            for(Id i : newMap.keyset())
            {
                //Enhancement - Partner margin discounts have to be copied over only for Partner Accounts
                if(oldMap.get(i).Margin_Discount__c!=newMap.get(i).Margin_Discount__c && newMap.get(i).RecordtypeId==partnerRecTypeId)
                {
                    copyToQuoteAccIds.add(i);
                }
            }
            
            if(copyToQuoteAccIds.size()>0)
            {
                copyToQuote(copyToQuoteAccIds);
            }
        }
        catch(Exception e)
        {
            System.debug('Exception caught: Error encounterd in After Update trigger of Account. Exception message: '+e.getMessage());
        }
    }
    
    //Enhancement - A method which will update partner margin discount for VAR Partner Quotes with the value from Partner Accounts
    
    public void copyToQuote(Set<Id> accIds)
    {
        try
        {
            List<Quote> quotes = new List<Quote>();
            
            quotes = [Select Partner_Margin_Discount__c, Contact.Account.Margin_Discount__c from Quote 
                             where Contact.AccountId in :accIds and Recordtype.Name='New VAR Partner Quote'
                                                                and Opportunity.StageName <> 'L10 - Closed Lost'
                                                                and Opportunity.StageName <> 'W10 - Closed/Won'
                                                                and Opportunity.StageName <> 'I12 - Inactive'];
            
            if(quotes.size()>0)
            {
                for(Quote q : quotes)
                {
                    q.Partner_Margin_Discount__c = q.Contact.Account.Margin_Discount__c;
                }
                
                Database.update(quotes,false);
            }
        }
        catch(Exception e)
        {
            System.debug('Exception caught: Error encounterd while updating Partner margin value for quotes. Exception message: '+e.getMessage());
        }
    }
    
    //Enhancement - A method to get the Account Record Type Id
    
    public Id getAccountRecordType(String recTypeName)
    {
        try
        {
            RecordType recType = [Select Id from RecordType where SObjectType = 'Account' and Name = :recTypeName];
            return recType.Id;
        }
        catch(QueryException e)
        {
            System.debug('Exception caught: ' + recTypeName + 'on Account is not found. Exception message: '+e.getMessage());
            return null;
        }
    }
    
}