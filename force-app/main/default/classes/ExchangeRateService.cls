/**
 * @description Service class that handles API callouts to the Exchange Rate API
 * Students will implement the methods to make callouts and process responses
 */ 
public class ExchangeRateService implements Callable {
    
    private static final String NAMED_CREDENTIAL = 'ExchangeRate_API'; // could also be rolled into metadata config

    // passed in from ExchangeRateScheduler through call method
    private Exchange_Rate_API_Config__mdt apiConfig;

    private void fetchMetadataConfig() {
        this.apiConfig = [SELECT Id, API_Key__c, Base_Currency__c, Apex_Class_Name__c, Apex_Method__c FROM Exchange_Rate_API_Config__mdt LIMIT 1];
    }

    /**
     * @description required call method to implement Callable interface
     * using the callable interface from the scheduled job removes the hard dependancy on this class from the schedulable class
     * that way when a job is scheduled, you can still modify this class/dependent classes without having to cancel scheduled jobs
     * @param action required string parameter for call method; this is used for method name
     * @param params required Map for call method; used to pass in Exchange_Rate_API_Config__mdt stored by 'config' key
     * @return Object required Object return type for call method; for updateExchangeRates it is the List<Exchange_Rate__c> that were created
     */
    public Object call(String action, Map<String, Object> params) {
        // get metadata config from Map params
        if(params.containsKey('config')) {
            this.apiConfig = (Exchange_Rate_API_Config__mdt)params.get('config');
        } else {
            Logger.error('config key is not in params Map as expected: ' + JSON.serialize(params)).addTag('ExchangeRate');
            Logger.saveLog();
            fetchMetadataConfig();
        }
        // call the method passed in from action
        switch on action {
          when 'updateExchangeRates' {
            return updateExchangeRates();
          }
          when else {
            String errorMsg = 'Unknown action name: ' + action;
            Logger.error(errorMsg).addTag('ExchangeRate');
            Logger.saveLog();
            throw new ExchangeRateServiceCustomException(errorMsg);
          }
        }
    }

    /**
     * @description Makes a callout to the Exchange Rate API to get the latest exchange rates
     * @return ExchangeRateWrapper containing the response data
     */
    public ExchangeRateWrapper getLatestRates() {
        // passed in from ExchangeRateScheduler through call method, but if we want to access this method directly will need to fetch metadata for configs
        if(this.apiConfig == null) {
            fetchMetadataConfig();
        }
        String endpoint = 'callout:' + NAMED_CREDENTIAL + this.apiConfig.API_Key__c + 'latest' + this.apiConfig.Base_Currency__c;
        HttpRequest req = new HttpRequest(); 
        req.setEndpoint(endpoint); 
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        HttpResponse res = new Http().send(req); 
        if(res.getStatusCode() == 200) {
            ExchangeRateWrapper wrp = ExchangeRateWrapper.parse(res.getBody()); 
            return wrp; 
        } else {
            String errorMsg = 'Error with Exchange Rate callout. StatusCode: ' + res.getStatusCode() + ' | Body: ' + res.getBody();
            Logger.error(errorMsg).addTag('ExchangeRate');
            Logger.saveLog();
            throw new ExchangeRateServiceCustomException(errorMsg); 
        }
    }
    
    /**
     * @description Processes the exchange rate data and creates or updates records
     * @param rateData The wrapper containing exchange rate data
     * @return List<Exchange_Rate__c> The list of records created or updated
     */
    public List<Exchange_Rate__c> processRates(ExchangeRateWrapper rateData) {
        List<Exchange_Rate__c> rateRecords = ExchangeRateWrapper.toExchangeRates(rateData);
        try{
            insert rateRecords; 
        } catch(Exception e) {
            Logger.error('Error inserting Exchange Rate records: ' + e.getMessage()).addTag('ExchangeRate');
            Logger.saveLog();
        } 
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

    /**
     * custom exception for errors from ExchangeRateService class
     */
    public class ExchangeRateServiceCustomException extends Exception {
    }
}