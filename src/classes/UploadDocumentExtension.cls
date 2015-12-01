/*
 ** Apex class to be used by UploadDocument VF to create attachments for Opportunity with specified type.
 
 ** Author: Eric He
 */
public with sharing class UploadDocumentExtension 
{
    public Opportunity_Upload__c OppUpload { get; set; }
    public Attachment OppAttachment
    {
        get
        {
            if(OppAttachment == null)
            {
                OppAttachment = new Attachment();
            }
            return OppAttachment;
        }
        set;
    }
    public Boolean UploadSuccess { get; set; }
    
    private String oppId;

    public UploadDocumentExtension(ApexPages.StandardController stdController) 
    {
        oppId = stdController.getId();
        OppUpload = new Opportunity_Upload__c(Opportunity__c = oppId);
        
        UploadSuccess = false;
    }

    public void upload()
    {
        try
        {
            OppUpload.Name = OppAttachment.Name;
            upsert OppUpload;
            
            OppAttachment.ParentId = OppUpload.Id;
            insert OppAttachment;
            UploadSuccess = true;
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
        finally
        {
            // Clears the viewstate.
            OppAttachment.body = null;
            OppAttachment = new Attachment();
        }
    }
}