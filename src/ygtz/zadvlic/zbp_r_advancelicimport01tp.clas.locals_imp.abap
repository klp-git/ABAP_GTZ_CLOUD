CLASS lhc_advancelicimport DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS CalculateCIFValueINR FOR DETERMINE ON MODIFY
      IMPORTING keys FOR advancelicimport~CalculateCIFValueINR.
    METHODS CalculateCIFValueINRSave FOR DETERMINE ON SAVE
      IMPORTING keys FOR advancelicimport~CalculateCIFValueINRSave.

ENDCLASS.

CLASS lhc_advancelicimport IMPLEMENTATION.

  METHOD CalculateCIFValueINR.

    READ ENTITY IN LOCAL MODE ZR_advancelicimport01TP
      FIELDS ( Cifvalue Advancelic )
      WITH CORRESPONDING #( keys )
      RESULT DATA(importlines).

    DATA updates TYPE TABLE FOR UPDATE ZR_advancelicimport01TP.

    LOOP AT importlines ASSIGNING FIELD-SYMBOL(<importline>).
      READ ENTITY in LOCAL MODE ZR_advancelicenseTP
        FIELDS ( Importexchangerate  )
        WITH CORRESPONDING #( keys )
        RESULT DATA(advancelicenses).
      LOOP AT advancelicenses INTO DATA(advancelicense).

      APPEND VALUE #( %tky = <importline>-%tky
                      Cifvalueinr = <importline>-Cifvalue * advancelicense-Importexchangerate
                      ) to updates.

      ENDLOOP.


    ENDLOOP.

    MODIFY ENTITY IN LOCAL MODE ZR_advancelicimport01TP
      UPDATE FIELDS ( Cifvalueinr ) WITH updates.


  ENDMETHOD.

  METHOD CalculateCIFValueINRSave.
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
