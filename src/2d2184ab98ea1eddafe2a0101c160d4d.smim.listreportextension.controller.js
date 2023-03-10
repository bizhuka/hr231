sap.ui.controller("zhr231.ext.controller.ListReportExtension", {

  _prefix: 'zhr231::sap.suite.ui.generic.template.ListReport.view.ListReport::ZC_HR231_Emergency_Role--',

  onInit: function () {
    window._main_table = this.getView().byId(this._prefix + 'responsiveTable')

    const listReportFilter = this.getView().byId(this._prefix + 'listReportFilter')
    listReportFilter.setLiveMode(true)
    listReportFilter.setShowClearOnFB(true)

    window._main_table.attachItemPress(function (oEvent) {
      const obj = oEvent.getParameters().listItem.getBindingContext().getObject()
      if (window._objectPage) {
        const items = []
        for (bind of window._main_table.getItems())
          items.push(bind.getBindingContext().getObject())
        window._objectPage.setCurrentPerson(items, obj.pernr, obj.begda)
      }
    })
  },

  onAfterRendering: function (oEvent) {
    this._setMessageParser()
    this._initReportMenu()
    this._initCreateDialog()
  },

  _setMessageParser: function () {
    const _view = this.getView()
    const model = _view.getModel()
    sap.ui.require(["zhr231/ext/controller/MessageParser"], function (MessageParser) {
      const messageParser = new MessageParser(model.sServiceUrl, model.oMetadata, !!model.bPersistTechnicalMessages)
      model.setMessageParser(messageParser)
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

    const baseMenu = _view.byId(this._prefix + 'listReport-btnExcelExport')
    if (baseMenu)
      baseMenu.getMenu().addItem(new sap.m.MenuItem(params))
    else  // For sapui5 1.71
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
        "value1": new Date(now.setMonth(now.getMonth() - 2)),
        "value2": new Date(now.setMonth(now.getMonth() + 4))
      }]
    }
    _filterBar.setFilterData(filterData)
    //_filterBar.fireSearch()

    // Hide variant selection
    this.getView().byId(this._prefix + 'template:::ListReportPage:::DynamicPageTitle').setVisible(false)
  },

  _initCreateDialog: function () {
    const _this = this
    const _view = _this.getView()

    _view.byId(_this._prefix + 'addEntry').attachPress(function () {
      const createDialog = _view.byId(_this._prefix + 'CreateWithDialog')
      if (createDialog && !createDialog.mEventRegistry.afterOpen) createDialog.attachAfterOpen(function () {
        createDialog.setContentWidth('23em')
        const _byId = sap.ui.getCore().byId
        _byId('__form0').setTitle('Create Emergency Team Duty')
      })
    })
  }
});