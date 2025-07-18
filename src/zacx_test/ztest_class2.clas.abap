CLASS ztest_class2 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA:
      mo_http_destination TYPE REF TO if_http_destination,
      mv_client           TYPE REF TO if_web_http_client.
    INTERFACES: if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTEST_CLASS2 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    TRY.
        "Initialize Template Store Client
        DATA(lo_client) = NEW zcl_fp_client2(
          iv_name = 'ADS_SRV'
        ).

        "Get form template data
        DATA(ls_template) = lo_client->get_template_by_name(
          iv_get_binary     = abap_true
          iv_form_name      = 'worksorder'
          iv_template_name  = 'worksorder'
        ).
        out->write( ls_template-template_name ).
        out->write( 'hekko.' ).
      CATCH cx_root INTO DATA(lvv).
        out->write( lvv->get_longtext(  ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
