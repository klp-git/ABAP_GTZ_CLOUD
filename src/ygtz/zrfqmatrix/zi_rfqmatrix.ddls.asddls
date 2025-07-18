@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RFQ Matrix Interface View'
define root view entity ZI_RFQMatrix 
  provider contract transactional_interface
  as projection on ZR_RFQMatrix as RFQMatrix
{
    key Bukrs,
    key Requestforquotation,
    key Vendorcode,
    key Productcode,
    key Scheduleline,
    key Supplierquotationitem,
    Vendorname,
    Productdesc,
    Producttradename,
    Remarks,
    Orderquantity,
    Orderquantityunit,
    Vendortype,
    Majoractivity,
    Typeofenterprise,
    Udyamaadharno,
    Udyamcertificatedate,
    Udyamcertificatereceivingdate,
    Vendorspecialname,
    Supply,
    Processed,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt

}
