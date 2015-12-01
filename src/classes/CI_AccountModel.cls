global class CI_AccountModel implements FCRM.FCR_CampaignInfluenceAPI.ICampaignAttributionPlugin2 {   
    public Integer InstanceNumber = 0;
    
    global String GetUniqueName() { return( (InstanceNumber==0)? 'CI_AccountModel' : 'CI_AccountModel' + String.ValueOf(InstanceNumber+1)); }
    
    global String GetDescription() { return('Account and Opportunity Contact Role Model v2 ' + ((InstanceNumber==0)? '': ' - ' + String.ValueOf(InstanceNumber+1))); }
    
    global String GetManufacturer() { return('Full Circle CRM Inc.'); }
    
    global String GetCopyright() { return ('Copyright © 2012-2013, Full Circle CRM Inc.'); }
    
    global PageReference GetConfigurationPage() 
    { 
        PageReference pr=Page.CI_AccountModelConfig;
        if(InstanceNumber!=0) pr.getParameters().put('instance',String.ValueOf(InstanceNumber));
        return pr;
    }
     
    global Boolean GetSupportsAccountInfluence() { return true; }
    
    global Boolean GetSupportsOpInfluence() {return false ;}
    
    global Boolean GetEnabled() 
    { 
        CI_AccountModelConfig__c cfg = CI_AccountModelConfig__c.getInstance('default');
        return(cfg!=null && cfg.Enabled__c);
    }
    
    global string AccountProcessAttribution(
        Map<ID, Account> accounts, 
        Map<ID, Map<ID, Opportunity>> opportunities,
        Map<ID, Decimal> OpenOpportunityRevenue,
        Map<ID, Decimal> ClosedOpportunityRevenue,
        Map<ID, Decimal> LostOpportunityRevenue,
        String State)
        {
            CI_AccountModelSupport model = new CI_AccountModelSupport(
                OpenOpportunityRevenue, ClosedOpportunityRevenue, LostOpportunityRevenue, InstanceNumber
                );
            
            return model.AccountProcessAttribution(
                accounts, opportunities, State);
        }
        
    global string OpportunityProcessAttribution(
        Map<ID, Opportunity> opportunities,
        Map<ID, Map<ID,CampaignMember>> CreatingContactResponses,
        Map<ID, Map<ID, CampaignMember>> PrimaryContactResponses,
        Map<ID, Map<ID, CampaignMember>> OtherContactResponses,
        String State)
        {
            return null;
        }
    
    global String Start() { return null; }
    global void Finish(String state) {}


    global string AccountProcessAttribution2(
        Map<ID, Account> accounts, 
        Map<ID, Map<ID, Opportunity>> opportunities,
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> OpenOpportunityRevenue,
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> ClosedOpportunityRevenue,
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> LostOpportunityRevenue,
        String state)
        {
            CI_AccountModelSupport model = new CI_AccountModelSupport(
                OpenOpportunityRevenue, ClosedOpportunityRevenue, LostOpportunityRevenue, InstanceNumber
                );
            
            return model.AccountProcessAttribution(
                accounts, opportunities, State);
        }
            
    global string OpportunityProcessAttribution2(
        Map<ID, Opportunity> opportunities,
        Map<ID, Map<ID,CampaignMember>> CreatingContactResponses,
        Map<ID, Map<ID, CampaignMember>> PrimaryContactResponses,
        Map<ID, Map<ID, CampaignMember>> OtherContactResponses,
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> OpenOpportunityRevenue,
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> ClosedOpportunityRevenue,
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> LostOpportunityRevenue,
        String state)
        {
            return null;
        }

    global Boolean GetSetsCMFieldsOnAttribution2() { return false ;}
}