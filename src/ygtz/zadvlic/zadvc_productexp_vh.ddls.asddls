@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'EXP Product Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZADVC_PRODUCTEXP_VH as 
  select from I_Product as pr
  join I_ProductDescription as pd on pr.Product = pd.Product and pd.LanguageISOCode = 'EN' and pr.ProductType ='ZFGC' 
  join I_UnitOfMeasureStdVH as un on un.UnitOfMeasure = pr.BaseUnit
{
    key pr.Product,
    pd.ProductDescription,
    ltrim(pr.Product,'0') as ProductAlias,
    pr.BaseUnit,
    un.UnitOfMeasureLongName
}
