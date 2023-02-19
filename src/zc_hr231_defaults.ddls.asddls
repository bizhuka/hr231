@AbapCatalog.sqlViewName: 'zvchr231_def'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Defaults'

@ObjectModel: {
    transactionalProcessingEnabled: true,
    writeActivePersistence: 'ZDHR231_EMR_DEF',
    createEnabled: true,
    updateEnabled: true,
    deleteEnabled: true,
    compositionRoot: true,
    
    semanticKey: [ 'pernr']
}


@ZABAP.virtualEntity: 'ZCL_HR231_DEF_FILTER'

@Search.searchable
define view ZC_HR231_Defaults as select from zdhr231_emr_def as _main
  association [0..1] to ZC_HR231_EmergeRoleText as _Text      on _Text.eid = _main.emergrole_id
  
  association [1..1] to ZC_HR231_OrgAssign      as _OrgAssign on _OrgAssign.pernr   = _main.pernr
                                                             and _OrgAssign.sprps   = ' '
{
    @UI.lineItem: [{ position: 10, importance: #HIGH }]
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 10 }]
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
//    @ObjectModel: { readOnly: true }
//    @Consumption.valueHelp: '_OrgAssign'
    key pernr,
        
    @UI.lineItem: [{ position: 15, importance: #HIGH }]
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 15 }]
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    @ObjectModel: { readOnly: true }
    _OrgAssign.ename,
    
    @UI.lineItem: [{ position: 20, importance: #HIGH }]
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 20 }]
//    @Consumption.valueHelp: '_Text'
    emergrole_id,
    
    @UI.lineItem: [{ position: 30 }]
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 30 }]
    kz,
    @UI.lineItem: [{ position: 40 }]
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 40 }]
    en,
    @UI.lineItem: [{ position: 50 }]
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 50 }]
    ru,
    
    _Text,
    _OrgAssign
}
