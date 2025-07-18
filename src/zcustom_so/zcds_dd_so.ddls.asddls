@EndUserText.label: 'PLANNING REPORT'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_SO1'
@UI.headerInfo: {typeName: 'Planning'}
define custom entity ZCDS_DD_SO
{
    @UI.selectionField: [{ position:1 }]
    @UI.lineItem: [{ position: 1, label:'Sales Order' }]
    
    key so:  abap.char(10);
    
     @UI.selectionField: [{ position:2 }]
     @UI.lineItem: [{ position: 2, label:'Order Type' }]
     so_type:  abap.char(4);
     
        
}
