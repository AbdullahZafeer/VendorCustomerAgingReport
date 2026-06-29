@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Report Name'
@ObjectModel.resultSet.sizeCategory: #XS  // <--- This is the magic word for "Dropdown"
@Metadata.ignorePropagatedAnnotations: true

define view entity ZFI_VH_ReportName
  as select from I_Language
{
  @ObjectModel.text.element: ['ReportName'] // <--- Tells Fiori to show the text, not the V/C key
  key cast('V' as zfi_de_rpttype) as ReportKey,
  
  @Semantics.text: true
  @EndUserText.label: 'Report Name'
  cast('Vendor Aging Analysis' as abap.char(40)) as ReportName
}
where
  Language = $session.system_language

union all

select from I_Language
{
  key cast('C' as zfi_de_rpttype) as ReportKey,
  cast('Customer Aging Analysis' as abap.char(40)) as ReportName
}
where
  Language = $session.system_language
