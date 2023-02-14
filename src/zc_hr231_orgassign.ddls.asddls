@AbapCatalog.sqlViewName: 'zvchr231_org_ass'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Org. Assignment'
@Search.searchable


@ZABAP.virtualEntity: 'ZCL_HR231_ORG_FILTER'

define view ZC_HR231_OrgAssign as select distinct from pa0001 as _main
association [0..1] to t001p on t001p.werks = _main.werks
                           and t001p.btrtl = _main.btrtl

association [0..1] to t501t on t501t.sprsl = $session.system_language
                           and t501t.persg = _main.persg    
                           
association [0..1] to t503t on t503t.sprsl = $session.system_language
                           and t503t.persk = _main.persk


association [0..1] to cskt  on cskt.spras = $session.system_language
                           and cskt.kokrs = _main.kokrs
                           and cskt.kostl = _main.kostl
                           and cskt.datbi = '99991231'

association [0..1] to t527x  on t527x.sprsl = $session.system_language
                            and t527x.orgeh = _main.orgeh
                            and t527x.endda >= _main.begda
                            and t527x.begda <= _main.endda
                            
association [0..1] to t528t  on t528t.sprsl = $session.system_language
                            and t528t.otype = 'S'
                            and t528t.plans = _main.plans
                            and t528t.endda >= _main.begda
                            and t528t.begda <= _main.endda
                            
association [0..1] to t513s  on t513s.sprsl = $session.system_language
                            and t513s.stell = _main.stell
                            and t513s.endda >= _main.begda
                            and t513s.begda <= _main.endda                      

{
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
    key pernr,
    key sprps,
    key endda,
    key begda,
    
        //bukrs,
        
        @UI.fieldGroup: [{ qualifier: 'OrgInfo', position: 10 }]
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
        ename,
        
        @UI.fieldGroup: [{ qualifier: 'OrgInfo', position: 20 }]
        @ObjectModel.text.element: ['werks_txt']
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
        werks,        
        t001p.btext as werks_txt,
        
        @UI.fieldGroup: [{ qualifier: 'OrgInfo', position: 30 }]
        @ObjectModel.text.element: ['persg_txt']
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
        persg,
        t501t.ptext as persg_txt,
        
        @UI.fieldGroup: [{ qualifier: 'OrgInfo', position: 40 }]
        @ObjectModel.text.element: ['persk_txt']        
        persk,        
        t503t.ptext as persk_txt,
        
        @UI.fieldGroup: [{ qualifier: 'OrgInfo', position: 50 }]
        @ObjectModel.text.element: ['kostl_txt']
        kostl,
        cskt.ktext as kostl_txt,
        
        @UI.fieldGroup: [{ qualifier: 'OrgInfo', position: 60 }]
        @ObjectModel.text.element: ['orgeh_txt']
        orgeh,
        t527x.orgtx as orgeh_txt,
        
        @UI.fieldGroup: [{ qualifier: 'OrgInfo', position: 70 }]
        @ObjectModel.text.element: ['plans_txt']
        plans,
        t528t.plstx as plans_txt,
        
        @UI.fieldGroup: [{ qualifier: 'OrgInfo', position: 80 }]
        @ObjectModel.text.element: ['stell_txt']
        stell,
        t513s.stltx as stell_txt   
}