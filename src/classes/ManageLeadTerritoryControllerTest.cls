@isTest
public class ManageLeadTerritoryControllerTest{
    
    @isTest static void testManageLeadTerritoryController(){
        RecordType recordType = [select Id from RecordType where SObjectType = 'Territory_AppD__c' and Name = 'Lead' limit 1];
        Territory_AppD__c territory = new Territory_AppD__c();
        territory.RecordTypeId = recordType.Id;
        territory.Name = 'Acme';
        territory.Type__c = 'acme';
        territory.Active__c = true;
        territory.Order__c = 1;
        territory.Assigned_To__c = '005n0000000psOA';
        insert territory;
        
        Territory_Setup__c setup = new Territory_Setup__c();
        setup.Type__c = 'Account/Contact';
        setup.Status__c = 'Active';
        setup.Next_Mass_Update_Date__c = System.today();
        insert setup;
        
        Test.setCurrentPage(new PageReference('/test?id=' + territory.Id));
        
        ManageLeadTerritoryController controller = new ManageLeadTerritoryController();
        Lead leadObject = controller.leadObject;
        String searchType = controller.searchType;
        
        controller.addMoreLeadTerritoryGeos();
        
        for(Territory_Geography__c item : controller.newLeadTerritoryGeos){
            item.Country__c = 'US';
            item.Zip_Start__c = '1000';
            item.Zip_End__c = '1001';
        }
        controller.CurrentTerritoryId = territory.Id;
        controller.insertNewLeadTerritoryGeos();
        
        controller.AssignmentsCSV = '11,11,11,11\n11,11,11,11';
        controller.insertNewLeadTerritoryGeosByCSV();
        
        controller.getLeadFields();
        
        controller.createLeadTerritory();
        controller.leadTerritory = territory;
        controller.createLeadTerritory();
        controller.editLeadTerritory();
        
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