public class QuoteLineItemFutureUpdate
{
    public static integer counter = 0;
    
    // Enhancement - This method will be called on the after insert event of Quote Line Item to avoid SELF REFERENCE FROM TRIGGER exception
    @future
    public static void futureMethod(Set<Id> quoteIds)
    {
        doCalculations(quoteIds, false);
    }
    
    // Enhancement - The method which does all the calculations for Line items that are associated with Products with Perpetual Support Type as New Order
    public static void doCalculations(Set<Id> quoteIds, Boolean isInsert)
    {
        if( !quoteIds.isEmpty() ) 
        {
            List<QuoteLineItem> allQLIs = QuoteLineItemUtil.getAllQLIs( quoteIds );
            
            Map<Id, List<QuoteLineItem>> quoteIdToQLIs = QuoteLineItemUtil.constructQuoteMap( allQLIs );
            
            Map<Id, Product2> allProducts = QuoteLineItemUtil.getProductsMap( allQLIs );
            
            if(isInsert)
            {
                validatePerpetualLicense(quoteIdToQLIs, allProducts);
            }
            
            Set<QuoteLineItem> qlisToUpdate = QuoteLineItemUtil.calculateUnitPriceOnSupport( quoteIdToQLIs, allProducts );
            
            if( !qlisToUpdate.isEmpty() )
            { 
                QuoteLineItemFutureUpdate.counter = 1;
                update new List<QuoteLineItem> ( qlisToUpdate );
            }
        }
    }
    
    public static void validatePerpetualLicense(Map<Id, List<QuoteLineItem>> quoteIdToQLIs, Map<Id, Product2> allProducts)
    {
        for( Id quoteId : quoteIdToQLIs.keySet() ) {
            List<QuoteLineItem> qlis = quoteIdToQLIs.get( quoteId );
            if(qlis.size() == 1  && qlis[0].Product_Family_Formula__c == 'Perpetual Support' &&  allProducts.get( qlis[0].PricebookEntry.Product2Id ).Perpetual_Support_Type__c == 'New Order' && trigger.newMap.containsKey(qlis[0].Id)) {
                trigger.newMap.get(qlis[0].Id).addError('Error: To add '+qlis[0].PricebookEntry.Product2.Name+', there must be a Product from the Perpetual License Product Family on the Quote.');
            }
        }
    }
    
    public static void validatePerpetualLicenseFromUpdate(Set<Id> quoteIds)
    {
            if( !quoteIds.isEmpty() )
            {
                List<QuoteLineItem> allQLIs = QuoteLineItemUtil.getAllQLIs( quoteIds );
                
                Map<Id, List<QuoteLineItem>> quoteIdToQLIs = QuoteLineItemUtil.constructQuoteMap( allQLIs );
                
                Map<Id, Product2> allProducts = QuoteLineItemUtil.getProductsMap( allQLIs );
                
                validatePerpetualLicense(quoteIdToQLIs, allProducts);
            }
    }
}