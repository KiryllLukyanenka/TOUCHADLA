trigger QuoteLineItemAfterTrigger on QuoteLineItem (after insert, after update, after delete) {
    
    Set<Id> quoteIds = new Set<Id>();
    
    if((trigger.isInsert || trigger.isUpdate) && trigger.isAfter)
    {
        quoteIds = QuoteLineItemUtil.getQuoteIds( trigger.oldMap, trigger.new, trigger.isInsert );
        
        // Enhancement - A future method will be called to avoid SELF REFERENCE FROM TRIGGER exception
        //               and a counter is used to prevent the future method being called from a future method
        if(QuoteLineItemFutureUpdate.counter==0 && trigger.isAfter && trigger.isUpdate)
        {
            QuoteLineItemFutureUpdate.validatePerpetualLicenseFromUpdate(quoteIds);
            QuoteLineItemFutureUpdate.futureMethod(quoteIds);
        }
        else
        {
            QuoteLineItemFutureUpdate.doCalculations(quoteIds,true);
        }
        
        //QuoteLineItemFutureUpdate.counter++;
    }
    
    else if(trigger.isDelete && trigger.isAfter)
    {
        for(Id i : trigger.oldMap.keyset())
        {
            if( trigger.oldMap.get(i).Product_Family_Formula__c == 'Perpetual License' ||
                trigger.oldMap.get(i).Product_Family_Formula__c == 'On-Premise Subscription' ||
                trigger.oldMap.get(i).Product_Family_Formula__c == 'SaaS Subscription' )
            {
                quoteIds.add(trigger.oldMap.get(i).QuoteId);
            }
        }
        system.debug('----->'+quoteIds.size());
        if(quoteIds.size()>0)
        {
            quoteLineItemFutureUpdate.doCalculations(quoteIds,false);
        }
    }
    
    // Enhancement - Following code has been moved to QuoteLineItemFutureUpdate Class
    /*
    if( !quoteIds.isEmpty() ) {
        List<QuoteLineItem> allQLIs = QuoteLineItemUtil.getAllQLIs( quoteIds );
        
        Map<Id, List<QuoteLineItem>> quoteIdToQLIs = QuoteLineItemUtil.constructQuoteMap( allQLIs );
        
        Map<Id, Product2> allProducts = QuoteLineItemUtil.getProductsMap( allQLIs );
        
        Set<QuoteLineItem> qlisToUpdate = QuoteLineItemUtil.calculateUnitPriceOnSupport( quoteIdToQLIs, allProducts );
        //System.debug('----->After Update Quote Line Item Trigger - qlistToUpdate size: '+new List<QuoteLineItem> ( qlisToUpdate )[0]);
        if( !qlisToUpdate.isEmpty() ){ System.debug('=====>'+qlisToUpdate);
            update new List<QuoteLineItem> ( qlisToUpdate );}
    }
    */
}