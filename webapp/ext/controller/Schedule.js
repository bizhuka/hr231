
sap.ui.define([
    "zhr231/ext/controller/Libs",
], function (Libs) {
    "use strict";

    return {
        _data: {
            title: '',
            startDate: new Date(),
            schedule: []
        },

        init: function (owner) {
            this.owner = owner

            this._oModel = new sap.ui.model.json.JSONModel()
            this._oModel.setDefaultBindingMode(sap.ui.model.BindingMode.TwoWay)
            this._oModel.setData(this._data)

            const workSchedule = owner.getView().byId('idWorkSchedule')
            // if(workSchedule)
            workSchedule.setModel(this._oModel, "schedule")
        },

        _refreshSchedule: function () {
            --this._counter
            this._oModel.updateBindings()
        },

        readCurrentSchedule: function (nPernr, month, app) {
            if (this._counter > 0) return
            this._counter = 2

            this._data.schedule = []

            if (app) month = Libs.get_middle(app.start, app.end1)
            if (!month) month = this._data.startDate
            Libs.set_noon(month)

            this._data.title = month.getFullYear() + " - " + month.toLocaleString('default', { month: 'long' })
            this._data.startDate = month

            if (!nPernr) {
                const urlPart = "pernr='"
                const iFrom = window.location.href.indexOf(urlPart)
                nPernr = window.location.href.substring(iFrom + urlPart.length, iFrom + urlPart.length + 8)
            }

            this._read_roles(nPernr, month)
            this._read_schedule(nPernr, month)
        },

        _read_roles: function (nPernr, month) {
            const firstDay = Libs.getFirstDayOfMonth(month)
            const begda = Libs.addDays(firstDay, -6)
            const endda = Libs.addDays(firstDay, 31 + 13)

            const arrFilter = [
                new sap.ui.model.Filter("pernr", sap.ui.model.FilterOperator.EQ, nPernr),
                new sap.ui.model.Filter("begda", sap.ui.model.FilterOperator.LE, Libs.getDateIso(endda)),
                new sap.ui.model.Filter("endda", sap.ui.model.FilterOperator.GE, Libs.getDateIso(begda))
            ]

            this.owner.getView().getModel().read("/ZC_HR231_Emergency_Role", {
                filters: arrFilter,

                success: function (data) {
                    for (const objPerson of data.results) {
                        const app = Libs.createAppointment(objPerson)
                        this._data.schedule.push({
                            start: app.start,
                            end: app.end1,
                            title: `${app.role_text} - ${app.tooltip}`,
                            color: app.color,

                            _app: app
                        })
                    }
                    this._refreshSchedule()
                }.bind(this)
            })
        },

        _read_schedule: function (nPernr, month) {
            this.owner.getView().getModel().read("/ZC_PT028_Schedule", {
                urlParameters: {
                    "$select": "begda,endda,tprog,kind,info,color",
                    "$filter": "datum eq datetime'" + Libs.getDateIso(month) + "T00:00:00' and pernr eq '" + nPernr + "'"
                },
                success: function (data) {
                    for (let item of data.results)
                        this._data.schedule.push({
                            start: item.begda,
                            end: item.endda,
                            title: item.tprog + (item.info ? " - " + item.info : ''),
                            color: item.color,
                        })
                    this._refreshSchedule()
                }.bind(this),

                error: function (oError) {
                    console.log(oError)
                }
            })
        }



    };
});

