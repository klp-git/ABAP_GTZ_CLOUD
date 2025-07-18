@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View foradvancelicexport'
define view entity ZR_advancelicexportTP
  as select from ZADVLICEXPORT as advancelicexport
  association to parent ZR_advancelicenseTP as _advancelicense on $projection.Bukrs = _advancelicense.Bukrs and $projection.Advancelic = _advancelicense.Advancelic
{
  key BUKRS as Bukrs,
  key ADVANCELIC as Advancelic,
  key ADVANCELICITEMNO as Advancelicitemno,
  PRODUCTCODE as Productcode,
  PRODUCTDESC as Productdesc,
  HSCODE as Hscode,
  QUANTITYUNIT as Quantityunit,
  LICENSEQTY as Licenseqty,
  FOBVALUE as Fobvalue,
  FOBVALUEINR as Fobvalueinr,
  SOQTY as Soqty,
  CREATED_BY as CreatedBy,
  CREATED_AT as CreatedAt,
  LAST_CHANGED_BY as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LAST_CHANGED_AT as LastChangedAt,
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  _advancelicense
  
}
