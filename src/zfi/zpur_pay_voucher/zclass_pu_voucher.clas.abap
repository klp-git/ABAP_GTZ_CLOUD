CLASS zclass_pu_voucher DEFINITION
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
        IMPORTING cleardoc        TYPE string
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
    CONSTANTS lc_template_name TYPE string VALUE 'zfi_pay_adv/zfi_pay_adv'."'zpo/zpo_v2'."
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.
ENDCLASS.



CLASS ZCLASS_PU_VOUCHER IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .

********** Header level data*********************
    SELECT SINGLE
       a~accountingdocument,
       a~postingdate,
       b~accountingdocumentheadertext,
       a~amountincompanycodecurrency,
       c~documentdate,
       a~supplier,
       d~BPSupplierFullName,
       e~glaccountlongname,
       f~CompanyCodeName,
      d~suppliername ,
    d~cityname,
    d~streetname,
    d~country,
    d~postalcode,
    d~taxnumber3,
     g~regionname


       FROM i_operationalacctgdocitem AS a

       LEFT JOIN  i_accountingdocumentjournal  AS b ON a~AccountingDocument = b~AccountingDocument AND a~CompanyCode = b~companycode AND b~Ledger = '0L' AND a~FiscalYear = b~FiscalYear
       LEFT JOIN i_supplier AS d ON a~Supplier = d~Supplier AND a~FinancialAccountType = 'K'
       LEFT JOIN i_companycode AS f ON a~companycode = f~CompanyCode
        LEFT JOIN i_regiontext WITH PRIVILEGED ACCESS  AS g ON d~Region = g~Region
       LEFT JOIN i_glaccounttextrawdata AS e ON  b~glaccount = e~GLAccount
       LEFT JOIN  i_accountingdocumentjournal  AS c ON a~AccountingDocument = c~AccountingDocument AND a~CompanyCode = c~companycode AND c~GLAccountType = 'C'
        WHERE a~AccountingDocument =  @cleardoc  AND a~FinancialAccountType IN ('K', 'S')   AND b~HouseBank IS NOT INITIAL  AND a~FISCALYEAR = @lv_fiscal
        AND a~CompanyCode = @lv_company  "" a~FiscalYear = '2024' AND a~CompanyCode = 'GT00'
      ""  AND a~fiscalyear = @lv_fiscal AND a~CompanyCode = @lv_company
           INTO @DATA(wa).

       SELECT SINGLE
       a~accountingdocument,
       a~postingdate,
       b~accountingdocumentheadertext,
       a~amountincompanycodecurrency,

       a~supplier,
       d~BPSupplierFullName,

      d~suppliername ,
    d~cityname,
    d~streetname,
    d~country,
    d~postalcode,
    d~taxnumber3,
    g~regionname



       FROM i_operationalacctgdocitem AS a

       LEFT JOIN  i_accountingdocumentjournal  AS b ON a~AccountingDocument = b~AccountingDocument AND a~CompanyCode = b~companycode AND b~Ledger = '0L' AND a~FiscalYear = b~FiscalYear
       LEFT JOIN i_supplier AS d ON a~Supplier = d~Supplier
        LEFT JOIN i_regiontext WITH PRIVILEGED ACCESS  AS g ON d~Region = g~Region

        WHERE a~AccountingDocument =  @cleardoc  AND a~FinancialAccountType = 'K'  AND a~FISCALYEAR = @lv_fiscal
        AND a~CompanyCode = @lv_company

           INTO @DATA(str1).

    DATA: supplier_add TYPE string.
    CONCATENATE str1-StreetName   str1-CityName  str1-RegionName  str1-PostalCode  str1-Country  INTO supplier_add SEPARATED BY space.
     data str2 type string.
     CONCATENATE str1-Supplier str1-BPSupplierFullName INTO str2 SEPARATED BY space.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
*    SELECT SINGLE
*    a~accountingdocument,
*    a~postingdate,
*    a~documentdate,
*    a~supplier, " this is take for joining
*    a~documentdate AS  documentdate2,
*    a~amountincompanycodecurrency,
*    b~CompanyCodeName, "done
*    c~plantname,
*    d~BPSupplierFullName,
*    f~glaccountlongname,
*    e~accountingdocumentheadertext
*
*    FROM i_operationalacctgdocitem AS a
*    LEFT JOIN i_companycode AS b ON a~companycode = b~companycode
*    LEFT JOIN i_plant AS c ON a~BusinessPlace  = c~Plant
*    LEFT JOIN i_supplier AS d ON a~Supplier = d~Supplier
*    LEFT JOIN i_accountingdocumentjournal AS e ON a~clearingAccountingDocument = e~AccountingDocument AND a~CompanyCode = e~CompanyCode
*                                                    AND a~ClearingDocFiscalYear = e~FiscalYear
*    LEFT JOIN i_glaccounttextrawdata AS f ON  e~glaccount = f~glaccount
*                     WHERE a~clearingAccountingDocument = @cleardoc AND a~accountingdocumentitem = '002'
*                     " AND e~GLAccountType = 'C' AND e~Ledger = '0L'

********Item level data***************
    IF wa IS NOT INITIAL.
      SELECT
       a~accountingdocument,
       a~businessplace,
       a~accountingdocumenttype,
       a~withholdingtaxamount,
       a~amountincompanycodecurrency,
       b~documentreferenceid,
       b~documentdate
     FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
     INNER JOIN i_journalentry AS b ON a~AccountingDocument = b~AccountingDocument AND a~FiscalYear = b~FiscalYear

      WHERE a~ClearingJournalEntry = @cleardoc
      AND a~CLEARINGJOURNALENTRYFISCALYEAR = @lv_fiscal AND a~CompanyCode = @lv_company
       AND a~TaxSection is NOT INITIAL  AND a~FinancialAccountType = 'K'


     INTO TABLE @DATA(item).
    ENDIF.

    DATA(lv_xml) =
    |<Form>| &&
    |<Header>| &&
    |<company_name>{ wa-CompanyCodeName }</company_name>| &&
    |<Branch></Branch>| &&
*    |<supplier>{ wa-supplier }</supplier>| &&
    |<GST_NO>{ str1-TaxNumber3 }</GST_NO>| &&
    |<supplier_add>{ supplier_add }</supplier_add>| &&
    |<Voucher_No>{ wa-AccountingDocument }</Voucher_No>| &&
    |<Voucher_Date>{ wa-PostingDate }</Voucher_Date>| &&
    |<payment_From>{ wa-GLAccountLongName }</payment_From>| &&
    |<payment_To>{ str2 }</payment_To>| &&
    |<Cheq_Neft_Rtgs_No>{ wa-AccountingDocumentHeaderText }</Cheq_Neft_Rtgs_No>| &&
    |<Cheq_Neft_Rtgs_Date>{ wa-DocumentDate }</Cheq_Neft_Rtgs_Date>| &&
    |<Payment_To></Payment_To>| &&
    |<Logic_for_data_inpara>{ wa-PostingDate }</Logic_for_data_inpara>| &&
    |<Logic_for_Amount_inpara>{ wa-AmountInCompanyCodeCurrency }</Logic_for_Amount_inpara>| &&
    |</Header>| &&
    |<LineItem>|.

    LOOP AT item INTO DATA(wa_item).
      DATA(lv_xml_table) =
        |<item>| &&
        |<Sr_No></Sr_No>| &&
        |<Document_No>{ wa_item-AccountingDocument }</Document_No>| &&
        |<Business_Place>{ wa_item-BusinessPlace }</Business_Place>| &&
        |<Document_Type>{ wa_item-AccountingDocumentType }</Document_Type>| &&
        |<Invoice_Ref_No>{ wa_item-DocumentReferenceID }</Invoice_Ref_No>| &&
        |<Invoice_Ref_Date>{ wa_item-DocumentDate }</Invoice_Ref_Date>| &&
        |<Invoice_Amount></Invoice_Amount>| &&
        |<TDS_Amount>{ wa_item-WithholdingTaxAmount }</TDS_Amount>| &&
        |<Net_Amount>{ wa_item-AmountInCompanyCodeCurrency }</Net_Amount>| &&
        |<Total></Total>| &&
        |</item>|.
      CONCATENATE lv_xml lv_xml_table INTO lv_xml.
    ENDLOOP.
    CONCATENATE lv_xml '</LineItem>' '</Form>' INTO lv_xml. " Properly closing the root tag.


    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).
  ENDMETHOD.
ENDCLASS.
