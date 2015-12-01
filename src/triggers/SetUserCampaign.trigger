trigger SetUserCampaign on User (after insert, after update) 
{
    Set<Id> needToAddCampaignUserIds = new Set<Id>();
    Set<Id> needToDeleteCampaignUserIds = new Set<Id>();
    for(User u : Trigger.New)
    {
        if(Trigger.isInsert)
        {
            needToAddCampaignUserIds.add(u.Id);
        }
        else if(Trigger.isUpdate)
        {
            User oldU = trigger.oldMap.get(u.Id);
            if(u.IsActive && !oldU.isActive)
            {
                needToAddCampaignUserIds.add(u.Id);
            }
            else if(!u.IsActive && oldU.isActive)
            {
                needToDeleteCampaignUserIds.add(u.Id);
            }
        }
    }
    if(needToAddCampaignUserIds.size() > 0 )
    {
        setUserCampaign.createCampaign(needToAddCampaignUserIds);
    }
    else if(needToDeleteCampaignUserIds.size() > 0 )
    {
         setUserCampaign.deleteCampaign(needToDeleteCampaignUserIds);    
    }
}