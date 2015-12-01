public with sharing abstract class AppDController {
	protected Logger loggerHandle= null;
	/*
	 * Constant representing Save operation. 
	 * This value is set to opCode variable on saveObject method call.
	 */
	public static final Integer OPCODE_SAVE = 1;
	
	/*  
	 * Constant representing Delete operation. 
	 * This value is set to opCode variable on deleteObject method call.
	 */ 
	public static final Integer OPCODE_DEL = 2;  
	
	/*
	 * Reference to the page control providing access to record and 
	 * standard implementations for save, cancel.
	 */
	public ApexPages.StandardController stdController{get;set;}
	
	
	/*
	 * Salesforce Object being referred in the Visual Force page.
	 */
	public SObject pageContextObj{get;set;}
	
	/*
	 * Constant indicating the mode of operation being carried out.
	 */
	public Integer operationCode{get;set;}
	
	/*
	 * Holder for error message while doing validation/backend operations.
	 */
	public String errorMessage{get;set;}
	
	/*
	 * Backend Stub used to set up backend calls and invoke and 
	 * retrieve response/error messages.
	 */
	public BackendLayer backend{get;set;}
	
   /* 
	*Flag for disabling UI elements whenever an exception occures
	*
	*/
	public Boolean disableUIComponent{get;set;}
	
	/*
	 * Default Constructor added to support for Child classes. 
	 * This constructor will be called very rarely in scenarios like:
	 * a) If the page is used as a link/custom button from a object page.
	 * b) Test case methods being executed without the Page's standard Controller object
	 * For eg: ProvisionFreeTrial button on Opportunity page will invoke 
	 * default constructor for appropriate Controller.
	 */
	public AppDController(){
		init();
	}
	/*public AppDController(Boolean shouldInit){
		if(shouldInit){
			init();
		}
	}*/
	
	/*
	 * Standard constructor, being called from most of the controller subclasses.
	 * This does the following tasks:
	 * a) initialize pageContextObj with the value of current record of the controller
	 *		For eg: In case create new pages, the pageContextObj will be initialized with
	 *		new object of StandardController object type; In case of view/edit the value 
	 *		will be set with the object being viewed/edited.
	 * b) Set the standard controller in the instance scope, to be used in action methods
     *    to invoke standard actions like cancel.
     * c) Call the init routine to initialize the pageContext object and/or any child 
	 *	  controller specific instance variables. 
	 */
	public AppDController(ApexPages.StandardController controller){
		this.pageContextObj = controller.getRecord();
		this.stdController = controller;
		init();
	}
	
	/*
	 * Initialization of pageContextObj specific to each object being
	 * initialized and is defined in corresponding subclasses of this 
	 * class for each object. Intentionally left blank for child class 
	 * to optionally override and implement additional functionalities.
	 * Note: 
	 * a) Virtual tag is necessary for methods to be overriden in child classes
	 * b) Using empty implementation instead of abstract method will help some
	 *    child classes not to override this method if there are no specific 
	 *    initializations to be done. 
	 */
	public virtual void init(){
		System.debug(LoggingLevel.Info,'###### Iniside Init to Initialize logger');
		loggerHandle = Logger.getLogger('AppDController');
		loggerHandle.logOptions.put(Logger.LOG_OPTIONS_CACHE_LOG_MESSAGES,true);
	}
	
	/*
	 * Saves the Object. Following is the flow for save:
	 * a) Validation
	 * b) Generate Parameters (Either Request Parameter/JSON Parameters)
	 * c) Make Backend Call to save the object
	 * d) Call doPreSave if client wants to do specific modifications to object being saved.
	 * e) On Success insert the object to DB
	 * f) Call doPostSave to execute any specific post save operations on the object being saved. 
	 */
	public PageReference saveObject(){
		operationCode = OPCODE_SAVE;
		System.debug(LoggingLevel.Info,'Entering saveObject in APPDController');
		if(pageContextObj!=null){
			try
			{
				if(validateObject()){
					loggerHandle.debug('Validation Succeeded, Proceeding on Settingup Backend');
					setupBackend();
					loggerHandle.debug('Invoking Backend');
					//Proceed if either backend = null or succesful invocation of backend
					//backend==null means the page/controller calling saveObject doesnot 
					//want backend interation. 
					System.debug(LoggingLevel.Info,'Entering saveObject inside Validate pass APPDController');
					if(backend==null || backend.invokeBackend()){
						loggerHandle.debug('Backend Call Succeeded, proceeding on saving');
						if(doPreSave()){
							doSave();
							loggerHandle.debug('Saving completed');
							return doPostSave();
						}else{
							showErrorMessage(errorMessage);
	            			//EmailUtil.notifyError(backend.getErrorMessage(true));
	            			loggerHandle.error('DoPreSave Error:'+errorMessage);
						}        
					}else{
						showErrorMessage(backend.getErrorMessage(false));
		            	EmailUtil.notifyError(backend.getErrorMessage(true),BackendConstants.BACKEND_ERROR_SUBJECT);
		            	loggerHandle.error('Backend Error:'+backend.getErrorMessage(true));
					}
				}else{
	            	errorMessage =errorMessage!=null?errorMessage:'Validation failed, contact administrator for more details.';
	            	showErrorMessage(errorMessage);
	            	loggerHandle.error('Validation failed, contact administrator for more details.'+errorMessage);
				}
			}
			catch(Exception e){
				String exceptionType = e.getTypeName();
				String pageURL = Apexpages.currentPage().getUrl();
				if('CalloutException'.equals(exceptionType) || 'JSONException'.equals(exceptionType)){
        			EmailUtil.notifyError(e, null);
				}else{
        			EmailUtil.notifyError(e, null);
				}
				errorMessage = e.getMessage()+'\n'+e.getStackTraceString();
				showErrorMessage(errorMessage);
            	System.debug(LoggingLevel.ERROR,errorMessage);
            	loggerHandle.error(e.getMessage(),e);
			}finally{
				loggerHandle.commitCachedLogs();
			}
		}else{
			showErrorMessage(errorMessage);
		}
		return null;
	} 
	 
	/**
	 *
	 * 
	 */
	public abstract void setupBackend();
	
	/*
	 * Actual call to save the Object. this is accomplished by 
	 * either Insert/Update in to the salesforce db.
	 */
	public virtual void doSave(){
		upsert pageContextObj;
	}
	
	/*
	 * Actual call to delete the Object from the salesforce db.
	 */
	public void doDelete(){
		if(pageContextObj!=null && pageContextObj.Id!=null){ 
			delete pageContextObj;
		}
	}
	
	/*
	 * Cancel Action handler. Cancel is done by calling doCancel.
	 */
	public PageReference cancel(){
		return doCancel();
	}
	
	/*
	 * Action handler for Object deletion. Following is the flow for delete:
	 * Step 1: Validation
	 * Step 2: Generate Parameters (Either Request Parameter/JSON Parameters)
	 * Step 3: Make Backend Call to remove the object
	 * Step 4: Call doPreDeelte if child object implementation wants to do specific logic for object deletion.
	 * Step 5: On Success delete the object to DB
	 * Step 6: Call doPostDelete to execute any specific post deletion operations on the object being deleted. 
	 */
	public PageReference deleteObject(){
		operationCode = OPCODE_DEL;
		if(pageContextObj!=null){
			setupBackend();
			if(backend==null || backend.invokeBackend()){
				if(doPreDelete()){
					doDelete();
					return doPostDelete();
				}else{
					showErrorMessage(errorMessage);
				}
			}else{
				errorMessage = backend.getErrorMessage(false);
				showErrorMessage(errorMessage);
		        EmailUtil.notifyError(backend.getErrorMessage(true),BackendConstants.BACKEND_ERROR_SUBJECT);
			}
		}
		return null;
	}
	
	public abstract Boolean validateObject();
	
	/*
	 * Routine called just before saving the object. This can be used to do 
	 * i) Initialization or Data modifications before saving
	 * ii) Decide whether to save or not based on specific conditions.
	 * This is implemented in specific subclasses.
	 */
	public abstract boolean doPreSave();
	
	/*
	 * Routine called just before saving the object. This can be used to do 
	 * i) Updating related objects with the object id of this object
	 * ii) Decide on the page to navigated next.
	 * This is implemented in specific subclasses.
	 */
	public abstract PageReference doPostSave();
	
	/*
	 * Routine called just before saving the object. This can be used to do 
	 * i) Decide on the page to navigated next.
	 * This is implemented in specific subclasses.
	 */
	public abstract PageReference doCancel();
	
	/*
	 * Routine called just before deletion of the object. 
	 * This can be used to do: 
	 * i) Initialization or Data modifications before deletion
	 * ii) Decide whether to proceed with delete or not based on specific conditions.
	 * This is implemented in specific subclasses.
	 */
	public abstract Boolean doPreDelete();
	
	/*
	 * Routine called just after deletion of the object. 
	 * This can be used to do: 
	 * i) Removing related child objects with the object id of this object
	 * ii) Decide on the page to be navigated next.
	 * This is implemented in specific subclasses.
	 */
	public abstract PageReference doPostDelete();
	
	/*
	 * Flag to disable the UI Action button. Currently used only in License Provision pages.
	 */
    public Boolean provisionDisabled{get;set;}
	
	/*
	 * Common Helper method to show Error message on the VisualForce Page
	 */
	public void showErrorMessage(String message){
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,message);
        ApexPages.addMessage(myMsg);
	}

	/*
	 * Cancels ongoing operation by showing error message and exception details and disables the submit action buttton.
	 * Also logs the errormessage and exception stack.
	 */
	public PageReference cancelOperation(String errorMessage, Exception e){
		if(e!=null){
			errorMessage+=e.getMessage()+'\nStack:'+e.getStackTraceString();
		}
		showErrorMessage(errorMessage);
		loggerHandle.error(errorMessage,e);
        provisionDisabled = true;
		return null;
	}
}