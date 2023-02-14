*----------------------------------------------------------------------*
*       Output-modules for infotype 9018                               *
*----------------------------------------------------------------------*


*----------------------------------------------------------------------*
*       Default values, Texts                                          *
*----------------------------------------------------------------------*
MODULE p9018 OUTPUT.
  IF psyst-nselc EQ yes.
* read text fields etc.; do this whenever the screen is show for the
*  first time:
*   PERFORM RExxxx.
    IF psyst-iinit = yes AND psyst-ioper = insert.
      " generate default values; do this the very first time on insert only:
      PERFORM get_default.
    ENDIF.
  ENDIF.

  " TODO create new UI strructure
  CLEAR zdhr231_emergrol.
  SELECT SINGLE emergrole INTO @zdhr231_emergrol-emergrole
  FROM zdhr231_emergrol
  WHERE emergrole_id = @p9018-emergrole_id.

ENDMODULE.


*----------------------------------------------------------------------*
*       read texts for listscreen
*----------------------------------------------------------------------*
MODULE p9018l OUTPUT.
* PERFORM RExxxx.
ENDMODULE.



FORM get_default.
  CHECK p9018-emergrole_id IS INITIAL
    AND pspar-pernr IS NOT INITIAL.

  SELECT SINGLE emergrole_id INTO @p9018-emergrole_id
  FROM zdhr231_emr_def
  WHERE pernr = @pspar-pernr.

ENDFORM.
