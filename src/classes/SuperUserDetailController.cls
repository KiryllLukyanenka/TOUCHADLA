public without sharing class SuperUserDetailController extends AbstractAppDController
{
    private string userid = apexpages.currentpage().getparameters().get('id');
    public SuperUserDetailController()
    {
        Editmode = false;
        getUserDetail();
        CurrentUserid = Userinfo.getUserId();
        User currentloginUser = [select Id, COntact.AccountId, COntact.Account.Name, IsPrmSuperUser from User where Id = :Userinfo.getUserId()];
        IsPrmSuperUser = currentloginUser.IsPrmSuperUser;
    }
    
    public Boolean IsPrmSuperUser { get; set; }
    public User CurrentUser { get; set; }
    public Boolean Editmode { get; set; }
    public Id CurrentUserid { get; set; }
    
    //User Access
    private String contactID;
    public String pageTitle{get;set;}
    public ADUAController_V2.ADUAUser adUsers {get;set;}
    public Contact contactObj {get;set;}
    public Account contactAcc {get;set;}
    public Boolean isPartnerLoggedIn {get;set;}
    public ADUAUI aduaUIObj{get;set;} 
    
    public pageReference showEditMode()
    {
        Editmode = true;
        return null;
    }
    
    public pageReference activateUser()
    {
        User theUser = new User(Id = userid);
        theUser.IsActive = true;
        update theUser;
        getUserDetail();
        return null;
    }
    
    public pageReference inactiveUser()
    {
        User theUser = new User(Id = userid);
        theUser.IsActive = false;
        update theUser;
        getUserDetail();
        return null;
    }
    
    public pageReference updateUser()
    {
        try
        {
        update CurrentUser;
        getUserDetail();       
        Editmode = false;
        }
        catch(Exception ex)
        {
        }
        return null;
    }
    
    public pageReference cancelEditUser()
    {
        Editmode = false;
        return null;
    }
    
    private void getUserDetail()
    {
        String strFields = '';
        for(String strField : Schema.SObjectType.User.fields.getMap().keySet())
        {
            strFields += strField + ', ';
        }
        String m_strAllUserFields = strFields.substring(0, strFields.length()-2);
        String strFilterInQuery = 'where Id = \'' + userid + '\'';
        String strQuery = 'select ' + m_strAllUserFields + ' from User ' + strFilterInQuery;
        List<User> users = (List<User>)database.query(strQuery);
        CurrentUser = users[0];
    }
    
    /**
     * Overriden init method called from the Super Class AppDController's constructor.  
     */
    public override void init(){
      super.init();
        if(contactId==null){
            contactId = ApexPages.currentPage().getParameters().get('ContactId');
        }
    }
    
    public  PageReference initAction(){
        contactId = ApexPages.currentPage().getParameters().get('ContactId');
         try{
          /*if(loggerHandle==null){
            loggerHandle =Logger.getLogger('ADUAController_V2');
          }*/
          loggerHandle.setClassName(ADUAController_V2.class.getName());
        if(contactId!=null){
            contactObj = (Contact)DataLayerConstants.fetchSingle('Contact',contactId);
            if(contactObj.AccountId!=null){
              contactAcc=(Account)DataLayerConstants.fetchSingle('Account',contactObj.AccountId);//contactObj.Account;
            }
            loggerHandle.debug('Initializing ADUA Page for contact:'+contactId+ ' of Account:'+contactObj.AccountId);
        }
        
        if(contactAcc!=null){
          disableUIComponent = false;
          isPartnerLoggedIn = UsersUtil.isPartner(contactAcc);        
          
          if(contactObj!=null){
              pageContextObj= contactObj;
          }
          pageTitle = 'Setup AppDynamics User Account for Contact: ';
          pageTitle +=contactObj.Name;
            String cName = contactAcc.Name.replace('\\','');
          String requestJson = '{"companyName":"'+cName.replaceAll('"','\\\\"')+'","emails":["'+contactObj.email+'"]}';
          adUsers = UserDetailsBackend.getUserDetails(requestJson);
          ADUAController_V2.ADUAUserDetails aduaUser = null;    
          if(adUsers!=null){
              aduaUser = adUsers.users[0];
          }
          
          List<Contact> contactList = new List<Contact>();
          contactList.add(contactObj);
          contactObj = UsersUtil.getContactPortalUsers(contactList, contactAcc).get(0);
          aduaUIObj=ADUAUI.newInstance(contactObj,aduaUser);
        } else{
          disableUIComponent = true;
          errorMessage = 'Please associate contact with an Account.';
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errorMessage);
            ApexPages.addMessage(myMsg);
            loggerHandle.error(errorMessage);
        }
        
        }catch(Exception e){
          
            loggerHandle.error(e.getMessage(),e);
        }
        
        return null;
    }
    
    public String downloadsVisible{get;set;}
  public String docsVisible{get;set;}
    
  /**
     * Implementation of Validation method to put validation code specific to ADUA operations.
     * This will be called during save process from the super class.
     */
    public override Boolean validateObject(){
      if(contactObj.Email== null || contactObj.Email.trim()==''){
      errorMessage = 'Please provide Email ID for the Contact when AppDynamics Access is enabled';
      return false;
    }
    if(contactObj.AccountId == null){
      errorMessage = 'Please select the account to which the Contact belongs';
      return false;
    }
    /*if(aduaUser.applications!=null && aduaUser.applications.size()==0){
      errorMessage = 'Please select the systems to which the user has access to under Accessible Systems for AppDynamics';
      return false;
    }*/
    if(aduaUIObj.active){
      if(aduaUIObj.systemEntries!=null && aduaUIObj.systemEntries.size()>0){
        Boolean isSelected = false;
        Boolean isDownloadSelected = false;
        Boolean isDownloadZoneSelected = false;
        
        for(ADUAUI.SystemEntry se: aduaUIObj.systemEntries){
          if(se.selected){
            isSelected = true;
            if(se.systemName.equals(AppDConstants.ACCESSIBLE_DOWNLOADS)){
              isDownloadSelected = true;
              for(ADUAUI.ADUAZoneDetails ad: aduaUIObj.zoneList){
                if(ad.selected){
                  isDownloadZoneSelected = true;
                }
              }
            }
          }
        }
        if(!isSelected){
          errorMessage = 'Please select the systems to which the user has access to under Accessible Systems for AppDynamics';
          return false;
        }
        
        if(isDownloadSelected && !isDownloadZoneSelected){
          errorMessage = 'Please select download zone(s) for the user access.';
          return false;
        }
      }
    }
    return true;
    }
    
  /**
    * Overriding setupbackend to initialize backend calls and parameters based on 
    * the operation being carriedout as Save/Update and Delete.
    */
    public override void setupBackend(){
      aduaUIObj.updateADUAUserDetails(null);
      backend = new BackendLayer();
    AccountBackend accBackend = new AccountBackend(contactAcc,BackendConstants.OPCODE_ADD_COMPANY);
        backend.addBackend(accBackend);
    ContactBackend_V2 ctcBackend= new ContactBackend_V2(aduaUIObj.aduaUser,contactAcc,BackendConstants.OPCODE_ADD_USER);
    backend.addBackend(ctcBackend);
    }
    
    public override PageReference doCancel(){
      if(contactID!=null){
            PageReference ref = new PageReference('/'+contactID);
            ref.setRedirect(true);
            return ref;
        }
        return null;
    }
    
    public override boolean doPreSave(){
      try{
          
          try{
        String response = backend.getResponse(BackendConstants.OPCODE_ADD_COMPANY);
             String ctResponse = backend.getResponse(BackendConstants.OPCODE_ADD_USER);
             loggerHandle.debug('Resonse for Company Call:'+response);
             loggerHandle.debug('Resonse for User Call:'+ctResponse);
             String companyId = response;
             Account_Portal_Company__c accountPortalCompany = null; 
                if(response!=null){
                  if(contactAcc!=null){
                    accountPortalCompany = AccountContactsADUAHelper.saveAccountPortalDetails(response, contactAcc);
                  }
        }
                JSONObject jsonResponse = new JSONObject(new JSONObject.JSONTokener(ctResponse));
                System.debug( 'PortalID__c adua'+jsonResponse.getValue(contactObj.Email).num+'' );
                
        String portalId = jsonResponse.getValue(contactObj.Email).num+'';
        Contact_Portal_User__c contactPortalUser = (Contact_Portal_User__c)contactObj.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).get(0);
        contactPortalUser.User_Portal_Id__c = portalId;
              
              /*
                Changing the page context object to contact_portal_user. 
              */  
                if(contactPortalUser!=null){
                  upsert contactPortalUser;
                  pageContextObj = contactPortalUser;
                }
                
                if(aduaUIObj.isChanged()){
                  UsersUtil.saveContactHistory(aduaUIObj,contactPortalUser,CommonUtil.getPageName(),'ADAUController_V2', backend.getStatusCode(BackendConstants.OPCODE_ADD_USER));
                }
              ADUAUtils.setupADUAContact(contactObj, aduaUIObj.aduaUser.getApplications());    
              
                //contactObj.PortalID__c = jsonResponse.getValue(contactObj.Email).num+'';
      }catch(Exception e){
              System.debug(e);
              loggerHandle.warn(e.getMessage(),e);
      }
            //upsert contactObj;  
        }
        catch(Exception e){
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage());
            ApexPages.addMessage(myMsg);
            ApexPages.addMessage(myMsg);
            loggerHandle.error(e.getMessage(),e);
        } 
        return true;
    }
    
    public override PageReference doPostSave(){
      PageReference ref = new PageReference('/apex/SuperUserDetail?id='+userid + '&ContactId=' + contactID + '&pageType=contact');
    ref.setRedirect(true);
    return ref;
    }
}