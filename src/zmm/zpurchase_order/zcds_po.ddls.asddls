@AbapCatalog.sqlViewName: 'YCDS_PO'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS for Purchase Order'
@Metadata.ignorePropagatedAnnotations: true
define view ZCDS_PO
  as select from I_PurchaseOrderItemAPI01
{
  key PurchaseOrder,
  key PurchaseOrderItem
      //    PurchaseOrderItemUniqueID,
      //    TextObjectType,
      //    Language,
      //    PlainLongText

}
