CLASS zcl_demo_ads2 DEFINITION

  PUBLIC

  FINAL

  CREATE PUBLIC .
  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.

  PRIVATE SECTION.

    METHODS get_root_exception

      IMPORTING

        !ix_exception  TYPE REF TO cx_root

      RETURNING

        VALUE(rx_root) TYPE REF TO cx_root .
ENDCLASS.



CLASS ZCL_DEMO_ADS2 IMPLEMENTATION.


  METHOD get_root_exception.

    rx_root = ix_exception.

    WHILE rx_root->previous IS BOUND.

      rx_root ?= rx_root->previous.

    ENDWHILE.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    "Syntax of the URL as described in "Call the REST API"

    "https://help.sap.com/viewer/6d3eac5a9e3144a7b43932a1078c7628/Cloud/en-US/5d61062ff783453cbbec42f5418fcd14.html

    "is the following

    "https://adsrestapiformsprocessing-<yoursubaccount>.<yourregionhost:[xxx.]hana.ondemand.com>/ads.restapi/v1/

    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.

    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
*    CONSTANTS  lv_url_token    TYPE string VALUE 'https://btp-yvzjjpaz.authentication.eu10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.

    CONSTANTS lc_template_name TYPE string VALUE 'DEMO/TEMPLATE'.

    "the ABAP field names such as "xdp_Template" will be converted to camel case "xdpTemplate"

    "by the json library /ui2/cl_json

    TYPES :

      BEGIN OF struct,

        xdp_Template TYPE string,

        xml_Data     TYPE string,

        form_Type    TYPE string,

        form_Locale  TYPE string,

        tagged_Pdf   TYPE string,

        embed_Font   TYPE string,

      END OF struct."

    DATA name_value_pairs  TYPE  if_web_http_request=>name_value_pairs   .


    name_value_pairs = VALUE #(

                   ( name = 'Accept' value = 'application/json, text/plain, */*'  )

                   ( name = 'Content-Type' value = 'application/json;charset=utf-8'  ) ).


    DATA lr_data TYPE REF TO data.


    DATA(lv_xml) = |<Form>| &&

    |<FormMaster>| &&

    |<Logo1Image></Logo1Image>| &&

    |<Logo2Image></Logo2Image>| &&

    |<Logo3Image></Logo3Image>| &&

    |<PrintFormTitleText>Title</PrintFormTitleText>| &&

    |<SenderAddressText></SenderAddressText>| &&

    |<WatermarkText>Test Copy</WatermarkText>| &&

    |<AdministrativeData>| &&

    |<CreationDateTime>2019-07-24T08:21:26</CreationDateTime>| &&

    |<LocaleCountry>DE</LocaleCountry>| &&

    |<LocaleLanguage>E</LocaleLanguage>| &&

    |<TenantIsProductive>false</TenantIsProductive>| &&

    |<User></User>| &&

    |</AdministrativeData>| &&

    |<Footer>| &&

    |<FooterBlock1Text>Footer1</FooterBlock1Text>| &&

    |<FooterBlock2Text>Footer2</FooterBlock2Text>| &&

    |<FooterBlock3Text>Footer3</FooterBlock3Text>| &&

    |<FooterBlock4Text>Footer4</FooterBlock4Text>| &&

    |</Footer>| &&

    |<RecipientAddress>| &&

    |<AddressID>655846</AddressID>| &&

    |<AddressLine1Text>Company</AddressLine1Text>| &&

    |<AddressLine2Text>Test Company</AddressLine2Text>| &&

    |<AddressLine3Text>SAP SE</AddressLine3Text>| &&

    |<AddressLine4Text>PO Box 13 27 89</AddressLine4Text>| &&

    |<AddressLine5Text>123459 Walldorf</AddressLine5Text>| &&

    |<AddressLine6Text></AddressLine6Text>| &&

    |<AddressLine7Text></AddressLine7Text>| &&

    |<AddressLine8Text></AddressLine8Text>| &&

    |<AddressType>1</AddressType>| &&

    |<Person></Person>| &&

    |</RecipientAddress>| &&

    |</FormMaster>| &&

    |<GIHeaderNode>| &&

    |<Language>EN</Language>| &&

    |<MaterialDocument>101</MaterialDocument>| &&

    |<MaterialDocumentItem>ITEM-2202</MaterialDocumentItem>| &&

    |<MaterialDocumentYear>2019</MaterialDocumentYear>| &&

    |<PrinterIsCapableBarCodes>true</PrinterIsCapableBarCodes>| &&

    |<GIMI>| &&

    |<AccountingDocumentCreationDate>2019-07-01T00:00:00</AccountingDocumentCreationDate>| &&

    |<BaseUnit>EA</BaseUnit>| &&

    |<Batch></Batch>| &&

    |<CostCenter></CostCenter>| &&

    |<CreatedByUser>SAP</CreatedByUser>| &&

    |<FixedAsset></FixedAsset>| &&

    |<GoodsMovementQuantity>100000.000</GoodsMovementQuantity>| &&

    |<GoodsMovementType>561</GoodsMovementType>| &&

    |<GoodsMovementTypeName>Initial stock entry</GoodsMovementTypeName>| &&

    |<GoodsReceiptAcctAssgmt></GoodsReceiptAcctAssgmt>| &&

    |<GoodsReceiptAcctAssgmtText></GoodsReceiptAcctAssgmtText>| &&

    |<GoodsReceiptPostingDate>2019-07-01T00:00:00</GoodsReceiptPostingDate>| &&

    |<Language>EN</Language>| &&

    |<MaintOrderOperationCounter>00000000</MaintOrderOperationCounter>| &&

    |<MaintOrderRoutingNumber>0000000000</MaintOrderRoutingNumber>| &&

    |<ManufacturingOrder></ManufacturingOrder>| &&

    |<MasterFixedAsset></MasterFixedAsset>| &&

    |<Material>M1</Material>| &&

    |<MaterialDocument>4900060890</MaterialDocument>| &&

    |<MaterialDocumentItem>0001</MaterialDocumentItem>| &&

    |<MaterialDocumentYear>2019</MaterialDocumentYear>| &&

    |<MaterialName>Material1</MaterialName>| &&

    |<Plant>0001</Plant>| &&

    |<PlantName>German-Plant</PlantName>| &&

    |<PrinterIsCapableBarCodes>true</PrinterIsCapableBarCodes>| &&

    |<ProjectNetwork></ProjectNetwork>| &&

    |<SalesOrder></SalesOrder>| &&

    |<SalesOrderItem>000000</SalesOrderItem>| &&

    |<SalesOrderScheduleLine>0000</SalesOrderScheduleLine>| &&

    |<StorageLocation>0003</StorageLocation>| &&

    |<TextElementText></TextElementText>| &&

    |<VersionForPrintingSlip>1</VersionForPrintingSlip>| &&

    |<WBSElementInternalID>00000000</WBSElementInternalID>| &&

    |<WarehouseStorageBin></WarehouseStorageBin>| &&

    |</GIMI>| &&

    |</GIHeaderNode>| &&

    |</Form>|.


    DATA(ls_data_xml) = cl_web_http_utility=>encode_base64( lv_xml ).



    TRY.



        DATA(lo_destination) = cl_http_destination_provider=>create_by_cloud_destination(

                                 i_name                  = 'ADS_SRV'

                                 i_service_instance_name = 'AdobeDocumentServicesCommArrangement'

                                 i_authn_mode            = if_a4c_cp_service=>service_specific

                               ).



        out->write( 'retrieved destination ADS_SRV' ).



        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_destination ).

        DATA(lo_request) = lo_http_client->get_http_request( ).



        lo_request->set_header_fields( i_fields = name_value_pairs ).

        lo_request->set_query( query =  lc_storage_name ).

        lo_request->set_uri_path( i_uri_path = lc_ads_render ).



        DATA(ls_body) = VALUE struct( xdp_Template = lc_template_name

                                      xml_Data = ls_data_xml

                                      form_Type = 'print'

                                      form_Locale = 'de_DE'

                                      tagged_Pdf = '0'

                                      embed_font = '0' ).



        DATA(lv_json) = /ui2/cl_json=>serialize( data = ls_body compress = abap_true pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).



        out->write( 'json payload' ).

        out->write( lv_json ).



        lo_request->append_text(

          EXPORTING

            data   = lv_json

        ).



        DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>post ).

        DATA(lv_json_response) = lo_response->get_text( ).



        out->write( 'lv_json_response:' ).

        out->write( lo_response->get_text( ) ).







        FIELD-SYMBOLS:

          <data>                TYPE data,

          <field>               TYPE any,

          <pdf_based64_encoded> TYPE any.



        "lv_json_response has the following structure `{"fileName":"PDFOut.pdf","fileContent":"JVB..."}



        lr_data = /ui2/cl_json=>generate( json = lv_json_response ).



        IF lr_data IS BOUND.

          ASSIGN lr_data->* TO <data>.

          ASSIGN COMPONENT `fileContent` OF STRUCTURE <data> TO <field>.

          IF sy-subrc EQ 0.

            ASSIGN <field>->* TO <pdf_based64_encoded>.

            out->write( <pdf_based64_encoded> ).

          ENDIF.

        ENDIF.

      CATCH cx_root INTO DATA(lx_exception).

        out->write( 'root exception' ).

        out->write( get_root_exception( lx_exception )->get_longtext(  ) ).

    ENDTRY.





  ENDMETHOD.
ENDCLASS.
