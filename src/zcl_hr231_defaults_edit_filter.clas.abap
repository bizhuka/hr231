CLASS zcl_hr231_defaults_edit_filter DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES:
      zif_sadl_read_runtime.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS:
      _fill_authorization CHANGING cs_item TYPE zc_hr231_defaultsedit.
ENDCLASS.



CLASS ZCL_HR231_DEFAULTS_EDIT_FILTER IMPLEMENTATION.


  METHOD zif_sadl_read_runtime~execute.
    DATA(ls_item) = CORRESPONDING zc_hr231_defaultsedit( is_filter ).
    CHECK ls_item-pernr = '99999999'.

    IF line_exists( is_requested-elements[ table_line = 'ALLOWED_EIDS' ] ).
      _fill_authorization( CHANGING cs_item = ls_item ).
    ENDIF.

    APPEND INITIAL LINE TO ct_data_rows[] ASSIGNING FIELD-SYMBOL(<ls_row>).
    MOVE-CORRESPONDING ls_item TO <ls_row>.
    cv_number_all_hits = lines( ct_data_rows[] ).
  ENDMETHOD.


  METHOD _fill_authorization.
    SELECT emergrole_id INTO TABLE @DATA(lt_all)        "#EC CI_NOWHERE
    FROM zdhr231_emergrol.

    DATA(lt_allowed_eids) = VALUE string_table( ).
    DATA(lo_opt) = zcl_hr231_options=>get_instance( ).
    LOOP AT lt_all ASSIGNING FIELD-SYMBOL(<ls_item>).
      CHECK lo_opt->check_authorization( iv_emergrole_id = <ls_item>-emergrole_id ) IS INITIAL.
      APPEND <ls_item>-emergrole_id TO lt_allowed_eids.
    ENDLOOP.

    cs_item-allowed_eids = concat_lines_of( table = lt_allowed_eids sep = |,| ).
    cs_item-upd_defaults = xsdbool( lo_opt->check_authorization( iv_upd_defaults = abap_true ) IS INITIAL ).
  ENDMETHOD.
ENDCLASS.
