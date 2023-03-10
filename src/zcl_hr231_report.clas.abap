CLASS zcl_hr231_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES: zif_sadl_exit,
      zif_sadl_stream_runtime,
      zif_sadl_read_runtime,
      zif_sadl_delete_runtime,
      zif_sadl_mpc.

    METHODS:
      check_authorization RETURNING VALUE(rv_error) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF ms_const,
        photo_normal_eid TYPE zdhr231_emergrol-emergrole_id VALUE 99,
        photo_icon_eid   TYPE zdhr231_emergrol-emergrole_id VALUE 98,
      END OF ms_const.

    TYPES:
      tt_day TYPE STANDARD TABLE OF d WITH DEFAULT KEY,

      BEGIN OF ts_sheet,
        name TYPE string,
        days TYPE tt_day,
        t    TYPE STANDARD TABLE OF zc_hr231_emergency_role WITH DEFAULT KEY,
      END OF ts_sheet,
      tt_sheet TYPE STANDARD TABLE OF ts_sheet WITH DEFAULT KEY,

      BEGIN OF ts_detail_pernr,
        pernr        TYPE pernr-pernr,
        ename        TYPE p0001-ename,
        stell        TYPE p0001-stell,
        stell_txt    TYPE string,
        address      TYPE string,
        dep_text     TYPE string,
        zzbwpa       TYPE p0007-zzbwpa,
        phone_mobile TYPE string,
        phone_work   TYPE string,
        notes        TYPE p9018-notes,
        kz           TYPE zdhr231_emr_def-kz,
        en           TYPE zdhr231_emr_def-en,
        ru           TYPE zdhr231_emr_def-ru,
      END OF ts_detail_pernr,

      BEGIN OF ts_paris_info,
        t TYPE STANDARD TABLE OF ts_detail_pernr WITH DEFAULT KEY,
      END OF ts_paris_info,

      BEGIN OF ts_9018_io,
        pernr        TYPE p9018-pernr,
        begda        TYPE p9018-begda,
        endda        TYPE p9018-endda,
        emergrole_id TYPE p9018-emergrole_id,
        notes        TYPE p9018-notes,

        " hidden in UI5 interface
        eid          TYPE p9018-emergrole_id,
        prev_begda   TYPE d,
        prev_endda   TYPE d,
      END OF ts_9018_io.

    METHODS:
      _make_report IMPORTING io_xtt                 TYPE REF TO zif_xtt
                             iv_filter              TYPE string
                   RETURNING VALUE(rv_file_content) TYPE xstring,
      _get_root IMPORTING iv_filter      TYPE string
                RETURNING VALUE(rt_root) TYPE tt_sheet,
      _get_paris_info IMPORTING it_sheet             TYPE tt_sheet
                      RETURNING VALUE(rs_paris_info) TYPE ts_paris_info,

      _check_has_default IMPORTING ir_9018_io      TYPE REF TO ts_9018_io
                         RETURNING VALUE(rv_error) TYPE string,

      _check_is_exists   IMPORTING is_9018_io      TYPE ts_9018_io
                         RETURNING VALUE(rv_error) TYPE string,

      _delete_previous   IMPORTING is_9018_io      TYPE ts_9018_io
                         RETURNING VALUE(rv_error) TYPE string,

      _create_new        IMPORTING is_9018_io      TYPE ts_9018_io
                         RETURNING VALUE(rv_error) TYPE string.
ENDCLASS.



CLASS ZCL_HR231_REPORT IMPLEMENTATION.


  METHOD check_authorization.
    DATA(lr_admin_agr_name) = zcl_hr231_options=>get_instance( )->r_admin_agr_name.
    SELECT SINGLE @abap_true INTO @DATA(lv_ok) "#EC CI_GENBUFF
    FROM agr_users
    WHERE agr_name IN @lr_admin_agr_name
      AND uname    EQ @sy-uname
      AND from_dat LE @sy-datum
      AND to_dat   GE @sy-datum.
    CHECK lv_ok <> abap_true.

    rv_error = |No rights to change 'Emergency roles'. Please contact HR support team|.
  ENDMETHOD.


  METHOD zif_sadl_delete_runtime~execute.
    LOOP AT it_key_values ASSIGNING FIELD-SYMBOL(<ls_item>).
      DATA(lv_tabix) = sy-tabix.

      DATA(lv_error) = check_authorization( ).
      IF lv_error IS INITIAL.
        DATA(ls_item) = CORRESPONDING ts_9018_io( <ls_item> ).
        ls_item-prev_begda   = ls_item-begda.
        ls_item-prev_endda   = ls_item-endda.
        ls_item-eid          = ls_item-eid.
        lv_error = _delete_previous( ls_item ).
      ENDIF.
      CHECK lv_error IS NOT INITIAL.

      INSERT lv_tabix INTO TABLE et_failed[].
      TRY.
          zcx_eui_no_check=>raise_sys_error( iv_message = lv_error ).
        CATCH zcx_eui_no_check INTO DATA(lo_error).
          RAISE EXCEPTION TYPE cx_sadl_contract_violation
            EXPORTING
              previous = lo_error.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_sadl_mpc~define.
    DATA(lo_entity) = io_model->get_entity_type( 'ZC_HR231_Emergency_RoleType' ).

    lo_entity->set_is_media( abap_true ).
    lo_entity->get_property( 'pernr' )->set_as_content_type( ).
    lo_entity->get_property( 'begda' )->set_as_content_type( ).
    lo_entity->get_property( 'endda' )->set_as_content_type( ).
    lo_entity->get_property( 'eid' )->set_as_content_type( ).

**********************************************************************
**********************************************************************

    DATA(lc_fixed_values) = /iwbep/if_mgw_odata_property=>gcs_value_list_type_property-fixed_values.

    io_model->get_entity_type( 'ZC_HR231_EmergeRoleTextType' )->get_property( 'eid' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZC_HR231_Emergency_RoleType' )->get_property( 'eid' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZC_HR231_DefaultsType' )->get_property( 'emergrole_id' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZC_HR231_DefaultsEditType' )->get_property( 'emergrole_id' )->set_value_list( lc_fixed_values ).

    io_model->get_entity_type( 'ZC_HR231_Emergency_RoleType' )->get_property( 'grp_id' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZC_HR231_EmergeRoleTextType' )->get_property( 'grp_id' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZC_HR231_GroupType' )->get_property( 'grp_id' )->set_value_list( lc_fixed_values ).

  ENDMETHOD.


  METHOD zif_sadl_read_runtime~execute.
*    TYPES:
*      BEGIN OF ts_image,
*      END OF ts_image.
*
*    LOOP AT ct_data_rows ASSIGNING FIELD-SYMBOL(<ls_row>).
*
*      DATA(ls_photo) = CORRESPONDING ts_image( <ls_row> ).
*      ls_photo-
*      MOVE-CORRESPONDING: ls_photo TO <ls_row>.
*    ENDLOOP.
  ENDMETHOD.


  METHOD zif_sadl_stream_runtime~create_stream.
    " № 0
    DATA(lv_error) = check_authorization( ).

    " № 1
    IF lv_error IS INITIAL.
      DATA(ls_9018_io) = VALUE ts_9018_io( ).
      /ui2/cl_json=>deserialize( EXPORTING jsonx = is_media_resource-value
                                 CHANGING  data  = ls_9018_io ).
      lv_error = _check_has_default( REF #( ls_9018_io ) ).
    ENDIF.

    " № 2
    IF lv_error IS INITIAL.
      lv_error = _check_is_exists( ls_9018_io ).
    ENDIF.

    " № 3
    IF lv_error IS INITIAL AND ( ls_9018_io-prev_begda IS NOT INITIAL
                              OR ls_9018_io-prev_endda IS NOT INITIAL ).
      lv_error = _delete_previous( ls_9018_io ).
    ENDIF.

    " № 4
    IF lv_error IS INITIAL.
      lv_error = _create_new( ls_9018_io ).
    ENDIF.


**********************************************************************
    IF lv_error IS NOT INITIAL.
      TRY.
          zcx_eui_no_check=>raise_sys_error( iv_message = lv_error ).
        CATCH zcx_eui_no_check INTO DATA(lo_error).
          RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
            EXPORTING
              previous = lo_error.
      ENDTRY.
    ENDIF.

**********************************************************************
    DATA(ls_p9018) = CORRESPONDING p9018( ls_9018_io ).
    zcl_hr231_options=>get_instance( )->send_to( ls_p9018 ).

    er_entity = NEW p9018( ls_p9018 ).
    COMMIT WORK AND WAIT.
  ENDMETHOD.


  METHOD zif_sadl_stream_runtime~get_stream.
    TYPES: BEGIN OF ts_key,
             pernr TYPE pernr-pernr,
             eid   TYPE zdhr231_emergrol-emergrole_id,
           END OF ts_key.
    DATA(ls_key) = VALUE ts_key( ).
    LOOP AT it_key_tab ASSIGNING FIELD-SYMBOL(<ls_key>).
      ASSIGN COMPONENT <ls_key>-name OF STRUCTURE ls_key TO FIELD-SYMBOL(<lv_value>).
      CHECK sy-subrc = 0.
      <lv_value> = <ls_key>-value.
    ENDLOOP.

**********************************************************************
    IF ls_key-pernr IS INITIAL AND iv_filter IS NOT INITIAL.
      DATA(lv_content) = _make_report( io_xtt    = NEW zcl_xtt_excel_xlsx( NEW zcl_xtt_file_smw0( 'ZR_HR231_EMERGDUTY.XLSX' ) )
                                       iv_filter = iv_filter ).
      DATA(lv_mime_type) = |application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|.

      io_srv_runtime->set_header(
           VALUE #( name  = 'Content-Disposition'
                    value = |attachment; filename="ZR_HR231_EMERGDUTY.xlsx"| ) ).
    ELSE.
      " Dump ?
      RETURN.
    ENDIF.

    " Any binary file
    er_stream = NEW /iwbep/cl_mgw_abs_data=>ty_s_media_resource(
      value     = lv_content
      mime_type = lv_mime_type ).
  ENDMETHOD.


  METHOD _check_has_default.
    SELECT SINGLE emergrole_id INTO @ir_9018_io->emergrole_id
    FROM zdhr231_emr_def
    WHERE pernr = @ir_9018_io->pernr.
    CHECK ir_9018_io->emergrole_id IS INITIAL.

    rv_error = |For Personnel Number { ir_9018_io->pernr ALPHA = OUT } there is no default value in ZDHR231_EMR_DEF table|.
  ENDMETHOD.


  METHOD _check_is_exists.
    TYPES p9018_tab TYPE STANDARD TABLE OF p9018 WITH DEFAULT KEY.
    DATA(lt_prev_tab) = CAST p9018_tab( zcl_hr_read=>infty_tab(
           iv_infty   = '9018'
           iv_pernr   = is_9018_io-pernr
           iv_begda   = is_9018_io-begda
           iv_endda   = is_9018_io-endda
           iv_no_auth = abap_true
           iv_where   = |EMERGROLE_ID = '{ is_9018_io-emergrole_id }'| ) )->*.

    IF lines( lt_prev_tab )   = 1                     AND
       is_9018_io-begda       = is_9018_io-prev_begda AND
       is_9018_io-endda       = is_9018_io-prev_endda AND
       lt_prev_tab[ 1 ]-notes = is_9018_io-notes.
      rv_error = |All data are same|.
      RETURN.
    ENDIF.

    DELETE lt_prev_tab WHERE begda = is_9018_io-prev_begda
                         AND endda = is_9018_io-prev_endda.

    CHECK lt_prev_tab[] IS NOT INITIAL.
    rv_error = |The item '{ is_9018_io-emergrole_id }' already exist in period { lt_prev_tab[ 1 ]-begda DATE = USER } - { lt_prev_tab[ 1 ]-endda DATE = USER } |.
  ENDMETHOD.


  METHOD _create_new.
    " Lock
    DATA(ls_return1) = VALUE bapireturn1( ).
    CALL FUNCTION 'BAPI_EMPLOYEE_ENQUEUE'
      EXPORTING
        number = is_9018_io-pernr
      IMPORTING
        return = ls_return1.
    IF ls_return1-id = 'RP' AND ls_return1-number = 60.
      ls_return1-message_v1 = is_9018_io-pernr.
    ENDIF.
    IF ls_return1 IS INITIAL.

      " Create
      DATA(ls_p9018) = CORRESPONDING p9018( is_9018_io ).
      CALL FUNCTION 'HR_INFOTYPE_OPERATION'
        EXPORTING
          infty         = '9018'
          number        = ls_p9018-pernr
          validityend   = ls_p9018-endda
          validitybegin = ls_p9018-begda
          record        = ls_p9018
          operation     = 'INS'
        IMPORTING
          return        = ls_return1
        EXCEPTIONS
          OTHERS        = 0.

      CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
        EXPORTING
          number = is_9018_io-pernr.
    ENDIF.

    CHECK ls_return1 IS NOT INITIAL.
    "MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO rv_error.
    MESSAGE ID ls_return1-id TYPE 'E' NUMBER ls_return1-number
       WITH ls_return1-message_v1 ls_return1-message_v2 ls_return1-message_v3 ls_return1-message_v4 INTO rv_error.
  ENDMETHOD.


  METHOD _delete_previous.
    DATA(ls_prev_row) = CAST p9018( zcl_hr_read=>infty_row(
           iv_infty   = '9018'
           iv_pernr   = is_9018_io-pernr
           iv_begda   = is_9018_io-prev_begda
           iv_endda   = is_9018_io-prev_endda
           iv_no_auth = abap_true
           iv_where   = |EMERGROLE_ID = '{ is_9018_io-eid }'|
           is_default = VALUE p9018( ) ) )->*.
    IF ls_prev_row IS INITIAL.
      rv_error = |Items { is_9018_io-prev_begda DATE = USER } { is_9018_io-prev_endda DATE = USER } not found|.
      RETURN.
    ENDIF.

    " Lock
    DATA(ls_return1) = VALUE bapireturn1( ).
    CALL FUNCTION 'BAPI_EMPLOYEE_ENQUEUE'
      EXPORTING
        number = is_9018_io-pernr
      IMPORTING
        return = ls_return1.
    IF ls_return1-id = 'RP' AND ls_return1-number = 60.
      ls_return1-message_v1 = is_9018_io-pernr.
    ENDIF.

    IF ls_return1 IS INITIAL.
      CALL FUNCTION 'HR_INFOTYPE_OPERATION'
        EXPORTING
          infty         = '9018'
          number        = ls_prev_row-pernr
          validityend   = ls_prev_row-endda
          validitybegin = ls_prev_row-begda
          record        = ls_prev_row
          operation     = 'DEL'
        IMPORTING
          return        = ls_return1
        EXCEPTIONS
          OTHERS        = 0.

      CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
        EXPORTING
          number = is_9018_io-pernr.
    ENDIF.

    CHECK ls_return1 IS NOT INITIAL.
    "MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO rv_error.
    MESSAGE ID ls_return1-id TYPE 'E' NUMBER ls_return1-number
       WITH ls_return1-message_v1 ls_return1-message_v2 ls_return1-message_v3 ls_return1-message_v4 INTO rv_error.
  ENDMETHOD.


  METHOD _get_paris_info.
*    SELECT SINGLE grp_text INTO @DATA(lv_paris_sheet)
*    FROM zvchr231_group
*    WHERE grp_id = '2'.
*    CHECK lv_paris_sheet IS NOT INITIAL.

    DATA(lv_datum) = sy-datum.
    LOOP AT it_sheet ASSIGNING FIELD-SYMBOL(<ls_paris_sheet>). " WHERE name = lv_paris_sheet.
      DATA(lt_info) = <ls_paris_sheet>-t[].
      SORT lt_info.
      DELETE ADJACENT DUPLICATES FROM lt_info.

      LOOP AT lt_info ASSIGNING FIELD-SYMBOL(<ls_info>).
        APPEND CORRESPONDING #( <ls_info> ) TO rs_paris_info-t ASSIGNING FIELD-SYMBOL(<ls_detail_info>).
        REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN <ls_detail_info>-notes WITH cl_abap_char_utilities=>cr_lf.

***********************************
        DATA(ls_0001) = CAST p0001( zcl_hr_read=>infty_row(
          iv_infty   = '0001'
          iv_pernr   = <ls_detail_info>-pernr
          iv_begda   = lv_datum
          iv_endda   = lv_datum
          iv_no_auth = abap_true
          is_default = VALUE p0001( ) ) )->*.
        MOVE-CORRESPONDING ls_0001 TO <ls_detail_info>.

        IF <ls_detail_info>-stell IS NOT INITIAL.
          SELECT SINGLE stltx INTO @<ls_detail_info>-stell_txt
          FROM t513s
          WHERE sprsl EQ @sy-langu
            AND stell EQ @<ls_detail_info>-stell
            AND endda GE @lv_datum
            AND begda LE @lv_datum.
        ENDIF.


        DATA(lv_department) = zcl_hr_om_utilities=>find_hlevel(
                                    im_otype = 'S'
                                    im_objid = ls_0001-plans
                                    im_datum = lv_datum
                                    im_wegid = 'ZS-O-O'
                                    im_hlevel = 'DEPARTMENT' ).

        <ls_detail_info>-dep_text = zcl_hr_om_utilities=>get_object_full_name( im_otype = 'O'
                                                                               im_subty = '0001'
                                                                               im_objid = lv_department
                                                                               im_datum = lv_datum ).
***********************************
        <ls_detail_info>-zzbwpa = CAST p0007( zcl_hr_read=>infty_row(
          iv_infty   = '0007'
          iv_pernr   = <ls_detail_info>-pernr
          iv_begda   = lv_datum
          iv_endda   = lv_datum
          iv_no_auth = abap_true
          is_default = VALUE p0007( ) ) )->zzbwpa.

***********************************
        <ls_detail_info>-phone_mobile =
            CAST p0105( zcl_hr_read=>infty_row(
              iv_infty   = '0105'
              iv_pernr   = <ls_detail_info>-pernr
              iv_begda   = lv_datum
              iv_endda   = lv_datum
              iv_where   = |SUBTY = 'CELL'|
              iv_no_auth = abap_true
              is_default = VALUE p0105( ) ) )->usrid.

***********************************
        DATA(ls_0006) =
            CAST p0006( zcl_hr_read=>infty_row(
              iv_infty   = '0006'
              iv_pernr   = <ls_detail_info>-pernr
              iv_begda   = lv_datum
              iv_endda   = lv_datum
              iv_where   = |SUBTY = '1'|
              iv_no_auth = abap_true
              is_default = VALUE p0006( ) ) )->*.
        <ls_detail_info>-address = |{ ls_0006-ort01 }, { ls_0006-stras }, { ls_0006-hsnmr }, { ls_0006-posta }|.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD _get_root.
    SELECT pernr, begda, endda, eid, role_text, ename, grp_text, grp_id, letter, notes, kz, en, ru INTO TABLE @DATA(lt_alv)
    FROM zc_hr231_emergency_role
    WHERE (iv_filter)
    ORDER BY grp_text.

    LOOP AT lt_alv ASSIGNING FIELD-SYMBOL(<ls_group>) GROUP BY ( grp_text = <ls_group>-grp_text ).
      " New sheet. Each sheet is for 1 grp_text
      APPEND VALUE #( name = <ls_group>-grp_text ) TO rt_root ASSIGNING FIELD-SYMBOL(<ls_sheet>).
      DATA(lv_beg_date) = CONV d( '99991231' ).
      DATA(lv_end_date) = CONV d( '00010101' ).

      LOOP AT GROUP <ls_group> ASSIGNING FIELD-SYMBOL(<ls_alv>).
        APPEND CORRESPONDING #( <ls_alv> ) TO <ls_sheet>-t[] ASSIGNING FIELD-SYMBOL(<ls_line>).

        lv_beg_date = COND #( WHEN lv_beg_date > <ls_alv>-begda THEN <ls_alv>-begda ELSE lv_beg_date ).
        lv_end_date = COND #( WHEN lv_end_date < <ls_alv>-endda THEN <ls_alv>-endda ELSE lv_end_date ).
      ENDLOOP.

      <ls_sheet>-days[] = VALUE tt_day( FOR lv_date = lv_beg_date THEN lv_date + 1 UNTIL lv_date > lv_end_date ( lv_date ) ).
    ENDLOOP.
  ENDMETHOD.


  METHOD _make_report.
    DATA(lt_sheets)     = _get_root( iv_filter ).
    DATA(ls_paris_info) = _get_paris_info( lt_sheets ).

    rv_file_content = io_xtt->merge( lt_sheets
                           )->merge( iv_block_name = 'P' is_block = ls_paris_info
                           )->get_raw( ).
  ENDMETHOD.
ENDCLASS.
