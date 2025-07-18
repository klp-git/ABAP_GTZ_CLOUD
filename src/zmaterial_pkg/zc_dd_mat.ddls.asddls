@AbapCatalog.viewEnhancementCategory: [#NONE]
@EndUserText.label: 'Consumption View for Interface view DD'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_ALLOWED
@Search.searchable: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZC_DD_Mat 
as projection on ZI_DD_MAT as Material 

//as select from ZI_DD_MAT
{
    @EndUserText.label: 'Material'
     @Search.defaultSearchElement: true
    key Mat,
    
    
    
     @EndUserText.label: 'Trade Name'
      @Search.defaultSearchElement: true
    TradeName,
    
    @EndUserText.label: 'Technical Name'
      @Search.defaultSearchElement: true    
    TechnicalName,
    
     @EndUserText.label: 'CAS Number'
      @Search.defaultSearchElement: true    
    CASNumber,
    
     @EndUserText.label: 'Quantity Multiple'
      @Search.defaultSearchElement: true    
    QuantityMultiple
    

}
