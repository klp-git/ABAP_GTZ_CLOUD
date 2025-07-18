@AbapCatalog.sqlViewName: 'YR_RFQ_VH'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RFQ Value help CDS'
define view ZR_RFQ_VH as select from I_Requestforquotation_Api01
{
    @Consumption.valueHelpDefault.display: true
    key RequestForQuotation,
    @Consumption.valueHelpDefault.display: true
    CompanyCode,
    @Consumption.valueHelpDefault.display: false
    PurchasingOrganization,
    @Consumption.valueHelpDefault.display: true
    PurchasingGroup,
    @Consumption.valueHelpDefault.display: true
    RFQPublishingDate
}
