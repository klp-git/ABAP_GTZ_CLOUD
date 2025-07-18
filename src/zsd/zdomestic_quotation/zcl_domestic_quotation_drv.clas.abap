CLASS zcl_domestic_quotation_drv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*    INTERFACES if_oo_adt_classrun.

    CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
    CLASS-DATA : var1 TYPE vbeln.
    TYPES :
      BEGIN OF struct,
        xdp_template TYPE string,
        xml_data     TYPE string,
        form_type    TYPE string,
        form_locale  TYPE string,
        tagged_pdf   TYPE string,
        embed_font   TYPE string,
      END OF struct.


    CLASS-METHODS :
      create_client
        IMPORTING url           TYPE string
        RETURNING VALUE(result) TYPE REF TO if_web_http_client
        RAISING   cx_static_check ,

      read_posts
        IMPORTING saleQuotNo      TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .


  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zsd_domestic_quotation/zsd_domestic_quotation'.
ENDCLASS.



CLASS ZCL_DOMESTIC_QUOTATION_DRV IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).
  ENDMETHOD .


  METHOD read_posts.

    """"""""""""""""""""""""""""plant address """""""""""""""""""""""""""""""""""""""""""

    SELECT SINGLE
        a~billingdocumentdate,  """"""" date
        "a~documentreferenceid,  """""""""" invoice number
        c~gstin_no ,
        c~state_code2 ,
        c~plant_name1 ,
        c~address1 ,
        c~address2 ,
        c~city ,
        c~district ,
        c~state_name ,
        c~pin ,
        c~country,
        c~cin_no,
        a~BINDINGPERIODVALIDITYENDDATE

        FROM i_salesquotation AS a
        LEFT JOIN i_salesquotationitem AS b ON b~salesquotation = a~salesquotation
        LEFT JOIN ztable_plant AS c ON c~plant_code = b~plant
        WHERE b~SalesQuotation = @saleQuotNo
       INTO @DATA(wa_plant).

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    SELECT  SINGLE

    a~salesquotation,
    a~salesquotationdate,
    b~YY1_POAmendmentDate_SDH,
    a~customerpaymentterms,
    a~IncotermsLocation1,
    b~yy1_sales_remarks_sdh,
    c~PaymentTermsName
    FROM I_SalesQuotation WITH PRIVILEGED ACCESS AS a
    LEFT JOIN  I_SalesQuotationTP  WITH PRIVILEGED ACCESS AS b ON a~SalesQuotation = b~SalesQuotation
    LEFT JOIN i_paymenttermstext WITH PRIVILEGED ACCESS AS c ON a~CustomerPaymentTerms = c~PaymentTerms AND c~Language = 'E'
    WHERE a~SalesQuotation = @saleQuotNo
    INTO @DATA(wa_header).


    """""""""""""details bill to"""""""""""""""""""""''

    SELECT SINGLE
    a~salesquotation,
    a~soldtoparty,
    b~TaxNumber3,
    b~bpcustomerfullname,
    b~addressid,
    c~streetname ,         " bill to add
    c~streetprefixname1 ,   " bill to add
    c~streetprefixname2 ,   " bill to add
    c~cityname ,   " bill to add
    c~region ,  "bill to add
    c~postalcode ,   " bill to add
    c~districtname ,   " bill to add
    c~country  ,
    c~housenumber,
    d~regionname,
    c~streetsuffixname1,
    c~streetsuffixname2,
    e~bpidentificationnumber



    FROM I_SalesQuotation WITH PRIVILEGED ACCESS AS a
    LEFT JOIN i_customer WITH PRIVILEGED ACCESS AS b ON a~SoldToParty = b~Customer
    LEFT JOIN i_address_2 WITH PRIVILEGED ACCESS AS c ON b~AddressID = c~AddressID
    LEFT JOIN I_RegionText AS d ON c~Region = d~Region AND c~Country = d~Country
    LEFT JOIN I_BuPaIdentification AS e ON a~SoldToParty = e~BusinessPartner AND e~BPIdentificationType = 'CIN'
    WHERE a~SalesQuotation = @saleQuotNo
    INTO @DATA(Billto).


    """""""""""""""""""""""""""""""ship to """"""""""""""""""""""
    SELECT SINGLE
      d~streetname ,         " ship to add
      d~streetprefixname1 ,   " ship to add
      d~streetprefixname2 ,   " ship to add
      d~cityname ,   " ship to add
      d~region ,  "ship to add
      d~postalcode ,   " ship to add
      d~districtname ,   " ship to add
      d~country ,
      d~housenumber ,
      c~customername ,
      e~RegionName,
      c~taxnumber3,
      c~bpcustomerfullname
     FROM i_salesdocumentitem AS a
     LEFT JOIN i_customer AS c ON a~ShipToParty = c~Customer
     LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
     LEFT JOIN I_RegionText AS e ON e~Region = d~Region AND e~Country = d~country
     WHERE c~Language = 'E' AND a~SalesDocument = @saleQuotNo
     INTO @DATA(wa_ship)
     PRIVILEGED ACCESS.

    """""""""""""""""""""""""""""""""""'header xml """"""""""""""""""""""""""""""""""""

    DATA: lv_plant_gstin_len TYPE i.
    lv_plant_gstin_len = strlen( wa_plant-gstin_no ).
    lv_plant_gstin_len = lv_plant_gstin_len - 2.
    DATA : lv_plant_pan TYPE string.
    IF wa_plant-gstin_no IS NOT INITIAL.
*      lv_plant_pan = wa_plant-gstin_no+2(lv_plant_gstin_len).
      lv_plant_pan = wa_plant-gstin_no+2(10).
    ENDIF.

    DATA(lv_statecode_name) = wa_plant-state_code2 && '-' && wa_plant-state_name.

    DATA plantaddstring TYPE string.
    CONCATENATE wa_plant-address1 wa_plant-address2 wa_plant-city wa_plant-district wa_plant-state_name wa_plant-pin INTO plantaddstring SEPARATED BY space.

    DATA billadd TYPE string.
    CONCATENATE Billto-HouseNumber Billto-streetname Billto-StreetPrefixName1 Billto-StreetPrefixName2
    Billto-CityName Billto-PostalCode Billto-DistrictName
    "" Billto-Country
      INTO billadd SEPARATED BY space.

    DATA: billpan TYPE string.
    DATA(lv_billto_gstin_len) = strlen( billto-TaxNumber3 ).
    IF billto-TaxNumber3 IS NOT INITIAL.
      lv_billto_gstin_len = lv_billto_gstin_len - 2.
      billpan = billto-TaxNumber3+2(lv_billto_gstin_len).
    ENDIF.

    DATA: billstatecode TYPE string.
    billstatecode = billto-TaxNumber3+0(2).
    CONCATENATE billstatecode '-' billto-RegionName INTO billstatecode SEPARATED BY space.

    DATA shipadd TYPE string.
    CONCATENATE wa_ship-HouseNumber wa_ship-streetname wa_ship-StreetPrefixName1 wa_ship-StreetPrefixName2
    wa_ship-CityName wa_ship-PostalCode wa_ship-DistrictName
    ""wa_ship-Country
    INTO shipadd SEPARATED BY space.

    DATA: shipstatecode TYPE string.
    IF wa_ship-TaxNumber3 IS NOT INITIAL.
      shipstatecode = wa_ship-TaxNumber3+0(2).
    ENDIF.
    CONCATENATE shipstatecode '-' wa_ship-RegionName INTO shipstatecode SEPARATED BY space.

    SELECT SINGLE FROM
    I_SalesQuotation AS a
    FIELDS
    a~purchaseorderbycustomer,
    a~customerpurchaseorderdate
    WHERE a~SalesQuotation = @salequotno
    INTO @DATA(lv_amend).


    DATA(lv_xml) =
    |<form>| &&
    |<header>| &&
    |<supplier>| &&
    |<plantgstin>{ wa_plant-gstin_no }</plantgstin>| &&
    |<plantname>{ wa_plant-plant_name1 }</plantname>| &&
    |<plantadd>{ plantaddstring }</plantadd>| &&
    |<plantstatecode>{ lv_statecode_name }</plantstatecode>| &&
    |<plantpan>{ lv_plant_pan }</plantpan>| &&
    |<plantcin>{ wa_plant-cin_no }</plantcin>| &&
    |</supplier>| &&
    |<billto>| &&
    |<billgstin>{ Billto-TaxNumber3 }</billgstin>| &&
    |<billname>{ billto-bpcustomerfullname }</billname>| &&
    |<billadd>{ billadd }</billadd>| &&
    |<billstate>{ billstatecode }</billstate>| &&
    |<billpan>{ billpan }</billpan>| &&
    |<billcin>{ Billto-BPIdentificationNumber }</billcin>| &&
    |<billplaceof>{ billstatecode }</billplaceof>| &&
    |</billto>| &&
    |<invoice>| &&
    |<invoiceno>{ wa_header-SalesQuotation }</invoiceno>| &&
    |<invoicdate>{ wa_header-SalesQuotationDate+6(2) && '/' && wa_header-SalesQuotationDate+4(2) && '/' && wa_header-SalesQuotationDate(4) }</invoicdate>| &&
    |<po_no>{ lv_amend-PurchaseOrderByCustomer }</po_no>| &&
    |<po_date>{ lv_amend-CustomerPurchaseOrderDate+6(2) && '/' && lv_amend-CustomerPurchaseOrderDate+4(2) && '/' && lv_amend-CustomerPurchaseOrderDate(4) }</po_date>| &&
    |<amendmentno></amendmentno>| &&
    |<amendmentdate></amendmentdate>| &&
    |<BINDINGPERIODVALIDITYENDDATE>{ wa_plant-BindingPeriodValidityEndDate }</BINDINGPERIODVALIDITYENDDATE>| &&
    |</invoice>| &&
    |<shipto>| &&
    |<shipgstin>{ wa_ship-TaxNumber3 }</shipgstin>| &&
    |<shipname>{ wa_ship-bpcustomerfullname }</shipname>| &&
    |<shipadd>{ shipadd }</shipadd>| &&
    |<shipstate>{ shipstatecode }</shipstate>| &&
    |</shipto>| &&
    |</header>| &&
    |<items>|.


    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    """"""""""""""""""""""""""""""""item""""""""""""""""""""

    SELECT

    a~material,
    a~product,
    a~SalesQuotation,
    a~salesquotationitemtext,
    a~orderquantity,
    a~yy1_packsize_sd_sdiu,
    a~yy1_noofpack_sd_sdi,  """"""""""" no of pack size""""""""""""
    a~baseunit,
    b~consumptiontaxctrlcode,
    a~Salesquotationitem,
    a~materialbycustomer

    FROM I_Salesquotationitem WITH PRIVILEGED ACCESS AS a
    LEFT JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS b ON a~Material = b~Product AND a~Plant = b~Plant
    WHERE a~SalesQuotation = @saleQuotNo
    INTO TABLE @DATA(it_item).

    """"""""""""""""""""""""""""""" gst""""""""""""


    SELECT

    a~conditionamount,   """"condition value
    a~conditionrateamount,  """""""""""""" condition amount
    a~conditiontype           """"""""""""""""condition type

    FROM i_salesquotationitemprcgelmnt WITH PRIVILEGED ACCESS AS a

    WHERE  a~SalesQuotation = @saleQuotNo

    INTO TABLE @DATA(gstvalue).

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    DATA: lv_total_gross_amount TYPE p DECIMALS 2.
    DATA: lv_igsttotal TYPE p DECIMALS 2.
    DATA: lv_cgsttotal TYPE p DECIMALS 2.
    DATA: lv_sgsttotal TYPE p DECIMALS 2.
    DATA: lv_totaltaxable TYPE p DECIMALS 2.
    DATA str1 TYPE string.
    DATA str2 TYPE string.
    LOOP AT it_item INTO DATA(wa_it_item).

      DATA: ztrade_pr TYPE zmaterial_table-mat.
      ztrade_pr = wa_it_item-Product.
      SHIFT ztrade_pr LEFT DELETING LEADING '0'.
      SELECT SINGLE
      a~trade_name
      FROM zmaterial_table AS a
      WHERE a~mat = @ztrade_pr
      INTO @DATA(wa_item3).
      IF wa_item3 IS NOT INITIAL.
        wa_it_item-SalesQuotationItemText = wa_item3.
      ELSE.

        SELECT SINGLE
        a~productname
        FROM i_producttext AS a
        WHERE a~product = @wa_it_item-Product
        INTO @DATA(wa_item4).

        wa_it_item-SalesQuotationItemText = wa_item4.

      ENDIF.

      SELECT SINGLE
      FROM i_salesquotationitemprcgelmnt AS a
      FIELDS
      a~ConditionAmount,
      a~ConditionType,
      a~ConditionRateValue
      WHERE a~SalesQuotation = @salequotno AND a~SalesQuotationItem = @wa_it_item-SalesQuotationItem
      AND a~ConditionType = 'ZBSP'
      INTO @DATA(wa_rate).

      SELECT SINGLE
      FROM i_salesquotationitemprcgelmnt AS a
      FIELDS
      a~ConditionAmount,
      a~ConditionType,
      a~ConditionRateValue
      WHERE a~SalesQuotation = @salequotno AND a~SalesQuotationItem = @wa_it_item-SalesQuotationItem
      AND a~ConditionType = 'ZDIS'
      INTO @DATA(wa_dis).

      DATA: lv_val TYPE p DECIMALS 2.
      DATA: lv_tax TYPE p DECIMALS 2.

      lv_val = wa_rate-ConditionRateValue * wa_it_item-OrderQuantity.
      lv_tax = lv_val + wa_dis-ConditionAmount.

      SELECT SINGLE
      FROM i_salesquotationitemprcgelmnt AS a
      FIELDS
      a~ConditionAmount,
      a~ConditionType,
      a~ConditionRateValue
      WHERE a~SalesQuotation = @salequotno AND a~SalesQuotationItem = @wa_it_item-SalesQuotationItem
      AND a~ConditionType = 'JOCG'
      INTO @DATA(wa_cgst).

      CLEAR wa_cgst-ConditionAmount.
      wa_cgst-ConditionAmount = lv_tax * ( wa_cgst-ConditionRateValue / 100 ).

      SELECT SINGLE
      FROM i_salesquotationitemprcgelmnt AS a
      FIELDS
      a~ConditionAmount,
      a~ConditionType,
      a~ConditionRateValue
      WHERE a~SalesQuotation = @salequotno AND a~SalesQuotationItem = @wa_it_item-SalesQuotationItem
      AND a~ConditionType = 'JOSG'
      INTO @DATA(wa_sgst).

      CLEAR wa_sgst-ConditionAmount.
      wa_sgst-ConditionAmount = lv_tax * ( wa_sgst-ConditionRateValue / 100 ).

      SELECT SINGLE
      FROM i_salesquotationitemprcgelmnt AS a
      FIELDS
      a~ConditionAmount,
      a~ConditionType,
      a~ConditionRateValue
      WHERE a~SalesQuotation = @salequotno AND a~SalesQuotationItem = @wa_it_item-SalesQuotationItem
      AND a~ConditionType = 'JOIG'
      INTO @DATA(wa_igst).

      CLEAR wa_igst-ConditionAmount.
      wa_igst-ConditionAmount = lv_tax * ( wa_igst-ConditionRateValue / 100 ).

      DATA: lv_grossamount TYPE p DECIMALS 2.
      lv_grossamount = lv_tax + wa_cgst-ConditionAmount + wa_sgst-ConditionAmount + wa_igst-ConditionAmount.

      SELECT SINGLE
      FROM i_salesquotationitemprcgelmnt AS a
      FIELDS
      a~ConditionAmount,
      a~ConditionType,
      a~ConditionRateValue
      WHERE a~SalesQuotation = @salequotno AND a~SalesQuotationItem = @wa_it_item-SalesQuotationItem
      AND a~ConditionType = 'ZFRT'
      INTO @DATA(wa_frt).

      SELECT SINGLE
      FROM i_salesquotationitemprcgelmnt AS a
      FIELDS
      a~ConditionAmount,
      a~ConditionType,
      a~ConditionRateValue
      WHERE a~SalesQuotation = @salequotno AND a~SalesQuotationItem = @wa_it_item-SalesQuotationItem
      AND a~ConditionType IN ( 'ZINC','ZINP','ZINS' )
      INTO @DATA(wa_ins).

      DATA: lv_fr_tax TYPE p DECIMALS 2.
      DATA: lv_fr_cr TYPE p DECIMALS 2.
      DATA: lv_fr_ca TYPE p DECIMALS 2.
      DATA: lv_fr_sr TYPE p DECIMALS 2.
      DATA: lv_fr_sa TYPE p DECIMALS 2.
      DATA: lv_fr_ir TYPE p DECIMALS 2.
      DATA: lv_fr_ia TYPE p DECIMALS 2.

      DATA: lv_in_tax TYPE p DECIMALS 2.
      DATA: lv_in_cr TYPE p DECIMALS 2.
      DATA: lv_in_sr TYPE p DECIMALS 2.
      DATA: lv_in_ir TYPE p DECIMALS 2.
      DATA: lv_in_ia TYPE p DECIMALS 2.
      DATA: lv_in_sa TYPE p DECIMALS 2.
      DATA: lv_in_ca TYPE p DECIMALS 2.

      lv_fr_tax += wa_frt-ConditionAmount.
      lv_fr_cr = wa_cgst-ConditionRateValue.
      lv_fr_sr = wa_sgst-ConditionRateValue.
      lv_fr_ir = wa_igst-ConditionRateValue.

      lv_in_tax += wa_ins-ConditionAmount.
      lv_in_cr = wa_cgst-ConditionRateValue.
      lv_in_sr = wa_sgst-ConditionRateValue.
      lv_in_ir = wa_igst-ConditionRateValue.

      lv_total_gross_amount += lv_grossamount.
      lv_igsttotal += wa_igst-ConditionAmount.
      lv_cgsttotal += wa_cgst-ConditionAmount.
      lv_sgsttotal += wa_sgst-ConditionAmount.
      lv_totaltaxable += lv_tax.

      str2 = wa_it_item-materialbycustomer.
      SHIFT str2 LEFT DELETING LEADING '0'.
      DATA(newline) = cl_abap_char_utilities=>newline.
      CONCATENATE wa_it_item-SalesQuotationItemText newline
      str2 INTO str1.


      DATA(lv_itemxml) =
      |<item>| &&
*      |<Description_of_goods>{ wa_it_item-SalesQuotationItemText }</Description_of_goods>| &&
      |<Description_of_goods>{ str1 }</Description_of_goods>| &&
      |<HSN_code>{ wa_it_item-ConsumptionTaxCtrlCode }</HSN_code>| &&
      |<pack_size>{ wa_it_item-YY1_NoofPack_sd_SDI }</pack_size>| &&
      |<No_of_Pack></No_of_Pack>| &&
      |<Qty>{ wa_it_item-OrderQuantity }</Qty>| &&
      |<Uom>{ wa_it_item-BaseUnit }</Uom>| &&
      |<rate>{ wa_rate-ConditionRateValue }</rate>| &&
      |<valofsup>{ lv_val }</valofsup>| &&
      |<dis>{ wa_dis-ConditionRateValue * -1 }</dis>| &&
      |<taxable>{ lv_tax }</taxable>| &&
      |<cgstrate>{ wa_cgst-ConditionRateValue }</cgstrate>| &&
      |<cgstamount>{ wa_cgst-ConditionAmount }</cgstamount>| &&
      |<sgstrate>{ wa_sgst-ConditionRateValue }</sgstrate>| &&
      |<sgstamount>{ wa_sgst-ConditionAmount }</sgstamount>| &&
      |<igstrate>{ wa_igst-ConditionRateValue }</igstrate>| &&
      |<igstamount>{ wa_igst-ConditionAmount }</igstamount>| &&
      |<grossamount>{ lv_grossamount }</grossamount>| &&
      |</item>|.

      CONCATENATE lv_xml lv_itemxml INTO lv_xml.
      clear str2.
      clear str1.
      clear wa_it_item.

    ENDLOOP.

    DATA: fgross_fr TYPE p DECIMALS 2.

    lv_fr_ia = ( lv_fr_tax * lv_fr_ir ) / 100.
    lv_fr_sa = ( lv_fr_tax * lv_fr_sr ) / 100.
    lv_fr_ca = ( lv_fr_tax * lv_fr_cr ) / 100.

    fgross_fr = lv_fr_tax + lv_fr_ia + lv_fr_sa + lv_fr_ca.

    DATA: fgross_in TYPE p DECIMALS 2.

    lv_in_ia = ( lv_in_tax * lv_in_ir ) / 100.
    lv_in_sa = ( lv_in_tax * lv_in_sr ) / 100.
    lv_in_ca = ( lv_in_tax * lv_in_cr ) / 100.

    fgross_in = lv_in_tax + lv_in_ia + lv_in_sa + lv_in_ca.

    lv_total_gross_amount += fgross_fr + fgross_in.
    lv_igsttotal += lv_fr_ia + lv_in_ia.
    lv_cgsttotal += lv_fr_ca + lv_in_ca.
    lv_sgsttotal += lv_fr_sa + lv_in_sa.
    lv_totaltaxable += lv_fr_tax + lv_in_tax.

    DATA: total_gst TYPE p DECIMALS 2.

    total_gst = lv_igsttotal + lv_cgsttotal + lv_sgsttotal.

    DATA(lv_footer) =
    |</items>| &&
    |<footer>| &&
    |<fr_tax>{ lv_fr_tax }</fr_tax>| &&
    |<fr_cr>{ lv_fr_cr }</fr_cr>| &&
    |<fr_ca>{ lv_fr_ca }</fr_ca>| &&
    |<fr_sr>{ lv_fr_sr }</fr_sr>| &&
    |<fr_sa>{ lv_fr_sa }</fr_sa>| &&
    |<fr_ir>{ lv_fr_ir }</fr_ir>| &&
    |<fr_ia>{ lv_fr_ia }</fr_ia>| &&
    |<fgross_fr>{ fgross_fr }</fgross_fr>| &&
    |<in_tax>{ lv_in_tax }</in_tax>| &&
    |<in_cr>{ lv_in_cr }</in_cr>| &&
    |<in_ca>{ lv_in_ca }</in_ca>| &&
    |<in_sr>{ lv_in_sr }</in_sr>| &&
    |<in_sa>{ lv_in_sa }</in_sa>| &&
    |<in_ir>{ lv_in_ir }</in_ir>| &&
    |<in_ia>{ lv_in_ia }</in_ia>| &&
    |<fgross_in>{ fgross_in }</fgross_in>| &&
    |<AmountBeforeTax>{ lv_totaltaxable }</AmountBeforeTax>| &&
    |<totalgrossamount>{ lv_total_gross_amount }</totalgrossamount>| &&
    |<igsttotal>{ lv_igsttotal }</igsttotal>| &&
    |<sgsttotal>{ lv_sgsttotal }</sgsttotal>| &&
    |<cgsttotal>{ lv_cgsttotal }</cgsttotal>| &&
    |<totaltaxable>{ lv_totaltaxable }</totaltaxable>| &&
    |<totalval></totalval>| &&
    |<cgstTax>{ lv_fr_ca }</cgstTax>| &&
    |<sgstTax>{ lv_fr_sa }</sgstTax>| &&
    |<igstTax>{ lv_fr_ia }</igstTax>| &&
    |<gst>{ total_gst }</gst>| &&
    |<AmountAfterTax>{ lv_total_gross_amount }</AmountAfterTax>| &&
    |<despatchTerm>{ wa_header-IncotermsLocation1 }</despatchTerm>| &&
    |<InsuranceTerm></InsuranceTerm>| &&
    |<PaymentTerm>{ wa_header-PaymentTermsName }</PaymentTerm>| &&
    |<Remarks>{ wa_header-YY1_Sales_remarks_SDH }</Remarks>| &&
    |</footer>|.

    CONCATENATE lv_xml lv_footer INTO lv_xml.

    DATA(lv_last) =
    |</form>|.

    CONCATENATE lv_xml lv_last INTO lv_xml.



    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).








  ENDMETHOD.
ENDCLASS.
