*----------------------------------------------------------------------*
*                                                                      *
*       Data definition for infotype 9018                              *
*                                                                      *
*----------------------------------------------------------------------*
PROGRAM mp901800 MESSAGE-ID rp.

TABLES:
  p9018,
  zdhr231_emergrol.
* the following tables are filled globally:
* T001P, T500P
* they can be made available with a TABLES-statement

FIELD-SYMBOLS: <pnnnn> STRUCTURE p9018
                       DEFAULT p9018.

DATA: psave LIKE p9018.
