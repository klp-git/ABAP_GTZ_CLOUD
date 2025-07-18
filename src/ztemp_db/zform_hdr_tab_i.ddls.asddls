@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'header table interface view entity'
define root view entity zform_hdr_tab_i
  as select from ZFORM_HDR_TAB
  composition [1..*] of zform_att_tab_i as _Attachments
{
      @EndUserText.label: 'Template ID'
  key id                 as Id,
      @EndUserText.label: 'Template Name'
      template_name      as TemplateName,
      @EndUserText.label: 'Description'
      description        as Description,
      lastchangedat      as Lastchangedat,
      locallastchangedat as Locallastchangedat,
      _Attachments // Make association public
}
