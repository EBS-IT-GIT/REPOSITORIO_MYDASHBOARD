CREATE OR REPLACE VIEW APPS.SAE_GRA
AS
SELECT GRA, Solicitante,Data_do_Status AS "Data do Status",  case when a.tipo = 'Retorno do Fornecedor (no Almox)' then 'Retorno' ELSE 'Remessa' END "Tipo"   FROM (
SELECT sgh.header_id        GRA
     , ppf.last_name        Solicitante
     , TO_CHAR(sgh.creation_date,'DD/MM/RRRR HH24:MI:SS')  Data_do_Status
     , (SELECT sts.meaning
          FROM apps.sae_gra_stages       sgs
             , apps.fnd_lookup_values_vl sts
         WHERE sgs.header_id = sgh.header_id
           AND sgs.stage_id = (SELECT MAX(x.stage_id) FROM apps.sae_gra_stages x WHERE x.header_id = sgh.header_id)
           AND sts.lookup_type = 'SAE_GRA_ETAPA'
           AND sts.lookup_code = sgs.stage_action) Tipo
  FROM apps.sae_gra_headers      sgh
     , apps.per_people_f         ppf
     , apps.fnd_lookup_values_vl pri
     , apps.fnd_lookup_values_vl tip
     , apps.po_vendors           pv
     , apps.po_vendor_sites_all  pvs
 WHERE ppf.person_id = sgh.user_requester 
   AND ppf.effective_start_date = (SELECT MAX(x.effective_start_date) FROM per_people_f x WHERE x.person_id = sgh.user_requester )   
   AND pri.lookup_type          = 'SAE_GRA_PRIORIDADE'
   AND pri.lookup_code          = sgh.priority
   AND tip.lookup_type          = 'SAE_GRA_TIPOS'
   AND tip.lookup_code          = sgh.type_code
   AND pvs.vendor_site_id       = sgh.vendor_site_id
   AND pv.vendor_id             = pvs.vendor_id
ORDER BY sgh.header_id) a 
WHERE Tipo IN ('Aguardando Conferência','Retorno do Fornecedor (no Almox)')
-- Alexandre Lima 21/11/2019 FIM

