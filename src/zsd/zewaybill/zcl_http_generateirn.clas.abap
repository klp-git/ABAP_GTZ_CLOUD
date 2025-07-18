CLASS zcl_http_generateirn DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_http_generateirn IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    DATA(req) = request->get_form_fields(  ).
    DATA(body)  = request->get_text(  )  .
*    xco_cp_json=>data->from_string( body )->write_to( REF #( lv_respo ) ).
*    /ui2/cl_json=>deserialize(
*    EXPORTING
*        json = body
*    CHANGING
*        data = lv_respo
*    ).

    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
    DATA(cookies)  = request->get_cookies(  ) .

    DATA req_host TYPE string.
    DATA req_proto TYPE string.
    DATA req_uri TYPE string.
    DATA json TYPE string .

    req_host = request->get_header_field( i_name = 'Host' ).
    req_proto = request->get_header_field( i_name = 'X-Forwarded-Proto' ).
    CASE request->get_method( ).

      WHEN CONV string( if_web_http_client=>get ).

*        response->set_text( get_html( ) ).

      WHEN CONV string( if_web_http_client=>post ).

*        DATA(plant) = lv_respo-plant.
*        DATA(docdate) = lv_respo-docdate.
        DATA: plant   TYPE ztable_irn-plant.
        DATA: docdate TYPE d.
        plant = request->get_form_field( `plant` ).
        docdate = request->get_form_field( `docdate` ).

        SELECT FROM i_billingdocumentitem AS a
        LEFT JOIN i_customer AS b ON a~PayerParty = b~Customer
        LEFT JOIN i_cnsldtndistributionchannelt AS c ON a~DistributionChannel = c~DistributionChannel
        INNER JOIN I_BillingDocument AS d ON a~BillingDocument = d~BillingDocument
        FIELDS
        a~CompanyCode,
        a~BillingDocument,
        a~CreationDate,
        a~Plant,
        a~PayerParty,
        b~CustomerName,
        a~DistributionChannel,
        a~BillingDocumentType,
        c~DistributionChannelName,
        d~documentreferenceid,
        d~AccountingPostingStatus
        WHERE a~Plant = @plant
        AND a~CreationDate = @docdate AND d~BillingDocumentType NOT IN ( 'F8' ) AND
        a~BillingDocument NOT IN ( SELECT billingdocno FROM ztable_irn WHERE billingdocno IS NOT INITIAL )
        INTO TABLE @DATA(lt) PRIVILEGED ACCESS.

        SORT lt BY BillingDocument.
        DELETE ADJACENT DUPLICATES FROM lt COMPARING BillingDocument CompanyCode.

        DATA: wa_zirn TYPE ztable_irn.
        GET TIME STAMP FIELD DATA(lv_timestamp).
        LOOP AT lt INTO DATA(wa).
          IF ( wa-AccountingPostingStatus = 'C' AND wa-BillingDocumentType <> 'JVR' ) OR ( wa-AccountingPostingStatus <> 'C' AND wa-BillingDocumentType = 'JVR' ).
            wa_zirn-Bukrs = wa-CompanyCode.
            wa_zirn-billingdocno = wa-BillingDocument.
            wa_zirn-taxinvoiceno = wa-DocumentReferenceID.
            wa_zirn-billingdate = wa-CreationDate.
            wa_zirn-plant = wa-Plant.
            wa_zirn-Partycode = wa-PayerParty.
            wa_zirn-distributionchannel = wa-DistributionChannel.
            wa_zirn-distributionchanneldiscription = wa-DistributionChannelName.
            wa_zirn-billingdocumenttype = wa-BillingDocumentType.
            wa_zirn-Partyname = wa-CustomerName.
            wa_zirn-Moduletype = 'SALES'.
            wa_zirn-last_changed_at = lv_timestamp.
            MODIFY ztable_irn FROM @wa_zirn.
            CLEAR wa_zirn.
            CLEAR wa.
          ENDIF.
        ENDLOOP.
        response->set_text( '1' ).
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
