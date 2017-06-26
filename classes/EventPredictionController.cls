public class EventPredictionController{
    public static final Integer SAMPLE_SIZE = 500;
    public static final String ACCESS_KEY = 'w3YaKkeAHJJbynCfskHw4wOkiaOhzhHrz4rjj1-mBIL0Bg7ccZdJdDBTvCwDtA1p';
    
    public static final String ACCESS_KEY2 = 'xVZ3wcG7KEwvlI9pf7Bo4zR6WlZYA6IxPSXWlaUsebI1sC0D4vMNt0M4iPIICZnW';
    
    public String prediction {get; private set;}
    public List<PredictionWrapper> predictionList {get; private set;}
    
    public List<Product2> prodList {get;set;}
    public String known {get;set;}
    

    
    public List<SelectOption> productSelectOptions {
            get {
                if(productSelectOptions == null) {
                    List<SelectOption> temp = new List<SelectOption>();
                    List<Product2> prodList = [SELECT Id, Name FROM Product2 LIMIT 100];
                    for(Product2 p :prodList) {
                        temp.add(new SelectOption(p.Id, p.Name));
                    }
                    productSelectOptions = temp;
                }
                return productSelectOptions;
            }
            set;
    }
    
    
    
    
    public String entityId {get;set;}
    public String targetEntityId {get;set;}
    
    
    
    
    
    public void predictEvent() {
        System.debug('known: ' + known);
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('http://pio-engine-mj.herokuapp.com/queries.json');
        req.setHeader('Content-Type','application/json');
        req.setBody('{ "items": ["' + known + '"], "num": 4 }');
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        //System.debug(res.getBody());
        
        //prediction =  res.getBody();
        
        predictionList = PredictionHandler.handlePredictions(res.getBody());
        
    }
    
    public void uploadEvent() {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('http://event-server-mj.herokuapp.com/events.json?accessKey=' + ACCESS_KEY);
        req.setHeader('Content-Type','application/json');
        req.setBody('{'
            + '"event" : "view",'
            + '"entityType" : "user",'
            + '"entityId" : "' + entityId + '",'
            + '"targetEntityType" : "item",'
            + '"targetEntityId" : "' + targetEntityId + '",'
        +'}');
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        System.debug('res: ' + res.getBody());
       
    }
    
    public static void populateSampleEvents() {
        
        List<Contact> contactList = [SELECT Id FROM Contact LIMIT :100];
        List<Product2>productList = [SELECT Id FROM Product2 LIMIT :100];
        
        
        for(Integer i=0; i<100; i++) {
            Integer randomContact = Math.round(Math.random()*99);
            Integer randomProduct = Math.round(Math.random()*16);
            
            
            HttpRequest req = new HttpRequest();
            
            req.setMethod('POST');
            req.setEndpoint('http://event-server-mj.herokuapp.com/events.json?accessKey=' + ACCESS_KEY);
            req.setHeader('Content-Type','application/json');
            req.setBody('{'
                + '"event" : "view",'
                + '"entityType" : "user",'
                + '"entityId" : "' + contactList[randomContact].Id + '",'
                + '"targetEntityType" : "item",'
                + '"targetEntityId" : "' + productList[randomProduct].Id + '",'
            +'}');
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
            
        }
        
    }
    
    public static void populateContacts() {
        
        List<Contact> contactList = [SELECT Id FROM Contact LIMIT :SAMPLE_SIZE];
        
        
        
        for(Integer i=0; i<100; i++) {
           
            HttpRequest req = new HttpRequest();
            
            req.setMethod('POST');
            req.setEndpoint('http://event-server-mj.herokuapp.com/events.json?accessKey=' + ACCESS_KEY);
            req.setHeader('Content-Type','application/json');
            req.setBody('{'
                + '"event" : "$set",'
                + '"entityType" : "user",'
                + '"entityId" : "' + contactList[i].Id + '"'
               
            +'}');
        
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
        }
        
    }
    
    public static void populateProducts() {
        
        List<Product2> productList = [SELECT Id FROM Product2];
        
        
        
        for(Integer i=0; i<productList.size(); i++) {
           
            HttpRequest req = new HttpRequest();
            
            req.setMethod('POST');
            req.setEndpoint('http://event-server-mj.herokuapp.com/events.json?accessKey=' + ACCESS_KEY);
            req.setHeader('Content-Type','application/json');
            req.setBody('{'
                + '"event" : "$set",'
                + '"entityType" : "item",'
                + '"entityId" : "' + productList[i].Id + '",'
                + '"properties" : {"categories" : ["c1", "c2"]}'
               
            +'}');
        
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
        }
        
    }
    
    public static void complementAll() {
        
         
         
        for(Integer i=0; i<50; i++) {
               
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setEndpoint('http://complementary-engine.herokuapp.com/queries.json');
                req.setHeader('Content-Type','application/json');
                req.setBody('{ "items": ["r' + i + '"], "num": 4 }');
                
                Http http = new Http();
                HTTPResponse res = http.send(req);
                System.debug('res - ' + i + ': ' + res.getBody());
            }
      
        
    }
    
    public static void predictComplement() {
        
         
         
        
               
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setEndpoint('http://complementary-engine.herokuapp.com/queries.json');
                req.setHeader('Content-Type','application/json');
                req.setBody('{ "items": ["p1"], "num": 4 }');
                
                Http http = new Http();
                HTTPResponse res = http.send(req);
                System.debug(res.getBody());
            
      
        
    }
    
    
    public static void populateComplementary() {
        
            List<String> eventTimes = new List<String>();
            for(Integer i=10; i<60; i++) {
                eventTimes.add('2014-11-02T09:' + i + ':45.618-08:00');
            }
            
            for(Integer i=0; i<50; i++) {
                HttpRequest req = new HttpRequest();
            
                req.setMethod('POST');
                req.setEndpoint('http://complementary-event-server.herokuapp.com/events.json?accessKey=' + ACCESS_KEY2);
                req.setHeader('Content-Type','application/json');
                req.setBody('{'
                  + '"event" : "buy",'
                  + '"entityType" : "user",'
                  + '"entityId" : "u' + i + '",'
                  + '"targetEntityType" : "item",'
                  + '"targetEntityId" : "i' + i + '",'
                  + '"eventTime" : "' + eventTimes[i] + '"'
                + '}');
            
                Http http = new Http();
                HTTPResponse res = http.send(req);   
                System.debug('inserting: ' + i);
            }
           
          
        
    }
    
    
    public static void populateComplementaryManual() {
        /*
            List<String> eventTimes = new List<String>();
            for(Integer i=10; i<60; i++) {
                eventTimes.add('2014-11-02T09:' + i + ':45.618-08:00');
            }
            
            for(Integer i=0; i<50; i++) {
                HttpRequest req = new HttpRequest();
            
                req.setMethod('POST');
                req.setEndpoint('http://complementary-event-server.herokuapp.com/events.json?accessKey=' + ACCESS_KEY2);
                req.setHeader('Content-Type','application/json');
                req.setBody('{'
                  + '"event" : "buy",'
                  + '"entityType" : "user",'
                  + '"entityId" : "u' + i + '",'
                  + '"targetEntityType" : "item",'
                  + '"targetEntityId" : "i' + i + '",'
                  + '"eventTime" : "' + eventTimes[i] + '"'
                + '}');
            
                Http http = new Http();
                HTTPResponse res = http.send(req);   
                System.debug('inserting: ' + i);
            }
           
          */
        
    }
    
    public void predictAll() {
        String allPredictions = '';
        
        List<Product2> pList = [SELECT Id FROM Product2];
        
        for(Product2 p :pList) {
            known = p.Id;
            predictEvent();
            allPredictions += p.Id + ' - ' + prediction + ' / ';
        }
        prediction = allPredictions;
    }
    
    
    
    public static void populateComplementaryAuto() {
        List<String> eventTimes = new List<String>();
        for(Integer i=10; i<60; i++) {
            eventTimes.add('2014-11-02T09:' + i + ':45.618-08:00');
        }
        
        List<String> userIds = new List<String>();
        for(Integer i=1; i<11; i++) {
            userIds.add('u' + i);
        }
    
        List<String> popularItems = new List<String>();
        for(Integer i=1; i<4; i++) {
            popularItems.add('p'+i);
        }
        
        List<String> frequentItems = new List<String>();
        for(Integer i=1; i<11; i++) {
            frequentItems.add('f'+i);
        }
        
        List<String> randomItems = new List<String>();
        for(Integer i=1; i<51; i++) {
            randomItems.add('r'+i);
        }
        
        
       
    
        for(String uid :userIds) {
            
            for(Integer i=0; i<2; i++) {
                String randomTime = eventTimes[Math.round(Math.random()*49)];
                
                Integer popularItemIndex = Math.round(Math.random()*2);
                System.debug('popularItemIndex: ' + popularItemIndex);
                Integer frequentItemIndex = Math.round(Math.random()*9);
                System.debug('frequentItemIndex: ' + frequentItemIndex);
                Integer randomItemIndex1 = Math.round(Math.random()*48);
                System.debug('randomItemIndex1: ' + randomItemIndex1);
                Integer randomItemIndex2 = Math.round(Math.random()*48);
                System.debug('randomItemIndex2: ' + randomItemIndex2);
                Integer randomItemIndex3 = Math.round(Math.random()*48);
                System.debug('randomItemIndex3: ' + randomItemIndex3);
                
                makeRequest(randomTime, uid, popularItems[popularItemIndex]);
                makeRequest(randomTime, uid, frequentItems[frequentItemIndex]);
                makeRequest(randomTime, uid, randomItems[randomItemIndex1]);
                makeRequest(randomTime, uid, randomItems[randomItemIndex2]);
                makeRequest(randomTime, uid, randomItems[randomItemIndex3]);
                
                
            }
            
        }
    
        
        
        
        
        
        
        
        
        
        
        
        
        
    }
    
    public static HTTPResponse makeRequest(String timeStr, String userStr, String itemStr) {
        
        HttpRequest req = new HttpRequest();
            
                req.setMethod('POST');
                req.setEndpoint('http://complementary-event-server.herokuapp.com/events.json?accessKey=' + ACCESS_KEY2);
                req.setHeader('Content-Type','application/json');
                req.setBody('{'
                  + '"event" : "buy",'
                  + '"entityType" : "user",'
                  + '"entityId" : "' + userStr + '",'
                  + '"targetEntityType" : "item",'
                  + '"targetEntityId" : "' + itemStr + '",'
                  + '"eventTime" : "' + timeStr + '"'
                + '}');
            
                Http http = new Http();
                HTTPResponse res = http.send(req);
                return res;
    }
    
    
}