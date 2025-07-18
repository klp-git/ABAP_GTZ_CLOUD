//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@EndUserText.label: 'projection view for quality inspection'
//@Metadata.ignorePropagatedAnnotations: true

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Projection view for Quality Inspection'


@UI.headerInfo:{

  typeName: 'Inspectation',

  typeNamePlural: 'Inspectation',

  typeImageUrl: 'sap-icon://inspectation',

  title: {

    type: #STANDARD,

    value: 'Materiala'

  },

  description.value: 'Materiala'

}

define root view entity zprjv_upload_insp
  provider contract transactional_query
  as projection on zi_upload_insp
{

      @UI.facet: [{ id: 'PurchaseOrders',

              purpose: #STANDARD,

              type: #IDENTIFICATION_REFERENCE,

              label: 'Purchase Orders',

              position: 10

            },{

              id:'log',position:20,

              type: #FIELDGROUP_REFERENCE,

              targetQualifier: 'ChangeLog',

              label:'Change Log'

            }]

      @UI: { lineItem: [{ position: 10 }],

      identification: [{ position: 10 }],

      selectionField: [{ position: 10 }] }

  key Materiala    as Materiala,

      @UI: { lineItem: [{ position: 20 }],

          identification: [{ position: 20 }],

          selectionField: [{ position: 20 }] }

  key Materialb    as Materialb,

      @UI: { lineItem: [{ position: 30 }],

          identification: [{ position: 30 }]}

      Movementype  as Movementype,

      @UI: { lineItem: [{ position: 40 }],

         identification: [{ position: 40 }]}

      Vendor       as Vendor,

      @UI: { lineItem: [{ position: 50 }],

         identification: [{ position: 50 }]}

      Poref        as Poref,

      @UI: { lineItem: [{ position: 60 }],

         identification: [{ position: 60 }]}

      Plant        as Plant,

      @UI: { lineItem: [{ position: 70 }],

         identification: [{ position: 70 }]}

      Storageloc   as Storageloc,

      @UI: { lineItem: [{ position: 80 }],

         identification: [{ position: 80 }]}

      Trpoststatus as Trpoststatus,

      @UI.fieldGroup: [{ qualifier: 'ChangeLog', position: 10 }]

      CreatedBy,

      @UI.fieldGroup: [{ qualifier: 'ChangeLog', position: 20 }]

      CreatedAt,

      @UI.fieldGroup: [{ qualifier: 'ChangeLog', position: 30 }]

      LastChangedBy,

      @UI.fieldGroup: [{ qualifier: 'ChangeLog', position: 40 }]

      LastChangedAt,



      @UI.hidden: true

      ExcelRowNumber

}
