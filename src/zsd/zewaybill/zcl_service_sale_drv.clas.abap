CLASS zcl_service_sale_drv DEFINITION
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
    CONSTANTS lc_template_name TYPE string VALUE 'zsd_serviceSales/zsd_serviceSales'."'zpo/zpo_v2'."
    CONSTANTS company_code TYPE string VALUE 'GT00'.
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.

ENDCLASS.



CLASS zcl_service_sale_drv IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .


    DATA(lv_header) =
    |<Form>|.

    DO 4 TIMES.
      DATA : plant_add   TYPE string.
      DATA : p_add1  TYPE string.
      DATA : p_add2 TYPE string.
      DATA : p_city TYPE string.
      DATA : p_dist TYPE string.
      DATA : p_state TYPE string.
      DATA : p_pin TYPE string.
      DATA : p_country TYPE string.

      DATA: lv_time           TYPE string,
            lv_formatted_time TYPE string.

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
      c~country ,
      d~irnno ,
      d~ackno ,
      d~ackdate ,
      d~billingdocno  ,    "invoice no
      d~billingdate ,     "ackdate
      d~signedqrcode,
      e~customerpurchaseorderdate ,   "DATE[1]
      e~yy1_poamendmentdate_sdh ,     "DATE[2]
      e~yy1_poamendmentno_sdh ,         "AdvancedRecieved[1]    Amendment PO No
      a~billingdocumentdate   ,    "workorderdate
      f~customer  ,    " GTZ CUST CODE
      g~customername   ,  "bil to name
      g~taxnumber3 ,   "bill to gst
      i~region   , " bill to state name
      e~yy1_dono_sdh  ,  " ship to dono
      e~yy1_dodate_sdh  ,  " ship to dodate
      e~purchaseorderbycustomer ,
      j~paymenttermsconditiondesc  ,  "Ship to Payment Terms
      k~supplierfullname  ,  " Transporter
      a~creationtime  ,  "IssueDate
      e~yy1_precarriageby_sdh  ,  "mode
      k~taxnumber3 AS Transport_GST  , "Transport_GST
      a~documentreferenceid ,
      b~salesdocument ,
      e~creationdate ,
      a~yy1_no_of_packages_bdh ,
      a~yy1_remark_bdh ,
      a~yy1_DATE_TIME_REMOVAL_BDH


      FROM I_BillingDocument AS a
      LEFT JOIN i_billingdocumentitem AS b ON b~billingdocument = a~billingdocument
      LEFT JOIN ztable_plant AS c ON c~plant_code = b~plant
      LEFT JOIN ztable_irn AS d ON d~billingdocno = a~BillingDocument AND a~CompanyCode = d~bukrs
      LEFT JOIN i_salesdocument AS e ON e~salesdocument = b~salesdocument
      LEFT JOIN i_billingdocumentpartner AS f ON f~billingdocument = a~billingdocument
      LEFT JOIN i_customer AS g ON g~customer = f~Customer
      LEFT JOIN i_regionText AS i ON g~country = i~country AND g~Region = i~Region
      LEFT JOIN I_PaymentTermsConditionsText AS j ON j~PaymentTerms = a~CustomerPaymentTerms AND j~Language = 'E'
      LEFT JOIN i_Supplier AS k ON k~supplier = f~Supplier
      WHERE a~billingdocument = @bill_doc
      AND a~CompanyCode = @company_code
      INTO @DATA(wa_data)
      PRIVILEGED ACCESS.

      p_add1 = wa_data-address1 && ',' .
      p_add2 = wa_data-address2 && ','.
      p_dist = wa_data-district && ','.
      p_city = wa_data-city && ','.
      p_state = wa_data-state_name .
      p_pin =  wa_data-pin .
      p_country =  '(' &&  wa_data-country && ')' .


***********************************************************************************CONDENSE TIME OF CREATION TIME
      DATA:
        lv_time_ist TYPE t,
        lv_seconds  TYPE i.

      lv_time = wa_data-CreationTime.


      lv_seconds = lv_time MOD 100.
      lv_seconds = lv_seconds + ( ( lv_time MOD 10000 ) / 100 ) * 60.
      lv_seconds = lv_seconds + ( lv_time / 10000 ) * 3600.


      lv_seconds = lv_seconds + 19800.


      lv_time_ist = ( lv_seconds / 3600 ) * 10000 + ( ( lv_seconds MOD 3600 ) / 60 ) * 100 + ( lv_seconds MOD 60 ).

      lv_time = lv_time_ist.


      lv_formatted_time = lv_time(2) && ':' && lv_time+2(2) && ':' && lv_time+4(2).

      " Remove any unwanted spaces (just in case)
      CONDENSE lv_formatted_time.



*******************************************************************************************************************

      DATA(lv2_date) = wa_data-YY1_POAmendmentDate_SDH.

      " Format as YYYY-MM-DD
      DATA(lv_formatted_date2) = lv2_date(4) && '-' && lv2_date+4(2) && '-' && lv2_date+6(2).

      " Remove unwanted spaces (if any)
      CONDENSE lv_formatted_date2.




***********************************************************************************SHIP TO  Address

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
       c~customername ,
       a~soldtoparty ,
       e~regionname
      FROM I_BillingDocument AS a
      LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument
      LEFT JOIN i_customer AS c ON c~customer = b~Customer
      LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
      LEFT JOIN I_RegionText AS e ON e~Region = d~Region AND e~Country = d~Country
      WHERE b~partnerFunction = 'RE'
      AND c~Language = 'E'
      AND a~BillingDocument = @bill_doc
      INTO @DATA(wa_bill)
      PRIVILEGED ACCESS.





***********************************************************************************SHIP TO  Address
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
       e~RegionName
      FROM I_BillingDocumentitem AS a
      LEFT JOIN i_salesdocumentitem AS b ON b~salesdocument = a~salesdocument
      LEFT JOIN i_customer AS c ON c~customer = b~shiptoparty
      LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
      LEFT JOIN I_RegionText AS e ON e~Region = d~Region AND e~Country = d~country
      WHERE
*    b~partnerFunction IN ('WE', 'AG') and
      c~Language = 'E'
      AND a~BillingDocument = @bill_doc
      INTO @DATA(wa_ship)
      PRIVILEGED ACCESS.


***********************************************************************************SOLD TO  Address
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
       c~customername
      FROM I_BillingDocument AS a
      LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument
      LEFT JOIN i_customer AS c ON c~customer = b~Customer
      LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
      WHERE b~partnerFunction = 'AG'
      AND c~Language = 'E'
      AND a~BillingDocument = @bill_doc
      INTO @DATA(wa_sold)
      PRIVILEGED ACCESS.


******************************************************************************************************ITEM LEVEL

      SELECT
      a~billingdocument,
      a~billingdocumentitem,
      a~product,
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
      g~conditionamount  , "i_amt
      g~conditionamount AS conditionamount2  ,  "freight
      g~conditionamount AS conditionamount3  ,  "tcs
      g~conditionamount AS conditionamount4  ,  "rounding off
      g~conditioncurrency ,  "ZINC
      g~conditionamount AS conditionamount5  ,    "ZINP
      g~conditionamount AS conditionamount6    "ZINS

      FROM I_BillingDocumentItem AS a
      LEFT JOIN i_handlingunititem AS b ON a~referencesddocument = b~handlingunitreferencedocument
      LEFT JOIN i_handlingunitheader AS c ON b~handlingunitexternalid = c~handlingunitexternalid
      LEFT JOIN i_productdescription AS d ON d~product = c~packagingmaterial
      LEFT JOIN I_SalesDocumentItem AS e ON e~SalesDocument = a~SalesDocument AND e~salesdocumentitem = a~salesdocumentitem
      LEFT JOIN i_productplantbasic AS f ON a~Product = f~Product AND a~Plant = f~Plant
      LEFT JOIN i_billingdocumentitemprcgelmnt AS g ON g~BillingDocument = a~BillingDocument
      WHERE a~billingdocument = @bill_doc
      INTO TABLE  @DATA(lt_item)
      PRIVILEGED ACCESS.

      SORT lt_item BY BillingDocumentItem.
      DELETE ADJACENT DUPLICATES FROM lt_item COMPARING BillingDocumentItem.


********************************************************************************************ITEM AMT & RATE



      SELECT
       a~conditionType  ,  "hidden conditiontype
       a~conditionamount ,  "hidden conditionamount
       a~conditionratevalue  ,  "condition ratevalue
       a~conditionbasevalue    " condition base value
       FROM I_BillingDocItemPrcgElmntBasic AS a
        WHERE a~BillingDocument = @bill_doc
       INTO TABLE @DATA(lt_item2)
       PRIVILEGED ACCESS.




**********************************************************************FOOTER LEVEL

      SELECT SINGLE
      a~actualgoodsmovementdate
      FROM i_deliverydocument AS a
      INTO @DATA(wa_footer)
      PRIVILEGED ACCESS.

      SELECT SINGLE
      FROM i_billingdocument AS a
      FIELDS
      a~yy1_serviceprtodate_bdh,
      a~yy1_serviceprfromdate_bdh,
      a~YY1_AgreementDate_BDH,
      a~YY1_AgreementNo_BDH,
      a~YY1_ItemNote_BDH,
      a~yy1_ordervalidfrom_bdh,
      a~yy1_ordervalidto_bdh
      WHERE a~BillingDocument = @bill_doc
      INTO @DATA(service_date) PRIVILEGED ACCESS.

******************************************************************************HEADER XML
      CONCATENATE p_add1  p_add2  p_dist p_city   p_state '-' p_pin  p_country INTO plant_add SEPARATED BY space.
*CONCATENATE wa_bill-StreetPrefixName1 wa_bill-StreetPrefixName2 wa_bill-cityname wa_bill-PostalCode wa_bill-DistrictName wa_bill-country   INTO wa_bill-StreetName SEPARATED BY SPACE.
*CONCATENATE wa_ship-StreetPrefixName1 wa_ship-StreetPrefixName2 wa_ship-cityname wa_ship-PostalCode wa_ship-DistrictName wa_ship-country   INTO wa_ship-StreetName SEPARATED BY SPACE.
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

      DATA(lv_header1) =
      |<BillingDocumentNode>| &&
      |<pagename>{ lv_pagename }</pagename>| &&
      |<AckDate>{ wa_data-ackdate }</AckDate>| &&
      |<AckNumber>{ wa_data-ackno }</AckNumber>| &&
      |<BillingDate>{ wa_data-BillingDocumentDate }</BillingDate>| &&
      |<servicefromdate>{ service_date-YY1_serviceprfromdate_BDH }</servicefromdate>| &&
      |<servicetodate>{ service_date-YY1_serviceprTodate_BDH }</servicetodate>| &&
      |<itemnote>{ service_date-YY1_ItemNote_BDH }</itemnote>| &&
      |<AgreementDate>{ service_date-YY1_AgreementDate_BDH }</AgreementDate>| &&
      |<AgreementNo>{ service_date-YY1_AgreementNo_BDH }</AgreementNo>| &&
      |<ordervalidfrom>{ service_date-yy1_ordervalidfrom_bdh }</ordervalidfrom>| &&
      |<ordervalidto>{ service_date-yy1_ordervalidto_bdh }</ordervalidto>| &&
      |<DocumentReferenceID>{ wa_data-documentreferenceid }</DocumentReferenceID>| &&
      |<Irn>{ wa_data-irnno }</Irn>| &&
      |<SignedQrCode>{ wa_data-signedqrcode }</SignedQrCode>| &&
      |<PurchaseOrderByCustomer>{ wa_data-PurchaseOrderByCustomer }</PurchaseOrderByCustomer>| &&
      |<SalesDocument>{ wa_data-SalesDocument }</SalesDocument>| &&
      |<SalesOrderDate>{ wa_data-CreationDate }</SalesOrderDate>| &&
      |<YY1_CustPODate_BD_h_BDH>{ wa_data-customerpurchaseorderdate }</YY1_CustPODate_BD_h_BDH>| &&
      |<YY1_PLANT_COM_ADD_BDH>{ plant_add }</YY1_PLANT_COM_ADD_BDH>| &&
      |<YY1_PLANT_COM_NAME_BDH>{ wa_data-plant_name1 }</YY1_PLANT_COM_NAME_BDH>| &&
      |<YY1_PLANT_GSTIN_NO_BDH>{ wa_data-gstin_no }</YY1_PLANT_GSTIN_NO_BDH>| &&
      |<YY1_PreCarriage_bd_h_BDH>{ wa_data-yy1_precarriageby_sdh }</YY1_PreCarriage_bd_h_BDH>| &&
      |<YY1_amendmentdate_bd_BDH>{ lv_formatted_date2 }</YY1_amendmentdate_bd_BDH>| &&
      |<YY1_amendmentno_bd_BDH>{ wa_data-yy1_poamendmentno_sdh }</YY1_amendmentno_bd_BDH>| &&
      |<YY1_dodatebd_BDH>{ wa_data-YY1_DODate_SDH  }</YY1_dodatebd_BDH>| &&
      |<YY1_dono_bd_BDH>{ wa_data-YY1_DONo_SDH }</YY1_dono_bd_BDH>| &&
      |<YY1_removal_date_bd_BDH></YY1_removal_date_bd_BDH>| &&
      |<YY1_issuetime_bd_BDH>{ lv_formatted_time }</YY1_issuetime_bd_BDH>| &&
      |<YY1_NO_OF_PACKAGES_BDH>{ wa_data-yy1_no_of_packages_bdh }</YY1_NO_OF_PACKAGES_BDH>| &&
      |<YY1_REMARK_BDH>{ wa_data-yy1_remark_bdh }</YY1_REMARK_BDH>| &&
      |<YY1_DATE_TIME_REMOVAL_BDH>{ wa_data-yy1_date_time_removal_bdh }</YY1_DATE_TIME_REMOVAL_BDH>|.


      CONCATENATE lv_header lv_header1 INTO lv_header.
********************************************************************************************FREIGHT BEGIN

      SELECT SUM( conditionamount )
        FROM i_billingdocitemprcgelmntbasic
        WHERE i_billingdocitemprcgelmntbasic~BillingDocument = @bill_doc
          AND i_billingdocitemprcgelmntbasic~ConditionType = 'ZFRT'
        INTO @DATA(wa_freight) PRIVILEGED ACCESS.

      DATA(lv_freight) =
          |<YY1_FreightAmount_BDH>{ wa_freight }</YY1_FreightAmount_BDH>|.

      CONCATENATE lv_header lv_freight INTO lv_header.


********************************************************************************************FREIGHT END

********************************************************************************************INSURANCE BEGIN

      SELECT SUM( conditionamount )
        FROM i_billingdocitemprcgelmntbasic
        WHERE i_billingdocitemprcgelmntbasic~BillingDocument = @bill_doc
          AND i_billingdocitemprcgelmntbasic~ConditionType IN ('ZINC' , 'ZINP' , 'ZINS')
        INTO @DATA(wa_insurance) PRIVILEGED ACCESS.

      DATA(lv_insurance) =
          |<YY1_InsuranceAmount_BDH>{ wa_insurance }</YY1_InsuranceAmount_BDH>|.
      CONCATENATE lv_header lv_insurance INTO lv_header.


********************************************************************************************INSURANCE    END

********************************************************************************************TCS BEGIN

      SELECT SUM( conditionamount )
        FROM i_billingdocitemprcgelmntbasic
        WHERE i_billingdocitemprcgelmntbasic~BillingDocument = @bill_doc
          AND i_billingdocitemprcgelmntbasic~ConditionType = 'JTC1'
        INTO @DATA(wa_tcs) PRIVILEGED ACCESS.

      DATA(lv_tcs) =
          |<TCSAmount>{ wa_tcs }</TCSAmount>|.
      CONCATENATE lv_header lv_tcs INTO lv_header.


********************************************************************************************TCS    END

*********************************************************************************************ROUND OFF

      SELECT SUM( conditionamount )
        FROM i_billingdocitemprcgelmntbasic
        WHERE i_billingdocitemprcgelmntbasic~BillingDocument = @bill_doc
          AND i_billingdocitemprcgelmntbasic~ConditionType = 'ZDIF'
        INTO @DATA(wa_round) PRIVILEGED ACCESS.

      DATA(lv_round) =
          |<RoundAmount>{ wa_round }</RoundAmount>|.
      CONCATENATE lv_header lv_round INTO lv_header.


********************************************************************************************ROUND OFF    END

******************************************************************************************VEHICLE NUM
      SELECT SINGLE
      b~vehiclenum ,
      a~billingdocument
      FROM i_billingdocument AS a
      LEFT JOIN ztable_irn AS b ON b~billingdocno = a~BillingDocument AND a~CompanyCode = b~bukrs
      WHERE a~billingdocument = @bill_doc
      INTO @DATA(wa_header3) PRIVILEGED ACCESS.

      IF wa_header3-vehiclenum IS NOT INITIAL .
        DATA(lv_header3) =
           |<YY1_VehicleNo_BDH>{ wa_header3-vehiclenum }</YY1_VehicleNo_BDH>| .
        CONCATENATE lv_header lv_header3 INTO lv_header.

      ELSE .

        SELECT SINGLE
        a~yy1_vehicleno_bdh ,
        a~billingdocument
        FROM i_billingdocument AS a
        WHERE a~BillingDocument = @bill_doc
        INTO @DATA(wa_header2) PRIVILEGED ACCESS.

        DATA(lv_header2) =
           |<YY1_VehicleNo_BDH>{ wa_header2-YY1_VehicleNo_BDH }</YY1_VehicleNo_BDH>| .
        CONCATENATE lv_header lv_header2 INTO lv_header.

      ENDIF.
*****************************************************************************************END VEHICLE NUM

******************************************************************************************TRANSPORTER

      SELECT SINGLE
      a~billingdocument ,
      b~suppliername ,
      b~taxnumber3
      FROM i_billingdocument AS a
      LEFT JOIN I_Supplier AS b ON b~Supplier = a~YY1_TransportDetails_BDH
      WHERE a~BillingDocument = @bill_doc
      INTO @DATA(wa_header4) PRIVILEGED ACCESS.

      DATA(lv_header4) =
           |<YY1_TransportDetails_BDHT>{ wa_header4-SupplierName }</YY1_TransportDetails_BDHT>| &&
           |<YY1_TransportGST_bd_h_BDH>{ wa_header4-TaxNumber3 }</YY1_TransportGST_bd_h_BDH>| .
      CONCATENATE lv_header lv_header4 INTO lv_header.


*******************************************************************************************END TRANSPORTER

      DATA(lv_header5) =
       |<BillToParty>| &&
       |<AddressLine1Text>{ wa_bill-CustomerName }</AddressLine1Text>| &&
       |<Partner>{ wa_data-Customer }</Partner>| &&
       |<RegionName>{ wa_bill-RegionName }</RegionName>| &&
       |</BillToParty>| &&
       |<Items>|.

      CONCATENATE lv_header lv_header5 INTO lv_header.

      LOOP AT lt_item INTO DATA(wa_item).
*      SHIFT wa_item-Product LEFT DELETING LEADING '0'.
        DATA(lv_item) =
        |<BillingDocumentItemNode>| &&
        |<BillingDocumentItemText>{ wa_item-Product }</BillingDocumentItemText>| &&
        |<IN_HSNOrSACCode>{ wa_item-consumptiontaxctrlcode }</IN_HSNOrSACCode>| &&
        |<Quantity>{ wa_item-BillingQuantity }</Quantity>| &&
        |<QuantityUnit>{ wa_item-BillingQuantityUnit }</QuantityUnit>| &&
        |<YY1_CustomerItemCode_BDI>{ wa_item-MaterialByCustomer }</YY1_CustomerItemCode_BDI>| &&
        |<YY1_avg_package_bd_BDI>{ wa_item-YY1_PackSize_sd_SDI }</YY1_avg_package_bd_BDI>| &&
        |<YY1_avg_package_bd_BDIU>{ wa_item-YY1_PackSize_sd_SDIU }</YY1_avg_package_bd_BDIU>| &&
        |<YY1_BD_ZINS_amt_BDI>{ wa_item-conditionamount6 }</YY1_BD_ZINS_amt_BDI>| &&
        |<YY1_bd_ZINC_amt_BDI>{ wa_item-ConditionCurrency }</YY1_bd_ZINC_amt_BDI>| &&
        |<YY1_bd_jtc1_tcsamount_BDI>{ wa_item-conditionamount3 }</YY1_bd_jtc1_tcsamount_BDI>| &&
        |<YY1_bd_zdif_BDI>{ wa_item-conditionamount4 }</YY1_bd_zdif_BDI>| &&
        |<YY1_bd_zinp_amt_BDI>{ wa_item-conditionamount5 }</YY1_bd_zinp_amt_BDI>| &&
        |<YY1_bd_zrft_amt_BDI>{ wa_item-conditionamount2 }</YY1_bd_zrft_amt_BDI>| &&
        |<YY1_no_of_packages_bd_BDI></YY1_no_of_packages_bd_BDI>| .


***************************************************************************************DISPER & AMT

        SELECT SINGLE  conditionratevalue ,
                conditionamount
          FROM i_billingdocitemprcgelmntbasic
          WHERE BillingDocument = @bill_doc AND BillingDocumentItem = @wa_item-BillingDocumentItem
            AND ConditionType = 'ZDIS'
          INTO  @DATA(wa_discount) PRIVILEGED ACCESS.
        DATA(lv_discount) =
              |<YY1_bd_zdis_dis_amt_BDI>{ wa_discount-ConditionAmount }</YY1_bd_zdis_dis_amt_BDI>| &&
              |<YY1_bd_zdis_dis_per_BDI>{ wa_discount-conditionratevalue }</YY1_bd_zdis_dis_per_BDI>| .
        CONCATENATE lv_item lv_discount INTO lv_item.
***************************************************************************************DISPER & AMT END

***************************************************************************************TRADENAME BEGIN
        DATA : lv_product TYPE string.
        lv_product = wa_item-Product.
        SHIFT lv_product LEFT DELETING LEADING '0'.

        SELECT SINGLE
        a~trade_name
        FROM zmaterial_table AS a
        WHERE a~mat = @lv_product
        INTO @DATA(wa_item3) PRIVILEGED ACCESS.

        IF wa_item3 IS NOT INITIAL.
          DATA(lv_item3) =
          |<YY1_fg_material_name_BDI>{ wa_item3 }</YY1_fg_material_name_BDI>|.
          CONCATENATE lv_item lv_item3 INTO lv_item .
        ELSE.
          " Fetch Product Name from `i_producttext`
          SELECT SINGLE
          a~productname
          FROM i_producttext AS a
          WHERE a~product = @wa_item-Product
          INTO @DATA(wa_item4) PRIVILEGED ACCESS.

          DATA(lv_item4) =
          |<YY1_fg_material_name_BDI>{ wa_item4 }</YY1_fg_material_name_BDI>|.
          CONCATENATE lv_item lv_item4 INTO lv_item.
        ENDIF.
        CONCATENATE lv_item '<ItemPricingConditions>' INTO lv_item.
***************************************************************************************TRADENAME END
        LOOP AT lt_item2 INTO DATA(wa_item2) .
          IF wa_item2-ConditionAmount < 0.
            wa_item2-ConditionAmount = wa_item2-ConditionAmount * -1.
          ENDIF.
          DATA(lv_item2) =
          |<ItemPricingConditionNode>| &&
          |<ConditionAmount>{ wa_item2-ConditionAmount }</ConditionAmount>| &&
          |<ConditionBaseValue>{ wa_item2-ConditionBaseValue }</ConditionBaseValue>| &&
          |<ConditionRateValue>{ wa_item2-ConditionRateValue }</ConditionRateValue>| &&
          |<ConditionType>{ wa_item2-ConditionType }</ConditionType>| &&
          |</ItemPricingConditionNode>|.
          CONCATENATE lv_item lv_item2 INTO lv_item.
          CLEAR wa_item2.
        ENDLOOP.
        DATA(it3) = |</ItemPricingConditions>| && |</BillingDocumentItemNode>|.
        CONCATENATE lv_item it3 INTO lv_item.
        CONCATENATE lv_header lv_item  INTO lv_header.
        CLEAR wa_item.
        CLEAR wa_item3.
        CLEAR wa_item4.
      ENDLOOP.

*    CONCATENATE lv_header lv_item  INTO lv_header .

      wa_ship-StreetName = wa_ship-HouseNumber && ' ' && wa_ship-StreetName.
      wa_sold-StreetName = wa_sold-HouseNumber && ' ' && wa_sold-StreetName.

      DATA(lv_footer) =
      |</Items>| &&
      |<PaymentTerms>| &&
      |<PaymentTermsName>{ wa_data-PaymentTermsConditionDesc }</PaymentTermsName>| &&
      |</PaymentTerms>| &&
      |<ShipToParty>| &&
      |<AddressLine1Text>{ wa_ship-CustomerName }</AddressLine1Text>| &&
      |<AddressLine2Text>{ wa_ship-StreetName }</AddressLine2Text>| &&
      |<AddressLine3Text>{ wa_ship-StreetPrefixName1 }</AddressLine3Text>| &&
      |<AddressLine4Text>{ wa_ship-StreetPrefixName2 }</AddressLine4Text>| &&
      |<AddressLine5Text>{ wa_ship-CityName }</AddressLine5Text>| &&
      |<AddressLine6Text>{ wa_ship-DistrictName }</AddressLine6Text>| &&
      |<AddressLine7Text>{ wa_ship-PostalCode }</AddressLine7Text>| &&
      |<AddressLine8Text>{ wa_ship-Country }</AddressLine8Text>| &&
      |<RegionName>{ wa_ship-RegionName }</RegionName>| &&
      |</ShipToParty>| &&
      |<SoldToParty>| &&
      |<AddressLine2Text>{ wa_sold-StreetName }</AddressLine2Text>| &&
      |<AddressLine3Text>{ wa_sold-StreetPrefixName1 }</AddressLine3Text>| &&
      |<AddressLine4Text>{ wa_sold-StreetPrefixName2 }</AddressLine4Text>| &&
      |<AddressLine5Text>{ wa_sold-CityName }</AddressLine5Text>| &&
      |<AddressLine6Text>{ wa_sold-DistrictName }</AddressLine6Text>| &&
      |<AddressLine7Text>{ wa_sold-PostalCode }</AddressLine7Text>| &&
      |<AddressLine8Text>{ wa_sold-Country }</AddressLine8Text>| &&
      |</SoldToParty>| &&
      |<Supplier>| &&
      |<RegionName>{ wa_data-state_name }</RegionName>| &&
      |</Supplier>| &&
      |<TaxationTerms>| &&
      |<IN_BillToPtyGSTIdnNmbr>{ wa_data-TaxNumber3 }</IN_BillToPtyGSTIdnNmbr>| &&
      |</TaxationTerms>| &&
      |</BillingDocumentNode>|.

      CONCATENATE lv_header lv_footer INTO lv_header.

    ENDDO.

    DATA(lv_form_last) =
    |</Form>|.

    CONCATENATE lv_header lv_form_last INTO lv_header.

*    REPLACE ALL OCCURRENCES OF '&' IN lv_header WITH 'and'.
    REPLACE ALL OCCURRENCES OF '<=' IN lv_header WITH 'let'.
    REPLACE ALL OCCURRENCES OF '>=' IN lv_header WITH 'get'.
*
    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_header
        template = lc_template_name
      RECEIVING
        result   = result12 ).

*      result12 = lv_header.


  ENDMETHOD .
ENDCLASS.
