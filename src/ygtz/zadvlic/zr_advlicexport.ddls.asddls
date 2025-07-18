@AbapCatalog.sqlViewName: 'ZR_ADVLICEXP_CDS'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Advance License Export CDS'
@Metadata.ignorePropagatedAnnotations: true
define view ZR_ADVLICEXPORT as select from zadvlicexport
{
    key bukrs as Bukrs,
    key advancelic as AdvanceLic,
    key advancelicitemno as Advancelicitemno,
    productcode as Productcode,
    productdesc as Productdesc,
    hscode as Hscode,
    quantityunit as Quantityunit,
    licenseqty as Licenseqty,
    fobvalue as Fobvalue,
    fobvalueinr as Fobvalueinr,
    soqty as Soqty
}
