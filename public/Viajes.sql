CREATE OR REPLACE VIEW APPS.XX_TCG_CARTAS_PORTE_CV_V
(
   NUMERO_CARTA_PORTE,
   CARTA_PORTE_RELACIONADA,
   CARTA_PORTE_ID,
   ITEM_NO,
   ITEM_DESC,
   LOT_NO,
   TIPO_GRANO,
   TIPO_GRANO_DESC,
   ITEM_ONCCA_CODE,
   ITEM_ONCCA_ESPECIE,
   TRANSFERIDO_FLAG,
   RECIBIDO_FLAG,
   ANULADO_FLAG,
   PESAJE_SALIDA_FLAG,
   PESAJE_ENTRADA_FLAG,
   TITULAR_CP_TIPO,
   TITULAR_CP,
   TITULAR_CP_ID,
   TITULAR_CP_CUIT,
   TITULAR_CP_ESTAB_ID,
   TITULAR_CP_ESTAB_DESC,
   TITULAR_CP_UBICACION_DESC,
   TITULAR_CP_PROVINCIA,
   TITULAR_CP_PROVINCIA_DESC,
   TITULAR_CP_LOCALIDAD,
   TITULAR_CP_LOCALIDAD_DESC,
   TITULAR_CP_DIRECCION,
   TITULAR_CP_CONTRATO_ID,
   ORIGEN_TIPO,
   INTERMEDIARIO_TIPO,
   INTERMEDIARIO,
   INTERMEDIARIO_ID,
   INTERMEDIARIO_CUIT,
   INTERMEDIARIO_RETIRO,
   INTERMEDIARIO_CONTRATO_ID,
   RTTE_COMERCIAL_TIPO,
   RTTE_COMERCIAL,
   RTTE_COMERCIAL_ID,
   RTTE_COMERCIAL_RETIRO,
   RTTE_COMERCIAL_CONTRATO_ID,
   CORREDOR_CUIT,
   CORREDOR,
   CORREDOR_ID,
   MERCADO_TERMINO_CUIT,
   MERCADO_TERMINO,
   MERCADO_TERMINO_ID,
   CORREDOR_VENDEDOR_CUIT,
   CORREDOR_VENDEDOR,
   CORREDOR_VENDEDOR_ID,
   REPRESENTANTE_CUIT,
   REPRESENTANTE,
   REPRESENTANTE_ID,
   DESTINATARIO_CUIT,
   DESTINATARIO,
   DESTINATARIO_ID,
   DESTINATARIO_CONTRATO_ID,
   DESTINO,
   DESTINO_ID,
   DESTINO_CUIT,
   DESTINO_ESTAB_ID,
   DESTINO_ESTAB_DESC,
   DESTINO_UBICACION,
   DESTINO_UBICACION_DESC,
   DESTINO_PROVINCIA,
   DESTINO_PROVINCIA_DESC,
   DESTINO_LOCALIDAD,
   DESTINO_LOCALIDAD_DESC,
   DESTINO_DIRECCION,
   DESTINO_TIPO,
   FECHA_ENVIO,
   FECHA_CARGA,
   CANTIDAD_HORAS,
   TICKET_ENVIO_NUMERO,
   TARA_ENVIO,
   PESO_BRUTO_ENVIO,
   PESO_NETO_ENVIO,
   PESO_ESTIMADO,
   PESO_TRANSFERIDO,
   PCTAJE_HUMEDAD_ESTIMADA,
   PCTAJE_MERMA_HUMEDAD_ENVIO,
   PESO_HUMEDAD_ESTIMADA,
   PCTAJE_MATERIA_EXTRANIA_ENVIO,
   PESO_MATERIA_EXTRANIA_ENVIO,
   LOTE,
   VARIEDAD,
   TIPO_CALIDAD_ENVIO,
   FECHA_RECEPCION,
   TICKET_RECEPCION_NUMERO,
   PESO_BRUTO_RECEPCION,
   TARA_RECEPCION,
   PESO_NETO_RECEPCION,
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
   SHIP_METHOD_MEANING,
   QR_ID,
   TRANSPORTISTA_NOMBRE,
   TRANSPORTISTA_CUIT,
   INTERMEDIARIO_FLETE,
   INTERMEDIARIO_FLETE_CUIT,
   PATENTE_CAMION,
   PATENTE_ACOPLADO,
   CHOFER,
   CUIL,
   SUBCONTRATADO,
   PROCEDENCIA_ENGANCHADA,
   DISTANCIA_ESTIMADA,
   TARIFA_REF_FLETE_XTON,
   COSTO_FLETE_XTON,
   COSTO_FLETE,
   TARIFA_CP_XTON,
   PROVISIONAR_FLETE_FLAG,
   PROVISIONADO_FLAG,
   REFACTURAR_FLETE_FLAG,
   REFACTURADO_FLAG,
   OBSERVACION_TRANSPORTE,
   CTG_NUMERO,
   CEE_NUMERO,
   COT_NUMERO,
   RENSPA,
   OBSERVACIONES,
   CREATION_DATE,
   CREATED_BY,
   NUMERO_BOLETIN,
   FACTOR,
   GRADO,
   NUMERO_LIQUIDACION,
   LIQUIDACION_ID,
   PROVISIONADO_POR_DESC,
   USER_NAME,
   UO_CERTIFICA,
   BOLETIN_HEADER_ID,
   ITEM_ID,
   TITULAR_CP_CONTRATO,
   INTERMEDIARIO_CONTRATO,
   RTTE_COMERCIAL_CONTRATO,
   DESTINATARIO_CONTRATO,
   FECHA_IMPRESION,
   ARRIBO_ESTIMADO,
   VIAJE_ID,
   TURNO_VIAJE,
   CANCELADO_FLAG_TB_ENVIO
)
AS
   SELECT DISTINCT
          xtcp.NUMERO_CARTA_PORTE,
          xtcp.CARTA_PORTE_RELACIONADA,
          xtcp.CARTA_PORTE_ID,
          cItems.ITEM_NO,
          cItems.ITEM_DESC,
          xtcp.LOT_NO,
          xtcp.TIPO_GRANO,
          cTipoGrano.TIPO_GRANO_DESC,
          cItems.ITEM_ONCCA_CODE,
          cItems.ITEM_ONCCA_ESPECIE,
          xtcp.TRANSFERIDO_FLAG,
          xtcp.RECIBIDO_FLAG,
          xtcp.ANULADO_FLAG,
          xtcp.PESAJE_SALIDA_FLAG,
          xtcp.PESAJE_ENTRADA_FLAG,
          xtcp.TITULAR_CP_TIPO,
          xtcp.TITULAR_CP,
          xtcp.TITULAR_CP_ID,
          xtcp.TITULAR_CP_CUIT,
          xtcp.TITULAR_CP_ESTAB_ID,
          DECODE (XX_TCG_LISTADO_CP.Es_Empresa_Grupo (xtcp.TITULAR_CP_CUIT),
                  'Y', cEstab1.TITULAR_CP_ESTAB_DESC,
                  cLocation1.TITULAR_CP_ESTAB_DESC)
             TITULAR_CP_ESTAB_DESC,
          cInvLoc1.TITULAR_CP_UBICACION_DESC,
          xtcp.TITULAR_CP_PROVINCIA,
          cLocProv1.TITULAR_CP_PROVINCIA_DESC,
          xtcp.TITULAR_CP_LOCALIDAD,
          cLocProv1.TITULAR_CP_LOCALIDAD_DESC,
          xtcp.TITULAR_CP_DIRECCION,
          xtcp.TITULAR_CP_CONTRATO_ID,
          XX_TCG_LISTADO_CP.
          Get_Tipo_Origen_Destino_CP (xtcp.TITULAR_CP_CUIT,
                                      xtcp.TITULAR_CP_ESTAB_ID,
                                      xtcp.CARTA_PORTE_ID)
             ORIGEN_TIPO,
          xtcp.INTERMEDIARIO_TIPO,
          xtcp.INTERMEDIARIO,
          xtcp.INTERMEDIARIO_ID,
          xtcp.INTERMEDIARIO_CUIT,
          xtcp.INTERMEDIARIO_RETIRO,
          xtcp.INTERMEDIARIO_CONTRATO_ID,
          xtcp.RTTE_COMERCIAL_TIPO,
          xtcp.RTTE_COMERCIAL,
          xtcp.RTTE_COMERCIAL_ID,
          xtcp.RTTE_COMERCIAL_RETIRO,
          xtcp.RTTE_COMERCIAL_CONTRATO_ID,
          xtcp.CORREDOR_CUIT,
          xtcp.CORREDOR,
          xtcp.CORREDOR_ID,
          xtcp.MERCADO_TERMINO_CUIT,
          xtcp.MERCADO_TERMINO,
          xtcp.MERCADO_TERMINO_ID,
          xtcp.CORREDOR_VENDEDOR_CUIT,
          xtcp.CORREDOR_VENDEDOR,
          xtcp.CORREDOR_VENDEDOR_ID,
          xtcp.REPRESENTANTE_CUIT,
          xtcp.REPRESENTANTE,
          xtcp.REPRESENTANTE_ID,
          xtcp.DESTINATARIO_CUIT,
          xtcp.DESTINATARIO,
          xtcp.DESTINATARIO_ID,
          xtcp.DESTINATARIO_CONTRATO_ID,
          xtcp.DESTINO,
          xtcp.DESTINO_ID,
          xtcp.DESTINO_CUIT,
          xtcp.DESTINO_ESTAB_ID,
          DECODE (XX_TCG_LISTADO_CP.Es_Empresa_Grupo (xtcp.DESTINO_CUIT),
                  'Y', cEstab2.DESTINO_ESTAB_DESC,
                  cLocation2.DESTINO_ESTAB_DESC)
             DESTINO_ESTAB_DESC,
          xtcp.DESTINO_UBICACION,
          cInvLoc2.DESTINO_UBICACION_DESC,
          xtcp.DESTINO_PROVINCIA,
          cLocProv2.DESTINO_PROVINCIA_DESC,
          xtcp.DESTINO_LOCALIDAD,
          cLocProv2.DESTINO_LOCALIDAD_DESC,
          xtcp.DESTINO_DIRECCION,
          XX_TCG_LISTADO_CP.
          Get_Tipo_Origen_Destino_CP (xtcp.DESTINO_CUIT,
                                      xtcp.DESTINO_ESTAB_ID,
                                      xtcp.CARTA_PORTE_ID)
             DESTINO_TIPO,
          xtcp.FECHA_ENVIO,
          xtcp.FECHA_CARGA,
          xtcp.CANTIDAD_HORAS,
          cDetallePesaje1.TICKET_ENVIO_NUMERO,
          xtcp.TARA_ENVIO,
          xtcp.PESO_BRUTO_ENVIO,
          (xtcp.PESO_BRUTO_ENVIO - xtcp.TARA_ENVIO) PESO_NETO_ENVIO,
          xtcp.PESO_ESTIMADO,
          xtcp.PESO_TRANSFERIDO,
          xtcp.PCTAJE_HUMEDAD_ESTIMADA,
          xtcp.PCTAJE_MERMA_HUMEDAD_ENVIO,
          XX_TCG_CALIDAD_PKG.
          Get_Peso_Merma_Humedad (
             p_peso                 => NVL (
                                         xtcp.peso_estimado,
                                         NVL (xtcp.peso_bruto_envio, 0)
                                         - NVL (xtcp.tara_envio, 0)),
             p_porcentaje_humedad   => xtcp.pctaje_humedad_estimada,
             p_item_oncca_code      => cItems.ITEM_ONCCA_CODE,
             p_item_id              => xtcp.item_id,
             p_party_id             => xtcp.destino_id,
             p_party_site_id        => xtcp.destino_estab_id,
             p_grupo_control        => '01')
             peso_humedad_estimada,
          xtcp.PCTAJE_MATERIA_EXTRANIA_ENVIO,
          ROUND (
             ( (NVL (
                   xtcp.peso_estimado,
                   NVL (xtcp.peso_bruto_envio, 0) - NVL (xtcp.tara_envio, 0))
                - XX_TCG_CALIDAD_PKG.
                  Get_Peso_Merma_Humedad (
                     p_peso                 => NVL (
                                                 xtcp.peso_estimado,
                                                 NVL (xtcp.peso_bruto_envio, 0)
                                                 - NVL (xtcp.tara_envio, 0)),
                     p_porcentaje_humedad   => xtcp.pctaje_humedad_estimada,
                     p_item_oncca_code      => cItems.ITEM_ONCCA_CODE,
                     p_item_id              => xtcp.item_id,
                     p_party_id             => xtcp.destino_id,
                     p_party_site_id        => xtcp.destino_estab_id,
                     p_grupo_control        => '01'))
              * xtcp.pctaje_materia_extrania_envio)
             / 100,
             NVL (FND_PROFILE.VALUE ('XX_ACO_PESO_CANTIDAD_DECIMALES'), 2))
             peso_materia_extrania_envio,
          xtcp.LOTE,
          xtcp.VARIEDAD,
          xtcp.TIPO_CALIDAD_ENVIO,
          xtcp.FECHA_RECEPCION,
          cDetallePesaje2.TICKET_RECEPCION_NUMERO,
          xtcp.PESO_BRUTO_RECEPCION,
          xtcp.TARA_RECEPCION,
          (xtcp.PESO_BRUTO_RECEPCION - xtcp.TARA_RECEPCION)
             PESO_NETO_RECEPCION,
          xtcp.PCTAJE_HUMEDAD_RECEP,
          xtcp.PCTAJE_MERMA_HUMEDAD_RECEP,
          XX_TCG_CALIDAD_PKG.
          Get_Merma_Humedad (p_carta_porte_id => xtcp.CARTA_PORTE_ID)
             PESO_MERMA_HUMEDAD_RECEP,
          xtcp.PCTAJE_ZARANDA_RECEP,
          XX_TCG_CALIDAD_PKG.
          Get_Merma_Zaranda (
             p_carta_porte_id   => xtcp.CARTA_PORTE_ID,
             p_tipo             => 'RECEP',
             p_country          => xtpc.operating_unit_country)
             PESO_MERMA_ZARANDA_RECEP,
          xtcp.PCTAJE_VOLATIL_RECEP,
          XX_TCG_CALIDAD_PKG.
          Get_Merma_Volatil (
             p_carta_porte_id   => xtcp.CARTA_PORTE_ID,
             p_tipo             => 'RECEP',
             p_country          => xtpc.operating_unit_country)
             PESO_MERMA_VOLATIL_RECEP,
          xtcp.PCTAJE_OTROS_RECEP,
          XX_TCG_CALIDAD_PKG.
          Get_Merma_Otros (p_carta_porte_id   => xtcp.CARTA_PORTE_ID,
                           p_tipo             => 'RECEP',
                           p_country          => xtpc.operating_unit_country)
             PESO_MERMA_OTROS_RECEP,
          xtcp.PCTAJE_MATERIA_EXTRANIA_RECEP,
          ROUND (
             ( (xtcp.PESO_BRUTO_RECEPCION - xtcp.TARA_RECEPCION)
              * xtcp.PCTAJE_MATERIA_EXTRANIA_RECEP)
             / 100,
             NVL (FND_PROFILE.VALUE ('XX_ACO_PESO_CANTIDAD_DECIMALES'), 2))
             PESO_MERMA_MATERIA_EXT_RECEP,
          XX_TCG_CALIDAD_PKG.
          Get_Peso_Aplicado (p_carta_porte_id   => xtcp.CARTA_PORTE_ID,
                             p_tipo             => 'RECEP')
             PESO_APLICADO_RECEP,
          xtcp.PCTAJE_HUMEDAD_COMPRA,
          xtcp.PCTAJE_MERMA_HUMEDAD_COMPRA,
          XX_TCG_CALIDAD_PKG.
          Get_Merma_Humedad (p_carta_porte_id   => xtcp.CARTA_PORTE_ID,
                             p_tipo             => 'COMPRA')
             PESO_MERMA_HUMEDAD_COMPRA,
          xtcp.PCTAJE_ZARANDA_COMPRA,
          XX_TCG_CALIDAD_PKG.
          Get_Merma_Zaranda (
             p_carta_porte_id   => xtcp.CARTA_PORTE_ID,
             p_tipo             => 'COMPRA',
             p_country          => xtpc.operating_unit_country)
             PESO_MERMA_ZARANDA_COMPRA,
          xtcp.PCTAJE_VOLATIL_COMPRA,
          XX_TCG_CALIDAD_PKG.
          Get_Merma_Volatil (
             p_carta_porte_id   => xtcp.CARTA_PORTE_ID,
             p_tipo             => 'COMPRA',
             p_country          => xtpc.operating_unit_country)
             PESO_MERMA_VOLATIL_COMPRA,
          xtcp.PCTAJE_OTROS_COMPRA,
          XX_TCG_CALIDAD_PKG.
          Get_Merma_Otros (p_carta_porte_id   => xtcp.CARTA_PORTE_ID,
                           p_tipo             => 'COMPRA',
                           p_country          => xtpc.operating_unit_country)
             PESO_MERMA_OTROS_COMPRA,
          XX_TCG_CALIDAD_PKG.
          Get_Peso_Aplicado (p_carta_porte_id   => xtcp.CARTA_PORTE_ID,
                             p_tipo             => 'COMPRA')
             PESO_APLICADO_COMPRA,
          cTranspo.SHIP_METHOD_MEANING,
          cTranspo.QR_ID,                                            -- CR1608
          xtcp.TRANSPORTISTA_NOMBRE,
          xtcp.TRANSPORTISTA_CUIT,
          xtcp.INTERMEDIARIO_FLETE,
          xtcp.INTERMEDIARIO_FLETE_CUIT,
          xtcp.PATENTE_CAMION,
          xtcp.PATENTE_ACOPLADO,
          xtcp.CHOFER,
          xtcp.CHOFER_CUIT,
          cTranspo.SUBCONTRATADO,
          xtcp.PROCEDENCIA_ENGANCHADA,
          xtcp.DISTANCIA_ESTIMADA,
          xtcp.TARIFA_REF_FLETE_XTON,
          xtcp.COSTO_FLETE_XTON,
          xtcp.COSTO_FLETE,
          xtcp.TARIFA_CP_XTON,
          xtcp.PROVISIONAR_FLETE_FLAG,
          xtcp.PROVISIONADO_FLAG,
          xtcp.REFACTURAR_FLETE_FLAG,
          xtcp.REFACTURADO_FLAG,
          xtcp.OBSERVACION_TRANSPORTE,
          xtcp.CTG_NUMERO,
          xtcp.CEE_NUMERO,
          xtcp.COT_NUMERO,
          xtcp.RENSPA,
          xtcp.OBSERVACIONES,
          xtcp.CREATION_DATE,
          xtcp.CREATED_BY,
          xtbh.NUMERO_BOLETIN,
          xtbh.FACTOR,
          xtbh.GRADO,
          xal1.NUMERO_LIQUIDACION,
          xal1.LIQUIDACION_ID,
          XX_TCG_LISTADO_CP.get_provisionado_por_desc (xtcp.carta_porte_id)
             PROVISIONADO_POR_DESC,
          fu.user_name,
          xtcp.UO_CERTIFICA,
          xtbh.boletin_header_id,
          xtcp.item_id,
          cCttoCompra1.TITULAR_CP_CONTRATO,
          cCttoCompra2.INTERMEDIARIO_CONTRATO,
          cCttoCompra3.RTTE_COMERCIAL_CONTRATO,
          cCttoCompra4.DESTINATARIO_CONTRATO,
          xtcp.fecha_impresion,
          xtcp.fecha_impresion + NVL (xatd.tiempo_maximo / 24, 0),
          cDetallePesaje1.viaje_id,
          cDetallePesaje1.turno_viaje,
          cDetallePesaje1.cancelado_flag cancelado_flag_tb_envio
     FROM xx_tcg_cartas_porte xtcp,
          (SELECT msi.segment1 item_no,
                  msi.description item_desc,
                  msi_dfv.xx_aco_codigo_oncca item_oncca_code,
                  lv_dfv.xx_aco_especies_oncca item_oncca_especie,
                  msi.inventory_item_id item_id,
                  msi.organization_id
             FROM mtl_system_items msi,
                  mtl_system_items_b_dfv msi_dfv,
                  fnd_lookup_values_vl lv,
                  fnd_lookup_values_dfv lv_dfv
            WHERE     1 = 1
                  AND msi_dfv.row_id = msi.ROWID
                  AND lv.lookup_code = msi_dfv.xx_aco_codigo_oncca
                  AND lv.lookup_type = 'XX_ACO_ESPECIES_ONCCA'
                  AND lv_dfv.row_id = lv.row_id
                  AND lv_dfv.context = lv.attribute_category) cItems,
          (SELECT meaning TIPO_GRANO_CODIGO,
                  description TIPO_GRANO_DESC,
                  lookup_type tipo_grano
             FROM fnd_lookup_values_vl
            WHERE 1 = 1 AND lookup_type = 'XX_ACO_TIPOS_GRANO' AND 1 = 1) cTipoGrano,
          (SELECT campo TITULAR_CP_ESTAB_DESC, establecimiento_id
             FROM xx_opm_establecimientos
            WHERE 1 = 1) cEstab1,
          (SELECT campo DESTINO_ESTAB_DESC, establecimiento_id
             FROM xx_opm_establecimientos
            WHERE 1 = 1) cEstab2,
          (SELECT l.address1 TITULAR_CP_ESTAB_DESC,
                  arh_addr_pkg.format_address (l.address_style,
                                               l.address1,
                                               l.address2,
                                               l.address3,
                                               l.address4,
                                               l.city,
                                               l.county,
                                               l.state,
                                               l.province,
                                               l.postal_code,
                                               NULL)
                     concatenated_address,
                  ps.party_id,
                  ps.party_site_id
             FROM hz_party_sites ps, hz_locations l
            WHERE     1 = 1
                  AND l.location_id = ps.location_id
                  AND 1 = 1
                  AND 1 = 1) cLocation1,
          (SELECT l.address1 DESTINO_ESTAB_DESC,
                  arh_addr_pkg.format_address (l.address_style,
                                               l.address1,
                                               l.address2,
                                               l.address3,
                                               l.address4,
                                               l.city,
                                               l.county,
                                               l.state,
                                               l.province,
                                               l.postal_code,
                                               NULL)
                     concatenated_address,
                  ps.party_id,
                  ps.party_site_id
             FROM hz_party_sites ps, hz_locations l
            WHERE     1 = 1
                  AND l.location_id = ps.location_id
                  AND 1 = 1
                  AND 1 = 1) cLocation2,
          (SELECT inventory_location_id,
                  segment1 TITULAR_CP_UBICACION_DESC,
                  description
             FROM mtl_item_locations
            WHERE 1 = 1) cInvLoc1,
          (SELECT inventory_location_id,
                  segment1 DESTINO_UBICACION_DESC,
                  description
             FROM mtl_item_locations
            WHERE 1 = 1) cInvLoc2,
          (SELECT lv_prov.lookup_code provincia,
                  lv_prov.meaning TITULAR_CP_PROVINCIA_DESC,
                  lv_loc.lookup_code localidad,
                  lv_loc.description TITULAR_CP_LOCALIDAD_DESC,
                  lv_z.lookup_code zona,
                  lv_z.meaning zona_desc
             FROM fnd_lookup_values_vl lv_prov,
                  fnd_lookup_values_vl lv_loc,
                  fnd_lookup_values_dfv lv_loc_dfv,
                  fnd_lookup_values_vl lv_z
            WHERE     1 = 1
                  AND lv_loc.lookup_type(+) = 'XX_ACO_LOCALIDADES_ONCCA'
                  AND lv_loc_dfv.row_id(+) = lv_loc.ROWID
                  AND lv_z.lookup_code(+) = lv_loc_dfv.xx_aco_zonas_distancia
                  AND lv_z.lookup_type(+) = 'XX_ACO_ZONAS_DISTANCIA'
                  AND lv_prov.lookup_type(+) = 'JLZZ_STATE_PROVINCE') cLocProv1,
          (SELECT lv_prov.lookup_code provincia,
                  lv_prov.meaning DESTINO_PROVINCIA_DESC,
                  lv_loc.lookup_code localidad,
                  lv_loc.description DESTINO_LOCALIDAD_DESC,
                  lv_z.lookup_code zona,
                  lv_z.meaning zona_desc
             FROM fnd_lookup_values_vl lv_prov,
                  fnd_lookup_values_vl lv_loc,
                  fnd_lookup_values_dfv lv_loc_dfv,
                  fnd_lookup_values_vl lv_z
            WHERE     1 = 1
                  AND lv_loc.lookup_type(+) = 'XX_ACO_LOCALIDADES_ONCCA'
                  AND lv_loc_dfv.row_id(+) = lv_loc.ROWID
                  AND lv_z.lookup_code(+) = lv_loc_dfv.xx_aco_zonas_distancia
                  AND lv_z.lookup_type(+) = 'XX_ACO_ZONAS_DISTANCIA'
                  AND lv_prov.lookup_type(+) = 'JLZZ_STATE_PROVINCE') cLocProv2,
          (SELECT numero_contrato TITULAR_CP_CONTRATO, contrato_id
             FROM xx_tcg_contratos_compra
            WHERE 1 = 1) cCttoCompra1,
          (SELECT numero_contrato INTERMEDIARIO_CONTRATO, contrato_id
             FROM xx_tcg_contratos_compra
            WHERE 1 = 1) cCttoCompra2,
          (SELECT numero_contrato RTTE_COMERCIAL_CONTRATO, contrato_id
             FROM xx_tcg_contratos_compra
            WHERE 1 = 1) cCttoCompra3,
          (SELECT numero_contrato DESTINATARIO_CONTRATO, contrato_id
             FROM xx_tcg_contratos_compra
            WHERE 1 = 1) cCttoCompra4,
          (SELECT wcs.carrier_service_id,
                  /* CR1608 */
                  qpv.qr_id,
                  qpv.grupo_control,
                  /* fin CR1608 */
                  wcs.mode_of_transport MODE_OF_TRANSPORT,
                  wcs.ship_method_code,
                  wcs.ship_method_meaning SHIP_METHOD_MEANING,
                  wcsd.xx_wsh_patente_camion PATENTE_CAMION,
                  wcsd.xx_wsh_patente_acoplado PATENTE_ACOPLADO,
                  NVL (qpv.empleado_nombre, wcsd.xx_wsh_nombre_conductor)
                     CHOFER,
                  wcsd.xx_wsh_cuil_conductor CUIL,
                  NULL responsable_fc,
                  NULL cuil_ferrocarril,
                  s.segment1 TRANSPORTISTA_NUMERO,
                  s.vendor_name TRANSPORTISTA_NOMBRE,
                  s.num_1099 || s.global_attribute12 TRANSPORTISTA_CUIT,
                  UPPER (qpv.clasificacion) clasificacion,
                  qpv.subcontratado
             FROM wsh_carrier_services_v wcs,
                  wsh_carrier_services_dfv wcsd,
                  xx_opm_qr_proveedores_cp_v qpv,
                  ap_suppliers s
            WHERE     1 = 1
                  AND wcsd.row_id = wcs.row_id
                  AND qpv.carrier_service_id = wcs.carrier_service_id
                  AND s.vendor_id(+) = TO_NUMBER (wcsd.xx_aco_proveedor)
                  AND 1 = 1) cTranspo,
          (SELECT balance_name BALANZA_TARA_SAL, balance_id
             FROM xx_oe_balances
            WHERE 1 = 1) cBalanza1,
          (SELECT balance_name BALANZA_PESO_BRUTO_SAL, balance_id
             FROM xx_oe_balances
            WHERE 1 = 1) cBalanza2,
          (SELECT balance_name BALANZA_PESO_BRUTO_ENT, balance_id
             FROM xx_oe_balances
            WHERE 1 = 1) cBalanza3,
          (SELECT balance_name BALANZA_TARA_ENT, balance_id
             FROM xx_oe_balances
            WHERE 1 = 1) cBalanza4,
          (SELECT xtb.ticket_numero TICKET_ENVIO_NUMERO,
                  xtb.ticket_id,
                  xtb.balanza_tara_id BALANZA_TARA_SAL_ID,
                  xtb.tara,
                  xtb.tara_fecha TARA_SAL_FECHA,
                  xtb.tara_user_id TARA_SAL_USER_ID,
                  xtb.tara_aut_flag TARA_SAL_AUT_FLAG,
                  xtb.tara_justif TARA_SAL_JUSTIF,
                  DECODE (
                     xtb.tara,
                     NULL, NULL,
                     DECODE (
                        xtb.tara_aut_flag,
                        'Y',    'A - '
                             || user_tara.user_name
                             || ' - '
                             || xtb.tara_fecha,
                           'M - '
                        || user_tara.user_name
                        || ' - '
                        || xtb.tara_fecha))
                     TARA_SAL_DET,
                  xtb.balanza_peso_bruto_id BALANZA_PESO_BRUTO_SAL_ID,
                  xtb.peso_bruto,
                  xtb.peso_bruto_fecha PESO_BRUTO_SAL_FECHA,
                  xtb.peso_bruto_user_id PESO_BRUTO_SAL_USER_ID,
                  xtb.peso_bruto_aut_flag PESO_BRUTO_SAL_AUT_FLAG,
                  xtb.peso_bruto_justif PESO_BRUTO_SAL_JUSTIF,
                  DECODE (
                     xtb.peso_bruto,
                     NULL, NULL,
                     DECODE (
                        xtb.peso_bruto_aut_flag,
                        'Y',    'A - '
                             || user_bruto.user_name
                             || ' - '
                             || xtb.peso_bruto_fecha,
                           'M - '
                        || user_bruto.user_name
                        || ' - '
                        || xtb.peso_bruto_fecha))
                     PESO_BRUTO_SAL_DET,
                  xtb.viaje_id,                                       --CR1608
                  (SELECT DISTINCT
                          estab_lectura_id || '-' || LPAD (turno, 6, 0) turno
                     FROM xx_tcg_control_viajes_cp_v
                    WHERE viaje_id = xtb.viaje_id)
                     turno_viaje,
                  xtb.cancelado_flag                                 -- CR1608
             FROM xx_tcg_tickets_balanza xtb,
                  (SELECT DECODE (fu.user_name,
                                  NULL, ppf.full_name,
                                  fu.user_name)
                             user_name,
                          user_id
                     FROM fnd_user fu, per_people_f ppf
                    WHERE ppf.party_id(+) = fu.user_id) user_tara,
                  (SELECT DECODE (fu.user_name,
                                  NULL, ppf.full_name,
                                  fu.user_name)
                             user_name,
                          user_id
                     FROM fnd_user fu, per_people_f ppf
                    WHERE ppf.party_id(+) = fu.user_id) user_bruto
            WHERE     1 = 1
                  AND user_tara.user_id(+) = xtb.tara_user_id
                  AND user_bruto.user_id(+) = xtb.peso_bruto_user_id) cDetallePesaje1,
          (SELECT xtb.ticket_numero TICKET_RECEPCION_NUMERO,
                  xtb.ticket_id,
                  xtb.balanza_tara_id BALANZA_TARA_ENT_ID,
                  xtb.tara,
                  xtb.tara_fecha TARA_ENT_FECHA,
                  xtb.tara_user_id TARA_ENT_USER_ID,
                  xtb.tara_aut_flag TARA_ENT_AUT_FLAG,
                  xtb.tara_justif TARA_ENT_JUSTIF,
                  DECODE (
                     xtb.tara,
                     NULL, NULL,
                     DECODE (
                        xtb.tara_aut_flag,
                        'Y',    'A - '
                             || user_tara.user_name
                             || ' - '
                             || xtb.tara_fecha,
                           'M - '
                        || user_tara.user_name
                        || ' - '
                        || xtb.tara_fecha))
                     TARA_ENT_DET,
                  xtb.balanza_peso_bruto_id BALANZA_PESO_BRUTO_ENT_ID,
                  xtb.peso_bruto,
                  xtb.peso_bruto_fecha PESO_BRUTO_ENT_FECHA,
                  xtb.peso_bruto_user_id PESO_BRUTO_ENT_USER_ID,
                  xtb.peso_bruto_aut_flag PESO_BRUTO_ENT_AUT_FLAG,
                  xtb.peso_bruto_justif PESO_BRUTO_ENT_JUSTIF,
                  DECODE (
                     xtb.peso_bruto,
                     NULL, NULL,
                     DECODE (
                        xtb.peso_bruto_aut_flag,
                        'Y',    'A - '
                             || user_bruto.user_name
                             || ' - '
                             || xtb.peso_bruto_fecha,
                           'M - '
                        || user_bruto.user_name
                        || ' - '
                        || xtb.peso_bruto_fecha))
                     PESO_BRUTO_ENT_DET
             FROM xx_tcg_tickets_balanza xtb,
                  (SELECT DECODE (fu.user_name,
                                  NULL, ppf.full_name,
                                  fu.user_name)
                             user_name,
                          user_id
                     FROM fnd_user fu, per_people_f ppf
                    WHERE ppf.party_id(+) = fu.user_id) user_tara,
                  (SELECT DECODE (fu.user_name,
                                  NULL, ppf.full_name,
                                  fu.user_name)
                             user_name,
                          user_id
                     FROM fnd_user fu, per_people_f ppf
                    WHERE ppf.party_id(+) = fu.user_id) user_bruto
            WHERE     1 = 1
                  AND user_tara.user_id(+) = xtb.tara_user_id
                  AND user_bruto.user_id(+) = xtb.peso_bruto_user_id) cDetallePesaje2,
          (SELECT xtbl.carta_porte_id,
                  xtbh.NUMERO_BOLETIN,
                  xtbl.boletin_header_id,
                  xtbh.factor factor,
                  xtbh.grado_resultante grado
             --XX_TCG_LISTADO_CP.Calcular_Grado (xtbh.boletin_header_id) grado
             FROM xx_tcg_boletin_lines xtbl, xx_tcg_boletin_headers xtbh
            WHERE xtbh.boletin_header_id = xtbl.boletin_header_id
                  AND xtbh.anulado_flag = 'N') xtbh,
          (SELECT xal12.NUMERO_LIQUIDACION,
                  xal12.LIQUIDACION_ID,
                  xal12.boletin_header_id
             FROM XX_TCG_LIQUIDACIONES_1116A xal12
            WHERE xal12.cancelado_flag = 'N') xal1,
          xx_tcg_parametros_compania xtpc,
          fnd_user fu,
          XX_ACO_TARIFA_DISTANCIA xatd
    WHERE     cItems.item_id(+) = xtcp.item_id
          AND cItems.organization_id(+) = xtcp.org_id
          AND cTipoGrano.tipo_grano(+) = xtcp.tipo_grano
          AND cEstab1.establecimiento_id(+) = xtcp.titular_cp_estab_id
          AND cLocation1.party_id(+) = xtcp.titular_cp_id
          AND cLocation1.party_site_id(+) = xtcp.titular_cp_estab_id
          AND cEstab2.establecimiento_id(+) = xtcp.DESTINO_ESTAB_ID
          AND cLocation2.party_id(+) = xtcp.DESTINO_ID
          AND cLocation2.party_site_id(+) = xtcp.DESTINO_ESTAB_ID
          AND cLocProv1.provincia(+) = xtcp.titular_cp_provincia
          AND cLocProv1.localidad(+) = xtcp.titular_cp_localidad
          AND cLocProv2.provincia(+) = xtcp.DESTINO_PROVINCIA
          AND cLocProv2.localidad(+) = xtcp.DESTINO_LOCALIDAD
          AND cInvLoc1.inventory_location_id(+) = xtcp.titular_cp_ubicacion
          AND cInvLoc2.inventory_location_id(+) = xtcp.DESTINO_UBICACION
          AND cCttoCompra1.contrato_id(+) = xtcp.titular_cp_contrato_id
          AND cCttoCompra2.contrato_id(+) = xtcp.intermediario_contrato_id
          AND cCttoCompra3.contrato_id(+) = xtcp.rtte_comercial_contrato_id
          AND cCttoCompra4.contrato_id(+) = xtcp.destinatario_contrato_id
          AND cTranspo.carrier_service_id(+) = xtcp.carrier_service_id
          AND cTranspo.grupo_control(+) = xtpc.grupo_control          --CR1608
          AND cDetallePesaje1.ticket_id(+) = xtcp.TICKET_ENVIO_ID
          AND cDetallePesaje2.ticket_id(+) = xtcp.TICKET_RECEPCION_ID
          AND cBalanza1.balance_id(+) = cDetallePesaje1.BALANZA_TARA_SAL_ID
          AND cBalanza2.balance_id(+) =
                 cDetallePesaje1.BALANZA_PESO_BRUTO_SAL_ID
          AND cBalanza3.balance_id(+) =
                 cDetallePesaje2.BALANZA_PESO_BRUTO_ENT_ID
          AND cBalanza4.balance_id(+) = cDetallePesaje2.BALANZA_TARA_ENT_ID
          AND xtbh.carta_porte_id(+) = xtcp.carta_porte_id
          AND xal1.boletin_header_id(+) = xtbh.boletin_header_id
          AND xtpc.operating_unit(+) = xtcp.operating_unit
          AND fu.user_id(+) = xtcp.created_by
          AND xatd.distancia_id(+) = xtcp.distancia_id          
          AND xtcp.creation_Date > to_Date('01/01/2020','DD/MM/RRRR');

grant select on XX_TCG_CARTAS_PORTE_CV_V to ADECO_BI;

CREATE OR REPLACE VIEW APPS.XX_TCG_CARTAS_PORTE_CV_V
(
   NUMERO_CARTA_PORTE,
   CARTA_PORTE_RELACIONADA,
   CARTA_PORTE_ID,
   ITEM_NO,
   ITEM_DESC,
   LOT_NO,
   TIPO_GRANO,
   TIPO_GRANO_DESC,
   ITEM_ONCCA_CODE,
   ITEM_ONCCA_ESPECIE,
   TRANSFERIDO_FLAG,
   RECIBIDO_FLAG,
   ANULADO_FLAG,
   PESAJE_SALIDA_FLAG,
   PESAJE_ENTRADA_FLAG,
   TITULAR_CP_TIPO,
   TITULAR_CP,
   TITULAR_CP_ID,
   TITULAR_CP_CUIT,
   TITULAR_CP_ESTAB_ID,
   TITULAR_CP_ESTAB_DESC,
   TITULAR_CP_UBICACION_DESC,
   TITULAR_CP_PROVINCIA,
   TITULAR_CP_PROVINCIA_DESC,
   TITULAR_CP_LOCALIDAD,
   TITULAR_CP_LOCALIDAD_DESC,
   TITULAR_CP_DIRECCION,
   TITULAR_CP_CONTRATO_ID,
   ORIGEN_TIPO,
   INTERMEDIARIO_TIPO,
   INTERMEDIARIO,
   INTERMEDIARIO_ID,
   INTERMEDIARIO_CUIT,
   INTERMEDIARIO_RETIRO,
   INTERMEDIARIO_CONTRATO_ID,
   RTTE_COMERCIAL_TIPO,
   RTTE_COMERCIAL,
   RTTE_COMERCIAL_ID,
   RTTE_COMERCIAL_RETIRO,
   RTTE_COMERCIAL_CONTRATO_ID,
   CORREDOR_CUIT,
   CORREDOR,
   CORREDOR_ID,
   MERCADO_TERMINO_CUIT,
   MERCADO_TERMINO,
   MERCADO_TERMINO_ID,
   CORREDOR_VENDEDOR_CUIT,
   CORREDOR_VENDEDOR,
   CORREDOR_VENDEDOR_ID,
   REPRESENTANTE_CUIT,
   REPRESENTANTE,
   REPRESENTANTE_ID,
   DESTINATARIO_CUIT,
   DESTINATARIO,
   DESTINATARIO_ID,
   DESTINATARIO_CONTRATO_ID,
   DESTINO,
   DESTINO_ID,
   DESTINO_CUIT,
   DESTINO_ESTAB_ID,
   DESTINO_ESTAB_DESC,
   DESTINO_UBICACION,
   DESTINO_UBICACION_DESC,
   DESTINO_PROVINCIA,
   DESTINO_PROVINCIA_DESC,
   DESTINO_LOCALIDAD,
   DESTINO_LOCALIDAD_DESC,
   DESTINO_DIRECCION,
   DESTINO_TIPO,
   FECHA_ENVIO,
   FECHA_CARGA,
   CANTIDAD_HORAS,
   TICKET_ENVIO_NUMERO,
   TARA_ENVIO,
   PESO_BRUTO_ENVIO,
   PESO_NETO_ENVIO,
   PESO_ESTIMADO,
   PESO_TRANSFERIDO,
   PCTAJE_HUMEDAD_ESTIMADA,
   PCTAJE_MERMA_HUMEDAD_ENVIO,
   PESO_HUMEDAD_ESTIMADA,
   PCTAJE_MATERIA_EXTRANIA_ENVIO,
   PESO_MATERIA_EXTRANIA_ENVIO,
   LOTE,
   VARIEDAD,
   TIPO_CALIDAD_ENVIO,
   FECHA_RECEPCION,
   TICKET_RECEPCION_NUMERO,
   PESO_BRUTO_RECEPCION,
   TARA_RECEPCION,
   PESO_NETO_RECEPCION,
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
   SHIP_METHOD_MEANING,
   QR_ID,
   TRANSPORTISTA_NOMBRE,
   TRANSPORTISTA_CUIT,
   INTERMEDIARIO_FLETE,
   INTERMEDIARIO_FLETE_CUIT,
   PATENTE_CAMION,
   PATENTE_ACOPLADO,
   CHOFER,
   CUIL,
   SUBCONTRATADO,
   PROCEDENCIA_ENGANCHADA,
   DISTANCIA_ESTIMADA,
   TARIFA_REF_FLETE_XTON,
   COSTO_FLETE_XTON,
   COSTO_FLETE,
   TARIFA_CP_XTON,
   PROVISIONAR_FLETE_FLAG,
   PROVISIONADO_FLAG,
   REFACTURAR_FLETE_FLAG,
   REFACTURADO_FLAG,
   OBSERVACION_TRANSPORTE,
   CTG_NUMERO,
   CEE_NUMERO,
   COT_NUMERO,
   RENSPA,
   OBSERVACIONES,
   CREATION_DATE,
   CREATED_BY,
   NUMERO_BOLETIN,
   FACTOR,
   GRADO,
   NUMERO_LIQUIDACION,
   LIQUIDACION_ID,
   PROVISIONADO_POR_DESC,
   USER_NAME,
   UO_CERTIFICA,
   BOLETIN_HEADER_ID,
   ITEM_ID,
   TITULAR_CP_CONTRATO,
   INTERMEDIARIO_CONTRATO,
   RTTE_COMERCIAL_CONTRATO,
   DESTINATARIO_CONTRATO,
   FECHA_IMPRESION,
   ARRIBO_ESTIMADO,
   VIAJE_ID,
   TURNO_VIAJE,
   CANCELADO_FLAG_TB_ENVIO
)
AS
   SELECT DISTINCT
          xtcp.NUMERO_CARTA_PORTE,
          xtcp.CARTA_PORTE_RELACIONADA,
          xtcp.CARTA_PORTE_ID,
          cItems.ITEM_NO,
          cItems.ITEM_DESC,
          xtcp.LOT_NO,
          xtcp.TIPO_GRANO,
          cTipoGrano.TIPO_GRANO_DESC,
          cItems.ITEM_ONCCA_CODE,
          cItems.ITEM_ONCCA_ESPECIE,
          xtcp.TRANSFERIDO_FLAG,
          xtcp.RECIBIDO_FLAG,
          xtcp.ANULADO_FLAG,
          xtcp.PESAJE_SALIDA_FLAG,
          xtcp.PESAJE_ENTRADA_FLAG,
          xtcp.TITULAR_CP_TIPO,
          xtcp.TITULAR_CP,
          xtcp.TITULAR_CP_ID,
          xtcp.TITULAR_CP_CUIT,
          xtcp.TITULAR_CP_ESTAB_ID,
          DECODE (XX_TCG_LISTADO_CP.Es_Empresa_Grupo (xtcp.TITULAR_CP_CUIT),
                  'Y', cEstab1.TITULAR_CP_ESTAB_DESC,
                  cLocation1.TITULAR_CP_ESTAB_DESC)
             TITULAR_CP_ESTAB_DESC,
          cInvLoc1.TITULAR_CP_UBICACION_DESC,
          xtcp.TITULAR_CP_PROVINCIA,
          cLocProv1.TITULAR_CP_PROVINCIA_DESC,
          xtcp.TITULAR_CP_LOCALIDAD,
          cLocProv1.TITULAR_CP_LOCALIDAD_DESC,
          xtcp.TITULAR_CP_DIRECCION,
          xtcp.TITULAR_CP_CONTRATO_ID,
          XX_TCG_LISTADO_CP.
          Get_Tipo_Origen_Destino_CP (xtcp.TITULAR_CP_CUIT,
                                      xtcp.TITULAR_CP_ESTAB_ID,
                                      xtcp.CARTA_PORTE_ID)
             ORIGEN_TIPO,
          xtcp.INTERMEDIARIO_TIPO,
          xtcp.INTERMEDIARIO,
          xtcp.INTERMEDIARIO_ID,
          xtcp.INTERMEDIARIO_CUIT,
          xtcp.INTERMEDIARIO_RETIRO,
          xtcp.INTERMEDIARIO_CONTRATO_ID,
          xtcp.RTTE_COMERCIAL_TIPO,
          xtcp.RTTE_COMERCIAL,
          xtcp.RTTE_COMERCIAL_ID,
          xtcp.RTTE_COMERCIAL_RETIRO,
          xtcp.RTTE_COMERCIAL_CONTRATO_ID,
          xtcp.CORREDOR_CUIT,
          xtcp.CORREDOR,
          xtcp.CORREDOR_ID,
          xtcp.MERCADO_TERMINO_CUIT,
          xtcp.MERCADO_TERMINO,
          xtcp.MERCADO_TERMINO_ID,
          xtcp.CORREDOR_VENDEDOR_CUIT,
          xtcp.CORREDOR_VENDEDOR,
          xtcp.CORREDOR_VENDEDOR_ID,
          xtcp.REPRESENTANTE_CUIT,
          xtcp.REPRESENTANTE,
          xtcp.REPRESENTANTE_ID,
          xtcp.DESTINATARIO_CUIT,
          xtcp.DESTINATARIO,
          xtcp.DESTINATARIO_ID,
          xtcp.DESTINATARIO_CONTRATO_ID,
          xtcp.DESTINO,
          xtcp.DESTINO_ID,
          xtcp.DESTINO_CUIT,
          xtcp.DESTINO_ESTAB_ID,
          DECODE (XX_TCG_LISTADO_CP.Es_Empresa_Grupo (xtcp.DESTINO_CUIT),
                  'Y', cEstab2.DESTINO_ESTAB_DESC,
                  cLocation2.DESTINO_ESTAB_DESC)
             DESTINO_ESTAB_DESC,
          xtcp.DESTINO_UBICACION,
          cInvLoc2.DESTINO_UBICACION_DESC,
          xtcp.DESTINO_PROVINCIA,
          cLocProv2.DESTINO_PROVINCIA_DESC,
          xtcp.DESTINO_LOCALIDAD,
          cLocProv2.DESTINO_LOCALIDAD_DESC,
          xtcp.DESTINO_DIRECCION,
          XX_TCG_LISTADO_CP.
          Get_Tipo_Origen_Destino_CP (xtcp.DESTINO_CUIT,
                                      xtcp.DESTINO_ESTAB_ID,
                                      xtcp.CARTA_PORTE_ID)
             DESTINO_TIPO,
          xtcp.FECHA_ENVIO,
          xtcp.FECHA_CARGA,
          xtcp.CANTIDAD_HORAS,
          cDetallePesaje1.TICKET_ENVIO_NUMERO,
          xtcp.TARA_ENVIO,
          xtcp.PESO_BRUTO_ENVIO,
          (xtcp.PESO_BRUTO_ENVIO - xtcp.TARA_ENVIO) PESO_NETO_ENVIO,
          xtcp.PESO_ESTIMADO,
          xtcp.PESO_TRANSFERIDO,
          xtcp.PCTAJE_HUMEDAD_ESTIMADA,
          xtcp.PCTAJE_MERMA_HUMEDAD_ENVIO,
          XX_TCG_CALIDAD_PKG.
          Get_Peso_Merma_Humedad (
             p_peso                 => NVL (
                                         xtcp.peso_estimado,
                                         NVL (xtcp.peso_bruto_envio, 0)
                                         - NVL (xtcp.tara_envio, 0)),
             p_porcentaje_humedad   => xtcp.pctaje_humedad_estimada,
             p_item_oncca_code      => cItems.ITEM_ONCCA_CODE,
             p_item_id              => xtcp.item_id,
             p_party_id             => xtcp.destino_id,
             p_party_site_id        => xtcp.destino_estab_id,
             p_grupo_control        => '01')
             peso_humedad_estimada,
          xtcp.PCTAJE_MATERIA_EXTRANIA_ENVIO,
          ROUND (
             ( (NVL (
                   xtcp.peso_estimado,
                   NVL (xtcp.peso_bruto_envio, 0) - NVL (xtcp.tara_envio, 0))
                - XX_TCG_CALIDAD_PKG.
                  Get_Peso_Merma_Humedad (
                     p_peso                 => NVL (
                                                 xtcp.peso_estimado,
                                                 NVL (xtcp.peso_bruto_envio, 0)
                                                 - NVL (xtcp.tara_envio, 0)),
                     p_porcentaje_humedad   => xtcp.pctaje_humedad_estimada,
                     p_item_oncca_code      => cItems.ITEM_ONCCA_CODE,
                     p_item_id              => xtcp.item_id,
                     p_party_id             => xtcp.destino_id,
                     p_party_site_id        => xtcp.destino_estab_id,
                     p_grupo_control        => '01'))
              * xtcp.pctaje_materia_extrania_envio)
             / 100,
             NVL (FND_PROFILE.VALUE ('XX_ACO_PESO_CANTIDAD_DECIMALES'), 2))
             peso_materia_extrania_envio,
          xtcp.LOTE,
          xtcp.VARIEDAD,
          xtcp.TIPO_CALIDAD_ENVIO,
          xtcp.FECHA_RECEPCION,
          cDetallePesaje2.TICKET_RECEPCION_NUMERO,
          xtcp.PESO_BRUTO_RECEPCION,
          xtcp.TARA_RECEPCION,
          (xtcp.PESO_BRUTO_RECEPCION - xtcp.TARA_RECEPCION)
             PESO_NETO_RECEPCION,
          xtcp.PCTAJE_HUMEDAD_RECEP,
          xtcp.PCTAJE_MERMA_HUMEDAD_RECEP,
          XX_TCG_CALIDAD_PKG.
          Get_Merma_Humedad (p_carta_porte_id => xtcp.CARTA_PORTE_ID)
             PESO_MERMA_HUMEDAD_RECEP,
          xtcp.PCTAJE_ZARANDA_RECEP,
          XX_TCG_CALIDAD_PKG.
          Get_Merma_Zaranda (
             p_carta_porte_id   => xtcp.CARTA_PORTE_ID,
             p_tipo             => 'RECEP',
             p_country          => xtpc.operating_unit_country)
             PESO_MERMA_ZARANDA_RECEP,
          xtcp.PCTAJE_VOLATIL_RECEP,
          XX_TCG_CALIDAD_PKG.
          Get_Merma_Volatil (
             p_carta_porte_id   => xtcp.CARTA_PORTE_ID,
             p_tipo             => 'RECEP',
             p_country          => xtpc.operating_unit_country)
             PESO_MERMA_VOLATIL_RECEP,
          xtcp.PCTAJE_OTROS_RECEP,
          XX_TCG_CALIDAD_PKG.
          Get_Merma_Otros (p_carta_porte_id   => xtcp.CARTA_PORTE_ID,
                           p_tipo             => 'RECEP',
                           p_country          => xtpc.operating_unit_country)
             PESO_MERMA_OTROS_RECEP,
          xtcp.PCTAJE_MATERIA_EXTRANIA_RECEP,
          ROUND (
             ( (xtcp.PESO_BRUTO_RECEPCION - xtcp.TARA_RECEPCION)
              * xtcp.PCTAJE_MATERIA_EXTRANIA_RECEP)
             / 100,
             NVL (FND_PROFILE.VALUE ('XX_ACO_PESO_CANTIDAD_DECIMALES'), 2))
             PESO_MERMA_MATERIA_EXT_RECEP,
          XX_TCG_CALIDAD_PKG.
          Get_Peso_Aplicado (p_carta_porte_id   => xtcp.CARTA_PORTE_ID,
                             p_tipo             => 'RECEP')
             PESO_APLICADO_RECEP,
          xtcp.PCTAJE_HUMEDAD_COMPRA,
          xtcp.PCTAJE_MERMA_HUMEDAD_COMPRA,
          XX_TCG_CALIDAD_PKG.
          Get_Merma_Humedad (p_carta_porte_id   => xtcp.CARTA_PORTE_ID,
                             p_tipo             => 'COMPRA')
             PESO_MERMA_HUMEDAD_COMPRA,
          xtcp.PCTAJE_ZARANDA_COMPRA,
          XX_TCG_CALIDAD_PKG.
          Get_Merma_Zaranda (
             p_carta_porte_id   => xtcp.CARTA_PORTE_ID,
             p_tipo             => 'COMPRA',
             p_country          => xtpc.operating_unit_country)
             PESO_MERMA_ZARANDA_COMPRA,
          xtcp.PCTAJE_VOLATIL_COMPRA,
          XX_TCG_CALIDAD_PKG.
          Get_Merma_Volatil (
             p_carta_porte_id   => xtcp.CARTA_PORTE_ID,
             p_tipo             => 'COMPRA',
             p_country          => xtpc.operating_unit_country)
             PESO_MERMA_VOLATIL_COMPRA,
          xtcp.PCTAJE_OTROS_COMPRA,
          XX_TCG_CALIDAD_PKG.
          Get_Merma_Otros (p_carta_porte_id   => xtcp.CARTA_PORTE_ID,
                           p_tipo             => 'COMPRA',
                           p_country          => xtpc.operating_unit_country)
             PESO_MERMA_OTROS_COMPRA,
          XX_TCG_CALIDAD_PKG.
          Get_Peso_Aplicado (p_carta_porte_id   => xtcp.CARTA_PORTE_ID,
                             p_tipo             => 'COMPRA')
             PESO_APLICADO_COMPRA,
          cTranspo.SHIP_METHOD_MEANING,
          cTranspo.QR_ID,                                            -- CR1608
          xtcp.TRANSPORTISTA_NOMBRE,
          xtcp.TRANSPORTISTA_CUIT,
          xtcp.INTERMEDIARIO_FLETE,
          xtcp.INTERMEDIARIO_FLETE_CUIT,
          xtcp.PATENTE_CAMION,
          xtcp.PATENTE_ACOPLADO,
          xtcp.CHOFER,
          xtcp.CHOFER_CUIT,
          cTranspo.SUBCONTRATADO,
          xtcp.PROCEDENCIA_ENGANCHADA,
          xtcp.DISTANCIA_ESTIMADA,
          xtcp.TARIFA_REF_FLETE_XTON,
          xtcp.COSTO_FLETE_XTON,
          xtcp.COSTO_FLETE,
          xtcp.TARIFA_CP_XTON,
          xtcp.PROVISIONAR_FLETE_FLAG,
          xtcp.PROVISIONADO_FLAG,
          xtcp.REFACTURAR_FLETE_FLAG,
          xtcp.REFACTURADO_FLAG,
          xtcp.OBSERVACION_TRANSPORTE,
          xtcp.CTG_NUMERO,
          xtcp.CEE_NUMERO,
          xtcp.COT_NUMERO,
          xtcp.RENSPA,
          xtcp.OBSERVACIONES,
          xtcp.CREATION_DATE,
          xtcp.CREATED_BY,
          xtbh.NUMERO_BOLETIN,
          xtbh.FACTOR,
          xtbh.GRADO,
          xal1.NUMERO_LIQUIDACION,
          xal1.LIQUIDACION_ID,
          XX_TCG_LISTADO_CP.get_provisionado_por_desc (xtcp.carta_porte_id)
             PROVISIONADO_POR_DESC,
          fu.user_name,
          xtcp.UO_CERTIFICA,
          xtbh.boletin_header_id,
          xtcp.item_id,
          cCttoCompra1.TITULAR_CP_CONTRATO,
          cCttoCompra2.INTERMEDIARIO_CONTRATO,
          cCttoCompra3.RTTE_COMERCIAL_CONTRATO,
          cCttoCompra4.DESTINATARIO_CONTRATO,
          xtcp.fecha_impresion,
          xtcp.fecha_impresion + NVL (xatd.tiempo_maximo / 24, 0),
          cDetallePesaje1.viaje_id,
          cDetallePesaje1.turno_viaje,
          cDetallePesaje1.cancelado_flag cancelado_flag_tb_envio
     FROM xx_tcg_cartas_porte xtcp,
          (SELECT msi.segment1 item_no,
                  msi.description item_desc,
                  msi_dfv.xx_aco_codigo_oncca item_oncca_code,
                  lv_dfv.xx_aco_especies_oncca item_oncca_especie,
                  msi.inventory_item_id item_id,
                  msi.organization_id
             FROM mtl_system_items msi,
                  mtl_system_items_b_dfv msi_dfv,
                  fnd_lookup_values_vl lv,
                  fnd_lookup_values_dfv lv_dfv
            WHERE     1 = 1
                  AND msi_dfv.row_id = msi.ROWID
                  AND lv.lookup_code = msi_dfv.xx_aco_codigo_oncca
                  AND lv.lookup_type = 'XX_ACO_ESPECIES_ONCCA'
                  AND lv_dfv.row_id = lv.row_id
                  AND lv_dfv.context = lv.attribute_category) cItems,
          (SELECT meaning TIPO_GRANO_CODIGO,
                  description TIPO_GRANO_DESC,
                  lookup_type tipo_grano
             FROM fnd_lookup_values_vl
            WHERE 1 = 1 AND lookup_type = 'XX_ACO_TIPOS_GRANO' AND 1 = 1) cTipoGrano,
          (SELECT campo TITULAR_CP_ESTAB_DESC, establecimiento_id
             FROM xx_opm_establecimientos
            WHERE 1 = 1) cEstab1,
          (SELECT campo DESTINO_ESTAB_DESC, establecimiento_id
             FROM xx_opm_establecimientos
            WHERE 1 = 1) cEstab2,
          (SELECT l.address1 TITULAR_CP_ESTAB_DESC,
                  arh_addr_pkg.format_address (l.address_style,
                                               l.address1,
                                               l.address2,
                                               l.address3,
                                               l.address4,
                                               l.city,
                                               l.county,
                                               l.state,
                                               l.province,
                                               l.postal_code,
                                               NULL)
                     concatenated_address,
                  ps.party_id,
                  ps.party_site_id
             FROM hz_party_sites ps, hz_locations l
            WHERE     1 = 1
                  AND l.location_id = ps.location_id
                  AND 1 = 1
                  AND 1 = 1) cLocation1,
          (SELECT l.address1 DESTINO_ESTAB_DESC,
                  arh_addr_pkg.format_address (l.address_style,
                                               l.address1,
                                               l.address2,
                                               l.address3,
                                               l.address4,
                                               l.city,
                                               l.county,
                                               l.state,
                                               l.province,
                                               l.postal_code,
                                               NULL)
                     concatenated_address,
                  ps.party_id,
                  ps.party_site_id
             FROM hz_party_sites ps, hz_locations l
            WHERE     1 = 1
                  AND l.location_id = ps.location_id
                  AND 1 = 1
                  AND 1 = 1) cLocation2,
          (SELECT inventory_location_id,
                  segment1 TITULAR_CP_UBICACION_DESC,
                  description
             FROM mtl_item_locations
            WHERE 1 = 1) cInvLoc1,
          (SELECT inventory_location_id,
                  segment1 DESTINO_UBICACION_DESC,
                  description
             FROM mtl_item_locations
            WHERE 1 = 1) cInvLoc2,
          (SELECT lv_prov.lookup_code provincia,
                  lv_prov.meaning TITULAR_CP_PROVINCIA_DESC,
                  lv_loc.lookup_code localidad,
                  lv_loc.description TITULAR_CP_LOCALIDAD_DESC,
                  lv_z.lookup_code zona,
                  lv_z.meaning zona_desc
             FROM fnd_lookup_values_vl lv_prov,
                  fnd_lookup_values_vl lv_loc,
                  fnd_lookup_values_dfv lv_loc_dfv,
                  fnd_lookup_values_vl lv_z
            WHERE     1 = 1
                  AND lv_loc.lookup_type(+) = 'XX_ACO_LOCALIDADES_ONCCA'
                  AND lv_loc_dfv.row_id(+) = lv_loc.ROWID
                  AND lv_z.lookup_code(+) = lv_loc_dfv.xx_aco_zonas_distancia
                  AND lv_z.lookup_type(+) = 'XX_ACO_ZONAS_DISTANCIA'
                  AND lv_prov.lookup_type(+) = 'JLZZ_STATE_PROVINCE') cLocProv1,
          (SELECT lv_prov.lookup_code provincia,
                  lv_prov.meaning DESTINO_PROVINCIA_DESC,
                  lv_loc.lookup_code localidad,
                  lv_loc.description DESTINO_LOCALIDAD_DESC,
                  lv_z.lookup_code zona,
                  lv_z.meaning zona_desc
             FROM fnd_lookup_values_vl lv_prov,
                  fnd_lookup_values_vl lv_loc,
                  fnd_lookup_values_dfv lv_loc_dfv,
                  fnd_lookup_values_vl lv_z
            WHERE     1 = 1
                  AND lv_loc.lookup_type(+) = 'XX_ACO_LOCALIDADES_ONCCA'
                  AND lv_loc_dfv.row_id(+) = lv_loc.ROWID
                  AND lv_z.lookup_code(+) = lv_loc_dfv.xx_aco_zonas_distancia
                  AND lv_z.lookup_type(+) = 'XX_ACO_ZONAS_DISTANCIA'
                  AND lv_prov.lookup_type(+) = 'JLZZ_STATE_PROVINCE') cLocProv2,
          (SELECT numero_contrato TITULAR_CP_CONTRATO, contrato_id
             FROM xx_tcg_contratos_compra
            WHERE 1 = 1) cCttoCompra1,
          (SELECT numero_contrato INTERMEDIARIO_CONTRATO, contrato_id
             FROM xx_tcg_contratos_compra
            WHERE 1 = 1) cCttoCompra2,
          (SELECT numero_contrato RTTE_COMERCIAL_CONTRATO, contrato_id
             FROM xx_tcg_contratos_compra
            WHERE 1 = 1) cCttoCompra3,
          (SELECT numero_contrato DESTINATARIO_CONTRATO, contrato_id
             FROM xx_tcg_contratos_compra
            WHERE 1 = 1) cCttoCompra4,
          (SELECT wcs.carrier_service_id,
                  /* CR1608 */
                  qpv.qr_id,
                  qpv.grupo_control,
                  /* fin CR1608 */
                  wcs.mode_of_transport MODE_OF_TRANSPORT,
                  wcs.ship_method_code,
                  wcs.ship_method_meaning SHIP_METHOD_MEANING,
                  wcsd.xx_wsh_patente_camion PATENTE_CAMION,
                  wcsd.xx_wsh_patente_acoplado PATENTE_ACOPLADO,
                  NVL (qpv.empleado_nombre, wcsd.xx_wsh_nombre_conductor)
                     CHOFER,
                  wcsd.xx_wsh_cuil_conductor CUIL,
                  NULL responsable_fc,
                  NULL cuil_ferrocarril,
                  s.segment1 TRANSPORTISTA_NUMERO,
                  s.vendor_name TRANSPORTISTA_NOMBRE,
                  s.num_1099 || s.global_attribute12 TRANSPORTISTA_CUIT,
                  UPPER (qpv.clasificacion) clasificacion,
                  qpv.subcontratado
             FROM wsh_carrier_services_v wcs,
                  wsh_carrier_services_dfv wcsd,
                  xx_opm_qr_proveedores_cp_v qpv,
                  ap_suppliers s
            WHERE     1 = 1
                  AND wcsd.row_id = wcs.row_id
                  AND qpv.carrier_service_id = wcs.carrier_service_id
                  AND s.vendor_id(+) = TO_NUMBER (wcsd.xx_aco_proveedor)
                  AND 1 = 1) cTranspo,
          (SELECT balance_name BALANZA_TARA_SAL, balance_id
             FROM xx_oe_balances
            WHERE 1 = 1) cBalanza1,
          (SELECT balance_name BALANZA_PESO_BRUTO_SAL, balance_id
             FROM xx_oe_balances
            WHERE 1 = 1) cBalanza2,
          (SELECT balance_name BALANZA_PESO_BRUTO_ENT, balance_id
             FROM xx_oe_balances
            WHERE 1 = 1) cBalanza3,
          (SELECT balance_name BALANZA_TARA_ENT, balance_id
             FROM xx_oe_balances
            WHERE 1 = 1) cBalanza4,
          (SELECT xtb.ticket_numero TICKET_ENVIO_NUMERO,
                  xtb.ticket_id,
                  xtb.balanza_tara_id BALANZA_TARA_SAL_ID,
                  xtb.tara,
                  xtb.tara_fecha TARA_SAL_FECHA,
                  xtb.tara_user_id TARA_SAL_USER_ID,
                  xtb.tara_aut_flag TARA_SAL_AUT_FLAG,
                  xtb.tara_justif TARA_SAL_JUSTIF,
                  DECODE (
                     xtb.tara,
                     NULL, NULL,
                     DECODE (
                        xtb.tara_aut_flag,
                        'Y',    'A - '
                             || user_tara.user_name
                             || ' - '
                             || xtb.tara_fecha,
                           'M - '
                        || user_tara.user_name
                        || ' - '
                        || xtb.tara_fecha))
                     TARA_SAL_DET,
                  xtb.balanza_peso_bruto_id BALANZA_PESO_BRUTO_SAL_ID,
                  xtb.peso_bruto,
                  xtb.peso_bruto_fecha PESO_BRUTO_SAL_FECHA,
                  xtb.peso_bruto_user_id PESO_BRUTO_SAL_USER_ID,
                  xtb.peso_bruto_aut_flag PESO_BRUTO_SAL_AUT_FLAG,
                  xtb.peso_bruto_justif PESO_BRUTO_SAL_JUSTIF,
                  DECODE (
                     xtb.peso_bruto,
                     NULL, NULL,
                     DECODE (
                        xtb.peso_bruto_aut_flag,
                        'Y',    'A - '
                             || user_bruto.user_name
                             || ' - '
                             || xtb.peso_bruto_fecha,
                           'M - '
                        || user_bruto.user_name
                        || ' - '
                        || xtb.peso_bruto_fecha))
                     PESO_BRUTO_SAL_DET,
                  xtb.viaje_id,                                       --CR1608
                  (SELECT DISTINCT
                          estab_lectura_id || '-' || LPAD (turno, 6, 0) turno
                     FROM xx_tcg_control_viajes_cp_v
                    WHERE viaje_id = xtb.viaje_id)
                     turno_viaje,
                  xtb.cancelado_flag                                 -- CR1608
             FROM xx_tcg_tickets_balanza xtb,
                  (SELECT DECODE (fu.user_name,
                                  NULL, ppf.full_name,
                                  fu.user_name)
                             user_name,
                          user_id
                     FROM fnd_user fu, per_people_f ppf
                    WHERE ppf.party_id(+) = fu.user_id) user_tara,
                  (SELECT DECODE (fu.user_name,
                                  NULL, ppf.full_name,
                                  fu.user_name)
                             user_name,
                          user_id
                     FROM fnd_user fu, per_people_f ppf
                    WHERE ppf.party_id(+) = fu.user_id) user_bruto
            WHERE     1 = 1
                  AND user_tara.user_id(+) = xtb.tara_user_id
                  AND user_bruto.user_id(+) = xtb.peso_bruto_user_id) cDetallePesaje1,
          (SELECT xtb.ticket_numero TICKET_RECEPCION_NUMERO,
                  xtb.ticket_id,
                  xtb.balanza_tara_id BALANZA_TARA_ENT_ID,
                  xtb.tara,
                  xtb.tara_fecha TARA_ENT_FECHA,
                  xtb.tara_user_id TARA_ENT_USER_ID,
                  xtb.tara_aut_flag TARA_ENT_AUT_FLAG,
                  xtb.tara_justif TARA_ENT_JUSTIF,
                  DECODE (
                     xtb.tara,
                     NULL, NULL,
                     DECODE (
                        xtb.tara_aut_flag,
                        'Y',    'A - '
                             || user_tara.user_name
                             || ' - '
                             || xtb.tara_fecha,
                           'M - '
                        || user_tara.user_name
                        || ' - '
                        || xtb.tara_fecha))
                     TARA_ENT_DET,
                  xtb.balanza_peso_bruto_id BALANZA_PESO_BRUTO_ENT_ID,
                  xtb.peso_bruto,
                  xtb.peso_bruto_fecha PESO_BRUTO_ENT_FECHA,
                  xtb.peso_bruto_user_id PESO_BRUTO_ENT_USER_ID,
                  xtb.peso_bruto_aut_flag PESO_BRUTO_ENT_AUT_FLAG,
                  xtb.peso_bruto_justif PESO_BRUTO_ENT_JUSTIF,
                  DECODE (
                     xtb.peso_bruto,
                     NULL, NULL,
                     DECODE (
                        xtb.peso_bruto_aut_flag,
                        'Y',    'A - '
                             || user_bruto.user_name
                             || ' - '
                             || xtb.peso_bruto_fecha,
                           'M - '
                        || user_bruto.user_name
                        || ' - '
                        || xtb.peso_bruto_fecha))
                     PESO_BRUTO_ENT_DET
             FROM xx_tcg_tickets_balanza xtb,
                  (SELECT DECODE (fu.user_name,
                                  NULL, ppf.full_name,
                                  fu.user_name)
                             user_name,
                          user_id
                     FROM fnd_user fu, per_people_f ppf
                    WHERE ppf.party_id(+) = fu.user_id) user_tara,
                  (SELECT DECODE (fu.user_name,
                                  NULL, ppf.full_name,
                                  fu.user_name)
                             user_name,
                          user_id
                     FROM fnd_user fu, per_people_f ppf
                    WHERE ppf.party_id(+) = fu.user_id) user_bruto
            WHERE     1 = 1
                  AND user_tara.user_id(+) = xtb.tara_user_id
                  AND user_bruto.user_id(+) = xtb.peso_bruto_user_id) cDetallePesaje2,
          (SELECT xtbl.carta_porte_id,
                  xtbh.NUMERO_BOLETIN,
                  xtbl.boletin_header_id,
                  xtbh.factor factor,
                  xtbh.grado_resultante grado
             --XX_TCG_LISTADO_CP.Calcular_Grado (xtbh.boletin_header_id) grado
             FROM xx_tcg_boletin_lines xtbl, xx_tcg_boletin_headers xtbh
            WHERE xtbh.boletin_header_id = xtbl.boletin_header_id
                  AND xtbh.anulado_flag = 'N') xtbh,
          (SELECT xal12.NUMERO_LIQUIDACION,
                  xal12.LIQUIDACION_ID,
                  xal12.boletin_header_id
             FROM XX_TCG_LIQUIDACIONES_1116A xal12
            WHERE xal12.cancelado_flag = 'N') xal1,
          xx_tcg_parametros_compania xtpc,
          fnd_user fu,
          XX_ACO_TARIFA_DISTANCIA xatd
    WHERE     cItems.item_id(+) = xtcp.item_id
          AND cItems.organization_id(+) = xtcp.org_id
          AND cTipoGrano.tipo_grano(+) = xtcp.tipo_grano
          AND cEstab1.establecimiento_id(+) = xtcp.titular_cp_estab_id
          AND cLocation1.party_id(+) = xtcp.titular_cp_id
          AND cLocation1.party_site_id(+) = xtcp.titular_cp_estab_id
          AND cEstab2.establecimiento_id(+) = xtcp.DESTINO_ESTAB_ID
          AND cLocation2.party_id(+) = xtcp.DESTINO_ID
          AND cLocation2.party_site_id(+) = xtcp.DESTINO_ESTAB_ID
          AND cLocProv1.provincia(+) = xtcp.titular_cp_provincia
          AND cLocProv1.localidad(+) = xtcp.titular_cp_localidad
          AND cLocProv2.provincia(+) = xtcp.DESTINO_PROVINCIA
          AND cLocProv2.localidad(+) = xtcp.DESTINO_LOCALIDAD
          AND cInvLoc1.inventory_location_id(+) = xtcp.titular_cp_ubicacion
          AND cInvLoc2.inventory_location_id(+) = xtcp.DESTINO_UBICACION
          AND cCttoCompra1.contrato_id(+) = xtcp.titular_cp_contrato_id
          AND cCttoCompra2.contrato_id(+) = xtcp.intermediario_contrato_id
          AND cCttoCompra3.contrato_id(+) = xtcp.rtte_comercial_contrato_id
          AND cCttoCompra4.contrato_id(+) = xtcp.destinatario_contrato_id
          AND cTranspo.carrier_service_id(+) = xtcp.carrier_service_id
          AND cTranspo.grupo_control(+) = xtpc.grupo_control          --CR1608
          AND cDetallePesaje1.ticket_id(+) = xtcp.TICKET_ENVIO_ID
          AND cDetallePesaje2.ticket_id(+) = xtcp.TICKET_RECEPCION_ID
          AND cBalanza1.balance_id(+) = cDetallePesaje1.BALANZA_TARA_SAL_ID
          AND cBalanza2.balance_id(+) =
                 cDetallePesaje1.BALANZA_PESO_BRUTO_SAL_ID
          AND cBalanza3.balance_id(+) =
                 cDetallePesaje2.BALANZA_PESO_BRUTO_ENT_ID
          AND cBalanza4.balance_id(+) = cDetallePesaje2.BALANZA_TARA_ENT_ID
          AND xtbh.carta_porte_id(+) = xtcp.carta_porte_id
          AND xal1.boletin_header_id(+) = xtbh.boletin_header_id
          AND xtpc.operating_unit(+) = xtcp.operating_unit
          AND fu.user_id(+) = xtcp.created_by
          AND xatd.distancia_id(+) = xtcp.distancia_id          
          AND xtcp.creation_Date > to_Date('01/01/2020','DD/MM/RRRR');

CREATE OR REPLACE VIEW APPS.XX_TCG_CONTROL_VIAJES_CV_V
(
   VIAJE_ID,
   ORGANIZATION_ID,
   ID_LECTURA_QR_DES,
   ID_LECTURA_QR_REC,
   TURNO,
   ESTAB_LECTURA_ID,
   ESTAB_CARGA_ID,
   CAMPO_ORIGEN,
   QR_ID,
   TRANSPORTISTA,
   CHOFER,
   CAMPANIA,
   CODIGO_ONCCA,
   CODIGO_ONCCA_CP,
   DESTINO_ID,
   ESTAB_DESTINO_ID,
   IMPRIMIR_FLAG,
   FECHA_MAXIMA_RETORNO,
   CARTA_PORTE_ID,
   ESTADO,
   FECHA_ESTADO,
   HORA_IMPRESION_OC,
   ARRIBO_REAL
)
AS
   SELECT xtcv.viaje_id,
          xtcv.organization_id,
          xtcv.id_lectura_qr_des,
          xtcv.id_lectura_qr_rec,
          xtcv.turno,
          xtcv.estab_lectura_id,
          xtcv.estab_carga_id,
          xoe.campo,
          xtcv.qr_id,
          aps.vendor_name,
          xoep.nombre,
          xtcv.campania,
          xtcv.codigo_oncca,
          xtcv.codigo_oncca_cp,
          xtcv.destino_id,
          xtcv.estab_destino_id,
          xtcv.imprimir_flag,
          xtcv.fecha_maxima_retorno,
          xttb.carta_porte_id,
          XX_TCG_CONTROL_VIAJES_PKG.set_estado_viaje (xtcv.viaje_id) estado,
          XX_TCG_CONTROL_VIAJES_PKG.
          Get_Fecha_Historial_por_Estado (
             xtcv.viaje_id,
             XX_TCG_CONTROL_VIAJES_PKG.set_estado_viaje (xtcv.viaje_id))
             fecha_estado,
          xtcv.hora_impresion_oc,
          NVL (
             XX_TCG_CONTROL_VIAJES_PKG.
             get_fecha_historial_por_estado (xtcv.viaje_id, 'ARRIBADO'),
             XX_TCG_CONTROL_VIAJES_PKG.
             get_fecha_historial_por_estado (xtcv.viaje_id, 'EN_DESCARGA'))
     FROM XX_TCG_CONTROL_VIAJES xtcv,
          (  SELECT MIN (carta_porte_id) carta_porte_id, viaje_id
               FROM XX_TCG_TICKETS_BALANZA
           GROUP BY viaje_id) xttb,
          XX_OPM_QR_PROVEEDORES xoqp,
          XX_OPM_ADMIN_PROVEEDORES xoap,
          AP_SUPPLIERS aps,
          XX_OPM_EMPLEADOS_PROVEEDORES xoep,
          XX_OPM_ESTABLECIMIENTOS xoe
    WHERE     xtcv.viaje_id = xttb.viaje_id(+)
          AND xtcv.qr_id = xoqp.qr_id
          AND xoqp.adm_vendor_id = xoap.adm_vendor_id
          AND xoap.vendor_id = aps.vendor_id
          AND xoqp.empleado_id = xoep.empleado_id
          AND xtcv.estab_carga_id = xoe.establecimiento_id
          AND xtcv.viaje_id > 0
       AND xtcv.creation_Date > to_Date('01/01/2020','DD/MM/RRRR');


       grant select on XX_TCG_CONTROL_VIAJES_CV_V to ADECO_BI;


       grant select on XX_TCG_CARTAS_PORTE_CV_V to ADECO_BI;



