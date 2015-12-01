@isTest
public class EditAccountTerritoryControllerTest{
    
    @isTest static void testEditAccountTerritoryController(){
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
        
        Test.setCurrentPage(new PageReference('/test?id=' + territory.Id));
        EditAccountTerritoryController.getFieldCriteriaOption('AccountSource');
        
        EditAccountTerritoryController controller = new EditAccountTerritoryController();
        Lead leadObject = controller.leadObject;
        
        controller.addMoreLeadTerritoryGeos();
        
        for(Territory_Geography__c item : controller.newLeadTerritoryGeos){
            item.Country__c = 'US';
            item.Zip_Start__c = '1000';
            item.Zip_End__c = '1001';
        }
        controller.insertNewLeadTerritoryGeos();
        
        controller.AssignmentsCSV = '11,11,11,11\n11,11,11,11';
        controller.insertNewLeadTerritoryGeosByCSV();
        
        controller.getLeadFields();
        
        controller.saveLeadTerritory();
        controller.LeadTerritory = territory;
        controller.saveLeadTerritory();
        
        controller.jsonCriteria = '{"Territory__c":"' + territory.Id + '","Country__c":"USA","State__c":"CA","Zip_Start__c":"1000","Zip_End__c":"1001"}';
        controller.createGeographicCriteria();
        
        controller.jsonCriteria = '{"Territory__c":"' + territory.Id + '","Field__c":"Name","Operator__c":"equal","Value__c":"Acme"}';
        controller.createLeadFieldCriteria();
        
        controller.userinfo = 'br';
        controller.searchUser();
        
        
        Territory_Geography__c tg = new Territory_Geography__c();
        tg.Territory__c = territory.Id;
        tg.Country__c = 'USA';
        insert tg;
        
        controller.removedId = tg.Id;
        controller.removedType = 'geography';
        controller.remove();
    }
}