CLASS zcl_rfqprint DEFINITION
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
        IMPORTING rfq_num         TYPE string
                  line_item       TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zmm_rfq_print/zmm_rfq_print'."'z/zpo_v2'."
ENDCLASS.



CLASS ZCL_RFQPRINT IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .

    SELECT SINGLE
    a~requestforquotation,   """""""""""""rfq number use
    a~Productcode,   """""""""""material number
    a~Orderquantity,     """"""""""""" rfq quantity use
    a~Vendorcode,
    a~supplierquotationitem,
    b~ProductDescription, "" material name
    a~CreatedAt """""""""""""""""""" date use
    FROM zr_rfqmatrixcds WITH PRIVILEGED ACCESS AS a
    LEFT JOIN  i_productdescription WITH PRIVILEGED ACCESS AS b ON a~Productcode = b~Product
    WHERE a~Requestforquotation = @rfq_num and a~supplierquotationitem = @line_item
    INTO @DATA(header).

    SELECT single
      product,
      SafetyStockquantity
     FROM I_ProductPlantBasic WITH PRIVILEGED ACCESS
     WHERE Product = @header-productcode
     INTO @DATA(wa_safetystock).

     DATA : lv_date TYPE vdm_validitystart.
    lv_date = cl_abap_context_info=>get_system_date( ).

    SELECT single

       SUM( matlwrhsstkqtyinmatlbaseunit )
      FROM i_matlstkatkeydateinaltuom( p_keydate = @lv_date ) WITH PRIVILEGED ACCESS
      WHERE product = @header-productcode
      INTO @data(wa_stockdate).

* out->write( header ).

    """""""""""""""""""""""""""""""""""""""""'' header completed""""""""""""""""

    """""""""""""""""""""""""""""""last purchase Details"""""""""""""""""""""""""""""""""""
    SELECT

    a~SupplierQuotation,
    a~material,
    b~Supplier,
    b~PurchaseOrderItem,
    b~purchaseorder,
    b~PostingDate,
      b~QuantityInBaseUnit ,     """""""""""""""""""""""""""
      f~NetPriceAmount,  """""""""""""""""""""""""""""""""""""""""""
    f~PlannedDeliveryDurationInDays, """"""""""""""""""""""""""""""""""""""""
      g~CashDiscount1Days, """""""""""""""""""""""""""""""""""""""""""""""""""""
      g~PurchaseOrderDate,
      i~yy1_vendorspecialname_sos, """"""""""""""""""""""""""""""""""""""
      c~BusinessPartnerName1,
      f~orderquantity

    FROM I_SupplierQuotationItemTP WITH PRIVILEGED ACCESS AS a
    LEFT JOIN I_MaterialDocumentItem_2 WITH PRIVILEGED ACCESS AS b ON a~Material = b~Material AND b~GoodsMovementType = '101'
    LEFT JOIN i_supplier WITH PRIVILEGED ACCESS AS c ON b~Supplier = c~Supplier
    LEFT JOIN zi_dd_mat WITH PRIVILEGED ACCESS AS e ON b~Material = e~Mat
    LEFT JOIN I_PurchaseOrderItemAPI01 WITH PRIVILEGED ACCESS AS f ON b~PurchaseOrder = f~PurchaseOrder AND b~PurchaseOrderItem = f~PurchaseOrderItem
    LEFT JOIN I_PurchaseOrderAPI01 WITH PRIVILEGED ACCESS AS g ON f~PurchaseOrder = g~PurchaseOrder
    LEFT JOIN I_PaymentTermsText WITH PRIVILEGED ACCESS AS h ON g~PaymentTerms = h~PaymentTerms AND h~Language = 'E'
    LEFT JOIN i_purchasinginforecordapi01 WITH PRIVILEGED ACCESS AS i ON c~Supplier = i~Supplier AND b~Material = i~Material
    WHERE a~requestforquotation = @rfq_num and a~RequestForQuotationItem = @line_item
    INTO TABLE @DATA(last_pu_details).
    SORT last_pu_details BY PostingDate DESCENDING Material ASCENDING .

    DELETE ADJACENT DUPLICATES FROM last_pu_details COMPARING material.

*  out->write( last_pu_details ).

    """""""""""""""""""""""""""""""""""""""""""""""""'fraight""""""""""""""""""""""""""""""""""""""""'


*    out->write( fraight ).

    """"""""""""""""""""""""""""""""""""""""""other charges""""""""""""""""""""

*  out->write( othercharges ).

    """"""""""""""""""""""""""""""""""""""credit days""""""""""""""""""""""""""""""
    SELECT
    a~postingdate,  """""""""""""""""""""""grn date
 a~purchaseorder,
 a~GoodsMovementType,
 b~cashdiscount1days,
* c~PLANNEDDELIVERYDURATIONINDAYS,
 d~purchaseorderdate



   FROM I_MaterialDocumentItem_2 WITH PRIVILEGED ACCESS AS a
   LEFT JOIN i_purchaseordertp_2 WITH PRIVILEGED ACCESS AS b ON a~PurchaseOrder = b~PurchaseOrder
*  LEFT JOIN I_PURCHASEORDERITEMAPI01 WITH PRIVILEGED ACCESS as c on a~PurchaseOrder = c~PurchaseOrder
   LEFT JOIN  I_purchaseorderapi01 WITH PRIVILEGED ACCESS AS d ON a~PurchaseOrder = d~PurchaseOrder

   WHERE a~GoodsMovementType = '101' AND a~PurchaseOrderItem = '10'

   INTO TABLE @DATA(creditdays).
    SORT creditdays BY PostingDate DESCENDING  .

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    SELECT FROM I_RequestForQuotationitemTP AS a
    LEFT JOIN I_SupplierQuotationItemTP WITH PRIVILEGED ACCESS AS b ON a~RequestForQuotation = b~RequestForQuotation AND a~RequestForQuotationItem = b~RequestForQuotationItem
    LEFT JOIN I_SupplierQuotationTP WITH PRIVILEGED ACCESS AS c ON b~SupplierQuotation = c~SupplierQuotation
    LEFT JOIN I_Supplier WITH PRIVILEGED ACCESS AS d ON c~Supplier = d~Supplier
    LEFT JOIN I_ProductText WITH PRIVILEGED ACCESS AS e ON a~Material = e~Product
    LEFT JOIN I_PaymentTermsText WITH PRIVILEGED ACCESS AS f ON f~PaymentTerms = c~PaymentTerms AND f~Language = 'E'
    LEFT JOIN i_purchasinginforecordapi01 WITH PRIVILEGED ACCESS AS i ON c~Supplier = i~Supplier AND a~Material = i~Material
    LEFT JOIN zi_dd_mat WITH PRIVILEGED ACCESS AS g ON a~Material = g~Mat
    FIELDS
    a~requestforquotation,
    a~RequestForQuotationItem,a~Material,
    b~SupplierQuotation,
    b~SupplierQuotationItem,
    b~ScheduleLineOrderQuantity,
    c~CashDiscount1Days, "c~NetPaymentDays,
    c~PaymentTerms,
    b~NetPriceAmount, "b~GrossAmount,
    d~Supplier, d~BusinessPartnerName1, d~BusinessPartnerName2,
    e~ProductName,
    f~PaymentTermsDescription,
    i~yy1_vendorspecialname_sos,
    g~TradeName
    WHERE  a~requestforquotation = @rfq_num AND  a~RequestForQuotationItem = @line_item
    INTO TABLE @DATA(it_main).

    DELETE it_main WHERE netpriceamount EQ '0'.
    DELETE it_main WHERE netpriceamount EQ '0.1'.
    DELETE it_main WHERE netpriceamount EQ '0.01'.




    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    SHIFT header-Productcode LEFT DELETING LEADING '0'.


    DATA(lv_header) =
    |<form>| &&
    |<header>| &&
    |<productdesc>{ header-ProductDescription }</productdesc>| &&
    |<PRODUCTCODE>{ header-Productcode }</PRODUCTCODE>| &&
    |<REQUESTFORQUOTATION>{ header-Requestforquotation }</REQUESTFORQUOTATION>| &&
    |<LP_RfqDate>{ header-CreatedAt }</LP_RfqDate>| &&
    |<ORDERQUANTITY>{ header-Orderquantity }</ORDERQUANTITY>| &&
    |<LP_MinimumStockQuant>{ wa_safetystock-SafetyStockQuantity }</LP_MinimumStockQuant>| &&
    |<LP_StockDate>{ wa_stockdate }</LP_StockDate>| &&
    |</header>| &&
    |<last_po_details>|.

    SELECT FROM I_RequestForQuotationitemTP WITH PRIVILEGED ACCESS AS a
        LEFT JOIN I_SupplierQuotationItemTP WITH PRIVILEGED ACCESS AS b ON a~RequestForQuotation = b~RequestForQuotation
                   AND a~RequestForQuotationItem = b~RequestForQuotationItem
        LEFT JOIN I_MaterialDocumentItem_2 WITH PRIVILEGED ACCESS AS c ON b~Material = c~Material
        LEFT JOIN I_Supplier WITH PRIVILEGED ACCESS AS d ON c~Supplier = d~Supplier
        LEFT JOIN zi_dd_mat WITH PRIVILEGED ACCESS AS e ON b~Material = e~Mat
        LEFT JOIN I_PurchaseOrderItemAPI01 WITH PRIVILEGED ACCESS AS f ON c~PurchaseOrder = f~PurchaseOrder AND c~PurchaseOrderItem = f~PurchaseOrderItem
        LEFT JOIN I_PurchaseOrderAPI01 WITH PRIVILEGED ACCESS AS g ON f~PurchaseOrder = g~PurchaseOrder
        LEFT JOIN I_PaymentTermsText WITH PRIVILEGED ACCESS AS h ON g~PaymentTerms = h~PaymentTerms AND h~Language = 'E'
        LEFT JOIN i_purchasinginforecordapi01 WITH PRIVILEGED ACCESS AS i ON c~Supplier = i~Supplier AND c~Material = i~Material
*        left join I_ProductMRPArea as i on i~Product = b~Material
        FIELDS
        "a~RequestForQuotation, a~RequestForQuotationItem ,
        b~SupplierQuotation, b~SupplierQuotationItem,
        c~Material, c~PostingDate, c~QuantityInBaseUnit , c~Supplier , c~PurchaseOrder, d~BusinessPartnerName1, d~BusinessPartnerName2,
        e~TradeName, f~NetPriceAmount, f~PlannedDeliveryDurationInDays, f~PurchaseOrder AS PurchaseOrder1, f~PurchaseOrderItem,
         g~CashDiscount1Days, g~PurchaseOrderDate,i~yy1_vendorspecialname_sos,
          h~PaymentTermsDescription
*          i~ReorderThresholdQuantity
        WHERE  a~requestforquotation = @rfq_num  AND a~RequestForQuotationItem = @line_item AND c~GoodsMovementType = '101' "'6000000054'
        INTO TABLE @DATA(it_PO_QTY_DATE).
*    SORT it_po_qty_date BY PostingDate DESCENDING.
    SORT it_po_qty_date BY PostingDate DESCENDING Material ASCENDING .

    DELETE ADJACENT DUPLICATES FROM it_po_qty_date COMPARING material.

    LOOP AT last_pu_details INTO DATA(wa_pu_details).
      SELECT SINGLE
         SUM( a~conditionamount )
         FROM i_purordpricingelementtp_2 WITH PRIVILEGED ACCESS AS a
         WHERE a~PurchaseOrder = @wa_pu_details-PurchaseOrder AND a~PurchaseOrderItem = @wa_pu_details-PurchaseOrderItem
        AND a~ConditionType IN ( 'ZFR1','ZFR2','ZFR3' )
       INTO @DATA(fraight).

      SELECT SINGLE
        SUM( a~conditionamount )
        FROM i_purordpricingelementtp_2 WITH PRIVILEGED ACCESS AS a
        WHERE a~PurchaseOrder = @wa_pu_details-PurchaseOrder AND a~PurchaseOrderItem = @wa_pu_details-PurchaseOrderItem
       AND a~ConditionType IN ( 'ZOT1','ZOT2' )
      INTO @DATA(othercharges).

      DATA: lv_landed TYPE p DECIMALS 2.
      DATA: lv_avg_fr TYPE p DECIMALS 2.

      lv_landed = wa_pu_details-NetPriceAmount + fraight / wa_pu_details-orderquantity + othercharges / wa_pu_details-orderquantity + lv_avg_fr.

      SELECT SINGLE FROM
        i_purchasinginforecordapi01 AS a
        LEFT JOIN i_purginforecdorgplntdataapi01 AS b ON a~purchasinginforecord = b~purchasinginforecord
        FIELDS
        b~materialplanneddeliverydurn
         WHERE a~Supplier = @wa_pu_details-Supplier AND a~Material = @wa_pu_details-Material
        INTO @DATA(wa_diff_lead).

      READ TABLE it_po_qty_date INTO DATA(wa_po_qty_date) WITH KEY Material = wa_pu_details-material.



      DATA(lv_last) =
      |<last_item>| &&
      |<LP_businesspartnername1>{ wa_pu_details-BusinessPartnerName1 }</LP_businesspartnername1>| &&
      |<suppliernamestring>{ wa_pu_details-YY1_VendorSpecialName_SOS }</suppliernamestring>| &&
      |<quantityinbaseunit>{ wa_pu_details-QuantityInBaseUnit }</quantityinbaseunit>| &&
      |<LP_NetpriceAmount>{ wa_pu_details-NetPriceAmount }</LP_NetpriceAmount>| &&
      |<LP_Freight>{ fraight / wa_pu_details-orderquantity }</LP_Freight>| &&
      |<LP_AVG_Freight></LP_AVG_Freight>| &&  " blank
      |<LP_other_chrg>{ othercharges / wa_pu_details-orderquantity }</LP_other_chrg>| &&
      |<LP_LandedCost>{ lv_landed }</LP_LandedCost>| &&
      |<LP_CashDiscount1Days>{ wa_pu_details-CashDiscount1Days }</LP_CashDiscount1Days>| &&
      |<LP_PLANNEDDELIVERYDURATIONINDAYS>{ wa_diff_lead }</LP_PLANNEDDELIVERYDURATIONINDAYS>| &&
      |<LP_PURCHASEORDERDATE>{ wa_po_qty_date-PurchaseOrderDate }</LP_PURCHASEORDERDATE>| &&
      |<LASTGRNDATE>{ wa_po_qty_date-PostingDate }</LASTGRNDATE>| &&
      |</last_item>|.

      CONCATENATE lv_header lv_last INTO lv_header.
      CLEAR wa_pu_details.
      CLEAR lv_landed.
      CLEAR othercharges.
      CLEAR fraight.
      CLEAR lv_avg_fr.
      CLEAR wa_po_qty_date.

    ENDLOOP.





    DATA(lv_po_xml) =
    |</last_po_details>| &&
    |<quotation>|.

    CONCATENATE lv_header lv_po_xml INTO lv_header.


    LOOP AT it_main INTO DATA(wa_main).

      SELECT SUM( ConditionAmount )
      FROM I_SupplierQuotationPrcElmntTP WITH PRIVILEGED ACCESS
      WHERE ConditionType IN ('ZFR1', 'ZFR2', 'ZFR3') AND SupplierQuotation = @wa_main-SupplierQuotation AND SupplierQuotationItem = @wa_main-SupplierQuotationItem
      INTO @DATA(lt_qUO_freight).

      SELECT SUM( ConditionAmount )
      FROM I_SupplierQuotationPrcElmntTP WITH PRIVILEGED ACCESS
      WHERE ConditionType IN ('ZGT1', 'ZGT2') AND SupplierQuotation = @wa_main-SupplierQuotation AND SupplierQuotationItem = @wa_main-SupplierQuotationItem
      INTO @DATA(lt_QUO_avg_freight).


      SELECT SUM( ConditionAmount )
        FROM I_SupplierQuotationPrcElmntTP
        WITH PRIVILEGED ACCESS
        WHERE ConditionType IN ('ZGT3') AND SupplierQuotation = @wa_main-SupplierQuotation AND SupplierQuotationItem = @wa_main-SupplierQuotationItem
        INTO @DATA(lt_QUO_othrercharge).

      DATA: lv_landed_quo TYPE p DECIMALS 2.

      lv_landed_quo = wa_main-netpriceamount + lt_QUO_avg_freight / wa_main-ScheduleLineOrderQuantity + lt_qUO_freight / wa_main-ScheduleLineOrderQuantity + lt_QUO_othrercharge / wa_main-ScheduleLineOrderQuantity.
      "+ wa_main-actualfreight + wa_main-averagereight + wa_main-insurance.

      SELECT SINGLE FROM
      i_purchasinginforecordapi01 AS a
      LEFT JOIN i_purginforecdorgplntdataapi01 AS b ON a~purchasinginforecord = b~purchasinginforecord
      FIELDS
      b~materialplanneddeliverydurn
      WHERE a~Material = @wa_main-material AND a~Supplier = @wa_main-supplier
      INTO @DATA(wa_main_lead).


      DATA(lv_quotation) =
      |<quotationitem>| &&
      |<QUO_businesspartnername1>{ wa_main-businesspartnername1 }</QUO_businesspartnername1>| &&
      |<suppliernamestring1>{ wa_main-yy1_vendorspecialname_sos }</suppliernamestring1>| &&
      |<QUO_QuotationQty>{ wa_main-schedulelineorderquantity }</QUO_QuotationQty>| &&
      |<QUO_NetAmount>{ wa_main-netpriceamount }</QUO_NetAmount>| &&
      |<fr>{ lt_qUO_freight / wa_main-ScheduleLineOrderQuantity }</fr>| &&
      |<avg_fr>{ lt_QUO_avg_freight / wa_main-ScheduleLineOrderQuantity }</avg_fr>| &&
      |<other>{ lt_QUO_othrercharge / wa_main-ScheduleLineOrderQuantity }</other>| &&
      |<landed>{ lv_landed_quo }</landed>| &&
      |<credit>{ wa_main-cashdiscount1days }</credit>| &&
      |<packing></packing>| && " blank
      |<leadtime>{ wa_main_lead }</leadtime>| &&
      |<podate></podate>| &&   " blank
      |<grndate></grndate>| &&   " blank
      |</quotationitem>|.

      CONCATENATE lv_header lv_quotation INTO lv_header.
      CLEAR wa_main_lead.
      CLEAR lv_landed_quo.
      CLEAR lt_QUO_othrercharge.
      CLEAR lt_QUO_avg_freight.
      CLEAR lt_qUO_freight.
      CLEAR wa_main.

    ENDLOOP.

    DATA(lv_xml_last) =
    |</quotation>| &&
    |</form>|.

    CONCATENATE lv_header lv_xml_last INTO lv_header.


    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_header
        template = lc_template_name
      RECEIVING
        result   = result12 ).





  ENDMETHOD.
ENDCLASS.
