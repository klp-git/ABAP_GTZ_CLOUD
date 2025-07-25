@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'All Product Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_ProductAll_VH as 
  select from I_Product as pr
  join I_ProductDescription as pd on pr.Product = pd.Product and pd.LanguageISOCode = 'EN' 
{
    key pr.Product,
    pd.ProductDescription,
    ltrim(pr.Product,'0') as ProductAlias
}
