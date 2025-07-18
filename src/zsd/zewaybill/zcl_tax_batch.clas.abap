CLASS zcl_tax_batch DEFINITION
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
        IMPORTING cleardoc        TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zsd_taxinvoice_batch/zsd_taxinvoice_batch'."'zpo/zpo_v2'."
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.

ENDCLASS.



CLASS zcl_tax_batch IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .

    """""""""""""" header level data"""""""""" plant add
    SELECT SINGLE
    a~billingdocumentdate,  """"""" date
     a~documentreferenceid,  """""""""" invoice number
    c~gstin_no ,
    c~state_code2 ,
    c~plant_name1 ,
     c~address1 ,
     c~address2 ,c~city ,
    c~district ,
    c~state_name ,
    c~pin ,
    c~country,
    c~cin_no

   FROM i_billingdocument AS a
    LEFT JOIN i_billingdocumentitem AS b ON b~billingdocument = a~billingdocument
    LEFT JOIN ztable_plant AS c ON c~plant_code = b~plant
    WHERE b~billingdocument = @cleardoc

   INTO @DATA(wa_plant) PRIVILEGED ACCESS.
*         out->write( wa_plant ).
    DATA plantaddstring TYPE string.
    CONCATENATE wa_plant-address1 wa_plant-address2 wa_plant-city wa_plant-district wa_plant-state_name wa_plant-pin INTO plantaddstring SEPARATED BY space.

    """"""""""""header level customer add"""""""""""""""""""""'
    SELECT SINGLE
     d~streetname ,         " sold to add
     d~streetprefixname1 ,   " sold to add
     d~streetprefixname2 ,   " sold to add
     d~cityname ,   " ship to add
     d~region ,  "sold to add
     d~postalcode ,   " sold to add
     d~districtname ,   " sold to add
     d~country ,
     d~housenumber ,
     c~customername,
     c~taxnumber3,
     e~RegionName
    FROM I_BillingDocument AS a
    LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument
    LEFT JOIN i_customer AS c ON c~customer = b~Customer
    LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
    LEFT JOIN i_regiontext AS e ON d~region = e~region AND d~country = e~country
    WHERE
    c~Language = 'E'
    AND a~BillingDocument = @cleardoc
    INTO @DATA(wa_sold)
    PRIVILEGED ACCESS.

*        out->write( wa_sold ).
    DATA : addstring TYPE string.
    CONCATENATE wa_sold-HouseNumber wa_sold-streetname wa_sold-StreetPrefixName1 wa_sold-CityName wa_sold-PostalCode  wa_sold-DistrictName
    INTO addstring SEPARATED BY space.

    SELECT SINGLE
    a~salesdocument,
    b~purchaseorderbycustomer,
    b~customerpurchaseorderdate
     FROM  I_billingdocumentItem WITH PRIVILEGED ACCESS AS a
    LEFT JOIN I_salesDocument WITH PRIVILEGED ACCESS AS b ON a~SalesDocument = b~SalesDocument
    WHERE a~BillingDocument = @cleardoc
    INTO @DATA(it_tab).


    SELECT
           a~product,
           a~referencesddocument,
           a~baseunit,  """""""uom
           a~billingdocumentitemtext,
           a~salesdocumentitemcategory,
           a~batch,
           d~OriginalDeliveryQuantity,
           f~ManufactureDate,
           f~shelflifeexpirationdate,
           a~billingdocumentitem,
           a~billingdocument


           FROM I_billingdocumentItem WITH PRIVILEGED ACCESS AS a
           LEFT JOIN I_DeliveryDocumentItem WITH PRIVILEGED ACCESS AS d ON a~ReferenceSDDocument = d~DeliveryDocument  AND a~Batch = d~Batch AND a~Product = d~Product
*       LEFT   JOIN i_billingdocumentitemtp WITH PRIVILEGED ACCESS as e on a~BillingDocument = e~BillingDocument and e~SalesDocumentItemCategory <> 'TAN' and a~BillingDocumentItem = e~BillingDocumentItem
            INNER JOIN i_batch WITH PRIVILEGED ACCESS AS f ON  a~Product = f~Material AND a~batch = f~batch AND a~Plant = f~Plant

            WHERE a~BillingDocument = @cleardoc AND a~salesdocumentitemcategory = 'CB99'
           INTO TABLE @DATA(it_item).
*        out->write( it_item ).


    """"""""""""""" footer level """"""""""""""""""""""
    SELECT SINGLE
   a~BillingDocument,
   a~yy1_transportdetails_bdh,
   a~yy1_vehicleno_bdh,
   b~SalesDocument,
   c~yy1_precarriageby_sdh
   FROM i_billingdocument WITH PRIVILEGED ACCESS AS a
   LEFT JOIN I_billingdocumentItem WITH PRIVILEGED ACCESS AS b ON a~BillingDocument = b~BillingDocument
   LEFT JOIN I_salesDocument WITH PRIVILEGED ACCESS AS c ON b~SalesDocument = c~SalesDocument
   WHERE a~BillingDocument = @cleardoc

   INTO @DATA(wa_footer).
    DATA : str1 TYPE string.
    IF wa_footer-YY1_PreCarriageby_SDH EQ 'R' .
      str1 = 'Road'.
    ELSEIF wa_footer-YY1_PreCarriageby_SDH EQ 'T'.

      str1 = 'Train'.

    ENDIF.

*        out->write( wa_footer ).
*data str2 type string.
* CONCATENATE it_tab-CustomerPurchaseOrderDate  it_tab-PurchaseOrderByCustomer  INTO str2 SEPARATED BY space.


    DATA(lv_xml) =
    |<Form>| &&
    |<BillingDocument>| &&
    |<Header>| &&
    |<Date></Date>| &&
    |<Time></Time>| &&
    |<PlantName>{ wa_plant-plant_name1 }</PlantName>| &&
    |<PlantGSTNO>{ wa_plant-gstin_no }</PlantGSTNO>| &&
    |<PlantAdd>| &&
    |<Add>{ plantaddstring }</Add>| &&
    |</PlantAdd>| &&
    |<CustomerDetails>| &&
    |<GSTNO>{ wa_sold-TaxNumber3 }</GSTNO>| &&
    |<Name>{ wa_sold-CustomerName }</Name>| &&
    |<Address>{ addstring }</Address>| &&
    |<StateName>{ wa_sold-RegionName }</StateName>| &&
    |<PanNo></PanNo>| &&
    |<Code></Code>| &&
    |<CIN_NO></CIN_NO>| &&
    |<Place_Of_Supply>{ wa_sold-RegionName }</Place_Of_Supply>| &&
    |</CustomerDetails>| &&
    |<Ref_Customer_Order_No>{ it_tab-PurchaseOrderByCustomer }</Ref_Customer_Order_No>| &&
    |<Ref_Customer_Order_Date>{ it_tab-CustomerPurchaseOrderDate }</Ref_Customer_Order_Date>| &&
    |<Invoice_Number>{ wa_plant-DocumentReferenceID }</Invoice_Number>| &&
    |<Invoice_Date>{ wa_plant-BillingDocumentDate }</Invoice_Date>| &&
    |<Menufactures_Name>{ wa_plant-plant_name1 }</Menufactures_Name>| &&
    |<CIN_NO>{ wa_plant-cin_no }</CIN_NO>| &&
    |</Header>| &&
    |<LineItem>|.

    LOOP AT it_item INTO DATA(wa_it_item).

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      DATA: ztrade_pr TYPE zmaterial_table-mat.
      ztrade_pr = wa_it_item-Product.

      SHIFT ztrade_pr LEFT DELETING LEADING '0'.

      SELECT SINGLE
      a~trade_name
      FROM zmaterial_table AS a
      WHERE a~mat = @ztrade_pr
      INTO @DATA(wa_item3) PRIVILEGED ACCESS.

      IF wa_item3 IS NOT INITIAL.

        wa_it_item-BillingDocumentItemText = wa_item3.
*          DATA(lv_item3) =
*          |<YY1_fg_material_name_BDI>{ wa_item3 }</YY1_fg_material_name_BDI>|.
*          CONCATENATE lv_item lv_item3 INTO lv_item .
      ELSE.
        " Fetch Product Name from `i_producttext`
        SELECT SINGLE
        a~productname
        FROM i_producttext AS a
        WHERE a~product = @wa_it_item-Product
        INTO @DATA(wa_item4) PRIVILEGED ACCESS.
        wa_it_item-BillingDocumentItemText = wa_item4.
*          DATA(lv_item4) =
*          |<YY1_fg_material_name_BDI>{ wa_item4 }</YY1_fg_material_name_BDI>|.
*          CONCATENATE lv_item lv_item4 INTO lv_item.
      ENDIF.

      SELECT SINGLE FROM
      i_billingdocumentitemtp AS a
      FIELDS
      a~yy1_no_of_pack_bdi
      WHERE a~BillingDocument = @wa_it_item-BillingDocument AND
      a~BillingDocumentItem = @wa_it_item-BillingDocumentItem
      INTO @DATA(lv_pack) PRIVILEGED ACCESS.

      DATA(lv_itemxml) =
      |<item>| &&
      |<Description_of_goods>{ wa_it_item-BillingDocumentItemText }</Description_of_goods>| &&
      |<Batch_No>{ wa_it_item-Batch }</Batch_No>| &&
      |<Qty_Per_Pack>{ lv_pack }</Qty_Per_Pack>| &&
      |<No_of_Pack></No_of_Pack>| &&
      |<Qty>{ wa_it_item-OriginalDeliveryQuantity }</Qty>| &&
      |<Uom>{ wa_it_item-BaseUnit }</Uom>| &&
      |<Manufatures_Date>{ wa_it_item-ManufactureDate }</Manufatures_Date>| &&
      |<Expiry_Date>{ wa_it_item-ShelfLifeExpirationDate }</Expiry_Date>| &&
      |</item>|.

      CONCATENATE lv_xml lv_itemxml INTO lv_xml.

      CLEAR wa_it_item.
      CLEAR lv_pack.
      CLEAR ztrade_pr.

    ENDLOOP.

    DATA(lv_footer) =
    |</LineItem>| &&
    |<Footer>| &&
    |<Transporter>{ wa_footer-YY1_TransportDetails_BDH }</Transporter>| &&
    |<Mode_of_transport>{ str1 }</Mode_of_transport>| &&
    |<Moter_Vehical_No>{ wa_footer-YY1_VehicleNo_BDH }</Moter_Vehical_No>| &&
    |<Consignment_no></Consignment_no>| &&
    |<Consignment_Dt></Consignment_Dt>| &&
    |</Footer>|.

    CONCATENATE lv_xml lv_footer INTO lv_xml.

    DATA(lv_last) =
    |</BillingDocument>| &&
    |</Form>|.


    CONCATENATE lv_xml lv_last INTO lv_xml.

    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

  ENDMETHOD.
ENDCLASS.
