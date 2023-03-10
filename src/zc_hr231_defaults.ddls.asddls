@AbapCatalog.sqlViewName: 'zvchr231_def'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Defaults'


@Search.searchable
define view ZC_HR231_Defaults as select from zdhr231_emr_def as _main
  association [0..1] to ZC_HR231_EmergeRoleText as _Text      on _Text.eid = _main.emergrole_id
  
  association [1..1] to ZC_HR231_OrgAssign as _OrgAssign on _OrgAssign.pernr   = _main.pernr
                                                        and _OrgAssign.begda  <= _OrgAssign.datum
                                                        and _OrgAssign.endda  >= _OrgAssign.datum
  
{
    @UI.lineItem: [{ position: 10, importance: #HIGH }]    
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
    @Consumption.valueHelp: '_OrgAssign'
    key pernr,
        
    @UI.lineItem: [{ position: 15, importance: #HIGH }]
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    _OrgAssign.ename,
    
    @UI.lineItem: [{ position: 100, importance: #LOW, exclude: true }]  
    @ObjectModel.text.element: ['emergrole_text']
    @Consumption.valueHelp: '_Text'
    @UI.textArrangement: #TEXT_ONLY
    _main.emergrole_id,
    
//    @UI.hidden: true
    @UI.lineItem: [{ position: 20, importance: #HIGH }]
    _Text.text as emergrole_text,
    
    @UI.lineItem: [{ position: 30 }]
    kz,
    @UI.lineItem: [{ position: 40 }]
    en,
    @UI.lineItem: [{ position: 50 }]
    ru,
    
    /* Associations */
    _Text,
    _OrgAssign
}
