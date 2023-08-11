sap.ui.define([
    "zhr231/ext/controller/Libs",
    "sap/ui/base/Object"
], function (Libs, SapObject) {
    "use strict";

    return SapObject.extend("zhr231.ext.controller.Details", {
        owner: null,
        _item: {},

        constructor: function (owner) {
            this.owner = owner
            this._model = new sap.ui.model.json.JSONModel()
            this._model.setDefaultBindingMode(sap.ui.model.BindingMode.TwoWay);
            this._model.setData(this._item)
        },

        initItem: function (src, dialogCreateMode) {
            this.dialogCreateMode = !!dialogCreateMode

            for (let variableKey in this._item)
                if (this._item.hasOwnProperty(variableKey))
                    delete this._item[variableKey]

            this._item.pernr = src.pernr
            this._item.ename = src.ename
            this._item.notes = src.notes
            this._item.role_text = src.role_text
            this._item.eid = src.type ? src.type.substring(4, 6) : ""
            this._item.prev_eid = this._item.eid
            this._item.info = src.info
            this._item.start = new Date(src.start.getTime())

            if (!this.dialogCreateMode) {
                this._item.end = new Date(src.end1.getTime())

                // +1 day
                this._item.start.setDate(this._item.start.getDate() + 1)
                this._item.prev_start = new Date(this._item.start.getTime())
                // +1 day
                this._item.end.setDate(this._item.end.getDate() + 1)
                this._item.prev_end = new Date(this._item.end.getTime())
            }
            this._item.actionText = this.dialogCreateMode ? "Create" : "Change"

            this._model.updateBindings()
        },

        showPopup: function (oAppointment) {
            if (!this._popup) {
                this._popup = sap.ui.xmlfragment("zhr231.ext.fragment.Popup", this)
                this.owner.getView().addDependent(this._popup)
                this._popup.setModel(this._model, 'item')
            }

            this._popup.openBy(oAppointment);
        },

        handleEditButton: function () {
            if (!this._dialog) {
                this._dialog = sap.ui.xmlfragment("zhr231.ext.fragment.Dialog", this)
                this.owner.getView().addDependent(this._dialog)
                this._dialog.setModel(this._model, 'item')
            }
            this._dialog.open()
        },

        handleEditCancelButton: function () {
            this._dialog.close()
        },

        handleActionButton: function () {
            this.set_pernr()

            if (this.dialogCreateMode) {
                this.handleCreate()
                return
            }
            const _this = this
            const _item = _this._item

            _this.owner.getView().getModel().create("/ZC_HR231_Emergency_Role",
                {
                    pernr: _item.pernr,
                    notes: _item.notes,
                    begda: "\/Date(" + _item.start.getTime() + ")\/",
                    endda: "\/Date(" + _item.end.getTime() + ")\/",                    
                    emergrole_id: _item.eid,

                    eid: _item.prev_eid,
                    prev_begda: "\/Date(" + _item.prev_start.getTime() + ")\/",
                    prev_endda: "\/Date(" + _item.prev_end.getTime() + ")\/"
                },
                {
                    success: function (data) {                        
                        _this.owner.update_1_appointment("updated",
                            {
                                pernr: _item.pernr,
                                begda: _item.prev_start,
                                endda: _item.prev_end
                            },
                            {
                                pernr: _item.pernr,
                                eid: _item.eid,
                                role_text: sap.ui.getCore().byId("inType").getSelectedItem().getProperty('text'),
                                color: data.color,

                                begda: data.begda,
                                endda: data.endda,
                                notes: data.notes,                                
                            })
                        _this._dialog.close()
                    }
                })
        },

        handleCreate: function () {
            const _this = this
            const _item = _this._item

            _this.owner.getView().getModel().create("/ZC_HR231_Emergency_Role",
                {
                    pernr: _item.pernr,
                    emergrole_id: _item.eid,
                    notes: _item.notes,
                    begda: "\/Date(" + _item.start.getTime() + ")\/",
                    endda: "\/Date(" + _item.end.getTime() + ")\/"
                },
                {
                    success: function (data) {
                        _this.owner.refreshCalendar(`Emergency role for ${_item.pernr} created`, true)
                        _this._dialog.close()
                    }
                })
        },

        handlePopoverDeleteButton: function () {
            const _this = this
            const _item = _this._item
            if (!this.oConfirmDialog) {
                this.oConfirmDialog = new sap.m.Dialog({
                    type: sap.m.DialogType.Message,
                    title: "Confirm",
                    content: new sap.m.Text({ text: "Do you want to delete this role?" }),
                    beginButton: new sap.m.Button({
                        type: sap.m.ButtonType.Emphasized,
                        text: "Delete",
                        press: function () {
                            this.oConfirmDialog.close()

                            this.owner.getView().getModel().remove("/ZC_HR231_Emergency_Role(pernr='" + _item.pernr + "',begda=datetime'"
                                + Libs.getDateIso(_item.prev_start) + "T00%3A00%3A00',endda=datetime'"
                                + Libs.getDateIso(_item.prev_end) + "T00%3A00%3A00',eid='"
                                + _item.eid + "')",
                                {
                                    success: function (data) {
                                        _this.owner.update_1_appointment("deleted",
                                            {
                                                pernr: _item.pernr,
                                                begda: _item.prev_start,
                                                endda: _item.prev_end
                                            })
                                    }
                                })
                        }.bind(this)
                    }),
                    endButton: new sap.m.Button({
                        text: "Cancel",
                        press: function () {
                            this.oConfirmDialog.close();
                        }.bind(this)
                    })
                });
            }

            this.oConfirmDialog.open();
        },

        _onAfterDialogOpen: function () {
            this.set_pernr()
        },

        set_pernr: function(){
            const nPernr = this._item.pernr ? this._item.pernr.replace(/^0+/, '') : ''
            // sap.ui.getCore().byId("idEdtPernr").setValue(nPernr)            
            
            const pernrInput = sap.ui.getCore().byId("idEdtPernr-input")
            pernrInput.mBindingInfos['value'].skipModelUpdate = true
            pernrInput.setValue(nPernr)

            document.getElementById("idEdtPernr-input-inner").value = nPernr
            //     pernrInput.setEditable(this.dialogCreateMode) Can change type?
        },

        _onOtherSelected: function (oEvent) {            
            const { emergrole_id, ename } = oEvent.getParameter('changes')
            this._item.ename = ename
            this._item.eid = emergrole_id
            
            this._model.updateBindings()
            this.set_pernr()
        },

        _onPernrSelected: function (oEvent) {
            if(oEvent.mParameters.validated)
                this._item.pernr = oEvent.mParameters.newValue
        }
    });
}
);