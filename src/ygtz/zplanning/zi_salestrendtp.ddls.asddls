@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forSalesTrend'
define root view entity ZI_SalesTrendTP
  provider contract TRANSACTIONAL_INTERFACE
  as projection on ZR_SalesTrendTP as SalesTrend
{
  key Bukrs,
  key Plant,
  key Trendmonth,
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
