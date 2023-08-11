
sap.ui.define([
    "sap/m/MessageToast",
], function (MessageToast) {
    "use strict";

    return {

        getDateIso: function (date) {
            const okDate = new Date(date.getTime() - (date.getTimezoneOffset() * 60 * 1000))
            return okDate.toISOString().split('T')[0]
        },

        getTextDate: function (d) {
            return d.toLocaleDateString('ru-RU')
        },

        get_middle: function (d1, d2) {
            return new Date((d1.getTime() + d2.getTime()) / 2)
        },

        getFirstDayOfMonth: function (date) {
            return new Date(date.getFullYear(), date.getMonth(), 1)
        },

        getLastDayOfMonth: function (date) {
            return new Date(date.getFullYear(), date.getMonth() + 1, 0)
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
            d.setDate(diff)
            this.set_noon(d)
            return new Date()
        },

        set_noon: function (date) {
            date.setHours(12, 0, 0, 0)
            return date
        },

        addDays: function (date, shift) {
            const result = new Date(date)
            result.setDate(result.getDate() + shift)
            this.set_noon(result)
            return result
        },

        showMessage: function (message, error) {
            MessageToast.show(message, { duration: 3500 })
            if (error)
                $(".sapMMessageToast").css("background", "#cc1919")
        },

        send_request: function (theUrl, callback) {
            var xmlHttp = new XMLHttpRequest()

            if (callback)
                xmlHttp.onreadystatechange = function () {
                    if (xmlHttp.readyState == 4 && xmlHttp.status == 200)
                        callback(xmlHttp.responseText)
                }
            xmlHttp.open("GET", theUrl, true) // true for asynchronous 
            xmlHttp.send(null)
        },

        createAppointment: function (objPerson) {
            const app = {                
                pernr: objPerson.pernr,
                ename: objPerson.ename,
                pic: this.get_avatar_url(objPerson.pernr),                
            }
            this.set_main_fields(app, objPerson)
            return app
        },

        set_main_fields: function (item, src) {
            item.type =  'Type' + src.eid
            item.role_text =  src.role_text,
            item.color = src.color.toLowerCase()
            
            item.notes = src.notes
            item.start = this.getFixedDate(src.begda)

            const endda = this.getFixedDate(src.endda, true)
            item.end1 = endda.low
            item.end2 = endda.high

            item.tooltip = "From " + this.getTextDate(src.begda) + " to " + this.getTextDate(src.endda)
            if (item.notes)
                item.tooltip += (" - " + item.notes)
        },

        get_avatar_url: function (pernr) {
            // __metadata.media_src  objPerson.photo_path +
            return document.location.origin + "/sap/opu/odata/sap/ZC_PY000_REPORT_CDS/ZC_PY000_PernrPhoto(pernr='" + pernr +
                "')/$value?sap-client=300&$filter=" + encodeURIComponent('img_size eq 64')
        },


    };
});

