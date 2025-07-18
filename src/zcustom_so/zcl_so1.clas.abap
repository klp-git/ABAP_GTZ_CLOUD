CLASS zcl_so1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SO1 IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF zcds_dd_so,
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
          CLEAR lt_filter_cond.
      ENDTRY.


      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'PLANT'.
          DATA(lt_so) = ls_filter_cond-range[].
*        ELSEIF ls_filter_cond-name = 'ITEM'.
*          DATA(lt_Product) = ls_filter_cond-range[].
*        ELSEIF ls_filter_cond-name = 'UOM'.
*          DATA(lt_UOM) = ls_filter_cond-range[].
*        ELSEIF ls_filter_cond-name = 'SAFETY_STOCK'.
*          DATA(lt_Safety) = ls_filter_cond-range[].
*        ELSEIF ls_filter_cond-name = 'PURCHASE_REQUISITION'.
*          DATA(lt_purchase) = ls_filter_cond-range[].
*        ELSEIF ls_filter_cond-name = 'PLANT_NAME'.
*          DATA(lt_plantName) = ls_filter_cond-range[].
*          ELSEIF ls_filter_cond-name = 'PURCHASE_ORDER'.
*          DATA(lt_po) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.

*
*      SELECT FROM I_ProductPlantBasic AS a
*      LEFT JOIN i_purchaseorderitemapi01 AS b
*      ON a~Product = b~Material
*      left join I_Plant as c on
*      a~Plant = c~Plant
*       FIELDS a~Plant,a~Product,a~BaseUnit,a~SafetyStockQuantity,b~PurchaseRequisition,c~PlantName,b~PurchaseOrder
*      WHERE a~Plant IN @lt_Plant AND a~Product IN @lt_Product AND a~BaseUnit IN @lt_UOM AND a~SafetyStockQuantity IN @lt_Safety
*      AND b~PurchaseRequisition IN @lt_purchase and c~PlantName in @lt_plantName and
*      b~PurchaseOrder in @lt_po INTO TABLE @DATA(it).



      SELECT FROM I_SalesOrder AS a

       FIELDS a~SalesOrder , a~SalesOrderType
      WHERE a~SalesOrder IN @lt_so
      INTO TABLE @DATA(it).

      LOOP AT it INTO DATA(wa).
        ls_response-so = wa-SalesOrder.
        ls_response-so_type = wa-SalesOrderType.

        APPEND ls_response TO lt_response.
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
