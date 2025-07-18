@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'cds for journal entry data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@UI:{
headerInfo:{typeName: 'Journal Entry Data',typeNamePlural: 'Journal Entrys Data'}
}
define root view entity zcds_Journal_Ent
  as select from I_OperationalAcctgDocItem
{
      @UI.selectionField:[{ position: 1 }]
      @UI.lineItem     : [{ position: 1, label: 'Company Code' }]
      @EndUserText.label: 'Company Code'
  key CompanyCode                 as CompanyCode,
      @UI.selectionField:[{ position: 2 }]
      @UI.lineItem     : [{ position: 2, label: 'Journal Entry No' },{
      type :#FOR_ACTION , dataAction: 'print',label: 'Print PDF'}]
      @EndUserText.label: 'Journal Entry No'
  key AccountingDocument          as AccountingDocument,
      @UI.selectionField:[{ position: 3 }]
      @UI.lineItem     : [{ position: 3, label: 'Fiscal Year' }]
      @EndUserText.label: 'Fiscal Year'
  key FiscalYear                  as FiscalYear,
      @UI.selectionField:[{ position: 4 }]
      @UI.lineItem     : [{ position: 4, label: 'Line Item' }]
      @EndUserText.label: 'Journal Line Item'
  key AccountingDocumentItem      as AccountingDocumentItem,
      @UI.selectionField:[{ position: 5 }]
      @UI.lineItem     : [{ position: 5, label: 'Journal Entry Type' }]
      @EndUserText.label: 'Journal Entry Type'
      AccountingDocumentType      as AccountingDocumentType,
      @UI.selectionField:[{ position: 6 }]
      @UI.lineItem     : [{ position: 6, label: 'Journal Entry Date' }]
      @EndUserText.label: 'Journal Entry Date'
      DocumentDate                as DocumentDate,
      @UI.selectionField:[{ position: 7 }]
      @UI.lineItem     : [{ position: 7, label: 'Amount' }]
      @EndUserText.label: 'Amount'
      @Semantics.amount.currencyCode: 'currency'
      AmountInTransactionCurrency as AmountInTransactionCurrency,
      CompanyCodeCurrency         as currency,

      /* Associations */
      _AccountingDocumentType,
      _AccountingDocumentTypeText,
      _CompanyCode,
      _CompanyCodeCurrency,
      _FiscalYear,
      _JournalEntry,
      _JournalEntryItemOneTimeData
}
