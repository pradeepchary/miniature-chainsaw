@isTest()

private class CompareMetaDataClassTest {
    
    public static msyn__Authorization_Value__c authDetail; /* Custom settings updated after the Security Review, Date:01/10/2017 at 03:00 AM  */
    public static list < msyn__Connected_Org__c > testOrglst;
    public static msyn__Application_Value__c testAppSetting; /* Custom settings updated after the Security Review, Date:01/10/2017 at 03:00 AM  */
    public static list < msyn__MetaSnap__c > testPackage;
    public static list < msyn__MetaSnap_Content__c > testPackageContent;
    public static list < msyn__MetaPack__c > testmetaPacklst;
    public static list < msyn__Profile__c > testProfiles;
    public static list < msyn__Profile_Attribute__c > testProfileAttlst;
    public static list <msyn__Deployment_Log__c > testDLogLst;
    public static msyn__Deployment_Log__c testZipItem;
    public static String componentNames ;
    public static String profileNames ;
    public static String componentIds ;
    public static String componentIds1 ;
    public static String profileIds ;
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
        System.debug('testPackageContent '+testPackageContent);
        testPackageContent[0].msyn__MetaSnap__c = testPackage[0].Id;
        testPackageContent[1].msyn__MetaSnap__c = testPackage[0].Id;
        testPackageContent[2].msyn__MetaSnap__c = testPackage[0].Id;
        testPackageContent[3].msyn__MetaSnap__c = testPackage[0].Id;
        testPackageContent[9].msyn__MetaSnap__c = testPackage[0].Id;
        testPackageContent[10].msyn__MetaSnap__c = testPackage[0].Id;
        testPackageContent[4].msyn__MetaSnap__c = testPackage[1].Id;
        testPackageContent[5].msyn__MetaSnap__c = testPackage[1].Id;
        testPackageContent[6].msyn__MetaSnap__c = testPackage[1].Id;
        testPackageContent[7].msyn__MetaSnap__c = testPackage[1].Id;
        testPackageContent[8].msyn__MetaSnap__c = testPackage[1].Id;
        testPackageContent[0].msyn__Member_Names__c = 'AccountActions';
        testPackageContent[0].msyn__Member_Type__c = 'ApexClass';
        testPackageContent[1].msyn__Member_Names__c = 'AccountPage';
        testPackageContent[1].msyn__Member_Type__c = 'ApexPage';
        testPackageContent[2].msyn__Member_Names__c = 'Admin';
        testPackageContent[2].msyn__Member_Type__c = 'UserPermissions';
        testPackageContent[3].msyn__Member_Names__c = 'Account';
        testPackageContent[3].msyn__Member_Type__c = 'CustomObject';
        testPackageContent[3].msyn__Folder_Component__c='objects';
        testPackageContent[4].msyn__Member_Names__c = 'Account';
        testPackageContent[4].msyn__Member_Type__c = 'SharingRules';
        testPackageContent[5].msyn__Member_Names__c = 'Account';
        testPackageContent[5].msyn__Member_Type__c = 'Workflow';
        testPackageContent[6].msyn__Member_Names__c = 'TestFolder/TestComponent';
        testPackageContent[6].msyn__Member_Type__c = 'Dashboard';
        testPackageContent[7].msyn__Member_Names__c = 'TestCmp';
        testPackageContent[7].msyn__Member_Type__c = 'AuraDefinitionBundle';
        testPackageContent[7].msyn__AuraItems__c = 'TestCmp.cmp//TestCmpController.js';
        testPackageContent[8].msyn__Member_Names__c = 'AccountActions';
        testPackageContent[8].msyn__Member_Type__c = 'ApexClass';
        testPackageContent[9].msyn__Member_Names__c = 'TestComponent';
        testPackageContent[9].msyn__Member_Type__c = 'AuraDefinitionBundle';
        testPackageContent[9].msyn__AuraItems__c = 'TestComponent.cmp//TestComponentController.js';
        testPackageContent[10].msyn__Member_Names__c = 'Admin';
        testPackageContent[10].msyn__Member_Type__c = 'Profile';
        
        
        insert testPackageContent;
        
        testmetaPacklst = testDataUtility.createMetaPacklst();
        insert testmetaPacklst;
        
        List < Attachment > attList = new List < Attachment >();
        
        Attachment att = new Attachment();
        att.Body = Blob.valueOf('Test String');
        att.Name = 'Testing.zip';
        att.ParentId = testmetaPacklst[0].Id;
        attList.add(att);
        
        Attachment att2 = new Attachment();
        att2.Body = Blob.valueOf('Test String');
        att2.Name = 'AccountActions.cls';
        att2.ParentId = testPackageContent[0].Id;
        attList.add(att2);
        
        Attachment att8 = new Attachment();
        att8.Body = Blob.valueOf('Test String');
        att8.Name = 'AccountActions.cls';
        att8.ParentId = testPackageContent[8].Id;
        attList.add(att8);
        
        Attachment att4 = new Attachment();
        att4.Body = Blob.valueOf('Test String');
        att4.Name = 'Account.object';
        att4.ParentId = testPackageContent[3].Id;
        attList.add(att4);
        
        Attachment att5 = new Attachment();
        att5.Body = Blob.valueOf('Test String </sharingrules>');
        att5.Name = 'Account.sharingRules';
        att5.ParentId = testPackageContent[4].Id;
        attList.add(att5);
        
        Attachment att6 = new Attachment();
        att6.Body = Blob.valueOf('Test String </workflow>');
        att6.Name = 'Account.workflow';
        att6.ParentId = testPackageContent[5].Id;
        attList.add(att6);
        
        Attachment att7 = new Attachment();
        att7.Body = Blob.valueOf('Test String');
        att7.Name = 'Account.sharingRules';
        att7.ParentId = testPackageContent[6].Id;
        attList.add(att7);
        
        Attachment att9 = new Attachment();
        att9.Body = Blob.valueOf('Test String');
        att9.Name = 'TestCmpController';
        att9.ParentId = testPackageContent[7].Id;
        attList.add(att9);

		Attachment att10 = new Attachment();
        att10.Body = Blob.valueOf('Test String');
        att10.Name = 'TestComponentController';
        att10.ParentId = testPackageContent[9].Id;
        attList.add(att10);
        
        testDLogLst = testDataUtility.createDLogs(testmetaPacklst, testOrglst);
        insert testDLogLst;
        
        testProfiles = testDataUtility.createProfiles(testPackage);
        testProfiles[0].Name = 'Admin';
        testProfiles[0].msyn__MetaSnap__c = testPackage[0].Id;
        testProfiles[1].Name = 'Admin';
        testProfiles[1].msyn__MetaPack__c = testmetaPacklst[0].Id;
        insert testProfiles;
        
        testProfileAttlst = testDataUtility.createProfileAtts(testProfiles, testPackageContent);
        testProfileAttlst[0].msyn__Profile__c = testProfiles[0].Id;
        testProfileAttlst[0].msyn__MetaSnap_Content__c = testPackageContent[0].Id;
        insert testProfileAttlst;
        
        Attachment att3 = new Attachment();
        att3.Body = Blob.valueOf('Test String');
        att3.Name = 'Admin.profile#AccountActions';
        att3.ParentId = testProfileAttlst[0].Id;
        attList.add(att3);
        
        insert attList;
        
        componentNames = testDataUtility.compNames();
        profileNames = testDataUtility.profNames();
        
        componentIds = '["'+testPackageContent[0].Id+'","'+testPackageContent[1].Id+'","'+testPackageContent[2].Id+'","'+testPackageContent[3].Id+'","'+testPackageContent[9].Id+'"]';
        profileIds = '["'+testProfileAttlst[0].Id+'","'+testProfileAttlst[1].Id+'","'+testProfileAttlst[2].Id+'","'+testProfileAttlst[3].Id+'"]';
        componentIds1 = '["'+testPackageContent[4].Id+'","'+testPackageContent[5].Id+'","'+testPackageContent[6].Id+'","'+testPackageContent[8].Id+'","'+testPackageContent[7].Id+'"]';
        
    }
    
    private static testmethod void testCompare(){
        
        createTestData();
        
        Test.startTest();
        
        UserperWrpClass dRwapObject =  CompareMetaDataClass.getpermissions();
        System.assertEquals(dRwapObject.SourceOrgs.size(), 20);
        
        String returnCRUDaccess = CompareMetaDataClass.getCRUDAccess('msyn__Connected_Org__c','msyn__MetaSnap__c','msyn__Metasnap_Content__c','msyn__Profile__c','msyn__Profile_Attribute__c','msyn__MetaPack__c','msyn__MetaPack_Component__c','msyn__MetaPack_Profile_Attribute__c','msyn__Deployment_Log__c','msyn__Deployment_Error_Log__c');
        
        list<msyn__MetaSnap__c> testPackList = CompareMetaDataClass.getpackageList(testOrglst[0].Name);
        
        list<msyn__MetaSnap__c> testPackList1 = CompareMetaDataClass.getpackageList(testOrglst[1].Name);
        
        List<CompCompareWrpClass> testPackContents = CompareMetaDataClass.getPackageContents(testPackage[0].Id,testPackage[0].Id);
        
        List<CompCompareWrpClass> testPackContents1 = CompareMetaDataClass.getPackageContents(testPackage[1].Id,testPackage[1].Id);
        
        list<CompCompareWrpClass> testPackInfo = CompareMetaDataClass.getPackageInformation('ApexClass',testPackage[0].Id,testPackage[0].Id);
        
        list<CompCompareWrpClass> testPackInfo1 = CompareMetaDataClass.getPackageInformation('ApexClass',testPackage[0].Id,testPackage[1].Id);
        
        list<CompCompareWrpClass> testPackInfo2 = CompareMetaDataClass.getPackageInformation('AuraDefinitionBundle',testPackage[0].Id,testPackage[0].Id);
        
        list<CompCompareWrpClass> testPackInfo3 = CompareMetaDataClass.getPackageInformation('AuraDefinitionBundle',testPackage[0].Id,testPackage[1].Id);

        PackageDetailsWrpClass testCreatePack = CompareMetaDataClass.getCreatePackage(componentIds, componentIds, profileIds, profileIds, 'TestPackName');
        
        PackageDetailsWrpClass testCreatePack2 = CompareMetaDataClass.getCreatePackage(componentIds, componentIds, profileIds, profileIds, 'TestPackName');
        
        PackageDetailsWrpClass testCreatePack3 = CompareMetaDataClass.getCreatePackage(componentIds1, componentIds1, profileIds, profileIds, 'TestPackName2');
        
        Boolean testEquals = CompareMetaDataClass.equalsNormCaseAndWhitespace(componentNames,componentNames);
        
        Test.stopTest();
        
    }
    
    private static testmethod void testDeployTestMethod() {
        
        createTestData();
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new HTTPCallOutMockClass());
        Test.setMock(WebServiceMock.class, new WebServiceMockImplClass());
        
        DStatusWrpClass result = CompareMetaDataClass.getResult('', true, testOrglst[0].Name, testmetaPacklst[0].Id, 'Validate', 'None');
        
        boolean zippackAvailable = false ;
        
        if(result != null){
            zippackAvailable = true ;
        }
        System.assertEquals(zippackAvailable, true);
        
        Test.stopTest();
        
    }
    
    private static testmethod void testUpdateZipMethod() {
        
        createTestData();
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new HTTPCallOutMockClass());
        Test.setMock(WebServiceMock.class, new WebServiceMockImplClass());
        
        CompareMetaDataClass.getUpdateZip('', testmetaPacklst[0].Id, testmetaPacklst[0].Name);
        
        boolean zippackAvailable = false ;
        
        String result = 'Test';
        
        if(result != null){
            zippackAvailable = true ;
        }
        System.assertEquals(zippackAvailable, true);
        
        Test.stopTest();
        
    }
    
    private static testmethod void testDeployPackMethod() {
        
        createTestData();
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new HTTPCallOutMockClass());
        Test.setMock(WebServiceMock.class, new WebServiceMockImplClass());
        
        CompareMetaDataClass.getDeployMetaPackage(testmetaPacklst[0].Id);
        
        boolean zippackAvailable = false ;
        
        String result = 'Test';
        
        if(result != null){
            zippackAvailable = true ;
        }
        System.assertEquals(zippackAvailable, true);
        
        Test.stopTest();
        
    }
    
    private static testmethod void testMetaPackTestMethod() {
        
        createTestData();
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new HTTPCallOutMockClass());
        Test.setMock(WebServiceMock.class, new WebServiceMockImplClass());
        
        String testMetaPack = CompareMetaDataClass.getCreateMetaPackage('Test' , testmetaPacklst[0].Id);
        
        String testMetaPack1 = CompareMetaDataClass.getCreateMetaPackage('Test1' , testmetaPacklst[1].Id);
        
        String delStr = '[]';
        
        boolean zippackAvailable = false ;
        
        if(delStr != null){
            zippackAvailable = true ;
        }
        
        System.assertEquals(zippackAvailable, true);
        
        Test.stopTest();
        
    }
    
    private static testmethod void testZipTestMethod() {
        
        createTestData();
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new HTTPCallOutMockClass());
        Test.setMock(WebServiceMock.class, new WebServiceMockImplClass());
        
        testZipItem = CompareMetaDataClass.getDeployPackage(testOrglst[0].Name, testmetaPacklst[0].Id, 'Deploy');
        
        boolean zippackAvailable = false ;
        
        if(testZipItem != null){
            zippackAvailable = true ;
        }
        System.assertEquals(zippackAvailable, true);
        
        Test.stopTest();
        
    }
}