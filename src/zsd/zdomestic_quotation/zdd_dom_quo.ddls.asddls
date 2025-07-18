@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View for Sales Quotation'
define root view entity zdd_dom_quo 
as select from I_SalesQuotation as a 
left outer join I_Customer as b on a.SoldToParty = b.Customer
{
    @EndUserText.label: 'Sales Quotation'
    key a.SalesQuotation,
    @EndUserText.label: 'Sales Quotation Type'
    a.SalesQuotationType,
    @EndUserText.label: 'Creation Date'
    a.CreationDate,
    @EndUserText.label: 'Distribution Channel'
    a.DistributionChannel,
    @EndUserText.label: 'Sold To Party'
    a.SoldToParty,
    @EndUserText.label: 'Customer Name'
    b.CustomerName
}
where a.DistributionChannel <> '20' and a.DistributionChannel <> '21' and a.DistributionChannel <> '22'
