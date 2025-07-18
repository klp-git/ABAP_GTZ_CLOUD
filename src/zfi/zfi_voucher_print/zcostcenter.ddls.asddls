@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZCOSTcENTER'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZCOSTcENTER
  as select from I_CostCenterText
{
  key CostCenter,
  key ControllingArea,
  key Language,
  key ValidityEndDate,
      CostCenterName,
      /* Associations */
      _ControllingArea,
      _ControllingAreaText,
      _Language
}
