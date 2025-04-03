/**
 * @description Service class that handles API callouts to the Exchange Rate API
 * Students will implement the methods to make callouts and process responses
 */ 
public class ExchangeRateService implements Callable {
    
    private static final String NAMED_CREDENTIAL = 'ExchangeRate_API';

    private Exchange_Rate_API_Config__mdt API_CONFIG = [SELECT Id, API_Key__c, Base_Currency__c FROM Exchange_Rate_API_Config__mdt LIMIT 1];

    // The base currency to use for exchange rates
    // TODO: Maybe convert this to a custom metadata config
    //private static final String BASE_CURRENCY = 'USD';
    private final String BASE_CURRENCY = API_CONFIG.Base_Currency__c;
    
    public ExchangeRateService() {
    }

    public Object call(String action, Map<String, Object> params) {
        switch on action {
          when 'updateExchangeRates' {
            this.API_CONFIG = (Exchange_Rate_API_Config__mdt)params.get('config');
            return updateExchangeRates();
          }
          when else {
           throw new ExchangeRateServiceCustomException('Unknown action name: ' + action);
          }
        }
    }

    /**
     * @description Makes a callout to the Exchange Rate API to get the latest exchange rates
     * @return ExchangeRateWrapper containing the response data
     */
    public ExchangeRateWrapper getLatestRates() {
        String endpoint = 'callout:' + NAMED_CREDENTIAL + this.API_CONFIG.API_Key__c + 'latest' + this.API_CONFIG.Base_Currency__c;
        HttpRequest req = new HttpRequest(); 
        req.setEndpoint(endpoint); 
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        HttpResponse res = new Http().send(req); 
        if(res.getStatusCode() == 200) {
            ExchangeRateWrapper wrp = ExchangeRateWrapper.parse(res.getBody()); 
            return wrp; 
        } else {
            throw new ExchangeRateServiceCustomException(
                'Error with Exchange Rate callout. StatusCode: ' + res.getStatusCode() + ' | Body: ' + res.getBody()
            ); 
        }
    }
    
    /**
     * @description Processes the exchange rate data and creates or updates records
     * @param rateData The wrapper containing exchange rate data
     * @return List<Exchange_Rate__c> The list of records created or updated
     */
    public List<Exchange_Rate__c> processRates(ExchangeRateWrapper rateData) {
        // TODO: Implement the method to process rates and create/update records
        List<Exchange_Rate__c> rateRecords = ExchangeRateWrapper.toExchangeRates(rateData);
        // try catch, create or update - upsert? 
        insert rateRecords; 
        return rateRecords;
    }
    
    /**
     * @description Combines getting and processing rates into a single operation
     * @return List<Exchange_Rate__c> The list of records created or updated
     */
    public List<Exchange_Rate__c> updateExchangeRates() {
        ExchangeRateWrapper latestRatesData = getLatestRates();
        List<Exchange_Rate__c> latestRateRecords = processRates(latestRatesData);
        return latestRateRecords;
    }

    public class ExchangeRateServiceCustomException extends Exception {
    }
}