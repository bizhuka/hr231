class ZCL_HR231_ORG_FILTER definition
  public
  final
  create public .

public section.

  interfaces ZIF_SADL_EXIT .
  interfaces ZIF_SADL_PREPARE_READ_RUNTIME .
protected section.
private section.
ENDCLASS.



CLASS ZCL_HR231_ORG_FILTER IMPLEMENTATION.


  METHOD zif_sadl_prepare_read_runtime~change_condition.
    CHECK iv_where ns '^'.

    DATA(lv_datum) = sy-datum.
    DATA(lt_condition) = VALUE if_sadl_query_types=>tt_complex_condition(
     ( type = 'simpleValue' value = lv_datum ) ( type = 'lessThanOrEqual'    attribute = 'BEGDA' )
     ( type = 'and' )
     ( type = 'simpleValue' value = lv_datum ) ( type = 'greaterThanOrEqual' attribute = 'ENDDA' )
    ).

    APPEND LINES OF lt_condition TO ct_sadl_condition.
  ENDMETHOD.
ENDCLASS.
