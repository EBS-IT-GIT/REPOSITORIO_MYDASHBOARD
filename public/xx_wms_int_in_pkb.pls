spool xx_wms_int_in_pkb.log
CREATE OR REPLACE PACKAGE BODY xx_wms_int_in_pk
/* $Header: xx_wms_int_in_pkb.pls 1.5    09-JUN-2020   */
-- --------------------------------------------------------------------------
--  1.0  02-10-2019  MGonzalez   Version Original
--  1.1  11-12-2019  MGonzalez   Se valida que no exista el registro 
--                               antes de insertar
--  1.2  13-12-2019  MGonzalez   Se agrega Ajuste Stock y Bloqueo    
--  1.3  20-12-2019  MGonzalez   Se agrega Bloqueo    
--  1.4  13-01-2020  MGonzalez   Se agrega Recepcion RMA
--  1.5  09-06-2020  MGonzalez   Se agrega control_concurrencia

AS
PROCEDURE update_status(p_status       IN VARCHAR2
                       ,p_error_mesg   IN VARCHAR2
                       ,p_message_id   IN VARCHAR2
                       ,p_row_id       IN ROWID) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  UPDATE xx_wms_integration_in xwii
     SET status           = p_status
        ,error_mesg       = p_error_mesg
        ,last_update_date = sysdate                              
    WHERE xwii.message_id = p_message_id
      AND ((p_row_id IS NULL 
           AND xwii.status     IN ('NEW', 'RUNNING'))
           OR p_row_id IS NOT NULL)
      AND xwii.rowid      = nvl(p_row_id, xwii.rowid);
  COMMIT;
END update_status;

PROCEDURE validate_message_id(p_message_id    IN VARCHAR2
                             ,p_error_mesg   OUT VARCHAR2
                             ) IS
l_debug_sequence VARCHAR2(2000):= 'xx_wms_int_in_pk.validate_message_id';
BEGIN
  xx_debug_pk.debug(l_debug_sequence||', Inicio',1);
  SELECT 'El message_id '||p_message_id||' ya fue procesado exitosamente'
    INTO p_error_mesg
    FROM dual
   WHERE EXISTS (SELECT 1
                   FROM xx_wms_integration_in xwii
                  WHERE xwii.message_id = p_message_id
                    AND xwii.status     = 'OK')
  ; 
  xx_debug_pk.debug(l_debug_sequence||', Fin',1);
EXCEPTION
  WHEN no_data_found THEN
    null;
  WHEN others THEN
    p_error_mesg := 'Error al validar message_id: '||sqlerrm;
END validate_message_id;

PROCEDURE control_concurrencia(p_message_id    IN VARCHAR2
                              ,p_error_mesg   OUT VARCHAR2
                             ) IS
l_calling_sequence VARCHAR2(2000):= 'xx_wms_int_in_pk.control_concurrencia';
l_count            NUMBER:=0;
BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  LOOP
    SELECT count(1) --'Existen lineas en RUNNING'                                             
      INTO l_count
      FROM xx_wms_integration_in xwii
     WHERE 1=1
	   --AND xwii.message_id != p_message_id
       AND xwii.status      = 'RUNNING';             
    EXIT WHEN l_count =0;             
  END LOOP;
  update_status(p_status       => 'RUNNING'
               ,p_error_mesg   => null
               ,p_message_id   => p_message_id
               ,p_row_id       => null);

  COMMIT;
  xx_debug_pk.debug(l_calling_sequence||', Fin',1);
EXCEPTION
  WHEN no_data_found THEN
    null;
  WHEN others THEN
    p_error_mesg := 'Error al controlar concurrencia message_id: '||sqlerrm;
END control_concurrencia;

PROCEDURE submit_RMA_processor(p_message_id    IN VARCHAR2
                              ,p_error_mesg   OUT VARCHAR2
                             ) IS
l_debug_sequence VARCHAR2(2000):= 'xx_wms_int_in_pk.submit_RMA_processor';
l_request_id     NUMBER;                                                            
l_user_id                        NUMBER;
l_resp_id                        NUMBER;
l_appl_id                        NUMBER;
l_respo_po                 VARCHAR2(100);
e_error          EXCEPTION;                                                         
CURSOR c_org IS
SELECT distinct ooh.org_id, xwii.facility_code 
  FROM xx_wms_integration_in xwii
     , oe_order_headers_all ooh
 WHERE 1=1 
   AND xwii.message_id             = p_message_id                      
   AND xwii.activity_code          = 1
   AND xwii.shipment_type          = 'DEV'
   AND xwii.status                 = 'OK'
   AND to_number(xwii.invn_attr_a) = ooh.header_id
;                                        

BEGIN
  xx_debug_pk.debug(l_debug_sequence||', Inicio',1);
  -- Ver que respo tiene que tener para hacer la importacion
  --fnd_profile.initialize (42057);
  --fnd_global.apps_initialize(user_id =>42057
  --                          ,resp_id =>50271
  --                          ,resp_appl_id =>201 );

  l_user_id := fnd_profile.value('XX_WMS_INTEGRATION_USER');

  IF l_user_id IS NULL THEN
    p_error_mesg := 'No se encuentra configurada la opcion de perfil XX WMS Usuario Integracion';
    RAISE e_error;
  END IF;

  FOR r_org IN c_org LOOP
    BEGIN
      SELECT flv_d.xx_respo_po
        INTO l_respo_po
        FROM fnd_lookup_values_vl flv
            ,fnd_lookup_values_dfv flv_d
       WHERE flv.lookup_type = 'XX_EBS_WMS_RESPO'
         AND flv.lookup_code = r_org.facility_code
         AND flv.rowid = flv_d.row_id;
    EXCEPTION
      WHEN OTHERS THEN
        p_error_mesg := 'Error al buscar la responsabilidad de Split de OM: '||sqlerrm;
        RAISE e_error;
    END;
  
    IF l_respo_po IS NULL THEN
      p_error_mesg := 'No se encuentra configurado el Flexfield de responsabilidad de PO en el lookup XX_EBS_WMS_RESPO';
      RAISE e_error;
    END IF;
  
    BEGIN
      SELECT responsibility_id
            ,application_id
        INTO l_resp_id
            ,l_appl_id
        FROM fnd_responsibility_vl
       WHERE responsibility_name = l_respo_po;
    EXCEPTION
      WHEN OTHERS THEN
        p_error_mesg := 'Error al obtener applicacion para la responsibility_name: '||l_respo_po||'. '||sqlerrm;
        RAISE e_error;
    END;
    fnd_profile.initialize (l_user_id);
    fnd_global.apps_initialize(user_id =>l_user_id
                              ,resp_id =>l_resp_id
                              ,resp_appl_id =>l_appl_id );


    xx_debug_pk.debug(l_debug_sequence||', Submit Procesador de Transacciones de Recepcion',1);
    BEGIN
      l_request_id := fnd_request.submit_request( application => 'PO'
                                                , program     => 'RVCTP'
                                                , description =>  ''
                                                , start_time  =>  ''
                                                , sub_request =>  FALSE
                                                , argument1   =>  'BATCH'
                                                , argument2   =>  ''                 
                                                , argument3   =>  r_org.org_id
                                              );

      xx_debug_pk.debug(l_debug_sequence||', l_request_id: '||l_request_id,1);
      IF l_request_id = 0 THEN
          p_error_mesg := fnd_message.get;
          RAISE e_error;
      END IF;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        p_error_mesg := 'Error Submit Concurrente Procesador de Transacciones de Recepcion. '||sqlerrm;
        RAISE e_error;
    END;
    xx_debug_pk.debug(l_debug_sequence||', l_request_id: '||l_request_id,1);
  END LOOP;
  xx_debug_pk.debug(l_debug_sequence||', Fin',1);
EXCEPTION
  WHEN no_data_found THEN
    null;
  WHEN others THEN
    p_error_mesg := 'Error al ejecutar procesador de recepcion de RMA: '||sqlerrm;
END submit_RMA_processor;

PROCEDURE process_integration
(p_int_type                  IN  VARCHAR2
,p_message_id                IN  VARCHAR2
,p_inv_history_tab           IN  XX_WMS_INT_IN_PK.XX_WMS_INV_HISTORY_TAB
,x_request_id                OUT NUMBER
,x_return_status             OUT VARCHAR2
,x_msg_data                  OUT VARCHAR2
) AS

CURSOR c_trx IS
SELECT *
  FROM(
SELECT xwii.rowid row_id
      ,xwii.*
  FROM xx_wms_integration_in xwii
 WHERE xwii.message_id = p_message_id
   AND xwii.status     = 'RUNNING'--'NEW'
 UNION
SELECT xwii.rowid row_id
      ,xwii.*
  FROM xx_wms_integration_in xwii
 WHERE xwii.message_id != p_message_id
   AND xwii.status      = 'ERROR'
   AND NOT EXISTS (SELECT 1
                     FROM xx_wms_integration_in xwii2
                    WHERE 1=1
                      AND xwii2.status     = 'OK'
                      AND xwii2.message_id = xwii.message_id
                      AND xwii2.group_nbr  = xwii.group_nbr
                      AND xwii2.seq_nbr    = xwii.seq_nbr)
      )
ORDER BY message_id, group_nbr, seq_nbr
;

l_inv_history_rec  xx_wms_int_in_pk.XX_WMS_INV_HISTORY_REC;
l_error_mesg       VARCHAR2(2000);
l_debug_sequence   VARCHAR2(2000):= 'xx_wms_int_in_pk.process_integration';
l_error_count      NUMBER;
e_error            EXCEPTION;

BEGIN
  xx_debug_pk.force_on(p_output          => 'DB_TABLE'
                     ,p_level           => 1
                     ,p_directory       => NULL
                     ,p_file            => NULL
                     ,p_other_statement => NULL
                     ,p_message_length  => 4000
                     );

  xx_debug_pk.debug(l_debug_sequence||', Inicio',1);
  xx_debug_pk.debug(l_debug_sequence||', p_inv_history_tab.count : '||p_inv_history_tab.count,1);
IF p_inv_history_tab.count > 0  THEN
  FOR i IN 1..p_inv_history_tab.count LOOP
      xx_debug_pk.debug(l_debug_sequence||',  p_inv_history_tab.activity_code : '||p_inv_history_tab(i).activity_code,1);
      xx_debug_pk.debug(l_debug_sequence||',  p_inv_history_tab.shipment_type : '||p_inv_history_tab(i).shipment_type,1);
    IF ((p_inv_history_tab(i).activity_code = 1 AND p_inv_history_tab(i).shipment_type = 'PROD') OR          -- Declaracion Produccion
        (p_inv_history_tab(i).activity_code = 1 AND p_inv_history_tab(i).shipment_type = 'DEV') OR           -- Recepcion RMA                
        (p_inv_history_tab(i).activity_code IN ( 4, 17, 19, 39, 40, 53 ) AND p_inv_history_tab(i).reason_code IS NOT NULL   -- Ajustes 
                                                                         )OR -- Ajustes CON DEV_PROD

         p_inv_history_tab(i).activity_code IN ( 22, 23, 24, 25 )                                            -- Bloqueo/Desbloqueo
         ) THEN                                    
      xx_debug_pk.debug(l_debug_sequence||',  p_inv_history_tab.i : '||i,1);
      xx_debug_pk.debug(l_debug_sequence||',  p_inv_history_tab.group_nbr : '||p_inv_history_tab(i).group_nbr,1);
      xx_debug_pk.debug(l_debug_sequence||',  p_inv_history_tab.seq_nbr : '||p_inv_history_tab(i).seq_nbr,1);
      xx_debug_pk.debug(l_debug_sequence||',  p_inv_history_tab.lpn_nbr : '||p_inv_history_tab(i).lpn_nbr,1);
      xx_debug_pk.debug(l_debug_sequence||',  p_inv_history_tab.item_code : '||p_inv_history_tab(i).item_code,1);
      BEGIN
        INSERT INTO xx_wms_integration_in 
          ( INTEGRATION_TYPE        
           ,GROUP_NBR  
           ,SEQ_NBR   
           ,FACILITY_CODE  
           ,COMPANY_CODE   
           ,ACTIVITY_CODE  
           ,REASON_CODE    
           ,LOCK_CODE      
           ,LPN_NBR        
           ,LOCATION       
           ,ITEM_CODE      
           ,ITEM_ALTERNATE_CODE 
           ,ITEM_PART_A         
           ,ITEM_PART_B         
           ,ITEM_PART_C         
           ,ITEM_PART_D         
           ,ITEM_PART_E         
           ,ITEM_PART_F         
           ,ITEM_DESCRIPTION    
           ,SHIPMENT_NBR        
           ,TRAILER_NBR         
           ,PO_NBR              
           ,PO_LINE_NBR         
           ,VENDOR_CODE         
           ,ORDER_NBR           
           ,ORDER_SEQ_NBR       
           ,TO_FACILITY_CODE    
           ,ORIG_QTY            
           ,ADJ_QTY           
           ,LPNS_SHIPPED            
           ,UNITS_SHIPPED            
           ,LPNS_RECEIVED           
           ,UNITS_RECEIVED     
           ,REF_CODE_1          
           ,REF_VALUE_1         
           ,REF_CODE_2        
           ,REF_VALUE_2         
           ,REF_CODE_3        
           ,REF_VALUE_3        
           ,REF_CODE_4        
           ,REF_VALUE_4        
           ,REF_CODE_5        
           ,REF_VALUE_5         
           ,CREATE_DATE         
           ,INVN_ATTR_A 
           ,INVN_ATTR_B 
           ,INVN_ATTR_C 
           ,SHIPMENT_LINE_NBR   
           ,SERIAL_NBR          
           ,INVN_ATTR_D         
           ,INVN_ATTR_E         
           ,INVN_ATTR_F          
           ,INVN_ATTR_G          
           ,WORK_ORDER_NBR          
           ,WORK_ORDER_SEQ_NBR      
           ,SCREEN_NAME          
           ,MODULE_NAME          
           ,REF_CODE_6           
           ,REF_VALUE_6           
           ,REF_CODE_7           
           ,REF_VALUE_7           
           ,REF_CODE_8           
           ,REF_VALUE_8           
           ,REF_CODE_9           
           ,REF_VALUE_9           
           ,REF_CODE_10           
           ,REF_VALUE_10           
           ,REF_CODE_11           
           ,REF_VALUE_11           
           ,REF_CODE_12           
           ,REF_VALUE_12           
           ,ORDER_TYPE           
           ,SHIPMENT_TYPE           
           ,PO_TYPE           
           ,BILLING_LOCATION_TYPE           
           ,CREATE_TS           
           ,INVN_ATTR_H           
           ,INVN_ATTR_I           
           ,INVN_ATTR_J           
           ,INVN_ATTR_K           
           ,INVN_ATTR_L           
           ,INVN_ATTR_M           
           ,INVN_ATTR_N           
           ,INVN_ATTR_O           
           ,REF_CODE_13           
           ,REF_VALUE_13           
           ,REF_CODE_14           
           ,REF_VALUE_14           
           ,REF_CODE_15           
           ,REF_VALUE_15           
           ,REF_CODE_16           
           ,REF_VALUE_16           
           ,REF_CODE_17           
           ,REF_VALUE_17           
           ,REF_CODE_18           
           ,REF_VALUE_18           
           ,REF_CODE_19           
           ,REF_VALUE_19           
           ,REF_CODE_20           
           ,REF_VALUE_20           
           ,TO_LOCATION           
           ,MESSAGE_ID              
           ,STATUS                  
           ,ERROR_MESG              
           ,CREATION_DATE           
           ,CREATED_BY              
           ,LAST_UPDATE_DATE        
           ,LAST_UPDATED_BY         
          )
        SELECT p_int_type      -- INTEGRATION_TYPE        
              ,p_inv_history_tab(i).GROUP_NBR  
              ,p_inv_history_tab(i).SEQ_NBR   
              ,p_inv_history_tab(i).FACILITY_CODE  
              ,p_inv_history_tab(i).COMPANY_CODE   
              ,p_inv_history_tab(i).ACTIVITY_CODE  
              ,p_inv_history_tab(i).REASON_CODE    
              ,p_inv_history_tab(i).LOCK_CODE      
              ,p_inv_history_tab(i).LPN_NBR        
              ,p_inv_history_tab(i).LOCATION       
              ,p_inv_history_tab(i).ITEM_CODE      
              ,p_inv_history_tab(i).ITEM_ALTERNATE_CODE 
              ,p_inv_history_tab(i).ITEM_PART_A         
              ,p_inv_history_tab(i).ITEM_PART_B         
              ,p_inv_history_tab(i).ITEM_PART_C         
              ,p_inv_history_tab(i).ITEM_PART_D         
              ,p_inv_history_tab(i).ITEM_PART_E         
              ,p_inv_history_tab(i).ITEM_PART_F         
              ,p_inv_history_tab(i).ITEM_DESCRIPTION    
              ,p_inv_history_tab(i).SHIPMENT_NBR        
              ,p_inv_history_tab(i).TRAILER_NBR         
              ,p_inv_history_tab(i).PO_NBR              
              ,p_inv_history_tab(i).PO_LINE_NBR         
              ,p_inv_history_tab(i).VENDOR_CODE         
              ,p_inv_history_tab(i).ORDER_NBR           
              ,p_inv_history_tab(i).ORDER_SEQ_NBR       
              ,p_inv_history_tab(i).TO_FACILITY_CODE    
              ,p_inv_history_tab(i).ORIG_QTY            
              ,p_inv_history_tab(i).ADJ_QTY           
              ,p_inv_history_tab(i).LPNS_SHIPPED            
              ,p_inv_history_tab(i).UNITS_SHIPPED            
              ,p_inv_history_tab(i).LPNS_RECEIVED           
              ,p_inv_history_tab(i).UNITS_RECEIVED     
              ,p_inv_history_tab(i).REF_CODE_1          
              ,p_inv_history_tab(i).REF_VALUE_1         
              ,p_inv_history_tab(i).REF_CODE_2        
              ,p_inv_history_tab(i).REF_VALUE_2         
              ,p_inv_history_tab(i).REF_CODE_3        
              ,p_inv_history_tab(i).REF_VALUE_3        
              ,p_inv_history_tab(i).REF_CODE_4        
              ,p_inv_history_tab(i).REF_VALUE_4        
              ,p_inv_history_tab(i).REF_CODE_5        
              ,p_inv_history_tab(i).REF_VALUE_5         
              ,p_inv_history_tab(i).CREATE_DATE         
              ,p_inv_history_tab(i).INVN_ATTR_A 
              ,p_inv_history_tab(i).INVN_ATTR_B 
              ,p_inv_history_tab(i).INVN_ATTR_C 
              ,p_inv_history_tab(i).SHIPMENT_LINE_NBR   
              ,p_inv_history_tab(i).SERIAL_NBR          
              ,p_inv_history_tab(i).INVN_ATTR_D         
              ,p_inv_history_tab(i).INVN_ATTR_E         
              ,p_inv_history_tab(i).INVN_ATTR_F          
              ,p_inv_history_tab(i).INVN_ATTR_G          
              ,p_inv_history_tab(i).WORK_ORDER_NBR          
              ,p_inv_history_tab(i).WORK_ORDER_SEQ_NBR      
              ,p_inv_history_tab(i).SCREEN_NAME          
              ,p_inv_history_tab(i).MODULE_NAME          
              ,p_inv_history_tab(i).REF_CODE_6           
              ,p_inv_history_tab(i).REF_VALUE_6           
              ,p_inv_history_tab(i).REF_CODE_7           
              ,p_inv_history_tab(i).REF_VALUE_7           
              ,p_inv_history_tab(i).REF_CODE_8           
              ,p_inv_history_tab(i).REF_VALUE_8           
              ,p_inv_history_tab(i).REF_CODE_9           
              ,p_inv_history_tab(i).REF_VALUE_9           
              ,p_inv_history_tab(i).REF_CODE_10           
              ,p_inv_history_tab(i).REF_VALUE_10           
              ,p_inv_history_tab(i).REF_CODE_11           
              ,p_inv_history_tab(i).REF_VALUE_11           
              ,p_inv_history_tab(i).REF_CODE_12           
              ,p_inv_history_tab(i).REF_VALUE_12           
              ,p_inv_history_tab(i).ORDER_TYPE           
              ,p_inv_history_tab(i).SHIPMENT_TYPE           
              ,p_inv_history_tab(i).PO_TYPE           
              ,p_inv_history_tab(i).BILLING_LOCATION_TYPE           
              ,p_inv_history_tab(i).CREATE_TS           
              ,p_inv_history_tab(i).INVN_ATTR_H           
              ,p_inv_history_tab(i).INVN_ATTR_I           
              ,p_inv_history_tab(i).INVN_ATTR_J           
              ,p_inv_history_tab(i).INVN_ATTR_K           
              ,p_inv_history_tab(i).INVN_ATTR_L           
              ,p_inv_history_tab(i).INVN_ATTR_M           
              ,p_inv_history_tab(i).INVN_ATTR_N           
              ,p_inv_history_tab(i).INVN_ATTR_O           
              ,p_inv_history_tab(i).REF_CODE_13           
              ,p_inv_history_tab(i).REF_VALUE_13           
              ,p_inv_history_tab(i).REF_CODE_14           
              ,p_inv_history_tab(i).REF_VALUE_14           
              ,p_inv_history_tab(i).REF_CODE_15           
              ,p_inv_history_tab(i).REF_VALUE_15           
              ,p_inv_history_tab(i).REF_CODE_16           
              ,p_inv_history_tab(i).REF_VALUE_16           
              ,p_inv_history_tab(i).REF_CODE_17           
              ,p_inv_history_tab(i).REF_VALUE_17           
              ,p_inv_history_tab(i).REF_CODE_18           
              ,p_inv_history_tab(i).REF_VALUE_18           
              ,p_inv_history_tab(i).REF_CODE_19           
              ,p_inv_history_tab(i).REF_VALUE_19           
              ,p_inv_history_tab(i).REF_CODE_20           
              ,p_inv_history_tab(i).REF_VALUE_20           
              ,p_inv_history_tab(i).TO_LOCATION           
              ,p_message_id       --MESSAGE_ID
              ,'NEW'              --STATUS
              ,''                 --MESG_ERROR
              ,sysdate            --CREATION_DATE
              ,fnd_global.user_id --CREATED_BY
              ,sysdate            --LAST_UPDATE_DATE
              ,fnd_global.user_id --LAST_UPDATED_BY
          FROM DUAL
         WHERE NOT EXISTS (SELECT 1
                             FROM xx_wms_integration_in
                            WHERE message_id        = p_message_id
                              AND nvl(lpn_nbr,'X')  = nvl(p_inv_history_tab(i).LPN_NBR,'X')
                              AND group_nbr         = p_inv_history_tab(i).GROUP_NBR
                              AND seq_nbr           = p_inv_history_tab(i).SEQ_NBR
                              AND status           != 'ERROR'
                          );
      EXCEPTION
        WHEN OTHERS THEN
         x_msg_data := 'Error al insertar en xx_wms_integration_in: '||sqlerrm; 
         RAISE e_error;
      END;
    END IF;
  END LOOP;
  COMMIT;
  xx_debug_pk.debug(l_debug_sequence||',  Validate message_id: '||p_message_id,1);
  validate_message_id(p_message_id,l_error_mesg);
  DELETE xx_wms_integration_in
   WHERE message_id = p_message_id
     AND status     = 'ERROR';
  COMMIT;
  IF l_error_mesg IS NOT NULL THEN
    xx_debug_pk.debug(l_debug_sequence||',  update status : '||l_error_mesg,1);

    BEGIN
      update_status(p_status       => 'ERROR'
                   ,p_error_mesg   => l_error_mesg
                   ,p_message_id   => p_message_id
                   ,p_row_id       => '');
    EXCEPTION
      WHEN OTHERS THEN
        x_msg_data := 'Error al actualizar el estado en xx_wms_integration_in: '||sqlerrm;
        RAISE e_error;
    END;
  END IF;

  control_concurrencia(p_message_id,l_error_mesg);
  IF l_error_mesg IS NOT NULL THEN
    xx_debug_pk.debug(l_debug_sequence||',  update status : '||l_error_mesg,1);

    BEGIN
      update_status(p_status       => 'ERROR'
                   ,p_error_mesg   => l_error_mesg
                   ,p_message_id   => p_message_id
                   ,p_row_id       => '');
    EXCEPTION
      WHEN OTHERS THEN
        x_msg_data := 'Error al actualizar el estado en xx_wms_integration_in: '||sqlerrm;
        RAISE e_error;
    END;
  END IF;

  xx_debug_pk.debug(l_debug_sequence||',  LOOP r_trx',1);
  FOR r_trx IN c_trx LOOP
    l_error_mesg := '';
    --l_inv_history_rec := XX_WMS_INV_HISTORY_REC();
    xx_debug_pk.debug(l_debug_sequence||',  r_trx.message_id: '||r_trx.message_id,1);
    xx_debug_pk.debug(l_debug_sequence||',  r_trx.row_id: '||r_trx.row_id,1);
    xx_debug_pk.debug(l_debug_sequence||',  r_trx.activity_code: '||r_trx.activity_code,1);
    xx_debug_pk.debug(l_debug_sequence||',  r_trx.shipment_type: '||r_trx.shipment_type,1);
    xx_debug_pk.debug(l_debug_sequence||',  r_trx.ref_value_4: '||r_trx.ref_value_4,1);
    l_inv_history_rec.activity_code     := r_trx.activity_code;
    l_inv_history_rec.group_nbr         := r_trx.group_nbr;
    l_inv_history_rec.shipment_nbr      := r_trx.shipment_nbr;
    l_inv_history_rec.invn_attr_c       := r_trx.invn_attr_c;
    l_inv_history_rec.item_code         := r_trx.item_code;
    l_inv_history_rec.facility_code     := r_trx.facility_code;
    l_inv_history_rec.lock_code         := r_trx.lock_code;
    l_inv_history_rec.units_received    := r_trx.units_received;
    l_inv_history_rec.ref_value_3       := r_trx.ref_value_3;
    l_inv_history_rec.ref_value_4       := r_trx.ref_value_4;
    l_inv_history_rec.lpn_nbr           := r_trx.lpn_nbr;
    l_inv_history_rec.create_ts         := r_trx.create_ts;
    l_inv_history_rec.reason_code       := r_trx.reason_code;
    l_inv_history_rec.adj_qty           := r_trx.adj_qty;
    l_inv_history_rec.ref_value_1       := r_trx.ref_value_1;
    l_inv_history_rec.ref_value_2       := r_trx.ref_value_2;
    l_inv_history_rec.orig_qty          := r_trx.orig_qty;
    l_inv_history_rec.invn_attr_a       := r_trx.invn_attr_a;

    IF r_trx.activity_code = 1 AND
       r_trx.shipment_type = 'PROD' THEN  
      -- Declaracion de produccion
      xx_wms_int_in_trx_pk.product_declaration(l_inv_history_rec
                                              ,l_error_mesg);
    ELSIF r_trx.activity_code IN (4, 17, 19, 39, 40, 53) AND
          r_trx.reason_code IS NOT NULL THEN
      -- Ajuste Stock
      xx_wms_int_in_trx_pk.stock_adjustment(l_inv_history_rec
                                           ,l_error_mesg);
    ELSIF r_trx.activity_code IN (22, 23, 24, 25) THEN
      -- Bloqueo de Lote/LPN
      xx_wms_int_in_trx_pk.block_lot_lpn(l_inv_history_rec
                                        ,l_error_mesg);
    ELSIF r_trx.activity_code = 1 AND
       r_trx.shipment_type = 'DEV' THEN  
      -- Recepcion RMA
      xx_wms_int_in_trx_pk.RMA_receipt(l_inv_history_rec
                                      ,l_error_mesg);
    ELSE
      l_error_mesg := 'No es un tipo de transaccion contemplado';
    END IF;
      
    xx_debug_pk.debug(l_debug_sequence||', l_error_mesg: '||l_error_mesg,1);

    IF l_error_mesg IS NOT NULL THEN
      xx_debug_pk.debug(l_debug_sequence||',  update status : '||l_error_mesg,1);
      ROLLBACK;
      BEGIN
        update_status(p_status       => 'ERROR'
                     ,p_error_mesg   => l_error_mesg
                     ,p_message_id   => r_trx.message_id
                     ,p_row_id       => r_trx.row_id);
      EXCEPTION
        WHEN OTHERS THEN
          x_msg_data := 'Error al actualizar el estado en xx_wms_integration_in: '||sqlerrm;
          RAISE e_error;
      END;
    ELSE
      BEGIN
        update_status(p_status       => 'OK'
                     ,p_error_mesg   => null
                     ,p_message_id   => r_trx.message_id
                     ,p_row_id       => r_trx.row_id);
      EXCEPTION
        WHEN OTHERS THEN
          x_msg_data := 'Error al actualizar el estado en xx_wms_integration_in: '||sqlerrm;
          RAISE e_error;
      END;
    END IF;
  END LOOP;

  BEGIN
    SELECT count(1)
      INTO l_error_count
      FROM xx_wms_integration_in xwii
     WHERE xwii.message_id = p_message_id
       AND xwii.status = 'ERROR';
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error buscando errores en xx_wms_integration_in '||sqlerrm;
      RAISE e_error;
  END;
  xx_debug_pk.debug(l_debug_sequence||', l_error_count: '||l_error_count,1);
  IF l_error_count = 0 THEN
    x_return_status := 'S';
    COMMIT;
    -- No se hace submit, se espera el procesador de recepcion
    submit_RMA_processor(p_message_id, x_msg_data);
  ELSE
    x_msg_data := 'Errores en xx_wms_integration_in ';
    x_return_status := 'E';
    ROLLBACK;
    /*
    --Actualizo las lineas que estaban OK con ERROR
    BEGIN
      UPDATE xx_wms_integration_in xwii
         SET status           = 'ERROR'
            ,last_update_date = sysdate
        WHERE xwii.message_id = p_message_id
          AND xwii.status     = 'OK';
    EXCEPTION
      WHEN OTHERS THEN
        x_msg_data := 'Error al actualizar el estado en xx_wms_integration_in: '||sqlerrm;
        RAISE e_error;
    END;
    */
  END IF;
END IF;
xx_debug_pk.debug(l_debug_sequence||', Fin',1);

EXCEPTION
  WHEN e_error THEN
    xx_debug_pk.debug(l_debug_sequence||'e_error ',1);
    x_return_status := 'E';
    update_status(p_status       => 'ERROR'
                 ,p_error_mesg   => x_msg_data
                 ,p_message_id   => p_message_id
                 ,p_row_id       => null);
    ROLLBACK;
  WHEN OTHERS THEN
    x_return_status := 'E';
    x_msg_data := 'Error: '||sqlerrm;
    xx_debug_pk.debug(l_debug_sequence||'x_msg_data: '||x_msg_data,1);
    update_status(p_status       => 'ERROR'
                 ,p_error_mesg   => x_msg_data
                 ,p_message_id   => p_message_id
                 ,p_row_id       => null);
    ROLLBACK;
    xx_debug_pk.debug(l_debug_sequence||',  error : '||x_msg_data,1);
END process_integration;

PROCEDURE process_integration_line
(p_int_type                  IN  VARCHAR2
,p_message_id                IN  VARCHAR2
,p_group_nbr                 IN VARCHAR2      
,p_seq_nbr                   IN NUMBER       
,p_facility_code                 IN VARCHAR2           
,p_company_code                  IN VARCHAR2                
,p_activity_code                 IN VARCHAR2           
,p_reason_code                   IN VARCHAR2
,p_lock_code                     IN VARCHAR2
,p_lpn_nbr                       IN VARCHAR2
,p_location                      IN VARCHAR2                          
,p_item_code                     IN VARCHAR2 
,p_item_alternate_code                IN VARCHAR2                        
,p_item_part_a                        IN VARCHAR2
,p_item_part_b                        IN VARCHAR2
,p_item_part_c                        IN VARCHAR2
,p_item_part_d                        IN VARCHAR2
,p_item_part_e                        IN VARCHAR2
,p_item_part_f                        IN VARCHAR2
,p_item_description                   IN VARCHAR2
,p_shipment_nbr                        IN VARCHAR2                  
,p_trailer_nbr                         IN NUMBER            
,p_po_nbr                              IN NUMBER
,p_po_line_nbr                         IN NUMBER
,p_vendor_code                        IN VARCHAR2
,p_order_nbr                          IN VARCHAR2
,p_order_seq_nbr                       IN NUMBER            
,p_to_facility_code                   IN VARCHAR2
,p_orig_qty                            IN NUMBER
,p_adj_qty                           IN NUMBER
,p_lpns_shipped                            IN NUMBER
,p_units_shipped                            IN NUMBER
,p_lpns_received                           IN NUMBER 
,p_units_received                     IN NUMBER             
,p_ref_code_1                         IN VARCHAR2
,p_ref_value_1                        IN VARCHAR2
,p_ref_code_2                       IN VARCHAR2
,p_ref_value_2                        IN VARCHAR2
,p_ref_code_3                       IN VARCHAR2
,p_ref_value_3                       IN VARCHAR2
,p_ref_code_4                       IN VARCHAR2
,p_ref_value_4                       IN VARCHAR2
,p_ref_code_5                       IN VARCHAR2
,p_ref_value_5                        IN VARCHAR2
,p_create_date                        IN VARCHAR2        
,p_invn_attr_a                IN VARCHAR2
,p_invn_attr_b                IN VARCHAR2
,p_invn_attr_c                IN VARCHAR2
,p_shipment_line_nbr                   IN NUMBER                      
,p_serial_nbr                         IN VARCHAR2
,p_invn_attr_d                        IN VARCHAR2
,p_invn_attr_e                        IN VARCHAR2
,p_invn_attr_f                         IN VARCHAR2
,p_invn_attr_g                         IN VARCHAR2
,p_work_order_nbr                         IN VARCHAR2
,p_work_order_seq_nbr                      IN NUMBER 
,x_request_id                OUT NUMBER
,x_return_status             OUT VARCHAR2
,x_msg_data                  OUT VARCHAR2
)IS
BEGIN
    xx_debug_pk.force_on(p_output          => 'DB_TABLE'
                     ,p_level           => 1
                     ,p_directory       => NULL
                     ,p_file            => NULL
                     ,p_other_statement => NULL
                     ,p_message_length  => 4000
                     );

    xx_debug_pk.debug('XX Inicio',1);

    xx_debug_pk.debug('XX int_type : '||p_int_type,1);
    xx_debug_pk.debug('XX message_id : '||p_message_id,1);
    xx_debug_pk.debug('XX group_nbr : '||p_group_nbr,1);
    xx_debug_pk.debug('XX seq_nbr : '||p_seq_nbr,1);
    xx_debug_pk.debug('XX lpn_nbr : '||p_lpn_nbr,1);
    xx_debug_pk.debug('XX item_code : '||p_item_code,1);
    xx_debug_pk.debug('XX p_SHIPMENT_NBR : '||p_SHIPMENT_NBR,1);


x_return_status := 'S';
x_request_id := 9999;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
    x_msg_data := 'Error: '||sqlerrm;
    xx_debug_pk.debug('XX error : '||x_msg_data,1);
END process_integration_line;
END xx_wms_int_in_pk;
/
show err
spool off
--exit
