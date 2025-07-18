CLASS zcl_vl01n_save DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_le_shp_save_doc_prepare .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VL01N_SAVE IMPLEMENTATION.


  METHOD if_le_shp_save_doc_prepare~modify_fields.

    DATA: LV_QTY TYPE menge_d.
    data: lv_mat type matnr.
    clear: lv_mat.

if DELIVERY_DOCUMENT_IN-DELIVERYDOCUMENTTYPE EQ 'JNL'
    OR DELIVERY_DOCUMENT_IN-DELIVERYDOCUMENTTYPE EQ 'LF'
    OR DELIVERY_DOCUMENT_IN-DELIVERYDOCUMENTTYPE EQ 'LR'..
    loop at DELIVERY_DOCUMENT_ITEMS_IN into data(wa_delitem).
        lv_mat = wa_delitem-material.
        shift lv_mat LEFT DELETING LEADING '0'.
        shift WA_delITEM-material left DELETING LEADING '0'.
        shift WA_delITEM-DELIVERYDOCUMENTITEM left DELETING LEADING '0'.

    if WA_delITEM-material is not initial.
       select single QuantityMultiple from zi_dd_mat
       where  Mat = @WA_delITEM-material
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

     lv_qty = WA_delITEM-actualdeliveryquantity / lv_netwt.
  endif.
  CONCATENATE 'Delivery Qty Should be Maintain Multiple of Material Pack Size Line Item - ' WA_delITEM-DELIVERYDOCUMENTITEM into data(lv_msg) SEPARATED BY space.
  IF frac( lv_qty ) <> 0.
     append value #( messagetype = 'E' messagetext = lv_msg  ) to messages.

       ELSE.
       lv_qty = lv_qty.
    endif.

clear lv_qty.
clear: lv_netwt.
*clear: lv_pack.
endloop.
endif.
  ENDMETHOD.
ENDCLASS.
