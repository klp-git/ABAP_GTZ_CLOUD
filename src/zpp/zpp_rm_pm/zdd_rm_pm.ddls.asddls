@EndUserText.label: 'Data Defination For Rm and pm'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_PP_RM_PM'
@UI.headerInfo: { typeName: 'Planning',
typeNamePlural:'Plannings' }

define custom entity zdd_rm_pm
{
      @EndUserText.label    : 'Material'
      @UI.lineItem          : [{ position: 10, label: 'Material' }]
      @UI.selectionField    : [{ position: 10 }]
      @Consumption.valueHelpDefinition: [{ entity : { name : 'zdd_rm_mat_vh',element : 'Product' } } ]
  key item_code             : abap.char(40);

      @EndUserText.label    : 'Material Name'
      @UI.lineItem          : [{ position: 20, label: 'Material Name' }]
      @UI.selectionField    : [{ position: 20 }]
      @Consumption.valueHelpDefinition: [{ entity : { name : 'zdd_rm_mat_vh',element : 'ProductName' } } ]
      item_name             : abap.char(80);

      @EndUserText.label    : 'Plant'
      @UI.lineItem          : [{ position: 30, label: 'Plant' }]
      @UI.selectionField    : [{ position: 30 }]
      plant                 : abap.char(4);
      
      @EndUserText.label    : 'UOM'
      @UI.lineItem          : [{ position: 40, label: 'UOM' }]
      @UI.selectionField    : [{ position: 40 }]
      uom                 : abap.char(2);

      //      @EndUserText.label          : 'Reorder Point'
      //      @UI.lineItem    : [{ position: 30, label: 'Reorder Point' }]
      //      @UI.selectionField          : [{ position: 30 }]
      //      msq             : abap.string;

      //      @EndUserText.label          : 'Csq'
      //      @UI.lineItem  : [{ position: 40, label: 'Csq' }]
      //      @UI.selectionField          : [{ position: 40 }]
      //      csq       : abap.string;
      //
      //      @EndUserText.label          : 'Pwoq'
      //      @UI.lineItem  : [{ position: 50, label: 'Pwoq' }]
      //      @UI.selectionField          : [{ position: 50 }]
      //      pwoq      : abap.string;

      @UI.selectionField    : [{exclude: true}]
      @UI.lineItem          : [{ position: 60, label: 'Sob' }]
      @UI.selectionField    : [{ position: 60 }]
      sob                   : abap.string;

      //      @UI.selectionField          : [{exclude: true}]
      @EndUserText.label    : 'Pre. Pend. W/O'
      @UI.lineItem          : [{ position: 65, label: 'Req. As Per Pre. Pend. W/O' }]
      pre_pend_wo           : abap.string;

      @EndUserText.label    : 'Day 1'
      @UI.lineItem          : [{ position: 70, label: 'Day 1' }]
      Day1                  : abap.string;

      @EndUserText.label    : 'Day 2'
      @UI.lineItem          : [{ position: 80, label: 'Day 2' }]
      Day2                  : abap.string;

      @EndUserText.label    : 'Day 3'
      @UI.lineItem          : [{ position: 90, label: 'Day 3' }]
      Day3                  : abap.string;

      @EndUserText.label    : 'Day 4'
      @UI.lineItem          : [{ position: 100, label: 'Day 4' }]
      Day4                  : abap.string;

      @EndUserText.label    : 'Day 5'
      @UI.lineItem          : [{ position: 110, label: 'Day 5' }]
      Day5                  : abap.string;

      @EndUserText.label    : 'Day 6'
      @UI.lineItem          : [{ position: 120, label: 'Day 6' }]
      Day6                  : abap.string;

      @EndUserText.label    : 'Day 7'
      @UI.lineItem          : [{ position: 130, label: 'Day 7' }]
      Day7                  : abap.string;

      @EndUserText.label    : 'Day 8'
      @UI.lineItem          : [{ position: 140, label: 'Day 8' }]
      Day8                  : abap.string;

      @EndUserText.label    : 'Day 9'
      @UI.lineItem          : [{ position: 150, label: 'Day 9' }]
      Day9                  : abap.string;

      @EndUserText.label    : 'Day 10'
      @UI.lineItem          : [{ position: 160, label: 'Day 10' }]
      Day10                 : abap.string;

      @EndUserText.label    : 'Day 11'
      @UI.lineItem          : [{ position: 170, label: 'Day 11' }]
      Day11                 : abap.string;

      @EndUserText.label    : 'Day 12'
      @UI.lineItem          : [{ position: 180, label: 'Day 12' }]
      Day12                 : abap.string;

      @EndUserText.label    : 'Day 13'
      @UI.lineItem          : [{ position: 190, label: 'Day 13' }]
      Day13                 : abap.string;

      @EndUserText.label    : 'Day 14'
      @UI.lineItem          : [{ position: 200, label: 'Day 14' }]
      Day14                 : abap.string;

      @EndUserText.label    : 'Day 15'
      @UI.lineItem          : [{ position: 210, label: 'Day 15' }]
      Day15                 : abap.string;

      @EndUserText.label    : 'Day 16'
      @UI.lineItem          : [{ position: 220, label: 'Day 16' }]
      Day16                 : abap.string;

      @EndUserText.label    : 'Day 17'
      @UI.lineItem          : [{ position: 230, label: 'Day 17' }]
      Day17                 : abap.string;

      @EndUserText.label    : 'Day 18'
      @UI.lineItem          : [{ position: 240, label: 'Day 18' }]
      Day18                 : abap.string;

      @EndUserText.label    : 'Day 19'
      @UI.lineItem          : [{ position: 250, label: 'Day 19' }]
      Day19                 : abap.string;

      @EndUserText.label    : 'Day 20'
      @UI.lineItem          : [{ position: 260, label: 'Day 20' }]
      Day20                 : abap.string;

      @EndUserText.label    : 'Day 21'
      @UI.lineItem          : [{ position: 270, label: 'Day 21' }]
      Day21                 : abap.string;

      @EndUserText.label    : 'Day 22'
      @UI.lineItem          : [{ position: 280, label: 'Day 22' }]
      Day22                 : abap.string;

      @EndUserText.label    : 'Day 23'
      @UI.lineItem          : [{ position: 290, label: 'Day 23' }]
      Day23                 : abap.string;

      @EndUserText.label    : 'Day 24'
      @UI.lineItem          : [{ position: 300, label: 'Day 24' }]
      Day24                 : abap.string;

      @EndUserText.label    : 'Day 25'
      @UI.lineItem          : [{ position: 310, label: 'Day 25' }]
      Day25                 : abap.string;

      @EndUserText.label    : 'Day 26'
      @UI.lineItem          : [{ position: 320, label: 'Day 26' }]
      Day26                 : abap.string;

      @EndUserText.label    : 'Day 27'
      @UI.lineItem          : [{ position: 330, label: 'Day 27' }]
      Day27                 : abap.string;

      @EndUserText.label    : 'Day 28'
      @UI.lineItem          : [{ position: 340, label: 'Day 28' }]
      Day28                 : abap.string;

      @EndUserText.label    : 'Day 29'
      @UI.lineItem          : [{ position: 350, label: 'Day 29' }]
      Day29                 : abap.string;

      @EndUserText.label    : 'Day 30'
      @UI.lineItem          : [{ position: 360, label: 'Day 30' }]
      Day30                 : abap.string;

      @EndUserText.label    : 'Total'
      @UI.lineItem          : [{ position: 370, label: 'Total' }]
      total                 : abap.string;

      @EndUserText.label    : 'Scb'
      @UI.lineItem          : [{ position: 380, label: 'Scb' }]
      scb                   : abap.string;

      @EndUserText.label    : 'Reorder Point'
      @UI.lineItem          : [{ position: 390, label: 'Reorder Point' }]
      //      @UI.selectionField    : [{ position: 390 }]
      msq                   : abap.string;

      @EndUserText.label    : 'Safety Stock Quantity'
      @UI.lineItem          : [{ position: 400, label: 'Safety Stock Quantity' }]
      min_stock_qty         : abap.string;

      //      @EndUserText.label    : 'Reorder Point'
      //      @UI.lineItem          : [{ position: 400, label: 'Reorder Point' }]
      //      @UI.selectionField    : [{ position: 400 }]
      //      msq                   : abap.string;

      //      @EndUserText.label    : 'Reorder Point'
      //      @UI.lineItem          : [{ position: 400, label: 'Reorder Point' }]
      //      @UI.hidden            : true
      //      Reorder_point         : abap.string;

      @EndUserText.label    : 'Max Stock Level'
      @UI.lineItem          : [{ position: 410, label: 'Max Stock Level' }]
      Max_stock_level       : abap.string;

      @EndUserText.label    : 'Ordering Qty'
      @UI.lineItem          : [{ position: 420, label: 'Ordering Qty' }]
      Ordering_Qty          : abap.string;

      @EndUserText.label    : 'Effective avail Stock'
      @UI.lineItem          : [{ position: 430, label: 'Effective avail Stock' }]
      Effective_avail_stock : abap.string;

      @EndUserText.label    : 'Stock Below Reorder Qty Level'
      @UI.lineItem          : [{ position: 440, label: 'Stock Below Reorder Qty Level' }]
      Stock_below           : abap.string;

      @EndUserText.label    : 'Minimum Po Qty'
      @UI.lineItem          : [{ position: 450, label: 'Minimum Po Qty' }]
      Minimum_po_qty        : abap.string;

      @EndUserText.label    : 'Open Po Qty'
      @UI.lineItem          : [{ position: 455, label: 'Open Po Qty' }]
      open_po_qty           : abap.string;

      @EndUserText.label    : 'AVG movement'
      @UI.lineItem          : [{ position: 460, label: 'AVG movement' }]
      AVG_movement          : abap.string;

      //      @EndUserText.label          : 'RM pur qty'
      //      @UI.lineItem    : [{ position: 470, label: 'RM pur qty' }]
      //      RM_pur_qty    : abap.string;
}
