class ZCL_ZC_HR231_EMERGENCY_ROLE definition
  public
  inheriting from CL_SADL_GTK_EXPOSURE_MPC
  final
  create public .

public section.

  methods DEFINE
    redefinition .
protected section.

  methods GET_PATHS
    redefinition .
  methods GET_TIMESTAMP
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZC_HR231_EMERGENCY_ROLE IMPLEMENTATION.


METHOD define.
  super->define( ).
  zcl_hr231_odata_model=>define_model( model ).
ENDMETHOD.


  method GET_PATHS.
et_paths = VALUE #(
( `CDS~ZC_HR231_EMERGENCY_ROLE` )
).
  endmethod.


  method GET_TIMESTAMP.
RV_TIMESTAMP = 20230219091442.
  endmethod.
ENDCLASS.
