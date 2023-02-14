CLASS zcl_hr231_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_sadl_exit .
    INTERFACES zif_sadl_stream_runtime .
    INTERFACES zif_sadl_read_runtime .
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
      END OF ts_detail_pernr,

      BEGIN OF ts_paris_info,
        t TYPE STANDARD TABLE OF ts_detail_pernr WITH DEFAULT KEY,
      END OF ts_paris_info.

    METHODS:
      _make_report IMPORTING io_xtt                 TYPE REF TO zif_xtt
                             iv_filter              TYPE string
                   RETURNING VALUE(rv_file_content) TYPE xstring,
      _get_root IMPORTING iv_filter      TYPE string
                RETURNING VALUE(rt_root) TYPE tt_sheet,
      _get_paris_info IMPORTING it_sheet             TYPE tt_sheet
                      RETURNING VALUE(rs_paris_info) TYPE ts_paris_info,

      _get_employee_photo IMPORTING iv_pernr TYPE pernr-pernr RETURNING VALUE(rv_photo) TYPE xstring,
      _get_small_icon     IMPORTING iv_photo TYPE xstring RETURNING VALUE(rv_icon) TYPE xstring.
ENDCLASS.



CLASS ZCL_HR231_REPORT IMPLEMENTATION.


  METHOD zif_sadl_read_runtime~execute.
    TYPES:
      BEGIN OF ts_image,
        " Importing
        pernr      TYPE pernr-pernr,
        " Exporting
        photo_path TYPE text255,
      END OF ts_image .

    cl_http_server=>if_http_server~get_location(
      IMPORTING host         = DATA(lv_host)
                port         = DATA(lv_port)
                out_protocol = DATA(lv_protocol) ).

    LOOP AT ct_data_rows ASSIGNING FIELD-SYMBOL(<ls_row>).

      DATA(ls_photo) = CORRESPONDING ts_image( <ls_row> ).
      ls_photo-photo_path = |{ lv_protocol }://{ lv_host }:{ lv_port }/sap/opu/odata/sap/ZC_HR231_EMERGENCY_ROLE_CDS/ZC_HR231_Emergency_Role(pernr='{
         ls_photo-pernr }',begda=datetime'2000-01-01T00%3A00%3A00',endda=datetime'2000-01-01T00%3A00%3A00',eid='{ ms_const-photo_normal_eid }')/$value?sap-client={ sy-mandt }|.

      MOVE-CORRESPONDING: ls_photo TO <ls_row>.
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_sadl_stream_runtime~create_stream.
*    TYPES: BEGIN OF ts_9018, pernr TYPE p9018-pernr, begda TYPE p9018-begda, endda TYPE p9018-endda,
*             eid   TYPE p9018-emergrole_id, "<--- hidden in UI5 interface
*           END OF ts_9018.
    DATA(lr_9018) = NEW p9018( ).
    /ui2/cl_json=>deserialize( EXPORTING jsonx = is_media_resource-value CHANGING data = lr_9018->* ).

**********************************************************************
    SELECT SINGLE emergrole_id INTO @lr_9018->emergrole_id
    FROM zdhr231_emr_def
    WHERE pernr = @lr_9018->pernr.
    IF lr_9018->emergrole_id IS INITIAL.
      DATA(lv_error) = |For Personnel Number { lr_9018->pernr ALPHA = OUT } there is no default value in ZDHR231_EMR_DEF table|.
    ENDIF.

**********************************************************************
    DO 1 TIMES.
      CHECK lv_error IS INITIAL.

      DATA(lr_prev) = CAST p9018( zcl_hr_read=>infty_row(
             iv_infty   = '9018'
             iv_pernr   = lr_9018->pernr
             iv_begda   = lr_9018->begda
             iv_endda   = lr_9018->endda
             iv_no_auth = abap_true
             iv_where   = |EMERGROLE_ID = '{ lr_9018->emergrole_id }'| ) ).
      CHECK lr_prev IS NOT INITIAL.
      lv_error = |The item '{ lr_9018->emergrole_id }' already exist in period { lr_prev->begda DATE = USER } - { lr_prev->endda DATE = USER } |.
    ENDDO.

**********************************************************************
    DO 1 TIMES.
      CHECK lv_error IS INITIAL.

      " Lock
      DATA(ls_return1) = VALUE bapireturn1( ).
      CALL FUNCTION 'BAPI_EMPLOYEE_ENQUEUE'
        EXPORTING
          number = lr_9018->pernr
        IMPORTING
          return = ls_return1.
      IF ls_return1-id = 'RP' AND ls_return1-number = 60.
        ls_return1-message_v1 = lr_9018->pernr.
      ENDIF.
      CHECK ls_return1 IS INITIAL.

      " Create
*      DATA(ls_9018) = VALUE p9018( pernr        = lr_9018->pernr begda        = lr_9018->begda endda        = lr_9018->endda
*                                   emergrole_id = lr_9018->eid ).
      CALL FUNCTION 'HR_INFOTYPE_OPERATION'
        EXPORTING
          infty         = '9018'
          number        = lr_9018->pernr
*         subtype       = lr_9018->subty
          validityend   = lr_9018->endda
          validitybegin = lr_9018->begda
          record        = lr_9018->*
          operation     = 'INS'
        IMPORTING
          return        = ls_return1
        EXCEPTIONS
          OTHERS        = 0.

      CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
        EXPORTING
          number = lr_9018->pernr.
    ENDDO.

**********************************************************************
    IF ls_return1 IS NOT INITIAL.
      "MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO DATA(lv_error).
      MESSAGE ID ls_return1-id TYPE 'E' NUMBER ls_return1-number
         WITH ls_return1-message_v1 ls_return1-message_v2 ls_return1-message_v3 ls_return1-message_v4 INTO lv_error.
    ENDIF.

    IF lv_error IS NOT INITIAL.
      TRY.
          zcx_eui_no_check=>raise_sys_error( iv_message = lv_error ).
        CATCH zcx_eui_no_check INTO DATA(lo_error).
          RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
            EXPORTING
              previous = lo_error.
      ENDTRY.
    ENDIF.

    zcl_hr231_options=>get_instance( )->send_to( lr_9018->* ).

    er_entity = lr_9018.
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
    " Photo
    IF ls_key-pernr IS NOT INITIAL AND ( ls_key-eid = ms_const-photo_normal_eid OR ls_key-eid = ms_const-photo_icon_eid ).
      DATA(lv_content)   = _get_employee_photo( ls_key-pernr ).
      IF ls_key-eid = ms_const-photo_icon_eid.
        lv_content = _get_small_icon( lv_content ).
      ENDIF.
      IF lv_content IS INITIAL.
        lv_content = cl_http_utility=>decode_x_base64( 'Qk06AAAAAAAAADYAAAAoAAAAAQAAAAEAAAABABgAAAAAAAQAAADEDgAAxA4AAAAAAAAAAAAA////AA==' ).
      ENDIF.

      DATA(lv_mime_type) = |image/jpeg|.
      io_srv_runtime->set_header(
           VALUE #( name  = 'Content-Disposition'
                    value = |inline; filename="ok.jpg"| ) ).
**********************************************************************
      " Report
    ELSEIF ls_key-pernr IS INITIAL AND iv_filter IS NOT INITIAL.
      lv_content = _make_report( io_xtt    = NEW zcl_xtt_excel_xlsx( NEW zcl_xtt_file_smw0( 'ZR_HR231_EMERGDUTY.XLSX' ) )
                                 iv_filter = iv_filter ).
      lv_mime_type = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'.

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


  METHOD _get_employee_photo.
    DATA lt_connection TYPE STANDARD TABLE OF bdn_con.
    CALL FUNCTION 'BDS_ALL_CONNECTIONS_GET'
      EXPORTING
        classname       = 'PREL'
        classtype       = 'CL'
        objkey          = CONV swotobjid-objkey( iv_pernr && '%' )
      TABLES
        all_connections = lt_connection
      EXCEPTIONS
        OTHERS          = 0.
    LOOP AT lt_connection ASSIGNING FIELD-SYMBOL(<ls_connection>) WHERE doc_type EQ 'HRICOLFOTO' OR doc_type EQ 'HRIEMPFOTO'.
      DATA(lt_info) = VALUE ilm_stor_t_scms_acinf( ).
      DATA(lt_bin)  = VALUE btc_t_xmlxtab( ).
      CLEAR: lt_info, lt_bin.
      CALL FUNCTION 'SCMS_DOC_READ'
        EXPORTING
          stor_cat    = space
          crep_id     = <ls_connection>-contrep
          doc_id      = <ls_connection>-bds_docid
        TABLES
          access_info = lt_info
          content_bin = lt_bin
        EXCEPTIONS
          OTHERS      = 15.
      CHECK sy-subrc = 0 AND lt_info[] IS NOT INITIAL AND lt_bin IS NOT INITIAL.

      rv_photo = zcl_eui_conv=>binary_to_xstring( it_table  = lt_bin
                                                  iv_length = lt_info[ 1 ]-comp_size ).
      RETURN.
    ENDLOOP.
  ENDMETHOD.


  METHOD _get_paris_info.
    SELECT SINGLE grp_text INTO @DATA(lv_paris_sheet)
    FROM zvchr231_group
    WHERE grp_id = '2'.
    CHECK lv_paris_sheet IS NOT INITIAL.

    DATA(lv_datum) = sy-datum.
    LOOP AT it_sheet ASSIGNING FIELD-SYMBOL(<ls_paris_sheet>) WHERE name = lv_paris_sheet.
      DATA(lt_info) = <ls_paris_sheet>-t[].
      SORT lt_info.
      DELETE ADJACENT DUPLICATES FROM lt_info.

      LOOP AT lt_info ASSIGNING FIELD-SYMBOL(<ls_info>).
        APPEND CORRESPONDING #( <ls_info> ) TO rs_paris_info-t ASSIGNING FIELD-SYMBOL(<ls_detail_info>).

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
    SELECT * INTO TABLE @DATA(lt_alv)
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


  METHOD _get_small_icon.
    CHECK iv_photo IS NOT INITIAL.
    DATA(o_ip) = NEW cl_fxs_image_processor( ).
    DATA(lv_hndl) = o_ip->add_image( iv_data = iv_photo ).

    o_ip->get_info( EXPORTING
                      iv_handle   = lv_hndl
                    IMPORTING
*                      ev_mimetype = DATA(lv_mimetype)
                      ev_xres     = DATA(lv_xres)
                      ev_yres     = DATA(lv_yres)
*                      ev_xdpi     = DATA(lv_xdpi)
*                      ev_ydpi     = DATA(lv_ydpi)
*                      ev_bitdepth = DATA(lv_bitdepth)
                      ).

    o_ip->resize(  iv_handle = lv_hndl
                    iv_xres   = 64
                    iv_yres   = 64 / lv_xres * lv_yres
                    ).


    o_ip->convert( iv_handle = lv_hndl
                   iv_format = cl_fxs_mime_types=>co_image_jpeg ).

    rv_icon = o_ip->get_image( lv_hndl ).
  ENDMETHOD.


  METHOD _make_report.
    DATA(lt_sheets)     = _get_root( iv_filter ).
    DATA(ls_paris_info) = _get_paris_info( lt_sheets ).

    rv_file_content = io_xtt->merge( lt_sheets
                           )->merge( iv_block_name = 'P' is_block = ls_paris_info
                           )->get_raw( ).
  ENDMETHOD.
ENDCLASS.
