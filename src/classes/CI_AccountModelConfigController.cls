public with sharing class CI_AccountModelConfigController {
    
    private CI_AccountModelConfig__c currentconfig;
    
    public Integer InstanceNumber { get{Init(); return CurrentInstanceNumber; } set;}
    
    public static Integer GetAdditionalInstanceCount()
    {
            CI_AccountModelConfig__c cfg = CI_AccountModelConfig__c.getInstance('default');
            if(cfg==null || cfg.Additional_Instances__c == null) return 0;
            return cfg.Additional_Instances__c.IntValue();
    }    

    private Integer CurrentInstanceNumber = 0;
        
    private Map<String,String> m_AvailableRoles;      // Indexed by the role
    
    private List<String> m_AvailableRoleList;           // In order provided by Describe
    
    private Map<String, CI_ContactRoleWeight__c> m_WeightInfo;
        
    private Set<String> m_AvailableCampaignTouches = new Set<String>{'First Touch', 'Last Touch', 'Primary Campaign Source'};
    
    private List<String> m_AvailableCampaignTouchesList = new List<String>{'First Touch', 'Last Touch', 'Primary Campaign Source'};      
        
    public CI_ContactRoleWeight__c noRoleWeightConfig {get;set;}
    
    private Map<String, CI_CampaignSpecificWeight__c> m_WeightInfoCampaign;
    
    public Map<String, CI_CampaignTypeExcluded__c> m_CampaignTypeExcludeInfo {get;set;}
    
    public Map<String, CI_OpportunityTypeExclude__c> m_OppTypeExcludeInfo {get;set;}
    
    private List<String> m_AvailableCampaignTypesList;
    
    private Map<String,String> m_AvailableCampaignTypes2;
    
    private Integer instNum;

    public void Init()
    {
        if(currentconfig!=null) return;
        String InstanceInfo = Apexpages.currentPage().getParameters().get('instance');
        if(InstanceInfo!=null)
        {
            try
            {
                CurrentInstanceNumber = Integer.valueOf(InstanceInfo);
            } catch(Exception ex) {}
        }
        
        Schema.DescribeFieldResult ocrroleinfo = OpportunityContactRole.Role.getDescribe();
        List <Schema.PicklistEntry> plelist = ocrroleinfo.getPicklistValues();
        m_AvailableRoles = new Map<String,String>();
        m_AvailableRoleList = new List<String>();   
        
        for(Schema.PicklistEntry ple: plelist)
        {
            m_AvailableRoles.put(ple.getValue(),ple.getLabel());
            m_AvailableRoleList.add(ple.getValue());
        }      
        
        Schema.DescribeFieldResult typefields = Schema.sObjectType.Campaign.fields.Type;
        List<Schema.PickListEntry> pickvalues = typefields.getPicklistValues();                
        m_AvailableCampaignTypesList = new List<String>();
        m_AvailableCampaignTypes2 = new Map<String,String>();         

        for(Schema.Picklistentry ple: pickvalues)
        {
            m_AvailableCampaignTypes2.put(ple.getLabel(),ple.getLabel());
            m_AvailableCampaignTypesList.add(ple.getLabel());           
        }
        
        instNum = CurrentInstanceNumber;
        LoadInstance(CurrentInstanceNumber);
    }   
    
    // Creates picklist of lead's Account lookup fields 
    public List<SelectOption> leadAccountFieldOptions {
        get {
        	if (leadAccountFieldOptions == null)
        	{	        		
        		List<SelectOption> options = new List<SelectOption>();
        		options.add(new selectOption('',''));		        	
	            Map<String, Schema.SObjectField> leadFieldMap = Schema.SObjectType.Lead.fields.getMap();
	            for (String fieldname : leadFieldMap.keySet())
	            {
	            	if (!(fieldname.split('__', 2).size() < 3)) continue;
	            	Schema.DescribeFieldResult fieldDesc = leadFieldMap.get(fieldname).getDescribe();
	            	if (fieldDesc.getType() == DisplayType.REFERENCE)
	            	{	
	            		Set<String> references = new Set<String>();						            		
						for (Schema.SObjectType refType : fieldDesc.getReferenceTo()) references.add(String.valueOf(refType));
						if (references.contains('Account'))
						{
			        	    options.add( 
			                    new selectOption(
			                        fieldDesc.getName(), 
			                        fieldDesc.getLabel()
			                    )
			                );								
						}            		
	            	}
	            }
	            options.sort();
	            leadAccountFieldOptions = options;
        	}
            return leadAccountFieldOptions;                 
        }
        set;
    }        
    
    // Creates picklist for opp fields available to be added as currency fields
    public List<SelectOption> currencyFieldOptions {
        get {
        	if (currencyFieldOptions == null)
        	{	
        		List<SelectOption> options = new List<SelectOption>();        	
	            Map<String, Schema.SObjectField> oppFieldMap = Schema.SObjectType.Opportunity.fields.getMap();
	            for (String fieldname : oppFieldMap.keySet())
	            {
	            	Schema.DescribeFieldResult fieldDesc = oppFieldMap.get(fieldname).getDescribe();
	            	if (fieldDesc.getType() == DisplayType.CURRENCY)
	            	{
		        	    options.add( 
		                    new selectOption(
		                        fieldDesc.getName(), 
		                        fieldDesc.getLabel()
		                    )
		                );	            		
	            	}
	            }
	            options.sort();
	            currencyFieldOptions = options;
        	}
            return currencyFieldOptions;                 
        }
        set;
    }	    
    
    public PageReference CreateInstance()
    {
        Init();
        CI_AccountModelConfig__c cfg = CI_AccountModelConfig__c.getInstance('default');
        if(cfg==null && CurrentInstanceNumber==0) cfg = currentconfig;
        if(cfg.Additional_Instances__c==null) cfg.Additional_Instances__c=1; else cfg.Additional_Instances__c++;
        Database.Upsert(cfg);
        
        return Cancel();
    }     
    
    public PageReference DeleteLastInstance()
    {
            Init();
            if(CurrentInstanceNumber== 0 || CurrentInstanceNumber < GetAdditionalInstanceCount()) return null;
            CI_AccountModelConfig__c cfg = CI_AccountModelConfig__c.getInstance('default');
            if(cfg==null || cfg.Additional_Instances__c==null) return Cancel();     // Should never happen
            cfg.Additional_Instances__c--;
            Database.Update(cfg);
            if(currentconfig.id!=null) 
            {
                Database.Delete(currentconfig);
                delete m_WeightInfo.values();
                delete m_WeightInfoCampaign.values();
                delete m_OppTypeExcludeInfo.values();
                delete m_CampaignTypeExcludeInfo.values();
                delete noRoleWeightConfig;
            }
            return Cancel();
    }         
        
    public void LoadInstance(Integer InstanceNumber)
    {
        String InstanceName = (InstanceNumber==0) ? 'default' : 'default-'+ String.ValueOf(InstanceNumber);
        CI_AccountModelConfig__c cfg = CI_AccountModelConfig__c.getInstance( InstanceName);
        if(cfg==null)
        {
            currentconfig = new CI_AccountModelConfig__c();
            currentconfig.name = InstanceName;
            currentconfig.DateFilter__c = 'create';
            currentconfig.CloseDateCutoff__c = false;
        }
        else 
        {
            currentconfig = cfg;
            if(currentconfig.DateFilter__c == 'none') currentconfig.DateFilter__c = 'create';
            if(currentconfig.DateFilter__c == null) currentconfig.DateFilter__c = 'create';
        }         
        
        // Getting settings specific for instance
        Map<String,CI_ContactRoleWeight__c> crwentries = new Map<String,CI_ContactRoleWeight__c>();
        for (CI_ContactRoleWeight__c crw : CI_ContactRoleWeight__c.getAll().values()) if (crw.Instance__c == InstanceNumber) crwentries.put(crw.Name, crw);
        m_WeightInfo = new Map<String, CI_ContactRoleWeight__c>();
                
        Map<String,CI_CampaignSpecificWeight__c> cswentries = new Map<String,CI_CampaignSpecificWeight__c>();
        for (CI_CampaignSpecificWeight__c csw : CI_CampaignSpecificWeight__c.getAll().values()) if (csw.Instance__c == InstanceNumber) cswentries.put(csw.Name, csw);             
        m_WeightInfoCampaign = new Map<String, CI_CampaignSpecificWeight__c>();        

        Map<String,CI_CampaignTypeExcluded__c> ctentries = new Map<String,CI_CampaignTypeExcluded__c>();
        for (CI_CampaignTypeExcluded__c cte : CI_CampaignTypeExcluded__c.getAll().values()) if (cte.Instance__c == InstanceNumber) ctentries.put(cte.Name, cte);             
        m_CampaignTypeExcludeInfo = new Map<String, CI_CampaignTypeExcluded__c>();        

        Map<String,CI_OpportunityTypeExclude__c> otentries = new Map<String,CI_OpportunityTypeExclude__c>();
        for (CI_OpportunityTypeExclude__c ote : CI_OpportunityTypeExclude__c.getAll().values()) if (ote.Instance__c == InstanceNumber) otentries.put(ote.Name, ote);             
        m_OppTypeExcludeInfo = new Map<String, CI_OpportunityTypeExclude__c>();
        
        // Load existing entries into the map
        for(CI_CampaignSpecificWeight__c csw: cswentries.values()) m_WeightInfoCampaign.put(csw.Type__c, csw);
        for(CI_CampaignTypeExcluded__c cte: ctentries.values()) m_CampaignTypeExcludeInfo.put(cte.Campaign_Type__c, cte);
        for(CI_OpportunityTypeExclude__c ote: otentries.values()) m_OppTypeExcludeInfo.put(ote.Opp_Type__c, ote);
        
        Boolean roleConfigFound = false;
        for(String crwName: crwentries.keySet()) 
        {
            if (!crwName.contains('No Role'))
            {
                m_WeightInfo.put(crwentries.get(crwName).Role__c, crwentries.get(crwName));
            }
            else
            {
                roleConfigFound = true;
                noRoleWeightConfig = crwentries.get(crwName);
            }
        }
                
        // Now create new objects for those that are missing
        for(String cType: m_AvailableCampaignTypes2.keyset())
        {
            if(!m_CampaignTypeExcludeInfo.containskey(cType))
            {
            	String ctName = GetStatusMappingName('w' + string.ValueOf(InstanceNumber) + cType);                
                m_CampaignTypeExcludeInfo.put(cType, new CI_CampaignTypeExcluded__c(Name = ctName, Exclude__c = false, Campaign_Type__c = cType, Instance__c = InstanceNumber));
            }
        }              
        
        // Now create new objects for those that are missing
        for(String role: m_AvailableRoles.keyset())
        {
            if(! m_WeightInfo.containskey(role))
            {
                String rolename = GetStatusMappingName('w' + string.ValueOf(InstanceNumber) + role);
                m_WeightInfo.put(role, new CI_ContactRoleWeight__c(Role__c = role, Name = rolename, weight__c = 0, Instance__c = InstanceNumber ));
            }
        }
        
        // Add default setting used for when Opportunity Contact Role Label is null
        if (!roleConfigFound)
        {
        	String noRolename = GetStatusMappingName('w' + string.ValueOf(InstanceNumber) + 'No Role');
            noRoleWeightConfig = new CI_ContactRoleWeight__c(Role__c = 'No Role', Name = noRolename, weight__c = 0, Instance__c = InstanceNumber );
        }
         
        // Create list of available campaign touches       
        for(String ctype: m_AvailableCampaignTouchesList)
        {
            if(! m_WeightInfoCampaign.containskey(ctype))
            {
            	String typename = GetStatusMappingName('w' + string.ValueOf(InstanceNumber) + ctype);
                m_WeightInfoCampaign.put(ctype, new CI_CampaignSpecificWeight__c(Type__c = ctype, Name = typename, weight__c = 0, Instance__c = InstanceNumber ));
            }
        }  
                            
    }    
    
    public List<OppTypeExclude> oppTypeExcludeList {
    	get {
    		if (oppTypeExcludeList == null)
    		{		          			
    			List<OppTypeExclude> oppTypeExcludes = new List<OppTypeExclude>();
    			Map<String, Boolean> excludeByOppType = new Map<String, Boolean>();
    			Map<String, CI_OpportunityTypeExclude__c> oppTypeExcludeSetting = CI_OpportunityTypeExclude__c.getAll();
    			for (CI_OpportunityTypeExclude__c ote : oppTypeExcludeSetting.values()) if (ote.Instance__c == InstanceNumber) excludeByOppType.put(ote.Opp_Type__c, ote.Exclude__c);
       			
		        Schema.DescribeFieldResult typefields = Schema.sObjectType.Opportunity.fields.Type;
		        List<Schema.PickListEntry> pickvalues = typefields.getPicklistValues();	
		        
		        for(Schema.PicklistEntry ple: pickvalues) 
		        {
		        	oppTypeExcludes.add(
		        		new OppTypeExclude(
		        			excludeByOppType.get(ple.getLabel()) != null ? excludeByOppType.get(ple.getLabel()) : false,
		        			ple.getLabel()
		        		)
		        	);
		        }
		        oppTypeExcludeList = oppTypeExcludes;  			
    		}  	
    		return oppTypeExcludeList;
    	}
    	set;
    }     
	
	public class OppTypeExclude 
	{	
		public Boolean exclude {get;set;}
		public String typeVal {get;set;}
		
		public OppTypeExclude(Boolean exclude, String typeVal) 
		{
			this.exclude = exclude;
			this.typeVal = typeVal;
		}		
	}	

    public Set<String> getCampaignTypes()
    {
        Init();
        return m_CampaignTypeExcludeInfo.keySet();
    }

    public List<String> getAvailableCampaignTouches()
    {
        Init();
        return m_AvailableCampaignTouchesList;
    }
    
    public Map<String, CI_CampaignSpecificWeight__c> getWeightInfoCampaign()
    {
        Init();
        return m_WeightInfoCampaign;
    }

    public List<String> getAvailableRoles()
    {
        Init();
        return m_AvailableRoleList; 
    }
    
    public List<String> getAvailableCampaignTypes2()
    {
        Init();
        return m_AvailableCampaignTypesList; 
    }
    
    public List<CI_ContactRoleWeight__c> weightInfoList {
        get {
            if (weightInfoList != null) return weightInfoList;
            return m_WeightInfo.values();
        }
        set;
    }
    
    public Map<String, String> getRoleLabels()
    {
        Init();
        return m_AvailableRoles;
    }
    
    public Map<String, String> getCampaignTypeLabels()
    {
        Init();
        return m_AvailableCampaignTypes2;
    }    
    
    public Map<String, CI_ContactRoleWeight__c> getWeightInfo()
    {
        Init();
        return m_WeightInfo;
    }

    public Map<String, CI_CampaignTypeExcluded__c> getCampaignTypeExclude()
    {
        Init();
        return m_CampaignTypeExcludeInfo;
    }

    public CI_AccountModelConfig__c configobject { get { init(); return currentconfig; } }


    public PageReference Save()
    {
        Init();
        
        if (configobject.Currency_Field_Name__c == null || configobject.Currency_Field_Name__c == 'Amount')  
        {
            configobject.Currency_Field_Name__c = 'Amount';
        }   
        else
        {
            PageReference pr = ApexPages.currentPage();
            pr.getParameters().put('returl', ApexPages.currentPage().getParameters().get('returl'));
            String InstanceInfo = Apexpages.currentPage().getParameters().get('instance');
            if (InstanceInfo != null)
            {
                pr.getParameters().put('instance', InstanceInfo);               
            }           
            
            Map<String, Schema.SObjectField> oppFieldMap = Schema.SObjectType.Opportunity.fields.getMap();
            if (oppFieldMap.get(configobject.Currency_Field_Name__c) != null)
            {
                Schema.DescribeFieldResult objDesc = oppFieldMap.get(configobject.Currency_Field_Name__c).getDescribe();
                if (objDesc.getType() != DisplayType.CURRENCY)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'The Currency Field Name entered is not a currency field'));                   
                    return pr;
                }
            }
            else
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'The Currency Field Name entered does not exist on the Opportunity'));
                return pr;              
            }
        }     
        
        Database.Upsert(currentconfig);
        
        // Save/Update Contact Role Weight Settings
        // ----------------------------------------------------------------------------------------------------------------
        List<CI_ContactRoleWeight__c> weightstoupdate = new List<CI_ContactRoleWeight__c>();
        List<CI_ContactRoleWeight__c> weightstodelete = new List<CI_ContactRoleWeight__c>();
        Map<String,CI_ContactRoleWeight__c> currententries = CI_ContactRoleWeight__c.getAll();
        
        for(CI_ContactRoleWeight__c crw : weightInfoList)
        {
            // If this entry doesn't have a current match, delete it
            if(!m_AvailableRoles.ContainsKey(crw.Role__c) && crw.id!=null && crw.Role__c != 'No Role') weightstodelete.add(crw);
            
            // If it's a new entry, or existing entry and value has changed, add it to the list to update
            if(crw.id==null || currententries.containskey(crw.name) && (crw.Weight__c != currententries.get(crw.Name).Weight__c || crw.Exclude_From_Influence__c != currententries.get(crw.Name).Exclude_From_Influence__c)) 
                weightstoupdate.add(crw);
        }
        if(weightstodelete.size()>0) delete weightstodelete;
        if(weightstoupdate.size()>0) upsert weightstoupdate;    // Upsert new or revised values
        upsert noRoleWeightConfig;

        // Save/Update Campaign Specific Weight Settings
        // ----------------------------------------------------------------------------------------------------------------
        List<CI_CampaignSpecificWeight__c> c_weightstoupdate = new List<CI_CampaignSpecificWeight__c>();
        List<CI_CampaignSpecificWeight__c> c_weightstodelete = new List<CI_CampaignSpecificWeight__c>();
        Map<String,CI_CampaignSpecificWeight__c> campaigncurrententries = CI_CampaignSpecificWeight__c.getAll();
        
        for(CI_CampaignSpecificWeight__c csw: m_WeightInfoCampaign.Values())
        {
            // If this entry doesn't have a current match, delete it
            if(!m_AvailableCampaignTouches.contains(csw.Type__c) && csw.id!=null) c_weightstodelete.add(csw);

            // If it's a new entry, or existing entry and value has changed, add it to the list to update
            if(csw.id==null || campaigncurrententries.containskey(csw.name) && csw.Weight__c != campaigncurrententries.get(csw.Name).Weight__c) c_weightstoupdate.add(csw);
        }
        if(c_weightstodelete.size()>0) delete c_weightstodelete;
        if(c_weightstoupdate.size()>0) upsert c_weightstoupdate;    // Upsert new or revised values

		for (oppTypeExclude ote : oppTypeExcludeList)
		{
			String oppTypeExcludeName = GetStatusMappingName('w' + string.ValueOf(InstanceNumber) + ote.typeVal);
			if (m_OppTypeExcludeInfo.get(ote.typeVal) == null) m_OppTypeExcludeInfo.put(ote.typeVal, new CI_OpportunityTypeExclude__c(
				Name=oppTypeExcludeName, Instance__c = InstanceNumber, Opp_Type__c = ote.typeVal, Exclude__c = ote.exclude)
			);
			else m_OppTypeExcludeInfo.get(ote.typeVal).Exclude__c = ote.exclude;
		}

		upsert m_OppTypeExcludeInfo.values();

        // Save/Update Campaign Type Exclude Settings
        // ----------------------------------------------------------------------------------------------------------------        
        upsert m_CampaignTypeExcludeInfo.values();                
        
        return Cancel();        // And return to main
    }
    
	// Returns the name for the customs etting record, hashed if necessary due to length
	public string GetStatusMappingName(String status)
	{
		String result;
		String encodedStatus = EncodingUtil.urlEncode(status, 'ASCII');
		if(encodedStatus.length()>35)
		{
			result=EncodingUtil.base64Encode(Crypto.GenerateDigest('SHA1',Blob.ValueOf(status)));
		}
		else result = status;
		return result;
	}     
    
    public PageReference Cancel()
    {
            String returl = ApexPages.currentPage().getParameters().get('returl');
            if(returl!=null) return new PageReference(returl);
            return null;
    }  
}