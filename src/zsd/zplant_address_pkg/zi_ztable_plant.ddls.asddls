
@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'CDS View for Plant Details'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zi_ztable_plant as select from ztable_plant 
{
    key comp_code as CompCode,
    key plant_code as PlantCode,
    plant_name1 as PlantName1,
    plant_name2 as PlantName2,
    address1 as Address1,
    address2 as Address2,
    address3 as Address3,
    city as City,
    district as District,
    state_code1 as StateCode1,
    state_code2 as StateCode2,
    state_name as StateName,
    pin as Pin,
    country as Country,
    cin_no as CinNo,
    gstin_no as GstinNo,
    pan_no as PanNo,
    tan_no as TanNo,
    remark1 as Remark1,
    remark2 as Remark2,
    remark3 as Remark3
}
