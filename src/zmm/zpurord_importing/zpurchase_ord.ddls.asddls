@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZPURCHASE_ORD'

define view entity ZPURCHASE_ORD
  as select from    I_PurchaseOrderAPI01 as a
    left outer join I_CompanyCode        as b on a.CompanyCode = b.CompanyCode
  //    left outer join I_Address_2          as c on b.AddressID = c.AddressID
  //    left outer join I_Supplier           as d on d.Supplier = a.Supplier
  //    left outer join I_RegionText         as e on e.Region = d.Region
  //    left outer join I_BusinessPartner    as f on f.BusinessPartner = d.Supplier
  //    left outer join I_SupplierQuotationTP as g on g.Supplier = a.Supplier

{
  key a.PurchaseOrder,
      a.Supplier,
      a.PurchaseOrderDate,
      b.CompanyCodeName
}
where
  a.PurchaseOrderType = 'ZIMP'
