@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: false
@EndUserText.label: 'Billing Lines CDS View'
@Metadata.allowExtensions: true
define view entity ZI_ZPP_PRD_MEMO
  as select from    I_ReservationDocumentItem
    left outer join I_Product          on I_ReservationDocumentItem.Product = I_Product.Product
    left outer join I_CnsldtnDivisionT on I_Product.Division = I_CnsldtnDivisionT.Division
{
  key I_ReservationDocumentItem.Reservation,
      //        key I_ReservationDocumentItem.ReservationItem,
      //            I_ReservationDocumentItem.Batch,
     key I_CnsldtnDivisionT.DivisionName
}
where
  I_ReservationDocumentItem.GoodsMovementType = '311'
group by
  I_ReservationDocumentItem.Reservation,
  I_CnsldtnDivisionT.DivisionName
