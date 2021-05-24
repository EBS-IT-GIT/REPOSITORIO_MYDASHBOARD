CREATE OR REPLACE PROCEDURE APPS."XX_CARGA_CP_BI" (p_carga_desde number)
AS
   CP_typereg    ADECO_BI.xx_tcg_cartas_porte_v2_BI%ROWTYPE;
   CPAP_typereg  ADECO_BI.xx_tcg_cartas_porte_AP%ROWTYPE;


   CURSOR CP_cur
   IS
 SELECT CARTA_PORTE_ID,
       ORG_ID,
       OPERATING_UNIT,
       NUMERO_CARTA_PORTE,
       CARTA_PORTE_RELACIONADA,
       ITEM_ID,
       ITEM_NO,
       ITEM_DESC,
       ITEM_ONCCA_CODE,
       ITEM_ONCCA_ESPECIE,
       LOT_NO,
       TIPO_GRANO,
       TIPO_GRANO_DESC,
       OBSERVACIONES,
       PESAJE_ENTRADA_FLAG,
       PESAJE_SALIDA_FLAG,
       TRANSFERIDO_FLAG,
       RECIBIDO_FLAG,
       ANULADO_FLAG,
       TITULAR_CP_ID,
       TITULAR_CP,
       TITULAR_CP_CUIT,
       TITULAR_CP_TIPO,
       TITULAR_CP_ESTAB_ID,
       TITULAR_CP_ESTAB_DESC,
       TITULAR_CP_ESTAB_ONCCA_CODE,
       TITULAR_CP_UBICACION,
       TITULAR_CP_UBICACION_DESC,
       TITULAR_CP_PROVINCIA,
       TITULAR_CP_PROVINCIA_DESC,
       TITULAR_CP_LOCALIDAD,
       TITULAR_CP_LOCALIDAD_DESC,
       TITULAR_CP_DIRECCION,
       TITULAR_CP_ZONA,
       TITULAR_CP_CONTRATO_ID,
       TITULAR_CP_CONTRATO,
       INTERMEDIARIO_ID,
       INTERMEDIARIO,
       INTERMEDIARIO_CUIT,
       INTERMEDIARIO_TIPO,
       INTERMEDIARIO_RETIRO,
       INTERMEDIARIO_CONTRATO_ID,
       INTERMEDIARIO_CONTRATO,
       RTTE_COMERCIAL_ID,
       RTTE_COMERCIAL,
       RTTE_COMERCIAL_CUIT,
       RTTE_COMERCIAL_TIPO,
       RTTE_COMERCIAL_RETIRO,
       RTTE_COMERCIAL_CONTRATO_ID,
       RTTE_COMERCIAL_CONTRATO,
       CORREDOR_ID,
       CORREDOR,
       CORREDOR_CUIT,
       MERCADO_TERMINO_ID,
       MERCADO_TERMINO,
       MERCADO_TERMINO_CUIT,
       CORREDOR_VENDEDOR_ID,
       CORREDOR_VENDEDOR,
       CORREDOR_VENDEDOR_CUIT,
       REPRESENTANTE_ID,
       REPRESENTANTE,
       REPRESENTANTE_CUIT,
       DESTINATARIO_ID,
       DESTINATARIO,
       DESTINATARIO_CUIT,
       DESTINATARIO_CONTRATO_ID,
       DESTINATARIO_CONTRATO,
       DESTINO_ID,
       DESTINO,
       DESTINO_CUIT,
       DESTINO_ESTAB_ID,
       DESTINO_ESTAB_DESC,
       DESTINO_ESTAB_ONCCA_CODE,
       DESTINO_UBICACION,
       DESTINO_UBICACION_DESC,
       DESTINO_PROVINCIA,
       DESTINO_PROVINCIA_DESC,
       DESTINO_LOCALIDAD,
       DESTINO_LOCALIDAD_DESC,
       DESTINO_DIRECCION,
       DESTINO_ZONA,
       CEE_NUMERO,
       CEE_FECHA_VENCIMIENTO,
       COT_NUMERO,
       RENSPA,
       CTG_NUMERO,
       CUPO,
       MOTIVO_RECHAZO,
       CARRIER_SERVICE_ID,
       SHIP_METHOD_MEANING,
       TRANSPORTISTA_NOMBRE,
       TRANSPORTISTA_CUIT,
       CHOFER,
       CUIL,
       SUBCONTRATADO,
       PATENTE_CAMION,
       PATENTE_ACOPLADO,
       INTERMEDIARIO_FLETE_ID,
       INTERMEDIARIO_FLETE,
       INTERMEDIARIO_FLETE_CUIT,
       VIAJE_ID,
       TURNO_VIAJE,
       QR,
       PROCEDENCIA_ENGANCHADA,
       DISTANCIA_ID,
       TARIFA_NEGOCIACION_ID,
       FECHA_CALC_DISTANCIA,
       DISTANCIA_ESTIMADA,
       TARIFA_REF_FLETE_XTON,
       COSTO_FLETE_XTON,
       COSTO_FLETE,
       COSTO_FLETE_CURRENCY_CODE,
       TARIFA_CP_XTON,
       PROVISIONAR_FLETE_FLAG,
       PROVISIONADO_FLAG,
       CUENTA_GASTO_PROVISION,
       CUENTA_GASTO_PAGO,
       REFACTURAR_FLETE_FLAG,
       REFACTURADO_FLAG,
       PAGADOR_FLETE_ID,
       PAGADOR_FLETE_DESC,
       PROVISIONADO_POR,
       PROVISIONADO_POR_DESC,
       FECHA_DISPONIBLE_TRANSPORTE,
       FIN_CARGA_TRANSPORTE,
       TOTAL_UNIDADES_TRANSPORTE,
       NUMERO_PEDIDO_TRANSPORTE,
       NUMERO_OPERATIVO_TRANSPORTE,
       NUMERO_GUIA_TRANSPORTE,
       ESTACION_TRANSPORTE,
       OBSERVACION_TRANSPORTE,
       ID_FACTURA_AP,
       TICKET_ENVIO_ID,
       FECHA_ENVIO,
       FECHA_CARGA,
       CANTIDAD_HORAS,
       TICKET_ENVIO_NUMERO,
       TARA_ENVIO,
       PESO_BRUTO_ENVIO,
       PESO_NETO_ENVIO,
       PESO_ESTIMADO,
       PESO_TRANSFERIDO,
       LOTE,
       VARIEDAD,
       PROYECTO_ID,
       TAREA_ID,
       TIPO_EROGACION,
       PCTAJE_HUMEDAD_ESTIMADA,
       PCTAJE_MERMA_HUMEDAD_ENVIO,
       PESO_HUMEDAD_ESTIMADA,
       PCTAJE_MATERIA_EXTRANIA_ENVIO,
       PESO_MATERIA_EXTRANIA_ENVIO,
       TIPO_CALIDAD_ENVIO,
       TICKET_RECEPCION_ID,
       TICKET_RECEPCION_NUMERO,
       FECHA_RECEPCION,
       PESO_BRUTO_RECEPCION,
       TARA_RECEPCION,
       PESO_NETO_RECEPCION,
       INSECTOS_VIVOS_FLAG,
       PCTAJE_HUMEDAD_RECEP,
       PCTAJE_MERMA_HUMEDAD_RECEP,
       PESO_MERMA_HUMEDAD_RECEP,
       PCTAJE_ZARANDA_RECEP,
       PESO_MERMA_ZARANDA_RECEP,
       PCTAJE_VOLATIL_RECEP,
       PESO_MERMA_VOLATIL_RECEP,
       PCTAJE_OTROS_RECEP,
       PESO_MERMA_OTROS_RECEP,
       PCTAJE_MATERIA_EXTRANIA_RECEP,
       PESO_MERMA_MATERIA_EXT_RECEP,
       PESO_APLICADO_RECEP,
       PCTAJE_HUMEDAD_COMPRA,
       PCTAJE_MERMA_HUMEDAD_COMPRA,
       PESO_MERMA_HUMEDAD_COMPRA,
       PCTAJE_ZARANDA_COMPRA,
       PESO_MERMA_ZARANDA_COMPRA,
       PCTAJE_VOLATIL_COMPRA,
       PESO_MERMA_VOLATIL_COMPRA,
       PCTAJE_OTROS_COMPRA,
       PESO_MERMA_OTROS_COMPRA,
       PESO_APLICADO_COMPRA,
       PROVISION_REQUEST_ID,
       UO_CERTIFICA,
       UO_BOLETIN,
       MERMA_HEADER_ID,
       GASTOS_ACOND_CALCULADOS_FLAG,
       FECHA_IMPRESION,
       ATTRIBUTE_CATEGORY,
       ATTRIBUTE1,
       ATTRIBUTE2,
       ATTRIBUTE3,
       ATTRIBUTE4,
       ATTRIBUTE5,
       ATTRIBUTE6,
       ATTRIBUTE7,
       ATTRIBUTE8,
       ATTRIBUTE9,
       ATTRIBUTE10,
       ATTRIBUTE11,
       ATTRIBUTE12,
       ATTRIBUTE13,
       ATTRIBUTE14,
       ATTRIBUTE15,
       CREATED_BY,
       USER_NAME,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       NUMERO_BOLETIN,
       FACTOR,
       GRADO,
       BOLETIN_HEADER_ID,
       LIQUIDACION_ID,
       NUMERO_LIQUIDACION,
       FECHA_LIQUIDACION,
       LIQUIDACION_RT_ID,
       LIQUIDACION_RT_NUMERO,
       LIQUIDACION_RT_FECHA
       FROM xx_tcg_cartas_porte_v2              
       WHERE (
             (
             pesaje_entrada_flag = 'N'
         AND pesaje_salida_flag = 'N'
             )
          OR (
               anulado_flag = 'Y'
            AND (
                pesaje_entrada_flag = 'Y'
             OR pesaje_salida_flag  = 'Y'          
                )
              )
             )
         AND last_update_date > sysdate -  p_carga_desde;


         CURSOR CPAP_c IS                                                                    
              SELECT REPLACE (acp.tipo_erogacion,
                              'CP_NO_PROVISIONADAS',
                              'FLETE')
                     tipo_erogacion,
                     ai.invoice_num nro_factura,
                     cbi.carta_porte_id,
                     SUM (acp.importe_gasto) importe_gasto,
                     acp.creation_date 
                FROM apps.xx_ap_asocia_cartas_porte acp,
                     apps.ap_invoices_all ai,
                     ADECO_BI.xx_tcg_cartas_porte_v2_BI cbi
               WHERE 1 = 1
                     AND ai.invoice_id = acp.invoice_id
                     AND acp.carta_porte_id = cbi.carta_porte_id
                     AND acp.tipo_erogacion in ('CP_NO_PROVISIONADAS','FLETE')
                     AND acp.creation_date > SYSDATE - 2
                     AND NOT EXISTS ( SELECT 1 
                                        FROM apps.xx_po_asocia_remitos xpar
                                       WHERE xpar.tipo_erogacion = 'FLETE'
                                         AND xpar.clave_id       = acp.carta_porte_id
                                     )
               GROUP BY REPLACE (acp.tipo_erogacion,
                                 'CP_NO_PROVISIONADAS',
                                 'FLETE'),
                         ai.invoice_num,
                         cbi.carta_porte_id, 
                         acp.creation_date                                                                           
              UNION ALL           
              SELECT tipo_erogacion, 
                     nro_factura,
                     carta_porte_id,
                     importe_gasto,
                     creation_date
                FROM (
                          SELECT xpar.tipo_erogacion,
                                 MAX(ai.invoice_num) nro_factura, 
                                 xpar.clave_id carta_porte_id,
                                 SUM(aid.amount) importe_gasto,
                                 MAX(xpar.creation_date) creation_date
                            FROM xx_po_asocia_remitos xpar,
                                 po_headers_all ph,
                                 po_lines_all pl,
                                 ap_invoice_distributions_all aid,
                                 po_distributions_all pd,
                                 ap_invoices_all ai
                           WHERE xpar.po_header_id = ph.po_header_id
                             AND NVL (ph.cancel_flag, 'N') = 'N'
                             AND pl.po_header_id = xpar.po_header_id
                             AND pl.po_line_id = xpar.po_line_id
                             AND aid.po_distribution_id = pd.po_distribution_id
                             AND pd.po_header_id = xpar.po_header_id
                             AND pd.po_line_id = xpar.po_line_id
                             AND ai.invoice_id = aid.invoice_id
                             AND aid.amount                <> 0
                             AND aid.line_type_lookup_code = 'ITEM'
                             AND xpar.tipo_documento       = 'TCG'
                             AND xpar.tipo_erogacion       = 'FLETE'
                             AND xpar.creation_date > SYSDATE - 5
                          GROUP BY xpar.tipo_erogacion, 
                                   xpar.clave_id
                         )
                    WHERE importe_gasto <> 0;


BEGIN

   execute immediate ('alter session set nls_language=''LATIN AMERICAN SPANISH''');

   OPEN CP_cur;

   LOOP
      FETCH CP_cur INTO cp_typereg;

      BEGIN
         INSERT INTO ADECO_BI.xx_tcg_cartas_porte_v2_BI
              VALUES cp_typereg;
      EXCEPTION
         WHEN OTHERS
         THEN

            IF cp_Typereg.carta_porte_id IS NOT NULL THEN 

               DELETE ADECO_BI.xx_tcg_cartas_porte_v2_BI
                WHERE carta_porte_id = cp_Typereg.carta_porte_id;

                INSERT INTO ADECO_BI.xx_tcg_cartas_porte_v2_BI
                       VALUES cp_typereg;

             END IF;
      END;

    EXIT WHEN CP_cur%NOTFOUND;
   END LOOP;

  CLOSE CP_cur;


 OPEN CPAP_c;

   LOOP
      FETCH CPAP_c INTO cpap_typereg;

      BEGIN
         INSERT INTO ADECO_BI.xx_tcg_cartas_porte_AP
              VALUES CPAP_typereg;

      EXCEPTION
         WHEN OTHERS
         THEN

            DELETE ADECO_BI.xx_tcg_cartas_porte_AP
             WHERE carta_porte_id = cpap_typereg.carta_porte_id;

            INSERT INTO ADECO_BI.xx_tcg_cartas_porte_AP
                 VALUES cpap_typereg;

      END;      


    EXIT WHEN CPAP_c%NOTFOUND;

   END LOOP;

  CLOSE CPAP_c;


     --Inserta QRs 

    execute immediate ( 'truncate table bolinf.XX_BI_QRS_CP ');


   INSERT INTO  bolinf.XX_BI_QRS_CP 
     SELECT qr_id,
            clasificacion,
            vendor_num    NroProveedor,
            vendor_name  Proveedor,
            vendor_cuit     CUIT,
            tipo_vehiculo,
            patente_veh_maq patente_chasis,
            xvpch.subcontratado sub_ch,
            TO_CHAR(xvpch.vencimiento_vtv,'DD/MM/YYYY') vto_vtv_ch,
            TO_CHAR(xvpch.vencimiento_ruta,'DD/MM/YYYY') vto_ruta_ch,
            TO_CHAR(xvpch.vencimiento_seguro,'DD/MM/YYYY') vto_seg_ch,
            TO_CHAR(xvpch.vto_seguro_carga,'DD/MM/YYYY') vto_seg_car_ch,
            xvpch.monto_seguro_carga mto_seg_car_ch,
            xvpch.codigo_senasa cod_senasa_ch,
            TO_CHAR(xvpch.vencimiento_senasa,'DD/MM/YYYY') vto_sen_ch,
            TO_CHAR(xvpch.vencimiento_assal,'DD/MM/YYYY') vto_assal_ch,
            TO_CHAR(xvpch.creation_date,'dd/mm/yyyy') FechaCreaChasis,
            TO_CHAR(xvpch.last_update_date,'dd/mm/yyyy') FechaModifChasis,                        
            xvpch.status status_ch,     
            patente_acoplado,
            xvpac.subcontratado sub_acop,            
            TO_CHAR(xvpac.vencimiento_vtv,'DD/MM/YYYY') vto_vtv_acop,
            TO_CHAR(xvpac.vencimiento_ruta,'DD/MM/YYYY') vto_ruta_acop,
            TO_CHAR(xvpac.vencimiento_seguro,'DD/MM/YYYY') vto_seg_acop,
            TO_CHAR(xvpac.vto_seguro_carga,'DD/MM/YYYY') vto_seg_car_acop,
            xvpac.monto_seguro_carga mto_seg_car_acop,
            xvpac.codigo_senasa co_senasa_acop,
            TO_CHAR(xvpac.vencimiento_senasa,'DD/MM/YYYY') vto_sen_acop,
            TO_CHAR(xvpac.vencimiento_assal,'DD/MM/YYYY') vto_assal_acop,
            TO_CHAR(xvpac.creation_date,'dd/mm/yyyy') FechaCreaAcop,
            TO_CHAR(xvpac.last_update_date,'dd/mm/yyyy') FechaModifAcop,                        
            xvpac.status status_acop,                                    
            xqr.tipo_empleado,
            empleado_nombre,
            empleado_cuil  CUIL,
            empleado_nacionalidad,
            xep.telefono,
            TO_CHAR(xep.vto_licencia,'DD/MM/YYYY') vto_licencia, 
            TO_CHAR(xep.vencimiento_cnrt,'DD/MM/YYYY') vencimiento_cnrt,
            TO_CHAR(xep.vencimiento_art,'DD/MM/YYYY') vencimiento_art,
            TO_CHAR(xep.creation_date,'dd/mm/yyyy') FechaCreaChofer,
            TO_CHAR(xep.last_update_date,'dd/mm/yyyy') FechaModifChofer,
            xep.status estadoempl,
            status_dsp  estado,
            documentacion,
            documentacion_72,
            fecha_ult_impresion,
            carga_combustible_flag,
            habilitado ,
            TO_CHAR(xqr.creation_date,'dd/mm/yyyy') FechaCreaQR,
            TO_CHAR(xqr.last_update_date,'dd/mm/yyyy') FechaModifQR,
            xqr.carrier_service_id 
  FROM apps.XX_OPM_QR_PROVEEDORES_V          xqr,
           apps.XX_OPM_EMPLEADOS_PROVEEDORES xep,
           apps.XX_OPM_VEHICULOS_PROVEEDORES  xvpch,
           apps.XX_OPM_VEHICULOS_PROVEEDORES  xvpac           
  WHERE grupo_control = '01'
      AND xep.empleado_id (+)     = xqr.empleado_id
      AND xvpch.vehiculo_id      = xqr.vehiculo_id
      AND xvpac.vehiculo_id (+)   = xqr.acoplado_id;



  execute immediate ( 'truncate table bolinf.XX_CP_LOGISTICA ');


-- DEMANDA CAMPOS 
INSERT INTO bolinf.XX_CP_LOGISTICA 
SELECT 'DEMANDA' tipo, 
       xdc.fecha_carga fecha, 
       DECODE(xoe.establecimiento_id, 140, (SELECT campo FROM xx_opm_establecimientos WHERE establecimiento_id = 59) , 
                                      xoe.campo ||                                           
                                      (SELECT '_'||flv.description
                                         FROM apps.fnd_lookup_values  flv
                                        WHERE flv.lookup_code  = xdc.condicion
                                          AND flv.lookup_type  = 'XX_TCG_CONDICION_CUPOS' 
                                          AND flv.language     = 'ESA'
                                          AND flv.description  = 'Interno')                                                                                                                                                                              
                                       ) campoagr,   
       xoe.campo ||                                           
       (SELECT '_'||flv.description
          FROM apps.fnd_lookup_values  flv
         WHERE flv.lookup_code  = xdc.condicion
           AND flv.lookup_type  = 'XX_TCG_CONDICION_CUPOS' 
           AND flv.language     = 'ESA'
           AND flv.description  = 'Interno')                                                                                                                                                                              
       campo,  
       cantidad_solicitada, 
       msi_dfv.xx_tcg_tipos tipo_estab, 
       NULL qr_id,
       NULL turno, 
       'CANTIDAD DE CAMIONES PEDIDOS' concepto ,
       1 orden, TRUNC(sysdate) fecha_join
  FROM xx_tcg_demanda_camiones       xdc
     , xx_opm_establecimientos       xoe     
     , mtl_secondary_inventories     msi  
     , mtl_secondary_inventories_dfv msi_dfv   
     , xx_tcg_parametros_compania    pc  
     , org_organization_definitions  od                       
 WHERE 1=1
   AND msi_dfv.row_id         = msi.rowid  
   AND xdc.item_oncca_code    = '021'
   AND xdc.empresa_estab_id   =  xoe.establecimiento_id 
   AND xoe.establecimiento_id = msi_dfv.xx_tcg_establecimientos
   AND pc.operating_unit_cuit = xdc.empresa_cuit
   AND pc.operating_unit      = od.operating_unit  
   AND msi.organization_id    = od.organization_id  
   AND msi_dfv.xx_tcg_tipos   = 'CAMPO'           
UNION ALL
-- ARRIBOS CAMPOS
SELECT xar.tipo, 
       xar.fecha, 
       DECODE(xar.establecimiento_id, 140, (SELECT campo FROM xx_opm_establecimientos WHERE establecimiento_id = 59) , xoe.campo) || xar.condicion campoagr, 
       xoe.campo || xar.condicion campo,                         
       xar.cantidad, 
       xar.tipo_estab, 
       xar.qr_id,            
       xar.turno, 
       xar.concepto, 
       xar.orden , TRUNC(sysdate) fecha_join
  FROM
      (      
       SELECT 'ARRIBO' tipo,  xvs.fecha fecha, xvi.estab_lectura_id establecimiento_id, 1 CANTIDAD, 'CAMPO' Tipo_Estab, xvi.qr_id, 
              'MA' Turno, 'Cantidad de Camiones En Playa 00:00 - 07:59' Concepto , 2 orden,
              (SELECT '_'||flv.description
                 FROM apps.fnd_lookup_values  flv
                WHERE flv.lookup_code  = xvi.condicion
                  AND flv.lookup_type  = 'XX_TCG_CONDICION_CUPOS' 
                  AND flv.language     = 'ESA'
                  AND flv.description  = 'Interno') Condicion   
         FROM apps.xx_tcg_control_viajes          xvi
            , apps.xx_tcg_control_viajes_status   xvs            
        WHERE xvi.creation_date          > TO_DATE('01/01/2020','dd/mm/yyyy')      
          AND  xvi.viaje_id              = xvs.viaje_id
          AND xvs.estado_transporte      = 'ACEPTADO'
          AND xvi.codigo_oncca           = '021'
          AND TO_NUMBER(TO_CHAR(XVS.FECHA, 'HH24')) BETWEEN 0 AND 7.99         
       UNION ALL       
       SELECT 'ARRIBO' tipo,  xvs.fecha fecha, xvi.estab_lectura_id establecimiento_id, 1 CANTIDAD, 'CAMPO' Tipo_Estab, xvi.qr_id, 
              'ME' Turno,  'Cantidad de Camiones En Playa 08:00 - 16:59' Concepto , 3 orden,
              (SELECT '_'||flv.description
                 FROM apps.fnd_lookup_values  flv
                WHERE flv.lookup_code  = xvi.condicion
                  AND flv.lookup_type  = 'XX_TCG_CONDICION_CUPOS' 
                  AND flv.language     = 'ESA'
                  AND flv.description  = 'Interno') Condicion 
         FROM apps.xx_tcg_control_viajes          xvi
            , apps.xx_tcg_control_viajes_status   xvs    
        WHERE xvi.creation_date       > TO_DATE('01/01/2020','dd/mm/yyyy')
          AND  xvi.viaje_id           = xvs.viaje_id
          AND xvs.estado_transporte   = 'ACEPTADO'
          AND xvi.codigo_oncca        = '021'
          AND TO_NUMBER(TO_CHAR(XVS.FECHA, 'HH24')) BETWEEN 8 AND 16.99          
       UNION ALL      
       SELECT 'ARRIBO' tipo,   TRUNC(xvs.fecha) + 1.00001 fecha, xvi.estab_lectura_id establecimiento_id, 1 CANTIDAD, 'CAMPO' Tipo_Estab, xvi.qr_id, 
              'MA' Turno , 'Cantidad de Camiones En Playa 17:00 - 23:59' Concepto , 4 orden,
              (SELECT '_'||flv.description
                FROM apps.fnd_lookup_values  flv
                WHERE flv.lookup_code  = xvi.condicion
                  AND flv.lookup_type  = 'XX_TCG_CONDICION_CUPOS' 
                  AND flv.language     = 'ESA'
                  AND flv.description  = 'Interno') Condicion 
         FROM apps.xx_tcg_control_viajes             xvi
            , apps.xx_tcg_control_viajes_status   xvs     
        WHERE xvi.creation_date          > TO_DATE('01/01/2020','dd/mm/yyyy')
          AND  xvi.viaje_id              = xvs.viaje_id
          AND xvs.estado_transporte      = 'ACEPTADO'
          AND xvi.codigo_oncca           = '021'     
          AND TO_NUMBER(TO_CHAR(XVS.FECHA, 'HH24')) BETWEEN 17 AND 24          
      ) xar
     , xx_opm_establecimientos         xoe   
 WHERE xar.establecimiento_id = xoe.establecimiento_id  
UNION ALL
-- TOTAL ARRIBO
SELECT tipo, 
       fecha, 
       DECODE(xtar.establecimiento_id, 140, (SELECT campo FROM xx_opm_establecimientos WHERE establecimiento_id = 59) , xoe.campo) || xtar.condicion campoagr, 
       xoe.campo || xtar.condicion campo,               
       cantidad, 
       tipo_estab, 
       NULL qr_id,
       turno, 
       concepto, 
       orden, TRUNC(sysdate) fecha_join
  FROM
      (
       SELECT 'TOTAL_ARRIBO' tipo,  xvs.fecha,  xvi.estab_lectura_id establecimiento_id, 1 CANTIDAD, 'CAMPO' Tipo_Estab,  
              'MA' Turno, 'TOTAL DE CAMIONES DISPONIBLES' Concepto , 5 orden,
              (SELECT '_'||flv.description
                FROM apps.fnd_lookup_values  flv
                WHERE flv.lookup_code  = xvi.condicion
                  AND flv.lookup_type  = 'XX_TCG_CONDICION_CUPOS' 
                  AND flv.language     = 'ESA'
                  AND flv.description  = 'Interno') Condicion               
         FROM apps.xx_tcg_control_viajes          xvi
            , apps.xx_tcg_control_viajes_status   xvs     
        WHERE xvi.creation_date         > TO_DATE('01/01/2020','dd/mm/yyyy')
          AND xvi.viaje_id              = xvs.viaje_id
          AND xvs.estado_transporte     = 'ACEPTADO'
          AND xvi.codigo_oncca          = '021'
          AND TO_NUMBER(TO_CHAR(XVS.FECHA, 'HH24')) BETWEEN 0 AND 16.99
        UNION ALL
       SELECT 'TOTAL_ARRIBO' tipo,  TRUNC(xvs.fecha) + 1.00001 fecha,  xvi.estab_lectura_id establecimiento_id, 1 CANTIDAD, 'CAMPO' Tipo_Estab,  
              'MA' Turno, 'TOTAL DE CAMIONES DISPONIBLES' Concepto , 5 orden,
              (SELECT '_'||flv.description
                FROM apps.fnd_lookup_values  flv
                WHERE flv.lookup_code  = xvi.condicion
                  AND flv.lookup_type  = 'XX_TCG_CONDICION_CUPOS' 
                  AND flv.language     = 'ESA'
                  AND flv.description  = 'Interno') Condicion                 
         FROM apps.xx_tcg_control_viajes          xvi
            , apps.xx_tcg_control_viajes_status   xvs     
        WHERE xvi.creation_date          > TO_DATE('01/01/2020','dd/mm/yyyy')
         AND  xvi.viaje_id               = xvs.viaje_id
         AND xvs.estado_transporte       = 'ACEPTADO'
         AND xvi.codigo_oncca            = '021'
         AND TO_NUMBER(TO_CHAR(XVS.FECHA, 'HH24')) BETWEEN 17 AND 24
        ) xtar
       , xx_opm_establecimientos         xoe   
  WHERE xtar.establecimiento_id = xoe.establecimiento_id                            
UNION ALL
-- DESPACHO igual fecha impresion, fecha carga
SELECT tipo, 
       fecha, 
       DECODE(xdei.establecimiento_id, 140, (SELECT campo FROM xx_opm_establecimientos WHERE establecimiento_id = 59) , xoe.campo) campoagr, 
       xoe.campo campo,               
       cantidad, 
       tipo_estab, 
       NULL qr_id,
       turno, 
       concepto, 
       orden, TRUNC(sysdate) fecha_join
  FROM
     (     
      SELECT tipo, fecha_real fecha, establecimiento_id, cantidad, tipo_estab, turno, concepto, orden
        FROM        
           (                              
             SELECT 'DESPACHO' tipo,  xcp.fecha_impresion fecha_real, xcp.fecha_carga fecha_bi,  xcp.titular_cp_estab_id establecimiento_id, 1 CANTIDAD, 'CAMPO' Tipo_Estab,
                    'MA' Turno, 'Cantidad de Camiones Cargados 00:00 - 07:59' Concepto, 6 orden 
               FROM apps.xx_tcg_cartas_porte_all   xcp
                  , mtl_system_items_b             mti    
                  , mtl_secondary_inventories      msi  
                  , mtl_secondary_inventories_dfv  msi_dfv   
                  , xx_tcg_parametros_compania     pc  
                  , org_organization_definitions   od                       
             WHERE 1=1
               AND TRUNC(fecha_impresion ) > TO_DATE('01/01/2020','dd/mm/yyyy') 
               AND msi_dfv.row_id           = msi.rowid 
               AND mti.inventory_item_id    = xcp.item_id
               AND xcp.titular_cp_tipo      = 'PRODUCTOR'
               AND mti.organization_id      = 135
               AND mti.attribute4           = '021' 
               AND xcp.titular_cp_estab_id  = msi_dfv.xx_tcg_establecimientos
               AND pc.operating_unit_cuit   = xcp.titular_cp_cuit
               AND pc.operating_unit        = od.operating_unit  
               AND msi.organization_id      = od.organization_id  
               AND msi_dfv.xx_tcg_tipos     = 'CAMPO'
               AND xcp.anulado_flag         = 'N'
               AND TO_NUMBER(TO_CHAR(xcp.fecha_impresion, 'HH24')) BETWEEN 0 AND 7.99                                           
             UNION ALL
            SELECT 'DESPACHO' tipo,    xcp.fecha_impresion fecha_real, xcp.fecha_carga fecha_bi, xcp.titular_cp_estab_id establecimiento_id, 1 CANTIDAD, 'CAMPO' Tipo_Estab, 
                   'ME' Turno , 'Cantidad de Camiones Cargados 08:00 - 16:59' Concepto , 7 orden
              FROM apps.xx_tcg_cartas_porte_all   xcp
                 , mtl_system_items_b             mti     
                 , mtl_secondary_inventories      msi  
                 , mtl_secondary_inventories_dfv  msi_dfv   
                 , xx_tcg_parametros_compania     pc  
                 , org_organization_definitions   od                       
            WHERE 1=1
              AND TRUNC(fecha_impresion ) > TO_DATE('01/01/2020','dd/mm/yyyy') 
              AND xcp.titular_cp_tipo     = 'PRODUCTOR'
              AND msi_dfv.row_id          = msi.rowid 
              AND mti.inventory_item_id   = xcp.item_id
              AND mti.organization_id     = 135
              AND mti.attribute4          = '021' 
              AND xcp.titular_cp_estab_id = msi_dfv.xx_tcg_establecimientos
              AND pc.operating_unit_cuit  = xcp.titular_cp_cuit
              AND pc.operating_unit       = od.operating_unit  
              AND msi.organization_id     = od.organization_id  
              AND msi_dfv.xx_tcg_tipos    = 'CAMPO'
              AND xcp.anulado_flag        = 'N'
              AND TO_NUMBER(TO_CHAR(xcp.fecha_impresion, 'HH24')) BETWEEN 8 AND 16.99                                         
            UNION ALL                        
           SELECT 'DESPACHO' tipo, xcp.fecha_impresion fecha_real, xcp.fecha_carga fecha_bi, xcp.titular_cp_estab_id establecimiento_id, 1 CANTIDAD, 'CAMPO' Tipo_Estab, 
                  'TA' Turno , 'Cantidad de Camiones Cargados 17:00 - 23:59' Concepto , 8 orden
             FROM apps.xx_tcg_cartas_porte_all   xcp
                , mtl_system_items_b             mti     
                , mtl_secondary_inventories      msi  
                , mtl_secondary_inventories_dfv  msi_dfv   
                , xx_tcg_parametros_compania     pc  
                , org_organization_definitions   od                       
            WHERE 1=1
              AND TRUNC(fecha_impresion ) > TO_DATE('01/01/2020','DD/MM/YYYY') 
              AND xcp.titular_cp_tipo      = 'PRODUCTOR'
              AND msi_dfv.row_id           = msi.rowid 
              AND mti.inventory_item_id    = xcp.item_id
              AND mti.organization_id      = 135
              AND mti.attribute4           = '021'
              AND xcp.titular_cp_estab_id  = msi_dfv.xx_tcg_establecimientos
              AND pc.operating_unit_cuit   = xcp.titular_cp_cuit
              AND pc.operating_unit        = od.operating_unit  
              AND msi.organization_id      = od.organization_id  
              AND msi_dfv.xx_tcg_tipos     = 'CAMPO'
              AND xcp.anulado_flag         = 'N'
              AND TO_NUMBER(TO_CHAR(xcp.fecha_impresion, 'HH24')) BETWEEN 17 AND 24                                 
             )
              WHERE TRUNC(fecha_real) = TRUNC(fecha_bi) 
           ) xdei
          , xx_opm_establecimientos  xoe
   WHERE xdei.establecimiento_id     = xoe.establecimiento_id                 
UNION ALL                 
-- DESPACHO fecha impresion distinto fecha carga
SELECT tipo, 
            fecha, 
            DECODE(xded.establecimiento_id, 140, (SELECT campo FROM xx_opm_establecimientos WHERE establecimiento_id = 59) , xoe.campo) campoagr, 
            xoe.campo campo,               
            cantidad, 
            tipo_estab, 
            NULL qr_id,            
            turno, 
            concepto, 
            orden, TRUNC(sysdate) fecha_join
  FROM
        (        
         SELECT tipo, fecha_bi fecha, establecimiento_id, cantidad, tipo_estab, turno, concepto, orden
          FROM
        (        
        SELECT 'DESPACHO' tipo, xcp.fecha_impresion fecha_real, TRUNC(xcp.fecha_carga)+0.9999 fecha_bi, xcp.titular_cp_estab_id establecimiento_id, 1 CANTIDAD, 'CAMPO' Tipo_Estab, 
               'TA' Turno , 'Cantidad de Camiones Cargados 17:00 - 23:59' Concepto , 8 orden
           FROM apps.xx_tcg_cartas_porte_all       xcp
                  , mtl_system_items_b             mti     
                  , mtl_secondary_inventories      msi  
                  , mtl_secondary_inventories_dfv  msi_dfv   
                  , xx_tcg_parametros_compania     pc  
                  , org_organization_definitions   od                       
          WHERE 1=1
              AND TRUNC(fecha_impresion ) > TO_DATE('01/01/2020','DD/MM/YYYY')         
              AND xcp.titular_cp_tipo       = 'PRODUCTOR'
              AND msi_dfv.row_id            = msi.rowid 
              AND mti.inventory_item_id     = xcp.item_id
              AND mti.organization_id       = 135
              AND mti.attribute4            = '021' 
              AND xcp.titular_cp_estab_id   = msi_dfv.xx_tcg_establecimientos
              AND pc.operating_unit_cuit    = xcp.titular_cp_cuit
              AND pc.operating_unit         = od.operating_unit  
             AND msi.organization_id        = od.organization_id  
             AND xcp.anulado_flag           = 'N'
             AND msi_dfv.xx_tcg_tipos       = 'CAMPO'
          --   AND TO_NUMBER(TO_CHAR(xcp.fecha_impresion, 'HH24')) BETWEEN 17 AND 24                               
         )          
         WHERE TRUNC(fecha_real) <> TRUNC(fecha_bi)         
         ) xded
          , xx_opm_establecimientos         xoe
 WHERE xded.establecimiento_id = xoe.establecimiento_id            
UNION ALL
-- TOTAL DESPACHO igual fecha impresion, fecha carga
SELECT tipo, 
            fecha, 
            DECODE(xtdei.establecimiento_id, 140, (SELECT campo FROM xx_opm_establecimientos WHERE establecimiento_id = 59) , xoe.campo) campoagr, 
            xoe.campo campo,               
            cantidad, 
            tipo_estab, 
            NULL qr_id,            
            turno, 
            concepto, 
            orden , TRUNC(sysdate) fecha_join
  FROM
          (
            SELECT tipo, fecha_real fecha, establecimiento_id, cantidad, tipo_estab, turno, concepto, orden
            FROM (
                    SELECT 'TOTAL_DESPACHO' tipo,  TRUNC(xcp.fecha_impresion) fecha_real, TRUNC(xcp.fecha_carga) fecha_bi,  xcp.titular_cp_estab_id establecimiento_id, 1 CANTIDAD, 'CAMPO' Tipo_Estab, 'TA' Turno , 'TOTAL DE CAMIONES CARGADOS' Concepto , 9 orden
                       FROM apps.xx_tcg_cartas_porte_all   xcp
                          , mtl_system_items_b                mti     
                          , mtl_secondary_inventories        msi  
                          , mtl_secondary_inventories_dfv  msi_dfv   
                          , xx_tcg_parametros_compania    pc  
                          , org_organization_definitions     od                       
                      WHERE 1=1
                        AND TRUNC(fecha_impresion ) > TO_DATE('01/01/2020','DD/MM/YYYY') 
                        AND msi_dfv.row_id            = msi.rowid 
                        AND xcp.titular_cp_tipo       = 'PRODUCTOR'
                        AND mti.inventory_item_id     = xcp.item_id
                        AND mti.organization_id       = 135
                        AND mti.attribute4            = '021' 
                        AND xcp.titular_cp_estab_id   = msi_dfv.xx_tcg_establecimientos
                        AND pc.operating_unit_cuit    = xcp.titular_cp_cuit
                        AND pc.operating_unit         = od.operating_unit  
                        AND msi.organization_id       = od.organization_id  
                        AND xcp.anulado_flag          = 'N'                         
                        AND msi_dfv.xx_tcg_tipos      = 'CAMPO'                
            )
             WHERE fecha_real = fecha_bi
           ) xtdei
          , xx_opm_establecimientos         xoe
 WHERE xtdei.establecimiento_id = xoe.establecimiento_id     
UNION ALL
-- TOTAL DESPACHO distinto fecha impresion, fecha carga
SELECT tipo, 
            fecha, 
            DECODE(xtded.establecimiento_id, 140, (SELECT campo FROM xx_opm_establecimientos WHERE establecimiento_id = 59) , xoe.campo) campoagr, 
            xoe.campo campo,               
            cantidad, 
            tipo_estab, 
            NULL qr_id,            
            turno, 
            concepto, 
            orden , TRUNC(sysdate) fecha_join
  FROM
          (
           SELECT tipo, fecha_bi fecha, establecimiento_id, cantidad, tipo_estab, turno, concepto, orden
             FROM (
                    SELECT 'TOTAL_DESPACHO' tipo,  TRUNC(xcp.fecha_impresion) fecha_real, TRUNC(xcp.fecha_carga) fecha_bi, xcp.titular_cp_estab_id establecimiento_id, 1 CANTIDAD, 'CAMPO' Tipo_Estab, 'TA' Turno , 'TOTAL DE CAMIONES CARGADOS' Concepto , 9 orden
                       FROM apps.xx_tcg_cartas_porte_all   xcp
                              , mtl_system_items_b             mti     
                              , mtl_secondary_inventories      msi  
                              , mtl_secondary_inventories_dfv  msi_dfv   
                              , xx_tcg_parametros_compania     pc  
                              , org_organization_definitions   od                       
                      WHERE 1=1
                         AND TRUNC(fecha_impresion )    > TO_DATE('01/01/2020','DD/MM/YYYY') 
                         AND msi_dfv.row_id             = msi.rowid 
                         AND mti.inventory_item_id      = xcp.item_id
                         AND xcp.titular_cp_tipo        = 'PRODUCTOR'
                         AND mti.organization_id        = 135
                         AND mti.attribute4             = '021' 
                         AND xcp.titular_cp_estab_id    = msi_dfv.xx_tcg_establecimientos
                         AND pc.operating_unit_cuit     = xcp.titular_cp_cuit
                         AND pc.operating_unit          = od.operating_unit  
                         AND msi.organization_id        = od.organization_id  
                         AND xcp.anulado_flag           = 'N'
                         AND msi_dfv.xx_tcg_tipos       = 'CAMPO'
                    )
                     WHERE fecha_real <> fecha_bi
           ) xtded
          , xx_opm_establecimientos         xoe
 WHERE xtded.establecimiento_id = xoe.establecimiento_id;



 execute immediate ( 'truncate table bolinf.XX_TCG_ARRIBOS_MOLINOS');

    insert into  bolinf.XX_TCG_ARRIBOS_MOLINOS
   SELECT tipo, 
            fecha, 
            xoe.campo campoagr, 
            xoe.campo campo,               
            cantidad, 
            tipo_estab, 
            NULL qr_id,
            turno, 
            concepto, 
            orden
  FROM
        (
                 SELECT 'ARRIBO_MOLINO' tipo,  xvs.fecha,  xcp.destino_estab_id establecimiento_id, 1 CANTIDAD, 'PLANTA' Tipo_Estab, 
                        'MA' Turno, 'Cantidad de Camiones Arribados 00:00 - 07:59' Concepto, 1 orden 
                   FROM apps.xx_tcg_cartas_porte_all   xcp
                      , mtl_system_items_b             mti    
                      , mtl_secondary_inventories      msi  
                      , mtl_secondary_inventories_dfv  msi_dfv   
                      , xx_tcg_parametros_compania     pc  
                      , org_organization_definitions   od
                      , xx_tcg_tickets_balanza         xttb 
                      , xx_tcg_control_viajes_status   xvs                                                  
                  WHERE 1=1
                    AND xvs.fecha                     > TO_DATE('01/01/2020','DD/MM/YYYY') 
                    AND msi_dfv.row_id                = msi.rowid 
                    AND mti.inventory_item_id         = xcp.item_id
                    AND xcp.titular_cp_tipo           = 'PRODUCTOR'
                    AND mti.organization_id           = 135
                    AND mti.attribute4                = '021' 
                    AND xcp.destino_estab_id          = msi_dfv.xx_tcg_establecimientos
                    AND pc.operating_unit_cuit        = xcp.destino_cuit
                    AND pc.operating_unit             = od.operating_unit  
                    AND msi.organization_id           = od.organization_id  
                    AND msi_dfv.xx_tcg_tipos         <> 'CAMPO' 
                    AND  xttb.tipo_ticket             = 'SALIDA'
                    AND xttb.ticket_id                = xcp.ticket_envio_id                   
                    AND NVL(xttb.cancelado_flag,'N')  = 'N'
                    AND NVL(xcp.anulado_flag,'N')     = 'N'
                    AND  xttb.viaje_id                = xvs.viaje_id
                    AND xvs.estado_transporte          = 'ARRIBADO'        
                    AND TO_NUMBER(TO_CHAR(xvs.fecha, 'HH24')) BETWEEN 0 AND 7.99                                                                                 
              UNION ALL
                 SELECT 'ARRIBO_MOLINO' tipo,  xvs.fecha,  xcp.destino_estab_id establecimiento_id, 1 CANTIDAD, 'PLANTA' Tipo_Estab, 
                        'MA' Turno, 'Cantidad de Camiones Arribados 08:00 - 15:59' Concepto, 2 orden 
                   FROM apps.xx_tcg_cartas_porte_all   xcp
                      , mtl_system_items_b             mti    
                      , mtl_secondary_inventories      msi  
                      , mtl_secondary_inventories_dfv  msi_dfv   
                      , xx_tcg_parametros_compania     pc  
                      , org_organization_definitions   od
                      , xx_tcg_tickets_balanza         xttb 
                      , xx_tcg_control_viajes_status   xvs                                                  
                  WHERE 1=1
                    AND xvs.fecha                     > TO_DATE('01/01/2020','DD/MM/YYYY')
                    AND msi_dfv.row_id                = msi.rowid 
                    AND mti.inventory_item_id         = xcp.item_id
                    AND xcp.titular_cp_tipo           = 'PRODUCTOR'
                    AND mti.organization_id           = 135
                    AND mti.attribute4                = '021' 
                    AND xcp.destino_estab_id          = msi_dfv.xx_tcg_establecimientos
                    AND pc.operating_unit_cuit        = xcp.destino_cuit
                    AND pc.operating_unit             = od.operating_unit  
                    AND msi.organization_id           = od.organization_id  
                    AND msi_dfv.xx_tcg_tipos         <> 'CAMPO' 
                    AND  xttb.tipo_ticket             = 'SALIDA'
                    AND xttb.ticket_id                = xcp.ticket_envio_id                   
                    AND NVL(xttb.cancelado_flag,'N')  = 'N'
                    AND NVL(xcp.anulado_flag,'N')     = 'N'
                    AND  xttb.viaje_id                = xvs.viaje_id
                    AND xvs.estado_transporte         = 'ARRIBADO'        
                    AND TO_NUMBER(TO_CHAR(xvs.fecha, 'HH24')) BETWEEN 8 AND 15.99                       
              UNION ALL
                 SELECT 'ARRIBO_MOLINO' tipo,  xvs.fecha,  xcp.destino_estab_id establecimiento_id, 1 CANTIDAD, 'PLANTA' Tipo_Estab, 'MA' Turno, 'Cantidad de Camiones Arribados 16:00 - 23:59' Concepto, 3 orden 
                   FROM apps.xx_tcg_cartas_porte_all   xcp
                          , mtl_system_items_b                mti    
                          , mtl_secondary_inventories        msi  
                          , mtl_secondary_inventories_dfv  msi_dfv   
                          , xx_tcg_parametros_compania    pc  
                          , org_organization_definitions      od
                          , xx_tcg_tickets_balanza             xttb 
                          , xx_tcg_control_viajes_status      xvs                                                  
                  WHERE 1=1
                    AND xvs.fecha                      > TO_DATE('01/01/2020','DD/MM/YYYY')
                    AND msi_dfv.row_id                 = msi.rowid 
                    AND mti.inventory_item_id          = xcp.item_id
                    AND xcp.titular_cp_tipo            = 'PRODUCTOR'
                    AND mti.organization_id            = 135
                    AND mti.attribute4                 = '021' 
                    AND xcp.destino_estab_id           = msi_dfv.xx_tcg_establecimientos
                    AND pc.operating_unit_cuit         = xcp.destino_cuit
                    AND pc.operating_unit              = od.operating_unit  
                    AND msi.organization_id            = od.organization_id  
                    AND msi_dfv.xx_tcg_tipos          <> 'CAMPO' 
                    AND  xttb.tipo_ticket              = 'SALIDA'
                    AND xttb.ticket_id                 = xcp.ticket_envio_id                   
                    AND NVL(xttb.cancelado_flag,'N')   = 'N'
                    AND NVL(xcp.anulado_flag,'N')      = 'N'
                    AND  xttb.viaje_id                 = xvs.viaje_id
                    AND xvs.estado_transporte          = 'ARRIBADO'        
                    AND TO_NUMBER(TO_CHAR(xvs.fecha, 'HH24')) BETWEEN 16 AND 24.00  
        )  xam
        , xx_opm_establecimientos         xoe   
 WHERE xam.establecimiento_id = xoe.establecimiento_id          
UNION ALL
-- TOTAL ARRIBO MOLINOS
SELECT tipo, 
            fecha, 
            xoe.campo campoagr, 
            xoe.campo campo,               
            cantidad, 
            tipo_estab, 
            NULL qr_id,
            turno, 
            concepto, 
            orden
  FROM
        (        
                 SELECT 'TOTAL_ARRIBO_MOLINO' tipo,  xvs.fecha,  xcp.destino_estab_id establecimiento_id, 1 CANTIDAD, 'PLANTA' Tipo_Estab, 
                        'TA' Turno, 'TOTAL DE CAMIONES ARRIBADOS' Concepto, 4 orden 
                   FROM apps.xx_tcg_cartas_porte_all   xcp
                      , mtl_system_items_b                mti    
                      , mtl_secondary_inventories        msi  
                      , mtl_secondary_inventories_dfv  msi_dfv   
                      , xx_tcg_parametros_compania    pc  
                      , org_organization_definitions      od
                      , xx_tcg_tickets_balanza             xttb 
                      , xx_tcg_control_viajes_status      xvs                                               
                  WHERE 1=1
                    AND xvs.fecha                    > TO_DATE('01/01/2020','DD/MM/YYYY')
                    AND msi_dfv.row_id               = msi.rowid 
                    AND mti.inventory_item_id        = xcp.item_id
                    AND xcp.titular_cp_tipo          = 'PRODUCTOR'
                    AND mti.organization_id          = 135
                    AND mti.attribute4               = '021' 
                    AND xcp.destino_estab_id         = msi_dfv.xx_tcg_establecimientos
                    AND pc.operating_unit_cuit       = xcp.destino_cuit
                    AND pc.operating_unit            = od.operating_unit  
                    AND msi.organization_id          = od.organization_id  
                    AND msi_dfv.xx_tcg_tipos        <> 'CAMPO' 
                    AND  xttb.tipo_ticket            = 'SALIDA'
                    AND xttb.ticket_id               = xcp.ticket_envio_id                   
                    AND NVL(xttb.cancelado_flag,'N') = 'N'
                    AND NVL(xcp.anulado_flag,'N')    = 'N'
                    AND  xttb.viaje_id               = xvs.viaje_id
                    AND xvs.estado_transporte        = 'ARRIBADO'                              
        )  xtam
        , xx_opm_establecimientos         xoe   
 WHERE xtam.establecimiento_id = xoe.establecimiento_id                              
UNION ALL                          
-- CAMIONES DESCARGADOS
SELECT tipo, 
            fecha, 
            xoe.campo campoagr, 
            xoe.campo campo,               
            cantidad, 
            tipo_estab, 
            NULL qr_id,
            turno, 
            concepto, 
            orden
  FROM
        (        
                 SELECT 'DESCARGADO_MOLINO' tipo,  xttb.tara_fecha fecha,  xcp.destino_estab_id establecimiento_id, 1 CANTIDAD, 'PLANTA' Tipo_Estab,
                        'MA' Turno, 'Cantidad de Camiones Descargados 00:00 - 07:59' Concepto, 5 orden
                   FROM apps.xx_tcg_cartas_porte_all   xcp
                      , mtl_system_items_b                mti    
                      , mtl_secondary_inventories        msi  
                      , mtl_secondary_inventories_dfv  msi_dfv   
                      , xx_tcg_parametros_compania    pc  
                      , org_organization_definitions      od
                      , xx_tcg_tickets_balanza             xttb                                                
                  WHERE 1=1
                    AND xttb.creation_date               > TO_DATE('01/01/2020','DD/MM/YYYY') 
                    AND msi_dfv.row_id                   = msi.rowid 
                    AND mti.inventory_item_id            = xcp.item_id
                    AND xcp.titular_cp_tipo              = 'PRODUCTOR'
                    AND mti.organization_id              = 135
                    AND mti.attribute4                   = '021' 
                    AND xcp.destino_estab_id             = msi_dfv.xx_tcg_establecimientos
                    AND pc.operating_unit_cuit           = xcp.destino_cuit
                    AND pc.operating_unit                = od.operating_unit  
                    AND msi.organization_id              = od.organization_id  
                    AND msi_dfv.xx_tcg_tipos            <> 'CAMPO' 
                    AND xttb.ticket_id                   = xcp.ticket_recepcion_id                   
                    AND NVL(xttb.cancelado_flag,'N')     = 'N'
                    AND NVL(xcp.anulado_flag,'N')        = 'N'
                    AND NVL(xcp.recibido_flag,'N')       = 'Y'
                    AND NVL(xcp.transferido_flag,'N')    = 'Y'
                    AND TO_NUMBER(TO_CHAR(xttb.tara_fecha, 'HH24')) BETWEEN 0 AND 7.99                                                                                                                   
              UNION ALL
                 SELECT 'DESCARGADO_MOLINO' tipo,  xttb.tara_fecha fecha,  xcp.destino_estab_id establecimiento_id, 1 CANTIDAD, 'PLANTA' Tipo_Estab, 'MA' Turno, 'Cantidad de Camiones Descargados 08:00 - 15:59' Concepto, 6 orden
                   FROM apps.xx_tcg_cartas_porte_all       xcp
                          , mtl_system_items_b             mti    
                          , mtl_secondary_inventories      msi  
                          , mtl_secondary_inventories_dfv  msi_dfv   
                          , xx_tcg_parametros_compania     pc  
                          , org_organization_definitions   od
                          , xx_tcg_tickets_balanza         xttb                                                
                  WHERE 1=1
                     AND xttb.creation_date           > TO_DATE('01/01/2020','DD/MM/YYYY')
                     AND msi_dfv.row_id               = msi.rowid 
                      AND mti.inventory_item_id       = xcp.item_id
                      AND xcp.titular_cp_tipo         = 'PRODUCTOR'
                      AND mti.organization_id         = 135
                      AND mti.attribute4              = '021' 
                      AND xcp.destino_estab_id        = msi_dfv.xx_tcg_establecimientos
                      AND pc.operating_unit_cuit      = xcp.destino_cuit
                      AND pc.operating_unit           = od.operating_unit  
                     AND msi.organization_id          = od.organization_id  
                     AND msi_dfv.xx_tcg_tipos        <> 'CAMPO' 
                     AND xttb.ticket_id               = xcp.ticket_recepcion_id                   
                     AND NVL(xttb.cancelado_flag,'N') = 'N'
                     AND NVL(xcp.anulado_flag,'N')    = 'N'
                     AND NVL(xcp.recibido_flag,'N')   = 'Y'
                     AND NVL(xcp.transferido_flag,'N') = 'Y'
                     AND TO_NUMBER(TO_CHAR(xttb.tara_fecha, 'HH24')) BETWEEN 8 AND 15.99                                                                                                                   
              UNION ALL
                 SELECT 'DESCARGADO_MOLINO' tipo,  xttb.tara_fecha fecha,  xcp.destino_estab_id establecimiento_id, 1 CANTIDAD, 'PLANTA' Tipo_Estab, 
                        'MA' Turno, 'Cantidad de Camiones Descargados 16:00 - 23:59' Concepto, 7 orden
                   FROM apps.xx_tcg_cartas_porte_all       xcp
                          , mtl_system_items_b             mti    
                          , mtl_secondary_inventories      msi  
                          , mtl_secondary_inventories_dfv  msi_dfv   
                          , xx_tcg_parametros_compania     pc  
                          , org_organization_definitions   od
                          , xx_tcg_tickets_balanza         xttb                                                
                  WHERE 1=1
                     AND xttb.creation_date           > TO_DATE('01/01/2020','DD/MM/YYYY') 
                     AND msi_dfv.row_id               = msi.rowid 
                     AND mti.inventory_item_id        = xcp.item_id
                     AND xcp.titular_cp_tipo          = 'PRODUCTOR'
                     AND mti.organization_id          = 135
                     AND mti.attribute4               = '021' 
                     AND xcp.destino_estab_id         = msi_dfv.xx_tcg_establecimientos
                     AND pc.operating_unit_cuit       = xcp.destino_cuit
                     AND pc.operating_unit            = od.operating_unit  
                     AND msi.organization_id          = od.organization_id  
                     AND msi_dfv.xx_tcg_tipos         <> 'CAMPO' 
                     AND xttb.ticket_id               = xcp.ticket_recepcion_id                   
                     AND NVL(xttb.cancelado_flag,'N') = 'N'
                     AND NVL(xcp.anulado_flag,'N')    = 'N'
                     AND NVL(xcp.recibido_flag,'N')   = 'Y'
                     AND NVL(xcp.transferido_flag,'N')= 'Y'
                     AND TO_NUMBER(TO_CHAR(xttb.tara_fecha, 'HH24')) BETWEEN 16 AND 24                                           
        )  xdm
        , xx_opm_establecimientos         xoe   
 WHERE xdm.establecimiento_id = xoe.establecimiento_id   
UNION ALL
-- TOTAL CAMIONES DESCARGADOS
SELECT tipo, 
            fecha, 
            xoe.campo campoagr, 
            xoe.campo campo,               
            cantidad, 
            tipo_estab, 
            NULL qr_id,
            turno, 
            concepto, 
            orden
  FROM
        (        
                 SELECT 'TOTAL_DESCARGADO_MOLINO' tipo,  xttb.tara_fecha fecha,  xcp.destino_estab_id establecimiento_id, 1 CANTIDAD, 'PLANTA' Tipo_Estab, 
                        'MA' Turno, 'TOTAL DE CAMIONES DESCARGADOS' Concepto, 8 orden
                   FROM apps.xx_tcg_cartas_porte_all        xcp
                          , mtl_system_items_b              mti    
                          , mtl_secondary_inventories       msi  
                          , mtl_secondary_inventories_dfv   msi_dfv   
                          , xx_tcg_parametros_compania      pc  
                          , org_organization_definitions    od
                          , xx_tcg_tickets_balanza          xttb                                                
                  WHERE 1=1
                     AND xttb.creation_date           > TO_DATE('01/01/2020','DD/MM/YYYY') 
                     AND msi_dfv.row_id               = msi.rowid 
                      AND mti.inventory_item_id       = xcp.item_id
                      AND xcp.titular_cp_tipo         = 'PRODUCTOR'
                      AND mti.organization_id         = 135
                      AND mti.attribute4              = '021' 
                      AND xcp.destino_estab_id        = msi_dfv.xx_tcg_establecimientos
                      AND pc.operating_unit_cuit      = xcp.destino_cuit
                      AND pc.operating_unit           = od.operating_unit  
                     AND msi.organization_id          = od.organization_id  
                     AND msi_dfv.xx_tcg_tipos        <> 'CAMPO' 
                     AND xttb.ticket_id               = xcp.ticket_recepcion_id                   
                     AND NVL(xttb.cancelado_flag,'N') = 'N'
                     AND NVL(xcp.anulado_flag,'N')    = 'N'
                     AND NVL(xcp.recibido_flag,'N')   = 'Y'
                     AND NVL(xcp.transferido_flag,'N')= 'Y'
         )  xtdm
        , xx_opm_establecimientos         xoe   
 WHERE xtdm.establecimiento_id = xoe.establecimiento_id;



    --execute immediate ( 'delete  ADECO_BI.XX_TCG_LCP_CALIDAD_TMP_BI');


    /*
      --Inserta datos de calidad del boletin
      BEGIN


         INSERT INTO ADECO_BI.XX_TCG_LCP_CALIDAD_TMP_BI
              SELECT flv.description concepto_muestra,
                     xtc.concepto_lookup_code,
                     CASE MAX (NVL (xvm.valor, -1))
                        WHEN -1 THEN 'N'
                        ELSE 'Y'
                     END
                        valor
                FROM xx_aco_valores_muestra xvm,
                     xx_aco_ta_conceptos_muestra xtc,
                     fnd_lookup_values flv,
                     xx_tcg_boletin_headers xbh,
                     ADECO_BI.xx_tcg_cartas_porte_v2_BI xtcp_BI
               WHERE     xbh.boletin_header_id = xtcp_BI.boletin_header_id
                     AND xvm.boletin_header_id(+) = xbh.boletin_header_id
                     AND xvm.codigo_concepto(+) = xtc.concepto_lookup_code
                     AND xtc.tabla_analisis_id = xbh.tabla_analisis_id
                     --- DEFINIR PERIODO ACTUALIZACION
                     AND xtcp_bi.creation_Date > sysdate -  p_carga_desde --between  '01-MAR-2019' and '31-MAR-2019';
                     --- DEFINIR PERIODO ACTUALIZACION
                     AND flv.lookup_type = 'XX_ACO_CONCEPTOS_MUESTRA'
                     AND flv.language = USERENV ('LANG')
                     AND flv.lookup_code = xtc.concepto_lookup_code
            GROUP BY flv.description, xtc.concepto_lookup_code
            ORDER BY xtc.concepto_lookup_code;


         INSERT INTO ADECO_BI.xx_TCG_carta_BI_BOLETIN
            SELECT XX_UTIL_PK.XML_NUM_DISPLAY (q.valor) valor,
                   q.concepto_muestra,
                   q.carta_porte_id
              FROM (SELECT flv.description concepto_muestra,
                           xtc.concepto_lookup_code,
                           xvm.valor,
                           xbl.carta_porte_id
                      FROM xx_tcg_boletin_lines xbl,
                           xx_tcg_boletin_headers xbh,
                           xx_aco_valores_muestra xvm,
                           xx_aco_ta_conceptos_muestra xtc,
                           fnd_lookup_values_vl flv,
                           ADECO_BI.xx_tcg_cartas_porte_v2_BI xtcp_BI
                     WHERE     1 = 1
                           AND xbl.carta_porte_id = xtcp_BI.carta_porte_id
                           -- DEFINIR PERIODO ACTUALIZACION
                          AND xtcp_bi.creation_Date > sysdate -  p_carga_desde --between  '01-MAR-2019' and '31-MAR-2019';
                           -- DEFINIR PERIODO ACTUALIZACION
                           AND xbl.boletin_header_id = xbh.boletin_header_id
                           AND xbh.anulado_flag = 'N'
                           AND xvm.boletin_header_id(+) =
                                  xbh.boletin_header_id
                           AND xvm.codigo_concepto(+) =
                                  xtc.concepto_lookup_code
                           AND xtc.tabla_analisis_id = xbh.tabla_analisis_id
                           AND flv.lookup_type = 'XX_ACO_CONCEPTOS_MUESTRA'
                           AND flv.lookup_code = xtc.concepto_lookup_code) q,
                   ADECO_BI.XX_TCG_LCP_CALIDAD_TMP_BI xtlcp
             WHERE 1 = 1
                   AND xtlcp.concepto_lookup_code = q.concepto_lookup_code(+);
      --AND q.concepto_lookup_code      = p_concepto

      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;
   */



END;
/

