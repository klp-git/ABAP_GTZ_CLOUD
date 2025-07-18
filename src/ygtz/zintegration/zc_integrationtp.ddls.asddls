@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forIntegration'
@ObjectModel.semanticKey: [ 'Intgmodule' ]
@Search.searchable: true
define root view entity ZC_IntegrationTP
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_IntegrationTP as Integration
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Intgmodule,
  Intgpath,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
