CLASS zclass_journal DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCLASS_JOURNAL IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF zdd_journal,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.


      DATA : lv_index          TYPE sy-tabix.

      DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                  ELSE lv_top ).

      TRY.
          DATA(lt_clause)        = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range.
          CLEAR lt_clause.
      ENDTRY.
      DATA(lt_parameter)     = io_request->get_parameters( ).
      DATA(lt_fields)        = io_request->get_requested_elements( ).
      DATA(lt_sort)          = io_request->get_sort_elements( ).
    ENDIF.


    TRY.
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
        CLEAR lt_filter_cond.
    ENDTRY.

    LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
      IF ls_filter_cond-name = 'JOURNAL_ENTRY_NO'.
        DATA(lt_je_no)  = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'JOURNAL_ENTRY_TY'.
        DATA(lt_je_ty) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'JOURNAL_ENTRY_DT'.
        DATA(lt_je_dt) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'AMOUNT_FIELD'.
        DATA(lt_amount) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'COMPANYCODE'.
        DATA(lt_c_code) = ls_filter_cond-range[].

      ENDIF.
    ENDLOOP.

    SELECT a~AccountingDocument,
    a~AccountingDocumentType,
    a~DocumentDate,
    a~amountintransactioncurrency,
    a~AccountingDocumentItem,
    a~companycode

     FROM I_OperationalAcctgDocItem AS a
    WHERE a~AccountingDocument IN @lt_je_no
    AND a~AccountingDocumentType IN @lt_je_ty
    AND a~DocumentDate IN @lt_je_dt
    AND a~AmountInTransactionCurrency IN @lt_amount
    AND a~CompanyCode IN @lt_c_code
    AND a~AccountingDocumentItem = '001'
     INTO TABLE @DATA(it).

    SORT it BY AccountingDocument.
    DELETE ADJACENT DUPLICATES FROM it COMPARING ALL FIELDS.

    LOOP AT it INTO DATA(wa).
      ls_response-journal_entry_no = wa-AccountingDocument.
      ls_response-journal_entry_ty = wa-AccountingDocumentType.
      ls_response-journal_entry_dt = wa-DocumentDate.
      ls_response-amount_field = wa-AmountInTransactionCurrency.
      ls_response-CompanyCode = wa-CompanyCode.
      APPEND ls_response TO lt_response.
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


  ENDMETHOD.
ENDCLASS.
