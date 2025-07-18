@EndUserText.label: 'Projection view for Header table'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity zform_hdr_tab_p
  provider contract transactional_query
  as projection on zform_hdr_tab_i
{

      @UI.facet: [{
                 id: 'TemplateData',
                 purpose: #STANDARD,
                 label: 'Tamplate Data',
                 type: #IDENTIFICATION_REFERENCE,
                 position: 10
             },{
                 id: 'Upload',
                 purpose: #STANDARD,
                 label: 'Upload Attachments',
                 type: #LINEITEM_REFERENCE,
                 position: 20,
                 targetElement: '_Attachments'
             }]

      @UI: {
          selectionField: [{ position: 10 }],
          lineItem: [{ position: 10 }],
          identification: [{ position: 10 }]
      }
  key Id,
      @UI: {
            lineItem: [{position: 20 }],
            identification: [{position: 20 }]
            }
      TemplateName,
      @UI: {
      lineItem: [{position: 30 }],
      identification: [{position: 30 }]
      }
      Description,
      @UI: {
          lineItem: [{position: 40 }],
          identification: [{position: 40 }]
      }
      Lastchangedat,
      Locallastchangedat,
      _Attachments : redirected to composition child zform_att_tab_p
}
