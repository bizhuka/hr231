*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lcl_util DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      get_from_filter IMPORTING iv_filter       TYPE string
                                iv_find         TYPE string
                      RETURNING VALUE(rv_value) TYPE string,
      format IMPORTING is_root           TYPE any
                       iv_template       TYPE string
             RETURNING VALUE(rv_escaped) TYPE string.
ENDCLASS.

CLASS lcl_util IMPLEMENTATION.
  METHOD get_from_filter.
    CHECK iv_filter CS iv_find.

    DATA(lv_from) = sy-fdpos + strlen( iv_find ).
    FIND FIRST OCCURRENCE OF |'| IN iv_filter+lv_from MATCH OFFSET DATA(lv_to).

    rv_value = iv_filter+lv_from(lv_to).
  ENDMETHOD.

  METHOD format.
    DATA(lv_body) = iv_template.
    REPLACE ALL OCCURRENCES OF: cl_abap_char_utilities=>cr_lf IN lv_body WITH `<br>`,
                                `><br>`                       IN lv_body WITH `>`. " Skip tags

    rv_escaped = zcl_xtt_html=>format( iv_template = lv_body
                                       is_root     = is_root ).
  ENDMETHOD.
ENDCLASS.
