@AbapCatalog.sqlViewName: 'ZR_RFQMATRIX_CDS'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RFQ Matrix CDS'
@Metadata.ignorePropagatedAnnotations: true
define view ZR_RFQMATRIXCDS as select from zrfqmatrix
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
    created_by as CreatedBy,
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt,
    local_last_changed_at as LocalLastChangedAt
}
 
