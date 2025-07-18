CLASS zcl_http_sk4 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension . "Standard Interface
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS ZCL_HTTP_SK4 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request. "Standard Method Which Handles the HTTP request
    response->set_text( 'Hello' ).
  ENDMETHOD.
ENDCLASS.
