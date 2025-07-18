CLASS ZCL_HTTP_DOM_TAX DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS: get_html RETURNING VALUE(html) TYPE string.
    METHODS: post_html
      IMPORTING
                bill_doc    TYPE string
      RETURNING VALUE(html) TYPE string.

    CLASS-DATA url TYPE string.
ENDCLASS.



CLASS ZCL_HTTP_DOM_TAX IMPLEMENTATION.


  METHOD get_html.    "Response HTML for GET request

    html = |<html> \n| &&
  |<body> \n| &&
  |<title>Tax Invoice</title> \n| &&
  |<form action="{ url }" method="POST">\n| &&
  |<H2>Tax Invoice</H2> \n| &&
  |<label for="fname">Tax Invoice:  </label> \n| &&
  |<input type="text" id="bill" name="bill" required ><br><br> \n| &&
  |<input type="submit" value="Submit"> \n| &&
  |</form> | &&
  |</body> \n| &&
  |</html> | .

  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.

    "0500000010  0002000004  4500000001 0500000002/3/4 4500000004 0600000004/5
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
    req_uri = '/sap/bc/http/sap/ZHTTP_DOM_TAX?sap-client=080'.
    url = |{ req_proto }://{ req_host }{ req_uri }client={ symandt }|.


    CASE request->get_method( ).

      WHEN CONV string( if_web_http_client=>get ).

        response->set_text( get_html( ) ).

      WHEN CONV string( if_web_http_client=>post ).

        DATA(bill_doc) = request->get_form_field( `bill` ).

        SELECT SINGLE FROM I_BillingDocument WITH PRIVILEGED ACCESS
        FIELDS BillingDocument WHERE BillingDocument = @bill_doc

        INTO @DATA(lv_bill).

        IF lv_bill IS NOT INITIAL.

          TRY.
              DATA(pdf) = zcl_http_dom_tax_print=>read_posts( bill_doc = bill_doc ).
    if  pdf = 'ERROR'.
          response->set_text( 'Error to show PDF something Problem' ).

ELSE.
              DATA(html) = |<html> | &&
                             |<body> | &&
                               | <iframe src="data:application/pdf;base64,{ pdf }" width="100%" height="100%"></iframe>| &&

                             | </body> | &&
                           | </html>|.

              response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
              response->set_text( html ).
              ENDIF.
            CATCH cx_static_check INTO DATA(er).
              response->set_text( er->get_longtext(  ) ).
          ENDTRY.
        ELSE.
          response->set_text( 'Billing Document no. does not exist.' ).
        ENDIF.

    ENDCASE.

  ENDMETHOD.


  METHOD post_html.

    html = |<html> \n| &&
   |<body> \n| &&
   |<title>Tax Invoice</title> \n| &&
   |<form action="{ url }" method="Get">\n| &&
   |<H2>Tax Invoice Success </H2> \n| &&
   |<input type="submit" value="Go Back"> \n| &&
   |</form> | &&
   |</body> \n| &&
   |</html> | .
  ENDMETHOD.
ENDCLASS.
