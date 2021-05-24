spool xx_wms_int_in_ship_load_pkb.log
CREATE OR REPLACE PACKAGE BODY xx_wms_int_in_ship_load_pk
/* $Header: xx_wms_int_in_ship_load_pkb.pls 1.7    17-ABR-2020   */
-- --------------------------------------------------------------------------
--  1.0  09-10-2019  MGonzalez   Version Original
--  1.1  28-11-2019  MGonzalez   Modificado correccion clear_quantity_cache
--  1.2  04-12-2019  MGonzalez   Modificado mayor debug                          
--  1.3  11-12-2019  MGonzalez   Modificado para agregar split_dd                
--  1.4  19-12-2019  MGonzalez   Se separa la reserva y el pick                  
--  1.5  06-01-2020  MGonzalez   Se controla total pickeado y se reprocesa        
--  1.6  26-02-2020  MGonzalez   Se cambia control x messege_id y line_nbr        
--  1.7  17-04-2020  MGonzalez   Se cambia para que la reserva se haga con 
--                               origen g_source_type_internal_ord cuando 
--                               es un pedido interno

AS
PROCEDURE update_status(p_status       IN VARCHAR2
                       ,p_error_mesg   IN VARCHAR2
                       ,p_message_id   IN VARCHAR2
                       ,p_row_id       IN ROWID) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  UPDATE xx_wms_int_in_ship_load xwiisp
     SET status = p_status                                           
        ,error_mesg = nvl(p_error_mesg,error_mesg)
    WHERE xwiisp.message_id = p_message_id
      AND xwiisp.rowid      = nvl(p_row_id, xwiisp.rowid)
      AND xwiisp.status     IN ('NEW', 'RUNNING');
  COMMIT;
END update_status;

PROCEDURE validate_message_id(p_message_id    IN VARCHAR2
                             ,p_error_mesg   OUT VARCHAR2
                             ) IS
l_calling_sequence VARCHAR2(2000):= 'xx_wms_int_in_ship_load_pk.validate_message_id';
BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  SELECT 'El message_id '||p_message_id||' ya fue procesado exitosamente'
    INTO p_error_mesg
    FROM dual
   WHERE EXISTS (SELECT 1
                   FROM xx_wms_int_in_ship_load xwiisl
                  WHERE xwiisl.message_id = p_message_id
                    AND xwiisl.status     = 'OK')
  ;
  xx_debug_pk.debug(l_calling_sequence||', Fin',1);
EXCEPTION
  WHEN no_data_found THEN
    null;
  WHEN others THEN
    p_error_mesg := 'Error al validar message_id: '||sqlerrm;
END validate_message_id;

PROCEDURE control_concurrencia(p_message_id    IN VARCHAR2
                              ,p_error_mesg   OUT VARCHAR2
                             ) IS
l_calling_sequence VARCHAR2(2000):= 'xx_wms_int_in_ship_load_pk.control_concurrencia';
l_count            NUMBER:=0;
BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  LOOP
    SELECT count(1) --'Existe otro message_id en RUNNING'                                             
      INTO l_count
      FROM xx_wms_int_in_ship_load xwiisl
     WHERE xwiisl.message_id != p_message_id
       AND xwiisl.status      = 'RUNNING';             
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


PROCEDURE get_locator (p_org_code           IN VARCHAR2
                      ,p_locator_type       IN VARCHAR2
                      ,x_locator           OUT VARCHAR2 
                      ,x_error_mesg        OUT VARCHAR2) IS
e_error         EXCEPTION;
l_calling_sequence VARCHAR2(100):='xx_wms_int_in_ship_load_pk.get_locator';
BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  SELECT decode(p_locator_type,'LOC_CONFIRM_DESPACHO',flv_d.XX_loc_Confirmacion_Despacho) locator     
    INTO x_locator
    FROM fnd_lookup_values_vl flv
        ,fnd_lookup_values_dfv flv_d
   WHERE flv.lookup_type = 'XX_MAPEO_EBS_WMS'
     AND flv.lookup_code = p_org_code
     AND flv.rowid = flv_d.row_id;

  xx_debug_pk.debug(l_calling_sequence||', Fin',1);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;                                                                                             
  WHEN OTHERS THEN
    x_error_mesg := 'Error en '||l_calling_sequence||',p_org_code: '||p_org_code||': '||sqlerrm;
END get_locator;

PROCEDURE pick_release (p_delivery_id            IN NUMBER
                       ,p_delivery_detail_id     IN NUMBER
                       ,x_error_mesg        OUT VARCHAR2) IS
e_error               EXCEPTION;
l_calling_sequence    VARCHAR2(100):='xx_wms_int_in_ship_load_pk.pick_release';
l_return_status       VARCHAR2(1);
l_msg_count           NUMBER;             
l_msg_data            VARCHAR2(9999);
l_count               NUMBER;             
l_msg_data_out        VARCHAR2(9999);
l_mesg                VARCHAR2(9999);
l_error_message       VARCHAR2(9999);
l_mesg_count          NUMBER;
l_new_batch_id        NUMBER;
l_request_id          NUMBER;
l_rule_id             NUMBER;
l_rule_name           VARCHAR2(2000);
l_batch_prefix        VARCHAR2(2000);
l_batch_info_rec      wsh_picking_batches_pub.batch_info_rec;
BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  l_batch_info_rec.delivery_id              := p_delivery_id;
  l_batch_info_rec.delivery_detail_id       := p_delivery_detail_id;
  l_batch_info_rec.Existing_Rsvs_Only_Flag  := 'Y';
  xx_debug_pk.debug(l_calling_sequence||', p_delivery_id: '||p_delivery_id,1);
  xx_debug_pk.debug(l_calling_sequence||', p_delivery_detail_id: '||p_delivery_detail_id,1);
  ------------------------------------------------------------------------
  -- API Call to Create Batch -
  ------------------------------------------------------------------------
  BEGIN
    wsh_picking_batches_pub.create_batch
                                         (p_api_version        => 1.0,
                                          p_init_msg_list      => fnd_api.g_true,
                                          p_commit             => fnd_api.g_false,
                                          x_return_status      => l_return_status,
                                          x_msg_count          => l_msg_count,
                                          x_msg_data           => l_msg_data,
                                          p_rule_id            => l_rule_id,
                                          p_rule_name          => l_rule_name,
                                          p_batch_rec          => l_batch_info_rec,
                                          p_batch_prefix       => l_batch_prefix,
                                          x_batch_id           => l_new_batch_id
                                         );
  EXCEPTION
    WHEN OTHERS THEN
      x_error_mesg := 'Error en wsh_picking_batches_pub.create_batch: '||sqlerrm; 
      RAISE e_error;
  END;
  xx_debug_pk.debug(l_calling_sequence||', l_return_status: '||l_return_status,1);
  xx_debug_pk.debug(l_calling_sequence||', l_msg_count: '||l_msg_count,1);

  IF l_return_status <> fnd_api.g_ret_sts_success THEN
    FOR i IN 1 .. l_msg_count LOOP
      apps.fnd_msg_pub.get (p_msg_index                   => i
                          , p_encoded                     => fnd_api.g_false
                          , p_data                        => l_mesg          
                          , p_msg_index_out               => l_count
                           );

      IF l_error_message IS NULL THEN
        l_error_message := SUBSTR (l_msg_data, 1, 250);
      ELSE
        l_error_message :=l_error_message || ' /' || SUBSTR (l_msg_data, 1, 250);
      END IF;
    END LOOP;

    x_error_mesg := l_error_message;
    xx_debug_pk.debug(l_calling_sequence||', API Error: '|| l_error_message,1);
    RAISE e_error;
  ELSE
    xx_debug_pk.debug(l_calling_sequence||', l_new_batch_id: '||l_new_batch_id,1);
  END IF;

  
  UPDATE wsh_delivery_details
     SET batch_id = l_new_batch_id
   WHERE delivery_detail_id = p_delivery_detail_id;

  -- Release the batch Created Above
  BEGIN
    wsh_picking_batches_pub.release_batch
                                         (p_api_version        => 1.0,
                                          p_init_msg_list      => fnd_api.g_true,
                                          p_commit             => fnd_api.g_false,
                                          x_return_status      => l_return_status,
                                          x_msg_count          => l_msg_count,
                                          x_msg_data           => l_msg_data,
                                          p_batch_id           => l_new_batch_id,
                                          p_batch_name         => NULL,
                                          p_log_level          => 1,
                                          p_release_mode       => 'ONLINE',
                                          -- (ONLINE or CONCURRENT)
                                          x_request_id         => l_request_id
                                         );
  EXCEPTION
    WHEN OTHERS THEN
      x_error_mesg := 'Error en wsh_picking_batches_pub.release_batch: '||sqlerrm; 
      RAISE e_error;
  END;
  IF l_return_status <> fnd_api.g_ret_sts_success THEN
    FOR i IN 1 .. l_msg_count LOOP
      apps.fnd_msg_pub.get (p_msg_index                   => i
                          , p_encoded                     => fnd_api.g_false
                          , p_data                        => l_mesg
                          , p_msg_index_out               => l_count
                           );

      IF l_error_message IS NULL THEN
        l_error_message := SUBSTR (l_msg_data, 1, 250);
      ELSE
        l_error_message :=l_error_message || ' /' || SUBSTR (l_msg_data, 1, 250);
      END IF;
    END LOOP;

    x_error_mesg := l_error_message;
    xx_debug_pk.debug(l_calling_sequence||', API Error: '|| l_error_message,1);
    RAISE e_error;
  ELSE
    xx_debug_pk.debug(l_calling_sequence||', l_request_id: '||l_request_id,1);
  END IF;

  xx_debug_pk.debug(l_calling_sequence||', Fin',1);
EXCEPTION
  WHEN e_error THEN
    NULL;
  WHEN OTHERS THEN
    x_error_mesg := 'Error general en '||l_calling_sequence||
                    ': '||sqlerrm;
END pick_release;



PROCEDURE create_reservation (p_organization_id        IN NUMBER
                             ,p_inventory_item_id      IN NUMBER
                             ,p_reservation_quantity   IN NUMBER
                             ,p_uom_code               IN VARCHAR2
                             ,p_subinventory_code      IN VARCHAR2
                             ,p_locator_id             IN NUMBER   
                             ,p_lot_number             IN VARCHAR2
                             ,p_source_header_id       IN NUMBER   
                             ,p_source_line_id         IN NUMBER   
                             ,x_error_mesg        OUT VARCHAR2) IS
e_error            EXCEPTION;
l_calling_sequence VARCHAR2(100):='xx_wms_int_in_ship_load_pk.create_reservation';
l_exists           NUMBER;
l_rsv_rec                                         inv_reservation_global.mtl_reservation_rec_type;
l_serial_number                                   inv_reservation_global.serial_number_tbl_type;
l_partial_reservation_flag                        VARCHAR2 (1) := fnd_api.g_false;
l_force_reservation_flag                          VARCHAR2 (1) := fnd_api.g_false;
l_validation_flag                                 VARCHAR2 (1) := fnd_api.g_true;
l_partial_reservation_exists                      BOOLEAN := FALSE;
l_primary_reservation_qty                         NUMBER;
l_subinventory_code                               VARCHAR2 (40);
l_source_name                                     VARCHAR2 (40);
l_error_message                                   VARCHAR2 (2000);
l_msg_index_out                                   NUMBER;
x_serial_number                                   inv_reservation_global.serial_number_tbl_type;
x_quantity_reserved                               NUMBER := 0;
x_reservation_id                                  NUMBER := 0;
x_return_status                                   VARCHAR2 (2);
x_msg_count                                       NUMBER := 0;
x_msg_data                                        VARCHAR2 (250);
l_dummy varchar2(300);
BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);

  BEGIN
    SELECT oos.name
      INTO l_source_name
      FROM oe_order_headers_all ooh
          ,oe_order_lines_all ool
          ,oe_order_sources oos
     WHERE ooh.order_source_id = oos.order_source_id
       AND ooh.header_id       = ool.header_id
       AND ool.line_id         = p_source_line_id;
  EXCEPTION
    WHEN OTHERS THEN
      x_error_mesg := 'Error al obtener tipo de pedido. '||sqlerrm;
      RAISE e_error;
  END;
  l_rsv_rec.organization_id                 := p_organization_id;
  l_rsv_rec.inventory_item_id               := p_inventory_item_id;
  l_rsv_rec.requirement_date                := SYSDATE + 1;
  xx_debug_pk.debug(l_calling_sequence||', l_source_name: '||l_source_name,1);
  IF l_source_name = 'Internal' THEN
    l_rsv_rec.demand_source_type_id           := inv_reservation_global.g_source_type_internal_ord;
  ELSE
    l_rsv_rec.demand_source_type_id           := inv_reservation_global.g_source_type_oe;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_rsv_rec.demand_source_type_id: '||l_rsv_rec.demand_source_type_id,1);
  l_rsv_rec.supply_source_type_id           := inv_reservation_global.g_source_type_inv;
  l_rsv_rec.demand_source_name              := null; -- tiene que ser nulo
  l_rsv_rec.primary_reservation_quantity    := null; --p_reservation_quantity;
  l_rsv_rec.primary_uom_code                := null; --p_uom_code;
  l_rsv_rec.subinventory_code               := p_subinventory_code;
  l_rsv_rec.LOCATOR_ID                      := p_locator_id; 
  l_rsv_rec.LOT_NUMBER                      := p_lot_number;
  l_rsv_rec.demand_source_header_id         := p_source_header_id; -- sales_order_id
  l_rsv_rec.demand_source_line_id           := p_source_line_id; -- oe line_id
  l_rsv_rec.reservation_uom_code            := p_uom_code; --NULL ;
  l_rsv_rec.reservation_quantity            := p_reservation_quantity; --NULL ;
  l_rsv_rec.supply_source_header_id         := NULL ; 
  l_rsv_rec.supply_source_line_id           := NULL ; 
  l_rsv_rec.supply_source_name              := NULL ; 
  l_rsv_rec.supply_source_line_detail       := NULL ; 
  l_rsv_rec.serial_number                   := NULL ;
  l_rsv_rec.ship_ready_flag                 := NULL ;
  l_rsv_rec.attribute15                     := NULL ;
  l_rsv_rec.attribute14                     := NULL ;        
  l_rsv_rec.attribute13                     := NULL ; 
  l_rsv_rec.attribute12                     := NULL ; 
  l_rsv_rec.attribute11                     := NULL ;  
  l_rsv_rec.attribute10                     := NULL ;
  l_rsv_rec.attribute9                      := NULL ;      
  l_rsv_rec.attribute8                      := NULL ;  
  l_rsv_rec.attribute7                      := NULL ; 
  l_rsv_rec.attribute6                      := NULL ;  
  l_rsv_rec.attribute5                      := NULL ;       
  l_rsv_rec.attribute4                      := NULL ;   
  l_rsv_rec.attribute3                      := NULL ; 
  l_rsv_rec.attribute2                      := NULL ;   
  l_rsv_rec.attribute1                      := NULL ;   
  l_rsv_rec.attribute_category              := NULL ;
  l_rsv_rec.lpn_id                          := NULL ;
  l_rsv_rec.pick_slip_number                := NULL ;
  l_rsv_rec.lot_number_id                   := NULL ;
  l_rsv_rec.subinventory_id                 := NULL ; 
  l_rsv_rec.revision                        := NULL ; 
  l_rsv_rec.external_source_line_id         := NULL ;      
  l_rsv_rec.external_source_code            := NULL ;      
  l_rsv_rec.autodetail_group_id             := NULL ;     
  l_rsv_rec.reservation_uom_id              := NULL ;     
  l_rsv_rec.primary_uom_id                  := NULL ;    
  l_rsv_rec.demand_source_delivery          := NULL ;  

  inv_quantity_tree_grp.clear_quantity_cache;
  xx_debug_pk.debug(l_calling_sequence||', call create_reservation',1);
  -- call API to create reservation
  inv_reservation_pub.create_reservation (p_api_version_number          => 1.0
                                        , p_init_msg_lst                => fnd_api.g_true
                                        , p_rsv_rec                     => l_rsv_rec
                                        , p_serial_number               => l_serial_number
                                        , p_partial_reservation_flag    => l_partial_reservation_flag
                                        , p_force_reservation_flag      => l_force_reservation_flag
                                        , p_partial_rsv_exists          => l_partial_reservation_exists
                                        , p_validation_flag             => l_validation_flag
                                        , x_serial_number               => x_serial_number
                                        , x_return_status               => x_return_status
                                        , x_msg_count                   => x_msg_count
                                        , x_msg_data                    => x_msg_data
                                        , x_quantity_reserved           => x_quantity_reserved
                                        , x_reservation_id              => x_reservation_id
                                         );

  xx_debug_pk.debug(l_calling_sequence||'RESERVA:  source_header_id, source_line_id, item_id,lot_number, reservation_quantity, quantity_reserved: '||
                                     p_source_header_id||', '|| p_source_line_id||', '||p_inventory_item_id||', '||p_lot_number||', '||p_reservation_quantity||', '||x_quantity_reserved,1);
  xx_debug_pk.debug(l_calling_sequence||', x_return_status: '|| x_return_status,1);
  xx_debug_pk.debug(l_calling_sequence||', x_msg_count: '|| x_msg_count,1);
  xx_debug_pk.debug(l_calling_sequence||', x_msg_data: '|| x_msg_data,1);
  IF x_return_status <> fnd_api.g_ret_sts_success THEN
    FOR i IN 1 .. x_msg_count LOOP
      apps.fnd_msg_pub.get (p_msg_index                   => i
                          , p_encoded                     => fnd_api.g_false
                          , p_data                        => x_msg_data
                          , p_msg_index_out               => l_msg_index_out
                           );

      IF l_error_message IS NULL THEN
        l_error_message := SUBSTR (x_msg_data, 1, 250);
      ELSE
        l_error_message :=l_error_message || ' /' || SUBSTR (x_msg_data, 1, 250);
      END IF;
    END LOOP;

    x_error_mesg := l_error_message;
    xx_debug_pk.debug(l_calling_sequence||', API Error: '|| l_error_message,1);
  ELSE
    xx_debug_pk.debug(l_calling_sequence||', Reservation ID: '|| x_reservation_id,1);
    xx_debug_pk.debug(l_calling_sequence||', Quantity Reserved: '|| x_quantity_reserved,1);
SELECT nvl(sum(mr.reservation_quantity),0)
  into l_dummy
  FROM mtl_reservations mr
 WHERE mr.inventory_item_id       = p_inventory_item_id
   AND mr.demand_source_header_id = p_source_header_id
   AND mr.demand_source_line_id   = p_source_line_id
;
    xx_debug_pk.debug(l_calling_sequence||', Quantity Reserved dummy: '|| l_dummy,1);
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', Fin',1);
EXCEPTION
  WHEN e_error THEN
    null;                                                                     
  WHEN OTHERS THEN
    x_error_mesg := 'Error general en '||l_calling_sequence||
                    ': '||sqlerrm;
END create_reservation;

PROCEDURE control_confirm (p_message_id            IN VARCHAR2
                          ,x_error_mesg        OUT VARCHAR2) IS
e_error               EXCEPTION;
l_calling_sequence    VARCHAR2(100):='xx_wms_int_in_ship_load_pk.control_confirm';
l_return_status       VARCHAR2(1);
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(9999);
l_dif_count           NUMBER := 0;
l_loop                NUMBER := 1;
CURSOR c_dev IS
SELECT xwi.inventory_item_id, ship.uom_code, xwi.item, xwi.organization_id, xwi.trip_id, xwi.delivery_id, xwi.shipped_qty
      ,sum(decode(ship.released_status, 'Y',ship.confirmed_quantity, 'C',ship.confirmed_quantity,0)) confirmed_quantity
      ,sum(decode(ship.released_status, 'B',ship.confirmed_quantity, 'R',ship.confirmed_quantity,0)) pending_quantity
  FROM (SELECT msi.inventory_item_id
              ,msi.organization_id
              ,xwiisl.item_part_a  item
              ,xwiisl.message_id
              ,xwiisl.order_hdr_cust_field_1  trip_id
              ,xwiisl.order_dtl_cust_field_2  delivery_id
              ,sum(xwiisl.shipped_qty) shipped_qty
          FROM xx_wms_int_in_ship_load xwiisl
              ,mtl_system_items msi
         WHERE xwiisl.message_id  = p_message_id
           AND xwiisl.status      = 'RUNNING' --'NEW'
           AND xwiisl.item_part_a = msi.segment1 
         GROUP BY msi.inventory_item_id
                 ,msi.organization_id
                 ,xwiisl.item_part_a
                 ,xwiisl.message_id
                 ,xwiisl.order_hdr_cust_field_1
                 ,xwiisl.order_dtl_cust_field_2) xwi
      ,(SELECT wtd.trip_id
              ,wtd.delivery_id
              ,wtd.inventory_item_id
              ,wtd.organization_id
              ,sum(wtd.requested_quantity)
              ,wtd.requested_quantity_uom
              ,wtd.released_status
              ,uom.uom_code
              ,sum(inv_convert.inv_um_convert (wtd.inventory_item_id              --Inventory Item Id
                                              ,NULL                             --Precision
                                              ,NVL (wtd.requested_quantity, 0)  --Quantity
                                              ,wtd.requested_quantity_uom       --From UOM
                                              ,uom.uom_code                       --To UOM
                                              ,NULL                             --From UOM Name
                                              ,NULL                             --To UOM Name
                                              )) confirmed_quantity
          FROM wsh_delivery_legs wdl
              ,wsh_trip_stops pickup_stop
              ,wsh_trip_deliverables_v wtd
              ,wsh_trips wt
              ,(SELECT distinct mcr_d.xx_uom_wms uom_code
                       ,mcr.inventory_item_id
                  FROM mtl_cross_references mcr
                      ,mtl_cross_references_dfv mcr_d
                 WHERE mcr.cross_reference_type                   = 'DUN14'
                   AND mcr.rowid = mcr_d.row_id ) uom
         WHERE wtd.inventory_item_id       = uom.inventory_item_id
           AND wtd.delivery_id             = wdl.delivery_id
           AND wdl.pick_up_stop_id         = pickup_stop.stop_id
           AND pickup_stop.trip_id         = wt.trip_id
           AND wtd.inventory_item_id       = uom.inventory_item_id
           AND wtd.released_status        IN ('B','R','Y','C')
         GROUP BY wtd.trip_id
                 ,wtd.delivery_id
                 ,wtd.inventory_item_id
                 ,wtd.organization_id
                 ,wtd.requested_quantity_uom
                 ,wtd.released_status
                 ,uom.uom_code ) ship
 WHERE xwi.message_id         = p_message_id
   AND ship.trip_id           = xwi.trip_id
   AND ship.delivery_id       = xwi.delivery_id
   AND ship.inventory_item_id = xwi.inventory_item_id
   AND ship.organization_id   = xwi.organization_id 
 GROUP BY xwi.inventory_item_id
         ,xwi.item
         ,xwi.organization_id
         ,xwi.trip_id
         ,xwi.delivery_id
         ,xwi.shipped_qty
         ,ship.uom_code
;

CURSOR c_ddtl (p_trip_id           NUMBER
              ,p_delivery_id       NUMBER
              ,p_inventory_item_id NUMBER
              ,p_uom_code          VARCHAR2) IS
SELECT a.*
FROM (
SELECT wtd.trip_id
      ,wtd.delivery_id
      ,wtd.inventory_item_id
      ,wtd.source_header_id
      ,wtd.source_line_id
      ,wtd.requested_quantity
      ,wtd.requested_quantity_uom
      ,inv_convert.inv_um_convert (p_inventory_item_id              --Inventory Item Id
                                  ,NULL                             --Precision
                                  ,NVL (wtd.requested_quantity, 0)  --Quantity
                                  ,wtd.requested_quantity_uom       --From UOM
                                  ,p_uom_code                       --To UOM
                                  ,NULL                             --From UOM Name
                                  ,NULL                             --To UOM Name
                                  ) quantity
      ,wtd.delivery_detail_id
  FROM wsh_delivery_legs wdl
      ,wsh_trip_stops pickup_stop
      ,wsh_trip_deliverables_v wtd
      ,wsh_trips wt
 WHERE wt.trip_id                  = p_trip_id
   AND wtd.delivery_id             = p_delivery_id
   AND wtd.inventory_item_id       = p_inventory_item_id
   AND wtd.delivery_id             = wdl.delivery_id
   AND wdl.pick_up_stop_id         = pickup_stop.stop_id
   AND pickup_stop.trip_id         = wt.trip_id
   AND wtd.released_status        IN ('R','B')
)a
 WHERE a.quantity > 0
 ORDER BY source_header_id, delivery_detail_id;

BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  WHILE l_loop <= 10 AND l_dif_count >= 0 LOOP
    xx_debug_pk.debug(l_calling_sequence||', l_loop: '||l_loop,1);
    xx_debug_pk.debug(l_calling_sequence||', l_dif_count: '||l_dif_count,1);
    l_loop      := l_loop +1;
    l_dif_count := 0;
    FOR r_dev IN c_dev LOOP
      xx_debug_pk.debug(l_calling_sequence||'CONTROL: trip_id, delivery_id, item, shipped_qty, confirmed_qty, pending_qty: '||
                                         r_dev.trip_id||', '||r_dev.delivery_id||', '|| r_dev.item||', '||r_dev.shipped_qty||', '||r_dev.confirmed_quantity||', '||r_dev.pending_quantity,1);
      IF r_dev.shipped_qty > r_dev.confirmed_quantity THEN
        l_dif_count := l_dif_count + 1;
        FOR r_ddtl IN c_ddtl (r_dev.trip_id           
                             ,r_dev.delivery_id       
                             ,r_dev.inventory_item_id 
                             ,r_dev.uom_code         ) LOOP
          xx_debug_pk.debug(l_calling_sequence||', Pick Release delivery_id, dd_id: '||r_dev.delivery_id||', '||r_ddtl.delivery_detail_id,1);
          pick_release (p_delivery_id            => r_dev.delivery_id
                       ,p_delivery_detail_id     => r_ddtl.delivery_detail_id
                       ,x_error_mesg             => x_error_mesg);

          IF x_error_mesg IS NOT NULL THEN
            xx_debug_pk.debug(l_calling_sequence||' x_error_mesg: '||x_error_mesg,1);
            RAISE e_error;
          END IF;
        END LOOP;
      END IF;
    END LOOP;
    IF l_dif_count = 0 THEN
      l_dif_count := -1;
      xx_debug_pk.debug(l_calling_sequence||', No hay diferencias de Pick Release ',1);
    ELSE
      xx_debug_pk.debug(l_calling_sequence||', Hay diferencias de Pick Release: '||l_dif_count,1);
    END IF;
  END LOOP;
       

  xx_debug_pk.debug(l_calling_sequence||', Fin',1);
EXCEPTION
  WHEN e_error THEN
    null;
  WHEN OTHERS THEN
    x_error_mesg := 'Error general en '||l_calling_sequence||
                    ': '||sqlerrm;
END control_confirm;

PROCEDURE unassigne_delivery (p_trip_id         IN NUMBER
                             ,p_delivery_id     IN NUMBER
                             ,x_error_mesg     OUT VARCHAR2) IS
e_error               EXCEPTION;
l_calling_sequence    VARCHAR2(100):='xx_wms_int_in_ship_load_pk.unassigne_delivery';
l_return_status       VARCHAR2(1);
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(9999);
l_count               NUMBER;
l_msg_data_out        VARCHAR2(9999);
l_mesg                VARCHAR2(9999);
l_error_message       VARCHAR2(9999);
l_mesg_count          NUMBER;
l_operation           VARCHAR2(30) := 'UNASSIGN-TRIP from Delivery';
l_action_code         VARCHAR2(15);
x_trip_id             NUMBER;
x_trip_name           VARCHAR2(30);






BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  xx_debug_pk.debug(l_calling_sequence||', p_tri_id: '||p_trip_id,1);
  xx_debug_pk.debug(l_calling_sequence||', p_delivery_id: '||p_delivery_id,1);
  l_action_code := 'UNASSIGN-TRIP';

  WSH_DELIVERIES_PUB.DELIVERY_ACTION( p_api_version_number => 1.0
                                    , p_init_msg_list      => FND_API.G_TRUE
                                    , x_return_status      => l_return_status
                                    , x_msg_count          => l_msg_count
                                    , x_msg_data           => l_msg_data_out
                                    , p_action_code        => l_action_code
                                    , p_delivery_id        => p_delivery_id
                                    , p_asg_trip_id        => p_trip_id
                                    , x_trip_id            => x_trip_id
                                    , x_trip_name          => x_trip_name
                                    );


  IF l_return_status <> fnd_api.g_ret_sts_success THEN
    FOR i IN 1 .. l_msg_count LOOP
      apps.fnd_msg_pub.get (p_msg_index                   => i
                          , p_encoded                     => fnd_api.g_false
                          , p_data                        => l_mesg
                          , p_msg_index_out               => l_count
                           );

      IF l_error_message IS NULL THEN
        l_error_message := SUBSTR (l_msg_data, 1, 250);
      ELSE
        l_error_message :=l_error_message || ' /' || SUBSTR (l_msg_data, 1, 250);
      END IF;
    END LOOP;

    x_error_mesg := l_error_message;
    xx_debug_pk.debug(l_calling_sequence||', API Error: '|| l_error_message,1);
    RAISE e_error;
  END IF;

  xx_debug_pk.debug(l_calling_sequence||', Fin',1);
EXCEPTION
  WHEN e_error THEN
    null;
  WHEN OTHERS THEN
    x_error_mesg := 'Error general en '||l_calling_sequence||
                    ': '||sqlerrm;
END unassigne_delivery;

PROCEDURE unassigne_line (p_delivery_id            IN NUMBER
                         ,p_delivery_detail_id     IN NUMBER
                         ,x_error_mesg        OUT VARCHAR2) IS
e_error               EXCEPTION;
l_calling_sequence    VARCHAR2(100):='xx_wms_int_in_ship_load_pk.unassigne_line';
l_return_status       VARCHAR2(1);
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(9999);
l_count               NUMBER;
l_msg_data_out        VARCHAR2(9999);
l_mesg                VARCHAR2(9999);
l_error_message       VARCHAR2(9999);
l_mesg_count          NUMBER;
l_tabofdeldets        WSH_DELIVERY_DETAILS_PUB.ID_TAB_TYPE;


BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  xx_debug_pk.debug(l_calling_sequence||', p_delivery_id: '||p_delivery_id,1);
  xx_debug_pk.debug(l_calling_sequence||', p_delivery_detail_id: '||p_delivery_detail_id,1);

  l_tabofdeldets(1) := p_delivery_detail_id;
  WSH_DELIVERY_DETAILS_PUB.DETAIL_TO_DELIVERY(P_API_VERSION      => 1.0,                   
                                              P_INIT_MSG_LIST    => FND_API.G_TRUE,
                                              P_COMMIT           => FND_API.G_FALSE,
                                              P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                                              X_RETURN_STATUS    => l_RETURN_STATUS,
                                              X_MSG_COUNT        => l_MSG_COUNT,
                                              X_MSG_DATA         => l_msg_data_out,
                                              P_TABOFDELDETS     => l_tabofdeldets,
                                              P_ACTION           => 'UNASSIGN',
                                              P_DELIVERY_ID      => p_delivery_id,
                                              P_DELIVERY_NAME    => p_delivery_id
                                             );

  IF l_return_status <> fnd_api.g_ret_sts_success THEN
    FOR i IN 1 .. l_msg_count LOOP
      apps.fnd_msg_pub.get (p_msg_index                   => i
                          , p_encoded                     => fnd_api.g_false
                          , p_data                        => l_mesg
                          , p_msg_index_out               => l_count
                           );

      IF l_error_message IS NULL THEN
        l_error_message := SUBSTR (l_msg_data, 1, 250);
      ELSE
        l_error_message :=l_error_message || ' /' || SUBSTR (l_msg_data, 1, 250);
      END IF;
    END LOOP;

    x_error_mesg := l_error_message;
    xx_debug_pk.debug(l_calling_sequence||', API Error: '|| l_error_message,1);
    RAISE e_error;
  END IF;

  xx_debug_pk.debug(l_calling_sequence||', Fin',1);
EXCEPTION
  WHEN e_error THEN
    null;
  WHEN OTHERS THEN
    x_error_mesg := 'Error general en '||l_calling_sequence||
                    ': '||sqlerrm;
END unassigne_line;



PROCEDURE validate_trip (p_trip_number        IN VARCHAR2
                        ,x_error_mesg        OUT VARCHAR2) IS
e_error            EXCEPTION;
l_calling_sequence VARCHAR2(100):='xx_wms_int_in_ship_load_pk.validate_trip';
l_exists           NUMBER;

BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  SELECT 1                     
    INTO l_exists  
    FROM wsh_trips wt
   WHERE wt.name = p_trip_number;
  xx_debug_pk.debug(l_calling_sequence||', Fin',1);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_error_mesg := 'Viaje inexistente '||p_trip_number;
  WHEN OTHERS THEN
    x_error_mesg := 'Error al buscar viaje en '||l_calling_sequence||',p_trip_number: '||p_trip_number||
                    ': '||sqlerrm;
END validate_trip;

PROCEDURE validate_delivery_id (p_delivery_id        IN NUMBER
                               ,p_trip_id            IN NUMBER
                               ,x_error_mesg        OUT VARCHAR2) IS
e_error            EXCEPTION;
l_calling_sequence VARCHAR2(100):='xx_wms_int_in_ship_load_pk.validate_delivery_id';
l_exists           NUMBER;

BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  SELECT count(1)
    INTO l_exists
    FROM wsh_delivery_legs dl,
         wsh_trip_stops pickup_stop,
         wsh_trips t
   WHERE t.trip_id           = p_trip_id  
     AND dl.delivery_id      = p_delivery_id
     AND dl.pick_up_stop_id  = pickup_stop.stop_id
     AND pickup_stop.trip_id = t.trip_id;

  xx_debug_pk.debug(l_calling_sequence||', Fin',1);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_error_mesg := 'Delivery inexistente trip_id: '||p_trip_id||', delivery_id: '||p_delivery_id ;
  WHEN OTHERS THEN
    x_error_mesg := 'Error al buscar viaje en '||l_calling_sequence||' trip_id: '||p_trip_id||', delivery_id: '||p_delivery_id||
                    ': '||sqlerrm;
END validate_delivery_id;

PROCEDURE split_dd(p_facility_code  IN  VARCHAR2
                  ,p_ship_load_rec  IN  XX_WMS_INT_IN_SHIP_LOAD_PK.XX_WMS_SHIP_LOAD_REC
                  ,x_msg_data       OUT VARCHAR2) AS

e_error                    EXCEPTION;
l_inventory_item_id        NUMBER;
l_organization_id          NUMBER;
l_trip_id                  NUMBER;
l_delivery_id              NUMBER;
l_shipped_qty              NUMBER;
l_org_code                 VARCHAR2(30);
l_uom_code                 VARCHAR2(30);
l_return_status            VARCHAR2 (1);
l_split_dd_id              NUMBER;
l_split_qty                NUMBER;
l_split_qty2               NUMBER;


l_calling_sequence         VARCHAR2(100):='xx_wms_int_in_ship_load_pk.split_dd';
CURSOR c_split (p_trip_id           NUMBER
               ,p_delivery_id       NUMBER
               ,p_inventory_item_id NUMBER
               ,p_shipped_qty       NUMBER
               ,p_uom_code          VARCHAR2) IS
SELECT a.*
FROM (
SELECT wtd.trip_id
      ,wtd.delivery_id
      ,wtd.inventory_item_id
      ,wtd.requested_quantity
      ,wtd.requested_quantity_uom
      ,inv_convert.inv_um_convert (p_inventory_item_id              --Inventory Item Id
                                  ,NULL                             --Precision
                                  ,NVL (wtd.requested_quantity, 0)  --Quantity
                                  ,wtd.requested_quantity_uom       --From UOM
                                  ,p_uom_code                       --To UOM
                                  ,NULL                             --From UOM Name
                                  ,NULL                             --To UOM Name
                                  ) requested_quantity2
      ,p_uom_code requested_quantity_uom2
      ,wtd.delivery_detail_id
  FROM wsh_delivery_legs wdl
      ,wsh_trip_stops pickup_stop
      ,wsh_trip_deliverables_v wtd
      ,wsh_trips wt
 WHERE wt.trip_id                  = p_trip_id
   AND wtd.delivery_id             = p_delivery_id
   AND wtd.inventory_item_id       = p_inventory_item_id
   AND wtd.delivery_id             = wdl.delivery_id
   AND wdl.pick_up_stop_id         = pickup_stop.stop_id
   AND pickup_stop.trip_id         = wt.trip_id
   AND wtd.released_status        IN ('R','B')
 ORDER BY wtd.requested_quantity desc
)a
 WHERE a.requested_quantity2 > p_shipped_qty
   AND rownum = 1;
BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
  l_trip_id       := p_ship_load_rec.order_hdr_cust_field_1;
  l_delivery_id   := p_ship_load_rec.order_dtl_cust_field_2;
  l_shipped_qty   := p_ship_load_rec.shipped_qty;
  xx_debug_pk.debug(l_calling_sequence||',l_shipped_qty : '||l_shipped_qty,1);

  -- Obtener Organizacion de Confirmacion Despacho
  xx_debug_pk.debug(l_calling_sequence||', p_facility_code : '||p_facility_code,1);
  xx_wms_int_in_trx_pk.get_organization_id(p_facility_code, 'ORG_CONFIRM_DESPACHO',l_organization_id ,l_org_code,x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_organization_id: '||l_organization_id,1);
 
  -- Obtener Item de Confirmacion Despacho
  xx_debug_pk.debug(l_calling_sequence||', p_ship_load_rec.item_part_a: '||p_ship_load_rec.item_part_a,1);
  xx_wms_int_in_trx_pk.get_item_id(p_ship_load_rec.item_part_a, l_organization_id ,l_inventory_item_id, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_inventory_item_id: '||l_inventory_item_id,1);


  -- Obtener UOM para Declaracion de Produccion
  xx_wms_int_in_trx_pk.get_item_uom(l_inventory_item_id, 'DUN14', l_organization_id, l_uom_code, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_uom_code: '||l_uom_code,1);

  xx_debug_pk.debug(l_calling_sequence||',l_trip_id, l_delivery_id, l_inventory_item_id,l_shipped_qty, l_uom_code '||
                                        l_trip_id||', '||l_delivery_id||', '|| l_inventory_item_id||', '|| l_shipped_qty||', '|| l_uom_code ,1);

  FOR r_split IN c_split (l_trip_id, l_delivery_id, l_inventory_item_id, l_shipped_qty, l_uom_code ) LOOP

    l_split_qty := inv_convert.inv_um_convert (l_inventory_item_id              --Inventory Item Id
                                              ,NULL                             --Precision
                                              ,l_shipped_qty                    --Quantity
                                              ,l_uom_code                       --To UOM
                                              ,r_split.requested_quantity_uom   --From UOM
                                              ,NULL                             --From UOM Name
                                              ,NULL                             --To UOM Name
                                              );
    l_split_qty2 := l_shipped_qty;
    xx_debug_pk.debug(l_calling_sequence||', r_split.delivery_detail_id: '||r_split.delivery_detail_id,1);
    ------------------------------------------------------------------------
    -- API Call to Create Batch -
    ------------------------------------------------------------------------
   WSH_DELIVERY_DETAILS_ACTIONS.Split_Delivery_Details (
                             p_from_detail_id => r_split.delivery_detail_id,
                             p_req_quantity => l_split_qty,
                             p_req_quantity2 => l_split_qty2,
                             x_new_detail_id => l_split_dd_id,
                             x_return_status => l_return_status,
                             p_manual_split => 'Y'
                                );

    xx_debug_pk.debug(l_calling_sequence||', l_split_dd_id: '||l_split_dd_id,1);
    xx_debug_pk.debug(l_calling_sequence||', l_return_status: '||l_return_status,1);
    IF l_return_status != 'S' THEN
      x_msg_data := 'Error al hacer Split';
      RAISE e_error;
    END IF;

  END LOOP;
  xx_debug_pk.debug(l_calling_sequence||', Fin',1);
EXCEPTION
  WHEN e_error THEN
    NULL;
  WHEN OTHERS THEN
    x_msg_data := 'Error: '||sqlerrm;
    xx_debug_pk.debug('XX error : '||x_msg_data,1);
END split_dd;


PROCEDURE reserv_and_pick(p_facility_code  IN  VARCHAR2
                         ,p_ship_load_rec  IN  XX_WMS_INT_IN_SHIP_LOAD_PK.XX_WMS_SHIP_LOAD_REC
                         ,p_reserv_pick    IN  VARCHAR2                                                   
                         ,x_msg_data       OUT VARCHAR2) AS

e_error                    EXCEPTION;
l_organization_id          NUMBER;
l_locator_id               NUMBER;
l_inventory_item_id        NUMBER;
l_trip_id                  NUMBER;
l_delivery_id              NUMBER;
l_quantity_pend            NUMBER;
l_shipped_qty              NUMBER;
l_quantity_reserv          NUMBER;
l_dbg_requested_quantity            NUMBER;
l_dbg_shipped_quantity              NUMBER;
l_dbg_released_status               VARCHAR2(30);
l_dbg_picked_quantity2              NUMBER;
l_dbg_split_from_dd_id NUMBER;
l_dbg_new_requested_quantity            NUMBER;
l_dbg_new_shipped_quantity              NUMBER;
l_dbg_new_released_status                VARCHAR2(30);
l_dbg_new_picked_quantity2              NUMBER;
l_dbg_new_split_from_dd_id NUMBER;
l_org_code                 VARCHAR2(30);
l_uom_code                 VARCHAR2(30);
l_subinventory_code        VARCHAR2(100);
l_locator                  VARCHAR2(100);
l_calling_sequence         VARCHAR2(100):='xx_wms_int_in_ship_load_pk.reserv_and_pick';
l_qty_reserved             NUMBER;
CURSOR c_dd (p_trip_id           NUMBER
            ,p_delivery_id       NUMBER
            ,p_inventory_item_id NUMBER
            ,p_uom_code          VARCHAR2) IS 
SELECT a.*
FROM (
SELECT wtd.trip_id
      ,wtd.delivery_id
      ,wtd.inventory_item_id
      ,wtd.source_header_id
      ,wtd.source_line_id
      ,wtd.requested_quantity
      ,wtd.requested_quantity_uom
      ,inv_convert.inv_um_convert (p_inventory_item_id              --Inventory Item Id
                                  ,NULL                             --Precision
                                  ,NVL (wtd.requested_quantity, 0)  --Quantity
                                  ,wtd.requested_quantity_uom       --From UOM
                                  ,p_uom_code                       --To UOM
                                  ,NULL                             --From UOM Name
                                  ,NULL                             --To UOM Name
                                  ) quantity
      ,wtd.delivery_detail_id
      ,mso.sales_order_id
      ,inv_convert.inv_um_convert (p_inventory_item_id              --Inventory Item Id
                                  ,NULL                             --Precision
                                  ,NVL ((SELECT nvl(sum(mr.reservation_quantity),0)
                                           FROM mtl_reservations mr
                                          WHERE mr.inventory_item_id       = p_inventory_item_id
                                            AND mr.demand_source_header_id = mso.sales_order_id   
                                            AND mr.demand_source_line_id   = wtd.source_line_id), 0)  --Quantity
                                  ,wtd.requested_quantity_uom       --From UOM
                                  ,p_uom_code                       --To UOM
                                  ,NULL                             --From UOM Name
                                  ,NULL                             --To UOM Name
                                  ) reserv_qty
     ,wtd.released_status  
  FROM wsh_delivery_legs wdl
      ,wsh_trip_stops pickup_stop
      ,wsh_trip_deliverables_v wtd
      ,wsh_trips wt
      ,mtl_sales_orders mso
      ,oe_order_headers_all oh
 WHERE wt.trip_id                  = p_trip_id
   AND wtd.delivery_id             = p_delivery_id
   AND wtd.inventory_item_id       = p_inventory_item_id
   AND wtd.delivery_id             = wdl.delivery_id
   AND wdl.pick_up_stop_id         = pickup_stop.stop_id
   AND pickup_stop.trip_id         = wt.trip_id
   AND wtd.source_header_type_name = mso.segment2
   AND to_char(oh.order_number)    = mso.segment1
   AND oh.header_id                = wtd.source_header_id
   AND wtd.released_status        IN ('R','B')
)a
 WHERE a.quantity > 0                     
 ORDER BY source_header_id, delivery_detail_id;

CURSOR c_ol (p_trip_id           NUMBER
            ,p_delivery_id       NUMBER
            ,p_inventory_item_id NUMBER
            ,p_uom_code          VARCHAR2) IS 
SELECT a.trip_id
      ,a.delivery_id
      ,a.inventory_item_id
      ,a.source_header_id
      ,a.source_line_id
      ,a.sales_order_id
      ,a.requested_quantity
      ,nvl(a.qty_reserved,0) qty_reserved
FROM (
SELECT wtd.trip_id
      ,wtd.delivery_id
      ,wtd.inventory_item_id
      ,wtd.source_header_id
      ,wtd.source_line_id
      ,mso.sales_order_id
--      ,sum(wtd.requested_quantity) requested_quantity
      ,sum(inv_convert.inv_um_convert (p_inventory_item_id              --Inventory Item Id
                                  ,NULL                             --Precision
                                  ,NVL (wtd.requested_quantity, 0)  --Quantity
                                  ,wtd.requested_quantity_uom       --From UOM
                                  ,p_uom_code                       --To UOM
                                  ,NULL                             --From UOM Name
                                  ,NULL                             --To UOM Name
                                  )) requested_quantity
      ,(SELECT sum(inv_convert.inv_um_convert (p_inventory_item_id              --Inventory Item Id
                                              ,NULL                             --Precision
                                              ,NVL (mr.reservation_quantity, 0)  --Quantity
                                              ,mr.reservation_uom_code      --From UOM
                                              ,p_uom_code                       --To UOM
                                              ,NULL                             --From UOM Name
                                              ,NULL                             --To UOM Name
                                              )) q
          FROM mtl_reservations mr
         WHERE mr.inventory_item_id       = wtd.inventory_item_id
           AND mr.demand_source_header_id = wtd.source_header_id
           AND mr.demand_source_line_id   = wtd.source_line_id
       ) qty_reserved
  FROM apps.wsh_delivery_legs wdl
      ,apps.wsh_trip_stops pickup_stop
      ,apps.wsh_trip_deliverables_v wtd
      ,apps.wsh_trips wt
      ,apps.mtl_sales_orders mso
      ,apps.oe_order_headers_all oh
 WHERE wt.trip_id                  = p_trip_id
   AND wtd.delivery_id             = p_delivery_id
   AND wtd.inventory_item_id       = p_inventory_item_id
   AND wtd.delivery_id             = wdl.delivery_id
   AND wdl.pick_up_stop_id         = pickup_stop.stop_id
   AND pickup_stop.trip_id         = wt.trip_id
   AND wtd.source_header_type_name = mso.segment2
   AND to_char(oh.order_number)    = mso.segment1
   AND oh.header_id                = wtd.source_header_id
   AND wtd.released_status        IN ('R','B') 
 GROUP BY wtd.trip_id, wtd.delivery_id, wtd.inventory_item_id, wtd.source_header_id, wtd.source_line_id 
         ,mso.sales_order_id
) a
WHERE a.requested_quantity > nvl(a.qty_reserved,0) 
;

BEGIN
  xx_debug_pk.debug(l_calling_sequence||', Inicio',1);

  xx_debug_pk.debug(l_calling_sequence||', p_ship_load_rec.order_hdr_cust_field_1: '||p_ship_load_rec.order_hdr_cust_field_1,1);
  validate_trip(p_trip_number => p_ship_load_rec.order_hdr_cust_field_1
               ,x_error_mesg  => x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  -- Obtener Organizacion de Confirmacion Despacho    
  xx_debug_pk.debug(l_calling_sequence||', p_facility_code : '||p_facility_code,1);
  xx_wms_int_in_trx_pk.get_organization_id(p_facility_code, 'ORG_CONFIRM_DESPACHO',l_organization_id ,l_org_code,x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_organization_id: '||l_organization_id,1);
  -- Obtener Subinventario de Confirmacion Despacho
  xx_wms_int_in_trx_pk.get_subinventory_code(p_facility_code, 'SUBINV_CONFIRM_DESPACHO',l_subinventory_code ,x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_subinventory_code: '||l_subinventory_code,1);
  -- Obtener Locator de Confirmacion Despacho
  get_locator(p_facility_code, 'LOC_CONFIRM_DESPACHO',l_locator ,x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_locator: '||l_locator,1);

  IF l_locator IS NOT NULL THEN
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
  END IF;
  -- Obtener Item de Confirmacion Despacho    
  xx_debug_pk.debug(l_calling_sequence||', p_ship_load_rec.item_part_a: '||p_ship_load_rec.item_part_a,1);
  xx_wms_int_in_trx_pk.get_item_id(p_ship_load_rec.item_part_a, l_organization_id ,l_inventory_item_id, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_inventory_item_id: '||l_inventory_item_id,1);
  xx_debug_pk.debug(l_calling_sequence||', p_ship_load_rec.order_hdr_cust_field_1: '||p_ship_load_rec.order_hdr_cust_field_1,1);
  validate_delivery_id(p_delivery_id => p_ship_load_rec.order_dtl_cust_field_2
                      ,p_trip_id     => p_ship_load_rec.order_hdr_cust_field_1
                      ,x_error_mesg  => x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;

  -- Obtener UOM para Declaracion de Produccion
  xx_wms_int_in_trx_pk.get_item_uom(l_inventory_item_id, 'DUN14', l_organization_id, l_uom_code, x_msg_data);
  IF x_msg_data IS NOT NULL THEN
    RAISE e_error;
  END IF;
  xx_debug_pk.debug(l_calling_sequence||', l_uom_code: '||l_uom_code,1);
  xx_debug_pk.debug(l_calling_sequence||', p_ship_load_rec.order_hdr_cust_field_1: '||p_ship_load_rec.order_hdr_cust_field_1,1);
  xx_debug_pk.debug(l_calling_sequence||', p_ship_load_rec.order_dtl_cust_field_2: '||p_ship_load_rec.order_dtl_cust_field_2,1);

  l_trip_id       := p_ship_load_rec.order_hdr_cust_field_1;
  l_delivery_id   := p_ship_load_rec.order_dtl_cust_field_2;
  l_quantity_pend := p_ship_load_rec.shipped_qty;
  l_shipped_qty   := p_ship_load_rec.shipped_qty;
  xx_debug_pk.debug(l_calling_sequence||',l_quantity_pend : '||l_quantity_pend,1);
  xx_debug_pk.debug(l_calling_sequence||',l_trip_id, l_delivery_id, l_inventory_item_id, l_uom_code '||
                                        l_trip_id||', '||l_delivery_id||', '|| l_inventory_item_id||', '|| l_uom_code ,1);
  IF p_reserv_pick = 'RESERV' THEN
    FOR r_ol IN c_ol(l_trip_id, l_delivery_id, l_inventory_item_id, l_uom_code ) LOOP
      BEGIN
        SELECT nvl(sum(inv_convert.inv_um_convert (l_inventory_item_id              --Inventory Item Id
                                              ,NULL                             --Precision
                                              ,NVL (mr.reservation_quantity, 0)  --Quantity
                                              ,mr.reservation_uom_code      --From UOM
                                              ,l_uom_code                       --To UOM
                                              ,NULL                             --From UOM Name
                                              ,NULL                             --To UOM Name
                                              )),0) q
          INTO l_qty_reserved
          FROM mtl_reservations mr
         WHERE mr.inventory_item_id       = r_ol.inventory_item_id
           AND mr.demand_source_header_id = r_ol.sales_order_id
           AND mr.demand_source_line_id   = r_ol.source_line_id;
      EXCEPTION
        WHEN OTHERS THEN
          x_msg_data := 'Error al buscar cantidad reservada: '||sqlerrm;
          RAISE e_error;
      END;
          
      xx_debug_pk.debug(l_calling_sequence||',l_qty_reserved : '||l_qty_reserved,1);

      IF r_ol.requested_quantity > l_qty_reserved THEN

        IF l_quantity_pend > 0 THEN
          IF l_quantity_pend <= r_ol.requested_quantity - l_qty_reserved THEN
            l_quantity_reserv := l_quantity_pend;
            l_quantity_pend   := 0;
          ELSE
            l_quantity_reserv := r_ol.requested_quantity - l_qty_reserved;
            l_quantity_pend   := l_quantity_pend - l_quantity_reserv;
          END IF;

    xx_debug_pk.debug(l_calling_sequence||',en loop : '||l_uom_code,1);
          create_reservation (p_organization_id        => l_organization_id
                             ,p_inventory_item_id      => l_inventory_item_id
                             ,p_reservation_quantity   => l_quantity_reserv
                             ,p_uom_code               => l_uom_code
                             ,p_subinventory_code      => l_subinventory_code
                             ,p_locator_id             => l_locator_id       
                             ,p_lot_number             => p_ship_load_rec.batch_nbr  -- Lot Number
                             ,p_source_header_id       => r_ol.sales_order_id
                             ,p_source_line_id         => r_ol.source_line_id
                             ,x_error_mesg             => x_msg_data);
   
          IF x_msg_data IS NOT NULL THEN
            RAISE e_error;
          END IF;
        END IF;
      END IF;
    END LOOP;
  END IF;


  IF p_reserv_pick = 'PICK' THEN
    FOR r_dd IN c_dd(l_trip_id, l_delivery_id, l_inventory_item_id, l_uom_code ) LOOP
    xx_debug_pk.debug(l_calling_sequence||',en loop : '||l_uom_code,1);
    xx_debug_pk.debug(l_calling_sequence||',r_dd.quantity: '||r_dd.quantity,1);
    xx_debug_pk.debug(l_calling_sequence||',r_dd.released_status: '||r_dd.released_status,1);
      IF r_dd.quantity = -99999 THEN
        x_msg_data := 'Error no existe conversion entre '||r_dd.requested_quantity_uom||' y '|| l_uom_code||' ,para el item: '||p_ship_load_rec.item_part_a;
        RAISE e_error;
      END IF;
      xx_debug_pk.debug(l_calling_sequence||'  ------------------------------------------',1);
      xx_debug_pk.debug(l_calling_sequence||'  ------------------------------------------',1);
      xx_debug_pk.debug(l_calling_sequence||', r_dd.delivery_detail_id: '||r_dd.delivery_detail_id,1);
      xx_debug_pk.debug(l_calling_sequence||', l_quantity_pend: '||l_quantity_pend,1);
      xx_debug_pk.debug(l_calling_sequence||', r_dd.quantity: '||r_dd.quantity,1);
      xx_debug_pk.debug(l_calling_sequence||', r_dd.reserv_qty: '||r_dd.reserv_qty,1);
      IF l_quantity_pend > 0 THEN
        IF l_quantity_pend <= r_dd.quantity THEN
          l_quantity_reserv := l_quantity_pend;                         
          l_quantity_pend   := 0;                         
        ELSE
          l_quantity_reserv := r_dd.quantity;
          l_quantity_pend   := l_quantity_pend - l_quantity_reserv; 
        END IF;
      xx_debug_pk.debug(l_calling_sequence||', l_quantity_reserv: '||l_quantity_reserv,1);
      xx_debug_pk.debug(l_calling_sequence||', p_ship_load_rec.batch_nbr: '||p_ship_load_rec.batch_nbr,1);
      xx_debug_pk.debug(l_calling_sequence||', p_reserv_pick: '||p_reserv_pick,1);
      xx_debug_pk.debug(l_calling_sequence||'PICK: delivery_id, delivery_detail_id: '||
                                         l_delivery_id||', '|| r_dd.delivery_detail_id,1);
        pick_release (p_delivery_id            => l_delivery_id
                     ,p_delivery_detail_id     => r_dd.delivery_detail_id
                     ,x_error_mesg             => x_msg_data);   

        IF x_msg_data IS NOT NULL THEN
          RAISE e_error;
        END IF;
      END IF;

      BEGIN 
        SELECT wdd.requested_quantity
              ,wdd.shipped_quantity
              ,wdd.released_status
              ,wdd.picked_quantity2
              ,wdd.split_from_delivery_detail_id
          INTO l_dbg_requested_quantity
              ,l_dbg_shipped_quantity
              ,l_dbg_released_status
              ,l_dbg_picked_quantity2
              ,l_dbg_split_from_dd_id
          FROM wsh_delivery_details wdd
         WHERE wdd.delivery_detail_id = r_dd.delivery_detail_id;
          xx_debug_pk.debug(l_calling_sequence||',  l_dbg_requested_quantity : '||l_dbg_requested_quantity,1);
          xx_debug_pk.debug(l_calling_sequence||', l_dbg_shipped_quantity : '||l_dbg_shipped_quantity,1);
          xx_debug_pk.debug(l_calling_sequence||', l_dbg_released_status : '|| l_dbg_released_status,1);
          xx_debug_pk.debug(l_calling_sequence||', l_dbg_picked_quantity2 : '||l_dbg_picked_quantity2,1);
          xx_debug_pk.debug(l_calling_sequence||', l_dbg_split_from_dd_id : '||l_dbg_split_from_dd_id,1);
     EXCEPTION
       WHEN OTHERS THEN NULL;
     END;

     /*
     BEGIN 
        SELECT wdd.requested_quantity
              ,wdd.shipped_quantity
              ,wdd.released_status
              ,wdd.picked_quantity2
              ,wdd.split_from_delivery_detail_id
          INTO l_dbg_new_requested_quantity
              ,l_dbg_new_shipped_quantity
              ,l_dbg_new_released_status
              ,l_dbg_new_picked_quantity2
              ,l_dbg_new_split_from_dd_id
          FROM wsh_delivery_details wdd
         WHERE wdd.split_from_delivery_detail_id = r_dd.delivery_detail_id;
          xx_debug_pk.debug(l_calling_sequence||',  l_dbg_new_requested_quantity : '||l_dbg_new_requested_quantity,1);
          xx_debug_pk.debug(l_calling_sequence||', l_dbg_new_shipped_quantity : '||l_dbg_new_shipped_quantity,1);
          xx_debug_pk.debug(l_calling_sequence||', l_dbg_new_released_status : '|| l_dbg_new_released_status,1);
          xx_debug_pk.debug(l_calling_sequence||', l_dbg_new_picked_quantity2 : '||l_dbg_new_picked_quantity2,1);
          xx_debug_pk.debug(l_calling_sequence||', l_dbg_new_split_from_dd_id : '||l_dbg_new_split_from_dd_id,1);
     EXCEPTION
       WHEN OTHERS THEN NULL;
     END;
     */


    END LOOP; 

    xx_debug_pk.debug(l_calling_sequence||', l_quantity_pend: '||l_quantity_pend,1);
    xx_debug_pk.debug(l_calling_sequence||', l_shipped_qty: '||l_shipped_qty,1);
    --IF l_quantity_pend > 0 THEN
    --  x_msg_data := 'No se pudo Confirmar el total, cantidad linea: '||p_ship_load_rec.shipped_qty||
    --                ', cantidad confirmada: '||to_char(l_shipped_qty - l_quantity_pend);
    --END IF;
  END IF;

  xx_debug_pk.debug(l_calling_sequence||', Fin',1);
EXCEPTION
  WHEN e_error THEN
    NULL;    
  WHEN OTHERS THEN
    x_msg_data := 'Error: '||sqlerrm;
    xx_debug_pk.debug('XX error : '||x_msg_data,1);
END reserv_and_pick;

PROCEDURE process_integration
(p_int_type                  IN  VARCHAR2
,p_message_id                IN  VARCHAR2
,p_facility_code             IN  VARCHAR2
,p_company_code              IN  VARCHAR2
,p_route_nbr                 IN  VARCHAR2
,p_ship_load_tab             IN  XX_WMS_INT_IN_SHIP_LOAD_PK.XX_WMS_SHIP_LOAD_TAB
,x_request_id                OUT NUMBER
,x_return_status             OUT VARCHAR2
,x_msg_data                  OUT VARCHAR2
) AS

CURSOR c_ship IS
SELECT xwiisl.rowid row_id
      ,xwiisl.*
  FROM xx_wms_int_in_ship_load xwiisl
 WHERE xwiisl.message_id = p_message_id
   AND xwiisl.status     = 'RUNNING' --'NEW'
 ORDER BY xwiisl.line_nbr
;

CURSOR c_unassig IS
SELECT distinct wtd.delivery_id, wtd.delivery_detail_id
  FROM wsh_delivery_legs wdl
      ,wsh_trip_stops pickup_stop
      ,wsh_trip_deliverables_v wtd
      ,wsh_trips wt
      ,mtl_system_items msi
      ,xx_wms_int_in_ship_load xwii
 WHERE 1=1
   AND xwii.message_id             = p_message_id
   AND wtd.delivery_id             = wdl.delivery_id
   AND wdl.pick_up_stop_id         = pickup_stop.stop_id
   AND pickup_stop.trip_id         = wt.trip_id
   AND wtd.released_status         = 'R'
   AND xwii.order_hdr_cust_field_1 = wt.trip_id                  
  -- AND xwii.order_dtl_cust_field_2 = wtd.delivery_id
   AND xwii.status                 = 'OK'
   AND xwii.item_part_a            = msi.segment1
   AND wtd.organization_id         = msi.organization_id
;

CURSOR c_unassig_delivery IS
SELECT DISTINCT wt.trip_id, wnd.delivery_id
  FROM wsh_new_deliveries wnd
      ,wsh_delivery_legs wdl
      ,wsh_trip_stops wtsp
      ,wsh_trip_stops wtsd
      ,xx_wms_int_in_ship_load xwii
      ,wsh_trips wt
 WHERE 1=1
   AND xwii.message_id             = p_message_id
   AND xwii.order_hdr_cust_field_1 = wt.trip_id
   AND wdl.delivery_id             = wnd.delivery_id
   AND wtsp.stop_id                = wdl.pick_up_stop_id
   AND wtsd.stop_id                = wdl.drop_off_stop_id
   AND wt.trip_id                  = wtsp.trip_id
   AND NOT EXISTS (SELECT 1 
                     FROM wsh_delivery_assignments wda
                    WHERE wnd.delivery_id = wda.delivery_id)
;


l_calling_sequence         VARCHAR2(100):='xx_wms_int_in_ship_load_pk.process_integration';

l_ship_load_rec    XX_WMS_INT_IN_SHIP_LOAD_PK.XX_WMS_SHIP_LOAD_REC;
l_error_mesg       VARCHAR2(2000);
l_error_count      NUMBER:=0;
e_error            EXCEPTION;

BEGIN
  IF nvl(fnd_profile.value('XX_DEBUG_ENABLED'), 'N') = 'Y' THEN
    xx_debug_pk.force_on(p_output          => 'DB_TABLE'
                     ,p_level           => 1
                     ,p_directory       => NULL
                     ,p_file            => NULL
                     ,p_other_statement => NULL
                     ,p_message_length  => 4000
                     );
 END IF;

    xx_debug_pk.debug(l_calling_sequence||', Inicio',1);
    xx_debug_pk.debug(l_calling_sequence||', p_message_id : '||p_message_id,1);
    xx_debug_pk.debug(l_calling_sequence||', p_facility_code : '||p_facility_code,1);
    xx_debug_pk.debug(l_calling_sequence||', p_company_code : '||p_company_code,1);
    xx_debug_pk.debug(l_calling_sequence||', p_route_nbr : '||p_route_nbr,1);

    xx_debug_pk.debug(l_calling_sequence||', p_ship_load_tab.count : '||p_ship_load_tab.count,1);
    DELETE xx_wms_int_in_ship_load xwiisp
     WHERE xwiisp.message_id = p_message_id
       AND xwiisp.status = 'ERROR';
  IF p_ship_load_tab.count > 0  THEN
    FOR i IN 1..p_ship_load_tab.count LOOP
      xx_debug_pk.debug(l_calling_sequence||', p_ship_load_tab.order_hdr_cust_field_1 : '||p_ship_load_tab(i).order_hdr_cust_field_1,1);
      xx_debug_pk.debug(l_calling_sequence||', p_ship_load_tab.ob_lpn_nbr : '||p_ship_load_tab(i).ob_lpn_nbr,1);
      xx_debug_pk.debug(l_calling_sequence||', p_ship_load_tab.item_alternate_code : '||p_ship_load_tab(i).item_alternate_code,1);
      xx_debug_pk.debug(l_calling_sequence||', p_ship_load_tab.item_part_a : '||p_ship_load_tab(i).item_part_a,1);
      xx_debug_pk.debug(l_calling_sequence||', p_ship_load_tab.shipped_qty : '||p_ship_load_tab(i).shipped_qty,1);

      BEGIN
        INSERT INTO xx_wms_int_in_ship_load 
          ( INTEGRATION_TYPE        
           ,LINE_NBR              
           ,SEQ_NBR               
           ,STOP_SHIPMENT_NBR     
           ,STOP_BOL_NBR          
           ,STOP_NBR_OF_OBLPNS    
           ,STOP_WEIGHT           
           ,STOP_VOLUME           
           ,STOP_SHIPPING_CHARGE  
           ,SHIPTO_FACILITY_CODE   
           ,SHIPTO_NAME1           
           ,SHIPTO_ADDR1           
           ,SHIPTO_ADDR2           
           ,SHIPTO_ADDR3           
           ,SHIPTO_CITY            
           ,SHIPTO_STATE           
           ,SHIPTO_ZIP             
           ,SHIPTO_COUNTRY         
           ,SHIPTO_PHONE_NBR       
           ,SHIPTO_EMAIL           
           ,SHIPTO_CONTACT         
           ,DEST_FACILITY_CODE     
           ,CUST_NAME1             
           ,CUST_ADDR1             
           ,CUST_ADDR2             
           ,CUST_ADDR3             
           ,CUST_CITY              
           ,CUST_STATE             
           ,CUST_ZIP               
           ,CUST_COUNTRY           
           ,CUST_PHONE_NBR         
           ,CUST_EMAIL             
           ,CUST_CONTACT           
           ,CUST_NBR               
           ,ORDER_NBR              
           ,ORD_DATE               
           ,EXP_DATE               
           ,REQ_SHIP_DATE          
           ,START_SHIP_DATE        
           ,STOP_SHIP_DATE         
           ,HOST_ALLOCATION_NBR   
           ,CUSTOMER_PO_NBR       
           ,SALES_ORDER_NBR       
           ,SALES_CHANNEL          
           ,DEST_DEPT_NBR         
           ,ORDER_HDR_CUST_FIELD_1 
           ,ORDER_HDR_CUST_FIELD_2 
           ,ORDER_HDR_CUST_FIELD_3 
           ,ORDER_HDR_CUST_FIELD_4 
           ,ORDER_HDR_CUST_FIELD_5 
           ,ORDER_SEQ_NBR         
           ,ORDER_DTL_CUST_FIELD_1 
           ,ORDER_DTL_CUST_FIELD_2 
           ,ORDER_DTL_CUST_FIELD_3 
           ,ORDER_DTL_CUST_FIELD_4 
           ,ORDER_DTL_CUST_FIELD_5 
           ,OB_LPN_NBR             
           ,ITEM_ALTERNATE_CODE    
           ,ITEM_PART_A            
           ,ITEM_PART_B            
           ,ITEM_PART_C            
           ,ITEM_PART_D            
           ,ITEM_PART_E            
           ,ITEM_PART_F            
           ,PRE_PACK_CODE          
           ,PRE_PACK_RATIO        
           ,PRE_PACK_RATIO_SEQ    
           ,PRE_PACK_TOTAL_UNITS  
           ,INVN_ATTR_A            
           ,INVN_ATTR_B            
           ,INVN_ATTR_C            
           ,HAZMAT                 
           ,SHIPPED_UOM            
           ,SHIPPED_QTY            
           ,PALLET_NBR             
           ,DEST_COMPANY_CODE      
           ,BATCH_NBR              
           ,EXPIRY_DATE            
           ,TRACKING_NBR          
           ,MASTER_TRACKING_NBR   
           ,PACKAGE_TYPE           
           ,PAYMENT_METHOD         
           ,CARRIER_ACCOUNT_NBR   
           ,SHIP_VIA_CODE          
           ,OB_LPN_WEIGHT         
           ,OB_LPN_VOLUME         
           ,OB_LPN_SHIPPING_CHARGE
           ,OB_LPN_TYPE            
           ,OB_LPN_ASSET_NBR      
           ,OB_LPN_ASSET_SEAL_NBR 
           ,SERIAL_NBR            
           ,CUSTOMER_PO_TYPE       
           ,CUSTOMER_VENDOR_CODE   
           ,ORDER_HDR_CUST_DATE_1  
           ,ORDER_HDR_CUST_DATE_2  
           ,ORDER_HDR_CUST_DATE_3  
           ,ORDER_HDR_CUST_DATE_4  
           ,ORDER_HDR_CUST_DATE_5  
           ,ORDER_HDR_CUST_NUMBER_1     
           ,ORDER_HDR_CUST_NUMBER_2     
           ,ORDER_HDR_CUST_NUMBER_3     
           ,ORDER_HDR_CUST_NUMBER_4     
           ,ORDER_HDR_CUST_NUMBER_5     
           ,ORDER_HDR_CUST_DECIMAL_1    
           ,ORDER_HDR_CUST_DECIMAL_2    
           ,ORDER_HDR_CUST_DECIMAL_3    
           ,ORDER_HDR_CUST_DECIMAL_4    
           ,ORDER_HDR_CUST_DECIMAL_5    
           ,ORDER_HDR_CUST_SHORT_TEXT_1    
           ,ORDER_HDR_CUST_SHORT_TEXT_2    
           ,ORDER_HDR_CUST_SHORT_TEXT_3    
           ,ORDER_HDR_CUST_SHORT_TEXT_4    
           ,ORDER_HDR_CUST_SHORT_TEXT_5    
           ,ORDER_HDR_CUST_SHORT_TEXT_6    
           ,ORDER_HDR_CUST_SHORT_TEXT_7    
           ,ORDER_HDR_CUST_SHORT_TEXT_8    
           ,ORDER_HDR_CUST_SHORT_TEXT_9    
           ,ORDER_HDR_CUST_SHORT_TEXT_10    
           ,ORDER_HDR_CUST_SHORT_TEXT_11    
           ,ORDER_HDR_CUST_SHORT_TEXT_12    
           ,ORDER_HDR_CUST_LONG_TEXT_1    
           ,ORDER_HDR_CUST_LONG_TEXT_2    
           ,ORDER_HDR_CUST_LONG_TEXT_3    
           ,ORDER_DTL_CUST_DATE_1    
           ,ORDER_DTL_CUST_DATE_2    
           ,ORDER_DTL_CUST_DATE_3    
           ,ORDER_DTL_CUST_DATE_4    
           ,ORDER_DTL_CUST_DATE_5    
           ,ORDER_DTL_CUST_NUMBER_1  
           ,ORDER_DTL_CUST_NUMBER_2  
           ,ORDER_DTL_CUST_NUMBER_3  
           ,ORDER_DTL_CUST_NUMBER_4  
           ,ORDER_DTL_CUST_NUMBER_5  
           ,ORDER_DTL_CUST_DECIMAL_1  
           ,ORDER_DTL_CUST_DECIMAL_2  
           ,ORDER_DTL_CUST_DECIMAL_3  
           ,ORDER_DTL_CUST_DECIMAL_4  
           ,ORDER_DTL_CUST_DECIMAL_5  
           ,ORDER_DTL_CUST_SHORT_TEXT_1    
           ,ORDER_DTL_CUST_SHORT_TEXT_2    
           ,ORDER_DTL_CUST_SHORT_TEXT_3    
           ,ORDER_DTL_CUST_SHORT_TEXT_4    
           ,ORDER_DTL_CUST_SHORT_TEXT_5    
           ,ORDER_DTL_CUST_SHORT_TEXT_6    
           ,ORDER_DTL_CUST_SHORT_TEXT_7    
           ,ORDER_DTL_CUST_SHORT_TEXT_8    
           ,ORDER_DTL_CUST_SHORT_TEXT_9    
           ,ORDER_DTL_CUST_SHORT_TEXT_10    
           ,ORDER_DTL_CUST_SHORT_TEXT_11    
           ,ORDER_DTL_CUST_SHORT_TEXT_12    
           ,ORDER_DTL_CUST_LONG_TEXT_1    
           ,ORDER_DTL_CUST_LONG_TEXT_2    
           ,ORDER_DTL_CUST_LONG_TEXT_3    
           ,INVN_ATTR_D    
           ,INVN_ATTR_E    
           ,INVN_ATTR_F    
           ,INVN_ATTR_G    
           ,MESSAGE_ID              
           ,FACILITY_CODE           
           ,COMPANY_CODE            
           ,ROUTE_NBR               
           ,STATUS                  
           ,ERROR_MESG              
           ,CREATION_DATE           
           ,CREATED_BY              
           ,LAST_UPDATE_DATE        
           ,LAST_UPDATED_BY         
          )
        SELECT p_int_type      -- INTEGRATION_TYPE        
              ,p_ship_load_tab(i).LINE_NBR              
              ,p_ship_load_tab(i).SEQ_NBR               
              ,p_ship_load_tab(i).STOP_SHIPMENT_NBR     
              ,p_ship_load_tab(i).STOP_BOL_NBR          
              ,p_ship_load_tab(i).STOP_NBR_OF_OBLPNS    
              ,p_ship_load_tab(i).STOP_WEIGHT           
              ,p_ship_load_tab(i).STOP_VOLUME           
              ,p_ship_load_tab(i).STOP_SHIPPING_CHARGE  
              ,p_ship_load_tab(i).SHIPTO_FACILITY_CODE   
              ,p_ship_load_tab(i).SHIPTO_NAME1           
              ,p_ship_load_tab(i).SHIPTO_ADDR1           
              ,p_ship_load_tab(i).SHIPTO_ADDR2           
              ,p_ship_load_tab(i).SHIPTO_ADDR3           
              ,p_ship_load_tab(i).SHIPTO_CITY            
              ,p_ship_load_tab(i).SHIPTO_STATE           
              ,p_ship_load_tab(i).SHIPTO_ZIP             
              ,p_ship_load_tab(i).SHIPTO_COUNTRY         
              ,p_ship_load_tab(i).SHIPTO_PHONE_NBR       
              ,p_ship_load_tab(i).SHIPTO_EMAIL           
              ,p_ship_load_tab(i).SHIPTO_CONTACT         
              ,p_ship_load_tab(i).DEST_FACILITY_CODE     
              ,p_ship_load_tab(i).CUST_NAME1             
              ,p_ship_load_tab(i).CUST_ADDR1             
              ,p_ship_load_tab(i).CUST_ADDR2             
              ,p_ship_load_tab(i).CUST_ADDR3             
              ,p_ship_load_tab(i).CUST_CITY              
              ,p_ship_load_tab(i).CUST_STATE             
              ,p_ship_load_tab(i).CUST_ZIP               
              ,p_ship_load_tab(i).CUST_COUNTRY           
              ,p_ship_load_tab(i).CUST_PHONE_NBR         
              ,p_ship_load_tab(i).CUST_EMAIL             
              ,p_ship_load_tab(i).CUST_CONTACT           
              ,p_ship_load_tab(i).CUST_NBR               
              ,p_ship_load_tab(i).ORDER_NBR              
              ,p_ship_load_tab(i).ORD_DATE               
              ,p_ship_load_tab(i).EXP_DATE               
              ,p_ship_load_tab(i).REQ_SHIP_DATE          
              ,p_ship_load_tab(i).START_SHIP_DATE        
              ,p_ship_load_tab(i).STOP_SHIP_DATE         
              ,p_ship_load_tab(i).HOST_ALLOCATION_NBR   
              ,p_ship_load_tab(i).CUSTOMER_PO_NBR       
              ,p_ship_load_tab(i).SALES_ORDER_NBR       
              ,p_ship_load_tab(i).SALES_CHANNEL          
              ,p_ship_load_tab(i).DEST_DEPT_NBR         
              ,p_ship_load_tab(i).ORDER_HDR_CUST_FIELD_1 
              ,p_ship_load_tab(i).ORDER_HDR_CUST_FIELD_2 
              ,p_ship_load_tab(i).ORDER_HDR_CUST_FIELD_3 
              ,p_ship_load_tab(i).ORDER_HDR_CUST_FIELD_4 
              ,p_ship_load_tab(i).ORDER_HDR_CUST_FIELD_5 
              ,p_ship_load_tab(i).ORDER_SEQ_NBR         
              ,p_ship_load_tab(i).ORDER_DTL_CUST_FIELD_1 
              ,p_ship_load_tab(i).ORDER_DTL_CUST_FIELD_2 
              ,p_ship_load_tab(i).ORDER_DTL_CUST_FIELD_3 
              ,p_ship_load_tab(i).ORDER_DTL_CUST_FIELD_4 
              ,p_ship_load_tab(i).ORDER_DTL_CUST_FIELD_5 
              ,p_ship_load_tab(i).OB_LPN_NBR             
              ,p_ship_load_tab(i).ITEM_ALTERNATE_CODE    
              ,p_ship_load_tab(i).ITEM_PART_A            
              ,p_ship_load_tab(i).ITEM_PART_B            
              ,p_ship_load_tab(i).ITEM_PART_C            
              ,p_ship_load_tab(i).ITEM_PART_D            
              ,p_ship_load_tab(i).ITEM_PART_E            
              ,p_ship_load_tab(i).ITEM_PART_F            
              ,p_ship_load_tab(i).PRE_PACK_CODE          
              ,p_ship_load_tab(i).PRE_PACK_RATIO        
              ,p_ship_load_tab(i).PRE_PACK_RATIO_SEQ    
              ,p_ship_load_tab(i).PRE_PACK_TOTAL_UNITS  
              ,p_ship_load_tab(i).INVN_ATTR_A            
              ,p_ship_load_tab(i).INVN_ATTR_B            
              ,p_ship_load_tab(i).INVN_ATTR_C            
              ,p_ship_load_tab(i).HAZMAT                 
              ,p_ship_load_tab(i).SHIPPED_UOM            
              ,p_ship_load_tab(i).SHIPPED_QTY            
              ,p_ship_load_tab(i).PALLET_NBR             
              ,p_ship_load_tab(i).DEST_COMPANY_CODE      
              ,p_ship_load_tab(i).BATCH_NBR              
              ,p_ship_load_tab(i).EXPIRY_DATE            
              ,p_ship_load_tab(i).TRACKING_NBR          
              ,p_ship_load_tab(i).MASTER_TRACKING_NBR   
              ,p_ship_load_tab(i).PACKAGE_TYPE           
              ,p_ship_load_tab(i).PAYMENT_METHOD         
              ,p_ship_load_tab(i).CARRIER_ACCOUNT_NBR   
              ,p_ship_load_tab(i).SHIP_VIA_CODE          
              ,p_ship_load_tab(i).OB_LPN_WEIGHT         
              ,p_ship_load_tab(i).OB_LPN_VOLUME         
              ,p_ship_load_tab(i).OB_LPN_SHIPPING_CHARGE
              ,p_ship_load_tab(i).OB_LPN_TYPE            
              ,p_ship_load_tab(i).OB_LPN_ASSET_NBR      
              ,p_ship_load_tab(i).OB_LPN_ASSET_SEAL_NBR 
              ,p_ship_load_tab(i).SERIAL_NBR            
              ,p_ship_load_tab(i).CUSTOMER_PO_TYPE       
              ,p_ship_load_tab(i).CUSTOMER_VENDOR_CODE   
              ,p_ship_load_tab(i).ORDER_HDR_CUST_DATE_1  
              ,p_ship_load_tab(i).ORDER_HDR_CUST_DATE_2  
              ,p_ship_load_tab(i).ORDER_HDR_CUST_DATE_3  
              ,p_ship_load_tab(i).ORDER_HDR_CUST_DATE_4  
              ,p_ship_load_tab(i).ORDER_HDR_CUST_DATE_5  
              ,p_ship_load_tab(i).ORDER_HDR_CUST_NUMBER_1     
              ,p_ship_load_tab(i).ORDER_HDR_CUST_NUMBER_2     
              ,p_ship_load_tab(i).ORDER_HDR_CUST_NUMBER_3     
              ,p_ship_load_tab(i).ORDER_HDR_CUST_NUMBER_4     
              ,p_ship_load_tab(i).ORDER_HDR_CUST_NUMBER_5     
              ,p_ship_load_tab(i).ORDER_HDR_CUST_DECIMAL_1    
              ,p_ship_load_tab(i).ORDER_HDR_CUST_DECIMAL_2    
              ,p_ship_load_tab(i).ORDER_HDR_CUST_DECIMAL_3    
              ,p_ship_load_tab(i).ORDER_HDR_CUST_DECIMAL_4    
              ,p_ship_load_tab(i).ORDER_HDR_CUST_DECIMAL_5    
              ,p_ship_load_tab(i).ORDER_HDR_CUST_SHORT_TEXT_1    
              ,p_ship_load_tab(i).ORDER_HDR_CUST_SHORT_TEXT_2    
              ,p_ship_load_tab(i).ORDER_HDR_CUST_SHORT_TEXT_3    
              ,p_ship_load_tab(i).ORDER_HDR_CUST_SHORT_TEXT_4    
              ,p_ship_load_tab(i).ORDER_HDR_CUST_SHORT_TEXT_5    
              ,p_ship_load_tab(i).ORDER_HDR_CUST_SHORT_TEXT_6    
              ,p_ship_load_tab(i).ORDER_HDR_CUST_SHORT_TEXT_7    
              ,p_ship_load_tab(i).ORDER_HDR_CUST_SHORT_TEXT_8    
              ,p_ship_load_tab(i).ORDER_HDR_CUST_SHORT_TEXT_9    
              ,p_ship_load_tab(i).ORDER_HDR_CUST_SHORT_TEXT_10    
              ,p_ship_load_tab(i).ORDER_HDR_CUST_SHORT_TEXT_11    
              ,p_ship_load_tab(i).ORDER_HDR_CUST_SHORT_TEXT_12    
              ,p_ship_load_tab(i).ORDER_HDR_CUST_LONG_TEXT_1    
              ,p_ship_load_tab(i).ORDER_HDR_CUST_LONG_TEXT_2    
              ,p_ship_load_tab(i).ORDER_HDR_CUST_LONG_TEXT_3    
              ,p_ship_load_tab(i).ORDER_DTL_CUST_DATE_1    
              ,p_ship_load_tab(i).ORDER_DTL_CUST_DATE_2    
              ,p_ship_load_tab(i).ORDER_DTL_CUST_DATE_3    
              ,p_ship_load_tab(i).ORDER_DTL_CUST_DATE_4    
              ,p_ship_load_tab(i).ORDER_DTL_CUST_DATE_5    
              ,p_ship_load_tab(i).ORDER_DTL_CUST_NUMBER_1  
              ,p_ship_load_tab(i).ORDER_DTL_CUST_NUMBER_2  
              ,p_ship_load_tab(i).ORDER_DTL_CUST_NUMBER_3  
              ,p_ship_load_tab(i).ORDER_DTL_CUST_NUMBER_4  
              ,p_ship_load_tab(i).ORDER_DTL_CUST_NUMBER_5  
              ,p_ship_load_tab(i).ORDER_DTL_CUST_DECIMAL_1  
              ,p_ship_load_tab(i).ORDER_DTL_CUST_DECIMAL_2  
              ,p_ship_load_tab(i).ORDER_DTL_CUST_DECIMAL_3  
              ,p_ship_load_tab(i).ORDER_DTL_CUST_DECIMAL_4  
              ,p_ship_load_tab(i).ORDER_DTL_CUST_DECIMAL_5  
              ,p_ship_load_tab(i).ORDER_DTL_CUST_SHORT_TEXT_1    
              ,p_ship_load_tab(i).ORDER_DTL_CUST_SHORT_TEXT_2    
              ,p_ship_load_tab(i).ORDER_DTL_CUST_SHORT_TEXT_3    
              ,p_ship_load_tab(i).ORDER_DTL_CUST_SHORT_TEXT_4    
              ,p_ship_load_tab(i).ORDER_DTL_CUST_SHORT_TEXT_5    
              ,p_ship_load_tab(i).ORDER_DTL_CUST_SHORT_TEXT_6    
              ,p_ship_load_tab(i).ORDER_DTL_CUST_SHORT_TEXT_7    
              ,p_ship_load_tab(i).ORDER_DTL_CUST_SHORT_TEXT_8    
              ,p_ship_load_tab(i).ORDER_DTL_CUST_SHORT_TEXT_9    
              ,p_ship_load_tab(i).ORDER_DTL_CUST_SHORT_TEXT_10    
              ,p_ship_load_tab(i).ORDER_DTL_CUST_SHORT_TEXT_11    
              ,p_ship_load_tab(i).ORDER_DTL_CUST_SHORT_TEXT_12    
              ,p_ship_load_tab(i).ORDER_DTL_CUST_LONG_TEXT_1    
              ,p_ship_load_tab(i).ORDER_DTL_CUST_LONG_TEXT_2    
              ,p_ship_load_tab(i).ORDER_DTL_CUST_LONG_TEXT_3    
              ,p_ship_load_tab(i).INVN_ATTR_D    
              ,p_ship_load_tab(i).INVN_ATTR_E    
              ,p_ship_load_tab(i).INVN_ATTR_F    
              ,p_ship_load_tab(i).INVN_ATTR_G    
              ,p_message_id       --MESSAGE_ID
              ,p_facility_code    --FACILITY_CODE
              ,p_company_code     --COMPANY_CODE
              ,p_route_nbr        --ROUTE_NBR    
              ,'NEW'              --STATUS
              ,''                 --MESG_ERROR
              ,sysdate            --CREATION_DATE
              ,fnd_global.user_id --CREATED_BY
              ,sysdate            --LAST_UPDATE_DATE
              ,fnd_global.user_id --LAST_UPDATED_BY
          FROM DUAL
         WHERE NOT EXISTS (SELECT 1
                             FROM xx_wms_int_in_ship_load
                            WHERE message_id              = p_message_id
                           -- Cambio 26-02-20
                              AND line_nbr                = p_ship_load_tab(i).line_nbr 
                              AND seq_nbr                 = p_ship_load_tab(i).seq_nbr 
                              --AND order_hdr_cust_field_1  = p_ship_load_tab(i).order_hdr_cust_field_1      
                              --AND order_dtl_cust_field_2  = p_ship_load_tab(i).order_dtl_cust_field_2
                              --AND item_part_a             = p_ship_load_tab(i).item_part_a
                              --AND ob_lpn_nbr              = p_ship_load_tab(i).ob_lpn_nbr
                           -- Fin Cambio 26-02-20
                          )
               ;
      EXCEPTION
        WHEN OTHERS THEN
         x_msg_data := 'Error al insertar en xx_wms_int_in_ship_load: '||sqlerrm; 
         RAISE e_error;
      END;
    END LOOP;
    COMMIT;
    xx_debug_pk.debug(l_calling_sequence||',  Validate message_id: '||p_message_id,1);
    validate_message_id(p_message_id,l_error_mesg);
    IF l_error_mesg IS NOT NULL THEN
      xx_debug_pk.debug(l_calling_sequence||',  update status : '||l_error_mesg,1);

      BEGIN
        update_status(p_status       => 'ERROR'
                     ,p_error_mesg   => l_error_mesg
                     ,p_message_id   => p_message_id
                     ,p_row_id       => '');
      EXCEPTION
        WHEN OTHERS THEN
          x_msg_data := 'Error al actualizar el estado en xx_wms_int_in_ship_load: '||sqlerrm;
          RAISE e_error;
      END;
    END IF;

    control_concurrencia(p_message_id,l_error_mesg);
    IF l_error_mesg IS NOT NULL THEN
      xx_debug_pk.debug(l_calling_sequence||',  update status : '||l_error_mesg,1);

      BEGIN
        update_status(p_status       => 'ERROR'
                     ,p_error_mesg   => l_error_mesg
                     ,p_message_id   => p_message_id
                     ,p_row_id       => '');
      EXCEPTION
        WHEN OTHERS THEN
          x_msg_data := 'Error al actualizar el estado en xx_wms_int_in_ship_load: '||sqlerrm;
          RAISE e_error;
      END;
    END IF;

    xx_debug_pk.debug(l_calling_sequence||', LOOP r_ship',1);
    FOR r_ship IN c_ship LOOP
      -- Recorro el loop de ship para hacer los split de los delivery_details antes de hacer las reservas y pick release
      l_error_mesg := '';
      xx_debug_pk.debug(l_calling_sequence||', r_ship.order_hdr_cust_field_1: '||r_ship.order_hdr_cust_field_1,1);
      xx_debug_pk.debug(l_calling_sequence||', r_ship.item_part_a: '||r_ship.item_part_a,1);
      xx_debug_pk.debug(l_calling_sequence||', r_ship.order_dtl_cust_field_2: '||r_ship.order_dtl_cust_field_2,1);
      l_ship_load_rec.order_hdr_cust_field_1         := r_ship.order_hdr_cust_field_1;   -- Viaje
      l_ship_load_rec.order_hdr_cust_field_2         := r_ship.order_hdr_cust_field_1;   -- Viaje
      l_ship_load_rec.item_part_a                    := r_ship.item_part_a;   -- Item Code
      l_ship_load_rec.req_ship_date                  := r_ship.req_ship_date;   -- Requirement Date
      l_ship_load_rec.shipped_qty                    := r_ship.shipped_qty;   -- Shipped Quantity
      l_ship_load_rec.batch_nbr                      := r_ship.batch_nbr;   -- Lot Number
      l_ship_load_rec.order_dtl_cust_field_2         := r_ship.order_dtl_cust_field_2;   -- Numero de Entrega
      l_ship_load_rec.order_dtl_cust_field_3         := r_ship.order_dtl_cust_field_3;   -- Numero de Pedido, puede venir concatenado con comas si son varios
      l_ship_load_rec.order_dtl_cust_field_4         := r_ship.order_dtl_cust_field_4;   -- Tipo de Pedido, puede venir concatenado con comas si son varios
      l_ship_load_rec.order_dtl_cust_field_5         := r_ship.order_dtl_cust_field_5;   -- Numero de Parada


      -- Procesar Confirmacion Viaje
      split_dd(p_facility_code
              ,l_ship_load_rec
              ,l_error_mesg);
      IF l_error_mesg IS NOT NULL THEN
        xx_debug_pk.debug(l_calling_sequence||', update status : '||l_error_mesg,1);

        BEGIN
          update_status(p_status       => 'ERROR'
                       ,p_error_mesg   => l_error_mesg
                       ,p_message_id   => p_message_id
                       ,p_row_id       => r_ship.row_id);
        EXCEPTION
          WHEN OTHERS THEN
            x_msg_data := 'Error al actualizar el estado en xx_wms_int_in_ship_load: '||sqlerrm;
            RAISE e_error;
        END;
      END IF;
    END LOOP;
    xx_debug_pk.debug(l_calling_sequence||', LOOP r_ship RESERV',1);
    COMMIT;
    FOR r_ship IN c_ship LOOP
      l_error_mesg := '';
      xx_debug_pk.debug(l_calling_sequence||', r_ship.order_hdr_cust_field_1: '||r_ship.order_hdr_cust_field_1,1);
      xx_debug_pk.debug(l_calling_sequence||', r_ship.item_part_a: '||r_ship.item_part_a,1);
      xx_debug_pk.debug(l_calling_sequence||', r_ship.order_dtl_cust_field_2: '||r_ship.order_dtl_cust_field_2,1);
      l_ship_load_rec.order_hdr_cust_field_1         := r_ship.order_hdr_cust_field_1;   -- Viaje     
      l_ship_load_rec.order_hdr_cust_field_2         := r_ship.order_hdr_cust_field_1;   -- Viaje     
      l_ship_load_rec.item_part_a                    := r_ship.item_part_a;   -- Item Code
      l_ship_load_rec.req_ship_date                  := r_ship.req_ship_date;   -- Requirement Date
      l_ship_load_rec.shipped_qty                    := r_ship.shipped_qty;   -- Shipped Quantity
      l_ship_load_rec.batch_nbr                      := r_ship.batch_nbr;   -- Lot Number       
      l_ship_load_rec.order_dtl_cust_field_2         := r_ship.order_dtl_cust_field_2;   -- Numero de Entrega
      l_ship_load_rec.order_dtl_cust_field_3         := r_ship.order_dtl_cust_field_3;   -- Numero de Pedido, puede venir concatenado con comas si son varios
      l_ship_load_rec.order_dtl_cust_field_4         := r_ship.order_dtl_cust_field_4;   -- Tipo de Pedido, puede venir concatenado con comas si son varios
      l_ship_load_rec.order_dtl_cust_field_5         := r_ship.order_dtl_cust_field_5;   -- Numero de Parada
  
      -- Procesar Confirmacion Viaje
      reserv_and_pick(p_facility_code
                     ,l_ship_load_rec
                     ,'RESERV'
                     ,l_error_mesg); 
    
      IF l_error_mesg IS NOT NULL THEN  
        xx_debug_pk.debug(l_calling_sequence||', update status : '||l_error_mesg,1);
     
        BEGIN
          update_status(p_status       => 'ERROR'            
                       ,p_error_mesg   => l_error_mesg
                       ,p_message_id   => p_message_id
                       ,p_row_id       => r_ship.row_id);
        EXCEPTION
          WHEN OTHERS THEN
            x_msg_data := 'Error al actualizar el estado en xx_wms_int_in_ship_load: '||sqlerrm;
            RAISE e_error;
        END;
      END IF;
    END LOOP;
    --COMMIT;

    xx_debug_pk.debug(l_calling_sequence||', LOOP r_ship PICK',1);
    FOR r_ship IN c_ship LOOP
      l_error_mesg := '';
      xx_debug_pk.debug(l_calling_sequence||', r_ship.order_hdr_cust_field_1: '||r_ship.order_hdr_cust_field_1,1);
      xx_debug_pk.debug(l_calling_sequence||', r_ship.item_part_a: '||r_ship.item_part_a,1);
      xx_debug_pk.debug(l_calling_sequence||', r_ship.order_dtl_cust_field_2: '||r_ship.order_dtl_cust_field_2,1);
      l_ship_load_rec.order_hdr_cust_field_1         := r_ship.order_hdr_cust_field_1;   -- Viaje
      l_ship_load_rec.order_hdr_cust_field_2         := r_ship.order_hdr_cust_field_1;   -- Viaje
      l_ship_load_rec.item_part_a                    := r_ship.item_part_a;   -- Item Code
      l_ship_load_rec.req_ship_date                  := r_ship.req_ship_date;   -- Requirement Date
      l_ship_load_rec.shipped_qty                    := r_ship.shipped_qty;   -- Shipped Quantity
      l_ship_load_rec.batch_nbr                      := r_ship.batch_nbr;   -- Lot Number
      l_ship_load_rec.order_dtl_cust_field_2         := r_ship.order_dtl_cust_field_2;   -- Numero de Entrega
      l_ship_load_rec.order_dtl_cust_field_3         := r_ship.order_dtl_cust_field_3;   -- Numero de Pedido, puede venir concatenado con comas si son varios
      l_ship_load_rec.order_dtl_cust_field_4         := r_ship.order_dtl_cust_field_4;   -- Tipo de Pedido, puede venir concatenado con comas si son varios
      l_ship_load_rec.order_dtl_cust_field_5         := r_ship.order_dtl_cust_field_5;   -- Numero de Parada

      -- Procesar Confirmacion Viaje
      reserv_and_pick(p_facility_code
                     ,l_ship_load_rec
                     ,'PICK'
                     ,l_error_mesg);

      IF l_error_mesg IS NOT NULL THEN
        xx_debug_pk.debug(l_calling_sequence||', update status : '||l_error_mesg,1);

        BEGIN
          update_status(p_status       => 'ERROR'
                       ,p_error_mesg   => l_error_mesg
                       ,p_message_id   => p_message_id
                       ,p_row_id       => r_ship.row_id);
        EXCEPTION
          WHEN OTHERS THEN
            x_msg_data := 'Error al actualizar el estado en xx_wms_int_in_ship_load: '||sqlerrm;
            RAISE e_error;
        END;
      END IF;
    END LOOP;

    -- Agrego llamada para confirmar lo pendiente en el caso que haya lineas con cantidad pendiente
    control_confirm(p_message_id, l_error_mesg);
    IF l_error_mesg IS NOT NULL THEN
      xx_debug_pk.debug(l_calling_sequence||', update status : '||l_error_mesg,1);

      BEGIN
        update_status(p_status       => 'ERROR'
                     ,p_error_mesg   => l_error_mesg
                     ,p_message_id   => p_message_id
                     ,p_row_id       => '');
      EXCEPTION
        WHEN OTHERS THEN
          x_msg_data := 'Error al actualizar el estado en xx_wms_int_in_ship_load: '||sqlerrm;
          RAISE e_error;
      END;
    END IF;

    BEGIN
      SELECT count(1)
        INTO l_error_count
        FROM xx_wms_int_in_ship_load xwiisp
       WHERE xwiisp.message_id = p_message_id
         AND xwiisp.status = 'ERROR';
    EXCEPTION
      WHEN OTHERS THEN
        x_msg_data := 'Error buscando errores en xx_wms_int_in_ship_load '||sqlerrm; 
        RAISE e_error;
    END;
    IF l_error_count = 0 THEN
      x_return_status := 'S';
      update_status(p_status       => 'OK'
                   ,p_error_mesg   => null
                   ,p_message_id   => p_message_id
                   ,p_row_id       => null);
      COMMIT;

      FOR r_unassig IN c_unassig LOOP
        l_error_mesg := '';
        unassigne_line(p_delivery_id        => r_unassig.delivery_id
                      ,p_delivery_detail_id => r_unassig.delivery_detail_id
                      ,x_error_mesg         => l_error_mesg);
      END LOOP;
      FOR r_unassig_delivery IN c_unassig_delivery LOOP
        l_error_mesg := '';
        unassigne_delivery(p_trip_id     => r_unassig_delivery.trip_id
                          ,p_delivery_id => r_unassig_delivery.delivery_id
                          ,x_error_mesg  => l_error_mesg);
      END LOOP;
    ELSE
      x_msg_data := 'Errores en xx_wms_int_in_ship_load '; 
      x_return_status := 'E';
      update_status(p_status       => 'ERROR'
                   ,p_error_mesg   => null
                   ,p_message_id   => p_message_id
                   ,p_row_id       => null);
      ROLLBACK;
    END IF;
  END IF;

    xx_debug_pk.debug(l_calling_sequence||', Fin',1);

EXCEPTION
  WHEN e_error THEN
    x_return_status := 'E';
    update_status(p_status       => 'ERROR'
                 ,p_error_mesg   => x_msg_data
                 ,p_message_id   => p_message_id
                 ,p_row_id       => null);
    ROLLBACK;
  WHEN OTHERS THEN
    x_return_status := 'E';
    x_msg_data := 'Error: '||sqlerrm;
    update_status(p_status       => 'ERROR'
                 ,p_error_mesg   => x_msg_data
                 ,p_message_id   => p_message_id
                 ,p_row_id       => null);
    ROLLBACK;
    xx_debug_pk.debug(l_calling_sequence||', error : '||x_msg_data,1);
END process_integration;

END xx_wms_int_in_ship_load_pk;
/
show err
spool off
--exit
