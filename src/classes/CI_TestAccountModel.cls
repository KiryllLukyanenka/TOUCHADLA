@isTest(seealldata = false)
public class CI_TestAccountModel {

  // Note - Full Circle CRM application is off during external tests - so we can
  // set all fields directly without interaction with the application

    static testMethod void TestRolesOnly() {
    Map<ID, Decimal> OpenOpportunityRevenue = new Map<ID, Decimal>();
    Map<ID, Decimal> ClosedOpportunityRevenue = new Map<ID, Decimal>();
    Map<ID, Decimal> LostOpportunityRevenue = new Map<ID, Decimal>();
      
        TestModel(0,1,1, OpenOpportunityRevenue, ClosedOpportunityRevenue, LostOpportunityRevenue);
        system.debug('Open ' + OpenOpportunityRevenue);
        system.debug('Closed ' + ClosedOpportunityRevenue);
        system.debug('Lost ' + LostOpportunityRevenue);

        Decimal dtotal = 0;
        for(Decimal d: OpenOpportunityRevenue.values()) dtotal+= d;
        System.AssertEquals(10000, dtotal);
        
        dtotal = 0;
        for(Decimal d: ClosedOpportunityRevenue.values()) dtotal+= d;
        System.AssertEquals(10000, dtotal);

        dtotal = 0;
        for(Decimal d: LostOpportunityRevenue.values()) dtotal+= d;
        System.AssertEquals(10000, dtotal);

    }

    static testMethod void TestAccountsOnly() {
    Map<ID, Decimal> OpenOpportunityRevenue = new Map<ID, Decimal>();
    Map<ID, Decimal> ClosedOpportunityRevenue = new Map<ID, Decimal>();
    Map<ID, Decimal> LostOpportunityRevenue = new Map<ID, Decimal>();
      
        TestModel(1,0, 0, OpenOpportunityRevenue, ClosedOpportunityRevenue, LostOpportunityRevenue);
        system.debug('Open ' + OpenOpportunityRevenue);
        system.debug('Closed ' + ClosedOpportunityRevenue);
        system.debug('Lost ' + LostOpportunityRevenue);

        Decimal dtotal = 0;
        for(Decimal d: OpenOpportunityRevenue.values()) dtotal+= d;
        System.AssertEquals(10000, dtotal);
        
        dtotal = 0;
        for(Decimal d: ClosedOpportunityRevenue.values()) dtotal+= d;
        System.AssertEquals(10000, dtotal);

        dtotal = 0;
        for(Decimal d: LostOpportunityRevenue.values()) dtotal+= d;
        System.AssertEquals(10000, dtotal);

    }

     
    static testMethod void TestTrigger()
    {
        CI_AccountModelConfig__c modelsettings = new CI_AccountModelConfig__c(name='default', Currency_Field_Name__c='Amount', Enabled__c = true, Search_Days__c = 365);
        insert modelsettings;       
        
      FCRM__FCR_APIHookTrigger__c hookobject = new FCRM__FCR_APIHookTrigger__c(FCRM__Hook_Type__c = 'campaigninfluence');
      Test.StartTest();
      insert hookobject;

      Test.StopTest();
      List<FCRM__FCR_APIHookTrigger__c> objs = [Select ID from FCRM__FCR_APIHookTrigger__c];
      system.AssertEquals(1, objs.size());
    }
    
    static testMethod void TestModel()
    {
    CI_AccountModel model = new CI_AccountModel();
    System.Assert(model.GetSupportsAccountInfluence());
    System.Assert(!model.GetSupportsOpInfluence());
    System.Assert(model.GetUniqueName() != null );
    System.Assert(model.GetDescription() != null );
    System.Assert(model.GetManufacturer() != null );
    System.Assert(model.GetCopyright() != null );
    System.Assert(model.GetConfigurationPage() != null); 
      
    }
    
    public static void TestModel(Integer AccountWeight, Integer RoleWeight, Integer CampaignSpecificWeight,
      Map<ID, Decimal> OpenOpportunityRevenue,
    Map<ID, Decimal> ClosedOpportunityRevenue,
    Map<ID, Decimal> LostOpportunityRevenue)
    {
      CI_AccountModelConfigController config = new CI_AccountModelConfigController();
        List<String> roles = config.getAvailableRoles();

    CI_AccountModelConfig__c modelsettings = new CI_AccountModelConfig__c(name='default', Currency_Field_Name__c = 'Amount', Enabled__c = true, Search_Days__c = 365, Account_Weight__c = AccountWeight);
    upsert modelsettings;       

    CI_ContactRoleWeight__c roleweightsetting = new CI_ContactRoleWeight__c(name = 'w0' , role__c = roles[0], weight__c = RoleWeight, Instance__c = 0 );    
    insert roleweightsetting;     
    
    List<CI_CampaignSpecificWeight__c> campaignweightsettings = new List<CI_CampaignSpecificWeight__c>{
      new CI_CampaignSpecificWeight__c(Instance__c = 0, name = 'w0Primary' , Type__c = 'Primary', weight__c = CampaignSpecificWeight ),
      new CI_CampaignSpecificWeight__c(Instance__c = 0, name = 'w0First Touch' , Type__c = 'First Touch', weight__c = CampaignSpecificWeight ),
      new CI_CampaignSpecificWeight__c(Instance__c = 0, name = 'w0Last Touch' , Type__c = 'Last Touch', weight__c = CampaignSpecificWeight )
    };    
    insert campaignweightsettings;        
      
      List<Account> acts = initTestAccounts('aa',1);
      insert acts;
      
      // Create 3 opportunities
      List<Opportunity> ops = initTestOpportunities('opwon',1,false, false);
      ops.addall(initTestOpportunities('opclosedlost',1,true, false));
      ops.addall(initTestOpportunities('opclosedwon',1,true, true));
      for(Opportunity op: ops)
      {
        op.AccountID = acts[0].id;
        op.Amount = 10000;
      }
      insert ops;
      //AddProductsToOpportunities(ops, 10000);

    List<Contact> cts = initTestContacts('cts', 5);
    for(Contact ct: cts) ct.AccountID = acts[0].id;
    cts[4].CI_Exclude_From_Influence__c = true;
    insert cts;
    
    List<Campaign> camps = initTestCampaigns('cmp', cts.size());
    insert camps;
    
    // Assign different Campaign types to each opp
    ops[0].FCRM__FCR_First_Campaign_Touch__c = camps[0].Id;
    ops[0].FCRM__FCR_Admin_Update_Counter__c = ops[0].FCRM__FCR_Admin_Update_Counter__c + 1;
    update ops;
    
    // Each contact has a response
    List<CampaignMember> cms = new List<CampaignMember>();
    for(Integer x = 0; x< 4; x++)
      cms.add(new CampaignMember(Status='Responded', ContactID = cts[x].id, CampaignID = camps[x].id, FCRM__FCR_Response_Date__c = DateTime.Now().AddDays(-1)));
    
    // Add Contact with CI_Exclude_From_Influence__c = true
    CampaignMember cmContact = new CampaignMember(Status='Responded', ContactID = cts[4].id, CampaignID = camps[0].id, FCRM__FCR_Response_Date__c = DateTime.Now().AddDays(-1));
    cms.add(cmContact);
    
    insert cms;
    
    // Each opportunity has one contact
    // Account has all 4 contacts
    List<OpportunityContactRole> ocrs = new List<OpportunityContactRole>();
    ocrs.add(new OpportunityContactRole(OpportunityID=ops[0].id, ContactID = cts[0].id, Role = roles[0]));
    ocrs.add(new OpportunityContactRole(OpportunityID=ops[1].id, ContactID = cts[1].id, Role = roles[0]));
    ocrs.add(new OpportunityContactRole(OpportunityID=ops[2].id, ContactID = cts[2].id, Role = roles[0]));
    insert ocrs;
    
    CI_AccountModel model = new CI_AccountModel();
    System.Assert(model.GetEnabled());
    System.Assert(model.OpportunityProcessAttribution(null, null, null, null, null)==null);

    Map<ID, Account> accounts = new Map<ID, Account>(acts);
    Map<ID, Map<ID, Opportunity>> opportunities = new Map<ID, Map<ID, Opportunity>>
       { acts[0].id => new Map<ID, Opportunity>(ops) };

    String state;
      Test.StartTest();
      state = model.Start();
    
    state = model.AccountProcessAttribution(accounts, 
      opportunities, OpenOpportunityRevenue, ClosedOpportunityRevenue, 
      LostOpportunityRevenue, State);     
      
      model.Finish(state);
      Test.StopTest();
    }
    
   public static List<Lead> initTestLeads(String prefix, Integer count)  
   {    
    List<Lead>lds = new List<Lead>();    
    for(Integer x=1;x<count+1;x++)    
    {      
      lds.add(new Lead(Company= prefix + '_' + String.valueOf(x), LastName = prefix + '_' + String.valueOf(x), Status='Nurture/Marketing'));    
    }    
    return lds;  
  }
    

  public static List<Account> initTestAccounts(String prefix, Integer count)
  {
    List<Account> accounts = new List<Account>();
    for(Integer x=1; x<count + 1; x++)
    {
      accounts.add(new Account(Name= prefix + '_' + String.valueOf(x)));    
    }
    return accounts;
  }


  public static List<Contact> initTestContacts(String prefix, Integer count)  
  {    
    List<Contact>cts = new List<Contact>();    
    for(Integer x=1;x<count+1;x++)    
    {      
      cts.add(new Contact(LastName = prefix + '_' + String.valueOf(x)));
    }
    return cts;  
  }
  
  public static List<Opportunity> initTestOpportunities(String prefix, Integer count, Boolean closed, Boolean won)
  {
    List<Opportunity> ops = new List<Opportunity>();
    Profile fsrProfile = [Select Id From Profile Where Name = 'AppD FSR' Limit 1];
    User fsrUser = [Select Id From User Where ProfileId = :fsrProfile.Id Limit 1];
    Profile isrProfile = [Select Id From Profile Where Name = 'AppD ISR' Limit 1];
    User isrUser = [Select Id From User Where ProfileId = :isrProfile.Id Limit 1];    
    for(Integer x=1; x<count+1; x++)
    {
      ops.add(new Opportunity(CloseDate = Date.Today().addDays(5), ISR__c = isrUser.ID, FSR__c = fsrUser.Id, FCRM__FCR_Admin_Update_Counter__c=1, Name = prefix + '_' + String.valueOf(x), StageName = getOpportunityStage(closed, won) ));  
    }
    return ops;
  }
  
  public static String getOpportunityStage(Boolean closed, Boolean won)
  {
    
    List<OpportunityStage> opportunitystages = [SELECT ID, IsClosed, IsWon, IsActive, MasterLabel from OpportunityStage where IsClosed = :closed and IsWon = :won];
    if(opportunitystages.size()>0) return opportunitystages[0].MasterLabel;
  
    return null;
  } 

   public static List<Campaign> initTestCampaigns(String prefix, Integer count)
   {
    List<Campaign> camps = new List<Campaign>();
    for(Integer x=1; x<count+1; x++)
    {
      camps.add(new Campaign(Name = prefix+'_'+ String.ValueOf(x), IsActive = true));
    }
    return camps;
   }

    /*
    public static void AddProductsToOpportunities(List<Opportunity> ops, decimal price)
    {
        List<PriceBookEntry> pbes = [SELECT ID, Name from PriceBookEntry where IsActive=true limit 1];
        
        if(pbes.size()==0) return;
        
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        for(Opportunity op: ops)
        {
            OpportunityLineItem newlineitem = new OpportunityLineItem();
            newlineitem.OpportunityID = op.id;
            newlineitem.PriceBookEntryID = pbes[0].id;
            newlineitem.Quantity = 1;
            newlineitem.UnitPrice = price;
            olis.add(newlineitem);
        }
        insert olis;
        
    }    
    */
    
}