
sap.ui.define([
    "zhr231/ext/controller/Libs",
    "sap/m/Button",
    "sap/m/DynamicDateRange",
    "sap/m/DynamicDateUtil"
], function (Libs, Button, DynamicDateRange, DynamicDateUtil) {
    "use strict";

    return {

        REPORT: '00000000',
        SEND_EMAIL: '77777777',

        initAll: function (owner) {
            this.owner = owner

            const _view = owner.getView()
            _view.byId('listReport-btnPersonalisation').setVisible(false)
            _view.byId('listReport-btnExcelExport').setVisible(false)

            const toolbar = _view.byId(owner._prefix + 'template::ListReport::TableToolbar')

            this.dateFilter = new DynamicDateRange({
                id: owner._prefix + 'dateRange',
                value: { operator: 'THISWEEK', values: [] },
                required: true,
                width: '25rem',
                change: function () {
                    this.oSmartFilterBar.fireSearch()
                }.bind(this)
            })
            toolbar.addContent(this.dateFilter)


            toolbar.addContent(new Button({
                id: owner._prefix + 'report-xlsx',
                text: "Report",
                icon: "sap-icon://excel-attachment",

                press: function () {
                    const sUrl = this._get_url_with_filter(this.REPORT)
                    if (!sUrl)
                        return

                    window.open(sUrl)
                }.bind(this)
            }))

            toolbar.addContent(new Button({
                id: owner._prefix + 'send-link',
                text: "Send",
                icon: "sap-icon://email",

                press: this.send_email.bind(this)
            }))

        },

        _get_url_with_filter: function (kind) {
            const table = this.owner.getView().byId(this.owner._prefix + 'responsiveTable')
            const sFilter = table.getBinding("items").sFilterParams
            if (!sFilter || sFilter.indexOf("begda") === -1) {
                Libs.showMessage('Please specify filter with "Start date"', true)
                return ''
            }

            return document.location.origin +
                `/sap/opu/odata/sap/ZC_HR231_EMERGENCY_ROLE_CDS/ZC_HR231_Emergency_Role(pernr='${kind}',begda=datetime'2000-01-01T00%3A00%3A00',endda=datetime'2000-01-01T00%3A00%3A00',eid='00')/$value?` +
                sFilter
        },

        send_email: function () {
            const date_filter_info = document.getElementById(this.dateFilter.getId() + '-input-inner').value
            const sUrl = this._get_url_with_filter(this.SEND_EMAIL) + ` and photo_path ne '${date_filter_info}'`
            if (!sUrl)
                return

            Libs.send_request(sUrl, function (result) {
                result = JSON.parse(result)
                Libs.showMessage(decodeURIComponent(result.message), result.error)
            }.bind(this))
        },

        _get_date_filter: function () {
            const arrDates = DynamicDateUtil.toDates(this.dateFilter.getValue())
            return [
                new sap.ui.model.Filter("begda", sap.ui.model.FilterOperator.LE, Libs.getDateIso(Libs.set_noon(arrDates[1]))),
                new sap.ui.model.Filter("endda", sap.ui.model.FilterOperator.GE, Libs.getDateIso(Libs.set_noon(arrDates[0])))]
        },

        beforeFilter: function (oSmartFilterBar, oBindingParams) {
            this.oSmartFilterBar = oSmartFilterBar

            oBindingParams.filters.push(... this._get_date_filter())
        }

    };
});

