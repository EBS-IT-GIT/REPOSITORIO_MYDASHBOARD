CREATE OR REPLACE PACKAGE BODY APPS."XX_AGRONOMO_EAM_PKG" AS

  g_request_id          NUMBER := FND_GLOBAL.CONC_REQUEST_ID;

  FUNCTION Run_API ( p_int_header_id            NUMBER
                   , p_operating_unit           NUMBER
                   , p_commit                   VARCHAR2
                   , x_po_header_id      IN OUT NUMBER
                   , x_po_header_number  IN OUT VARCHAR2
                   , x_error_msg         IN OUT VARCHAR2
                   ) RETURN BOOLEAN IS

    CURSOR cIError IS
      SELECT error_message
      FROM po_interface_errors
      WHERE interface_header_id = p_int_header_id;

    d_pkg_name CONSTANT VARCHAR2(255) := 'po.plsql.PO_PDOI_Concurrent.';
    d_api_name CONSTANT VARCHAR2(255) :=  'POXPDOI';
    d_position                  NUMBER;

    l_selected_batch_id         NUMBER;
    l_buyer_id                  NUMBER;
    l_document_type             VARCHAR2(25);
    l_document_subtype          VARCHAR2(25);
    l_create_items              VARCHAR2(1);
    l_create_source_rules_flag  VARCHAR2(1);
    l_approval_status           VARCHAR2(25);
    l_rel_gen_method            VARCHAR2(25);
    l_org_id                    NUMBER := NULL;
    l_ga_flag                   VARCHAR2(1) := NULL;

    --<LOCAL SR/ASL PROJECT START>
    l_sourcing_level            VARCHAR2(50) := NULL;
    l_sourcing_inv_org_id       HR_ALL_ORGANIZATION_UNITS.organization_id%type;
    --<LOCAL SR/ASL PROJECT END>

    --Bug 13343886
    l_batch_size                NUMBER;
    l_gather_stats              VARCHAR2(1);
    --Bug 13343886

    l_return_status             VARCHAR2(1);
    l_msg                       VARCHAR2(2000);
    --CLM PDOI Integration
    l_clm_flag                  VARCHAR2(1) := 'N';
    eError                      EXCEPTION;
  BEGIN
    --FND_GLOBAL.apps_initialize(FND_GLOBAL.User_ID, FND_GLOBAL.Resp_ID, FND_GLOBAL.Resp_appl_ID);
    --FND_GLOBAL.apps_initialize(25677, 50267, 201);

    --FND_CLIENT_INFO.set_org_context(p_operating_unit);

    d_position := 0;

    l_buyer_id           := NULL;
    l_document_type      := 'STANDARD';
    l_document_subtype   := NULL;
    l_create_items       := 'N';
    l_create_source_rules_flag := 'N';

    d_position := 20;

    l_approval_status    := 'INITIATE APPROVAL';
    l_rel_gen_method     := NULL;
    l_selected_batch_id  := NULL;
    l_org_id             := p_operating_unit;
    l_ga_flag            := NULL; --'10';  -- FPI GA

    --<LOCAL SR/ASL PROJECT  START>
    l_sourcing_level      := NULL; --'12';
    l_sourcing_inv_org_id := NULL; --XX_TCG_FUNCTIONS_PKG.getMasterOrg;--'ITEM-ORGANIZATION'; --'14';
    --<LOCAL SR/ASL PROJECT  END>

    --Bug 13343886
    PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE := 5000;
    PO_PDOI_CONSTANTS.g_GATHER_STATS   := 'N';
    --Bug 13343886

    --CLM PDOI Integration
    --For CLM requests CLM Flag(15) is always going to be 'Y'
    --For Commercial requests (15) is going to fetch some random value
    l_clm_flag := 'N';

    d_position := 30;

    PO_PDOI_GRP.start_process
               ( p_api_version          => 1.0
               , p_init_msg_list        => FND_API.G_TRUE
               , p_validation_level     => FND_API.G_VALID_LEVEL_FULL
               , p_commit               => FND_API.G_FALSE
               , x_return_status        => l_return_status
               , p_gather_intf_tbl_stat => FND_API.G_FALSE
               , p_calling_module       => PO_PDOI_CONSTANTS.g_CALL_MOD_CONCURRENT_PRGM
               , p_selected_batch_id    => l_selected_batch_id
               , p_batch_size           => PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE
               , p_buyer_id             => l_buyer_id
               , p_document_type        => l_document_type
               , p_document_subtype     => l_document_subtype
               , p_create_items         => l_create_items
               , p_create_sourcing_rules_flag => l_create_source_rules_flag
               , p_rel_gen_method       => l_rel_gen_method
               , p_sourcing_level       => l_sourcing_level
               , p_sourcing_inv_org_id  => l_sourcing_inv_org_id
               , p_approved_status      => l_approval_status
               , p_process_code         => PO_PDOI_CONSTANTS.g_process_code_PENDING
               , p_interface_header_id  => p_int_header_id -- Interface Header ID generado previamente
               , p_org_id               => p_operating_unit
               , p_ga_flag              => l_ga_flag
               , p_clm_flag             => l_clm_flag
               );

    IF l_return_status != FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    BEGIN
      SELECT ph.po_header_id, ph.segment1
      INTO x_po_header_id, x_po_header_number
      FROM po_headers_interface hi
         , po_headers_all       ph
      WHERE 1=1
      AND ph.po_header_id = hi.po_header_id
      AND hi.interface_header_id = p_int_header_id
      ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FOR r IN cIError LOOP
          x_error_msg := x_error_msg||' '||r.error_message;
        END LOOP;

        RETURN FALSE;
    END;

    RETURN TRUE;
    DBMS_OUTPUT.PUT_LINE('Proceso finalizado OK. hdr_id:'||x_po_header_id||' OC Number: '||x_po_header_number);

  EXCEPTION
    WHEN OTHERS THEN
      PO_MESSAGE_S.add_exc_msg
      ( p_pkg_name => d_pkg_name,
        p_procedure_name => d_api_name || '.' || d_position
      );

      FOR i IN 1..FND_MSG_PUB.COUNT_MSG LOOP
        l_msg := FND_MSG_PUB.get
                 ( p_msg_index => i,
                   p_encoded => FND_API.G_FALSE
                 );

        DBMS_OUTPUT.PUT_LINE('Error: '||l_msg);
        x_error_msg := x_error_msg || l_msg ||' ';
      END LOOP;
      RETURN FALSE;
  END;


  PROCEDURE Finalizar_WO IS
    CURSOR cServ IS

      SELECT DISTINCT
             e.*
           , od.operating_unit
           , od.organization_name
           , wo.scheduled_start_date
           , wo.scheduled_completion_date
      FROM xx_agronomo_eam_int e
         , org_organization_definitions od
         , eam_work_orders_v   wo
      WHERE 1=1
      AND od.organization_id = e.organizacion_id
      AND wo.wip_entity_id   = e.wip_entity_id
      AND wo.organization_id = e.organizacion_id
      AND e.importado_flag   = 'Y'
      AND e.cerrado_flag     = 'Y'
      AND e.completado_flag != 'Y'
      AND wo.work_order_status != 'Complete'
      AND e.request_id       = g_request_id
      AND NOT EXISTS (SELECT DISTINCT 1 FROM xx_agronomo_eam_oc_int eoc WHERE eoc.servicio = e.servicio AND eoc.importado_flag != 'Y')
      AND NOT EXISTS (SELECT DISTINCT 1 FROM xx_agronomo_eam_inv_int einv WHERE einv.servicio = e.servicio AND einv.importado_flag != 'Y')
      ORDER BY od.operating_unit, e.servicio
      ;

    --EAM Interface params
    d_pkg_name CONSTANT VARCHAR2(255) := 'EAM_WORKORDERTRANSACTIONS_PUB';
    d_api_name CONSTANT VARCHAR2(255) := 'COMPLETE_WORK_ORDER';

    l_inventory_rec         EAM_WORKORDERTRANSACTIONS_PUB.INVENTORY_ITEM_REC_TYPE;
    l_attributes_rec        EAM_WORKORDERTRANSACTIONS_PUB.ATTRIBUTES_REC_TYPE;
    l_inventory_item_tbl    EAM_WORKORDERTRANSACTIONS_PUB.INVENTORY_ITEM_TBL_TYPE;

    x_return_status         VARCHAR2(4000);
    x_msg_data              VARCHAR2(4000);
    x_msg_count             NUMBER;

    l_msg_index             NUMBER;
    l_msg_data              VARCHAR2(4000);
    --
    l_rc                    NUMBER;
    l_error_message         VARCHAR2(2000);
    --
    l_organization_id       NUMBER;
    l_ou                    NUMBER;
    --
    eWOError                EXCEPTION;
  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Completando WOs');

    FOR rServ IN cServ LOOP
      l_error_message  := NULL;
      l_attributes_rec := NULL;
      l_inventory_rec  := NULL;
      l_inventory_item_tbl(1) := l_inventory_rec;

      BEGIN
        IF NVL(l_ou, -99) != rServ.operating_unit THEN
          l_ou := rServ.operating_unit;

          FND_GLOBAL.apps_initialize(FND_GLOBAL.USER_ID, FND_GLOBAL.RESP_ID, FND_GLOBAL.RESP_APPL_ID);

          FND_CLIENT_INFO.set_org_context(l_ou);
        END IF;

        EAM_WORKORDERTRANSACTIONS_PUB.COMPLETE_WORK_ORDER
        ( p_api_version          => 1.0
        , p_init_msg_list        => FND_API.G_FALSE
        , p_commit               => FND_API.G_FALSE
        , x_return_status        => x_return_status
        , x_msg_count            => x_msg_count
        , x_msg_data             => x_msg_data
        , p_wip_entity_id        => rServ.wip_entity_id
        , p_transaction_type     => EAM_WORKORDERTRANSACTIONS_PUB.G_TXN_TYPE_COMPLETE
        , p_transaction_date     => SYSDATE
        , p_user_id              => FND_GLOBAL.USER_ID
        , p_actual_start_date    => rServ.scheduled_start_date
        , p_actual_end_date      => rServ.scheduled_completion_date
        , p_inventory_item_info  => l_inventory_item_tbl
        , p_reference            => 'Referencia'
        , p_reason               => 'Finalizacion x API'
        , p_attributes_rec       => l_attributes_rec
        );


        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
          UPDATE XX_AGRONOMO_EAM_INT
          SET completado_flag = 'Y'
            , mensaje_error   = NULL
          WHERE servicio = rServ.servicio;

          l_rc := cServ%ROWCOUNT;
        ELSE
          IF (x_msg_count > 0) THEN
            l_msg_index := x_msg_count;
            FOR i IN 1 .. x_msg_count LOOP
              FND_MSG_PUB.get( p_msg_index     => FND_MSG_PUB.G_NEXT
                             , p_encoded       => 'F'
                             , p_data          => l_msg_data
                             , p_msg_index_out => l_msg_index);

              IF i = 1 THEN
                l_error_message := 'Error '||l_msg_index||' : '||l_msg_data;
              ELSE
                l_error_message := l_error_message||'. Error '||l_msg_index||' : '||l_msg_data;
              END IF;
            END LOOP;
          END IF;

          RAISE eWOError;
        END IF;

      EXCEPTION
        WHEN eWOError THEN
          UPDATE XX_AGRONOMO_EAM_INT
          SET completado_flag = 'E'
            , mensaje_error = l_error_message
          WHERE servicio = rServ.servicio;

      END;

    END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Se finalizaron '||l_rc||' Pedidos de Trabajo.');
    COMMIT;

    FND_FILE.PUT_LINE(FND_FILE.LOG, '- Finalizar WOs');
  END Finalizar_WO;


  PROCEDURE Genera_Inv ( p_modo_ejecucion VARCHAR2 ) IS

    CURSOR cTrx ( p_trx_name VARCHAR2 ) IS
      SELECT mst.transaction_source_type_id
           , mst.transaction_source_type_name
           , mtt.transaction_type_id
           , mtt.transaction_type_name
           , mtt.transaction_action_id
           , lv.meaning  transaction_action_name
      FROM mtl_txn_source_types  mst
         , mtl_transaction_types mtt
         , fnd_lookup_values     lv
      WHERE 1=1
      AND mtt.transaction_source_type_id = mst.transaction_source_type_id
      AND lv.lookup_code  = mtt.transaction_action_id
      AND lv.lookup_type  = 'MTL_TRANSACTION_ACTION'
      AND mst.transaction_source_type_name = 'Job or Schedule'
      AND lv.language     = 'ESA'
      --AND mtt.transaction_type_id IN (35, 43)
      AND mtt.transaction_type_name = p_trx_name
      AND TRUNC(NVL(mtt.disable_date, SYSDATE+1)) > TRUNC(SYSDATE)
      ;

    CURSOR cInv IS

      SELECT e.*
           , od.operating_unit
           , od.organization_name
           , ei.mov_insumo_id
           , ei.fecha
           , ei.subinventario
           , ei.localizador
           , ei.cantidad
           , ei.impacto
           , ei.producto
           , ei.em_subsistema_id
           , we.entity_type
      FROM xx_agronomo_eam_int     e
         , xx_agronomo_eam_inv_int ei
         , org_organization_definitions od
         , wip_entities            we
      WHERE 1=1
      AND ei.servicio      = e.servicio
      AND we.wip_entity_id = e.wip_entity_id
      AND od.organization_id = e.organizacion_id
      AND ei.importado_flag IN ('N', 'P', 'R')
      AND e.request_id     = g_request_id
      ORDER BY od.operating_unit, e.servicio, ei.mov_insumo_id
      ;

    rTrx                  cTrx%ROWTYPE;
    rMTI                  MTL_TRANSACTIONS_INTERFACE%ROWTYPE;
    l_trx_int_id          NUMBER;
    l_rc                  NUMBER;

    l_organization_id     NUMBER;
    l_item_id             NUMBER;
    l_uom                 VARCHAR2(50);
    l_reason_id           NUMBER;
    l_trx_source_type_id  NUMBER;
    l_trx_type_id         NUMBER;
    l_trx_action_id       NUMBER;
    l_locator_id          NUMBER;
    l_subinventario       VARCHAR2(50);
    l_quantity            NUMBER;

    l_error_message       VARCHAR2(2000);
    eLineError            EXCEPTION;
  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Generando movimientos de INV');

    UPDATE XX_AGRONOMO_EAM_INV_INT
    SET subinventario = DECODE(subinventario, 'null', NULL)
      , localizador   = DECODE(localizador, 'null', NULL)
    WHERE 1=1
    AND request_id = g_request_id;

    FOR rInv IN cInv LOOP
      l_error_message  := NULL;
      rMTI     := NULL;
      rTrx     := NULL;

      BEGIN
        BEGIN
          SELECT organization_id
          INTO l_organization_id
          FROM org_organization_definitions
          WHERE organization_id = rInv.organizacion_id
          ;
        EXCEPTION
          WHEN OTHERS THEN
            l_error_message := 'No fue posible encontrar organization_id ('||rInv.organizacion_id||').';
            RAISE eLineError;
        END;

        BEGIN
          SELECT inventory_item_id, primary_uom_code--, lot_control_code
          INTO l_item_id, l_uom--, l_lot_ctrl
          FROM mtl_system_items
          WHERE 1=1
          AND organization_id = l_organization_id
          AND segment1        = rInv.producto
          ;
        EXCEPTION
          WHEN OTHERS THEN
            l_error_message := 'No fue posible encontrar el producto ('||rInv.producto||') en la organización ('||l_organization_id||').';
            RAISE eLineError;
        END;

        /*IF l_lot_ctrl = 2 AND
           r1.producto_lote IS NULL THEN
          l_error_message := 'El producto ('||r1.producto_numero||') controla lote y el mismo no fue informado.';
          RAISE eLineError;
        END IF;*/

        BEGIN
          SELECT secondary_inventory_name
          INTO l_subinventario
          FROM mtl_secondary_inventories
          WHERE 1=1
          AND secondary_inventory_name = NVL(rInv.subinventario, 'REPUESTOS')
          AND organization_id = l_organization_id
          ;
        EXCEPTION
          WHEN OTHERS THEN
            l_error_message := 'No fue posible encontrar subinventario ('||NVL(rInv.subinventario, 'REPUESTOS')||').';
            RAISE eLineError;
        END;

        BEGIN
          SELECT inventory_location_id
          INTO l_locator_id
          FROM mtl_item_locations
          WHERE segment1      = NVL(rInv.localizador, 'REP G')
          AND organization_id = l_organization_id
          ;
        EXCEPTION
          WHEN OTHERS THEN
            l_error_message := 'No fue posible encontrar localizador ('||NVL(rInv.localizador, 'REP G')||').';
            RAISE eLineError;
        END;

        BEGIN
          SELECT reason_id
          INTO l_reason_id
          FROM mtl_transaction_reasons
          WHERE reason_name = 'CREP';
        EXCEPTION
          WHEN OTHERS THEN
            l_error_message := 'No fue posible encontrar motivo CREP.';
            RAISE eLineError;
        END;

        IF rInv.impacto = 1 THEN
          OPEN cTrx ('WIP Issue');
          l_quantity := ABS(rInv.cantidad) * -1;
        ELSIF rInv.impacto = -1 THEN
          OPEN cTrx ('WIP Return');
          l_quantity := ABS(rInv.cantidad);
        END IF;

        FETCH cTrx INTO rTrx;
        l_trx_source_type_id := rTrx.transaction_source_type_id;
        l_trx_type_id   := rTrx.transaction_type_id;
        l_trx_action_id := rTrx.transaction_action_id;
        CLOSE cTrx;

        IF l_trx_type_id IS NULL THEN
          l_error_message := 'No fue posible encontrar tipo de transaccion.';
          RAISE eLineError;
        END IF;

        IF p_modo_ejecucion = 'F' THEN
          SELECT mtl_material_transactions_s.NEXTVAL
          INTO l_trx_int_id
          FROM DUAL;

          --MTL_TRANSACTIONS_INTERFACE
          rMTI.transaction_interface_id := l_trx_int_id;
          rMTI.source_line_id           := -1;
          rMTI.source_header_id         := -1;
          --
          rMTI.source_code              := 'Job or Schedule';
          rMTI.transaction_source_type_id := l_trx_source_type_id;
          rMTI.transaction_type_id      := l_trx_type_id;
          rMTI.transaction_action_id    := l_trx_action_id;
          rMTI.reason_id                := l_reason_id;
          rMTI.attribute_category       := l_reason_id;
          --
          rMTI.transaction_mode         := 3; --Background
          rMTI.lock_flag                := 2; --NO
          rMTI.process_flag             := 1; --YES
          --
          rMTI.transaction_uom          := l_uom;
          rMTI.transaction_date         := SYSDATE;
          rMTI.inventory_item_id        := l_item_id;
          rMTI.transaction_quantity     := l_quantity;
          --Desde
          rMTI.organization_id          := l_organization_id;
          rMTI.subinventory_code        := l_subinventario;
          rMTI.locator_id               := l_locator_id;
          rMTI.transaction_reference    := rInv.descripcion;
          --WO
          rMTI.transaction_source_id    := rInv.wip_entity_id;
          rMTI.wip_entity_type          := rInv.entity_type;
          rMTI.operation_seq_num        := rInv.em_subsistema_id;
          --WHO
          rMTI.created_by       := FND_GLOBAL.User_ID;
          rMTI.creation_date    := SYSDATE;
          rMTI.last_updated_by  := FND_GLOBAL.User_ID;
          rMTI.last_update_date := SYSDATE;

          INSERT INTO MTL_TRANSACTIONS_INTERFACE VALUES rMTI;

        END IF;

        UPDATE XX_AGRONOMO_EAM_INV_INT
        SET importado_flag = DECODE(p_modo_ejecucion, 'F', 'Y', p_modo_ejecucion)
          , transaction_interface_id = l_trx_int_id
          , mensaje_error  = NULL
        WHERE 1=1
        AND servicio = rInv.servicio
        AND mov_insumo_id = rinv.mov_insumo_id;

        l_rc := cInv%ROWCOUNT;
      --
      EXCEPTION
        WHEN eLineError THEN
          UPDATE XX_AGRONOMO_EAM_INV_INT
          SET importado_flag  = 'E'
            , transaction_interface_id = NULL
            , mensaje_error = l_error_message
          WHERE 1=1
          AND servicio = rInv.servicio
          AND mov_insumo_id = rinv.mov_insumo_id;
      END;

    END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Se insertaron '||l_rc||' registros en interface de Inventario.');
    COMMIT;

    FND_FILE.PUT_LINE(FND_FILE.LOG, '- Generando movimientos de INV');
  END Genera_Inv;


  PROCEDURE Genera_OC ( p_modo_ejecucion VARCHAR2 ) IS

    CURSOR cServ IS

      SELECT DISTINCT
             e.*
           , od.operating_unit
           , od.organization_name
      FROM xx_agronomo_eam_int          e
         , xx_agronomo_eam_oc_int       eoc
         , org_organization_definitions od
      WHERE 1=1
      AND eoc.servicio       = e.servicio
      AND od.organization_id = e.organizacion_id
      AND eoc.importado_flag IN ('N', 'P', 'R')
      AND e.wip_entity_id  IS NOT NULL
      AND e.request_id     = g_request_id
      ORDER BY od.operating_unit, e.servicio
      ;

    CURSOR cH ( p_servicio NUMBER ) IS

      SELECT eoc.proveedor_id, eoc.moneda, MAX(eoc.po_header_id) po_header_id
      FROM xx_agronomo_eam_oc_int eoc
      WHERE 1=1
      AND eoc.importado_flag IN ('N', 'P', 'R')
      AND eoc.request_id     = g_request_id
      AND eoc.servicio       = p_servicio
      GROUP BY eoc.proveedor_id, eoc.moneda
      ORDER BY eoc.proveedor_id
      ;

    CURSOR cL ( p_servicio     NUMBER
              , p_proveedor_id NUMBER
              , p_moneda       VARCHAR2
              ) IS

      SELECT eoc.*
      FROM xx_agronomo_eam_oc_int eoc
      WHERE 1=1
      AND eoc.importado_flag IN ('N', 'P', 'R')
      AND eoc.request_id   = g_request_id
      AND eoc.servicio     = p_servicio
      AND eoc.proveedor_id = p_proveedor_id
      AND eoc.moneda       = p_moneda
      ORDER BY eoc.servicio_tercero_id
      ;


    CURSOR cVS ( p_operating_unit  NUMBER
               , p_productor_id    NUMBER
               ) IS

      SELECT vs.vendor_site_id
      FROM ap_suppliers        s
         , po_vendor_sites_all vs
         , hz_party_site_uses  hpsu
      WHERE 1=1
      AND vs.vendor_id = s.vendor_id
      AND NVL(vs.inactive_date, SYSDATE+1) > TRUNC(SYSDATE)
      AND vs.org_id    = p_operating_unit
      AND s.vendor_id  = p_productor_id
      AND hpsu.site_use_type = 'PURCHASING'
      AND hpsu.status = 'A'
      AND nvl(vs.PURCHASING_SITE_FLAG,'X') = 'Y'
      AND vs.party_site_id = hpsu.party_site_id
      ;


    l_dummy_chr           VARCHAR2(500);
    l_dummy_num           NUMBER;

    l_progress            VARCHAR2(10);
    l_int_header_id       NUMBER;
    l_int_line_id         NUMBER;
    l_batch_id            NUMBER;

    --Campos comunes
    l_attribute_category  VARCHAR2(5) := 'AR';

    --Campos para la cabecera
    l_organization_id     NUMBER;
    l_agent_id            NUMBER;
    l_doc_type            VARCHAR2(10)  := 'STANDARD';
    -- Proveedor
    l_vendor_id           NUMBER;
    l_vendor_site_id      NUMBER;
    l_ship_to_location_id NUMBER;
    l_bill_to_location_id NUMBER;

    --Campos para las lineas
    l_line_type_id        NUMBER := 1020; --Servicios GOODS QUANTITY
    l_item_id             NUMBER;
    l_item_desc           VARCHAR2(250);
    l_uom_code            VARCHAR2(50);
    l_category_id         NUMBER;

    --Campos para las distribuciones
    l_cc_id               NUMBER;
    l_segment_un          VARCHAR2(50);
    l_currency            VARCHAR2(50);

    l_po_header_id        NUMBER;
    l_po_header_number    VARCHAR2(50);

    l_rc                  NUMBER;
    l_ln                  NUMBER;
    l_ou                  NUMBER;
    l_resp_id             NUMBER;
    l_resp_appl_id        NUMBER;

    l_cantidad            NUMBER := 1;

    l_error_message       VARCHAR2(2000);
    eServError            EXCEPTION;
    eHeaderError          EXCEPTION;
    eLineError            EXCEPTION;
    eAPIError             EXCEPTION;
  BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Generando OCs');
    FOR rServ IN cServ LOOP
      l_error_message  := NULL;

      BEGIN
        BEGIN
          IF NVL(l_ou, -99) != rServ.operating_unit THEN
            l_ou := rServ.operating_unit;

            SELECT r.responsibility_id, r.application_id
            INTO l_resp_id, l_resp_appl_id
            FROM fnd_profile_option_values pov
               , fnd_profile_options_vl    po
               , fnd_responsibility_vl     r
            WHERE 1=1
            AND po.profile_option_id = pov.profile_option_id
            AND po.application_id    = pov.application_id
            AND po.profile_option_name = 'ORG_ID'
            AND pov.level_value      = r.responsibility_id
            AND UPPER(r.responsibility_name) like UPPER('% PO Super User %')
            AND TO_NUMBER(pov.profile_option_value) = l_ou;

            FND_GLOBAL.apps_initialize(FND_GLOBAL.User_ID, l_resp_id, l_resp_appl_id);

            FND_CLIENT_INFO.set_org_context(l_ou);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            l_error_message := 'El usuario no cuenta con la responsabilidad asociada para la unidad operativa ('||l_ou||').';
            RAISE eServError;
        END;

        FOR rH IN cH ( rServ.servicio ) LOOP
          l_error_message  := NULL;
          l_po_header_id   := NULL;
          l_vendor_id      := rH.proveedor_id;
          l_currency       := rH.moneda;
          BEGIN
            SELECT cancel_flag
            INTO l_dummy_chr
            FROM po_headers_all ph
            WHERE ph.po_header_id = rH.po_header_id
            ;

            IF l_dummy_chr != 'Y' THEN
              l_error_message := 'Existe una OC generada para el servicio ('||rServ.servicio||') proveedor ('||rH.proveedor_id||') y la misma no ha sido cancelada.';
              RAISE eHeaderError;
            END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              NULL;
            WHEN OTHERS THEN
              l_error_message := 'No fue posible validar estado de la OC para el servicio ('||rServ.servicio||')  proveedor ('||rH.proveedor_id||').';
              RAISE eHeaderError;
          END;

          BEGIN
            SELECT organization_id
            INTO l_organization_id
            FROM org_organization_definitions
            WHERE organization_id = rServ.organizacion_id
            ;
          EXCEPTION
            WHEN OTHERS THEN
              l_error_message := 'No fue posible encontrar organization_id ('||rServ.organizacion_id||').';
              RAISE eHeaderError;
          END;

          -- Comprador
          BEGIN
            SELECT agent_id
            INTO l_dummy_num
            FROM po_agents
            WHERE agent_id = rServ.comprador_id;

            l_agent_id := l_dummy_num;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_error_message := 'No fue posible obtener comprador ('||rServ.comprador_id||').';
              RAISE eHeaderError;
          END;

          -- Productor
          BEGIN
            SELECT vendor_id
            INTO l_vendor_id
            FROM ap_suppliers
            WHERE 1=1
            AND NVL(end_date_active, SYSDATE+1) > TRUNC(SYSDATE)
            AND vendor_id = rH.proveedor_id
            ;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_error_message := 'El proveedor ('||rH.proveedor_id||') se encuentra deshabilitado.';
              RAISE eHeaderError;
          END;

          OPEN cVS (l_ou, l_vendor_id);
          FETCH cVS INTO l_vendor_site_id;
          IF cVS%NOTFOUND THEN
            CLOSE cVS;
            l_error_message := 'No se encontró Sucursal de compra activa del Depositante para la Unidad operativa'; -- CR1991 - Validaciones previas a la generación de la OC
            RAISE eHeaderError;
          END IF;
          CLOSE cVS;

          BEGIN
            SELECT location_id
            INTO l_ship_to_location_id
            FROM hr_locations
            WHERE location_code = rServ.direccion_envio;
          EXCEPTION
            WHEN OTHERS THEN
              l_error_message := 'No fue posible encontrar dirección de envío ('||rServ.direccion_envio||').';
              RAISE eHeaderError;
          END;

          /*BEGIN
            SELECT location_id
            INTO l_bill_to_location_id
            FROM hr_locations
            WHERE location_code = rOCh.direccion_facturacion;
          EXCEPTION
            WHEN OTHERS THEN
              l_error_message := 'No fue posible encontrar dirección de envío ('||rOCh.direccion_facturacion||').';
              RAISE eHeaderError;
          END;*/

          IF p_modo_ejecucion = 'F' THEN
            l_progress := 'IDs';
            SELECT NVL(MAX(batch_id),0)+1
            INTO l_batch_id
            FROM po_headers_interface;
            --DBMS_OUTPUT.PUT_LINE('Batch ID: '||l_batch_id);

            SELECT po_headers_interface_s.NEXTVAL
            INTO l_int_header_id
            FROM DUAL;
            --DBMS_OUTPUT.PUT_LINE('Interface Header ID: '||l_int_header_id);

            l_progress := 'intHeader';
            INSERT INTO PO.PO_HEADERS_INTERFACE
            ( INTERFACE_HEADER_ID
            , BATCH_ID
            , PROCESS_CODE
            , ACTION
            , ATTRIBUTE_CATEGORY
            , ORG_ID
            , COMMENTS
            , DOCUMENT_TYPE_CODE
            , CURRENCY_CODE
            , AGENT_ID
            , VENDOR_ID
            , VENDOR_SITE_ID
            , SHIP_TO_LOCATION_ID
            , APPROVAL_REQUIRED_FLAG
            , APPROVAL_STATUS
            , CREATION_DATE
            )
            VALUES
            ( l_int_header_id --  INTERFACE_HEADER_ID
            , l_batch_id
            , 'PENDING'  --  PROCESS_CODE
            , 'ORIGINAL' --  ACTION
            , l_attribute_category
            , l_ou
            , rServ.descripcion
            , l_doc_type
            , rH.moneda
            , l_agent_id
            , l_vendor_id
            , l_vendor_site_id
            , l_ship_to_location_id
            , 'Y'        -- APPROVAL_REQUIRED_FLAG
            , 'INCOMPLETE' -- APPROVAL_STATUS
            , SYSDATE    --  CREATION_DATE
            );


            l_ln := 1;
          END IF;

          FOR rL IN cL ( rServ.servicio
                       , rH.proveedor_id
                       , rH.moneda
                       ) LOOP

            BEGIN

              BEGIN
                SELECT si.inventory_item_id, si.description, si.primary_uom_code, ic.category_id
                INTO l_item_id, l_item_desc, l_uom_code, l_category_id
                FROM mtl_system_items      si
                   , mtl_item_categories_v ic
                WHERE 1=1
                AND ic.organization_id = si.organization_id
                AND ic.inventory_item_id = si.inventory_item_id
                AND ic.category_set_name = 'Inventory'
                AND si.organization_id = l_organization_id
                AND si.segment1        = rL.producto
                ;
              EXCEPTION
                WHEN OTHERS THEN
                  l_error_message := 'No fue posible encontrar la categoria del producto ('||rL.producto||').';
                  RAISE eLineError;
              END;

              IF p_modo_ejecucion = 'F' THEN

                l_progress := 'intLines';
                l_int_line_id := po_lines_interface_s.nextval;
                INSERT INTO PO.PO_LINES_INTERFACE
                ( INTERFACE_HEADER_ID
                , INTERFACE_LINE_ID
                , ACTION
                , LINE_NUM
                , LINE_TYPE_ID
                , CATEGORY_ID
                , ITEM_ID
                , ITEM_DESCRIPTION
                , UOM_CODE
                , QUANTITY
                , UNIT_PRICE
                , ORGANIZATION_ID
                , SHIP_TO_ORGANIZATION_ID
                , SHIP_TO_LOCATION_ID
                , PROMISED_DATE
                , NEED_BY_DATE
                , LINE_ATTRIBUTE_CATEGORY_LINES
                , CREATION_DATE
                ) VALUES
                ( l_int_header_id -- INTERFACE_HEADER_ID
                , l_int_line_id   -- INTERFACE_LINE_ID
                , 'ADD'           --  ACTION
                , l_ln            -- LINE_NUM
                , l_line_type_id
                , l_category_id
                , l_item_id
                , l_item_desc
                , l_uom_code
                , l_cantidad
                , rL.precio
                , l_organization_id
                , l_organization_id
                , l_ship_to_location_id
                , TRUNC(SYSDATE)
                , TRUNC(SYSDATE)
                , 'AR'
                , SYSDATE -- CREATION_DATE,
                );

                l_progress := 'intDistrib';
                INSERT INTO PO.PO_DISTRIBUTIONS_INTERFACE
                ( INTERFACE_HEADER_ID
                , INTERFACE_LINE_ID
                , INTERFACE_DISTRIBUTION_ID
                , DISTRIBUTION_NUM
                , QUANTITY_ORDERED
                , ATTRIBUTE_CATEGORY
                , DESTINATION_TYPE_CODE
                , WIP_ENTITY_ID
                , WIP_OPERATION_SEQ_NUM
                , CREATION_DATE
                ) VALUES
                ( l_int_header_id     -- INTERFACE_HEADER_ID
                , l_int_line_id       -- INTERFACE_LINE_ID
                , po_distributions_interface_s.NEXTVAL
                , l_ln                -- DISTRIBUTION_NUM
                , l_cantidad
                , 'AR'
                , 'SHOP FLOOR'
                , rServ.wip_entity_id
                , rL.em_subsistema_id
                , SYSDATE -- CREATION_DATE,
                );
              END IF;

              l_ln := l_ln + 1;
            EXCEPTION
              WHEN eLineError THEN
                UPDATE XX_AGRONOMO_EAM_OC_INT
                SET importado_flag  = 'E'
                  , mensaje_error = l_error_message
                WHERE 1=1
                AND servicio   = rServ.servicio
                AND servicio_tercero_id = rL.servicio_tercero_id
                AND request_id = g_request_id
                ;

                RAISE eHeaderError;
            END;
          END LOOP;

          IF p_modo_ejecucion = 'F' THEN
            BEGIN
              IF NOT Run_API ( p_int_header_id     => l_int_header_id
                             , p_operating_unit    => l_ou
                             , p_commit            => FND_API.G_FALSE
                             , x_po_header_id      => l_po_header_id
                             , x_po_header_number  => l_po_header_number
                             , x_error_msg         => l_error_message
                             ) THEN
                l_po_header_id  := NULL;
                l_po_header_number := NULL;

                DELETE po_headers_interface WHERE interface_header_id = l_int_header_id;
                DELETE po_lines_interface WHERE interface_header_id = l_int_header_id;
                DELETE po_distributions_interface WHERE interface_header_id = l_int_header_id;
                DELETE po_interface_errors WHERE interface_header_id = l_int_header_id;

                RAISE eAPIError;
              END IF;

              BEGIN
                SELECT segment3
                INTO l_segment_un
                FROM gl_code_combinations
                WHERE code_combination_id =
                ( SELECT variance_account_id
                  FROM po_distributions_all
                  WHERE po_header_id = l_po_header_id
                );

                UPDATE po_lines_all
                SET attribute2 = l_segment_un
                WHERE po_header_id = l_po_header_id;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;

            EXCEPTION
              WHEN eAPIError THEN
                RAISE eHeaderError;
            END;
          END IF;

          UPDATE XX_AGRONOMO_EAM_OC_INT
          SET importado_flag = DECODE(p_modo_ejecucion, 'F', 'Y', p_modo_ejecucion)
            , po_header_id   = l_po_header_id
            , mensaje_error  = NULL
          WHERE 1=1
          AND servicio = rServ.servicio
          AND proveedor_id = rH.proveedor_id
          AND moneda       = rH.moneda
          AND request_id   = g_request_id;

          l_rc := NVL(l_rc,0) + 1;
        END LOOP;

      EXCEPTION
        WHEN eServError THEN
          UPDATE XX_AGRONOMO_EAM_OC_INT
          SET importado_flag  = 'E'
            , mensaje_error = l_error_message
          WHERE 1=1
          AND servicio   = rServ.servicio
          AND request_id = g_request_id
          ;

        WHEN eHeaderError THEN
          UPDATE XX_AGRONOMO_EAM_OC_INT
          SET importado_flag  = 'E'
            , mensaje_error = l_error_message
          WHERE 1=1
          AND servicio = rServ.servicio
          AND proveedor_id = l_vendor_id
          AND moneda       = l_currency
          AND request_id   = g_request_id
          ;
      END;

    END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Se crearon '||l_rc||' Ordenes de Compra.');
    COMMIT;

    FND_FILE.PUT_LINE(FND_FILE.LOG, '- Generando OCs');

  END Genera_OC;


  PROCEDURE Check_Operation IS
    CURSOR cServ IS
      SELECT DISTINCT aop.servicio, aop.organizacion_id, aop.fecha_inicio, aop.fecha_fin, aop.wip_entity_id, wo.wip_entity_name
      FROM eam_work_orders_v wo,
      ( SELECT DISTINCT e.servicio, e.wip_entity_id, e.organizacion_id, e.fecha_inicio, e.fecha_fin, eoc.em_subsistema_id
        FROM xx_agronomo_eam_int          e
           , xx_agronomo_eam_oc_int       eoc
        WHERE 1=1
        AND eoc.servicio     = e.servicio
        AND e.wip_entity_id  IS NOT NULL
        AND e.request_id     = g_request_id
        UNION
        SELECT DISTINCT e.servicio, e.wip_entity_id, e.organizacion_id, e.fecha_inicio, e.fecha_fin, ei.em_subsistema_id
        FROM xx_agronomo_eam_int     e
           , xx_agronomo_eam_inv_int ei
        WHERE 1=1
        AND ei.servicio      = e.servicio
        AND e.wip_entity_id  IS NOT NULL
        AND e.request_id     = g_request_id
      ) aop
      WHERE 1=1
      AND wo.wip_entity_id = aop.wip_entity_id
      AND NOT EXISTS (SELECT 1 FROM wip_operations_v wo
                      WHERE wo.wip_entity_id = aop.wip_entity_id
                      AND wo.operation_code  = 'SU'||aop.em_subsistema_id)
      ORDER BY 1;

    CURSOR cOper ( p_servicio NUMBER ) IS
      SELECT DISTINCT em_subsistema_id
      FROM
      ( SELECT DISTINCT e.servicio, e.wip_entity_id, eoc.em_subsistema_id
        FROM xx_agronomo_eam_int          e
           , xx_agronomo_eam_oc_int       eoc
        WHERE 1=1
        AND eoc.servicio     = e.servicio
        AND e.wip_entity_id  IS NOT NULL
        AND e.servicio       = p_servicio
        AND e.request_id     = g_request_id
        UNION
        SELECT DISTINCT e.servicio, e.wip_entity_id, ei.em_subsistema_id
        FROM xx_agronomo_eam_int     e
           , xx_agronomo_eam_inv_int ei
        WHERE 1=1
        AND ei.servicio      = e.servicio
        AND e.wip_entity_id  IS NOT NULL
        AND e.servicio       = p_servicio
        AND e.request_id     = g_request_id
      ) aop
      WHERE NOT EXISTS (SELECT 1 FROM wip_operations_v wo
                        WHERE wo.wip_entity_id = aop.wip_entity_id
                        AND wo.operation_code  = 'SU'||aop.em_subsistema_id)
      ORDER BY aop.em_subsistema_id;

    --EAM Interface params
    d_pkg_name CONSTANT VARCHAR2(255) := 'EAM_PROCESS_WO_PUB';
    d_api_name CONSTANT VARCHAR2(255) := 'EAMPWOPB';

    l_eam_wo_rec                EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_eam_op_rec                EAM_PROCESS_WO_PUB.eam_op_rec_type;
    l_eam_op_tbl                EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_eam_op_network_tbl        EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_eam_res_tbl               EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_eam_res_inst_tbl          EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_eam_sub_res_tbl           EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_eam_res_usage_tbl         EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_eam_mat_req_tbl           EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_out_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_out_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_out_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_out_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_out_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_out_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_out_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_out_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_out_eam_direct_items_tbl  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    x_eam_wo_rec                EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    x_eam_op_tbl                EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    x_eam_op_network_tbl        EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    x_eam_res_tbl               EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    x_eam_res_inst_tbl          EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    x_eam_sub_res_tbl           EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    x_eam_res_usage_tbl         EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    x_eam_mat_req_tbl           EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    x_eam_direct_items_tbl      EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

    x_return_status             VARCHAR2(4000);
    x_msg_count                 NUMBER;

    l_msg_index                 NUMBER;
    l_msg_data                  VARCHAR2(4000);
    --

    l_rc                        NUMBER := 0;
    l_error_message             VARCHAR2(2000);

    eWOError       EXCEPTION;

  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Generando Operaciones de WOs');


    FOR rServ IN cServ LOOP
      l_error_message := NULL;
      l_eam_wo_rec    := NULL;
      l_eam_op_tbl.delete;

      BEGIN

        FOR rOper IN cOper (rServ.servicio) LOOP
          l_eam_op_rec := NULL;
          l_eam_op_rec.transaction_type  := EAM_PROCESS_WO_PVT.G_OPR_CREATE;
          l_eam_op_rec.wip_entity_id     := rServ.wip_entity_id;
          l_eam_op_rec.organization_id   := rServ.organizacion_id;
          l_eam_op_rec.operation_seq_num := rOper.em_subsistema_id;
          l_eam_op_rec.start_date        := rServ.fecha_inicio;
          l_eam_op_rec.completion_date   := rServ.fecha_fin;

          SELECT standard_operation_id, operation_description, department_id
          INTO l_eam_op_rec.standard_operation_id, l_eam_op_rec.description, l_eam_op_rec.department_id
          FROM bom_standard_operations_v
          WHERE 1=1
          AND organization_id = rServ.organizacion_id
          AND operation_code  = 'SU'||rOper.em_subsistema_id;

          l_eam_op_tbl(cOper%ROWCOUNT) := l_eam_op_rec;
        END LOOP;

        EAM_PROCESS_WO_PUB.PROCESS_WO
        ( p_bo_identifier        => 'EAM'
        , p_api_version_number   => 1.0
        , p_init_msg_list        => TRUE
        , p_commit               => 'N'
        , p_eam_wo_rec           => l_eam_wo_rec
        , p_eam_op_tbl           => l_eam_op_tbl
        , p_eam_op_network_tbl   => l_eam_op_network_tbl
        , p_eam_res_tbl          => l_eam_res_tbl
        , p_eam_res_inst_tbl     => l_eam_res_inst_tbl
        , p_eam_sub_res_tbl      => l_eam_sub_res_tbl
        , p_eam_res_usage_tbl    => l_eam_res_usage_tbl
        , p_eam_mat_req_tbl      => l_eam_mat_req_tbl
        , p_eam_direct_items_tbl => l_out_eam_direct_items_tbl
        , x_eam_wo_rec           => x_eam_wo_rec
        , x_eam_op_tbl           => x_eam_op_tbl
        , x_eam_op_network_tbl   => x_eam_op_network_tbl
        , x_eam_res_tbl          => x_eam_res_tbl
        , x_eam_res_inst_tbl     => x_eam_res_inst_tbl
        , x_eam_sub_res_tbl      => x_eam_sub_res_tbl
        , x_eam_res_usage_tbl    => x_eam_res_usage_tbl
        , x_eam_mat_req_tbl      => x_eam_mat_req_tbl
        , x_eam_direct_items_tbl => x_eam_direct_items_tbl
        , x_return_status        => x_return_status
        , x_msg_count            => x_msg_count
        --, p_debug                => 'N'
        --, p_output_dir           => '/ua1001/fs_ne/ADECO/interface' --'/usr/temp'
        --, p_debug_filename       => 'EAM_WO_DEBUG.log'
        --, p_debug_file_mode      => '1_'||TO_DATE(SYSDATE, 'YYYYMMDD')
        );


        IF x_return_status = 'S' THEN
          l_rc := cServ%ROWCOUNT;
        ELSE
          IF (x_msg_count > 0) THEN
            l_msg_index := x_msg_count;
            FOR i IN 1 .. x_msg_count LOOP
              FND_MSG_PUB.get( p_msg_index     => FND_MSG_PUB.G_NEXT
                             , p_encoded       => 'F'
                             , p_data          => l_msg_data
                             , p_msg_index_out => l_msg_index);

              IF i = 1 THEN
                l_error_message := 'Error '||l_msg_index||' : '||l_msg_data;
              ELSE
                l_error_message := l_error_message||'. Error '||l_msg_index||' : '||l_msg_data;
              END IF;
            END LOOP;
          END IF;

          RAISE eWOError;
        END IF;

      EXCEPTION
        WHEN eWOError THEN
          UPDATE XX_AGRONOMO_EAM_INT
          SET importado_flag  = 'E'
            , mensaje_error = l_error_message
          WHERE servicio = rServ.servicio;

      END;

    END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Se actualizaron '||l_rc||' Pedidos de Trabajo.');
    COMMIT;

    FND_FILE.PUT_LINE(FND_FILE.LOG, '- Generando Operaciones de WOs');

  END Check_Operation;


  PROCEDURE Genera_WO ( p_modo_ejecucion VARCHAR2 ) IS
    CURSOR cServ IS

      SELECT e.*
           , od.operating_unit
           , od.organization_name
      FROM xx_agronomo_eam_int e
         , org_organization_definitions od
      WHERE 1=1
      AND od.organization_id = e.organizacion_id
      AND e.importado_flag IN ('N', 'P', 'R')
      AND e.request_id     = g_request_id
      ORDER BY od.operating_unit, e.servicio
      ;

    --EAM Interface params
    d_pkg_name CONSTANT VARCHAR2(255) := 'EAM_PROCESS_WO_PUB';
    d_api_name CONSTANT VARCHAR2(255) := 'EAMPWOPB';

    l_eam_wo_rec                EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_eam_op_rec                EAM_PROCESS_WO_PUB.eam_op_rec_type;
    l_eam_op_tbl                EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_eam_op_network_tbl        EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_eam_res_tbl               EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_eam_res_inst_tbl          EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_eam_sub_res_tbl           EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_eam_res_usage_tbl         EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_eam_mat_req_tbl           EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_out_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_out_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_out_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_out_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_out_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_out_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_out_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_out_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_out_eam_direct_items_tbl  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    x_eam_wo_rec                EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    x_eam_op_tbl                EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    x_eam_op_network_tbl        EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    x_eam_res_tbl               EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    x_eam_res_inst_tbl          EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    x_eam_sub_res_tbl           EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    x_eam_res_usage_tbl         EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    x_eam_mat_req_tbl           EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    x_eam_direct_items_tbl      EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

    x_return_status             VARCHAR2(4000);
    x_msg_count                 NUMBER;

    l_msg_index                 NUMBER;
    l_msg_data                  VARCHAR2(4000);
    --

    l_rc                        NUMBER;
    l_error_message             VARCHAR2(2000);

    --
    l_organization_id            NUMBER;
    l_ou                         NUMBER;
    l_wip_entity_name            VARCHAR2(500);
    l_asset_number               VARCHAR2(30);
    l_asset_group_id             NUMBER;
    l_maintenance_object_type    NUMBER;
    l_maintenance_object_id      NUMBER;
    l_owning_department          VARCHAR2(20);
    l_owning_department_id       NUMBER(20);
    l_wip_accounting_class_code  VARCHAR2(20);
    l_eam_item_type              NUMBER;
    --

    eWOError       EXCEPTION;
  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Generando WOs');
    /*UPDATE xx_agronomo_eam_int
    SET comprador_id = 23646
    WHERE request_id = g_request_id;*/

    FOR rServ IN cServ LOOP
      l_error_message  := NULL;

      BEGIN
        BEGIN
          IF NVL(l_ou, -99) != rServ.operating_unit THEN
            l_ou := rServ.operating_unit;

            /*SELECT r.responsibility_id, r.application_id
            INTO l_resp_id, l_resp_appl_id
            FROM fnd_profile_option_values pov
               , fnd_profile_options_vl    po
               , fnd_responsibility_vl     r
            WHERE 1=1
            AND po.profile_option_id = pov.profile_option_id
            AND po.application_id    = pov.application_id
            AND po.profile_option_name = 'ORG_ID'
            AND pov.level_value      = r.responsibility_id
            AND UPPER(r.responsibility_name) like UPPER('% EAM Arg')
            AND TO_NUMBER(pov.profile_option_value) = l_ou;*/

            FND_GLOBAL.apps_initialize(FND_GLOBAL.USER_ID, FND_GLOBAL.RESP_ID, FND_GLOBAL.RESP_APPL_ID);

            FND_CLIENT_INFO.set_org_context(l_ou);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            l_error_message := 'El usuario no cuenta con la responsabilidad asociada para la unidad operativa ('||l_ou||').';
            RAISE eWOError;
        END;

        BEGIN
          SELECT organization_id
          INTO l_organization_id
          FROM org_organization_definitions
          WHERE organization_id = rServ.organizacion_id
          ;
        EXCEPTION
          WHEN OTHERS THEN
            l_error_message := 'No fue posible encontrar organization_id ('||rServ.organizacion_id||').';
            RAISE eWOError;
        END;

        BEGIN
          SELECT mean.instance_number
               , mean.maintenance_object_type
               , mean.maintenance_object_id
               , msi.inventory_item_id
               , mean.wip_accounting_class_Code
               , mean.owning_department_id
               , mean.eam_item_type
          INTO l_asset_number
             , l_maintenance_object_type
             , l_maintenance_object_id
             , l_asset_group_id
             , l_wip_accounting_class_Code
             , l_owning_department_id
             , l_eam_item_type
          FROM mtl_eam_asset_numbers_all_v mean
             , mtl_system_items            msi
          WHERE 1=1
          AND msi.segment1         = mean.concatenated_segments
          AND msi.organization_id  = mean.current_organization_id
          AND msi.organization_id  = l_organization_id
          AND mean.instance_number = rServ.identificador
          ;

        EXCEPTION
          WHEN OTHERS THEN
            l_error_message := 'No fue posible encontrar el activo ('||rServ.identificador||').';
            RAISE eWOError;
        END;


        BEGIN
          SELECT work_order_prefix||rServ.servicio --(rServ.servicio+200) --quitar el +xxx!!!!
          INTO l_wip_entity_name
          FROM wip_eam_parameters_v
          WHERE organization_id = l_organization_id;
        EXCEPTION
          WHEN OTHERS THEN
            l_error_message := 'No fue posible encontrar el activo ('||rServ.identificador||').';
            RAISE eWOError;
        END;


        IF p_modo_ejecucion = 'F' THEN
          l_eam_wo_rec := NULL;
          l_eam_wo_rec.organization_id  := l_organization_id;
          l_eam_wo_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_CREATE;
          l_eam_wo_rec.status_type      := WIP_CONSTANTS.RELEASED; --Unreleased;
          l_eam_wo_rec.wip_entity_name  := l_wip_entity_name;
          l_eam_wo_rec.description      := 'Prueba interface '||l_wip_entity_name;
          l_eam_wo_rec.scheduled_start_date      := rServ.fecha_inicio;
          l_eam_wo_rec.scheduled_completion_date := rServ.fecha_fin;
          l_eam_wo_rec.work_order_type  := rServ.tipo_servicio;

          IF l_eam_item_type = 1 THEN
            l_eam_wo_rec.asset_number   := l_asset_number;
            l_eam_wo_rec.asset_group_id := l_asset_group_id;
          ELSIF l_eam_item_type = 3 THEN
            l_eam_wo_rec.rebuild_item_id       := l_asset_group_id;
            l_eam_wo_rec.rebuild_serial_number := l_asset_number;
          END IF;

          l_eam_wo_rec.owning_department := l_owning_department_id;
          l_eam_wo_rec.class_code        := l_wip_accounting_class_code;
          --IF l_eam_item_type = 3 THEN
            --l_eam_wo_rec.maintenance_object_source := 2; -- EAM
          --ELSIF l_eam_item_type = 1 THEN
            l_eam_wo_rec.maintenance_object_source := 1; -- EAM
          --END IF;
          l_eam_wo_rec.maintenance_object_type := l_maintenance_object_type;
          l_eam_wo_rec.maintenance_object_id   := l_maintenance_object_id;

          l_eam_wo_rec.notification_required := 'N';
          l_eam_wo_rec.material_issue_by_mo  := 'N';
          l_eam_wo_rec.issue_zero_cost_flag  := 'Y';
          l_eam_wo_rec.notification_required := 'N';
          l_eam_wo_rec.po_creation_time  := 1;
          l_eam_wo_rec.job_quantity      := 1;
          l_eam_wo_rec.priority          := 10 ;
          l_eam_wo_rec.requested_start_date    := SYSDATE;

          /*FOR i IN 1..7 LOOP
            l_eam_op_rec := NULL;
            l_eam_op_rec.transaction_type  := EAM_PROCESS_WO_PVT.G_OPR_CREATE;
            l_eam_op_rec.organization_id   := l_organization_id;
            l_eam_op_rec.operation_seq_num := i;
            l_eam_op_rec.start_date        := rServ.fecha_inicio;
            l_eam_op_rec.completion_date   := rServ.fecha_fin;

            SELECT standard_operation_id, operation_description, department_id
            INTO l_eam_op_rec.standard_operation_id, l_eam_op_rec.description, l_eam_op_rec.department_id
            FROM bom_standard_operations_v
            WHERE 1=1
            AND organization_id = l_organization_id
            AND operation_code  = 'SU'||i;

            l_eam_op_tbl(i) := l_eam_op_rec;
          END LOOP;*/

          -- Solo General
          l_eam_op_rec := NULL;
          l_eam_op_rec.transaction_type  := EAM_PROCESS_WO_PVT.G_OPR_CREATE;
          l_eam_op_rec.organization_id   := l_organization_id;
          l_eam_op_rec.operation_seq_num := 1;
          l_eam_op_rec.start_date        := rServ.fecha_inicio;
          l_eam_op_rec.completion_date   := rServ.fecha_fin;

          BEGIN
            SELECT standard_operation_id, operation_description, department_id
            INTO l_eam_op_rec.standard_operation_id, l_eam_op_rec.description, l_eam_op_rec.department_id
            FROM bom_standard_operations_v
            WHERE 1=1
            AND organization_id = l_organization_id
            AND operation_code  = 'SU1';
          EXCEPTION
            WHEN OTHERS THEN
              l_error_message := 'No fue posible encontrar operación General para la organización ('||l_organization_id||').';
              RAISE eWOError;
          END;

          l_eam_op_tbl(1) := l_eam_op_rec;
          -- Solo General

          EAM_PROCESS_WO_PUB.PROCESS_WO
          ( p_bo_identifier        => 'EAM'
          , p_api_version_number   => 1.0
          , p_init_msg_list        => TRUE
          , p_commit               => 'N'
          , p_eam_wo_rec           => l_eam_wo_rec
          , p_eam_op_tbl           => l_eam_op_tbl
          , p_eam_op_network_tbl   => l_eam_op_network_tbl
          , p_eam_res_tbl          => l_eam_res_tbl
          , p_eam_res_inst_tbl     => l_eam_res_inst_tbl
          , p_eam_sub_res_tbl      => l_eam_sub_res_tbl
          , p_eam_res_usage_tbl    => l_eam_res_usage_tbl
          , p_eam_mat_req_tbl      => l_eam_mat_req_tbl
          , p_eam_direct_items_tbl => l_out_eam_direct_items_tbl
          , x_eam_wo_rec           => x_eam_wo_rec
          , x_eam_op_tbl           => x_eam_op_tbl
          , x_eam_op_network_tbl   => x_eam_op_network_tbl
          , x_eam_res_tbl          => x_eam_res_tbl
          , x_eam_res_inst_tbl     => x_eam_res_inst_tbl
          , x_eam_sub_res_tbl      => x_eam_sub_res_tbl
          , x_eam_res_usage_tbl    => x_eam_res_usage_tbl
          , x_eam_mat_req_tbl      => x_eam_mat_req_tbl
          , x_eam_direct_items_tbl => x_eam_direct_items_tbl
          , x_return_status        => x_return_status
          , x_msg_count            => x_msg_count
          --, p_debug                => 'N'
          --, p_output_dir           => '/ua1001/fs_ne/ADECO/interface' --'/usr/temp'
          --, p_debug_filename       => 'EAM_WO_DEBUG.log'
          --, p_debug_file_mode      => '1_'||TO_DATE(SYSDATE, 'YYYYMMDD')
          );

        END IF;


        IF x_eam_wo_rec.wip_entity_id IS NOT NULL THEN
          UPDATE XX_AGRONOMO_EAM_INT
          SET wip_entity_id  = x_eam_wo_rec.wip_entity_id
            , importado_flag = DECODE(p_modo_ejecucion, 'F', 'Y', p_modo_ejecucion)
            , mensaje_error  = NULL
          WHERE servicio = rServ.servicio;

          l_rc := cServ%ROWCOUNT;
        ELSE
          IF (x_msg_count > 0) THEN
            l_msg_index := x_msg_count;
            FOR i IN 1 .. x_msg_count LOOP
              FND_MSG_PUB.get( p_msg_index     => FND_MSG_PUB.G_NEXT
                             , p_encoded       => 'F'
                             , p_data          => l_msg_data
                             , p_msg_index_out => l_msg_index);

              IF i = 1 THEN
                l_error_message := 'Error '||l_msg_index||' : '||l_msg_data;
              ELSE
                l_error_message := l_error_message||'. Error '||l_msg_index||' : '||l_msg_data;
              END IF;
            END LOOP;
          END IF;

          RAISE eWOError;
        END IF;

      EXCEPTION
        WHEN eWOError THEN
          UPDATE XX_AGRONOMO_EAM_INT
          SET importado_flag  = 'E'
            , mensaje_error = l_error_message
          WHERE servicio = rServ.servicio;

      END;

    END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Se crearon '||l_rc||' Pedidos de Trabajo.');
    COMMIT;

    FND_FILE.PUT_LINE(FND_FILE.LOG, '- Generando WOs');
  END Genera_WO;


  PROCEDURE Interfaz_EAM ( errbuf           IN OUT VARCHAR2
                         , retcode          IN OUT VARCHAR2
                         , p_org_code       IN VARCHAR2
                         , p_fecha_desde    IN VARCHAR2
                         , p_fecha_hasta    IN VARCHAR2
                         , p_modo_ejecucion IN VARCHAR2
                         ) IS


    CURSOR cError IS
      SELECT servicio, 'Pedido Trabajo' tipo_error, mensaje_error
      FROM xx_agronomo_eam_int
      WHERE importado_flag = 'E'
      AND request_id       = g_request_id
      UNION
      SELECT servicio, 'Orden de Compra' tipo_error, mensaje_error
      FROM xx_agronomo_eam_oc_int
      WHERE importado_flag = 'E'
      AND request_id       = g_request_id
      UNION
      SELECT servicio, 'Inventario' tipo_error, mensaje_error
      FROM xx_agronomo_eam_inv_int
      WHERE importado_flag = 'E'
      AND request_id       = g_request_id
      ;

    -- Java Params
    l_fecha_desde         VARCHAR2(50);
    l_fecha_hasta         VARCHAR2(50);
    l_output              DBMSOUTPUT_LINESARRAY;
    l_linecount           NUMBER;
    --
    l_rc                  NUMBER;
  BEGIN
    l_fecha_desde := NVL(TO_CHAR(TO_DATE(p_fecha_desde,'RRRR-MM-DD HH24:MI:SS'),'RRRR-MM-DD'), TO_CHAR(SYSDATE, 'RRRR-MM-DD'));
    l_fecha_hasta := NVL(TO_CHAR(TO_DATE(p_fecha_hasta,'RRRR-MM-DD HH24:MI:SS'),'RRRR-MM-DD'), TO_CHAR(SYSDATE, 'RRRR-MM-DD'));

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'XX Interfaz Agronomo EAM');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Parámetros:');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_org_code    '||p_org_code);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_fecha_desde '||p_fecha_desde);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_fecha_hasta '||p_fecha_hasta);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_modo_ejecucion '||p_modo_ejecucion);
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'XX Interfaz Agronomo EAM');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Parámetros:');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_org_code    '||p_org_code);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_fecha_desde '||p_fecha_desde);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_fecha_hasta '||p_fecha_hasta);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_modo_ejecucion '||p_modo_ejecucion);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');

    FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Ejecutando Interfaz Java...');
    --FND_FILE.PUT_LINE(FND_FILE.LOG, 'cd /ua1001/fs_ne/ADECO/agronomo;/usr/bin/java -cp ''.:/ua1001/fs_ne/ADECO/agronomo/*'' AgronomoInterface '||NVL(p_org_code,'null')||' '||l_fecha_desde||' '||l_fecha_hasta||chr(10));
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'cd /ua1001/fs_ne/ADECO/agronomo;/usr/bin/java -cp ''.:/ua1001/fs_ne/ADECO/agronomo/*'' AgronomoInterfaceEAM PROCESS_NEWS '||NVL(p_org_code,'null')||' '||l_fecha_desde||' '||l_fecha_hasta||' '||g_request_id||' '||p_modo_ejecucion||chr(10));
    dbms_output.disable;
    dbms_output.enable;
    dbms_java.set_output(1023);
    --host_command ('cd /ua1001/fs_ne/ADECO/agronomo;/usr/bin/java -cp ''.:/ua1001/fs_ne/ADECO/agronomo/*'' AgronomoInterface '||NVL(p_org_code,'null')||' '||l_fecha_desde||' '||l_fecha_hasta);
    host_command ('cd /ua1001/fs_ne/ADECO/agronomo;/usr/bin/java -cp ''.:/ua1001/fs_ne/ADECO/agronomo/*'' AgronomoInterfaceEAM PROCESS_NEWS '||NVL(p_org_code,'null')||' '||l_fecha_desde||' '||l_fecha_hasta||' '||g_request_id||' '||p_modo_ejecucion);
    dbms_output.get_lines(l_output, l_linecount);
    IF l_output.COUNT > l_linecount THEN
      -- Remove the final empty line above l_linecount
      l_output.TRIM;

      FOR r1 IN (SELECT column_value FROM TABLE(l_output)) LOOP
        FND_FILE.PUT_LINE(FND_FILE.LOG, r1.column_value);
      END LOOP;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '- Ejecutando Interfaz Java...');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Ejecuta Procedimiento Generando WOs');
    Genera_WO ( p_modo_ejecucion );
    FND_FILE.PUT_LINE(FND_FILE.LOG, '- Ejecuta Procedimiento Generando WOs');
    IF p_modo_ejecucion = 'F' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Ejecuta Procedimiento Generando Operaciones de WOs');
      Check_Operation;
      FND_FILE.PUT_LINE(FND_FILE.LOG, '- Ejecuta Procedimiento Generando Operaciones de WOs');
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Ejecuta Procedimiento Generando OCs');
    Genera_OC ( p_modo_ejecucion );
    FND_FILE.PUT_LINE(FND_FILE.LOG, '- Ejecuta Procedimiento Generando OCs');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Ejecuta Procedimiento Generando Mov Inv');
    Genera_Inv ( p_modo_ejecucion );
    FND_FILE.PUT_LINE(FND_FILE.LOG, '- Ejecuta Procedimiento Generando Mov Inv');
    IF p_modo_ejecucion = 'F' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Ejecuta Procedimiento Finalizar WOs');
      Finalizar_WO;
      FND_FILE.PUT_LINE(FND_FILE.LOG, '- Ejecuta Procedimiento Finalizar WOs');
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Ejecutando Interfaz Java para actualizar errores en Argonomo...');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'cd /ua1001/fs_ne/ADECO/agronomo;/usr/bin/java -cp ''.:/ua1001/fs_ne/ADECO/agronomo/*'' AgronomoInterfaceEAM PROCESS_ERRORS '||NVL(p_org_code,'null')||' '||l_fecha_desde||' '||l_fecha_hasta||' '||g_request_id||' '||p_modo_ejecucion||chr(10));
    l_output := NULL;
    l_linecount := NULL;
    dbms_output.disable;
    dbms_output.enable;
    dbms_java.set_output(1023);
    host_command ('cd /ua1001/fs_ne/ADECO/agronomo;/usr/bin/java -cp ''.:/ua1001/fs_ne/ADECO/agronomo/*'' AgronomoInterfaceEAM PROCESS_ERRORS '||NVL(p_org_code,'null')||' '||l_fecha_desde||' '||l_fecha_hasta||' '||g_request_id||' '||p_modo_ejecucion);
    dbms_output.get_lines(l_output, l_linecount);
    IF l_output.COUNT > l_linecount THEN
      -- Remove the final empty line above l_linecount
      l_output.TRIM;

      FOR r1 IN (SELECT column_value FROM TABLE(l_output)) LOOP
        FND_FILE.PUT_LINE(FND_FILE.LOG, r1.column_value);
      END LOOP;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '- Ejecutando Interfaz Java para actualizar errores en Argonomo...');

    l_rc := 0;
    FOR rError IN cError LOOP
      l_rc := cError%ROWCOUNT;
    END LOOP;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Se encontraron '||l_rc||' registros con error.');

    FOR rError IN cError LOOP
      IF cError%ROWCOUNT = 1 THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'A continuación se detallan los registros con error:');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Servicio  | Tarea            | Error');
      END IF;

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(rError.servicio, 10, ' ')||'| '||RPAD(rError.tipo_error,16,' ')||' | '||rError.mensaje_error);
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,  SQLERRM);
      ROLLBACK;
  END Interfaz_EAM;


  PROCEDURE Interfaz_EAM_OCI ( errbuf           IN OUT VARCHAR2
                             , retcode          IN OUT VARCHAR2
                             , p_org_code       IN VARCHAR2
                             , p_fecha_desde    IN VARCHAR2
                             , p_fecha_hasta    IN VARCHAR2
                             , p_modo_ejecucion IN VARCHAR2
                             ) IS

    CURSOR cH IS

      SELECT oci.insumo_oc_id, oci.descripcion, oci.fecha, oci.direccion_envio, oci.direccion_facturacion
           , oci.organizacion_id, oci.proveedor_id, oci.moneda, oci.comprador_id, od.operating_unit
           , MAX(oci.po_header_id) po_header_id
      FROM xx_agronomo_eam_oci_int      oci
         , org_organization_definitions od
      WHERE 1=1
      AND od.organization_id = oci.organizacion_id
      AND oci.importado_flag IN ('N', 'P', 'R')
      AND oci.request_id     = g_request_id
      GROUP BY oci.insumo_oc_id, oci.descripcion, oci.fecha, oci.direccion_envio, oci.direccion_facturacion
             , oci.organizacion_id, oci.proveedor_id, oci.moneda, oci.comprador_id, od.operating_unit
      ORDER BY 1
      ;

    CURSOR cL ( p_insumo_oc_id     NUMBER ) IS

      SELECT oci.*
      FROM xx_agronomo_eam_oci_int oci
      WHERE 1=1
      AND oci.importado_flag IN ('N', 'P', 'R')
      AND oci.request_id   = g_request_id
      AND oci.insumo_oc_id = p_insumo_oc_id
      ORDER BY oci.insumo_oc_det_id
      ;


    CURSOR cVS ( p_operating_unit  NUMBER
               , p_productor_id    NUMBER
               ) IS

      SELECT vs.vendor_site_id
      FROM ap_suppliers        s
         , po_vendor_sites_all vs
         , hz_party_site_uses  hpsu
      WHERE 1=1
      AND vs.vendor_id = s.vendor_id
      AND NVL(vs.inactive_date, SYSDATE+1) > TRUNC(SYSDATE)
      AND vs.org_id    = p_operating_unit
      AND s.vendor_id  = p_productor_id
      AND hpsu.site_use_type = 'PURCHASING'
      AND hpsu.status = 'A'
      AND nvl(vs.PURCHASING_SITE_FLAG,'X') = 'Y'
      AND vs.party_site_id = hpsu.party_site_id
      ;

    CURSOR cError IS
      SELECT insumo_oc_id, 'Orden de Compra' tipo_error, mensaje_error
      FROM xx_agronomo_eam_oci_int
      WHERE importado_flag = 'E'
      AND request_id       = g_request_id
      ;


    l_dummy_chr           VARCHAR2(500);
    l_dummy_num           NUMBER;

    l_progress            VARCHAR2(10);
    l_int_header_id       NUMBER;
    l_int_line_id         NUMBER;
    l_batch_id            NUMBER;

    --Campos comunes
    l_attribute_category  VARCHAR2(5) := 'AR';

    --Campos para la cabecera
    l_organization_id     NUMBER;
    l_agent_id            NUMBER;
    l_doc_type            VARCHAR2(10)  := 'STANDARD';
    -- Proveedor
    l_vendor_id           NUMBER;
    l_vendor_site_id      NUMBER;
    l_ship_to_location_id NUMBER;
    l_bill_to_location_id NUMBER;

    --Campos para las lineas
    l_line_type_id        NUMBER := 1020; --Servicios GOODS QUANTITY
    l_item_id             NUMBER;
    l_item_desc           VARCHAR2(250);
    l_uom_code            VARCHAR2(50);
    l_category_id         NUMBER;
    l_expense_account     NUMBER;

    --Campos para las distribuciones
    l_cc_id               NUMBER;
    l_segment_un          VARCHAR2(50);
    l_currency            VARCHAR2(50);

    l_po_header_id        NUMBER;
    l_po_header_number    VARCHAR2(50);

    l_rc                  NUMBER;
    l_ou                  NUMBER;
    l_resp_id             NUMBER;
    l_resp_appl_id        NUMBER;

    l_cantidad            NUMBER := 1;

    l_error_message       VARCHAR2(2000);
    eHeaderError          EXCEPTION;
    eLineError            EXCEPTION;
    eAPIError             EXCEPTION;

    -- Java Params
    l_fecha_desde         VARCHAR2(50);
    l_fecha_hasta         VARCHAR2(50);
    l_output              DBMSOUTPUT_LINESARRAY;
    l_linecount           NUMBER;
    --
  BEGIN
    l_fecha_desde := NVL(TO_CHAR(TO_DATE(p_fecha_desde,'RRRR-MM-DD HH24:MI:SS'),'RRRR-MM-DD'), TO_CHAR(SYSDATE, 'RRRR-MM-DD'));
    l_fecha_hasta := NVL(TO_CHAR(TO_DATE(p_fecha_hasta,'RRRR-MM-DD HH24:MI:SS'),'RRRR-MM-DD'), TO_CHAR(SYSDATE, 'RRRR-MM-DD'));

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'XX Interfaz Agronomo EAM OC Insumos');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Parámetros:');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_org_code    '||p_org_code);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_fecha_desde '||p_fecha_desde);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_fecha_hasta '||p_fecha_hasta);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_modo_ejecucion '||p_modo_ejecucion);
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'XX Interfaz Agronomo EAM OC Insumos');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Parámetros:');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_org_code    '||p_org_code);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_fecha_desde '||p_fecha_desde);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_fecha_hasta '||p_fecha_hasta);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_modo_ejecucion '||p_modo_ejecucion);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');

    FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Ejecutando Interfaz Java...');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'cd /ua1001/fs_ne/ADECO/agronomo;/usr/bin/java -cp ''.:/ua1001/fs_ne/ADECO/agronomo/*'' AgronomoInterfaceEAMOCI PROCESS_NEWS '||NVL(p_org_code,'null')||' '||l_fecha_desde||' '||l_fecha_hasta||' '||g_request_id||' '||p_modo_ejecucion||chr(10));
    dbms_output.disable;
    dbms_output.enable;
    dbms_java.set_output(1023);
    host_command ('cd /ua1001/fs_ne/ADECO/agronomo;/usr/bin/java -cp ''.:/ua1001/fs_ne/ADECO/agronomo/*'' AgronomoInterfaceEAMOCI PROCESS_NEWS '||NVL(p_org_code,'null')||' '||l_fecha_desde||' '||l_fecha_hasta||' '||g_request_id||' '||p_modo_ejecucion);
    dbms_output.get_lines(l_output, l_linecount);
    IF l_output.COUNT > l_linecount THEN
      -- Remove the final empty line above l_linecount
      l_output.TRIM;

      FOR r1 IN (SELECT column_value FROM TABLE(l_output)) LOOP
        FND_FILE.PUT_LINE(FND_FILE.LOG, r1.column_value);
      END LOOP;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '- Ejecutando Interfaz Java...');


    FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Generando OCs');
    /*UPDATE xx_agronomo_eam_oci_int
    SET comprador_id = 23646
    WHERE request_id = g_request_id;*/

    FOR rH IN cH LOOP
      l_error_message  := NULL;

      BEGIN
        BEGIN
          IF NVL(l_ou, -99) != rH.operating_unit THEN
            l_ou := rH.operating_unit;

            SELECT r.responsibility_id, r.application_id
            INTO l_resp_id, l_resp_appl_id
            FROM fnd_profile_option_values pov
               , fnd_profile_options_vl    po
               , fnd_responsibility_vl     r
            WHERE 1=1
            AND po.profile_option_id = pov.profile_option_id
            AND po.application_id    = pov.application_id
            AND po.profile_option_name = 'ORG_ID'
            AND pov.level_value      = r.responsibility_id
            AND UPPER(r.responsibility_name) like UPPER('% PO Super User %')
            AND TO_NUMBER(pov.profile_option_value) = l_ou;

            FND_GLOBAL.apps_initialize(FND_GLOBAL.User_ID, l_resp_id, l_resp_appl_id);

            FND_CLIENT_INFO.set_org_context(l_ou);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            l_error_message := 'El usuario no cuenta con la responsabilidad asociada para la unidad operativa ('||l_ou||').';
            RAISE eHeaderError;
        END;

        l_error_message  := NULL;
        l_po_header_id   := NULL;
        l_vendor_id      := rH.proveedor_id;
        l_currency       := rH.moneda;

        BEGIN
          SELECT cancel_flag
          INTO l_dummy_chr
          FROM po_headers_all ph
          WHERE ph.po_header_id = rH.po_header_id
          ;

          IF l_dummy_chr != 'Y' THEN
            l_error_message := 'Existe una OC generada para el servicio ('||rH.insumo_oc_id||') proveedor ('||rH.proveedor_id||') y la misma no ha sido cancelada.';
            RAISE eHeaderError;
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
          WHEN OTHERS THEN
            l_error_message := 'No fue posible validar estado de la OC para el insumo ('||rH.insumo_oc_id||')  proveedor ('||rH.proveedor_id||').';
            RAISE eHeaderError;
        END;

        BEGIN
          SELECT organization_id
          INTO l_organization_id
          FROM org_organization_definitions
          WHERE organization_id = rH.organizacion_id
          ;
        EXCEPTION
          WHEN OTHERS THEN
            l_error_message := 'No fue posible encontrar organization_id ('||rH.organizacion_id||').';
            RAISE eHeaderError;
        END;

        -- Comprador
        BEGIN
          SELECT agent_id
          INTO l_dummy_num
          FROM po_agents
          WHERE agent_id = rH.comprador_id;

          l_agent_id := l_dummy_num;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_error_message := 'No fue posible obtener comprador ('||rH.comprador_id||').';
            RAISE eHeaderError;
        END;

        -- Productor
        BEGIN
          SELECT vendor_id
          INTO l_vendor_id
          FROM ap_suppliers
          WHERE 1=1
          AND NVL(end_date_active, SYSDATE+1) > TRUNC(SYSDATE)
          AND vendor_id = rH.proveedor_id
          ;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_error_message := 'El proveedor ('||rH.proveedor_id||') se encuentra deshabilitado.';
            RAISE eHeaderError;
        END;

        OPEN cVS (l_ou, l_vendor_id);
        FETCH cVS INTO l_vendor_site_id;
        IF cVS%NOTFOUND THEN
          CLOSE cVS;
          l_error_message := 'No se encontró Sucursal de compra activa del Depositante para la Unidad operativa '||l_ou; -- CR1991 - Validaciones previas a la generación de la OC
          RAISE eHeaderError;
        END IF;
        CLOSE cVS;

        BEGIN
          SELECT location_id
          INTO l_ship_to_location_id
          FROM hr_locations
          WHERE location_code = rH.direccion_envio;
        EXCEPTION
          WHEN OTHERS THEN
            l_error_message := 'No fue posible encontrar dirección de envío ('||rH.direccion_envio||').';
            RAISE eHeaderError;
        END;

        /*BEGIN
          SELECT location_id
          INTO l_bill_to_location_id
          FROM hr_locations
          WHERE location_code = rOCh.direccion_facturacion;
        EXCEPTION
          WHEN OTHERS THEN
            l_error_message := 'No fue posible encontrar dirección de envío ('||rOCh.direccion_facturacion||').';
            RAISE eHeaderError;
        END;*/

        IF p_modo_ejecucion = 'F' THEN
          l_progress := 'IDs';
          SELECT NVL(MAX(batch_id),0)+1
          INTO l_batch_id
          FROM po_headers_interface;
          --DBMS_OUTPUT.PUT_LINE('Batch ID: '||l_batch_id);

          SELECT po_headers_interface_s.NEXTVAL
          INTO l_int_header_id
          FROM DUAL;
          --DBMS_OUTPUT.PUT_LINE('Interface Header ID: '||l_int_header_id);

          l_progress := 'intHeader';
          INSERT INTO PO.PO_HEADERS_INTERFACE
          ( INTERFACE_HEADER_ID
          , BATCH_ID
          , PROCESS_CODE
          , ACTION
          , ATTRIBUTE_CATEGORY
          , ORG_ID
          , COMMENTS
          , DOCUMENT_TYPE_CODE
          , CURRENCY_CODE
          , AGENT_ID
          , VENDOR_ID
          , VENDOR_SITE_ID
          , SHIP_TO_LOCATION_ID
          , APPROVAL_REQUIRED_FLAG
          , APPROVAL_STATUS
          , CREATION_DATE
          )
          VALUES
          ( l_int_header_id --  INTERFACE_HEADER_ID
          , l_batch_id
          , 'PENDING'  --  PROCESS_CODE
          , 'ORIGINAL' --  ACTION
          , l_attribute_category
          , l_ou
          , rH.descripcion
          , l_doc_type
          , rH.moneda
          , l_agent_id
          , l_vendor_id
          , l_vendor_site_id
          , l_ship_to_location_id
          , 'Y'        -- APPROVAL_REQUIRED_FLAG
          , 'INCOMPLETE' -- APPROVAL_STATUS
          , SYSDATE    --  CREATION_DATE
          );

        END IF;

        FOR rL IN cL ( rH.insumo_oc_id
                     --, rH.proveedor_id
                     --, rH.moneda
                     ) LOOP

          BEGIN

            BEGIN
              SELECT si.inventory_item_id, si.description, si.primary_uom_code, si.expense_account, ic.category_id
              INTO l_item_id, l_item_desc, l_uom_code, l_expense_account, l_category_id
              FROM mtl_system_items      si
                 , mtl_item_categories_v ic
              WHERE 1=1
              AND ic.organization_id = si.organization_id
              AND ic.inventory_item_id = si.inventory_item_id
              AND ic.category_set_name = 'Inventory'
              AND si.organization_id = l_organization_id
              AND si.segment1        = rL.producto
              ;
            EXCEPTION
              WHEN OTHERS THEN
                l_error_message := 'No fue posible encontrar la categoria del producto ('||rL.producto||').';
                RAISE eLineError;
            END;

            IF p_modo_ejecucion = 'F' THEN

              l_progress := 'intLines';
              l_int_line_id := po_lines_interface_s.nextval;
              INSERT INTO PO.PO_LINES_INTERFACE
              ( INTERFACE_HEADER_ID
              , INTERFACE_LINE_ID
              , ACTION
              , LINE_NUM
              , LINE_TYPE_ID
              , CATEGORY_ID
              , ITEM_ID
              , ITEM_DESCRIPTION
              , UOM_CODE
              , QUANTITY
              , UNIT_PRICE
              , ORGANIZATION_ID
              , SHIP_TO_ORGANIZATION_ID
              , SHIP_TO_LOCATION_ID
              , PROMISED_DATE
              , NEED_BY_DATE
              , LINE_ATTRIBUTE_CATEGORY_LINES
              , CREATION_DATE
              ) VALUES
              ( l_int_header_id -- INTERFACE_HEADER_ID
              , l_int_line_id   -- INTERFACE_LINE_ID
              , 'ADD'           --  ACTION
              , rL.po_line_number -- LINE_NUM
              , l_line_type_id
              , l_category_id
              , l_item_id
              , l_item_desc
              , l_uom_code
              , rL.cantidad
              , rL.precio
              , l_organization_id
              , l_organization_id
              , l_ship_to_location_id
              , TRUNC(SYSDATE)
              , TRUNC(SYSDATE)
              , 'AR'
              , SYSDATE -- CREATION_DATE,
              );

              l_progress := 'intDistrib';
              INSERT INTO PO.PO_DISTRIBUTIONS_INTERFACE
              ( INTERFACE_HEADER_ID
              , INTERFACE_LINE_ID
              , INTERFACE_DISTRIBUTION_ID
              , DISTRIBUTION_NUM
              , QUANTITY_ORDERED
              , ATTRIBUTE_CATEGORY
              , DESTINATION_TYPE_CODE
              --, WIP_ENTITY_ID
              --, WIP_OPERATION_SEQ_NUM
              , CREATION_DATE
              ) VALUES
              ( l_int_header_id     -- INTERFACE_HEADER_ID
              , l_int_line_id       -- INTERFACE_LINE_ID
              , po_distributions_interface_s.NEXTVAL
              , l_rc                -- DISTRIBUTION_NUM
              , rL.cantidad
              , 'AR'
              , rL.tipo_destino
              --, rServ.wip_entity_id
              --, rL.em_subsistema_id
              , SYSDATE -- CREATION_DATE,
              );
            END IF;
          EXCEPTION
            WHEN eLineError THEN
              UPDATE XX_AGRONOMO_EAM_OCI_INT
              SET importado_flag  = 'E'
                , mensaje_error = l_error_message
              WHERE 1=1
              AND insumo_oc_id = rH.insumo_oc_id
              AND insumo_oc_det_id = rL.insumo_oc_det_id;

              RAISE eHeaderError;
          END;
        END LOOP;

        IF p_modo_ejecucion = 'F' THEN
          BEGIN
            IF NOT Run_API ( p_int_header_id     => l_int_header_id
                           , p_operating_unit    => l_ou
                           , p_commit            => FND_API.G_FALSE
                           , x_po_header_id      => l_po_header_id
                           , x_po_header_number  => l_po_header_number
                           , x_error_msg         => l_error_message
                           ) THEN
              l_po_header_id  := NULL;
              l_po_header_number := NULL;

              DELETE po_headers_interface WHERE interface_header_id = l_int_header_id;
              DELETE po_lines_interface WHERE interface_header_id = l_int_header_id;
              DELETE po_distributions_interface WHERE interface_header_id = l_int_header_id;
              DELETE po_interface_errors WHERE interface_header_id = l_int_header_id;

              RAISE eAPIError;
            END IF;

            BEGIN
              SELECT segment3
              INTO l_segment_un
              FROM gl_code_combinations
              WHERE code_combination_id =
              ( SELECT variance_account_id
                FROM po_distributions_all
                WHERE po_header_id = l_po_header_id
              );

              UPDATE po_lines_all
              SET attribute2 = l_segment_un
              WHERE po_header_id = l_po_header_id;
            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;

          EXCEPTION
            WHEN eAPIError THEN
              RAISE eHeaderError;
          END;
        END IF;

        UPDATE XX_AGRONOMO_EAM_OCI_INT
        SET importado_flag = DECODE(p_modo_ejecucion, 'F', 'Y', p_modo_ejecucion)
          , po_header_id   = l_po_header_id
          , mensaje_error  = NULL
        WHERE 1=1
        AND insumo_oc_id = rH.insumo_oc_id;

        l_rc := NVL(l_rc,0) + 1;

      EXCEPTION
        WHEN eHeaderError THEN
          UPDATE XX_AGRONOMO_EAM_OCI_INT
          SET importado_flag  = 'E'
            , mensaje_error = l_error_message
          WHERE 1=1
          AND insumo_oc_id = rH.insumo_oc_id
          ;
      END;

    END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Se crearon '||l_rc||' Ordenes de Compra.');
    COMMIT;

    FND_FILE.PUT_LINE(FND_FILE.LOG, '- Generando OCs');


    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Ejecutando Interfaz Java para actualizar errores en Argonomo...');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'cd /ua1001/fs_ne/ADECO/agronomo;/usr/bin/java -cp ''.:/ua1001/fs_ne/ADECO/agronomo/*'' AgronomoInterfaceEAMOCI PROCESS_ERRORS '||NVL(p_org_code,'null')||' '||l_fecha_desde||' '||l_fecha_hasta||' '||g_request_id||' '||p_modo_ejecucion||chr(10));
    l_output := NULL;
    l_linecount := NULL;
    dbms_output.disable;
    dbms_output.enable;
    dbms_java.set_output(1023);
    host_command ('cd /ua1001/fs_ne/ADECO/agronomo;/usr/bin/java -cp ''.:/ua1001/fs_ne/ADECO/agronomo/*'' AgronomoInterfaceEAMOCI PROCESS_ERRORS '||NVL(p_org_code,'null')||' '||l_fecha_desde||' '||l_fecha_hasta||' '||g_request_id||' '||p_modo_ejecucion);
    dbms_output.get_lines(l_output, l_linecount);
    IF l_output.COUNT > l_linecount THEN
      -- Remove the final empty line above l_linecount
      l_output.TRIM;

      FOR r1 IN (SELECT column_value FROM TABLE(l_output)) LOOP
        FND_FILE.PUT_LINE(FND_FILE.LOG, r1.column_value);
      END LOOP;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '- Ejecutando Interfaz Java para actualizar errores en Argonomo...');

    l_rc := 0;
    FOR rError IN cError LOOP
      l_rc := cError%ROWCOUNT;
    END LOOP;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Se encontraron '||l_rc||' registros con error.');

    FOR rError IN cError LOOP
      IF cError%ROWCOUNT = 1 THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'A continuación se detallan los registros con error:');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Servicio  | Tarea            | Error');
      END IF;

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(rError.insumo_oc_id, 10, ' ')||'| '||RPAD(rError.tipo_error,16,' ')||' | '||rError.mensaje_error);
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,  SQLERRM);
      ROLLBACK;
  END Interfaz_EAM_OCI;

END XX_AGRONOMO_EAM_PKG;
/
