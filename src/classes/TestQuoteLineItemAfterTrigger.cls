@IsTest(SeeAllData=true)
private class TestQuoteLineItemAfterTrigger {

    static testMethod void testForQLIError() {
        Account acc = TestUtil.createAccounts(1, true)[0];
        Contact con =  TestUtil.createContacts(1, acc.Id, true)[0];
        Opportunity opp = TestUtil.createOpps(1, acc.Id, true)[0];
        Quote q = TestUtil.createQuotes(1, con.Id, opp.Id, false)[0];
        PriceBookEntry pbe = null;
        try{
        pbe = [Select Id, Pricebook2Id from PricebookEntry 
                                        where PricebookEntry.Product2.Family = 'Perpetual Support' 
                                        and isactive=true Limit 1];
        q.Pricebook2Id = pbe.Pricebook2Id;
        insert q;
        }catch(Exception e){}
        Test.startTest();
            try{
                QuoteLineItem qli = TestUtil.createQLIs(1, q.Id, pbe.Id, false)[0];
                qli.Months__c = 2;
                insert qli;
            }catch(Exception ex){
               // system.assertEquals(ex.getMessage(), 'there must be a Product from the Perpetual License Product Family on the Quote.');
               // System.assert(ex.getMessage().contains('there must be a Product from the Perpetual License Product Family on the Quote.'));
            }
            
        Test.stopTest();
    }
    
    static testMethod void testForQLIInsert(){
        Account acc = TestUtil.createAccounts(1, true)[0];
        Contact con =  TestUtil.createContacts(1, acc.Id, true)[0];
        Opportunity opp = TestUtil.createOpps(1, acc.Id, true)[0];
        Quote q = TestUtil.createQuotes(1, con.Id, opp.Id, false)[0];
        Decimal totalPrice = 0;
        PriceBookEntry pbe=null;
        try{
        pbe = [Select Id, Pricebook2Id, UnitPrice from PricebookEntry 
                                        where PricebookEntry.Product2.Family = 'Perpetual License' 
                                        and isactive=true Limit 1];
        q.Pricebook2Id = pbe.Pricebook2Id;
        insert q;
        }catch(Exception e){}
        List<QuoteLineItem> prodQLIs = TestUtil.createQLIs(2, q.Id, pbe.Id, false);
                PriceBookEntry pbe1 =null;
        try{
        pbe1 = [Select Id, Pricebook2Id, UnitPrice, PricebookEntry.Product2.Perpetual_Support_Discount_Percentage__c from PricebookEntry 
                                        where PricebookEntry.Product2.Family = 'Perpetual Support' 
                                        and isactive=true 
                                        and Pricebook2Id = :pbe.Pricebook2Id Limit 1];
        pbe1.Product2.Perpetual_Support_Discount_Percentage__c = 20;                             
        }catch(Exception e){}
        Test.startTest();
                    try{
            QuoteLineItem supportQLI = TestUtil.createQLIs(1, q.Id, pbe1.Id, false)[0];
            supportQLI.Months__c = 12;
            

                insert supportQLI;
                Set<Id> ids = new Set<Id>();
                for(QuoteLineItem record :prodQLIs){
                    ids.add(record.id);
                }
                prodQLIs = [Select TotalPrice from QuoteLineItem where id in: ids];
                supportQLI = [Select TotalPrice from QuoteLineItem where id = :supportQLI.Id];
                for(QuoteLineItem record : prodQLIs){
                    totalPrice += record.TotalPrice;
                }
                totalPrice = totalPrice * pbe1.Product2.Perpetual_Support_Discount_Percentage__c/100;
        
            }catch(Exception e){
            
            }
        Test.stopTest();
        //system.assertEquals(TotalPrice, supportQLI.TotalPrice);
    }
}