/*
 * VF Extension provides background support for VF: DealRegistration
 *
 * Eric He
 * Modified History
 * --------------------------------------------
 * Justin Wong - 6/16/2015:  Added the Type field to the updateOpportunity method
*/
public without sharing class DealRegExtension 
{   
    public AccountInfo DnBAccount { get; set; }
    public AccountInfo DRAccount { get; set; }
    public Contact PrimaryContact { get; set; }
    public Opportunity DealReg { get; set; }

    public List<String> ApplicationStackOptions { get;set; }
    public List<String> PursingProductOptions { get; set; }    

    private User portalUser;
    private String leadId;
    
    public DealRegExtension(ApexPages.StandardController stdController) 
    {        
        DnBAccount = new AccountInfo();
        DRAccount = new AccountInfo();
        PrimaryContact = new Contact();
        DealReg = new Opportunity(Deal_Type__c = '');

        portalUser = [select Id, ContactId, Contact.AccountId, Contact.Account.Name, Contact.Account.OwnerId from User where Id = :UserInfo.getUserId()];
        
        initApplicationStackOptions();
        initPursingProductOptions();
        
        leadId = ApexPages.currentPage().getParameters().get('lid');
        if(String.isNotBlank(leadId))
        {
            populateFieldsFromLead();
        }
    }
    
    public PageReference save()
    {    
        initDealRegFields();
        try
        {
            String opportunityId = createOpportunity();           
            // The partner user automatically follow the newly created opportunity.
            followOpportunity(opportunityId);
            // Add the partner user to the opportunity team.
            addOpportunityTeamMember(opportunityId);

            if(DealReg.Primary_Contact__c != null)
            {
                addOpportunityPrimaryContact(opportunityId);
            }            

            submitOpportunityForApproval(opportunityId);
            return new PageReference('/' + opportunityId);
        }
        catch(Exception ex)
        {
            system.debug(ex);
            ApexPages.addMessages(ex);
            return null;
        }
    }
    
    public class AccountInfo
    {
        public String Name { get; set; }
        public String DunsNumber { get; set; }
        public String BillingStreet { get; set; }
        public String BillingCity { get; set; }
        public String BillingState { get; set; }
        public String BillingPostalCode { get; set; }
        public String BillingCountry { get; set; }
    }
    
    private void initApplicationStackOptions()
    {
        ApplicationStackOptions = new List<String>();
        Schema.DescribeFieldResult result = Schema.SObjectType.Opportunity.fields.Application_Stack__c;
        for(Schema.PicklistEntry entry : result.getPicklistValues())
        {
            ApplicationStackOptions.add(entry.getValue());
        }       
    }

    private void initPursingProductOptions()
    {
        PursingProductOptions = new List<String>();
        Schema.DescribeFieldResult result = Schema.SObjectType.Opportunity.fields.DR_Products_Pursing__c;
        for(Schema.PicklistEntry entry : result.getPicklistValues())
        {
            PursingProductOptions.add(entry.getValue());
        }
    }
    
    private void populateFieldsFromLead()
    {
        Lead lead = [select Id, Company, Street, City, State, PostalCode, Country, Email, Phone, FirstName, LastName, Title, Estimated_Close_Date__c, CurrencyIsoCode from Lead where Id = :leadId];
        DnBAccount.Name = lead.Company;
        
        DRAccount.Name = lead.Company;
        DRAccount.BillingStreet = lead.Street;
        DRAccount.BillingCity = lead.City;
        DRAccount.BillingState = lead.State;
        DRAccount.BillingPostalCode = lead.PostalCode;
        DRAccount.BillingCountry = lead.Country;
        
        PrimaryContact.Email = lead.Email;
        PrimaryContact.Phone = lead.Phone;
        PrimaryContact.FirstName = lead.FirstName;
        PrimaryContact.LastName = lead.LastName;
        PrimaryContact.Title = lead.Title;
        
        DealReg.CloseDate = lead.Estimated_Close_Date__c;
        DealReg.CurrencyIsoCode = lead.CurrencyIsoCode;
    }
    
    private void initDealRegFields()
    {
        DealReg.Name = getOpportunityName();
        DealReg.Deal_Source__c = 'Deal Registration';
        DealReg.Partner_Involved__c = portalUser.Contact.AccountId;
        DealReg.StageName = 'A1 - Pipeline Generation';       
        DealReg.Partner_Account_Owner__c = portalUser.Contact.Account.OwnerId;  
        DealReg.NextStep = DealReg.Next_Steps__c;
        DealReg.Opportunity_Description__c = DealReg.Description;     
    }
    
    private String createOpportunity()
    {
        String accountId, contactId;
        // If the company is found from DnB Service.
        if(!DealReg.DR_Company_Not_Found__c)
        {                
            accountId = getCustomerAccountId();
            contactId = getPrimaryContactId(accountId);
        }
        else
        {
            saveAccountInfoToOpportunity();
            saveContactInfoToOpportunity();
        }
        DealReg.AccountId = (accountId != null) ? accountId : portalUser.Contact.AccountId;
        DealReg.Primary_Contact__c = contactId;
        
        if(String.isBlank(leadId))
        {                
            insert DealReg;            
            return DealReg.Id;
        }
        else
        {
            return convertLead(accountId, contactId);
        }
    }
    
    private String convertLead(String accountId, String contactId)
    {
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadId);
        lc.setAccountId(accountId);
        lc.setContactId(contactId);
        lc.setOwnerId(portalUser.Id);
        // FCRM edit, now explicitly setting Lead status to 'Recycled'
        //LeadStatus convertStatus = [select Id, MasterLabel from LeadStatus where IsConverted = true limit 1];
        //lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setConvertedStatus('Recycled');
        Database.LeadConvertResult result = Database.convertLead(lc);
        
        String opportunityId = result.getOpportunityId();
        updateOpportunity(opportunityId);
        
        if(DealReg.DR_Company_Not_Found__c)
        {
            delete [select Id from Account where Id = :result.getAccountId()];
        }
        
        return opportunityId;
    }
    
    private String updateOpportunity(String opportunityId)
    {
        Opportunity convertedOpportunity = [select Type, Name, Project_Country__c, AccountId, Primary_Contact__c, Deal_Source__c, Partner_Involved__c, Partner_Account_Owner__c,
                                            DR_Company_Not_Found__c, DR_Company_Name__c, DR_Address__c, DR_City__c, DR_State_Province__c, DR_Zip__c, DR_Country__c,
                                            DR_Email_Address__c, DR_Contact_Phone__c, DR_Contact_First_Name__c, DR_Contact_Last_Name__c, DR_Title__c,
                                            DR_Existing_Client__c, DR_Primary_APM_Solution__c, DR_Executive_Approval__c, AD_Employee_Engaged__c, AD_Partner_Engaged_Employee__c,
                                            Application_Stack__c, DR_Number_of_Agents__c, DR_Products_Pursing__c, Amount, CloseDate, Deal_Type__c, Opportunity_Type__c,
                                            CurrencyIsoCode, DR_Primary_Competitor__c, DR_Deal_Timeframe__c, Next_Steps__c, Description from Opportunity where Id = :opportunityId];
        convertedOpportunity.Type = DealReg.Type;
        convertedOpportunity.Name = DealReg.Name;
        convertedOpportunity.AccountId = DealReg.AccountId;
        convertedOpportunity.Primary_Contact__c = DealReg.Primary_Contact__c;
        convertedOpportunity.Deal_Source__c = DealReg.Deal_Source__c;
        convertedOpportunity.Partner_Involved__c = DealReg.Partner_Involved__c;
        convertedOpportunity.Partner_Account_Owner__c = DealReg.Partner_Account_Owner__c;
        convertedOpportunity.DR_Company_Not_Found__c = DealReg.DR_Company_Not_Found__c;
        convertedOpportunity.DR_Company_Name__c = DealReg.DR_Company_Name__c;
        convertedOpportunity.DR_Address__c = DealReg.DR_Address__c;
        convertedOpportunity.DR_City__c = DealReg.DR_City__c;
        convertedOpportunity.DR_State_Province__c = DealReg.DR_State_Province__c;
        convertedOpportunity.DR_Zip__c = DealReg.DR_Zip__c;
        convertedOpportunity.DR_Country__c = DealReg.DR_Country__c;
        convertedOpportunity.DR_Email_Address__c = DealReg.DR_Email_Address__c;
        convertedOpportunity.DR_Contact_Phone__c = DealReg.DR_Contact_Phone__c;
        convertedOpportunity.DR_Contact_First_Name__c = DealReg.DR_Contact_First_Name__c;
        convertedOpportunity.DR_Contact_Last_Name__c = DealReg.DR_Contact_Last_Name__c;
        convertedOpportunity.DR_Title__c = DealReg.DR_Title__c;
        convertedOpportunity.DR_Existing_Client__c = DealReg.DR_Existing_Client__c;
        convertedOpportunity.DR_Primary_APM_Solution__c = DealReg.DR_Primary_APM_Solution__c;
        convertedOpportunity.DR_Executive_Approval__c = DealReg.DR_Executive_Approval__c;
        convertedOpportunity.AD_Employee_Engaged__c = DealReg.AD_Employee_Engaged__c;
        convertedOpportunity.AD_Partner_Engaged_Employee__c = DealReg.AD_Partner_Engaged_Employee__c;
        convertedOpportunity.Application_Stack__c = DealReg.Application_Stack__c;
        convertedOpportunity.DR_Number_of_Agents__c = DealReg.DR_Number_of_Agents__c;
        convertedOpportunity.DR_Products_Pursing__c = DealReg.DR_Products_Pursing__c;
        convertedOpportunity.Amount = DealReg.Amount;
        convertedOpportunity.CloseDate = DealReg.CloseDate;
        convertedOpportunity.Deal_Type__c = DealReg.Deal_Type__c;
        convertedOpportunity.Opportunity_Type__c = DealReg.Opportunity_Type__c;
        convertedOpportunity.CurrencyIsoCode = DealReg.CurrencyIsoCode;
        convertedOpportunity.DR_Primary_Competitor__c = DealReg.DR_Primary_Competitor__c;
        convertedOpportunity.DR_Deal_Timeframe__c = DealReg.DR_Deal_Timeframe__c;
        convertedOpportunity.Next_Steps__c = DealReg.Next_Steps__c;
        convertedOpportunity.Project_Country__c = DealReg.Project_Country__c;
        convertedOpportunity.Description = DealReg.Description;
        
        update convertedOpportunity;
        return opportunityId;
    }
    
    // Opportunity.Name = DnBAccount.Name | DealReg.DR_Company_Name + Partner Account Name.
    private String getOpportunityName()
    {
        String clientAccountName = (DnBAccount.Name != null) ? DnBAccount.Name : DealReg.DR_Company_Name__c;
        if(clientAccountName == null)
        {
            clientAccountName = '';
        }
        String partnerAccountName = (portalUser.Contact.Account.Name != null) ? portalUser.Contact.Account.Name : '';
        return clientAccountName + '-' + partnerAccountName;
    }

    private String getCustomerAccountId()
    {
        // Retrieves the Account based on the DunsNumber field.
        List<Account> customerAccounts = [select Id from Account where DunsNumber = :DnBAccount.DunsNumber];
        // If find, return the Account
        if(customerAccounts.size() > 0)
        {
            return customerAccounts[0].Id;
        }        

        // If not, create a new one, and return it back.
        Account newAccount = new Account(Name = DnBAccount.Name,
                                         DunsNumber = DnBAccount.DunsNumber,
                                         BillingStreet = DnBAccount.BillingStreet,
                                         BillingCity = DnBAccount.BillingCity,
                                         BillingState = DnBAccount.BillingState,
                                         BillingPostalCode = DnBAccount.BillingPostalCode,
                                         BillingCountry = DnBAccount.BillingCountry);
        if(portalUser.Contact.Account.OwnerId != null)
        {
            newAccount.OwnerId = portalUser.Contact.Account.OwnerId;
        }        
        insert newAccount;
        return newAccount.Id;

    }

    private String getPrimaryContactId(String accountId)
    {
        if(String.isNotBlank(DealReg.Primary_Contact__c))
        {
            return DealReg.Primary_Contact__c;
        }

        PrimaryContact.AccountId = accountId;        
        insert PrimaryContact;
        return PrimaryContact.Id;
    }

    private void saveAccountInfoToOpportunity()
    {
        DealReg.DR_Company_Name__c = DRAccount.Name;
        DealReg.Name = getOpportunityName();
        DealReg.DR_Address__c = DRAccount.BillingStreet;
        DealReg.DR_City__c = DRAccount.BillingCity;
        DealReg.DR_State_Province__c = DRAccount.BillingState;
        DealReg.DR_Zip__c = DRAccount.BillingPostalCode;
        DealReg.DR_Country__c = DRAccount.BillingCountry;
    }

    private void saveContactInfoToOpportunity()
    {
        DealReg.DR_Email_Address__c = PrimaryContact.Email;
        DealReg.DR_Contact_Phone__c = PrimaryContact.Phone;
        DealReg.DR_Contact_First_Name__c = PrimaryContact.FirstName;
        DealReg.DR_Contact_Last_Name__c = PrimaryContact.LastName;
        DealReg.DR_Title__c = PrimaryContact.Title;
    }

    private void followOpportunity(String opportunityId)
    {
        // ConnectApi method are not supported in data siloed tests.
        // Please use @isTest(SeeAllData=true)
        if(!Test.isRunningTest())
        {
            String communityId = Network.getNetworkId();        
            ConnectApi.ChatterUsers.follow(communityId, portalUser.Id, opportunityId);                
        }        
    }

    private void addOpportunityTeamMember(String opportunityId)
    {
        OpportunityTeamMember teamMember = new OpportunityTeamMember(OpportunityId = opportunityId, UserId = portalUser.Id, TeamMemberRole = 'Partner');
        insert teamMember;        
    }

    private void addOpportunityPrimaryContact(String opportunityId)
    {        
        List<OpportunityContactRole> contactRoles = [select OpportunityId, ContactId, IsPrimary, Role from OpportunityContactRole 
                                                where OpportunityId = :opportunityId and ContactId = :DealReg.Primary_Contact__c];
        if(contactRoles.size() > 0)
        {            
            contactRoles[0].IsPrimary = true;
            contactRoles[0].Role = 'Administrative';
            update contactRoles[0];       
        }                                               
        else
        {
            OpportunityContactRole opportunityPrimaryContact = new OpportunityContactRole(OpportunityId = opportunityId,
                                                                                            ContactId = DealReg.Primary_Contact__c,
                                                                                            IsPrimary = true,
                                                                                            Role = 'Administrative');
            insert opportunityPrimaryContact;
        } 
    }

    private void submitOpportunityForApproval(String opportunityId)
    {
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setComments('Submitting request for approval');
        request.setObjectId(opportunityId);
        if(!Test.isRunningTest())
        {
            Approval.ProcessResult result = Approval.process(request);
        }
    }

    @RemoteAction
    public static Contact getPrimaryContact(String contactEmail, String companyNumber)
    {
        return ContactLookup.getPrimaryContact(contactEmail, companyNumber);
    }
}