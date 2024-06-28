public class IntuitApiService {
    public HttpResponse getTodaysUnpayedInvoices() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        String myquery = 'select * from Invoice where Balance > \'0.00\' and DueDate <= \'2024-06-30\' orderby DueDate desc';
        String encodedQuery = EncodingUtil.urlEncode(myquery, 'UTF-8');
        System.debug(encodedQuery);
        
        
        request.setEndpoint('callout:QBNamedCredential/query?minorversion=70&query='+ encodedQuery);
        request.setMethod('GET'); 
        //request.setHeader('Content-Type', 'application/text');
        request.setHeader('Content-Type', 'application/json');
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            // Successful response
            System.debug('Response: ' + response.getBody());
            System.debug(response);
        } else {
            // Error handling
            System.debug('Failed with status code: ' + response.getStatusCode());
            System.debug('Response: ' + response.getBody());
        }
        return response;
    }
    
}