@AbapCatalog.sqlViewName: 'ZSALES_FORVIEW'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data Defination for Sales Forcast'
define view ZSALES_FOR_DD as select from zsales_for_table 
  {
  key bukrs             as Bukrs ,
  key plant             as Plant ,
  key forecastmonth     as Forecastmonth,
  key productcode       as Productcode,
  productdesc           as Productdesc,
  quantityunit          as Quantityunit,
  forecastdate          as Forecastdate,
  forecastqty           as Forecastqty,
  created_by            as created_by,
  created_at            as created_at,
  last_changed_by       as Last_changed_by,
  last_changed_at       as last_changed_at,
  local_last_changed_at as local_last_changed_at
    
}
