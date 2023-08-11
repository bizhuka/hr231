sap.ui.define([
    "zhr231/ext/controller/Libs",
    "sap/ui/base/Object"
], function (Libs, SapObject) {
    "use strict";

    return SapObject.extend("zhr231.ext.controller.EditDef", {
        owner: null,
        _def: {},

        constructor: function (owner) {
            this.owner = owner
            this._model = new sap.ui.model.json.JSONModel()
            this._model.setDefaultBindingMode(sap.ui.model.BindingMode.TwoWay);
            this._model.setData(this._def)
        },

        openDialog: function (create, cPernrEid) {
            const _this = this
            _this.dialogCreateMode = create

            _this._def.pernr = ''
            _this._def.emergrole_id = ''
            _this._def.ename = ''
            _this._def.kz = false
            _this._def.ru = false
            _this._def.en = false

            _this._def.actionText = create ? "Create" : "Change"
            if (create) {
                _this.showDialog()
                return
            }

            const arrPair = cPernrEid.split('-')
            _this._def.pernr = arrPair[0]
            _this._def.emergrole_id = arrPair[1]

            this.readByPernr("ZC_HR231_DefaultsEdit", _this._def.emergrole_id, function (item) {
                _this._def.emergrole_id = item.emergrole_id
                _this._def.ename = item.ename
                _this._def.kz = item.kz
                _this._def.ru = item.ru
                _this._def.en = item.en

                _this.showDialog()
            })
        },

        readByPernr: function (enitySetName, emergrole_id, callback) {
            const affFilter = [new sap.ui.model.Filter("pernr", sap.ui.model.FilterOperator.EQ, this._def.pernr)]
            if(emergrole_id)
                affFilter.push(new sap.ui.model.Filter("emergrole_id", sap.ui.model.FilterOperator.EQ, emergrole_id))

            this.owner.getOwnerComponent().getModel().read(`/${enitySetName}`, {
                filters: affFilter,

                success: function (data) {
                    callback(data.results[0])
                }
            })
        },

        showDialog: function () {
            this._model.updateBindings()

            if (!this._dialog) {
                this._dialog = sap.ui.xmlfragment("zhr231.ext.fragment.EditDef", this)
                this.owner.getView().addDependent(this._dialog)
                this._dialog.setModel(this._model, 'def')
            }
            this._dialog.open()
        },

        closeDialog: function (oEvent) {
            this.owner.defaultUpdated(typeof oEvent === 'string' ? oEvent : '')
            this._dialog.close()
        },

        handleActionButton: function () {
            const _this = this
            const _def = _this._def

            const item = {
                pernr: _def.pernr,
                emergrole_id: _def.emergrole_id,
                kz: _def.kz,
                ru: _def.ru,
                en: _def.en,
            }

            if (!item.pernr || !item.emergrole_id) {
                Libs.showMessage('Input required fields', true)
                return
            }

            const methodName = this.dialogCreateMode ? 'create' : 'update'
            _this.owner.getView().getModel()[methodName]("/ZC_HR231_DefaultsEdit" + (!this.dialogCreateMode ? `(pernr='${item.pernr}',emergrole_id='${item.emergrole_id}')` : ''),
                item,
                {
                    success: function () {
                        _this.closeDialog(`Option for ${_this._def.pernr} ${methodName}d`)
                    }
                })
        },

        _onAfterDialogOpen: function () {
            const nPernr = this._def.pernr ? this._def.pernr.replace(/^0+/, '') : ''
            sap.ui.getCore().byId("idDefPernr").setValue(nPernr)
            sap.ui.getCore().byId("idDefPernr-input").setEditable(this.dialogCreateMode)
        },

        _onDialogPernrSelected: function (oEvent) {
            const _this = this
            _this._def.pernr = oEvent.mParameters.newValue
            _this.readByPernr("ZC_HR231_OrgAssign", false, function (item) {
                _this._def.ename = item.ename
                _this._model.updateBindings()
            })
        }
    });
}
);