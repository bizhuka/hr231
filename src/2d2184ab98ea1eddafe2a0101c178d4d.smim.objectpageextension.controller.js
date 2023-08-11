// sap.ui.controller("zhr231.ext.controller.ObjectPageExtension", {})

sap.ui.define([
	"zhr231/ext/controller/Schedule",
	//"zhr231/ext/controller/ListReportExtension.controller"
], function (Schedule) {
	"use strict";

	return {
		_prefix: 'zhr231::sap.suite.ui.generic.template.ObjectPage.view.Details::ZC_HR231_Emergency_Role--',


		onInit: function () {
			// const objectPage = this.getView().byId(this._prefix + "objectPage")
			// if (objectPage) objectPage.setUseIconTabBar(true)

			window._objectPage = this
			Schedule.init(this)
		},

		onAfterRendering: function () {
			Schedule.readCurrentSchedule()
		},

		startDateChangeHandler: function (oEvent) {
			Schedule.readCurrentSchedule(null, oEvent.getParameter('date'))
		},

		handleAppointmentSelect: function (oEvent) {
			const oAppointment = oEvent.getParameter("appointment")
			if (!oAppointment)
				return

			const obj = oAppointment.getBindingContext('schedule').getObject()
			if (obj._app) window._listReport.handleAppointmentSelect(oEvent, obj._app)
		}
	}
})



