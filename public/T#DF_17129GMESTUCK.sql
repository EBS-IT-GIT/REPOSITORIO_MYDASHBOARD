

delete from apps.mtl_transaction_lots_temp
where transaction_temp_id in (select 
mtt.transaction_temp_id
from apps.MTL_MATERIAL_TRANSACTIONs_TEMP mtt,apps.mtl_parameters ood
where mtt.organization_id = ood.organization_id and mtt.transaction_source_id = 6854031 and mtt.organization_id = 2456
);
--1 reg





