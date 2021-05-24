CREATE OR REPLACE VIEW XXISV_XRT_AP_REAL_V AS
SELECT DISTINCT
           a.invoice_payment_id AS invoice_payment_id,
           d.invoice_id AS invoice_id,
           TRIM (SUBSTR (p.vendor_name, 1, 55)) AS pfj_nome,

           TRIM (SUBSTR (assa.address_line1, 1, 70)) AS pfj_endereco,
           TRIM (SUBSTR (assa.address_line3, 1, 15)) AS pfj_numero,
           TRIM (SUBSTR (assa.zip, 1, 9)) AS pfj_cep,
           TRIM (SUBSTR (assa.address_line2, 1, 80)) AS pfj_complemento,
           TRIM (
               SUBSTR (
                      assa.global_attribute10
                   || assa.global_attribute11
                   || assa.global_attribute12,
                   1,
                   19))
               AS pfj_cpf,
           TRIM (SUBSTR (assa.state, 1, 2)) AS pfj_uf,
           TRIM (SUBSTR (b.vendor_site_id, 1, 255)) AS pfj_descricao,
           TRIM (SUBSTR (assa.city, 1, 40)) AS pfj_cidade,
           '4' AS pfj_tipo,
           e.bank_number AS ban_codigo,
           e.branch_number AS age_codigo,
           g.bank_account_num AS cnt_codigo,
           b.payment_method_code AS tdp_codigo,
           b.check_number AS doc_pagador,
           NVL ( (SELECT gcc.segment1
                    FROM apps.gl_code_combinations gcc
                   WHERE gcc.code_combination_id = pda.code_combination_id),
                '01')
               AS pfj_codigo,
           SUBSTR (b.vendor_id, 1, 20) AS pfj_emitente,
          --- SUBSTR (f.name, 1, 12) AS tdo_codigo,
          SUBSTR (INVOICE_TYPE_LOOKUP_CODE, 1, 12)  AS tdo_codigo,
           b.currency_code AS ind_codigo_real,
           d.invoice_amount AS valor_original,
           --c.amount AS valor_original,
           SUBSTR (d.invoice_num, 1, 15) AS doc_origem,
           b.checkrun_name || ' PGTO_ID#' || b.checkrun_id AS historico,
           DECODE (a.reversal_flag, 'Y', b.void_date, NULL)
               AS data_efetivacao,
           '-1' AS temperatura,
           'AP' AS origem_sistema,
              'INVOICE_PAYMENT_ID#'
           || a.invoice_payment_id
           || 'DISTRIB#'
           || c.invoice_distribution_id
           || 'PARCELA#'
           || a.payment_num
               AS origem_pk,
           NVL (a.exchange_rate, 1) AS taxa_conversao_corr,
           xxisv.xrt_utils_pkg.get_concat_segments (
               (NVL (
                    (SELECT code_combination_id
                       FROM po_distributions_all
                      WHERE po_distribution_id =
                                (SELECT apv.po_distribution_id
                                   FROM xxisv.xxisv_xrt_ap_contas_pagar_v apv
                                  WHERE     apv.invoice_id = a.invoice_id
                                        AND apv.po_distribution_id =
                                                c.po_distribution_id
                                        AND ROWNUM = 1)),
                    NVL (xxisv.xxisv_xrt_distrib (a.invoice_id),
                         c.dist_code_combination_id))),
               d.set_of_books_id) || '..'
               AS informacoes_contabeis,
           SUBSTR (
                  p.vendor_name
               || ' PARCELA#'
               || a.payment_num
               || ' '
               || apt.name
               || ' '
               || d.description,
               1,
               480)
               AS finalidade,
           NVL (d.terms_date, d.invoice_date) AS data_competencia,
           d.payment_currency_code AS ind_codigo_ccc,
           b.check_date AS data_pagamento,
           d.invoice_type_lookup_code || '#UA#' AS controle_interno,
           'ITF_AP_REAL' AS origem_processo,
           c.dist_code_combination_id AS dff_01,
           a.set_of_books_id AS dff_02,
           s.original_invoice_id AS dff_03,
           NVL (
               (SELECT dff_04
                  FROM xxisv.xxisv_xrt_ap_real_v3
                 WHERE     invoice_payment_id = a.invoice_payment_id
                       AND dff_04 IS NOT NULL
                       AND dff_05 IS NOT NULL
                       AND ROWNUM = 1),
               d.source || '#' || c.po_distribution_id)
               AS dff_04,
           NVL (
               (SELECT    gcc.segment1
                       || '.'
                       || gcc.segment2
                       || '.'
                       || gcc.segment3
                       || '.'
                       || gcc.segment4
                       || '.'
                       || gcc.segment5
                       || '.'
                       || gcc.segment6
                       || '.'
                       || gcc.segment7
                  FROM apps.gl_code_combinations gcc
                 WHERE gcc.code_combination_id = pda.code_combination_id),
               (SELECT dff_05
                  FROM xxisv.xxisv_xrt_ap_real_v3
                 WHERE     invoice_payment_id = a.invoice_payment_id
                       AND dff_05 IS NOT NULL
                       AND ROWNUM = 1))
               AS dff_05,
           --a.amount AS valor_parcela,
         --  c.amount AS valor_parcela,
         case
           when  instr((xxisv.xxisv_xrt_ap_item (
                a.invoice_payment_id,
                (   'INVOICE_PAYMENT_ID#'
                 || a.invoice_payment_id
                 || 'DISTRIB#'
                 || c.invoice_distribution_id
                 || 'PARCELA#'
                 || a.payment_num))),'-' )>= 1 then -c.amount else  c.amount end

           /*(xxisv.xxisv_xrt_ap_item (
                a.invoice_payment_id,
                (   'INVOICE_PAYMENT_ID#'
                 || a.invoice_payment_id
                 || 'DISTRIB#'
                 || c.invoice_distribution_id
                 || 'PARCELA#'
                 || a.payment_num)))  */


                  as valor_parcela ,
           (xxisv.xxisv_xrt_ap_item (
                a.invoice_payment_id,
                (   'INVOICE_PAYMENT_ID#'
                 || a.invoice_payment_id
                 || 'DISTRIB#'
                 || c.invoice_distribution_id
                 || 'PARCELA#'
                 || a.payment_num)))
               AS valor_item,
              'Banco: '
           || e.bank_name
           || ' Agencia: '
           || e.bank_branch_name
           || ' c/c: '
           || g.bank_account_num
               AS informacoes_bancarias,
           b.checkrun_id || '#' || b.checkrun_name AS informacoes_bene_reme,
           p.vendor_type_lookup_code AS att_str1,
           a.remit_to_supplier_name AS att_str2,
           c.line_type_lookup_code AS att_str3,
           d.invoice_type_lookup_code AS att_str4,
           a.reversal_inv_pmt_id AS att_str5,
           aila.attribute_category || '#' || aila.attribute1 AS att_str6,
           DECODE (a.reversal_flag, 'Y', b.status_lookup_code, NULL)
               AS att_str7,
           NVL (d.attribute5, NVL (d.attribute10, NVL (d.source, 'X')))
               AS att_str8,
           d.goods_received_date AS att_dt1,
           (SELECT NVL (po_header_id, 0)
              FROM ap_invoice_lines_all
             WHERE invoice_id = d.invoice_id AND ROWNUM = 1)
               AS att_num2,
           a.last_update_date AS last_update_date
      FROM apps.ap_invoice_payments_all a,
           apps.ap_checks_all b,
           apps.ap_invoice_distributions_all c,
           apps.ap_invoices_all d,
           apps.ap_check_formats f,
           apps.ce_bank_accounts g,
           apps.ce_bank_branches_v e,
           apps.ap_suppliers p,
           apps.ap_selected_invoices_all s,
           apps.ce_bank_acct_uses_all u,
           apps.po_distributions_all pda,
           apps.ap_terms apt,
           apps.ap_invoice_lines_all aila,
           apps.ap_supplier_sites_all assa
     WHERE     b.check_id = a.check_id
           AND b.org_id = a.org_id
           AND d.invoice_id = a.invoice_id
           AND d.org_id = a.org_id
           AND c.invoice_id = d.invoice_id
           AND c.invoice_id = aila.invoice_id
           AND c.org_id = aila.org_id
           AND c.invoice_line_number = aila.line_number
           AND c.org_id = d.org_id
           AND (   c.line_type_lookup_code IN ('ITEM',
                                               'ACCRUAL',
                                               'FREIGHT',
                                               'MISCELLANEOUS',
                                               'AWT',
                                               'RETAINAGE',
                                               'RETAINAGE RELEASE')
                OR (    c.line_type_lookup_code IN ('MISCELLANEOUS')
                    AND p.vendor_type_lookup_code IN ('TAX AUTHORITY'))
                OR (    c.line_type_lookup_code IN ('MISCELLANEOUS')
                    AND c.description NOT LIKE
                            ('DIFEREN%Imposto%Servi%Outras%Despesas%Importar')))
           AND s.invoice_id(+) = a.invoice_id
           AND s.payment_num(+) = a.payment_num
           AND f.check_format_id(+) = b.check_format_id
           AND b.ce_bank_acct_use_id = u.bank_acct_use_id
           AND u.bank_account_id = g.bank_account_id
           AND g.bank_branch_id = e.branch_party_id
           AND b.vendor_id = p.vendor_id
           AND c.po_distribution_id = pda.po_distribution_id(+)
           AND d.terms_id = apt.term_id
           AND NVL (c.cancellation_flag, 'N') NOT IN ('S', 'Y')
           AND assa.vendor_id = p.vendor_id
           AND assa.vendor_site_id = b.vendor_site_id
;
