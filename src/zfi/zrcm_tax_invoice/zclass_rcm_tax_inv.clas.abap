CLASS zclass_rcm_tax_inv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*    INTERFACES if_oo_adt_classrun.
    CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
    CLASS-DATA : var1 TYPE vbeln.
    TYPES :
      BEGIN OF struct,
        xdp_template TYPE string,
        xml_data     TYPE string,
        form_type    TYPE string,
        form_locale  TYPE string,
        tagged_pdf   TYPE string,
        embed_font   TYPE string,
      END OF struct.

    CLASS-METHODS :
      create_client
        IMPORTING url           TYPE string
        RETURNING VALUE(result) TYPE REF TO if_web_http_client
        RAISING   cx_static_check ,

      read_posts
        IMPORTING accountingDocNo TYPE string
        RETURNING VALUE(result12)        TYPE string
        RAISING   cx_static_check .


  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'ZFI_RCM_TAX_INV/ZFI_RCM_TAX_INV'.
ENDCLASS.



CLASS ZCLASS_RCM_TAX_INV IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts.

    var1 = accountingDocNo.
    var1 =   |{ |{ var1 ALPHA = OUT }| ALPHA = IN }| .
    DATA(lv_accountingDocNo) = var1.

    SELECT SINGLE
    a~accountingdocument ,
    a~in_gstplaceofsupply ,"""""state code of bill_to
    a~supplier,
    a~originalreferencedocument,
    a~postingdate,
    a~documentdate,
    a~companycode,
    b~suppliername ,
    b~cityname,
    b~streetname,
    b~region,
    b~country,
    b~postalcode,
    b~taxnumber3,
    c~regionname,
    d~countryname,
    e~documentreferenceid,
    f~companycodename
    FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
    LEFT JOIN i_supplier WITH PRIVILEGED ACCESS  AS b ON a~supplier = b~supplier
    LEFT JOIN i_regiontext WITH PRIVILEGED ACCESS  AS c ON b~Region = c~Region
    LEFT JOIN i_countrytext WITH PRIVILEGED ACCESS  AS d ON b~Country = d~Country
    LEFT JOIN i_accountingdocumentjournal  WITH PRIVILEGED ACCESS AS e ON a~AccountingDocument = e~AccountingDocument AND a~CompanyCode = e~CompanyCode
    AND a~FiscalYear = e~FiscalYear
    LEFT JOIN i_companycode AS f ON a~CompanyCode = f~CompanyCode
    AND a~FiscalYear = e~FiscalYear
    WHERE a~AccountingDocumentType IN ( 'RE', 'KR','UR' ) AND a~FinancialAccountType = 'K'
    AND a~AccountingDocument EQ @lv_accountingDocNo
*    AND a~Supplier IS NOT INITIAL
    INTO @DATA(wa_head).
*    out->write( wa_head ).


    SELECT SINGLE
    a~accountingdocument,
    a~companycode,
    a~fiscalyear,
    a~purchasingdocument,
    b~purchaseorderdate
    FROM i_operationalacctgdocitem  WITH PRIVILEGED ACCESS AS a
    LEFT JOIN i_purchaseorderapi01  WITH PRIVILEGED ACCESS AS b ON a~PurchasingDocument = b~PurchaseOrder
    WHERE transactiontypedetermination IN  ( 'WRX' , 'FR1' , 'ZOC' , 'ZAF' , 'ZLC' , 'ZLU' , 'FR3' , 'ZCC' , 'ZCF' , 'ZCH' , 'ZEC' )
    AND a~AccountingDocument EQ @lv_accountingDocNo
    INTO  @DATA(po).





    """""""""""""""""""""""""""""""TAX PAYABLE ON REVERSE """""""""""""""""""""""""""""""""""

    SELECT SINGLE a~accountingdocument ,
    a~fiscalyear,
    a~companycode
    FROM i_operationalacctgdocitem  WITH PRIVILEGED ACCESS  AS a
     WHERE a~AccountingDocumentType IN ( 'RE', 'KR','UR' )
     AND a~AccountingDocumentItemType = 'T'
     AND transactiontypedetermination IN ('JRC', 'JRS', 'JRI', 'JRU')
     AND a~AccountingDocument EQ @lv_accountingDocNo
     INTO @DATA(wa_head_tax).

    DATA : tax_porcb TYPE string,
           urcm      TYPE string.



    IF wa_head_tax IS NOT INITIAL.
      tax_porcb = 'Yes'.
      urcm = 'UNDER REVERSE CHARGE MECHANISM'.
    ENDIF.

*    out->write( wa_head_tax ).
*    out->write( tax_porcb ).


    DATA: supp_add1 TYPE string,
          supp_add2 TYPE string,
          supp_ad3  TYPE string.


    supp_add1 = wa_head-streetname.
    CONCATENATE supp_add1  ','  wa_head-cityname INTO supp_add1 SEPARATED BY space.
    supp_add2 = wa_head-postalcode.
    CONCATENATE supp_add2  ','  wa_head-RegionName  INTO supp_add2 SEPARATED BY space.
    supp_ad3 =  wa_head-CountryName.


    DATA : inv_no TYPE string.
    inv_no = wa_head-OriginalReferenceDocument+0(10).

    DATA : st_cd TYPE string.
    st_cd = wa_head-TaxNumber3+0(2).

    """""""""""""""""""""""""""""BILL TO """""""""""""""""""""""""""""""""""""
    SELECT SINGLE
    a~accountingdocument ,
   a~fiscalyear,
   a~companycode,
   a~in_gstplaceofsupply,
   b~plantname,
   b~plant,
   c~taxnumber1,
   c~businesstypelist,
   d~regionname
   FROM i_operationalacctgdocitem  WITH PRIVILEGED ACCESS AS a
   LEFT JOIN i_plant  WITH PRIVILEGED ACCESS AS b ON a~BusinessPlace = b~Plant
   LEFT JOIN i_kr_businessplace  WITH PRIVILEGED ACCESS AS c ON a~BusinessPlace = c~branch
   LEFT JOIN i_regiontext  WITH PRIVILEGED ACCESS AS d ON a~IN_GSTPlaceOfSupply = d~region
   WHERE a~CompanyCode = 'GT00'
   AND a~AccountingDocumentType IN ( 'RE', 'KR' , 'UR' ) AND a~FinancialAccountType = 'K'
   AND a~AccountingDocument EQ @lv_accountingDocNo
   INTO @DATA(wa_head_bill).

    DATA : bill_ad1 TYPE string,
           bill_ad2 TYPE string,
           bill_ad3 TYPE string,
           pan      TYPE string,
           state_cd TYPE string.

    pan = wa_head_bill-TaxNumber1+2(10).
    state_cd = wa_head_bill-TaxNumber1+0(2).


    """""""""""""""""""""""""""""ITEM DETAILS"""""""""""""""""""""""""""""""""""""""""

    SELECT
     a~product,
     a~in_hsnorsaccode,
     a~quantity,
     a~baseunit,
     a~absoluteamountincocodecrcy,
      a~AccountingDocument,
    a~fiscalyear,
    a~companycode,
    a~accountingdocumentitem,
    a~taxitemgroup,
     b~productname,
      a~costelement,
      a~AccountingDocumentItemType,
      a~TransactionTypeDetermination,
      c~glaccount,
      c~glaccountname

     FROM
     i_operationalacctgdocitem  WITH PRIVILEGED ACCESS AS a
     LEFT JOIN i_producttext  WITH PRIVILEGED ACCESS AS b ON a~Product = b~Product
     LEFT JOIN i_accountingdocumentjournal  WITH PRIVILEGED ACCESS AS c ON a~GLAccount = c~GLAccount
*     WHERE a~AccountingDocumentItemType = 'W' AND a~TransactionTypeDetermination = 'WRX' or a~CostElement is NOT INITIAL
     WHERE a~AccountingDocument EQ @lv_accountingDocNo
     INTO TABLE @DATA(it_item).




*    out->write( it_item ).
    """"""""""""""""""""""""""""""CGST """""""""""""""""""""""""""""""""""

    SELECT
    a~AccountingDocument,
    a~fiscalyear,
    a~companycode,
     a~absoluteamountincocodecrcy,
     a~TaxItemGroup,
     a~taxitemacctgdocitemref
     FROM
      i_operationalacctgdocitem  WITH PRIVILEGED ACCESS AS a
      WHERE a~AccountingDocumentItemType = 'T' AND a~TransactionTypeDetermination = 'JRC'
      AND a~AccountingDocument EQ @lv_accountingDocNo
      INTO TABLE @DATA(cgst_amt).

    DATA: it_cgst_amt LIKE cgst_amt.

    LOOP AT cgst_amt INTO DATA(wa_cgst_amt).
      IF wa_cgst_amt-TaxItemGroup = wa_cgst_amt-TaxItemAcctgDocItemRef.
        APPEND wa_cgst_amt TO it_cgst_amt.
      ENDIF.
      CLEAR wa_cgst_amt.
    ENDLOOP.


*    out->write( it_cgst_amt ).
    """"""""""""""""""""""""""""""SGST """""""""""""""""""""""""""""""""""

    SELECT
     a~AccountingDocument,
    a~fiscalyear,
    a~companycode,
     a~absoluteamountincocodecrcy,
      a~TaxItemGroup,
     a~taxitemacctgdocitemref
     FROM
      i_operationalacctgdocitem  WITH PRIVILEGED ACCESS AS a
      WHERE a~AccountingDocumentItemType = 'T' AND a~TransactionTypeDetermination = 'JRS'
      AND a~AccountingDocument EQ @lv_accountingDocNo
      INTO TABLE @DATA(sgst_amt).



    DATA: it_sgst_amt LIKE sgst_amt.

    LOOP AT sgst_amt INTO DATA(wa_sgst_amt).
      IF wa_sgst_amt-TaxItemGroup = wa_sgst_amt-TaxItemAcctgDocItemRef.
        APPEND wa_sgst_amt TO it_sgst_amt.
      ENDIF.
      CLEAR wa_sgst_amt.
    ENDLOOP.


    """"""""""""""""""""""""""""""UGST """""""""""""""""""""""""""""""""""

    SELECT
     a~AccountingDocument,
    a~fiscalyear,
    a~companycode,
     a~absoluteamountincocodecrcy,
      a~TaxItemGroup,
     a~taxitemacctgdocitemref
     FROM
      i_operationalacctgdocitem  WITH PRIVILEGED ACCESS AS a
      WHERE a~AccountingDocumentItemType = 'T' AND a~TransactionTypeDetermination = 'JRU'
      AND a~AccountingDocument EQ @lv_accountingDocNo
      INTO TABLE @DATA(ugst_amt).



    DATA: it_ugst_amt LIKE ugst_amt.

    LOOP AT ugst_amt INTO DATA(wa_ugst_amt).
      IF wa_ugst_amt-TaxItemGroup = wa_ugst_amt-TaxItemAcctgDocItemRef.
        APPEND wa_ugst_amt TO it_ugst_amt.
      ENDIF.
      CLEAR wa_ugst_amt.
    ENDLOOP.

    """"""""""""""""""""""""""""""IGST """""""""""""""""""""""""""""""""""

    SELECT
     a~AccountingDocument,
    a~fiscalyear,
    a~companycode,
     a~absoluteamountincocodecrcy,
      a~TaxItemGroup,
     a~taxitemacctgdocitemref
     FROM
      i_operationalacctgdocitem  WITH PRIVILEGED ACCESS AS a
      WHERE a~AccountingDocumentItemType = 'T' AND a~TransactionTypeDetermination = 'JRI'
      AND a~AccountingDocument EQ @lv_accountingDocNo
      INTO TABLE @DATA(igst_amt).
*
*
*    out->write( igst_amt ).
    DATA: it_igst_amt LIKE igst_amt.

    LOOP AT igst_amt INTO DATA(wa_igst_amt).
      IF wa_igst_amt-TaxItemGroup = wa_igst_amt-TaxItemAcctgDocItemRef.
        APPEND wa_igst_amt TO it_igst_amt.
      ENDIF.
      CLEAR wa_igst_amt.
    ENDLOOP.




    DATA(lv_xml) =
       |<form>| &&
       |<header>| &&
       |<companyName>{ wa_head-CompanyCodeName }</companyName>| &&
       |<underRevChargMechnism>{ urcm }</underRevChargMechnism>| &&
       |<supplierDetails>| &&
       |<supplier>{ wa_head-Supplier }</supplier>| &&
       |<supName>{ wa_head-SupplierName }</supName>| &&
       |<address1>{ supp_add1 }</address1>| &&
        |<address2>{ supp_add2 }</address2>| &&
         |<address3>{ supp_ad3 }</address3>| &&
         |<gstin>{ wa_head-TaxNumber3 }</gstin>| &&
         |<stateCode>{ st_cd }</stateCode>| &&
         |</supplierDetails>| &&
         |<invoiceNo>{ inv_no }</invoiceNo>| &&
         |<docNo>{ wa_head-AccountingDocument }</docNo>| &&
         |<docDate>{ wa_head-PostingDate }</docDate>| &&
         |<invoiceDate>{ wa_head-PostingDate }</invoiceDate>| &&
         |<suppInvNo>{ wa_head-DocumentReferenceID }</suppInvNo>| &&
         |<supInvDate>{ wa_head-DocumentDate }</supInvDate>| &&
         |<taxPaybleOnRevChrgBasis>{ tax_porcb }</taxPaybleOnRevChrgBasis>| &&
         |<poNo>{ po-PurchasingDocument }</poNo>| &&
         |<poDt>{ po-PurchaseOrderDate }</poDt>| &&
         |<BillTo>| &&
         |<plant>{ wa_head_bill-Plant }</plant>| &&
         |<Name>{ wa_head_bill-PlantName }</Name>| &&
*         |<Address1>{ bill_ad1 }</Address1>| &&
*         |<Address2>{ bill_ad2 }</Address2>| &&
*         |<Address3>{ bill_ad3 }</Address3>| &&
         |<gstin>{ wa_head_bill-TaxNumber1 }</gstin>| &&
         |<pan>{ pan }</pan>| &&
         |<cin>{ wa_head_bill-BusinessTypeList }</cin>| &&
         |<stateCode>{ state_cd }</stateCode>| &&
         |<placeOfSupply>{ wa_head_bill-RegionName }</placeOfSupply>| &&
         |</BillTo>| &&
         |</header>| &&
          |<item>|.

    SORT it_item BY AccountingDocumentItem.
    DELETE ADJACENT DUPLICATES FROM it_item COMPARING AccountingDocumentItem.
    LOOP AT it_item INTO DATA(wa_item).
      IF ( ( wa_item-AccountingDocumentItemType = 'W' OR  wa_item-AccountingDocumentItemType = 'F'
         AND ( wa_item-TransactionTypeDetermination = 'WRX'
               OR wa_item-TransactionTypeDetermination = 'FR1'
               OR wa_item-TransactionTypeDetermination = 'ZOC'
               OR wa_item-TransactionTypeDetermination = 'ZAF'
               OR wa_item-TransactionTypeDetermination = 'ZLC'
               OR wa_item-TransactionTypeDetermination = 'ZLU'
               OR wa_item-TransactionTypeDetermination = 'FR3'
               OR wa_item-TransactionTypeDetermination = 'ZCC'
               OR wa_item-TransactionTypeDetermination = 'ZCF'
               OR wa_item-TransactionTypeDetermination = 'ZCH'
               OR wa_item-TransactionTypeDetermination = 'ZEC' )
         AND wa_item-CostElement IS INITIAL )
      OR ( wa_item-AccountingDocumentItemType = ''
           AND wa_item-TransactionTypeDetermination = ''
           AND wa_item-CostElement IS NOT INITIAL ) ).
        DATA(lv_xml2) =
         |<lineItem>| &&
         |<slNo>{ wa_item-TaxItemGroup }</slNo>| &&
         |<itemCode>{ wa_item-product }</itemCode>|.
        CONCATENATE lv_xml lv_xml2 INTO lv_xml.
        IF wa_item-CostElement IS INITIAL.
          DATA(lv_pname) =
          |<itemName>{ wa_item-ProductName }</itemName>|.
        ELSE.
          lv_pname = |<itemName>{ wa_item-GLAccountName }</itemName>|.
        ENDIF.
        CONCATENATE lv_xml lv_pname INTO lv_xml.
        CLEAR lv_xml2.
        lv_xml2 =
        |<hsn>{ wa_item-IN_HSNOrSACCode }</hsn>| &&
        |<qty>{ wa_item-Quantity }</qty>| &&
        |<unit>{ wa_item-BaseUnit }</unit>| &&
        |<totalValueOfSup>{ wa_item-AbsoluteAmountInCoCodeCrcy }</totalValueOfSup>| &&
        |<discount></discount>| .


        READ TABLE it_cgst_amt INTO DATA(wa_camt) WITH KEY AccountingDocument = wa_item-AccountingDocument CompanyCode = wa_item-CompanyCode
                       FiscalYear = wa_item-FiscalYear TaxItemGroup = wa_item-TaxItemGroup.
        DATA(lv_cgstAmt) =
                |<cgstAmt>{ wa_camt-AbsoluteAmountInCoCodeCrcy }</cgstAmt>|.

        READ TABLE it_sgst_amt INTO DATA(wa_samt) WITH KEY AccountingDocument = wa_item-AccountingDocument CompanyCode = wa_item-CompanyCode
              FiscalYear = wa_item-FiscalYear TaxItemGroup = wa_item-TaxItemGroup.
        DATA(lv_sgstAmt) =
                |<sgstAmt>{ wa_samt-AbsoluteAmountInCoCodeCrcy }</sgstAmt>|.

        READ TABLE it_ugst_amt INTO DATA(wa_uamt) WITH KEY AccountingDocument = wa_item-AccountingDocument CompanyCode = wa_item-CompanyCode
              FiscalYear = wa_item-FiscalYear TaxItemGroup = wa_item-TaxItemGroup.
        DATA(lv_ugstAmt) =
                |<ugstAmt>{ wa_uamt-AbsoluteAmountInCoCodeCrcy }</ugstAmt>|.

        READ TABLE it_igst_amt INTO DATA(wa_iamt) WITH KEY AccountingDocument = wa_item-AccountingDocument CompanyCode = wa_item-CompanyCode
              FiscalYear = wa_item-FiscalYear TaxItemGroup = wa_item-TaxItemGroup.
        DATA(lv_igstAmt) =
                |<igstAmt>{ wa_iamt-AbsoluteAmountInCoCodeCrcy }</igstAmt>|.

        CONCATENATE lv_xml lv_xml2 lv_cgstamt lv_sgstamt lv_ugstamt lv_igstamt  '</lineItem>' INTO lv_xml.
        CLEAR wa_camt.
        CLEAR wa_samt.
        CLEAR wa_iamt.
        CLEAR wa_uamt.
        CLEAR wa_item.
      ENDIF.
    ENDLOOP.

    DATA(lv_footer) =
 |</item>| &&
 |<footer>| &&
 |<compName>{ wa_head-CompanyCodeName }</compName>| &&
 |</footer>| &&
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
