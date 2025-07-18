@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'zcdsVoucher'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zcdsVoucher
  as select from I_OperationalAcctgDocItem                     as a
    inner join  zcds_accotdocumentjournal as e on   a.AccountingDocument = e.AccountingDocument
                                                                    and a.GLAccount              = e.GLAccount
                                                                    and a.CompanyCode            = e.CompanyCode
                                                                    and a.AccountingDocumentItem = e.AccountingDocumentItem
                                                                    and a.FiscalYear             = e.FiscalYear 
//                                                                    and a.LedgerGLLineItem       = e.LedgerGLLineItem 
                                                                    
      left outer join I_GLAccountTextRawData                        as b on a.GLAccount = b.GLAccount
      left outer join I_CostCenterText                              as c on  a.CostCenter = c.CostCenter
                                                                         and c.Language   = 'E'
      left outer join I_ProfitCenterText                            as d on  e.ProfitCenter = d.ProfitCenter
                                                                         and d.Language     = 'E'
{
  key a.CompanyCode,
  key a.AccountingDocument,
  key a.FiscalYear,
  key a.AccountingDocumentItem,
      a.GLAccount,
      @Semantics.amount.currencyCode: 'curr'
      a.AmountInCompanyCodeCurrency,
      a.CompanyCodeCurrency as curr,
      a.DocumentItemText,
      a.TransactionTypeDetermination,
      b.GLAccountName,
      e.CostCenter,
      c.CostCenterName,
      e.ProfitCenter,
      e.AccountingDocument  as noo,
      e.Ledger,
      d.ProfitCenterName,
      /* Associations */

      a._CompanyCode,
      a._FiscalYear,
      a._GLAccountInCompanyCode,
      a._JournalEntry,
      a._JournalEntryItemOneTimeData,
      a._OneTimeAccountBP
}

//


