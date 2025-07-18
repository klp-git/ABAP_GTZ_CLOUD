@UI.headerInfo: {typeName: 'Sales Order Print'}
@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity zcds_works_order
  as select from    I_SalesDocument     as a
    left outer join I_Customer          as b on a.SoldToParty = b.Customer
    left outer join I_SalesOrderPartner as c on  a.SalesDocument   = c.SalesOrder
                                             and c.PartnerFunction = 'AP'
{
      @EndUserText.label: 'Sales Order No'
  key a.SalesDocument,
      @EndUserText.label: 'Sales Document Category'
      a.SDDocumentCategory,
      @EndUserText.label: 'Creation Date'
      a.CreationDate,
      @EndUserText.label: 'Customer Code'
      b.Customer,
      @EndUserText.label: 'Customer Name'
      b.BPCustomerName,
      @EndUserText.label: 'Sales Person Name'
      c.FullName

}
where
  a.SDDocumentCategory <> 'B'
