@AbapCatalog.sqlViewName: 'zvchr231_emg_txt'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Role texts'
@VDM.viewType: #CONSUMPTION


define view ZC_HR231_EmergeRoleText as select from zdhr231_emergrol
  association [1..1] to ZC_HR231_Group      as _Group on _Group.grp_id = grp
{

    @UI.lineItem: [{ position: 10, importance: #HIGH }]
    @ObjectModel.text.element: ['text'] 
    @UI.textArrangement: #TEXT_ONLY      
    key emergrole_id as eid,
    
        @UI.lineItem: [{ position: 20 }]
        @Semantics.text: true
        emergrole    as text,
        
        letter,
        
        @Consumption.valueHelp: '_Group'
        grp as grp_id,
        
        _Group
}
