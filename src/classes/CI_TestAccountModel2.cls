@isTest
private class CI_TestAccountModel2 {

    // Note - Full Circle CRM application is off during external tests - so we can
    // set all fields directly without interaction with the application

    static testMethod void TestRolesOnly() {
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> OpenOpportunityRevenue = new Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>>();
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> ClosedOpportunityRevenue = new Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>>();
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> LostOpportunityRevenue = new Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>>();
        
        TestModel(0,1, 1, OpenOpportunityRevenue, ClosedOpportunityRevenue, LostOpportunityRevenue);
        system.debug('Open ' + OpenOpportunityRevenue);
        system.debug('Closed ' + ClosedOpportunityRevenue);
        system.debug('Lost ' + LostOpportunityRevenue);

        Decimal dtotal = 0;
        for(ID cmid: OpenOpportunityRevenue.keyset())
        {
            for(FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue d: OpenOpportunityRevenue.get(cmid)) dtotal+= d.InfluenceAmount;
        }
        System.AssertEquals(10000, dtotal);
        
        dtotal = 0;
        for(ID cmid: OpenOpportunityRevenue.keyset())
        {
            system.debug('closed op revenue ' + ClosedOpportunityRevenue );
            system.debug('closed op revenue2 ' + ClosedOpportunityRevenue.get(cmid) );
            for(FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue d: ClosedOpportunityRevenue.get(cmid)) dtotal+= d.InfluenceAmount;
        }
        System.AssertEquals(10000, dtotal);

        dtotal = 0;
        for(ID cmid: OpenOpportunityRevenue.keyset())
        {
            for(FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue d: LostOpportunityRevenue.get(cmid)) dtotal+= d.InfluenceAmount;
        }
        System.AssertEquals(10000, dtotal);

    }

    static testMethod void TestAccountsOnly() {
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> OpenOpportunityRevenue = new Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>>();
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> ClosedOpportunityRevenue = new Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>>();
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> LostOpportunityRevenue = new Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>>();
        
        TestModel(1,0, 0, OpenOpportunityRevenue, ClosedOpportunityRevenue, LostOpportunityRevenue);
        system.debug('Open ' + OpenOpportunityRevenue);
        system.debug('Closed ' + ClosedOpportunityRevenue);
        system.debug('Lost ' + LostOpportunityRevenue);

        Decimal dtotal = 0;
        for(ID cmid: OpenOpportunityRevenue.keyset())
        {
            for(FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue d: OpenOpportunityRevenue.get(cmid)) dtotal+= d.InfluenceAmount;
        }
        System.AssertEquals(10000, dtotal);
        
        dtotal = 0;
        for(ID cmid: OpenOpportunityRevenue.keyset())
        {
            for(FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue d: ClosedOpportunityRevenue.get(cmid)) dtotal+= d.InfluenceAmount;
        }
        System.AssertEquals(10000, dtotal);

        dtotal = 0;
        for(ID cmid: OpenOpportunityRevenue.keyset())
        {
            for(FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue d: LostOpportunityRevenue.get(cmid)) dtotal+= d.InfluenceAmount;
        }
        System.AssertEquals(10000, dtotal);
    }

     
    
    public static void TestModel(Integer AccountWeight, Integer RoleWeight, Integer CampaignSpecificWeight,
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> OpenOpportunityRevenue,
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> ClosedOpportunityRevenue,
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> LostOpportunityRevenue)
    {
        CI_AccountModelConfigController config = new CI_AccountModelConfigController();
        List<String> roles = config.getAvailableRoles();

        CI_AccountModelConfig__c modelsettings = new CI_AccountModelConfig__c(name='default', Currency_Field_Name__c = 'Amount', Account_Weight__c = AccountWeight, Search_Days__c = 365, Enabled__c = true);
        insert modelsettings;

        CI_ContactRoleWeight__c roleweightsetting = new CI_ContactRoleWeight__c(name = 'w0' , role__c = roles[0], weight__c = RoleWeight );     
        insert roleweightsetting;               

        CI_CampaignSpecificWeight__c campaignweightsetting = new CI_CampaignSpecificWeight__c(name = 'w0Primary Campaign Source' , Type__c = 'Primary Campaign Source', weight__c = CampaignSpecificWeight );      
        insert campaignweightsetting;   
        
        List<Account> acts = CI_TestAccountModel.initTestAccounts('aa',1);
        insert acts;
        
        // Create 3 opportunities
        List<Opportunity> ops = CI_TestAccountModel.initTestOpportunities('opwon',1,false, false);
        ops.addall(CI_TestAccountModel.initTestOpportunities('opclosedlost',1,true, false));
        ops.addall(CI_TestAccountModel.initTestOpportunities('opclosedwon',1,true, true));
        for(Opportunity op: ops)
        {           
            op.AccountID = acts[0].id;
            op.Amount = 10000;
        }
        insert ops;

        List<Contact> cts = CI_TestAccountModel.initTestContacts('cts', 4);
        for(Contact ct: cts) ct.AccountID = acts[0].id;
        insert cts;
        
        List<Campaign> camps = CI_TestAccountModel.initTestCampaigns('cmp', cts.size());
        insert camps;
        
        // Each contact has a response
        List<CampaignMember> cms = new List<CampaignMember>();
        for(Integer x = 0; x< 4; x++)
            cms.add(new CampaignMember(Status='Responded', ContactID = cts[x].id, CampaignID = camps[x].id, FCRM__FCR_Response_Date__c = DateTime.Now().AddDays(-1)));
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
        
        state = model.AccountProcessAttribution2(accounts, 
            opportunities, OpenOpportunityRevenue, ClosedOpportunityRevenue, 
            LostOpportunityRevenue, State);     
        
        model.Finish(state);
        Test.StopTest();
    }
}