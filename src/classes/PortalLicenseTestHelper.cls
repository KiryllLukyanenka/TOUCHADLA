public with sharing class PortalLicenseTestHelper extends AbstractAppDController{
	public PortalLicenseTestHelper(ApexPages.StandardController stdController){
		super(stdController);
	}
	public String accountNamePrefix{get;set;}
	public Integer numberOfContacts{get;set;}
	public Boolean opportunityPerContact{get;set;}
	
	public PageReference setupTestAccountAndRelatedEntries(){
		DateTime ts = System.now();
		systemTimeStampUniqueString = ts.year() + '_' + ts.month() + '_' + ts.day() + '__' + ts.hour() + '_' + ts.minute() + '_' + ts.second();
		if(accountNamePrefix==null || accountNamePrefix.trim().equals('')){
			showErrorMessage('Account Name Prefix must be defined');
			return null;
		}
		if(numberOfContacts==null){
			showErrorMessage('# of contacts must be specified');
			return null;
		}
		
		Account acc = createAccount();
		FCRM.FCR_SupportAPI.SetPassiveModeInContext();
		list<Contact> cts = createContacts(acc);
		list<Opportunity> opps = createOpportunities(acc,cts);
		PageReference ref = new PageReference('/'+acc.Id);
		return ref;//Go to Test Account Summary
	}
	
	public String systemTimeStampUniqueString{get;set;}
	
	public Account createAccount(){
		Account acc = new Account(name=accountNamePrefix + '_' + systemTimeStampUniqueString);
		insert acc;
		return acc;
	}
	
	public list<Contact> createContacts(Account acc){
		list<Contact> cts = new list<Contact>();
		for(integer i=1;i<=numberOfContacts;i++){
			Contact ct = new Contact(FirstName='FName_'+i, 
										LastName=acc.Name, 
										email=acc.Name+'_'+i+'@test.com', 
										AccountId = acc.Id,
										FCRM__FCR_Status__c = 'Open'); 
			cts.add(ct);
		}
		insert cts;
		return cts;
	}
	
	public list<Opportunity> createOpportunities(Account acc, List<Contact> cts){
		list<Opportunity> opps = new list<Opportunity>();
		map<Contact, Opportunity> ctOppMap = new map<Contact, Opportunity>();
		if(opportunityPerContact){
			for(Contact ct:cts){
				Opportunity opp = createOpportunity(acc,ct,false);
				opps.add(opp);
				ctOppMap.put(ct,opp);
			}
		}else{
			Opportunity opp = createOpportunity(acc,cts.get(0),false);
			opps.add(opp);
			ctOppMap.put(cts.get(0),opp);
		}
		upsert opps;
		list<OpportunityContactRole> ctRoles = new list<OpportunityContactRole>();
		for(Contact ct:cts){
			Opportunity opp = ctOppMap.get(ct);
			if(opp!=null){
				OpportunityContactRole ctRole = createOppContactRole(opp, ct, false);
				ctRoles.add(ctRole);
				opp.Primary_Contact__c = ct.Id;
			}
		}
		upsert ctRoles;
		update opps;
		return opps;
	}
	
	public Opportunity createOpportunity(Account acc, Contact primaryCt, Boolean save){
		Opportunity opp = new Opportunity(Name=acc.Name+'_'+primaryCt.FirstName,
										StageName='A1 - Pipeline Generation',
										AccountId = acc.Id,
										closeDate=system.now().date());
		if(save){
			insert opp;
		}
		return opp;
	}
	
	public OpportunityContactRole createOppContactRole(Opportunity opp, Contact ct, Boolean save){
		OpportunityContactRole ctRole = new OpportunityContactRole(opportunityId = opp.Id, 
																	contactId = ct.Id, 
																	Role='Champion', 
																	isPrimary=true);
		if(save){
			insert ctRole;
		}
		return ctRole;
	}
}