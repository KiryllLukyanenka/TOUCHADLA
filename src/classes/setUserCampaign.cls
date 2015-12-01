public class setUserCampaign
{
    @future
    public static void createCampaign(Set<Id> userIds)
    {
        Map<Id, String> campaignMap = new Map<Id, String>();
        
        for(User u : [select Id, ContactId, COntact.Account.Partner_Region__c from User where COntact.Account.Partner_Region__c != null and Id in :userIds])
        {
            campaignMap.put(u.ContactId, u.COntact.Account.Partner_Region__c);
        }
        if(campaignMap.keyset().size() > 0 )
        {
            List<CampaignMember> members = new List<CampaignMember>();
            Map<String, Id> regionCampaignMap = new Map<String, Id>();
            for(Partner_Campaign__c partnerCampaign : [select Id, Campaign__c, Campaign__r.Name, Partner_Region__c from Partner_Campaign__c])
            {
                regionCampaignMap.put(partnerCampaign.Partner_Region__c, partnerCampaign.Campaign__c);
                
            }
            for(Id cntId : campaignMap.keyset())
            {
                String region = campaignMap.get(cntId);
                Id campaignId = regionCampaignMap.get(region);
                if(region != null && campaignId != null)
                {
                    CampaignMember partnerUserMember = new CampaignMember(CampaignId = campaignId, ContactId = cntId);
                    members.add(partnerUserMember);
                }
            }
            if(members.size() > 0)
            {
                insert members;
            }
        }
    }
    
    @future
    public static void deleteCampaign(set<Id> userIds)
    {
        Set<Id> cntIds = new Set<Id>();
        for(User u : [select Id, ContactId, COntact.Account.Partner_Region__c from User where COntact.Account.Partner_Region__c != null and Id in :userIds])
        {
            cntIds.add(u.ContactId);
        }
        Set<Id> regionCampaignIds = new Set<Id>();
        for(Partner_Campaign__c partnerCampaign : [select Id, Campaign__c, Campaign__r.Name, Partner_Region__c from Partner_Campaign__c])
        {
            regionCampaignIds.add(partnerCampaign.Campaign__c);            
        }
        delete [select Id from CampaignMember where CampaignId in :regionCampaignIds and ContactId in :cntIds]; 
    }
}