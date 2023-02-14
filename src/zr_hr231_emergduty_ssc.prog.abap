*&---------------------------------------------------------------------*
*&  Include           ZR_HR231_EMERGDUTY_SSC
*&---------------------------------------------------------------------*
tables: pa9018.
selection-screen begin of block 01 with frame title text-001.

select-options: s_pernr  for pa9018-pernr,
                s_period for sy-datum obligatory.

parameters: rb_hr    type char1 radiobutton group rg1 default 'X',
            rb_paris type char1 radiobutton group rg1.
selection-screen end of block 01.
