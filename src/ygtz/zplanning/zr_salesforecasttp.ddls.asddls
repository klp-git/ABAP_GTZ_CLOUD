@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forSalesForecast'
define root view entity ZR_SalesForecastTP
  as select from zsalesforecast as SalesForecast
{
  key bukrs as Bukrs,
  key plant as Plant,
  key forecastmonth as Forecastmonth,
  key productcode as Productcode,
  productdesc as Productdesc,
  quantityunit as Quantityunit,
  forecastdate as Forecastdate,
  forecastqty as Forecastqty,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}
