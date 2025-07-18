@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'interface entity for Journal'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@UI:{
headerInfo:{typeName: 'Journal Entry Data',typeNamePlural: 'Journal Entrys Data'}
}
define root view entity zcds_Journal_Entry
  as select from I_OperationalAcctgDocItem  
{
      @UI.selectionField:[{ position: 1 }]
      @UI.lineItem     : [{ position: 1, label: 'Journal Entry No' },{
       type :#FOR_ACTION , dataAction: 'print',label: 'Print PDF'}]
      @EndUserText.label: 'Journal Entry No'
  key AccountingDocument          as JOURNAL_ENTRY_NO,
//      @UI.selectionField:[{ position: 7 }]
//      @UI.lineItem     : [{ position: 7, label: 'Line Item' }]
//      @EndUserText.label: 'Journal Line Item'
  key AccountingDocumentItem      as LineItem,
      @UI.selectionField:[{ position: 2 }]
      @UI.lineItem     : [{ position: 2, label: 'Journal Entry Type' }]
      @EndUserText.label: 'Journal Entry Type'
      AccountingDocumentType      as JOURNAL_ENTRY_TY,
      @UI.selectionField:[{ position: 3 }]
      @UI.lineItem     : [{ position: 3, label: 'Journal Entry Date' }]
      @EndUserText.label: 'Journal Entry Date'
      DocumentDate                as JOURNAL_ENTRY_DT,
      @UI.selectionField:[{ position: 4 }]
      @UI.lineItem     : [{ position: 4, label: 'Amount' }]
      @EndUserText.label: 'Amount'
      @Semantics.amount.currencyCode: 'currency'
      AmountInTransactionCurrency as Amount,
      //     @UI.selectionField:[{ position: 5 }]
      //   @UI.lineItem     : [{ position: 5, label: 'Currency' }]
      //   @EndUserText.label: 'Currency'
      CompanyCodeCurrency         as currency,
      @UI.selectionField:[{ position: 6 }]
      @UI.lineItem     : [{ position: 6, label: 'Company Code' }]
      @EndUserText.label: 'Company Code'
      CompanyCode                 as Companycode,

      /* Associations */
      _AccountingDocumentType,
      _AccountingDocumentTypeText,
      _CompanyCode
}
