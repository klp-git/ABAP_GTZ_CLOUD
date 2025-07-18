CLASS zcl_salesjob_lines_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SALESJOB_LINES_TEST IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
*    delete from zpurchinvlines.
*    delete from zpurchinvproc.
    delete from zbillinglines WHERE billno is NOT INITIAL.
    delete from zbillingproc WHERE billingdocument is not INITIAL.

  ENDMETHOD.
ENDCLASS.
