({
    // To display Modal pop up
    handleClickv3: function(component, event, helper) {
        $A.util.removeClass(component.find("modal-id"), "slds-hide");
	},
    
    // To trigger direct download of the files
    handleClick: function(component) {
        var temp = component.get("v.bDirect");
        component.set("v.bDirect", !temp);
    },
    
    // To close the Modal pop up
    closeModal: function(component) {
        $A.util.addClass(component.find("modal-id"), "slds-hide");
    }
})