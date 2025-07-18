@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View foradvancelicense'
define root view entity ZI_advancelicenseTP
  provider contract transactional_interface
  as projection on ZR_advancelicenseTP as advancelicense
{
  key Bukrs,
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
  _advancelicexport : redirected to composition child ZI_advancelicexportTP,
  _advancelicimport : redirected to composition child ZI_advancelicimport01TP
  
}
