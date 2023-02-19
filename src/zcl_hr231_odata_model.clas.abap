class ZCL_HR231_ODATA_MODEL definition
  public
  final
  create public .

public section.

  class-methods DEFINE_MODEL
    importing
      !IO_MODEL type ref to /IWBEP/IF_MGW_ODATA_MODEL
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .
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
