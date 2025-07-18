@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root view for Return Delivery Slip'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity zi_qm_ret__slip_root
  as select from zi_qm_return_slip
{
  key MaterialDocumentYear,
  key MaterialDocument,
  key MaterialDocumentItem,
      Material,
      Plant,
      StorageLocation,
      StorageType,
      StorageBin,
      Batch,
      ShelfLifeExpirationDate,
      ManufactureDate,
      Supplier,
      SalesOrder,
      SalesOrderItem,
      SalesOrderScheduleLine,
      WBSElementInternalID
}
