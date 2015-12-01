public class PartnerCampaignsController
{
    public PartnerCampaignsController()
    {
       PartnerCampaigns = [select Id, Campaign__c, Campaign__r.Name, Partner_Region__c from Partner_Campaign__c];
    }
    
    public List<Partner_Campaign__c> PartnerCampaigns {get; set; }
    
    public PageReference CreateNewPartnerCampaign()
    {
        PageReference retPage = new PageReference('/apex/NewEditPartnerCampaign');
        retPage.setRedirect(true);
        return retPage;
    }
}