@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forZIRN'
@ObjectModel.semanticKey: [ 'Bukrs' ]
@Search.searchable: true
define root view entity ZC_ZIRNTP
  provider contract transactional_query
  as projection on ZR_ZIRNTP as ZIRN
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Bukrs,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Billingdocno,
  taxinvoiceno,
  Moduletype,
  Plant,
  Billingdate,
  Partycode,
  distributionchannel,
  distributionchanneldiscription,
  billingdocumenttype,
  Partyname,
  Irnno,
  Ackno,
  Ackdate,
  Signedinvoice,
  Signedqrcode,
  documentreferenceid,
  Irnstatus,
  Canceldate,
  Distance,
  Vehiclenum,
  Ewaybillno,
  Ewaydate,
  Ewaystatus,
  Ewaycanceldate,
  IRNCANCLEDATE,
  Ewayvaliddate,
  Transportername,
  Transportergstin,
  Grdate,
  Grno,
  Irncreatedby,
  Ewaycreatedby,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
