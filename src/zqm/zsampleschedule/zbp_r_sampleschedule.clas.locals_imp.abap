CLASS LHC_ZR_SAMPLESCHEDULE DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZrSampleschedule
        RESULT result,
      createSampleSchedule FOR MODIFY
            IMPORTING keys FOR ACTION ZrSampleschedule~createSampleSchedule RESULT result.
ENDCLASS.

CLASS LHC_ZR_SAMPLESCHEDULE IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

  METHOD createSampleSchedule.
    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_prplanning' ##NO_TEXT.

    DATA batch TYPE char13.
    DATA storagelocation TYPE char13.
    DATA plant TYPE char05.
    DATA product TYPE char72.
    DATA testnum TYPE int1.
    DATA numberoftests TYPE int1.
    DATA scheduledate TYPE d.
    DATA addmonths TYPE int1.

    DATA create_sampledata TYPE STRUCTURE FOR CREATE zr_sampleschedule.
    DATA create_sampledatatab TYPE TABLE FOR CREATE zr_sampleschedule.

    LOOP AT keys INTO DATA(ls_key).
        TRY.
            batch = ls_key-%param-BatchNo.
            if batch = ''.
              APPEND VALUE #( %cid = ls_key-%cid ) TO failed-zrsampleschedule.
              APPEND VALUE #( %cid = ls_key-%cid
                              %msg = new_message_with_text(
                                       severity = if_abap_behv_message=>severity-error
                                       text     = 'Batch No. cannot be blank.' )
                            ) TO reported-zrsampleschedule.
              RETURN.
            ENDIF.

            storagelocation = ls_key-%param-StorageLocation .
            if storagelocation = ''.
              APPEND VALUE #( %cid = ls_key-%cid ) TO failed-zrsampleschedule.
              APPEND VALUE #( %cid = ls_key-%cid
                              %msg = new_message_with_text(
                                       severity = if_abap_behv_message=>severity-error
                                       text     = 'Storage Location cannot be blank.' )
                            ) TO reported-zrsampleschedule.
              RETURN.
            ENDIF.

            plant = ls_key-%param-PlantNo .
            if plant = ''.
              APPEND VALUE #( %cid = ls_key-%cid ) TO failed-zrsampleschedule.
              APPEND VALUE #( %cid = ls_key-%cid
                              %msg = new_message_with_text(
                                       severity = if_abap_behv_message=>severity-error
                                       text     = 'Plant cannot be blank.' )
                            ) TO reported-zrsampleschedule.
              RETURN.
            ENDIF.

            product = ls_key-%param-Productcode.
            product = |{ product  WIDTH = 18 ALIGN = RIGHT  PAD = '0' }|.

            if product = ''.
              APPEND VALUE #( %cid = ls_key-%cid ) TO failed-zrsampleschedule.
              APPEND VALUE #( %cid = ls_key-%cid
                              %msg = new_message_with_text(
                                       severity = if_abap_behv_message=>severity-error
                                       text     = 'Product cannot be blank.' )
                            ) TO reported-zrsampleschedule.
              RETURN.
            ENDIF.

            SELECT SINGLE FROM ZR_ProductAll_VH as prod
                  FIELDS Product
                  WHERE prod~Product = @product OR prod~ProductAlias = @product
                  INTO @DATA(productid).
            product = productid.

            SELECT FROM zr_sampleschedule as ss
              FIELDS TESTNUM
            WHERE ss~Plant = @plant and ss~Storagelocation = @storagelocation
              and ss~Productcode = @product and ss~Batch = @batch
              INTO TABLE @DATA(ltcheck).
            IF ltcheck IS NOT INITIAL.
                APPEND VALUE #( %cid = ls_key-%cid ) TO failed-zrsampleschedule.
                APPEND VALUE #( %cid = ls_key-%cid
                                %msg = new_message_with_text(
                                       severity = if_abap_behv_message=>severity-error
                                       text     = 'Sample schedules are already created.' )
                                ) TO reported-zrsampleschedule.
                RETURN.
            ENDIF.

        CATCH cx_root INTO DATA(lx_root).
"            RAISE EXCEPTION lx_root.
            APPEND VALUE #( %cid = ls_key-%cid
                              %msg = new_message_with_text(
                                       severity = if_abap_behv_message=>severity-error
                                       text     = 'Batch No. cannot be blank.' )
                            ) TO reported-zrsampleschedule.

        ENDTRY.

        SELECT FROM I_InspectionLot AS il
            FIELDS  il~InspectionLotStartDate
        WHERE  il~Plant = @plant AND il~BatchStorageLocation = @storagelocation
            and il~Material = @product and il~Batch = @batch
            and il~InspectionLotOrigin = '05'
        INTO TABLE @DATA(ltlines).

        SORT LTLINES BY InspectionLotStartDate.

        IF ltlines IS INITIAL.
            APPEND VALUE #( %cid = ls_key-%cid ) TO failed-zrsampleschedule.
            APPEND VALUE #( %cid = ls_key-%cid
                            %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = 'First Sample Testing not started.' )
                            ) TO reported-zrsampleschedule.
            RETURN.
        ELSE.
            LOOP AT ltlines INTO DATA(walines).

                scheduledate = walines-InspectionLotStartDate.
                testnum = 0.
                IF storagelocation = '0009' OR storagelocation = '0011'.
                    numberoftests = 10.
                ELSE.
                    numberoftests = 4.
                ENDIF.

                SELECT SINGLE FROM ZR_ProductAll_VH as prod
                  FIELDS ProductDescription
                  WHERE prod~Product = @product
                  INTO @DATA(productdesc).

                "Loop for counters
                WHILE numberoftests <> 0.
                    numberoftests = numberoftests - 1.
                    testnum = testnum + 1.

                    addmonths = 0.
                    CASE testnum.
                        WHEN 1.
                            scheduledate = scheduledate.
                        WHEN 2.
                            addmonths = 1.
                        WHEN 3.
                            addmonths = 2.
                        WHEN 4.
                            addmonths = 3.
                        WHEN 5.
                            addmonths = 3.
                        WHEN 6.
                            addmonths = 3.
                        WHEN 7.
                            addmonths = 6.
                        WHEN 8.
                            addmonths = 6.
                        WHEN 9.
                            addmonths = 12.
                        WHEN 10.
                            addmonths = 12.
                    ENDCASE.

                    IF addmonths > 0.
                        SELECT FROM I_CalendarDate as cs
                          FIELDS dats_add_months( @scheduledate, @addmonths ) as sdate
                          WHERE cs~CalendarDate = @scheduledate
                        INTO TABLE @DATA(ltdate).

                        LOOP AT ltdate INTO DATA(wadate).
                            scheduledate = wadate-sdate.
                        ENDLOOP.
                    ENDIF.

                    create_sampledata =
                       VALUE #(  %cid      = 'idius'    "ls_key-%cid
                              Plant = plant
                              Storagelocation = storagelocation
                              Productcode = product
                              Batch = batch
                              Testnum = testnum
                              Productdesc = productdesc
                              Scheduledate = scheduledate
                              Remarks = ''
                              ) .
                    APPEND create_sampledata TO create_sampledatatab.

                    MODIFY ENTITIES OF zr_sampleschedule IN LOCAL MODE
                        ENTITY ZrSampleschedule
                        CREATE
                        FIELDS ( plant Storagelocation Productcode Batch Testnum Productdesc Scheduledate Remarks )
                              WITH create_sampledatatab
                        MAPPED   mapped
                        FAILED   failed
                        REPORTED reported.


                    CLEAR : create_sampledata, create_sampledatatab.
                ENDWHILE.


                APPEND VALUE #( %cid = ls_key-%cid
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-success
                        text     = 'Sample Scheduled Generated successfully.' )
                        ) TO reported-zrsampleschedule.

                RETURN.
            ENDLOOP.
        ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
