public with sharing class WarehouseCalloutService {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

    public static void syncDataFromWareHouse() {
        Http httpClient = new Http();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(WAREHOUSE_URL);
        req.setMethod('GET');

        HttpResponse res = httpClient.send(req);

        JSONParser parser = JSON.createParser(res.getBody());
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        parser.readValueAs(EquipmentItem.class);
                    }
                }
            }
        }
    }

    public class EquipmentItem {
        public String sku;
        public String cost;
        public String lifespan;
        public String maintenanceperiod;
        public String name;
        public String quantity;
        public String replacement;
    }
}

