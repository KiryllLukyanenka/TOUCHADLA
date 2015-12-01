@isTest
private class TestSmallClasses {

    @isTest static void testCeligoException(){
        CeligoException celigoException = new CeligoException();
    }
    
    @isTest static void testCeligoUnexpectedValueException(){
        new CeligoUnexpectedValueException();
    }
    
    @isTest(SeeAllData=true) static void test_DBTunaLicenseDetailsController_DBTunaBackend(){
        DBTuna_License__c[] licenses = [select Id, Opportunity__c, ExpiryDate__c, Server_Name__c from DBTuna_License__c limit 1];
        
        if(licenses.size() > 0){
            DBTunaLicenseDetailsController controller = new DBTunaLicenseDetailsController(new ApexPages.StandardController(licenses[0]));
            controller.init();
            
            DBTunaBackend ctrl = new DBTunaBackend(licenses[0]);
            ctrl.setupInputParameters();
        }
    }
    
    @isTest(SeeAllData=true) static void testOpportunityUtil(){
        FCRM.FCR_SupportAPI.SetPassiveModeInContext();
        Opportunity[] oppts = [select Id, StageName from Opportunity where StageName != 'W10 - Closed/Won' and Amount_USD__c >= 100000 limit 2];
        if(oppts.size() > 0){
            oppts[0].StageName = 'W10 - Closed/Won';
            oppts[1].StageName = 'W10 - Closed/Won';
            try{
                update oppts;
            }catch(Exception e){}
        }
    }
    
    @isTest static void testTaskCreationController(){
        Contact con = new Contact(LastName = 'con');
        insert con;
        TaskCreationController ctrl = new TaskCreationController(new ApexPages.StandardController(con));
    }
    
    @isTest static void testBackendLayer(){
        Backend backend = new Backend();
        backend.errorMessage = 'error';
        
        RESTAPI api = new RESTAPI();
        api.serviceURL = 'test';
        api.headers = new Map<String, String>{'1' => '1'};
        api.requestBody = 'test';
        api.requestMethod = 'test';
        api.response = new HttpResponse();
        api.response.setBody('{}');
        api.response.setStatusCode(400);
        RESTAPI.unitTestMode = false;
        
        BackendLayer ctrl = new BackendLayer();
        ctrl.backendList.add(backend);
        ctrl.restAPIObj = api;
        ctrl.getErrorMessage();
        ctrl.getErrorMessage(true);
        ctrl.getErrorMessage(false);
        ctrl.getResponse(100);
        ctrl.getStatusCode(2);
        
        BackendLayer.BackendParameter parameter = new BackendLayer.BackendParameter('1', 1);
        BackendLayer.BackendParameter parameter2 = new BackendLayer.BackendParameter('1', true);
        BackendLayer.BackendParameter parameter3 = new BackendLayer.BackendParameter('1', backend);
    }
    
    @isTest static void testQuoteLinePageExt(){
        QuoteLinePageExt controller = new QuoteLinePageExt('test');
    }
    
    @isTest static void testQuoteLineItemClass(){
        QuoteLineItemClass controller = new QuoteLineItemClass('test');
    }
    
    @isTest static void testLicenseHistoryController(){
        LicenseHistoryController controller = new LicenseHistoryController('test');
    }
}