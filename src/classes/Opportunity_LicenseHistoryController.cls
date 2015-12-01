public with sharing class Opportunity_LicenseHistoryController {/*
	public Integer activeLicenseCount{get;set;}
    public Opportunity opportunityObj{get;set;}
    public List<LicenseDetail__c> licenses{get;set;}
    public Opportunity_LicenseHistoryController(ApexPages.StandardController stdController){
        opportunityObj = (Opportunity)stdController.getRecord();
        licenses = [select Id,Name,License_Expiry_Date__c,Server_Agents__c,Net_Agents__c,Machine_Agents__c from LicenseDetail__c where Id IN (select License__c from License_Opportunity__c where Opportunity__c=:opportunityObj.Id)];
        List<LicenseDetail__c> activeLicenses = [select Id,Name,License_Expiry_Date__c,Server_Agents__c,Net_Agents__c,Machine_Agents__c from LicenseDetail__c where Id IN (select License__c from License_Opportunity__c where Opportunity__c=:opportunityObj.Id) and Stage__c<>'DISABLED'];
        if(activeLicenses!=null){
        	activeLicenseCount = activeLicenses.size();
        }
    }*/
}