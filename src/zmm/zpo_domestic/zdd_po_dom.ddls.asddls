@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZPURCHASE_ORD'
@Metadata.allowExtensions: true

define view entity ZDD_PO_DOM
  as select from    I_PurchaseOrderAPI01 as a
    left outer join I_CompanyCode        as b on a.CompanyCode = b.CompanyCode
    left outer join I_Supplier           as c on a.Supplier = c.Supplier
  //    left outer join I_Address_2          as c on b.AddressID = c.AddressID
  //    left outer join I_Supplier           as d on d.Supplier = a.Supplier
  //    left outer join I_RegionText         as e on e.Region = d.Region
  //    left outer join I_BusinessPartner    as f on f.BusinessPartner = d.Supplier
  //    left outer join I_SupplierQuotationTP as g on g.Supplier = a.Supplier

{
      @EndUserText.label: 'Purchase Order'
  key a.PurchaseOrder,
      @EndUserText.label: 'Supplier'
      a.Supplier,
      @EndUserText.label: 'Purchase Order Type'
      a.PurchaseOrderType,
      a.PurchaseOrderDate,
      b.CompanyCodeName,
      c.SupplierName
}
where
      a.PurchaseOrderType <> 'ZIMP'
  and a.PurchaseOrderType <> 'ZSTR'
