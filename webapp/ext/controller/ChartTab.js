sap.ui.define([
	"zhr231/ext/controller/Libs",

	"sap/ui/base/Object",
	"sap/ui/model/json/JSONModel",
	"sap/ui/model/Filter",
	"sap/ui/model/FilterOperator",
	"sap/viz/ui5/format/ChartFormatter",
	"sap/viz/ui5/controls/common/feeds/FeedItem",
	"sap/viz/ui5/data/MeasureDefinition"
], function (Libs, SapObject, JSONModel, Filter, FilterOperator, ChartFormatter, FeedItem, MeasureDefinition) {
	"use strict";

	return SapObject.extend("zhr231.ext.controller.ChartTab", {
		owner: null,

		_chart: {
			_items: [],

			_period_key: 'MONTH',
			_periods: [
				{ key: 'WEEK', value: 'Week' },
				{ key: 'MONTH', value: 'Month' },
				{ key: 'QUARTER', value: 'Quarter' },
				{ key: 'YEAR', value: 'Year' },
			]
		},

		constructor: function (owner) {
			this.owner = owner

			sap.ui.core.BusyIndicator.show(0)
			sap.ui.core.Fragment.load({ id: owner.getView().getId(), name: "zhr231.ext.fragment.ChartTab", controller: this })
				.then(function (chartTab) {
					this.owner.getView().byId('popOverDuty').connect(this.owner.getView().byId('frameDuty').getVizUid())

					this.chartModel = new JSONModel()
					this.chartModel.setDefaultBindingMode(sap.ui.model.BindingMode.TwoWay);
					this.chartModel.setData(this._chart)

					chartTab.setModel(this.chartModel, "chart")
					this.read_chart_data()

					owner.getView().byId('chartVBox').addItem(chartTab)
					sap.ui.core.BusyIndicator.hide()
				}.bind(this))

		},

		_calculate_average_line: function (items) {
			const frame = this.owner.getView().byId('frameDuty')
			const vizProperties = frame.getVizProperties()
			const valueAxis = vizProperties.plotArea.referenceLine.line.valueAxis

			const isVisible = items.length > 0

			// Average value
			valueAxis[0].visible = isVisible
			if (isVisible) {
				valueAxis[0].value = isVisible ? items.reduce((total, next) => total + Number(next.days_count), 0) / items.length : 0
				valueAxis[0].label.text = `Average value ${Math.round(valueAxis[0].value * 100) / 100}`
			}
			frame.setVizProperties(vizProperties)
		},

		_fillDuty: function (items) {
			const unqDuty = {}
			const unqItems = {}
			for (const item of items) {
				const updateLine = unqItems[item.period] ? unqItems[item.period] : {
					period: item.period,
					period_raw: item.period_raw
				}
				unqItems[item.period] = updateLine

				const name = `d${item.pernr}`
				updateLine[name] = (updateLine[name] ? updateLine[name] : 0) + Number(item.days_count)
				unqDuty[name] = `${item.ename} (${parseInt(item.pernr, 10)})`
			}
			this._chart._items = Object.values(unqItems)
			this._chart._items.sort((a, b) => a.period_raw > b.period_raw ? 1 : -1)

			// Delete previous feeds
			const frameDuty = this.owner.getView().byId('frameDuty')
			const feeds = frameDuty.getFeeds()
			for (let i = 1; i < feeds.length; i++) //0 is Dimension period
				frameDuty.removeFeed(feeds[i])

			const datasetDuty = this.owner.getView().byId('datasetDuty')
			datasetDuty.removeAllMeasures()

			const arr_pernr_texts = []
			for (const pernr_key in unqDuty) {
				const pernr_text = unqDuty[pernr_key]
				arr_pernr_texts.push(pernr_text)

				datasetDuty.addMeasure(new MeasureDefinition({
					value: `{chart>${pernr_key}}`,
					name: pernr_text
				}))
			}

			frameDuty.addFeed(new FeedItem({
				uid: "valueAxis",
				type: "Measure",
				values: arr_pernr_texts
			}))
		},

		read_chart_data: function () {
			const filterBar = this.owner.getView().byId(this.owner._prefix + 'listReportFilter')
			const filters = filterBar.getFilters()

			const fakeFilter = this._chart._period_key + (filterBar.getBasicSearchValue() ? '^' + filterBar.getBasicSearchValue() : '')
			filters.push(new Filter("period", FilterOperator.EQ, fakeFilter))

			this.owner.getOwnerComponent().getModel().read("/ZC_HR231_Chart", {
				filters: filters,

				urlParameters: {
					"$select": "pernr,period,days_count,ename,period_raw"
					//"search": filterBar.getBasicSearchValue()
				},

				success: function (data) {
					this._fillDuty(data.results)
					this._calculate_average_line(data.results)

					this.chartModel.updateBindings()
				}.bind(this)
			})

		}

	});
}
);