update RA_BATCH_SOURCES_all rbs
     set rbs.attribute6 = 'Interno',
          rbs.last_update_date = sysdate,
          rbs.last_updated_by = 2070
where rbs.attribute6 is null
    and rbs.attribute_category = 'AR'
    and rbs.org_id in (select ou.organization_id
                               from hr_organization_units ou    
                               where ou.name like 'AR%');
                               
-- Cantidad Total de Filas a actualizar = 967        