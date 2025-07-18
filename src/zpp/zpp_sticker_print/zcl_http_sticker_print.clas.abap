CLASS zcl_http_sticker_print DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_STICKER_PRINT IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA(req) = request->get_form_fields(  ).
    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).


    DATA beamno TYPE string.
    DATA orderno TYPE c LENGTH 12.
    DATA orderno1  TYPE c LENGTH 12.
    DATA fromsticker TYPE string.
    DATA tosticker TYPE string.

    beamno = VALUE #( req[ name = 'beamno' ]-value OPTIONAL ) .
    orderno = VALUE #( req[ name = 'orderno' ]-value OPTIONAL ) .
    fromsticker = VALUE #( req[ name = 'fromsticker' ]-value OPTIONAL ) .
    tosticker = VALUE #( req[ name = 'tosticker' ]-value OPTIONAL ) .

    orderno1   =  |{ orderno ALPHA = IN }| .
    DATA(pdf2) = zcl_sticker_print_driver=>read_posts( beamno = beamno orderno = orderno1
                                                   fromsticker  = fromsticker tosticker = tosticker ) .

    response->set_text( pdf2  ).


  ENDMETHOD.
ENDCLASS.
