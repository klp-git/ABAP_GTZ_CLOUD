@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_SAMPLESCHEDULE
  provider contract transactional_query
  as projection on ZR_SAMPLESCHEDULE
{
  key Plant,
  key Storagelocation,
  key Productcode,
  key Batch,
  key Testnum,
  Productdesc,
  Scheduledate,
  Remarks,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
