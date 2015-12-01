public with sharing class ADUAUI {
    
    public ADUAController_V2.ADUAUserDetails aduaUser{get;set;}
    public Contact contactObj;
    public Contact_Portal_User__c contactPortalUser;
    public transient License_Contacts__c licCt;
    public DBLicense_Contacts__c dbLicCt;
    public List<SystemEntry> systemEntries = new List<SystemEntry>();
    public List<ADUAZoneDetails> zoneList = new List<ADUAZoneDetails>();
    public Boolean fez{get;set;}
    public Boolean fezOriginal;
    public Boolean newUser{get;set;}
    public String downloadsVisible{get;set;}
    public String docsVisible{get;set;}
    public Boolean active{get;set;}
    public Boolean isPrimary {get;set;}
    public Boolean helpAgent{get;set;}
    
    
    private ADUAUI(Contact contactObj,ADUAController_V2.ADUAUserDetails aduaUserDetails,SObject licCt){
        this.aduaUser = aduaUserDetails;
        this.contactObj = contactObj;
        this.contactPortalUser = (Contact_Portal_User__c)contactObj.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).get(0);
        //TEMP Fix if aduaUserDetails is null. We should fix it like in above constructor to initialize aduaUserDetails from contact if backend returns null
        if(aduaUserDetails==null){
            return;
        }
        aduaUserDetails.contactId = contactObj.id;
        //this.licCt = licCt;
        if(licCt!=null){
            String objName = licCt.getSObjectType().getDescribe().getName();
            if('License_Contacts__c'.equals(objName)){
                this.licCt = (License_Contacts__c)licCt;
            } else if('DBLicense_Contacts__c'.equals(objName)){
                this.dbLicCt = (DBLicense_Contacts__c)licCt;
            } 
        }
        active=aduaUserDetails.isActive!=null&&Boolean.valueOf(aduaUserDetails.isActive);
        
        isPrimary = false;
        if(this.licCt!=null){
            isPrimary = (this.licCt!=null && this.licCt.Contact_Type__c.equals('PRIMARY'));
        }
        if(this.dbLicCt!=null){
            isPrimary = (this.dbLicCt!=null && this.dbLicCt.Contact_Type__c.equals('PRIMARY'));
        }
        String applicationsStr = aduaUserDetails.getApplications();
        systemEntries = new List<SystemEntry>();        
        SystemEntry se;// = new SystemEntry();
        if(applicationsStr.contains('download-zones') || isPrimary){
            downloadsVisible='block';
            se = new SystemEntry();
            se.systemName = AppDConstants.ACCESSIBLE_DOWNLOADS;
            se.selected = true;
            se.selectedOriginal = se.selected;
            systemEntries.add(se);
            this.contactPortalUser.Download__c=true;
        }else{
            downloadsVisible='none';
            se = new SystemEntry();
            se.systemName = AppDConstants.ACCESSIBLE_DOWNLOADS;
            se.selected = false;
            se.selectedOriginal = se.selected;
            systemEntries.add(se);
            this.contactPortalUser.Download__c=false;
        }
        if(applicationsStr.contains('docs')|| isPrimary){
            se = new SystemEntry();
            se.systemName = AppDConstants.ACCESSIBLE_DOCS;
            se.selected = true;
            se.selectedOriginal = se.selected;
            systemEntries.add(se);
            if(applicationsStr.contains('docs-partner-fez')){
                fez = true;
                fezOriginal = fez;
                docsVisible = 'block';
            }else{
                fez = false;
                fezOriginal = fez;
                docsVisible = 'none';
            }
            if(UsersUtil.isPartner(contactObj.Account)){
                docsVisible = 'block';             
             }else{
                docsVisible = 'none';
             }
             this.contactPortalUser.Docs__c=true;
        }else{
            se = new SystemEntry();
            se.systemName = AppDConstants.ACCESSIBLE_DOCS;
            se.selected = false;
            se.selectedOriginal = se.selected;
            systemEntries.add(se);
            docsVisible='none';
            this.contactPortalUser.Docs__c=false;
        }
        if(applicationsStr.contains('help')|| isPrimary){
            se = new SystemEntry();
            se.systemName = AppDConstants.ACCESSIBLE_ZENDESK;
            se.selected = true;
            se.selectedOriginal = se.selected;
            systemEntries.add(se);
            //aduaUser.isActive = true;
            this.contactPortalUser.ZenDesk__c=true;
            if(applicationsStr.contains('help-agents')){
                helpAgent = true;
            }
        }else{
            se = new SystemEntry();
            se.systemName = AppDConstants.ACCESSIBLE_ZENDESK;
            se.selected = false;
            se.selectedOriginal = se.selected;
            systemEntries.add(se);
            this.contactPortalUser.ZenDesk__c=false;
            helpAgent = false;
        }

        if(applicationsStr.contains('community-fanclub') || (this.contactObj.Registered_Fan_Club__c == 'Yes')){
            se = new SystemEntry();
            se.systemName = AppDConstants.ACCESSIBLE_FAN_CLUB;
            se.selected = true;
            se.selectedOriginal = se.selected;
            systemEntries.add(se);
            this.contactObj.Registered_Fan_Club__c = 'Yes';
        }
		else{
            se = new SystemEntry();
            se.systemName = AppDConstants.ACCESSIBLE_FAN_CLUB;
            se.selected = false;
            se.selectedOriginal = se.selected;
            systemEntries.add(se);
            this.contactObj.Registered_Fan_Club__c = 'No';
            helpAgent = false;
        }        

        //LMS needs to be checked for every contact so it will selected by default
            se = new SystemEntry();
            se.systemName = AppDConstants.ACCESSIBLE_LMS;
            se.selected = true;
            se.isLMS = true;
            se.selectedOriginal = false;
            systemEntries.add(se);
            //aduaUser.isActive = true;
            this.contactPortalUser.LMS__c=true;
            
        if(applicationsStr.contains('mindtickle-partners')){
            se = new SystemEntry();
            se.isVisible = UsersUtil.isPartner(contactObj.Account);
            se.systemName = AppDConstants.MINDTICKLE_SSO;
            se.selected = true;
            se.selectedOriginal = se.selected;
            systemEntries.add(se);
        }
		else{
            se = new SystemEntry();
            if(UsersUtil.isPartner(contactObj.Account)) {
                se.isVisible = true;
            }
            else {
                se.isVisible = false;
            }
            se.systemName = AppDConstants.MINDTICKLE_SSO;
            se.selected = false;
            se.selectedOriginal = se.selected;
            systemEntries.add(se);
            helpAgent = false;
        }        
            
        zoneList = new List<ADUAZoneDetails>();  
        List<Zone__c> liZones = CommonUtil.getAllZoneList();
        for(Zone__c zone: liZones){
            String zonePath = zone.Zone_Path__c;
            ADUAZoneDetails ad = new ADUAZoneDetails();
            if(applicationsStr.contains(zonePath)){
                ad.selected = true;
                ad.selectedOriginal = ad.selected;
                ad.zone = zone;  
                zoneList.add(ad);
            }else{
                ad.selected = false;
                ad.selectedOriginal = ad.selected;
                ad.zone = zone;  
                if(CommonUtil.isPartnerUserLoggedIn()){
                    if(zone.Enabled_for_Partner__c){
                        zoneList.add(ad);
                    }
                }else{
                    zoneList.add(ad);
               }
            }
        }
        
        if(CommonUtil.isPartnerUserLoggedIn() && !active){
        	for(SystemEntry sysEntry:systemEntries){
        		if(sysEntry.systemName == AppDConstants.ACCESSIBLE_DOWNLOADS ||
	        		sysEntry.systemName == AppDConstants.ACCESSIBLE_DOCS||
	        		sysEntry.systemName == AppDConstants.ACCESSIBLE_ZENDESK||
	        		sysEntry.systemName == AppDConstants.ACCESSIBLE_LMS
        		){
        			sysEntry.selected=true;		
        		}else if(sysEntry.systemName == AppDConstants.MINDTICKLE_SSO){
	        		if(UsersUtil.isPartner(contactObj.Account)) {
			            sysEntry.isVisible = true;
			            sysEntry.selected = true;
			        }
        		}	
        	}
        	
        	for(ADUAZoneDetails zoneDetail: zonelist){
        		if(BackendConstants.DOWNLOAD_ZONE_SAAS_PUBLIC.equals(zoneDetail.zone.Zone_Path__c) ||
        			BackendConstants.DOWNLOAD_ZONE_ON_PREMISE_PUBLIC.equals(zoneDetail.zone.zone_path__c)){
        			zoneDetail.selected=true;
        		}
        	}
        }
    }
    
    public List<SystemEntry> getSystemEntries(){
        return systemEntries;
    }
    
    public List<ADUAZoneDetails> getZoneList(){
        return zoneList;
    }
    
    public Boolean isChanged(){
        for(SystemEntry sys:systemEntries){
            if(sys.isChanged()){
                return true;
            }
        }
        
        for(ADUAZoneDetails zone:zoneList){
            if(zone.isChanged()){
                return true;
            }
        }
        if(fez!=fezOriginal){
            return true;
        }
        return false;
    }
    
    public void updateADUAUserDetails(SObject obj){
        String oldApplicationsStr = aduaUser.getApplications();
        aduaUser.applications = new Set<String>();
        
        String downloadZone = '';
        if(obj!=null){
            String objName = obj.getSObjectType().getDescribe().getName();
            if('DBTuna_License__c'.equals(objName)){
                downloadZone = BackendConstants.DOWNLOAD_ZONE_DB_ON_PREMISE_PUBLIC;
            } else if('LicenseDetail__c'.equals(objName)){
                    LicenseDetail__c licenseDetailObj = (LicenseDetail__c)obj;
                    if(licenseDetailObj.Product_Type__c.equals(AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE)){
                        downloadZone = BackendConstants.DOWNLOAD_ZONE_ON_PREMISE_PUBLIC;    
                    }else{
                        downloadZone = BackendConstants.DOWNLOAD_ZONE_SAAS_PUBLIC;
                    }
            }   
        }
        
        for(SystemEntry se: systemEntries){
                if(se.systemName.equals(AppDConstants.ACCESSIBLE_DOWNLOADS)){
                    if(se.selected == true){
                        active=true;
                        String downloadZoneStr = '';
                        for(ADUAZoneDetails ad: zoneList){
                            if(downloadZone.equals(ad.zone.Zone_Path__c)){
                                if(!ad.selected){
                                    ad.selected = true;
                                }
                            }
                            if(ad.selected){
                                aduaUser.applications.add('download-zones/'+ad.zone.Zone_Path__c);
                            }
                        }
                        if(!aduaUser.getApplications().contains('download-zones')){
                            for(ADUAZoneDetails ad: zoneList){
                                if(ad.zone.Zone_Path__c.equals(BackendConstants.DOWNLOAD_ZONE_ON_PREMISE_PUBLIC)){
                                    ad.selected = true;
                                    aduaUser.applications.add('download-zones/'+BackendConstants.DOWNLOAD_ZONE_ON_PREMISE_PUBLIC);  
                                    break;
                                }
                            }
                            //aduaUser.applications.add('download-zones/'+BackendConstants.DOWNLOAD_ZONE_ON_PREMISE_PUBLIC);
                        }
                    } else{
                        for(ADUAZoneDetails ad: zoneList){
                            ad.selected = false;
                        }
                    } 
                }
                
                if(se.systemName.equals(AppDConstants.ACCESSIBLE_DOCS)){
                    if(se.selected == true){
                        active=true;
                        if(obj==null){
                            if((fez!=null && fez)){
                                aduaUser.applications.add('docs/docs-partner-fez');
                            }else if(oldApplicationsStr.contains('docs/docs-customer')){
                                aduaUser.applications.add('docs/docs-customer');
                            }else{
                                aduaUser.applications.add('docs/docs-internal');
                            }
                        } else{
                            if(oldApplicationsStr.contains('docs-partner-fez') || (fez!=null && fez)){
                                aduaUser.applications.add('docs/docs-partner-fez');
                            }else if(oldApplicationsStr.contains('docs/docs-customer')){
                                aduaUser.applications.add('docs/docs-customer');
                            }else{
                                aduaUser.applications.add('docs/docs-internal');
                            }
                        }
                    }
                }
                
                if(se.systemName.equals(AppDConstants.ACCESSIBLE_ZENDESK)){
                    if(se.selected == true){
                        active=true;
                        if(helpAgent!=null && helpAgent){
                            aduaUser.applications.add('help/help-agents');
                        }else{
                            aduaUser.applications.add('help');
                        }
                    }
                }
                
                if(se.systemName.equals(AppDConstants.ACCESSIBLE_LMS)){
                    if(se.selected == true){
                        active=true;
                        aduaUser.applications.add('learning-system/lms-learner');
                    }
                }
				
                if(se.systemName.equals(AppDConstants.ACCESSIBLE_FAN_CLUB)){
                    if(se.selected == true){
                        active=true;
                        aduaUser.applications.add('community-fanclub');
                    }
                }

                if(se.systemName.equals(AppDConstants.MINDTICKLE_SSO)){
                    if(se.selected == true){
                        active=true;
                        aduaUser.applications.add('mindtickle-partners');
                    }
                }
				
            }
            aduaUser.isActive=active+'';
            aduaUser.firstName = this.contactObj.firstName;
            aduaUser.lastName = this.contactObj.lastName;
            
            this.contactPortalUser.Docs__c = aduaUser.getApplications().contains('docs');
            this.contactPortalUser.Download__c = aduaUser.getApplications().contains('download-zones');
            this.contactPortalUser.ZenDesk__c = aduaUser.getApplications().contains('help');
            this.contactPortalUser.LMS__c = aduaUser.getApplications().contains('learning-system');
            if(aduaUser.getApplications().contains('community-fanclub')) {
	            this.contactObj.Registered_Fan_Club__c = 'Yes';
            }
            else {
	            this.contactObj.Registered_Fan_Club__c = 'No';
            }
    }
    
    public static ADUAUI newInstance(Contact contactObj,ADUAController_V2.ADUAUserDetails aduaUserFromBackend,SObject licCt){
        ADUAUI instance=null;
        Boolean newUser=false;
        Contact_Portal_User__c contactPortalUser =  (Contact_Portal_User__c)contactObj.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).get(0); //contactObj.Portal_User__r.get(0);
        if(aduaUserFromBackend==null||aduaUserFromBackend.userId==null){
            newUser=true;
            aduaUserFromBackend = new ADUAController_V2.ADUAUserDetails();
                        aduaUserFromBackend.contactId = contactObj.id;
            aduaUserFromBackend.email = contactObj.Email;
            aduaUserFromBackend.firstName = contactObj.FirstName;
            aduaUserFromBackend.lastName = contactObj.LastName;
            aduaUserFromBackend.applications = new Set<String>();
            if(contactPortalUser.Download__c){
                aduaUserFromBackend.isActive='true';
                aduaUserFromBackend.applications.add('download-zones/'+BackendConstants.DOWNLOAD_ZONE_ON_PREMISE_PUBLIC);
            }
            if(contactPortalUser.Docs__c){
                aduaUserFromBackend.isActive='true';
                String accName = contactObj.Account.Name;
                if(contactObj.Email!=null&& contactObj.Email.endsWith('@appdynamics.com') ||accName.containsIgnoreCase('appdynamics')){
                    aduaUserFromBackend.applications.add('docs/docs-internal');
                }else{
                    if(contactObj.Account.RecordType.Name.containsIgnorecase('Partner')){
                        aduaUserFromBackend.applications.add('docs/docs-partner');
                    }else{
                        aduaUserFromBackend.applications.add('docs/docs-customer');
                    }
                }
            }
            if(contactPortalUser.ZenDesk__c){
                aduaUserFromBackend.isActive='true';
                aduaUserFromBackend.applications.add('help');
            }
            if(contactPortalUser.LMS__c){
                aduaUserFromBackend.isActive='true';
                aduaUserFromBackend.applications.add('learning-system/lms-learner');
            }   
        }
        if(aduaUserFromBackend.applications==null){
            aduaUserFromBackend.applications = new Set<String>();
        }
        //Fix for Null Pointer Exception when backend returns null for aduaUserFromBackend
        aduaUserFromBackend.contactId = contactObj.id;
        instance=new ADUAUI(contactObj,aduaUserFromBackend,licCt);
        instance.newUser=newUser;
        return instance;
    }
    public static ADUAUI newInstance(Contact contactObj,ADUAController_V2.ADUAUserDetails aduaUserFromBackend){
        return newInstance(contactObj,aduaUserFromBackend,null);
    }   
    
    public class ADUAZoneDetails{
        public Zone__c zone{get;set;}
        public Boolean selected{get;set;}
        public Boolean selectedOriginal{get;set;}
        public Boolean isChanged(){
            return selected!=selectedOriginal;
        }
    }
    
    public class SystemEntry{
        public SystemEntry() { 
            isVisible = true;
        }
        public String systemName{get;set;}
        public Boolean selected{get;set;}
        public Boolean isVisible{get;set;}
        public Boolean isLMS{get;set;}
        public Boolean selectedOriginal{get;set;}
        public Boolean isChanged(){
            return selected!=selectedOriginal;
        }
    }   
    
    public static testMethod void testADUAUI_1(){
        EnvironmentSettings.testEnvironmentSettings();
        RESTAPI.unitTestMode = true;
        Account acc = new Account(Name='Test Account',PortalID__c='123456',RecordTypeId='01280000000LrcY');
        insert acc;
        Contact con  = new Contact(firstName='Test fn',lastName='Test ln',email='test@appdynamics.com',Accountid=acc.id,Download__c=true,Docs__c=true,ZenDesk__c=true,LMS__c=true);
        insert con;
        
        Contact_Portal_User__c contactPortalUser = null;
        if(con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME)==null || con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).size()==0){
            //contactPortalUser = new Contact_Portal_User__c(Contact__c=con.Id);
            contactPortalUser = new Contact_Portal_User__c();
            contactPortalUser.put('Contact__c',con.Id);
            insert contactPortalUser;
        }
        
        con = (Contact)DataLayerConstants.fetchSingle('Contact',con.id);
        
        UserDetailsBackend.testResponseJson = '{"users": [{"applications": ["docs/docs-customer","help","download-zones/saas-public","learning-system/lms-learner"], "userId": 55883, "email": "testcontact25thaugust@tarams.com", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":true}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
        ADUAController_V2.ADUAUserDetails ad = new ADUAController_V2.ADUAUserDetails();
        ADUAUI.newInstance(con, ad);
    }
    
     public static testMethod void testADUAUI_2(){
        EnvironmentSettings.testEnvironmentSettings();
        RESTAPI.unitTestMode = true;
        Account acc = new Account(Name='Test Account',PortalID__c='123456',RecordTypeId='01280000000LrcY');
        insert acc;
        Contact con  = new Contact(firstName='Test fn',lastName='Test ln',email='test@appdynamics.com',Accountid=acc.id,Download__c=true,Docs__c=true,ZenDesk__c=true,LMS__c=true);
        insert con;
        
        Contact_Portal_User__c contactPortalUser = null;
        if(con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME)==null || con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).size()==0){
            //contactPortalUser = new Contact_Portal_User__c(Contact__c=con.Id);
            contactPortalUser = new Contact_Portal_User__c();
            contactPortalUser.put('Contact__c',con.Id);
            insert contactPortalUser;
        }
        
        con = (Contact)DataLayerConstants.fetchSingle('Contact',con.id);
        UserDetailsBackend.testResponseJson = '{"users": [{"applications": ["docs/docs-customer","help","download-zones/saas-public","learning-system/lms-learner"], "userId": 55883, "email": "testcontact25thaugust@tarams.com", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":true}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
        ADUAController_V2.ADUAUserDetails ad = new ADUAController_V2.ADUAUserDetails();
        ADUAUI.newInstance(con, ad,new License_Contacts__c(Contact_Type__c='PRIMARY'));
    }
    
    public static testMethod void testADUAUI_3(){
        EnvironmentSettings.testEnvironmentSettings();
        RESTAPI.unitTestMode = true;
        Account acc = new Account(Name='Test Account',PortalID__c='123456',RecordTypeId='01280000000LrcY');
        insert acc;
        Contact con  = new Contact(firstName='Test fn',lastName='Test ln',email='test@appdynamics.com',Accountid=acc.id,Download__c=true,Docs__c=true,ZenDesk__c=true,LMS__c=true);
        insert con;
        
        Contact_Portal_User__c contactPortalUser = null;
        if(con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME)==null || con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).size()==0){
            //contactPortalUser = new Contact_Portal_User__c(Contact__c=con.Id);
            contactPortalUser = new Contact_Portal_User__c();
            contactPortalUser.put('Contact__c',con.Id);
            insert contactPortalUser;
        }
        
        con = (Contact)DataLayerConstants.fetchSingle('Contact',con.id);
        
        UserDetailsBackend.testResponseJson = '{"users": [{"applications": ["docs/docs-customer","help","download-zones/saas-public","learning-system/lms-learner"], "userId": 55883, "email": "testcontact25thaugust@tarams.com", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":true}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
        ADUAController_V2.ADUAUserDetails ad = new ADUAController_V2.ADUAUserDetails();
        ADUAUI adu = ADUAUI.newInstance(con, ad,new DBLicense_Contacts__c(Contact_Type__c='PRIMARY'));
        adu.getSystemEntries();
    }
    
    public static testMethod void testADUAUI_4(){
        EnvironmentSettings.testEnvironmentSettings();
        RESTAPI.unitTestMode = true;
        Account acc = new Account(Name='Test Account',PortalID__c='123456',RecordTypeId='01280000000LrcY');
        insert acc;
        Contact con  = new Contact(firstName='Test fn',lastName='Test ln',email='test@appdynamics.com',Accountid=acc.id,Download__c=true,Docs__c=true,ZenDesk__c=true,LMS__c=true);
        insert con;
        
        Contact_Portal_User__c contactPortalUser = null;
        if(con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME)==null || con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).size()==0){
            //contactPortalUser = new Contact_Portal_User__c(Contact__c=con.Id);
            contactPortalUser = new Contact_Portal_User__c();
            contactPortalUser.put('Contact__c',con.Id);
            insert contactPortalUser;
        }
        
        con = (Contact)DataLayerConstants.fetchSingle('Contact',con.id);
        
        UserDetailsBackend.testResponseJson = '{"users": [{"applications": ["mindtickle-partners","docs/docs-customer","help","download-zones/saas-public","learning-system/lms-learner"], "userId": 55883, "email": "testcontact25thaugust@tarams.com", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":true}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
        ADUAController_V2.ADUAUserDetails ad = new ADUAController_V2.ADUAUserDetails();
        ADUAUI adu = ADUAUI.newInstance(con, ad,new DBLicense_Contacts__c(Contact_Type__c='PRIMARY'));
        adu.getSystemEntries();
    }
}