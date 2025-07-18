CLASS zcl_http_delete DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_DELETE IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>delete ).
        TYPES: BEGIN OF ty_json,
                 companycode TYPE string,
                 document    TYPE string,
               END OF ty_json.

        DATA: lv_json1 TYPE ty_json.

        CALL METHOD /ui2/cl_json=>deserialize
          EXPORTING
            json = request->get_text( )
          CHANGING
            data = lv_json1.
        DATA: lv_bukrs TYPE ztable_irn-bukrs.
        DATA: lv_invoice TYPE ztable_irn-billingdocno.
        lv_bukrs = lv_json1-companycode.
        lv_invoice = lv_json1-document.

        DELETE FROM ztable_irn WHERE bukrs = @lv_bukrs and billingdocno = @lv_invoice.
        response->set_text( '1' ).
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
