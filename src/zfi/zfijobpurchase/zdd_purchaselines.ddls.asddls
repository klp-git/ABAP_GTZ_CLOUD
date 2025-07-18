
@EndUserText.label: 'zce_fi_pur_reg new'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_FIJOBPURCHASE'
@UI.headerInfo: {typeName: 'Gate Purchase Register', typeNamePlural: 'Gate Purchase Register'}
define custom entity ZDD_PURCHASELINES //ZCDS_FIJOBPURCHASE
{
      @UI.selectionField     : [{ position: 10 }]
      @EndUserText.label     : 'Company Code'
      @UI.lineItem           : [{ position:10, label:'Company Code' }]
  key bukrs                  : abap.char(4);
      @UI.selectionField     : [{ position: 20 }]
//      @EndUserText.label     : 'Fiscal Year'
//      @UI.lineItem           : [{ position:20, label:'Fiscal Year' }]
//  key gjahr                  : abap.char(4);
//      @UI.selectionField     : [{ position: 30 }]
//      @EndUserText.label     : 'Document Number'
//      @UI.lineItem           : [{ position:30, label:'Document Number' }]
//  key belnr                  : abap.char(10);
//      @EndUserText.label     : 'Document Item Number'
//      @UI.lineItem           : [{ position:40, label:'Document Item Number' }]
//  key txgrp                  : abap.numc(3);
//
//      @EndUserText.label     : 'Vendor Code'
//      @UI.lineItem           : [ { position: 50, label: 'Vendor Code' } ]
//      lifnr                  : abap.char(10);
//
//      @EndUserText.label     : 'Vendor Name'
//      @UI.lineItem           : [ { position: 60, label: 'Vendor Name' } ]
//      vendorname             : abap.char(163);
//
//      @EndUserText.label     : 'Vendor Recon.A/C'
//      @UI.lineItem           : [ { position: 70, label: 'Vendor Recon.A/C' } ]
//      vendorreconaccount     : abap.char(10);
//
//      @EndUserText.label     : 'Vendor Recon.A/c Name'
//      @UI.lineItem           : [ { position: 80, label: 'Vendor Recon.A/c Name' } ]
//      vendorreconaccountname : abap.char(50);
//
//      @EndUserText.label     : 'Vendor GSTIN Number'
//      @UI.lineItem           : [ { position: 90, label: 'Vendor GSTIN Number' } ]
//      vendorgstin            : abap.char(15);
//
//      @EndUserText.label     : 'Vendor Pan Number'
//      @UI.lineItem           : [ { position: 100, label: 'Vendor Pan Number' } ]
//      vendorpannumber        : abap.char(10);
//
//
//      @EndUserText.label     : 'Document Type'
//      @UI.lineItem           : [ { position: 110, label: 'Document Type' } ]
//      AccountingDocumentType : abap.char(2);
//
//      //      @EndUserText.label: 'Document Line Item'
//      //      @UI.lineItem: [ { position: 110, label: 'Document Line Item' } ]
//      //      @UI.identification: [ { position: 110, label: 'Document Line Item' } ]
//      //      documentlineitem        as Documentlineitem,
////      //
////      @EndUserText.label     : 'Posting Date'
////      @UI.lineItem           : [ { position: 130, label: 'Posting Date' } ]
////      @UI.selectionField     : [{ position:40 }]
////      postingdate            : datn;
////
////      @EndUserText.label     : 'Plant Name'
////      @UI.lineItem           : [ { position: 140, label: 'Plant Name' } ]
////      plantname              : abap.char(100);
////
////      @EndUserText.label     : 'Plant GST'
////      @UI.lineItem           : [ { position: 150, label: 'Plant GST' } ]
////      plantgst               : abap.char(15);
////      //
//      @EndUserText.label     : 'GL A/c No.'
//      @UI.lineItem           : [ { position: 160, label: 'GL A/c No.' } ]
//      costelement            : abap.char(10);
//
//      @EndUserText.label     : 'GL A/c Description'
//      @UI.lineItem           : [ { position: 170, label: 'GL A/c Description' } ]
//      glaccountdiscription   : abap.char(50);
//
//      @EndUserText.label     : 'Bill / Ref. Number'
//      @UI.lineItem           : [ { position: 180, label: 'Bill / Ref. Number' } ]
//      xblnr                  : abap.char(16);
//
//      @EndUserText.label     : 'Bill / Ref. Date'
//      @UI.lineItem           : [ { position: 190, label: 'Bill / Ref. Date' } ]
//      documentdate           : datn;
//      //
//      //     @EndUserText.label: 'Vendor Type'
//      //      @UI.lineItem: [ { position: 200, label: 'Vendor Type' } ]
//      //      vendortype            as Vendortype ,
//      //
//      //      @EndUserText.label: 'Type of Enterprise'
//      //      @UI.lineItem: [ { position: 210, label: 'Type of Enterprise' } ]
//      //     typeofenterprise           as typeofenterprise,
//
//      @EndUserText.label     : 'Profit Center'
//      @UI.lineItem           : [ { position: 215, label: 'Profit Center' } ]
//      profitcenter           : abap.char(10);
//
//      @EndUserText.label     : 'HSN Code'
//      @UI.lineItem           : [ { position: 220, label: 'HSN Code' } ]
//      hsncode                : abap.char(16);
//
//      @EndUserText.label     : 'Tax Code'
//      @UI.lineItem           : [ { position: 230, label: 'Tax Code' } ]
//      taxcode                : abap.char(2);
//
//      @EndUserText.label     : 'Tax Code Name'
//      @UI.lineItem           : [ { position: 240, label: 'Tax Code Name' } ]
//      taxcodename            : abap.char(50);

      @EndUserText.label     : 'Taxable  Value'
      @UI.lineItem           : [ { position: 250, label: 'Taxable Value' } ]
      taxablevalue           : abap.dec(25,2);

      @EndUserText.label     : 'IGST Receivable'
      @UI.lineItem           : [ { position: 260, label: 'IGST Receivable' } ]
      igst_receive           : abap.dec(25,2);

      @EndUserText.label     : 'CGST Receivable'
      @UI.lineItem           : [ { position: 270, label: 'CGST Receivable' } ]
      cgst_receive           : abap.dec(25,2);

      @EndUserText.label     : 'SGST Receivable'
      @UI.lineItem           : [ { position: 280, label: 'SGST Receivable' } ]
      sgst_receive           : abap.dec(25,2);

      @EndUserText.label     : 'UGST Receivable'
      @UI.lineItem           : [ { position: 290, label: 'UGST Receivable' } ]
      ugst_receive           : abap.dec(25,2);

      @EndUserText.label     : 'Total Tax'
      @UI.lineItem           : [ { position: 300, label: 'Total Tax' } ]
      total_tax              : abap.dec(25,2);

      @EndUserText.label     : 'Round Off'
      @UI.lineItem           : [ { position: 310, label: 'Round Off' } ]
      round_off              : abap.dec(25,2);

      @EndUserText.label     : 'Total Amount'
      @UI.lineItem           : [ { position: 320, label: 'Total Amount' } ]
      total_amount           : abap.dec(25,2);

      @EndUserText.label     : 'IGST %'
      @UI.lineItem           : [ { position: 330, label: 'IGST %' } ]
      rate_igst              : abap.dec(5,2);

      @EndUserText.label     : 'CGST %'
      @UI.lineItem           : [ { position: 350, label: 'CGST %' } ]
      rate_cgst              : abap.dec(5,2);

      @EndUserText.label     : 'SGST %'
      @UI.lineItem           : [ { position: 360, label: 'SGST %' } ]
      rate_sgst              : abap.dec(5,2);

      @EndUserText.label     : 'UGST %'
      @UI.lineItem           : [ { position: 370, label: 'UGST %' } ]
      rate_ugst              : abap.dec(5,2);

      @EndUserText.label     : 'RCM IGST Payable'
      @UI.lineItem           : [ { position: 380, label: 'RCM IGST Payable' } ]
      rcm_igst               : abap.dec(25,2);

      @EndUserText.label     : 'RCM CGST Payable'
      @UI.lineItem           : [ { position: 390, label: 'RCM CGST Payable' } ]
      rcm_cgst               : abap.dec(25,2);

      @EndUserText.label     : 'RCM SGST Payable'
      @UI.lineItem           : [ { position: 400, label: 'RCM SGST Payable' } ]
      rcm_sgst               : abap.dec(25,2);

      @EndUserText.label     : ' RCM UGST Payable'
      @UI.lineItem           : [ { position: 410, label: 'RCM UGST Payable' } ]
      rcm_ugst               : abap.dec(25,2);

      @EndUserText.label     : 'Is Reversed'
      @UI.lineItem           : [ { position: 420, label: 'Is Reversed' } ]
      is_reversed            : abap.char(10);

}




//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@EndUserText.label: 'Data defination of purchaselines'
//@Metadata.ignorePropagatedAnnotations: false
//define root view entity ZDD_PURCHASELINES
//  as select from zpurchase_table
//{
//      @EndUserText.label: 'Company Code'
//      @UI.lineItem: [ { position: 10, importance: #HIGH, label: 'Company Code' } ]
//      @UI.identification: [ { position: 10, label: 'Company Code' } ]
//       @Search.defaultSearchElement: true
//       @UI.selectionField   : [{ position:10 }]
//  key companycode         as Companycode,
//
//      @EndUserText.label: 'Fiscal Year'
//      @UI.lineItem: [ { position: 20, importance: #HIGH, label: 'Fiscal year' } ]
//      @UI.identification: [ { position: 20, label: 'Fiscal year' } ]
//      @Search.defaultSearchElement: true
//       @UI.selectionField   : [{ position:20 }]
//  key fiscalyearvalue     as Fiscalyearvalue,
//  
//    @EndUserText.label: 'FI Document Number'
//      @UI.lineItem: [ { position: 92, importance: #HIGH, label: 'FI Document Number' } ]
//      @UI.identification: [ { position: 92, label: 'FI Document Number' } ]
//      @Search.defaultSearchElement: true
//       @UI.selectionField   : [{ position:30 }]
//  key fidocumentno        as Fidocumentno,
//  
//  
//      @EndUserText.label: 'FI Document Line Item'
//      @UI.lineItem: [ { position: 101, label: 'FI Document Line Item' } ]
//      @UI.identification: [ { position: 101, label: 'FI Document Line Item' } ]
//  key fidocumentitem      as Fidocumentitem,
//       
//  
//    @EndUserText.label: 'Vendor Code'
//      @UI.lineItem: [ { position: 40, label: 'Vendor Code' } ]  
//      @UI.identification: [ { position: 40, label: 'Vendor Code' } ]
//      vendorcode          as Vendorcode,
//
////      @EndUserText.label: 'Supplier Invoice'
////      @UI.lineItem: [ { position: 50, label: 'Supplier Invoice' } ]
////      @UI.identification: [ { position: 50, label: 'Supplier Invoice' } ]
////      supplierinvoice     as Supplierinvoice, 
////
////      @EndUserText.label: 'Supplier Invoice Item'
////      @UI.lineItem: [ { position: 60, label: 'Supplier Invoice Item' } ]
////      @UI.identification: [ { position: 60, label: 'Supplier Invoice Item' } ]
////      supplierinvoiceitem as Supplierinvoiceitem,
////      
//      
//     
//
//      @EndUserText.label: 'Vendor Name'
//      @UI.lineItem: [ { position: 50, importance: #HIGH, label: 'Vendor Name' } ]
//      @UI.identification: [ { position: 50, label: 'Vendor Name' } ]
//      vendorname          as Vendorname,
//      
//      @EndUserText.label: 'Vendor Reco.A/C'
//      @UI.lineItem: [ { position: 60, importance: #HIGH, label: 'Vendor Reco.A/C' } ]
//      @UI.identification: [ { position: 60, label: 'Vendor Reco.A/C' } ]
//      vendorreconaccount as vendorreconaccount,
//      
//      @EndUserText.label: 'Vendor Recon.A/c Name'
//      @UI.lineItem: [ { position: 70, importance: #HIGH, label: 'Vendor Recon.A/c Name' } ]
//      @UI.identification: [ { position: 70, label: 'Vendor Recon.A/c Name' } ]
//      vendorreconaccountname as Vendorreconaccountname,
//      
//     @EndUserText.label: 'Vendor GSTIN Number'
//      @UI.lineItem: [ { position: 80, importance: #HIGH, label: 'Vendor GSTIN Number' } ]
//      @UI.identification: [ { position: 80, label: 'Vendor GSTIN Number' } ]
//      vendorgstnumber as Vendorgstnumber,
//     @EndUserText.label: 'Vendor Pan Number'
//      @UI.lineItem: [ { position: 90, importance: #HIGH, label: 'Vendor Pan Number' } ]
//      @UI.identification: [ { position: 90, label: 'Vendor Pan Number' } ]
//      vendorpannumber  as Vendorpannumber,
//       
//      
//      @EndUserText.label: 'Document Type'
//      @UI.lineItem: [ { position: 100, importance: #HIGH, label: 'Document Type' } ]
//      @UI.identification: [ { position: 100, label: 'Document Type' } ]
//      documenttype   as Documenttype,  
//      
//     
//      
//      @EndUserText.label: 'Document Line Item'
//      @UI.lineItem: [ { position: 110, label: 'Document Line Item' } ]
//      @UI.identification: [ { position: 110, label: 'Document Line Item' } ]
//      documentlineitem        as Documentlineitem,
//    
//      @EndUserText.label: 'Posting Date'
//      @UI.lineItem: [ { position: 120, label: 'Posting Date' } ]
//      @UI.identification: [ { position: 120, label: 'Posting Date' } ]
//       @Search.defaultSearchElement: true
//       @UI.selectionField   : [{ position:40 }]
//     // @Consumption.filter:{ mandatory: true }
//      postingdate         as Postingdate,
//
//      @EndUserText.label: 'Plant Name'
//      @UI.lineItem: [ { position: 130, label: 'Plant Name' } ]
//      @UI.identification: [ { position: 130, label: 'Plant Name' } ]
//      plantname           as Plantname,
//      
//      @EndUserText.label: 'Plant GST'
//      @UI.lineItem: [ { position: 140, label: 'Plant GST' } ]
//      @UI.identification: [ { position: 140, label: 'Plant GST' } ]
//       plantgst           as  plantgst,
//       
//       @EndUserText.label: 'Glaccount Number'
//      @UI.lineItem: [ { position: 150, label: 'Glaccount Number' } ]
//      @UI.identification: [ { position: 150, label: 'Glaccount Number' } ]
//      glaccountnumber          as Glaccountnumber,
//      
//      @EndUserText.label: 'GL A/c Description'
//      @UI.lineItem: [ { position: 160, label: 'GL A/c Description' } ]
//      @UI.identification: [ { position: 160, label: 'GL A/c Description' } ]
//       glaccountdiscription          as  Glaccountdiscription,
//       
//       @EndUserText.label: 'Bill / Ref. Number'
//      @UI.lineItem: [ { position: 170, label: 'Bill / Ref. Number' } ]
//      @UI.identification: [ { position: 170, label: 'Bill / Ref. Number' } ]
//      billrefnumber   as Bllrefnumber,
//      
//      @EndUserText.label: 'Bill / Ref. Date'
//      @UI.lineItem: [ { position: 180, label: 'Bill / Ref. Date' } ]
//      @UI.identification: [ { position: 180, label: 'Bill / Ref. Date' } ]
//     billrefdate           as billrefdate,
//     
//     @EndUserText.label: 'Vendor Type'
//      @UI.lineItem: [ { position: 190, label: 'Vendor Type' } ]
//      @UI.identification: [ { position: 190, label: 'Vendor Type' } ]
//      vendortype            as Vendortype ,
//      
//      @EndUserText.label: 'Type of Enterprise'
//      @UI.lineItem: [ { position: 200, label: 'Type of Enterprise' } ]
//      @UI.identification: [ { position: 200, label: 'Type of Enterprise' } ]
//     typeofenterprise           as typeofenterprise,
//      
//      
//      
//      @EndUserText.label: 'Profit Center'
//      @UI.lineItem: [ { position: 210, label: 'Profit Center' } ]
//      @UI.identification: [ { position: 210, label: 'Profit Center' } ]
//      profitcenter        as Profitcenter,
//
//      @EndUserText.label: 'HSN Code'
//      @UI.lineItem: [ { position: 220, label: 'HSN Code' } ]
//      @UI.identification: [ { position: 220, label: 'HSN Code' } ]
//      hsncode             as Hsncode,
//      
//      @EndUserText.label: 'Tax Code'
//      @UI.lineItem: [ { position: 230, label: 'Tax Code' } ]
//      @UI.identification: [ { position: 230, label: 'Tax Code' } ]
//      taxcode             as Taxcode,
//      
//       @EndUserText.label: 'Tax Code Name'
//      @UI.lineItem: [ { position: 240, label: 'Tax Code Name' } ]
//      @UI.identification: [ { position: 240, label: 'Tax Code Name' } ]
//     taxcodename            as Taxcodename,
//     
//      @EndUserText.label: 'Taxable  Value'
//      @UI.lineItem: [ { position: 250, label: 'Taxable Value' } ]
//      @UI.identification: [ { position: 250, label: 'Taxable Value' } ]
//     taxablevalue             as Taxablevalue,
//     
//      @EndUserText.label: 'IGST Receivable'
//      @UI.lineItem: [ { position: 260, label: 'IGST Receivable' } ]
//      @UI.identification: [ { position: 260, label: 'IGST Receivable' } ]
//     igst_receive             as Igst_receive,
//
//      @EndUserText.label: 'CGST Receivable'
//      @UI.lineItem: [ { position: 270, label: 'CGST Receivable' } ]
//      @UI.identification: [ { position: 270, label: 'CGST Receivable' } ]
//      cgst_receive        as CgstReceive,
//
//      @EndUserText.label: 'SGST Receivable'
//      @UI.lineItem: [ { position: 280, label: 'SGST Receivable' } ]
//      @UI.identification: [ { position: 280, label: 'SGST Receivable' } ]
//      sgst_receive        as SgstReceive,
//      
//      @EndUserText.label: 'UGST Receivable'
//      @UI.lineItem: [ { position: 290, label: 'UGST Receivable' } ]
//      @UI.identification: [ { position: 290, label: 'UGST Receivable' } ]
//      ugst_receive        as ugst_receive,
//
//
//      @EndUserText.label: 'Total Tax'
//      @UI.lineItem: [ { position: 300, importance: #HIGH, label: 'Total Tax' } ]
//      @UI.identification: [ { position: 300, label: 'Total Tax' } ]
//       total_tax         as total_tax,
//       
//       
//      @EndUserText.label: 'Round Off'
//      @UI.lineItem: [ { position: 310, importance: #HIGH, label: 'Round Off' } ]
//      @UI.identification: [ { position: 310, label: 'Net Amount' } ]
//       round_off         as round_off ,
//       
//       
//      @EndUserText.label: 'Total Amount'
//      @UI.lineItem: [ { position: 320, importance: #HIGH, label: 'Total Amount' } ]
//      @UI.identification: [ { position: 320, label: 'Net Amount' } ]
//         tot_amount         as   Tot_amount ,
//    
//      @EndUserText.label: 'IGST %'
//      @UI.lineItem: [ { position: 340, importance: #HIGH, label: 'IGST %' } ]
//      @UI.identification: [ { position: 340, label: 'Net Amount' } ]
//        igst        as   Igst,
//        
//        @EndUserText.label: 'CGST %'
//      @UI.lineItem: [ { position: 350, importance: #HIGH, label: 'CGST %' } ]
//      @UI.identification: [ { position: 350, label: 'Net Amount' } ]
//        cgst        as   Cgst,
//        
//        @EndUserText.label: 'SGST %'
//      @UI.lineItem: [ { position: 360, importance: #HIGH, label: 'SGST %' } ]
//      @UI.identification: [ { position: 360, label: 'Net Amount' } ]
//        sgst        as   Sgst,
//        
//        @EndUserText.label: 'UGST %'
//      @UI.lineItem: [ { position: 370, importance: #HIGH, label: 'UGST %' } ]
//      @UI.identification: [ { position: 370, label: 'Net Amount' } ]
//        ugst        as   Ugst,
//        
//        @EndUserText.label: 'RCM IGST Payable'
//      @UI.lineItem: [ { position: 380, importance: #HIGH, label: 'RCM IGST Payable' } ]
//      @UI.identification: [ { position: 380, label: 'Is Rversed' } ]
//        igst_payable       as   Igst_payable,
//        
//         @EndUserText.label: 'RCM CGST Payable'
//      @UI.lineItem: [ { position: 390, importance: #HIGH, label: 'RCM CGST Payable' } ]
//      @UI.identification: [ { position: 390, label: 'Is Rversed' } ]
//        cgst_payable         as    Cgst_payable ,
//        
//         @EndUserText.label: 'RCM SGST Payable'
//      @UI.lineItem: [ { position: 400, importance: #HIGH, label: 'RCM SGST Payable' } ]
//      @UI.identification: [ { position: 400, label: 'Is Rversed' } ]
//        sgst_payable        as   Sgst_payable ,
//         @EndUserText.label: ' RCM UGST Payable'
//      @UI.lineItem: [ { position: 410, importance: #HIGH, label: 'RCM UGST Payable' } ]
//      @UI.identification: [ { position: 410, label: 'Is Rversed' } ]
//        ugst_payable        as   Ugst_payable ,
//        
//           @EndUserText.label: ' Is_Reversed'
//      @UI.lineItem: [ { position: 420, importance: #HIGH, label: 'Isreversed
//      ' } ]
//      @UI.identification: [ { position: 420, label: 'Is Rversed' } ]
//       is_reversed        as   Is_reversed 
//        
//     
//         
//         
//       
//        
//        
//}
//
//
//
//
//
//
//
//
//
//
//
//
