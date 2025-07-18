@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forPRPlanning'
@ObjectModel.semanticKey: [ 'Bukrs' ]
@Search.searchable: true
define root view entity ZC_PRPlanningTP
  provider contract transactional_query
  as projection on ZR_PRPlanningTP as PRPlanning
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
  key Bukrs,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
  key Plant,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90   
  key Planningmonth,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
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
