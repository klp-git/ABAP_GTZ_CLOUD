CLASS zcl_voucher_print_dr DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*    INTERFACES if_oo_adt_classrun .
    CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
    TYPES :
      BEGIN OF struct,
        xdp_template TYPE string,
        xml_data     TYPE string,
        form_type    TYPE string,
        form_locale  TYPE string,
        tagged_pdf   TYPE string,
        embed_font   TYPE string,
      END OF struct."


    CLASS-METHODS :
      create_client
        IMPORTING url           TYPE string
        RETURNING VALUE(result) TYPE REF TO if_web_http_client
        RAISING   cx_static_check ,

      read_posts
        IMPORTING lv_belnr2       TYPE string
                  lv_fiscal type string
                  lv_company type string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zfi_voucher_print/zfi_voucher_print'."'zpo/zpo_v2'."
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.

ENDCLASS.



CLASS ZCL_VOUCHER_PRINT_DR IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .

    SELECT SINGLE
    a~companycode,
 a~fiscalyear, a~AccountingDocument,
                  a~PostingDate,
                  a~DocumentDate,
                  a~FinancialAccountType,
*                  a~Supplier,
*                  a~Customer,
                  d~DocumentReferenceID,
*                  a~AssignmentReference,
                  a~AccountingDocumentType,
                  a~companycodecurrency,
                  a~transactioncurrency,
                  e~ACCOUNTINGDOCUMENTTYPENAME
*                  b~CustomerName,
*                  c~SupplierName
     FROM I_OperationalAcctgDocItem AS a
*     LEFT JOIN I_Customer AS b ON a~Customer = b~Customer
*     LEFT JOIN I_Supplier AS c ON a~Supplier = c~Supplier
     LEFT JOIN i_journalentry AS d ON a~AccountingDocument = d~AccountingDocument AND a~CompanyCode = d~CompanyCode AND a~FiscalYear = d~FiscalYear
     LEFT JOIN I_ACCOUNTINGDOCUMENTJOURNAL WITH PRIVILEGED ACCESS as e on a~AccountingDocumentType = e~AccountingDocumentType AND a~AccountingDocument = e~AccountingDocument
     WHERE "( a~Supplier IS NOT INITIAL OR a~Customer IS NOT INITIAL )  AND
       a~AccountingDocument =  @lv_belnr2    AND a~fiscalyear = @lv_fiscal AND a~CompanyCode = @lv_company    "'1300000014'
*       and ( a~FinancialAccountType = 'K' OR a~FinancialAccountType = 'D' )

     INTO @DATA(wa).

     data documentstring type string.
     CONCATENATE wa-AccountingDocumentType '-' wa-AccountingDocumentTypeName INTO documentstring.



    SELECT SINGLE
             a~Supplier,
             a~Customer,
             a~AccountingDocumentType,
             b~CustomerName,
             c~SupplierName,
             b~bpcustomerfullname,
             b~taxnumber3,
             b~cityname,
             b~postalcode,
             b~streetname
FROM I_OperationalAcctgDocItem AS a
LEFT JOIN I_Customer AS b ON a~Customer = b~Customer
LEFT JOIN I_Supplier AS c ON a~Supplier = c~Supplier
LEFT JOIN i_journalentry AS d ON a~AccountingDocument = d~AccountingDocument AND a~CompanyCode = d~CompanyCode AND a~FiscalYear = d~FiscalYear
WHERE "( a~Supplier IS NOT INITIAL OR a~Customer IS NOT INITIAL )  AND
  a~AccountingDocument =  @lv_belnr2   AND a~fiscalyear = @lv_fiscal AND a~CompanyCode = @lv_company   "'1300000014'
  AND ( a~FinancialAccountType = 'K' OR a~FinancialAccountType = 'D' )
INTO @DATA(CustVen).

    DATA : customer_add TYPE string.
    CONCATENATE  custven-StreetName ' ' custven-CityName ' ' custven-PostalCode INTO customer_add SEPARATED BY space.
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
*
*    SELECT a~GLAccount , a~AmountInCompanyCodeCurrency , a~DocumentItemText, a~GLAccountName, a~TransactionTypeDetermination,
*           a~CostCenter , a~CostCenterName , a~ProfitCenter , a~ProfitCenterName
*           FROM zcdsVoucher AS a
*           WHERE AccountingDocument =  @lv_belnr2 "'1300000014'
*           AND a~TransactionTypeDetermination NE 'AGX'
*           AND a~TransactionTypeDetermination NE 'EGX'
*         AND a~fiscalyear = @lv_fiscal AND a~CompanyCode = @lv_company
*           INTO TABLE @DATA(it_lines).

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
             d~taxcodeName






             FROM  i_accountingdocumentjournal WITH PRIVILEGED ACCESS as a
             LEFT JOIN I_ProfitCenterText   WITH PRIVILEGED ACCESS as b on a~ProfitCenter = b~ProfitCenter and b~Language = 'E'
             LEFT JOIN i_costcentertext  WITH PRIVILEGED ACCESS as c on a~CostCenter = c~CostCenter
             LEFT JOIN i_taxcodetext WITH PRIVILEGED ACCESS as d on a~taxcode = d~TaxCode

             WHERE a~AccountingDocument = @lv_belnr2  AND a~fiscalyear = @lv_fiscal AND a~CompanyCode = @lv_company
             AND a~Ledger = '0L' AND a~GLAccount <> '0029500100'

             INTO TABLE @DATA(it_lines).


*
*           SELECT SINGLE
*           a~ACCOUNTINGDOCCREATEDBYUSER,
*           a~PARKEDBYUSER,
*           b~CreatedByUser,
*           b~BUSINESSPARTNERFULLNAME
*           FROM I_JOURNALENTRY WITH PRIVILEGED ACCESS as a
*           LEFT JOIN I_BUSINESSPARTNER WITH PRIVILEGED ACCESS as b on substring(a~AccountingDocCreatedByUser,2) = b~BusinessPartner
*
*           WHERE AccountingDocument =  @lv_belnr2
*           INTO @DATA(wa_footer).
    SELECT SINGLE
           a~accountingdoccreatedbyuser,
           a~parkedbyuser
        FROM i_journalentry WITH PRIVILEGED ACCESS AS a
        WHERE a~AccountingDocument = @lv_belnr2  AND a~fiscalyear = @lv_fiscal AND a~CompanyCode = @lv_company
        INTO @DATA(wa_footer).

    DATA: lv_user TYPE string.
    DATA: lv_user_length TYPE i.
    lv_user_length = strlen( wa_footer-AccountingDocCreatedByUser ).
    lv_user_length = lv_user_length - 2.
    lv_user = wa_footer-AccountingDocCreatedByUser+2(lv_user_length).

    SELECT SINGLE FROM I_BusinessPartner AS a
    FIELDS a~BusinessPartnerFullName
    WHERE a~BusinessPartner = @lv_user
    INTO @DATA(wa_footername).

*    DATA: lv_usercheck TYPE i.

    SELECT SINGLE
           a~accountingdoccreatedbyuser,
           a~parkedbyuser
        FROM i_journalentry WITH PRIVILEGED ACCESS AS a
        WHERE a~AccountingDocument = @lv_belnr2  AND a~fiscalyear = @lv_fiscal AND a~CompanyCode = @lv_company
        INTO @DATA(wa_footernamestring).

    IF wa_footernamestring-ParkedByUser IS NOT INITIAL.
      DATA: lv_usercheck TYPE string.
      DATA: lv_usercheck_length  TYPE i.
*      lv_usercheck_length = wa_footernamestring-ParkedByUser.
      lv_usercheck_length = strlen( wa_footernamestring-ParkedByUser ).
      lv_usercheck_length = lv_usercheck_length - 2.
      lv_usercheck = wa_footernamestring-ParkedByUser+2(lv_usercheck_length).

      SELECT SINGLE FROM I_BusinessPartner AS b
      FIELDS b~BusinessPartnerFullName
      WHERE b~BusinessPartner = @lv_usercheck
      INTO @DATA(wa_footernamecheck).
    ENDIF.



    IF wa_footernamecheck IS INITIAL.
      wa_footernamecheck = wa_footername.
      wa_footer-ParkedByUser = wa_footer-AccountingDocCreatedByUser.
    ENDIF.
*



    SELECT SINGLE
a~companycode,
a~fiscalyear,
     d~suppliername ,
    d~cityname,
    d~streetname,
    d~country,
    d~postalcode,
    d~taxnumber3,
*    a~amountincompanycodecurrency,
*    c~documentdate,
*    a~supplier,
*    d~SupplierFullName,
*    e~glaccountlongname,
*    f~CompanyCodeName,
*     g~regionname,
     h~countryname
*      b~cityname,
*    d~streetname,
*    b~region,
*    b~country,
*    b~postalcode,
*    b~taxnumber3,
*    c~regionname,
*    d~countryname,


       FROM i_operationalacctgdocitem AS a

       LEFT JOIN  i_accountingdocumentjournal  AS b ON a~AccountingDocument = b~AccountingDocument AND a~CompanyCode = b~companycode AND b~Ledger = '0L'
       LEFT JOIN i_supplier AS d ON a~Supplier = d~Supplier
       LEFT JOIN i_regiontext WITH PRIVILEGED ACCESS  AS g ON d~Region = g~Region
       LEFT JOIN i_companycode AS f ON a~companycode = f~CompanyCode
       LEFT JOIN i_countrytext WITH PRIVILEGED ACCESS  AS h ON g~Country = h~Country
       LEFT JOIN i_glaccounttextrawdata AS e ON  b~glaccount = e~GLAccount
       LEFT JOIN  i_accountingdocumentjournal  AS c ON a~AccountingDocument = c~AccountingDocument AND a~CompanyCode = c~companycode AND c~GLAccountType = 'C'
      WHERE "( a~Supplier IS NOT INITIAL OR a~Customer IS NOT INITIAL )  AND
  a~AccountingDocument =  @lv_belnr2  "'1300000014'
  AND ( a~FinancialAccountType = 'K' OR a~FinancialAccountType = 'D' )
 AND a~fiscalyear = @lv_fiscal AND a~CompanyCode = @lv_company

        INTO @DATA(wa_supplier_add).

    DATA: supplier_add TYPE string.

    CONCATENATE wa_supplier_add-StreetName ' ' wa_supplier_add-Country ' ' wa_supplier_add-CityName ' ' wa_supplier_add-CountryName ' ' wa_supplier_add-PostalCode INTO supplier_add SEPARATED BY space.





****** Variables ******
    DATA : Vendor TYPE String.
*    CONCATENATE: wa-Supplier wa-SupplierName INTO Vendor SEPARATED BY space.
    IF CustVen-Supplier IS NOT INITIAL AND CustVen-SupplierName IS NOT INITIAL.
      CONCATENATE: CustVen-Supplier CustVen-SupplierName INTO Vendor SEPARATED BY space.
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
                      |<Doc_currency>{ wa-CompanyCodeCurrency }</Doc_currency>| &&
                      |<Tran_currency>{ wa-TransactionCurrency }</Tran_currency>| &&
*                     |<AccountingDocumentType>{ wa-AccountingDocumentTypeName }</AccountingDocumentType>| &&
                     |<AccountingDocumentType>{ documentstring }</AccountingDocumentType>| &&
                      |<PostingDate>{ wa-PostingDate }</PostingDate>| &&
                      |<DocumentReferenceID>{ wa-DocumentReferenceID }</DocumentReferenceID>| && "0002000004
                      |<DocumentDate>{ wa-DocumentDate }</DocumentDate>| &&
                      |<OffsettingAccountType>{ wa-FinancialAccountType }</OffsettingAccountType>| &&
                      |<Vendor>{ Vendor }</Vendor>| &&
                      |<Vendor_Add>{ supplier_add }</Vendor_Add>| &&
                      |<Vendor_gst>{ wa_supplier_add-TaxNumber3 }</Vendor_gst>| &&
                      |<Customer>{ Customer }</Customer>| &&
                      |<Customer_Add>{ customer_add }</Customer_Add>| &&
                      |<Customer_Gst>{ custven-TaxNumber3 }</Customer_Gst>| &&
                      |<Entered_By>{ wa_footer-ParkedByUser }</Entered_By>| &&
                      |<Entered_By_FullName>{ wa_footernamecheck }</Entered_By_FullName>| &&
                      |<Checked_By>{ wa_footer-AccountingDocCreatedByUser }</Checked_By>| &&
                      |<Checked_By_fullName>{ wa_footername }</Checked_By_fullName>| &&
*                      |<CustomerName>{ wa-CustomerName }</CustomerName>| &&
                      |</InternalDocumentNode>| &&
                      |<Table>|.

* Item
    LOOP AT it_lines INTO DATA(wa_lines).
      DATA(lv_xml1) = |<tableDataRows>| &&
                   |<GLAccount>{ wa_lines-GLAccount }</GLAccount>| &&
                   |<GLAccountName>{ wa_lines-GLAccountName }</GLAccountName>| &&
*                   |<GLAccountName> A/P - Capital Goods </GLAccountName>| &&
                   |<ProfitCenter>{ wa_lines-ProfitCenter }</ProfitCenter>| &&
                   |<ProfitCenterDescription>{ wa_lines-ProfitCenterName }</ProfitCenterDescription>| &&
                   |<CostCenter>{ wa_lines-CostCenter }</CostCenter>| &&
                   |<CostCenterDescription>{ wa_lines-CostCenterName }</CostCenterDescription>| &&
                   |<AmountInCompanyCodeCurrency>{ wa_lines-CreditAmountInCoCodeCrcy }</AmountInCompanyCodeCurrency>| &&
                   |<DebitAmountInCoCodeCrcy>{ wa_lines-DebitAmountInCoCodeCrcy }</DebitAmountInCoCodeCrcy>| &&
                   |<Taxcode>{ wa_lines-TaxCode }</Taxcode> | &&
                   |<TaxDescription>{ wa_lines-TaxCodeName }</TaxDescription>| &&
                   |<Narration>{ wa_lines-DocumentItemText }</Narration>| &&
                   |</tableDataRows>| .

      CLEAR : wa_lines.
      CONCATENATE: lv_xml lv_xml1 INTO lv_xml.
    ENDLOOP.
    DATA(lv_xml2) = |</Table>| &&
                    |</AccountingRow>| &&
                    |</Form>|.
    CONCATENATE: lv_xml lv_xml2 INTO lv_xml.

    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

  ENDMETHOD .
ENDCLASS.
