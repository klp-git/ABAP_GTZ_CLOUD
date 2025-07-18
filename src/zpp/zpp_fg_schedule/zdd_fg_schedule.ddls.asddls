@EndUserText.label: 'Fg Dispatch Schedule'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_PP_FG_SCHEDULE'
@UI.headerInfo: { typeName: 'Planning',
typeNamePlural:'Planning' }

define custom entity ZDD_FG_SCHEDULE
{
      @EndUserText.label          : 'Material'
      @UI.lineItem  : [{ position: 10, label: 'Material' }]
      @UI.selectionField          : [{ position: 10 }]
      //      @Consumption.valueHelpDefinition: [{ entity : { name : 'zdd_mat_vh',element : 'product' } } ]
  key item_code : abap.char(40);

      @EndUserText.label          : 'Material Name'
      @UI.lineItem  : [{ position: 20, label: 'Material Name' }]
      @UI.selectionField          : [{ position: 20 }]
      item_name : abap.char(80);

      @EndUserText.label          : 'Msq'
      @UI.lineItem  : [{ position: 30, label: 'Msq' }]
      @UI.selectionField          : [{ position: 30 }]
      msq       : abap.string;

      @EndUserText.label          : 'Csq'
      @UI.lineItem  : [{ position: 40, label: 'Csq' }]
      @UI.selectionField          : [{ position: 40 }]
      csq       : abap.string;

      @EndUserText.label          : 'Pwoq'
      @UI.lineItem  : [{ position: 50, label: 'Pwoq' }]
      @UI.selectionField          : [{ position: 50 }]
      pwoq      : abap.string;

      @UI.selectionField          : [{exclude: true}]
      @UI.lineItem  : [{ position: 60, label: 'Sob' }]
      @UI.selectionField          : [{ position: 60 }]
      sob       : abap.string;

      @EndUserText.label          : 'Day 1'
      @UI.lineItem               : [{ position: 70, label: 'Day 1' }]
      Day1      : abap.string;

      @EndUserText.label          : 'Day 2'
      @UI.lineItem               : [{ position: 80, label: 'Day 2' }]
      Day2      : abap.string;

      @EndUserText.label          : 'Day 3'
      @UI.lineItem               : [{ position: 90, label: 'Day 3' }]
      Day3      : abap.string;

      @EndUserText.label          : 'Day 4'
      @UI.lineItem               : [{ position: 100, label: 'Day 4' }]
      Day4      : abap.string;

      @EndUserText.label          : 'Day 5'
      @UI.lineItem               : [{ position: 110, label: 'Day 5' }]
      Day5      : abap.string;

      @EndUserText.label          : 'Day 6'
      @UI.lineItem               : [{ position: 120, label: 'Day 6' }]
      Day6      : abap.string;

      @EndUserText.label          : 'Day 7'
      @UI.lineItem               : [{ position: 130, label: 'Day 7' }]
      Day7      : abap.string;

      @EndUserText.label          : 'Day 8'
      @UI.lineItem               : [{ position: 140, label: 'Day 8' }]
      Day8      : abap.string;

      @EndUserText.label          : 'Day 9'
      @UI.lineItem               : [{ position: 150, label: 'Day 9' }]
      Day9      : abap.string;

      @EndUserText.label          : 'Day 10'
      @UI.lineItem               : [{ position: 160, label: 'Day 10' }]
      Day10     : abap.string;

      @EndUserText.label          : 'Day 11'
      @UI.lineItem               : [{ position: 170, label: 'Day 11' }]
      Day11     : abap.string;

      @EndUserText.label          : 'Day 12'
      @UI.lineItem               : [{ position: 180, label: 'Day 12' }]
      Day12     : abap.string;

      @EndUserText.label          : 'Day 13'
      @UI.lineItem               : [{ position: 190, label: 'Day 13' }]
      Day13     : abap.string;

      @EndUserText.label          : 'Day 14'
      @UI.lineItem               : [{ position: 200, label: 'Day 14' }]
      Day14     : abap.string;

      @EndUserText.label          : 'Day 15'
      @UI.lineItem               : [{ position: 210, label: 'Day 15' }]
      Day15     : abap.string;

      @EndUserText.label          : 'Day 16'
      @UI.lineItem               : [{ position: 220, label: 'Day 16' }]
      Day16     : abap.string;

      @EndUserText.label          : 'Day 17'
      @UI.lineItem               : [{ position: 230, label: 'Day 17' }]
      Day17     : abap.string;

      @EndUserText.label          : 'Day 18'
      @UI.lineItem               : [{ position: 240, label: 'Day 18' }]
      Day18     : abap.string;

      @EndUserText.label          : 'Day 19'
      @UI.lineItem               : [{ position: 250, label: 'Day 19' }]
      Day19     : abap.string;

      @EndUserText.label          : 'Day 20'
      @UI.lineItem               : [{ position: 260, label: 'Day 20' }]
      Day20     : abap.string;

      @EndUserText.label          : 'Day 21'
      @UI.lineItem               : [{ position: 270, label: 'Day 21' }]
      Day21     : abap.string;

      @EndUserText.label          : 'Day 22'
      @UI.lineItem               : [{ position: 280, label: 'Day 22' }]
      Day22     : abap.string;

      @EndUserText.label          : 'Day 23'
      @UI.lineItem               : [{ position: 290, label: 'Day 23' }]
      Day23     : abap.string;

      @EndUserText.label          : 'Day 24'
      @UI.lineItem               : [{ position: 300, label: 'Day 24' }]
      Day24     : abap.string;

      @EndUserText.label          : 'Day 25'
      @UI.lineItem               : [{ position: 310, label: 'Day 25' }]
      Day25     : abap.string;

      @EndUserText.label          : 'Day 26'
      @UI.lineItem               : [{ position: 320, label: 'Day 26' }]
      Day26     : abap.string;

      @EndUserText.label          : 'Day 27'
      @UI.lineItem               : [{ position: 330, label: 'Day 27' }]
      Day27     : abap.string;

      @EndUserText.label          : 'Day 28'
      @UI.lineItem               : [{ position: 340, label: 'Day 28' }]
      Day28     : abap.string;

      @EndUserText.label          : 'Day 29'
      @UI.lineItem               : [{ position: 350, label: 'Day 29' }]
      Day29     : abap.string;

      @EndUserText.label          : 'Day 30'
      @UI.lineItem               : [{ position: 360, label: 'Day 30' }]
      Day30     : abap.string;

      @EndUserText.label          : 'Total'
      @UI.lineItem  : [{ position: 370, label: 'Total' }]
      total     : abap.string;

      @EndUserText.label          : 'Scb'
      @UI.lineItem  : [{ position: 380, label: 'Scb' }]
      scb       : abap.string;
}
