trigger QuoteAfterInsertAfterUpdate on Quote (after insert, after update) {
    if(trigger.isUpdate) {
        Set<Id> quoteIds = new Set<Id>();
        
        // Enhancement - have a quote map to get the opportunity stage value as cross object fields will be null in trigger.new
        Map<Id,Quote> quoteOptyMap = new Map<Id,Quote>([Select Opportunity.StageName from Quote where Id in :trigger.newMap.keyset()]);
        
        for( Quote q : trigger.new ) {
            Quote oldQuote = trigger.oldMap.get(q.Id);
            if((oldQuote.One_Time_Discount_Percentage__c != q.One_Time_Discount_Percentage__c 
                || oldQuote.Partner_Margin_Discount__c != q.Partner_Margin_Discount__c)
               && (quoteOptyMap.get(q.Id).Opportunity.StageName != 'L10 - Closed Lost' 
                   && quoteOptyMap.get(q.Id).Opportunity.StageName != 'W10 - Closed/Won'
                   && quoteOptyMap.get(q.Id).Opportunity.StageName != 'I12 - Inactive'))
                quoteIds.add( q.Id );
        }
        List<QuoteLineItem> qlis = QuoteLineItemUtil.getAllQLIs( quoteIds );
        List<QuoteLineItem> qlisToUpdate = new List<QuoteLineItem>();
        Map<Id, Product2> allProducts = QuoteLineItemUtil.getProductsMap( qlis );
        if( !qlis.isEmpty() ) {
        
            for(QuoteLineItem q: qlis ) {
                Quote quote = trigger.newMap.get(q.quoteId);
                // Enhancement - No need to copy over one time discount from quote to line item in trigger
                //q.One_Time_Discount__c = trigger.newMap.get(q.quoteId).One_Time_Discount_Percentage__c ;
                if(quote.RecordTypeId == '01280000000Lref' 
                        /*&& !((q.Product_Family_Formula__c == 'Perpetual Support' // - Enhancement - New CR - Perpetual support new order product and premium subscriptions support should always have partner margin discount as zero
                        && q.PricebookEntry.Product2.Perpetual_Support_Type__c == 'New Order')
                        || (q.Product_Family_Formula__c=='Premium Subscriptions Support'))*/
                // Enhancement - No need to check for Partner Margin Applied as per the new requirement, all the line items should be copied with the value from Quote
                //&& allProducts.get(q.PricebookEntry.Product2Id ).Partner_Margin_Applied__c == 'True'
                ) {
                    q.Partner_Margin__c = trigger.newMap.get(q.quoteId).Partner_Margin_Discount__c;
                    // Enhancement - No need to copy over one time discount from quote to line item in trigger
                    //q.One_Time_Discount__c = trigger.newMap.get(q.quoteId).One_Time_Discount_Percentage__c ;
                    if(q.Partner_Margin__c == null ) q.Partner_Margin__c = 0;
                    
                    qlisToUpdate.add(q);
                    // Enhancement - No need to copy over one time discount from quote to line item in trigger
                    //if(q.One_Time_Discount__c == null ) q.One_Time_Discount__c = 0;
                } //else q.Partner_Margin__c = 0; - Enhancement - New CR - No need to make it zero
            }
            //update qlis;
            if(qlisToUpdate.size()>0)
            {
                system.debug('======>'+qlisToUpdate);
                update qlisToUpdate;
            }
        }
    }
}