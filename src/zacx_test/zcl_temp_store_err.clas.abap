CLASS zcl_temp_store_err DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .

    CONSTANTS:
      BEGIN OF setup_not_complete,
        msgid TYPE symsgid VALUE '' , "value 'Z_TMPL_STORE',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF setup_not_complete,
      BEGIN OF data_error,
        msgid TYPE symsgid VALUE '' , "VALUE 'Z_TMPL_STORE',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'MV_HTTP_STATUS_CODE',
        attr2 TYPE scx_attrname VALUE 'MV_HTTP_REASON',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF data_error,
      BEGIN OF http_client_error,
        msgid TYPE symsgid VALUE '' , "VALUE 'Z_TMPL_STORE',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'MV_HTTP_REASON',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF http_client_error.

    DATA mv_http_status_code TYPE i .
    DATA mv_http_reason TYPE string .
    METHODS constructor
      IMPORTING
        !textid              LIKE if_t100_message=>t100key OPTIONAL
        !previous            LIKE previous OPTIONAL
        !mv_http_status_code TYPE i OPTIONAL
        !mv_http_reason      TYPE string OPTIONAL .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TEMP_STORE_ERR IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    me->mv_http_status_code = mv_http_status_code .
    me->mv_http_reason = mv_http_reason .
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
