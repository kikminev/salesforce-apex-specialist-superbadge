@IsTest
public with sharing class MaintenanceRequestHelperTest {

    private static Integer SHORTEST_MAINTENANCE_CYCLE = 10;

    @TestSetup
    private static void setup() {

        List<Vehicle__c> vehiclesToInsert = new List<Vehicle__c>();
        for (Integer i = 0; i < 300; i++) {
            Vehicle__c vehicle = new Vehicle__c();
            vehicle.Name = 'Vehicle ' + i;

            vehiclesToInsert.add(vehicle);
        }

        insert vehiclesToInsert;

        // this standard product object is renamed to equipment by the tech requirements
        Product2 equipment = new Product2();
        equipment.Name = 'Spark plugs';
        equipment.Description = 'Spark plugs';
        equipment.Cost__c = 100;
        equipment.Current_Inventory__c = 301;
        equipment.Lifespan_Months__c = 12;
        equipment.Maintenance_Cycle__c = SHORTEST_MAINTENANCE_CYCLE;
        equipment.ProductCode = 'sparkPlugs';
        equipment.Replacement_Part__c = true;
        equipment.Warehouse_SKU__c = '18593425';

        insert equipment;

        Product2 equipmentOilFilter = new Product2();
        equipmentOilFilter.Name = 'Oil filters';
        equipmentOilFilter.Description = 'Oil filters';
        equipmentOilFilter.Cost__c = 10;
        equipmentOilFilter.Current_Inventory__c = 604;
        equipmentOilFilter.Lifespan_Months__c = 24;
        equipmentOilFilter.Maintenance_Cycle__c = 15;
        equipmentOilFilter.ProductCode = 'oil_filters';
        equipmentOilFilter.Replacement_Part__c = true;
        equipmentOilFilter.Warehouse_SKU__c = '784676423';

        insert equipmentOilFilter;

        List<Case> routineMaintenanceToInsert = new List<Case>();

        for(Vehicle__c vehicle : vehiclesToInsert) {
            Case routineMaintenance = new Case();
            routineMaintenance.Type = MaintenanceRequestHelper.CASE_TYPE_ROUTINE_MAINTENANCE;
            routineMaintenance.Subject = 'Test Maintenance Request ';
            routineMaintenance.Vehicle__c = vehicle.Id;

            routineMaintenanceToInsert.add(routineMaintenance);
        }

        insert routineMaintenanceToInsert;

        List<Equipment_Maintenance_Item__c> equipmentMaintenanceItemsToInsert = new List<Equipment_Maintenance_Item__c>();
        for (Case routineMaintenance : routineMaintenanceToInsert) {
            Equipment_Maintenance_Item__c equipmentMaintenanceItem = new Equipment_Maintenance_Item__c();
            equipmentMaintenanceItem.Equipment__c = equipment.Id;
            equipmentMaintenanceItem.Maintenance_Request__c = routineMaintenance.Id;

            equipmentMaintenanceItemsToInsert.add(equipmentMaintenanceItem);

            Equipment_Maintenance_Item__c equipmentMaintenanceItem1 = new Equipment_Maintenance_Item__c();
            equipmentMaintenanceItem1.Equipment__c = equipmentOilFilter.Id;
            equipmentMaintenanceItem1.Maintenance_Request__c = routineMaintenance.Id;

            equipmentMaintenanceItemsToInsert.add(equipmentMaintenanceItem1);
        }

        insert equipmentMaintenanceItemsToInsert;
    }

    @IsTest
    public static void testNotCreatingNewCheckupsAsConditionsDontMatch() {

        Case routineMaintenance = [SELECT Id, Status FROM Case WHERE Type = :MaintenanceRequestHelper.CASE_TYPE_ROUTINE_MAINTENANCE LIMIT 1];
        routineMaintenance.Subject = 'Test Maintenance Request Change';

        update routineMaintenance;

        List<Case> allCases = [SELECT Id FROM Case];
        System.assertEquals(300, allCases.size(), 'No new cases should be created as it doesn\'t match the conditions');

        routineMaintenance.Status = 'New';
        update routineMaintenance;

        allCases = [SELECT Id FROM Case];
        System.assertEquals(300, allCases.size(), 'No new cases should be created as it doesn\'t match the conditions');
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
        System.assertEquals(301, allCases.size(), 'No new cases should be created as this is not a repair request');
    }

    @IsTest
    public static void testCreatingFutureCheckupsForRoutineMaintenanceWhenItCloses() {
        Vehicle__c vehicle1 = [SELECT Id FROM Vehicle__c WHERE Name =  'Vehicle 0'];

        List<Case> openRoutineMaintenance = [SELECT Id, Status, Vehicle__c, Date_Due__c FROM Case WHERE Type = :MaintenanceRequestHelper.CASE_TYPE_ROUTINE_MAINTENANCE];
        for (Case routineMaintenance : openRoutineMaintenance) {
            routineMaintenance.Status = MaintenanceRequestHelper.CASE_STATUS_CLOSED;
        }

        update openRoutineMaintenance;

        List<Case> closedRoutineMaintenance = [SELECT Id, Status, Vehicle__c, Date_Due__c FROM Case WHERE Type = :MaintenanceRequestHelper.CASE_TYPE_ROUTINE_MAINTENANCE AND Status = :MaintenanceRequestHelper.CASE_STATUS_CLOSED];

        System.assertEquals(300, closedRoutineMaintenance.size());

        List<Case> automaticallyCreatedFutureRoutineCheckup = [SELECT Id, Status, Vehicle__c, Date_Due__c, Type FROM Case WHERE Subject = 'Automatically Scheduled Routine Maintenance'];

        System.assertEquals(300, automaticallyCreatedFutureRoutineCheckup.size(), '300 new routine checkup should be created - scheduled in the future');

        for (Case routineCheckup : automaticallyCreatedFutureRoutineCheckup) {
            System.assertEquals(MaintenanceRequestHelper.CASE_TYPE_ROUTINE_MAINTENANCE, routineCheckup.Type);
            System.assertEquals(System.today().addDays(SHORTEST_MAINTENANCE_CYCLE), routineCheckup.Date_Due__c);
        }
    }

    @IsTest
    public static void testCreatingFutureCheckupsForRepairWhenItCloses() {
        Vehicle__c vehicle2 = [SELECT Id FROM Vehicle__c WHERE Name =  'Vehicle 2'];
        List<Case> repairs = [SELECT Id, Status, Vehicle__c FROM Case WHERE Type = :MaintenanceRequestHelper.CASE_TYPE_ROUTINE_MAINTENANCE];
        repairs[0].Description = 'some test description';
        repairs[1].Status = MaintenanceRequestHelper.CASE_STATUS_CLOSED;

        update repairs;

        List<Case> automaticallyCreatedFutureRoutineCheckup = [SELECT Id, Status, Vehicle__c, Type FROM Case WHERE Subject = 'Automatically Scheduled Routine Maintenance'];

        System.assertEquals(1, automaticallyCreatedFutureRoutineCheckup.size(), '1 routine checkup should be created - scheduled in the future');
    }
}
