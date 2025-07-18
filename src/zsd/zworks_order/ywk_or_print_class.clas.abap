CLASS ywk_or_print_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*    INTERFACES if_oo_adt_classrun .
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
      END OF struct."


    CLASS-METHODS :
      create_client
        IMPORTING url           TYPE string
        RETURNING VALUE(result) TYPE REF TO if_web_http_client
        RAISING   cx_static_check ,

      read_posts
        IMPORTING salesorderno    TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zsd_worksorder/zsd_worksorder'."'zpo/zpo_v2'."
ENDCLASS.



CLASS YWK_OR_PRINT_CLASS IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts.
*  METHOD if_oo_adt_classrun~main.
    var1 = salesorderno.
    var1 =   |{ |{ var1 ALPHA = OUT }| ALPHA = IN }| .
    DATA(lv_salesorderno) = var1.
****************************************  header data ******************************************************
    SELECT SINGLE
    a~purchaseorderbycustomer,
        a~customerpurchaseorderdate,
        a~yy1_poamendmentno_sdh,
        a~yy1_precarriageby_sdh,
            a~yy1_poamendmentdate_sdh,
                a~yy1_dono_sdh,
                    a~yy1_dodate_sdh,
                    b~customerName,
                    b~BpcustomerName,
                    b~streetName,
                    b~BPAddrCityName,
                    b~BPAddrStreetName,
                    b~DistrictName,
                    b~postalcode,
                    b~TaxNumber3,
                    a~customerpaymentterms,
                    b~Region,
                    b~CustomerAccountGroup,
                    b~country,
                    a~soldtoparty,
                    a~soldtoparty AS gtz_cust_code,
                    a~salesdocument,
                    a~creationdate,
                    a~RequestedDeliveryDate,
*                    a~YY1_TCSAmount_SDH,
                    a~transactioncurrency,
                    a~YY1_Remarks_SO_sdh,
                    c~customerPaymentTermsName,
                    d~supplierName,
                    d~taxnumber3 AS suppliergst,
                    e~countryName,
                    b~AddressID,
                    f~region AS addressregion,
                    f~country AS addresscountry,
                    g~regionname,
                    h~BusinessPartnerIDByExtSystem,
                    i~CustomerPaymentTermsName AS paymentterms

     FROM i_salesdocument WITH PRIVILEGED ACCESS  AS a LEFT JOIN
     i_customer WITH PRIVILEGED ACCESS  AS b ON a~soldtoparty = b~Customer LEFT JOIN

     I_CustomerPaymentTermsText WITH PRIVILEGED ACCESS  AS c ON a~customerPaymentTerms = c~customerPaymentTerms LEFT JOIN
     i_supplier WITH PRIVILEGED ACCESS  AS d ON a~yy1_TransportName_SDH = d~supplier LEFT JOIN
      i_countrytext WITH PRIVILEGED ACCESS  AS e ON b~country = e~Country
      LEFT JOIN i_address_2 WITH PRIVILEGED ACCESS AS f ON b~AddressID = f~AddressID
      LEFT JOIN i_regiontext WITH PRIVILEGED ACCESS AS g ON f~Region = g~Region AND f~Country = g~Country AND g~language = 'E'
      LEFT JOIN i_businesspartner WITH PRIVILEGED ACCESS AS h ON a~SoldToParty = h~BusinessPartner
    LEFT JOIN i_customerpaymenttermstext WITH PRIVILEGED ACCESS AS i ON a~CustomerPaymentTerms = i~CustomerPaymentTerms AND  i~Language = 'E'

    WHERE a~salesdocument EQ @lv_salesorderno
    INTO @DATA(wa_header1).

    DATA: modedispatch TYPE string.
    IF wa_header1-YY1_PreCarriageby_SDH = 'A'.
      modedispatch = 'Air'.
    ELSEIF wa_header1-YY1_PreCarriageby_SDH = 'R'.
      modedispatch = 'Road'.
    ELSEIF wa_header1-YY1_PreCarriageby_SDH = 'S'.
      modedispatch = 'Ship'.
    ELSEIF wa_header1-YY1_PreCarriageby_SDH = 'T'.
      modedispatch = 'Rail'.
    ENDIF.

    DATA : transportename TYPE string.
    CONCATENATE wa_header1-SupplierName '-' wa_header1-suppliergst INTO transportename.
    DATA : state_code2 TYPE string.
    state_code2 = wa_header1-TaxNumber3.

    SELECT SINGLE
    b~customerName,
    b~streetName,
    b~BPAddrStreetName,
    b~BPAddrCityName,
    b~DistrictName,
    b~postalcode,
    b~TaxNumber3,
    b~Region,
    b~CustomerAccountGroup,
    b~country,
    c~plantname,
    c~plant,
    d~countryName ,
    b~addressid,
     f~region AS addressregion,
     f~country AS addresscountry,
     g~regionname,
     b~BpcustomerName
     FROM i_salesdocumentitem  WITH PRIVILEGED ACCESS  AS a LEFT JOIN
     i_customer  WITH PRIVILEGED ACCESS  AS b ON a~shiptoparty = b~Customer LEFT JOIN
     i_plant  WITH PRIVILEGED ACCESS  AS c ON a~plant = c~plant LEFT JOIN
     i_countrytext  WITH PRIVILEGED ACCESS  AS d ON b~country = d~Country
      LEFT JOIN i_address_2 WITH PRIVILEGED ACCESS AS f ON b~AddressID = f~AddressID
       LEFT JOIN i_regiontext WITH PRIVILEGED ACCESS AS g ON f~Region = g~Region AND f~Country = g~Country AND g~language = 'E'
*     left join i_address_2 WITH PRIVILEGED ACCESS as e on e~addressid = b~AddressID
    WHERE a~salesdocument EQ  @lv_salesorderno
    INTO @DATA(wa_header2).
    DATA : state_codesihpto  TYPE string.
    state_codesihpto = wa_header2-TaxNumber3.
    "add by vishal
    "Buyer Address
    IF wa_header1-AddressID IS NOT INITIAL.
      SELECT SINGLE FROM i_address_2 WITH PRIVILEGED ACCESS
      FIELDS streetname , streetprefixname1 , streetprefixname2 , cityname , HouseNumber ,
             postalcode , districtname , country
             WHERE AddressID = @wa_header1-AddressID
             INTO @DATA(wa_header3).



*      wa_header1-BPAddrStreetName = wa_header3-StreetName.
      CONCATENATE  wa_header3-HouseNumber wa_header3-StreetName
                  INTO wa_header1-BPAddrStreetName SEPARATED BY ' '.

      IF wa_header3-streetprefixname1 <> ',' .
        CONCATENATE wa_header3-streetprefixname1 ' ' INTO wa_header1-BPAddrCityName.
      ENDIF.

      IF wa_header3-StreetPrefixName2 <> ','.
        CONCATENATE wa_header1-BPAddrCityName wa_header3-StreetPrefixName2
         INTO wa_header1-BPAddrCityName SEPARATED BY ' '.
      ENDIF.

      wa_header1-DistrictName = wa_header3-DistrictName.
      CONCATENATE wa_header3-streetName wa_header3-PostalCode INTO wa_header1-streetName SEPARATED BY ' ' .
      wa_header1-PostalCode = wa_header3-PostalCode.
*           wa_header1-BPAddrStreetName = wa_header3-PostalCode.

    ENDIF.


    " Consignee Adres
    IF wa_header2-AddressID IS NOT INITIAL.
      SELECT SINGLE FROM i_address_2 WITH PRIVILEGED ACCESS
       FIELDS streetname , streetprefixname1 , streetprefixname2 , cityname , HouseNumber ,
              postalcode , districtname , country
              WHERE AddressID = @wa_header2-AddressID
              INTO @DATA(wa_header4).


      CONCATENATE  wa_header4-HouseNumber wa_header4-StreetName
                INTO wa_header2-BPAddrStreetName SEPARATED BY ' '.

      IF wa_header4-streetprefixname1 <> ',' .
        CONCATENATE wa_header4-streetprefixname1 ' ' INTO wa_header2-BPAddrCityName.
      ENDIF.

      IF wa_header4-StreetPrefixName2 <> ','.
        CONCATENATE wa_header2-BPAddrCityName wa_header4-StreetPrefixName2
         INTO wa_header2-BPAddrCityName SEPARATED BY ' '.
      ENDIF.

      wa_header2-DistrictName = wa_header4-DistrictName.
      wa_header2-PostalCode = wa_header4-PostalCode.
      CONCATENATE wa_header4-streetName wa_header4-PostalCode INTO wa_header2-streetName SEPARATED BY ' ' .


    ENDIF.



*    out->write( wa_header1 ).
*    out->write( wa_header2 ).


*******************************************************    line item data  ******************************
    SELECT
    a~salesdocument,
    a~salesdocumentitem,
    a~Salesdocumentitemtext,
    a~OrderQuantity,
    a~netpricequantityunit,
    a~product,
    a~yy1_packsize_sd_sdi,
    b~consumptiontaxctrlcode,
    c~pricedetnexchangerate
    FROM i_salesdocumentitem WITH PRIVILEGED ACCESS  AS a LEFT JOIN
    i_productplantbasic WITH PRIVILEGED ACCESS  AS b ON a~product = b~Product AND a~Plant = b~Plant
    LEFT JOIN i_salesdocument WITH PRIVILEGED ACCESS AS c ON a~SalesDocument = c~SalesDocument
    WHERE a~salesdocument =  @lv_salesorderno  AND consumptiontaxctrlcode IS NOT INITIAL
    INTO TABLE @DATA(it_line).

*    TYPES: BEGIN OF ty_itlines2,
*             salesdocument      TYPE i_salesdocitempricingelement-SalesDocument,
*             salesdocumentitem  TYPE i_salesdocitempricingelement-SalesDocumentItem,
*             conditionratevalue TYPE i_salesdocitempricingelement-conditionratevalue,
*             conditionamount    TYPE i_salesdocitempricingelement-conditionamount,
*             conditionbasevalue TYPE i_salesdocitempricingelement-conditionbasevalue,
*             conditiontype      TYPE i_salesdocitempricingelement-conditiontype,
*           END OF ty_itlines2.
*
*    DATA wa_lines2 TYPE ty_itlines2.
*    DATA it_line2 TYPE TABLE OF ty_itlines2.

*    IF it_line IS NOT INITIAL.
*      SELECT
*      a~salesdocument,
*      a~salesdocumentitem,
*      a~conditionratevalue,
*         a~conditionamount,
*         a~conditionbasevalue,
*         a~conditiontype
*         FROM i_salesdocitempricingelement as a
*         FOR ALL ENTRIES IN @it_line
*         WHERE a~salesdocument =  @it_line-salesdocument AND a~salesdocumentitem =  @it_line-salesdocumentitem
*         INTO TABLE @DATA(it_line2) PRIVILEGED ACCESS.
*
*    ENDIF.
    IF it_line IS NOT INITIAL.

      SELECT
        a~salesdocument,
        a~salesdocumentitem,
        a~conditionratevalue,
        a~conditionamount,
        a~conditionbasevalue,
        a~conditiontype
        FROM i_salesdocitempricingelement WITH PRIVILEGED ACCESS AS a
        INNER JOIN @it_line AS b
        ON a~salesdocument = b~salesdocument
        AND a~salesdocumentitem = b~salesdocumentitem
        INTO TABLE @DATA(it_line2).

    ENDIF.

*    DELETE it_line where CONSUMPTIONTAXCTRLCODE is INITIAL.

*    out->write( it_line ).
*    out->write( '  ' ).
*    out->write( it_line2 ).

*************************************************    header xml ***********************************************

    IF wa_header1-Country = 'IN' AND wa_header1-RegionName = 'Chhattīsgarh'.
      wa_header1-RegionName = 'Chhattisgarh'.
    ENDIF.
    IF wa_header2-Country = 'IN' AND wa_header2-RegionName = 'Chhattīsgarh'.
      wa_header2-RegionName = 'Chhattisgarh'.
    ENDIF.

    DATA(lv_xml) =
    |<Form>| &&
    |<header>| &&
    |<po_no>{ wa_header1-purchaseorderbycustomer }</po_no>| &&
    |<dated1>{ wa_header1-customerpurchaseorderdate }</dated1>| &&
    |<amd_po_no>{ wa_header1-yy1_poamendmentno_sdh }</amd_po_no>| &&
    |<dated2>{ wa_header1-yy1_poamendmentdate_sdh }</dated2>| &&
    |<do_no>{ wa_header1-YY1_DONo_SDH }</do_no>| &&
    |<date>{ wa_header1-YY1_DODate_SDH }</date>| &&
    |<buyer>{ wa_header1-BpcustomerName }</buyer>| &&
    |<buyer_address1>{ wa_header1-streetName }</buyer_address1>| &&
    |<buyer_address2>{ wa_header1-BPAddrStreetName }</buyer_address2>| && "1
    |<buyer_address3>{ wa_header1-DistrictName }</buyer_address3>| &&  "3
    |<buyer_address4>{ wa_header1-postalcode }</buyer_address4>| &&
    |<buyer_address5>{ wa_header1-BPAddrCityName }</buyer_address5>| && "2
    |<buyer_gstin>{ wa_header1-TaxNumber3 }</buyer_gstin>| &&
    |<Payment_terms>{ wa_header1-CustomerPaymentTermsName }</Payment_terms>| &&
    |<buyer_state>{ state_code2 }</buyer_state>| &&
    |<buyer_state_Name>{ wa_header1-RegionName }</buyer_state_Name>| &&
    |<party_code>{ wa_header1-soldtoparty }</party_code>| &&
    |<consignee_name>{ wa_header2-BpcustomerName }</consignee_name>| &&
    |<consignee_address1>{ wa_header2-StreetName }</consignee_address1>| &&
    |<consignee_address2>{ wa_header2-BPAddrStreetName }</consignee_address2>| && "1
    |<consignee_address3>{ wa_header2-DistrictName }</consignee_address3>| &&   "3
    |<consignee_address4>{ wa_header2-PostalCode }</consignee_address4>| &&
    |<consignee_address5>{ wa_header2-BPAddrCityName }</consignee_address5>| && " 2
    |<consignee_gstin>{ wa_header2-TaxNumber3 }</consignee_gstin>| &&
    """"""""""""""""""""""""""""""""""""'
    |<consignee_state>{ state_codesihpto }</consignee_state>| &&
    |<consignee_state_Name>{ wa_header2-RegionName }</consignee_state_Name>| &&
    |<gtz_customer_code>{ wa_header1-BusinessPartnerIDByExtSystem }</gtz_customer_code>| &&
    |<work_order_no>{ wa_header1-salesdocument }</work_order_no>| &&
    |<work_order_date>{ wa_header1-CreationDate }</work_order_date>| &&
    |<c_c>{ wa_header2-PlantName }</c_c>| &&
    |<plant>{ wa_header2-Plant }</plant>| &&
    |<tr_currency>{ wa_header1-TransactionCurrency }</tr_currency>| &&
    |<Mode_Of_Dispatch>{ modedispatch }</Mode_Of_Dispatch>| &&
    |<remarks>{ wa_header1-YY1_Remarks_SO_sdh }</remarks>|.

    IF wa_header1-CustomerAccountGroup = 'ZEXP'.
      DATA(lv_xml_cn_buyer) =
      |<buyer_country>{ wa_header1-countryName }</buyer_country>|.
    ELSE.
      lv_xml_cn_buyer = |<buyer_country></buyer_country>|.
    ENDIF.

    IF wa_header2-CustomerAccountGroup = 'ZEXP'.
      DATA(lv_xml_cn_consignee) =
      |<consignee_country>{ wa_header2-countryName }</consignee_country>|.
    ELSE.
      lv_xml_cn_consignee = |<consignee_country></consignee_country>|.
    ENDIF.
    DATA(lv_header_last) =
    |</header>| &&
    |<lineItem>|.

    CONCATENATE lv_xml lv_xml_cn_buyer lv_xml_cn_consignee lv_header_last INTO lv_xml.

    SELECT SINGLE
    FROM i_salesdocument AS a
    FIELDS
    a~pricedetnexchangerate
    WHERE a~SalesDocument = @lv_salesorderno
    INTO @DATA(lv_exchange).

***********************************************    line item xml   ***************************************************
    DATA : taxrate TYPE p LENGTH 9 DECIMALS 2.
    DATA r_flag TYPE i VALUE 0.
    DATA d_flag TYPE i VALUE 0.
    DATA i_flag TYPE i VALUE 0.
    DATA c_s_flag TYPE i VALUE 0.
    DATA value_of_sup TYPE i_salesdocumentitem-OrderQuantity.
    DATA taxable_value TYPE i_salesdocumentitem-OrderQuantity.
    DATA discount TYPE i_salesdocitempricingelement-conditionratevalue.
    DATA rounding_off TYPE i_salesdocitempricingelement-ConditionAmount.
    DATA freight_amt TYPE i_salesdocitempricingelement-ConditionAmount.
    DATA Insurance_amt TYPE i_salesdocitempricingelement-ConditionAmount.
    DATA tcs_amount TYPE i_salesdocitempricingelement-ConditionAmount.
    DATA: fr_line_tax TYPE p DECIMALS 2.
    DATA: fr_line_gross TYPE p DECIMALS 2.
    DATA: ins_line_gross TYPE p DECIMALS 2.
    DATA: ins_line_tax TYPE p DECIMALS 2.

    LOOP AT it_line INTO DATA(wa_line).




      DATA(reverse_string) = reverse( wa_line-Salesdocumentitemtext ).
      DATA(lv_pos) = find( val = reverse_string sub = '-' ).
      DATA(length) = strlen( reverse_string ) - ( lv_pos + 1 ).
      lv_pos = lv_pos + 1.
      DATA(temp_data) = reverse_string+lv_pos(length).
*      temp_data = reverse( temp_data ). "comment by Vishal

      " for Fetching MAterial Description " add By Vishal Tyagi on 2202025
      DATA : lv_material TYPE c LENGTH 40.
      lv_material = wa_line-Product.
      SHIFT lv_material LEFT DELETING LEADING '0'.

      SELECT SINGLE FROM zmaterial_table WITH PRIVILEGED ACCESS
      FIELDS trade_name
      WHERE Mat = @lv_material
      INTO @DATA(lv_desc).

      IF lv_desc IS INITIAL.
        SELECT SINGLE FROM I_producttext WITH PRIVILEGED ACCESS
        FIELDS ProductName
        WHERE Product = @wa_line-Product
        INTO @lv_desc.
      ENDIF.

      temp_data = lv_desc.
      CLEAR : lv_desc , lv_material.

      SELECT SINGLE
      FROM i_salesdocumentitem AS a
      FIELDS
      a~MaterialByCustomer
      WHERE a~SalesDocument = @wa_line-SalesDocument AND
      a~SalesDocumentItem = @wa_line-SalesDocumentItem
      INTO @DATA(lv_des2).

*      DATA: lv_des TYPE string.
*      lv_des = temp_data.
*
*      IF lv_des2 IS NOT INITIAL.
*        IF lv_des IS NOT INITIAL.
*          CONCATENATE lv_des '" - "' lv_des2 INTO lv_des.
*        ELSE.
*          lv_des = lv_des2.
*        ENDIF.
*      ENDIF.


      DATA(lv_xml1) =
      |<item>| &&
      |<Description>{ temp_data }</Description>| &&
      |<HSN>{ wa_line-consumptiontaxctrlcode }</HSN>| &&
      |<quantity>{ wa_line-OrderQuantity }</quantity>| &&
      |<uom>{ wa_line-netpricequantityunit }</uom>| &&
      |<PRICEDETNEXCHANGERATE>{ wa_line-PriceDetnExchangeRate }</PRICEDETNEXCHANGERATE>| &&
      |<pack_size>{ wa_line-yy1_packsize_sd_sdi }</pack_size>| &&
       |<des>{ lv_des2 }</des>|.
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      CLEAR lv_des2.
      DATA ratexchange TYPE p LENGTH 9 DECIMALS 2 .

      LOOP AT it_line2 INTO DATA(wa_line2) WHERE salesdocument = wa_line-salesdocument AND salesdocumentitem = wa_line-salesdocumentitem.
        IF wa_line2-ConditionType = 'ZBSP' OR wa_line2-ConditionType = 'ZEXP'.
          ratexchange = wa_line-PriceDetnExchangeRate * wa_line2-ConditionRateValue.
          taxrate = floor( ratexchange * 100 ) / 100.

          DATA(lv_xml1_rate) =
          """""""""""""""""""""""""""""""""""""
*          |<rate>{ wa_line2-conditionratevalue }</rate>|.
          |<rate>{ taxrate }</rate>|.
*          value_of_sup = wa_line-OrderQuantity * wa_line2-conditionratevalue.
          value_of_sup = wa_line-OrderQuantity * ratexchange.

          r_flag = 1.
        ELSEIF wa_line2-ConditionType = 'ZDIS'.
          IF wa_line2-conditionratevalue < 0.
            discount = wa_line2-conditionratevalue * -1.
          ELSE.
            discount = wa_line2-conditionratevalue.
          ENDIF.

          DATA(lv_xml1_dis) =
         |<discount>{ discount }</discount>|.
          d_flag = 1.
          DATA: line_igst TYPE p DECIMALS 2.
          DATA: line_sgst TYPE p DECIMALS 2.
          DATA: line_cgst TYPE p DECIMALS 2.
        ELSEIF wa_line2-ConditionType = 'JOIG'.
          DATA(lv_xml1_igst) =
           |<igst_rate>{ wa_line2-conditionratevalue }</igst_rate>| &&
           |<igst_amount>{ ( ( value_of_sup  - ( value_of_sup * discount ) / 100 ) * wa_line2-conditionratevalue ) / 100 }</igst_amount>|.
          line_igst = wa_line2-conditionamount.
          i_flag = 1.
        ELSEIF wa_line2-ConditionType = 'JOCG' OR wa_line2-ConditionType = 'JOSG'.
          DATA(lv_xml1_cgst_sgst) =
           |<cgst_rate>{ wa_line2-conditionratevalue }</cgst_rate>| &&
           |<cgst_amount>{ ( ( value_of_sup  - ( value_of_sup * discount ) / 100 ) * wa_line2-conditionratevalue ) / 100 }</cgst_amount>| &&
           |<sgst_rate>{ wa_line2-conditionratevalue }</sgst_rate>| &&
           |<sgst_amount>{ ( ( value_of_sup  - ( value_of_sup * discount ) / 100 ) * wa_line2-conditionratevalue ) / 100 }</sgst_amount>|.
          line_sgst = wa_line2-conditionamount.
          line_cgst = wa_line2-conditionamount.
          c_s_flag = 1.
        ENDIF.
        IF wa_line2-ConditionType = 'ZDIF'.
          rounding_off = rounding_off + wa_line2-ConditionAmount.
        ENDIF.
        IF wa_line2-ConditionType = 'ZFRT' OR wa_line2-ConditionType = 'ZEFC'.
*          Freight_amt = Freight_amt + wa_line2-ConditionAmount.
          fr_line_tax = fr_line_tax + wa_line2-ConditionAmount * lv_exchange.
          fr_line_gross  = fr_line_gross +  wa_line2-ConditionAmount * lv_exchange + line_igst +
        line_cgst + line_sgst.
        ENDIF.
        IF wa_line2-ConditionType = 'ZINC' OR wa_line2-ConditionType = 'ZINP' OR wa_line2-ConditionType = 'ZINS' OR  wa_line2-ConditionType = 'ZENS'.
*          Insurance_amt = Insurance_amt + wa_line2-ConditionAmount * lv_exchange.
          ins_line_tax = ins_line_tax + wa_line2-ConditionAmount * lv_exchange.
          ins_line_gross  = ins_line_gross +  wa_line2-ConditionAmount * lv_exchange + line_igst +
        line_cgst + line_sgst.
        ENDIF.
        IF wa_line2-ConditionType = 'JTC1'.
          tcs_amount += wa_line2-ConditionAmount.
        ENDIF.





      ENDLOOP.

      IF value_of_sup IS NOT INITIAL.
        taxable_value =   value_of_sup  - ( value_of_sup * discount ) / 100.
*        taxrate =   value_of_sup  - ( value_of_sup * discount ) / 100.
      ENDIF.

      IF r_flag = 0.
        lv_xml1_rate = |<rate></rate>|.
      ENDIF.
      IF d_flag = 0.
        lv_xml1_dis =
            |<discount></discount>|.
      ENDIF.
      IF i_flag = 0.
        lv_xml1_igst =
             |<igst_rate></igst_rate>| &&
             |<igst_amount></igst_amount>|.
      ENDIF.
      IF c_s_flag = 0.
        lv_xml1_cgst_sgst =
             |<cgst_rate></cgst_rate>| &&
             |<cgst_amount></cgst_amount>| &&
             |<sgst_rate></sgst_rate>| &&
             |<sgst_amount></sgst_amount>|.
      ENDIF.

      DATA(lv_xml_gross) =
      |<value_of_sup>{ value_of_sup }</value_of_sup>| &&
     |<taxable_value>{ taxable_value }</taxable_value>| &&
*      |<taxable_value>{ taxrate }</taxable_value>| &&
      |</item>|.

      CONCATENATE lv_xml lv_xml1 lv_xml1_rate lv_xml1_dis lv_xml1_igst lv_xml1_cgst_sgst lv_xml_gross INTO lv_xml.
      r_flag = 0.
      d_flag = 0.
      i_flag = 0.
      c_s_flag = 0.
      CLEAR value_of_sup.
      CLEAR taxable_value.
    ENDLOOP.

    SELECT SINGLE
   FROM i_salesdocument AS a
   FIELDS
   a~IncotermsLocation1
   WHERE a~SalesDocument = @lv_salesorderno
   INTO @DATA(lv_despatch).

    DATA(lv_xml2) =
    |</lineItem>| &&
    |<footer>| &&
    |<ins_line_gross>{ ins_line_gross }</ins_line_gross>| &&
    |<fr_line_gross>{ fr_line_gross }</fr_line_gross>| &&
    |<fr_line_tax>{ fr_line_tax }</fr_line_tax>| &&
    |<ins_line_tax>{ ins_line_tax }</ins_line_tax>| &&
    |<freight_amt>{ Freight_amt }</freight_amt>| &&
    |<insurance_amt>{ Insurance_amt }</insurance_amt>| &&
    |<rounding_off>{ rounding_off }</rounding_off>| &&
    |<tcs_amount>{ tcs_amount }</tcs_amount>| &&
    |<expected_despatch>{ wa_header1-RequestedDeliveryDate }</expected_despatch>| &&
    |<expected_del>{ wa_header1-RequestedDeliveryDate }</expected_del>| &&
    |<payment_terms>{ wa_header1-customerPaymentTermsName }</payment_terms>| &&
    |<despatch_terms>{ lv_despatch }</despatch_terms>| &&
    |<transport_name>{ wa_header1-SupplierName }</transport_name>| &&
    |<transport_gst>{ wa_header1-suppliergst }</transport_gst>|.
    CONCATENATE lv_xml lv_xml2 INTO lv_xml.

*************************************************    footer xml  *************************************************
    DATA(lv_xml_last) =
    |</footer>| &&
    |</Form>|.
    CONCATENATE lv_xml lv_xml_last INTO lv_xml.
*    out->write( lv_xml ).

*
    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

  ENDMETHOD.
ENDCLASS.
