public class OpportunityInlineController { 


    @AuraEnabled public static String getMyAuraVariableFromTheController() { 
        System.debug('called on server side');
        return 'Here is the text from my controller'; 
    
    } 

}