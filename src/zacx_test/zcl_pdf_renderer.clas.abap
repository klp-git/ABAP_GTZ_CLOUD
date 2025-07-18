CLASS zcl_pdf_renderer DEFINITION
PUBLIC
FINAL
CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PDF_RENDERER IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    out->write( 'Finished processing.' ).
  ENDMETHOD.
ENDCLASS.
