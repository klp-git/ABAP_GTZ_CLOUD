CLASS zcl_Acct_Print DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ACCT_PRINT IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
*    IF io_request->is_data_requested( ).
*
*      DATA: lt_response    TYPE TABLE OF zcds_acco,
*            ls_response    LIKE LINE OF lt_response,
*            lt_responseout LIKE lt_response,
*            ls_responseout LIKE LINE OF lt_responseout.
*
*      DATA(lv_top)   =   io_request->get_paging( )->get_page_size( ).
*      DATA(lv_skip)  =   io_request->get_paging( )->get_offset( ).
*      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).
*
*      TRY.
*          DATA(lt_clause)  = io_request->get_filter( )->get_as_ranges( ).
*        CATCH cx_rap_query_filter_no_range.
*          CLEAR lt_clause.
*      ENDTRY.
*
*
*      DATA(lt_parameters)  = io_request->get_parameters( ).
*      DATA(lt_fileds)  = io_request->get_requested_elements( ).
*      DATA(lt_sort)  = io_request->get_sort_elements( ).
*
*      TRY.
*          DATA(lt_Filter_cond) = io_request->get_filter( )->get_as_ranges( ).
*        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
*          CLEAR lt_Filter_cond.
*      ENDTRY.
*
*      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
*        IF ls_filter_cond-name = 'ACCOUNTINGDOCUMENT'.
*          DATA(lt_AccountingDocument) = ls_filter_cond-range[].
*        ELSEIF ls_filter_cond-name = 'COMPANYCODE'.
*          DATA(lt_CompanyCode) = ls_FILTER_cond-range[].
*        ELSEIF ls_filter_cond-name = 'FISCALYEAR'.
*          DATA(lt_FiscalYear) = ls_filter_cond-range[].
*        ELSEIF ls_filter_cond-name = 'ACCOUNTINGDOCUMENTITEM'.
*          DATA(lt_AccountingDocumentItem) = ls_filter_cond-range[].
*        ELSEIF ls_filter_cond-name = 'POSTINGDATE'.
*          DATA(lt_PostingDate) = ls_filter_cond-range[].
*        ELSEIF ls_filter_cond-name = 'ACCOUNTINGDOCUMENTTYPE'.
*          DATA(lt_AccountingDocumentType) = ls_FILTER_cond-range[].
*        ELSEIF ls_filter_cond-name = 'CLEARINGDATE'.
*          DATA(lt_ClearingDate) = ls_filter_cond-range[].
*        ELSEIF ls_filter_cond-name = 'DOCUMENTDATE'.
*          DATA(lt_DocumentDate) = ls_FILTER_cond-range[].
*        ELSEIF ls_filter_cond-name = 'GLACCOUNT'.
*          DATA(lt_GLAccount) = ls_filter_cond-range[].
*        ELSEIF ls_filter_cond-name = 'AMOUNTINCOMPANYCODECURRENCY'.
*          DATA(lt_AmountInCompanyCodeCurrency) = ls_FILTER_cond-range[].
*        ENDIF.
*      ENDLOOP.
*
*      SELECT AccountingDocument,
*             CompanyCode,
*             FiscalYear,
*             AccountingDocumentItem,
*             AccountingDocumentType,
*             ClearingDate,
*             GLAccount,
*             postingdate,
*             DocumentItemText,
*             TransactionTypeDetermination,
*             DocumentDate,
*             Customer,
*             Supplier,
*             AmountInCompanyCodeCurrency,
*             IsReversal,
*             IsReversed
*      FROM zcds_acco
*      WHERE AccountingDocument IN @lt_AccountingDocument
*        AND CompanyCode IN @lt_CompanyCode
*        AND FiscalYear IN @lt_FiscalYear
*        AND AccountingDocumentItem IN @lt_AccountingDocumentItem
*        AND postingdate IN @lt_postingdate
*        AND AccountingDocumentType IN @lt_AccountingDocumentType
*        AND ClearingDate IN @lt_ClearingDate
*        AND GLAccount IN @lt_GLAccount
*        AND DocumentDate IN @LT_DocumentDate
*        AND AmountInCompanyCodeCurrency IN @lt_AmountInCompanyCodeCurrency
*         AND TransactionTypeDetermination NE 'AGX'
*         AND TransactionTypeDetermination NE 'EGX'
*         AND AccountingDocumentType NE 'WL'
*         AND AccountingDocumentType NE 'RV'
*         AND AccountingDocumentType NE 'WA'
*         AND AccountingDocumentType NE 'WN'
*         AND AccountingDocumentType NE 'SK'
*         AND AccountingDocumentType NE 'SJ'
*         AND AccountingDocumentType NE 'SU'
*         AND AccountingDocumentType NE 'SA'
*         AND AccountingDocumentType NE 'AB'
*         AND IsReversal NE 'X'
*         AND IsReversed NE 'X'
*      INTO TABLE @DATA(it).
*
*      LOOP AT it INTO DATA(wa).
*        ls_response-AccountingDocument = wa-AccountingDocument.
*        ls_response-CompanyCode = wa-CompanyCode.
*        ls_response-FiscalYear = wa-FiscalYear.
*        ls_response-AccountingDocumentItem = wa-AccountingDocumentItem.
*        ls_response-AccountingDocumentType = wa-AccountingDocumentType.
*        ls_response-ClearingDate = wa-ClearingDate.
*        ls_response-GLAccount = wa-GLAccount.
*        ls_response-DocumentDate = wa-DocumentDate.
*        ls_response-DocumentItemText = wa-DocumentItemText.
*        ls_response-Customer = wa-Customer.
*        ls_response-Supplier = wa-Supplier.
*        ls_response-TransactionTypeDetermination = wa-TransactionTypeDetermination.
*        ls_response-AmountInCompanyCodeCurrency = wa-AmountInCompanyCodeCurrency.
*        ls_response-PostingDate = wa-PostingDate.
*        ls_response-IsReversal = wa-IsReversal.
*        ls_response-IsReversed = wa-IsReversed.
*        APPEND ls_response TO lt_response.
*      ENDLOOP.
*
*      lv_max_rows = lv_skip + lv_top.
*      IF lv_skip > 0.
*        lv_skip = lv_skip + 1.
*      ENDIF.
*
*      CLEAR lt_responseout.
*      LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>) FROM lv_skip TO lv_max_rows.
*        ls_responseout = <lfs_out_line_item>.
*        APPEND ls_responseout TO lt_responseout.
*      ENDLOOP.
*
*      io_response->set_total_number_of_records( lines( lt_response ) ).
*      io_response->set_data( lt_responseout ).

*    ENDIF.
  ENDMETHOD.
ENDCLASS.
