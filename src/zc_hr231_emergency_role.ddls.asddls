@AbapCatalog.sqlViewName: 'zvchr231_emg_rol'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Emergency roles of Personnel Number'
@VDM.viewType: #CONSUMPTION
//@Search.searchable


@ObjectModel: {
    transactionalProcessingEnabled: true,
//    writeActivePersistence: 'PA9018',
//    compositionRoot: true,
    createEnabled: true,
//    updateEnabled: true,
//    deleteEnabled: true,
    
    semanticKey: [ 'pernr']
    // draftEnabled: true, writeDraftPersistence: ''
    // modelCategory: #BUSINESS_OBJECT,
}


@UI: {
    headerInfo: {
        typeName: 'Emergency role',
        typeNamePlural: 'Emergency roles',
        title: {
            type: #STANDARD, value: 'ename'
        },
        description: {
            value: 'pernr'
        }
    }
}    
@OData.publish: true

@ZABAP.virtualEntity: 'ZCL_HR231_REPORT'

define view ZC_HR231_Emergency_Role as select from pa9018 as _root                                                             
  association [1..1] to ZC_HR231_OrgAssign      as _OrgAssign on _OrgAssign.pernr   = _root.pernr
                                                             and _OrgAssign.endda  >= _root.begda  
                                                             and _OrgAssign.begda  <= _root.endda
                                                             and _OrgAssign.sprps   = ' '
  association [0..1] to ZC_HR231_EmergeRoleText as _Text      on _Text.eid          = _root.emergrole_id
  
  association [0..*] to ZC_HR231_Defaults       as _FakeConn  on _FakeConn.pernr    = _root.pernr  
  //association [1..1] to pa0002                  as _PersInfo  on _PersInfo.    
{
//     @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
     @UI.lineItem: [{ position: 10, importance: #HIGH }]
     @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
     //@Consumption.valueHelp: '_OrgAssign'
     key _root.pernr,
     
     
     @UI.lineItem: [{ position: 20, importance: #HIGH }]
     @UI.selectionField: [{ position: 10 }]
     @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
     key _root.begda,
     
     @UI.lineItem: [{ position: 30, importance: #HIGH }]
//     @UI.selectionField: [{ position: 20 }]
     @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
     key _root.endda,
         
         @UI.selectionField: [{ position: 30 }]
         //@Consumption.valueHelp: '_Text'
         @ObjectModel.text.element: ['role_text']
         //@UI.lineItem: [{ position: 70, importance: #HIGH, label: 'Emergency role' }]
         //@UI.textArrangement: #TEXT_ONLY  
     key _root.emergrole_id as eid,
         _Text.text as role_text,
         
          @UI.lineItem: [{ position: 40, importance: #HIGH }]
//          @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
          _OrgAssign.ename,
          @UI.lineItem: [{ position: 50, importance: #LOW }]
          _OrgAssign.plans_txt,
          
//         @UI.lineItem: [{ position: 50, importance: #LOW }] @UI.fieldGroup: [{ qualifier: 'PersInfo', position: 20 }]
//         _PersInfo.vorna as FirstName, _PersInfo.nachn as LastName,    
         
         @UI.selectionField: [{ position: 25 }]
         @UI.lineItem: [{ position: 90, importance: #LOW, label: 'Group' }]
//         @Consumption.valueHelp: '_Group'
         _Text._Group.grp_text,
         _Text.grp_id,
         _Text.letter,
         
//         @UI.fieldGroup: [{ qualifier: 'Other' }]
         @UI: {lineItem: [{ position: 100, importance: #LOW } ] }
         @UI.multiLineText: true
         _root.notes,
        
         @UI.hidden: true
         _FakeConn.kz,
         @UI.hidden: true
         _FakeConn.ru,
         @UI.hidden: true
         _FakeConn.en,
         
         cast( ' ' as abap.char( 255 ) ) as photo_path,
         
    /* Associations */
         //_Schedule,
         _OrgAssign,
         _Text,
         _Text._Group,
         _FakeConn
         
} where  _root.sprps = ' '
