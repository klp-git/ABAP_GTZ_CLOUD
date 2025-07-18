CLASS zclass_eq_screen DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCLASS_EQ_SCREEN IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF zcds_export_quotation,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.

      DATA(lv_top)   =   io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)  =   io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).
      TRY.
          DATA(lt_clause)  = io_request->get_filter( )->get_as_ranges( ).
          DATA(lt_parameters)  = io_request->get_parameters( ).
          DATA(lt_fileds)  = io_request->get_requested_elements( ).
          DATA(lt_sort)  = io_request->get_sort_elements( ).
        CATCH cx_root INTO DATA(lx_exception).
          CLEAR lt_clause.

      ENDTRY.

      TRY.
          DATA(lt_Filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
        clear lt_filter_cond.
      ENDTRY.


      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'SALESQUOTATION'.
          DATA(lt_salesquot) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'SALESQUOTATIONTYPE'.
          DATA(lt_salesquottype) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'CREATIONDATE'.
          DATA(lt_cdate) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'SALESORGANIZATION'.
          DATA(lt_saleorg) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.


      SELECT
      salesquotation ,
      salesquotationtype,
      salesorganization,
      creationdate
      FROM i_SALESQUOTATION
      WHERE SalesQuotation IN @lt_salesquot
      AND salesquotationtype IN @lt_salesquottype
      AND SalesOrganization IN @lt_saleorg
      AND CreationDate IN @lt_cdate
      INTO TABLE @DATA(it_item).


      LOOP AT it_item INTO DATA(wa).
        ls_response-SalesQuotation = wa-SalesQuotation.
        ls_response-SalesQuotationType = wa-SalesQuotationType.
        ls_response-SalesOrganization = wa-SalesOrganization.
        ls_response-CreationDate = wa-CreationDate.
        APPEND ls_response TO lt_response.
        CLEAR wa.
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
        CLEAR ls_responseout.
      ENDLOOP.

      io_response->set_total_number_of_records( lines( lt_response ) ).
      io_response->set_data( lt_responseout ).

    ENDIF.
  ENDMETHOD.
ENDCLASS.
