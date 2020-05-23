/*******************************************************************************************************
* 
* @ Name    :   IFv2_ConcessionWorkflowHandlerTest
* @ Purpose :   Test data for IFv2_ConcessionWorkflowHandler
* @ Author  :   Kanchan
* @ Class	: 	IFv2_ConcessionWorkflowHandler
*
*   Date            |  Developer Name           |  Version      |  Changes
* ======================================================================================================
*   15-01-2019      |  Kanchan.b@absyz.com      |  1.0          |  Initial Version
*
*******************************************************************************************************/
@isTest(SeeAllData=true)
public class IFv2_ConcessionWorkflowHandlerTest {
    
    @isTest
    static void testCall(){
        Test.setMock(WebServiceMock.class, new SG_WF_WS_Sap_Con_CreateNotif_Mock());
        
        Profile p =[SELECT ID FROM Profile Where Name='System Administrator'];
        User u = new user();
        u.alias = 'alias';
        u.LastName = 'lastName';
        u.Username = 'test@testingfsagdgdsbggfbsajkdf.com';
        u.Email = 'test@seg-automotive.com';
        u.TimeZoneSidKey = 'Europe/Berlin';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.ProfileId = p.Id;
        u.Department = '123';
        insert u;
        
        
        IFv2_request__c req = new IFv2_request__c();
        req.Workflow__c='Concession';
        req.Status__c = 'Draft';
        
        req.Approver1__c=u.id;
        req.CategoryCodeDescription__c='QS-RM001-0010 Concession inhouse production (product)';
        req.MaterialNo__c='123';
        req.SupplierName__c='123';
        req.Full8Dreportnecessary__c='No';
        req.SAPInstance__c='PSI';
        req.Remarks__c='Remark';
        req.ConcessionDescription__c='concession desc';
        insert req;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(req.id);
        req1.setSubmitterId(u.Id); 
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
        
        
        Account acc= new Account();
        acc.IFv2_Request__c=req.Id;
        acc.IFv2_Plant__c='3123123123123123123';
        acc.Name='test Class';
        acc.IFv2_SupplierNo__c='123';
        acc.IFv2_CustomerNo__c='88';
        acc.IFv2_Furtherprocessing__c='123123123123332';
        acc.IFv2_Escalatetomanagementlevel__c='YES';
        acc.IFv2_ContainmentAction2__c='Action';
        acc.IFv2_ContainmentAction3__c='Action';
        acc.IFv2_ContainmentAction4__c='Action';
        acc.IFv2_ContainmentAction5__c='Action';
        insert acc;
        
        req.Account__c=acc.id;
        update req;
        
        
        List<String> reqList = new List<String>();
        reqList.add(req.Id);
        Map<String, String> httpHeaders = new Map<String,String>();
        httpHeaders.put('TEST', 'TEST');
        
        Test.startTest();
        IFv2_ConcessionWorkflowHandler.createNotificationWrapper(reqList, httpHeaders);
        List<IFv2_request__c> reqLess = [SELECT Id FROM IFv2_request__c LIMIT 1];
        System.assertEquals(true, reqLess.size()>0);
        Test.stopTest();
    }
    
    @isTest
    static void testCallTwo(){
        Test.setMock(WebServiceMock.class, new SG_WF_WS_Sap_Con_CreateNotif_Mock());
        
        Profile p =[SELECT ID FROM Profile Where Name='System Administrator'];
        User u = new user();
        u.alias = 'alias';
        u.LastName = 'lastName';
        u.Username = 'test@testingfsagdgdsbggfbsajkdf.com';
        u.Email = 'test@seg-automotive.com';
        u.TimeZoneSidKey = 'Europe/Berlin';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.ProfileId = p.Id;
        u.Department = '123';
        insert u;
        
        IFv2_request__c req = new IFv2_request__c();
        req.Workflow__c='Concession';
        req.Status__c = 'Draft';
        
        req.Approver1__c=u.id;
        req.CategoryCodeDescription__c='QS-RM001-0010 Concession inhouse production (product)';
        req.MaterialNo__c='123';
        req.SupplierName__c='123';
        req.Full8Dreportnecessary__c='Yes';
        req.Remarks__c='Remark';
        req.ConcessionDescription__c='concession desc';
        insert req;
        
        List<String> reqList = new List<String>();
        reqList.add(req.Id);
        Map<String, String> httpHeaders = new Map<String,String>();
        httpHeaders.put('TEST', 'TEST');
        
        Test.startTest();
        IFv2_ConcessionWorkflowHandler.createNotificationWrapper(reqList, httpHeaders);
        List<IFv2_request__c> reqLess = [SELECT Id FROM IFv2_request__c LIMIT 1];
        System.assertEquals(true, reqLess.size()>0);
        Test.stopTest();
        
    }
    
}