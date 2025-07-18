*CLASS lhc_Inspection DEFINITION INHERITING FROM cl_abap_behavior_handler.
*  PRIVATE SECTION.
*
*    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
*      IMPORTING keys REQUEST requested_authorizations FOR Inspection RESULT result.
*
*    METHODS validateVendor FOR VALIDATE ON SAVE
*      IMPORTING keys FOR Inspection~validateVendor.
*
*ENDCLASS.
*
*CLASS lhc_Inspection IMPLEMENTATION.
*
*  METHOD get_instance_authorizations.
*  ENDMETHOD.
*
*  METHOD validateVendor.
*  ENDMETHOD.
*
*ENDCLASS.
CLASS lhc_inspection DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.



    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION

      IMPORTING keys REQUEST requested_authorizations FOR inspection RESULT result.



    METHODS validatevendor FOR VALIDATE ON SAVE

      IMPORTING keys FOR inspection~validatevendor.



ENDCLASS.



CLASS lhc_inspection IMPLEMENTATION.



  METHOD get_instance_authorizations.

  ENDMETHOD.



  METHOD validatevendor.

**********************************************************************

*   reading entities from CDS view

    READ ENTITIES OF zi_upload_insp IN LOCAL MODE

    ENTITY Inspection

    ALL FIELDS

    WITH CORRESPONDING #( keys )

    RESULT DATA(inspectations)

    FAILED DATA(inspectation_failed).

    IF inspectation_failed IS NOT INITIAL.

*    if the above read fails then return the error message

      failed = CORRESPONDING #( DEEP inspectation_failed ).

      RETURN.

    ENDIF.

    LOOP AT inspectations ASSIGNING FIELD-SYMBOL(<inspectation>).

      IF <inspectation>-Vendor <> '9999999999'.

        DATA(lv_msg) = |Vendor must be '9999999999'|.

        lv_msg = COND #( WHEN <inspectation>-ExcelRowNumber IS INITIAL

        THEN lv_msg

        ELSE |Row { <inspectation>-ExcelRowNumber } : { lv_msg }| ).

        APPEND VALUE #( %tky = <inspectation>-%tky ) TO failed-inspection.

        APPEND VALUE #( %tky = <inspectation>-%tky

                        %state_area = 'Validate Vendor'

                        %msg = new_message_with_text(

                            severity = if_abap_behv_message=>severity-error

                            text = lv_msg )

                         %element-vendor = if_abap_behv=>mk-on ) TO reported-inspection.



      ENDIF.

      CLEAR lv_msg.

    ENDLOOP.



**********************************************************************

  ENDMETHOD.



ENDCLASS.
