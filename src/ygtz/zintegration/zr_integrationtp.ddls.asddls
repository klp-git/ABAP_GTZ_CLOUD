@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forIntegration'
define root view entity ZR_IntegrationTP
  as select from ZINTEGRATION as Integration
{
  key INTGMODULE as Intgmodule,
  INTGPATH as Intgpath,
  CREATED_BY as CreatedBy,
  CREATED_AT as CreatedAt,
  LAST_CHANGED_BY as LastChangedBy,
  LAST_CHANGED_AT as LastChangedAt,
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt
  
}
