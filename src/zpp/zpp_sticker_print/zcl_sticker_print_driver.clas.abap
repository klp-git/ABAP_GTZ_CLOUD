CLASS zcl_sticker_print_driver DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
    CLASS-DATA : template TYPE string .
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
        IMPORTING VALUE(orderno)  TYPE char12
                  beamno          TYPE string
                  fromsticker     TYPE string
                  tosticker       TYPE string


        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .

  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.eu10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://btp-yvzjjpaz.authentication.eu10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'ZPP_CARD_STICKER/ZPP_CARD_STICKER'.

ENDCLASS.



CLASS ZCL_STICKER_PRINT_DRIVER IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).
  ENDMETHOD .


  METHOD if_oo_adt_classrun~main.
* DATA(test) = read_posts( salesorderno = '0000000076' ) .
  ENDMETHOD.


  METHOD read_posts .


    DATA xsml TYPE string .
    DATA Lv_xml TYPE string .
    DATA tostiker TYPE string .

    tostiker = tosticker .

    IF fromsticker IS NOT INITIAL AND tostiker IS INITIAL .

      tostiker = fromsticker .

    ENDIF.

    IF  beamno IS NOT INITIAL AND orderno IS NOT INITIAL.

      SELECT SINGLE b~ProductDescription FROM I_ManufacturingOrderItem AS a
                   INNER JOIN I_ProductDescription AS b ON ( b~Product = a~Material AND b~Language = 'E' )
                   WHERE Batch = @beamno AND a~ManufacturingOrder = @orderno  INTO @DATA(matdes) .

*     SELECT SINGLE YY1_SetNo_ORD FROM I_ManufacturingOrder WHERE Batch = @beamno AND ManufacturingOrder = @orderno INTO  @DATA(SETNO) .

    ENDIF.

    DATA : alpha TYPE c LENGTH 1.

*SELECT *
* FROM zpp_alphabet_ta1 AS a WHERE alphabet BETWEEN @fromsticker AND @TOSTIKER INTO TABLE  @DATA(ROLLNO) .

*DATA(IT1)  = ROLLNO[].


*SORT IT1 DESCENDING BY SNO.
*READ TABLE IT1 INTO DATA(WA_IT1) INDEX 1 .
*
*SORT ROLLNO BY SNO.
*DATA N TYPE I  .
*LOOP AT ROLLNO INTO DATA(ROLLWA) .
* N = N + 1 .
*ENDLOOP.


*DATA SNO2 TYPE I    .
*
*    SNO2   =  N / 2 .
    lv_xml =

      |<form1>| &&
      |<Subform2>| .
*
*DATA N1 TYPE I  .
*DATA N2 TYPE I  .
*DATA N3 TYPE I  .
*DATA N4 TYPE I  .
*DATA BARCODE1 TYPE STRING .
*DATA BARCODE2 TYPE STRING  .
*
* READ TABLE ROLLNO INTO DATA(WA_ROLLNO) INDEX 1.
*
* DO SNO2   TIMES  .
*    IF SNO2 = '1' AND N = '1' .
*
*     N2 = WA_ROLLNO-sno .
*
*     SELECT SINGLE alphabet FROM zpp_alphabet_ta1 WHERE sno = @N2 INTO   @DATA(ROLLNO1) .
*
*    ELSE .
*   N1 = N1 + 1 .
*
*   IF N1 = '1' .
*   N2 = WA_ROLLNO-sno .
*   SELECT SINGLE alphabet FROM zpp_alphabet_ta1 WHERE sno = @N2 INTO   @ROLLNO1 .
*   ELSE.
*   N2 = N4 + 1.
*   IF  N2 <=  WA_IT1-sno .
*   SELECT SINGLE alphabet FROM zpp_alphabet_ta1 WHERE sno = @N2 INTO   @ROLLNO1 .
*   ENDIF.
*   ENDIF.
*
*   N3  = N3 + 1 .
*
*   IF N3 = '1'  .
*   N4  = WA_ROLLNO-sno + 1.
*   SELECT SINGLE alphabet FROM zpp_alphabet_ta1 WHERE sno = @N4 INTO   @DATA(ROLLNO2) .
*   ELSE .
*
*   N4 = N4 + 2.
*   IF N4 <=  WA_IT1-sno .
*   SELECT SINGLE alphabet FROM zpp_alphabet_ta1 WHERE sno = @N4 INTO   @ROLLNO2 .
*   ENDIF.
*   ENDIF.
*
*ENDIF.
*
*  CONCATENATE beamno ROLLNO1 INTO BARCODE1 .
*   CONCATENATE beamno ROLLNO2 INTO BARCODE2 .
*
    lv_xml =   lv_xml &&
*
          |<SFLine_1>| &&
          |<SF_1>| &&
          |<Beamno>{ beamno }</Beamno>| &&
*            |<RollNo>{ ROLLNO1 }</RollNo>| &&
*            |<Supervisor_name></Supervisor_name>| &&
*            |<Setno>{ SETNO }</Setno>| &&
*            |<Dofin_Date></Dofin_Date>| &&
*            |<Dofin_No></Dofin_No>| &&
*            |<SortNo>{ MATDES }</SortNo>| &&
*            |<Code128BarCode1>{ BARCODE1 }</Code128BarCode1>| &&
          |</SF_1>| &&
*            |<SF_2>| &&
*            |<Supervisor_name></Supervisor_name>| &&
*            |<Setno>{ SETNO }</Setno>| &&
*            |<Dofin_Date></Dofin_Date>| &&
*            |<Dofin_No></Dofin_No>| &&
*            |<SortNo>{ MATDES }</SortNo>| &&
*            |<RollNo>{ ROLLNO2 }</RollNo>| &&
*            |<Beamno>{ beamno }</Beamno>| &&
*            |<Code128BarCode2>{ BARCODE2 }</Code128BarCode2>| &&
*            |</SF_2>| &&
          |</SFLine_1>| .
*
*CLEAR : ROLLNO1 ,ROLLNO2 , BARCODE1 ,BARCODE2.
*ENDDO.

    lv_xml =   lv_xml &&
       |</Subform2>| &&
       |</form1>| .

    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).


  ENDMETHOD.
ENDCLASS.
