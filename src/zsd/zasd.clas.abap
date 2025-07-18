CLASS zasd DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZASD IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

***    DATA: purchaseorder TYPE i_purchaseorderapi01-PurchaseOrder.
***    purchaseorder = '1300000000'.
***
**********************************************************************************Header Select Query
***
***    SELECT SINGLE
***    a~PurchaseOrder,
***    a~supplier,
***    a~PurchaseOrderdate,
***    b~companycodename,
***    c~HouseNumber,
***    c~StreetName,
***    c~CityName,
****    c~PhoneNumber,
****    c~FaxNumber,
***    d~SupplierName,
***    d~BPAddrStreetName,
****    d~STREETPREFIXNAME1,
****    d~CITYNAME,
***    d~businesspartnerpannumber,
***    d~postalcode,
***    d~taxnumber3,
***    e~RegionName
****    f~SupplierQuoation,
****    f~QuotationSubmissionDate
***
***    FROM i_purchaseorderapi01 AS a
***    LEFT JOIN i_companycode AS b ON a~CompanyCode = b~CompanyCode
***    LEFT JOIN I_Address_2 AS c ON c~addressid = b~addressid
***    LEFT JOIN i_supplier AS d ON d~Supplier = a~Supplier
***    LEFT JOIN i_regiontext AS e ON  e~region = d~region
****    LEFT JOIN A_SupplierQuotation AS f ON f~ = a~
***
***    WHERE a~PurchaseOrder = @purchaseorder
***    INTO  @DATA(wa).
***
***
**********************************************************************************ITEM Select Query
***
****SELECT
****a~SupplierMaterialNumber,
**** a~YY1_HSCODE_PDI,
****a~BASEUNIT,
***** a~SCHEDULELINEORDERQUANTITY,
****a~NETPRICEAMOUNT
****FROM I_PurchaseOrderItemAPI01 AS a
****INTO TABLE @DATA(IT).
***
****out->write( WA ).
****OUT->WRITE( IT ).
***
**********************************************************************************FOOTER Select Query
***
****SELECT SINGLE
****a~house_num1,
****a~street,
****a~city1,
****a~post_code1
****
****FROM ESH_N_COMPANY_ADDRESS_ADDRESS AS a
****INTO @DATA(WA2).
***
**********************************************************************************Header XML
***
****CONCATENATE WA-Housenumber WA-CityName WA-StreetName into WA-HouseNumber.
****CONCATENATE WA-BPADDRSTREETNAME WA-STREETPREFIXNAME1 WA-CITYNAME WA-POSTALCODE WA-RegionName into WA-BPAddrStreetName.
***    DATA(main_xml) =
***    |<FORM>| &&
***    |<HEADER>| &&
****|<COMPANYNAME>{ WA-companycodename }</COMPANYNAME>| &&
***    |<COMPANYADDRESS>{ wa-HouseNumber }</COMPANYADDRESS>| &&
****|<PHONENUMBER>{ WA-PhoneNumber }</PHONENUMBER>| &&
****|<FAX>{ WA-FaxNumber }</FAX>| &&
***    |<DOCNO>{ wa-PurchaseOrder }</DOCNO>| &&
***    |<VENDORNAME>{ wa-SupplierName }</VENDORNAME>| &&
***    |<VENDORADDRESS>{ wa-BPAddrStreetName }</VENDORADDRESS>| &&
***    |<PARTYCODE>{ wa-Supplier }</PARTYCODE>| &&
***    |<PANNUMBER>{ wa-businesspartnerpannumber }</PANNUMBER>| &&
***    |<GSTIN>{ wa-taxnumber3 }</GSTIN>| &&
***    |<P.O.NUMBER>{ wa-PurchaseOrder }</P.O.NUMBER>| &&
***    |<P.O.DATE>{ wa-PurchaseOrderDate }</P.O.DATE>| &&
***    |</HEADER>| &&
***    |<PurchaseOrderItems>| .
***
***
**********************************************************************************ITEM XML
***
***
***    LOOP AT it INTO DATA(wa_item).
***      DATA(item_xml) =
***      |<PurchaseOrderItemNode>| &&
***      |<DESCRIPTION>{ wa_item-SupplierMaterialNumber }</DESCRIPTION>| &&
***      |<HSCODE>{ wa_item-yy1_hscode_pdi }</HSCODE>| &&
***      |<UOM>{ wa_item-BaseUnit }</UOM>| &&
****|<QTY>{ WA_ITEM-SCHEDULELINEORDERQUANTITY }</QTY>| &&
***      |<RATEPERUNIT>{ wa_item-NetPriceAmount }</RATEPERUNIT>| &&
***      |</PurchaseOrderItemNode>| .
***      CLEAR wa_item.
***      CONCATENATE main_xml item_xml INTO main_xml.
***    ENDLOOP.
***
***
**********************************************************************************FOOTER XML
***
****CONCATENATE WA2-house_num1 WA2-street WA2-city1 WA2-post_code1 into WA2-house_num1.
***    DATA(footer_xml) = |</PurchaseOrderItems>| &&
***                       |<FOOTER| &&
****                   |<REGISTERED_OFFICE>{ WA2-house_num1 }</REGISTERED_OFFICE>| &&
***                       |</FOOTER| &&
***                       |</PurchaseOrderNode>| &&
***                       |</FORM>|.
***    CONCATENATE main_xml footer_xml INTO main_xml.
***
***    out->write(  main_xml ).
  ENDMETHOD.
ENDCLASS.
