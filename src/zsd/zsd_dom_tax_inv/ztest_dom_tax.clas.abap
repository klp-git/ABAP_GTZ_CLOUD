CLASS ztest_dom_tax DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-DATA : bill_doc TYPE I_BillingDocument-BillingDocument.
    CLASS-DATA : company_code TYPE I_BillingDocument-CompanyCode.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTEST_DOM_TAX IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
*
*'0090000109'
    bill_doc = '0090000043'.
    company_code = 'GT00'.
************************* Details of Supplier **********************************************
*    SELECT  FROM i_billingdocument WITH PRIVILEGED ACCESS AS a
*    INNER JOIN i_billingdocumentitem WITH PRIVILEGED ACCESS AS b ON a~billingdocument = b~billingdocument
*    inner join ZI_ZTABLE_PLANT WITH PRIVILEGED ACCESS as c on b~Plant = c~PlantCode
*
*
*    FIELDS a~billingdocument,a~PurchaseOrderByCustomer,a~SalesOrganization,a~CreationDate,a~CreationTime,
*    b~billingdocumentitem,b~ReferenceSDDocument,
*c~PlantCode,c~PlantName1,c~PlantName2,c~Address1,c~Address2,c~Address3,c~City,c~District,c~StateCode1,c~StateCode2,c~StateName,
*c~Pin,c~Country,c~CinNo,c~GstinNo,c~PanNo,c~TanNo
*
*    WHERE a~billingdocument = @bill_doc AND b~billingquantity <> 0
*    INTO TABLE @DATA(lt_supp).
*    READ TABLE lt_supp INTO DATA(wa_supp) INDEX 1.
*
*
********************** Working on TopRight Side *************************************************
*
**YY1_amendmentno_bd_BDH
**YY1_CustPODate_BD_h_BDH
**YY1_amendmentdate_bd_BDH
*  SELECT SINGLE FROM i_billingdocumentitem AS a
*    INNER JOIN i_salesdocument AS b ON b~salesdocument = a~salesdocument
*    FIELDS a~salesdocument , b~yy1_dono_sdh, b~yy1_dodate_sdh, b~yy1_poamendmentno_sdh, b~yy1_poamendmentdate_sdh, b~customerpurchaseorderdate
*    WHERE a~billingdocument = @bill_doc
*    INTO @DATA(wa).
*
*
********************** Working on Footer- removal Goods date & time Side *************************************************
*
*    select single from I_billingdocumentitem as a
*   inner join i_deliverydocumentitem as b on a~referencesddocument = b~deliverydocument and a~referencesddocumentitem = b~deliverydocumentitem
*   inner join i_deliverydocument as c on b~deliverydocument = c~deliverydocument
*  fields c~actualgoodsmovementdate , c~actualgoodsmovementtime
*  where a~billingdocument = @bill_doc
*  into @data(lv_removal).
*
*
**  for port loading,pre carriage, discahrge
*    SELECT SINGLE FROM i_billingdocumentitem AS a
*       " INNER JOIN i_salesorder as b on b~salesorder = a~salesdocument
*    INNER JOIN i_salesdocument AS c ON c~salesdocument = a~salesdocument
*
*    FIELDS a~salesdocument, c~yy1_portofdicharge_sdh, c~yy1_portofloading_sdh,
*    c~yy1_precarriageby_sdh
*
*    WHERE a~billingdocument = @bill_doc
*    INTO @DATA(transport).
*
************************* Details of Recipient (Bill To) **********************************************
*    SELECT  FROM i_billingdocument WITH PRIVILEGED ACCESS AS a
*    INNER JOIN i_billingdocumentitem WITH PRIVILEGED ACCESS AS b ON a~billingdocument = b~billingdocument
*    INNER JOIN i_customer WITH PRIVILEGED ACCESS AS c ON a~soldtoparty = c~customer
*    INNER JOIN i_customerpaymenttermstext WITH PRIVILEGED ACCESS  AS d ON a~customerpaymentterms = d~customerpaymentterms
*         LEFT JOIN i_countrytext WITH PRIVILEGED ACCESS  AS e ON b~country = e~country
*    FIELDS
*    a~billingdocument,
*    a~soldtoparty AS gtz_cust_code,
*    a~creationdate,
*    b~billingdocumentitem,
*    c~customername,
*    c~streetname,
*    c~bpaddrcityname,
*    c~bpaddrstreetname,
*    c~districtname,
*    c~postalcode,
*    c~taxnumber3,
*    c~region,
*    c~customeraccountgroup,
*    c~country,
*    d~customerpaymenttermsname,
*    e~countryname
*
*    WHERE a~billingdocument = @bill_doc AND b~billingquantity <> 0
*    INTO TABLE @DATA(lt_billto).
*    READ TABLE lt_billto INTO DATA(wa_billto) INDEX 1.
*
************************* Details of Recipient (Ship To) **********************************************
*    SELECT  FROM i_billingdocument WITH PRIVILEGED ACCESS AS a
*    INNER JOIN i_billingdocumentitem WITH PRIVILEGED ACCESS AS b ON a~billingdocument = b~billingdocument
*    INNER JOIN i_customer WITH PRIVILEGED ACCESS AS c ON a~soldtoparty = c~customer " might be change
*    INNER JOIN i_customerpaymenttermstext WITH PRIVILEGED ACCESS  AS d ON a~customerpaymentterms = d~customerpaymentterms
*         LEFT JOIN i_countrytext WITH PRIVILEGED ACCESS  AS e ON b~country = e~country
*    FIELDS a~billingdocument,    a~soldtoparty,
*                        a~soldtoparty AS gtz_cust_code,
*                        a~creationdate,
*    b~billingdocumentitem,
*    c~customername,
*    c~streetname,
*    c~bpaddrcityname,
*    c~bpaddrstreetname,
*    c~districtname,
*    c~postalcode,
*    c~taxnumber3,
*    c~region,
*    c~customeraccountgroup,
*    c~country,
*    d~customerpaymenttermsname,
*    e~countryname
*
*    WHERE a~billingdocument = @bill_doc AND b~billingquantity <> 0
*    INTO TABLE @DATA(lt_shipto).
*
*
*    READ TABLE lt_shipto INTO DATA(wa_shipto) INDEX 1.
*
*********************************************************************************
*
*    select single * from ztable_irn as a
*    where a~bukrs = @company_code and a~billingdocno = @bill_doc
*    into @data(wa_irn).
*
*
************************* Line Item **********************************************
*
*    SELECT  FROM i_billingdocument WITH PRIVILEGED ACCESS AS a
*    INNER JOIN i_billingdocumentitem WITH PRIVILEGED ACCESS AS b ON a~billingdocument = b~billingdocument
*    inner join i_salesdocumentitem WITH PRIVILEGED ACCESS as c on c~salesdocument = b~salesdocument and
*                                                                c~salesdocumentitem = b~SalesDocumentItem
**inner join zi_dd_mat WITH PRIVILEGED ACCESS as c on c~Mat = '1400001782'
*    INNER JOIN i_productplantbasic AS d ON b~product = d~product
*    FIELDS a~billingdocument,
*    b~billingdocumentitem,b~billingquantity,b~billingquantityunit,b~product,b~billingdocumentitemtext,
*    c~yy1_packsize_sd_sdi, c~yy1_noofpack_sd_sdi,
**c~Mat,
*    d~consumptiontaxctrlcode
*    WHERE a~billingdocument = @bill_doc AND b~billingquantity <> 0
*    INTO TABLE @DATA(lt_line).
*
*
***********************Pricing Element************************************************
*    SELECT  FROM i_billingdocument WITH PRIVILEGED ACCESS AS a
*    INNER JOIN i_billingdocumentitem WITH PRIVILEGED ACCESS AS b ON a~billingdocument = b~billingdocument
**inner join zi_dd_mat WITH PRIVILEGED ACCESS as c on c~Mat = '1400001782'
*    INNER JOIN i_billingdocumentitemprcgelmnt WITH PRIVILEGED ACCESS AS d ON b~billingdocument = d~billingdocument
*                                                                        AND b~billingdocumentitem = d~billingdocumentitem
*    FIELDS a~billingdocument,
*    b~billingdocumentitem,b~billingquantity,b~product,b~billingdocumentitemtext,
**c~Mat
*    d~conditiontype, d~conditionamount, d~conditionbaseamount, d~conditionratevalue
*    WHERE a~billingdocument = @bill_doc AND b~billingquantity <> 0
*    INTO TABLE @DATA(lt_price).
*
*
*
*LOOP AT lt_line INTO DATA(wa_line).
*    SHIFT wa_line-product LEFT DELETING LEADING '0'.
*    MODIFY lt_line FROM wa_line.
*ENDLOOP.


********************************************************************************HEADER LEVEL
    DATA : plant_add   TYPE string.
    DATA : p_add1  TYPE string.
    DATA : p_add2 TYPE string.
    DATA : p_city TYPE string.
    DATA : p_dist TYPE string.
    DATA : p_state TYPE string.
    DATA : p_pin TYPE string.
    DATA : p_country TYPE string.

    DATA: lv_time TYPE string,
      lv_formatted_time TYPE string.

    SELECT SINGLE
    c~gstin_no ,
    c~state_code2 ,
    c~plant_name1 ,
    c~address1 ,
    c~address2 ,
    c~city ,
    c~district ,
    c~state_name ,
    c~pin ,
    c~country ,
    d~irnno ,
    d~ackno ,
    d~ackdate ,
    d~billingdocno  ,    "invoice no
    d~billingdate ,     "ackdate
    d~signedqrcode,
    e~customerpurchaseorderdate ,   "DATE[1]
    e~yy1_poamendmentdate_sdh ,     "DATE[2]
    e~yy1_poamendmentno_sdh ,         "AdvancedRecieved[1]    Amendment PO No
    a~billingdocumentdate   ,    "workorderdate
    f~customer  ,    " GTZ CUST CODE
    g~customername   ,  "bil to name
    g~taxnumber3 ,   "bill to gst
    i~region   , " bill to state name
    e~yy1_dono_sdh  ,  " ship to dono
    e~yy1_dodate_sdh  ,  " ship to dodate
    e~purchaseorderbycustomer ,
    j~paymenttermsconditiondesc  ,  "Ship to Payment Terms
    k~supplierfullname  ,  " Transporter
    a~creationtime  ,  "IssueDate
    e~yy1_precarriageby_sdh  ,  "mode
    k~taxnumber3 AS Transport_GST  , "Transport_GST
    a~documentreferenceid ,
    b~salesdocument ,
    e~creationdate ,
    a~YY1_NO_OF_PACKAGES_BDH ,
    a~yy1_remark_bdh ,
    a~yy1_DATE_TIME_REMOVAL_BDH


    FROM I_BillingDocument AS a
    LEFT JOIN i_billingdocumentitem AS b ON b~billingdocument = a~billingdocument
    LEFT JOIN ztable_plant AS c ON c~plant_code = b~plant
    LEFT JOIN ztable_irn AS d ON d~billingdocno = a~BillingDocument AND a~CompanyCode = d~bukrs
    LEFT JOIN i_salesdocument AS e ON e~salesdocument = b~salesdocument
    LEFT JOIN i_billingdocumentpartner AS f ON f~billingdocument = a~billingdocument
    LEFT JOIN i_customer AS g ON g~customer = f~Customer
    LEFT JOIN i_regionText AS i ON g~country = i~country AND g~Region = i~Region
    LEFT JOIN I_PaymentTermsConditionsText AS j ON j~PaymentTerms = a~CustomerPaymentTerms AND j~Language = 'E'
    LEFT JOIN i_Supplier AS k ON k~supplier = f~Supplier
    WHERE a~billingdocument = @bill_doc
    AND a~CompanyCode = @company_code
    INTO @DATA(wa_data)
    PRIVILEGED ACCESS.

    p_add1 = wa_data-address1 && ',' .
    p_add2 = wa_data-address2 && ','.
    p_dist = wa_data-district && ','.
    p_city = wa_data-city && ','.
    p_state = wa_data-state_name .
    p_pin =  wa_data-pin .
    p_country =  '(' &&  wa_data-country && ')' .


***********************************************************************************CONDENSE TIME OF CREATION TIME


lv_time = wa_data-CreationTime.

" Insert colons at appropriate positions
lv_formatted_time = lv_time(2) && ':' && lv_time+2(2) && ':' && lv_time+4(2).

" Remove any unwanted spaces (just in case)
CONDENSE lv_formatted_time.



*******************************************************************************************************************

DATA(lv2_date) = wa_data-YY1_POAmendmentDate_SDH.

" Format as YYYY-MM-DD
DATA(lv_formatted_date2) = lv2_date(4) && '-' && lv2_date+4(2) && '-' && lv2_date+6(2).

" Remove unwanted spaces (if any)
CONDENSE lv_formatted_date2.




***********************************************************************************SHIP TO  Address
    SELECT SINGLE
     d~streetname ,         " bill to add
     d~streetprefixname1 ,   " bill to add
     d~streetprefixname2 ,   " bill to add
     d~cityname ,   " bill to add
     d~region ,  "bill to add
     d~postalcode ,   " bill to add
     d~districtname ,   " bill to add
     d~country  ,
     d~housenumber ,
     c~customername ,
     a~soldtoparty ,
     e~regionname
    FROM I_BillingDocument AS a
    LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument
    LEFT JOIN i_customer AS c ON c~customer = b~Customer
    LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
    LEFT JOIN I_RegionText AS e on e~Region = d~Region
    WHERE b~partnerFunction = 'RE'
    and c~Language = 'E'
    and a~BillingDocument = @bill_doc
    INTO @DATA(wa_bill)
    PRIVILEGED ACCESS.




***********************************************************************************SHIP TO  Address
    SELECT SINGLE
     d~streetname ,         " ship to add
     d~streetprefixname1 ,   " ship to add
     d~streetprefixname2 ,   " ship to add
     d~cityname ,   " ship to add
     d~region ,  "ship to add
     d~postalcode ,   " ship to add
     d~districtname ,   " ship to add
     d~country ,
     d~housenumber ,
     c~customername ,
     e~RegionName
    FROM I_BillingDocument AS a
    LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument
    LEFT JOIN i_customer AS c ON c~customer = b~Customer
    LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
    LEFT JOIN I_RegionText AS e on e~Region = d~Region
    WHERE b~partnerFunction IN ('WE', 'AG')
    and c~Language = 'E'
    and a~BillingDocument = @bill_doc
    INTO @DATA(wa_ship)
    PRIVILEGED ACCESS.


***********************************************************************************SOLD TO  Address
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
     c~customername
    FROM I_BillingDocument AS a
    LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument
    LEFT JOIN i_customer AS c ON c~customer = b~Customer
    LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
    WHERE b~partnerFunction = 'AG'
    and c~Language = 'E'
    and a~BillingDocument = @bill_doc
    INTO @DATA(wa_sold)
    PRIVILEGED ACCESS.


******************************************************************************************************ITEM LEVEL

    SELECT
    a~billingdocument,
    a~billingdocumentitem,
    a~product,
    b~handlingunitreferencedocument,
    b~material,
    b~handlingunitexternalid,
    c~packagingmaterial,
    d~productdescription,
    e~materialbycustomer ,
    f~consumptiontaxctrlcode  ,   "HSN CODE
    a~billingdocumentitemtext ,   "mat
    e~yy1_packsize_sd_sdi  ,  "i_avgpkg
    a~billingquantity  ,  "Quantity
    a~billingquantityunit  ,  "UOM
    e~yy1_packsize_sd_sdiu  ,   " package_qtyunit
    e~yy1_noofpack_sd_sdi  ,   " avg_content
    g~conditionratevalue   ,  " i_per
    g~conditionamount  , "i_amt
    g~conditionamount AS conditionamount2  ,  "freight
    g~conditionamount AS conditionamount3  ,  "tcs
    g~conditionamount AS conditionamount4  ,  "rounding off
    g~conditioncurrency ,  "ZINC
    g~conditionamount AS conditionamount5  ,    "ZINP
    g~conditionamount AS conditionamount6    "ZINS

    FROM I_BillingDocumentItem AS a
    LEFT JOIN i_handlingunititem AS b ON a~referencesddocument = b~handlingunitreferencedocument
    LEFT JOIN i_handlingunitheader AS c ON b~handlingunitexternalid = c~handlingunitexternalid
    LEFT JOIN i_productdescription AS d ON d~product = c~packagingmaterial
    LEFT JOIN I_SalesDocumentItem AS e ON e~SalesDocument = a~SalesDocument AND e~salesdocumentitem = a~salesdocumentitem
    LEFT JOIN i_productplantbasic AS f ON a~Product = f~Product
    LEFT JOIN i_billingdocumentitemprcgelmnt AS g ON g~BillingDocument = a~BillingDocument
    WHERE a~billingdocument = @bill_doc
    INTO TABLE  @DATA(lt_item)
    PRIVILEGED ACCESS.

    SORT lt_item BY BillingDocumentItem.
    DELETE ADJACENT DUPLICATES FROM lt_item COMPARING BillingDocumentItem.


********************************************************************************************ITEM AMT & RATE



    SELECT
     a~conditionType  ,  "hidden conditiontype
     a~conditionamount ,  "hidden conditionamount
     a~conditionratevalue  ,  "condition ratevalue
     a~conditionbasevalue    " condition base value
     FROM I_BillingDocItemPrcgElmntBasic AS a
      WHERE a~BillingDocument = @bill_doc
     INTO TABLE @DATA(lt_item2)
     PRIVILEGED ACCESS.




**********************************************************************FOOTER LEVEL

    SELECT SINGLE
    a~actualgoodsmovementdate
    FROM i_deliverydocument AS a
    INTO @DATA(wa_footer)
    PRIVILEGED ACCESS.

******************************************************************************HEADER XML
    CONCATENATE p_add1  p_add2  p_dist p_city   p_state '-' p_pin  p_country INTO plant_add SEPARATED BY space.
*CONCATENATE wa_bill-StreetPrefixName1 wa_bill-StreetPrefixName2 wa_bill-cityname wa_bill-PostalCode wa_bill-DistrictName wa_bill-country   INTO wa_bill-StreetName SEPARATED BY SPACE.
*CONCATENATE wa_ship-StreetPrefixName1 wa_ship-StreetPrefixName2 wa_ship-cityname wa_ship-PostalCode wa_ship-DistrictName wa_ship-country   INTO wa_ship-StreetName SEPARATED BY SPACE.
    DATA(lv_header) =
    |<Form>| &&
    |<BillingDocumentNode>| &&
    |<AckDate>{ wa_data-ackdate }</AckDate>| &&
    |<AckNumber>{ wa_data-ackno }</AckNumber>| &&
    |<BillingDate>{ wa_data-billingdate }</BillingDate>| &&
    |<DocumentReferenceID>{ wa_data-documentreferenceid }</DocumentReferenceID>| &&
    |<Irn>{ wa_data-irnno }</Irn>| &&
    |<SignedQrCode>{ wa_data-signedqrcode }</SignedQrCode>| &&
    |<PurchaseOrderByCustomer>{ wa_data-PurchaseOrderByCustomer }</PurchaseOrderByCustomer>| &&
    |<SalesDocument>{ wa_data-SalesDocument }</SalesDocument>| &&
    |<SalesOrderDate>{ wa_data-CreationDate }</SalesOrderDate>| &&
    |<YY1_CustPODate_BD_h_BDH>{ wa_data-customerpurchaseorderdate }</YY1_CustPODate_BD_h_BDH>| &&
    |<YY1_PLANT_COM_ADD_BDH>{ plant_add }</YY1_PLANT_COM_ADD_BDH>| &&
    |<YY1_PLANT_COM_NAME_BDH>{ wa_data-plant_name1 }</YY1_PLANT_COM_NAME_BDH>| &&
    |<YY1_PLANT_GSTIN_NO_BDH>{ wa_data-gstin_no }</YY1_PLANT_GSTIN_NO_BDH>| &&
    |<YY1_PreCarriage_bd_h_BDH>{ wa_data-yy1_precarriageby_sdh }</YY1_PreCarriage_bd_h_BDH>| &&
    |<YY1_amendmentdate_bd_BDH>{ lv_formatted_date2 }</YY1_amendmentdate_bd_BDH>| &&
    |<YY1_amendmentno_bd_BDH>{ wa_data-yy1_poamendmentno_sdh }</YY1_amendmentno_bd_BDH>| &&
    |<YY1_dodatebd_BDH>{ wa_data-YY1_DODate_SDH  }</YY1_dodatebd_BDH>| &&
    |<YY1_dono_bd_BDH>{ wa_data-YY1_DONo_SDH }</YY1_dono_bd_BDH>| &&
    |<YY1_removal_date_bd_BDH></YY1_removal_date_bd_BDH>| &&
    |<YY1_issuetime_bd_BDH>{ lv_formatted_time }</YY1_issuetime_bd_BDH>| &&
    |<YY1_NO_OF_PACKAGES_BDH>{ wa_data-yy1_no_of_packages_bdh }</YY1_NO_OF_PACKAGES_BDH>| &&
    |<YY1_REMARK_BDH>{ wa_data-yy1_remark_bdh }</YY1_REMARK_BDH>| &&
    |<YY1_DATE_TIME_REMOVAL_BDH>{ wa_data-yy1_date_time_removal_bdh }</YY1_DATE_TIME_REMOVAL_BDH>|.



********************************************************************************************FREIGHT BEGIN

SELECT SUM( conditionamount )
  FROM I_BILLINGDOCITEMPRCGELMNTBASIC
  WHERE I_BILLINGDOCITEMPRCGELMNTBASIC~BillingDocument = @bill_doc
    AND I_BILLINGDOCITEMPRCGELMNTBASIC~ConditionType = 'ZFRT'
  INTO @DATA(wa_freight).

DATA(lv_freight) =
    |<FreightAmount>{ wa_freight }</FreightAmount>|.
CONCATENATE lv_header lv_freight INTO lv_header.


********************************************************************************************FREIGHT END

********************************************************************************************INSURANCE BEGIN

SELECT SUM( conditionamount )
  FROM I_BILLINGDOCITEMPRCGELMNTBASIC
  WHERE I_BILLINGDOCITEMPRCGELMNTBASIC~BillingDocument = @bill_doc
    AND I_BILLINGDOCITEMPRCGELMNTBASIC~ConditionType IN ('ZINC' , 'ZINP' , 'ZINS')
  INTO @DATA(wa_insurance).

DATA(lv_insurance) =
    |<InsuranceAmount>{ wa_insurance }</InsuranceAmount>|.
CONCATENATE lv_header lv_insurance INTO lv_header.


********************************************************************************************INSURANCE    END

********************************************************************************************TCS BEGIN

SELECT SUM( conditionamount )
  FROM I_BILLINGDOCITEMPRCGELMNTBASIC
  WHERE I_BILLINGDOCITEMPRCGELMNTBASIC~BillingDocument = @bill_doc
    AND I_BILLINGDOCITEMPRCGELMNTBASIC~ConditionType = 'JTC1'
  INTO @DATA(wa_tcs).

DATA(lv_tcs) =
    |<TCSAmount>{ wa_tcs }</TCSAmount>|.
CONCATENATE lv_header lv_tcs INTO lv_header.


********************************************************************************************TCS    END

*********************************************************************************************ROUND OFF

SELECT SUM( conditionamount )
  FROM I_BILLINGDOCITEMPRCGELMNTBASIC
  WHERE I_BILLINGDOCITEMPRCGELMNTBASIC~BillingDocument = @bill_doc
    AND I_BILLINGDOCITEMPRCGELMNTBASIC~ConditionType = 'ZDIF'
  INTO @DATA(wa_round).

DATA(lv_round) =
    |<RoundAmount>{ wa_round }</RoundAmount>|.
CONCATENATE lv_header lv_round INTO lv_header.


********************************************************************************************ROUND OFF    END

******************************************************************************************VEHICLE NUM
   Select single
   b~vehiclenum ,
   a~billingdocument
   from i_billingdocument as a
   LEFT JOIN ztable_irn AS b ON b~billingdocno = a~BillingDocument AND a~CompanyCode = b~bukrs
   where a~billingdocument = @bill_doc
   into @data(wa_header3).

IF wa_header3-vehiclenum is not initial .
   Data(lv_header3) =
      |<YY1_VehicleNo_BDH>{ wa_header3-vehiclenum }</YY1_VehicleNo_BDH>| .
      CONCATENATE lv_header lv_header3 into lv_header.

Else .

  Select single
  a~yy1_vehicleno_bdh ,
  a~billingdocument
  from i_billingdocument as a
  where a~BillingDocument = @bill_doc
  into @data(wa_header2).

   Data(lv_header2) =
      |<YY1_VehicleNo_BDH>{ wa_header2-YY1_VehicleNo_BDH }</YY1_VehicleNo_BDH>| .
      CONCATENATE lv_header lv_header2 into lv_header.

ENDIF.
*****************************************************************************************END VEHICLE NUM

******************************************************************************************TRANSPORTER

Select Single
a~billingdocument ,
b~suppliername ,
b~taxnumber3
from i_billingdocument as a
left join I_Supplier as b on b~Supplier = a~YY1_TransportDetails_BDH
where a~BillingDocument = @bill_doc
INTO @Data(wa_header4).

Data(lv_header4) =
     |<YY1_TransportDetails_BDHT>{ wa_header4-SupplierName }</YY1_TransportDetails_BDHT>| &&
     |<YY1_TransportGST_bd_h_BDH>{ wa_header4-TaxNumber3 }</YY1_TransportGST_bd_h_BDH>| .
     CONCATENATE lv_header lv_header4 into lv_header.


*******************************************************************************************END TRANSPORTER

   Data(lv_header5) =
    |<BillToParty>| &&
    |<AddressLine1Text>{ wa_bill-CustomerName }</AddressLine1Text>| &&
    |<Partner>{ wa_data-Customer }</Partner>| &&
    |<RegionName>{ wa_bill-RegionName }</RegionName>| &&
    |</BillToParty>| &&
    |<Items>|.

CONCATENATE lv_header lv_header5 into lv_header.

    LOOP AT lt_item INTO DATA(wa_item).
*      SHIFT wa_item-Product LEFT DELETING LEADING '0'.
      DATA(lv_item) =
      |<BillingDocumentItemNode>| &&
      |<BillingDocumentItemText>{ wa_item-Product }</BillingDocumentItemText>| &&
      |<IN_HSNOrSACCode>{ wa_item-consumptiontaxctrlcode }</IN_HSNOrSACCode>| &&
      |<Quantity>{ wa_item-BillingQuantity }</Quantity>| &&
      |<QuantityUnit>{ wa_item-BillingQuantityUnit }</QuantityUnit>| &&
      |<YY1_CustomerItemCode_BDI>{ wa_item-MaterialByCustomer }</YY1_CustomerItemCode_BDI>| &&
      |<YY1_avg_package_bd_BDI>{ wa_item-YY1_PackSize_sd_SDI }</YY1_avg_package_bd_BDI>| &&
      |<YY1_avg_package_bd_BDIU>{ wa_item-YY1_PackSize_sd_SDIU }</YY1_avg_package_bd_BDIU>| &&
      |<YY1_BD_ZINS_amt_BDI>{ wa_item-conditionamount6 }</YY1_BD_ZINS_amt_BDI>| &&
      |<YY1_bd_ZINC_amt_BDI>{ wa_item-ConditionCurrency }</YY1_bd_ZINC_amt_BDI>| &&
      |<YY1_bd_jtc1_tcsamount_BDI>{ wa_item-conditionamount3 }</YY1_bd_jtc1_tcsamount_BDI>| &&
      |<YY1_bd_zdif_BDI>{ wa_item-conditionamount4 }</YY1_bd_zdif_BDI>| &&
      |<YY1_bd_zinp_amt_BDI>{ wa_item-conditionamount5 }</YY1_bd_zinp_amt_BDI>| &&
      |<YY1_bd_zrft_amt_BDI>{ wa_item-conditionamount2 }</YY1_bd_zrft_amt_BDI>| &&
      |<YY1_no_of_packages_bd_BDI></YY1_no_of_packages_bd_BDI>| .


***************************************************************************************DISPER & AMT

SELECT single  conditionratevalue ,
        conditionamount
  FROM I_BILLINGDOCITEMPRCGELMNTBASIC
  WHERE BillingDocument = @bill_doc
    AND ConditionType = 'ZDIS'
  INTO  @DATA(wa_discount).
DATA(lv_discount) =
      |<YY1_bd_zdis_dis_amt_BDI>{ wa_discount-ConditionAmount }</YY1_bd_zdis_dis_amt_BDI>| &&
      |<YY1_bd_zdis_dis_per_BDI>{ wa_discount-conditionratevalue }</YY1_bd_zdis_dis_per_BDI>| .
  CONCATENATE lv_item lv_discount into lv_item.
***************************************************************************************DISPER & AMT END

***************************************************************************************TRADENAME BEGIN
      SELECT SINGLE
      a~trade_name
      FROM zmaterial_table AS a
      WHERE a~mat = @wa_item-Product
      INTO @DATA(wa_item3).

      IF wa_item3 IS NOT INITIAL.
        DATA(lv_item3) =
        |<YY1_fg_material_name_BDI>{ wa_item3 }</YY1_fg_material_name_BDI>|.
        CONCATENATE lv_item lv_item3 INTO lv_item .
      ELSE.
        " Fetch Product Name from `i_producttext`
        SELECT SINGLE
        a~productname
        FROM i_producttext AS a
        WHERE a~product = @wa_item-Product
        INTO @DATA(wa_item4).

        DATA(lv_item4) =
        |<YY1_fg_material_name_BDI>{ wa_item4 }</YY1_fg_material_name_BDI>|.
        CONCATENATE lv_item lv_item4 INTO lv_item.
      ENDIF.
      CONCATENATE lv_item '<ItemPricingConditions>' INTO lv_item.
***************************************************************************************TRADENAME END
      LOOP AT lt_item2 INTO DATA(wa_item2) .
        DATA(lv_item2) =
        |<ItemPricingConditionNode>| &&
        |<ConditionAmount>{ wa_item2-ConditionAmount }</ConditionAmount>| &&
        |<ConditionBaseValue>{ wa_item2-ConditionBaseValue }</ConditionBaseValue>| &&
        |<ConditionRateValue>{ wa_item2-ConditionRateValue }</ConditionRateValue>| &&
        |<ConditionType>{ wa_item2-ConditionType }</ConditionType>| &&
        |</ItemPricingConditionNode>|.
        CONCATENATE lv_item lv_item2 INTO lv_item.
        CLEAR wa_item2.
      ENDLOOP.
      DATA(it3) = |</ItemPricingConditions>| && |</BillingDocumentItemNode>|.
      CONCATENATE lv_item it3 INTO lv_item.
      CONCATENATE lv_header lv_item  INTO lv_header.
      CLEAR wa_item.
      CLEAR wa_item3.
      CLEAR wa_item4.
    ENDLOOP.

*    CONCATENATE lv_header lv_item  INTO lv_header .

    DATA(lv_footer) =
    |</Items>| &&
    |<PaymentTerms>| &&
    |<PaymentTermsName>{ wa_data-PaymentTermsConditionDesc }</PaymentTermsName>| &&
    |</PaymentTerms>| &&
    |<ShipToParty>| &&
    |<AddressLine1Text>{ wa_ship-CustomerName }</AddressLine1Text>| &&
    |<AddressLine2Text>{ wa_ship-StreetName }</AddressLine2Text>| &&
    |<AddressLine3Text>{ wa_ship-StreetPrefixName1 }</AddressLine3Text>| &&
    |<AddressLine4Text>{ wa_ship-StreetPrefixName2 }</AddressLine4Text>| &&
    |<AddressLine5Text>{ wa_ship-CityName }</AddressLine5Text>| &&
    |<AddressLine6Text>{ wa_ship-DistrictName }</AddressLine6Text>| &&
    |<AddressLine7Text>{ wa_ship-PostalCode }</AddressLine7Text>| &&
    |<AddressLine8Text>{ wa_ship-Country }</AddressLine8Text>| &&
    |<RegionName>{ wa_ship-RegionName }</RegionName>| &&
    |</ShipToParty>| &&
    |<SoldToParty>| &&
    |<AddressLine2Text>{ wa_sold-StreetName }</AddressLine2Text>| &&
    |<AddressLine3Text>{ wa_sold-StreetPrefixName1 }</AddressLine3Text>| &&
    |<AddressLine4Text>{ wa_sold-StreetPrefixName2 }</AddressLine4Text>| &&
    |<AddressLine5Text>{ wa_sold-CityName }</AddressLine5Text>| &&
    |<AddressLine6Text>{ wa_sold-DistrictName }</AddressLine6Text>| &&
    |<AddressLine7Text>{ wa_sold-PostalCode }</AddressLine7Text>| &&
    |<AddressLine8Text>{ wa_sold-Country }</AddressLine8Text>| &&
    |</SoldToParty>| &&
    |<Supplier>| &&
    |<RegionName>{ wa_data-state_name }</RegionName>| &&
    |</Supplier>| &&
    |<TaxationTerms>| &&
    |<IN_BillToPtyGSTIdnNmbr>{ wa_data-TaxNumber3 }</IN_BillToPtyGSTIdnNmbr>| &&
    |</TaxationTerms>| &&
    |</BillingDocumentNode>| &&
    |</Form>|.

    CONCATENATE lv_header lv_footer INTO lv_header.

    REPLACE ALL OCCURRENCES OF '&' IN lv_header WITH 'and'.
    REPLACE ALL OCCURRENCES OF '<=' IN lv_header WITH 'let'.
    REPLACE ALL OCCURRENCES OF '>=' IN lv_header WITH 'get'.


*i_billingdocumentitemprcgelmnt
* DATA(lv_xml) =
*    |<Form>| &&
*    |<BillingDocument>{ wa_supp-billingdocument }</BillingDocument>| &&
*    |<BillingDocumentItem>{ wa_supp-billingdocumentitem }</BillingDocumentItem>| &&
*    |<Supply_PlantName1>{ wa_SUPP-PlantName2 }</Supply_PlantName1> | &&
*    |<Supply_PlantName2>{ wa_SUPP-PlantName2 }</Supply_PlantName2> | &&
*    |<Supply_Address1>{ wa_SUPP-Address1 }</Supply_Address1> | &&
*    |<Supply_Address2>{ wa_SUPP-Address2 }</Supply_Address2> | &&
*    |<Supply_Address3>{ wa_SUPP-Address3 }</Supply_Address3> | &&
*    |<Supply_City>{ wa_SUPP-City }</Supply_City> | &&
*    |<Supply_District>{ wa_SUPP-District }</Supply_District> | &&
*    |<Supply_StateCode1>{ wa_SUPP-StateCode1 }</Supply_StateCode1> | &&
*    |<Supply_StateCode2>{ wa_SUPP-StateCode2 }</Supply_StateCode2> | &&
*    |<Supply_StateName>{ wa_SUPP-StateName }</Supply_StateName> | &&
*    |<Supply_Pin>{ wa_SUPP-Pin }</Supply_Pin> | &&
*    |<Supply_Country>{ wa_SUPP-Country }</Supply_Country> | &&
*    |<Supply_CinNo>{ wa_SUPP-CinNo }</Supply_CinNo> | &&
*    |<Supply_GstinNo>{ wa_SUPP-GstinNo }</Supply_GstinNo> | &&
*    |<Supply_PanNo>{ wa_SUPP-PanNo }</Supply_PanNo> | &&
*    |<Supply_TanNo>{ wa_SUPP-TanNo }</Supply_TanNo> | &&
*    |<Billto_CustCode>{ wa_billto-gtz_cust_code }</Billto_CustCode> | &&
*    |<Billto_CreationDate>{ wa_billto-creationdate }</Billto_CreationDate> | &&
*    |<Billto_CustomerName>{ wa_billto-customername }</Billto_CustomerName> | &&
*    |<Billto_StreetName>{ wa_billto-streetname }</Billto_StreetName> | &&
*    |<Billto_BPAddrCityName>{ wa_billto-bpaddrcityname }</Billto_BPAddrCityName> | &&
*    |<Billto_BPAddrStreetName>{ wa_billto-bpaddrstreetname }</Billto_BPAddrStreetName> | &&
*    |<Billto_DistrictName>{ wa_billto-districtname }</Billto_DistrictName> | &&
*    |<Billto_PostalCode>{ wa_billto-postalcode }</Billto_PostalCode> | &&
*    |<Billto_TaxNumber3>{ wa_billto-taxnumber3 }</Billto_TaxNumber3> | &&
*    |<Billto_Region>{ wa_billto-region }</Billto_Region> | &&
*    |<Billto_CustomerAccountGroup>{ wa_billto-customeraccountgroup }</Billto_CustomerAccountGroup> | &&
*    |<Billto_Country>{ wa_billto-country }</Billto_Country> | &&
*    |<Billto_CustomerPaymentTermsName>{ wa_billto-customerpaymenttermsname }</Billto_CustomerPaymentTermsName> | &&
*    |<Billto_CountryName>{ wa_billto-countryname }</Billto_CountryName> | &&
*    |<Shippto_CustCode>{ wa_shipto-gtz_cust_code }</Shippto_CustCode> | &&
*    |<Shippto_CreationDate>{ wa_shipto-creationdate }</Shippto_CreationDate> | &&
*    |<Shippto_CustomerName>{ wa_shipto-customername }</Shippto_CustomerName> | &&
*    |<Shippto_StreetName>{ wa_shipto-streetname }</Shippto_StreetName> | &&
*    |<Shippto_BPAddrCityName>{ wa_shipto-bpaddrcityname }</Shippto_BPAddrCityName> | &&
*    |<Shippto_BPAddrStreetName>{ wa_shipto-bpaddrstreetname }</Shippto_BPAddrStreetName> | &&
*    |<Shippto_DistrictName>{ wa_shipto-districtname }</Shippto_DistrictName> | &&
*    |<Shippto_PostalCode>{ wa_shipto-postalcode }</Shippto_PostalCode> | &&
*    |<Shippto_TaxNumber3>{ wa_shipto-taxnumber3 }</Shippto_TaxNumber3> | &&
*    |<Shippto_Region>{ wa_shipto-region }</Shippto_Region> | &&
*    |<Shippto_CustomerAccountGroup>{ wa_shipto-customeraccountgroup }</Shippto_CustomerAccountGroup> | &&
*    |<Shippto_Country>{ wa_shipto-country } </Shippto_Country> | &&
*    |<Shippto_CustomerPaymentTermsName>{ wa_shipto-customerpaymenttermsname }</Shippto_CustomerPaymentTermsName> | &&
*    |<Shippto_CountryName>{ wa_shipto-countryname }</Shippto_CountryName> | &&
*    |<IRN></IRN>| &&
*    |<AckNO></AckNO>| &&
*    |<AckDate></AckDate>| &&
*    |<InvoiceNo></InvoiceNo>| &&
*    |<InvoiceNoDate></InvoiceNoDate>| &&
*    |<CustomerPONo>{ wa_supp-PurchaseOrderByCustomer }</CustomerPONo>| &&
*    |<CustomerPONoDate>{ wa-CustomerPurchaseOrderDate }</CustomerPONoDate>| &&
*    |<AmendmentPONo>{ wa-YY1_POAmendmentNo_SDH }</AmendmentPONo>| &&
*    |<AmendmentPONoDate>{ wa-YY1_POAmendmentDate_SDH }</AmendmentPONoDate>| &&
*    |<OurWorkOrderNo>{ wa_supp-ReferenceSDDocument }</OurWorkOrderNo>| &&
*    |<WorkOrderDate></WorkOrderDate>| &&
*    |<DONo>{ wa-YY1_DONo_SDH }</DONo>| &&
*    |<DODate>{ wa-YY1_DODate_SDH }</DODate>| &&
*    |<Date_Timeofissueofinvoice>{ wa_supp-CreationDate } T{ wa_supp-CreationTime }</Date_Timeofissueofinvoice>| &&
*    |<Date_Timeofremovalofgoods>{ lv_removal-ActualGoodsMovementDate }{ lv_removal-ActualGoodsMovementTime }</Date_Timeofremovalofgoods>| &&
*    |<Way_BillNo></Way_BillNo>| &&
*    |<Way_BillNoDate></Way_BillNoDate>| &&
*    |<ModeofTransport>{ transport-YY1_PreCarriageby_SDH }</ModeofTransport>| &&
*    |<MotorVehicleNo></MotorVehicleNo>| &&
*    |<Transporter></Transporter>| &&
*    |<Remarks></Remarks>| .


*CONCATENATE lv_xml '<TableData>' INTO lv_xml.

*LOOP AT lt_line INTO wa_line.
*  DATA(lv_xml2) =
*        |<tableDataRows>| &&
*        |<BillingDocument>{ wa_line-billingdocument }</BillingDocument>| &&
*        |<BillingDocumentItem>{ wa_line-billingdocumentitem }</BillingDocumentItem>| &&
*        |<Product>{ wa_line-product }</Product>| &&
*        |<Quantity>{ wa_line-billingquantity }</Quantity>| &&
*        |<UOM>{ wa_line-BillingQuantityUnit }</UOM>| &&
*        |<HSN>{ wa_line-ConsumptionTaxCtrlCode }</HSN>| &&
*        |<AvgPack_NoofPackage>{ wa_line-YY1_PackSize_sd_SDI } X { wa_line-YY1_NoofPack_sd_SDI }</AvgPack_NoofPackage>| &&
*        |<PricingRows>|.

*  CONCATENATE lv_xml lv_xml2 INTO lv_xml.
*
*  LOOP AT lt_price INTO DATA(wa_price).
*    DATA(lv_xml3) =
*                |<PricingRowsData>| &&
*                |<ConditionType>{ wa_price-ConditionType }</ConditionType>| &&
*                |<ConditionRateValue>{ wa_price-ConditionRateValue }</ConditionRateValue>| &&
*                |<ConditionAmount>{ wa_price-ConditionAmount }</ConditionAmount>| &&
*                |</PricingRowsData>|.
*    CONCATENATE lv_xml lv_xml3 INTO lv_xml.
*  ENDLOOP.
*
*  CONCATENATE lv_xml '</PricingRows>' '</tableDataRows>' INTO lv_xml.
*ENDLOOP.
*
*CONCATENATE lv_xml '</TableData> </Form>' INTO lv_xml.

*REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.
*REPLACE ALL OCCURRENCES OF '<=' in lv_xml WITH 'let'.
*REPLACE ALL OCCURRENCES OF '>=' in lv_xml WITH 'get'.

*out->write( lt_supp ).



    out->write( lv_header ).



  ENDMETHOD.
ENDCLASS.
