@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Salary definition for delete'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_SALARYINTDEL provider contract transactional_query
  as projection on ZR_SALARYINT
{
  key ProfitCenter,
  key CostCenter,
  key GLAccount,
  key PayMonth,
  key BusinessPlace,
  key Branch,
  CompanyCode,
  PostingDate,
  Narration,
  AccountingDocument,
  

  @Semantics.amount.currencyCode: 'Currency'
  Debit,

  @Semantics.amount.currencyCode: 'Currency'
  Credit,

  Currency,

  Errorlog,

  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt
}
where IsPosted = '' and IsDeleted = 'X' 
