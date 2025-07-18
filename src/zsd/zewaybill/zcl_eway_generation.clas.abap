CLASS zcl_eway_generation DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_item_list,
             product_name        TYPE string,
             product_description TYPE string,
             hsn_code            TYPE string,
             quantity            TYPE p LENGTH 8 DECIMALS 3,
             unit_of_product     TYPE string,
             cgst_rate           TYPE p LENGTH 5 DECIMALS 2,
             sgst_rate           TYPE p LENGTH 5 DECIMALS 2,
             igst_rate           TYPE p LENGTH 5 DECIMALS 2,
             cess_rate           TYPE p LENGTH 5 DECIMALS 2,
             cessNonAdvol        TYPE p LENGTH 8 DECIMALS 2,
             taxable_amount      TYPE p LENGTH 13 DECIMALS 2,
           END OF ty_item_list.


    CLASS-DATA itemList TYPE TABLE OF ty_item_list.
    TYPES: BEGIN OF ty_final,
             userGstin                   TYPE string,
             supply_type                 TYPE string,
             sub_supply_type             TYPE string,
             sub_supply_description      TYPE string,
             document_type               TYPE string,
             document_number             TYPE string,
             document_date               TYPE string,
             gstin_of_consignor          TYPE string,
             legal_name_of_consignor     TYPE string,
             address1_of_consignor       TYPE string,
             address2_of_consignor       TYPE string,
             place_of_consignor          TYPE string,
             pincode_of_consignor        TYPE string,
             state_of_consignor          TYPE string,
             actual_from_state_name      TYPE string,
             gstin_of_consignee          TYPE string,
             legal_name_of_consignee     TYPE string,
             address1_of_consignee       TYPE string,
             address2_of_consignee       TYPE string,
             place_of_consignee          TYPE string,
             pincode_of_consignee        TYPE string,
             state_of_supply             TYPE string,
             actual_to_state_name        TYPE string,
             transaction_type            TYPE string,
             other_value                 TYPE string,
             total_invoice_value         TYPE p LENGTH 13 DECIMALS 2,
             taxable_amount              TYPE p LENGTH 13 DECIMALS 2,
             cgst_amount                 TYPE p LENGTH 13 DECIMALS 2,
             sgst_amount                 TYPE p LENGTH 13 DECIMALS 2,
             igst_amount                 TYPE p LENGTH 13 DECIMALS 2,
             cess_amount                 TYPE p LENGTH 13 DECIMALS 2,
             cess_nonadvol_value         TYPE p LENGTH 13 DECIMALS 2,
             transporter_id              TYPE string,
             transporter_name            TYPE string,
             transporter_document_number TYPE string,
             transporter_document_date   TYPE string,
             transportation_mode         TYPE string,
             transportation_distance     TYPE string,
             vehicle_number              TYPE string,
             vehicle_type                TYPE string,
             generate_status             TYPE string,
             data_source                 TYPE string,
             user_ref                    TYPE string,
             location_code               TYPE string,
             eway_bill_status            TYPE string,
             auto_print                  TYPE string,
             email                       TYPE string,
             data_record                 TYPE string,
             itemList                    LIKE itemList,
           END OF ty_final.


    CLASS-DATA: wa_final TYPE ty_final.

    CLASS-METHODS :generated_eway_bill IMPORTING
                                                 invoice       TYPE ztable_irn-billingdocno
                                                 companycode   TYPE ztable_irn-bukrs
                                       RETURNING VALUE(result) TYPE string.
ENDCLASS.



CLASS ZCL_EWAY_GENERATION IMPLEMENTATION.


  METHOD generated_eway_bill.

    """"""""""""""""""""""""""   user gstin    """"""""""""""""""""""""""""""""""""""""

    SELECT SINGLE FROM i_billingdocument AS a
    INNER JOIN I_BillingDocumentItem AS b ON a~BillingDocument = b~BillingDocument
    INNER JOIN ztable_plant AS c ON b~Plant = c~plant_code
    FIELDS
    b~plant,
    c~gstin_no,
    c~state_code2
    WHERE a~BillingDocument = @invoice AND
    a~CompanyCode = @companycode
    INTO @DATA(lv_user_gstin) PRIVILEGED ACCESS.

    wa_final-userGstin = lv_user_gstin-gstin_no.  " done

    SELECT SINGLE FROM i_billingdocument AS a
    INNER JOIN I_BillingDocumentItem AS b ON a~BillingDocument = b~BillingDocument
    FIELDS b~DistributionChannel
    WHERE a~BillingDocument = @invoice AND
    a~CompanyCode = @companycode
*    AND b~BillingDocumentType NOT IN ( 'S1','S2' )
    INTO @DATA(lv_trans_details) PRIVILEGED ACCESS.

    wa_final-supply_type = 'outward'.  " done

*    wa_final-supply_type = 'outward'.
    SELECT SINGLE FROM i_billingdocument AS a
 INNER JOIN I_BillingDocumentItem AS b ON a~BillingDocument = b~BillingDocument
 FIELDS a~BillingDocument,
 a~BillingDocumentType,
 a~BillingDocumentDate,
 b~Plant,
 b~DistributionChannel,
 a~DocumentReferenceID
 WHERE a~BillingDocument = @invoice
*    AND b~BillingDocumentType NOT IN ( 'S1','S2' )
 INTO @DATA(lv_document_details) PRIVILEGED ACCESS.

    IF lv_document_details-BillingDocumentType = 'F2' OR lv_document_details-BillingDocumentType = 'CBRE' OR lv_document_details-BillingDocumentType = 'JSTO'
     OR lv_document_details-BillingDocumentType = 'S1' OR lv_document_details-BillingDocumentType = 'S2'.
      wa_final-document_type = 'INV'.
    ELSEIF lv_document_details-BillingDocumentType = 'G2'.
      wa_final-document_type = 'CRN'.
    ELSEIF lv_document_details-BillingDocumentType = 'L2'.
      wa_final-document_type = 'DBN'.   " done
    ENDIF.

    wa_final-sub_supply_type = 'Supply'.    " done
    wa_final-sub_supply_description = ''.   " done
*    wa_final-document_type = 'Tax Invoice'.

    SHIFT lv_document_details-DocumentReferenceID LEFT DELETING LEADING '0'.
    wa_final-document_number = lv_document_details-DocumentReferenceID.  " done

*    wa_final-document_number = 'IMP/23/032'.
*    wa_final-document_date = '22/06/2023'.
    " done
    wa_final-document_date = lv_document_details-BillingDocumentDate+6(2) && '/' && lv_document_details-BillingDocumentDate+4(2) && '/' && lv_document_details-BillingDocumentDate(4).

    SELECT SINGLE c~addressid,
                  c~addresssearchterm2 AS gstin,
                  c~careofname AS lglnm,
                  c~streetname AS addr1,
                  c~cityname AS addr2,
                  c~districtname AS city2,
                  c~postalcode AS pin2,
                  c~region AS stcd,
                  a~plant_name1,
                  a~gstin_no,
                  a~address1,
                  a~address2,
                  a~state_code2,
                  a~pin,
                  a~city,
                  a~state_name
    FROM ztable_plant AS a
    LEFT JOIN i_plant AS b ON a~plant_code = b~plant
    LEFT JOIN i_address_2 AS c ON ( b~addressid = c~addressid )
    WHERE plant = @lv_document_details-plant INTO @DATA(sellerplantaddress) PRIVILEGED ACCESS.


    wa_final-gstin_of_consignor = sellerplantaddress-gstin_no.
    wa_final-legal_name_of_consignor  =  sellerplantaddress-plant_name1.
*    wa_final-legal_name_of_consignor = 'Welton'.
    wa_final-address1_of_consignor    =  sellerplantaddress-address1.
    wa_final-address2_of_consignor    =  sellerplantaddress-address2.

*    wa_final-address1_of_consignor = 'The Taj Mahal Palace,Apollo Bandar'.
*    wa_final-address2_of_consignor = 'Colaba,Mumbai'.
    wa_final-place_of_consignor      =  sellerplantaddress-addr2 .
    IF sellerplantaddress-city IS NOT INITIAL.
      wa_final-place_of_consignor      =  sellerplantaddress-city .
    ENDIF.
*    wa_final-place_of_consignor = 'Mumbai'.
    wa_final-pincode_of_consignor      =  sellerplantaddress-pin.
*    wa_final-pincode_of_consignor = 400001.

    wa_final-state_of_consignor = sellerplantaddress-state_name.
    wa_final-actual_from_state_name = sellerplantaddress-state_name.


*    SELECT SINGLE * FROM i_billingdocument AS a
*    LEFT JOIN i_customer AS b ON a~SoldToParty = b~customer
*    LEFT JOIN i_address_2 AS c ON c~AddressID = c~AddressID
*    LEFT JOIN i_regiontext AS e ON e~Region = c~Region AND e~Language = 'E' AND c~Country = e~Country
*    LEFT JOIN i_countrytext AS f ON e~country = f~country
*    WHERE a~billingdocument = @invoice
*    INTO @DATA(buyeradd) PRIVILEGED ACCESS.

    SELECT SINGLE * FROM i_billingdocumentitem AS a
       LEFT JOIN i_salesdocumentitem AS b ON a~salesdocument = b~salesdocument
       LEFT JOIN i_customer AS c ON b~shiptoparty = c~customer
       LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
       LEFT JOIN i_regiontext AS e ON e~Region = c~Region AND e~Language = 'E' AND c~Country = e~Country
       LEFT JOIN i_countrytext AS f ON e~country = f~country
       WHERE a~billingdocument = @invoice
       INTO @DATA(buyeradd) PRIVILEGED ACCESS.

    DATA : lv_Details_of_buyer  TYPE string.
    lv_Details_of_buyer = buyeradd-d-HouseNumber.

    CONCATENATE lv_Details_of_buyer buyeradd-d-streetname
    buyeradd-d-streetprefixname1 buyeradd-d-streetprefixname2
     buyeradd-d-CityName buyeradd-d-postalcode buyeradd-d-districtname
     buyeradd-f-CountryName INTO  lv_Details_of_buyer SEPARATED BY space.


    DATA: lv_Details_of_buyer_length TYPE i.
    lv_Details_of_buyer_length = strlen( lv_Details_of_buyer ).
    DATA: lv_Details_of_buyer1 TYPE string.
    DATA: lv_Details_of_buyer2 TYPE string.

    IF lv_Details_of_buyer_length > 95.
      lv_Details_of_buyer1 = lv_Details_of_buyer+0(95).
      lv_Details_of_buyer2 = lv_Details_of_buyer+95.
    ELSE.
      lv_Details_of_buyer1 = lv_Details_of_buyer+0(lv_Details_of_buyer_length).
      lv_Details_of_buyer2 = ''.
    ENDIF.




    wa_final-gstin_of_consignee = buyeradd-c-taxnumber3.
    wa_final-legal_name_of_consignee = buyeradd-c-CustomerName.
    wa_final-address1_of_consignee = lv_Details_of_buyer1.
    wa_final-address2_of_consignee = lv_Details_of_buyer2.
    IF wa_final-gstin_of_consignee <> ''.
      wa_final-place_of_consignee = wa_final-gstin_of_consignee+0(2).
    ENDIF.

    wa_final-pincode_of_consignee = buyeradd-c-postalcode.
    wa_final-state_of_supply = buyeradd-e-RegionName.
    wa_final-actual_to_state_name = buyeradd-e-RegionName.

    SELECT SINGLE FROM
    ztable_irn AS a
    FIELDS
    a~vehiclenum,
    a~distance
    WHERE a~billingdocno = @invoice AND a~bukrs = @companycode
    INTO @DATA(lv_transport).


*    wa_final-transaction_type = 3.

    SELECT SINGLE FROM
    i_billingdocument AS a
    LEFT JOIN i_supplier AS b ON a~YY1_TransportDetails_BDH = b~Supplier
    FIELDS
    b~TaxNumber3
    WHERE a~BillingDocument = @invoice
    INTO @DATA(transporter_id).

    wa_final-transporter_id = transporter_id.
*    wa_final-transporter_name = ''.
*    wa_final-transporter_document_number = ''.
*    wa_final-transporter_document_date = ''.
    wa_final-transportation_mode = 'Road'.
    wa_final-transportation_distance = lv_transport-distance.

    wa_final-vehicle_number = lv_transport-vehiclenum.
*    wa_final-vehicle_type = 'Regular'.
*    wa_final-generate_status = 1.
*    wa_final-data_source = 'erp'.
*    wa_final-user_ref = ''.
*    wa_final-location_code = ''.
*    wa_final-eway_bill_status = 'ABC'.
*    wa_final-auto_print = 'N'.
*    wa_final-email = ''.
*    wa_final-delete_record = 'N'.


    SELECT FROM I_BillingDocumentItem FIELDS BillingDocument, BillingDocumentItem, BillingDocumentItemText,
   Product, Plant, BillingQuantity, BillingQuantityUnit, DistributionChannel
   WHERE BillingDocument = @invoice AND CompanyCode = @companycode AND BillingQuantity <> '0'
   INTO TABLE @DATA(lt_item) PRIVILEGED ACCESS.

    DATA: wa_itemList TYPE ty_item_list.
    DATA: itemList TYPE TABLE OF ty_item_list.
    DATA: total_cgst TYPE p DECIMALS 2.
    DATA: total_sgst TYPE p DECIMALS 2.
    DATA: total_igst TYPE p DECIMALS 2.
    DATA: total_taxable TYPE p DECIMALS 2.
    DATA: total_invoice_val TYPE p DECIMALS 2.
    DATA: total_other TYPE p DECIMALS 2.

    LOOP AT lt_item INTO DATA(wa_item).

      DATA: lv_wa_item_Product TYPE zmaterial_table-trade_name.
      lv_wa_item_Product = wa_item-Product.
      SHIFT lv_wa_item_Product LEFT DELETING LEADING '0'.
      SELECT SINGLE FROM
      zmaterial_table AS a
      FIELDS
      a~trade_name
      WHERE a~mat = @lv_wa_item_Product
      INTO @DATA(wa_productname).

      SELECT SINGLE FROM
      i_producttext AS a
      LEFT JOIN i_productplantbasic AS b ON a~Product = b~Product
      FIELDS
      a~ProductName,
      a~product,
      b~ConsumptionTaxCtrlCode
      WHERE a~Product = @wa_item-Product
      INTO @DATA(wa_product).

      IF wa_productname IS NOT INITIAL.
        wa_itemList-product_name = wa_productname.
        wa_itemList-product_description = wa_productname.
      ELSE.
        wa_itemList-product_name = wa_product-ProductName.
        wa_itemList-product_description = wa_product-ProductName.
      ENDIF.
      wa_itemList-hsn_code = wa_product-ConsumptionTaxCtrlCode.
      wa_itemList-quantity = wa_item-BillingQuantity.

      select single from
      i_unitofmeasure as a
      FIELDS
      a~UnitOfMeasure_E
      where a~UnitOfMeasure = @wa_item-BillingQuantityUnit
      into @data(lv_unitofmeasure).

      wa_itemList-unit_of_product = lv_unitofmeasure.


      SELECT FROM i_billingdocumentitemprcgelmnt AS a
       FIELDS
       a~ConditionRatevalue,
       a~ConditionRateAmount,
       a~conditionamount,
       a~conditiontype,
       a~billingdocumentitem,
       a~billingdocument
       WHERE
       a~billingdocument  = @wa_item-BillingDocument AND
       a~billingdocumentitem = @wa_item-BillingDocumentItem
       INTO TABLE @DATA(b_item) PRIVILEGED ACCESS.

      READ TABLE b_item INTO DATA(wa_cgst) WITH KEY conditiontype = 'JOCG'.
      READ TABLE b_item INTO DATA(wa_sgst) WITH KEY conditiontype = 'JOSG'.
      READ TABLE b_item INTO DATA(wa_igst) WITH KEY conditiontype = 'JOIG'.

      IF wa_cgst IS NOT INITIAL.
        wa_itemList-cgst_rate = wa_cgst-ConditionRateValue.
        total_cgst += wa_cgst-ConditionAmount.
      ENDIF.

      IF wa_sgst IS NOT INITIAL.
        wa_itemList-sgst_rate = wa_sgst-ConditionRateValue.
        total_sgst += wa_sgst-ConditionAmount.
      ENDIF.

      IF wa_igst IS NOT INITIAL.
        wa_itemList-igst_rate = wa_igst-ConditionRateValue.
        total_igst += wa_igst-ConditionAmount.
      ENDIF.

      READ TABLE b_item INTO DATA(zbasicdis) WITH KEY conditiontype = 'ZDIS'.
      IF sy-subrc EQ 0.
        DATA(lv_discount) = zbasicdis-ConditionAmount.
      ENDIF.

      IF lv_document_details-BillingDocumentType = 'F2'
AND ( lv_document_details-DistributionChannel = '20' OR lv_document_details-DistributionChannel = '22' OR
lv_document_details-DistributionChannel = '21' ) .
        SELECT SINGLE
         a~ConditionRateAmount,
         a~ConditionAmount
         FROM i_billingdocumentitemprcgelmnt AS a
         INNER JOIN i_billingdocumentitem AS b
           ON a~billingdocument = b~billingdocument
          AND a~billingdocumentitem = b~billingdocumentitem
         WHERE a~ConditionType IN ('ZEXP')
           AND a~BillingDocument = @wa_item-billingdocument
           AND a~BillingDocumentItem = @wa_item-billingdocumentitem
            INTO @DATA(zbasicunitprice).
      ELSEIF  ( lv_document_details-BillingDocumentType = 'F2' OR lv_document_details-BillingDocumentType = 'CBRE' )
   AND ( lv_document_details-DistributionChannel = '11' OR lv_document_details-DistributionChannel = '12' OR
   lv_document_details-DistributionChannel = '13' OR lv_document_details-DistributionChannel = '15' ).
        SELECT SINGLE
        a~ConditionRateAmount,
        a~ConditionAmount
        FROM i_billingdocumentitemprcgelmnt AS a
        INNER JOIN i_billingdocumentitem AS b
          ON a~billingdocument = b~billingdocument
         AND a~billingdocumentitem = b~billingdocumentitem
        WHERE a~ConditionType IN ('ZBSP')
          AND a~BillingDocument = @wa_item-billingdocument
          AND a~BillingDocumentItem = @wa_item-billingdocumentitem
           INTO @zbasicunitprice.
      ELSEIF ( lv_document_details-BillingDocumentType = 'G2' OR lv_document_details-BillingDocumentType = 'L2' )
AND ( lv_document_details-DistributionChannel = '11' OR lv_document_details-DistributionChannel = '12' OR
lv_document_details-DistributionChannel = '13' OR lv_document_details-DistributionChannel = '15' ).
        SELECT SINGLE
             a~ConditionRateAmount,
             a~ConditionAmount
             FROM i_billingdocumentitemprcgelmnt AS a
             INNER JOIN i_billingdocumentitem AS b
               ON a~billingdocument = b~billingdocument
              AND a~billingdocumentitem = b~billingdocumentitem
             WHERE a~ConditionType IN ('ZCDM')
               AND a~BillingDocument = @wa_item-billingdocument
               AND a~BillingDocumentItem = @wa_item-billingdocumentitem
                INTO @zbasicunitprice.
      ELSEIF ( lv_document_details-BillingDocumentType = 'JSTO' )
AND ( lv_document_details-DistributionChannel = '14' ).
        SELECT SINGLE
             a~ConditionRateAmount,
             a~ConditionAmount
             FROM i_billingdocumentitemprcgelmnt AS a
             INNER JOIN i_billingdocumentitem AS b
               ON a~billingdocument = b~billingdocument
              AND a~billingdocumentitem = b~billingdocumentitem
             WHERE a~ConditionType IN ('ZSTO')
               AND a~BillingDocument = @wa_item-billingdocument
               AND a~BillingDocumentItem = @wa_item-billingdocumentitem
                INTO @zbasicunitprice.
      ENDIF.

      SELECT SINGLE FROM
      I_BillingDocument AS a
      FIELDS a~AccountingExchangeRate
      WHERE a~BillingDocument = @wa_item-billingdocument
      INTO @DATA(lv_exchange).

      IF lv_document_details-BillingDocumentType = 'F2' AND ( lv_document_details-DistributionChannel = '20' OR
      lv_document_details-DistributionChannel = '21' OR
      lv_document_details-DistributionChannel = '22' ).
        zbasicunitprice-ConditionAmount = zbasicunitprice-ConditionAmount * lv_exchange.
        zbasicunitprice-ConditionRateAmount = zbasicunitprice-ConditionRateAmount * lv_exchange.
      ENDIF.

      IF sy-subrc EQ 0.
        DATA(lv_supply) = zbasicunitprice-ConditionAmount.
      ENDIF.

      READ TABLE b_item INTO DATA(wa_freight) WITH KEY conditiontype = 'ZFRT'.
      IF sy-subrc EQ 0 .
        DATA(lv_freight) = wa_freight-conditionamount .
      ENDIF.

      SELECT SINGLE
       a~ConditionRateAmount,
       a~ConditionAmount
       FROM i_billingdocumentitemprcgelmnt AS a
       INNER JOIN i_billingdocumentitem AS b
         ON a~billingdocument = b~billingdocument
        AND a~billingdocumentitem = b~billingdocumentitem
       WHERE a~ConditionType IN ( 'ZINC', 'ZINS', 'ZINP' )
         AND a~BillingDocument = @wa_item-billingdocument
         AND a~BillingDocumentItem = @wa_item-billingdocumentitem
          INTO @DATA(wa_insu).

      IF sy-subrc EQ 0 .
        DATA(lv_insu) = wa_insu-conditionamount.
      ENDIF.

      READ TABLE b_item INTO DATA(tcs) WITH KEY conditiontype = 'JTC1'.
      IF sy-subrc EQ 0 .
        DATA(tcsamt) = tcs-conditionamount .
      ENDIF.


      total_other += lv_insu + lv_freight + tcsamt.
      DATA: lv_itemlist_taxable_amt TYPE p DECIMALS 2.
      lv_itemlist_taxable_amt = lv_supply + lv_discount + lv_insu + lv_freight.
      wa_itemList-taxable_amount =  lv_itemlist_taxable_amt." + tcsamt.
      total_taxable += wa_itemList-taxable_amount.
      total_invoice_val += wa_itemList-taxable_amount + wa_cgst-ConditionAmount + wa_sgst-ConditionAmount +
                                         wa_igst-ConditionAmount.

      CLEAR wa_item.
      CLEAR wa_cgst.
      CLEAR wa_igst.
      CLEAR wa_sgst.
      CLEAR b_item.
      CLEAR wa_product.
      CLEAR lv_supply.
      CLEAR lv_discount.
      CLEAR lv_freight.
      CLEAR wa_freight.
      CLEAR lv_insu.
      CLEAR wa_insu.
      APPEND wa_itemlist TO itemList.
      CLEAR wa_itemList.
      CLEAR tcsamt.
      CLEAR tcs.
      clear wa_productname.
      clear lv_unitofmeasure.
    ENDLOOP.


    wa_final-other_value = total_other.
    wa_final-total_invoice_value = total_invoice_val.
    wa_final-taxable_amount = total_taxable.
    wa_final-cgst_amount = total_cgst.
    wa_final-sgst_amount = total_sgst.
    wa_final-igst_amount = total_igst.
    wa_final-cess_amount = 0.
    wa_final-cess_nonadvol_value = 0.
    wa_final-generate_status = '1'.



*    wa_itemList-unit_of_product = 'BOX'.

*    wa_itemList-cess_rate = '0'.
*    wa_itemList-cessNonAdvol = '0'.

    wa_final-itemlist = itemList.

    DATA:json TYPE REF TO if_xco_cp_json_data.

    xco_cp_json=>data->from_abap(
      EXPORTING
        ia_abap      = wa_final
      RECEIVING
        ro_json_data = json   ).
    json->to_string(
      RECEIVING
        rv_string =   DATA(lv_string) ).

    REPLACE ALL OCCURRENCES OF 'ī' IN lv_string WITH 'i'.
    REPLACE ALL OCCURRENCES OF '"USERGSTIN"' IN lv_string WITH '"userGstin"'.
    REPLACE ALL OCCURRENCES OF '"SUPPLY_TYPE"' IN lv_string WITH '"supply_type"'.
    REPLACE ALL OCCURRENCES OF '"SUB_SUPPLY_TYPE"' IN lv_string WITH '"sub_supply_type"'.
    REPLACE ALL OCCURRENCES OF '"SUB_SUPPLY_DESCRIPTION"' IN lv_string WITH '"sub_supply_description"'.
    REPLACE ALL OCCURRENCES OF '"DOCUMENT_TYPE"' IN lv_string WITH '"document_type"'.
    REPLACE ALL OCCURRENCES OF '"DOCUMENT_NUMBER"' IN lv_string WITH '"document_number"'.
    REPLACE ALL OCCURRENCES OF '"DOCUMENT_DATE"' IN lv_string WITH '"document_date"'.
    REPLACE ALL OCCURRENCES OF '"GSTIN_OF_CONSIGNOR"' IN lv_string WITH '"gstin_of_consignor"'.
    REPLACE ALL OCCURRENCES OF '"LEGAL_NAME_OF_CONSIGNOR"' IN lv_string WITH '"legal_name_of_consignor"'.
    REPLACE ALL OCCURRENCES OF '"ADDRESS1_OF_CONSIGNOR"' IN lv_string WITH '"address1_of_consignor"'.
    REPLACE ALL OCCURRENCES OF '"ADDRESS2_OF_CONSIGNOR"' IN lv_string WITH '"address2_of_consignor"'.
    REPLACE ALL OCCURRENCES OF '"PLACE_OF_CONSIGNOR"' IN lv_string WITH '"place_of_consignor"'.
    REPLACE ALL OCCURRENCES OF '"PINCODE_OF_CONSIGNOR"' IN lv_string WITH '"pincode_of_consignor"'.
    REPLACE ALL OCCURRENCES OF '"STATE_OF_CONSIGNOR"' IN lv_string WITH '"state_of_consignor"'.
    REPLACE ALL OCCURRENCES OF '"ACTUAL_FROM_STATE_NAME"' IN lv_string WITH '"actual_from_state_name"'.
    REPLACE ALL OCCURRENCES OF '"GSTIN_OF_CONSIGNEE"' IN lv_string WITH '"gstin_of_consignee"'.
    REPLACE ALL OCCURRENCES OF '"LEGAL_NAME_OF_CONSIGNEE"' IN lv_string WITH '"legal_name_of_consignee"'.
    REPLACE ALL OCCURRENCES OF '"ADDRESS1_OF_CONSIGNEE"' IN lv_string WITH '"address1_of_consignee"'.
    REPLACE ALL OCCURRENCES OF '"ADDRESS2_OF_CONSIGNEE"' IN lv_string WITH '"address2_of_consignee"'.
    REPLACE ALL OCCURRENCES OF '"PLACE_OF_CONSIGNEE"' IN lv_string WITH '"place_of_consignee"'.
    REPLACE ALL OCCURRENCES OF '"PINCODE_OF_CONSIGNEE"' IN lv_string WITH '"pincode_of_consignee"'.
    REPLACE ALL OCCURRENCES OF '"STATE_OF_SUPPLY"' IN lv_string WITH '"state_of_supply"'.
    REPLACE ALL OCCURRENCES OF '"ACTUAL_TO_STATE_NAME"' IN lv_string WITH '"actual_to_state_name"'.
    REPLACE ALL OCCURRENCES OF '"TRANSACTION_TYPE"' IN lv_string WITH '"transaction_type"'.
    REPLACE ALL OCCURRENCES OF '"OTHER_VALUE"' IN lv_string WITH '"other_value"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_INVOICE_VALUE"' IN lv_string WITH '"total_invoice_value"'.
    REPLACE ALL OCCURRENCES OF '"TAXABLE_AMOUNT"' IN lv_string WITH '"taxable_amount"'.
    REPLACE ALL OCCURRENCES OF '"CGST_AMOUNT"' IN lv_string WITH '"cgst_amount"'.
    REPLACE ALL OCCURRENCES OF '"SGST_AMOUNT"' IN lv_string WITH '"sgst_amount"'.
    REPLACE ALL OCCURRENCES OF '"IGST_AMOUNT"' IN lv_string WITH '"igst_amount"'.
    REPLACE ALL OCCURRENCES OF '"CESS_AMOUNT"' IN lv_string WITH '"cess_amount"'.
    REPLACE ALL OCCURRENCES OF '"CESS_NONADVOL_VALUE"' IN lv_string WITH '"cess_nonadvol_value"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTER_ID"' IN lv_string WITH '"transporter_id"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTATION_MODE"' IN lv_string WITH '"transportation_mode"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTATION_DISTANCE"' IN lv_string WITH '"transportation_distance"'.
    REPLACE ALL OCCURRENCES OF '"VEHICLE_NUMBER"' IN lv_string WITH '"vehicle_number"'.
    REPLACE ALL OCCURRENCES OF '"vehicle_type"' IN lv_string WITH '"vehicle_type"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTER_NAME"' IN lv_string WITH '"transporter_name"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTER_DOCUMENT_NUMBER"' IN lv_string WITH '"transporter_document_number"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTER_DOCUMENT_DATE"' IN lv_string WITH '"transporter_document_date"'.
    REPLACE ALL OCCURRENCES OF '"VEHICLE_TYPE"' IN lv_string WITH '"vehicle_type"'.
    REPLACE ALL OCCURRENCES OF '"GENERATE_STATUS"' IN lv_string WITH '"generate_status"'.
    REPLACE ALL OCCURRENCES OF '"DATA_SOURCE"' IN lv_string WITH '"data_source"'.
    REPLACE ALL OCCURRENCES OF '"USER_REF"' IN lv_string WITH '"user_ref"'.
    REPLACE ALL OCCURRENCES OF '"EWAY_BILL_STATUS"' IN lv_string WITH '"eway_bill_status"'.
    REPLACE ALL OCCURRENCES OF '"LOCATION_CODE"' IN lv_string WITH '"location_code"'.
    REPLACE ALL OCCURRENCES OF '"AUTO_PRINT"' IN lv_string WITH '"auto_print"'.
    REPLACE ALL OCCURRENCES OF '"EMAIL"' IN lv_string WITH '"email"'.
    REPLACE ALL OCCURRENCES OF '"DATA_RECORD"' IN lv_string WITH '"data_record"'.
    REPLACE ALL OCCURRENCES OF '"ITEMLIST"' IN lv_string WITH '"itemList"'.
    REPLACE ALL OCCURRENCES OF '"PRODUCT_NAME"' IN lv_string WITH '"product_name"'.
    REPLACE ALL OCCURRENCES OF '"PRODUCT_DESCRIPTION"' IN lv_string WITH '"product_description"'.
    REPLACE ALL OCCURRENCES OF '"HSN_CODE"' IN lv_string WITH '"hsn_code"'.
    REPLACE ALL OCCURRENCES OF '"QUANTITY"' IN lv_string WITH '"quantity"'.
    REPLACE ALL OCCURRENCES OF '"UNIT_OF_PRODUCT"' IN lv_string WITH '"unit_of_product"'.
    REPLACE ALL OCCURRENCES OF '"CGST_RATE"' IN lv_string WITH '"cgst_rate"'.
    REPLACE ALL OCCURRENCES OF '"SGST_RATE"' IN lv_string WITH '"sgst_rate"'.
    REPLACE ALL OCCURRENCES OF '"IGST_RATE"' IN lv_string WITH '"igst_rate"'.
    REPLACE ALL OCCURRENCES OF '"CESS_RATE"' IN lv_string WITH '"cess_rate"'.
    REPLACE ALL OCCURRENCES OF '"CESSNONADVOL"' IN lv_string WITH '"cess_nonadvol"'.

    result = lv_string.

  ENDMETHOD.
ENDCLASS.
