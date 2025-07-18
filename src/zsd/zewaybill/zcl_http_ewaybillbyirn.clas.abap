CLASS zcl_http_ewaybillbyirn DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_EWAYBILLBYIRN IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>post ).
        DATA irn_url TYPE string.
        DATA lv_client2 TYPE REF TO if_web_http_client.
        SELECT SINGLE FROM zintegration
       FIELDS Intgpath
       WHERE Intgmodule = 'EWAY-BY-IRN-URL'
       INTO @irn_url.
        TRY.
            DATA(dest2) = cl_http_destination_provider=>create_by_url( irn_url ).
            lv_client2 = cl_web_http_client_manager=>create_by_http_destination( dest2 ).
          CATCH cx_static_check INTO DATA(lv_cx_static_check2).
            response->set_status( i_code = 500 i_reason = 'Internal Server Error' ).
            response->set_text( |Destination creation failed: { lv_cx_static_check2->get_longtext( ) }| ).
            RETURN.
        ENDTRY.
        DATA: lv_bukrs TYPE ztable_irn-bukrs.
        DATA: lv_invoice TYPE ztable_irn-billingdocno.
        DATA: lv_gstno TYPE string.
        TRY.
            lv_bukrs = request->get_form_field( `companycode` ).
            lv_invoice = request->get_form_field( `document` ).

            IF lv_bukrs IS INITIAL OR lv_invoice IS INITIAL.
              response->set_text( 'Company code and document number are required' ).
              RETURN.
            ENDIF.
            DATA(get_payload) = zcl_ewaybillbyirn_generation=>generated_ewaybillbyirn( companycode = lv_bukrs document = lv_invoice ).


            IF get_payload = '1'.
              response->set_text( 'IRN Not Generated.' ).
              RETURN.
            ENDIF.

            SELECT SINGLE FROM I_BillingDocumentItem AS b
                           FIELDS b~Plant, b~BillingDocumentType
                           WHERE b~BillingDocument = @lv_invoice
                           INTO @DATA(lv_document_details) PRIVILEGED ACCESS.

            IF sy-subrc <> 0.
              response->set_text( |Document { lv_invoice } not found| ).
              RETURN.
            ENDIF.

            SELECT SINGLE FROM ztable_plant
                   FIELDS gstin_no
                   WHERE comp_code = @lv_bukrs AND plant_code = @lv_document_details-Plant
                   INTO @DATA(userPass).
            IF userPass IS INITIAL.
              response->set_status( i_code = 404 i_reason = 'Not Found' ).
              response->set_text( |GSTIN not found for company { lv_bukrs } and plant { lv_document_details-Plant }| ).
              RETURN.
            ENDIF.
        DATA(req4) = lv_client2->get_http_request( ).


        SELECT SINGLE FROM zintegration
            FIELDS intgpath
            WHERE Intgmodule = 'APIM_SECRETKEY'
            INTO @DATA(head1name).

            SELECT SINGLE FROM zintegration
            FIELDS Intgpath
            WHERE Intgmodule = 'APIM_SECRETVAL'
            INTO @DATA(subscriptionValue).

            DATA : name1 TYPE string.
            name1 = head1name.

            DATA : subscription TYPE string.
            subscription = subscriptionvalue.


            req4->set_header_field(
             i_name  = name1
             i_value = subscription
           ).

            req4->set_header_field(
              i_name  = 'gstin'
              i_value = CONV string( userPass )
            ).
       req4->append_text( EXPORTING data = get_payload ).
            req4->set_content_type( 'application/json' ).
            DATA url_response2 TYPE string.
    TRY.
                url_response2 = lv_client2->execute( if_web_http_client=>post )->get_text( ).

                TYPES: BEGIN OF errorDetails,
                         error_code    TYPE string,
                         error_message TYPE string,
                         error_source  TYPE string,
                       END OF errorDetails.

                TYPES: BEGIN OF ty_message,
                         EwbNo        TYPE string,
                         EwbDt        TYPE string,
                         EwbValidTill TYPE string,
                       END OF ty_message.

                TYPES: BEGIN OF success,
                         Success TYPE string,
                       END OF success.


                TYPES: BEGIN OF gvtres1,
                         govt_response TYPE success,
                       END OF gvtres1.

                DATA checkRes TYPE TABLE OF gvtres1.

                xco_cp_json=>data->from_string( url_response2 )->write_to( REF #( checkRes ) ).

                LOOP AT checkRes INTO DATA(Res).

                  IF Res-govt_response-success = 'N'.

                    TYPES: BEGIN OF errors,
                             ErrorDetails TYPE TABLE OF errorDetails WITH EMPTY KEY,
                           END OF errors.
                    TYPES: BEGIN OF gvtres2,
                             govt_response TYPE errors,
                           END OF gvtres2.

                    DATA ErrorRes TYPE TABLE OF gvtres2.

                    xco_cp_json=>data->from_string( url_response2 )->write_to( REF #( ErrorRes ) ).

                    LOOP AT ErrorRes INTO DATA(wa_error).
                      LOOP AT wa_error-govt_response-errordetails INTO DATA(lv_errors).
                        response->set_text( lv_errors-error_message ).
                        RETURN.
                      ENDLOOP.
                    ENDLOOP.
                  ELSE.

                    TYPES: BEGIN OF gvtres3,
                             govt_response TYPE ty_message,
                           END OF gvtres3.

                    DATA OkRes TYPE TABLE OF gvtres3.

                    xco_cp_json=>data->from_string( url_response2 )->write_to( REF #( OkRes ) ).

                    LOOP AT OkRes INTO DATA(wa_ok).
                      DATA: wa_zirn TYPE ztable_irn.
                      SELECT SINGLE * FROM ztable_irn AS a
                         WHERE a~billingdocno = @lv_invoice AND
                         a~bukrs = @lv_bukrs
                         INTO @DATA(lv_table_data).

                      wa_zirn = lv_table_data.
                      wa_zirn-ewaybillno = wa_ok-govt_response-ewbno.
                      wa_zirn-ewaydate =  wa_ok-govt_response-ewbdt .
                      wa_zirn-ewayvaliddate = zcl_http_eway_gen=>getdate( wa_ok-govt_response-ewbvalidtill ).
                      wa_zirn-ewaycreatedby = sy-mandt.
                      wa_zirn-ewaystatus = 'GEN'.
                      MODIFY ztable_irn FROM @wa_zirn.

                      response->set_text( | Eway Bill Generated Successfully { wa_ok-govt_response-ewbno } for Document - { lv_invoice }  | ).
                      RETURN.
                    ENDLOOP.
                  ENDIF.
                ENDLOOP.
              CATCH cx_web_http_client_error INTO DATA(lv_error_response2).
                response->set_status( i_code = 500 i_reason = 'Internal Server Error' ).
                response->set_text( |API request failed: { lv_error_response2->get_longtext( ) }| ).
            ENDTRY.
          CATCH cx_root INTO DATA(lv_general_error).
            response->set_status( i_code = 500 i_reason = 'Internal Server Error' ).
            response->set_text( |Processing failed: { lv_general_error->get_longtext( ) }| ).
        ENDTRY.
*       try.
*       lv_bukrs = request
*       ENDTRY.

*        DATA token_url TYPE string .
*        DATA lv_token TYPE string.
*        DATA lv_client TYPE REF TO if_web_http_client.
*        DATA req TYPE REF TO if_web_http_client.
*        DATA irn_url TYPE string .
*        DATA lv_client2 TYPE REF TO if_web_http_client.
*        DATA req3 TYPE REF TO if_web_http_client.
*        irn_url = 'https://apimsapintegration.azure-api.net/api/v1/gen-ewb-by-irn/' .


*        TRY.
*            DATA(dest2) = cl_http_destination_provider=>create_by_url( irn_url ).
*            lv_client2 = cl_web_http_client_manager=>create_by_http_destination( dest2 ).
*
*          CATCH cx_static_check INTO DATA(lv_cx_static_check2).
*            response->set_text( lv_cx_static_check2->get_longtext( ) ).
*        ENDTRY.
*        TYPES: BEGIN OF ty_json,
*                 companycode TYPE string,
*                 document    TYPE string,
*               END OF ty_json.

*        DATA: lv_json1 TYPE ty_json.
*
*        CALL METHOD /ui2/cl_json=>deserialize
*          EXPORTING
*            json = request->get_text( )
*          CHANGING
*            data = lv_json1.

*        DATA: lv_bukrs TYPE ztable_irn-bukrs.
*        DATA: lv_invoice TYPE ztable_irn-billingdocno.
*        lv_bukrs = lv_json1-companycode.
*        lv_invoice = lv_json1-document.
**
*        DATA(get_payload) = zcl_ewaybillbyirn_generation=>generated_ewaybillbyirn( companycode = lv_bukrs document = lv_invoice ).
*
*
*        DATA(req4) = lv_client2->get_http_request( ).

*        req4->set_header_field(
*          EXPORTING
*            i_name  = 'Ocp-Apim-Subscription-Key'
*            i_value = '801c1e52d4c642428fcabfe4fd4661f3'
*
*        ).
*        req4->append_text( EXPORTING data = get_payload ).
*        req4->set_content_type( 'application/json' ).
*        DATA url_response2 TYPE string.

*        TRY.
*            url_response2 = lv_client2->execute( if_web_http_client=>post )->get_text( ).
*
*            TYPES: BEGIN OF ty_message,
*                     ewbno        TYPE string,
*                     ewbdt        TYPE string,
*                     ewbvalidtill TYPE string,
*                   END OF ty_message.
*
*            TYPES: BEGIN OF ty_message2,
*                     message TYPE ty_message,
*                     status  TYPE string,
*                   END OF ty_message2.
*
*
*
*            TYPES: BEGIN OF ty_message3,
*                     results TYPE ty_message2,
*                   END OF ty_message3.
*
*            DATA lv_message TYPE ty_message3.
*
*            xco_cp_json=>data->from_string( url_response2 )->write_to( REF #( lv_message ) ).
*
*            DATA: wa_zewaybillbyirn TYPE ztable_irn.
*
*            SELECT SINGLE * FROM ztable_irn AS a
*            WHERE a~billingdocno = @lv_invoice AND
*            a~bukrs = @lv_bukrs
*            INTO @DATA(lv_table_data).
*
*            wa_zewaybillbyirn = lv_table_data.
*            wa_zewaybillbyirn-ewaybillno = lv_message-results-message-ewbno.
*            wa_zewaybillbyirn-ewaydate = lv_message-results-message-ewbdt.
*            wa_zewaybillbyirn-ewayvaliddate = lv_message-results-message-ewbvalidtill.
*            wa_zewaybillbyirn-ewaystatus = 'GEN'.
*
*
*            MODIFY ztable_irn FROM @wa_zewaybillbyirn.

*            response->set_text( lv_message-results-message-ewbno ).
*
*
*          CATCH cx_web_http_client_error INTO DATA(lv_error_response2).
*            response->set_text( lv_error_response2->get_longtext( ) ).
*        ENDTRY.
    WHEN OTHERS.
        response->set_status( i_code = 405 i_reason = 'Method Not Allowed' ).
        response->set_text( 'Only POST method is supported' ).
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
