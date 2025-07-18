@EndUserText.label: 'PLANNING REPORT'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_TESTPDF'
@UI.headerInfo: {typeName: 'Planning'}
define custom entity Ztest_pdf
{
      @UI.selectionField: [{ position:1 }]
      @UI.lineItem  : [{ position: 1, label:'Sales Order' }]

  key so      : abap.char(10);

      @UI.selectionField: [{ position:2 }]
      @UI.lineItem  : [{ position: 2, label:'Order Type' }]
      so_type : abap.char(4);


}
