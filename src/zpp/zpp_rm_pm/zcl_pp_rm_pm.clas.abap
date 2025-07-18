CLASS zcl_pp_rm_pm DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

    TYPES: BEGIN OF st_raw,
             material TYPE matnr,
             day      TYPE d,
             qty      TYPE string,
           END OF st_raw.

    TYPES: BEGIN OF st_raw2,
             material TYPE matnr,
             qty      TYPE string,
           END OF st_raw2.
    TYPES: BEGIN OF st_test,
             material TYPE matnr,
           END OF st_test.
    TYPES: BEGIN OF st_test2,
             fg_material  TYPE matnr,
             raw_material TYPE matnr,
             uom          TYPE string,
             quantity     TYPE string,
             times        TYPE i,
           END OF st_test2.


*    CLASS-DATA : lt_raw TYPE HASHED TABLE OF st_raw WITH UNIQUE KEY material,day.
    CLASS-DATA : lt_raw TYPE TABLE OF st_raw.
    CLASS-DATA : lt_raw3 TYPE TABLE OF st_raw2.
    CLASS-DATA : wa_raw4 LIKE LINE OF lt_raw3.
    CLASS-DATA : wa_raw LIKE LINE OF lt_raw.
    CLASS-DATA : lt_test TYPE TABLE OF st_test.
    CLASS-DATA : wa_test LIKE LINE OF lt_test.
    CLASS-DATA : lt_test2 TYPE TABLE OF st_test2.
    CLASS-DATA : wa_test2 LIKE LINE OF lt_test2.

    CLASS-METHODS : datefield IMPORTING
                                        datef         TYPE datn
                              RETURNING VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_pp_rm_pm IMPLEMENTATION.


  METHOD datefield.
    DATA : datef2 TYPE datn.
    datef2 = datef.
    result = datef2+6(2) && '/' && datef2+4(2) && '/' && datef2(4).
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    IF io_request->is_data_requested(  ).
      DATA: lt_response    TYPE TABLE OF zdd_rm_pm,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.
      DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                  ELSE lv_top ).
*      DATA(lt_clause)        = io_request->get_filter( )->get_as_ranges( ).
      DATA(lt_parameter)     = io_request->get_parameters( ).
      DATA(lt_fields)        = io_request->get_requested_elements( ).
      DATA(lt_sort)          = io_request->get_sort_elements( ).
      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
          DATA(lv_catch) = 1.
      ENDTRY.

      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'ITEM_CODE'.
          DATA(lt_itemcode) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'PLANT'.
          DATA(lt_plant) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.

      IF lt_itemcode IS NOT INITIAL.
        LOOP AT lt_itemcode INTO DATA(wa_itemcode).

          DATA : var1 TYPE c LENGTH 18.

          IF wa_itemcode-low IS NOT INITIAL.
            var1 = wa_itemcode-low.
            wa_itemcode-low = |{ var1 ALPHA = IN }|.
          ENDIF.

          IF wa_itemcode-high IS NOT INITIAL.
            CLEAR var1.
            var1 = wa_itemcode-high.
            wa_itemcode-high = |{ var1 ALPHA = IN }|.
          ENDIF.
          MODIFY lt_itemcode FROM wa_itemcode.
        ENDLOOP.
      ENDIF.

      SELECT FROM I_product AS a
      LEFT JOIN i_producttext AS b ON a~Product = b~Product AND b~Language = 'E'
      FIELDS
      a~Product,
      b~ProductName,
      a~BaseUnit
      WHERE a~ProductType IN ( 'ZRAW','ZRMC','ZPKG' )
      AND a~Product IN @lt_itemcode
*      AND a~Plant IN @lt_item_name
*    AND a~Product = '000000001400000000'
      INTO TABLE @DATA(lt).

      SELECT FROM
      i_product AS a LEFT JOIN
      I_ProductSupplyPlanning AS b ON a~Product = b~Product
      FIELDS
      SUM( b~ReorderThresholdQuantity ) AS ReorderThresholdQuantity,
      SUM( b~MaximumStockQuantity ) AS MaximumStockQuantity,
      SUM( b~safetystockquantity ) AS safetystockquantity,
      a~Product
      WHERE
      a~Product IN @lt_itemcode
      AND a~ProductType IN ( 'ZRAW','ZRMC','ZPKG' )
      GROUP BY a~Product
      INTO TABLE @DATA(lv_prdsup).

      SELECT FROM i_product AS a
     LEFT JOIN i_stockquantitycurrentvalue_2( p_displaycurrency = 'INR' ) AS b
       ON a~Product = b~Product
     FIELDS
       SUM( b~MatlWrhsStkQtyInMatlBaseUnit ) AS MatlWrhsStkQtyInMatlBaseUnit,
       a~Product
     WHERE
       b~ValuationAreaType = '1'
       AND b~inventorystocktype NOT IN ( 'S','03' )
       AND a~ProductType IN ( 'ZRAW','ZRMC','ZPKG' )
       AND a~Product IN @lt_itemcode
     GROUP BY a~Product
     INTO TABLE @DATA(lv_sob).

      SELECT FROM i_product AS a
  LEFT JOIN i_stockquantitycurrentvalue_2( p_displaycurrency = 'INR' ) AS b
    ON a~Product = b~Product
  FIELDS
    SUM( b~MatlWrhsStkQtyInMatlBaseUnit ) AS MatlWrhsStkQtyInMatlBaseUnit,
    a~Product
  WHERE
    b~ValuationAreaType = '1'
    AND b~inventorystocktype NOT IN ( 'S','03' )
    AND a~ProductType IN ( 'ZRAW','ZRMC','ZPKG' )
    AND a~Product IN @lt_itemcode
    AND (
          ( b~Plant = 'GM30' AND b~StorageLocation IN (
              '0002', '0003', '0004', '0006', '0007', '0008', '0009', '0010',
              '0011', '0012', '0013', '0014', '0015', '0016', '0017', '0018', '0019', '0005' )
          )
          OR
          ( b~Plant = 'GM01' AND b~StorageLocation IN ( '0001', '0002', '0003','0004' ) )
        )
  GROUP BY a~Product
  INTO TABLE @DATA(lv_csq).

      DATA : curr_date TYPE d.
      curr_date = cl_abap_context_info=>get_system_date( ).
      DATA(lv_fisc_start_date) = '20250401'.

      IF curr_date - lv_fisc_start_date = 10000.
        lv_fisc_start_date = curr_date.
      ENDIF.


      SELECT
          b~material,
          b~GoodsMovementType,
          SUM( b~QuantityInBaseUnit ) AS QuantityInBaseUnit
          FROM i_product AS a
          INNER JOIN i_materialdocumentitem_2 AS b
            ON a~Product = b~Material
          WHERE
            a~ProductType IN ('ZRAW','ZRMC','ZPKG') AND
            a~Product IN @lt_itemcode AND
            b~GoodsMovementType IN ('261','262') AND
            b~DocumentDate BETWEEN @lv_fisc_start_date AND @curr_date
          GROUP BY b~material,b~GoodsMovementType
          INTO TABLE @DATA(lv_avg_move).

      """"""""""""""""""""""""""""""""""""""""

      DATA: lv_date1       TYPE d,
            lv_date2       TYPE d,
            lv_months      TYPE i,
            lv_years_diff  TYPE i,
            lv_months_diff TYPE i.

      " Extract year and month parts from the dates
      DATA: lv_year1  TYPE i,
            lv_month1 TYPE i,
            lv_year2  TYPE i,
            lv_month2 TYPE i.

      lv_date1 = lv_fisc_start_date.
      lv_date2 = curr_date.

      lv_year1  = lv_date1+0(4).
      lv_month1 = lv_date1+4(2).

      lv_year2  = lv_date2+0(4).
      lv_month2 = lv_date2+4(2).

      " Calculate year and month difference
      lv_years_diff  = lv_year2 - lv_year1.
      lv_months_diff = lv_month2 - lv_month1.

      lv_months = ( lv_years_diff * 12 ) + lv_months_diff.




      """"""""""""""""""" fg material Bomb Explode day level """"""""""""""""

      SELECT FROM I_product AS a
     LEFT JOIN i_producttext AS b ON a~Product = b~Product AND b~Language = 'E'
     FIELDS
     a~Product,
     b~ProductName
     WHERE a~ProductType = 'ZFGC'
*     AND a~Product IN @lt_itemcode
*     AND b~ProductName IN @lt_item_name
*    AND a~Product = '000000001400000000'
     INTO TABLE @DATA(lt_fg).

      DATA: lv_sydate TYPE datum.
      lv_sydate = cl_abap_context_info=>get_system_date( ).
      lv_sydate = lv_sydate + 1.

      SELECT FROM i_product AS a
      INNER JOIN i_salesdocumentitem AS b
        ON a~Product = b~Product
      INNER JOIN i_salesdocumentscheduleline AS c
        ON b~SalesDocument = c~SalesDocument
        AND b~SalesDocumentItem = c~SalesDocumentItem
      FIELDS
        a~Product,
        c~deliverydate AS ConfirmedDeliveryDate,
        SUM( c~openconfddelivqtyinbaseunit ) AS confirmedrqmtqtyinbaseunit
      WHERE a~ProductType = 'ZFGC'
*        AND a~Product IN @lt_itemcode
        AND c~confirmeddeliverydate >= @lv_sydate
        AND c~confirmeddeliverydate < @( lv_sydate + 30 )
        AND b~SDProcessStatus <> 'C'
        AND b~SDDocumentRejectionStatus = 'A'
        AND b~SDDocumentCategory = 'C'
      GROUP BY
        a~Product,
        c~deliverydate
      INTO TABLE @DATA(lv_sum).

      SELECT FROM i_product AS a
      INNER JOIN i_salesdocumentitem AS b
        ON a~Product = b~Product
      INNER JOIN i_salesdocumentscheduleline AS c
        ON b~SalesDocument = c~SalesDocument
        AND b~SalesDocumentItem = c~SalesDocumentItem
      FIELDS
        a~Product,
        SUM( c~confdorderqtybymatlavailcheck ) AS confdorderqtybymatlavailcheck
      WHERE a~ProductType = 'ZFGC'
*        AND a~Product IN @lt_itemcode
        AND c~confirmeddeliverydate < @lv_sydate
        AND b~SDProcessStatus <> 'C'
        AND b~SDDocumentRejectionStatus = 'A'
        AND b~SDDocumentCategory = 'C'
      GROUP BY
        a~Product
      INTO TABLE @DATA(lv_pwoq).

      SELECT FROM i_product AS a
      INNER JOIN i_salesdocumentitem AS b
        ON a~Product = b~Product
      INNER JOIN i_deliverydocumentitem AS c
        ON b~SalesDocument = c~ReferenceSDDocument
        AND b~SalesDocumentItem = c~ReferenceSDDocumentItem
      FIELDS
        a~Product,
        SUM( c~actualdeliveryquantity ) AS confdorderqtybymatlavailcheck
      WHERE a~ProductType = 'ZFGC'
*        AND a~Product IN @lt_itemcode
        AND b~SDProcessStatus <> 'C'
        AND b~SDDocumentRejectionStatus = 'A'
        AND b~SDDocumentCategory = 'C'
        AND c~GoodsMovementStatus = 'C'
      GROUP BY
        a~Product
      INTO TABLE @DATA(lv_pwoq2).

      SELECT FROM
      i_billofmaterialtp_2 AS a
      FIELDS
      a~BillOfMaterial,
      a~BillOfMaterialCategory,
      a~Plant,
      a~Material
      WHERE a~Material IS NOT INITIAL
      INTO TABLE @DATA(lt_bill).

      DATA : start_date TYPE d.
      DATA : j TYPE i.


      LOOP AT lt_fg INTO DATA(wa_fg).
        start_date = lv_sydate.
        j = 0.

        """"""""""""""""""""""""" check which fg material considered """""""""""""""""""""""""
        DATA : lv_check_pwoq TYPE string.
        DATA : lv_check_total TYPE string.

        READ TABLE lv_pwoq INTO DATA(wa_pwoq) WITH KEY Product = wa_fg-Product.
        IF wa_pwoq-confdorderqtybymatlavailcheck IS NOT INITIAL.
          lv_check_pwoq = wa_pwoq-confdorderqtybymatlavailcheck.
        ENDIF.

        READ TABLE lv_pwoq2 INTO DATA(wa_pwoq2) WITH KEY Product = wa_fg-Product.
        IF wa_pwoq2-confdorderqtybymatlavailcheck IS NOT INITIAL.
          lv_check_pwoq = lv_check_pwoq - wa_pwoq2-confdorderqtybymatlavailcheck.
        ENDIF.

        DO 30 TIMES.
          READ TABLE lv_sum INTO DATA(wa_check_sum) WITH KEY ConfirmedDeliveryDate = lv_sydate Product = wa_fg-Product.
          lv_check_total += wa_check_sum-confirmedrqmtqtyinbaseunit.
          CLEAR wa_check_sum.
        ENDDO.

        """""""""""""""""""""""""""""""""""""""""""""""""""""

        IF NOT ( ( lv_check_pwoq IS INITIAL OR lv_check_pwoq = 0 ) AND lv_check_total = 0 ).

          DO 1 TIMES.

            READ TABLE lt_bill INTO DATA(wa_bill) WITH KEY Material = wa_fg-Product.
            READ TABLE lv_sum INTO DATA(wa_sum) WITH KEY ConfirmedDeliveryDate = ( start_date + j ) Product = wa_fg-Product.

            IF wa_sum-confirmedrqmtqtyinbaseunit <> '0'.

              READ ENTITIES OF i_billofmaterialtp_2
              ENTITY billofmaterial
              EXECUTE explodebom
              FROM VALUE #(
              (
              billofmaterial = wa_bill-BillOfMaterial
              plant = wa_bill-Plant
              material = wa_fg-Product
              billofmaterialcategory = wa_bill-BillOfMaterialCategory

              %param-bomexplosionapplication = 'PI01'
              %param-requiredquantity = wa_sum-confirmedrqmtqtyinbaseunit
              %param-explodebomlevelvalue = 0
              %param-bomexplosionismultilevel = 'X'
              )
              )
              RESULT DATA(lt_result)
              FAILED DATA(ls_failed)
              REPORTED DATA(ls_reported).

              LOOP AT lt_result INTO DATA(wa_result). "WHERE %param-billofmaterialcomponent = '000000001100000101'.
                READ TABLE lt_raw INTO DATA(wa_raw2) WITH KEY material = wa_result-%param-billofmaterialcomponent day = ( start_date + j ).

                IF sy-subrc EQ 0.
                  wa_raw-material = wa_result-%param-billofmaterialcomponent.
                  wa_raw-day = ( start_date + j ).
*                  wa_raw-qty = wa_raw2-qty + wa_result-%param-componentquantityincompuom.
                  READ TABLE lt INTO DATA(wa_uom) WITH KEY Product = wa_raw-material.
                  wa_test2-quantity = wa_result-%param-componentquantityincompuom.
                  wa_test2-uom = wa_result-%param-billofmaterialitemunit.

                  CASE wa_uom-BaseUnit.

                    WHEN 'G'.
                      CASE wa_result-%param-billofmaterialitemunit.
                        WHEN 'KG'.
                          wa_raw-qty = |{ ( wa_raw2-qty + ( wa_result-%param-componentquantityincompuom * 1000 ) ) DECIMALS = 3 }|.
                        WHEN 'G'.
                          wa_raw-qty = wa_raw2-qty + wa_result-%param-componentquantityincompuom.
                      ENDCASE.
                    WHEN 'KG'.
                      CASE wa_result-%param-billofmaterialitemunit.
                        WHEN 'G'.
                          wa_raw-qty = |{ ( wa_raw2-qty + ( wa_result-%param-componentquantityincompuom / 1000 ) ) DECIMALS = 3 }|.
                        WHEN 'KG'.
                          wa_raw-qty = wa_raw2-qty + wa_result-%param-componentquantityincompuom.
                      ENDCASE.
                    WHEN 'ML'.
                      CASE wa_result-%param-billofmaterialitemunit.
                        WHEN 'L'.
                          wa_raw-qty = |{ ( wa_raw2-qty + ( wa_result-%param-componentquantityincompuom * 1000 ) ) DECIMALS = 3 }|.
                        WHEN 'ML'.
                          wa_raw-qty = wa_raw2-qty + wa_result-%param-componentquantityincompuom.
                      ENDCASE.
                    WHEN 'L'.
                      CASE wa_result-%param-billofmaterialitemunit.
                        WHEN 'ML'.
                          wa_raw-qty = |{ ( wa_raw2-qty + ( wa_result-%param-componentquantityincompuom / 1000 ) ) DECIMALS = 3 }|.
                        WHEN 'L'.
                          wa_raw-qty = wa_raw2-qty + wa_result-%param-componentquantityincompuom.
                      ENDCASE.

                    WHEN OTHERS.
                      wa_raw-qty = wa_raw2-qty + wa_result-%param-componentquantityincompuom.

                  ENDCASE.

*                  IF wa_result-%param-billofmaterialitemunit = 'G'.
*                    wa_raw-qty = |{ ( wa_raw2-qty + wa_result-%param-componentquantityincompuom / 1000 ) DECIMALS = 3 }|.
*                  ELSEIF wa_result-%param-billofmaterialitemunit = 'ML'.
*                    wa_raw-qty = |{ ( wa_raw2-qty + wa_result-%param-componentquantityincompuom / 1000 ) DECIMALS = 3 }|.
*                  ELSE.
*                    wa_raw-qty = wa_raw2-qty + wa_result-%param-componentquantityincompuom.
*                  ENDIF.

*                  MODIFY TABLE lt_raw FROM wa_raw.
                  LOOP AT lt_raw INTO DATA(wa_up2) WHERE material = wa_raw-material AND day = wa_raw-day.
                    wa_up2-material = wa_raw-material.
                    wa_up2-day = wa_raw-day.
                    wa_up2-qty = wa_raw4-qty.
                    MODIFY lt_raw FROM wa_up2.
                    CLEAR wa_up2.
                  ENDLOOP.
                ELSE.
                  wa_raw-material = wa_result-%param-billofmaterialcomponent.
                  wa_raw-day = ( start_date + j ).
                  CLEAR wa_uom.
                  READ TABLE lt INTO wa_uom WITH KEY Product = wa_raw-material.
                  wa_test2-quantity = wa_result-%param-componentquantityincompuom.
                  wa_test2-uom = wa_result-%param-billofmaterialitemunit.

                  CASE wa_uom-BaseUnit.

                    WHEN 'G'.
                      CASE wa_result-%param-billofmaterialitemunit.
                        WHEN 'KG'.
                          wa_raw-qty = |{ wa_result-%param-componentquantityincompuom * 1000  DECIMALS = 3 }|.
                        WHEN 'G'.
                          wa_raw-qty =  wa_result-%param-componentquantityincompuom.
                      ENDCASE.
                    WHEN 'KG'.
                      CASE wa_result-%param-billofmaterialitemunit.
                        WHEN 'G'.
                          wa_raw-qty = |{  wa_result-%param-componentquantityincompuom / 1000 DECIMALS = 3 }|.
                        WHEN 'KG'.
                          wa_raw-qty = wa_result-%param-componentquantityincompuom.
                      ENDCASE.
                    WHEN 'ML'.
                      CASE wa_result-%param-billofmaterialitemunit.
                        WHEN 'L'.
                          wa_raw-qty = |{ wa_result-%param-componentquantityincompuom * 1000  DECIMALS = 3 }|.
                        WHEN 'ML'.
                          wa_raw-qty = wa_result-%param-componentquantityincompuom.
                      ENDCASE.
                    WHEN 'L'.
                      CASE wa_result-%param-billofmaterialitemunit.
                        WHEN 'ML'.
                          wa_raw-qty = |{ wa_result-%param-componentquantityincompuom / 1000 DECIMALS = 3 }|.
                        WHEN 'L'.
                          wa_raw-qty = wa_result-%param-componentquantityincompuom.
                      ENDCASE.

                    WHEN OTHERS.
                      wa_raw-qty = wa_result-%param-componentquantityincompuom.

                  ENDCASE.
                  wa_test2-quantity = wa_result-%param-componentquantityincompuom.
                  wa_test2-uom = wa_result-%param-billofmaterialitemunit.
                  INSERT wa_raw INTO TABLE lt_raw.
                ENDIF.

                IF j = 0.
                  wa_test2-fg_material = wa_fg-Product.
                  wa_test2-raw_material = wa_result-%param-billofmaterialcomponent.

*                  READ TABLE lt_test2 INTO DATA(wa_temp_test2) WITH KEY fg_material = wa_test2-fg_material raw_material = wa_test2-raw_material uom = wa_result-%param-billofmaterialitemunit.
*                  IF sy-subrc EQ 0.
*                    wa_test2-times = wa_temp_test2-times + 1.
*                  ELSE.
*                    wa_test2-times = 1.
*                  ENDIF.
                  APPEND wa_test2 TO lt_test2.
                ENDIF.
                CLEAR wa_test2.

                CLEAR wa_raw.
                CLEAR wa_raw2.
                CLEAR wa_result.
              ENDLOOP.

              CLEAR lt_result.

            ENDIF.

            CLEAR wa_sum.
            CLEAR wa_bill.
            j = j + 1.
          ENDDO.

          """""""""""" changes by apratim on 10.07.2025 """""""""""""""""""""""""""
          CLEAR lt_result.
          CLEAR ls_failed.
          CLEAR ls_reported.
          CLEAR wa_bill.

          READ TABLE lt_bill INTO wa_bill WITH KEY Material = wa_fg-Product.

          READ ENTITIES OF i_billofmaterialtp_2
              ENTITY billofmaterial
              EXECUTE explodebom
              FROM VALUE #(
              (
              billofmaterial = wa_bill-BillOfMaterial
              plant = wa_bill-Plant
              material = wa_fg-Product
              billofmaterialcategory = wa_bill-BillOfMaterialCategory

              %param-bomexplosionapplication = 'PI01'
              %param-requiredquantity = lv_check_pwoq
              %param-explodebomlevelvalue = 0
              %param-bomexplosionismultilevel = 'X'
              )
              )
              RESULT lt_result
              FAILED ls_failed
              REPORTED ls_reported.

          CLEAR wa_result.

          LOOP AT lt_result INTO wa_result. "WHERE %param-billofmaterialcomponent = '000000001100000101'.
            wa_test-material = wa_fg-Product.
            APPEND wa_test TO lt_test.
            CLEAR wa_raw4.
            READ TABLE lt_raw3 INTO DATA(wa_temp_raw) WITH KEY material = wa_result-%param-billofmaterialcomponent.
            IF sy-subrc EQ 0.
              wa_raw4-material = wa_result-%param-billofmaterialcomponent.
*              wa_raw4-qty = wa_temp_raw-qty + wa_result-%param-componentquantityincompuom.
              CLEAR wa_uom.
              READ TABLE lt INTO wa_uom WITH KEY Product = wa_raw4-material.

              CASE wa_uom-BaseUnit.

                WHEN 'G'.
                  CASE wa_result-%param-billofmaterialitemunit.
                    WHEN 'KG'.
                      wa_raw4-qty = |{ ( wa_temp_raw-qty + wa_result-%param-componentquantityincompuom * 1000 ) DECIMALS = 3 }|.
                    WHEN 'G'.
                      wa_raw4-qty = wa_temp_raw-qty + wa_result-%param-componentquantityincompuom.
                  ENDCASE.
                WHEN 'KG'.
                  CASE wa_result-%param-billofmaterialitemunit.
                    WHEN 'G'.
                      wa_raw4-qty = |{ ( wa_temp_raw-qty + wa_result-%param-componentquantityincompuom / 1000 ) DECIMALS = 3 }|.
                    WHEN 'KG'.
                      wa_raw4-qty = wa_temp_raw-qty + wa_result-%param-componentquantityincompuom.
                  ENDCASE.
                WHEN 'ML'.
                  CASE wa_result-%param-billofmaterialitemunit.
                    WHEN 'L'.
                      wa_raw4-qty = |{ ( wa_temp_raw-qty + wa_result-%param-componentquantityincompuom * 1000 ) DECIMALS = 3 }|.
                    WHEN 'ML'.
                      wa_raw4-qty = wa_temp_raw-qty + wa_result-%param-componentquantityincompuom.
                  ENDCASE.
                WHEN 'L'.
                  CASE wa_result-%param-billofmaterialitemunit.
                    WHEN 'ML'.
                      wa_raw4-qty = |{ ( wa_temp_raw-qty + wa_result-%param-componentquantityincompuom / 1000 ) DECIMALS = 3 }|.
                    WHEN 'L'.
                      wa_raw4-qty = wa_temp_raw-qty + wa_result-%param-componentquantityincompuom.
                  ENDCASE.

                WHEN OTHERS.
                  wa_raw4-qty = wa_temp_raw-qty + wa_result-%param-componentquantityincompuom.

              ENDCASE.

*              IF wa_result-%param-billofmaterialitemunit = 'G'.
*                wa_raw4-qty = |{ ( wa_temp_raw-qty + wa_result-%param-componentquantityincompuom / 1000 ) DECIMALS = 3 }|.
*              ELSEIF wa_result-%param-billofmaterialitemunit = 'ML'.
*                wa_raw4-qty = |{ ( wa_temp_raw-qty + wa_result-%param-componentquantityincompuom / 1000 ) DECIMALS = 3 }|.
*              ELSE.
*                wa_raw4-qty = wa_temp_raw-qty + wa_result-%param-componentquantityincompuom.
*              ENDIF.
*              MODIFY lt_raw3 FROM wa_raw4.
              LOOP AT lt_raw3 INTO DATA(wa_up) WHERE material = wa_raw4-material.
                wa_up-qty = wa_raw4-qty.
                MODIFY lt_raw3 FROM wa_up.
                CLEAR wa_up.
              ENDLOOP.
            ELSE.
              wa_raw4-material = wa_result-%param-billofmaterialcomponent.

              CLEAR wa_uom.
              READ TABLE lt INTO wa_uom WITH KEY Product = wa_raw-material.

              CASE wa_uom-BaseUnit.

                WHEN 'G'.
                  CASE wa_result-%param-billofmaterialitemunit.
                    WHEN 'KG'.
                      wa_raw4-qty = |{ wa_result-%param-componentquantityincompuom * 1000 DECIMALS = 3 }|.
                    WHEN 'G'.
                      wa_raw4-qty = wa_result-%param-componentquantityincompuom.
                  ENDCASE.
                WHEN 'KG'.
                  CASE wa_result-%param-billofmaterialitemunit.
                    WHEN 'G'.
                      wa_raw4-qty = |{ wa_result-%param-componentquantityincompuom / 1000 DECIMALS = 3 }|.
                    WHEN 'KG'.
                      wa_raw4-qty = wa_result-%param-componentquantityincompuom.
                  ENDCASE.
                WHEN 'ML'.
                  CASE wa_result-%param-billofmaterialitemunit.
                    WHEN 'L'.
                      wa_raw4-qty = |{ wa_result-%param-componentquantityincompuom * 1000 DECIMALS = 3 }|.
                    WHEN 'ML'.
                      wa_raw4-qty = wa_result-%param-componentquantityincompuom.
                  ENDCASE.
                WHEN 'L'.
                  CASE wa_result-%param-billofmaterialitemunit.
                    WHEN 'ML'.
                      wa_raw4-qty = |{ wa_result-%param-componentquantityincompuom / 1000 DECIMALS = 3 }|.
                    WHEN 'L'.
                      wa_raw4-qty = wa_result-%param-componentquantityincompuom.
                  ENDCASE.

                WHEN OTHERS.
                  wa_raw-qty = wa_result-%param-componentquantityincompuom.

              ENDCASE.

*              IF wa_result-%param-billofmaterialitemunit = 'G'.
*                wa_raw4-qty = |{ wa_result-%param-componentquantityincompuom / 1000 DECIMALS = 3 }|.
*              ELSEIF wa_result-%param-billofmaterialitemunit = 'ML'.
*                wa_raw4-qty = |{ wa_result-%param-componentquantityincompuom / 1000 DECIMALS = 3 }|.
*              ELSE.
*                wa_raw4-qty = wa_result-%param-componentquantityincompuom.
*              ENDIF.
              INSERT wa_raw4 INTO TABLE lt_raw3.
            ENDIF.
            CLEAR wa_temp_raw.
          ENDLOOP.

          CLEAR lt_result.
          """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        ENDIF.

        CLEAR wa_fg.

      ENDLOOP.
      SORT lt_test BY material.
      DELETE ADJACENT DUPLICATES FROM lt_test COMPARING material.

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      DATA : lv_start_date TYPE d.
      lv_start_date = lv_sydate.

      ls_response-Day1 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day2 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day3 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day4 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day5 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day6 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day7 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day8 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day9 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day10 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day11 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day12 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day13 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day14 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day15 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day16 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day17 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day18 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day19 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day20 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day21 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day22 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day23 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day24 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day25 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day26 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day27 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day28 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day29 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.


      ls_response-Day30 = datefield( datef = lv_start_date ).
      lv_start_date = lv_start_date + 1.

      APPEND ls_response TO lt_response.

      """"""""" changes by apratim on 10.07.2025 """""""""""""
      SELECT FROM
      i_purchaseorderitemapi01 AS a
      LEFT JOIN i_purordschedulelineapi01 AS b ON a~PurchaseOrder = b~PurchaseOrder AND a~PurchaseOrderItem = b~PurchaseOrderItem
      FIELDS
      SUM( b~ScheduleLineOrderQuantity ) AS ScheduleLineOrderQuantity,
      SUM( b~RoughGoodsReceiptQty ) AS RoughGoodsReceiptQty,
      a~Material
      WHERE a~Material IN @lt_itemcode AND
      a~IsCompletelyDelivered <> 'X' AND
      a~PurchasingDocumentDeletionCode <> 'X'
      GROUP BY a~Material
      INTO TABLE @DATA(lt_open_po).

      SELECT FROM
      i_productplantbasic AS a
      FIELDS
      a~Plant,
      a~Product
      WHERE a~Product IS NOT INITIAL
      INTO TABLE @DATA(lt_plant_basic).



      """"""""""""""""""""""""""""""""""""""""""""""""""""""""

      LOOP AT lt INTO DATA(wa).
        ls_response-item_code = |{ wa-Product ALPHA = OUT }|.
        ls_response-item_name = wa-ProductName.
        ls_response-uom = wa-BaseUnit.
        IF ls_response-uom = 'ST'.
          ls_response-uom = 'PC'.
        ENDIF.

        READ TABLE lt_plant_basic INTO DATA(wa_plant_basic) WITH KEY Product = wa-Product.
        IF wa_plant_basic IS NOT INITIAL.
          ls_response-plant = wa_plant_basic-Plant.
        ENDIF.

        READ TABLE lv_prdsup INTO DATA(wa_prdsup) WITH KEY Product = wa-Product.
        IF wa_prdsup-reorderthresholdquantity IS NOT INITIAL.
          ls_response-msq = wa_prdsup-reorderthresholdquantity.
        ENDIF.
        IF wa_prdsup-maximumstockquantity IS NOT INITIAL.
          ls_response-Max_stock_level = wa_prdsup-maximumstockquantity.
        ENDIF.
        IF wa_prdsup-safetystockquantity IS NOT INITIAL.
          ls_response-min_stock_qty = wa_prdsup-safetystockquantity.
        ENDIF.

        READ TABLE lv_csq INTO DATA(wa_csq) WITH KEY Product = wa-Product.
        IF wa_csq-matlwrhsstkqtyinmatlbaseunit IS NOT INITIAL.
          ls_response-sob = wa_csq-matlwrhsstkqtyinmatlbaseunit.
        ENDIF.

        READ TABLE lt_raw3 INTO DATA(wa_temp_raw3) WITH KEY material = wa-Product.
        ls_response-pre_pend_wo = wa_temp_raw3-qty.
        CLEAR wa_temp_raw3.


        READ TABLE lv_avg_move INTO DATA(wa_avg1) WITH KEY Material = wa-product GoodsMovementType = '261'.
        READ TABLE lv_avg_move INTO DATA(wa_avg2) WITH KEY Material = wa-product GoodsMovementType = '262'.
        ls_response-AVG_movement = ( wa_avg1-quantityinbaseunit - wa_avg2-quantityinbaseunit ) / ( lv_months + 1 ).


        READ TABLE lt_raw INTO DATA(wa_raw3) WITH KEY day = lv_sydate material = wa-Product.
        ls_response-day1 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 1 ) material = wa-Product.
        ls_response-day2 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 2 ) material = wa-Product.
        ls_response-day3 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 3 ) material = wa-Product.
        ls_response-day4 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 4 ) material = wa-Product.
        ls_response-day5 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 5 ) material = wa-Product.
        ls_response-day6 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 6 ) material = wa-Product.
        ls_response-day7 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 7 ) material = wa-Product.
        ls_response-day8 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 8 ) material = wa-Product.
        ls_response-day9 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 9 ) material = wa-Product.
        ls_response-day10 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 10 ) material = wa-Product.
        ls_response-day11 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 11 ) material = wa-Product.
        ls_response-day12 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 12 ) material = wa-Product.
        ls_response-day13 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 13 ) material = wa-Product.
        ls_response-day14 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 14 ) material = wa-Product.
        ls_response-day15 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 15 ) material = wa-Product.
        ls_response-day16 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 16 ) material = wa-Product.
        ls_response-day17 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 17 ) material = wa-Product.
        ls_response-day18 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 18 ) material = wa-Product.
        ls_response-day19 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 19 ) material = wa-Product.
        ls_response-day20 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 20 ) material = wa-Product.
        ls_response-day21 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 21 ) material = wa-Product.
        ls_response-day22 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 22 ) material = wa-Product.
        ls_response-day23 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 23 ) material = wa-Product.
        ls_response-day24 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 24 ) material = wa-Product.
        ls_response-day25 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 25 ) material = wa-Product.
        ls_response-day26 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 26 ) material = wa-Product.
        ls_response-day27 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 27 ) material = wa-Product.
        ls_response-day28 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 28 ) material = wa-Product.
        ls_response-day29 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_raw INTO wa_raw3 WITH KEY day = ( lv_sydate + 29 ) material = wa-Product.
        ls_response-day30 = wa_raw3-qty.
        CLEAR wa_raw3.

        READ TABLE lt_open_po INTO DATA(wa_open_po) WITH KEY material = wa-Product.
        ls_response-open_po_qty = wa_open_po-schedulelineorderquantity - wa_open_po-roughgoodsreceiptqty.
        CLEAR wa_open_po.

        ls_response-total =
      ls_response-day1  + ls_response-day2  + ls_response-day3  + ls_response-day4  + ls_response-day5  +
      ls_response-day6  + ls_response-day7  + ls_response-day8  + ls_response-day9  + ls_response-day10 +
      ls_response-day11 + ls_response-day12 + ls_response-day13 + ls_response-day14 + ls_response-day15 +
      ls_response-day16 + ls_response-day17 + ls_response-day18 + ls_response-day19 + ls_response-day20 +
      ls_response-day21 + ls_response-day22 + ls_response-day23 + ls_response-day24 + ls_response-day25 +
      ls_response-day26 + ls_response-day27 + ls_response-day28 + ls_response-day29 + ls_response-day30 + ls_response-pre_pend_wo.

        ls_response-scb = ls_response-sob - ls_response-total.

        ls_response-Effective_avail_stock = ls_response-scb - ls_response-min_stock_qty.
        ls_response-Stock_below = ls_response-scb - ls_response-msq.

        DATA : temp_ordering TYPE p DECIMALS 2.

        temp_ordering = ls_response-Ordering_Qty.

        IF ( ls_response-Max_stock_level - ls_response-Stock_below ) < temp_ordering.
          ls_response-Minimum_po_qty = ls_response-Ordering_Qty.
        ELSE.
          ls_response-Minimum_po_qty = ls_response-Max_stock_level - ls_response-Stock_below.
        ENDIF.


        IF ls_response-Effective_avail_stock < 0.
          ls_response-Effective_avail_stock = ls_response-Effective_avail_stock * -1.
          CONCATENATE '-' ls_response-Effective_avail_stock INTO ls_response-Effective_avail_stock.
        ENDIF.

        IF ls_response-Stock_below < 0.
          ls_response-Stock_below = ls_response-Stock_below * -1.
          CONCATENATE '-' ls_response-Stock_below INTO ls_response-Stock_below.
        ENDIF.

        IF ls_response-Minimum_po_qty < 0.
          ls_response-Minimum_po_qty = ls_response-Minimum_po_qty * -1.
          CONCATENATE '-' ls_response-Minimum_po_qty INTO ls_response-Minimum_po_qty.
        ENDIF.

        IF ls_response-scb < 0.
          ls_response-scb = ls_response-scb * -1.
          CONCATENATE '-' ls_response-scb INTO ls_response-scb.
        ENDIF.

        IF ls_response-sob < 0.
          ls_response-sob = ls_response-sob * -1.
          CONCATENATE '-' ls_response-sob INTO ls_response-sob.
        ENDIF.


        COLLECT ls_response INTO lt_response.
        CLEAR wa.
        CLEAR ls_response.
        CLEAR wa_csq.
        CLEAR wa_prdsup.
        CLEAR wa_avg1.
        CLEAR wa_avg2.
        CLEAR temp_ordering.
      ENDLOOP.

      IF lt_plant IS NOT INITIAL.
        READ TABLE lt_plant INTO DATA(wa_plant) INDEX 1.
        DELETE lt_response WHERE plant <> wa_plant-low.
      ENDIF.


      lv_max_rows = lv_skip + lv_top.
      IF lv_skip > 0.
        lv_skip = lv_skip + 1.
      ENDIF.

      CLEAR lt_responseout.
      LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>) FROM lv_skip TO lv_max_rows.
        ls_responseout = <lfs_out_line_item>.
        APPEND ls_responseout TO lt_responseout.
      ENDLOOP.

      io_response->set_total_number_of_records( lines( lt_response ) ).
      io_response->set_data( lt_responseout ).

    ENDIF.
  ENDMETHOD.
ENDCLASS.
