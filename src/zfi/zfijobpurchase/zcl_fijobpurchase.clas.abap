
CLASS zcl_fijobpurchase DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FIJOBPURCHASE IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF ZCDS_FIJOBPURCHASE,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.

      DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                  ELSE lv_top ).

      TRY.
          DATA(lt_clause)        = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lo_error).
          DATA(lv_msg) = lo_error->get_text( ).
      ENDTRY.

      DATA(lt_parameter)     = io_request->get_parameters( ).
      DATA(lt_fields)        = io_request->get_requested_elements( ).
      DATA(lt_sort)          = io_request->get_sort_elements( ).

      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
          lv_msg = lo_error->get_text( ).
      ENDTRY.


      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'BUKRS'.
          DATA(lt_bukrs) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'GJAHR'.
          DATA(lt_gjahr) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'BELNR'.
          DATA(lt_belnr) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.

      SELECT FROM I_OperationalAcctgDocItem AS a
      LEFT JOIN I_JournalEntry AS b ON a~CompanyCode = b~CompanyCode
      AND a~FiscalYear = b~FiscalYear AND a~AccountingDocument = b~AccountingDocument
      FIELDS a~CompanyCode, a~FiscalYear, a~AccountingDocument, a~TaxItemGroup,
      a~AccountingDocumentType, a~PostingDate, a~CostElement, a~BusinessPlace, a~ProfitCenter,
      a~IN_HSNOrSACCode, a~TaxCode, a~AbsoluteAmountInCoCodeCrcy, a~DebitCreditCode, a~AmountInCompanyCodeCurrency,
      b~DocumentReferenceID, b~DocumentDate, b~ReverseDocument
      WHERE a~AccountingDocumentType IN ( 'KR', 'KC', 'KG', 'UR' )
      AND a~PurchasingDocument = '' AND a~CostElement <> '' AND a~TransactionTypeDetermination = '' AND
      a~CompanyCode IN @lt_bukrs AND a~FiscalYear IN @lt_gjahr
      AND a~AccountingDocument IN @lt_belnr

*      AND a~AccountingDocument = '1900000019'
      INTO TABLE @DATA(it_bseg) PRIVILEGED ACCESS.

      SELECT FROM ZI_PlantTable AS a
      FIELDS a~PlantCode, concat_with_space( a~PlantName1 , a~PlantName2, 1 ) AS plantname, a~GstinNo
      WHERE PlantCode <> ''
      INTO TABLE @DATA(it_plant) PRIVILEGED ACCESS.

      SELECT FROM I_Supplier AS a
      FIELDS a~Supplier, a~BPSupplierFullName, a~TaxNumber3, a~BusinessPartnerPanNumber
      WHERE a~SupplierFullName <> ''
      INTO TABLE @DATA(it_supplier) PRIVILEGED ACCESS.

      SELECT FROM I_GLAccountTextRawData AS a
      FIELDS a~GLAccount, a~GLAccountLongName
      WHERE a~GLAccountLongName <> '' AND a~Language = 'E'
      INTO TABLE @DATA(it_glaccount) PRIVILEGED ACCESS.

      SELECT FROM I_GLAccountTextRawData AS a
      FIELDS a~GLAccount, a~GLAccountLongName
      WHERE a~GLAccountLongName <> '' AND a~Language = 'E'
      INTO TABLE @DATA(it_glaccount2) PRIVILEGED ACCESS.

      SELECT FROM I_TaxCodeText FIELDS TaxCode, TaxCodeName
      WHERE TaxCode <> '' AND Language = 'E'
      INTO TABLE @DATA(it_taxcode) PRIVILEGED ACCESS.

      SELECT FROM I_OperationalAcctgDocItem AS a
      FIELDS a~CompanyCode, a~FiscalYear, a~AccountingDocument, a~FinancialAccountType,
      a~Supplier, a~OperationalGLAccount, a~AccountingDocumentType, a~TransactionTypeDetermination, a~TaxItemGroup,
      a~AbsoluteAmountInCoCodeCrcy, a~AccountingDocumentItemType, a~CostElement
      WHERE a~AccountingDocumentType IN ( 'KR', 'KC', 'KG', 'UR' ) AND
      a~CompanyCode IN @lt_bukrs AND a~FiscalYear IN @lt_gjahr
      AND a~AccountingDocument IN @lt_belnr
      INTO TABLE @DATA(it_bseg2) PRIVILEGED ACCESS.



      LOOP AT it_bseg ASSIGNING FIELD-SYMBOL(<wa_bseg>).

        ls_response-bukrs = <wa_bseg>-CompanyCode.
        ls_response-gjahr = <wa_bseg>-FiscalYear.
        ls_response-belnr = <wa_bseg>-AccountingDocument.
        ls_response-txgrp = <wa_bseg>-TaxItemGroup.
        ls_response-AccountingDocumentType = <wa_bseg>-AccountingDocumentType.
        ls_response-postingdate = <wa_bseg>-PostingDate.
        ls_response-costelement = <wa_bseg>-CostElement.
        ls_response-xblnr = <wa_bseg>-DocumentReferenceID. "Bill ref. No.
        ls_response-documentdate = <wa_bseg>-DocumentDate. "Bill ref. date
        ls_response-profitcenter = <wa_bseg>-ProfitCenter.
        ls_response-hsncode = <wa_bseg>-IN_HSNOrSACCode.
        ls_response-taxcode = <wa_bseg>-TaxCode.
        ls_response-taxablevalue = <wa_bseg>-AbsoluteAmountInCoCodeCrcy.
        ls_response-is_reversed = <wa_bseg>-ReverseDocument.

        IF <wa_bseg>-DebitCreditCode = 'H'.
          ls_response-taxablevalue *= -1.
        ENDIF.

        READ TABLE it_bseg2 ASSIGNING FIELD-SYMBOL(<wa_bseg2>) WITH KEY AccountingDocument = <wa_bseg>-AccountingDocument
                                                                            CompanyCode = <wa_bseg>-CompanyCode
                                                                            FiscalYear = <wa_bseg>-FiscalYear FinancialAccountType = 'K'.
        IF <wa_bseg2> IS ASSIGNED.
          ls_response-lifnr = <wa_bseg2>-Supplier.
          ls_response-vendorreconaccount = <wa_bseg2>-OperationalGLAccount.

          READ TABLE it_glaccount ASSIGNING FIELD-SYMBOL(<wa_glaccount>) WITH KEY GLAccount = <wa_bseg2>-OperationalGLAccount.
          IF <wa_glaccount> IS ASSIGNED.
            ls_response-vendorreconaccountname = <wa_glaccount>-GLAccountLongName.
            UNASSIGN <wa_glaccount>.
          ENDIF.

          READ TABLE it_glaccount2 ASSIGNING FIELD-SYMBOL(<wa_glaccount2>) WITH KEY GLAccount = <wa_bseg2>-CostElement.
          IF <wa_glaccount2> IS ASSIGNED.
            ls_response-glaccountdiscription = <wa_glaccount2>-GLAccountLongName.
            UNASSIGN <wa_glaccount2>.
          ENDIF.

          READ TABLE it_supplier ASSIGNING FIELD-SYMBOL(<wa_supplier>) WITH KEY Supplier = <wa_bseg2>-Supplier.
          IF <wa_supplier> IS ASSIGNED.
            ls_response-vendorname = <wa_supplier>-BPSupplierFullName.
            ls_response-vendorgstin = <wa_supplier>-TaxNumber3.
            ls_response-vendorpannumber = <wa_supplier>-BusinessPartnerPanNumber.
            UNASSIGN <wa_supplier>.
          ENDIF.
          UNASSIGN <wa_bseg2>.
        ENDIF.


        READ TABLE it_plant ASSIGNING FIELD-SYMBOL(<wa_plant>) WITH KEY PlantCode = <wa_bseg>-BusinessPlace.
        IF <wa_plant> IS ASSIGNED.
          ls_response-plantname = <wa_plant>-plantname.
          ls_response-plantgst = <wa_plant>-GstinNo.
          UNASSIGN <wa_plant>.
        ENDIF.

        READ TABLE it_taxcode ASSIGNING FIELD-SYMBOL(<wa_taxcode>) WITH KEY TaxCode = <wa_bseg>-TaxCode.
        IF <wa_taxcode> IS ASSIGNED.
          ls_response-taxcodename = <wa_taxcode>-TaxCodeName.
          UNASSIGN <wa_taxcode>.
        ENDIF.

        READ TABLE it_bseg2 ASSIGNING FIELD-SYMBOL(<wa_bseg3>) WITH KEY AccountingDocument = <wa_bseg>-AccountingDocument
                                                                            CompanyCode = <wa_bseg>-CompanyCode
                                                                            FiscalYear = <wa_bseg>-FiscalYear
                                                                            AccountingDocumentItemType = 'T'
                                                                            TaxItemGroup = <wa_bseg>-TaxItemGroup
                                                                            TransactionTypeDetermination = 'JII'.
        IF <wa_bseg3> IS ASSIGNED.
          ls_response-igst_receive = <wa_bseg3>-AbsoluteAmountInCoCodeCrcy.
          IF <wa_bseg>-AmountInCompanyCodeCurrency <> 0.
            ls_response-rate_igst = abs( ( <wa_bseg3>-AbsoluteAmountInCoCodeCrcy / <wa_bseg>-AmountInCompanyCodeCurrency ) * 100 ).
          ENDIF.
          UNASSIGN <wa_bseg3>.
        ENDIF.
        READ TABLE it_bseg2 ASSIGNING FIELD-SYMBOL(<wa_bseg4>) WITH KEY AccountingDocument = <wa_bseg>-AccountingDocument
                                                                           CompanyCode = <wa_bseg>-CompanyCode
                                                                           FiscalYear = <wa_bseg>-FiscalYear
                                                                           AccountingDocumentItemType = 'T'
                                                                           TaxItemGroup = <wa_bseg>-TaxItemGroup
                                                                           TransactionTypeDetermination = 'JIS'.
        IF <wa_bseg4> IS ASSIGNED.
          ls_response-cgst_receive = <wa_bseg4>-AbsoluteAmountInCoCodeCrcy.
          ls_response-sgst_receive = <wa_bseg4>-AbsoluteAmountInCoCodeCrcy.
          IF <wa_bseg>-AmountInCompanyCodeCurrency <> 0.
            ls_response-rate_cgst = abs( ( <wa_bseg4>-AbsoluteAmountInCoCodeCrcy / <wa_bseg>-AmountInCompanyCodeCurrency ) * 100 ).
            ls_response-rate_sgst = ls_response-rate_cgst.
          ENDIF.
          UNASSIGN <wa_bseg4>.
        ENDIF.

        READ TABLE it_bseg2 ASSIGNING FIELD-SYMBOL(<wa_bseg5>) WITH KEY AccountingDocument = <wa_bseg>-AccountingDocument
                                                                           CompanyCode = <wa_bseg>-CompanyCode
                                                                           FiscalYear = <wa_bseg>-FiscalYear
                                                                           AccountingDocumentItemType = 'T'
                                                                           TaxItemGroup = <wa_bseg>-TaxItemGroup
                                                                           TransactionTypeDetermination = 'JIU'.
        IF <wa_bseg5> IS ASSIGNED.
          ls_response-ugst_receive = <wa_bseg5>-AbsoluteAmountInCoCodeCrcy.
          IF <wa_bseg>-AmountInCompanyCodeCurrency <> 0.
            ls_response-rate_ugst = abs( ( <wa_bseg5>-AbsoluteAmountInCoCodeCrcy / <wa_bseg>-AmountInCompanyCodeCurrency ) * 100 ).
          ENDIF.
          UNASSIGN <wa_bseg5>.
        ENDIF.

        READ TABLE it_bseg2 ASSIGNING FIELD-SYMBOL(<wa_bseg6>) WITH KEY AccountingDocument = <wa_bseg>-AccountingDocument
                                                                          CompanyCode = <wa_bseg>-CompanyCode
                                                                          FiscalYear = <wa_bseg>-FiscalYear
                                                                          AccountingDocumentItemType = 'T'
                                                                          TaxItemGroup = <wa_bseg>-TaxItemGroup
                                                                          TransactionTypeDetermination = 'JRC'.
        IF <wa_bseg6> IS ASSIGNED.
          ls_response-rcm_cgst = <wa_bseg6>-AbsoluteAmountInCoCodeCrcy.
          ls_response-rcm_sgst = <wa_bseg6>-AbsoluteAmountInCoCodeCrcy.
          UNASSIGN <wa_bseg6>.
        ENDIF.

        READ TABLE it_bseg2 ASSIGNING FIELD-SYMBOL(<wa_bseg7>) WITH KEY AccountingDocument = <wa_bseg>-AccountingDocument
                                                                         CompanyCode = <wa_bseg>-CompanyCode
                                                                         FiscalYear = <wa_bseg>-FiscalYear
                                                                         AccountingDocumentItemType = 'T'
                                                                         TaxItemGroup = <wa_bseg>-TaxItemGroup
                                                                         TransactionTypeDetermination = 'JRI'.
        IF <wa_bseg7> IS ASSIGNED.
          ls_response-rcm_igst = <wa_bseg7>-AbsoluteAmountInCoCodeCrcy.
          UNASSIGN <wa_bseg7>.
        ENDIF.

        READ TABLE it_bseg2 ASSIGNING FIELD-SYMBOL(<wa_bseg8>) WITH KEY AccountingDocument = <wa_bseg>-AccountingDocument
                                                                        CompanyCode = <wa_bseg>-CompanyCode
                                                                        FiscalYear = <wa_bseg>-FiscalYear
                                                                        AccountingDocumentItemType = 'T'
                                                                        TaxItemGroup = <wa_bseg>-TaxItemGroup
                                                                        TransactionTypeDetermination = 'JRU'.
        IF <wa_bseg8> IS ASSIGNED.
          ls_response-rcm_ugst = <wa_bseg8>-AbsoluteAmountInCoCodeCrcy.
          UNASSIGN <wa_bseg8>.
        ENDIF.

        ls_response-total_tax = ls_response-igst_receive + ls_response-cgst_receive + ls_response-cgst_receive + ls_response-ugst_receive.
        ls_response-total_amount = ls_response-total_tax + <wa_bseg>-AmountInCompanyCodeCurrency. "roundoff + IGSG


        APPEND ls_response TO lt_response .
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
