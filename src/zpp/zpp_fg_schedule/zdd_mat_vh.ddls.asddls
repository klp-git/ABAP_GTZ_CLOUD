@AbapCatalog.sqlViewName: 'ZDDMATVH'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help for fg material'
define view zdd_mat_vh
  as select from    I_Product     as a
    left outer join I_ProductText as b on  a.Product  = b.Product
                                       and b.Language = 'E'
{
  key a.Product,
      b.ProductName
}
where
  a.ProductType = 'ZFGC'
