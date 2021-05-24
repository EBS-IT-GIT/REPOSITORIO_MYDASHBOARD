-- Created on 20/03/2021 by ABNER 
declare
  -- Local variables here
  i     integer;
  r_row cll_f255_notifications%rowtype;
begin
  -- Test statements here
  FOR l_cll IN (  SELECT distinct a.INVOICE_PAYMENT_ID,
       a.INVOICE_ID,
       a.PAYMENT_NUM,
       A.ORG_ID,
       b.check_date

  FROM apps.ap_invoice_payments_all      a,
       apps.ap_checks_all                b,
       apps.ap_invoice_distributions_all c,
       apps.ap_invoices_all              d,
       apps.ap_check_formats             f,
       apps.ce_bank_accounts             g,
       apps.ce_bank_branches_v           e,
       apps.ap_suppliers                 p,
       apps.ap_selected_invoices_all     s,
       apps.ce_bank_acct_uses_all        u,
       apps.po_distributions_all         pda,
       apps.ap_terms                     apt,
       apps.ap_invoice_lines_all         aila,
       apps.ap_supplier_sites_all        assa
 WHERE b.check_id = a.check_id
   AND b.org_id = a.org_id
   AND d.invoice_id = a.invoice_id
   AND d.org_id = a.org_id
   AND c.invoice_id = d.invoice_id
   AND c.invoice_id = aila.invoice_id
   AND c.org_id = aila.org_id
   AND c.invoice_line_number = aila.line_number
   AND c.org_id = d.org_id
   AND (c.line_type_lookup_code IN
       ('ITEM',
         'ACCRUAL',
         'FREIGHT',
         'MISCELLANEOUS',
         'AWT',
         'RETAINAGE',
         'RETAINAGE RELEASE') OR
       (c.line_type_lookup_code IN ('MISCELLANEOUS') AND
       p.vendor_type_lookup_code IN ('TAX AUTHORITY')) OR
       (c.line_type_lookup_code IN ('MISCELLANEOUS') AND
       c.description NOT LIKE
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
   AND NVL(c.cancellation_flag, 'N') NOT IN ('S', 'Y')
   AND assa.vendor_id = p.vendor_id
   AND assa.vendor_site_id = b.vendor_site_id
   AND b.check_date between ('01/03/2021') and ('05/03/2021') 
   --AND ROWNUM = 1
) loop
    r_row := null ;
    r_row.notification_id  := apps.cll_f255_notifications_s.nextval;
    r_row.isv_name         := 'XRT';
    r_row.event_key        := 'carga.script.' || l_cll.invoice_payment_id || '.' ||
                              l_cll.invoice_id || '.' || l_cll.payment_num || '.' ||
                              l_cll.org_id || '.' ||
                              to_char(l_cll.check_date, 'DD-MON-RRRR') || '.sysdate=' || to_char(sysdate, 'DD-MON-RRRR hh:mi:ss');
    r_row.event_name       := 'oracle.apps.cll.ap_invoice_payments';
    r_row.transaction_type := 'UPDATE';
    r_row.creation_date    := sysdate;
    r_row.created_by       := -1;
    r_row.last_update_date := sysdate;
    r_row.export_status    := 1;
  
    r_row.PARAMETER_NAME1  := 'INVOICE_PAYMENT_ID';
    r_row.PARAMETER_VALUE1 := L_CLL.INVOICE_PAYMENT_ID;
  
    r_row.PARAMETER_NAME2  := 'INVOICE_ID';
    r_row.PARAMETER_VALUE2 := L_CLL.INVOICE_ID;
  
    r_row.PARAMETER_NAME3  := 'PAYMENT_NUM';
    r_row.PARAMETER_VALUE3 := L_CLL.PAYMENT_NUM;
  
    r_row.PARAMETER_NAME4  := 'ORG_ID';
    r_row.PARAMETER_VALUE4 := L_CLL.ORG_ID;
  
    INSERT INTO cll_f255_notifications VALUES r_row;
    commit;
    DBMS_LOCK.sleep(5);
  
  end loop;
end;
