CLASS zcl_mm_rfq_http DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS: get_html RETURNING VALUE(html) TYPE string.
    METHODS: post_html
      IMPORTING
                rfq_num     TYPE string
      RETURNING VALUE(html) TYPE string.

    CLASS-DATA url TYPE string.
ENDCLASS.



CLASS ZCL_MM_RFQ_HTTP IMPLEMENTATION.


  METHOD get_html.    "Response HTML for GET request

    html = |<html> \n| &&
 |<body> \n| &&
 |<title>RFQ  </title> \n| &&
 |<form action="{ url }" method="POST">\n| &&
 |<H2>RFQ Print</H2> \n| &&
 |<label for="fname">RFQ number:  </label> \n| &&
 |<input type="text" id="rfq_num" name="rfq_num" required ><br><br> \n| &&
 |<input type="submit" value="Submit"> \n| &&
 |</form> | &&
 |</body> \n| &&
 |</html> | .



  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.
    DATA(req) = request->get_form_fields(  ).
    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
    DATA(cookies)  = request->get_cookies(  ) .

    DATA req_host TYPE string.
    DATA req_proto TYPE string.
    DATA req_uri TYPE string.

    req_host = request->get_header_field( i_name = 'Host' ).
    req_proto = request->get_header_field( i_name = 'X-Forwarded-Proto' ).
    IF req_proto IS INITIAL.
      req_proto = 'https'.
    ENDIF.
*     req_uri = request->get_request_uri( ).
    DATA(symandt) = sy-mandt.
    req_uri = '/sap/bc/http/sap/ZMM_RFQ_HTTP?sap-client=080'.
    url = |{ req_proto }://{ req_host }{ req_uri }client={ symandt }|.


    CASE request->get_method( ).

      WHEN CONV string( if_web_http_client=>get ).

        response->set_text( get_html( ) ).

      WHEN CONV string( if_web_http_client=>post ).

        DATA(lv_rfq) = request->get_form_field( `rfq_num` ).

        SELECT SINGLE FROM I_PurchaseOrderAPI01
        FIELDS PurchaseOrder "WHERE PurchaseOrder = @ebeln      "6000000002
        INTO @DATA(lv_po).

        IF lv_po IS NOT INITIAL.

          TRY.
              DATA(pdf) = zcl_rfq_driver=>read_posts( rfq_num = lv_rfq ).

*            response->set_text( pdf ).

              DATA(html) = |<html> | &&
                             |<body> | &&
                               | <iframe src="data:application/pdf;base64,{ pdf }" width="100%" height="100%"></iframe>| &&
                             | </body> | &&
                           | </html>|.



              response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
              response->set_text( html ).
            CATCH cx_static_check INTO DATA(er).
              response->set_text( er->get_longtext(  ) ).
          ENDTRY.
        ELSE.
          response->set_text( 'RFQ does not exist.' ).
        ENDIF.

    ENDCASE.

*    TRY.
*        DATA(pdf) = ycl_adobe_print=>read_posts( ebeln = ebeln ).
*
*
*        response->set_text( pdf ).
*      CATCH cx_static_check INTO DATA(er).
*        response->set_text( er->get_longtext(  ) ).
*    ENDTRY.


  ENDMETHOD.


  METHOD post_html.

    html = |<html> \n| &&
   |<body> \n| &&
   |<title>RFQ Print</title> \n| &&
   |<form action="{ url }" method="Get">\n| &&
   |<H2>RFQ Print Success </H2> \n| &&
   |<input type="submit" value="Go Back"> \n| &&
   |</form> | &&
   |</body> \n| &&
   |</html> | .
  ENDMETHOD.
ENDCLASS.
