@AbapCatalog.sqlViewName: 'ZR_ADVLIC_CDS'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Advance License CDS'
@Metadata.ignorePropagatedAnnotations: true
define view ZR_ADVLICCDS as select from zadvlic
{
    key bukrs as Bukrs,
    key advancelic as Advancelic,
    licdate as Licdate,
    fileno as Fileno,
    importvalidupto as Importvalidupto,
    exportvalidupto as Exportvalidupto,
    customsbondno as Customsbondno,
    bonddate as Bonddate,
    currencycode as Currencycode,
    importexchangerate as Importexchangerate,
    exportexchangerate as Exportexchangerate,
    importcifinfc as Importcifinfc,
    exportfobinfc as Exportfobinfc,
    totalexportqty as Totalexportqty,
    valueadditionperc as Valueadditionperc,
    importcifininr as Importcifininr,
    exportfobininr as Exportfobininr
}
