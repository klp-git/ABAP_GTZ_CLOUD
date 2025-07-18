CLASS zcl_test_dateformat DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TEST_DATEFORMAT IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA : lv_date TYPE datum.
    DATA : date TYPE c LENGTH 10.
    lv_date = '20250120' .

    CONCATENATE lv_date+0(4) lv_date+4(2) '01' into date.



  SELECT  * from zsalesforecast where plant = 'AA' and bukrs = 'JS02' into table @Data(it_temp).
*  lv_temp-forecastmonth = 20250120.
loop at it_temp into data(wa_temp).
wa_temp-forecastmonth = '20250120'.
modify zsalesforecast from @wa_temp.
endloop.

delete from zsalesforecast  WHERE productcode = 'IPHONE'.



    out->write( date ).

  ENDMETHOD.
ENDCLASS.
