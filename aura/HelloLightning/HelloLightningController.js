
({

	handleClick : function(component, event, helper) {
		var btnClicked = event.getSource();         // the button
        var btnMessage = btnClicked.get("v.label"); // the button's label
        component.set("v.message", btnMessage);     // update our message
       
		helper.helperMethod();
	},
	
	doInit: function(cmp, helper) {
		
		
		
		cmp.set("v.setMeOnInit", "controller init magic!");
		//alert(cmp.get("v.recordId"));
	
		
		
		
		
			console.log('starting');
            //var currProdId = prodId;
            
            var table = 
                       ' <table class="table table-striped">'
                           + '<thead>'
                               + '<tr>'
                                    + '<th>Name</th>'
                                    + '<th>Family</th>'
                                    + '<th>Description</th>'
                                    + '<th>Product Code</th>'
                                    + '<th>Score</th>'
                                    + '<th></th>'
                                +'</tr>'
                            + '</thead>'
                            + '<tbody>';
                            
            table += '</tbody></table>';
               
            
            console.log('finishing');
		
		console.log('table: ' + table);
		cmp.set("v.tableElem", '0123');
		cmp.set("v.setMeOnInit", table);
		console.log('helper: ' + helper);
	//	helper.getMyAuraVariableHelper(cmp);
	//helper.helperMethod();
		
	//	helper.helperMethod();
		
		
		
    },
    
    	getMyAuraVariable : function(component, helper) { 
    			console.log('called********************');
    		//this will be the method name on the controller contained within the // controller property on our aura component 
    		var a = component.get("c.getMyAuraVariableFromTheController"); 
    		var self = this; //build the callback since all controller calls are batched and sent //asynchronously 
    		a.setCallback(this, function(action){ //action.getState() will let you know if it was successful or not. //a good idea would be to check this to make sure everything //worked as expected. 
    			console.log(action.getState()); //set the return value from the controller to the variable on our component 
    			component.set("v.yourAuraVaraible", action.getReturnValue()); //do more stuff }); //fire off the action .enqueueAction(a); 
    		});
    		
    	}
    
   

})