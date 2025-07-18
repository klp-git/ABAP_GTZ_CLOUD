@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data Defination Of Purchase Requisition'
@Metadata.allowExtensions: true
define root view entity ZDD_PURCHASE_REQUISITION as select from C_PurchaseRequisitionItemDEX as a
left outer join I_ProductDescription as b on a.Material = b.Product and b.Language = 'E'
{
    key a.PurchaseRequisition,
    key a.PurchaseRequisitionItem,
    a.Material,
    b.ProductDescription
}
