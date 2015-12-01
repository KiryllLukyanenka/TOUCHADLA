global without sharing class FC_GSR_AsyncPlugin implements FCRM.FCR_ExtensibilityAPI.IExtensibilityPlugin  {

    public static final String TIMEDASYNC = 'TimedAsync';   
    
    global Set<String> RequestedAPIs() { return new Set<String>{TIMEDASYNC} ;}   

    global String GetUniqueName() { return 'FC_GSR_AsyncPlugin' ;}
    
    global Map<String,Set<String>> RequestedFields() 
    { 
        return new Map<String, Set<String>>();
    }    
    
    global void ExtensibilityEvent(String eventname, FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs args) {

        if (eventname == TIMEDASYNC && args.getXMLdata() != null)
        {
            List<String> personIds = args.getXMLdata().split(',');
			String firstPersonId = personIds[0];
    		String personType = firstPersonId.startsWith('003') == true ? 'Contact' : 'Lead';
    		String statusField = personType == 'Contact' ? 'FCRM__FCR_Status__c' : 'Status';
    		String queryStr = 'Select Id, FCRM__FCR_Admin_Update_Counter__c, FCRM__FCR_Nurture_Timeout__c, ' 
    			+ statusField + ' From ' + personType + ' Where Id IN :personIds';   
    		List<sObject> personsToProcessList = Database.query(queryStr);  
    		Map<Id, sObject> personsToProcess = new Map<Id, sObject>(personsToProcessList);   
    		FC_GSR_ScoreReevaluator.processPersonRecords(personsToProcess, personType, true);
        } 
        
        return;
           
    }

}