public with sharing class QuoteLinePageExt {
	
	// for test method code coverage
	public QuoteLinePageExt(String forTestMethod){
		
	}
	
 /*   public String s{get;set;}
    public String ids {get;set;}
    Map<Id,Product2> prodMap;
    public Map<String,PricebookEntry> priceMap{get;set;}
    List<String> idList {get;set;}
    public String recId{get;set;}
    Quote qObj;
    public List<productWrapper> wrapperList {get;set;}
    public String  pbId {get;set;}
    public String  recordTypeId {get;set;}
    public Boolean  custType {get;set;}
    Map <String,productWrapper> PerpetualSupportItemMap;  
    public String val {get;set;}
    public String PBIds {get;set;}
    public Boolean editFlag {get;set;}
    public Boolean disPlayPB {get;set;}
    Map <String,Product2> PerpetualSupport;
    public String  pbString {get;set;}
    transient Schema.DescribeSObjectResult R;
    transient Map<Id,Schema.RecordTypeInfo> rtMapById;
    List<QuoteLineItem> editList;
    public List<boolean> dispSPrice {get;set;}
    public boolean isSaleInputPrice;
    public QuoteLinePageExt(ApexPages.StandardController controller)
    {
        recId=controller.getId();
        editFlag=false;
        disPlayPB=false;
        //val=System.currentPageReference().getParameters().get('val');
        if(System.currentPageReference().getParameters().get('srch')!=null)
        {
            String srch =System.currentPageReference().getParameters().get('search');
            String Field =System.currentPageReference().getParameters().get('field');
            String Oper =System.currentPageReference().getParameters().get('opr');
            String content =System.currentPageReference().getParameters().get('val');
        if(System.test.isRunningTest()==false)  
        {
           if(Field!=null && Oper!=null && content!=null && content!='' &&Oper!=''&&Field!='' )     
           {
            val=new PageReference('/ui/quote/SelectSearch?PricebookEntrycol0='+Field+'&PricebookEntryoper0='+Oper+'&PricebookEntryfval0='+content+'&sFltrFields=1&nooverride=1&addTo='+recId+'&offset=0&search='+srch+'&isdtp=mn').getContent().ToString();
           }
           else
            val=new PageReference('/ui/quote/SelectSearch?sFltrFields=1&nooverride=1&addTo='+recId+'&offset=0&search='+srch+'&isdtp=mn').getContent().ToString();
        }   
        }
        qObj= (Quote) controller.getRecord();
        R = Quote.SObjectType.getDescribe();
        rtMapById = R.getRecordTypeInfosById();
        if(recId!=null && System.test.isRunningTest()==false)
        {
        s=new PageReference('/ui/quote/SelectSearch?addTo='+recId+'&retURL=%2F'+recId+'&nooverride=1&isdtp=mn').getContent().ToString();
        pbId=qObj.Pricebook2Id;
        recordTypeId=qObj.RecordTypeId;
        }
        ids=System.currentPageReference().getParameters().get('ids');
        //s= new PageReference('/sfc/#search').getContent().ToString();
        if(ids!=null)
        {
             wrapperList = new List<productWrapper>();
            idList=ids.split('-');
            pbId=qObj.Pricebook2Id;
            recordTypeId=qObj.RecordTypeId;
        if(rtMapById.get(recordTypeId).getName().contains('Customer'))
            custType=true;
            else
            custType=false;
            
            getNewProdInfo();
        }
    }
    
    public void editQuoteLine()
    {
        PerpetualSupportItemMap= new Map <String,productWrapper> ();
        pbId=qObj.Pricebook2Id;
        editFlag=true;
        recordTypeId=qObj.RecordTypeId;
         wrapperList = new List<productWrapper>();
        if(rtMapById.get(recordTypeId).getName().contains('Customer'))
        custType=true;
        else
        custType=false;
        Map<String,QuoteLineItem> quoteMap = new Map<String,QuoteLineItem>();
        priceMap = new Map<String,PricebookEntry>();
        List<String> prodList = new List<string>();
        List<PricebookEntry> PbList;
        List<QuoteLineItem> qLine=[Select q.Partner_Margin_Applied__c ,q.Volume_Discount__c ,q.Support_Percent__c,q.Number_Of_Yrs__c,q.Quantity,q.UnitPrice,q.QuoteId, q.Product_Type__c, q.Product_Family__c, q.PricebookEntryId,q.PricebookEntry.Product2Id, q.ListPrice, q.LineNumber, q.Id, q.Field_Discount__c, q.Field_Discount_Amount__c, q.Discount, q.Description From QuoteLineItem q where q.QuoteId=:recId ];
        for(QuoteLineItem q :qLine)
        {
            quoteMap.put(q.PricebookEntryId,q);
            prodList.add(q.PricebookEntry.Product2Id);
        }
        if(!quoteMap.isempty())
        PbList=[Select p.UseStandardPrice,p.Product2.Name, p.UnitPrice, p.Product2Id, p.Pricebook2Id, p.Name, p.IsActive, p.Id, p.CurrencyIsoCode From PricebookEntry p where id in:quoteMap.KeySet() and p.IsActive=true];
        if(!PbList.isempty())
        {
            for(PricebookEntry pbe: PbList)
            priceMap.put(pbe.Product2Id,pbe);
        }
        
            prodMap=new Map<Id,Product2>([Select p.Partner_Margin_Applied__c,p.Volume_Discount_Applied__c,p.One_Time_Discount_Applied__c, p.Support_Pecent_per_Year__c, p.Subscription_Duration__c, p.Name, p.License_Type__c, p.Id, p.Family, p.Description, p.CurrencyIsoCode From Product2 p where p.id in :prodList order by p.family]);
        
        for(Product2 p:prodMap.values())
        {
                QuoteLineItem q =  quoteMap.get(priceMap.get(p.Id).Id);
                calculate(p,q,false);
        }
    
    }
    
    
    public void getNewProdInfo()
    {
        PerpetualSupportItemMap= new Map <String,productWrapper> ();
        Boolean oneTimeFlag=false;
        prodMap=new Map<Id,Product2>([Select p.Partner_Margin_Applied__c,p.Volume_Discount_Applied__c,p.One_Time_Discount_Applied__c, p.Support_Pecent_per_Year__c, p.Subscription_Duration__c, p.Name, p.License_Type__c, p.Id, p.Family, p.Description, p.CurrencyIsoCode From Product2 p where p.id in :idList]);
         editList=[Select q.Partner_Margin_Applied__c,q.Support_Percent__c,q.Number_Of_Yrs__c,q.Quantity,q.UnitPrice,q.QuoteId, q.Product_Type__c, q.Product_Family__c, q.PricebookEntryId,q.PricebookEntry.Product2Id, q.ListPrice, q.LineNumber, q.Id, q.Field_Discount__c, q.Field_Discount_Amount__c, q.Discount, q.Description From QuoteLineItem q where q.QuoteId=:recId and q.Product_Family__c='Perpetual Support' limit 1];
        System.debug('editlistpp..........'+editList+'2--'+PerpetualSupportItemMap+'3'+PerpetualSupport);
        if(editList.isempty())
        PerpetualSupport = new Map <String,Product2>([Select p.Partner_Margin_Applied__c,p.Volume_Discount_Applied__c,p.One_Time_Discount_Applied__c, p.Support_Pecent_per_Year__c, p.Subscription_Duration__c, p.Name, p.License_Type__c, p.Id, p.Family, p.Description, p.CurrencyIsoCode From Product2 p where p.family='Perpetual Support']);
        List<PricebookEntry> PbList;
        priceMap = new Map<String,PricebookEntry>();
            System.debug('editlistppqs..........'+editList+'2--'+PerpetualSupportItemMap+'3'+PerpetualSupport);
        if(pbId!=null && PerpetualSupport!=null)
        {
            PbList=[Select p.UseStandardPrice,p.Product2.Name, p.UnitPrice, p.Product2Id, p.Pricebook2Id, p.Name, p.IsActive, p.Id, p.CurrencyIsoCode From PricebookEntry p where p.Pricebook2Id =:PbId and (p.Product2Id in :prodMap.keySet() or p.Product2Id in :PerpetualSupport.keySet() ) and p.IsActive=true];
            
        }
        else if(pbId!=null && !editList.isempty())
        {
            PbList=[Select p.UseStandardPrice,p.Product2.Name, p.UnitPrice, p.Product2Id, p.Pricebook2Id, p.Name, p.IsActive, p.Id, p.CurrencyIsoCode From PricebookEntry p where p.Pricebook2Id =:PbId and (p.Product2Id in :prodMap.keySet() or p.Product2Id = :editList[0].PricebookEntry.Product2Id ) and p.IsActive=true];
        }
        
        System.debug('editlistppqr..........'+editList+'2--'+PerpetualSupportItemMap+'3'+PerpetualSupport); if(!PbList.isempty())
        {
            for(PricebookEntry pbe: PbList)
            priceMap.put(pbe.Product2Id,pbe);
        }
        
        for(Product2 p:prodMap.values())
        {
            if(p.family!='Perpetual Support')
            {
                QuoteLineItem q = new QuoteLineItem(PricebookEntryId=priceMap.get(p.Id).Id ,QuoteId=recId);
                calculate(p,q,true);
            }
        
        }
    }
    
    public void calculate(Product2 p, QuoteLineItem q,Boolean newFlag)
    {
       Boolean vol=p.Volume_Discount_Applied__c == null ? false : Boolean.ValueOf(p.Volume_Discount_Applied__c);
       Boolean oneDis=p.One_Time_Discount_Applied__c == null ? false : Boolean.ValueOf(p.One_Time_Discount_Applied__c); 
       System.debug('editlistppq..........'+editList+'2--'+PerpetualSupportItemMap+'3'+PerpetualSupport);
        if(newFlag)
            {
                q.UnitPrice=priceMap.get(p.Id).unitprice;
                q.Product_Family__c=p.Family;
            }
            System.debug('new---'+newFlag+'family---'+p.Family+'map---'+PerpetualSupportItemMap);
        if(!newFlag && p.Family== 'Perpetual Support' && PerpetualSupportItemMap.isempty())
            {
                    QuoteLineItem qls=q;
                    Product2 existingPro=[Select p.Volume_Discount_Applied__c,p.One_Time_Discount_Applied__c, p.Support_Pecent_per_Year__c, p.Subscription_Duration__c, p.Name, p.License_Type__c, p.Id, p.Family, p.Description, p.CurrencyIsoCode From Product2 p where p.Id=:qls.PricebookEntry.Product2Id];
                    Boolean Margin = false;
                    qls.Product_Family__c='Perpetual Support';
                    if(Margin==true && custType==false)
                    Margin = true;
                    else
                    Margin=false;
                    productWrapper p2 = new productWrapper(true, true, true, Margin,existingPro,qls,true);
                    p2.UnitPrice=String.ValueOf(qls.UnitPrice);
                    wrapperList.add(p2);
                    PerpetualSupportItemMap.put(p.Id,p2);
            }
            if(p.Family=='Perpetual License')
            {
                Boolean Margin = true;
                if(Margin==true && custType==false)
                Margin = true;
                else
                Margin=false;
                productWrapper p1 = new productWrapper(vol, oneDis, false, Margin,  p,q,false);
                p1.UnitPrice=String.ValueOf(q.UnitPrice);
                wrapperList.add(p1);
                System.debug('editlist1..........'+editList+'2--'+PerpetualSupportItemMap+'3'+PerpetualSupport);
                if(PerpetualSupportItemMap.isempty() && newFlag==true )
                {
                if(PerpetualSupport!= null )
                    {   
                        for(Product2 pSupport:PerpetualSupport.values())
                        {
                            QuoteLineItem qls = new QuoteLineItem(PricebookEntryId=priceMap.get(pSupport.Id).Id ,QuoteId=recId);
                            qls.Quantity=1;
                            qls.UnitPrice=0;
                            qls.Product_Family__c='Perpetual Support';
                             Margin = false;
                             if(Margin==true && custType==false)
                                 Margin = true;
                                 else
                                Margin=false;
                            productWrapper p2 = new productWrapper(true, true, true, Margin,  pSupport,qls,true);
                            p2.UnitPrice=String.ValueOf(qls.UnitPrice);
                            wrapperList.add(p2);
                            PerpetualSupportItemMap.put(p.Id,p2);
                        }
                    
                    }   
            
                    else if(!editList.isempty())
                    {
                            System.debug('editlist..........'+editList);
                            QuoteLineItem qls=editList[0];
                            Product2 existingPro=[Select p.Volume_Discount_Applied__c,p.One_Time_Discount_Applied__c, p.Support_Pecent_per_Year__c, p.Subscription_Duration__c, p.Name, p.License_Type__c, p.Id, p.Family, p.Description, p.CurrencyIsoCode From Product2 p where p.Id=:qls.PricebookEntry.Product2Id];
                            Margin = false;
                             qls.Product_Family__c='Perpetual Support';
                            if(Margin==true && custType==false)
                            Margin = true;
                            else
                            Margin=false;
                            productWrapper p2 = new productWrapper(true, true, true, Margin,existingPro,qls,true);
                            p2.UnitPrice=String.ValueOf(qls.UnitPrice);
                            wrapperList.add(p2);
                            PerpetualSupportItemMap.put(p.Id,p2);
                        
                    }
                }
                
            }
            
            else if(p.Family=='On-Premise Subscription')
            {
                
                 Boolean Margin = true;
                if(Margin==true && custType==false)
                Margin = true;
                else
                Margin=false;
                productWrapper p1 = new productWrapper(vol, oneDis,false, Margin,  p,q,false);
                p1.UnitPrice=String.ValueOf(q.UnitPrice);
                wrapperList.add(p1);
                
            }
            
            else if(p.Family=='Renewal')
            {
                
             Boolean Margin = true;
                if(Margin==true && custType==false)
                Margin = true;
                else
                Margin=false;
                productWrapper p1 = new productWrapper(vol, oneDis, false, Margin,  p,q,false);
                p1.UnitPrice=String.ValueOf(q.UnitPrice);
                wrapperList.add(p1);
                
            }
            else if(p.Family=='Training')
            {
                Boolean Margin = true;
                if(Margin==true && custType==false)
                Margin = true;
                else
                Margin=false;
                productWrapper p1 = new productWrapper(vol, oneDis, false, Margin,  p,q,false);
                p1.UnitPrice=String.ValueOf(q.UnitPrice);
                wrapperList.add(p1);
            }
            else if(p.Family=='SaaS Subscription')
            {
                 Boolean Margin = true;
                if(Margin==true && custType==false)
                Margin = true;
                else
                Margin=false;
                productWrapper p1 = new productWrapper(vol, oneDis, false, Margin,  p,q,false);
                p1.UnitPrice=String.ValueOf(q.UnitPrice);
                wrapperList.add(p1);
                
            }
            else if(p.Family=='Service')
            {
                 Boolean Margin = false;
                if(Margin==true && custType==false)
                Margin = true;
                else
                Margin=false;
                    productWrapper p1 = new productWrapper(vol, oneDis, false, Margin,  p,q,false);
                p1.UnitPrice=String.ValueOf(q.UnitPrice);
                wrapperList.add(p1);
                
            }
        
    }
    public Pagereference Save()
    {
        List<QuoteLineItem> qliList = new List<QuoteLineItem> ();
        List<QuoteLineItem> qliList1 = new List<QuoteLineItem> ();
        Decimal SalesPrice=0;
        Decimal quantity=0;
        Decimal Support;
        Decimal NoOfYrs;
        if(qObj.Support_Percent__c==null)
        {
            Support=0;
        }
        else
        {
            Support=qObj.Support_Percent__c;
        }   
        if(qObj.Number_Of_Yrs__c==null)
        {
            NoOfYrs=0;
        }   
        else
        NoOfYrs=qObj.Number_Of_Yrs__c;
        for(productWrapper pw:wrapperList)
        {
            system.debug('--pw--'+pw);
            QuoteLineItem q =pw.qli;
            system.debug('--ql'+q);
            system.debug('--qp'+q.unitPrice);
            isSaleInputPrice = false;
            if(pw.prod.Family== 'Service' ||pw.prod.Family== 'Renewal' ||pw.prod.Family== 'SaaS Mgmnt Fee'){
            	isSaleInputPrice=true;
            }
            if(System.test.isRunningtest())
            {
                if(q.Quantity==null)
                q.Quantity=1;
            }
                    if(pw.prod.Family!='Perpetual Support'  )
                    {
                        
                      
                        //  ---  One Time Discount Calculation
                            if(q.Field_Discount__c==null)
                            q.Field_Discount__c=0;
                            if(q.Volume_Discount__c==null)
                            q.Volume_Discount__c=0;
                            if(q.Field_Discount__c ==0 && q.Volume_Discount__c==0)
                            {
                                q.Field_Discount_Amount__c=0;
                            }
                            else if(q.Field_Discount__c ==0 )
                            q.Field_Discount_Amount__c =0 ;
                            else if(q.Volume_Discount__c ==0)
                            q.Field_Discount_Amount__c=priceMap.get(pw.prod.Id).UnitPrice*(q.Field_Discount__c/100)*q.quantity;
                            else
                            q.Field_Discount_Amount__c=(1-q.Volume_Discount__c/100)*priceMap.get(pw.prod.Id).UnitPrice*(q.Field_Discount__c/100)*q.quantity;
                          //---------Volume Discount Calculation
                            if(q.Volume_Discount__c ==0)
                            q.Volume_Discount_Amount__c=0;
                            else
                            q.Volume_Discount_Amount__c=priceMap.get(pw.prod.Id).UnitPrice * (q.Volume_Discount__c /100)* q.Quantity ;
                            
                           //-------------Sales Price Calculation
                            Decimal pMargin = qObj.Partner_Margin__c;
                            if(pw.prod.Partner_Margin_Applied__c !='true'){
                                pMargin = 0;
                                q.Partner_Margin_Applied__c = 'No';
                            }
                            else
                            {
                                q.Partner_Margin_Applied__c = 'Yes';
                            }
                            system.debug('--Partner_Margin_Applied__c--'+pw.prod.Partner_Margin_Applied__c);
                            if(custType==true && !isSaleInputPrice)//  && pw.prod.Partner_Margin_Applied__c=='True' Customer Quote
                            {
                                System.debug('prod----'+pw.prod+'price--'+priceMap+'---dis--'+q.Field_Discount_Amount__c+'--vol--'+q.Volume_Discount_Amount__c+'--quqn--'+q.Quantity);
                                
                          
                            		q.unitPrice= priceMap.get(pw.prod.Id).UnitPrice-(q.Field_Discount_Amount__c/q.Quantity)-(q.Volume_Discount_Amount__c/q.Quantity);
                            	//}
                            }
                            else if(custType==false && !isSaleInputPrice)//   && pw.prod.Partner_Margin_Applied__c=='True' Partner Quote
                                {
                                    
                                    if(q.Volume_Discount__c==0 && q.Field_Discount__c==0){
                                    	system.debug('--b4'+q.unitPrice);
                                    	
                                   
                                    		q.unitPrice= priceMap.get(pw.prod.Id).UnitPrice*(1-pMargin/100 );	
                                    	
                                    	system.debug('--a4'+q.unitPrice);
                                    }
                                    else
                                    {
                                    if(pMargin!=0)
                                        {
                                            
                                            if(q.Field_Discount__c==0)
                                            {
                                                
                                            q.unitPrice=(1 - q.Volume_Discount__c/100 ) *priceMap.get(pw.prod.Id).UnitPrice * (1-pMargin/100 );
                                            }
                                            
                                            else if(q.Volume_Discount__c==0)
                                            {
                                                
                                            q.unitPrice=priceMap.get(pw.prod.Id).UnitPrice *(1- q.Field_Discount__c/100)* (1-pMargin/100 );
                                            }
                                            else
                                            {
                                            q.unitPrice=(1 - q.Volume_Discount__c/100 ) *priceMap.get(pw.prod.Id).UnitPrice*(1- q.Field_Discount__c/100)* (1-pMargin/100 ) ;
                                            }
                                            
                                        }
                                        else
                                            {
                                                if(q.Field_Discount__c==0)
                                                q.unitPrice=(1 - q.Volume_Discount__c/100 ) *priceMap.get(pw.prod.Id).UnitPrice;
                                                else
                                                if(q.Volume_Discount__c==0)
                                                    q.unitPrice=(1 - q.Field_Discount__c/100 ) *priceMap.get(pw.prod.Id).UnitPrice;
                                                else
                                                q.unitPrice=(1 - q.Volume_Discount__c/100 ) * priceMap.get(pw.prod.Id).UnitPrice*(1 - q.Field_Discount__c/100 ) ;
                                            }
                                        
                                        
                                    }   
                                    
                                }
                                else if(custType==false && isSaleInputPrice)
                                {
                                 
                                    
                                    q.unitPrice= q.unitPrice*(1-pMargin/100 );
                                    
                                }
                                else if(custType==true && isSaleInputPrice)
                                {
                                 q.unitPrice= q.unitPrice-(q.Field_Discount_Amount__c/q.Quantity)-(q.Volume_Discount_Amount__c/q.Quantity);
                                }
                            
                        
                if(pw.prod.Family=='Perpetual License'  )
                {
                    SalesPrice=SalesPrice+q.UnitPrice;
                    Quantity=quantity+q.Quantity;
                    system.debug('--q'+q.UnitPrice);
                }   
                    if(q!=null)
                    qliList.add(q);
                     system.debug('--qfinal'+q);
            }
            
            
        }
        
        if(PerpetualSupportItemMap!=null && !PerpetualSupportItemMap.isempty())
    {   
        List<productWrapper> suppList =PerpetualSupportItemMap.values();
        
                productWrapper p2 =suppList[0];
                QuoteLineItem qs = p2.qli;
                System.debug('Checking unit price..'+qs.UnitPrice);
                Decimal price = priceMap.get(p2.prod.Id).UnitPrice;
                if(Support!=0 && NoOfYrs!=0){
                	//qs.UnitPrice=qs.UnitPrice+(((SalesPrice*quantity*Support)/100)* NoOfYrs);
                	qs.UnitPrice=price+(((SalesPrice*quantity*Support)/100)* NoOfYrs);
                }
                  else
                qs.UnitPrice=0; //qs.UnitPrice+(SalesPrice*quantity);
                
                qs.Total_Price_Static__c=qs.UnitPrice;
                
            
           
                qliList.add(qs);
                    
                    
    }   
            
    try{    
        update(Qobj);
        if(!qliList.isempty())
        upsert(qliList);
        
    }
    
    
    catch(Exception e)
    {
        Apexpages.addMessages(e);
        return null;
    }
        //update(qliList1);
        return new Pagereference('/'+recid);
        
    }
    
    public Pagereference cancel()
    {
        return new Pagereference('/'+recid);
    }
    
    public class productWrapper
    {
        public Boolean Volume {get;set;}
        public Boolean OneTimeDiscount {get;set;}
        public Boolean PerpetualSupport {get;set;}
        public Boolean PartnerMargin {get;set;}
        public QuoteLineItem qli{get;set;}
        public Product2 prod {get;set;}
        public String ListPrice {get;set;}
        public Boolean SupportItem {get;set;}
        public String UnitPrice {get;set;}
        productWrapper(Boolean vol, Boolean Dis, Boolean Supp, Boolean Margin, Product2 p,QuoteLineItem q,Boolean s)
        {
            Volume=vol;
            OneTimeDiscount=Dis;
            PerpetualSupport=Supp;
            PartnerMargin=Margin;
            prod=p;
            qli=q;
            SupportItem=s;
        }
        
    }
    public pagereference CheckPB()
    {
        if(qobj.Pricebook2Id!=null)
        {
            Pagereference pg=new Pagereference('/apex/QuoteLinePage?addTo='+recId+'&retURL=%2F'+recId+'&sfdc.override=1'+'&id='+recId);
            pg.setredirect(true);
            return pg;
        }
         
        displayPB=true;
        return null;
    }
    
     public List<SelectOption> getPBList()
    {
        List<Pricebook2> pbLists =[Select p.Name, p.IsActive, p.Id From Pricebook2 p where p.IsActive=true];
        List<SelectOption> options = new List<SelectOption>();
        for(Pricebook2 pbs:pbLists)
        {
            options.add(new SelectOption(pbs.Id, pbs.Name));
        }
        
        return options;
    }
    public pagereference SavePB()
    {
        qobj.Pricebook2Id=PbIds;
        update qobj;
        Pagereference pg=new Pagereference('/apex/QuoteLinePage?addTo='+recId+'&retURL=%2F'+recId+'&sfdc.override=1'+'&id='+recId);
        pg.setredirect(true);
        return pg;
    }
    
    @IsTest(SeeAllData=true)
    static  void testQuote()
    {
        Account a = new Account(name='testabc',Margin_Discount__c=5);
        insert a;
        Contact c = new Contact(AccountId=a.Id,lastName='abc');
        insert c;
        Opportunity op = new Opportunity(AccountId=a.Id,Name='testoppAbc', StageName='A1 - Active',CloseDate=System.Today().addDays(20));
        insert op;
        System.debug('opty inserted...');
        List<Product2> prodList = new List<Product2>();
        Product2 prod = new Product2(Name='Prod1' ,Family='Perpetual License',Volume_Discount_Applied__c='true',One_Time_Discount_Applied__c='true');
        Product2 prod1 = new Product2(Name='Prod2' ,Family='Perpetual Support');
        Product2 prod2 = new Product2(Name='Prod3' ,Family='On-Premise Subscription',Volume_Discount_Applied__c='false',One_Time_Discount_Applied__c='false');
        Product2 prod3 = new Product2(Name='Prod4' ,Family='Renewal',Volume_Discount_Applied__c='false',One_Time_Discount_Applied__c='true');
        Product2 prod4 = new Product2(Name='Prod5' ,Family='Training',Volume_Discount_Applied__c='true',One_Time_Discount_Applied__c='false');
        Product2 prod5 = new Product2(Name='Prod6' ,Family='SaaS Subscription',Volume_Discount_Applied__c='true',One_Time_Discount_Applied__c='true');
        Product2 prod6 = new Product2(Name='Prod7' ,Family='Service',Volume_Discount_Applied__c='true',One_Time_Discount_Applied__c='true');
        prodList.add(prod);
        prodList.add(prod1);
        prodList.add(prod2);
        prodList.add(prod3);
        prodList.add(prod4);
        prodList.add(prod5);
        prodList.add(prod6);
        insert(prodList);
        List<Pricebook2> pb2List = [select Id, Name, IsActive, IsStandard from Pricebook2 where IsStandard = true or IsStandard = false order by IsStandard desc limit 2];
        Pricebook2 stdPbook;
        Pricebook2 custPbook;
        System.debug('checkinguu---'+pb2List);
        for (Pricebook2 pbs:pb2List)
        {
            
        pbs.IsActive = true;
        if(pbs.IsStandard==true)
        stdPbook=pbs;
        else
        custPbook=pbs;
        System.debug('pb-----'+custPbook);
        }
        update pb2List;
        System.debug('cust---'+custPbook);
         Schema.DescribeSObjectResult Rs;
         Map<String,Schema.RecordTypeInfo> rtMapByIds;
         Rs = Quote.SObjectType.getDescribe();
        rtMapByIds = Rs.getRecordTypeInfosByName(); 
        List<Quote> quoteList = new List<Quote>();
        Quote q = new Quote(opportunityId=op.Id, Name='testQuoteabc');
        q.recordtypeId=rtMapByIds.get('New Customer Quote').getRecordtypeId();
        
        Quote q1 = new Quote(opportunityId=op.Id, Name='testPartnerQuoteabc',Pricebook2Id=custPbook.Id,ContactId=c.Id);
        q1.recordtypeId=rtMapByIds.get('New VAR Partner Quote').getRecordtypeId();
        quoteList.add(q);
        quoteList.add(q1);
        insert quoteList;
        
        PricebookEntry pbe1 ,pbe2,pbe3,pbe4,pbe5,pbe6,pbe7;
        PricebookEntry cpbe1,cpbe2,cpbe3,cpbe4,cpbe5,cpbe6,cpbe7;
        List<PricebookEntry> pbList = new List<PricebookEntry>();// Added by Santoshi to do mass insert.
       pbe1 = new PricebookEntry(

      Pricebook2Id = stdPbook.Id,

      Product2Id = prod.Id,

      IsActive = true,

      UseStandardPrice = false,

      UnitPrice = 500.00

    );
    pbList.add(pbe1);
   // insert pbe1;



    pbe2 = new PricebookEntry(

      Pricebook2Id = stdPbook.Id,

      Product2Id = prod1.Id,

      IsActive = true,

      UseStandardPrice = false,

      UnitPrice = 1000.00

    );
    pbList.add(pbe2);
  //  insert pbe2;

    

    pbe3 = new PricebookEntry(

      Pricebook2Id = stdPbook.Id,

      Product2Id = prod2.Id,

      IsActive = true,

      UseStandardPrice = false,

      UnitPrice = 1500.00

    );
    pbList.add(pbe3);
    
      pbe4 = new PricebookEntry(

      Pricebook2Id = stdPbook.Id,

      Product2Id = prod3.Id,

      IsActive = true,

      UseStandardPrice = false,

      UnitPrice = 1500.00

    );
    pbList.add(pbe4);
    
      pbe5 = new PricebookEntry(

      Pricebook2Id = stdPbook.Id,

      Product2Id = prod4.Id,

      IsActive = true,

      UseStandardPrice = false,

      UnitPrice = 1500.00

    );
    pbList.add(pbe5);
    
      pbe6 = new PricebookEntry(

      Pricebook2Id = stdPbook.Id,

      Product2Id = prod5.Id,

      IsActive = true,

      UseStandardPrice = false,

      UnitPrice = 1500.00

    );
    pbList.add(pbe6);
    
      pbe7 = new PricebookEntry(

      Pricebook2Id = stdPbook.Id,

      Product2Id = prod6.Id,

      IsActive = true,

      UseStandardPrice = false,

      UnitPrice = 1500.00

    );
    pbList.add(pbe7);
    
    
    
      cpbe1 = new PricebookEntry(

      Pricebook2Id = custPbook.Id,

      Product2Id = prod.Id,

      IsActive = true,

      UseStandardPrice = false,

      UnitPrice = 500.00

    );
    pbList.add(cpbe1);
   // insert pbe1;



    cpbe2 = new PricebookEntry(

      Pricebook2Id = custPbook.Id,

      Product2Id = prod1.Id,

      IsActive = true,

      UseStandardPrice = false,

      UnitPrice = 1000.00

    );
    pbList.add(cpbe2);
  //  insert pbe2;

    

    cpbe3 = new PricebookEntry(

      Pricebook2Id = custPbook.Id,

      Product2Id = prod2.Id,

      IsActive = true,

      UseStandardPrice = false,

      UnitPrice = 1500.00

    );
    pbList.add(cpbe3);
    
      cpbe4 = new PricebookEntry(

      Pricebook2Id = custPbook.Id,

      Product2Id = prod3.Id,

      IsActive = true,

      UseStandardPrice = false,

      UnitPrice = 1500.00

    );
    pbList.add(cpbe4);
    
      cpbe5 = new PricebookEntry(

      Pricebook2Id = custPbook.Id,

      Product2Id = prod4.Id,

      IsActive = true,

      UseStandardPrice = false,

      UnitPrice = 1500.00

    );
    pbList.add(cpbe5);
    
      cpbe6 = new PricebookEntry(

      Pricebook2Id = custPbook.Id,

      Product2Id = prod5.Id,

      IsActive = true,

      UseStandardPrice = false,

      UnitPrice = 1500.00

    );
    pbList.add(cpbe6);
    
      cpbe7 = new PricebookEntry(

      Pricebook2Id = custPbook.Id,

      Product2Id = prod6.Id,

      IsActive = true,

      UseStandardPrice = false,

      UnitPrice = 1500.00

    );
    pbList.add(cpbe7);
    
    insert pbList;
    
     PageReference VFpage1 = Page.QuoteLineIntermediate;
        test.setCurrentPage(VFpage1);
        ApexPages.StandardController VFpage_Extn1 = new ApexPages.StandardController(q);
        QuoteLinePageExt CLS1 = new QuoteLinePageExt(VFpage_Extn1);
        CLS1.checkPb();
        CLS1.getPBList();
        CLS1.PBids=custPbook.Id;
        CLS1.SavePB();
        CLS1.checkPb();
        CLS1.cancel();
        System.assertequals(q.Pricebook2Id,custPbook.Id);
        String idss=Prod.id+'-'+Prod2.id+'-'+Prod4.Id+'-'+Prod5.Id+'-'+Prod6.Id+'-'+prod3.Id;
        
        VFpage1 = Page.QuoteLinePageNew;
        test.setCurrentPage(VFpage1);
        VFpage1.getParameters().put('ids',idss);
        VFpage_Extn1 = new ApexPages.StandardController(q);
        CLS1 = new QuoteLinePageExt(VFpage_Extn1);
        System.assert(CLS1.wrapperList.size()>=1);
        CLS1.Save();
        
        VFpage1 = Page.QuoteLinePageNew;
        test.setCurrentPage(VFpage1);
        VFpage1.getParameters().put('ids',idss);
        VFpage_Extn1 = new ApexPages.StandardController(q);
        CLS1 = new QuoteLinePageExt(VFpage_Extn1);
        System.assert(CLS1.wrapperList.size()>=1);
        CLS1.Save();
        
        VFpage1 = Page.QuoteLineEditPage;
        test.setCurrentPage(VFpage1);
        VFpage_Extn1 = new ApexPages.StandardController(q);
        CLS1 = new QuoteLinePageExt(VFpage_Extn1);
        CLS1.editQuoteLine();
        CLS1.Save();
            
        VFpage1 = Page.QuoteLinePage;
        test.setCurrentPage(VFpage1);
        VFpage1.getParameters().put('search','test');
         VFpage1.getParameters().put('field','Name');
         VFpage1.getParameters().put('opr','eq'); 
         VFpage1.getParameters().put('val','test');
         VFpage1.getParameters().put('srch','true');
        VFpage_Extn1 = new ApexPages.StandardController(q);
        CLS1 = new QuoteLinePageExt(VFpage_Extn1);
        
        
         VFpage_Extn1 = new ApexPages.StandardController(q1);
        CLS1 = new QuoteLinePageExt(VFpage_Extn1);
        CLS1.checkPb();
        CLS1.getPBList();
        CLS1.PBids=custPbook.Id;
        CLS1.SavePB();
        
        
        VFpage1 = Page.QuoteLinePageNew;
        test.setCurrentPage(VFpage1);
        VFpage1.getParameters().put('ids',idss);
        VFpage_Extn1 = new ApexPages.StandardController(q1);
        CLS1 = new QuoteLinePageExt(VFpage_Extn1);
      //    CLS1.Save();
      
      List<QuoteLineItem> qliLists =[select Partner_Margin_Applied__c,Id,QuoteId from QuoteLineItem where QuoteId=:q.Id limit 1];
      if(!qliLists.isempty())
      {
        PageReference VFpage2 = Page.QuoteLineEditDetail;
        test.setCurrentPage(VFpage2);
        ApexPages.StandardController VFpage_Extn2 = new ApexPages.StandardController(qliLists[0]);
        QuoteLineItemClass CLS3 = new QuoteLineItemClass(VFpage_Extn2);
        CLS3.redirectEdiAll();
  
      }
    }
 */
}