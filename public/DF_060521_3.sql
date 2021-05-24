MERGE INTO RA_CUSTOMER_TRX_LINES_ALL RCTL
 USING (SELECT DISTINCT
               rctl_nc.uom_code uom_nc,
               rctl_nc_adj.uom_code uom_fc,
               rctl_nc.inventory_item_id,
               rct_nc.customer_trx_id,
               rct_nc.trx_number,
               rctl_nc_adj.customer_trx_line_id
          FROM ra_customer_trx_all rct_nc,
               ra_cust_trx_types_all rctt,
               hr_organization_units hou,
               ra_customer_trx_lines_all rctl_nc,
               ra_customer_trx_lines_all rctl_nc_adj
         WHERE 1=1
           AND hou.organization_id     = rct_nc.org_id
           AND rct_nc.cust_trx_type_id = rctt.cust_trx_type_id
           AND rctt.org_id             = rct_nc.org_id
           AND rctl_nc.customer_trx_id = rct_nc.customer_trx_id
           AND rctl_nc.line_type       = 'LINE'
           AND rctl_nc.attribute8      IS NULL
           AND rctl_nc.uom_code               != rctl_nc_adj.uom_code
           AND rctl_nc_adj.customer_trx_id     = rctl_nc.customer_trx_id
           AND rctl_nc_adj.line_type           = 'LINE'
           AND rctl_nc_adj.inventory_item_id   = rctl_nc.inventory_item_id
           AND NVL(rctl_nc_adj.attribute8,'N') = 'Y'
           AND rctt.type               = 'CM'
           AND rct_nc.creation_date    > TO_DATE('01-04-2021','DD-MM-RRRR')
           AND rct_nc.created_from     = 'AR_INVOICE_API') xx
ON (RCTL.CUSTOMER_TRX_LINE_ID = XX.CUSTOMER_TRX_LINE_ID
AND RCTL.CUSTOMER_TRX_ID      = XX.CUSTOMER_TRX_ID)
WHEN MATCHED THEN
UPDATE SET RCTL.UOM_CODE = XX.UOM_NC;

COMMIT;
/
EXIT