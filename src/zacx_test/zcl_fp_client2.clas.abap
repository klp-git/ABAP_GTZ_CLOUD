CLASS zcl_fp_client2 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA:
      mo_http_destination TYPE REF TO if_http_destination,
      mv_client           TYPE REF TO if_web_http_client.
    TYPES :
      BEGIN OF ty_template_body,
        xdp_Template        TYPE xstring,
        template_Name       TYPE c LENGTH 30,
        description         TYPE c LENGTH 280,
        note                TYPE c LENGTH 280,
        locale              TYPE c LENGTH 6,
        language            TYPE c LENGTH 280,
        master_Language     TYPE c LENGTH 280,
        business_Area       TYPE c LENGTH 280,
        business_Department TYPE c LENGTH 280,
      END OF ty_template_body,
      BEGIN OF ty_form_body,
        form_Name   TYPE c LENGTH 30,
        description TYPE c LENGTH 280,
        note        TYPE c LENGTH 30,
      END OF ty_form_body,
      tt_forms     TYPE STANDARD TABLE OF ty_form_body WITH KEY form_Name,
      tt_templates TYPE STANDARD TABLE OF ty_template_body WITH KEY template_Name.
    METHODS:
      constructor
        IMPORTING
          iv_name                  TYPE string
          iv_service_instance_name TYPE string OPTIONAL,
      get_template_by_name
        IMPORTING
                  iv_get_binary      TYPE abap_boolean DEFAULT abap_false
                  iv_form_name       TYPE string
                  iv_template_name   TYPE string
        RETURNING VALUE(rs_template) TYPE ty_template_body,
      reder_pdf
        IMPORTING
                  iv_xml             TYPE string
        RETURNING VALUE(rv_response) TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS:
      __get_request
        RETURNING VALUE(ro_request) TYPE REF TO if_web_http_request,
      __json2abap
        IMPORTING
          ir_input_data TYPE data
        CHANGING
          cr_abap_data  TYPE data,
      __execute
        IMPORTING
                  i_method           TYPE if_web_http_client=>method
        RETURNING VALUE(ro_response) TYPE REF TO if_web_http_response.

ENDCLASS.



CLASS ZCL_FP_CLIENT2 IMPLEMENTATION.


  METHOD constructor.
*    TRY.
*        mo_http_destination = cl_http_destination_provider=>create_by_cloud_destination(
*          i_service_instance_name = CONV #( iv_service_instance_name )
*          i_name                  = iv_name
*          i_authn_mode            = if_a4c_cp_service=>service_specific
*        ).
*        mv_client = cl_web_http_client_manager=>create_by_http_destination( mo_http_destination ).
*      CATCH cx_web_http_client_error into data(lv).
*       CATCH cx_http_dest_provider_error into data(lb).
*
*    ENDTRY.
  ENDMETHOD.


  METHOD get_template_by_name.

    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( |/v1/forms/{ iv_form_name }/templates/{ iv_template_name }| ).
    IF iv_get_binary = abap_true.
      lo_request->set_query( |select=xdpTemplate,templateData| ).
    ELSE.
      lo_request->set_query( |select=templateData| ).
    ENDIF.
    DATA(lo_response) = __execute(
      i_method = if_web_http_client=>get
    ).

    DATA(lv_json_response) = lo_response->get_text( ).
    DATA lr_data TYPE REF TO data.
    lr_data = /ui2/cl_json=>generate(
      json = lv_json_response
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    IF lr_data IS BOUND.
      ASSIGN lr_data->* TO FIELD-SYMBOL(<data>).
      __json2abap(
          EXPORTING
            ir_input_data = <data>
          CHANGING
            cr_abap_data = rs_template
      ).
    ENDIF.

  ENDMETHOD.


  METHOD reder_pdf.

*    TYPES :
*      BEGIN OF struct,
*        xdp_Template TYPE string,
*        xml_Data     TYPE string,
*        form_Type    TYPE string,
*        form_Locale  TYPE string,
*        tagged_Pdf   TYPE string,
*        embed_Font   TYPE string,
*      END OF struct.
*
*    CONSTANTS: cns_storage_name  TYPE string VALUE 'templateSource=storageName',
*               cns_template_name TYPE string VALUE 'worksorder/worksorder'.
*    DATA lr_data TYPE REF TO data.
*
*
*    DATA(lo_request) = __get_request( ).
*    lo_request->set_query( query =  cns_storage_name ).
*    lo_request->set_uri_path( i_uri_path = '/v1/adsRender/pdf' ).
*
*
*    DATA(ls_body) = VALUE struct(  xdp_Template = cns_template_name
*                                   xml_Data = iv_xml
*                                   form_Type = 'print'
*                                   form_Locale = 'en_US'
*                                   tagged_Pdf = '0'
*                                   embed_font = '0' ).
*
*    DATA(lv_json) = /ui2/cl_json=>serialize( data = ls_body compress = abap_true
*                                             pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
*
*    lo_request->append_text(
*          EXPORTING
*            data   = lv_json
*        ).
*
*    TRY.
*        DATA(lo_response) = __execute(
*          i_method = if_web_http_client=>post
*        ).
*
*        DATA(lv_json_response) = lo_response->get_text( ).
*
*        FIELD-SYMBOLS:
*          <data>                TYPE data,
*          <field>               TYPE any,
*          <pdf_based64_encoded> TYPE any.
*
*        "lv_json_response has the following structure `{"fileName":"PDFOut.pdf","fileContent":"JVB..."}
*
*        lr_data = /ui2/cl_json=>generate( json = lv_json_response ).
*
*        IF lr_data IS BOUND.
*          ASSIGN lr_data->* TO <data>.
*          ASSIGN COMPONENT `fileContent` OF STRUCTURE <data> TO <field>.
*          IF sy-subrc EQ 0.
*            ASSIGN <field>->* TO <pdf_based64_encoded>.
**            rv_response = <pdf_based64_encoded>.
*            rv_response = lv_json_response.
*          ENDIF.
*        ENDIF.
*
*    ENDTRY.


  ENDMETHOD.


  METHOD __execute.
*    TRY.
*        ro_response = mv_client->execute( i_method = i_method ).
*        DATA(response_body) = ro_response->get_text( ).
*        DATA(response_headers) = ro_response->get_header_fields( ).
*      CATCH cx_web_message_error.
*
*      CATCH cx_web_http_client_error INTO DATA(lo_http_error).

*    ENDTRY.
  ENDMETHOD.


  METHOD __get_request.
    ro_request = mv_client->get_http_request( ).
    ro_request->set_header_fields( VALUE #(
      ( name = 'Accept' value = 'application/json, text/plain, */*'  )
      ( name = 'Content-Type' value = 'application/json;charset=utf-8'  )
    ) ).
  ENDMETHOD.


  METHOD __json2abap.
    DATA(lo_input_struct)   = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( p_data = ir_input_data ) ).
    DATA(lo_target_struct)  = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( p_data = cr_abap_data ) ).


    LOOP AT lo_input_struct->components ASSIGNING FIELD-SYMBOL(<ls_component>).
      IF line_exists( lo_target_struct->components[ name = <ls_component>-name ] ).
        ASSIGN COMPONENT <ls_component>-name OF STRUCTURE ir_input_data TO FIELD-SYMBOL(<field_in_data>).
        ASSIGN COMPONENT <ls_component>-name OF STRUCTURE cr_abap_data TO FIELD-SYMBOL(<field_out_data>).

        IF lo_target_struct->components[ name = <ls_component>-name ]-type_kind = cl_abap_typedescr=>typekind_xstring.
          <field_out_data> = cl_web_http_utility=>decode_x_base64( <field_in_data>->* ).
        ELSE.
          <field_out_data> = <field_in_data>->*.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
