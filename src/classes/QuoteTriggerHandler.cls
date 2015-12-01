/****************************************************************
* Calculate discount logic for OneTime, Partner, and Federal*
*
* Modified History
* --------------------------------------------
* Justin Wong - 08/06/2015:  Added OneTime and Federal Discount Logic.
                             Refactored the logic.
*****************************************************************/

public with sharing class QuoteTriggerHandler {

    public static Quote_Discount_Settings__c quoteSetting = Quote_Discount_Settings__c.getInstance();
    
    public static void afterInsert(List<Quote> newList) {
        updateDiscountLineItems(newList);
    }
    
    public static void afterUpdate(List<Quote> newList, Map<Id, Quote> oldMap) {
        updateDiscountLineItems(newList);
    }
    
    //original method; commented out by 8/14/2015 by Justin Wong
    /*private static void updateDiscountLineItems_old(List<Quote> newList) {

    Map<Id, List<QuoteLineItem>> quoteItemMap =
      new Map<Id, List<QuoteLineItem>>();
    List<QuoteLineItem> itemsToUpdateList = new List<QuoteLineItem>();
    Map<String, Product2> productMap = new Map<String, Product2>();
    Map<String, Map<Id, Map<String, PricebookEntry>>> priceMap =
      new Map<String, Map<Id, Map<String, PricebookEntry>>>();
    Set<String> discountNameSet = new Set<String>();
    Boolean hasPartnerDiscount;

    if (quoteSetting != null) {
      if (quoteSetting.One_Time_Discount_Product__c != null) {
        discountNameSet.add(quoteSetting.One_Time_Discount_Product__c);
      }
      if (quoteSetting.Partner_Margin_Discount_Product__c != null) {
        discountNameSet.add(quoteSetting.Partner_Margin_Discount_Product__c);
      }
    }

    if (quoteSetting != null) {
      for (Product2 p : [SELECT Id,
                                Name
                         FROM Product2
                         WHERE Name =
                          :quoteSetting.Partner_Margin_Discount_Product__c
                         OR Name =
                          :quoteSetting.One_Time_Discount_Product__c]) {
        productMap.put(p.Name, p);
      }
    }

    for (QuoteLineItem item : [SELECT Id,
                                      QuoteId,
                                      Quantity,
                                      UnitPrice,
                                      TotalPrice,
                                      PricebookEntryId,
                                      PricebookEntry.Name
                               FROM QuoteLineItem
                               Where QuoteId IN : newList]) {
      if (!quoteItemMap.containsKey(item.QuoteId)) {
        quoteItemMap.put(item.QuoteId, new List<QuoteLineItem>());
      }

      quoteItemMap.get(item.QuoteId).add(item);
    }

    for (PricebookEntry entry :[SELECT Id,
                                       Product2Id,
                                       Product2.Name,
                                       Pricebook2Id,
                                       CurrencyIsoCode
                                FROM PricebookEntry
                                WHERE Product2.Name IN :discountNameSet]) {
      if (!priceMap.containsKey(entry.Product2.Name)) {
        priceMap.put(entry.Product2.Name,
          new Map<Id, Map<String, PricebookEntry>>());
      }
      if (!priceMap.get(entry.Product2.Name).containsKey(entry.Pricebook2Id)) {
        priceMap.get(entry.Product2.Name).put(entry.Pricebook2Id,
          new Map<String, PricebookEntry>());
      }

      priceMap.get(entry.Product2.Name).get(entry.Pricebook2Id).put(
        entry.CurrencyIsoCode, entry);
    }

    for (Quote q : newList) {
      hasPartnerDiscount = false;

      if (quoteItemMap.containsKey(q.Id)) {
        for (QuoteLineItem item : quoteItemMap.get(q.Id)) {
          system.debug(quoteSetting);
          system.debug(quoteSetting.Partner_Margin_Discount_Product__c);
          system.debug(item.PricebookEntry.Name);

          if (quoteSetting != null &&
              quoteSetting.Partner_Margin_Discount_Product__c ==
                item.PricebookEntry.Name) {
            hasPartnerDiscount = true;

            if (item.Quantity != 1 ||
                -(item.UnitPrice) != q.Partner_Margin_Amount__c) {
              item.Quantity = 1;
              item.UnitPrice = -(q.Partner_Margin_Amount__c);
              itemsToUpdateList.add(item);
            }
            break;

          }
        }

        system.debug(hasPartnerDiscount);
        system.debug(q.Partner_Margin_Amount__c);
        system.debug(quoteSetting.Partner_Margin_Discount_Product__c);
        system.debug(priceMap);
        system.debug(q.Pricebook2Id);

        if (!hasPartnerDiscount && q.Partner_Margin_Amount__c != null &&
            q.Partner_Margin_Amount__c > 0 &&
            priceMap.containsKey(
              quoteSetting.Partner_Margin_Discount_Product__c) &&
            priceMap.get(
              quoteSetting.Partner_Margin_Discount_Product__c).containsKey(
                q.Pricebook2Id) &&
            priceMap.get(
              quoteSetting.Partner_Margin_Discount_Product__c).get(
                q.Pricebook2Id).containsKey(q.CurrencyIsoCode)) {
          itemsToUpdateList.add(new QuoteLineItem(
            QuoteId = q.Id,
            UnitPrice = -(q.Partner_Margin_Amount__c),
            Quantity = 1,
            PricebookEntryId = priceMap.get(
              quoteSetting.Partner_Margin_Discount_Product__c).get(
                q.Pricebook2Id).get(q.CurrencyIsoCode).Id));
          system.debug(priceMap.get(
              quoteSetting.Partner_Margin_Discount_Product__c).get(
                q.Pricebook2Id).get(q.CurrencyIsoCode));
          system.debug(q.CurrencyIsoCode);
        }
      }
    }

    if (!itemsToUpdateList.isEmpty()) {
      upsert itemsToUpdateList;
    }
  }*/
    //Create/Update discount line at the quotelineitem object
    private static void updateDiscountLineItems(List<Quote> newList) {

        //Map<Id, List<QuoteLineItem>> quoteItemMap = new Map<Id, List<QuoteLineItem>>();
        List<QuoteLineItem> itemsToUpdateList = new List<QuoteLineItem>();
        //Map<String, Product2> productMap = new Map<String, Product2>();
        //Map<String, Map<Id, Map<String, PricebookEntry>>> priceMap = new Map<String, Map<Id, Map<String, PricebookEntry>>>();
        //Set<String> discountNameSet = new Set<String>();
        
        Map<Id, List<QuoteLineItem>> quoteItemMap = getQuoteLine(newList);
        Set<String> discountNameSet = getDiscountSet();
        Map<String, Product2> productMap = getDiscountProduct();
        Map<String, Map<Id, Map<String, PricebookEntry>>> priceMap = getProductPriceMap(discountNameSet);
        
        Boolean hasPartnerDiscount;
        Boolean hasOneTimeDiscount;
        //Boolean hasFederalDiscount;
    
        system.debug('quoteItemMap: ' + quoteItemMap);
    
        for (Quote q : newList) {
          hasPartnerDiscount = false;
          hasOneTimeDiscount = false;
          //hasFederalDiscount = false;
    
          if (quoteItemMap.containsKey(q.Id)) {
            for (QuoteLineItem item : quoteItemMap.get(q.Id)) {
              system.debug('Quote Setting: '+ quoteSetting);
              system.debug('Partner Quote Setting: ' + quoteSetting.Partner_Margin_Discount_Product__c);
              system.debug('Item Pricebook; ' + item.PricebookEntry.Name);
    
              if (quoteSetting != null &&
                  quoteSetting.Partner_Margin_Discount_Product__c ==
                    item.PricebookEntry.Name ) {
                hasPartnerDiscount = true;
                
                if (item.Quantity != 1 ||
                    -(item.UnitPrice) != q.Partner_Margin_Amount__c) {
                  item.Quantity = 1;
                  item.UnitPrice = -(q.Partner_Margin_Amount__c);
                  itemsToUpdateList.add(item);
                  system.debug('itemstoUpdate1: ' + itemsToUpdateList);
                }
                //break;
    
              }
              
              if (quoteSetting != null &&
                 quoteSetting.One_Time_Discount_Product__c ==
                    item.PricebookEntry.Name) {
                hasOneTimeDiscount = true;
         
               if (item.Quantity != 1 ||
                    -(item.UnitPrice) != q.One_Time_Discount__c) {
                  item.Quantity = 1;
                  item.UnitPrice = -(q.One_Time_Discount__c==null?0:q.One_Time_Discount__c);
                  itemsToUpdateList.add(item);
                  system.debug('OneTimeitemstoUpdate2: ' + itemsToUpdateList);
                }
                //break;
    
              }
              
              /*if (quoteSetting != null &&
                 quoteSetting.Federal_Distributor_Discount_Product__c ==
                    item.PricebookEntry.Name) {
                hasFederalDiscount = true;
         
               if (item.Quantity != 1 ||
                    -(item.UnitPrice) != q.Federal_Distributor_Margin_Amount__c) {
                  item.Quantity = 1;
                  item.UnitPrice = -(q.Federal_Distributor_Margin_Amount__c==null?0:q.Federal_Distributor_Margin_Amount__c);
                  itemsToUpdateList.add(item);
                  system.debug('FederalDisti: ' + itemsToUpdateList);
                }
                //break;
    
              }*/
            }
    
            system.debug('Partner Discount: ' + hasPartnerDiscount);
            system.debug('Total Price Custom: ' + q.Total_Price_Custom__c);
            system.debug('Partner Discount Amount: ' + q.Partner_Margin_Amount__c);
    
            if (!hasPartnerDiscount && q.Partner_Margin_Amount__c != null &&
                q.Partner_Margin_Amount__c > 0 &&
                priceMap.containsKey(
                  quoteSetting.Partner_Margin_Discount_Product__c) &&
                priceMap.get(
                  quoteSetting.Partner_Margin_Discount_Product__c).containsKey(
                    q.Pricebook2Id) &&
                priceMap.get(
                  quoteSetting.Partner_Margin_Discount_Product__c).get(
                    q.Pricebook2Id).containsKey(q.CurrencyIsoCode)) {
              itemsToUpdateList.add(new QuoteLineItem(
                QuoteId = q.Id,
                UnitPrice = -(q.Partner_Margin_Amount__c),
                Quantity = 1,
                PricebookEntryId = priceMap.get(
                  quoteSetting.Partner_Margin_Discount_Product__c).get(
                    q.Pricebook2Id).get(q.CurrencyIsoCode).Id));
              system.debug(priceMap.get(
                  quoteSetting.Partner_Margin_Discount_Product__c).get(
                    q.Pricebook2Id).get(q.CurrencyIsoCode));
              system.debug(q.CurrencyIsoCode);
            }
            
            system.debug('OneTime Discount: ' + hasOneTimeDiscount);
            system.debug('OneTime Discount Amount: ' + q.One_Time_Discount__c);
            system.debug('OneTime Quote Setting: ' + quoteSetting.One_Time_Discount_Product__c);
            
            if (!hasOneTimeDiscount && q.One_Time_Discount__c != null &&
                q.One_Time_Discount__c > 0 &&
                priceMap.containsKey(
                  quoteSetting.One_Time_Discount_Product__c) &&
                priceMap.get(
                  quoteSetting.One_Time_Discount_Product__c).get(
                    q.Pricebook2Id).containsKey(q.CurrencyIsoCode)) {
              itemsToUpdateList.add(new QuoteLineItem(
                QuoteId = q.Id,
                UnitPrice = -(q.One_Time_Discount__c ),
                Quantity = 1,
                PricebookEntryId = priceMap.get(
                  quoteSetting.One_Time_Discount_Product__c).get(
                    q.Pricebook2Id).get(q.CurrencyIsoCode).Id));
              system.debug('OneTimeDiscount PriceMap: ' + priceMap.get(
                  quoteSetting.One_Time_Discount_Product__c).get(
                    q.Pricebook2Id).get(q.CurrencyIsoCode));
              system.debug('One Time Item: ' + q.CurrencyIsoCode);
               system.debug('itemstoUpdate3: ' + itemsToUpdateList);
            }
            //commented out -- to be released later.
            /*if (!hasFederalDiscount && q.Federal_Distributor_Margin_Amount__c != null &&
                q.Federal_Distributor_Margin_Amount__c > 0 &&
                priceMap.containsKey(
                  quoteSetting.Federal_Distributor_Discount_Product__c) &&
                priceMap.get(
                  quoteSetting.Federal_Distributor_Discount_Product__c).get(
                    q.Pricebook2Id).containsKey(q.CurrencyIsoCode)) {
              itemsToUpdateList.add(new QuoteLineItem(
                QuoteId = q.Id,
                UnitPrice = -(q.Federal_Distributor_Margin_Amount__c),
                Quantity = 1,
                PricebookEntryId = priceMap.get(
                  quoteSetting.Federal_Distributor_Discount_Product__c).get(
                    q.Pricebook2Id).get(q.CurrencyIsoCode).Id));
              system.debug('FederalDiscount PriceMap: ' + priceMap.get(
                  quoteSetting.One_Time_Discount_Product__c).get(
                    q.Pricebook2Id).get(q.CurrencyIsoCode));
              system.debug('Federal Item: ' + q.CurrencyIsoCode);
               system.debug('FederalitemstoUpdate3: ' + itemsToUpdateList);
            }*/
          }
          
        }
        system.debug('ItemsToUpdateList : ' + itemsToUpdateList.size() + ' ' + itemsToUpdateList);
        if (!itemsToUpdateList.isEmpty()) {
          upsert itemsToUpdateList;
        }
    }
    
    private static Map<String, Product2> getDiscountProduct(){
        Map<String, Product2> discountProductMap = new Map<String, Product2>();
        if (quoteSetting != null) {
            for (Product2 p : [SELECT Id, Name FROM Product2 
                                WHERE Name = :quoteSetting.Partner_Margin_Discount_Product__c 
                                   OR Name = :quoteSetting.One_Time_Discount_Product__c]) {
               discountProductMap.put(p.Name, p);
            }
        }
        
        return discountProductMap;
    }
    
    private static Map<String, Map<Id, Map<String, PricebookEntry>>> getProductPriceMap(Set<String> discountProd) {
        Map<String, Map<Id, Map<String, PricebookEntry>>> productPriceMap = new Map<String, Map<Id, Map<String, PricebookEntry>>>();
        
        for (PricebookEntry entry :[SELECT Id,
                                           Product2Id,
                                           Product2.Name,
                                           Pricebook2Id,
                                           CurrencyIsoCode
                                    FROM PricebookEntry
                                    WHERE Product2.Name IN :discountProd]) {
          if (!productPriceMap.containsKey(entry.Product2.Name)) {
            productPriceMap.put(entry.Product2.Name,
              new Map<Id, Map<String, PricebookEntry>>());
          }
          if (!productPriceMap.get(entry.Product2.Name).containsKey(entry.Pricebook2Id)) {
            productPriceMap.get(entry.Product2.Name).put(entry.Pricebook2Id, new Map<String, PricebookEntry>());
          }
    
          productPriceMap.get(entry.Product2.Name).get(entry.Pricebook2Id).put(entry.CurrencyIsoCode, entry);
        }
        
        return productPriceMap;
    }
    
    private static Map<Id, List<QuoteLineItem>> getQuoteLine(List<Quote> newQuoteList) {
        Map<Id, List<QuoteLineItem>> quoteLineMap = new Map<Id, List<QuoteLineItem>>();
        
        for (QuoteLineItem item : [SELECT Id,
                                          QuoteId,
                                          Quantity,
                                          UnitPrice,
                                          TotalPrice,
                                          PricebookEntryId,
                                          PricebookEntry.Name
                                   FROM QuoteLineItem
                                   Where QuoteId IN : newQuoteList]) {
          if (!quoteLineMap.containsKey(item.QuoteId)) {
            quoteLineMap.put(item.QuoteId, new List<QuoteLineItem>());
          }
    
          quoteLineMap.get(item.QuoteId).add(item);
        }
    
        return quoteLineMap;
    }
    private static Set<String> getDiscountSet() {
        Set<String> discountQuoteName = new Set<String>();
        
        if (quoteSetting != null) {
            if (quoteSetting.One_Time_Discount_Product__c != null) {
                discountQuoteName.add(quoteSetting.One_Time_Discount_Product__c);
            }
            if (quoteSetting.Partner_Margin_Discount_Product__c != null) {
               discountQuoteName.add(quoteSetting.Partner_Margin_Discount_Product__c);
            }
            /*if (quoteSetting.Federal_Distributor_Discount_Product__c != null) {
               discountQuoteName.add(quoteSetting.Federal_Distributor_Discount_Product__c);
            }*/
        }
        
        return discountQuoteName;
    }  
}