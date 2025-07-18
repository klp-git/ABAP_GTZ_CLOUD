CLASS ztest_zplant_address_pkg DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTEST_ZPLANT_ADDRESS_PKG IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
*  data: wa type ztable_plant.
    SELECT SINGLE * FROM
    ztable_plant AS a
    WHERE a~plant_code = 'GE01' AND a~comp_code = 'GT00'
    INTO @DATA(wa) PRIVILEGED ACCESS.

    wa-gstin_no = '19AABCG1667P1Z2'.
    MODIFY ztable_plant FROM @wa.

    SELECT SINGLE * FROM
   ztable_plant AS a
   WHERE a~plant_code = 'GM30' AND a~comp_code = 'GT00'
   INTO @DATA(wa1) PRIVILEGED ACCESS.

    wa1-gstin_no = '19AABCG1667P1Z2'.
    MODIFY ztable_plant FROM @wa1.



  ENDMETHOD.
ENDCLASS.
