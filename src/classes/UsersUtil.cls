/**
 * Class: UsersUtil.cls
 * Purpose: Provide common functionalities as helper methods
 * related to User Object and ContactPortalUserObjects
 */
public without sharing class UsersUtil {
   
    public static Boolean isPartner(Account contactAcc){
        if(contactAcc!=null && contactAcc.RecordType!=null && contactAcc.RecordType.Name!=null){
            String recordType = contactAcc.RecordType.Name;
            if(recordType.startsWith('VAR') || recordType.startsWith('Partner')){
                return true;
            }
        }
        return false;
    }
    
    /**
     * Check if the logged in user belongs to group named <groupName>. 
     * Note this method as of now only looks at direct members of a group 
     * to see if user is added as member. If user is a member of another group 
     * which is inturn member of this group, then it wont handle and return false;
     *
     * @param groupName - Name of Group to search for membership of logged in user
     *
     * @return true if user is directly member of the group; false otherwise
     */    
    public static Boolean userBelongsToGroup(String groupName){
        try{
            GroupMember grpMember = [Select Id,GroupId,UserOrGroupId from GroupMember where Group.Name=:groupName and UserOrGroupId=:UserInfo.getUserId() limit 1];
            if(grpMember!=null){
                return true;
            }
        }catch(Exception e){}
        return false;
    }
    
    public static List<Contact> getContactPortalUsers(List<Contact> contactList,Account accountObj){
		List<Contact_Portal_User__c> contactPortalUsers = new List<Contact_Portal_User__c>();
    	for(Contact con: contactList){
    		Contact_Portal_User__c contactPortalUser = null;
    		if(con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME)==null || con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).size()==0){
				//contactPortalUser = new Contact_Portal_User__c(Contact__c=con.Id);
				contactPortalUser = new Contact_Portal_User__c();
				contactPortalUser.put('Contact__c',con.Id);
				contactPortalUsers.add(contactPortalUser);
    		}
    	}
    	if(contactPortalUsers.size()>0){
    		insert contactPortalUsers;
    	}	
    	List<Contact> contactObjects = Database.query('SELECT Description,ADUAUserDetails__c,Enable_Access__c, docs_fez__c,LMS__c, No_longer_at_Company__c,Docs__c,Download__c, Needs_Email__c,ZenDesk__c,Email, '+
    									'LastName, Id, PortalID__c, Title, Name, Accessible_Systems__c,Account.RecordType.Name,Account.Name,Account.RecordType.Id, Account.Id,Account.PortalID__c,'+
    									'Account.OwnerId, FirstName,LMS_Portal_User_Contact__c, Registered_Fan_Club__c, LMS_Cloned__c, '+
    									
    									'(Select id,Contact__c,User_Portal_Id__c,Docs__c,Download__c,ZenDesk__c,LMS__c, '+
    									'ADUAUserDetails__c,Contact__r.Account.RecordType.Name,Contact__r.Account.Name, '+
    									'Contact__r.Account.RecordType.Id, Contact__r.Account.Id,Contact__r.Account.PortalID__c, '+
    									'Contact__r.Name,Contact__r.Description,Contact__r.Needs_Email__c,Contact__r.Email, Contact__r.LastName, '+ 
    									'Contact__r.Accessible_Systems__c, '+
    									'Contact__r.Account.OwnerId, Contact__r.FirstName,Contact__r.LMS_Portal_User_Contact__c, Contact__r.LMS_Cloned__c '+
    									' from Contact_Portal_User__r) '+
    									
    									' FROM Contact where id in:contactList'); 
    	/*[SELECT Description,ADUAUserDetails__c,Enable_Access__c, docs_fez__c,LMS__c, No_longer_at_Company__c,Docs__c,Download__c, Needs_Email__c,ZenDesk__c,Email,
    									LastName, Id, PortalID__c, Title, Name, Accessible_Systems__c,Account.RecordType.Name,Account.Name,Account.RecordType.Id, Account.Id,Account.PortalID__c,
    									Account.OwnerId, FirstName,LMS_Portal_User_Contact__c, LMS_Cloned__c, 
    									
    									(Select id,Contact__c,User_Portal_Id__c,Docs__c,Download__c,ZenDesk__c,LMS__c,
    									ADUAUserDetails__c,Contact__r.Account.RecordType.Name,Contact__r.Account.Name,
    									Contact__r.Account.RecordType.Id, Contact__r.Account.Id,Contact__r.Account.PortalID__c,
    									Contact__r.Name,Contact__r.Description,Contact__r.Needs_Email__c,Contact__r.Email, Contact__r.LastName, 
    									Contact__r.Accessible_Systems__c,
    									Contact__r.Account.OwnerId, Contact__r.FirstName,Contact__r.LMS_Portal_User_Contact__c, Contact__r.LMS_Cloned__c
    									 from Contact_Portal_User__r)
    									
    									FROM Contact where id in:contactList];*/
    	if(contactObjects!=null){
    		return contactObjects;	
    	} else{
    		return null;
    	}
    }
      
    public static String getUserDetailsRequestJson(List<Contact> contactObjects,String accountName){
        accountName = accountName.replace('\\','');
    	String emailArrayString = '[';
    	for(Contact con: contactObjects){
    		emailArrayString += '"'+con.email+'",';
    	}
    	if(emailArrayString.Substring(emailArrayString.length()-1,emailArrayString.length()).equals(',')){
    		emailArrayString = emailArrayString.Substring(0,emailArrayString.length()-1);
    	}
    	emailArrayString += ']';
    	
    	String requestJson = '{"companyName":"'+accountName.replaceAll('"','\\\\"')+'","emails":'+emailArrayString+'}';
        System.debug('getUserDetailsRequestJson : ' + requestJson);
    	
    	return requestJson;
    }
    
    public static testMethod void testGetContactPortalUsers(){
    	Account acc = new Account(Name='Test Account',PortalID__c='123456',RecordTypeId='01280000000LrcY');
        insert acc;
        Contact con  = new Contact(firstName='Test fn',lastName='Test ln',Accountid=acc.id,email='test@test.com');
        insert con;
        List<Contact> contactList = new List<Contact>();
        contactList.add(con); 
    	UsersUtil.getContactPortalUsers(contactList, acc);
    	UsersUtil.getUserDetailsRequestJson(contactList,'TestAccount');
    }
    
    public static testMethod void testUserUtil(){
       // Boolean isUserLoggedIn = UsersUtil.isPartnerUserLoggedIn();
        //User usr = UsersUtil.getUserByEmail('srinidhi.acharya@tarams.com');
        //UsersUtil.getUserEmailByName(usr.Name);
        //System.assert(usr!=null);
        //UsersUtil.getUserId(usr);
        
        //usr = UsersUtil.getUserByEmail('abafasf.afsfgasf@tarams.com');
        //UsersUtil.getUserId(usr);
        try{userBelongsToGroup(AppDConstants.PRIVILEGED_USER_GROUP_NAME);
        }catch(Exception e){
            
        }
        try{userBelongsToGroup('ssgdsgsdg');
        }catch(Exception e){
            
        }
        Contact ct = new Contact();
        ct.FirstName = 'Srinidhi';
        ct.LastName = 'Srinidhi';
        ct.Email= 'Srinidhi@Srinidhi.com';
        //Contact ct = [Select Id,FirstName,LastName,Email from Contact limit 1];
        //try{createLMSUser(ct);}catch(Exception e){}
        //try{createLMSUser(ct);}catch(Exception e){}
    }
    
    public static void saveContactHistory(ADUAUI aduauiObj,Contact_Portal_User__c contactUserObj,String apexPage, String apexClass, String saveUserStatus ){
    	list<Permissions_change_log__c> permissionsLogList = new list<Permissions_change_log__c>();
    	Id userid = Userinfo.getUserId(); 
    	String getUserApiStatus = aduauiObj.aduaUser.getUserApiStatus;
    	String getUserDetailsResponse = aduauiObj.aduaUser.getUserDetailsResponse;
    	Boolean isActive = aduauiObj.active;
    	ContactPortalUserHistory__c conHistory = new ContactPortalUserHistory__c(Contact_Portal_User__c = contactUserObj.Id, Changed_date__c = System.now(), user__c = userid, ApexClass__c = apexClass, ApexVisualforcePage__c = apexPage, GetUser_Api_Response__c = getUserDetailsResponse, GetUser_Api_Status__c = getUserApiStatus, Is_New_User__c = aduauiObj.newUser, 	Save_User_Status__c = saveUserStatus, 	is_Active__c = isActive );
    	insert conHistory; 
		for (ADUAUI.SystemEntry entry : aduauiObj.getSystemEntries()){
    		if (entry.systemName.equals(AppDConstants.ACCESSIBLE_DOWNLOADS)){
    			for (ADUAUI.ADUAZoneDetails zone : aduauiObj.getZoneList()){
	    			String path = zone.zone.Zone_Path__c;
		    		if (zone.isChanged()){
			    		Permissions_change_log__c PermissionsLog = new Permissions_change_log__c(SystemName__c='download-zones/'+path,OldValue__c=zone.selectedOriginal, NewValue__c=zone.selected, ContactPortalUserHistory__c = conHistory.Id);
		    			permissionsLogList.add(PermissionsLog);
		    		}
    			}
    		}  
    		else if(entry.systemName.equals(AppDConstants.ACCESSIBLE_DOCS) && entry.isChanged() || aduauiObj.isPrimary){
		    		String accName = aduauiObj.contactObj.Account.Name;
		    		String path = '';
		    		{
						if(aduauiObj.contactObj.Email!=null&& aduauiObj.contactObj.Email.endsWith('@appdynamics.com') ||accName.containsIgnoreCase('appdynamics')){
							path = 'docs/docs-internal';
						}else{
							if(aduauiObj.contactObj.Account.RecordType.Name.containsIgnorecase('Partner')){
								path = 'docs/docs-partner';  
							}else{
								path = 'docs/docs-customer';
							}
						}
			    		Permissions_change_log__c PermissionsLog = new Permissions_change_log__c(SystemName__c=path,OldValue__c=(Boolean)entry.selectedOriginal, NewValue__c=(Boolean)entry.selected, ContactPortalUserHistory__c = conHistory.Id);
			    		permissionsLogList.add(PermissionsLog);
		    		}
		    		
		    		if(aduauiObj.fez!=aduauiObj.fezOriginal){
		    			path = 'docs/docs-partner-fez';
		    			Permissions_change_log__c PermissionsLog = new Permissions_change_log__c(SystemName__c=path,OldValue__c=(Boolean)aduauiObj.fezOriginal, NewValue__c=(Boolean)aduauiObj.fez, ContactPortalUserHistory__c = conHistory.Id);
			    		permissionsLogList.add(PermissionsLog);
		    		}
	    		
    		}
    		else if (entry.systemName.equals(AppDConstants.ACCESSIBLE_LMS) && entry.isChanged() || aduauiObj.isPrimary){
	    			String path = 'learning-system/lms-learner';
	    			Permissions_change_log__c PermissionsLog = new Permissions_change_log__c(SystemName__c=path,OldValue__c=entry.selectedOriginal, NewValue__c=entry.selected, ContactPortalUserHistory__c = conHistory.Id);
		    		permissionsLogList.add(PermissionsLog);
    			
    		}
    		else if(entry.systemName.equals(AppDConstants.ACCESSIBLE_ZENDESK) && entry.isChanged() || aduauiObj.isPrimary){
	    			String path = 'help';
	    			Permissions_change_log__c PermissionsLog = new Permissions_change_log__c(SystemName__c=path,OldValue__c=entry.selectedOriginal, NewValue__c=entry.selected, ContactPortalUserHistory__c = conHistory.Id);
		    		permissionsLogList.add(PermissionsLog);
    			
    		}
		}
		insert permissionsLogList;
    }
    
    /*@future (callout=true)
    public static void disablePortalUsers(List<String> updatedContacts){
    	List<Contact> contactObjects = [SELECT Description,ADUAUserDetails__c,Enable_Access__c, docs_fez__c,LMS__c, No_longer_at_Company__c,Docs__c,Download__c, Needs_Email__c,ZenDesk__c,Email,
    									LastName, Id, PortalID__c, Title, Name, Accessible_Systems__c,Account.RecordType.Name,Account.Name,Account.RecordType.Id, Account.Id,Account.PortalID__c,
    									Account.OwnerId, FirstName,LMS_Portal_User_Contact__c, LMS_Cloned__c 
    									FROM Contact where id in:updatedContacts];
    									
    	Map<String,Contact> contactsMap = new Map<String,Contact>();
    	
    	for(Contact con:contactObjects){
    		contactsMap.put(con.email,con);
    	}
    	
    	Account accountObj = contactObjects.get(0).Account;	
    	accountObj = (Account)DataLayerConstants.fetchSingle('Account',accountObj.id);							
    	String requestJson = UsersUtil.getUserDetailsRequestJson(contactObjects,accountObj.Name);
    	ADUAController_V2.ADUAUser adUsers = UserDetailsBackend.getUserDetails(requestJson);
    	
    	List<Contact> contactsSentToDisable = new List<Contact>();
    	
    	BackendLayer backend = new BackendLayer();
    	 
    	if(adUsers!=null){
    		for(ADUAController_V2.ADUAUserDetails ad: adUsers.users){
    			if(ad.userId!=null && ad.isActive!=null){
	    			Contact con = contactsMap.get(ad.email);
	    			if(con!=null){
		    			if(con.No_longer_at_Company__c && ad.isActive.equals('true')){
		    				ad.isActive = 'false';
		    				contactsSentToDisable.add(contactsMap.get(ad.email));
	    					ContactBackend_V2 ctcBackend= new ContactBackend_V2(ad,accountObj,BackendConstants.OPCODE_ADD_USER);
	    					backend.addBackend(ctcBackend);
		    			} else if(!con.No_longer_at_Company__c && ad.isActive.equals('false')){
		    				ad.isActive = 'true';
	    					ContactBackend_V2 ctcBackend= new ContactBackend_V2(ad,accountObj,BackendConstants.OPCODE_ADD_USER);
	    					backend.addBackend(ctcBackend);
		    			}
	    			}
    			}
    		}
    	
			if(backend.invokeBackend()){
				UsersUtil.notifyAccountOwner(contactsSentToDisable,accountObj);        			
        	}
    	}
    }
    
    public static void notifyAccountOwner(List<Contact> contactsSentToDisable, Account accountObj){
    	try{
	    	String emailContent = 'Hi '+accountObj.Owner.Name+', <br/> <br/>';
	    	emailContent += 'We noticed that following users have been marked as No Longer at company. As a result of this they will no longer have access '; 
	    	emailContent += ' to AppDynamics systems. We wanted you to ensure that the following license(s) have these users listed as Primary Contact. ';
	    	emailContent += 'Please review and ensure to update Primary contact to a different user of the account ('+accountObj.Name+').<br/><br/>';
	    	
	    	emailContent += 'Contacts Marked as No Longer and the licenses having them as Primary Contact:<br/><br/>';
	    	emailContent += '<table border="1" align="left" style="border-collapse:collapse;"><th>Contact</th><th>License</th>';
	    	
	    	String emailString = '';
	    	emailString +=accountObj.Owner.Email+',';
	    	
	    	Map<Contact,List<LicenseDetail__c>> licContactsMap = new Map<Contact,List<LicenseDetail__c>>(); 
	    	System.debug('contactsSentToDisable=============='+contactsSentToDisable);
	    	List<License_Contacts__c> licenseContacts = [select Id,Contact__c,Contact__r.Id,Contact__r.Name,License__c,License__r.Id,License__r.Sales_Rep__c from License_Contacts__c where Contact__c in:contactsSentToDisable and Contact_Type__c='PRIMARY'];
	    	System.debug('licenseContacts='+licenseContacts);
	    	if(licenseContacts!=null){
	    		for(License_Contacts__c lc: licenseContacts){
	    			Set<Contact> keys = licContactsMap.keySet();
	    			if(keys!=null && keys.contains(lc.Contact__r)){
	    				List<LicenseDetail__c> licenseList = licContactsMap.get(lc.contact__r);
	    				if(licenseList!=null){
	    					licenseList.add(lc.License__r);
	    				}
	    			} else{
						List<LicenseDetail__c> licenseList = new List<LicenseDetail__c>();
						licenseList.add(lc.License__r);
						licContactsMap.put(lc.contact__r,licenseList);
	    			}
	    			
	    			
	    			String salesRep = lc.License__r.Sales_Rep__c;
	    			
	    			if(salesRep!=null){
                		Integer startIndex=salesRep.indexOf('(');
                		Integer endIndex=salesRep.lastIndexOf(')');
                		if(startIndex<endIndex && startIndex!=-1 && endIndex!=-1)
                		{
                			emailString +=salesRep.substring(startIndex+1,endIndex) + ',';
                		}
            		}
	    		}
	    		emailString = emailString.Substring(0,emailString.length()-1);
	    	}
	    	
	    	List<Contact> contactsKey = new List<Contact>();
	    	contactsKey.addAll(licContactsMap.keySet());
	    	
	    	for(Integer i=0;i<contactsKey.size();i++){
	    		Contact con = contactsKey.get(i);
	    		List<LicenseDetail__c> licenseList = licContactsMap.get(con);
	    		Integer counter = i+1;
	    		//emailContent +='&nbsp;&nbsp;&nbsp;  <b>'+counter+'. '+con.Name+'</b><br/>';
	    		emailContent += '<tr><td><a href='+EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.SALESFORCE_URL)+con.id+'>'+con.Name+'</a></td><td>';
	    		for(LicenseDetail__c l: licenseList){
	    			//emailContent +='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*'+l.id+'<br/>';
	    			emailContent +='<a href='+EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.SALESFORCE_URL)+l.id+'>'+l.id+'</a><br/>';
	    		}
	    		emailContent +='</td></tr>';
	    	}
			emailContent +='</table> ';	    		    	
	    	emailContent +=' <br><br/> <br><br/> Regards, <br/>'+UserInfo.getName();
	    	
	    	if(licContactsMap.size()>0){
	    		EmailUtil.notifyAccountOwner(emailContent,emailString);
	    	}
    	}catch(Exception e){
    		EmailUtil.notifyError(e, null);
    	}
    }
}
    }*/
}