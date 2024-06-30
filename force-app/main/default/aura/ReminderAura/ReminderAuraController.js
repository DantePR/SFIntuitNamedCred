({
    handleClick : function(component, event, helper) {
        // Change the message when the button is clicked
        
        let action = component.get("c.changeText");
        action.setParams({ NewText: "Some value" });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                // Handle the successful response
                let result = response.getReturnValue();
                console.log(result);
                component.set("v.message", result);
            } else {
                // Handle the error
                let errors = response.getError();
                console.error(errors);
                component.set("v.message", errors);
            }
        });


        
    }
})
