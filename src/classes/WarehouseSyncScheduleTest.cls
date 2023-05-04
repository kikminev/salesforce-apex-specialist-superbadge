@IsTest
public with sharing class WarehouseSyncScheduleTest {
    public static String CRON_EXP = '0 0 22 * * ? *';

    @IsTest
    private static void testWarehouseSyncSchedule() {
        WarehouseCalloutServiceMock mock = new WarehouseCalloutServiceMock();
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        String jobId = System.schedule('WarehouseSyncScheduleJobTest', CRON_EXP, new WarehouseSyncSchedule());
        Test.stopTest();

        System.assertNotEquals(null, jobId);
    }
}