
CLASS  zcl_ficndn_inv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*    INTERFACES if_oo_adt_classrun .
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
        IMPORTING bill_doc        TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zficndn/zficndn'."'zpo/zpo_v2'."
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.
ENDCLASS.



CLASS ZCL_FICNDN_INV IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .

    SELECT SINGLE
      a~soldtoparty,
      b~taxnumber3,
      b~customerfullname,    """""""""" Name
      b~customername,     """""""""""""""""Name
      c~streetname ,         " sold to add
      c~streetprefixname1 ,   " sold to add
      c~streetprefixname2 ,   " sold to add
      c~cityname ,   " ship to add
      c~region ,  "sold to add
      c~postalcode ,   " sold to add
      c~districtname ,   " sold to add
      c~country ,
      c~housenumber,   """""""''''''' adddress
      a~creationdate ,   """""""""""" for date
      e~referencesddocument,   """ this fetch for joining for serial number
      f~accountingdocexternalreference,        """"""""""""""Serial No. of Corresponding Tax Invoice /Bill of Supply & Date
      a~billingdocumenttype,    """""""""""""Nature of Document
      a~yy1_remark_bdh,
      a~billingdocument,
      a~documentreferenceid,
      a~billingdocumentdate

      FROM i_billingdocument WITH PRIVILEGED ACCESS AS a
      LEFT JOIN i_customer WITH PRIVILEGED ACCESS AS b ON a~SoldToParty = b~customer
       LEFT JOIN i_address_2   WITH PRIVILEGED ACCESS  AS c ON b~AddressID = c~AddressID
        LEFT JOIN i_billingdocumentitem WITH PRIVILEGED ACCESS AS e ON a~BillingDocument = e~BillingDocument
           LEFT JOIN i_salesdocument WITH PRIVILEGED ACCESS AS f  ON e~referencesddocument = f~ReferenceSDDocument

      WHERE a~billingdocument = @bill_doc

      INTO @DATA(wa_header).

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""SHIP TO  Address
    SELECT SINGLE
     d~streetname ,         " ship to add
     d~streetprefixname1 ,   " ship to add
     d~streetprefixname2 ,   " ship to add
     d~cityname ,   " ship to add
     d~postalcode ,   " ship to add
     d~districtname ,   " ship to add
     d~country ,
     d~housenumber ,
     c~customername,
     e~regionname,
     c~taxnumber3,
     a~billingdocument,
     c~AddressID,
     f~CountryName,
     d~region

    FROM I_BillingDocumentitem AS a
    LEFT JOIN i_salesdocumentitem AS b ON b~salesdocument = a~salesdocument
    LEFT JOIN i_customer AS c ON c~customer = b~ShipToParty
    LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
    LEFT JOIN i_regiontext AS e ON e~Region = c~Region AND e~Language = 'E' AND c~Country = e~Country
    LEFT JOIN i_countrytext AS f ON e~country = f~country
    WHERE  a~billingdocument =  @bill_doc
    INTO @DATA(wa_ship) PRIVILEGED ACCESS.

    """""""""""""""""""""""""""sold to """""""""""""""""""''
    SELECT SINGLE
   b~customer,
   d~streetname ,         " sold to add
   d~streetprefixname1 ,   " sold to add
   d~streetprefixname2 ,   " sold to add
   d~cityname ,   " ship to add
   d~region ,  "sold to add
   d~postalcode ,   " sold to add
   d~districtname ,   " sold to add
   d~country ,
   d~housenumber ,
   c~customername,
   c~TaxNumber3,
   e~countryname,
   f~regionname
  FROM I_BillingDocument AS a
  LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument
  LEFT JOIN i_customer AS c ON c~customer = b~Customer
  LEFT JOIN i_countrytext AS e ON c~Country = e~Country
  LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
  LEFT JOIN i_regiontext AS f ON f~Region = c~Region AND f~Language = 'E' AND c~Country = f~Country
  WHERE
*  b~partnerFunction = 'AG' AND
  c~Language = 'E'
  AND  a~billingdocument =  @bill_doc
  INTO @DATA(wa_sold) PRIVILEGED ACCESS.

    DATA : lv_Details_of_consignee  TYPE string.
    lv_Details_of_consignee = wa_sold-HouseNumber.

    CONCATENATE lv_Details_of_consignee wa_sold-streetname ' '
    wa_sold-streetprefixname1 ' ' wa_sold-streetprefixname2
    ' ' wa_sold-CityName ' ' wa_sold-postalcode ' ' wa_sold-districtname
    '  ' wa_sold-CountryName INTO  lv_Details_of_consignee.



*    out->write( wa_sold ).


    """"""""""""""""""""""item level """"""""""""""""""""

    SELECT
       a~billingdocumentitemtext ,   "mat
       a~billingquantity  ,  "Quantity
       a~billingquantityunit  ,  "UOM "" quantityunit
       b~consumptiontaxctrlcode  ,   "HSN CODE
       a~product,
       e~trade_name,
       f~productname,
       a~plant,
       a~billingdocument,
       a~billingdocumentitem
       FROM I_BillingDocumentItem  WITH PRIVILEGED ACCESS AS a
        LEFT JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS b ON a~Product = b~Product AND a~Plant = b~Plant
        LEFT JOIN zmaterial_table WITH PRIVILEGED ACCESS AS e ON a~product = e~mat
         LEFT JOIN  i_producttext WITH PRIVILEGED ACCESS AS f ON a~Product = f~Product

       WHERE a~billingdocument =  @bill_doc AND a~billingquantity <> '0'
       INTO TABLE  @DATA(lt_item).
*    out->write( lt_item ).

    """"""""""""""""""""gst level"""""""""""""""""""""""""""""""



    DATA : lv_statecode TYPE string.
    DATA : lv_statecode2 TYPE string.
    DATA : lv_pan_Recipient TYPE string.
    DATA: lv_length TYPE i.
    DATA: lv_placesup_ship TYPE string.
    lv_length = strlen( wa_sold-TaxNumber3 ).
    lv_length = lv_length - 2.
    lv_statecode = wa_ship-TaxNumber3+0(2).
    lv_statecode2 = wa_sold-TaxNumber3+0(2).
    lv_pan_Recipient = wa_sold-TaxNumber3+2(lv_length).
    lv_placesup_ship = lv_statecode2.
    CONCATENATE lv_placesup_ship wa_sold-RegionName INTO lv_placesup_ship.

    SELECT SINGLE FROM
    i_billingdocumentitem AS a LEFT JOIN
    ztable_plant AS d ON a~plant = d~plant_code
    FIELDS
     d~state_code2 ,
       d~plant_name1 ,
       d~address1 ,
       d~address2 ,
       d~city ,
       d~district ,
       d~state_name ,
       d~pin ,
       d~country AS supplierad,
       d~gstin_no,
       d~cin_no
       WHERE a~BillingDocument = @bill_doc
       INTO @DATA(lv_plant) PRIVILEGED ACCESS.

    SELECT SINGLE FROM
    i_billingdocument AS a LEFT JOIN
    ztable_irn AS b ON a~BillingDocument = b~billingdocno AND a~CompanyCode = b~bukrs
    FIELDS
    b~irnno,
    b~ackno,
    b~ackdate,
    b~signedqrcode
    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(lv_irn) PRIVILEGED ACCESS.

    DATA : yy1_plant_com_add_bdh TYPE string.
    yy1_plant_com_add_bdh = lv_plant-address1.
    CONCATENATE yy1_plant_com_add_bdh lv_plant-address2  lv_plant-district
    lv_plant-state_name lv_plant-pin lv_plant-supplierad
    INTO yy1_plant_com_add_bdh SEPARATED BY space.

    SELECT SINGLE FROM i_billingdocumentitem AS a
      INNER JOIN i_salesdocument AS b ON a~salesdocument = b~salesdocument
      INNER JOIN i_billingdocument AS c ON b~assignmentreference = c~billingdocument
      FIELDS c~creationdate , c~documentreferenceid
      WHERE a~billingdocument = @bill_doc
      INTO @DATA(lv_serial)
      PRIVILEGED ACCESS.


    SELECT SINGLE FROM i_billingdocumentitem AS a
    LEFT JOIN i_salesdocument AS b ON a~salesdocument = b~salesdocument
    FIELDS
    a~BillingDocument,
    a~salesdocument,
    b~referencesddocument
    WHERE a~billingdocument = @bill_doc
    INTO @DATA(lv_serialno1) PRIVILEGED ACCESS.

    SELECT SINGLE FROM i_billingdocument AS a
    FIELDS
    a~documentreferenceid,
    a~Creationdate
    WHERE a~BillingDocument = @lv_serialno1-referencesddocument
    INTO @DATA(lv_serialno2) PRIVILEGED ACCESS.

    SELECT SINGLE FROM i_billingdocument AS a
    LEFT JOIN i_billingdocumentitem AS b ON a~BillingDocument = b~BillingDocument
    LEFT JOIN I_SalesDocument AS c ON b~ReferenceSDDocument = c~SalesDocument
    FIELDS
    a~yy1_remark_bdh,
    c~YY1_Remarks_SO_SDH
    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(lv_remarks) PRIVILEGED ACCESS.


    wa_sold-StreetName = wa_sold-HouseNumber && ' ' && wa_sold-StreetName.

    DATA(lv_header) =
    |<form>| &&
    |<BillingDocumentNode>| &&
    |<AckDate>{ lv_irn-ackdate }</AckDate>| &&
    |<AckNumber>{ lv_irn-ackno }</AckNumber>| &&
    |<BillingDate>{ wa_header-BillingDocumentDate }</BillingDate>| &&
    |<BillingDocument>{ wa_header-BillingDocument }</BillingDocument>| &&
    |<BillingDocumentType>{ wa_header-BillingDocumentType }</BillingDocumentType>| &&
    |<DocumentReferenceID>{ wa_header-DocumentReferenceID }</DocumentReferenceID>| &&
    |<serialDocumentReferenceID>{ lv_serialno2-DocumentReferenceID }</serialDocumentReferenceID>| &&
    |<serialDocumentReferencedate>{ lv_serialno2-CreationDate }</serialDocumentReferencedate>| &&
    |<Irn>{ lv_irn-irnno }</Irn>| &&
    |<SignedQr>{ lv_irn-signedqrcode }</SignedQr>| &&
    |<YY1_PLANT_COM_ADD_BDH>{ yy1_plant_com_add_bdh }</YY1_PLANT_COM_ADD_BDH>| &&
    |<YY1_PLANT_COM_NAME_BDH>{ lv_plant-plant_name1 }</YY1_PLANT_COM_NAME_BDH>| &&
    |<YY1_PLANT_GSTIN_NO_BDH>{ lv_plant-gstin_no }</YY1_PLANT_GSTIN_NO_BDH>| &&
    |<YY1_SerialDate_BD_h_BDH>{ lv_serial-creationdate }</YY1_SerialDate_BD_h_BDH>| &&
    |<YY1_SerialTaxInvoice_b_BDH>{ lv_serial-documentreferenceid }</YY1_SerialTaxInvoice_b_BDH>| &&
    |<remarks>{ lv_remarks-YY1_REMARK_BDH }</remarks>| &&
    |<BillToParty>| &&
    |<AddressLine2Text>{ wa_sold-StreetName }</AddressLine2Text>| &&
    |<AddressLine3Text>{ wa_sold-StreetPrefixName1 }</AddressLine3Text>| &&
    |<AddressLine4Text>{ wa_sold-HouseNumber }</AddressLine4Text>| &&
    |<AddressLine5Text>{ wa_sold-StreetPrefixName2 }</AddressLine5Text>| &&
    |<AddressLine6Text>{ wa_sold-CityName }</AddressLine6Text>| &&
    |<AddressLine7Text>{ wa_sold-PostalCode }</AddressLine7Text>| &&
    |<AddressLine8Text>{ wa_sold-DistrictName && ',' && wa_sold-CountryName }</AddressLine8Text>| &&
    |<FullName>{ wa_sold-CustomerName }</FullName>| &&
    |<Region>{ wa_sold-Region }</Region>| &&
    |<RegionName>{ wa_sold-RegionName }</RegionName>| &&
    |</BillToParty>| &&
    |<Items>|.

    LOOP AT lt_item INTO DATA(wa_item).

      DATA: lv_fg_material TYPE string.
      DATA: lv_product TYPE zmaterial_table-mat.
      lv_product = wa_item-Product.

      SHIFT lv_product LEFT DELETING LEADING '0'.

      SELECT SINGLE
      b~trade_name
      FROM zmaterial_table AS b
      WHERE b~mat = @lv_product
      INTO @DATA(wa_fg) PRIVILEGED ACCESS.

      IF wa_fg IS NOT INITIAL.
        lv_fg_material = wa_fg.
      ELSE.
        SELECT SINGLE
        a~productname
        FROM i_producttext AS a
        WHERE a~product = @wa_item-Product
        INTO @DATA(wa_fg2) PRIVILEGED ACCESS.
        lv_fg_material = wa_fg2.
      ENDIF.
      SELECT SINGLE FROM i_billingdocumentitemprcgelmnt
        FIELDS conditionratevalue, conditioncurrency, conditionamount
        WHERE billingdocument = @wa_item-billingdocument AND
        billingdocumentitem = @wa_item-billingdocumentitem AND
        conditiontype = 'ZDIS'
        INTO @DATA(wa4)
        PRIVILEGED ACCESS.

      SELECT SINGLE FROM i_billingdocumentitemprcgelmnt
       FIELDS conditioncurrency, conditionamount
       WHERE billingdocument = @wa_item-billingdocument AND
       billingdocumentitem = @wa_item-billingdocumentitem AND
       conditiontype = 'ZDIF'
       INTO @DATA(wa6_zdif)
       PRIVILEGED ACCESS.

      SELECT SINGLE FROM i_billingdocumentitemprcgelmnt
       FIELDS conditionamount,conditionratevalue, conditioncurrency
       WHERE billingdocument = @wa_item-billingdocument AND
       billingdocumentitem = @wa_item-billingdocumentitem AND
       conditiontype = 'ZBSP'
       INTO @DATA(lv_zbsp)
       PRIVILEGED ACCESS.

      SELECT SINGLE FROM i_billingdocumentitemprcgelmnt
     FIELDS conditioncurrency, conditionamount
     WHERE billingdocument = @wa_item-billingdocument AND
     billingdocumentitem = @wa_item-billingdocumentitem AND
     conditiontype = 'ZCDM'
     INTO @DATA(w1_zcdm)
     PRIVILEGED ACCESS.

      SELECT
       a~conditiontype,
       a~conditionamount,
       a~conditionratevalue,
       a~billingdocument,
       a~billingdocumentitem
       FROM i_billingdocitemprcgelmntbasic WITH PRIVILEGED ACCESS AS a
       WHERE a~billingdocument = @bill_doc AND a~BillingDocumentItem = @wa_item-BillingDocumentItem
       INTO TABLE @DATA(lt_gst).

      SELECT SINGLE
       a~conditiontype,
       a~conditionamount,
       a~conditionratevalue,
       a~billingdocument,
       a~billingdocumentitem
       FROM i_billingdocitemprcgelmntbasic WITH PRIVILEGED ACCESS AS a
       WHERE a~billingdocument = @bill_doc AND a~BillingDocumentItem = @wa_item-BillingDocumentItem
       AND a~ConditionType = 'ZBSP'
       INTO @DATA(lt_valueSup).

      SELECT SINGLE
      a~conditiontype,
      a~conditionamount,
      a~conditionratevalue,
      a~billingdocument,
      a~billingdocumentitem
      FROM i_billingdocitemprcgelmntbasic WITH PRIVILEGED ACCESS AS a
      WHERE a~billingdocument = @bill_doc AND a~BillingDocumentItem = @wa_item-BillingDocumentItem
      AND a~ConditionType = 'ZDIS'
      INTO @DATA(lt_DIS).

      DATA : lv_tax TYPE i_billingdocitemprcgelmntbasic-ConditionAmount.
      lv_tax = lt_valueSup-conditionamount + lt_DIS-conditionamount.
      IF wa_header-BillingDocumentType <> 'CBRE'.
        lv_tax = w1_zcdm-ConditionAmount.
      ENDIF.

      DATA(lv_item) =
      |<BillingDocumentItemNode>| &&
      |<GrossAmount></GrossAmount>| &&
      |<IN_HSNOrSACCode>{ wa_item-ConsumptionTaxCtrlCode }</IN_HSNOrSACCode>| &&
      |<Plant>{ wa_item-Plant }</Plant>| &&
      |<TaxAmount>{ lv_tax }</TaxAmount>| &&
      |<YY1_BD_ZCDM_amt_BDI>{ lv_tax  }</YY1_BD_ZCDM_amt_BDI>| &&
      |<YY1_bd_ZBSP_line_BDI>{ lv_zbsp-conditionamount }</YY1_bd_ZBSP_line_BDI>| &&
      |<YY1_bd_zdif_BDI>{ wa6_zdif-conditionamount }</YY1_bd_zdif_BDI>| &&
      |<YY1_bd_zdis_dis_amt_BDI>{ wa4-conditionamount }</YY1_bd_zdis_dis_amt_BDI>| &&
      |<YY1_fg_material_name_BDI>{ lv_fg_material }</YY1_fg_material_name_BDI>| &&
      |<ItemPricingConditions>|.


      CONCATENATE lv_header lv_item INTO lv_header.



      LOOP AT lt_gst INTO DATA(wa_gst).
        DATA(lv_price) =
        |<ItemPricingConditionNode>| &&
        |<ConditionAmount>{ wa_gst-ConditionAmount }</ConditionAmount>| &&
        |<ConditionRateValue>{ wa_gst-ConditionRateValue }</ConditionRateValue>| &&
        |<ConditionType>{ wa_gst-ConditionType }</ConditionType>| &&
        |</ItemPricingConditionNode>|.

        CONCATENATE lv_header lv_price INTO lv_header.
      ENDLOOP.

      DATA(lv_footer_line) =
      |</ItemPricingConditions>| &&
      |</BillingDocumentItemNode>|.

      CONCATENATE lv_header lv_footer_line INTO lv_header.

    ENDLOOP.

    wa_ship-StreetName = wa_ship-HouseNumber && ' ' && wa_ship-StreetName.

    DATA(lv_xml_ship) =
    |</Items>| &&
    |<ShipToParty>| &&
    |<AddressLine2Text>{ wa_ship-StreetPrefixName1 }</AddressLine2Text>| &&
    |<AddressLine3Text>{ wa_ship-StreetName }</AddressLine3Text>| &&
    |<AddressLine4Text>{ wa_ship-HouseNumber }</AddressLine4Text>| &&
    |<AddressLine5Text>{ wa_ship-StreetPrefixName2 }</AddressLine5Text>| &&
    |<AddressLine6Text>{ wa_ship-CityName }</AddressLine6Text>| &&
    |<AddressLine7Text>{ wa_ship-PostalCode }</AddressLine7Text>| &&
    |<AddressLine8Text>{ wa_ship-DistrictName && ',' && wa_ship-CountryName }</AddressLine8Text>| &&
    |<FullName>{ wa_ship-CustomerName }</FullName>| &&
    |<Region>{ wa_ship-TaxNumber3+0(2) }</Region>| &&
    |<RegionName>{ wa_ship-RegionName }</RegionName>| &&
    |</ShipToParty>| &&
    |<Supplier>| &&
    |<Region>{ lv_plant-state_code2 }</Region>| &&
    |<RegionName>{ lv_plant-state_name }</RegionName>| &&
    |</Supplier>| &&
    |<TaxationTerms>| &&
    |<IN_BillToPtyGSTIdnNmbr>{ wa_sold-TaxNumber3 }</IN_BillToPtyGSTIdnNmbr>| &&
    |</TaxationTerms>|
    .

    CONCATENATE lv_header lv_xml_ship INTO lv_header.



    DATA(lv_footer) =
    |</BillingDocumentNode>| &&
    |</form>|.

    CONCATENATE lv_header lv_footer INTO lv_header.
    REPLACE ALL OCCURRENCES OF 'ī' IN lv_header WITH 'i'.

    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_header
        template = lc_template_name
      RECEIVING
        result   = result12 ).



  ENDMETHOD.
ENDCLASS.
