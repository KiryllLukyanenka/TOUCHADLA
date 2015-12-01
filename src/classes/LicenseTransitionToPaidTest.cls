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
private class LicenseTransitionToPaidTest {
	
	static void createLicense() {
		Opportunity opp = [Select Id from Opportunity LIMIT 1];
        List<LicenseDetail__c>  licenses = new  List<LicenseDetail__c>();
        for( integer i =0; i<1; i++) {
        	LicenseDetail__c lic = new LicenseDetail__c();
        	lic.Product_Type__c = 'On-Premise';
        	lic.License_BackendID__c = '100';
        	lic.License_Expiry_Date__c = System.now().date().addDays(15);
        	lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
        	//lic.Server_Agents__c  = 10;
        	//lic.Net_Agents__c  = 10;
        	lic.Stage__c = 'TRIAL';
        	insert lic;
        	licenses.add(lic);
        		
        	License_Agent__c laJava = new License_Agent__c();
        	laJava.Agent_Type__c = 'Java';
        	laJava.Count__c = 10;
        	laJava.License__c = lic.id;
			insert laJava;
        	License_Agent__c laNet = new License_Agent__c();
        	laNet.Agent_Type__c = '.Net';
        	laNet.Count__c = 10;
        	laNet.License__c = lic.id;
			insert laNet;
        }
        
        //insert licenses;
        List<License_Opportunity__c> licOpps = new List<License_Opportunity__c>();
        for (integer i =0; i<licenses.size(); i++ ) {
        	LicenseDetail__c lic = licenses.get(i);
        	License_Opportunity__c licOpp = new License_Opportunity__c();
        	licOpp.Opportunity__c = opp.id;
        	licOpp.license__c = lic.id;
        	licOpps.add(licOpp);
        }
       	insert licOpps;
		
	}

    static testMethod void testExtendTrial_TransitionToPaidInit() {
    	createLicense();
    	LicenseDetail__c license = [select Id  from LicenseDetail__c limit 1];
    	if(license==null){
    		return;
    	}
    	String licenseId = license.Id;
    	
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
        Pagereference ref = new PageReference('/apex/LicenseExtend_TransitionPage');
        Test.setCurrentPage(ref);
        ApexPages.currentPage().getParameters().put('LicenseId',licenseId);
        
        LicenseProvision_UpgradeController ctrler = new LicenseProvision_UpgradeController(stdCtrler); ctrler.initAction();
       // ctrler.extendTrial_TransitionToPaidInit();
       	System.assertNotEquals(ctrler.licenseDetailObj,null);
        //System.assertEquals(ctrler.licenseOpcode,LicenseProvision_UpgradeController.LICENSE_OPCODE_TRANSITION_TO_PERMANENT);
    }
    
    static testMethod void testSaveObjectFailureBackend(){
    	createLicense();
    	LicenseDetail__c license = [select Id  from LicenseDetail__c limit 1];
    	if(license==null){
    		return;
    	}
    	String licenseId = license.Id;
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
        Pagereference ref = new PageReference('/apex/LicenseExtend_TransitionPage');
        Test.setCurrentPage(ref);
        ApexPages.currentPage().getParameters().put('LicenseId',licenseId);
        
        LicenseProvision_UpgradeController ctrler = new LicenseProvision_UpgradeController(stdCtrler); ctrler.initAction();
//        ctrler.extendTrial_TransitionToPaidInit();
        PageReference nextPage = ctrler.saveObject();
        System.assertEquals(nextPage,null);
    }
    
    /*static testMethod void testSaveObjectFailureNoParameter(){
    	createLicense();
    	LicenseDetail__c license = [select Id  from LicenseDetail__c limit 1];
    	if(license==null){
    		return;
    	}
    	String licenseId = license.Id;
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
        Pagereference ref = new PageReference('/apex/LicenseExtend_TransitionPage');
        Test.setCurrentPage(ref);
        //ApexPages.currentPage().getParameters().put('LicenseId',licenseId);
        
        LicenseProvision_UpgradeController ctrler = new LicenseProvision_UpgradeController(stdCtrler); ctrler.initAction();
//        ctrler.extendTrial_TransitionToPaidInit();
        
        PageReference nextPage = ctrler.saveObject();
        
        System.assertEquals(nextPage,null);
    }*/
    
    static testMethod void testSaveObject(){
    	createLicense();
    	RESTAPI.unitTestMode = true;
    	LicenseDetail__c license = [select Id  from LicenseDetail__c limit 1];
    	if(license==null){
    		return;
    	}
    	String licenseId = license.Id;
    	BackendConstants.OPCODE_URL_MAP.put(BackendConstants.OPCODE_TRANSITION_TO_PERMANENT,'http://appdynamics.com/license');
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
        Pagereference ref = new PageReference('/apex/LicenseExtend_TransitionPage');
        Test.setCurrentPage(ref);
        ApexPages.currentPage().getParameters().put('LicenseId',licenseId);
        
        LicenseProvision_UpgradeController ctrler = new LicenseProvision_UpgradeController(stdCtrler); ctrler.initAction();
        //ctrler.extendTrial_TransitionToPaidInit();
        PageReference nextPage = ctrler.saveObject();
        //System.assertNotEquals(nextPage,null);
        //System.assertEquals(nextPage,null);
    }
    
    static testMethod void testCancel(){
    	createLicense();
    	LicenseDetail__c license = [select Id  from LicenseDetail__c limit 1];
    	if(license==null){
    		return;
    	}
    	String licenseId = license.Id;
    	
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
        Pagereference ref = new PageReference('/apex/LicenseExtend_TransitionPage');
        Test.setCurrentPage(ref);
        ApexPages.currentPage().getParameters().put('LicenseId',licenseId);
        
        LicenseProvision_UpgradeController ctrler = new LicenseProvision_UpgradeController(stdCtrler); ctrler.initAction();
        //ctrler.extendTrial_TransitionToPaidInit();
        
        PageReference nextPage = ctrler.cancel();
        System.assertNotEquals(nextPage,null);
    }
}