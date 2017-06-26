/*
    Matt Jolly | Slalom Consulting | 6/16/17
    Description - Helper class for parsing the responses from the recommendation
        engine API
*/
public class PredictionHandler {

    //Accepts a raw response string from the recommendation engine and returns
        // a list of prediction wrapper objects
    public static List<PredictionWrapper> handlePredictions(String rawResponse) {
        List<PredictionWrapper> pws = new List<PredictionWrapper>();
        //Parse the string and generate list of predictions        
        Map<String,Object> itemScores = (Map<String,Object>)JSON.deserializeuntyped(rawResponse);
        for(String prodId :itemScores.keyset()) {
            List<Object> prodMap = (List<Object>)itemScores.get(prodId);
            for(Object p :prodMap) {
                Map<String,Object> innerMap = (Map<String,Object>) p;
                String itId;
                for(String s: innerMap.keyset()) {
                    if(s == 'item') {
                        itId = (String)innerMap.get(s);
                    } else if(s == 'score') {
                        pws.add(new PredictionWrapper(itId, (Decimal)innerMap.get(s)));     
                    }
               }
            }
        }
        
        //Map each prediction wrapper to the id of the product it refers to
        Map<Id, PredictionWrapper> productIdToPwMap = new Map<Id, PredictionWrapper>();
        for(PredictionWrapper p :pws) {
            productIdToPwMap.put(p.itemId, p);
        }
        
        //Retrieve details about recommended products
        List<Product2> predictedProducts = [
                SELECT
                    Id,
                    Name, 
                    Family,
                    Description, 
                    ProductCode,
                    Product_Image__c
                FROM Product2
                WHERE Id IN :productIdToPwMap.keyset()
        ];
        
        //Add product details to the predicrtion wrapper, and sort by similarity score
        List<PredictionWrapper> sortedPws = new List<PredictionWrapper>();
        for(Product2 p :predictedProducts) {
            productIdToPwMap.get(p.Id).item = p;
            sortedPws.add(productIdToPwMap.get(p.Id));
        }
        sortedPws.sort();
        return sortedPws;
    }
    
    /**
    *   Accept the raw JSON string from the prediction engine. Parse the string
    *   and create wrapped objects.
    */
    public static List<PredictionWrapper> handleComplementaryPredictions(String rawResponse) {
        List<PredictionWrapper> pws = new List<PredictionWrapper>();
        
        //Parse the string and generate list of predictions        
        Map<String,Object> itemScores = (Map<String,Object>)JSON.deserializeuntyped(rawResponse);
        List<object> scoreList = (List<object>)itemScores.get('rules');
        List<PredictionWrapper> pwList = new List<PredictionWrapper>();
        for(object obj :scoreList) {
            Map<String,object> objMap = (Map<String,Object>)obj;
            List<Object> itemList = (List<Object>)objMap.get('itemScores');
            for(Object mso : itemList) {
                Map<String, Object> predictionRow = (Map<String, Object>)mso;
                pwList.add(new PredictionWrapper(((String)predictionRow.get('item')).split('-')[1], (Decimal)predictionRow.get('confidence')));
            }
        }
       
        return retrievePredictionProducts(pwList);
    }
    
    /**
    * For a list of prediction wrappers with product ids, retrieve each
    *   Product object with necessary fields and add it to the wrapper.
    */
    public static List<PredictionWrapper> retrievePredictionProducts(List<PredictionWrapper> pwList) {
         //Map each prediction wrapper to the id of the product it refers to
        Map<Id, PredictionWrapper> productIdToPwMap = new Map<Id, PredictionWrapper>();
        for(PredictionWrapper p :pwList) {
            productIdToPwMap.put(p.itemId, p);
        }
        
        //Retrieve details about recommended products
        List<Product2> predictedProducts = [
                SELECT
                    Id,
                    Name, 
                    Family,
                    Description, 
                    ProductCode,
                    Product_Image__c
                FROM Product2
                WHERE Id IN :productIdToPwMap.keyset()
        ];
        
        //Add product details to the predicrtion wrapper, and sort by similarity score
        List<PredictionWrapper> sortedPws = new List<PredictionWrapper>();
        for(Product2 p :predictedProducts) {
            productIdToPwMap.get(p.Id).item = p;
            sortedPws.add(productIdToPwMap.get(p.Id));
        }
        sortedPws.sort();
        return sortedPws;
    }
    
}