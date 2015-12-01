@isTest
private class TestDealRegExtension {
    
    @isTest 
    static void testOpportunityUpload() 
    {
        ApexPages.StandardController stdController = new ApexPages.StandardController(new Opportunity());
        DealRegExtension extension = new DealRegExtension(stdController);

        extension.DnBAccount.Name = 'Baidu, Inc.';
        extension.DnBAccount.DunsNumber = '544682230';
        extension.DnBAccount.BillingStreet = 'Baidu Campus, No. 10, Shangdi 10th Street';
        extension.DnBAccount.BillingCity = 'Beijing';
        extension.DnBAccount.BillingState = 'Beijing';
        extension.DnBAccount.BillingPostalCode = '100085';
        extension.DnBAccount.BillingCountry = 'CN';

        /*
        extension.DRAccount.Name = 'Baidu, Inc.';
        extension.DRAccount.DunsNumber = '544682230';
        extension.DRAccount.BillingStreet = 'Baidu Campus, No. 10, Shangdi 10th Street';
        extension.DRAccount.BillingCity = 'Beijing';
        extension.DRAccount.BillingState = 'Beijing';
        extension.DRAccount.BillingPostalCode = '100085';
        extension.DRAccount.BillingCountry = 'CN';
        */

        extension.PrimaryContact.Email = 'robin.lee@baidu.com';
        extension.PrimaryContact.Phone = '13888888888';
        extension.PrimaryContact.FirstName = 'Robin';
        extension.PrimaryContact.LastName = 'Lee';
        extension.PrimaryContact.Title = 'CEO';

        extension.DealReg.CloseDate = Date.today().addMonths(1);        

        extension.save();   
    }

    @isTest 
    static void testOpportunityUpload2() 
    {
        ApexPages.StandardController stdController = new ApexPages.StandardController(new Opportunity());
        DealRegExtension extension = new DealRegExtension(stdController);       

        /*
        extension.DnBAccount.Name = 'Baidu, Inc.';
        extension.DnBAccount.DunsNumber = '544682230';
        extension.DnBAccount.BillingStreet = 'Baidu Campus, No. 10, Shangdi 10th Street';
        extension.DnBAccount.BillingCity = 'Beijing';
        extension.DnBAccount.BillingState = 'Beijing';
        extension.DnBAccount.BillingPostalCode = '100085';
        extension.DnBAccount.BillingCountry = 'CN';
        */
        
        extension.DRAccount.Name = 'Baidu, Inc.';
        extension.DRAccount.DunsNumber = '544682230';
        extension.DRAccount.BillingStreet = 'Baidu Campus, No. 10, Shangdi 10th Street';
        extension.DRAccount.BillingCity = 'Beijing';
        extension.DRAccount.BillingState = 'Beijing';
        extension.DRAccount.BillingPostalCode = '100085';
        extension.DRAccount.BillingCountry = 'CN';

        extension.PrimaryContact.Email = 'robin.lee@baidu.com';
        extension.PrimaryContact.Phone = '13888888888';
        extension.PrimaryContact.FirstName = 'Robin';
        extension.PrimaryContact.LastName = 'Lee';
        extension.PrimaryContact.Title = 'CEO';

        extension.DealReg.DR_Company_Not_Found__c = true;
        extension.DealReg.CloseDate = Date.today().addMonths(1);        

        extension.save();
    }
    
    @isTest 
    static void testOpportunityUpload3() 
    {
        ApexPages.StandardController stdController = new ApexPages.StandardController(new Opportunity());
        DealRegExtension extension = new DealRegExtension(stdController);               
        extension.DRAccount.Name = 'Google, Inc.';
        extension.DRAccount.DunsNumber = '544682230';
        extension.DRAccount.BillingStreet = 'Baidu Campus, No. 10, Shangdi 10th Street';
        extension.DRAccount.BillingCity = 'Beijing';
        extension.DRAccount.BillingState = 'Beijing';
        extension.DRAccount.BillingPostalCode = '100085';
        extension.DRAccount.BillingCountry = 'CN';

        extension.PrimaryContact.Email = 'robin.lee@baidu.com';
        extension.PrimaryContact.Phone = '13888888888';
        extension.PrimaryContact.FirstName = 'Robin';
        extension.PrimaryContact.LastName = 'Lee';
        extension.PrimaryContact.Title = 'CEO';

        extension.DealReg.DR_Company_Not_Found__c = true;
        extension.DealReg.CloseDate = Date.today().addMonths(1);        

        extension.save();
    }
    
    @isTest 
    static void testLeadConvert() 
    {       
        Lead newLead = new Lead();
        newLead.Company = 'Baidu, Inc.';
        newLead.Street = 'Baidu Campus, No. 10, Shangdi 10th Street';
        newLead.City = 'Beijing';
        newLead.State = 'Beijing';
        newLead.PostalCode = '';
        newLead.Country = '100085';
        newLead.Email = 'robin.lee@baidu.com';
        newLead.Phone = '13888888888';
        newLead.FirstName = 'Robin';
        newLead.LastName = 'Lee';
        newLead.Title = 'CEO';
        newLead.Estimated_Close_Date__c = Date.today().addMonths(1);
        newLead.Status = 'Open';
        insert newLead;

        ApexPages.currentPage().getParameters().put('lid', newLead.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(new Opportunity());
        DealRegExtension extension = new DealRegExtension(stdController);

        /*
        extension.DnBAccount.Name = 'Baidu, Inc.';
        extension.DnBAccount.DunsNumber = '544682230';
        extension.DnBAccount.BillingStreet = 'Baidu Campus, No. 10, Shangdi 10th Street';
        extension.DnBAccount.BillingCity = 'Beijing';
        extension.DnBAccount.BillingState = 'Beijing';
        extension.DnBAccount.BillingPostalCode = '100085';
        extension.DnBAccount.BillingCountry = 'CN';
        */

        /*
        extension.DRAccount.Name = 'Baidu, Inc.';
        extension.DRAccount.DunsNumber = '544682230';
        extension.DRAccount.BillingStreet = 'Baidu Campus, No. 10, Shangdi 10th Street';
        extension.DRAccount.BillingCity = 'Beijing';
        extension.DRAccount.BillingState = 'Beijing';
        extension.DRAccount.BillingPostalCode = '100085';
        extension.DRAccount.BillingCountry = 'CN';

        extension.PrimaryContact.Email = 'robin.lee@baidu.com';
        extension.PrimaryContact.Phone = '13888888888';
        extension.PrimaryContact.FirstName = 'Robin';
        extension.PrimaryContact.LastName = 'Lee';
        extension.PrimaryContact.Title = 'CEO';

        extension.DealReg.DR_Company_Not_Found__c = true;
        extension.DealReg.CloseDate = Date.today().addMonths(1);    
        */

        extension.DRAccount.DunsNumber = '544682230';           

        extension.save();
    }
}