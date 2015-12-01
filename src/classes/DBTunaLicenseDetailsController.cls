public with sharing class DBTunaLicenseDetailsController extends AbstractAppDController {
	public Opportunity myOpportunity{get;set;}
	public Account accObj;
	public List<ContactWrapper> dblicenseContacts{get;set;}
	public DBTuna_License__c lic {get;set;}
	public DBTunaLicenseDetailsController(ApexPages.StandardController controller){
		super(controller);
	}
	
	public override void init(){
		super.init();
		loggerHandle.setClassName(DBTunaLicenseDetailsController.class.getName());
		lic = (DBTuna_License__c)pageContextObj;
		myOpportunity = (Opportunity)DataLayerConstants.fetchSingle('Opportunity_Account_Owner',lic.Opportunity__c);
		accObj = [Select Id,CreatedById, OwnerId,Technical_Account_Manager__r.Id,Technical_Account_Manager__r.Email ,Name,PortalID__c,RecordType.Name,RecordType.Id from Account where Id=:myOpportunity.AccountId];
		dblicenseContacts = LicenseUtil.getDBContacts(lic,myOpportunity,accObj,true);
	}
}