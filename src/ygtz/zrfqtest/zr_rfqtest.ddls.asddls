@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RFQ Matrix CDS'
define root view entity ZR_RFQtest 
with parameters
@EndUserText.label: 'Parm'
PRFQ : abap.char(10)
as select from zrfqmatrix as RFQMatrix
{
  key bukrs as Bukrs,
  key requestforquotation as Requestforquotation,
  key vendorcode as Vendorcode,
  key productcode as Productcode,
  key scheduleline as Scheduleline,
  key supplierquotationitem as Supplierquotationitem,
  vendorname as Vendorname,
  productdesc as Productdesc,
  producttradename as Producttradename,
  remarks as Remarks,
  orderquantity as Orderquantity,
  orderquantityunit as Orderquantityunit,
  vendortype as Vendortype,
  majoractivity as Majoractivity,
  typeofenterprise as Typeofenterprise,
  udyamaadharno as Udyamaadharno,
  udyamcertificatedate as Udyamcertificatedate,
  udyamcertificatereceivingdate as Udyamcertificatereceivingdate,
  vendorspecialname as Vendorspecialname,
  supply as Supply,
  processed as Processed,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
}
where requestforquotation = $parameters.PRFQ
