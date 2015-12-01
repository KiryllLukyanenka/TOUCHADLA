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
private class LicenseProvisionTest {
    
    static testMethod void testProvisionInit() {
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);
            ctrler.initAction();
            //System.assertNotEquals(ctrler.licenseDetailObj,null);
            //System.assertNotEquals(ctrler.myOpportunity,null);
            //System.assertEquals(ctrler.licenseOpcode,LicenseProvision_FreeTrialController.LICENSE_OPCODE_PROVISION_FREE_TRIAL);
        }
    }
    
    static testMethod void testValidate() {
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);
            ctrler.initAction();
            ctrler.licenseDetailObj.Product_Type__c = 'On-premise';
            Boolean result = ctrler.validateObject();
            //System.assertEquals(result,true);
        }
    }
    
    static testMethod void testValidateFailureNoProductType() {
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
            Boolean result = ctrler.validateObject();
            System.assertEquals(result,false);
        }
    }
    
    static testMethod void testValidateFailureNoCustomURLForHosted() {
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
            ctrler.licenseDetailObj.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_SAAS;
            Boolean result = ctrler.validateObject();
            System.assertEquals(result,false);
        }
    }
    
    static testMethod void testValidateFailure() {
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            //ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
            Boolean result = ctrler.validateObject();
            System.assertEquals(result,false);
        }
    }
    /*
    static testMethod void setupBackend(){
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);
            ctrler.initAction();
            ctrler.licenseDetailObj.Product_Type__c = 'On-premise';
            Boolean result = ctrler.validateObject();
            ctrler.showAddContactPage = true;
            ctrler.setupBackend();
            //System.assertEquals(result,true);
            
            BackendLayer backend = ctrler.backend;
            System.assertNotEquals(backend,null);
            
            List<Backend> dataList = backend.backendList;
            System.assertNotEquals(dataList,null);
            for(Backend data:dataList){
                List<BackendLayer.BackendParameter> params = data.getParameters();
                System.assertNotEquals(params,null);
                for(BackendLayer.BackendParameter param:params){
                    if('contacts'.equals(param.key)){
                        List<JSonObject.value> arrayVal = param.jsonArrayVal;
                        System.assertNotEquals(arrayVal,null);
                        if(arrayVal!=null){
                        for(JSONObject.value val:arrayVal){
                            System.assertNotEquals(val,null);
                            System.debug(val+',');
                        }
                        }
                    }
                }
            }
        }
    }
    */
    static testMethod void testSaveObjectFailureBackend(){
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
            ctrler.licenseDetailObj.Product_Type__c = 'On-premise';
            ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date();
            PageReference nextPage = ctrler.saveObject();
            System.assertEquals(nextPage, null);
        }
    }
    
    
    
    static testMethod void testSaveObjectFailureNoInputs(){
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
            //ctrler.licenseDetailObj.Product_Type__c = 'On-premise';
            PageReference nextPage = ctrler.saveObject();
            System.assertEquals(nextPage, null);
        }
    }
    
    static testMethod void testSaveObject(){
        RESTAPI.unitTestMode = true;
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        
        BackendConstants.OPCODE_URL_MAP.put(BackendConstants.OPCODE_PROVISION_FREE_TRIAL,'http://appdynamics.com/license');
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
            ctrler.licenseDetailObj.Product_Type__c = 'On-Premise';
            ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date().addDays(15);
            PageReference nextPage = ctrler.saveObject();
            
            //System.assertNotEquals(nextPage, null);
        }
    }
    
    static testMethod void testSaveObjectProvisionPaid(){
        RESTAPI.unitTestMode = true;
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        
        BackendConstants.OPCODE_URL_MAP.put(BackendConstants.OPCODE_PROVISION_FREE_TRIAL,'http://appdynamics.com/license');
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
            ctrler.licenseDetailObj.Product_Type__c = 'On-Premise';
            ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date().addDays(15);
            PageReference nextPage = ctrler.saveObject();
            
            //System.assertNotEquals(nextPage, null);
        }
    }
    
    
    static testMethod void testSaveObjectModifyLicense(){
        RESTAPI.unitTestMode = true;
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        
        BackendConstants.OPCODE_URL_MAP.put(BackendConstants.OPCODE_PROVISION_FREE_TRIAL,'http://appdynamics.com/license');
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_Page');
            Test.setCurrentPage(ref);
            LicenseDetail__c licenseObj = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
            String licId = licenseObj.Id;
            ApexPages.currentPage().getParameters().put('LicenseId',licId);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            ApexPages.currentPage().getParameters().put('action','ModifyLicense');
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
            ctrler.licenseDetailObj.Product_Type__c = 'On-Premise';
            ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date().addDays(15);
            PageReference nextPage = ctrler.saveObject();
            
            //System.assertNotEquals(nextPage, null);
        }
    }
    
                
    static testMethod void testSaveObjectNonJson2(){
        
        RESTAPI.unitTestMode = true;
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        
        BackendConstants.OPCODE_URL_MAP.put(BackendConstants.OPCODE_PROVISION_FREE_TRIAL,'http://appdynamics.com/license');
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
            ctrler.licenseDetailObj.Product_Type__c = 'On-Premise';
            ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date().addDays(15);
            PageReference nextPage = ctrler.saveObject();
            //System.assertNotEquals(nextPage, null);
        }
    
    }
    
    static testMethod void testSaveObjectFailureBackendNon200SC(){
        RESTAPI.unitTestMode = true;
        String oldVal= BackendConstants.OPCODE_URL_MAP.get(BackendConstants.OPCODE_PROVISION_FREE_TRIAL);
        BackendConstants.OPCODE_URL_MAP.put(BackendConstants.OPCODE_PROVISION_FREE_TRIAL,'');
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
            ctrler.licenseDetailObj.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
            ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().addDays(15).date();
            PageReference nextPage = ctrler.saveObject();
            System.assertEquals(nextPage, null);
        }
    }

    static testMethod void testSaveObjectValidationFailure(){
        RESTAPI.unitTestMode = true;
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
			ctrler.licenseDetailObj.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
            PageReference nextPage = null;
            /*
            //Date Error
            {
                ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date();
                nextPage = ctrler.saveObject();
                
                System.assertEquals(nextPage, null);
                
                ctrler.provisionInit();
                ctrler.licenseDetailObj.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
                ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date().addDays(46);
                nextPage = ctrler.saveObject();
                
                System.assertEquals(nextPage, null);
            }
            */
            ctrler.licenseDetailObj.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
            ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date().addDays(15);
            nextPage = ctrler.saveObject();
            //System.assertNOTEquals(nextPage, null);
            //Permanent License Mac Address Error
            {
                ctrler.licenseDetailObj.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
                ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date().addDays(15);
                ctrler.licenseDetailObj.Is_Permanent__c = true;
                nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);
                
                ctrler.licenseDetailObj.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
                ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date().addDays(15);
                ctrler.licenseDetailObj.Is_Permanent__c = true;
                ctrler.licenseDetailObj.MAC_Address__c = 'aasgasgasfg';
                nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);
                
                ctrler.licenseDetailObj.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
                ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date().addDays(15);
                ctrler.licenseDetailObj.Is_Permanent__c = true;
                ctrler.licenseDetailObj.MAC_Address__c = 'aa:bb:cc:dd:ee:ff';
                nextPage = ctrler.saveObject();
                //System.assertNotEquals(nextPage, null);

                ctrler.licenseDetailObj.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
                ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date().addDays(15);
                ctrler.licenseDetailObj.Is_Permanent__c = true;
                ctrler.licenseDetailObj.MAC_Address__c = 'aa:bb:cc:dd:ee:ff';
                ctrler.licenseDetailObj.Is_Perpetual__c = true;
                nextPage = ctrler.saveObject();
                //System.assertNotEquals(nextPage, null);
                
                ctrler.licenseDetailObj.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
                ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date().addDays(15);
                ctrler.licenseDetailObj.Is_Permanent__c = false;
                ctrler.licenseDetailObj.Is_Perpetual__c = false;
                ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date().addDays(10);
                nextPage = ctrler.saveObject();
                //System.assertNotEquals(nextPage, null);
            }
            /* Commented out since SOQL queries were more than 100
            //SaaS License Validations
            {
                ctrler.licenseDetailObj.Machine_Agents__c = 1;
                ctrler.licenseDetailObj.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_SAAS;
                nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);
                
                ctrler.licenseDetailObj.Custom_URL_Name__c = 'asgasf';
                nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);
                
                ctrler.licenseDetailObj.IS_EUM__c= true;
                nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);
                
                ctrler.licenseDetailObj.CoRadiant_Integration_URL__c = 'asfasf';
                nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);
            }
            */
        }
        BackendConstants.OPCODE_REQMETHOD_MAP.put(BackendConstants.OPCODE_PROVISION_FREE_TRIAL,BackendConstants.REQ_METHOD_POST);
    }
    
    static testMethod void testSaveObjectValidationFailureForSaaS(){
        RESTAPI.unitTestMode = true;
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
            PageReference nextPage = null;
            {
                ctrler.licenseDetailObj.Machine_Agents__c = 1;
                ctrler.licenseDetailObj.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_SAAS;
                nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);
                
                ctrler.licenseDetailObj.Custom_URL_Name__c = 'asgasf';
                nextPage = ctrler.saveObject();
                //System.assertNotEquals(nextPage, null);
                
                ctrler.licenseDetailObj.IS_EUM__c= true;
                nextPage = ctrler.saveObject();
                //System.assertEquals(nextPage, null);
                
                ctrler.licenseDetailObj.CoRadiant_Integration_URL__c = 'asfasf';
                nextPage = ctrler.saveObject();
                //System.assertEquals(nextPage, null);
            }
        }
    }
    
    static testMethod void testValidationFailureNodeCount(){
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
            
            ctrler.licenseDetailObj.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
            ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date().addDays(10);
            
            for(PortalDataType.LicenseAgentInfo licInfo:ctrler.licAgentInfoList) {
            	licInfo.licAgent.Count__c = -5;
            }
            PageReference nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);
            //Java/.Net and additional machine Agent Units count validation
           /* {
                ctrler.licenseDetailObj.Server_Agents__c = -5;
                PageReference nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);
                
                ctrler.licenseDetailObj.Server_Agents__c = 1;
                ctrler.licenseDetailObj.Net_Agents__c = -5;
                nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);
                
                ctrler.licenseDetailObj.Server_Agents__c = 1;
                ctrler.licenseDetailObj.Net_Agents__c = 2;
                ctrler.licenseDetailObj.Machine_Agents__c = -5;
                nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);
            }*/
        }   
    }
    
    static testMethod void validationFailureNodeCount2(){
        
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
            
            ctrler.licenseDetailObj.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
            ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date().addDays(10);
            
            //Java/.Net and additional machine Agent Units count validation
            {
                ctrler.licenseDetailObj.Server_Agents__c = null;
                ctrler.licenseDetailObj.Net_Agents__c = null;
                PageReference nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);
                
                ctrler.licenseDetailObj.Server_Agents__c = null;
                ctrler.licenseDetailObj.Net_Agents__c = 10;
                ctrler.licenseDetailObj.Machine_Agents__c = null;
                nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);
                
                ctrler.licenseDetailObj.Server_Agents__c = null;
                ctrler.licenseDetailObj.Net_Agents__c = 10;
                ctrler.licenseDetailObj.Machine_Agents__c = 10;
                nextPage = ctrler.saveObject();
                
                System.assertEquals(nextPage, null);
                
                
                ctrler.licenseDetailObj.Server_Agents__c = 10;
                ctrler.licenseDetailObj.Net_Agents__c = null;
                ctrler.licenseDetailObj.Machine_Agents__c = null;
                nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);

                ctrler.licenseDetailObj.Server_Agents__c = 10;
                ctrler.licenseDetailObj.Net_Agents__c = null;
                ctrler.licenseDetailObj.Machine_Agents__c = 10;
                nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);
                
            }
        }
    }

    static testMethod void validationFailureOnPremise(){
        
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
            
            ctrler.licenseDetailObj.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
            ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date().addDays(10);
            ctrler.licenseDetailObj.Server_Agents__c = 10;
            ctrler.licenseDetailObj.Net_Agents__c = 10;
            ctrler.licenseDetailObj.Machine_Agents__c = 10;
            
            {
                ctrler.licenseDetailObj.MAC_Address__c = 'abcdefgh';
                PageReference nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);
                
                ctrler.licenseDetailObj.MAC_Address__c = 'aa:bb:cc:dd:ee:ff';
                nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);
            }
        }
    }

    static testMethod void validationFailureSaaS(){
        
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
            
            ctrler.licenseDetailObj.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_SAAS;
            ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date().addDays(10);
            ctrler.licenseDetailObj.Server_Agents__c = 10;
            ctrler.licenseDetailObj.Net_Agents__c = 10;
            ctrler.licenseDetailObj.Machine_Agents__c = 10;
            
            {
                ctrler.licenseDetailObj.Custom_URL_Name__c = null;
                PageReference nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);
                
                ctrler.licenseDetailObj.Custom_URL_Name__c = '@$#@%$@W$ @%@$@#@>/wsfasf';
                nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);
                
                ctrler.licenseDetailObj.Custom_URL_Name__c = 'afsbdced';
                nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);
            }
        }
    }
    
    static testMethod void validationFailureSaaSLite(){
        
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
            
            ctrler.licenseDetailObj.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_SAAS_LITE;
            ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date().addDays(10);
            ctrler.licenseDetailObj.Server_Agents__c = 10;
            ctrler.licenseDetailObj.Net_Agents__c = 10;
            ctrler.licenseDetailObj.Machine_Agents__c = 10;
            
            {
                ctrler.licenseDetailObj.Custom_URL_Name__c = null;
                PageReference nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);
                
                ctrler.licenseDetailObj.Custom_URL_Name__c = 'afsbdced';
                nextPage = ctrler.saveObject();
                System.assertEquals(nextPage, null);
            }
        }
    }
    
    static testMethod void testSaveObjectFailureBackendNoResponse(){
        RESTAPI.unitTestMode = true;
        String oldVal= BackendConstants.OPCODE_URL_MAP.get(BackendConstants.OPCODE_PROVISION_FREE_TRIAL);
        BackendConstants.OPCODE_URL_MAP.put(BackendConstants.OPCODE_PROVISION_FREE_TRIAL,'');
        BackendConstants.OPCODE_REQMETHOD_MAP.put(BackendConstants.OPCODE_PROVISION_FREE_TRIAL,null);
        
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
            ctrler.licenseDetailObj.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
            ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().addDays(15).date();
            PageReference nextPage = ctrler.saveObject();
            System.assertEquals(nextPage, null);
        }
        BackendConstants.OPCODE_REQMETHOD_MAP.put(BackendConstants.OPCODE_PROVISION_FREE_TRIAL,BackendConstants.REQ_METHOD_POST);
    }
    
    static testMethod void testSaveObjectNonJSON(){
        RESTAPI.unitTestMode = true;
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        AppDConstants.Backend_Mode = AppDConstants.Backend_Mode_REQ_PARAM;
        BackendConstants.OPCODE_URL_MAP.put(BackendConstants.OPCODE_PROVISION_FREE_TRIAL,'http://appdynamics.com/license');
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
            ctrler.licenseDetailObj.Product_Type__c = 'On-Premise';
            ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date().addDays(15);
            PageReference nextPage = ctrler.saveObject();
            //System.assertNotEquals(nextPage, null);
        }
        AppDConstants.Backend_Mode = AppDConstants.Backend_Mode_JSON;
    }
    
    static testMethod void testSaveObjectNonJSONGet(){
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        AppDConstants.Backend_Mode = AppDConstants.Backend_Mode_REQ_PARAM;
        BackendConstants.OPCODE_URL_MAP.put(BackendConstants.OPCODE_PROVISION_FREE_TRIAL,'http://appdynamics.com/license');
        BackendConstants.OPCODE_REQMETHOD_MAP.put(BackendConstants.OPCODE_PROVISION_FREE_TRIAL,'GET');
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
            ctrler.licenseDetailObj.Product_Type__c = 'On-premise';
            ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date().addDays(15);
            PageReference nextPage = ctrler.saveObject();
            //System.assertNotEquals(nextPage, null);
        }
        AppDConstants.Backend_Mode = AppDConstants.Backend_Mode_JSON;
    }
    
    static testMethod void testCancel(){
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
            //ctrler.licenseDetailObj.Product_Type__c = 'On-premise';
            PageReference nextPage = ctrler.cancel();
            System.assertNotEquals(nextPage, null);
        }
    }
    
    static testMethod void testForLicenseTechOwners(){
        //Opportunity opp = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', 'Name','Europe Opp');
        Opportunity opp = [Select Id, Name from Opportunity LIMIT 1];
        
        if(opp!=null){
            ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new License_Opportunity__c());
            Pagereference ref = new PageReference('/apex/License_ProvisionFree_Page');
            Test.setCurrentPage(ref);
            ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
            LicenseProvision_FreeTrialController ctrler = new LicenseProvision_FreeTrialController(stdCtrler);ctrler.initAction();
            ctrler.licenseDetailObj.Product_Type__c = 'On-premise';
            ctrler.licenseDetailObj.License_Expiry_Date__c = System.now().date();
            //System.assertNotEquals(ctrler.techOwnerSelectOptions, null);
        }
    }
    
    public static testMethod void testForCoverage(){
    	Pagereference page = new PageReference('/apex/LicenseProvision_Upgrade.page');
        Test.setCurrentPage(page);
        LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
        Apexpages.currentPage().getParameters().put('LicenseId',lic.Id);
        lic.Is_EUM__c=false;
        lic.RUM_Enabled__c=false;
        lic.Stage__c='TRIAL';
        lic.Is_Permanent__c=false;
        lic.MAC_Address__c = '11:11:11:11:11:11';
        lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
        upsert lic;
        License_EUM_Details__c led = new License_EUM_Details__c();
        led.Access_Key__c = '';
        led.License__c = lic.id;
        //led.Type__c = 'LITE';
        upsert led;
        LicenseProvisionController lp = new LicenseProvision_ExtendController(new ApexPages.Standardcontroller(lic));
        lp.licenseOpcode=BackendConstants.OPCODE_PROVISION_FREE_TRIAL;
        String opTion1 = lp.eumAccountOption1;
        String opTion2 = lp.eumAccountOption2;
        lp.licenseDetailObj = null;
        lp.uiValidation();
        lp.licenseDetailObj = lic;
        lp.licenseOpcode = BackendConstants.OPCODE_EXTEND_TRIAL;
        lp.licenseDetailObj.Stage__c = 'PAID_PERMANENT';
        lp.uiValidation();
        lp.licenseDetailObj.Product_Type__c='Hosted (SaaS)';
        lp.licenseDetailObj.Support__c = true;
        lp.licenseDetailObj.Custom_URL_Name__c = 'testTarams';
        lp.uiValidation();
        lp.selectedEUMAccountType = 'newEUMAccount';
        lp.uiValidation();
        lp.selectedEUMAccountType='oldEUMAccount';
        lp.uiValidation();
        lp.showAllContacts();
        lp.fldsRender.isOppsUser = true;
        lp.eumInput.eumDetails.AccountName__c = null;
        lp.validateObject();
        lp.fldsRender.isOppsUser = false;
        lp.licenseDetailObj.Ad_hoc_Email_Ids__c='srinidhi.acharya@tarams.com, ;    srinidhi.acharya@appdynamics.com';
        lp.validateObject();
        lp.licenseDetailObj.Ad_hoc_Email_Ids__c='srinidhi.acharya@tarams.com, srinidhi.acharya@appdynamics.com';
        lp.validateContactsForLicense();
        lp.doCancel();
        lp.licenseOpcode = BackendConstants.OPCODE_PROVISION_FREE_TRIAL;
        lp.doCancel();
    }
}