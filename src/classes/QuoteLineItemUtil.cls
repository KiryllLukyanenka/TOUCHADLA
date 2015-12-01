public with sharing class QuoteLineItemUtil {

    public static Set<Id> getQuoteIds( Map<Id, QuoteLineItem> oldMap, List<QuoteLineItem> newQLIs, Boolean isInsert ){
        // get all QuoteIds 
        Set<Id> quoteIds = new Set<Id>();
        for(QuoteLineItem qli : newQLIs) {
            QuoteLineItem oldQLI;
            if( !isInsert ) oldQLI = oldMap.get( qli.Id );
            if( isInsert || (!isInsert && ( oldQLI.Quantity != qli.Quantity || 
                                            oldQLI.Months__c != qli.Months__c ||
                                            oldQLI.Volume_Discount__c != qli.Volume_Discount__c ||
                                            oldQLI.Partner_Margin__c != qli.Partner_Margin__c ||
                                            oldQLI.One_Time_Discount__c != qli.One_Time_Discount__c ||
                                            oldQLI.TotalPrice != qli.TotalPrice)  ) )
                quoteIds.add( qli.QuoteId );
        }
        return quoteIds;
    }
    
    public static List<QuoteLineItem> getAllQLIs( Set<Id> quoteIds ){
        // query for all quoteLineItems for that quote
        List<QuoteLineItem> allQLIs = [ Select Id, QuoteId, TotalPrice, PricebookEntry.Product2Id, PricebookEntry.Product2.Name, 
                                               Product_Family_Formula__c, Months__c, UnitPrice, Quantity, Volume_Discount__c, 
                                               One_Time_Discount__c, Partner_Margin__c, Quote.Perpetual_Total_Volume_Discount__c,
                                               Quote.One_Time_Discount_Percentage__c, Subtotal_Custom__c, Quote.Partner_Margin_Discount__c,
                                               PricebookEntry.Product2.Perpetual_Support_Type__c 
                                        from QuoteLineItem 
                                        where quoteId IN :quoteIds];
        return allQLIs;
    }
    
    public static Map<Id,Product2> getProductsMap( List<QuoteLineItem> allQLIs ) {
        Set<Id> productIds = new Set<Id>();
         //get all productIds
        for( QuoteLineItem qli : allQLIs ) {
            productIds.add( qli.PricebookEntry.Product2Id );
        }
        Map<Id, Product2> allProducts = new Map<Id, Product2> ( [ Select Id, Support_Pecent_per_Year__c,
                                                                         Perpetual_Support_Type__c, Perpetual_Support_Discount_Percentage__c, Product2.Partner_Margin_Applied__c 
                                                                  from Product2 
                                                                  where Id IN :productIds ] );
        return allProducts;
    }
    
    public static Map<Id, List<QuoteLineItem>> constructQuoteMap ( List<QuoteLineItem> allQLIs ){
         // construct a map of quote to all quoteLineItems for that quote
        Map<Id, List<QuoteLineItem>> quoteIdToQLIs = new Map<Id, List<QuoteLineItem>>();
        for(QuoteLineItem qli : allQLIs ) {
            if( quoteIdToQLIs.containsKey( qli.QuoteId ) )
                quoteIdToQLIs.get( qli.QuoteId ).add( qli );
            else
                quoteIdToQLIs.put( qli.QuoteId, new List<QuoteLineItem>{ qli } );
        }
        return quoteIdToQLIs;
    }
    
    public static Set<QuoteLineItem> calculateUnitPriceOnSupport( Map<Id, List<QuoteLineItem>> quoteIdToQLIs, Map<Id, Product2> allProducts ){
        Set<QuoteLineItem> qlisToUpdate = new Set<QuoteLineItem> ();
        // loop through all quotes and its quotelineitems
        for( Id quoteId : quoteIdToQLIs.keySet() ) {
            List<QuoteLineItem> qlis = quoteIdToQLIs.get( quoteId );
            /* Enhancement - Moved to QuoteLineItemFutureUpdate class
            if(qlis.size() == 1  && qlis[0].Product_Family_Formula__c == 'Perpetual Support' &&  allProducts.get( qlis[0].PricebookEntry.Product2Id ).Perpetual_Support_Type__c == 'New Order' && trigger.newMap.containsKey(qlis[0].Id)) {
                trigger.newMap.get(qlis[0].Id).addError('Error: To add '+qlis[0].PricebookEntry.Product2.Name+', there must be a Product from the Perpetual License Product Family on the Quote.');
            }
            */
            
            Decimal totalPrice1 = 0;
            Decimal totalPrice2 = 0;
            //For the Perpetual Support type only
            Decimal supportTotalPrice = 0;

            for(QuoteLineItem qli : qlis ) {
                qli.Partner_Margin__c = qli.Quote.Partner_Margin_Discount__c;
                if( qli.Product_Family_Formula__c == 'Perpetual License' ) {
                    //TODO what's the subtotal for? this field may skip the family type filter
                    if(qli.Subtotal_custom__c!=null) {
                        totalPrice1 += (qli.Subtotal_custom__c );
                        totalPrice2 += (qli.Subtotal_custom__c ); // Enhancement - Total price is changed to Subtotal_Custom__c as per the new requirement
                    }
                    supportTotalPrice += (qli.totalPrice);
                    System.debug('************* Total Price ='+totalPrice1);
                    System.debug('************* Support Total Price ='+supportTotalPrice);
                    System.debug('************* Unit Price ='+qli.UnitPrice);
                }
            }
            
            for(QuoteLineItem qli : quoteIdToQLIs.get( quoteId ) ) {
                Product2 p = allProducts.get( qli.PricebookEntry.Product2Id );
                if( (qli.Product_Family_Formula__c == 'Perpetual Support' && 
                    p.Perpetual_Support_Type__c == 'New Order')) {                    
                    qlisToUpdate.add(productCalculation(qli,p,supportTotalPrice));                    
                }
                else if(qli.Product_Family_Formula__c=='Premium Subscriptions Support'){
                    qlisToUpdate.add(productCalculation(qli,p,totalPrice2)); 
                }
            }
        }
        return qlisToUpdate;
    }
    
    public static QuoteLineItem productCalculation(QuoteLineItem qli, Product2 p, Decimal totalPrice)
    {
        // Enhancement - Moved from bottom (after the calculation) as it would be better to make it 0 before calculation to avoid null pointer exceptions
        
        if(qli.Partner_Margin__c == null) 
        qli.Partner_Margin__c = 0;
        if(qli.One_Time_Discount__c == null) qli.One_Time_Discount__c = 0;
        
        if( qli.Volume_Discount__c >0) 
            qli.Subtotal_custom__c = (totalPrice * (p.Support_Pecent_per_Year__c/100) ) 
                                    * ( qli.Volume_Discount__c /100) * qli.Quantity / 12 * qli.Months__c;
        else 
            qli.Subtotal_custom__c =  (totalPrice * (p.Support_Pecent_per_Year__c/100) ) * qli.Quantity / 12 * qli.Months__c;

        qli.Partner_Margin_Amount__c = ( (totalPrice * (p.Support_Pecent_per_Year__c/100)) * (1- qli.Volume_Discount__c )) 
                                        * (1- (qli.One_Time_Discount__c/100) ) * ( qli.Partner_Margin__c/100 ) * qli.Quantity / 12 * qli.Months__c;
                                        
        qli.One_Time_Discount_Amount__c = ( (totalPrice * (p.Support_Pecent_per_Year__c/100)) * (1- (qli.Volume_Discount__c/100) )) 
                                            * ( qli.One_Time_Discount__c/100 ) * qli.Quantity / 12 * qli.Months__c;
        //TODO here is the place to change the percentage
        qli.Total_Price_Static__c =  ((totalPrice * (p.Support_Pecent_per_Year__c/100) *(1 - (qli.Volume_Discount__c/100) ) ) 
                                    * ( 1 - (qli.One_Time_Discount__c/100) ) * (1 - (qli.Partner_Margin__c/100) )) * qli.Quantity / 12 * qli.Months__c;
        qli.Quantity = 1;
                                                                                    
        Decimal unitPrice = ( ( totalPrice * p.Support_Pecent_per_Year__c ) 
                                / 1200 ) 
                              * qli.Months__c;
        
        /* Enhancement - Moved to top (before calcuations) as it would be better to make it 0 before calculation to avoid null pointer exceptions
        if(qli.Partner_Margin__c == null) qli.Partner_Margin__c = 0;
        if(qli.One_Time_Discount__c == null) qli.One_Time_Discount__c = 0;
        */
        
        qli.UnitPrice = unitPrice * (1 - (qli.Volume_Discount__c/100)) * 
                                    (1 - (qli.One_Time_Discount__c/100)) * 
                                    (1 - (qli.Partner_Margin__c/100));
        System.debug('************* Unit Price ='+unitPrice);
        
        qli.UnitPrice = totalPrice * (p.Perpetual_Support_Discount_Percentage__c/100);
        
        return qli;
    }
}