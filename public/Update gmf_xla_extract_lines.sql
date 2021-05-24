update apps.mtl_material_transactions
set reason_id = 1663
where transaction_id in (
98498478,
98498479,
98499503,
98499504);
--
update apps.gmf_xla_extract_headers
set reason_id = 1663
where transaction_id in (
98498478,
98498479,
98499503,
98499504);
--
commit;
