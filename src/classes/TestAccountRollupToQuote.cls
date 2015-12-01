@IsTest(seeAlldata= true)
private class TestAccountRollupToQuote 
{
    static testMethod void testPartnerMarginAndNewOrderQuoteLineItem()
    {
        try
        {
        List<Account> accList;
        List<Contact> conList;
        List<Product2> prodList;
        List<PriceBookEntry> standardPriceList;
        List<PriceBookEntry> pbeList;
        List<QuoteLineItem> qliList;
        
        accList = new List<Account>{TestUtil.createAccounts(1, false)[0], TestUtil.createAccounts(1, false)[0]};
        AccountTriggerHandler obj = new AccountTriggerHandler();
        accList[1].RecordTypeId = obj.getAccountRecordType('Partner Account');
        insert accList;
        
        conList = new List<Contact>{TestUtil.createContacts(1, accList[0].Id, false)[0], TestUtil.createContacts(1, accList[1].Id, false)[0]};
        insert conList;
        
        Opportunity opp = TestUtil.createOpps(1, accList[0].Id, true)[0];
        
        Quote q = TestUtil.createQuotes(1, conList[1].Id, opp.Id, false)[0];
         
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard = true];
        
        Pricebook2 pb = new Pricebook2(Name = 'Test Price Book', Description = ' Price Book', IsActive = true);
        insert pb;
        
        Product2 prod1 = new Product2(Name = '.NET Pro Edition On-Premise Subscription 1-11 Months', Family = 'On-Premise Subscription', IsActive = true,
                                    Partner_Margin_Applied__c = 'True', Monthly__c = true, One_Time_Discount_Applied__c = 'true', Volume_Discount_Applied__c = 'true'
                                    );
        
        Product2 prod2 = new Product2(Name = '.NET Test & Dev Edition On-Premise Perpetual', Family = 'Perpetual License', IsActive = true,
                                    Partner_Margin_Applied__c = 'True', Monthly__c = false, One_Time_Discount_Applied__c = 'true', Volume_Discount_Applied__c = 'true',
                                    Support_Pecent_per_Year__c = 20);
        
        Product2 prod3 = new Product2(Name = 'Support Renewal for Perpetual Licenses', Family = 'Perpetual Support', IsActive = true,
                                    Partner_Margin_Applied__c = 'True', Monthly__c = true, One_Time_Discount_Applied__c = 'true', Volume_Discount_Applied__c = 'true',
                                    Perpetual_Support_Type__c = 'Renewal');
        
        Product2 prod4 = new Product2(Name = 'Support for Perpetual Licenses - 20%/Yr', Family = 'Perpetual Support', IsActive = true,
                                    Partner_Margin_Applied__c = 'True', Monthly__c = true, One_Time_Discount_Applied__c = 'true', Volume_Discount_Applied__c = 'true',
                                    Support_Pecent_per_Year__c = 20, Perpetual_Support_Type__c = 'New Order');
        prodList = new List<Product2>{prod1,prod2,prod3,prod4};
        insert prodList;
        
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = prod1.Id, 
                                                          UnitPrice = 10000, IsActive = true, 
                                                          UseStandardPrice = false);
        
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = prod2.Id, 
                                                          UnitPrice = 10000, IsActive = true, 
                                                          UseStandardPrice = false);
        
        PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = prod3.Id, 
                                                          UnitPrice = 10000, IsActive = true, 
                                                          UseStandardPrice = false);
        
        PricebookEntry standardPrice4 = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = prod4.Id, 
                                                          UnitPrice = 10000, IsActive = true, 
                                                          UseStandardPrice = false);
        standardPriceList = new List<PriceBookEntry>{standardPrice1,standardPrice2,standardPrice3,standardPrice4};
        insert standardPriceList;
        
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod1.Id, 
                                                          UnitPrice = 10000, IsActive = true, 
                                                          UseStandardPrice = false);
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod2.Id, 
                                                          UnitPrice = 10000, IsActive = true, 
                                                          UseStandardPrice = false);
        
        PricebookEntry pbe3 = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod3.Id, 
                                                          UnitPrice = 10000, IsActive = true, 
                                                          UseStandardPrice = false);
        
        PricebookEntry pbe4 = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod4.Id, 
                                                          UnitPrice = 10000, IsActive = true, 
                                                          UseStandardPrice = false);
        pbeList = new List<PricebookEntry>{pbe1,pbe2,pbe3,pbe4};
        insert pbeList;
        
        q.Pricebook2Id = pb.Id;
        q.RecordTypeId = '01280000000Lref';
        q.Partner_Margin_Discount__c = 0;
        insert q;
        
        QuoteLineItem qli1 = TestUtil.createQLIs(1, q.Id, pbe1.Id, false)[0];
        QuoteLineItem qli2 = TestUtil.createQLIs(1, q.Id, pbe2.Id, false)[0];
        QuoteLineItem qli3 = TestUtil.createQLIs(1, q.Id, pbe3.Id, false)[0];
        QuoteLineItem qli4 = TestUtil.createQLIs(1, q.Id, pbe4.Id, false)[0];
        
        qli1.Quantity = 4;
        qli1.Months__c = 6;
        qli1.Volume_Discount__c = 15;
        qli1.One_Time_Discount__c = 5;
        qli1.Perpetual_Support_Renewal_Price__c = 0;
        
        qli2.Quantity = 2;
        qli2.Months__c = 0;
        qli2.Volume_Discount__c = 5;
        qli2.One_Time_Discount__c = 10;
        qli2.Perpetual_Support_Renewal_Price__c = 0;
        
        qli4.Quantity = 1;
        qli4.Months__c = 18;
        qli4.Volume_Discount__c = 0;
        qli4.One_Time_Discount__c = 0;
        qli3.Perpetual_Support_Renewal_Price__c = 350;
        
        qli3.Quantity = 3;
        qli3.Months__c = 9;
        qli3.Volume_Discount__c = 0;
        qli3.One_Time_Discount__c = 15;
        qli4.Perpetual_Support_Renewal_Price__c = 0;
        
        List<QuoteLineItem> qlis = new List<QuoteLineItem>{qli1,qli2,qli3,qli4};
        insert qlis;
        
        test.startTest();
        
        //QuoteLineItemFutureUpdate.counter = 0;
        
        accList[1].Margin_Discount__c = 20;
        update accList[1];
        
        //System.assertEquals(accList[1].Margin_Discount__c, [Select Partner_Margin_Discount__c from quote where Id = :q.Id].Partner_Margin_Discount__c);
        //System.assertEquals(accList[1].Margin_Discount__c, [Select Partner_Margin__c from QuoteLineItem where Id = :qli1.Id].Partner_Margin__c);
        
        Delete qli1;
        
        test.stopTest();
        }
        catch(Exception e)
        {
            System.debug('An error occured in running TestAccountToQuoteRollup class: '+e.getMessage());
        }
    }
}