@EndUserText.label: 'I_OperationalAcctgDocItem CDS'
@Search.searchable: false
@AccessControl.authorizationCheck: #NOT_ALLOWED
//@ObjectModel.query.implementedBy: 'ABAP:ZCL_ACCT_PRINT'
@UI.headerInfo: {typeName: 'VOUCHER PRINT'}
define view entity ZCDS_ACCO
  as select from I_OperationalAcctgDocItem as a
    inner join   zcds_accotdocumentjournal as b on  a.AccountingDocument     = b.AccountingDocument
                                                and a.GLAccount              = b.GLAccount
                                                and a.CompanyCode            = b.CompanyCode
                                                and a.AccountingDocumentItem = b.AccountingDocumentItem
                                                and a.FiscalYear             = b.FiscalYear
{
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:1 }]
      @UI.lineItem   : [{ position:1, label:'Accounting Document' }]
  key a.AccountingDocument,
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:2 }]
      @UI.lineItem   : [{ position:2, label:'Company Code' }]
  key a.CompanyCode,

      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:3 }]
      @UI.lineItem   : [{ position:3, label:'Fiscal Year' }]
  key a.FiscalYear,
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:4 }]
      @UI.lineItem   : [{ position:4, label:'Accounting Document Item' }]
  key a.AccountingDocumentItem,

      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:4.5 }]
      @UI.lineItem   : [{ position:4.5, label:'Posting Date' }]
      a.PostingDate,

      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:5}]
      @UI.lineItem   : [{ position:5, label:'Accounting DocumentType' }]
      a.AccountingDocumentType,

      @UI.lineItem   : [{ position:5.2, label:'Document Item Text' }]
      a.DocumentItemText,

      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:5.5}]
      @UI.lineItem   : [{ position:5.5, label:' Document Date' }]
      a.DocumentDate,
      @UI.lineItem   : [{ position:6, label:'Clearing Date' }]
      a.ClearingDate,
      @UI.selectionField   : [{ position:8}]
      @UI.lineItem   : [{ position:8, label:'GL Account' }]
      a.GLAccount,
      a.Customer,
      a.Supplier,

      @UI.lineItem   : [{ position:10, label:'Transactional Type Determination' }]
      a.TransactionTypeDetermination,
      @Semantics.amount.currencyCode: 'curr'
      @UI.lineItem   : [{ position:9, label:'Amount In CompanyCode Currency' }]
      a.AmountInCompanyCodeCurrency,
      a.CompanyCodeCurrency as curr,
      b.IsReversal,
      b.IsReversed
      ////      /* Associations */
      //      a._CompanyCode,
      //      a._CompanyCodeCurrency,
      //      a._Customer,
      //      a._CustomerCompany,
      //      a._CustomerText,
      //      a._FiscalYear,
      //      a._GLAccountInCompanyCode,
      //      a._JournalEntry,
      //      @ObjectModel.sort.enabled: false
      //      a._JournalEntryItemOneTimeData,
      //      /*_OneTimeAccountBP,*/
      //      @ObjectModel.filter.enabled: false
      //      a._Supplier,
      //      a._SupplierCompany,
      //      a._SupplierText

}
