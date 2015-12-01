public with sharing class FC_ResponseReanimator {

	private static FC_ResponseReanimateManager__c setting = FC_ResponseReanimateManager__c.getInstance('default');

    public static void requestHandler(Map<Id, CampaignMember> newMap)
    {
        Set<Id> respPromptCampaignIds = FCRM.FCR_SupportAPI.GetResponsePromptCampaignIDs();
        Map<Id, CampaignMember> respByrespPromptPersonId = new Map<Id, CampaignMember>();        
		
		Map<Id, Campaign> camps = new Map<Id, Campaign>([Select Id, FC_Defer_To_Reanimation__c, FC_Exclude_From_Reanimation__c From Campaign Where Id IN :respPromptCampaignIds]);
		
        for (CampaignMember cm : newMap.values())
        {        	
            if (cm.HasResponded && ((respPromptCampaignIds.contains(cm.CampaignId) && camps.get(cm.CampaignId).FC_Defer_To_Reanimation__c) 
            	|| (respPromptCampaignIds.contains(cm.FCRM__FCR_Campaign_Repeat_Parent__c) && camps.get(cm.FCRM__FCR_Campaign_Repeat_Parent__c).FC_Defer_To_Reanimation__c)))
            {
                respByrespPromptPersonId.put(cm.ContactId == null ? cm.LeadId : cm.ContactId, cm);
            }
        }         
        
        system.debug('respByrespPromptPersonId' + respByrespPromptPersonId);
		
		// Exit if no campaign member records are part of a response prompt campaign and have FC_Defer_To_Reanimation__c = true
		if (respByrespPromptPersonId != null && respByrespPromptPersonId.size() == 0) return;
		
		Map<Id, sObject> personRecById = new Map<Id, sObject>([Select Id From Contact Where Id IN :respByrespPromptPersonId.keySet()]);
		Map<Id, sObject> leadRecById = new Map<Id, sObject>([Select Id From Lead Where Id IN :respByrespPromptPersonId.keySet()]);
		personRecById.putAll(leadRecById);

    	// Remove persons with an active response
        List<Id> personRecIds = new List<Id>();
        for (Id personRecId : respByrespPromptPersonId.keySet()) personRecIds.add(personRecId);    	
		List<CampaignMember> activeResponses = FCRM.FCR_SupportAPI.GetActiveResponses(personRecIds);
		for (CampaignMember cm : activeResponses)
		{
			Id personId = cm.ContactId != null ? cm.ContactId : cm.LeadId;
			if (!newMap.containsKey(cm.Id)) respByrespPromptPersonId.remove(personId);
		}
		
		// Exit if remaining person records have active responses
		if (respByrespPromptPersonId.size() == 0) return; 
		
		List<String> unanimatedStatusValues = setting.Response_Status_Values_to_Consider__c.split(';');
		Date minResponseDate = Date.today() - (Integer)setting.Last_X_Days_Responded_For_Reopen__c; 
        
        List<Id> personRecIds2 = new List<Id>();
        for (Id personRecId : respByrespPromptPersonId.keySet()) personRecIds2.add(personRecId);          
        
        List<CampaignMember> unanimatedResponses = FindDQdOrUnopenedResponses(personRecIds2, unanimatedStatusValues, minResponseDate);  
        
        system.debug('unanimatedResponses' + unanimatedResponses);
        
        if (unanimatedResponses.size() > 0)
        {
            Set<Id> respPromptsToDelete = new Set<Id>();
            List<CampaignMember> respToReopen = new List<CampaignMember>();
            Set<Id> personIdsSeen = new Set<Id>();              
            for (CampaignMember cm : unanimatedResponses)
            {
                Id personId = cm.ContactId == null ? cm.LeadId : cm.ContactId;
                if (!personIdsSeen.contains(personId))
                {
                    // Delete the response Prompt Campaign and re-open DQ'd marketing Campaign
                    CampaignMember respPrompt = respByrespPromptPersonId.get(personId);
                    respPromptsToDelete.add(respPrompt.Id);
                    respToReopen.add(cm);
                    // First person seen will be the most recently created response because of Order By clause 
                    personIdsSeen.add(personId);
                }
            }
            reopenResponses(respToReopen, personRecById);
            deleteResponses(respPromptsToDelete);                                              
            
        }       
    }   
    
	public static List<CampaignMember> FindDQdOrUnopenedResponses(
		List<Id> personIds, 
		List<String> unanimatedStatusValues,
		Date minResponseDate)
	{
		List<CampaignMember> responses = new List<CampaignMember>();
		List<CampaignMember> unanimatedResponses = new List<CampaignMember>(); 
		
		unanimatedResponses = [Select Id, ContactId, LeadId From CampaignMember 
			Where (LeadId IN :personIds or ContactId IN :personIds)
				and FCRM__FCR_Response_Status__c IN :unanimatedStatusValues
				and FCRM__FCR_Response_Date__c > :minResponseDate
				and Campaign.FC_Exclude_From_Reanimation__c = false
				and FC_Reanimation_Date__c = null
			Order By FCRM__FCR_Response_Date__c DESC];
		
		// Add most recent DQ'd or Unopened response	
		if (unanimatedResponses.size() > 0) responses.addAll(getRecentResponses(unanimatedResponses));						
			
		return responses;
	}
	
	// Returns a list of the first CampaignMembers per person id seen in cms. 
	// Assumes the list of CampaignMembers is ordered by most recent (FCRM__FCR_Response_Date__c) in descending order  
	public static List<CampaignMember> getRecentResponses(List<CampaignMember> cms)
	{
		Set<Id> personIdsSeen = new Set<Id>();
		List<CampaignMember> recentResponse = new List<CampaignMember>();
		for (CampaignMember cm : cms)
		{
			if (!personIdsSeen.contains(cm.ContactId) && !personIdsSeen.contains(cm.LeadId))
			{
				recentResponse.add(cm);
				personIdsSeen.add(cm.ContactId != null ? cm.ContactId : cm.LeadId);
			}
		}
		return recentResponse;
	}        
    
    // Reopen marketing responses that are currently Disqualified
    public static void reopenResponses(List<CampaignMember> responses, Map<Id, sObject> personRecById)
    {        
        List<Id> contactsToReopen = new List<Id>();
        List<Id> leadsToReopen = new List<Id>();
    	
		// Reopen responses
        for (CampaignMember cm : responses)
        {        	
        	Id personRecId = cm.ContactId != null ? cm.ContactId : cm.LeadId;
        	sObject personRec = personRecById.get(personRecId);    	
        	
        	if (cm.ContactId != null) contactsToReopen.add(cm.ContactId);
        	else leadsToReopen.add(cm.LeadId);

        	for (Schema.FieldSetMember fieldSetToNow : Schema.SObjectType.CampaignMember.FieldSets.FC_Response_Reanimator_Fields_Set_To_Now.getFields())
        	{
        		if (fieldSetToNow.getType() == DisplayType.Datetime) cm.put(fieldSetToNow.getFieldPath(), Datetime.now());
        		else if (fieldSetToNow.getType() == DisplayType.Date) cm.put(fieldSetToNow.getFieldPath(), Date.today());
        	}

        	for (Schema.FieldSetMember fieldToClear : Schema.SObjectType.CampaignMember.FieldSets.FC_Response_Reanimator_Fields_To_Clear.getFields())
        	{
        		if (fieldToClear.getType() == DisplayType.Boolean) cm.put(fieldToClear.getFieldPath(), false);
        		else cm.put(fieldToClear.getFieldPath(), null);
        	}        		
        	        	
	        cm.FC_Reanimation_Date__c  = Datetime.now();         	
            cm.FCRM__FCR_Response_Status__c = setting.Response_Active_Status_Value__c;
        }
		                  
		update responses;       				      
        
        // Reopen associated person record  
        if (contactsToReopen.size() > 0)
        {
        	List<Contact> contacts = [Select FCRM__FCR_Status__c From Contact Where Id IN :contactsToReopen];
        	for (Contact c : contacts) c.FCRM__FCR_Status__c = setting.Response_Active_Status_Value__c;
        	update contacts;
        }
        else if (leadsToReopen.size() > 0)
        {
        	List<Lead> leads = [Select Status From Lead Where Id IN :leadsToReopen];
        	for (Lead l : leads) l.Status = setting.Response_Active_Status_Value__c;
        	update leads;        	
        }			  
    }

    // Delete response prompt campaigns
    public static void deleteResponses(Set<Id> responseIds)
    {       
        FCRM.FCR_SupportAPI.DisableApplicationForContext(); 
        delete [Select Id From CampaignMember Where Id IN :responseIds];
        FCRM.FCR_SupportAPI.UndoDisableApplicationForContext(); 
    }

}