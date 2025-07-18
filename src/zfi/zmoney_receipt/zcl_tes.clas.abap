CLASS zcl_tes DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TES IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  data result12 type string.
*
*     SELECT SINGLE a~AccountingDocument,
*                  a~PostingDate,
*                  a~DocumentDate,
*                  a~OffsettingAccountType,
*                  a~Supplier,
*                  a~Customer,
*                  a~AssignmentReference,
*                  a~AccountingDocumentType,
*                  b~CustomerName,
*                  c~SupplierName
*     FROM I_OperationalAcctgDocItem AS a
*     LEFT JOIN I_Customer AS b ON a~Customer = b~Customer
*     LEFT JOIN I_Supplier AS c ON a~Supplier = c~Supplier
*     WHERE "( a~Supplier IS NOT INITIAL OR a~Customer IS NOT INITIAL )  AND
*       a~AccountingDocument = '1900000000'" @lv_belnr2 "
*     INTO @DATA(wa).


****** Item ******
*   SELECT a~GLAccount , a~AmountInCompanyCodeCurrency, a~DocumentItemText, b~GLAccountName ,
*           c~CostCenter , c~CostCenterName , d~ProfitCenter , d~ProfitCenterName
*    FROM I_OperationalAcctgDocItem AS a
**    LEFT JOIN i_cnsldtnglaccountvh AS b ON a~GLAccount = b~GLAccount
*    inner JOIN I_GLACCOUNTTEXTRAWDATA AS b ON a~GLAccount = b~GLAccount
*    LEFT JOIN i_costcentertext AS c ON a~CostCenter = c~CostCenter AND c~Language = 'E'
*    LEFT JOIN i_profitcentertext AS d ON a~ProfitCenter = d~ProfitCenter AND d~Language = 'E'
*     where  a~AccountingDocument = '1900000000'" @lv_belnr2 "
*    INTO TABLE @DATA(it_lines).


**

SELECT SINGLE
    a~accountingdocumenttype,
    a~accountingdocument,
    a~postingdate,
    a~FinancialAccountType,
    a~Customer,
    a~supplier,
*    a~OffsettingAccountType,
    a~OffsettingAccount,
*    a~AmountInCompanyCodeCurrency,
    b~CustomerName,
    c~suppliername,
    d~GLAccountType
    FROM I_OperationalAcctgDocItem AS a
    LEFT JOIN I_Customer AS b ON a~customer = b~customer and a~AccountingDocumentType = 'DZ'
    LEFT JOIN I_Supplier AS c ON a~Supplier = c~Supplier
    LEFT JOIN I_GLACCOUNTSTDVH AS d ON a~GLAccount = d~GLAccount and d~GLAccountType = 'C'
    WHERE a~AccountingDocument  = '1400000000'
     and ( a~FinancialAccountType = 'K' OR a~FinancialAccountType = 'D' )
    INTO @DATA(wa).

    SELECT single
   a~AbsoluteAmountInCoCodeCrcy
   FROM I_OperationalAcctgDocItem AS a
   WHERE a~AccountingDocument  = '1400000000'
   and a~FinancialAccountType = 'S'
   and a~HouseBankAccount is not INITIAL
   into @data(a).

    DATA : Vendor TYPE String.
*    CONCATENATE: wa-Supplier wa-SupplierName INTO Vendor SEPARATED BY space.
   IF wa-Supplier IS NOT INITIAL AND wa-SupplierName IS NOT INITIAL.
    CONCATENATE: wa-Supplier wa-SupplierName INTO Vendor SEPARATED BY ' / '.
    endif.
    IF wa-Customer IS NOT INITIAL AND wa-CustomerName IS NOT INITIAL.
    DATA : Customer TYPE String.
*    CONCATENATE: wa-Customer wa-CustomerName INTO Customer SEPARATED BY space.
    CONCATENATE wa-Customer wa-CustomerName INTO Customer SEPARATED BY ' / '.
    endif.




*******************************************************************************Header XML
DATA(lv_xml) = |<Form>| &&
               |<InternalDocumentNode>| &&
               |<AccmountingDocument>{ wa-AccountingDocument }</AccountingDocument>| &&
               |<AccountingDocumentType>{ wa-AccountingDocumentType }</AccountingDocumentType>| &&
               |<PostingDate>{ wa-PostingDate }</PostingDate>| &&
               |<OffsettingAccountType>{ wa-FinancialAccountType }</OffsettingAccountType>| &&
               |<CustomerName>{ wa-CustomerName }</CustomerName>| &&
               |<SupplierName>{ wa-SupplierName }</SupplierName>| &&
               |<GLAccountType>{ wa-GLAccountType }</GLAccountType>| &&
               |<AmountInCompanyCodeCurrency>{ a }</AmountInCompanyCodeCurrency>| &&
               |</InternalDocumentNode>| &&
               |</Form>|.
*


    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = 'zmoneyreceipt/zmoneyreceipt'
      RECEIVING
        result   = result12 ).
ENDMETHOD.
ENDCLASS.
