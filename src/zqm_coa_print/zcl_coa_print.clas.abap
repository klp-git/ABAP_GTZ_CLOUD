
CLASS zcl_coa_print DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*    INTERFACES if_oo_adt_classrun .
    CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
    TYPES :
      BEGIN OF struct,
        xdp_template TYPE string,
        xml_data     TYPE string,
        form_type    TYPE string,
        form_locale  TYPE string,
        tagged_pdf   TYPE string,
        embed_font   TYPE string,
      END OF struct."


    CLASS-METHODS :
      create_client
        IMPORTING url           TYPE string
        RETURNING VALUE(result) TYPE REF TO if_web_http_client
        RAISING   cx_static_check ,

      read_posts
        IMPORTING lot             TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zqm_coa/zqm_coa'."'zpo/zpo_v2'."
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.

ENDCLASS.



CLASS ZCL_COA_PRINT IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .


*    SELECT SINGLE FROM I_InspectionLot
*    FIELDS * WHERE InspectionLot = @lot
*    INTO @DATA(wa).
*
*
*
*        DATA(lv_xml) = |<Form> | &&
*                         |<Inspection>| &&
*                         |<InspectionLot>{ wa-InspectionLot }</InspectionLot> | &&
*                         |<Material>{ wa-Material }</Material>| &&
*                         |</Inspection>| &&
*                         |</Form>|.

    TYPES : BEGIN OF ty_line,
              InspectionLot(12)                  TYPE c,
              inspectionspecificationtext(200)   TYPE c,
              inspspeclowerlimit(8)              TYPE p DECIMALS 3,
              inspspecupperlimit(8)              TYPE p DECIMALS 3,
              InspectionLimit(120)               TYPE c,
              InspSpecInformationField3(255)     TYPE c,

              deci_value(8)                      TYPE p DECIMALS 3,
              inspectionresultoriginalvalue(120) TYPE c,
              inspectionresulttext(120)          TYPE c,

              InspectionSpecificationPlant(4)    TYPE c,
              InspSpecImportanceCode(2)          TYPE c,
              INSPECTIONSPECIFICATIONUNIT(30)   TYPE c, """""""""""""""""""""
              inspectioncharacteristic(500)      TYPE c,
            END OF ty_line.
    DATA : it_line TYPE TABLE OF ty_line,
           wa_line TYPE ty_line.

    """"""""""""""""""""""" HEADER DATA """""""""""""""""""""""""""""""""""""""
    SELECT FROM i_InspectionLOT WITH PRIVILEGED ACCESS AS a

    INNER JOIN i_batch WITH PRIVILEGED ACCESS AS b ON a~Batch = b~Batch AND  a~Plant = b~Plant AND a~Material = b~Material
    INNER JOIN i_inspectionlottp_2 WITH PRIVILEGED ACCESS AS c ON a~InspectionLot = c~InspectionLot AND  a~Plant = c~Plant AND a~Material = c~Material
    FIELDS
    a~InspectionLot,
     a~InspectionLotObjectText , a~Material, a~InspectionLotQuantity, a~Batch,a~InspectionLotQuantityUnit,
           b~ShelfLifeExpirationDate, b~ManufactureDate,
           c~insplotqtytofree
           WHERE a~InspectionLot = @lot " '10000000466'
           INTO TABLE @DATA(it_head).
    READ TABLE it_head INTO DATA(wa_head) INDEX 1.
    SHIFT wa_head-Material LEFT DELETING LEADING '0'.



    SELECT SINGLE
   a~InspectionLot ,
   b~BOMAlternativeText ,
   c~inspectionlotusagedecidedon FROM
   i_InspectionLOT WITH PRIVILEGED ACCESS  AS a
   LEFT JOIN i_billofmaterialtp_2 WITH PRIVILEGED ACCESS AS b ON a~Material = b~Material
   LEFT JOIN i_insplotusagedecision WITH PRIVILEGED ACCESS AS c ON a~InspectionLot = c~InspectionLot
   WHERE a~InspectionLot = @lot
   INTO @DATA(wastp).





    SELECT SINGLE
    a~inspectionlot,
    b~producttype
    FROM i_InspectionLOT WITH PRIVILEGED ACCESS AS a
    LEFT JOIN i_product WITH PRIVILEGED ACCESS AS b ON a~Material = b~Product
    WHERE a~InspectionLot = @lot
    INTO @DATA(prd_ty).






    DATA temp_manuf TYPE sydate.
    DATA temp_expiry TYPE sydate.
    temp_manuf = wa_head-ManufactureDate.
    temp_expiry = wa_head-ShelfLifeExpirationDate.
    DATA : lv_date_expiry TYPE string.
    DATA : lv_date_manufacture TYPE string.

*CONCATENATE temp+6(2) temp+4(2) temp+0(4) INTO lv_date.
    CONCATENATE temp_expiry+6(2) '.'
                       temp_expiry+4(2)  '.'
                       temp_expiry+0(4)
                       INTO lv_date_expiry.
*                   SEPARATED BY '.'.

    CONCATENATE temp_manuf+6(2) '.'
                       temp_manuf+4(2)  '.'
                       temp_manuf+0(4)
                       INTO lv_date_manufacture.
*                   SEPARATED BY '.'.


    wa_head-ShelfLifeExpirationDate = lv_date_manufacture.


    wa_head-ShelfLifeExpirationDate = lv_date_expiry.
    wa_head-ManufactureDate = lv_date_manufacture.




    """"""""""""""""""""""" LINE ITEM DATA """""""""""""""""""""""""""""""""""""""
*     InspectionLot(12) TYPE c,
*        INSPECTIONSPECIFICATIONTEXT(60) type c,
*        INSPSPECLOWERLIMIT(8) type p DECIMALS 3,
*        INSPSPECUPPERLIMIT(8) type p DECIMALS 3,
*        InspectionLimit(60) type c,
*        InspSpecInformationField3(40) type c,
*
*        deci_value(8) type p DECIMALS 3,
*        INSPECTIONRESULTORIGINALVALUE(60) type c,
*        INSPECTIONRESULTTEXT(60) TYPE c,
*
*        InspectionSpecificationPlant(4) TYPE c,
*        INSPECIMPORTANCECODE TYPE i,
*

    SELECT FROM i_inspcharacteristictp_2 WITH PRIVILEGED ACCESS  AS a
    INNER JOIN i_inspectionresult WITH PRIVILEGED ACCESS  AS b ON a~InspectionLot = b~InspectionLot AND a~InspectionCharacteristic = b~InspectionCharacteristic

    FIELDS
    a~InspectionLot, b~InspectionResultText, a~inspspeclowerlimit, a~inspspecupperlimit,a~InspSpecInformationField3,
    b~inspectionresultoriginalvalue,a~inspectionspecificationtext ,
     a~InspectionSpecificationPlant, a~InspSpecImportanceCode , b~InspectionCharacteristic,
     a~InspectionSpecificationUnit """"""""""""""""""""""""""
                WHERE a~InspectionLot = @lot " '10000000466' "'010000000127'
           INTO CORRESPONDING FIELDS OF TABLE @it_line.



    DELETE it_line WHERE inspectionspecificationplant EQ 'GM30' AND  InspSpecImportanceCode <> '92'.

    DATA : temp1(8) TYPE c.
    DATA : temp2(8) TYPE c.

    DATA: deci_value TYPE p DECIMALS 3.


    LOOP AT it_line INTO wa_line.
      IF wa_line-InspSpecLowerLimit IS  INITIAL AND  wa_line-inspspecupperlimit IS  INITIAL.
        CONDENSE wa_line-inspspecinformationfield3.
        wa_line-inspectionlimit = wa_line-inspspecinformationfield3.
      ELSEIF  wa_line-InspSpecLowerLimit IS INITIAL.
        temp1 =  wa_line-InspSpecUpperLimit.
        CONDENSE: wa_line-inspectionlimit , temp1 .
        CONCATENATE '<=' temp1 INTO wa_line-inspectionlimit." SEPARATED BY space.
      ELSEIF  wa_line-inspspecupperlimit IS INITIAL.
        CLEAR temp2.
        temp2 =  wa_line-inspspeclowerlimit.
        CONDENSE: wa_line-inspectionlimit , temp2 .
        CONCATENATE '>=' temp2 INTO wa_line-inspectionlimit." SEPARATED BY space.
      ELSE.
        temp1 = wa_line-InspSpecLowerLimit.
        temp2 = wa_line-InspSpecUpperLimit.
        CONDENSE: wa_line-inspectionlimit , temp1,temp2 .
        CONCATENATE temp1 '-' temp2 INTO wa_line-inspectionlimit.
*         wa_line-inspectionlimit =  wa_line-InspSpecLowerLimit. "+ ' - ' + wa_line-InspSpecUpperLimit.
      ENDIF.
      """""""""""""""""""""""""""""""1"""""""""""""""""""""""""""""""""""
     if wa_line-inspectionspecificationunit cp 'Z*' .

      SELECT SINGLE FROM I_unitofmeasuretext as a
      FIELDS
      a~UnitOfMeasureName
      WHERE  a~UnitOfMeasure = @wa_line-inspectionspecificationunit
      AND a~Language = 'E'
      INTO @DATA(str1).
      wa_line-inspectionspecificationunit = str1.
     ENDIF.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

*      IF wa_line-inspectionresultoriginalvalue IS  INITIAL. """""""""""""""""""""""""""
*        wa_line-inspectionresultoriginalvalue = wa_line-inspectionresulttext.
*
*      ELSE.
*        wa_line-deci_value = wa_line-inspectionresultoriginalvalue.
*      ENDIF.
*      MODIFY it_line FROM wa_line.
*      CLEAR: wa_line, temp1,temp2.

      IF wa_line-inspectionresulttext IS NOT INITIAL. """""""""""""""""""""""""""
        wa_line-inspectionresultoriginalvalue = wa_line-inspectionresulttext.

      ELSEIF wa_line-inspectionresulttext is INITIAL .
        wa_line-deci_value = wa_line-inspectionresultoriginalvalue.
      ENDIF.
      MODIFY it_line FROM wa_line.
      CLEAR: wa_line, temp1,temp2.


 """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    ENDLOOP.

*    loop at IT_LINE into wa_line.
*    if wa_line-InspSpecLowerLimit is INITIAL and  wa_line-inspspecupperlimit is INITIAL.
*
*    ENDIF.
*    ENDLOOP.


    DATA:
      lt_result TYPE TABLE OF ty_line,
      wa_result TYPE ty_line,
      wa_inner  TYPE ty_line.

    SORT it_line BY inspectioncharacteristic.
    CLEAR wa_result.

    DATA(date_1) = sy-datum.

    LOOP AT it_line INTO wa_line.
      CLEAR wa_result.
      LOOP AT it_line INTO wa_inner.
        IF wa_inner-inspectionspecificationtext = wa_line-inspectionspecificationtext.
          IF wa_result-inspectionspecificationtext IS INITIAL.
            MOVE-CORRESPONDING wa_inner TO wa_result.
          ELSE.
            CONCATENATE wa_result-InspSpecInformationField3 wa_inner-InspSpecInformationField3 INTO wa_result-InspSpecInformationField3 SEPARATED BY space.
            CONCATENATE wa_result-inspectionresulttext wa_inner-inspectionresulttext INTO wa_result-inspectionresulttext SEPARATED BY space.
          ENDIF.
        ENDIF.
      ENDLOOP.
      APPEND wa_result TO lt_result.
*    DELETE it_line WHERE INSPECTIONSPECIFICATIONTEXT = wa_line-INSPECTIONSPECIFICATIONTEXT.
    ENDLOOP.

    DELETE ADJACENT DUPLICATES FROM lt_result COMPARING inspectionlot inspectionspecificationtext.

    LOOP AT lt_result INTO wa_result.
      IF wa_result-InspSpecLowerLimit IS  INITIAL AND  wa_result-inspspecupperlimit IS  INITIAL.
        wa_result-inspectionlimit = wa_result-inspspecinformationfield3.
        wa_result-inspectionresultoriginalvalue = wa_result-inspectionresulttext.
        MODIFY lt_result FROM wa_result.
        CLEAR: wa_result.
      ENDIF.
    ENDLOOP.

    DATA : pre_text TYPE string.
    DATA : wa_result2 LIKE LINE OF lt_result.

    DATA : lt_result1 LIKE lt_result.

    LOOP AT lt_result INTO wa_result.
      IF wa_result-inspectionresultoriginalvalue IS INITIAL AND wa_result-inspectionlimit IS INITIAL.
*        wa_result-inspectionspecificationtext = wa_result-inspectionspecificationtext.
        pre_text = wa_result2-inspectionspecificationtext.
        wa_result-inspectionlimit = wa_result2-inspectionlimit.
        wa_result-inspectionresultoriginalvalue = wa_result2-inspectionresultoriginalvalue.
        wa_result-deci_value = wa_result2-deci_value.
        wa_result-inspectionspecificationunit = wa_result2-inspectionspecificationunit . """""""""""" 1""""""""""
        CONCATENATE pre_text wa_result-inspectionspecificationtext  INTO wa_result-inspectionspecificationtext SEPARATED BY space.
        DELETE lt_result1 WHERE inspectionspecificationtext = pre_text.
      ENDIF.
      wa_result2 = wa_result.

      APPEND wa_result TO lt_result1.
      CLEAR wa_result.
    ENDLOOP.

    CLEAR lt_result.
    lt_result = lt_result1.


    DATA : xsml TYPE string.
    DATA(lv_xml) = |<Form> | &&
                         |<Inspection>| &&
                         |<InspectionLot>{ wa_head-InspectionLot }</InspectionLot> | &&
                         |<Material>{ wa_head-Material }</Material>| &&
                         |<ProductType>{ prd_ty-ProductType }</ProductType>| &&
                         |<BOMAlternativeText>{ wastp-BOMAlternativeText }</BOMAlternativeText>| &&
                         |<InspectionLotUsageDecidedOn>{ wastp-InspectionLotUsageDecidedOn }</InspectionLotUsageDecidedOn>| &&
                         |<IssuanceDate>{ date_1 }</IssuanceDate>| &&
                         |<INSPECTIONSPECIFICATIONTEXT>{ wa_head-InspectionLotObjectText }</INSPECTIONSPECIFICATIONTEXT>| &&
                         |<InspectionLotQuantity>{ wa_head-InspectionLotQuantity } { wa_head-InspectionLotQuantityUnit } </InspectionLotQuantity>| &&
                         |<Batch>{ wa_head-Batch }</Batch>| &&
                         |<ShelfLifeExpirationDate>{ lv_date_expiry }</ShelfLifeExpirationDate>| &&
                         |<ManufactureDate>{ lv_date_manufacture }</ManufactureDate>| &&
                         |<INSPLOTQTYTOFREE>{ wa_head-insplotqtytofree } { wa_head-InspectionLotQuantityUnit } </INSPLOTQTYTOFREE>| &&
                         |<BatchRelesedQuantityUnit>{ wa_head-InspectionLotQuantityUnit }</BatchRelesedQuantityUnit>| &&
                         |</Inspection>|.
*                     &&                     |</Form>|.
    DATA : num TYPE i VALUE 0.
    LOOP AT lt_result INTO wa_line.
      num = num + 1.
      DATA(lv_xml2) =
        |<tableDataRows>| &&
           |<siNo> { num } </siNo>| &&
           |<TestParameter>{ wa_line-inspectionspecificationtext  }</TestParameter>| &&
           |<Specification>{ wa_line-inspectionlimit }</Specification>| &&
           |<Results>{ wa_line-inspectionresultoriginalvalue }</Results>| &&
           |<Deci_value_spec>{ wa_line-deci_value }</Deci_value_spec>| &&
           |<INSPECTIONSPECIFICATIONUNIT>{ wa_line-inspectionspecificationunit }</INSPECTIONSPECIFICATIONUNIT>| && """"""""""""1""""
           |</tableDataRows>|
           .
      """" LV_XML-----------> Header
      """""lv_xml2 line one by one

      ""xsml---> line item(final)

      """""""""" Final version XML : LV_XML
      CONCATENATE xsml lv_xml2 INTO xsml .
    ENDLOOP.

    CONCATENATE lv_xml xsml INTO lv_xml.
    CONCATENATE lv_xml   '</Form>' INTO lv_xml.
     REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.
     REPLACE ALL OCCURRENCES OF '<=' IN lv_xml WITH 'let'.
     REPLACE ALL OCCURRENCES OF '>=' IN lv_xml WITH 'get'.
     """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
     REPLACE ALL OCCURRENCES OF '–' IN lv_xml WITH '-'.  " En dash
     REPLACE ALL OCCURRENCES OF '−' IN lv_xml WITH '-'.  " Minus sign
    REPLACE ALL OCCURRENCES OF '—' IN lv_xml WITH '-'.  " Em dash



    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).


  ENDMETHOD .
ENDCLASS.
