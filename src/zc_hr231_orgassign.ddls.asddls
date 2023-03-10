@AbapCatalog.sqlViewName: 'zvchr231_org_ass'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Org. Assign'
@Search.searchable: true

define view ZC_HR231_OrgAssign as select from ZC_PY000_OrgAssignment {
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
    key pernr,
    key endda,
    key begda,
        
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
        ename,
        
        datum,
        
        plans,
        _Position
} where begda  <=  datum and endda  >= datum
