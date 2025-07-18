CLASS zfi_test_jobpurchase DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZFI_TEST_JOBPURCHASE IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  SELECT  FROM  I_OPERATIONALACCTGDOCITEM as a
  LEFT JOIN I_JOURNALENTRY as b on a~AccountingDocument = b~AccountingDocument AND a~CompanyCode = b~CompanyCode AND a~FiscalYear = b~FiscalYear

 FIELDS
 a~AccountingDocument,
 a~CompanyCode,
 a~FiscalYear,
 a~TaxItemGroup,
 a~PostingDate,
 a~BusinessPlace,
 a~CostElement,
 a~ProfitCenter,
 a~IN_HSNORSACCODE,
 a~TaxCode,
 a~ABSOLUTEAMOUNTINCOCODECRCY,
 a~DEBITCREDITCODE,
 b~ReverseDocument,
 b~DocumentDate,
 b~DocumentReferenceID
 WHERE
 a~AccountingDocument = '1900000019' AND a~PurchasingDocument is INITIAL  AND a~AccountingDocumentType IN ( 'KR','KG','KC','UR' )
 AND a~CostElement is NOT INITIAL AND a~TransactionTypeDetermination = ''
 INTO TABLE @DATA(it_data)   PRIVILEGED ACCESS .

 SELECT FROM ZI_ZTABLE_PLANT as a
 FIELDS
 a~PlantCode , concat_with_space( a~PlantName1,a~PlantName2,1 ) AS plantname , a~GstinNo

 WHERE a~PlantCode is NOT INITIAL

 INTO TABLE @DATA(plant).

 SELECT FROM  I_GLACCOUNTTEXTRAWDATA as a
 FIELDS
 a~GLAccountLongName,
 a~GLAccount

 WHERE a~GLAccountLongName is    NOT INITIAL AND a~Language = 'E'
 INTO TABLE @DATA(gl_nmae) PRIVILEGED ACCESS.

 SELECT FROM I_TAXCODETEXT as a
 FIELDS
 a~TaxCode,
 a~TaxCodeName

 WHERE a~TaxCodeName is NOT INITIAL AND a~Language = 'E'
 INTO TABLE @DATA(taxcode) PRIVILEGED ACCESS.
 SELECT FROM I_SUPPLIER as a
 FIELDS
 a~BPSupplierFullName,
 a~TaxNumber3,
 a~BusinessPartnerPanNumber
 WHERE a~BPSupplierFullName is NOT INITIAL
 INTO TABLE @DATA(supll).

 SELECT FROM  I_OPERATIONALACCTGDOCITEM as a
 FIELDS
 a~AccountingDocument,
 a~CompanyCode,
 a~FiscalYear,
 a~FinancialAccountType,
 a~Supplier,
 a~OperationalGLAccount

 WHERE a~AccountingDocument = '1900000019' AND a~AccountingDocumentType IN ( 'KR','KC','KG','UR' )
 INTO TABLE @DATA(readtable).










  ENDMETHOD.
ENDCLASS.
