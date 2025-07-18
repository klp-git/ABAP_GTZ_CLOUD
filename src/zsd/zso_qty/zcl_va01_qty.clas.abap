CLASS zcl_va01_qty DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_sd_sls_modify_item .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VA01_QTY IMPLEMENTATION.


  METHOD if_sd_sls_modify_item~modify_fields.
    data : lv_qty type p decimals 2.
    data : lv_mat type matnr.
*    data : lv_pack type char.
*    data: messagess like LINE OF messages
data it_message type table of messagetyp.
salesdocumentitem_extension_o = salesdocumentitem_extension_i.
   lv_mat = salesdocumentitem-material.
   shift lv_mat LEFT DELETING LEADING '0'.
    if salesdocumentitem-material is not initial.
       select single QuantityMultiple from zi_dd_mat
       where  Mat = @lv_mat
       into @data(lv_netwt)
       PRIVILEGED ACCESS.

    endif.

    if lv_netwt > 0 .
     lv_qty  = SALESDOCUMENTITEM-ORDERQUANTITY / lv_netwt.
    endif.

*     if lv_qty = lv_qty / 2.
*            lv_qty = lv_qty * 2.
*    else.
*    append value #( messagetype = 'E' messagetext = 'maintain correct qty'  ) to messages.

*       endif.

       IF frac( lv_qty ) <> 0.

       ELSE.
       salesdocumentitem_extension_o-YY1_PACKSIZE_SD_SDI = lv_netwt.
       salesdocumentitem_extension_o-yy1_noofpack_sd_sdi = lv_qty.
       salesdocumentitem_extension_o-yy1_packsize_sd_sdiu = salesdocumentitem-baseunit.

    endif.


  ENDMETHOD.
ENDCLASS.
