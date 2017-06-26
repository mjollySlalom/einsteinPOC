/*
    Matt Jolly | Slalom Consulting | 6/23/17
    Description - JS controller for board attachment recommendations lightning component
*/
({
    doInit: function(component, event, helper) {
        var action = component.get("c.getRecommendedAttachments");
        action.setParams({"oppId": component.get("v.recordId")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
               
                //Check that some records were returned               
                try {
                    var combinedList = JSON.parse(unescape(response.getReturnValue()));    
                } catch (err) {
                    return;
                }
                
                //The first item in the list is the selected Board for the opportunity
                    //The rest of the list contains recommended Sockets for the board
                component.set("v.selectedBoard", combinedList[0].item.Name);
                
                //Initialize the table and populate head
               var table = 
                   ' <table class="slds-table slds-table_bordered slds-table_resizable-cols slds-table_fixed-layout" role="grid">'
                       + '<thead>'
                           + '<tr >'
                                + '<th>Name</th>'
                                + '<th>Family</th>'
                                + '<th>Product Code</th>'
                               // + '<th>Description</th>'
                                + '<th>Score</th>'
                                + '<th></th>'
                            +'</tr>'
                        + '</thead>'
                        + '<tbody>';
                                
                //Add a table row for each recommended item                
                for(var i=1; i<combinedList.length; i++) {
                    table += 
                        '<tr>'
                            +'<td><a href="/' + combinedList[i].item.Id + '"> ' + combinedList[i].item.Name + ' </a>';
                    
                    //Add the product image. If none exists, add a placeholder image                            
                    table += combinedList[i].item.Product_Image__c == undefined 
                            ? '<br/><img src="http://via.placeholder.com/50x50"></img>'
                            : '<br/><img style="height:50px; width:50px;" src="' + combinedList[i].item.Product_Image__c + '"></img>';
                    
                    table +=
                            '</td>'
                            +'<td>' + combinedList[i].item.Family + '</td>'
                            +'<td>' + combinedList[i].item.ProductCode + '</td>'
                           // +'<td>' + combinedList[i].item.Description + '</td>'
                            +'<td>' + combinedList[i].score + '</td>';
                    
                    //Add product link
                    table += 
                            '<td><a href="https://einstein-poc-mj-dev-ed.lightning.force.com/apex/addOpportunityProduct?itemId=' + combinedList[i].item.Id + '&oppId=' + component.get("v.recordId") + '");">Add</a></td>';        
                    table += 
                        '</tr>';
                }    
                //finalize the table and append to the page
                table += '</tbody></table>';
                component.set("v.productTable", table);
                
               
            }else {
                console.log('failed');
            }
        });
        //Call the Apex action
        $A.enqueueAction(action);
    }
})