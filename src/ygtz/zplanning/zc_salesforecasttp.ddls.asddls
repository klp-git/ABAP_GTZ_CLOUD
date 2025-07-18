@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forSalesForecast'
@ObjectModel.semanticKey: [ 'Bukrs' ]
@Search.searchable: true
define root view entity ZC_SalesForecastTP
  provider contract transactional_query
  as projection on ZR_SalesForecastTP as SalesForecast
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Bukrs,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Plant,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Forecastmonth,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Productcode,
  Productdesc,
  Quantityunit,
  Forecastdate,
  Forecastqty,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
