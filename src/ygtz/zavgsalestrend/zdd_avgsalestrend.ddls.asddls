@AbapCatalog.sqlViewName: 'ZSALESTRENDSQL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'average sales trend data definition'
@Metadata.ignorePropagatedAnnotations: true
define view zdd_avgsalestrend as select from zavgsalestrend
{
  //key bukrs            as Bukrs,
  key plant            as plant , 
  key trendmonth       as Trendmonth, 
  key productcode      as Productcode,   
  productdesc          as Productdesc,
  quantityunit         as Quantityunit, 
  trenddate            as Trenddate,     
  salesqty             as Salesqty, 
  created_by           as Created_by,    
  created_at           as Created_at,
  last_changed_by      as Last_changed_by,
  last_changed_at      as Last_changed_at
}
