@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View foradvancelicense'
define root view entity ZR_advancelicenseTP
  as select from ZADVLIC as advancelicense
  composition [0..*] of ZR_advancelicexportTP as _advancelicexport
  composition [0..*] of ZR_advancelicimport01TP as _advancelicimport
{
  key BUKRS as Bukrs,
  key ADVANCELIC as Advancelic,
  LICDATE as Licdate,
  FILENO as Fileno,
  IMPORTVALIDUPTO as Importvalidupto,
  EXPORTVALIDUPTO as Exportvalidupto,
  CUSTOMSBONDNO as Customsbondno,
  BONDDATE as Bonddate,
  CURRENCYCODE as Currencycode,
  IMPORTEXCHANGERATE as Importexchangerate,
  EXPORTEXCHANGERATE as Exportexchangerate,
  IMPORTCIFINFC as Importcifinfc,
  EXPORTFOBINFC as Exportfobinfc,
  TOTALEXPORTQTY as Totalexportqty,
  VALUEADDITIONPERC as Valueadditionperc,
  IMPORTCIFININR as Importcifininr,
  EXPORTFOBININR as Exportfobininr,
  @Semantics.user.createdBy: true
  CREATED_BY as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  CREATED_AT as CreatedAt,
  LAST_CHANGED_BY as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LAST_CHANGED_AT as LastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  _advancelicexport,
  _advancelicimport
  
}
