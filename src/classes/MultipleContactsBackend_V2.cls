public with sharing class MultipleContactsBackend_V2 extends Backend{
	public Account accountObj{get;set;}
	public List<ADUAController_V2.ADUAUserDetails> aduaUsers{get;set;}
	public LicenseDetail__c licenseObj{get;set;}
	public DBTuna_License__c dblicenseObj{get;set;}
	public User accMgrUsr;
	public User salesRepUsr;
	public User oppOwnerUsr;
	
	public MultipleContactsBackend_V2(List<ADUAController_V2.ADUAUserDetails> aduaUsers, Account accountObj, User accMgrUsr, User salesRepUsr, User oppOwnerUsr, Integer opCode){
		super();
		this.aduaUsers = aduaUsers;
		this.accountObj = accountObj;
		this.opCode = opCode;
		this.accMgrUsr = accMgrUsr;
		this.salesRepUsr = salesRepUsr;
		this.oppOwnerUsr = oppOwnerUsr;
		setupInputParameters();
	}   
	
	public virtual override void setupInputParameters(){
		List<Backend> backends = new List<Backend>();
		for(ADUAController_V2.ADUAUserDetails adua:aduaUsers){
			ContactBackend_V2 backend = new ContactBackend_V2(adua,accountObj,accMgrUsr,salesRepUsr,oppOwnerUsr,opCode);
			backends.add(backend);
		}
		BackendLayer.BackendParameter segregatedParam = new BackendLayer.BackendParameter('users',backends);
        getParameters().add(segregatedParam);
	}
}