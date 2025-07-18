@EndUserText.label: 'PLANNING TEST acx demo dev cloud'
@Search.searchable: false
//@ObjectModel.query.implementedBy: 'ABAP:ZCDSTAX_INV_BATCH_D'
@UI.headerInfo: {typeName: 'PLANNING REPORT'
}
define custom entity ZCDSTAX_INV_BATCH_D 
{
   
      @UI.selectionField: [{ position: 1 }] // Select-Options
      @UI.lineItem: [{ position: 1, label: 'Company Code' }] 
      @Consumption.valueHelpDefinition: [{ entity : { element: 'Plant', name: 'I_ProductPlantStdVH' } }]
      key Companycode   : abap.char(4); 
      
        @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:2 }]             // Select-Options
      @UI.lineItem   : [{ position:2, label:'Customer Code' }]     // F-cat
//      @UI.hidden: true               // Hidding Specific Field
      Customer : abap.char(40); 
      
        @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:2 }]             // Select-Options
      @UI.lineItem   : [{ position:2, label:'Reconciliation Account ' }]     // F-cat
//      @UI.hidden: true               // Hidding Specific Field
      Reconciliation_Account      : abap.char(40);     
}
