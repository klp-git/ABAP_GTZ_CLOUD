@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'i_operationalacctgdocitem CDS'
@Metadata.ignorePropagatedAnnotations: true
@UI.headerInfo: {typeName: 'RCM TAX INVOICE PRINT'}
@ObjectModel.usageType: {
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity ZCDS_RCM
  as select from I_OperationalAcctgDocItem as a
    inner join   zcds_accotdocumentjournal as b on  a.AccountingDocument     = b.AccountingDocument
                                                and a.GLAccount              = b.GLAccount
                                                and a.CompanyCode            = b.CompanyCode
                                                and a.AccountingDocumentItem = b.AccountingDocumentItem
                                                and a.FiscalYear             = b.FiscalYear

    inner join   I_JournalEntry            as c on  a.AccountingDocument = c.AccountingDocument
                                                and a.CompanyCode        = c.CompanyCode
                                                and a.FiscalYear         = c.FiscalYear

{
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 1 }]
      @UI.lineItem: [{ position: 1 }]
      @EndUserText.label: 'Journal Entry No'
  key a.AccountingDocument,

      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 2 }]
      @UI.lineItem: [{ position: 2, label: 'Company Code' }]
  key a.CompanyCode,

      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 3 }]
      @UI.lineItem: [{ position: 3, label: 'Fiscal Year' }]
  key a.FiscalYear,

      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 4 }]
      @UI.lineItem: [{ position: 4, label: 'Journal Entry Type' }]
      a.AccountingDocumentType,

      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 5 }]
      @UI.lineItem: [{ position: 5, label: 'Posting Date' }]
      min(a.PostingDate)                as PostingDate, -- Select the earliest PostingDate

      @Semantics.amount.currencyCode: 'curr'
      @UI.lineItem: [{ position: 7, label: 'Amount' }]
      sum(a.AbsoluteAmountInCoCodeCrcy) as AbsoluteAmountInCoCodeCrcy, -- Aggregating Amount

      a.CompanyCodeCurrency             as curr,

      @Search.defaultSearchElement: true
      @UI.lineItem: [{ position: 8, label: 'Supplier' }]
      a.Supplier,

      @Search.defaultSearchElement: true
      @UI.lineItem: [{ position: 9, label: 'Clearing Date' }]
      a.ClearingDate,

      @Search.defaultSearchElement: true
      @UI.lineItem: [{ position: 10, label: 'Clearing Journal Entry' }]
      a.ClearingJournalEntry,

      @Search.defaultSearchElement: true
      @UI.lineItem: [{ position: 11, label: 'MIRO No.' }]
      a.OriginalReferenceDocument,

      @Search.defaultSearchElement: true
      @UI.lineItem: [{ position: 12, label: 'REVERSE No.' }]

      c.ReverseDocument
}
where
  (
       a.AccountingDocumentType       = 'RE'
    or a.AccountingDocumentType       = 'KR'
    or a.AccountingDocumentType       = 'UR'
  )
  and  a.AccountingDocumentItemType   = 'T'
  and(
       a.TransactionTypeDetermination = 'JRC'
    or a.TransactionTypeDetermination = 'JRS'
    or a.TransactionTypeDetermination = 'JRI'
    or a.TransactionTypeDetermination = 'JRU'
  )
group by
  a.AccountingDocument,
  a.CompanyCode,
  a.FiscalYear,
  a.AccountingDocumentType,
  a.CompanyCodeCurrency,
  a.Supplier,
  a.ClearingDate,
  a.ClearingJournalEntry,
  a.OriginalReferenceDocument,
  c.ReverseDocument
  
  
  
  
  
  
