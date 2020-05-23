/*******************************************************************************************************
* 
* @ Name		:  mv2_ConnectOrgClass
* @ Purpose		:  This class is used to authunticate organizations
* @ Author		:  Absyz
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   15-May-2020     |  Absyz					    |  1.0          |  Initial Version

*******************************************************************************************************/

public with sharing class mv2_ConnectOrgClass {
    
/*********************************************************************************************************************
Method       : getOauthURL
Input        : MV2_ConnectedOrg__c
Return Type  : String
Desc         : Retruns the URL which is used to get the access code
*********************************************************************************************************************/
    
    @AuraEnabled
    public static String updateOauthURL(MV2_ConnectedOrg__c newOrg) {
        //local variable
        String url = '';
        
        //building the url depending on the type of Org
        if(newOrg != null) {
            if(String.isNotBlank(newOrg.OrgType__c)) {
                if (newOrg.OrgType__c == 'Sandbox') {
                    url = 'https://test.salesforce.com/services/oauth2/authorize?response_type=code&client_id=';
                } else if (newOrg.OrgType__c == 'Production') {
                    url = 'https://login.salesforce.com/services/oauth2/authorize?response_type=code&client_id=';
                } else {
                    if(String.isNotBlank(newOrg.CustomURL__c)) {
                        url = newOrg.CustomURL__c + '/services/oauth2/authorize?response_type=code&client_id=';
                    }
                }
                
                //Getting the Connected app Keys from Custom Setting
                MV2_ApplicationValue__c appLicationSetting = MV2_ApplicationValue__c.getInstance();
                url = url + appLicationSetting.ConsumerKey__c;
                url = url + '&redirect_uri=oob&state=mystate';
            }
        }
        
        return url;
    }
    
/*********************************************************************************************************************
Method       : insertOrg
Input        : MV2_ConnectedOrg__c
Return Type  : None
Desc         : Creates the Authentication Org information
*********************************************************************************************************************/
    
    @AuraEnabled
    public static String insertOrg(MV2_ConnectedOrg__c newOrg) {
        
        try {
            
            if(newOrg != null) {
                if(String.isNotBlank(newOrg.OrgType__c)) {
                    
                    List < MV2_ConnectedOrg__c > newOrglist = new List < MV2_ConnectedOrg__c > ();
                    
                    //local variables
                    String Accesscode = newOrg.AuthorizationCode__c.replace('=', '%3D').trim();
                    String header = '';
                    String endpoint = '';
                    String loginUrl = '';
                    String refreshToken = '';
                    String accessToken = '';
                    
                    //building the url depending on the type of Org
                    if (newOrg.OrgType__c == 'Sandbox') {
                        loginUrl = 'https://test.salesforce.com';
                    } else if (newOrg.OrgType__c == 'Production') {
                        loginUrl = 'https://login.salesforce.com';
                    } else {
                        loginUrl = newOrg.CustomURL__c;
                    }
                    
                    //getting the custom setting value
                    MV2_ApplicationValue__c appSetting = MV2_ApplicationValue__c.getInstance();
                    
                    //Building the Body of the Request
                    String reqbody = 'grant_type=authorization_code&client_id=' + appSetting.ConsumerKey__c +
                        '&client_secret=' + appSetting.ConsumerSecret__c + '&code=' + Accesscode + '&redirect_uri=oob';
                    
                    endpoint = loginUrl + '/services/oauth2/token?' + reqbody;
                    
                    //HTTP Callout
                    Map < String, Object > mapReqBody = getHTTPResponse(endpoint, header, 'POST');
                    
                    if(!mapReqBody.isEmpty()) {
                        
                        //getting the refresh token and access token
                        refreshToken = String.valueOf(mapReqBody.get('refresh_token'));
                        accessToken = String.valueOf(mapReqBody.get('access_token'));
                        
                        header = String.valueOf(mapReqBody.get('token_type')) + ' ' + accessToken;
                        endpoint = loginUrl + '/services/oauth2/userinfo' ;
                        
                        String remoteSiteURL = String.valueOf(mapReqBody.get('instance_url'));
                        
                        // User Info       
                        Map < String, Object > mapReqInfoBody = getHTTPResponse(endpoint, header, 'POST');
                        
                        if(!mapReqInfoBody.isEmpty()) {
                            
                            // Query Request
                            Map < String, Object > mapURI = (Map < String, object > ) mapReqInfoBody.get('urls');
                            
                            if(!mapURI.isEmpty()) {
                                
                                String queryUri = String.valueOf(mapURI.get('query')).replace('{version}', appSetting.Version__c);
                                
                                endpoint = queryUri + '?q=select+id+from+Organization+limit+1';
                                
                                //Getting the org Id from the call 
                                Map < String, Object > mapReqQryBody = getHTTPResponse(endpoint, header, 'GET');
                                
                                if(!mapReqQryBody.isEmpty()) {
                                    
                                    String strOrg = JSON.serialize(mapReqQryBody.get('records'));
                                    
                                    List < Organization > OrgList = (List < Organization > ) JSON.deserialize(strOrg, List < Organization > .class);
                                    
                                    if(!OrgList.isEmpty()) {
                                        String orgIDs = String.valueOf(OrgList[0].Id);
                                        
                                        newOrg.OrgId__c = orgIDs;
                                        newOrgList.add(newOrg);
                                        
                                        if (!newOrgList.isEmpty()) {
                                            Database.saveresult[] sr = Database.insert(newOrglist, False);
                                            //        ErrorLogUtility.processErrorLogs(sr, newOrglist, 'OrgAuthorizationClass', 'insertOrg', 'MV2_ConnectedOrg__c', 'Insert');
                                        }
                                        
                                        //Create Authorization Detail Information 
                                        List < MV2_AuthorizationValue__c > authorizationDetaillist = new List < MV2_AuthorizationValue__c > ();
                                        
                                        MV2_AuthorizationValue__c authorizationDetail = new MV2_AuthorizationValue__c();
                                        authorizationDetail.Name = OrgList[0].Id;
                                        authorizationDetail.OrgId__c = OrgList[0].Id;
                                        authorizationDetail.Username__c = newOrg.Username__c;
                                        authorizationDetail.AccessToken__c = accessToken;
                                        authorizationDetail.RefreshToken__c = refreshToken;
                                        authorizationDetail.EndPointURL__c = remoteSiteURL;
                                        authorizationDetaillist.add(authorizationDetail);
                                        
                                        if (!authorizationDetaillist.isEmpty()) {
                                            Database.saveresult[] sr = Database.insert(authorizationDetaillist, False);
                                            //        msyn.ErrorLogUtility.processErrorLogs(sr, authorizationDetaillist, 'OrgAuthorizationClass', 'insertOrg', 'Authorization_Value__c', 'Insert'); /* Custom settings updated after the Security Review, Date:01/10/2017 at 03:00 AM  */
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            return null;
        }
        
        Catch(Exception ex) {
            return ex.getMessage();
        }
        
    }
    
/*********************************************************************************************************************
Method : getHTTPResponse
Input : (String endpoint, String header, String method)
Return Type : Map<String, object>
Desc   : Used for the HTTP Callout
*********************************************************************************************************************/
    
    public static Map < String, object > getHTTPResponse(String endpoint, String header, String method) {
        //new Http Request
        
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint(endpoint);
        if (header != '') {
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', header);
        }
        Http httpReq = new Http();
        
        HTTPResponse res = httpReq.send(req);
        
        Boolean redirect = false;
        if(res.getStatusCode() >=300 && res.getStatusCode() <= 307 && res.getStatusCode() != 306) {
            do {
                // reset the value each time
                redirect = false;
                // get location of the redirect
                String loc = res.getHeader('Location');
                if(loc == null) {
                    redirect = false;
                    continue;
                }
                req = new HttpRequest();
                req.setEndpoint(loc);
                req.setMethod(method);
                res = httpReq.send(req);
                if(res.getStatusCode() != 500) { // 500 = fail
                    if(res.getStatusCode() >=300 && res.getStatusCode() <= 307 && res.getStatusCode() != 306) {
                        redirect= true;
                    }
                }
            } while (redirect && Limits.getCallouts() != Limits.getLimitCallouts());
        }
        
        return (Map < String, object > ) JSON.deserializeUntyped(res.getBody());
    }
}