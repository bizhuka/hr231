sap.ui.define([
	'sap/m/SinglePlanningCalendarRenderer',
	'sap/ui/core/InvisibleText',
	'sap/ui/core/Core',
	'sap/ui/unified/library'
],

	function (SinglePlanningCalendarRenderer, InvisibleText, Core, unifiedLibrary) {
		"use strict";

		var SPCalendarRenderer = { apiVersion: 2 }

		// shortcut for sap.ui.unified.CalendarDayType
		var CalendarDayType = unifiedLibrary.CalendarDayType;

		SPCalendarRenderer.render = function (oRm, oCalendar) {
			var oHeader = oCalendar._getHeader(),
				oGrid = oCalendar._getCurrentGrid();

			oRm.openStart("div", oCalendar);
			oRm.accessibilityState({
				role: "region",
				roledescription: oCalendar._oRB.getText("SPC_CONTROL_NAME"),
				labelledby: {
					value: oHeader.getId() + "-Title " + oGrid.getId() + "-nowMarkerText",
					append: true
				}
			});
			oRm.class("sapMSinglePC");
			oRm.openEnd();

			// Height 3rem & Text
			oGrid.getRenderer().renderAppointment = SPCalendarRenderer._ownRenderAppointment

			oRm.renderControl(oHeader);
			oRm.renderControl(oGrid);

			oRm.close("div");
		};


		SPCalendarRenderer._ownRenderAppointment = function (oRm, oControl, app, iColumn, oDensitySizes, iRow) {
			var oAppointment = app.data,
				iWidth = app.width,
				iLevel = app.level,
				iColumns = oControl._getColumns(),
				sTooltip = oAppointment.getTooltip_AsString(),
				sType = oAppointment.getType(),
				sColor = oAppointment.getColor(),
				sTitle = oAppointment.getTitle(),
				sText = oAppointment.getText(),
				sIcon = oAppointment.getIcon(),
				sId = oAppointment.getId(),
				bDraggable = oAppointment.getParent().getEnableAppointmentsDragAndDrop(),
				mAccProps = {
					role: "listitem",
					labelledby: {
						value: InvisibleText.getStaticId("sap.ui.unified", "APPOINTMENT"),
						append: true
					},
					// Prevents aria-selected from being added on the appointment
					selected: null
				},
				// aAriaLabels = oControl.getAriaLabelledBy(),
				iRight = iColumns - iColumn - iWidth,
				bIsRTL = Core.getConfiguration().getRTL(),
				aClasses,
				iBorderThickness = Core.getConfiguration().getTheme().indexOf("_hc") ? 2 : 1;

			iRight = iRight < 0 ? 0 : iRight;

			if (sTitle) {
				mAccProps["labelledby"].value = mAccProps["labelledby"].value + " " + sId + "-Title";
			}

			// Put start/end information after the title
			mAccProps["labelledby"].value = mAccProps["labelledby"].value + " " + sId + "-Descr";

			if (sText) {
				mAccProps["labelledby"].value = mAccProps["labelledby"].value + " " + sId + "-Text";
			}

			if (oAppointment.getTentative()) {
				mAccProps["labelledby"].value = mAccProps["labelledby"].value + " " + InvisibleText.getStaticId("sap.ui.unified", "APPOINTMENT_TENTATIVE");
			}

			if (oAppointment.getSelected()) {
				mAccProps["labelledby"].value = mAccProps["labelledby"].value + " " + InvisibleText.getStaticId("sap.ui.unified", "APPOINTMENT_SELECTED");
			}

			oRm.openStart("div", oAppointment.getId() + "-" + iColumn + "_" + iRow);
			oRm.attr("draggable", bDraggable);
			oRm.attr("data-sap-ui-draggable", bDraggable);
			oRm.attr("data-sap-ui-related", oAppointment.getId());
			oRm.attr("data-sap-level", iLevel);
			oRm.attr("data-sap-width", iWidth);
			oRm.attr("tabindex", 0);

			if (sTooltip) {
				oRm.attr("title", sTooltip);
			}
			oRm.accessibilityState(oAppointment, mAccProps);
			oRm.class("sapMSinglePCAppointmentWrap");
			oRm.class("sapUiCalendarRowApps"); // TODO: when refactor the CSS of appointments maybe we won't need this class
			if (!sColor && sType !== CalendarDayType.None) {
				oRm.class("sapUiCalendarApp" + sType);
			}
			if (sColor) {
				if (Core.getConfiguration().getRTL()) {
					oRm.style("border-right-color", sColor);
				} else {
					oRm.style("border-left-color", sColor);
				}
			}
			oRm.style(bIsRTL ? "right" : "left", "calc(" + (iColumn * 100) / iColumns + "% + " + iBorderThickness + "px)");
			oRm.style(bIsRTL ? "left" : "right", "calc(" + (iRight * 100) / iColumns + "% + " + iBorderThickness + "px)");
			oRm.style("top", (iLevel * oDensitySizes.appHeight + oDensitySizes.cellHeaderHeight) + "rem");
			oRm.openEnd();

			oRm.openStart("div");
			oRm.class("sapUiCalendarApp");
			oRm.style("height", "3rem");
			//oRm.class("sapUiCalendarAppHeight2");

			if (oAppointment.getSelected()) {
				oRm.class("sapUiCalendarAppSel");
			}

			if (oAppointment.getTentative()) {
				oRm.class("sapUiCalendarAppTent");
			}

			 if (sIcon) {
				oRm.class("sapUiCalendarAppWithIcon");
			 }

			oRm.openEnd(); // div element

			// extra content DIV to make some styling possible
			oRm.openStart("div");
			oRm.class("sapUiCalendarAppCont");

			if (sColor) {
				oRm.style("background-color", oAppointment._getCSSColorForBackground(sColor));
			}

			oRm.openEnd(); // div element

			if (app.hasPrevious < 0) {
				aClasses = ["sapUiCalendarAppArrowIconLeft", "sapUiCalendarAppArrowIcon"];
				oRm.icon("sap-icon://arrow-left", aClasses, { title: null, role: "img" });
			}

			if (sIcon) {
				aClasses = ["sapUiCalendarAppIcon"];
				var mAttributes = {};

				mAttributes["id"] = sId + "-Icon";
				mAttributes["title"] = null;
				mAttributes["role"] = "img";
				oRm.icon(sIcon, aClasses, mAttributes);
			}

			oRm.openStart("div");
			oRm.class("sapUiCalendarAppTitleWrapper");
			oRm.openEnd();

			if (sTitle) {
				oRm.openStart("span", sId + "-Title");
				oRm.class("sapUiCalendarAppTitle");
				oRm.openEnd(); // span element
				oRm.text(sTitle, true);
				oRm.close("span");
			}

			if (sText) {
				oRm.openStart("span", sId + "-Text");
				oRm.class("sapUiCalendarAppText");
				oRm.openEnd(); // span element
				oRm.text(sText, false);
				oRm.close("span");
			}

			oRm.close("div");

			if (app.hasNext < 0) {
				aClasses = ["sapUiCalendarAppArrowIconRight", "sapUiCalendarAppArrowIcon"];
				oRm.icon("sap-icon://arrow-right", aClasses, { title: null, role: "img" });
			}

			oRm.openStart("span", sId + "-Descr");
			oRm.class("sapUiInvisibleText");
			oRm.openEnd(); // span element
			oRm.text(oControl._getAppointmentAnnouncementInfo(oAppointment));
			oRm.close("span");

			oRm.close("div");

			oRm.close("div");
			oRm.close("div");
		};

		return SPCalendarRenderer

	}, /* bExport= */ true);