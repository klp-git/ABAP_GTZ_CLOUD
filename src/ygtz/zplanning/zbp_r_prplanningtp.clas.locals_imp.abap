CLASS lhc_prplanning DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR PRPlanning
        RESULT result,
      createPlanningData FOR MODIFY
        IMPORTING keys FOR ACTION PRPlanning~createPlanningData RESULT result,
      deletePlanData FOR MODIFY
            IMPORTING keys FOR ACTION PRPlanning~deletePlanData RESULT result.
ENDCLASS.

CLASS lhc_prplanning IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD createPlanningData.

    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_prplanning' ##NO_TEXT.

    DATA plantno TYPE c LENGTH 4 .
    DATA lv_date TYPE d.
*    data productcode type char40.
    DATA create_pldata TYPE STRUCTURE FOR CREATE zr_prplanningtp.
    DATA create_pldatatab TYPE TABLE FOR CREATE zr_prplanningtp.
    DATA insertTag TYPE int1.
    DATA supplytag TYPE int1.
    DATA maxbillingdate TYPE d.
    DATA toDate TYPE d.

    LOOP AT keys INTO DATA(ls_key).
      TRY.
          plantno = ls_key-%param-PlantNo.
          lv_date = ls_key-%param-PlanDate .
*          productcode = ls_key-%param-ProductCode.

          IF plantno IS INITIAL.
            plantno = ''.
          ENDIF.

          IF plantno = ''.

            APPEND VALUE #( %cid = ls_key-%cid ) TO failed-prplanning.
            APPEND VALUE #( %cid = ls_key-%cid
                            %msg = new_message_with_text(
                                     severity = if_abap_behv_message=>severity-error
                                     text     = 'Plant cannot be blank.' )
                          ) TO reported-prplanning.
            RETURN.
          ENDIF.

          IF lv_date IS NOT INITIAL.
            DATA(lv_year) = lv_date+0(4).
            DATA(lv_month) = lv_date+4(2).
            DATA(lv_day) = '01'.
            lv_date = |{ lv_year }{ lv_month ALPHA = IN }{ lv_day }|.

            lv_month += 1.

            IF lv_month > 12.
              lv_month = 1.
              lv_year  = lv_year + 1.
            ENDIF.

            DATA(lv_date2) = |{ lv_year }{ lv_month ALPHA = IN }{ lv_day }|.
            toDate = lv_date2.
            toDate = toDate - 1.

            SELECT SINGLE FROM zprplanning FIELDS *
            WHERE planningmonth = @lv_date2
            INTO @DATA(wa_prplanning).

            IF wa_prplanning IS NOT INITIAL.
              APPEND VALUE #( %cid = ls_key-%cid ) TO failed-prplanning.
              APPEND VALUE #( %cid = ls_key-%cid
                              %msg = new_message_with_text(
                                       severity = if_abap_behv_message=>severity-error
                                       text     = 'Planning data already generated for the next Month.' )
                            ) TO reported-prplanning.
              RETURN.
            ENDIF.
          ENDIF.

          TRANSLATE plantno TO UPPER CASE.

          SELECT SINGLE FROM I_ProductPlantBasic FIELDS Plant
          WHERE Plant = @plantno
          INTO @DATA(lv_plant).


          IF lv_plant IS INITIAL.
            APPEND VALUE #( %cid = ls_key-%cid ) TO failed-prplanning.
            APPEND VALUE #( %cid = ls_key-%cid
                            %msg = new_message_with_text(
                                     severity = if_abap_behv_message=>severity-error
                                     text     = 'Plant is not found in DB.' )
                          ) TO reported-prplanning.
            RETURN.
          ENDIF.
      ENDTRY.

      "delete planning data
      DATA: it_instance_d TYPE TABLE FOR DELETE ZR_PRPlanningTP.
*
*      DATA keys_mapped TYPE TABLE FOR DELETE ZR_PRPlanningTP.
*      keys_mapped = VALUE #( FOR wa IN keys
*        ( Plant = wa-%param-PlantNo
*          Planningmonth = wa-%param-PlanDate ) ).
*
*
*      READ ENTITIES OF ZR_PRPlanningTP IN LOCAL MODE
*        ENTITY PRPlanning
*        FIELDS ( plant planningmonth ) WITH CORRESPONDING #( keys_mapped )
*        RESULT DATA(planningdata)
*        FAILED failed.

      SELECT FROM zprplanning FIELDS planningmonth, plant
      WHERE plant = @plantno AND planningmonth = @lv_date
      INTO TABLE @DATA(it_delete_tab) UP TO 1 ROWS.


      LOOP AT it_delete_tab INTO DATA(wa_prplanning2).

        SELECT FROM zprplanning
          FIELDS bukrs, plant, planningmonth, productcode
          WHERE plant = @wa_prplanning2-Plant AND planningmonth = @wa_prplanning2-Planningmonth
          INTO TABLE @DATA(it_prplanning_del_tab).
        LOOP AT it_prplanning_del_tab INTO DATA(wa_prplanning_del_tab).
          it_instance_d = VALUE #( (
                                      Bukrs         = wa_prplanning_del_tab-Bukrs
                                      Plant         = wa_prplanning_del_tab-Plant
                                      Planningmonth = wa_prplanning_del_tab-Planningmonth
                                      Productcode   = wa_prplanning_del_tab-Productcode
                                    ) ).

          MODIFY ENTITIES OF ZR_PRPlanningTP IN LOCAL MODE
            ENTITY PRPlanning
            DELETE FROM it_instance_d
            FAILED failed
            REPORTED reported.

          CLEAR wa_prplanning_del_tab.
        ENDLOOP.

*        COMMIT ENTITIES
        CLEAR wa_prplanning2.
      ENDLOOP.

      "delete planning data end



      SELECT FROM I_ProductPlantBasic AS ppb
      LEFT JOIN I_ProductDescription AS pd ON ppb~Product = pd~Product AND pd~LanguageISOCode = 'EN'
      INNER JOIN I_Product AS product ON ppb~Product = product~Product AND product~ProductType = 'ZFGC'
      LEFT JOIN I_ProductSupplyPlanning AS psp ON ppb~Product = psp~Product AND ppb~Plant = psp~Plant
      FIELDS ppb~Plant, ppb~Product, pd~ProductDescription, product~ComparisonPriceQuantity, psp~ReorderThresholdQuantity, psp~CompanyCode,
      psp~MaximumStockQuantity ,product~BaseUnit
      WHERE  ppb~Plant = @plantno "AND ppb~product = '000000001400000032'
     INTO TABLE @DATA(ltlines).

      SORT ltlines BY Product.
*     DELETE ADJACENT DUPLICATES FROM LTLINES COMPARING ALL FIELDS.
*delete create_pldatatab where Maximumqty = '0' and Forecastqty = '0' and Minimumqty = '0'
*                          and Overrideqty = '0' and Salesorderqty = '0' and Salestrendqty = '0'
*                          and Suggestedqty = '0'.

      IF ltlines IS NOT INITIAL.

        LOOP AT ltlines INTO DATA(walines).

          DATA wa_zprplanning TYPE zprplanning.

          DATA(lv_matnr) = |{ walines-Product ALPHA = OUT }|.
          CONDENSE lv_matnr.

          SELECT SINGLE FROM ZC_SalesForecastTP AS sftp
          FIELDS sftp~Forecastqty,sftp~Forecastdate
          WHERE sftp~Productcode = @lv_matnr AND sftp~Plant = @walines-Plant AND sftp~Forecastmonth = @lv_date
              INTO @DATA(sftp_fcq).

          maxbillingdate = lv_date - 366.
*          SELECT SINGLE FROM ZC_SalesTrendTP AS sttp
*          FIELDS sttp~Salesqty, sttp~Trenddate , sttp~Quantityunit
**          WHERE sttp~Productcode = @lv_matnr AND sttp~Plant = @walines-Plant AND sttp~Trendmonth = @lv_date
*WHERE sttp~Productcode = @lv_matnr AND sttp~Plant = @walines-Plant AND sttp~Trendmonth >= @lv_date
*              INTO @DATA(sttp_tq).

          SELECT FROM ZC_SalesTrendTP AS sttp FIELDS MAX( Salesqty ) WHERE sttp~Productcode = @lv_matnr AND sttp~Plant = @walines-Plant
          AND sttp~Trendmonth >= @maxbillingdate    INTO @DATA(sttp_tq).

          DATA : order_qty TYPE i_salesdocumentitem-orderquantity.

          SELECT FROM i_salesdocumentitem AS isdi
            FIELDS isdi~orderquantity ,  isdi~product ,isdi~RequestedDeliveryDate
             FOR ALL ENTRIES IN @ltlines
             WHERE isdi~product = @ltlines-product AND isdi~RequestedDeliveryDate BETWEEN @lv_date AND  @todate
              INTO TABLE @DATA(salesqty1).

          LOOP AT salesqty1 INTO DATA(wa) WHERE product = walines-product.
*           AND
*            RequestedDeliveryDate BETWEEN lv_date AND  todate.
            order_qty += wa-orderquantity.
            CLEAR : wa.
          ENDLOOP.

*        READ TABLE salesqty1 INTO DATA(wa) WITH KEY product = walines-product.
*         total_value += wa-ORDERQUANTITY.
*         CLEAr: wa.





          """"""""""""""""""""""""""""""""""""""""""""""""""""""""

*          DATA(lv_max_qty) = walines-MaximumStockQuantity.
*
*          IF sftp_fcq-Forecastqty > lv_max_qty.
*            lv_max_qty = sftp_fcq-Forecastqty.
*          ENDIF.
*          IF sttp_tq > lv_max_qty.
*            lv_max_qty = sttp_tq.
*          ENDIF.
*
*          IF order_qty > lv_max_qty .
*            lv_max_qty = order_qty.
*          ENDIF.

          DATA : lv_max_sugg TYPE p DECIMALS 2.
          DATA : lv_sugg_qty TYPE p DECIMALS 2.

          IF  sttp_tq  > order_qty .
            lv_max_sugg = sttp_tq .
          ELSE.
            lv_max_sugg = order_qty .
          ENDIF.

          lv_max_sugg += sftp_fcq-Forecastqty.

          IF walines-MaximumStockQuantity > lv_max_sugg.
            lv_sugg_qty = walines-MaximumStockQuantity.
          ELSE.
            lv_sugg_qty = lv_max_sugg.
          ENDIF.

          """""""""""""""""""""""""""""""" changes by apratim kanth on 13/05/2025 """""""""""""""""""""

          SELECT SINGLE
          from I_SALESORDERITEM as a
          left join I_SALESORDERSCHEDULELINE as b on a~SalesOrder = b~SalesOrder and a~SalesOrderItem = b~SalesOrderItem
          FIELDS
          SUM( B~REQUESTEDRQMTQTYINBASEUNIT ) AS opensalesorderqty
          where a~Product = @walines-Product
          into @data(lv_opensalesorderqty).


          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



          IF lv_date IS NOT INITIAL.
              IF lv_sugg_qty IS NOT INITIAL.
                IF ls_key-%param-PlanDate IS NOT INITIAL .
                  create_pldata =
                       VALUE #(  %cid      = 'idius'    "ls_key-%cid
                              Bukrs = walines-CompanyCode
                              Plant = walines-Plant
                              planningmonth = lv_date "ls_key-%param-PlanDate
                              Productcode = |{ walines-Product ALPHA = OUT }|
                              Productdesc = walines-ProductDescription
                              Quantityunit = walines-BaseUnit
                              Planningdate = lv_date
                              Minimumqty = walines-ReorderThresholdQuantity
                              Maximumqty = walines-MaximumStockQuantity
                              Salestrendqty =  sttp_tq"-Salesqty "lv_trend  "
                              Forecastqty = sftp_fcq-Forecastqty
                              Salesorderqty = order_qty
                              Suggestedqty = lv_sugg_qty
                              opensalesorderqty = lv_opensalesorderqty
                              Remarks = ''
                              Overrideqty = 0
                                  Closed = 0
                                                      ) .
                  APPEND create_pldata TO create_pldatatab.


                  MODIFY ENTITIES OF ZR_PRPlanningTP IN LOCAL MODE
                                ENTITY PRPlanning
                                CREATE
                                FIELDS ( Bukrs plant planningmonth productcode productdesc quantityunit
                                                planningdate
                                                 minimumqty maximumqty salestrendqty
                                    forecastqty remarks salesorderqty opensalesorderqty suggestedqty overrideqty closed )
                                      WITH create_pldatatab
                                MAPPED   mapped
                                FAILED   failed
                                REPORTED reported.

                ENDIF.
              ENDIF.
          ENDIF.
          "              CLEAR : lv_matnr, lv_max_qty, sttp_tq, sftp_fcq.
**          MODIFY zprplanning FROM @wa_zprplanning.
          CLEAR : create_pldata, create_pldatatab, lv_matnr, lv_sugg_qty, sttp_tq, sftp_fcq ,order_qty .
*          CLEAR : lv_matnr, lv_max_qty, sttp_tq, sftp_fcq.
        ENDLOOP.
*  DELETE LTLINES WHERE Product <> waLINES-Product.

        APPEND VALUE #( %cid = mycid
                            %msg = new_message_with_text(
                                     severity = if_abap_behv_message=>severity-success
                                     text     = 'PR Planning Generated successfully.' )
                  ) TO reported-prplanning.

        RETURN.

      ENDIF.
    ENDLOOP.

    RETURN.
  ENDMETHOD.

  METHOD deletePlanData.

      CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_prplanning' ##NO_TEXT.

    DATA plantno TYPE c LENGTH 4 .
    DATA lv_date TYPE sy-datum.
    DATA create_pldata TYPE STRUCTURE FOR CREATE zr_prplanningtp.
    DATA create_pldatatab TYPE TABLE FOR CREATE zr_prplanningtp.
    DATA insertTag TYPE int1.
    DATA supplytag TYPE int1.
    DATA maxbillingdate TYPE d.

    LOOP AT keys INTO DATA(ls_key).
      TRY.
          plantno = ls_key-%param-PlantNo.
          lv_date = ls_key-%param-PlanDate .

          IF plantno IS INITIAL.
            plantno = ''.
          ENDIF.

          IF plantno = ''.

            APPEND VALUE #( %cid = ls_key-%cid ) TO failed-prplanning.
            APPEND VALUE #( %cid = ls_key-%cid
                            %msg = new_message_with_text(
                                     severity = if_abap_behv_message=>severity-error
                                     text     = 'Plant cannot be blank.' )
                          ) TO reported-prplanning.
            RETURN.
          ENDIF.

          IF lv_date IS NOT INITIAL.
            DATA(lv_year) = lv_date+0(4).
            DATA(lv_month) = lv_date+4(2).
            DATA(lv_day) = '01'.
            lv_date = |{ lv_year }{ lv_month ALPHA = IN }{ lv_day }|.
            lv_month += 1.

            IF lv_month > 12.
              lv_month = 1.
              lv_year  = lv_year + 1.
            ENDIF.

            DATA(lv_date2) = |{ lv_year }{ lv_month ALPHA = IN }{ lv_day }|.
            SELECT SINGLE FROM zprplanning FIELDS *
            WHERE planningmonth = @lv_date2
            INTO @DATA(wa_prplanning).

            IF wa_prplanning IS NOT INITIAL.

              APPEND VALUE #( %cid = ls_key-%cid ) TO failed-prplanning.
              APPEND VALUE #( %cid = ls_key-%cid
                              %msg = new_message_with_text(
                                       severity = if_abap_behv_message=>severity-error
                                       text     = 'Planning data already generated for the next Month.' )
                            ) TO reported-prplanning.
              RETURN.
            ENDIF.
          ENDIF.

          TRANSLATE plantno TO UPPER CASE.

          SELECT SINGLE FROM I_ProductPlantBasic FIELDS Plant
          WHERE Plant = @plantno
          INTO @DATA(lv_plant).

*          DELETE FROM zprplanning
*          WHERE Plant = @lv_plant AND Productcode = @lv_matnr AND Planningmonth = @ls_key-%param-PlanDate .


          IF lv_plant IS INITIAL.
            APPEND VALUE #( %cid = ls_key-%cid ) TO failed-prplanning.
            APPEND VALUE #( %cid = ls_key-%cid
                            %msg = new_message_with_text(
                                     severity = if_abap_behv_message=>severity-error
                                     text     = 'Plant is not found in DB.' )
                          ) TO reported-prplanning.
            RETURN.
          ENDIF.
      ENDTRY.

      "delete planning data
      DATA: it_instance_d TYPE TABLE FOR DELETE ZR_PRPlanningTP.

      SELECT FROM zprplanning FIELDS planningmonth, plant
      WHERE plant = @plantno AND planningmonth = @lv_date
      INTO TABLE @DATA(it_delete_tab) UP TO 1 ROWS.


      LOOP AT it_delete_tab INTO DATA(wa_prplanning2).

        SELECT FROM zprplanning
          FIELDS bukrs, plant, planningmonth, productcode
          WHERE plant = @wa_prplanning2-Plant AND planningmonth = @wa_prplanning2-Planningmonth
          INTO TABLE @DATA(it_prplanning_del_tab).
        LOOP AT it_prplanning_del_tab INTO DATA(wa_prplanning_del_tab).
          it_instance_d = VALUE #( (
                                      Bukrs         = wa_prplanning_del_tab-Bukrs
                                      Plant         = wa_prplanning_del_tab-Plant
                                      Planningmonth = wa_prplanning_del_tab-Planningmonth
                                      Productcode   = wa_prplanning_del_tab-Productcode
                                    ) ).

          MODIFY ENTITIES OF ZR_PRPlanningTP IN LOCAL MODE
            ENTITY PRPlanning
            DELETE FROM it_instance_d
            FAILED failed
            REPORTED reported.

          CLEAR wa_prplanning_del_tab.
        ENDLOOP.

*        COMMIT ENTITIES
        CLEAR wa_prplanning2.
      ENDLOOP.

      "delete planning data end






    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
