CLASS zcl_pp_fg_schedule DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

    CLASS-METHODS : datefield IMPORTING
                                        datef         TYPE datn
                              RETURNING VALUE(result) TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PP_FG_SCHEDULE IMPLEMENTATION.


  METHOD datefield.
    DATA : datef2 TYPE datn.
    datef2 = datef.
    result = datef2+6(2) && '/' && datef2+4(2) && '/' && datef2(4).
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    IF io_request->is_data_requested(  ).
      DATA: lt_response    TYPE TABLE OF zdd_fg_schedule,
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
        ELSEIF ls_filter_cond-name = 'SCHEDULE_START_DATE'.
          DATA(lt_schedule_start_date) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'ITEM_NAME'.
          DATA(lt_item_name) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'MSQ'.
          DATA(lt_msq) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'CSQ'.
          DATA(lt_csq) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'PWOQ'.
          DATA(lt_pwoq) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'SOB'.
          DATA(lt_sob) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'SCB'.
          DATA(lt_scb) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'TOTAL'.
          DATA(lt_total) = ls_filter_cond-range[].
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

*      READ TABLE lt_schedule_start_date INTO DATA(ls_schedule_start_date) INDEX 1.
*      DATA lv_date TYPE dats.
*      DATA lv_date2 TYPE dats.
*      lv_date2 = ls_schedule_start_date-low.
*      lv_date = ls_schedule_start_date-low.
*      lv_date = lv_date + 30.

      TYPES: BEGIN OF st_final,
               item_code      TYPE i_product-product,
               item_name      TYPE i_producttext-productname,
               msq            TYPE string,
               csq            TYPE string,
               pwoq           TYPE string,
               sob            TYPE string,
               schduled_start TYPE datn,
               day1           TYPE string,
               day2           TYPE string,
               day3           TYPE string,
               day4           TYPE string,
               day5           TYPE string,
               day6           TYPE string,
               day7           TYPE string,
               day8           TYPE string,
               day9           TYPE string,
               day10          TYPE string,
               day11          TYPE string,
               day12          TYPE string,
               day13          TYPE string,
               day14          TYPE string,
               day15          TYPE string,
               day16          TYPE string,
               day17          TYPE string,
               day18          TYPE string,
               day19          TYPE string,
               day20          TYPE string,
               day21          TYPE string,
               day22          TYPE string,
               day23          TYPE string,
               day24          TYPE string,
               day25          TYPE string,
               day26          TYPE string,
               day27          TYPE string,
               day28          TYPE string,
               day29          TYPE string,
               day30          TYPE string,
               total          TYPE string,
               scb            TYPE string,
             END OF st_final.


      DATA : lt_final TYPE TABLE OF st_final.
      DATA : wa_final TYPE st_final.


      DATA: lv_sydate TYPE datum.
      lv_sydate = cl_abap_context_info=>get_system_date( ).
      lv_sydate = lv_sydate + 1.


      SELECT FROM I_product AS a
      LEFT JOIN i_producttext AS b ON a~Product = b~Product AND b~Language = 'E'
      FIELDS
      a~Product,
      b~ProductName
      WHERE a~ProductType = 'ZFGC'
      AND a~Product IN @lt_itemcode
      AND b~ProductName IN @lt_item_name
*    AND a~Product = '000000001400000000'
      INTO TABLE @DATA(lt).

*      SELECT FROM i_product AS a
*      INNER JOIN i_salesdocumentitem AS b
*        ON a~Product = b~Product
*      INNER JOIN i_salesdocumentscheduleline AS c
*        ON b~SalesDocument = c~SalesDocument
*        AND b~SalesDocumentItem = c~SalesDocumentItem
*      FIELDS
*        a~Product,
*        c~confirmeddeliverydate,
*        SUM( c~confirmedrqmtqtyinbaseunit ) AS confirmedrqmtqtyinbaseunit
*      WHERE a~ProductType = 'ZFGC'
*        AND a~Product IN @lt_itemcode
*        AND c~confirmeddeliverydate >= @lv_sydate
*        AND c~confirmeddeliverydate < @( lv_sydate + 30 )
*        AND b~SDProcessStatus <> 'C'
*        AND b~SDDocumentRejectionStatus = 'A'
*        AND b~SDDocumentCategory = 'C'
*      GROUP BY
*        a~Product,
*        c~confirmeddeliverydate
*      INTO TABLE @DATA(lv_sum).

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
        AND a~Product IN @lt_itemcode
        AND c~confirmeddeliverydate >= @lv_sydate
        AND c~confirmeddeliverydate < @( lv_sydate + 30 )
        AND b~SDProcessStatus <> 'C'
        AND b~SDDocumentRejectionStatus = 'A'
        AND b~SDDocumentCategory = 'C'
      GROUP BY
        a~Product,
        c~deliverydate
      INTO TABLE @DATA(lv_sum).

      """""""""" chnages by apratim on 28/05/2025 """"""""""""""""""""""""""

      SELECT FROM i_product AS a
      LEFT JOIN i_stockquantitycurrentvalue_2( p_displaycurrency = 'INR' ) AS b
        ON a~Product = b~Product
      FIELDS
        SUM( b~MatlWrhsStkQtyInMatlBaseUnit ) AS MatlWrhsStkQtyInMatlBaseUnit,
        a~Product
      WHERE
        b~ValuationAreaType = '1'
        AND b~inventorystocktype NOT IN ( 'S','03' )
        AND a~ProductType = 'ZFGC'
        AND a~Product IN @lt_itemcode
      GROUP BY a~Product
      INTO TABLE @DATA(lv_csq).


      SELECT FROM
      i_product AS a LEFT JOIN
      I_ProductSupplyPlanning AS b ON a~Product = b~Product
      FIELDS
      SUM( b~ReorderThresholdQuantity ) AS ReorderThresholdQuantity,
      a~Product
      WHERE
      a~Product IN @lt_itemcode
      AND a~ProductType = 'ZFGC'
      GROUP BY a~Product
      INTO TABLE @DATA(lv_prdsup).


*      SELECT FROM i_product AS a
*      LEFT JOIN i_salesdocumentitem AS b
*      ON a~Product = b~Product
*      LEFT JOIN i_salesdocumentscheduleline AS c
*      ON b~SalesDocument = c~SalesDocument
*      AND b~SalesDocumentItem = c~SalesDocumentItem
*      FIELDS
*      SUM( c~ConfdOrderQtyByMatlAvailCheck ) AS ConfdOrderQtyByMatlAvailCheck,
*      a~Product
*      WHERE
*      c~ConfirmedDeliveryDate <= @( lv_sydate )
*      AND a~Product IN @lt_itemcode
*      AND a~Product = 'ZFGC'
*      AND b~SDProcessStatus <> 'C'
*      AND b~SDDocumentRejectionStatus = 'A'
*      AND b~SDDocumentCategory = 'C'
*      GROUP BY a~Product
*      INTO TABLE @DATA(lv_pwoq).

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
        AND a~Product IN @lt_itemcode
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
        AND a~Product IN @lt_itemcode
        AND b~SDProcessStatus <> 'C'
        AND b~SDDocumentRejectionStatus = 'A'
        AND b~SDDocumentCategory = 'C'
        AND c~GoodsMovementStatus = 'C'
      GROUP BY
        a~Product
      INTO TABLE @DATA(lv_pwoq2).


      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


      LOOP AT lt INTO DATA(wa)." WHERE Product = '000000001400001212'.

        DATA lv_product TYPE string.
        lv_product = wa-Product.
        SHIFT lv_product LEFT DELETING LEADING '0'.


        wa_final-item_code = lv_product.
        wa_final-item_name = wa-ProductName.

        READ TABLE lv_csq INTO DATA(wa_csq) WITH KEY Product = wa-Product.
        IF wa_csq-matlwrhsstkqtyinmatlbaseunit IS NOT INITIAL.
          wa_final-csq = wa_csq-matlwrhsstkqtyinmatlbaseunit.
        ENDIF.

        READ TABLE lv_prdsup INTO DATA(wa_prdsup) WITH KEY Product = wa-Product.
        IF wa_prdsup-reorderthresholdquantity IS NOT INITIAL.
          wa_final-msq = wa_prdsup-reorderthresholdquantity.
        ENDIF.

        READ TABLE lv_pwoq INTO DATA(wa_pwoq) WITH KEY Product = wa-Product.
        IF wa_pwoq-confdorderqtybymatlavailcheck IS NOT INITIAL.
          wa_final-pwoq = wa_pwoq-confdorderqtybymatlavailcheck.
        ENDIF.

        READ TABLE lv_pwoq2 INTO DATA(wa_pwoq2) WITH KEY Product = wa-Product.
        IF wa_pwoq2-confdorderqtybymatlavailcheck IS NOT INITIAL.
          wa_final-pwoq = wa_final-pwoq - wa_pwoq2-confdorderqtybymatlavailcheck.
        ENDIF.


        wa_final-sob = wa_final-csq - wa_final-pwoq.
        wa_final-schduled_start = lv_sydate.


        READ TABLE lv_sum INTO DATA(wa_sum) WITH KEY ConfirmedDeliveryDate = lv_sydate Product = wa-Product.
        wa_final-day1 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 1 ) Product = wa-Product.
        wa_final-day2 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 2 ) Product = wa-Product.
        wa_final-day3 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 3 ) Product = wa-Product.
        wa_final-day4 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 4 ) Product = wa-Product.
        wa_final-day5 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 5 ) Product = wa-Product.
        wa_final-day6 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 6 ) Product = wa-Product.
        wa_final-day7 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 7 ) Product = wa-Product.
        wa_final-day8 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 8 ) Product = wa-Product.
        wa_final-day9 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 9 ) Product = wa-Product.
        wa_final-day10 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 10 ) Product = wa-Product.
        wa_final-day11 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 11 ) Product = wa-Product.
        wa_final-day12 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 12 ) Product = wa-Product.
        wa_final-day13 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 13 ) Product = wa-Product.
        wa_final-day14 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 14 ) Product = wa-Product.
        wa_final-day15 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 15 ) Product = wa-Product.
        wa_final-day16 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 16 ) Product = wa-Product.
        wa_final-day17 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 17 ) Product = wa-Product.
        wa_final-day18 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 18 ) Product = wa-Product.
        wa_final-day19 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 19 ) Product = wa-Product.
        wa_final-day20 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 20 ) Product = wa-Product.
        wa_final-day21 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 21 ) Product = wa-Product.
        wa_final-day22 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 22 ) Product = wa-Product.
        wa_final-day23 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 23 ) Product = wa-Product.
        wa_final-day24 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 24 ) Product = wa-Product.
        wa_final-day25 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 25 ) Product = wa-Product.
        wa_final-day26 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 26 ) Product = wa-Product.
        wa_final-day27 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 27 ) Product = wa-Product.
        wa_final-day28 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 28 ) Product = wa-Product.
        wa_final-day29 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        READ TABLE lv_sum INTO wa_sum WITH KEY ConfirmedDeliveryDate = ( lv_sydate + 29 ) Product = wa-Product.
        wa_final-day30 = wa_sum-confirmedrqmtqtyinbaseunit.
        CLEAR wa_sum.

        wa_final-total =
      wa_final-day1  + wa_final-day2  + wa_final-day3  + wa_final-day4  + wa_final-day5  +
      wa_final-day6  + wa_final-day7  + wa_final-day8  + wa_final-day9  + wa_final-day10 +
      wa_final-day11 + wa_final-day12 + wa_final-day13 + wa_final-day14 + wa_final-day15 +
      wa_final-day16 + wa_final-day17 + wa_final-day18 + wa_final-day19 + wa_final-day20 +
      wa_final-day21 + wa_final-day22 + wa_final-day23 + wa_final-day24 + wa_final-day25 +
      wa_final-day26 + wa_final-day27 + wa_final-day28 + wa_final-day29 + wa_final-day30.

        wa_final-scb = wa_final-sob - wa_final-total.

        IF wa_final-scb < 0.
          wa_final-scb = wa_final-scb * -1.
          CONCATENATE '-' wa_final-scb INTO wa_final-scb.
        ENDIF.

        IF wa_final-sob < 0.
          wa_final-sob = wa_final-sob * -1.
          CONCATENATE '-' wa_final-sob INTO wa_final-sob.
        ENDIF.



        CONDENSE wa_final-csq NO-GAPS.
        CONDENSE wa_final-msq NO-GAPS.
        CONDENSE wa_final-pwoq NO-GAPS.
        CONDENSE wa_final-total NO-GAPS.
        CONDENSE wa_final-scb NO-GAPS.
        CONDENSE wa_final-sob NO-GAPS.
        APPEND wa_final TO lt_final.

        CLEAR wa.
        CLEAR wa_final.
        CLEAR lv_product.
        CLEAR wa_sum.
        CLEAR wa_pwoq.
        CLEAR wa_prdsup.
        CLEAR wa_csq.
        CLEAR wa_pwoq2.

      ENDLOOP.

      DELETE lt_final WHERE ( pwoq IS INITIAL OR pwoq = 0 ) AND total = 0.

      READ TABLE lt_csq INTO DATA(wa_csq2) INDEX 1.
      IF sy-subrc EQ 0.
        SHIFT wa_csq2-low LEFT DELETING LEADING '*'.
        SHIFT wa_csq2-low RIGHT DELETING TRAILING '*'.
        CONDENSE wa_csq2-low NO-GAPS.

        IF wa_csq2-low IS NOT INITIAL.
          DELETE lt_final WHERE csq <> wa_csq2-low.
        ENDIF.
      ENDIF.

      READ TABLE lt_msq INTO DATA(wa_msq2) INDEX 1.
      IF sy-subrc EQ 0.
        SHIFT wa_msq2-low LEFT DELETING LEADING '*'.
        SHIFT wa_msq2-low RIGHT DELETING TRAILING '*'.
        CONDENSE wa_msq2-low NO-GAPS.

        IF wa_msq2-low IS NOT INITIAL.
          DELETE lt_final WHERE msq <> wa_msq2-low.
        ENDIF.
      ENDIF.

      READ TABLE lt_pwoq INTO DATA(wa_pwoq3) INDEX 1.
      IF sy-subrc EQ 0.
        SHIFT wa_pwoq3-low LEFT DELETING LEADING '*'.
        SHIFT wa_pwoq3-low RIGHT DELETING TRAILING '*'.
        CONDENSE wa_pwoq3-low NO-GAPS.

        IF wa_pwoq3-low IS NOT INITIAL.
          DELETE lt_final WHERE pwoq <> wa_pwoq3-low.
        ENDIF.
      ENDIF.

      READ TABLE lt_total INTO DATA(wa_total2) INDEX 1.
      IF sy-subrc EQ 0.
        SHIFT wa_total2-low LEFT DELETING LEADING '*'.
        SHIFT wa_total2-low RIGHT DELETING TRAILING '*'.
        CONDENSE wa_total2-low NO-GAPS.

        IF wa_total2-low IS NOT INITIAL.
          DELETE lt_final WHERE total <> wa_total2-low.
        ENDIF.
      ENDIF.

      READ TABLE lt_sob INTO DATA(wa_sob2) INDEX 1.
      IF sy-subrc EQ 0.
        SHIFT wa_sob2-low LEFT DELETING LEADING '*'.
        SHIFT wa_sob2-low RIGHT DELETING TRAILING '*'.
        CONDENSE wa_sob2-low NO-GAPS.

        IF wa_sob2-low IS NOT INITIAL.
          DELETE lt_final WHERE sob <> wa_sob2-low.
        ENDIF.
      ENDIF.

      READ TABLE lt_scb INTO DATA(wa_scb2) INDEX 1.
      IF sy-subrc EQ 0.
        SHIFT wa_scb2-low LEFT DELETING LEADING '*'.
        SHIFT wa_scb2-low RIGHT DELETING TRAILING '*'.
        CONDENSE wa_scb2-low NO-GAPS.

        IF wa_scb2-low IS NOT INITIAL.
          DELETE lt_final WHERE scb <> wa_scb2-low.
        ENDIF.
      ENDIF.


      DATA : lv_start_date TYPE d.
      DATA : lv_end_date TYPE d.

      lv_start_date = lv_sydate.
      lv_end_date = lv_sydate + 30.

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
      CLEAR ls_response.

      LOOP AT lt_final INTO wa_final.
        ls_response-item_code = wa_final-item_code.
        ls_response-item_name = wa_final-item_name.
        ls_response-msq = wa_final-msq.
        ls_response-csq = wa_final-csq.
        ls_response-pwoq = wa_final-pwoq.

*        IF wa_final-sob < 0.
*          wa_final-sob = wa_final-sob * -1.
*          CONCATENATE '-' wa_final-sob INTO wa_final-sob.
*        ENDIF.
        ls_response-sob = wa_final-sob.

        ls_response-day1  = wa_final-day1.
        ls_response-day2  = wa_final-day2.
        ls_response-day3  = wa_final-day3.
        ls_response-day4  = wa_final-day4.
        ls_response-day5  = wa_final-day5.
        ls_response-day6  = wa_final-day6.
        ls_response-day7  = wa_final-day7.
        ls_response-day8  = wa_final-day8.
        ls_response-day9  = wa_final-day9.
        ls_response-day10 = wa_final-day10.
        ls_response-day11 = wa_final-day11.
        ls_response-day12 = wa_final-day12.
        ls_response-day13 = wa_final-day13.
        ls_response-day14 = wa_final-day14.
        ls_response-day15 = wa_final-day15.
        ls_response-day16 = wa_final-day16.
        ls_response-day17 = wa_final-day17.
        ls_response-day18 = wa_final-day18.
        ls_response-day19 = wa_final-day19.
        ls_response-day20 = wa_final-day20.
        ls_response-day21 = wa_final-day21.
        ls_response-day22 = wa_final-day22.
        ls_response-day23 = wa_final-day23.
        ls_response-day24 = wa_final-day24.
        ls_response-day25 = wa_final-day25.
        ls_response-day26 = wa_final-day26.
        ls_response-day27 = wa_final-day27.
        ls_response-day28 = wa_final-day28.
        ls_response-day29 = wa_final-day29.
        ls_response-day30 = wa_final-day30.
        ls_response-total = wa_final-total.

*        IF wa_final-scb < 0.
*          wa_final-scb = wa_final-scb * -1.
*          CONCATENATE '-' wa_final-scb INTO wa_final-scb.
*        ENDIF.
        ls_response-scb = wa_final-scb.

        APPEND ls_response TO lt_response.
        CLEAR wa_final.
        CLEAR ls_response.
      ENDLOOP.



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
