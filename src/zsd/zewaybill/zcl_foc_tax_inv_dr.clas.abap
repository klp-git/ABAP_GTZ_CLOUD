CLASS zcl_foc_tax_inv_dr DEFINITION
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
    CONSTANTS lc_template_name TYPE string VALUE 'zsd_foc_inv/zsd_foc_inv'."'zpo/zpo_v2'."
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.
ENDCLASS.



CLASS zcl_foc_tax_inv_dr IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .

    DATA(lv_xml) =
    |<Form>|.

    DO 4 TIMES.

      SELECT SINGLE

      a~creationdate,
      a~documentreferenceid,
      a~purchaseorderbycustomer,
      c~salesdocument,
      c~creationdate AS salecreationdate,
      c~salesdocument AS i_salesdaument,
      b~plant,
      b~referencesddocument,
      d~gstin_no ,
      d~state_code2 ,
     d~plant_name1 ,
     d~address1 ,
     d~address2 ,
     d~city ,
     d~district ,
     d~state_name ,
     d~pin ,
     d~country,
     e~supplierName,
     e~taxnumber3,
     c~yy1_dono_sdh,
     c~salesdocumenttype,
     c~sddocumentcategory,
     c~yy1_dodate_sdh,
     c~yy1_poamendmentno_sdh,
     c~yy1_poamendmentdate_sdh,
     c~customerpurchaseorderdate,
     f~region,
     g~regionname,
     h~addressid,
     i~streetname,
     i~streetprefixname1,
     i~streetprefixname2,
     i~cityname,
     i~postalcode,
     i~districtname,
     a~billingdocumentdate,
     a~transactioncurrency
*   i~COuntry


      FROM i_billingdocument WITH PRIVILEGED ACCESS AS a
      LEFT JOIN i_billingdocumentitem WITH PRIVILEGED ACCESS AS b ON a~BillingDocument = b~BillingDocument
      LEFT JOIN i_salesdocument WITH PRIVILEGED ACCESS AS c  ON b~SalesDocument = c~SalesDocument
      LEFT JOIN I_Customer WITH PRIVILEGED ACCESS AS h ON a~SoldToParty = h~customer
     INNER JOIN i_address_2  WITH PRIVILEGED ACCESS AS i ON h~AddressID = i~AddressID
      LEFT JOIN ztable_plant WITH PRIVILEGED ACCESS AS d ON d~plant_code = b~plant
      LEFT JOIN i_supplier WITH PRIVILEGED ACCESS AS e ON a~YY1_TransportDetails_BDH = e~Supplier
      LEFT    JOIN i_customer WITH PRIVILEGED ACCESS AS f ON a~SoldToParty = e~Customer
      LEFT JOIN i_regiontext WITH PRIVILEGED ACCESS AS g ON f~Country = g~Country

      WHERE a~billingdocument = @bill_doc
      INTO  @DATA(wa_header).

      SELECT SINGLE
      a~yy1_date_time_removal_bdh,
      a~yy1_no_of_packages_bdh,
      a~yy1_remark_bdh,
      a~yy1_transportdetails_bdh,
      b~supplierfullname,
      b~Taxnumber3


      FROM i_billingdocument WITH PRIVILEGED ACCESS AS a
      LEFT JOIN i_supplier WITH PRIVILEGED ACCESS AS b ON a~YY1_TransportDetails_BDH = b~Supplier

       WHERE a~billingdocument = @bill_doc
       INTO @DATA(footer).




      """"""""""""""""item level data """"""""""""""""'

      SELECT
       a~billingdocument,
       a~billingdocumentitem,
       a~plant,
       a~product,
       a~billingdocumentitemtext ,   "mat
       a~billingquantity  ,  "Quantity
       a~billingquantityunit  ,  "UOM "" quantityunit
       b~consumptiontaxctrlcode  ,   "HSN CODE
       c~yy1_packsize_sd_sdi  ,  "i_avgpkg
       c~yy1_packsize_sd_sdiu  ,   " package_qtyunit
       c~yy1_noofpack_sd_sdi,
*       a~product,
       e~trade_name,
       f~productname

       FROM I_BillingDocumentItem  WITH PRIVILEGED ACCESS AS a
       LEFT JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS b ON a~Product = b~Product AND a~Plant = b~Plant
       LEFT JOIN zmaterial_table WITH PRIVILEGED ACCESS AS e ON a~product = e~mat
       LEFT JOIN  i_producttext WITH PRIVILEGED ACCESS AS f ON a~Product = f~Product
       LEFT JOIN I_SalesDocumentItem WITH PRIVILEGED ACCESS AS c ON c~SalesDocument = a~SalesDocument AND c~salesdocumentitem = a~salesdocumentitem
       WHERE a~billingdocument =  @bill_doc AND a~BillingQuantity <> '0'
       INTO TABLE  @DATA(lt_item).


      """"""""""""condition based""""""""""""""
      SELECT
     a~conditionType  ,  "hidden conditiontype
     a~conditionamount ,  "hidden conditionamount
     a~conditionratevalue  ,  "condition ratevalue
     a~conditionbasevalue   " condition base value
     FROM I_BillingDocItemPrcgElmntBasic AS a
      WHERE a~BillingDocument =  @bill_doc
     INTO TABLE @DATA(lt_item2) PRIVILEGED ACCESS.

      DATA : plant_add   TYPE string.

      DATA : p_add1  TYPE string.

      DATA : p_add2 TYPE string.

      DATA : p_city TYPE string.

      DATA : p_dist TYPE string.

      DATA : p_state TYPE string.

      DATA : p_pin TYPE string.

      DATA : p_country TYPE string.

      SELECT SINGLE

      c~gstin_no ,

      c~state_code2 ,

      c~plant_name1 ,

      c~address1 ,

      c~address2 ,

      c~city ,

      c~district ,

      c~state_name ,

      c~pin ,

      c~country

      FROM i_billingdocument AS a

      LEFT JOIN i_billingdocumentitem AS b ON b~billingdocument = a~billingdocument

      LEFT JOIN ztable_plant AS c ON c~plant_code = b~plant

      WHERE b~billingdocument = @bill_doc

      INTO @DATA(wa_plant)

      PRIVILEGED ACCESS.

      p_add1 = wa_plant-address1 && ',' .

      p_add2 = wa_plant-address2 && ','.

      p_dist = wa_plant-district && ','.

      p_city = wa_plant-city && ','.

      p_state = wa_plant-state_name .

      p_pin =  wa_plant-pin .

      p_country =  '(' &&  wa_plant-country && ')' .


      CONCATENATE p_add1  p_add2  p_dist p_city   p_state '-' p_pin  p_country INTO plant_add SEPARATED BY space.


      SELECT SINGLE
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
         c~taxnumber3,
         e~regionname

        FROM I_BillingDocument AS a
        LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument
        LEFT JOIN i_customer AS c ON c~customer = b~Customer
        LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
        LEFT JOIN i_regiontext AS e ON e~Region = c~Region AND e~Language = 'E' AND c~Country = e~Country
        WHERE b~partnerFunction = 'AG'
        AND c~Language = 'E'
        AND a~BillingDocument = @bill_doc
        INTO @DATA(wa_sold)
        PRIVILEGED ACCESS.


      SELECT SINGLE FROM
      i_billingdocument AS a
      LEFT JOIN ztable_irn AS b ON a~BillingDocument = b~billingdocno AND a~CompanyCode = b~bukrs
      FIELDS
      b~irnno,
      b~ewaybillno,
      b~ewaydate
      WHERE a~BillingDocument = @bill_doc
      INTO @DATA(lv_ewaybill) PRIVILEGED ACCESS.


      DATA: lv_plant_add TYPE string.
      lv_plant_add = wa_header-state_code2.
      CONCATENATE lv_plant_add ' - ' wa_header-state_name INTO lv_plant_add.

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

      SELECT SINGLE FROM
      i_billingdocument AS a
      FIELDS
      a~YY1_VehicleNo_BDH
      WHERE a~BillingDocument = @bill_doc
      INTO @DATA(lv_yy1_vehicleno_bdh) PRIVILEGED ACCESS.

      DATA(lv_xml1) =
        |<BillingDocumentNode>| &&
        |<pagename>{ lv_pagename }</pagename>| &&
        |<BillingDate>{ wa_header-BillingDocumentDate }</BillingDate>| &&
        |<DocumentReferenceID>{ wa_header-documentreferenceid }</DocumentReferenceID>| &&
        |<TRANSACTIONCURRENCY>{ wa_header-transactioncurrency }</TRANSACTIONCURRENCY>| &&
        |<ewaybill>{ lv_ewaybill-ewaybillno }</ewaybill>| &&
        |<ewaybilldate>{ lv_ewaybill-ewaydate }</ewaybilldate>| &&
        |<PurchaseOrderByCustomer>{ wa_header-PurchaseOrderByCustomer }</PurchaseOrderByCustomer>| &&   " PO number
        |<AmountInWords></AmountInWords>| &&                      " pending
        |<SalesDocument>{ wa_header-SalesDocument }</SalesDocument>| && " Work order no
        |<SalesOrderDate>{ wa_header-salecreationdate }</SalesOrderDate>| && " Work order date
        |<YY1_CustPODate_BD_h_BDH>{ wa_header-CustomerPurchaseOrderDate }</YY1_CustPODate_BD_h_BDH>| && " PO date
        |<YY1_LRDate_BDH></YY1_LRDate_BDH>| &&   " Consignment Note Date
        |<YY1_LRNumber_BDH></YY1_LRNumber_BDH>| &&   " Consignment No
        |<YY1_PLANT_COM_ADD_BDH>{ plant_add }</YY1_PLANT_COM_ADD_BDH>| &&   " Add left side
        |<YY1_PLANT_COM_NAME_BDH></YY1_PLANT_COM_NAME_BDH>| &&   " Invoice number
        |<plant_add>{ lv_plant_add }</plant_add>| &&
        |<YY1_PLANT_GSTIN_NO_BDH>{ wa_header-gstin_no }</YY1_PLANT_GSTIN_NO_BDH>| &&   " First GST No
        |<YY1_TransportDetails_BDHT>{ wa_header-SupplierName }</YY1_TransportDetails_BDHT>| &&   " Head office
        |<YY1_TransportGST_bd_BDH>{ wa_header-TaxNumber3 }</YY1_TransportGST_bd_BDH>| &&   " Transport GST
        |<YY1_VehicleNo_BDH>{ lv_yy1_vehicleno_bdh }</YY1_VehicleNo_BDH>| &&   " Vehicle number
        |<YY1_dodatebd_BDH></YY1_dodatebd_BDH>| &&
        |<YY1_dono_bd_BDH></YY1_dono_bd_BDH>| &&
        |<BillToParty>| &&
        |<Region>{ wa_sold-Region }</Region>| &&
        |<RegionName>{ wa_sold-RegionName }</RegionName>| &&
        |</BillToParty>| &&
        |<Items>|.

      CONCATENATE lv_xml lv_xml1 INTO lv_xml.


*      DELETE ADJACENT DUPLICATES FROM lt_item COMPARING consumptiontaxctrlcode.

      LOOP AT lt_item INTO DATA(wa_item).
        DATA(var1_wa_fg) =   |{ wa_item-product ALPHA = OUT }|.


        SELECT SINGLE
        b~trade_name
        FROM zmaterial_table AS b
        WHERE b~mat = @var1_wa_fg
        INTO @DATA(wa_fg) PRIVILEGED ACCESS.

        IF wa_fg IS NOT INITIAL.
          DATA(lv_fg_mat) = wa_fg.
        ELSE.
          SELECT SINGLE
          a~productname
          FROM i_producttext AS a
          WHERE a~product = @wa_item-product
          INTO @DATA(wa_fg2) PRIVILEGED ACCESS.
          lv_fg_mat = wa_fg2.
        ENDIF.
        """"" change logic of YY1_bd_no_of_package_BDI on 23/04/2025 by apratim
        CLEAR wa_item-YY1_NoofPack_sd_SDI.

        IF wa_item-YY1_PackSize_sd_SDI <> '0'.
          wa_item-YY1_NoofPack_sd_SDI = wa_item-BillingQuantity / wa_item-YY1_PackSize_sd_SDI.
        ENDIF.


        """"""""""""""""""""""""""""""
        DATA(lv_item_xml) =
          |<BillingDocumentItemNode>| &&
          |<IN_HSNOrSACCode>{ wa_item-ConsumptionTaxCtrlCode }</IN_HSNOrSACCode>| &&
          |<Plant>{ wa_item-Plant }</Plant>| &&
          |<Quantity>{ wa_item-BillingQuantity }</Quantity>| &&
          |<QuantityUnit>{ wa_item-YY1_PackSize_sd_SDIU }</QuantityUnit>| &&
          |<YY1_avg_package_bd_BDI>{ wa_item-YY1_PackSize_sd_SDI }</YY1_avg_package_bd_BDI>| &&
          |<YY1_bd_no_of_package_BDI>{ wa_item-YY1_NoofPack_sd_SDI }</YY1_bd_no_of_package_BDI>| &&
          |<YY1_fg_material_name_BDI>{ lv_fg_mat }</YY1_fg_material_name_BDI>| &&
          |<ItemPricingConditions>|
          .

        " Concatenate item XML to the main XML string
        CONCATENATE lv_xml lv_item_xml INTO lv_xml.

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
        DATA(lv_item_footer) =
        |</ItemPricingConditions>| &&
        |</BillingDocumentItemNode>|.

        CONCATENATE lv_xml lv_item_footer INTO lv_xml.
      ENDLOOP.

      DATA: lv_add5 TYPE string.

      CONCATENATE lv_add5 wa_sold-CityName '-' wa_sold-DistrictName INTO lv_add5.

      wa_sold-StreetName = wa_sold-HouseNumber && ' ' && wa_sold-StreetName.

      DATA(lv_soldto_party) =
      |</Items>| &&
      |<SoldToParty>| &&
      |<AddressLine1Text>{ wa_sold-customername }</AddressLine1Text>| &&
      |<AddressLine2Text>{ wa_sold-StreetName }</AddressLine2Text>| &&
      |<AddressLine3Text>{ wa_sold-PostalCode }</AddressLine3Text>| &&
      |<AddressLine4Text>{ wa_sold-housenumber }</AddressLine4Text>| &&
      |<AddressLine5Text>{ lv_add5 }</AddressLine5Text>| &&
      |<AddressLine6Text></AddressLine6Text>| &&
      |<AddressLine7Text></AddressLine7Text>| &&
      |<AddressLine8Text></AddressLine8Text>| &&
      |</SoldToParty>|.

      CONCATENATE lv_xml lv_soldto_party INTO lv_xml.

      DATA(lv_taxation) =
      |<TaxationTerms>| &&
      |<IN_BillToPtyGSTIdnNmbr>{ wa_sold-taxnumber3 }</IN_BillToPtyGSTIdnNmbr>| &&
      |</TaxationTerms>|.

      CONCATENATE lv_xml lv_taxation INTO lv_xml.

      " Closing the <Items> and <BillingDocumentNode> tags
      DATA(no_of_pack) = 'No of Packages'.
      DATA(lv_remark) = 'Remarks'.
      DATA(lv_date_time) = 'Date & Time Removal of Goods'.

      DATA(lv_textelement) =
      |<TextElements>| &&
      |<TextElementNode>| &&
      |<TextElementDescription>{ no_of_pack }</TextElementDescription>| &&
      |<TextElementText>{ footer-yy1_no_of_packages_bdh }</TextElementText>| &&
      |</TextElementNode>| &&
      |<TextElementNode>| &&
      |<TextElementDescription>{ lv_remark }</TextElementDescription>| &&
      |<TextElementText>{ footer-yy1_remark_bdh }</TextElementText>| &&
      |</TextElementNode>| &&
      |<TextElementNode>| &&
      |<TextElementDescription>{ lv_date_time }</TextElementDescription>| &&
      |<TextElementText>{ footer-yy1_date_time_removal_bdh }</TextElementText>| &&
      |</TextElementNode>| &&
      |</TextElements>|.

      CONCATENATE lv_xml lv_textelement INTO lv_xml.

      DATA(lv_footer) =
        |</BillingDocumentNode>|.

      " Concatenate the footer to the main XML string
      CONCATENATE lv_xml lv_footer INTO lv_xml.

      " Final XML is now in lv_xml

    ENDDO.

    DATA(lv_last_form) =
     |</Form>|.

    CONCATENATE lv_xml lv_last_form INTO lv_xml.


    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

*      result12 = lv_xml.


  ENDMETHOD.
ENDCLASS.
