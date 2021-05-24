spool xx_wms_int_out_items_pkb.log
CREATE OR REPLACE PACKAGE BODY xx_wms_int_out_items_pk
/* $Header: xx_wms_int_out_items_pkb.pls 1.1    04-DIC-2019   */
-- --------------------------------------------------------------------------
--  1.0  03-10-2019  MGonzalez   Version Original
--  1.1  04-12-2019  MGonzalez   Mejora performance                         

AS
PROCEDURE get_integration_data
(p_int_type                  IN  VARCHAR2
,x_xml_text                  OUT CLOB            
,x_request_id                OUT NUMBER
,x_return_status             OUT VARCHAR2
,x_msg_data                  OUT VARCHAR2
) AS
l_request_id    NUMBER:=to_char(sysdate,'YYYYMMDDHH24MI');
l_date_from     DATE;   --:=sysdate - (nvl(fnd_profile.value('XX_WMS_INT_OUT_ITEMS_HR'),1) /24) ;                                             
l_new_rows      NUMBER;
l_xml_text      XMLTYPE;
l_debug_sequence VARCHAR2(2000):= 'xx_wms_int_out_items_pk.get_integration_data ';
e_error         EXCEPTION;
BEGIN
    /*
    xx_debug_pk.force_on(p_output          => 'DB_TABLE'
                     ,p_level           => 1
                     ,p_directory       => NULL
                     ,p_file            => NULL
                     ,p_other_statement => NULL
                     ,p_message_length  => 4000
                     );
    */

    xx_debug_pk.debug(l_debug_sequence||', Inicio',1);
    xx_debug_pk.debug(l_debug_sequence||', int_type : '||p_int_type,1);

  -- Busca ultima fecha de ejecucion
  BEGIN
    SELECT nvl(to_date(max(xwii.request_id),'YYYYMMDDHH24MI'),sysdate-30)
      INTO l_date_from
      FROM xx_wms_int_items xwii;
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al buscar max request_id en xx_wms_int_items: '||sqlerrm; 
      RAISE e_error;
  END;
  xx_debug_pk.debug(l_debug_sequence||', l_date_from : '||to_char(l_date_from,'YYYYMMDDHH24MI'),1);
      
  --
  -- Inserto en la tabla las novedades de items para enviar a WMS
  --
  BEGIN
    INSERT INTO xx_wms_int_items
          (request_id              
          ,inventory_item_id       
          ,organization_id         
          ,unit_uom_wms            
          ,pallet_uom_wms          
          ,unit_x_pallet_qty       
          ,unit_weight             
          ,weight_uom_code         
          ,action_code             
          ,item_complete_flag      
          ,status                  
          ,error_mesg              
          ,creation_date           
          ,created_by              
          ,last_update_date        
          ,last_updated_by         
          )
    SELECT l_request_id
          ,msi.inventory_item_id
          ,msi.organization_id
          ,null      unit_uom_wms
          ,null      pallet_uom_wms
          ,null      unit_x_pallet_qty
          ,msi.unit_weight
          ,msi.weight_uom_code
          --,CASE WHEN msi.creation_date >= l_date_from THEN 'CREATE'
          --      ELSE 'UPDATE' END             action_code
          ,'CREATE' action_code
          ,'Y'      item_complete_flag
          ,'NEW' status
          ,null  error_mesg
          ,sysdate creation_date
          ,fnd_global.user_id created_by
          ,sysdate last_update_date
          ,fnd_global.user_id last_updated_by
      FROM mtl_system_items msi
          ,mtl_parameters mp
          ,mtl_cross_references mcr
          ,fnd_lookup_values_vl flv
          ,fnd_lookup_values_dfv flv_dfv
     WHERE 1=1
       AND msi.organization_id = mp.organization_id
       AND flv.lookup_type = 'XX_MAPEO_EBS_WMS'
       --AND flv.lookup_code = mp.organization_code
       AND flv_dfv.xx_org_transfer_prod = mp.organization_code
       AND mcr.inventory_item_id = msi.inventory_item_id
       AND flv.rowid             = flv_dfv.row_id
       AND mcr.cross_reference_type = 'DUN14'
       AND nvl(mcr.organization_id,msi.organization_id) = msi.organization_id
       AND (msi.creation_date >  l_date_from
         OR msi.last_update_date > l_date_from
         OR mcr.creation_date >  l_date_from
         OR mcr.last_update_date > l_date_from
         OR EXISTS (SELECT 1
                      FROM MTL_UOM_CLASS_CONVERSIONS muc
                     WHERE msi.inventory_item_id = muc.inventory_item_id
                       AND (muc.creation_date > l_date_from
                           OR muc.last_update_date > l_date_from)
                   )
         OR EXISTS (SELECT 1
                      FROM mtl_system_items_tl msit
                     WHERE 1=1 
                       AND msit.inventory_item_id         = msi.inventory_item_id
                       AND msit.organization_id           = msi.organization_id
                       AND msit.language = 'ESA'
                       AND (msit.creation_date >  l_date_from
                        OR msit.last_update_date > l_date_from )
                   )
           )
    UNION
    SELECT l_request_id
          ,msi.inventory_item_id
          ,msi.organization_id
          ,null      unit_uom_wms
          ,null      pallet_uom_wms
          ,null      unit_x_pallet_qty
          ,nvl(msi.unit_weight,1)
          ,msi.weight_uom_code
          --,CASE WHEN msi.creation_date >= l_date_from THEN 'CREATE'
          --      ELSE 'UPDATE' END             action_code
          ,'CREATE' action_code
          ,'N'      item_complete_flag
          ,'NEW' status
          ,null  error_mesg
          ,sysdate creation_date
          ,fnd_global.user_id created_by
          ,sysdate last_update_date
          ,fnd_global.user_id last_updated_by
      FROM mtl_system_items msi
          ,mtl_parameters mp
          ,fnd_lookup_values_vl flv
          ,fnd_lookup_values_dfv flv_dfv
     WHERE 1=1
       AND msi.organization_id = mp.organization_id
       AND flv.lookup_type = 'XX_MAPEO_EBS_WMS'
       --AND flv.lookup_code = mp.organization_code
       AND flv_dfv.xx_org_transfer_prod = mp.organization_code
       AND flv.rowid             = flv_dfv.row_id
       AND (msi.creation_date >  l_date_from
         OR msi.last_update_date > l_date_from
         OR EXISTS (SELECT 1
                      FROM mtl_system_items_tl msit
                     WHERE 1=1 
                       AND msit.inventory_item_id         = msi.inventory_item_id
                       AND msit.organization_id           = msi.organization_id
                       AND msit.language = 'ESA'
                       AND (msit.creation_date >  l_date_from
                        OR msit.last_update_date > l_date_from)
                    )
         )
       AND NOT EXISTS(SELECT 1
                        FROM mtl_cross_references mcr
                       WHERE mcr.inventory_item_id = msi.inventory_item_id
                         AND mcr.cross_reference_type = 'DUN14'
                         AND nvl(mcr.organization_id,msi.organization_id) = msi.organization_id
                      )
        ;

    --l_new_rows := SQL%ROWCOUNT;
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al insertar en xx_wms_int_items: '||sqlerrm; 
      RAISE e_error;
  END;
  BEGIN
    UPDATE xx_wms_int_items xwii
       SET request_id = l_request_id
          ,status     = 'NEW'
          ,error_mesg = ''
     WHERE status != 'OK' --= 'ERROR'
       AND NOT EXISTS (SELECT 1
                         FROM xx_wms_int_items xwii2
                        WHERE xwii2.inventory_item_id = xwii.inventory_item_id
                          AND xwii2.request_id        = l_request_id); 
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al actualizar lineas con error en xx_wms_int_items: '||sqlerrm;
      RAISE e_error;
  END;

  BEGIN
    UPDATE xx_wms_int_items xwii
       SET status = 'ERROR'
          ,error_mesg = case when(xwii.error_mesg is null) then 
                                  '' else xwii.error_mesg || '. ' end || 
                                  'Item sin vida util en org de declaracion de produccion'
     WHERE xwii.request_id = l_request_id
       AND xwii.item_complete_flag = 'Y'
       AND EXISTS(
            SELECT 1                                                                   
              FROM mtl_system_items msi
                  ,mtl_parameters mp
                  ,fnd_lookup_values_vl flv
                  ,fnd_lookup_values_dfv flv_d
             WHERE 1 = 1
               AND msi.inventory_item_id = xwii.inventory_item_id
               AND msi.organization_id  = mp.organization_id
               AND flv_d.xx_org_declaracion_prod = mp.organization_code
               AND flv.lookup_type = 'XX_MAPEO_EBS_WMS'
               AND flv.rowid = flv_d.row_id
               AND NVL(msi.shelf_life_days,0) = 0 --dias de vida util
                 )				   
        ;
    xx_debug_pk.debug(l_debug_sequence||', items sin vida util en org de declaracion: '|| SQL%ROWCOUNT,1);
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al actualizar lineas con error en xx_wms_int_items: '||sqlerrm;
      RAISE e_error;
  END;
  BEGIN
    UPDATE xx_wms_int_items xwii
       SET status = 'ERROR'
          ,error_mesg = case when(xwii.error_mesg is null) then 
                                  '' else xwii.error_mesg || '. ' end || 
                        'Item sin vida util en org de transferencia'
     WHERE xwii.request_id = l_request_id
       AND xwii.item_complete_flag = 'Y'
       AND EXISTS(
            SELECT 1
              FROM mtl_system_items msi
                  ,mtl_parameters mp
                  ,fnd_lookup_values_vl flv
                  ,fnd_lookup_values_dfv flv_d
             WHERE 1 = 1
               AND msi.inventory_item_id = xwii.inventory_item_id
               AND msi.organization_id  = mp.organization_id
               AND flv_d.xx_org_transfer_prod = mp.organization_code
               AND flv.lookup_type = 'XX_MAPEO_EBS_WMS'
               AND flv.rowid = flv_d.row_id
               AND NVL(msi.shelf_life_days,0) = 0 --dias de vida util
                 )
        ;
    xx_debug_pk.debug(l_debug_sequence||', items sin vida util en org de transferencia: '|| SQL%ROWCOUNT,1);
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al actualizar lineas con error en xx_wms_int_items: '||sqlerrm;
      RAISE e_error;
  END;

  BEGIN
    UPDATE xx_wms_int_items xwii
       SET status = 'ERROR'
          ,error_mesg = case when(xwii.error_mesg is null) then 
                                  '' else xwii.error_mesg || '. ' end || 
                        'No existe DUN14' 
     WHERE xwii.request_id = l_request_id
       AND xwii.item_complete_flag = 'Y'
       AND NOT EXISTS 
                  (SELECT 1
                     FROM mtl_system_items msi
                         ,mtl_cross_references mcr
                    WHERE 1=1 
                      AND xwii.inventory_item_id      = msi.inventory_item_id
                      AND xwii.organization_id        = msi.organization_id
                      AND mcr.inventory_item_id       = msi.inventory_item_id
                      AND nvl(mcr.organization_id,msi.organization_id) = msi.organization_id
                      AND mcr.cross_reference_type    = 'DUN14')
     ;

    xx_debug_pk.debug(l_debug_sequence||', items sin DUN14: '|| SQL%ROWCOUNT,1);
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al actualizar lineas con error en xx_wms_int_items: '||sqlerrm;
      RAISE e_error;
  END;

  BEGIN
    UPDATE xx_wms_int_items xwii
       SET (unit_uom_wms
           ,pallet_uom_wms) = 
                  (SELECT mcr_d.xx_uom_wms
                         ,mcr_d.xx_uom_pallet_wms
                     FROM mtl_system_items msi
                         ,mtl_cross_references mcr
                         ,mtl_cross_references_dfv mcr_d

                    WHERE 1=1
                      AND xwii.inventory_item_id      = msi.inventory_item_id
                      AND xwii.organization_id        = msi.organization_id
                      AND mcr.inventory_item_id       = msi.inventory_item_id
                      AND nvl(mcr.organization_id,msi.organization_id) = msi.organization_id
                      AND mcr.cross_reference_type    = 'DUN14'
                      AND mcr.rowid = mcr_d.row_id )
     WHERE xwii.request_id = l_request_id
       AND xwii.item_complete_flag = 'Y'
       AND (xwii.unit_uom_wms IS NULL OR xwii.pallet_uom_wms IS NULL)
     ;
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al actualizar lineas con error en xx_wms_int_items: '||sqlerrm;
      RAISE e_error;
  END;
  BEGIN
    UPDATE xx_wms_int_items xwii
       SET status = 'ERROR'
          ,error_mesg = case when(xwii.error_mesg is null) then 
                                  '' else xwii.error_mesg || '. ' end || 
                        'No existe Unidad de Medida para DUN14'
     WHERE xwii.request_id = l_request_id
       AND xwii.item_complete_flag = 'Y'
       AND xwii.unit_uom_wms IS NULL
     ;

    xx_debug_pk.debug(l_debug_sequence||', items sin UOM en DUN14: '|| SQL%ROWCOUNT,1);
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al actualizar lineas con error en xx_wms_int_items: '||sqlerrm;
      RAISE e_error;
  END;
  BEGIN
    UPDATE xx_wms_int_items xwii
       SET status = 'ERROR'
          ,error_mesg = case when(xwii.error_mesg is null) then 
                                  '' else xwii.error_mesg || '. ' end || 
                        'No existe Unidad de Medida Pallet en DUN14'
     WHERE xwii.request_id = l_request_id
       AND xwii.item_complete_flag = 'Y'
       AND xwii.pallet_uom_wms IS NULL
     ;
    xx_debug_pk.debug(l_debug_sequence||', items sin UOM de Pallet en DUN14: '|| SQL%ROWCOUNT,1);
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al actualizar lineas con error en xx_wms_int_items: '||sqlerrm;
      RAISE e_error;
  END;
  BEGIN
    UPDATE xx_wms_int_items xwii
       SET status = 'ERROR'
          ,error_mesg = case when(xwii.error_mesg is null) then 
                                  '' else xwii.error_mesg || '. ' end || 
                        'No existe peso'
     WHERE xwii.request_id = l_request_id
       AND xwii.item_complete_flag = 'Y'
       AND (xwii.unit_weight IS NULL OR xwii.weight_uom_code IS NULL)
     ;
    xx_debug_pk.debug(l_debug_sequence||', items sin peso: '|| SQL%ROWCOUNT,1);
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al actualizar lineas con error en xx_wms_int_items: '||sqlerrm;
      RAISE e_error;
  END;



  BEGIN
    UPDATE xx_wms_int_items xwii
       SET unit_weight_wms = decode(xwii.weight_uom_code
                                   ,'KG',xwii.unit_weight
                                   ,inv_convert.inv_um_convert (xwii.inventory_item_id   --Inventory Item Id
                                                               ,NULL                     --Precision
                                                               ,NVL(xwii.unit_weight, 0) --Quantity
                                                               ,xwii.weight_uom_code     --From UOM
                                                               ,'KG'                     --To UOM
                                                               ,NULL                     --From UOM Name
                                                               ,NULL                     --To UOM Name
                                                               ))
          ,kg_x_pallet = inv_convert.inv_um_convert (xwii.inventory_item_id    --Inventory Item Id
                                                    ,NULL                      --Precision
                                                    ,1                         --Quantity
                                                    ,xwii.pallet_uom_wms       --From UOM
                                                    ,'KG'                      --To UOM
                                                    ,NULL                      --From UOM Name
                                                    ,NULL                      --To UOM Name
                                                    )
 
     WHERE xwii.request_id = l_request_id
       AND xwii.item_complete_flag = 'Y'
        ;
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al actualizar lineas con unit_weight_wms en xx_wms_int_items: '||sqlerrm;
      RAISE e_error;
  END;

  BEGIN
    UPDATE xx_wms_int_items xwii
       SET status = 'ERROR'
          ,error_mesg = case when(xwii.error_mesg is null) then 
                                  '' else xwii.error_mesg || '. ' end || 
                        'No existe conversion entre KG y '||xwii.weight_uom_code
     WHERE xwii.request_id = l_request_id
       AND xwii.item_complete_flag = 'Y'
       AND (xwii.unit_weight_wms IS NULL OR xwii.unit_weight_wms = -99999)
       AND xwii.unit_weight IS NOT NULL
       AND xwii.weight_uom_code IS NOT NULL
     ;

    xx_debug_pk.debug(l_debug_sequence||', items sin conversion a KG: '|| SQL%ROWCOUNT,1);
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al actualizar lineas con error en xx_wms_int_items: '||sqlerrm;
      RAISE e_error;
  END;
  BEGIN
    UPDATE xx_wms_int_items xwii
       SET status = 'ERROR'
          ,error_mesg = case when(xwii.error_mesg is null) then 
                                  '' else xwii.error_mesg || '. ' end || 
                        'No existe conversion entre KG y '||xwii.pallet_uom_wms
     WHERE xwii.request_id = l_request_id
       AND xwii.item_complete_flag = 'Y'
       AND (xwii.kg_x_pallet IS NULL OR xwii.kg_x_pallet = -99999)
       AND xwii.pallet_uom_wms IS NOT NULL
     ;
    xx_debug_pk.debug(l_debug_sequence||', items sin conversion a Pallet: '|| SQL%ROWCOUNT,1);

  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al actualizar lineas con error en xx_wms_int_items: '||sqlerrm;
      RAISE e_error;
  END;

  BEGIN
    UPDATE xx_wms_int_items xwii
       SET unit_x_pallet_qty = inv_convert.inv_um_convert (xwii.inventory_item_id    --Inventory Item Id
                                                          ,NULL                      --Precision
                                                          ,xwii.kg_x_pallet          --Quantity
                                                          ,'KG'                      --From UOM
                                                          ,xwii.unit_uom_wms         --To UOM
                                                          ,NULL                      --From UOM Name
                                                          ,NULL                      --To UOM Name
                                                          )

     WHERE xwii.request_id = l_request_id
       AND xwii.item_complete_flag = 'Y'
        ;
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al actualizar lineas con unit_x_pallet_qty en xx_wms_int_items: '||sqlerrm;
      RAISE e_error;
  END;

  BEGIN
    UPDATE xx_wms_int_items xwii
       SET status = 'ERROR'
          ,error_mesg = case when(xwii.error_mesg is null) then 
                                  '' else xwii.error_mesg || '. ' end || 
                        'No existe conversion entre KG y '||nvl(xwii.unit_uom_wms,'Unidad medida WMS')
     WHERE xwii.request_id = l_request_id
       AND xwii.item_complete_flag = 'Y'
       AND (xwii.unit_x_pallet_qty IS NULL OR xwii.unit_x_pallet_qty = -99999)
       AND xwii.kg_x_pallet IS NOT NULL AND xwii.kg_x_pallet != -99999
       AND -99999 != inv_convert.inv_um_convert (xwii.inventory_item_id    --Inventory Item Id
                                                ,NULL                      --Precision
                                                ,xwii.unit_weight_wms          --Quantity
                                                ,'KG'                      --From UOM
                                                ,xwii.unit_uom_wms         --To UOM
                                                ,NULL                      --From UOM Name
                                                ,NULL                      --To UOM Name
                                                )

     ;
    xx_debug_pk.debug(l_debug_sequence||', items sin conversion a Pallet: '|| SQL%ROWCOUNT,1);

  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al actualizar lineas con error en xx_wms_int_items: '||sqlerrm;
      RAISE e_error;
  END;
  BEGIN
    UPDATE xx_wms_int_items xwii
       SET status = 'ERROR'
          ,error_mesg = case when(xwii.error_mesg is null) then
                                  '' else xwii.error_mesg || '. ' end ||
                        'No existe conversion entre KG y '||nvl(xwii.unit_uom_wms,'Unidad medida WMS')
     WHERE xwii.request_id = l_request_id
       AND xwii.item_complete_flag = 'Y'
       AND -99999 = inv_convert.inv_um_convert (xwii.inventory_item_id    --Inventory Item Id
                                               ,NULL                      --Precision
                                               ,xwii.unit_weight_wms          --Quantity
                                               ,'KG'                      --From UOM
                                               ,xwii.unit_uom_wms         --To UOM
                                               ,NULL                      --From UOM Name
                                               ,NULL                      --To UOM Name
                                               )
      AND xwii.unit_weight_wms IS NOT NULL
      AND xwii.unit_uom_wms    IS NOT NULL
     ;
    xx_debug_pk.debug(l_debug_sequence||', items sin conversion a Unidad de medida de WMS: '|| SQL%ROWCOUNT,1);

  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al actualizar lineas con error en xx_wms_int_items: '||sqlerrm;
      RAISE e_error;
  END;


  xx_debug_pk.debug(l_debug_sequence||', l_request_id : '||l_request_id,1);

  BEGIN
    SELECT count(1)             
      INTO l_new_rows                                        
      FROM xx_wms_int_items xwii
     WHERE xwii.request_id = l_request_id
       AND xwii.status != 'ERROR';
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al buscar lineas sin error en xx_wms_int_items: '||sqlerrm;
      RAISE e_error;
  END;

  xx_debug_pk.debug(l_debug_sequence||', l_new_rows : '||l_new_rows,1);
  IF nvl(l_new_rows,0) > 0 THEN
    --
    -- Si hay novedades armo xml para mensaje de salida
    --
    BEGIN
      --SELECT ('<?xml version="1.0" encoding="utf-8"?> '||XMLCONCAT (XMLELEMENT ("LgfData", XMLELEMENT ("Header", 
      SELECT ((XMLELEMENT ("LgfData", XMLELEMENT ("Header", 
                                   XMLELEMENT ("DocumentVersion",
                                               '9.0.0'
                                              ),
                                   XMLELEMENT ("OriginSystem",
                                               'LGF'
                                              ),
                                   XMLELEMENT ("ClientEnvCode",
                                               l_request_id 
                                              ),
                                   XMLELEMENT ("ParentCompanyCode",
                                               'ADECO'
                                              ),
                                   XMLELEMENT ("Entity",
                                               'item'
                                              ),
                                   XMLELEMENT ("TimeStamp",
                                               to_char(sysdate,'YYYY-mm-dd hh24:mi:ss') 
                                              ),
                                   XMLELEMENT ("MessageId",
                                               l_request_id                         
                                              )
                               ),
                     XMLELEMENT ("ListOfItems",
               (SELECT XMLAGG(
                         XMLELEMENT("item",
                           XMLFOREST(
                             --mp.organization_code                           AS "company_code"
                             'ADECO'                                        AS "company_code"
                            ,msi.segment1                                   AS "item_alternate_code"
                            ,msi.segment1                                   AS "part_a"
                            ,xwii.action_code                               AS "action_code"
                            ,replace(msit.long_description,'"','')          AS "description"
                            ,decode(xwii.item_complete_flag,'Y'
                                   ,mcr.cross_reference, msi.segment1)      AS "barcode"
                            ,'1'                                            AS "unit_cost"
                            ,'0'                                            AS "unit_length"
                            ,'0'                                            AS "unit_width"
                            ,'0'                                            AS "unit_height"
                            ,decode(xwii.item_complete_flag,'Y'
                                   ,xwii.unit_weight_wms,xwii.unit_weight)  AS "unit_weight"
                            ,'0'                                            AS "unit_volume"
                            ,'false'                                        AS "hazmat"
                            ,decode(xwii.item_complete_flag,'Y'
                                    ,xwii.unit_x_pallet_qty,1)              AS "std_case_qty" ---cantidad de bolsones por pallet??? ver como se calcular la conversion
                            ,decode(msi.lot_control_code,2,'true','false')  AS "req_batch_nbr_flg"	
                            ,'true'                                         AS "host_aware_item_flg"
                            ,'false'                                        AS "handle_decimal_qty_flg"
                            ,'0'                                            AS "product_life"  -- ver como se obtiene
                           )
                         )
                       )
                  FROM xx_wms_int_items xwii
                      ,mtl_system_items msi
                      ,mtl_system_items_tl msit
                      ,mtl_parameters mp
                      ,mtl_cross_references mcr
                 WHERE xwii.request_id                = l_request_id
                   AND xwii.status                   != 'ERROR'
                   AND xwii.inventory_item_id         = msi.inventory_item_id
                   AND xwii.organization_id           = msi.organization_id
                   AND msi.organization_id            = mp.organization_id
                   AND msit.inventory_item_id         = msi.inventory_item_id
                   AND msit.organization_id           = msi.organization_id
                   AND msit.language = 'ESA'
                   AND mcr.inventory_item_id(+)       = msi.inventory_item_id
                   --AND mcr.organization_id(+)         = msi.organization_id
                   AND mcr.cross_reference_type(+)    = 'DUN14'
                   --AND msi.segment1 = '320951360004'
               ) "ListOfItems"
              )
            ))) xmltext
       INTO l_xml_text
       FROM DUAL;
     x_return_status := 'S';
     x_request_id    := l_request_id;
     x_xml_text      := l_xml_text.getClobVal();
    EXCEPTION
      WHEN OTHERS THEN
        x_msg_data := 'Error al armar x_xml_text: '||sqlerrm; 
        RAISE e_error;
    END;
  ELSE 
    x_return_status := 'X'; -- Indica que no se encontraron novedades
  END IF;
  xx_debug_pk.debug('XX Fin',1);

EXCEPTION
  WHEN e_error THEN
    x_return_status := 'E';
    UPDATE xx_wms_int_items xwii
       SET status = 'ERROR'
          ,error_mesg = x_msg_data                                                
     WHERE xwii.request_id = l_request_id
       AND xwii.status != 'ERROR';
  WHEN OTHERS THEN
    x_return_status := 'E';
    x_msg_data := 'Error: '||sqlerrm;
    UPDATE xx_wms_int_items xwii
       SET status = 'ERROR'
          ,error_mesg = x_msg_data
     WHERE xwii.request_id = l_request_id
       AND xwii.status != 'ERROR';
END get_integration_data;
PROCEDURE update_response_integration
(p_int_type                  IN  VARCHAR2
,p_request_id                IN  NUMBER
,p_return_status             IN  VARCHAR2
,p_msg_data                  IN  VARCHAR2
)AS
BEGIN
  UPDATE xx_wms_int_items
     SET status            = decode(p_return_status,'True','OK','ERROR')
        ,error_mesg        = decode(p_return_status,'True','',p_msg_data)
        ,last_update_date  = sysdate
        ,last_updated_by   = fnd_global.user_id
   WHERE request_id = p_request_id
     AND status    != 'ERROR';
END update_response_integration;

END xx_wms_int_out_items_pk;
/
show err
spool off
EXIT
