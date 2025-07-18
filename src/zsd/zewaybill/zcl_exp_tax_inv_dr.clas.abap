CLASS zcl_exp_tax_inv_dr DEFINITION
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
    CONSTANTS lc_template_name TYPE string VALUE 'zexport_tax_inv/zexport_tax_inv'.
ENDCLASS.



CLASS zcl_exp_tax_inv_dr IMPLEMENTATION.
  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .

  METHOD read_posts .

    DATA(lv_xml) =
    |<Form>|.

    DO 6 TIMES.

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
        a~accountingexchangerate,
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
      a~yy1_date_time_removal_bdh,
      a~yy1_transportdetails_bdh,
      a~yy1_vehicleno_bdh
      FROM i_billingdocument AS a
      LEFT JOIN i_billingdocumentitem AS b ON a~BillingDocument = b~BillingDocument
      LEFT JOIN i_purchaseorderhistoryapi01 AS c ON b~batch = c~batch AND c~goodsmovementtype = '101'
      LEFT JOIN i_inbounddelivery AS d ON c~deliverydocument = d~inbounddelivery
      LEFT JOIN ztable_plant AS e ON e~plant_code = b~plant
      LEFT JOIN i_billingdocumentpartner AS f ON a~BillingDocument = f~BillingDocument
      LEFT JOIN I_Supplier AS g ON f~Supplier = g~Supplier
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
  f~countryname
  FROM I_BillingDocument AS a
  LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument
  LEFT JOIN i_customer AS c ON c~customer = b~Customer
  INNER JOIN i_address_2 AS d ON d~AddressID = c~AddressID
  LEFT JOIN i_regiontext AS e ON e~Region = c~Region AND e~Language = 'E' AND c~Country = e~Country
  LEFT JOIN i_countrytext AS f ON d~Country = f~Country
  WHERE b~partnerFunction = 'RE' AND  a~BillingDocument = @bill_doc
  INTO @DATA(wa_bill)
  PRIVILEGED ACCESS.




      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""SHIP TO  Address
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
       c~customername,
       f~countryname,
       e~regionname,
       c~bpcustomername
      FROM I_BillingDocument AS a
      LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument
      LEFT JOIN i_customer AS c ON c~customer = b~Customer
      LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
       LEFT JOIN i_countrytext AS f ON d~Country = f~Country
       LEFT JOIN i_regiontext AS e ON e~Region = c~Region AND e~Language = 'E' AND c~Country = e~Country
      WHERE b~partnerFunction IN ('AG', 'RE') AND a~BillingDocument = @bill_doc
      INTO @DATA(wa_ship)
      PRIVILEGED ACCESS.


      DATA : wa_ad5 TYPE string.
      wa_ad5 = wa_bill-PostalCode.
      CONCATENATE wa_ad5 wa_bill-CityName  wa_bill-DistrictName INTO wa_ad5 SEPARATED BY space.

      DATA : wa_ad5_ship TYPE string.
      wa_ad5_ship = wa_ship-PostalCode.
      CONCATENATE wa_ad5_ship wa_ship-CityName  wa_ship-DistrictName INTO wa_ad5_ship SEPARATED BY space.

      """""""""""""""""""""""""""""""""""""""""""""     sold TO  Address
      SELECT SINGLE
      b~customer,
      d~streetname ,         " sold to add
      d~streetprefixname1 ,   " sold to add
      d~streetprefixname2 ,   " sold to add
      d~cityname ,   " ship to add
      d~region ,  "sold to add
      d~postalcode ,   " sold to add
      d~districtname ,   " sold to add
      d~country,
      d~housenumber ,
      c~customername,
      c~TaxNumber3,
      e~countryname,
      c~bpcustomername
     FROM I_BillingDocument AS a
     LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument
     LEFT JOIN i_customer AS c ON c~customer = b~Customer
     LEFT JOIN i_countrytext AS e ON c~Country = e~Country AND e~Language = 'E'
     LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
     WHERE b~partnerFunction = 'AG'
     AND c~Language = 'E'
     AND a~BillingDocument = @bill_doc
     INTO @DATA(wa_sold)
     PRIVILEGED ACCESS.



      """"""""""""""""""""""""""""   custom header field """"""""""""""""""""""""

      SELECT SINGLE FROM i_billingdocument AS a
        INNER JOIN i_billingdocumentitem AS b ON a~billingdocument = b~billingdocument
        INNER JOIN i_salesdocument AS c ON b~salesdocument = c~salesdocument
        INNER JOIN i_salesquotation AS d ON c~referencesddocument = d~salesquotation
        FIELDS d~creationdate, d~yy1_termsofdelivery_sd_sdh,d~yy1_termsofpayment_soh_sdh
         WHERE
         b~billingdocument = @bill_doc
            INTO @DATA(lv_print) PRIVILEGED ACCESS.


      SELECT SINGLE
        a~billingdocument ,
        b~suppliername ,
        b~taxnumber3
        FROM i_billingdocument AS a
        LEFT JOIN I_Supplier AS b ON b~Supplier = a~YY1_TransportDetails_BDH
        WHERE a~BillingDocument = @bill_doc
        INTO @DATA(wa_header4) PRIVILEGED ACCESS.

      SELECT SINGLE FROM i_billingdocumentitem AS a
          LEFT JOIN i_salesdocument AS b ON b~salesdocument = a~salesdocument
          FIELDS a~salesdocument , b~yy1_dono_sdh, b~yy1_dodate_sdh, b~yy1_poamendmentno_sdh, b~yy1_poamendmentdate_sdh, b~customerpurchaseorderdate,
          b~CreationDate,b~PurchaseOrderByCustomer
          WHERE a~billingdocument = @bill_doc
          INTO @DATA(wa_amend)
          PRIVILEGED ACCESS.


      """""""""""""""""""""""""" item level """"""""""""""""""""""""""""""""""

*    SELECT
*    a~billingdocument,
*    a~billingdocumentitem,
*    a~product,
*    a~netamount,
*    a~referencesddocument,
*    a~plant,
*    b~handlingunitreferencedocument,
*    b~material,
*    b~handlingunitexternalid,
*    c~packagingmaterial,
*    d~productdescription,
*    e~materialbycustomer ,
*    f~consumptiontaxctrlcode  ,   "HSN CODE
*    a~billingdocumentitemtext ,   "mat
*    e~yy1_packsize_sd_sdi  ,  "i_avgpkg
*    a~billingquantity  ,  "Quantity
*    a~billingquantityunit  ,  "UOM
*    e~yy1_packsize_sd_sdiu  ,   " package_qtyunit
*    e~yy1_noofpack_sd_sdi  ,   " avg_content
*    g~conditionratevalue   ,  " i_per
*    g~conditionamount ,
*    g~conditionbasevalue,
*    g~conditiontype,
*    e~salesdocumentitemcategory
*
*
*    FROM I_BillingDocumentItem AS a
*    LEFT JOIN i_handlingunititem AS b ON a~referencesddocument = b~handlingunitreferencedocument
*    LEFT JOIN i_handlingunitheader AS c ON b~handlingunitexternalid = c~handlingunitexternalid
*    LEFT JOIN i_productdescription AS d ON d~product = c~packagingmaterial
*    LEFT JOIN I_SalesDocumentItem AS e ON e~SalesDocument = a~SalesDocument AND e~salesdocumentitem = a~salesdocumentitem
*    LEFT JOIN i_productplantbasic AS f ON a~Product = f~Product
*    LEFT JOIN i_billingdocumentitemprcgelmnt AS g ON g~BillingDocument = a~BillingDocument AND g~BillingDocumentItem = a~BillingDocumentItem
*    WHERE a~billingdocument = @bill_doc
*    INTO TABLE  @DATA(it_item)
*    PRIVILEGED ACCESS.

      SELECT
     a~billingdocument,
     a~billingdocumentitem,
     a~product,
     a~netamount,
     a~referencesddocument,
     a~plant,
     e~materialbycustomer ,
     f~consumptiontaxctrlcode  ,   "HSN CODE
     a~billingdocumentitemtext ,   "mat
     e~yy1_packsize_sd_sdi  ,  "i_avgpkg
     a~billingquantity  ,  "Quantity
     a~billingquantityunit  ,  "UOM
     e~yy1_packsize_sd_sdiu  ,   " package_qtyunit
     e~yy1_noofpack_sd_sdi  ,   " avg_content
     e~salesdocumentitemcategory


     FROM I_BillingDocumentItem AS a
     LEFT JOIN I_SalesDocumentItem AS e ON e~SalesDocument = a~SalesDocument AND e~salesdocumentitem = a~salesdocumentitem
     LEFT JOIN i_productplantbasic AS f ON a~Product = f~Product and a~Plant = f~Plant
     WHERE a~billingdocument = @bill_doc
     INTO TABLE  @DATA(it_item)
     PRIVILEGED ACCESS.

*    DELETE ADJACENT DUPLICATES FROM it_item COMPARING billingdocumentitem.

      SELECT SUM( conditionamount )
      FROM i_billingdocumentitemprcgelmnt
      WHERE billingdocument = @bill_doc
        AND conditiontype = 'ZEFC'
        INTO @DATA(freight) PRIVILEGED ACCESS.

*I_BillingDocItemPrcgElmntBasic


      SELECT SINGLE FROM
      i_billingdocumentitem AS a
      LEFT JOIN i_salesdocument AS b ON a~SalesDocument = b~SalesDocument
      FIELDS
      b~YY1_PreCarriageby_SDH
      WHERE a~BillingDocument = @bill_doc
      INTO @DATA(lv_trans_mode) PRIVILEGED ACCESS.

      DATA : lv_transportmode TYPE string.

      IF lv_trans_mode = 'A'.
        lv_transportmode = 'Air'.
      ELSEIF lv_trans_mode = 'R'.
        lv_transportmode = 'Road'.
      ELSEIF lv_trans_mode = 'S'.
        lv_transportmode = 'Ship'.
      ELSEIF lv_trans_mode = 'T'.
        lv_transportmode = 'Train'.
      ENDIF.

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
*    DATA(lv_formatted_time) = |{ lv_hours WIDTH = 2 PAD = '0' }:{ lv_minutes WIDTH = 2 PAD = '0' }:{ lv_seconds WIDTH = 2 PAD = '0' }|.



      wa_header4-SupplierName = wa_header4-SupplierName && ' - ' && wa_header4-TaxNumber3.

      SELECT SINGLE FROM
      i_billingdocumentitem AS a
      FIELDS
      a~referencesddocument
      WHERE a~BillingDocument = @bill_doc
      INTO @DATA(lv_reference) PRIVILEGED ACCESS.

      SELECT SINGLE FROM
      i_billingdocumentitem AS a
      LEFT JOIN i_billingdocument AS b ON a~BillingDocument = b~BillingDocument
      AND a~salesdocumentitemcategory = 'TAN'
      FIELDS
      a~BillingDocument
      WHERE a~ReferenceSDDocument = @lv_reference AND b~BillingDocumentType = 'F8'
      INTO @DATA(lv_commercial) PRIVILEGED ACCESS.

      SHIFT lv_commercial LEFT DELETING LEADING '0'.

      DATA:lv_pagename TYPE string.

      IF sy-index = 1.
        lv_pagename = 'ORIGINAL'.
      ENDIF.
      IF sy-index = 2.
        lv_pagename = 'DUPLICATE'.
      ENDIF.
      IF sy-index = 3.
        lv_pagename = 'TRIPLICATE'.
      ENDIF.
      IF sy-index = 4.
        lv_pagename = 'QUARDUPLICATE'.
      ENDIF.
      IF sy-index = 5.
        lv_pagename = 'QUINTUPLICATE'.
      ENDIF.
      IF sy-index = 6.
        lv_pagename = 'SIXTUPLICATE'.
      ENDIF.

    select single from
    i_billingdocumentitem as a
    left join i_salesdocument as b on a~salesdocument = b~salesdocument
    FIELDS
    b~referencesddocument
    where a~billingdocument = @bill_doc
    into @data(wa_matgdes) PRIVILEGED ACCESS.

    select single from
    i_salesdocument as a
    FIELDS
    a~yy1_materialgroupdes_sdh
    where a~salesdocument = @wa_matgdes
    into @data(wa_matdes2) PRIVILEGED ACCESS.


      DATA(lv_xml_page) =

    |<BillingDocumentNode>| &&
    |<pagename>{ lv_pagename }</pagename>| &&
    |<AbsltAccountingExchangeRate>{ wa_header-accountingexchangerate }</AbsltAccountingExchangeRate>| &&
    |<AckDate>{ wa_header-ackdate }</AckDate>| &&
    |<AckNumber>{ wa_header-ackno }</AckNumber>| &&
    |<AmountInWords></AmountInWords>| &&                      " pending
    |<BillingDate>{ wa_header-BillingDocumentDate }</BillingDate>| &&
    |<CreationTime>{ lv_formatted_time }</CreationTime>| &&
    |<DocumentReferenceID>{ wa_header-DocumentReferenceID }</DocumentReferenceID>| &&
    |<Irn>{ wa_header-irnno }</Irn>| &&
    |<EwayBill>{ wa_header-ewaybillno }</EwayBill>| &&
    |<EwayBillDate>{ wa_header-ewaydate }</EwayBillDate>| &&
    |<ReferenceSDDocument>{ wa_header-ReferenceSDDocument }</ReferenceSDDocument>| &&
    |<SalesDocument>{ wa_amend-PurchaseOrderByCustomer }</SalesDocument>| &&
    |<SalesOrderDate>{ wa_amend-CustomerPurchaseOrderDate }</SalesOrderDate>| &&
    |<YY1_PLANT_COM_ADD_BDH>{ plant_add }</YY1_PLANT_COM_ADD_BDH>| &&
    |<YY1_PLANT_COM_NAME_BDH>{ plant_name }</YY1_PLANT_COM_NAME_BDH>| &&
    |<YY1_PLANT_GSTIN_NO_BDH>{ plant_gstin }</YY1_PLANT_GSTIN_NO_BDH>| &&
    |<YY1_PLANT_STATE_CODE_BDH>{ wa_header-state_code2 }</YY1_PLANT_STATE_CODE_BDH>| &&
    |<YY1_TermsofDeliveryVF_BDH>{ lv_print-YY1_TermsOfDelivery_SD_SDH }</YY1_TermsofDeliveryVF_BDH>| &&
    |<YY1_TransportDetails_BDHT>{ wa_header4-SupplierName }</YY1_TransportDetails_BDHT>| &&
    |<Transportmode>{ lv_transportmode }</Transportmode>| &&
    |<YY1_REMARK_BDH>{ wa_header-yy1_remark_bdh }</YY1_REMARK_BDH>| &&
    |<YY1_VehicleNo_BDH>{ wa_header-YY1_VehicleNo_BDH }</YY1_VehicleNo_BDH>| &&     " pending
    |<YY1_amendmentdate_bd_BDH>{ wa_amend-yy1_poamendmentdate_sdh }</YY1_amendmentdate_bd_BDH>| &&
    |<YY1_amendmentno_bd_BDH>{ wa_amend-yy1_poamendmentno_sdh }</YY1_amendmentno_bd_BDH>| &&
    |<YY1_VEHICLENO_BDH>{ wa_header-yy1_vehicleno_bdh }</YY1_VEHICLENO_BDH>| &&
    |<YY1_DATE_TIME_REMOVAL_BDH>{ wa_header-yy1_date_time_removal_bdh }</YY1_DATE_TIME_REMOVAL_BDH>| &&
    |<YY1_custmatdes>{ wa_matdes2 }</YY1_custmatdes>| &&
    |<commercial>{ lv_commercial }</commercial>| &&
    |<Items>|.

    clear wa_matdes2.

      CONCATENATE lv_xml lv_xml_page   INTO lv_xml.

      LOOP AT it_item INTO DATA(wa_item).

        IF wa_item-SalesDocumentItemCategory = 'TAN'.
          SELECT SINGLE FROM i_billingdocumentitem AS a
          FIELDS billingquantity,billingdocument
          WHERE a~BillingDocument = @wa_item-billingdocument
          AND billingdocumentitem = @wa_item-BillingDocumentItem
          INTO @DATA(lv_exp)
          PRIVILEGED ACCESS.
        ENDIF.

        SELECT
            a~handlingunitreferencedocument,
            a~material,
            a~handlingunitexternalid,
            b~packagingmaterial,
            c~productdescription
            FROM i_handlingunititem AS a
            LEFT JOIN i_handlingunitheader AS b ON a~handlingunitexternalid = b~handlingunitexternalid
            LEFT JOIN i_productdescription AS c ON c~product = b~packagingmaterial
            WHERE a~handlingunitreferencedocument = @wa_item-referencesddocument AND
            a~material = @wa_item-product
            INTO TABLE @DATA(lt_handle)
            PRIVILEGED ACCESS.


        SORT lt_handle BY handlingunitexternalid ASCENDING.
        DELETE ADJACENT DUPLICATES FROM lt_handle COMPARING handlingunitexternalid.
        DATA: lv_count TYPE string.
        lv_count = lines( lt_handle ).

        SELECT SINGLE a~quantitydenominator, a~quantitynumerator, b~billingquantity
          FROM i_productunitsofmeasure AS a
          INNER JOIN i_billingdocumentitem AS b ON a~product = b~product
          WHERE
          a~alternativeunit = 'KG' AND
          a~product = @wa_item-product
          INTO @DATA(lv_qunt)
          PRIVILEGED ACCESS.

        DATA quant_in_l TYPE i_billingdocumentitem-billingquantity.
        quant_in_l = ( lv_qunt-quantitydenominator / lv_qunt-quantitynumerator ) * lv_qunt-billingquantity.


        DATA(var1_wa_fg) =   |{ wa_item-product ALPHA = OUT }|.
        DATA: fg_mat TYPE zmaterial_table-trade_name.

        SELECT SINGLE
            b~trade_name
            FROM zmaterial_table AS b
            WHERE b~mat = @var1_wa_fg
            INTO @DATA(wa_fg) PRIVILEGED ACCESS.


        IF wa_fg IS NOT INITIAL.
          fg_mat = wa_fg.
        ELSE.
          SELECT SINGLE
          a~productname
          FROM i_producttext AS a
          WHERE a~product = @var1_wa_fg
          INTO @DATA(wa_fg2) PRIVILEGED ACCESS.
          fg_mat = wa_fg.
        ENDIF.


        SELECT
            c~quantitydenominator,
            c~quantitynumerator
            FROM
            i_productunitsofmeasure AS c
            WHERE c~product = @wa_item-product AND c~alternativeunit = 'KG'
            INTO TABLE @DATA(lt_netweight)
            PRIVILEGED ACCESS.

        READ TABLE lt_netweight INTO DATA(wa_netweight) INDEX 1.
        DATA: net_weight TYPE p DECIMALS 3.
        net_weight = wa_netweight-quantitydenominator / wa_netweight-quantitynumerator.

        READ TABLE lt_handle INTO DATA(lv_handle1) INDEX 1.
        SELECT SINGLE
            d~trade_name
            FROM zmaterial_table AS d
            WHERE d~mat = @lv_handle1-packagingmaterial
            INTO @DATA(lv_handle_tradename)
            PRIVILEGED ACCESS.

        DATA: pkg_mat TYPE zmaterial_table-trade_name.


        IF lv_handle_tradename IS NOT INITIAL.
          pkg_mat = lv_handle_tradename.
        ELSE.
          pkg_mat = lv_handle1-productdescription.
        ENDIF.

        SELECT
            SUM( b~handlingunittareweight ) FROM
            i_handlingunitheader AS b
            WHERE b~handlingunitpackingobjectkey = @wa_item-referencesddocument
            INTO @DATA(lv_tare)
            PRIVILEGED ACCESS.

        select single from i_billingdocumentitem as a
        left join i_salesdocument as b on a~salesdocument = b~salesdocument
        left join i_salesdocumentitem as c on b~referencesddocument = c~salesdocument
        FIELDS
        c~yy1_desofgood_sdi
        where a~billingdocument = @wa_item-billingdocument
        and c~material =  @wa_item-product
        into @data(lv_desofgoods) PRIVILEGED ACCESS.




        DATA(lv_item_xml) =
        |<BillingDocumentItemNode>| &&
        |<BillingDocumentItemText>{ wa_item-Product }</BillingDocumentItemText>| &&
        |<IN_HSNOrSACCode>{ wa_item-consumptiontaxctrlcode }</IN_HSNOrSACCode>| &&
        |<Plant>{ wa_item-plant }</Plant>| &&
        |<QuantityUnit>{ wa_item-BillingQuantityUnit }</QuantityUnit>| &&
        |<YY1_EXPTAX_QUANTITY_BDI>{ lv_exp-BillingQuantity }</YY1_EXPTAX_QUANTITY_BDI>| &&
        |<YY1_NO_PKGS_BDI>{ lv_count }</YY1_NO_PKGS_BDI>| &&
        |<YY1_Quant_inKG_of_ltr_BDI>{ quant_in_l }</YY1_Quant_inKG_of_ltr_BDI>| &&
        |<YY1_fg_material_name_BDI>{ fg_mat }</YY1_fg_material_name_BDI>| &&
        |<YY1_net_weight_bd_BDI>{ net_weight }</YY1_net_weight_bd_BDI>| &&
        |<YY1_pack_kind_BDI>{ pkg_mat }</YY1_pack_kind_BDI>| &&
        |<YY1_tare_weight_BDI>{ lv_tare }</YY1_tare_weight_BDI>| &&
        |<YY1_des_of_goods>{ lv_desofgoods }</YY1_des_of_goods>| &&
        |<ItemPricingConditions>|.
        CONCATENATE lv_xml lv_item_xml INTO lv_xml.

        clear lv_desofgoods.

        SELECT
         a~conditionType  ,  "hidden conditiontype
         a~conditionamount ,  "hidden conditionamount
         a~conditionratevalue  ,  "condition ratevalue
         a~conditionbasevalue   " condition base value
         FROM i_billingdocumentitemprcgelmnt AS a
          WHERE a~BillingDocument = @bill_doc AND a~BillingDocumentItem = @wa_item-BillingDocumentItem
         INTO TABLE @DATA(lt_item2)
         PRIVILEGED ACCESS.

        LOOP AT lt_item2 INTO DATA(wa_item2).
          DATA(lv_pricing_xml) =

          |<ItemPricingConditionNode>| &&
          |<ConditionAmount>{ wa_item2-ConditionAmount }</ConditionAmount>| &&
          |<ConditionBaseValue>{ wa_item2-ConditionBaseValue }</ConditionBaseValue>| &&
          |<ConditionRateValue>{ wa_item2-ConditionRateValue }</ConditionRateValue>| &&
          |<ConditionType>{ wa_item2-ConditionType }</ConditionType>| &&
          |<ValueofSupply></ValueofSupply>| &&                          " pending
          |</ItemPricingConditionNode>|.

          CLEAR wa_item2.
          CONCATENATE lv_xml lv_pricing_xml INTO lv_xml.
        ENDLOOP.
        DATA(lv_itemend_xml) =
        |</ItemPricingConditions>| &&
        |</BillingDocumentItemNode>|.

        CONCATENATE lv_xml lv_itemend_xml INTO lv_xml.


        CLEAR lv_item_xml.
        CLEAR wa_item.

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

      wa_ship-StreetName = wa_ship-HouseNumber && ' ' && wa_ship-StreetName.
      wa_sold-StreetName = wa_sold-HouseNumber && ' ' && wa_sold-StreetName.

      DATA(lv_footer) =
      |</Items>| &&
      |<PaymentTerms>| &&
      |<PaymentTermsName>{ lv_payterms }</PaymentTermsName>| &&   " pending
      |</PaymentTerms>| &&
      |<ShipToParty>| &&
    |<AddressLine1Text>{ wa_ship-bpCustomerName }</AddressLine1Text>| &&
    |<AddressLine3Text>{ wa_ship-StreetPrefixName2 }</AddressLine3Text>| &&
    |<AddressLine4Text>{ wa_ship-StreetName }</AddressLine4Text>| &&
    |<AddressLine5Text>{ wa_ad5_ship }</AddressLine5Text>| &&
    |<AddressLine6Text>{ wa_ship-CountryName }</AddressLine6Text>| &&
    |<AddressLine7Text></AddressLine7Text>| &&    " pending
    |<AddressLine8Text></AddressLine8Text>| &&    " pending
    |</ShipToParty>| &&
    |<SoldToParty>| &&
    |<AddressLine1Text>{ wa_sold-bpCustomerName }</AddressLine1Text>| &&     " pending
    |<AddressLine2Text>{ wa_sold-StreetName }</AddressLine2Text>| &&
    |<AddressLine3Text>{ wa_sold-StreetPrefixName1 }</AddressLine3Text>| &&
    |<AddressLine4Text>{ wa_sold-StreetPrefixName2 }</AddressLine4Text>| &&
    |<AddressLine5Text>{ wa_sold-CityName }</AddressLine5Text>| &&
    |<AddressLine6Text>{ wa_sold-DistrictName }</AddressLine6Text>| &&
    |<AddressLine7Text>{ wa_sold-PostalCode }</AddressLine7Text>| &&
    |<AddressLine8Text>{ wa_sold-countryname }</AddressLine8Text>| &&
    |<Partner>{ wa_sold-Customer }</Partner>| &&                       " pending
    |</SoldToParty>| &&
    |<Supplier>| &&
    |<RegionName>{ wa_header-state_name }</RegionName>| &&
    |</Supplier>| &&
    |<TaxationTerms>| &&
    |<IN_BillToPtyGSTIdnNmbr>{ wa_sold-TaxNumber3 }</IN_BillToPtyGSTIdnNmbr>| &&
    |<VATRegistrationCountryName>{ wa_sold-CountryName }</VATRegistrationCountryName>| &&
    |</TaxationTerms>| &&
    |</BillingDocumentNode>|.


      CONCATENATE lv_xml lv_footer INTO lv_xml.

    ENDDO.

    DATA(lv_xml_last) =
   |</Form>|.

    CONCATENATE lv_xml lv_xml_last INTO lv_xml.

*    REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.
    REPLACE ALL OCCURRENCES OF '<=' IN lv_xml WITH 'let'.
    REPLACE ALL OCCURRENCES OF '>=' IN lv_xml WITH 'get'.
*
    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

*        result12 = lv_xml.

  ENDMETHOD.
ENDCLASS.
