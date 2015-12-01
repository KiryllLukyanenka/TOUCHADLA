@IsTest(seeAlldata= true)
private class TestQuoteAfterTrigger {

    static testMethod void testQuoteAfterUpdate() {
        QuoteSyncField__c quoteField = new QuoteSyncField__c(
            Name = 'Name',
            OppSyncField__c = 'Name'
        );
        insert quoteField ;
        /* Enahncement - This custom setting record already exists in Production
        QuoteLineSyncField__c quoteLine = new QuoteLineSyncField__c(
            Name = 'Months__c',
            OppLineSyncField__c = 'Volume_Discount__c'
            
        );
        insert quoteLine ;
        */
        Account acc = TestUtil.createAccounts(1, true)[0];
        Contact con =  TestUtil.createContacts(1, acc.Id, true)[0];
        Opportunity opp = TestUtil.createOpps(1, acc.Id, true)[0];
        Quote q = TestUtil.createQuotes(1, con.Id, opp.Id, false)[0];
        
        
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard = true];

        Pricebook2 pb = new Pricebook2(Name = 'Test Price Book', Description = ' Price Book', IsActive = true);
        insert pb;
        Product2 prod = new Product2(Name = 'License Prod', Family = 'Renewal', IsActive = true,
                                    Partner_Margin_Applied__c = 'True', Monthly__c = true);
        insert prod;
        
        Product2 supportProd = new Product2(Name = 'Support Prod', Family = 'Renewal', IsActive = true, 
                                            Monthly__c = true, Partner_Margin_Applied__c = 'True', 
                                            Perpetual_Support_Type__c = 'New Order', Support_Pecent_per_Year__c=20);
        insert supportProd;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = prod.Id, 
                                                          UnitPrice = 10000, IsActive = true, 
                                                          UseStandardPrice = false);
        insert standardPrice;
        
        PricebookEntry standardPriceSupport = new PricebookEntry(Pricebook2Id = standardPB.Id, 
                                                                 Product2Id = supportProd.Id, UnitPrice = 10000, 
                                                                 IsActive = true, UseStandardPrice = false);
        insert standardPriceSupport;
        
        q.Pricebook2Id = pb.Id;
        q.RecordTypeId = '01280000000LzGr';
        q.Partner_Margin_Discount__c = 0; // Enhancement - this value will be copied over to Line Items
        insert q;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 10000,
                                                IsActive = true, UseStandardPrice = false);
        insert pbe;
        
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = supportProd.Id, 
                                                 UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert pbe1;
        
        
       

        QuoteLineItem prodQLI = TestUtil.createQLIs(1, q.Id, pbe.Id, true)[0];
        
        QuoteLineItem supportQLI = TestUtil.createQLIs(1, q.Id, pbe1.Id, false)[0];
        
        supportQLI.Months__c = 12;
        prodQLI.Months__c = 12;
        supportQLI.Perpetual_Support_Renewal_Price__c = 0;
        prodQLI.Perpetual_Support_Renewal_Price__c = 0;
        System.debug('supportQLI----'+supportQLI);
        insert supportQLI;
        update prodQLI; 
        
        System.debug('prodQLI----'+prodQLI);
        Test.startTest();
            List<OpportunityLineItem> oliList = [Select id ,Months__c from OpportunityLineItem where OpportunityId = :opp.Id];
            for(OpportunityLineItem ol :oliList ){
                ol.Months__c =  12;    
            }
            System.debug('oliList ----'+oliList );
            if(oliList  != null && oliList.size()>0)
                update oliList ;
            
            opp.SyncedQuoteId = q.Id;
            update opp;
            q.One_Time_Discount_Percentage__c = 10;
            update q;
        Test.stopTest();
        
        prodQLI = [Select TotalPrice, UnitPrice from QuoteLineItem where id = :prodQLI.Id];
        supportQLI = [Select TotalPrice, UnitPrice  from QuoteLineItem where id = :supportQLI.Id];
        Decimal totalPrice = ((prodQLI.TotalPrice * .2)  * .9 ) ;
        
        System.debug('supportQLI----'+supportQLI);
        QuoteSyncUtil.addNewQuoteId(q.Id);
        QuoteSyncUtil.getNewQuoteIds();
        QuoteSyncUtil.removeNewQuoteId(q.Id);
        Set<Id> ids = new Set<Id> ();
        ids.add(q.id);
        QuoteSyncUtil.removeAllNewQuoteIds(ids); 
        QuoteSyncUtil.clearNewQuoteIds();
        QuoteSyncUtil.isNewQuote(q.Id);
        QuoteSyncUtil.getQuoteLineFieldMapTo('Months__c');
        QuoteSyncUtil.getQuoteFieldsString();
        QuoteSyncUtil.getOppFieldsString();
        QuoteSyncUtil.getQuoteLineFieldsString();
        QuoteSyncUtil.getOppLineFieldsString();
        QuoteSyncUtil.addQuoteField('Name', 'Name');
        QuoteSyncUtil.addQuoteLineField('Months__c', 'Discount');
        QuoteSyncUtil.removeQuoteField('Name');
        QuoteSyncUtil.removeQuoteLineField('Months__c');
        QuoteSyncUtil.getField('Opportunity', 'Name');
        QuoteSyncUtil.getField('Quote', 'Notes__c');
        QuoteSyncUtil.getField('QuoteLineItem', 'Months__c');
        QuoteSyncUtil.getField('OpportunityLineItem', 'OpportunityId');
        QuoteSyncUtil.getCustomRequiredFields('Opportunity');
        QuoteSyncUtil.getCustomRequiredFields('QuoteLineItem');
        QuoteSyncUtil.getCustomRequiredFields('Quote');
        QuoteSyncUtil.getCustomRequiredFields('OpportunityLineItem');
        
        QuoteSyncUtil.populateRequiredFields(opp);
        QuoteSyncUtil.populateRequiredFields(q);
        QuoteSyncUtil.populateRequiredFields(prodQLI);
        Schema.DescribeFieldResult F = Schema.SObjectType.Opportunity.fields.Name;
        QuoteSyncUtil.createValue('Opportunity', 'Name', f);
        Schema.DescribeFieldResult Ft = Schema.SObjectType.Quote.fields.Name;
        QuoteSyncUtil.createValue('Quote', 'Name', Ft );
        
        //QuoteSyncUtil.populateRequiredFields(NewRec);
        //system.assertEquals(TotalPrice, supportQLI.TotalPrice);
    }
}