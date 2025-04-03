/**
 * @description Test class for the ExchangeRateScheduler
 * This will be provided to students to test their scheduler implementation
 */
@isTest
private class ExchangeRateSchedulerTest {
    
    /**
     * @description Tests the execute method of the scheduler
     */
    @isTest
    static void testExecute() {
        // Set up the Custom Metadata config
        // Can set values for everything except an actual API Key
        Exchange_Rate_API_Config__mdt mockConfig = new Exchange_Rate_API_Config__mdt(
            Apex_Class_Name__c = 'ExchangeRateService',
            Apex_Method__c = 'updateExchangeRates',
            API_Key__c = 'mockApiKey',
            Base_Currency__c = 'USD'
        );
        // Set up the mock
        Test.setMock(HttpCalloutMock.class, new ExchangeRateMock());
        
        // Call the execute method directly
        Test.startTest();
        // Create an instance of the scheduler
        ExchangeRateScheduler scheduler = new ExchangeRateScheduler();
        scheduler.config = mockConfig;
        scheduler.execute(null); // Passing null as the context is sufficient for testing
        Test.stopTest();
        
        /* original test performs callout and verifies 9 records were created
         * But with API Key stored as Custom Metadata, cannot perform actual callout in the test without hardcoding they key somewhere
         * So with Custom Metadata, and Callable, I modified this test to assert the ExchangeRateService class is called
         * The tests for ExchangeRateService will have to handle the assertions for Exchange_Rate__c records
         */

        /*
        // Verify that exchange rates were created
        List<Exchange_Rate__c> rates = [
            SELECT Id, Base_Currency__c, Target_Currency__c, Rate__c
            FROM Exchange_Rate__c
        ];
        System.assertEquals(9, rates.size(), 'Should have 9 exchange rate records');
        */
        Assert.isNotNull(scheduler.classInstance, 'Expected an instance of the Apex Class but did not observe the same.');
        Assert.isInstanceOfType(scheduler.classInstance, ExchangeRateService.class, 'Expected the Callable to be an instance of ExchangeRateService class but it was not.');
    }
    
    /**
     * @description Tests error handling in the execute method
     */
    @isTest
    static void testExecute_Error() {
        // Set up the mock for an error response
        Test.setMock(HttpCalloutMock.class, new ExchangeRateMock(true));
        
        // Create an instance of the scheduler
        ExchangeRateScheduler scheduler = new ExchangeRateScheduler();
        
        // Call the execute method and ensure it handles errors gracefully
        Test.startTest();
        try {
            scheduler.execute(null);
            // The execute method should catch exceptions, so we should not assert failure here
        } catch (Exception e) {
            System.assert(false, 'The execute method should handle exceptions: ' + e.getMessage());
        }
        Test.stopTest();
        
        // Verify that no exchange rates were created (due to the error)
        List<Exchange_Rate__c> rates = [
            SELECT Id FROM Exchange_Rate__c
        ];
        System.assertEquals(0, rates.size(), 'Should have no exchange rate records due to error');
    }
}