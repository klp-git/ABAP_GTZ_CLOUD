@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forSalesTrend'
define root view entity ZR_SalesTrendTP
  as select from ZSALESTREND as SalesTrend
{
  key BUKRS as Bukrs,
  key PLANT as Plant,
  key TRENDMONTH as Trendmonth,
  key PRODUCTCODE as Productcode,
  PRODUCTDESC as Productdesc,
  QUANTITYUNIT as Quantityunit,
  TRENDDATE as Trenddate,
  SALESQTY as Salesqty,
  @Semantics.user.createdBy: true
  CREATED_BY as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  CREATED_AT as CreatedAt,
  LAST_CHANGED_BY as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LAST_CHANGED_AT as LastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt
  
}
