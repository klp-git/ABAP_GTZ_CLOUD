@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_SAMPLESCHEDULE
  as select from zsampleschedule
{
  key plant as Plant,
  @EndUserText.label: 'Storage Location'
  key storagelocation as Storagelocation,
  @EndUserText.label: 'Product'
  key productcode as Productcode,
  @EndUserText.label: 'Batch'
  key batch as Batch,
  @EndUserText.label: 'Test Number'
  key testnum as Testnum,
  @EndUserText.label: 'Product Description'
  productdesc as Productdesc,
  @EndUserText.label: 'Schedule Date'
  scheduledate as Scheduledate,
  remarks as Remarks,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}
