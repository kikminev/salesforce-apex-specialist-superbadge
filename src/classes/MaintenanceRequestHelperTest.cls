@IsTest
public with sharing class MaintenanceRequestHelperTest {

    @TestSetup
    private static void setup() {
        Vehicle__c vehicle1 = new Vehicle__c();
        vehicle1.Name = 'HowWeRoll Recreational Vehicle 1';
        insert vehicle1;

        Vehicle__c vehicle2 = new Vehicle__c();
        vehicle2.Name = 'HowWeRoll Recreational Vehicle 2';
        insert vehicle2;

        Case routineMaitenance = new Case();
        routineMaitenance.Type = MaintenanceRequestHelper.CASE_TYPE_ROUTINE_MAINTENANCE;
        routineMaitenance.Subject = 'Test Maintenance Request';
        routineMaitenance.Vehicle__c = vehicle1.Id;

        insert routineMaitenance;

        // this standard product object is renamed to equipment by the tech requirements
        Product2 equipment = new Product2();
        equipment.Description = 'Spark plugs';
        equipment.Cost__c = 100;
        equipment.Current_Inventory__c = 301;
        equipment.Lifespan_Months__c = 12;
        equipment.Maintenance_Cycle__c = 1;
        equipment.ProductCode = 'sparkPlugs';
        equipment.Replacement_Part__c = true;
        equipment.Warehouse_SKU__c = '18593425';

        Equipment_Maintenance_Item__c equipmentMaintenanceItem = new Equipment_Maintenance_Item__c();
        equipmentMaintenanceItem.Equipment__c = equipment.Id;


        Case repair = new Case();
        repair.Type = MaintenanceRequestHelper.CASE_TYPE_REPAIR;
        repair.Subject = 'Test Repair';
        repair.Vehicle__c = vehicle2.Id;

        insert repair;
    }

    @IsTest
    public static void testNotCreatingNewCheckupsAsConditionsDontMatch() {

        Case routineMaintenance = [SELECT Id, Status FROM Case WHERE Type = :MaintenanceRequestHelper.CASE_TYPE_ROUTINE_MAINTENANCE];
        routineMaintenance.Subject = 'Test Maintenance Request Change';

        update routineMaintenance;

        List<Case> allCases = [SELECT Id FROM Case];
        System.assertEquals(2, allCases.size(), 'No new cases should be created as it doesn\'t match the conditions');

        routineMaintenance.Status = 'New';
        update routineMaintenance;

        allCases = [SELECT Id FROM Case];
        System.assertEquals(2, allCases.size(), 'No new cases should be created as it doesn\'t match the conditions');
    }

    @IsTest
    public static void testNotCreatingNewCheckupsAsTypeDoesntMatch() {
        Case badCustomerExperienceCase = new Case();
        badCustomerExperienceCase.Type = 'Customer Experience';

        insert badCustomerExperienceCase;

        Case badCustomerExperienceCaseToUpdate = [SELECT Id, Status FROM Case WHERE Type = 'Customer Experience'];
        badCustomerExperienceCaseToUpdate.Status = MaintenanceRequestHelper.CASE_STATUS_CLOSED;

        update badCustomerExperienceCaseToUpdate;

        List<Case> allCases = [SELECT Id FROM Case];
        System.assertEquals(3, allCases.size(), 'No new cases should be created as this is not a repair request');
    }

    @IsTest
    public static void testCreatingFutureCheckupsForRoutineMaintenanceWhenItCloses() {
        Vehicle__c vehicle1 = [SELECT Id FROM Vehicle__c WHERE Name =  'HowWeRoll Recreational Vehicle 1'];
        Case routineMaintenance = [SELECT Id, Status, Vehicle__c FROM Case WHERE Type = :MaintenanceRequestHelper.CASE_TYPE_ROUTINE_MAINTENANCE];
        routineMaintenance.Status = MaintenanceRequestHelper.CASE_STATUS_CLOSED;

        update routineMaintenance;

        List<Case> automaticallyCreatedFutureRoutineCheckup = [SELECT Id, Status, Vehicle__c, Type FROM Case WHERE Subject = 'Automatically Scheduled Routine Maintenance'];

        System.assertEquals(1, automaticallyCreatedFutureRoutineCheckup.size(), '1 new routine checkup should be created - scheduled in the future');

        Case routineCheckup = automaticallyCreatedFutureRoutineCheckup[0];

        System.assertEquals(MaintenanceRequestHelper.CASE_TYPE_ROUTINE_MAINTENANCE, routineCheckup.Type);
        System.assertEquals(routineMaintenance.Vehicle__c, routineCheckup.Vehicle__c);
        System.assertEquals(vehicle1.Id, routineCheckup.Vehicle__c);
    }

    @IsTest
    public static void testCreatingFutureCheckupsForRepairWhenItCloses() {
        Vehicle__c vehicle2 = [SELECT Id FROM Vehicle__c WHERE Name =  'HowWeRoll Recreational Vehicle 2'];
        Case repair = [SELECT Id, Status, Vehicle__c FROM Case WHERE Type = :MaintenanceRequestHelper.CASE_TYPE_REPAIR];
        repair.Status = MaintenanceRequestHelper.CASE_STATUS_CLOSED;

        update repair;

        List<Case> automaticallyCreatedFutureRoutineCheckup = [SELECT Id, Status, Vehicle__c, Type FROM Case WHERE Subject = 'Automatically Scheduled Routine Maintenance'];

        System.assertEquals(1, automaticallyCreatedFutureRoutineCheckup.size(), '1 new routine checkup should be created - scheduled in the future');

        Case routineCheckup = automaticallyCreatedFutureRoutineCheckup[0];

        System.assertEquals(MaintenanceRequestHelper.CASE_TYPE_ROUTINE_MAINTENANCE, routineCheckup.Type);
        System.assertEquals(repair.Vehicle__c, routineCheckup.Vehicle__c);
        System.assertEquals(vehicle2.Id, routineCheckup.Vehicle__c);
    }
}
