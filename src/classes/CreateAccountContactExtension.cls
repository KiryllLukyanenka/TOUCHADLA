/*
 ** Apex class to be used by CreateAccountContact VF to create Account and Contact, and
 ** relate them to the current opportunity.
 
 ** Author: Eric He
 */
public with sharing class CreateAccountContactExtension 
{
    public Account RelatedAccount { get; set; }
    public Contact PrimaryContact { get; set; }
    public String OppId { get; private set; }
    public Boolean IsSuccess { get; private set; }

    private Opportunity deal;

    public CreateAccountContactExtension(ApexPages.StandardController stdController) 
    {
        OppId = stdController.getId();
        deal = [select DR_Company_Name__c, DR_Address__c, DR_City__c, DR_State_Province__c, DR_Zip__c, DR_Country__c, 
                    DR_Contact_First_Name__c, DR_Contact_Last_Name__c, DR_Title__c, DR_Contact_Phone__c, DR_Email_Address__c, CreatedById
                from Opportunity where Id = :OppId];        
        
        RelatedAccount = new Account(Name = deal.DR_Company_Name__c,
                                     BillingStreet = deal.DR_Address__c,
                                     BillingCity = deal.DR_City__c,
                                     BillingState = deal.DR_State_Province__c,
                                     BillingPostalCode = deal.DR_Zip__c,
                                     BillingCountry = deal.DR_Country__c,
                                     OwnerId = UserInfo.getUserId());

        PrimaryContact = new Contact(FirstName = deal.DR_Contact_First_Name__c,
                                     LastName = deal.DR_Contact_Last_Name__c,
                                     Title = deal.DR_Title__c,
                                     Phone = deal.DR_Contact_Phone__c,
                                     Email = deal.DR_Email_Address__c,
                                     OwnerId = deal.CreatedById);

        IsSuccess = false;
    }

    public void save()
    {        
        try
        {
            upsert RelatedAccount;

            PrimaryContact.AccountId = RelatedAccount.Id;
            upsert PrimaryContact;

            deal.AccountId = RelatedAccount.Id;
            deal.Primary_Contact__c = PrimaryContact.Id;
            deal.OwnerId = RelatedAccount.OwnerId;
            update deal;
            
            IsSuccess = true;
        }
        catch(Exception ex)
        {            
            ApexPages.addMessages(ex);
        }
    }
}