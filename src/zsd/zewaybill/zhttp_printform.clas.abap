CLASS zhttp_printform DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA url TYPE string.
ENDCLASS.



CLASS ZHTTP_PRINTFORM IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA(req) = request->get_form_fields(  ).
    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
    DATA(cookies)  = request->get_cookies(  ) .

    DATA req_host TYPE string.
    DATA req_proto TYPE string.
    DATA req_uri TYPE string.
    DATA json TYPE string .

    req_host = request->get_header_field( i_name = 'Host' ).
    req_proto = request->get_header_field( i_name = 'X-Forwarded-Proto' ).
    IF req_proto IS INITIAL.
      req_proto = 'https'.
    ENDIF.
*     req_uri = request->get_request_uri( ).
    DATA(symandt) = sy-mandt.
    req_uri = '/sap/bc/http/sap/ZHTTP_SERVICE?sap-client=080'.
    url = |{ req_proto }://{ req_host }{ req_uri }client={ symandt }|.
    DATA(printname) = VALUE #( req[ name = 'print' ]-value OPTIONAL ).
    DATA(cc) = request->get_form_field( `companycode` ).
    DATA(doc) = request->get_form_field( `document` ).
    DATA(getdocument) = VALUE #( req[ name = 'doc' ]-value OPTIONAL ).
    DATA(getcompanycode) = VALUE #( req[ name = 'cc' ]-value OPTIONAL ).


    CASE request->get_method( ).

      WHEN CONV string( if_web_http_client=>get ).
        IF printname = 'dom' OR printname = 'sto' OR printname = 'expo' OR printname = 'foc' OR printname = 'ss'.
          SELECT SINGLE FROM I_BillingDocument AS a
                    FIELDS a~DistributionChannel,a~BillingDocumentType
                    WHERE a~BillingDocument = @getdocument AND a~CompanyCode = @getcompanycode
                    INTO @DATA(wa_check) PRIVILEGED ACCESS.
          DATA: getresult TYPE string.
          getresult = wa_check-DistributionChannel.
        ENDIF.
        IF printname = 'cndn' OR printname = 'rm'.
          SELECT SINGLE FROM I_BillingDocument AS a
                      FIELDS a~DistributionChannel,a~BillingDocumentType
                      WHERE a~BillingDocument = @getdocument AND a~CompanyCode = @getcompanycode
                      INTO @wa_check PRIVILEGED ACCESS.
          getresult = wa_check-BillingDocumentType.
        ENDIF.

        response->set_text( getresult ).

      WHEN CONV string( if_web_http_client=>post ).


        SELECT SINGLE * FROM I_BillingDocument AS a
        WHERE a~BillingDocument = @doc AND a~CompanyCode = @cc
        INTO @DATA(lv_invoice) PRIVILEGED ACCESS.

        IF lv_invoice IS NOT INITIAL.

          TRY.
              IF printname = 'dom'.
                DATA(pdf) = zcl_http_dom_tax_print=>read_posts( bill_doc = doc ) .
*                DATA(pdf) = zcl_printform_driver_program=>read_posts( bill_doc = doc printname = printname ) .
              ENDIF.
              IF printname = 'sto'.
                pdf = zcl_sto_tax_inv_dr=>read_posts( bill_doc = doc ) .
*                DATA(pdf) = zcl_sd_driver_program=>read_posts( bill_doc = doc printname = printname ) .
              ENDIF.

              IF printname = 'expo'.
                pdf = zcl_exp_tax_inv_dr=>read_posts( bill_doc = doc ) .
*                pdf = zcl_printform_driver_program=>read_posts( bill_doc = doc printname = printname ) .
              ENDIF.

              IF printname = 'foc'.
                pdf = zcl_foc_tax_inv_dr=>read_posts( bill_doc = doc ) .
*                pdf = zcl_printform_driver_program=>read_posts( bill_doc = doc printname = printname ) .
              ENDIF.
              IF printname = 'rm'.
                pdf = zcl_driver_purchase_return=>read_posts( bill_doc = doc ) .
*                DATA(pdf) = zcl_sd_driver_program=>read_posts( bill_doc = doc printname = printname ) .
              ENDIF.
              IF printname = 'ss'.
                pdf = zcl_service_sale_drv=>read_posts( bill_doc = doc ) .
*                pdf = zcl_printform_driver_program=>read_posts( bill_doc = doc printname = printname ) .

              ENDIF.

              IF printname = 'batch'.
                pdf = zcl_tax_batch=>read_posts( cleardoc = doc ) .
              ENDIF.
              IF printname = 'focexport'.
                pdf = zcl_foc_exp_drv=>read_posts( bill_doc = doc ) .
              ENDIF.

              IF printname = 'cndn'.
*                SELECT SINGLE FROM i_billingdocument AS a
*                FIELDS a~FiscalYear,a~AccountingDocument
*                WHERE a~BillingDocument = @doc AND a~CompanyCode = @cc
*                INTO @DATA(wa_doc).
*
*                SELECT SINGLE FROM i_accountingdocumentjournal WITH PRIVILEGED ACCESS AS a
*                 FIELDS accountingdocument WHERE a~accountingdocument = @wa_doc-AccountingDocument AND a~FiscalYear = @wa_doc-FiscalYear AND a~CompanyCode = @cc
*                 INTO @DATA(lv_ac).
*
*                DATA: ac TYPE string.
*                DATA: fs TYPE string.
*                ac = wa_doc-AccountingDocument.
*                fs = wa_doc-FiscalYear.
                pdf = zcl_ficndn_inv=>read_posts( bill_doc = doc ) .
*                DATA(pdf) = zcl_sd_driver_program=>read_posts( bill_doc = doc printname = printname ) .
              ENDIF.

              IF  pdf = 'ERROR'.
                response->set_text( 'Error to show PDF something Problem' ).

*            response->set_text( pdf ).
              ELSE.
                DATA(html) = |<html> | &&
                               |<body> | &&
                                 | <iframe src="data:application/pdf;base64,{ pdf }" width="100%" height="100%"></iframe>| &&

                               | </body> | &&
                             | </html>|.

                response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
                response->set_text( pdf ).
              ENDIF.
            CATCH cx_static_check INTO DATA(er).
              response->set_text( er->get_longtext(  ) ).
          ENDTRY.
        ELSE.
          response->set_text( 'Invoice No does not exist.' ).
        ENDIF.

    ENDCASE.


  ENDMETHOD.
ENDCLASS.
