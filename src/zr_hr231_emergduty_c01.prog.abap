*&---------------------------------------------------------------------*
*&  Include           ZR_HR231_EMERGDUTY_C01
*&---------------------------------------------------------------------*


CLASS lcl_report DEFINITION.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ts_weekduty,
*        yesno type char1,
        till TYPE char20,
      END OF ts_weekduty,
      tt_weekduty TYPE STANDARD TABLE OF ts_weekduty WITH DEFAULT KEY,

      BEGIN OF ts_column,
        mon_dates TYPE string,
        row_field TYPE string,
      END OF ts_column,
      tt_column TYPE STANDARD TABLE OF ts_column WITH DEFAULT KEY,

      BEGIN OF ts_row,
        pernr      TYPE pernr_d,
        lastname   TYPE pa0002-nachn,
        name       TYPE pa0002-vorna,
        role       TYPE zdhr231_emergrol-emergrole,
        begda      TYPE begda,
        endda      TYPE endda,
        t_weekduty TYPE tt_weekduty,
      END OF ts_row,
      tt_row TYPE STANDARD TABLE OF ts_row WITH DEFAULT KEY,

      " Document structure
      BEGIN OF ts_merge,
        title TYPE string,
        c     TYPE tt_column, " 1st. In template {R-C}
        t     TYPE tt_row,    " 2nd.
      END OF ts_merge.
    DATA: ms_merge  TYPE ts_merge,
          mr_roleid TYPE RANGE OF zde_hr231_emergrole_id.


    METHODS: set_global,
      getdata,
      get_columns RETURNING VALUE(rt_column) TYPE tt_column,
      show_data,
      check_weekduty IMPORTING iv_cnt           TYPE sy-index
                               iv_begda         TYPE begda
                               iv_endda         TYPE endda
                     EXPORTING ev_till          TYPE char20
                     RETURNING VALUE(rv_result) TYPE abap_bool
                     .

ENDCLASS.

CLASS lcl_report IMPLEMENTATION.

  METHOD set_global.
    CASE abap_true.
      WHEN rb_hr.
        mr_roleid = VALUE #( sign   = 'I'
                             option = 'EQ'
                            ( low = '01' )
                            ( low = '02' )
                            ( low = '03' )
                            ( low = '04' ) ).
        ms_merge-title = 'HR Emergency'.
      WHEN rb_paris.
        mr_roleid = VALUE #( sign   = 'I'
                             option = 'EQ'
                            ( low = '05' )
                            ( low = '06' ) ).
        ms_merge-title = 'PARIS group'.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.

  METHOD getdata.
    DATA lv_till TYPE char20.
    ms_merge-c = get_columns( ).
    DATA(lv_col_cnt) = lines( ms_merge-c ).

    SELECT * FROM pa9018                      "#EC CI_ALL_FIELDS_NEEDED
      INTO TABLE @DATA(lt_9018)
      WHERE pernr IN @s_pernr
        AND begda LE @s_period-high
        AND endda GE @s_period-low
        AND emergrole_id IN @mr_roleid.

    DATA ls0002 TYPE pa0002.
    LOOP AT lt_9018 ASSIGNING FIELD-SYMBOL(<fs_9018>).

      APPEND INITIAL LINE TO ms_merge-t ASSIGNING FIELD-SYMBOL(<fs_item>).
      <fs_item>-pernr = <fs_9018>-pernr.

      SELECT SINGLE emergrole INTO @<fs_item>-role
      FROM zdhr231_emergrol
      WHERE emergrole_id = @<fs_9018>-emergrole_id.

      <fs_item>-begda = <fs_9018>-begda.
      <fs_item>-endda = <fs_9018>-endda.
      SELECT SINGLE nachn, vorna FROM pa0002 INTO CORRESPONDING FIELDS OF @ls0002 WHERE pernr = @<fs_9018>-pernr.
      IF sy-subrc = 0.
        <fs_item>-lastname = ls0002-nachn.
        <fs_item>-name = ls0002-vorna.
      ENDIF.

      FIELD-SYMBOLS <lt_weekduty> TYPE tt_weekduty.
      ASSIGN COMPONENT 'T_WEEKDUTY' OF STRUCTURE <fs_item> TO <lt_weekduty>.

      DO lv_col_cnt TIMES.
        CLEAR lv_till.
        DATA(lv_index) = sy-index.
        IF <lt_weekduty> IS ASSIGNED.
          APPEND INITIAL LINE TO <lt_weekduty> ASSIGNING FIELD-SYMBOL(<lv_weekduty>).
          IF check_weekduty( EXPORTING iv_cnt = lv_index iv_begda = <fs_item>-begda iv_endda = <fs_item>-endda IMPORTING ev_till = lv_till )
            EQ abap_true.
            IF lv_till IS NOT INITIAL.
              <lv_weekduty> = lv_till.
            ELSE.
              <lv_weekduty> = 'X'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDDO.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_weekduty.

    DATA: lv_date  TYPE sy-datum,
          lv_date7 TYPE sy-datum.
    CLEAR ev_till.
    rv_result = abap_false.
    DO.
      " Index without leading space
      DATA(lv_index) = sy-index.
*      condense lv_index.

      IF lv_date IS INITIAL.
        lv_date = s_period-low.
      ELSE.
        lv_date = lv_date7 + 1.
      ENDIF.
      lv_date7 = lv_date + 6.

      IF lv_index <> iv_cnt.
        CONTINUE.
      ENDIF.

      IF ( iv_begda BETWEEN lv_date AND lv_date7 ) OR
         ( iv_endda BETWEEN lv_date AND lv_date7 ) OR
         ( lv_date BETWEEN iv_begda AND iv_endda AND lv_date7 BETWEEN iv_begda AND iv_endda ).
        rv_result = abap_true.
      ENDIF.
      IF iv_endda LE lv_date7.
        ev_till = |till { iv_endda+6(2) }.{ iv_endda+4(2) }.{ iv_endda(4) } |.
      ENDIF.

      EXIT.
    ENDDO.
  ENDMETHOD.

  METHOD show_data.

    DATA(lo_xtt) = NEW zcl_xtt_excel_xlsx( NEW zcl_xtt_file_smw0( 'ZR_HR231_EMERGDUTY.XLSX' ) ).
    lo_xtt->merge( ms_merge ).
    lo_xtt->show( ).
*    lo_xtt->download( ).

  ENDMETHOD.

  METHOD get_columns.
    DATA: ls_column TYPE ts_column,
          lv_date   TYPE sy-datum,
          lv_date7  TYPE sy-datum.
    DO.
      " Index without leading space
      DATA lv_index  TYPE string.
      lv_index = sy-index.
      CONDENSE lv_index.

      IF lv_date IS INITIAL.
        lv_date = s_period-low.
      ELSE.
        lv_date = lv_date7 + 1.
      ENDIF.
      lv_date7 = lv_date + 6.

      IF lv_date > s_period-high.
        EXIT.
      ENDIF.

*     ex. ls_column-mon_txt = 'from 10.12.22 till 16.12.22'.
      ls_column-mon_dates = |from { lv_date+6(2) }.{ lv_date+4(2) }.{ lv_date(4) } | &&
                            |till { lv_date7+6(2) }.{ lv_date7+4(2) }.{ lv_date7(4) } |.

      " Add with dynamic column name
      CONCATENATE `{R-T:v-T_WEEKDUTY[ ` lv_index ` ]-TILL;}` INTO ls_column-row_field.

      APPEND ls_column TO rt_column.
    ENDDO.

  ENDMETHOD.

ENDCLASS.
