//@AbapCatalog.sqlViewName: 'ZDD_COAS'
//@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@EndUserText.label: 'cds view for coa report'
//@Metadata.ignorePropagatedAnnotations: true


@EndUserText.label: 'I_InspectionLot CDS'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_COASCREEN'
@UI.headerInfo: {typeName: 'COA PRINT'}
define view  entity zdd_coa as select from I_InspectionLot
{
     @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:1 }]
      @UI.lineItem   : [{ position:1, label:'inspection lot number' }]
  key InspectionLot,


      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:2 }]
      @UI.lineItem   : [{ position:2, label:'batch' }]
      Batch,
      
      
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:3 }]
      @UI.lineItem   : [{ position:3, label:'material' }]
      Material
}
