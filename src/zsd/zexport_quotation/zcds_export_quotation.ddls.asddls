@EndUserText.label: 'I_SALESQUOTATION CDS'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCLASS_EQ_SCREEN'
@UI.headerInfo: {typeName: 'Sales Quotation Print'}
define custom entity zcds_export_quotation
{
      @UI.selectionField : [{ position:10 }]
      @UI.lineItem       : [{ position: 10, label: 'Sales Quotation' }]
      @EndUserText.label : 'Sales Quotation'
  key salesquotation     : abap.char( 10 );
      @UI.selectionField : [{ position:20 }]
      @UI.lineItem       : [{ position: 20, label: 'Sales Quotation Type' }]
      @EndUserText.label : 'Sales Quotation Type'
      SALESQUOTATIONTYPE : abap.char( 3 );

      @UI.selectionField : [{ position:30 }]
      @UI.lineItem       : [{ position: 30, label: 'Creation Date' }]
      @EndUserText.label : 'Creation Date'
      CreationDate       : abap.dats(8);


      @Search.defaultSearchElement: true
      @UI.selectionField : [{ position:40 }]
      @UI.lineItem       : [{ position: 40, label: 'Sales Organization' }]
      @EndUserText.label: 'Sales Organization'
      SalesOrganization  : abap.char(4);


}

//
//
//
//
//}
