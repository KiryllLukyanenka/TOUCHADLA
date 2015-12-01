trigger CI_AccountModelTrigger on FCRM__FCR_APIHookTrigger__c (after insert) {
    FCRM__FCR_APIHookTrigger__c hookobject = trigger.new[0];
    if(hookobject.FCRM__Hook_Type__c == 'campaigninfluence')
    {
        CI_AccountModel plugin = new CI_AccountModel();
        FCRM.FCR_CampaignInfluenceAPI.RegisterPlugin(plugin);    
		Integer additionalinstances = CI_AccountModelConfigController.GetAdditionalInstanceCount();
		// Only test one instance in test mode
		if(additionalinstances>0 && !Test.IsRunningTest())
		{
			for(Integer i=0; i<additionalinstances; i++)
			{
				plugin = new CI_AccountModel();
				plugin.InstanceNumber = i+1;
				FCRM.FCR_CampaignInfluenceAPI.RegisterPlugin(plugin);
			}
		}

    }

}