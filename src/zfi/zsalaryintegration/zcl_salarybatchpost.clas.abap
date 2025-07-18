CLASS zcl_salarybatchpost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun.

    METHODS: run,
            post.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_salarybatchpost IMPLEMENTATION.

  METHOD post.

     SELECT FROM zr_salaryint
   FIELDS Branch , PayMonth
   GROUP BY  Branch , PayMonth
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

      LOOP AT it_data INTO DATA(wa).

      DATA(psDate) = ZCL_http_salary_post=>checkdateformat( date = postingdate datetype = 'Posting' ).
      FIND 'Invalid' IN psDate.
      IF sy-subrc = 0.
        MODIFY ENTITIES OF Zr_Salaryint
          ENTITY ZrSalaryint
          UPDATE FIELDS ( Errorlog )
          WITH VALUE #( (
              Errorlog = psDate
          ) )
          FAILED DATA(lt_failed)
          REPORTED DATA(lt_reported).

        COMMIT ENTITIES BEGIN
        RESPONSE OF zr_salaryint
        FAILED DATA(lt_commit_failed22)
        REPORTED DATA(lt_commit_reported22).
        COMMIT ENTITIES END.

        RETURN.
      ENDIF.

      DATA(dcDate) = ZCL_http_salary_post=>checkDateFormat( date = postingdate datetype = 'Document' ).
      FIND 'Invalid' IN dcDate.
      IF sy-subrc = 0.
        MODIFY ENTITIES OF Zr_Salaryint
          ENTITY ZrSalaryint
          UPDATE FIELDS ( Errorlog )
          WITH VALUE #( (
              Errorlog = dcDate

          ) )
        FAILED lt_failed
        REPORTED lt_reported.

        COMMIT ENTITIES BEGIN
        RESPONSE OF zr_salaryint
        FAILED lt_commit_failed22
        REPORTED lt_commit_reported22.
        COMMIT ENTITIES END.

        RETURN.
      ENDIF.

      DATA(message) = ZCL_http_salary_post=>postSupplierPayment( wa_data = wa ).

    ENDLOOP.

  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'Branch'   lowercase_ind = abap_true changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'BraZh' )

    ).

  ENDMETHOD.

  METHOD run.
    post(  ).
  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
    run(  ).
  ENDMETHOD.

  METHOD if_apj_rt_exec_object~execute.
    run(  ).
  ENDMETHOD.
ENDCLASS.
