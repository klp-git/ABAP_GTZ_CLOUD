CLASS zcdsrtax_inv_batch_d DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCDSRTAX_INV_BATCH_D IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.

data lt_zplant_table TYPE TABLE OF zplant_table.
data wa_zplant_table TYPE zplant_table.


TYPES : BEGIN OF lty_data,
      companycode        type string,
      fiscalyearvalue    type string,
  fidocumentno       type string,
   fidocumentitem     type string,
*  supplierinvoiceitem    type string,
  vendorcode             type string,
  vendorname            type string,
  vendorreconaccount     type string,
  vendorreconaccountname type string,
  vendorgstnumber        type string,
  vendorpannumber        type string,
  documenttype           type string,
  documentlineitem       type string,
  postingdate            type string,
  plantname              type string,
  plantgst               type string,
  glaccountnumber        type string,
  glaccountdiscription   type string,
  billrefnumber          type string,
  billrefdate           type string,
  vendortype            type string,
  typeofenterprise       type string,
  profitcenter           type string,
  hsncode                type string,
  taxcode                type string,
  taxcodename            type string,
  taxablevalue           type string,
  igst_receive          type string,
  cgst_receive           type string,
  sgst_receive           type string,
  ugst_receive           type string,
  roundoff         type string,
  totalamount type string,
  igstpercent     type string,
  cgstpercent  type string,
  sgstpercent type string,
  ugstpercent type string,
  rcmigstpayable type string,
  rcmcgstpayable type string,
  rcmsgstpayable type string,
  rcmugstpayable type string,
  isreversed  type string,



   toxtotal          type string,


       END OF lty_data.

       DATA : lt_data type TABLE OF lty_data.
       data : wa_data type lty_data.

 """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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
    WHERE  a~AccountingDocument = '1700000001' AND
    a~AccountingDocumentType IN ( 'KR','KC','KG','UR' )
    AND a~PurchasingDocument IS INITIAL

    ""AND a~CostElement is NOT INITIAL
    INTO TABLE @DATA(header).
   SORT header BY AccountingDocument CompanyCode FiscalYear.
    DELETE ADJACENT DUPLICATES FROM Header COMPARING AccountingDocument CompanyCode FiscalYear.

    LOOP AT header INTO DATA(wa_header).


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
      a~businessplace,
      a~supplier
      FROM i_operationalacctgdocitem AS a
      WHERE a~AccountingDocument = @wa_header-AccountingDocument AND a~CompanyCode = @wa_header-CompanyCode AND a~FiscalYear = @wa_header-FiscalYear
     AND a~CostElement IS NOT INITIAL

     INTO TABLE @DATA(it_item).
      SORT it_item BY AccountingDocument AccountingDocumentItem.
      DATA platname TYPE string.

   DATA plantadd  type string.

   DATA string1 type string.
   DATA string2 type string.
   DATA string3 type string.
   DATA string4 type string.
   DATA string5 type string.
   DATA string6 type string.
   DATA string7 type string.
   DATA string8 type string.

   data totalstr1 type string.


      LOOP AT it_item INTO DATA(wa_line).


        SELECT SINGLE FROM
        i_taxcodetext AS a
        FIELDS
        a~TaxCodeName
        WHERE a~TaxCode = @wa_line-TaxCode
        INTO @DATA(lv_taxcode).

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
        a~DocumentDate
        WHERE a~AccountingDocument = @wa_line-AccountingDocument AND a~CompanyCode = @wa_line-CompanyCode
        AND a~FiscalYear = @wa_header-FiscalYear
        INTO @DATA(frvalue).

          SELECT AbsoluteAmountInCoCodeCrcy, AccountingDocumentItemType,
           TransactionTypeDetermination, TaxItemGroup,taxitemacctgdocitemref,TAXBASEAMOUNTINCOCODECRCY
      FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS
      WHERE TaxItemGroup = @wa_line-TaxItemGroup
        AND AccountingDocument = @wa_header-AccountingDocument
        AND FiscalYear = @wa_header-FiscalYear
        AND CompanyCode = @wa_header-CompanyCode
        AND TaxItemGroup = @wa_line-TaxItemGroup
      INTO TABLE @DATA(lv_gst).

        DATA tax1 TYPE string.
        DATA taxg TYPE string.
        data totaltax type string.



        LOOP AT lv_gst INTO DATA(wa_gst).
          tax1 = wa_gst-TaxItemGroup.
          SHIFT tax1 LEFT DELETING LEADING '0'.
          taxg = wa_gst-TaxItemAcctgDocItemRef.
          SHIFT taxg LEFT DELETING LEADING '0'.
          IF wa_gst-AccountingDocumentItemType = 'T' AND wa_gst-TransactionTypeDetermination = 'JII' AND tax1 = taxg.
            string1 = wa_gst-AbsoluteAmountInCoCodeCrcy.
          ELSEIF  wa_gst-AccountingDocumentItemType = 'T' AND wa_gst-TransactionTypeDetermination = 'JIC' AND tax1 = taxg.
            string2 = wa_gst-AbsoluteAmountInCoCodeCrcy.
          ELSEIF  wa_gst-AccountingDocumentItemType = 'T' AND wa_gst-TransactionTypeDetermination = 'JIS' AND tax1 = taxg.
            string3 = wa_gst-AbsoluteAmountInCoCodeCrcy.
          ELSEIF  wa_gst-AccountingDocumentItemType = 'T' AND wa_gst-TransactionTypeDetermination = 'JIU' AND tax1 = taxg.
            string4 = wa_gst-AbsoluteAmountInCoCodeCrcy.
          ELSEIF  wa_gst-AccountingDocumentItemType = 'T' AND wa_gst-TransactionTypeDetermination = 'JRI' AND tax1 = taxg .
            string5 = wa_gst-AbsoluteAmountInCoCodeCrcy.
          ELSEIF  wa_gst-AccountingDocumentItemType = 'T' AND wa_gst-TransactionTypeDetermination = 'JRC' AND tax1 = taxg .
            string6 = wa_gst-AbsoluteAmountInCoCodeCrcy.
          ELSEIF  wa_gst-AccountingDocumentItemType = 'T' AND wa_gst-TransactionTypeDetermination = 'JRS' AND tax1 = taxg .
            string7 = wa_gst-AbsoluteAmountInCoCodeCrcy.
          ELSEIF  wa_gst-AccountingDocumentItemType = 'T' AND wa_gst-TransactionTypeDetermination = 'JRU' AND tax1 = taxg .
            string8 = wa_gst-AbsoluteAmountInCoCodeCrcy.

          ENDIF.
          wa_data-igst_receive = string1.
          wa_data-cgst_receive = string2.
          wa_data-sgst_receive = string3.
          wa_data-ugst_receive = string4.
          totaltax = string1 + string2 + string3 + string4.
          wa_data-toxtotal = totaltax.
           wa_data-rcmigstpayable = string5.
          wa_data-rcmcgstpayable = string6.
          wa_data-rcmsgstpayable = string7.
          wa_data-rcmugstpayable = string8.
          ENDLOOP.


*          SELECT SINGLE FROM I_JOURNALENTRY WITH PRIVILEGED ACCESS  as a
*          FIELDS
*          a~ReverseDocument
*
 totalstr1 = wa_line-AbsoluteAmountInCoCodeCrcy + totaltax .

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

      SELECT SINGLE FROM I_JOURNALENTRY WITH PRIVILEGED ACCESS as a
      FIELDS
      a~ReverseDocument,
      a~DocumentReferenceID
      WHERE a~AccountingDocument = @wa_line-AccountingDocument AND a~CompanyCode = @wa_line-CompanyCode
      AND a~FiscalYear = @wa_line-FiscalYear

      INTO @DATA(rstr1).
      SELECT SINGLE FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS as a
      FIELDS
      a~Supplier,
      a~OperationalGLAccount,
      a~GLAccount
       WHERE a~AccountingDocument = @wa_line-AccountingDocument AND a~CompanyCode = @wa_line-CompanyCode
      AND a~FiscalYear = @wa_line-FiscalYear AND a~FinancialAccountType = 'K'
      INTO @DATA(it_string).

      SELECT SINGLE FROM I_SUPPLIER WITH PRIVILEGED ACCESS as a
      FIELDS
      a~BPSupplierFullName,
      a~TaxNumber3,
      a~BusinessPartnerPanNumber
      WHERE a~Supplier = @it_string-Supplier
      INTO @DATA(vendorstr1).
      SELECT SINGLE FROM  I_GLACCOUNTTEXTRAWDATA WITH PRIVILEGED ACCESS as a
      FIELDS
      a~GLAccountLongName
      WHERE a~GLAccount = @it_string-GLAccount
      INTO @DATA(vstr1).



        wa_data-fidocumentno = wa_line-AccountingDocument.
        wa_data-companycode = wa_line-CompanyCode.
        wa_data-fiscalyearvalue = wa_line-FiscalYear.
        wa_data-glaccountnumber = wa_line-CostElement.
        wa_data-documenttype = wa_line-AccountingDocumentType.
        wa_data-postingdate = wa_line-PostingDate.
        wa_data-plantname = plantadd.
        wa_data-plantgst = plant-GstinNo.
        wa_data-billrefdate = frvalue-DocumentDate.
        wa_data-profitcenter = wa_line-ProfitCenter.
       wa_data-hsncode = wa_line-IN_HSNOrSACCode.
       wa_data-taxcode = wa_line-TaxCode.
       wa_data-taxcodename = lv_taxcode.
        wa_data-taxablevalue = wa_line-AbsoluteAmountInCoCodeCrcy .
        wa_data-totalamount = totalstr1.
        wa_data-igstpercent = lv_result_igst.
        wa_data-cgstpercent = lv_result_cgst.
        wa_data-sgstpercent = lv_result_sgst.
        wa_data-rcmigstpayable = string5.
        wa_data-rcmcgstpayable = string6.
        wa_data-rcmcgstpayable = string7.
        wa_data-rcmugstpayable = string8.
        wa_data-isreversed = rstr1-ReverseDocument.
        wa_data-fidocumentitem = wa_line-TaxItemGroup.
        wa_data-vendorcode = it_string-Supplier.
        wa_data-vendorname = vendorstr1-BPSupplierFullName.
        wa_data-vendorreconaccount = it_string-OperationalGLAccount.
        wa_data-vendorreconaccountname = vstr1.
        wa_data-vendorgstnumber = vendorstr1-TaxNumber3.
        wa_data-vendorpannumber = vendorstr1-BusinessPartnerPanNumber.
        wa_data-documentlineitem = wa_line-TaxItemGroup.
        wa_data-glaccountdiscription = rstr1.
        wa_data-billrefnumber = rstr1-DocumentReferenceID.
        wa_data-fidocumentitem = wa_line-AccountingDocumentItem.







*
*
*        wa_zpurchase-glaccdiscription = glname.
*        wa_zpurchase-sgst_receive = sgst.
*        wa_zpurchase-cgst_receive = cgst.
*        wa_zpurchase-ugst_receive = ugst.
*        wa_zpurchase-igst_receive = igst.
*        wa_zpurchase-billrefnumber = frvalue-DocumentReferenceID.
**        wa_zpurchase-fidocumentitem = gst1-AccountingDocumentItem

     APPEND wa_data TO lt_data.
     clear : wa_data,wa_line,string1,wa_gst.


      ENDLOOP.

    clear wa_header.

    ENDLOOP.

    LOOP AT lt_data INTO DATA(wa_table).

    wa_zplant_table-companycode = wa_table-companycode.
    wa_zplant_table-fiscalyearvalue = wa_table-fiscalyearvalue.
    wa_zplant_table-vendorcode = wa_table-vendorcode.
    wa_zplant_table-vendorname = wa_table-vendorname.
    wa_zplant_table-vendorreconaccount = wa_table-vendorreconaccount.
    wa_zplant_table-vendorreconaccountname = wa_table-vendorreconaccountname.
    wa_zplant_table-vendorgstnumber = wa_table-vendorgstnumber.
    wa_zplant_table-vendorpannumber = wa_table-vendorpannumber.
    wa_zplant_table-fidocumentno = wa_table-fidocumentno.
    wa_zplant_table-documenttype = wa_table-documenttype.
    wa_zplant_table-documentlineitem = wa_table-documentlineitem.
    wa_zplant_table-fidocumentitem = wa_table-fidocumentitem.
    wa_zplant_table-postingdate = wa_table-postingdate.
    wa_zplant_table-plantname = wa_table-plantname.
    wa_zplant_table-plantgst = wa_table-plantgst.
    wa_zplant_table-glaccountnumber = wa_table-glaccountnumber.
    wa_zplant_table-glaccountdiscription = wa_table-glaccountdiscription.
    wa_zplant_table-billrefnumber = wa_table-billrefnumber.
    wa_zplant_table-billrefdate = wa_table-billrefdate.
    wa_zplant_table-profitcenter = wa_table-profitcenter.
    wa_zplant_table-hsncode = wa_table-hsncode.
    wa_zplant_table-taxcode = wa_table-taxcode.
    wa_zplant_table-taxcodename = wa_table-taxcodename.
    wa_zplant_table-taxablevalue = wa_table-taxablevalue.
    wa_zplant_table-igst_receive = wa_table-igst_receive.
    wa_zplant_table-cgst_receive = wa_table-cgst_receive.
    wa_zplant_table-sgst_receive = wa_table-sgst_receive.
    wa_zplant_table-ugst_receive = wa_table-ugst_receive.
    wa_zplant_table-total_tax = wa_table-toxtotal. """"""""""""""
    wa_zplant_table-round_off = wa_table-roundoff.
    wa_zplant_table-tot_amount = wa_table-totalamount.
    wa_zplant_table-igst = wa_table-igstpercent.
    wa_zplant_table-cgst = wa_table-cgstpercent.
    wa_zplant_table-sgst = wa_table-sgstpercent.
    wa_zplant_table-ugst = wa_table-ugstpercent.
    wa_zplant_table-igst_payable = wa_table-rcmigstpayable.
    wa_zplant_table-cgst_payable = wa_table-rcmcgstpayable.
    wa_zplant_table-sgst_payable = wa_table-rcmsgstpayable.
    wa_zplant_table-ugst_payable = wa_table-rcmugstpayable.
    wa_zplant_table-is_reversed = wa_zplant_table-is_reversed.


    MODIFY zplant_table FROM  @wa_zplant_table.
    clear :   wa_table,wa_zplant_table.

    ENDLOOP.
*DELETE FROM zplant_table.

    out->write( lt_data ).







ENDMETHOD.
ENDCLASS.
