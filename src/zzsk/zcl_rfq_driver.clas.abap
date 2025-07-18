CLASS zcl_rfq_driver DEFINITION
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
        IMPORTING rfq_num         TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zmm_rfq_print/zmm_rfq_print'."'z/zpo_v2'."
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.

ENDCLASS.



CLASS ZCL_RFQ_DRIVER IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .


    SELECT SINGLE FROM zr_rfqmatrixcds AS a
   FIELDS a~requestforquotation , a~Vendorname, a~Productcode, a~Productdesc, a~Orderquantity
   WHERE a~requestforquotation = @rfq_num
   INTO @DATA(wa_head).

    DATA(lv_xml) = |<Form>| &&
*                   |<REQUESTFORQUOTATION>{ wa_head-requestforquotation }</REQUESTFORQUOTATION>| &&
                   |<REQUESTFORQUOTATION>6000000005</REQUESTFORQUOTATION>| &&
                   |<VENDORNAME>{ wa_head-vendorname }</VENDORNAME>| &&
                   |<PRODUCTCODE>{ wa_head-productcode }</PRODUCTCODE> | &&
                   |<PRODUCTDESC> { wa_head-productdesc }</PRODUCTDESC> | &&
                   |<ORDERQUANTITY>{ wa_head-orderquantity }</ORDERQUANTITY> | &&
                   |</Form>|.

    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

  ENDMETHOD .
ENDCLASS.
