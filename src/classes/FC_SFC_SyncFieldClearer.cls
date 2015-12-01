global without sharing class FC_SFC_SyncFieldClearer implements FCRM.FCR_ExtensibilityAPI.IExtensibilityPlugin {

    public static final String ACTIVERESPONSEPROCESSED = 'ActiveResponseProcessed'; // Response has been processed on lead or contact
    public static final String INACTIVENONTQRESPONSEPROCESSED ='InactiveNonTQResponseProcessed';	// Inactive and not qualified 
    public static final String INACTIVETQRESPONSEPROCESSED = 'InactiveTQResponseProcessed'; // Inactive but qualified Response has been processed on lead or contact

    global String GetUniqueName() { return 'FC_SFC_SyncFieldClearer' ;}
    global Set<String> RequestedAPIs() { return new Set<String>{ACTIVERESPONSEPROCESSED, INACTIVETQRESPONSEPROCESSED, INACTIVENONTQRESPONSEPROCESSED} ;}
    
    public static String testFieldToClear;
    
    public List<String> getFieldsToClear(String objInContext) 
    {
        List<String> fieldPaths = new List<String>();
		FC_SFC_Sync_Field_Clear_Setting__c globalSetting = FC_SFC_Sync_Field_Clear_Setting__c.getOrgDefaults();        
        if (objInContext == 'Contact' && globalSetting.Active_For_Contacts__c) for (Schema.FieldSetMember fsm : Schema.SObjectType.Contact.FieldSets.Clear_Sync_Fields_After_Response.getFields()) fieldPaths.add(fsm.getFieldPath());
        if (objInContext == 'Lead' && globalSetting.Active_For_Leads__c) for (Schema.FieldSetMember fsm : Schema.SObjectType.Lead.FieldSets.Clear_Sync_Fields_After_Response.getFields()) fieldPaths.add(fsm.getFieldPath());
        if (Test.isRunningTest()) fieldPaths.add(testFieldToClear);
        return fieldPaths;
    }                  
    
    global Map<String,Set<String>> RequestedFields() 
    { 
        return new Map<String, Set<String>>{};
    }
	
    global void ExtensibilityEvent(String eventname, FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs args) 
    {        
        if(eventname==ACTIVERESPONSEPROCESSED || eventname==INACTIVENONTQRESPONSEPROCESSED || eventname == INACTIVETQRESPONSEPROCESSED )
        {
        	List<ID> recordstoprocess;
			if(args.getRecordIDs()==null) return;
			if(args.getRecordIDs().size()>0) recordstoprocess = args.getRecordIDs()[0];
			if(recordstoprocess==null | recordstoprocess.size()==0) return;
			
			String objInContext = String.valueOf(recordstoprocess[0].getSObjectType());
			system.debug(objInContext); 	        	
            
            List<String> fieldsToClear = getFieldsToClear(objInContext);
            system.debug('fieldsToClear: ' + fieldsToClear);
            
            if (fieldsToClear.size() == 0) return;
            
            String query = 'Select ' + String.join(fieldsToClear, ', ') + ' From ' + objInContext + ' Where Id IN :recordstoprocess';           
            Map<Id, sObject> objs = new Map<Id, sObject>(Database.query(query));              
            system.debug('objs: ' + objs);
            
            List<sObject> objsToUpdate = new List<sObject>();
            for (sObject obj : objs.values())
            {
            	for (String field : fieldsToClear)
            	{	
    				if (obj.get(field) != null || obj.get(field) == true) 
    				{
    					if (obj.get(field) == true) obj.put(field, false); 
    					else if (obj.get(field) != false) obj.put(field, null);
	    				objsToUpdate.add(obj);		    					         
    				}    				            			
            	}    				           	
            }        
            
            if (objsToUpdate.size() > 0)
            {
            	Set<Id> objIdToUpdate = new Set<Id>();
            	List<sObject> objsToUpdateDeduped = new List<sObject>();
            	system.debug('objsToUpdate: ' + objsToUpdate);
            	for (sObject obj : objsToUpdate)
            	{
            		if (!objIdToUpdate.contains((Id)obj.get('Id')))
            		{
            			objsToUpdateDeduped.add(obj);
            			objIdToUpdate.add((Id)obj.get('Id'));
            		}
            	}            	
            	system.debug('objsToUpdateDeduped' + objsToUpdateDeduped);
            	update objsToUpdateDeduped;
            }   
                                                                
        }   
        
    }

}