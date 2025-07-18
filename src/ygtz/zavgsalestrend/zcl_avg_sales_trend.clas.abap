CLASS zcl_avg_sales_trend DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension .
    DATA :tb_data       TYPE TABLE OF zsalestrend,
          lt_json_table TYPE TABLE OF zsalestrend,
          wa_data       TYPE zsalestrend.

    METHODS: post_html IMPORTING data TYPE string RETURNING VALUE(message) TYPE string.

    DATA: lv_json TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_AVG_SALES_TREND IMPLEMENTATION.


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

          DATA(count) = 0.
          message =  data.

          /ui2/cl_json=>deserialize(
        EXPORTING
          json = data
        CHANGING
          data = tb_data
      ).


          IF tb_data IS NOT INITIAL.
            SELECT * FROM zsalestrend FOR ALL ENTRIES IN @tb_data WHERE plant = @tb_data-plant
            AND trendmonth = @tb_data-trendmonth AND productcode = @tb_data-productcode INTO TABLE @DATA(lv_trend).

            SELECT * FROM I_Product FOR ALL ENTRIES IN @tb_data WHERE ProductExternalID = @tb_data-productcode
            AND ProductType = 'ZSFG'
           INTO TABLE @DATA(lv_mate).

          ENDIF.

          IF lv_mate IS NOT INITIAL.
*            SELECT * FROM I_ProductDescription FOR ALL ENTRIES IN @lv_mate WHERE Product = @lv_mate-Product AND Language = 'E'
*              INTO TABLE @DATA(lv_desc).

*            SELECT * FROM I_ProductPlantBasic FOR ALL ENTRIES IN @lv_mate WHERE Product = @lv_mate-Product
*            INTO TABLE @DATA(lv_plantbasic).

          ENDIF.
*   delete ADJACENT DUPLICATES FROM tb_data comparing plant trendmonth bukrs.
          LOOP AT tb_data INTO DATA(ls_Material).

            IF ls_material-bukrs = ''.
              ls_material-bukrs = 'GT00'.
            ENDIF.
            READ TABLE lv_mate INTO DATA(ls_mat) WITH KEY ProductExternalID = ls_material-productcode.
            IF sy-subrc EQ 0.
*                ls_material-productcode = ls_mat-ProductExternalID.
            ENDIF.
*            READ TABLE lv_desc INTO DATA(ls_desc) WITH KEY Product = ls_mat-Product Language = 'E'.
            IF sy-subrc EQ 0.
*              ls_material-productdesc = ls_desc-ProductDescription.
            ENDIF.

*            READ TABLE lv_plantbasic INTO DATA(ls_plantbasic) WITH KEY Product = ls_mat-Product Plant = ls_material-plant.
            IF sy-subrc EQ 0.
*
            ENDIF.
            READ TABLE lv_trend INTO DATA(ls_trend) WITH KEY plant = ls_material-plant
                                                           trendmonth = ls_material-trendmonth
                                                           productcode = ls_material-productcode.

            IF sy-subrc EQ 0.
              message = 'Record already exist'.
*         elseif ls_material-productdesc ne ls_desc-ProductDescription.
*           MESSAGE = 'Please enter correct Product description'.
*         elseif ls_material-productcode ne ls_mat-ProductExternalID.
*           MESSAGE = 'Please enter correct Product Code'.
*         elseif ls_material-plant ne ls_material-plant.
*           MESSAGE = 'Please enter correct Plant'.
            ELSE.

              MODIFY zsalestrend  FROM @ls_Material    .
*            message = |{ data }|.
              message = 'Upload Successfully'.
            ENDIF.

          ENDLOOP.


        CATCH cx_static_check INTO DATA(er).

          message = |Something Went Wrong: { er->get_longtext( ) }|.

      ENDTRY.

    ELSE.

      message = |No Data Added|.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
