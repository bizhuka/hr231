CLASS zcl_hr231_chart DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES:
      zif_sadl_exit,
      zif_sadl_read_runtime,
      if_amdp_marker_hdb.

  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      tt_chart TYPE STANDARD TABLE OF zc_hr231_chart WITH DEFAULT KEY,

      BEGIN OF ts_filter,
        period TYPE string,
      END OF ts_filter.


    METHODS:
      _get_chart_items
        IMPORTING VALUE(iv_where)        TYPE string
                  VALUE(iv_group_by)     TYPE char10
                  VALUE(iv_from_date)    TYPE d
                  VALUE(iv_current_date) TYPE d
        EXPORTING VALUE(et_chart)        TYPE tt_chart,

      _get_week_text
        IMPORTING iv_week        TYPE scal-week
        RETURNING VALUE(rv_text) TYPE string,

      _prepare_filter
        IMPORTING is_filter   TYPE ts_filter
        EXPORTING ev_group_by TYPE char10
        CHANGING  cv_where    TYPE string.

ENDCLASS.



CLASS zcl_hr231_chart IMPLEMENTATION.
  METHOD _get_chart_items
       BY DATABASE PROCEDURE FOR HDB
        LANGUAGE SQLSCRIPT
        OPTIONS READ-ONLY
          USING pa9018 zdhr231_emergrol pa0001
          .
    declare lv_mandt     char( 3 ) = session_context('CLIENT');
    declare lv_count     integer;
    declare lv_index     integer;
    declare lv_day_index integer;
    declare lv_tabix     integer;

    declare lt_result table(
            datum char( 8 ),
            pernr char( 8 ),
            ename char( 40 ),
            cnt   integer
    );

   lt_select =
            SELECT _main.begda, _main.pernr,
*                  for filteration
                   _main.EMERGROLE_ID as eid, _grp.grp as grp_id,
                   days_between(_main.begda, _main.endda) as cnt,
                   _0001.ename

            FROM pa9018 as _main inner join ZDHR231_EMERGROL as _grp ON _grp.mandt        = _main.mandt
                                                                    AND _grp.EMERGROLE_ID = _main.EMERGROLE_ID
*                                  inner to delete old values ?
                                 left outer join pa0001 as _0001 ON _0001.mandt =  _main.mandt
                                                                and _0001.PERNR =  _main.pernr
                                                                and _0001.SPRPS =  ' '
                                                                and _0001.ENDDA >= :iv_current_date
                                                                and _0001.BEGDA <= :iv_current_date
            WHERE _main.mandt = :lv_mandt AND _main.sprps = ' '
              and _main.endda >= :iv_from_date;
   lt_select = APPLY_FILTER ( :lt_select, :iv_where);

   lv_count = record_count( :lt_select );
   lv_tabix = 0;
   for lv_index in 1..lv_count do
         for lv_day_index in 0..:lt_select.cnt[ lv_index ] DO
            lv_tabix = lv_tabix + 1;

            lt_result.pernr[ lv_tabix ] = :lt_select.pernr[ lv_index ];
            lt_result.ename[ lv_tabix ] = :lt_select.ename[ lv_index ];
            lt_result.cnt[ lv_tabix ]   = 1;
            lt_result.datum[ lv_tabix ] = to_char( add_days ( to_date( :lt_select.begda[ lv_index ], 'YYYYMMDD' ), :lv_day_index), 'YYYYMMDD' );

            lv_day_index = lv_day_index + 1;
        END for;
    END for;

    if :iv_group_by = 'YEAR' then
*        TOP 200
        et_chart   = SELECT
                        pernr, SUBSTRING(datum, 1, 4) as period, sum( cnt ) as days_count, ename,
                        cast(' ' as VARCHAR( 40 ) ) as period_raw, '99' as eid, '9' as grp_id
                     FROM :lt_result
                     WHERE datum >= :iv_from_date
                     GROUP BY pernr, SUBSTRING(datum, 1, 4), ename
                     ORDER BY        SUBSTRING(datum, 1, 4) DESC;

    elseif :iv_group_by = 'QUARTER' then
*        TOP 700
        et_chart   = SELECT
                        pernr, quarter(datum) as period, sum( cnt ) as days_count, ename,
                        cast(' ' as VARCHAR( 40 ) ) as period_raw, '99' as eid, '9' as grp_id
                     FROM :lt_result
                     WHERE datum >= :iv_from_date
                     GROUP BY pernr, quarter(datum), ename
                     ORDER BY        quarter(datum) DESC;

    elseif :iv_group_by = 'MONTH' then
*        TOP 2000
        et_chart   = SELECT
                        pernr, SUBSTRING(datum, 1, 6) as period, sum( cnt ) as days_count, ename,
                        cast(' ' as VARCHAR( 40 ) ) as period_raw, '99' as eid, '9' as grp_id
                     FROM :lt_result
                     WHERE datum >= :iv_from_date
                     GROUP BY pernr, SUBSTRING(datum, 1, 6), ename
                     ORDER BY        SUBSTRING(datum, 1, 6) DESC;

    elseif :iv_group_by = 'WEEK' then
*        TOP 1700
        et_chart   = SELECT
                        pernr, concat( SUBSTRING(datum, 1, 4), TO_NVARCHAR(week(datum), '00' ) ) as period, sum( cnt ) as days_count, ename,
                        cast(' ' as VARCHAR( 40 ) ) as period_raw, '99' as eid, '9' as grp_id
                     FROM :lt_result
                     WHERE datum >= :iv_from_date
                     GROUP BY pernr, concat( SUBSTRING(datum, 1, 4), TO_NVARCHAR(week(datum), '00' ) ), ename
                     ORDER BY        concat( SUBSTRING(datum, 1, 4), TO_NVARCHAR(week(datum), '00' ) ) DESC;
    end if;
  ENDMETHOD.

  METHOD zif_sadl_read_runtime~execute.
    DATA(ls_filter) = CORRESPONDING ts_filter( is_filter ).
    CHECK ls_filter-period IS NOT INITIAL
      AND ct_data_rows[] IS INITIAL.

    DATA(lv_where) = iv_where.
    _prepare_filter( EXPORTING is_filter   = ls_filter
                     IMPORTING ev_group_by = DATA(lv_group_by)
                     CHANGING  cv_where    = lv_where ).

    DATA(lo_opt) = zcl_hr231_options=>get_instance( ).
    ASSIGN lo_opt->t_period[ period = lv_group_by ] TO FIELD-SYMBOL(<ls_period>).
    _get_chart_items( EXPORTING iv_where        = lv_where
                                iv_group_by     = lv_group_by
                                iv_current_date = sy-datum
                                iv_from_date    = zcl_hr_month=>get_period_start_date( iv_period = <ls_period>-period
                                                                                       iv_offset = CONV #( - <ls_period>-per_count ) )
                      IMPORTING et_chart    = DATA(lt_chart) ).


    LOOP AT lt_chart ASSIGNING FIELD-SYMBOL(<ls_line>).
      IF <ls_line>-ename IS INITIAL.
        <ls_line>-ename = CAST p0001( zcl_hr_read=>infty_row(
           iv_infty   = '0001'
           iv_pernr   = <ls_line>-pernr
           " Last for all periods
*           iv_begda   = sy-datum
*           iv_endda   = sy-datum
           iv_no_auth = abap_true
           is_default = VALUE p0001( ) ) )->ename.
      ENDIF.

      <ls_line>-period_raw = <ls_line>-period.
      CASE lv_group_by.
        WHEN 'MONTH'. <ls_line>-period = <ls_line>-period(4) && ` ` && zcl_hr_month=>get_text( CONV #( <ls_line>-period+4(2) ) ).
        WHEN 'WEEK'.  <ls_line>-period = _get_week_text( iv_week = CONV #( <ls_line>-period ) ).
      ENDCASE.
    ENDLOOP.

    ct_data_rows = CORRESPONDING #( lt_chart ).
  ENDMETHOD.

  METHOD _prepare_filter.
    REPLACE FIRST OCCURRENCE OF |( PERIOD = `{ is_filter-period }` and | IN cv_where WITH ''.
    IF sy-subrc <> 0.
      CLEAR cv_where.
    ELSE.
      DATA(lv_length) = strlen( cv_where ) - 1.
      cv_where = cv_where(lv_length).
      REPLACE ALL OCCURRENCES OF |`| IN cv_where WITH |'|.
    ENDIF.

    SPLIT is_filter-period AT '^' INTO ev_group_by
                                  DATA(lv_basic_search_value).
    CHECK lv_basic_search_value IS NOT INITIAL.

    DATA(lv_fuzzy_search) = |CONTAINS( ( ENAME, PERNR ), '{ lv_basic_search_value }', FUZZY( ( 0.9, 'similarCalculationMode=search' ), ( 0.6, 'similarCalculationMode=search' ) ) )|.
    IF cv_where IS INITIAL.
      cv_where = lv_fuzzy_search.
    ELSE.
      cv_where = |{ cv_where } AND { lv_fuzzy_search }|.
    ENDIF.
  ENDMETHOD.

  METHOD _get_week_text.
    rv_text = COND #( WHEN iv_week+4(2) = '53'
                      THEN |{ iv_week(4) } last week|
                      ELSE |{ iv_week(4) } week №{ iv_week+4(2) }| ).

    DATA(ls_period) = VALUE zcl_hr_month=>ts_range( ).
    CALL FUNCTION 'WEEK_GET_FIRST_DAY'
      EXPORTING
        week   = iv_week
      IMPORTING
        date   = ls_period-begda
      EXCEPTIONS
        OTHERS = 1.

    IF ls_period-begda IS INITIAL.
      RETURN.
    ENDIF.

    ls_period-endda = ls_period-begda + 6.
    rv_text = |{ ls_period-begda(4) } { ls_period-begda+4(2) }.{ ls_period-begda+6(2) } - { ls_period-endda+4(2) }.{ ls_period-endda+6(2) }|.
  ENDMETHOD.
ENDCLASS.
