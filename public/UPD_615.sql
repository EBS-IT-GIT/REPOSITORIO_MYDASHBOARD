SET DEFINE OFF
update po_vendors pv
set attribute5 = (select codigo_sustitutiva from apps.xx_ap_vendor_sustitutiva_t_all sust
where cuit_vendor = PV.Num_1099||pv.global_attribute12)
where vendor_id IN (SELECT vendor_id
FROM apps.xx_ap_vendor_sustitutiva_t_all sust
,apps.po_vendors pv
where sust.cuit_vendor = PV.Num_1099||pv.global_attribute12
and attribute5 != sust.codigo_sustitutiva);
--185 Rows
/
EXIT