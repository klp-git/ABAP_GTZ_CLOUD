CLASS  ZCL_HTTP_FI_CN_DN_SRV  DEFINITION
  PUBLIC

  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_http_service_extension.
*
*    METHODS: get_html RETURNING VALUE(ui_html) TYPE string,
*             post_html IMPORTING accnt TYPE string RETURNING VALUE(html) TYPE string.


  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS: get_html RETURNING VALUE(html) TYPE string.
    METHODS: post_html
      IMPORTING
              accounting_no TYPE string
                fiscal_year type string
                Company_code type string
      RETURNING VALUE(html)  TYPE string.

    CLASS-DATA url TYPE string.

ENDCLASS.



CLASS ZCL_HTTP_FI_CN_DN_SRV IMPLEMENTATION.


 METHOD get_html.    "Response HTML for GET request

    html = |<html> \n| &&
  |<body> \n| &&
  |<title>Accounting No </title> \n| &&
  |<form action="{ url }" method="POST">\n| &&
  |<H2>GTZ Accounting Print</H2> \n| &&
  |<label for="fname">Accounting Document:  </label> \n| &&
  |<input type="text" id="accounting_no" name="accounting_no" required ><br><br> \n| &&
   |<label for="fname">Fiscal Year:  </label> \n| &&
  |<input type="text" id="fiscal_year" name="fiscal_year" required ><br><br> \n| &&
  |<label for="fname">Company Code:  </label> \n| &&
  |<input type="text" id="Company_code" name="Company_code" required ><br><br> \n| &&
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
    DATA json TYPE string .

    req_host = request->get_header_field( i_name = 'Host' ).
    req_proto = request->get_header_field( i_name = 'X-Forwarded-Proto' ).
    IF req_proto IS INITIAL.
      req_proto = 'https'.
    ENDIF.
*     req_uri = request->get_request_uri( ).
    DATA(symandt) = sy-mandt.
    req_uri = '/sap/bc/http/sap/ZHTTP_FI_CN_DN_SRV'.
    url = |{ req_proto }://{ req_host }{ req_uri }client={ symandt }|.


    CASE request->get_method( ).

      WHEN CONV string( if_web_http_client=>get ).

        response->set_text( get_html( ) ).

      WHEN CONV string( if_web_http_client=>post ).

        DATA(ac) = request->get_form_field( `accounting_no` ).
       DATA(fs) = request->get_form_field( `fiscal_year` ).
        DATA(cc) = request->get_form_field( `Company_code` ).

        SELECT single FROM i_accountingdocumentjournal WITH PRIVILEGED ACCESS AS a
        FIELDS accountingdocument WHERE a~accountingdocument = @ac and a~FiscalYear = @fs and a~CompanyCode = @cc
        INTO @DATA(lv_ac).

        IF lv_ac IS NOT INITIAL.

            TRY.
              DATA(pdf) = zcl_cn_dn_drv_CLASS=>read_posts( accounting_no = ac  Company_code = cc fiscal_year = fs ).
    if  pdf = 'ERROR'.
          response->set_text( 'Error to show PDF something Problem' ).

*            response->set_text( pdf ).
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
          response->set_text( 'Accounting number  does not exist.' ).
        ENDIF.
    ENDCASE.

  ENDMETHOD.


  METHOD post_html.

    html = |<html> \n| &&
   |<body> \n| &&
   |<title>Acoounting No</title> \n| &&
   |<form action="{ url }" method="Get">\n| &&
   |<H2>Accounting No Print Success </H2> \n| &&
   |<input type="submit" value="Go Back"> \n| &&
   |</form> | &&
   |</body> \n| &&
   |</html> | .
  ENDMETHOD.
ENDCLASS.
