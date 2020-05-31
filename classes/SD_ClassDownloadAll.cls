/*****************************************************************************************************
* 
* @ Name        : SD_ClassDownloadAll
* @ Purpose     : Controller for retreivng attachments
* @ Author      : Pradeep Chary
* @ Test Class  : SD_ClassDownloadAllTest
*
* Date          | Developer Name              | Version   | Changes
* ====================================================================================================
* 17-04-2020    | pradeep.chary@absyz.com     | 1.0       | Initial Version
*
*****************************************************************************************************/

public with sharing class SD_ClassDownloadAll {
    
    /****************************************************************************************************
* @desc     	: Returns the attachments under a generic object
* @param    	: stRecordId
* @return   	: LIST<detailsClass> wrapper object
****************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static LIST<detailsClass> getAttachments(String stRecordId) {
        
        String theme = UserInfo.getUiThemeDisplayed();
        
        // return variable
        List<detailsClass> returnList = new List<detailsClass>();
        
        String CLSD0001 = System.Label.CLSD0001;  // SELECT Id FROM
        String CLSD0002 = System.Label.CLSD0002;  // WHERE Id = :stRecordId LIMIT 1
        String CLSD0003 = System.Label.CLSD0003;  // /
        String CLSD0004 = System.Label.CLSD0004;  // Id
        String CLSD0005 = System.Label.CLSD0005;  // No Files
        String CLSD0006 = System.Label.CLSD0006;  // Record does not exist
        String CLSD0007 = System.Label.CLSD0007;  // Please check record Id and object
        
        // checking for null and whitespaces
        if(String.isNotBlank(stRecordId)) {
            
            try {
                // retriving the object reference
                Id recordId = stRecordId;
                Schema.SObjectType objectType = recordId.getSObjectType();
                
                // dynamic query to retrieve the object Id
                String stQuery = CLSD0001 + ' ' + objectType + ' ' + CLSD0002;
                
                List<sObject> recordList = Database.query(stQuery);
                
                // checking if the record exists
                if(!recordList.isEmpty()) {
                    
                    // the record exists, retrieve the queried Id
                    String stActualId = String.valueOf(recordList[0].get(CLSD0004));
                    
                    // variables declaration
                    Set<Id> idsSet = new Set<Id>();
                    List<attachmentClass> fileList = new List<attachmentClass>();
                    
                    // Query to retrieve Content Document Link records with parent Id equal to stActualId
                    List<ContentDocumentLink> contentDocLinkList = [SELECT ContentDocumentId 
                                                                    FROM ContentDocumentLink 
                                                                    WHERE LinkedEntityId = :stActualId];
                    
                    for(ContentDocumentLink conDocLink : contentDocLinkList) {
                        idsSet.add(conDocLink.ContentDocumentId);
                    }
                    
                    // Based on the Content Document Link Ids retrieve the Content Version records
                    List<ContentVersion> versionList = [SELECT Id, ContentDocumentId, ContentSize, FileExtension, Owner.Name, 
                                                        OwnerId, LastModifiedDate, Title
                                                        FROM ContentVersion 
                                                        WHERE ContentDocumentId = :idsSet
                                                        AND IsLatest = true];
                    
                    // Mapping Content Version to wrapper object
                    if(!versionList.isEmpty()) {
                        for(ContentVersion record : versionList) {
                            attachmentClass file = new attachmentClass();
                            file.stRecordId = record.Id;
                            file.stDownloadId = record.ContentDocumentId;
                            file.stTitle = record.Title;
                            file.stOwner = record.Owner.Name;
                            file.stOwnerId = CLSD0003 + record.OwnerId;
                            file.stExtension = record.FileExtension;
                            file.inContentSize = record.ContentSize;
                            file.dtModifiedDate = record.LastModifiedDate;
                            fileList.add(file);
                        }
                    }
                    
                    // checking for null and error conditions
                    detailsClass response = new detailsClass();
                    if(UserInfo.getUiThemeDisplayed() == 'Theme4d' || Test.isRunningTest()) {
                        response.bLightningExperience = true;
                    }
                    if(!fileList.isEmpty()) {
                        response.recordList = fileList;
                    } else {
                        response.bEmpty = true;
                        response.stMessage = CLSD0005;
                    }
                    returnList.add(response);
                } else {
                    
                    // checking for condition if the record does not exist
                    detailsClass response = new detailsClass();
                    response.bError = true;
                    response.stMessage = CLSD0006;
                    returnList.add(response);
                }
            } catch (exception e) {
                // handling exceptions
                detailsClass response = new detailsClass();
                response.bError = true;
                response.stMessage = e.getMessage();
                returnList.add(response);
            }
        } else {
            
            // checking for condition if the record and sObject are valid
            detailsClass response = new detailsClass();
            response.bError = true;
            response.stMessage = CLSD0007;
            returnList.add(response);
        }
        
        return returnList;
    }
    
    // Wrapper class to return files details and handle error message if any
    public class detailsClass {
        @AuraEnabled public LIST<attachmentClass> recordList;
        @AuraEnabled public String stMessage;
        @AuraEnabled public Boolean bError;
        @AuraEnabled public Boolean bEmpty;
        @AuraEnabled public Boolean bLightningExperience;
        
        public detailsClass() {
            this.stMessage = '';
            this.bError = false;
            this.bEmpty = false;
            this.bLightningExperience = false;
        }
    }
    
    // Wrapper class to map Content version and Attachment to one
    public class attachmentClass {
        @AuraEnabled public String stRecordId;
        @AuraEnabled public String stBody;
        @AuraEnabled public String stDownloadId;
        @AuraEnabled public String stTitle;
        @AuraEnabled public String stOwner;
        @AuraEnabled public String stOwnerId;
        @AuraEnabled public String stExtension;
        @AuraEnabled public Integer inContentSize;
        @AuraEnabled public DateTime dtModifiedDate;
        
        public attachmentClass() {}
    }
}