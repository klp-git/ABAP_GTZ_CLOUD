CLASS zcl_http_dom_quo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA url TYPE string.
ENDCLASS.



CLASS ZCL_HTTP_DOM_QUO IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA(req) = request->get_form_fields(  ).
    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
    DATA(cookies)  = request->get_cookies(  ) .

    DATA req_host TYPE string.
    DATA req_proto TYPE string.
    DATA req_uri TYPE string.
    DATA json TYPE string .

    req_host = request->get_header_field( i_name = 'Host' ).
    req_proto = request->get_header_field( i_name = 'X-Forwarded-Proto' ).

*    DATA(printname) = VALUE #( req[ name = 'print' ]-value OPTIONAL ).
*    DATA(cc) = request->get_form_field( `companycode` ).
    DATA(salesdoc) = request->get_form_field( `salesquotation` ).
*    DATA(getdocument) = VALUE #( req[ name = 'doc' ]-value OPTIONAL ).
*    DATA(getcompanycode) = VALUE #( req[ name = 'cc' ]-value OPTIONAL ).


    CASE request->get_method( ).

      WHEN CONV string( if_web_http_client=>get ).

      WHEN CONV string( if_web_http_client=>post ).


        SELECT SINGLE
        FROM i_salesquotation AS a
        FIELDS
        a~SalesQuotation
        WHERE a~SalesQuotation = @salesdoc
        INTO @DATA(lv_quotation).

        IF lv_quotation IS NOT INITIAL.

          TRY.
              DATA(pdf) = zcl_domestic_quotation_drv=>read_posts( saleQuotNo = salesdoc ) .
              IF  pdf = 'ERROR'.
                response->set_text( 'Error to show PDF something Problem' ).
              ELSE.
                DATA(html) = |<html> | &&
                               |<body> | &&
                                 | <iframe src="data:application/pdf;base64,{ pdf }" width="100%" height="100%"></iframe>| &&

                               | </body> | &&
                             | </html>|.

                response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
                response->set_text( pdf ).
              ENDIF.
            CATCH cx_static_check INTO DATA(er).
              response->set_text( er->get_longtext(  ) ).
          ENDTRY.
        ELSE.
          response->set_text( 'Invoice No does not exist.' ).
        ENDIF.

    ENDCASE.


  ENDMETHOD.
ENDCLASS.
