@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forIntegration'
define root view entity ZI_IntegrationTP
  provider contract TRANSACTIONAL_INTERFACE
  as projection on ZR_IntegrationTP as Integration
{
  key Intgmodule,
  Intgpath,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
