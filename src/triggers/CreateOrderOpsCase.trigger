trigger CreateOrderOpsCase on Opportunity (after insert, after update) {
    List<Case> cases = new List<Case>();
    for (Opportunity Opp : Trigger.New) {
        if (Opp.StageName == 'W10 - Closed/Won' && Opp.Case_Created__c == False){
            case newcase = new case();
            newcase.Subject = Opp.Name + ' has just been set to W-10';
            newcase.Description = 'Please Book this deal - ' + Opp.ID;
            newcase.Status = 'New';
            newcase.CurrencyIsoCode = Opp.Owner.DefaultCurrencyIsoCode;
            newcase.Origin = 'Web';
            newcase.Opportunity__c = Opp.Id;
            newcase.Reason = 'W-10 Status';
            newcase.OwnerId = '00G80000002oYaP';
            newcase.RecordTypeID = '01280000000LzIJ';
            cases.add(newcase);
System.debug('++++');
System.debug('Adding new case');
        }
    }

    if (cases.size() > 0) {
        try {
            insert cases;
        }
        catch (DMLException e) {     }
    }
}


/*Have a case automatically created when an opportunity is changed to W10 status so Order Ops can track progress to booking
Have the ticket “created by” field equal the Sales Rep on the Opportunity
Have the case related to the Opportunity
Set the Case Type = W10 Status
Case Reason = W10 Status
Set the case owner to OrderOps Case Queue
Case Status value = New
Put the new W10 Status Case into a list view for OrderOps to manage
Allow a member of the OrderOps team to change the Case Owner to their own name
Case Status values manually updated 
New, In Progress, Escalated, Waiting for Reply, Closed
When OrderOps cannot book the deal, they should be able to use case comments to communicate the issue with the SalesRep
Workflow email to Contact/Contact Email (Sales Rep) to notify them of the comment
Setup email to case so responses can get logged back to sfdc*/