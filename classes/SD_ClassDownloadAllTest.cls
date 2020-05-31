/*****************************************************************************************************
* 
* @ Name        : SD_ClassDownloadAllTest
* @ Purpose     : Test class for Controller SD_ClassDownloadAll
* @ Author      : Pradeep Chary
*
* Date          | Developer Name              | Version   | Changes
* ====================================================================================================
* 24-04-2020    | pradeep.chary@absyz.com     | 1.0       | Initial Version
*
*****************************************************************************************************/

@isTest()
public class SD_ClassDownloadAllTest {
    
    public static List<String> recordIds;
    
    // Test data for the test class
    public static void createTestData() {
        
        recordIds = new List<String>();
        
        // Create test record 1
        Account data1 = new Account();
        data1.Name = 'Dummy Account';
        insert data1;
        
        // Create test record 2
        Account data2 = new Account();
        data2.Name = 'Test Account 2';
        insert data2;
        
        recordIds.add(data1.Id);
        recordIds.add(data2.Id);
        
        // Create content version record
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        recordIds.add(contentVersion.Id);
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        // create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = recordIds[0];
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
    }
    
    // Test method 1
    private static testmethod void unittestLoadv1() {
        createTestData();
        
        Test.startTest();
        SD_ClassDownloadAll.getAttachments(recordIds[0]);
        SD_ClassDownloadAll.getAttachments(recordIds[1]);
        SD_ClassDownloadAll.getAttachments('00X');
        SD_ClassDownloadAll.getAttachments('001g000001jmmCA');
        SD_ClassDownloadAll.getAttachments(null);
        Test.stopTest();
    }
    
}