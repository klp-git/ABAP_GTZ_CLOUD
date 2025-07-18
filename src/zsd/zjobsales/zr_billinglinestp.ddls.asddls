@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Billing Lines CDS View'
define view entity ZR_BillingLinesTP
  as select from zbillinglines as BillingLines
  association to parent ZR_BillingDocTP as _BillingDoc on  $projection.bukrs               = _BillingDoc.Bukrs
                                                       and $projection.Fiscalyearvalue     = _BillingDoc.Fiscalyearvalue
                                                       and $projection.billingdocumentitem = _BillingDoc.Billingdocument
{
      @EndUserText.label: 'Company Code'
  key companycode                as bukrs, // 11
      @EndUserText.label: 'Fiscal Year Value'
  key fiscalyearvalue            as Fiscalyearvalue,
      // V
      @EndUserText.label: 'Bill No.'
  key invoice                    as billingdocument, // 24
      // AB
      @EndUserText.label: 'Line Item No.'
  key lineitemno                 as billingdocumentitem, // 31
      // A
      @EndUserText.label: 'Sales Quotation - PI Number'
      salesquotation             as referencesddocument, // 4
      // B
      @EndUserText.label: 'Inv Date'
      creationdate               as creationdate, // 26
      // C
      @EndUserText.label: 'Sales Person'
      salesperson                as fullname, // 6
      // D
      @EndUserText.label: 'Sale Order Number'
      saleordernumber            as salesdocument, // 7
      // E
      @EndUserText.label: 'Sale Order Creation Date'
      salescreationdate          as sales_creationdate, // 8
      // F
      @EndUserText.label: 'Customer PO Number'
      customerponumber           as purchaseorderbycustomer, // 9
      // G
      @EndUserText.label: 'Sold to party GSTIN'
      soldtopartygstin           as taxnumber3, // 10
      //companycode             as companycode,
      // I
      @EndUserText.label: 'Sold-to Party Name'
      soldtopartyname            as customername, // 12

      @EndUserText.label: 'Customer Group'
      customergroup              as CustomerGroup,
      // J
      @EndUserText.label: 'Sold-to Party Number'
      soldtopartynumber          as soldtoparty, // 13
      // K
      @EndUserText.label: 'Ship to Party Number'
      shiptopartynumber          as shiptoparty, // 14
      // L
      @EndUserText.label: 'Ship to Party Name'
      shiptopartyname            as ship_customername, // 15
      // M
      @EndUserText.label: 'Ship to Party GST No.'
      shiptopartygstno           as ship_taxnumber3, // 16
      // N
      @EndUserText.label: 'Delivery Place State Code'
      deliveryplacestatecode     as del_place_state_code, // 17
      // P
      @EndUserText.label: 'Sold to Region Code'
      soldtoregioncode           as sold_region_code, // 19
      // Q
      @EndUserText.label: 'Delivery Number'
      deliverynumber             as D_ReferenceSDDocument, // 20
      // R
      @EndUserText.label: 'Delivery Date'
      deliverydate               as delivery_CreationDate, // 21
      // S
      @EndUserText.label: 'Billing Type / Document Type'
      billingtype                as BillingDocumentType, // 22
      // T
      @EndUserText.label: 'Billing Doc. Desc.'
      billingdocdesc             as billing_doc_desc, // 23
      // U
      @EndUserText.label: 'Inv No'
      billno                     as documentreferenceid, // 25
      // X
      @EndUserText.label: 'E - way Bill Number'
      ewaybillnumber             as E_way_Bill_Number, // 27
      // Y
      @EndUserText.label: 'E way Bill Date & Time'
      ewaybilldatetime           as E_way_Bill_Date_Time, // 28
      // Z
      @EndUserText.label: 'IRN Ack Number'
      irnacknumber               as IRN_Ack_Number, // 29
      // AA
      @EndUserText.label: 'Delivery Plant'
      deliveryplant              as del_plant, // 30
      // W
      @EndUserText.label: 'Inv Date'
      invoicedate                as Billingdocumentdate, // 26
      // AC
      @EndUserText.label: 'Material No/Code'
      materialno                 as Product, // 32
      // AD
      @EndUserText.label: 'Material Description'
      materialdescription        as Materialdescription, // 33
      // AE
      @EndUserText.label: 'Customer Item Code'
      customeritemcode           as MaterialByCustomer, // 34

      @EndUserText.label: 'Product Category'
      productcategory            as ProductCategory,
      // AF
      @EndUserText.label: 'HSN/Control Code'
      hsncode                    as ConsumptionTaxCtrlCode, // 35
      // AG
      @EndUserText.label: 'HS Code'
      hscode                     as YY1_SOHSCODE_SDI, // 36
      // AH
      @EndUserText.label: 'QTY'
      qty                        as billingQuantity, // 37
      // AI
      @EndUserText.label: 'UOM'
      uom                        as baseunit, // 38
      // AK
      @EndUserText.label: 'Document currency'
      documentcurrency           as transactioncurrency, // 40
      // AL
      @EndUserText.label: 'Exchange rate'
      exchangerate               as accountingexchangerate, // 41
      // AJ
      @EndUserText.label: 'Rate'
      rate                       as Itemrate, // 39
      // AM
      @EndUserText.label: 'Rate in INR (Rate X Exchange Rate)'
      rateininr                  as rate_in_inr, // 42
      // AN
      @EndUserText.label: 'Taxable Value before Discount in INR'
      taxablevaluebeforediscount as taxable_value, // 43
      // AV
      @EndUserText.label: 'IGST Amt'
      igstamt                    as Igst, // 51
      // AZ
      @EndUserText.label: 'SGST Amt'
      sgstamt                    as Sgst, // 55
      // AX
      @EndUserText.label: 'CGST Amt'
      cgstamt                    as Cgst, // 53
      // AQ
      @EndUserText.label: 'Taxable Value After Discount in INR'
      taxablevalueafterdiscount  as taxable_value_dis, // 46
      // AR
      @EndUserText.label: 'Freight Charge in INR'
      freightchargeinr           as freight_charge_inr, // 47
      // AS
      @EndUserText.label: 'Insurance  Rate In INR'
      insurancerateinr           as insurance_rate, //48
      // AT
      @EndUserText.label: 'Insurance  Amount In INR'
      insuranceamountinr         as insurance_amt, // 49
      // BA
      @EndUserText.label: 'UGST Rate'
      ugstrate                   as rateugst, // 56
      // BB
      @EndUserText.label: 'UGST Amt'
      ugstamt                    as ugst, // 57
      // BE
      @EndUserText.label: 'Roundoff Value'
      roundoffvalue              as Roundoff, // 60
      // AP
      @EndUserText.label: 'Discount Amount'
      discountamount             as Discount, // 45
      // AO
      @EndUserText.label: 'Discount Rate'
      discountrate               as ratediscount, // 44
      // BF
      @EndUserText.label: 'Invoice Amount In INR'
      invoiceamount              as Totalamount, // 61
      // AU
      @EndUserText.label: 'IGST Rate'
      igstrate                   as Rateigst, // 50
      // AW
      @EndUserText.label: 'CGST Rate'
      cgstrate                   as Ratecgst, // 52
      // AY
      @EndUserText.label: 'SGST Rate'
      sgstrate                   as Ratesgst, // 54
      // BC
      @EndUserText.label: 'TCS Rate'
      tcsrate                    as Ratetcs, // 58
      // BD
      @EndUserText.label: 'TCS Amount'
      tcsamount                  as Tcs, // 59
      @EndUserText.label: 'Cancelled Invoice'
      cancelledinvoice           as cancelledinvoice,
      case when cancelledinvoice = 'X' then
      1 else 0 end               as Cancelled,
      @EndUserText.label: 'Sales Organisation'
      salesorganisation          as salesorganisation,
      @EndUserText.label: 'Distribution Channel'
      distributionchannel        as distributionchannel,
      @EndUserText.label: 'Division'
      division                   as division,
      @EndUserText.label: 'Sales Quotation - PI Creation Date'
      salesquotationdate as salesquotationdate,

      _BillingDoc

}
