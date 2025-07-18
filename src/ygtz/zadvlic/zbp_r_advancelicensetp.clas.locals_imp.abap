CLASS lhc_advancelicense DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR advancelicense RESULT result.
    METHODS calcuateinrvalue FOR DETERMINE ON MODIFY
      IMPORTING keys FOR advancelicense~calcuateinrvalue.

    METHODS earlynumbering_advlicexport FOR NUMBERING
      IMPORTING entities FOR CREATE advancelicense\_Advancelicexport.

    METHODS earlynumbering_advlicimport FOR NUMBERING
      IMPORTING entities FOR CREATE advancelicense\_Advancelicimport.


ENDCLASS.

CLASS lhc_advancelicense IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

METHOD earlynumbering_advlicexport.
    READ ENTITIES OF ZR_advancelicenseTP IN LOCAL MODE
      ENTITY advancelicense BY \_advancelicexport
        FIELDS ( Advancelicitemno )
          WITH CORRESPONDING #( entities )
          RESULT DATA(entry_lines)
        FAILED failed.


    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entry_header>).
      " get highest item from lines
      DATA(max_item_id) = REDUCE #( INIT max = CONV posnr( '000000' )
                                    FOR entry_line IN entry_lines USING KEY entity WHERE ( Bukrs = <entry_header>-Bukrs and Advancelic = <entry_header>-Advancelic )
                                    NEXT max = COND posnr( WHEN entry_line-Advancelicitemno > max
                                                           THEN entry_line-Advancelicitemno
                                                           ELSE max )
                                  ).
    ENDLOOP.

    "assign Item No.
    LOOP AT <entry_header>-%target ASSIGNING FIELD-SYMBOL(<entry_line>).
      APPEND CORRESPONDING #( <entry_line> ) TO mapped-advancelicexport ASSIGNING FIELD-SYMBOL(<mapped_entry_line>).
      IF <entry_line>-Advancelicitemno IS INITIAL.
        max_item_id += 10.
        <mapped_entry_line>-Advancelicitemno = max_item_id.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_advlicimport.
    READ ENTITIES OF ZR_advancelicenseTP IN LOCAL MODE
      ENTITY advancelicense BY \_advancelicimport
        FIELDS ( Advancelicitemno )
          WITH CORRESPONDING #( entities )
          RESULT DATA(entry_lines)
        FAILED failed.


    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entry_header>).
      " get highest item from lines
      DATA(max_item_id) = REDUCE #( INIT max = CONV posnr( '000000' )
                                    FOR entry_line IN entry_lines USING KEY entity WHERE ( Bukrs = <entry_header>-Bukrs and Advancelic = <entry_header>-Advancelic )
                                    NEXT max = COND posnr( WHEN entry_line-Advancelicitemno > max
                                                           THEN entry_line-Advancelicitemno
                                                           ELSE max )
                                  ).
    ENDLOOP.

    "assign Item No.
    LOOP AT <entry_header>-%target ASSIGNING FIELD-SYMBOL(<entry_line>).
      APPEND CORRESPONDING #( <entry_line> ) TO mapped-advancelicimport ASSIGNING FIELD-SYMBOL(<mapped_entry_line>).
      IF <entry_line>-Advancelicitemno IS INITIAL.
        max_item_id += 10.
        <mapped_entry_line>-Advancelicitemno = max_item_id.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD CALCUATEINRVALUE.
    READ ENTITIES OF ZR_advancelicenseTP IN LOCAL MODE
      ENTITY advancelicense
      FIELDS ( Importexchangerate Exportexchangerate Importcifinfc Exportfobinfc )
      WITH CORRESPONDING #( keys )
      RESULT DATA(advlicenses).

    loop at advlicenses INTO DATA(advlicense).
      MODIFY ENTITIES OF ZR_advancelicenseTP IN LOCAL MODE
        ENTITY advancelicense
        UPDATE
        FIELDS ( Exportfobininr Importcifininr ) WITH VALUE #( ( %tky = advlicense-%tky
                      Exportfobininr = advlicense-Exportfobinfc * advlicense-Exportexchangerate
                      Importcifininr = advlicense-Importcifinfc * advlicense-Importexchangerate
                      ) ).

    endloop.


  ENDMETHOD.

ENDCLASS.
