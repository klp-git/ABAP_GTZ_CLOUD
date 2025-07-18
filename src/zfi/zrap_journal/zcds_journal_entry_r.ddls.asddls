@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consumption for rfq'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity zcds_Journal_Entry_r as projection on zcds_Journal_Entry
//composition of zcds_Journal_Entry as _association_name
{
    key JOURNAL_ENTRY_NO,
    key LineItem,
    JOURNAL_ENTRY_TY,
    JOURNAL_ENTRY_DT,
    @Semantics.amount.currencyCode: 'currency'
    Amount,
    currency,
    Companycode,
    /* Associations */
    _AccountingDocumentType,
    _AccountingDocumentTypeText,
    _CompanyCode
//    _association_name
}
