@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZGLACCOUNT'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGLACCOUNT as select from I_GLACCOUNTTEXTRAWDATA
{
    key ChartOfAccounts,
    key GLAccount,
    key Language,
    GLAccountName,
    /* Associations */
    _ChartOfAccounts,
    _ChartOfAccountsText,
    _Language
}
