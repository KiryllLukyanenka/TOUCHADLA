public virtual class LicenseBackend extends Backend{
    public Boolean emailPropertiesRequired=true; 
    public LicenseDetail__c license{get;set;}
    public License_EUM_Details__c eumDetails{get;set;}        
    public LicenseEUMInput eumInput{get;set;}
    private List<OpportunityTeamMember> opportunityMembers;
    private Opportunity myOpportunity;  
    private List<PortalDataType.LicenseAgentInfo> licAgents;
    private List<ContactWrapper> licenseContacts;
    public LicenseBackend(){  
    }

    private Account accObj;
    public LicenseBackend(LicenseDetail__c license, Opportunity opp, Account acc, List<PortalDataType.LicenseAgentInfo> licAgents,List<ContactWrapper> licContacts,LicenseEUMInput eumInput,Integer opCode){
        super(license,opcode);
        this.license=license;
        this.myOpportunity = opp;
        this.accObj = acc;
        this.opCode = opcode;
        this.licAgents = licAgents;
        this.licenseContacts=licContacts;
        this.eumInput = eumInput;
        try{
            opportunityMembers = [Select Id,User.Name,User.Id,User.Email,User.Username,User.FirstName,User.LastName,OpportunityId from OpportunityTeamMember where OpportunityId=:myOpportunity.Id];
        }catch(Exception e){
            //license.Reason__c = 'Opportunity:'+myOpportunity+' Error:'+e.getStackTraceString();
        }
        setupInputParameters();
    }
    
    public virtual override void handleResponse(String response, Integer statusCode){
        if(response!=null){
            CommonUtil.updateLicenseResponse(response, license,eumInput.eumDetails);
        }
    }  
    
    public virtual override void setupInputParameters(){
        setParameters(new List<BackendLayer.BackendParameter>());
        BackendLayer.BackendParameter param = null;

        param = new BackendLayer.BackendParameter('operationType',BackendConstants.OPCODE_TO_OPERATION_MAP.get(opCode));
        getParameters().add(param);

        String expiryDate = String.valueOf(license.License_Expiry_Date__c);
        
        param = new BackendLayer.BackendParameter('expiryDate',expiryDate);
        getParameters().add(param);
        
        if(licAgents==null){
            licAgents = LicenseUtil.getLicenseAgentInfoList(license, BackendConstants.OPCODE_VIEW_LICENSE);
        }
        
        if(licAgents!=null){
            LicenseUtil.calculateApplicationAnalytics(licAgents);
            List<Backend> agentBackends = new List<Backend>();
            Integer total=0;
            boolean isPaid = false;
            boolean isLite = false;
            if(license.Stage__c!=null){
                if(license.Stage__c.contains('PAID') ||  opcode==BackendConstants.OPCODE_ADD_LICENSE || opcode==BackendConstants.OPCODE_TRANSITION_TO_PERMANENT){
                    isPaid = true;
                }
                if(opcode == BackendConstants.OPCODE_CONVERT_TO_LITE){
                	isLite = true;
                }
            }
            for(PortalDataType.LicenseAgentInfo licAgentInfo:licAgents){
                License_Agent__c licAgent = licAgentInfo.licAgent;
                String agentCategory = licAgent.Category__c;
                if(PortalDataType.LICENSING_MODEL_FIXED.equals(licAgent.Licensing_Model__c)){
                    licAgent.Max_Agents__c = licAgent.Count__c;
                }
                
                if(isLite){
                	licAgent.Edition__c = PortalDataType.EDITION_LITE;
                    licAgent.Expiration_Date__c = license.License_Expiry_Date__c;
                }else if(!isPaid){
                    if(licAgent.Agent_Type__c!='Synthetic'){
                        licAgent.Edition__c = PortalDataType.EDITION_PRO_TRIAL;
                    }
                    licAgent.Expiration_Date__c = license.License_Expiry_Date__c;
                }
                
                if(BackendConstants.LICENSE_AGENT_CATEGORY_APM.equals(agentCategory) || 
                    BackendConstants.LICENSE_AGENT_CATEGORY_ANALYTICS.equals(agentCategory) ||
                    BackendConstants.LICENSE_AGENT_CATEGORY_SYNTHETIC.equals(agentCategory)){
                    if(licAgentInfo.agentMetadata.Enabled__c)
                    {
                    	agentBackends.add(new LicenseAgentBackend(license,licAgentInfo,null,null,false));
	                    if(!'Database'.equals(licAgent.Agent_Type__c) && BackendConstants.LICENSE_AGENT_CATEGORY_APM.equals(agentCategory)){
	                        if(licAgent.Max_Agents__c!=null && licAgent.Max_Agents__c > 0){
	                            total+=Integer.valueOf(licAgent.Max_Agents__c);
	                        }else if(licAgent.Count__c!=null){
	                            total+=Integer.valueOf(licAgent.Count__c);
	                        }
	                    }
                    }
                }
            }
            
            if(eumInput.eumWeb!=null && eumInput.eumWeb.Type__c!=null){
                if(eumInput.eumMobile==null){
                    eumInput.eumMobile = new EUM_Mobile__c();
                }if(eumInput.eumMobile.Type__c == null){
                    eumInput.eumMobile.Type__c = 'LITE';
                    eumInput.eumMobile.Units__c = 1;
                }
                agentBackends.add(new LicenseAgentBackend(license,null,eumInput.eumWeb,null));
                agentBackends.add(new LicenseAgentBackend(license,null,null,eumInput.eumMobile));
            }

            License_Agent__c licTotalAgents=new License_Agent__c();
            licTotalAgents.Agent_Type__c = 'Total';
            licTotalAgents.Count__c = total;
            licTotalAgents.Licensing_Model__c='FIXED';
            if(license.Stage__c!=null && license.Stage__c.contains('PAID')){
                licTotalAgents.Edition__c='PRO';    
            }else{
                if(opcode==BackendConstants.OPCODE_ADD_LICENSE || opcode==BackendConstants.OPCODE_TRANSITION_TO_PERMANENT){
                    licTotalAgents.Edition__c='PRO';
                }else{
                    licTotalAgents.Edition__c='PRO_TRIAL';
                }
            }
            
            licTotalAgents.Max_Agents__c = total;
            licTotalAgents.Expiration_Date__c = license.License_Expiry_Date__c;
            agentBackends.add(new LicenseAgentBackend(license,licTotalAgents,null,null));
            param = new BackendLayer.BackendParameter();
            param.key='license-agents';
            param.backendParameterType = BackendConstants.BACKEND_PARAM_TYPE_LIST_OF_BACKEND;
            param.backendList=agentBackends;
            getParameters().add(param);
        }
        
        
        param = new BackendLayer.BackendParameter('IsEUM',license.IS_EUM__c+'');
        getParameters().add(param);
        
        //TODO Removing Reason to avoid special character errors.
        param = new BackendLayer.BackendParameter('reason','');
        getParameters().add(param);
        
        String productType = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE.equals(license.Product_Type__c)?'On-Premise':'SAAS';
        param = new BackendLayer.BackendParameter('ProductType',productType);
        getParameters().add(param);

        String selectedController = '';
        String customerSaasURL = '';
        if(license.Custom_URL_Name__c!=null){
            customerSaasURL =license.Custom_URL_Name__c; 
        }
        param = new BackendLayer.BackendParameter('customerSaasUrl',customerSaasURL);
        getParameters().add(param);
        
        if(!AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE.equals(license.Product_Type__c)){
            if (license.SaaS_Password__c == null || license.SaaS_Password__c == '') {
                license.SaaS_Password__c = CommonUtil.generatePassword();
            }
            if(license.Saas_Access_Key__c == null || license.SaaS_Access_Key__c.trim().equals('')){
                license.SaaS_Access_Key__c = license.SaaS_Password__c; 
            }
            
            param = new BackendLayer.BackendParameter('saasPassword',license.SaaS_Password__c);
            getParameters().add(param);
            param = new BackendLayer.BackendParameter('accountAccessKey',license.SaaS_Access_Key__c);
            getParameters().add(param);
        }
        
        Boolean manualSaaS = license.Manual_SaaS_Fields__c;
        if(manualSaaS==null || !manualSaaS){
            license.SAAS_UserName__c = license.Custom_URL_Name__c;
            license.SaaS_Account__c= license.Custom_URL_Name__c;    
        }
        
        if(license.Support__c){
            param = new BackendLayer.BackendParameter('controller_id',license.Controller_ID__c);
            getParameters().add(param);
            param = new BackendLayer.BackendParameter('support',true+'');
            getParameters().add(param);
        }  
            
        param = new BackendLayer.BackendParameter('saasUserName',license.SAAS_UserName__c);
        getParameters().add(param);
        
        param = new BackendLayer.BackendParameter('saasAccount',license.SaaS_Account__c);
        getParameters().add(param);
        
        String macAddress = '';
        if(license.MAC_Address__c!=null){
            macAddress =  license.MAC_Address__c;
        }
        param = new BackendLayer.BackendParameter('MacAddress',macAddress);
        getParameters().add(param);
        
        String licenseBackendId = '';
        if(license.License_BackendID__c!=null){
            licenseBackendId = license.License_BackendID__c; 
        }
        param = new BackendLayer.BackendParameter('licenseId',licenseBackendId);
        getParameters().add(param);
        
        String coradiantIntegrationURL = '';
        if(license.Coradiant_Integration_URL__c!=null){
            coradiantIntegrationURL = license.Coradiant_Integration_URL__c;
        }
        param = new BackendLayer.BackendParameter('coradiantIntegrationURL',coradiantIntegrationURL);
        getParameters().add(param);
        String sfID = '';
        if(license.Id!=null){
            sfID = license.Id;
        }
        param = new BackendLayer.BackendParameter('salesforceID',sfID);
        getParameters().add(param);
        
        RUMBackend rumBackend = new RUMBackend(license,eumInput,opcode);
        param = new BackendLayer.BackendParameter();
        param.backendParameterType = BackendConstants.BACKEND_PARAM_TYPE_BACKEND;
        param.key = 'rum';
        param.backendData = rumBackend;
        getParameters().add(param);
        
        if(emailPropertiesRequired){
            param = new BackendLayer.BackendParameter('contacts',CommonUtil.jsonArrayOfContactRoles(license,licenseContacts,opportunityMembers));
            getParameters().add(param);
            
            String techOwnerEmail= CommonUtil.getTechincalOwnerEmail(myOpportunity);
            
            param = new BackendLayer.BackendParameter('techOwner',techOwnerEmail);
            getParameters().add(param);
            
            if(myOpportunity!=null){
                if(myOpportunity.Owner!=null){
                    param = new BackendLayer.BackendParameter('opportunityOwner', myOpportunity.Owner.Email);
                    getParameters().add(param);
                }
                
                param = new BackendLayer.BackendParameter('opportunityId',myOpportunity.Id);
                getParameters().add(param);
                if(accObj==null){
                    accObj= [Select Id,OwnerId,Name,Technical_Account_Manager__r.Id, Technical_Account_Manager__r.Email from Account where Id=:myOpportunity.AccountId];
                }
            }
            if(accObj!=null){
                String technicalAccountManagerEmail = '';
                try{
                    if(accObj.Technical_Account_Manager__c!=null){
                        technicalAccountManagerEmail = accObj.Technical_Account_Manager__r.Email;
                    }
                }catch(Exception e){}
                param = new BackendLayer.BackendParameter('technicalAccountManagerEmail',technicalAccountManagerEmail);//UsersUtil.getUserEmailByName(accObj.Technical_Account_Manager__c));
                getParameters().add(param);
                
                String owner = accObj.OwnerId;
                User ownerUser =  null;
                try{
                    ownerUser = [Select Id,Name,Email,LastName from User where Id=:owner];
                }catch(Exception e){}
                param = new BackendLayer.BackendParameter('accountManagerEmail',ownerUser!=null?ownerUser.Email:null);
                getParameters().add(param);
                
                param = new BackendLayer.BackendParameter('customerName',accObj.Name);
                getParameters().add(param);
            }
            String creatorUserID = Userinfo.getUserId();
            try{
                User creatorUser = [Select Id,Name,Email,CompanyName,Contact.Account.Id,Contact.Account.Name,LastName from User where Id=:creatorUserId];
                param = new BackendLayer.BackendParameter('salesRepEmail',creatorUser.Email);
                getParameters().add(param);
                
                String creatorUserAccName = '';
                try{
                    creatorUserAccName = creatorUser.Contact.Account.Name;
                }catch(Exception e){
                    
                }
                /*if('NTT Europe'.equalsIgnoreCase(creatorUserAccName)){
                    Backend bk = new Backend();
                    BackendLayer.BackendParameter valParam= new BackendLayer.BackendParameter('envName','NTT');
                    BackendLayer.BackendParameter dnsParam= new BackendLayer.BackendParameter('createDNS','false');
                    bk.getParameters().add(valParam);
                    bk.getParameters().add(dnsParam);
                    param = new BackendLayer.BackendParameter('saas',bk);
                    getParameters().add(param);
                }*/
            }catch(Exception e){
            }
        }
    }
    
    public class LicenseTransactionCheck extends LicenseBackend{
        public LicenseTransactionCheck(LicenseDetail__c license,LicenseEUMInput eumInput){
            super(license,null,null,null,null,eumInput,BackendConstants.OPCODE_GET_LIC_TRANSACTION_STATE);
        }
        
        public override virtual void setupInputParameters(){
            BackendLayer.BackendParameter param = new BackendLayer.BackendParameter();
            param.backendParameterType = BackendConstants.BACKEND_PARAM_TYPE_URL_APPEND;
            param.value = license.Transaction_ID__c;
            getParameters().add(param);
        }
    }
    
    public class SupportLicenseProvision extends LicenseBackend{
        private String controllerId;
        public SupportLicenseProvision(LicenseDetail__c license, String controllerId,LicenseEUMInput eumInput,Integer opcode){
            super(license,null,null,null,null,eumInput,opcode);
            this.controllerId = controllerId;
            setupInputParameters();
        }
        
        public override virtual void setupInputParameters(){
            super.setupInputParameters();
            BackendLayer.BackendParameter param = new BackendLayer.BackendParameter('controller_id',controllerId);
            getParameters().add(param);
            param = new BackendLayer.BackendParameter('support',true+'');
            getParameters().add(param);
        }
    }
    
    public class LicenseAgentBackend extends Backend{
        private License_Agent__c licenseAgent;
        private EUM_Web__c eumWeb;
        private EUM_Mobile__c eumMobile;
        private LicenseDetail__c lic;
        private PortalDataType.LicenseAgentInfo licAgentInfo;
        
        public LicenseAgentBackend(LicenseDetail__c lic,License_Agent__c licenseAgent, EUM_Web__c eumWeb, EUM_Mobile__c eumMobile){
            this.licenseAgent= licenseAgent;
            this.eumWeb = eumWeb;
            this.eumMobile = eumMobile;
            this.lic = lic;
            setupInputParameters();
        }
        
        public LicenseAgentBackend(LicenseDetail__c lic,PortalDataType.LicenseAgentInfo licAgentInfo, EUM_Web__c eumWeb, EUM_Mobile__c eumMobile, Boolean test){
        	this.licAgentInfo = licAgentInfo;
            this.licenseAgent = licAgentInfo.licAgent;
            this.eumWeb = eumWeb;
            this.eumMobile = eumMobile;
            this.lic = lic;
            setupInputParameters();
        }
        
        public override virtual void setupInputParameters(){
            
            BackendLayer.BackendParameter agentTypeParam = new BackendLayer.BackendParameter('agent-type','');
            BackendLayer.BackendParameter expirationDateParam = new BackendLayer.BackendParameter('expiration-date','');
            BackendLayer.BackendParameter licensingModelParam = new BackendLayer.BackendParameter('licensing-model','');
            BackendLayer.BackendParameter countParam = new BackendLayer.BackendParameter('count','');
            BackendLayer.BackendParameter maxCountParam = new BackendLayer.BackendParameter('max_count','');
            BackendLayer.BackendParameter allowOveragesParam = new BackendLayer.BackendParameter('allow-overage','');
            BackendLayer.BackendParameter editionParam = new BackendLayer.BackendParameter('edition','');
            BackendLayer.BackendParameter dataRetentionParam = new BackendLayer.BackendParameter('retention_period',0);

            getParameters().add(agentTypeParam);
            getParameters().add(expirationDateParam);
            getParameters().add(licensingModelParam);
            getParameters().add(countParam);
            getParameters().add(maxCountParam);
            getParameters().add(allowOveragesParam);
            getParameters().add(editionParam);
            getParameters().add(dataRetentionParam);
            
            

            if(licenseAgent!=null){
            	if(BackendConstants.LICENSE_AGENT_CATEGORY_ANALYTICS.equals(licenseAgent.Category__c)){
	            	if(licenseAgent.Retention_Period__c!=null){
	            		integer retention = 0;
	                    try{
	                        retention = Integer.valueof(licenseAgent.Retention_Period__c);
	                    }catch(Exception e){
	                        
	                    }
	                   	
	                   	if(licenseAgent.Count__c > 0 || licenseAgent.Max_Agents__c>0){
	                   		if(retention==0){
								retention = Integer.valueof(LicenseUtil.setDataRetentionDefaults(lic, licenseAgent));
	                   		}	
	                   	}else{
	                   		retention = 0;
	                   	}
	                   	dataRetentionParam.intVal = retention;   
	                }
            	}
                editionParam.value = licenseAgent.Edition__c;
                
                
                String agentType = licenseAgent.Agent_Type__c;
                if(licAgentInfo!=null && licAgentInfo.agentMetadata!=null){
                	 agentType = licAgentInfo.agentMetadata.Portal_API_Name__c;//'.NET'.equals(licenseAgent.Agent_Type__c)?'.Net':licenseAgent.Agent_Type__c;
                }
                
                agentTypeParam.value=agentType;
                if(licenseAgent.Licensing_Model__c==null){
                    licenseAgent.Licensing_Model__c = 'Fixed';
                }
                licensingModelParam.value=licenseAgent.Licensing_Model__c;
                
                expirationDateParam.value = String.valueOf(licenseAgent.Expiration_Date__c);
                Integer agentCount = 0;
                if(licenseAgent.Count__c!=null){
                    agentCount = Integer.valueOf(licenseAgent.Count__c);
                }
                countParam.value = String.valueOf(agentCount);
                Integer maxCount = 0;
                if(licenseAgent.Max_Agents__c!=null){
                    maxCount = Integer.valueOf(licenseAgent.Max_Agents__c);
                }
                if(maxCount<agentCount){
                    maxCount = agentCount;
                }
                maxCountParam.value = String.valueOf(maxCount);
                Boolean allowOverages = 'Overages'.equals(licenseAgent.Licensing_Model__c);
                allowOveragesParam.value = String.valueOf(allowOverages);
            }
            if(eumWeb!=null && eumWeb.Type__c!=null){
                
                String agentType = BackendConstants.EUM_TYPE_BACKEND_MAP.get(eumWeb.Type__c);
                agentTypeParam.value = agentType;
                Integer agentCount = 0;
                if(eumWeb.Units__c!=null){
                    agentCount = Integer.valueOf(eumWeb.Units__c);
                }
                editionParam.value = eumWeb.Type__c;
                countParam.value = String.valueOf(agentCount);
                Boolean allowOverages = false;
                if(eumWeb.Allow_Overages__c!=null){
                    allowOverages = eumWeb.Allow_Overages__c;
                }
                allowOveragesParam.value = String.valueOf(allowOverages);

                expirationDateParam.value = String.valueOf(lic.License_Expiry_Date__c);
                maxCountParam.value = String.valueOf(agentCount);
                licensingModelParam.value='Fixed';
            }

            if(eumMobile!=null && eumMobile.Type__c!=null){
                String agentType = BackendConstants.EUM_MOBILE_TYPE_BACKEND_MAP.get(eumMobile.Type__c);
                agentTypeParam.value = agentType;
                Integer agentCount = 0;
                if(eumMobile.Units__c!=null){
                    agentCount = Integer.valueOf(eumMobile.Units__c);
                }
                editionParam.value = eumMobile.Type__c;
                countParam.value = String.valueOf(agentCount);
                Boolean allowOverages=false;
                if(eumMobile.Allow_Overages__c!=null){
                    allowOverages = eumMobile.Allow_Overages__c;
                }
                allowOveragesParam.value = String.valueOf(allowOverages);

                expirationDateParam.value = String.valueOf(lic.License_Expiry_Date__c);

                maxCountParam.value = String.valueOf(agentCount);
                licensingModelParam.value='Fixed';
            }
        }
    }
    
    public class RUMBackend extends LicenseBackend{
        private LicenseDetail__c licObj;
        public RUMBackend(LicenseDetail__c licObj,LicenseEUMInput eumInput,Integer licenseOpcode){
            super();
            this.opcode=licenseOpcode;
            this.licObj= licObj;
            this.eumInput = eumInput;
            setupInputParameters();
        }
        
        public override virtual void setupInputParameters(){
            BackendLayer.BackendParameter param = new BackendLayer.BackendParameter();
            ///<portal-company-id>/deactivate
            String rumAction = '';
            String rumAccName = '';
            param = new BackendLayer.BackendParameter('OPCODE',opcode+'');
            getParameters().add(param);
                
            if(opcode==BackendConstants.OPCODE_UNPROVISION_LICENSE){
                rumAction='disable';
            }else if(opcode==BackendConstants.OPCODE_EXPIRE_LICENSE){
                rumAction='disable';
            }else{
                if(eumInput.eumDetails!=null && eumInput.eumDetails.RUM_Enabled__c!=null){
                    if(eumInput.eumDetails.RUM_Enabled__c){
                         rumAction = 'enable'; 
                    }else{
                        rumAction = null;
                    }
                }else{
                    rumAction = null;
                }
            }
            param = new BackendLayer.BackendParameter('action',rumAction);
            getParameters().add(param);
            
            param = new BackendLayer.BackendParameter('rum-account-name',(eumInput.eumDetails!=null && eumInput.eumDetails.AccountName__c!=null)?eumInput.eumDetails.AccountName__c:null);
            getParameters().add(param);
            
            param = new BackendLayer.BackendParameter('agent-units',(eumInput.eumWeb!=null && eumInput.eumWeb.Type__c!=null)?Integer.ValueOf(eumInput.eumWeb.Units__c):null);
            getParameters().add(param);
              
            param = new BackendLayer.BackendParameter('allow-overage',eumInput.eumWeb!=null?eumInput.eumWeb.Allow_Overages__c+'':false+'');
            getParameters().add(param);
            
            param = new BackendLayer.BackendParameter('type',eumInput.eumWeb!=null?BackendConstants.EUM_TYPE_BACKEND_MAP.get(eumInput.eumWeb.Type__c):null);
            getParameters().add(param);
            
            param = new BackendLayer.BackendParameter('mobile-agent-units',(eumInput.eumMobile!=null && eumInput.eumMobile.Type__c!=null)?Integer.ValueOf(eumInput.eumMobile.Units__c):null);
            getParameters().add(param);
              
            param = new BackendLayer.BackendParameter('mobile-allow-overage',eumInput.eumMobile!=null?eumInput.eumMobile.Allow_Overages__c+'':false+'');
            getParameters().add(param);
            
            param = new BackendLayer.BackendParameter('mobile-type',eumInput.eumMobile!=null?BackendConstants.EUM_MOBILE_TYPE_BACKEND_MAP.get(eumInput.eumMobile.Type__c):null);
            getParameters().add(param);
            
            param = new BackendLayer.BackendParameter('import-eum',eumInput.eumDetails!=null?eumInput.eumDetails.Import_EUM__c+'':false+'');
            getParameters().add(param);
            
            param = new BackendLayer.BackendParameter('rum-access-key',eumInput.eumDetails!=null?eumInput.eumDetails.Access_Key__c:'');
            getParameters().add(param);
        }
    }
}