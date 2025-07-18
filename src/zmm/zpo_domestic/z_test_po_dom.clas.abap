CLASS z_test_po_dom DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z_TEST_PO_DOM IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
*    DATA: lv_string TYPE string.
*    data: lv_result type p DECIMALS 2.
*
*    lv_string = 'CGST 5% +UTGST 9% - Domestic output GST'.
*    FIND 'CGST' IN lv_string MATCH OFFSET DATA(lv_index).
*    lv_index = lv_index + 5.
*    lv_result = lv_string+lv_index(1).
*    lv_result = lv_result + 9.
    DATA: lv_addressid TYPE string.
    lv_addressid = '0000007026'.

    SELECT * FROM
    I_Address_2 AS a
    WHERE a~AddressID IS NOT INITIAL AND
    a~AddressID = @lv_addressid
    INTO TABLE @DATA(lt) PRIVILEGED ACCESS.

    out->write( lt ).
  ENDMETHOD.
ENDCLASS.
