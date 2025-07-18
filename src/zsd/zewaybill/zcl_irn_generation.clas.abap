CLASS zcl_irn_generation DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_transaction_details,   " mandatory
             supply_type     TYPE string,
             charge_type     TYPE string,
             igst_on_intra   TYPE string,
             ecommerce_gstin TYPE string,
           END OF ty_transaction_details.

    TYPES: BEGIN OF ty_document_details,      " mandatory
             document_type   TYPE string,
             document_number TYPE string,
             document_date   TYPE string,
           END OF ty_document_details.

    TYPES: BEGIN OF ty_seller_details,          " mandatory
             gstin        TYPE string,
             legal_name   TYPE string,
             trade_name   TYPE string,
             address1     TYPE string,
             address2     TYPE string,
             location     TYPE string,
             pincode      TYPE string,
             state_code   TYPE string,
             phone_number TYPE string,
             email        TYPE string,
           END OF ty_seller_details.


    TYPES: BEGIN OF ty_buyer_details,           " mandatory
             gstin           TYPE string,
             legal_name      TYPE string,
             trade_name      TYPE string,
             address1        TYPE string,
             address2        TYPE string,
             location        TYPE string,
             pincode         TYPE string,
             place_of_supply TYPE string,
             state_code      TYPE string,
             phone_number    TYPE string,
             email           TYPE string,
           END OF ty_buyer_details.


    TYPES:BEGIN OF ty_dispatch_details,
            company_name TYPE string, "dqfefkewl",
            address1     TYPE string , "Vila",
            address2     TYPE string, "Vila",
            location     TYPE string, "Noida",
            pincode      TYPE string,                       " 201301,
            state_code   TYPE string, "09"
          END OF ty_dispatch_details.


    TYPES: BEGIN OF ty_ship_details,
             gstin      TYPE string, "05AAAPG7885R002",
             legal_name TYPE string, ": "123",
             trade_name TYPE string, ": "232",
             address1   TYPE string, ": "1",
             address2   TYPE string, "",
             location   TYPE string, "221",
             pincode    TYPE string,                        ": 263001,
             state_code TYPE string, ": "5"
           END OF ty_ship_details.

    TYPES: BEGIN OF ty_export_details,
             ship_bill_number TYPE string, "",
             ship_bill_date   TYPE string, "",
             country_code     TYPE string, ": "IN",
             foreign_currency TYPE string, "inr",
             refund_claim     TYPE string,  "N",
             port_code        TYPE string, "12",
             export_duty      TYPE string, "90.9"
           END OF ty_export_details.


    TYPES: BEGIN OF ty_payment_details,
             bank_account_number TYPE string, "Account Details",
             paid_balance_amount TYPE string, "100.2",
             credit_days         TYPE string, "2,
             credit_transfer     TYPE string, ": "Credit Transfer",
             direct_debit        TYPE string, ": "Direct Debit",
             branch_or_ifsc      TYPE string, ": "KKK000180",
             payment_mode        TYPE string, ": "CASH",
             payee_name          TYPE string, "Payee Name",
             outstanding_amount  TYPE string, "1.9",
             payment_instruction TYPE string, "Payment Instruction",
             payment_term        TYPE string, "Terms of Payment"
           END OF ty_payment_details.


    "reference_details {         }


    TYPES: BEGIN OF ty_additional_document_details,
             supporting_document_url TYPE string, "asafsd",
             supporting_document     TYPE string, "india",
             additional_information  TYPE string, "india"
           END OF ty_additional_document_details.


    TYPES: BEGIN OF ty_ewaybill_details,
             transporter_id              TYPE string, "05AAABB0639G1Z8",
             transporter_name            TYPE string, "Jay Trans",
             transportation_mode         TYPE string, "1",
             transportation_distance     TYPE string, " 296,
             transporter_document_number TYPE string, "12301",
             transporter_document_date   TYPE string, "14/09/2023",
             vehicle_number              TYPE string,       "PQR1234",
             vehicle_type                TYPE string, "R"
           END OF ty_ewaybill_details.


    TYPES: BEGIN OF ty_value_details,                           " mandatory
             total_assessable_value      TYPE string, ": 4,
             total_cgst_value            TYPE string, "",
             total_sgst_value            TYPE string, "0,
             total_igst_value            TYPE string, "0.2,
             total_cess_value            TYPE string, "0,
             total_cess_value_of_state   TYPE string, "0,
             total_discount              TYPE string, "0,
             total_other_charge          TYPE string, "0,
             total_invoice_value         TYPE string, "4.2,
             round_off_amount            TYPE string, "0,
             tot_inv_val_additional_curr TYPE string, "total_invoice_value_additional_currency:"0
           END OF ty_value_details.

    TYPES: BEGIN OF ty_batch_details,                           " mandatory
             name          TYPE string,
             expiry_date   TYPE string,
             warranty_date TYPE string,
           END OF ty_batch_details.
    TYPES: BEGIN OF ty_attribute_details,                           " mandatory
             item_attribute_details TYPE string,
             item_attribute_value   TYPE string,
           END OF ty_attribute_details.


    CLASS-DATA : attribute_details TYPE TABLE OF ty_attribute_details.

    TYPES: BEGIN OF ty_item_list,
             item_serial_number         TYPE string,
             product_description        TYPE string,
             is_service                 TYPE string,
             hsn_code                   TYPE string,
             bar_code                   TYPE string,
             quantity                   TYPE string,
             free_quantity              TYPE string,
             unit                       TYPE string,
             unit_price                 TYPE string,
             total_amount               TYPE string,
             pre_tax_value              TYPE string,
             discount                   TYPE string,
             other_charge               TYPE string,
             assessable_value           TYPE string,
             gst_rate                   TYPE string,
             igst_amount                TYPE string,
             cgst_amount                TYPE string,
             sgst_amount                TYPE string,
             cess_rate                  TYPE string,
             cess_amount                TYPE string,
             cess_nonadvol_amount       TYPE string,
             state_cess_rate            TYPE string,
             state_cess_amount          TYPE string,
             state_cess_nonadvol_amount TYPE string,
             total_item_value           TYPE string,
             country_origin             TYPE string,
             order_line_reference       TYPE string,
             product_serial_number      TYPE string,
             batch_details              TYPE ty_batch_details,
             attribute_details          LIKE attribute_details,
           END OF ty_item_list.

    CLASS-DATA : item_list TYPE TABLE OF ty_item_list.

    TYPES: BEGIN OF ty_contract_details,
             receipt_advice_number      TYPE string,
             receipt_advice_date        TYPE string,
             batch_reference_number     TYPE string,
             contract_reference_number  TYPE string,
             other_reference            TYPE string,
             project_reference_number   TYPE string,
             vendor_po_reference_number TYPE string,
             vendor_po_reference_date   TYPE string,
           END OF ty_contract_details.

    TYPES: BEGIN OF ty_preceding_document_details,
             reference_of_original_invoice TYPE string,
             preceding_invoice_date        TYPE string,
             other_reference               TYPE string,
           END OF ty_preceding_document_details.
    TYPES: BEGIN OF ty_document_period_details,
             invoice_period_start_date TYPE string,
             invoice_period_end_date   TYPE string,
           END OF ty_document_period_details.
    TYPES: BEGIN OF ty_reference_details,
             other_refernce          TYPE string,
             invoice_remarks         TYPE string,
             document_period_details TYPE ty_document_period_details,
           END OF ty_reference_details.

    CLASS-DATA : preceding_document_details TYPE TABLE OF ty_preceding_document_details.
    CLASS-DATA : contract_details TYPE TABLE OF ty_contract_details.
    CLASS-DATA : additional_document_details TYPE TABLE OF ty_additional_document_details.

    TYPES: BEGIN OF ty_body,
             user_gstin                  TYPE string,
             data_source                 TYPE string,
             transaction_details         TYPE ty_transaction_details,
             document_details            TYPE ty_document_details,
             seller_details              TYPE ty_seller_details,
             buyer_details               TYPE ty_buyer_details,
             dispatch_details            TYPE ty_dispatch_details,
             ship_details                TYPE ty_ship_details,
             export_details              TYPE ty_export_details,
             payment_details             TYPE ty_payment_details,
             reference_details           TYPE ty_reference_details,
             preceding_document_details  LIKE preceding_document_details,
             contract_details            LIKE contract_details,
             additional_document_details LIKE additional_document_details,
             ewaybill_details            TYPE ty_ewaybill_details,
             value_details               TYPE ty_value_details,
             item_list                   LIKE item_list,
           END OF ty_body.
    CLASS-METHODS :generated_irn IMPORTING
                                           companycode   TYPE ztable_irn-bukrs
                                           document      TYPE ztable_irn-billingdocno
                                 RETURNING VALUE(result) TYPE string.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_IRN_GENERATION IMPLEMENTATION.


  METHOD generated_irn.

    DATA : wa_final TYPE ty_body.
    DATA: it_itemlist TYPE TABLE OF ty_item_list,
          wa_itemlist TYPE ty_item_list.

*****************""""""""""""""""""""   user gstin    """"""""""""""""""""""""""""""""""""""""
    SELECT SINGLE FROM i_billingdocument AS a
    INNER JOIN I_BillingDocumentItem AS b ON a~BillingDocument = b~BillingDocument
    INNER JOIN ztable_plant AS c ON b~Plant = c~plant_code
    FIELDS b~plant,c~gstin_no,c~state_code2
    WHERE a~BillingDocument = @document AND
    a~CompanyCode = @companycode
*    AND b~BillingDocumentType NOT IN ( 'S1','S2' )
    INTO @DATA(lv_user_gstin) PRIVILEGED ACCESS.

*    IF lv_user_gstin = 'GH01'.
*      wa_final-user_gstin = '19AABCG1667P1Z2'.
*    ELSEIF lv_user_gstin = 'GF01'.
*      wa_final-user_gstin = '19AABCG1667P1Z2'.
*    ELSEIF lv_user_gstin = 'GM01'.
*      wa_final-user_gstin = '19AABCG1667P1Z2'.
*    ELSEIF lv_user_gstin = 'GM30'.
*      wa_final-user_gstin = '19AABCG1667P1Z2'.
*    ELSEIF lv_user_gstin = 'GE01'.
*      wa_final-user_gstin = '19AABCG1667P1Z2'.
*    ELSEIF lv_user_gstin = 'GW01'.
*      wa_final-user_gstin = '27AABCG1667P1Z5'.
*    ELSEIF lv_user_gstin = 'GW02'.
*      wa_final-user_gstin = '27AABCG1667P1Z5'.
*    ELSEIF lv_user_gstin = 'GT01'.
*      wa_final-user_gstin = '19AABCG1667P1Z2'.
*    ELSE.
*      wa_final-user_gstin = ''.
*    ENDIF.

*    wa_final-user_gstin = '09AAAPG7885R002'.     " hardcoded
    wa_final-user_gstin = lv_user_gstin-gstin_no.


**************************    transaction details    """""""""""""""""""""""""

    SELECT SINGLE FROM i_billingdocument AS a
    INNER JOIN I_BillingDocumentItem AS b ON a~BillingDocument = b~BillingDocument
    FIELDS b~DistributionChannel
    WHERE a~BillingDocument = @document AND
    a~CompanyCode = @companycode
*    AND b~BillingDocumentType NOT IN ( 'S1','S2' )
    INTO @DATA(lv_trans_details) PRIVILEGED ACCESS.

    IF lv_trans_details = 11 OR lv_trans_details = 12 OR lv_trans_details = 13 OR lv_trans_details = 14
    OR lv_trans_details = 15 OR lv_trans_details = 16.
      wa_final-transaction_details-supply_type = 'B2B'.
    ELSE.
      wa_final-transaction_details-supply_type = 'EXPWOP'.
    ENDIF.


********************************  document details  """"""""""""""""""""""""""""""


    SELECT SINGLE FROM i_billingdocument AS a
    INNER JOIN I_BillingDocumentItem AS b ON a~BillingDocument = b~BillingDocument
    FIELDS a~BillingDocument,
    a~BillingDocumentType,
    a~BillingDocumentDate,
    a~DistributionChannel,
    b~Plant,
    a~DocumentReferenceID
    WHERE a~BillingDocument = @document
*    AND b~BillingDocumentType NOT IN ( 'S1','S2' )
    INTO @DATA(lv_document_details) PRIVILEGED ACCESS.

    IF lv_document_details-BillingDocumentType = 'F2' OR lv_document_details-BillingDocumentType = 'JSTO'
     OR lv_document_details-BillingDocumentType = 'S1' OR lv_document_details-BillingDocumentType = 'S2'.
      wa_final-document_details-document_type = 'INV'.
    ELSEIF lv_document_details-BillingDocumentType = 'G2' or lv_document_details-BillingDocumentType = 'CBRE'.
      wa_final-document_details-document_type = 'CRN'.
    ELSEIF lv_document_details-BillingDocumentType = 'L2'.
      wa_final-document_details-document_type = 'DBN'.
    ENDIF.
*    wa_final-document_details-document_type = 'INV'.    " HARDCODED
    SHIFT lv_document_details-DocumentReferenceID LEFT DELETING LEADING '0'.
    wa_final-document_details-document_number = lv_document_details-DocumentReferenceID.
*    wa_final-document_details-document_number = 'Acx/56797'.    " HARDCODED
    wa_final-document_details-document_date = lv_document_details-BillingDocumentDate+6(2) && '/' && lv_document_details-BillingDocumentDate+4(2) && '/' && lv_document_details-BillingDocumentDate(4).
*    wa_final-document_details-document_date = '23/02/2025'. " hardcoded

***************************************seller details """"""""""""""""""""""""""""""""""""""

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
                  a~city
    FROM ztable_plant AS a
    LEFT JOIN i_plant AS b ON a~plant_code = b~plant
    LEFT JOIN i_address_2 AS c ON ( b~addressid = c~addressid )
    WHERE plant = @lv_document_details-plant INTO @DATA(sellerplantaddress) PRIVILEGED ACCESS.

    wa_final-seller_details-gstin    =  sellerplantaddress-gstin_no.
*    wa_final-seller_details-gstin    =  '09AAAPG7885R002'.   " HARDCODED
    wa_final-seller_details-legal_name  =  sellerplantaddress-plant_name1.
*    wa_final-seller_details-legal_name  =  'MastersIndia UP'.  " HARDCODED
    wa_final-seller_details-trade_name =  sellerplantaddress-plant_name1.
    wa_final-seller_details-address1    =  sellerplantaddress-address1.
    wa_final-seller_details-address2    =  sellerplantaddress-address2 .
    wa_final-seller_details-location      =  sellerplantaddress-addr2 .
    IF sellerplantaddress-city IS NOT INITIAL.
      wa_final-seller_details-location      =  sellerplantaddress-city .
    ENDIF.
*    wa_final-seller_details-location      =  '1279' .   " HARDCODED
    wa_final-seller_details-state_code     =  sellerplantaddress-state_code2.
*    wa_final-seller_details-state_code     =  '09'.    " HARDCODED
    wa_final-seller_details-pincode      =  sellerplantaddress-pin.


*******************************    buyer details    """"""""""""""""""""""""""""""""

*    SELECT SINGLE * FROM i_billingdocumentpartner AS a  INNER JOIN i_customer AS
*            b ON ( a~customer = b~customer  ) WHERE a~billingdocument = @document
*             AND a~partnerfunction = 'RE' INTO  @DATA(buyeradd) PRIVILEGED ACCESS.

    SELECT SINGLE * FROM i_billingdocument AS a
    LEFT JOIN i_customer AS b ON a~SoldToParty = b~customer
    LEFT JOIN i_address_2 AS c ON c~AddressID = c~AddressID
    LEFT JOIN i_regiontext AS e ON e~Region = c~Region AND e~Language = 'E' AND c~Country = e~Country
    LEFT JOIN i_countrytext AS f ON e~country = f~country
    WHERE a~billingdocument = @document
    INTO @DATA(buyeradd) PRIVILEGED ACCESS.

    DATA : lv_Details_of_buyer  TYPE string.
    lv_Details_of_buyer = buyeradd-c-HouseNumber.

    CONCATENATE lv_Details_of_buyer buyeradd-c-streetname
    buyeradd-c-streetprefixname1  buyeradd-c-streetprefixname2
     buyeradd-c-CityName buyeradd-c-postalcode buyeradd-c-districtname
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
*    lv_Details_of_buyer1 = lv_Details_of_buyer+0(95).
*    lv_Details_of_buyer2 = lv_Details_of_buyer+95.


    wa_final-buyer_details-gstin = buyeradd-b-taxnumber3.
*    wa_final-buyer_details-gstin = '05AAAPG7885R002'.   " HARDCODED
    wa_final-buyer_details-legal_name = buyeradd-b-CustomerName.
    wa_final-buyer_details-trade_name = buyeradd-b-customername.
    IF wa_final-buyer_details-gstin <> ''.
      wa_final-buyer_details-place_of_supply = wa_final-buyer_details-gstin+0(2).
    ENDIF.
    wa_final-buyer_details-address1 = lv_Details_of_buyer1.
    wa_final-buyer_details-address2 = lv_Details_of_buyer2.
    wa_final-buyer_details-location   = buyeradd-b-cityname .
    wa_final-buyer_details-pincode   = buyeradd-b-postalcode  .
    wa_final-buyer_details-state_code  = wa_final-buyer_details-place_of_supply  .
*    wa_final-buyer_details-state_code  =  '05'.    " HARDCODED

    """"""""""""""""""""""" ship details """""""""""""""""""""""""""""

    SELECT SINGLE * FROM i_billingdocumentitem AS a
    LEFT JOIN i_salesdocumentitem AS b ON a~salesdocument = b~salesdocument
    LEFT JOIN i_customer AS c ON b~shiptoparty = c~customer
    LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
    LEFT JOIN i_regiontext AS e ON e~Region = c~Region AND e~Language = 'E' AND c~Country = e~Country
    LEFT JOIN i_countrytext AS f ON e~country = f~country
    WHERE a~billingdocument = @document
    INTO @DATA(wa_ship) PRIVILEGED ACCESS.

    DATA : lv_Details_of_Recipients  TYPE string.
    lv_Details_of_Recipients = wa_ship-d-HouseNumber.

    CONCATENATE lv_Details_of_Recipients wa_ship-d-streetname
    wa_ship-d-streetprefixname1 wa_ship-d-streetprefixname2
     wa_ship-d-CityName wa_ship-d-postalcode wa_ship-d-districtname
     wa_ship-f-CountryName INTO lv_Details_of_Recipients SEPARATED BY space.

    DATA: lv_Details_of_ship_length TYPE i.
    lv_Details_of_ship_length = strlen( lv_Details_of_Recipients ).
    DATA: lv_Details_of_Recipients1 TYPE string.
    DATA: lv_Details_of_Recipients2 TYPE string.

     IF lv_Details_of_ship_length > 95.
      lv_Details_of_Recipients1 = lv_Details_of_Recipients+0(95).
    lv_Details_of_Recipients2 = lv_Details_of_Recipients+95.
    ELSE.
        lv_Details_of_Recipients1 = lv_Details_of_Recipients+0(lv_Details_of_ship_length).
    lv_Details_of_Recipients2 = ''.
    ENDIF.



    wa_final-ship_details-legal_name = wa_ship-c-customername.
    wa_final-ship_details-address1 = lv_Details_of_Recipients1.
    wa_final-ship_details-address2 = lv_Details_of_Recipients2.
    wa_final-ship_details-location = wa_ship-c-CityName.
    wa_final-ship_details-pincode = wa_ship-c-PostalCode.
    wa_final-ship_details-state_code = wa_ship-c-taxnumber3+0(2).


****************************    dispatch details   """"""""""""""""""""""""""""""""""

    SELECT SINGLE FROM
    i_companycode AS a
    FIELDS a~CompanyCodeName
    WHERE a~CompanyCode = @companycode
    INTO @DATA(lv_dispatch_details) PRIVILEGED ACCESS.

    wa_final-dispatch_details-company_name = sellerplantaddress-plant_name1.
    wa_final-dispatch_details-address1    =  sellerplantaddress-addr1.
    wa_final-dispatch_details-address2    =  sellerplantaddress-addr2.
    wa_final-dispatch_details-location     =  sellerplantaddress-city.
*    wa_final-dispatch_details-location     =  'Noida'.   " HARDCODED
*    wa_final-dispatch_details-state_code     =  sellerplantaddress-stcd.
    wa_final-dispatch_details-state_code     =  sellerplantaddress-state_code2.
*    wa_final-dispatch_details-state_code     =  '09'.   " HARDCODED
    wa_final-dispatch_details-pincode      =  sellerplantaddress-pin.


    SELECT FROM I_BillingDocumentItem FIELDS BillingDocument, BillingDocumentItem, BillingDocumentItemText,
    Product, Plant, BillingQuantity, BillingQuantityUnit, DistributionChannel
    WHERE BillingDocument = @document AND CompanyCode = @companycode AND BillingQuantity <> '0'
    INTO TABLE @DATA(lt_item) PRIVILEGED ACCESS.

*************************** ewaybill_details """"""""""""""""""""""""""""

    wa_final-ewaybill_details-transportation_mode = 'Rail'.   " hardocded
    wa_final-ewaybill_details-transportation_distance = '1024'. " hardcoded

***********************    refernce details

*    wa_final-reference_details-document_period_details-invoice_period_end_date =
    wa_final-reference_details-document_period_details-invoice_period_end_date = wa_final-document_details-document_date.  " hardcoded
*    wa_final-reference_details-document_period_details-invoice_period_start_date = wa_final-document_details-document_date.
    wa_final-reference_details-document_period_details-invoice_period_start_date = wa_final-document_details-document_date.  " hardcoded

**************************   preceding document details  """""""""""""""""""""""""""

    DATA : lt_preceding_doc TYPE TABLE OF ty_preceding_document_details.
    DATA : wa_preceding_doc TYPE ty_preceding_document_details.

    wa_preceding_doc-reference_of_original_invoice =  wa_final-document_details-document_number.
    wa_preceding_doc-preceding_invoice_date =  wa_final-document_details-document_date.

    APPEND wa_preceding_doc TO lt_preceding_doc.
    wa_final-preceding_document_details = lt_preceding_doc.

    IF lv_document_details-BillingDocumentType = 'F2' AND ( lv_document_details-DistributionChannel = '20' OR
     lv_document_details-DistributionChannel = '21' OR
     lv_document_details-DistributionChannel = '22' ).
      wa_final-buyer_details-gstin = 'URP'.
      wa_final-buyer_details-state_code = '96'.
      wa_final-buyer_details-pincode   = '999999'.
      wa_final-ship_details-gstin = 'URP'.
      wa_final-ship_details-state_code = '96'.
      wa_final-ship_details-pincode   = '999999'.
      wa_final-export_details-country_code = wa_ship-e-Country.

    ENDIF.

    """""""""""""""""""""""""""""""""""""""""""""   Pricing DATA  """""""""""""""""""""""""""""""""""""""""""


*    delete ADJACENT DUPLICATES FROM lt_item COMPARING



    """""""""""""""""""""""""""""""""""""""""""""'"" line item """"""""""""""""""""""""""""""""
    DATA: total_round TYPE p DECIMALS 2.
    LOOP AT lt_item INTO DATA(bill_item).
      DATA: assessable_value TYPE p DECIMALS 2.
      DATA: unit_price TYPE p DECIMALS 2.
      DATA: total_amount TYPE p DECIMALS 2.

      SELECT FROM i_billingdocumentitemprcgelmnt AS a
      FIELDS
      a~ConditionRatevalue,
      a~ConditionRateAmount,
      a~conditionamount,
      a~conditiontype,
      a~billingdocumentitem,
      a~billingdocument
      WHERE
      a~billingdocument  = @document AND
      a~billingdocumentitem = @bill_item-BillingDocumentItem
      INTO TABLE @DATA(b_item) PRIVILEGED ACCESS.

      SELECT SINGLE conditionbaseamount FROM i_billingdocumentitemprcgelmnt WHERE billingdocument = @bill_item-billingdocument
                                            AND billingdocumentitem = @bill_item-billingdocumentitem AND
        conditionbaseamount IS NOT INITIAL AND  conditiontype IN ( 'JOIG' ,'JOCG' ,'JOSG' ) INTO @DATA(baseamount) PRIVILEGED ACCESS.

      wa_itemlist-item_serial_number    =  bill_item-BillingDocumentItem.   " done
      wa_itemlist-product_description    =  bill_item-billingdocumentitemtext .  " done

      SELECT SINGLE * FROM i_productplantbasic AS a LEFT JOIN i_product AS b ON ( a~product = b~product )
       WHERE a~product = @bill_item-Product AND a~plant = @bill_item-plant  INTO @DATA(hsnsac).

      IF hsnsac-b-producttype = 'SERV'.
        wa_itemlist-hsn_code     =  hsnsac-a-consumptiontaxctrlcode .   " done
      ELSE.
        wa_itemlist-hsn_code      =  hsnsac-a-consumptiontaxctrlcode .   " done
      ENDIF.


      wa_itemlist-quantity        =  bill_item-billingquantity .          " done


      IF bill_item-billingquantityunit           = 'TO' .                 " done
        wa_itemlist-unit       =  'TON' .
      ELSEIF bill_item-billingquantityunit      = 'MTR' .
        wa_itemlist-unit       =  'MTR' .
      ELSEIF bill_item-billingquantityunit     = 'KG' .
        wa_itemlist-unit       =  'KGS' .
      ELSEIF bill_item-billingquantityunit+0(3) = 'BAG' .
        wa_itemlist-unit       =  'BAGS'.
      ELSE .
        wa_itemlist-unit        =  'OTH'.
      ENDIF .

      DATA:unitprice TYPE string,
           totamt    TYPE string.


      """"""""""""""""""""""""""""""""    BASIC PRICE   """"""""""""""""""""""""""""""""""""""""""

      READ TABLE b_item INTO DATA(zbasic) WITH KEY conditiontype = 'ZTIV' billingdocumentitem = bill_item-billingdocumentitem .
      IF sy-subrc = 0.
        totamt     = zbasic-conditionamount.
      ENDIF .

      total_amount = totamt.
      unit_price = totamt / wa_itemlist-quantity.

      SELECT SUM( conditionamount )    FROM i_billingdocumentitemprcgelmnt
             WHERE   conditiontype IN ( 'ZDPQ','ZDPR', 'ZDFA' )
             AND billingdocument = @bill_item-billingdocument AND billingdocumentitem = @bill_item-billingdocumentitem
              INTO @DATA(discount) .

*      SELECT SUM( conditionamount )    FROM i_billingdocumentitemprcgelmnt
*       WHERE   conditiontype IN ( 'ZPFW','ZINS', 'ZLOD','JTC1','JTC2','ZFC','ZFRE' ,'ZFPQ','ZFCP' )
*       AND billingdocument = @bill_item-billingdocument AND billingdocumentitem = @bill_item-billingdocumentitem
*        INTO @DATA(otchg) .

*      wa_itemlist-assamt       = totamt .
*      wa_itemlist-cesnonadvamt = '0'.

      """""""""""""""""""""""""""""""""""""""""""""""TAX DATA*******************************
      READ TABLE b_item INTO DATA(wa_freight) WITH KEY conditiontype = 'ZFRT' billingdocumentitem = bill_item-billingdocumentitem .
      IF sy-subrc EQ 0 .
        DATA(lv_freight) = wa_freight-conditionamount .
      ENDIF.

*      READ TABLE b_item INTO DATA(wa_insu) WITH KEY conditiontype = 'ZINC' billingdocumentitem = bill_item-billingdocumentitem .
*      IF sy-subrc EQ 0 .
*        DATA(lv_insu) = wa_insu-conditionamount.
*      ENDIF.

      SELECT SINGLE
       a~ConditionRateAmount,
       a~ConditionAmount
       FROM i_billingdocumentitemprcgelmnt AS a
       INNER JOIN i_billingdocumentitem AS b
         ON a~billingdocument = b~billingdocument
        AND a~billingdocumentitem = b~billingdocumentitem
       WHERE a~ConditionType IN ( 'ZINC', 'ZINS', 'ZINP' )
         AND a~BillingDocument = @bill_item-billingdocument
         AND a~BillingDocumentItem = @bill_item-billingdocumentitem
          INTO @DATA(wa_insu).
      IF sy-subrc EQ 0 .
        DATA(lv_insu) = wa_insu-conditionamount.
      ENDIF.

*      READ TABLE b_item INTO DATA(zbasicunitprice) WITH KEY a-conditiontype = 'ZBSP' a-billingdocumentitem = bill_item-billingdocumentitem .


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
           AND a~BillingDocument = @bill_item-billingdocument
           AND a~BillingDocumentItem = @bill_item-billingdocumentitem
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
          AND a~BillingDocument = @bill_item-billingdocument
          AND a~BillingDocumentItem = @bill_item-billingdocumentitem
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
               AND a~BillingDocument = @bill_item-billingdocument
               AND a~BillingDocumentItem = @bill_item-billingdocumentitem
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
               AND a~BillingDocument = @bill_item-billingdocument
               AND a~BillingDocumentItem = @bill_item-billingdocumentitem
                INTO @zbasicunitprice.
      ENDIF.

      SELECT SINGLE FROM
      I_BillingDocument AS a
      FIELDS a~AccountingExchangeRate
      WHERE a~BillingDocument = @bill_item-billingdocument
      INTO @DATA(lv_exchange).

      IF lv_document_details-BillingDocumentType = 'F2' AND ( lv_document_details-DistributionChannel = '20' OR
      lv_document_details-DistributionChannel = '21' OR
      lv_document_details-DistributionChannel = '22' ).
        zbasicunitprice-ConditionAmount = zbasicunitprice-ConditionAmount * lv_exchange.
        zbasicunitprice-ConditionRateAmount = zbasicunitprice-ConditionRateAmount * lv_exchange.
      ENDIF.

      unit_price  = zbasicunitprice-ConditionRateAmount.
      total_amount = zbasicunitprice-ConditionAmount.




      READ TABLE b_item INTO DATA(zbasicdis) WITH KEY conditiontype = 'ZDIS' billingdocumentitem = bill_item-billingdocumentitem .
      IF sy-subrc EQ 0.
        wa_itemlist-discount = zbasicdis-ConditionAmount.
      ENDIF.


      READ TABLE b_item INTO DATA(zbasicigst) WITH KEY conditiontype = 'JOIG' billingdocumentitem = bill_item-billingdocumentitem .
      IF sy-subrc EQ 0 .

*        wa_itemlist-igstrt      =  zbasicigst-a-conditionrateratio .
        wa_itemlist-igst_amount    =  zbasicigst-conditionamount ."  * bill_head-accountingexchangerate   .
        wa_itemlist-gst_rate = zbasicigst-ConditionRatevalue.

      ENDIF.

      READ TABLE b_item INTO DATA(zbasiccgst) WITH KEY conditiontype = 'JOCG' billingdocumentitem = bill_item-billingdocumentitem .
      IF sy-subrc EQ 0 .
*        wa_itemlist-cgstrt      =  zbasicgst-a-conditionrateratio." * 2.
        wa_itemlist-cgst_amount    =  zbasiccgst-conditionamount ." * bill_head-accountingexchangerate
        wa_itemlist-gst_rate = zbasiccgst-ConditionRatevalue.  .
      ENDIF.

      READ TABLE b_item INTO DATA(zbasicsgst) WITH KEY conditiontype = 'JOSG' billingdocumentitem = bill_item-billingdocumentitem .
*        wa_itemlist-sgstrt     =  zbasisgst-a-conditionrateratio .
      IF sy-subrc EQ 0 .
        wa_itemlist-sgst_amount    =  zbasicsgst-conditionamount ."* bill_head-accountingexchangerate .
        wa_itemlist-gst_rate = wa_itemlist-gst_rate + zbasicsgst-ConditionRatevalue.

      ENDIF .
*
      READ TABLE b_item INTO DATA(tcs) WITH KEY conditiontype = 'JTC1' billingdocumentitem = bill_item-billingdocumentitem .
      IF sy-subrc EQ 0 .
        DATA(tcsamt) = tcs-conditionamount .
      ENDIF.

      READ TABLE b_item INTO DATA(total_item_value) WITH KEY conditiontype = 'JTCB' billingdocumentitem = bill_item-billingdocumentitem .
      IF sy-subrc EQ 0 .
        wa_itemlist-total_item_value = total_item_value-conditionamount .
      ENDIF.

*      READ TABLE b_item INTO DATA(wa_round) WITH KEY conditiontype = 'ZDIF' billingdocumentitem = bill_item-billingdocumentitem .
*      IF sy-subrc EQ 0 .
*        DATA(lv_round) = wa_round-conditionamount.
*      ENDIF.


      total_amount = total_amount + lv_freight + lv_insu.
*      wa_itemlist-other_charge = lv_freight + lv_insu  + tcsamt .
      assessable_value = total_amount + wa_itemlist-discount + wa_itemlist-other_charge.
*      total_round = total_round + lv_round.



*      wa_itemlist-othchrg              = '0'."otchg  * bill_head-accountingexchangerate .
      wa_final-value_details-total_assessable_value   +=  assessable_value.
      wa_final-value_details-total_igst_value += wa_itemlist-igst_amount .
      wa_final-value_details-total_sgst_value += wa_itemlist-sgst_amount .
      wa_final-value_details-total_cgst_value += wa_itemlist-cgst_amount .
*      wa_final-otheramount             = '0'."wa_final-otheramount + wa_itemlist-othchrg.
*      wa_final-othertcsamount          = wa_final-othertcsamount + tcsamt .
*      wa_final-value_details-total_discount +=  wa_itemlist-discount.
      wa_final-value_details-total_invoice_value  += assessable_value +
                                         wa_itemlist-igst_amount + wa_itemlist-cgst_amount +
                                         wa_itemlist-sgst_amount.


*      IF wa_itemlist-cgstrt IS INITIAL.
*        wa_itemlist-cgstrt = '0'.
*      ENDIF.
      IF wa_itemlist-cgst_amount IS INITIAL.
        wa_itemlist-cgst_amount = '0'.
      ENDIF.
*      IF wa_itemlist-sgstrt IS INITIAL.
*        wa_itemlist-sgstrt = '0'.
*      ENDIF.
      IF wa_itemlist-sgst_amount IS INITIAL.
        wa_itemlist-sgst_amount = '0'.
      ENDIF.
*      IF wa_itemlist-igstrt IS INITIAL.
*        wa_itemlist-igstrt = '0'.
*      ENDIF.
      IF wa_itemlist-igst_amount IS INITIAL.
        wa_itemlist-igst_amount = '0'.
      ENDIF.
*      IF wa_itemlist-cesrt IS INITIAL.
*        wa_itemlist-cesrt = '0'.
*      ENDIF.
*      IF wa_itemlist- IS INITIAL.
*        wa_itemlist-cesamt = '0'.
*      ENDIF.
      IF wa_itemlist-other_charge IS INITIAL.
        wa_itemlist-other_charge = '0'.
      ENDIF.
      IF wa_itemlist-cess_nonadvol_amount IS INITIAL.
        wa_itemlist-cess_nonadvol_amount = '0'.
      ENDIF.


      """"" is_service

      wa_itemlist-is_service = 'N'.
      IF bill_item-DistributionChannel = '15'.
        wa_itemlist-is_service = 'Y'.
      ENDIF.
*      wa_itemlist-total_item_value = wa_itemlist-assessable_value * (  1 + ( wa_itemlist-gst_rate ) + wa_itemlist-cess_nonadvol_amount ).
      wa_itemlist-total_item_value = assessable_value + wa_itemlist-sgst_amount +
      wa_itemlist-cgst_amount + wa_itemlist-igst_amount.

      wa_itemlist-total_amount = total_amount.
      wa_itemlist-unit_price = unit_price.
      wa_itemlist-assessable_value = assessable_value.

      APPEND wa_itemlist TO it_itemlist.
      CLEAR :  wa_itemlist ,tcsamt,discount,unitprice ,totamt.
      CLEAR b_item.
    ENDLOOP.

    DATA: lv_total TYPE i_billingdocumentitemprcgelmnt-ConditionAmount.
    lv_total = wa_final-value_details-total_invoice_value.
    DATA: result0 TYPE p DECIMALS 0.
    DATA: result2 TYPE p DECIMALS 2.
    DATA: lv_round TYPE p DECIMALS 2.
    result0 = lv_total.
    result2 = lv_total.
    lv_round = result0 - result2.

    wa_final-value_details-total_invoice_value = wa_final-value_details-total_invoice_value + lv_round.


    wa_final-value_details-round_off_amount = lv_round.

    wa_final-item_list = it_itemlist.

    DATA:json TYPE REF TO if_xco_cp_json_data.

    xco_cp_json=>data->from_abap(
      EXPORTING
        ia_abap      = wa_final
      RECEIVING
        ro_json_data = json   ).
    json->to_string(
      RECEIVING
        rv_string =   DATA(lv_string) ).

*   DATA(lv_json) = /ui2/cl_json=>serialize( data = lv_string compress = abap_true pretty_name = /ui2/cl_json=>pretty_mode-low_case ).

*    REPLACE ALL OCCURRENCES OF REGEX '"([A-Z0-9_]+)"\s*:' IN lv_string WITH '"\L\1":'.


    REPLACE ALL OCCURRENCES OF '"USER_GSTIN"' IN lv_string WITH '"user_gstin"'.
    REPLACE ALL OCCURRENCES OF '"DATA_SOURCE"' IN lv_string WITH '"data_source"'.
    REPLACE ALL OCCURRENCES OF '"TRANSACTION_DETAILS"' IN lv_string WITH '"transaction_details"'.
    REPLACE ALL OCCURRENCES OF '"SUPPLY_TYPE"' IN lv_string WITH '"supply_type"'.
    REPLACE ALL OCCURRENCES OF '"CHARGE_TYPE"' IN lv_string WITH '"charge_type"'.
    REPLACE ALL OCCURRENCES OF '"IGST_ON_INTRA"' IN lv_string WITH '"igst_on_intra"'.
    REPLACE ALL OCCURRENCES OF '"ECOMMERCE_GSTIN"' IN lv_string WITH '"ecommerce_gstin"'.

    REPLACE ALL OCCURRENCES OF '"DOCUMENT_DETAILS"' IN lv_string WITH '"document_details"'.
    REPLACE ALL OCCURRENCES OF '"DOCUMENT_TYPE"' IN lv_string WITH '"document_type"'.
    REPLACE ALL OCCURRENCES OF '"DOCUMENT_NUMBER"' IN lv_string WITH '"document_number"'.
    REPLACE ALL OCCURRENCES OF '"DOCUMENT_DATE"' IN lv_string WITH '"document_date"'.

    REPLACE ALL OCCURRENCES OF '"SELLER_DETAILS"' IN lv_string WITH '"seller_details"'.
    REPLACE ALL OCCURRENCES OF '"GSTIN"' IN lv_string WITH '"gstin"'.
    REPLACE ALL OCCURRENCES OF '"LEGAL_NAME"' IN lv_string WITH '"legal_name"'.
    REPLACE ALL OCCURRENCES OF '"TRADE_NAME"' IN lv_string WITH '"trade_name"'.
    REPLACE ALL OCCURRENCES OF '"ADDRESS1"' IN lv_string WITH '"address1"'.
    REPLACE ALL OCCURRENCES OF '"ADDRESS2"' IN lv_string WITH '"address2"'.
    REPLACE ALL OCCURRENCES OF '"LOCATION"' IN lv_string WITH '"location"'.
    REPLACE ALL OCCURRENCES OF '"PINCODE"' IN lv_string WITH '"pincode"'.
    REPLACE ALL OCCURRENCES OF '"STATE_CODE"' IN lv_string WITH '"state_code"'.
    REPLACE ALL OCCURRENCES OF '"PHONE_NUMBER"' IN lv_string WITH '"phone_number"'.
    REPLACE ALL OCCURRENCES OF '"EMAIL"' IN lv_string WITH '"email"'.

    REPLACE ALL OCCURRENCES OF '"BUYER_DETAILS"' IN lv_string WITH '"buyer_details"'.
    REPLACE ALL OCCURRENCES OF '"PLACE_OF_SUPPLY"' IN lv_string WITH '"place_of_supply"'.

    REPLACE ALL OCCURRENCES OF '"DISPATCH_DETAILS"' IN lv_string WITH '"dispatch_details"'.
    REPLACE ALL OCCURRENCES OF '"COMPANY_NAME"' IN lv_string WITH '"company_name"'.

    REPLACE ALL OCCURRENCES OF '"SHIP_DETAILS"' IN lv_string WITH '"ship_details"'.

    REPLACE ALL OCCURRENCES OF '"EXPORT_DETAILS"' IN lv_string WITH '"export_details"'.
    REPLACE ALL OCCURRENCES OF '"SHIP_BILL_NUMBER"' IN lv_string WITH '"ship_bill_number"'.
    REPLACE ALL OCCURRENCES OF '"SHIP_BILL_DATE"' IN lv_string WITH '"ship_bill_date"'.
    REPLACE ALL OCCURRENCES OF '"COUNTRY_CODE"' IN lv_string WITH '"country_code"'.
    REPLACE ALL OCCURRENCES OF '"FOREIGN_CURRENCY"' IN lv_string WITH '"foreign_currency"'.
    REPLACE ALL OCCURRENCES OF '"REFUND_CLAIM"' IN lv_string WITH '"refund_claim"'.
    REPLACE ALL OCCURRENCES OF '"PORT_CODE"' IN lv_string WITH '"port_code"'.
    REPLACE ALL OCCURRENCES OF '"EXPORT_DUTY"' IN lv_string WITH '"export_duty"'.

    REPLACE ALL OCCURRENCES OF '"PAYMENT_DETAILS"' IN lv_string WITH '"payment_details"'.
    REPLACE ALL OCCURRENCES OF '"BANK_ACCOUNT_NUMBER"' IN lv_string WITH '"bank_account_number"'.
    REPLACE ALL OCCURRENCES OF '"PAID_BALANCE_AMOUNT"' IN lv_string WITH '"paid_balance_amount"'.
    REPLACE ALL OCCURRENCES OF '"CREDIT_DAYS"' IN lv_string WITH '"credit_days"'.
    REPLACE ALL OCCURRENCES OF '"CREDIT_TRANSFER"' IN lv_string WITH '"credit_transfer"'.
    REPLACE ALL OCCURRENCES OF '"DIRECT_DEBIT"' IN lv_string WITH '"direct_debit"'.
    REPLACE ALL OCCURRENCES OF '"BRANCH_OR_IFSC"' IN lv_string WITH '"branch_or_ifsc"'.
    REPLACE ALL OCCURRENCES OF '"PAYMENT_MODE"' IN lv_string WITH '"payment_mode"'.
    REPLACE ALL OCCURRENCES OF '"PAYEE_NAME"' IN lv_string WITH '"payee_name"'.
    REPLACE ALL OCCURRENCES OF '"OUTSTANDING_AMOUNT"' IN lv_string WITH '"outstanding_amount"'.
    REPLACE ALL OCCURRENCES OF '"PAYMENT_INSTRUCTION"' IN lv_string WITH '"payment_instruction"'.
    REPLACE ALL OCCURRENCES OF '"PAYMENT_TERM"' IN lv_string WITH '"payment_term"'.

    REPLACE ALL OCCURRENCES OF '"REFERENCE_DETAILS"' IN lv_string WITH '"reference_details"'.
    REPLACE ALL OCCURRENCES OF '"INVOICE_REMARKS"' IN lv_string WITH '"invoice_remarks"'.

    REPLACE ALL OCCURRENCES OF '"ADDITIONAL_DOCUMENT_DETAILS"' IN lv_string WITH '"additional_document_details"'.

    REPLACE ALL OCCURRENCES OF '"EWAYBILL_DETAILS"' IN lv_string WITH '"ewaybill_details"'.

    REPLACE ALL OCCURRENCES OF '"VALUE_DETAILS"' IN lv_string WITH '"value_details"'.

    REPLACE ALL OCCURRENCES OF '"ITEM_LIST"' IN lv_string WITH '"item_list"'.
    REPLACE ALL OCCURRENCES OF '"REFERENCE_DETAILS"' IN lv_string WITH '"reference_details"'.
    REPLACE ALL OCCURRENCES OF '"INVOICE_REMARKS"' IN lv_string WITH '"invoice_remarks"'.
    REPLACE ALL OCCURRENCES OF '"DOCUMENT_PERIOD_DETAILS"' IN lv_string WITH '"document_period_details"'.
    REPLACE ALL OCCURRENCES OF '"INVOICE_PERIOD_START_DATE"' IN lv_string WITH '"invoice_period_start_date"'.
    REPLACE ALL OCCURRENCES OF '"INVOICE_PERIOD_END_DATE"' IN lv_string WITH '"invoice_period_end_date"'.

    REPLACE ALL OCCURRENCES OF '"PRECEDING_DOCUMENT_DETAILS"' IN lv_string WITH '"preceding_document_details"'.
    REPLACE ALL OCCURRENCES OF '"REFERENCE_OF_ORIGINAL_INVOICE"' IN lv_string WITH '"reference_of_original_invoice"'.
    REPLACE ALL OCCURRENCES OF '"PRECEDING_INVOICE_DATE"' IN lv_string WITH '"preceding_invoice_date"'.
    REPLACE ALL OCCURRENCES OF '"OTHER_REFERENCE"' IN lv_string WITH '"other_reference"'.

    REPLACE ALL OCCURRENCES OF '"CONTRACT_DETAILS"' IN lv_string WITH '"contract_details"'.
    REPLACE ALL OCCURRENCES OF '"RECEIPT_ADVICE_NUMBER"' IN lv_string WITH '"receipt_advice_number"'.
    REPLACE ALL OCCURRENCES OF '"RECEIPT_ADVICE_DATE"' IN lv_string WITH '"receipt_advice_date"'.
    REPLACE ALL OCCURRENCES OF '"BATCH_REFERENCE_NUMBER"' IN lv_string WITH '"batch_reference_number"'.
    REPLACE ALL OCCURRENCES OF '"CONTRACT_REFERENCE_NUMBER"' IN lv_string WITH '"contract_reference_number"'.
    REPLACE ALL OCCURRENCES OF '"PROJECT_REFERENCE_NUMBER"' IN lv_string WITH '"project_reference_number"'.
    REPLACE ALL OCCURRENCES OF '"VENDOR_PO_REFERENCE_NUMBER"' IN lv_string WITH '"vendor_po_reference_number"'.
    REPLACE ALL OCCURRENCES OF '"VENDOR_PO_REFERENCE_DATE"' IN lv_string WITH '"vendor_po_reference_date"'.

    REPLACE ALL OCCURRENCES OF '"ADDITIONAL_DOCUMENT_DETAILS"' IN lv_string WITH '"additional_document_details"'.
    REPLACE ALL OCCURRENCES OF '"SUPPORTING_DOCUMENT_URL"' IN lv_string WITH '"supporting_document_url"'.
    REPLACE ALL OCCURRENCES OF '"SUPPORTING_DOCUMENT"' IN lv_string WITH '"supporting_document"'.
    REPLACE ALL OCCURRENCES OF '"ADDITIONAL_INFORMATION"' IN lv_string WITH '"additional_information"'.

    REPLACE ALL OCCURRENCES OF '"EWAYBILL_DETAILS"' IN lv_string WITH '"ewaybill_details"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTER_ID"' IN lv_string WITH '"transporter_id"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTER_NAME"' IN lv_string WITH '"transporter_name"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTATION_MODE"' IN lv_string WITH '"transportation_mode"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTATION_DISTANCE"' IN lv_string WITH '"transportation_distance"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTER_DOCUMENT_NUMBER"' IN lv_string WITH '"transporter_document_number"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTER_DOCUMENT_DATE"' IN lv_string WITH '"transporter_document_date"'.
    REPLACE ALL OCCURRENCES OF '"VEHICLE_NUMBER"' IN lv_string WITH '"vehicle_number"'.
    REPLACE ALL OCCURRENCES OF '"VEHICLE_TYPE"' IN lv_string WITH '"vehicle_type"'.

    REPLACE ALL OCCURRENCES OF '"VALUE_DETAILS"' IN lv_string WITH '"value_details"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_ASSESSABLE_VALUE"' IN lv_string WITH '"total_assessable_value"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_CGST_VALUE"' IN lv_string WITH '"total_cgst_value"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_SGST_VALUE"' IN lv_string WITH '"total_sgst_value"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_IGST_VALUE"' IN lv_string WITH '"total_igst_value"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_CESS_VALUE"' IN lv_string WITH '"total_cess_value"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_INVOICE_VALUE"' IN lv_string WITH '"total_invoice_value"'.

    REPLACE ALL OCCURRENCES OF '"ITEM_LIST"' IN lv_string WITH '"item_list"'.
    REPLACE ALL OCCURRENCES OF '"ITEM_SERIAL_NUMBER"' IN lv_string WITH '"item_serial_number"'.
    REPLACE ALL OCCURRENCES OF '"PRODUCT_DESCRIPTION"' IN lv_string WITH '"product_description"'.
    REPLACE ALL OCCURRENCES OF '"IS_SERVICE"' IN lv_string WITH '"is_service"'.
    REPLACE ALL OCCURRENCES OF '"HSN_CODE"' IN lv_string WITH '"hsn_code"'.
    REPLACE ALL OCCURRENCES OF '"BAR_CODE"' IN lv_string WITH '"bar_code"'.
    REPLACE ALL OCCURRENCES OF '"QUANTITY"' IN lv_string WITH '"quantity"'.
    REPLACE ALL OCCURRENCES OF '"FREE_QUANTITY"' IN lv_string WITH '"free_quantity"'.
    REPLACE ALL OCCURRENCES OF '"UNIT"' IN lv_string WITH '"unit"'.

    REPLACE ALL OCCURRENCES OF '"UNIT_PRICE"' IN lv_string WITH '"unit_price"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_AMOUNT"' IN lv_string WITH '"total_amount"'.

    REPLACE ALL OCCURRENCES OF '"TOTAL_CESS_VALUE_OF_STATE"' IN lv_string WITH '"total_cess_value_of_state"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_DISCOUNT"' IN lv_string WITH '"total_discount"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_OTHER_CHARGE"' IN lv_string WITH '"total_other_charge"'.
    REPLACE ALL OCCURRENCES OF '"ROUND_OFF_AMOUNT"' IN lv_string WITH '"round_off_amount"'.
    REPLACE ALL OCCURRENCES OF '"TOT_INV_VAL_ADDITIONAL_CURR"' IN lv_string WITH '"tot_inv_val_additional_curr"'.
    REPLACE ALL OCCURRENCES OF '"PRE_TAX_VALUE"' IN lv_string WITH '"pre_tax_value"'.
    REPLACE ALL OCCURRENCES OF '"DISCOUNT"' IN lv_string WITH '"discount"'.
    REPLACE ALL OCCURRENCES OF '"OTHER_CHARGE"' IN lv_string WITH '"other_charge"'.
    REPLACE ALL OCCURRENCES OF '"ASSESSABLE_VALUE"' IN lv_string WITH '"assessable_value"'.
    REPLACE ALL OCCURRENCES OF '"GST_RATE"' IN lv_string WITH '"gst_rate"'.
    REPLACE ALL OCCURRENCES OF '"IGST_AMOUNT"' IN lv_string WITH '"igst_amount"'.
    REPLACE ALL OCCURRENCES OF '"CGST_AMOUNT"' IN lv_string WITH '"cgst_amount"'.
    REPLACE ALL OCCURRENCES OF '"SGST_AMOUNT"' IN lv_string WITH '"sgst_amount"'.
    REPLACE ALL OCCURRENCES OF '"CESS_RATE"' IN lv_string WITH '"cess_rate"'.
    REPLACE ALL OCCURRENCES OF '"CESS_AMOUNT"' IN lv_string WITH '"cess_amount"'.
    REPLACE ALL OCCURRENCES OF '"CESS_NONADVOL_AMOUNT"' IN lv_string WITH '"cess_nonadvol_amount"'.
    REPLACE ALL OCCURRENCES OF '"STATE_CESS_AMOUNT"' IN lv_string WITH '"state_cess_amount"'.
    REPLACE ALL OCCURRENCES OF '"STATE_CESS_NONADVOL_AMOUNT"' IN lv_string WITH '"state_cess_nonadvol_amount"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_ITEM_VALUE"' IN lv_string WITH '"total_item_value"'.
    REPLACE ALL OCCURRENCES OF '"COUNTRY_ORIGIN"' IN lv_string WITH '"country_origin"'.
    REPLACE ALL OCCURRENCES OF '"ORDER_LINE_REFERENCE"' IN lv_string WITH '"order_line_reference"'.
    REPLACE ALL OCCURRENCES OF '"PRODUCT_SERIAL_NUMBER"' IN lv_string WITH '"product_serial_number"'.
    REPLACE ALL OCCURRENCES OF '"BATCH_DETAILS"' IN lv_string WITH '"batch_details"'.
    REPLACE ALL OCCURRENCES OF '"NAME"' IN lv_string WITH '"name"'.
    REPLACE ALL OCCURRENCES OF '"EXPIRY_DATE"' IN lv_string WITH '"expiry_date"'.
    REPLACE ALL OCCURRENCES OF '"WARRANTY_DATE"' IN lv_string WITH '"warranty_date"'.
    REPLACE ALL OCCURRENCES OF '"ATTRIBUTE_DETAILS"' IN lv_string WITH '"attribute_details"'.
    REPLACE ALL OCCURRENCES OF '"ITEM_ATTRIBUTE_DETAILS"' IN lv_string WITH '"item_attribute_details"'.
    REPLACE ALL OCCURRENCES OF '"ITEM_ATTRIBUTE_VALUE"' IN lv_string WITH '"item_attribute_value"'.


    result = lv_string.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    DATA : wa_final TYPE ty_body.
    DATA: it_itemlist TYPE TABLE OF ty_item_list,
          wa_itemlist TYPE ty_item_list.

*****************   user gstin
    DATA: var1 TYPE i_billingdocument-BillingDocument.
    var1 = '0090000011'.
    DATA: var2 TYPE i_billingdocument-CompanyCode.
    var2 = 'GT00'.
    SELECT SINGLE FROM i_billingdocument AS a
    INNER JOIN I_BillingDocumentItem AS b ON a~BillingDocument = b~BillingDocument
    FIELDS b~plant
    WHERE a~BillingDocument = @var1 AND
    a~CompanyCode = @var2
*    AND b~BillingDocumentType NOT IN ( 'S1','S2' )
    INTO @DATA(lv_user_gstin) PRIVILEGED ACCESS.

*    IF lv_user_gstin = 'GH01'.
*      wa_final-user_gstin = '19AABCG1667P1Z2'.
*    ELSEIF lv_user_gstin = 'GF01'.
*      wa_final-user_gstin = '19AABCG1667P1Z2'.
*    ELSEIF lv_user_gstin = 'GM01'.
*      wa_final-user_gstin = '19AABCG1667P1Z2'.
*    ELSEIF lv_user_gstin = 'GM30'.
*      wa_final-user_gstin = '19AABCG1667P1Z2'.
*    ELSEIF lv_user_gstin = 'GE01'.
*      wa_final-user_gstin = '19AABCG1667P1Z2'.
*    ELSEIF lv_user_gstin = 'GW01'.
*      wa_final-user_gstin = '27AABCG1667P1Z5'.
*    ELSEIF lv_user_gstin = 'GW02'.
*      wa_final-user_gstin = '27AABCG1667P1Z5'.
*    ELSEIF lv_user_gstin = 'GT01'.
*      wa_final-user_gstin = '19AABCG1667P1Z2'.
*    ELSE.
*      wa_final-user_gstin = ''.
*    ENDIF.

    wa_final-user_gstin = '09AAAPG7885R002'.     " hardcoded


**************************    transaction details

    SELECT SINGLE FROM i_billingdocument AS a
    INNER JOIN I_BillingDocumentItem AS b ON a~BillingDocument = b~BillingDocument
    FIELDS b~DistributionChannel
    WHERE a~BillingDocument = @var1 AND
    a~CompanyCode = @var2
*    AND b~BillingDocumentType NOT IN ( 'S1','S2' )
    INTO @DATA(lv_trans_details) PRIVILEGED ACCESS.

    IF lv_trans_details = 11 OR lv_trans_details = 12 OR lv_trans_details = 13 OR lv_trans_details = 14
    OR lv_trans_details = 15 OR lv_trans_details = 16.
      wa_final-transaction_details-supply_type = 'B2B'.
    ELSE.
      wa_final-transaction_details-supply_type = 'EXPWP'.
    ENDIF.


********************************document details


    SELECT SINGLE FROM i_billingdocument AS a
    INNER JOIN I_BillingDocumentItem AS b ON a~BillingDocument = b~BillingDocument
    FIELDS a~BillingDocument,
    a~BillingDocumentType,
    a~BillingDocumentDate,
    b~Plant
    WHERE a~BillingDocument = @var1
*    AND b~BillingDocumentType NOT IN ( 'S1','S2' )
    INTO @DATA(lv_document_details) PRIVILEGED ACCESS.

    IF lv_document_details = 'F2' OR lv_document_details = 'CBRE' OR lv_document_details = 'JSTO'.
      wa_final-document_details-document_type = 'INV'.
    ELSEIF lv_document_details = 'G2'.
      wa_final-document_details-document_type = 'CRN'.
    ELSEIF lv_document_details = 'L2'.
      wa_final-document_details-document_type = 'DBN'.
    ENDIF.
    wa_final-document_details-document_type = 'INV'.    " HARDCODED
    wa_final-document_details-document_number = lv_document_details-BillingDocument.
    wa_final-document_details-document_number = 'Acx/56796'.    " HARDCODED
    wa_final-document_details-document_date = lv_document_details-BillingDocumentDate.
    wa_final-document_details-document_date = '23/02/2025'.

***************************************seller detials

    SELECT SINGLE a~addressid,
                  b~addresssearchterm2 AS gstin,
                  b~careofname AS lglnm,
                  b~streetname AS addr1,
                  b~cityname AS addr2,
                  b~districtname AS city,
                  b~postalcode AS pin,
                  b~region AS stcd
    FROM i_plant AS a
    LEFT JOIN i_address_2 AS b ON ( a~addressid = b~addressid )
    WHERE plant = @lv_document_details-plant INTO @DATA(sellerplantaddress) PRIVILEGED ACCESS.

    wa_final-seller_details-gstin    =  sellerplantaddress-gstin.
    wa_final-seller_details-gstin    =  '09AAAPG7885R002'.   " HARDCODED
    wa_final-seller_details-legal_name  =  sellerplantaddress-lglnm.
    wa_final-seller_details-legal_name  =  'MastersIndia UP'.  " HARDCODED
    wa_final-seller_details-trade_name =  sellerplantaddress-lglnm.
    wa_final-seller_details-address1    =  sellerplantaddress-addr1.
    wa_final-seller_details-address2    =  sellerplantaddress-addr2 .
    wa_final-seller_details-location      =  sellerplantaddress-city .
    wa_final-seller_details-location      =  '1279' .   " HARDCODED
    wa_final-seller_details-state_code     =  sellerplantaddress-stcd.
    wa_final-seller_details-state_code     =  '09'.    " HARDCODED
    wa_final-seller_details-pincode      =  sellerplantaddress-pin.


*******************************    buyer details

    SELECT SINGLE * FROM i_billingdocumentpartner AS a  INNER JOIN i_customer AS
            b ON ( a~customer = b~customer  ) WHERE a~billingdocument = @var1
             AND a~partnerfunction = 'RE' INTO  @DATA(buyeradd) PRIVILEGED ACCESS.

    wa_final-buyer_details-gstin = buyeradd-b-taxnumber3.
    wa_final-buyer_details-gstin = '05AAAPG7885R002'.   " HARDCODED
    wa_final-buyer_details-legal_name = buyeradd-b-customername.
    wa_final-buyer_details-trade_name = buyeradd-b-customername.
    IF wa_final-buyer_details-gstin <> ''.
      wa_final-buyer_details-place_of_supply = wa_final-buyer_details-gstin+0(2).
    ENDIF.
    wa_final-buyer_details-address1 = buyeradd-b-customerfullname.
    wa_final-buyer_details-address2 = ''.
    wa_final-buyer_details-location   = buyeradd-b-cityname .
    wa_final-buyer_details-pincode   = buyeradd-b-postalcode  .
    wa_final-buyer_details-state_code  = buyeradd-b-region  .
    wa_final-buyer_details-state_code  =  '05'.    " HARDCODED


****************************    dispatch details

    SELECT SINGLE FROM
    i_companycode AS a
    FIELDS a~CompanyCodeName
    WHERE a~CompanyCode = @var2
    INTO @DATA(lv_dispatch_details).

    wa_final-dispatch_details-company_name = lv_dispatch_details.
    wa_final-dispatch_details-address1    =  sellerplantaddress-addr1.
    wa_final-dispatch_details-address2    =  sellerplantaddress-addr2.
    wa_final-dispatch_details-location     =  sellerplantaddress-city.
    wa_final-dispatch_details-location     =  'Noida'.   " HARDCODED
    wa_final-dispatch_details-state_code     =  sellerplantaddress-stcd.
    wa_final-dispatch_details-state_code     =  '09'.   " HARDCODED
    wa_final-dispatch_details-pincode      =  sellerplantaddress-pin.


    SELECT FROM I_BillingDocumentItem
    FIELDS BillingDocument, BillingDocumentItem, Product, BillingDocumentItemText, BillingDocumentType,
    BillingQuantity, BillingQuantityUnit, Plant
    WHERE BillingDocument = @var1 AND CompanyCode = @var2
    INTO TABLE @DATA(lt_item) PRIVILEGED ACCESS.

***************************ewaybill_details

    wa_final-ewaybill_details-transportation_mode = 'Rail'.
    wa_final-ewaybill_details-transportation_distance = '1024'.

***********************    refernce details

    wa_final-reference_details-document_period_details-invoice_period_end_date = wa_final-document_details-document_date.
    wa_final-reference_details-document_period_details-invoice_period_end_date = '23/02/2025'.
    wa_final-reference_details-document_period_details-invoice_period_start_date = wa_final-document_details-document_date.
    wa_final-reference_details-document_period_details-invoice_period_start_date = '23/02/2025'.

**************************preceding document details

    DATA : lt_preceding_doc TYPE TABLE OF ty_preceding_document_details.
    DATA : wa_preceding_doc TYPE ty_preceding_document_details.

    wa_preceding_doc-reference_of_original_invoice =  wa_final-document_details-document_number.
    wa_preceding_doc-preceding_invoice_date =  wa_final-document_details-document_date.

    APPEND wa_preceding_doc TO lt_preceding_doc.
    wa_final-preceding_document_details = lt_preceding_doc.

*************Pricing DATA

    SELECT * FROM i_billingdocumentitemprcgelmnt AS a  INNER JOIN   i_billingdocumentitem AS b
    ON ( a~billingdocument = b~billingdocument  )  WHERE
    a~billingdocument  = @var1 AND billingquantity NE '' INTO TABLE @DATA(b_item) PRIVILEGED ACCESS.

    LOOP AT lt_item INTO DATA(bill_item).

      SELECT SINGLE conditionbaseamount FROM i_billingdocumentitemprcgelmnt WHERE billingdocument = @bill_item-billingdocument
                                            AND billingdocumentitem = @bill_item-billingdocumentitem AND
        conditionbaseamount IS NOT INITIAL AND  conditiontype IN ( 'JOIG' ,'JOCG' ,'JOSG' ) INTO @DATA(baseamount) PRIVILEGED ACCESS.

      wa_itemlist-item_serial_number    =  bill_item-BillingDocumentItem.
      wa_itemlist-product_description    =  bill_item-billingdocumentitemtext .

      SELECT SINGLE * FROM i_productplantbasic AS a LEFT JOIN i_product AS b ON ( a~product = b~product )
       WHERE a~product = @bill_item-Product AND a~plant = @bill_item-plant  INTO @DATA(hsnsac).

      IF hsnsac-b-producttype = 'SERV'.
        wa_itemlist-hsn_code     =  hsnsac-a-consumptiontaxctrlcode .
      ELSE.
        wa_itemlist-hsn_code      =  hsnsac-a-consumptiontaxctrlcode .
      ENDIF.


      wa_itemlist-quantity        =  bill_item-billingquantity .

      IF bill_item-billingquantityunit           = 'TO' .
        wa_itemlist-unit       =  'TON' .
      ELSEIF bill_item-billingquantityunit      = 'MTR' .
        wa_itemlist-unit       =  'MTR' .
      ELSEIF bill_item-billingquantityunit     = 'KG' .
        wa_itemlist-unit       =  'KGS' .
      ELSEIF bill_item-billingquantityunit+0(3) = 'BAG' .
        wa_itemlist-unit       =  'BAGS'.
      ELSE .
        wa_itemlist-unit        =  'OTH'.
      ENDIF .

      DATA:unitprice TYPE string,
           totamt    TYPE string.


      """""""""""""""""""""BASIC PRICE""""""""""""""""""""""""""
      READ TABLE b_item INTO DATA(zbasic) WITH KEY a-conditiontype = 'ZTIV' a-billingdocumentitem = bill_item-billingdocumentitem .
      IF sy-subrc = 0.
        totamt     = zbasic-a-conditionamount.
      ENDIF .
      wa_itemlist-total_amount = totamt.
      wa_itemlist-unit_price = totamt / wa_itemlist-quantity.
      SELECT SUM( conditionamount )    FROM i_billingdocumentitemprcgelmnt
             WHERE   conditiontype IN ( 'ZDPQ','ZDPR', 'ZDFA' )
             AND billingdocument = @bill_item-billingdocument AND billingdocumentitem = @bill_item-billingdocumentitem
              INTO @DATA(discount) .

*      SELECT SUM( conditionamount )    FROM i_billingdocumentitemprcgelmnt
*       WHERE   conditiontype IN ( 'ZPFW','ZINS', 'ZLOD','JTC1','JTC2','ZFC','ZFRE' ,'ZFPQ','ZFCP' )
*       AND billingdocument = @bill_item-billingdocument AND billingdocumentitem = @bill_item-billingdocumentitem
*        INTO @DATA(otchg) .

*      wa_itemlist-assamt       = totamt .
*      wa_itemlist-cesnonadvamt = '0'.

      """""""""""""""""""""""""""""""""""""""""""""""TAX DATA*******************************
      READ TABLE b_item INTO DATA(zbasicigst) WITH KEY a-conditiontype = 'JOIG'  a-billingdocumentitem = bill_item-billingdocumentitem .
      IF sy-subrc EQ 0 .

*        wa_itemlist-igstrt      =  zbasicigst-a-conditionrateratio .
        wa_itemlist-igst_amount    =  zbasicigst-a-conditionamount ."  * bill_head-accountingexchangerate   .
        wa_itemlist-gst_rate = zbasicigst-a-ConditionRateAmount.

      ELSE.

        READ TABLE b_item INTO DATA(zbasicgst) WITH KEY a-conditiontype = 'JOCG'  a-billingdocumentitem = bill_item-billingdocumentitem .
*        wa_itemlist-cgstrt      =  zbasicgst-a-conditionrateratio." * 2.
        wa_itemlist-cgst_amount    =  zbasicgst-a-conditionamount ." * bill_head-accountingexchangerate
        wa_itemlist-gst_rate = zbasicgst-a-ConditionRateAmount.  .

        READ TABLE b_item INTO DATA(zbasisgst) WITH KEY a-conditiontype = 'JOSG'   a-billingdocumentitem = bill_item-billingdocumentitem .
*        wa_itemlist-sgstrt     =  zbasisgst-a-conditionrateratio .
        wa_itemlist-sgst_amount    =  zbasisgst-a-conditionamount ."* bill_head-accountingexchangerate .
        wa_itemlist-gst_rate = zbasisgst-a-ConditionRateAmount.

      ENDIF .
*
      READ TABLE b_item INTO DATA(tcs) WITH KEY a-conditiontype = 'JTC1'  a-billingdocumentitem = bill_item-billingdocumentitem .
      IF sy-subrc EQ 0 .
        DATA(tcsamt) = tcs-a-conditionamount .
      ENDIF.

*      wa_itemlist-othchrg              = '0'."otchg  * bill_head-accountingexchangerate .
      wa_final-value_details-total_assessable_value   +=  wa_itemlist-assessable_value.
      wa_final-value_details-total_igst_value += wa_itemlist-igst_amount .
      wa_final-value_details-total_sgst_value += wa_itemlist-sgst_amount .
      wa_final-value_details-total_cgst_value += wa_itemlist-cgst_amount .
*      wa_final-otheramount             = '0'."wa_final-otheramount + wa_itemlist-othchrg.
*      wa_final-othertcsamount          = wa_final-othertcsamount + tcsamt .
      wa_final-value_details-total_invoice_value      += wa_itemlist-assessable_value +
                                         wa_itemlist-igst_amount + wa_itemlist-cgst_amount +
                                         wa_itemlist-sgst_amount + wa_itemlist-other_charge + tcsamt.



*      IF wa_itemlist-cgstrt IS INITIAL.
*        wa_itemlist-cgstrt = '0'.
*      ENDIF.
      IF wa_itemlist-cgst_amount IS INITIAL.
        wa_itemlist-cgst_amount = '0'.
      ENDIF.
      wa_itemlist-cgst_amount = '0'.
*      IF wa_itemlist-sgstrt IS INITIAL.
*        wa_itemlist-sgstrt = '0'.
*      ENDIF.
      IF wa_itemlist-sgst_amount IS INITIAL.
        wa_itemlist-sgst_amount = '0'.
      ENDIF.
      wa_itemlist-sgst_amount = '0'.
*      IF wa_itemlist-igstrt IS INITIAL.
*        wa_itemlist-igstrt = '0'.
*      ENDIF.
      IF wa_itemlist-igst_amount IS INITIAL.
        wa_itemlist-igst_amount = '0'.
      ENDIF.
      wa_itemlist-igst_amount = '0'.
*      IF wa_itemlist-cesrt IS INITIAL.
*        wa_itemlist-cesrt = '0'.
*      ENDIF.
*      IF wa_itemlist- IS INITIAL.
*        wa_itemlist-cesamt = '0'.
*      ENDIF.
      IF wa_itemlist-other_charge IS INITIAL.
        wa_itemlist-other_charge = '0'.
      ENDIF.
      IF wa_itemlist-cess_nonadvol_amount IS INITIAL.
        wa_itemlist-cess_nonadvol_amount = '0'.
      ENDIF.


      """"" is_service

      wa_itemlist-is_service = 'Y'.
      wa_itemlist-total_item_value = wa_itemlist-assessable_value * (  1 + ( wa_itemlist-gst_rate ) + wa_itemlist-cess_nonadvol_amount ).

      APPEND wa_itemlist TO it_itemlist.
      CLEAR :  wa_itemlist ,tcsamt,discount,unitprice ,totamt.
    ENDLOOP.

    wa_final-item_list = it_itemlist.

    DATA:json TYPE REF TO if_xco_cp_json_data.

    xco_cp_json=>data->from_abap(
      EXPORTING
        ia_abap      = wa_final
      RECEIVING
        ro_json_data = json   ).
    json->to_string(
      RECEIVING
        rv_string =   DATA(lv_string) ).

*   DATA(lv_json) = /ui2/cl_json=>serialize( data = lv_string compress = abap_true pretty_name = /ui2/cl_json=>pretty_mode-low_case ).

*    REPLACE ALL OCCURRENCES OF REGEX '"([A-Z0-9_]+)"\s*:' IN lv_string WITH '"\L\1":'.


    REPLACE ALL OCCURRENCES OF '"USER_GSTIN"' IN lv_string WITH '"user_gstin"'.
    REPLACE ALL OCCURRENCES OF '"DATA_SOURCE"' IN lv_string WITH '"data_source"'.
    REPLACE ALL OCCURRENCES OF '"TRANSACTION_DETAILS"' IN lv_string WITH '"transaction_details"'.
    REPLACE ALL OCCURRENCES OF '"SUPPLY_TYPE"' IN lv_string WITH '"supply_type"'.
    REPLACE ALL OCCURRENCES OF '"CHARGE_TYPE"' IN lv_string WITH '"charge_type"'.
    REPLACE ALL OCCURRENCES OF '"IGST_ON_INTRA"' IN lv_string WITH '"igst_on_intra"'.
    REPLACE ALL OCCURRENCES OF '"ECOMMERCE_GSTIN"' IN lv_string WITH '"ecommerce_gstin"'.

    REPLACE ALL OCCURRENCES OF '"DOCUMENT_DETAILS"' IN lv_string WITH '"document_details"'.
    REPLACE ALL OCCURRENCES OF '"DOCUMENT_TYPE"' IN lv_string WITH '"document_type"'.
    REPLACE ALL OCCURRENCES OF '"DOCUMENT_NUMBER"' IN lv_string WITH '"document_number"'.
    REPLACE ALL OCCURRENCES OF '"DOCUMENT_DATE"' IN lv_string WITH '"document_date"'.

    REPLACE ALL OCCURRENCES OF '"SELLER_DETAILS"' IN lv_string WITH '"seller_details"'.
    REPLACE ALL OCCURRENCES OF '"GSTIN"' IN lv_string WITH '"gstin"'.
    REPLACE ALL OCCURRENCES OF '"LEGAL_NAME"' IN lv_string WITH '"legal_name"'.
    REPLACE ALL OCCURRENCES OF '"TRADE_NAME"' IN lv_string WITH '"trade_name"'.
    REPLACE ALL OCCURRENCES OF '"ADDRESS1"' IN lv_string WITH '"address1"'.
    REPLACE ALL OCCURRENCES OF '"ADDRESS2"' IN lv_string WITH '"address2"'.
    REPLACE ALL OCCURRENCES OF '"LOCATION"' IN lv_string WITH '"location"'.
    REPLACE ALL OCCURRENCES OF '"PINCODE"' IN lv_string WITH '"pincode"'.
    REPLACE ALL OCCURRENCES OF '"STATE_CODE"' IN lv_string WITH '"state_code"'.
    REPLACE ALL OCCURRENCES OF '"PHONE_NUMBER"' IN lv_string WITH '"phone_number"'.
    REPLACE ALL OCCURRENCES OF '"EMAIL"' IN lv_string WITH '"email"'.

    REPLACE ALL OCCURRENCES OF '"BUYER_DETAILS"' IN lv_string WITH '"buyer_details"'.
    REPLACE ALL OCCURRENCES OF '"PLACE_OF_SUPPLY"' IN lv_string WITH '"place_of_supply"'.

    REPLACE ALL OCCURRENCES OF '"DISPATCH_DETAILS"' IN lv_string WITH '"dispatch_details"'.
    REPLACE ALL OCCURRENCES OF '"COMPANY_NAME"' IN lv_string WITH '"company_name"'.

    REPLACE ALL OCCURRENCES OF '"SHIP_DETAILS"' IN lv_string WITH '"ship_details"'.

    REPLACE ALL OCCURRENCES OF '"EXPORT_DETAILS"' IN lv_string WITH '"export_details"'.
    REPLACE ALL OCCURRENCES OF '"SHIP_BILL_NUMBER"' IN lv_string WITH '"ship_bill_number"'.
    REPLACE ALL OCCURRENCES OF '"SHIP_BILL_DATE"' IN lv_string WITH '"ship_bill_date"'.
    REPLACE ALL OCCURRENCES OF '"COUNTRY_CODE"' IN lv_string WITH '"country_code"'.
    REPLACE ALL OCCURRENCES OF '"FOREIGN_CURRENCY"' IN lv_string WITH '"foreign_currency"'.
    REPLACE ALL OCCURRENCES OF '"REFUND_CLAIM"' IN lv_string WITH '"refund_claim"'.
    REPLACE ALL OCCURRENCES OF '"PORT_CODE"' IN lv_string WITH '"port_code"'.
    REPLACE ALL OCCURRENCES OF '"EXPORT_DUTY"' IN lv_string WITH '"export_duty"'.

    REPLACE ALL OCCURRENCES OF '"PAYMENT_DETAILS"' IN lv_string WITH '"payment_details"'.
    REPLACE ALL OCCURRENCES OF '"BANK_ACCOUNT_NUMBER"' IN lv_string WITH '"bank_account_number"'.
    REPLACE ALL OCCURRENCES OF '"PAID_BALANCE_AMOUNT"' IN lv_string WITH '"paid_balance_amount"'.
    REPLACE ALL OCCURRENCES OF '"CREDIT_DAYS"' IN lv_string WITH '"credit_days"'.
    REPLACE ALL OCCURRENCES OF '"CREDIT_TRANSFER"' IN lv_string WITH '"credit_transfer"'.
    REPLACE ALL OCCURRENCES OF '"DIRECT_DEBIT"' IN lv_string WITH '"direct_debit"'.
    REPLACE ALL OCCURRENCES OF '"BRANCH_OR_IFSC"' IN lv_string WITH '"branch_or_ifsc"'.
    REPLACE ALL OCCURRENCES OF '"PAYMENT_MODE"' IN lv_string WITH '"payment_mode"'.
    REPLACE ALL OCCURRENCES OF '"PAYEE_NAME"' IN lv_string WITH '"payee_name"'.
    REPLACE ALL OCCURRENCES OF '"OUTSTANDING_AMOUNT"' IN lv_string WITH '"outstanding_amount"'.
    REPLACE ALL OCCURRENCES OF '"PAYMENT_INSTRUCTION"' IN lv_string WITH '"payment_instruction"'.
    REPLACE ALL OCCURRENCES OF '"PAYMENT_TERM"' IN lv_string WITH '"payment_term"'.

    REPLACE ALL OCCURRENCES OF '"REFERENCE_DETAILS"' IN lv_string WITH '"reference_details"'.
    REPLACE ALL OCCURRENCES OF '"INVOICE_REMARKS"' IN lv_string WITH '"invoice_remarks"'.

    REPLACE ALL OCCURRENCES OF '"ADDITIONAL_DOCUMENT_DETAILS"' IN lv_string WITH '"additional_document_details"'.

    REPLACE ALL OCCURRENCES OF '"EWAYBILL_DETAILS"' IN lv_string WITH '"ewaybill_details"'.

    REPLACE ALL OCCURRENCES OF '"VALUE_DETAILS"' IN lv_string WITH '"value_details"'.

    REPLACE ALL OCCURRENCES OF '"ITEM_LIST"' IN lv_string WITH '"item_list"'.
    REPLACE ALL OCCURRENCES OF '"REFERENCE_DETAILS"' IN lv_string WITH '"reference_details"'.
    REPLACE ALL OCCURRENCES OF '"INVOICE_REMARKS"' IN lv_string WITH '"invoice_remarks"'.
    REPLACE ALL OCCURRENCES OF '"DOCUMENT_PERIOD_DETAILS"' IN lv_string WITH '"document_period_details"'.
    REPLACE ALL OCCURRENCES OF '"INVOICE_PERIOD_START_DATE"' IN lv_string WITH '"invoice_period_start_date"'.
    REPLACE ALL OCCURRENCES OF '"INVOICE_PERIOD_END_DATE"' IN lv_string WITH '"invoice_period_end_date"'.

    REPLACE ALL OCCURRENCES OF '"PRECEDING_DOCUMENT_DETAILS"' IN lv_string WITH '"preceding_document_details"'.
    REPLACE ALL OCCURRENCES OF '"REFERENCE_OF_ORIGINAL_INVOICE"' IN lv_string WITH '"reference_of_original_invoice"'.
    REPLACE ALL OCCURRENCES OF '"PRECEDING_INVOICE_DATE"' IN lv_string WITH '"preceding_invoice_date"'.
    REPLACE ALL OCCURRENCES OF '"OTHER_REFERENCE"' IN lv_string WITH '"other_reference"'.

    REPLACE ALL OCCURRENCES OF '"CONTRACT_DETAILS"' IN lv_string WITH '"contract_details"'.
    REPLACE ALL OCCURRENCES OF '"RECEIPT_ADVICE_NUMBER"' IN lv_string WITH '"receipt_advice_number"'.
    REPLACE ALL OCCURRENCES OF '"RECEIPT_ADVICE_DATE"' IN lv_string WITH '"receipt_advice_date"'.
    REPLACE ALL OCCURRENCES OF '"BATCH_REFERENCE_NUMBER"' IN lv_string WITH '"batch_reference_number"'.
    REPLACE ALL OCCURRENCES OF '"CONTRACT_REFERENCE_NUMBER"' IN lv_string WITH '"contract_reference_number"'.
    REPLACE ALL OCCURRENCES OF '"PROJECT_REFERENCE_NUMBER"' IN lv_string WITH '"project_reference_number"'.
    REPLACE ALL OCCURRENCES OF '"VENDOR_PO_REFERENCE_NUMBER"' IN lv_string WITH '"vendor_po_reference_number"'.
    REPLACE ALL OCCURRENCES OF '"VENDOR_PO_REFERENCE_DATE"' IN lv_string WITH '"vendor_po_reference_date"'.

    REPLACE ALL OCCURRENCES OF '"ADDITIONAL_DOCUMENT_DETAILS"' IN lv_string WITH '"additional_document_details"'.
    REPLACE ALL OCCURRENCES OF '"SUPPORTING_DOCUMENT_URL"' IN lv_string WITH '"supporting_document_url"'.
    REPLACE ALL OCCURRENCES OF '"SUPPORTING_DOCUMENT"' IN lv_string WITH '"supporting_document"'.
    REPLACE ALL OCCURRENCES OF '"ADDITIONAL_INFORMATION"' IN lv_string WITH '"additional_information"'.

    REPLACE ALL OCCURRENCES OF '"EWAYBILL_DETAILS"' IN lv_string WITH '"ewaybill_details"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTER_ID"' IN lv_string WITH '"transporter_id"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTER_NAME"' IN lv_string WITH '"transporter_name"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTATION_MODE"' IN lv_string WITH '"transportation_mode"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTATION_DISTANCE"' IN lv_string WITH '"transportation_distance"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTER_DOCUMENT_NUMBER"' IN lv_string WITH '"transporter_document_number"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTER_DOCUMENT_DATE"' IN lv_string WITH '"transporter_document_date"'.
    REPLACE ALL OCCURRENCES OF '"VEHICLE_NUMBER"' IN lv_string WITH '"vehicle_number"'.
    REPLACE ALL OCCURRENCES OF '"VEHICLE_TYPE"' IN lv_string WITH '"vehicle_type"'.

    REPLACE ALL OCCURRENCES OF '"VALUE_DETAILS"' IN lv_string WITH '"value_details"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_ASSESSABLE_VALUE"' IN lv_string WITH '"total_assessable_value"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_CGST_VALUE"' IN lv_string WITH '"total_cgst_value"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_SGST_VALUE"' IN lv_string WITH '"total_sgst_value"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_IGST_VALUE"' IN lv_string WITH '"total_igst_value"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_CESS_VALUE"' IN lv_string WITH '"total_cess_value"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_INVOICE_VALUE"' IN lv_string WITH '"total_invoice_value"'.

    REPLACE ALL OCCURRENCES OF '"ITEM_LIST"' IN lv_string WITH '"item_list"'.
    REPLACE ALL OCCURRENCES OF '"ITEM_SERIAL_NUMBER"' IN lv_string WITH '"item_serial_number"'.
    REPLACE ALL OCCURRENCES OF '"PRODUCT_DESCRIPTION"' IN lv_string WITH '"product_description"'.
    REPLACE ALL OCCURRENCES OF '"IS_SERVICE"' IN lv_string WITH '"is_service"'.
    REPLACE ALL OCCURRENCES OF '"HSN_CODE"' IN lv_string WITH '"hsn_code"'.
    REPLACE ALL OCCURRENCES OF '"BAR_CODE"' IN lv_string WITH '"bar_code"'.
    REPLACE ALL OCCURRENCES OF '"QUANTITY"' IN lv_string WITH '"quantity"'.
    REPLACE ALL OCCURRENCES OF '"FREE_QUANTITY"' IN lv_string WITH '"free_quantity"'.
    REPLACE ALL OCCURRENCES OF '"UNIT"' IN lv_string WITH '"unit"'.

    REPLACE ALL OCCURRENCES OF '"UNIT_PRICE"' IN lv_string WITH '"unit_price"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_AMOUNT"' IN lv_string WITH '"total_amount"'.

    REPLACE ALL OCCURRENCES OF '"TOTAL_CESS_VALUE_OF_STATE"' IN lv_string WITH '"total_cess_value_of_state"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_DISCOUNT"' IN lv_string WITH '"total_discount"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_OTHER_CHARGE"' IN lv_string WITH '"total_other_charge"'.
    REPLACE ALL OCCURRENCES OF '"ROUND_OFF_AMOUNT"' IN lv_string WITH '"round_off_amount"'.
    REPLACE ALL OCCURRENCES OF '"TOT_INV_VAL_ADDITIONAL_CURR"' IN lv_string WITH '"tot_inv_val_additional_curr"'.
    REPLACE ALL OCCURRENCES OF '"PRE_TAX_VALUE"' IN lv_string WITH '"pre_tax_value"'.
    REPLACE ALL OCCURRENCES OF '"DISCOUNT"' IN lv_string WITH '"discount"'.
    REPLACE ALL OCCURRENCES OF '"OTHER_CHARGE"' IN lv_string WITH '"other_charge"'.
    REPLACE ALL OCCURRENCES OF '"ASSESSABLE_VALUE"' IN lv_string WITH '"assessable_value"'.
    REPLACE ALL OCCURRENCES OF '"GST_RATE"' IN lv_string WITH '"gst_rate"'.
    REPLACE ALL OCCURRENCES OF '"IGST_AMOUNT"' IN lv_string WITH '"igst_amount"'.
    REPLACE ALL OCCURRENCES OF '"CGST_AMOUNT"' IN lv_string WITH '"cgst_amount"'.
    REPLACE ALL OCCURRENCES OF '"SGST_AMOUNT"' IN lv_string WITH '"sgst_amount"'.
    REPLACE ALL OCCURRENCES OF '"CESS_RATE"' IN lv_string WITH '"cess_rate"'.
    REPLACE ALL OCCURRENCES OF '"CESS_AMOUNT"' IN lv_string WITH '"cess_amount"'.
    REPLACE ALL OCCURRENCES OF '"CESS_NONADVOL_AMOUNT"' IN lv_string WITH '"cess_nonadvol_amount"'.
    REPLACE ALL OCCURRENCES OF '"STATE_CESS_RATE"' IN lv_string WITH '"state_cess_rate"'.
    REPLACE ALL OCCURRENCES OF '"STATE_CESS_AMOUNT"' IN lv_string WITH '"state_cess_amount"'.
    REPLACE ALL OCCURRENCES OF '"STATE_CESS_NONADVOL_AMOUNT"' IN lv_string WITH '"state_cess_nonadvol_amount"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_ITEM_VALUE"' IN lv_string WITH '"total_item_value"'.
    REPLACE ALL OCCURRENCES OF '"COUNTRY_ORIGIN"' IN lv_string WITH '"country_origin"'.
    REPLACE ALL OCCURRENCES OF '"ORDER_LINE_REFERENCE"' IN lv_string WITH '"order_line_reference"'.
    REPLACE ALL OCCURRENCES OF '"PRODUCT_SERIAL_NUMBER"' IN lv_string WITH '"product_serial_number"'.
    REPLACE ALL OCCURRENCES OF '"BATCH_DETAILS"' IN lv_string WITH '"batch_details"'.
    REPLACE ALL OCCURRENCES OF '"NAME"' IN lv_string WITH '"name"'.
    REPLACE ALL OCCURRENCES OF '"EXPIRY_DATE"' IN lv_string WITH '"expiry_date"'.
    REPLACE ALL OCCURRENCES OF '"WARRANTY_DATE"' IN lv_string WITH '"warranty_date"'.
    REPLACE ALL OCCURRENCES OF '"ATTRIBUTE_DETAILS"' IN lv_string WITH '"attribute_details"'.
    REPLACE ALL OCCURRENCES OF '"ITEM_ATTRIBUTE_DETAILS"' IN lv_string WITH '"item_attribute_details"'.
    REPLACE ALL OCCURRENCES OF '"ITEM_ATTRIBUTE_VALUE"' IN lv_string WITH '"item_attribute_value"'.


*    result = lv_string.

    out->write( lv_string ).
  ENDMETHOD.
ENDCLASS.
