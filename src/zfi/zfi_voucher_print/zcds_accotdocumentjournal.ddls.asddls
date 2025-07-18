@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'zcds_accotdocumentjournal'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zcds_accotdocumentjournal
  as select from I_AccountingDocumentJournal( P_Language:'E' ) as a
{
  key a.CompanyCode,
  key a.AccountingDocument,
  key a.FiscalYear,
  key a.Ledger,
  key a.LedgerGLLineItem,
      a.GLAccount,
      a.ProfitCenter,
      a.CostCenter,
      a.AccountingDocumentItem,
      a.IsReversal,
      a.IsReversed
      //  a.CostCenter


}
where
  a.Ledger = '0L'
