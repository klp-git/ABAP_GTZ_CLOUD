@EndUserText.label: 'i_operationalacctgdocitem CDS'
@Search.searchable: false
//@ObjectModel.query.implementedBy: 'ABAP:ZCL_CN_DN_SCREEN_CLASS'
@UI.headerInfo: {typeName: 'cn_dn PRINT'}
define view entity zcds_FI_CN_DN as select  from I_OperationalAcctgDocItem  as a
    inner join I_JournalEntry as b 
        on a.AccountingDocument = b.AccountingDocument
        and a.CompanyCode = b.CompanyCode
        and a.FiscalYear = b.FiscalYear
{
    @Search.defaultSearchElement: true
    @UI.selectionField : [{ position:1 }]
    @UI.lineItem : [{ position:1, label:'AccountingDocument' }]
    // @EndUserText.label: 'Accounting document'
    key a.AccountingDocument,

    @Search.defaultSearchElement: true
    @UI.selectionField : [{ position:3 }]
    @UI.lineItem : [{ position:3, label:'FiscalYear' }]
    // @EndUserText.label: 'Fiscal Year'
    key a.FiscalYear,

    @Search.defaultSearchElement: true
    @UI.selectionField : [{ position:4 }]
    @UI.lineItem : [{ position:4, label:'CompanyCode' }]
    // @EndUserText.label: 'Company Code'
    key a.CompanyCode,

    @Search.defaultSearchElement: true
    @UI.selectionField : [{ position:5 }]
    @UI.lineItem : [{ position:5, label:'Posting Date' }]
    // @EndUserText.label: 'Posting Date'
    a.PostingDate,

    @Search.defaultSearchElement: true
    @UI.selectionField : [{ position:6 }]
    @UI.lineItem : [{ position:6, label:'Customer' }]
    // @EndUserText.label: 'Customer'
    a.Customer,

    @Search.defaultSearchElement: true
    @UI.selectionField : [{ position:7 }]
    @UI.lineItem : [{ position:7, label:'Vendor' }]
    // @EndUserText.label: 'Vendor'
    a.Supplier,

    @Search.defaultSearchElement: true
    @UI.selectionField : [{ position:8 }]
    @UI.lineItem : [{ position:8, label:'Doc.Type' }]
    // @EndUserText.label: 'Document Type'
    a.AccountingDocumentType,

    @Search.defaultSearchElement: true
    @UI.selectionField : [{ position:9 }]
    @UI.lineItem : [{ position:9, label:'Amount' }]
    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
    // @EndUserText.label: 'Amount'
    sum(a.AbsoluteAmountInCoCodeCrcy) as TotalAmount,  // Aggregated TotalAmount


    @Search.defaultSearchElement: true
    @UI.hidden: true
    @UI.selectionField : [{ position:10 }]
    @UI.lineItem : [{ position:10, label:'Currency' }]
    // @EndUserText.label: 'Currency'
    a.CompanyCodeCurrency,

    @Search.defaultSearchElement: true
    @UI.hidden: true
    @UI.selectionField : [{ position:11 }]
    @UI.lineItem : [{ position:11, label:'Reverse No' }]
    // @EndUserText.label: 'Reverse Document'
    b.ReverseDocument,
    
    
//    @Search.defaultSearchElement: true
//    @UI.selectionField : [{ position:2 }]
//    @UI.lineItem : [{ position:2, label:'AccountingDocument' }]
//    // @EndUserText.label: 'Reverse Document'
//     a.OriginalReferenceDocument
    @Search.defaultSearchElement: true
   @UI.selectionField : [{ position:2 }]
    @UI.lineItem: [{ position: 2, label: 'Original Reference Doc No' }]
cast( a.OriginalReferenceDocument as abap.char(10) ) as OriginalRefDoCNo
    
   
    
}



where
  (
 
   
  
       a.AccountingDocumentType       = 'KC'
    or a.AccountingDocumentType       = 'KG'
    or a.AccountingDocumentType  = 'RK'
//   
//    or a.AccountingDocumentType       = 'DD'
  )
   and   a.FinancialAccountType = 'K' 
// and(
//       a.TransactionTypeDetermination = 'WRX'
//    or a.TransactionTypeDetermination = 'EGK'
//    or a.TransactionTypeDetermination = 'KBS'
//    or a.TransactionTypeDetermination = 'JII'
//    or a.TransactionTypeDetermination = 'JIC'
//  )
group by a.AccountingDocument, a.FiscalYear, a.CompanyCode, a.PostingDate, a.Customer, a.Supplier, a.AccountingDocumentType, a.CompanyCodeCurrency, b.ReverseDocument,a.OriginalReferenceDocument          




































