@AbapCatalog.viewEnhancementCategory: [#NONE]
@EndUserText.label: 'I_BillingDocument'
@Search.searchable: false
//@ObjectModel.query.implementedBy: 'ABAP:ZPUR_PAY_SC_VOUCHER'
@UI.headerInfo: {typeName: 'ZCL_CDSTAXINVOICE'}
define root view entity ZCL_CDSTAXINVOICE as select from  I_BillingDocument 
{
    @Search.defaultSearchElement: true
       @UI.selectionField   : [{ position:1 }]
       @UI.lineItem   : [{ position:1, label:'BillingDocument' }]
       //@EndUserText.label: 'Accounting document'
  key  BillingDocument,


       @Search.defaultSearchElement: true
       @UI.selectionField   : [{ position:2 }]
       @UI.lineItem   : [{ position:2, label:'FiscalYear' }]
       // @EndUserText.label: 'Fiscal Document'
  key  FiscalYear,


       @Search.defaultSearchElement: true
       @UI.selectionField   : [{ position:3 }]
       @UI.lineItem   : [{ position:3, label:'CompanyCode' }]
       // @EndUserText.label: 'Company Code'
  key  CompanyCode  
}
