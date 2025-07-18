@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'attachment table projection'
define view entity zform_att_tab_p
  as projection on zform_att_tab_i
{
      @UI.facet: [{
                  id: 'TemplateData',
                  purpose: #STANDARD,
                  label: 'Attachment Information',
                  type: #IDENTIFICATION_REFERENCE,
                  position: 10
              }]

      @UI: {
            lineItem: [{ position: 10 }],
            identification: [{ position: 10 }]
        }
  key TempId,
      @UI: {
          lineItem: [{ position: 20 }],
          identification: [{ position: 20 }]
        }
      Id,
      @UI: {
          lineItem: [{ position: 30 }],
          identification: [{ position: 30 }]
        }
      Description,
      @UI: {
         lineItem: [{ position: 40 }],
         identification: [{ position: 40 }]
       }
      Attachment,
      Mimetype,
      Filename,
      Lastchangedat,
      /* Associations */
      _Form : redirected to parent zform_hdr_tab_p // Make association public
}
