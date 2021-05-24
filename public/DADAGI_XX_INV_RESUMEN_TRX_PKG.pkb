CREATE OR REPLACE PACKAGE BODY APPS."XX_INV_RESUMEN_TRX_PKG"
IS
 g_debug BOOLEAN := FALSE;

 PROCEDURE print_output ( p_message IN VARCHAR2 ) IS
 BEGIN
 IF fnd_global.conc_request_id = -1
 THEN
 DBMS_OUTPUT.put_line (p_message);
 ELSE
 fnd_file.put_line (fnd_file.output, p_message);
 END IF;
 END print_output;


 PROCEDURE print_debug ( p_message IN VARCHAR2) IS
 BEGIN
 IF g_debug THEN
 IF fnd_global.conc_request_id = -1 THEN
 DBMS_OUTPUT.put_line (p_message);
 ELSE
 fnd_file.put_line (fnd_file.LOG, p_message);
 END IF;
 END IF;
 END print_debug;


 FUNCTION fmt ( p_txt IN VARCHAR2
 , p_len IN NUMBER
 ) RETURN VARCHAR2 IS
 BEGIN
 RETURN RPAD (SUBSTR (NVL (p_txt, ' ')
 , 1
 , p_len
 )
 , p_len
 , ' '
 );
 END fmt;


 FUNCTION get_productor ( p_tipo_doc IN VARCHAR2
 , p_carta_porte_id IN NUMBER
 ) RETURN VARCHAR2 IS
 l_productor VARCHAR2 (200);
 BEGIN
 IF p_tipo_doc = 'TCG_CARTA_PORTE'
 THEN
 SELECT CASE
 WHEN rtte_comercial_tipo = 'PRODUCTOR'
 THEN (SELECT party_name
 FROM hz_parties
 WHERE party_id = rtte_comercial_id)
 WHEN intermediario_tipo='PRODUCTOR'
 then (SELECT party_name
 FROM hz_parties
 WHERE party_id = intermediario_id)
 ELSE (SELECT party_name
 FROM hz_parties
 WHERE party_id = titular_cp_id)
 END productor
 INTO l_productor
 FROM xx_tcg_cartas_porte_all
 WHERE carta_porte_id = p_carta_porte_id;
 ELSIF p_tipo_doc = 'TCG_LIQUIDACION'
 THEN
 SELECT p.party_name productor
 INTO l_productor
 FROM xx_tcg_liquidaciones l
 , xx_tcg_contratos_compra cc
 , hz_parties p
 WHERE l.contrato_id = cc.contrato_id
 AND cc.productor_id = p.party_id
 AND l.liquidacion_id = p_carta_porte_id;
 END IF;

 RETURN l_productor;
 EXCEPTION
 WHEN NO_DATA_FOUND
 THEN
 RETURN NULL;
 END get_productor;


 FUNCTION get_nro_contrato (
 p_tipo_doc IN VARCHAR2
 , p_party_id_le IN NUMBER
 , p_carta_porte_id IN NUMBER
 )
 RETURN VARCHAR2
 IS
 l_contrato_id NUMBER;
 l_nro_contrato VARCHAR2 (200);
 BEGIN
 IF p_tipo_doc = 'TCG_CARTA_PORTE'
 THEN
 FOR r1 IN (SELECT *
 FROM xx_tcg_cartas_porte_all
 WHERE carta_porte_id = p_carta_porte_id)
 LOOP
 IF p_party_id_le = r1.titular_cp_id
 AND r1.titular_cp_contrato_id IS NOT NULL
 THEN
 l_contrato_id := r1.titular_cp_contrato_id;
 EXIT;
 ELSIF p_party_id_le = r1.intermediario_id
 AND r1.intermediario_contrato_id IS NOT NULL
 THEN
 l_contrato_id := r1.intermediario_contrato_id;
 EXIT;
 ELSIF p_party_id_le = r1.rtte_comercial_id
 AND r1.rtte_comercial_contrato_id IS NOT NULL
 THEN
 l_contrato_id := r1.rtte_comercial_contrato_id;
 EXIT;
 ELSIF p_party_id_le = r1.destinatario_id
 AND r1.destinatario_contrato_id IS NOT NULL
 THEN
 l_contrato_id := r1.destinatario_contrato_id;
 EXIT;
 END IF;
 END LOOP;
 END IF;

 SELECT numero_contrato
 INTO l_nro_contrato
 FROM xx_tcg_contratos_compra
 WHERE contrato_id = l_contrato_id;

 RETURN l_nro_contrato;
 EXCEPTION
 WHEN NO_DATA_FOUND
 THEN
 RETURN NULL;
 END get_nro_contrato;

 FUNCTION get_transferido_flag (
 p_tipo_doc IN VARCHAR2
 , p_carta_porte_id IN NUMBER
 )
 RETURN VARCHAR2
 IS
 l_flag VARCHAR2 (10);
 BEGIN
 IF p_tipo_doc = 'TCG_CARTA_PORTE'
 THEN
 SELECT transferido_flag
 INTO l_flag
 FROM xx_tcg_cartas_porte_all
 WHERE carta_porte_id = p_carta_porte_id;
 END IF;

 RETURN l_flag;
 EXCEPTION
 WHEN NO_DATA_FOUND
 THEN
 RETURN NULL;
 END get_transferido_flag;

 FUNCTION get_recibido_flag (
 p_tipo_doc IN VARCHAR2
 , p_carta_porte_id IN NUMBER
 )
 RETURN VARCHAR2
 IS
 l_flag VARCHAR2 (10);
 BEGIN
 IF p_tipo_doc = 'TCG_CARTA_PORTE'
 THEN
 SELECT recibido_flag
 INTO l_flag
 FROM xx_tcg_cartas_porte_all
 WHERE carta_porte_id = p_carta_porte_id;
 END IF;

 RETURN l_flag;
 EXCEPTION
 WHEN NO_DATA_FOUND
 THEN
 RETURN NULL;
 END get_recibido_flag;

 FUNCTION get_cmv (
 p_tipo_doc IN VARCHAR2
 , p_org_id IN NUMBER
 , p_carta_porte_id IN NUMBER
 )
 RETURN VARCHAR2
 IS
 l_cmv VARCHAR2 (100);
 BEGIN
 FOR r IN (SELECT asociado_flag
 , ROWNUM row_num
 FROM xx_tcg_asocia_pedido_venta
 WHERE carta_porte_id = p_carta_porte_id
 AND operating_unit = p_org_id)
 LOOP
 IF r.row_num = 1
 THEN
 l_cmv := NVL (r.asociado_flag, 'N');
 END IF;

 IF r.row_num <> 1
 AND l_cmv <> NVL (r.asociado_flag, 'N')
 THEN
 l_cmv := 'Parcial';
 END IF;
 END LOOP;

 IF l_cmv = 'N'
 THEN
 RETURN NULL;
 END IF;

 RETURN l_cmv;
 EXCEPTION
 WHEN OTHERS
 THEN
 RETURN NULL;
 END get_cmv;


 PROCEDURE main ( errbuf OUT VARCHAR2
 , retcode OUT VARCHAR2
 , p_org_id IN NUMBER
 , p_organization_id IN NUMBER
 , p_subinventory_code IN VARCHAR2
 , p_locator_id IN NUMBER
 , p_period_name_from IN VARCHAR2 -- amanukyan 20180130 issue 131
 , p_period_name_to IN VARCHAR2 -- amanukyan 20180130 issue 131
 , p_cat_gl IN NUMBER
 , p_item_id IN NUMBER
 , p_lote_desde IN VARCHAR2
 , p_lote_hasta IN VARCHAR2 --SD1119
 , p_source_carta_porte IN VARCHAR2 --amanukyan 20180205 issue 140 cartas de porte
 , p_stock_init_flag IN VARCHAR2 -- issue 159 amanukyan mejora stock inicial
 ) IS

 CURSOR c1 ( pc_fecha_inv DATE ) IS
 SELECT tipo_reg
 , (SELECT COUNT (1)
 FROM mtl_material_transactions mmt2
 , mtl_transaction_lot_numbers mln2
 , org_acct_periods per2
 WHERE 1 = 1
 AND mmt2.transaction_id = mln2.transaction_id(+)
 AND mmt2.organization_id = per2.organization_id
 AND mmt2.acct_period_id = per2.acct_period_id
 AND mmt2.subinventory_code = tbl.subinventory_code
 AND NVL (mmt2.locator_id, -12) = NVL (tbl.locator_id, -12)
 AND NVL (mln2.lot_number, '-99') = NVL (tbl.lot_number, '-99')
 AND mmt2.inventory_item_id = tbl.inventory_item_id
 AND NVL (mmt2.transaction_source_name, '1111') NOT IN
 ('En mano migrado desde OPM'
 , 'Migrated negative onhand from OPM'
 , 'Migrated onhand from OPM'
 , 'Negativo en mano migrado desde OPM'
 )
 -- amanukyan 20180329 estos son stocks de fechas anteriores
 AND per2.period_year
 || LPAD (per2.period_num
 , 2
 , '0'
 ) BETWEEN p_period_name_from AND p_period_name_to) cant_movs
 , clase_gl
 , clase_gl_descr
 , clase_costo
 , clase_costo_descr
 , item_code
 , item_description
 , ou_name
 , party_id_le
 , organization_code
 , organization_name
 , subinventory_code
 , establecimiento_id
 , descr_establecimiento
 , LOCATOR
 , lot_number
 , owning_supplier
 , transaction_date
 , transaction_type_name
 , xx_tcg_tipo_doc
 , reason_name
 , transaction_id
 , primary_uom_code
 -- amanukyan 20180405 stock inicial
 , NVL
 (SUM (qty1) OVER (PARTITION BY organization_code, subinventory_code, item_code, lot_number, LOCATOR, item_code, NVL
 (owning_organization_id
 , organization_id) ORDER BY organization_code
 , subinventory_code
 , item_code
 , lot_number
 , LOCATOR
 , item_code
 , tipo_reg
 , NVL (owning_organization_id, organization_id)
 , transaction_date
 , transaction_id ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)
 , 0) saldo_inicial1
 , qty1
 , NVL
 (SUM (qty1) OVER (PARTITION BY organization_code, subinventory_code, item_code, lot_number, LOCATOR, item_code, NVL
 (owning_organization_id
 , organization_id) ORDER BY organization_code
 , subinventory_code
 , item_code
 , lot_number
 , LOCATOR
 , item_code
 , tipo_reg
 , NVL (owning_organization_id, organization_id)
 , transaction_date
 , transaction_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
 , 0) saldo_final1
 --
 , secondary_uom_code
 , SUM (qty2) OVER (PARTITION BY organization_code, subinventory_code, item_code, lot_number, LOCATOR, item_code, NVL
 (owning_organization_id
 , organization_id) ORDER BY organization_code
 , subinventory_code
 , item_code
 , lot_number
 , LOCATOR
 , item_code
 , tipo_reg
 , NVL (owning_organization_id, organization_id)
 , transaction_date
 , transaction_id ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)
 -- amanukyan 20180405 stock inicial
 saldo_inicial2
 , qty2
 , SUM (qty2) OVER (PARTITION BY organization_code, subinventory_code, item_code, lot_number, LOCATOR, item_code, NVL
 (owning_organization_id
 , organization_id) ORDER BY organization_code
 , subinventory_code
 , item_code
 , lot_number
 , LOCATOR
 , item_code
 , tipo_reg
 , NVL (owning_organization_id, organization_id)
 , transaction_date
 , transaction_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
 -- amanukyan 20180405 stock inicial
 saldo_final2
 , carta_porte
 , numero_liquidacion -- CR1786
 , productor
 , nro_contrato
 , flag_transferido
 , flag_recibido
 , cmv
 , order_number
 , line_number
 , order_type
 , ordered_qty
 , po_number
 , po_line_number
 , xx_opm_ot
 , project_number
 , task_name
 , expenditure_type
 , xx_opm_parcela
 , xx_opm_variedad
 , xx_opm_vale_consumo
 , xx_opm_patente_vehiculo
 , xx_opm_km_vehiculo
 , usuario_creacion
 , creation_date
 , transaction_reference
 FROM (SELECT '1' tipo_reg
 , hou.organization_id org_id
 , hou.NAME ou_name
 , xep.party_id party_id_le
 , ood.organization_id
 , par.organization_code
 , ood.organization_name
 , mmt.subinventory_code
 , subinvx.xx_tcg_establecimientos establecimiento_id
 , (SELECT campo
 FROM xx_opm_establecimientos
 WHERE establecimiento_id = subinvx.xx_tcg_establecimientos) descr_establecimiento
 , mmt.locator_id
 , loc.segment1 LOCATOR
 , mmt.transaction_id
 , mmt.inventory_item_id
 , DECODE (mmt.owning_tp_type
 , 1, (SELECT DISTINCT x.vendor_name
 || '-'
 || z.vendor_site_code
 FROM po_vendor_sites_all z
 , po_vendors x
 WHERE x.vendor_id = z.vendor_id
 AND z.vendor_site_id = mmt.owning_organization_id)
 -- Inicio adm CR2241 - cambio 1561 
 , 2, DECODE(mtt.transaction_type_name
            ,'WIP ISSUE', NULL
            ,'Transfer to Regular',(SELECT DISTINCT x.vendor_name
                                     || '-'
                                     || z.vendor_site_code
                                     FROM po_vendor_sites_all z
                                     , po_vendors x
                                     , mtl_material_transactions mmt1
                                     WHERE x.vendor_id = z.vendor_id
                                     AND z.vendor_site_id = mmt1.owning_organization_id
                                     AND mmt1.owning_tp_type = 1
                                     AND mtt.transaction_type_name != 'WIP ISSUE'
                                     AND mmt1.transaction_id = mmt.transfer_transaction_id
                                     AND mmt1.transaction_set_id = mmt.transaction_set_id
                                     AND mmt1.transaction_batch_id = mmt.transaction_batch_id
                                     AND ROWNUM = 1
                                     UNION ALL
                                     SELECT DISTINCT x.vendor_name
                                     || '-'
                                     || z.vendor_site_code
                                     FROM po_vendor_sites_all z
                                     , po_vendors x
                                     , mtl_material_transactions mmt1
                                     WHERE x.vendor_id = z.vendor_id
                                     AND z.vendor_site_id = mmt1.owning_organization_id
                                     AND mmt1.owning_tp_type = 1
                                     AND mtt.transaction_type_name != 'WIP ISSUE'
                                     AND mmt.transfer_transaction_id IS NULL
                                     AND mmt1.transaction_set_id = mmt.transaction_set_id
                                     AND mmt1.transaction_batch_id = mmt.transaction_batch_id
                                     AND ROWNUM = 1)
            ,(SELECT DISTINCT x.vendor_name
             || '-'
             || z.vendor_site_code
             FROM po_vendor_sites_all z
             , po_vendors x
             , mtl_material_transactions mmt1
             WHERE x.vendor_id = z.vendor_id
             AND z.vendor_site_id = mmt1.owning_organization_id
             AND mmt1.owning_tp_type = 1
             AND mmt1.transaction_set_id = mmt.transaction_set_id
             AND mmt1.transaction_batch_id = mmt.transaction_batch_id
             AND ROWNUM = 1))
 -- Fin adm CR2241 - cambio 1561 
 ) owning_supplier
 , mtt.transaction_type_name
 , mttx.xx_tcg_tipo_doc
 , CASE
 WHEN mmt.reason_id IS NOT NULL
 THEN mtr.reason_name
 WHEN ( mmt.reason_id IS NULL
 AND mtt.transaction_type_name = 'Cycle Count Adjust')
 THEN (SELECT reason_name
 FROM mtl_cycle_count_headers_dfv mccx
 , mtl_cycle_count_headers mcc
 , mtl_transaction_reasons mtr
 WHERE mccx.row_id = mcc.ROWID
 AND mcc.cycle_count_header_id = mmt.transaction_source_id
 AND mccx.xx_opm_motivo_recuento = mtr.reason_id)
 END reason_name
 , mtr.description reason_description
 , mmt.transaction_date
 , mln.lot_number lot_number
 , msi.segment1 item_code
 , msi.description item_description
 , cat_cost.category_id clase_costo_id
 , cat_cost.segment1 clase_costo
 , cat_cost.description clase_costo_descr
 , cat_gl.category_id clase_gl_id
 , cat_gl.segment1 clase_gl
 , cat_gl.description clase_gl_descr
 , msi.primary_uom_code
 , NVL (mln.primary_quantity, mmt.primary_quantity) qty1
 , msi.secondary_uom_code
 , NVL (mln.secondary_transaction_quantity, mmt.secondary_transaction_quantity) qty2
 , mmt.source_code
 , mmt.transaction_source_type_id
 , mmt.transaction_source_id
 , CASE
 WHEN mmtx.xx_aco_source_code = p_source_carta_porte
 THEN (SELECT DECODE (MIN (oeh.order_number)
 , MAX (oeh.order_number), MAX (oeh.order_number)
 || ''
 , 'MULTIPLE'
 ) order_number
 FROM xx_tcg_asocia_pedido_venta pva
 , oe_order_headers_all oeh
 WHERE pva.carta_porte_id = mmtx.xx_aco_source_id
 AND pva.operating_unit = hou.organization_id
 AND oeh.org_id = hou.organization_id
 AND oeh.header_id = pva.oe_order_header_id)
 WHEN mmt.source_code = 'RCV'
 AND mtst.transaction_source_type_name NOT IN ('RMA')
 THEN (SELECT rsh.receipt_num
 || ''
 FROM rcv_shipment_headers rsh
 , rcv_transactions rt
 WHERE rsh.shipment_header_id = rt.shipment_header_id
 AND transaction_id = mmt.rcv_transaction_id)
 WHEN mtst.transaction_source_type_name IN ('Sales order', 'RMA')
 OR mtt.transaction_type_name IN ('Residual Qty Issue', 'Residual Qty Receipt')
 THEN (SELECT DISTINCT order_number
 || ''
 FROM oe_order_headers_all oe
 , oe_order_lines_all oel
 WHERE oe.header_id = oel.header_id
 AND oel.line_id = mmt.trx_source_line_id)
 WHEN mtr.reason_name = 'TRPT' THEN --CR1708
 (select TO_CHAR(ooh.order_number)
 from oe_order_headers_all ooh
 WHERE ooh.header_id = mmtx.xx_numero_pedido)
 END order_number
 , CASE
 WHEN mmtx.xx_aco_source_code = p_source_carta_porte
 THEN (SELECT decode (MIN (oel.header_id), MAX (oel.header_id),DECODE (MIN (oel.line_id)
 , MAX (oel.line_id), MAX (oel.line_number)
 || ''
 , 'MULTIPLE'
 ), null) line_number
 FROM oe_order_lines_all oel
 , oe_order_lines_all_dfv oeldf
 , xx_tcg_asocia_pedido_venta pva
 WHERE oel.ROWID = oeldf.row_id
 AND oel.header_id = pva.oe_order_header_id
 AND oeldf.xx_om_carta_porte = mmt.waybill_airbill
 AND pva.carta_porte_id = mmtx.xx_aco_source_id)
 WHEN mtst.transaction_source_type_name IN ('Sales order', 'RMA')
 OR mtt.transaction_type_name IN ('Residual Qty Issue', 'Residual Qty Receipt')
 THEN (SELECT line_number
 || ''
 FROM oe_order_lines_all oe
 WHERE oe.line_id = mmt.trx_source_line_id) -- amanukyan 20180912 join issue
 END line_number
 , CASE
 WHEN mtr.reason_name = 'TRPT' THEN --CR1708
 (SELECT decode (MIN (oeh.header_id), MAX (oeh.header_id),DECODE (MIN (tt.NAME)
 , MAX (tt.NAME), MAX (tt.NAME)
 , 'MULTIPLE'
 ), null) order_type
 FROM oe_order_headers_all oeh
 , oe_transaction_types_tl tt
 WHERE oeh.header_id = mmtx.xx_numero_pedido
 AND oeh.order_type_id = tt.transaction_type_id
 AND LANGUAGE = 'ESA')
 WHEN mmtx.xx_aco_source_code = p_source_carta_porte
 THEN (SELECT decode (MIN (oeh.header_id), MAX (oeh.header_id),DECODE (MIN (tt.NAME)
 , MAX (tt.NAME), MAX (tt.NAME)
 , 'MULTIPLE'
 ), null) order_type
 FROM xx_tcg_asocia_pedido_venta pva
 , oe_order_headers_all oeh
 , oe_transaction_types_tl tt
 WHERE oeh.header_id = pva.oe_order_header_id
 AND pva.carta_porte_id = mmtx.xx_aco_source_id
 AND oeh.order_type_id = tt.transaction_type_id
 AND LANGUAGE = 'ESA')
 WHEN mtst.transaction_source_type_name IN ('Sales order', 'RMA')
 OR mtt.transaction_type_name IN ('Residual Qty Issue', 'Residual Qty Receipt')
 THEN (SELECT NAME
 FROM oe_order_headers_all ooh
 , oe_transaction_types_tl tt
 , oe_order_lines_all oel
 WHERE ooh.header_id = oel.header_id
 AND oel.line_id = mmt.trx_source_line_id
 AND ooh.order_type_id = tt.transaction_type_id
 AND LANGUAGE = 'ESA')
 END order_type
 , CASE
 WHEN mmtx.xx_aco_source_code = p_source_carta_porte
 THEN (SELECT decode (MIN (oel.header_id), MAX (oel.header_id),SUM (oel.ordered_quantity), null)
 FROM oe_order_lines_all oel
 , oe_order_lines_all_dfv oeldf
 , xx_tcg_asocia_pedido_venta pva
 WHERE oel.ROWID = oeldf.row_id
 AND oel.header_id = pva.oe_order_header_id
 AND oeldf.xx_om_carta_porte = mmt.waybill_airbill
 AND pva.carta_porte_id = mmtx.xx_aco_source_id)
 WHEN mtst.transaction_source_type_name IN ('Sales order', 'RMA')
 OR mtt.transaction_type_name IN ('Residual Qty Issue', 'Residual Qty Receipt')
 THEN (SELECT ordered_quantity
 FROM oe_order_lines_all ool
 WHERE line_id = mmt.trx_source_line_id) -- amanukyan 20180912
 END ordered_qty
 , CASE
 WHEN mmt.transaction_source_type_id = 1
 THEN -- 1= Purchase Order
 (SELECT segment1
 FROM po_headers_all
 WHERE po_header_id = mmt.transaction_source_id)
 END po_number
 , CASE
 WHEN mmt.transaction_source_type_id = 1
 THEN
 (SELECT DISTINCT pl.line_num
 FROM rcv_transactions rt
 , po_lines_all pl
 WHERE 1=1
 AND rt.transaction_id = mmt.source_line_id
 AND pl.po_line_id = rt.po_line_id
 AND pl.po_header_id = mmt.transaction_source_id)
 END po_line_number
 , CASE mtst.transaction_source_type_name
 WHEN 'Job or Schedule'
 THEN (SELECT wip_entity_name
 FROM wip_entities
 WHERE wip_entity_id = mmt.transaction_source_id)
 ELSE mmtx.xx_opm_ot
 END xx_opm_ot -- amanukyan 20180924 EAM Issue
 , pp.segment1 project_number
 , pt.task_number task_name
 , mmt.expenditure_type
 , mmtx.xx_opm_parcela
 , mmtx.xx_opm_variedad
 , mmtx.xx_opm_vale_consumo
 , mmtx.xx_opm_patente_vehiculo
 , mmtx.xx_opm_km_vehiculo
 , CASE
 WHEN mmt.source_code = 'RCV'
 THEN (SELECT SUBSTR (rsh.comments
 , 1
 , 240
 )
 FROM rcv_shipment_headers rsh
 , rcv_transactions rt
 WHERE rsh.shipment_header_id = rt.shipment_header_id
 AND transaction_id = mmt.rcv_transaction_id)
 ELSE mmt.transaction_reference
 END transaction_reference
 , u.user_name usuario_creacion
 , mmt.creation_date
 , --CASE
 -- WHEN mttx.xx_tcg_tipo_doc = 'CARTA_PORTE'
 -- THEN mmt.waybill_airbill
 --END carta_porte
 CASE
 WHEN mtt.transaction_type_name = 'PO Receipt'
 THEN (SELECT packing_slip
 || ''
 FROM rcv_shipment_headers rsh
 , rcv_transactions rt
 WHERE rsh.shipment_header_id = rt.shipment_header_id
 AND transaction_id = mmt.rcv_transaction_id)
 ELSE mmt.waybill_airbill
 END carta_porte
 , CASE -- CR1786
 WHEN mtt.transaction_type_name like 'TCG%Liquidacion'
 THEN (SELECT xtl.numero_liquidacion
 FROM MTL_MATERIAL_TRANSACTIONS mtt
 , MTL_MATERIAL_TRANSACTIONS_DFV mttd
 , XX_TCG_LIQUIDACIONES xtl
 WHERE mtt.rowid = mttd.row_id
 AND mttd.xx_aco_source_id = xtl.liquidacion_id
 AND mttd.xx_aco_source_code = 'XXTCGLIQ'
 AND mtt.transaction_id = mmt.transaction_id)
 ELSE
 NULL
 END numero_liquidacion -- amanukyan 20180131 issue
 , CASE
 WHEN mmtx.xx_aco_source_code = p_source_carta_porte
 THEN (SELECT MAX (xx_inv_resumen_trx_pkg.get_productor (mttdf2.xx_tcg_tipo_doc
 , mmtx.xx_aco_source_id))
 FROM mtl_transaction_types_dfv mttdf2
 , mtl_transaction_types mtt1
 , mtl_material_transactions mmt1
 WHERE mtt1.ROWID = mttdf2.row_id
 AND mmt1.transaction_type_id = mtt1.transaction_type_id
 AND mmt1.transaction_set_id = mmt.transaction_set_id
 AND NVL (mmt1.transaction_batch_id, -99) = NVL (mmt.transaction_batch_id, -99))
 WHEN mtt.transaction_type_name IN ('PO Receipt', 'Return to Vendor')
 THEN (SELECT aps.vendor_name
 FROM rcv_shipment_headers rsh
 , rcv_transactions rt
 , ap_suppliers aps
 WHERE rsh.shipment_header_id = rt.shipment_header_id
 AND transaction_id = mmt.rcv_transaction_id
 AND rsh.vendor_id = aps.vendor_id)
 WHEN mtst.transaction_source_type_name IN ('Sales order', 'RMA')
 OR mtt.transaction_type_name IN ('Residual Qty Issue', 'Residual Qty Receipt')
 THEN (SELECT hp.party_name
 FROM oe_order_headers_all oe
 , oe_order_lines_all oel
 , hz_cust_accounts hca
 , hz_parties hp
 WHERE oe.header_id = oel.header_id
 AND oel.line_id = mmt.trx_source_line_id
 AND hca.party_id = hp.party_id
 AND hca.cust_account_id = oe.sold_to_org_id)
 WHEN mtt.transaction_type_name like 'TCG%Liquidacion' --CR1786
 THEN (SELECT hp.party_name
 FROM MTL_MATERIAL_TRANSACTIONS mtt
 , MTL_MATERIAL_TRANSACTIONS_DFV mttd
 , XX_TCG_LIQUIDACIONES xtl
 , HZ_PARTIES hp
 WHERE mtt.rowid = mttd.row_id
 AND mttd.xx_aco_source_id = xtl.liquidacion_id
 AND xtl.empresa_origen_party_id = hp.party_id
 AND mttd.xx_aco_source_code = 'XXTCGLIQ'
 AND mtt.transaction_id = mmt.transaction_id)
 END productor
 , CASE
 WHEN mmtx.xx_aco_source_code = p_source_carta_porte
 THEN (SELECT MAX (xx_inv_resumen_trx_pkg.get_nro_contrato (mttdf2.xx_tcg_tipo_doc
 , xep.party_id
 , mmtx.xx_aco_source_id
 ))
 FROM mtl_transaction_types_dfv mttdf2
 , mtl_transaction_types mtt1
 , mtl_material_transactions mmt1
 WHERE mtt1.ROWID = mttdf2.row_id
 AND mmt1.transaction_type_id = mtt1.transaction_type_id
 AND mmt1.transaction_set_id = mmt.transaction_set_id
 AND NVL (mmt1.transaction_batch_id, -99) = NVL (mmt.transaction_batch_id, -99))
 WHEN mtt.transaction_type_name like 'TCG%Liquidacion' -- CR1786
 THEN (SELECT xtc.numero_contrato
 FROM MTL_MATERIAL_TRANSACTIONS mtt
 , MTL_MATERIAL_TRANSACTIONS_DFV mttd
 , XX_TCG_LIQUIDACIONES xtl
 , XX_TCG_CONTRATOS_COMPRA xtc
 WHERE mtt.rowid = mttd.row_id
 AND mttd.xx_aco_source_id = xtl.liquidacion_id
 AND xtl.contrato_id = xtc.contrato_id
 AND mttd.xx_aco_source_code = 'XXTCGLIQ'
 AND mtt.transaction_id = mmt.transaction_id)
 END nro_contrato
 , CASE
 WHEN mmtx.xx_aco_source_code = p_source_carta_porte
 THEN (SELECT MAX (xx_inv_resumen_trx_pkg.get_transferido_flag (mttdf2.xx_tcg_tipo_doc
 , mmtx.xx_aco_source_id))
 FROM mtl_transaction_types_dfv mttdf2
 , mtl_transaction_types mtt1
 , mtl_material_transactions mmt1
 WHERE mtt1.ROWID = mttdf2.row_id
 AND mmt1.transaction_type_id = mtt1.transaction_type_id
 AND mmt1.transaction_set_id = mmt.transaction_set_id
 AND NVL (mmt1.transaction_batch_id, -99) = NVL (mmt.transaction_batch_id, -99))
 END flag_transferido
 , (SELECT MAX (xx_inv_resumen_trx_pkg.get_recibido_flag (mttdf2.xx_tcg_tipo_doc
 , mmtx.xx_aco_source_id))
 FROM mtl_transaction_types_dfv mttdf2
 , mtl_transaction_types mtt1
 , mtl_material_transactions mmt1
 WHERE mtt1.ROWID = mttdf2.row_id
 AND mmt1.transaction_type_id = mtt1.transaction_type_id
 AND mmt1.transaction_set_id = mmt.transaction_set_id
 AND NVL (mmt1.transaction_batch_id, -99) = NVL (mmt.transaction_batch_id, -99))
 flag_recibido
 , CASE
 WHEN mmtx.xx_aco_source_code = p_source_carta_porte
 THEN (SELECT MAX (xx_inv_resumen_trx_pkg.get_cmv (mttdf2.xx_tcg_tipo_doc
 , hou.organization_id
 , mmtx.xx_aco_source_id
 ))
 FROM mtl_transaction_types_dfv mttdf2
 , mtl_transaction_types mtt1
 , mtl_material_transactions mmt1
 WHERE mtt1.ROWID = mttdf2.row_id
 AND mmt1.transaction_type_id = mtt1.transaction_type_id
 AND mmt1.transaction_set_id = mmt.transaction_set_id
 AND NVL (mmt1.transaction_batch_id, -99) = NVL (mmt.transaction_batch_id, -99))
 END cmv
 , per.period_start_date
 , mmt.owning_organization_id
 FROM mtl_material_transactions mmt
 , mtl_material_transactions_dfv mmtx
 , mtl_txn_source_types mtst
 , mtl_transaction_lot_numbers mln
 , mtl_system_items msi
 , (SELECT ic.organization_id
 , ic.inventory_item_id
 , mc.category_id
 , mc.segment1
 , mc.description
 FROM mtl_item_categories_v ic
 , mtl_categories mc
 WHERE ic.category_set_name LIKE 'Categor_a Costos OPM' --, 'Categoría Contable OPM')
 AND mc.category_id = ic.category_id) cat_cost
 , (SELECT ic.organization_id
 , ic.inventory_item_id
 , mc.category_id
 , mc.segment1
 , mc.description
 FROM mtl_item_categories_v ic
 , mtl_categories mc
 WHERE ic.category_set_name LIKE 'Categor_a Contable OPM'
 AND mc.category_id = ic.category_id) cat_gl
 , mtl_transaction_types mtt
 , mtl_transaction_types_dfv mttx
 , mtl_transaction_reasons mtr
 , mtl_item_locations loc
 , org_organization_definitions ood
 , mtl_parameters par
 , hr_operating_units hou
 , xle_le_ou_ledger_v xlo
 , xle_entity_profiles xep
 , mtl_secondary_inventories subinv
 , mtl_secondary_inventories_dfv subinvx
 , pa_projects_all pp
 , pa_tasks pt
 , fnd_user u
 , org_acct_periods per
 WHERE mmt.transaction_type_id = mtt.transaction_type_id
 AND mtt.transaction_source_type_id = mtst.transaction_source_type_id
 AND mmt.transaction_source_type_id = mtst.transaction_source_type_id
 AND mmt.ROWID = mmtx.row_id
 AND mtt.ROWID = mttx.row_id
 AND mmt.organization_id = per.organization_id
 AND mmt.organization_id = ood.organization_id
 AND mmt.organization_id = par.organization_id
 AND ood.operating_unit = hou.organization_id
 AND hou.organization_id = xlo.operating_unit_id
 AND xlo.legal_entity_id = xep.legal_entity_id
 AND mmt.locator_id = loc.inventory_location_id(+)
 AND mmt.organization_id = msi.organization_id
 AND mmt.inventory_item_id = msi.inventory_item_id
 AND cat_cost.organization_id(+) = par.master_organization_id
 AND cat_cost.inventory_item_id(+) = msi.inventory_item_id
 AND cat_gl.organization_id(+) = par.master_organization_id
 AND cat_gl.inventory_item_id(+) = msi.inventory_item_id
 AND mmt.reason_id = mtr.reason_id(+)
 -- amanukyan 20180329 estos son stocks de fechas anteriores
 AND NVL (mmt.transaction_source_name, '1111') NOT IN
 ('En mano migrado desde OPM'
 , 'Migrated negative onhand from OPM'
 , 'Migrated onhand from OPM'
 , 'Negativo en mano migrado desde OPM'
 )
 -- amanukyan 20180329 estos son stocks de fechas anteriores
--AND mmt.owning_tp_type = 2 -- si hubiera que ignorar Trx de terceros
 AND mmt.transaction_id = mln.transaction_id(+)
 AND mmt.inventory_item_id = mln.inventory_item_id(+)
 AND mmt.organization_id = mln.organization_id(+)
 AND mmt.organization_id = subinv.organization_id
 AND mmt.subinventory_code = subinv.secondary_inventory_name
 AND subinv.ROWID = subinvx.row_id
 AND mmt.source_project_id = pp.project_id(+)
 AND mmt.source_task_id = pt.task_id(+)
 AND mmt.created_by = u.user_id
 AND EXISTS (SELECT 1
 FROM org_access_view oav
 WHERE 1 = 1
 AND oav.organization_id = ood.organization_id
 AND oav.responsibility_id = fnd_profile.VALUE ('RESP_ID')
 AND oav.resp_application_id = fnd_profile.VALUE ('RESP_APPL_ID'))
 AND TRUNC (mmt.transaction_date) BETWEEN per.period_start_date AND per.schedule_close_date
--Parametros
 AND ood.operating_unit = p_org_id
 AND ( ood.organization_id = p_organization_id
 AND p_organization_id IS NOT NULL
 OR ood.organization_id IN (SELECT organization_id
 FROM org_organization_definitions
 WHERE operating_unit = p_org_id)
 AND p_organization_id IS NULL
 )
 AND ( mmt.subinventory_code = p_subinventory_code
 OR p_subinventory_code IS NULL)
 AND ( mmt.locator_id = p_locator_id
 OR p_locator_id IS NULL)
 AND ( cat_gl.category_id = p_cat_gl
 OR p_cat_gl IS NULL)
 AND ( mmt.inventory_item_id = p_item_id
 OR p_item_id IS NULL)
 AND ( p_lote_desde IS NULL OR
 ( p_lote_desde IS NOT NULL AND
 mln.lot_number >= p_lote_desde
 )
 )
 AND ( p_lote_hasta IS NULL OR
 ( p_lote_hasta IS NOT NULL AND
 mln.lot_number <= p_lote_hasta
 )
 )
--AND PER.period_name = p_period_name -- amanukyan 20180130 issue 131
 AND per.period_year
 || LPAD (per.period_num
 , 2
 , '0'
 ) BETWEEN p_period_name_from AND p_period_name_to -- amanukyan 20180130 issue 131
 UNION ALL
 SELECT '0' tipo_reg
 , ood.operating_unit
 , hou.NAME ou_name
 , NULL
 , qoh.organization_id
 , par.organization_code
 , ood.organization_name
 , qoh.subinventory_code
 , NULL
 , NULL
 , qoh.locator_id
 , loc.segment1 LOCATOR
 , NULL
 , qoh.inventory_item_id
 , CASE
 WHEN qoh.owning_organization_id IS NOT NULL
 THEN (SELECT x.vendor_name
           || '-'
           || z.vendor_site_code
         FROM po_vendor_sites_all z
            , po_vendors x
        WHERE x.vendor_id = z.vendor_id
          AND z.vendor_site_id = qoh.owning_organization_id)
 ELSE 
   NULL
 END owning_supplier
 , 'SaldoInicial' trx_type
 , NULL
 , NULL
 , NULL
 , NULL schedule_close_date
 , qoh.lot_number
 , msi.segment1 item_code
 , msi.description
 , NULL
 , NULL
 , NULL
 , cat_gl.category_id clase_gl_id
 , cat_gl.segment1 clase_gl
 , cat_gl.description clase_gl_descr
 , NULL
 , SUM (qoh.transaction_quantity) primary_quantity
 , NULL
 , SUM (NVL (qoh.secondary_transaction_quantity, 0)) secondary_quantity
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , NULL
 , TRUNC (pc_fecha_inv)
 - ( TO_NUMBER (TO_CHAR (pc_fecha_inv, 'DD'))
 - 1) period_start_date
 , owning_organization_id
 FROM mtl_system_items msi
 , mtl_parameters par
 , org_organization_definitions ood
 , hr_operating_units hou
 , mtl_item_locations loc
 , (SELECT ic.organization_id
 , ic.inventory_item_id
 , mc.category_id
 , mc.segment1
 , mc.description
 FROM mtl_item_categories_v ic
 , mtl_categories mc
 WHERE ic.category_set_name LIKE 'Categor_a Contable OPM'
 AND mc.category_id = ic.category_id) cat_gl
 , ( -- OnHand Propio
 SELECT moqv.organization_id organization_id
 , moqv.subinventory_code subinventory_code
 , moqv.inventory_item_id inventory_item_id
 , moqv.locator_id
 , moqv.lot_number
 , SUM (transaction_quantity) transaction_quantity
 , SUM (secondary_transaction_quantity) secondary_transaction_quantity
 , NULL owning_organization_id
 , 'N' transito
 FROM mtl_onhand_quantities moqv
 GROUP BY moqv.organization_id
 , moqv.subinventory_code
 , moqv.inventory_item_id
 , moqv.locator_id
 , moqv.lot_number
 , 'N'
 UNION ALL -- En transito
 SELECT ms.from_organization_id organization_id
 , from_subinventory
 , ms.item_id inventory_item_id
 , mmt.locator_id
 , mln.lot_number lot_number
 , SUM (quantity)
 , SUM (mmt.secondary_transaction_quantity) qty2
 , ms.to_organization_id
 , 'Y'
 FROM mtl_supply ms
 , rcv_shipment_headers rsh
 , rcv_shipment_lines rsl
 , mtl_material_transactions mmt
 , mtl_transaction_lot_numbers mln
 WHERE 1 = 1
 AND mmt.transaction_id = mln.transaction_id(+)
 AND mmt.inventory_item_id = mln.inventory_item_id(+)
 AND mmt.organization_id = mln.organization_id(+)
 AND mmt.transaction_id = rsl.mmt_transaction_id
 AND rsh.shipment_header_id = ms.shipment_header_id
 AND rsl.shipment_line_id = ms.shipment_line_id
 AND supply_type_code = 'SHIPMENT'
 AND intransit_owning_org_id IS NOT NULL
 GROUP BY ms.from_organization_id
 , ms.from_subinventory
 , ms.item_id
 , ms.to_organization_id
 , 'Y'
 , mmt.locator_id
 , mln.lot_number
 UNION ALL -- Diferencia de Trx de OnHand Propio
 SELECT mmt.organization_id
 , mmt.subinventory_code
 , mmt.inventory_item_id
 , mmt.locator_id
 , mln.lot_number lot_number
 , -SUM (NVL (mln.primary_quantity, mmt.primary_quantity)) qty1
 , -SUM (NVL (mln.secondary_transaction_quantity, mmt.secondary_transaction_quantity))
 qty2
 , NULL owning_organization_id
 , 'N' transito
 FROM mtl_material_transactions mmt
 , mtl_transaction_lot_numbers mln
 WHERE 1 = 1
 AND mmt.owning_tp_type = 2 -- Ignora Trx de terceros
 -- amanukyan 20180329 estos son stocks de fechas anteriores
 AND NVL (mmt.transaction_source_name, '1111') NOT IN
 ('En mano migrado desde OPM'
 , 'Migrated negative onhand from OPM'
 , 'Migrated onhand from OPM'
 , 'Negativo en mano migrado desde OPM'
 )
 -- amanukyan 20180329 estos son stocks de fechas anteriores
 AND mmt.transaction_id = mln.transaction_id(+)
 AND mmt.inventory_item_id = mln.inventory_item_id(+)
 AND mmt.organization_id = mln.organization_id(+)
 AND TRUNC (mmt.transaction_date) >=
 --= amanukyan 20180706 no quieren que se considere el movimiento del día 1 00:00:00
 TRUNC (pc_fecha_inv)
 GROUP BY mmt.organization_id
 , mmt.subinventory_code
 , mmt.inventory_item_id
 , mmt.locator_id
 , mln.lot_number
 , 'N'
 UNION ALL -- OnHand de Terceros
 SELECT organization_id
 , subinventory_code
 , inventory_item_id
 , locator_id
 , lot_number
 , SUM (transaction_quantity) qty1
 , SUM (secondary_transaction_quantity) qty2
 , owning_organization_id
 , 'N' transito
 FROM mtl_onhand_quantities_detail qd
 WHERE owning_organization_id != organization_id
 GROUP BY qd.organization_id
 , qd.subinventory_code
 , qd.inventory_item_id
 , qd.locator_id
 , qd.lot_number
 , qd.owning_organization_id
 , 'N'
 UNION ALL -- Diferencia de Transacciones de OnHand de Terceros
 SELECT mmt.organization_id
 , mmt.subinventory_code
 , mmt.inventory_item_id
 , mmt.locator_id
 , mln.lot_number lot_number
 , -SUM (NVL (mln.primary_quantity, mmt.primary_quantity)) qty1
 , -SUM (NVL (mln.secondary_transaction_quantity, mmt.secondary_transaction_quantity))
 qty2
 , mmt.owning_organization_id
 , 'N' transito
 FROM mtl_material_transactions mmt
 , mtl_transaction_lot_numbers mln
 WHERE mmt.owning_tp_type = 1 -- trx de terceros
 -- amanukyan 20180329 estos son stocks de fechas anteriores
 AND NVL (mmt.transaction_source_name, '1111') NOT IN
 ('En mano migrado desde OPM'
 , 'Migrated negative onhand from OPM'
 , 'Migrated onhand from OPM'
 , 'Negativo en mano migrado desde OPM'
 )
 -- amanukyan 20180329 estos son stocks de fechas anteriores
 AND mmt.transaction_id = mln.transaction_id(+)
 AND mmt.inventory_item_id = mln.inventory_item_id(+)
 AND mmt.organization_id = mln.organization_id(+)
 AND TRUNC (mmt.transaction_date) >=
 --= amanukyan 20180706 no quieren que se considere el movimiento del día 1 00:00:00
 TRUNC (pc_fecha_inv)
 --and mln.inventory_item_id = 863
 GROUP BY mmt.organization_id
 , mmt.subinventory_code
 , mmt.inventory_item_id
 , mmt.owning_organization_id
 , mmt.transaction_date
 , mmt.locator_id
 , mln.lot_number
 , 'N') qoh
 WHERE qoh.inventory_item_id = msi.inventory_item_id
 AND qoh.organization_id = msi.organization_id
 AND qoh.organization_id = ood.organization_id
 AND cat_gl.organization_id(+) = par.master_organization_id
 AND cat_gl.inventory_item_id(+) = qoh.inventory_item_id
 AND qoh.organization_id = par.organization_id
 AND ood.operating_unit = hou.organization_id
 AND EXISTS (SELECT 1
 FROM org_access_view oav
 WHERE 1 = 1
 AND oav.organization_id = ood.organization_id
 AND oav.responsibility_id = fnd_profile.VALUE ('RESP_ID')
 AND oav.resp_application_id = fnd_profile.VALUE ('RESP_APPL_ID'))
 AND qoh.locator_id = loc.inventory_location_id(+)
 -- params
 AND ood.operating_unit = p_org_id
 AND ( ood.organization_id = p_organization_id
 AND p_organization_id IS NOT NULL
 OR ood.organization_id IN (SELECT organization_id
 FROM org_organization_definitions
 WHERE operating_unit = p_org_id)
 AND p_organization_id IS NULL
 )
 AND ( qoh.subinventory_code = p_subinventory_code
 OR p_subinventory_code IS NULL)
 AND ( qoh.locator_id = p_locator_id
 OR p_locator_id IS NULL)
 AND ( cat_gl.category_id = p_cat_gl
 OR p_cat_gl IS NULL)
 AND ( qoh.inventory_item_id = p_item_id
 OR p_item_id IS NULL)
 AND ( p_lote_desde IS NULL OR
 ( p_lote_desde IS NOT NULL AND
 qoh.lot_number >= p_lote_desde
 )
 )
 AND ( p_lote_hasta IS NULL OR
 ( p_lote_hasta IS NOT NULL AND
 qoh.lot_number <= p_lote_hasta
 )
 )
 GROUP BY ood.operating_unit
 , hou.NAME
 , qoh.organization_id
 , par.organization_code
 , ood.organization_name
 , qoh.subinventory_code
 , qoh.locator_id
 , loc.segment1
 , qoh.inventory_item_id
 , qoh.lot_number
 , msi.segment1
 , msi.description
 , cat_gl.category_id
 , cat_gl.segment1
 , cat_gl.description
 , owning_organization_id
 , TRUNC (pc_fecha_inv)
 - ( TO_NUMBER (TO_CHAR (pc_fecha_inv, 'DD'))
 - 1)) tbl
 ORDER BY organization_code
 , subinventory_code
 , item_code
 , lot_number
 , LOCATOR
 , tipo_reg
 , owning_organization_id
 , transaction_date
 , transaction_id;

 l_ou_name VARCHAR2 (200);
 l_oi_name VARCHAR2 (200);
 l_locator VARCHAR2 (200);
 l_cat_gl VARCHAR2 (200);
 l_item_code VARCHAR2 (200);
 l_period_name_from VARCHAR2 (200);
 l_period_name_to VARCHAR2 (200);
 l_fecha_dia_ant DATE;
 l_cant_init NUMBER;
 l_cant NUMBER;
 l_cant_fin NUMBER;
 l_cant_init2 NUMBER;
 l_cant2 NUMBER;
 l_cant_fin2 NUMBER;
 l_yes_no VARCHAR2 (250);
 l_carta_porte VARCHAR2 (255);
 BEGIN

 fnd_file.put_line (fnd_file.log, 'p_org_id: '||p_org_id);
 fnd_file.put_line (fnd_file.log, 'p_organization_id: '||p_organization_id);
 fnd_file.put_line (fnd_file.log, 'p_subinventory_code: '||p_subinventory_code);
 fnd_file.put_line (fnd_file.log, 'p_locator_id: '||p_locator_id);
 fnd_file.put_line (fnd_file.log, 'p_period_name_from: '||p_period_name_from);
 fnd_file.put_line (fnd_file.log, 'p_period_name_to: '||p_period_name_to);
 fnd_file.put_line (fnd_file.log, 'p_cat_gl: '||p_cat_gl);
 fnd_file.put_line (fnd_file.log, 'p_item_id : '||p_item_id );
 fnd_file.put_line (fnd_file.log, 'p_lote_desde: '||p_lote_desde);
 fnd_file.put_line (fnd_file.log, 'p_lote_hasta: '||p_lote_hasta);
 fnd_file.put_line (fnd_file.log, 'p_source_carta_porte: '||p_source_carta_porte);
 fnd_file.put_line (fnd_file.log, 'p_stock_init_flag: '||p_stock_init_flag);



 SELECT (SELECT NAME
 FROM hr_operating_units
 WHERE organization_id = p_org_id) ou_name
 , (SELECT organization_name
 FROM org_organization_definitions
 WHERE organization_id = p_organization_id) oi_name
 , (SELECT segment1
 FROM mtl_item_locations
 WHERE inventory_location_id = p_locator_id)
 , (SELECT mc.segment1
 || '-'
 || mc.description
 FROM mtl_categories mc
 WHERE mc.category_id = p_cat_gl)
 , (SELECT segment1
 || '-'
 || description
 FROM mtl_system_items
 WHERE inventory_item_id = p_item_id
 AND ROWNUM = 1)
 INTO l_ou_name
 , l_oi_name
 , l_locator
 , l_cat_gl
 , l_item_code
 FROM DUAL;

 print_output ( 'Unidad Operativa: '
 || l_ou_name);
 print_output ( 'Org.Inventario: '
 || l_oi_name);
 print_output ( 'Subinventario: '
 || p_subinventory_code);
 print_output ( 'Localizador: '
 || l_locator);

 SELECT DECODE (p_stock_init_flag
 , 'Y', 'Sí'
 , 'No'
 )
 INTO l_yes_no
 FROM DUAL;

---
 SELECT period_name
 , period_start_date
 INTO l_period_name_from
 , l_fecha_dia_ant
 FROM (SELECT DISTINCT period_year
 || LPAD (period_num
 , 2
 , '0'
 ) period_num
 , period_name
 , TRUNC (period_start_date) period_start_date
 FROM org_acct_periods)
 WHERE period_num = p_period_name_from;

 SELECT period_name
 INTO l_period_name_to
 FROM (SELECT DISTINCT period_year
 || LPAD (period_num
 , 2
 , '0'
 ) period_num
 , period_name
 FROM org_acct_periods)
 WHERE period_num = p_period_name_to;

 fnd_file.put_line (fnd_file.LOG, 'l_fecha_dia_ant : '
 || l_fecha_dia_ant);
 fnd_file.put_line (fnd_file.LOG, 'l_period_name_from: '
 || l_period_name_from);
 fnd_file.put_line (fnd_file.LOG, 'l_period_name_to : '
 || l_period_name_to);
 print_output ( 'Período Desde: '
 || l_period_name_from);
 print_output ( 'Período Hasta: '
 || l_period_name_to);
 print_output ( 'Cat GL: '
 || l_cat_gl);
 print_output ( 'Artículo: '
 || l_item_code);
 print_output ( 'Lote Desde: '
 || p_lote_desde);
 print_output ( 'Lote Hasta: '
 || p_lote_hasta);
 print_output ( 'Stock Inicial sin Mov: '
 || l_yes_no);
 print_output (' ');
 print_output ( 'Clase GL'
 || '|'
 || 'Descripción Clase GL'
 || '|'
 || 'Clase Costo'
 || '|'
 || 'Descripción Clase Costo'
 || '|'
 || 'Cod. Artículo'
 || '|'
 || 'Descripción Artículo'
 || '|'
 || 'Unidad Operativa'
 || '|'
 || 'Cod. Organización'
 || '|'
 || 'Nombre Organización'
 || '|'
 || 'Subinventario'
 || '|'
 || 'Establecimiento'
 || '|'
 ||
 -- 'Descr establecimiento' || '|' ||
 'Ubicación'
 || '|'
 || 'Lote'
 || '|'
 || 'Owner'
 || '|'
 || 'Fecha Transacción'
 || '|'
 || 'Tipo Transacción'
 || '|'
 || 'Motivo Transacción'
 || '|'
 || 'Id Transactión'
 || '|'
 || 'UOM1'
 || '|'
 || 'Saldo inicial'
 || '|'
 || 'Cant 1'
 || '|'
 || 'Saldo final'
 || '|'
 || 'UOM2'
 || '|'
 || 'Saldo inicial'
 || '|'
 || 'Cant 2'
 || '|'
 || 'Saldo final'
 || '|'
 || 'Remito/Carta Porte'
 || '|'
 || 'Numero Liquidacion' -- CR1786 ASilva Marzo 2019
 || '|'
 --|| 'Productor/Cliente'
 || 'Proveedor/Cliente' -- amanukyan 20190812 #2387681 id cambio 415
 || '|'
 || 'Nro contrato'
 || '|'
 || 'Flag transferido'
 || '|'
 || 'Flag recibido'
 || '|'
 || 'CMV'
 || '|'
 || 'Ped Vta'
 || '|'
 || 'Línea Ped Vta'
 || '|'
 || 'Tipo Ped'
 || '|'
 || 'Cant Ped'
 || '|'
 || 'Orden de Compra'
 || '|'
 || 'Nro Línea OC'
 || '|'
 || 'Orden Trabajo'
 || '|'
 || 'Proyecto'
 || '|'
 || 'Tarea'
 || '|'
 || 'Tipo Erogación'
 || '|'
 || 'Parcela'
 || '|'
 || 'Variedad'
 || '|'
 || 'Vale de consumo'
 || '|'
 || 'Patente vehiculo'
 || '|'
 || 'Kms vehículo'
 || '|'
 || 'Usuario creación'
 || '|'
 || 'Fecha creación'
 || '|'
 || 'Referencia');

 FOR r1 IN c1 (l_fecha_dia_ant)
 LOOP
 IF r1.tipo_reg = '1'
 OR ( r1.cant_movs = 0
 AND r1.tipo_reg = '0'
 AND p_stock_init_flag = 'Y')
 THEN
 --
 l_cant_init := 0;
 l_cant := 0;
 l_cant_fin := 0;
 --
 l_cant_init2 := 0;
 l_cant2 := 0;
 l_cant_fin2 := 0;

 -- SD1264
			IF (r1.carta_porte IS NULL ) THEN
				SELECT
				NVL (MAX (ofd.XX_OM_CARTA_PORTE),'') INTO l_carta_porte
				FROM
				mtl_material_transactions mtt
				, oe_order_lines_all ol
				, oe_order_lines_all_dfv ofd
				, mtl_sales_orders mso
				WHERE
				mtt.source_code = 'ORDER ENTRY'
				AND ol.rowid = ofd.rowid
				AND mtt.transaction_source_id = mso.sales_order_id
				AND ol.line_id = mtt.trx_source_line_id
				AND mtt.transaction_id = r1.transaction_id
				;
			ELSE
				l_carta_porte := r1.carta_porte;
			END IF;
 --
 IF ( r1.cant_movs = 0
 AND r1.tipo_reg = '0')
 THEN
 --
 l_cant_init := r1.qty1;
 l_cant := 0;
 l_cant_fin := r1.saldo_final1;
 --
 l_cant_init2 := r1.qty2;
 l_cant2 := 0;
 l_cant_fin2 := r1.saldo_final2;
 ELSE
 --
 l_cant_init := r1.saldo_inicial1;
 l_cant := r1.qty1;
 l_cant_fin := r1.saldo_final1;
 --
 l_cant_init2 := r1.saldo_inicial2;
 l_cant2 := r1.qty2;
 l_cant_fin2 := r1.saldo_final2;
 END IF;

 -- para no exportar los regs de saldo inicial
 IF ( l_cant_init <> 0
 OR l_cant_init2 <> 0
 OR r1.cant_movs <> 0)
 THEN -- amanukyan 20180924 no mostrar los que no tienen movs iniciales
 print_output ( r1.clase_gl
 || '|'
 || r1.clase_gl_descr
 || '|'
 || r1.clase_costo
 || '|'
 || r1.clase_costo_descr
 || '|'
 || r1.item_code
 || '|'
 || r1.item_description
 || '|'
 || r1.ou_name
 || '|'
 || r1.organization_code
 || '|'
 || r1.organization_name
 || '|'
 || r1.subinventory_code
 || '|'
 ||
 --r1.establecimiento_id || '|' || -- amanukyan 20180130 issue
 r1.descr_establecimiento
 || '|'
 || r1.LOCATOR
 || '|'
 || r1.lot_number
 || '|'
 || CASE WHEN r1.transaction_type_name = 'WIP Issue' THEN '' ELSE r1.owning_supplier END -- adm CR2241 cambio 1561 
 || '|'
 || r1.transaction_date
 || '|'
 || r1.transaction_type_name
 || '|'
 || r1.reason_name
 || '|'
 || r1.transaction_id
 || '|'
 || r1.primary_uom_code
 || '|'
 || l_cant_init
 || '|'
 || l_cant
 || '|'
 || l_cant_fin
 || '|'
 || r1.secondary_uom_code
 || '|'
 || l_cant_init2
 || '|'
 || l_cant2
 || '|'
 || l_cant_fin2
 || '|'
 --|| r1.carta_porte
 || l_carta_porte
 || '|'
 || r1.numero_liquidacion -- CR1786
 || '|'
 || r1.productor
 || '|'
 || r1.nro_contrato
 || '|'
 || r1.flag_transferido
 || '|'
 || r1.flag_recibido
 || '|'
 || r1.cmv
 || '|'
 || r1.order_number
 || '|'
 || r1.line_number
 || '|'
 || r1.order_type
 || '|'
 || r1.ordered_qty
 || '|'
 || r1.po_number
 || '|'
 || r1.po_line_number
 || '|'
 || r1.xx_opm_ot
 || '|'
 || r1.project_number
 || '|'
 || r1.task_name
 || '|'
 || r1.expenditure_type
 || '|'
 || r1.xx_opm_parcela
 || '|'
 || r1.xx_opm_variedad
 || '|'
 || r1.xx_opm_vale_consumo
 || '|'
 || r1.xx_opm_patente_vehiculo
 || '|'
 || r1.xx_opm_km_vehiculo
 || '|'
 || r1.usuario_creacion
 || '|'
 || r1.creation_date
 || '|'
 || r1.transaction_reference);
 END IF;
 END IF;
 END LOOP;
 END main;
END xx_inv_resumen_trx_pkg; 
/

