global class Intuit extends Auth.AuthProviderPluginClass {
               
    public String redirectUrl; // use this URL for the endpoint that the authentication provider calls back to for configuration
    private String key;
    private String secret;
    private String scope;
    private String authUrl;    // application redirection to the Intuit website for authentication and authorization
    private String accessTokenUrl; // uri to get the new access token from Intuit  using the GET verb
    private String customMetadataTypeApiName = 'IntuitConnectSetting__mdt'; // api name for the custom metadata type created for this auth provider
    private String userAPIUrl; // api url to access the user in Intuit
    private String userAPIVersionUrl; // version of the user api url to access data from Intuit
    

    global String getCustomMetadataType() {
        return customMetadataTypeApiName;
    }

    global PageReference initiate(Map<string,string> authProviderConfiguration, String stateToPropagate) {
        System.debug('RER initiate');
        authUrl = authProviderConfiguration.get('Auth_Url__c');
        //System.debug('authUrl' + authUrl);
        scope = authProviderConfiguration.get('Scope__c');
        System.debug('scope' + scope);
        redirectUrl = authProviderConfiguration.get('Redirect_uri__c');
        //System.debug('redirectUrl' + redirectUrl);
        //Here the developer can build up a request of some sort
        //Ultimately they’ll return a URL where we will redirect the user
        key = authProviderConfiguration.get('Key__c');
        //System.debug('key' + key);
        String url = authUrl + '?client_id='+ key +'&scope='+ scope +'&redirect_uri='+ redirectUrl + '&response_type=code' +  '&state=' + stateToPropagate;
        
        System.debug('url' + url);
        return new PageReference(url);
     }

    global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state ) {
        //Here, the developer will get the callback with actual protocol.  
        //Their responsibility is to return a new object called AuthProviderToken
        //This will contain an optional accessToken and refreshToken
        System.debug('handleCallback');
        System.debug(authProviderConfiguration);
        key = authProviderConfiguration.get('Key__c');
        secret = authProviderConfiguration.get('Secret__c');
        accessTokenUrl = authProviderConfiguration.get('Access_Token_Url__c');
        redirectUrl = authProviderConfiguration.get('Redirect_uri__c');
        Map<String,String> queryParams = state.queryParameters;
        String code = queryParams.get('code');
        String sfdcState = queryParams.get('state');
       
        System.debug(redirectUrl);
        HttpRequest req = new HttpRequest();
        /*
        Map<String, Object> jsonMap = new Map<String, Object>();
        jsonMap.put('code', code);
        jsonMap.put('redirect_uri', redirectUrl);
        jsonMap.put('grant_type', 'authorization_code'); 
        String jsonString = JSON.serialize(jsonMap);
        */
        String body = 'grant_type=authorization_code&code=' + code + '&redirect_uri=' + redirectUrl;
        Blob blobData = Blob.valueOf(key + ':' + secret);
        String base64EncodedString = EncodingUtil.base64Encode(blobData);
        req.setEndpoint(accessTokenUrl);
        req.setBody(body);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setHeader('Host','oauth.platform.intuit.com');
        req.setHeader('Authorization','Basic ' + base64EncodedString);
        req.setMethod('POST');
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        System.debug(responseBody);
        String accessToken = getValueFromResponse(responseBody, 'access_token');
        System.debug('accessToken');
        System.debug(accessToken);
        //Parse access token value
        String refreshToken = getValueFromResponse(responseBody, 'refresh_token');
        //Parse refresh token value
        System.debug('refreshToken');
        System.debug(refreshToken);
        return new Auth.AuthProviderTokenResponse('Intuit', accessToken, refreshToken, sfdcState);
        //don’t hard-code the refresh token value!
     }


      global Auth.UserData  getUserInfo(Map<string,string> authProviderConfiguration, Auth.AuthProviderTokenResponse response) { 
          //Here the developer is responsible for constructing an Auth.UserData object
          String token = response.oauthToken;
          HttpRequest req = new HttpRequest();
          userAPIUrl = authProviderConfiguration.get('API_User_Url__c');
          userAPIVersionUrl = authProviderConfiguration.get('API_User_Version_Url__c');
          scope = authProviderConfiguration.get('Scope__c');
          req.setHeader('Authorization', 'Bearer ' + token);
          req.setEndpoint(userAPIUrl);
          //req.setHeader('Content-Type','application/xml');
          req.setHeader('Accept','application/json');
          req.setMethod('GET');
          
          Http http = new Http();
          HTTPResponse res = http.send(req);
          String responseBody = res.getBody();
          System.debug('Get USER Data');
          System.debug(responseBody);
          String id = getValueFromResponse(responseBody, 'sub');
          String fname = (scope.contains('Profile')) ? getValueFromResponse(responseBody, 'givenName') : '' ;
          String lname = (scope.contains('Profile')) ? getValueFromResponse(responseBody, 'familyName') : '' ; 
          String flname = fname + ' ' + lname;
          String uname = (scope.contains('Email')) ? getValueFromResponse(responseBody, 'email') : '' ; 
          String emailVerified = (scope.contains('Email')) ? getValueFromResponse(responseBody, 'emailVerified') : '' ;  
          String phoneNumber =  (scope.contains('Phone')) ? getValueFromResponse(responseBody, 'phoneNumber') : '' ; 
          String phoneNumberVerified =  (scope.contains('Phone')) ? getValueFromResponse(responseBody, 'phoneNumberVerified') : '' ; 
          String locale = 'US';
          Map<String,String> provMap = new Map<String,String>();
          provMap.put('phoneNumber', phoneNumber);
          provMap.put('phoneNumberVerified', phoneNumberVerified);
          provMap.put('phoneNumber', phoneNumber);
          provMap.put('phoneNumberVerified', phoneNumberVerified);
          return new Auth.UserData(id, fname, lname, flname, uname,
               'what', locale, null, 'Intuit', null, provMap);
     }
     
     private String getTokenValueFromResponse(String response, String token, String ns) {
         Dom.Document docx = new Dom.Document();
         docx.load(response);
         String ret = null;

         dom.XmlNode xroot = docx.getrootelement() ;
         if(xroot != null){
            ret = xroot.getChildElement(token, ns).getText();
         }
         return ret;
     }  

     private String getValueFromResponse(String response, String token) {
         
        Map<String, Object> myJmap = (Map<String, Object>) JSON.deserializeUntyped(response);

         return myJmap.get(token).toString();
     }

     global class IntuitException extends Exception {}

}