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
        recipient    TYPE adr6-smtp_addr,
        sender       TYPE adr6-smtp_addr,
        body         TYPE string,
      END OF ts_email,
      tt_email TYPE SORTED TABLE OF ts_email WITH UNIQUE KEY emergrole_id,

      BEGIN OF ts_role,
        name           TYPE agr_users-agr_name,
        r_emergrole_id TYPE RANGE OF p9018-emergrole_id,
        upd_defaults   TYPE xsdboolean,
        can_delete     TYPE xsdboolean,
      END OF ts_role,

      BEGIN OF ts_period,
        period    TYPE zss_hr231_ui-period,
        per_count TYPE num2,
      END OF ts_period.

    DATA:
      t_email  TYPE tt_email READ-ONLY,
      t_roles  TYPE STANDARD TABLE OF ts_role   WITH DEFAULT KEY READ-ONLY,
      t_period TYPE STANDARD TABLE OF ts_period WITH DEFAULT KEY READ-ONLY.

    CLASS-METHODS:
      get_instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_hr231_options.

    METHODS:
      check_authorization IMPORTING iv_emergrole_id TYPE p9018-emergrole_id OPTIONAL
                                    iv_upd_defaults TYPE abap_bool          OPTIONAL
                                    iv_can_delete   TYPE abap_bool          OPTIONAL
                          RETURNING VALUE(rv_error) TYPE string,

      send_to IMPORTING is_9018 TYPE p9018
              RAISING   /iwbep/cx_mgw_tech_exception.
  PROTECTED SECTION.

  PRIVATE SECTION.
    CLASS-DATA:
      _instance TYPE REF TO zcl_hr231_options.

    DATA:
      mt_db_roles TYPE STANDARD TABLE OF agr_users-agr_name WITH DEFAULT KEY.

    METHODS:
      init,
      _get_emerge_role_text IMPORTING iv_emergrole_id TYPE p9018-emergrole_id
                            RETURNING VALUE(rv_text)  TYPE string.
ENDCLASS.



CLASS ZCL_HR231_OPTIONS IMPLEMENTATION.


  METHOD check_authorization.
    DATA(lv_emergrole_id_ok) = abap_false.
    DATA(lv_upd_defaults_ok) = abap_false.
    DATA(lv_can_delete_ok)   = abap_false.

    LOOP AT mt_db_roles ASSIGNING FIELD-SYMBOL(<lv_db_role>).
      ASSIGN t_roles[ name = <lv_db_role> ] TO FIELD-SYMBOL(<ls_role>).
      ASSERT sy-subrc = 0.

      IF iv_emergrole_id IN <ls_role>-r_emergrole_id.
        lv_emergrole_id_ok = abap_true.
      ENDIF.

      IF iv_upd_defaults = abap_true AND <ls_role>-upd_defaults = abap_true.
        lv_upd_defaults_ok = abap_true.
      ENDIF.

      IF iv_can_delete = abap_true AND <ls_role>-can_delete = abap_true.
        lv_can_delete_ok = abap_true.
      ENDIF.
    ENDLOOP.

    IF iv_emergrole_id IS NOT INITIAL AND lv_emergrole_id_ok <> abap_true.
      rv_error = |No rights to edit '{ _get_emerge_role_text( iv_emergrole_id ) }'. Please contact HR support team|.
    ENDIF.

    IF iv_upd_defaults IS NOT INITIAL AND lv_upd_defaults_ok <> abap_true.
      rv_error = |No rights to edit defaults. Please contact HR support team|.
    ENDIF.

    IF iv_can_delete IS NOT INITIAL AND lv_can_delete_ok <> abap_true.
      rv_error = |No rights to change & delete old emergency records. Please contact HR support team|.
    ENDIF.
  ENDMETHOD.


  METHOD get_instance.
    IF _instance IS INITIAL.
      _instance = NEW #( ).
      zcl_aqo_option=>create( _instance ).
      _instance->init( ).
    ENDIF.

    ro_instance = _instance.
  ENDMETHOD.


  METHOD init.
    CHECK t_roles[] IS NOT INITIAL.

    SELECT agr_name INTO TABLE @mt_db_roles
    FROM agr_users
    FOR ALL ENTRIES IN @t_roles
    WHERE agr_name EQ @t_roles-name
      AND uname    EQ @sy-uname
      AND from_dat LE @sy-datum
      AND to_dat   GE @sy-datum.
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

          "Line manager
          DATA(lv_line_manager) = zcl_hr_om_utilities=>get_line_manager_for_pernr( iv_pernr = is_9018-pernr ).
          IF lv_line_manager IS NOT INITIAL.
            lr_0105 = CAST p0105( zcl_hr_read=>infty_row( iv_infty = '0105'
                                                          iv_pernr = is_9018-pernr
                                                          iv_begda = lv_datum
                                                          iv_endda = lv_datum
                                                          iv_where = |SUBTY = '0010'| ) ).

            IF lr_0105 IS NOT INITIAL.
              APPEND VALUE #( recipient = cl_cam_address_bcs=>create_internet_address( lr_0105->usrid_long )
                              copy = abap_true ) TO lt_recipient[].
            ENDIF.
          ENDIF.
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


  METHOD _get_emerge_role_text.
    SELECT SINGLE text INTO @rv_text
    FROM zc_hr231_emergeroletext
    WHERE eid = @iv_emergrole_id.
  ENDMETHOD.
ENDCLASS.
