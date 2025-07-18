CLASS ztest_mmrpq_print DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTEST_MMRPQ_PRINT IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    """"""""""""""""""""Code For Stock as on Date """""""""""""""""""""""""""""""""""""""""""""""""

*
*    "FREIGHT Last Purchase Details
*    SELECT purchaseOrder, purchaseOrderItem, ConditionRateValue
*    FROM i_purorditmpricingelementapi01 WITH PRIVILEGED ACCESS
*    WHERE ConditionType IN ('ZFR1', 'ZFR2', 'ZFR3')
*    INTO TABLE @DATA(lt_last_freight).
*
*    " Fetch Average Freight Last Purchase Details Data for Condition Types ZGT1, ZGT2
*    SELECT purchaseOrder, purchaseOrderItem, ConditionBaseValue
*        FROM i_purorditmpricingelementapi01 WITH PRIVILEGED ACCESS
*        WHERE ConditionType IN ('ZGT1', 'ZGT2')
*        INTO TABLE @DATA(lt_last_avg_freight).
*
*    out->write( lt_last_avg_freight ).
******************************************For Line Item Table *****************************************
*
*    "FREIGHT
*
*    SELECT
*    a~SupplierQuotation,
*    a~SupplierQuotationItem,
*    a~ConditionRateValue,
*       b~ScheduleLineOrderQuantity
*    FROM I_SupplierQuotationPrcElmntTP WITH PRIVILEGED ACCESS  AS a
*    LEFT JOIN I_Supplierquotationitemtp WITH PRIVILEGED ACCESS AS b ON a~SupplierQuotation = b~SupplierQuotation
*    WHERE a~SupplierQuotation = '5700000238' AND  ConditionType = 'ZFR2'  """""IN ('ZFR1', 'ZFR2', 'ZFR3')
*    INTO TABLE @DATA(lt_qUO_freight).
*
*    out->write( lt_qUO_freight ).
*
*    """""""""" for other charge """""""""""""""
*    SELECT
*     a~SupplierQuotation,
*     a~SupplierQuotationItem,
*     a~ConditionRateValue,
*        b~ScheduleLineOrderQuantity
*     FROM I_SupplierQuotationPrcElmntTP WITH PRIVILEGED ACCESS  AS a
*     LEFT JOIN I_Supplierquotationitemtp WITH PRIVILEGED ACCESS AS b ON a~SupplierQuotation = b~SupplierQuotation
*     WHERE a~SupplierQuotation = '5700000238' AND  ConditionType = 'ZOT2'   """""IN ('ZFR1', 'ZFR2', 'ZFR3')
*     INTO TABLE @DATA(lt_othercharge).
*
*    out->write( lt_othercharge ).
*
*    SELECT FROM zr_rfqmatrixcds WITH PRIVILEGED ACCESS AS a
*
*    INNER JOIN I_RequestForQuotationItemTP WITH PRIVILEGED ACCESS AS b ON a~Requestforquotation = b~RequestForQuotation AND a~Productcode = b~Material
*    FIELDS a~requestforquotation, a~Productcode, a~Orderquantity, "a~CreatedAt,
*    b~RequestForQuotationItem
*    WHERE b~requestforquotation = '5700000238'   """"AND b~RequestForQuotationItem = @line_item
*    INTO TABLE @DATA(lt_othercharge1).
*    out->write( lt_othercharge1 ).


    SELECT
         a~SupplierQuotation,
          a~SupplierQuotationItem,
           a~ConditionRateValue,
           a~ConditionType
      FROM I_SupplierQuotationPrcElmntTP WITH PRIVILEGED ACCESS AS a

      WHERE a~SupplierQuotation = '6000000106'   AND  a~ConditionType = 'ZOT1' AND a~conditionType = 'ZOT2'
      INTO TABLE @DATA(lt_QUO_othrercharge).
 out->write( lt_QUO_othrercharge ).



  ENDMETHOD.
ENDCLASS.
