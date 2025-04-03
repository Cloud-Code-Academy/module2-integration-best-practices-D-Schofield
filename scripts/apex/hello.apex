List<Exchange_Rate__c> rateRecords = new ExchangeRateService().updateExchangeRates();
System.debug('# rateRecords: ' + rateRecords.size() );
