@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forZIRN'
define root view entity ZR_ZIRNTP
  as select from ztable_irn as ZIRN 
  left outer join I_BillingDocument as b on ZIRN.billingdocno = b.BillingDocument
{
  key ZIRN.bukrs                          as Bukrs,
      @EndUserText.label: 'Bill  No'
  key ZIRN.billingdocno                   as Billingdocno,
      ZIRN.taxinvoiceno as taxinvoiceno,
      ZIRN.moduletype                     as Moduletype,
      ZIRN.plant                          as Plant,
      @EndUserText.label: 'Document Date'
      ZIRN.billingdate                    as Billingdate,
      ZIRN.partycode                      as Partycode,
      @EndUserText.label: 'Distribution Channel'
      ZIRN.distributionchannel            as distributionchannel,
      ZIRN.distributionchanneldiscription as distributionchanneldiscription,
      ZIRN.billingdocumenttype            as billingdocumenttype,
      ZIRN.partyname                      as Partyname,
      ZIRN.irnno                          as Irnno,
      ZIRN.ackno                          as Ackno,
      ZIRN.ackdate                        as Ackdate,
      ZIRN.documentreferenceid            as documentreferenceid,
      ZIRN.irnstatus                      as Irnstatus,
      ZIRN.canceldate                     as Canceldate,
      ZIRN.signedinvoice                  as Signedinvoice,
      ZIRN.signedqrcode                   as Signedqrcode,
      ZIRN.distance                       as Distance,
      ZIRN.vehiclenum                     as Vehiclenum,
      ZIRN.ewaybillno                     as Ewaybillno,
      ZIRN.ewaydate                       as Ewaydate,
      ZIRN.ewaystatus                     as Ewaystatus,
      ZIRN.ewaycanceldate                 as Ewaycanceldate,
      ZIRN.ewayvaliddate                  as Ewayvaliddate,
      ZIRN.transportername                as Transportername,
      ZIRN.transportergstin               as Transportergstin,
      ZIRN.grdate                         as Grdate,
      ZIRN.grno                           as Grno,
      ZIRN.irncancledate                  as IRNCANCLEDATE,
      @Semantics.user.createdBy: true
      ZIRN.irncreatedby                   as Irncreatedby,
      ZIRN.ewaycreatedby                  as Ewaycreatedby,
      ZIRN.created_by                     as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      ZIRN.created_at                     as CreatedAt,
      ZIRN.last_changed_by                as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      ZIRN.last_changed_at                as LastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      ZIRN.local_last_changed_at          as LocalLastChangedAt

}
where b.BillingDocumentType <> 'S1' and b.BillingDocumentIsCancelled <> 'X'
