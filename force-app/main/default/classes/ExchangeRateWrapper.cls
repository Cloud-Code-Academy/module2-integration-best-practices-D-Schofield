/**
 * @description Wrapper class to deserialize the JSON response from the Exchange Rate API
 * Students will implement the properties and methods to process the data
 * @pmd suppress FormalParameterNamingConventions
 * @justification field names match the response from API, but don't confirm to PMD naming convention
 * leaving it to match API for simplicity
 */
public class ExchangeRateWrapper {
   
    // TODO: Implement properties to match the JSON structure of the API response
    // Sample response:
    // {
    //   "base_code": "USD",
    //   "time_last_update_unix": 1740690001,
    //   "conversion_rates": {
    //     "EUR": 0.9488,
    //     "GBP": 0.8393,
    //     "JPY": 136.57,
    //     ...
    //   }
    // }

    public String base_code; 
    public String time_last_update_unix; // would UTC String be easier/better to work with? - DateTime.valueOfGMT(lastUpdateUTC); 
    public Map<String, Decimal> conversion_rates; 

    public ExchangeRateWrapper(String baseCurrencyCode, String time_last_update_unix, Map<String, Decimal> conversion_rates) {
        this.base_code = baseCurrencyCode;
        this.time_last_update_unix = time_last_update_unix;
        this.conversion_rates = conversion_rates;
    }


    // used in ExchangeRateServiceTest
    public ExchangeRateWrapper() {
    }

    /**
     * @description Converts the wrapper data to a list of Exchange_Rate__c records
     * @return List<Exchange_Rate__c> The list of exchange rate records
     */
    public static List<Exchange_Rate__c> toExchangeRates(ExchangeRateWrapper rateData) {
        // TODO: Implement the method to convert the wrapper data to Exchange_Rate__c records
        // 1. Create a list to hold the Exchange_Rate__c records
        // 2. Iterate through the rates map
        // 3. For each rate, create an Exchange_Rate__c record
        // 4. Return the list of records
        List<Exchange_Rate__c> rates = new List<Exchange_Rate__c>(); 
        for (String currencyCode : rateData.conversion_rates.keySet()) {
            Long unixTime = Long.valueOf(rateData.time_last_update_unix);
            Decimal decimalRate = (Decimal)rateData.conversion_rates.get(currencyCode);
            Exchange_Rate__c rateRecord = new Exchange_Rate__c(
                Base_Currency__c    = rateData.base_code,
                External_Id__c      = buildExternalId(rateData.base_code, currencyCode),
                Last_Updated__c     = convertUnixToDateTime(unixTime), //1743552002
                Rate__c             = decimalRate, //1074.5400
                Target_Currency__c  = currencyCode
            ); 
            rates.add(rateRecord);
        }
        return rates; 
    }
    
    /**
     * @description Static method to parse the JSON response into the wrapper class
     * @param jsonResponse The JSON response from the API
     * @return ExchangeRateWrapper The parsed wrapper instance
     */
    public static ExchangeRateWrapper parse(String jsonResponse) {
        // TODO: Implement the method to parse the JSON response
        // Use JSON.deserialize or **JSON.deserializeStrict** ?? to parse the response
        ExchangeRateWrapper rateWrapper = (ExchangeRateWrapper) JSON.deserialize(jsonResponse, ExchangeRateWrapper.class);
        return rateWrapper;
    }
    
    /**
     * @description Static method to convert a long unix time to a DateTime for the Salesforce record
     * @param unixTime unix string from callout response, converted into a Long data type
     * @return DateTime DateTime value to use for the Salesforce field value
     */
    private static DateTime convertUnixToDateTime(Long unixTime) {
        Long unixTimeMilliseconds = unixTime * 1000; 
        return DateTime.newInstance(unixTimeMilliseconds); 
    }

    /**
     * @description simple method for logic that creates external id
     * if it needs to be updated in the future, or accessed in different places, this is the one place that could be updated
     * @param base_code base currency code like USD
     * @param targetCode target currency code for exchange rate for base currency
     * @return String concatenated value that serves as external id
     */
    private static String buildExternalId(String base_code, String targetCode) {
        return base_code + '_' + targetCode;
    }
}