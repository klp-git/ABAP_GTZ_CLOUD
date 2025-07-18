CLASS zcl_sto_tax_inv_dr DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
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
        IMPORTING
                  bill_doc        TYPE string
*                  company_code     TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zsd_sto_tax_inv/zsd_sto_tax_inv'."'zpo/zpo_v2'."
*    CONSTANTS company_code TYPE string VALUE 'GT00'.
ENDCLASS.



CLASS ZCL_STO_TAX_INV_DR IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).


  ENDMETHOD .


  METHOD read_posts.

    DATA(lv_xml) =
    |<Form>|.

    DO 4 TIMES.

      DATA : plant_add   TYPE string.
      DATA : p_add1  TYPE string.
      DATA : p_add2 TYPE string.
      DATA : p_city TYPE string.
      DATA : p_dist TYPE string.
      DATA : p_state TYPE string.
      DATA : p_pin TYPE string.
      DATA : p_country   TYPE string,
             plant_name  TYPE string,
             plant_gstin TYPE string.



      SELECT SINGLE
       a~billingdocument ,
        a~billingdocumentdate ,
        a~creationdate,
        a~creationtime,
        a~documentreferenceid,
         b~referencesddocument ,
         b~plant,
          d~deliverydocumentbysupplier,
       e~gstin_no ,
       e~state_code2 ,
       e~plant_name1 ,
       e~address1 ,
       e~address2 ,
       e~city ,
       e~district ,
       e~state_name ,
       e~pin ,
       e~country ,
       g~supplierfullname,
       i~documentdate,
      j~irnno ,
      j~ackno ,
      j~ackdate ,
      j~billingdocno  ,    "invoice no
      j~billingdate ,
      j~signedqrcode,
      j~ewaybillno,
      j~ewaydate,
      k~YY1_DODate_SDH,
      k~yy1_dono_sdh,
      a~yy1_remark_bdh,
      g~suppliername,
      a~yy1_no_of_packages_bdh,
      a~yy1_date_time_removal_bdh,
      a~yy1_vehicleno_bdh,
      g~Taxnumber3
      FROM i_billingdocument AS a
      LEFT JOIN i_billingdocumentitem AS b ON a~BillingDocument = b~BillingDocument
      LEFT JOIN i_purchaseorderhistoryapi01 AS c ON b~batch = c~batch AND c~goodsmovementtype = '101'
      LEFT JOIN i_inbounddelivery AS d ON c~deliverydocument = d~inbounddelivery
      LEFT JOIN ztable_plant AS e ON e~plant_code = b~plant
      LEFT JOIN i_billingdocumentpartner AS f ON a~BillingDocument = f~BillingDocument
      LEFT JOIN I_Supplier AS g ON a~yy1_transportdetails_bdh = g~Supplier
      LEFT JOIN i_materialdocumentitem_2 AS h ON h~purchaseorder = c~purchaseorder AND h~goodsmovementtype = '101'
      LEFT JOIN I_MaterialDocumentHeader_2 AS i ON h~MaterialDocument = i~MaterialDocument
      LEFT JOIN ztable_irn AS j ON j~billingdocno = a~BillingDocument AND a~CompanyCode = j~bukrs
      LEFT JOIN i_salesdocument AS k ON k~salesdocument = b~salesdocument
      WHERE a~BillingDocument = @bill_doc
      INTO @DATA(wa_header) PRIVILEGED ACCESS.




      p_add1 = wa_header-address1 && ',' .
      p_add2 = wa_header-address2 && ','.
      p_dist = wa_header-district && ','.
      p_city = wa_header-city && ','.
      p_state = wa_header-state_name .
      p_pin =  wa_header-pin .
      p_country =  '(' &&  wa_header-country && ')' .


      CONCATENATE p_add1  p_add2  p_dist p_city   p_state '-' p_pin  p_country INTO plant_add SEPARATED BY space.

      plant_name = wa_header-plant_name1.
      plant_gstin = wa_header-gstin_no.


      """""""""""""""""""""""""""""""""   BILL TO """""""""""""""""""""""""""""""""
      SELECT SINGLE
    d~streetname ,         " bill to add
    d~streetprefixname1 ,   " bill to add
    d~streetprefixname2 ,   " bill to add
    d~cityname ,   " bill to add
    d~region ,  "bill to add
    d~postalcode ,   " bill to add
    d~districtname ,   " bill to add
    d~country  ,
    d~housenumber ,
    c~customername,
    e~regionname,
    f~countryname,
    c~taxnumber3,
    d~streetsuffixname1,
    d~streetsuffixname2,
    c~customer
   FROM I_BillingDocument AS a
   LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument
   LEFT JOIN i_customer AS c ON c~customer = b~Customer
   LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
   LEFT JOIN i_regiontext AS e ON e~Region = c~Region AND e~Language = 'E' AND c~Country = e~Country
   LEFT JOIN i_countrytext AS f ON d~Country = f~Country
   WHERE b~partnerFunction = 'RE' AND  a~BillingDocument = @bill_doc
   INTO @DATA(wa_bill)
   PRIVILEGED ACCESS.

      DATA: bill_gstin TYPE string.
      bill_gstin = wa_bill-TaxNumber3.




      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""SHIP TO  Address
      SELECT SINGLE
    d~streetname ,         " bill to add
    d~streetprefixname1 ,   " bill to add
    d~streetprefixname2 ,   " bill to add
    d~cityname ,   " bill to add
    d~region ,  "bill to add
    d~postalcode ,   " bill to add
    d~districtname ,   " bill to add
    d~country  ,
    d~housenumber ,
    c~customername,
    e~regionname,
    f~countryname,
    c~taxnumber3,
    d~streetsuffixname1,
    d~streetsuffixname2,
    c~customer
   FROM I_BillingDocument AS a
   LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument
   LEFT JOIN i_customer AS c ON c~customer = b~Customer
   LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
   LEFT JOIN i_regiontext AS e ON e~Region = c~Region AND e~Language = 'E' AND c~Country = e~Country
   LEFT JOIN i_countrytext AS f ON d~Country = f~Country
   WHERE b~partnerFunction IN ( 'WE', 'AG' ) AND  a~BillingDocument = @bill_doc
   INTO @DATA(wa_ship)
   PRIVILEGED ACCESS.

      DATA : wa_ad5 TYPE string.
      wa_ad5 = wa_bill-PostalCode.
      CONCATENATE wa_ad5 wa_bill-CityName  wa_bill-DistrictName INTO wa_ad5 SEPARATED BY space.

      DATA : wa_ad5_ship TYPE string.
      wa_ad5_ship = wa_ship-PostalCode.
      CONCATENATE wa_ad5_ship wa_ship-CityName  wa_ship-DistrictName INTO wa_ad5_ship SEPARATED BY space.





      """""""""""""""""""""""""""""""""""ITEM DETAILS"""""""""""""""""""""""""""""""""""

      SELECT
        a~billingdocument,
        a~billingdocumentitem,
        a~product,
        a~netamount,
        b~handlingunitreferencedocument,
        b~material,
        b~handlingunitexternalid,
        c~packagingmaterial,
        d~productdescription,
        e~materialbycustomer ,
        f~consumptiontaxctrlcode  ,   "HSN CODE
        a~billingdocumentitemtext ,   "mat
        e~yy1_packsize_sd_sdi  ,  "i_avgpkg
        a~billingquantity  ,  "Quantity
        a~billingquantityunit  ,  "UOM
        e~yy1_packsize_sd_sdiu  ,   " package_qtyunit
        e~yy1_noofpack_sd_sdi  ,   " avg_content
        g~conditionratevalue   ,  " i_per
        g~conditionamount ,
        g~conditionbasevalue,
        g~conditiontype,
        a~creationdate


        FROM I_BillingDocumentItem AS a
        LEFT JOIN i_handlingunititem AS b ON a~referencesddocument = b~handlingunitreferencedocument
        LEFT JOIN i_handlingunitheader AS c ON b~handlingunitexternalid = c~handlingunitexternalid
        LEFT JOIN i_productdescription AS d ON d~product = c~packagingmaterial
        LEFT JOIN I_SalesDocumentItem AS e ON e~SalesDocument = a~SalesDocument AND e~salesdocumentitem = a~salesdocumentitem
        LEFT JOIN i_productplantbasic AS f ON a~Product = f~Product AND a~Plant = f~Plant
        LEFT JOIN i_billingdocumentitemprcgelmnt AS g ON g~BillingDocument = a~BillingDocument AND g~BillingDocumentItem = a~BillingDocumentItem
        WHERE a~billingdocument = @bill_doc
        INTO TABLE @DATA(it_item)
        PRIVILEGED ACCESS.

      SORT it_item BY BillingDocumentItem ASCENDING.
      DELETE it_item WHERE BillingQuantity = 0.
      DELETE ADJACENT DUPLICATES FROM it_item COMPARING BillingDocumentItem.
      DELETE ADJACENT DUPLICATES FROM it_item COMPARING Product.

*      out->write( it_item ).
      SELECT SUM( conditionamount )
  FROM i_billingdocitemprcgelmntbasic
  WHERE billingdocument = @bill_doc
    AND conditiontype = 'ZFRT'
    INTO @DATA(freight) PRIVILEGED ACCESS.



      SORT it_item BY BillingDocumentItem.
      DELETE ADJACENT DUPLICATES FROM it_item COMPARING BillingDocument BillingDocumentItem.

      DATA : discount TYPE p DECIMALS 3.

*      out->write( it_item ).
*    out->write( wa_header ).

      DATA: temp_add TYPE string.
      temp_add = wa_bill-postalcode.
      CONCATENATE temp_add ' ' wa_bill-CityName ' ' wa_bill-DistrictName ' ' INTO temp_add.
      DATA: transport_details TYPE string.
      transport_details = wa_header-suppliername.
      CONCATENATE transport_details ' - ' wa_header-TaxNumber3 INTO transport_details.
      IF wa_header-YY1_DODate_SDH = 0.
        CLEAR wa_header-YY1_DODate_SDH.
      ENDIF.

      DATA:lv_pagename TYPE string.

      IF sy-index = 1.
        lv_pagename = 'ORIGINAL FOR RECIPIENT'.
      ENDIF.
      IF sy-index = 2.
        lv_pagename = 'DUPLICATE FOR TRANSPORTER'.
      ENDIF.
      IF sy-index = 3.
        lv_pagename = 'TRIPLICATE FOR SUPPLIER'.
      ENDIF.
      IF sy-index = 4.
        lv_pagename = 'EXTRA COPY'.
      ENDIF.

      wa_bill-StreetName = wa_bill-HouseNumber && ' ' && wa_bill-StreetName.

      DATA: lv_utc_time   TYPE t,
            lv_utc_string TYPE string,
            lv_ist_time   TYPE t,
            lv_hours      TYPE i,
            lv_minutes    TYPE i,
            lv_seconds    TYPE i.

      lv_utc_time = wa_header-CreationTime.

* Extract hours, minutes, seconds
      lv_hours   = lv_utc_time+0(2).
      lv_minutes = lv_utc_time+2(2).
      lv_seconds = lv_utc_time+4(2).

* Convert to IST (Add 5 hours 30 minutes)
      lv_hours = lv_hours + 5.
      lv_minutes = lv_minutes + 30.

      IF lv_minutes >= 60.
        lv_minutes = lv_minutes - 60.
        lv_hours = lv_hours + 1.
      ENDIF.

      IF lv_hours >= 24.
        lv_hours = lv_hours - 24.
      ENDIF.

      DATA: str_min TYPE string.
      str_min = lv_minutes.
      CONDENSE str_min NO-GAPS.

      IF strlen( str_min ) = 1.
        str_min = '0' && str_min.
      ENDIF.

      DATA: str_sec TYPE string.
      str_sec = lv_seconds.
      CONDENSE str_sec NO-GAPS.

      IF strlen( str_sec ) = 1.
        str_sec = '0' && str_sec.
      ENDIF.

      DATA(lv_formatted_time) = lv_hours && ':' && str_min && ':' && str_sec.

      DATA(lv_xml_page) =
      |<BillingDocumentNode>| &&
      |<pagename>{ lv_pagename }</pagename>| &&
      |<AckDate>{ wa_header-ackdate }</AckDate>| &&
      |<AckNumber>{ wa_header-ackno }</AckNumber>| &&
      |<BillingDate>{ wa_header-BillingDocumentDate }</BillingDate>| &&
      |<Billingtime>{ lv_formatted_time }</Billingtime>| &&
      |<DocumentReferenceID>{ wa_header-DocumentReferenceID }</DocumentReferenceID>| &&
      |<Irn>{ wa_header-irnno }</Irn>| &&
      |<eway_no>{ wa_header-ewaybillno }</eway_no>| &&
      |<eway_dt>{ wa_header-ewaydate }</eway_dt>| &&
      |<signedQr>{ wa_header-signedqrcode }</signedQr>| &&
      |<YY1_PLANT_COM_ADD_BDH>{ plant_add }</YY1_PLANT_COM_ADD_BDH>| &&
      |<YY1_PLANT_COM_NAME_BDH>{ plant_name }</YY1_PLANT_COM_NAME_BDH>| &&
      |<YY1_PLANT_GSTIN_NO_BDH>{ plant_gstin }</YY1_PLANT_GSTIN_NO_BDH>| &&
      |<YY1_dodatebd_BDH>{ wa_header-YY1_DODate_SDH }</YY1_dodatebd_BDH>| &&
      |<YY1_dono_bd_BDH>{ wa_header-YY1_DONo_SDH }</YY1_dono_bd_BDH>| &&
      |<YY1_NO_OF_PACKAGES_BDH>{ wa_header-yy1_no_of_packages_bdh }</YY1_NO_OF_PACKAGES_BDH>| &&
      |<YY1_REMARK_BDH>{ wa_header-yy1_remark_bdh }</YY1_REMARK_BDH>| &&
      |<YY1_TransportDetails_BDHT>{ transport_details }</YY1_TransportDetails_BDHT>| &&
      |<date_time_removal>{ wa_header-yy1_date_time_removal_bdh }</date_time_removal>| &&
      |<vehicle_no>{ wa_header-yy1_vehicleno_bdh }</vehicle_no>| &&
*    |<Plant>{ wa_header-Plant }</Plant>| &&
*    |<RegionName>{ wa_header-state_name }</RegionName>| &&
      |<BillToParty>| &&
      |<AddressLine3Text>{ wa_bill-streetprefixname1 }</AddressLine3Text>| &&
      |<AddressLine4Text>{ wa_bill-streetprefixname2 }</AddressLine4Text>| &&
      |<AddressLine5Text>{ wa_bill-streetname }</AddressLine5Text>| &&
      |<AddressLine6Text>{ wa_bill-streetsuffixname1 }</AddressLine6Text>| &&
      |<AddressLine7Text>{ wa_bill-streetsuffixname2 }</AddressLine7Text>| &&
      |<AddressLine8Text>{ temp_add }</AddressLine8Text>| &&
*    |<Region>{ wa_bill-Region }</Region>| &&
      |<FullName>{ wa_bill-CustomerName }</FullName>| &&   " done
      |<Partner>{ wa_bill-Customer }</Partner>| &&
      |<RegionName>{ wa_bill-RegionName }</RegionName>| &&
      |</BillToParty>| &&
      |<Items>|.

      CONCATENATE lv_xml lv_xml_page INTO lv_xml.

      LOOP AT it_item INTO DATA(wa_item).

        DATA : lv_productcode TYPE string.
        lv_productcode = wa_item-Product.
        SHIFT lv_productcode LEFT DELETING LEADING '0'.

        SELECT SINGLE
       a~trade_name,
       a~quantity_multiple
       FROM zmaterial_table AS a
       WHERE a~mat = @lv_productcode
       INTO @DATA(wa_item3) PRIVILEGED ACCESS.
        DATA: product_text TYPE string.

        IF wa_item3 IS NOT INITIAL.
          product_text = wa_item3-trade_name.
        ELSE.
          " Fetch Product Name from `i_producttext`
          SELECT SINGLE
          a~productname
          FROM i_producttext AS a
          WHERE a~product = @wa_item-Product
          INTO @DATA(wa_item4) PRIVILEGED ACCESS.
          product_text = wa_item4.
        ENDIF.
        DATA(lv_item) =
        |<BillingDocumentItemNode>|.
        CONCATENATE lv_xml lv_item INTO lv_xml.

        SELECT
       SINGLE
       b~conditionratevalue
       FROM
       I_BillingDocItemPrcgElmntBasic AS b
       WHERE b~BillingDocument = @wa_item-BillingDocument AND b~BillingDocumentItem = @wa_item-BillingDocumentItem
       AND b~ConditionType = 'ZSTO'
       INTO @DATA(lv_NetPriceAmount) PRIVILEGED ACCESS.



        SELECT
        SINGLE FROM
        i_billingdocumentitem AS a
        FIELDS
        a~BillingDocument,
        SUM( a~BillingQuantity ) AS BillingQuantity
        WHERE a~BillingDocument = @wa_item-BillingDocument AND
        a~Product = @wa_item-Product GROUP BY a~BillingDocument
        INTO @DATA(lv_quantity) PRIVILEGED ACCESS.


        DATA(lv_item_xml) =

        |<BillingDocumentItemText>{ product_text }</BillingDocumentItemText>| &&
        |<IN_HSNOrSACCode>{ wa_item-consumptiontaxctrlcode }</IN_HSNOrSACCode>| &&
        |<NetPriceAmount>{ lv_NetPriceAmount }</NetPriceAmount>| &&                       " pending
        |<Plant></Plant>| &&                                         " pending
        |<Quantity>{ lv_quantity-billingquantity }</Quantity>| &&
        |<QuantityUnit>{ wa_item-BillingQuantityUnit }</QuantityUnit>| &&
        |<YY1_avg_package_bd_BDI>{ wa_item3-quantity_multiple }</YY1_avg_package_bd_BDI>| &&
        |<YY1_bd_zdif_BDI></YY1_bd_zdif_BDI>| &&                      " pending
        |<YY1_fg_material_name_BDI></YY1_fg_material_name_BDI>| &&    " Pending
        |<ItemPricingConditions>|.
        CONCATENATE lv_xml lv_item_xml INTO lv_xml.
        CLEAR lv_quantity.

        SELECT
          a~conditionType  ,  "hidden conditiontype
          a~conditionamount ,  "hidden conditionamount
          a~conditionratevalue  ,  "condition ratevalue
          a~conditionbasevalue   " condition base value
          FROM I_BillingDocItemPrcgElmntBasic AS a
           WHERE a~BillingDocument = @bill_doc AND a~BillingDocumentItem = @wa_item-BillingDocumentItem
          INTO TABLE @DATA(lt_item2)
          PRIVILEGED ACCESS.

        LOOP AT lt_item2 INTO DATA(wa_item2).
          DATA(lv_item2_xml) =
          |<ItemPricingConditionNode>| &&
          |<ConditionAmount>{ wa_item2-ConditionAmount }</ConditionAmount>| &&
          |<ConditionBaseValue>{ wa_item2-ConditionBaseValue }</ConditionBaseValue>| &&
          |<ConditionRateValue>{ wa_item2-ConditionRateValue }</ConditionRateValue>| &&
          |<ConditionType>{ wa_item2-ConditionType }</ConditionType>| &&
          |</ItemPricingConditionNode>|.
          CONCATENATE lv_xml lv_item2_xml INTO lv_xml.
          CLEAR wa_item2.
        ENDLOOP.
        DATA(lv_item3_xml) =
        |</ItemPricingConditions>| &&
        |</BillingDocumentItemNode>|.

        CONCATENATE lv_xml lv_item3_xml INTO lv_xml.
        CLEAR lv_item.
        CLEAR lv_item_xml.
        CLEAR lt_item2.
        CLEAR wa_item.
        CLEAR lv_productcode.
      ENDLOOP.

      SELECT
      SINGLE
      c~yy1_termsofpayment_soh_sdh
      FROM
      i_billingdocumentitem AS a
      LEFT JOIN I_salesdocument AS b ON a~salesdocument = b~salesdocument
      LEFT JOIN I_SalesQuotation AS c ON b~referencesddocument = c~salesquotation
      WHERE a~BillingDocument = @bill_doc
      INTO @DATA(lv_payterms) PRIVILEGED ACCESS.

      DATA(lv_payment_term) =
        |</Items>| &&
        |<PaymentTerms>| &&
        |<PaymentTermsName>{ lv_payterms }</PaymentTermsName>| &&    " pending
        |</PaymentTerms>|.

      CONCATENATE lv_xml lv_payment_term INTO lv_xml.

      DATA: temp_add2 TYPE string.
      temp_add2 = wa_bill-PostalCode.
      CONCATENATE temp_add2 ' ' wa_bill-CityName ' ' wa_bill-DistrictName ' ' INTO temp_add2.

      wa_ship-StreetName = wa_ship-HouseNumber && ' ' && wa_ship-StreetName.

      DATA(lv_shiptoparty) =
      |<ShipToParty>| &&
      |<AddressLine2Text>{ wa_ship-CustomerName }</AddressLine2Text>| &&
*    |<AddressLine3Text>{ wa_ship-STREETPREFIXNAME2 }</AddressLine3Text>| &&
      |<AddressLine3Text>{ wa_ship-streetprefixname1 }</AddressLine3Text>| &&
      |<AddressLine4Text>{ wa_ship-streetprefixname2 }</AddressLine4Text>| &&
*    |<AddressLine4Text>{ wa_ship-STREETNAME }</AddressLine4Text>| &&
      |<AddressLine5Text>{ wa_ship-streetname }</AddressLine5Text>| &&
*    |<AddressLine5Text>{ wa_ship-STREETPREFIXNAME1 }</AddressLine5Text>| &&
      |<AddressLine6Text>{ wa_ship-streetsuffixname1 }</AddressLine6Text>| &&
      |<AddressLine7Text>{ wa_ship-streetsuffixname2 }</AddressLine7Text>| &&
      |<AddressLine8Text>{ temp_add2 }</AddressLine8Text>| &&
      |<FullName>{ wa_ship-CustomerName }</FullName>| &&
      |<custgstin>{ wa_ship-TaxNumber3 }</custgstin>| &&
      |<RegionName>{ wa_ship-RegionName }</RegionName>| &&
      |</ShipToParty>|.

      CONCATENATE lv_xml lv_shiptoparty INTO lv_xml.

      DATA(lv_supplier) =
      |<Supplier>| &&
      |<RegionName>{ wa_header-state_name }</RegionName>| &&                " pending
      |</Supplier>|.
      CONCATENATE lv_xml lv_supplier INTO lv_xml.

      DATA(lv_taxation) =
      |<TaxationTerms>| &&
      |<IN_BillToPtyGSTIdnNmbr>{ bill_gstin }</IN_BillToPtyGSTIdnNmbr>| &&       " pending   IN_BillToPtyGSTIdnNmbr
      |</TaxationTerms>|.
      CONCATENATE lv_xml lv_taxation INTO lv_xml.

      DATA(lv_footer) =
      |</BillingDocumentNode>|.

      CONCATENATE lv_xml lv_footer INTO lv_xml.

      CLEAR wa_ad5.
      CLEAR wa_ad5_ship.
      CLEAR wa_bill.
      CLEAR wa_ship.
      CLEAR wa_header.

    ENDDO.

    DATA(lv_xml_last) =
    |</Form>|.

    CONCATENATE lv_xml lv_xml_last INTO lv_xml.

*    out->write( lv_xml ).

*    REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.
    REPLACE ALL OCCURRENCES OF '<=' IN lv_xml WITH 'let'.
    REPLACE ALL OCCURRENCES OF '>=' IN lv_xml WITH 'get'.

    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).


  ENDMETHOD.
ENDCLASS.
