CLASS zcl_sales_forecast DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension .
    DATA :tb_data       TYPE TABLE OF zsalesforecast,
          lt_json_table TYPE TABLE OF zsalesforecast,
          wa_data       TYPE zsalesforecast.

    METHODS: post_html IMPORTING data TYPE string RETURNING VALUE(message) TYPE string.

    DATA: lv_json TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SALES_FORECAST IMPLEMENTATION.


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

      """""""""""""""""""""""" for date validations

*    DATA(count1) = 0.
*          message =  data.
*
*          /ui2/cl_json=>deserialize(
*        EXPORTING
*          json = data
*        CHANGING
*          data = tb_data
*      ).
*
*
*       DATA : lv_flag TYPE char1.
*          DATA : lv_len TYPE i .
*
*          LOOP AT tb_data INTO DATA(wa_data).
*
*            lv_len =  strlen( wa_data-forecastdate ).
*            IF lv_len > 8.
*              lv_flag = 'F' .
*              EXIT.
*            ENDIF.
*
*          ENDLOOP.
*
      """"""""""""""""""""""""

      TRY.

          DATA(count) = 0.
          message =  data.

          /ui2/cl_json=>deserialize(
        EXPORTING
          json = data
        CHANGING
          data = tb_data
      ).

          DATA : lv_flag TYPE c LENGTH 1.
          DATA : lv_len TYPE i .

*          delete ADJACENT DUPLICATES FROM tb_data comparing plant forecastmonth productcode.

          IF tb_data IS NOT INITIAL.
            SELECT * FROM zsalesforecast FOR ALL ENTRIES IN @tb_data WHERE plant = @tb_data-plant
            AND forecastmonth = @tb_data-forecastmonth AND productcode = @tb_data-productcode INTO TABLE @DATA(lv_sales).
          ENDIF.

          LOOP AT tb_data INTO DATA(wa_data).

            lv_len =  strlen( wa_data-forecastdate ).
            IF lv_len <> 8.
              lv_flag = 'F' .
              message = 'Something Went Wrong'.
              EXIT.

            ENDIF.

          ENDLOOP.

*          if lv_flag = 'F'.
**
*          endif.
* if lv_sales is INITIAL.
*  MESSAGE = 'Reocrd alreday exist'.
* else.

          IF lv_flag <> 'F'.
            LOOP AT tb_data INTO DATA(ls_Material).

              IF ls_material-bukrs = ''.
                ls_material-bukrs = 'GT00'.
              ENDIF.
              READ TABLE lv_sales INTO DATA(ls_sales) WITH KEY plant = ls_material-plant
                                                               forecastmonth = ls_material-forecastmonth
                                                               productcode = ls_material-productcode.
              IF sy-subrc EQ 0.
                message = 'Record already exist'.
              ELSE.
                MODIFY zsalesforecast FROM @ls_Material.
*            message = |{ ls_material-bukrs }|.
                message = 'Upload Successfully'.
              ENDIF.
            ENDLOOP.
          ENDIF.

        CATCH cx_static_check INTO DATA(er).

          message = |Something Went Wrong: { er->get_longtext( ) }|.
*          message = |Record already exist : { er->get_longtext( ) }|.

      ENDTRY.

    ELSE.

      message = |No Data Added|.

    ENDIF.



  ENDMETHOD.
ENDCLASS.
