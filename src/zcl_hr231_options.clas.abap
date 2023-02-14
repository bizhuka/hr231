CLASS zcl_hr231_options DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE

  GLOBAL FRIENDS zcl_aqo_option .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ts_email,
        emergrole_id TYPE zdhr231_emergrol-emergrole_id,
        subject      TYPE adr6-smtp_addr,
        sender       TYPE adr6-smtp_addr,
        body         TYPE string,
      END OF ts_email,
      tt_email TYPE SORTED TABLE OF ts_email WITH UNIQUE KEY emergrole_id.

    DATA:
      t_email TYPE tt_email READ-ONLY.

    CLASS-METHODS:
      get_instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_hr231_options.

    METHODS:
      send_to IMPORTING is_9018 TYPE p9018
              RAISING   /iwbep/cx_mgw_tech_exception.

  PROTECTED SECTION.

  PRIVATE SECTION.
    CLASS-DATA:
      _instance TYPE REF TO zcl_hr231_options.
ENDCLASS.



CLASS ZCL_HR231_OPTIONS IMPLEMENTATION.


  METHOD get_instance.
    IF _instance IS INITIAL.
      _instance = NEW #( ).
      zcl_aqo_option=>create( _instance ).
    ENDIF.

    ro_instance = _instance.
  ENDMETHOD.


  METHOD send_to.
    ASSIGN t_email[ emergrole_id = is_9018-emergrole_id ] TO FIELD-SYMBOL(<ls_email>).
    CHECK sy-subrc = 0.

    DATA(lv_datum) = sy-datum.
    DATA(ls_0001) = CAST p0001( zcl_hr_read=>infty_row( iv_infty = '0001'
                                                        iv_pernr = is_9018-pernr
                                                        iv_begda = lv_datum
                                                        iv_endda = lv_datum
                                                        is_default = VALUE p0001( ename = is_9018-pernr ) ) )->*.

    DATA(lt_recipient) = VALUE zcl_xtt=>tt_recipients_bcs( ).
    DATA(lr_0105) = CAST p0105( zcl_hr_read=>infty_row( iv_infty = '0105'
                                                        iv_pernr = is_9018-pernr
                                                        iv_begda = lv_datum
                                                        iv_endda = lv_datum
                                                        iv_where = |SUBTY = '0010'| ) ).
    TRY.
        IF lr_0105 IS NOT INITIAL.
          APPEND VALUE #( recipient  = cl_cam_address_bcs=>create_internet_address( lr_0105->usrid_long ) ) TO lt_recipient[].
        ELSE.
          " Send to creator in SAP
          DATA(lv_subject_remainder) = | No email found for { ls_0001-ename }|.
          APPEND VALUE #( recipient  = cl_sapuser_bcs=>create( sy-uname ) )                                 TO lt_recipient[].
        ENDIF.

        DATA(lo_sender) = cl_cam_address_bcs=>create_internet_address( <ls_email>-sender ).
      CATCH cx_bcs INTO DATA(lo_error).
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
          EXPORTING
            previous = lo_error.
    ENDTRY.

**********************************************************************
    TYPES:
      BEGIN OF ts_body_root,
        ename TYPE p0001-ename,
        begda TYPE p9018-begda,
        endda TYPE p9018-begda,
      END OF ts_body_root.

    NEW zcl_xtt_html(  iv_as_email_body = abap_true
                       io_file   = NEW zcl_xtt_file_raw(
                       iv_name   = |body.html|
                       iv_string = replace( val  = <ls_email>-body
                                            sub  = cl_abap_char_utilities=>cr_lf
                                            with = '<br/>'
                                            occ  = 0 ) )
                    )->merge( VALUE ts_body_root( ename = ls_0001-ename
                                                  begda = is_9018-begda
                                                  endda = is_9018-endda )
                    )->send( iv_subject        = <ls_email>-subject && lv_subject_remainder
                             it_recipients_bcs = lt_recipient
                             iv_body           = ''  " Use own body
                             iv_commit         = abap_true
                             io_sender         = lo_sender ).

  ENDMETHOD.
ENDCLASS.
