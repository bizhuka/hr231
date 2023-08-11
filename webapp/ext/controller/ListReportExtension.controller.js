// sap.ui.controller("zhr231.ext.controller.ListReportExtension", {});

sap.ui.define([
  "zhr231/ext/controller/Libs",
  "zhr231/ext/controller/Schedule",
  "zhr231/ext/controller/ReportButtons",
  "zhr231/ext/controller/MessageParser",
  "zhr231/ext/controller/Details",
  "zhr231/ext/controller/EditDef",
], function (Libs, Schedule, ReportButtons, MessageParser, Details, EditDef) {
  "use strict";

  return {
    _prefix: 'zhr231::sap.suite.ui.generic.template.ListReport.view.ListReport::ZC_HR231_Emergency_Role--',

    _calendar_data: {
      generalTitle: '',
      // startDate: null,
      supportedAppointmentItems: [],
      persons: [],
      list: [],
      canCreate: false,
      canUpdDefaults: false,
    },

    onInit: function () {
      sap.ui.core.BusyIndicator.show(0)

      const listReportFilter = this.getView().byId(this._prefix + 'listReportFilter')
      listReportFilter.setLiveMode(true)
      listReportFilter.setShowClearOnFB(true)

      this._oModel = new sap.ui.model.json.JSONModel()
      // this._calendar_data.startDate = Libs.getMonday(new Date())
      this._oModel.setData(this._calendar_data)
      this.getView().setModel(this._oModel, "calendar")
      this._setMessageParser()
      this._loadRoleText()

      const parLevel = this.getView().byId(this._prefix + 'page')
      const smartTable = parLevel.getContent()
      sap.ui.core.Fragment.load({ id: this.getView().getId(), name: "zhr231.ext.fragment.Main", controller: this })
        .then(function (oMainObjectPageLayout) {
          parLevel.setContent(oMainObjectPageLayout)

          // Insert to new place          
          this.getView().byId('idSmartTableParent').addBlock(smartTable)

          // this.getView().byId(this._prefix + 'idGeneralCalendar-Header-NavToolbar-TodayBtn').firePress()
          const generalCalendar = this.getView().byId('idGeneralCalendar')
          generalCalendar.setSelectedView(generalCalendar.getViews()[1]) // Month

          this.getView().byId(this._prefix + 'listReportFilter').attachAssignedFiltersChanged(function () {
            this._updateCalendarItems()
          }.bind(this))

          this._checkAuthorization()
          sap.ui.core.BusyIndicator.hide()
        }.bind(this))

      // Hide variant selection
      this.getView().byId(this._prefix + 'template:::ListReportPage:::DynamicPageTitle').setVisible(false)

      window._listReport = this
      this.getView().byId('responsiveTable').attachItemPress(function (oEvent) {
        const obj = oEvent.getParameters().listItem.getBindingContext().getObject()
        Schedule.readCurrentSchedule(obj.pernr, null, Libs.createAppointment(obj))
      }.bind(this))
    },

    handleRowHeaderClick: function (oEvent) {
      const row = oEvent.mParameters.row.getBindingContext('calendar').getObject()
      if (row.appointments.length === 0)
        return

      const firstApp = row.appointments[0]
      const urlKey = {
        pernr: "*" + firstApp.pernr + "*",
        begda: `datetime*${Libs.getDateIso(firstApp.start)}T00%3A00%3A00*`,
        endda: `datetime*${Libs.getDateIso(firstApp.end1)}T00%3A00%3A00*`,
        eid: "*" + firstApp.type.substr(4) + "*"
      }

      window.location.href = `index.html#/ZC_HR231_Emergency_Role(${new URLSearchParams(urlKey).toString().replaceAll("*", "'").replaceAll('&', ',')})/`
      Schedule.readCurrentSchedule(firstApp.pernr, null, firstApp)
    },

    handleMoreLinkPress: function (oEvent) {
      const oDate = oEvent.getParameter("date")
      const generalCalendar = this.getView().byId('idGeneralCalendar')

      generalCalendar.setSelectedView(generalCalendar.getViews()[0]) // Week

      // this._oModel.setData({ startDate: oDate }, true)
      generalCalendar.setStartDate(oDate)
    },

    onAfterRendering: function () {
      ReportButtons.initAll(this)
    },

    onBeforeRebindTableExtension: function (oEvent) {
      const oBindingParams = oEvent.getParameter("bindingParams");
      oBindingParams.parameters = oBindingParams.parameters || {};

      const oSmartTable = oEvent.getSource();
      const oSmartFilterBar = this.byId(oSmartTable.getSmartFilterId())

      if (this._ChartTab) // && this._active_section === 'chartTab')
        this._ChartTab.read_chart_data()

      ReportButtons.beforeFilter(oSmartFilterBar, oBindingParams)
    },

    startDateChangeHandler: function () {
      this._updateCalendarItems()
    },

    onSectionChange: function (oEvent) {
      this._active_section = oEvent.getParameter('section').getId().replace(this._prefix, '')

      if (this._active_section === 'idGeneralSection' || this._active_section === 'idPersonalSection')
        this._updateCalendarItems()


      if (this._active_section === 'chartTab') {
        sap.ui.core.BusyIndicator.show(0)
        sap.ui.require(["zhr231/ext/controller/ChartTab"], function (ChartTab) {
          sap.ui.core.BusyIndicator.hide()
          if (!this._ChartTab)
            this._ChartTab = new ChartTab(this)
        }.bind(this));
      }
    },

    _get_period: function () {
      if (this._active_section === 'idGeneralSection') {
        const startDate = this.getView().byId('idGeneralCalendar').getStartDate()
        this._calendar_data.generalTitle = startDate.getFullYear() + " - " + startDate.toLocaleString('default', { month: 'long' })
        return {
          date_from: Libs.addDays(startDate, -6),
          date_to: Libs.addDays(startDate, 31 + 13)
        }
      }

      const calendar = this.getView().byId('idPersonalCalendar')
      const startDate = calendar.getStartDate()
      return {
        date_from: Libs.addDays(startDate, 0),
        date_to: Libs.addDays(startDate, calendar.getViewKey() === 'OneMonth' ? 30 : 6)
      }
    },

    _updateCalendarItems: function () {
      const _this = this
      const oFilterBar = _this.getView().byId(this._prefix + 'listReportFilter')
      const arrfilters = oFilterBar.getFilters()

      const period = this._get_period()
      arrfilters.push(new sap.ui.model.Filter("begda", sap.ui.model.FilterOperator.LE, Libs.getDateIso(period.date_to)))
      arrfilters.push(new sap.ui.model.Filter("endda", sap.ui.model.FilterOperator.GE, Libs.getDateIso(period.date_from)))

      this.getOwnerComponent().getModel().read("/ZC_HR231_Emergency_Role", {
        filters: arrfilters,
        urlParameters: {
          "$select": "pernr,role_text,begda,endda,ename,plans_txt,grp_text,notes,eid,color,photo_path",
          "search": oFilterBar.getBasicSearchValue()
        },

        success: function (data) {
          _this.setCalendarItems(data.results)
        }
      })
    },

    setCalendarItems: function (items) {
      const persons = {}
      this._calendar_data.list = []
      for (const objPerson of items) {
        const line = persons[objPerson.pernr] || {
          personID: objPerson.pernr,
          pic: Libs.get_avatar_url(objPerson.pernr),
          ename: objPerson.ename,
          plans_txt: objPerson.plans_txt,
          appointments: []
        }

        const app = Libs.createAppointment(objPerson)
        line.appointments.push(app)
        this._calendar_data.list.push(app)

        persons[objPerson.pernr] = line
      }
      this._calendar_data.persons = Object.values(persons)

      this.refreshCalendar()
    },

    refreshCalendar: function (message, hard) {
      if (hard)
        this._updateCalendarItems()
      else
        //this._oModel.setData(this._calendar_data)
        this._oModel.updateBindings()

      // TODO  Check
      const oTable = this.getView().byId(this._prefix + 'responsiveTable')
      //if (oTable && oTable.getParent())
      oTable.getParent().rebindTable()

      if (message) {
        Libs.showMessage(message)

        if (this.scheduleObj && window._objectPage)
          Schedule.readCurrentSchedule()
      }
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

    handleAppointmentSelect: function (oEvent, appObject) {
      this.scheduleObj = appObject

      const oAppointment = oEvent.getParameter("appointment")
      if (!oAppointment)
        return

      if (!this.details)
        this.details = new Details(this)

      if (!appObject) appObject = oAppointment.getBindingContext('calendar').getObject()
      this.details.initItem(appObject)

      this.details.showPopup(oAppointment)
    },

    appointmentCreate: function () {
      if (!this.details)
        this.details = new Details(this)

      this.details.initItem({ start: new Date() }, true)
      this.details.handleEditButton()
    },

    update_1_appointment: function (message, delApp, insApp) {
      const row = this._calendar_data.persons.filter(item => item.personID === delApp.pernr)
      if (!row[0]) return

      const delArr = row[0].appointments.filter(app =>
        Libs.getTextDate(app.start) === Libs.getTextDate(Libs.getFixedDate(delApp.begda))
        && Libs.getTextDate(app.end1) === Libs.getTextDate(Libs.getFixedDate(delApp.endda)))
      if (!delArr[0]) return
      const delItem = delArr[0]

      if (insApp)
        Libs.set_main_fields(delItem, insApp)
      else {
        row[0].appointments = row[0].appointments.filter(app => app !== delItem)
        this._calendar_data.list = this._calendar_data.list.filter(item => item !== delItem)
      }

      this.refreshCalendar(`Emergency role for ${delItem.pernr} ${message}`)
    },

    _setMessageParser: function () {
      const model = this.getOwnerComponent().getModel()
      const messageParser = new MessageParser(model.sServiceUrl, model.oMetadata, !!model.bPersistTechnicalMessages)
      model.setMessageParser(messageParser)
    },

    _loadRoleText: function () {
      const _this = this
      const supportedAppointmentItems = _this._calendar_data.supportedAppointmentItems
      if (supportedAppointmentItems.length === 0)
        this.getOwnerComponent().getModel().read("/ZC_HR231_EmergeRoleText", {
          urlParameters: {
            "$select": "eid,text,color",
          },
          success: function (data) {
            for (const item of data.results)
              supportedAppointmentItems.push({
                type: 'Type' + item.eid,
                text: item.text + ' (' + item.eid + ')',
                color: item.color.toLowerCase()
              })
          }
        })
    },

    _checkAuthorization: function () {
      const _this = this
      _this.getOwnerComponent().getModel().read(`/ZC_HR231_DefaultsEdit`, {
        filters: [new sap.ui.model.Filter("pernr", sap.ui.model.FilterOperator.EQ, '99999999')],

        urlParameters: {
          "$select": "allowed_eids,upd_defaults"
        },
        success: function (data) {
          if (data.results.length === 0)
            return

          this._calendar_data.canCreate = data.results[0].allowed_eids.length > 0
          this._calendar_data.canUpdDefaults = data.results[0].upd_defaults === 'X'
          this._oModel.updateBindings()
        }.bind(this)
      })
    },

    onDefaultEditClick: function (oEvent) {
      const action = oEvent !== 'CRE' ? oEvent.oSource.getTarget().substr(0, 3) : oEvent
      const cPernrEid = oEvent !== 'CRE' ? oEvent.oSource.getTarget().substr(4) : false

      if (action === 'DEL')
        this._doDefaultDelete(cPernrEid)
      else
        this._doDefaultEdit(action === 'CRE', cPernrEid)
    },

    _doDefaultEdit: function (create, cPernrEid) {
      if (!this.editDef)
        this.editDef = new EditDef(this)

      this.editDef.openDialog(create, cPernrEid)
    },

    defaultUpdated: function (message) {
      if (message)
        Libs.showMessage(message)
      this.getView().byId(this._prefix + 'idDefaultList').rebindTable()
    },

    _doDefaultDelete: function (cPernrEid) {
      const _this = this
      const arrPair = cPernrEid.split('-')
      if (!this._deleteDialog) {
        this._deleteDialog = new sap.m.Dialog({
          type: sap.m.DialogType.Message,
          title: "Confirm",
          content: new sap.m.Text({ text: `Are you sure to delete ${arrPair[0]} - ${arrPair[1]} option?` }),
          beginButton: new sap.m.Button({
            type: sap.m.ButtonType.Emphasized,
            text: "Delete",
            press: function () {
              this._deleteDialog.close()

              this.getView().getModel().remove(`/ZC_HR231_DefaultsEdit(pernr='${arrPair[0]}',emergrole_id='${arrPair[1]}')`,
                {
                  success: function () {
                    _this.defaultUpdated(`The option for ${arrPair[0]} - ${arrPair[1]} successfully deleted`)
                  }
                })
            }.bind(this)
          }),
          endButton: new sap.m.Button({
            text: "Cancel",
            press: function () {
              this._deleteDialog.close()
            }.bind(this)
          })
        });
      }

      this._deleteDialog.open();
    }
  }
})