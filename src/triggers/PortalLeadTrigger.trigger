trigger PortalLeadTrigger on Lead (after insert,after update) {
    Lead[] leads = trigger.new;
    List<PortalLeadToLicenseManagerInput> inputList = new List<PortalLeadToLicenseManagerInput>();
    String key='';
    String acctId;
    String oppId;
    Set<String> sEmailIds = new Set<String>();
    if(Trigger.isInsert){
    	//Azure flow
    	//Do the following steps
	    //1. Convert Lead under MSWAS account
	    //2. Make Portal Call to get License
	    //3. Insert LicenseDetail with response from 2
	    //4. Insert new License contact for the license in 3 and contact in 1
	    //5. Insert new License System and mark as License as in 3 and System as Azure
	    //PortalLeadToLicenseManager.execute(azureLeads,'MICROSOFT WINDOWS AZURE STORE');
	    list<String> azureLeads = new list<String>();
  		System.debug('Insert logic called');
	    
	    for(Lead lead:leads){
	        	/*String leadID = lead.id;
	        	PortalLeadToLicenseManagerInput input = PortalLeadToLicenseManagerInput.newInstance(leadID,lead.LeadSource);
	        	input.status = lead.Status;
	        	inputList.add(input);*/
				sEmailIds.add(lead.email);	   
	            //azureLeads.add(lead.Id);
	    }
	    
    } else if(Trigger.isUpdate){
    	//Self service flow
    	
    	{
    		System.debug('Update logic called');
    		for(Integer i=0;i<trigger.new.size();i++){
    			Lead leadNewState = trigger.new[i];
	    		Lead leadOldState = trigger.old[i];
	    		if (leadOldState.isConverted == false && leadNewState.isConverted == true) {
	    			
					//if('Website'.equalsIgnoreCase(leadNewState.LeadSource)){
						
						/*String convertedCtID = leadNewState.ConvertedContactId;
			        	String convertedAccId = leadNewState.ConvertedAccountId;
			        	String convertedOppId = leadNewState.ConvertedOpportunityId;
			        	PortalLeadToLicenseManagerInput input = PortalLeadToLicenseManagerInput.newInstance(convertedCtId,convertedAccId,convertedOppId,leadNewState.LeadSource);
			        	input.email = leadNewState.email;
			        	input.status = leadNewState.status;
			        	inputList.add(input);*/
			        	System.debug('leadNewState.email ' + leadNewState.email);
			        	if(leadNewState.email != null && leadNewState.email != '') {
				        	sEmailIds.add(leadNewState.email);
				        	acctId = leadNewState.ConvertedAccountId;
				        	oppId = leadNewState.ConvertedOpportunityId;
				        	System.debug('Acct id is : ' + acctId);
			        	}
			        	
					//}
				}
	    	}
    	}
    }
	if(sEmailIds.size() > 0) {
    	System.debug('Before isInProgress');	
   		if (PortalLock.acquireLock()){
		    System.debug('Inside if');	
        	System.debug('Calling sync ...');
        	List<String> syncEmailIds = new List<String>();
        	for(String emailIdToSend : sEmailIds) {
        		syncEmailIds.add(emailIdToSend);
        	}
			//PortalLicenseSynch.emailIds = sEmailIds;
			//PortalLicenseSynch.accountIdForLeadConvert = leadNewState.ConvertedAccountId;
			//PortalLicenseSynch.action = PortalLicenseSynch.ACTION_PULL_AND_STORE_LICENSES;
			PortalLicenseSynch.processData(syncEmailIds, acctId, oppId, null);
   		}
   		
   		System.debug('After if');	
   		     		
	}
}