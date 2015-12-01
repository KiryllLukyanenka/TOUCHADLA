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
private class CampaignMembersTest {

    static testMethod void myUnitTest() {
        CampaignMember member = [Select CampaignId,LeadId,Lead_Status__c,Lead_Source__c,Lead_Source_Detail__c from CampaignMember where LeadId!='' limit 1];
        if(member!=null){
            CampaignMember newMember = new CampaignMember();
            newMember.CampaignId = member.CampaignId;
            newMember.LeadId= member.LeadId;
            newMember.Lead_Source_Detail__c = 'Test';
            try{
            delete member;
            insert newMember;
            }catch(Exception e){}
        }
        
        Lead lead = new Lead();
        lead.Lead_Source_Detail__c = 'Test';
        lead.LastName='lastName';
        lead.Company='Company';
        upsert lead;
        List<Lead> leads = [Select Id,Company,LastName,LeadSource,Status,Lead_Source_Detail__c from Lead limit 100];
        upsert leads;
    }
}