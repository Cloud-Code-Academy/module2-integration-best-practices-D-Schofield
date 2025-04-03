/**
 * @description Scheduler class to run the exchange rate update on a schedule
 * Scheduling should be done in Salesforce Setup Apex Classes -> Schedule Apex
 */
global class ExchangeRateScheduler implements Schedulable {
    
    @TestVisible
    private Exchange_Rate_API_Config__mdt config; 

    @TestVisible
    private Callable classInstance;

    /**
     * @description Executes the scheduled job to update exchange rates
     * @param context The SchedulableContext
     */
    global void execute(SchedulableContext sc) {
        // 1. Call ExchangeRateService.updateExchangeRates()
        // 2. Add error handling
        // 3. Consider adding logging if available
        try {
            if(config == null) {
                config = [SELECT Id, API_Key__c, Base_Currency__c, Apex_Class_Name__c FROM Exchange_Rate_API_Config__mdt LIMIT 1];
            }
            Map<String, Object> params = new Map<String, Object>{
                'config' => config
            };
            classInstance = (Callable) Type.forName(config.Apex_Class_Name__c).newInstance();
            Object obj = classInstance.call(config.Apex_Method__c, params);
            //ExchangeRateService.updateExchangeRates();
        } catch (Exception e) {
            System.debug('Error with Exchange Rate job: ' + e.getMessage());
        }
        
    }
}