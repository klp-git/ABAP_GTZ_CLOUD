@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View foradvancelicimport'
define view entity ZI_advancelicimport01TP
  as projection on ZR_advancelicimport01TP as advancelicimport
{
  key Bukrs,
  key Advancelic,
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
  _advancelicense : redirected to parent ZI_advancelicenseTP
  
}
