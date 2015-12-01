global class NewEditPartnerCampaignController
{    
    private String partnerCampaignId = ApexPages.currentpage().getparameters().get('id');
    
    public NewEditPartnerCampaignController()
    {
        PartnerCampaign = new Partner_Campaign__c();
        if(partnerCampaignId != null && partnerCampaignId instanceOf ID)
        {
            PartnerCampaign = [select Id, Campaign__c, Campaign__r.Name, Partner_Region__c from Partner_Campaign__c where Id = :partnerCampaignId];
        }
    }
    
    public Partner_Campaign__c PartnerCampaign { get; set; }
    
    public List<SelectOption> getPartnerRegions()
    {
        List<SelectOption> results = new List<SelectOption>();
        Schema.DescribeFieldResult regions = Account.Partner_Region__c.getDescribe();
        for(Schema.PicklistEntry entry : regions.getPicklistValues())
        {
            results.add(new SelectOption(entry.getValue(), entry.getValue()));
        }
        return results;
    }
    
    public List<SelectOption> getAllActiveCampaigns()
    {
        List<SelectOption> results = new List<SelectOption>();
        
        for(Campaign cam : [select Id, Name from Campaign where IsActive = true])
        {
            results.add(new SelectOption(cam.Id, cam.Name));
        }
        return results;
    }
    
    public PageReference cancel()
    {
        PageReference retPage = new PageReference('/apex/PartnerCampaigns');
        retPage.setRedirect(true);
        return retPage; 
    }
    
    @RemoteAction
    global static List<Campaign> searchCampaigns(String campaignNameKeyword)
    {
        String keyword = '%' + campaignNameKeyword + '%';
        return [select Id, Name from Campaign where Name like :keyword limit 1000];
    }
    
    public PageReference savePartnerCampaign()
    {
        
        Set<String> hasCampaignRegions = new Set<String>();
        for(Partner_Campaign__c thispartnerCampaign : [select Id, Campaign__c, Campaign__r.Name, Partner_Region__c from Partner_Campaign__c where Id != :PartnerCampaign.Id])
        {
            hasCampaignRegions.add(thispartnerCampaign.Partner_Region__c);
        }
        if(hasCampaignRegions.contains(PartnerCampaign.Partner_Region__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, PartnerCampaign.Partner_Region__c + ' already has a campaign, please select another Account Region.'));
        }
        else
        {        
            upsert PartnerCampaign;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Partner Campaign was saved.'));
        }
        //PageReference retPage = new PageReference('/apex/NewEditPartnerCampaign?id=' + PartnerCampaign.Id);
        //retPage.setRedirect(true);
        return null; 
    }
}