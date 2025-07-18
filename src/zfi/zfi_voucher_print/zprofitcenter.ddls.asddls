@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZPROFITCENTER'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZPROFITCENTER
  as select from I_ProfitCenterText
{
  key Language,
  key ControllingArea,
  key ProfitCenter,
  key ValidityEndDate,
      ProfitCenterName,
      /* Associations */
      _ControllingArea,
      _ControllingAreaText,
      _Language
}
