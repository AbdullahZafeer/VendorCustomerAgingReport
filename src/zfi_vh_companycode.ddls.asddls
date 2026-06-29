@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help: Company Code Dropdown'
@ObjectModel.resultSet.sizeCategory: #XS 

define view entity ZFI_VH_CompanyCode
  as select from I_CompanyCode
{
      @ObjectModel.text.element: ['CompanyCodeName']
  key CompanyCode,
      CompanyCodeName
}
