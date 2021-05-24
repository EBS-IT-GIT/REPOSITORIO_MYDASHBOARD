set define off;
update ap_invoices_all
set global_attribute12 = 'A'
,global_attribute13 = '01'
where invoice_id = 5396750;
--1 Rows

update ap_invoices_all
set global_attribute11 = 'FC INTERNA'
,global_attribute12 = 'Y'
,global_attribute13 = '99'
where invoice_id IN (3602674,5221654);
--2 Rows
EXIT