CLASS zcl_hr231_odata_model DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS define_model
      IMPORTING
        !io_model TYPE REF TO /iwbep/if_mgw_odata_model .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HR231_ODATA_MODEL IMPLEMENTATION.


  METHOD define_model.
    DATA(lo_entity) = io_model->get_entity_type( 'ZC_HR231_Emergency_RoleType' ).

    lo_entity->set_is_media( abap_true ).
    lo_entity->get_property( 'pernr' )->set_as_content_type( ).
    lo_entity->get_property( 'begda' )->set_as_content_type( ).
    lo_entity->get_property( 'endda' )->set_as_content_type( ).
    lo_entity->get_property( 'eid' )->set_as_content_type( ).
  ENDMETHOD.
ENDCLASS.
