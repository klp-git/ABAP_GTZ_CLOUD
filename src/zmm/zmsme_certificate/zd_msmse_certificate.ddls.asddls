@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Data defination of msme certificate'
define root view entity ZD_MSMSE_CERTIFICATE
  as select from zmsme_table
{
  key vendorno         as VendorNo,
      vendortype       as VendorType,
      certificateno    as CertificateNo,
      validfrom        as ValidFrom,
      validto          as ValidTo,
      registrationcity as RegistrationCity,
      creationdate     as Creationdate,
      case when status = 'X' then
      'Active' else 'Non-Active' end  as status
}
