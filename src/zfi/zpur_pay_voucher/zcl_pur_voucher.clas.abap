CLASS zcl_pur_voucher DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
    METHODS: get_html RETURNING VALUE(ui_html) TYPE string,
      post_html IMPORTING

                          cleardoc    TYPE string
*      docfiscalyear type string
*      comcode type string
                RETURNING VALUE(html) TYPE string.
    CLASS-DATA url TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PUR_VOUCHER IMPLEMENTATION.


  METHOD get_html.
*
*    ui_html = |<html><head><title>Payment Advice</title></head><body style="margin:0 ;background-color:#495767;">|.
*
*    CONCATENATE ui_html
*                 '<form action="{ url }" method="POST">'
*                 '<label style = "color:white;font-size:17px" for="belnr">Accounting Document</label>'
*                 '<input style="font-size:17px;padding:2px 3px;background:transparent;border:1px solid white;margin:4px;color: white;" type="text" id="cleardoc" name="cleardoc" required>'
*
*                 '<input style="font-size:14px;background-color:#1b8dec;padding:5px 17px;border-radius: 6px;cursor:pointer;border:none;color:white;font-weight:700;" type="submit" value="Print">'
*                 '</form>'
*               '</body></html>' INTO ui_html.
  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.
    "0500000010  0002000004  4500000001 0500000002/3/4 4500000004 0600000004/5
*    DATA(req) = request->get_form_fields(  ).
*    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
*    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
*    DATA(cookies)  = request->get_cookies(  ) .
*
*    DATA req_host TYPE string.
*    DATA req_proto TYPE string.
*    DATA req_uri TYPE string.
*
*    req_host = request->get_header_field( i_name = 'Host' ).
*    req_proto = request->get_header_field( i_name = 'X-Forwarded-Proto' ).
*    IF req_proto IS INITIAL.
*      req_proto = 'https'.
*    ENDIF.
**     req_uri = request->get_request_uri( ).
*    DATA(symandt) = sy-mandt.
*    req_uri = '/sap/bc/http/sap/ZPUR_VOUCHER?sap-client=080'.
*    url = |{ req_proto }://{ req_host }{ req_uri }client={ symandt }|.
*
*    CASE request->get_method( ).
*
*      WHEN CONV string( if_web_http_client=>get ).
*
*        response->set_text( get_html( ) ).
*
*
*      WHEN CONV string( if_web_http_client=>post ).
*        " Handle POST request
*        DATA(cleardoc) =  request->get_form_field( `cleardoc` ).
*
*        SELECT SINGLE FROM I_OperationalAcctgDocItem
*      FIELDS  ClearingAccountingDocument , ClearingDocFiscalYear , CompanyCode
*      WHERE ClearingAccountingDocument = @cleardoc
*      INTO @DATA(lv_ip).
*        IF lv_ip IS NOT INITIAL.
*          TRY.
*              " Construct HTML response with embedded PDF view
*              DATA(pdf_content) = zclass_pu_voucher=>read_posts( cleardoc = cleardoc
**                                                            docfiscalyear = FiscalYear
**                                                            comcode = lv_ip-comcode
*                                                                 ).
*              IF  pdf_content = 'ERROR'.
*                response->set_text( 'Error to show PDF something Problem' ).
*              ELSE.
*                DATA(html) = |<html> | &&
*                               |<body> | &&
*                                 | <iframe src="data:application/pdf;base64,{ pdf_content }" width="100%" height="100%"></iframe>| &&
*                               | </body> | &&
*                             | </html>|.
*                response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
*                response->set_text( pdf_content ).
*              ENDIF.
*            CATCH cx_static_check INTO DATA(er).
*              response->set_text( er->get_longtext(  ) ).
*          ENDTRY.
*        ELSE.
*          response->set_text( 'Acccount Document does not exist.' ).
*        ENDIF.
*
*    ENDCASE.
  ENDMETHOD.


  METHOD post_html.
*
*    html = |<html> \n| &&
*   |<body> \n| &&
*   |<title>Account Document</title> \n| &&
*   |<form action="{ url }" method="Get">\n| &&
*   |<H2>Payment Advice Print Success </H2> \n| &&
*   |<input type="submit" value="Go Back"> \n| &&
*   |</form> | &&
*   |</body> \n| &&
*   |</html> | .
  ENDMETHOD.
ENDCLASS.
