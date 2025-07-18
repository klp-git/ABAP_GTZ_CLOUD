@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Billing Docs Interface View'
define root view entity ZI_BillingDocTP
  provider contract transactional_interface
  as projection on ZR_BillingDocTP as BillingDoc
{
  key Bukrs,
  key Fiscalyearvalue,
  key Billingdocument,
  creationdatetime,
      _BillingLines : redirected to composition child ZI_BillingLinesTP

}
