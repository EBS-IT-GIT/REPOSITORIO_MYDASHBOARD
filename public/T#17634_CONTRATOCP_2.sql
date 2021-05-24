UPDATE apps.xx_po_asocia_remitos xpar
   SET clave_nro = '5005-' || SUBSTR(clave_nro,6,8),
       clave_id  = 9000000 + clave_id
 WHERE xpar.tipo_documento = 'TCG'
   AND xpar.clave_id IN    
 (
438853,
438866,
438870,
438875,
438922,
443171,
446268,
446849,
446851,
446853,
446931);
