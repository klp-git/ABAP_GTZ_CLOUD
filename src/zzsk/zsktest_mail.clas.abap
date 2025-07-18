CLASS zsktest_mail DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
    CLASS-DATA: lx_bcs_mail TYPE REF TO cx_bcs_mail.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZSKTEST_MAIL IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
***
****    out->write( 'Hello' ).
***
***
***
***    DELETE FROM zprplanning WHERE productcode IS INITIAL.
***
***    DATA: lv_timestamp TYPE timestampl,
***          lv_user      TYPE syuname.
***
***    " Get current user and timestamp
***    lv_user      = cl_abap_context_info=>get_user_technical_name( ).
***    lv_timestamp = cl_abap_context_info=>get_system_time( ).
***
***
***
***    DATA timestamp1 TYPE utclong.
***    DATA timestamp2 TYPE utclong.
***    DATA difference TYPE decfloat34.
***    DATA date_user TYPE d.
***    DATA time_user TYPE t.
***    DATA(lv_date) = cl_abap_context_info=>get_system_date( ).
***    DATA(lv_month) = lv_date+4(2).
***    DATA(lv_year) = lv_date+0(4).
***    DATA(lv_day) = lv_date+6(2).
***    lv_month += 1.
***
***    IF lv_month > 12.
***      lv_month = 1.
***      lv_year  = lv_year + 1.
***    ENDIF.
***
***    DATA(lv_date2) = |{ lv_year }{ lv_month ALPHA = IN }{ lv_day }|.
****    out->write( lv_date2 ).
***
***    timestamp1 = utclong_current( ).
****    out->write( |Current UTC time { timestamp1 }| ).
***
***    timestamp2 = utclong_add( val = timestamp1 days = 7 ).
****    out->write( |Added 7 days to current UTC time { timestamp2 }| ).
***
***    difference = utclong_diff( high = timestamp2 low = timestamp1 ).
****    out->write( |Difference between timestamps in seconds: { difference }| ).
***
****    out->write( |Difference between timestamps in days: { difference / 3600 / 24 }| ).
***
***    CONVERT UTCLONG utclong_current( )
***       INTO DATE date_user
***            TIME time_user
***            TIME ZONE cl_abap_context_info=>get_user_time_zone( ).
***
****    out->write( |UTC timestamp split into date (type D) and time (type T )| ).
****    out->write( |according to the user's time zone (cl_abap_context_info=>get_user_time_zone( ) ).| ).
****    out->write( |{ date_user DATE = USER }, { time_user TIME = USER }| ).
***
****    DELETE FROM zprplanning WHERE bukrs IS INITIAL.
****
****    DELETE FROM zsalesforecast WHERE bukrs IS INITIAL.
****
****    DELETE FROM zsalestrend WHERE bukrs IS INITIAL.
***
***
***    SELECT SINGLE FROM i_address_2 WITH PRIVILEGED ACCESS
***    FIELDS *
***    WHERE AddressID = '0000001112'
***    INTO @DATA(wa_adr).
***
***    SELECT SINGLE FROM I_BusinessPartnerAddressType WITH PRIVILEGED ACCESS
***    FIELDS *
****    WHERE BusinessPartner = '1210000011'
***    INTO @DATA(wa_adr2).
***
***    DELETE FROM zsalestrend .
***
***    out->write( wa_adr ).
***
****    SELECT FROM zprplanning FIELDS * INTO TABLE @DATA(it).
****    LOOP AT it INTO DATA(wa).
****      wa-productcode = |{ wa-productcode ALPHA = OUT }|.
****      MODIFY zprplanning FROM @wa  .
****      CLEAR : wa.
****    ENDLOOP.
****    DELETE FROM zprplanning WHERE productcode IS NOT INITIAL.
***
****    out->write( 'Hello' ).
****
****    TRY.
****        DATA(lo_mail) = cl_bcs_mail_message=>create_instance( ).
****        lo_mail->set_sender( 'sagar.kumar@acxiomconsulting.com' ).
****        lo_mail->add_recipient( 'sagar.kumar@acxiomconsulting.com' ).
****
****
****
****        lo_mail->set_subject( 'Testing  mail' ).
****        lo_mail->set_main( cl_bcs_mail_textpart=>create_instance(
****        iv_content      = 'hello'
****        iv_content_type = 'text/html'
****        ) ).
****
****
****        lo_mail->send( IMPORTING et_status = DATA(lt_status) ).
****        out->write( lt_status ).
****      CATCH cx_bcs_mail INTO lx_bcs_mail.
****        out->write( lx_bcs_mail->get_longtext(  ) ).
****    ENDTRY.
***
***
*******    TRY.
*******        DATA(lo_mail) = cl_bcs_mail_message=>create_instance( ).
*******
*******        lo_mail->set_sender( 'sagarshriwastav2@gmail.com' ).
*******        lo_mail->add_recipient( 'sagarshriwastav44@gmail.com' ).
*******
*******        lo_mail->set_subject( 'Test Mail' ).
*******
*******        lo_mail->set_main( cl_bcs_mail_textpart=>create_instance(
*******            iv_content      = '<h1>Hello</h1><p>Sagar Kumar</p>'
*******            iv_content_type = 'text/html' ) ).
*******
*******        lo_mail->send( IMPORTING et_status = DATA(lt_status) ).
*******
*******        out->write( lt_status ).
*******
*******      CATCH cx_bcs_mail INTO DATA(lo_err).
*******        out->write( lo_err->get_longtext( ) ).
*******    ENDTRY.
  ENDMETHOD.
ENDCLASS.
