delete jg.JG_ZZ_ENTITY_ASSOC asoc
where asoc.id_type = '25'
and asoc.ineffective_date is not null
and exists (select 1
              from jg.JG_ZZ_ENTITY_ASSOC as2
             where id_type = '25'
             and as2.ineffective_date is null
             and asoc.primary_id_number = as2.primary_id_number
             and asoc.ASSOCIATED_ENTITY_ID = as2.ASSOCIATED_ENTITY_ID
             and asoc.effective_date > as2.effective_date);
             --717 Rows
             /
             EXIT