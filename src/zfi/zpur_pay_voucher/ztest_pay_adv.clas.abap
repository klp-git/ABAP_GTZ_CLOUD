
CLASS ztest_pay_adv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
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

*    CLASS-METHODS :
*      create_client
*        IMPORTING url           TYPE string
*        RETURNING VALUE(result) TYPE REF TO if_web_http_client
*        RAISING   cx_static_check ,
*
**      read_posts
*        IMPORTING VALUE(accountingDocNo) TYPE string
*        RETURNING VALUE(result12)        TYPE string
*        RAISING   cx_static_check .


  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://bn-dev-jpiuus30.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zsd_salesorder_print/zsd_salesorder_print'.
ENDCLASS.



CLASS ZTEST_PAY_ADV IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    SELECT SINGLE FROM i_operationalacctgdocitem AS a
       LEFT JOIN i_supplier AS d ON a~Supplier = d~Supplier AND a~Supplier IS NOT INITIAL
       FIELDS d~SupplierFullName
        WHERE a~AccountingDocument = '1500000032' AND a~FiscalYear = '2024' AND a~CompanyCode = 'GT00'
          INTO @DATA(wa2).
    out->write( wa2 ).
    DATA(lv_doc) = '1500000032'.

    SELECT SINGLE
   e~glaccountlongname
   FROM i_operationalacctgdocitem AS a
   LEFT JOIN  i_accountingdocumentjournal  AS b ON a~AccountingDocument = b~AccountingDocument AND a~CompanyCode = b~companycode
                                   AND b~Ledger = '0L'
   LEFT JOIN i_glaccounttextrawdata AS e ON  b~glaccount = e~GLAccount
   WHERE b~HouseBank IS NOT INITIAL
   INTO @DATA(test).
   """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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

     WHERE a~ClearingJournalEntry = '1500000003'  AND a~ClearingJournalEntryFiscalYear = '2025' AND a~CompanyCode = 'GT00'  AND a~FinancialAccountType = 'K'
      AND a~TaxSection  is NOT INITIAL
*     WHERE a~ClearingJournalEntry = '1500000003'   "AND a~ClearingDocFiscalYear = '2024' AND a~CompanyCode = 'GT00' AND
*        AND a~fiscalyear = '2025' AND a~CompanyCode = 'GT00'  AND a~FinancialAccountType = 'K' AND a~TaxSection is NOT INITIAL"" AND a~Accountingdocumentitem = '001'
*"" AND  a~TransactionTypeDetermination = 'EGK'  """"IN ('KBS', 'EGK','EGX')
     INTO TABLE @DATA(item).

    out->write( item ).

     SELECT
      a~accountingdocument,
       a~businessplace,
       a~accountingdocumenttype,
       a~withholdingtaxamount,
       a~amountincompanycodecurrency
        FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a

  WHERE a~ClearingJournalEntry = '1500000003'  AND a~ClearingJournalEntryFiscalYear = '2025' AND a~CompanyCode = 'GT00'  AND a~FinancialAccountType = 'K'
      AND a~TaxSection  is NOT INITIAL

    INTO TABLE @DATA(it_item).

*    out->write( it_item ).

******* Header level data*********************
    SELECT SINGLE
*    a~accountingdocument,
*    a~postingdate,
*    b~accountingdocumentheadertext,
*    d~region,
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
*    d~countryname


       FROM i_operationalacctgdocitem AS a

       LEFT JOIN  i_accountingdocumentjournal  AS b ON a~AccountingDocument = b~AccountingDocument AND a~CompanyCode = b~companycode AND b~Ledger = '0L'
       LEFT JOIN i_supplier AS d ON a~Supplier = d~Supplier
       LEFT JOIN i_regiontext WITH PRIVILEGED ACCESS  AS g ON d~Region = g~Region
       LEFT JOIN i_companycode AS f ON a~companycode = f~CompanyCode
       LEFT JOIN i_countrytext WITH PRIVILEGED ACCESS  AS h ON g~Country = h~Country
       LEFT JOIN i_glaccounttextrawdata AS e ON  b~glaccount = e~GLAccount
       LEFT JOIN  i_accountingdocumentjournal  AS c ON a~AccountingDocument = c~AccountingDocument AND a~CompanyCode = c~companycode AND c~GLAccountType = 'C'
        WHERE a~AccountingDocument =  @lv_doc   AND a~FinancialAccountType = 'K'  AND b~HouseBank IS NOT INITIAL"" AND a~FiscalYear = '2024' AND a~CompanyCode = 'GT00'


        INTO @DATA(wa).

    DATA: supplier_add TYPE string.

    CONCATENATE wa-StreetName ',' wa-Country ',' wa-CityName ',' wa-CountryName ',' wa-PostalCode INTO supplier_add.

*    out->write( supplier_add ).

*
*    SELECT
*  a~reservation,
*  a~product,
*  a~batch,
*  a~ResvnItmRequiredQtyInBaseUnit,
*  a~entryunit,
*  b~productdescription,
*  c~manufacturedate,
* c~shelflifeexpirationdate,
* c~plant,
*  d~division
*  FROM i_reservationdocumentitem WITH PRIVILEGED ACCESS AS a
*  LEFT JOIN i_productdescription WITH PRIVILEGED ACCESS AS b ON a~Product = b~Product
*  LEFT JOIN i_batch  WITH PRIVILEGED ACCESS AS c ON a~plant = c~plant
*  LEFT  JOIN i_product WITH PRIVILEGED ACCESS AS d ON  a~product = d~Product
*   WHERE a~Reservation =  '0000000992'  AND c~plant IS NOT INITIAL
*   INTO TABLE @DATA(item).
*
*DELETE ADJACENT DUPLICATES FROM item COMPARING Reservation Product Batch Plant.
*    out->write( item ).
*******Item level data***************

*    SELECT
*     a~accountingdocument,
*     a~businessplace,
*     a~accountingdocumenttype,
*     a~withholdingtaxamount,
*     a~amountincompanycodecurrency,
*     b~documentreferenceid,
*     b~documentdate
*     FROM i_operationalacctgdocitem AS a
*     LEFT JOIN i_journalentry AS b ON a~AccountingDocument = b~AccountingDocument
*      WHERE a~ClearingJournalEntry = @lv_doc AND  a~ClearingJournalEntryFiscalYear = '2024' AND a~CompanyCode = 'GT00' AND
*        a~FinancialAccountType = 'K' AND a~Accountingdocumentitem = '001'
*   INTO TABLE @DATA(item).
**    out->write( item ).
*
*    DATA(lv_xml) =
*    |<Form>| &&
*    |<Header>| &&
**    |<company_name>{ wa-CompanyCodeName }</company_name>| &&
*    |<Branch></Branch>| &&
*    |<supplier></supplier>| &&
*    |<Gst_no>{ wa-TaxNumber3 }</Gst_no>| &&
*    |<Add>{ wa-TaxNumber3 }</Add>| &&
**    |<Voucher_No>{ wa-AccountingDocument }</Voucher_No>| &&
**    |<Voucher_Date>{ wa-PostingDate }</Voucher_Date>| &&
**    |<payment_From>{ wa-GLAccountLongName }</payment_From>| &&
**    |<payment_To>{ wa-SupplierFullName }</payment_To>| &&
**    |<Cheq_Neft_Rtgs_No>{ wa-AccountingDocumentHeaderText }</Cheq_Neft_Rtgs_No>| &&
**    |<Cheq_Neft_Rtgs_Date>{ wa-DocumentDate }</Cheq_Neft_Rtgs_Date>| &&
**    |<Payment_To></Payment_To>| &&
**    |<Logic_for_data_inpara>{ wa-PostingDate }</Logic_for_data_inpara>| &&
*    |<Logic_for_Amount_inpara></Logic_for_Amount_inpara>| &&
*    |</Header>| &&
*    |<LineItem>|.
*
*    LOOP AT item INTO DATA(wa_item).
*      DATA(lv_xml_table) =
*        |<item>| &&
*        |<Sr_No></Sr_No>| &&
*        |<Document_No>{ wa_item-AccountingDocument }</Document_No>| &&
*        |<Business_Place>{ wa_item-BusinessPlace }</Business_Place>| &&
*        |<Document_Type>{ wa_item-AccountingDocumentType }</Document_Type>| &&
*        |<Invoice_Ref_No>{ wa_item-DocumentReferenceID }</Invoice_Ref_No>| &&
*        |<Invoice_Ref_Date>{ wa_item-DocumentDate }</Invoice_Ref_Date>| &&
*        |<Invoice_Amount></Invoice_Amount>| &&
*        |<TDS_Amount>{ wa_item-WithholdingTaxAmount }</TDS_Amount>| &&
*        |<Net_Amount>{ wa_item-AmountInCompanyCodeCurrency }</Net_Amount>| &&
*        |<Total></Total>| &&
*        |</item>|.
*      CONCATENATE lv_xml lv_xml_table INTO lv_xml.
*    ENDLOOP.
*    CONCATENATE lv_xml '</LineItem>' '</Form>' INTO lv_xml. " Properly closing the root tag.
*
**    out->write( lv_xml ).
*
*
**    CALL METHOD zcl_ads_print=>getpdf(
**      EXPORTING
**        xmldata  = lv_xml
**        template = lc_template_name
**      RECEIVING
**        result   = result12 ).





    """"""""""""" writtong code foe billing documentent """"""""""""""""""""""""""""""""""""""""""""""""""""""

    """"""""""header level data"""""""""""""""""""""""""""""""""""

    """"""""" add of plant """"""""""""""""""""""""""""""""""""""""""""""

*select single
*
*a~creationdate ,     """""""'header level
*
*"""""""""""""plant add""""""""""""""
*      a~documentreferenceid,
*        d~state_code2 ,
*       d~plant_name1 ,
*       d~address1 ,
*       d~address2 ,
*       d~city ,
*       d~district ,
*       d~state_name AS supplieradd ,
*       d~pin ,
*       d~country AS supplierad,
*       d~gstin_no,
*       d~cin_no ,    """""""""""""addddddd  pan no got from gst in
*
*       """"""""""""some more dields for foc add
*     i~streetprefixname2,
*     i~streetprefixname1,
*     i~cityname,
*     i~postalcode,
*      f~region,
*     g~regionname,
*     i~districtname
*
*
*
* FROM i_billingdocument WITH PRIVILEGED ACCESS AS a
*      LEFT JOIN i_billingdocumentitem AS b ON a~BillingDocument = b~BillingDocument
*      LEFT JOIN i_salesdocument WITH PRIVILEGED ACCESS AS c  ON b~SalesDocument = c~SalesDocument
*      LEFT JOIN I_Customer WITH PRIVILEGED ACCESS AS h ON a~SoldToParty = h~customer
*     INNER JOIN i_address_2  WITH PRIVILEGED ACCESS AS i ON h~AddressID = i~AddressID
*      LEFT JOIN ztable_plant WITH PRIVILEGED ACCESS AS d ON d~plant_code = b~plant
*      LEFT JOIN i_supplier WITH PRIVILEGED ACCESS AS e ON a~YY1_TransportDetails_BDH = e~Supplier
*      LEFT    JOIN i_customer WITH PRIVILEGED ACCESS AS f ON a~SoldToParty = e~Customer
*      LEFT JOIN i_regiontext WITH PRIVILEGED ACCESS AS g ON f~Country = g~Country
*
*
*where  a~billingdocument = '0090000030'
*
*INTO @DATA(wa_header) .
**PRIVILEGED ACCESS .
*out->write( wa_header ).
*
*""""""""""" select quary for bill top party or add for receipients"""""""
*
*
































































































*
*    DATA(lv_xml) =
*    |<Form>| &&
*    |<BillingDocumentNode>| &&
*    |<AckDate>{ wa_header-ackdate }</AckDate>| &&
*    |<AckNumber>{ wa_header-ackno }</AckNumber>| &&
*    |<BillingDate>{ wa_header-CreationDate }</BillingDate>| &&
*    |<Billingtime>{ wa_header-CreationTime }</Billingtime>| &&
*    |<DocumentReferenceID>{ wa_header-DocumentReferenceID }</DocumentReferenceID>| &&
*    |<Irn>{ wa_header-irnno }</Irn>| &&
*    |<YY1_PLANT_COM_ADD_BDH>{ plant_add }</YY1_PLANT_COM_ADD_BDH>| &&
*    |<YY1_PLANT_COM_NAME_BDH>{ plant_name }</YY1_PLANT_COM_NAME_BDH>| &&
*    |<YY1_PLANT_GSTIN_NO_BDH>{ plant_gstin }</YY1_PLANT_GSTIN_NO_BDH>| &&
*    |<YY1_dodatebd_BDH>{ wa_header-YY1_DODate_SDH }</YY1_dodatebd_BDH>| &&
*    |<YY1_dono_bd_BDH>{ wa_header-YY1_DONo_SDH }</YY1_dono_bd_BDH>| &&
*    |<YY1_NO_OF_PACKAGES_BDH>{ wa_header-yy1_no_of_packages_bdh }</YY1_NO_OF_PACKAGES_BDH>| &&
*    |<YY1_REMARK_BDH>{ wa_header-yy1_remark_bdh }</YY1_REMARK_BDH>| &&
*    |<YY1_TransportDetails_BDHT>{ transport_details }</YY1_TransportDetails_BDHT>| &&
*    |<date_time_removal>{ wa_header-yy1_date_time_removal_bdh }</date_time_removal>| &&
*    |<vehicle_no>{ wa_header-YY1_VEHICLENO_BDH }</vehicle_no>| &&
**    |<Plant>{ wa_header-Plant }</Plant>| &&
**    |<RegionName>{ wa_header-state_name }</RegionName>| &&
*    |<BillToParty>| &&
*    |<AddressLine3Text>{ wa_bill-streetprefixname1 }</AddressLine3Text>| &&
*    |<AddressLine4Text>{ wa_bill-streetprefixname2 }</AddressLine4Text>| &&
*    |<AddressLine5Text>{ wa_bill-streetname }</AddressLine5Text>| &&
*    |<AddressLine6Text>{ wa_bill-streetsuffixname1 }</AddressLine6Text>| &&
*    |<AddressLine7Text>{ wa_bill-streetsuffixname2 }</AddressLine7Text>| &&
*    |<AddressLine8Text>{ temp_add }</AddressLine8Text>| &&
**    |<Region>{ wa_bill-Region }</Region>| &&
*    |<FullName>{ wa_bill-CustomerName }</FullName>| &&   " done
*    |<Partner>{ wa_bill-Customer }</Partner>| &&
*    |<RegionName>{ wa_bill-RegionName }</RegionName>| &&
*    |</BillToParty>| &&
*    |<Items>|.
*
*
*
*    LOOP AT it_item INTO DATA(wa_item).
*
*      SHIFT wa_item-Product LEFT DELETING LEADING '0'.
*
*      SELECT SINGLE
*     a~trade_name,
*     a~quantity_multiple
*     FROM zmaterial_table AS a
*     WHERE a~mat = @wa_item-Product
*     INTO @DATA(wa_item3).
*      DATA: product_text TYPE string.
*
*      IF wa_item3 IS NOT INITIAL.
*        product_text = wa_item3-trade_name.
*      ELSE.
*        " Fetch Product Name from `i_producttext`
*        SELECT SINGLE
*        a~productname
*        FROM i_producttext AS a
*        WHERE a~product = @wa_item-Product
*        INTO @DATA(wa_item4).
*        product_text = wa_item4.
*      ENDIF.
*      DATA(lv_item) =
*      |<BillingDocumentItemNode>|.
*      CONCATENATE lv_xml lv_item INTO lv_xml.
*
*      SELECT
*      SINGLE
*      b~conditionratevalue
*      FROM
*      I_BillingDocumentItem AS a
*      LEFT JOIN I_BillingDocItemPrcgElmntBasic AS b ON a~BillingDocument = b~BillingDocument
*      WHERE a~BillingDocument = @wa_item-BillingDocument
*      INTO @DATA(lv_NetPriceAmount).
*
*
*      DATA(lv_item_xml) =
*
*      |<BillingDocumentItemText>{ product_text }</BillingDocumentItemText>| &&
*      |<IN_HSNOrSACCode>{ wa_item-consumptiontaxctrlcode }</IN_HSNOrSACCode>| &&
*      |<NetPriceAmount>{ lv_NetPriceAmount }</NetPriceAmount>| &&                       " pending
*      |<Plant></Plant>| &&                                         " pending
*      |<Quantity>{ wa_item-BillingQuantity }</Quantity>| &&
*      |<QuantityUnit>{ wa_item-BillingQuantityUnit }</QuantityUnit>| &&
*      |<YY1_avg_package_bd_BDI>{ wa_item3-quantity_multiple }</YY1_avg_package_bd_BDI>| &&
*      |<YY1_bd_zdif_BDI></YY1_bd_zdif_BDI>| &&                      " pending
*      |<YY1_fg_material_name_BDI></YY1_fg_material_name_BDI>| &&    " Pending
*      |<ItemPricingConditions>|.
*      CONCATENATE lv_xml lv_item_xml INTO lv_xml.
*
*      SELECT
*        a~conditionType  ,  "hidden conditiontype
*        a~conditionamount ,  "hidden conditionamount
*        a~conditionratevalue  ,  "condition ratevalue
*        a~conditionbasevalue   " condition base value
*        FROM I_BillingDocItemPrcgElmntBasic AS a
*         WHERE a~BillingDocument = @bill_doc AND a~BillingDocumentItem = @wa_item-BillingDocumentItem
*        INTO TABLE @DATA(lt_item2)
*        PRIVILEGED ACCESS.
*
*      LOOP AT lt_item2 INTO DATA(wa_item2).
*        DATA(lv_item2_xml) =
*        |<ItemPricingConditionNode>| &&
*        |<ConditionAmount>{ wa_item2-ConditionAmount }</ConditionAmount>| &&
*        |<ConditionBaseValue>{ wa_item2-ConditionBaseValue }</ConditionBaseValue>| &&
*        |<ConditionRateValue>{ wa_item2-ConditionRateValue }</ConditionRateValue>| &&
*        |<ConditionType>{ wa_item2-ConditionType }</ConditionType>| &&
*        |</ItemPricingConditionNode>|.
*        CONCATENATE lv_xml lv_item2_xml INTO lv_xml.
*        CLEAR wa_item2.
*      ENDLOOP.
*      DATA(lv_item3_xml) =
*      |</ItemPricingConditions>| &&
*      |</BillingDocumentItemNode>| &&
*      |</Items>|.
*
*      CONCATENATE lv_xml lv_item3_xml INTO lv_xml.
*      CLEAR lv_item.
*      CLEAR lv_item_xml.
*      CLEAR lt_item2.
*      CLEAR wa_item.
*    ENDLOOP.
*
*    SELECT
*    SINGLE
*    c~yy1_termsofpayment_soh_sdh
*    FROM
*    i_billingdocumentitem AS a
*    LEFT JOIN I_salesdocument AS b ON a~salesdocument = b~salesdocument
*    LEFT JOIN I_SalesQuotation AS c ON b~referencesddocument = c~salesquotation
*    WHERE a~BillingDocument = @bill_doc
*    INTO @DATA(lv_payterms).
*
*    DATA(lv_payment_term) =
*      |<PaymentTerms>| &&
*      |<PaymentTermsName>{ lv_payterms }</PaymentTermsName>| &&    " pending
*      |</PaymentTerms>|.
*
*    CONCATENATE lv_xml lv_payment_term INTO lv_xml.
*
*    DATA: temp_add2 TYPE string.
*    temp_add2 = wa_bill-PostalCode.
*    CONCATENATE temp_add2 ' ' wa_bill-CityName ' ' wa_bill-DistrictName ' ' INTO temp_add2.
*
*
**
**    DATA(lv_shiptoparty) =
**    |<ShipToParty>| &&
**    |<AddressLine2Text>{ wa_ship-CustomerName }</AddressLine2Text>| &&
***    |<AddressLine3Text>{ wa_ship-STREETPREFIXNAME2 }</AddressLine3Text>| &&
**    |<AddressLine3Text>{ wa_ship-streetprefixname1 }</AddressLine3Text>| &&
**    |<AddressLine4Text>{ wa_ship-streetprefixname2 }</AddressLine4Text>| &&
***    |<AddressLine4Text>{ wa_ship-STREETNAME }</AddressLine4Text>| &&
**    |<AddressLine5Text>{ wa_ship-streetname }</AddressLine5Text>| &&
***    |<AddressLine5Text>{ wa_ship-STREETPREFIXNAME1 }</AddressLine5Text>| &&
*    |<AddressLine6Text>{ wa_ship-streetsuffixname1 }</AddressLine6Text>| &&
*    |<AddressLine7Text>{ wa_ship-streetsuffixname2 }</AddressLine7Text>| &&
*    |<AddressLine8Text>{ temp_add2 }</AddressLine8Text>| &&
*    |<FullName>{ wa_ship-CustomerName }</FullName>| &&
*    |<custgstin>{ wa_ship-TaxNumber3 }</custgstin>| &&
*    |<RegionName>{ wa_ship-RegionName }</RegionName>| &&
*    |</ShipToParty>|.
*
*    CONCATENATE lv_xml lv_shiptoparty INTO lv_xml.
*
*    DATA(lv_supplier) =
*    |<Supplier>| &&
*    |<RegionName>{ wa_header-state_name }</RegionName>| &&                " pending
*    |</Supplier>|.
*    CONCATENATE lv_xml lv_supplier INTO lv_xml.
*
*    DATA(lv_taxation) =
*    |<TaxationTerms>| &&
*    |<IN_BillToPtyGSTIdnNmbr>{ bill_gstin }</IN_BillToPtyGSTIdnNmbr>| &&       " pending   IN_BillToPtyGSTIdnNmbr
*    |</TaxationTerms>|.
*    CONCATENATE lv_xml lv_taxation INTO lv_xml.
*
*    DATA(lv_footer) =
*    |</BillingDocumentNode>| &&
*    |</Form>|.
*
*    CONCATENATE lv_xml lv_footer INTO lv_xml.
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*      DATA(lv_xml) =
*        |<Form>| &&
*        |<BillingDocumentNode>| &&
*        |<BillingDate>{ wa_header-creationdate }</BillingDate>| &&
*        |<DocumentReferenceID>{ wa_header-documentreferenceid }</DocumentReferenceID>| &&
*        |<PurchaseOrderByCustomer>{ wa_header-PurchaseOrderByCustomer }</PurchaseOrderByCustomer>| &&   " PO number
*        |<AmountInWords></AmountInWords>| &&                      " pending
*        |<SalesDocument>{ wa_header-SalesDocument }</SalesDocument>| && " Work order no
*        |<SalesOrderDate>{ wa_header-salecreationdate }</SalesOrderDate>| && " Work order date
*        |<YY1_CustPODate_BD_h_BDH>{ wa_header-CustomerPurchaseOrderDate }</YY1_CustPODate_BD_h_BDH>| && " PO date
*        |<YY1_LRDate_BDH></YY1_LRDate_BDH>| &&   " Consignment Note Date
*        |<YY1_LRNumber_BDH></YY1_LRNumber_BDH>| &&   " Consignment No
*        |<YY1_PLANT_COM_ADD_BDH>{ plant_add }</YY1_PLANT_COM_ADD_BDH>| &&   " Add left side
*        |<YY1_PLANT_COM_NAME_BDH></YY1_PLANT_COM_NAME_BDH>| &&   " Invoice number
*        |<plant_add>{ lv_plant_add }</plant_add>| &&
*        |<YY1_PLANT_GSTIN_NO_BDH>{ wa_header-gstin_no }</YY1_PLANT_GSTIN_NO_BDH>| &&   " First GST No
*        |<YY1_TransportDetails_BDHT>{ wa_header-SupplierName }</YY1_TransportDetails_BDHT>| &&   " Head office
*        |<YY1_TransportGST_bd_BDH>{ wa_header-TaxNumber3 }</YY1_TransportGST_bd_BDH>| &&   " Transport GST
*        |<YY1_VehicleNo_BDH></YY1_VehicleNo_BDH>| &&   " Vehicle number
*        |<YY1_dodatebd_BDH></YY1_dodatebd_BDH>| &&
*        |<YY1_dono_bd_BDH></YY1_dono_bd_BDH>| &&
*        |<BillToParty>| &&
*        |<Region>{ wa_sold-Region }</Region>| &&
*        |<RegionName>{ wa_sold-RegionName }</RegionName>| &&
*        |</BillToParty>| &&
*        |<Items>|.
*
*
**      DELETE ADJACENT DUPLICATES FROM lt_item COMPARING consumptiontaxctrlcode.
*
*      LOOP AT lt_item INTO DATA(wa_item).
*        DATA(var1_wa_fg) =   |{ wa_item-product ALPHA = OUT }|.
*
*
*        SELECT SINGLE
*        b~trade_name
*        FROM zmaterial_table AS b
*        WHERE b~mat = @var1_wa_fg
*        INTO @DATA(wa_fg) PRIVILEGED ACCESS.
*
*        IF wa_fg IS NOT INITIAL.
*          DATA(lv_fg_mat) = wa_fg.
*        ELSE.
*          SELECT SINGLE
*          a~productname
*          FROM i_producttext AS a
*          WHERE a~product = @bill_doc
*          INTO @DATA(wa_fg2) PRIVILEGED ACCESS.
*          lv_fg_mat = wa_fg2.
*        ENDIF.
*        DATA(lv_item_xml) =
*          |<BillingDocumentItemNode>| &&
*          |<IN_HSNOrSACCode>{ wa_item-ConsumptionTaxCtrlCode }</IN_HSNOrSACCode>| &&
*          |<Plant>{ wa_item-Plant }</Plant>| &&
*          |<Quantity>{ wa_item-BillingQuantity }</Quantity>| &&
*          |<QuantityUnit>{ wa_item-YY1_PackSize_sd_SDIU }</QuantityUnit>| &&
*          |<YY1_avg_package_bd_BDI>{ wa_item-YY1_PackSize_sd_SDI }</YY1_avg_package_bd_BDI>| &&
*          |<YY1_bd_no_of_package_BDI>{ wa_item-YY1_NoofPack_sd_SDI }</YY1_bd_no_of_package_BDI>| &&
*          |<YY1_fg_material_name_BDI>{ lv_fg_mat }</YY1_fg_material_name_BDI>| &&
*          |<ItemPricingConditions>|
*          .
*
*        " Concatenate item XML to the main XML string
*        CONCATENATE lv_xml lv_item_xml INTO lv_xml.
*
*        LOOP AT lt_item2 INTO DATA(wa_item2).
*          DATA(lv_pricing_xml) =
*
*          |<ItemPricingConditionNode>| &&
*          |<ConditionAmount>{ wa_item2-ConditionAmount }</ConditionAmount>| &&
*          |<ConditionBaseValue>{ wa_item2-ConditionBaseValue }</ConditionBaseValue>| &&
*          |<ConditionRateValue>{ wa_item2-ConditionRateValue }</ConditionRateValue>| &&
*          |<ConditionType>{ wa_item2-ConditionType }</ConditionType>| &&
*          |<ValueofSupply></ValueofSupply>| &&                          " pending
*          |</ItemPricingConditionNode>|.
*
*          CLEAR wa_item2.
*          CONCATENATE lv_xml lv_pricing_xml INTO lv_xml.
*        ENDLOOP.
*        DATA(lv_item_footer) =
*        |</ItemPricingConditions>| &&
*        |</BillingDocumentItemNode>|.
*
*        CONCATENATE lv_xml lv_item_footer INTO lv_xml.
*      ENDLOOP.
*
*      DATA: lv_add5 TYPE string.
*
*      CONCATENATE lv_add5 wa_sold-CityName '-' wa_sold-DistrictName INTO lv_add5.
*
*      DATA(lv_soldto_party) =
*      |</Items>| &&
*      |<SoldToParty>| &&
*      |<AddressLine1Text>{ wa_sold-customername }</AddressLine1Text>| &&
*      |<AddressLine2Text>{ wa_sold-StreetName }</AddressLine2Text>| &&
*      |<AddressLine3Text>{ wa_sold-PostalCode }</AddressLine3Text>| &&
*      |<AddressLine4Text>{ wa_sold-housenumber }</AddressLine4Text>| &&
*      |<AddressLine5Text>{ lv_add5 }</AddressLine5Text>| &&
*      |<AddressLine6Text></AddressLine6Text>| &&
*      |<AddressLine7Text></AddressLine7Text>| &&
*      |<AddressLine8Text></AddressLine8Text>| &&
*      |</SoldToParty>|.
*
*      CONCATENATE lv_xml lv_soldto_party INTO lv_xml.
*
*      DATA(lv_taxation) =
*      |<TaxationTerms>| &&
*      |<IN_BillToPtyGSTIdnNmbr>{ wa_sold-taxnumber3 }</IN_BillToPtyGSTIdnNmbr>| &&
*      |</TaxationTerms>|.
*
*      CONCATENATE lv_xml lv_taxation INTO lv_xml.
*
*      " Closing the <Items> and <BillingDocumentNode> tags
*      DATA(no_of_pack) = 'No of Packages'.
*      DATA(lv_remark) = 'Remarks'.
*      DATA(lv_date_time) = 'Date & Time Removal of Goods'.
*
*      DATA(lv_textelement) =
*      |<TextElements>| &&
*      |<TextElementNode>| &&
*      |<TextElementDescription>{ no_of_pack }</TextElementDescription>| &&
*      |<TextElementText>{ footer-yy1_no_of_packages_bdh }</TextElementText>| &&
*      |</TextElementNode>| &&
*      |<TextElementNode>| &&
*      |<TextElementDescription>{ lv_remark }</TextElementDescription>| &&
*      |<TextElementText>{ footer-yy1_remark_bdh }</TextElementText>| &&
*      |</TextElementNode>| &&
*      |<TextElementNode>| &&
*      |<TextElementDescription>{ lv_date_time }</TextElementDescription>| &&
*      |<TextElementText>{ footer-yy1_date_time_removal_bdh }</TextElementText>| &&
*      |</TextElementNode>| &&
*      |</TextElements>|.
*
*      CONCATENATE lv_xml lv_textelement INTO lv_xml.
*
*      DATA(lv_footer) =
*        |</BillingDocumentNode>| &&
*        |</Form>|.
*
*      " Concatenate the footer to the main XML string
*      CONCATENATE lv_xml lv_footer INTO lv_xml.
*






  ENDMETHOD.
ENDCLASS.
