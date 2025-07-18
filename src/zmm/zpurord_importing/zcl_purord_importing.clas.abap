

CLASS zcl_purord_importing DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*    INTERFACES if_oo_adt_classrun.
    CLASS-METHODS :
*      create_client
*        IMPORTING url           TYPE string
*        RETURNING VALUE(result) TYPE REF TO if_web_http_client
*        RAISING   cx_static_check ,

      read_posts
        IMPORTING lv_PO2          TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_template_name TYPE string VALUE 'zpo_import/zpo_import'."'zpo/zpo_v2'."
ENDCLASS.



CLASS ZCL_PURORD_IMPORTING IMPLEMENTATION.


  METHOD read_posts .

*******************************************************************************Header Select Query

    SELECT SINGLE
       a~PurchaseOrder,
       a~supplier,

       a~PurchaseOrderdate,
       a~yy1_quotation_date_po_pdh,
       a~yy1_quotation_no_pdh,
       b~companycodename,
       c~HouseNumber,
       c~StreetName,
       c~streetprefixname1,
       c~streetprefixname2,
       c~CityName,
       c~postalcode AS postalcode2,
       c~districtname,
       i~countryname,
       d~addressid,
       d~SupplierName,
       d~BPAddrStreetName,
       d~CityName AS cn,
       d~businesspartnerpannumber,
       d~postalcode,
       d~taxnumber3,
       d~businesspartnername1,
       d~businesspartnername2,
       e~RegionName,
       g~businesspartnername,
       h~CreationDate
     FROM i_purchaseorderapi01 AS a
     LEFT JOIN i_companycode AS b ON a~CompanyCode = b~CompanyCode
     LEFT JOIN i_supplier AS d ON d~Supplier = a~Supplier
     LEFT JOIN I_Address_2 AS c ON c~addressid = d~addressid
     LEFT JOIN i_regiontext AS e ON e~region = d~region
     LEFT JOIN i_Businesspartner AS g ON g~BusinessPartner = d~Supplier
     LEFT JOIN i_supplierquotationtp AS h ON h~Supplier = a~Supplier
     LEFT JOIN i_countrytext AS i ON c~Country = i~Country

     WHERE a~PurchaseOrder = @lv_po2
     INTO  @DATA(wa) PRIVILEGED ACCESS.


    DATA: sr TYPE i.
    sr = 1.
    DATA: indicator_count TYPE i VALUE 0.



*******************************************************************************ITEM Select Query

    SELECT
      a~yy1_hscode_pdi,
      a~baseunit,
      a~taxcode,
      a~OrderQuantity,
      a~netpriceamount,
      a~DocumentCurrency,
      a~YY1_PackingMode_PDI,
      b~ProductName,
      b~product,
       a~purchasingdocumentdeletioncode,
      a~purchaseorderitem,
      c~currencyshortname,
      a~yy1_countryoforigin_pdi
    FROM I_PurchaseOrderItemAPI01 AS a
    LEFT JOIN i_producttext AS b ON b~Product = a~Material
    LEFT JOIN i_currencytext AS c ON a~DocumentCurrency = c~Currency
    WHERE a~PurchaseOrder = @lv_po2
    INTO TABLE @DATA(it) PRIVILEGED ACCESS.

    sort it by PurchaseOrderItem ASCENDING.

    SELECT SINGLE
      a~purchaseorder,
      a~yy1_deliverytext_pdh,
      a~yy1_itemtext_pdh,
      b~PaymentTermsName,
      a~YY1_remarks_PDH,
     a~yy1_serviceperiodstart_pdh,
       a~yy1_serviceperiodendda_pdh,
       a~incotermslocation1,
      e~CountryName,
      d~ValidityEndDate
    FROM I_PurchaseOrderAPI01 AS a
    LEFT JOIN i_paymenttermstext AS b ON b~PaymentTerms = a~PaymentTerms
    LEFT JOIN i_supplier AS c ON c~Supplier = a~Supplier
    LEFT JOIN I_PurchaseOrderTP_2 AS d ON d~PurchaseOrder = a~PurchaseOrder
    LEFT JOIN I_CountryText AS e ON e~Country = c~Country
    WHERE a~PurchaseOrder = @lv_po2
    INTO @DATA(wa2) PRIVILEGED ACCESS.

    SELECT SINGLE FROM i_purchaseorderitemapi01 AS a
       LEFT JOIN i_purchaseorderapi01 AS b ON a~PurchaseOrder = b~PurchaseOrder
       LEFT JOIN i_supplier AS c ON b~Supplier = c~Supplier
       LEFT JOIN I_Plant AS d ON a~Plant = d~Plant
       LEFT JOIN i_purchasingdocumenttypetext AS e ON b~PurchaseOrderType = e~PurchasingDocumentType
       FIELDS
       a~plant,
       a~PurchaseOrder,
      b~PurchaseOrderType,
       b~PurchaseOrderDate,
       b~Supplier,
       c~TaxNumber3,
       c~BusinessPartnerPanNumber,
       b~YY1_Quotation_No_PDH,
       b~YY1_Quotation_Date_PO_PDH,
       b~YY1_Remarks_PDH,
       d~PlantName,
       e~PurchasingDocumentTypeName

       WHERE a~PurchaseOrder = @lv_po2
       INTO @DATA(wa1) PRIVILEGED ACCESS.


*     **********************************************************************PLANT ADDRESS ***************************************
    SELECT SINGLE FROM
        ztable_plant AS a
        FIELDS
        a~address1,
        a~address2,
        a~city,
        a~district,
        a~pin,
        a~state_name,
        a~country
        WHERE a~plant_code = @wa1-Plant
        INTO @DATA(wa_plant_add) PRIVILEGED ACCESS.

    DATA: lv_plant_add TYPE string.
    lv_plant_add = wa_plant_add-address1.
    DATA: lv_space TYPE string VALUE ', '.

    IF wa_plant_add-address2 IS NOT INITIAL.
      IF lv_plant_add IS NOT INITIAL.
        CONCATENATE lv_plant_add lv_space wa_plant_add-address2 INTO lv_plant_add.
      ELSE.
        lv_plant_add = wa_plant_add-address2.
      ENDIF.
    ENDIF.

    IF wa_plant_add-district IS NOT INITIAL.
      IF lv_plant_add IS NOT INITIAL.
        CONCATENATE lv_plant_add lv_space wa_plant_add-district INTO lv_plant_add.
      ELSE.
        lv_plant_add = wa_plant_add-district.
      ENDIF.
    ENDIF.

    IF wa_plant_add-state_name IS NOT INITIAL.
      IF lv_plant_add IS NOT INITIAL.
        CONCATENATE lv_plant_add lv_space wa_plant_add-state_name INTO lv_plant_add.
      ELSE.
        lv_plant_add = wa_plant_add-state_name.
      ENDIF.
    ENDIF.

    IF wa_plant_add-pin IS NOT INITIAL.
      IF lv_plant_add IS NOT INITIAL.
        CONCATENATE lv_plant_add lv_space wa_plant_add-pin INTO lv_plant_add.
      ELSE.
        lv_plant_add = wa_plant_add-pin.
      ENDIF.
    ENDIF.

    IF wa_plant_add-country IS NOT INITIAL.
      IF lv_plant_add IS NOT INITIAL.
        CONCATENATE lv_plant_add lv_space wa_plant_add-country INTO lv_plant_add.
      ELSE.
        lv_plant_add = wa_plant_add-country.
      ENDIF.
    ENDIF.

    REPLACE ALL OCCURRENCES OF ',,' IN lv_plant_add WITH ','.

*    ********************************************************************************for amenden no *************************************
    SELECT SINGLE FROM
    i_purchaseorderapi01 AS a
    LEFT JOIN i_purgprocessingstatustext AS b ON a~PurchasingProcessingStatus = b~PurchasingProcessingStatus
    AND b~Language = 'E'
    FIELDS
    b~PurchasingProcessingStatusName,
    b~PurchasingProcessingStatus
    WHERE a~PurchaseOrder = @lv_po2
    INTO @DATA(wa_status) PRIVILEGED ACCESS.

    SELECT FROM
    i_purchaseorderchangedocument AS a
    LEFT JOIN i_purordchangedocumentitem AS b ON a~PurchaseOrder = b~PurchaseOrder
    FIELDS
    a~CreationDate,
    a~ChangeDocument,
    a~PurchaseOrder,
    b~changedocnewfieldvalue
    WHERE a~PurchaseOrder = @lv_po2
    INTO TABLE @DATA(lt_amend) PRIVILEGED ACCESS.

    DATA : count_amend TYPE string.
    count_amend = lines( lt_amend ).
    SORT lt_amend BY ChangeDocument DESCENDING.
    READ TABLE lt_amend INTO DATA(wa_amend) INDEX 0.

    DATA : lv_date TYPE vdm_validitystart.
    lv_date = cl_abap_context_info=>get_system_date( ).
    SELECT FROM
    c_purorderitemdocumentchanges( p_datefunction = '20250101', p_startdate = '20250101', p_enddate = @lv_date ) AS a
    FIELDS
    a~ChangeDocument,
    a~ChangeDocNewFieldValue,
    a~changedocobject
    WHERE a~changedocobject = @lv_po2
    ORDER BY a~ChangeDocument
    INTO TABLE @DATA(lt_amend2) PRIVILEGED ACCESS.
    CLEAR count_amend.
    DATA: flag TYPE i VALUE 1.
    DATA: lt_ChangeDate TYPE TABLE OF i_purchaseorderchangedocument-Creationdate.
    DATA: wa_ChangeDocument TYPE i_purchaseorderchangedocument-Creationdate.

    LOOP AT lt_amend2 INTO DATA(wa_amend2).
      IF flag = 1.
        SELECT FROM
        i_purchaseorderchangedocument AS a
        FIELDS
        a~CreationDate,
        a~ChangeDocument
        WHERE a~ChangeDocument = @wa_amend2-ChangeDocument
        INTO TABLE @DATA(lt_amend3) PRIVILEGED ACCESS.
        LOOP AT lt_amend3 INTO DATA(wa_amend3).
          APPEND wa_amend3-CreationDate TO lt_ChangeDate.
          CLEAR wa_amend3.
        ENDLOOP.
        count_amend = count_amend + 1.
      ENDIF.
      IF wa_amend2-ChangeDocNewFieldValue = '05'.
        flag = 1.
      ENDIF.


      CLEAR wa_amend2.
    ENDLOOP.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    DATA str1 TYPE string.
    LOOP AT lt_amend INTO DATA(wa_lt_amend).
      str1 = wa_lt_amend-PurchaseOrder.
    ENDLOOP.

    SELECT COUNT( a~ChangeDocNewFieldValue )
     FROM  i_purordchangedocumentitem WITH PRIVILEGED ACCESS AS a
     WHERE a~PurchaseOrder = @lv_po2 AND a~ChangeDocNewFieldValue = '05'
     INTO @DATA(lv_string1).
    DATA str3 TYPE string.
    DATA str4 TYPE string.
    IF lv_string1 > 1 .
      str3 = lv_string1 - 1.
    ELSE.
      str3 = ''.
    ENDIF.
    IF str3 IS NOT INITIAL.
      CONCATENATE wa_lt_amend-PurchaseOrder  str3 INTO str4 SEPARATED BY '-'.

    ENDIF.
    DATA: lv_amend TYPE string.
    SORT lt_ChangeDate DESCENDING.
    READ TABLE lt_ChangeDate INTO DATA(wa_ChangeDate) INDEX 1.


    lv_amend = wa-PurchaseOrder.
    IF lv_amend IS NOT INITIAL.
      CONCATENATE lv_amend ' - ' count_amend INTO lv_amend.
    ELSE.
      lv_amend = count_amend.
    ENDIF.

    IF lv_amend IS INITIAL.
      CLEAR wa_ChangeDate.
    ENDIF.

    SELECT SINGLE
      b~CurrencyShortName
    FROM I_PurchaseOrderItemAPI01 AS a
    INNER JOIN i_currencytext AS b ON a~DocumentCurrency = b~Currency
    WHERE a~PurchaseOrder = @lv_po2
    INTO @DATA(wa_cuurency) PRIVILEGED ACCESS.


********************************************************************************Header XML
    DATA : vendor_add TYPE string.
    DATA : comp_add TYPE string.
    CONCATENATE wa-HouseNumber wa-StreetName wa-StreetPrefixName1 wa-StreetPrefixName2
    wa-CityName wa-postalcode2 wa-DistrictName wa-CountryName INTO vendor_add SEPARATED BY space.

    DATA: lv_vendorname TYPE string.
    CONCATENATE wa-BusinessPartnerName1 wa-BusinessPartnerName2 INTO lv_vendorname SEPARATED BY space.

    IF str4 IS INITIAL.
      CLEAR wa_ChangeDate.
    ENDIF.
    DATA(main_xml) =
    |<FORM>| &&
    |<PurchaseOrderNode>| &&
    |<HEADER>| &&
    |<COMPANYNAME>{ wa-companycodename }</COMPANYNAME>| &&
    |<COMPANYADDRESS>{ comp_add }</COMPANYADDRESS>| &&
    |<DOCNO>{ wa-PurchaseOrder }</DOCNO>| &&
    |<PLANT>{ wa1-PlantName }</PLANT>| &&
    |<amendmentno>{ str4 }</amendmentno>| &&       " done
    |<amendmentdate>{ wa_ChangeDate }</amendmentdate>| &&
    |<potype>{ wa1-PurchasingDocumentTypeName }</potype>| &&
    |<VENDORNAME>{ lv_vendorname }</VENDORNAME>| &&
    |<VENDORADDRESS>{ vendor_add }</VENDORADDRESS>| &&
    |<PARTYCODE>{ wa-Supplier }</PARTYCODE>| &&
    |<PANNUMBER>{ wa-businesspartnerpannumber }</PANNUMBER>| &&
    |<GSTIN>{ wa-taxnumber3 }</GSTIN>| &&
    |<P.O.NUMBER>{ wa-PurchaseOrder }</P.O.NUMBER>| &&
    |<P.O.DATE>{ wa-PurchaseOrderDate }</P.O.DATE>| &&
    |<QUOTATION.NO>{ wa-yy1_quotation_no_pdh }</QUOTATION.NO>| &&
    |<QUOTATION.DATE>{ wa-yy1_quotation_date_po_pdh }</QUOTATION.DATE>| &&
    |<amend>{ str4 }</amend>| &&
    |<amenddate>{ wa_ChangeDate }</amenddate>| &&
    |<currencyCode>{ wa_cuurency }</currencyCode>| &&
    |</HEADER>| &&
    |<PurchaseOrderItems>|.

    CLEAR wa_cuurency.


*******************************************************************************ITEM XML


    DATA : total_fright_chrg TYPE p DECIMALS 2.
    DATA : total_sea_fright_chrg TYPE p DECIMALS 2.
    DATA : total_ins_chrg TYPE p DECIMALS 2.
    DATA : total_other_chg TYPE p DECIMALS 2.
    DATA : total_val_with_tax TYPE p DECIMALS 2.
    LOOP AT it INTO DATA(wa_item).
      SELECT SINGLE
            FROM i_purchasinginforecordapi01 AS a
            FIELDS
             a~PurchasingInfoRecord,
             a~YY1_VendorSpecialName_SOS
            WHERE a~Material = @wa_item-Product AND a~Supplier = @wa1-Supplier
            INTO @DATA(wa_purchaseapi) PRIVILEGED ACCESS.

      SELECT FROM
         i_purordpricingelementtp_2 AS a
         FIELDS
         a~PurchaseOrder,
         a~PurchaseOrderItem,
         a~ConditionAmount,
         a~ConditionType,
         a~ConditionBaseValue,
         a~ConditionRateAmount,
         a~FreightSupplier
         WHERE a~PurchaseOrder = @lv_po2 AND a~PurchaseOrderItem = @wa_item-PurchaseOrderItem
         INTO TABLE @DATA(lt_price) PRIVILEGED ACCESS.

      READ TABLE lt_price INTO DATA(wa_fr2) WITH KEY ConditionType = 'ZFR2'.
      DATA : lv_fright TYPE p DECIMALS 2.
      IF wa_fr2 IS NOT INITIAL.
        lv_fright  += wa_fr2-ConditionAmount.
      ENDIF.
      total_fright_chrg += lv_fright.
      CLEAR wa_fr2.
      CLEAR lv_fright.


      DATA: lv_ins TYPE p DECIMALS 2.
      READ TABLE lt_price INTO DATA(wa_in2) WITH KEY ConditionType = 'ZIN2'.
      IF wa_in2 IS NOT INITIAL.
        lv_ins += wa_in2-ConditionAmount.
      ENDIF.
      total_ins_chrg += lv_ins.
      CLEAR wa_in2.
      CLEAR lv_ins.


      READ TABLE lt_price INTO DATA(wa_sf1) WITH KEY ConditionType = 'ZSF1'.
      READ TABLE lt_price INTO DATA(wa_sf2) WITH KEY ConditionType = 'ZSF2'.
      DATA: lv_seaFreight TYPE p DECIMALS 2.
      IF wa_sf1 IS NOT INITIAL.
        lv_seaFreight  += wa_sf1-ConditionAmount.
      ENDIF.
      IF wa_sf2 IS NOT INITIAL.
        lv_seaFreight  += wa_sf2-ConditionAmount.
      ENDIF.
      total_sea_fright_chrg += lv_seaFreight.
      CLEAR wa_sf1.
      CLEAR wa_sf2.
      CLEAR lv_seaFreight.


      READ TABLE lt_price INTO DATA(wa_ot1) WITH KEY ConditionType = 'ZOT1'.
      READ TABLE lt_price INTO DATA(wa_ot2) WITH KEY ConditionType = 'ZOT2'.
      DATA: lv_ot TYPE p DECIMALS 2.
      IF wa_ot1 IS NOT INITIAL.
        lv_ot  += wa_ot1-ConditionAmount.
      ENDIF.
      IF wa_ot2 IS NOT INITIAL.
        lv_ot  += wa_ot2-ConditionAmount.
      ENDIF.
      total_other_chg += lv_ot.
      CLEAR wa_ot1.
      CLEAR wa_ot2.
      CLEAR lv_ot.



      DATA : lv_index TYPE i VALUE -1.


*      SELECT SINGLE
*      FROM i_purchasinginforecordapi01 AS a
*      FIELDS
*       a~PurchasingInfoRecord,
*       a~YY1_VendorSpecialName_SOS
*      WHERE a~Material = @wa_item-Product AND a~Supplier = @wa1-Supplier
*      INTO @DATA(wa_purchaseapi) PRIVILEGED ACCESS.


      SELECT SINGLE
      FROM I_TaxCodeText AS a
      FIELDS
      a~TaxCodeName,
      a~TaxCode
      WHERE a~TaxCode = @wa_item-TaxCode
      INTO @DATA(wa_gst) PRIVILEGED ACCESS.

      DATA: lv_material_value TYPE p DECIMALS 2.
      lv_material_value = wa_item-OrderQuantity * wa_item-NetPriceAmount.

      DATA: lv_string TYPE string.
      DATA: lv_result_cgst TYPE p DECIMALS 2.
      DATA: lv_result_sgst TYPE p DECIMALS 2.
      DATA: lv_result_igst TYPE p DECIMALS 2.
      DATA: lv_result_gst TYPE string.

      lv_string = wa_gst-TaxCodeName.


      IF lv_string IS NOT INITIAL.
        FIND to_upper( 'CGST' ) IN lv_string MATCH OFFSET lv_index.

        IF lv_index <> -1.
          lv_index = lv_index + 5.
          lv_result_gst = lv_string+lv_index(2).
          REPLACE '%' IN lv_result_gst WITH ' '.
          CONDENSE lv_result_gst NO-GAPS.
          lv_result_cgst = lv_result_gst.
        ENDIF.

        CLEAR lv_index.
        CLEAR lv_result_gst.
        lv_index = -1.

        FIND to_upper( 'SGST' ) IN lv_string MATCH OFFSET lv_index.
        IF lv_index <> -1.
          lv_index = lv_index + 5.
          lv_result_gst = lv_string+lv_index(2).
          REPLACE '%' IN lv_result_gst WITH ' '.
          CONDENSE lv_result_gst NO-GAPS.
          lv_result_sgst = lv_result_gst.
        ENDIF.

        CLEAR lv_index.
        CLEAR lv_result_gst.
        lv_index = -1.

        FIND to_upper( 'IGST' ) IN lv_string MATCH OFFSET lv_index.
        IF lv_index <> -1.
          lv_index = lv_index + 5.
          lv_result_gst = lv_string+lv_index(2).
          REPLACE '%' IN lv_result_gst WITH ' '.
          CONDENSE lv_result_gst NO-GAPS.
          lv_result_igst = lv_result_gst.
        ENDIF.

      ENDIF.
      lv_index = -1.
      CLEAR lv_result_gst.
      CLEAR lv_string.


      IF lv_result_cgst IS NOT INITIAL.
        lv_result_sgst = lv_result_cgst.
      ENDIF.

      IF lv_result_sgst IS NOT INITIAL.
        lv_result_cgst = lv_result_sgst.
      ENDIF.
      lv_result_igst = lv_result_igst.

      DATA : lv_total_value TYPE p DECIMALS 2.


      lv_total_value  = lv_material_value + ( lv_material_value * lv_result_cgst ) / 100 + ( lv_material_value * lv_result_sgst ) / 100 + ( lv_material_value * lv_result_igst ) / 100.
*      total_val_tax = total_val_tax + lv_total_value - lv_material_value.

      total_val_with_tax = total_val_with_tax + lv_total_value.

      SELECT
      FROM i_purchaseordschedulelinetp_2 AS a
      FIELDS
       a~PurchaseOrder,
       a~ScheduleLineDeliveryDate
      WHERE a~PurchaseOrder = @lv_po2 AND a~PurchaseOrderItem = @wa_item-PurchaseOrderItem
      INTO TABLE @DATA(lt_deliverydate) PRIVILEGED ACCESS.

      DATA(lt_deliverydate_len) = lines( lt_deliverydate ).
      SORT lt_deliverydate BY ScheduleLineDeliveryDate DESCENDING.
      READ TABLE lt_deliverydate INTO DATA(wa_deliverydate) INDEX 1.

      DATA : lv_delivery_date TYPE string.

      IF lt_deliverydate_len < 2.
        lv_delivery_date = wa_deliverydate-ScheduleLineDeliveryDate.
      ELSE.
        lv_delivery_date = 'As Per Annexure'.
      ENDIF.
*******************************************purchaseorder status ***********************

*  SELECT SINGLE FROM
*    i_purchaseorderapi01 AS a
*    LEFT JOIN i_purgprocessingstatustext AS b ON a~PurchasingProcessingStatus = b~PurchasingProcessingStatus
*    AND b~Language = 'E'
*    FIELDS
*    b~PurchasingProcessingStatusName,
*    b~PurchasingProcessingStatus
*    WHERE a~PurchaseOrder = @lv_po2
*    INTO @DATA(wa_status) PRIVILEGED ACCESS.



      IF wa_status-PurchasingProcessingStatus <> '05'.
        wa_status-PurchasingProcessingStatusName = 'Draft'.
      ENDIF.
      IF wa_status-PurchasingProcessingStatusName = 'Release completed'.
        wa_status-PurchasingProcessingStatusName = 'Approved'.
      ENDIF.
      IF indicator_count = sr.
        wa_status-PurchasingProcessingStatusName = 'Cancelled'.
      ENDIF.
      IF indicator_count = 1 AND sr <> 1.
        wa_status-PurchasingProcessingStatusName = 'Partially Cancelled'.
      ENDIF.

      SELECT SINGLE FROM
        i_purchaseorderitemnotetp_2 AS a
        FIELDS
        a~PlainLongText
        WHERE a~PurchaseOrder = @lv_po2 AND a~PurchaseOrderItem = @wa_item-PurchaseOrderItem AND a~TextObjectType = 'F01' AND a~Language = 'E'
        INTO @DATA(text_remark) PRIVILEGED ACCESS.

      IF wa_item-PurchasingDocumentDeletionCode = 'L'.
        indicator_count = indicator_count + 1.
        lv_result_sgst = '0'.
        lv_result_cgst = '0'.
        lv_result_igst = '0'.
        lv_material_value = '0'.
        wa_item-OrderQuantity = 0.
        wa_item-NetPriceAmount = 0.
        clear lv_delivery_date.
      ENDIF.


      DATA(item_xml) =
      |<PurchaseOrderItemNode>| &&
      |<DESCRIPTION>{ wa_purchaseapi-YY1_VendorSpecialName_SOS }</DESCRIPTION>| &&
      |<PACKINGMODE>{ wa_item-YY1_PackingMode_PDI }</PACKINGMODE>| &&
      |<HSCODE>{ wa_item-yy1_hscode_pdi }</HSCODE>| &&
      |<UOM>{ wa_item-BaseUnit }</UOM>| &&
      |<QTY>{ wa_item-OrderQuantity }</QTY>| &&
      |<RATEPERUNIT>{ wa_item-NetPriceAmount }</RATEPERUNIT>| &&
      |<CURRENCY>{ wa_item-currencyshortname }</CURRENCY>| .

      DATA(lv_xml_line2) =
      |<dispatch_date>{ lv_delivery_date }</dispatch_date>| &&
      |<country>{ wa_item-yy1_countryoforigin_pdi }</country>| &&
      |<remarks>{ text_remark }</remarks>| &&
       "paste kiya hai yaha
      |</PurchaseOrderItemNode>|
      .
      CONCATENATE main_xml item_xml  lv_xml_line2 INTO main_xml.
      CLEAR lv_delivery_date.
      CLEAR wa_item.
      CLEAR lv_delivery_date.
      CLEAR lt_deliverydate_len.
      CLEAR wa_purchaseapi.
      clear text_remark.
    ENDLOOP.


*******************************************************************************FOOTER XML

*CONCATENATE WA2-house_num1 WA2-street WA2-city1 WA2-post_code1 into WA2-house_num1.
    SELECT SINGLE FROM
    I_PurchaseOrderAPI01 AS a
    FIELDS
    a~YY1_Remarks_PDH
    WHERE a~PurchaseOrder = @lv_po2
    INTO @DATA(lv_remarks) PRIVILEGED ACCESS.

*    ************************************************************ annexure cal

    LOOP AT it INTO DATA(wa3).
      SELECT SINGLE
        FROM i_purchasinginforecordapi01 AS a
        FIELDS
         a~PurchasingInfoRecord,
         a~YY1_VendorSpecialName_SOS
        WHERE a~Material = @wa3-Product AND a~Supplier = @wa1-Supplier
        INTO @DATA(wa_purchaseapi2) PRIVILEGED ACCESS.

      SHIFT wa3-Product LEFT DELETING LEADING '0'.

      SELECT SINGLE
       FROM zmaterial_table AS a
       FIELDS
       a~trade_name
       WHERE a~mat = @wa3-Product
       INTO @DATA(des1) PRIVILEGED ACCESS.
*
      DATA(lv_xml_line3) =
         |<annexureitem>| &&
        |<sr>{ sr }</sr>| &&
        |<vendor>{ wa_purchaseapi2-YY1_VendorSpecialName_SOS }</vendor>| &&
        |<des1>{ des1 }</des1>| &&
        |<des2>{ wa3-YY1_PackingMode_PDI }</des2>| &&
        |<table>|.
*
      CONCATENATE main_xml lv_xml_line3 INTO main_xml.
      sr = sr + 1.
      CLEAR des1.
*
      SELECT
      FROM i_purchaseordschedulelinetp_2 AS a
      FIELDS
       a~PurchaseOrder,
       a~ScheduleLineDeliveryDate,
       a~ScheduleLineOrderQuantity
      WHERE a~PurchaseOrder = @lv_po2 AND a~PurchaseOrderItem = @wa3-PurchaseOrderItem
      INTO TABLE @DATA(lt_deliverydate2) PRIVILEGED ACCESS.

      DATA(lt_deliverydate_len2) = lines( lt_deliverydate2 ).
      SORT lt_deliverydate2 BY ScheduleLineDeliveryDate DESCENDING.
      READ TABLE lt_deliverydate2 INTO DATA(wa_deliverydate3) INDEX 1.

      DATA : lv_delivery_date2 TYPE string.

      IF lt_deliverydate_len2 < 2.
        lv_delivery_date2 = wa_deliverydate3-ScheduleLineDeliveryDate.
      ELSE.
        lv_delivery_date2 = 'As Per Annexure'.
      ENDIF.
*
      SORT lt_deliverydate2 BY ScheduleLineDeliveryDate ASCENDING.
      LOOP AT lt_deliverydate2 INTO DATA(wa_deliverydate2).
        DATA(lv_xml_sch) =
        |<item1>| &&
        |<sch_qty>{ wa_deliverydate2-ScheduleLineOrderQuantity }</sch_qty>| &&
        |<dis_date>{ wa_deliverydate2-ScheduleLineDeliveryDate }</dis_date>| &&
        |</item1>|.
*
        CONCATENATE main_xml lv_xml_sch INTO main_xml.
      ENDLOOP.
      DATA(lv_xml_line8) =

           |</table>| &&
           |</annexureitem>|.
*
      CONCATENATE main_xml lv_xml_line8 INTO main_xml.
      CLEAR wa_purchaseapi2.
      CLEAR lt_deliverydate2.

    ENDLOOP.

    SELECT SINGLE FROM
    i_purchaseordernotetp_2 AS a
    FIELDS
    a~PlainLongText
    WHERE a~PurchaseOrder = @lv_po2 AND a~TextObjectType = 'F01' AND a~Language = 'E'
    INTO @DATA(text_ins) PRIVILEGED ACCESS.

    SELECT SINGLE FROM
    i_purchaseordernotetp_2 AS a
    FIELDS
    a~PlainLongText
    WHERE a~PurchaseOrder = @lv_po2 AND a~TextObjectType = 'F06' AND a~Language = 'E'
    INTO @DATA(text_bill) PRIVILEGED ACCESS.

    SELECT SINGLE FROM
    i_purchaseordernotetp_2 AS a
    FIELDS
    a~PlainLongText
    WHERE a~PurchaseOrder = @lv_po2 AND a~TextObjectType = 'F05' AND a~Language = 'E'
    INTO @DATA(text_ship) PRIVILEGED ACCESS.

    SELECT SINGLE FROM
    i_purchaseordernotetp_2 AS a
    FIELDS
    a~PlainLongText
    WHERE a~PurchaseOrder = @lv_po2 AND a~TextObjectType = 'F03' AND a~Language = 'E'
    INTO @DATA(text_free) PRIVILEGED ACCESS.

    SELECT SINGLE FROM
    i_purchaseordernotetp_2 AS a
    FIELDS
    a~PlainLongText
    WHERE a~PurchaseOrder = @lv_po2 AND a~TextObjectType = 'F04' AND a~Language = 'E'
    INTO @DATA(text_oth) PRIVILEGED ACCESS.

    SELECT SINGLE FROM
    i_purchaseordernotetp_2 AS a
    FIELDS
    a~PlainLongText
    WHERE a~PurchaseOrder = @lv_po2 AND a~TextObjectType = 'F08' AND a~Language = 'E'
    INTO @DATA(text_wr) PRIVILEGED ACCESS.

    DATA(footer_xml) =
        |</PurchaseOrderItems>| &&
        |<FOOTER>| &&
        |<remarks>{ lv_remarks }</remarks>| &&
        |<PAYMENTTERMS>{ wa2-YY1_remarks_PDH }</PAYMENTTERMS>| &&
        |<COUNTRYOFORIGIN>{ wa2-CountryName }</COUNTRYOFORIGIN>| &&
        |<MODEOFDISPATCH>{ wa2-yy1_deliverytext_pdh }</MODEOFDISPATCH>| &&
        |<purchasingstatus>{ wa_status-PurchasingProcessingStatusName }</purchasingstatus>| &&
*    |<SHIPPINGTERMS>{ wa2-yy1_itemtext_pdh }</SHIPPINGTERMS>| &&
        |<SHIPPINGTERMS>{ wa2-incotermslocation1 }</SHIPPINGTERMS>| &&
        |<ORDERVALIDITY>{ wa2-ValidityEndDate }</ORDERVALIDITY>| &&
        |<SERVICEPERIODSTART_PDH>{ wa2-yy1_serviceperiodstart_pdh  }</SERVICEPERIODSTART_PDH>| &&
        |<SERVICEPERIODend_PDH>{ wa2-YY1_Serviceperiodendda_PDH  }</SERVICEPERIODend_PDH>| &&
        |<total_fright_chrg>{ total_fright_chrg }</total_fright_chrg>| &&
        |<total_ins_chrg>{ total_ins_chrg }</total_ins_chrg>| &&
        |<total_oth_chrg>{ total_other_chg }</total_oth_chrg>| &&
        |<total_seaFreight_chrg>{ total_sea_fright_chrg }</total_seaFreight_chrg>| &&
        |<insurance>{ text_ins }</insurance>| &&
        |<bill>{ text_bill }</bill>| &&
        |<ship>{ text_ship }</ship>| &&
        |<freetime>{ text_free }</freetime>| &&
        |<otherTerm>{ text_oth }</otherTerm>| &&
        |<wrantee>{ text_wr }</wrantee>| &&
        |</FOOTER>| &&
        |</PurchaseOrderNode>| &&
        |</FORM>|.
    CONCATENATE main_xml footer_xml INTO main_xml.

*out->write(  MAIN_XML ).

    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = main_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

  ENDMETHOD.
ENDCLASS.
