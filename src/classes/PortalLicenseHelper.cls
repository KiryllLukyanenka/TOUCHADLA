public class PortalLicenseHelper {
	
	public class DAO{
		public PortalModelLicense.License backendLicense{get;set;}
		public LicenseDetail__c sfLicense{get;set;}
		
		public PortalModelLicense.License toBackend(){
			if(backendLicense == null){
				backendLicense = new PortalModelLicense.License();
			}
			return backendLicense;
		}
		
		public String sfStage{
			get{
				if(backendLicense.edition == 'pro'){
					if(backendLicense.deployment.type == 'onprem'){
						PortalModelLicense.Attribute onpremAttribs = backendLicense.deployment.attributes;
						if(onpremAttribs!=null){
							if(onpremAttribs.mac_address!=null && !onpremAttribs.mac_address.trim().equals('')){
								return backendLicense.active?'PAID_PERMANENT':'PAID_PERMANENT_EXPRIED';
							}else{
								return backendLicense.active?'PAID_TEMP':'PAID_TEMP_EXPRIED';
							}
						}
					}
					return backendLicense.active?'PAID_PERMANENT':'PAID_PERMANENT_EXPRIED';
				}else if (backendLicense.edition == 'lite'){
					return  'LITE';
				}else{
					return backendLicense.active?'TRIAL':'TRIAL_EXPRIED';
				}
			}
		}
		
		public Date getDate(String dateStr){
			dateStr = dateStr.replace('T', ' ');
			System.debug(LoggingLevel.Info, 'STR:'+dateStr);
			try{
				Date expDate = DateTime.parse(dateStr).date();
				return expDate;
			}catch(Exception e){
				Date expDate = DateTime.valueOf(dateStr).date();
				System.debug(LoggingLevel.Info, 'Date:'+expDate);
				return expDate;
			}
			
		}
		
		public String sfDeploymentOption{
			get{
				return (backendLicense.deployment.type == 'saas')? 'Hosted (SaaS)' : 'On-Premise';
			}
		}
		
		public LicenseDetail__c fromBackend(){
			LicenseDetail__c lic = null;
			try{
				lic = [SELECT  Ad_hoc_Email_Ids__c, CreatedById, CreatedDate, 
				Custom_URL_Name__c, Product_Type__c, Last_License_User__c, LastModifiedById, LastModifiedDate, LastOpcode__c, 
				ProcessState__c, License_Expiry_Date__c, License_Time__c, License_BackendID__c, MAC_Address__c, Manual_SaaS_Fields__c, 
				Reason__c, OwnerId,Id, SaaS_Access_Key__c, SaaS_Account__c, SaaS_Password__c, SAAS_UserName__c, Stage__c, Support__c,  
				Transaction_ID__c,
				(SELECT Agent_Type__c,Category__c,Count__c,CreatedById,CreatedDate,Edition__c,Enabled__c,Expiration_Date__c,License__c,
				Licensing_Model__c,Max_Agents__c,Id,Retention_Period__c FROM License_Agents__r),
				(SELECT Contact__c,Contact_Type__c,License__c,Need_Service_Email__c,Id,Need_Operations_Email__c FROM License_Contacts__r)
				 FROM LicenseDetail__c where License_BackendID__c =: backendLicense.id];
			}catch(Exception e){
				System.debug(LoggingLevel.DEBUG, 'Creating a new SF License');
			}
			lic = new LicenseDetail__c(Stage__c = sfStage, License_Expiry_Date__c = getDate(backendLicense.end_date), Product_Type__c = sfDeploymentOption, 
								License_BackendID__c = backendLicense.id);
			System.debug(LoggingLevel.Info, 'Deployment:'+this.sfDeploymentOption);
			if('Hosted (SaaS)'.equals(this.sfDeploymentOption)){
				PortalModelLicense.Attribute saasAttribs = backendLicense.deployment.attributes;
				lic.Custom_URL_Name__c = 'default';
				system.debug(LoggingLevel.Info, 'DEFAULT:'+lic.Custom_URL_Name__c);
				lic.SAAS_Account__c = 'default';
				lic.SAAS_UserName__c = 'default';
				lic.SAAS_Password__c = saasAttribs.password;
				lic.SAAS_Access_Key__c = saasAttribs.access_key;
			}else{
				PortalModelLicense.Attribute onPremAttribs = backendLicense.deployment.attributes;
				String macAddress = onPremAttribs.mac_address;
				if(macAddress!=null && !macAddress.trim().toLowerCase().equals('none')){
					lic.MAC_Address__c = macAddress;
				}
			}
			
			upsert lic;
			
			List<License_Agent__c> sfLicAgents = lic.License_Agents__r;
			if(sfLicAgents==null){
				sfLicAgents = new list<License_Agent__c>();
			}
			map<String, License_Agent__c> sfLicAgentMap = new map<String, License_Agent__c>();
			for(License_Agent__c sfLicAgent: sfLicAgents){
				sfLicAgentMap.put(sfLicAgent.Agent_Type__c, sfLicAgent);
			}
			if(backendLicense.products != null){
				for(PortalModelLicense.Product prd: backendLicense.products){
					String agentType = prd.name;
					License_Agent__c sfLicAgent = sfLicAgentMap.get(agentType);
					if(sfLicAgent == null){
						sfLicAgent = new License_Agent__c();
						sfLicAgent.License__c = lic.id;
						sfLicAgents.add(sfLicAgent);
						sfLicAgent.Agent_Type__c = agentType;
					}
					if(prd.edition == 'pro'){
						sfLicAgent.Edition__c = 'PRO';
					}else if(prd.edition == 'pro-trial'){
						sfLicAgent.Edition__c = 'PRO_TRIAL';
					}else{
						sfLicAgent.Edition__c = 'LITE';
					}
					String model = prd.model.toLowerCase();
					sfLicAgent.Licensing_Model__c = model;
					sfLicAgent.Category__c = prd.category;
					sfLicAgent.Count__c = prd.units;
					sfLicAgent.Max_Agents__c = prd.max_units;
					sfLicAgent.Expiration_Date__c = getDate(prd.expiration_date);
					sfLicAgent.Retention_Period__c = prd.retention + '';
				}
				upsert sfLicAgents;
			}
			
			list<License_Contacts__c> licCts = lic.License_Contacts__r;
			
			map<String, License_Contacts__c> licCtMap = new map<String, License_Contacts__c>();
			for(License_Contacts__c licCt:licCts){
				String email = licCt.Contact__r.Email;
				licCtMap.put(email, licCt);
			}
			
			if(backendLicense.contacts!=null){
				for(PortalModelLicense.LicenseUser user:backendLicense.contacts){
					License_Contacts__c licCt = licCtMap.get(user.email);
					if(licCt == null){
						//TODO Implement the case of getting the account contacts and associating it
						/*licCt = new License_Contacts__c(License__c = lic.id);
						licCt.Contact__c =*/ 
					}
					if(licCt != null){
						licCt.Contact_Type__c = user.user_type;
						String[] notificationsArr = user.notifications;
						set<String> notificationsSet = new set<String>(notificationsArr);
						licCt.Need_Operations_Email__c = true;
						if(notificationsSet.contains('saas')){
							licCt.Need_Service_Email__c = true;
						}
					}
				}
			}
			upsert licCts;
			
			
			try{
				lic = [SELECT  Ad_hoc_Email_Ids__c, CreatedById, CreatedDate, 
				Custom_URL_Name__c, Product_Type__c, Last_License_User__c, LastModifiedById, LastModifiedDate, LastOpcode__c, 
				ProcessState__c, License_Expiry_Date__c, License_Time__c, License_BackendID__c, MAC_Address__c, Manual_SaaS_Fields__c, 
				Reason__c, OwnerId,Id, SaaS_Access_Key__c, SaaS_Account__c, SaaS_Password__c, SAAS_UserName__c, Stage__c, Support__c,  
				Transaction_ID__c,
				(SELECT Agent_Type__c,Category__c,Count__c,CreatedById,CreatedDate,Edition__c,Enabled__c,Expiration_Date__c,License__c,
				Licensing_Model__c,Max_Agents__c,Id,Retention_Period__c FROM License_Agents__r),
				(SELECT Contact__c,Contact_Type__c,License__c,Need_Service_Email__c,Id,Need_Operations_Email__c FROM License_Contacts__r)
				 FROM LicenseDetail__c where Id =: lic.Id];
			}catch(Exception e){
				System.debug(LoggingLevel.DEBUG, 'Creating a new SF License');
			}
			this.sfLicense = lic;
			return sfLicense;
		}
		
		public void updateLicenseProducts(){
			List<License_Agent__c> licAgents = null;
			try{
				licAgents = [Select ID, Agent_Type__c, Count__c, Edition__c, Licensing_Model__c, Expiration_Date__c, Max_Agents__c,
													Retention_Period__c from License_Agent__c where License__c =: this.sfLicense.id];
			}catch(Exception e){
				System.debug(LoggingLevel.INFO, 'Error while retrieving the agents');
			}
			if(licAgents == null){
				licAgents = new list<License_Agent__c>();
			}
			map<String, License_Agent__c> typeAgentsMap = new map<String, License_Agent__c>();
			for(License_Agent__c licAgent:licAgents){
				typeAgentsMap.put(licAgent.Agent_Type__c, licAgent);
			}
			
			for(PortalModelLicense.Product prd: backendLicense.products){
				License_Agent__c licAgent = typeAgentsMap.get(prd.type);
				if(licAgent == null){
					licAgent = new License_Agent__c(License__c = this.sfLicense.id);
					typeAgentsMap.put(prd.type, licAgent);
					licAgents.add(licAgent);
				}
				licAgent.Agent_Type__c = prd.type;
				licAgent.Category__c = prd.category;
				licAgent.Edition__c = prd.edition;
				licAgent.Expiration_Date__c = getDate(prd.expiration_date);
				licAgent.Licensing_Model__c = prd.model;
				licAgent.Count__c = prd.units;
				licAgent.Max_Agents__c = prd.max_units;
				licAgent.Retention_Period__c = prd.retention+'';
			}
			upsert licAgents;
		}
		
		public void updateLicenseContacts(){
			List<License_Contacts__c> licContacts = null;
			try{
				licContacts = [Select ID, Contact__r.Email, Need_Service_Email__c, Need_Operations_Email__c, License__c, Contact_Type__c from
								License_Contacts__c where License__c =: this.sfLicense.Id];
			}catch(Exception e){
				System.debug(LoggingLevel.INFO, 'Error while retrieving the agents');
			}
			if(licContacts == null){
				licContacts = new list<License_Contacts__c>();
			}
			map<String, License_Contacts__c> emailLicCtMap = new map<String, License_Contacts__c>();
			for(License_Contacts__c licCt:licContacts){
				emailLicCtMap.put(licCt.Contact__r.Email, licCt);
			}
			
			for(PortalModelLicense.LicenseUser usr: backendLicense.contacts){
				License_Contacts__c licCt = emailLicCtMap.get(usr.email);
				if(licCt == null){
					licCt = new License_Contacts__c(License__c = this.sfLicense.id,
													Contact__c = usr.contactId);
					emailLicCtMap.put(usr.email, licCt);
					licContacts.add(licCt);	
				}
				licCt.Contact_Type__c = usr.user_type;
				licCt.Need_Service_Email__c = usr.needServiceEmail;
				licCt.Need_Operations_Email__c = usr.needLicenseEmail;
			}
			upsert licContacts;
		}
	}
	
	public list<PortalModelLicense.Property> metadataProperties {get;set;}
	
	public PortalModelLicense.License portalLicense{get;set;}
	
	public list<String> categories{get;set;}
	
	public map<String,list<PortalModelLicense.Product>> categoryBasedProducts {get;set;}
	
	public Account accObj {get;set;}
	public Opportunity oppObj {get;set;}
	public LicenseDetail__c licObj {get;set;}
	
	public String primaryContactEmail {get;set;}
	
	public map<String, PortalModelLicense.Property> metadataMap{
			get{
				if(metadataProperties!=null){
					map<String, PortalModelLicense.Property> valueMap = new map<String, PortalModelLicense.Property>();
					for(PortalModelLicense.Property prop:metadataProperties){
						valueMap.put(prop.name, prop);
					}
					return valueMap;
				}
				return null;
			}
		}
	
	public PortalLicenseHelper(PortalModelLicense.License portalLicense, 
		list<PortalModelLicense.Property> properties, Account accObj, Opportunity oppObj, 
		LicenseDetail__c licObj){
		this.portalLicense = portalLicense;
		this.metadataProperties = properties;
		this.accObj = accObj;
		this.oppObj = oppObj;
		this.licObj = licObj;
		this.initializeSalesforceContextVars();
		System.debug(LoggingLevel.Info, 'Opp Contacts:'+ this.oppContactPortalUsers);
		this.processLicenseProducts();
	}
	public list<PortalModelLicense.LicenseUser> accContactPortalUsers {get;set;}
	public list<PortalModelLicense.LicenseUser> oppContactPortalUsers {get;set;}
	private map<String, PortalModelLicense.LicenseUser> emailToPortalUserMap {get;set;}
	private map<Contact, PortalModelLicense.LicenseUser> contactToPortalUserMap {get;set;}
	
	private void initializeSalesforceContextVars(){
		this.accContactPortalUsers = new list<PortalModelLicense.LicenseUser>();
		this.oppContactPortalUsers = new list<PortalModelLicense.LicenseUser>();
		emailToPortalUserMap = new map<String, PortalModelLicense.LicenseUser>();
		contactToPortalUserMap = new map<Contact, PortalModelLicense.LicenseUser>();
		try{
			try{
				OpportunityContactRole ctRole = [Select Contact.Email, OpportunityId, isPrimary from OpportunityContactRole where OpportunityId=:oppObj.Id and isPrimary=True limit 1];
				if(ctRole!=null){
					System.debug(LoggingLevel.Info, 'OppctRole:'+ctRole);
					this.primaryContactEmail = ctRole.contact.Email;
				}
			}catch(Exception e){
				System.debug(LoggingLevel.Info, 'CT ROLE ERROR:'+e);
			}
			initializeAccountContacts();
			initializeOpportunityContacts();
		}catch(Exception e){
			System.debug(LoggingLevel.Info, 'Error in initializing account and opportunity contacts:' + e);
		}
	}
	
	public list<PortalModelLicense.LicenseUser> getLicenseUsersForOpportunity(){
		return mergePortalUsers(oppContactPortalUsers);
	}
	
	public list<PortalModelLicense.LicenseUser> getLicenseUsersForAccount(){
		return mergePortalUsers(accContactPortalUsers);
	}
	
	public list<PortalModelLicense.LicenseUser> mergePortalUsers(list<PortalModelLicense.LicenseUser> targetUsers){
		Set<PortalModelLicense.LicenseUser> users = new Set<PortalModelLicense.LicenseUser>();
		if(this.portalLicense.contacts!=null){
			for(PortalModelLicense.LicenseUser user: this.portalLicense.contacts){
				if(!users.contains(user)){
					users.add(user);
				}
			}
		}
		for(PortalModelLicense.LicenseUser user:targetUsers){
			if(!users.contains(user)){
				users.add(user);
			}
		}
		return new list<PortalModelLicense.LicenseUser>(users);
	}
	
	private void initializeAccountContacts(){
		accContactPortalUsers = new list<PortalModelLicense.LicenseUser>();
		list<Contact> accContacts = DataLayerConstants.fetchMultiple('Contact', ' WHERE AccountID=\''+this.accObj.Id+'\'');
		for(Contact ct:accContacts){
			accContactPortalUsers.add(getLicenseUser(ct));	
		}
	}
	
	private PortalModelLicense.LicenseUser getLicenseUser(Contact ct){
		System.debug(LoggingLevel.Info, 'Primary Contact Email:'+primaryContactEmail);
		if(contactToPortalUserMap.get(ct)!=null){
			return contactToPortalUserMap.get(ct);
		}
		else if(emailToPortalUserMap.get(ct.email)!=null){
			contactToPortalUserMap.put(ct, emailToPortalUserMap.get(ct.email));
			return emailToPortalUserMap.get(ct.email);
		}else{
			PortalModelLicense.LicenseUser user = new PortalModelLicense.LicenseUser();
			user.firstName = ct.firstName;
			user.lastName = ct.lastName;
			user.email = ct.email;
			user.notifications = new String[]{};
			user.contactId = ct.Id;
			
			if(user.email.equals(primaryContactEmail)){
				user.isPrimary = true;
			}else{
				user.isPrimary = false;
			}
			emailToPortalUserMap.put(ct.email, user);
			contactToPortalUserMap.put(ct, user);
			return user;
		}
	}
	
	private void initializeOpportunityContacts(){
		oppContactPortalUsers = new list<PortalModelLicense.LicenseUser>();
		list<Contact> oppContacts = DataLayerConstants.fetchMultiple('Contact', ' WHERE ID in (SELECT CONTACTID FROM OpportunityContactRole where opportunityid=\''+this.oppObj.Id+'\')');
		for(Contact ct:oppContacts){
			oppContactPortalUsers.add(getLicenseUser(ct));	
		}
	}
	
	private void processLicenseProducts(){
		set<String> categoriesSet = new set<String>();
		String message = '';
		categoryBasedProducts = new map<String, list<PortalModelLicense.Product>>();
		editionSelectOptions = new map<PortalModelLicense.Product, list<SelectOption>>();
		modelSelectOptions = new map<PortalModelLicense.Product, list<SelectOption>>();
		for(PortalModelLicense.Product prd: portalLicense.products){
			message+='Prd Type:'+prd.type+' \t Prd Category:'+prd.category;
			if(!categoriesSet.contains(prd.category)){
				categoriesSet.add(prd.category);
			}
			list<PortalModelLicense.Product> productsForCategory = categoryBasedProducts.get(prd.category);
			if(productsForCategory == null){
				productsForCategory = new list<PortalModelLicense.Product>();
				categoryBasedProducts.put(prd.category, productsForCategory);
			}
			productsForCategory.add(prd);
			if(this.portalLicense.edition == 'pro-trial' || (prd.edition==null || prd.edition.trim().equals(''))){
				prd.edition = this.portalLicense.edition;
			}
			if(prd.edition == 'pro-trial'){
				prd.model = 'Fixed';
			}
			if(prd.model == 'Fixed' || prd.max_units == null || prd.max_units < prd.units){
				prd.max_units = prd.units;
			}
			if(prd.category=='ANALYTICS'){
				prd.retention = 90;
			}else{
				prd.retention = 0;
			}
			String key_base = 'agents__'+prd.category+'__'+prd.type+'__';
			if(metadataMap!=null)
			{
				System.debug(LoggingLevel.Info, 'KEY BASE:'+key_base+'edition');
				PortalModelLicense.Property metadataEdition = metadataMap.get(key_base+'edition');
				system.debug(LoggingLevel.Info, 'Checking Agent Level Edition:'+key_base+'edition');
				if(metadataEdition!=null){
					String[] allowed_values = metadataEdition.allowed_values;
					if(allowed_values!=null){
						list<SelectOption> selectOptions = new list<SelectOption>();
						for(String allowed_val:allowed_values){
							SelectOption selOption = new SelectOption(allowed_val, allowed_val);
							selectOptions.add(selOption);
							system.debug(LoggingLevel.Info, 'Addiing Agent Level Edition:'+allowed_val);
						}
						editionSelectOptions.put(prd,selectOptions);
					}
				}
				PortalModelLicense.Property metadataExpDate = metadataMap.get(key_base+'expiration_date');
				PortalModelLicense.Property metadataModel = metadataMap.get(key_base+'licensing_model');
				if(metadataModel!=null){
					String[] allowed_values = metadataModel.allowed_values;
					if(allowed_values!=null){
						list<SelectOption> selectOptions = new list<SelectOption>();
						for(String allowed_val:allowed_values){
							SelectOption selOption = new SelectOption(allowed_val, allowed_val);
							selectOptions.add(selOption);
						}
						modelSelectOptions.put(prd, selectOptions);
					}
				}
				PortalModelLicense.Property metadataMaxUnits = metadataMap.get(key_base+'units');
				PortalModelLicense.Property metadataRetention = metadataMap.get(key_base+'max_units');
			}
		}
		EmailUtil.notifyError('message:'+message,'error');
		this.categories = new list<String>(categoriesSet);
	}
	
	public map<PortalModelLicense.Product, list<SelectOption>> editionSelectOptions{get;set;}
	public map<PortalModelLicense.Product, list<SelectOption>> modelSelectOptions{get;set;}
}