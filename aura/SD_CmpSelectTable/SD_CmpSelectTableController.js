({
    // On Load function to frame Data table columns and data
    init: function(component, event, helper) {
        // Row Actions
        var actions = [
            { label: "Preview", name: "show_preview" }
        ];
        
        // Setting up the data table columns Title, Owner, LastModified, and Size
        component.set("v.columns", [
            {
                label: "Title", fieldName: "icon", sortable: true, 
                cellAttributes: {
                    iconName: { 
                        fieldName: "iconName" 
                    },
                    iconLabel: { 
                        fieldName: "stTitle" 
                    },
                    iconPosition: "left",
                    class: "custom-icon"
                }
            },
            {
                label: "Owner", fieldName: "stOwnerId", sortable: true, type: "url",
                typeAttributes: {
                    label: { 
                        fieldName: "stOwner" 
                    },
                    tooltip: { 
                        fieldName: "stOwner" 
                    },
                    target: "_blank" 
                } 
            },
            {
                label: "Last Modified", fieldName: "dtModifiedDate", sortable: true, type: "date",
                typeAttributes: {
                    day: "numeric",  
                    month: "short",  
                    year: "numeric",  
                    hour: "2-digit",  
                    minute: "2-digit",  
                    second: "2-digit",  
                    hour12: true
                }
            },
            {
                label: "Size", fieldName: "stContentSize", sortable: true, type: "text"
            },
            { 
                type: "action", 
                typeAttributes: { 
                    rowActions: actions, 
                    menuAlignment: "left" 
                } 
            }
        ]);
        
        // Fetching the file records
        var stRecordId = component.get("v.recordId");
        if(stRecordId !== undefined) {
            helper.fetchData(component);
        }
    },
    
    // Column sorting
    updateColumnSorting: function(component, event, helper) {
        component.set("v.bSpinner", true);
        // We use the setTimeout method here to simulate the async
        // process of the sorting data, so that user will see the
        // spinner loading when the data is being sorted.
        setTimeout($A.getCallback(function() {
            var fieldName = event.getParam("fieldName");
            var sortDirection = event.getParam("sortDirection");
            component.set("v.sortedBy", fieldName);
            component.set("v.sortedDirection", sortDirection);
            helper.sortData(component, fieldName, sortDirection);
            component.set("v.bSpinner", false);
        }), 0);
    },
    
    // On Row selection, checking the checkbox
    handleRowSelection: function(component, event) {
        var selectedRows = event.getParam("selectedRows");
        component.set("v.selectedData", selectedRows);
        component.set("v.bWarning", false);
    },
    
    // Triggering download all files
    handleClickv2: function(component, event, helper) {
        var recordList = component.get("v.selectedData");
        helper.downloadWithIds(component, recordList);
    },
    
    // Triggering download for single file
    handleClickv3: function(component, event, helper) {
        helper.downloadNormal(component);
    },
    
    // Triggering direct download of all files
    handleClickv4: function(component, event, helper) {
        helper.downloadAll(component);
    },
    
    // Open preview of the record
    handleRowAction: function(component, event, helper) {
        var action = event.getParam("action");
        var row = event.getParam("row");
        
        if(action !== undefined) {
            if(action.name === "show_preview") {
                var rows = component.get("v.data");
                var rowIndex = helper.getRowIndex(rows, row);
                
                var content = rows[rowIndex];
                var records = [];
                records.push(content.stDownloadId);
                
                var fireEvent = $A.get("e.lightning:openFiles");
                fireEvent.fire({
                    recordIds: records
                });
            }
        }
    },
    
    handleTypeFilter: function(component, event, helper) {
        if(event.getSource() !== undefined) {
            var clicked = event.getSource();
            if(clicked.get("v.iconName") !== undefined) {
                var filteredData = [];
                var iconName = clicked.get("v.iconName");
                var backupData = component.get("v.backupData");
                var dataLength = backupData.length;
                for(var i=0;i<dataLength;i=i+1) {
                    var data = backupData[i];
                    if(data.iconName === iconName) {
                        filteredData.push(data);
                    }
                }
                
                var icons = component.get("v.icons");
                var updatedIcons = [];
                for(var j=0;j<icons.length;j=j+1) {
                    var icon = icons[j];
                    icon.variant = "neutral"
                    updatedIcons.push(icon);
                }
                
                component.set("v.data", filteredData);
                component.set("v.icons", updatedIcons);
                
                clicked.set("v.variant", "brand");
            }
        }
    },
    
    updateToDefault: function(component, event, helper) {
        helper.iconsToDefault(component);
    },
    
    handleMenuSelect: function(component, event) {
        var selectedMenuItemValue = event.getParam("value");
        if(selectedMenuItemValue === "Upload") {
            
            
        } else if(selectedMenuItemValue === "View") {
            // Fire the event to navigate to the standard Files list view
            var relatedListEvent = $A.get("e.force:navigateToRelatedList");
            relatedListEvent.setParams({
                "relatedListId": "CombinedAttachments",
                "parentRecordId": component.get("v.recordId")
            });
            relatedListEvent.fire();
        }
    },
    
    handleRefresh: function(component, event, helper) {
        // Fetching the file records
        helper.fetchData(component);
        // aligning icons to default;
        helper.iconsToDefault(component);
    }
})