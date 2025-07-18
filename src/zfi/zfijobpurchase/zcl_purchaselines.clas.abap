
CLASS zcl_purchaselines DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PURCHASELINES IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
*      ( selname = 'S_ID'    kind = if_apj_dt_exec_object=>select_option datatype = 'C' length = 10 param_text = 'My ID'                                      changeable_ind = abap_true )
*      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'My Description'   lowercase_ind = abap_true changeable_ind = abap_true )
*      ( selname = 'P_COUNT' kind = if_apj_dt_exec_object=>parameter     datatype = 'I' length = 10 param_text = 'My Count'                                   changeable_ind = abap_true )
      ( selname = 'P_SIMUL' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length =  1 param_text = 'Full Processing' checkbox_ind = abap_true  changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
*      ( selname = 'S_ID'    kind = if_apj_dt_exec_object=>select_option sign = 'I' option = 'EQ' low = '4711' )
*      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'My Default Description' )
*      ( selname = 'P_COUNT' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = '200' )
      ( selname = 'P_SIMUL' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = abap_false )
    ).

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    TYPES ty_id TYPE c LENGTH 10.
    DATA s_id    TYPE RANGE OF ty_id.
    DATA p_descr TYPE c LENGTH 80.
    DATA p_count TYPE i.
    DATA p_simul TYPE abap_boolean.
    DATA processfrom TYPE d.

*************************************** RATE GST ************************************
    DATA: lv_gst_text  TYPE string,
          lv_igst_perc TYPE string,
          lv_cgst_perc TYPE string,
          lv_sgst_perc TYPE string,
          lv_pos_start TYPE i,
          lv_pos_end   TYPE i,
          lv_length    TYPE i.

************************************************************************************

    DATA: jobname   TYPE cl_apj_rt_api=>ty_jobname.
    DATA: jobcount  TYPE cl_apj_rt_api=>ty_jobcount.
    DATA: catalog   TYPE cl_apj_rt_api=>ty_catalog_name.
    DATA: template  TYPE cl_apj_rt_api=>ty_template_name.


    DATA: lt_purchinvlines TYPE STANDARD TABLE OF zpurchase_table,
          wa_purchinvlines TYPE zpurchase_table.


****************************************************************************************
    DATA maxpostingdate TYPE d.
    DATA deleteString TYPE c LENGTH 4.
    DATA: lv_tstamp TYPE timestamp, lv_date TYPE d, lv_time TYPE t, lv_dst TYPE abap_bool.

    GET TIME STAMP FIELD DATA(lv_timestamp).

    GET TIME STAMP FIELD lv_tstamp.
    CONVERT TIME STAMP lv_tstamp TIME ZONE sy-zonlo INTO DATE lv_date TIME lv_time DAYLIGHT SAVING TIME lv_dst.

    deleteString = |{ lv_date+6(2) }| && |{ lv_time+0(2) }|.

    IF deleteString = '2819'.
      DELETE FROM zpurchase_table WHERE fidocumentno IS NOT INITIAL.
      COMMIT WORK.
    ENDIF.

    SELECT FROM zpurchase_table "zbillinglines
      FIELDS MAX( postingdate ) WHERE postingdate IS NOT INITIAL
      INTO @maxpostingdate .
    IF maxpostingdate IS INITIAL.
      maxpostingdate = 20010101.
    ELSE.
      maxpostingdate = maxpostingdate - 30.
    ENDIF.
****************************************************************************************


    " Getting the actual parameter values
    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
        WHEN 'S_ID'.
          APPEND VALUE #( sign   = ls_parameter-sign
                          option = ls_parameter-option
                          low    = ls_parameter-low
                          high   = ls_parameter-high ) TO s_id.
        WHEN 'P_DESCR'. p_descr = ls_parameter-low.
        WHEN 'P_COUNT'. p_count = ls_parameter-low.
        WHEN 'P_SIMUL'. p_simul = ls_parameter-low.
      ENDCASE.
    ENDLOOP.

    TRY.
*      read own runtime info catalog
        cl_apj_rt_api=>get_job_runtime_info(
                         IMPORTING
                           ev_jobname        = jobname
                           ev_jobcount       = jobcount
                           ev_catalog_name   = catalog
                           ev_template_name  = template ).

      CATCH cx_apj_rt.
        CLEAR jobname.

    ENDTRY.

    processfrom = sy-datum - 30.
    IF p_simul = abap_true.
      processfrom = sy-datum - 2000.
    ENDIF.





  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.



    DELETE FROM zpurchase_table.
    DATA: lt_zpurchase TYPE  TABLE OF zpurchase_table.
    DATA : wa_zpurchase TYPE zpurchase_table.

    SELECT FROM i_operationalacctgdocitem AS a
    FIELDS
    a~AccountingDocument ,
    a~AccountingDocumentItem,
    a~CompanyCode,
    a~FiscalYear,
    a~CostElement,
    a~AccountingDocumentItemType,
    a~TransactionTypeDetermination,
    a~TaxItemGroup,
    a~ProfitCenter,
    a~AbsoluteAmountInCoCodeCrcy,
    a~DebitCreditCode
    WHERE
*    a~AccountingDocument = '1900000019' AND
    a~AccountingDocumentType IN ( 'KR','KC','KG','UR' )
    AND a~PurchasingDocument IS INITIAL

    ""AND a~CostElement is NOT INITIAL
    INTO TABLE @DATA(header).

    SORT header BY AccountingDocument CompanyCode FiscalYear.
    DELETE ADJACENT DUPLICATES FROM Header COMPARING AccountingDocument CompanyCode FiscalYear.

    LOOP AT header INTO DATA(wa_header).
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      DATA plantadd TYPE string.
      DATA igst TYPE string.
      DATA cgst TYPE string.
      DATA sgst TYPE string.
      DATA ugst TYPE string.




      SELECT
      a~companycode,
      a~fiscalyear,
      a~accountingdocument,
      a~accountingdocumentitem,
      a~TaxItemGroup,
      a~AccountingDocumentItemType,
      a~CostElement,
      a~TransactionTypeDetermination,
      a~ProfitCenter,
      a~IN_HSNOrSACCode,
      a~TaxCode,
      a~AbsoluteAmountInCoCodeCrcy,
      a~DebitCreditCode,
      a~AccountingDocumentType,
      a~PostingDate,
      a~businessplace
      FROM i_operationalacctgdocitem AS a
      WHERE a~AccountingDocument = @wa_header-AccountingDocument AND a~CompanyCode = @wa_header-CompanyCode AND a~FiscalYear = @wa_header-FiscalYear
     AND a~CostElement IS NOT INITIAL

     INTO TABLE @DATA(it_item).
      SORT it_item BY AccountingDocument AccountingDocumentItem.
      DATA platname TYPE string.


      LOOP AT it_item INTO DATA(wa_line).


        SELECT SINGLE FROM
        i_taxcodetext AS a
        FIELDS
        a~TaxCodeName
        WHERE a~TaxCode = @wa_line-TaxCode
        INTO @DATA(lv_taxcode).
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        SELECT SINGLE FROM i_operationalacctgdocitem  as a
        FIELDS
        a~AccountingDocument,
        a~Supplier,
        a~FinancialAccountType,
        a~OperationalGLAccount
        WHERE a~AccountingDocument = @wa_line-AccountingDocument
        AND a~CompanyCode = @wa_line-CompanyCode AND a~FiscalYear = @wa_line-FiscalYear AND a~FinancialAccountType = 'K'
        INTO @DATA(str1).

        SELECT SINGLE FROM I_SUPPLIER as a
        FIELDS
        a~SupplierFullName,
        a~TaxNumber3,
        a~BusinessPartnerPanNumber

        WHERE a~Supplier = @str1-Supplier
        INTO @DATA(str2).

        SELECT SINGLE FROM I_GLACCOUNTTEXTRAWDATA as a

        FIELDS a~GLAccountLongName
        WHERE a~GLAccount = @wa_line-CostElement AND a~Language = 'E'
        INTO @DATA(string1).

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""'
        SELECT SINGLE FROM zi_ztable_plant AS a
        FIELDS
        a~PlantName1,
        a~PlantName2,
        a~GstinNo

        WHERE a~PlantCode = @wa_line-BusinessPlace
        INTO @DATA(plant).
        CONCATENATE plant-PlantName1 plant-PlantName2 INTO  plantadd SEPARATED BY space.

        SELECT SINGLE FROM i_glaccounttextrawdata AS a
        FIELDS
        a~GLAccountLongName
        WHERE a~GLAccount = @wa_line-CostElement
        INTO @DATA(glname).


        SELECT SINGLE FROM  i_journalentry AS a
        FIELDS
        a~DocumentReferenceID,
        a~DocumentDate,
        a~ReverseDocument
        WHERE a~AccountingDocument = @wa_line-AccountingDocument AND a~CompanyCode = @wa_line-CompanyCode
        AND a~FiscalYear = @wa_header-FiscalYear
        INTO @DATA(frvalue).

        SELECT SINGLE
        FROM i_operationalacctgdocitem AS a
        FIELDS
        a~AccountingDocumentItemType,
        a~TransactionTypeDetermination,
        a~TaxItemGroup,
         a~AbsoluteAmountInCoCodeCrcy
         WHERE a~AccountingDocument  = @wa_line-AccountingDocument AND a~CompanyCode = @wa_line-CompanyCode
         AND a~FiscalYear = @wa_line-FiscalYear
         AND a~TaxItemGroup = @wa_line-TaxItemGroup
      INTO   @DATA(gst_value1).

        """"""""""""""""""""""""""""""""""""""""""""
        SELECT SINGLE AbsoluteAmountInCoCodeCrcy, AccountingDocumentItemType,
           TransactionTypeDetermination, TaxItemGroup,taxitemacctgdocitemref
      FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS
      WHERE "TaxItemGroup = @wa_line-TaxItemGroup
         AccountingDocument = @wa_line-AccountingDocument
        AND FiscalYear = @wa_line-FiscalYear
        AND CompanyCode = @wa_line-CompanyCode
        AND TaxItemGroup = @wa_line-TaxItemGroup
AND AccountingDocumentItemType = 'T' AND TransactionTypeDetermination = 'JIC'
      INTO  @DATA(lv_cgst).


        SELECT SINGLE AbsoluteAmountInCoCodeCrcy, AccountingDocumentItemType,
            TransactionTypeDetermination, TaxItemGroup,taxitemacctgdocitemref
       FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS
       WHERE "TaxItemGroup = @wa_line-TaxItemGroup
          AccountingDocument = @wa_line-AccountingDocument
         AND FiscalYear = @wa_line-FiscalYear
         AND CompanyCode = @wa_line-CompanyCode
         AND TaxItemGroup = @wa_line-TaxItemGroup
 AND AccountingDocumentItemType = 'T' AND TransactionTypeDetermination = 'JII'
       INTO  @DATA(lv_igst).


        SELECT SINGLE AbsoluteAmountInCoCodeCrcy, AccountingDocumentItemType,
            TransactionTypeDetermination, TaxItemGroup,taxitemacctgdocitemref
       FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS
       WHERE "TaxItemGroup = @wa_line-TaxItemGroup
          AccountingDocument = @wa_line-AccountingDocument
         AND FiscalYear = @wa_line-FiscalYear
         AND CompanyCode = @wa_line-CompanyCode
         AND TaxItemGroup = @wa_line-TaxItemGroup
 AND AccountingDocumentItemType = 'T' AND TransactionTypeDetermination = 'JIS'
       INTO  @DATA(lv_sgst).


        SELECT SINGLE AbsoluteAmountInCoCodeCrcy, AccountingDocumentItemType,
            TransactionTypeDetermination, TaxItemGroup,taxitemacctgdocitemref
       FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS
       WHERE "TaxItemGroup = @wa_line-TaxItemGroup
          AccountingDocument = @wa_line-AccountingDocument
         AND FiscalYear = @wa_line-FiscalYear
         AND CompanyCode = @wa_line-CompanyCode
         AND TaxItemGroup = @wa_line-TaxItemGroup
 AND AccountingDocumentItemType = 'T' AND TransactionTypeDetermination = 'JIU'
       INTO  @DATA(lv_ugst).


        """""""""""""""""""""""""""""""Paybel tax """""""""""""""""""""""""""""""""
        SELECT SINGLE AbsoluteAmountInCoCodeCrcy, AccountingDocumentItemType,
             TransactionTypeDetermination, TaxItemGroup,taxitemacctgdocitemref
        FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS
        WHERE "TaxItemGroup = @wa_line-TaxItemGroup
           AccountingDocument = @wa_line-AccountingDocument
          AND FiscalYear = @wa_line-FiscalYear
          AND CompanyCode = @wa_line-CompanyCode
          AND TaxItemGroup = @wa_line-TaxItemGroup
  AND AccountingDocumentItemType = 'T' AND TransactionTypeDetermination = 'JRI'
        INTO  @DATA(lv_Rigst).


        SELECT SINGLE AbsoluteAmountInCoCodeCrcy, AccountingDocumentItemType,
            TransactionTypeDetermination, TaxItemGroup,taxitemacctgdocitemref
       FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS
       WHERE "TaxItemGroup = @wa_line-TaxItemGroup
          AccountingDocument = @wa_line-AccountingDocument
         AND FiscalYear = @wa_line-FiscalYear
         AND CompanyCode = @wa_line-CompanyCode
         AND TaxItemGroup = @wa_line-TaxItemGroup
 AND AccountingDocumentItemType = 'T' AND TransactionTypeDetermination = 'JRC'
       INTO  @DATA(lv_Rcgst).


        SELECT SINGLE AbsoluteAmountInCoCodeCrcy, AccountingDocumentItemType,
            TransactionTypeDetermination, TaxItemGroup,taxitemacctgdocitemref
       FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS
       WHERE "TaxItemGroup = @wa_line-TaxItemGroup
          AccountingDocument = @wa_line-AccountingDocument
         AND FiscalYear = @wa_line-FiscalYear
         AND CompanyCode = @wa_line-CompanyCode
         AND TaxItemGroup = @wa_line-TaxItemGroup
 AND AccountingDocumentItemType = 'T' AND TransactionTypeDetermination = 'JRS'
       INTO  @DATA(lv_Rsgst).


        SELECT SINGLE AbsoluteAmountInCoCodeCrcy, AccountingDocumentItemType,
            TransactionTypeDetermination, TaxItemGroup,taxitemacctgdocitemref
       FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS
       WHERE "TaxItemGroup = @wa_line-TaxItemGroup
          AccountingDocument = @wa_line-AccountingDocument
         AND FiscalYear = @wa_line-FiscalYear
         AND CompanyCode = @wa_line-CompanyCode
         AND TaxItemGroup = @wa_line-TaxItemGroup
 AND AccountingDocumentItemType = 'T' AND TransactionTypeDetermination = 'JRU'
       INTO  @DATA(lv_Rugst).

*        DATA tax1 TYPE string.
*        DATA taxg TYPE string.

*        IF lv_cgst-TaxItemGroup = lv_cgst-TaxItemAcctgDocItemRef.
*          cgst = lv_cgst-AbsoluteAmountInCoCodeCrcy.
*
*        ENDIF.

        DATA : tot_tax TYPE p LENGTH 13 DECIMALS 2.

        tot_tax = lv_cgst-AbsoluteAmountInCoCodeCrcy + lv_igst-AbsoluteAmountInCoCodeCrcy + lv_sgst-AbsoluteAmountInCoCodeCrcy + lv_igst-AbsoluteAmountInCoCodeCrcy.

   """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

   DATA: lv_string TYPE string.
      DATA: lv_result_cgst TYPE p DECIMALS 2.
      DATA: lv_result_sgst TYPE p DECIMALS 2.
      DATA: lv_result_igst TYPE p DECIMALS 2.
      DATA: lv_result_gst TYPE string.

      lv_string = lv_taxcode.
   data lv_index type i VALUE -1.

      IF lv_string IS NOT INITIAL.
        FIND to_upper( 'CGST' ) IN lv_string MATCH OFFSET lv_index.

        IF lv_index <> -1.
          lv_index = lv_index + 5.

          DATA: j TYPE i.
          j = lv_index.
          WHILE j < strlen( lv_string ) AND ( lv_string+j(1) ) <> '%'.
            j = j + 1.
          ENDWHILE.
          IF j = strlen( lv_string ).
            lv_result_cgst = 0.
          ELSE.
            j = j - lv_index.
            lv_result_gst = lv_string+lv_index(j).
            REPLACE '%' IN lv_result_gst WITH ' '.
            CONDENSE lv_result_gst NO-GAPS.
            lv_result_cgst = lv_result_gst.
          ENDIF..
        ENDIF.

        CLEAR lv_index.
        CLEAR lv_result_gst.
        lv_index = -1.

        FIND to_upper( 'SGST' ) IN lv_string MATCH OFFSET lv_index.
        IF lv_index <> -1.
          lv_index = lv_index + 5.
          j = lv_index.
          WHILE j < strlen( lv_string ) AND ( lv_string+j(1) ) <> '%'.
            j = j + 1.
          ENDWHILE.
          IF j = strlen( lv_string ).
            lv_result_sgst = 0.
          ELSE.
            j = j - lv_index.
            lv_result_gst = lv_string+lv_index(j).

*          lv_result_gst = lv_string+lv_index(2).
            REPLACE '%' IN lv_result_gst WITH ' '.
            CONDENSE lv_result_gst NO-GAPS.
            lv_result_sgst = lv_result_gst.
          ENDIF.
        ENDIF.

        CLEAR lv_index.
        CLEAR lv_result_gst.
        lv_index = -1.

        FIND to_upper( 'IGST' ) IN lv_string MATCH OFFSET lv_index.
        IF lv_index <> -1.
          lv_index = lv_index + 5.
          j = lv_index.
          WHILE j < strlen( lv_string ) AND ( lv_string+j(1) ) <> '%'.
            j = j + 1.
          ENDWHILE.
          IF j = strlen( lv_string ).
            lv_result_igst = 0.
          ELSE.
            j = j - lv_index.
            lv_result_gst = lv_string+lv_index(j).
*          lv_result_gst = lv_string+lv_index(2).
            REPLACE '%' IN lv_result_gst WITH ' '.
            CONDENSE lv_result_gst NO-GAPS.
            lv_result_igst = lv_result_gst.
          ENDIF.
        ENDIF.

        CLEAR lv_index.
        CLEAR lv_result_gst.
        lv_index = -1.
      ENDIF.
      lv_index = -1.
      CLEAR lv_result_gst.
      CLEAR lv_string.

   data tot_amount type string.
   data roundvalue type string.

   tot_amount = tot_tax +  roundvalue  + wa_line-AbsoluteAmountInCoCodeCrcy .






*        LOOP AT lv_gst INTO DATA(wa_gst).
*          tax1 = wa_gst-TaxItemGroup.
*          SHIFT tax1 LEFT DELETING LEADING '0'.
*          taxg = wa_gst-TaxItemAcctgDocItemRef.
*          SHIFT taxg LEFT DELETING LEADING '0'.
*          IF wa_gst-AccountingDocumentItemType = 'T' AND wa_gst-TransactionTypeDetermination = 'JII' AND tax1 = taxg.
*            igst = wa_gst-AbsoluteAmountInCoCodeCrcy.
*          ELSEIF  wa_gst-AccountingDocumentItemType = 'T' AND wa_gst-TransactionTypeDetermination = 'JIC' AND tax1 = taxg.
*            cgst = wa_gst-AbsoluteAmountInCoCodeCrcy.
*          ELSEIF  wa_gst-AccountingDocumentItemType = 'T' AND wa_gst-TransactionTypeDetermination = 'JIS' AND tax1 = taxg.
*            sgst = wa_gst-AbsoluteAmountInCoCodeCrcy.
*          ELSEIF  wa_gst-AccountingDocumentItemType = 'T' AND wa_gst-TransactionTypeDetermination = 'JIU' AND tax1 = taxg.
*            ugst = wa_gst-AbsoluteAmountInCoCodeCrcy.
*
*          ENDIF.
**    ENDLOOP.
*          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
**          wa_zpurchase-igst_receive = string1.
*          CLEAR : igst , cgst, ugst, sgst.
*        ENDLOOP.

        wa_zpurchase-fidocumentno = wa_line-AccountingDocument.
        wa_zpurchase-fidocumentitem = wa_line-AccountingDocumentItem.
        wa_zpurchase-companycode = wa_line-CompanyCode.
        wa_zpurchase-glaccountnumber = wa_line-CostElement.
        wa_zpurchase-documenttype = wa_line-AccountingDocumentType.
        wa_zpurchase-postingdate = wa_line-PostingDate.
        wa_zpurchase-plantname = plantadd.
        wa_zpurchase-fiscalyearvalue = wa_line-FiscalYear.
        wa_zpurchase-plantgst = plant-GstinNo.
        wa_zpurchase-billrefdate = frvalue-DocumentDate.
        wa_zpurchase-profitcenter = wa_line-ProfitCenter.
        wa_zpurchase-hsncode = wa_line-IN_HSNOrSACCode.
        wa_zpurchase-taxcode = wa_line-TaxCode .
        wa_zpurchase-taxcodename = lv_taxcode.
        wa_zpurchase-taxablevalue = wa_line-AbsoluteAmountInCoCodeCrcy.
        wa_zpurchase-glaccdiscription = glname.

        wa_zpurchase-sgst_receive = lv_sgst-AbsoluteAmountInCoCodeCrcy.
        wa_zpurchase-cgst_receive = lv_cgst-AbsoluteAmountInCoCodeCrcy.
        wa_zpurchase-ugst_receive = lv_ugst-AbsoluteAmountInCoCodeCrcy.
        wa_zpurchase-igst_receive = lv_igst-AbsoluteAmountInCoCodeCrcy.

        wa_zpurchase-sgst_payable = lv_rsgst-AbsoluteAmountInCoCodeCrcy.
        wa_zpurchase-cgst_payable = lv_rcgst-AbsoluteAmountInCoCodeCrcy.
        wa_zpurchase-igst_payable = lv_rigst-AbsoluteAmountInCoCodeCrcy.
        wa_zpurchase-ugst_payable = lv_rugst-AbsoluteAmountInCoCodeCrcy.

        wa_zpurchase-billrefnumber = frvalue-DocumentReferenceID.
        wa_zpurchase-total_tax = tot_tax.
        wa_zpurchase-tot_amount = tot_amount.
        wa_zpurchase-igst = lv_result_igst .
        wa_zpurchase-cgst = lv_result_cgst.
        wa_zpurchase-sgst = lv_result_sgst.

        wa_zpurchase-glaccountdiscription = string1.
        wa_zpurchase-documentlineitem = wa_line-TaxItemGroup.
        wa_zpurchase-vendorcode = str1-Supplier.
        wa_zpurchase-vendorname = str2-SupplierFullName.
        wa_zpurchase-vendorreconaccount = str1-OperationalGLAccount.
        wa_zpurchase-vendorreconaccountname = string1.
        wa_zpurchase-vendorgstnumber = str2-TaxNumber3.
        wa_zpurchase-vendorpannumber = str2-BusinessPartnerPanNumber.
*        wa_zpurchase-sgst_payable = lv_rsgst-AbsoluteAmountInCoCodeCrcy.
*        wa_zpurchase-cgst_payable = lv_rcgst-AbsoluteAmountInCoCodeCrcy.
*        wa_zpurchase-igst_payable = lv_rigst-AbsoluteAmountInCoCodeCrcy.
*        wa_zpurchase-ugst_payable = lv_rugst-AbsoluteAmountInCoCodeCrcy.
        wa_zpurchase-is_reversed = frvalue-ReverseDocument.

*        wa_zpurchase-fidocumentitem = gst1-AccountingDocumentItem.

        MODIFY zpurchase_table FROM @wa_zpurchase.
        CLEAR wa_line.
        CLEAR lv_taxcode.

      ENDLOOP.
    ENDLOOP.





  ENDMETHOD.
ENDCLASS.
