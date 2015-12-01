@isTest
public class UploadDocumentExtensionTest {
    
    @isTest static void testUploadDocumentExtension(){
        Account account = new Account(Name = 'Acc', Industry = 'test');
        insert Account;
        Opportunity oppt = new Opportunity(AccountId = account.Id, Name = 'Oppt', StageName = 'stage', CloseDate = System.today());
        insert oppt;
        UploadDocumentExtension controller = new UploadDocumentExtension(new ApexPages.StandardController(oppt));
        Attachment att = controller.OppAttachment;
        controller.upload();
    }
    
    @isTest static void testUploadDocumentExtension2(){
        Account account = new Account(Name = 'Acc2', Industry = 'test2');
        insert Account;
        Opportunity oppt = new Opportunity(AccountId = account.Id, Name = 'Oppt2', StageName = 'stage2', CloseDate = System.today().addDays(2));
        insert oppt;
        UploadDocumentExtension controller = new UploadDocumentExtension(new ApexPages.StandardController(oppt));
        Attachment att = controller.OppAttachment;
        controller.upload();
    }
}