CREATE OR REPLACE VIEW BOLINF.XXAR0024_VIEWA AS 
SELECT REPLACE(hou.name, '_UO', '')                                     org
--
-- $Header: XXAR0024_VIEWA.vw 120.4 18/11/2019 09:26:26 appldev ship $
-- +==================================================================+
-- |                            HQS Plus                              |
-- |                       All rights reserved.                       |
-- +==================================================================+
-- | FILENAME                                                         |
-- |   XXAR0024_VIEWA.vw                                              |
-- |                                                                  |
-- | PURPOSE                                                          |
-- |   XXAR0024_VIEWA                                                 |
-- |                                                                  |
-- | DESCRIPTION                                                      |
-- |   View XXAR0024_VIEWA                                            |
-- |                                                                  |
-- | PARAMETERS                                                       |
-- |                                                                  |
-- | CREATED BY                                                       |
-- |  Renan Camarota    16/12/2016                                    |
-- |                                                                  |
-- | UPDATED BY                                                       |
-- |  #120.2 Joao Adami             03/02/2017                        |
-- |  #120.3 Mariana Resende        18/11/2019                        |
-- |  #120.4 Ivam Cardoso           07/04/2020                        |
-- |                                                                  |
-- +==================================================================+
--
      ,hp.party_name                                                    cliente
      ,hp.party_id
      ,SUBSTR(hcs.global_attribute3, 1, 3) || '.' ||
       SUBSTR(hcs.global_attribute3, 4, 3) || '.' ||
       SUBSTR(hcs.global_attribute3, 7, 3)                              cnpj
      ,hcs.global_attribute4 || '-' || hcs.global_attribute5            local
      ,aps.trx_number                                                   numero_nf_transacao
      ,aps.trx_date                                                     data_emissao_nf
      ,(SELECT SUM(apsx.amount_line_items_original)
          FROM ar.ar_payment_schedules_all apsx
         WHERE apsx.customer_trx_id = aps.customer_trx_id)              valor_nf
      ,aps.number_of_due_dates                                          numero_parcela
      ,aps.terms_sequence_number                                        parcela_paga
      ,aps.amount_due_original                                          vlr_original_parcela
      ,aps.amount_applied                                               valor_aplicado_parcela
      ,aps.amount_due_remaining                                         valor_restante_parcela
      ,DECODE(aps.status, 'CL', 'Fechado', 'OP', 'Aberto', 'aps.statu') Status_Parcela
      ,aps.amount_adjusted                                              vlr_ajuste
      ,acra.amount                                                      valor_rececebimento
      ,araa.amount_applied                                              valor_aplicado
      ,acra.amount - araa.amount_applied                                saldo_recebimento
      ,acra.receipt_number                                              numero_recebimento
      ,acra.receipt_date                                                data_recebimento
      ,araa.gl_date                                                     data_contabil
      ,DECODE(NVL(hca.customer_class_code, 'N'), 'N', 'N', 'S')         orgaos_publicos
      ,glc.segment1                                                     empresa_contabil
      ,glc.segment2                                                     centro_custo
      ,glc.segment3                                                     conta_contabil
      ,glc.segment4                                                     programa
      ,arm.name                                                         metodo_recebimento
      ,DECODE(acra.status, 'APP', 'APLICADO')                           status
      ,aps.due_date                                                     data_vencimento --#120.3
  FROM apps.ar_receivable_applications_all araa
      ,hr_operating_units                  hou
      ,apps.ar_cash_receipts_all           acra
      ,apps.hz_cust_accounts               hca
      ,apps.hz_cust_site_uses_all          hcsua
      ,apps.hz_cust_acct_sites_all         hcs
      ,apps.hz_parties                     hp
      ,apps.ar_receipt_methods             arm
      ,apps.ar_payment_schedules_all       aps
      ,apps.gl_code_combinations           glc
 WHERE araa.line_applied > '0'
   AND araa.status                 = 'APP'
   AND araa.display                = 'Y'
--   And araa.gl_date               >= < 'dd-mmm-yyyy'>
--   And araa.gl_date               <= < 'dd-mmm-yyyy'>
   AND hou.organization_id         = acra.org_id
   AND hou.date_from              <= SYSDATE
   AND nvl(hou.date_to, SYSDATE)  >= SYSDATE
   AND acra.cash_receipt_id       = araa.cash_receipt_id(+)
 --AND acra.status                = 'APP'   --#120.4
   AND hca.cust_account_id        = acra.pay_from_customer
   AND hp.party_id                = hca.party_id
   AND hcsua.site_use_id          = acra.customer_site_use_id
   AND hcs.cust_acct_site_id      = hcsua.cust_acct_site_id
   AND hcs.org_id                 = hcsua.org_id
   AND arm.receipt_method_id      = acra.receipt_method_id
   AND aps.payment_schedule_id(+) = araa.applied_payment_schedule_id
   AND glc.code_combination_id    = araa.code_combination_id
 ORDER BY hp.party_name                   --#120.3
         ,acra.cash_receipt_id            --#120.3
         ,araa.receivable_application_id  --#120.3
         ,acra.receipt_date
         ,acra.amount
-- Indicativo de final de arquivo. Nao deve ser removido.
/
