@Metadata.allowExtensions: true
@EndUserText.label: 'Plant Address Details Page'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZAPPC_TABLE_PLANTAPP
  provider contract transactional_query
  as projection on ZAPPR_TABLE_PLANTAPP
{
  key CompCode,
  key PlantCode,
  PlantName1,
  PlantName2,
  Address1,
  Address2,
  Address3,
  City,
  District,
  StateCode1,
  StateCode2,
  StateName,
  Pin,
  Country,
  CinNo,
  GstinNo,
  PanNo,
  TanNo,
  Remark1,
  Remark2,
  Remark3,
  CreatedBy,
  CreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  LastChangedAt
  
}
