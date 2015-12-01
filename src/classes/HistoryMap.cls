/*
 * HistoryMap class maintains Maps which contains object as key and values as list of fields or relational object names.
*/
public with sharing class HistoryMap {
	
	/*
		Map contains Field API name as key and label as value. This map is used in LicenseHistoryController_V2 to show 
		license history details in Audit trial UI.
	*/
	public static Map<String,Map<String,String>> objectsFieldsAndLabelNamesMap = new Map<String,Map<String,String>>
														{
															'LicenseDetail__c'=> new Map<String,String>{
																											'Product_Type__c' => 'Deployment-Option','Stage__c' => 'Stage','Product_Type__c' => 'Deployment-Option',
																											'License_Expiry_Date__c' => 'Expiry Date','Java_Agents_Rollup__c' => 'Java','Net_Agents_Rollup__c' => '.Net',
																											'Machine_Agents_Rollup__c' => 'Machine','Database_Agents_Rollup__c' => 'Database','NodeJs_Agents_Rollup__c' => 'NodeJs',
																											'License_BackendID__c' => 'License BackendID',
																											'PHP_Agents_Rollup__c' => 'PHP','MAC_Address__c' => 'Mac Address','Custom_URL_Name__c' => 'SAAS URL','Transaction_ID__c' => 'Transaction Id'
																										},
															'EUM_Web__c' => new Map<String,String>{
																									'Allow_overages__c' => 'EUM Web Overages','Type__c' => 'EUM Web Type',
																									'Units__c' => 'EUM Web Units'
																								},
															'EUM_Mobile__c' => new Map<String,String>{
																									'Allow_overages__c' => 'EUM Mobile Overages','Type__c' => 'EUM Mobile Type',
																									'Units__c' => 'EUM Mobile Units'
																								}
														};																
	
	/*
		The Map contains object name as key and list of field names as values.
	*/
	public static Map<String,List<String>> objectAndFieldsMap = new Map<String,List<String>>
												{
													'LicenseDetail__c'=> new List<String>{
											   												'Custom_URL_Name__c','Product_Type__c',
											                                         		'License_Expiry_Date__c','MAC_Address__c',
											                                         		'Stage__c','License_BackendID__c',
											                                         		'Java_Agents_Rollup__c','Net_Agents_Rollup__c',
											                                         		'Machine_Agents_Rollup__c','PHP_Agents_Rollup__c',
											                                         		'Database_Agents_Rollup__c','NodeJs_Agents_Rollup__c',
											                                         		'Transaction_ID__c'
											                                         },
											    	'License_EUM_Details__c'=> new List<String>{
											   												'AccountName__c','Access_Key__c'
											                                         },
													'License_Agent__c'=> new List<String>{
											   												'Agent_Type__c','Count__c'
											                                         },
													'EUM_Web__c'=> new List<String>{
											   												'Allow_overages__c','Type__c','Units__c'
											                                         },
													'EUM_Mobile__c'=> new List<String>{
											   												'Allow_overages__c','Type__c','Units__c'
											                                         }											                                         
											   };
	
	/*
		The Map contains object name as key and list of relational object names as values.
	*/											   
	public static Map<String,List<String>> relatedObjectsMap = new Map<String,List<String>>
												{
													'LicenseDetail__c'=> new List<String>{
											   												'License_EUM_Details__r','License_Agents__r',
											   												'License_EUM_Details__r.EUM_Web__r','License_EUM_Details__r.EUM_Mobile__r'
											            	                             }
												};
}