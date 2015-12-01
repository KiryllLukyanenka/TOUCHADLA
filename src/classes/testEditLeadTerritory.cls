@isTest
public class testEditLeadTerritory
{
    @isTest
    static void testEditLeadTerritory()
    {
        Id leadTerritoryRecordTypeId = [select Id from RecordType where SobjectType = 'Territory_AppD__c' and Name = 'Lead' limit 1].Id;
        Territory_AppD__c testLt = new Territory_AppD__c(Name = 'Acme', RecordTypeId = leadTerritoryRecordTypeId, Type__c = 'Geography', Assigned_To_Type__c = 'User', Assigned_To_ID__c = Userinfo.getUserId(), Assigned_To__c = userinfo.getUserName(), Order__c = 1);
        insert testLt;
        //AnnualRevenue
        Territory_Field_Criteria__c testLeadFIeldCriteria1 = new Territory_Field_Criteria__c(Field__c = 'AppJam_Presenter__c', Value__c = 'true', Operator__c = 'equals', Territory__c = testLt.Id);
        Territory_Field_Criteria__c testLeadFIeldCriteria2 = new Territory_Field_Criteria__c(Field__c = 'Deal_Stage__c', Value__c = 'Qualified', Operator__c = 'equals', Territory__c = testLt.Id);
        Territory_Field_Criteria__c testLeadFIeldCriteria3 = new Territory_Field_Criteria__c(Field__c = 'AnnualRevenue', Value__c = '100000', Operator__c = 'equals', Territory__c = testLt.Id);
        Territory_Field_Criteria__c testLeadFIeldCriteria4 = new Territory_Field_Criteria__c(Field__c = 'App_Map_First_Visit__c', Value__c = '9/8/2014', Operator__c = 'equals', Territory__c = testLt.Id);
        Territory_Field_Criteria__c testLeadFIeldCriteria5 = new Territory_Field_Criteria__c(Field__c = 'Estimated_Close_Date__c', Value__c = '9/8/2014', Operator__c = 'equals', Territory__c = testLt.Id);        
        insert new List<Territory_Field_Criteria__c> {testLeadFIeldCriteria1, testLeadFIeldCriteria2, testLeadFIeldCriteria3, testLeadFIeldCriteria4, testLeadFIeldCriteria5};        
        Territory_Geography__c testLeadGeo = new Territory_Geography__c(Territory__c = testLt.Id, Country__c = 'usa', State__c = 'ca', Zip_Start__c = '1000', Zip_End__c = '2000');
        insert testLeadGeo;
        PageReference testPage = new PageReference('/apex/EditLeadTerritory?id=' + testLt.Id);
        test.setCurrentPage(testPage);
        EditLeadTerritoryController controller = new EditLeadTerritoryController();
        controller.userinfo = userinfo.getUserName();
        controller.searchUser();
        Controller.addMoreLeadTerritoryGeos();
        Territory_Geography__c newLeadTerritoryGeo = controller.newLeadTerritoryGeos[0];
        newLeadTerritoryGeo.COuntry__c = 'CN';
        newLeadTerritoryGeo.State__c = 'BJ';
        newLeadTerritoryGeo.Zip_Start__c = '1000';
        newLeadTerritoryGeo.Zip_End__c = '2000';
        controller.insertNewLeadTerritoryGeos();
        COntroller.AssignmentsCSV = 'USA,CA,1000,2000\nUSA,CA,2000,4000';
        COntroller.insertNewLeadTerritoryGeosByCSV();
        system.assert(controller.getLeadFields() != null);
        controller.saveLeadTerritory();           
        Controller.jsonCriteria = '{"Territory__c":"' +  testLt.Id
                          + '","Country__c":"USA'
                          + '","State__c":"CS'
                          + '","Zip_Start__c":"10000'
                          + '","Zip_End__c":"20000'
                          + '"}';
      Controller.createGeographicCriteria();
      Controller.jsonCriteria = '{"Territory__c":"' +  testLt.Id
                          + '","Field__c":"Name'
                          + '","Operator__c":"equals' 
                          + '","Value__c":"Acme'
                          + '"}';
      Controller.createLeadFieldCriteria();
      Controller.removedType = 'leadField';
      Controller.removedId = testLeadFIeldCriteria1.Id;
      Controller.remove();
      Controller.removedType = 'geography';
      Controller.removedId = testLeadGeo.Id;
      Controller.remove();
    }
}