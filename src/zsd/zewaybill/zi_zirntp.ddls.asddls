@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View forZIRN'
define root view entity ZI_ZIRNTP
  provider contract transactional_interface
  as projection on ZR_ZIRNTP as ZIRN
{
  key Bukrs,
  key Billingdocno,
      taxinvoiceno,
      Moduletype,
      Plant,
      Billingdate,
      Partycode,
      distributionchannel,
      distributionchanneldiscription,
      billingdocumenttype,
      Partyname,
      Irnno,
      Ackno,
      Ackdate,
      documentreferenceid,
      Irnstatus,
      Canceldate,
      Signedinvoice,
      Signedqrcode,
      Distance,
      Vehiclenum,
      Ewaybillno,
      Ewaydate,
      Ewaystatus,
      Ewaycanceldate,
      IRNCANCLEDATE,
      Ewayvaliddate,
      Transportername,
      Transportergstin,
      Grdate,
      Grno,
      Irncreatedby,
      Ewaycreatedby,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt

}
