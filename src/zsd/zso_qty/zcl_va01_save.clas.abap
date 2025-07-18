CLASS zcl_va01_save DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_sd_sls_check_before_save .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VA01_SAVE IMPLEMENTATION.


  METHOD if_sd_sls_check_before_save~check_document.

    DATA: LV_WEIGHT TYPE ntgew.
    DATA: LV_PACK TYPE  p DECIMALS  2.
    DATA: LV_QTY TYPE menge_d.
    data: lv_mat type matnr.

    clear : lv_weight.
    clear: lv_mat.
    loop at SALESDOCUMENTITEMS into data(wa_soitem).
        lv_mat = WA_SOITEM-material.
        shift lv_mat LEFT DELETING LEADING '0'.
        shift WA_SOITEM-material left DELETING LEADING '0'.
        shift WA_SOITEM-salesdocumentitem left DELETING LEADING '0'.
*     read table SALESDOCUMENTITEMS_EXTENSION into data(WA_SOITEMEXT) index 1.
*        concatenate 'Please maintain No of Packs for Material no ' WA_SOITEM-material ' & line item no' WA_SOITEM-salesdocumentitem into data(lv_msg1)
*        SEPARATED BY space.
*        concatenate 'Please maintain Pack Size for Material no ' WA_SOITEM-material ' & line item no' WA_SOITEM-salesdocumentitem into data(lv_msg2)
*        SEPARATED BY space.
*      IF WA_SOITEMEXT-yy1_noofpack_sd_sdi IS INITIAL.
*         append value #(  messagetype = 'E' messagetext = lv_msg1 ) to messages.
*      elseif WA_SOITEMEXT-yy1_packsize_sd_sdi IS INITIAL.
*         append value #(  messagetype = 'E' messagetext = lv_msg2 ) to messages.
*    endif.

    if WA_SOITEM-material is not initial.

           select single QuantityMultiple from zi_dd_mat
           where  Mat = @WA_SOITEM-material
           into @data(lv_netwt)
           PRIVILEGED ACCESS.
        endif.

        if lv_mat is not initial.

           select single QuantityMultiple from zi_dd_mat
           where  Mat = @lv_mat
           into @lv_netwt
           PRIVILEGED ACCESS.
        endif.


     if lv_netwt > 0 .

         lv_qty = WA_SOITEM-ORDERQUANTITY / lv_netwt.
      endif.
      CONCATENATE 'Order Qty Should be Maintain Multiple of Material Pack Size Line Item - ' WA_SOITEM-salesdocumentitem into data(lv_msg) SEPARATED BY space.
      IF frac( lv_qty ) <> 0.
         append value #( messagetype = 'E' messagetext = lv_msg  ) to messages.

           ELSE.
           lv_qty = lv_qty.
        endif.

    clear lv_qty.
    clear: lv_netwt.
    clear: lv_pack.

    endloop.


  ENDMETHOD.
ENDCLASS.
