@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sticker Print CDS'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zpp_sticker_print_cds
  as select from I_ManufacturingOrderItem
{
  key ManufacturingOrder,
      Product,
      Batch
}
group by
  ManufacturingOrder,
  Product,
  Batch
