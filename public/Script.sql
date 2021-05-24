--Executar em ordem
--1
update AP_SUPPLIERS
set attribute7 = fnd_date.date_to_canonical(end_date_active)
where end_date_active IS NOT NULL
and vendor_id not in (select supplier_id from sae_pos_inactive_suppliers);

--2
ALTER TRIGGER BOLINF.SAE_AP_SUPPLIERS_TRG DISABLE;

--3
update AP_SUPPLIERS
set end_date_active = NULL
where end_date_active IS NOT NULL
and attribute7 IS NOT NULL
and vendor_id not in (select supplier_id from sae_pos_inactive_suppliers);

--4
ALTER TRIGGER BOLINF.SAE_AP_SUPPLIERS_TRG ENABLE;



