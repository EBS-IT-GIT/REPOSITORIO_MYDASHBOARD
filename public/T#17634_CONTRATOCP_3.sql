UPDATE apps.xx_po_asocia_remitos xpar
   SET clave_nro = '0005-' || SUBSTR(clave_nro,6,8),
       clave_id  = clave_id - 9000000
 WHERE xpar.tipo_documento = 'TCG'
   AND xpar.clave_id IN    
 (
9438853,
9438866,
9438870,
9438875,
9438922,
9443171,
9446268,
9446849,
9446851,
9446853,
9446931);


update apps.xx_tcg_asocia_pedido_venta 
set carta_porte_id = carta_porte_id - 9000000,LAST_UPDATED_BY = 2070,LAST_UPDATE_DATE = SYSDATE where carta_porte_id in (
9438853,
9438866,
9438870,
9438875,
9438922,
9443171,
9446268,
9446849,
9446851,
9446853,
4946931);


