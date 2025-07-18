CLASS zcl_http_msme DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
    DATA :tb_data       TYPE TABLE OF zmsme_table,
          lt_json_table TYPE TABLE OF zmsme_table,
          wa_data       TYPE zmsme_table.

    METHODS: post_html IMPORTING data TYPE string RETURNING VALUE(message) TYPE string.

    DATA: lv_json TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_MSME IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.


    DATA(req_method) = request->get_method( ).

    CASE req_method.
      WHEN CONV string( if_web_http_client=>post ).

        " Handle POST request

        DATA(data) = request->get_text( ).

        response->set_text( post_html( data ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD post_html.


    IF data IS NOT INITIAL.

      TRY.
*         delete from zmaterial_table.

          DATA(count) = 0.
          message =  data.

*        lv_json = /ui2/cl_json=>serialize(  data = message
*                                                    pretty_name = /ui2/cl_json=>pretty_mode-camel_case )    .
          /ui2/cl_json=>deserialize(
        EXPORTING
          json = data
        CHANGING
          data = tb_data
      ).

          " Store parsed data into the class's table
*        tb_data = lt_json_table.
          LOOP AT tb_data INTO DATA(ls_Material).
            MODIFY zmsme_table FROM @ls_Material    .
*          count = count + 1.
          ENDLOOP.

          " Return success message
*          message = |Material Data successfully parsed into internal table. |.
          message = |Data uploading Successfully done. |.


        CATCH cx_static_check INTO DATA(er).

          message = |Something Went Wrong: { er->get_longtext( ) }|.

      ENDTRY.

    ELSE.

      message = |No Data Added|.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
