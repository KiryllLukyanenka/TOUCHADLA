trigger PortalContactTrigger on Contact (after update) {
	Contact[] leads = trigger.new;
    List<PortalLeadToLicenseManagerInput> inputList = new List<PortalLeadToLicenseManagerInput>();
    
    if(Trigger.isUpdate){
    	//Self service flow
    		for(Integer i=0;i<trigger.new.size();i++){
	    		Contact leadNewState = trigger.new[i];
	    		Contact leadOldState = trigger.old[i];
	    		String oldStateInterestingMoment = leadOldState.mkto_si__Last_Interesting_Moment_Desc__c;
	    		String newStateInterestingMoment = leadNewState.mkto_si__Last_Interesting_Moment_Desc__c;
	    		Boolean buyChanges=false; 
			    if('Buys Agents'.equals(newStateInterestingMoment)){
			    	if(!'Buys Agents'.equals(oldStateInterestingMoment)){
			    		System.debug('Buys AGENTS');
			    		buyChanges=true;
			    	}
			    }else if ('Upgrade Agents'.equals(newStateInterestingMoment)){
			    	//if(!'Upgrade Agents'.equals(oldStateInterestingMoment))
			    	{
			    		System.debug('UPGRADE AGENTS');
			    		buyChanges=true;
			    	}
			    }else if ('Cancels self service buy.'.equals(newStateInterestingMoment)){
			    	if(!'Cancels self service buy.'.equals(oldStateInterestingMoment)){
			    		System.debug('CANCELS AGENTS');
			    		buyChanges=true;
			    	}
			    }
	    		
			 	if(buyChanges) {//if Buy  -- set to false not to execute until we find a way to integrate the buy	
					String convertedCtID = '';
					String convertedAccId = '';
					String convertedOppId = '';
					convertedCtID = leadNewState.Id;
	        		convertedAccId = leadNewState.AccountId;
					String email = leadNewState.email;
					String leadSource = leadNewState.leadSource;
					PortalLeadToLicenseManagerInput input = PortalLeadToLicenseManagerInput.newInstance(null, email, leadSource, true,true,convertedCtID,convertedAccId,convertedOppId);
					input.leadOwnerId = leadNewState.ownerId;
					inputList.add(input);
				}
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