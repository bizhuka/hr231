sap.ui.define([
    'sap/ui/base/Object'
], function (Object) {
    "use strict";

    return Object.extend("zhr231.ext.controller.Details", {
        owner: null,
        _item: {},

        constructor: function (owner) {
            this.owner = owner
            this._model = new sap.ui.model.json.JSONModel()
            this._model.setData(this._item)
        },

        showPopup: function (oAppointment) {
            if (!this._popup) {
                this._popup = sap.ui.xmlfragment("zhr231.ext.fragment.Popup", this)
                this.owner.getView().addDependent(this._popup)
                this._popup.setModel(this._model, 'item')
            }

            const src = oAppointment.getBindingContext('calendar').getObject()
            this._item.pernr = src.pernr
            this._item.ename = src.ename
            this._item.notes = src.notes
            this._item.title = src.title
            this._item.type = src.type
            this._item.info = src.info
            this._item.start = new Date(src.start.getTime())
            this._item.end = new Date(src.end1.getTime())

            // +1 day
            this._item.start.setDate(this._item.start.getDate() + 1)
            this._item.prev_start = new Date(this._item.start.getTime())
            // +1 day
            this._item.end.setDate(this._item.end.getDate() + 1)
            this._item.prev_end = new Date(this._item.end.getTime())

            this._model.updateBindings()
            this._popup.openBy(oAppointment);
        },

        handleEditButton: function (oEvent) {
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

        handleEditChangeButton: function () {
            const _dialog = this._dialog
            const _item = this._item

            this.owner.getView().getModel().create("/ZC_HR231_Emergency_Role",
                {
                    pernr: _item.pernr,
                    notes: _item.notes,
                    begda: "\/Date(" + _item.start.getTime() + ")\/",
                    endda: "\/Date(" + _item.end.getTime() + ")\/",
                    prev_begda: "\/Date(" + _item.prev_start.getTime() + ")\/",
                    prev_endda: "\/Date(" + _item.prev_end.getTime() + ")\/"
                },
                {
                    success: function (data) {
                        window._objectPage.update_1_appointment("updated",
                            {
                                pernr: _item.pernr,
                                begda: _item.prev_start,
                                endda: _item.prev_end
                            },
                            {
                                pernr: _item.pernr,
                                begda: data.begda,
                                endda: data.endda,
                                notes: data.notes
                            })
                        _dialog.close()
                    }
                })

        },

        handlePopoverDeleteButton: function () {
            const _item = this._item
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
console.log(_item)
                            this.owner.getView().getModel().remove("/ZC_HR231_Emergency_Role(pernr='" + _item.pernr + "',begda=datetime'"
                                + _item.prev_start.toISOString().split('T')[0] + "T00%3A00%3A00',endda=datetime'"
                                + _item.prev_end.toISOString().split('T')[0] + "T00%3A00%3A00',eid='"
                                + _item.type.substring(4, 6) + "')",
                                {
                                    success: function (data) {
                                        window._objectPage.update_1_appointment("deleted",
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
        }

    });
}
);