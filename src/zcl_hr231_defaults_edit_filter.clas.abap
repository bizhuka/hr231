CLASS zcl_hr231_defaults_edit_filter DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES: zif_sadl_exit,
      zif_sadl_read_runtime,
      zif_sadl_prepare_read_runtime,
      zif_sadl_prepare_batch.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HR231_DEFAULTS_EDIT_FILTER IMPLEMENTATION.


  METHOD zif_sadl_prepare_batch~prepare.
    DATA(lv_error) = NEW zcl_hr231_report( )->check_authorization( ).
    IF lv_error IS NOT INITIAL.
      TRY.
          zcx_eui_no_check=>raise_sys_error( iv_message = lv_error ).
        CATCH zcx_eui_no_check INTO DATA(lo_error).
          RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
            EXPORTING
              previous = lo_error.
      ENDTRY.
    ENDIF.

    LOOP AT ct_create ASSIGNING FIELD-SYMBOL(<ls_create>) WHERE source-association_name CP 'TO_DEFAULTSEDIT*'.
      CLEAR <ls_create>-source-association_name.
      <ls_create>-source-entity_id = <ls_create>-entity_id.
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_sadl_prepare_read_runtime~change_condition.
    CHECK iv_where CS |^TO_DEFAULTSEDIT|.
    CLEAR ct_sadl_condition[].
  ENDMETHOD.


  METHOD zif_sadl_read_runtime~execute.
    TYPES: BEGIN OF ts_key,
             pernr TYPE string,
           END OF ts_key.
    FIELD-SYMBOLS <ls_key> TYPE ts_key.

    ASSIGN ir_key->* TO <ls_key> CASTING.
    CHECK sy-subrc = 0 AND <ls_key>-pernr = '99999999'.

    CHECK NEW zcl_hr231_report( )->check_authorization( ) IS INITIAL.

    " Can edit
    APPEND INITIAL LINE TO ct_data_rows[] ASSIGNING FIELD-SYMBOL(<ls_row>).
    MOVE-CORRESPONDING <ls_key> TO <ls_row>.
    cv_number_all_hits = lines( ct_data_rows[] ).
  ENDMETHOD.
ENDCLASS.
