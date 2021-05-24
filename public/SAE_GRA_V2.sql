 
--View Atualizada em 02/03/2020 - Chamado 125449
CREATE OR REPLACE FORCE EDITIONABLE VIEW "APPS"."SAE_GRA" ("GRA", "SOLICITANTE", "Data GRA", "Tipo") AS 
  SELECT a.GRA, A.Solicitante, A.data_status as "Data GRA", case when a.gra_status = 'Retorno do Fornecedor (no Almox)' then 'Retorno' ELSE 'Remessa' END "Tipo" FROM (
SELECT sgh.header_id        GRA
     , ppf.last_name        Solicitante
     , TO_CHAR(sgh.creation_date,'DD/MM/RRRR HH24:MI:SS')  gra_data
     , pri.meaning          prioridade
     , tip.meaning          gra_tipo
     , pv.vendor_name       destino
     , (SELECT sts.meaning
          FROM apps.sae_gra_stages       sgs
             , apps.fnd_lookup_values_vl sts
         WHERE sgs.header_id = sgh.header_id
           AND sgs.stage_id = (SELECT MAX(x.stage_id) FROM apps.sae_gra_stages x WHERE x.header_id = sgh.header_id)
           AND sts.lookup_type = 'SAE_GRA_ETAPA'
           AND sts.lookup_code = sgs.stage_action) gra_status
     , TO_CHAR(sts.creation_date,'DD/MM/RRRR HH24:MI:SS')  data_status
      , TO_CHAR(sts.forecast_date ,'DD/MM/RRRR HH24:MI:SS')  data_forecast
  FROM apps.sae_gra_headers      sgh
     , apps.sae_gra_stages       sts
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
   AND sts.stage_id = (SELECT MAX(x.stage_id) FROM apps.sae_gra_stages x WHERE x.header_id = sgh.header_id)
ORDER BY sgh.header_id) a 
WHERE gra_status IN ('Aguardando Conferência','Retorno do Fornecedor (no Almox)')
  --AND a.gra IN ( 1043,1208)
;