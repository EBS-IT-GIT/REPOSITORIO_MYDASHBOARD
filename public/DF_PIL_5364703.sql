set define off;
update ap_invoice_distributions_all aid
set charge_applicable_to_dist_id = null
where aid.invoice_id = 5364703
and aid.invoice_distribution_id IN (95156560,95156561);
--1row
exit