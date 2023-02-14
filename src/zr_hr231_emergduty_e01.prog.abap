*&---------------------------------------------------------------------*
*&  Include           ZR_HR231_EMERGDUTY_E01
*&---------------------------------------------------------------------*


initialization.

  data(lo_report) = new lcl_report( ).
  s_period-sign = 'I'.
  s_period-option = 'EQ'.
  s_period-low = sy-datum(4) && sy-datum+4(2) && '01'.
  call function 'HR_JP_MONTH_BEGIN_END_DATE'
    exporting
      iv_date           = s_period-low
    importing
      ev_month_end_date = s_period-high.
  append s_period.

start-of-selection.
  lo_report->set_global( ).
  lo_report->getdata( ).
  lo_report->show_data( ).
