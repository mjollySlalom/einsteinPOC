/*
    Matt Jolly | Slalom Consulting | 6/16/17
    Description - Controller for the product recommendation page
*/
public class SimilarProductController{
    //TODO: This should be moved to a custom setting / custom metadata record
    public static final String ACCESS_KEY = 'w3YaKkeAHJJbynCfskHw4wOkiaOhzhHrz4rjj1-mBIL0Bg7ccZdJdDBTvCwDtA1p';
   
    //Singleton data member 
        //Queries for the list of products and populates the dropdown on the page
    public List<SelectWrapper> productSelectOptions {
            get {
                if(productSelectOptions == null) {
                    List<SelectWrapper> temp = new List<SelectWrapper>();
                    List<Product2> prodList = [SELECT Id, Name FROM Product2 LIMIT 100];
                    for(Product2 p :prodList) {
                        temp.add(new SelectWrapper(p.Name, p.Id));
                    }
                    productSelectOptions = temp;
                }
                return productSelectOptions;
            }
            set;
    }
    
    //Remote action for recommending similar products.
        //Makes an API call to the recommendation engine, and returns a list of 
        //product recommendations
    @RemoteAction
    public static List<PredictionWrapper> predictEvent(String known, Integer cnt) {
        //Make the API call to the recommendation engine
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('http://pio-engine-mj.herokuapp.com/queries.json');
        req.setHeader('Content-Type','application/json');
        req.setBody('{ "items": ["' + known + '"], "num": ' + cnt + ' }');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        //Create the list of results and return to front-end        
        return PredictionHandler.handlePredictions(res.getBody());
    }
    
    //Wrapper class for the customized select options
    private class selectWrapper{
        public String name{get;set;}
        public String prodId{get;set;}
        public SelectWrapper(String n, String pId) {
            name = n;
            prodId = pId;
        }
    }
}