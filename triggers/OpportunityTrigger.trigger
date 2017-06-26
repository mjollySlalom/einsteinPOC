trigger OpportunityTrigger on Opportunity (before update, after update, before insert, after insert, before delete, after delete) {

    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            
        } else if(Trigger.isUpdate) {
            
        } else if(Trigger.isDelete) {
            
        } else if(Trigger.isUndelete) {
            
        }
    } else if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            
        } else if(Trigger.isUpdate) {
            OpportunityTriggerDispatcher.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
        } else if(Trigger.isDelete) {
            
        } else if(Trigger.isUndelete) {
            
        }
    }

}