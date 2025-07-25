@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Return delivery slip - Base CDS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_qm_return_slip
  as select from I_MaterialDocumentItem_2

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
      //Customer,
      //InventorySpecialStockType,
      //InventoryStockType,
      //StockOwner,
      //GoodsMovementType,
      //DebitCreditCode,
      //InventoryUsabilityCode,
      //QuantityInBaseUnit,
      //MaterialBaseUnit,
      //QuantityInEntryUnit,
      //EntryUnit,
      //PostingDate,
      //DocumentDate,
      //ReservationItemRecordType,
      //TotalGoodsMvtAmtInCCCrcy,
      //CompanyCodeCurrency,
      //InventoryValuationType,
      //ReservationIsFinallyIssued,
      //PurchaseOrder,
      //PurchaseOrderItem,
      //ProjectNetwork,
      //OrderID,
      //OrderItem,
      //MaintOrderRoutingNumber,
      //MaintOrderOperationCounter,
      //Reservation,
      //ReservationItem,
      //DeliveryDocument,
      //DeliveryDocumentItem,
      //ReversedMaterialDocumentYear,
      //ReversedMaterialDocument,
      //ReversedMaterialDocumentItem,
      //RvslOfGoodsReceiptIsAllowed,
      //GoodsRecipientName,
      //GoodsMovementReasonCode,
      //UnloadingPointName,
      //CostCenter,
      //GLAccount,
      //ServicePerformer,
      //PersonWorkAgreement,
      //AccountAssignmentCategory,
      //WorkItem,
      //ServicesRenderedDate,
      //IssgOrRcvgMaterial,
      //IssuingOrReceivingPlant,
      //IssuingOrReceivingStorageLoc,
      //IssgOrRcvgBatch,
      //IssgOrRcvgSpclStockInd,
      //IssuingOrReceivingValType,
      //CompanyCode,
      //BusinessArea,
      //ControllingArea,
      //FiscalYearPeriod,
      //FiscalYearVariant,
      //GoodsMovementRefDocType,
      //IsCompletelyDelivered,
      //MaterialDocumentItemText,
      //IsAutomaticallyCreated,
      //SerialNumbersAreCreatedAutomly,
      //GoodsReceiptType,
      //ConsumptionPosting,
      //MultiAcctAssgmtOriglMatlDocItm,
      //MultipleAccountAssignmentCode,
      //GoodsMovementIsCancelled,
      //IssuingOrReceivingStockType,
      //ManufacturingOrder,
      //ManufacturingOrderItem,
      //MaterialDocumentLine,
      //MaterialDocumentParentLine,
      //SpecialStockIdfgSalesOrder,
      //SpecialStockIdfgSalesOrderItem,
      //SpecialStockIdfgWBSElement,
      //QtyInPurchaseOrderPriceUnit,
      //OrderPriceUnit,
      //QuantityInDeliveryQtyUnit,
      //DeliveryQuantityUnit,
      //ProfitCenter,
      //ProductStandardID,
      //GdsMvtExtAmtInCoCodeCrcy,
      //ReferenceDocumentFiscalYear,
      //InvtryMgmtReferenceDocument,
      //InvtryMgmtRefDocumentItem,
      //EWMWarehouse,
      //EWMStorageBin,
      //MaterialDocumentPostingType,
      //OriginalMaterialDocumentItem,
      ///* Associations */
      //_AccountAssignmentCategory,
      //_BPStockOwner,
      //_BusinessArea,
      //_BusinessPartner,
      //_CompanyCode,
      //_ControllingArea,
      //_CostCenter,
      //_Currency,
      //_Customer,
      //_CustomerCompanyByPlant,
      //_DebitCreditCode,
      //_DeliveryDocument,
      //_DeliveryDocumentItem,
      //_EntryUnit,
      //_GLAccount,
      //_GoodsMovementType,
      //_GoodsMvtTypeBySpclStkIndT,
      //_InventorySpecialStockType,
      //_InventoryStockType,
      //_InventoryValuationType,
      //_IssgOrRcvgMaterial,
      //_IssgOrRcvgSpclStockInd,
      //_IssuingOrReceivingPlant,
      //_IssuingOrReceivingStorageLoc,
      //_LogisticsOrder,
      //_Material,
      //_MaterialBaseUnit,
      //_MaterialDocumentHeader,
      //_MaterialDocumentYear,
      //_PersonWorkAgreement,
      //_Plant,
      //_ProjectNetwork,
      //_PurchaseOrder,
      //_PurchaseOrderItem,
      //_ReversedMatDoc,
      //_ReversedMatDocItem,
      //_SalesOrder,
      //_SalesOrderItem,
      //_SalesOrderScheduleLine,
      //_StockType_2,
      //_StorageLocation,
      //_Supplier,
      //_SupplierCompanyByPlant,
      //_WBSElement,
      //_WorkItem

}
