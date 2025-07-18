@EndUserText.label: 'PDF Response Entity'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_PDF_PROVIDER'
define custom entity ZPDFResponseEntity
  with parameters
    p_salesorder : vbeln
{
//      @UI.lineItem:[{ position:20, label:'PDF' }]
  key PdfContent : abap.string; // HTML content for PDF rendering
}
    
