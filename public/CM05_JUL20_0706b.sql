SET DEFINE OFF
update xx_ar_ap_coef_cm05
set end_date_active = TO_DATE('05/07/2020','DD/MM/YYYY')
where coef_id IN (80,67,69);
--3 Rows
/
EXIT