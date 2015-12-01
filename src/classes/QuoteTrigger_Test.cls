@isTest(seeAllData=true)
private class QuoteTrigger_Test {
    @isTest static void testQuote() {
    Account acc = TestUtil.createAccounts(1, true)[0];
    Contact con =  TestUtil.createContacts(1, acc.Id, true)[0];
    Opportunity opp = TestUtil.createOpps(1, acc.Id, true)[0];
    Quote q = TestUtil.createQuotes(1, con.Id, opp.Id, false)[0];

    Pricebook2 standardPB = [SELECT Id
                             FROM Pricebook2
                             WHERE isStandard = true];

    Pricebook2 pb = new Pricebook2(
      Name = 'Test Price Book',
      Description = ' Price Book',
      IsActive = true);
    insert pb;

    Quote_Discount_Settings__c quoteSetting =
      Quote_Discount_Settings__c.getInstance();

    if (quoteSetting == null) {
      insert new Quote_Discount_Settings__c(
        One_Time_Discount_Product__c = 'One Time Discount Product',
        Partner_Margin_Discount_Product__c = 'Partner Margin Discount Product');
    }

    List<Product2> prodList = new List<Product2>();
    Product2 prod = new Product2(
      Name = quoteSetting.One_Time_Discount_Product__c,
      Family = 'Renewal',
      IsActive = true,
      Partner_Margin_Applied__c = 'True',
      Monthly__c = true);
    prodList.add(prod);

    Product2 supportProd = new Product2(
      Name = quoteSetting.Partner_Margin_Discount_Product__c,
      Family = 'Renewal',
      IsActive = true);
    prodList.add(supportProd);
    
    Product2 supportProd3 = new Product2(
      Name = quoteSetting.One_Time_Discount_Product__c,
      Family = 'Renewal',
      IsActive = true);
    prodList.add(supportProd3);
    
    Product2 supportProd4 = new Product2(
      Name = quoteSetting.Federal_Distributor_Discount_Product__c,
      Family = 'Renewal',
      IsActive = true);
    prodList.add(supportProd4);

    Product2 supportProd2 = new Product2(
      Name = 'Test Prod 3',
      Family = 'Renewal',
      IsActive = true);
    prodList.add(supportProd2);
    insert prodList;

    List<PricebookEntry> entryList = new List<PricebookEntry>();
    PricebookEntry standardPrice = new PricebookEntry(
      Pricebook2Id = standardPB.Id,
      Product2Id = prod.Id,
      UnitPrice = 10000,
      IsActive = true,
      UseStandardPrice = false);
    entryList.add(standardPrice);

    PricebookEntry standardPriceSupport = new PricebookEntry(
      Pricebook2Id = standardPB.Id,
      Product2Id = supportProd.Id,
      UnitPrice = 10000,
      IsActive = true,
      UseStandardPrice = false);
    entryList.add(standardPriceSupport);

    PricebookEntry standardPriceSupport2 = new PricebookEntry(
      Pricebook2Id = standardPB.Id,
      Product2Id = supportProd2.Id,
      UnitPrice = 10000,
      IsActive = true,
      UseStandardPrice = false);
    entryList.add(standardPriceSupport2);
    insert entryList;

    q.Pricebook2Id = pb.Id;
    q.Partner_Margin_Discount__c = 15;
    q.One_Time_Discount__c = 1000;
    q.Federal_Distributor_Margin__c= 10;
    q.Name = 'Test Quote';
    
    insert q;
    
    List<Quote> qte = new List<Quote>();
    Map<Id, Quote> mapQte = new Map<Id, Quote>();
    
    qte.add(q);
    
    
    QuoteTriggerHandler.afterInsert(qte);

    entryList = new List<PricebookEntry>();
    PricebookEntry pbe = new PricebookEntry(
      Pricebook2Id = pb.Id,
      Product2Id = prod.Id,
      UnitPrice = 10000,
      IsActive = true,
      UseStandardPrice = false);
    entryList.add(pbe);

    PricebookEntry pbe1 = new PricebookEntry(
      Pricebook2Id = pb.Id,
      Product2Id = supportProd.Id,
      UnitPrice = 10000,
      IsActive = true,
      UseStandardPrice = false);
    entryList.add(pbe1);

    PricebookEntry pbe2 = new PricebookEntry(
      Pricebook2Id = pb.Id,
      Product2Id = supportProd2.Id,
      UnitPrice = 10000,
      IsActive = true,
      UseStandardPrice = false);
    insert pbe2;
    insert entryList;

    List<QuoteLineItem> itemList = new List<QuoteLineItem>();
    //QuoteLineItem prodQLI = TestUtil.createQLIs(1, q.Id, pbe.Id, false)[0];
    QuoteLineItem supportQLI = TestUtil.createQLIs(1, q.Id, pbe2.Id, false)[0];
    itemList.add(supportQLI);
    //itemList.add(prodQLI);
    insert itemList;
    
    QuoteLineItemTriggerHandler.afterInsert(itemList);

    //update quote
    q.One_Time_Discount__c = 2500;
    q.Federal_Distributor_Margin__c=0;
    q.Partner_Margin_Discount__c = 20;
    update q;
    
    QuoteTriggerHandler.afterUpdate(qte, mapQte);
    
    
    System.assertEquals(itemList.size(), 1);
    
    }
}