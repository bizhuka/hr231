sap.ui.controller("zhr231.ext.controller.ObjectPageExtension", {

	_prefix: 'zhr231::sap.suite.ui.generic.template.ObjectPage.view.Details::ZC_HR231_Emergency_Role--',


	onInit: function () {
		const objectPage = this.getView().byId(this._prefix + "objectPage")
		if (objectPage)
			objectPage.setUseIconTabBar(true)
	},


});
