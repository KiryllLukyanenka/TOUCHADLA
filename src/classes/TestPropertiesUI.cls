/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestPropertiesUI {

    public static testMethod void testInitAction() {
        PropertiesUI property = new PropertiesUI();
        property.initAction();
    }
    
    public static testMethod void testAddNewProperty(){
		PropertiesUI property = new PropertiesUI();
    	property.initAction();
        property.addNewProperty();
    } 
    
    public static testMethod void testCancel(){
    	PropertiesUI property = new PropertiesUI();
    	property.initAction();
        property.addNewProperty();
        property.cancel();
    } 
    
    public static testMethod void testValidateExisitingProperties(){
    	PropertiesUI property = new PropertiesUI();
    	property.initAction();

		for(Portal_Property__c prop :property.properties){
			prop.Key__c = null;
        }
         
        property.showPropertiesTable = true;
         
        property.validate();
    }
    
    public static testMethod void testValidateSuccessExisitingProperties(){
    	PropertiesUI property = new PropertiesUI();
    	property.initAction();

		for(Portal_Property__c prop :property.properties){
			prop.Value__c = 'test';
        }
         
        property.showPropertiesTable = true;
         
        property.validate();
    }  
    
    public static testMethod void testValidateNewProperties(){
		PropertiesUI property = new PropertiesUI();
		property.initAction();
    	 
		Portal_Property__c newProperty = new  Portal_Property__c();        
		newProperty.Key__c = null;
		newProperty.Value__c = null;
		newProperty.Portal_Setting__c = property.portalSettings.Id;
		property.newProperties.add(newProperty);
         
		property.showNewPropertiesTable = true;
         
		property.validate();
    }
    
    public static testMethod void testValidateSuccessNewProperties(){
		PropertiesUI property = new PropertiesUI();
		property.initAction();
    	 
		Portal_Property__c newProperty = new  Portal_Property__c();        
		newProperty.Key__c = 'testing';
		newProperty.Value__c = 'success';
		newProperty.Portal_Setting__c = property.portalSettings.Id;
		property.newProperties.add(newProperty);
         
		property.showNewPropertiesTable = true;
         
		property.validate();
    }
    
    public static testMethod void testValidateFailure(){
		PropertiesUI property = new PropertiesUI();
		property.initAction();
    	
    	property.showNewPropertiesTable = false;
    	property.showPropertiesTable = false;
    	
		property.validate();
    }
    
    public static testMethod void testSaveProperties(){          
		PropertiesUI property = new PropertiesUI();
    	property.initAction();

		property.showPropertiesTable = true;
		
        property.saveList();
    }
    
    public static testMethod void testSavePropertiesWithoutPortalSettingsId(){          
		PropertiesUI property = new PropertiesUI();
    	property.initAction();
		property.showNewPropertiesTable = true;
		Portal_Property__c newProperty = new  Portal_Property__c();
    	newProperty.Key__c = 'test';
		newProperty.Value__c = 'testing';
        property.newProperties.add(newProperty);
        property.saveList();
    } 
}