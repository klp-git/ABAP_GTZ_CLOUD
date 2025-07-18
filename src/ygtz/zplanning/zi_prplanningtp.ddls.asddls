@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forPRPlanning'
define root view entity ZI_PRPlanningTP
  provider contract transactional_interface
  as projection on ZR_PRPlanningTP as PRPlanning
{
  key Bukrs,
  key Plant,
  key Planningmonth,
  key Productcode,
      Productdesc,
      Quantityunit,
      Planningdate,
      Minimumqty,
      Maximumqty,
      Salestrendqty,
      Forecastqty,
      Salesorderqty,
      Suggestedqty,
      Overrideqty,
      opensalesorderqty,
      Remarks,
      Closed,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt

}
