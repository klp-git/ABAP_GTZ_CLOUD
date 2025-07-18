@EndUserText.label: 'I_OperationalAcctgDocItem CDS'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_LIST_REPORT'
@UI.headerInfo: {typeName: 'MONEY RECEIPTT'}
define view entity zcds_moneyrec as select from  I_OperationalAcctgDocItem as A 
inner join I_Customer as b on A.Customer = b.Customer and A.AccountingDocumentType = 'DZ'
{
A.AccountingDocument,
A.AccountingDocumentType,
A.PostingDate,
A.CompanyCode,
A.Customer,
b.CustomerName 
}
