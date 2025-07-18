CLASS zcl_purchasejob_lines DEFINITION
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



CLASS ZCL_PURCHASEJOB_LINES IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
*      ( selname = 'S_ID'    kind = if_apj_dt_exec_object=>select_option datatype = 'C' length = 10 param_text = 'My ID'                                      changeable_ind = abap_true )
*      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'My Description'   lowercase_ind = abap_true changeable_ind = abap_true )
*      ( selname = 'P_COUNT' kind = if_apj_dt_exec_object=>parameter     datatype = 'I' length = 10 param_text = 'My Count'                                   changeable_ind = abap_true )
      ( selname = 'P_SIMUL' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length =  1 param_text = 'Full Processing' checkbox_ind = abap_true  changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
*      ( selname = 'S_ID'    kind = if_apj_dt_exec_object=>select_option sign = 'I' option = 'EQ' low = '4711' )
*      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'My Default Description' )
*      ( selname = 'P_COUNT' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = '200' )
      ( selname = 'P_SIMUL' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = abap_false )
    ).

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    TYPES ty_id TYPE c LENGTH 10.
    DATA s_id    TYPE RANGE OF ty_id.
    DATA p_descr TYPE c LENGTH 80.
    DATA p_count TYPE i.
    DATA p_simul TYPE abap_boolean.
    DATA processfrom TYPE d.

*************************************** RATE GST ************************************
    DATA: lv_gst_text  TYPE string,
          lv_igst_perc TYPE string,
          lv_cgst_perc TYPE string,
          lv_sgst_perc TYPE string,
          lv_pos_start TYPE i,
          lv_pos_end   TYPE i,
          lv_length    TYPE i.

    TYPES: BEGIN OF ty_gst_data,
             SupplierInvoice   TYPE I_SuplrInvcItemPurOrdRefAPI01-SupplierInvoice,
             PurchaseOrderItem TYPE I_SuplrInvcItemPurOrdRefAPI01-PurchaseOrderItem,
             Igst              TYPE c LENGTH 10,
             Cgst              TYPE c LENGTH 10,
             Sgst              TYPE c LENGTH 10,
           END OF ty_gst_data.
    DATA: lt_gst_data TYPE TABLE OF ty_gst_data, " Temporary table for storing GST values
          ls_gst_data TYPE ty_gst_data.  " Work area for GST extraction
************************************************************************************

    DATA: jobname   TYPE cl_apj_rt_api=>ty_jobname.
    DATA: jobcount  TYPE cl_apj_rt_api=>ty_jobcount.
    DATA: catalog   TYPE cl_apj_rt_api=>ty_catalog_name.
    DATA: template  TYPE cl_apj_rt_api=>ty_template_name.

    DATA: lt_purchinvlines     TYPE STANDARD TABLE OF zpurchinvlines,
          wa_purchinvlines     TYPE zpurchinvlines,
          lt_purchinvprocessed TYPE STANDARD TABLE OF zpurchinvproc,
          wa_purchinvprocessed TYPE zpurchinvproc.


****************************************************************************************
    DATA maxpostingdate TYPE d.
    DATA deleteString TYPE c LENGTH 4.
    DATA: lv_tstamp TYPE timestamp, lv_date TYPE d, lv_time TYPE t, lv_dst TYPE abap_bool.

    GET TIME STAMP FIELD DATA(lv_timestamp).

    GET TIME STAMP FIELD lv_tstamp.
    CONVERT TIME STAMP lv_tstamp TIME ZONE sy-zonlo INTO DATE lv_date TIME lv_time DAYLIGHT SAVING TIME lv_dst.

    deleteString = |{ lv_date+6(2) }| && |{ lv_time+0(2) }|.

    IF deleteString = '2819'.
      DELETE FROM zpurchinvlines WHERE purchaseorder IS NOT INITIAL.
      DELETE FROM zpurchinvproc WHERE companycode IS NOT INITIAL .
      COMMIT WORK.
    ENDIF.

    SELECT FROM zpurchinvlines "zbillinglines
      FIELDS MAX( postingdate ) WHERE postingdate IS NOT INITIAL
      INTO @maxpostingdate .
    IF maxpostingdate IS INITIAL.
      maxpostingdate = 20010101.
    ELSE.
      maxpostingdate = maxpostingdate - 30.
    ENDIF.
****************************************************************************************


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

    TRY.
*      read own runtime info catalog
        cl_apj_rt_api=>get_job_runtime_info(
                         IMPORTING
                           ev_jobname        = jobname
                           ev_jobcount       = jobcount
                           ev_catalog_name   = catalog
                           ev_template_name  = template ).

      CATCH cx_apj_rt.
        CLEAR jobname.

    ENDTRY.

    processfrom = sy-datum - 30.
    IF p_simul = abap_true.
      processfrom = sy-datum - 2000.
    ENDIF.


*    DATA: lt_purchinvlines     TYPE STANDARD TABLE OF zpurchinvlines,
*          wa_purchinvlines     TYPE zpurchinvlines,
*          lt_purchinvprocessed TYPE STANDARD TABLE OF zpurchinvproc,
*          wa_purchinvprocessed TYPE zpurchinvproc.
*    DELETE FROM zpurchinvlines.
*    DELETE FROM zpurchinvproc.

    SELECT FROM I_SupplierInvoiceAPI01 AS c
        LEFT JOIN i_supplier AS b ON b~supplier = c~InvoicingParty
        LEFT JOIN zmsme_table AS d ON c~InvoicingParty = d~vendorno
        FIELDS
            b~Supplier,
            b~SupplierAccountGroup,
            b~PostalCode,
            b~BPAddrCityName,
            b~BPAddrStreetName,
            b~TaxNumber3,
            b~BusinessPartnerPanNumber,
            b~BPSupplierName,
            b~SupplierFullName,
            b~region,
            c~ReverseDocument,
            c~ReverseDocumentFiscalYear,
            c~CompanyCode,
            c~PaymentTerms,
            c~CreatedByUser,
            c~CreationDate,
            c~InvoicingParty,
            c~InvoiceGrossAmount,
            c~DocumentCurrency,
            c~SupplierInvoiceIDByInvcgParty,
            c~FiscalYear,
            c~SupplierInvoice,
            c~SupplierInvoiceWthnFiscalYear,
            c~DocumentDate,
            c~PostingDate,
            d~vendortype
        WHERE
        c~PostingDate >= @processfrom AND
        NOT EXISTS (
               SELECT supplierinvoice FROM zpurchinvproc
               WHERE c~supplierinvoice = zpurchinvproc~supplierinvoice AND
                 c~CompanyCode = zpurchinvproc~companycode AND
                 c~FiscalYear = zpurchinvproc~fiscalyearvalue )
            INTO TABLE @DATA(ltheader).


*    DELETE ADJACENT DUPLICATES FROM ltheader COMPARING Supplier.
    DATA: lv_orrefdoc TYPE string.

    LOOP AT ltheader INTO DATA(waheader).


      DATA: lv_sl TYPE string.
      lv_sl = waheader-SupplierInvoice.
      CONCATENATE lv_sl waheader-FiscalYear INTO lv_sl.

*      SELECT SINGLE FROM
*      i_operationalacctgdocitem AS g INNER JOIN
*      I_JournalEntry AS h ON g~AccountingDocument = h~AccountingDocument AND g~FiscalYear = h~FiscalYear
*      FIELDS
*      g~OriginalReferenceDocument
*      WHERE h~IsReversed = 'X' AND
*      g~OriginalReferenceDocument = @lv_sl
*      INTO @DATA(lv_reversed).
*
*      IF lv_reversed IS INITIAL.




      SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
       FIELDS
           a~PurchaseOrderItem,
           a~SupplierInvoiceItem,
           a~PurchaseOrder,
           a~FreightSupplier ,
           a~SupplierInvoice ,
           a~FiscalYear ,
           a~TaxJurisdiction AS SInvwithFYear,
           a~plant,
           a~PurchaseOrderItemMaterial AS material,
           a~QuantityInPurchaseOrderUnit,
           a~QtyInPurchaseOrderPriceUnit,
           a~PurchaseOrderQuantityUnit,
           a~ReferenceDocument ,
           a~ReferenceDocumentFiscalYear,
           a~PurchaseOrderPriceUnit,
           a~ReferenceDocumentItem,
           a~TaxCode,
           a~SupplierInvoiceItemAmount,
           a~DebitCreditCode,
           a~SuplrInvcDeliveryCostCndnType
       WHERE a~SupplierInvoice = @waheader-SupplierInvoice AND a~FiscalYear = @waheader-FiscalYear

         AND a~FiscalYear = @waheader-FiscalYear
         INTO TABLE @DATA(ltlines).
      SORT ltlines BY SupplierInvoiceItem PurchaseOrderItem DESCENDING.
*      DELETE ADJACENT DUPLICATES FROM ltlines COMPARING PurchaseOrder PurchaseOrderItem.

      LOOP AT ltlines INTO DATA(walines).
        """"" header data """""""""""""""""""""""""
*          SELECT FROM
*          I_PurchaseOrderHistoryApi01 AS a
*          FIELDS
*          a~PurchaseOrder,
*          a~PurchaseOrderItem,
*          a~PurchasingHistoryDocument,
*          a~PurchasingHistoryDocumentItem
*          WHERE a~PurchaseOrder = @walines-PurchaseOrder AND a~PurchaseOrderItem = @walines-PurchaseOrderItem
*          AND a~PurchasingHistoryCategory = 'E'
*          INTO TABLE @DATA(lt_grn).

*          LOOP AT lt_grn INTO DATA(wa_grn).
        lv_orrefdoc = waheader-SupplierInvoice.
        CONCATENATE lv_orrefdoc waheader-FiscalYear INTO lv_orrefdoc.

        SELECT SINGLE FROM
        i_operationalacctgdocitem AS a
        FIELDS
        a~AccountingDocument
        WHERE a~CompanyCode = @waheader-CompanyCode AND
        a~FiscalYear = @waheader-FiscalYear AND
        a~AccountingDocumentType  IN ( 'KG', 'KC', 'RE', 'UR', 'RK' ) AND
        a~OriginalReferenceDocument = @lv_orrefdoc
        INTO @DATA(lv_acc).


        DATA str1 TYPE string.
        SELECT SINGLE
        a~AccountingDocument,
        a~businessplace,
        b~plant_name1,
        b~plant_name2,
        b~gstin_no
        FROM  i_operationalacctgdocitem AS a
        LEFT JOIN ztable_plant AS b ON a~BusinessPlace = b~plant_code
        WHERE a~CompanyCode = @waheader-CompanyCode AND
        a~FiscalYear = @waheader-FiscalYear AND
        a~AccountingDocument = @lv_acc
        INTO @DATA(lv_accstr1).

        SELECT SINGLE
       a~AccountingDocument,
       a~taxcode,
       b~taxcodename,
       a~ProfitCenter

       FROM  i_operationalacctgdocitem AS a
        LEFT JOIN i_taxcodetext WITH PRIVILEGED ACCESS AS b ON a~taxcode = b~TaxCode
       WHERE a~CompanyCode = @waheader-CompanyCode AND
       a~FiscalYear = @waheader-FiscalYear AND
       a~Accountingdocumentitemtype = 'W' OR
       a~Accountingdocumentitemtype = '' AND
       a~TransactionTypeDetermination = 'WRX' OR
       a~TransactionTypeDetermination = '' AND
       a~AccountingDocument = @lv_acc
       INTO @DATA(lv_accstr2).

        CONCATENATE lv_accstr1-Plant_Name1 lv_accstr1-Plant_Name2 INTO str1 SEPARATED BY space.

        SELECT SINGLE FROM
       i_operationalacctgdocitem AS a
       FIELDS
       a~AccountingDocument,
       a~AccountingDocumentType
       WHERE a~CompanyCode = @waheader-CompanyCode AND
       a~FiscalYear = @waheader-FiscalYear AND
       a~OriginalReferenceDocument = @lv_orrefdoc
       INTO @DATA(wa_main).

        wa_purchinvlines-fiscalyearvalue = waheader-FiscalYear.  " done
        wa_purchinvlines-supplierinvoice = waheader-SupplierInvoice. "done
        wa_purchinvlines-companycode = waheader-CompanyCode. " done
        wa_purchinvlines-fidocumentno = lv_acc. " done
        wa_purchinvlines-postingdate = waheader-PostingDate.
        wa_purchinvlines-plantname = str1. " done
        wa_purchinvlines-plantgst = lv_accstr1-gstin_no. " done
        wa_purchinvlines-taxcodename = lv_accstr2-TaxCodeName.
        wa_purchinvlines-profitcenter = lv_accstr2-ProfitCenter.
        wa_purchinvlines-documenttype = wa_main-AccountingDocumentType. " done
        wa_purchinvlines-vendorcode = waheader-invoicingparty. " done
        wa_purchinvlines-vendorname = waheader-BPSupplierName. " done
        wa_purchinvlines-suppliergstno = waheader-TaxNumber3. " done
        wa_purchinvlines-supplierpanno  = waheader-BusinessPartnerPanNumber. " done
        wa_purchinvlines-vendor_type = waheader-vendortype. " done



        """""" line data """""""""""""""""""""""""
        DATA : lv_matdes TYPE string.
        lv_matdes = walines-material.
        SHIFT lv_matdes LEFT DELETING LEADING '0'.

        SELECT SINGLE
        FROM zmaterial_table AS a
        FIELDS
        a~trade_name

        WHERE a~mat = @lv_matdes
        INTO @DATA(wa_materialdes).

        SELECT SINGLE
        FROM I_PurchaseOrderAPI01 AS a
        FIELDS
        a~PurchaseOrderType,
        a~PurchaseOrderDate,
        a~Purchasingorganization,
        a~PurchasingGroup,
        a~YY1_Quotation_No_PDH,
        a~YY1_Quotation_Date_PO_PDH
        WHERE a~PurchaseOrder = @walines-PurchaseOrder
        INTO @DATA(lv_po).

        SELECT SINGLE FROM
        I_ProductText AS a
        FIELDS
        a~ProductName
        WHERE a~Product = @walines-material AND a~Language = 'E'
        INTO @DATA(lv_prtxt).

        SELECT SINGLE FROM
        i_purchaseorderhistoryapi01 AS a
        LEFT JOIN I_BillingDocumentItem AS b ON a~PurchasingHistoryDocument = b~ReferenceSDDocument AND a~PurchasingHistoryDocumentItem = b~ReferenceSDDocumentItem
        LEFT JOIN ztable_irn AS c ON b~BillingDocument = c~billingdocno
        FIELDS
        c~ewaybillno,
        c~ewaydate
        WHERE a~PurchaseOrder = @walines-PurchaseOrder AND a~PurchaseOrderItem = @walines-PurchaseOrderItem
        INTO @DATA(lv_eway).

        SELECT SINGLE FROM
        I_DeliveryDocumentItem AS a
        LEFT JOIN I_DeliveryDocument AS b ON a~DeliveryDocument = b~DeliveryDocument
        FIELDS
        b~DeliveryDocumentBySupplier
        WHERE a~PurchaseOrder = @walines-PurchaseOrder AND
        a~PurchaseOrderItem = @walines-PurchaseOrderItem
        INTO @DATA(wa_vendor).

        SELECT SINGLE
        FROM i_purchaseorderhistoryapi01 AS a
        LEFT JOIN I_MaterialDocumentHeader_2 AS b ON b~MaterialDocument = a~PurchasingHistoryDocument
        FIELDS
        a~DocumentDate, a~PurchasingHistoryDocument, b~ReferenceDocument
        WHERE a~PurchaseOrder = @walines-PurchaseOrder AND a~PurchaseOrderItem = @walines-PurchaseOrderItem
        INTO @DATA(lv_vendor_date).

        SELECT SINGLE FROM
        i_purchaseorderitemtp_2 AS a
        LEFT JOIN I_Requestforquotation_Api01 AS b ON a~SupplierQuotation = b~RequestForQuotation
        FIELDS
        a~SupplierQuotation,
        b~RFQPublishingDate
        WHERE a~PurchaseOrder = @walines-PurchaseOrder
        INTO @DATA(wa_rfq).

        SELECT SINGLE FROM
        I_MaterialDocumentItem_2 AS a
        FIELDS
        a~QuantityInBaseUnit
        WHERE a~PurchaseOrder = @walines-PurchaseOrder AND a~PurchaseOrderItem = @walines-PurchaseOrderItem
        INTO @DATA(lv_mrn).

        SELECT SINGLE FROM
        i_purchaseorderhistoryapi01 AS a
        FIELDS
        a~PostingDate
        WHERE a~PurchaseOrder = @walines-PurchaseOrder AND a~PurchaseOrderItem = @walines-PurchaseOrderItem
        AND a~PurchasingHistoryCategory = 'Q'
        INTO @DATA(wa_mrn_date).

        SELECT SINGLE FROM
        i_purchaseorderhistoryapi01 AS a
        FIELDS
        a~PostingDate
        WHERE a~PurchasingHistoryDocument = @walines-ReferenceDocument AND
        a~PurchasingHistoryCategory = 'E'
        INTO @DATA(lv_grn_date).

        SELECT SINGLE FROM
        i_purchaseorderhistoryapi01 AS a
        FIELDS
        a~QuantityInDeliveryQtyUnit,
        a~QuantityInBaseUnit
        WHERE a~PurchasingHistoryDocument = @walines-ReferenceDocument AND
        a~PurchasingHistoryDocumentYear = @walines-ReferenceDocumentFiscalYear AND
        a~PurchasingHistoryDocumentItem = @walines-ReferenceDocumentItem
        INTO @DATA(lv_grn_qty).

        SELECT SINGLE FROM
        i_purchaseorderhistoryapi01 AS a
        LEFT JOIN i_inbounddelivery AS b ON a~DeliveryDocument = b~InboundDelivery
        FIELDS
        a~DeliveryDocument,
        b~DeliveryDate
        WHERE
        a~PurchaseOrder = @walines-PurchaseOrder
        AND a~PurchaseOrderItem = @walines-PurchaseOrderItem
        INTO @DATA(lv_inbound).

        SELECT SINGLE FROM
        i_inspectionlot AS a
        FIELDS
        a~InspectionLot,
        a~InspectionLotCreatedOn
        WHERE a~MaterialDocument = @walines-ReferenceDocument
        INTO @DATA(lv_inspection).

        SELECT SINGLE FROM
        i_operationalacctgdocitem AS a
        FIELDS
        a~IN_HSNOrSACCode
        WHERE a~CompanyCode = @waheader-CompanyCode AND
        a~FiscalYear = @waheader-FiscalYear AND
        a~OriginalReferenceDocument = @lv_orrefdoc
        INTO @DATA(lv_hsn).

        SELECT SINGLE FROM
        I_TaxCodeText AS a
        FIELDS
        a~TaxCodeName
        WHERE a~TaxCode = @walines-TaxCode
        INTO @DATA(lv_taxcodename).

        SELECT SINGLE FROM
        i_purorditmpricingelementapi01 AS a
        FIELDS
        a~ConditionRateValue
        WHERE a~PurchaseOrder = @walines-PurchaseOrder AND
        a~PurchaseOrderItem = @walines-PurchaseOrderItem AND a~ConditionType = 'PMP0'
        INTO @DATA(lv_basic).

        """"""""""""""""""""  gst  """""""""""""""""""""""""""""""""
        DATA: lv_string TYPE string.
        DATA: lv_result_cgst TYPE p DECIMALS 2.
        DATA: lv_result_sgst TYPE p DECIMALS 2.
        DATA: lv_result_igst TYPE p DECIMALS 2.
        DATA : lv_index TYPE i VALUE -1.
        DATA: lv_result_gst TYPE string.

        lv_string = lv_taxcodename.


        IF lv_string IS NOT INITIAL.
          FIND to_upper( 'CGST' ) IN lv_string MATCH OFFSET lv_index.

          IF lv_index <> -1.
            lv_index = lv_index + 5.

            DATA: j TYPE i.
            j = lv_index.
            WHILE j < strlen( lv_string ) AND ( lv_string+j(1) ) <> '%'.
              j = j + 1.
            ENDWHILE.
            IF j = strlen( lv_string ).
              lv_result_cgst = 0.
            ELSE.
              j = j - lv_index.
              lv_result_gst = lv_string+lv_index(j).
              REPLACE '%' IN lv_result_gst WITH ' '.
              CONDENSE lv_result_gst NO-GAPS.
              lv_result_cgst = lv_result_gst.
            ENDIF..
          ENDIF.

          CLEAR lv_index.
          CLEAR lv_result_gst.
          lv_index = -1.

          FIND to_upper( 'SGST' ) IN lv_string MATCH OFFSET lv_index.
          IF lv_index <> -1.
            lv_index = lv_index + 5.
            j = lv_index.
            WHILE j < strlen( lv_string ) AND ( lv_string+j(1) ) <> '%'.
              j = j + 1.
            ENDWHILE.
            IF j = strlen( lv_string ).
              lv_result_sgst = 0.
            ELSE.
              j = j - lv_index.
              lv_result_gst = lv_string+lv_index(j).

*          lv_result_gst = lv_string+lv_index(2).
              REPLACE '%' IN lv_result_gst WITH ' '.
              CONDENSE lv_result_gst NO-GAPS.
              lv_result_sgst = lv_result_gst.
            ENDIF.
          ENDIF.

          CLEAR lv_index.
          CLEAR lv_result_gst.
          lv_index = -1.

          FIND to_upper( 'IGST' ) IN lv_string MATCH OFFSET lv_index.
          IF lv_index <> -1.
            lv_index = lv_index + 5.
            j = lv_index.
            WHILE j < strlen( lv_string ) AND ( lv_string+j(1) ) <> '%'.
              j = j + 1.
            ENDWHILE.
            IF j = strlen( lv_string ).
              lv_result_igst = 0.
            ELSE.
              j = j - lv_index.
              lv_result_gst = lv_string+lv_index(j).
*          lv_result_gst = lv_string+lv_index(2).
              REPLACE '%' IN lv_result_gst WITH ' '.
              CONDENSE lv_result_gst NO-GAPS.
              lv_result_igst = lv_result_gst.
            ENDIF.
          ENDIF.

          CLEAR lv_index.
          CLEAR lv_result_gst.
          lv_index = -1.
        ENDIF.
        lv_index = -1.
        CLEAR lv_result_gst.
        CLEAR lv_string.

        SELECT SINGLE FROM
        i_operationalacctgdocitem AS a
        FIELDS
        a~TaxBaseAmountInTransCrcy
        WHERE a~CompanyCode = @waheader-CompanyCode AND
        a~FiscalYear = @waheader-FiscalYear AND
        a~AccountingDocumentType  IN ( 'KG','KC','RE' ) AND
        a~OriginalReferenceDocument = @lv_orrefdoc
        INTO @DATA(lv_taxtrnas).

        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        wa_purchinvlines-supplierinvoiceitem = walines-SupplierInvoiceItem. " done
        wa_purchinvlines-product = lv_matdes. " done
        wa_purchinvlines-productname = lv_prtxt. " done
        wa_purchinvlines-product_trade_name = wa_materialdes. " done
        wa_purchinvlines-purchaseorder = walines-PurchaseOrder. " done
        wa_purchinvlines-purchaseorderitem = walines-PurchaseOrderItem. " done
        wa_purchinvlines-purchaseordertype = lv_po-PurchaseOrderType. " done
        wa_purchinvlines-purchaseorderdate = lv_po-PurchaseOrderDate. " done
        wa_purchinvlines-Purchasingorganization = lv_po-Purchasingorganization. " done
        wa_purchinvlines-purchasinggroup = lv_po-PurchasingGroup. " done

*          IF wa_vendor IS INITIAL.
        SELECT SINGLE FROM I_JournalEntry AS a
       FIELDS a~DocumentReferenceID
       WHERE a~CompanyCode = @waheader-CompanyCode AND
       a~FiscalYear = @waheader-FiscalYear AND
       a~AccountingDocument = @lv_acc
       INTO @DATA(VendorInvNo).



        wa_purchinvlines-vendor_invoice_no = VendorInvNo . " done
*          ELSE.
*            wa_purchinvlines-vendor_invoice_no = wa_vendor . " done
*          ENDIF.

        wa_purchinvlines-vendor_invoice_date = waheader-DocumentDate. " done
        wa_purchinvlines-rfqno = wa_rfq-SupplierQuotation. " done
        wa_purchinvlines-rfqdate = wa_rfq-RFQPublishingDate. " done
*        wa_purchinvlines-baseunit = walines-BaseUnit.
        wa_purchinvlines-Mrnquantityinbaseunit = walines-QuantityInPurchaseOrderUnit. " done
        wa_purchinvlines-Mrnpostingdate = waheader-PostingDate. " done
*        wa_purchinvlines-vendor_invoice_date = walines-DocumentDate.
        wa_purchinvlines-ewaybillno = lv_eway-ewaybillno. " done
        wa_purchinvlines-ewaybilldate = lv_eway-ewaydate. " done
        wa_purchinvlines-supplierquotation = lv_po-YY1_Quotation_No_PDH. " done
        wa_purchinvlines-supplierquotationdate = lv_po-YY1_Quotation_Date_PO_PDH. " done
*            wa_purchinvlines-grnno = wa_grn-purchasinghistorydocument. " done
        wa_purchinvlines-grnno = walines-ReferenceDocument. " done
        wa_purchinvlines-grnline = walines-ReferenceDocumentItem. " done
        wa_purchinvlines-grndate = lv_grn_date. " done
        wa_purchinvlines-grnqty = lv_grn_qty-QuantityInBaseUnit. " done
        wa_purchinvlines-deliveryqty = lv_grn_qty-QuantityInDeliveryQtyUnit. " done
        wa_purchinvlines-inboundno = lv_inbound-DeliveryDocument. " done
        wa_purchinvlines-inbounddate = lv_inbound-DeliveryDate. " done
        wa_purchinvlines-inspectionlot = lv_inspection-InspectionLot. " done
        wa_purchinvlines-inspectiondate = lv_inspection-InspectionLotCreatedOn. " done
        wa_purchinvlines-hsncode = lv_hsn. " done
        wa_purchinvlines-taxcode = walines-TaxCode. " done
        wa_purchinvlines-taxcodename = lv_taxcodename. " done
        wa_purchinvlines-basicrate = lv_basic. " done

****************************************************************************************  Net Amount Change by Vinay
        IF walines-DebitCreditCode = 'H'.
          wa_purchinvlines-netamount = ( walines-SupplierInvoiceItemAmount * -1 ). " done
        ELSE.
          wa_purchinvlines-netamount = walines-SupplierInvoiceItemAmount .
        ENDIF.

        IF walines-TaxCode+0(1) = 'H'.
          wa_purchinvlines-gstinputtype = 'Non Eligible Credit'.
        ELSE.
          wa_purchinvlines-gstinputtype = 'Eligible Credit'.
        ENDIF.

        SELECT SINGLE FROM I_AccountingDocumentJournal( p_language = 'E' ) AS a
        FIELDS a~AccountingDocumentTypeName
        WHERE a~Ledger = '0L'
        AND a~AccountingDocumentType = @wa_purchinvlines-documenttype
        INTO @DATA(lv_acc_type_name).

******************************************************************************************************************* Added by Vinay on 16-06-2025
        SELECT SINGLE FROM I_AccountingDocumentJournal( p_language = 'E' ) AS a
        LEFT JOIN i_fixedasset AS b ON a~MasterFixedAsset = b~MasterFixedAsset
        FIELDS a~MasterFixedAsset AS AssetNumber,
               b~fixedassetdescription,
               b~AssetAdditionalDescription
        WHERE a~Ledger = '0L'
        AND a~PurchasingDocument = @wa_purchinvlines-purchaseorder
        AND a~PurchasingDocumentItem = @wa_purchinvlines-purchaseorderitem
        AND a~assetaccttransclassfctn = '11'
        AND a~transactiontypedetermination = 'ANL'
        INTO @DATA(Asset).

        DATA(AssetDescription) = |{ Asset-FixedAssetDescription } { asset-AssetAdditionalDescription }|.

        wa_purchinvlines-assetno = asset-assetnumber.
        wa_purchinvlines-assetname = assetdescription.

        IF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZAF'.
          wa_purchinvlines-othercharge_fright = 'Oversease Charges'.
        ELSEIF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZCT'.
          wa_purchinvlines-othercharge_fright = 'Custom Duty'.
        ELSEIF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZFR'.
          wa_purchinvlines-othercharge_fright = 'Freight Charges'.
        ELSEIF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZGT'.
          wa_purchinvlines-othercharge_fright = 'Avg. Freight Charges'.
        ELSEIF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZIN'.
          wa_purchinvlines-othercharge_fright = 'Insurance Charges'.
        ELSEIF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZOT'.
          wa_purchinvlines-othercharge_fright = 'Other Charges'.
        ELSEIF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZPK'.
          wa_purchinvlines-othercharge_fright = 'Packing & Forwarding Charges'.
        ELSEIF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZSD'.
          wa_purchinvlines-othercharge_fright = 'Shipping Charges'.
        ELSEIF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZSF'.
          wa_purchinvlines-othercharge_fright = 'Sea Freight Charges'.
        ELSEIF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZSN'.
          wa_purchinvlines-othercharge_fright = 'Shipping NOC Charges'.
        ELSEIF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZSV'.
          wa_purchinvlines-othercharge_fright = 'Sipping Det. Charges'.
        ENDIF.

********************************************************************************************************************
*
        wa_purchinvlines-documenttypename = lv_acc_type_name .
        wa_purchinvlines-debitcreditcode = walines-debitcreditcode.

*********************************************************************************************************************

        wa_purchinvlines-rateigst = lv_result_igst. " done
        wa_purchinvlines-ratecgst = lv_result_cgst. " done
        wa_purchinvlines-ratesgst = lv_result_sgst. " done

        wa_purchinvlines-igst = wa_purchinvlines-netamount * ( lv_result_igst / 100 ). " done
        wa_purchinvlines-sgst = wa_purchinvlines-netamount * ( lv_result_sgst / 100 ). " done
        wa_purchinvlines-cgst = wa_purchinvlines-netamount * ( lv_result_cgst / 100 ). " done

        SELECT SINGLE FROM I_OperationalAcctgDocItem
        FIELDS AmountInCompanyCodeCurrency, TransactionTypeDetermination, TaxBaseAmountInCoCodeCrcy
        WHERE AccountingDocument = @wa_purchinvlines-fidocumentno
        AND TaxItemGroup = @wa_purchinvlines-supplierinvoiceitem
        AND TransactionTypeDetermination = 'JIM' AND CompanyCode = @wa_purchinvlines-companycode
        AND FiscalYear = @wa_purchinvlines-fiscalyearvalue
        INTO ( @wa_purchinvlines-igst, @DATA(lv_txtypedet), @DATA(lv_taxbaseamt) ) PRIVILEGED ACCESS.

******************************************************************************************************Fields Added by Vinay
        IF walines-TaxCode+0(1) = 'J' OR walines-TaxCode+0(1) = 'M'.
          wa_purchinvlines-rcmigst = ( wa_purchinvlines-igst * -1 ).
          wa_purchinvlines-rcmcgst = ( wa_purchinvlines-cgst * -1 ).
          wa_purchinvlines-rcmsgst = ( wa_purchinvlines-sgst * -1 ).
        ELSE.
          wa_purchinvlines-rcmigst = 0.
          wa_purchinvlines-rcmcgst = 0.
          wa_purchinvlines-rcmsgst = 0.
        ENDIF.

        wa_purchinvlines-taxamount = wa_purchinvlines-igst + wa_purchinvlines-cgst + wa_purchinvlines-sgst. " done
        wa_purchinvlines-totalamount = wa_purchinvlines-taxamount + wa_purchinvlines-netamount. " done

        wa_purchinvlines-isreversed = waheader-ReverseDocument.

        SELECT SINGLE FROM i_suplrinvcitempurordrefapi01 AS a
        FIELDS a~DocumentCurrency
        WHERE  a~FiscalYear = @waheader-FiscalYear AND
        a~SupplierInvoice = @walines-SupplierInvoice
        INTO @DATA(lv_DocumentCurrency).

*         select single from I_SuplrInv as a
*         fields a~IN_CustomDutyAssessableValue
*         WHERE  a~FiscalYear = @waheader-FiscalYear AND
*         a~SupplierInvoice = @walines-SupplierInvoice
*         into @DATA(lv_AssessableValue) PRIVILEGED ACCESS.

        SELECT SINGLE SupplierInvoiceStatus
        FROM i_supplierinvoiceapi01 AS a
        WHERE a~SupplierInvoice = @waheader-SupplierInvoice
        INTO @DATA(lv_invoiceStatus).

        SELECT SINGLE FROM I_JournalEntry AS a
        FIELDS a~AbsoluteExchangeRate
        WHERE  a~OriginalReferenceDocument = @lv_orrefdoc
        INTO @DATA(lv_Exchangerate).

***********************************************************************************************  changed by Vinay on 07-06-2025
        wa_purchinvlines-documentcurrency = lv_DocumentCurrency. " done
        IF wa_purchinvlines-taxcode = 'K1'.
          wa_purchinvlines-assessablevalue = ( ( ( wa_purchinvlines-taxamount * 100 ) / 18 ) - wa_purchinvlines-netamount ). " done
        ELSE.
          wa_purchinvlines-assessablevalue = 0. " done
        ENDIF.

        wa_purchinvlines-exchangerate = lv_Exchangerate. " done
        wa_purchinvlines-taxablevalue =  wa_purchinvlines-netamount * wa_purchinvlines-exchangerate.
        IF lv_txtypedet = 'JIM'.
          wa_purchinvlines-taxablevalue = lv_taxbaseamt.
          CLEAR : lv_taxbaseamt, lv_txtypedet.
        ENDIF.

        IF lv_invoiceStatus = '5'.
          wa_purchinvlines-invoicestatus = 'Posted'.
        ELSEIF lv_invoicestatus = 'D'.
          wa_purchinvlines-invoicestatus = 'Entered and Held'.
        ELSE.
          wa_purchinvlines-invoicestatus = 'Parked'.
        ENDIF.
***************************************************************************************************

        IF lv_taxtrnas < '0'.
          wa_purchinvlines-totalamount *= -1.
          wa_purchinvlines-taxamount *= -1.
          wa_purchinvlines-cgst *= -1.
          wa_purchinvlines-sgst *= -1.
          wa_purchinvlines-igst *= -1.
          wa_purchinvlines-netamount *= -1.
          wa_purchinvlines-Mrnquantityinbaseunit *= -1.
        ENDIF.

*            IF walines-DebitCreditCode = 'H'.
*              wa_purchinvlines-netamount = wa_purchinvlines-netamount * -1. " done
*            ENDIF.

        MODIFY zpurchinvlines FROM @wa_purchinvlines.
        CLEAR wa_purchinvlines.
        CLEAR lv_acc.
        CLEAR lv_orrefdoc.
        CLEAR str1.
        CLEAR lv_accstr1.
        CLEAR lv_matdes.
        CLEAR wa_materialdes.
        CLEAR lv_po.
        CLEAR wa_main.
        CLEAR lv_prtxt.
        CLEAR lv_eway.
        CLEAR wa_vendor.
        CLEAR lv_vendor_date.
        CLEAR wa_rfq.
        CLEAR lv_mrn.
        CLEAR wa_mrn_date.
        CLEAR lv_grn_date.
        CLEAR lv_grn_qty.
        CLEAR lv_inbound.
        CLEAR lv_inspection.
        CLEAR lv_hsn.
        CLEAR lv_taxcodename.
        CLEAR lv_basic.
        CLEAR lv_result_igst.
        CLEAR lv_result_sgst.
        CLEAR lv_result_cgst.
        CLEAR lv_taxtrnas.
      ENDLOOP.
*          CLEAR wa_grn.
*        ENDLOOP.
      CLEAR waheader.
*      ENDIF.
*      CLEAR lv_reversed.
      CLEAR lv_sl.
    ENDLOOP.
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    DATA: lt_purchinvlines     TYPE STANDARD TABLE OF zpurchinvlines,
          wa_purchinvlines     TYPE zpurchinvlines,
          lt_purchinvprocessed TYPE STANDARD TABLE OF zpurchinvproc,
          wa_purchinvprocessed TYPE zpurchinvproc.
    DELETE FROM zpurchinvlines WHERE supplierinvoice IS NOT INITIAL.
    DELETE FROM zpurchinvproc WHERE supplierinvoice IS NOT INITIAL.

    DELETE FROM zpurchinvlines WHERE supplierinvoice = '5105600374'.

    SELECT FROM I_SupplierInvoiceAPI01 AS c
    LEFT JOIN i_supplier AS b ON b~supplier = c~InvoicingParty
    LEFT JOIN zmsme_table AS d ON c~InvoicingParty = d~vendorno
    FIELDS
        b~Supplier,
        b~SupplierAccountGroup,
        b~PostalCode,
        b~BPAddrCityName,
        b~BPAddrStreetName,
        b~TaxNumber3,
        b~BusinessPartnerPanNumber,
        b~BPSupplierName,
        b~SupplierFullName,
        b~region,
        c~ReverseDocument,
        c~ReverseDocumentFiscalYear,
        c~CompanyCode,
        c~PaymentTerms,
        c~CreatedByUser,
        c~CreationDate,
        c~InvoicingParty,
        c~InvoiceGrossAmount,
        c~DocumentCurrency,
        c~SupplierInvoiceIDByInvcgParty,
        c~FiscalYear,
        c~SupplierInvoice,
        c~SupplierInvoiceWthnFiscalYear,
        c~DocumentDate,
        c~PostingDate,
        d~vendortype
    WHERE
*    c~PostingDate >= @processfrom AND
    NOT EXISTS (
           SELECT supplierinvoice FROM zpurchinvproc
           WHERE c~supplierinvoice = zpurchinvproc~supplierinvoice AND
             c~CompanyCode = zpurchinvproc~companycode AND
             c~FiscalYear = zpurchinvproc~fiscalyearvalue )
        INTO TABLE @DATA(ltheader).


*    DELETE ADJACENT DUPLICATES FROM ltheader COMPARING Supplier.
    DATA: lv_orrefdoc TYPE string.

    LOOP AT ltheader INTO DATA(waheader).


      DATA: lv_sl TYPE string.
      lv_sl = waheader-SupplierInvoice.
      CONCATENATE lv_sl waheader-FiscalYear INTO lv_sl.

*      SELECT SINGLE FROM
*      i_operationalacctgdocitem AS g INNER JOIN
*      I_JournalEntry AS h ON g~AccountingDocument = h~AccountingDocument AND g~FiscalYear = h~FiscalYear
*      FIELDS
*      g~OriginalReferenceDocument
*      WHERE h~IsReversed = 'X' AND
*      g~OriginalReferenceDocument = @lv_sl
*      INTO @DATA(lv_reversed).

*      IF lv_reversed IS INITIAL.
*



      SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
       FIELDS
           a~PurchaseOrderItem,
           a~SupplierInvoiceItem,
           a~PurchaseOrder,
           a~FreightSupplier ,
           a~SupplierInvoice ,
           a~FiscalYear ,
           a~TaxJurisdiction AS SInvwithFYear,
           a~plant,
           a~PurchaseOrderItemMaterial AS material,
           a~QuantityInPurchaseOrderUnit,
           a~QtyInPurchaseOrderPriceUnit,
           a~PurchaseOrderQuantityUnit,
           a~ReferenceDocument ,
           a~ReferenceDocumentFiscalYear,
           a~PurchaseOrderPriceUnit,
           a~ReferenceDocumentItem,
           a~TaxCode,
           a~DebitCreditCode,
           a~SupplierInvoiceItemAmount,
           a~SuplrInvcDeliveryCostCndnType
           WHERE a~SupplierInvoice = @waheader-SupplierInvoice AND a~FiscalYear = @waheader-FiscalYear
           AND a~FiscalYear = @waheader-FiscalYear
           INTO TABLE @DATA(ltlines).
           SORT ltlines BY SupplierInvoiceItem PurchaseOrderItem DESCENDING.
*      DELETE ADJACENT DUPLICATES FROM ltlines COMPARING PurchaseOrder PurchaseOrderItem.

      LOOP AT ltlines INTO DATA(walines).
        """"" header data """""""""""""""""""""""""
*          SELECT FROM
*          I_PurchaseOrderHistoryApi01 AS a
*          FIELDS
*          a~PurchaseOrder,
*          a~PurchaseOrderItem,
*          a~PurchasingHistoryDocument,
*          a~PurchasingHistoryDocumentItem
*          WHERE a~PurchaseOrder = @walines-PurchaseOrder AND a~PurchaseOrderItem = @walines-PurchaseOrderItem
*          AND a~PurchasingHistoryCategory = 'E'
*          INTO TABLE @DATA(lt_grn).

*          LOOP AT lt_grn INTO DATA(wa_grn).
        lv_orrefdoc = waheader-SupplierInvoice.
        CONCATENATE lv_orrefdoc waheader-FiscalYear INTO lv_orrefdoc.

        SELECT SINGLE FROM
        i_operationalacctgdocitem AS a
        FIELDS
        a~AccountingDocument
        WHERE a~CompanyCode = @waheader-CompanyCode AND
        a~FiscalYear = @waheader-FiscalYear AND
        a~AccountingDocumentType  IN ( 'KG','KC','RE','UR' ) AND
        a~OriginalReferenceDocument = @lv_orrefdoc
        INTO @DATA(lv_acc).


        DATA str1 TYPE string.
        SELECT SINGLE
        a~AccountingDocument,
        a~businessplace,
        b~plant_name1,
        b~plant_name2,
        b~gstin_no
        FROM  i_operationalacctgdocitem AS a
        LEFT JOIN ztable_plant AS b ON a~BusinessPlace = b~plant_code
        WHERE a~CompanyCode = @waheader-CompanyCode AND
        a~FiscalYear = @waheader-FiscalYear AND
        a~AccountingDocument = @lv_acc
        INTO @DATA(lv_accstr1).

        SELECT SINGLE
       a~AccountingDocument,
       a~taxcode,
       b~taxcodename,
       a~ProfitCenter

       FROM  i_operationalacctgdocitem AS a
        LEFT JOIN i_taxcodetext WITH PRIVILEGED ACCESS AS b ON a~taxcode = b~TaxCode
       WHERE a~CompanyCode = @waheader-CompanyCode AND
       a~FiscalYear = @waheader-FiscalYear AND
       a~Accountingdocumentitemtype = 'W' OR
       a~Accountingdocumentitemtype = '' AND
       a~TransactionTypeDetermination = 'WRX' OR
       a~TransactionTypeDetermination = '' AND
       a~AccountingDocument = @lv_acc
       INTO @DATA(lv_accstr2).

        CONCATENATE lv_accstr1-Plant_Name1 lv_accstr1-Plant_Name2 INTO str1 SEPARATED BY space.

        SELECT SINGLE FROM
       i_operationalacctgdocitem AS a
       FIELDS
       a~AccountingDocument,
       a~AccountingDocumentType
       WHERE a~CompanyCode = @waheader-CompanyCode AND
       a~FiscalYear = @waheader-FiscalYear AND
       a~OriginalReferenceDocument = @lv_orrefdoc
       INTO @DATA(wa_main).

        wa_purchinvlines-fiscalyearvalue = waheader-FiscalYear.  " done
        wa_purchinvlines-supplierinvoice = waheader-SupplierInvoice. "done
        wa_purchinvlines-companycode = waheader-CompanyCode. " done
        wa_purchinvlines-fidocumentno = lv_acc. " done
        wa_purchinvlines-postingdate = waheader-PostingDate.
        wa_purchinvlines-plantname = str1. " done
        wa_purchinvlines-plantgst = lv_accstr1-gstin_no. " done
        wa_purchinvlines-taxcodename = lv_accstr2-TaxCodeName.
        wa_purchinvlines-profitcenter = lv_accstr2-ProfitCenter.
        wa_purchinvlines-documenttype = wa_main-AccountingDocumentType. " done
        wa_purchinvlines-vendorcode = waheader-invoicingparty. " done
        wa_purchinvlines-vendorname = waheader-BPSupplierName. " done
        wa_purchinvlines-suppliergstno = waheader-TaxNumber3. " done
        wa_purchinvlines-supplierpanno  = waheader-BusinessPartnerPanNumber. " done
        wa_purchinvlines-vendor_type = waheader-vendortype. " done



        """""" line data """""""""""""""""""""""""
        DATA : lv_matdes TYPE string.
        lv_matdes = walines-material.
        SHIFT lv_matdes LEFT DELETING LEADING '0'.

        SELECT SINGLE
        FROM zmaterial_table AS a
        FIELDS
        a~trade_name

        WHERE a~mat = @lv_matdes
        INTO @DATA(wa_materialdes).

        SELECT SINGLE
        FROM I_PurchaseOrderAPI01 AS a
        FIELDS
        a~PurchaseOrderType,
        a~PurchaseOrderDate,
        a~Purchasingorganization,
        a~PurchasingGroup,
        a~YY1_Quotation_No_PDH,
        a~YY1_Quotation_Date_PO_PDH
        WHERE a~PurchaseOrder = @walines-PurchaseOrder
        INTO @DATA(lv_po).

        SELECT SINGLE FROM
        I_ProductText AS a
        FIELDS
        a~ProductName
        WHERE a~Product = @walines-material AND a~Language = 'E'
        INTO @DATA(lv_prtxt).

        SELECT SINGLE FROM
        i_purchaseorderhistoryapi01 AS a
        LEFT JOIN I_BillingDocumentItem AS b ON a~PurchasingHistoryDocument = b~ReferenceSDDocument AND a~PurchasingHistoryDocumentItem = b~ReferenceSDDocumentItem
        LEFT JOIN ztable_irn AS c ON b~BillingDocument = c~billingdocno
        FIELDS
        c~ewaybillno,
        c~ewaydate
        WHERE a~PurchaseOrder = @walines-PurchaseOrder AND a~PurchaseOrderItem = @walines-PurchaseOrderItem
        INTO @DATA(lv_eway).

        SELECT SINGLE FROM
        I_DeliveryDocumentItem AS a
        LEFT JOIN I_DeliveryDocument AS b ON a~DeliveryDocument = b~DeliveryDocument
        FIELDS
        b~DeliveryDocumentBySupplier
        WHERE a~PurchaseOrder = @walines-PurchaseOrder AND
        a~PurchaseOrderItem = @walines-PurchaseOrderItem
        INTO @DATA(wa_vendor).

        SELECT SINGLE
        FROM i_purchaseorderhistoryapi01 AS a
        LEFT JOIN I_MaterialDocumentHeader_2 AS b ON b~MaterialDocument = a~PurchasingHistoryDocument
        FIELDS
        a~DocumentDate, a~PurchasingHistoryDocument, b~ReferenceDocument
        WHERE a~PurchaseOrder = @walines-PurchaseOrder AND a~PurchaseOrderItem = @walines-PurchaseOrderItem
        INTO @DATA(lv_vendor_date).

        SELECT SINGLE FROM
        i_purchaseorderitemtp_2 AS a
        LEFT JOIN I_Requestforquotation_Api01 AS b ON a~SupplierQuotation = b~RequestForQuotation
        FIELDS
        a~SupplierQuotation,
        b~RFQPublishingDate
        WHERE a~PurchaseOrder = @walines-PurchaseOrder
        INTO @DATA(wa_rfq).

        SELECT SINGLE FROM
        I_MaterialDocumentItem_2 AS a
        FIELDS
        a~QuantityInBaseUnit
        WHERE a~PurchaseOrder = @walines-PurchaseOrder AND a~PurchaseOrderItem = @walines-PurchaseOrderItem
        INTO @DATA(lv_mrn).

        SELECT SINGLE FROM
        i_purchaseorderhistoryapi01 AS a
        FIELDS
        a~PostingDate
        WHERE a~PurchaseOrder = @walines-PurchaseOrder AND a~PurchaseOrderItem = @walines-PurchaseOrderItem
        AND a~PurchasingHistoryCategory = 'Q'
        INTO @DATA(wa_mrn_date).

        SELECT SINGLE FROM
        i_purchaseorderhistoryapi01 AS a
        FIELDS
        a~PostingDate
        WHERE a~PurchasingHistoryDocument = @walines-ReferenceDocument AND
        a~PurchasingHistoryCategory = 'E'
        INTO @DATA(lv_grn_date).

        SELECT SINGLE FROM
        i_purchaseorderhistoryapi01 AS a
        FIELDS
        a~QuantityInDeliveryQtyUnit,
        a~QuantityInBaseUnit
        WHERE a~PurchasingHistoryDocument = @walines-ReferenceDocument AND
        a~PurchasingHistoryDocumentYear = @walines-ReferenceDocumentFiscalYear AND
        a~PurchasingHistoryDocumentItem = @walines-ReferenceDocumentItem
        INTO @DATA(lv_grn_qty).

        SELECT SINGLE FROM
        i_purchaseorderhistoryapi01 AS a
        LEFT JOIN i_inbounddelivery AS b ON a~DeliveryDocument = b~InboundDelivery
        FIELDS
        a~DeliveryDocument,
        b~DeliveryDate
        WHERE
        a~PurchaseOrder = @walines-PurchaseOrder
        AND a~PurchaseOrderItem = @walines-PurchaseOrderItem
        INTO @DATA(lv_inbound).

        SELECT SINGLE FROM
        i_inspectionlot AS a
        FIELDS
        a~InspectionLot,
        a~InspectionLotCreatedOn
        WHERE a~MaterialDocument = @walines-ReferenceDocument
        INTO @DATA(lv_inspection).

        SELECT SINGLE FROM
        i_operationalacctgdocitem AS a
        FIELDS
        a~IN_HSNOrSACCode
        WHERE a~CompanyCode = @waheader-CompanyCode AND
        a~FiscalYear = @waheader-FiscalYear AND
        a~OriginalReferenceDocument = @lv_orrefdoc
        INTO @DATA(lv_hsn).

        SELECT SINGLE FROM
        I_TaxCodeText AS a
        FIELDS
        a~TaxCodeName
        WHERE a~TaxCode = @walines-TaxCode
        INTO @DATA(lv_taxcodename).

        SELECT SINGLE FROM
        i_purorditmpricingelementapi01 AS a
        FIELDS
        a~ConditionRateValue
        WHERE a~PurchaseOrder = @walines-PurchaseOrder AND
        a~PurchaseOrderItem = @walines-PurchaseOrderItem AND a~ConditionType = 'PMP0'
        INTO @DATA(lv_basic).

        """"""""""""""""""""  gst  """""""""""""""""""""""""""""""""
        DATA: lv_string TYPE string.
        DATA: lv_result_cgst TYPE p DECIMALS 2.
        DATA: lv_result_sgst TYPE p DECIMALS 2.
        DATA: lv_result_igst TYPE p DECIMALS 2.
        DATA : lv_index TYPE i VALUE -1.
        DATA: lv_result_gst TYPE string.

        lv_string = lv_taxcodename.


        IF lv_string IS NOT INITIAL.
          FIND to_upper( 'CGST' ) IN lv_string MATCH OFFSET lv_index.

          IF lv_index <> -1.
            lv_index = lv_index + 5.

            DATA: j TYPE i.
            j = lv_index.
            WHILE j < strlen( lv_string ) AND ( lv_string+j(1) ) <> '%'.
              j = j + 1.
            ENDWHILE.
            IF j = strlen( lv_string ).
              lv_result_cgst = 0.
            ELSE.
              j = j - lv_index.
              lv_result_gst = lv_string+lv_index(j).
              REPLACE '%' IN lv_result_gst WITH ' '.
              CONDENSE lv_result_gst NO-GAPS.
              lv_result_cgst = lv_result_gst.
            ENDIF..
          ENDIF.

          CLEAR lv_index.
          CLEAR lv_result_gst.
          lv_index = -1.

          FIND to_upper( 'SGST' ) IN lv_string MATCH OFFSET lv_index.
          IF lv_index <> -1.
            lv_index = lv_index + 5.
            j = lv_index.
            WHILE j < strlen( lv_string ) AND ( lv_string+j(1) ) <> '%'.
              j = j + 1.
            ENDWHILE.
            IF j = strlen( lv_string ).
              lv_result_sgst = 0.
            ELSE.
              j = j - lv_index.
              lv_result_gst = lv_string+lv_index(j).

*          lv_result_gst = lv_string+lv_index(2).
              REPLACE '%' IN lv_result_gst WITH ' '.
              CONDENSE lv_result_gst NO-GAPS.
              lv_result_sgst = lv_result_gst.
            ENDIF.
          ENDIF.

          CLEAR lv_index.
          CLEAR lv_result_gst.
          lv_index = -1.

          FIND to_upper( 'IGST' ) IN lv_string MATCH OFFSET lv_index.
          IF lv_index <> -1.
            lv_index = lv_index + 5.
            j = lv_index.
            WHILE j < strlen( lv_string ) AND ( lv_string+j(1) ) <> '%'.
              j = j + 1.
            ENDWHILE.
            IF j = strlen( lv_string ).
              lv_result_igst = 0.
            ELSE.
              j = j - lv_index.
              lv_result_gst = lv_string+lv_index(j).
*          lv_result_gst = lv_string+lv_index(2).
              REPLACE '%' IN lv_result_gst WITH ' '.
              CONDENSE lv_result_gst NO-GAPS.
              lv_result_igst = lv_result_gst.
            ENDIF.
          ENDIF.

          CLEAR lv_index.
          CLEAR lv_result_gst.
          lv_index = -1.
        ENDIF.
        lv_index = -1.
        CLEAR lv_result_gst.
        CLEAR lv_string.

        SELECT SINGLE FROM
        i_operationalacctgdocitem AS a
        FIELDS
        a~TaxBaseAmountInTransCrcy
        WHERE a~CompanyCode = @waheader-CompanyCode AND
        a~FiscalYear = @waheader-FiscalYear AND
        a~AccountingDocumentType  IN ( 'KG','KC','RE' ) AND
        a~OriginalReferenceDocument = @lv_orrefdoc
        INTO @DATA(lv_taxtrnas).

        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        wa_purchinvlines-supplierinvoiceitem = walines-SupplierInvoiceItem. " done
        wa_purchinvlines-product = lv_matdes. " done
        wa_purchinvlines-productname = lv_prtxt. " done
        wa_purchinvlines-product_trade_name = wa_materialdes. " done
        wa_purchinvlines-purchaseorder = walines-PurchaseOrder. " done
        wa_purchinvlines-purchaseorderitem = walines-PurchaseOrderItem. " done
        wa_purchinvlines-purchaseordertype = lv_po-PurchaseOrderType. " done
        wa_purchinvlines-purchaseorderdate = lv_po-PurchaseOrderDate. " done
        wa_purchinvlines-Purchasingorganization = lv_po-Purchasingorganization. " done
        wa_purchinvlines-purchasinggroup = lv_po-PurchasingGroup. " done

*          IF wa_vendor IS INITIAL.
        SELECT SINGLE FROM I_JournalEntry AS a
       FIELDS a~DocumentReferenceID
       WHERE a~CompanyCode = @waheader-CompanyCode AND
       a~FiscalYear = @waheader-FiscalYear AND
       a~AccountingDocument = @lv_acc
       INTO @DATA(VendorInvNo).

        wa_purchinvlines-vendor_invoice_no = VendorInvNo . " done
*          ELSE.
*            wa_purchinvlines-vendor_invoice_no = wa_vendor . " done
*          ENDIF.

        wa_purchinvlines-vendor_invoice_date = waheader-DocumentDate. " done
        wa_purchinvlines-rfqno = wa_rfq-SupplierQuotation. " done
        wa_purchinvlines-rfqdate = wa_rfq-RFQPublishingDate. " done
*        wa_purchinvlines-baseunit = walines-BaseUnit.
        wa_purchinvlines-Mrnquantityinbaseunit = walines-QuantityInPurchaseOrderUnit. " done
        wa_purchinvlines-Mrnpostingdate = waheader-PostingDate. " done
*        wa_purchinvlines-vendor_invoice_date = walines-DocumentDate.
        wa_purchinvlines-ewaybillno = lv_eway-ewaybillno. " done
        wa_purchinvlines-ewaybilldate = lv_eway-ewaydate. " done
        wa_purchinvlines-supplierquotation = lv_po-YY1_Quotation_No_PDH. " done
        wa_purchinvlines-supplierquotationdate = lv_po-YY1_Quotation_Date_PO_PDH. " done
*            wa_purchinvlines-grnno = wa_grn-purchasinghistorydocument. " done
        wa_purchinvlines-grnno = walines-ReferenceDocument. " done
        wa_purchinvlines-grnline = walines-ReferenceDocumentItem. " done
        wa_purchinvlines-grndate = lv_grn_date. " done
        wa_purchinvlines-grnqty = lv_grn_qty-QuantityInBaseUnit. " done
        wa_purchinvlines-deliveryqty = lv_grn_qty-QuantityInDeliveryQtyUnit. " done
        wa_purchinvlines-inboundno = lv_inbound-DeliveryDocument. " done
        wa_purchinvlines-inbounddate = lv_inbound-DeliveryDate. " done
        wa_purchinvlines-inspectionlot = lv_inspection-InspectionLot. " done
        wa_purchinvlines-inspectiondate = lv_inspection-InspectionLotCreatedOn. " done
        wa_purchinvlines-hsncode = lv_hsn. " done
        wa_purchinvlines-taxcode = walines-TaxCode. " done
        wa_purchinvlines-taxcodename = lv_taxcodename. " done

****************************************************************************************  Net Amount Change by Vinay
        IF walines-DebitCreditCode = 'H'.
          wa_purchinvlines-netamount = ( walines-SupplierInvoiceItemAmount * -1 ). " done
        ELSE.
          wa_purchinvlines-netamount = walines-SupplierInvoiceItemAmount .
        ENDIF.

        IF walines-TaxCode+0(1) = 'H'.
          wa_purchinvlines-gstinputtype = 'Non Eligible Credit'.

        ELSE.
          wa_purchinvlines-gstinputtype = 'Eligible Credit'.
        ENDIF.

        SELECT SINGLE FROM I_AccountingDocumentJournal( p_language = 'E' ) AS a
       FIELDS a~AccountingDocumentTypeName
       WHERE a~Ledger = '0L'
         AND a~AccountingDocumentType = @wa_purchinvlines-documenttype
       INTO @DATA(lv_acc_type_name).

******************************************************************************************************************* Added by Vinay on 16-06-2025
        SELECT SINGLE FROM I_AccountingDocumentJournal( p_language = 'E' ) AS a
        left join I_FIXEDASSET as b on a~MasterFixedAsset = b~MasterFixedAsset
        FIELDS a~MasterFixedAsset AS AssetNumber,
               b~FIXEDASSETDESCRIPTION,
               b~AssetAdditionalDescription
        WHERE a~Ledger = '0L'
        AND a~PurchasingDocument = @wa_purchinvlines-purchaseorder
        AND a~PurchasingDocumentItem = @wa_purchinvlines-purchaseorderitem
        and a~ASSETACCTTRANSCLASSFCTN = '11'
        and a~TRANSACTIONTYPEDETERMINATION = 'ANL'
        INTO @DATA(Asset).

        Data(AssetDescription) = |{ Asset-FixedAssetDescription } { asset-AssetAdditionalDescription }|.

        wa_purchinvlines-assetno = asset-assetnumber.
        wa_purchinvlines-assetname = assetdescription.
*
        wa_purchinvlines-documenttypename = lv_acc_type_name .
        wa_purchinvlines-debitcreditcode = wa_purchinvlines-debitcreditcode.


        IF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZAF'.
          wa_purchinvlines-othercharge_fright = 'Oversease Charges'.
        ELSEIF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZCT'.
          wa_purchinvlines-othercharge_fright = 'Custom Duty'.
        ELSEIF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZFR'.
          wa_purchinvlines-othercharge_fright = 'Freight Charges'.
        ELSEIF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZGT'.
          wa_purchinvlines-othercharge_fright = 'Avg. Freight Charges'.
        ELSEIF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZIN'.
          wa_purchinvlines-othercharge_fright = 'Insurance Charges'.
        ELSEIF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZOT'.
          wa_purchinvlines-othercharge_fright = 'Other Charges'.
        ELSEIF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZPK'.
          wa_purchinvlines-othercharge_fright = 'Packing & Forwarding Charges'.
        ELSEIF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZSD'.
          wa_purchinvlines-othercharge_fright = 'Shipping Charges'.
        ELSEIF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZSF'.
          wa_purchinvlines-othercharge_fright = 'Sea Freight Charges'.
        ELSEIF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZSN'.
          wa_purchinvlines-othercharge_fright = 'Shipping NOC Charges'.
        ELSEIF walines-SuplrInvcDeliveryCostCndnType+0(3) = 'ZSV'.
          wa_purchinvlines-othercharge_fright = 'Sipping Det. Charges'.
        ENDIF.

*********************************************************************************************************************

        wa_purchinvlines-rateigst = lv_result_igst. " done
        wa_purchinvlines-ratecgst = lv_result_cgst. " done
        wa_purchinvlines-ratesgst = lv_result_sgst. " done
        wa_purchinvlines-igst = wa_purchinvlines-netamount * ( lv_result_igst / 100 ). " done
        wa_purchinvlines-sgst = wa_purchinvlines-netamount * ( lv_result_sgst / 100 ). " done
        wa_purchinvlines-cgst = wa_purchinvlines-netamount * ( lv_result_cgst / 100 ). " done

        SELECT SINGLE FROM I_OperationalAcctgDocItem
       FIELDS AmountInCompanyCodeCurrency, TaxBaseAmountInCoCodeCrcy, TransactionTypeDetermination
       WHERE AccountingDocument = @wa_purchinvlines-fidocumentno
       AND TaxItemGroup = @wa_purchinvlines-supplierinvoiceitem
       AND TransactionTypeDetermination = 'JIM' AND CompanyCode = @wa_purchinvlines-companycode
       AND FiscalYear = @wa_purchinvlines-fiscalyearvalue
       INTO ( @wa_purchinvlines-igst , @DATA(lv_taxbaseamt), @DATA(lv_txtypedet) ) PRIVILEGED ACCESS.


******************************************************************************************************Fields Added by Vinay

        wa_purchinvlines-basicrate = ( wa_purchinvlines-netamount / wa_purchinvlines-mrnquantityinbaseunit ). " done

        wa_purchinvlines-taxamount = wa_purchinvlines-igst + wa_purchinvlines-cgst + wa_purchinvlines-sgst. " done

        wa_purchinvlines-isreversed = waheader-ReverseDocument.
        IF walines-TaxCode+0(1) = 'J' OR walines-TaxCode+0(1) = 'M'.
          wa_purchinvlines-rcmigst = ( wa_purchinvlines-igst * -1 ).
          wa_purchinvlines-rcmcgst = ( wa_purchinvlines-cgst * -1 ).
          wa_purchinvlines-rcmsgst = ( wa_purchinvlines-sgst * -1 ).
        ELSE.
          wa_purchinvlines-rcmigst = 0.
          wa_purchinvlines-rcmcgst = 0.
          wa_purchinvlines-rcmsgst = 0.
        ENDIF.

        wa_purchinvlines-isreversed = waheader-ReverseDocument.

        SELECT SINGLE FROM i_suplrinvcitempurordrefapi01 AS a
        FIELDS a~DocumentCurrency
         WHERE  a~FiscalYear = @waheader-FiscalYear AND
         a~SupplierInvoice = @walines-SupplierInvoice
         INTO @DATA(lv_DocumentCurrency).


*         select single from I_SuplrInv as a
*         fields a~IN_CustomDutyAssessableValue
*         WHERE  a~FiscalYear = @waheader-FiscalYear AND
*         a~SupplierInvoice = @walines-SupplierInvoice
*         into @DATA(lv_AssessableValue) PRIVILEGED ACCESS.

        SELECT SINGLE SupplierInvoiceStatus
        FROM i_supplierinvoiceapi01 AS a
        WHERE a~SupplierInvoice = @waheader-SupplierInvoice
        INTO @DATA(lv_invoiceStatus).

        SELECT SINGLE FROM I_JournalEntry AS a
        FIELDS a~AbsoluteExchangeRate
        WHERE  a~OriginalReferenceDocument = @lv_orrefdoc
        INTO @DATA(lv_Exchangerate).

***********************************************************************************************  changed by Vinay on 07-06-2025
        wa_purchinvlines-documentcurrency = lv_DocumentCurrency. " done
        wa_purchinvlines-exchangerate = lv_Exchangerate. " done
        wa_purchinvlines-taxablevalue = wa_purchinvlines-netamount * wa_purchinvlines-exchangerate.
        IF lv_txtypedet IS NOT INITIAL.
          wa_purchinvlines-taxablevalue = lv_taxbaseamt.
          CLEAR: lv_taxbaseamt, lv_txtypedet.
        ENDIF.

        IF wa_purchinvlines-taxcode = 'K1'.
          wa_purchinvlines-assessablevalue = ( ( ( wa_purchinvlines-taxamount * 100 ) / 18 ) - wa_purchinvlines-netamount ). " done
        ELSE.
          wa_purchinvlines-assessablevalue = 0. " done
        ENDIF.

        IF lv_invoiceStatus = '5'.
          wa_purchinvlines-invoicestatus = 'Posted'.
        ELSE.
          wa_purchinvlines-invoicestatus = 'Parked'.
        ENDIF.
        wa_purchinvlines-totalamount = wa_purchinvlines-taxamount + wa_purchinvlines-taxablevalue. " done
***************************************************************************************************

        IF lv_taxtrnas < '0'.
          wa_purchinvlines-totalamount *= -1.
          wa_purchinvlines-taxamount *= -1.
          wa_purchinvlines-cgst *= -1.
          wa_purchinvlines-sgst *= -1.
          wa_purchinvlines-igst *= -1.
          wa_purchinvlines-netamount *= -1.
          wa_purchinvlines-Mrnquantityinbaseunit *= -1.
        ENDIF.

*            IF walines-DebitCreditCode = 'H'.
*              wa_purchinvlines-netamount = wa_purchinvlines-netamount * -1. " done
*            ENDIF.

        MODIFY zpurchinvlines FROM @wa_purchinvlines.
        CLEAR wa_purchinvlines.
        CLEAR lv_acc.
        CLEAR lv_orrefdoc.
        CLEAR str1.
        clear asset.
        CLEAR lv_accstr1.
        CLEAR lv_matdes.
        CLEAR wa_materialdes.
        CLEAR lv_po.
        CLEAR wa_main.
        CLEAR lv_prtxt.
        CLEAR lv_eway.
        CLEAR wa_vendor.
        CLEAR lv_vendor_date.
        CLEAR wa_rfq.
        CLEAR lv_mrn.
        CLEAR wa_mrn_date.
        CLEAR lv_grn_date.
        CLEAR lv_grn_qty.
        CLEAR lv_inbound.
        CLEAR lv_inspection.
        CLEAR lv_hsn.
        CLEAR lv_taxcodename.
        CLEAR lv_basic.
        CLEAR lv_result_igst.
        CLEAR lv_result_sgst.
        CLEAR lv_result_cgst.
        CLEAR lv_taxtrnas.
      ENDLOOP.
*          CLEAR wa_grn.
*        ENDLOOP.
      CLEAR waheader.
*      ENDIF.
*      CLEAR lv_reversed.
      CLEAR lv_sl.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
