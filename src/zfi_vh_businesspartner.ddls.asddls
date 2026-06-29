@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help: Vendor/Customer'

define view entity ZFI_VH_BusinessPartner
  as select from I_BusinessPartner as BP
  
 
    inner join I_OperationalAcctgDocItem as Item 
      on  BP.BusinessPartner = Item.Supplier 
       or BP.BusinessPartner = Item.Customer
{
      @EndUserText.label: 'Vendor/Customer Number'
      @UI.lineItem: [{ position: 10 }]
      key cast(BP.BusinessPartner as abap.char(10)) as BusinessPartner,
      @EndUserText.label: 'Name'
      @UI.lineItem: [{ position: 20 }]
      BP.BusinessPartnerName,

      @EndUserText.label: 'Full Name'
      @UI.lineItem: [{ position: 30 }]
      BP.BusinessPartnerFullName
}
group by 
  BP.BusinessPartner,
  BP.BusinessPartnerName,
  BP.BusinessPartnerFullName
