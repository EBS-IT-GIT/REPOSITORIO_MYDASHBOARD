CREATE OR REPLACE PACKAGE BODY APPS."XX_INV_STOCK_CONSUMOMASIVO_PKG" AS



  FUNCTION Get_Quantity( p_type_quantity     VARCHAR2
                       , p_organization_id   NUMBER
                       , p_subinventory_code VARCHAR2
                       , p_locator_id        NUMBER
                       , p_lot_number        VARCHAR2
                       , p_inventory_item_id NUMBER
                       , p_planning_party    NUMBER
                       , p_owning_party      NUMBER
                       , p_revision          VARCHAR2
                       , p_cost_group_id     NUMBER
                       , p_grade_code        VARCHAR2
)
  RETURN NUMBER
  AS


    l_return_status       VARCHAR2(240);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(3000);
    l_is_revision_control BOOLEAN;
    l_query_loose_only    BOOLEAN;
    l_lot_control_code    NUMBER;
    l_is_lot_control      BOOLEAN;
    l_tree_mode           NUMBER;
    l_tot_qty_prim        NUMBER;
    l_tot_qty_sec         NUMBER;
    l_av_qty_res_prim     NUMBER;
    l_av_qty_res_sec      NUMBER;
    l_av_qty_trx_prim     NUMBER;
    l_av_qty_trx_sec      NUMBER;
    l_dummy               NUMBER;


  BEGIN


    --Revision
    IF (p_revision IS NULL) THEN
      l_is_revision_control := FALSE;
    ELSE
      l_is_revision_control := TRUE;
    END IF;


    -- Lot Control
    SELECT lot_control_code
      INTO l_lot_control_code
      FROM MTL_SYSTEM_ITEMS_B
     WHERE inventory_item_id = p_inventory_item_id
       AND organization_id   = p_organization_id;

    IF (p_lot_number IS NULL) AND
      (p_subinventory_code IS NOT NULL)
      OR (l_lot_control_code = 1) THEN
      l_is_lot_control := FALSE;
    ELSE
      l_is_lot_control := TRUE;
    END IF;


    -- Type of query
    IF (p_subinventory_code IS NOT NULL) AND
--      (jtf_grid.getcolumnnumbervalue ('RESULTS.GRID',p_rowNumber,'PACKED') IS NOT NULL
--       AND  jtf_grid.getcolumnnumbervalue ('RESULTS.GRID',p_rowNumber,'PACKED') = 0)
       (p_cost_group_id IS NOT NULL) THEN

      l_query_loose_only := TRUE;

      IF (l_lot_control_code = 2) THEN
        IF p_lot_number IS NULL THEN
          l_query_loose_only := FALSE;
        END IF;
      END IF;

      IF (p_planning_party IS NOT NULL)
        OR (p_owning_party IS NOT NULL) THEN
        l_query_loose_only := FALSE;
      ELSE
        l_query_loose_only := TRUE;
      END IF;

    ELSE
      l_query_loose_only := FALSE;
    END IF;


    -- Tree mode
    IF (l_query_loose_only) THEN
      l_tree_mode := 3;
    ELSE
      l_tree_mode := 2;
    END IF;

    INV_QUANTITY_TREE_PUB.query_quantities
                         ( p_api_version_number                => 1.0
                         , p_init_msg_lst                      => 'F'
                         , x_return_status                     => l_return_status
                         , x_msg_count                         => l_msg_count
                         , x_msg_data                          => l_msg_data
                         , p_organization_id                   => p_organization_id
                         , p_inventory_item_id                 => p_inventory_item_id
                         , p_tree_mode                         => l_tree_mode
                         , p_is_revision_control               => l_is_revision_control
                         , p_is_lot_control                    => l_is_lot_control
                         , p_is_serial_control                 => FALSE
                         , p_grade_code                        => p_grade_code
                         , p_demand_source_type_id             => -1
                         , p_demand_source_header_id           => -1
                         , p_demand_source_line_id             => -1
                         , p_demand_source_name                => NULL
                         , p_lot_expiration_date               => SYSDATE
                         , p_revision                          => p_revision
                         , p_lot_number                        => p_lot_number
                         , p_subinventory_code                 => p_subinventory_code
                         , p_locator_id                        => p_locator_id
                         , p_onhand_source                     => 3
                         , x_qoh                               => l_tot_qty_prim
                         , x_rqoh                              => l_dummy
                         , x_qr                                => l_dummy
                         , x_qs                                => l_dummy
                         , x_att                               => l_av_qty_trx_prim
                         , x_atr                               => l_av_qty_res_prim
                         , x_sqoh                              => l_tot_qty_sec
                         , x_srqoh                             => l_dummy
                         , x_sqr                               => l_dummy
                         , x_sqs                               => l_dummy
                         , x_satt                              => l_av_qty_trx_sec
                         , x_satr                              => l_av_qty_res_sec
                         , p_cost_group_id                     => p_cost_group_id
          );




    IF (p_type_quantity = 'Q_TO_RESERVE_PRIMARY') THEN
      RETURN l_av_qty_res_prim;
    ELSIF (p_type_quantity = 'Q_TO_RESERVE_SECONDARY') THEN
      RETURN l_av_qty_res_sec;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END Get_Quantity;



  PROCEDURE Main
  IS

    CURSOR c_stock IS
      SELECT mp.organization_id
           , mp.organization_code
           , moq.subinventory_code
           , mil.concatenated_segments                                        locator
           , moq.locator_id
           , moq.lot_number
           , mms.status_code
           , msi.inventory_item_id
           , msi.segment1                                                     articulo
           , msiT.description                                                  descripcion
           , msi.primary_uom_code                                             uom1
           , SUM(moq.transaction_quantity)                                    q_total1
           , msi.secondary_uom_code                                           uom2
           , SUM(moq.secondary_transaction_quantity)                          q_total2
           , TRUNC(mln.origination_date)                                      fecha_alta
           , TRUNC(mln.origination_date + NVL(msi.hold_days, 0))              fecha_liberacion
           , TRUNC(mln.expiration_date)                                       fecha_vencimiento
           , mln.creation_date
           , moq.planning_organization_id
           , moq.owning_organization_id
           , moq.revision
           , moq.cost_group_id
        FROM MTL_ONHAND_QUANTITIES_DETAIL moq
           , MTL_PARAMETERS               mp
           , MTL_SYSTEM_ITEMS_B           msi
           , MTL_SYSTEM_ITEMS_TL           msiT
           , MTL_MATERIAL_STATUSES_TL     mms
           , MTL_LOT_NUMBERS              mln
           , MTL_CROSS_REFERENCES_V       mcr
           , MTL_ITEM_LOCATIONS_KFV       mil
       WHERE 1=1
         AND msi.inventory_item_id = msiT.inventory_item_id
         AND msi.organization_id = msiT.organization_id 
         AND msiT.language='ESA'
         AND moq.organization_id      = mp.organization_id
         AND moq.inventory_item_id    = msi.inventory_item_id
         AND moq.organization_id      = msi.organization_id
         AND moq.status_id            = mms.status_id
         AND mms.language             = 'ESA'
         AND moq.inventory_item_id    = mln.inventory_item_id
         AND moq.organization_id      = mln.organization_id
         AND moq.lot_number           = mln.lot_number
         AND mcr.cross_reference_type = 'DYNAMIC'
         AND mcr.inventory_item_id    = moq.inventory_item_id
         AND moq.locator_id           = mil.inventory_location_id
         AND moq.subinventory_code    = mil.subinventory_code
         AND moq.organization_id      = mil.organization_id
       GROUP BY mcr.cross_reference
           , msi.inventory_item_id
           , msi.segment1
           , msiT.description
           , mp.organization_id
           , mp.organization_code
           , moq.lot_number
           , mln.creation_date
           , mln.origination_date
           , mln.expiration_date
           , mms.status_code
           , moq.subinventory_code
           , mil.concatenated_segments
           , moq.locator_id
           , msi.primary_uom_code
           , msi.secondary_uom_code
           , msi.hold_days
           , moq.planning_organization_id
           , moq.owning_organization_id
           , moq.revision
           , moq.cost_group_id;


    l_qty_to_reserve1   NUMBER;
    l_qty_to_reserve2   NUMBER;
    l_cant_stock        NUMBER;

  BEGIN

    FND_LOG.string( log_level => FND_LOG.level_statement
                  , module    => 'XX_INV_STOCK_CONSUMO_MASIVO_PKG.Main'
                  , message   => 'Inicio: '||to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'));


    DELETE FROM XX_INV_STOCK_CONSUMO_MASIVO inv
     WHERE NOT EXISTS (SELECT 'Y'
                         FROM MTL_ONHAND_QUANTITIES_DETAIL moq
                            , MTL_PARAMETERS               mp
                            , MTL_SYSTEM_ITEMS_B           msi
                            , MTL_MATERIAL_STATUSES_TL     mms
                            , MTL_LOT_NUMBERS              mln
                            , MTL_CROSS_REFERENCES_V       mcr
                            , MTL_ITEM_LOCATIONS_KFV       mil
                        WHERE 1=1
                          AND moq.organization_id      = mp.organization_id
                          AND moq.inventory_item_id    = msi.inventory_item_id
                          AND moq.organization_id      = msi.organization_id
                          AND moq.status_id            = mms.status_id
                          AND mms.language             = 'ESA'
                          AND moq.inventory_item_id    = mln.inventory_item_id
                          AND moq.organization_id      = mln.organization_id
                          AND moq.lot_number           = mln.lot_number
                          AND mcr.cross_reference_type = 'DYNAMIC'
                          AND mcr.inventory_item_id    = moq.inventory_item_id
                          AND moq.locator_id           = mil.inventory_location_id
                          AND moq.subinventory_code    = mil.subinventory_code
                          AND moq.organization_id      = mil.organization_id
                          AND moq.organization_id      = inv.organization_id
                          AND moq.subinventory_code    = inv.subinventory_code
                          AND NVL(moq.locator_id, -1)  = NVL(inv.locator_id, -1)
                          AND NVL(moq.lot_number, 'X') = NVL(inv.lot_number, 'X')
                          AND moq.inventory_item_id    = inv.inventory_item_id
                          AND msi.primary_uom_code     = inv.unit_of_measure1
                          AND msi.secondary_uom_code   = inv.unit_of_measure2
                          );

    COMMIT;

    FND_LOG.string( log_level => FND_LOG.level_statement
                  , module    => 'XX_INV_STOCK_CONSUMO_MASIVO_PKG.Main'
                  , message   => 'Borrado de registros obsoletos: Exitoso');

    INV_QUANTITY_TREE_PUB.clear_quantity_cache;

    FND_LOG.string( log_level => FND_LOG.level_statement
                  , module    => 'XX_INV_STOCK_CONSUMO_MASIVO_PKG.Main'
                  , message   => 'INV_QUANTITY_TREE_PUB.clear_quantity_cache: Exitoso');


    FOR rs IN c_stock LOOP

      IF (rs.status_code != 'RET'
        AND NVL(rs.fecha_vencimiento, TRUNC(SYSDATE+1)) > TRUNC(SYSDATE)
        AND rs.q_total1 != 0) THEN

        l_qty_to_reserve1 := Get_Quantity( p_type_quantity     => 'Q_TO_RESERVE_PRIMARY'
                                         , p_organization_id   => rs.organization_id
                                         , p_subinventory_code => rs.subinventory_code
                                         , p_locator_id        => rs.locator_id
                                         , p_lot_number        => rs.lot_number
                                         , p_inventory_item_id => rs.inventory_item_id
                                         , p_planning_party    => rs.planning_organization_id
                                         , p_owning_party      => rs.owning_organization_id
                                         , p_revision          => rs.revision
                                         , p_cost_group_id     => rs.cost_group_id
                                         , p_grade_code        => NULL);

        l_qty_to_reserve2 := Get_Quantity( p_type_quantity     => 'Q_TO_RESERVE_SECONDARY'
                                         , p_organization_id   => rs.organization_id
                                         , p_subinventory_code => rs.subinventory_code
                                         , p_locator_id        => rs.locator_id
                                         , p_lot_number        => rs.lot_number
                                         , p_inventory_item_id => rs.inventory_item_id
                                         , p_planning_party    => rs.planning_organization_id
                                         , p_owning_party      => rs.owning_organization_id
                                         , p_revision          => rs.revision
                                         , p_cost_group_id     => rs.cost_group_id
                                         , p_grade_code        => NULL);


      ELSE

        l_qty_to_reserve1 := 0;
        l_qty_to_reserve2 := 0;

      END IF;

      BEGIN
        SELECT count(*)
          INTO l_cant_stock
          FROM XX_INV_STOCK_CONSUMO_MASIVO xsc
         WHERE xsc.organization_id   = rs.organization_id
           AND xsc.subinventory_code = rs.subinventory_code
           AND xsc.inventory_item_id = rs.inventory_item_id
           AND xsc.locator_id        = NVL(rs.locator_id, xsc.locator_id)
           AND xsc.lot_number        = NVL(rs.lot_number, xsc.lot_number)
           AND xsc.unit_of_measure1  = rs.uom1
           AND xsc.unit_of_measure2  = rs.uom2;


      EXCEPTION
        WHEN OTHERS THEN
          l_cant_stock := 0;
      END;

      IF (l_cant_stock = 0) THEN

        INSERT INTO XX_INV_STOCK_CONSUMO_MASIVO
            ( ORGANIZATION_ID
            , ORGANIZATION_CODE
            , SUBINVENTORY_CODE
            , LOCATOR_ID
            , LOCATOR
            , LOT_NUMBER
            , STATUS
            , INVENTORY_ITEM_ID
            , ITEM_NUMBER
            , ITEM_DESCRIPTION
            , UNIT_OF_MEASURE1
            , TOTAL_QUANTITY1
            , QTY_TO_RESERVE1
            , UNIT_OF_MEASURE2
            , TOTAL_QUANTITY2
            , QTY_TO_RESERVE2
            , ORIGINATION_DATE
            , RELEASE_DATE
            , EXPIRATION_DATE
            , CREATION_DATE)
        VALUES
            ( rs.organization_id
            , rs.organization_code
            , rs.subinventory_code
            , rs.locator_id
            , rs.locator
            , rs.lot_number
            , rs.status_code
            , rs.inventory_item_id
            , rs.articulo
            , rs.descripcion
            , rs.uom1
            , rs.q_total1
            , l_qty_to_reserve1
            , rs.uom2
            , rs.q_total2
            , l_qty_to_reserve2
            , rs.fecha_alta
            , rs.fecha_liberacion
            , rs.fecha_vencimiento
            , rs.creation_date);

      ELSE

        UPDATE XX_INV_STOCK_CONSUMO_MASIVO xsc
           SET xsc.status            = rs.status_code
             , xsc.total_quantity1   = rs.q_total1
             , xsc.qty_to_reserve1   = l_qty_to_reserve1
             , xsc.total_quantity2   = rs.q_total2
             , xsc.qty_to_reserve2   = l_qty_to_reserve2
             , xsc.origination_date  = rs.fecha_alta
             , xsc.release_date      = rs.fecha_liberacion
             , xsc.expiration_date   = rs.fecha_vencimiento
             , xsc.creation_date     = rs.creation_date
         WHERE xsc.organization_id   = rs.organization_id
           AND xsc.subinventory_code = rs.subinventory_code
           AND xsc.inventory_item_id = rs.inventory_item_id
           AND xsc.locator_id        = NVL(rs.locator_id, xsc.locator_id)
           AND xsc.lot_number        = NVL(rs.lot_number, xsc.lot_number)
           AND xsc.unit_of_measure1  = rs.uom1
           AND xsc.unit_of_measure2  = rs.uom2;


      END IF;

    END LOOP;

    -- Inserta marca y pallets
   delete bolinf.XX_STOCK_MARCA_PALLET;
   commit;


INSERT INTO bolinf.XX_STOCK_MARCA_PALLET
 SELECT
a.inventory_item_id "Id_Item",a.organization_id "Id_Organizacion",
D.ORGANIZATION_CODE "Organizacion",
H.NAME "Descripcion Organizacion",
--a.end_Date_active,
A.SEGMENT1 "Articulo", A.HOLD_DAYS,
A.DESCRIPTION "Descripcion",
A.PRIMARY_UNIT_OF_MEASURE "Ppal-Unidad Medida Primaria",
CA3.CATEGORY_CONCAT_SEGS "Inventario",
(select flex_value||'-'||description  from apps.FND_FLEX_VALUES_VL  where flex_value_set_id = 1010650 and flex_value = ca3.segment1) rubro,
(select flex_value||'-'||description  from apps.FND_FLEX_VALUES_VL  where flex_value_set_id = 1010651 and PARENT_FLEX_VALUE_LOW = ca3.segment1 and flex_Value = ca3.segment2) familia,
(select flex_value||'-'||description  from apps.FND_FLEX_VALUES_VL  where flex_value_set_id = 1010652 and PARENT_FLEX_VALUE_LOW = ca3.segment1 and flex_Value = ca3.segment3) subfamilia,
(select vl.flex_value||'-'||vl.description  from apps.FND_FLEX_VALUES_VL vl, apps.fnd_flex_value_Sets fs  where flex_value_set_name='XX_BI_MARCA_LOV' and vl.flex_value_Set_id = fs.flex_value_Set_id  and  flex_Value = ca4.segment1) marca_oracle, -- marca
(CASE
    WHEN (A.DESCRIPTION) LIKE '%TRES%'  THEN 'Las Tres Ninas'
    WHEN (A.DESCRIPTION) LIKE '%ANGELI%'  THEN 'Angelita'
    WHEN (A.DESCRIPTION) LIKE '%APOS%'  THEN 'Apostoles'
        WHEN (A.DESCRIPTION) LIKE '%JUM%'  THEN 'Jumbo'
    WHEN (A.DESCRIPTION) LIKE '%WALM%'  THEN 'Walmart'
    WHEN (A.DESCRIPTION) LIKE '%DIA%'  THEN 'Dia'
    WHEN (A.DESCRIPTION) LIKE '%VEA%'  THEN 'Vea'
    WHEN (A.DESCRIPTION) LIKE '%Cuis%'  THEN 'Cuisine'
    WHEN (A.DESCRIPTION) LIKE '%SP%'  THEN 'SP'
    ELSE 'N/A' END) Marca,
nvl((select mcc.conversion_rate from  apps.MTL_UOM_CLASS_CONVERSIONS  mcc  where mcc.inventory_item_id = a.inventory_item_id and mcc.to_uom_class = 'EMBALAJE'
and mcc.to_unit_of_measure='Pallet'),0) litros_por_pallet
  FROM
  apps.MTL_SYSTEM_ITEMS_B A,
  apps.MTL_PARAMETERS D,
  apps.HR_ORGANIZATION_UNITS_V H,
  apps.gl_code_combinations_kfv co1,
  apps.gl_code_combinations_kfv co2,
  apps.mtl_item_Categories_V ca1,
  apps.mtl_item_Categories_V ca2,
  apps.mtl_item_Categories_V ca3,
  apps.mtl_item_Categories_V ca4/*vnaveira   ,
  apps.mtl_item_Categories_V ca5,
  apps.mtl_item_Categories_V ca6,
  apps.mtl_item_Categories_V ca7,
  apps.mtl_item_Categories_V ca8,
  apps.mtl_item_Categories_V ca9,
  apps.mtl_item_Categories_V ca10,
  apps.mtl_item_Categories_V ca11*/
 WHERE
 1=1
-- and a.eng_item_flag = DECODE ('INV', 'ENG', 'Y', 'N')
 and a.segment1 like '41001003%'--= '416201010414'
 and a.organization_id = h.organization_id
 and h.organization_id = d.organization_id
 and a.COST_OF_SALES_ACCOUNT = co1.code_Combination_id (+)
 AND a.sales_Account = co2.code_combination_id
 --and a.organization_id = 135
 and a.end_date_active is null
 and a.inventory_item_id = CA1.INVENTORY_ITEM_ID (+)
 and a.organization_id = ca1.organization_id(+)
 and CA1.CATEGORY_SET_id(+) = '1100000041' -- Clase Contable OPM
 and a.inventory_item_id = CA2.INVENTORY_ITEM_ID (+)
 and a.organization_id = ca2.organization_id(+)
 and CA2.CATEGORY_SET_id(+) = '1100000061' -- Categor?de Producto OPM
 and a.inventory_item_id = CA3.INVENTORY_ITEM_ID (+)
 and a.organization_id = ca3.organization_id(+)
 and CA3.CATEGORY_SET_id(+) = '1' -- Inventario/*
and a.inventory_item_id = CA4.INVENTORY_ITEM_ID (+)
 and a.organization_id = ca4.organization_id(+)
 and CA4.CATEGORY_SET_name(+) = 'Categoria Marca BI' -- Dim Producto Hyperion
 /*and a.inventory_item_id = CA5.INVENTORY_ITEM_ID (+)
 and a.organization_id = ca5.organization_id(+)
 and CA5.CATEGORY_SET_id(+) = '1100000024' -- PT Pedidos Bodegas
 and a.inventory_item_id = CA6.INVENTORY_ITEM_ID (+)
 and a.organization_id = ca6.organization_id(+)
 and CA6.CATEGORY_SET_id(+) = '1100000021' -- PT Producci?n Bodegas
 and a.inventory_item_id = CA7.INVENTORY_ITEM_ID (+)
 and a.organization_id = ca7.organization_id(+)
 and CA7.CATEGORY_SET_id(+) = '1100000022' -- Rubros Compras
 and a.inventory_item_id = CA8.INVENTORY_ITEM_ID (+)
 and a.organization_id = ca8.organization_id(+)
 and CA8.CATEGORY_SET_id(+) = '1100000023' -- Rubros Inventario
 and a.inventory_item_id = CA9.INVENTORY_ITEM_ID (+)
 and a.organization_id = ca9.organization_id(+)
 and CA9.CATEGORY_SET_id(+) = '1' -- Inventory
 and a.inventory_item_id = CA10.INVENTORY_ITEM_ID (+)
 and a.organization_id = ca10.organization_id(+)
 and CA10.CATEGORY_SET_id(+) = '1000000006' -- Producto
 and a.inventory_item_id = CA11.INVENTORY_ITEM_ID (+)
 and a.organization_id = ca11.organization_id(+)
 and CA11.CATEGORY_SET_id(+) = '1100000101' -- Categoria Hacienda*/
 --and A.ITEM_TYPE = 'FG'
 --AND A.SEGMENT1 LIKE '4100%30010'
 --and ca3.segment2 = '067'
 and length(a.segment1) =12
 AND D.ORGANIZATION_CODE = 'PUH';


    COMMIT;


    FND_LOG.string( log_level => FND_LOG.level_statement
                  , module    => 'XX_INV_STOCK_CONSUMO_MASIVO_PKG.Main'
                  , message   => 'Fin: '||to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'));

  EXCEPTION
    WHEN others THEN
      FND_LOG.string( log_level => FND_LOG.level_statement
                    , module    => 'XX_INV_STOCK_CONSUMO_MASIVO_PKG.Main'
                    , message   => 'Error: '||SQLERRM);

  END Main;

  PROCEDURE historia IS
  BEGIN
    -- Se deja la historia, como la foto de la tabla original
       INSERT into XX_INV_STOCK_CONS_MASIVO_HIS
       SELECT a.*, sysdate  from XX_INV_STOCK_CONSUMO_MASIVO a;




   EXCEPTION
    WHEN others THEN
      FND_LOG.string( log_level => FND_LOG.level_statement
                    , module    => 'XX_INV_STOCK_CONSUMO_MASIVO_PKG.Historia'
                    , message   => 'Error: '||SQLERRM);

  END historia;

END;
/
