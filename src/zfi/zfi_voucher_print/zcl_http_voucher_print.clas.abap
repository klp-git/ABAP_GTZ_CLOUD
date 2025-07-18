CLASS zcl_http_voucher_print DEFINITION

  PUBLIC

  CREATE PUBLIC.


  PUBLIC SECTION.

    INTERFACES if_http_service_extension.
    CLASS-DATA : user_belnr TYPE string.
    CLASS-DATA: var1 TYPE i_operationalacctgdocitem-AccountingDocument.
  PROTECTED SECTION.

  PRIVATE SECTION.
*    METHODS: get_html RETURNING VALUE(ui_html) TYPE string,

    METHODS:  post_html IMPORTING
                                  lv_belnr    TYPE string
                                  lv_company  TYPE string
                                  lv_fiscal   TYPE string
                        RETURNING VALUE(html) TYPE string.
ENDCLASS.



CLASS ZCL_HTTP_VOUCHER_PRINT IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA(req_method) = request->get_method( ).

    CASE req_method.

      WHEN CONV string( if_web_http_client=>get ).

        " Handle GET request

*        response->set_text( get_html( ) ).

      WHEN CONV string( if_web_http_client=>post ).

        " Handle POST request

        DATA(lv_belnr) = request->get_form_field( `belnr` ).
        DATA(lv_fiscal) = request->get_form_field( `fiscal` ).
        DATA(lv_company) = request->get_form_field( `company` ).

        response->set_text( post_html( lv_belnr = lv_belnr lv_fiscal = lv_fiscal lv_company = lv_company ) ).
*         response->set_text( post_html( lv_belnr ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD post_html.

    DATA lv_belnr2 TYPE string.
    DATA lv_fiscal2 TYPE string.
    DATA lv_company2 TYPE string.
    DATA:  var1 TYPE i_operationalacctgdocitem-AccountingDocument.
    var1 = lv_belnr.
    var1   = |{ var1 ALPHA = IN }|.
    user_belnr = lv_belnr.
    user_belnr =  var1.
    lv_fiscal2 = lv_fiscal.
    lv_company2 = lv_company.

    SELECT SINGLE FROM i_operationalacctgdocitem

      FIELDS AccountingDocument

      WHERE AccountingDocument = @user_belnr

      INTO @lv_belnr2.

    IF lv_belnr2 IS NOT INITIAL.

      TRY.

          " Construct HTML response with embedded PDF view

          DATA(pdf_content) = zcl_voucher_print_dr=>read_posts( lv_belnr2 = user_belnr lv_fiscal = lv_fiscal2 lv_company = lv_company2 ).

          html = |{ pdf_content }|.
*           html = |<html><body><iframe src="data:application/pdf;base64,{ pdf_content }" width="100%" height="600px"></iframe></body></html>|.

*              response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
*              response->set_text( pdf ).
        CATCH cx_static_check INTO DATA(er).

          html = |Accounting Document does not exist: { er->get_longtext( ) }|.

      ENDTRY.

    ELSE.

      html = |Accounting Document not found|.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
