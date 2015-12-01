global class ZendeskBackend {
  
 /* public static boolean checkIf_Partner_Contacts_Changed(Account account, Account_Zendesk__c az, List<Contact> partnerContacts){
  	List<Zendesk_Contact__c> zendeskContacts = [Select Id, Contact_Id__c, Zendesk_User_Id__c from Zendesk_Contact__c where Account_Zendesk__c=:az.id];
  	Set<String> oldContactIds = new Set<String>();
  	Set<String> newContactIds = new Set<String>();
  	Boolean isModified = false;
  	
  	if(partnerContacts!=null){
  		for(Contact con: partnerContacts){
  			newContactIds.add(con.id);
  		}
  	}
  	
  	if(zendeskContacts!=null){
  		for(Zendesk_Contact__c zc: zendeskContacts){
			oldContactIds.add(zc.Contact_Id__c);
		}
  		
  		for(String conId:newContactIds){
  			if(oldContactIds.contains(conId)){
  				isModified = false;
  			}else{
  				isModified = true;
  				break;
  			}  			
  		}
  		System.debug('isModified1'+isModified);
  		if(isModified == false){
  			for(String conId:oldContactIds){
  				if(newContactIds.contains(conId)){
  					isModified = false;
  				}else{
  					isModified = true;
  					break;
  				}  			
  			}
  		}
  		System.debug('isModified2'+isModified);
  		
  	}
  		return isModified;
  }
  
  public static boolean checkIf_ACE_TAM_Changed(Account account, Account_Zendesk__c az){
    if((account.ACE_Architect__c!=az.ACE_Architect__c || account.Technical_Account_Manager__c != az.TAM__c || account.Owner.Id != az.SE__c)){
        return true;
    } else{
        return false;
    }
  }
  
  public static boolean checkIf_ACE_TAM_NULL(Account account){
    if(account.ACE_Architect__c == null && account.Technical_Account_Manager__c == null){
        return true;
    }else{
        return false;
    }   
  }
  
  public static void checkTriggerDetails(Account account){
        Account_Zendesk__c az = new Account_Zendesk__c();
        List<Contact> partnerContacts;
        String zendeskOperationType;
        Integer accountPortalId; 
        String organizationId; 
        Account_Portal_Company__c accountPortalCompany = null;
        
        Map<Integer,String> partnerContactsMap = new Map<Integer,String>(); 
         
        account = [select Id, Name , Owner.Id, Owner.Email, ACE_Architect__c, ACE_Architect__r.Email, CreatedBy.Email, CreatedById, Technical_Account_Manager__c, Technical_Account_Manager__r.Email,Owner.contactId, Owner.contact.accountId, PortalID__c,(Select Id, Account__c,ALookup__c, Company_Portal_Id__c from Portal_Company__r) from Account where id =:account.id];
        
        List<Account_Zendesk__c> zendeskAccounts = [select Id, Organisation_Id__c, Trigger_Id__c, OP_CODE__c, Description__c, Status__c, Account__c, ACE_Architect__c, TAM__c, SE__c from Account_Zendesk__c where Account__c =: account.id];
        
        if(zendeskAccounts != null && zendeskAccounts.size() > 0){
            az = zendeskAccounts.get(0);
        } 
        System.debug('zendeskAccounts'+zendeskAccounts);
        System.debug('az:status__c'+az.status__c);
        System.debug('account portal id'+account.PortalID__c);
        
        
        if(account.Portal_Company__r!=null && account.Portal_Company__r.size()>0){
        	accountPortalCompany = account.Portal_Company__r.get(0);
        }
            
        if(accountPortalCompany==null || accountPortalCompany.Company_Portal_Id__c==null){
        	System.debug('null');
        	az.Status__c = 'FAILED';
        	az.Description__c = 'Account portal id is null';
        	az.Account__c = account.id;
        	upsert az;
        	System.debug('az'+az);
        } else{
        	
        	try{
        		accountPortalId = integer.ValueOf(accountPortalCompany.Company_Portal_Id__c);
        	}catch(Exception e){
        		
        	}
        	
	        if(account.Owner.contactId!=null){
	        	try{
					partnerContacts = [select Id,Email,PortalID__c,(Select id, CLookup__c,Contact__c,User_Portal_Id__c from Portal_User__r) from Contact where AccountId =:account.Owner.contact.accountId and Partner_Contact_Roles__c in ('Sales Engineer','Support Engineer')];
					System.debug('partnerContacts'+partnerContacts);
					if(partnerContacts!=null && partnerContacts.size()>0){
						for(Contact con: partnerContacts){
	        				if(con.Portal_User__r!=null && con.Portal_User__r.size()>0){
	        					Contact_Portal_User__c contactPortalUser = con.Portal_User__r.get(0);
	        					if(contactPortalUser.User_Portal_Id__c!=null && !contactPortalUser.User_Portal_Id__c.equals('null') && !contactPortalUser.User_Portal_Id__c.equals('')){
									partnerContactsMap.put(integer.ValueOf(contactPortalUser.User_Portal_Id__c),con.Id);
	        					}
	        				}
						}
					}
	        	}catch(Exception e){
	        		
	        	}
			}
	        
	        if(az.status__c == null || az.status__c.equals('FAILED')){
	            if(az.Trigger_Id__c == null){
	                zendeskOperationType = 'CREATE';
	            }
	            else{
	                zendeskOperationType = 'UPDATE';
	            }
	        } else if(az.status__c.equals('SUCCESS') || RESTAPI.unitTestMode){
	            
	            if(RESTAPI.unitTestMode){
	            	organizationId = '1234';
	            }else{
	            	organizationId = az.Organisation_Id__c;
	            }
	            
	            System.debug('organizationId==='+organizationId);
	            try{
		            if(checkIf_ACE_TAM_Changed(account,az)){
		                zendeskOperationType = 'UPDATE';
		            }
	            }catch(Exception e){
	            	
	            }
	            
	            if(partnerContacts!=null){
	            	try{
		            	if(checkIf_Partner_Contacts_Changed(account,az,partnerContacts)){
		            		zendeskOperationType = 'UPDATE';
		            	}
		            }catch(Exception e){
	            	
	            	}
	            }
	            
	            /*if(account.ACE_Architect__c == null && account.Technical_Account_Manager__c == null && account.CreatedById == null){
	                zendeskOperationType = 'DELETE';
	            }*/
	            
	        /*}////////////////////
	        
	        if(zendeskOperationType != null){  
	            az.Account__c = account.id;     
	            az.status__c = 'IN_PROGRESS';
	            upsert az;  
	            System.debug('az:'+az);
	            System.debug('before doZendeskCreateTriggerCall'+ account.name +'    '+ account.ACE_Architect__r.Email);
	            String aceId = account.ACE_Architect__c!=null?account.ACE_Architect__c:null;
	            String aceEmail = account.ACE_Architect__c!=null?account.ACE_Architect__r.Email:null; 
	            System.debug('before aceId'+ aceId +'    '+ aceEmail);
	            System.debug('before status'+ aceId +'    '+ az.status__c);
	            try{
	            	System.debug('partnerContactsMap'+partnerContactsMap);
	            	ZendeskBackend.doZendeskTriggerCall(account.name, account.id, aceEmail, account.Owner.Email, account.Technical_Account_Manager__r.Email, aceId, account.Owner.Id, account.Technical_Account_Manager__c, az.id, zendeskOperationType, partnerContactsMap,accountPortalId,organizationId);
	            }catch(Exception e){
	            	
	            }
	        }
        }
  }
      
  @future (callout=true)
  public static void doZendeskTriggerCall(String accountName, String accountId, String aceEmailId, String seEmailId, String tamEmailId, String aceUserID, String seUserID, String tamUserID, String accountZendeskId, String zendeskOperationType,Map<Integer,String> partnerContactsMap,Integer accountPortalId,String organizationId) {
    String aceZendeskUserId;
    String tamZendeskUserId;
    String seZendeskUserId;
    String actionDetails = '"actions":[';
    List<User_Zendesk__c> zendeskUsers;
    boolean insertACEUser = false;
    boolean insertSEUser = false;
    boolean insertTAMUser = false;
    boolean insertPartnerUsers = false;
    List<Integer> portalIds = new List<Integer>(); 
    Map<String,String> partnerPortalAndZendeskIds = new Map<String,String>();
    ZendeskDetail[] zendeskDetails;
    ZendeskDetail[] companyZendeskDetails;
    
    Account_Zendesk__c az = [select Id, Organisation_Id__c, Trigger_Id__c, OP_CODE__c, Description__c, Status__c, Account__c from Account_Zendesk__c where id =: accountZendeskId];
    
    if(aceEmailId != null){
        try{
            zendeskUsers = [select Id, User__c, Zendesk_User_Id__c from User_Zendesk__c where User__r.Email =:aceEmailId limit 1];
            //aceZendeskUserId = zendeskUsers.size()>0?zendeskUsers.get(0).Zendesk_User_Id__c:fetchUserACEIdFromZendesk(aceEmailId);
            
            if(zendeskUsers.size()>0){
                aceZendeskUserId = zendeskUsers.get(0).Zendesk_User_Id__c;
            } else{
                aceZendeskUserId = fetchUserIdFromZendesk(aceEmailId);
                insertACEUser = aceZendeskUserId!=null?true:false;
            }
            
            if(aceZendeskUserId!=null){
                //actionDetails +='{"field":"cc","value":["'+aceZendeskUserId+'",""," "]}';
                String emailBody = '';
                //emailBody += '<b>Organization:</b> '+accountName+' <br/><br/>';
                //emailBody += '<b>Ticket link:</b> https://{{ticket.url}}<br/><br/>';
                emailBody += 'A ticket ({{ticket.id}}) with {{ticket.priority}} priority has been received by {{ticket.requester.name}} from {{ticket.organization.name}}.<br/><br/>';
                emailBody += 'Log into the Help Center to take or comment the ticket. Support will assign or resolve it shortly.<br/><br/>';
                emailBody += 'Review the ticket by following the link below:<br/> https://{{ticket.url}}<br/><br/>';
                emailBody += '{{ticket.comments_formatted}}';
                /*emailBody += '{% for comment in ticket.comments_formatted %}';
                emailBody += '<b> {{comment.author.name}}, {{comment.created_at_with_time}}:</b><br/>';
                emailBody += '<p>{{comment.value}}<p>';
                emailBody += '{% if comment.attachments != empty%}';
                emailBody += 'Attachment(s):<br/>';
                emailBody += '{% for attachment in comment.attachments %}';
                emailBody += '{{attachment.filename}}<br/>';
                emailBody += '{{attachment.url}}<br/>'; 
                emailBody += '{% endfor %}';
                emailBody += '{% endif %}';
                emailBody += '----------------------------------------------------------------------------------------------------------------------------------------------<br/><br/>';
                emailBody += '{% endfor %}';*/
                
              /* ////////////  actionDetails +='{"field":"notification_user","value": ["'+aceZendeskUserId+'", "ACE {{ticket.organization.name}} {{ticket.title}}", "'+emailBody+'"]}';
            }
        }catch(Exception e){
            
        }
    }
    
    if(tamEmailId != null){
        try{
            zendeskUsers = [select Id, User__c, Zendesk_User_Id__c from User_Zendesk__c where User__r.Email =:tamEmailId limit 1];
            
            if(zendeskUsers.size()>0){
                tamZendeskUserId = zendeskUsers.get(0).Zendesk_User_Id__c;
            } else{
                tamZendeskUserId = fetchUserIdFromZendesk(tamEmailId);
                insertTAMUser = aceZendeskUserId!=null?true:false;
            }
            
            if(tamZendeskUserId != null){
                if(aceZendeskUserId != null){
                    actionDetails +=',';
                }
                actionDetails +='{"field":"cc","value":["'+tamZendeskUserId+'",""," "]}';
            }
            
        }catch(Exception e){
            
        }
    }
    
    if(seEmailId != null){
        try{
            zendeskUsers = [select Id, User__c, Zendesk_User_Id__c from User_Zendesk__c where User__r.Email =:seEmailId limit 1];
            
            if(zendeskUsers.size()>0){
                seZendeskUserId = zendeskUsers.get(0).Zendesk_User_Id__c;
            } else{
                seZendeskUserId = fetchUserIdFromZendesk(seEmailId);
                insertSEUser = seZendeskUserId!=null?true:false;
            }
            
            if(seZendeskUserId != null){
                if(aceZendeskUserId != null || tamZendeskUserId != null){
                    actionDetails +=',';
                }
                actionDetails +='{"field":"cc","value":["'+seZendeskUserId+'",""," "]},';
            }
        }catch(Exception e){
            
        }
    }
    
    if(partnerContactsMap.size() > 0){
    	//call portal api for contact user ids
    	//portalIds.clear();
    	portalIds.addAll(partnerContactsMap.keySet());
    	String arrayString = '[';
    	for(Integer i = 0;i<portalIds.size();i++){
			arrayString +=portalIds.get(i);
			if(i < portalIds.size()-1){
				arrayString +=',';
			}else{
				arrayString += ']';
			}
		}
		String requestContactJson = '{"type":"contact","portalid":'+arrayString+'}';
		zendeskDetails = fetchZendeskIdFromPortal(requestContactJson);
		if(zendeskDetails!=null){
			for(ZendeskDetail zd: zendeskDetails){
				insertPartnerUsers = true;
				if(zd.zendeskid!=null && !zd.zendeskid.equals('') && !zd.zendeskid.equals('null')){
					actionDetails +='{"field":"cc","value":["'+zd.zendeskid+'",""," "]},';
				}
			}
		}
		
    } else if(zendeskOperationType.equals('UPDATE')){
    	insertPartnerUsers = true;
    }
    
    if(actionDetails.Substring(actionDetails.length()-1,actionDetails.length()).equals(',')){
    	actionDetails = actionDetails.Substring(0,actionDetails.length()-1);
    }
    
    actionDetails += ']';
    
    if((aceZendeskUserId == null && seZendeskUserId == null && tamZendeskUserId == null && zendeskDetails==null) && zendeskOperationType.equals('CREATE')){
        az.Account__c = accountId;
        az.status__c = 'FAILED';
        az.OP_CODE__c = '1';
        az.Description__c = 'aceZendeskUserId, seZendeskUserId, partnerContactIds and tamZendeskUserId are null.';
        upsert az;
    } else{
        String triggerId;  
        try{    
            try{
            	if(organizationId==null){
	            	String requestCompanyJson = '{"type":"company","portalid":['+accountPortalId+']}';
					companyZendeskDetails = fetchZendeskIdFromPortal(requestCompanyJson);
					if(companyZendeskDetails!=null){
						for(ZendeskDetail zd: companyZendeskDetails){
							if(zd.zendeskid!=null && !zd.zendeskid.equals('')){
								organizationId = zd.zendeskid;
							}
						}
					}
            	}
                //organizationId = doZendeskOrganisationCall(accountName);    
            }catch(Exception e){
                 
            }
            if(organizationId == null){
                az.Account__c = accountId;
                az.status__c = 'FAILED';
                az.OP_CODE__c = '2';
                az.Description__c = 'Organization Id is null.';
                upsert az;
            }else{
                RESTAPI api = new RESTAPI();
                if(zendeskOperationType.equals('CREATE')){
                    api.serviceURL =''+EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.ZENDESK_URL)+'/api/v2/triggers.json';
                    Blob headerValue = Blob.valueOf('jira@appdynamics.com'+':'+'help@appdynamics');
                    Map<String,String> headers = new Map<String,String>();
                    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                    headers.put('Authorization',authorizationHeader);
                    headers.put('Content-Type', 'application/json');
                    api.headers = headers;
                    api.requestMethod='POST';
                    api.requestBody = '{"trigger":{"title":"'+accountName+'_ACE_TAM_SE_Notification", "all":[{ "field": "organization", "operator": "is", "value": "'+organizationId+'" }] ,"any": [{ "field": "status", "operator": "is", "value": "open" }, { "field": "status", "operator": "is", "value": "New" }, { "field": "status", "operator": "is", "value": "Pending" }, { "field": "status", "operator": "is", "value": "Solved" }, { "field": "status", "operator": "is", "value": "Closed" }], '+actionDetails+'}}';
                    api.invoke();
                                                
                    System.JSONParser parser = System.JSON.createParser(api.response.getBody());
                    while (parser.nextToken() != null) {
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'id')) {
                              parser.nextToken();
                              System.debug(parser.getText());
                              triggerId = parser.getText();
                        }
                    }
                } else if(zendeskOperationType.equals('UPDATE')){
                    triggerId = az.Trigger_Id__c;
                    api.serviceURL =''+EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.ZENDESK_URL)+'/api/v2/triggers/'+triggerId+'.json';
                    Blob headerValue = Blob.valueOf('jira@appdynamics.com'+':'+'help@appdynamics');
                    Map<String,String> headers = new Map<String,String>();
                    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                    headers.put('Authorization',authorizationHeader);
                    headers.put('Content-Type', 'application/json');
                    api.headers = headers;
                    api.requestMethod='PUT';
                    api.requestBody = '{"trigger":{"any": [{ "field": "status", "operator": "is", "value": "open" }, { "field": "status", "operator": "is", "value": "New" }, { "field": "status", "operator": "is", "value": "Pending" }, { "field": "status", "operator": "is", "value": "Solved" }, { "field": "status", "operator": "is", "value": "Closed" }],"all":[{ "field": "organization", "operator": "is", "value": "'+organizationId+'" }],'+actionDetails+'}}';
                    api.invoke();
                    
                    System.JSONParser parser = System.JSON.createParser(api.response.getBody());
                   
                } /*else if(zendeskOperationType.equals('DELETE')){
                    triggerId = az.Trigger_Id__c;
                    api.serviceURL =''+EnvironmentSettings.instance.ZENDESK_URL+'/api/v2/triggers/'+triggerId+'.json';
                    Blob headerValue = Blob.valueOf('jira@appdynamics.com'+':'+'help@appdynamics');
                    Map<String,String> headers = new Map<String,String>();
                    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                    headers.put('Authorization',authorizationHeader);
                    headers.put('Content-Type', 'application/json');
                    api.headers = headers;
                    api.requestMethod='DELETE';
                    api.invoke();
                }*/
                
     /* //////////           
                if(api.response.getStatusCode() >= 200 && triggerId != null){
                        if(!zendeskOperationType.equals('DELETE')){
                            az.Organisation_Id__c = organizationId;
                            az.Account__c = accountId;
                            az.Trigger_Id__c = triggerId;
                            az.status__c = 'SUCCESS';
                            az.OP_CODE__c = '0';
                            az.Description__c = 'Zendesk Trigger created successfully.';
                            
                            //if(tamZendeskUserId!=null)
                                az.TAM__c = tamUserID;
                                
                            if(seZendeskUserId!=null)
                                az.SE__c = seUserID;
                                
                            if(aceZendeskUserId!=null)
                                az.ACE_Architect__c = aceUserID;
                                
                            upsert az;
                        } else{
                            delete az;
                        }
                        
                        User_Zendesk__c uz;
                        
                        if(insertACEUser){
                            uz = new User_Zendesk__c(User__c = aceUserID, Zendesk_User_Id__c = aceZendeskUserId);
                            insert uz;
                        }
                        
                        if(insertSEUser){
                            uz = new User_Zendesk__c(User__c = seUserID, Zendesk_User_Id__c = seZendeskUserId);
                            insert uz;
                        }
                        
                        if(insertTAMUser){
                            uz = new User_Zendesk__c(User__c = tamUserID, Zendesk_User_Id__c = tamZendeskUserId);
                            insert uz;
                        }
                        
                        if(insertPartnerUsers){
                        	
                        	List<Zendesk_Contact__c> zendeskPartnercontacts;
	        				try{
	        					zendeskPartnercontacts = [select Id,Contact_Id__c,PortalId__c from Zendesk_Contact__c where Account_Zendesk__c=:az.id];
	        				}catch(Exception e){
	        					
	        				}
	        				
	        				try{
		        				if(zendeskPartnercontacts!=null && zendeskPartnercontacts.size()>0){
		        					if(partnerContactsMap.size()>0){	
										for(Zendesk_Contact__c z: zendeskPartnercontacts){
											Boolean containContact = false;
											for(String contactId:partnerContactsMap.values()){
												System.debug('z'+z);
												System.debug('z.Contact_Id__c'+z.Contact_Id__c);
												System.debug('contactId'+contactId);
												if(contactId.equals(z.Contact_Id__c)){
													//partnerContactsMap.remove(Integer.valueOf(z.PortalId__c));
													containContact = true;
												}else{
													//delete z;
													containContact = false;
												}
											}
											if(containContact){
												partnerContactsMap.remove(Integer.valueOf(z.PortalId__c));
											}else{
												delete z;
											}
										}
									} else{
										delete zendeskPartnercontacts;
									}
		        				}
	        				}catch(Exception e){
	        					
	        				}
	        				System.debug('partnerContactsMap'+partnerContactsMap);
	        				
                        	List<Zendesk_Contact__c> zcList = new List<Zendesk_Contact__c>();
                        	
                        	if(partnerContactsMap!=null && partnerContactsMap.size()>0){
	                        	for(ZendeskDetail zd: zendeskDetails){
	                        		String contactId = partnerContactsMap.get(Integer.valueOf(zd.portalid));
									if(zd.zendeskid!=null && !zd.zendeskid.equals('') && zd.portalid!=null && !zd.portalid.equals('')
									 && contactId!=null && !contactId.equals('')){
										Zendesk_Contact__c zc = new Zendesk_Contact__c();
										zc.Account_Zendesk__c = az.id;
										zc.Contact_Id__c = contactId; 										
										zc.Zendesk_User_Id__c = zd.zendeskid;
										zc.PortalId__c = zd.portalid;
										zcList.add(zc);
									}
	                        	}
	                        	insert zcList;
                        	}
                        	
                        }
                        
                    }else{
                        az.Organisation_Id__c = organizationId;
                        az.Account__c = accountId;
                        az.Trigger_Id__c = triggerId;
                        az.status__c = 'FAILED';
                        az.OP_CODE__c = '3';
                        az.Description__c = api.response.getBody();
                        upsert az;
                    }
            }
        }catch(Exception e){
            
        }
    }
  }
  
  public static ZendeskDetail[] fetchZendeskIdFromPortal(String requestJson) {
  	//String jsonString = '{"type":"contact", "zendesk_details" :[{"portalid":"1212","zendeskid":"121213123"},{"portalid":"121213","zendeskid":"12312345"}]}';
  	ZendeskBackend.PortalResponse portalResponse = null;
    RESTAPI api = new RESTAPI();
    api.serviceURL = EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.backendServerURL)+'/accounts/manage/zendeskaccount/';
    Map<String,String> headersMap = new Map<String,String>();
	Long timestamp = DateTime.now().getTime();
	String signatureKey = EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.privateKey) + timestamp;
	Blob signatureBlob = Blob.valueOf(signatureKey);
	String signature = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', signatureBlob));
	headersMap.put('Timestamp',  '' + timestamp);
	headersMap.put('Api_token', EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.apiToken));
	headersMap.put('Signature' , signature);
	api.headers = headersMap;
	api.requestMethod='POST';
	api.requestBody = requestJson;
	if(!RESTAPI.unitTestMode){
		api.invoke();
		System.debug('response==='+ api.response.getBody());
	    if(api.response!=null && api.response.getStatusCode()==200){
	    	System.JSONParser parser =   JSON.createParser( api.response.getBody() );
	    	while (parser.nextToken() != null) {    
				if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
					portalResponse = (ZendeskBackend.PortalResponse)parser.readValueAs(ZendeskBackend.PortalResponse.class);
					//System.debug('type ==== '+portalResponse.type);    
					//System.debug('zendesk_details ==== '+portalResponse.zendesk_details[0].portalid);                        
				}
	    	}
	    } else{
	    	EmailUtil.notifyError('Error in portal zendesk api call: <br/>'+api.response.getBody(),null);
	    }  
	    return portalResponse.zendesk_details;
	}else{
		return null;
	}
  }
  
  public static String fetchUserIdFromZendesk(String emailId) {
    System.debug('fetchUserACEIdFromZendesk:');
    String userId;
    
    RESTAPI api = new RESTAPI();
    api.serviceURL = ''+EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.ZENDESK_URL)+'/api/v2/users/search.json?query=type:user%20email:"'+emailId+'"';
    Blob headerValue = Blob.valueOf('jira@appdynamics.com'+':'+'help@appdynamics');
    Map<String,String> headers = new Map<String,String>();
    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
    headers.put('Authorization',authorizationHeader);
    headers.put('Content-Type', 'application/json');
    api.headers = headers;
    api.requestMethod='GET';
    api.invoke();
    
    System.debug('fetchUserACEIdFromZendesk:'+ api.response.getBody() );
            System.JSONParser parser =   JSON.createParser( api.response.getBody() );
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) {
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                             ZendeskUser usr = (ZendeskUser)parser.readValueAs(ZendeskUser.class);
                             System.debug( 'users '+usr.email );
                             if(usr.email.equals(emailId)){
                                userId = usr.id;
                             }
                        }
                    }
                }
            }  
    return userId;
  }
  
  public class ZendeskUser {
    public string url;
    public string id;
    public string name;
    public string email;
    public string external_id;
    public string alias;
    public string created_at;
    public string updated_at;
    public string active;
    public string verified;
    public string shared;
    public string locale_id;
    public string locale;
    public string time_zone;
    public string last_login_at;
    public string phone;
    public string signature;
    public string details;
    public string notes;
    public string organization_id;
    public string role;
    public string custom_role_id;
    public string moderator;
    public string ticket_restriction;
    public string only_private_comments;
    public string[] tags;
    public string suspended;
    public ZendeskUserPhoto photo;
    public Boolean shared_agent;
    public Boolean restricted_agent;
    public string user_fields;
  }
  
  public class ZendeskUserPhoto {
    public string url;
    public string id;
    public string file_name;
    public string content_url;
    public string content_type;
    public string size;
    public string[] thumbnails;
  }
  
  public class PortalResponse {
    public String type;
    public String status;
    public ZendeskDetail[] zendesk_details;
  }
  
  public class ZendeskDetail {
    public String portalid;
    public String zendeskid;
  }
  */
}