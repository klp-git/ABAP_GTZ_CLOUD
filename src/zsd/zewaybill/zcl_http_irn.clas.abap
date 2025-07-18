CLASS zcl_http_irn DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_IRN IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>post ).
        DATA token_url TYPE string .
        DATA lv_token TYPE string.
        DATA lv_client TYPE REF TO if_web_http_client.
        DATA req TYPE REF TO if_web_http_client.
        DATA irn_url TYPE string .
        DATA lv_client2 TYPE REF TO if_web_http_client.
        DATA req3 TYPE REF TO if_web_http_client.

        SELECT SINGLE FROM
        zintegration AS a
        FIELDS
        a~intgmodule,
        a~intgpath
        WHERE a~intgmodule = 'Generate_Einvoice_IRN'
        INTO @DATA(lv_int_eway).

        irn_url = lv_int_eway-intgpath .


        TRY.
            DATA(dest2) = cl_http_destination_provider=>create_by_url( irn_url ).
            lv_client2 = cl_web_http_client_manager=>create_by_http_destination( dest2 ).

          CATCH cx_static_check INTO DATA(lv_cx_static_check2).
            response->set_text( lv_cx_static_check2->get_longtext( ) ).
        ENDTRY.

        DATA: companycode TYPE string.
        DATA: document    TYPE string.

*        CALL METHOD /ui2/cl_json=>deserialize
*          EXPORTING
*            json = request->get_text( )
*          CHANGING
*            data = lv_json1.

        DATA: lv_bukrs TYPE ztable_irn-bukrs.
        DATA: lv_invoice TYPE ztable_irn-billingdocno.
*        lv_bukrs = lv_json1-companycode.
*        lv_invoice = lv_json1-document.
        lv_bukrs = request->get_form_field( `companycode` ).
        lv_invoice = request->get_form_field( `document` ).


*
        DATA(get_payload) = zcl_irn_generation=>generated_irn( companycode = lv_bukrs document = lv_invoice ).
*
*        response->set_text( get_payload ).

        DATA(req4) = lv_client2->get_http_request( ).

*        lv_token = |JWT { lv_token }|.

        SELECT SINGLE FROM
                zintegration AS a
                FIELDS
                a~intgmodule,
                a~intgpath
                WHERE a~intgmodule = 'APIM_SECRETKEY'
                INTO @DATA(lv_sec_eway).

        SELECT SINGLE FROM
                zintegration AS a
                FIELDS
                a~intgmodule,
                a~intgpath
                WHERE a~intgmodule = 'APIM_SECRETVAL'
                INTO @DATA(lv_key_eway).

        data: lv_sec_eway1 TYPE string.
        lv_sec_eway1 = lv_sec_eway-intgpath.
        data: lv_key_eway1 TYPE string.
        lv_key_eway1 = lv_key_eway-intgpath.

        req4->set_header_field(
          EXPORTING
            i_name  = lv_sec_eway1
            i_value = lv_key_eway1
*      RECEIVING
*        r_value =
        ).
*    CATCH cx_web_message_error.

        req4->append_text( EXPORTING data = get_payload ).
        req4->set_content_type( 'application/json' ).
        DATA url_response2 TYPE string.

        TRY.
            url_response2 = lv_client2->execute( if_web_http_client=>post )->get_text( ).

*            TRANSLATE url_response2 TO UPPER CASE.

            TYPES: BEGIN OF ty_message,
                     ackno  TYPE string,
                     ackdt  TYPE string,
                     irn    TYPE string,
                     status TYPE string,
                     SignedInvoice type string,
                     SignedQRCode type string,
                   END OF ty_message.

            TYPES: BEGIN OF ty_message2,
                     message TYPE ty_message,
                     status  TYPE string,
                   END OF ty_message2.



            TYPES: BEGIN OF ty_message3,
                     results TYPE ty_message2,
                   END OF ty_message3.

            DATA lv_message TYPE ty_message3.

            xco_cp_json=>data->from_string( url_response2 )->write_to( REF #( lv_message ) ).

*            DATA(json_str) = url_response2.
*            DATA(json_result) = xco_cp_json=>read( url_response2 ).
            DATA: wa_zirn TYPE ztable_irn.
*
            SELECT SINGLE * FROM ztable_irn AS a
            WHERE a~billingdocno = @lv_invoice AND
            a~bukrs = @lv_bukrs
            INTO @DATA(lv_table_data).
            wa_zirn = lv_table_data.
            wa_zirn-irnno = lv_message-results-message-irn.
            wa_zirn-ackno = lv_message-results-message-ackno.
            wa_zirn-ackdate = lv_message-results-message-ackdt.
            wa_zirn-irnstatus = 'GEN'.
            wa_zirn-signedinvoice = lv_message-results-message-signedinvoice.
            wa_zirn-signedqrcode = lv_message-results-message-signedqrcode.

            MODIFY ztable_irn FROM @wa_zirn.

*            response->set_text( lv_message-results-message-irn ).
            response->set_text( url_response2 ).


          CATCH cx_web_http_client_error INTO DATA(lv_error_response2).
            response->set_text( lv_error_response2->get_longtext( ) ).
        ENDTRY.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
