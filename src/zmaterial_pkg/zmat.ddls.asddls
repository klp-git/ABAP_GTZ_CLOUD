@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'zmat'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zmat as select from zmat_ta
{
      key mat as MaterialCode,
          trade_name as TradeName,
          quantity_multiple as QuantityInMultiple,
             technical_name as TechnicalName,
             cas_number as CASNumber
    
}
