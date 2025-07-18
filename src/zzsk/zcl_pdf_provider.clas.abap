CLASS zcl_pdf_provider DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
    DATA : lv_vbeln TYPE vbeln.
    DATA lo_http_destination TYPE REF TO if_http_destination.
    DATA lo_http_client     TYPE REF TO if_web_http_client.
    DATA lo_http_response   TYPE REF TO if_web_http_response.
  PRIVATE SECTION.

ENDCLASS.



CLASS ZCL_PDF_PROVIDER IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

  ENDMETHOD.
ENDCLASS.
