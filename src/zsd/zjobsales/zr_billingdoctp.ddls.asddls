@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS view for Billing Documents'
define root view entity ZR_BillingDocTP
  as select from zbillingproc as BillingDoc
  composition [0..*] of ZR_BillingLinesTP as _BillingLines
{
  key bukrs                   as Bukrs,
  key fiscalyearvalue         as Fiscalyearvalue,
  key billingdocument         as Billingdocument,
  creationdatetime        as  creationdatetime,
      _BillingLines

}
