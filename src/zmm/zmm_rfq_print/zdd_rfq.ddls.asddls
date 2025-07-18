@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View for Rfq Print'
define view entity zdd_rfq
  as select from I_SupplierQuotationItem_Api01 as a
{
  @EndUserText.label: 'Rfq'
  key RequestForQuotation,
  @EndUserText.label: 'Rfq Item No'
  key RequestForQuotationItem,
  @EndUserText.label: 'Supplier Quotation'
  a.SupplierQuotation,
  @EndUserText.label: ' Supplier Quotation Item'
  SupplierQuotationItem,
  @EndUserText.label: 'Material'
  a.Material

}

where
  (
        a.PurchasingDocumentCategory = 'O'
    and a.NetAmount                  > 0.1
    //    or a.AccountingDocumentType       = 'KG'

  )
group by
  a.RequestForQuotation,
  a.RequestForQuotationItem,
  a.SupplierQuotation,
  a.SupplierQuotationItem,
  a.Material
