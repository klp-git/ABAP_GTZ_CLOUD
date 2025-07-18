CLASS zcl_http_eway_gen DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .

         CLASS-METHODS getDate
      IMPORTING datestr       TYPE string
      RETURNING VALUE(result) TYPE d.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_EWAY_GEN IMPLEMENTATION.


    METHOD getDate.
    DATA: lv_date_str   TYPE string.

    " Convert DD/MM/YYYY to YYYYMMDD
    " Extract date part (first 10 characters)
    lv_date_str = datestr(10).

    " Convert to ABAP date format (YYYYMMDD)
    REPLACE ALL OCCURRENCES OF '-' IN lv_date_str WITH ''.
    result = lv_date_str.

  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.
    DATA(req1) = request->get_form_fields(  ).
    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
    DATA(cookies)  = request->get_cookies(  ) .

    DATA(getdocument) = VALUE #( req1[ name = 'doc' ]-value OPTIONAL ).
    DATA(getcompanycode) = VALUE #( req1[ name = 'cc' ]-value OPTIONAL ).
    DATA(getdistance) = VALUE #( req1[ name = 'dist' ]-value OPTIONAL ).
    DATA(getvehicle) = VALUE #( req1[ name = 'veh' ]-value OPTIONAL ).

    CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>get ).
        DATA: wa_zirn1 TYPE ztable_irn.
*
        SELECT SINGLE * FROM ztable_irn AS a
        WHERE a~billingdocno = @getdocument AND
        a~bukrs = @getcompanycode
        INTO @DATA(lv_table_data1).

        wa_zirn1 = lv_table_data1.

        wa_zirn1-vehiclenum = getvehicle.
        wa_zirn1-distance = getdistance.

        MODIFY ztable_irn FROM @wa_zirn1.
        IF sy-subrc EQ 0.
          response->set_text( '1' ).
        ENDIF.
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
        WHERE a~intgmodule = 'Generate_Eway_bill'
        INTO @DATA(lv_int_eway).

*        irn_url = 'https://apimsapintegration.azure-api.net/api/v1/ewayBillsGenerate/' .
        irn_url = lv_int_eway-intgpath .


        TRY.
            DATA(dest2) = cl_http_destination_provider=>create_by_url( irn_url ).
            lv_client2 = cl_web_http_client_manager=>create_by_http_destination( dest2 ).

          CATCH cx_static_check INTO DATA(lv_cx_static_check2).
            response->set_text( lv_cx_static_check2->get_longtext( ) ).
        ENDTRY.
*        TYPES: BEGIN OF ty_json,
*                 companycode TYPE string,
*                 document    TYPE string,
*               END OF ty_json.
        DATA: companycode TYPE string.
        DATA: document    TYPE string.

*        DATA: lv_json1 TYPE ty_json.

*        CALL METHOD /ui2/cl_json=>deserialize
*          EXPORTING
*            json = request->get_text( )
*          CHANGING
*            data = lv_json1.

        DATA: lv_bukrs TYPE ztable_irn-bukrs.
        DATA: lv_invoice TYPE ztable_irn-billingdocno.
        lv_bukrs = request->get_form_field( `companycode` ).
        lv_invoice = request->get_form_field( `document` ).
*
        DATA(get_payload) = zcl_eway_generation=>generated_eway_bill( companycode = lv_bukrs invoice = lv_invoice ).
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
*            FIND to_upper( 'code' ) IN url_response2 MATCH OFFSET DATA(lv_index).
            DATA: lv_code TYPE string.

*            FIND REGEX '"code":\s*"(\d+)"' IN url_response2 SUBMATCHES lv_code.
            FIND 'code' IN url_response2 MATCH OFFSET DATA(lv_index).
            lv_index = lv_index + 6.
            lv_code = url_response2+lv_index(3).


*            lv_index = lv_index + 7.
*            lv_code = url_response2+lv_index(3).


            TYPES: BEGIN OF ty_message,
                     ewayBillNo   TYPE string,
                     ewayBillDate TYPE string,
                     validUpto    TYPE string,
                     alert        TYPE string,
                     error        TYPE string,
                     url          TYPE string,
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

              wa_zirn-ewaybillno = lv_message2-results-message-ewaybillno.
              wa_zirn-ewaydate = lv_message2-results-message-ewaybilldate.
              wa_zirn-ewayvaliddate = lv_message2-results-message-validupto.
              wa_zirn-ewaystatus = 'GEN'.

              MODIFY ztable_irn FROM @wa_zirn.

            ENDIF.

*            DATA(json_str) = url_response2.
*            DATA(json_result) = xco_cp_json=>read( url_response2 ).

            response->set_text( url_response2 ).


          CATCH cx_web_http_client_error INTO DATA(lv_error_response2).
            response->set_text( lv_error_response2->get_longtext( ) ).
        ENDTRY.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
