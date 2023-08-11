@AbapCatalog.sqlViewName: 'zvchr231_chart'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Chart'
@Search.searchable

@ZABAP.virtualEntity: 'ZCL_HR231_CHART'
define view ZC_HR231_Chart as select from pa9018 {
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    key pernr,
    
    // Year or Quarter Or Month (default) Or Week
    key cast(' ' as abap.char( 40 )) as period,
    
        // Main measure
        cast(0 as abap.int4 ) as days_count,
        
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }    
        cast(' ' as abap.char( 40 ) ) as ename,
        cast(' ' as abap.char( 40 )) as period_raw,
        '99' as eid,
        '9' as grp_id
}
