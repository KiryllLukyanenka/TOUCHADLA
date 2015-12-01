public with sharing class PortalModelLicense {
	public class LicenseDiscoverResult{
		public LicenseMetadata meta_data;
	}
	
	public class LicenseMetadata{
		public License default_request{get;set;}
		public Property[] metadata{get;set;}
	}
	
	public class Property{
		public String name{get;set;}
		public String data_type{get;set;}
		public String default_value{get;set;}
		public String min_value{get;set;}
		public String max_value{get;set;}
		public String[] allowed_values{get;set;}
	}
	
	public class License{
		public String id;
		public String edition {get;set;}
		public String expiration_date {get;set;}
		public String end_date{get;set;}
		public DeploymentData deployment {get;set;}
		public Product[] products;
		public LicenseUser[] contacts;
		public LicenseSource source;
		public LicenseCompany company;
		
		public String status{
			get{
				return this.active ? 'active' : 'in-active';
			}
		}
		
		public String sfStage{
			get{
				if(this.edition == 'pro'){
					if(deployment.type == 'onprem'){
						Attribute onpremAttribs = deployment.attributes;
						if(onpremAttribs!=null){
							if(onpremAttribs.mac_address!=null && !onpremAttribs.mac_address.trim().equals('')){
								return this.active?'PAID_PERMANENT':'PAID_PERMANENT_EXPRIED';
							}else{
								return this.active?'PAID_TEMP':'PAID_TEMP_EXPRIED';
							}
						}
					}
					return this.active?'PAID_PERMANENT':'PAID_PERMANENT_EXPRIED';
				}else if (this.edition == 'lite'){
					return  'LITE';
				}else{
					return this.active?'TRIAL':'TRIAL_EXPRIED';
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
				return (this.deployment.type == 'saas')? 'Hosted (SaaS)' : 'On-Premise';
			}
		}
		
		public Boolean active{
			get{
				return true;//this.getDate(this.end_date) > Date.today();
			}
		}
	}
	
	public class DeploymentData{
		public String type{get;set;}
		public Attribute attributes{get;set;}
	}
	
	public virtual class Attribute{
		public String mac_address{get;set;}
		public String hostname{get;set;}
		public String account_name{get;set;}
		public String user_name{get;set;}
		public String password{get;set;}
		public String access_key{get;set;} 
	}
	
	public class Product{
		public String name{get;set;}
		public String type{get;set;}
		public String category{get;set;}
		public String edition{get;set;}
		public String expiration_date{get;set;}
		public DateTime expiration_date_dt {
			get{
				return this.getDate(expiration_date);
			}
		}
		public String model{get;set;}
		public Integer units{
			get;
			set{
				units = value;
			}
		}
		public Integer max_units{get;set;}
		public Integer retention{get;set;}
		
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
		
		public list<SelectOption> editionSelectOptions{get;set;}
		public list<SelectOption> modelSelectOptions{get;set;}
	}
	
	public class LicenseUser{
		public String contactId {get;set;}
		public string email{get;set;}
		public String firstName{get;set;}
		public String lastName{get;set;}
		public String user_type {get;set;}
		public String type{
			get{
				return this.user_type;
			}
		}
		
		public Boolean isPrimary{
			get;
			set{
				isPrimary = value;
				if(value){
					this.user_type = 'primary';
					this.needServiceEmail = true;
					this.needLicenseEmail = true;
				}else{
					this.user_type = 'additional';
				}
			}
		}
		
		public String[] notifications;
		
		public Boolean needServiceEmail{
			get{
				
				if(notifications!=null){
					set<String> notificationsSet = new set<String>(notifications);
					return notificationsSet.contains('saas');
				}
				return false;
			}set{
				needServiceEmail = value;
				if(notifications == null){
					notifications = new list<String>();
				}
				set<String> notificationsSet = new set<String>(notifications);
				if(!notificationsSet.contains('saas')){
					this.notifications.add('saas');
				}
			}
		}
		
		public  Boolean needLicenseEmail{
			get{
				
				if(notifications!=null){
					set<String> notificationsSet = new set<String>(notifications);
					return notificationsSet.contains('license');
				}
				return false;
			}
			set{
				needLicenseEmail = value;
				set<String> notificationsSet = new set<String>(notifications);
				if(!notificationsSet.contains('license')){
					this.notifications.add('license');
				}
			}
		}
		
		public Boolean equals(Object obj){
			if(obj instanceof LicenseUser){
				return email.equals(((LicenseUser)obj).email);
			}
			return false;
		}
		
		public Integer hashCode(){
			return email.hashCode();
		}
	}
	
	public class LicenseCompany{
		public string name{get;set;}
		public String type{get;set;}
	}
	
	public class LicenseSource{
		public string type;
		public list<LicenseSourceProperty> properties;
	}
	
	public class LicenseSourceProperty{
		public String property;
		public String value;
	}
	
	public class LicenseOperation{
		public String id {get;set;} //"id": "44b0139a-5f3c-419f-a93b-bad1fa8d55c2",
		public String status {get;set;} //"status"": "SUCCESS",
		public String started {get;set;} //   "started": null,
		public String completed {get;set;} //"completed": null,
		public String reason {get;set;} //"reason": "",
		public list<LicenseOperationTask> tasks {get;set;}
		public boolean success {
			get{
				return status == 'SUCCESS';
			}
		}
		public boolean failed {
			get{
				return status == 'FAILED';
			}
		}
		
		public boolean inprogress{
			get{
				return !finished;
			}
		}
		public boolean finished{
			get{
				return success || failed;
			}
		}
		
		public String statusClass{
			get{
				if(success){
					return 'success';
				}else if(failed){
					return 'failed';
				}else{
					return 'inprogress';
				}
			}
		}
	}
	
	public class LicenseOperationTask{
		public String id {get;set;} //"id": "44958cd0-c3eb-4076-aac7-e9dd4bd0c596",
		public String name {get;set;} //"name": "license",
		public String type {get;set;} //"type": "OnPremLicenseAction",
		public String started {get;set;} //"started": "2015-10-28T13:37:26.100028",
        public String completed {get;set;} //"completed": "2015-10-28T13:37:26.854261",
        public String reason {get;set;} // "reason": "",
        public String status {get;set;} //"status": "SUCCESS"
        public boolean success {
			get{
				return status == 'SUCCESS';
			}
		}
		public boolean failed {
			get{
				return status == 'FAILED';
			}
		}
		public boolean inprogress{
			get{
				return (started!=null && !started.equals('')) && !finished;
			}
		}
		public boolean finished{
			get{
				return success || failed;
			}
		}
		public String statusClass{
			get{
				if(success){
					return 'success';
				}else if(failed){
					return 'failed';
				}else if(inprogress){
					return 'inprogress';
				}else{
					return '';
				}
			}
		}
	}
}