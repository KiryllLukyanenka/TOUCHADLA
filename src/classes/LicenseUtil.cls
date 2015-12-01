/**
 * Class: LicenseUtil
 * Package: None 
 * Abstract: Helper class containing all common methods needed to do licensing operations, 
 * in terms of initializing/copying/modifying license and related objects
 */
public with sharing class LicenseUtil {
	
	public static map<String,LicenseProduct_Metadata__c> getSupportedProductsMetadata(){
    	//Retrieve all the license product metadata objects
    	list<LicenseProduct_Metadata__c> supportedProductMetadataList = null;
    	try{
    		 supportedProductMetadataList = [Select Id,Name, Order__c, SF_API_NAME__c, Portal_API_Name__c, Included_In_Total__c, Category__c, Enabled__c, IS_Beta__c  from LicenseProduct_Metadata__c ORDER BY Order__c];
    	}catch(Exception e){
    		System.debug(LoggingLevel.Error,'Error while getting the supported metadata of products:'+e);
    	}
    	if(supportedProductMetadataList == null || supportedProductMetadataList.size()==0){
    		supportedProductMetadataList = new List<LicenseProduct_Metadata__c>();
    		integer orderVal = 0; 
    		for(String agentType:BackendConstants.LICENSE_AGENT_TYPES_APM){
    			System.debug('Agent Type:'+agentType);
    			LicenseProduct_Metadata__c licProdMetadata = new LicenseProduct_Metadata__c(Name=agentType, 
                                  SF_API_Name__c = agentType,
    															Portal_API_Name__c = BackendConstants.AGENT_TYPE_BACKEND_MAP.get(agentType),
    															Category__c = BackendConstants.LICENSE_AGENT_CATEGORY_APM, 
                                  Enabled__c=true,
    															Order__c = orderVal++);
				
				licProdMetadata.Included_in_Total__c = (agentType!='Database' && agentType!='Total'); 
				
				supportedProductMetadataList.add(licProdMetadata);
    		}
    		
    		for(String agentType:BackendConstants.LICENSE_AGENT_TYPES_ANALYTICS){
    			System.debug('Agent Type:'+agentType);
    			LicenseProduct_Metadata__c licProdMetadata = new LicenseProduct_Metadata__c(Name=agentType, 
                                  SF_API_Name__c = agentType,
    															Portal_API_Name__c = BackendConstants.AGENT_TYPE_BACKEND_MAP.get(agentType),
    															Category__c = BackendConstants.LICENSE_AGENT_CATEGORY_ANALYTICS, 
                                  Enabled__c=true,
    															Order__c = orderVal++);
				supportedProductMetadataList.add(licProdMetadata);
    		}
    		upsert supportedProductMetadataList;
    	}
    	map<String,LicenseProduct_Metadata__c> productMetadataMap = new map<String,LicenseProduct_Metadata__c>();
    	for(LicenseProduct_Metadata__c metadata:supportedProductMetadataList){
    		productMetadataMap.put(metadata.SF_API_Name__c,metadata);
    	}
    	return productMetadataMap;
    }
    	
    //Profile IDs for enabling Paid License operations. These are read from Portal Settings db object through Environment Settings layer
    public static String AD_FINANCE_PROFILE_ID = EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.AD_FINANCE_PROFILE_ID);//getProfileId('AD Finance');
    public static String AD_SALES_OPS_PROFILE_ID = EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.AD_SALES_OPS_PROFILE_ID);//getProfileId('AD Sales Ops');
    public static String AD_SYS_ADMINISTRATORS_PROFILE_ID = EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.AD_SYS_ADMINISTRATORS_PROFILE_ID);//getProfileId('System Administrator');
     
     /*
      * Copies License Agent Objects from one license to other license, used for HA License flows
      */
     public static List<PortalDataType.LicenseAgentInfo> copyLicenseAgents(List<PortalDataType.LicenseAgentInfo> licAgents,Boolean includeLicenseLink){
       List<PortalDataType.LicenseAgentInfo> newLicAgents = new List<PortalDataType.LicenseAgentInfo>();
       for(PortalDataType.LicenseAgentInfo licAgentInfo:licAgents){
         PortalDataType.LicenseAgentInfo newLicAgentInfo = copyLicenseAgentInfo(licAgentInfo, includeLicenseLink);
         newLicAgents.add(newLicAgentInfo);
       } 
       return newLicAgents;
     }
     
     /*
      * Called from above method for single license agent info to create a copy
      */
     public static PortalDataType.LicenseAgentInfo copyLicenseAgentInfo(PortalDataType.LicenseAgentInfo licAgentInfo,Boolean includeLicenseLink){
      PortalDataType.LicenseAgentInfo newLicAgentInfo = new PortalDataType.LicenseAgentInfo(licAgentInfo,includeLicenseLink);
     	return newLicAgentInfo;
     }
     
     /* 
      * Creates a clone of given License object as HA License. 
      * This is used by HALicenseController during enabling HA license for a Paid On Premise license.
      */
     public static LicenseDetail__c createHALicense(LicenseDetail__c sourceObject){
        LicenseDetail__c destObj = new LicenseDetail__c();
        destObj.Product_Type__c = sourceObject.Product_Type__c;
        destObj.Stage__c = sourceObject.Stage__c;
        destObj.License_Expiry_Date__c = sourceObject.License_Expiry_Date__c;
        destObj.IS_HA__c = true;
        destObj.Is_EUM__c = sourceObject.Is_EUM__c;
        destObj.Is_Permanent__c = sourceObject.Is_Permanent__c;
        destObj.Is_Perpetual__c= sourceObject.Is_Perpetual__c;
        destObj.Custom_URL_Name__c = sourceObject.Custom_URL_Name__c;
        destObj.Primary_Contact__c = sourceObject.Primary_Contact__c;
        destObj.Additional_Contacts__c = sourceObject.Additional_Contacts__c;
        destObj.Account_Manager__c = sourceObject.Account_Manager__c;
        destObj.Sales_Rep__c = sourceObject.Sales_Rep__c;
        destObj.Technical_Owner__c = sourceObject.Technical_Owner__c;
        destObj.Ad_hoc_Email_Ids__c = sourceObject.Ad_hoc_Email_Ids__c;
        destObj.HA_Source_License__c = sourceObject.Id;
        destObj.LastOpcode__c=BackendConstants.OPCODE_HA_LICENSE;
        return destObj;
     }
     
    /*
		 * Creating EUM records for HA License.    		
     */
    public static LicenseEUMInput createEUMLicense(LicenseEUMInput eumInput, LicenseDetail__c licenseDetail){
     	License_EUM_Details__c eumDetail = new License_EUM_Details__c();
     	eumDetail.License__c = licenseDetail.id;
     	eumDetail.RUM_Enabled__c = eumInput.eumDetails.RUM_Enabled__c;
     	eumDetail.AccountName__c = eumInput.eumDetails.AccountName__c;
     	eumDetail.Access_Key__c = eumInput.eumDetails.Access_Key__c;
     	eumDetail.Import_EUM__c = eumInput.eumDetails.Import_EUM__c;
     	
     	EUM_Web__c eumWeb = new EUM_Web__c();
     	eumWeb.License_EUM_Detail__c = eumDetail.id;
     	eumWeb.Type__c = eumInput.eumWeb.Type__c;
     	eumWeb.Allow_overages__c = eumInput.eumWeb.Allow_overages__c;
     	eumWeb.Units__c = eumInput.eumWeb.Units__c;
     	
     	EUM_Mobile__c eumMobile = new EUM_Mobile__c();
     	eumMobile.License_EUM_Detail__c = eumDetail.id;
     	eumMobile.Type__c = eumInput.eumMobile.Type__c;
     	eumMobile.Allow_overages__c = eumInput.eumMobile.Allow_overages__c;
     	eumMobile.Units__c = eumInput.eumMobile.Units__c;
     	
     	LicenseEUMInput newEumInput = new LicenseEUMInput(eumDetail,eumWeb,eumMobile);
     	return newEumInput;
     }
     
     /*
      * Retrieves HA License associated with given license. 
      * This is used by ViewLicenseController to display HA License in the main license page.
      */
     public static LicenseDetail__c getHALicense(LicenseDetail__c lic){
        return (LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c', 'HA_Source_License__c',lic.Id );
     }
     
     /*
      * Checks if a license operation is supported for a logged in user.
      * Checks if the logged in user's profile id is among the Profile IDs defined in Settings object for paid license flows.
      * If yes returns true; else returns true only 
      * @param opcode the operation code as defined in BackendConstants indicating the license operation 
      */
     public static Boolean isOperationSupport(LicenseDetail__c licenseDetailObj,Integer opcode){
       String profileId = UserInfo.getProfileId();
       String licenseStage = '';
       if(licenseDetailObj!=null){
          licenseStage = licenseDetailObj.Stage__c;
       }
       if(profileId.startsWith(AD_FINANCE_PROFILE_ID) || profileId.startsWith(AD_SALES_OPS_PROFILE_ID) || profileId.startsWith(AD_SYS_ADMINISTRATORS_PROFILE_ID)){
         return true;
       }else{
         return (licenseStage!=null && !licenseStage.contains('PAID'))
                    &&
                (opcode==BackendConstants.OPCODE_PROVISION_FREE_TRIAL||
                  opcode==BackendConstants.OPCODE_EXTEND_TRIAL);
       }
     }
     
     /*
      * Checks if user belongs to a Privileged group ("license-orderops"). This will give the ability to provision trial/paid 
      */
     public static Boolean hasSpecialPrivileges(){
     	String profileId = UserInfo.getProfileId();
       	return (profileId.startsWith(AD_FINANCE_PROFILE_ID) || profileId.startsWith(AD_SALES_OPS_PROFILE_ID) || profileId.startsWith(AD_SYS_ADMINISTRATORS_PROFILE_ID));
     }
    
    /*
     * Get all the license agents for a given license. Initialize new objects with default values for a new license
     * and update to add new agent types for existing license.
     * This is used by getLicenseAgentInfo method which retrieves all license agents from DB and then creates a list
     * of Wrapper type LicenseAgentInfo and is used in UI, Controller and Backend integration layers.
     */
    public static List<License_Agent__c> getLicenseAgents(LicenseDetail__c licDetail, map<String, LicenseProduct_Metadata__c> supportedProducts, Boolean isPaid, Integer opcode){
      List<License_Agent__c> licAgents = licDetail.License_Agents__r;
      if(licAgents==null || licAgents.size()==0){
        try{
          //TODO Need to move this to DataLayerConstants layer
          licAgents = [Select Id,Agent_Type__c, Count__c,License__c,Licensing_Model__c,Expiration_Date__c,Max_Agents__c,Retention_Period__c,Edition__c,Category__c,Enabled__c from License_Agent__c where License__c=:licDetail.Id];
        }catch(Exception e){
          /*
           * No need to do anything here, as if there are no license agents for a given license id, 
           * we will go ahead and create fresh agent objects
           */
        }
      }

      /*
       * If the list of agents returned from db is empty, we will create a list of new License_Agent__c objects by going 
       * through all supported agent types from BackendCosntants.
       */
      if(licAgents==null||licAgents.size()==0){
      	System.debug(LoggingLevel.Info,'Adding New Agents for:'+supportedProducts);
      	licAgents = initializeNewLicenseAgents(licDetail, isPaid, supportedProducts, opcode);
      }else{
      	updateMissingAgents(licDetail,licAgents, isPaid, supportedProducts);
      }
      System.debug('Added all licenseAgentUnits:'+licAgents);
      return licAgents;
    }

	private static List<License_Agent__c> initializeNewLicenseAgents(LicenseDetail__c licDetail,Boolean isPaid, map<String,LicenseProduct_Metadata__c> supportedProducts, Integer opcode){
		List<License_Agent__c> licAgents = new list<License_Agent__c>();
		for(LicenseProduct_Metadata__c supportedProd:supportedProducts.values()){
      		License_Agent__c licAgent= new License_Agent__c();
			if(licDetail!=null && licDetail.Id!=null){
				licAgent.License__c = licDetail.Id;
			}
			licAgent.Agent_Type__c = supportedProd.SF_API_Name__c;
			licAgent.Category__c= supportedProd.Category__c;
			licAgent.Licensing_Model__c=PortalDataType.LICENSING_MODEL_FIXED;
			if(isPaid){
        		licAgent.Edition__c = PortalDataType.EDITION_PRO;	
        	}else{
        		if(opcode == BackendConstants.OPCODE_CONVERT_TO_LITE || 'LITE'.equals(licDetail.Stage__c)){
		  			licAgent.Edition__c = PortalDataType.EDITION_LITE;
		  		}else{
		  			if(licAgent.Agent_Type__c!='Synthetic'){
        				licAgent.Edition__c = PortalDataType.EDITION_PRO_TRIAL;
		  			}
        		}
        	}
        	if(BackendConstants.LICENSE_AGENT_CATEGORY_ANALYTICS.equals(licAgent.Category__c)){
        		licAgent.Retention_Period__c = '0';
        	}
        	licAgents.Add(licAgent);
      	}
      	return licAgents;
	}
    /*
     * Logic to add Missing agents in to the existing LicenseAgent objects in DB. 
     * This flow is there to take care of new agents support added and those new agents
     * should appear with default value in existing License objects upgrade flows.
     * Logic here is to go through the list of supported agent types in BackendCosntants
     * and check it against existing license agent objects for a license and if any
     */
    private static void updateMissingAgents(LicenseDetail__c licDetail, List<License_Agent__c> licAgents, Boolean isPaid, map<String,LicenseProduct_Metadata__c> supportedProducts){
      /* 
       * No need to check for null as the caller already takes care of that, 
       * and this method will be called only when the list of license agents is not null and not empty
       */
      for(String supportedProdType:supportedProducts.keySet()){
      		LicenseProduct_Metadata__c supportedProd = supportedProducts.get(supportedProdType);
      		boolean found=false;
	      	for(License_Agent__c licAgent:licAgents){
	      		LicenseProduct_Metadata__c metadata = supportedProducts.get(licAgent.Agent_Type__c);
	      		if(metadata==null){
	      			
	      		} 
	      		if(supportedProd.SF_API_Name__c.equalsIgnoreCase(licAgent.Agent_Type__c)){
		            found=true;
		            break;
				}
	      	}
	      	
	      	if(!found){
	          License_Agent__c newLicAgent= new License_Agent__c(Agent_Type__c = supportedProd.SF_API_Name__c,
	          													Count__c=0, 
	          													Licensing_Model__c = PortalDataType.LICENSING_MODEL_FIXED,
	          													Category__c= supportedProd.Category__c);	          
	            /*
	             * Update License__c with license ID. Handling error for precaution only as for existing licenses, 
	             * license id should not be null. 
	             */
	          if(isPaid){
        		newLicAgent.Edition__c = PortalDataType.EDITION_PRO;	
	           }else{
	           	if(newLicAgent.Agent_Type__c!='Synthetic'){
	        		newLicAgent.Edition__c = PortalDataType.EDITION_PRO_TRIAL;
	           	}
	          }
	          if(licDetail!=null && licDetail.Id!=null){
	            newLicAgent.License__c = licDetail.Id;
	          }
	          licAgents.Add(newLicAgent);
	        }
	      	
      	}
    }
    
    /* 
     * Method used by License Controller to initialize the license agents for a given license. This internall calls
     * getLicenseAgents defined above to get License_Agent__c objects read from db or initialized freshly and then
     * a list of wrapper objects of type LicenseAgentInfo is created which will be used by Visualforce,controller and backend classes.
     * In the wrapper object we also set the display text and also toggle the display of agent based on license type as per 
     * configuration done in BackendCosntants#LICENSE_AGENT_VISIBILITY_MAP
     */
	public static List<PortalDataType.LicenseAgentInfo> getLicenseAgentInfoList(LicenseDetail__c lic,Integer opCode){
		List<PortalDataType.LicenseAgentInfo> returnVal = new List<PortalDataType.LicenseAgentInfo>();
		boolean isPaid = false;
		if((lic.Stage__c!=null && lic.Stage__c.contains('PAID')) || opcode==BackendConstants.OPCODE_ADD_LICENSE || opcode==BackendConstants.OPCODE_TRANSITION_TO_PERMANENT){
			isPaid = true;
		}
		map<String, LicenseProduct_Metadata__c> supportedProductsMetadata = LicenseUtil.getSupportedProductsMetadata();
		List<License_Agent__c> licAgents = getLicenseAgents(lic, supportedProductsMetadata, isPaid, opcode);
		if(licAgents!=null){
			for(License_Agent__c licAgent:licAgents){
				PortalDataType.LicenseAgentInfo agentInfo = new PortalDataType.LicenseAgentInfo();
				agentInfo.licAgent = licAgent;
			  	if(licAgent.Category__c==null){
			  		licAgent.Category__c = BackendConstants.getAgentCategory(licAgent.Agent_Type__c);
			  	}
			  	if(licAgent.Expiration_Date__c == null){
				    licAgent.Expiration_Date__c = lic.License_Expiry_Date__c;
				}
				if(licAgent.Licensing_Model__c == null){
					licAgent.Licensing_Model__c = PortalDataType.LICENSING_MODEL_FIXED;
			  	}
			  	if(licAgent.Edition__c == null){
			  		if(isPaid){
				  		licAgent.Edition__c = PortalDataType.EDITION_PRO;	
				  	}else{
				  		if(opcode == BackendConstants.OPCODE_CONVERT_TO_LITE || 'LITE'.equals(lic.Stage__c)){
				  			licAgent.Edition__c = PortalDataType.EDITION_LITE;
				  		}else{
				  			if(licAgent.Agent_Type__c!='Synthetic'){
				  				licAgent.Edition__c = PortalDataType.EDITION_PRO_TRIAL;
				  			}
				  		}
				  	}
			  	}
			  	
			  	if(licAgent.Agent_Type__c == 'Synthetic'){
			  		if(licAgent.Edition__c == PortalDataType.EDITION_PRO_TRIAL){
			  			licAgent.Edition__c = 'LITE';
			  		}
			  	}
          		
          		if(licAgent.Max_Agents__c == null){
          			if(PortalDataType.LICENSING_MODEL_FIXED.equals(licAgent.Licensing_Model__c)){
						licAgent.Max_Agents__c = licAgent.Count__c;	
					}else if(PortalDataType.LICENSING_MODEL_OVERAGES.equals(licAgent.Licensing_Model__c)){
          				if(licAgent.Count__c<=250){
							licAgent.Max_Agents__c = licAgent.Count__c  + 250;	
          				}else{
          					licAgent.Max_Agents__c = 2 * licAgent.Count__c;
          				}          		
          			}else{
						licAgent.Max_Agents__c = 100;
					}
				}
				if(PortalDataType.EDITION_PRO.equals(licAgent.Edition__c) || !isPaid){
					licAgent.Expiration_Date__c = lic.License_Expiry_Date__c;
				}
				agentInfo.agentText = licAgent.Agent_Type__c;
				agentInfo.selectedProductEdition = licAgent.Edition__c;
				agentInfo.selectedProductLicensingModel = licAgent.Licensing_Model__c;
				if('Machine'.equals(licAgent.Agent_Type__c)){
					agentInfo.agentText = 'Additional '+ agentInfo.agentText;
				}
				if(agentInfo.isAnalyticsAgent){
					if(licAgent.Retention_Period__c == null || licAgent.Retention_Period__c.trim().equals('') || Integer.valueOf(licAgent.Retention_Period__c.trim())==0){
						if(licAgent.Count__c >0 && licAgent.Max_Agents__c > 0){
							licAgent.Retention_Period__c = LicenseUtil.setDataRetentionDefaults(lic, licAgent);
		        		}else{
		        			licAgent.Retention_Period__c = '0';
		        		}
					}
				}
				agentInfo.agentMetadata = supportedProductsMetadata.get(agentInfo.licAgent.Agent_Type__c);
				agentInfo.isVisible = agentInfo.agentMetadata.Enabled__c;
				if('CPlusPlusNative'.equals(agentInfo.licAgent.Agent_Type__c) && LicenseUtil.hasSpecialPrivileges()){
					agentInfo.isVisible = true; 
				}
				returnVal.add(agentInfo);
			}
		}
		return returnVal;
    }
    
    public static void calculateApplicationAnalytics(List<PortalDataType.LicenseAgentInfo> licAgentInfoList){
         License_Agent__c transAgent = null;
        License_Agent__c logAgent = null;
        License_Agent__c applicationAgent = null;
        decimal transCount = 0;
        decimal logCount = 0;
        decimal transMaxCount = 0;
        decimal logMaxCount = 0;
        for(PortalDataType.LicenseAgentInfo licAgent:licAgentInfoList){
            if(licAgent.licAgent.Agent_Type__c == 'ApplicationAnalytics'){
                applicationAgent = licAgent.licAgent;
            }else if(licAgent.licAgent.Agent_Type__c == 'Log'){
                logAgent = licAgent.licAgent;
                if(logAgent.Count__c!=null){
                  logCount = logAgent.Count__c;
                }
                if(logAgent.Max_Agents__c!=null){
                  logMaxCount = logAgent.Max_Agents__c;
                }
                 
            }else if(licAgent.licAgent.Agent_Type__c == 'Transaction'){
                transAgent = licAgent.licAgent;
                if(transAgent.Count__c!=null){
                  transCount = transAgent.Count__c;
                }
                if(transAgent.Max_Agents__c!=null){
                  transMaxCount = transAgent.Max_Agents__c;
                }
            }
        }
        applicationAgent.count__c = 2 * transCount + logCount;
        applicationAgent.Max_Agents__c = 2 * transMaxCount + logMaxCount;
        applicationAgent.Retention_Period__c = '7';
    }    

    /*
     * Helper method to retreive teh count of a given agent type in list of agent info objects
     */ 
    public static Integer getCount(String agentType,List<PortalDataType.LicenseAgentInfo> licAgentInfoList){
      //handling invalid inputs and ensuring to send 0 incase of invalid inputs rather than failing execution.
      if(licAgentInfoList!=null && agentType!=null){
        for(PortalDataType.LicenseAgentInfo licAgentInfo:licAgentInfoList){
          if(agentType.equals(licAgentInfo.licAgent.Agent_Type__c)){
            if(licAgentInfo.licAgent.Count__c!=null){
              //Count__c is a Number field which translates to a double value and hence doing convertion to integer
              //Handling boundary cases if there is a fraction value in count, so that parseInt shouldnot cause abnormal termination
              try{
                return Integer.valueOf(licAgentInfo.licAgent.Count__c);
              }catch(Exception e){
                //Log Error here
                //Incase of error default value of 0 is sent back
              }
            }
          }
        }
      }
      return 0;
    }
    
    /*
     * Get Contact objects for license. 
     */
    public static set<Contact> getLicContacts(LicenseDetail__c lic,Contact accContact){
    	List<License_Contacts__c> licContacts =[Select License__c,Contact__r.Id,Contact__r.Name,Contact__r.FirstName,Contact__r.LastName,Contact__r.Email,Contact__r.No_longer_at_Company__c,Contact__r.Needs_Email__c,Contact_Type__c,Need_Operations_Email__c,Need_Service_Email__c from License_Contacts__c where License__c=:lic.Id];
    	set<Contact> opportunityContacts = new set<Contact>();
    	for(License_Contacts__c licCon:licContacts){
			if(licCon.Contact__r.Id == accContact.Id){
				opportunityContacts.add(accContact);
			}
		}
		return opportunityContacts;
    }
    
    /*
     * Retrieves the contact roles for a given opportunity
     */
    //e,Contact.LMS_Portal_User_Contact__c, Contact.LMS_Cloned__c,(Select Docs__c,Download__c,ZenDesk__c,LMS__c,User_Portal_ID__c from Contact.Contact_Portal_User),
    private static List<OpportunityContactRole> getOpportunityContacts(Opportunity opp){
    	try{
    		return [Select Contact.ID,Contact.Email,IsPrimary from OpportunityContactRole where OpportunityID=:opp.Id];
    	}catch(Exception e){
    		return null;
    	}
    } 
    
    /* 
     * Retrieves all the contacts of account with contact_portal_user object as well
     */
    private static List<Contact> getAccountContacts(Account acc){
        try{
            //return [Select ID,Name,Email,FirstName,LastName,LMS_Portal_User_Contact__c, LMS_Cloned__c,(Select Docs__c,Download__c,ZenDesk__c,LMS__c,User_Portal_ID__c from Contact_Portal_User__r) from Contact where AccountId=:acc.Id];
            return Database.query('Select ID,Name,Email,FirstName,LastName,Registered_Fan_Club__c from Contact where AccountId=\''+acc.Id+'\'');
        }catch(Exception e){
            return null;
        }
    }
    
    /**
     * Get License Contacts. This serves following different scenarios:
     * - License Contacts associated with only License (This is for licenses without any opportunity association like Azure/Self-service
     * - License Contacts with contacts from Opportunity (this is for all licenses with an opportunity association and to retrieve contacts belonging to opportunity only
     * - License Contacts with contacts from Account (This is for all licenses with an opportunity association and to retrieve all contacts belonging to account)
     */
     //Contact__r.Name,Contact__r.FirstName,Contact__r.LastName,Contact__r.Email,Contact__r.No_longer_at_Company__c,Contact__r.LMS_Portal_User_Contact__c, Contact__r.LMS_Cloned__c,(Select Docs__c,Download__c,ZenDesk__c,LMS__c,User_Portal_ID__c from Contact__r.Contact_Portal_User1__r),
    public static List<ContactWrapper> getLicenceContacts(LicenseDetail__c lic,Opportunity opp,Account acc,Boolean viewMode){
    	List<ContactWrapper> ctWrapperList = new List<ContactWrapper>();
    	OpportunityContactRole oppPrimaryContact = null;
        list<License_Contacts__c> licContacts =[Select License__c,Contact__c,Contact__r.Id,Contact__r.Email,Contact_Type__c,Need_Operations_Email__c,Need_Service_Email__c from License_Contacts__c where License__c=:lic.Id];
        map<String,ContactWrapper> emailsAdded = new map<String,ContactWrapper>();
        for(License_Contacts__c licCt:licContacts){
        	ContactWrapper ctWrapper = emailsAdded.get(licCt.Contact__r.Email); 
        	if(ctWrapper==null){
        		ctWrapper = new ContactWrapper(licCt,licCt.contact__r,lic);
        		if('PRIMARY'.equals(ctWrapper.licContact.Contact_Type__c)){
        			ctWrapper.licContact.Need_Operations_Email__c=true;
					ctWrapper.licContact.Need_Service_Email__c=true;
        		}
        		if(ctWrapper.licContact.Need_Operations_Email__c || ctWrapper.licContact.Need_Service_Email__c){
        			ctWrapperList.add(ctWrapper);
        			emailsAdded.put(licCt.contact__r.Email,ctWrapper);
        		}
        	}
        }
        if(opp!=null){
    		list<OpportunityContactRole> oppCtRoles = getOpportunityContacts(opp);
    		for(OpportunityContactRole oppCtRole:oppCtRoles){
    			ContactWrapper ctWrapperAlreadyAdded = emailsAdded.get(oppCtRole.Contact.Email);
    			System.debug(LoggingLevel.INFO,'ALREADY ADDED CTEMAIL:'+oppCtRole.Contact.Email);
    			System.debug(LoggingLevel.INFO,'ALREADY ADDED CT:'+ctWrapperAlreadyAdded);
    			if(ctWrapperAlreadyAdded!=null){
    				//If already added and is not added as primary in lic ct but in opportunity its primary
    				if(oppCtRole.isPrimary){
    					oppPrimaryContact = oppCtRole;
    					if(!'PRIMARY'.equals(ctWrapperAlreadyAdded.licContact.Contact_Type__c)){
    						ctWrapperAlreadyAdded.licContact.Contact_Type__c = 'PRIMARY';
    						ctWrapperAlreadyAdded.licContact.Need_Operations_Email__c=true;
    						ctWrapperAlreadyAdded.licContact.Need_Service_Email__c=true;
    					}
    				}
    			}else{
    				License_Contacts__c licCt = new License_Contacts__c();
	    			licCt.license__r=lic;
	    			licCt.Contact__r = oppCtRole.contact;
	    			licCt.Contact__c = oppCtRole.contact.id;
	    			if(oppCtRole.isPrimary){
	    				oppPrimaryContact = oppCtRole;
	    				licCt.Contact_Type__c = 'PRIMARY';
	    				licCt.Need_Operations_Email__c=true;
	    				licCt.Need_Service_Email__c=true;
	    			}else{
	    				licCt.Contact_Type__c = 'ADDITIONAL';
	    			}
	    			ContactWrapper ctWrapper = new ContactWrapper(licCt,licCt.Contact__r,lic);
	    			ctWrapperList.add(ctWrapper);
	    			emailsAdded.put(oppCtRole.Contact.Email,ctWrapper);
    			}
    		}
    	}  
    	
    	if(acc!=null){
    		List<Contact> accContacts = getAccountContacts(acc);
    		for(Contact accCt:accContacts){
    			ContactWrapper ctWrapperAlreadyAdded = emailsAdded.get(accCt.Email);
    			if(ctWrapperAlreadyAdded==null){
    				License_Contacts__c licCt=new License_Contacts__c();
	    			licCt.license__r=lic;
	    			licCt.Contact__r=accCt;
	    			licCt.Contact__c = accCt.id;
	    			licCt.Contact_Type__c='ADDITIONAL';
	    			ContactWrapper ctWrapper=new ContactWrapper(licCt,licCt.Contact__r,lic);
	    			ctWrapperList.add(ctWrapper);
    			}
    		}
    	}

      	list<String> ctIDs = new list<String>();
      	map<String,ContactWrapper> ctWrapperMap = new map<String,ContactWrapper>();
		for(ContactWrapper ctWrapper:ctWrapperList){
    		Contact ctObj = ctWrapper.contactObj;
        	if(ctObj!=null){
	      		ctIDs.add(ctObj.Id);
	      		ctWrapper.contactObj = ctObj;
	      		ctWrapper.licContact.Contact__r = ctObj;
	      		if(oppPrimaryContact!=null && oppPrimaryContact.Contact.email!=ctObj.email){
	      			ctWrapper.licContact.Contact_Type__c = 'ADDITIONAL';
      			}
          		ctWrapperMap.put(ctObj.Id,ctWrapper);
        	}
    	}
    	
		list<Contact> ctObjList = Database.query('SELECT No_longer_at_Company__c,Email,Download__c,ZenDesk__c,Docs__c,LMS__c, LastName, Id, Name,'+
													'Account.RecordType.Name,Account.Name,Account.RecordType.Id, Account.Id,Account.OwnerId, FirstName, '+
													'LMS_Portal_User_Contact__c, Registered_Fan_Club__c, LMS_Cloned__c, (Select id, Contact__c,User_Portal_Id__c,Docs__c,Download__c,'+
													'ZenDesk__c,LMS__c ,ADUAUserDetails__c from Contact_Portal_User__r) FROM Contact WHERE ID IN: ctIds');
 
	  	if(ctObjList!=null){
		    for(Contact ctObj:ctObjList){
		      ContactWrapper ctWrapper =ctWrapperMap.get(ctObj.Id);
		      if(ctWrapper!=null){
		        ctWrapper.contactObj = ctObj;
		      }
		    }
	  	}
	  	return ctWrapperList;  
	}
    
    public static void updateLicenseContacts(List<ContactWrapper> licenseContacts,LicenseDetail__c licenseDetailObj){
    	try{
            List<License_Contacts__c> licCtsToDelete = [Select ID,Contact__c,License__c from License_Contacts__c where License__c=:licenseDetailObj.Id];
            delete licCtsToDelete;
      }catch(Exception e){
            License_Contacts__c licCtToDelete = [Select ID,Contact__c,License__c from License_Contacts__c where License__c=:licenseDetailObj.Id];
            delete licCtToDelete;
      }
        
    	List<License_Contacts__c> licCts = new List<License_Contacts__c>();
    	for(ContactWrapper ctWrapper:licenseContacts){
            if(ctWrapper.licContact.Need_Operations_Email__c || ctWrapper.licContact.Need_Service_Email__c){
                License_Contacts__c licCt = new License_Contacts__c();
                licCt.Contact__c = ctWrapper.contactObj.Id;
                licCt.License__c=licenseDetailObj.Id;
                licCt.Need_Operations_Email__c=ctWrapper.licContact.Need_Operations_Email__c;
                licCt.Need_Service_Email__c=ctWrapper.licContact.Need_Service_Email__c;
                licCt.Contact_Type__c=ctWrapper.licContact.Contact_Type__c;
                licCts.add(licCt);
            }
      }
      upsert licCts;  
    }
    
    public static List<ContactWrapper> getDBContacts(DBTuna_License__c lic,Opportunity opp,Account acc,Boolean viewMode){
		System.debug( 'Entered getDBContacts' );
       	List<ContactWrapper> ctWrapperList = new List<ContactWrapper>();
    	OpportunityContactRole oppPrimaryContact = null;
    	list<DBLicense_Contacts__c> licContacts =[Select DBLicense__c,Contact__c,Contact_Type__c, Contact__r.Id,Contact__r.Name,Contact__r.FirstName,Contact__r.LastName,Contact__r.Email,Contact__r.Needs_Email__c from DBLicense_Contacts__c where DBLicense__c=:lic.Id];
    	
        map<String,ContactWrapper> emailsAdded = new map<String,ContactWrapper>();
        for(DBLicense_Contacts__c licCt:licContacts){
        	ContactWrapper ctWrapper = emailsAdded.get(licCt.Contact__r.Email);
        	System.debug('Needs email: ' + licCt.Contact__r.Email + ' ');
        	//ContactWrapper ctWrapper = null; 
			//licCt.Contact__r.Needs_Email__c = false;
        	if(ctWrapper==null){
        		ctWrapper = new ContactWrapper(licCt.Contact__r, lic);
        		ctWrapper.dbLicContact = licCt;
        		//licCt.Contact__r.Needs_Email__c = false;
        	}
        	System.debug('Needs email: ' + licCt.Contact__r.Email + ' ' + ctWrapper.contactObj.Needs_Email__c);
        	
        }
		
		System.debug( 'Checking null opp' );
        if(opp!=null){
    		list<OpportunityContactRole> oppCtRoles = getOpportunityContacts(opp);
    		for(OpportunityContactRole oppCtRole:oppCtRoles){
    			ContactWrapper ctWrapperAlreadyAdded = emailsAdded.get(oppCtRole.Contact.Email);
    			System.debug(LoggingLevel.INFO,'ALREADY ADDED CTEMAIL:'+oppCtRole.Contact.Email);
    			System.debug(LoggingLevel.INFO,'ALREADY ADDED CT:'+ctWrapperAlreadyAdded);
    			if(ctWrapperAlreadyAdded!=null){
    				//If already added and is not added as primary in lic ct but in opportunity its primary
    				if(oppCtRole.isPrimary){
    					oppPrimaryContact = oppCtRole;
    					if(!'PRIMARY'.equals(ctWrapperAlreadyAdded.licContact.Contact_Type__c)){
    						ctWrapperAlreadyAdded.licContact.Contact_Type__c = 'PRIMARY';
    						//ctWrapperAlreadyAdded.licContact.Need_Operations_Email__c=true;
    						//ctWrapperAlreadyAdded.licContact.Need_Service_Email__c=true;
    					}
    				}
    			}else{
    				DBLicense_Contacts__c licCt = new DBLicense_Contacts__c();
	    			//licCt.license__r=lic;
	    			licCt.Contact__r = oppCtRole.contact;
	    			licCt.Contact__c = oppCtRole.contact.id;
	    			if(oppCtRole.isPrimary){
	    				oppPrimaryContact = oppCtRole;
	    				licCt.Contact_Type__c = 'PRIMARY';
						licCt.Contact__r.Needs_Email__c = true;
	    				//licCt.Need_Operations_Email__c=true;
	    				//licCt.Need_Service_Email__c=true;
	    			}else{
	    				licCt.Contact_Type__c = 'ADDITIONAL';
						licCt.Contact__r.Needs_Email__c = false;
	    			}
	    			ContactWrapper ctWrapper = new ContactWrapper(licCt.Contact__r, lic);
	    			ctWrapper.dbLicContact = licCt;
	    			ctWrapperList.add(ctWrapper);
	    			emailsAdded.put(oppCtRole.Contact.Email,ctWrapper);
    			}
    		}
    	}  
    	
      	list<String> ctIDs = new list<String>();
      	map<String,ContactWrapper> ctWrapperMap = new map<String,ContactWrapper>();
		for(ContactWrapper ctWrapper:ctWrapperList){
    		Contact ctObj = ctWrapper.contactObj;
        	if(ctObj!=null){
	      		ctIDs.add(ctObj.Id);
	      		ctWrapper.contactObj = ctObj;
	      		ctWrapper.dbLicContact.Contact__r = ctObj;
	      		if(oppPrimaryContact!=null && oppPrimaryContact.Contact.email!=ctObj.email){
	      			ctWrapper.dbLicContact.Contact_Type__c = 'ADDITIONAL';
      			}
          		ctWrapperMap.put(ctObj.Id,ctWrapper);
        	}
    	}
    	
		list<Contact> ctObjList = Database.query('SELECT No_longer_at_Company__c,Email,Needs_Email__c,Download__c,ZenDesk__c,Docs__c,LMS__c, LastName, Id, Name,'+
													'Account.RecordType.Name,Account.Name,Account.RecordType.Id, Account.Id,Account.OwnerId, FirstName, '+
													'LMS_Portal_User_Contact__c, LMS_Cloned__c, (Select id, Contact__c,User_Portal_Id__c,Docs__c,Download__c,'+
													'ZenDesk__c,LMS__c ,ADUAUserDetails__c from Contact_Portal_User__r) FROM Contact WHERE ID IN: ctIds');
 
	  	if(ctObjList!=null){
		    for(Contact ctObj:ctObjList){
		      ContactWrapper ctWrapper =ctWrapperMap.get(ctObj.Id);
		      if(ctWrapper!=null){
		      	if(licContacts == null || licContacts.isEmpty()) {
					if(ctWrapper.dbLicContact.Contact_Type__c == 'PRIMARY') {
						ctObj.Needs_Email__c = true;
					}
					else {
						ctObj.Needs_Email__c = false;
					}
		      	}
		      	else {
		      		try {
				    	DBLicense_Contacts__c licC =[Select DBLicense__c,Contact__c,Contact_Type__c, Contact__r.Id,Contact__r.Name,Contact__r.FirstName,Contact__r.LastName,Contact__r.Email,Contact__r.Needs_Email__c from DBLicense_Contacts__c where DBLicense__c=:lic.Id and Contact__r.Id = :ctObj.Id];
				    	ctObj.Needs_Email__c = licC.Contact__r.Needs_Email__c;
		      		}
		      		catch(Exception e) {
		      			System.debug('Exception thrown ' + e.getMessage());
		      			ctObj.Needs_Email__c = false;
		      		}
		      	}
				
				ctWrapper.contactObj = ctObj;
				System.debug(LoggingLevel.Info,'7 Contact type:'+ctWrapper.dbLicContact.Contact_Type__c);
		      }
		    }
	  	}
	  	//ctWrapperList.sort();
		System.debug( 'Exiting getDBContacts' );
	  	return ctWrapperList;  
    }
    
    /*
     * Copy License contacts from lic1 to lic2. This is used during HA License flows
     */
    public static void copyLicenseContacts(LicenseDetail__c lic1,LicenseDetail__c lic2){
        List<License_Contacts__c> licContacts = [Select License__c,Contact__c,Contact_Type__c,Need_Operations_Email__c,Need_Service_Email__c from License_Contacts__c where License__c=:lic1.Id];
        List<License_Contacts__c> licContacts2 = new List<License_Contacts__c>();
        for(License_Contacts__c licContact:licContacts){
            License_Contacts__c licContact2 = new License_Contacts__c();
            licContact2.License__c = lic2.Id;
            licContact2.Contact__c = licContact.Contact__c;
            licContact2.Contact_Type__c = licContact.Contact_Type__c;
            licContact2.Need_Operations_Email__c = licContact.Need_Operations_Email__c;
    		licContact2.Need_Service_Email__c = licContact.Need_Service_Email__c;
            licContacts2.add(licContact2);
        }
        upsert licContacts2;
    }
    
    /*
     * Saves License old and new state details in License History objects.
     */
    public static void saveHistory(SObject oldObjectState, Map<String,List<SObject>> oldStateRelationalObjectMap,String status,Boolean deltaValues){
    	try{
    		/*
    		 * Gets SObject name.  
    		 */
	    	String objectName = oldObjectState.getSObjectType().getDescribe().getName();
	    	
	    	SObject newObjectState = DataLayerConstants.fetchSingle(objectName, oldObjectState.id);
	    	
	    	Map<String,List<SObject>> newStateRelationalObjectMap = getRelationalRecordsMap(newObjectState);
	    	
	    	/*
	    	 * Creates  License_History_Tracking__c record with stage and user details.
	    	 */
	    	License_History_Tracking__c lth = new License_History_Tracking__c(License__c=oldObjectState.id,License_Operation__c=newObjectState.get('Stage__c')+'',User__c=UserInfo.getUserId(),Status__c=status,DateTime__c=System.now());
		    insert lth;
		    
		    List<License_History_Property__c> licenseHistoryProperties = new List<License_History_Property__c>();
	    	
	    	/*
	    	 * Gets list of fields from HistoryMap class for a given object
	    	 */
	    	List<String> fieldNames = HistoryMap.objectAndFieldsMap.get(objectName);
	    	
	    	licenseHistoryProperties.addAll(createLicenseHistoryPropertyInstanceList(newObjectState,oldObjectState,fieldNames,lth,deltaValues));
	    	
	    	/*
	    	 * Gets list of relational objects for a given parent object
	    	 */ 
	    	List<String> relationalObjectNames = HistoryMap.relatedObjectsMap.get(objectName);
	    	
	    	/*
	    	 * Camparing new and old values from relational objects 
	    	 * and inserting into License History Property object.
	    	 */
	    	if(relationalObjectNames!=null && relationalObjectNames.size()>0){
		    	for(String relationalObjectName: relationalObjectNames){
					Map<String,SObject> oldRelaMap = new Map<String,SObject>();
		    		Map<String,SObject> newRelaMap = new Map<String,SObject>();
		    		
		    		if(oldStateRelationalObjectMap.get(relationalObjectName)!=null){
		    			for(SObject sobj: oldStateRelationalObjectMap.get(relationalObjectName)){
		    				oldRelaMap.put(sobj.get('id')+'',sobj);
		    			}
		    		}
		    		
		    		if(newStateRelationalObjectMap.get(relationalObjectName)!=null){
		    			for(SObject sobj: newStateRelationalObjectMap.get(relationalObjectName)){
		    				newRelaMap.put(sobj.get('id')+'',sobj);
		    			}
		    		}
		    		
		    		if(newRelaMap.size()>0){
		    			for(SObject newSobj: newRelaMap.values()){
		    				String objName = newSobj.getSObjectType().getDescribe().getName();
		    				List<String> relationalFieldNames = HistoryMap.objectAndFieldsMap.get(objName);
		    				if(oldRelaMap.size()>0 && oldRelaMap.keySet().contains(newSobj.get('id')+'')){
		    					for(SObject oldSobj: oldRelaMap.values()){
		    						if(newSobj.get('id') == oldSobj.get('id')){
	    								licenseHistoryProperties.addAll(createLicenseHistoryPropertyInstanceList(newSobj,oldSobj,relationalFieldNames,lth,deltaValues));
		    						}
		    					}
		    				} else {
		    					licenseHistoryProperties.addAll(createLicenseHistoryPropertyInstanceList(newSobj,null,relationalFieldNames,lth,deltaValues));
		    				}
		    			}
		    		}
		    	}	
	    	}
	    	
	    	/*
	    	 * Inserting the history details into License History Property object.
	    	 */
	    	if(licenseHistoryProperties.size()>0){
	    		insert licenseHistoryProperties;
	    	}
	    	
    	}catch(Exception e){
    		EmailUtil.notifyError(e, null);
    	}
    }
    
    /*
     * Creates list of License_History_Property__c instance for each field in Sobject.
     */
    public static List<License_History_Property__c> createLicenseHistoryPropertyInstanceList(SObject newObjectState,SObject oldObjectState,List<String> fieldNames,License_History_Tracking__c lth,Boolean deltaValues){
    	List<License_History_Property__c> licenseHistoryProperties = new List<License_History_Property__c>();
    	String objectName = newObjectState.getSObjectType().getDescribe().getName();
    	for(String fieldName: fieldNames){
    		String newValue = (newObjectState!=null && newObjectState.get(fieldName)!=null)?newObjectState.get(fieldName)+'':'';
    		String oldValue = (oldObjectState!=null && oldObjectState.get(fieldName)!=null)?oldObjectState.get(fieldName)+'':'';
    		if(deltaValues){
    			if(!newValue.equals(oldValue)){
	    			licenseHistoryProperties.add(getLicenseHistoryPropertyInstance(lth, newValue, oldValue, fieldName, objectName));
    			}
    		} else {
    			licenseHistoryProperties.add(getLicenseHistoryPropertyInstance(lth, newValue, oldValue, fieldName, objectName));
    		}
    	}
    	return licenseHistoryProperties;
    }
    
    /*
		 * Create the instance of License_History_Property__c object and return it.     
     */
    public static License_History_Property__c getLicenseHistoryPropertyInstance(License_History_Tracking__c lth, String newValue, String oldValue, String fieldName, String objectName){
    	License_History_Property__c lhp = new License_History_Property__c();
    	lhp.License_History_Tracking__c = lth.id;
    	lhp.New_Value__c = newValue;
    	lhp.Old_Value__c = oldValue;
    	lhp.Property_Field_Name__c = fieldName;
    	lhp.Property_Object_Name__c = objectName;
    	return lhp;
    }
    
    /*
     * Updating the license history records with status(Success/Fail).
     * Reverting back the license values if the status is Failed.
     */
    public static void updateLicenseHistory(LicenseDetail__c license,LicenseDetail__c oldLicenseState, String state){
    	License_History_Tracking__c lht = [select id, License__c, License_Operation__c, User__c, Status__c,(select id, New_Value__c, Old_Value__c, Property_Field_Name__c, Property_Object_Name__c from License_History_Property__r) from License_History_Tracking__c where License__c=:license.id and Status__c='IN_PROGRESS' ORDER BY CreatedDate DESC limit 1];
    	lht.License_Operation__c = license.Stage__c;
    	List<License_History_Property__c> licenseHistoryProperties = new List<License_History_Property__c>();
    	if('SUCCESS'.equals(state)){
    		
    		/*
    		 * In the first transaction the License_History_Property__c will contains License_BackendID__c and Stage__c details
    		 * so, updating  the values.
    		 */
			for(License_History_Property__c lhp: lht.License_History_Property__r){
 				if(lhp.Property_Field_Name__c.equals('License_BackendID__c')){
 					lhp.New_Value__c = license.License_BackendID__c;
 					licenseHistoryProperties.add(lhp);
 				}
 				
 				if(lhp.Property_Field_Name__c.equals('Stage__c')){
 					lhp.New_Value__c = license.Stage__c;
 					licenseHistoryProperties.add(lhp);
 				}
 				
 			}
 			
 			/*
    		* If the the license deployment-option or stage is changed from then, we are inserting the changed details here. 
    		*/
 			if(licenseHistoryProperties.size()==0){
	 			if(!license.License_BackendID__c.equals(oldLicenseState.License_BackendID__c)){
	 				licenseHistoryProperties.add(getLicenseHistoryPropertyInstance(lht, license.License_BackendID__c, oldLicenseState.License_BackendID__c, 'License_BackendID__c', 'LicenseDetail__c'));
	 			}
	 			if(!license.Stage__c.equals(oldLicenseState.Stage__c)){
	 				licenseHistoryProperties.add(getLicenseHistoryPropertyInstance(lht, license.Stage__c, oldLicenseState.Stage__c, 'Stage__c', 'LicenseDetail__c'));
	 			}
 			}
 			
    	   lht.Status__c = 'SUCCESS';
    	} else if('Failed'.equals(state)){
    		lht.Status__c = 'Failed';
    		license = (LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c', license.id);
    		Map<String,String> licenseHistoryMap = new Map<String,String>();
    		for(License_History_Property__c lhp: lht.License_History_Property__r){
    			licenseHistoryMap.put(lhp.Property_Field_Name__c,lhp.Old_Value__c);
    		}
    		
    		Set<String> licenseHistoryKeySet = licenseHistoryMap.keySet();
    		
    		if(licenseHistoryKeySet.contains('License_Expiry_Date__c')){
    			license.License_Expiry_Date__c = Date.valueof(licenseHistoryMap.get('License_Expiry_Date__c'));
    		}
    		
    		if(licenseHistoryKeySet.contains('Stage__c')){
    			license.Stage__c = licenseHistoryMap.get('Stage__c');
    		}
    		
    		if(licenseHistoryKeySet.contains('Product_Type__c')){
    			license.Stage__c = licenseHistoryMap.get('Product_Type__c');
    		}
    		
    		if(licenseHistoryKeySet.contains('Custom_URL_Name__c')){
    			license.Custom_URL_Name__c = licenseHistoryMap.get('Custom_URL_Name__c');
    		}
    		
    		if(licenseHistoryKeySet.contains('MAC_Address__c')){
    			license.MAC_Address__c = licenseHistoryMap.get('MAC_Address__c');
    		}

    		if(license.License_Agents__r.size()>0){
    			List<License_Agent__c> licenseAgents = new List<License_Agent__c>(); 
	    		for(License_Agent__c licenseAgent: license.License_Agents__r){
	    			License_Agent__c la = licenseAgent;
	    			if(la.Agent_Type__c.equals('Java') && licenseHistoryKeySet.contains('Java_Agents_Rollup__c')){
	    				la.Count__c = Integer.valueOf(licenseHistoryMap.get('Java_Agents_Rollup__c'));
	    			} 
	    			else if(la.Agent_Type__c.equals('.NET') && licenseHistoryKeySet.contains('Net_Agents_Rollup__c')){
	    				la.Count__c = Integer.valueOf(licenseHistoryMap.get('Net_Agents_Rollup__c'));
	    			}
	    			else if(la.Agent_Type__c.equals('PHP') && licenseHistoryKeySet.contains('PHP_Agents_Rollup__c')){
	    				la.Count__c = Integer.valueOf(licenseHistoryMap.get('PHP_Agents_Rollup__c'));
	    			}
	    			else if(la.Agent_Type__c.equals('Machine') && licenseHistoryKeySet.contains('Machine_Agents_Rollup__c')){
	    				la.Count__c = Integer.valueOf(licenseHistoryMap.get('Machine_Agents_Rollup__c'));
	    			}
	    			else if(la.Agent_Type__c.equals('Database') && licenseHistoryKeySet.contains('Database_Agents_Rollup__c')){
	    				la.Count__c = Integer.valueOf(licenseHistoryMap.get('Database_Agents_Rollup__c'));
	    			}
	    			else if(la.Agent_Type__c.equals('NodeJs') && licenseHistoryKeySet.contains('NodeJs_Agents_Rollup__c')){
	    				la.Count__c = Integer.valueOf(licenseHistoryMap.get('NodeJs_Agents_Rollup__c'));
	    			}
	    			licenseAgents.add(la);
	    		}
	    		if(licenseAgents.size()>0){
	    			upsert licenseAgents;
	    		}
    		}
    		
    		if(license.License_EUM_Details__r.size()>0){
    			List<License_EUM_Details__c> licenseEUM_Details = new List<License_EUM_Details__c>(); 
    			for(License_EUM_Details__c led: license.License_EUM_Details__r){
    				//if(led.Type__c!=null)
    				{
    					led.Type__c = licenseHistoryMap.get('Type__c')!=null?licenseHistoryMap.get('Type__c'):'';
    					led.Access_Key__c = licenseHistoryMap.get('Access_Key__c')!=null?licenseHistoryMap.get('Access_Key__c'):'';
    					led.AccountName__c = licenseHistoryMap.get('AccountName__c')!=null?licenseHistoryMap.get('AccountName__c'):'';
    					led.Agent_Units__c = licenseHistoryMap.get('Agent_Units__c')!=null?Integer.valueOf(licenseHistoryMap.get('Agent_Units__c')):0;
    					led.Allow_Overages__c = licenseHistoryMap.get('Allow_Overages__c')!=null?Boolean.valueOf(licenseHistoryMap.get('Allow_Overages__c')):false;
    					led.Import_EUM__c = licenseHistoryMap.get('Import_EUM__c')!=null?Boolean.valueOf(licenseHistoryMap.get('Import_EUM__c')):false;
    					led.RUM_Enabled__c = licenseHistoryMap.get('RUM_Enabled__c')!=null?Boolean.valueOf(licenseHistoryMap.get('RUM_Enabled__c')):false;
    					licenseEUM_Details.add(led);
    				}
    			}
    			if(licenseEUM_Details.size()>0){
    				upsert licenseEUM_Details;
    			}
    		}
    		 
    	}
    	update lht;
    	update license;
    	
    	/*
    		Update/Insert license property details for LicenseBackendId and Stage.
    	*/
    	if(licenseHistoryProperties.size()>0){
	    	try{
				upsert licenseHistoryProperties;
	 		}catch(Exception e){
				EmailUtil.notifyError(e, null);
	 		}
    	}
    }
    
    public static list<License_Contacts__c> getContactLicenses(Account acc){
    	try{
	    	list<License_Contacts__c> licCts = [Select Contact__r.Id,Contact__r.Name,Contact__r.Email,
	    											Contact_Type__c,
                            License__r.Id,License__r.Custom_URL_Name__c,License__r.Product_Type__c,
	    											License__r.MAC_Address__c,License__r.License_Expiry_Date__c, License__r.ProcessState__c,
                            License__r.Java_Agents_Rollup__c,License__r.Net_Agents_Rollup__c,License__r.PHP_Agents_Rollup__c,
	    											License__r.Stage__c from License_Contacts__c where Contact__r.AccountId=:acc.Id];
			return licCts;
    	}catch(Exception e){
    		EmailUtil.notifyError(e,acc);
    		return null;
    	}
    }
    
    public static list<License_Opportunity__c> getOpportunityLicenses(Account acc){
    	try{
    		list<License_Opportunity__c> licCts = [Select Opportunity__r.Id,Opportunity__r.Name,
    											License__r.Id,License__r.Custom_URL_Name__c,License__r.Product_Type__c,
    											License__r.MAC_Address__c,License__r.License_Expiry_Date__c,License__r.ProcessState__c,
                          License__r.Java_Agents_Rollup__c,License__r.Net_Agents_Rollup__c,License__r.PHP_Agents_Rollup__c,
    											License__r.Stage__c from License_Opportunity__c where Opportunity__r.AccountId=:acc.Id];
			return licCts;
    	}catch(Exception e){
    		EmailUtil.notifyError(e,acc);
    		return null;
    	}
    }
    
    /*
    	Initializing LicenseEUMInput instance which contains EUM web and mobile details.
    */
    public static LicenseEUMInput getEUMLicenseInput(License_EUM_Details__c licenseEUMDetails){
    	LicenseEUMInput eumInput = null;
    	EUM_Mobile__c eumMobile = null;
        EUM_Web__c eumWeb = null;
		if(licenseEUMDetails==null){
			licenseEUMDetails = new License_EUM_Details__c();
        	eumMobile = new EUM_Mobile__c();
        	eumWeb = new EUM_Web__c();
        } else {
        	if(licenseEUMDetails.EUM_Mobile__r.size()==0){
        		eumMobile = new EUM_Mobile__c();
        	} else {
        		eumMobile = licenseEUMDetails.EUM_Mobile__r[0];
        	}
        		
        	if(licenseEUMDetails.EUM_Web__r.size()==0){
        		eumWeb = new EUM_Web__c();
        	} else {
        		eumWeb = licenseEUMDetails.EUM_Web__r[0];
        	}
		}
		eumInput = new LicenseEUMInput(licenseEUMDetails, eumWeb, eumMobile);
		return eumInput;
    }
    
    /*
		 * Code for fetching first and second level relational object records. 
	   */
    public static Map<String,List<SObject>> getRelationalRecordsMap(SObject licenseState){
    	String objectName = licenseState.getSObjectType().getDescribe().getName();
    	Map<String,List<SObject>> relationalLicenseHistoryMap = new Map<String,List<SObject>>();
    	List<String> relationalNames = HistoryMap.relatedObjectsMap.get(objectName);
    	for(String relName: relationalNames){ 
    		
    		if(!relName.contains('.')){
				relationalLicenseHistoryMap.put(relName,licenseState.getSObjects(relName));	
    		} else {
    			String[] subRelationalNames = relName.split('\\.');
    			
    			/*
    				Code for fetching first and second level relational object records. 
    			*/
    			List<SObject> rel = licenseState.getSObjects(subRelationalNames[0]);
    			if(rel!=null && rel.size()>0){
    				SObject sobj = rel.get(0);
    				String relObjectName = sobj.getSObjectType().getDescribe().getName();
    				List<SObject> sobjList = DataLayerConstants.fetchMultiple(relObjectName, ' Where id = \''+sobj.get('id')+'\' limit 1');
    				if(sobjList.size()>0){
    					relationalLicenseHistoryMap.put(relName,sobjList.get(0).getSObjects(subRelationalNames[1]));
    				}else{
    					relationalLicenseHistoryMap.put(relName,null);
    				}
    			}else{
    				relationalLicenseHistoryMap.put(relName,null);
    			}
    		}
    	}
    	return relationalLicenseHistoryMap;
    }

	
	public static LicenseBackend getLicenseBackend(Integer lastOpCode, LicenseDetail__c licenseDetailObj, 
														Opportunity myOpportunity, Account accObj, 
														list<PortalDataType.LicenseAgentInfo> licAgentInfoList,
														 List<ContactWrapper> licenseContacts,
														 LicenseEUMInput eumInput){
		LicenseBackend backendObj = new LicenseBackend(licenseDetailObj,myOpportunity,accObj,
                      licAgentInfoList,licenseContacts,eumInput,lastOpCode);
        return backendObj;
	}
	
	public static String setDataRetentionDefaults(LicenseDetail__c lic, License_Agent__c licAgent){
		if('Log'.equals(licAgent.Agent_Type__c)) {
				if(lic.Product_Type__c == null || lic.Product_Type__c.equals('On-Premise')) {
					return EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.ANALYTICS_LOG_ON_PREM_DEFAULT_DATA_RETENTION);
				}
				else {
					return EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.ANALYTICS_LOG_SAAS_DEFAULT_DATA_RETENTION);
				}
			}
		if('Transaction'.equals(licAgent.Agent_Type__c)) {
			if(lic.Product_Type__c == null || lic.Product_Type__c.equals('On-Premise')) {
				return EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.ANALYTICS_TXN_ON_PREM_DEFAULT_DATA_RETENTION);
			}
			else {
				return EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.ANALYTICS_TXN_SAAS_DEFAULT_DATA_RETENTION);
			}
		}
		
		if('BrowserAnalytics'.equals(licAgent.Agent_Type__c)) {
			if(lic.Product_Type__c == null || lic.Product_Type__c.equals('On-Premise')) {
				return EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.BROWSER_ANALYTICS_ON_PREM_DEFAULT_DATA_RETENTION);
			}
			else {
				return EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.BROWSER_ANALYTICS_SAAS_DEFAULT_DATA_RETENTION);
			}
		}
		
		if('MobileAnalytics'.equals(licAgent.Agent_Type__c)) {
			if(lic.Product_Type__c == null || lic.Product_Type__c.equals('On-Premise')) {
				return EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.MOBILE_ANALYTICS_ON_PREM_DEFAULT_DATA_RETENTION);
			}
			else {
				return EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.MOBILE_ANALYTICS_SAAS_DEFAULT_DATA_RETENTION);
			}
		}
        
		return '';
	}

  public static Boolean isOnPremise(LicenseDetail__c lic){
    return lic == null || lic.Product_Type__c == null || lic.Product_Type__c.equals('On-Premise');
  }
  
  
  public static Boolean isTrial(LicenseDetail__c lic, Integer opcode){
      if (opcode==BackendConstants.OPCODE_ADD_LICENSE || opcode==BackendConstants.OPCODE_TRANSITION_TO_PERMANENT){
        return false;
      }else{
        return lic == null || lic.Stage__c == null || lic.Stage__c.contains('TRIAL') || lic.Stage__c.contains('LITE');  
      }
  }
	

  private static testMethod void testApplicationAnalytics(){
       LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
        list<PortalDataType.LicenseAgentInfo> licenseAgentInfoList = getLicenseAgentInfoList(lic, BackendConstants.OPCODE_PROVISION_FREE_TRIAL);
        calculateApplicationAnalytics(licenseAgentInfoList);
        PortalDataType.LicenseAgentInfo appAgent;
        for(PortalDataType.LicenseAgentInfo licAgent:licenseAgentInfoList){
            if(licAgent.licAgent.Agent_Type__c == 'ApplicationAnalytics'){
                appAgent = licAgent;
            }
        }
        if(appAgent != null) {
            System.assert(appAgent.licAgent.count__c != null);
        }
  }


    public static testMethod void testLicenseUtil(){
      isOperationSupport(null,BackendConstants.OPCODE_EXTEND_TRIAL);
      hasSpecialPrivileges();
      System.assert(true);
    }
    
    private static testMethod void testCreateEUMLicense(){
     	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
        License_EUM_Details__c eumDetails = new License_EUM_Details__c();
        eumDetails.RUM_Enabled__c = true;
        eumDetails.AccountName__c = 'testTarams';
        eumDetails.Access_Key__c = 'testTarams';
        eumDetails.Import_EUM__c = false;
        eumDetails.License__c = lic.Id;
        insert eumDetails;
        EUM_Web__c eumWeb = new EUM_Web__c();
     	eumWeb.License_EUM_Detail__c = eumDetails.Id;
     	eumWeb.Type__c = 'LITE';
     	eumWeb.Allow_overages__c = false;
     	eumWeb.Units__c = 1;
     	insert eumWeb;
     	EUM_Mobile__c eumMobile = new EUM_Mobile__c();
     	eumMobile.License_EUM_Detail__c = eumDetails.Id;
     	eumMobile.Type__c = 'LITE';
     	eumMobile.Allow_overages__c = false;
     	eumMobile.Units__c = 1;
     	insert eumMobile;
     	LicenseEUMInput input = new LicenseEUMInput(eumDetails,eumWeb,eumMobile);
     	createEUMLicense(input,lic);
     }
     
     private static testMethod void testGetAgentCount(){
     	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
        list<PortalDataType.LicenseAgentInfo> licenseAgentInfoList = getLicenseAgentInfoList(lic, BackendConstants.OPCODE_PROVISION_FREE_TRIAL);
        getCount('Java', licenseAgentInfoList);
     }
}