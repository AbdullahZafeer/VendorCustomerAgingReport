@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor/Customer Aging - Data Model'
@Metadata.ignorePropagatedAnnotations: true


define view entity ZFI_VCAge_I
  with parameters
    @EndUserText.label: 'Evaluation Date'
    @Environment.systemField: #SYSTEM_DATE
    P_KeyDate : zzde_aging_keydate1,

    @EndUserText.label: 'Report Name'
    P_ReportType : zfi_de_rpttype

  as select from I_OperationalAcctgDocItem as Item

  association [0..1] to I_BusinessPartner as _Supplier
    on  Item.Supplier = _Supplier.BusinessPartner
  association [0..1] to I_BusinessPartner as _Customer
    on  Item.Customer = _Customer.BusinessPartner

  association [0..1] to I_JournalEntry as _JournalEntry
    on  Item.CompanyCode        = _JournalEntry.CompanyCode
    and Item.FiscalYear         = _JournalEntry.FiscalYear
    and Item.AccountingDocument = _JournalEntry.AccountingDocument

  association [0..1] to I_GLAccountText as _GLAccountText
    on  Item.GLAccount         = _GLAccountText.GLAccount
    and Item.ChartOfAccounts   = _GLAccountText.ChartOfAccounts
    and _GLAccountText.Language = $session.system_language

  association [0..1] to I_AccountingDocumentTypeText as _DocTypeText
    on  Item.AccountingDocumentType = _DocTypeText.AccountingDocumentType
    and _DocTypeText.Language         = $session.system_language

  association [0..1] to I_PurchaseOrderAPI01 as _PurchaseOrder
    on  Item.PurchasingDocument = _PurchaseOrder.PurchaseOrder
    
  association [0..1] to I_BillingDocument as _BillingDocument
    on Item.OriginalReferenceDocument = _BillingDocument.BillingDocument

{
  key Item.CompanyCode,
  key Item.FiscalYear,
  key Item.AccountingDocument,
  key Item.AccountingDocumentItem,

      case when Item.Supplier <> '' then cast('Vendor Aging Analysis' as abap.char(40))
           else cast('Customer Aging Analysis' as abap.char(40))
      end                                                   as ReportName,

      cast( case when Item.Supplier <> '' then Item.Supplier else Item.Customer end as abap.char(10) ) as AccountNumber,
      
      case when Item.Supplier <> '' then _Supplier.BusinessPartnerFullName
           else _Customer.BusinessPartnerFullName 
      end                                     as AccountName,
           
      case when Item.Supplier <> '' then _Supplier.BusinessPartnerGrouping
           else _Customer.BusinessPartnerGrouping 
      end                                     as AccountGroup,
           
      case when Item.Supplier <> '' then cast(Item.PurchasingDocument as abap.char(16))
           else cast(_BillingDocument.BillingDocument as abap.char(16)) end               as ReferenceDocument,
           
      case when Item.Supplier <> '' then _PurchaseOrder.PurchaseOrderDate
           else _BillingDocument.BillingDocumentDate end                                  as ReferenceDocumentDate,

      Item.GLAccount                                        as ReconciliationAccount,
      _GLAccountText.GLAccountName                          as ReconciliationAccountName,

      _JournalEntry.PostingDate,
      _JournalEntry.DocumentDate,
      Item.NetDueDate                                       as DueDate,

      case when Item.Supplier <> '' then _JournalEntry.DocumentReferenceID
           else cast('' as abap.char(16)) end               as AssignmentReference,

      _JournalEntry.AccountingDocument                      as DocumentNumber,
      Item.AccountingDocumentType                           as DocumentType,
      _DocTypeText.AccountingDocumentTypeName               as DocumentTypeName,

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      Item.AmountInCompanyCodeCurrency                      as Amount,
      Item.CompanyCodeCurrency,
      
      $parameters.P_KeyDate                                 as EvaluationDate,
      
      

      case when Item.NetDueDate <> '00000000'
           then dats_days_between( Item.NetDueDate, $parameters.P_KeyDate )
           else 0
      end                                                   as OverdueDays
}
/* MODIFIED: Bulletproof SAP Open Item Logic */
//where ( 
//        ( $parameters.P_ReportType = 'V' and Item.Supplier <> '' and ( Item.AccountingDocumentType = 'KR' or Item.AccountingDocumentType = 'RE' ) )
//     or ( $parameters.P_ReportType = 'C' and Item.Customer <> '' and ( Item.AccountingDocumentType = 'DR' or Item.AccountingDocumentType = 'RV' ) )
//      )
//  and Item.IsOpenItemManaged = 'X'
//  and _JournalEntry.PostingDate <= $parameters.P_KeyDate
//  and ( Item.ClearingAccountingDocument is initial or Item.ClearingAccountingDocument = '' or Item.ClearingDate > $parameters.P_KeyDate )
/* THE ULTIMATE BULLETPROOF SAP AP/AR LOGIC */
where ( 
        ( $parameters.P_ReportType = 'V' and Item.FinancialAccountType = 'K' and ( Item.AccountingDocumentType = 'KR' or Item.AccountingDocumentType = 'RE' ) )
     or ( $parameters.P_ReportType = 'C' and Item.FinancialAccountType = 'D' and ( Item.AccountingDocumentType = 'DR' or Item.AccountingDocumentType = 'RV' ) )
      )
  and Item.IsOpenItemManaged = 'X'
  and _JournalEntry.PostingDate <= $parameters.P_KeyDate
  and ( Item.ClearingJournalEntry is initial or Item.ClearingJournalEntry = '' or Item.ClearingDate > $parameters.P_KeyDate )
