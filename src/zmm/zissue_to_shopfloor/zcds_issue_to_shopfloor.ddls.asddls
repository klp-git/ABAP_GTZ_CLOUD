@EndUserText.label: 'Material CDS'
@Search.searchable: false
@UI.headerInfo: {typeName: 'Issue To ShopFloor Print'}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity zcds_issue_to_shopfloor
  as select from I_MaterialDocumentItem_2
{
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:1 }]
      @UI.lineItem   : [{ position:1, label:'Material Document Year' }]
      key MaterialDocumentYear,
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:2 }]
      @UI.lineItem   : [{ position:2, label:'Material Document' }]
      key MaterialDocument,
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:3 }]
      @UI.lineItem   : [{ position:3, label:'Material Document Item' }]
      key MaterialDocumentItem
}
 