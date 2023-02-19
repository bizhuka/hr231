@AbapCatalog.sqlViewName: 'zvchr231_pa0001'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PA0001'


define view ZC_HR231_PA0001 as select from pa0001 {
    key mandt,
    key pernr,
    key sprps,
    key endda,
    key begda,
    
        bukrs,
        ename,
        werks,
        persg,        
        persk,
        kokrs,
        kostl,
        orgeh,
        plans,
        stell,
        ansvh,
        btrtl,        
        
        cast (substring( cast( tstmp_current_utctimestamp() as abap.char(17) ), 1, 8 ) as abap.dats) as datum
}
