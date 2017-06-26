/*
    Matt Jolly | Slalom Consulting | 6/23/17
    Description - Apex controller for board attachment recommendations lightning component
*/
public class RecommendAttachController {

    //For an opportunity, return a list of recommended sockets for the currently selected
        //board 
    @AuraEnabled
    public static String getRecommendedAttachments(Id oppId) {
        //Retrieve all products for the given opportunity       
        List<OpportunityLineItem> oliList = [
                SELECT 
                    Id,
                    Product2.Name,
                    Product2.Id,
                    Opportunity.Category__c,
                    Product2.Class__c
                FROM OpportunityLineItem 
                WHERE OpportunityId = :oppId
        ];
        
        Set<Id> existingOppProducts = new Set<Id>();
        OpportunityLineItem oli = null;
        for(OpportunityLineItem o :oliList) {
            //Store the board associated with this opportunity
            if(o.Product2.Class__c == 'Board') {
                oli = o;
            //Store the existing sockets on this opportunity
            } else {
                existingOppProducts.add(o.Product2.Id);
            }
        }
        
        //If no board exists on this opportunity, do not make a recommendation       
        if(oli == null) {
           return '';
        }
        
        //Make the API call to the recommendation engine
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('http://complementary-engine.herokuapp.com/queries.json');
        req.setHeader('Content-Type','application/json');
        req.setBody('{ "items": ["' + oli.Opportunity.Category__c + '-' + oli.Product2.Id + '"], "num": ' + 20 + ' }');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        //Parse the prediction engine response and wrap predictions
        List<PredictionWrapper> predictionList = PredictionHandler.handleComplementaryPredictions(res.getBody());
        
        //Remove any sockets from the list of recommendations, if they already exist on this opportunity
        List<PredictionWrapper> cleanedPredictionList = new List<PredictionWrapper>();
        for(PredictionWrapper pw: predictionList) {
            if(!existingOppProducts.contains(pw.item.Id)) {
                cleanedPredictionList.add(pw);
            }
        }
        
        //Make 5 recommendations at most
        List<PredictionWrapper> cleanedPredictionSubList = new List<PredictionWrapper>();
        for(Integer i=0; i<5 && i<cleanedPredictionList.size(); i++) {
            
            cleanedPredictionSubList.add(cleanedPredictionList[i]);
        }
        
        //Add the board to the list of sockets so that the board name is passed to the lightning component
            //without making an additional call. The board must be the first item in the list
        List<PredictionWrapper> combinedList = new List<PredictionWrapper>{new PredictionWrapper(oli)};
        combinedList.addAll(cleanedPredictionSubList);
    
        return JSON.serialize(combinedList);
    }
}