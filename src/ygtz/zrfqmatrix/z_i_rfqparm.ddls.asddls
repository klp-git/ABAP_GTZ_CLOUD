@EndUserText.label: 'RFQ Parameter'
define abstract entity Z_I_RFQPARM
{
  @EndUserText.label: 'RFQ No.'
//  @Consumption.valueHelpDefinition: [{entity: {name: 'ZR_RFQ_VH', element: 'RequestForQuotation' }}]
  RFQNo     : abap.char( 10 );

    
}
