sap.ui.controller("zhr231.ext.controller.ObjectPageExtension", {

	_prefix: 'zhr231::sap.suite.ui.generic.template.ObjectPage.view.Details::ZC_HR231_Emergency_Role--',
	_data: {
		singleTitle: '',
		startDate: new Date(),
		viewKey: "Week",
		supportedAppointmentItems: [],
		team: [],
		selector: []
	},

	onInit: function () {
		window._objectPage = this

		const objectPage = this.getView().byId(this._prefix + "objectPage")
		if (objectPage)
			objectPage.setUseIconTabBar(true)

		this._oModel = new sap.ui.model.json.JSONModel()
		this._oModel.setData(this._data)
		this._oCalendarContainer = sap.ui.getCore().byId(this._prefix + "TeamContainer")
		this._mCalendars = {}
		this._sSelectedView = this._data.viewKey
		this._loadCalendar("PlanningCalendar")
	},

	_refreshCalendar: function () {
		this._oModel.updateBindings()
	},

	// Loads and displays calendar (if not already loaded), otherwise just displays it
	_loadCalendar: function (sCalendarId) {
		const _this = this
		var oView = this.getView();

		if (!this._mCalendars[sCalendarId]) {
			this._mCalendars[sCalendarId] = sap.ui.core.Fragment.load({
				id: oView.getId(),
				name: "zhr231.ext.fragment." + sCalendarId,
				controller: this
			}).then(function (oCalendarVBox) {
				//this._populateSelect(this.byId(sCalendarId + "TeamSelector"));
				return oCalendarVBox;
			}.bind(this));
		}

		this._mCalendars[sCalendarId].then(function (oCalendarVBox) {
			oCalendarVBox.setModel(_this._oModel, "calendar");
			this._displayCalendar(sCalendarId, oCalendarVBox);
		}.bind(this));
	},

	// Displays already loaded calendar
	_displayCalendar: function (sCalendarId, oCalendarVBox) {
		this._oCalendarContainer.removeAllContent()

		this._oCalendarContainer.addContent(oCalendarVBox);
		var oCalendar = oCalendarVBox.getItems()[0];
		var oTeamSelect = this.byId(sCalendarId + "TeamSelector");
		oTeamSelect.setSelectedKey(this._sSelectedMember);

		// oCalendar.setStartDate(this._data.startDate);
		if (isNaN(this._sSelectedMember)) {
			// Planning Calendar
			//oCalendar.setViewKey(this._sSelectedView);
			oCalendar.setViewKey("Week")
			oCalendar.bindElement({
				path: "/team",
				model: "calendar"
			});
		} else {
			// Single Planning Calendar
			//oCalendar.setSelectedView(oCalendar.getViewByKey(this._sSelectedView));
			oCalendar.setSelectedView(oCalendar.getViewByKey("OneMonth"))
			oCalendar.bindElement({
				path: "/team/" + this._sSelectedMember,
				model: "calendar"
			});
		}
	},

	update_1_appointment: function (message, delApp, insApp) {
		const row = this._data.team.filter(item => item.personID === delApp.pernr)
		if (!row[0]) return

		const delArr = row[0].appointments.filter(app =>
			this.getTextDate(app.start) === this.getTextDate(this.getFixedDate(delApp.begda))
			&& this.getTextDate(app.end1) === this.getTextDate(this.getFixedDate(delApp.endda)))
		if (!delArr[0]) return
		const delItem = delArr[0]


		if (!insApp)
			row[0].appointments = row[0].appointments.filter(app => app !== delItem)
		else
			this.setPeriod(delItem, insApp)

		this._refreshCalendar()
		window._main_table.getParent().rebindTable()
		sap.m.MessageToast.show('Emergency role ' + message, {
			duration: 3500
		});
	},

	setPeriod: function (item, src) {
		item.notes = src.notes
		item.start = this.getFixedDate(src.begda)

		const endda = this.getFixedDate(src.endda, true)
		item.end1 = endda.low
		item.end2 = endda.high

		item.info = "From " + this.getTextDate(src.begda) + " to " + this.getTextDate(src.endda)
		if (item.notes)
			item.info += (" - " + item.notes)
	},

	setCurrentPerson: function (items, pernr, begda) {
		this._loadCalendar("PlanningCalendar")

		const team = {}
		for (objPerson of items) {
			const line = team[objPerson.pernr] || {
				personID: objPerson.pernr,
				// __metadata.media_src  objPerson.photo_path +
				pic: document.location.origin + "/sap/opu/odata/sap/ZC_PY000_REPORT_CDS/ZC_PY000_PernrPhoto(pernr='" + objPerson.pernr +
						 "')/$value?sap-client=300&$filter=" + encodeURIComponent('img_size eq 64'),
				name: objPerson.ename,
				role: objPerson.plans_txt,
				appointments: [],
				headers: []
			}
			const app = {
				title: objPerson.role_text,
				type: 'Type' + objPerson.eid,

				pernr: objPerson.pernr,
				ename: objPerson.ename
			}
			this.setPeriod(app, objPerson)
			line.appointments.push(app)

			team[objPerson.pernr] = line
		}

		// to array
		const first = team[pernr]
		if (first) {
			delete team[pernr]
			this._data.team = Object.values(team)
			this._data.team.unshift(first)
		}


		this._data.selector = []
		this._data.selector.push({
			index: 'Team',
			text: 'Team'
		})
		for (index = 0; index < this._data.team.length; index++) {
			this._data.selector.push({
				index: index,
				text: this._data.team[index].name
			});
		}

		if (begda)
			this._setStartDate(this.getFixedDate(this.getMonday(begda)))

		this._refreshCalendar()
	},

	_setStartDate: function (date) {
		this._data.startDate = date
		this._data.singleTitle = date.getFullYear() + " - " + date.toLocaleString('default', { month: 'long' })
	},

	// Saves currently selected date
	startDateChangeHandler: function (oEvent) {
		this._setStartDate(new Date(oEvent.getSource().getStartDate()))
	},

	onAfterRendering: function () {
		const _this = this
		if (!window._main_table)
			this.getView().getModel().read("/ZC_HR231_Emergency_Role", {
				urlParameters: {
					"$select": "pernr,role_text,begda,endda,ename,plans_txt,grp_text,notes,eid,photo_path",
					"$filter": "(begda ge datetime'" + _this.getDateIso(new Date(new Date().getFullYear(), 0, 1)) + "T00:00:00' and begda le datetime'" + _this.getDateIso(new Date()) + "T00:00:00')"
				},
				success: function (data) {
					_this.setCurrentPerson(data.results,
						_this._getFromUrl("pernr='", 8),
						new Date(_this._getFromUrl("begda=datetime'", 10)))
				},
				error: function (oError) {
					console.log(oError)
				}
			})

		const supportedAppointmentItems = _this._data.supportedAppointmentItems
		if (supportedAppointmentItems.length === 0)
			this.getView().getModel().read("/ZC_HR231_EmergeRoleText", {
				urlParameters: {
					"$select": "eid,text",
				},
				success: function (data) {
					for (item of data.results)
						supportedAppointmentItems.push({
							type: 'Type' + item.eid,
							text: item.text + ' (' + item.eid + ')'
						})
					_this._refreshCalendar()
				},
				error: function (oError) {
					console.log(oError)
				}
			})
	},

	// TODO make lib
	getDateIso: function (date) {
		const okDate = new Date(date.getTime() - (date.getTimezoneOffset() * 60 * 1000))
		return okDate.toISOString().split('T')[0]
	},

	// Saves currently selected view
	viewChangeHandler: function (oEvent) {
		return
		var oCalendar = oEvent.getSource();
		if (isNaN(this._sSelectedMember)) {
			this._sSelectedView = oCalendar.getViewKey();
		} else {
			this._sSelectedView = oCore.byId(oCalendar.getSelectedView()).getKey();
		}
		//oCalendar.setStartDate(this._data.startDate);
	},

	// Opend a legend
	openLegend: function (oEvent) {
		var _this = this,
			oSource = oEvent.getSource(),
			oView = _this.getView();
		if (!this._pLegendPopover) {
			this._pLegendPopover = sap.ui.core.Fragment.load({
				id: oView.getId(),
				name: "zhr231.ext.fragment.Legend",
				controller: this
			}).then(function (oLegendPopover) {
				oLegendPopover.setModel(_this._oModel, "calendar")
				oView.addDependent(oLegendPopover);
				return oLegendPopover;
			});
		}
		this._pLegendPopover.then(function (oLegendPopover) {
			if (oLegendPopover.isOpen()) {
				oLegendPopover.close();
			} else {
				oLegendPopover.openBy(oSource);
			}
		});
	},


	// Does loading of the PC/SPC depending on selected item
	selectChangeHandler: function (oEvent) {
		this._sSelectedMember = oEvent.getParameter("selectedItem").getKey();
		this._loadCalendar(isNaN(this._sSelectedMember) ? "PlanningCalendar" : "SinglePlanningCalendar");
	},

	// Loads SPC for a person which row is clicked
	rowSelectionHandler: function (oEvent) {
		var oSelectedRow = oEvent.getParameter("rows")[0],
			sSelectedId = oSelectedRow.getId();
		this._sSelectedMember = sSelectedId.substr(sSelectedId.lastIndexOf('-') + 1);
		oSelectedRow.setSelected(false);
		this._loadCalendar("SinglePlanningCalendar");
	},

	handleAppointmentSelect: function (oEvent) {
		const oAppointment = oEvent.getParameter("appointment")
		if (!oAppointment)
			return

		const _this = this
		sap.ui.require(["zhr231/ext/controller/Details"], function (Details) {
			if (!_this.details)
				_this.details = new Details(_this)
			_this.details.showPopup(oAppointment)
		})
	},

	// // Handler of the "Create" button
	// appointmentCreate: function (oEvent) {
	// 	MessageToast.show("Creating new appointment...");
	// },

	_getFromUrl: function (name, count) {
		const ind = window.location.href.indexOf(name)
		if (ind === -1)
			return null
		return window.location.href.substr(ind + name.length, count)
	},

	getMonday: function (d) {
		d = new Date(d);
		var day = d.getDay(),
			diff = d.getDate() - day + (day == 0 ? -6 : 1); // adjust when day is sunday
		return new Date(d.setDate(diff));
	},

	getTextDate: function (d) {
		return d.toLocaleDateString('ru-RU')
	},

	getFixedDate: function (date, pair) {
		const low = new Date(date.getTime() + date.getTimezoneOffset() * 60000)
		if (!pair)
			return low

		const high = new Date(low.getTime());
		high.setDate(high.getDate() + 1)

		return {
			low: low,
			high: high
		}
	}
});
