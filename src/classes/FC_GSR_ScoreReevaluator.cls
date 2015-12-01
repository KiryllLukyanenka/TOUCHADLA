public with sharing class FC_GSR_ScoreReevaluator {

	public static Boolean bypassScoreRequirement = false;

    public static void requestHandler(Map<Id, sObject> personRecs, Map<Id, sObject> oldPersonRecs)
    {    	
    	RM_Score_Evaluation_Setting__c setting = RM_Score_Evaluation_Setting__c.getInstance('default');
    	if (setting==null) return;
    	
    	List<Id> personIds = new List<Id>(personRecs.keySet());
    	String firstPersonId = personIds[0];
    	String personType = firstPersonId.startsWith('003') == true ? 'Contact' : 'Lead';
    	String monitoredFieldName =  personType == 'Contact' ? setting.Contact_Trigger_Field__c : setting.Lead_Trigger_Field__c;
    	String scoringField = FCRM.FCR_SupportAPI.GetScoringInfo(personType);    	
    	Map<Id, sObject> personsToProcess = new Map<Id, sObject>();
        for (sObject person : personRecs.values())
        {
        	if(monitoredFieldName != null && (bypassScoreRequirement || (scoringField != null && person.get(scoringField) != null && FCRM.FCR_SupportAPI.GetEvaluationThreshold() != null))
        		&& (person.get(monitoredFieldName) != oldPersonRecs.get((Id)person.get('Id')).get(monitoredFieldName) && person.get(monitoredFieldName) != null && person.get(monitoredFieldName) != false))
        	{
        		if (bypassScoreRequirement)
        		{
        			personsToProcess.put((Id)person.get('Id'), person);	
        		}
        		else
        		{
        			Decimal subtractAmntFromScore = 0;  
        			Decimal addAmntToScore = 0;      			
        			if (person.get('FCRM__FCR_Prior_' + personType + '_Score__c') != null)
        			{
        				subtractAmntFromScore = (Decimal)person.get('FCRM__FCR_Prior_' + personType + '_Score__c');
        				if (person.get('FCRM__FCR_Response_Score__c') != null)
        				{
        					addAmntToScore = (Decimal)person.get('FCRM__FCR_Response_Score__c'); 	
        				}
        			}
        			Decimal currentScore = (Decimal)person.get(scoringField) - subtractAmntFromScore + addAmntToScore;
        			if (currentScore >= (Decimal)FCRM.FCR_SupportAPI.GetEvaluationThreshold())
        			{
        				personsToProcess.put((Id)person.get('Id'), person);		
        			}
        		}        			
        	}
        } 
        
        system.debug('personsToProcess1' + personsToProcess);        
        
        if (personsToProcess.size() == 0) return;
        
        if (setting.Time_Delay_for_Evaluation__c > 0)
        {
        	List<String> personIdList = new List<String>();
        	for (String id : personsToProcess.keySet()) personIdList.add(id);        	
            FCRM.FCR_SupportAPI.ScheduleAsyncOperation(
                'FC_GSR_AsyncPlugin', 
                Datetime.now().addMinutes((Integer)setting.Time_Delay_for_Evaluation__c), 
                String.join(personIdList, ',')
            );        	
        }
        else processPersonRecords(personsToProcess, personType, false);
    }  
    
    public static void processPersonRecords(Map<Id, sObject> personsToProcess, String personType, Boolean isAsyncContext)
    {    	
    	RM_Score_Evaluation_Setting__c setting = RM_Score_Evaluation_Setting__c.getInstance('default');
    	if (setting==null) return;
    	
    	Map<Id, sObject> personRecs = personsToProcess.deepClone();
    	Set<Id> convertedContactIds = new Set<Id>();
    	if (isAsyncContext && personType == 'Lead')
    	{
    		List<Lead> convertedLeads = [Select Id, ConvertedContactId From Lead Where IsConverted = true and Id IN :personRecs.keySet()];
    		for (Lead l : convertedLeads) 
    		{
    			personsToProcess.remove(l.Id);
    			if (setting.Follow_Converted_Lead__c) convertedContactIds.add(l.ConvertedContactId);
    		}
    		if (convertedContactIds.size() > 0)
    		{     
	    		Map<Id, sObject> convertedContactsToProcess = new Map<Id, sObject>([Select Id, FCRM__FCR_Admin_Update_Counter__c, FCRM__FCR_Nurture_Timeout__c, FCRM__FCR_Status__c From Contact Where Id IN :convertedContactIds]);
	    		processPersonRecords(convertedContactsToProcess, 'Contact', false);       			
    		}
    	}
    	
    	if (personsToProcess.size() == 0) return;
    	
    	system.debug('personsToProcess2' + personsToProcess);
    	
        // Remove records that have an active response
        List<Id> personRecIds = new List<Id>();
        for (Id personRecId : personsToProcess.keySet()) personRecIds.add(personRecId);    	
		Map<Id, CampaignMember> activeResponses = new Map<Id, CampaignMember>(FCRM.FCR_SupportAPI.GetActiveResponses(personRecIds));		
		Map<Id, CampaignMember> activeAndOppActiveResponses = new Map<Id, CampaignMember>(FCRM.FCR_SupportAPI.GetActiveAndOpActiveResponses(personRecIds));
		for (CampaignMember cm : activeResponses.values())
		{
			Id personId = cm.ContactId != null ? cm.ContactId : cm.LeadId;
			if (personsToProcess.containsKey(personId)) personsToProcess.remove(personId);
		}        
        
        if (personsToProcess.size() == 0) return;
        
        system.debug('personsToProcess3' + personsToProcess);

		// If Contacts_Allowed_Additional_Response__c = true, a response can be opened up if the contact has an opportunity active response.
		for (Id cmId : activeAndOppActiveResponses.keySet())
		{
			CampaignMember cm = activeAndOppActiveResponses.get(cmId); 
			Id personId = cm.ContactId != null ? cm.ContactId : cm.LeadId;
			if (personsToProcess.containsKey(personId) && !activeResponses.containsKey(cmId) && !setting.Contacts_Allowed_Additional_Response__c)
				personsToProcess.remove(personId);
		}
		
		if (personsToProcess.size() == 0) return;        

		system.debug('personsToProcess4' + personsToProcess);

		// Fetch unopened responses
		List<String> unopenStatusValues = setting.Response_Status_Values__c.split(',');

		Time localTime = DateTime.now().time();		
		Datetime myDate = Date.today() - (Integer)setting.Search_Timeframe_Days__c;
		Datetime minResponseDate = myDate.addHours(localTime.hour()).addMinutes(localTime.minute() - (Integer)setting.Search_Timeframe_Minutes__c).addSeconds(localTime.second());
		
		minResponseDate.addDays((Integer)setting.Search_Timeframe_Days__c * -1);
		minResponseDate.addMinutes((Integer)setting.Search_Timeframe_Minutes__c * -1);		
		
		system.debug('minResponseDate' + minResponseDate);

        List<CampaignMember> unopenedResponses = [Select Id, ContactId, LeadId, 
            FCRM__FCR_Response_Status__c, CampaignId, CRCR_Rescored_Date__c From CampaignMember 
            Where (LeadId IN :personsToProcess.keySet() or ContactId IN :personsToProcess.keySet())
                and FCRM__FCR_Response_Status__c IN :unopenStatusValues
                and FCRM__FCR_Response_Date__c >= :minResponseDate
            Order By FCRM__FCR_Response_Date__c DESC];  
        
        system.debug('unopenedResponses' + unopenedResponses);
        
    	Set<Id> contactIdsToOpen = new Set<Id>();
    	Set<Id> leadIdsToOpen = new Set<Id>(); 
    	Map<Id, Integer> changeFlagMap = new Map<Id, Integer>();
    	Map<Id, sObject> personRecsToUpdate = new Map<Id, sObject>();    
    	Map<Id, CampaignMember> responsesToUpdate = new Map<Id, CampaignMember>();
    	Set<Id> campaignIds = new Set<Id>();
    	for (CampaignMember cm : unopenedResponses) campaignIds.add(cm.CampaignId);
    	Map<Id, Campaign> campaignsById = new Map<Id, Campaign>([Select Id, FCRM__FCR_Bypass_Nurture_Timeout__c From Campaign Where Id IN :campaignIds or Id = :setting.Default_Campaign_ID__c]);
    	
        for (CampaignMember cm : unopenedResponses)
        {
            if (!contactIdsToOpen.contains(cm.ContactId) && !leadIdsToOpen.contains(cm.LeadId) && cm.CRCR_Rescored_Date__c == null)
            {
            	Id personRecId = cm.ContactId != null ? cm.ContactId : cm.LeadId;
            	personsToProcess.remove(personRecId);
            	sObject personRec = personRecs.get(personRecId);
            	
            	// Check if nurture timeout applies and isn't bypassed
            	if ((Date)personRec.get('FCRM__FCR_Nurture_Timeout__c') > Date.today() 
            		&& campaignsById.get(cm.CampaignId).FCRM__FCR_Bypass_Nurture_Timeout__c == false) continue;
            	
				cm.FCRM__FCR_Response_Status__c = personType == 'Contact' ? setting.Contact_Status_after_Response__c : setting.Lead_Status_after_Response__c;
				cm.CRCR_Rescored_Date__c = DateTime.now();
				responsesToUpdate.put(cm.Id, cm);
				
                changeFlagMap.put(personRecId, 4); // Source sync field has changed                     
                personRecsToUpdate.put(personRecId, personRec);							 
            }
        }                 
        
        // personsToProcess is now the set of person Ids that don't have a response to reopen.
        // If Default Campaign Id is populated in the custom setting, then insert new response with default campaign associated
        if (setting.Default_Campaign_ID__c != null && setting.Default_Member_Status__c != null && personsToProcess.size() > 0)
        {
        	List<CampaignMember> cmsWithDefaultCampaignToInsert = new List<CampaignMember>();
        	for (Id personId : personsToProcess.keySet())
        	{
        		sObject personRec = personRecs.get(personId);
        		        		
        		// Check if nurture timeout applies and isn't bypassed
            	if ((Date)personRec.get('FCRM__FCR_Nurture_Timeout__c') > Date.today() 
            		&& campaignsById.get(setting.Default_Campaign_ID__c).FCRM__FCR_Bypass_Nurture_Timeout__c == false) continue; 
            		       		
        		CampaignMember cm = new CampaignMember(
        			Status='Responded', 
        			FCRM__FCR_Response_Date__c=DateTime.now(), 
        			FCRM__FCR_Response_Status__c=setting.Default_Member_Status__c,  
        			CampaignID = setting.Default_Campaign_ID__c
        		);
        		if (personType == 'Contact') cm.ContactId = personId;
        		else if (personType == 'Lead') cm.LeadId = personId;
        		cmsWithDefaultCampaignToInsert.add(cm);
        	}
        	if (cmsWithDefaultCampaignToInsert.size() > 0)
        	{
        		try {
        			Database.insert(cmsWithDefaultCampaignToInsert, false);
        		} catch (Exception e) {
        			// When system tries to insert repeat but repeats aren't allowed
        			system.debug(e.getMessage());
        		}
        	} 
        }
        
        system.debug('responsesToUpdate' + responsesToUpdate);
        
        if (responsesToUpdate.size() > 0)
        {           
            
            FCRM.FCR_SupportAPI.DisableApplicationForContext();
                        
            update responsesToUpdate.values();
            
	        for (sObject obj : personRecsToUpdate.values())
	        {           
                if (personType == 'Contact') obj.put('FCRM__FCR_Status__c', setting.Contact_Status_after_Response__c);
                else obj.put('Status', setting.Lead_Status_after_Response__c);
                obj.put('FCRM__FCR_Admin_Update_Counter__c', (Decimal)obj.get('FCRM__FCR_Admin_Update_Counter__c') == null ? 1 : (Decimal)obj.get('FCRM__FCR_Admin_Update_Counter__c') + 1);
	        }
	        
	        update personRecsToUpdate.values();
	        
	        FCRM.FCR_SupportAPI.UndoDisableApplicationForContext();
	        
	        Set<Id> responsesToSync = new Set<Id>(responsesToUpdate.keySet());  
	        
            FCRM.FCR_SupportAPI.PerformResponseSync(
                personRecsToUpdate.keySet(), 
                responsesToSync, 
                personType == 'Lead' ? 0 : 1,
                changeFlagMap
            );  
        }      	
    } 

}