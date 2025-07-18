@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'Interface View Data Definition CDS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_DD_MAT as select from zmaterial_table
{
    key mat as Mat,
    trade_name as TradeName,
    technical_name as TechnicalName,
    cas_number as CASNumber,
    quantity_multiple as QuantityMultiple
    

}
