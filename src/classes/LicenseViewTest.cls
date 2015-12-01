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
private class LicenseViewTest {
	
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

    static testMethod void testViewLicenseInit() {
    	//createLicense();
    	List<LicenseDetail__c> lics = new List<LicenseDetail__c>();
    	
    	try{
    		License_Opportunity__c licOpp = [Select License__c from License_Opportunity__c where Opportunity__c!='' and License__r.Stage__c='TRIAL' and License__r.Product_Type__c='On-Premise' limit 1];
    		lics.add((LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licOpp.License__c));
    	}catch(Exception e){}
    	try{
    		License_Opportunity__c licOpp = [Select License__c from License_Opportunity__c where Opportunity__c!='' and License__r.Stage__c='TRIAL' and License__r.Is_Eum__c=true and License__r.Product_Type__c='On-Premise' limit 1];
    		lics.add((LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licOpp.License__c));
    	}catch(Exception e){}
    	try{
    		License_Opportunity__c licOpp = [Select License__c from License_Opportunity__c where Opportunity__c!='' and License__r.Stage__c='PAID_TEMP' and License__r.Product_Type__c='On-Premise'  limit 1];
    		lics.add((LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licOpp.License__c));
    	}catch(Exception e){}
    	try{
    		License_Opportunity__c licOpp = [Select License__c from License_Opportunity__c where Opportunity__c!='' and License__r.Stage__c='PAID_PERMANENT' and License__r.Product_Type__c='On-Premise'  limit 1];
    		lics.add((LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licOpp.License__c));
    	}catch(Exception e){}
    	try{
    		License_Opportunity__c licOpp = [Select License__c from License_Opportunity__c where Opportunity__c!='' and License__r.Stage__c='DISABLED' and License__r.Product_Type__c='On-Premise'  limit 1];
    		lics.add((LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licOpp.License__c));
    	}catch(Exception e){}
    	/*try{
    		License_Opportunity__c licOpp = [Select License__c from License_Opportunity__c where Opportunity__c!='' and License__r.Stage__c='TRIAL_EXPIRED' and License__r.Product_Type__c='On-Premise' limit 1];
    		lics.add((LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licOpp.License__c));
    	}catch(Exception e){}
    	try{
    		License_Opportunity__c licOpp = [Select License__c from License_Opportunity__c where Opportunity__c!='' and License__r.Stage__c='PAID_TEMP_EXPIRED' and License__r.Product_Type__c='On-Premise'  limit 1];
    		lics.add((LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licOpp.License__c));
    	}catch(Exception e){}
    	try{
    		License_Opportunity__c licOpp = [Select License__c from License_Opportunity__c where Opportunity__c!='' and License__r.Stage__c='PAID_PERMANENT_EXPIRED' and License__r.Product_Type__c='On-Premise'  limit 1];
    		lics.add((LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licOpp.License__c));
    	}catch(Exception e){}
    	*/
    	
    	/*try{
    		License_Opportunity__c licOpp = [Select License__c from License_Opportunity__c where Opportunity__c!='' and License__r.Stage__c='TRIAL' and License__r.Product_Type__c like '%SaaS%' limit 1];
    		lics.add((LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licOpp.License__c));
    	}catch(Exception e){}
    	*/
    	try{
    		License_Opportunity__c licOpp = [Select License__c from License_Opportunity__c where Opportunity__c!='' and License__r.Stage__c='PAID_PERMANENT' and License__r.Product_Type__c like '%SaaS%' limit 1];
    		lics.add((LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licOpp.License__c));
    	}catch(Exception e){}
    	for(LicenseDetail__c lic:lics){
    		ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(lic);
	        Pagereference ref = new PageReference('/apex/ViewLicensePage');
	        Test.setCurrentPage(ref);	
	        ViewLicenseController ctrler = new ViewLicenseController(stdCtrler);
        	//System.assertNotEquals(ctrler.licenseDetailObj,null);
    	}
        //System.assertEquals(ctrler.licenseOpcode,ViewLicenseController.LICENSE_OPCODE_VIEW_LICENSE);
    }
    
    static testMethod void testViewLicenseInitNoParameters() {
    	createLicense();
    	String licenseId = 'a01U0000000LtsIIAS';
    	LicenseDetail__c licenseObj = [Select ID from LicenseDetail__c limit 1];
    	if(licenseObj==null){
    		return;
    	}
    	licenseId = licenseObj.Id;
    	
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licenseId);
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(lic);
        Pagereference ref = new PageReference('/apex/ViewLicensePage');
        Test.setCurrentPage(ref);
        
        ViewLicenseController ctrler = new ViewLicenseController(stdCtrler);
        System.assertNotEquals(ctrler.licenseDetailObj,null);
        //System.assertEquals(ctrler.licenseOpcode,ViewLicenseController.LICENSE_OPCODE_VIEW_LICENSE);
    }
    
    
    static testMethod void testViewLicenseInitPaid() {
    	createLicense();
    	String licenseId = 'a01U0000000LxB6IAK';
    	LicenseDetail__c licenseObj = [Select ID,ProcessState__c,Stage__c from LicenseDetail__c limit 1];
    	if(licenseObj==null){
    		return;
    	}
    	licenseId = licenseObj.Id;
    	licenseObj.ProcessState__c = 'SUCCESS';
    	licenseObj.Stage__c = 'PAID_PERMANENT';
    	licenseObj.License_Expiry_Date__c = System.now().date().addDays(2);
    	upsert licenseObj;
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licenseId);
        
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(lic);
        Pagereference ref = new PageReference('/apex/ViewLicensePage');
        Test.setCurrentPage(ref);
        
        ViewLicenseController ctrler = new ViewLicenseController(stdCtrler);
        ctrler.initAction();
        
        System.assertEquals(ctrler.licenseDetailObj.Stage__c,'PAID_PERMANENT');
        System.assertNotEquals(ctrler.licenseDetailObj,null);
        licenseObj.Stage__c = 'TRIAL';
        upsert licenseObj;
        //System.assertEquals(ctrler.licenseOpcode,ViewLicenseController.LICENSE_OPCODE_VIEW_LICENSE);
    }
    
    
    static testMethod void testViewLicenseInitTrial1() {
    	createLicense();
    	String licenseId = 'a01U0000000LxB6IAK';
    	LicenseDetail__c licenseObj = [Select ID,ProcessState__c,Stage__c from LicenseDetail__c limit 1];
    	if(licenseObj==null){
    		return;
    	}
    	licenseId = licenseObj.Id;
    	licenseObj.ProcessState__c = 'SUCCESS';
    	licenseObj.Stage__c = 'TRIAL';
    	licenseObj.License_Expiry_Date__c = System.now().date().addDays(2);
    	upsert licenseObj;
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licenseId);
        
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(lic);
        Pagereference ref = new PageReference('/apex/ViewLicensePage');
        Test.setCurrentPage(ref);
        
        ViewLicenseController ctrler = new ViewLicenseController(stdCtrler);
        ctrler.initAction();
        
        System.assertEquals(ctrler.licenseDetailObj.Stage__c,'TRIAL');
        System.assertNotEquals(ctrler.licenseDetailObj,null);
        licenseObj.Stage__c = 'TRIAL';
        upsert licenseObj;
        //System.assertEquals(ctrler.licenseOpcode,ViewLicenseController.LICENSE_OPCODE_VIEW_LICENSE);
    }
    
    
    static testMethod void testViewLicenseInitDisabled() {
    	createLicense();
    	String licenseId = 'a01U0000000LxB6IAK';
    	LicenseDetail__c licenseObj = [Select ID,ProcessState__c,Stage__c from LicenseDetail__c limit 1];
    	if(licenseObj==null){
    		return;
    	}
    	licenseId = licenseObj.Id;
    	licenseObj.ProcessState__c = 'SUCCESS';
    	licenseObj.Stage__c = 'DISABLED';
    	upsert licenseObj;
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licenseId);
        
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(lic);
        Pagereference ref = new PageReference('/apex/ViewLicensePage');
        Test.setCurrentPage(ref);
        
        ViewLicenseController ctrler = new ViewLicenseController(stdCtrler);
        ctrler.initAction();
        
        System.assertEquals(ctrler.licenseDetailObj.Stage__c,'DISABLED');
        System.assertNotEquals(ctrler.licenseDetailObj,null);
        licenseObj.Stage__c = 'TRIAL';
        //upsert licenseObj;
        //System.assertEquals(ctrler.licenseOpcode,ViewLicenseController.LICENSE_OPCODE_VIEW_LICENSE);
    }
    
    static testMethod void testViewLicenseInitExpired() {
    	createLicense();
    	String licenseId = 'a01U0000000LxB6IAK';
    	LicenseDetail__c licenseObj = [Select ID,ProcessState__c,Stage__c from LicenseDetail__c limit 1];
    	if(licenseObj==null){
    		return;
    	}
    	licenseId = licenseObj.Id;
    	licenseObj.ProcessState__c = 'SUCCESS';
    	licenseObj.Stage__c = 'EXPIRED';
    	upsert licenseObj;
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licenseId);
        
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(lic);
        Pagereference ref = new PageReference('/apex/ViewLicensePage');
        Test.setCurrentPage(ref);
        
        ViewLicenseController ctrler = new ViewLicenseController(stdCtrler);
        ctrler.initAction();
        
        System.assertEquals(ctrler.licenseDetailObj.Stage__c,'EXPIRED');
        System.assertNotEquals(ctrler.licenseDetailObj,null);
        licenseObj.Stage__c = 'TRIAL';
        //upsert licenseObj;
        //System.assertEquals(ctrler.licenseOpcode,ViewLicenseController.LICENSE_OPCODE_VIEW_LICENSE);
    }
    
    static testMethod void testViewLicenseInitSaaS() {
    	createLicense();
    	String licenseId = 'a01U0000000LxB6IAK';
    	LicenseDetail__c licenseObj = [Select ID,ProcessState__c,Stage__c,Product_Type__c,IS_EUM__c,Custom_URL_Name__c from LicenseDetail__c limit 1];
    	if(licenseObj==null){
    		return;
    	}
    	licenseId = licenseObj.Id;
    	licenseObj.ProcessState__c = 'SUCCESS';
    	licenseObj.Stage__c = 'EXPIRED';
    	licenseObj.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_SAAS;
    	licenseObj.Custom_URL_Name__c = 'taramsViewLicenseInitSaaS';
    	licenseObj.IS_EUM__c = true;
    	upsert licenseObj;
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licenseId);
        
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(lic);
        Pagereference ref = new PageReference('/apex/ViewLicensePage');
        Test.setCurrentPage(ref);
        
        ViewLicenseController ctrler = new ViewLicenseController(stdCtrler);
        ctrler.initAction();
        
        System.assertEquals(ctrler.licenseDetailObj.Stage__c,'EXPIRED');
        System.assertNotEquals(ctrler.licenseDetailObj,null);
        //licenseObj.Stage__c = 'TRIAL';
        //upsert licenseObj;
        //System.assertEquals(ctrler.licenseOpcode,ViewLicenseController.LICENSE_OPCODE_VIEW_LICENSE);
    }
    
    static testMethod void testViewLicenseInitPaidProgress() {
    	createLicense();
    	String licenseId = 'a01U0000000LxB6IAK';
    	LicenseDetail__c licenseObj = [Select ID from LicenseDetail__c limit 1];
    	if(licenseObj==null){
    		return;
    	}
    	licenseId = licenseObj.Id;
    	
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licenseId);
        lic.ProcessState__c = 'In Progress';
        lic.Server_Agents__c = 545634;
        upsert lic;
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(lic);
        Pagereference ref = new PageReference('/apex/ViewLicensePage');
        Test.setCurrentPage(ref);
        
        ViewLicenseController ctrler = new ViewLicenseController(stdCtrler);
        
        System.assertNotEquals(ctrler.licenseDetailObj,null);
//        System.assertEquals(ctrler.licenseOpcode,ViewLicenseController.LICENSE_OPCODE_VIEW_LICENSE);
        ctrler.pollForStateCompletion();
        //System.assertEquals(ctrler.licenseDetailObj.ProcessState__c,'Completed');
    }
    
    
    static testMethod void testViewLicenseInitTrial() {
    	createLicense();
    	String licenseId = 'a01U0000000LxB6IAK';
    	LicenseDetail__c licenseObj = [Select ID from LicenseDetail__c limit 1];
    	if(licenseObj==null){
    		return;
    	}
    	licenseId = licenseObj.Id;
    	
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licenseId);
        lic.Stage__c = 'Trial';
        lic.License_Expiry_Date__c = System.now().date().addDays(2);
        upsert lic;
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(lic);
        Pagereference ref = new PageReference('/apex/ViewLicensePage');
        Test.setCurrentPage(ref);
        
        ViewLicenseController ctrler = new ViewLicenseController(stdCtrler);
        
        System.assertNotEquals(ctrler.licenseDetailObj,null);
//        System.assertEquals(ctrler.licenseOpcode,ViewLicenseController.LICENSE_OPCODE_VIEW_LICENSE);
    }
    
    static testMethod void testViewLicenseInitExtendedTrial() {
    	createLicense();
    	String licenseId = 'a01U0000000LxB6IAK';
    	LicenseDetail__c licenseObj = [Select ID from LicenseDetail__c limit 1];
    	if(licenseObj==null){
    		return;
    	}
    	licenseId = licenseObj.Id;
    	
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licenseId);
        lic.Stage__c = 'Extended Trial';
        upsert lic;
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(lic);
        Pagereference ref = new PageReference('/apex/ViewLicensePage');
        Test.setCurrentPage(ref);
        
        ViewLicenseController ctrler = new ViewLicenseController(stdCtrler);
        
        System.assertNotEquals(ctrler.licenseDetailObj,null);
//        System.assertEquals(ctrler.licenseOpcode,ViewLicenseController.LICENSE_OPCODE_VIEW_LICENSE);
    }
    
    
    /*static testMethod void testViewLicenseButtonClicks() {
    	
    	try{createLicense();
    	//List<SObject> licenses = DataLayerConstants.fetch('LicenseDetail__c');
    	List<SObject> licenses = DataLayerConstants.fetchMultiple('LicenseDetail__c','IS_EUM__c',false);
    	SObject license = DataLayerConstants.fetchSingle('LicenseDetail__c','IS_EUM__c',true);
    	license = DataLayerConstants.fetchSingle('LicenseDetail__c','IS_EUM__c',false);
    	String licenseId = 'a01U0000000LxB6IAK';
    	LicenseDetail__c licenseObj = [Select ID from LicenseDetail__c limit 1];
    	if(licenseObj==null){
    		return;
    	}
    	licenseId = licenseObj.Id;
    	
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licenseId);
        lic.Stage__c = 'Trial';
        lic.License_Expiry_Date__c = System.now().date().addDays(2);
        upsert lic;
        ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(lic);
        Pagereference ref = new PageReference('/apex/ViewLicensePage');
        Test.setCurrentPage(ref);
        
        ViewLicenseController ctrler = new ViewLicenseController(stdCtrler);
        
        System.assertNotEquals(ctrler.licenseDetailObj,null);
//        System.assertEquals(ctrler.licenseOpcode,ViewLicenseController.LICENSE_OPCODE_VIEW_LICENSE);
        
        PageReference page1 = ctrler.extendTrial();
        
        PageReference page2 = ctrler.transitionToPaid();
        
        PageReference page3 = ctrler.splitLicense();
        
        PageReference page4 = ctrler.haLicense();
        
        PageReference page5 = ctrler.edit();
        
        PageReference page6 = ctrler.saveObject();
    	}catch(Exception e){}
    }*/
}