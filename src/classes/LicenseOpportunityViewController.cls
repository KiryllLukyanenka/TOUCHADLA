public with sharing class LicenseOpportunityViewController {
    License_Opportunity__c licenseOpportunity;
    private String licenseId;
    public LicenseOpportunityViewController(ApexPages.StandardController stdController)
    {
        licenseOpportunity = (License_Opportunity__c) stdController.getRecord();
        
        try
        {
            licenseOpportunity =[select Opportunity__c, License__c from License_Opportunity__c where Id=:licenseOpportunity.Id];
            licenseId = licenseOpportunity.License__c;
        }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Error while retrieving associated license for opportunity:'+e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    
    public PageReference redirectToLicense()
    {
        if(licenseId!=null)
        {
            PageReference ref = new PageReference('/'+licenseId);
            ref.setRedirect(true);
            return ref;
        }
        return null;
    }
}