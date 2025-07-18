CLASS ZCL_HTTP_SALARY_POST DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
    CLASS-METHODS postData
      IMPORTING
        request        TYPE REF TO if_web_http_request
      RETURNING
        VALUE(message) TYPE string .

    TYPES: BEGIN OF ty_json_structure,
             Branch        TYPE C LENGTH 40,
             PayMonth      TYPE C LENGTH 3,
           END OF ty_json_structure.

    CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.

    CLASS-METHODS  postSupplierPayment
      IMPORTING
        wa_data        TYPE ty_json_structure
      RETURNING
        VALUE(message) TYPE string .

    CLASS-METHODS  checkDateFormat
      IMPORTING
        date           TYPE string
        dateType       TYPE string
      RETURNING
        VALUE(message) TYPE string.

     CLASS-METHODS  psDateGen
      IMPORTING
        wa_data        TYPE ty_json_structure
      RETURNING
        VALUE(message) TYPE string.



PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_SALARY_POST IMPLEMENTATION.


  METHOD checkDateFormat.

    DATA: lv_match TYPE i.

    FIND REGEX '^\d{2}-\d{2}-\d{4}$'  IN date.

    IF sy-subrc = 0.
      lv_match = 1.
    ELSE.
      lv_match = 0.
    ENDIF.

    FIND REGEX '^\d{4}\d{2}\d{2}$'  IN date.
    IF sy-subrc = 0.
      lv_match = 2.
    ENDIF.

    IF lv_match = 1.
      TRY.
          DATA: lv_date_parts TYPE TABLE OF string.
          SPLIT date AT '-' INTO  DATA(lv_date_parts1) DATA(lv_date_parts2) DATA(lv_date_parts3) .
          message = lv_date_parts3 && lv_date_parts2 && lv_date_parts1.
        CATCH cx_sy_itab_line_not_found.
          message = |Invalid { dateType } date format: { date }|.
          RETURN.
      ENDTRY.
    ELSEIF lv_match = 2.
      message = date.
    ELSE.
      message = |Invalid { dateType } date format: { date }|.
      RETURN.
    ENDIF.

  ENDMETHOD.


  METHOD getCID.
    TRY.
        cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.
    CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>post ).
        response->set_text( postData( request ) ).
    ENDCASE.
  ENDMETHOD.

 METHOD psDateGen .

 SELECT * FROM ZR_SALARYINT
    WHERE Branch = @wa_data-branch AND
          PayMonth = @wa_data-PayMonth
          INTO TABLE @DATA(it_data).

    DATA(lv_month) = it_data[ 1 ]-PayMonth.
    DATA: lv_year  TYPE string,
          ev_last_day TYPE string,
          lv_no TYPE string,
          postingdate TYPE string.
    DATA(lv_date) = cl_abap_context_info=>get_system_date( ).
    lv_year = lv_date(4).

      CASE lv_month.
      WHEN 'Jan'. lv_no = '01'.
      WHEN 'Feb'. lv_no = '02'.
      WHEN 'Mar'. lv_no = '03'.
      WHEN 'Apr'. lv_no = '04'.
      WHEN 'May'. lv_no = '05'.
      WHEN 'Jun'. lv_no = '06'.
      WHEN 'Jul'. lv_no = '07'.
      WHEN 'Aug'. lv_no = '08'.
      WHEN 'Sep'. lv_no = '09'.
      WHEN 'Oct'. lv_no = '10'.
      WHEN 'Nov'. lv_no = '11'.
      WHEN 'Dec'. lv_no = '12'.
      WHEN OTHERS. lv_no = '00'.

ENDCASE.
   CASE lv_no.
    WHEN 04 OR 06 OR 09 OR 11.
      ev_last_day = '30'.

    WHEN 02.

      IF ( lv_year MOD 4 = 0 AND lv_year MOD 100 <> 0 ) OR ( lv_year MOD 400 = 0 ).
        ev_last_day = '29'.
      ELSE.
        ev_last_day = '28'.
      ENDIF.

    WHEN OTHERS.
      ev_last_day = '31'.
   ENDCASE.

    CONCATENATE ev_last_day lv_month lv_year INTO postingdate SEPARATED BY '-'.

 ENDMETHOD.

  METHOD postData.

    DATA tt_json_structure TYPE TABLE OF ty_json_structure WITH EMPTY KEY.

    TRY.
       xco_cp_json=>data->from_string( request->get_text( ) )->write_to( REF #( tt_json_structure ) ).

       LOOP AT tt_json_structure INTO DATA(wa).
         message = postSupplierPayment( wa_data = wa  ).
       ENDLOOP.
*
      CATCH cx_sy_conversion_no_date INTO DATA(lx_date).
        message = |Error in Date Conversion: { lx_date->get_text( ) }|.

      CATCH cx_sy_conversion_no_time INTO DATA(lx_time).
        message = |Error in Time Conversion: { lx_time->get_text( ) }|.

      CATCH cx_sy_open_sql_db INTO DATA(lx_sql).
        message = |SQL Error: { lx_sql->get_text( ) }|.

     CATCH cx_root INTO DATA(lx_root).
       message = |General Error here: { lx_root->get_text( ) }|.

    ENDTRY.


  ENDMETHOD.


  METHOD postSupplierPayment.
    DATA: lt_je_deep TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
          document   TYPE string.

    SELECT * FROM ZR_SALARYINT
    WHERE Branch = @wa_data-branch AND
          PayMonth = @wa_data-PayMonth
          INTO TABLE @DATA(it_data).

    DATA(lv_month) = it_data[ 1 ]-PayMonth.
    DATA: lv_year     TYPE string,
          ev_last_day TYPE string,
          lv_no       TYPE string,
          postingdate TYPE string.
    DATA(lv_date) = cl_abap_context_info=>get_system_date( ).
    lv_year = lv_date(4).

    CASE lv_month.
      WHEN 'Jan'. lv_no = '01'.
      WHEN 'Feb'. lv_no = '02'.
      WHEN 'Mar'. lv_no = '03'.
      WHEN 'Apr'. lv_no = '04'.
      WHEN 'May'. lv_no = '05'.
      WHEN 'Jun'. lv_no = '06'.
      WHEN 'Jul'. lv_no = '07'.
      WHEN 'Aug'. lv_no = '08'.
      WHEN 'Sep'. lv_no = '09'.
      WHEN 'Oct'. lv_no = '10'.
      WHEN 'Nov'. lv_no = '11'.
      WHEN 'Dec'. lv_no = '12'.
      WHEN OTHERS. lv_no = '00'.

    ENDCASE.
    CASE lv_no.
      WHEN 04 OR 06 OR 09 OR 11.
        ev_last_day = '30'.

      WHEN 02.

        IF ( lv_year MOD 4 = 0 AND lv_year MOD 100 <> 0 ) OR ( lv_year MOD 400 = 0 ).
          ev_last_day = '29'.
        ELSE.
          ev_last_day = '28'.
        ENDIF.

      WHEN OTHERS.
        ev_last_day = '31'.
    ENDCASE.

    CONCATENATE lv_year lv_no ev_last_day INTO postingdate.

*    DATA(postingDate) = psDateGen( wa_data = wa_data ).

    APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep>).
    <je_deep>-%cid = getCid(  ).
    <je_deep>-%param = VALUE #(
    companycode = 'GT00'
    accountingdocumenttype = 'HR'
    CreatedByUser = sy-uname
    documentdate = postingdate
    postingdate =  postingdate
    _glitems = VALUE #(
     FOR wa_data1 IN it_data INDEX INTO j
                        ( glaccountlineitem = |{ j WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
                            DocumentItemText = wa_data1-Narration
                            CostCenter = wa_data1-CostCenter
                            ProfitCenter = wa_data1-ProfitCenter
                            BusinessPlace = wa_data1-BusinessPlace
                            GLAccount = wa_data1-GLAccount
                            _currencyamount = VALUE #( (
                                    currencyrole = '00'
                                    journalentryitemamount  = COND #(
                                                                      WHEN wa_data1-debit IS NOT INITIAL THEN wa_data1-debit
                                                                      ELSE wa_data1-credit * -1
                                                                    )
                                    currency = 'INR' ) )
                         )
        )
   ).

    MODIFY ENTITIES OF i_journalentrytp PRIVILEGED
    ENTITY journalentry
    EXECUTE post FROM lt_je_deep
    FAILED DATA(ls_failed_deep)
    REPORTED DATA(ls_reported_deep)
    MAPPED DATA(ls_mapped_deep).

    IF ls_failed_deep IS NOT INITIAL.

      LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep>).
        message = <ls_reported_deep>-%msg->if_message~get_text( ).

      ENDLOOP.
      UPDATE zsalarytable SET Errorlog = @message
       WHERE branch = @wa_data-Branch AND
             pay_month = @wa_data-PayMonth.
      RETURN.
    ELSE.

      COMMIT ENTITIES BEGIN
      RESPONSE OF i_journalentrytp
      FAILED DATA(lt_commit_failed)
      REPORTED DATA(lt_commit_reported).

      IF lt_commit_reported IS NOT INITIAL.
        LOOP AT lt_commit_reported-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported>).
          document = <ls_reported>-AccountingDocument.
        ENDLOOP.
      ELSE.
        LOOP AT lt_commit_failed-journalentry ASSIGNING FIELD-SYMBOL(<ls_failed>).
          message = <ls_failed>-%fail-cause.
        ENDLOOP.
        UPDATE zsalarytable SET Errorlog = @message
         WHERE branch = @wa_data-Branch AND
               pay_month = @wa_data-PayMonth .
        RETURN.
      ENDIF.

      COMMIT ENTITIES END.

      IF document IS NOT INITIAL.
        message = |Document Created Successfully: { document } |.
        MODIFY ENTITIES OF ZR_SALARYINT
        ENTITY zrsalaryint
        UPDATE FIELDS ( Accountingdocument Isposted Errorlog )
        WITH VALUE #(
        FOR wa_data2 IN it_data INDEX INTO i
         (
            Accountingdocument = document
            Isposted = abap_true
            Errorlog = ''
            ProfitCenter = wa_data2-ProfitCenter
            CostCenter = wa_data2-CostCenter
            PayMonth = wa_data2-PayMonth
            BusinessPlace = wa_data2-BusinessPlace
            GLAccount = wa_data2-GLAccount
            Branch = wa_data2-Branch
            )  )
        FAILED DATA(lt_failed2)
        REPORTED DATA(lt_reported2).

        COMMIT ENTITIES BEGIN
        RESPONSE OF ZR_SALARYINT
        FAILED DATA(lt_commit_failed22)
        REPORTED DATA(lt_commit_reported22).

        ...
        COMMIT ENTITIES END.
      ELSE.
        message = |Document Creation Failed: { message }|.
      ENDIF.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
