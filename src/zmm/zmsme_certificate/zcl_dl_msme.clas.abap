CLASS zcl_dl_msme DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DL_MSME IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DELETE FROM zmsme_table where vendorno is NOT INITIAL.
  ENDMETHOD.
ENDCLASS.
