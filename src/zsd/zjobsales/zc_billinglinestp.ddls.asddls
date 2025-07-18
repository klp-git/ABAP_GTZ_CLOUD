@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Billing Lines Projection Views'
@ObjectModel.semanticKey: [ 'Billingdocumentitem' ]
@Search.searchable: true
define view entity ZC_BillingLinesTP
  as projection on ZR_BillingLinesTP as BillingLines
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
  key bukrs,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
  key Fiscalyearvalue,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
  key billingdocument,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
  key billingdocumentitem,
      referencesddocument,
      // B
      creationdate,
      // C
      fullname,
      // D
      salesdocument,
      // E
      sales_creationdate,
      // F
      purchaseorderbycustomer,
      // G
      taxnumber3,
      // I
      customername,
      // J
      soldtoparty,
      CustomerGroup,
      // K
      shiptoparty,
      // L
      ship_customername,
      // M
      ship_taxnumber3,
      // N
      del_place_state_code,
      // P
      sold_region_code,
      // Q
      D_ReferenceSDDocument,
      // R
      delivery_CreationDate,
      // S
      BillingDocumentType,
      // T
      billing_doc_desc,
      // U
      documentreferenceid,
      // X
      E_way_Bill_Number,
      // Y
      E_way_Bill_Date_Time,
      // Z
      IRN_Ack_Number,
      // AA
      del_plant,
      // W
      Billingdocumentdate,
      // AC
      Product,
      // AD
      Materialdescription,
      // AE
      MaterialByCustomer,
      ProductCategory,
      // AF
      ConsumptionTaxCtrlCode,
      // AG
      YY1_SOHSCODE_SDI,
      // AH
      billingQuantity,
      // AI
      baseunit,
      // AK
      transactioncurrency,
      // AL
      accountingexchangerate,
      // AJ
      Itemrate,
      // AM
      rate_in_inr,
      // AN
      taxable_value,
      // AV
      Igst,
      // AZ
      Sgst,
      // AX
      Cgst,
      // AQ
      taxable_value_dis,
      // AR
      freight_charge_inr,
      // AS
      insurance_rate,
      // AT
      insurance_amt,
      // BA
      rateugst,
      // BB
      ugst,
      // BE
      Roundoff,
      // AP
      Discount,
      // AO
      ratediscount,
      // BF
      Totalamount,
      // AU
      Rateigst,
      // AW
      Ratecgst,
      // AY
      Ratesgst,
      // BC
      Ratetcs,
      // BD
      Tcs,
      cancelledinvoice,
      Cancelled,
      salesorganisation,
      distributionchannel,
      division,
      salesquotationdate,
      _BillingDoc : redirected to parent ZC_BillingDocTP

}
