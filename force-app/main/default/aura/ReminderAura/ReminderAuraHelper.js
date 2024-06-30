({
    validateForm : function(component) {
        // Validate form fields
        let isValid = true;
        let field1Value = component.find("v.message").get("v.value");
        if ( field1Value != '') {
            isValid = false;
        }

        return isValid;
    }
})
