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
private class CommonTests {

    static testMethod void testController_PermissionCheck() {
        Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
        Test.setCurrentPage(ref);
        ApexPages.currentPage().getParameters().put('operation','ProvisionTrial');
        try{
        Controller_PermissionCheck check = new Controller_PermissionCheck();
        }catch(Exception e){}
        ApexPages.currentPage().getParameters().put('operation','ProvisionPaid');
        try{
        Controller_PermissionCheck check = new Controller_PermissionCheck();
        }catch(Exception e){}
        ApexPages.currentPage().getParameters().put('operation','ABC');
        try{
        Controller_PermissionCheck check = new Controller_PermissionCheck();
        }catch(Exception e){}
    }
    
    /*static testMethod void testAccount_OpportunityLicensesTest(){
    	License_Opportunity__c licOpp = [Select License__c,Opportunity__c from License_Opportunity__c where Opportunity__c!='' limit 1];
    	if(licOpp!=null){
    		String oppId= licOpp.Opportunity__c;
    		Opportunity opp = (Opportunity)DataLayerConstants.fetchSingle('Opportunity',oppId);
    		String accId = opp.AccountId+'';
    		Account acc = (Account)DataLayerConstants.fetchSingle('Account',accId);
    		if(acc!=null){
	    		Account_OpportunityLicenses accOpp = new Account_OpportunityLicenses(new ApexPages.Standardcontroller(acc));
	    	}
    	}
    	
    }*/
    
    static testMethod void testEnvironmentalSettings(){
    	EnvironmentSettings.testEnvironmentSettings();
    	EnvironmentSettings en = EnvironmentSettings.instance;	
    	en.getPropertyValue(EnvironmentSettings.backendServerURL);
    }
    
    static testMethod void testAppdConstants(){
    	EnvironmentSettings.testEnvironmentSettings();
    	AppDConstants.getProvisionTrialMaxUnits();
    	try{
    	User usr = [Select Id,UserName,Email from user where ContactId!=''];
    	System.runAs(usr){
    		AppDConstants.getProvisionDefaultDate();
    		AppDConstants.getProvisionTrialMaxUnits();
    	}
    	}catch(Exception e){}
    }
    
    static testMethod void testOppLicController(){
    	Opportunity_LicenseController ctl = new Opportunity_LicenseController(new ApexPages.Standardcontroller(new LicenseDetail__c()));
    }
}