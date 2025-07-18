CLASS zclass_eq DEFINITION
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
    CONSTANTS lc_template_name TYPE string VALUE 'ZSD_SALES_QUOTATION/ZSD_SALES_QUOTATION'.
ENDCLASS.



CLASS ZCLASS_EQ IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts.

    SELECT SINGLE
    a~salesquotation,
    a~creationdate,
    a~purchaseorderbycustomer,
    a~customerpurchaseorderdate,
    a~yy1_portofdicharge_sdh,
    a~soldtoparty,
    a~yy1_termsofpayment_soh_sdh,
    a~yy1_termsofdelivery_sd_sdh,
    a~yy1_precarriageby_sdh,
    a~yy1_portofloading_sdh,
    a~yy1_shipment_sd_h_sdh,
    a~yy1_packing_sd_h_sdh,
    a~yy1_plant1_sdh,
    a~transactioncurrency,

c~customer,
c~BpcustomerName,
*                    c~BPAddrCityName,
*                    c~BPAddrStreetName,
*                    c~DistrictName,
*                    c~streetName,
*
                    c~TaxNumber3,
*                    c~Region,
*                    c~CustomerAccountGroup,
*                    c~country,
                    c~telephonenumber1,

                    e~countryname,
                    d~plant_name1,
                    d~address1,
                    d~address2,
                    d~city,
                    d~district,
                    d~pin,
                    d~state_code1,
                    d~state_name,
                    d~cin_no,
                    d~gstin_no,
                    d~plant_code,
                    f~housenumber,
                    f~streetname,
                    f~streetprefixname1,
                    f~streetprefixname2,
                    f~cityname,
                    f~postalcode,
                    f~districtname,
                    f~country
*
    FROM
    i_salesquotation AS a
    LEFT JOIN i_salesquotationitem AS b ON a~SalesQuotation = b~SalesQuotation
*    LEFT JOIN i_plant AS b ON a~yy1_plant1_sdh = b~plant and a~YY1_Plant1_SDH is not INITIAL
    LEFT JOIN ztable_plant AS d ON b~Plant = d~plant_code
    LEFT JOIN i_customer AS c ON a~SoldToParty = c~Customer
    LEFT JOIN i_address_2 WITH PRIVILEGED ACCESS AS f ON c~AddressID = f~AddressID
   LEFT JOIN  i_countrytext AS e ON c~country = e~Country
    WHERE a~SalesQuotation EQ @saleQuotNo
    INTO @DATA(wa_head).

    DATA : pre_car_by TYPE string.
    IF wa_head-YY1_PreCarriageby_SDH = 'T'.

      pre_car_by = 'Rail'.
    ELSEIF wa_head-YY1_PreCarriageby_SDH = 'A'.
      pre_car_by = 'Air'.
    ELSEIF wa_head-YY1_PreCarriageby_SDH = 'R'.
      pre_car_by = 'Road'.
    ELSEIF wa_head-YY1_PreCarriageby_SDH = 'S'.
      pre_car_by = 'Ship'.
    ENDIF.

    DATA : plant_ad2 TYPE string,
           plant_ad1 TYPE string.

    plant_ad1 = wa_head-address1.
    CONCATENATE plant_ad1 ',' wa_head-address2 ',' wa_head-city ',' wa_head-district ',' wa_head-pin INTO plant_ad1 SEPARATED BY space.




    plant_ad2 = wa_head-state_code1.
    CONCATENATE plant_ad2 ',' wa_head-state_name INTO plant_ad2 SEPARATED BY space.


    DATA : con_ad1 TYPE string,
           con_ad2 TYPE string,
           pan     TYPE string.

    pan = wa_head-TaxNumber3+2(10).

    con_ad1 = wa_head-housenumber.
    IF con_ad1 = ','.
      con_ad1 = ''.
    ENDIF.

    IF wa_head-StreetName = ','.
      wa_head-StreetName = ''.
      CONCATENATE con_ad1 wa_head-StreetName INTO con_ad1.
    ELSE.
      CONCATENATE con_ad1 wa_head-StreetName ',' INTO con_ad1.
    ENDIF.

    IF wa_head-StreetPrefixName1 = ','.
      wa_head-StreetPrefixName1 = ''.
      CONCATENATE con_ad1 wa_head-StreetPrefixName1 INTO con_ad1.
    ELSE.
      CONCATENATE con_ad1 wa_head-StreetPrefixName1 ',' INTO con_ad1.
    ENDIF.

    IF wa_head-StreetPrefixName2 = ','.
      wa_head-StreetPrefixName2 = ''.
      CONCATENATE con_ad1 wa_head-StreetPrefixName2 INTO con_ad1.
    ELSE.
      CONCATENATE con_ad1 wa_head-StreetPrefixName2 ',' INTO con_ad1.
    ENDIF.

    IF wa_head-CityName = ','.
      wa_head-CityName = ''.
      CONCATENATE con_ad1 wa_head-CityName INTO con_ad1.
    ELSE.
      CONCATENATE con_ad1 wa_head-CityName INTO con_ad1.
    ENDIF.


    "CONCATENATE con_ad1  ','  wa_head-StreetPrefixName1 ','  wa_head-StreetPrefixName2 ',' wa_head-CityName INTO con_ad1 SEPARATED BY space.

    con_ad2 = wa_head-PostalCode.

    IF con_ad2 = ','.
      con_ad2 = ''.
    ELSE.
      CONCATENATE con_ad2 ',' INTO con_ad2.
    ENDIF.

    IF wa_head-DistrictName = ','.
      wa_head-DistrictName = ''.
      CONCATENATE con_ad2 wa_head-DistrictName INTO con_ad2.
    ELSE.
      CONCATENATE con_ad2 wa_head-DistrictName ',' INTO con_ad2.
    ENDIF.

    IF wa_head-CountryName = ','.
      wa_head-CountryName = ''.
      CONCATENATE con_ad2 wa_head-CountryName INTO con_ad2.
    ELSE.
      CONCATENATE con_ad2 wa_head-CountryName INTO con_ad2.
    ENDIF.

    CONCATENATE con_ad2  'TEL :' wa_head-TelephoneNumber1 INTO con_ad2 SEPARATED BY space.


    "CONCATENATE con_ad2  ','  wa_head-DistrictName ','  wa_head-CountryName  INTO con_ad2 SEPARATED BY space.

    """"""

    """"""
*    out->write( wa_head ).
*    out->write( con_ad1 ).
*    out->write( con_ad2 ).
*    out->write( pan ).


    """"""""""""""""""""""""""""""""ITEM LEVEL DETAILS""""""""""""""""""""""""""""""""""""""

    SELECT
    a~salesquotation,
    a~salesquotationitem,
    a~material,
    c~productname,
    a~yy1_sohscode_sdi,
    a~baseunit,
    a~orderquantity,
    a~yy1_packsize_sd_sdi,
    d~quantitynumerator,
    d~quantitydenominator,
    d~alternativeunit
    FROM
    i_salesquotationitem AS a
*    LEFT JOIN i_salesquotationitem AS b ON a~SalesQuotation EQ b~SalesQuotation
    LEFT JOIN i_producttext AS c ON a~Material EQ c~Product
    LEFT JOIN i_productunitsofmeasure AS d ON a~Material EQ d~Product AND d~AlternativeUnit = 'KG'
    WHERE a~SalesQuotation EQ @saleQuotNo
    INTO TABLE @DATA(it_item).




    """""""""""""""""""""""""""""""FOB """""""""""""""""""""""""""""""""""""""

    SELECT
    a~salesquotationitem,
    c~conditionamount,
    c~conditiontype,
    c~conditionratevalue
        FROM
           i_salesquotationitem AS a
*           LEFT JOIN i_salesquotationitem AS b ON a~SalesQuotation EQ b~SalesQuotation
           LEFT JOIN  i_salesquotationitemprcgelmnt AS c ON a~SalesQuotation = c~SalesQuotation AND a~SalesQuotationItem = c~SalesQuotationItem
           AND c~ConditionType = 'ZEXP'
           WHERE a~SalesQuotation EQ @saleQuotNo
           INTO TABLE @DATA(fob).

    """""""""""""""""""""""""""""""Freight  """""""""""""""""""""""""""""""""""""""

    SELECT
    a~salesquotationitem,
    c~conditionamount,
    c~conditiontype,
    c~conditionratevalue
        FROM
           i_salesquotationitem AS a
*           LEFT JOIN i_salesquotationitem AS b ON a~SalesQuotation EQ b~SalesQuotation
           LEFT JOIN  i_salesquotationitemprcgelmnt AS c ON a~SalesQuotation = c~SalesQuotation AND a~SalesQuotationItem = c~SalesQuotationItem
           AND c~ConditionType = 'ZEFC'
           WHERE a~SalesQuotation EQ @saleQuotNo
           INTO TABLE @DATA(freight).


    """""""""""""""""""""""""""""""Insurance """""""""""""""""""""""""""""""""""""""

    SELECT
    a~salesquotationitem,
    c~conditionamount,
    c~conditiontype,
    c~conditionratevalue
        FROM
           i_salesquotationitem AS a
*           LEFT JOIN i_salesquotationitem AS b ON a~SalesQuotation EQ b~SalesQuotation
           LEFT JOIN  i_salesquotationitemprcgelmnt AS c ON a~SalesQuotation = c~SalesQuotation AND a~SalesQuotationItem = c~SalesQuotationItem
           AND c~ConditionType = 'ZENS'
           WHERE a~SalesQuotation EQ @saleQuotNo
           INTO TABLE @DATA(ins).
    SORT it_item BY salesquotationitem ASCENDING.
    DELETE ADJACENT DUPLICATES FROM  it_item COMPARING salesquotation salesquotationitem.

*    DELETE ADJACENT DUPLICATES FROM fob COMPARING ALL FIELDS.
*    DELETE ADJACENT DUPLICATES FROM freight COMPARING ALL FIELDS.
*    DELETE ADJACENT DUPLICATES FROM ins COMPARING ALL FIELDS.

    DATA : qty_kg TYPE p DECIMALS 2.
    DATA : pack_size  TYPE p DECIMALS 2.


    select single from
    i_salesquotationtp as a
    FIELDS
    a~YY1_Sales_remarks_SDH,
    a~YY1_materialgroupdes_SDH
    where a~Salesquotation = @saleQuotNo
    into @data(wa_remarks).


    DATA(lv_xml) =
    |<form>| &&
    |<Header>| &&
    |<exporter>| &&
    |<plant>{ wa_head-plant_code }</plant>| &&
    |<Name>{ wa_head-plant_name1 }</Name>| &&
    |<ad1>{ plant_ad1 }</ad1>| &&
    |<ad2>{ plant_ad2 }</ad2>| &&
    |<gstin>{ wa_head-gstin_no }</gstin>| &&
    |<cin>{ wa_head-cin_no }</cin>| &&
    |<phone></phone>| &&
    |<proformaNo>{ wa_head-SalesQuotation }</proformaNo>| &&
    |<date>{ wa_head-CreationDate }</date>| &&
    |<buyOrderNo>{ wa_head-PurchaseOrderByCustomer }</buyOrderNo>| &&
    |<buyDate>{ wa_head-CustomerPurchaseOrderDate }</buyDate>| &&
    |<countryFDest>{ wa_head-CountryName }</countryFDest>| &&
    |</exporter>| &&
    |<customer>{ wa_head-Customer }</customer>| &&
    |<name>{ wa_head-BpCustomerName }</name>| &&
    |<remarks>{ wa_remarks-YY1_Sales_remarks_SDH }</remarks>| &&
    |<address1>{ con_ad1 }</address1>| &&
    |<address2>{ con_ad2 }</address2>| &&
    |<pan>{ pan }</pan>| &&
    |<phone>{ wa_head-TelephoneNumber1 }</phone>| &&
    |<email></email>| &&
    |<consignee>| &&
    |<termsOfPayment>{ wa_head-YY1_TermsofPayment_soh_SDH }</termsOfPayment>| &&
    |<termsOfDelv>{ wa_head-YY1_TermsOfDelivery_SD_SDH }</termsOfDelv>| &&
    |</consignee>| &&
    |<preCarBy>{ pre_car_by }</preCarBy>| &&
    |<portOfload>{ wa_head-YY1_PortofLoading_SDH }</portOfload>| &&
    |<finalDest>{ wa_head-YY1_PortofDicharge_SDH }</finalDest>| &&
    |<portOfDis>{ wa_head-YY1_PortofDicharge_SDH }</portOfDis>| &&
    |<shipment>{ wa_head-YY1_Shipment_SD_H_SDH }</shipment>| &&
    |<packing>{ wa_head-YY1_Packing_SD_H_SDH }</packing>| &&
    |<currency>{ wa_head-TransactionCurrency }</currency>| &&
    |<materialgroupdes>{ wa_remarks-YY1_materialgroupdes_SDH }</materialgroupdes>| &&
    |</Header>| &&
    |<lineitem>|.


    LOOP AT it_item INTO DATA(wa_item).
      pack_size = wa_item-YY1_PackSize_sd_SDI.

      "Add by Vishal on 22022025
      " for Fetching MAterial Description
*      SELECT SINGLE FROM zmaterial_table WITH PRIVILEGED ACCESS
*      FIELDS trade_name
*      WHERE Mat = @wa_item-Material
*      INTO @DATA(lv_desc).

      DATA : lv_material TYPE c LENGTH 40.
      lv_material = wa_item-Material.
      SHIFT lv_material LEFT DELETING LEADING '0'.

      SELECT SINGLE FROM zmaterial_table WITH PRIVILEGED ACCESS
      FIELDS trade_name
      WHERE Mat = @lv_material
      INTO @DATA(lv_desc).
      IF lv_desc IS NOT INITIAL.
        wa_item-ProductName = lv_desc.
      ENDIF.

*      IF lv_desc IS INITIAL.
*        SELECT SINGLE FROM I_producttext as a
*        FIELDS ProductName
*        where a~Product = @lv_material
*        INTO @lv_desc PRIVILEGED ACCESS.
*      ENDIF.


      CLEAR : lv_desc , lv_material.

      "End

      IF wa_item-BaseUnit = 'KG'.
        qty_kg = wa_item-OrderQuantity.
      ELSEIF wa_item-BaseUnit = 'L'.
        qty_kg = wa_item-OrderQuantity * ( wa_item-QuantityDenominator / wa_item-QuantityNumerator ).
      ENDIF.

*      select single from
*      i_salesquotationitem as a
*      FIELDS
*      a~MaterialByCustomer
*      where a~SalesQuotation = @salequotno and a~SalesQuotationItem = @wa_item-SalesQuotationItem
*      into @data(wa_itemtext).

      select single
      from I_SALESQUOTATIONITEMTP as a
      FIELDS
      a~YY1_desofgood_SDI
      where a~SalesQuotation = @salequotno and a~SalesQuotationItem = @wa_item-SalesQuotationItem
      into @data(wa_itemtext).

      DATA(lv_item) =
      |<item>| &&
      |<Gddesc>{ wa_item-ProductName }</Gddesc>| &&
      |<hs>{ wa_item-YY1_SOHSCode_SDI }</hs>| &&
      |<uom>{ wa_item-BaseUnit }</uom>| &&
      |<qty>{ wa_item-OrderQuantity }</qty>| &&
      |<qtyKg>{ qty_kg }</qtyKg>| &&
      |<packSize>{ wa_item-YY1_PackSize_sd_SDI }</packSize>|.

      READ TABLE fob INTO DATA(wa_fob) WITH KEY salesquotationitem = wa_item-SalesQuotationItem.
      DATA(lv_fob) =
      |<fobRate>{ wa_fob-ConditionRateValue }</fobRate>| &&
      |<fobAmount>{ wa_fob-ConditionAmount }</fobAmount>|.


      READ TABLE freight INTO DATA(wa_freight) WITH KEY salesquotationitem = wa_item-SalesQuotationItem.
      DATA(lv_freight) =
      |<freightRate>{ wa_freight-ConditionRateValue }</freightRate>| &&
      |<freightAmount>{ wa_freight-ConditionAmount }</freightAmount>|.


      READ TABLE ins INTO DATA(wa_ins) WITH KEY  salesquotationitem = wa_item-SalesQuotationItem.
      DATA(lv_ins) =
      |<insuranceRate>{ wa_ins-ConditionRateValue }</insuranceRate>| &&
      |<insuranceAmount>{ wa_ins-ConditionAmount }</insuranceAmount>| &&
      |<itemText>{ wa_itemtext }</itemText>| &&
      |</item>|.

      CONCATENATE lv_xml lv_item lv_fob lv_freight lv_ins  INTO lv_xml.
      CLEAR wa_item.
      CLEAR wa_ins.
      CLEAR wa_freight.
      CLEAR wa_fob.
      CLEAR qty_kg.
      CLEAR pack_size.
    ENDLOOP.
    DATA(lv_last) =
      |</lineitem>| &&
      |</form>|.

    CONCATENATE lv_xml lv_last  INTO lv_xml.


    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).



*    out->write( qty_kg ).
*    out->write( it_item ).




  ENDMETHOD.
ENDCLASS.
