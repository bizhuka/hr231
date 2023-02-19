CLASS zcl_hr231_def_filter DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_sadl_exit .
    INTERFACES zif_sadl_prepare_read_runtime .
    INTERFACES zif_sadl_prepare_batch .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HR231_DEF_FILTER IMPLEMENTATION.


  METHOD zif_sadl_prepare_batch~prepare.
    LOOP AT ct_create ASSIGNING FIELD-SYMBOL(<ls_create>) WHERE source-association_name CP 'TO_FAKE*'.
      CLEAR <ls_create>-source-association_name.
      <ls_create>-source-entity_id = <ls_create>-entity_id.
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_sadl_prepare_read_runtime~change_condition.
    CHECK iv_where CP |PERNR = `*`|.
    CLEAR ct_sadl_condition[].
  ENDMETHOD.
ENDCLASS.
