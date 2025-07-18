CLASS zcl_test_issue DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
      CLASS-DATA : var1 TYPE I_PROCESSORDERTP-ProcessOrder.
    CLASS-DATA : var2 TYPE I_MATERIALDOCUMENTITEM_2-MaterialDocument.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TEST_ISSUE IMPLEMENTATION.


 METHOD if_oo_adt_classrun~main.

  DATA: process_no_1 TYPE string.
    DATA: process_no TYPE string.
    Data : mat_no1 type string.
    Data : mat_no type string.


   process_no = '600062'.
   mat_no = '4900002723'.

    var1 = process_no.
    var1 =   |{ |{ var1 ALPHA = OUT }| ALPHA = IN }| .
    process_no_1 = process_no.
    process_no_1 = var1.

     var2 = mat_no.
    var2 =   |{ |{ var2 ALPHA = OUT }| ALPHA = IN }| .
    mat_no1 = mat_no.
    mat_no1 = var2.

    out->write(  mat_no1  ).
*     out->write(  process_no_1  ).


  SELECT SINGLE
     a~ProcessOrderText ,a~Batch, b~productionversiontext, a~orderplannedtotalqty ,a~productionunit
     FROM i_processordertp AS a
     LEFT JOIN i_productionversion AS b ON a~Product = b~Material AND a~ProductionVersion = b~ProductionVersion
    WHERE a~ProcessOrder = '000001000167'
     INTO @DATA(wa_header).

     Data : lv_combine type string,
            lv_new_qty type string.

     lv_new_qty = wa_header-OrderPlannedTotalQty.
     CONCATENATE lv_new_qty  wa_header-ProductionUnit into lv_combine .

    SELECT SINGLE
    a~DocumentDate, a~MaterialDocument
    FROM i_materialdocumentitem_2 AS a
    WHERE a~MaterialDocument = '4900002903'
    INTO @DATA(wa_issue).

    SELECT FROM i_materialdocumentitem_2 AS a
    LEFT JOIN i_productdescription AS b  ON a~Material = b~Product
    left join I_ProcessOrderComponentTP as c on a~Material = c~Material and a~Material is not initial and c~Material is not initial
    FIELDS b~ProductDescription,a~MaterialBaseUnit,a~IssgOrRcvgBatch,a~ShelfLifeExpirationDate,a~QuantityInBaseUnit,a~Material,
    c~RequiredQuantity
    WHERE a~MaterialDocument = '4900002903' AND a~IsAutomaticallyCreated = 'X' and c~ProcessOrder = '000001000167'
    INTO TABLE @DATA(item).

      DATA: lv_date TYPE sy-datum,
      lv_time TYPE sy-uzeit,
      lv_timestamp  TYPE timestamp.

      GET TIME STAMP FIELD lv_timestamp.

      CONVERT TIME STAMP lv_timestamp TIME ZONE 'IST'
    INTO DATE lv_date TIME lv_time.

      lv_date = sy-datum.
      lv_time = sy-uzeit.

    DATA : lv_xml TYPE string.
    lv_xml = |<Form>| &&
             |<Header>| &&
             |<Requisition></Requisition>| &&
             |<Production_no></Production_no>| &&
             |<Product>{ wa_header-ProcessOrderText }</Product>| &&
             |<Batch_No>{ wa_header-Batch }</Batch_No>| &&
             |<BOM_Code>{ wa_header-ProductionVersionText }</BOM_Code>| &&
             |<Batch_Qty>{ lv_combine }</Batch_Qty>| &&
             |<Issue_No>{ wa_issue-MaterialDocument }</Issue_No>| &&
             |<Issue_Date>{ wa_issue-DocumentDate }</Issue_Date>| &&
             |</Header>| &&
             |<Item>|.

    data : sno type i value 0.
    LOOP AT item INTO DATA(wa_item).
       sno = sno + 1.
      DATA(lv_item) = |<lineitem>| &&
              |<sno>{ sno }</sno>| &&
              |<Description>{ wa_item-ProductDescription }</Description>| &&
              |<UOM>{ wa_item-MaterialBaseUnit }</UOM>| &&
              |<Batch_No_item>{ wa_item-IssgOrRcvgBatch }</Batch_No_item>| &&
              |<Expiry_date>{ wa_item-ShelfLifeExpirationDate }</Expiry_date>| &&
              |<strength></strength>| &&
              |<Issue_qty>{ wa_item-QuantityInBaseUnit }</Issue_qty>| &&
              |<Required_Qty>{ wa_item-RequiredQuantity }</Required_Qty>| &&
              |</lineitem>|.
      CONCATENATE lv_xml lv_item INTO lv_xml.
    ENDLOOP.


    CONCATENATE lv_xml '</Item>' '</Form>' INTO lv_xml.


out->write( lv_xml ).
out->write( lv_date ).
out->write( lv_time ).

 ENDMETHOD.
ENDCLASS.
