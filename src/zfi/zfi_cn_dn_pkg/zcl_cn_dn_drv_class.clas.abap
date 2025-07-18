CLASS   zcl_cn_dn_drv_class DEFINITION
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
*  accounting  = accounting   CompanyCode = companycode  FiscalYear = FiscalYear
      read_posts
        IMPORTING accounting_no   TYPE string
                  Company_code    TYPE string
                  fiscal_year     TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zfi_cn_dn/zfi_cn_dn'."'zpo/zpo_v2'."
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.

ENDCLASS.



CLASS zcl_cn_dn_drv_class IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .



    DATA : pan_DS    TYPE string,
           state_cds TYPE string.

    " Header
    SELECT SINGLE
           a~PostingKey,
           b~CompanyCodeName,
           AccountingDocumentType
      FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
      INNER JOIN I_CompanyCode WITH PRIVILEGED ACCESS AS b
        ON a~CompanyCode = b~CompanyCode
      WHERE a~AccountingDocument = @accounting_no
        AND a~FiscalYear         = @fiscal_year
        AND a~CompanyCode        = @Company_code
        AND a~FinancialAccountType = 'K'
        AND ( a~AccountingDocumentType = 'KG'
           OR  a~AccountingDocumentType = 'KC'
            OR  a~AccountingDocumentType = 'DD'
             OR  a~AccountingDocumentType = 'DG' )
      INTO @DATA(lv_head).

    DATA: lv_devitname TYPE string.
    IF lv_head-AccountingDocumentType = 'KG'.
      lv_devitname = 'Vendor Debit Note' .
    ELSEIF lv_head-AccountingDocumentType = 'KC'.
      lv_devitname = 'Vendor Credit Note'.
    ELSEIF lv_head-AccountingDocumentType = 'DD'.
      lv_devitname = 'Customer Debit Note'.
    ELSEIF lv_head-AccountingDocumentType = 'DG'.
      lv_devitname = 'Customer Credit Note'.
    ENDIF.
    " Footer
    SELECT SINGLE a~DocumentItemText
      FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
      WHERE a~AccountingDocument = @accounting_no
        AND a~FiscalYear         = @fiscal_year
        AND a~CompanyCode        = @Company_code
        AND a~FinancialAccountType = 'K'
        AND ( a~TransactionTypeDetermination = 'KBS'
           OR  a~TransactionTypeDetermination = 'EGK' )
      INTO @DATA(lv_FOOT).

    " Detail of Supplier
    SELECT SINGLE
           a~accountingdocument,
           a~postingdate,
           a~documentdate,
           a~withholdingtaxamount,
           c~TaxNumber3,       " GST number etc.
           c~suppliername,
           c~cityname,
           c~streetname,
           c~region,
           c~postalcode,
           d~documentreferenceid,
           d~originalreferencedocument,
           e~regionname
      FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
      LEFT JOIN i_supplier       WITH PRIVILEGED ACCESS AS c ON a~Supplier = c~Supplier
      LEFT JOIN i_journalentry   WITH PRIVILEGED ACCESS AS d ON a~AccountingDocument = d~AccountingDocument
                                                           AND a~CompanyCode        = d~CompanyCode
                                                           AND a~FiscalYear         = d~FiscalYear
      LEFT JOIN i_regiontext     WITH PRIVILEGED ACCESS AS e ON a~IN_GSTPlaceOfSupply = e~region
      WHERE a~AccountingDocument = @accounting_no
        AND a~FiscalYear         = @fiscal_year
        AND a~CompanyCode        = @Company_code
        AND a~FinancialAccountType = 'K'
      INTO @DATA(wa_head).
    DATA doc_date TYPE string.
    doc_date = wa_head-DocumentDate.
    pan_DS    = wa_head-TaxNumber3+2(10). "pan number
    state_cds = wa_head-TaxNumber3+0(2). "state code

    " BILL TO
    SELECT SINGLE
           a~accountingdocument,
           a~fiscalyear,
           a~companycode,
           a~in_gstplaceofsupply, " gst
           a~region,
           b~plantname,
           b~plant,
           c~taxnumber1,         " gstin
           c~businesstypelist,    " cin
           c~businessplacename,
           d~regionname
      FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
      LEFT JOIN i_plant            WITH PRIVILEGED ACCESS AS b ON a~BusinessPlace = b~Plant
      LEFT JOIN i_kr_businessplace WITH PRIVILEGED ACCESS AS c ON a~BusinessPlace = c~branch
      LEFT JOIN i_regiontext       WITH PRIVILEGED ACCESS AS d ON a~IN_GSTPlaceOfSupply = d~region
      WHERE a~AccountingDocument = @accounting_no
        AND a~FiscalYear         = @fiscal_year
        AND a~CompanyCode        = @Company_code
      INTO @DATA(wa_head_bill).

    DATA : bill_ad1 TYPE string,
           bill_ad2 TYPE string,
           bill_ad3 TYPE string,
           pan      TYPE string,
           state_cd TYPE string.

    pan      = wa_head_bill-TaxNumber1+2(10).
    state_cd = wa_head_bill-TaxNumber1+0(2).

    " ITEM DETAILS - Join with I_ProductText and I_GLACCOUNTTEXTRAWDATA in one query
*    SELECT
*           a~product,
*           a~costelement,
*           coalesce( d~glaccountlongname, b~productname, a~product ) AS itemname,
*           a~in_hsnorsaccode,
*           a~quantity,
*           a~glaccount,
*           a~baseunit,
*           a~absoluteamountincocodecrcy,
*           a~AccountingDocument,
*           a~fiscalyear,
*           a~companycode,
*           a~accountingdocumentitem,
*           a~taxitemgroup,
*           a~taxcode,
*           d~glaccountlongname,
*           b~productname
*
*      FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
*      LEFT JOIN i_producttext         WITH PRIVILEGED ACCESS AS b ON a~Product    = b~Product
*      LEFT JOIN i_glaccounttextrawdata WITH PRIVILEGED ACCESS AS d ON a~GLAccount = d~glaccount
*      WHERE ( a~AccountingDocumentItemType = 'W'
*           OR  a~AccountingDocumentItemType = ' '  )
**        AND ( a~TransactionTypeDetermination = 'WRX'
**           OR  a~TransactionTypeDetermination = ' '  )
*        AND ( a~TransactionTypeDetermination IN ( 'WRX','RKA' )
*           OR  a~TransactionTypeDetermination = ' '  )
*     AND a~CostElement <> '0052060000' AND a~GLAccount <> '0052060000'
**      AND a~FinancialAccountType = 'S' OR a~TransactionTypeDetermination = 'KBS'
*        AND a~AccountingDocument = @accounting_no
*        AND a~FiscalYear         = @fiscal_year
*        AND a~CompanyCode        = @Company_code
*      INTO TABLE @DATA(it_item).

    SELECT
         a~product,
         a~costelement,
         coalesce( d~glaccountlongname, b~productname, a~product ) AS itemname,
         a~in_hsnorsaccode,
         a~quantity,
         a~glaccount,
         a~baseunit,
       a~absoluteamountincocodecrcy   ,
         a~AccountingDocument,
         a~fiscalyear,
         a~companycode,
         a~accountingdocumentitem,
         a~taxitemgroup,
         a~taxcode,
         d~glaccountlongname,
         b~productname,
*           e~ReferenceDocumentItemGroup,
         a~AccountingDocumentItemType,
         a~TransactionTypeDetermination

    FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
    LEFT JOIN i_producttext         WITH PRIVILEGED ACCESS AS b ON a~Product    = b~Product
    LEFT JOIN i_glaccounttextrawdata WITH PRIVILEGED ACCESS AS d ON a~GLAccount = d~glaccount

*    LEFT JOIN i_accountingdocumentjournal WITH PRIVILEGED ACCESS as e on a~AccountingDocument = e~AccountingDocument
*    AND a~CompanyCode = e~CompanyCode AND a~FiscalYear = e~FiscalYear and a~taxi

    WHERE
    ( ( a~AccountingDocumentItemType IN ( 'P','W','M' )  OR a~AccountingDocumentItemType IS INITIAL )
    AND  ( a~TransactionTypeDetermination IN ( 'PRD','WRX','RKA','BSX' ) OR  a~TransactionTypeDetermination IS INITIAL  ) )
*    ( ( a~AccountingDocumentItemType IN ( 'P','W' )  AND a~TransactionTypeDetermination IN ( 'PRD','WRX','RKA' ) )
*    OR  ( a~AccountingDocumentItemType IS INITIAL AND  a~TransactionTypeDetermination IS INITIAL  ) )
    AND a~CostElement <> '0052060000'
    AND a~GLAccount <> '0052060000'
    AND a~AccountingDocument = @accounting_no
    AND a~FiscalYear         = @fiscal_year
    AND a~CompanyCode        = @Company_code

    INTO TABLE @DATA(it_item).



    SELECT
    a~product,
    a~costelement,
    a~absoluteamountincocodecrcy,
   a~fiscalyear,
  a~companycode,
   a~accountingdocumentitem,
   a~TaxItemGroup,
   a~taxcode,
   a~baseunit,
    a~quantity,
  a~AccountingDocument,
      d~glaccountlongname
     FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
*    LEFT JOIN i_producttext         WITH PRIVILEGED ACCESS AS b ON a~Product    = b~Product
    LEFT JOIN i_glaccounttextrawdata WITH PRIVILEGED ACCESS AS d ON a~GLAccount = d~glaccount
   WHERE (
            a~AccountingDocumentItemType = 'S' AND a~TransactionTypeDetermination = 'KBS'

         )

         AND a~CostElement <> '0052060000'

           AND a~AccountingDocument = @accounting_no
      AND a~FiscalYear         = @fiscal_year
      AND a~CompanyCode        = @Company_code

    INTO TABLE @DATA(it_itemnamestring).
    DATA str1 TYPE string.
"""""""""    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
 sort it_item BY Product.
      DELETE ADJACENT DUPLICATES FROM it_item COMPARING Product.

    DATA: wa_item2 LIKE LINE OF it_item.
    IF it_item IS INITIAL.
      LOOP AT it_itemnamestring INTO DATA(wa_it_itemnamestring).

*        str1 = wa_it_itemnamestring-CostElement.
*
*      ENDIF.
*      if str1 is NOT INITIAL.
*        wa_item_productstring = str1.
*      ENDIF.
        wa_item2-product = wa_it_itemnamestring-Product.
        wa_item2-CostElement = wa_it_itemnamestring-CostElement.
        wa_item2-AbsoluteAmountInCoCodeCrcy = wa_it_itemnamestring-AbsoluteAmountInCoCodeCrcy.
        wa_item2-GLAccountLongName = wa_it_itemnamestring-GLAccountLongName.
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        wa_item2-AccountingDocumentItem = wa_it_itemnamestring-AccountingDocumentItem.
        wa_item2-CompanyCode = wa_it_itemnamestring-CompanyCode.
        wa_item2-FiscalYear = wa_it_itemnamestring-FiscalYear.
        wa_item2-TaxItemGroup = wa_it_itemnamestring-TaxItemGroup  .
        wa_item2-AccountingDocument = wa_it_itemnamestring-AccountingDocument  .
        wa_item2-TaxCode  = wa_it_itemnamestring-TaxCode.
        wa_item2-Quantity = wa_it_itemnamestring-Quantity.
        wa_item2-BaseUnit = wa_it_itemnamestring-BaseUnit.

        APPEND wa_item2 TO it_item.

      ENDLOOP.

      DATA  wa_item_Productstring TYPE string.


** this loop is not run because on the table same name loop run on the table
*      LOOP AT it_item INTO DATA(wa_item).
*        IF wa_item-Product IS NOT INITIAL AND wa_item-GLAccount  IS NOT INITIAL   .
*
*          wa_item_productstring = wa_item-Product . """""""""""""this
*
*        ELSEIF wa_item-Product IS  INITIAL AND wa_item-GLAccount IS NOT INITIAL.
*          wa_item_productstring = wa_item-GLAccount.
*
*
*        ELSEIF wa_item-CostElement IS NOT INITIAL AND wa_item-GLAccount IS  INITIAL.
*          wa_item_productstring = wa_item-CostElement.
*        ELSEIF wa_item-CostElement IS  INITIAL AND wa_item-GLAccount IS NOT INITIAL.
*          wa_item_productstring = wa_item-GLAccount.
*
*
*        ENDIF.
**      MODIFY it_item FROM wa_it_item.
*        CLEAR wa_item.
*      ENDLOOP.



      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      DATA wa_itemnamestring TYPE string.
*    LOOP AT it_item INTO DATA(wa_itemstring).
**      IF wa_it_item-Product IS INITIAL AND wa_it_item-CostElement IS INITIAL.
* IF wa_it_item-Product IS NOT INITIAL AND wa_it_item-GLAccount  IS NOT INITIAL .
*        wa_itemnamestring = wa_it_item-ProductName.
*    ELSEIF wa_it_item-Product IS  INITIAL AND wa_it_item-GLAccount IS NOT INITIAL.
**      ELSEIF wa_it_item-Product IS NOT INITIAL .
*        wa_itemnamestring = wa_it_item-GLAccountLongName .
**      ELSEIF  wa_it_item-CostElement IS NOT INITIAL.
*      ELSEIF  wa_it_item-GLAccount  IS NOT INITIAL.
*        wa_itemnamestring = wa_itemstring-GLAccountLongName.
*      ENDIF.
*    ENDLOOP.

    ENDIF.

    " (Removed separate FOR ALL ENTRIES SELECTs and loops for fetching productname and GL account details)

    " CGST
    SELECT
           a~AccountingDocument,
           a~fiscalyear,
           a~companycode,
           a~absoluteamountincocodecrcy,
           a~TaxItemGroup,
           a~taxitemacctgdocitemref,
           a~TransactionTypeDetermination,
           a~taxcode
      FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
      WHERE a~AccountingDocumentItemType = 'T'
        AND a~TransactionTypeDetermination  = 'JIC'
        AND a~AccountingDocument           = @accounting_no
        AND a~FiscalYear                   = @fiscal_year
        AND a~CompanyCode                  = @Company_code
      INTO TABLE @DATA(cgst_amt).

    DATA: it_cgst_amt LIKE cgst_amt.
    LOOP AT cgst_amt INTO DATA(wa_cgst_amt).
      IF wa_cgst_amt-TaxItemGroup = wa_cgst_amt-TaxItemAcctgDocItemRef.
      SELECT SINGLE FROM i_taxcoderate as a
       FIELDS
       a~ConditionRateRatio
       WHERE a~TaxCode = @wa_cgst_amt-TaxCode
       INTO @DATA(igsttax1). """"""""""""""""""""""""""""""""
        APPEND wa_cgst_amt TO it_cgst_amt.
      ENDIF.
      CLEAR wa_cgst_amt.
    ENDLOOP.

    " SGST
    SELECT
           a~AccountingDocument,
           a~fiscalyear,
           a~companycode,
           a~absoluteamountincocodecrcy,
           a~TaxItemGroup,
           a~taxitemacctgdocitemref,
           a~TransactionTypeDetermination,
           a~taxcode  """""""""""""'
      FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
      WHERE a~AccountingDocumentItemType = 'T'
        AND a~TransactionTypeDetermination  = 'JIS'
        AND a~AccountingDocument           = @accounting_no
        AND a~FiscalYear                   = @fiscal_year
        AND a~CompanyCode                  = @Company_code
      INTO TABLE @DATA(sgst_amt).

    DATA: it_sgst_amt LIKE sgst_amt.
    LOOP AT sgst_amt INTO DATA(wa_sgst_amt).
      IF wa_sgst_amt-TaxItemGroup = wa_sgst_amt-TaxItemAcctgDocItemRef.
        APPEND wa_sgst_amt TO it_sgst_amt.
      ENDIF.
      CLEAR wa_sgst_amt.
    ENDLOOP.

    " UGST
    SELECT
           a~AccountingDocument,
           a~fiscalyear,
           a~companycode,
           a~absoluteamountincocodecrcy,
           a~TaxItemGroup,
           a~taxitemacctgdocitemref,
           a~TransactionTypeDetermination,
           a~taxcode """""""""""""""""""""
      FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
      WHERE a~AccountingDocumentItemType = 'T'
        AND a~TransactionTypeDetermination  = 'JIU'
        AND a~AccountingDocument           = @accounting_no
        AND a~FiscalYear                   = @fiscal_year
        AND a~CompanyCode                  = @Company_code
      INTO TABLE @DATA(ugst_amt).

    DATA: it_ugst_amt LIKE ugst_amt.
    LOOP AT ugst_amt INTO DATA(wa_ugst_amt).
      IF wa_ugst_amt-TaxItemGroup = wa_ugst_amt-TaxItemAcctgDocItemRef.
        APPEND wa_ugst_amt TO it_ugst_amt.
      ENDIF.
      CLEAR wa_ugst_amt.
    ENDLOOP.

    " IGST
    SELECT
           a~AccountingDocument,
           a~fiscalyear,
           a~companycode,
           a~absoluteamountincocodecrcy,
           a~TaxItemGroup,
           a~taxitemacctgdocitemref,
           a~TransactionTypeDetermination,
           a~taxcode
      FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
      WHERE a~AccountingDocumentItemType = 'T'
        AND a~TransactionTypeDetermination  = 'JII'
        AND a~AccountingDocument           = @accounting_no
        AND a~FiscalYear                   = @fiscal_year
        AND a~CompanyCode                  = @Company_code
      INTO TABLE @DATA(igst_amt).

    DATA: it_igst_amt LIKE igst_amt.
    LOOP AT igst_amt INTO DATA(wa_igst_amt).
      IF wa_igst_amt-TaxItemGroup = wa_igst_amt-TaxItemAcctgDocItemRef.
       SELECT SINGLE FROM i_taxcoderate as a
       FIELDS
       a~ConditionRateRatio
       WHERE a~TaxCode = @wa_igst_amt-TaxCode
       INTO @DATA(igsttax). """""""""""""""""""""""""""""""""""""
*        APPEND wa_igst_amt TO it_igst_amt.
        APPEND wa_igst_amt TO it_igst_amt.
      ENDIF.
      CLEAR wa_igst_amt.
    ENDLOOP.
    SELECT  SINGLE
      a~absoluteamountincocodecrcy
      FROM  i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a

      WHERE  a~AccountingDocument = @accounting_no
         AND a~FiscalYear         = @fiscal_year
         AND a~CompanyCode        = @Company_code  AND a~transactiontypedetermination IN ( 'KBS','EGK','EGX' ) AND
         a~FINANCIALACCOUNTTYPE = 'K'
         INTO @DATA(headerstr1).


    DATA s TYPE i.
    DATA(lv_xml) = |<form>| &&
                     |<header>| &&
                     |<PostingKey>{ lv_devitname }</PostingKey>| &&
                     |<companyName>{ lv_head-CompanyCodeName }</companyName>| &&
                     |<supplierDetails>| &&
                       |<gstin>{ wa_head-TaxNumber3 }</gstin>| &&
                       |<supName>{ wa_head-SupplierName }</supName>| &&
                       |<address1>{ wa_head-cityname }</address1>| &&
                       |<address2>{ wa_head-streetname }</address2>| &&
                       |<regionname>{ wa_head-RegionName }</regionname>| &&
                       |<address4>{ wa_head-PostalCode }</address4>| &&
                       |<stateCode_ds>{ state_cds }</stateCode_ds>| &&
                       |<pannumber_ds>{ pan_DS }</pannumber_ds>| &&
                     |</supplierDetails>| &&
                     |<docNo>{ wa_head-AccountingDocument }</docNo>| &&
                    |<postingDate>{ wa_head-PostingDate }</postingDate>| &&
                     |<documentDate>{ doc_date }</documentDate>| &&
                     |<docrefid>{ wa_head-DocumentReferenceID }</docrefid>| &&
                     |<orgrefdoc>{ wa_head-OriginalReferenceDocument }</orgrefdoc>| &&
                     |<BillTo>| &&
                       |<gstin>{ wa_head_bill-TaxNumber1 }</gstin>| &&
                        |<taxcodestr1>{ headerstr1 }</taxcodestr1>| &&
                       |<Namestring1>{ wa_head_bill-PlantName }</Namestring1>| &&
                       |<stateCode>{ state_cd }</stateCode>| &&
                       |<billto_regionname>{ wa_head_bill-RegionName }</billto_regionname>| &&
                       |<billtopan>{ pan }</billtopan>| &&
                       |<cin>{ wa_head_bill-BusinessTypeList }</cin>| &&
                       |<plant>{ wa_head_bill-Plant }</plant>| &&
                       |<Product_division>{ wa_head_bill-BusinessPlaceName }</Product_division>| &&
                     |</BillTo>| &&
                     |</header>| &&
                     |<item>|.

    LOOP AT it_item INTO DATA(wa_item).



*    LOOP AT it_item INTO DATA(wa_it_item).
      IF wa_item-Product IS NOT INITIAL AND wa_item-GLAccount  IS NOT INITIAL   .

        wa_item_productstring = wa_item-Product . """""""""""""this
        wa_itemnamestring = wa_item-ProductName.
      ELSEIF wa_item-Product IS  INITIAL AND wa_item-GLAccount IS NOT INITIAL.
        wa_item_productstring = wa_item-GLAccount.
        wa_itemnamestring = wa_item-GLAccountLongName.

      ELSEIF wa_item-CostElement IS NOT INITIAL AND wa_item-GLAccount IS  INITIAL.
        wa_item_productstring = wa_item-CostElement.
        wa_itemnamestring = wa_item-GLAccountLongName.
      ELSEIF wa_item-CostElement IS  INITIAL AND wa_item-GLAccount IS NOT INITIAL.
        wa_item_productstring = wa_item-GLAccount.
        wa_itemnamestring = wa_item-GLAccountLongName.


      ENDIF.


 if  wa_item-TransactionTypeDetermination = 'PRD' OR wa_item-TransactionTypeDetermination = 'WRX'
 OR wa_item-TransactionTypeDetermination = 'RKA' OR wa_item-TransactionTypeDetermination = 'BSX'
 OR wa_item-TransactionTypeDetermination is INITIAL.
     SELECT SINGLE SUM( a~AbsoluteAmountInCoCodeCrcy )

  FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS as a

    WHERE
    ( ( a~AccountingDocumentItemType IN ( 'P','W','M' )  OR a~AccountingDocumentItemType IS INITIAL )
    AND  ( a~TransactionTypeDetermination IN ( 'PRD','WRX','RKA','BSX' ) OR  a~TransactionTypeDetermination IS INITIAL  ) )

*    ( ( a~AccountingDocumentItemType IN ( 'P','W' )  AND a~TransactionTypeDetermination IN ( 'PRD','WRX','RKA' ) )
*    OR  ( a~AccountingDocumentItemType IS INITIAL AND  a~TransactionTypeDetermination IS INITIAL  ) )
    AND a~CostElement <> '0052060000'
    AND a~GLAccount <> '0052060000'
    AND a~AccountingDocument = @accounting_no
    AND a~FiscalYear         = @fiscal_year
    AND a~CompanyCode        = @Company_code
    GROUP BY a~Product
    INTO  @DATA(total_tax) .

 ENDIF.

  if total_tax is NOT INITIAL.
    wa_item-AbsoluteAmountInCoCodeCrcy = total_tax.
  ENDIF.

*SELECT SINGLE SUM( a~AbsoluteAmountInCoCodeCrcy )
*
*  FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS as a
*
*    WHERE
*    ( ( a~AccountingDocumentItemType IN ( 'P','W','M' )  OR a~AccountingDocumentItemType IS INITIAL )
*    AND  ( a~TransactionTypeDetermination IN ( 'PRD','WRX','RKA','BSX' ) OR  a~TransactionTypeDetermination IS INITIAL  ) )
*
**    ( ( a~AccountingDocumentItemType IN ( 'P','W' )  AND a~TransactionTypeDetermination IN ( 'PRD','WRX','RKA' ) )
**    OR  ( a~AccountingDocumentItemType IS INITIAL AND  a~TransactionTypeDetermination IS INITIAL  ) )
*    AND a~CostElement <> '0052060000'
*    AND a~GLAccount <> '0052060000'
*    AND a~AccountingDocument = @accounting_no
*    AND a~FiscalYear         = @fiscal_year
*    AND a~CompanyCode        = @Company_code
*    GROUP BY a~Product
*    INTO  @DATA(total_tax) .
*
*    total_tax = wa_item-AbsoluteAmountInCoCodeCrcy.


*     ENDIF.

*     SELECT  SINGLE
*     a~ABSOLUTEAMOUNTINCOCODECRCY
*     FROM  I_OPERATIONALACCTGDOCITEM WITH PRIVILEGED ACCESS as a
*
*     WHERE  a~AccountingDocument = @accounting_no
*        AND a~FiscalYear         = @fiscal_year
*        AND a~CompanyCode        = @Company_code  AND a~TRANSACTIONTYPEDETERMINATION IN ( 'KBS','EGK','EGX' )
*        INTO @DATA(headerstr1).
*    ENDLOOP.
 if wa_item-TaxCode is INITIAL .

     SELECT SINGLE FROM I_OPERATIONALACCTGDOCTAXITEM as a
     FIELDS
     a~TaxCode
     WHERE a~AccountingDocument = @wa_item-AccountingDocument AND a~CompanyCode = @wa_item-CompanyCode
     AND a~FiscalYear = @wa_item-FiscalYear

     INTO @DATA(taxcode) PRIVILEGED ACCESS.
      wa_item-TaxCode = taxcode.



     ENDIF.
      s += 1.
      DATA(lv_xml2) = |<lineItem>| &&
                        |<slNo>{ wa_item-TaxItemGroup }</slNo>| &&
                        |<totalValueOfSup>{ wa_item-AbsoluteAmountInCoCodeCrcy }</totalValueOfSup>| &&
*                        |<totalValueOfSup>{ wa_item-AbsoluteAmountInCoCodeCrcy }</totalValueOfSup>| &&
*                        |<totalValueOfSup>{ total_tax }</totalValueOfSup>| &&
                        |<totalValueOfSup>{ wa_item-AbsoluteAmountInCoCodeCrcy }</totalValueOfSup>| &&
                        |<quantity>{ wa_item-Quantity }</quantity>| &&
                        |<Product>{ wa_item_Productstring }</Product>| &&
*                        |<CostElement>{ wa_item-CostElement }</CostElement>| &&
                        |<ItemName>{ wa_itemnamestring }</ItemName>| &&
                        |<taxcode>{ wa_item-TaxCode }</taxcode>| &&
                        |<serialno>{ s }</serialno>| &&
                        |<baseunit>{ wa_item-BaseUnit }</baseunit>|.
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


         SELECT SINGLE FROM i_taxcoderate as a
         FIELDS
         a~ConditionRateRatio
         WHERE a~TaxCode = @wa_item-TaxCode AND a~AccountKeyForGLAccount = 'JIC'
         INTO @DATA(jicgsttaxrate).
      DATA(lv_cgstAmt) = |<cgstAmt>{ jicgsttaxrate }</cgstAmt>|.

       SELECT SINGLE FROM i_taxcoderate as a
         FIELDS
         a~ConditionRateRatio
         WHERE a~TaxCode = @wa_item-TaxCode AND a~AccountKeyForGLAccount = 'JIS'
         INTO @DATA(jisgsttaxrate).

      DATA(lv_sgstAmt) = |<sgstAmt>{ jisgsttaxrate }</sgstAmt>|.

        SELECT SINGLE FROM i_taxcoderate as a
         FIELDS
         a~ConditionRateRatio
         WHERE a~TaxCode = @wa_item-TaxCode AND a~AccountKeyForGLAccount = 'JIU'
         INTO @DATA(jiugsttaxrate).
       DATA(lv_ugstAmt) = |<ugstAmt>{ jiugsttaxrate }</ugstAmt>|.


        SELECT SINGLE FROM i_taxcoderate as a
         FIELDS
         a~ConditionRateRatio
         WHERE a~TaxCode = @wa_item-TaxCode AND a~AccountKeyForGLAccount = 'JII'
         INTO @DATA(jiigsttaxrate).

          DATA(lv_igstAmt) = |<igstAmt>{ jiigsttaxrate }</igstAmt>|.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      READ TABLE it_cgst_amt INTO DATA(wa_camt)
           WITH KEY AccountingDocument = wa_item-AccountingDocument
                    CompanyCode        = wa_item-CompanyCode
                    FiscalYear         = wa_item-FiscalYear
                    TaxItemGroup       = wa_item-TaxItemGroup .
                      IF sy-subrc <> 0 AND wa_item-TaxItemGroup IS INITIAL AND wa_item-TransactionTypeDetermination = 'PRD'.
             READ TABLE it_cgst_amt INTO  wa_camt
           WITH KEY AccountingDocument = wa_item-AccountingDocument
                    CompanyCode        = wa_item-CompanyCode
                    FiscalYear         = wa_item-FiscalYear
                    TransactionTypeDetermination = 'JIC'.


*                    wa_samt-AbsoluteAmountInCoCodeCrcy = wa_samt-AbsoluteAmountInCoCodeCrcy.

*                    wa_camt-AbsoluteAmountInCoCodeCrcy = wa_camt-AbsoluteAmountInCoCodeCrcy.

           ENDIF.

*    DATA(lv_cgstAmt) = |<cgstAmt>{ wa_camt-AbsoluteAmountInCoCodeCrcy }</cgstAmt>|.


      READ TABLE it_sgst_amt INTO DATA(wa_samt)
           WITH KEY AccountingDocument = wa_item-AccountingDocument
                    CompanyCode        = wa_item-CompanyCode
                    FiscalYear         = wa_item-FiscalYear
                    TaxItemGroup       = wa_item-TaxItemGroup.
                     IF sy-subrc <> 0 AND wa_item-TaxItemGroup IS INITIAL AND wa_item-TransactionTypeDetermination = 'PRD'.
             READ TABLE it_sgst_amt INTO  wa_samt
           WITH KEY AccountingDocument = wa_item-AccountingDocument
                    CompanyCode        = wa_item-CompanyCode
                    FiscalYear         = wa_item-FiscalYear
                    TransactionTypeDetermination = 'JIS'.
*                    wa_samt-AbsoluteAmountInCoCodeCrcy = wa_samt-AbsoluteAmountInCoCodeCrcy.

           ENDIF.
*      DATA(lv_sgstAmt) = |<sgstAmt>{ wa_samt-AbsoluteAmountInCoCodeCrcy }</sgstAmt>|.

      READ TABLE it_ugst_amt INTO DATA(wa_uamt)
           WITH KEY AccountingDocument = wa_item-AccountingDocument
                    CompanyCode        = wa_item-CompanyCode
                    FiscalYear         = wa_item-FiscalYear
                    TaxItemGroup       = wa_item-TaxItemGroup.
                     IF sy-subrc <> 0 AND wa_item-TaxItemGroup IS INITIAL AND wa_item-TransactionTypeDetermination = 'PRD'
                     .
             READ TABLE it_ugst_amt INTO  wa_uamt
           WITH KEY AccountingDocument = wa_item-AccountingDocument
                    CompanyCode        = wa_item-CompanyCode
                    FiscalYear         = wa_item-FiscalYear
                    TransactionTypeDetermination = 'JIU'.

*                    wa_uamt-AbsoluteAmountInCoCodeCrcy = wa_uamt-AbsoluteAmountInCoCodeCrcy.
           ENDIF.
*      DATA(lv_ugstAmt) = |<ugstAmt>{ wa_uamt-AbsoluteAmountInCoCodeCrcy }</ugstAmt>|.

      READ TABLE it_igst_amt INTO DATA(wa_iamt)
           WITH KEY AccountingDocument = wa_item-AccountingDocument
                    CompanyCode        = wa_item-CompanyCode
                    FiscalYear         = wa_item-FiscalYear
                  TaxItemGroup       = wa_item-TaxItemGroup.
          IF sy-subrc <> 0 AND wa_item-TaxItemGroup IS INITIAL "" AND wa_igst_amt-TransactionTypeDetermination = 'JII'
          AND wa_item-TransactionTypeDetermination = 'PRD'.
             READ TABLE it_igst_amt INTO  wa_iamt
           WITH KEY AccountingDocument = wa_item-AccountingDocument
                    CompanyCode        = wa_item-CompanyCode
                    FiscalYear         = wa_item-FiscalYear
                    TransactionTypeDetermination = 'JII'.

*                    wa_samt-AbsoluteAmountInCoCodeCrcy = wa_samt-AbsoluteAmountInCoCodeCrcy.

*                   wa_iamt-AbsoluteAmountInCoCodeCrcy = wa_iamt-AbsoluteAmountInCoCodeCrcy.

           ENDIF.
*      DATA(lv_igstAmt) = |<igstAmt>{ wa_iamt-AbsoluteAmountInCoCodeCrcy }</igstAmt>|.
      CLEAR: wa_camt, wa_iamt, wa_samt, wa_uamt.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""




      CONCATENATE lv_xml lv_xml2 lv_cgstAmt lv_sgstAmt lv_ugstAmt lv_igstAmt '</lineItem>' INTO lv_xml.
    ENDLOOP.

    DATA(lv_footer) = |</item>| &&
                        |<TDS_AMT_Footer>{ wa_head-WithholdingTaxAmount }</TDS_AMT_Footer>| &&
                        |<Document_text>{ lv_FOOT }</Document_text>| &&
                        |</form>|.

    CONCATENATE lv_xml lv_footer INTO lv_xml.

    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

  ENDMETHOD.
ENDCLASS.
