CLASS zdel_s DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zdel_s IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  Delete from zsalarytable.
  ENDMETHOD.
ENDCLASS.
