/**
 * Created by kik on 21.03.23.
 */

/*
    *** trailhead challenge class ***
    https://trailhead.salesforce.com/content/learn/modules/apex_testing/apex_testing_intro
    https://raw.githubusercontent.com/developerforce/trailhead-code-samples/master/VerifyDate.cls
 */

@IsTest
private class TestVerifyDate {
    @IsTest
    private static void testCheckDatesWithin30Days(){
        Date randomDate1 = Date.parse('12/03/2020');
        Date randomDate2 = Date.parse('25/03/2020');
        Date endOfMonthDay = Date.parse('31/03/2020');


        System.assertEquals(true, randomDate1 < randomDate2);
        System.assertEquals(randomDate2, VerifyDate.CheckDates(randomDate1, randomDate2));


        // test DateWithin30Days 'date2 < date1' case
        System.assertEquals(endOfMonthDay, VerifyDate.CheckDates(randomDate2, randomDate1));
    }

    @IsTest
    private static void testCheckDatesNotWithin30Days(){
        Date randomDate1 = Date.parse('05/03/2021');
        Date randomDate2 = Date.parse('25/03/2023');
        Date realEndOfMonthDay = Date.parse('31/03/2021');


        System.assertEquals(true, randomDate1 < randomDate2);
        System.assertEquals(realEndOfMonthDay, VerifyDate.CheckDates(randomDate1, randomDate2));
    }
}
