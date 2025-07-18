CLASS zcl_http_get DEFINITION

  PUBLIC

  CREATE PUBLIC.

  PUBLIC SECTION.


    INTERFACES if_http_service_extension.

*    METHODS: post_html IMPORTING lv_data TYPE string RETURNING VALUE(lv_message) TYPE string.
    DATA: lv_json TYPE string.


  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.



CLASS ZCL_HTTP_GET IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA(req_method) = request->get_method( ).

    CASE req_method.

      WHEN CONV string( if_web_http_client=>get ).

        " Handle POST request
        SELECT FROM i_operationalacctgdocitem
               FIELDS AccountingDocument,
                      CompanyCode,
                      FiscalYear,
                      AccountingDocumentItem,
                      AccountingDocumentType,
                      DocumentDate,
                      AmountInTransactionCurrency
               WHERE AccountingDocumentItem = '001'
               INTO TABLE @DATA(it).

        " Check if table has data
        IF it IS NOT INITIAL.
          " Create JSON writer
          DATA(lv_json) = /ui2/cl_json=>serialize(  data = it
                                                    pretty_name = /ui2/cl_json=>pretty_mode-camel_case )    .

        ENDIF.

        response->set_text( lv_json ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
