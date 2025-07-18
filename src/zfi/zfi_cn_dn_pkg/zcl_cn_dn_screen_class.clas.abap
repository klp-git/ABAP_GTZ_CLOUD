CLASS  zcl_cn_dn_screen_Class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_CN_DN_SCREEN_CLASS IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF zcds_fi_cn_dn,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.

      DATA(lv_top)   =   io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)  =   io_request->get_paging( )->get_offset( ).
   DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).
   TRY.
          DATA(lt_parameters)  = io_request->get_parameters( ).
          DATA(lt_fileds)  = io_request->get_requested_elements( ).
          DATA(lt_sort)  = io_request->get_sort_elements( ).


          DATA(lt_Filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
          CLEAR lx_no_sel_option.
      ENDTRY.

*      TRY.
*          DATA(lt_Filter_cond) = io_request->get_filter( )->get_as_ranges( ).
*        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
*        clear lt_filter_cond.
*      ENDTRY.


      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'ACCOUNTINGDOCUMENT'.
          DATA(lt_acc) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'COMPANYCODE'.
          DATA(lt_cc) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'FISCALYEAR'.
          DATA(lt_fy) = ls_filter_cond-range[].
           ELSEIF ls_filter_cond-name = 'POSTINGDATE'.
          DATA(lt_PD) = ls_filter_cond-range[].
           ELSEIF ls_filter_cond-name = 'ACCOUNTINGDOCUMENTTYPE'.
          DATA(lt_DTYPE) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.


      SELECT
    a~accountingdocument,
      a~fiscalyear,
      a~companycode,
      A~customer,
      a~supplier,
      a~accountingdocumenttype,
      a~ABSOLUTEAMOUNTINCOCODECRCY,
      a~postingdate
      FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS  AS a
      WHERE a~AccountingDocument IN @lt_acc
      AND a~FiscalYear IN @lt_fy
      AND a~CompanyCode IN @lt_cc AND a~PostingDate in @lt_PD and a~AccountingDocumentType in @lt_dtype and a~FinancialAccountType = 'K'
      INTO TABLE @DATA(it_item).

      loop at it_item INTO DATA(wa).
      ls_response-AccountingDocument = wa-AccountingDocument.
      ls_response-CompanyCode = wa-CompanyCode .
      ls_response-FiscalYear = wa-FiscalYear.

      ls_response-AccountingDocumentType = wa-AccountingDocumentType.
        ls_response-Customer = wa-Customer.
        ls_response-Supplier = wa-Supplier.
        ls_response-PostingDate = wa-PostingDate.
        ls_response-AbsoluteAmountInCoCodeCrcy = wa-AbsoluteAmountInCoCodeCrcy.
      APPEND ls_response TO lt_response.
      clear wa.
      clear ls_response.

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
