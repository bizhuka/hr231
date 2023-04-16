@AbapCatalog.sqlViewName: 'zvchr231_emg_rol'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Emergency roles of Personnel Number'
@VDM.viewType: #CONSUMPTION
@Search.searchable


@ObjectModel: {
    transactionalProcessingEnabled: true,
//    writeActivePersistence: 'PA9018',
//    compositionRoot: true,
//    createEnabled: true,
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

define view ZC_HR231_Emergency_Role as select distinct from pa9018 as _root                                                             
  association [0..1] to ZC_HR231_EmergeRoleText as _Text      on _Text.eid          = _root.emergrole_id
  
  association [0..1] to ZC_HR231_Defaults       as _Defaults  on _Defaults.pernr    = _root.pernr  
  
  // Fake connection SM30 tab
  association [0..*] to ZC_HR231_DefaultsEdit   as _DefaultsEdit on _DefaultsEdit.pernr        = _root.pernr
                                                                and _DefaultsEdit.emergrole_id = '77'
{
     @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
     @UI.lineItem: [{ position: 10, importance: #HIGH }]
     @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
     @Consumption.valueHelp: '_Defaults'
     @UI.fieldGroup: [{ qualifier: 'GeneralInfo', position: 10 }]     
     key _root.pernr,
     
     
     @UI.lineItem: [{ position: 20, importance: #HIGH }]
     @UI.selectionField: [{ position: 10 }]
     @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false, mandatory: true }
     @EndUserText.label: 'Period'
     @UI.fieldGroup: [{ qualifier: 'GeneralInfo', position: 20 }]     
     key _root.begda,
     
     @UI.lineItem: [{ position: 30, importance: #HIGH }]
//     @UI.selectionField: [{ position: 20 }]
     @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
     @UI.fieldGroup: [{ qualifier: 'GeneralInfo', position: 22 }]     
     key _root.endda,
          
         @UI.selectionField: [{ position: 30 }]
         @Consumption.valueHelp: '_Text'
         @ObjectModel.text.element: ['role_text']
         //@UI.lineItem: [{ position: 70, importance: #HIGH, label: 'Emergency role' }]
         @UI.fieldGroup: [{ qualifier: 'GeneralInfo', position: 40 }]         
     key _root.emergrole_id as eid,
         _Text.text as role_text,
         
         @UI.lineItem: [{ position: 16, importance: #LOW, label: 'Group' }]   
         @UI.selectionField: [{ position: 20 }]
         @ObjectModel.text.element: ['grp_text']
         @UI.textArrangement: #TEXT_ONLY 
         @Consumption.valueHelp: '_Group'         
         _Text.grp_id,         
         @UI.hidden: true
         _Text._Group.grp_text,

         
          @UI.lineItem: [{ position: 15, importance: #HIGH }]
          @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
          @UI.fieldGroup: [{ qualifier: 'GeneralInfo', position: 15 }]          
          _Defaults.ename,
          @UI.lineItem: [{ position: 60, importance: #LOW }]
          _Defaults._OrgAssign._Position._Text.plstx as plans_txt,
          
         _Text.letter,
         _Text.color,
         
//         @UI.fieldGroup: [{ qualifier: 'Other' }]
         @UI: {lineItem: [{ position: 100, importance: #LOW } ] }
         @UI.multiLineText: true
         @UI.fieldGroup: [{ qualifier: 'GeneralInfo', position: 40 }]
         _root.notes,
        
         @UI.hidden: true
         _Defaults.kz,
         @UI.hidden: true
         _Defaults.ru,
         @UI.hidden: true
         _Defaults.en,
         
         //cast( ' ' as abap.char( 255 ) ) as photo_path,
        concat( concat('../../../../../opu/odata/sap/ZC_PY000_REPORT_CDS/ZC_PY000_PernrPhoto(pernr=''', _root.pernr),
                       ''')/$value')  as photo_path,
         
    /* Associations */
         _Text,
         _Text._Group as _Group,
         _Defaults,
         _DefaultsEdit
         
} where  _root.sprps = ' '
