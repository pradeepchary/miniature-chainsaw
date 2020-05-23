/*******************************************************************************************************
* 
* @ Name		:  mv2_GitDataClass
* @ Purpose		:  This class is used to retrieve and commit data from GIT
* @ Author		:  Absyz
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   21-May-2020     |  Absyz					    |  1.0          |  Initial Version

*******************************************************************************************************/

public with sharing class mv2_GitDataClass {

    @AuraEnabled(cacheable=true)
    public static List<MV2_Branch__c> retrieveRepositoriesBranch() {
        List<MV2_Branch__c> branchList = [SELECT Id, Name, Repository__r.Name FROM MV2_Branch__c];

        if(!branchList.isEmpty()) {
            return branchList;
        } else {
            return new List<MV2_Branch__c>();
        }
    }

    @AuraEnabled
    public static String retrieveCommitData(List<String> stCommitIdList) {
        
        if(!stCommitIdList.isEmpty()) {
            try {
                MV2_GitSettings__c settings = MV2_GitSettings__c.getInstance('GitHub');
                
                if(settings != null) {
                    if(String.isNotBlank(settings.AccessToken__c)) {

                        List<MV2_Commit__c> commitList = [SELECT Id, TreeUrl__c FROM MV2_Commit__c WHERE Id IN :stCommitIdList];

                        if(!commitList.isEmpty()) {
                            MV2_Commit__c commitRecord = commitList[0];

                            String stEndpoint = commitRecord.TreeUrl__c;
                            String stHeader = 'Bearer ' + settings.AccessToken__c;

                            String response = mv2_GitSettingsClass.getHTTPResponse(stEndpoint, stHeader, 'GET', '');
                            
                            if(String.isNotBlank(response)) {
                                
                                mv2_ParseCommitTrees parseResponse = mv2_ParseCommitTrees.parse(response);

                                return retrieveBlobData(parseResponse, stHeader, commitRecord.Id);
                            }
                        }
                    }
                }
            } catch (Exception e) {
                return e.getMessage();
            }
        }
        return 'error';
    }

    public static String retrieveBlobData(mv2_ParseCommitTrees commitTree, String header, String commitId) {
        
        if(commitTree != null) {
            if(!commitTree.tree.isEmpty()) {

                Map<String, mv2_ParseCommitTrees.Tree> treeMap = new Map<String, mv2_ParseCommitTrees.Tree>();
                List<String> stShaList = new List<String>();

                for(mv2_ParseCommitTrees.Tree tree : commitTree.tree) {
                    treeMap.put(tree.sha, tree);
                    stShaList.add(tree.sha);
                }

                if(!stShaList.isEmpty()) {
                    try {
                        String endpoint = 'https://api.github.com/repos/pradeepchary/miniature-chainsaw/git/blobs/' + stShaList[0];

                        String blobResponse = mv2_GitSettingsClass.getHTTPResponse(endpoint, header, 'GET', '');
                            
                        if(String.isNotBlank(blobResponse)) {
                            System.debug('blob-response = ' + blobResponse);

                            Mv2_ParseBlob parseBlobResponse = Mv2_ParseBlob.parse(blobResponse);

                            if(parseBlobResponse != null) {
                                mv2_ParseCommitTrees.Tree treeRecord = treeMap.get(parseBlobResponse.sha);

                                Attachment record = new Attachment();
                                record.Body = EncodingUtil.base64Decode(parseBlobResponse.content);
                                record.ParentId = commitId;
                                record.Name = treeRecord.path;
                                insert record;

                                return 'success';
                            }
                        }
                    } catch (Exception e) {
                        return e.getMessage();
                    }
                }
            }
        }

        return 'error';
    }

    @AuraEnabled
    public static String deployCommitData(String stCommitId, String stBranchId) {
        try {
            if(String.isNotBlank(stBranchId)) {
                List<MV2_Branch__c> branchList = [SELECT Id, Name, Repository__r.GitRefsUrl__c, Repository__r.BlobsUrl__c, Repository__r.TreesUrl__c, Repository__r.GitCommitsUrl__c FROM MV2_Branch__c WHERE Id = :stBranchId];
                
                if(!branchList.isEmpty()) {
                    MV2_Branch__c branchRecord = branchList[0];

                    MV2_GitSettings__c settings = MV2_GitSettings__c.getInstance('GitHub');
                    
                    if(settings != null) {
                        if(String.isNotBlank(settings.AccessToken__c)) {

                            List<String> refsSplitList = (branchRecord.Repository__r.GitRefsUrl__c).split('\\{');

                            String stEndpoint = refsSplitList[0] + '/heads/' + branchRecord.Name;
                            String stHeader = 'Bearer ' + settings.AccessToken__c;

                            String refResponse = mv2_GitSettingsClass.getHTTPResponse(stEndpoint, stHeader, 'GET', '');
                            
                            if(String.isNotBlank(refResponse)) {
                                Mv2_ParseRefs parseRefResponse = Mv2_ParseRefs.parse(refResponse);

                                if(parseRefResponse != null) {
                                    return getGitTree(parseRefResponse, stHeader, stCommitId, branchRecord);
                                }
                            }
                        }
                    }
                }
            }
            
        } catch (Exception e) {
            return e.getMessage();
        }
        return 'error';
    }

    public static String getGitTree(Mv2_ParseRefs response, String stHeader, String stCommitId, MV2_Branch__c branchRecord) {

        if(String.isNotBlank(response.object_Z.sha)) {
            List<MV2_Commit__c> commitRecordList = [SELECT Id, Name, TreeUrl__c, TreeSha__c, ParentsSha__c FROM MV2_Commit__c WHERE Name = :response.object_Z.sha];

            if(!commitRecordList.isEmpty()) {
                return insertBlobToGit(commitRecordList[0], stHeader, stCommitId, branchRecord);

            } else {

                if(String.isNotBlank(response.object_Z.url)) {

                    String stEndpoint = response.object_Z.url;

                    String commitResponse = mv2_GitSettingsClass.getHTTPResponse(stEndpoint, stHeader, 'GET', '');

                    if(String.isNotBlank(commitResponse)) {

                        mv2_ParseCommitSingleTree parseCommitResponse = mv2_ParseCommitSingleTree.parse(commitResponse.replace('date', 'date_Z'));

                        if(parseCommitResponse != null) {
                            System.debug('parseCommitResponse = ' + parseCommitResponse);

                            MV2_Commit__c record = new MV2_Commit__c();
                            record.Name = parseCommitResponse.sha;
                            record.TreeSha__c = parseCommitResponse.tree.sha;
                            record.TreeUrl__c = parseCommitResponse.tree.url;
                            if(!parseCommitResponse.parents.isEmpty()) {
                                record.ParentsSha__c = parseCommitResponse.parents[0].url;
                            }

                            return insertBlobToGit(record, stHeader, stCommitId, branchRecord);
                        }
                    }
                }
            }
        }
        
        return 'error';
    }

    public static String insertBlobToGit(MV2_Commit__c commitRecord, String stHeader, String stCommitId, MV2_Branch__c branchRecord) {
        List<Attachment> attachList = [Select Name, Body FROM Attachment WHERE parentId=:stCommitId LIMIT 1];
        if(!attachList.isEmpty()) {

            List<String> blobSplitList = (branchRecord.Repository__r.BlobsUrl__c).split('\\{');

            String stEndpoint = blobSplitList[0];
            String stJsonInput = '{\n' +
            ' "content" : "' + EncodingUtil.base64Encode(attachList[0].Body) + '",\n' +
            ' "encoding" : "base64" \n' +
            '}';

            String blobResponse = mv2_GitSettingsClass.getHTTPResponse(stEndpoint, stHeader, 'POST', stJsonInput);

            if(String.isNotBlank(blobResponse)) {
                mv2_ParseSingleBlob parseBlobResponse = (Mv2_ParseSingleBlob) System.JSON.deserialize(blobResponse, Mv2_ParseSingleBlob.class);
                
                if(parseBlobResponse != null) {

                    List<String> treeSplitList = (branchRecord.Repository__r.TreesUrl__c).split('\\{');

                    stEndpoint = treeSplitList[0];

                    String stTreeJsonInput = '{\n' +
                    '"base_tree": "' + commitRecord.TreeSha__c + '",\n' +
                    '   "tree": [\n' +
                    '{\n' +
                    '"path": "' + attachList[0].Name + '",\n' +
                    '"mode": "100644",\n'+
                    '"type": "blob",\n'+
                    '"sha": "' + parseBlobResponse.sha +'"\n'+
                    '}\n' +
                    ']\n'+
                    '}';

                    String treeResponse = mv2_GitSettingsClass.getHTTPResponse(stEndpoint, stHeader, 'POST', stTreeJsonInput);

                    if(String.isNotBlank(treeResponse)) {
                        mv2_ParseCommitTrees parseTreeResponse = mv2_ParseCommitTrees.parse(treeResponse);

                        if(parseTreeResponse != null) {
                            List<String> commitSplitList = (branchRecord.Repository__r.GitCommitsUrl__c).split('\\{');
                            stEndpoint = commitSplitList[0];

                            String stCommitJsonInput = '{\n' +
                            '"message" : "Success from Apex v3",\n' +
                            '"parents" : ["' + commitRecord.ParentsSha__c + '"],\n' +
                            '"tree" : "' + parseTreeResponse.sha + '"\n' +
                            '}';

                            String commitResponse = mv2_GitSettingsClass.getHTTPResponse(stEndpoint, stHeader, 'POST', stCommitJsonInput);

                            if(String.isNotBlank(commitResponse)) {

                                mv2_ParseCommitSingleTree parseCommitResponse = mv2_ParseCommitSingleTree.parse(commitResponse);

                                if(parseCommitResponse != null) {

                                    List<String> refsSplit2List = (branchRecord.Repository__r.GitRefsUrl__c).split('\\{');

                                    stEndpoint = refsSplit2List[0] + '/heads/' + branchRecord.Name;

                                    String stHeadjsonInput = '{\n' +
                                    '"sha": "' + parseCommitResponse.sha + '",\n' +
                                    '"force": true\n' +
                                    '}';

                                    String updateResponse = mv2_GitSettingsClass.getHTTPResponse(stEndpoint, stHeader, 'PATCH', stHeadjsonInput);

                                    if(String.isNotBlank(updateResponse)) {
                                        System.debug('updateResponse = ' + updateResponse);

                                        return 'success';
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return 'error';
    }

    public class mv2_ParseSingleBlob {

        public String url;
        public String sha;

    }
}