@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'RFQ Matrix Projection View'
@ObjectModel.semanticKey: [ 'Requestforquotation' ]
@Search.searchable: true
define root view entity ZC_RFQMatrix 
  provider contract transactional_query
  as projection on ZR_RFQMatrix as RFQMatrix
{
    key Bukrs,
    @Search.defaultSearchElement: true
    @Search.fuzzinessThreshold: 0.90 
    key Requestforquotation,
    @Search.defaultSearchElement: true
    @Search.fuzzinessThreshold: 0.90 
    key Vendorcode,
    @Search.defaultSearchElement: true
    @Search.fuzzinessThreshold: 0.90 
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
