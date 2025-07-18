CLASS zcl_prd_memo_drv DEFINITION
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
        IMPORTING cleardoc        TYPE string
                  division        TYPE string
                  divisionname    TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zprd_memo_detail/zprd_memo_detail'."'zpo/zpo_v2'."
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.
ENDCLASS.



CLASS ZCL_PRD_MEMO_DRV IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .

    SELECT SINGLE
    a~reservation,
    a~storagelocation,
    a~ISsUINGORRECEIVINGSTORAGELOC,
    a~plant,
    a~matlcomprequirementdate,
   b~division,
   c~divisionname

    FROM i_reservationdocumentitem WITH PRIVILEGED ACCESS AS a
  LEFT     JOIN i_product WITH PRIVILEGED ACCESS AS b ON  a~product = b~Product
  LEFT JOIN i_cnsldtndivisiont WITH PRIVILEGED ACCESS AS c ON b~Division = c~Division
    WHERE a~Reservation =  @cleardoc and a~GoodsMovementType = '311'
    INTO @DATA(wa_header).
*    out->write( wa_header ).
    SELECT  SINGLE
    a~plant,
     d~plant_name1 ,
         d~address1 ,
         d~address2 ,
         d~city ,
         d~district ,
         d~state_name ,
         d~pin ,
         d~country

     FROM i_reservationdocumentitem WITH PRIVILEGED ACCESS AS a
      LEFT JOIN ztable_plant WITH PRIVILEGED ACCESS AS d ON d~plant_code = a~plant
        WHERE a~Reservation =  @cleardoc and a~GoodsMovementType = '311'
        INTO @DATA(wa_headeradd).
    DATA plant_add TYPE string.
    CONCATENATE wa_headeradd-address1 ','  wa_headeradd-address2 ',' wa_headeradd-district ',' wa_headeradd-state_name  ',' wa_headeradd-city   ',' wa_headeradd-pin            INTO plant_add.

    """"""""""""item level """"""""""""""""""
    SELECT
    a~reservation,
    a~product,
    a~batch,
    a~ResvnItmRequiredQtyInBaseUnit,
    a~entryunit,
    b~productdescription,
    c~manufacturedate,
    c~shelflifeexpirationdate,
    c~plant,
    c~material,
    d~division
    FROM i_reservationdocumentitem WITH PRIVILEGED ACCESS AS a
    LEFT JOIN i_productdescription WITH PRIVILEGED ACCESS AS b ON a~Product = b~Product
    LEFT JOIN i_batch  WITH PRIVILEGED ACCESS AS c ON a~plant = c~plant AND a~Batch = c~batch AND a~Product = c~material AND c~plant IS NOT INITIAL
    LEFT  JOIN i_product WITH PRIVILEGED ACCESS AS d ON  a~product = d~Product
    WHERE a~Reservation =  @cleardoc AND d~division = @division and a~GoodsMovementType = '311'
     INTO TABLE @DATA(item).

    SORT item BY Reservation Product Batch Plant ASCENDING.
    DELETE ADJACENT DUPLICATES FROM item COMPARING Reservation Product Batch Plant.

    DATA: month_number TYPE string.
    DATA: lv_year TYPE string.
    DATA: month_name TYPE string.

    lv_year = wa_header-MatlCompRequirementDate+0(4).
    month_number = wa_header-MatlCompRequirementDate+4(2).
    CASE month_number.
      WHEN 1.
        month_name = 'January'.
      WHEN 2.
        month_name = 'February'.
      WHEN 3.
        month_name = 'March'.
      WHEN 4.
        month_name = 'April'.
      WHEN 5.
        month_name = 'May'.
      WHEN 6.
        month_name = 'June'.
      WHEN 7.
        month_name = 'July'.
      WHEN 8.
        month_name = 'August'.
      WHEN 9.
        month_name = 'September'.
      WHEN 10.
        month_name = 'October'.
      WHEN 11.
        month_name = 'November'.
      WHEN 12.
        month_name = 'December'.
      WHEN OTHERS.
        month_name = 'Invalid month number'.
    ENDCASE.

*    out->write( item ).

    DATA(lv_xml) =
      |<Form>| &&
      |<Plant_Name>{ wa_headeradd-plant_name1 }</Plant_Name>| &&
      |<Address1>{ plant_add }</Address1>| &&
      |<Address2></Address2>| &&
      |<Prodon_memo_no>{ wa_header-Reservation }</Prodon_memo_no>| &&
      |<Disvison>{ divisionname }</Disvison>| &&                      " pending
      |<Date>{ wa_header-MatlCompRequirementDate }</Date>| && " Work order no
      |<Sending_lecotion>{ wa_header-StorageLocation }</Sending_lecotion>| &&
      |<Plant>{ wa_header-Plant }</Plant>| && " PO date
      |<Fin_yr>{ lv_year }</Fin_yr>| &&
      |<Month>{ month_name   }</Month>| &&
      |<Receiving_s._location>{ wa_header-IssuingOrReceivingStorageLoc }</Receiving_s._location>| &&
  |<LineItem>|.

    LOOP AT item INTO DATA(wa_item).

      SELECT SINGLE FROM
         I_UnitOfMeasure AS a
         FIELDS
         a~UnitOfMeasure_E
         WHERE a~UnitOfMeasure = @wa_item-EntryUnit
         INTO @DATA(lv_unit).

      DATA(lv_xml_table) =
         |<item>| &&
        |<item>{ wa_item-ProductDescription }</item>| &&
        |<Batch>{ wa_item-Batch }</Batch>| &&
        |<qty>{ wa_item-ResvnItmRequiredQtyInBaseUnit }</qty>| &&
        |<uom>{ lv_unit }</uom>| &&
        |<mfgdate>{ wa_item-ManufactureDate }</mfgdate>| &&
        |<expdate>{ wa_item-ShelfLifeExpirationDate }</expdate>| &&
        |</item>|.
      CONCATENATE lv_xml lv_xml_table INTO lv_xml.
      CLEAR wa_item.
    ENDLOOP.
    CONCATENATE lv_xml '</LineItem>' '</Form>' INTO lv_xml.
*out->write( lv_xml ).

    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).


  ENDMETHOD.
ENDCLASS.
