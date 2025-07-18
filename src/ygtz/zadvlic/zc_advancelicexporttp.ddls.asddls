@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View foradvancelicexport'
@ObjectModel.semanticKey: [ 'Advancelicitemno' ]
@Search.searchable: true
define view entity ZC_advancelicexportTP
  as projection on ZR_advancelicexportTP as advancelicexport
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
  Fobvalue,
  Fobvalueinr,
  Soqty,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt,
  _advancelicense : redirected to parent ZC_advancelicenseTP
  
}
