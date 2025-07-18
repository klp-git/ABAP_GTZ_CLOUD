@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forSalesTrend'
@ObjectModel.semanticKey: [ 'Bukrs' ]
@Search.searchable: true
define root view entity ZC_SalesTrendTP
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_SalesTrendTP as SalesTrend
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Bukrs,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Plant,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Trendmonth,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Productcode,
  Productdesc,
  Quantityunit,
  Trenddate,
  Salesqty,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
