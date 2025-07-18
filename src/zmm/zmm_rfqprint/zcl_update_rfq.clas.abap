CLASS zcl_update_rfq DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_UPDATE_RFQ IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
*    SELECT * FROM
*    zrfqmatrix AS a
*    WHERE a~requestforquotation IS NOT INITIAL
*    INTO TABLE @DATA(lt).
*
*    DATA: wa2 TYPE zrfqmatrix.
*
*    LOOP AT lt INTO DATA(wa).
*      wa2 = wa.
*      DATA: lv_prcode TYPE zrfqmatrix-productcode.
*      lv_prcode = wa-productcode.
*
*      SHIFT lv_prcode LEFT DELETING LEADING '0'.
*      SELECT SINGLE FROM
*      zmaterial_table AS a
*      FIELDS
*      a~trade_name
*      WHERE a~mat = @lv_prcode
*      INTO @DATA(lv_trade).
*
*      wa2-producttradename = lv_trade.
*
*      DATA: lv_vendor TYPE zmsme_table-vendorno.
*      lv_vendor = wa-vendorcode.
*      SHIFT lv_vendor LEFT DELETING LEADING '0'.
*      SELECT SINGLE FROM
*      zmsme_table AS a
*      FIELDS
*      a~validfrom,
*      a~creationdate,
*      a~certificateno,
*      a~vendortype
*      WHERE a~vendorno = @lv_vendor
*      INTO @DATA(lv_msme).
*
*      wa2-vendortype = lv_msme-vendortype.
*      wa2-udyamcertificatedate = lv_msme-validfrom.
*      wa2-udyamcertificatereceivingdate = lv_msme-creationdate.
*      wa2-udyamaadharno = lv_msme-certificateno.
*
*      SELECT SINGLE FROM
*      i_purchasinginforecordapi01 AS a
*      FIELDS
*      a~YY1_VendorSpecialName_SOS
*      WHERE a~Material = @wa-productcode AND a~Supplier = @wa-vendorcode
*      INTO @DATA(lv_special).
*
*      wa2-vendorspecialname = lv_special.
*
*      MODIFY zrfqmatrix FROM @wa2.
*      CLEAR lv_special.
*      CLEAR wa2.
*      CLEAR lv_vendor.
*      CLEAR lv_msme.
*      CLEAR lv_prcode.
*      CLEAR lv_trade.
*      CLEAR wa.
*    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
