CLASS zcl_render_pdf_exec DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
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
        IMPORTING housebank       TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .

  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'worksorder/worksorder'.
ENDCLASS.



CLASS ZCL_RENDER_PDF_EXEC IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD if_oo_adt_classrun~main.
* DATA(test) = read_posts( salesorderno = '0000000076' ) .
 ENDMETHOD.


  METHOD read_posts .
    DATA lv_xml11 TYPE string .
    DATA selfpynam TYPE string.
    DATA bank TYPE string.
    DATA lv_xml111 TYPE string.


    DATA(lv1)  =  |<form1>|  .
    DATA(lv2)  =  |</form1>|  .

    lv_xml111  = lv1 && lv2 .


    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_xml111
        template = lc_template_name
      RECEIVING
        result   = result12 ).

  ENDMETHOD .
ENDCLASS.
