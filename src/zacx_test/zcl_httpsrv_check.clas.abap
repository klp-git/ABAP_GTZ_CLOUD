CLASS zcl_httpsrv_check DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTPSRV_CHECK IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.


    DATA(req) = request->get_form_fields(  ).
    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
    DATA(cookies)  = request->get_cookies(  ) .
*data(cache)  = request->get_cookies(  ) .

    DATA(housebank)    = VALUE #( req[ name = 'housebank' ]-value OPTIONAL ) .


*    DATA(pdf1)   = zcl_render_pdf_exec=>read_posts( housebank = housebank )  .
*    response->set_text( pdf1 ).




  ENDMETHOD.
ENDCLASS.
