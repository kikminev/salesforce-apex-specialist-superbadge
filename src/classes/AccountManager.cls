/**
 * Created by kik on 14.04.23.
 *
 * Apex hands-on challenge - https://trailhead.salesforce.com/content/learn/modules/apex_integration_services/apex_integration_webservices
 */

@RestResource(UrlMapping='/Accounts/*')
global with sharing class AccountManager {

    @HttpGet
    global static Account getAccount() {
        RestRequest request = RestContext.request;

        String url = request.requestURI;

        Pattern idPattern = Pattern.compile('.+(001[a-zA-Z\\d]+)/');
        Matcher matcher = idPattern.matcher(url);

        System.debug('Find? ' + matcher.find());
        System.debug('PM Group 1: ' + matcher.group(1));

        String accountId = matcher.group(1);

        Account account = [SELECT Id, Name, (SELECT Id, Name FROM Contacts) FROM Account WHERE Id = :accountId];

        return account;
    }
}