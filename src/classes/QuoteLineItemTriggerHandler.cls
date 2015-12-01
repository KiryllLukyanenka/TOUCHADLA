public with sharing class QuoteLineItemTriggerHandler {
    public static Quote_Discount_Settings__c quoteSetting = Quote_Discount_Settings__c.getInstance();

    public static void afterInsert(List<QuoteLineItem> newList) {
        updateQuoteWithDiscounts(newList);
        //updateTotalPriceCustom(newList);
       
    }

    public static void afterUpdate(List<QuoteLineItem> newList, Map<Id, QuoteLineItem> oldMap) {
        updateQuoteWithDiscounts(newList);
        //updateTotalPriceCustom(newList);
    }

    public static void afterDelete(List<QuoteLineItem> oldList) {
        updateQuoteWithDiscounts(oldList);
        //updateTotalPriceCustom(oldList);
    }
    
    /*private static void updateTotalPriceCustom(List<QuoteLineItem> newList) {
      
        Set<Id> quoteLineIdSet = new Set<Id>();
        Map<Id, Double> quoteTotalPriceMap = new Map<Id, Double>();
        List<Quote> quoteToUpdateTotalPriceCustom = new List<Quote>();
        
        for (QuoteLineItem item : newList) {
            if (item.QuoteId != null) {
                quoteLineIdSet.add(item.QuoteId);
            }
        }
        
        System.Debug('Quote TtoalPrice : ' + quoteLineIdSet);
        
        for (AggregateResult r : [SELECT QuoteId, sum(TotalPrice) 
                                       FROM QuoteLineItem
                                      WHERE quoteid IN :quoteLineIdSet
                                        AND PricebookEntry.Name NOT IN(:quoteSetting.Partner_Margin_Discount_Product__c, 
                                                                  :quoteSetting.Federal_Distributor_Discount_Product__c)
                                   group by quoteid]) {
            quoteTotalPriceMap.put((Id)r.get('QuoteId'),(Double)r.get('expr0'));
                                                   
        }
        
        System.Debug('Quote Total Price Map : ' + quoteTotalPriceMap);
        
        for (Quote q : [select Id, Total_Price_Custom__c from Quote where Id IN :quoteLineIdSet]) {
        
            Double totalAmount = quoteTotalPriceMap.get(q.Id);
            q.Total_Price_Custom__c = totalAmount;
            quoteToUpdateTotalPriceCustom.add(q);
        
        }
        
        update quoteToUpdateTotalPriceCustom;
    }*/


    private static void updateQuoteWithDiscounts(List<QuoteLineItem> newList) {
        Map<Id, Quote> quoteToUpdateMap = new Map<Id, Quote>();
        List<QuoteLineItem> itemsToTestList = new List<QuoteLineItem>();
        Set<Id> quoteIdSet = new Set<Id>();

        for (QuoteLineItem item : newList) {
            if (item.QuoteId != null) {
                quoteIdSet.add(item.QuoteId);
            }
        }

        if (quoteSetting != null) {
            for (QuoteLineItem item : [SELECT Id,
                                        QuoteId,
                                        TotalPrice,
                                        PricebookEntryId,
                                        PricebookEntry.Name
                                 FROM QuoteLineItem
                                 WHERE QuoteId IN :quoteIdSet
                                   AND PricebookEntry.Name NOT IN(:quoteSetting.Partner_Margin_Discount_Product__c, 
                                                                  :quoteSetting.Federal_Distributor_Discount_Product__c)]) {
                itemsToTestList.add(item);
            }
        }

        for (QuoteLineItem item : itemsToTestList) {
            if (!quoteToUpdateMap.containsKey(item.QuoteId)) {
                quoteToUpdateMap.put(item.QuoteId, new Quote(Id = item.QuoteId, One_Time_Discount__c = 0));
        // check why setting to 0 fails
            }
        
            if (quoteSetting.One_Time_Discount_Product__c != null &&
                item.PricebookEntry.Name == quoteSetting.One_Time_Discount_Product__c) {
                quoteToUpdateMap.get(item.QuoteId).One_Time_Discount__c = item.TotalPrice < 0 ? -(item.TotalPrice) : item.TotalPrice;
            }
            if (quoteSetting.Partner_Margin_Discount_Product__c == null ||
                item.PricebookEntry.Name != quoteSetting.Partner_Margin_Discount_Product__c) {
                if (quoteToUpdateMap.get(item.QuoteId).Total_Price_Custom__c == null) {
                    quoteToUpdateMap.get(item.QuoteId).Total_Price_Custom__c = 0;
                }
                quoteToUpdateMap.get(item.QuoteId).Total_Price_Custom__c += item.TotalPrice;
            }
        }
        System.debug('quotetoUpdateMap : ' + quoteToUpdateMap);
        System.debug('quotetoUpdateMap size :'+ quoteToUpdateMap.size());
        if (!quoteToUpdateMap.isEmpty()) {
            update quoteToUpdateMap.values();
        }
    }
}