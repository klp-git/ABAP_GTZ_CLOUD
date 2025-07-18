CLASS  zpur_pay_sc_voucher DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZPUR_PAY_SC_VOUCHER IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF zpur_pay_cd_voucher,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.

      DATA(lv_top)   =   io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)  =   io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).

      TRY.
          DATA(lt_clause)  = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range.
          CLEAR lt_clause.
      ENDTRY.

      DATA(lt_parameters)  = io_request->get_parameters( ).
      DATA(lt_fileds)  = io_request->get_requested_elements( ).
      DATA(lt_sort)  = io_request->get_sort_elements( ).

      TRY.
          DATA(lt_Filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
          CLEAR lt_filter_cond.
      ENDTRY.


      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'ACCOUNTINGDOCUMENT'.
          DATA(lt_acc) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'COMPANYCODE'.
          DATA(lt_cc) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'FISCALYEAR'.
          DATA(lt_fy) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.


      SELECT
    a~accountingdocument,
      a~fiscalyear,
      a~companycode
      FROM i_operationalacctgdocitem AS a
      WHERE a~AccountingDocument IN @lt_acc
      AND a~FiscalYear IN @lt_fy
      AND a~CompanyCode IN @lt_cc
      INTO TABLE @DATA(item).

      LOOP AT item INTO DATA(was).
        ls_response-AccountingDocument = was-AccountingDocument.
        ls_response-CompanyCode = was-CompanyCode .
        ls_response-FiscalYear = was-FiscalYear.
        APPEND ls_response TO lt_response.
        CLEAR was.
        CLEAR ls_response.

      ENDLOOP.




      lv_max_rows = lv_skip + lv_top.
      IF lv_skip > 0.
        lv_skip = lv_skip + 1.
      ENDIF.

      CLEAR lt_responseout.
      LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>) FROM lv_skip TO lv_max_rows.
        ls_responseout = <lfs_out_line_item>.
        APPEND ls_responseout TO lt_responseout.
      ENDLOOP.

      io_response->set_total_number_of_records( lines( lt_response ) ).
      io_response->set_data( lt_responseout ).

    ENDIF.
  ENDMETHOD.
ENDCLASS.
