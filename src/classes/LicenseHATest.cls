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
private class LicenseHATest {
    
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
            
            License_EUM_Details__c eum =  new License_EUM_Details__c();
	        eum.License__c = lic.id;
	        eum.AccountName__c = 'TestEUM';
	        insert eum;
	        
	        EUM_Mobile__c eumMobile = new EUM_Mobile__c();
	        eumMobile.Allow_overages__c = false;
	        eumMobile.License_EUM_Detail__c = eum.id;
	        eumMobile.Type__c = 'LITE';
	        eumMobile.Units__c = 1;
	        insert eumMobile;
	        
	        EUM_Web__c eumWeb = new EUM_Web__c();
	        eumWeb.Allow_overages__c = false;
	        eumWeb.License_EUM_Detail__c = eum.id;
	        eumWeb.Type__c = 'LITE';
	        eumWeb.Units__c = 1;
	        insert eumWeb;
                
        }
        
        //insert licenses;
        //insert licenseAgents;
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

    static testMethod void testHALicenseInit() {
        createLicense();
        String licenseId = 'a01U0000000LtsIIAS';
        LicenseDetail__c lic = [Select ID from LicenseDetail__c limit 1];
        if(lic==null){
            return;
        }
        licenseId = lic.Id;
        
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
        Pagereference ref = new PageReference('/apex/HALicensePage');
        Test.setCurrentPage(ref);
        ApexPages.currentPage().getParameters().put('licenseId',licenseId);
        
        HALicenseController ctrler = new HALicenseController(stdCtrler);
        
        System.assertNotEquals(ctrler.licenseDetailObj,null);
        System.assertEquals(ctrler.licenseDetailObj.IS_HA__c,true);
//        System.assertEquals(ctrler.licenseOpcode,HALicenseController.LICENSE_OPCODE_HA_LICENSE);
    }
    
    static testMethod void testHALicenseSaveFailureNoParameter() {
        createLicense();
        String licenseId = 'a01U0000000LtsIIAS';
        LicenseDetail__c lic = [Select ID from LicenseDetail__c limit 1];
        if(lic==null){
            return;
        }
        licenseId = lic.Id;
        
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
        Pagereference ref = new PageReference('/apex/HALicensePage');
        Test.setCurrentPage(ref);
        //ApexPages.currentPage().getParameters().put('licenseId',licenseId);
        
        HALicenseController ctrler = new HALicenseController(stdCtrler);
        
        try{
        PageReference nextPage = ctrler.doHaSave();
        System.assertEquals(nextPage , null);
        }catch(Exception e){}
    }
    
    static testMethod void testHALicenseSaveFailureBackend() {
        createLicense();
        String licenseId = 'a01U0000000LtsIIAS';
        LicenseDetail__c lic = [Select ID from LicenseDetail__c limit 1];
        if(lic==null){
            return;
        }
        licenseId = lic.Id;
        
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
        Pagereference ref = new PageReference('/apex/HALicensePage');
        Test.setCurrentPage(ref);
        ApexPages.currentPage().getParameters().put('licenseId',licenseId);
        
        HALicenseController ctrler = new HALicenseController(stdCtrler);
        
        try{
        PageReference nextPage = ctrler.dohaSave();
        System.assertEquals(nextPage , null);
        }catch(Exception e){}
    }
    
    static testMethod void testHALicenseSave() {
        createLicense();
        RESTAPI.unitTestMode = true;
        String licenseId = 'a01U0000000LtsIIAS';
        LicenseDetail__c lic = [Select ID from LicenseDetail__c limit 1];
        if(lic==null){
            return;
        }
        licenseId = lic.Id;
        
        BackendConstants.OPCODE_URL_MAP.put(BackendConstants.OPCODE_HA_LICENSE,'http://license.ha');
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
        Pagereference ref = new PageReference('/apex/HALicensePage');
        Test.setCurrentPage(ref);
        ApexPages.currentPage().getParameters().put('licenseId',licenseId);
        
        HALicenseController ctrler = new HALicenseController(stdCtrler);
        
        ctrler.licenseDetailObj.MAC_Address__c ='aa:bb:cc:dd:ee:ff';
        try{
        PageReference nextPage = ctrler.dohaSave();
        }catch(Exception e){}
        //System.assertNotEquals(nextPage , null);
    }
    
    
    static testMethod void testHALicenseCancel() {
        createLicense();
        String licenseId = 'a01U0000000LtsIIAS';
        LicenseDetail__c lic = [Select ID from LicenseDetail__c limit 1];
        if(lic==null){
            return;
        }
        licenseId = lic.Id;
        
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
        Pagereference ref = new PageReference('/apex/HALicensePage');
        Test.setCurrentPage(ref);
        ApexPages.currentPage().getParameters().put('licenseId',licenseId);
        
        HALicenseController ctrler = new HALicenseController(stdCtrler);
        
        PageReference nextPage = ctrler.cancel();
        System.assertNotEquals(nextPage , null);
    }
    
    static testMethod void testHALicenseInit2() {
        
		Opportunity opp = [Select Id from Opportunity LIMIT 1];
        
            LicenseDetail__c lic = new LicenseDetail__c();
            lic.Product_Type__c = 'On-Premise';
            lic.License_BackendID__c = '100';
            lic.License_Expiry_Date__c = System.now().date().addDays(15);
            lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
            //lic.Server_Agents__c  = 10;
            //lic.Net_Agents__c  = 10;
            lic.Stage__c = 'TRIAL';
            insert lic;
            
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
            
            License_EUM_Details__c eum =  new License_EUM_Details__c();
	        eum.License__c = lic.id;
	        eum.AccountName__c = 'TestEUM';
	        insert eum;
	        
	        EUM_Mobile__c eumMobile = new EUM_Mobile__c();
	        eumMobile.Allow_overages__c = false;
	        eumMobile.License_EUM_Detail__c = eum.id;
	        eumMobile.Type__c = 'LITE';
	        eumMobile.Units__c = 1;
	        insert eumMobile;
	        
	        EUM_Web__c eumWeb = new EUM_Web__c();
	        eumWeb.Allow_overages__c = false;
	        eumWeb.License_EUM_Detail__c = eum.id;
	        eumWeb.Type__c = 'LITE';
	        eumWeb.Units__c = 1;
	        insert eumWeb;
                
            License_Opportunity__c licOpp = new License_Opportunity__c();
            licOpp.Opportunity__c = opp.id;
            licOpp.license__c = lic.id;
        	insert licOpp;
			
		
        String licenseId = lic.Id;
        
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
        Pagereference ref = new PageReference('/apex/HALicensePage');
        Test.setCurrentPage(ref);
        ApexPages.currentPage().getParameters().put('licenseId',licenseId);
        
        HALicenseController ctrler = new HALicenseController(stdCtrler);
        
        PageReference nextPage = ctrler.cancel();
        System.assertNotEquals(nextPage , null);
    }
    
    static testMethod void testHALicenseInit3() {
        
		Opportunity opp = [Select Id from Opportunity LIMIT 1];
        
            LicenseDetail__c lic = new LicenseDetail__c();
            lic.Product_Type__c = 'On-Premise';
            lic.License_BackendID__c = '100';
            lic.License_Expiry_Date__c = System.now().date().addDays(15);
            lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
            //lic.Server_Agents__c  = 10;
            //lic.Net_Agents__c  = 10;
            lic.Stage__c = 'TRIAL';
            insert lic;
            
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
            
            License_EUM_Details__c eum =  new License_EUM_Details__c();
	        eum.License__c = lic.id;
	        eum.AccountName__c = 'TestEUM';
	        insert eum;
	        
	        EUM_Mobile__c eumMobile = new EUM_Mobile__c();
	        eumMobile.Allow_overages__c = false;
	        eumMobile.License_EUM_Detail__c = eum.id;
	        eumMobile.Type__c = 'LITE';
	        eumMobile.Units__c = 2;
	        insert eumMobile;
	        
	        EUM_Web__c eumWeb = new EUM_Web__c();
	        eumWeb.Allow_overages__c = false;
	        eumWeb.License_EUM_Detail__c = eum.id;
	        eumWeb.Type__c = 'LITE';
	        eumWeb.Units__c = 2;
	        insert eumWeb;
                
            License_Opportunity__c licOpp = new License_Opportunity__c();
            licOpp.Opportunity__c = opp.id;
            licOpp.license__c = lic.id;
        	insert licOpp;
			
		
        String licenseId = lic.Id;
        
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
        Pagereference ref = new PageReference('/apex/HALicensePage');
        Test.setCurrentPage(ref);
        ApexPages.currentPage().getParameters().put('licenseId',licenseId);
        
        HALicenseController ctrler = new HALicenseController(stdCtrler);
        
        PageReference nextPage = ctrler.cancel();
        System.assertNotEquals(nextPage , null);
    }
    
    static testMethod void testHALicenseInit4() {
        
		Opportunity opp = [Select Id from Opportunity LIMIT 1];
        
            LicenseDetail__c lic = new LicenseDetail__c();
            lic.Product_Type__c = 'On-Premise';
            lic.License_BackendID__c = '100';
            lic.License_Expiry_Date__c = System.now().date().addDays(15);
            lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
            //lic.Server_Agents__c  = 10;
            //lic.Net_Agents__c  = 10;
            lic.Stage__c = 'TRIAL';
            insert lic;
            
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
            
            License_EUM_Details__c eum =  new License_EUM_Details__c();
	        eum.License__c = lic.id;
	        eum.AccountName__c = 'TestEUM';
	        insert eum;
	        
	        EUM_Mobile__c eumMobile = new EUM_Mobile__c();
	        eumMobile.Allow_overages__c = true;
	        eumMobile.License_EUM_Detail__c = eum.id;
	        eumMobile.Type__c = 'LITE';
	        eumMobile.Units__c = 2;
	        insert eumMobile;
	        
	        EUM_Web__c eumWeb = new EUM_Web__c();
	        eumWeb.Allow_overages__c = true;
	        eumWeb.License_EUM_Detail__c = eum.id;
	        eumWeb.Type__c = 'LITE';
	        eumWeb.Units__c = 2;
	        insert eumWeb;
                
            License_Opportunity__c licOpp = new License_Opportunity__c();
            licOpp.Opportunity__c = opp.id;
            licOpp.license__c = lic.id;
        	insert licOpp;
			
		
        String licenseId = lic.Id;
        
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
        Pagereference ref = new PageReference('/apex/HALicensePage');
        Test.setCurrentPage(ref);
        ApexPages.currentPage().getParameters().put('licenseId',licenseId);
        
        HALicenseController ctrler = new HALicenseController(stdCtrler);
        
        PageReference nextPage = ctrler.cancel();
        System.assertNotEquals(nextPage , null);
    }
    
    static testMethod void testHALicenseValidateWithLicenseObjectNull() {
        
		Opportunity opp = [Select Id from Opportunity LIMIT 1];
        
            LicenseDetail__c lic = new LicenseDetail__c();
            lic.Product_Type__c = 'On-Premise';
            lic.License_BackendID__c = '100';
            lic.License_Expiry_Date__c = System.now().date().addDays(15);
            lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
            //lic.Server_Agents__c  = 10;
            //lic.Net_Agents__c  = 10;
            lic.Stage__c = 'TRIAL';
            insert lic;
            
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
            
            License_EUM_Details__c eum =  new License_EUM_Details__c();
	        eum.License__c = lic.id;
	        eum.AccountName__c = 'TestEUM';
	        insert eum;
	        
	        EUM_Mobile__c eumMobile = new EUM_Mobile__c();
	        eumMobile.Allow_overages__c = true;
	        eumMobile.License_EUM_Detail__c = eum.id;
	        eumMobile.Type__c = 'LITE';
	        eumMobile.Units__c = 2;
	        insert eumMobile;
	        
	        EUM_Web__c eumWeb = new EUM_Web__c();
	        eumWeb.Allow_overages__c = true;
	        eumWeb.License_EUM_Detail__c = eum.id;
	        eumWeb.Type__c = 'LITE';
	        eumWeb.Units__c = 2;
	        insert eumWeb;
                
            License_Opportunity__c licOpp = new License_Opportunity__c();
            licOpp.Opportunity__c = opp.id;
            licOpp.license__c = lic.id;
        	insert licOpp;
			
		
        String licenseId = lic.Id;
        
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
        Pagereference ref = new PageReference('/apex/HALicensePage');
        Test.setCurrentPage(ref);
        ApexPages.currentPage().getParameters().put('licenseId',licenseId);
        
        HALicenseController ctrler = new HALicenseController(stdCtrler);
        ctrler.licenseDetailObj = null;
        
        ctrler.validateObject();
    }
    
    static testMethod void testHALicenseValidateWithMacAddressNull() {
        
		Opportunity opp = [Select Id from Opportunity LIMIT 1];
        
            LicenseDetail__c lic = new LicenseDetail__c();
            lic.Product_Type__c = 'On-Premise';
            lic.License_BackendID__c = '100';
            lic.License_Expiry_Date__c = System.now().date().addDays(15);
            lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
            //lic.Server_Agents__c  = 10;
            //lic.Net_Agents__c  = 10;
            lic.Stage__c = 'TRIAL';
            insert lic;
            
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
            
            License_EUM_Details__c eum =  new License_EUM_Details__c();
	        eum.License__c = lic.id;
	        eum.AccountName__c = 'TestEUM';
	        insert eum;
	        
	        EUM_Mobile__c eumMobile = new EUM_Mobile__c();
	        eumMobile.Allow_overages__c = true;
	        eumMobile.License_EUM_Detail__c = eum.id;
	        eumMobile.Type__c = 'LITE';
	        eumMobile.Units__c = 2;
	        insert eumMobile;
	        
	        EUM_Web__c eumWeb = new EUM_Web__c();
	        eumWeb.Allow_overages__c = true;
	        eumWeb.License_EUM_Detail__c = eum.id;
	        eumWeb.Type__c = 'LITE';
	        eumWeb.Units__c = 2;
	        insert eumWeb;
                
            License_Opportunity__c licOpp = new License_Opportunity__c();
            licOpp.Opportunity__c = opp.id;
            licOpp.license__c = lic.id;
        	insert licOpp;
			
		
        String licenseId = lic.Id;
        
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
        Pagereference ref = new PageReference('/apex/HALicensePage');
        Test.setCurrentPage(ref);
        ApexPages.currentPage().getParameters().put('licenseId',licenseId);
        
        HALicenseController ctrler = new HALicenseController(stdCtrler);
        
        ctrler.validateObject();
    }
    
    static testMethod void testHALicenseValidateWithInValidMacAddress() {
        
		Opportunity opp = [Select Id from Opportunity LIMIT 1];
        
            LicenseDetail__c lic = new LicenseDetail__c();
            lic.Product_Type__c = 'On-Premise';
            lic.License_BackendID__c = '100';
            lic.License_Expiry_Date__c = System.now().date().addDays(15);
            lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
            //lic.Server_Agents__c  = 10;
            //lic.Net_Agents__c  = 10;
            lic.Stage__c = 'TRIAL';
            insert lic;
            
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
            
            License_EUM_Details__c eum =  new License_EUM_Details__c();
	        eum.License__c = lic.id;
	        eum.AccountName__c = 'TestEUM';
	        insert eum;
	        
	        EUM_Mobile__c eumMobile = new EUM_Mobile__c();
	        eumMobile.Allow_overages__c = true;
	        eumMobile.License_EUM_Detail__c = eum.id;
	        eumMobile.Type__c = 'LITE';
	        eumMobile.Units__c = 2;
	        insert eumMobile;
	        
	        EUM_Web__c eumWeb = new EUM_Web__c();
	        eumWeb.Allow_overages__c = true;
	        eumWeb.License_EUM_Detail__c = eum.id;
	        eumWeb.Type__c = 'LITE';
	        eumWeb.Units__c = 2;
	        insert eumWeb;
                
            License_Opportunity__c licOpp = new License_Opportunity__c();
            licOpp.Opportunity__c = opp.id;
            licOpp.license__c = lic.id;
        	insert licOpp;
			
		
        String licenseId = lic.Id;
        
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
        Pagereference ref = new PageReference('/apex/HALicensePage');
        Test.setCurrentPage(ref);
        ApexPages.currentPage().getParameters().put('licenseId',licenseId);
        
        HALicenseController ctrler = new HALicenseController(stdCtrler);
        ctrler.licenseDetailObj.MAC_Address__c = '11';
        ctrler.validateObject();
    }
}