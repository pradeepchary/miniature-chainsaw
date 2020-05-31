/**************************************************************************************************************************************************\
@ Author        : Pradeep Chary
@ Date          : March 2017
@ Test File     : NA
@ Function      : Test Class for DeleteMetaDataClass
-----------------------------------------------------------------------------

***************************************************************************************************************************************************/

@isTest()
private class DeleteMetaDataClassTest {
    
    public static msyn__Authorization_Value__c authDetail; /* Custom settings updated after the Security Review, Date:01/10/2017 at 03:00 AM  */
    public static list < msyn__Connected_Org__c > testOrglst;
    public static msyn__Application_Value__c testAppSetting; /* Custom settings updated after the Security Review, Date:01/10/2017 at 03:00 AM  */
    public static list < msyn__MetaSnap__c > testPackage;
    public static list < msyn__MetaSnap_Content__c > testPackageContent;
    public static list < msyn__MetaPack__c > testmetaPacklst;
    public static list <msyn__Deployment_Log__c > testDLogLst;
    public static msyn__Deployment_Log__c testZipItem;
    public static list < msyn__Profile__c > testProfiles;
    public static list < msyn__Profile_Attribute__c > testProfileAttlst;
    public static list < msyn__MetaPack_Component__c > testpackComponentsLst;
    public static list < msyn__User_Authorization__c > testUserpermissions;
    
    private static void createTestData() {
        
        testOrglst = testDataUtility.createConnectedOrgs();
        insert testOrglst;
        
        testAppSetting = testDataUtility.createAppSetting();
        insert testAppSetting;
        
        authDetail = testDataUtility.createAuthorization();
        insert authDetail;
        
        Id UserId = UserInfo.getUserId();
        
        testUserpermissions = testDataUtility.createUserPermissions(testOrglst,UserId);
        insert testUserpermissions;
        
        testPackage = testDataUtility.createMetaSnaps(testOrglst);
        insert testPackage;
        
        testPackageContent = testDataUtility.createMetaSnapComponents(testPackage);
        testPackageContent[0].msyn__Member_Names__c = 'AccountActions';
        testPackageContent[1].msyn__MetaSnap__c = testPackage[0].Id;
        testPackageContent[2].msyn__MetaSnap__c = testPackage[0].Id;
        testPackageContent[3].msyn__MetaSnap__c = testPackage[0].Id;
        testPackageContent[1].msyn__Member_Names__c = 'TestClass';
        testPackageContent[2].msyn__Member_Names__c = 'Admin';
        testPackageContent[2].msyn__Member_Type__c = 'UserPermissions';
        
        insert testPackageContent;
        
        testmetaPacklst = testDataUtility.createMetaPacklst();
        testmetaPacklst[0].msyn__Destructive_Changes__c = true;
        testmetaPacklst[1].msyn__Destructive_Changes__c = true;
        insert testmetaPacklst;
        
        Attachment att = new Attachment();
        att.Body = Blob.valueOf('Test String');
        att.Name = 'Testing.zip';
        att.ParentId = testmetaPacklst[0].Id;
        insert att;
        
        testpackComponentsLst = testDataUtility.createMetaPackComponents(testmetaPacklst);
        insert testpackComponentsLst;
        
        testDLogLst = testDataUtility.createDLogs(testmetaPacklst, testOrglst);
        insert testDLogLst;
        
        testProfiles = testDataUtility.createProfiles(testPackage);
        insert testProfiles;
        
        testProfileAttlst = testDataUtility.createProfileAtts(testProfiles, testPackageContent);
        testProfileAttlst[1].msyn__Profile__c = testProfiles[0].Id;
        insert testProfileAttlst;
        
    }
    
    private static testmethod void testDelete() {
        
        createTestData();
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new HTTPCallOutMockClass());
        Test.setMock(WebServiceMock.class, new WebServiceMockImplClass());
        
        String returnCRUDaccess = DeleteMetaDataClass.getCRUDAccess('msyn__Connected_Org__c','msyn__MetaPack__c','msyn__MetaPack_Component__c','msyn__Deployment_Log__c','msyn__Deployment_Error_Log__c');
        
        list < RMetaDataItemWrpClass > testMetaDataItemlst = DeleteMetaDataClass.getMetadataItems('ApexClass', testOrglst[0].Name);
        
        UserperWrpClass wrapClass = DeleteMetaDataClass.getpermissions();
        System.assertEquals(wrapClass.SourceOrgs.size(), 20);
        
        list < msyn__MetaPack__c > metaPacklst = DeleteMetaDataClass.getMetaPacks();
        
        list < MetaDataTypesWrpClass > testmetaDataTypelst = DeleteMetaDataClass.getMetaDataTypesonLoad(testOrglst[0].Name);
        
        Test.stopTest();
        
    }
    
    private static testmethod void testFolderTestMethod() {
        
        createTestData();
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new HTTPCallOutMockClass());
        Test.setMock(WebServiceMock.class, new WebServiceMockImplClass());
        
        list < RMetaDataItemWrpClass > testFolderItem = DeleteMetaDataClass.getFoldItems('unfiled$public', 'Report', testOrglst[0].Name);
        
        UserperWrpClass wrapClass = DeleteMetaDataClass.getpermissions();
        System.assertEquals(wrapClass.SourceOrgs.size(), 20);
        
        Test.stopTest();
        
    }
    
    private static testmethod void testUpdateTestMethod() {
        
        createTestData();
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new HTTPCallOutMockClass());
        Test.setMock(WebServiceMock.class, new WebServiceMockImplClass());
        
        
        
        UserperWrpClass wrapClass = DeleteMetaDataClass.getpermissions();
        System.assertEquals(wrapClass.SourceOrgs.size(), 20);
        
        Test.stopTest();
        
    }
    
    private static testmethod void testDlogsMethod() {
        
        createTestData();
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new HTTPCallOutMockClass());
        Test.setMock(WebServiceMock.class, new WebServiceMockImplClass());
        String TargetOrgs= '["' + testOrglst[0].Name + '"]';
        List < MetaPackWrpClass >  testLogItem = DeleteMetaDataClass.getDeploymentLogs(testmetaPacklst[0].Id,TargetOrgs);
        
        boolean logaVailable = false ;
        
        if(testLogItem != null){
            logaVailable = true ;
        }
        
        System.assertEquals(logaVailable, true);
        
        Test.stopTest();
        
    }
    
    private static testmethod void testMetaPackTestMethod() {
        
        createTestData();
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new HTTPCallOutMockClass());
        Test.setMock(WebServiceMock.class, new WebServiceMockImplClass());
        
        String testMetaPack = DeleteMetaDataClass.getCreateMetaPackage('Test' , testmetaPacklst[0].Id, true);
        
        UserperWrpClass wrapClass = DeleteMetaDataClass.getpermissions();
        System.assertEquals(wrapClass.SourceOrgs.size(), 20);
        
        Test.stopTest();
        
    }
    
    private static testmethod void testCreatePackTestMethod() {
        
        createTestData();
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new HTTPCallOutMockClass());
        Test.setMock(WebServiceMock.class, new WebServiceMockImplClass());
        
        String compName = testDataUtility.compNames();
        String compType = testDataUtility.compTypes();
        
        String compDetails = '["TestSnap9"]'; 
        String compDeTypes = '["ApexClass"]'; 
        
        PackageDetailsWrpClass testMetaPack = DeleteMetaDataClass.getDeletePackages('None', compType, compName, compDetails, compDeTypes, 'TestMetapack');
        
        PackageDetailsWrpClass testMetaPack2 = DeleteMetaDataClass.getDeletePackages('None', compType, compName, null, null, 'TestMetapack');
        
        PackageDetailsWrpClass testMetaPack3 = DeleteMetaDataClass.getDeletePackages(testMetaPack.metaPackID, compType, compName, null, null, 'TestMetapack');
        
        boolean packAvailable = false ;
        
        if(testMetaPack != null){
            packAvailable = true ;
        }
        
        System.assertEquals(packAvailable, true);
        
        Test.stopTest();
        
    }
    
    private static testmethod void testZipTestMethod() {
        
        createTestData();
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new HTTPCallOutMockClass());
        Test.setMock(WebServiceMock.class, new WebServiceMockImplClass());
        
        testZipItem = DeleteMetaDataClass.getDeployPackage(testOrglst[0].Name, testmetaPacklst[0].Id, 'Deploy' , true);
        
        boolean zippackAvailable = false ;
        
        if(testZipItem != null){
            zippackAvailable = true ;
        }
        
        System.assertEquals(zippackAvailable, true);
        
        Test.stopTest();
    }
    
    private static testmethod void testQDeployTestMethod() {
        
        createTestData();
        
        Test.startTest();
        
        list < msyn__MetaPack__c > metaPacklst = DeployMetaDataClass.getMetaPacks();
        boolean zippackAvailable = false ;
        
        if(metaPacklst != null){
            zippackAvailable = true ;
        }
        
        System.assertEquals(zippackAvailable, true);
        
        
        Test.setMock(HttpCalloutMock.class, new HTTPCallOutMockClass());
        Test.setMock(WebServiceMock.class, new WebServiceMockImplClass());
        
        msyn__Deployment_Log__c result = DeleteMetaDataClass.getQuickDeploy(testmetaPacklst[0].Id, testDLogLst[0].Id ,false);
        
        Test.stopTest();
        
    }
    
    private static testmethod void testDeployMethod() {
        
        createTestData();
        
        Test.startTest();
        
        list < msyn__MetaPack__c > metaPacklst = DeployMetaDataClass.getMetaPacks();
        boolean zippackAvailable = false ;
        
        if(metaPacklst != null){
            zippackAvailable = true ;
        }
        
        System.assertEquals(zippackAvailable, true);
        
        Test.setMock(HttpCalloutMock.class, new HTTPCallOutMockClass());
        Test.setMock(WebServiceMock.class, new WebServiceMockImplClass());
        
        String compDetails = '["' + testPackageContent[0].msyn__Member_Names__c + '"]';
        String profileDetails = '["' + testProfileAttlst[0].Id + '"]';
        String packageDetails = '["' + testPackage[0].msyn__MetaSnap_Name__c + '"]';
        
        PackageDetailsWrpClass pkgDetWrpClass = DeployMetaDataClass.getUpdatedPackage(compDetails,profileDetails,compDetails,testmetaPacklst[0].Id,false);
        
        DStatusWrpClass result = DeleteMetaDataClass.getStatusResult('', true, testOrglst[0].Name, testmetaPacklst[0].Id, 'Deploy', 'None');
        
        Test.stopTest();
        
    }
    
}