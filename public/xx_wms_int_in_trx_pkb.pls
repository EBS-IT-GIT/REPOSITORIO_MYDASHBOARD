create or replace
PACKAGE BODY XX_WMS_INT_IN_TRX_PK AS
 /* $Header: xx_wms_int_in_trx_pkb.pls 1.9    30-JUN-2020   */
 -- --------------------------------------------------------------------------
 --  1.0  02-10-2019  MGonzalez   Version Original
 --  1.1  05-12-2019  MGonzalez   Tomo la primer OP del lote
 --  1.2  06-12-2019  MGonzalez   Mayor debug en gme
 --  1.3  11-12-2019  MGonzalez   substr de lpn_nbr para sacar el prefijo en
 --                               transaction_reference
 --  1.4  13-12-2019  MGonzalez   Se agrega ajuste stock y bloqueo
 --  1.5  13-01-2020  MGonzalez   Se agrega Recepcion RMA
 --  1.6  16-01-2020  MGonzalez   Se busca batch_id por linea+lote
 --  1.7  20-02-2020  MGonzalez   Se agrega update_lot_status para bloqueo
 --  1.8  18-03-2020  MGonzalez   Se agrega modifica get_locator_id para 
 --                               que si sale por no data found tome el valor nulo
 --  1.9  30-06-2020  MGonzalez   Se controla REPROCESO positivo 
 --                               y control por bloqueo y desbloqueo con retencion
 
PROCEDURE get_organization_id (p_org_code         IN VARCHAR2
                              ,p_org_type         IN VARCHAR2
                              ,x_organization_id OUT NUMBER
                              ,x_org_code        OUT VARCHAR2
                              ,x_error_mesg      OUT VARCHAR2) IS
e_error         EXCEPTION;
l_calling_sequence VARCHAR2(100):='xx_wms_int_in_trx_pk.get_organization_id';
BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  SELECT mp.organization_id
        ,mp.organization_code
    INTO x_organization_id
        ,x_org_code
    FROM mtl_parameters mp
        ,fnd_lookup_values_vl flv
        ,fnd_lookup_values_dfv flv_d
   WHERE flv.lookup_type = 'XX_MAPEO_EBS_WMS'
     AND flv.lookup_code = p_org_code
     AND ((p_org_type = 'ORG_DECLARACION_PROD'
          AND flv_d.XX_Org_Declaracion_Prod = mp.organization_code)
         OR
          (p_org_type = 'ORG_TRANSFER_PROD'
          AND flv_d.XX_Org_transfer_Prod = mp.organization_code)
         OR
          (p_org_type = 'ORG_CONFIRM_DESPACHO'
          AND flv_d.XX_Org_Confirmacion_Despacho = mp.organization_code)
         )
     AND flv.rowid = flv_d.row_id;

  xx_debug_pk.debug(l_calling_sequence||', Fin',1);

EXCEPTION
  WHEN OTHERS THEN
    x_error_mesg := 'Error en '||l_calling_sequence||',p_org_code: '||p_org_code||': '||sqlerrm;
END get_organization_id;

PROCEDURE get_subinventory_code (p_org_code           IN VARCHAR2
                                ,p_subinv_type        IN VARCHAR2
                                ,x_subinventory_code OUT VARCHAR2
                                ,x_error_mesg        OUT VARCHAR2) IS
e_error         EXCEPTION;
l_calling_sequence VARCHAR2(100):='xx_wms_int_in_trx_pk.get_subinventory_code';
BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  SELECT decode(p_subinv_type,'SUBINV_DECLARACION_PROD',flv_d.XX_sub_Declaracion_Prod
                             ,'SUBINV_TRANSFER_PROD',flv_d.XX_sub_Transfer_Prod
                             ,'SUBINV_CONFIRM_DESPACHO',flv_d.XX_Sub_Cofirmacion_Despacho) subinv_code
    INTO x_subinventory_code
    FROM fnd_lookup_values_vl flv
        ,fnd_lookup_values_dfv flv_d
   WHERE flv.lookup_type = 'XX_MAPEO_EBS_WMS'
     AND flv.lookup_code = p_org_code
     AND flv.rowid = flv_d.row_id;

  xx_debug_pk.debug(l_calling_sequence||', Fin',1);

EXCEPTION
  WHEN OTHERS THEN
    x_error_mesg := 'Error en '||l_calling_sequence||',p_org_code: '||p_org_code||': '||sqlerrm;
END get_subinventory_code;

PROCEDURE get_locator_id (p_org_code           IN VARCHAR2
                         ,p_lock_code          IN VARCHAR2
                         ,x_locator_code      OUT VARCHAR2
                         ,x_locator_id        OUT NUMBER
                         ,x_error_mesg        OUT VARCHAR2) IS
e_error         EXCEPTION;
l_calling_sequence VARCHAR2(100):='xx_wms_int_in_trx_pk.get_locator_id';
BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  xx_debug_pk.debug(l_calling_sequence||', p_org_code: '||p_org_code,1);
  xx_debug_pk.debug(l_calling_sequence||', p_lock_code: '||p_lock_code,1);

  BEGIN
    SELECT flv_d.XX_LOCALIZADOR_ESTADO locator_name
      INTO x_locator_code
      FROM fnd_lookup_values_vl flv
          ,fnd_lookup_values_dfv flv_d
     WHERE flv.lookup_type             = 'XX_EBS_WMS_ESTADOS'
       AND substr(flv.lookup_code,1,3) = p_org_code
       AND nvl(flv.description,'NULO') = nvl(p_lock_code,'NULO')
       AND flv.rowid                   = flv_d.row_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN 
      BEGIN
        SELECT flv_d.XX_LOCALIZADOR_ESTADO locator_name
          INTO x_locator_code
          FROM fnd_lookup_values_vl flv
              ,fnd_lookup_values_dfv flv_d
         WHERE flv.lookup_type             = 'XX_EBS_WMS_ESTADOS'
           AND substr(flv.lookup_code,1,3) = p_org_code
           AND nvl(flv.description,'NULO') = 'NULO'
           AND flv.rowid                   = flv_d.row_id;
      EXCEPTION
        WHEN OTHERS THEN
          x_error_mesg := 'Error al obtener el localizador en XX_EBS_WMS_ESTADOS para estado NULO,'||' ORG: '||p_org_code||'. '||sqlerrm;
          RAISE e_error;
      END;
    WHEN OTHERS THEN
      x_error_mesg := 'Error al obtener el localizador en XX_EBS_WMS_ESTADOS para estado: '||p_lock_code||' ORG: '||p_org_code||'. '||sqlerrm;
      RAISE e_error;
  END;
  xx_debug_pk.debug(l_calling_sequence||', x_locator_code: '||x_locator_code,1);
  BEGIN
    SELECT mil.inventory_location_id
      INTO x_locator_id
      FROM mtl_item_locations mil
          ,mtl_parameters mp
     WHERE mp.organization_code = p_org_code
       AND mil.segment1         = x_locator_code
       AND mil.organization_id  = mp.organization_id;
  EXCEPTION
    WHEN OTHERS THEN
      x_error_mesg := 'Error al obtener el locator_id para codigo:'||x_locator_code||'ORG: '||p_org_code||'. '||sqlerrm;
      RAISE e_error;
  END;
  xx_debug_pk.debug(l_calling_sequence||', x_locator_id: '||x_locator_id,1);
  xx_debug_pk.debug(l_calling_sequence||', Fin',1);

EXCEPTION
  WHEN e_error THEN
    xx_debug_pk.debug(l_calling_sequence||', '||x_error_mesg,1);
  WHEN OTHERS THEN
    x_error_mesg := 'Error en '||l_calling_sequence||', p_org_code: '||p_org_code||': '||sqlerrm;
END get_locator_id;

PROCEDURE get_item_id (p_item_code          IN VARCHAR2
                      ,p_organization_id    IN NUMBER
                      ,x_inventory_item_id OUT NUMBER
                      ,x_error_mesg        OUT VARCHAR2) IS
e_error         EXCEPTION;
l_calling_sequence VARCHAR2(100):='xx_wms_int_in_trx_pk.get_item_id';

BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  SELECT msi.inventory_item_id
    INTO x_inventory_item_id
    FROM mtl_system_items msi
   WHERE msi.segment1        = p_item_code
     AND msi.organization_id = p_organization_id;

  xx_debug_pk.debug(l_calling_sequence||', Fin',1);

EXCEPTION
  WHEN OTHERS THEN
    x_error_mesg := 'Error en '||l_calling_sequence||',p_item_code: '||p_item_code||': '||sqlerrm;
END get_item_id;

PROCEDURE get_item_uom (p_inventory_item_id  IN NUMBER
                       ,p_uom_type           IN VARCHAR2
                       ,p_organization_id    IN NUMBER
                       ,x_uom_code          OUT VARCHAR2
                       ,x_error_mesg        OUT VARCHAR2) IS
e_error         EXCEPTION;
l_calling_sequence VARCHAR2(100):='xx_wms_int_in_trx_pk.get_item_uom';

BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  IF p_uom_type = 'DUN14' THEN
    SELECT mcr_d.xx_uom_wms
      INTO x_uom_code
      FROM mtl_cross_references mcr
          ,mtl_cross_references_dfv mcr_d
     WHERE mcr.inventory_item_id                      = p_inventory_item_id
       AND mcr.cross_reference_type                   = 'DUN14'
       AND nvl(mcr.organization_id,p_organization_id) = p_organization_id
       AND mcr.rowid = mcr_d.row_id ;
  ELSE
    null; -- futuros tipos de UOM
  END IF;
  IF x_uom_code IS NULL THEN
    x_error_mesg := 'No existe UOM en Referencia Cruzada DUN14';
  END IF;

  xx_debug_pk.debug(l_calling_sequence||', Fin',1);

EXCEPTION
  WHEN OTHERS THEN
    x_error_mesg := 'Error en '||l_calling_sequence||',p_inventory_item_id: '||p_inventory_item_id||': '||sqlerrm;
END get_item_uom;

PROCEDURE get_reason_id (p_reason_code  IN VARCHAR2
                        ,x_reason_id   OUT NUMBER
                        ,x_error_mesg  OUT VARCHAR2) IS
e_error         EXCEPTION;
l_calling_sequence VARCHAR2(100):='xx_wms_int_in_trx_pk.get_reason_id';

BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  SELECT mtr.reason_id
    INTO x_reason_id
    FROM mtl_transaction_reasons mtr
   WHERE mtr.reason_name = p_reason_code;
  xx_debug_pk.debug(l_calling_sequence||', Fin',1);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_error_mesg := 'No existe reason: '||p_reason_code;
  WHEN OTHERS THEN
    x_error_mesg := 'Error en '||l_calling_sequence||',p_reason_code: '||p_reason_code||': '||sqlerrm;
END get_reason_id;

PROCEDURE get_trx_type (p_org_code           IN VARCHAR2
                       ,p_trx_type           IN VARCHAR2
                       ,x_trx_type_name     OUT VARCHAR2
                       ,x_error_mesg        OUT VARCHAR2) IS
e_error         EXCEPTION;
l_calling_sequence VARCHAR2(100):='xx_wms_int_in_trx_pk.get_trx_type';
BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  xx_debug_pk.debug(l_calling_sequence||', p_org_code: '||p_org_code,1);
  xx_debug_pk.debug(l_calling_sequence||', p_trx_type: '||p_trx_type,1);
  BEGIN
    SELECT decode(p_trx_type,'ALTA',flv_d.XX_TRXN_ALTA
                            ,'BAJA',flv_d.XX_TRXN_BAJA) trx_type
      INTO x_trx_type_name
      FROM fnd_lookup_values_vl flv
          ,fnd_lookup_values_dfv flv_d
     WHERE flv.lookup_type = 'XX_MAPEO_EBS_WMS'
       AND flv.lookup_code = p_org_code
       AND flv.rowid = flv_d.row_id;
  EXCEPTION
    WHEN OTHERS THEN
      x_error_mesg := 'Error al buscar ddff de trx_type '||p_trx_type||'. Error: '||sqlerrm;
      RAISE e_error;
  END;

  xx_debug_pk.debug(l_calling_sequence||', x_trx_type_name: '||x_trx_type_name,1);
  xx_debug_pk.debug(l_calling_sequence||', Fin',1);

EXCEPTION
  WHEN e_error THEN NULL;
  WHEN OTHERS THEN
    x_error_mesg := 'Error en '||l_calling_sequence||',p_org_code: '||p_org_code||': '||sqlerrm;
END get_trx_type;

PROCEDURE get_trx_alias(p_org_code           IN VARCHAR2
                       ,x_trx_alias         OUT VARCHAR2
                       ,x_error_mesg        OUT VARCHAR2) IS
e_error         EXCEPTION;
l_calling_sequence VARCHAR2(100):='xx_wms_int_in_trx_pk.get_trx_alias';
BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  SELECT flv_d.XX_ALIAS
    INTO x_trx_alias
    FROM fnd_lookup_values_vl flv
        ,fnd_lookup_values_dfv flv_d
   WHERE flv.lookup_type = 'XX_MAPEO_EBS_WMS'
     AND flv.lookup_code = p_org_code
     AND flv.rowid = flv_d.row_id;

  xx_debug_pk.debug(l_calling_sequence||', Fin',1);

EXCEPTION
  WHEN OTHERS THEN
    x_error_mesg := 'Error en '||l_calling_sequence||',p_org_code: '||p_org_code||': '||sqlerrm;
END get_trx_alias;

PROCEDURE validate_lot_number (p_batch_id            IN OUT NUMBER
                              ,p_inventory_item_id   IN     NUMBER
                              ,p_lot_number          IN     VARCHAR2
                              ,p_linea               IN     VARCHAR2
                              ,p_material_detail_id OUT     NUMBER
                              ,x_error_mesg         OUT     VARCHAR2) IS
e_error            EXCEPTION;
l_calling_sequence VARCHAR2(100):='xx_wms_int_in_trx_pk.validate_lot_number';
l_exists           NUMBER;
CURSOR c_lot IS
  SELECT distinct
         gmd.material_detail_id
        ,gbh.batch_id
        ,gbh.batch_no
        ,rownum row_num
    FROM gme_pending_product_lots gppl
        ,gme_material_details gmd
        ,gme_batch_header_dfv gbh_dfv
        ,gme_batch_header gbh
   WHERE gppl.batch_id           = nvl(p_batch_id,gppl.batch_id)
     AND gmd.inventory_item_id   = p_inventory_item_id
     AND gppl.lot_number         = p_lot_number
     AND gbh.batch_status        = 2
     AND gbh.batch_id            = gmd.batch_id
     AND gppl.material_detail_id = gmd.material_detail_id
     AND nvl(gbh_dfv.linea,'X')  = nvl(p_linea,'X')
     AND gbh_dfv.row_id          = gbh.rowid
;

BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  SELECT a.material_detail_id
        ,a.batch_id
    INTO p_material_detail_id
        ,p_batch_id
    FROM (SELECT distinct
                 gmd.material_detail_id
                ,gbh.batch_id
            FROM gme_pending_product_lots gppl
                ,gme_material_details gmd
                ,gme_batch_header_dfv gbh_dfv
                ,gme_batch_header gbh
           WHERE gppl.batch_id           = nvl(p_batch_id,gppl.batch_id)
             AND gmd.inventory_item_id   = p_inventory_item_id
             AND gppl.lot_number         = p_lot_number
             AND gbh.batch_status        = 2
             AND gbh.batch_id            = gmd.batch_id
             AND gppl.material_detail_id = gmd.material_detail_id
             AND nvl(gbh_dfv.linea,'X')  = nvl(p_linea,'X')
             AND gbh_dfv.row_id          = gbh.rowid
           ORDER BY gbh.batch_id)a
   WHERE rownum = 1
   ;
  xx_debug_pk.debug(l_calling_sequence||', Fin',1);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_error_mesg := 'Lote '||p_lot_number||', linea: '||p_linea||' inexistente en una orden en estado WIP';
  WHEN TOO_MANY_ROWS THEN
    x_error_mesg := 'Lote '||p_lot_number||', linea: '||p_linea||' en mas de una orden en estado WIP: ';
    p_batch_id           := '';
    p_material_detail_id := '';
    FOR r_lot IN c_lot LOOP
    xx_debug_pk.debug(l_calling_sequence||'row_num: '||r_lot.row_num,1);
    xx_debug_pk.debug(l_calling_sequence||'batch_no: '||r_lot.batch_no,1);
      IF r_lot.row_num = 1 THEN
        x_error_mesg := x_error_mesg||r_lot.batch_no;
      ELSE
        x_error_mesg := x_error_mesg||', '||r_lot.batch_no;
      END IF;
    END LOOP;
  WHEN OTHERS THEN
    x_error_mesg := 'Error al buscar lote en '||l_calling_sequence||',p_inventory_item_id: '||p_inventory_item_id||
                    ', p_lot_number: '||p_lot_number||
                    ': '||sqlerrm;
END validate_lot_number;

PROCEDURE create_gme_trx (p_shipment_nbr          IN VARCHAR2
                         ,p_inventory_item_id     IN NUMBER
                         ,p_organization_id       IN NUMBER
                         ,p_subinventory_code     IN VARCHAR2
                         ,p_locator_id            IN NUMBER
                         ,p_trx_quantity          IN NUMBER
                         ,p_trx_uom               IN VARCHAR2
                         ,p_lpn_nbr               IN VARCHAR2
                         ,p_lot_number            IN VARCHAR2
                         ,p_create_ts             IN VARCHAR2
                         ,p_transaction_type      IN VARCHAR2
                         ,x_error_mesg           OUT VARCHAR2) IS

e_error                       EXCEPTION;
l_batch_id                    NUMBER;
l_batch_status                NUMBER;
l_trx_source_line_id          NUMBER;
l_orig_transaction_id         NUMBER;
l_transaction_interface_id    NUMBER;
l_transaction_type_id         NUMBER;
l_transaction_action_id       NUMBER;
l_org_code                    VARCHAR2(30);
lx_message_count              VARCHAR2(1000);
lx_message_list               VARCHAR2(10000);
lx_return_status              VARCHAR2(1000);
l_mmti_rec                    mtl_transactions_interface%ROWTYPE;
l_mmli_tbl                    gme_common_pvt.mtl_trans_lots_inter_tbl;
lx_mmt_rec                    mtl_material_transactions%ROWTYPE;
lx_mmln_tbl                   gme_common_pvt.mtl_trans_lots_num_tbl;


l_calling_sequence VARCHAR2(100):='xx_wms_int_in_trx_pk.create_gme_trx';

BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  xx_debug_pk.debug(l_calling_sequence||', p_inventory_item_id: '||p_inventory_item_id,1);
  xx_debug_pk.debug(l_calling_sequence||', p_shipment_nbr: '||p_shipment_nbr,1);
  xx_debug_pk.debug(l_calling_sequence||', p_organization_id: '||p_organization_id,1);
  xx_debug_pk.debug(l_calling_sequence||', p_subinventory_code: '||p_subinventory_code,1);
  xx_debug_pk.debug(l_calling_sequence||', p_locator_id: '||p_locator_id,1);
  xx_debug_pk.debug(l_calling_sequence||', p_trx_quantity: '||p_trx_quantity,1);
  xx_debug_pk.debug(l_calling_sequence||', p_trx_uom: '||p_trx_uom,1);
  xx_debug_pk.debug(l_calling_sequence||', p_lpn_nbr: '||p_lpn_nbr,1);
  xx_debug_pk.debug(l_calling_sequence||', p_lot_number: '||p_lot_number,1);
  xx_debug_pk.debug(l_calling_sequence||', p_create_ts: '||p_create_ts,1);
    --fnd_global.apps_initialize(user_id =>39617,resp_id =>50265 ,resp_appl_id =>550 );
    --fnd_profile.initialize (39617);
    lx_return_status := fnd_api.g_ret_sts_success;
    fnd_msg_pub.initialize;

  gme_common_pvt.g_error_count := 0;
  gme_common_pvt.set_timestamp;
  gme_common_pvt.g_move_to_temp := fnd_api.g_false;


  SELECT mtl_material_transactions_s.NEXTVAL
  INTO l_transaction_interface_id
  FROM DUAL;

  /* No se usa mas el batch que viene de WMS - Modificacion 051119
  BEGIN
    SELECT gbh.batch_id
          ,gbh.batch_status
          --,gmd.material_detail_id
      INTO l_batch_id
          ,l_batch_status
          --,l_TRX_SOURCE_LINE_ID
      FROM gme_batch_header gbh
          --,gme_material_details gmd
     WHERE 1=1--gbh.batch_id = gmd.batch_id
       AND gbh.batch_no = p_shipment_nbr
       ;
       --AND gmd.line_type IN (1,2)
       --AND gmd.inventory_item_id = p_inventory_item_id;
  EXCEPTION
    WHEN OTHERS THEN
      x_error_mesg := 'Error al buscar orden '||p_shipment_nbr||'. '||sqlerrm;
      RAISE e_error;
  END;
  xx_debug_pk.debug(l_calling_sequence||', l_batch_id: '||l_batch_id,1);
  xx_debug_pk.debug(l_calling_sequence||', l_batch_status: '||l_batch_status,1);
  IF l_batch_status != 2 THEN
    x_error_mesg := 'La orden '||p_shipment_nbr||' no se encuentra en estado WIP';
    RAISE e_error;
  END IF;
  */
  xx_debug_pk.debug(l_calling_sequence||', linea: '||replace(substr(p_shipment_nbr,instr(p_shipment_nbr,'-')+1),p_lot_number,''),1);
  validate_lot_number (p_batch_id           => l_batch_id
                      ,p_inventory_item_id  => p_inventory_item_id
                      ,p_lot_number         => p_lot_number
                      ,p_linea              => replace(substr(p_shipment_nbr,instr(p_shipment_nbr,'-')+1),p_lot_number,'')
                      ,p_material_detail_id => l_trx_source_line_id
                      ,x_error_mesg         => x_error_mesg);
  IF x_error_mesg IS NOT NULL THEN
    RAISE e_error;
  END IF;

  xx_debug_pk.debug(l_calling_sequence||', l_TRX_SOURCE_LINE_ID: '||l_TRX_SOURCE_LINE_ID,1);
  SELECT mtt.transaction_type_id
        ,mtt.transaction_action_id
    INTO l_transaction_type_id
        ,l_transaction_action_id
    FROM mtl_transaction_types mtt
   WHERE mtt.transaction_type_name = p_transaction_type;--'WIP Completion';

  SELECT mp.organization_code
    INTO l_org_code
    FROM mtl_parameters mp
   WHERE mp.organization_id = p_organization_id;
  xx_debug_pk.debug(l_calling_sequence||', l_org_code: '||l_org_code,1);

  IF l_transaction_type_id = 44 THEN   --WIP Completion
    l_mmti_rec.transaction_interface_id         := l_transaction_interface_id;
    l_mmti_rec.transaction_header_id            := l_transaction_interface_id;
    l_mmti_rec.transaction_source_id            := l_transaction_interface_id;
    l_mmti_rec.organization_id                  := p_organization_id;
    l_mmti_rec.subinventory_code                := p_subinventory_code;
    l_mmti_rec.locator_id                       := p_locator_id;
    l_mmti_rec.inventory_item_id                := p_inventory_item_id;
    l_mmti_rec.source_header_id                 := l_batch_id;
    l_mmti_rec.transaction_source_id            := l_batch_id; -- Batch_id
    l_mmti_rec.trx_source_line_id               := l_trx_source_line_id; -- material_detail_id
    l_mmti_rec.transaction_quantity             := p_trx_quantity;
    l_mmti_rec.transaction_uom                  := p_trx_uom;
    l_mmti_rec.primary_quantity                 := p_trx_quantity;
    l_mmti_rec.secondary_uom_code               := '';
    l_mmti_rec.secondary_transaction_quantity   := '';
    l_mmti_rec.source_code                      := p_lpn_nbr;
    l_mmti_rec.TRANSACTION_SOURCE_TYPE_ID       := 5;
    l_mmti_rec.wip_entity_type                  := 9;
    l_mmti_rec.TRANSACTION_ACTION_ID            := l_transaction_action_id; --gme_common_pvt.g_prod_comp_txn_action;   --1;
    l_mmti_rec.TRANSACTION_TYPE_ID              := l_transaction_type_id;   --gme_common_pvt.g_prod_completion;--44;
    l_mmti_rec.TRANSACTION_DATE                 := to_date(replace(p_create_ts,'T',''),'yyyy-mm-ddhh24:mi:ss'); --i.transaction_date;
    l_mmti_rec.TRANSACTION_REFERENCE            := substr(p_lpn_nbr,4);
    l_mmti_rec.LAST_UPDATE_DATE                 := SYSDATE;
    l_mmti_rec.LAST_UPDATED_BY                  := fnd_global.user_id;
    l_mmti_rec.CREATION_DATE                    := SYSDATE;
    l_mmti_rec.CREATED_BY                       := fnd_global.user_id;
    l_mmti_rec.LAST_UPDATE_LOGIN                := fnd_global.login_id;

    ---------------------------------------Lot Details
    l_mmli_tbl(1).last_update_date       := gme_common_pvt.g_timestamp;
    l_mmli_tbl(1).last_updated_by        := gme_common_pvt.g_user_ident;
    l_mmli_tbl(1).creation_date          := gme_common_pvt.g_timestamp;
    l_mmli_tbl(1).created_by             := gme_common_pvt.g_user_ident;
    l_mmli_tbl(1).lot_number             := p_lot_number;
    l_mmli_tbl(1).transaction_quantity   := p_trx_quantity;
    ------------------------------------------------


    apps.gme_api_pub.create_material_txn (
                  p_api_version          => 2.0
                  ,p_validation_level    => gme_common_pvt.g_max_errors
                  ,p_init_msg_list       => fnd_api.g_true
                  ,p_commit              => fnd_api.g_false
                  ,x_message_count       => lx_message_count
                  ,x_message_list        => lx_message_list
                  ,x_return_status       => lx_return_status
                  ,p_org_code            => l_org_code
                  ,p_mmti_rec            => l_mmti_rec
                  ,p_mmli_tbl            => l_mmli_tbl
                  ,p_batch_no            => NULL
                  ,p_line_no             => NULL
                  ,p_line_type           => NULL
                  ,p_create_lot          => fnd_api.g_true--NULL
                  ,p_generate_lot        => NULL
                  ,p_generate_parent_lot => NULL
                  ,x_mmt_rec             => lx_mmt_rec
                  ,x_mmln_tbl            => lx_mmln_tbl );

    xx_debug_pk.debug(l_calling_sequence||', x_message_count ='||TO_CHAR(lx_message_count),1);
    xx_debug_pk.debug(l_calling_sequence||', lx_message_list ='||substr(lx_message_list,1,120),1);
    xx_debug_pk.debug(l_calling_sequence||', lx_return_status ='||lx_return_status,1);
    xx_debug_pk.debug(l_calling_sequence||', lx_mmt_rec.transaction_id ='||lx_mmt_rec.transaction_id,1);

    IF nvl(lx_message_count,0) >=1 THEN
      FOR I IN 1..lx_message_count LOOP
        xx_debug_pk.debug(l_calling_sequence||I||'. '||SUBSTR(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ),1, 255),1);
      END LOOP;
    END IF;
    IF (nvl(lx_message_count,0) = 0) THEN
      UPDATE mtl_material_transactions mtt
         SET mtt.transaction_reference = substr(p_lpn_nbr,4)
            ,mtt.source_line_id        = ''
       WHERE mtt.transaction_id = lx_mmt_rec.transaction_id;
    ELSE
      --x_error_mesg := 'Error en gme_api_pub.create_material_txn: '||substr(lx_message_list,1,120);
      --061219
      x_error_mesg := substr('Error en gme_api_pub.create_material_txn: '||lx_message_list,1,1800);
      RAISE e_error;
    END IF;
  ELSE  -- Es Una devolucion de produccion
    BEGIN
      SELECT max(mmt.transaction_id)
        INTO l_orig_transaction_id
        FROM mtl_material_transactions mmt
       WHERE 1=1
         AND transaction_type_id = 44
         AND transaction_source_id = l_batch_id
         AND transaction_reference = substr(p_lpn_nbr,4);
    EXCEPTION
      WHEN OTHERS THEN
        x_error_mesg := 'Error al buscar Transaccion de Declaracion '||l_batch_id||', '||p_lpn_nbr||'. '||sqlerrm;
        RAISE e_error;
    END;
    xx_debug_pk.debug(l_calling_sequence||', l_orig_transaction_id ='||l_orig_transaction_id,1);
    xx_debug_pk.debug(l_calling_sequence||', p_trx_quantity ='||p_trx_quantity,1);
    IF p_trx_quantity > 0 THEN
      BEGIN
        SELECT mmt.transaction_source_id
              ,mmt.organization_id
              ,mmt.subinventory_code
              ,mmt.locator_id
              ,mmt.inventory_item_id
              ,mmt.trx_source_line_id
              ,mmt.transaction_source_id
              ,mmt.trx_source_line_id
              ,inv_convert.inv_um_convert (mmt.inventory_item_id    --Inventory Item Id
                                          ,NULL                     --Precision
                                          ,NVL (p_trx_quantity, 0)  --Quantity
                                          ,p_trx_uom                --From UOM
                                          ,mmt.transaction_uom      --To UOM
                                          ,NULL                     --From UOM Name
                                          ,NULL                     --To UOM Name
                                          ) transaction_quantity
              ,mmt.transaction_uom
              ,'OPM'
              ,mmt.TRANSACTION_SOURCE_TYPE_ID
              ,10
              ,mmt.TRANSACTION_ACTION_ID
              ,mmt.TRANSACTION_TYPE_ID
              ,SYSDATE
              ,mmt.TRANSACTION_REFERENCE
              ,SYSDATE
              ,fnd_global.user_id
              ,SYSDATE
              ,fnd_global.user_id
              ,fnd_global.login_id
          INTO l_mmti_rec.transaction_source_id
              ,l_mmti_rec.organization_id
              ,l_mmti_rec.subinventory_code
              ,l_mmti_rec.locator_id
              ,l_mmti_rec.inventory_item_id
              ,l_mmti_rec.source_header_id
              ,l_mmti_rec.transaction_source_id
              ,l_mmti_rec.trx_source_line_id
              ,l_mmti_rec.transaction_quantity
              ,l_mmti_rec.transaction_uom
              ,l_mmti_rec.source_code
              ,l_mmti_rec.TRANSACTION_SOURCE_TYPE_ID
              ,l_mmti_rec.wip_entity_type
              ,l_mmti_rec.TRANSACTION_ACTION_ID
              ,l_mmti_rec.TRANSACTION_TYPE_ID
              ,l_mmti_rec.TRANSACTION_DATE
              ,l_mmti_rec.TRANSACTION_REFERENCE
              ,l_mmti_rec.LAST_UPDATE_DATE
              ,l_mmti_rec.LAST_UPDATED_BY
              ,l_mmti_rec.CREATION_DATE
              ,l_mmti_rec.CREATED_BY
              ,l_mmti_rec.LAST_UPDATE_LOGIN
          FROM mtl_material_transactions mmt
         WHERE 1=1
           AND mmt.transaction_id = l_orig_transaction_id;
      EXCEPTION
        WHEN OTHERS THEN
          x_error_mesg := 'Error al buscar Transaccion '||l_orig_transaction_id||'. '||sqlerrm;
          RAISE e_error;
      END;
      ---------------------------------------Lot Details
      l_mmli_tbl(1).last_update_date       := gme_common_pvt.g_timestamp;
      l_mmli_tbl(1).last_updated_by        := gme_common_pvt.g_user_ident;
      l_mmli_tbl(1).creation_date          := gme_common_pvt.g_timestamp;
      l_mmli_tbl(1).created_by             := gme_common_pvt.g_user_ident;
      l_mmli_tbl(1).lot_number             := p_lot_number;
      l_mmli_tbl(1).transaction_quantity   := l_mmti_rec.transaction_quantity;
      ------------------------------------------------

      gme_api_pub.update_material_txn
                           (p_api_version              => 2.0,
                            p_validation_level         => gme_common_pvt.g_max_errors,
                            p_init_msg_list            => fnd_api.g_false,
                            p_commit                   => fnd_api.g_false,
                            x_message_count            => lx_message_count,
                            x_message_list             => lx_message_list,
                            x_return_status            => lx_return_status,
                            p_transaction_id           => l_orig_transaction_id,
                            p_mmti_rec                 => l_mmti_rec,
                            p_mmli_tbl                 => l_mmli_tbl,
                            p_create_lot               => NULL,
                            p_generate_lot             => NULL,
                            p_generate_parent_lot      => NULL,
                            x_mmt_rec                  => lx_mmt_rec,
                            x_mmln_tbl                 => lx_mmln_tbl );

      xx_debug_pk.debug(l_calling_sequence||', x_message_count ='||TO_CHAR(lx_message_count),1);
      xx_debug_pk.debug(l_calling_sequence||', lx_message_list ='||substr(lx_message_list,1,120),1);
      xx_debug_pk.debug(l_calling_sequence||', lx_return_status ='||lx_return_status,1);
      xx_debug_pk.debug(l_calling_sequence||', lx_mmt_rec.transaction_id ='||lx_mmt_rec.transaction_id,1);

      IF nvl(lx_message_count,0) >=1 THEN
        FOR I IN 1..lx_message_count LOOP
          xx_debug_pk.debug(l_calling_sequence||I||'. '||SUBSTR(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ),1, 255),1);
        END LOOP;
        x_error_mesg := substr('Error en gme_api_pub.update_material_txn: '||lx_message_list,1,1800);
        RAISE e_error;
      END IF;

    ELSE
      -- Se borra la declaracion de produccion
      gme_common_pvt.g_error_count := 0;
      gme_common_pvt.set_timestamp;
      gme_common_pvt.g_move_to_temp := fnd_api.g_false;
      xx_debug_pk.debug(l_calling_sequence||', delete_material_txn ='||l_orig_transaction_id,1);
      gme_api_pub.delete_material_txn
                              (p_api_version              => 2.0,
                               p_validation_level         => gme_common_pvt.g_max_errors,
                               p_init_msg_list            => fnd_api.g_false,
                               p_commit                   => fnd_api.g_false,
                               x_message_count            => lx_message_count,
                               x_message_list             => lx_message_list,
                               x_return_status            => lx_return_status,
                               p_transaction_id           => l_orig_transaction_id
                              );
      xx_debug_pk.debug(l_calling_sequence||', x_message_count ='||TO_CHAR(lx_message_count),1);
      xx_debug_pk.debug(l_calling_sequence||', lx_message_list ='||substr(lx_message_list,1,120),1);
      xx_debug_pk.debug(l_calling_sequence||', lx_return_status ='||lx_return_status,1);

      IF nvl(lx_message_count,0) >=1 THEN
        FOR I IN 1..lx_message_count LOOP
          xx_debug_pk.debug(l_calling_sequence||I||'. '||SUBSTR(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ),1, 255),1);
        END LOOP;
        x_error_mesg := substr('Error en gme_api_pub.delete_material_txn: '||lx_message_list,1,1800);
        RAISE e_error;
      ELSE
        -- Save Batch Procedure
        -- This procedure allows the user to save a batch.
        -- It is used to consolidate all the transactions from the temporary
        -- tables and write them to the main tables.
        gme_api_pub.save_batch (p_header_id => ''
                              , x_return_status => lx_return_status);

      END IF;

    END IF;
  END IF;

  xx_debug_pk.debug(l_calling_sequence||', Fin',1);

EXCEPTION
  WHEN e_error THEN
    xx_debug_pk.debug(l_calling_sequence||'. '||x_error_mesg,1);
  WHEN OTHERS THEN
    x_error_mesg := 'Error en '||l_calling_sequence||'. '||sqlerrm;
    xx_debug_pk.debug(l_calling_sequence||'. '||x_error_mesg,1);
END create_gme_trx;

PROCEDURE create_mtl_trx (p_inventory_item_id              IN NUMBER
                         ,p_organization_id                IN NUMBER
                         ,p_subinventory_code              IN VARCHAR2
                         ,p_locator_id                     IN NUMBER
                         ,p_transaction_type_id            IN NUMBER
                         ,p_transaction_action_id          IN NUMBER
                         ,p_transaction_source_type_id     IN NUMBER
                         ,p_transaction_source_id          IN NUMBER
                         ,p_reason_id                      IN NUMBER
                         ,p_transfer_organization_id       IN NUMBER
                         ,p_transfer_subinventory_code     IN VARCHAR2
                         ,p_transfer_locator_id            IN NUMBER
                         ,p_trx_quantity                   IN NUMBER
                         ,p_trx_uom                        IN VARCHAR2
                         ,p_lpn_nbr                        IN VARCHAR2
                         ,p_lot_number                     IN VARCHAR2
                         ,p_lot_exp                        IN VARCHAR2
                         ,x_error_mesg                    OUT VARCHAR2) IS

e_error                       EXCEPTION;
l_transaction_interface_id    NUMBER;
lx_trans_count                NUMBER;
lx_message_count              VARCHAR2(1000);
lx_message_list               VARCHAR2(10000);
lx_return_status              VARCHAR2(1000);
l_retcode                     VARCHAR2(100);


l_calling_sequence VARCHAR2(100):='xx_wms_int_in_trx_pk.create_mtl_trx';

BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  gme_common_pvt.g_error_count := 0;
  gme_common_pvt.set_timestamp;
  gme_common_pvt.g_move_to_temp := fnd_api.g_false;

  xx_debug_pk.debug(l_calling_sequence||', lot_exp: '||to_date(p_lot_exp,'YYYYMMDD'),1);

  SELECT mtl_material_transactions_s.NEXTVAL
  INTO l_transaction_interface_id
  FROM DUAL;

  BEGIN
    INSERT INTO mtl_transactions_interface
               (source_code
               ,source_header_id
               ,source_line_id
               ,process_flag
               ,lock_flag
               ,transaction_mode
               ,last_update_date
               ,last_updated_by
               ,creation_date
               ,created_by
               ,organization_id
               ,inventory_item_id
               ,transaction_quantity
               ,transaction_uom
               ,transaction_date
               ,transaction_type_id
               ,transaction_action_id
               ,transaction_source_type_id
               ,transaction_source_id
               ,transaction_header_id
               ,transaction_interface_id
               ,subinventory_code
               ,locator_id
               ,transfer_organization
               ,transfer_subinventory
               ,transfer_locator
               ,reason_id
               ,transaction_reference
               )
        VALUES (
                'WMS'   --p_lpn_nbr    --source_code
               ,l_transaction_interface_id       --soure_header_id --> secuencia
               ,l_transaction_interface_id       --source_line_id   --> secuencia
               ,1       --process_flag
               ,2       --lock_flag
               ,3       --transaction_mode
               ,SYSDATE --l_up_date
               ,fnd_global.user_id     --l_up_by
               ,SYSDATE --c_date
               ,fnd_global.user_id     --c_by
               ,p_organization_id     --organization_id   -->MSS Organizacion donde se hizo la declaracion
               ,p_inventory_item_id   --inventory_item_id    --> item que se declaro
               ,p_trx_quantity        --transaction_quantity --> cantidad declarada
               ,p_trx_uom             --transaction_uom      --> UOM declaracion
               ,SYSDATE               --transaction_date     --> sysdate
               ,p_transaction_type_id --transaction_type_id
               ,p_transaction_action_id --transaction_action_id
               ,p_transaction_source_type_id   --transaction_source_type_id
               ,p_transaction_source_id        --transaction_source_id
               ,l_transaction_interface_id     --transaction_header_id
               ,l_transaction_interface_id     --transaction_interface_id --> secuencia
               ,p_subinventory_code            --subinventory_code        --> subinventario donde se declaro
               ,p_locator_id                   --locator_id             --> localizador donde se declaro
               ,p_transfer_organization_id   --transfer_organization   --> lookup xx_mapero_ebs_wms --> ddff org_transfer_prod
               ,p_transfer_subinventory_code    --transfer_subinventory   --> lookup xx_mapero_ebs_wms --> ddff sub_transfer_prod
               ,p_transfer_locator_id           --transfer_locator        --> mismo localizador de origen pero en el org de destino
               ,p_reason_id           --reason_id --
               ,substr(p_lpn_nbr,4)    --'WMS_DECLARION_PROD'      --transaction_reference
               );
  EXCEPTION
    WHEN OTHERS THEN
      x_error_mesg := 'Error al insertar en mtl_transactions_interface: '||sqlerrm;
      RAISE e_error;
  END;

  BEGIN
    INSERT INTO mtl_transaction_lots_interface (
                   transaction_interface_id
                  ,source_code
                  ,source_line_id
                  ,lot_number
                  ,transaction_quantity
                  ,process_flag
                  ,created_by
                  ,creation_date
                  ,last_updated_by
                  ,last_update_date)
           VALUES (
                   l_transaction_interface_id     --secuencia
                  ,p_lpn_nbr                      --source_code,              --lpn_nbr
                  ,l_transaction_interface_id     --source_line_id, --secuencia
                  ,p_lot_number                   --lote que se hizo la declaracion
                  ,p_trx_quantity                 --cantidad declaracion
                  ,1                              --process_flag
                  ,fnd_global.user_id             --created_by
                  ,SYSDATE                        --creation_date
                  ,fnd_global.user_id             --last_updated_by
                  ,SYSDATE                        --last_update_date
                  );


  EXCEPTION
    WHEN OTHERS THEN
      x_error_mesg := 'Error al insertar en mtl_transaction_lots_interface: '||sqlerrm;
      RAISE e_error;
  END;
  l_retcode := INV_TXN_MANAGER_PUB.process_transactions (
                            p_api_version     => 1.0,
                            p_init_msg_list   => fnd_api.g_true,
                            x_return_status   => lx_return_status,
                            x_msg_count       => lx_message_count,
                            x_msg_data        => lx_message_list,
                            x_trans_count     => lx_trans_count,
                            p_header_id       => l_transaction_interface_id);
     --COMMIT;
  xx_debug_pk.debug(l_calling_sequence||', l_retcode ='||l_retcode,1);
  xx_debug_pk.debug(l_calling_sequence||', x_message_count ='||TO_CHAR(lx_message_count),1);
  xx_debug_pk.debug(l_calling_sequence||', lx_message_list ='||substr(lx_message_list,1,120),1);
  xx_debug_pk.debug(l_calling_sequence||', lx_return_status ='||lx_return_status,1);
  xx_debug_pk.debug(l_calling_sequence||', lx_trans_count ='||lx_trans_count,1);

  IF nvl(lx_message_count,0) >=1 THEN
    FOR I IN 1..lx_message_count LOOP
      xx_debug_pk.debug(l_calling_sequence||I||'. '||SUBSTR(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ),1, 255),1);
    END LOOP;
  END IF;
  IF (nvl(lx_message_count,0) = 0 AND lx_message_list IS NULL AND lx_return_status = 'S') THEN
    NULL;
    --COMMIT;
  ELSE
    IF lx_message_list is not null THEN
      x_error_mesg := 'Error en INV_TXN_MANAGER_PUB.process_transactions: '||substr(lx_message_list,1,120);
    ELSE
      BEGIN
        SELECT mti.error_explanation||'. '||mti.error_code
          INTO x_error_mesg
          FROM mtl_transactions_interface mti
         WHERE mti.transaction_interface_id = l_transaction_interface_id;
      EXCEPTION
        WHEN OTHERS THEN
          x_error_mesg := 'Error buscando errores en mtl_transactions_interface: '||sqlerrm;
      END;
    END IF;
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', Fin',1);

EXCEPTION
  WHEN e_error THEN
    xx_debug_pk.debug(l_calling_sequence||'. '||x_error_mesg,1);
  WHEN OTHERS THEN
    x_error_mesg := 'Error en '||l_calling_sequence||'. '||sqlerrm;
    xx_debug_pk.debug(l_calling_sequence||'. '||x_error_mesg,1);
END create_mtl_trx;


PROCEDURE product_declaration
(p_inv_history_rec           IN  xx_wms_int_in_pk.XX_WMS_INV_HISTORY_REC
,x_msg_data                  OUT VARCHAR2
) AS

e_error                 EXCEPTION;
l_user_id                        NUMBER;
l_resp_id                        NUMBER;
l_appl_id                        NUMBER;
l_organization_id                NUMBER;
l_transfer_organization_id       NUMBER;
l_inventory_item_id              NUMBER;
l_locator_id                     NUMBER;
l_transfer_locator_id            NUMBER;
l_reason_id                      NUMBER;
l_org_code                       VARCHAR2(30);
l_transfer_org_code              VARCHAR2(30);
l_subinventory_code              VARCHAR2(30);
l_transfer_subinventory_code     VARCHAR2(30);
l_locator_code                   VARCHAR2(100);
l_uom_code                       VARCHAR2(30);
l_calling_sequence               VARCHAR2(100):='xx_wms_int_in_trx_pk.product_declaration';
BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  l_user_id := fnd_profile.value('XX_WMS_INTEGRATION_USER');
  l_resp_id := fnd_profile.value('XX_WMS_INTEGRATION_RESPO_OPM');
  IF l_user_id IS NULL THEN
    x_msg_data := 'No se encuentra configurada la opcion de perfil XX WMS Usuario Integracion';
    RAISE e_error;
  END IF;
  IF l_resp_id IS NULL THEN
    x_msg_data := 'No se encuentra configurada la opcion de perfil XX WMS Responsabilidad OPM Integracion';
    RAISE e_error;
  END IF;
  BEGIN
    SELECT application_id
      INTO l_appl_id
      FROM fnd_responsibility
     WHERE responsibility_id = l_resp_id;
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al obtener applicacion para la responsibility_id: '||l_resp_id||'. '||sqlerrm;
      RAISE e_error;
  END;
  fnd_profile.initialize (l_user_id);
  fnd_global.apps_initialize(user_id =>l_user_id
                            ,resp_id =>l_resp_id
                            ,resp_appl_id =>l_appl_id );

  -- Obtener Organizacion de Declaracion de Produccion
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.facility_code : '||p_inv_history_rec.facility_code,1);
  get_organization_id(p_inv_history_rec.facility_code, 'ORG_DECLARACION_PROD',l_organization_id ,l_org_code,x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_organization_id: '||l_organization_id,1);

  -- Obtener Organizacion de Transferecia de Produccion
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.facility_code : '||p_inv_history_rec.facility_code,1);
  get_organization_id(p_inv_history_rec.facility_code, 'ORG_TRANSFER_PROD',l_transfer_organization_id ,l_transfer_org_code,x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_transfer_organization_id: '||l_transfer_organization_id,1);


  -- Obtener Item de Declaracion de Produccion
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.item_code : '||p_inv_history_rec.item_code,1);
  get_item_id(p_inv_history_rec.item_code, l_organization_id ,l_inventory_item_id, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_inventory_item_id: '||l_inventory_item_id,1);

  -- Obtener Subinventory de Declaracion de Produccion
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.facility_code : '||p_inv_history_rec.facility_code,1);
  get_subinventory_code(p_inv_history_rec.facility_code, 'SUBINV_DECLARACION_PROD',l_subinventory_code, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_subinventory_code: '||l_subinventory_code,1);

  -- Obtener Subinventory de Transferencia de Produccion
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.facility_code : '||p_inv_history_rec.facility_code,1);
  get_subinventory_code(p_inv_history_rec.facility_code, 'SUBINV_TRANSFER_PROD',l_transfer_subinventory_code, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_transfer_subinventory_code: '||l_transfer_subinventory_code,1);

  -- Obtener Localizador de Declaracion de Produccion
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.lock_code : '||p_inv_history_rec.lock_code,1);
  get_locator_id(l_org_code, p_inv_history_rec.lock_code, l_locator_code, l_locator_id, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_locator_id: '||l_locator_id,1);

  -- Obtener Localizador de Transferencia de Produccion
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.lock_code : '||p_inv_history_rec.lock_code,1);
  get_locator_id(l_transfer_org_code, p_inv_history_rec.lock_code, l_locator_code, l_transfer_locator_id, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_transfer_locator_id: '||l_transfer_locator_id,1);

  -- Obtener UOM para Declaracion de Produccion
  get_item_uom(l_inventory_item_id, 'DUN14', l_organization_id, l_uom_code, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_uom_code: '||l_uom_code,1);
  xx_debug_pk.debug(l_calling_sequence||', l_inventory_item_id: '||l_inventory_item_id,1);

  create_gme_trx (p_shipment_nbr          => p_inv_history_rec.shipment_nbr
                 ,p_inventory_item_id     => l_inventory_item_id
                 ,p_organization_id       => l_organization_id
                 ,p_subinventory_code     => l_subinventory_code
                 ,p_locator_id            => l_locator_id
                 ,p_trx_quantity          => p_inv_history_rec.units_received
                 ,p_trx_uom               => l_uom_code
                 ,p_lpn_nbr               => p_inv_history_rec.lpn_nbr
                 ,p_lot_number            => p_inv_history_rec.ref_value_3
                 ,p_create_ts             => p_inv_history_rec.create_ts
                 ,p_transaction_type      => 'WIP Completion'
                 ,x_error_mesg            => x_msg_data);

  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;

  -- Obtener reason_id
  get_reason_id('TRNI', l_reason_id, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_reason_id: '||l_reason_id,1);

  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.ref_value_4: '||p_inv_history_rec.ref_value_4,1);
  create_mtl_trx (p_inventory_item_id              => l_inventory_item_id
                 ,p_organization_id                => l_organization_id
                 ,p_subinventory_code              => l_subinventory_code
                 ,p_locator_id                     => l_locator_id
                 ,p_transaction_type_id            => 141   -- Transf Organizaciones
                 ,p_transaction_action_id          => 3
                 ,p_transaction_source_type_id     => 13
                 ,p_transaction_source_id          => ''
                 ,p_reason_id                      => l_reason_id
                 ,p_transfer_organization_id       => l_transfer_organization_id
                 ,p_transfer_subinventory_code     => l_transfer_subinventory_code
                 ,p_transfer_locator_id            => l_transfer_locator_id
                 ,p_trx_quantity                   => p_inv_history_rec.units_received
                 ,p_trx_uom                        => l_uom_code
                 ,p_lpn_nbr                        => p_inv_history_rec.lpn_nbr
                 ,p_lot_number                     => p_inv_history_rec.ref_value_3
                 ,p_lot_exp                        => p_inv_history_rec.ref_value_4
                 ,x_error_mesg                     => x_msg_data);

  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  COMMIT;

  xx_debug_pk.debug(l_calling_sequence||', Fin',1);

EXCEPTION
  WHEN e_error THEN
    NULL;
  WHEN OTHERS THEN
    x_msg_data := 'Error: '||sqlerrm;
    xx_debug_pk.debug(l_calling_sequence||', error : '||x_msg_data,1);
END product_declaration;

PROCEDURE stock_adjustment
(p_inv_history_rec           IN  xx_wms_int_in_pk.XX_WMS_INV_HISTORY_REC
,x_msg_data                  OUT VARCHAR2
) AS

e_error                 EXCEPTION;
l_user_id                        NUMBER;
l_resp_id                        NUMBER;
l_appl_id                        NUMBER;
l_organization_id                NUMBER;
l_transfer_organization_id       NUMBER;
l_trx_organization_id            NUMBER;
l_trf_organization_id            NUMBER;
l_inventory_item_id              NUMBER;
l_locator_id                     NUMBER;
l_transfer_locator_id            NUMBER;
l_trx_locator_id                 NUMBER;
l_trf_locator_id                 NUMBER;
l_transaction_type_id            NUMBER;
l_trx_quantity                   NUMBER;
l_transaction_action_id          NUMBER;
l_transaction_source_type_id     NUMBER;
l_transaction_source_id          NUMBER;
l_reason_id                      NUMBER;
l_batch_id                       NUMBER;
l_trx_source_line_id             NUMBER;
l_org_code                       VARCHAR2(30);
l_transfer_org_code              VARCHAR2(30);
l_subinventory_code              VARCHAR2(30);
l_transfer_subinventory_code     VARCHAR2(30);
l_trx_subinventory_code          VARCHAR2(30);
l_trf_subinventory_code          VARCHAR2(30);
l_locator_code                   VARCHAR2(100);
l_uom_code                       VARCHAR2(30);
l_trx_type_name                  VARCHAR2(30);
l_trx_alias                      VARCHAR2(30);
l_calling_sequence               VARCHAR2(100):='xx_wms_int_in_trx_pk.stock_adjustment';
BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  l_user_id := fnd_profile.value('XX_WMS_INTEGRATION_USER');
  l_resp_id := fnd_profile.value('XX_WMS_INTEGRATION_RESPO_OPM');
  IF l_user_id IS NULL THEN
    x_msg_data := 'No se encuentra configurada la opcion de perfil XX WMS Usuario Integracion';
    RAISE e_error;
  END IF;
  IF l_resp_id IS NULL THEN
    x_msg_data := 'No se encuentra configurada la opcion de perfil XX WMS Responsabilidad OPM Integracion';
    RAISE e_error;
  END IF;

  BEGIN
    SELECT application_id
      INTO l_appl_id
      FROM fnd_responsibility
     WHERE responsibility_id = l_resp_id;
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al obtener applicacion para la responsibility_id: '||l_resp_id||'. '||sqlerrm;
      RAISE e_error;
  END;
  fnd_profile.initialize (l_user_id);
  fnd_global.apps_initialize(user_id =>l_user_id
                            ,resp_id =>l_resp_id
                            ,resp_appl_id =>l_appl_id );

  -- Obtener Organizacion de Declaracion de Produccion
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.facility_code : '||p_inv_history_rec.facility_code,1);
  get_organization_id(p_inv_history_rec.facility_code, 'ORG_DECLARACION_PROD',l_organization_id ,l_org_code,x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_organization_id: '||l_organization_id,1);

  -- Obtener Subinventory de Declaracion de Produccion
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.facility_code : '||p_inv_history_rec.facility_code,1);
  get_subinventory_code(p_inv_history_rec.facility_code, 'SUBINV_DECLARACION_PROD',l_subinventory_code, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_subinventory_code: '||l_subinventory_code,1);

  -- Obtener Localizador de Declaracion de Produccion
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.lock_code : '||p_inv_history_rec.lock_code,1);
  get_locator_id(l_org_code, p_inv_history_rec.lock_code, l_locator_code, l_locator_id, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_locator_id: '||l_locator_id,1);

  -- Obtener Organizacion de Transferecia de Produccion
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.facility_code : '||p_inv_history_rec.facility_code,1);
  get_organization_id(p_inv_history_rec.facility_code, 'ORG_TRANSFER_PROD',l_transfer_organization_id ,l_transfer_org_code,x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_transfer_organization_id: '||l_transfer_organization_id,1);


  -- Obtener Item de Ajuste
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.item_code : '||p_inv_history_rec.item_code,1);
  get_item_id(p_inv_history_rec.item_code, l_organization_id ,l_inventory_item_id, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_inventory_item_id: '||l_inventory_item_id,1);

  -- Obtener Subinventory de Transferencia de Produccion
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.facility_code : '||p_inv_history_rec.facility_code,1);
  get_subinventory_code(p_inv_history_rec.facility_code, 'SUBINV_TRANSFER_PROD',l_transfer_subinventory_code, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_transfer_subinventory_code: '||l_transfer_subinventory_code,1);

  -- Obtener Localizador de Transferencia de Produccion
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.lock_code : '||p_inv_history_rec.lock_code,1);
  get_locator_id(l_transfer_org_code, p_inv_history_rec.lock_code, l_locator_code, l_transfer_locator_id, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_transfer_locator_id: '||l_transfer_locator_id,1);

  -- Obtener UOM para Declaracion de Produccion
  get_item_uom(l_inventory_item_id, 'DUN14', l_organization_id, l_uom_code, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;

  xx_debug_pk.debug(l_calling_sequence||', l_inventory_item_id: '||l_inventory_item_id,1);

  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.ref_value_4: '||p_inv_history_rec.ref_value_4,1);
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.adj_qty: '||p_inv_history_rec.adj_qty,1);
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.activity_code: '||p_inv_history_rec.activity_code,1);

  -------------------------------------------------------------------------
  -- Si REASON_CODE =
  --   REPROCESO -- transferencia de DSS a MSS (x adj_qty) "Transf Organizaciones" tt_id = 141
  --   DEV_PROD  -- trx de "WIP Return" tt_id 43 + transferencia de DSS a MSS (x adj_qty) "Transf Organizaciones" tt_id=141
  --   DECOMISO  -- hay que hacer una baja en DSS, "Baja Industria", la saco del ddff, ahora consulto el reason a utilizar porque no encuentro uno para decomiso.
  --   QADJ      -- baja x calidad, hay que hacer una baja en DSS, "Baja Industria", la saco del ddff
  --   OTROS REASON -- si adj_qty < 0 --> hay que hacer una baja en DSS, "Baja Industria", la saco del ddff
  --                -- si adj_qty > 0 --> hay que hacer un alta en DSS, "Alta Industria", la saco del ddff
  -------------------------------------------------------------------------


  IF p_inv_history_rec.activity_code IN  (4, 17, 19, 39, 40, 53) AND
     p_inv_history_rec.reason_code IS NOT NULL THEN
    -- Obtener trx_alias
    get_trx_alias(l_transfer_org_code, l_trx_alias ,x_msg_data);

    IF x_msg_data IS NOT NULL THEN
      RAISE e_error;
    END IF;
    xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.reason_code: '||p_inv_history_rec.reason_code,1);
    IF p_inv_history_rec.reason_code in ('REPROCESO','DEV_PROD') THEN

      IF p_inv_history_rec.reason_code = 'REPROCESO' THEN
        IF p_inv_history_rec.adj_qty > 0 THEN
          x_msg_data := 'Ajuste por REPROCESO es positivo en WMS';
          RAISE e_error;
        ELSE
          l_trx_quantity              := abs(p_inv_history_rec.adj_qty);
        END IF;  
      ELSIF p_inv_history_rec.reason_code = 'DEV_PROD' THEN
        l_trx_quantity                := p_inv_history_rec.orig_qty;
      END IF;

      l_trx_type_name               := 'Transf Organizaciones'; --Transferencia desde DSS a MSS
      l_trx_organization_id         := l_transfer_organization_id;
      l_trx_subinventory_code       := l_transfer_subinventory_code;
      l_trx_locator_id              := l_transfer_locator_id;
      l_trf_organization_id         := l_organization_id;
      l_trf_subinventory_code       := l_subinventory_code;
      l_trf_locator_id              := l_locator_id;
      l_trx_alias                   := '';  -- No es account alias trx
      -- Obtener reason_id
      get_reason_id('TRNI', l_reason_id, x_msg_data);
      IF x_msg_data IS NOT NULL THEN
        RAISE e_error;
      END IF;
      xx_debug_pk.debug(l_calling_sequence||', l_reason_id: '||l_reason_id,1);
    ELSE

      xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.reason_code: '||p_inv_history_rec.reason_code,1);
      IF p_inv_history_rec.adj_qty > 0 THEN
        -- Obtener trx_type
        get_trx_type(p_inv_history_rec.facility_code, 'ALTA',l_trx_type_name ,x_msg_data);

        IF x_msg_data IS NOT NULL THEN
          RAISE e_error;
        END IF;

      ELSIF p_inv_history_rec.adj_qty < 0 THEN

        -- Obtener trx_type
        get_trx_type(p_inv_history_rec.facility_code, 'BAJA',l_trx_type_name ,x_msg_data);

        IF x_msg_data IS NOT NULL THEN
          RAISE e_error;
        END IF;
      END IF;

      l_trx_quantity                := p_inv_history_rec.adj_qty;
      l_trx_organization_id         := l_transfer_organization_id;
      l_trx_subinventory_code       := l_transfer_subinventory_code;
      l_trx_locator_id              := l_transfer_locator_id;
      -- Obtener reason_id
      get_reason_id(p_inv_history_rec.reason_code, l_reason_id, x_msg_data);
      IF x_msg_data IS NOT NULL THEN
        RAISE e_error;
      END IF;
      xx_debug_pk.debug(l_calling_sequence||', l_reason_id: '||l_reason_id,1);

    END IF;
    xx_debug_pk.debug(l_calling_sequence||', l_trx_type_name: '||l_trx_type_name,1);
    BEGIN
      SELECT mtt.transaction_type_id
            ,mtt.transaction_action_id
            ,mtt.transaction_source_type_id
        INTO l_transaction_type_id
            ,l_transaction_action_id
            ,l_transaction_source_type_id
        FROM mtl_transaction_types mtt
       WHERE mtt.transaction_type_name = l_trx_type_name;
    EXCEPTION
      WHEN OTHERS THEN
        x_msg_data := 'Error al buscar tipo de transaccion: '||l_trx_type_name||'. '||sqlerrm;
        RAISE e_error;
    END;
    xx_debug_pk.debug(l_calling_sequence||', l_transaction_type_id: '||l_transaction_type_id,1);
    xx_debug_pk.debug(l_calling_sequence||', l_trx_alias: '||l_trx_alias,1);
    IF l_trx_alias IS NOT NULL THEN
      BEGIN
        SELECT mgd.disposition_id
          INTO l_transaction_source_id
          FROM mtl_generic_dispositions mgd
           WHERE mgd.segment1        = l_trx_alias
           AND mgd.organization_id = l_trx_organization_id;
      EXCEPTION
        WHEN OTHERS THEN
          x_msg_data := 'Error al buscar alias: '||l_trx_alias||'. '||sqlerrm;
          RAISE e_error;
      END;
    END IF;


    xx_debug_pk.debug(l_calling_sequence||', Antes create_mtl_trx     ',1);
    xx_debug_pk.debug(l_calling_sequence||', ------------------------------------------',1);
    xx_debug_pk.debug(l_calling_sequence||', l_inventory_item_id: '||l_inventory_item_id,1);
    xx_debug_pk.debug(l_calling_sequence||', l_trx_organization_id: '||l_trx_organization_id,1);
    xx_debug_pk.debug(l_calling_sequence||', l_trx_subinventory_code: '||l_trx_subinventory_code,1);
    xx_debug_pk.debug(l_calling_sequence||', l_trx_locator_id: '||l_trx_locator_id,1);
    xx_debug_pk.debug(l_calling_sequence||', l_trf_organization_id: '||l_trf_organization_id,1);
    xx_debug_pk.debug(l_calling_sequence||', l_trf_subinventory_code: '||l_trf_subinventory_code,1);
    xx_debug_pk.debug(l_calling_sequence||', l_trf_locator_id: '||l_trf_locator_id,1);
    xx_debug_pk.debug(l_calling_sequence||', l_transaction_type_id: '||l_transaction_type_id,1);
    xx_debug_pk.debug(l_calling_sequence||', l_transaction_action_id: '||l_transaction_action_id,1);
    xx_debug_pk.debug(l_calling_sequence||', l_transaction_source_type_id: '||l_transaction_source_type_id,1);
    xx_debug_pk.debug(l_calling_sequence||', l_transaction_source_id: '||l_transaction_source_id,1);
    xx_debug_pk.debug(l_calling_sequence||', l_reason_id: '||l_reason_id,1);
    xx_debug_pk.debug(l_calling_sequence||', l_trx_quantity: '||l_trx_quantity,1);
    xx_debug_pk.debug(l_calling_sequence||', l_uom_code: '||l_uom_code,1);
    xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.lpn_nbr: '||p_inv_history_rec.lpn_nbr,1);
    xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.ref_value_1: '||p_inv_history_rec.ref_value_1,1);
    xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.ref_value_2: '||p_inv_history_rec.ref_value_2,1);
    xx_debug_pk.debug(l_calling_sequence||', ------------------------------------------',1);
    create_mtl_trx (p_inventory_item_id              => l_inventory_item_id
                   ,p_organization_id                => l_trx_organization_id
                   ,p_subinventory_code              => l_trx_subinventory_code
                   ,p_locator_id                     => l_trx_locator_id
                   ,p_transfer_organization_id       => l_trf_organization_id
                   ,p_transfer_subinventory_code     => l_trf_subinventory_code
                   ,p_transfer_locator_id            => l_trf_locator_id
                   ,p_transaction_type_id            => l_transaction_type_id
                   ,p_transaction_action_id          => l_transaction_action_id
                   ,p_transaction_source_type_id     => l_transaction_source_type_id
                   ,p_transaction_source_id          => l_transaction_source_id
                   ,p_reason_id                      => l_reason_id
                   ,p_trx_quantity                   => l_trx_quantity
                   ,p_trx_uom                        => l_uom_code
                   ,p_lpn_nbr                        => p_inv_history_rec.lpn_nbr
                   ,p_lot_number                     => p_inv_history_rec.ref_value_1
                   ,p_lot_exp                        => p_inv_history_rec.ref_value_2
                   ,x_error_mesg                     => x_msg_data);

    IF x_msg_data IS NOT NULL THEN
      RAISE e_error;
    END IF;
    IF p_inv_history_rec.reason_code = 'DEV_PROD' THEN
      xx_debug_pk.debug(l_calling_sequence||', reason_code DEV_PROD generar Wip Return ',1);
      -- Ademas de la transferencia hay que hacer el wip return
      -- Wip Return por la cantidad original
      -- Wip Completion por la diferencia de la cantidad ajustada
      -- Transferencia entre organizacion de la nueva cantidad declarada


      l_trx_quantity                := p_inv_history_rec.orig_qty + p_inv_history_rec.adj_qty;
      l_trx_organization_id         := l_organization_id;
      l_trx_subinventory_code       := l_subinventory_code;
      l_trx_locator_id              := l_locator_id;

      xx_debug_pk.debug(l_calling_sequence||', WIP Completion Return: '||l_trx_quantity,1);

      create_gme_trx (p_shipment_nbr          => p_inv_history_rec.shipment_nbr
                     ,p_inventory_item_id     => l_inventory_item_id
                     ,p_organization_id       => l_trx_organization_id
                     ,p_subinventory_code     => l_trx_subinventory_code
                     ,p_locator_id            => l_trx_locator_id
                     ,p_trx_quantity          => l_trx_quantity
                     ,p_trx_uom               => l_uom_code
                     ,p_lpn_nbr               => p_inv_history_rec.lpn_nbr
                     ,p_lot_number            => p_inv_history_rec.ref_value_1
                     ,p_create_ts             => p_inv_history_rec.create_ts
                     ,p_transaction_type      => 'WIP Completion Return'
                     ,x_error_mesg            => x_msg_data);

      xx_debug_pk.debug(l_calling_sequence||', x_msg_data: '||x_msg_data,1);
      IF x_msg_data IS NOT NULL THEN
        RAISE e_error;
      END IF;

      IF l_trx_quantity > 0 THEN
        -- Luego de hacer el ajuste de la cantidad se hace la transferencia
        -- Obtener reason_id
        get_reason_id('TRNI', l_reason_id, x_msg_data);
        IF x_msg_data IS NOT NULL THEN
          RAISE e_error;
        END IF;
        xx_debug_pk.debug(l_calling_sequence||', l_reason_id: '||l_reason_id,1);

        xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.ref_value_4: '||p_inv_history_rec.ref_value_4,1);
        create_mtl_trx (p_inventory_item_id              => l_inventory_item_id
                       ,p_organization_id                => l_organization_id
                       ,p_subinventory_code              => l_subinventory_code
                       ,p_locator_id                     => l_locator_id
                       ,p_transaction_type_id            => 141   -- Transf Organizaciones
                       ,p_transaction_action_id          => 3
                       ,p_transaction_source_type_id     => 13
                       ,p_transaction_source_id          => ''
                       ,p_reason_id                      => l_reason_id
                       ,p_transfer_organization_id       => l_transfer_organization_id
                       ,p_transfer_subinventory_code     => l_transfer_subinventory_code
                       ,p_transfer_locator_id            => l_transfer_locator_id
                       ,p_trx_quantity                   => l_trx_quantity
                       ,p_trx_uom                        => l_uom_code
                       ,p_lpn_nbr                        => p_inv_history_rec.lpn_nbr
                       ,p_lot_number                     => p_inv_history_rec.ref_value_1
                       ,p_lot_exp                        => p_inv_history_rec.ref_value_2
                       ,x_error_mesg                     => x_msg_data);

        IF x_msg_data IS NOT NULL THEN
          RAISE e_error;
        END IF;

      END IF;
    END IF;
  END IF;
  COMMIT;

  xx_debug_pk.debug(l_calling_sequence||', Fin',1);

EXCEPTION
  WHEN e_error THEN
    NULL;
  WHEN OTHERS THEN
    x_msg_data := 'Error: '||sqlerrm;
    xx_debug_pk.debug(l_calling_sequence||', error : '||x_msg_data,1);
END stock_adjustment;

PROCEDURE update_lot_status(p_organization_id    IN NUMBER
                           ,p_inventory_item_id  IN NUMBER
                           ,p_locator_id         IN NUMBER
                           ,p_org_code           IN VARCHAR2
                           ,p_locator_code       IN VARCHAR2
                           ,p_lot_number         IN VARCHAR2
                           ,x_error_mesg        OUT VARCHAR2) IS

l_calling_sequence VARCHAR2(100):='xx_wms_int_in_trx_pk.update_lot_status';
l_api_version      NUMBER       := 1.0; 
l_init_msg_list	   VARCHAR2(2)  := FND_API.G_TRUE; 
l_commit           VARCHAR2(2)  := FND_API.G_FALSE; 
x_return_status	   VARCHAR2(2);
x_msg_count        NUMBER       := 0;
x_msg_data         VARCHAR2(255);
-- API specific declarations
l_object_type      VARCHAR2 (20) ; 
l_status_code      VARCHAR2 (30) ; 
l_status_id        NUMBER;                 
l_actual_status_id NUMBER;                 
l_reason_id        NUMBER;                 
l_status_rec       INV_MATERIAL_STATUS_PUB.mtl_status_update_rec_type ;      
e_error            EXCEPTION;

BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);

  BEGIN
    SELECT distinct tag
      INTO l_status_code
      FROM fnd_lookup_values_vl flv
          ,fnd_lookup_values_dfv flv_d
     WHERE flv.lookup_type             = 'XX_EBS_WMS_ESTADOS'
       AND substr(flv.lookup_code,1,3) = p_org_code
       AND flv_d.XX_LOCALIZADOR_ESTADO = p_locator_code
       AND flv.rowid                   = flv_d.row_id;  
  EXCEPTION
    WHEN OTHERS THEN
      x_error_mesg := 'Error al buscar estado de bloqueo: '||p_locator_code||'. '||sqlerrm;
      RAISE e_error;
  END;
  xx_debug_pk.debug(l_calling_sequence||', l_status_code: '||l_status_code,1);

  BEGIN
    SELECT status_id
      INTO l_status_id
      FROM mtl_material_statuses_vl mms
     WHERE mms.status_code = l_status_code;            
  EXCEPTION
    WHEN OTHERS THEN
      x_error_mesg := 'Error al buscar el status_id para estado: '||l_status_code||'. '||sqlerrm;
      RAISE e_error;
  END;
  xx_debug_pk.debug(l_calling_sequence||', l_status_id: '||l_status_id,1);
  get_reason_id('QADJ', l_reason_id, x_error_mesg);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_reason_id: '||l_reason_id,1);

  BEGIN
    SELECT distinct moqd.status_id
      INTO l_actual_status_id
      FROM mtl_onhand_quantities_detail moqd
     WHERE moqd.organization_id   = p_organization_id
       AND moqd.locator_id        = p_locator_id
       AND moqd.inventory_item_id = p_inventory_item_id
       AND moqd.lot_number        = p_lot_number;
  EXCEPTION
    WHEN OTHERS THEN
      x_error_mesg := 'Error al buscar el status_id en onhand: '||p_lot_number||'. '||sqlerrm;
      RAISE e_error;
  END;
  xx_debug_pk.debug(l_calling_sequence||', l_actual_status_id: '||l_actual_status_id,1);

  IF l_status_id != l_actual_status_id THEN

    l_object_type                      := 'H';   -- 'O' = Lot , 'S' = Serial, 'Z' = Subinventory, 'L' = Locator, 'H' = Onhand
    l_status_rec.organization_id       := p_organization_id;
    l_status_rec.inventory_item_id     := p_inventory_item_id;
    l_status_rec.lot_number            := p_lot_number; 
    l_status_rec.zone_code             := NULL;
    l_status_rec.locator_id            := p_locator_id;
    l_status_rec.status_id             := l_status_id; -- select status_id, status_code from mtl_material_statuses_vl;
    l_status_rec.update_reason_id      := l_reason_id;  -- select reason_id, reason_name from mtl_transaction_reasons where reason_type_display = 'Update Status';
    l_status_rec.update_method         := 2;

    INV_MATERIAL_STATUS_PUB.update_status
      (  p_api_version_number   =>    l_api_version
       , p_init_msg_lst         =>    l_init_msg_list      
       , p_commit               =>    l_commit            
       , x_return_status        =>    x_return_status     
       , x_msg_count            =>    x_msg_count         
       , x_msg_data             =>    x_msg_data          
       , p_object_type          =>    l_object_type       
       , p_status_rec           =>    l_status_rec        
      );
    xx_debug_pk.debug(l_calling_sequence||', Return Status: '||x_return_status);

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      xx_debug_pk.debug(l_calling_sequence||', Error Message :'||x_msg_data);
      x_error_mesg := x_msg_data;
    END IF;
  ELSE
    xx_debug_pk.debug(l_calling_sequence||', No hay cambio de estado');
  END IF;

  xx_debug_pk.debug(l_calling_sequence||', Fin',1);

EXCEPTION
  WHEN e_error THEN
    null;
  WHEN OTHERS THEN
    x_error_mesg := 'Error en '||l_calling_sequence||',p_inventory_item_id: '||p_inventory_item_id||': '||sqlerrm;
END update_lot_status;

PROCEDURE block_lot_lpn
(p_inv_history_rec           IN  xx_wms_int_in_pk.XX_WMS_INV_HISTORY_REC
,x_msg_data                  OUT VARCHAR2
) AS

e_error                 EXCEPTION;
l_user_id                        NUMBER;
l_resp_id                        NUMBER;
l_appl_id                        NUMBER;
l_transfer_organization_id       NUMBER;
l_trx_organization_id            NUMBER;
l_trf_organization_id            NUMBER;
l_inventory_item_id              NUMBER;
l_from_locator_id                NUMBER;
l_to_locator_id                  NUMBER;
l_trx_locator_id                 NUMBER;
l_trf_locator_id                 NUMBER;
l_trx_quantity                   NUMBER;
l_reason_id                      NUMBER;
l_transaction_type_id            NUMBER;
l_transaction_action_id          NUMBER;
l_transaction_source_type_id     NUMBER;
l_transaction_source_id          NUMBER;
l_org_code                       VARCHAR2(30);
l_transfer_org_code              VARCHAR2(30);
l_transfer_subinventory_code     VARCHAR2(30);
l_trx_subinventory_code          VARCHAR2(30);
l_trf_subinventory_code          VARCHAR2(30);
l_locator_code                   VARCHAR2(100);
l_to_locator_code                VARCHAR2(100);
l_prev_lock_code                 VARCHAR2(100);
l_uom_code                       VARCHAR2(30);
l_lot_number                     VARCHAR2(100);
l_lot_exp                        VARCHAR2(100);
l_trx_type_name                  VARCHAR2(100);
l_from_block_code                VARCHAR2(100);
l_sin_mapeo                      VARCHAR2(100);
l_calling_sequence               VARCHAR2(100):='xx_wms_int_in_trx_pk.block_lot_lpn';
BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  l_user_id := fnd_profile.value('XX_WMS_INTEGRATION_USER');
  l_resp_id := fnd_profile.value('XX_WMS_INTEGRATION_RESPO_OPM');

  IF l_user_id IS NULL THEN
    x_msg_data := 'No se encuentra configurada la opcion de perfil XX WMS Usuario Integracion';
    RAISE e_error;
  END IF;
  IF l_resp_id IS NULL THEN
    x_msg_data := 'No se encuentra configurada la opcion de perfil XX WMS Responsabilidad OPM Integracion';
    RAISE e_error;
  END IF;

  BEGIN
    SELECT application_id
      INTO l_appl_id
      FROM fnd_responsibility
     WHERE responsibility_id = l_resp_id;
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al obtener applicacion para la responsibility_id: '||l_resp_id||'. '||sqlerrm;
      RAISE e_error;
  END;
  fnd_profile.initialize (l_user_id);
  fnd_global.apps_initialize(user_id =>l_user_id
                            ,resp_id =>l_resp_id
                            ,resp_appl_id =>l_appl_id );

  -- Obtener Organizacion de Transferecia de Produccion
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.facility_code : '||p_inv_history_rec.facility_code,1);
  get_organization_id(p_inv_history_rec.facility_code, 'ORG_TRANSFER_PROD',l_transfer_organization_id ,l_transfer_org_code,x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_transfer_organization_id: '||l_transfer_organization_id,1);


  -- Obtener Item de Bloqueo/Desbloqueo
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.item_code : '||p_inv_history_rec.item_code,1);
  get_item_id(p_inv_history_rec.item_code, l_transfer_organization_id ,l_inventory_item_id, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_inventory_item_id: '||l_inventory_item_id,1);

  -- Obtener Subinventory de Transferencia de Produccion
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.facility_code : '||p_inv_history_rec.facility_code,1);
  get_subinventory_code(p_inv_history_rec.facility_code, 'SUBINV_TRANSFER_PROD',l_transfer_subinventory_code, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_transfer_subinventory_code: '||l_transfer_subinventory_code,1);

  -- Obtener Localizador a Bloque/Desbloqueo
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.lock_code : '||p_inv_history_rec.lock_code,1);
  get_locator_id(l_transfer_org_code, p_inv_history_rec.lock_code, l_to_locator_code, l_to_locator_id, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_to_locator_id: '||l_to_locator_id,1);

  -- Obtener UOM para Declaracion de Produccion
  get_item_uom(l_inventory_item_id, 'DUN14', l_transfer_organization_id, l_uom_code, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_uom_code: '||l_uom_code,1);
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.activity_code: '||p_inv_history_rec.activity_code,1);

  -------------------------------------------------------------------------
  -- Activity_code  in 22, 23 -- Bloqueo
  --     From (prev_lock_code)
  --      To  (lock_code)
  --
  -- Activity_code in 24 25 - DesBloqueo
  --   Si  SI LOCK_CODE = last_lock_code sino no tengo que hacer nada porque ya esta ahi
  --     From (lock_code)
  --      To  (ref_value_2)
  -- Activity_code  56 Bloqueo/desblq lote (No hace nada porque lo hace x lpn
  -------------------------------------------------------------------------

  -------------------------------------------------------------------------
  -- Modificacion 30-06-20:
  -- Si en REF_VALUE1 viene alg˙n cÛdigo de retenciÛn y 
  --    en  REF_VALUE2 NO hay cÛdigo de retenciÛn, 
  --    --> SI hace transferencia de subinventario de ret a apr.
  --
  -- Si en REF_VALUE1 viene alg˙n cÛdigo de retenciÛn y 
  --    en  REF_VALUE2 ya hay cÛdigo de retenciÛn, 
  --    --> NO se hace transferencia de subinventario porque el stock ya esta en ret.
  --
  -- Si en REF_VALUE1 NO viene ning˙n cÛdigo de retenciÛn y 
  --    en  REF_VALUE2 SI hay cÛdigo de retenciÛn, 
  --    --> SI se hace transferencia de subinventario porque el stock ya est· en ret.
  --
  -- Si en REF_VALUE1  NO viene alg˙n cÛdigo de retenciÛn y 
  --    en  REF_VALUE2 NO hay cÛdigo de retenciÛn, 
  --    --> NO se hace transferencia de subinventario porque el stock ya esta en apr.  
  -------------------------------------------------------------------------
  --IF p_inv_history_rec.activity_code in (22, 23, 24, 25) THEN
  IF p_inv_history_rec.activity_code in (22, 23, 24, 25) AND 
    ((nvl(p_inv_history_rec.ref_value_1,'NULO') LIKE '%RET_%' AND nvl(p_inv_history_rec.ref_value_2,'NULO') NOT LIKE '%RET_%') OR
     (nvl(p_inv_history_rec.ref_value_1,'NULO') NOT LIKE '%RET_%' AND nvl(p_inv_history_rec.ref_value_2,'NULO') LIKE '%RET_%') 
    ) THEN
     
    BEGIN
      SELECT xwii.lock_code
        INTO l_prev_lock_code
        FROM xx_wms_integration_in xwii
       WHERE xwii.lpn_nbr   = p_inv_history_rec.lpn_nbr
         AND xwii.item_code = p_inv_history_rec.item_code
         AND xwii.status = 'OK'
         AND xwii.activity_code NOT IN (24,25)
         AND xwii.message_id ||xwii.group_nbr||xwii.seq_nbr  =
             (SELECT max(xwii2.message_id||xwii2.group_nbr||xwii2.seq_nbr)
                FROM apps.xx_wms_integration_in xwii2
               WHERE xwii2.lpn_nbr =  p_inv_history_rec.lpn_nbr
                 AND xwii2.item_code = p_inv_history_rec.item_code
                 AND xwii2.activity_code NOT IN (24,25)
                 AND xwii2.status = 'OK');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_msg_data := 'LPN '||p_inv_history_rec.lpn_nbr||' no declarado';
        RAISE e_error;
      WHEN OTHERS THEN
        x_msg_data := 'Error al buscar lock_code anterior del LPN: '||p_inv_history_rec.lpn_nbr||
                      'Error: '||sqlerrm;
        RAISE e_error;
    END;
    l_from_block_code := substr(p_inv_history_rec.ref_value_1,instr(p_inv_history_rec.ref_value_1,';',-1)+1);
    xx_debug_pk.debug(l_calling_sequence||', l_from_block_code: '||l_from_block_code,1);

    BEGIN
      SELECT 'N'                      
        INTO l_sin_mapeo         
        FROM fnd_lookup_values_vl flv
            ,fnd_lookup_values_dfv flv_d
         WHERE FLV.LOOKUP_TYPE             = 'XX_EBS_WMS_ESTADOS'
           AND SUBSTR(FLV.LOOKUP_CODE,1,3) = l_transfer_org_code
           AND nvl(flv.description,'NULO') = l_from_block_code
           AND FLV.ROWID                   = FLV_D.ROW_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN l_sin_mapeo := 'Y';             
      WHEN OTHERS THEN
           x_msg_data := 'Error al buscar l_from_block_code: '||l_from_block_code||'. '||sqlerrm;
           RAISE e_error;
    END;

    xx_debug_pk.debug(l_calling_sequence||', l_sin_mapeo: '||l_sin_mapeo,1);
    IF p_inv_history_rec.activity_code in (22, 23) THEN
      -- Obtener Localizador desde Bloque/Desbloqueo
      xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.ref_value_1: : '||p_inv_history_rec.ref_value_1,1);
      IF l_sin_mapeo = 'N' THEN
        get_locator_id(l_transfer_org_code, substr(p_inv_history_rec.ref_value_1,instr(p_inv_history_rec.ref_value_1,';',-1)+1)
                     , l_locator_code, l_from_locator_id, x_msg_data);
      ELSE
        get_locator_id(l_transfer_org_code, substr(replace(p_inv_history_rec.ref_value_1,';'||l_from_block_code,'')
                                                  ,instr(replace(p_inv_history_rec.ref_value_1,';'||l_from_block_code,''),';',-1)+1)
                     , l_locator_code, l_from_locator_id, x_msg_data);
      END IF;
      IF x_msg_data IS NOT NULL THEN
        RAISE e_error;
      END IF;
      xx_debug_pk.debug(l_calling_sequence||', l_from_locator_id: '||l_from_locator_id,1);
    ELSIF p_inv_history_rec.activity_code in (24, 25)    THEN
      -- Obtener Localizador desde Desbloqueo
      xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.lock_code: '||p_inv_history_rec.lock_code,1);
      IF l_sin_mapeo = 'N' THEN
        get_locator_id(l_transfer_org_code, substr(p_inv_history_rec.ref_value_1,instr(p_inv_history_rec.ref_value_1,';',-1)+1)
                     , l_locator_code, l_from_locator_id, x_msg_data);
      ELSE
        get_locator_id(l_transfer_org_code, substr(replace(p_inv_history_rec.ref_value_1,';'||l_from_block_code,'')
                                                  ,instr(replace(p_inv_history_rec.ref_value_1,';'||l_from_block_code,''),';',-1)+1)
                     , l_locator_code, l_from_locator_id, x_msg_data);
      END IF;
      IF x_msg_data IS NOT NULL THEN
        RAISE e_error;
      END IF;
      xx_debug_pk.debug(l_calling_sequence||', l_from_locator_id: '||l_from_locator_id,1);

      -- Obtener Localizador hasta Desbloqueo
      xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.ref_value_2: '||p_inv_history_rec.ref_value_2,1);
      get_locator_id(l_transfer_org_code, substr(p_inv_history_rec.ref_value_2,instr(p_inv_history_rec.ref_value_2,';',-1)+1)
                   , l_to_locator_code, l_to_locator_id, x_msg_data);
      IF x_msg_data IS NOT NULL THEN
        RAISE e_error;
      END IF;
      xx_debug_pk.debug(l_calling_sequence||', l_to_locator_id: '||l_to_locator_id,1);

    END IF;

    -- Cuando es bloqueo/desbloqueo de LPN la cantidad viene informada
    l_trx_quantity                := p_inv_history_rec.orig_qty;
    l_lot_number                  := p_inv_history_rec.ref_value_4;
    l_lot_exp                     := p_inv_history_rec.ref_value_5;


    --IF p_inv_history_rec.activity_code in (24, 25)    AND
    IF l_to_locator_id = l_from_locator_id THEN
      NULL;
    ELSE
      l_trx_type_name               := 'Transf Subinventario'; --Transferencia Entre localizadores
      l_trx_organization_id         := l_transfer_organization_id;
      l_trx_subinventory_code       := l_transfer_subinventory_code;
      l_trx_locator_id              := l_from_locator_id;
      l_trf_organization_id         := l_transfer_organization_id;
      l_trf_subinventory_code       := l_transfer_subinventory_code;
      l_trf_locator_id              := l_to_locator_id;
      -- Obtener reason_id
      get_reason_id('TRNI', l_reason_id, x_msg_data);
      IF x_msg_data IS NOT NULL THEN
        RAISE e_error;
      END IF;
      xx_debug_pk.debug(l_calling_sequence||', l_reason_id: '||l_reason_id,1);
  
      xx_debug_pk.debug(l_calling_sequence||', l_trx_type_name: '||l_trx_type_name,1);
      BEGIN
        SELECT mtt.transaction_type_id
              ,mtt.transaction_action_id
              ,mtt.transaction_source_type_id
          INTO l_transaction_type_id
              ,l_transaction_action_id
              ,l_transaction_source_type_id
          FROM mtl_transaction_types mtt
         WHERE mtt.transaction_type_name = l_trx_type_name;
      EXCEPTION
        WHEN OTHERS THEN
          x_msg_data := 'Error al buscar tipo de transaccion: '||l_trx_type_name||'. '||sqlerrm;
          RAISE e_error;
      END;
      xx_debug_pk.debug(l_calling_sequence||', l_transaction_type_id: '||l_transaction_type_id,1);

      xx_debug_pk.debug(l_calling_sequence||', Antes create_mtl_trx     ',1);
      xx_debug_pk.debug(l_calling_sequence||', ------------------------------------------',1);
      xx_debug_pk.debug(l_calling_sequence||', l_inventory_item_id: '||l_inventory_item_id,1);
      xx_debug_pk.debug(l_calling_sequence||', l_trx_organization_id: '||l_trx_organization_id,1);
      xx_debug_pk.debug(l_calling_sequence||', l_trx_subinventory_code: '||l_trx_subinventory_code,1);
      xx_debug_pk.debug(l_calling_sequence||', l_trx_locator_id: '||l_trx_locator_id,1);
      xx_debug_pk.debug(l_calling_sequence||', l_trf_organization_id: '||l_trf_organization_id,1);
      xx_debug_pk.debug(l_calling_sequence||', l_trf_subinventory_code: '||l_trf_subinventory_code,1);
      xx_debug_pk.debug(l_calling_sequence||', l_trf_locator_id: '||l_trf_locator_id,1);
      xx_debug_pk.debug(l_calling_sequence||', l_transaction_type_id: '||l_transaction_type_id,1);
      xx_debug_pk.debug(l_calling_sequence||', l_transaction_action_id: '||l_transaction_action_id,1);
      xx_debug_pk.debug(l_calling_sequence||', l_transaction_source_type_id: '||l_transaction_source_type_id,1);
      xx_debug_pk.debug(l_calling_sequence||', l_transaction_source_id: '||l_transaction_source_id,1);
      xx_debug_pk.debug(l_calling_sequence||', l_reason_id: '||l_reason_id,1);
      xx_debug_pk.debug(l_calling_sequence||', l_trx_quantity: '||l_trx_quantity,1);
      xx_debug_pk.debug(l_calling_sequence||', l_uom_code: '||l_uom_code,1);
      xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.lpn_nbr: '||p_inv_history_rec.lpn_nbr,1);
      xx_debug_pk.debug(l_calling_sequence||', l_lot_number: '||l_lot_number,1);
      xx_debug_pk.debug(l_calling_sequence||', l_lot_exp: '||l_lot_exp,1);
      xx_debug_pk.debug(l_calling_sequence||', ------------------------------------------',1);

      create_mtl_trx (p_inventory_item_id              => l_inventory_item_id
                     ,p_organization_id                => l_trx_organization_id
                     ,p_subinventory_code              => l_trx_subinventory_code
                     ,p_locator_id                     => l_trx_locator_id
                     ,p_transfer_organization_id       => l_trf_organization_id
                     ,p_transfer_subinventory_code     => l_trf_subinventory_code
                     ,p_transfer_locator_id            => l_trf_locator_id
                     ,p_transaction_type_id            => l_transaction_type_id
                     ,p_transaction_action_id          => l_transaction_action_id
                     ,p_transaction_source_type_id     => l_transaction_source_type_id
                     ,p_transaction_source_id          => l_transaction_source_id
                     ,p_reason_id                      => l_reason_id
                     ,p_trx_quantity                   => l_trx_quantity
                     ,p_trx_uom                        => l_uom_code
                     ,p_lpn_nbr                        => p_inv_history_rec.lpn_nbr
                     ,p_lot_number                     => l_lot_number
                     ,p_lot_exp                        => l_lot_exp
                     ,x_error_mesg                     => x_msg_data);

      IF x_msg_data IS NOT NULL THEN
        RAISE e_error;
      END IF;
      -- Cambio el estado del lote que corresponde al localizador destino
      update_lot_status(p_organization_id    => l_trf_organization_id
                       ,p_inventory_item_id  => l_inventory_item_id
                       ,p_locator_id         => l_trf_locator_id
                       ,p_org_code           => p_inv_history_rec.facility_code
                       ,p_locator_code       => l_to_locator_code
                       ,p_lot_number         => l_lot_number
                       ,x_error_mesg         => x_msg_data);
    END IF;
  ELSIF p_inv_history_rec.activity_code = 56 THEN
     -- Cuando es bloqueo/desbloqueo de lote no hace nada porque llegan las lineas de cada uno de los lpn
     null;
  END IF;
  COMMIT;

  xx_debug_pk.debug(l_calling_sequence||', Fin',1);

EXCEPTION
  WHEN e_error THEN
    NULL;
  WHEN OTHERS THEN
    x_msg_data := 'Error: '||sqlerrm;
    xx_debug_pk.debug(l_calling_sequence||', error : '||x_msg_data,1);
END block_lot_lpn;

--//-------------------------------------------------------------------------
procedure get_interface_ids(
	 x_header_interface_id			OUT NUMBER
	,x_group_id						OUT NUMBER
	,x_transaction_interface_id		OUT NUMBER
	,x_material_transaction_id		OUT NUMBER
	,x_msg_data						OUT VARCHAR2
)
is
	l_calling_sequence VARCHAR2(100):='xx_wms_int_in_trx_pk.RMA_receipt.get_interface_ids';
begin

	x_msg_data := null;

	select 
	 rcv_headers_interface_s.nextval
	,rcv_interface_groups_s.nextval
	,rcv_transactions_interface_s.nextval
	,mtl_material_transactions_s.nextval
	into 
	 x_header_interface_id
	,x_group_id
	,x_transaction_interface_id
	,x_material_transaction_id
	from dual;

exception
	when others then
		x_msg_data := l_calling_sequence || ': Error al buscar secuencias. ' || sqlerrm;      
end get_interface_ids;

procedure insert_rcv_headers(
	 i_header_interface_id			IN	NUMBER
	,i_group_id						IN	NUMBER
	,i_org_id						IN	NUMBER
	,i_customer_id					IN	NUMBER
	,x_msg_data						OUT	VARCHAR2
)
is
	l_calling_sequence VARCHAR2(100):='xx_wms_int_in_trx_pk.RMA_receipt.insert_rcv_headers';
begin

	x_msg_data := null;

	INSERT INTO RCV_HEADERS_INTERFACE(
		 HEADER_INTERFACE_ID
		,GROUP_ID
		,ORG_ID
		,PROCESSING_STATUS_CODE
		,RECEIPT_SOURCE_CODE
		,TRANSACTION_TYPE
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,CUSTOMER_ID
		,EXPECTED_RECEIPT_DATE
		,VALIDATION_FLAG
	)
	SELECT 
		 i_header_interface_id
		,i_group_id
		,i_org_id
		,'PENDING'
		,'CUSTOMER'
		,'NEW'
		,SYSDATE
		,fnd_global.user_id
		,fnd_global.login_id
		,i_customer_id
		,SYSDATE
		,'Y'
	FROM DUAL;

	xx_debug_pk.debug(l_calling_sequence || ', Insert RCV_HEADERS_INTERFACE: ' || SQL%ROWCOUNT, 1);

exception
	when others then
		x_msg_data := l_calling_sequence || ': Error al insertar en RCV_HEADERS_INTERFACE. ' || sqlerrm;
end insert_rcv_headers;

procedure insert_rcv_transactions(
	 i_transaction_interface_id		IN	NUMBER
	,i_group_id						IN	NUMBER
	,i_org_id						IN	NUMBER
	,i_header_interface_id			IN	NUMBER
	,i_trx_quantity					IN	NUMBER
	,i_order_quantity_uom			IN	VARCHAR2
	,i_inventory_item_id			IN	NUMBER
	,i_employee_id					IN	NUMBER
	,i_organization_id				IN	NUMBER
	,i_ship_from_org_id				IN	NUMBER
	,i_subinventory_code			IN	VARCHAR2
	,i_locator_id					IN	NUMBER
	,i_header_id					IN	NUMBER
	,i_line_id 						IN	NUMBER
	,i_customer_id					IN	NUMBER
	,i_customer_site_id				IN	NUMBER
	,x_msg_data						OUT	VARCHAR2
)
is
	l_calling_sequence VARCHAR2(100):='xx_wms_int_in_trx_pk.RMA_receipt.insert_rcv_transactions';
begin

	x_msg_data := null;

	INSERT INTO RCV_TRANSACTIONS_INTERFACE(
		 INTERFACE_TRANSACTION_ID
		,GROUP_ID
		,ORG_ID
		,HEADER_INTERFACE_ID
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,CREATION_DATE
		,CREATED_BY
		,TRANSACTION_TYPE
		,TRANSACTION_DATE
		,PROCESSING_STATUS_CODE
		,PROCESSING_MODE_CODE
		,TRANSACTION_STATUS_CODE
		,QUANTITY
		,UOM_CODE
		,INTERFACE_SOURCE_CODE
		,ITEM_ID
		,EMPLOYEE_ID
		,AUTO_TRANSACT_CODE
		,RECEIPT_SOURCE_CODE
		,TO_ORGANIZATION_ID
		,SOURCE_DOCUMENT_CODE
		,DESTINATION_TYPE_CODE
		,DELIVER_TO_LOCATION_ID
		,SUBINVENTORY
		,LOCATOR_ID
		,EXPECTED_RECEIPT_DATE
		,OE_ORDER_HEADER_ID
		,OE_ORDER_LINE_ID
		,CUSTOMER_ID
		,CUSTOMER_SITE_ID
		,VALIDATION_FLAG
	) VALUES (
		 i_transaction_interface_id  --INTERFACE_TRANSACTION_ID
		,i_group_id                  --GROUP_ID
		,i_org_id                    --ORG_ID
		,i_header_interface_id       --HEADER_INTERFACE_ID
		,SYSDATE                     --LAST_UPDATE_DATE
		,fnd_global.user_id          --LAST_UPDATED_BY
		,SYSDATE                     --CREATION_DATE
		,fnd_global.user_id          --CREATED_BY
		,'RECEIVE'                   --TRANSACTION_TYPE
		,SYSDATE                     --TRANSACTION_DATE
		,'PENDING'                   --PROCESSING_STATUS_CODE
		,'BATCH'                     --PROCESSING_MODE_CODE
		,'PENDING'                   --TRANSACTION_MODE_CODE
		,i_trx_quantity              --QUANTITY
		,i_order_quantity_uom        --UOM_CODE
		,'RCV'                       --INTERFACE_SOURCE_CODE
		,i_inventory_item_id         --ITEM_ID
		,i_employee_id               --EMPLOYEE_ID
		,'DELIVER'                   --AUTO_TRANSACT_CODE
		,'CUSTOMER'                  --RECEIPT_SOURCE_CODE
		,i_organization_id           --TO_ORGANIZATION_ID
		,'RMA'                       --SOURCE_DOCUMENT_CODE
		,'INVENTORY'                 --DESTINATION_TYPE_CODE
		,i_ship_from_org_id          --DELIVER_TO_LOCATION_ID
		,i_subinventory_code         --SUBINVENTORY
		,i_locator_id                --LOCATOR_ID     -- localizador destino
		,SYSDATE                     --EXPECTED_RECEIPT_DATE
		,i_header_id                 --OE_ORDER_HEADER_ID
		,i_line_id                   --OE_ORDER_LINE_ID
		,i_customer_id               --CUSTOMER_ID
		,i_customer_site_id          --CUSTOMER_SITE_ID
		,'Y'                         --VALIDATION_FLAG
	);

	xx_debug_pk.debug(l_calling_sequence || ', Insert RCV_TRANSACTIONS_INTERFACE: ' || SQL%ROWCOUNT, 1);			   

exception
	when others then
		x_msg_data := l_calling_sequence || ': Error al insertar en RCV_TRANSACTIONS_INTERFACE. ' || sqlerrm;
end insert_rcv_transactions;

procedure insert_mtl_transaction_lots(
	 i_material_transaction_id		IN	NUMBER
	,i_trx_quantity					IN	NUMBER
	,i_lot_number					IN	VARCHAR2
	,i_expiry_date					IN	DATE
	,i_transaction_interface_id		IN	NUMBER
	,x_msg_data						OUT	VARCHAR2
)
is
	l_calling_sequence VARCHAR2(100):='xx_wms_int_in_trx_pk.RMA_receipt.insert_mtl_transaction_lots';
begin

	x_msg_data := null;

	INSERT INTO mtl_transaction_lots_interface(
		 TRANSACTION_interface_ID
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_LOGIN
		,TRANSACTION_QUANTITY
		,LOT_NUMBER
		,LOT_EXPIRATION_DATE
		,PRODUCT_CODE
		,PRODUCT_TRANSACTION_ID
	) VALUES (
		 i_material_transaction_id   	--TRANSACTION_interface_ID
		,SYSDATE                     	--LAST_UPDATE_DATE
		,fnd_global.user_id          	--LAST_UPDATED_BY
		,SYSDATE                     	--CREATION_DATE
		,fnd_global.user_id          	--CREATED_BY
		,fnd_global.login_id         	--LAST_UPDATE_LOGIN
		,i_trx_quantity              	--TRANSACTION_QUANTITY
		,i_lot_number 					--LOT_NUMBER
		,i_expiry_date					--LOT_EXPIRATION_DATE
		,'RCV'                       	--PRODUCT_CODE
		,i_transaction_interface_id  	--PRODUCT_TRANSACTION_ID
	);

	xx_debug_pk.debug(l_calling_sequence || ', Insert MTL_TRANSACTION_LOTS_INTERFACE: ' || SQL%ROWCOUNT, 1);

exception
	when others then
		x_msg_data := l_calling_sequence || ': Error al insertar en MTL_TRANSACTION_LOTS_INTERFACE. ' || sqlerrm;      
end insert_mtl_transaction_lots;

procedure run_interface(
	i_group_id	IN	NUMBER,
	i_org_id	IN	NUMBER,
	x_error		OUT	VARCHAR2
)
is
--	PRAGMA AUTONOMOUS_TRANSACTION;

	l_calling_sequence VARCHAR2(100):='xx_wms_int_in_trx_pk.RMA_receipt.run_interface';
	l_request_id 	number;
	l_request_end 	boolean;
	l_phase			varchar2(255);
	l_status		varchar2(255);
	l_dev_phase		varchar2(255);
	l_dev_status	varchar2(255);
	l_message		varchar2(2000);

begin

	x_error := NULL;

	l_request_id := 
	fnd_request.submit_request (
		application => 'PO',
		program => 'RVCTP',
		argument1 => 'BATCH',
		argument2 => i_group_id,
		argument3 => i_org_id
	);

	if(l_request_id > 0)then

		l_request_end := 
		fnd_concurrent.wait_for_request(
			request_id => l_request_id,
			interval => 5,
			phase => l_phase,
			status => l_status,
			dev_phase => l_dev_phase,
			dev_status => l_dev_status,
			message => l_message
		);

		if not(l_dev_phase = 'COMPLETE' and l_dev_status = 'NORMAL')then

			x_error := l_calling_sequence || ': ' || l_message;

		end if;

	end if;

exception
	when others then
		x_error := l_calling_sequence || ': Error en submit_request. ' || sqlerrm;

end run_interface;
--//-------------------------------------------------------------------------

PROCEDURE split_rma_line(p_header_id                            IN NUMBER
                        ,p_line_id                              IN NUMBER
                        ,p_inventory_item_id                    IN NUMBER
                        ,p_org_id                               IN NUMBER
                        ,p_ordered_qty                          IN NUMBER
                        ,p_split_ordered_qty                    IN NUMBER
                        ,x_new_line_id                         OUT NUMBER
                        ,x_msg_data                            OUT VARCHAR2)
IS
 l_header_rec OE_ORDER_PUB.Header_Rec_Type;
 l_line_tbl OE_ORDER_PUB.Line_Tbl_Type;
 l_action_request_tbl OE_ORDER_PUB.Request_Tbl_Type;
 l_return_status VARCHAR2(1000);
 l_msg_count NUMBER;
 l_msg_data VARCHAR2(1000);
 p_api_version_number NUMBER :=1.0;
 p_init_msg_list VARCHAR2(10) := FND_API.G_FALSE;
 p_return_values VARCHAR2(10) := FND_API.G_FALSE;
 p_action_commit VARCHAR2(10) := FND_API.G_FALSE;
 p_header_rec OE_ORDER_PUB.Header_Rec_Type := OE_ORDER_PUB.G_MISS_HEADER_REC;
 p_old_header_rec OE_ORDER_PUB.Header_Rec_Type :=  OE_ORDER_PUB.G_MISS_HEADER_REC;
 p_header_val_rec OE_ORDER_PUB.Header_Val_Rec_Type := OE_ORDER_PUB.G_MISS_HEADER_VAL_REC;
 p_old_header_val_rec OE_ORDER_PUB.Header_Val_Rec_Type := OE_ORDER_PUB.G_MISS_HEADER_VAL_REC;
 p_Header_Adj_tbl OE_ORDER_PUB.Header_Adj_Tbl_Type :=  OE_ORDER_PUB.G_MISS_HEADER_ADJ_TBL;
 p_old_Header_Adj_tbl OE_ORDER_PUB.Header_Adj_Tbl_Type := OE_ORDER_PUB.G_MISS_HEADER_ADJ_TBL;
 p_Header_Adj_val_tbl OE_ORDER_PUB.Header_Adj_Val_Tbl_Type := OE_ORDER_PUB.G_MISS_HEADER_ADJ_VAL_TBL;
 p_old_Header_Adj_val_tbl OE_ORDER_PUB.Header_Adj_Val_Tbl_Type := OE_ORDER_PUB.G_MISS_HEADER_ADJ_VAL_TBL;
 p_Header_price_Att_tbl OE_ORDER_PUB.Header_Price_Att_Tbl_Type := OE_ORDER_PUB.G_MISS_HEADER_PRICE_ATT_TBL;
 p_old_Header_Price_Att_tbl OE_ORDER_PUB.Header_Price_Att_Tbl_Type := OE_ORDER_PUB.G_MISS_HEADER_PRICE_ATT_TBL;
 p_Header_Adj_Att_tbl OE_ORDER_PUB.Header_Adj_Att_Tbl_Type := OE_ORDER_PUB.G_MISS_HEADER_ADJ_ATT_TBL;
 p_old_Header_Adj_Att_tbl OE_ORDER_PUB.Header_Adj_Att_Tbl_Type :=  OE_ORDER_PUB.G_MISS_HEADER_ADJ_ATT_TBL;
 p_Header_Adj_Assoc_tbl OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type :=  OE_ORDER_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL;
 p_old_Header_Adj_Assoc_tbl OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type := OE_ORDER_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL;
 p_Header_Scredit_tbl OE_ORDER_PUB.Header_Scredit_Tbl_Type := OE_ORDER_PUB.G_MISS_HEADER_SCREDIT_TBL;
 p_old_Header_Scredit_tbl OE_ORDER_PUB.Header_Scredit_Tbl_Type := OE_ORDER_PUB.G_MISS_HEADER_SCREDIT_TBL;
 p_Header_Scredit_val_tbl OE_ORDER_PUB.Header_Scredit_Val_Tbl_Type := OE_ORDER_PUB.G_MISS_HEADER_SCREDIT_VAL_TBL;
 p_old_Header_Scredit_val_tbl OE_ORDER_PUB.Header_Scredit_Val_Tbl_Type := OE_ORDER_PUB.G_MISS_HEADER_SCREDIT_VAL_TBL;
 p_line_tbl OE_ORDER_PUB.Line_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_TBL;
 p_old_line_tbl OE_ORDER_PUB.Line_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_TBL;
 p_line_val_tbl OE_ORDER_PUB.Line_Val_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_VAL_TBL;
 p_old_line_val_tbl OE_ORDER_PUB.Line_Val_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_VAL_TBL;
 p_Line_Adj_tbl OE_ORDER_PUB.Line_Adj_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_ADJ_TBL;
 p_old_Line_Adj_tbl OE_ORDER_PUB.Line_Adj_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_ADJ_TBL;
 p_Line_Adj_val_tbl OE_ORDER_PUB.Line_Adj_Val_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_ADJ_VAL_TBL;
 p_old_Line_Adj_val_tbl OE_ORDER_PUB.Line_Adj_Val_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_ADJ_VAL_TBL;
 p_Line_price_Att_tbl OE_ORDER_PUB.Line_Price_Att_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_PRICE_ATT_TBL;
 p_old_Line_Price_Att_tbl OE_ORDER_PUB.Line_Price_Att_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_PRICE_ATT_TBL;
 p_Line_Adj_Att_tbl OE_ORDER_PUB.Line_Adj_Att_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_ADJ_ATT_TBL;
 p_old_Line_Adj_Att_tbl OE_ORDER_PUB.Line_Adj_Att_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_ADJ_ATT_TBL;
 p_Line_Adj_Assoc_tbl OE_ORDER_PUB.Line_Adj_Assoc_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_ADJ_ASSOC_TBL;
 p_old_Line_Adj_Assoc_tbl OE_ORDER_PUB.Line_Adj_Assoc_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_ADJ_ASSOC_TBL;
 p_Line_Scredit_tbl OE_ORDER_PUB.Line_Scredit_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_SCREDIT_TBL;
 p_old_Line_Scredit_tbl OE_ORDER_PUB.Line_Scredit_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_SCREDIT_TBL;
 p_Line_Scredit_val_tbl OE_ORDER_PUB.Line_Scredit_Val_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_SCREDIT_VAL_TBL;
 p_old_Line_Scredit_val_tbl OE_ORDER_PUB.Line_Scredit_Val_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_SCREDIT_VAL_TBL;
 p_Lot_Serial_tbl OE_ORDER_PUB.Lot_Serial_Tbl_Type := OE_ORDER_PUB.G_MISS_LOT_SERIAL_TBL;
 p_old_Lot_Serial_tbl OE_ORDER_PUB.Lot_Serial_Tbl_Type := OE_ORDER_PUB.G_MISS_LOT_SERIAL_TBL;
 p_Lot_Serial_val_tbl OE_ORDER_PUB.Lot_Serial_Val_Tbl_Type := OE_ORDER_PUB.G_MISS_LOT_SERIAL_VAL_TBL;
 p_old_Lot_Serial_val_tbl OE_ORDER_PUB.Lot_Serial_Val_Tbl_Type := OE_ORDER_PUB.G_MISS_LOT_SERIAL_VAL_TBL;
 p_action_request_tbl OE_ORDER_PUB.Request_Tbl_Type := OE_ORDER_PUB.G_MISS_REQUEST_TBL;
 x_header_val_rec OE_ORDER_PUB.Header_Val_Rec_Type;
 x_Header_Adj_tbl OE_ORDER_PUB.Header_Adj_Tbl_Type;
 x_Header_Adj_val_tbl OE_ORDER_PUB.Header_Adj_Val_Tbl_Type;
 x_Header_price_Att_tbl OE_ORDER_PUB.Header_Price_Att_Tbl_Type;
 x_Header_Adj_Att_tbl OE_ORDER_PUB.Header_Adj_Att_Tbl_Type; 
 x_Header_Adj_Assoc_tbl OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type;
 x_Header_Scredit_tbl OE_ORDER_PUB.Header_Scredit_Tbl_Type;
 x_Header_Scredit_val_tbl OE_ORDER_PUB.Header_Scredit_Val_Tbl_Type;
 x_line_val_tbl OE_ORDER_PUB.Line_Val_Tbl_Type;
 x_Line_Adj_tbl OE_ORDER_PUB.Line_Adj_Tbl_Type;
 x_Line_Adj_val_tbl OE_ORDER_PUB.Line_Adj_Val_Tbl_Type;
 x_Line_price_Att_tbl OE_ORDER_PUB.Line_Price_Att_Tbl_Type;
 x_Line_Adj_Att_tbl OE_ORDER_PUB.Line_Adj_Att_Tbl_Type;
 x_Line_Adj_Assoc_tbl OE_ORDER_PUB.Line_Adj_Assoc_Tbl_Type;
 x_Line_Scredit_tbl OE_ORDER_PUB.Line_Scredit_Tbl_Type;
 x_Line_Scredit_val_tbl OE_ORDER_PUB.Line_Scredit_Val_Tbl_Type;
 x_Lot_Serial_tbl OE_ORDER_PUB.Lot_Serial_Tbl_Type;
 x_Lot_Serial_val_tbl OE_ORDER_PUB.Lot_Serial_Val_Tbl_Type;
 x_action_request_tbl OE_ORDER_PUB.Request_Tbl_Type;
 X_DEBUG_FILE VARCHAR2(100);
 l_line_tbl_index NUMBER;
 l_msg_index_out NUMBER(10);
 l_calling_sequence VARCHAR2(100):='xx_wms_int_in_trx_pk.RMA_receipt.split_rma_line';
BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  xx_debug_pk.debug(l_calling_sequence||', p_header_id: '||p_header_id,1);
  xx_debug_pk.debug(l_calling_sequence||', p_line_id: '||p_line_id,1);
  xx_debug_pk.debug(l_calling_sequence||', p_ordered_qty: '||p_ordered_qty,1);
  xx_debug_pk.debug(l_calling_sequence||', p_split_ordered_qty: '||p_split_ordered_qty,1);
  x_msg_data := null;
  oe_msg_pub.initialize;
  --fnd_global.apps_initialize(42057,50276,660); 
  mo_global.init('ONT');
  oe_debug_pub.initialize;
  X_DEBUG_FILE := OE_DEBUG_PUB.Set_Debug_Mode('FILE');
  --oe_debug_pub.SetDebugLevel(5); -- Use 5 for the most debuging output, I warn  you its a lot of data
 --This is to UPDATE order line
  l_line_tbl_index :=1;
 -- Changed attributes
  l_header_rec := OE_ORDER_PUB.G_MISS_HEADER_REC;
  l_header_rec.header_id := p_header_id; -- header_id of the order
  l_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
  l_line_tbl(l_line_tbl_index) := OE_ORDER_PUB.G_MISS_LINE_REC;
  l_line_tbl(l_line_tbl_index).operation := OE_GLOBALS.G_OPR_UPDATE;
  l_line_tbl(l_line_tbl_index).split_by := FND_GLOBAL.USER_ID; -- Pass user_id who is splitting the line
  l_line_tbl(l_line_tbl_index).split_action_code := 'SPLIT';
  l_line_tbl(l_line_tbl_index).header_id := p_header_id; -- header_id of the order
  l_line_tbl(l_line_tbl_index).line_id := p_line_id; -- line_id of the order line which needs to split
  l_line_tbl(l_line_tbl_index).ordered_quantity := p_ordered_qty - p_split_ordered_qty; -- new ordered quantity of the line which you want to split 
  l_line_tbl(l_line_tbl_index).change_reason := 'MISC'; -- Enter the reason code for this Split
  l_line_tbl(l_line_tbl_index).org_id := p_org_id;  
  l_line_tbl_index :=2;
  l_line_tbl(l_line_tbl_index ) := OE_ORDER_PUB.G_MISS_LINE_REC;
  l_line_tbl(l_line_tbl_index ).operation := OE_GLOBALS.G_OPR_CREATE;
  l_line_tbl(l_line_tbl_index ).split_by := 'WMS'; --'USER'; -- Enter user(Bug 25793299)
  l_line_tbl(l_line_tbl_index ).split_action_code := 'SPLIT';
  l_line_tbl(l_line_tbl_index ).split_from_line_id := p_line_id; -- line_id of  original line from which the line is splitted
  l_line_tbl(l_line_tbl_index ).inventory_item_id := p_inventory_item_id; -- inventory item id
  l_line_tbl(l_line_tbl_index ).ordered_quantity := p_split_ordered_qty; -- Enter the remaining qty after Split in ordered quantity 
  l_line_tbl(l_line_tbl_index).org_id := p_org_id;  
 -- CALL TO PROCESS ORDER
  OE_ORDER_PUB.process_order (
   p_api_version_number => 1.0
   , p_init_msg_list => fnd_api.g_false
   , p_return_values => fnd_api.g_false
   , p_action_commit => fnd_api.g_false
   , p_org_id        => p_org_id              
   , x_return_status => l_return_status
   , x_msg_count => l_msg_count
   , x_msg_data => l_msg_data
   , p_header_rec => l_header_rec
   , p_line_tbl => l_line_tbl
   , p_action_request_tbl => l_action_request_tbl
 -- OUT PARAMETERS
   , x_header_rec => p_header_rec
   , x_header_val_rec => x_header_val_rec
   , x_Header_Adj_tbl => x_Header_Adj_tbl
   , x_Header_Adj_val_tbl => x_Header_Adj_val_tbl
   , x_Header_price_Att_tbl => x_Header_price_Att_tbl
   , x_Header_Adj_Att_tbl => x_Header_Adj_Att_tbl
   , x_Header_Adj_Assoc_tbl => x_Header_Adj_Assoc_tbl
   , x_Header_Scredit_tbl => x_Header_Scredit_tbl
   , x_Header_Scredit_val_tbl => x_Header_Scredit_val_tbl
   , x_line_tbl => p_line_tbl
   , x_line_val_tbl => x_line_val_tbl
   , x_Line_Adj_tbl => x_Line_Adj_tbl
   , x_Line_Adj_val_tbl => x_Line_Adj_val_tbl
   , x_Line_price_Att_tbl => x_Line_price_Att_tbl
   , x_Line_Adj_Att_tbl => x_Line_Adj_Att_tbl
   , x_Line_Adj_Assoc_tbl => x_Line_Adj_Assoc_tbl
   , x_Line_Scredit_tbl => x_Line_Scredit_tbl
   , x_Line_Scredit_val_tbl => x_Line_Scredit_val_tbl
   , x_Lot_Serial_tbl => x_Lot_Serial_tbl
   , x_Lot_Serial_val_tbl => x_Lot_Serial_val_tbl
   , x_action_request_tbl => l_action_request_tbl
  );

  xx_debug_pk.debug(l_calling_sequence||', OM Debug file: ' ||oe_debug_pub.G_DIR||'/'||oe_debug_pub.G_FILE,1);
  xx_debug_pk.debug(l_calling_sequence||', l_msg_count: '||l_msg_count ,1);
  xx_debug_pk.debug(l_calling_sequence||', l_msg_data: '||l_msg_data ,1);
 -- Retrieve messages
  FOR i IN 1 .. l_msg_count LOOP
    Oe_Msg_Pub.get( p_msg_index => i
                  , p_encoded => Fnd_Api.G_FALSE
                  , p_data => l_msg_data
                  , p_msg_index_out => l_msg_index_out);
    xx_debug_pk.debug(l_calling_sequence||', l_msg_data: '||l_msg_data ,1);
    xx_debug_pk.debug(l_calling_sequence||', l_msg_index_out: '||l_msg_index_out ,1);
    x_msg_data := x_msg_data||' '||l_msg_data;
  END LOOP;
 -- Check the return status
  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
    xx_debug_pk.debug(l_calling_sequence||', Line Id 1: '||p_line_tbl(1).line_id ,1);
    xx_debug_pk.debug(l_calling_sequence||', Ordered qty 1: '||p_line_tbl(1).ordered_quantity ,1);
    xx_debug_pk.debug(l_calling_sequence||', Line Id 2: '||p_line_tbl(2).line_id ,1);
    xx_debug_pk.debug(l_calling_sequence||', Ordered qty 2: '||p_line_tbl(2).ordered_quantity ,1);
  ELSE
    xx_debug_pk.debug(l_calling_sequence||', Line Quantity update Failed',1);
  END IF;

  x_new_line_id := p_line_tbl(2).line_id;             
  xx_debug_pk.debug(l_calling_sequence||', Fin',1);

EXCEPTION
  WHEN OTHERS THEN
    x_msg_data := l_calling_sequence || ': Error al hacer split de linea. ' || sqlerrm;
END split_rma_line;

PROCEDURE RMA_receipt
(p_inv_history_rec           IN  xx_wms_int_in_pk.XX_WMS_INV_HISTORY_REC
,x_msg_data                  OUT VARCHAR2
) AS
l_calling_sequence               VARCHAR2(100):='xx_wms_int_in_trx_pk.RMA_receipt';
l_organization_id                NUMBER;
l_locator_id                     NUMBER;
l_inventory_item_id              NUMBER;
l_user_id                        NUMBER;
l_resp_id                        NUMBER;
l_appl_id                        NUMBER;
l_org_id                         NUMBER;
l_header_interface_id            NUMBER;
l_group_id                       NUMBER;
l_material_transaction_id        NUMBER;
l_transaction_interface_id       NUMBER;
l_customer_id                    NUMBER;
l_customer_site_id               NUMBER;
l_employee_id                    NUMBER;
l_ship_from_org_id               NUMBER;
l_header_id                      NUMBER;
l_line_id                        NUMBER;
l_request_id                     NUMBER;
l_ordered_quantity               NUMBER;
l_trx_quantity                   NUMBER;
l_order_quantity_uom             VARCHAR2(30);
l_org_code                       VARCHAR2(30);
l_subinventory_code              VARCHAR2(30);
l_locator_code                   VARCHAR2(30);
l_locator                        VARCHAR2(30);
l_uom_code                       VARCHAR2(30);
l_respo_split_om                 VARCHAR2(100);
e_error                          EXCEPTION;

	--//----------------------------------------------
	cursor rma_cur(p_header_id number, p_inventory_item_id number, p_units_received number, p_uom_ocde varchar2) is
		SELECT ooha.org_id
			  ,oola.header_id
			  ,oola.line_id
			  ,oola.ship_from_org_id
			  ,hcasa.cust_acct_site_id customer_site_id
			  ,hca.cust_account_id customer_id
			  ,oola.order_quantity_uom
			  ,oola.ordered_quantity
			  ,inv_convert.inv_um_convert (
					oola.inventory_item_id    --Inventory Item Id
					,NULL                     --Precision
					,NVL(p_units_received, 0) --Quantity
					,p_uom_ocde               --From UOM
					,oola.order_quantity_uom  --To UOM
					,NULL                     --From UOM Name
					,NULL                     --To UOM Name
				) transaction_quantity
		  FROM oe_order_headers_all    ooha
			  ,oe_order_lines_all      oola
			  ,hz_cust_site_uses_all   hcsua
			  ,hz_cust_acct_sites_all  hcasa
			  ,hz_cust_accounts        hca
		 WHERE 1 = 1
		   AND oola.header_id = p_header_id
		   AND oola.inventory_item_id = p_inventory_item_id
		   AND ooha.header_id = oola.header_id
		   AND ooha.flow_status_code NOT IN ('CLOSED','CANCELLED')
		   AND oola.flow_status_code = 'AWAITING_RETURN'
		   AND ooha.ship_to_org_id = hcsua.site_use_id
		   AND ooha.org_id = hcsua.org_id
		   AND hcsua.site_use_code = 'SHIP_TO'
		   AND hcsua.status = 'A'
		   AND hcsua.cust_acct_site_id = hcasa.cust_acct_site_id
		   AND hca.cust_account_id = hcasa.cust_account_id
		   AND hca.status = 'A'
                   AND NOT EXISTS (SELECT 1 
                                     FROM RCV_TRANSACTIONS_INTERFACE rti
                                    WHERE rti.oe_order_header_id     = p_header_id
                                      AND rti.oe_order_line_id       = oola.line_id
                                      AND rti.processing_status_code = 'PENDING' ) 
		   ORDER BY oola.line_id
		   ;

	l_rma_row rma_cur%rowtype;
	l_found boolean;
	l_index number := 1;
	l_error varchar2(32767);
	l_quantity number;
	l_exists boolean;
	l_status varchar2(100);	
	--//----------------------------------------------

BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  l_user_id := fnd_profile.value('XX_WMS_INTEGRATION_USER');
  --l_resp_id := fnd_profile.value('XX_WMS_INTEGRATION_RESPO_OPM');

  IF l_user_id IS NULL THEN
    x_msg_data := 'No se encuentra configurada la opcion de perfil XX WMS Usuario Integracion';
    RAISE e_error;
  END IF;
  BEGIN
    SELECT flv_d.xx_respo_split_om
      INTO l_respo_split_om
      FROM fnd_lookup_values_vl flv
          ,fnd_lookup_values_dfv flv_d
     WHERE flv.lookup_type = 'XX_EBS_WMS_RESPO'
       AND flv.lookup_code = p_inv_history_rec.facility_code
       AND flv.rowid = flv_d.row_id;
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al buscar la responsabilidad de Split de OM: '||sqlerrm;
      RAISE e_error;
  END;

  IF l_respo_split_om IS NULL THEN
    x_msg_data := 'No se encuentra configurado el Flexfield de responsabilidad de spliet de OM en el lookup XX_EBS_WMS_RESPO';
    RAISE e_error;
  END IF;

  BEGIN
    SELECT responsibility_id
          ,application_id
      INTO l_resp_id
          ,l_appl_id
      FROM fnd_responsibility_vl
     WHERE responsibility_name = l_respo_split_om;
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al obtener applicacion para la responsibility_name: '||l_respo_split_om||'. '||sqlerrm;
      RAISE e_error;
  END;
  fnd_profile.initialize (l_user_id);
  fnd_global.apps_initialize(user_id =>l_user_id
                            ,resp_id =>l_resp_id
                            ,resp_appl_id =>l_appl_id );

  -- Obtener Organizacion de Confirmacion Despacho
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.facility_code : '||p_inv_history_rec.facility_code,1);
  get_organization_id(p_inv_history_rec.facility_code, 'ORG_CONFIRM_DESPACHO',l_organization_id ,l_org_code,x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_organization_id: '||l_organization_id,1);

  -- Obtener Item
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.item_code : '||p_inv_history_rec.item_code,1);
  get_item_id(p_inv_history_rec.item_code, l_organization_id ,l_inventory_item_id, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_inventory_item_id: '||l_inventory_item_id,1);

  -- Obtener Subinventory de Confirmacion de Despacho
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.facility_code : '||p_inv_history_rec.facility_code,1);
  get_subinventory_code(p_inv_history_rec.facility_code, 'SUBINV_CONFIRM_DESPACHO',l_subinventory_code, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_subinventory_code: '||l_subinventory_code,1);

  BEGIN
    SELECT flv_d.XX_loc_Confirmacion_Despacho locator
      INTO l_locator
      FROM fnd_lookup_values_vl flv
          ,fnd_lookup_values_dfv flv_d
     WHERE flv.lookup_type = 'XX_MAPEO_EBS_WMS'
       AND flv.lookup_code = l_org_code
       AND flv.rowid = flv_d.row_id;
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al buscar localizador de confirmacion de despacho: '||sqlerrm;
      RAISE e_error;
  END;

  -- Obtener Localizador de Confirmacion de Despacho
  xx_debug_pk.debug(l_calling_sequence||', l_locator : '||l_locator,1);
  BEGIN
    SELECT mil.inventory_location_id
      INTO l_locator_id
      FROM mtl_item_locations mil
     WHERE mil.organization_id = l_organization_id
       AND mil.subinventory_code = l_subinventory_code
       AND mil.segment1          = l_locator;
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al obtener localizador: '||l_locator||' Error: '||sqlerrm;
      RAISE e_error;
  END;
  xx_debug_pk.debug(l_calling_sequence||', l_locator_id: '||l_locator_id,1);

  -- Obtener UOM para Declaracion de Produccion
  get_item_uom(l_inventory_item_id, 'DUN14', l_organization_id, l_uom_code, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_uom_code: '||l_uom_code,1);
  xx_debug_pk.debug(l_calling_sequence||', p_inv_history_rec.units_received: '||p_inv_history_rec.units_received,1);

/*----------------------------------------------------------------------------------------------	
  -- Obtener datos de la linea de RMA a recibir
  BEGIN
    SELECT ooha.org_id
          ,oola.header_id
          ,oola.line_id
          ,oola.ship_from_org_id
          ,hcasa.cust_acct_site_id customer_site_id
          ,hca.cust_account_id customer_id
          ,oola.order_quantity_uom
          ,oola.ordered_quantity
          ,inv_convert.inv_um_convert (oola.inventory_item_id    --Inventory Item Id
                                      ,NULL                     --Precision
                                      ,NVL (p_inv_history_rec.units_received,0)  --Quantity
                                      ,l_uom_code               --From UOM
                                      ,oola.order_quantity_uom      --To UOM
                                      ,NULL                     --From UOM Name
                                      ,NULL                     --To UOM Name
                                      ) transaction_quantity

      INTO l_org_id
          ,l_header_id
          ,l_line_id
          ,l_ship_from_org_id
          ,l_customer_site_id
          ,l_customer_id
          ,l_order_quantity_uom
          ,l_ordered_quantity
          ,l_trx_quantity
      FROM oe_order_headers_all    ooha
          ,oe_order_lines_all      oola
          ,hz_cust_site_uses_all   hcsua
          ,hz_cust_acct_sites_all  hcasa
          ,hz_cust_accounts        hca
     WHERE 1 = 1
       AND oola.line_id            = to_number(p_inv_history_rec.invn_attr_a)
       AND ooha.header_id          = oola.header_id
       AND oola.flow_status_code   NOT IN ('CLOSED','CANCELLED')
       AND ooha.flow_status_code   NOT IN ('CLOSED','CANCELLED')
       AND oola.flow_status_code   = 'AWAITING_RETURN'
       AND ooha.ship_to_org_id     = hcsua.site_use_id
       AND ooha.org_id             = hcsua.org_id
       AND hcsua.site_use_code     = 'SHIP_TO'
       AND hcsua.status            = 'A'
       AND hcsua.cust_acct_site_id = hcasa.cust_acct_site_id
       AND hca.cust_account_id     = hcasa.cust_account_id
       AND hca.status              = 'A';
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data := 'Error al buscar linea de pedido, line_id: '||l_line_id||'. Error: '||sqlerrm;
      RAISE e_error;
  END;
----------------------------------------------------------------------------------------------	*/

	--//---------------------------------------------------------------------------
	open rma_cur(to_number(p_inv_history_rec.invn_attr_a), l_inventory_item_id, p_inv_history_rec.units_received, l_uom_code);
	fetch rma_cur into l_rma_row; 
	l_found := rma_cur%found;
	close rma_cur;

	l_trx_quantity := l_rma_row.transaction_quantity;

	while l_found and l_trx_quantity > 0 loop

		xx_debug_pk.debug(l_calling_sequence || ' ' || l_index || ' ) l_trx_quantity: '|| l_trx_quantity, 1);
		xx_debug_pk.debug(l_calling_sequence || ' ' || l_index || ' ) order_quantity_uom: ' || l_rma_row.order_quantity_uom, 1);
		xx_debug_pk.debug(l_calling_sequence || ' ' || l_index || ' ) ordered_quantity: ' || l_rma_row.ordered_quantity, 1);		

		get_interface_ids(
			 x_header_interface_id => l_header_interface_id
			,x_group_id => l_group_id
			,x_transaction_interface_id => l_transaction_interface_id
			,x_material_transaction_id => l_material_transaction_id
			,x_msg_data => l_error
		);

		if(l_error is not null)then
			x_msg_data := l_error;
			RAISE e_error;				
		end if;

		insert_rcv_headers(
			 i_header_interface_id => l_header_interface_id
			,i_group_id => l_group_id
			,i_org_id => l_rma_row.org_id
			,i_customer_id => l_rma_row.customer_id
			,x_msg_data => l_error
		);

		if(l_error is not null)then
			x_msg_data := l_error;
			RAISE e_error;				
		end if;			

		--if(l_rma_row.ordered_quantity >= l_trx_quantity)then
		if(l_rma_row.ordered_quantity > l_trx_quantity)then

			l_quantity := l_trx_quantity;
                        split_rma_line(p_header_id          => l_rma_row.header_id 
                                      ,p_line_id            => l_rma_row.line_id
                                      ,p_inventory_item_id  => l_inventory_item_id        
                                      ,p_org_id             => l_rma_row.org_id        
                                      ,p_ordered_qty        => l_rma_row.ordered_quantity                           
                                      ,p_split_ordered_qty  => l_trx_quantity             
                                      ,x_new_line_id        => l_line_id                  
                                      ,x_msg_data           => x_msg_data);                 
                        IF x_msg_data IS NOT NULL THEN
                          RAISE e_error;
                        END IF;
			l_trx_quantity := 0;

		else
			l_quantity     := l_rma_row.ordered_quantity; 
			l_trx_quantity := l_trx_quantity - l_rma_row.ordered_quantity;
                        l_line_id      := l_rma_row.line_id;

		end if;

		insert_rcv_transactions(
			 i_transaction_interface_id	=> l_transaction_interface_id
			,i_group_id	=> l_group_id
			,i_org_id => l_rma_row.org_id
			,i_header_interface_id => l_header_interface_id
			,i_trx_quantity	=> l_quantity
			,i_order_quantity_uom => l_rma_row.order_quantity_uom
			,i_inventory_item_id => l_inventory_item_id
			,i_employee_id	=> l_employee_id
			,i_organization_id	=> l_organization_id
			,i_ship_from_org_id	=> l_rma_row.ship_from_org_id
			,i_subinventory_code => l_subinventory_code
			,i_locator_id => l_locator_id
			,i_header_id => l_rma_row.header_id
			,i_line_id => l_line_id
			,i_customer_id => l_rma_row.customer_id
			,i_customer_site_id => l_rma_row.customer_site_id
			,x_msg_data => l_error
		);

		if(l_error is not null)then
			x_msg_data := l_error;
			RAISE e_error;				
		end if;

		insert_mtl_transaction_lots(
			 i_material_transaction_id => l_material_transaction_id
			,i_trx_quantity => l_quantity
			,i_lot_number => p_inv_history_rec.ref_value_3
			,i_expiry_date => to_date(p_inv_history_rec.ref_value_4, 'YYYYMMDD')
			,i_transaction_interface_id => l_transaction_interface_id
			,x_msg_data => l_error
		);

		if(l_error is not null)then
			x_msg_data := l_error;
			RAISE e_error;				
		end if;

		--//----------------------
		/*
                run_interface(
			i_group_id => l_group_id,
			i_org_id => l_rma_row.org_id,
			x_error => l_error
		);

		if(l_error is not null)then
			x_msg_data := l_error;
			RAISE e_error;				
		end if;		
                */
		--//----------------------

		--//----------------------
		/*

		** ESTE ES EL LOOP QUE NO TERMINA NUNCA PORQUE LA TABAL DE INTERFACE QUEDA LOCKEADA
		**

		l_exists := true;
		while l_exists loop

			xx_debug_pk.debug(l_calling_sequence || ', Esperando que termine interfaz ' || l_group_id, 1);

			begin

				select processing_status_code into l_status
				from rcv_transactions_interface
				where 1=1
				and group_id = l_group_id
				;

				if(l_status = 'ERROR')then
					l_exists := false;
				else
					dbms_lock.sleep(10);
				end if;

			exception
				when no_data_found then

					xx_debug_pk.debug(l_calling_sequence || ', Termin€ interfaz ' || l_group_id, 1);

					l_exists := false;
			end;
		end loop;
		*/
		--//----------------------

		l_index := l_index + 1;

		open rma_cur(to_number(p_inv_history_rec.invn_attr_a), l_inventory_item_id, p_inv_history_rec.units_received, l_uom_code);
		fetch rma_cur into l_rma_row; 
		l_found := rma_cur%found;
		close rma_cur;		

	end loop;
	--//---------------------------------------------------------------------------

  COMMIT;
  xx_debug_pk.debug(l_calling_sequence||', Fin',1);

EXCEPTION
  WHEN e_error THEN
    NULL;
  WHEN OTHERS THEN
    x_msg_data := 'Error: '||sqlerrm;
    xx_debug_pk.debug(l_calling_sequence||', error : '||x_msg_data,1);
END RMA_receipt;

END xx_wms_int_in_trx_pk;
/
exit
