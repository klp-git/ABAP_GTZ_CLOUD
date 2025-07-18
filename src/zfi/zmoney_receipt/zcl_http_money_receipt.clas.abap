CLASS zcl_http_Money_Receipt DEFINITION

  PUBLIC

  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_http_service_extension.

    METHODS: get_html RETURNING VALUE(ui_html) TYPE string.
      METHODS : post_html

             IMPORTING lv_belnr TYPE string
              lv_company  TYPE string
               lv_fiscal   TYPE string
              RETURNING VALUE(html) TYPE string.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.



CLASS ZCL_HTTP_MONEY_RECEIPT IMPLEMENTATION.


   METHOD get_html.

*     SELECT SINGLE FROM i_operationalacctgdocitem
*        FIELDS AccountingDocument
**        WHERE AccountingDocument = @lv_belnr
*        INTO @DATA(it_belnr).
*
*    DATA count TYPE string.
*
*    count = lines( it ).

     ui_html = |<html><head><title>Money Receipt</title></head><body style="margin:0 ;background-color:#495767;">|.

    CONCATENATE ui_html
                 '<form action="/sap/bc/http/sap/ZCL_HTTP_MONEY_RECEIPT" method="POST">'
                 '<label style = "color:white;font-size:17px" for="belnr">Accounting Document</label>'
                 '<input style="font-size:17px;padding:2px 3px;background:transparent;border:1px solid white;margin:4px;color: white;" type="text" id="belnr" name="belnr" required>'
                 '<input style="font-size:14px;background-color:#1b8dec;padding:5px 17px;border-radius: 6px;cursor:pointer;border:none;color:white;font-weight:700;" type="submit" value="Print">'
                 '</form>'
               '</body></html>' INTO ui_html.
  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.

    DATA(req_method) = request->get_method( ).

    CASE req_method.

      WHEN CONV string( if_web_http_client=>get ).
        " Handle GET request

        response->set_text( get_html( ) ).

      WHEN CONV string( if_web_http_client=>post ).
        " Handle POST request

        DATA(lv_belnr) = request->get_form_field( `belnr` ).
          DATA(lv_fiscal) = request->get_form_field( `fiscal` ).
        DATA(lv_company) = request->get_form_field( `company` ).


        response->set_text( post_html( lv_belnr = lv_belnr lv_fiscal = lv_fiscal  lv_company = lv_company ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD post_html.

    DATA LV_belnr2 TYPE string.

    SELECT SINGLE FROM I_OperationalAcctgDocItem

      FIELDS  accountingdocument

      WHERE accountingdocument = @lv_belnr

      INTO @LV_belnr2.

    IF LV_belnr2 IS NOT INITIAL.

      TRY.

          " Construct HTML response with embedded PDF view
          DATA(pdf_content) = zcl_Money_Receipt=>read_posts( LV_belnr2 = lv_belnr lv_fiscal = lv_fiscal  lv_company = lv_company ).
*            DATA(pdf_content) = zcl_purord_importing=>read_posts( LV_PO2 = '0500000014' ).

*          html = |{ pdf_content }|.
           html = |{ pdf_content }|.

        CATCH cx_static_check INTO DATA(er).

          html = |Accounting Document does not exist: { er->get_longtext( ) }|.

      ENDTRY.

    ELSE.

      html = |Accounting Document not found|.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
