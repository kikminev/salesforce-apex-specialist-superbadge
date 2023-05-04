@IsTest
private class WarehouseCalloutServiceTest {

    @IsTest
    private static void testSyncDataFromWareHouse() {
        WarehouseCalloutServiceMock mock = new WarehouseCalloutServiceMock();
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();


        WarehouseCalloutService warehouseCalloutService = new WarehouseCalloutService();
        System.enqueueJob(warehouseCalloutService);
        Test.stopTest();

        List<Product2> equipment = [SELECT Id, Name, Cost__c FROM Product2];
        System.assertEquals(1, equipment.size());
        System.assertEquals(true, equipment[0].Name.contains('Generator 1000 kW'));
        System.assertEquals(5000, equipment[0].Cost__c);
    }
}
