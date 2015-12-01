public with sharing class CI_AccountModelSupport {

    private Map<ID, Decimal> OpenOpportunityRevenue;
    private Map<ID, Decimal> ClosedOpportunityRevenue;
    private Map<ID, Decimal> LostOpportunityRevenue;
    private Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> OpenOpportunityRevenue2;
    private Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> ClosedOpportunityRevenue2;
    private Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> LostOpportunityRevenue2;
    private Integer Instance;
    
	// Get specified configuration or default
	public CI_AccountModelConfig__c getConfigSetting(String configName)
	{ 
        CI_AccountModelConfig__c cfgsetting = CI_AccountModelConfig__c.getInstance(configName);
        if (cfgsetting == null)
        {
            cfgsetting = new CI_AccountModelConfig__c(Name = configName);        	
        }
        return cfgsetting;	
	}    

    private CI_AccountModelConfig__c config;

    // AllRelatedContacts are all contacts related either via account or OpportunityContactRole
    public Map<ID, Contact> AllRelatedContacts;
    
    // CampaignById are all parent Campaigns by Campaign Member Id
    private Map<ID, Campaign> CampaignById;
    
    // PrimaryCampaignIdByOppId is a map of campaign Ids by opp Id
    private Map<ID, ID> PrimaryCampaignIdByOppId = new Map<Id, ID>();
    
    // AccountsToContacts contains a set of all contact IDs for each account
    public Map<ID, Set<ID>> AccountsToContactIDs;
    
    // AccountsToLeadResponses contains a map of accounts to a list of all related lead responses
    public Map<ID, List<CampaignMember>> AccountsToLeadResponses = new Map<ID, List<CampaignMember>>();    
    
    // RelatedOpDetails contains all related opportunities with OpportunityContactRoles queried
    public Map<ID, Opportunity> RelatedOpDetails;
    
    // Trackes the highest weight attributed to a contact or lead per account
    private Map<String, Decimal> highestWeightByPersonId = new Map<String, Decimal>();
    
    // Map of contact Ids to Boolean value, indicating whether contacts have roles that exclude them from influence
    private Map<ID, Boolean> roleExcludedBycontactId = new Map<ID, Boolean>();
    
    private Set<String> campaignTypesToExclude = new Set<String>();

    private Map<String, CI_ContactRoleWeight__c> WeightInfo;
    private Map<String, CI_CampaignSpecificWeight__c> WeightInfoCampaign;    

    public CI_AccountModelSupport(
        Map<ID, Decimal> OpenOpRevenue,
        Map<ID, Decimal> ClosedOpRevenue,
        Map<ID, Decimal> LostOpRevenue,
        Integer instanceNumber)
    {
        this(new Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>>(), 
            new Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>>(),
            new Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>>(),
            instanceNumber);
        OpenOpportunityRevenue = OpenOpRevenue;
        ClosedOpportunityRevenue = ClosedOpRevenue;
        LostOpportunityRevenue = LostOpRevenue;
                
    }

    public CI_AccountModelSupport(
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> OpenOpRevenue2,
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> ClosedOpRevenue2,
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> LostOpRevenue2,
        Integer instanceNumber)
    {
        OpenOpportunityRevenue2 = OpenOpRevenue2;
        ClosedOpportunityRevenue2 = ClosedOpRevenue2;
        LostOpportunityRevenue2 = LostOpRevenue2;
        
        Instance = InstanceNumber;
        
        // Reset earliest based on config
        String InstanceName = (Instance==0) ? 'default' : 'default-'+ String.ValueOf(Instance);
        config = getConfigSetting(InstanceName);
        if(config.Account_Weight__c==null) config.Account_Weight__c = 0;    // Just in case
        
        Map<String,CI_ContactRoleWeight__c> crwentries = CI_ContactRoleWeight__c.getAll();
        WeightInfo = new Map<String, CI_ContactRoleWeight__c>();
        // Key by role for fast lookup of weight
        for(CI_ContactRoleWeight__c crw: crwentries.values()) if (crw.Instance__c == Instance) WeightInfo.put(crw.Role__c, crw);
        
        Map<String,CI_CampaignSpecificWeight__c> cswentries = CI_CampaignSpecificWeight__c.getAll();
        WeightInfoCampaign = new Map<String, CI_CampaignSpecificWeight__c>();
        // Key by type for fast lookup of weight
        for(CI_CampaignSpecificWeight__c csw: cswentries.values()) if (csw.Instance__c == Instance) WeightInfoCampaign.put(csw.Type__c, csw);        
                
    }

    public string AccountProcessAttribution (Map<ID, Account> accounts, 
        Map<ID, Map<ID, Opportunity>> opportunities, String State)
    {
        
        Map<String,CI_CampaignTypeExcluded__c> ctentries = CI_CampaignTypeExcluded__c.getAll();
        for (CI_CampaignTypeExcluded__c cte : ctentries.values())
        {
            if (cte.Instance__c == Instance && cte.Exclude__c) campaignTypesToExclude.add(cte.Campaign_Type__c);
        }       
        
        if(config==null) return null;   // Config should be set by now
        
        // Get the opportunities, along with OpportunityContactRole info for each opportunity
        RelatedOpDetails = getRelatedOpDetails(opportunities);        
        
        // Find earliest date on all opportunities. This helps make the query more selective
        // and build the set of contacts related to the opportunities
        Set<ID> contactswithroles = new Set<ID>();
        DateTime earliest = DateTime.Now();
        
        Set<String> oppTypesToExclude = new Set<String>();
        for (CI_OpportunityTypeExclude__c ote : CI_OpportunityTypeExclude__c.getAll().values()) if (ote.Instance__c == Instance && ote.Exclude__c) oppTypesToExclude.add(ote.Opp_Type__c);

		Set<Id> oppIdsToExclude = new Set<Id>();     
		
        for(Opportunity op: RelatedOpDetails.values())
        {            
        	if (oppTypesToExclude.contains(op.Type)) oppIdsToExclude.add(op.Id); 
        	
            PrimaryCampaignIdByOppId.put(op.Id, op.CampaignId);
            
            // Don't worry about 'none' case here - it will be handled subsequently
            if(config.DateFilter__c!='closed')
            {
                if (op.CreatedDate< earliest) earliest = op.CreatedDate;
            }
            else
            {
                if (op.CreatedDate< earliest) earliest = op.CloseDate;
            }
            for(OpportunityContactRole ocr : op.OpportunityContactRoles)
            {
                contactswithroles.add(ocr.ContactID);   
            }
        }
        
        
        if(config.Search_Days__c!=null && config.DateFilter__c!='none') earliest = earliest.addDays(- config.Search_Days__c.intValue());
        else earliest = DateTime.newInstance(0);

        // Get a list of accounts with oppportunities - those are all we're interested in
        Set<ID> AccountsWithOpportunities = new Set<ID>();  
        for(ID accountid: accounts.keyset())
            if(opportunities.containskey(accountid)) AccountsWithOpportunities.add(accountid);		

        // Query now on all contacts. This incluces all contacts on the account, and 
        // any contacts on an OpportunityContactRole
        AllRelatedContacts = getRelatedContacts(AccountsWithOpportunities, contactswithroles, earliest);        
        
        Set<Id> leadResponseCampaigns = new Set<Id>();
		if (config.Lead_Response_Weight__c > 0 && config.Lead_Account_Lookup_Field__c != null) 
		{
			AccountsToLeadResponses = getRelatedLeadResponsesByAccountId(AccountsWithOpportunities, earliest, config.Lead_Account_Lookup_Field__c);
			for (Id acctId : AccountsToLeadResponses.keySet())
			{
				for (CampaignMember cm : AccountsToLeadResponses.get(acctId))
				{
					leadResponseCampaigns.add(cm.CampaignId);
				}
			}
		}           
        
        CampaignById = getAssociatedCampaigns(AllRelatedContacts, leadResponseCampaigns);           
        
        // Create a map from accounts to contact IDs
        // This will improve efficiency of the final model processing. We could requery on
        // account here, but we're assuming that SOQL calls and record lines is more limited
        // than script lines here.
        AccountsToContactIDs = new Map<ID, Set<ID>>();
        
        for(ID accountid: AccountsWithOpportunities) AccountsToContactIDs.put(accountid, new Set<ID>());
        for(Contact ct: AllRelatedContacts.Values())
        {
            if(ct.AccountID!=null && AccountsToContactIDs.ContainsKey(ct.AccountID)) AccountsToContactIDs.get(ct.AccountID).add(ct.id);
        }
        
        // Now process the revenues - go through each account
        for(ID accountid: AccountsWithOpportunities)
        {   // Loop through each opportunity on each account
            for(Opportunity op: opportunities.get(accountid).values())            
            {   
            	if (oppIdsToExclude.contains(op.Id)) continue;
            	// Add the revenue for that opportunity            	
            	Opportunity opWithCurrencyField = RelatedOpDetails.get(op.Id);
            	Decimal opAmount = (Decimal)opWithCurrencyField.get(config.Currency_Field_Name__c);

                if(config.Include_Zero_Amount_Influence__c==true || (opAmount!=null && opAmount>0)) 
                {
                	 // Don't bother if there's no revenue unless we're capturing zero revenue                	
                	AddRevenueForOpportunity(AccountsToContactIds.get(accountid), AccountsToLeadResponses.get(accountid), RelatedOpDetails.get(op.id), (opAmount==null ? 0 : opAmount));
                }                    
            }
        }
                    
        return null;            
    }

    // Determines whether campaign member will be included in influence calculation
    private Boolean campaignMemberIncluded(CampaignMember cm, Opportunity relatedop, DateTime earliest) 
    {    	
        return (
               cm.FCRM__FCR_Response_Date__c >= earliest
            && (cm.FCRM__FCR_Response_Date__c.Date() <= relatedop.CloseDate || !relatedop.isClosed && !config.CloseDateCutoff__c  )
            && (
                   // Excludes certain campaign types based on a custom field on the campaign called CI_Exclude_From_Influence__c, 
                   // from all influence unless they are the primary campaign
                   (CampaignById != null && CampaignById.get(cm.CampaignId) != null && !CampaignById.get(cm.CampaignId).CI_Exclude_From_Influence__c) 
                || (CampaignById != null && CampaignById.get(cm.CampaignId) != null && CampaignById.get(cm.CampaignId).CI_Exclude_From_Influence__c && PrimaryCampaignIdByOppId != null && PrimaryCampaignIdByOppId.get(relatedop.Id) == cm.CampaignId)
                )
            && ((cm.ContactId == null || cm.LeadId != null || (AllRelatedContacts != null && AllRelatedContacts.get(cm.ContactId) != null && !AllRelatedContacts.get(cm.ContactId).CI_Exclude_From_Influence__c)))
            && (
                // Exclude certain roles unless primary campaign 
                (
                    (cm.ContactId != null && roleExcludedBycontactId != null && roleExcludedBycontactId.containsKey(cm.ContactId))
                    && (
                           (roleExcludedBycontactId.get(cm.ContactId) && PrimaryCampaignIdByOppId != null && PrimaryCampaignIdByOppId != null && PrimaryCampaignIdByOppId.get(relatedop.Id) == cm.CampaignId) 
                        || (!roleExcludedBycontactId.get(cm.ContactId))
                    )
                )
                || (cm.ContactId != null && roleExcludedBycontactId != null && !roleExcludedBycontactId.containsKey(cm.ContactId))
                || (cm.ContactId == null)
            )
            && (campaignTypesToExclude != null && CampaignById != null && CampaignById.get(cm.CampaignId) != null && !campaignTypesToExclude.contains(CampaignById.get(cm.CampaignId).Type))
        );      
    }
    
    // Returns largest weight between new weight and previous weight calculated for either contact or lead
    private Decimal getLargerWeight(CampaignMember cm, String accountId, Decimal newWeight)
    {
        Decimal currentWeight;
        String personId = cm.ContactId + accountId;
        if (highestWeightByPersonId.containsKey(personId))
        {
            currentWeight = highestWeightByPersonId.get(personId);  
        }
        else
        {
            currentWeight = newWeight;
            highestWeightByPersonId.put(personId, currentWeight);
        }       
        return math.max(currentWeight, newWeight);
    }
    
    private Decimal getLargestWeight(CampaignMember cm, String accountId)
    {
        String personId =  cm.ContactId + accountId;
        if (highestWeightByPersonId.containsKey(personId)) return highestWeightByPersonId.get(personId);    
        return 0.0;     
    }

    public void AddRevenueForOpportunity(Set<ID> accountcontactids, List<CampaignMember> relatedLeadResponses, Opportunity relatedop, Decimal Amount) 
    {
        Map<ID, Decimal> OpenOpPoints = new Map<ID, Decimal>();
        Map<ID, Decimal> ClosedOpPoints = new Map<ID, Decimal>();
        Map<ID, Decimal> LostOpPoints = new Map<ID, Decimal>();
        
        DateTime earliest;
        Decimal totalweight = 0;
        
        if(config.Search_Days__c!=null && config.DateFilter__c!='none')
        {
            earliest = (config.DateFilter__c=='create' || config.DateFilter__c==null) ? relatedop.CreatedDate.addDays(- config.Search_Days__c.intValue()) : relatedop.CloseDate.addDays(- config.Search_Days__c.intValue());
        }
        else earliest = DateTime.newInstance(0);
        
        // We need to build a new list of roles that removes duplicate contacts on the opportunity
        // We do this by creating a map keyed on the contact ID. Note that we are only using
        // a map here to remove duplicate contacts
        Map<ID, OpportunityContactRole> rolelist = new Map<ID, OpportunityContactRole>();
        
        for(OpportunityContactRole ocr: relatedop.OpportunityContactRoles)
        {
            String role = ocr.Role == null ? 'No Role' : ocr.Role;
            
            if (config.Attribution_For_Account_Contacts_Only__c && !accountcontactids.contains(ocr.contactid)) continue;    

            if(! rolelist.containskey(ocr.ContactID))
            {   // First role for a contact
                rolelist.put(ocr.ContactID, ocr);  
                roleExcludedBycontactId.put(ocr.ContactID, WeightInfo.containskey(role) ? WeightInfo.get(role).Exclude_From_Influence__c : false);
            }           
            else 
            {   
                // A contact is always assigned the weight of the highest weighted non-excluded contact role. 
                // If there are only excluded roles, take the highest weight of those roles.
                if (roleExcludedBycontactId.get(ocr.ContactID) && WeightInfo.get(role).Exclude_From_Influence__c)
                {
                    // Subsequent role for a contact - replace if the new one has a higher weight
                    Decimal existingweight = (WeightInfo.containskey(rolelist.get(ocr.ContactID).Role))? WeightInfo.get(rolelist.get(ocr.ContactID).Role).Weight__c : 0;
                    Decimal newweight = (WeightInfo.containskey(role))? WeightInfo.get(role).Weight__c : 0;
                    if(newweight>existingweight) rolelist.put(ocr.ContactID, ocr);                      
                }
                // If subsequent role is not excluded, but previous one is, replace with non-excluded role
                else if (roleExcludedBycontactId.get(ocr.ContactID))
                {
                    rolelist.put(ocr.ContactID, ocr);
                    roleExcludedBycontactId.put(ocr.ContactID, false);                  
                }
                else
                {
                    Decimal existingweight = (WeightInfo.containskey(rolelist.get(ocr.ContactID).Role))? WeightInfo.get(rolelist.get(ocr.ContactID).Role).Weight__c : 0;
                    Decimal newweight = (WeightInfo.containskey(role))? WeightInfo.get(role).Weight__c : 0;
                    if(newweight>existingweight) rolelist.put(ocr.ContactID, ocr);                  
                }
            }                          
            
        }             
        
        // Every response on contacts on an account gets one account based point
        // ----------------------------------------------------------------------------------------------------------------
        for(ID contactid: accountcontactids)
        {
            // If this contact was created after the opportunity close date, ignore it
            if((config.Attribution_For_Account_Contacts_Only__c && !accountcontactids.contains(contactid)) 
            	|| AllRelatedContacts.get(contactid).CreatedDate.Date() > relatedop.CloseDate) continue;
            for(CampaignMember cm: AllRelatedContacts.get(contactid).CampaignMembers)
            {
                if (campaignMemberIncluded(cm, relatedop, earliest))
                {
                    Decimal weight = getLargerWeight(cm, relatedop.AccountId, config.Account_Weight__c);
                    TotalWeight += weight;
                    if(relatedop.IsClosed)
                    {
                        if(relatedop.IsWon)
                        {
                            ClosedOpPoints.put(cm.id, (ClosedOpPoints.ContainsKey(cm.id))? ClosedOpPoints.get(cm.id)+weight: weight );
                        }
                        else
                        {
                            LostOpPoints.put(cm.id, (LostOpPoints.ContainsKey(cm.id))? LostOpPoints.get(cm.id)+weight: weight );
                        }
                    }
                    else
                    {
                        OpenOpPoints.put(cm.id, (OpenOpPoints.ContainsKey(cm.id))? OpenOpPoints.get(cm.id)+weight: weight );
                    }
                    
                }
            }
        }
        system.debug('account based points');
        system.debug('1 TotalWeight ' + TotalWeight);    
        system.debug('1 ClosedOpPoints ' + ClosedOpPoints);
        system.debug('1 LostOpPoints ' + LostOpPoints);
        system.debug('1 OpenOpPoints ' + OpenOpPoints);        
        
        // Now grant role based points to responses on contacts on OpportunityContactRoles
        // based on the role
        // ----------------------------------------------------------------------------------------------------------------
        for(OpportunityContactRole ocr: rolelist.values())
        {
            ID contactid = ocr.ContactID;
            if (config.Attribution_For_Account_Contacts_Only__c && !accountcontactids.contains(contactid)) continue;
            Decimal weight;
            // Assign weight from contact role. If Role is null, grab weight value from "No Role" in WeightInfo. 
            if (WeightInfo.containskey(ocr.Role))
            {
                weight = WeightInfo.get(ocr.Role).Weight__c;
            }
            else if (ocr.Role == null) 
            {
                // Allows users to assign weight points to OpContactRoles with Role = null
                weight = WeightInfo.get('No Role').Weight__c;
            }
            else 
            {
                weight = 0;
            }
            if(weight==0) continue;

            for(CampaignMember cm: AllRelatedContacts.get(contactid).CampaignMembers)
            {
                if (campaignMemberIncluded(cm, relatedop, earliest))
                {
                    TotalWeight+= weight;
                    if(relatedop.IsClosed)
                    {
                        if(relatedop.IsWon)
                        {
                            ClosedOpPoints.put(cm.id, (ClosedOpPoints.ContainsKey(cm.id))? ClosedOpPoints.get(cm.id)+weight: weight );
                        }
                        else
                        {
                            LostOpPoints.put(cm.id, (LostOpPoints.ContainsKey(cm.id))? LostOpPoints.get(cm.id)+weight: weight );
                        }
                    }
                    else
                    {
                        OpenOpPoints.put(cm.id, (OpenOpPoints.ContainsKey(cm.id))? OpenOpPoints.get(cm.id)+weight: weight );
                    }
                    
                }
            }
        }        
        system.debug('Role weights');
        system.debug('2 TotalWeight ' + TotalWeight);    
        system.debug('2 ClosedOpPoints ' + ClosedOpPoints);
        system.debug('2 LostOpPoints ' + LostOpPoints);
        system.debug('2 OpenOpPoints ' + OpenOpPoints);        
        
        // Grant Campaign Specific points based off fields on related op
        // ----------------------------------------------------------------------------------------------------------------
        for(OpportunityContactRole ocr: rolelist.values())
        {
            ID contactid = ocr.ContactID;
            // Only earliest response associated with first touch campaign is attributed weight.
            Id firstTouchCmId;
            // Only latest response associated with last touch campaign is attributed weight.
            Id lastTouchCmId; 
            Datetime earliestFirstTouchRespDate;
            Datetime latestLastTouchRespDate;              
            for(CampaignMember cm: AllRelatedContacts.get(contactid).CampaignMembers)
            {                              
            	if (config.Attribution_For_Account_Contacts_Only__c && !accountcontactids.contains(cm.ContactId)) continue;  

                Decimal weight = 0;
                Boolean excludedCmWithPrimaryCampaign = CampaignById.get(cm.CampaignId).CI_Exclude_From_Influence__c && PrimaryCampaignIdByOppId.get(relatedop.Id) == cm.CampaignId;
                Boolean excludedRoleWithPrimaryCampaign = roleExcludedBycontactId.get(cm.ContactId) && PrimaryCampaignIdByOppId.get(relatedop.Id) == cm.CampaignId;
                
                if (relatedop.FCRM__FCR_First_Campaign_Touch__c == cm.CampaignId && !excludedCmWithPrimaryCampaign && !excludedRoleWithPrimaryCampaign && campaignMemberIncluded(cm, relatedop, earliest)) 
                {
                	if (earliestFirstTouchRespDate == null || cm.FCRM__FCR_Response_Date__c < earliestFirstTouchRespDate) 
                	{
                		earliestFirstTouchRespDate = cm.FCRM__FCR_Response_Date__c;
                		firstTouchCmId = cm.Id;
                	} 
                }
                if (relatedop.FCRM__FCR_Last_Campaign_Touch__c == cm.CampaignId && !excludedCmWithPrimaryCampaign && !excludedRoleWithPrimaryCampaign && campaignMemberIncluded(cm, relatedop, earliest)) 
                {
                	if (latestLastTouchRespDate == null || cm.FCRM__FCR_Response_Date__c > latestLastTouchRespDate) 
                	{
                		latestLastTouchRespDate = cm.FCRM__FCR_Response_Date__c;
                		lastTouchCmId = cm.Id;
                	}                 	
                }
                if (PrimaryCampaignIdByOppId.get(relatedop.Id) == cm.CampaignId) 
                {
                    weight += WeightInfoCampaign.get('Primary Campaign Source').Weight__c;
                }                   

                if (weight > 0 && campaignMemberIncluded(cm, relatedop, earliest))
                {
                    // Campaign Specific weighting is additive
                    TotalWeight+= weight;
                    if(relatedop.IsClosed)
                    {
                        if(relatedop.IsWon)
                        {
                            ClosedOpPoints.put(cm.id, (ClosedOpPoints.ContainsKey(cm.id))? ClosedOpPoints.get(cm.id)+weight: weight );
                        }
                        else
                        {
                            LostOpPoints.put(cm.id, (LostOpPoints.ContainsKey(cm.id))? LostOpPoints.get(cm.id)+weight: weight );
                        }
                    }
                    else
                    {
                        OpenOpPoints.put(cm.id, (OpenOpPoints.ContainsKey(cm.id))? OpenOpPoints.get(cm.id)+weight: weight );
                    }
                    
                }                   
            }
            
            if (firstTouchCmId != null)
            {
            	Decimal weight = WeightInfoCampaign.get('First Touch').Weight__c;
                TotalWeight += weight;
                if(relatedop.IsClosed)
                {
                    if (relatedop.IsWon) ClosedOpPoints.put(firstTouchCmId, (ClosedOpPoints.ContainsKey(firstTouchCmId))? ClosedOpPoints.get(firstTouchCmId)+weight: weight );
                    else LostOpPoints.put(firstTouchCmId, (LostOpPoints.ContainsKey(firstTouchCmId))? LostOpPoints.get(firstTouchCmId)+weight: weight );
                } else OpenOpPoints.put(firstTouchCmId, (OpenOpPoints.ContainsKey(firstTouchCmId))? OpenOpPoints.get(firstTouchCmId)+weight: weight );          	
            }
            
            if (lastTouchCmId != null)
            {
            	Decimal weight = WeightInfoCampaign.get('Last Touch').Weight__c;
                TotalWeight += weight;
                if(relatedop.IsClosed)
                {
                    if (relatedop.IsWon) ClosedOpPoints.put(lastTouchCmId, (ClosedOpPoints.ContainsKey(lastTouchCmId))? ClosedOpPoints.get(lastTouchCmId)+weight: weight );
                    else LostOpPoints.put(lastTouchCmId, (LostOpPoints.ContainsKey(lastTouchCmId))? LostOpPoints.get(lastTouchCmId)+weight: weight );
                } else OpenOpPoints.put(lastTouchCmId, (OpenOpPoints.ContainsKey(lastTouchCmId))? OpenOpPoints.get(lastTouchCmId)+weight: weight );                  	
            }            
        }
        system.debug('Camapaign type weight');
        system.debug('3 TotalWeight ' + TotalWeight);    
        system.debug('3 ClosedOpPoints ' + ClosedOpPoints);
        system.debug('3 LostOpPoints ' + LostOpPoints);
        system.debug('3 OpenOpPoints ' + OpenOpPoints);  
                                      
        if (relatedLeadResponses != null && relatedLeadResponses.size() > 0)
        {
	        for(CampaignMember cm: relatedLeadResponses)
	        {
	            if (campaignMemberIncluded(cm, relatedop, earliest))
	            {                
	                TotalWeight += config.Lead_Response_Weight__c;
	                if(relatedop.IsClosed)
	                {
	                    if(relatedop.IsWon)
	                    {
	                        ClosedOpPoints.put(cm.id, (ClosedOpPoints.ContainsKey(cm.id))? ClosedOpPoints.get(cm.id)+config.Lead_Response_Weight__c: config.Lead_Response_Weight__c );
	                    }
	                    else
	                    {
	                        LostOpPoints.put(cm.id, (LostOpPoints.ContainsKey(cm.id))? LostOpPoints.get(cm.id)+config.Lead_Response_Weight__c: config.Lead_Response_Weight__c );
	                    }
	                }
	                else
	                {
	                    OpenOpPoints.put(cm.id, (OpenOpPoints.ContainsKey(cm.id))? OpenOpPoints.get(cm.id)+config.Lead_Response_Weight__c: config.Lead_Response_Weight__c );
	                }
	                
	            }
	        }           	
        }     
        
        system.debug('Related Lead Response Weight');
        system.debug('4 TotalWeight ' + TotalWeight);    
        system.debug('4 ClosedOpPoints ' + ClosedOpPoints);
        system.debug('4 LostOpPoints ' + LostOpPoints);
        system.debug('4 OpenOpPoints ' + OpenOpPoints);          
        
        for(ID cmid: OpenOpPoints.keyset())
        {
            if(OpenOpportunityRevenue2.get(cmid)==null) OpenOpportunityRevenue2.put(cmid, new List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>());
            if(OpenOpPoints.get(cmid) > 0)  // Revenue can be zero (if capturing zero amount influence, but weight must exist to capture info
            {
                Decimal therevenue = Amount * OpenOpPoints.get(cmid) / TotalWeight;
                OpenOpportunityRevenue2.get(cmid).add(new FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue(relatedop.id, therevenue)); 
                if(OpenOpportunityRevenue!=null) OpenOpportunityRevenue.put(cmid, (OpenOpportunityRevenue.containskey(cmid))? therevenue + OpenOpportunityRevenue.get(cmid): therevenue);
            }
        }       
        for(ID cmid: ClosedOpPoints.keyset())
        {
            if(ClosedOpportunityRevenue2.get(cmid)==null) ClosedOpportunityRevenue2.put(cmid, new List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>());
            if(ClosedOpPoints.get(cmid) > 0)
            {
                Decimal therevenue = Amount * ClosedOpPoints.get(cmid) / TotalWeight;
                ClosedOpportunityRevenue2.get(cmid).add(new FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue(relatedop.id, therevenue)); 
                if(ClosedOpportunityRevenue !=null) ClosedOpportunityRevenue.put(cmid, (ClosedOpportunityRevenue.containskey(cmid))? therevenue + ClosedOpportunityRevenue.get(cmid): therevenue);
            }
        }       
        for(ID cmid: LostOpPoints.keyset())
        {
            if(LostOpportunityRevenue2.get(cmid)==null) LostOpportunityRevenue2.put(cmid, new List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>());
            if(LostOpPoints.get(cmid)>0)
            {
                Decimal therevenue = Amount * LostOpPoints.get(cmid) / TotalWeight;
                LostOpportunityRevenue2.get(cmid).add(new FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue(relatedop.id, therevenue)); 
                if(LostOpportunityRevenue!=null) LostOpportunityRevenue.put(cmid, (LostOpportunityRevenue.containskey(cmid))? therevenue + LostOpportunityRevenue.get(cmid): therevenue);
            }
        }       
        
    }
    
    // Get a list of all opportunties on all accounts
    // Subquery to get all OpportunityContactRole objects that have a role defined
    // Return map is keyed by opportunity ID
    // This also requeries for any extra fields we need on opportunity
    // Be sure to pull Amount off the original opportunity though, as it's been adjusted
    // by the caller to handle multi-currency correctly.
    public Map<ID, Opportunity> getRelatedOpDetails(Map<ID, Map<ID, Opportunity>> opportunities)
    {
        // Build set of opportunity keys
        Set<ID> opkeys = new Set<ID>();
        for(Map<ID, Opportunity> opmap: opportunities.values())
        {
            opkeys.addAll(opmap.keyset());
        }
        List<String> fieldNameList = new List<String>();
        for (String fieldname : Schema.SObjectType.Opportunity.fields.getMap().keySet()) fieldNameList.add(fieldname);
        
        String queryClause = 'Select (Select ID, ContactID, Role from OpportunityContactRoles), FCRM__FCR_Last_Campaign_Touch__c, ' + 
        	'Type, Id, CreatedDate, CampaignId, CloseDate, ' + (config.Currency_Field_Name__c != null ? config.Currency_Field_Name__c + ',' : '') + 
        	' isClosed, AccountId, IsWon, FCRM__FCR_First_Campaign_Touch__c' + 
        	' From Opportunity Where Id IN :opkeys';
        Map<ID, Opportunity> results = new Map<ID, Opportunity>();
        for (sObject obj : Database.query(queryClause)) results.put((Id)obj.get('Id'), (Opportunity)obj);                                   
        return results;
    }    
        
    // Get a list of all contacts for the accounts and the OpportunityContactRoles
    // Subquery to get the responses
    // Only our responses are considered in the model
    public Map<ID, Contact> getRelatedContacts(Set<ID> accountids, Set<ID> contactids, DateTime earliest)
    { 
        Map<ID, Contact> results = new Map<ID, Contact>(
            [Select ID, AccountID, CreatedDate, CI_Exclude_From_Influence__c,
                    (Select ID, CampaignId, FCRM__FCR_Response_Date__c, LeadId, ContactId from CampaignMembers 
                    where FCRM__FCR_Response_Date__c!=null And HasResponded=true And FCRM__FCR_Response_Date__c >= :earliest)
                FROM Contact where (AccountID in :accountids or ID in :contactids)]
            );
        return results; 
    }
    
    public Map<ID, List<CampaignMember>> getRelatedLeadResponsesByAccountId(Set<ID> accountids, DateTime earliest, String leadLookupField)
    { 
    	String queryClause = 'Select ID, ' + leadLookupField + ', (Select ID, CampaignId, FCRM__FCR_Response_Date__c, LeadId, ContactId from CampaignMembers ' +  
                    'Where FCRM__FCR_Response_Date__c != null And HasResponded = true And FCRM__FCR_Response_Date__c >= :earliest) ' + 
                'FROM Lead Where (' + leadLookupField + ' IN :accountids and CI_Exclude_From_Influence__c = false)';
        system.debug(queryClause);
        List<Lead> resultsList = Database.query(queryClause);
        Map<ID, Lead> results = new Map<ID, Lead>(resultsList);
        Map<ID, List<CampaignMember>> leadResponsesByAccount = new Map<ID, List<CampaignMember>>();     
        for(Lead ld: results.Values())
        {
            for(CampaignMember cm: ld.CampaignMembers)
            {
	        	if (!leadResponsesByAccount.containsKey((Id)ld.get(leadLookupField))) leadResponsesByAccount.put((Id)ld.get(leadLookupField), new List<CampaignMember>());
	        	leadResponsesByAccount.get((Id)ld.get(leadLookupField)).add(cm);
            }
        }
        return leadResponsesByAccount; 
    }    
     
    // Get a list of all parent campaigns for campaign members 
    // Used to determine which campaigns aren't included in influence attribution    
    private Map<ID, Campaign> getAssociatedCampaigns(Map<ID, Contact> relatedContacts, Set<Id> additionalCampaignIds) 
    {
        Map<ID, Campaign> parentCampaigns = new Map<ID, Campaign>();
        Set<Id> campaignIds = new Set<Id>();
        for(Contact ct: relatedContacts.Values())
        {
            for(CampaignMember cm: relatedContacts.get(ct.Id).CampaignMembers)
            {
                campaignIds.add(cm.CampaignId);
            }
        }
        if (additionalCampaignIds.size() > 0) campaignIds.addAll(additionalCampaignIds);
        if (campaignIds.size() > 0)
        {
            parentCampaigns = new Map<ID, Campaign>([Select Id, CI_Exclude_From_Influence__c, Type From Campaign Where Id IN :campaignIds or Id IN :additionalCampaignIds]);
        }
        return parentCampaigns;
    }   
  
}