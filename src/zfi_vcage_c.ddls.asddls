@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor/Customer Aging Analysis'
@Metadata.allowExtensions: true
@Search.searchable: true

define view entity ZFI_VCAge_C
  with parameters
    @EndUserText.label: 'Evaluation Date'
//    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CalendarDate', element: 'CalendarDate' } }]
    @Consumption.derivation: {
      lookupEntity: 'I_CalendarDate',
      resultElement: 'CalendarDate',
      binding: [{ 
        targetElement: 'CalendarDate', 
        type: #SYSTEM_FIELD, 
        value: '#SYSTEM_DATE' 
      }]
    }
    @Environment.systemField: #SYSTEM_DATE
    P_KeyDate : zzde_aging_keydate1,

    @EndUserText.label: 'Report Name'
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZFI_VH_ReportName', element: 'ReportKey' } }]
    P_ReportType : zfi_de_rpttype

  as select from ZFI_VCAge_I( P_KeyDate: $parameters.P_KeyDate, P_ReportType: $parameters.P_ReportType ) as Aging
{
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZFI_VH_CompanyCode', element: 'CompanyCode' } }]
  key Aging.CompanyCode,
  key Aging.FiscalYear,
  key Aging.AccountingDocument,
  key Aging.AccountingDocumentItem,

      Aging.ReportName,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZFI_VH_BusinessPartner', element: 'BusinessPartner' } }]
//      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_BusinessPartner', element: 'BusinessPartner' } }] 
      Aging.AccountNumber,
      Aging.AccountName,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_BusinessPartnerGrouping', element: 'BusinessPartnerGrouping' } }]
      Aging.AccountGroup,
      Aging.ReferenceDocument,
      Aging.ReferenceDocumentDate,
    
      Aging.ReconciliationAccount,
      Aging.ReconciliationAccountName,
      Aging.PostingDate,
      Aging.DocumentDate,
      Aging.DueDate,
      Aging.AssignmentReference,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.6
      Aging.DocumentNumber,
      Aging.DocumentType,
      Aging.DocumentTypeName,
      
      Aging.EvaluationDate,
      
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      @DefaultAggregation: #SUM
      Aging.Amount,

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      @DefaultAggregation: #SUM
      case when Aging.OverdueDays < 1                  then cast(Aging.Amount as abap.dec(23,2)) else 0 end  as NotDue,
      
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      @DefaultAggregation: #SUM
      case when Aging.OverdueDays between 1   and 29   then cast(Aging.Amount as abap.dec(23,2)) else 0 end  as Days01To29,
      
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      @DefaultAggregation: #SUM
      case when Aging.OverdueDays between 30  and 45   then cast(Aging.Amount as abap.dec(23,2)) else 0 end  as Days30To45,
      
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      @DefaultAggregation: #SUM
      case when Aging.OverdueDays between 46  and 60   then cast(Aging.Amount as abap.dec(23,2)) else 0 end  as Days46To60,
      
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      @DefaultAggregation: #SUM
      case when Aging.OverdueDays between 61  and 90   then cast(Aging.Amount as abap.dec(23,2)) else 0 end  as Days61To90,
      
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      @DefaultAggregation: #SUM
      case when Aging.OverdueDays between 91  and 120  then cast(Aging.Amount as abap.dec(23,2)) else 0 end  as Days91To120,
      
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      @DefaultAggregation: #SUM
      case when Aging.OverdueDays between 121 and 180  then cast(Aging.Amount as abap.dec(23,2)) else 0 end  as Days121To180,
      
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      @DefaultAggregation: #SUM
      case when Aging.OverdueDays between 181 and 365  then cast(Aging.Amount as abap.dec(23,2)) else 0 end  as Days181To365,
      
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      @DefaultAggregation: #SUM
      case when Aging.OverdueDays > 365                then cast(Aging.Amount as abap.dec(23,2)) else 0 end  as DaysOver365,

      Aging.CompanyCodeCurrency
}
