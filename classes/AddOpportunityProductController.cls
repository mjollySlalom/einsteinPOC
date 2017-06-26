/*    
    Matt Jolly | Slalom | 6/23/17
    Description - Add opportunity page controller.
*/            
public class AddOpportunityProductController {
    public Id itemId {get; private set;}
    public Id oppId {get; private set;}


    public AddOpportunityProductController() {
        itemId = ApexPages.currentPage().getParameters().get('itemId');
        oppId = ApexPages.currentPage().getParameters().get('oppId');
    }
    
    //Add the selected product to the selected opportunity
    @RemoteAction
    public static String attachSocket(Id itemId, Id oppId) {
        //Find the pricebook entry associated with the product
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE Product2Id = :itemId AND Pricebook2Id = '01s6A000002Ob7eQAC' LIMIT 1];
        //Crreate the line item record
        OpportunityLineItem oli = new OpportunityLineItem(Quantity = 1, OpportunityId = oppId, PricebookEntryId = pbe.Id, TotalPrice = 1);
        insert oli;
        return 'success';
    }
}