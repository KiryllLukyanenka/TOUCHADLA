@isTest
public with sharing class CI_TestAccountModelConfigController 
{
    static testMethod void testConfig() 
    {
        PageReference pr = Page.CI_AccountModelConfig;
        Test.setCurrentPageReference(pr);
        pr.getParameters().put('instance','0');
        
        CI_AccountModelConfigController config = new CI_AccountModelConfigController();
        Test.StartTest();
        List<String> roles = config.getAvailableRoles();
        system.assert(config.currencyFieldOptions.size() > 0);
        system.assert(config.leadAccountFieldOptions.size() > 0);
        config.getRoleLabels();
        config.getAvailableCampaignTouches();
        config.getWeightInfoCampaign();
        config.CreateInstance();
        CI_AccountModelConfigController.GetAdditionalInstanceCount();
        config.DeleteLastInstance();
        System.Assert(config.configobject.Enabled__c==false);
        config.configobject.Currency_Field_Name__c = 'BadFieldName';
        config.Save();
        config.configobject.Currency_Field_Name__c = 'Amount';
        config.Save();
        system.assertEquals(roles.size(), config.getWeightInfo().size());
        
        CI_AccountModelConfigController config2 = new CI_AccountModelConfigController();
        config2.getAvailableRoles();
        Test.StopTest();
        
    }
}