@AbapCatalog.sqlViewName: 'zvchr231_defed'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Edit version of ZC_HR231_Defaults'


@ObjectModel: {
    transactionalProcessingEnabled: true,
    writeActivePersistence: 'ZDHR231_EMR_DEF',
    createEnabled: true,
    updateEnabled: true,
    deleteEnabled: true,
    compositionRoot: true,
    
    semanticKey: [ 'pernr']
}

@ZABAP.virtualEntity: 'ZCL_HR231_DEFAULTS_EDIT_FILTER'

// Edit defaults
define view ZC_HR231_DefaultsEdit as select from ZC_HR231_Defaults {
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 10 }]
    key pernr,
    
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 15 }]
    @ObjectModel: { mandatory: true }
    key emergrole_id, 
    emergrole_text,  
    
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 20 }]
    @ObjectModel: { readOnly: true }                     
    ename,
    
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 30 }]
    kz,
    
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 40 }]
    en,
    
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 50 }]
    ru,
    
    @UI.hidden: true
    cast( ' ' as abap.char( 25 )) as allowed_eids,
    @UI.hidden: true
    cast( ' ' as abap.char( 25 )) as upd_defaults,
        
    /* Associations */
    _OrgAssign,
    _Text
}
