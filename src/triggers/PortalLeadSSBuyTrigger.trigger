/*
 * Trigger on Lead update for Self-Service Buy Flows. 
 * It will look for an interesting moment of "Buys Agents" and then call the PortalLeadToLicenseManager for 
 * Lead conversion and License claim flows.
 */
trigger PortalLeadSSBuyTrigger on Lead (after update) {
	
	list<PortalLeadToLicenseManagerInput> inputList = new list<PortalLeadToLicenseManagerInput>();
	for(Integer i=0;i<trigger.new.size();i++){
    	Lead leadNewState = trigger.new[i];
	    Lead leadOldState = trigger.old[i];
        System.debug('Lead name : ' + leadNewState.name);
	    String oldStateInterestingMoment = leadOldState.mkto_si__Last_Interesting_Moment_Desc__c;
	    String newStateInterestingMoment = leadNewState.mkto_si__Last_Interesting_Moment_Desc__c;
	    Boolean buyChanges=false; 
	    if('Buys Agents'.equals(newStateInterestingMoment)){
	    	if(!'Buys Agents'.equals(oldStateInterestingMoment)){
	    		System.debug('####SRINIDHI::Buys AGENTS');
	    		buyChanges=true;
	    	}
	    }else if ('Upgrade Agents'.equals(newStateInterestingMoment)){
	    	if(!'Upgrade Agents'.equals(oldStateInterestingMoment)){
	    		System.debug('####SRINIDHI::UPGRADE AGENTS');
	    		buyChanges=true;
	    	}
	    }
		if(buyChanges){//if Buy  -- set to false not to execute until we find a way to integrate the buy
			String convertedCtID = '';
			String convertedAccId = '';
			String convertedOppId = '';
			if(leadNewState.isConverted){
				//Retrieving contact/account/opportunity if the contact is already converted
				convertedCtID = leadNewState.ConvertedContactId;
	    		convertedAccId = leadNewState.ConvertedAccountId;
	    		convertedOppId = leadNewState.ConvertedOpportunityId;
			}
			
			String leadId = leadNewState.id;
			String email = leadNewState.email;
			String leadSource = leadNewState.leadSource;
			PortalLeadToLicenseManagerInput input = PortalLeadToLicenseManagerInput.newInstance(leadId, email, leadSource, true,leadNewState.isConverted,convertedCtID,convertedAccId,convertedOppId);
			input.status = leadNewState.status;
			input.leadOwnerId=leadNewState.OwnerId;
			inputList.add(input);
		}
	}
	if(inputList.size()>0){
    	String key='';	
    	key = CommonUtil.activeInProgressKey();
    	if(key==null){
    		key = '';
    		for(PortalLeadToLicenseManagerInput input:inputList){
	    		key+=input.email;
	    	}
    	}
   		if (!CommonUtil.isInProgress(key)){
	    	CommonUtil.setInProgress(key, true);
			//Call PortalLeadToLicenseManager execute API
			try{
				PortalLeadToLicenseManager.execute(inputList);
			}catch(Exception e){
				EmailUtil.notifyError(e,  null);
				CommonUtil.setInProgress(key, false);
			}
    	}
    }
	
}