/*
	TestLicenseHistoryController contains test methods for License History Tracking implementation. 
*/

@IsTest
public with sharing class TestLicenseHistoryController {
	public static testMethod void testLicenseHistoryController_1(){
		LicenseDetail__c lic = new LicenseDetail__c();
		lic.Product_Type__c = 'On-Premise';
        lic.License_BackendID__c = '100';
        lic.License_Expiry_Date__c = System.now().date().addDays(15);
        lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
        lic.Server_Agents__c  = 10;
        lic.Net_Agents__c  = 10;
        lic.Stage__c = 'TRIAL';
        insert lic;
        
        License_History_Tracking__c lht = new License_History_Tracking__c();
        lht.License__c = lic.id;
        lht.License_Operation__c = 'TRIAL';
        lht.Status__c = 'SUCCESS';
        insert lht;
        
        License_History_Property__c lhp = new License_History_Property__c();
        lhp.License_History_Tracking__c = lht.id;
        lhp.New_Value__c = 'PAID';
        lhp.Old_Value__c = 'TRIAL';
        lhp.Property_Field_Name__c = 'Stage__c';
        lhp.Property_Object_Name__c = 'LicenseDetail__c';
        insert lhp;
        
        LicenseHistoryController_V2 lhc = new LicenseHistoryController_V2();
        lhc.setLicenseIdCtrller(lic.id+'');
        String licId = lhc.getLicenseIdCtrller();
        List<LicenseHistoryController_V2.HistoryWrapper> lhw = lhc.licenseHistories;
        for(LicenseHistoryController_V2.HistoryWrapper hw: lhw){
        	String actionString = hw.getActionString();
        }
	}
	
	public static testMethod void testLicenseHistoryController_2(){
		LicenseDetail__c lic = new LicenseDetail__c();
		lic.Product_Type__c = 'On-Premise';
        lic.License_BackendID__c = '100';
        lic.License_Expiry_Date__c = System.now().date().addDays(15);
        lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
        lic.Server_Agents__c  = 10;
        lic.Net_Agents__c  = 10;
        lic.Stage__c = 'TRIAL';
        insert lic;
        
        License_EUM_Details__c eum =  new License_EUM_Details__c();
        eum.License__c = lic.id;
        eum.Type__c = 'LITE';
        eum.Allow_Overages__c = true;
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
        
        lic = (LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c', lic.id);
        Map<String,List<SObject>> relationalLicenseHistoryMap = new Map<String,List<SObject>>();
        LicenseUtil.saveHistory(lic,relationalLicenseHistoryMap,'IN_PROGRESS',false);
	}
	
	public static testMethod void testLicenseHistoryController_3(){
		LicenseDetail__c lic = new LicenseDetail__c();
		lic.Product_Type__c = 'On-Premise';
        lic.License_BackendID__c = '100';
        lic.License_Expiry_Date__c = System.now().date().addDays(15);
        lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
        lic.Server_Agents__c  = 10;
        lic.Net_Agents__c  = 10;
        lic.Stage__c = 'TRIAL';
        insert lic;
        
        License_EUM_Details__c eum =  new License_EUM_Details__c();
        eum.License__c = lic.id;
        eum.Type__c = 'LITE';
        eum.Allow_Overages__c = true;
        eum.AccountName__c = 'TestEUM';
        insert eum;
        
        License_History_Tracking__c lht = new License_History_Tracking__c();
        lht.License__c = lic.id;
        lht.License_Operation__c = 'TRIAL';
        lht.Status__c = 'IN_PROGRESS';
        insert lht;
        
        License_History_Property__c lhp = new License_History_Property__c();
        lhp.License_History_Tracking__c = lht.id;
        lhp.New_Value__c = 'PAID';
        lhp.Old_Value__c = 'TRIAL';
        lhp.Property_Field_Name__c = 'Stage__c';
        lhp.Property_Object_Name__c = 'LicenseDetail__c';
        insert lhp;
        
        License_History_Property__c lhp2 = new License_History_Property__c();
        lhp2.License_History_Tracking__c = lht.id;
        lhp2.New_Value__c = '123123';
        lhp2.Old_Value__c = '234234';
        lhp2.Property_Field_Name__c = 'License_BackendID__c';
        lhp2.Property_Object_Name__c = 'LicenseDetail__c';
        insert lhp2;
        
        lic = (LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c', lic.id);
        
       	LicenseUtil.updateLicenseHistory(lic,lic,'SUCCESS');
	}
	
	public static testMethod void testLicenseHistoryController_4(){
		LicenseDetail__c lic = new LicenseDetail__c();
		lic.Product_Type__c = 'On-Premise';
        lic.License_BackendID__c = '100';
        lic.License_Expiry_Date__c = System.now().date().addDays(15);
        lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
        lic.Server_Agents__c  = 10;
        lic.Net_Agents__c  = 10;
        lic.Stage__c = 'TRIAL';
        insert lic;
        
        License_Agent__c laJava = new License_Agent__c();
        laJava.Agent_Type__c = 'Java';
        laJava.Count__c = 10;
        laJava.License__c = lic.id;
        insert laJava;
        
        License_Agent__c laNet = new License_Agent__c();
        laNet.Agent_Type__c = '.NET';
        laNet.Count__c = 10;
        laNet.License__c = lic.id;
        insert laNet;
        
        License_Agent__c laPHP = new License_Agent__c();
        laPHP.Agent_Type__c = 'PHP';
        laPHP.Count__c = 10;
        laPHP.License__c = lic.id;
        insert laPHP;
        
        License_Agent__c laMachine = new License_Agent__c();
        laMachine.Agent_Type__c = 'Machine';
        laMachine.Count__c = 10;
        laMachine.License__c = lic.id;
        insert laMachine;
        
        License_EUM_Details__c eum =  new License_EUM_Details__c();
        eum.License__c = lic.id;
        eum.Type__c = 'LITE';
        eum.Allow_Overages__c = true;
        eum.AccountName__c = 'TestEUM';
        eum.Agent_Units__c = 1;
        eum.Import_EUM__c = false;
        eum.RUM_Enabled__c = true;
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
        
        lic = (LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c', lic.id);
        
        Map<String,List<SObject>> relationalLicenseHistoryMap = new Map<String,List<SObject>>();
        LicenseUtil.saveHistory(lic,relationalLicenseHistoryMap,'IN_PROGRESS',false);
       	LicenseUtil.updateLicenseHistory(lic,lic,'Failed');
	}
}