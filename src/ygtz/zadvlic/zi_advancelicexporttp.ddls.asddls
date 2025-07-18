@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View foradvancelicexport'
define view entity ZI_advancelicexportTP
  as projection on ZR_advancelicexportTP as advancelicexport
{
  key Bukrs,
  key Advancelic,
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
  _advancelicense : redirected to parent ZI_advancelicenseTP
  
}
