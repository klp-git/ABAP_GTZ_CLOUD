CLASS zcl_Money_receipt DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*    INTERFACES if_oo_adt_classrun.
    CLASS-METHODS :

      read_posts
        IMPORTING lv_belnr2      TYPE string
                 lv_fiscal type string
                  lv_company type string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_template_name TYPE string VALUE 'zmoneyreceipt/zmoneyreceipt'."'zpo/zpo_v2'."
ENDCLASS.



CLASS ZCL_MONEY_RECEIPT IMPLEMENTATION.


  METHOD read_posts .

*******************************************************************************Header Select Query
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
    LEFT JOIN I_Customer AS b ON a~customer = b~customer and a~AccountingDocumentType IN ( 'DZ','KZ','CV' )
    LEFT JOIN I_Supplier AS c ON a~Supplier = c~Supplier
    LEFT JOIN I_GLACCOUNTSTDVH AS d ON a~GLAccount = d~GLAccount and d~GLAccountType = 'C'
    WHERE a~AccountingDocument  = @lv_belnr2 AND a~fiscalyear = @lv_fiscal AND a~CompanyCode = @lv_company
     and ( a~FinancialAccountType = 'K' OR a~FinancialAccountType = 'D' )
    INTO @DATA(wa).


  SELECT single
   a~AbsoluteAmountInCoCodeCrcy,
   a~ASSIGNMENTREFERENCE
   FROM I_OperationalAcctgDocItem AS a
   WHERE a~AccountingDocument  =  @lv_belnr2  AND a~fiscalyear = @lv_fiscal AND a~CompanyCode = @lv_company"'1400000001'
   and a~FinancialAccountType = 'S'
   and a~HouseBankAccount is not INITIAL
   into @data(a).

   if a is INITIAL.
     SELECT single
   a~AbsoluteAmountInCoCodeCrcy,
   a~ASSIGNMENTREFERENCE
   FROM I_OperationalAcctgDocItem AS a
   WHERE a~AccountingDocument  =  @lv_belnr2  AND a~fiscalyear = @lv_fiscal AND a~CompanyCode = @lv_company"'1400000001'
   and a~FinancialAccountType = 'S'
   and a~HouseBankAccount is  INITIAL
   into @data(header).

   a-AbsoluteAmountInCoCodeCrcy = header-AbsoluteAmountInCoCodeCrcy.
   a-AssignmentReference = header-AssignmentReference.

   ENDIF.




****** Variables ******
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
               |<AccountingDocument>{ wa-AccountingDocument }</AccountingDocument>| &&
               |<AccountingDocumentType>{ wa-AccountingDocumentType }</AccountingDocumentType>| &&
               |<PostingDate>{ wa-PostingDate }</PostingDate>| &&
               |<OffsettingAccountType>{ wa-FinancialAccountType }</OffsettingAccountType>| &&
               |<OffsettingAccount>{ wa-OffsettingAccount }</OffsettingAccount>| &&
               |<CustomerName>{ Customer }</CustomerName>| &&
               |<SupplierName>{ Vendor }</SupplierName>| &&
               |<PaymentMode>{ a-AssignmentReference }</PaymentMode>| &&
               |<GLAccountType>{ wa-GLAccountType }</GLAccountType>| &&
               |<AmountInCompanyCodeCurrency>{ a-AbsoluteAmountInCoCodeCrcy }</AmountInCompanyCodeCurrency>| &&
               |</InternalDocumentNode>| &&
               |</Form>|.
*


    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

  ENDMETHOD.
ENDCLASS.
