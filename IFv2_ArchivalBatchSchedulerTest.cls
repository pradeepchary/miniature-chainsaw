/*******************************************************************************************************
* 
* @ Name 		: 	IFv2_ArchivalBatchSchedulerTest
* @ Purpose 	: 	Test class to Scheduler class for Archival Batch
* @ Author		: 	Prasad Vivek
* @ Class Name	:	IFv2_ArchivalBatchScheduler
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   28-10-2018      |  vivek.kothalanka@absyz.com   |  1.0          |  Initial Version
*******************************************************************************************************/
@isTest
public class IFv2_ArchivalBatchSchedulerTest {
    
    //Test data set up method
    @TestSetUp 
    Public static void setUpData() {
        
        //Inserting test data for schedule class.
        IFv2_Workflow__c workflowRecord = IFv2_testDataUtility.createWorkflowCustomSetting();
        insert workflowRecord;
    }
    //Method to call schedule class
    Public static TestMethod void schedlueMethod() {
        
        //Creating cron Logic
        String cronValue = '0 0 0 28 2 ? *';
        
        test.startTest();     
        IFv2_ArchivalBatchScheduler userPermissionSetAssignmentBatch = new IFv2_ArchivalBatchScheduler(); 
        String jobId = System.schedule('ArchivalBatchScheduler',cronValue,userPermissionSetAssignmentBatch);
        CronTrigger crontrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                                   FROM CronTrigger 
                                   WHERE id = :jobId];
        system.assertEquals(0, crontrigger.TimesTriggered);
        test.stopTest();
    }
}