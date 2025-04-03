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
     * Uses the callable interface from the scheduled job to remove the hard dependancy on the service class
     * that way when a job is scheduled, you can still modify the service class/dependent classes without having to cancel scheduled jobs
     * @param context The SchedulableContext
     */
    global void execute(SchedulableContext sc) {
        // 1. Call ExchangeRateService.updateExchangeRates()
        // 2. Add error handling
        // 3. Consider adding logging if available

        //ExchangeRateService.updateExchangeRates();

        try {
            if(config == null) {
                config = [SELECT Id, API_Key__c, Base_Currency__c, Apex_Class_Name__c, Apex_Method__c FROM Exchange_Rate_API_Config__mdt LIMIT 1];
            }
            Map<String, Object> params = new Map<String, Object>{
                'config' => config
            };
            classInstance = (Callable) Type.forName(config.Apex_Class_Name__c).newInstance();
            classInstance.call(config.Apex_Method__c, params);
        } catch (Exception e) {
            Logger.error('Error with Exchange Rate job: ' + e.getMessage()).addTag('ExchangeRate');
            Logger.saveLog();
        }

    }
}