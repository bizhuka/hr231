sap.ui.controller("zhr231.ext.controller.ListReportExtension", {

  _prefix: 'zhr231::sap.suite.ui.generic.template.ListReport.view.ListReport::ZC_HR231_Emergency_Role--',

  _data: {
    singleTitle: '',
    startDate: new Date(),
    //viewKey: "OneMonth",
    supportedAppointmentItems: [],
    persons: [],
    list: []
  },

  onInit: function () {
    const listReportFilter = this.getView().byId(this._prefix + 'listReportFilter')
    listReportFilter.setLiveMode(true)
    listReportFilter.setShowClearOnFB(true)

    this._oModel = new sap.ui.model.json.JSONModel()
    this._oModel.setData(this._data)
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

        this.getView().byId(this._prefix + 'SinglePlanningCalendar-Header-NavToolbar-TodayBtn').firePress()

        const _this = this
        this.getView().byId(this._prefix + 'listReportFilter').attachAssignedFiltersChanged(function () {
          _this._updateCalendarItems()
        })

        this._checkAuthorization()
      }.bind(this))
  },

  onAfterRendering: function () {
    this._initReportMenu()
  },

  startDateChangeHandler: function () {
    this._updateCalendarItems()
  },

  _updateCalendarItems: function () {
    const _this = this
    const oFilterBar = _this.getView().byId(this._prefix + 'listReportFilter')
    const arrfilters = oFilterBar.getFilters()

    const startDate = new Date(this._data.startDate)
    this._data.singleTitle = startDate.getFullYear() + " - " + startDate.toLocaleString('default', { month: 'long' })

    // // if (this._data.viewKey === 'OneMonth') {
    // const date_from = new Date(startDate.getFullYear(), startDate.getMonth(), 1)
    // const date_to = new Date(startDate.getFullYear(), startDate.getMonth() + 1, 0)
    // // } else { // Week
    // //     const monday = this.getMonday(startDate)
    // //     date_from = new Date(monday)
    // //     monday.setDate(monday.getDate() + 6);
    // //     date_to = monday
    // // }
    // //console.log(this.getDateIso(date_from), this.getDateIso(date_to)) // this._data.viewKey, 
    // arrfilters.push(new sap.ui.model.Filter("begda", sap.ui.model.FilterOperator.LE, this.getDateIso(date_to)))
    // arrfilters.push(new sap.ui.model.Filter("endda", sap.ui.model.FilterOperator.GE, this.getDateIso(date_from)))

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
    this._data.list = []
    for (const objPerson of items) {
      const line = persons[objPerson.pernr] || {
        personID: objPerson.pernr,
        // __metadata.media_src  objPerson.photo_path +
        pic: document.location.origin + "/sap/opu/odata/sap/ZC_PY000_REPORT_CDS/ZC_PY000_PernrPhoto(pernr='" + objPerson.pernr +
          "')/$value?sap-client=300&$filter=" + encodeURIComponent('img_size eq 64'),
        ename: objPerson.ename,
        plans_txt: objPerson.plans_txt,
        appointments: []
      }
      const app = {
        role_text: objPerson.role_text,
        type: 'Type' + objPerson.eid,

        pernr: objPerson.pernr,
        ename: objPerson.ename,
        pic: line.pic,
        color: objPerson.color
      }
      this.setPeriod(app, objPerson)

      line.appointments.push(app)
      this._data.list.push(app)

      persons[objPerson.pernr] = line
    }
    this._data.persons = Object.values(persons)

    this.refreshCalendar()
  },

  setPeriod: function (item, src) {
    item.notes = src.notes
    item.start = this.getFixedDate(src.begda)

    const endda = this.getFixedDate(src.endda, true)
    item.end1 = endda.low
    item.end2 = endda.high

    item.tooltip = "From " + this.getTextDate(src.begda) + " to " + this.getTextDate(src.endda)
    if (item.notes)
      item.tooltip += (" - " + item.notes)
  },

  // TODO make lib
  getDateIso: function (date) {
    const okDate = new Date(date.getTime() - (date.getTimezoneOffset() * 60 * 1000))
    return okDate.toISOString().split('T')[0]
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
  },

  getMonday: function (d) {
    d = new Date(d);
    var day = d.getDay(),
      diff = d.getDate() - day + (day == 0 ? -6 : 1); // adjust when day is sunday
    return new Date(d.setDate(diff));
  },

  refreshCalendar: function (message, hard) {
    if (hard)
      this._updateCalendarItems()
    else
      //this._oModel.setData(this._data)
      this._oModel.updateBindings()

    // TODO  Check
    const oTable = this.getView().byId(this._prefix + 'responsiveTable')
    //if (oTable && oTable.getParent())
    oTable.getParent().rebindTable()

    if (message)
      sap.m.MessageToast.show(message, {
        duration: 3500
      })
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

  handleAppointmentSelect: function (oEvent) {
    const oAppointment = oEvent.getParameter("appointment")
    if (!oAppointment)
      return

    const _this = this
    sap.ui.require(["zhr231/ext/controller/Details"], function (Details) {
      if (!_this.details)
        _this.details = new Details(_this)

      _this.details.initItem(oAppointment.getBindingContext('calendar').getObject())
      _this.details.showPopup(oAppointment)
    })
  },

  appointmentCreate: function () {
    const _this = this
    sap.ui.require(["zhr231/ext/controller/Details"], function (Details) {
      if (!_this.details)
        _this.details = new Details(_this)

      _this.details.initItem({ start: new Date() }, true)
      _this.details.handleEditButton()
    })
  },

  update_1_appointment: function (message, delApp, insApp) {
    const row = this._data.persons.filter(item => item.personID === delApp.pernr)
    if (!row[0]) return

    const delArr = row[0].appointments.filter(app =>
      this.getTextDate(app.start) === this.getTextDate(this.getFixedDate(delApp.begda))
      && this.getTextDate(app.end1) === this.getTextDate(this.getFixedDate(delApp.endda)))
    if (!delArr[0]) return
    const delItem = delArr[0]

    if (insApp)
      this.setPeriod(delItem, insApp)
    else {
      row[0].appointments = row[0].appointments.filter(app => app !== delItem)
      this._data.list = this._data.list.filter(item => item !== delItem)
    }

    this.refreshCalendar(`Emergency role for ${delItem.pernr} ${message}`)
  },

  _setMessageParser: function () {
    const model = this.getOwnerComponent().getModel()
    sap.ui.require(["zhr231/ext/controller/MessageParser"], function (MessageParser) {
      const messageParser = new MessageParser(model.sServiceUrl, model.oMetadata, !!model.bPersistTechnicalMessages)
      model.setMessageParser(messageParser)
    })
  },

  _loadRoleText: function () {
    const _this = this
    const supportedAppointmentItems = _this._data.supportedAppointmentItems
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

      success: function (data) {
        if (data.results.length === 0)
          return

        for (let i = 1; i <= 3; i++)
          sap.ui.getCore().byId(`${_this._prefix}btCreate${i}`).setEnabled(true)
      }
    })
  },

  _initReportMenu: function () {
    const _this = this
    const _view = _this.getView()

    const menuId = _this._prefix + 'report-xlsx'
    if (_view.byId(menuId))
      return

    const params = {
      id: menuId,
      text: "Report",
      icon: "sap-icon://excel-attachment",

      press: function () {
        const table = _view.byId(_this._prefix + 'responsiveTable')
        const sFilter = table.getBinding("items").sFilterParams
        if (!sFilter || sFilter.indexOf("begda") === -1) {
          sap.m.MessageToast.show('Please specify filter with "Start date"', { duration: 3500 });
          $(".sapMMessageToast").css("background", "#cc1919");
          return
        }
        const sUrl =
          document.location.origin +
          "/sap/opu/odata/sap/ZC_HR231_EMERGENCY_ROLE_CDS/ZC_HR231_Emergency_Role(pernr='00000000',begda=datetime'2000-01-01T00%3A00%3A00',endda=datetime'2000-01-01T00%3A00%3A00',eid='00')/$value?" +
          sFilter
        window.open(sUrl)
      }
    }

    _view.byId(_this._prefix + 'template::ListReport::TableToolbar').addContent(new sap.m.Button(params))
  },

  onInitSmartFilterBarExtension: function (oEvent) {
    const _filterBar = oEvent.getSource()

    const filterData = _filterBar.getFilterData()
    const now = new Date()
    filterData.begda = {
      "ranges": [{
        "exclude": false,
        "operation": "BT",
        "keyField": "begda",
        "value1": new Date(now.setMonth(now.getMonth() - 4)),
        "value2": new Date(now.setMonth(now.getMonth() + 6))
      }]
    }
    _filterBar.setFilterData(filterData)

    // Hide variant selection
    this.getView().byId(this._prefix + 'template:::ListReportPage:::DynamicPageTitle').setVisible(false)
  },

  onDefaultEditClick: function (oEvent) {
    const action = oEvent !== 'CRE' ? oEvent.oSource.getTarget().substr(0, 3) : oEvent
    const nPernr = oEvent !== 'CRE' ? oEvent.oSource.getTarget().substr(4) : false

    if (action === 'DEL')
      this._doDefaultDelete(nPernr)
    else
      this._doDefaultEdit(action === 'CRE', nPernr)
  },

  _doDefaultEdit: function (create, nPernr) {
    const _this = this
    sap.ui.require(["zhr231/ext/controller/EditDef"], function (EditDef) {
      if (!_this.editDef)
        _this.editDef = new EditDef(_this)

      _this.editDef.openDialog(create, nPernr)
    })
  },

  defaultUpdated: function (message) {
    if (message)
      sap.m.MessageToast.show(message, {
        duration: 3500
      })
    this.getView().byId(this._prefix + 'idDefaultList').rebindTable()
  },

  _doDefaultDelete: function (nPernr) {
    const _this = this
    if (!this._deleteDialog) {
      this._deleteDialog = new sap.m.Dialog({
        type: sap.m.DialogType.Message,
        title: "Confirm",
        content: new sap.m.Text({ text: `Are you sure to delete ${nPernr} option?` }),
        beginButton: new sap.m.Button({
          type: sap.m.ButtonType.Emphasized,
          text: "Delete",
          press: function () {
            this._deleteDialog.close()

            this.getView().getModel().remove(`/ZC_HR231_DefaultsEdit('${nPernr}')`,
              {
                success: function () {
                  _this.defaultUpdated(`The option for ${nPernr} successfully deleted`)
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

});