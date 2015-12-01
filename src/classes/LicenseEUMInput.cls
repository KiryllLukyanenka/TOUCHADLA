public with sharing class LicenseEUMInput {
	public License_EUM_Details__c eumDetails {get;set;}
	public EUM_Web__c eumWeb {get;set;}
	public EUM_Mobile__c eumMobile {get;set;}
	
	public LicenseEUMInput(License_EUM_Details__c eumDetails, EUM_Web__c eumWeb, EUM_Mobile__c eumMobile){
		this.eumDetails = eumDetails;
		this.eumWeb = eumWeb;
		this.eumMobile = eumMobile;
	}
}