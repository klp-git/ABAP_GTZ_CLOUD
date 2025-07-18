@AbapCatalog.sqlViewName: 'ZR_ADVLICIMP_CDS'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Advance License Import CDS'
@Metadata.ignorePropagatedAnnotations: true
define view ZR_ADVLICIMPORT as select from zadvlicimport
{
    key bukrs   as Bukrs,
    key advancelic as Advancelic,
    key advancelicitemno as Advancelicitemno,
    productcode as Productcode,
    productdesc as Productdesc,
    hscode as Hscode,
    quantityunit as Quantityunit,
    licenseqty as Licenseqty,
    cifvalue as Cifvalue,
    cifvalueinr as Cifvalueinr,
    poqty as Poqty
}
