/**
 * @description Wrapper class to deserialize the JSON response from the Exchange Rate API
 * Students will implement the properties and methods to process the data
 */
public class ExchangeRateWrapper {
   
    // TODO: Implement properties to match the JSON structure of the API response
    // Sample response:
    // {
    //   "baseCode": "USD",
    //   "lastUpdateUnix": 1740690001,
    //   "conversionRates": {
    //     "EUR": 0.9488,
    //     "GBP": 0.8393,
    //     "JPY": 136.57,
    //     ...
    //   }
    // }

    public String baseCode;
    public String lastUpdateUnix;
    //public DateTime time_last_update_utc;
    public Map<String, Decimal> conversionRates;

    // Add property for external ID
    // This is an ID you will generate to uniquely identify the exchange rate record
    // This does not come from the API response
    //public String externalId; // baseCurrency + '_' + targetCurrency
    //public ExchangeRateWrapper(String baseCurrencyCode, String lastUpdateUnix, String lastUpdateUTC, Map<String, Decimal> conversionRates, String targetCurrencyCode) {
    //public ExchangeRateWrapper(String baseCurrencyCode, String lastUpdateUTC, Map<String, Decimal> conversionRates, String targetCurrencyCode) {
    /*public ExchangeRateWrapper(String baseCurrencyCode, String lastUpdateUTC, Map<String, Decimal> conversionRates) {
        this.baseCode = baseCurrencyCode;
        //this.lastUpdateUnix = lastUpdateUnix;
        this.time_last_update_utc = DateTime.valueOfGMT(lastUpdateUTC);
        this.conversionRates = conversionRates;
        //this.externalId = baseCurrencyCode + '_' + targetCurrencyCode;
    }*/

    public ExchangeRateWrapper(String baseCurrencyCode, String lastUpdateUnix, Map<String, Decimal> conversionRates) {
        this.baseCode = baseCurrencyCode;
        this.lastUpdateUnix = lastUpdateUnix;
        this.conversionRates = conversionRates;
    }

    // used in ExchangeRateService for toExchangeRates() method
    public ExchangeRateWrapper(ExchangeRateWrapper wrp) {
        this.baseCode = wrp.baseCode;
        this.lastUpdateUnix = wrp.lastUpdateUnix;
        this.conversionRates = wrp.conversionRates;
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
        for (String currencyCode : rateData.conversionRates.keySet()) {
            Long unixTime = Long.valueOf(rateData.lastUpdateUnix);
            //TODO make sure map contains key
            Decimal decimalRate = (Decimal)rateData.conversionRates.get(currencyCode);
            Exchange_Rate__c rateRecord = new Exchange_Rate__c(
                Base_Currency__c    = rateData.baseCode,
                External_Id__c      = rateData.baseCode + '_' + currencyCode,
                Last_Updated__c     = convertUnixToDateTime(unixTime), //1743552002
                //Last_Updated__c     = rateData.time_last_update_utc,
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
    
    private static DateTime convertUnixToDateTime(Long unixTime) {
        Long unixTimeMilliseconds = unixTime * 1000; 
        DateTime dt = DateTime.newInstance(unixTimeMilliseconds); 
        return dt; 
    }
}