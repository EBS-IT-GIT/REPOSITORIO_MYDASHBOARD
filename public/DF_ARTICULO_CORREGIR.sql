select a.carta_porte_id+9000000,a.* from apps.xx_tcg_asocia_pedido_venta a where a.carta_porte_id in (
438853)

-- DF
-- CAMBIA EL NRO DE ID  
update apps.xx_tcg_asocia_pedido_venta set carta_porte_id = carta_porte_id+9000000 where carta_porte_id = 438853
--9438853

UPDATE xx_po_asocia_remitos xpar
   SET clave_nro = '5005-' || SUBSTR(clave_nro,6,8),
       clave_id  = 1000000 + clave_id
 WHERE xpar.tipo_documento = 'TCG'
   AND xpar.clave_ID = 438853

-----
--REVERTIR-RECEPCION   

UPDATE APPS.XX_TCG_CARTAS_PORTE_ALL SET DESTINATARIO_CONTRATO_ID = 7964
WHERE CARTA_PORTE_ID = 438853
   
--REVERTIR ESTOS DF
update apps.xx_tcg_asocia_pedido_venta set carta_porte_id = carta_porte_id+9000000 where carta_porte_id = 438853
--9438853

UPDATE xx_po_asocia_remitos xpar
   SET clave_nro = '5005-' || SUBSTR(clave_nro,6,8),
       clave_id  = 1000000 + clave_id
 WHERE xpar.tipo_documento = 'TCG'
   AND xpar.clave_ID = 438853
   

select * from apps.xx_tcg_cartas_porte_all where carta_porte_id = 438853


select * from apps.mtl_parameters where organization_id = 1791


   SELECT mtt.creation_date,
          mtt.transaction_id,
          TO_NUMBER (mtt.attribute2) carta_porte_id,
          mtt.attribute4 tipo_movimiento,
          mtt.waybill_airbill numero_carta_porte     --, mtt.inventory_item_id
                                                ,
          (SELECT DISTINCT
                     segment1
                  || ' - '
                  || description
                  || ' ('
                  || inventory_item_id
                  || ')'
             FROM mtl_system_items
            WHERE inventory_item_id = mtt.inventory_item_id
                  AND organization_id = 135 ) -- XX_TCG_FUNCTIONS_PKG.getMasterOrg)
             item                           --, mtt.transaction_source_type_id
                 ,
          (SELECT    transaction_source_type_name
                  || ' ('
                  || transaction_source_type_id
                  || ')'
             FROM mtl_txn_source_types
            WHERE transaction_source_type_id = mtt.transaction_source_type_id)
             transaction_source_type               --, mtt.transaction_type_id
                                    ,
          (SELECT transaction_type_name || ' (' || transaction_type_id || ')'
             FROM mtl_transaction_types
            WHERE transaction_type_id = mtt.transaction_type_id)
             transaction_type                    --, mtt.transaction_action_id
                             ,
          (SELECT meaning || ' (' || transaction_action_id || ')'
             FROM fnd_lookup_values
            WHERE     1 = 1
                  AND lookup_type = 'MTL_TRANSACTION_ACTION'
                  AND lookup_code = mtt.transaction_action_id
                  AND language = 'ESA')
             transaction_action                              --, mtt.reason_id
                               ,
          (SELECT reason_name || ' (' || reason_id || ')'
             FROM mtl_transaction_reasons
            WHERE reason_id = mtt.reason_id)
             reason_code                                                    --
                        ,
          mtt.transaction_quantity,
          mtt.transaction_uom,
          (SELECT lot_number
             FROM mtl_transaction_lot_numbers
            WHERE transaction_id = mtt.transaction_id)
             lot_number                                                     --
                       ,
          mtt.transaction_date                          --, mtt.acct_period_id
                              ,
          (SELECT period_name
             FROM org_acct_periods_v
            WHERE acct_period_id = mtt.acct_period_id)
             acct_period,
          mtt.distribution_account_id                                       --
                                     --, mtt.organization_id
          ,
          (SELECT organization_name || ' (' || organization_id || ')'
             FROM org_organization_definitions
            WHERE organization_id = mtt.organization_id)
             organization_name,
          mtt.subinventory_code                             --, mtt.locator_id
                               ,
          (SELECT    segment1
                  || ' - '
                  || description
                  || ' ('
                  || inventory_location_id
                  || ')'
             FROM mtl_item_locations
            WHERE inventory_location_id = mtt.locator_id)
             locator                                                        --
                    --, mtt.transfer_organization_id
          ,
          (SELECT organization_name || ' (' || organization_id || ')'
             FROM org_organization_definitions
            WHERE organization_id = mtt.transfer_organization_id)
             transfer_organization_name,
          mtt.transfer_subinventory                --, mtt.transfer_locator_id
                                   ,
          (SELECT    segment1
                  || ' - '
                  || description
                  || ' ('
                  || inventory_location_id
                  || ')'
             FROM mtl_item_locations
            WHERE inventory_location_id = mtt.transfer_locator_id)
             transfer_locator                                               --
                             ,
          (SELECT organization_name || ' (' || organization_id || ')'
             FROM org_organization_definitions
            WHERE organization_id = mtt.owning_organization_id
           UNION
           SELECT s.vendor_name || ' (' || vs.vendor_site_id || ')'
             FROM po_vendor_sites_all vs, ap_suppliers s
            WHERE     1 = 1
                  AND s.vendor_id = vs.vendor_id
                  AND vs.vendor_site_id = mtt.owning_organization_id
                  AND NOT EXISTS
                             (SELECT 1
                                FROM org_organization_definitions
                               WHERE organization_id =
                                        mtt.owning_organization_id))
             owning_organization_name       --, mtt.xfr_owning_organization_id
                           ,
           (
           SELECT s.vendor_name || ' (' || vs.vendor_site_id || ')'
             FROM po_vendor_sites_all vs, ap_suppliers s
            WHERE     1 = 1
                  AND s.vendor_id = vs.vendor_id
                  AND vs.vendor_site_id = mtt.owning_organization_id
                 )
             owning_organization_name_aux       --, mtt.xfr_owning_organization_id
                                     ,
          (SELECT organization_name || ' (' || organization_id || ')'
             FROM org_organization_definitions
            WHERE organization_id = mtt.xfr_owning_organization_id)
             xfr_owning_organization_name,
          source_project_id,
          source_task_id,
          expenditure_type,
          pa_expenditure_org_id,
          mtt.*
     FROM mtl_material_transactions mtt
    WHERE 1 = 1 AND source_code = 'Inventory'
       --AND TO_NUMBER (mtt.attribute2) IN ('393641','396077')
 AND(  
--(mtt.waybill_airbill = '0005-84282000' and mtt.inventory_item_id = 865) or
(mtt.waybill_airbill = '0005-85901560' and mtt.inventory_item_id = 863) --or
/*(mtt.waybill_airbill = '0005-85901561' and mtt.inventory_item_id = 863) or
(mtt.waybill_airbill = '0005-85901562' and mtt.inventory_item_id = 863) or
(mtt.waybill_airbill = '0005-85901563' and mtt.inventory_item_id = 863) or
(mtt.waybill_airbill = '0005-85901564' and mtt.inventory_item_id = 863) or
(mtt.waybill_airbill = '0005-86475770' and mtt.inventory_item_id = 863) or
(mtt.waybill_airbill = '0005-86806635' and mtt.inventory_item_id = 863) or
(mtt.waybill_airbill = '0005-86806668' and mtt.inventory_item_id = 863) or
(mtt.waybill_airbill = '0005-86806669' and mtt.inventory_item_id = 863) or
(mtt.waybill_airbill = '0005-86806670' and mtt.inventory_item_id = 863) or
(mtt.waybill_airbill = '0005-86806673' and mtt.inventory_item_id = 863)*/ 
 )
 --      AND mtt.owning_organization_id = 329026         
     AND mtt.creation_date >to_date('01/06/2019','dd/mm/yyyy')
--      AND mtt.subinventory_code = '190'
    --  AND mtt.owning_organization_id = 4251
     ORDER BY mtt.waybill_airbill ,MTT.TRANSACTION_ID--,-- mtt.creation_date DESC
     
     
     UPDATE APPS.MTL_SYSTEM_ITEMS_B SET
DUAL_UOM_CONTROL =2,
SECONDARY_UOM_CODE = 'UN',
DUAL_UOM_DEVIATION_HIGH = 0,
DUAL_UOM_DEVIATION_LOW = 0,
SECONDARY_DEFAULT_IND ='F',
LAST_UPDATE_DATE = SYSDATE,
LAST_UPDATED_BY = 2070
WHERE
inventory_item_id = 28462662  and
organization_id =1949;
