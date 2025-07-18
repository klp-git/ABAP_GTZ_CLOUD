extend view entity C_SalesOrderManage with
{
  @EndUserText.label: 'Advance Lic'
  @Semantics.text: true
  @UI.dataFieldDefault: [{hidden: false}]
  @UI.identification: [{hidden: false}]
  @UI.lineItem: [{hidden: false}]
  @Consumption.valueHelpDefinition: [{entity: {name: 'ZR_ADVLICCDS', element: 'advancelic' }}]  
  SalesOrder.ZZ_ADVLIC_SDH as ZZ_ADVLIC_SDH
  
}
