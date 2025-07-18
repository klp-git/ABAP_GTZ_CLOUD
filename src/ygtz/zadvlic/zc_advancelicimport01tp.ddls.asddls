@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View foradvancelicimport'
@ObjectModel.semanticKey: [ 'Advancelicitemno' ]
@Search.searchable: true
define view entity ZC_advancelicimport01TP
  as projection on ZR_advancelicimport01TP as advancelicimport
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Bukrs,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Advancelic,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Advancelicitemno,
  Productcode,
  Productdesc,
  Hscode,
  Quantityunit,
  Licenseqty,
  Cifvalue,
  Cifvalueinr,
  Poqty,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt,
  _advancelicense : redirected to parent ZC_advancelicenseTP
  
}
