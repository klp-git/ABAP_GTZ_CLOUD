@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Billing Lines CDS View'
define root view entity ZR_BILLINGLINETP
  as select from zbillinglines as BillingLines
{
      @EndUserText.label: 'Company Code'
  key companycode                as CompanyCode,
      @EndUserText.label: 'Fiscal Year Value'
  key fiscalyearvalue            as Fiscalyearvalue,
      // V
      @EndUserText.label: 'Invoice No'
  key invoice                    as Invoice,
      // AB
      @EndUserText.label: 'Line Item No.'
  key lineitemno                 as LineItemNo,
      // A
      @EndUserText.label: 'Sales Quotation'
      salesquotation             as SalesQuotation,
      // B
      @EndUserText.label: 'Creation Date'
      creationdate               as CreationDate,
      // C
      @EndUserText.label: 'Sales Person'
      salesperson                as SalesPerson,
      // D
      @EndUserText.label: 'Sale Order Number'
      saleordernumber            as SaleOrderNumber,
      // E
      @EndUserText.label: 'Sales Creation Date'
      salescreationdate          as SalesCreationDate,
      // F
      @EndUserText.label: 'Customer PO Number'
      customerponumber           as CustomerPONumber,
      // G
      @EndUserText.label: 'Sold to party GSTIN'
      soldtopartygstin           as SoldtopartyGSTIN,
      //companycode             as companycode,
      // I
      @EndUserText.label: 'Sold-to Party Name'
      soldtopartyname            as SoldtoPartyName,
      // J
      @EndUserText.label: 'Sold-to Party Number'
      soldtopartynumber          as SoldtoPartyNumber,
      
      @EndUserText.label: 'CustomerGroup'
      customergroup          as CustomerGroup,
      // K
      @EndUserText.label: 'Ship to Party Number'
      shiptopartynumber          as ShiptoPartyNumber,
      // L
      @EndUserText.label: 'Ship to Party Name'
      shiptopartyname            as ShiptoPartyName,
      // M
      @EndUserText.label: 'Ship to Party GST No.'
      shiptopartygstno           as ShiptoPartyGSTNo,
      // N
      @EndUserText.label: 'Delivery Place State Code'
      deliveryplacestatecode     as DeliveryPlaceStateCode,
      // P
      @EndUserText.label: 'Sold to Region Code'
      soldtoregioncode           as SoldtoRegionCode,
      // Q
      @EndUserText.label: 'Delivery Number'
      deliverynumber             as DeliveryNumber,
      // R
      @EndUserText.label: 'Delivery Date'
      deliverydate               as DeliveryDate,
      // S
      @EndUserText.label: 'Billing Type'
      billingtype                as BillingType,
      // T
      @EndUserText.label: 'Billing Doc. Desc.'
      billingdocdesc             as BillingDocDesc,
      // U
      @EndUserText.label: 'Bill No.'
      billno                     as BillNo,
      // X
      @EndUserText.label: 'E - way Bill Number'
      ewaybillnumber             as EwayBillNumber,
      // Y
      @EndUserText.label: 'E way Bill Date & Time'
      ewaybilldatetime           as EwayBillDateTime,
      // Z
      @EndUserText.label: 'IRN Ack Number'
      irnacknumber               as IRNAckNumber,
      // AA
      @EndUserText.label: 'Delivery Plant'
      deliveryplant              as DeliveryPlant,
      // W
      @EndUserText.label: 'Invoice Date'
      invoicedate                as InvoiceDate,
      // AC
      @EndUserText.label: 'Material No'
      materialno                 as MaterialNo,
      // AD
      @EndUserText.label: 'Material Description'
      materialdescription        as MaterialDescription,
      // AE
      @EndUserText.label: 'Customer Item Code'
      customeritemcode           as CustomerItemCode,
      
      @EndUserText.label: 'Product Category'
      productcategory           as ProductCategory,
      
      // AF
      @EndUserText.label: 'HSN Code'
      hsncode                    as HSNCode,
      // AG
      @EndUserText.label: 'HS Code'
      hscode                     as HSCode,
      // AH
      @EndUserText.label: 'QTY'
      qty                        as QTY,
      // AI
      @EndUserText.label: 'UOM'
      uom                        as UOM,
      // AK
      @EndUserText.label: 'Document currency'
      documentcurrency           as Documentcurrency,
      // AL
      @EndUserText.label: 'Exchange rate'
      exchangerate               as Exchangerate,
      // AJ
      @EndUserText.label: 'Rate'
      rate                       as Rate,
      // AM
      @EndUserText.label: 'Rate in INR'
      rateininr                  as RateinINR,
      // AN
      @EndUserText.label: 'Taxable Value before Discount'
      taxablevaluebeforediscount as TaxableValueBeforeDiscount,
      // AV
      @EndUserText.label: 'IGST Amt'
      igstamt                    as IGSTAmt,
      // AZ
      @EndUserText.label: 'SGST Amt'
      sgstamt                    as SGSTAmt,
      // AX
      @EndUserText.label: 'CGST Amt'
      cgstamt                    as CGSTAmt,
      // AQ
      @EndUserText.label: 'Taxable Value After Discount'
      taxablevalueafterdiscount  as TaxableValueAfterDiscount,
      // AR
      @EndUserText.label: 'Freight Charge INR'
      freightchargeinr           as FreightChargeINR,
      // AS
      @EndUserText.label: 'Insurance Rate INR'
      insurancerateinr           as InsuranceRateINR,
      // AT
      @EndUserText.label: 'Insurance Amount INR'
      insuranceamountinr         as InsuranceAmountINR,
      // BA
      @EndUserText.label: 'UGST Rate'
      ugstrate                   as UGSTRate,
      // BB
      @EndUserText.label: 'UGST Amt'
      ugstamt                    as UGSTAmt,
      // BE
      @EndUserText.label: 'Roundoff Value'
      roundoffvalue              as RoundoffValue,
      // AP
      @EndUserText.label: 'Discount Amount'
      discountamount             as DiscountAmount,
      // AO
      @EndUserText.label: 'Discount Rate'
      discountrate               as DiscountRate,
      // BF
      @EndUserText.label: 'Invoice Amount'
      invoiceamount              as InvoiceAmount,
      // AU
      @EndUserText.label: 'IGST Rate'
      igstrate                   as IGSTRate,
      // AW
      @EndUserText.label: 'CGST Rate'
      cgstrate                   as CGSTRate,
      // AY
      @EndUserText.label: 'SGST Rate'
      sgstrate                   as SGSTRate,
      // BC
      @EndUserText.label: 'TCS Rate'
      tcsrate                    as TCSRate,
      // BD
      @EndUserText.label: 'TCS Amount'
      tcsamount                  as TCSAmount,
      @EndUserText.label: 'Cancelled Invoice'
      cancelledinvoice           as cancelledinvoice,
      case when cancelledinvoice = 'X' then
      1 else 0 end  as Cancelled
}
