@AbapCatalog.sqlViewName: 'ZR_MATERIAL_CDS'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'Material Trade Technical CDS'
define view ZR_MATERIAL_TT as select from zmaterial_table
{
  key mat        as mat,
  trade_name     as Tradename,
  technical_name as Technicalname,
  cas_number     as Casnumber
}
