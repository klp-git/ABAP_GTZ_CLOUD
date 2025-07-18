CLASS ztest_lut_inv_print DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTEST_LUT_INV_PRINT IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.


SELECT  from I_BillingDocument WITH PRIVILEGED ACCESS as a
inner join I_BillingDocumentItem WITH PRIVILEGED ACCESS as b on a~BillingDocument = b~BillingDocument
FIELDS a~BillingDocument,
b~BillingDocumentItem
WHERE a~BillingDocument = '0090000109' AND b~BillingQuantity <> 0
into TABLE @data(lt_head).

READ TABLE lt_head INTO data(wa_head) INDEX 1.

SELECT  from I_BillingDocument WITH PRIVILEGED ACCESS as a
inner join I_BillingDocumentItem WITH PRIVILEGED ACCESS as b on a~BillingDocument = b~BillingDocument
*inner join zi_dd_mat WITH PRIVILEGED ACCESS as c on c~Mat = '1400001782'
FIELDS a~BillingDocument,
b~BillingDocumentItem,b~BillingQuantity,b~Product,b~BillingDocumentItemText
*c~Mat
WHERE a~BillingDocument = '0090000109' AND b~BillingQuantity <> 0
into TABLE @data(lt_line).

SELECT  from I_BillingDocument WITH PRIVILEGED ACCESS as a
inner join I_BillingDocumentItem WITH PRIVILEGED ACCESS as b on a~BillingDocument = b~BillingDocument
*inner join zi_dd_mat WITH PRIVILEGED ACCESS as c on c~Mat = '1400001782'
INNER JOIN i_billingdocumentitemprcgelmnt WITH PRIVILEGED ACCESS as d on b~BillingDocument = d~BillingDocument
                                                                    and b~BillingDocumentItem = d~BillingDocumentItem
FIELDS a~BillingDocument,
b~BillingDocumentItem,b~BillingQuantity,b~Product,b~BillingDocumentItemText,
*c~Mat
d~ConditionType, d~ConditionAmount, d~ConditionBaseAmount, d~ConditionRateValue
WHERE a~BillingDocument = '0090000109' AND b~BillingQuantity <> 0
into TABLE @data(lt_price).

*i_billingdocumentitemprcgelmnt
DATA(lv_xml) = |<Form>| &&
               |<BillingDocument> { wa_head-BillingDocument } </BillingDocument> | &&
               |<BillingDocumentItem> { wa_head-BillingDocumentItem } </BillingDocumentItem> | &&
               |<Form>|.

 LOOP AT lt_line  INTO data(wa_line).
      DATA(lv_xml2) =
        |<tableDataRows>| &&
           |<BillingDocument>{ wa_line-BillingDocument  }</BillingDocument>| &&
           |<BillingDocumentItem> { wa_line-BillingDocumentItem } </BillingDocumentItem> | &&
           |<TradeName>{ wa_line-Product  }</TradeName>| &&
           |<Quantity>{ wa_line-BillingQuantity  }</Quantity>|.


LOOP AT lt_price INTO data(wa_price).
 DATA(lv_xml3) =
            |<PricingRows>| &&
           |<BillingDocument>{ wa_line-BillingDocument  }</BillingDocument>| &&
           |<BillingDocumentItem> { wa_line-BillingDocumentItem } </BillingDocumentItem> | &&
           |<TradeName>{ wa_line-Product  }</TradeName>| &&
           |<Quantity>{ wa_line-BillingQuantity  }</Quantity>|.

ENDLOOP.

*           |</tableDataRows>|.


ENDLOOP.

*    data : xsml TYPE string.
*DATA(lv_xml) = |<Form> | &&
*                     |<Inspection>| &&
*                     |<InspectionLot>{ wa_head-InspectionLot }</InspectionLot> | &&
*                     |<Material>{ wa_head-Material }</Material>| &&
*                     |<INSPECTIONSPECIFICATIONTEXT>{ wa_head-InspectionLotObjectText }</INSPECTIONSPECIFICATIONTEXT>| &&
*                     |<InspectionLotQuantity>{ wa_head-InspectionLotQuantity }</InspectionLotQuantity>| &&
*                     |<Batch>{ wa_head-Batch }</Batch>| &&
*                     |<ShelfLifeExpirationDate>{ lv_date_expiry }</ShelfLifeExpirationDate>| &&
*                     |<ManufactureDate>{ lv_date_manufacture }</ManufactureDate>| &&
*                     |<INSPLOTQTYTOFREE>{ wa_head-insplotqtytofree }</INSPLOTQTYTOFREE>| &&
*                     |</Inspection>|.
**                     &&                     |</Form>|.
* data : num type i VALUE 0.
*    LOOP AT lt_result INTO wa_line.
*        num = num + 1.
*      DATA(lv_xml2) =
*        |<tableDataRows>| &&
*           |<siNo> { num } </siNo>| &&
*           |<TestParameter>{ wa_line-inspectionspecificationtext  }</TestParameter>| &&
*           |<Specification>{ wa_line-inspectionlimit } </Specification>| &&
*           |<Results>{ wa_line-inspectionresultoriginalvalue }</Results>| &&
*           |<Deci_value_spec>{ wa_line-deci_value }</Deci_value_spec>| &&
*           |</tableDataRows>|
*           .
*     """" LV_XML-----------> Header
*     """""lv_xml2 line one by one
*
*     ""xsml---> line item(final)
*
*     """""""""" Final version XML : LV_XML
*      CONCATENATE xsml lv_xml2 INTO xsml .
*    ENDLOOP.
*
*     CONCATENATE lv_xml xsml INTO lv_xml.
*     CONCATENATE lv_xml   '</Form>' INTO lv_xml.
*REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.
*REPLACE ALL OCCURRENCES OF '<=' in lv_xml WITH 'let'.
*REPLACE ALL OCCURRENCES OF '>=' in lv_xml WITH 'get'.


out->write( lt_line ).
out->write( lt_price ).


    ENDMETHOD.
ENDCLASS.
