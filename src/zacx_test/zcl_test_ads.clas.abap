CLASS zcl_test_ads DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TEST_ADS IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    TRY.
        "Initialize Template Store Client
        DATA(lo_store) = NEW zcl_temp_store(
          "name of the destination (in destination service instance) pointing to Forms Service by Adobe API service instance
          iv_name = 'ads_destapi'       "restapi'
          "name of communication arrangement with scenario SAP_COM_0276
          iv_service_instance_name = 'SAP_COM_0276'
        ).
        out->write( 'Template Store Client initialized' ).
        "Initialize class with service definition
**        DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( 'ZDSAG_BILLING_SRV_DEF' ).
**        out->write( 'Dataservice initialized' ).

        "Get initial select keys for service
**        DATA(lt_keys)     = lo_fdp_util->get_keys( ).
**        lt_keys[ name = 'ID' ]-value = '1'.
**        DATA(lv_xml) = lo_fdp_util->read_to_xml( lt_keys ).
**        out->write( 'Service data retrieved' ).

        DATA(ls_template) = lo_store->get_template_by_name(
          iv_get_binary     = abap_true
          iv_form_name      = 'saleorder' "<= form object in template store
          iv_template_name  = 'salesorder' "<= template (in form object) that should be used
        ).

        out->write( 'Form Template retrieved' ).

*        cl_fp_ads_util=>render_4_pq(
*          EXPORTING
*            iv_locale       = 'en_US'
*            iv_pq_name      = 'PRINT_QUEUE' "<= Name of the print queue where result should be stored
*            iv_xml_data     = lv_xml
*            iv_xdp_layout   = ls_template-xdp_template
*            is_options      = VALUE #(
*              trace_level = 4 "Use 0 in production environment
*            )
*          IMPORTING
*            ev_trace_string = DATA(lv_trace)
*            ev_pdl          = DATA(lv_pdf)
*        ).

        out->write( 'Output was generated' ).

*        cl_print_queue_utils=>create_queue_item_by_data(
*            "Name of the print queue where result should be stored
*            iv_qname = 'PRINT_QUEUE'
*            iv_print_data = lv_pdf
*            iv_name_of_main_doc = 'DSAG DEMO Output'
*        ).
*
*        out->write( 'Output was sent to print queue' ).
      CATCH cx_fp_fdp_error zcl_temp_store_err cx_fp_ads_util.
        out->write( 'Exception occurred.' ).
    ENDTRY.
    out->write( 'Finished processing.' ).


  ENDMETHOD.
ENDCLASS.
