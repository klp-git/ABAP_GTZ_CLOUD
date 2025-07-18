CLASS zcl_purchase_requisition DEFINITION
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
        IMPORTING cleardoc        TYPE c_purchaserequisitionitemdex-PurchaseRequisition
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'ZPURCHASEREQUISITION/ZPURCHASEREQUISITION'."'zpo/zpo_v2'."
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.
ENDCLASS.



CLASS ZCL_PURCHASE_REQUISITION IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).
  ENDMETHOD .


  METHOD read_posts .

    """""""""""""""header level """"""""""""""""""""""""""""'
    SELECT SINGLE
    a~Purchaserequisition,
    b~plant_name1,
    b~plant_name2,
    a~Creationdate,
    a~Purchaserequisitiontype,
    c~Purchasingdocumenttypename,
    d~PurReqnDescription   """""""""""
    FROM c_purchaserequisitionitemdex WITH PRIVILEGED ACCESS AS a
    LEFT JOIN ztable_plant WITH PRIVILEGED ACCESS AS b ON a~plant = b~plant_code
    LEFT JOIN i_purchasingdocumenttypetext WITH PRIVILEGED ACCESS AS c ON a~Purchaserequisitiontype = c~PurchasingDocumentType
    LEFT JOIN I_PurchaseRequisitionAPI01 WITH PRIVILEGED ACCESS AS d ON a~PurchaseRequisition = d~PurchaseRequisition
    AND c~Purchasingdocumentcategory = 'B'

    WHERE a~Purchaserequisition = @cleardoc
    INTO @DATA(header).

    SELECT SINGLE
    FROM I_PurchaseRequisitionAPI01 AS a
    FIELDS
    a~PurReqnDescription
    WHERE a~PurchaseRequisition = @cleardoc
    INTO @DATA(wa_Indent_From).

*    out->write( header ).

    """"""""""""""""""""""""""""""item level""""""""""""""""""""""""""""""""""""""
    DATA string1 TYPE string.
    CONCATENATE header-plant_name1 header-plant_name2 INTO string1 SEPARATED BY space.
    DATA(lv_xml) =
    |<Form>| &&
    |<Header>| &&
    |<Indent_From>{ wa_Indent_From }</Indent_From>| &&
    |<Department>{ header-PurReqnDescription }</Department>| &&
    |<Indent_Date>{ header-CreationDate }</Indent_Date>| &&
    |<Indent_Code>{ header-PurchaseRequisition }</Indent_Code>| &&
    |<Purchase_group>{ header-PurchasingDocumentTypeName }</Purchase_group>| &&
    |<Opertaion_Unit>{ string1 }</Opertaion_Unit>| &&
    |<created></created>| &&
    |</Header>| &&
    |<items>|.


    SELECT

    a~Purchaserequisition,
    a~material,
    a~Purchaserequisitionitem,
    a~plant,
    a~storagelocation ,
    a~deliverydate,
    a~purchaserequisitionprice,
    a~requirementtracking,
    b~productdescription,
    a~requestedquantity,
    c~unitofmeasure_E
*   d~purchaseorder,
*   d~Purchaseorderitem,
*   d~PostingDate,
*  e~NETPRICEAMOUNT
   FROM c_purchaserequisitionitemdex WITH PRIVILEGED ACCESS AS a
   LEFT JOIN i_productdescription WITH PRIVILEGED ACCESS AS b ON a~material = b~product AND b~language = 'E'
   LEFT JOIN i_unitofmeasure WITH PRIVILEGED ACCESS AS c ON a~BaseUnit =  c~UnitOfMeasure
* LEFT JOIN I_PURCHASEORDERHISTORYAPI01 WITH PRIVILEGED ACCESS as d on a~Material = d~Material
* LEFT JOIN I_STORAGELOCATION WITH PRIVILEGED ACCESS as e on  a~Plant = e~Plant
   WHERE a~Purchaserequisition = @cleardoc
   INTO TABLE @DATA(item).
* out->write( item ).
*  SORT it_po_qty_date BY PostingDate DESCENDING Material ASCENDING .
    SORT item BY Purchaserequisitionitem ASCENDING.

    DATA string2 TYPE string.
    DATA : lv_date TYPE vdm_validitystart.
    lv_date = cl_abap_context_info=>get_system_date( ).
    DATA: sr TYPE i VALUE 1.

    LOOP AT item INTO DATA(wa_item).
      SELECT FROM
      i_purchaseorderhistoryapi01 AS d
      FIELDS
      d~purchaseorder,
      d~Purchaseorderitem,
      d~PostingDate
      WHERE d~Material = @wa_item-Material
      INTO TABLE @DATA(lt_podate).
      SORT lt_podate BY PostingDate DESCENDING.
      IF lt_podate IS NOT INITIAL.
        READ TABLE lt_podate INTO DATA(lv_podate) INDEX 1.
      ENDIF.

      SELECT SINGLE FROM
      i_purchaseorderitemtp_2 AS e
      FIELDS
      e~netpriceamount
      WHERE e~PurchaseOrder = @lv_podate-PurchaseOrder AND e~PurchaseOrderItem = @lv_podate-PurchaseOrderItem
      INTO @DATA(lv_netprice).

      SELECT SINGLE  FROM
       i_storagelocation  WITH PRIVILEGED ACCESS
       FIELDS  storagelocationname

       WHERE plant = @wa_item-plant AND storagelocation  = @wa_item-storagelocation

       INTO @DATA(str1).

*      SELECT SUM( matlwrhsstkqtyinmatlbaseunit )
*  FROM i_matlstkatkeydateinaltuom( p_keydate = @lv_date )
*  WITH PRIVILEGED ACCESS
*
*  WHERE product = @wa_item-material
*  INTO @DATA(str2).

      SELECT SINGLE
      FROM
      I_MaterialStock_2 AS a
      FIELDS
      SUM( a~MatlWrhsStkQtyInMatlBaseUnit )
      WHERE a~Material = @wa_item-Material AND a~Plant = @wa_item-Plant
      INTO @DATA(str2).

      string2 = wa_item-PurchaseRequisitionPrice *  wa_item-RequestedQuantity .

      SELECT SINGLE FROM
      i_purchaserequisitionitemapi01 AS a
      FIELDS
      a~YY1_Pur_ItemText_PRI,
      a~YY1_RemarksItem_PRI
      WHERE a~PurchaseRequisition = @cleardoc AND a~PurchaseRequisitionItem = @wa_item-PurchaseRequisitionItem
      INTO @DATA(wa_text).

      SHIFT wa_item-Material LEFT DELETING LEADING '0'.

      DATA(lv_itemxml) =
      |<item>| &&

      |<srNo>{ sr }</srNo>| &&
      |<Material>{ wa_item-Material }</Material>| &&
      |<Short_Text>{ wa_item-ProductDescription }</Short_Text>| &&
      |<Item_Text>{ wa_text-YY1_Pur_ItemText_PRI }</Item_Text>| &&
      |<Qty>{ wa_item-RequestedQuantity }</Qty>| &&
      |<Uom>{ wa_item-UnitOfMeasure_E }</Uom>| &&
      |<Material_Required_Date>{ wa_item-DeliveryDate }</Material_Required_Date>| &&
      |<Last_Purchase_Price>{ lv_netprice }</Last_Purchase_Price>| &&
      |<Current_Approx_Rate>{ wa_item-PurchaseRequisitionPrice }</Current_Approx_Rate>| &&
      |<Current_Amt>{ string2 }</Current_Amt>| &&
      |<Storage_Location>{ str1 }</Storage_Location>| &&
      |<Aviliable_Stock>{ str2 }</Aviliable_Stock>| &&
      |<Trackin_No>{ wa_item-RequirementTracking }</Trackin_No>| &&
      |<Remarks>{ wa_text-YY1_RemarksItem_PRI }</Remarks>| &&
        |</item>|.

      sr = sr + 1.
      CONCATENATE lv_xml lv_itemxml INTO lv_xml.
      CLEAR wa_item.
      CLEAR wa_text.
      clear str2.
      clear str1.
    ENDLOOP.

    DATA(lv_last) =
    |</items>| &&
    |</Form>|.


    CONCATENATE   lv_xml lv_last INTO lv_xml.


    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).


  ENDMETHOD.
ENDCLASS.
