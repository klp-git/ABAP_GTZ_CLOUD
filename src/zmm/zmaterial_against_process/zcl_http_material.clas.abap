CLASS ZCL_HTTP_Material DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS: get_html RETURNING VALUE(html) TYPE string.
    METHODS: post_html
      IMPORTING
                process_no     TYPE string
                mat_no         Type string
      RETURNING VALUE(html) TYPE string.

    CLASS-DATA url TYPE string.
ENDCLASS.



CLASS ZCL_HTTP_MATERIAL IMPLEMENTATION.


  METHOD get_html.    "Response HTML for GET request

    html = |<html> \n| &&
  |<body> \n| &&
  |<title>Issue To Shopkeeper</title> \n| &&
  |<form action="/sap/bc/http/sap/ZHTTP_MATERIAL" method="POST">\n| &&
  |<H2>Material Consumption</H2> \n| &&
  |<label for="fname">Process Order No:  </label> \n| &&
  |<input type="text" id="process_no" name="process_no" required ><br><br> \n| &&
  |<label for="fname">Material Document No:  </label> \n| &&
  |<input type="text" id="mat_no" name="mat_no" required ><br><br> \n| &&
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
    DATA(symandt) = sy-mandt.
    req_uri = '/sap/bc/http/sap/ZHTTP_MATERIAL?sap-client=080'.
    url = |{ req_proto }://{ req_host }{ req_uri }client={ symandt }|.


    CASE request->get_method( ).

      WHEN CONV string( if_web_http_client=>get ).

        response->set_text( get_html( ) ).

      WHEN CONV string( if_web_http_client=>post ).

        DATA(lv_process) = request->get_form_field( `process_no` ).
        DATA(lv_mat) = request->get_form_field( `mat_no` ).

        TYPES: BEGIN OF ty_mat_process,
         MaterialDocument TYPE I_MATERIALDOCUMENTITEM_2-MaterialDocument,
         ProcessOrder     TYPE I_PROCESSORDERTP-ProcessOrder,
       END OF ty_mat_process.

        Data: wa_final TYPE ty_mat_process.

        DATA : var1 TYPE I_PROCESSORDERTP-ProcessOrder.
        DATA : var2 TYPE I_MATERIALDOCUMENTITEM_2-MaterialDocument.
        DATA: lv_process1 TYPE string,
              lv_mat1 type string.


         var1 = lv_process.
         var1 =   |{ |{ var1 ALPHA = OUT }| ALPHA = IN }| .
         lv_process1 = lv_process.
         lv_process1 = var1.

         var2 = lv_mat.
         var2 =   |{ |{ var2 ALPHA = OUT }| ALPHA = IN }| .
         lv_mat1 = lv_mat.
         lv_mat1 = var2.

        SELECT SINGLE FROM I_MATERIALDOCUMENTITEM_2 as a
        FIELDS a~MaterialDocument  WHERE a~MaterialDocument = @lv_mat1
        INTO @DATA(wa_mat).

        SELECT SINGLE FROM I_PROCESSORDERTP as a
        FIELDS a~ProcessOrder  WHERE a~ProcessOrder = @lv_process1
        INTO @DATA(wa_process).

        wa_final-MaterialDocument = wa_mat.
        wa_final-ProcessOrder = wa_process.


        IF wa_final IS NOT INITIAL.

          TRY.
              DATA(pdf) = zcl_driver_material=>read_posts( process_no = lv_process1
                                                     mat_no = lv_mat1 ).
              IF  pdf = 'ERROR'.
                response->set_text( 'Error to show PDF' ).
              ELSE.
*                DATA(html) = |<html> | &&
*                               |<body> | &&
*                                 | <iframe src="data:application/pdf;base64,{ pdf }" width="100%" height="100%"></iframe>| &&
*                               | </body> | &&
*                             | </html>|.

                response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
                response->set_text( pdf ).
              ENDIF.
            CATCH cx_static_check INTO DATA(er).
              response->set_text( er->get_longtext(  ) ).
          ENDTRY.
        ELSE.
          response->set_text( 'Document No does not exist.' ).
        ENDIF.
    ENDCASE.

  ENDMETHOD.


  METHOD post_html.

    html = |<html> \n| &&
   |<body> \n| &&
   |<title>Material Consumption</title> \n| &&
   |<form action="/sap/bc/http/sap/ZHTTP_MATERIAL" method="Get">\n| &&
   |<H2>Issue To Shopkeeper Print Success </H2> \n| &&
   |<input type="submit" value="Go Back"> \n| &&
   |</form> | &&
   |</body> \n| &&
   |</html> | .
  ENDMETHOD.
ENDCLASS.
