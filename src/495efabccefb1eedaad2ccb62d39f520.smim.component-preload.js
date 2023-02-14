//@ui5-bundle zhr231/Component-preload.js
jQuery.sap.registerPreloadedModules({
"version":"2.0",
"modules":{
	"zhr231/Component.js":function(){sap.ui.define(["sap/suite/ui/generic/template/lib/AppComponent"],function(e){"use strict";return e.extend("zhr231.Component",{metadata:{manifest:"json"}})});
},
	"zhr231/ext/controller/ListReportExtension.controller.js":function(){sap.ui.controller("zhr231.ext.controller.ListReportExtension",{_prefix:"zhr231::sap.suite.ui.generic.template.ListReport.view.ListReport::ZC_HR231_Emergency_Role--",onInit:function(){window._main_table=this.getView().byId(this._prefix+"responsiveTable");const e=this.getView().byId(this._prefix+"listReportFilter");e.setLiveMode(true);e.setShowClearOnFB(true);window._main_table.attachItemPress(function(e){const t=e.getParameters().listItem.getBindingContext().getObject();if(window._objectPage){const e=[];for(bind of window._main_table.getItems())e.push(bind.getBindingContext().getObject());window._objectPage.setCurrentPerson(e,t.pernr,t.begda)}})},onAfterRendering:function(e){this._setMessageParser();this._initReportMenu();this._initCreateDialog()},_setMessageParser:function(){const e=this.getView();const t=e.getModel();sap.ui.require(["zhr231/ext/controller/MessageParser"],function(e){const i=new e(t.sServiceUrl,t.oMetadata,!!t.bPersistTechnicalMessages);t.setMessageParser(i)})},_initReportMenu:function(){const e=this;const t=e.getView();const i=e._prefix+"report-xlsx";if(t.byId(i))return;const n={id:i,text:"Report",icon:"sap-icon://excel-attachment",press:function(){const i=t.byId(e._prefix+"responsiveTable");const n=i.getBinding("items").sFilterParams;if(!n||n.indexOf("begda")===-1){sap.m.MessageToast.show('Please specify filter with "Start date"',{duration:3500});$(".sapMMessageToast").css("background","#cc1919");return}const s=document.location.origin+"/sap/opu/odata/sap/ZC_HR231_EMERGENCY_ROLE_CDS/ZC_HR231_Emergency_Role(pernr='00000000',begda=datetime'2000-01-01T00%3A00%3A00',endda=datetime'2000-01-01T00%3A00%3A00',eid='00')/$value?"+n;window.open(s)}};const s=t.byId(this._prefix+"listReport-btnExcelExport");if(s)s.getMenu().addItem(new sap.m.MenuItem(n));else t.byId(e._prefix+"template::ListReport::TableToolbar").addContent(new sap.m.Button(n))},onInitSmartFilterBarExtension:function(e){const t=this;const i=e.getSource();const n=i.getFilterData();n.begda={ranges:[{exclude:false,operation:"BT",keyField:"begda",value1:new Date((new Date).getFullYear(),0,1),value2:new Date}]};i.setFilterData(n);this.getView().byId(this._prefix+"template:::ListReportPage:::DynamicPageTitle").setVisible(false)},_initCreateDialog:function(){const e=this;const t=e.getView();t.byId(e._prefix+"addEntry").attachPress(function(){const i=t.byId(e._prefix+"CreateWithDialog");if(i&&!i.mEventRegistry.afterOpen)i.attachAfterOpen(function(){i.setContentWidth("25em");const e=sap.ui.getCore().byId;e("__form0").setTitle("Create Emergency Team Duty")})})}});
},
	"zhr231/ext/controller/MessageParser.js":function(){sap.ui.define(["sap/ui/model/odata/ODataMessageParser"],function(s){"use strict";return s.extend("zhr231.ext.controller.MessageParser",{parse:function(e,t,a,r,o){var n=this;s.prototype.parse.apply(n,arguments);if(e.statusCode<400||e.statusCode>=600)return;const i={request:t,response:e,url:t.requestUri};const p=this._parseBody(e,i);const u=[];const c=[];for(let s of p){if(s.message.indexOf("An exception was raised")===-1)u.push(s.message);c.push(s.type)}sap.m.MessageToast.show(u.join("\n"),{duration:3500});if(c.indexOf("Error")>=0)$(".sapMMessageToast").css("background","#cc1919")}})});
},
	"zhr231/ext/controller/ObjectPageExtension.controller.js":function(){sap.ui.controller("zhr231.ext.controller.ObjectPageExtension",{_prefix:"zhr231::sap.suite.ui.generic.template.ObjectPage.view.Details::ZC_HR231_Emergency_Role--",_data:{title:"Team Calendar",startDate:new Date,viewKey:"Week",supportedAppointmentItems:[],team:[],selector:[]},onInit:function(){window._objectPage=this;this._oModel=new sap.ui.model.json.JSONModel;this._oModel.setData(this._data);this._oCalendarContainer=this.byId(this._prefix+"TeamContainer");this._mCalendars={};this._sCalendarDisplayed="";this._sSelectedView=this._data.viewKey;this._loadCalendar("PlanningCalendar")},_refreshCalendar:function(){this._oModel.setData(this._data)},_loadCalendar:function(e){const t=this;var n=this.getView();if(!this._mCalendars[e]){this._mCalendars[e]=sap.ui.core.Fragment.load({id:n.getId(),name:"zhr231.ext.fragment."+e,controller:this}).then(function(e){return e}.bind(this))}this._mCalendars[e].then(function(n){n.setModel(t._oModel,"calendar");this._displayCalendar(e,n)}.bind(this))},_hideCalendar:function(){if(this._sCalendarDisplayed===""){return Promise.resolve()}return this._mCalendars[this._sCalendarDisplayed].then(function(e){this._oCalendarContainer.removeContent(e)}.bind(this))},_displayCalendar:function(e,t){this._hideCalendar().then(function(){this._oCalendarContainer.addContent(t);this._sCalendarDisplayed=e;var n=t.getItems()[0];var a=this.byId(e+"TeamSelector");a.setSelectedKey(this._sSelectedMember);if(isNaN(this._sSelectedMember)){n.setViewKey("Week");n.bindElement({path:"/team",model:"calendar"})}else{n.setSelectedView(n.getViewByKey("OneMonth"));n.bindElement({path:"/team/"+this._sSelectedMember,model:"calendar"})}}.bind(this))},setCurrentPerson:function(e,t,n){this._loadCalendar("PlanningCalendar");const a={};for(objPerson of e){const e=a[objPerson.pernr]||{personID:objPerson.pernr,pic:objPerson.__metadata.media_src.replace("eid='"+objPerson.eid+"'","eid='98'")+"?sap-client=300",name:objPerson.ename,role:objPerson.plans_txt,appointments:[],headers:[]};e.appointments.push({start:this.getBaseDate(objPerson.begda),end:this.getBaseDate(objPerson.endda,true),title:objPerson.role_text,info:"From "+objPerson.begda.toLocaleDateString("ru-RU")+" to "+objPerson.endda.toLocaleDateString("ru-RU"),type:"Type"+objPerson.eid});a[objPerson.pernr]=e}const r=a[t];if(r){delete a[t];this._data.team=Object.values(a);this._data.team.unshift(r)}this._data.selector=[];this._data.selector.push({index:"Team",text:"Team"});for(index=0;index<this._data.team.length;index++){this._data.selector.push({index:index,text:this._data.team[index].name})}if(n)this._data.startDate=this.getBaseDate(this.getMonday(n));this._refreshCalendar()},onAfterRendering:function(){const e=this;if(!window._main_table)this.getView().getModel().read("/ZC_HR231_Emergency_Role",{urlParameters:{$select:"pernr,role_text,begda,endda,ename,role_group,eid",$filter:"(begda ge datetime'"+e.getDateIso(new Date((new Date).getFullYear(),0,1))+"T00:00:00' and begda le datetime'"+e.getDateIso(new Date)+"T00:00:00')"},success:function(t){e.setCurrentPerson(t.results,e._getFromUrl("pernr='",8),new Date(e._getFromUrl("begda=datetime'",10)))},error:function(e){console.log(e)}});const t=e._data.supportedAppointmentItems;if(t.length===0)this.getView().getModel().read("/ZC_HR231_EmergeRoleText",{urlParameters:{$select:"eid,text"},success:function(n){for(item of n.results)t.push({type:"Type"+item.eid,text:item.text+" ("+item.eid+")"});e._refreshCalendar()},error:function(e){console.log(e)}})},getDateIso:function(e){return e.toISOString().split("T")[0]},viewChangeHandler:function(e){return;var t=e.getSource();if(isNaN(this._sSelectedMember)){this._sSelectedView=t.getViewKey()}else{this._sSelectedView=oCore.byId(t.getSelectedView()).getKey()}t.setStartDate(this._data.startDate)},openLegend:function(e){var t=this,n=e.getSource(),a=t.getView();if(!this._pLegendPopover){this._pLegendPopover=sap.ui.core.Fragment.load({id:a.getId(),name:"zhr231.ext.fragment.Legend",controller:this}).then(function(e){e.setModel(t._oModel,"calendar");a.addDependent(e);return e})}this._pLegendPopover.then(function(e){if(e.isOpen()){e.close()}else{e.openBy(n)}})},selectChangeHandler:function(e){this._sSelectedMember=e.getParameter("selectedItem").getKey();this._loadCalendar(isNaN(this._sSelectedMember)?"PlanningCalendar":"SinglePlanningCalendar")},rowSelectionHandler:function(e){var t=e.getParameter("rows")[0],n=t.getId();this._sSelectedMember=n.substr(n.lastIndexOf("-")+1);t.setSelected(false);this._loadCalendar("SinglePlanningCalendar")},startDateChangeHandler:function(e){this._data.startDate=new Date(e.getSource().getStartDate())},_getFromUrl:function(e,t){const n=window.location.href.indexOf(e);if(n===-1)return null;return window.location.href.substr(n+e.length,t)},getMonday:function(e){e=new Date(e);var t=e.getDay(),n=e.getDate()-t+(t==0?-6:1);return new Date(e.setDate(n))},getBaseDate:function(e,t){result=new Date(e.getTime()+e.getTimezoneOffset()*6e4);if(t)result.setDate(result.getDate()+1);return result}});
},
	"zhr231/ext/fragment/CustomFilter.fragment.xml":'<core:FragmentDefinition xmlns="sap.m" xmlns:smartfilterbar="sap.ui.comp.smartfilterbar" xmlns:core="sap.ui.core"><smartfilterbar:ControlConfiguration key="visitorFilter" label="Visitors only" visibleInAdvancedArea="true" groupId="_BASIC"><smartfilterbar:customControl></smartfilterbar:customControl></smartfilterbar:ControlConfiguration></core:FragmentDefinition>\r\n',
	"zhr231/ext/fragment/Legend.fragment.xml":'<core:FragmentDefinition\n\t\txmlns="sap.m"\n\t\txmlns:core="sap.ui.core"\n\t\txmlns:u="sap.ui.unified"><ResponsivePopover\n\t\t\ttitle="Calendar Legend"\n\t\t\tplacement="Bottom"\n\t\t\tshowHeader="false"><PlanningCalendarLegend\n\t\t\t\tappointmentItems="{\n\t\t\t\t\tpath : \'calendar>/supportedAppointmentItems\',\n\t\t\t\t\ttemplateShareable: true\n\t\t\t\t}"><appointmentItems><u:CalendarLegendItem\n\t\t\t\t\ttext="{calendar>text}"\n\t\t\t\t\ttype="{calendar>type}"\n\t\t\t\t\ttooltip="{calendar>text}" /></appointmentItems></PlanningCalendarLegend></ResponsivePopover></core:FragmentDefinition>',
	"zhr231/ext/fragment/PlanningCalendar.fragment.xml":'<core:FragmentDefinition\n\txmlns="sap.m"\n\txmlns:unified="sap.ui.unified"\n\txmlns:core="sap.ui.core"><VBox><PlanningCalendar\n            id="PlanningCalendar"            \n            viewKey="{calendar>/viewKey}"\n            rows="{calendar>/team}"\n            appointmentsVisualization="Filled"\n            showEmptyIntervalHeaders="false"\n            showWeekNumbers="true"\n            rowSelectionChange=".rowSelectionHandler"\n            startDateChange=".startDateChangeHandler"\n            viewChange=".viewChangeHandler"\n            startDate="{calendar>/startDate}"\n        ><toolbarContent><Select id="PlanningCalendarTeamSelector" change=".selectChangeHandler"  items="{ path: \'calendar>/selector\' }"><core:Item key="{calendar>index}" text="{calendar>text}" /></Select><Button id="PlanningCalendarLegendButton" icon="sap-icon://legend" press=".openLegend" tooltip="Open Planning Calendar legend" ariaHasPopup="Dialog" /></toolbarContent><views><PlanningCalendarView key="Week" intervalType="Week" description="Week" intervalsS="1" intervalsM="2" intervalsL="7"/><PlanningCalendarView key="OneMonth" intervalType="OneMonth" description="Month" /></views><rows><PlanningCalendarRow icon="{calendar>pic}"\n\t\t\t\t\t\t\t\t\t title="{calendar>name}"\n\t\t\t\t\t\t\t\t\t text="{calendar>role}"\n\t\t\t\t\t\t\t\t\t appointments="{path : \'calendar>appointments\', templateShareable: true}"\n\t\t\t\t\t\t\t\t\t ><appointments><unified:CalendarAppointment\n                            startDate="{calendar>start}"\n                            endDate="{calendar>end}"                            \n                            title="{calendar>title}"\n                            text="{calendar>info}"\n                            type="{calendar>type}"\n                        /></appointments></PlanningCalendarRow></rows></PlanningCalendar></VBox></core:FragmentDefinition>',
	"zhr231/ext/fragment/SinglePlanningCalendar.fragment.xml":'<core:FragmentDefinition\n\txmlns="sap.m"\n\txmlns:unified="sap.ui.unified"\n\txmlns:core="sap.ui.core"><VBox><SinglePlanningCalendar\n\t\t\tid="SinglePlanningCalendar"\n\t\t\tstartDateChange=".startDateChangeHandler"\n\t\t\tviewChange=".viewChangeHandler"\n\t\t\tappointments="{calendar>appointments}"\n\t\t\tstartDate="{calendar>/startDate}"\n\t\t\t><actions><Select id="SinglePlanningCalendarTeamSelector" change=".selectChangeHandler"  items="{ path: \'calendar>/selector\' }"><core:Item key="{calendar>index}" text="{calendar>text}" /></Select><Button\n\t\t\t\t\tid="SinglePlanningCalendarLegendButton"\n\t\t\t\t\ticon="sap-icon://legend"\n\t\t\t\t\tpress=".openLegend"\n\t\t\t\t\ttooltip="Open Single Planning Calendar legend"\n\t\t\t\t\tariaHasPopup="Dialog"/></actions><views><SinglePlanningCalendarMonthView\n\t\t\t\t\tkey="OneMonth"\n\t\t\t\t\ttitle="Month"/></views><appointments><unified:CalendarAppointment\n\t\t\t\t\tstartDate="{calendar>start}"\n\t\t\t\t\tendDate="{calendar>end}"\n\t\t\t\t\ttitle="{calendar>title} {calendar>info}"\t\t\t\t\t\n\t\t\t\t\ttext="{calendar>info}"\n\t\t\t\t\ttype="{calendar>type}"></unified:CalendarAppointment></appointments></SinglePlanningCalendar></VBox></core:FragmentDefinition>',
	"zhr231/ext/fragment/TeamContainer.fragment.xml":'<core:FragmentDefinition  xmlns="sap.m"\n                          xmlns:l="sap.ui.layout"\n\t\t\t\t\t\t  xmlns:unified="sap.ui.unified"\n\t\t\t\t\t\t  xmlns:core="sap.ui.core"\n\t ><l:VerticalLayout width="100%" id="TeamContainer"></l:VerticalLayout></core:FragmentDefinition>\n',
	"zhr231/i18n/i18n.properties":'# This is the resource bundle for zhr231\n\n#Texts for manifest.json\n\n#XTIT: Application name\nappTitle=Emergency Team Duty\n\n#YDES: Application description\nappDescription=Emergency Team Duty',
	"zhr231/manifest.json":'{"_version":"1.42.0","sap.app":{"id":"zhr231","type":"application","i18n":"i18n/i18n.properties","applicationVersion":{"version":"0.0.1"},"title":"{{appTitle}}","description":"{{appDescription}}","resources":"resources.json","sourceTemplate":{"id":"@sap/generator-fiori:lrop","version":"1.8.4","toolsId":"7e3a49ee-07e1-4c3c-86c5-de95dbc2e659"},"dataSources":{"mainService":{"uri":"/sap/opu/odata/sap/ZC_HR231_EMERGENCY_ROLE_CDS/","type":"OData","settings":{"annotations":["ZC_HR231_EMERGENCY_ROLE_CDS_VAN","annotation"],"localUri":"localService/metadata.xml","odataVersion":"2.0"}},"ZC_HR231_EMERGENCY_ROLE_CDS_VAN":{"uri":"/sap/opu/odata/IWFND/CATALOGSERVICE;v=2/Annotations(TechnicalName=\'ZC_HR231_EMERGENCY_ROLE_CDS_VAN\',Version=\'0001\')/$value/","type":"ODataAnnotation","settings":{"localUri":"localService/ZC_HR231_EMERGENCY_ROLE_CDS_VAN.xml"}},"annotation":{"type":"ODataAnnotation","uri":"annotations/annotation.xml","settings":{"localUri":"annotations/annotation.xml"}}}},"sap.ui":{"technology":"UI5","icons":{"icon":"","favIcon":"","phone":"","phone@2":"","tablet":"","tablet@2":""},"deviceTypes":{"desktop":true,"tablet":true,"phone":true}},"sap.ui5":{"flexEnabled":true,"dependencies":{"minUI5Version":"1.102.0","libs":{"sap.m":{},"sap.ui.core":{},"sap.ushell":{},"sap.f":{},"sap.ui.comp":{},"sap.ui.generic.app":{},"sap.suite.ui.generic.template":{}}},"contentDensities":{"compact":true,"cozy":true},"models":{"i18n":{"type":"sap.ui.model.resource.ResourceModel","settings":{"bundleName":"zhr231.i18n.i18n"}},"":{"dataSource":"mainService","preload":true,"settings":{"defaultBindingMode":"TwoWay","defaultCountMode":"Inline","refreshAfterChange":false,"metadataUrlParams":{"sap-value-list":"none"}}},"@i18n":{"type":"sap.ui.model.resource.ResourceModel","uri":"i18n/i18n.properties"}},"resources":{"css":[]},"routing":{"config":{},"routes":[],"targets":{}},"extends":{"extensions":{"sap.ui.controllerExtensions":{"sap.suite.ui.generic.template.ListReport.view.ListReport":{"controllerName":"zhr231.ext.controller.ListReportExtension"},"sap.suite.ui.generic.template.ObjectPage.view.Details":{"controllerName":"zhr231.ext.controller.ObjectPageExtension","sap.ui.generic.app":{}}},"sap.ui.viewExtensions":{"sap.suite.ui.generic.template.ListReport.view.ListReport":{"SmartFilterBarControlConfigurationExtension|ZC_HR231_Emergency_Role":{"className":"sap.ui.core.Fragment","fragmentName":"zhr231.ext.fragment.CustomFilter","type":"XML"}},"sap.suite.ui.generic.template.ObjectPage.view.Details":{"AfterFacet|ZC_HR231_Emergency_Role|GeneralInfo":{"className":"sap.ui.core.Fragment","fragmentName":"zhr231.ext.fragment.TeamContainer","type":"XML","sap.ui.generic.app":{"title":"Team calendar"}}}}}}},"sap.ui.generic.app":{"_version":"1.3.0","settings":{"forceGlobalRefresh":false,"objectPageHeaderType":"Dynamic","considerAnalyticalParameters":true,"showDraftToggle":false,"flexibleColumnLayout":{"defaultTwoColumnLayoutType":"TwoColumnsMidExpanded"}},"pages":{"ListReport|ZC_HR231_Emergency_Role":{"entitySet":"ZC_HR231_Emergency_Role","component":{"name":"sap.suite.ui.generic.template.ListReport","list":true,"settings":{"condensedTableLayout":true,"smartVariantManagement":true,"enableTableFilterInPageVariant":true,"filterSettings":{"dateSettings":{"useDateRange":true}},"dataLoadSettings":{"loadDataOnAppLaunch":"always"},"tableSettings":{"createWithParameterDialog":{"fields":{"pernr":{"path":"pernr"},"begda":{"path":"begda"},"endda":{"path":"endda"}},"eid":{"path":"eid","comment":"Use ZDHR231_EMR_DEF table"}}}}},"pages":{"ObjectPage|ZC_HR231_Emergency_Role":{"entitySet":"ZC_HR231_Emergency_Role","defaultLayoutTypeIfExternalNavigation":"MidColumnFullScreen","component":{"name":"sap.suite.ui.generic.template.ObjectPage"}},"pages":{"ObjectPage|to_Text":{"navigationProperty":"to_Text","entitySet":"ZC_HR231_EmergeRoleText","defaultLayoutTypeIfExternalNavigation":"MidColumnFullScreen","component":{"name":"sap.suite.ui.generic.template.ObjectPage"}}}}}}},"sap.fiori":{"registrationIds":[],"archeType":"transactional"}}',
	"zhr231/utils/locate-reuse-libs.js":'(function(e){var t=function(e,t){var n=["sap.apf","sap.base","sap.chart","sap.collaboration","sap.f","sap.fe","sap.fileviewer","sap.gantt","sap.landvisz","sap.m","sap.ndc","sap.ovp","sap.rules","sap.suite","sap.tnt","sap.ui","sap.uiext","sap.ushell","sap.uxap","sap.viz","sap.webanalytics","sap.zen"];Object.keys(e).forEach(function(e){if(!n.some(function(t){return e===t||e.startsWith(t+".")})){if(t.length>0){t=t+","+e}else{t=e}}});return t};var n=function(e){var n="";if(e){if(e["sap.ui5"]&&e["sap.ui5"].dependencies){if(e["sap.ui5"].dependencies.libs){n=t(e["sap.ui5"].dependencies.libs,n)}if(e["sap.ui5"].dependencies.components){n=t(e["sap.ui5"].dependencies.components,n)}}if(e["sap.ui5"]&&e["sap.ui5"].componentUsages){n=t(e["sap.ui5"].componentUsages,n)}}return n};var r=function(e){var t=e;return new Promise(function(r,a){$.ajax(t).done(function(e){r(n(e))}).fail(function(){a(new Error("Could not fetch manifest at \'"+e))})})};var a=function(e){if(e){Object.keys(e).forEach(function(t){var n=e[t];if(n&&n.dependencies){n.dependencies.forEach(function(e){if(e.url&&e.url.length>0&&e.type==="UI5LIB"){jQuery.sap.log.info("Registering Library "+e.componentId+" from server "+e.url);jQuery.sap.registerModulePath(e.componentId,e.url)}})}})}};e.registerComponentDependencyPaths=function(e){return r(e).then(function(e){if(e&&e.length>0){var t="/sap/bc/ui2/app_index/ui5_app_info?id="+e;var n=jQuery.sap.getUriParameters().get("sap-client");if(n&&n.length===3){t=t+"&sap-client="+n}return $.ajax(t).done(a)}})}})(sap);var scripts=document.getElementsByTagName("script");var currentScript=document.getElementById("locate-reuse-libs");if(!currentScript){currentScript=document.currentScript}var manifestUri=currentScript.getAttribute("data-sap-ui-manifest-uri");var componentName=currentScript.getAttribute("data-sap-ui-componentName");var useMockserver=currentScript.getAttribute("data-sap-ui-use-mockserver");var bundleResources=function(){jQuery.sap.require("jquery.sap.resources");var e=sap.ui.getCore().getConfiguration().getLanguage();var t=jQuery.sap.resources({url:"i18n/i18n.properties",locale:e});document.title=t.getText("appTitle")};sap.registerComponentDependencyPaths(manifestUri).catch(function(e){jQuery.sap.log.error(e)}).finally(function(){sap.ui.getCore().attachInit(bundleResources);if(componentName&&componentName.length>0){if(useMockserver&&useMockserver==="true"){sap.ui.getCore().attachInit(function(){sap.ui.require([componentName.replace(/\\./g,"/")+"/localService/mockserver"],function(e){e.init();sap.ushell.Container.createRenderer().placeAt("content")})})}else{sap.ui.require(["sap/ui/core/ComponentSupport"]);sap.ui.getCore().attachInit(bundleResources)}}else{sap.ui.getCore().attachInit(function(){sap.ushell.Container.createRenderer().placeAt("content")})}});sap.registerComponentDependencyPaths(manifestUri);'
}});