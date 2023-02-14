@AbapCatalog.sqlViewName: 'zvchr231_group'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Group'
@VDM.viewType: #CONSUMPTION

define view ZC_HR231_Group as select from dd07t as t {
    @ObjectModel.text.element: [ 'Text' ]
    @UI.textArrangement: #TEXT_ONLY  
    @EndUserText.label: 'Group'
    @UI.lineItem: [{ position: 10 }] 
    key domvalue_l as grp_id,
    
    @EndUserText.label: 'Group'
    @UI.lineItem: [{ position: 20 }]
    ddtext as grp_text        
} where t.domname = 'ZDD_HR231_GROUP' and t.ddlanguage = $session.system_language and t.as4local = 'A' and t.as4vers = '0000'