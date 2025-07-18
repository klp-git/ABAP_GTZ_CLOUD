@EndUserText.label: 'CDS for Journal Entry Report'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCLASS_JOURNAL'
@UI.headerInfo: {typeName: 'Journal REPORT'}

define custom entity zdd_journal 
{
      @UI.selectionField:[{ position: 1 }]
      @UI.lineItem     : [{ position: 1, label: 'Journal Entry No' }]
      @EndUserText.label: 'Journal Entry No'
//    @UI.text: {'label': 'Material Description' }
  key journal_entry_no : abap.char(10);


      @UI.selectionField:[{ position: 2 }]
      @UI.lineItem     : [{ position: 2, label: 'Journal Entry Type' }]
      @EndUserText.label: 'Journal Entry Type'
      journal_entry_ty : abap.char(2);

      @UI.selectionField:[{ position: 3 }]
      @UI.lineItem     : [{ position: 3, label: 'Journal Entry Date' }]
      @EndUserText.label: 'Journal Entry Date'
      journal_entry_dt : abap.dats(8);

      @UI.selectionField:[{ position: 4 }]
      @UI.lineItem     : [{ position: 4, label: 'Amount' }]
      @EndUserText.label: 'Amount'
      @Semantics.amount.currencyCode: 'currency_field'
      amount_field     : abap.curr(23, 2);

      //   @UI.selectionField: [{ position: 5 }]
      //   @UI.lineItem: [{ position: 5, label: 'Currency' }]
      @Semantics.currencyCode: true
      currency_field   : abap.cuky(5);

      @UI.selectionField:[{ position: 5 }]
      @UI.lineItem: [{ position: 5, label: 'Company Code' }]
      @EndUserText.label: 'Company Code'
      CompanyCode      : abap.char(4);






}
