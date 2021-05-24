--
-- 4 Regs
Update ap.ap_invoice_lines_all
   Set Line_Type_lookup_code = 'ITEM' --MISCELLANEOUS
 Where invoice_id in (12371,12429,12373,12374)
   And line_number = 3
/   
--
-- 4 Regs
Update AP.ap_invoice_distributions_all
   Set Line_Type_lookup_code = 'RETAINAGE' --MISCELLANEOUS
 Where invoice_id in (12371,12429,12373,12374)
   And invoice_line_number = 3
/
--
--17 regs
Update AP.ap_invoices_all
   set INVOICE_TYPE_LOOKUP_CODE = 'RETAINAGE RELEASE' --STANDARD
 Where INVOICE_ID IN (1234032,4195036,4264032,1373024,4368080,4378547,1294128,1294127,4367144,1204161,4294034,4229031,4364320,4368079,4226030,4378358,4367527)
/
--
--1 regs
Update AP.ap_invoice_distributions_all
   Set Line_Type_lookup_code = 'ITEM' --FREIGHT
 Where INVOICE_DISTRIBUTION_ID = 4483726
/
--
--1 regs
Update AP.ap_invoice_distributions_all
   Set Line_Type_lookup_code = 'RETAINAGE' --ITEM
 Where INVOICE_DISTRIBUTION_ID = 4773604
/
--
COMMIT
/
