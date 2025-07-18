CLASS lhc_advancelicexport DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS CalculateFOBValueINR FOR DETERMINE ON MODIFY
      IMPORTING keys FOR advancelicexport~CalculateFOBValueINR.

    METHODS ExportQtyAdd FOR DETERMINE ON MODIFY
      IMPORTING keys FOR advancelicexport~ExportQtyAdd.

ENDCLASS.

CLASS lhc_advancelicexport IMPLEMENTATION.

  METHOD CalculateFOBValueINR.

    READ ENTITY IN LOCAL MODE ZR_advancelicexportTP
      FIELDS ( Fobvalue Advancelic )
      WITH CORRESPONDING #( keys )
      RESULT DATA(exportlines).

    DATA updates TYPE TABLE FOR UPDATE ZR_advancelicexportTP.

    LOOP AT exportlines ASSIGNING FIELD-SYMBOL(<exportline>).
      READ ENTITY IN LOCAL MODE ZR_advancelicenseTP
        FIELDS ( Exportexchangerate  )
        WITH CORRESPONDING #( keys )
        RESULT DATA(advancelicenses).
      LOOP AT advancelicenses INTO DATA(advancelicense).

        APPEND VALUE #( %tky = <exportline>-%tky
                        Fobvalueinr = <exportline>-Fobvalue * advancelicense-Exportexchangerate
                        ) TO updates.

      ENDLOOP.


    ENDLOOP.

    MODIFY ENTITY IN LOCAL MODE ZR_advancelicexportTP
      UPDATE FIELDS ( Fobvalueinr ) WITH updates.


  ENDMETHOD.

  METHOD ExportQtyAdd.

    READ ENTITY IN LOCAL MODE ZR_advancelicexportTP
      FIELDS ( LicenseQTY Advancelic )
      WITH CORRESPONDING #( keys )
      RESULT DATA(exportlines).

    DATA updates TYPE TABLE FOR UPDATE ZR_advancelicenseTP.

    LOOP AT exportlines ASSIGNING FIELD-SYMBOL(<exportline>).
      READ ENTITY IN LOCAL MODE ZR_advancelicenseTP
        FIELDS ( Totalexportqty  )
        WITH CORRESPONDING #( keys )
        RESULT DATA(advancelicenses).
      LOOP AT advancelicenses INTO DATA(advancelicense).

        APPEND VALUE #( "%tky = <exportline>-%tky
                        Totalexportqty = <exportline>-Licenseqty + advancelicense-Totalexportqty
                        ) TO updates.

      ENDLOOP.


    ENDLOOP.

    MODIFY ENTITY IN LOCAL MODE ZR_advancelicenseTP
      UPDATE FIELDS ( Totalexportqty ) WITH updates.


  ENDMETHOD.



ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
