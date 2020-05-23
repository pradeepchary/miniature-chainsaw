/** 
 * Description  - Test class for ContentDocumentLinkTrigger
 * Created by   - snpl
 **/
@isTest(seeAllData=true)
private class ContentDocumentLinkTriggerTest {

    static testMethod void testTrigger() {
        
        List<User> userlist = [Select Id from user Limit 1];
        
        // Create News record
        News_Announcements__c news = TestData.createNews(userlist[0].Id, 
                                                        'Global_News', 
                                                        'Event');
        insert news;
        
        // Create ContentVersion
        ContentVersion contentVer = new ContentVersion( Title = 'news news',ContentURL='http://www.google.com' );
        insert contentVer;
        
        contentVer = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :contentVer.Id];
        
        // Create ContentDocumentLink   
        ContentDocumentLink contDoc =  new ContentDocumentLink(ContentDocumentId = contentVer.ContentDocumentId,
                                                                 ShareType= 'I',
                                                                 Visibility = 'AllUsers',
                                                                LinkedEntityId = news.id );
        
        Test.StartTest();
            insert contDoc;
        Test.StopTest();
        
        news = [Select Id, ImageAttachmentId__c From News_Announcements__c where Id =: news.Id][0];
        
        // Check if ImageAttachmentId__c is modified
        System.assertEquals(news.ImageAttachmentId__c, contentVer.Id );
    }
}