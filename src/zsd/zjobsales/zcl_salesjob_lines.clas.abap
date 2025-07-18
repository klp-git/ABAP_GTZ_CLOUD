CLASS zcl_salesjob_lines DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .

    INTERFACES if_oo_adt_classrun .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_salesjob_lines IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'S_ID'    kind = if_apj_dt_exec_object=>select_option datatype = 'C' length = 10 param_text = 'My ID'                                      changeable_ind = abap_true )
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'My Description'   lowercase_ind = abap_true changeable_ind = abap_true )
      ( selname = 'P_COUNT' kind = if_apj_dt_exec_object=>parameter     datatype = 'I' length = 10 param_text = 'My Count'                                   changeable_ind = abap_true )
      ( selname = 'P_SIMUL' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length =  1 param_text = 'My Simulate Only' checkbox_ind = abap_true  changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'S_ID'    kind = if_apj_dt_exec_object=>select_option sign = 'I' option = 'EQ' low = 'Sales Reg' )
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'Sales Register' )
      ( selname = 'P_COUNT' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = '200' )
      ( selname = 'P_SIMUL' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = abap_true )
    ).
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    TYPES ty_id TYPE c LENGTH 10.

    DATA s_id    TYPE RANGE OF ty_id.
    DATA p_descr TYPE c LENGTH 80.
    DATA p_count TYPE i.
    DATA p_simul TYPE abap_boolean.

    DATA: jobname   TYPE cl_apj_rt_api=>ty_jobname.
    DATA: jobcount  TYPE cl_apj_rt_api=>ty_jobcount.
    DATA: catalog   TYPE cl_apj_rt_api=>ty_catalog_name.
    DATA: template  TYPE cl_apj_rt_api=>ty_template_name.

    DATA: lt_billinglines     TYPE TABLE OF zbillinglines,
          wa_billinglines     TYPE zbillinglines,
          lt_billingprocessed TYPE STANDARD TABLE OF zbillingproc,
          wa_billingprocessed TYPE zbillingproc.
    DATA: lt_cancelled TYPE TABLE OF zbillinglines.
    DATA: wa_cancelled TYPE zbillinglines.

    DATA maxBillingDate TYPE d.
    DATA deleteString TYPE c LENGTH 4.
    DATA: lv_tstamp TYPE timestamp, lv_date TYPE d, lv_time TYPE t, lv_dst TYPE abap_bool.


    GET TIME STAMP FIELD lv_tstamp.
    CONVERT TIME STAMP lv_tstamp TIME ZONE sy-zonlo INTO DATE lv_date TIME lv_time DAYLIGHT SAVING TIME lv_dst.

    deleteString = |{ lv_date+6(2) }| && |{ lv_time+0(2) }|.


    SELECT FROM zbillinglines
      FIELDS MAX( invoicedate ) WHERE invoicedate IS NOT INITIAL
      INTO @maxBillingDate .
    IF maxBillingDate IS INITIAL.
      maxBillingDate = 20010101.
    ELSE.
      maxBillingDate = maxBillingDate - 30.
    ENDIF.

    GET TIME STAMP FIELD DATA(lv_timestamp).

    " Getting the actual parameter values
    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
        WHEN 'S_ID'.
          APPEND VALUE #( sign   = ls_parameter-sign
                          option = ls_parameter-option
                          low    = ls_parameter-low
                          high   = ls_parameter-high ) TO s_id.
        WHEN 'P_DESCR'. p_descr = ls_parameter-low.
        WHEN 'P_COUNT'. p_count = ls_parameter-low.
        WHEN 'P_SIMUL'. p_simul = ls_parameter-low.
      ENDCASE.
    ENDLOOP.

    IF deleteString = p_descr+7(4).
      DELETE FROM zbillingproc WHERE billingdocument IS NOT INITIAL.
      DELETE FROM zbillinglines WHERE companycode IS NOT INITIAL.
      COMMIT WORK.
    ENDIF.

    TRY.
*      read own runtime info catalog
        cl_apj_rt_api=>get_job_runtime_info(
                         IMPORTING
                           ev_jobname        = jobname
                           ev_jobcount       = jobcount
                           ev_catalog_name   = catalog
                           ev_template_name  = template ).

      CATCH cx_apj_rt.
        CLEAR catalog.

    ENDTRY.

    SELECT FROM I_BillingDocument AS header
    JOIN I_BillingDocumentitem AS a ON header~BillingDocument = a~BillingDocument
    LEFT JOIN i_salesdocument AS b ON a~salesdocument = b~SalesDocument
    LEFT JOIN i_salesquotation AS c ON b~ReferenceSDDocument = c~salesquotation
    LEFT JOIN i_salesdocumentpartner AS d ON a~salesdocument = d~salesdocument AND d~PartnerFunction = 'AP'
    LEFT JOIN i_customer AS e ON header~SoldToParty = e~Customer
    LEFT JOIN I_SALESDOCUMENTitem AS f ON a~salesdocument = f~SalesDocument AND a~SalesDocumentItem = f~SalesDocumentItem
    LEFT JOIN i_deliverydocument AS g ON a~ReferenceSDDocument = g~DeliveryDocument
    LEFT JOIN ztable_irn AS h ON header~BillingDocument = h~billingdocno AND header~CompanyCode = h~bukrs
      FIELDS header~BillingDocument,  header~BillingDocumentType, header~Division, header~BillingDocumentDate, header~BillingDocumentIsCancelled,
              header~CompanyCode, header~FiscalYear, header~AccountingDocument, header~SoldToParty,header~SalesDistrict,header~SalesOrganization,
              header~DocumentReferenceID,
              b~referencesddocument,
              e~CustomerAccountGroup,
              c~CreationDate,
              c~salesquotationdate,
              d~FullName,
              a~salesdocument,
              b~CreationDate AS sales_creationdate,
              b~SalesDocumentDate,
              b~purchaseorderbycustomer,
              e~TaxNumber3,
              e~customername,
              a~referencesddocument AS d_referencesddocument,
              g~deliveryDate AS delivery_creationdate,
              a~plant,
              header~DistributionChannel,
              h~ewaydate,
              h~ewaybillno,
              h~ackno
      WHERE header~BillingDocumentDate >= @maxbillingdate AND
      header~BillingDocumentType <> 'F8' AND
      NOT EXISTS (
               SELECT BillingDocument FROM zbillingproc
               WHERE header~BillingDocument = zbillingproc~BillingDocument AND
                 header~CompanyCode = zbillingproc~bukrs AND
                 header~FiscalYear = zbillingproc~fiscalyearvalue )
*            AND header~BillingDocument = '0090000103'
      INTO TABLE @DATA(ltheader).

    SORT ltheader BY BillingDocument.
    DELETE ADJACENT DUPLICATES FROM ltheader COMPARING BillingDocument.

    SELECT FROM I_BillingDocument AS header
    JOIN I_BillingDocumentitem AS a ON header~BillingDocument = a~BillingDocument
    LEFT JOIN i_salesdocument AS b ON a~salesdocument = b~SalesDocument
    LEFT JOIN i_salesquotation AS c ON a~ReferenceSDDocument = c~ReferenceSDDocument
    LEFT JOIN i_salesdocumentpartner AS d ON a~salesdocument = d~salesdocument AND d~PartnerFunction = 'AP'
    LEFT JOIN i_customer AS e ON a~ShipToParty = e~Customer
    LEFT JOIN I_SALESDOCUMENTitem AS f ON a~salesdocument = f~SalesDocument AND a~SalesDocumentItem = f~SalesDocumentItem
      FIELDS
      header~BillingDocument,
      e~TaxNumber3,
      f~shiptoparty,
      e~CustomerName AS ship_customername,
      e~taxnumber3 AS ship_taxnumber3
     WHERE header~BillingDocumentDate >= @maxbillingdate AND
     header~BillingDocumentType <> 'F8' AND
     NOT EXISTS (
           SELECT BillingDocument FROM zbillingproc
           WHERE header~BillingDocument = zbillingproc~BillingDocument AND
             header~CompanyCode = zbillingproc~bukrs AND
             header~FiscalYear = zbillingproc~fiscalyearvalue )
*            AND header~BillingDocument = '0090000103'
  INTO TABLE @DATA(ltheader_ship).

    SORT ltheader_ship BY BillingDocument.
    DELETE ADJACENT DUPLICATES FROM ltheader_ship COMPARING BillingDocument.

    LOOP AT ltheader INTO DATA(wa).
      DELETE FROM zbillinglines
          WHERE zbillinglines~companycode = @wa-CompanyCode AND
          zbillinglines~fiscalyearvalue = @wa-FiscalYear AND
          zbillinglines~invoice = @wa-BillingDocument.
      READ TABLE ltheader_ship INTO DATA(wa_ship) WITH KEY BillingDocument = wa-BillingDocument.
      wa_billingprocessed-billingdocument = wa-BillingDocument.
      wa_billingprocessed-bukrs = wa-CompanyCode.
      wa_billingprocessed-fiscalyearvalue = wa-FiscalYear.
      wa_billingprocessed-creationdatetime = lv_timestamp.
*******************************************      add

      SELECT FROM I_BillingDocumentItem AS item
        LEFT JOIN I_ProductDescription AS pd ON item~Product = pd~Product AND pd~LanguageISOCode = 'EN'
        LEFT JOIN I_BillingDocumentitem AS a ON item~BillingDocument = a~BillingDocument AND item~BillingDocumentItem = a~BillingDocumentItem
        LEFT JOIN I_SalesDocumentItem AS b ON a~product = b~Material AND a~salesdocument = b~SalesDocument AND a~SalesDocumentItem = b~SalesDocumentItem
        LEFT JOIN i_productplantbasic AS c ON a~Product = c~Product
        LEFT JOIN i_billingdocument AS e ON a~BillingDocument = e~BillingDocument
        LEFT JOIN I_Product AS _Product ON  item~Product = _Product~Product
        FIELDS item~BillingDocument, item~BillingDocumentItem
        , item~Plant, item~ProfitCenter, item~Product, item~BillingQuantity, item~BaseUnit, item~BillingQuantityUnit, item~NetAmount,
             item~TaxAmount, item~TransactionCurrency, item~CancelledBillingDocument, item~BillingQuantityinBaseUnit,
             pd~ProductDescription,
             c~consumptiontaxctrlcode,
             e~accountingexchangerate,
             b~MaterialByCustomer,
             b~yy1_sohscode_sdi,
             _Product~ItemCategoryGroup
        WHERE item~BillingDocument = @wa-BillingDocument AND consumptiontaxctrlcode IS NOT INITIAL
           INTO TABLE @DATA(ltlines).

      SELECT FROM I_BillingDocItemPrcgElmntBasic FIELDS BillingDocument , BillingDocumentItem, ConditionRateValue, ConditionAmount, ConditionType,
        transactioncurrency AS d_transactioncurrency
        WHERE BillingDocument = @wa-BillingDocument
        INTO TABLE @DATA(it_price).

      LOOP AT ltlines INTO DATA(wa_lines).
        IF wa_lines-BillingQuantity <> '0'.
          wa_billinglines-invoice = wa_lines-BillingDocument.
          wa_billinglines-lineitemno = wa_lines-BillingDocumentItem.
          wa_billinglines-fiscalyearvalue = wa-FiscalYear.
          wa_billinglines-invoice = wa-BillingDocument.
          wa_billinglines-productcategory = wa_lines-ItemCategoryGroup.
          wa_billinglines-lineitemno = wa_lines-BillingDocumentItem.
          wa_billinglines-companycode = wa-CompanyCode.
          wa_billinglines-invoicedate = wa-BillingDocumentDate.
          wa_billinglines-materialno = wa_lines-Product.
          wa_billinglines-materialdescription  = wa_lines-ProductDescription.
          wa_billinglines-hsncode = wa_lines-consumptiontaxctrlcode.
          wa_billinglines-uom = wa_lines-baseunit.
          wa_billinglines-hscode = wa_lines-yy1_sohscode_sdi.
          wa_billinglines-customeritemcode = wa_lines-MaterialByCustomer.
          wa_billinglines-distributionchannel = wa-DistributionChannel.
          wa_billinglines-division = wa-Division.
          wa_billinglines-salesorganisation = wa-SalesOrganization.
          wa_billinglines-irnacknumber = wa-ackno.
          wa_billinglines-ewaybillnumber = wa-ewaybillno.
          wa_billinglines-ewaybilldatetime = wa-ewaydate.
          wa_billinglines-deliverydate = wa-delivery_creationdate.


          READ TABLE it_price INTO DATA(wa_price) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'ZMRP'.
          wa_billinglines-mrp                  = wa_price-ConditionRateValue.
          CLEAR wa_price.

          READ TABLE it_price INTO DATA(wa_price0) WITH KEY BillingDocument = wa-BillingDocument
                                                      BillingDocumentItem = wa_lines-BillingDocumentItem
                                                      ConditionType = 'ZR00'.
*        ls_response-BasicAmt = wa_price0-ConditionRateValue.
          CLEAR wa_price0.

          READ TABLE it_price INTO DATA(wa_priceIRD) WITH KEY BillingDocument = wa-BillingDocument
                                                      BillingDocumentItem = wa_lines-BillingDocumentItem
                                                      ConditionType = 'ZBSP'.
          READ TABLE it_price INTO DATA(wa_priceIRE) WITH KEY BillingDocument = wa-BillingDocument
                                                   BillingDocumentItem = wa_lines-BillingDocumentItem
                                                   ConditionType = 'ZEXP'.
          READ TABLE it_price INTO DATA(wa_priceSTO) WITH KEY BillingDocument = wa-BillingDocument
                                                   BillingDocumentItem = wa_lines-BillingDocumentItem
                                                   ConditionType = 'ZSTO'.
          READ TABLE it_price INTO DATA(wa_priceCDM) WITH KEY BillingDocument = wa-BillingDocument
                                                   BillingDocumentItem = wa_lines-BillingDocumentItem
                                                   ConditionType = 'ZCDM'.
          IF wa_priceird IS NOT INITIAL.
            wa_billinglines-rate = wa_priceIRD-ConditionRateValue.
          ELSEIF wa_priceIRE IS NOT INITIAL.
            wa_billinglines-rate = wa_priceIRE-ConditionRateValue.
          ELSEIF wa_priceSTO IS NOT INITIAL.
            wa_billinglines-rate =  wa_priceSTO-ConditionRateValue.
          ELSEIF wa_priceCDM IS NOT INITIAL.
            wa_billinglines-rate =  wa_priceCDM-ConditionRateValue.
          ENDIF.
          IF wa_priceCDM IS NOT INITIAL.
            wa_billinglines-rate =  wa_priceCDM-ConditionRateValue.
          ENDIF.
          CLEAR wa_priceIRD.
          CLEAR wa_priceSTO.
          CLEAR wa_priceCDM.
          CLEAR wa_priceire.

          READ TABLE it_price INTO DATA(wa_price1) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'JOIG'.
          wa_billinglines-igstamt                    = wa_price1-ConditionAmount.
          wa_billinglines-igstrate                = wa_price1-ConditionRateValue.
          CLEAR wa_price1.

          READ TABLE it_price INTO DATA(wa_price2) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'JOSG'.
          wa_billinglines-sgstamt                    = wa_price2-ConditionAmount.
          wa_billinglines-cgstamt                    = wa_price2-ConditionAmount.
          wa_billinglines-cgstrate                = wa_price2-ConditionRateValue.
          wa_billinglines-sgstrate                = wa_price2-ConditionRateValue.
          CLEAR wa_price2.

          READ TABLE it_price INTO DATA(wa_price4) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'ZDIF'.
          wa_billinglines-roundoffvalue                = wa_price4-ConditionAmount.
          CLEAR wa_price4.

          READ TABLE it_price INTO DATA(wa_price5) WITH KEY BillingDocument = wa-BillingDocument
                                                       BillingDocumentItem = wa_lines-BillingDocumentItem
                                                       ConditionType = 'ZMAN'.
          wa_billinglines-manditax                = wa_price5-ConditionAmount.
          CLEAR wa_price5.

          READ TABLE it_price INTO DATA(wa_price6) WITH KEY BillingDocument = wa-BillingDocument
                                                       BillingDocumentItem = wa_lines-BillingDocumentItem
                                                       ConditionType = 'ZMCS'.
          wa_billinglines-mandicess               = wa_price6-ConditionAmount.
          CLEAR wa_price6.

          READ TABLE it_price INTO DATA(wa_price7) WITH KEY BillingDocument = wa-BillingDocument
                                                   BillingDocumentItem = wa_lines-BillingDocumentItem
                                                   ConditionType = 'ZDIS'.
          wa_billinglines-discountamount                = wa_price7-ConditionAmount.
          wa_billinglines-discountrate = wa_price7-ConditionRateValue.
          CLEAR wa_price7.

*        wa_billinglines-itemrate                = walines-YY1_IGSTRate_BDI.
*        wa_billinglines-totalamount             = walines-NetAmount + walines-TaxAmount.
*
          SELECT SINGLE FROM i_productsalestax FIELDS Product
            WHERE Product = @wa_lines-Product AND Country = 'IN' AND TaxClassification = '1'
            INTO @DATA(lv_flag).

          IF lv_flag IS NOT INITIAL.
            wa_billinglines-exempted = 'No'.
          ELSE.
            wa_billinglines-exempted = 'Yes'.
          ENDIF.

*          wa_billinglines-discountrate            = 0.
          wa_billinglines-billingqtyinsku         = wa_lines-BillingQuantityInBaseUnit.

          READ TABLE it_price INTO DATA(wa_price8) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'JTC1'.
          wa_billinglines-tcsamount                     = wa_price8-ConditionAmount.
          wa_billinglines-tcsrate                 = wa_price8-ConditionRateValue.
          CLEAR wa_price8.

          READ TABLE it_price INTO DATA(wa_price9) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'ZFRT'.
          READ TABLE it_price INTO DATA(wa_price10) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'ZEFC'.
          IF wa_price9 IS NOT INITIAL.
            wa_billinglines-freightchargeinr          = wa_price9-ConditionAmount * wa_lines-AccountingExchangeRate.
          ELSEIF wa_price10 IS NOT INITIAL.
            wa_billinglines-freightchargeinr          = wa_price10-ConditionAmount * wa_lines-AccountingExchangeRate.
          ENDIF.

*          wa_billinglines-f          = wa_price9-ConditionRateValue.
          CLEAR wa_price9.
          CLEAR wa_price10.

          READ TABLE it_price INTO DATA(wa_price10_INS1) WITH KEY BillingDocument = wa-BillingDocument
                                                          BillingDocumentItem = wa_lines-BillingDocumentItem
                                                          ConditionType = 'ZINC'.

          READ TABLE it_price INTO DATA(wa_price10_INS2) WITH KEY BillingDocument = wa-BillingDocument
                                                          BillingDocumentItem = wa_lines-BillingDocumentItem
                                                          ConditionType = 'ZINP'.
          READ TABLE it_price INTO DATA(wa_price10_INS3) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'ZINS'.
          READ TABLE it_price INTO DATA(wa_price10_INS4) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'ZENS'.
          IF wa_price10_INS1 IS NOT INITIAL.
            wa_billinglines-insuranceamountinr           = wa_price10_INS1-ConditionAmount.
            wa_billinglines-insurancerateinr          = wa_price10_INS1-ConditionRateValue.
          ELSEIF wa_price10_INS2 IS NOT INITIAL.
            wa_billinglines-insuranceamountinr           = wa_price10_INS2-ConditionAmount.
            wa_billinglines-insurancerateinr          = wa_price10_INS2-ConditionRateValue.
          ELSEIF wa_price10_INS3 IS NOT INITIAL.
            wa_billinglines-insuranceamountinr           = wa_price10_INS3-ConditionAmount.
            wa_billinglines-insurancerateinr          = wa_price10_INS3-ConditionRateValue.
          ELSEIF wa_price10_INS4 IS NOT INITIAL.
            wa_billinglines-insuranceamountinr           = wa_price10_INS4-ConditionAmount.
*            wa_billinglines-insurancerateinr          = wa_price10_INS4-ConditionRateValue.
          ENDIF.
          CLEAR wa_price10_INS1.
          CLEAR wa_price10_INS2.
          CLEAR wa_price10_INS3.
          CLEAR wa_price10_INS4.
          READ TABLE it_price INTO DATA(wa_UGST) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'JOUG'.
          IF wa_UGST IS NOT INITIAL.
            wa_billinglines-ugstrate = wa_UGST-ConditionRateValue.
            wa_billinglines-ugstamt = wa_UGST-ConditionAmount.
          ENDIF.
          CLEAR wa_UGST.

          READ TABLE it_price INTO DATA(wa_trans) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem.
          wa_billinglines-documentcurrency = wa_trans-d_transactioncurrency.
          CLEAR wa_trans.
          wa_billinglines-exchangerate = wa_lines-AccountingExchangeRate.
          wa_billinglines-rateininr = wa_billinglines-rate * wa_billinglines-exchangerate.

          wa_billinglines-salesquotation = wa-ReferenceSDDocument.
          wa_billinglines-salesquotationdate = wa-SalesQuotationDate.
          wa_billinglines-creationdate = wa-CreationDate.
          wa_billinglines-salesperson = wa-fullname.
          wa_billinglines-saleordernumber = wa-SalesDocument.
          wa_billinglines-salescreationdate = wa-SalesDocumentDate.
          wa_billinglines-customerponumber = wa-purchaseorderbycustomer.
          wa_billinglines-soldtopartygstin = wa-TaxNumber3.
          wa_billinglines-soldtopartyname = wa-CustomerName.
          wa_billinglines-customergroup = wa-CustomerAccountGroup.
          wa_billinglines-soldtopartynumber = wa-soldtoparty.
          wa_billinglines-shiptopartynumber = wa_ship-shiptoparty.
          wa_billinglines-shiptopartyname = wa_ship-ship_customername.
          wa_billinglines-shiptopartygstno = wa_ship-ship_taxnumber3.
          IF wa-taxnumber3 IS NOT INITIAL.
            wa_billinglines-deliveryplacestatecode = wa-taxnumber3+0(2).
          ENDIF.
          IF wa_ship-taxnumber3 IS NOT INITIAL.
            wa_billinglines-soldtoregioncode = wa_ship-taxnumber3+0(2).
          ENDIF.
          wa_billinglines-deliverynumber = wa-d_referencesddocument.
          wa_billinglines-billingtype = wa-billingdocumenttype.
          wa_billinglines-netamount            = wa_lines-NetAmount.
          wa_billinglines-taxamount            = wa_lines-TaxAmount.
          wa_billinglines-qty = wa_lines-billingquantity.
          wa_billinglines-taxablevaluebeforediscount = wa_billinglines-rateininr * wa_billinglines-qty.
          wa_billinglines-taxablevalueafterdiscount = wa_billinglines-taxablevaluebeforediscount + wa_billinglines-discountamount.
          wa_billinglines-invoiceamount  = wa_billinglines-taxablevalueafterdiscount + wa_billinglines-igstamt + wa_billinglines-cgstamt
                                         + wa_billinglines-sgstamt + wa_billinglines-ugstamt + wa_billinglines-roundoffvalue + wa_billinglines-freightchargeinr +
                                         wa_billinglines-insuranceamountinr.
          wa_billinglines-cancelledinvoice = ''.

          IF wa_billinglines-billingtype = 'S1'.
            wa_billinglines-netamount            = wa_billinglines-netamount * -1.
            wa_billinglines-taxamount            = wa_billinglines-taxamount * -1.
            wa_billinglines-qty = wa_lines-billingquantity * -1.
            wa_billinglines-taxablevaluebeforediscount = wa_billinglines-taxablevaluebeforediscount * -1.
            wa_billinglines-taxablevalueafterdiscount = wa_billinglines-taxablevalueafterdiscount * -1.
            wa_billinglines-invoiceamount  = wa_billinglines-invoiceamount * -1.

            wa_billinglines-insuranceamountinr = wa_billinglines-insuranceamountinr * -1.
            wa_billinglines-tcsamount = wa_billinglines-tcsamount * -1.
            wa_billinglines-discountamount = wa_billinglines-discountamount * -1.
            wa_billinglines-mandicess = wa_billinglines-mandicess * -1.
            wa_billinglines-manditax = wa_billinglines-manditax * -1.
            wa_billinglines-roundoffvalue = wa_billinglines-roundoffvalue * -1.
            wa_billinglines-sgstamt     = wa_billinglines-sgstamt * -1.
            wa_billinglines-cgstamt = wa_billinglines-cgstamt * -1.
            wa_billinglines-igstamt = wa_billinglines-igstamt * -1.
            wa_billinglines-ugstamt = wa_billinglines-ugstamt * -1.
            wa_billinglines-cancelledinvoice = 'X'.
            wa_cancelled-invoice = wa_billinglines-invoice.
            APPEND wa_cancelled TO lt_cancelled.
            CLEAR wa_cancelled.
          ENDIF.

          IF wa-billingdocumenttype = 'F2'.
            wa_billinglines-billingdocdesc = 'Standard Invoice'.
          ENDIF.
          IF wa-billingdocumenttype = 'JSTO'.
            wa_billinglines-billingdocdesc = 'STO Invoice'.
          ENDIF.
          IF wa-billingdocumenttype = 'G2'.
            wa_billinglines-billingdocdesc = 'Credit Note'.
          ENDIF.
          IF wa-billingdocumenttype = 'L2'.
            wa_billinglines-billingdocdesc = 'Debit Note'.
          ENDIF.
          IF wa-billingdocumenttype = 'S1'.
            wa_billinglines-billingdocdesc = 'Invoice Cancellation'.
          ENDIF.
          IF wa-billingdocumenttype = 'S2'.
            wa_billinglines-billingdocdesc = 'Credit Memo Cancellation'.
          ENDIF.
          IF wa-billingdocumenttype = 'F8'.
            wa_billinglines-billingdocdesc = 'Export Commercial Invoice'.
          ENDIF.


          wa_billinglines-billno = wa-DocumentReferenceID.
          wa_billinglines-invoicedate = wa-billingdocumentdate.
          wa_billinglines-deliveryplant = wa-Plant.

          SELECT SINGLE FROM
          zbillinglines AS a
          FIELDS
          a~invoice,
          a~materialno,
          a~lineitemno,
          a~qty
          WHERE a~invoice = @wa_billinglines-invoice AND
          a~fiscalyearvalue = @wa_billinglines-fiscalyearvalue AND a~companycode = @wa_billinglines-companycode AND
          a~lineitemno = @wa_billinglines-lineitemno
          INTO @DATA(lv_checkdub).

          IF wa_billinglines-invoice = lv_checkdub-invoice AND wa_billinglines-materialno = lv_checkdub-materialno AND
          wa_billinglines-lineitemno = lv_checkdub-lineitemno AND wa_billinglines-qty = lv_checkdub-qty.
          ELSE.
            MODIFY zbillinglines FROM @wa_billinglines.
          ENDIF.
          CLEAR: wa_lines,wa_billinglines.
        ENDIF.
      ENDLOOP.

      MODIFY zbillingproc FROM @wa_billingprocessed.
      CLEAR: wa, wa_billingprocessed.
    ENDLOOP.

    """""""""" changes """"""""""""""""""""


    """""""""""""""""""""""""""""""""""""""

    LOOP AT lt_cancelled INTO wa_cancelled.
      SELECT SINGLE billingdocument,CancelledBillingDocument FROM i_billingdocument
            WHERE BillingDocument = @wa_cancelled-invoice
            INTO @DATA(temp).
      IF temp IS NOT INITIAL.
        SELECT * FROM zbillinglines AS dc
        WHERE dc~invoice = @temp-CancelledBillingDocument
        INTO TABLE @DATA(temp_zbillinglines).

        LOOP AT temp_zbillinglines INTO DATA(wa_temp_zbillinglines).
          wa_temp_zbillinglines-cancelledinvoice = 'X'.
          MODIFY zbillinglines FROM @wa_temp_zbillinglines.
          CLEAR wa_temp_zbillinglines.
        ENDLOOP.
      ENDIF.
      CLEAR wa_cancelled.
    ENDLOOP.


  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    DATA: lt_billinglines     TYPE TABLE OF zbillinglines,
          wa_billinglines     TYPE zbillinglines,
          lt_billingprocessed TYPE STANDARD TABLE OF zbillingproc,
          wa_billingprocessed TYPE zbillingproc.
    DATA: lt_cancelled TYPE TABLE OF zbillinglines.
    DATA: wa_cancelled TYPE zbillinglines.
    DATA maxBillingDate TYPE d.
    DATA deleteString TYPE c LENGTH 4.
    DATA: lv_tstamp TYPE timestamp, lv_date TYPE d, lv_time TYPE t, lv_dst TYPE abap_bool.


    GET TIME STAMP FIELD lv_tstamp.
    CONVERT TIME STAMP lv_tstamp TIME ZONE sy-zonlo INTO DATE lv_date TIME lv_time DAYLIGHT SAVING TIME lv_dst.

    deleteString = |{ lv_date+6(2) }| && |{ lv_time+0(2) }|.

    IF deleteString = '2819'.
      DELETE FROM zbillingproc WHERE billingdocument IS NOT INITIAL.
      DELETE FROM zbillinglines WHERE companycode IS NOT INITIAL.
      COMMIT WORK.
    ENDIF.

    SELECT FROM zbillinglines
      FIELDS MAX( invoicedate ) WHERE invoicedate IS NOT INITIAL
      INTO @maxBillingDate .
    IF maxBillingDate IS INITIAL.
      maxBillingDate = 20010101.
    ELSE.
      maxBillingDate = maxBillingDate - 30.
    ENDIF.

    GET TIME STAMP FIELD DATA(lv_timestamp).

    DELETE FROM zbillingproc WHERE billingdocument IS NOT INITIAL.
    DELETE FROM zbillinglines WHERE companycode IS NOT INITIAL.
*COMMIT WORK.

        SELECT FROM I_BillingDocument AS header
    JOIN I_BillingDocumentitem AS a ON header~BillingDocument = a~BillingDocument
    LEFT JOIN i_salesdocument AS b ON a~salesdocument = b~SalesDocument
    LEFT JOIN i_salesquotation AS c ON b~ReferenceSDDocument = c~salesquotation
    LEFT JOIN i_salesdocumentpartner AS d ON a~salesdocument = d~salesdocument AND d~PartnerFunction = 'AP'
    LEFT JOIN i_customer AS e ON header~SoldToParty = e~Customer
    LEFT JOIN I_SALESDOCUMENTitem AS f ON a~salesdocument = f~SalesDocument AND a~SalesDocumentItem = f~SalesDocumentItem
    LEFT JOIN i_deliverydocument AS g ON a~ReferenceSDDocument = g~DeliveryDocument
    LEFT JOIN ztable_irn AS h ON header~BillingDocument = h~billingdocno AND header~CompanyCode = h~bukrs
      FIELDS header~BillingDocument,  header~BillingDocumentType, header~Division, header~BillingDocumentDate, header~BillingDocumentIsCancelled,
              header~CompanyCode, header~FiscalYear, header~AccountingDocument, header~SoldToParty,header~SalesDistrict,header~SalesOrganization,
              header~DocumentReferenceID,
              b~referencesddocument,
              e~CustomerAccountGroup,
              c~CreationDate,
              c~salesquotationdate,
              d~FullName,
              a~salesdocument,
              b~CreationDate AS sales_creationdate,
              b~SalesDocumentDate,
              b~purchaseorderbycustomer,
              e~TaxNumber3,
              e~customername,
              a~referencesddocument AS d_referencesddocument,
              g~deliveryDate AS delivery_creationdate,
              a~plant,
              header~DistributionChannel,
              h~ewaydate,
              h~ewaybillno,
              h~ackno
      WHERE
*      header~BillingDocumentDate >= @maxbillingdate AND
      header~BillingDocumentType <> 'F8' AND
      NOT EXISTS (
               SELECT BillingDocument FROM zbillingproc
               WHERE header~BillingDocument = zbillingproc~BillingDocument AND
                 header~CompanyCode = zbillingproc~bukrs AND
                 header~FiscalYear = zbillingproc~fiscalyearvalue )
*            AND header~BillingDocument = '0090000103'
      INTO TABLE @DATA(ltheader).

    SORT ltheader BY BillingDocument.
    DELETE ADJACENT DUPLICATES FROM ltheader COMPARING BillingDocument.

    SELECT FROM I_BillingDocument AS header
    JOIN I_BillingDocumentitem AS a ON header~BillingDocument = a~BillingDocument
    LEFT JOIN i_salesdocument AS b ON a~salesdocument = b~SalesDocument
    LEFT JOIN i_salesquotation AS c ON a~ReferenceSDDocument = c~ReferenceSDDocument
    LEFT JOIN i_salesdocumentpartner AS d ON a~salesdocument = d~salesdocument AND d~PartnerFunction = 'AP'
    LEFT JOIN i_customer AS e ON a~ShipToParty = e~Customer
    LEFT JOIN I_SALESDOCUMENTitem AS f ON a~salesdocument = f~SalesDocument AND a~SalesDocumentItem = f~SalesDocumentItem
      FIELDS
      header~BillingDocument,
      e~TaxNumber3,
      f~shiptoparty,
      e~CustomerName AS ship_customername,
      e~taxnumber3 AS ship_taxnumber3
     WHERE
*     header~BillingDocumentDate >= @maxbillingdate AND
     header~BillingDocumentType <> 'F8' AND
     NOT EXISTS (
           SELECT BillingDocument FROM zbillingproc
           WHERE header~BillingDocument = zbillingproc~BillingDocument AND
             header~CompanyCode = zbillingproc~bukrs AND
             header~FiscalYear = zbillingproc~fiscalyearvalue )
*            AND header~BillingDocument = '0090000103'
  INTO TABLE @DATA(ltheader_ship).

    SORT ltheader_ship BY BillingDocument.
    DELETE ADJACENT DUPLICATES FROM ltheader_ship COMPARING BillingDocument.

    LOOP AT ltheader INTO DATA(wa).
      DELETE FROM zbillinglines
          WHERE zbillinglines~companycode = @wa-CompanyCode AND
          zbillinglines~fiscalyearvalue = @wa-FiscalYear AND
          zbillinglines~invoice = @wa-BillingDocument.
      READ TABLE ltheader_ship INTO DATA(wa_ship) WITH KEY BillingDocument = wa-BillingDocument.
      wa_billingprocessed-billingdocument = wa-BillingDocument.
      wa_billingprocessed-bukrs = wa-CompanyCode.
      wa_billingprocessed-fiscalyearvalue = wa-FiscalYear.
      wa_billingprocessed-creationdatetime = lv_timestamp.
*******************************************      add

      SELECT FROM I_BillingDocumentItem AS item
        LEFT JOIN I_ProductDescription AS pd ON item~Product = pd~Product AND pd~LanguageISOCode = 'EN'
        LEFT JOIN I_BillingDocumentitem AS a ON item~BillingDocument = a~BillingDocument AND item~BillingDocumentItem = a~BillingDocumentItem
        LEFT JOIN I_SalesDocumentItem AS b ON a~product = b~Material AND a~salesdocument = b~SalesDocument AND a~SalesDocumentItem = b~SalesDocumentItem
        LEFT JOIN i_productplantbasic AS c ON a~Product = c~Product
        LEFT JOIN i_billingdocument AS e ON a~BillingDocument = e~BillingDocument
        LEFT JOIN I_Product AS _Product ON  item~Product = _Product~Product
        FIELDS item~BillingDocument, item~BillingDocumentItem
        , item~Plant, item~ProfitCenter, item~Product, item~BillingQuantity, item~BaseUnit, item~BillingQuantityUnit, item~NetAmount,
             item~TaxAmount, item~TransactionCurrency, item~CancelledBillingDocument, item~BillingQuantityinBaseUnit,
             pd~ProductDescription,
             c~consumptiontaxctrlcode,
             e~accountingexchangerate,
             b~MaterialByCustomer,
             b~yy1_sohscode_sdi,
             _Product~ItemCategoryGroup
        WHERE item~BillingDocument = @wa-BillingDocument AND consumptiontaxctrlcode IS NOT INITIAL
           INTO TABLE @DATA(ltlines).

      SELECT FROM I_BillingDocItemPrcgElmntBasic FIELDS BillingDocument , BillingDocumentItem, ConditionRateValue, ConditionAmount, ConditionType,
        transactioncurrency AS d_transactioncurrency
        WHERE BillingDocument = @wa-BillingDocument
        INTO TABLE @DATA(it_price).

      LOOP AT ltlines INTO DATA(wa_lines).
        IF wa_lines-BillingQuantity <> '0'.
          wa_billinglines-invoice = wa_lines-BillingDocument.
          wa_billinglines-lineitemno = wa_lines-BillingDocumentItem.
          wa_billinglines-fiscalyearvalue = wa-FiscalYear.
          wa_billinglines-invoice = wa-BillingDocument.
          wa_billinglines-productcategory = wa_lines-ItemCategoryGroup.
          wa_billinglines-lineitemno = wa_lines-BillingDocumentItem.
          wa_billinglines-companycode = wa-CompanyCode.
          wa_billinglines-invoicedate = wa-BillingDocumentDate.
          wa_billinglines-materialno = wa_lines-Product.
          wa_billinglines-materialdescription  = wa_lines-ProductDescription.
          wa_billinglines-hsncode = wa_lines-consumptiontaxctrlcode.
          wa_billinglines-uom = wa_lines-baseunit.
          wa_billinglines-hscode = wa_lines-yy1_sohscode_sdi.
          wa_billinglines-customeritemcode = wa_lines-MaterialByCustomer.
          wa_billinglines-distributionchannel = wa-DistributionChannel.
          wa_billinglines-division = wa-Division.
          wa_billinglines-salesorganisation = wa-SalesOrganization.
          wa_billinglines-irnacknumber = wa-ackno.
          wa_billinglines-ewaybillnumber = wa-ewaybillno.
          wa_billinglines-ewaybilldatetime = wa-ewaydate.
          wa_billinglines-deliverydate = wa-delivery_creationdate.


          READ TABLE it_price INTO DATA(wa_price) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'ZMRP'.
          wa_billinglines-mrp                  = wa_price-ConditionRateValue.
          CLEAR wa_price.

          READ TABLE it_price INTO DATA(wa_price0) WITH KEY BillingDocument = wa-BillingDocument
                                                      BillingDocumentItem = wa_lines-BillingDocumentItem
                                                      ConditionType = 'ZR00'.
*        ls_response-BasicAmt = wa_price0-ConditionRateValue.
          CLEAR wa_price0.

          READ TABLE it_price INTO DATA(wa_priceIRD) WITH KEY BillingDocument = wa-BillingDocument
                                                      BillingDocumentItem = wa_lines-BillingDocumentItem
                                                      ConditionType = 'ZBSP'.
          READ TABLE it_price INTO DATA(wa_priceIRE) WITH KEY BillingDocument = wa-BillingDocument
                                                   BillingDocumentItem = wa_lines-BillingDocumentItem
                                                   ConditionType = 'ZEXP'.
          READ TABLE it_price INTO DATA(wa_priceSTO) WITH KEY BillingDocument = wa-BillingDocument
                                                   BillingDocumentItem = wa_lines-BillingDocumentItem
                                                   ConditionType = 'ZSTO'.
          READ TABLE it_price INTO DATA(wa_priceCDM) WITH KEY BillingDocument = wa-BillingDocument
                                                   BillingDocumentItem = wa_lines-BillingDocumentItem
                                                   ConditionType = 'ZCDM'.
          IF wa_priceird IS NOT INITIAL.
            wa_billinglines-rate = wa_priceIRD-ConditionRateValue.
          ELSEIF wa_priceIRE IS NOT INITIAL.
            wa_billinglines-rate = wa_priceIRE-ConditionRateValue.
          ELSEIF wa_priceSTO IS NOT INITIAL.
            wa_billinglines-rate =  wa_priceSTO-ConditionRateValue.
          ELSEIF wa_priceCDM IS NOT INITIAL.
            wa_billinglines-rate =  wa_priceCDM-ConditionRateValue.
          ENDIF.
          IF wa_priceCDM IS NOT INITIAL.
            wa_billinglines-rate =  wa_priceCDM-ConditionRateValue.
          ENDIF.
          CLEAR wa_priceIRD.
          CLEAR wa_priceSTO.
          CLEAR wa_priceCDM.
          CLEAR wa_priceire.

          READ TABLE it_price INTO DATA(wa_price1) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'JOIG'.
          wa_billinglines-igstamt                    = wa_price1-ConditionAmount.
          wa_billinglines-igstrate                = wa_price1-ConditionRateValue.
          CLEAR wa_price1.

          READ TABLE it_price INTO DATA(wa_price2) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'JOSG'.
          wa_billinglines-sgstamt                    = wa_price2-ConditionAmount.
          wa_billinglines-cgstamt                    = wa_price2-ConditionAmount.
          wa_billinglines-cgstrate                = wa_price2-ConditionRateValue.
          wa_billinglines-sgstrate                = wa_price2-ConditionRateValue.
          CLEAR wa_price2.

          READ TABLE it_price INTO DATA(wa_price4) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'ZDIF'.
          wa_billinglines-roundoffvalue                = wa_price4-ConditionAmount.
          CLEAR wa_price4.

          READ TABLE it_price INTO DATA(wa_price5) WITH KEY BillingDocument = wa-BillingDocument
                                                       BillingDocumentItem = wa_lines-BillingDocumentItem
                                                       ConditionType = 'ZMAN'.
          wa_billinglines-manditax                = wa_price5-ConditionAmount.
          CLEAR wa_price5.

          READ TABLE it_price INTO DATA(wa_price6) WITH KEY BillingDocument = wa-BillingDocument
                                                       BillingDocumentItem = wa_lines-BillingDocumentItem
                                                       ConditionType = 'ZMCS'.
          wa_billinglines-mandicess               = wa_price6-ConditionAmount.
          CLEAR wa_price6.

          READ TABLE it_price INTO DATA(wa_price7) WITH KEY BillingDocument = wa-BillingDocument
                                                   BillingDocumentItem = wa_lines-BillingDocumentItem
                                                   ConditionType = 'ZDIS'.
          wa_billinglines-discountamount                = wa_price7-ConditionAmount.
          wa_billinglines-discountrate = wa_price7-ConditionRateValue.
          CLEAR wa_price7.

*        wa_billinglines-itemrate                = walines-YY1_IGSTRate_BDI.
*        wa_billinglines-totalamount             = walines-NetAmount + walines-TaxAmount.
*
          SELECT SINGLE FROM i_productsalestax FIELDS Product
            WHERE Product = @wa_lines-Product AND Country = 'IN' AND TaxClassification = '1'
            INTO @DATA(lv_flag).

          IF lv_flag IS NOT INITIAL.
            wa_billinglines-exempted = 'No'.
          ELSE.
            wa_billinglines-exempted = 'Yes'.
          ENDIF.

*          wa_billinglines-discountrate            = 0.
          wa_billinglines-billingqtyinsku         = wa_lines-BillingQuantityInBaseUnit.

          READ TABLE it_price INTO DATA(wa_price8) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'JTC1'.
          wa_billinglines-tcsamount                     = wa_price8-ConditionAmount.
          wa_billinglines-tcsrate                 = wa_price8-ConditionRateValue.
          CLEAR wa_price8.

          READ TABLE it_price INTO DATA(wa_price9) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'ZFRT'.
          READ TABLE it_price INTO DATA(wa_price10) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'ZEFC'.
          IF wa_price9 IS NOT INITIAL.
            wa_billinglines-freightchargeinr          = wa_price9-ConditionAmount * wa_lines-AccountingExchangeRate.
          ELSEIF wa_price10 IS NOT INITIAL.
            wa_billinglines-freightchargeinr          = wa_price10-ConditionAmount * wa_lines-AccountingExchangeRate.
          ENDIF.

*          wa_billinglines-f          = wa_price9-ConditionRateValue.
          CLEAR wa_price9.
          CLEAR wa_price10.

          READ TABLE it_price INTO DATA(wa_price10_INS1) WITH KEY BillingDocument = wa-BillingDocument
                                                          BillingDocumentItem = wa_lines-BillingDocumentItem
                                                          ConditionType = 'ZINC'.

          READ TABLE it_price INTO DATA(wa_price10_INS2) WITH KEY BillingDocument = wa-BillingDocument
                                                          BillingDocumentItem = wa_lines-BillingDocumentItem
                                                          ConditionType = 'ZINP'.
          READ TABLE it_price INTO DATA(wa_price10_INS3) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'ZINS'.
          READ TABLE it_price INTO DATA(wa_price10_INS4) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'ZENS'.
          IF wa_price10_INS1 IS NOT INITIAL.
            wa_billinglines-insuranceamountinr           = wa_price10_INS1-ConditionAmount.
            wa_billinglines-insurancerateinr          = wa_price10_INS1-ConditionRateValue.
          ELSEIF wa_price10_INS2 IS NOT INITIAL.
            wa_billinglines-insuranceamountinr           = wa_price10_INS2-ConditionAmount.
            wa_billinglines-insurancerateinr          = wa_price10_INS2-ConditionRateValue.
          ELSEIF wa_price10_INS3 IS NOT INITIAL.
            wa_billinglines-insuranceamountinr           = wa_price10_INS3-ConditionAmount.
            wa_billinglines-insurancerateinr          = wa_price10_INS3-ConditionRateValue.
          ELSEIF wa_price10_INS4 IS NOT INITIAL.
            wa_billinglines-insuranceamountinr           = wa_price10_INS4-ConditionAmount.
*            wa_billinglines-insurancerateinr          = wa_price10_INS4-ConditionRateValue.
          ENDIF.
          CLEAR wa_price10_INS1.
          CLEAR wa_price10_INS2.
          CLEAR wa_price10_INS3.
          CLEAR wa_price10_INS4.
          READ TABLE it_price INTO DATA(wa_UGST) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'JOUG'.
          IF wa_UGST IS NOT INITIAL.
            wa_billinglines-ugstrate = wa_UGST-ConditionRateValue.
            wa_billinglines-ugstamt = wa_UGST-ConditionAmount.
          ENDIF.
          CLEAR wa_UGST.

          READ TABLE it_price INTO DATA(wa_trans) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem.
          wa_billinglines-documentcurrency = wa_trans-d_transactioncurrency.
          CLEAR wa_trans.
          wa_billinglines-exchangerate = wa_lines-AccountingExchangeRate.
          wa_billinglines-rateininr = wa_billinglines-rate * wa_billinglines-exchangerate.

          wa_billinglines-salesquotation = wa-ReferenceSDDocument.
          wa_billinglines-salesquotationdate = wa-SalesQuotationDate.
          wa_billinglines-creationdate = wa-CreationDate.
          wa_billinglines-salesperson = wa-fullname.
          wa_billinglines-saleordernumber = wa-SalesDocument.
          wa_billinglines-salescreationdate = wa-SalesDocumentDate.
          wa_billinglines-customerponumber = wa-purchaseorderbycustomer.
          wa_billinglines-soldtopartygstin = wa-TaxNumber3.
          wa_billinglines-soldtopartyname = wa-CustomerName.
          wa_billinglines-customergroup = wa-CustomerAccountGroup.
          wa_billinglines-soldtopartynumber = wa-soldtoparty.
          wa_billinglines-shiptopartynumber = wa_ship-shiptoparty.
          wa_billinglines-shiptopartyname = wa_ship-ship_customername.
          wa_billinglines-shiptopartygstno = wa_ship-ship_taxnumber3.
          IF wa-taxnumber3 IS NOT INITIAL.
            wa_billinglines-deliveryplacestatecode = wa-taxnumber3+0(2).
          ENDIF.
          IF wa_ship-taxnumber3 IS NOT INITIAL.
            wa_billinglines-soldtoregioncode = wa_ship-taxnumber3+0(2).
          ENDIF.
          wa_billinglines-deliverynumber = wa-d_referencesddocument.
          wa_billinglines-billingtype = wa-billingdocumenttype.
          wa_billinglines-netamount            = wa_lines-NetAmount.
          wa_billinglines-taxamount            = wa_lines-TaxAmount.
          wa_billinglines-qty = wa_lines-billingquantity.
          wa_billinglines-taxablevaluebeforediscount = wa_billinglines-rateininr * wa_billinglines-qty.
          wa_billinglines-taxablevalueafterdiscount = wa_billinglines-taxablevaluebeforediscount + wa_billinglines-discountamount.
          wa_billinglines-invoiceamount  = wa_billinglines-taxablevalueafterdiscount + wa_billinglines-igstamt + wa_billinglines-cgstamt
                                         + wa_billinglines-sgstamt + wa_billinglines-ugstamt + wa_billinglines-roundoffvalue + wa_billinglines-freightchargeinr +
                                         wa_billinglines-insuranceamountinr.
          wa_billinglines-cancelledinvoice = ''.

          IF wa_billinglines-billingtype = 'S1'.
            wa_billinglines-netamount            = wa_billinglines-netamount * -1.
            wa_billinglines-taxamount            = wa_billinglines-taxamount * -1.
            wa_billinglines-qty = wa_lines-billingquantity * -1.
            wa_billinglines-taxablevaluebeforediscount = wa_billinglines-taxablevaluebeforediscount * -1.
            wa_billinglines-taxablevalueafterdiscount = wa_billinglines-taxablevalueafterdiscount * -1.
            wa_billinglines-invoiceamount  = wa_billinglines-invoiceamount * -1.

            wa_billinglines-insuranceamountinr = wa_billinglines-insuranceamountinr * -1.
            wa_billinglines-tcsamount = wa_billinglines-tcsamount * -1.
            wa_billinglines-discountamount = wa_billinglines-discountamount * -1.
            wa_billinglines-mandicess = wa_billinglines-mandicess * -1.
            wa_billinglines-manditax = wa_billinglines-manditax * -1.
            wa_billinglines-roundoffvalue = wa_billinglines-roundoffvalue * -1.
            wa_billinglines-sgstamt     = wa_billinglines-sgstamt * -1.
            wa_billinglines-cgstamt = wa_billinglines-cgstamt * -1.
            wa_billinglines-igstamt = wa_billinglines-igstamt * -1.
            wa_billinglines-ugstamt = wa_billinglines-ugstamt * -1.
            wa_billinglines-cancelledinvoice = 'X'.
            wa_cancelled-invoice = wa_billinglines-invoice.
            APPEND wa_cancelled TO lt_cancelled.
            CLEAR wa_cancelled.
          ENDIF.

          IF wa-billingdocumenttype = 'F2'.
            wa_billinglines-billingdocdesc = 'Standard Invoice'.
          ENDIF.
          IF wa-billingdocumenttype = 'JSTO'.
            wa_billinglines-billingdocdesc = 'STO Invoice'.
          ENDIF.
          IF wa-billingdocumenttype = 'G2'.
            wa_billinglines-billingdocdesc = 'Credit Note'.
          ENDIF.
          IF wa-billingdocumenttype = 'L2'.
            wa_billinglines-billingdocdesc = 'Debit Note'.
          ENDIF.
          IF wa-billingdocumenttype = 'S1'.
            wa_billinglines-billingdocdesc = 'Invoice Cancellation'.
          ENDIF.
          IF wa-billingdocumenttype = 'S2'.
            wa_billinglines-billingdocdesc = 'Credit Memo Cancellation'.
          ENDIF.
          IF wa-billingdocumenttype = 'F8'.
            wa_billinglines-billingdocdesc = 'Export Commercial Invoice'.
          ENDIF.


          wa_billinglines-billno = wa-DocumentReferenceID.
          wa_billinglines-invoicedate = wa-billingdocumentdate.
          wa_billinglines-deliveryplant = wa-Plant.

          SELECT SINGLE FROM
          zbillinglines AS a
          FIELDS
          a~invoice,
          a~materialno,
          a~lineitemno,
          a~qty
          WHERE a~invoice = @wa_billinglines-invoice AND
          a~fiscalyearvalue = @wa_billinglines-fiscalyearvalue AND a~companycode = @wa_billinglines-companycode AND
          a~lineitemno = @wa_billinglines-lineitemno
          INTO @DATA(lv_checkdub).

          IF wa_billinglines-invoice = lv_checkdub-invoice AND wa_billinglines-materialno = lv_checkdub-materialno AND
          wa_billinglines-lineitemno = lv_checkdub-lineitemno AND wa_billinglines-qty = lv_checkdub-qty.
          ELSE.
            MODIFY zbillinglines FROM @wa_billinglines.
          ENDIF.
          CLEAR: wa_lines,wa_billinglines.
        ENDIF.
      ENDLOOP.

      MODIFY zbillingproc FROM @wa_billingprocessed.
      CLEAR: wa, wa_billingprocessed.
    ENDLOOP.

    """""""""" changes """"""""""""""""""""


    """""""""""""""""""""""""""""""""""""""

    LOOP AT lt_cancelled INTO wa_cancelled.
      SELECT SINGLE billingdocument,CancelledBillingDocument FROM i_billingdocument
            WHERE BillingDocument = @wa_cancelled-invoice
            INTO @DATA(temp).
      IF temp IS NOT INITIAL.
        SELECT * FROM zbillinglines AS dc
        WHERE dc~invoice = @temp-CancelledBillingDocument
        INTO TABLE @DATA(temp_zbillinglines).

        LOOP AT temp_zbillinglines INTO DATA(wa_temp_zbillinglines).
          wa_temp_zbillinglines-cancelledinvoice = 'X'.
          MODIFY zbillinglines FROM @wa_temp_zbillinglines.
          CLEAR wa_temp_zbillinglines.
        ENDLOOP.
      ENDIF.
      CLEAR wa_cancelled.
    ENDLOOP.



*    SELECT * FROM zbillinglines
*               INTO TABLE @DATA(it).
*    LOOP AT it INTO DATA(wa1).
*      out->write( data = 'Data : client -' ) .
*      out->write( data = wa1-client ) .
*      out->write( data = '- bukrs-' ) .
*      out->write( data = wa1-materialdescription ) .
*      out->write( data = '- doc-' ) .
*      out->write( data = wa1-billingdocument ) .
*      out->write( data = '- item -' ) .
*      out->write( data = wa1-billingdocumentitem ) .
*    endloop.

  ENDMETHOD.
ENDCLASS.
