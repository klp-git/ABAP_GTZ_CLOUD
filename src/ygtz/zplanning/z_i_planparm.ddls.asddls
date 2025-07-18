@EndUserText.label: 'Planning Parameter'
define abstract entity Z_I_PLANPARM
{

  @EndUserText.label: 'Plant'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PlantStdVH', element: 'Plant' } }]
  PlantNo  : abap.char( 4 );

  @EndUserText.label: 'Plant Date'
  PlanDate : abap.dats;


}
