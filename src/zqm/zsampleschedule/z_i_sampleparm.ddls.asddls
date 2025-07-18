@EndUserText.label: 'Sample Parameter'
define abstract entity Z_I_SAMPLEPARM
{
  @EndUserText.label: 'Plant'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PlantStdVH', element: 'Plant' } }]
  PlantNo     : abap.char( 4 );

  @EndUserText.label: 'Storage Location'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_StorageLocationStdVH', element: 'StorageLocation' },
                                        additionalBinding: [{ localElement: 'PlantNo',
                                                              element: 'Plant' }]
    }]
  StorageLocation     : abap.char( 4 );

  @EndUserText.label: 'Product'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZR_ProductAll_VH', element: 'Product' } }]
  Productcode     : abap.char( 40 );

  @EndUserText.label: 'Batch'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_BatchStdVH', element: 'Batch' } ,
                                        additionalBinding: [{ localElement: 'Productcode',
                                                              element: 'Material' }]
    }]
  BatchNo     : abap.char( 10 );

  
     
}
