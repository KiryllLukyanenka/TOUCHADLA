/**
 * Controller: Account_OpportunityLicenses
 * Visual Force Page: Account_OpportunityLicenses_Page
 * Standard Controller: Account
 * 
 * This class contains controller code to retrieve Opportunity and associated
 * License data list for a given account.
 *
 * This is used in a Visual Force Page 'Account_OpportunityLicenses_Page' which
 * displays each Opportunity and corresponding Set of Licenses in a tabular format.
 *
 * This page is embedded in Standard Detail page layout of Accounts.
 *
 * See Visual Force page 'Account_OpportunityLicenses_Page' and 
 * Standard Account Page layout for the references of fields and actions of this class.  
 */
public with sharing class Account_OpportunityLicenses {
	
	public Integer activeLicenseCount{get;set;}
	
	public list<License_Contacts__c> licCts{get;set;}
	public list<License_Opportunity__c> licOpps{get;set;}
	public boolean showLicOpps{get;set;}
	
	/**
	 * Constructor of the Controller which initializes data set to be rendered in 
	 * Visual Force page. 
	 * The sequence of execution of the constructor is as follows:
	 * <ul>
	 * 	<li>Retrieve the Account object being referred using Standard Controller reference</li>
	 *	<li>Retrieve all the opportunies for the account</li>
	 *  <li>For each opportunity retrieve all the licenses</li>
	 *  <li>For each license, create Accout_OpportunityLicenses object with Opportunity and License data set</li>
	 * </ul>
	 */
	public Account_OpportunityLicenses(ApexPages.StandardController stdController){
		Account accountObj = (Account)stdController.getRecord();
		activeLicenseCount=0;
		if(accountObj!=null && accountObj.Id!=null){
			licCts = LicenseUtil.getContactLicenses(accountObj);
			licOpps = licenseUtil.getOpportunityLicenses(accountObj);
		}
		showLicOpps = licOpps!=null && licOpps.size()>0;
		activeLicenseCount = (licOpps!=null && licOpps.size()>0)? licOpps.size(): licCts.size();
		if(activeLicenseCount==0){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'No Licenses associated with the account '+accountObj.Id);
            ApexPages.addMessage(myMsg);
		}
	}
}