({
    // Generic server call function
    callToServer: function(component, method, callback, params, background, spinner) {
        // Server method to call
        var action = component.get(method);
        // Check if Spinner is required
        if(spinner) {
            component.set("v.bSpinner", true);
        }
        // Setting up the parameters for server method
        if(params) {
            action.setParams(params);
        }
        // Server should run in the background
        if(background) {
            action.setBackground();
        }
        // Server callback
        action.setCallback(this, function(response) {
            if(spinner) {
                component.set("v.bSpinner", false);
            }
            // response status
            var state = response.getState();
            if (state === "SUCCESS") {
                // response status if it is Success
                callback.call(this, response.getReturnValue());
            } else if(state === "ERROR") {
                // response status if it is error
                var errors = response.getError();
                if (errors) {
                    // assigning the error messages to the error attributes
                    if (errors[0] && errors[0].message) {
                        component.set("v.stErrorMessage", errors[0].message);
                        component.set("v.bError", true);
                    }
                }
            } else {
                // generic error message
                component.set("v.stErrorMessage", "ERROR: Unknown Error");
                component.set("v.bError", true);
            }
        });
        // Trigger the server action
        $A.enqueueAction(action);
    },
    
    fetchData: function(component) {
        // Server call to get the File records
        var self = this;
        self.callToServer(
            component,
            "c.getAttachments",
            function(response) {
                if(response.length > 0) {
                    // If the server returns records
                    var result = response[0];
                    if(!result.bError) {
                        if(!result.bEmpty) {
                            var attachments = result.recordList;
                            component.set("v.bLightningExperience", result.bLightningExperience);
                            if(attachments !== undefined) {
                                if(attachments.length > 0) {
                                    // Mapping data wrt the data table
                                    self.alignData(component, attachments);
                                    // Sorting based on the last modified date in desc order
                                    self.sortData(component, "dtModifiedDate", "dsc");
                                    // Enabling Data Table
                                    component.set("v.bEnableTable", true);
                                    component.set("v.bDisabled", false);
                                    component.set("v.backupData", component.get("v.data"));
                                }
                            }
                        } else {
                            // If the server returns empty records
                            component.set("v.stErrorMessage", result.stMessage);
                            component.set("v.bError", true);
                            component.set("v.bDisabled", true);
                        }
                    } else {
                        // If the server returns error
                        component.set("v.stErrorMessage", result.stMessage);
                        component.set("v.bError", true);
                        component.set("v.bDisabled", true);
                    }
                }
            },
            {
                "stRecordId" : component.get("v.recordId")
            }, false, true);
    },
    
    // Mapping data wrt the data table
    alignData: function(component, recordList) {
        var self = this;
        var updatedList = [];
        for(var i=0; i<recordList.length; i=i+1) {
            var record = recordList[i];
            var stType = record.stExtension;
            record.iconName = self.iconType(component, stType);
            record.stContentSize = self.updateContentSize(record.inContentSize);
            updatedList.push(record);
        }
        
        component.set("v.data", updatedList);
        
        var iconsList = component.get("v.icons");
        if(iconsList.length > 1) {
            component.set("v.bIconFilter", true);
        } 
    },
    
    // Generic sorting data function
    sortData: function (component, fieldName, sortDirection) {
        var self = this;
        var data = component.get("v.data");
        var reverse = sortDirection !== "asc";
        
        if(fieldName === "icon") {
            fieldName = "stTitle";
        } else if(fieldName === "stOwnerId") {
            fieldName = "stOwner";
        } else if(fieldName === "stContentSize") {
            fieldName = "inContentSize";
        }
        
        data = Object.assign([], data.sort(self.sortBy(fieldName, reverse ? -1 : 1)));
        component.set("v.data", data);
    },
    
    // Generic sorting logic
    sortBy: function (field, reverse, primer) {
        var key = primer
        ? function(x) {
            return primer(x[field]);
        }
        : function(x) {
            return x[field];
        };
        
        return function (a, b) {
            var A = key(a);
            var B = key(b);
            return reverse * ((A > B) - (B > A));
        };
    },
    
    // Mapping the icons wrt the extensions
    iconType: function(component, stType) {
        var iconName = "";
        var name = "";
        if(stType === "xls" || stType === "xlsx") {
            iconName = "doctype:excel";
            name = "XLS";
        } else if(stType === "doc" || stType === "docx") {
            iconName = "doctype:word";
            name = "DOC";
        } else if(stType === "ppt" || stType === "pptx") {
            iconName = "doctype:ppt";
            name = "PPT";
        } else if(stType === "pdf") {
            iconName = "doctype:pdf";
            name = "PDF";
        } else if(stType === "txt") {
            iconName = "doctype:txt";
            name = "TXT";
        } else if(stType === "html") {
            iconName = "doctype:html";
            name = "HTML";
        } else if(stType === "csv") {
            iconName = "doctype:csv";
            name = "CSV";
        } else if(stType === "zip" || stType === "rar") {
            iconName = "doctype:zip";
            name = "ZIP";
        } else if(stType === "xml") {
            iconName = "doctype:xml";
            name = "XML";
        } else if(stType === "mp4") {
            iconName = "doctype:mp4";
            name = "MP4";
        } else if(stType === "png" || stType === "jpg" || stType === "jpeg" || stType === "bmp" || stType === "gif") {
            iconName = "doctype:image";
            name = "IMG";
        } else {
            iconName = "doctype:attachment";
            name = "ATCH";
        }
        
        var iconsList = component.get("v.icons");
        if(iconsList.length > 0) {
            if(JSON.stringify(iconsList).indexOf(iconName) > -1) {
                
            } else {
                var record = {};
                record.icon = iconName;
                record.name = name;
                record.variant = "neutral";
                iconsList.push(record);
            }
        } else {
            var record = {};
            record.icon = iconName;
            record.name = name;
            record.variant = "neutral";
            iconsList.push(record);
        }
        component.set("v.icons", iconsList);
        
        return iconName;
    },
    
    // Checking for the record sizes
    updateContentSize: function(stSize) {
        if(stSize > 0) {
            stSize = stSize/1024;
            if(stSize < 1) {
                stSize = stSize * 1000;
                stSize = Math.round(stSize);
                return stSize.toString() + ' B';
            }
            stSize = Math.round(stSize);
            if(stSize < 1024) {
                return stSize.toString() + ' KB';
            } else {
                stSize = stSize/1024;
                stSize = stSize.toFixed(2);
                return stSize.toString() + ' MB';
            }
        } else {
            return '0 KB';
        }
    },
    
    // Get the row index selected
    getRowIndex: function(rows, row) {
        var rowIndex = -1;
        rows.some(function(current, i) {
            if (current.stRecordId === row.stRecordId) {
                rowIndex = i;
                return true;
            }
        });
        return rowIndex;
    },
    
    // Simple download with the Content Ids
    downloadWithIds: function(component, recordList) {
        component.set("v.bSpinner", true);
        
        var recordLength = recordList.length;
        var parameter = "";
        
        // Building the download link
        if(recordLength > 0) {
            for(var i=0;i<recordLength;i=i+1) {
                var record = recordList[i];
                parameter = parameter + "/" + record.stDownloadId;
            }
            
            var stDefaultURL = "/sfc/servlet.shepherd/document/download/";
            
            if(component.get("v.bLightningExperience")) {
                
                parameter = stDefaultURL + parameter + "?";
                window.open(parameter);
                
            } else {
                var stCommunity = component.get("v.stCommunity");
                
                if(stCommunity) {
                    parameter = "/" + stCommunity + stDefaultURL + parameter + "?";
                    window.open(parameter);
                } else {
                    component.set("v.stErrorMessage", "Please enter community name, contact your Admin");
                    component.set("v.bError", true);
                }
            }
        } else {
            component.set("v.bWarning", true);
        }
        
        component.set("v.bSpinner", false);
    },
    
    // Single file download using content document Id
    downloadNormal: function(component) {
        component.set("v.bSpinner", true);
        
        var recordList = component.get("v.selectedData");
        var recordLength = recordList.length;
        
        if(recordLength > 0) {
            var stDefaultURL = "/sfc/servlet.shepherd/document/download/";
            
            if(component.get("v.bLightningExperience")) {
                for(var i=0;i<recordLength;i=i+1) {
                    var record = recordList[i];
                    var parameter = stDefaultURL + record.stDownloadId + "?";
                    window.open(parameter);
                }
            } else {
                var stCommunity = component.get("v.stCommunity");
                if(stCommunity) {
                    for(var i=0;i<recordLength;i=i+1) {
                        var record = recordList[i];
                        var parameter = "/" + stCommunity + stDefaultURL + record.stDownloadId + "?";
                        window.open(parameter);
                    }
                } else {
                    component.set("v.stErrorMessage", "Please enter community name, contact your Admin");
                    component.set("v.bError", true);
                }
            }            
        } else {
            component.set("v.bWarning", true);
        }
        
        component.set("v.bSpinner", false);
    },
    
    // Direct download of all the attachments
    downloadAll: function(component) {
        var self = this;
        var data = component.get("v.data");
        self.downloadWithIds(component, data);
    },
    
    iconsToDefault: function(component) {
        var updatedIcons = [];
        var icons = component.get("v.icons");
        
        for(var j=0;j<icons.length;j=j+1) {
            var icon = icons[j];
            icon.variant = "neutral"
            updatedIcons.push(icon);
        }
        
        component.set("v.icons", updatedIcons);
        component.set("v.data", component.get("v.backupData"));
    }
})