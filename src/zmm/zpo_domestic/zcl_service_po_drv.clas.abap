CLASS zcl_service_po_drv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
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
                  lv_po2          TYPE I_purchaseorderapi01-PurchaseOrder
*                  company_code     TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'ZMM_SERVICE_PO/ZMM_SERVICE_PO'."'zpo/zpo_v2'."
ENDCLASS.



CLASS ZCL_SERVICE_PO_DRV IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).
  ENDMETHOD .


  METHOD if_oo_adt_classrun~main.
  ENDMETHOD.


  METHOD read_posts.
    SELECT SINGLE
          a~PurchaseOrder,
          a~supplier,
          a~PurchaseOrderdate,
          a~yy1_quotation_date_po_pdh,
          a~yy1_quotation_no_pdh,
          b~companycodename,
          c~HouseNumber,
          c~StreetName,
          c~CityName,
          d~SupplierName,
          d~BPAddrStreetName,
          d~CityName AS cn,
          d~businesspartnerpannumber,
          d~postalcode,
          d~taxnumber3,
          e~RegionName,
          g~businesspartnername,
          h~CreationDate,
          a~purchasingprocessingstatus,
          a~yy1_serviceperiodendda_pdh,
          a~yy1_serviceperiodstart_pdh,
          a~yy1_servicetype_pdh,
             j~certificateno,
      j~vendortype,
      j~validfrom
        FROM i_purchaseorderapi01 AS a
        LEFT JOIN i_companycode AS b ON a~CompanyCode = b~CompanyCode
        LEFT JOIN I_Address_2 AS c ON c~addressid = b~addressid
        LEFT JOIN i_supplier AS d ON d~Supplier = a~Supplier
        LEFT JOIN i_regiontext AS e ON e~region = d~region
        LEFT JOIN i_Businesspartner AS g ON g~BusinessPartner = d~Supplier
        LEFT JOIN i_supplierquotationtp AS h ON h~Supplier = a~Supplier
         LEFT JOIN zmsme_table AS j ON a~Supplier = j~vendorno

        WHERE a~PurchaseOrder = @lv_po2
        INTO  @DATA(wa).

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

    SELECT FROM
        i_purchaseorderchangedocument AS a
        FIELDS
        a~CreationDate,
        a~ChangeDocument,
        a~PurchaseOrder
        WHERE a~PurchaseOrder = @lv_po2
        INTO TABLE @DATA(lt_amend).

    DATA : count_amend TYPE string.
    count_amend = lines( lt_amend ).
    SORT lt_amend BY ChangeDocument DESCENDING.
    READ TABLE lt_amend INTO DATA(wa_amend) INDEX 1.

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
    DATA: flag TYPE i VALUE 0.
    DATA: lt_ChangeDate TYPE TABLE OF i_purchaseorderchangedocument-Creationdate.
    DATA: wa_ChangeDocument TYPE i_purchaseorderchangedocument-Creationdate.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
     WHERE a~PurchaseOrder = @str1 AND a~ChangeDocNewFieldValue = '05'
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

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    SELECT SINGLE FROM i_purchaseorderapi01 AS a
    LEFT JOIN i_supplier AS b ON a~Supplier = b~Supplier
    LEFT JOIN i_address_2 AS c ON b~AddressID = c~AddressID
    FIELDS
    c~HouseNumber,
    c~streetname,
    c~streetprefixname1,
    c~streetprefixname2,
    c~cityname,
    c~postalcode,
    c~districtname,
    c~country,
    b~SupplierName,
    b~BPSupplierName
    WHERE a~PurchaseOrder = @lv_po2
    INTO @DATA(lv_address) PRIVILEGED ACCESS.

    SELECT SINGLE FROM i_purchaseorderapi01 AS a
    LEFT JOIN i_purchaseorderpartnerapi01 AS b ON a~PurchaseOrder = b~PurchaseOrder
    LEFT JOIN I_Supplier AS c ON b~Supplier = c~Supplier
    LEFT JOIN i_address_2 AS d ON c~AddressID = d~AddressID
    FIELDS
    d~AddressID,
    d~organizationname1,
    d~HouseNumber,
    d~StreetName,
    d~StreetPrefixName1,
    d~StreetPrefixName2,
    d~CityName,
    d~PostalCode,
    d~DistrictName
    WHERE a~PurchaseOrder = @lv_po2 AND b~PartnerFunction = 'FS'
    INTO @DATA(lv_transporter) PRIVILEGED ACCESS.


    DATA: lv_supp_add TYPE string.
    lv_supp_add = lv_address-HouseNumber.

    CONCATENATE lv_supp_add ',' lv_address-StreetName ',' lv_address-StreetPrefixName1 ','
    lv_address-StreetPrefixName2 ',' lv_address-CityName ',' lv_address-PostalCode ',' lv_address-DistrictName ','
    'India' INTO lv_supp_add.

    REPLACE ALL OCCURRENCES OF ',,' IN lv_supp_add WITH ','.
    SHIFT lv_supp_add LEFT DELETING LEADING ','.

    SELECT SINGLE FROM
    i_purchaseorderapi01 AS a
    LEFT JOIN i_purgprocessingstatustext AS b ON a~PurchasingProcessingStatus = b~PurchasingProcessingStatus
    AND b~Language = 'E'
    FIELDS
    b~PurchasingProcessingStatusName,
    b~PurchasingProcessingStatus
    WHERE a~PurchaseOrder = @lv_po2
    INTO @DATA(wa_status) PRIVILEGED ACCESS.


    IF wa_status-PurchasingProcessingStatus = '02'.
      wa_status-PurchasingProcessingStatusName = 'Draft'.
    ENDIF.

    IF wa-PurchasingProcessingStatus <> '05'.
      CLEAR lv_amend.
      clear wa_changedate.
    ENDIF.

    SELECT SINGLE FROM
    i_purordaccountassignmentapi01 AS a
    FIELDS
    a~MasterFixedAsset
    WHERE a~PurchaseOrder = @lv_po2
    INTO @DATA(lv_assets).

    DATA: service_p TYPE string.
    DATA: service_p_start TYPE string.
    DATA: service_p_end TYPE string.
    DATA: service_t TYPE string.

    service_p_start = wa-YY1_Serviceperiodstart_PDH+6(2) && '/' && wa-YY1_Serviceperiodstart_PDH+4(2) && '/' && wa-YY1_Serviceperiodstart_PDH(4).
    service_p_end = wa-YY1_Serviceperiodendda_PDH+6(2) && '/' && wa-YY1_Serviceperiodendda_PDH+4(2) && '/' && wa-YY1_Serviceperiodendda_PDH(4).
    CONCATENATE service_p_start 'to' service_p_end INTO service_p SEPARATED BY space.

    IF wa-YY1_Serviceperiodstart_PDH IS INITIAL.
      CLEAR service_p.
    ENDIF.

    IF wa-YY1_ServiceType_PDH = 'YES'.
      service_t = 'Comprehensive'.
    ELSEIF wa-YY1_ServiceType_PDH = 'NO'.
      service_t = 'Non-Comprehensive'.
    ENDIF.

    SELECT SINGLE FROM
    i_purchaseorderapi01 AS a
    FIELDS
    a~YY1_po_type_PDH
    WHERE a~PurchaseOrder = @lv_po2
    INTO @DATA(lv_poType).

    DATA: lv_headerText TYPE string.
    CASE lv_poType.
      WHEN '1'.
        lv_headerText = 'WORKS CONTRACT'.
      WHEN '2'.
        lv_headerText = 'PURCHASE ORDER'.
      WHEN '3'.
        lv_headerText = 'SERVICE ORDER'.
    ENDCASE.

    SELECT SINGLE
      a~plainlongtext

      FROM i_purchaseordernotetp_2 WITH PRIVILEGED ACCESS AS a

      WHERE a~PurchaseOrder =  @lv_po2 AND a~TextObjectType = 'F07'

      INTO @DATA(payment).
    SELECT SINGLE
  a~plainlongtext

  FROM i_purchaseordernotetp_2 WITH PRIVILEGED ACCESS AS a

  WHERE a~PurchaseOrder =  @lv_po2 AND a~TextObjectType = 'F06'

  INTO @DATA(invoiceadd).

    IF str4 IS INITIAL.
      CLEAR wa_changedate.
    ENDIF.


    DATA(main_xml) =
    |<FORM>| &&
    |<PurchaseOrderNode>| &&
    |<HEADER>| &&
    |<Headertext>{ lv_headerText }</Headertext>| &&  " done
    |<COMPANYNAME>{ wa-companycodename }</COMPANYNAME>| &&  " done
    |<PO>{ wa1-PurchaseOrder }</PO>| &&       " done
    |<PLANT>{ wa1-PlantName }</PLANT>| &&       " done
    |<amendmentno>{ str4 }</amendmentno>| &&       " done
    |<amendmentdate>{ wa_ChangeDate }</amendmentdate>| &&       " done
    |<PURCHASEORDERTYPE>{ wa1-PurchasingDocumentTypeName }</PURCHASEORDERTYPE>| &&       " done
    |<PODATE>{ wa1-PurchaseOrderDate }</PODATE>| &&       " done
    |<PARTYCODE>{ wa1-Supplier }</PARTYCODE>| &&       " done
    |<PAN>{ wa1-BusinessPartnerPanNumber }</PAN>| &&       " done
    |<GSTIN>{ wa1-TaxNumber3 }</GSTIN>| &&       " done
    |<QUOTATION>{ wa1-YY1_Quotation_No_PDH }</QUOTATION>| &&       " done
    |<QUOTATION_DATE>{ wa1-YY1_Quotation_Date_PO_PDH }</QUOTATION_DATE>| &&       " done
    |<party_name>{ lv_address-BPSupplierName }</party_name>| &&       " done
    |<supplier_address>{ lv_supp_add }</supplier_address>| &&       " done
    |<transporter></transporter>| &&       " done
    |<transportadd></transportadd>| &&       " done
    |<insurance></insurance>| &&       " done
    |<delivery></delivery>| &&       " done
    |<paymentTerms>{ payment }</paymentTerms>| &&       " done
    |<Invoice_Address>{ invoiceadd }</Invoice_Address>| &&
    |<deliveryAdd></deliveryAdd>| &&
    |<SERVICEPERIOD>{ service_p }</SERVICEPERIOD>| &&
    |<SERVICETYPE>{ service_t }</SERVICETYPE>| &&
    |</HEADER>| &&
    |<Items>|.


    SELECT
       a~yy1_hscode_pdi,
       a~baseunit,       " uom
       a~OrderQuantity,   "order qty
       a~netpriceamount,
       a~DocumentCurrency,
       a~YY1_PackingMode_PDI,
       b~ProductName,    " des of goods
       b~product,
       a~YY1_QuantityPerPack_PDI,
       a~taxcode,
       a~PurchaseOrderItem,
       a~purchasingdocumentdeletioncode,
       a~orderpriceunit,
       a~AccountAssignmentCategory,
       a~PurchaseOrderItemText
     FROM I_PurchaseOrderItemAPI01 AS a
     LEFT JOIN i_producttext AS b ON b~Product = a~Material
     WHERE a~PurchaseOrder = @lv_po2
     INTO TABLE @DATA(it).

    SORT it BY PurchaseOrderItem ASCENDING.

    DATA : total_ins_chrg TYPE p DECIMALS 2.
    DATA : total_frt_chrg TYPE p DECIMALS 2.
    DATA : total_val_with_tax TYPE p DECIMALS 2.
    DATA : total_val_tax TYPE p DECIMALS 2.
    DATA : total_other_chrg TYPE p DECIMALS 2.
    DATA : tax0 TYPE p DECIMALS 2.
    DATA : tax15 TYPE p DECIMALS 2.
    DATA : tax25 TYPE p DECIMALS 2.
    DATA : tax6 TYPE p DECIMALS 2.
    DATA : tax9 TYPE p DECIMALS 2.
    DATA : tax14 TYPE p DECIMALS 2.
    DATA : sgst0 TYPE p DECIMALS 2.
    DATA : sgst15 TYPE p DECIMALS 2.
    DATA : sgst25 TYPE p DECIMALS 2.
    DATA : sgst6 TYPE p DECIMALS 2.
    DATA : sgst9 TYPE p DECIMALS 2.
    DATA : sgst14 TYPE p DECIMALS 2.
    DATA : igst0 TYPE p DECIMALS 2.
    DATA : igst3 TYPE p DECIMALS 2.
    DATA : igst5 TYPE p DECIMALS 2.
    DATA : igst12 TYPE p DECIMALS 2.
    DATA : igst18 TYPE p DECIMALS 2.
    DATA : igst28 TYPE p DECIMALS 2.
    DATA: sr TYPE i.
    sr = sr + 1.
    DATA: indicator_count TYPE i VALUE 0.
    DATA : lv_index TYPE i VALUE -1.

    LOOP AT it INTO DATA(wa_item).

      SELECT SINGLE
      FROM i_purchasinginforecordapi01 AS a
      FIELDS
       a~PurchasingInfoRecord,
       a~YY1_VendorSpecialName_SOS
      WHERE a~Material = @wa_item-Product AND a~Supplier = @wa1-Supplier
      INTO @DATA(wa_purchaseapi) PRIVILEGED ACCESS.


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

          DATA: j TYPE i.
          j = lv_index.
          WHILE j < strlen( lv_string ) AND ( lv_string+j(1) ) <> '%'.
            j = j + 1.
          ENDWHILE.
          IF j = strlen( lv_string ).
            lv_result_cgst = 0.
          ELSE.
            j = j - lv_index.
            lv_result_gst = lv_string+lv_index(j).
            REPLACE '%' IN lv_result_gst WITH ' '.
            CONDENSE lv_result_gst NO-GAPS.
            lv_result_cgst = lv_result_gst.
          ENDIF..
        ENDIF.

        CLEAR lv_index.
        CLEAR lv_result_gst.
        lv_index = -1.

        FIND to_upper( 'SGST' ) IN lv_string MATCH OFFSET lv_index.
        IF lv_index <> -1.
          lv_index = lv_index + 5.
          j = lv_index.
          WHILE j < strlen( lv_string ) AND ( lv_string+j(1) ) <> '%'.
            j = j + 1.
          ENDWHILE.
          IF j = strlen( lv_string ).
            lv_result_sgst = 0.
          ELSE.
            j = j - lv_index.
            lv_result_gst = lv_string+lv_index(j).

*          lv_result_gst = lv_string+lv_index(2).
            REPLACE '%' IN lv_result_gst WITH ' '.
            CONDENSE lv_result_gst NO-GAPS.
            lv_result_sgst = lv_result_gst.
          ENDIF.
        ENDIF.

        CLEAR lv_index.
        CLEAR lv_result_gst.
        lv_index = -1.

        FIND to_upper( 'IGST' ) IN lv_string MATCH OFFSET lv_index.
        IF lv_index <> -1.
          lv_index = lv_index + 5.
          j = lv_index.
          WHILE j < strlen( lv_string ) AND ( lv_string+j(1) ) <> '%'.
            j = j + 1.
          ENDWHILE.
          IF j = strlen( lv_string ).
            lv_result_igst = 0.
          ELSE.
            j = j - lv_index.
            lv_result_gst = lv_string+lv_index(j).
*          lv_result_gst = lv_string+lv_index(2).
            REPLACE '%' IN lv_result_gst WITH ' '.
            CONDENSE lv_result_gst NO-GAPS.
            lv_result_igst = lv_result_gst.
          ENDIF.
        ENDIF.

      ENDIF.
      lv_index = -1.
      CLEAR lv_result_gst.
      CLEAR lv_string.

*      IF wa_item-PurchasingDocumentDeletionCode = 'L'.
*        lv_result_sgst = '0'.
*        lv_result_cgst = '0'.
*        lv_result_igst = '0'.
*        lv_material_value = '0'.
*      ENDIF.


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



      IF wa_item-PurchasingDocumentDeletionCode = 'L'.
        indicator_count = indicator_count + 1.
      ENDIF.

      SELECT
      FROM i_purchaseordschedulelinetp_2 AS a
      FIELDS
       a~PurchaseOrder,
       a~ScheduleLineDeliveryDate
      WHERE a~PurchaseOrder = @lv_po2 AND a~PurchaseOrderItem = @wa_item-PurchaseOrderItem
      INTO TABLE @DATA(lt_deliverydate) PRIVILEGED ACCESS.

      DATA(lt_deliverydate_len) = lines( lt_deliverydate ).

      READ TABLE lt_deliverydate INTO DATA(wa_deliverydate) INDEX 1.


      SELECT FROM
      i_purordpricingelementtp_2 AS a
      FIELDS
      a~PurchaseOrder,
      a~PurchaseOrderItem,
      a~ConditionAmount,
      a~ConditionType,
      a~ConditionBaseValue,
      a~ConditionRateAmount
      WHERE a~PurchaseOrder = @lv_po2 AND a~PurchaseOrderItem = @wa_item-PurchaseOrderItem
      INTO TABLE @DATA(lt_price).

      READ TABLE lt_price INTO DATA(wa_fr1) WITH KEY ConditionType = 'ZFR1'.
      READ TABLE lt_price INTO DATA(wa_fr2) WITH KEY ConditionType = 'ZFR2'.
      READ TABLE lt_price INTO DATA(wa_fr3) WITH KEY ConditionType = 'ZFR3'.

      DATA : lv_fright TYPE p DECIMALS 2.
      IF wa_fr1 IS NOT INITIAL.
        lv_fright  += wa_fr1-ConditionAmount.
      ENDIF.
      IF wa_fr2 IS NOT INITIAL.
        lv_fright  += wa_fr2-ConditionAmount.
      ENDIF.
      IF wa_fr3 IS NOT INITIAL.
        lv_fright  += wa_fr3-ConditionAmount.
      ENDIF.
*
      READ TABLE lt_price INTO DATA(wa_ot1) WITH KEY ConditionType = 'ZOT1'.
      READ TABLE lt_price INTO DATA(wa_ot2) WITH KEY ConditionType = 'ZOT2'.

      DATA : lv_other TYPE p DECIMALS 2.

      IF wa_ot2 IS NOT INITIAL.
        lv_other  += wa_ot2-ConditionAmount.
      ENDIF.
      IF wa_ot1 IS NOT INITIAL.
        lv_other  += wa_ot1-ConditionAmount.
      ENDIF.

      DATA: lv_ins TYPE p DECIMALS 2.
      READ TABLE lt_price INTO DATA(wa_in2) WITH KEY ConditionType = 'ZIN2'.
      READ TABLE lt_price INTO DATA(wa_in1) WITH KEY ConditionType = 'ZIN1'.
      IF wa_in2 IS NOT INITIAL.
        lv_ins += wa_in2-ConditionAmount.
      ENDIF.
      IF wa_in1 IS NOT INITIAL.
        lv_ins += wa_in1-ConditionAmount.
      ENDIF.

*      IF wa_item-PurchasingDocumentDeletionCode = 'L'.
*        lv_fright = '0'.
*        lv_ins = '0'.
*        lv_other = '0'.
*        wa_item-OrderQuantity = '0'.
*        wa_item-NetPriceAmount = '0'.
*        wa_item-NetPriceAmount = '0'.
*        wa_item-YY1_QuantityPerPack_PDI = '0'.
*      ENDIF.

      IF lv_result_cgst IS NOT INITIAL.
        total_val_tax = total_val_tax + ( ( lv_material_value + lv_fright + lv_ins + lv_other ) * lv_result_cgst / 100 ).
        total_val_tax = total_val_tax + ( ( lv_material_value + lv_fright + lv_ins + lv_other ) * lv_result_sgst / 100 ).
      ENDIF.

      IF lv_result_igst IS NOT INITIAL.
        total_val_tax = total_val_tax + ( ( lv_material_value + lv_fright + lv_ins + lv_other ) * lv_result_igst / 100 ).
      ENDIF.

      total_frt_chrg += lv_fright.
      total_ins_chrg += lv_ins.
      total_other_chrg += lv_other.


      SELECT SINGLE
      FROM i_purchaseorderitemnotetp_2 AS a
      FIELDS
      a~PlainLongText
      WHERE a~PurchaseOrder = @lv_po2 AND a~PurchaseOrderItem = @wa_item-PurchaseOrderItem
      AND a~TextObjectType = 'F01'
      INTO @DATA(lv_remarks).

      IF wa_item-BaseUnit = 'LE'.
        wa_item-BaseUnit = 'AU'.
      ENDIF.

      SELECT SINGLE FROM
      I_UnitOfMeasure AS a
      FIELDS
      a~UnitOfMeasure_E
      WHERE
      a~UnitOfMeasure = @wa_item-orderpriceunit
      INTO @DATA(wa_unit).

      IF wa_item-AccountAssignmentCategory = 'A'.
        wa_item-ProductName = wa_item-PurchaseOrderItemText.
      ENDIF.

      IF lv_result_sgst = '0' AND lv_result_igst = '0'.
        tax0 += lv_material_value + lv_other + lv_fright.
        sgst0 += ( ( lv_material_value + lv_other + lv_fright ) * lv_result_sgst ) / 100.
        igst0 += ( ( lv_material_value + lv_other + lv_fright ) * lv_result_igst ) / 100.
      ENDIF.
      IF lv_result_sgst = '1.5' OR  lv_result_igst = '3'.
        tax15 += lv_material_value + lv_other + lv_fright.
        sgst15 += ( ( lv_material_value + lv_other + lv_fright ) * lv_result_sgst ) / 100.
        igst3 += ( ( lv_material_value + lv_other + lv_fright ) * lv_result_igst ) / 100.
      ENDIF.
      IF lv_result_sgst = '2.5' OR  lv_result_igst = '5'.
        tax25 += lv_material_value + lv_other + lv_fright.
        sgst25 += ( ( lv_material_value + lv_other + lv_fright ) * lv_result_sgst ) / 100.
        igst5 += ( ( lv_material_value + lv_other + lv_fright ) * lv_result_igst ) / 100.
      ENDIF.
      IF lv_result_sgst = '6' OR  lv_result_igst = '12'.
        tax6 += lv_material_value + lv_other + lv_fright.
        sgst6 += ( ( lv_material_value + lv_other + lv_fright ) * lv_result_sgst ) / 100.
        igst12 += ( ( lv_material_value + lv_other + lv_fright ) * lv_result_igst ) / 100.
      ENDIF.
      IF lv_result_sgst = '9' OR  lv_result_igst = '18'.
        tax9 += lv_material_value + lv_other + lv_fright.
        sgst9 += ( ( lv_material_value + lv_other + lv_fright ) * lv_result_sgst ) / 100.
        igst18 += ( ( lv_material_value + lv_other + lv_fright ) * lv_result_igst ) / 100.
      ENDIF.
      IF lv_result_sgst = '14' OR  lv_result_igst = '28'.
        tax14 += lv_material_value + lv_other + lv_fright.
        sgst14 += ( ( lv_material_value + lv_other + lv_fright ) * lv_result_sgst ) / 100.
        igst28 += ( ( lv_material_value + lv_other + lv_fright ) * lv_result_igst ) / 100.
      ENDIF.
      DATA(lv_xml_line) =
      |<PurchaseOrderItem>| &&
      |<sr>{ sr }</sr>| &&
      |<des_of_goods>{ wa_item-ProductName }</des_of_goods>| &&
      |<order_qty>{ wa_item-OrderQuantity }</order_qty>| &&
      |<uom>{ wa_unit }</uom>| &&
      |<rate>{ wa_item-NetPriceAmount }</rate>| &&
      |<taxable_amount>{ lv_material_value }</taxable_amount>| &&
      |<sgst>{ lv_result_sgst }</sgst>| &&
      |<igst>{ lv_result_igst }</igst>| &&
      |<cgst>{ lv_result_cgst }</cgst>| &&
      |<total_value>{ lv_total_value }</total_value>| &&
      |<remarks>{ lv_remarks }</remarks>|.

      sr = sr + 1.
      CONCATENATE main_xml lv_xml_line INTO main_xml.
      DATA : lv_delivery_date TYPE string.

      IF lt_deliverydate_len < 2.
        lv_delivery_date = wa_deliverydate-ScheduleLineDeliveryDate.
      ELSE.
        lv_delivery_date = 'As Per Annexure'.
      ENDIF.

      DATA(lv_xml_line2) =
      |<dispatch_date>{ lv_delivery_date }</dispatch_date>| &&
      |</PurchaseOrderItem>|
      .

      CONCATENATE main_xml lv_xml_line2 INTO main_xml.
      CLEAR wa_item.
      CLEAR lv_fright.
      CLEAR lv_ins.
      CLEAR lv_other.
      CLEAR wa_unit.

    ENDLOOP.

    SELECT SINGLE FROM
    i_purchaseorderapi01 AS a
    FIELDS
    a~YY1_Remarks_PDH,
    a~YY1_ItemText_PDH,
    a~YY1_DeliveryText_PDH
    WHERE a~PurchaseOrder = @lv_po2
    INTO @DATA(wa_yy1).

    IF wa_status-PurchasingProcessingStatus <> '05'.
      wa_status-PurchasingProcessingStatusName = 'Draft'.
    ENDIF.
    IF wa_status-PurchasingProcessingStatusName = 'Release completed'.
      wa_status-PurchasingProcessingStatusName = 'Approved'.
    ENDIF.
    IF indicator_count = sr.
      wa_status-PurchasingProcessingStatusName = 'cancelled'.
    ENDIF.
    IF indicator_count = 1 AND sr <> 1.
      wa_status-PurchasingProcessingStatusName = 'Partially Cancelled'.
    ENDIF.

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


    select single from
    i_purchaseorderitemapi01 as a
    left join ztable_plant as b on a~Plant = b~plant_code
    FIELDS
    b~gstin_no
    where a~PurchaseOrder = @lv_po2
    into @data(lv_gstin).

    select single from
    i_purchaseorderapi01 as a
    FIELDS
    a~YY1_AmendmentNo_po_hd_PDH
    where a~PurchaseOrder = @lv_po2
    into @data(lv_reasonamend).

    DATA(lv_footer) =
    |</Items>| &&
    |<chart>| &&
    |<rows0>| &&
    |<tax0>{ tax0 }</tax0>| &&
    |<sgst0>{ sgst0 }</sgst0>| &&
    |<cgst0>{ sgst0 }</cgst0>| &&
    |<igst0>{ igst0 }</igst0>| &&
    |</rows0>| &&
    |<rows15>| &&
    |<tax15>{ tax15 }</tax15>| &&
    |<sgst15>{ sgst15 }</sgst15>| &&
    |<cgst15>{ sgst15 }</cgst15>| &&
    |<igst3>{ igst3 }</igst3>| &&
    |</rows15>| &&
    |<rows25>| &&
    |<tax25>{ tax25 }</tax25>| &&
    |<sgst25>{ sgst15 }</sgst25>| &&
    |<cgst25>{ sgst25 }</cgst25>| &&
    |<igst5>{ igst5 }</igst5>| &&
    |</rows25>| &&
    |<rows6>| &&
    |<tax6>{ tax6 }</tax6>| &&
    |<sgst6>{ sgst6 }</sgst6>| &&
    |<cgst6>{ sgst6 }</cgst6>| &&
    |<igst12>{ igst12 }</igst12>| &&
    |</rows6>| &&
    |<rows9>| &&
    |<tax9>{ tax9 }</tax9>| &&
    |<sgst9>{ sgst9 }</sgst9>| &&
    |<cgst9>{ sgst9 }</cgst9>| &&
    |<igst18>{ igst18 }</igst18>| &&
    |</rows9>| &&
    |<rows14>| &&
     |<tax14>{ tax14 }</tax14>| &&
    |<sgst14>{ sgst14 }</sgst14>| &&
    |<cgst14>{ sgst14 }</cgst14>| &&
    |<igst28>{ igst28 }</igst28>| &&
    |</rows14>| &&
    |</chart>| &&
    |<footer>| &&
     |<frieght>{ total_frt_chrg }</frieght>| &&
     |<othcharges>{ total_other_chrg }</othcharges>| &&
     |<deladd>{ lv_plant_add }</deladd>| &&
     |<uan_no>{ wa-certificateno }</uan_no>| &&
    | <TypeofEnterprises>{ wa-vendortype }</TypeofEnterprises> | &&
    |<UanCertificateDate>{ wa-validfrom }</UanCertificateDate> | &&
    |<purchasingstatus>{ wa_status-PurchasingProcessingStatusName }</purchasingstatus>| &&
    |<total_val_with_tax>{ total_val_with_tax }</total_val_with_tax>| &&
    |<total_val_tax>{ total_val_tax }</total_val_tax>| &&
    |<total_other_chrg>{ total_other_chrg }</total_other_chrg>| &&
    |<itemtext>{ wa_yy1-YY1_ItemText_PDH }</itemtext>| &&
    |<modeofdispatch>{ wa_yy1-YY1_DeliveryText_PDH }</modeofdispatch>| &&
    |<remarks>{ wa_yy1-YY1_Remarks_PDH }</remarks>| &&
    |<gstin>{ lv_gstin }</gstin>| &&
    |<amendreason>{ lv_reasonamend }</amendreason>| &&
    |</footer>|.

    CONCATENATE main_xml lv_footer INTO main_xml.

    DATA(lv_xml_last) =
    |</PurchaseOrderNode>| &&
    |</FORM>|.

    CONCATENATE main_xml lv_xml_last INTO main_xml.


    REPLACE ALL OCCURRENCES OF '&' IN main_xml WITH 'and'.
    REPLACE ALL OCCURRENCES OF '<=' IN main_xml WITH 'let'.
    REPLACE ALL OCCURRENCES OF '>=' IN main_xml WITH 'get'.

    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = main_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).


  ENDMETHOD.
ENDCLASS.
