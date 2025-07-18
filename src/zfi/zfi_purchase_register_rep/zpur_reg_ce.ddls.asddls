@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_FI_PURREG_REP'
@UI.headerInfo: {typeName: 'FI Purchase Register', typeNamePlural: 'FI Purchase Register'}
define custom entity zpur_reg_ce
{
      @UI.selectionField     : [{ position: 10 }]
      @EndUserText.label     : 'Company Code'
      @UI.lineItem           : [{ position:10, label:'Company Code' }]
  key bukrs                  : abap.char(4);
      @UI.selectionField     : [{ position: 20 }]
      @EndUserText.label     : 'Fiscal Year'
      @UI.lineItem           : [{ position:20, label:'Fiscal Year' }]
  key gjahr                  : abap.char(4);
      @UI.selectionField     : [{ position: 30 }]
      @EndUserText.label     : 'Document Number'
      @UI.lineItem           : [{ position:30, label:'Document Number' }]
  key belnr                  : abap.char(10);
      @EndUserText.label     : 'Document Item Number'
      @UI.lineItem           : [{ position:40, label:'Document Item Number' }]
  key txgrp                  : abap.numc(3);

      @EndUserText.label     : 'Vendor Code'
      @UI.lineItem           : [ { position: 50, label: 'Vendor Code' } ]
      lifnr                  : abap.char(10);

      @EndUserText.label     : 'Vendor Name'
      @UI.lineItem           : [ { position: 60, label: 'Vendor Name' } ]
      vendorname             : abap.char(163);

      @EndUserText.label     : 'Vendor Recon.A/C'
      @UI.lineItem           : [ { position: 70, label: 'Vendor Recon.A/C' } ]
      vendorreconaccount     : abap.char(10);

      @EndUserText.label     : 'Vendor Recon.A/c Name'
      @UI.lineItem           : [ { position: 80, label: 'Vendor Recon.A/c Name' } ]
      vendorreconaccountname : abap.char(50);

      @EndUserText.label     : 'Vendor GSTIN Number'
      @UI.lineItem           : [ { position: 90, label: 'Vendor GSTIN Number' } ]
      vendorgstin            : abap.char(15);

      @EndUserText.label     : 'Vendor Pan Number'
      @UI.lineItem           : [ { position: 100, label: 'Vendor Pan Number' } ]
      vendorpannumber        : abap.char(10);

        @UI.selectionField     : [{ position: 50 }]
      @EndUserText.label     : 'Document Type'
      @UI.lineItem           : [ { position: 110, label: 'Document Type' } ]
      AccountingDocumentType : abap.char(2);

      @EndUserText.label     : 'Document Type Name'
      @UI.lineItem           : [ { position: 120, label: 'Document Type Name' } ]
      AccountingDocTypename  : abap.char(40);

      //      @EndUserText.label: 'Document Line Item'
      //      @UI.lineItem: [ { position: 110, label: 'Document Line Item' } ]
      //      @UI.identification: [ { position: 110, label: 'Document Line Item' } ]
      //      documentlineitem        as Documentlineitem,
      //
      @EndUserText.label     : 'Posting Date'
      @UI.lineItem           : [ { position: 130, label: 'Posting Date' } ]
      @UI.selectionField     : [{ position:40 }]
      postingdate            : datn;

      @EndUserText.label     : 'Plant Name'
      @UI.lineItem           : [ { position: 140, label: 'Plant Name' } ]
      plantname              : abap.char(100);

      @EndUserText.label     : 'Plant GST'
      @UI.lineItem           : [ { position: 150, label: 'Plant GST' } ]
      plantgst               : abap.char(15);
      //
      @EndUserText.label     : 'GL A/c No.'
      @UI.lineItem           : [ { position: 160, label: 'GL A/c No.' } ]
      costelement            : abap.char(10);

      @EndUserText.label     : 'GL A/c Description'
      @UI.lineItem           : [ { position: 170, label: 'GL A/c Description' } ]
      glaccountdiscription   : abap.char(50);

      @EndUserText.label     : 'Item Text'
      @UI.lineItem           : [ { position: 175, label: 'Item Text' } ]
      item_text              : abap.char(50);

      @EndUserText.label     : 'Bill / Ref. Number'
      @UI.lineItem           : [ { position: 180, label: 'Bill / Ref. Number' } ]
      xblnr                  : abap.char(16);

      @EndUserText.label     : 'Bill / Ref. Date'
      @UI.lineItem           : [ { position: 190, label: 'Bill / Ref. Date' } ]
      documentdate           : datn;
      //
      //     @EndUserText.label: 'Vendor Type'
      //      @UI.lineItem: [ { position: 200, label: 'Vendor Type' } ]
      //      vendortype            as Vendortype ,
      //
      //      @EndUserText.label: 'Type of Enterprise'
      //      @UI.lineItem: [ { position: 210, label: 'Type of Enterprise' } ]
      //     typeofenterprise           as typeofenterprise,

      @EndUserText.label     : 'Profit Center'
      @UI.lineItem           : [ { position: 215, label: 'Profit Center' } ]
      profitcenter           : abap.char(10);

      @EndUserText.label     : 'HSN Code'
      @UI.lineItem           : [ { position: 220, label: 'HSN Code' } ]
      hsncode                : abap.char(16);

      @EndUserText.label     : 'Tax Code'
      @UI.lineItem           : [ { position: 230, label: 'Tax Code' } ]
      taxcode                : abap.char(2);

      @EndUserText.label     : 'Tax Code Name'
      @UI.lineItem           : [ { position: 240, label: 'Tax Code Name' } ]
      taxcodename            : abap.char(50);

      @EndUserText.label     : 'GST Input Type'
      @UI.lineItem           : [ { position: 245, label: 'GST Input Type' } ]
      gstinput_type          : abap.char(20);

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
      @UI.selectionField     : [{ position: 55 }]
      @EndUserText.label     : 'Is Reversed'
      @UI.lineItem           : [ { position: 420, label: 'Is Reversed' } ]
      is_reversed            : abap.char(10);

}
