CLASS zcl_http_cancleewb DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .

    CLASS-METHODS :getPayload IMPORTING
                                        invoice       TYPE ztable_irn-billingdocno
                                        companycode   TYPE ztable_irn-bukrs
                              RETURNING VALUE(result) TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_CANCLEEWB IMPLEMENTATION.


  METHOD getPayload.


    TYPES: BEGIN OF ty_item_list,
             userGstin        TYPE string,
             eway_bill_number TYPE string,
             reason_of_cancel TYPE string,
             cancel_remark    TYPE string,
             data_source      TYPE string,
           END OF ty_item_list.

    DATA : wa_json TYPE ty_item_list.

    SELECT SINGLE FROM ztable_irn AS a
    FIELDS a~ewaybillno
     WHERE a~billingdocno = @invoice AND
     a~bukrs = @companycode
     INTO @DATA(lv_table_data).

    SELECT SINGLE FROM
   i_billingdocumentitem AS a LEFT JOIN
   ztable_plant AS b ON a~Plant = b~plant_code
   FIELDS
   b~gstin_no
   WHERE a~BillingDocument = @invoice AND a~CompanyCode = @companycode
   INTO @DATA(lv_user_gstin).

*    IF lv_table_data = ''.
*      result = '1'.
*      RETURN.
*    ENDIF.

    wa_json-userGstin = lv_user_gstin.
    wa_json-eway_bill_number = lv_table_data.
    wa_json-reason_of_cancel = 'Others'.
    wa_json-cancel_remark = 'Cancelled the order'.
    wa_json-data_source = 'erp'.


    DATA:json TYPE REF TO if_xco_cp_json_data.

    xco_cp_json=>data->from_abap(
      EXPORTING
        ia_abap      = wa_json
      RECEIVING
        ro_json_data = json   ).
    json->to_string(
      RECEIVING
        rv_string =   DATA(lv_string) ).

    REPLACE ALL OCCURRENCES OF '"USERGSTIN"' IN lv_string WITH '"userGstin"'.
    REPLACE ALL OCCURRENCES OF '"EWAY_BILL_NUMBER"' IN lv_string WITH '"eway_bill_number"'.
    REPLACE ALL OCCURRENCES OF '"REASON_OF_CANCEL"' IN lv_string WITH '"reason_of_cancel"'.
    REPLACE ALL OCCURRENCES OF '"CANCEL_REMARK"' IN lv_string WITH '"cancel_remark"'.
    REPLACE ALL OCCURRENCES OF '"DATA_SOURCE"' IN lv_string WITH '"data_source"'.

    result = lv_string.

  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.
    CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>post ).
        DATA irn_url TYPE string.
        DATA lv_client2 TYPE REF TO if_web_http_client.

        SELECT SINGLE FROM zintegration
           FIELDS Intgpath
           WHERE Intgmodule = 'EWB-CANCEL-URL'
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


            SELECT SINGLE FROM ztable_irn AS a
          FIELDS a~ewaybillno
             WHERE a~billingdocno = @lv_invoice AND
             a~bukrs = @lv_bukrs
             INTO @DATA(lv_table_data1).

            IF lv_bukrs IS INITIAL OR lv_invoice IS INITIAL.
              response->set_text( 'Company code and document number are required' ).
              RETURN.
            ELSEIF lv_table_data1 IS INITIAL.
              response->set_text( 'EWB Not Generated' ).
              RETURN.
            ENDIF.

            DATA(get_payload) = getpayload( companycode = lv_bukrs invoice = lv_invoice ).
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
*
*            req4->set_header_field(
*              i_name  = 'gstin'
*              i_value = CONV string( userPass )
*            ).
            req4->append_text( EXPORTING data = get_payload ).
            req4->set_content_type( 'application/json' ).
            DATA url_response2 TYPE string.
            TRY.
                url_response2 = lv_client2->execute( if_web_http_client=>post )->get_text( ).

*            TRANSLATE url_response2 TO UPPER CASE.
*            FIND to_upper( 'code' ) IN url_response2 MATCH OFFSET DATA(lv_index).
                DATA: lv_code TYPE string.

*            FIND REGEX '"code":\s*"(\d+)"' IN url_response2 SUBMATCHES lv_code.
                FIND 'code' IN url_response2 MATCH OFFSET DATA(lv_index).
                lv_index = lv_index + 6.
                lv_code = url_response2+lv_index(3).


*            lv_index = lv_index + 7.
*            lv_code = url_response2+lv_index(3).


                TYPES: BEGIN OF ty_message,
                         ewayBillNo TYPE string,
                         CancelDate TYPE string,
                         error      TYPE string,
                       END OF ty_message.

                TYPES: BEGIN OF ty_message2,
                         message TYPE string,
                         status  TYPE string,
                         code    TYPE string,
                       END OF ty_message2.

                TYPES: BEGIN OF ty_message4,
                         message TYPE ty_message,
                         status  TYPE string,
                         code    TYPE string,
                       END OF ty_message4.

                TYPES: BEGIN OF ty_message5,
                         results TYPE ty_message4,
                       END OF ty_message5.


                TYPES: BEGIN OF ty_message3,
                         results TYPE ty_message2,
                       END OF ty_message3.

                DATA lv_message TYPE ty_message3.
                DATA lv_message2 TYPE ty_message5.

                IF lv_code = '204'.
                  xco_cp_json=>data->from_string( url_response2 )->write_to( REF #( lv_message ) ).
                ENDIF.
                IF lv_code = '200'.
                  xco_cp_json=>data->from_string( url_response2 )->write_to( REF #( lv_message2 ) ).
                  DATA: wa_zirn TYPE ztable_irn.
*
                  SELECT SINGLE * FROM ztable_irn AS a
                  WHERE a~billingdocno = @lv_invoice AND
                  a~bukrs = @lv_bukrs
                  INTO @DATA(lv_table_data).

                  wa_zirn = lv_table_data.
                  wa_zirn-ewaybillno = ''.
                  wa_zirn-ewaydate = ''.
                  wa_zirn-ewaycanceldate = sy-datum.
                  wa_zirn-ewayvaliddate = ''.
                  wa_zirn-ewaycreatedby  = ''.
                  wa_zirn-ewaystatus = 'CNL'.

                  MODIFY ztable_irn FROM @wa_zirn.
                ENDIF.

*            DATA(json_str) = url_response2.
*            DATA(json_result) = xco_cp_json=>read( url_response2 ).

                response->set_text( url_response2 ).


              CATCH cx_web_http_client_error INTO DATA(lv_error_response2).
                response->set_text( lv_error_response2->get_longtext( ) ).
            ENDTRY.

*            TRY.
*                url_response2 = lv_client2->execute( if_web_http_client=>post )->get_text( ).
*
*                TYPES: BEGIN OF errorDetails,
*                         error_code    TYPE string,
*                         error_message TYPE string,
*                         error_source  TYPE string,
*                       END OF errorDetails.
*
*                TYPES: BEGIN OF govt_res1,
*                         errorDetails TYPE  errorDetails,
*                       END OF govt_res1.
*
*                TYPES: BEGIN OF mainres,
*                         irn       TYPE  string,
*                         ewbStatus TYPE string,
*                       END OF mainres.
*
*
*                DATA lv_message TYPE mainres.
*                DATA lv_message2 TYPE govt_res1.
*
*                xco_cp_json=>data->from_string( url_response2 )->write_to( REF #( lv_message ) ).
*
*                IF lv_message-ewbstatus = 'CANCELLED'.
*
*                  DATA: wa_zirn TYPE ztable_irn.
*                  SELECT SINGLE * FROM ztable_irn AS a
*                     WHERE a~billingdocno = @lv_invoice AND
*                     a~bukrs = @lv_bukrs
*                     INTO @DATA(lv_table_data).
*
*                  wa_zirn = lv_table_data.
*                  wa_zirn-ewaybillno = ''.
*                  wa_zirn-ewaydate = '00010101'.
*                  wa_zirn-ewaycanceldate = sy-datum.
*                  wa_zirn-ewayvaliddate = '00010101'.
*                  wa_zirn-ewaycreatedby  = ''.
*                  wa_zirn-ewaystatus = 'CNL'.
*                  MODIFY ztable_irn FROM @wa_zirn.
*
*                  response->set_text( |EWB Cancelled| ).
*                  RETURN.
*                ENDIF.
*
*                xco_cp_json=>data->from_string( url_response2 )->write_to( REF #( lv_message2 ) ).
*                response->set_text( lv_message2-errordetails-error_message ).
*              CATCH cx_web_http_client_error INTO DATA(lv_error_response2).
*                response->set_status( i_code = 500 i_reason = 'Internal Server Error' ).
*                response->set_text( |API request failed: { lv_error_response2->get_longtext( ) }| ).
*            ENDTRY.
          CATCH cx_root INTO DATA(lv_general_error).
            response->set_status( i_code = 500 i_reason = 'Internal Server Error' ).
            response->set_text( |Processing failed: { lv_general_error->get_longtext( ) }| ).
        ENDTRY.
      WHEN OTHERS.
        response->set_status( i_code = 405 i_reason = 'Method Not Allowed' ).
        response->set_text( 'Only POST method is supported' ).

    ENDCASE.
  ENDMETHOD.
ENDCLASS.
