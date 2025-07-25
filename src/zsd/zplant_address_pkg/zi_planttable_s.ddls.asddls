@EndUserText.label: 'Plant table Singleton'
@AccessControl.authorizationCheck: #NOT_ALLOWED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'PlantTableAll'
  }
}
define root view entity ZI_PlantTable_S
  as select from I_Language
    left outer join I_CstmBizConfignLastChgd on I_CstmBizConfignLastChgd.ViewEntityName = 'ZI_PLANTTABLE'
  association [0..*] to I_ABAPTransportRequestText as _I_ABAPTransportRequestText on $projection.TransportRequestID = _I_ABAPTransportRequestText.TransportRequestID
  composition [0..*] of ZI_PlantTable as _PlantTable
{
  @UI.facet: [ {
    id: 'ZI_PlantTable', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'Plant table', 
    position: 1 , 
    targetElement: '_PlantTable'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _PlantTable,
  @UI.hidden: true
  I_CstmBizConfignLastChgd.LastChangedDateTime as LastChangedAtMax,
  @ObjectModel.text.association: '_I_ABAPTransportRequestText'
  @UI.identification: [ {
    position: 2 , 
    type: #WITH_INTENT_BASED_NAVIGATION, 
    semanticObjectAction: 'manage'
  } ]
  @Consumption.semanticObject: 'CustomizingTransport'
  cast( '' as sxco_transport) as TransportRequestID,
  _I_ABAPTransportRequestText
  
}
where I_Language.Language = $session.system_language
