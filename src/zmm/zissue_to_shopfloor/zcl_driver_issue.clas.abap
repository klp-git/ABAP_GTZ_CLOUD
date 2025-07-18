
CLASS zcl_driver_issue DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*    INTERFACES if_oo_adt_classrun .
    CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
    CLASS-DATA : var1 TYPE i_processordertp-ProcessOrder.
    CLASS-DATA : var2 TYPE i_materialdocumentitem_2-MaterialDocument.
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
        IMPORTING process_no      TYPE string
                  mat_no          TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'ZISSUE_TO_PRODUCTION/ZISSUE_TO_PRODUCTION'.

ENDCLASS.



CLASS ZCL_DRIVER_ISSUE IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .
    DATA: process_no_1 TYPE string.

    DATA : mat_no1 TYPE string.

    var1 = process_no.
    var1 =   |{ |{ var1 ALPHA = OUT }| ALPHA = IN }| .
    process_no_1 = process_no.
    process_no_1 = var1.

    var2 = mat_no.
    var2 =   |{ |{ var2 ALPHA = OUT }| ALPHA = IN }| .
    mat_no1 = mat_no.
    mat_no1 = var2.


    SELECT SINGLE
     a~ProcessOrderText ,a~Batch, b~productionversiontext, a~orderplannedtotalqty ,a~productionunit,a~ProcessOrder
     FROM i_processordertp AS a
     LEFT JOIN i_productionversion AS b ON a~Product = b~Material AND a~ProductionVersion = b~ProductionVersion
    WHERE a~ProcessOrder = @process_no_1
     INTO @DATA(wa_header).

    DATA : lv_combine TYPE string,
           lv_new_qty TYPE string.

    lv_new_qty = wa_header-OrderPlannedTotalQty.
    CONCATENATE lv_new_qty  wa_header-ProductionUnit INTO lv_combine .

    SELECT SINGLE
    a~DocumentDate,
    a~MaterialDocument,
    d~address1,
    d~address2,
    d~state_name,
    d~city,
    d~district,
    d~state_code2,
    d~country,
    d~pin




    FROM i_materialdocumentitem_2 AS a
     LEFT JOIN ztable_plant AS d ON a~Plant = d~plant_code
    WHERE a~MaterialDocument = @mat_no1
    INTO @DATA(wa_issue).

    SELECT FROM i_materialdocumentitem_2 AS a
   LEFT JOIN i_productdescription AS b  ON a~Material = b~Product
   LEFT JOIN I_ProcessOrderComponentTP AS c ON a~Material = c~Material AND a~Material IS NOT INITIAL AND c~Material IS NOT INITIAL
   FIELDS b~ProductDescription,a~MaterialBaseUnit,a~IssgOrRcvgBatch,a~ShelfLifeExpirationDate,a~QuantityInBaseUnit,a~Material,
   c~RequiredQuantity
   WHERE a~MaterialDocument = @mat_no1 AND a~IsAutomaticallyCreated = 'X' AND c~ProcessOrder = @process_no_1
   INTO TABLE @DATA(item).



    SHIFT wa_header-ProcessOrder LEFT DELETING LEADING '0'.
    DATA: addressstring TYPE string.
    CONCATENATE wa_issue-address1 ', ' wa_issue-address2 ' , '  wa_issue-city ' , '  wa_issue-state_name ' - ' wa_issue-state_code2 ' , '  wa_issue-country ' ' wa_issue-pin INTO addressstring.

    DATA : lv_xml TYPE string.
    lv_xml = |<Form>| &&
             |<Header>| &&
             |<Process_no>{ wa_header-ProcessOrder }</Process_no>| &&
             |<addressstring> { addressstring } </addressstring>| &&
             |<Product>{ wa_header-ProcessOrderText }</Product>| &&
             |<Batch_No>{ wa_header-Batch }</Batch_No>| &&
             |<BOM_Code>{ wa_header-ProductionVersionText }</BOM_Code>| &&
             |<Batch_Qty>{ lv_combine }</Batch_Qty>| &&
             |<Issue_No>{ wa_issue-MaterialDocument }</Issue_No>| &&
             |<Issue_Date>{ wa_issue-DocumentDate }</Issue_Date>| &&
             |</Header>| &&
             |<Item>|.

*    DATA : sno TYPE i VALUE 0.
*    LOOP AT item INTO DATA(wa_item).
*      sno = sno + 1.
*      SELECT SINGLE FROM
*      I_UnitOfMeasure AS a
*      FIELDS
*      a~UnitOfMeasure_E
*      WHERE a~UnitOfMeasure = @wa_item-MaterialBaseUnit
*      INTO @DATA(lv_unit).
*
*      DATA(lv_item) = |<lineitem>| &&
*              |<sno>{ sno }</sno>| &&
*              |<Description>{ wa_item-ProductDescription }</Description>| &&
*              |<UOM>{ lv_unit }</UOM>| &&
*              |<Batch_No_item>{ wa_item-IssgOrRcvgBatch }</Batch_No_item>| &&
*              |<Expiry_date>{ wa_item-ShelfLifeExpirationDate }</Expiry_date>| &&
*              |<Issue_qty>{ wa_item-QuantityInBaseUnit }</Issue_qty>| &&
*              |<Required_Qty>{ wa_item-RequiredQuantity }</Required_Qty>| &&
*              |</lineitem>|.
*      CONCATENATE lv_xml lv_item INTO lv_xml.
*
*      CLEAR wa_item.
*      CLEAR lv_unit.
*    ENDLOOP.


    """""""""""""""""""""""" changed by Apratim """"""""""""""""""""""
    SELECT FROM i_materialdocumentitem_2 AS a
    LEFT JOIN i_productdescription AS b  ON a~Material = b~Product
    FIELDS
    b~ProductDescription,a~MaterialBaseUnit,a~IssgOrRcvgBatch,a~ShelfLifeExpirationDate,a~QuantityInBaseUnit,a~Material
    WHERE a~MaterialDocument = @mat_no1 AND a~IsAutomaticallyCreated = 'X'
    INTO TABLE @DATA(item1).

    SORT item1 BY Material ASCENDING.
    DELETE ADJACENT DUPLICATES FROM item1 COMPARING material.

    DATA : sno TYPE i VALUE 0.

    LOOP AT item1 INTO DATA(wa_item1).
      SELECT FROM i_materialdocumentitem_2 AS a
      FIELDS
      a~IssgOrRcvgBatch,SUM( a~QuantityInBaseUnit ) AS issuedqty ,a~Material
      WHERE a~IsAutomaticallyCreated = 'X' AND a~MaterialDocument = @mat_no1 AND a~Material = @wa_item1-Material
      GROUP BY a~IssgOrRcvgBatch,a~Material
      INTO TABLE @DATA(lt_table).

      DATA(lt_lines) = lines( lt_table ).

      IF lt_lines = 1.
        READ TABLE lt_table INTO DATA(wa_table) INDEX 1.
        SELECT FROM I_ProcessOrderComponentTP AS c
        FIELDS
        c~RequiredQuantity,c~Batch
        WHERE c~ProcessOrder = @process_no_1 AND c~material = @wa_table-Material AND c~RequiredQuantity IS NOT INITIAL AND
        c~GoodsMovementType = '261'
        INTO TABLE @DATA(lt_required).

        LOOP AT lt_required INTO DATA(wa_required).
          sno = sno + 1.

          SELECT SINGLE FROM
          I_UnitOfMeasure AS a
          FIELDS
          a~UnitOfMeasure_E
          WHERE a~UnitOfMeasure = @wa_item1-MaterialBaseUnit
          INTO @DATA(lv_unit).

          DATA(lv_item) = |<lineitem>| &&
        |<sno>{ sno }</sno>| &&
        |<Description>{ wa_item1-ProductDescription }</Description>| &&
        |<UOM>{ lv_unit }</UOM>| &&
        |<Batch_No_item>{ wa_table-IssgOrRcvgBatch }</Batch_No_item>| &&
        |<Expiry_date>{ wa_item1-ShelfLifeExpirationDate }</Expiry_date>| &&
        |<Issue_qty>{ wa_table-issuedqty }</Issue_qty>| &&
        |<Required_Qty>{ wa_required-RequiredQuantity }</Required_Qty>| &&
        |</lineitem>|.
          CONCATENATE lv_xml lv_item INTO lv_xml.
          CLEAR wa_table-issuedqty.
          CLEAR wa_required.
          CLEAR lv_unit.
        ENDLOOP.

      ELSE.

        SELECT FROM I_ProcessOrderComponentTP AS c
        FIELDS
        SUM( c~RequiredQuantity )
        WHERE c~ProcessOrder = @process_no_1 AND c~material = @wa_item1-Material AND c~RequiredQuantity IS NOT INITIAL AND
        c~GoodsMovementType = '261'
        INTO @DATA(sumrequired).


        LOOP AT lt_table INTO wa_table.
          sno = sno + 1.

          SELECT SINGLE FROM
          I_UnitOfMeasure AS a
          FIELDS
          a~UnitOfMeasure_E
          WHERE a~UnitOfMeasure = @wa_item1-MaterialBaseUnit
          INTO @lv_unit.

          lv_item = |<lineitem>| &&
            |<sno>{ sno }</sno>| &&
            |<Description>{ wa_item1-ProductDescription }</Description>| &&
            |<UOM>{ lv_unit }</UOM>| &&
            |<Batch_No_item>{ wa_table-IssgOrRcvgBatch }</Batch_No_item>| &&
            |<Expiry_date>{ wa_item1-ShelfLifeExpirationDate }</Expiry_date>| &&
            |<Issue_qty>{ wa_table-issuedqty }</Issue_qty>| &&
            |<Required_Qty>{ sumrequired }</Required_Qty>| &&
            |</lineitem>|.
          CONCATENATE lv_xml lv_item INTO lv_xml.
          CLEAR sumrequired.
          CLEAR lv_unit.
          CLEAR wa_table.
        ENDLOOP.

      ENDIF.


    ENDLOOP.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


    CONCATENATE lv_xml '</Item>' '</Form>' INTO lv_xml.

    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).
  ENDMETHOD .
ENDCLASS.
