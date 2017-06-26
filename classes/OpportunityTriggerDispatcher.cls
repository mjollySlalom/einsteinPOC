/*
    Matt Jolly | Slalom Consulting | 6/23/17
    Description - Trigger dispatcher for opportunity objects
*/
public class OpportunityTriggerDispatcher {
    //Access key for prediction engine api
    public static final String ACCESS_KEY = 'UIQEVszCC9H0CGnoMtp6s6oukSqySWpdROq2il7OqwtUII7ct61NIaYTyRmquDsK';

    public static final String closedOpportunityStatus = 'Closed Won';
    
    public static void handleAfterUpdate(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        updateMlDb(oldMap, newMap);
    }
    
    /*
    *   Updates the machine learning database, each time an opportunity stage is 
    *       set to Closed won
    */
    public static void updateMlDb(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        //Bulk state change check
        Map<Id, Opportunity> newClosedOpportunities = new Map<Id, Opportunity>();
        for(Id oldOpId :oldMap.keyset()) {
            if(oldMap.get(oldOpId).StageName != closedOpportunityStatus 
                    && newMap.get(oldOpId).StageName == closedOpportunityStatus) {
                newClosedOpportunities.put(oldOpId, newMap.get(oldOpId));
            }
        }
        
        //If any opportunities set to closed won stage, make the callout to the
            //event server api (api calls in trigger must be future)
        if(!newClosedOpportunities.isEmpty()) {
            makeMlDbCallout(newClosedOpportunities.keyset());
        }
    }
    
    /*
    * Add each product in a closed won opportunity to the complementary product
    *   prediction io event server database.
    */
    @future(callout=true)
    public static void makeMlDbCallout (Set<Id> oppIdSet) {
        //Retrieve each line item from the closed opportunity
        List<OpportunityLineItem> oliList = [
                SELECT  
                    Id, 
                    OpportunityId, 
                    Product2Id, 
                    Opportunity.Category__c
                FROM OpportunityLineItem 
                WHERE OpportunityId IN :oppIdSet
        ];
        
        //Record the current time in the correct format for the event server database
            //Must use the same time for each product purchased in an opportunity to ensure
            // that they are recognized as being in the same "shopping basket"
        DateTime closedTime = DateTime.now();
        String closedTimeStr = String.valueOf(closedTime.year()) + '-' + addLeadingZeros(String.valueOf(closedTime.month())) + '-' + addLeadingZeros(String.valueOf(closedTime.day())) + 'T' + addLeadingZeros(String.valueOf(closedTime.hour())) + ':' + addLeadingZeros(String.valueOf(closedTime.minute())) + ':' + addLeadingZeros(String.valueOf(closedTime.second())) + '.' + adjustMs(String.valueOf(closedTime.millisecond())) + '-08:00';
        
        //No bulk api call for adding items, so call one at a time
            //TODO: Only 100 api calls are permitted during a single execution context
            //  if more than 100 opportunities are closed in a single transaction, this 
            // method will fail. Need to create batch process for this use-case.
        for(OpportunityLineItem oli :oliList) {
            //Send the api call
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint('http://complementary-event-server.herokuapp.com/events.json?accessKey=' + ACCESS_KEY);
            req.setHeader('Content-Type','application/json');
            req.setBody('{'
              + '"event" : "buy",'
              + '"entityType" : "user",'
              + '"entityId" : "' + oli.OpportunityId + '",'
              + '"targetEntityType" : "item",'
              + '"targetEntityId" : "' + oli.Opportunity.Category__c + '-' + oli.Product2Id + '",'
              + '"eventTime" : "' + closedTimeStr + '"'
            + '}');
        
            Http http = new Http();
            //Don't need to do anything with the response
            HTTPResponse res = http.send(req);
        }
    }
    
    //Helper method for formatting event date in event server db
    private static String addLeadingZeros (String str) {
        return str.length() == 2 ? str : '0' + str;
    }
    
    //Helper method for formatting event date in event server db
    private static String adjustMs (String str) {
        String retStr;
        if(str.length() == 3) {
            retStr = str;
        } else if(str.length() > 3) {
            retStr = str.substring(0,3);
        } else if (str.length() == 0) {
            retStr = '000';
        } else if (str.length() == 1) {
            retStr = '00' + str;   
        } else if (str.length() == 2) {
            retStr = '0' + str;
        }
        return retStr;
    }

}