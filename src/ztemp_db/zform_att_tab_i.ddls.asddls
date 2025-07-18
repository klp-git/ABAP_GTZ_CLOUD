@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View Entity for attachment'
define view entity zform_att_tab_i
  as select from zform_att_tab
  association to parent zform_hdr_tab_i as _Form on $projection.Id = _Form.Id
{
  key temp_id             as TempId,
      id                  as Id,
      @EndUserText.label: 'Description'
      description         as Description,
      @EndUserText.label: 'Attachments'
      @Semantics.largeObject:{
          mimeType: 'Mimetype',
          fileName: 'Filename',
          contentDispositionPreference: #INLINE
      }
      attachment          as Attachment,
      @EndUserText.label: 'File Type'
      mimetype            as Mimetype,
      @EndUserText.label: 'File Name'
      filename            as Filename,

      _Form.Lastchangedat as Lastchangedat,
      _Form // Make association public
}
