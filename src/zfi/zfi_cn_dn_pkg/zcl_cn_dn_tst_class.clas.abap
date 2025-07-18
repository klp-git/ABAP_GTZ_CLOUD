        CLASS   zcl_CN_DN_TST_CLASS DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
   PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_CN_DN_TST_CLASS IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.

  DATA : pan_DS    TYPE string,
         state_cds TYPE string.

  " Header
  SELECT SINGLE
         a~PostingKey,
         b~CompanyCodeName
    FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
    INNER JOIN I_CompanyCode WITH PRIVILEGED ACCESS AS b
      ON a~CompanyCode = b~CompanyCode
    WHERE a~AccountingDocument = '1700000010'
      AND a~FiscalYear         = '2024'
      AND a~CompanyCode        = 'GT00'
      AND a~FinancialAccountType = 'K'
      AND ( a~AccountingDocumentType = 'KG'
         OR  a~AccountingDocumentType = 'KC' )
    INTO @DATA(lv_head).

  " Footer
  SELECT SINGLE a~DocumentItemText
    FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
    WHERE a~AccountingDocument = '1700000010'
      AND a~FiscalYear         = '2024'
      AND a~CompanyCode        = 'GT00'
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
    WHERE a~AccountingDocument = '1700000010'
      AND a~FiscalYear         = '2024'
      AND a~CompanyCode        = 'GT00'
      AND a~FinancialAccountType = 'K'
    INTO @DATA(wa_head).

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
    WHERE a~AccountingDocument = '1700000010'
      AND a~FiscalYear         = '2024'
      AND a~CompanyCode        = 'GT00'
    INTO @DATA(wa_head_bill).

  DATA : bill_ad1 TYPE string,
         bill_ad2 TYPE string,
         bill_ad3 TYPE string,
         pan      TYPE string,
         state_cd TYPE string.

  pan      = wa_head_bill-TaxNumber1+2(10).
  state_cd = wa_head_bill-TaxNumber1+0(2).

  " ITEM DETAILS - Join with I_ProductText and I_GLACCOUNTTEXTRAWDATA in one query
  SELECT
         a~product,
         a~costelement,
         COALESCE( d~glaccountlongname, b~productname, a~product ) AS itemname,
         a~in_hsnorsaccode,
         a~quantity,
         a~baseunit,
         a~absoluteamountincocodecrcy,
         a~AccountingDocument,
         a~fiscalyear,
         a~companycode,
         a~accountingdocumentitem,
         a~taxitemgroup,
         a~taxcode
    FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
    LEFT JOIN i_producttext         WITH PRIVILEGED ACCESS AS b ON a~Product    = b~Product
    LEFT JOIN i_glaccounttextrawdata WITH PRIVILEGED ACCESS AS d ON a~costelement = d~glaccount
    WHERE ( a~AccountingDocumentItemType = 'W'
         OR  a~AccountingDocumentItemType = ' ' )
      AND ( a~TransactionTypeDetermination IN ( 'WRX','WIT','RKA' )
         OR  a~TransactionTypeDetermination = ' ' )
*      AND
*       ( a~TransactionTypeDetermination = 'WIT'
*         OR  a~TransactionTypeDetermination = ' ' )
*      AND ( a~TransactionTypeDetermination = 'RKA'
*         OR  a~TransactionTypeDetermination = ' ' )
      AND a~AccountingDocument = '5300000001'
      AND a~FiscalYear         = '2025'
      AND a~CompanyCode        = 'GT00'
    INTO TABLE @DATA(it_item).
*    out->write( it_item ).

  " (Removed separate FOR ALL ENTRIES SELECTs and loops for fetching productname and GL account details)

  " CGST
  SELECT
         a~AccountingDocument,
         a~fiscalyear,
         a~companycode,
         a~absoluteamountincocodecrcy,
         a~TaxItemGroup,
         a~taxitemacctgdocitemref
    FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
    WHERE a~AccountingDocumentItemType = 'T'
      AND a~TransactionTypeDetermination  = 'JIC'
      AND a~AccountingDocument           = '1700000010'
      AND a~FiscalYear                   = '2024'
      AND a~CompanyCode                  = 'GT00'
    INTO TABLE @DATA(cgst_amt).

  DATA: it_cgst_amt like cgst_amt.
  LOOP AT cgst_amt INTO DATA(wa_cgst_amt).
    IF wa_cgst_amt-TaxItemGroup = wa_cgst_amt-TaxItemAcctgDocItemRef.
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
         a~taxitemacctgdocitemref
    FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
    WHERE a~AccountingDocumentItemType = 'T'
      AND a~TransactionTypeDetermination  = 'JIS'
      AND a~AccountingDocument           = '1700000010'
      AND a~FiscalYear                   = '2024'
      AND a~CompanyCode                  = 'GT00'
    INTO TABLE @DATA(sgst_amt).

  DATA: it_sgst_amt like sgst_amt.
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
         a~taxitemacctgdocitemref
    FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
    WHERE a~AccountingDocumentItemType = 'T'
      AND a~TransactionTypeDetermination  = 'JIU'
      AND a~AccountingDocument           = '1700000010'
      AND a~FiscalYear                   = '2024'
      AND a~CompanyCode                  = 'GT00'
    INTO TABLE @DATA(ugst_amt).

  DATA: it_ugst_amt like ugst_amt.
  LOOP AT ugst_amt INTO DATA(wa_ugst_amt).
    IF wa_ugst_amt-TaxItemGroup = wa_ugst_amt-TaxItemAcctgDocItemRef.
      APPEND wa_ugst_amt TO it_ugst_amt.
    ENDIF.
    CLEAR wa_ugst_amt.
  ENDLOOP.

  " IGST
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

   SELECT
         a~product,
         a~costelement,
         coalesce( d~glaccountlongname, b~productname, a~product ) AS itemname,
         a~in_hsnorsaccode,
         a~quantity,
         a~glaccount,
         a~baseunit,
         a~absoluteamountincocodecrcy,
         a~AccountingDocument,
         a~fiscalyear,
         a~companycode,
         a~accountingdocumentitem,
         a~taxitemgroup,
         a~taxcode,
         d~glaccountlongname,
         b~productname,
           e~ReferenceDocumentItemGroup,
         a~AccountingDocumentItemType,
         a~TransactionTypeDetermination

    FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
    LEFT JOIN i_producttext         WITH PRIVILEGED ACCESS AS b ON a~Product    = b~Product
    LEFT JOIN i_glaccounttextrawdata WITH PRIVILEGED ACCESS AS d ON a~GLAccount = d~glaccount
       LEFT JOIN i_accountingdocumentjournal WITH PRIVILEGED ACCESS as e on a~AccountingDocument = e~AccountingDocument
    AND a~CompanyCode = e~CompanyCode AND a~FiscalYear = e~FiscalYear

    WHERE
    ( ( a~AccountingDocumentItemType = 'P' AND a~TransactionTypeDetermination = 'PRD' )
    OR  ( a~AccountingDocumentItemType IS INITIAL AND  a~TransactionTypeDetermination IS INITIAL  ) )
    AND
    a~CostElement <> '0052060000'
    AND a~GLAccount <> '0052060000'
    AND
     a~AccountingDocument = '2700000000'
    AND a~FiscalYear         = '2025'
    AND a~CompanyCode        = 'GT00'
    INTO TABLE @DATA(it_itemtax).

    out->write( it_itemtax ).

  """"""""""""""""""""""""""""""""""""""""""
  SELECT
         a~AccountingDocument,
         a~fiscalyear,
         a~companycode,
         a~absoluteamountincocodecrcy,
         a~TaxItemGroup,
         a~taxitemacctgdocitemref
    FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
    WHERE a~AccountingDocumentItemType = 'T'
      AND a~TransactionTypeDetermination  = 'JII'
      AND a~AccountingDocument           = '1700000010'
      AND a~FiscalYear                   = '2024'
      AND a~CompanyCode                  = 'GT00'
    INTO TABLE @DATA(igst_amt).

  DATA: it_igst_amt like igst_amt.
  LOOP AT igst_amt INTO DATA(wa_igst_amt).
    IF wa_igst_amt-TaxItemGroup = wa_igst_amt-TaxItemAcctgDocItemRef.
      APPEND wa_igst_amt TO it_igst_amt.
    ENDIF.
    CLEAR wa_igst_amt.
  ENDLOOP.

  DATA s TYPE i.
  DATA(lv_xml) = |<form>| &&
                   |<header>| &&
                   |<PostingKey>{ lv_head-PostingKey }</PostingKey>| &&
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
                   |<docDate>{ wa_head-DocumentDate }</docDate>| &&
                   |<docrefid>{ wa_head-DocumentReferenceID }</docrefid>| &&
                   |<orgrefdoc>{ wa_head-OriginalReferenceDocument }</orgrefdoc>| &&
                   |<BillTo>| &&
                     |<gstin>{ wa_head_bill-TaxNumber1 }</gstin>| &&
                     |<Name>{ wa_head_bill-PlantName }</Name>| &&
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
    s += 1.
    DATA(lv_xml2) = |<lineItem>| &&
                      |<slNo>{ wa_item-TaxItemGroup }</slNo>| &&
                      |<totalValueOfSup>{ wa_item-AbsoluteAmountInCoCodeCrcy }</totalValueOfSup>| &&
                      |<quantity>{ wa_item-Quantity }</quantity>| &&
                      |<Product>{ wa_item-Product }</Product>| &&
                      |<CostElement>{ wa_item-CostElement }</CostElement>| &&
                      |<ItemName>{ wa_item-itemname }</ItemName>| &&
                      |<taxcode>{ wa_item-TaxCode }</taxcode>| &&
                      |<serialno>{ s }</serialno>| &&
                      |<baseunit>{ wa_item-BaseUnit }</baseunit>|.

    READ TABLE it_cgst_amt INTO DATA(wa_camt)
         WITH KEY AccountingDocument = wa_item-AccountingDocument
                  CompanyCode        = wa_item-CompanyCode
                  FiscalYear         = wa_item-FiscalYear
                  TaxItemGroup       = wa_item-TaxItemGroup.
    DATA(lv_cgstAmt) = |<cgstAmt>{ wa_camt-AbsoluteAmountInCoCodeCrcy }</cgstAmt>|.

    READ TABLE it_sgst_amt INTO DATA(wa_samt)
         WITH KEY AccountingDocument = wa_item-AccountingDocument
                  CompanyCode        = wa_item-CompanyCode
                  FiscalYear         = wa_item-FiscalYear
                  TaxItemGroup       = wa_item-TaxItemGroup.
    DATA(lv_sgstAmt) = |<sgstAmt>{ wa_samt-AbsoluteAmountInCoCodeCrcy }</sgstAmt>|.

    READ TABLE it_ugst_amt INTO DATA(wa_uamt)
         WITH KEY AccountingDocument = wa_item-AccountingDocument
                  CompanyCode        = wa_item-CompanyCode
                  FiscalYear         = wa_item-FiscalYear
                  TaxItemGroup       = wa_item-TaxItemGroup.
    DATA(lv_ugstAmt) = |<ugstAmt>{ wa_uamt-AbsoluteAmountInCoCodeCrcy }</ugstAmt>|.

    READ TABLE it_igst_amt INTO DATA(wa_iamt)
         WITH KEY AccountingDocument = wa_item-AccountingDocument
                  CompanyCode        = wa_item-CompanyCode
                  FiscalYear         = wa_item-FiscalYear
                  TaxItemGroup       = wa_item-TaxItemGroup.
    DATA(lv_igstAmt) = |<igstAmt>{ wa_iamt-AbsoluteAmountInCoCodeCrcy }</igstAmt>|.
    CLEAR: wa_camt, wa_iamt, wa_samt, wa_uamt.
    CONCATENATE lv_xml lv_xml2 lv_cgstAmt lv_sgstAmt lv_ugstAmt lv_igstAmt '</lineItem>' INTO lv_xml.
  ENDLOOP.

  DATA(lv_footer) = |</item>| &&
                      |<TDS_AMT_Footer>{ wa_head-WithholdingTaxAmount }</TDS_AMT_Footer>| &&
                      |<Document_text>{ lv_FOOT }</Document_text>| &&
                      |</form>|.

  CONCATENATE lv_xml lv_footer INTO lv_xml.

*  out->write( it_line ).
*    CALL METHOD ycl_test_adobe2=>getpdf(
*      EXPORTING
*        xmldata  = lv_xml
*        template = lc_template_name
*      RECEIVING
*        result   = result12 ).
*
*
  ENDMETHOD .
ENDCLASS.
