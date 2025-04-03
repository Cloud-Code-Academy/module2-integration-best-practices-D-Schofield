/**
 * @description Scheduler class to run the exchange rate update on a schedule
 * Scheduling should be done in Salesforce Setup Apex Classes -> Schedule Apex
 */
global class ExchangeRateScheduler implements Schedulable {
    
    /**
     * @description Executes the scheduled job to update exchange rates
     * @param context The SchedulableContext
     */
    global void execute(SchedulableContext sc) {
        // 1. Call ExchangeRateService.updateExchangeRates()
        try {
            ExchangeRateService.updateExchangeRates();
        } catch (Exception e) {
            System.debug('Error with Exchange Rate job: ' + e.getMessage());
        }
        // 2. Add error handling
        // 3. Consider adding logging if available
    }
}