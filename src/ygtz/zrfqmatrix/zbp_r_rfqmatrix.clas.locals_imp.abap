CLASS lhc_RFQMatrix DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR RFQMatrix RESULT result.
    METHODS createRFQData FOR MODIFY
      IMPORTING keys FOR ACTION rfqmatrix~createRFQData RESULT result.

    METHODS markSupply FOR MODIFY
      IMPORTING keys FOR ACTION rfqmatrix~markSupply.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR rfqmatrix RESULT result.

    METHODS deleteRFQ FOR MODIFY
      IMPORTING keys FOR ACTION rfqmatrix~deleteRFQ RESULT result.
    METHODS createSupplierQuote FOR MODIFY
      IMPORTING keys FOR ACTION rfqmatrix~createSupplierQuote RESULT result.
    METHODS printComparison FOR MODIFY
      IMPORTING keys FOR ACTION rfqmatrix~printComparison RESULT result .
    METHODS sendToSupplier FOR MODIFY
      IMPORTING keys FOR ACTION rfqmatrix~sendToSupplier.
    METHODS createRFQDataPIR FOR MODIFY
      IMPORTING keys FOR ACTION rfqmatrix~createRFQDataPIR RESULT result.
    METHODS updateRFQ FOR MODIFY
      IMPORTING keys FOR ACTION rfqmatrix~updateRFQ RESULT result.
    METHODS publishRFQ FOR MODIFY
      IMPORTING keys FOR ACTION rfqmatrix~publishRFQ RESULT result.

ENDCLASS.

CLASS lhc_RFQMatrix IMPLEMENTATION.


  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD createRFQData.

    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_rfqmatrix' ##NO_TEXT.

    DATA rfqno TYPE char13 .
    DATA create_rfqmatrix TYPE STRUCTURE FOR CREATE ZR_RFQMatrix.
    DATA create_rfqtab TYPE TABLE FOR CREATE ZR_RFQMatrix.
    DATA insertTag TYPE int1.
    DATA supplytag TYPE int1.


    LOOP AT keys INTO DATA(ls_key).

      TRY.
          rfqno = ls_key-%param-RFQNo.

          IF rfqno = ''.
            APPEND VALUE #( %cid = ls_key-%cid ) TO failed-rfqmatrix.
            APPEND VALUE #( %cid = ls_key-%cid
                            %msg = new_message_with_text(
                                     severity = if_abap_behv_message=>severity-error
                                     text     = 'RFQ No. cannot be blank.' )
                          ) TO reported-rfqmatrix.
            RETURN.
          ENDIF.

*        CATCH .
*          APPEND VALUE #( %cid = ls_key-%cid ) TO failed-rfqmatrix.
*          APPEND VALUE #( %cid = ls_key-%cid
*                          %msg = new_message_with_text(
*                                   severity = if_abap_behv_message=>severity-error
*                                   text     = fill_node_object_exception->get_text( ) )
*                        ) TO reported-rfqmatrix.
*          RETURN.

      ENDTRY.

      SELECT FROM zrfqmatrix
        FIELDS requestforquotation
        WHERE zrfqmatrix~requestforquotation = @rfqno
            INTO TABLE @DATA(ltcheck).
      IF ltcheck IS NOT INITIAL.
        APPEND VALUE #( %cid = ls_key-%cid ) TO failed-rfqmatrix.
        APPEND VALUE #( %cid = ls_key-%cid
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'RFQ Data already generated.' )
                      ) TO reported-rfqmatrix.
        RETURN.
      ENDIF.



      insertTag = 0.

      SELECT FROM I_Requestforquotation_Api01 AS rfq
        JOIN I_RfqBidder_Api01 AS bidder ON rfq~RequestForQuotation = bidder~RequestForQuotation
        JOIN I_RfqItem_Api01 AS lines ON bidder~RequestForQuotation = lines~RequestForQuotation
        JOIN I_RfqScheduleLine_Api01 AS sch ON bidder~RequestForQuotation = sch~RequestForQuotation AND lines~RequestForQuotationItem = sch~RequestForQuotationItem
        JOIN I_ProductDescription AS pd ON lines~Material = pd~Product AND pd~LanguageISOCode = 'EN'
        LEFT JOIN i_supplier AS supplier ON supplier~supplier = bidder~Supplier
        FIELDS rfq~CompanyCode, rfq~RequestForQuotation, rfq~RFQPublishingDate, bidder~Supplier, lines~RequestForQuotationItem, lines~Material,
            sch~OrderQuantityUnit, sch~ScheduleLineOrderQuantity, sch~ScheduleLine, pd~ProductDescription, supplier~SupplierFullName
        WHERE rfq~RequestForQuotation = @rfqno
           INTO TABLE @DATA(ltlines).

      LOOP AT ltlines INTO DATA(walines).
        IF walines-RFQPublishingDate = '00000000'.
          APPEND VALUE #( %cid = ls_key-%cid ) TO failed-rfqmatrix.
          APPEND VALUE #( %cid = ls_key-%cid
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = 'RFQ is not published.' )
                        ) TO reported-rfqmatrix.
          RETURN.
        ENDIF.

        supplytag = 0.
        SELECT FROM I_MPPurchasingSourceItem AS sourcelist
        FIELDS sourcelist~Plant
        WHERE sourcelist~Material = @walines-Material AND sourcelist~Supplier = @walines-Supplier
          AND sourcelist~ValidityStartDate <= @walines-RFQPublishingDate
          AND ( sourcelist~ValidityEndDate = '00000000' OR sourcelist~ValidityEndDate >= @walines-RFQPublishingDate )
        INTO TABLE @DATA(ltsource).
        IF ltsource IS NOT INITIAL.
          supplytag = 1.
        ENDIF.

        SELECT SINGLE  FROM I_Businesspartner AS bp
        LEFT JOIN I_BusinessPartnerTypeText AS bptt ON bp~BusinessPartnerType = bptt~BusinessPartnerType AND bptt~Language = 'E'
        FIELDS bp~businesspartner, bp~BusinessPartnerType, bptt~BusinessPartnerTypeDesc
        WHERE bp~BusinessPartner = @walines-Supplier
            INTO @DATA(bp_type).

        SELECT SINGLE FROM I_BuPaIdentification AS bpif
        FIELDS bpif~BPIdentificationType, bpif~Region
        WHERE bpif~BusinessPartner = @walines-Supplier
            INTO @DATA(bpif_Aadhar).

        SELECT SINGLE FROM I_Suppliercompany AS sc
        FIELDS sc~SupplierCertificationDate, sc~SupplierHeadOffice
        WHERE sc~Supplier = @walines-Supplier
            INTO @DATA(sc_SCD).


*        SELECT SINGLE FROM yy1_BusinessPartnerSuplDex as bpsd
*        FIELDS bpsd~TitleSupplier, bpsd~Supplier
*        WHERE bpsd~Supplier = @walines-Supplier
*            INTO @data(bpsd_Sup).
*


        create_rfqmatrix = VALUE #( %cid      = ls_key-%cid
                                    Bukrs = walines-CompanyCode
                                    Requestforquotation = walines-RequestForQuotation
                                    Vendorcode = walines-Supplier
                                    Productcode = walines-Material
                                    Scheduleline = walines-ScheduleLine
                                    Supplierquotationitem = walines-RequestForQuotationItem
                                    Productdesc = walines-ProductDescription
                                    Vendorname = walines-SupplierFullName
                                    Producttradename = ''
                                    Remarks = ''
                                    Orderquantity = walines-ScheduleLineOrderQuantity
                                    Orderquantityunit = walines-OrderQuantityUnit
                                    Vendortype = ''
                                    Majoractivity = bp_type-BusinessPartnerTypeDesc
                                    Typeofenterprise = ''
                                    Udyamaadharno = bpif_aadhar-BPIdentificationType
                                    Udyamcertificatedate = sc_SCD-SupplierCertificationDate
                                    Udyamcertificatereceivingdate = ''
                                    Vendorspecialname = ''
                                    Supply = supplytag
                                    Processed = 0
                                            ).
        APPEND create_rfqmatrix TO create_rfqtab.

        MODIFY ENTITIES OF ZR_RFQMatrix IN LOCAL MODE
              ENTITY rfqmatrix
              CREATE FIELDS ( bukrs requestforquotation vendorcode productcode scheduleline supplierquotationitem
                  productdesc vendorname producttradename remarks orderquantity orderquantityunit vendortype
                  majoractivity typeofenterprise udyamaadharno udyamcertificatedate udyamcertificatereceivingdate
                  vendorspecialname supply processed )
                    WITH create_rfqtab
              MAPPED   mapped
              FAILED   failed
              REPORTED reported.

        CLEAR : create_rfqmatrix.
        CLEAR : create_rfqtab.
      ENDLOOP.

      APPEND VALUE #( %cid = ls_key-%cid
                      %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-success
                        text = 'RFQ Data Generated.' )
                        ) TO reported-rfqmatrix.


    ENDLOOP.



  ENDMETHOD.

  METHOD markSupply.
    READ ENTITIES OF ZR_RFQMatrix IN LOCAL MODE
      ENTITY rfqmatrix
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(rfqmatrix)
      FAILED failed.

    SORT rfqmatrix BY Supply DESCENDING.
    LOOP AT rfqmatrix ASSIGNING FIELD-SYMBOL(<lfs_rfqmatrix>).
      IF <lfs_rfqmatrix>-Supply = 0.
        <lfs_rfqmatrix>-Supply = 1.
      ELSE.
        <lfs_rfqmatrix>-Supply = 0.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF ZR_RFQMatrix IN LOCAL MODE
      ENTITY rfqmatrix
      UPDATE FIELDS ( Supply ) WITH CORRESPONDING #( rfqmatrix ).


    APPEND VALUE #( %tky = <lfs_rfqmatrix>-%tky
                    %msg = new_message_with_text(
                      severity = if_abap_behv_message=>severity-success
                      text = 'Supply Marked.' )
                      ) TO reported-rfqmatrix.


  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF ZR_RFQMatrix IN LOCAL MODE
      ENTITY rfqmatrix
      FIELDS ( Requestforquotation Productcode Supplierquotationitem Vendorcode Scheduleline Supply ) WITH CORRESPONDING #( keys )
      RESULT DATA(rfqdata)
      FAILED failed.

    result = VALUE #(
      FOR rfqline IN rfqdata
      LET statusval = COND #( WHEN rfqline-Supply = 1
                              THEN if_abap_behv=>fc-o-disabled
                              ELSE if_abap_behv=>fc-o-enabled )

                              IN ( %tky = rfqline-%tky
                                   %action-deleteRFQ = statusval )

      ).

  ENDMETHOD.

  METHOD deleteRFQ.
    DATA: it_instance_d TYPE TABLE FOR DELETE ZR_RFQMatrix.


    READ ENTITIES OF ZR_RFQMatrix IN LOCAL MODE
      ENTITY rfqmatrix
      FIELDS ( Bukrs Requestforquotation Productcode Supplierquotationitem Vendorcode Scheduleline Supply ) WITH CORRESPONDING #( keys )
      RESULT DATA(rfqdata)
      FAILED failed.

    LOOP AT rfqdata INTO DATA(rfqline).
      IF rfqline-Requestforquotation <> ''.
        SELECT FROM zrfqmatrix
          FIELDS requestforquotation, supply
          WHERE requestforquotation = @rfqline-Requestforquotation AND supply = 1
          INTO TABLE @DATA(ltrfqcheck).
        IF ltrfqcheck IS NOT INITIAL.
          APPEND VALUE #( %tky = rfqline-%tky ) TO failed-rfqmatrix.

          APPEND VALUE #( %tky = keys[ 1 ]-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text = 'Supply is marked, cannot delete.'
                        ) ) TO reported-rfqmatrix.
          RETURN.
        ENDIF.

        SELECT FROM zrfqmatrix
          FIELDS Bukrs, Requestforquotation, Productcode, Supplierquotationitem, Vendorcode, Scheduleline
          WHERE requestforquotation = @rfqline-Requestforquotation
          INTO TABLE @DATA(ltrfqdelete).
        LOOP AT ltrfqdelete INTO DATA(walines).
          it_instance_d = VALUE #( ( Bukrs = walines-bukrs
                                    Requestforquotation = walines-Requestforquotation
                                    Productcode = walines-Productcode
                                    Supplierquotationitem = walines-Supplierquotationitem
                                    Vendorcode = walines-Vendorcode
                                    Scheduleline = walines-Scheduleline
                                    ) ).

          MODIFY ENTITIES OF ZR_RFQMatrix IN LOCAL MODE
            ENTITY rfqmatrix
            DELETE FROM it_instance_d
            FAILED failed
            REPORTED reported.
        ENDLOOP.

        APPEND VALUE #( %tky = rfqline-%tky
                    %msg = new_message_with_text(
                      severity = if_abap_behv_message=>severity-success
                      text = 'RFQ Data Deleted.' )
                      ) TO reported-rfqmatrix.

*        COMMIT ENTITIES
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD createSupplierQuote.

    DATA: it_instance_d TYPE TABLE FOR DELETE ZR_RFQMatrix.
    DATA: recordfound TYPE string VALUE ' '.
    DATA intgpath TYPE string VALUE ''.


    READ ENTITIES OF ZR_RFQMatrix IN LOCAL MODE
      ENTITY rfqmatrix
      FIELDS ( Bukrs Requestforquotation Productcode Supplierquotationitem Vendorcode Scheduleline Supply ) WITH CORRESPONDING #( keys )
      RESULT DATA(rfqdata)
      FAILED failed.

    LOOP AT rfqdata INTO DATA(rfqline).
      IF rfqline-Requestforquotation <> ''.
        SELECT FROM zrfqmatrix
          FIELDS requestforquotation, processed
          WHERE requestforquotation = @rfqline-Requestforquotation AND processed = 1
          INTO TABLE @DATA(ltrfqcheck).
        IF ltrfqcheck IS NOT INITIAL.
          APPEND VALUE #( %tky = rfqline-%tky ) TO failed-rfqmatrix.

          APPEND VALUE #( %tky = keys[ 1 ]-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text = 'RFQ is already processed, cannot create Quote.'
                        ) ) TO reported-rfqmatrix.
          RETURN.
        ENDIF.

        SELECT SINGLE 'X' FROM zrfqmatrix
          WHERE requestforquotation = @rfqline-Requestforquotation
          INTO (@recordfound).
        IF sy-subrc = 0.
          IF recordfound = 'X'.

            SELECT SINGLE FROM zintegration
              FIELDS IntgPath
              WHERE IntgModule = 'RFQQUOTE'
              INTO ( @intgpath ).

            DATA rfqvalue TYPE string VALUE IS INITIAL.
*            DATA rfq_url TYPE string VALUE 'https://myapp-balanced-hyena-qz.cfapps.us10-001.hana.ondemand.com/SQFromRFQ' .
*            DATA(url) = |{ rfq_url }|.
            DATA(url) = |{ intgpath }|.
            TRY.
                DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
              CATCH cx_http_dest_provider_error INTO DATA(lv_cx_http_dest_error).
                APPEND VALUE #( %tky = rfqline-%tky
                     %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-error
                       text = lv_cx_http_dest_error->get_text( ) )
                       ) TO reported-rfqmatrix.
            ENDTRY.
            TRY.
                DATA(client) = cl_web_http_client_manager=>create_by_http_destination( dest ).
              CATCH cx_web_http_client_error INTO DATA(lv_CX_WEB_HTTP_CLIENT_ERROR).
                APPEND VALUE #( %tky = rfqline-%tky
                      %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text = lv_CX_WEB_HTTP_CLIENT_ERROR->get_text( ) )
                        ) TO reported-rfqmatrix.
            ENDTRY.
            DATA(req) = client->get_http_request(  ).
            req->set_content_type( 'application/json' ).
            CONCATENATE '{"RFQ":"' rfqline-Requestforquotation '" }' INTO rfqvalue.
            "           req->set_text( '{ "RFQ":"7000000033" }' ) .
            req->set_text( rfqvalue ) .

            DATA: retresponse TYPE string.
            DATA lr_exc TYPE REF TO cx_root.
            TRY.
                retresponse = client->execute( if_web_http_client=>post )->get_text( ).
*              CATCH cx_web_http_client_error cx_web_message_error.
              CATCH cx_root INTO lr_exc.
                APPEND VALUE #( %tky = rfqline-%tky
                    %msg = new_message_with_text(
                      severity = if_abap_behv_message=>severity-error
                      text = lr_exc->get_text( ) )
                      ) TO reported-rfqmatrix.
            ENDTRY.

            REPLACE '' WITH '"message": "Internal Server Error",' INTO retresponse.
            CONCATENATE 'Supplier Quote created. ' retresponse INTO retresponse.
            APPEND VALUE #( %tky = rfqline-%tky
                    %msg = new_message_with_text(
                      severity = if_abap_behv_message=>severity-success
                      text = retresponse )
                      ) TO reported-rfqmatrix.

          ENDIF.
        ENDIF.


*        COMMIT ENTITIES
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD printComparison.

    DATA quatationvalue TYPE string .
    READ ENTITIES OF ZR_RFQMatrix IN LOCAL MODE
     ENTITY rfqmatrix
      FIELDS ( Requestforquotation )
     WITH CORRESPONDING #( keys )
     RESULT DATA(quotation)
     FAILED failed.
    LOOP AT quotation INTO DATA(wa).
      quatationvalue = wa-Requestforquotation.
    ENDLOOP.


    IF quatationvalue IS NOT INITIAL.
*              DATA(pdf) = zcl_rfq_print=>read_posts( rfq_num = quatationvalue ).
*              DATA(html) = |<html> | &&
*                             |<body> | &&
*                               | <iframe src="data:application/pdf;base64,{ pdf }" width="100%" height="100%"></iframe>| &&
*                             | </body> | &&
*                           | </html>|.

*             result = html.

    ENDIF.

  ENDMETHOD.

  METHOD sendToSupplier.

    DATA lt_failed TYPE TABLE OF bapiret2.


    READ ENTITIES OF zr_rfqmatrix IN LOCAL MODE
      ENTITY rfqmatrix
      FIELDS ( Bukrs Requestforquotation Vendorcode Productcode Scheduleline Supplierquotationitem Vendorname Productdesc Producttradename Remarks Orderquantity Orderquantityunit Vendortype Majoractivity Typeofenterprise Udyamaadharno
Udyamcertificatedate Udyamcertificatereceivingdate Vendorspecialname Supply Processed CreatedBy CreatedAt LastChangedBy LastChangedAt LocalLastChangedAt )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_rfqdata)
      FAILED failed.


    IF lt_rfqdata IS NOT INITIAL.
      READ TABLE lt_rfqdata INTO DATA(ls_rfqdata) INDEX 1.

      SELECT FROM zrfqmatrix FIELDS vendorname, vendortype, vendorcode, requestforquotation, udyamaadharno,
      typeofenterprise
   WHERE requestforquotation = @ls_rfqdata-Requestforquotation AND vendorcode = @ls_rfqdata-Vendorcode
   INTO TABLE @DATA(it) UP TO 1 ROWS.

      READ TABLE it INTO DATA(wa) INDEX 1.

      SELECT FROM zrfqmatrix FIELDS requestforquotation, productcode, productdesc, orderquantity, orderquantityunit, vendorcode,
      supply
      WHERE requestforquotation = @ls_rfqdata-Requestforquotation AND vendorcode = @ls_rfqdata-Vendorcode
*      ORDER BY requestforquotation
      INTO TABLE @DATA(it2).

      SELECT SINGLE FROM i_requestforquotation_api01 FIELDS LatestRegistrationDate
      WHERE RequestForQuotation = @ls_rfqdata-Requestforquotation
      INTO @DATA(lv_reg_date).

      """""" added by apratim """"""""""""""""""
*      DATA(lv_formatted_date2) = lv_reg_date(4) && '-' && lv_reg_date+4(2) && '-' && lv_reg_date+6(2).
      DATA: lv_formatted_date2 TYPE string.
      lv_formatted_date2 = lv_reg_date+6(2).
      CONCATENATE lv_formatted_date2 '-' lv_reg_date+4(2) '-' lv_reg_date(4) INTO lv_formatted_date2.
      CONDENSE lv_formatted_date2.



      """"""""""""""""""""""""

      SELECT FROM I_Supplier WITH PRIVILEGED ACCESS FIELDS BusinessPartnerName1, BusinessPartnerName2, TaxNumber3, AddressID
      WHERE Supplier = @ls_rfqdata-Vendorcode
      INTO TABLE @DATA(it_s).


      READ TABLE it_s INTO DATA(wa_s) INDEX 1.

      IF wa_s IS NOT INITIAL.
        SELECT SINGLE FROM i_address_2 WITH PRIVILEGED ACCESS
        FIELDS streetname, StreetPrefixName1, StreetPrefixName2, CityName, PostalCode, DistrictName, Country
        WHERE AddressID = @wa_s-AddressID
        INTO @DATA(wa_addr).

        SELECT FROM I_AddressEmailAddress_2 WITH PRIVILEGED ACCESS
        FIELDS EmailAddress
        WHERE AddressID = @wa_s-AddressID
        INTO TABLE @DATA(lt_email).

      ENDIF.

      DATA wa_email_sender TYPE c LENGTH 512.
      SELECT SINGLE FROM zintegration FIELDS intgpath
      WHERE intgmodule = 'RFQMAIL'
      INTO @wa_email_sender.

      DATA wa_email_sendercc TYPE c LENGTH 512.
      SELECT SINGLE FROM zintegration FIELDS intgpath
      WHERE intgmodule = 'RFQMAILCC'
      INTO @wa_email_sendercc.

      SELECT SINGLE FROM zmsme_table
      FIELDS vendortype
      WHERE vendorno = @ls_rfqdata-Vendorcode
      INTO @DATA(lv_vendortype).

      """""""" added by apratim """""""""""""""""
      SELECT SINGLE FROM
      zmsme_table AS a
      FIELDS
      a~certificateno,
      a~validfrom
      WHERE a~vendorno = @ls_rfqdata-Vendorcode
      INTO @DATA(lv_uan).

      DATA: lv_valid_date TYPE string.
      lv_valid_date = lv_uan-validfrom+6(2).
      CONCATENATE lv_valid_date '-' lv_uan-validfrom+4(2) '-' lv_uan-validfrom(4) INTO lv_valid_date.
      CONDENSE lv_valid_date.

      """"""""""""""""""""""""""""

      DATA : counter TYPE i VALUE 1.

      IF lv_valid_date = '00-00-0000'.
        CLEAR lv_valid_date.
      ENDIF.

      IF sy-subrc = 0.
        DATA(lv_email_body) = |<p>To,{ wa_s-BusinessPartnerName1 } { wa_s-BusinessPartnerName2 }</p>| &&
        "|<p>To,{ wa-vendorname }</p><br>| &&
           |<p>Address - { wa_addr-StreetName } { wa_addr-StreetPrefixName1 } { wa_addr-StreetPrefixName2 } { wa_addr-CityName } { wa_addr-PostalCode } { wa_addr-DistrictName } { wa_addr-Country }</p>| &&
           |<p>GST No -{ wa_s-TaxNumber3 }</p>| &&
           |<p>Udyam Aadhar No - { lv_uan-certificateno }</p>| &&    """" added by apratim
           |<p>UAN Certificate Date - { lv_valid_date }</p>| &&      """" added by apratim
           |<p>Vendor Type - { lv_vendortype }</p>| &&
*           |<p>Udyam Aadhar No -{ wa-udyamaadharno  }</p><br>| &&
*           |<p>UAN Certificate Date -</p><br>| &&
*           |<p>Type of Enterprise - { wa-typeofenterprise } </p><br><br>| &&
           |<p>Dear Vendor,<br></p>| &&
           |<p>This is to inform you that we are transforming our business operation through SAP Public Cloud from the Financial Year 2025-2026 onwards.</p>| &&
           |<p>Therefore our earlier Supplier Portal is not operational at this moment.</p>| &&
           |<p>Please send your quotation along with Pack Size/Packing Mode, Origin, HSN Code, GST%, Terms, Availability etc for the following Materials by E Mail</p>|.
*           |<p>This is to inform you that new RFQ (Request for Quotation) upload in system.<br></p>| &&
*           |<p>You are requested to send us your offer along with Pack Size/Packing Mode, Origin,| &&
*           |<p>HSN Code, GST%, terms, availability etc. for following products-</p><br>|.

*        SORT it2 BY requestforquotation.
        DATA: supply_flag TYPE string.
        supply_flag = '0'.

        LOOP AT it2 INTO DATA(wa2) WHERE supply > '0'.

          SELECT SINGLE FROM i_purchasinginforecordapi01
          FIELDS YY1_VendorSpecialName_SOS
          WHERE Supplier = @wa2-vendorcode AND Material = @wa2-productcode
          INTO @DATA(lv_VendorSpecialName_SOS).

          lv_email_body = | { lv_email_body } <p>{ counter }) { lv_VendorSpecialName_SOS }-{ wa2-orderquantity } { wa2-orderquantityunit }</p>|.

          counter = counter + 1.
          IF wa2-supply > '0'.
            supply_flag = '1'.
          ENDIF.
          CLEAR lv_VendorSpecialName_SOS.
        ENDLOOP.   """ edited by apratim

        lv_email_body = lv_email_body && |<p>if your quotation is not received by { lv_formatted_date2 }, your quotation will not consider for our evaluation.</p>| &&
       |<p>Looking forward to your reply at the earliest.</p>| &&
       |<p>Thanks Regards-<br>Purchase Department<br><b>GTZ (India) Pvt. Ltd.</b><br>Khariberia<br>+91 33 2470 6644</p>|.
        " &&
*       |<p>Note: Please check the above details - Your Name, Address, GST No,</p>| &&
*       |<p>UAN, UAN Certificate Date, and Type of Enterprise (as per our system). If there are any changes, please inform us immediately with supporting documents.</p>|.

        IF supply_flag = '1'.
          TRY.
              DATA(lo_mail) = cl_bcs_mail_message=>create_instance( ).

              SELECT SINGLE FROM zintegration FIELDS intgpath
              WHERE intgmodule = 'Custom' INTO @DATA(lv_sys).
              IF lv_sys = sy-sysid.
                lo_mail->set_sender( 'mohammadsohel20@gmail.com' ).
                lo_mail->add_recipient( 'mohammadsohel20@gmail.com' ).
              ELSE.
                lo_mail->set_sender( wa_email_sender ). "wa_email_sender

                LOOP AT lt_email INTO DATA(wa_emailid).
                  DATA lv_email_rx TYPE c LENGTH 512.
                  lv_email_rx = wa_emailid-EmailAddress.
                  lo_mail->add_recipient( lv_email_rx ).
                  CLEAR wa_emailid.
                ENDLOOP.

                lo_mail->add_recipient( wa_email_sendercc ). "CC
              ENDIF.

              lo_mail->set_subject( 'RFQ Details' ).
              lo_mail->set_main( cl_bcs_mail_textpart=>create_instance(
                iv_content      = lv_email_body
                iv_content_type = 'text/html'
              ) ).
              lo_mail->send( IMPORTING et_status = DATA(lt_status) ).

              APPEND VALUE #( %cid = 'qdwef'
             %msg = new_message_with_text(
               severity = if_abap_behv_message=>severity-success
               text = lt_status[ 1 ]-status_response )
               ) TO reported-rfqmatrix.

            CATCH cx_bcs_mail INTO DATA(lx_bcs_mail).
              APPEND VALUE #( %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text = lx_bcs_mail->get_text( ) )
                          ) TO reported-rfqmatrix.
          ENDTRY.
        ENDIF.
      ENDIF.

    ENDIF.
    APPEND VALUE #( %cid = 'qdwef'
             %msg = new_message_with_text(
               severity = if_abap_behv_message=>severity-success
               text = 'Email Sent' )
               ) TO reported-rfqmatrix.
  ENDMETHOD.

  METHOD createRFQDataPIR.
    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_rfqmatrix' ##NO_TEXT.

    DATA rfqno TYPE char13 .
    DATA create_rfqmatrix TYPE STRUCTURE FOR CREATE ZR_RFQMatrix.
    DATA create_rfqtab TYPE TABLE FOR CREATE ZR_RFQMatrix.
    DATA insertTag TYPE int1.
    DATA supplytag TYPE int1.


    LOOP AT keys INTO DATA(ls_key).

      TRY.
          rfqno = ls_key-%param-RFQNo.

          IF rfqno = ''.
            APPEND VALUE #( %cid = ls_key-%cid ) TO failed-rfqmatrix.
            APPEND VALUE #( %cid = ls_key-%cid
                            %msg = new_message_with_text(
                                     severity = if_abap_behv_message=>severity-error
                                     text     = 'RFQ No. cannot be blank.' )
                          ) TO reported-rfqmatrix.
            RETURN.
          ENDIF.

*        CATCH .
*          APPEND VALUE #( %cid = ls_key-%cid ) TO failed-rfqmatrix.
*          APPEND VALUE #( %cid = ls_key-%cid
*                          %msg = new_message_with_text(
*                                   severity = if_abap_behv_message=>severity-error
*                                   text     = fill_node_object_exception->get_text( ) )
*                        ) TO reported-rfqmatrix.
*          RETURN.

      ENDTRY.

      SELECT FROM zrfqmatrix
        FIELDS requestforquotation
        WHERE zrfqmatrix~requestforquotation = @rfqno
            INTO TABLE @DATA(ltcheck).
      IF ltcheck IS NOT INITIAL.
        APPEND VALUE #( %cid = ls_key-%cid ) TO failed-rfqmatrix.
        APPEND VALUE #( %cid = ls_key-%cid
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'RFQ Data already generated.' )
                      ) TO reported-rfqmatrix.
        RETURN.
      ENDIF.



      insertTag = 0.

      SELECT FROM I_Requestforquotation_Api01 AS rfq
        JOIN I_RfqItem_Api01 AS lines ON rfq~RequestForQuotation = lines~RequestForQuotation
        JOIN I_RfqScheduleLine_Api01 AS sch ON rfq~RequestForQuotation = sch~RequestForQuotation AND lines~RequestForQuotationItem = sch~RequestForQuotationItem
        JOIN I_ProductDescription AS pd ON lines~Material = pd~Product AND pd~LanguageISOCode = 'EN'
        FIELDS rfq~CompanyCode, rfq~RequestForQuotation, rfq~RFQPublishingDate, lines~RequestForQuotationItem, lines~Material, lines~Plant,
            sch~OrderQuantityUnit, sch~ScheduleLineOrderQuantity, sch~ScheduleLine, pd~ProductDescription
        WHERE rfq~RequestForQuotation = @rfqno
           INTO TABLE @DATA(ltlines).

      LOOP AT ltlines INTO DATA(walines).
        "To be published after this process
*        IF walines-RFQPublishingDate = '00000000'.
*          APPEND VALUE #( %cid = ls_key-%cid ) TO failed-rfqmatrix.
*          APPEND VALUE #( %cid = ls_key-%cid
*                          %msg = new_message_with_text(
*                                   severity = if_abap_behv_message=>severity-error
*                                   text     = 'RFQ is not published.' )
*                        ) TO reported-rfqmatrix.
*          RETURN.
*        ENDIF.

        supplytag = 0.
        SELECT FROM I_MPPurchasingSourceItem AS sourcelist
        FIELDS sourcelist~Supplier
        WHERE sourcelist~Material = @walines-Material AND sourcelist~Plant = @walines-Plant
          AND sourcelist~ValidityStartDate <= @sy-datum
          AND ( sourcelist~ValidityEndDate = '00000000' OR sourcelist~ValidityEndDate >= @sy-datum )
        INTO TABLE @DATA(ltsource).
        LOOP AT ltsource INTO DATA(wasource).

          SELECT SINGLE  FROM I_Businesspartner AS bp
          LEFT JOIN I_BusinessPartnerTypeText AS bptt ON bp~BusinessPartnerType = bptt~BusinessPartnerType AND bptt~Language = 'E'
          FIELDS bp~businesspartner, bp~BusinessPartnerType, bptt~BusinessPartnerTypeDesc
          WHERE bp~BusinessPartner = @wasource-Supplier
              INTO @DATA(bp_type).

*          SELECT SINGLE FROM I_BuPaIdentification AS bpif
*          FIELDS bpif~BPIdentificationType, bpif~Region
*          WHERE bpif~BusinessPartner = @wasource-Supplier
*              INTO @DATA(bpif_Aadhar).

*          SELECT SINGLE FROM I_Suppliercompany AS sc
*          FIELDS sc~SupplierCertificationDate, sc~SupplierHeadOffice
*          WHERE sc~Supplier = @wasource-Supplier
*              INTO @DATA(sc_SCD).

          SELECT SINGLE FROM i_supplier AS supplier
          FIELDS SupplierFullName
          WHERE supplier~supplier = @wasource-Supplier
              INTO @DATA(supplier_fullname).

          SELECT SINGLE FROM zi_dd_mat
          FIELDS TradeName
          WHERE Mat = @walines-Material
              INTO @DATA(trade_name).


          SELECT SINGLE FROM zmsme_table
          FIELDS vendortype,certificateno, creationdate, validfrom
          WHERE vendorno = @wasource-Supplier
          INTO @DATA(lv_vendortype).

          SELECT SINGLE FROM i_purchasinginforecordapi01
          FIELDS YY1_VendorSpecialName_SOS
          WHERE Supplier = @wasource-Supplier AND Material = @walines-Material
          INTO @DATA(lv_VendorSpecialName_SOS).

          create_rfqmatrix = VALUE #( %cid      = ls_key-%cid
                                  Bukrs = walines-CompanyCode
                                  Requestforquotation = walines-RequestForQuotation
                                  Vendorcode = wasource-Supplier
                                  Productcode = walines-Material
                                  Scheduleline = walines-ScheduleLine
                                  Supplierquotationitem = walines-RequestForQuotationItem
                                  Productdesc = walines-ProductDescription
                                  Vendorname = supplier_fullname
                                  Producttradename = trade_name
                                  Remarks = ''
                                  Orderquantity = walines-ScheduleLineOrderQuantity
                                  Orderquantityunit = walines-OrderQuantityUnit
                                  Vendortype = lv_vendortype-vendortype
                                  Majoractivity = bp_type-BusinessPartnerTypeDesc
                                  Typeofenterprise = ''
                                  Udyamaadharno = lv_vendortype-certificateno
                                  Udyamcertificatedate = lv_vendortype-validfrom
                                  Udyamcertificatereceivingdate = lv_vendortype-creationdate
                                  Vendorspecialname = lv_VendorSpecialName_SOS
                                  Supply = supplytag
                                  Processed = 0
                                          ).
          APPEND create_rfqmatrix TO create_rfqtab.

          MODIFY ENTITIES OF ZR_RFQMatrix IN LOCAL MODE
            ENTITY rfqmatrix
            CREATE FIELDS ( bukrs requestforquotation vendorcode productcode scheduleline supplierquotationitem
                productdesc vendorname producttradename remarks orderquantity orderquantityunit vendortype
                majoractivity typeofenterprise udyamaadharno udyamcertificatedate udyamcertificatereceivingdate
                vendorspecialname supply processed )
                  WITH create_rfqtab
            MAPPED   mapped
            FAILED   failed
            REPORTED reported.

          CLEAR : create_rfqmatrix.
          CLEAR : create_rfqtab.
        ENDLOOP.

      ENDLOOP.

      APPEND VALUE #( %cid = ls_key-%cid
                      %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-success
                        text = 'RFQ Data Generated.' )
                        ) TO reported-rfqmatrix.


    ENDLOOP.


  ENDMETHOD.

  METHOD updateRFQ.
    DATA: it_instance_d TYPE TABLE FOR DELETE ZR_RFQMatrix.
    DATA vendorinsert TYPE int1.

    DATA: lt_bidder_cba TYPE TABLE FOR CREATE I_RequestForQuotationTP\\RequestForQuotation\_RequestForQuotationBidder.


    READ ENTITIES OF ZR_RFQMatrix IN LOCAL MODE
      ENTITY rfqmatrix
      FIELDS ( Bukrs Requestforquotation Productcode Supplierquotationitem Vendorcode Scheduleline Supply ) WITH CORRESPONDING #( keys )
      RESULT DATA(rfqdata)
      FAILED failed.

    LOOP AT rfqdata INTO DATA(rfqline).
      IF rfqline-Requestforquotation <> ''.

        SELECT FROM zrfqmatrix
            FIELDS DISTINCT vendorcode
        WHERE bukrs = @rfqline-Bukrs AND requestforquotation = @rfqline-Requestforquotation
        AND supply = 1
        INTO TABLE @DATA(ltrfq).
        IF ltrfq IS NOT INITIAL.

          vendorinsert = 0.
          APPEND INITIAL LINE TO lt_bidder_cba ASSIGNING FIELD-SYMBOL(<ls_bidder>).
          <ls_bidder>-RequestForQuotation = rfqline-Requestforquotation.

          LOOP AT ltrfq INTO DATA(warfq).
            SELECT FROM I_RfqBidder_Api01 AS bidder
                FIELDS bidder~Supplier
                WHERE RequestForQuotation = @rfqline-Requestforquotation
                AND Supplier = @warfq-vendorcode
                INTO TABLE @DATA(ltbidder).
            IF ltbidder IS INITIAL.
              vendorinsert = 1.
              APPEND INITIAL LINE TO <ls_bidder>-%target ASSIGNING FIELD-SYMBOL(<ls_bidder_target>).
              <ls_bidder_target>-Supplier = warfq-vendorcode.
              <ls_bidder_target>-%cid = 'BIDDER_' && sy-tabix.
            ENDIF.
          ENDLOOP.

          IF vendorinsert <> 0.
            MODIFY ENTITIES OF I_RequestForQuotationTP
                ENTITY RequestForQuotation
            CREATE BY \_RequestForQuotationBidder FROM lt_bidder_cba
            FAILED DATA(ls_failed)
                MAPPED DATA(ls_mapped)
                REPORTED DATA(ls_reported).

            APPEND VALUE #( %tky = rfqline-%tky
                %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-success
                text = 'Bidders Updated.' )
                ) TO reported-rfqmatrix.

            CLEAR : lt_bidder_cba.
          ELSE.
            APPEND VALUE #( %tky = rfqline-%tky
                %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-success
                text = 'Bidders already Updated.' )
                ) TO reported-rfqmatrix.
          ENDIF.
        ELSE.
          APPEND VALUE #( %tky = rfqline-%tky
              %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-success
              text = 'Supplier not marked for supply.' )
              ) TO reported-rfqmatrix.
        ENDIF.

      ENDIF.
    ENDLOOP.

    READ ENTITIES OF ZR_RFQMatrix IN LOCAL MODE
      ENTITY rfqmatrix
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(rfqlines).

    result = VALUE #( FOR rfqselected IN rfqlines
                    ( %tky   = rfqselected-%tky
                      %param = rfqselected ) ).


  ENDMETHOD.

  METHOD publishRFQ.
    DATA: it_instance_d TYPE TABLE FOR DELETE ZR_RFQMatrix.

    DATA: lt_bidder_cba TYPE TABLE FOR CREATE I_RequestForQuotationTP\\RequestForQuotation\_RequestForQuotationBidder.


    READ ENTITIES OF ZR_RFQMatrix IN LOCAL MODE
      ENTITY rfqmatrix
      FIELDS ( Bukrs Requestforquotation Productcode Supplierquotationitem Vendorcode Scheduleline Supply ) WITH CORRESPONDING #( keys )
      RESULT DATA(rfqdata)
      FAILED failed.

    LOOP AT rfqdata INTO DATA(rfqline).
      IF rfqline-Requestforquotation <> ''.

        MODIFY ENTITIES OF I_RequestForQuotationTP
        ENTITY RequestForQuotation
        EXECUTE Publish FROM VALUE #( ( RequestForQuotation = |{ rfqline-Requestforquotation }| ) )
        FAILED DATA(ls_failed)
        MAPPED DATA(ls_mapped).


        APPEND VALUE #( %tky = rfqline-%tky
            %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-success
            text = 'RFQ Published.' )
            ) TO reported-rfqmatrix.


      ENDIF.
    ENDLOOP.

    READ ENTITIES OF ZR_RFQMatrix IN LOCAL MODE
      ENTITY rfqmatrix
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(rfqlines).

    result = VALUE #( FOR rfqselected IN rfqlines
                    ( %tky   = rfqselected-%tky
                      %param = rfqselected ) ).


  ENDMETHOD.

ENDCLASS.
