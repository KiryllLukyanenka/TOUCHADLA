@isTest
public class ManageAccountTerritoryControllerTest{
    
    @isTest static void testManageAccountTerritoryController(){
        RecordType recordType = [select Id from RecordType where SobjectType = 'Territory_AppD__c' and Name = 'Account' limit 1];
        Territory_AppD__c territory = new Territory_AppD__c();
        territory.RecordTypeId = recordType.Id;
        territory.Name = 'Acme';
        territory.Type__c = 'acme';
        territory.Active__c = true;
        territory.Order__c = 1;
        territory.Assigned_To__c = '005n0000000psOA';
        territory.Effective_Date__c = System.today();
        insert territory;
        
        Territory_Setup__c setup = new Territory_Setup__c();
        setup.Type__c = 'Account/Contact';
        setup.Status__c = 'Active';
        setup.Next_Mass_Update_Date__c = System.today();
        insert setup;
        
        Test.setCurrentPage(new PageReference('/test?tid=' + territory.Id + '&territoryId=' + territory.Id));
        
        ManageAccountTerritoryController controller = new ManageAccountTerritoryController();
        Lead leadObject = controller.leadObject;
        
        ManageAccountTerritoryController.setupStatus('Off');
        ManageAccountTerritoryController.getFieldCriteriaOption('AccountSource');
        
        controller.saveMassUpdatedDate();
        controller.toggleTerritoryActive();
        controller.addMoreterritoryGeos();
        
        for(Territory_Geography__c item : controller.newTerritoryGeos){
            item.Country__c = 'US';
            item.Zip_Start__c = '1000';
            item.Zip_End__c = '1001';
        }
        controller.CurrentTerritoryId = territory.Id;
        controller.insertNewTerritoryGeos();
        
        controller.AssignmentsCSV = '11,11,11,11\n11,11,11,11';
        controller.insertNewTerritoryGeosByCSV();
        
        controller.getObjectFields();
        
        controller.createTerritory();
        controller.territory = territory;
        controller.createTerritory();
        controller.editTerritory();
        
        controller.jsonCriteria = '{"Territory__c":"' + territory.Id + '","Country__c":"USA","State__c":"CA","Zip_Start__c":"1000","Zip_End__c":"1001"}';
        controller.createGeographicCriteria();
        
        controller.jsonCriteria = '{"Territory__c":"' + territory.Id + '","Field__c":"Name","Operator__c":"equal","Value__c":"Acme"}';
        controller.createLeadFieldCriteria();
        
        controller.territoryOrder = territory.Id;
        controller.saveOrder();
        
        controller.userinfo = 'br';
        controller.searchUser();
        
        controller.removedId = territory.Id;
        controller.removedType = 'territory';
        controller.remove();
    }
}