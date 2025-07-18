CLASS ztest DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTEST IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA lv_belnr2 TYPE string.
    DATA result12 TYPE string.
*   SELECT SINGLE a~AccountingDocument,
*                  a~PostingDate,
*                  a~DocumentDate,
*                  a~FinancialAccountType,
*                  a~Supplier,
*                  a~Customer,
*                  d~DocumentReferenceID,
**                  a~AssignmentReference,
*                  a~AccountingDocumentType,
*                  b~CustomerName,
*                  c~SupplierName
*     FROM I_OperationalAcctgDocItem AS a
*     LEFT JOIN I_Customer AS b ON a~Customer = b~Customer
*     LEFT JOIN I_Supplier AS c ON a~Supplier = c~Supplier
*     LEFT join i_journalentry as d on a~AccountingDocument = d~AccountingDocument and a~CompanyCode = d~CompanyCode and a~FiscalYear = d~FiscalYear
*     WHERE "( a~Supplier IS NOT INITIAL OR a~Customer IS NOT INITIAL )  AND
*       a~AccountingDocument = '5000000002' " @lv_belnr2
*       and ( a~FinancialAccountType = 'K' OR a~FinancialAccountType = 'D' )
*     INTO @DATA(wa).

    SELECT SINGLE a~AccountingDocument,
                a~PostingDate,
                a~DocumentDate,
                a~FinancialAccountType,
*                  a~Supplier,
*                  a~Customer,
                d~DocumentReferenceID,
*                  a~AssignmentReference,
                a~AccountingDocumentType
*                  b~CustomerName,
*                  c~SupplierName
   FROM I_OperationalAcctgDocItem AS a
*     LEFT JOIN I_Customer AS b ON a~Customer = b~Customer
*     LEFT JOIN I_Supplier AS c ON a~Supplier = c~Supplier
   LEFT JOIN i_journalentry AS d ON a~AccountingDocument = d~AccountingDocument AND a~CompanyCode = d~CompanyCode AND a~FiscalYear = d~FiscalYear
   WHERE "( a~Supplier IS NOT INITIAL OR a~Customer IS NOT INITIAL )  AND
     a~AccountingDocument = '5000000002' " @lv_belnr2 "'1300000014'
*       and ( a~FinancialAccountType = 'K' OR a~FinancialAccountType = 'D' )
   INTO @DATA(wa).


    SELECT SINGLE
             a~Supplier,
             a~Customer,
             a~AccountingDocumentType,
             b~CustomerName,
             c~SupplierName
FROM I_OperationalAcctgDocItem AS a
LEFT JOIN I_Customer AS b ON a~Customer = b~Customer
LEFT JOIN I_Supplier AS c ON a~Supplier = c~Supplier
LEFT JOIN i_journalentry AS d ON a~AccountingDocument = d~AccountingDocument AND a~CompanyCode = d~CompanyCode AND a~FiscalYear = d~FiscalYear
WHERE "( a~Supplier IS NOT INITIAL OR a~Customer IS NOT INITIAL )  AND
  a~AccountingDocument = '5000000002' " @lv_belnr2 "'1300000014'
  AND ( a~FinancialAccountType = 'K' OR a~FinancialAccountType = 'D' )
INTO @DATA(CustVen).



****** Item ******
*    SELECT a~GLAccount , a~AmountInCompanyCodeCurrency, a~DocumentItemText, b~GLAccountName ,
*           c~CostCenter , c~CostCenterName , d~ProfitCenter , d~ProfitCenterName
*    FROM I_OperationalAcctgDocItem AS a
**    LEFT JOIN i_cnsldtnglaccountvh AS b ON a~GLAccount = b~GLAccount
*    Left JOIN I_GLACCOUNTTEXTRAWDATA AS b ON a~GLAccount = b~GLAccount
*    LEFT JOIN i_costcentertext AS c ON a~CostCenter = c~CostCenter AND c~Language = 'E'
*    LEFT JOIN i_profitcentertext AS d ON a~ProfitCenter = d~ProfitCenter AND d~Language = 'E'
*    WHERE AccountingDocument =  @lv_belnr2 "'1300000014'
*    INTO TABLE @DATA(it_lines).

*   SELECT a~GLAccount , a~AmountInCompanyCodeCurrency , a~DocumentItemText, a~GLAccountName,
*          a~CostCenter , a~CostCenterName , a~ProfitCenter , a~ProfitCenterName
*          FROM zcdsVoucher AS a
*          WHERE AccountingDocument = '1400000000' " @lv_belnr2
*          INTO TABLE @DATA(it_lines).
*    SELECT a~GLAccount , a~AmountInCompanyCodeCurrency , a~DocumentItemText, a~GLAccountName, a~TransactionTypeDetermination,
*             a~CostCenter , a~CostCenterName , a~ProfitCenter , a~ProfitCenterName , a~ledger , a~noo
*             FROM zcdsVoucher AS a
*             WHERE AccountingDocument = '5000000002' "  @lv_belnr2 "'1300000014'
*             AND a~Ledger = '0L'
*             AND a~TransactionTypeDetermination NE 'AGX'
*             AND a~TransactionTypeDetermination NE 'EGX'
*             INTO TABLE @DATA(it_lines).
       """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

*             SELECT
*             a~AccountingDocument,
*             a~companycode,
*             a~fiscalyear,
*             a~glaccount,
*             a~costcenter,
*             a~profitcenter,
*             a~CREDITAMOUNTINCOCODECRCY,
*             a~DEBITAMOUNTINCOCODECRCY,
*             b~ProfitCenterName
*
*
*
*
*
*             FROM  i_accountingdocumentjournal WITH PRIVILEGED ACCESS as a
*             LEFT JOIN I_ProfitCenterText   WITH PRIVILEGED ACCESS as b on a~ProfitCenter = b~ProfitCenter and b~Language = 'E'
*
*             WHERE a~AccountingDocument = '1500000014'  AND a~companycode = 'GT00' AND a~FiscalYear = '2025'
*             AND a~Ledger = '0L' AND a~GLAccount <> '0029500100'
*
*             INTO TABLE @DATA(it_lines).
*
              SELECT
             a~AccountingDocument,
             a~companycode,
             a~fiscalyear,
             a~glaccount,
             a~GLAccountName,
             a~costcenter,
             c~CostCenterName,
             a~profitcenter,
             b~ProfitCenterName,
             a~CREDITAMOUNTINCOCODECRCY,
             a~DEBITAMOUNTINCOCODECRCY,
             a~DocumentItemText,
             a~taxcode,
             d~taxcodeName,
             e~WITHHOLDINGTAXCODE,
             f~WhldgTaxCodeName






             FROM  i_accountingdocumentjournal WITH PRIVILEGED ACCESS as a
             LEFT JOIN I_ProfitCenterText   WITH PRIVILEGED ACCESS as b on a~ProfitCenter = b~ProfitCenter and b~Language = 'E'
             LEFT JOIN i_costcentertext  WITH PRIVILEGED ACCESS as c on a~CostCenter = c~CostCenter
             LEFT JOIN i_taxcodetext WITH PRIVILEGED ACCESS as d on a~taxcode = d~TaxCode
             LEFT JOIN I_WITHHOLDINGTAXITEM WITH PRIVILEGED ACCESS as e on a~AccountingDocument = e~AccountingDocument
             AND a~CompanyCode = e~CompanyCode AND a~FiscalYear = e~FiscalYear AND a~GLAccount = e~GLAccount
             LEFT JOIN i_wITHHOLDINGTAXCODE WITH PRIVILEGED ACCESS as f on e~WithholdingTaxCode = f~WithholdingTaxCode


             WHERE a~AccountingDocument = '2600000007'  AND a~companycode = 'GT00' AND a~FiscalYear = '2025'
             AND a~Ledger = '0L' AND a~GLAccount <> '0029500100'

             INTO TABLE @DATA(it_lines).



          out->write( it_lines ).
*""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*SELECT
*  a~AccountingDocument,
*  a~companycode,
*  a~fiscalyear,
*  a~glaccount
*
*FROM  i_accountingdocumentjournal WITH PRIVILEGED ACCESS AS a
*LEFT OUTER JOIN I_CostCenterText  AS b
*  ON a~CostCenter = b~CostCenter
*  AND b~Language = 'E'
*WHERE a~AccountingDocument = '4900000055'
*  AND a~companycode = 'GTOO'
*  AND a~FiscalYear = '2025'
*  ""AND a~Ledger = '0L'
* "" AND a~GLAccount <> '0029500100'
*INTO TABLE @DATA(it_lines).
*
*out->write( it_lines ).


    SELECT AccountingDocument,
           CompanyCode,
           FiscalYear,
           AccountingDocumentItem,
           AccountingDocumentType,
           ClearingDate,
*             ClearingAccountingDocument,
           clearingjournalentry,
           GLAccount,
           DocumentItemText,
           TransactionTypeDetermination,
           DocumentDate,
           Customer,
           Supplier,
           AmountInCompanyCodeCurrency
    FROM I_OperationalAcctgDocItem
    WHERE AccountingDocument = '1500000002'
       AND TransactionTypeDetermination NE 'AGX'
       AND TransactionTypeDetermination NE 'EGX'
    INTO TABLE @DATA(it).


****** Variables ******
    DATA : Vendor TYPE String.
*    CONCATENATE: wa-Supplier wa-SupplierName INTO Vendor SEPARATED BY space.
    IF CustVen-Supplier IS NOT INITIAL AND CustVen-SupplierName IS NOT INITIAL.
      CONCATENATE: CustVen-Supplier CustVen-SupplierName INTO Vendor SEPARATED BY ' / '.
    ENDIF.
    IF CustVen-Customer IS NOT INITIAL AND CustVen-CustomerName IS NOT INITIAL.
      DATA : Customer TYPE String.
*    CONCATENATE: wa-Customer wa-CustomerName INTO Customer SEPARATED BY space.
      CONCATENATE CustVen-Customer CustVen-CustomerName INTO Customer SEPARATED BY ' / '.
    ENDIF.
* Header
    DATA(lv_xml) =    |<Form>| &&
                      |<AccountingRow>| &&
                      |<InternalDocumentNode>| &&
*                      |<AccountingDocument> 1233 </AccountingDocument>| &&
                      |<AccountingDocument>{ wa-AccountingDocument }</AccountingDocument>| &&
                      |<AccountingDocumentType>{ wa-AccountingDocumentType }</AccountingDocumentType>| &&
                      |<PostingDate>{ wa-PostingDate }</PostingDate>| &&
                      |<DocumentReferenceID>{ wa-DocumentReferenceID }</DocumentReferenceID>| && "0002000004
                      |<DocumentDate>{ wa-DocumentDate }</DocumentDate>| &&
                      |<OffsettingAccountType>{ wa-FinancialAccountType }</OffsettingAccountType>| &&
                      |<Vendor>{ Vendor }</Vendor>| &&
                      |<Customer>{ Customer }</Customer>| &&
*                      |<CustomerName>{ wa-CustomerName }</CustomerName>| &&
                      |</InternalDocumentNode>| &&
                      |<Table>|.

* Item
*    LOOP AT it_lines INTO DATA(wa_lines).
*      DATA(lv_xml1) = |<tableDataRows>| &&
*                   |<GLAccount>{ wa_lines-GLAccount }</GLAccount>| &&
**                   |<GLAccountName>{ wa_lines-GLAccountName }</GLAccountName>| &&
**                   |<GLAccountName> A/P - Capital Goods </GLAccountName>| &&
*                   |<ProfitCenter>{ wa_lines-ProfitCenter }</ProfitCenter>| &&
*                   |<ProfitCenterDescription>{ wa_lines-ProfitCenterName }</ProfitCenterDescription>| &&
*                   |<CostCenter>{ wa_lines-CostCenter }</CostCenter>| &&
*                   |<CostCenterDescription>{ wa_lines-CostCenterName }</CostCenterDescription>| &&
*                   |<AmountInCompanyCodeCurrency>{ wa_lines-AmountInCompanyCodeCurrency }</AmountInCompanyCodeCurrency>| &&
*                   |<DebitAmountInCoCodeCrcy>{ wa_lines-AmountInCompanyCodeCurrency }</DebitAmountInCoCodeCrcy>| &&
*                   |<Narration>{ wa_lines-DocumentItemText }</Narration>| &&
*                   |</tableDataRows>| .
*
*      CLEAR : wa_lines.
*      CONCATENATE: lv_xml lv_xml1 INTO lv_xml.
*    ENDLOOP.
*    DATA(lv_xml2) = |</Table>| &&
*                    |</AccountingRow>| &&
*                    |</Form>|.
*    CONCATENATE: lv_xml lv_xml2 INTO lv_xml.

    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = 'zfi_voucher_print/zfi_voucher_print'
      RECEIVING
        result   = result12 ).
  ENDMETHOD.
ENDCLASS.
