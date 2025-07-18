@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZR for salary'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_SALARYINT as select from zsalarytable
{
  key profit_center       as ProfitCenter,
  key cost_center         as CostCenter,
  key gl_account          as GLAccount,
  key pay_month           as PayMonth,
  key business_place      as BusinessPlace,
  key branch              as Branch,
  company_code            as CompanyCode,
  posting_date            as PostingDate,
  documenttypetext        as Narration,
  accountingdocument      as AccountingDocument,

  @Semantics.amount.currencyCode: 'Currency'
  debit                   as Debit,

  @Semantics.amount.currencyCode: 'Currency'
  credit                  as Credit,

  currency                as Currency,

  errorlog                as Errorlog,
  isposted                as IsPosted,
  isdeleted               as IsDeleted,
  isvalidate              as IsValidate,

  @Semantics.user.createdBy: true
  created_by              as CreatedBy,

  @Semantics.systemDateTime.createdAt: true
  created_at              as CreatedAt,

  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by         as LastChangedBy,

  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at         as LastChangedAt
}
