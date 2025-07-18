@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'root view entity for Quality insp'
//@Metadata.ignorePropagatedAnnotations: true
define root view entity zi_upload_insp
  as select from zupload_insp
{

      @EndUserText.label: 'Material A'

  key materiala       as Materiala,

      @EndUserText.label: 'Material B'

  key materialb       as Materialb,

      @EndUserText.label: 'Movement Type'

      movementtype    as Movementype,

      @EndUserText.label: 'Supplier/Vendor'

      vendor          as Vendor,

      @EndUserText.label: 'PO reference'

      poref           as Poref,

      @EndUserText.label: 'Plant'

      plant           as Plant,

      @EndUserText.label: 'Storage Location'

      storageloc      as Storageloc,

      @EndUserText.label: 'Transfer Post Status'

      trpoststatus    as Trpoststatus,

      @Semantics.user.createdBy: true

      @EndUserText.label: 'Created By'

      created_by      as CreatedBy,

      @Semantics.systemDateTime.createdAt: true

      @EndUserText.label: 'Created At'

      created_at      as CreatedAt,

      @Semantics.user.lastChangedBy: true

      @EndUserText.label: 'Last Changed By'

      last_changed_by as LastChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true

      @EndUserText.label: 'Last Changed At'

      last_changed_at as LastChangedAt,

      0               as ExcelRowNumber

}
