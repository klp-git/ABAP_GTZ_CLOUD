CLASS zcl_po_dom_drv DEFINITION
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
    CONSTANTS lc_template_name TYPE string VALUE 'zmm_po_dom/zmm_po_dom'."'zpo/zpo_v2'."

ENDCLASS.



CLASS ZCL_PO_DOM_DRV IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).
  ENDMETHOD .


  METHOD if_oo_adt_classrun~main.
  ENDMETHOD.


  METHOD read_posts.
*    DATA : lv_po2 TYPE string.
*    lv_po2 =  '500000113'.
    SELECT SINGLE
        a~PurchaseOrder,
        a~supplier,
        a~PurchaseOrderdate,
        a~yy1_quotation_date_po_pdh,
        a~yy1_quotation_no_pdh,
        a~YY1_itemtext_pdh,
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
        a~PurchasingProcessingStatus,
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
      INTO  @DATA(wa) PRIVILEGED ACCESS.

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

    SELECT SINGLE FROM i_purchaseorderapi01 AS a
    LEFT JOIN i_supplier AS b ON a~Supplier = b~Supplier
    LEFT JOIN i_address_2 AS c ON b~AddressID = c~AddressID
    LEFT JOIN i_regiontext AS d ON c~Region = d~Region AND c~Country = d~Country
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
    b~BPSupplierName,
    d~RegionName
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
    d~DistrictName,
    c~TaxNumber3
    WHERE a~PurchaseOrder = @lv_po2 AND b~PartnerFunction = 'FS'
    INTO @DATA(lv_transporter) PRIVILEGED ACCESS.


    DATA: lv_supp_add TYPE string.
    lv_supp_add = lv_address-HouseNumber.

    IF lv_address-StreetName IS NOT INITIAL.
      IF lv_supp_add IS NOT INITIAL.
        CONCATENATE lv_supp_add ', ' lv_address-StreetName INTO lv_supp_add SEPARATED BY space.
      ELSE.
        lv_supp_add = lv_address-StreetName.
      ENDIF.
    ENDIF.

    IF lv_address-StreetPrefixName1 IS NOT INITIAL.
      IF lv_supp_add IS NOT INITIAL.
        CONCATENATE lv_supp_add ', ' lv_address-StreetPrefixName1 INTO lv_supp_add SEPARATED BY space.
      ELSE.
        lv_supp_add = lv_address-StreetPrefixName1.
      ENDIF.
    ENDIF.

    IF lv_address-StreetPrefixName2 IS NOT INITIAL.
      IF lv_supp_add IS NOT INITIAL.
        CONCATENATE lv_supp_add ', ' lv_address-StreetPrefixName2 INTO lv_supp_add SEPARATED BY space.
      ELSE.
        lv_supp_add = lv_address-StreetPrefixName2.
      ENDIF.
    ENDIF.

    IF lv_address-CityName IS NOT INITIAL.
      IF lv_supp_add IS NOT INITIAL.
        CONCATENATE lv_supp_add ', ' lv_address-CityName INTO lv_supp_add SEPARATED BY space.
      ELSE.
        lv_supp_add = lv_address-CityName.
      ENDIF.
    ENDIF.

    IF lv_address-PostalCode IS NOT INITIAL.
      IF lv_supp_add IS NOT INITIAL.
        CONCATENATE lv_supp_add ', ' lv_address-PostalCode INTO lv_supp_add SEPARATED BY space.
      ELSE.
        lv_supp_add = lv_address-PostalCode.
      ENDIF.
    ENDIF.

    IF lv_address-DistrictName IS NOT INITIAL.
      IF lv_supp_add IS NOT INITIAL.
        CONCATENATE lv_supp_add ', ' lv_address-DistrictName INTO lv_supp_add SEPARATED BY space.
      ELSE.
        lv_supp_add = lv_address-DistrictName.
      ENDIF.
    ENDIF.

    IF lv_address-RegionName IS NOT INITIAL.
      IF lv_supp_add IS NOT INITIAL.
        CONCATENATE lv_supp_add ', ' lv_address-RegionName INTO lv_supp_add SEPARATED BY space.
      ELSE.
        lv_supp_add = lv_address-RegionName.
      ENDIF.
    ENDIF.

    IF lv_address-country IS NOT INITIAL.
      IF lv_supp_add IS NOT INITIAL.
        CONCATENATE lv_supp_add ', ' 'India' INTO lv_supp_add SEPARATED BY space.
      ELSE.
        lv_supp_add = 'India'.
      ENDIF.
    ENDIF.


*    CONCATENATE lv_supp_add ' , ' lv_address-StreetName ' , ' lv_address-StreetPrefixName1 ' , '
*    lv_address-StreetPrefixName2 ' , ' lv_address-CityName ' , ' lv_address-PostalCode ' , ' lv_address-DistrictName ' , ' lv_address-RegionName ' , '
*    'India' INTO lv_supp_add.


    IF lv_supp_add IS NOT INITIAL.
      SHIFT lv_supp_add LEFT DELETING LEADING ','.
    ENDIF.
    REPLACE ALL OCCURRENCES OF ',,' IN lv_supp_add WITH ','.

    SELECT SINGLE FROM i_purchaseorderapi01 AS a
    LEFT JOIN I_IncotermsClassificationText AS b ON a~YY1_IncoTerms2_PDH = b~IncotermsClassification
    FIELDS
    a~YY1_IncoTerms2Remarks_PDH,
    b~IncotermsClassificationName
    WHERE a~PurchaseOrder = @lv_po2
    INTO @DATA(wa_insurance) PRIVILEGED ACCESS.

    SELECT SINGLE FROM i_purchaseorderapi01 AS a
    LEFT JOIN I_IncotermsClassificationText AS b ON a~IncotermsClassification = b~IncotermsClassification
    FIELDS
    a~IncotermsLocation1,
    a~YY1_DeliveryText_PDH,
    b~IncotermsClassificationName
    WHERE a~PurchaseOrder = @lv_po2
    INTO @DATA(wa_delivery) PRIVILEGED ACCESS.


    DATA: lv_insurance TYPE string.
    lv_insurance = wa_insurance-IncotermsClassificationName.

    IF wa_insurance-YY1_IncoTerms2Remarks_PDH IS NOT INITIAL.
      IF lv_insurance IS NOT INITIAL.
        CONCATENATE lv_insurance '-' wa_insurance-YY1_IncoTerms2Remarks_PDH INTO lv_insurance.
      ELSE.
        lv_insurance = wa_insurance-YY1_IncoTerms2Remarks_PDH.
      ENDIF.
    ENDIF.
    REPLACE ALL OCCURRENCES OF ',,' IN lv_insurance WITH ','.
*    CONDENSE lv_insurance.
    SHIFT lv_insurance RIGHT DELETING TRAILING space.
*    CONCATENATE lv_insurance '-' wa_insurance-YY1_IncoTerms2Remarks_PDH INTO lv_insurance.

    DATA: lv_delivery TYPE string.
    lv_delivery = wa_delivery-IncotermsClassificationName.

    IF wa_delivery-IncotermsLocation1 IS NOT INITIAL.
      IF lv_delivery IS NOT INITIAL.
        CONCATENATE lv_delivery '-' wa_delivery-IncotermsLocation1 INTO lv_delivery.
      ELSE.
        lv_delivery = wa_delivery-IncotermsLocation1.
      ENDIF.
    ENDIF.

    IF wa_delivery-YY1_DeliveryText_PDH IS NOT INITIAL.
      IF lv_delivery IS NOT INITIAL.
        CONCATENATE lv_delivery '-' wa_delivery-YY1_DeliveryText_PDH INTO lv_delivery.
      ELSE.
        lv_delivery = wa_delivery-YY1_DeliveryText_PDH.
      ENDIF.
    ENDIF.

    REPLACE ALL OCCURRENCES OF ',,' IN lv_delivery WITH ','.
    IF lv_delivery IS NOT INITIAL.

      DATA(lv_length) = strlen( lv_delivery ) - 1.
      DATA(lv_last) = lv_delivery+lv_length(1).
      IF lv_last CP '[A-Za-z0-9]'.
        lv_delivery = lv_delivery.
      ELSE.
        lv_delivery = lv_delivery+0(lv_length).
      ENDIF.

    ENDIF.

*    CONCATENATE lv_delivery '-' wa_delivery-IncotermsLocation1 ' , ' wa_delivery-YY1_DeliveryText_PDH INTO lv_delivery.

    SELECT SINGLE FROM
    i_purchaseorderapi01 AS a
    FIELDS
    a~YY1_Remarks_PDH
    WHERE a~PurchaseOrder = @lv_po2
    INTO @DATA(lv_paymentTerms).

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


*    DATA: lv_space TYPE string VALUE ','.
*
*    CONCATENATE lv_plant_add lv_space wa_plant_add-address2 lv_space
*    lv_space wa_plant_add-district lv_space wa_plant_add-state_name lv_space wa_plant_add-pin lv_space wa_plant_add-country
*    INTO lv_plant_add.


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
    DATA: flag TYPE i VALUE 1.
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
     INTO @DATA(lv_string1) .
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


    DATA: lv_transportfull TYPE string.
    lv_transportfull = lv_transporter-StreetName.

    DATA: lv_comma TYPE string VALUE ', '.

    IF lv_transporter-StreetPrefixName1 IS NOT INITIAL.
      IF lv_transportfull IS NOT INITIAL.
        CONCATENATE lv_transportfull lv_comma lv_transporter-StreetPrefixName1 INTO lv_transportfull.
      ELSE.
        lv_transportfull = lv_transporter-StreetPrefixName1.
      ENDIF.
    ENDIF.

    IF lv_transporter-StreetPrefixName2 IS NOT INITIAL.
      IF lv_transportfull IS NOT INITIAL.
        CONCATENATE lv_transportfull lv_comma lv_transporter-StreetPrefixName2 INTO lv_transportfull.
      ELSE.
        lv_transportfull = lv_transporter-StreetPrefixName2.
      ENDIF.
    ENDIF.

    IF lv_transporter-CityName IS NOT INITIAL.
      IF lv_transportfull IS NOT INITIAL.
        CONCATENATE lv_transportfull lv_comma lv_transporter-CityName INTO lv_transportfull.
      ELSE.
        lv_transportfull = lv_transporter-CityName.
      ENDIF.
    ENDIF.

    IF lv_transporter-PostalCode IS NOT INITIAL.
      IF lv_transportfull IS NOT INITIAL.
        CONCATENATE lv_transportfull lv_comma lv_transporter-PostalCode INTO lv_transportfull.
      ELSE.
        lv_transportfull = lv_transporter-PostalCode.
      ENDIF.
    ENDIF.

    IF lv_transporter-DistrictName IS NOT INITIAL.
      IF lv_transportfull IS NOT INITIAL.
        CONCATENATE lv_transportfull lv_comma lv_transporter-DistrictName INTO lv_transportfull.
      ELSE.
        lv_transportfull = lv_transporter-DistrictName.
      ENDIF.
    ENDIF.


*    REPLACE ALL OCCURRENCES OF ',,' IN lv_transportfull WITH ','.

    IF wa-PurchasingProcessingStatus <> '05'.
      CLEAR lv_amend.
      CLEAR wa_ChangeDate.
    ENDIF.

*    DATA(lv_gstin_add_trans) = lv_transporter-OrganizationName1 && ' - ' && lv_transporter-TaxNumber3.
    DATA: lv_gstin_add_trans TYPE string.
    lv_gstin_add_trans = lv_transporter-OrganizationName1.

    IF lv_transporter-TaxNumber3 IS NOT INITIAL.
      IF lv_gstin_add_trans IS NOT INITIAL.
        CONCATENATE lv_gstin_add_trans ' - ' lv_transporter-TaxNumber3 INTO lv_gstin_add_trans.
      ELSE.
        lv_gstin_add_trans = lv_transporter-TaxNumber3.
      ENDIF.
    ENDIF.

    IF str4 IS INITIAL.
      CLEAR wa_ChangeDate.
    ENDIF.

    DATA(main_xml) =
        |<FORM>| &&
        |<PurchaseOrderNode>| &&
        |<HEADER>| &&
        |<COMPANYNAME>{ wa-companycodename }</COMPANYNAME>| &&
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
        |<party_name>{ lv_address-BpSupplierName }</party_name>| &&       " done
        |<supplier_address>{ lv_supp_add }</supplier_address>| &&       " done
        |<transporter>{ lv_gstin_add_trans }</transporter>| &&       " done
        |<transportadd>{ lv_transportfull }</transportadd>| &&       " done
        |<insurance>{ lv_insurance }</insurance>| &&       " done
        |<delivery>{ lv_delivery }</delivery>| &&       " done
        |<paymentTerms>{ lv_paymentterms }</paymentTerms>| &&       " done
        |<deliveryAdd>{ lv_plant_add }</deliveryAdd>| &&
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
       a~purchasingdocumentdeletioncode
     FROM I_PurchaseOrderItemAPI01 AS a
     LEFT JOIN i_producttext AS b ON b~Product = a~Material
     WHERE a~PurchaseOrder = @lv_po2
     INTO TABLE @DATA(it) PRIVILEGED ACCESS.

    SORT it BY PurchaseOrderItem ASCENDING.

    DATA : total_val_with_tax TYPE p DECIMALS 2.
    DATA : total_val_tax TYPE p DECIMALS 2.
    DATA : total_other_chrg TYPE p DECIMALS 2.
    DATA : total_fright_chrg TYPE p DECIMALS 2.
    DATA : total_ins_chrg TYPE p DECIMALS 2.
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
    sr = 1.
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

        CLEAR lv_index.
        CLEAR lv_result_gst.
        lv_index = -1.
      ENDIF.
      lv_index = -1.
      CLEAR lv_result_gst.
      CLEAR lv_string.

      IF wa_item-PurchasingDocumentDeletionCode = 'L'.
        indicator_count = indicator_count + 1.
        lv_result_sgst = '0'.
        lv_result_cgst = '0'.
        lv_result_igst = '0'.
        lv_material_value = '0'.
      ENDIF.


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

      SELECT SINGLE FROM
      i_purchaseorderapi01 AS a
      FIELDS
      a~Supplier
      WHERE a~PurchaseOrder = @lv_po2 AND a~Supplier IS NOT INITIAL
      INTO @DATA(lv_api01) PRIVILEGED ACCESS.

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
      READ TABLE lt_price INTO DATA(wa_fr3) WITH KEY ConditionType = 'ZFR3'.
      READ TABLE lt_price INTO DATA(wa_fr1) WITH KEY ConditionType = 'ZFR1'.
      DATA : lv_fright TYPE p DECIMALS 2.

      IF wa_fr2 IS NOT INITIAL.
        IF wa_fr2-FreightSupplier <> lv_api01.
          lv_fright += '0'.
        ELSE.
          lv_fright  += wa_fr2-ConditionAmount.
        ENDIF.
      ENDIF.
      IF wa_fr3 IS NOT INITIAL.
        IF wa_fr3-FreightSupplier <> lv_api01.
          lv_fright += '0'.
        ELSE.
          lv_fright  += wa_fr3-ConditionAmount.
        ENDIF.
      ENDIF.
      IF wa_fr1 IS NOT INITIAL.
        IF wa_fr1-FreightSupplier <> lv_api01.
          lv_fright += '0'.
        ELSE.
          lv_fright  += wa_fr1-ConditionAmount..
        ENDIF.
      ENDIF.

      CLEAR wa_fr2.
      CLEAR wa_fr3.
      CLEAR wa_fr1.

      READ TABLE lt_price INTO DATA(wa_ot1) WITH KEY ConditionType = 'ZOT1'.
      READ TABLE lt_price INTO DATA(wa_ot2) WITH KEY ConditionType = 'ZOT2'.

      DATA : lv_other TYPE p DECIMALS 2.

      IF wa_ot2 IS NOT INITIAL.
        lv_other  += wa_ot2-ConditionAmount.
      ENDIF.
      IF wa_ot1 IS NOT INITIAL.
        lv_other  += wa_ot1-ConditionAmount.
      ENDIF.
      CLEAR wa_ot1.
      CLEAR wa_ot2.

      DATA: lv_ins TYPE p DECIMALS 2.
      READ TABLE lt_price INTO DATA(wa_in2) WITH KEY ConditionType = 'ZIN2'.
      READ TABLE lt_price INTO DATA(wa_in1) WITH KEY ConditionType = 'ZIN1'.
      IF wa_in2 IS NOT INITIAL.
        lv_ins += wa_in2-ConditionAmount.
      ENDIF.
      IF wa_in1 IS NOT INITIAL.
        lv_ins += wa_in1-ConditionAmount.
      ENDIF.
      CLEAR wa_in2.
      CLEAR wa_in1.

      IF wa_item-PurchasingDocumentDeletionCode = 'L'.
        lv_fright = '0'.
        lv_ins = '0'.
        lv_other = '0'.
        wa_item-OrderQuantity = '0'.
        wa_item-NetPriceAmount = '0'.
        wa_item-NetPriceAmount = '0'.
        wa_item-YY1_QuantityPerPack_PDI = '0'.
      ENDIF.
      IF lv_result_cgst IS NOT INITIAL.
        total_val_tax = total_val_tax + ( ( lv_material_value + lv_fright + lv_ins + lv_other ) * lv_result_cgst / 100 ).
        total_val_tax = total_val_tax + ( ( lv_material_value + lv_fright + lv_ins + lv_other ) * lv_result_sgst / 100 ).
      ENDIF.

      IF lv_result_igst IS NOT INITIAL.
        total_val_tax = total_val_tax + ( ( lv_material_value + lv_fright + lv_ins + lv_other ) * lv_result_igst / 100 ).
      ENDIF.

      total_other_chrg +=  lv_other.
      total_fright_chrg += lv_fright.
      total_ins_chrg += lv_ins.

      IF wa_item-BaseUnit = 'LE'.
        wa_item-BaseUnit = 'AU'.
      ENDIF.

      SELECT SINGLE FROM
      I_UnitOfMeasure AS a
      FIELDS
      a~UnitOfMeasure_E
      WHERE
      a~UnitOfMeasure = @wa_item-BaseUnit
      INTO @DATA(wa_unit) PRIVILEGED ACCESS.

      SHIFT wa_item-Product LEFT DELETING LEADING '0'.

      SELECT SINGLE
      FROM zmaterial_table AS a
      FIELDS
      a~trade_name
      WHERE a~mat = @wa_item-Product
      INTO @DATA(lv_des_of_goods) PRIVILEGED ACCESS.

      IF lv_result_sgst = '0' AND lv_result_igst = '0'.
        tax0 += lv_material_value + lv_fright + lv_ins + lv_other.
        sgst0 += ( ( lv_material_value + lv_fright + lv_ins + lv_other ) * lv_result_sgst ) / 100.
        igst0 += ( ( lv_material_value + lv_fright + lv_ins + lv_other ) * lv_result_igst ) / 100.
      ENDIF.
      IF lv_result_sgst = '1.5' OR  lv_result_igst = '3'.
        tax15 += lv_material_value + lv_fright + lv_ins + lv_other..
        sgst15 += ( ( lv_material_value + lv_fright + lv_ins + lv_other ) * lv_result_sgst ) / 100.
        igst3 += ( ( lv_material_value + lv_fright + lv_ins + lv_other ) * lv_result_igst ) / 100.
      ENDIF.
      IF lv_result_sgst = '2.5' OR  lv_result_igst = '5'.
        tax25 += lv_material_value + lv_fright + lv_ins + lv_other..
        sgst25 += ( ( lv_material_value + lv_fright + lv_ins + lv_other ) * lv_result_sgst ) / 100.
        igst5 += ( ( lv_material_value + lv_fright + lv_ins + lv_other ) * lv_result_igst ) / 100.
      ENDIF.
      IF lv_result_sgst = '6' OR  lv_result_igst = '12'.
        tax6 += lv_material_value + lv_fright + lv_ins + lv_other..
        sgst6 += ( ( lv_material_value + lv_fright + lv_ins + lv_other ) * lv_result_sgst ) / 100.
        igst12 += ( ( lv_material_value + lv_fright + lv_ins + lv_other ) * lv_result_igst ) / 100.
      ENDIF.
      IF lv_result_sgst = '9' OR  lv_result_igst = '18'.
        tax9 += lv_material_value + lv_fright + lv_ins + lv_other..
        sgst9 += ( ( lv_material_value + lv_fright + lv_ins + lv_other ) * lv_result_sgst ) / 100.
        igst18 += ( ( lv_material_value + lv_fright + lv_ins + lv_other ) * lv_result_igst ) / 100.
      ENDIF.
      IF lv_result_sgst = '14' OR  lv_result_igst = '28'.
        tax14 += lv_material_value + lv_fright + lv_ins + lv_other..
        sgst14 += ( ( lv_material_value + lv_fright + lv_ins + lv_other ) * lv_result_sgst ) / 100.
        igst28 += ( ( lv_material_value + lv_fright + lv_ins + lv_other ) * lv_result_igst ) / 100.
      ENDIF.



      DATA(lv_xml_line) =
      |<PurchaseOrderItem>| &&
      |<sr>{ sr }</sr>| &&
      |<des_of_goods>{ lv_des_of_goods }</des_of_goods>| &&
      |<supplier_special>{ wa_purchaseapi-YY1_VendorSpecialName_SOS }</supplier_special>| &&
      |<order_qty>{ wa_item-OrderQuantity }</order_qty>| &&
      |<uom>{ wa_unit }</uom>| &&
      |<currency>{ wa_item-DocumentCurrency }</currency>| &&
      |<rate>{ wa_item-NetPriceAmount }</rate>| &&
      |<qty_per_pack>{ wa_item-YY1_QuantityPerPack_PDI }</qty_per_pack>| &&
      |<packing_mode>{ wa_item-YY1_PackingMode_PDI }</packing_mode>| &&
      |<material_value>{ lv_material_value }</material_value>| &&
      |<sgst>{ lv_result_sgst }</sgst>| &&
      |<igst>{ lv_result_igst }</igst>| &&
      |<cgst>{ lv_result_cgst }</cgst>| &&
      |<total_value>{ lv_total_value }</total_value>|.

      sr = sr + 1.
      CLEAR lv_des_of_goods.

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
      CLEAR lv_delivery_date.
      CLEAR lv_fright.
      CLEAR lv_ins.
      CLEAR lv_other.
      CLEAR lv_total_value.
      CLEAR lv_material_value.
      CLEAR lv_result_sgst.
      CLEAR lv_result_cgst.
      CLEAR lv_result_igst.
      CLEAR lv_string.
      CLEAR lt_price.
      CLEAR lt_deliverydate.
      CLEAR wa_deliverydate.
      CLEAR wa_gst.
      CLEAR wa_purchaseapi.
      CLEAR wa_unit.


    ENDLOOP.
    sr = sr - 1.

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
    |<uan_no>{ wa-certificateno }</uan_no>| &&
    | <TypeofEnterprises>{ wa-vendortype }</TypeofEnterprises> | &&
    |<UanCertificateDate>{ wa-validfrom }</UanCertificateDate> | &&
    |<purchasingstatus>{ wa_status-PurchasingProcessingStatusName }</purchasingstatus>| &&
    |<total_val_with_tax>{ total_val_with_tax }</total_val_with_tax>| &&
    |<total_val_tax>{ total_val_tax }</total_val_tax>| &&
    |<YY1_REMARKS_PDH>{ wa-YY1_ItemText_PDH }</YY1_REMARKS_PDH>| &&
    |<total_other_chrg>{ total_other_chrg }</total_other_chrg>| &&
    |<total_freight_chrg>{ total_fright_chrg }</total_freight_chrg>| &&
    |<total_insu_chrg>{ total_ins_chrg }</total_insu_chrg>| &&
    |</footer>| &&
    |<annexure>|.

    CONCATENATE main_xml lv_footer INTO main_xml.


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
       c~trade_name
     FROM I_PurchaseOrderItemAPI01 AS a
     LEFT JOIN i_producttext AS b ON b~Product = a~Material
     LEFT JOIN zmaterial_table AS c ON a~Material = c~mat
     WHERE a~PurchaseOrder = @lv_po2
     INTO TABLE @DATA(it2) PRIVILEGED ACCESS.

    sr = 1.

    LOOP AT it2 INTO DATA(wa2).
      SELECT SINGLE
        FROM i_purchasinginforecordapi01 AS a
        FIELDS
         a~PurchasingInfoRecord,
         a~YY1_VendorSpecialName_SOS
        WHERE a~Material = @wa2-Product AND a~Supplier = @wa1-Supplier
        INTO @DATA(wa_purchaseapi2) PRIVILEGED ACCESS.

      SHIFT wa2-Product LEFT DELETING LEADING '0'.

      SELECT SINGLE
       FROM zmaterial_table AS a
       FIELDS
       a~trade_name
       WHERE a~mat = @wa2-Product
       INTO @DATA(des1) PRIVILEGED ACCESS.
*
      DATA(lv_xml_line3) =
        |<annexureitem>| &&
        |<sr>{ sr }</sr>| &&
        |<vendor>{ wa_purchaseapi2-YY1_VendorSpecialName_SOS }</vendor>| &&
        |<des1>{ des1 }</des1>| &&
        |<des2>{ wa2-YY1_PackingMode_PDI }</des2>| &&
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
      WHERE a~PurchaseOrder = @lv_po2 AND a~PurchaseOrderItem = @wa2-PurchaseOrderItem
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
*
      DATA(lv_xml_line8) =
      |</table>| &&
      |</annexureitem>|.
*
      CONCATENATE main_xml lv_xml_line8 INTO main_xml.
      CLEAR wa_purchaseapi2.
      CLEAR lt_deliverydate2.
*
    ENDLOOP.

    DATA(lv_annexure) =
    |</annexure>| &&
    |<productspectable>|.

    CONCATENATE main_xml lv_annexure INTO main_xml.

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
      a~purchasingdocumentdeletioncode
    FROM I_PurchaseOrderItemAPI01 AS a
    LEFT JOIN i_producttext AS b ON b~Product = a~Material
    WHERE a~PurchaseOrder = @lv_po2
    INTO TABLE @DATA(lt_product) PRIVILEGED ACCESS.

    DATA : lv_flag TYPE i VALUE 0.

    LOOP AT lt_product INTO DATA(wa_product).

      SELECT SINGLE
        FROM i_purchasinginforecordapi01 AS a
        FIELDS
         a~PurchasingInfoRecord,
         a~YY1_VendorSpecialName_SOS
        WHERE a~Material = @wa_product-Product AND a~Supplier = @wa1-Supplier
        INTO @DATA(wa_purchaseapi1) PRIVILEGED ACCESS.
*
      SELECT
      FROM i_inspplanmatlassgmtverstp_2 AS a
      FIELDS
      a~inspectionplangroup,
      a~inspectionplan
      WHERE a~Material = @wa_product-Product AND inspectionplangroup LIKE '5%'
      INTO TABLE @DATA(lt_rms) PRIVILEGED ACCESS.

      SORT lt_rms BY inspectionplangroup DESCENDING.
      READ TABLE lt_rms INTO DATA(wa_rms) INDEX 1.
*
      DATA: lv_rms TYPE string.
      lv_rms = wa_rms-InspectionPlanGroup.
*
*    CONCATENATE lv_rms '/' wa_rms-InspectionPlan INTO lv_rms.
      IF lv_rms IS NOT INITIAL.
        CONCATENATE lv_rms '/' wa_rms-InspectionPlan INTO lv_rms.
      ELSE.
        lv_rms = wa_rms-InspectionPlan.
      ENDIF.

      DATA: lv_material_code TYPE string.
      lv_material_code = wa_product-Product.

      SHIFT lv_material_code LEFT DELETING LEADING '0'.

      DATA(lv_xml_footer) =
      |<prdspecification>| &&
      |<header>| &&
      |<material_code>{ lv_material_code }</material_code>| &&
      |<rms_no>{ lv_rms }</rms_no>| &&
      |<material_name>{ wa_purchaseapi1-YY1_VendorSpecialName_SOS }</material_name>| &&
      |</header>| &&
      |<prditems>|.


      CONCATENATE main_xml lv_xml_footer INTO main_xml.

      SELECT FROM
      i_purchaseorderitemapi01 AS a LEFT JOIN
      i_inspplanmatlassgmtverstp_2 AS b ON a~Material = b~Material LEFT JOIN
      i_inspplanopcharcversion_2 AS c ON b~InspectionPlanGroup = c~InspectionPlanGroup
      FIELDS
      a~Material,
      a~PurchaseOrderItem,
      c~InspectionSpecificationText,
      c~InspSpecInformationField3,
      c~InspSpecLowerLimit,
      c~InspSpecupperLimit
      WHERE a~PurchaseOrder = @lv_po2
      AND c~inspspecimportancecode = '92' AND
      a~Material = @wa_product-Product
      AND b~InspectionPlanGroup LIKE '5%'
      INTO TABLE @DATA(lt_material) PRIVILEGED ACCESS.

      SORT lt_material BY PurchaseOrderItem ASCENDING.

      sr = 1.
      lv_flag = 0.

      LOOP AT lt_material INTO DATA(wa_material).
        DATA: lv_spec TYPE string.
        IF wa_material-InspSpecInformationField3 IS INITIAL.
          IF wa_material-InspSpecLowerLimit IS NOT INITIAL AND wa_material-InspSpecupperLimit IS NOT INITIAL.
            DATA: p_lv_lower TYPE p DECIMALS 2.
            DATA: p_lv_upper TYPE p DECIMALS 2.
            DATA: lv_lower TYPE string.
            DATA: lv_upper TYPE string.
            p_lv_lower = wa_material-InspSpecLowerLimit.
            p_lv_upper = wa_material-InspSpeclowerLimit.
            lv_lower = p_lv_lower.
            lv_upper = p_lv_upper.
            CONCATENATE lv_lower lv_upper INTO lv_spec SEPARATED BY ' - '.
            CLEAR lv_lower.
            CLEAR lv_upper.
          ELSEIF wa_material-InspSpecLowerLimit IS NOT INITIAL AND wa_material-InspSpecupperLimit IS INITIAL.
            p_lv_lower = wa_material-InspSpecLowerLimit.
            lv_lower = p_lv_lower.
            lv_upper = '  >= '.

            CONCATENATE lv_lower lv_upper INTO lv_spec.
          ELSEIF wa_material-InspSpecLowerLimit IS INITIAL AND wa_material-InspSpecupperLimit IS NOT INITIAL.
            p_lv_upper = wa_material-InspSpecupperLimit.
            lv_lower = ' <= '.
            lv_upper = p_lv_upper.

            CONCATENATE lv_lower lv_upper INTO lv_spec.
          ELSEIF wa_material-InspSpecLowerLimit IS INITIAL AND wa_material-InspSpecupperLimit IS NOT INITIAL.
          ENDIF.
        ELSE.
          lv_spec = wa_material-InspSpecInformationField3.
        ENDIF.

        lv_flag = 1.

        DATA(lv_material_xml) =
            |<prditem>| &&
            |<sr>{ sr }</sr>| &&
            |<testpm>{ wa_material-InspectionSpecificationText }</testpm>| &&
            |<spec>{ lv_spec }</spec>| &&
            |</prditem>|.

        sr = sr + 1.

        CONCATENATE main_xml lv_material_xml INTO main_xml.
        CLEAR wa_material.
        CLEAR lv_spec.
        CLEAR p_lv_upper.
        CLEAR p_lv_lower.
        CLEAR lv_upper.
        CLEAR lv_lower.
      ENDLOOP.

      IF lv_flag = 0.
        lv_material_xml =
            |<prditem>| &&
            |<sr></sr>| &&
            |<testpm></testpm>| &&
            |<spec></spec>| &&
            |</prditem>|.
        CONCATENATE main_xml lv_material_xml INTO main_xml.
      ENDIF.

      DATA(lv_prd_last_item) =
      |</prditems>| &&
      |</prdspecification>|.

      CONCATENATE main_xml lv_prd_last_item INTO main_xml.
      CLEAR lt_rms.
      CLEAR lv_rms.
      CLEAR wa_product.
      CLEAR lt_material.
      CLEAR wa_rms.
      CLEAR wa_purchaseapi1.
    ENDLOOP.

    DATA(lv_prd_last) =
    |</productspectable>|.

    CONCATENATE main_xml lv_prd_last INTO main_xml.


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
