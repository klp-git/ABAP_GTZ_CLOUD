@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forPRPlanning'
define root view entity ZR_PRPlanningTP
  as select from zprplanning as PRPlanning
{
  key bukrs                 as Bukrs,
  key plant                 as Plant,
  key planningmonth         as Planningmonth,
  key productcode           as Productcode,
      productdesc           as Productdesc,
      quantityunit          as Quantityunit,
      planningdate          as Planningdate,
      minimumqty            as Minimumqty,
      maximumqty            as Maximumqty,
      salestrendqty         as Salestrendqty,
      forecastqty           as Forecastqty,
      salesorderqty         as Salesorderqty,
      suggestedqty          as Suggestedqty,
      overrideqty           as Overrideqty,
      opensalesorderqty as opensalesorderqty,
      remarks               as Remarks,
      closed                as Closed,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      local_last_changed_at as LocalLastChangedAt

}
