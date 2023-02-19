*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDHR231_EMR_DEF.................................*
DATA:  BEGIN OF STATUS_ZDHR231_EMR_DEF               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDHR231_EMR_DEF               .
CONTROLS: TCTRL_ZDHR231_EMR_DEF
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZDHR231_EMR_DEF               .
TABLES: ZDHR231_EMR_DEF                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
