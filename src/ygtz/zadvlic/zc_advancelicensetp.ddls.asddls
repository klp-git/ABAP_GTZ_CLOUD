@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View foradvancelicense'
@ObjectModel.semanticKey: [ 'Bukrs' ]
@Search.searchable: true
define root view entity ZC_advancelicenseTP
  provider contract transactional_query
  as projection on ZR_advancelicenseTP as advancelicense
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Bukrs,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Advancelic,
  Licdate,
  Fileno,
  Importvalidupto,
  Exportvalidupto,
  Customsbondno,
  Bonddate,
  Currencycode,
  Importexchangerate,
  Exportexchangerate,
  Importcifinfc,
  Exportfobinfc,
  Totalexportqty,
  Valueadditionperc,
  Importcifininr,
  Exportfobininr,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt,
  _advancelicexport : redirected to composition child ZC_advancelicexportTP,
  _advancelicimport : redirected to composition child ZC_advancelicimport01TP
  
}
