*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDHR231_EMERGROL................................*
DATA:  BEGIN OF STATUS_ZDHR231_EMERGROL              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDHR231_EMERGROL              .
CONTROLS: TCTRL_ZDHR231_EMERGROL
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZDHR231_EMERGROL              .
TABLES: ZDHR231_EMERGROL               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
