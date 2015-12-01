/*
 * Class Name: PropertiesUI.cls
 * @Author: Giri Bhushan
 *
 * This class is used to fetch/Add portal setting properties depending upon the instance. 
 *  
 */

public virtual class PropertiesUI{
    
    public List <Portal_Property__c> properties{get;set;}
    public List <Portal_Property__c> newProperties{get;set;}
    
    public Portal_Settings__c portalSettings{get;set;}
    
    public String organization{get;set;}
    public String sectionHeaderString{get;set;}
     
    public Boolean showPropertiesTable {get; set;}
    public Boolean showNewPropertiesTable {get; set;}
    public Boolean showCancel {get; set;}
    
    /*
	 *This method is used for getting the OrganizationId, getting an instance of Portal_Settings__c
	 *and to fetch portal porperties using Portal_Settings__c record.        
    */
    public PageReference initAction(){
        if(UserInfo.getOrganizationId().startsWith('00D80000000MDAy')){ //This is AppDynamics Production Salesforce Organization ID
            organization = 'Production';
        }else{
            organization = 'QA';
        }
        
        try{
            portalSettings = [SELECT Id, instance__c from Portal_Settings__c WHERE instance__c= :organization limit 1];
        }catch(Exception e){
            EnvironmentSettings instanceVar = EnvironmentSettings.instance;
            portalSettings = instanceVar.portalSetting; 
        }
        try{    
            if(portalSettings!=null){
                properties = [SELECT Id, Key__c, Value__c, Portal_Setting__r.instance__c, Portal_Setting__c from Portal_Property__c WHERE Portal_Setting__c=:portalSettings.id];
            }
        }catch(Exception e){
            properties = new List <Portal_Property__c>();
        }
        
        sectionHeaderString = 'Properties';
        
        newProperties = new List <Portal_Property__c>();
        
        resetBooleanValues(true,false,false);
        
        return null;   
    }
    
    /*
     *This method is used for creating a new Portal_Property__c instance 
     *and add it in the list of  Portal_Property__c with empty key and value fields.  
     */   
    public PageReference addNewProperty(){
        if(portalSettings!=null){
            sectionHeaderString = 'Add New Properties';
            
            Portal_Property__c newProperty = new  Portal_Property__c(); 
            newProperty.Key__c = '';
            newProperty.Value__c='';
            newProperty.Portal_Setting__c = portalSettings.Id;
            newProperties.add(newProperty);
            
            resetBooleanValues(false,true,true);
        }
        
        return null;
    }
    
    /*
	 *This method is used for redirecting back to the list of properties table if we donot want to add new property   
     *after clicking on the 'Add New Property' button.
    */
    public PageReference cancel(){
        sectionHeaderString = 'Properties';
        
        if(newProperties.size()>0){
            newProperties.clear();
        }  
        
        resetBooleanValues(true,false,false);
        
        return null;
    }
    
    /*
	 *This method is used for doing different kind of Validations
	 *and showing the error message.
    */
    public Boolean validate(){
    	if(showNewPropertiesTable){
	    	for(Portal_Property__c property : newProperties){
	             if(property.Key__c == null || property.Value__c == null){
	             	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter value in all the key and value fields.');
	             	ApexPages.addMessage(myMsg);
	             	return false;
	             }
	    	}
	    	return true;
    	}
    	
        if(showPropertiesTable){     
	        for(Portal_Property__c property : properties){
	             if(property.Key__c == null || property.Value__c == null){
	             	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter value in all the key and value fields.');
	             	ApexPages.addMessage(myMsg);
	             	return false;
	             }
	        }
	        return true;
        }
    	return false;
    }
         
   /*
	*This method is used for updating/inserting the portal properties.
	*Also for displaying the success message after updating and inserting.  
	*/
    public PageReference saveList(){
    	if(validate()){   
			try{
				
	        	if(newProperties.size()>0){
	            	properties.addAll(newProperties);
	            	newProperties.clear();  
	        	}
	        	
	        	sectionHeaderString = 'Properties';
	        
	        	resetBooleanValues(true,false,false);
	        	
	        	upsert properties;
	        	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Records updated successfully.');
				ApexPages.addMessage(myMsg);
	        }catch(Exception e){
	        	
	        	resetBooleanValues(false,true,true);
	        	
	        	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
				ApexPages.addMessage(myMsg);
	        } 
    	}    

        return null;
    }
    
    /*
     *This is a generic method for setting different boolean flags for showing 
     *and hiding different buttons and pageBlockTable in Visualforce page. 
    */
    public void resetBooleanValues(Boolean showPropertiesTable, Boolean showNewPropertiesTable, Boolean showCancel){
        this.showPropertiesTable = showPropertiesTable;
        this.showNewPropertiesTable = showNewPropertiesTable;
        this.showCancel = showCancel;
    }
}