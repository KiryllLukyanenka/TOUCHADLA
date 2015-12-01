public with sharing class TaskCreationController {
    
    public String fileName{get;set;}
    public Blob fileContents{get;set;}
    
    private static Map<String,String> casDisposition_LeadStatusMap = new Map<String,String>();
    static{
        casDisposition_LeadStatusMap.put('Active','Qualified');
        casDisposition_LeadStatusMap.put('Call Back Later','Contacted');
        casDisposition_LeadStatusMap.put('Interest PHP','Contacted');
        casDisposition_LeadStatusMap.put('Interest .NET','Contacted');
        casDisposition_LeadStatusMap.put('Interest: Other Application Stack','Contacted');
        casDisposition_LeadStatusMap.put('Meeting Scheduled','Qualified');
        casDisposition_LeadStatusMap.put('Not Interested','Unqualified');
        casDisposition_LeadStatusMap.put('Not Interested - existing APM Tool','Unqualified');   
        casDisposition_LeadStatusMap.put('No the Right Person/No Referral','Unqualified');
        casDisposition_LeadStatusMap.put('Referral','Contacted');
        casDisposition_LeadStatusMap.put('Direct Number','Attempted Contact');
        casDisposition_LeadStatusMap.put('Gatekeeper Block','Attempted Contact');
        casDisposition_LeadStatusMap.put('Information Error','Unqualified');
        casDisposition_LeadStatusMap.put('Not Available','Attempted Contact');
        casDisposition_LeadStatusMap.put('Person Left','Unqualified');
        casDisposition_LeadStatusMap.put('Voicemail Reached','Attempted Contact');
    }
    
    public TaskCreationController(ApexPages.StandardController stdController){
                
    }
    
    private String userName;
    private String dateString;
    private Date dueDate;
    private User salesRepUser;
    
    public PageReference processFile(){
        String fileContentsString = fileContents.toString();
        String[] lines = fileContentsString.split('\n',-1);
        
        if(lines!=null){
            Boolean dataStarted=false;
            List<Task> taskObjects = new List<Task>();
            List<String> crmIds = new List<String>(); 
            Map<String,String> crmId_DispositionMap= new Map<String,String>();
            List<Lead> leadList = [Select Id,Name,ConvertedContactId,Email,Status from Lead where ConvertedContactId=''];
            for(String line : lines){
                if(line.contains('Prepared for')){
                    
                    String parsedLine =line.substring('Prepared for'.length()+1).trim();
                    String[] parsedLineElements =   parsedLine.split(' ',-1);
                    userName = parsedLineElements[0]+' '+parsedLineElements[1];
                    try{
                        salesRepUser = [Select Id,Name,Email,UserName from User where Name=:userName];
                    }catch(Exception e){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Unable to find User with Name:'+userName);
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                    dateString = parsedLineElements[3];
                    String[]dateElements = dateString.trim().split('/');
                    
                    dueDate = Date.valueOf(dateElements[2]+'-'+dateElements[0]+'-'+dateElements[1]);
                    continue; 
                }
                if(line.contains('Company Name,Job Title')){
                    dataStarted=true;
                    continue;
                }
                if(dataStarted){
                    String[] words = line.trim().split(',',-1);
                    try{
                    if(words!=null && words.size()>12){
                            Task taskObj = new Task();
                            taskObj.Subject = 'CAS '+words[5];
                            taskObj.Status = 'Completed';
                            taskObj.ActivityDate = dueDate;
                            taskObj.OwnerId = salesRepUser.Id;
                            //taskObj.Description = line;
                            Lead lead = getLead(words,leadList);
                            //Contact ct = getContact(words);
                            try{
                                String id = '';
                                if(lead!=null){
                                    id = lead.Id;
                                    String convertedCtId = lead.ConvertedContactId;
                                    if(convertedCtId!=null){
                                        continue;
                                    }else{
                                        taskObj.WhoId = id;
                                    }
                                    
                                }else{
                                    continue;
                                }
                                
                                /*else if(ct!=null){
                                    id = ct.Id;
                                }*/
                                
                            }catch(Exception e){
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Invalid Owner Value '+ words[12]);
                                ApexPages.addMessage(myMsg);
                                continue;
                            }
                            crmIds.add(words[12]);
                            crmId_DispositionMap.put(words[12],words[5]);
                            taskObjects.add(taskObj);
                    }
                    }catch(Exception e){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,e.getMessage()+'\nInsufficient gParameters:'+ line+'\n'+e.getStackTraceString());
                        ApexPages.addMessage(myMsg);
                        continue;
                    }
                }
            }
            
            for(Lead leadObj:leadList){
                String disposition = crmId_DispositionMap.get(leadObj.Id);
                if(disposition !=null){
                    String leadStatusVal = casDisposition_LeadStatusMap.get(disposition);
                    if(leadStatusVal!=null){
                        leadObj.Status = leadStatusVal;
                    } 
                }
            }
            
            //System.runAs(salesRepUser)
            {
                try{
                    upsert taskObjects;
                }catch(Exception e){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Task Error: '+e.getMessage());
                    ApexPages.addMessage(myMsg);
                }
                try{
                    upsert leadList;
                }catch(Exception e){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Lead Error: '+e.getMessage());
                    ApexPages.addMessage(myMsg);
                }
            }
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,taskObjects.size()+' Completed Tasks have been assigned succesfully for '+ userName+'<'+salesRepUser.Id+'>');
            ApexPages.addMessage(myMsg);        
        }
        return null;
    }
    
    private Lead getLead(String[] words, List<Lead> leads){
        String crmId = words[words.size()-2];
        String crmIdEmail = words[words.size()-3];
        for(Lead leadObj:leads){
            String leadId=leadObj.Id;
            if(leadId.equals(crmId)){
                return leadObj;
            }else if(leadObj.Email!=null && leadObj.Email.equals(crmIdEmail)){
                return leadObj;
            }
        }return null;
    }
    
    private Contact getContact(String[] words){
        String crmId = words[words.size()-2];
        String crmIdEmail = words[words.size()-3];
        try{
            Contact lead = [select Id,Name,FirstName,LastName,Email from Contact where Id=:crmId];
            return lead;
        }catch(Exception e){
            System.debug(LoggingLevel.Error,e);
        }
        try{
            Contact lead = [select Id,Name,FirstName,LastName,Email from Contact where Email=:crmIdEmail];
            return lead;
        }catch(Exception e){
            System.debug(LoggingLevel.Error,e);
        }
        return null;
    }
}