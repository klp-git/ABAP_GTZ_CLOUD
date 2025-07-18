//@AbapCatalog.sqlViewName: 'ZDD_COAS'
//@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@EndUserText.label: 'cds view for coa report'
//@Metadata.ignorePropagatedAnnotations: true


@EndUserText.label: 'i_operationalacctgdocitem CDS'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZPUR_PAY_SC_VOUCHER'
@UI.headerInfo: {typeName: 'ZPUR_PAY_VOUCHER'}
define view entity ZPUR_PAY_CD_VOUCHER
  as select from I_OperationalAcctgDocItem
{
       @Search.defaultSearchElement: true
       @UI.selectionField   : [{ position:1 }]
       @UI.lineItem   : [{ position:1, label:'AccountingDocument' }]
       //@EndUserText.label: 'Accounting document'
  key  AccountingDocument,


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
