CLASS zcl_vf01_save DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_sd_bil_data_transfer .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VF01_SAVE IMPLEMENTATION.


  METHOD if_sd_bil_data_transfer~change_data.
   DATA(current_date) = cl_abap_context_info=>get_system_date( ).
   if bil_doc_res-billingdocumentdate ne current_date.
*    append value #( messagetype = 'E' messagetext = lv_msg  ) to messages.
   endif.
  ENDMETHOD.
ENDCLASS.
