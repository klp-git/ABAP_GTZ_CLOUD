//@AbapCatalog.sqlViewName: 'ZPLANT'
//@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PLANT'
define root view  entity YPLANT_YPACK as select from  I_Plant
 {
    
   key Plant,
    PlantName 
//    ValuationArea,
//    PlantCustomer,
//    PlantSupplier,
//    FactoryCalendar,
//    DefaultPurchasingOrganization,
//    SalesOrganization
//    AddressID,
//    PlantCategory,
//    DistributionChannel,
//    Division,
//    Language,
//    IsMarkedForArchiving,
//    /* Associations */
//    _Address,
//    _Customer,
//    _MRPArea,
//    _OrganizationAddress,
//    _PlantCategoryText,
//    _ResponsiblePurchaseOrg,
//    _Supplier,
//    _ValuationArea
}  group by 
    Plant,
    PlantName 
