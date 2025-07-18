CLASS zcl_list_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_LIST_REPORT IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF zcds_moneyrec,
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
          CLEAR lt_Filter_cond.
      ENDTRY.

      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'ACCOUNTINGDOCUMENT'.
          DATA(lt_AccountingDocument) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'COMPANYCODE'.
          DATA(lt_CompanyCode) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = 'ACCOUNTINGDOCUMENTTYPE'.
          DATA(lt_AccountingDocumentType) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'POSTINGDATE'.
          DATA(lt_PostingDate) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'CUSTOMER'.
          DATA(lt_Customer) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'CUSTOMERNAME'.
          DATA(lt_CustomerName) = ls_FILTER_cond-range[].
        ENDIF.
      ENDLOOP.
      SELECT AccountingDocument,
             CompanyCode,
             AccountingDocumentType,
             PostingDate,
             Customer,
             CustomerName

      FROM zcds_moneyrec
        WHERE AccountingDocument IN @lt_AccountingDocument
        AND CompanyCode IN @lt_CompanyCode
        AND AccountingDocumentType IN @lt_AccountingDocumentType
        AND PostingDate IN @lt_PostingDate
        AND Customer IN @lt_Customer
        AND CustomerName IN @lt_CustomerName
        INTO TABLE @DATA(it).
      LOOP AT it INTO DATA(wa).
        ls_response-AccountingDocument = wa-AccountingDocument.
        ls_response-AccountingDocumentType = wa-AccountingDocumentType.
        ls_response-CompanyCode = wa-CompanyCode.
        ls_response-Customer = wa-Customer.
        ls_response-CustomerName = wa-CustomerName.
        ls_response-PostingDate = wa-PostingDate.
        APPEND ls_response TO lt_response.
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
