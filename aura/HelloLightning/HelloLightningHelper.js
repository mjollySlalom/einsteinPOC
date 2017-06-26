({
	helperMethod : function() {
		console.log('test');
	},
	
	getMyAuraVariableHelper : function(component) { 
    		//this will be the method name on the controller contained within the // controller property on our aura component 
    		var a = component.get("c.getMyAuraVariableFromTheController"); 
    		var self = this; //build the callback since all controller calls are batched and sent //asynchronously 
    		a.setCallback(this, function(action){ //action.getState() will let you know if it was successful or not. //a good idea would be to check this to make sure everything //worked as expected. 
    			console.log(action.getState()); //set the return value from the controller to the variable on our component 
    			component.set("v.yourAuraVaraible", action.getReturnValue()); //do more stuff }); //fire off the action .enqueueAction(a); 
    		});
    		
    	}
})