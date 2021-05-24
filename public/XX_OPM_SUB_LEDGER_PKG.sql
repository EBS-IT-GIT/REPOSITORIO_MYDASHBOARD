  set define off;

  CREATE OR REPLACE PACKAGE "APPS"."XX_OPM_SUB_LEDGER_PKG" IS
  P_APPLICATION_ID           NUMBER;
  P_ORG_ID                   NUMBER;
  P_GL_PERIOD                VARCHAR2(255);
  P_FECHA_DESDE              VARCHAR2(255);
  P_FECHA_HASTA              VARCHAR2(255);
  P_EVENT_CLASS_GROUP_CODE   VARCHAR2(255);
  P_TRANSACTION_TYPE_ID      NUMBER;
  P_SOLO_ERRORES             VARCHAR2(255);
  
  function get_owning_supplier(p_process_enabled_flag  in varchar2
                                           , p_eam_enabled_flag in varchar2
                                            , p_owning_tp_type in number
                                            , p_owning_organization_id in number
                                            , p_transaction_type_name  in varchar2
                                            , p_transfer_transaction_id in number
                                            , p_transaction_set_id in number
                                            , p_transaction_batch_id in number)
                                            return varchar2;

  FUNCTION BeforeReportTrigger RETURN boolean ;

  PROCEDURE main_cnc ( errbuf                    IN OUT VARCHAR2
                     , retcode                   IN OUT VARCHAR2
                     , P__APPLICATION_ID         IN     NUMBER
                     , P__ORG_ID                 IN     NUMBER
                     , P__GL_PERIOD              IN     VARCHAR2
                     , P__FECHA_DESDE            IN     VARCHAR2
                     , P__FECHA_HASTA            IN     VARCHAR2
                     , P__EVENT_CLASS_GROUP_CODE IN     VARCHAR2
                     , P__TRANSACTION_TYPE_ID    IN     NUMBER
                     , P__SOLO_ERRORES           IN     VARCHAR2
                     , P_DEST_DIR                IN     VARCHAR2
                     , P_USR                     IN     VARCHAR2
                     , P_PWD                     IN     VARCHAR2
                     , P_TIMEOUT                 IN     VARCHAR2
                     );

END XX_OPM_SUB_LEDGER_PKG;
/


  CREATE OR REPLACE PACKAGE BODY "APPS"."XX_OPM_SUB_LEDGER_PKG" IS
function get_owning_supplier(p_process_enabled_flag  in varchar2
                                           , p_eam_enabled_flag in varchar2
                                            , p_owning_tp_type in number
                                            , p_owning_organization_id in number
                                            , p_transaction_type_name  in varchar2
                                            , p_transfer_transaction_id in number
                                            , p_transaction_set_id in number
                                            , p_transaction_batch_id in number)
                                            return varchar2 is
l_owning_supplier varchar2(500);                                            
begin

IF p_process_enabled_flag = 'Y' and p_eam_enabled_flag = 'N' then 
     IF p_owning_tp_type = 1 then 
               SELECT DISTINCT x.vendor_name || '-' || z.vendor_site_code
                      into l_owning_supplier
                FROM po_vendor_sites_all z , po_vendors x
                  WHERE x.vendor_id = z.vendor_id
                  AND z.vendor_site_id = p_owning_organization_id;
    ELSIF  p_owning_tp_type = 2 then
                    IF p_transaction_type_name in ('WIP Issue'                  ,'WIP Completion Return' 
                                                                ,'WIP Return'                 ,'WIP Completion' 
                                                                ,'WIP cost update'            ,'WIP assembly scrap' 
                                                                ,'WIP return from scrap'      ,'WIP Negative Issue' 
                                                                ,'WIP Negative Return'        ,'WIP Lot Split' 
                                                                ,'WIP Lot Merge'              ,'WIP Lot Bonus' 
                                                                ,'WIP Lot Quantity Update'    ,'WIP estimated scrap' 
                                                                ,'WIP Byproduct Completion'   ,'WIP Byproduct Return' ) then 
                                  l_owning_supplier:= null;         
                    ELSIF p_transaction_type_name = 'Transfer to Regular' then
                              SELECT DISTINCT x.vendor_name                     || '-'                     || z.vendor_site_code
                                          INTO l_owning_supplier
                                         FROM po_vendor_sites_all z
                                                 , po_vendors x
                                                 , mtl_material_transactions mmt1
                                         WHERE x.vendor_id = z.vendor_id
                                          AND z.vendor_site_id = mmt1.owning_organization_id
                                         AND mmt1.owning_tp_type = 1
                                          AND mmt1.transaction_set_id = p_transaction_set_id
                                          AND mmt1.transaction_batch_id = p_transaction_batch_id
                                         and ( (p_transfer_transaction_id IS NOT NULL      AND mmt1.transaction_id = p_transfer_transaction_id)
                                                   OR
                                                   ( p_transfer_transaction_id IS NULL )
                                                )
                                         AND ROWNUM = 1 ;
                    ELSE
                        SELECT DISTINCT x.vendor_name  || '-'   || z.vendor_site_code
                                          INTO l_owning_supplier                       
                            FROM po_vendor_sites_all z
                                     , po_vendors x
                                     , mtl_material_transactions mmt1
                         WHERE x.vendor_id = z.vendor_id
                         AND z.vendor_site_id = mmt1.owning_organization_id
                         AND mmt1.owning_tp_type = 1
                         AND mmt1.transaction_set_id = p_transaction_set_id
                         AND mmt1.transaction_batch_id = p_transaction_batch_id
                         AND ROWNUM = 1;
                    END IF;          
     ELSE l_owning_supplier := null;
     END IF;         
ELSE l_owning_supplier := null;
end if;
/*
select     DECODE( p_process_enabled_flag,'Y',DECODE( p_eam_enabled_flag,'N',
                                                                                 DECODE (p_owning_tp_type , 1, (SELECT DISTINCT x.vendor_name || '-' || z.vendor_site_code
                                                                                                                                      FROM po_vendor_sites_all z , po_vendors x
                                                                                                                                      WHERE x.vendor_id = z.vendor_id
                                                                                                                                      AND z.vendor_site_id = p_owning_organization_id)
                                                         -- Inicio adm CR2243 - CH1751
                                                                                                                            , 2, DECODE(p_transaction_type_name
                                                                                                                                            ,'WIP Issue', NULL
                                                                                                                                            ,'WIP Completion Return', NULL
                                                                                                                                            ,'WIP Return', NULL
                                                                                                                                            ,'WIP Completion', NULL
                                                                                                                                            ,'WIP cost update', NULL
                                                                                                                                            ,'WIP assembly scrap', NULL
                                                                                                                                            ,'WIP return from scrap', NULL
                                                                                                                                            ,'WIP Negative Issue', NULL
                                                                                                                                            ,'WIP Negative Return', NULL
                                                                                                                                            ,'WIP Lot Split', NULL
                                                                                                                                            ,'WIP Lot Merge', NULL
                                                                                                                                            ,'WIP Lot Bonus', NULL
                                                                                                                                            ,'WIP Lot Quantity Update', NULL
                                                                                                                                            ,'WIP estimated scrap', NULL
                                                                                                                                            ,'WIP Byproduct Completion', NULL
                                                                                                                                            ,'WIP Byproduct Return', NULL
                                                                                                                                            ,'Transfer to Regular',(SELECT DISTINCT x.vendor_name
                                                                                                                                                                     || '-'
                                                                                                                                                                     || z.vendor_site_code
                                                                                                                                                                     FROM po_vendor_sites_all z
                                                                                                                                                                     , po_vendors x
                                                                                                                                                                     , mtl_material_transactions mmt1
                                                                                                                                                                     WHERE x.vendor_id = z.vendor_id
                                                                                                                                                                     AND z.vendor_site_id = mmt1.owning_organization_id
                                                                                                                                                                     AND mmt1.owning_tp_type = 1
                                                                                                                                                                     AND p_transaction_type_name not like 'WIP%'
                                                                                                                                                                     AND mmt1.transaction_id = p_transfer_transaction_id
                                                                                                                                                                     AND mmt1.transaction_set_id = p_transaction_set_id
                                                                                                                                                                     AND mmt1.transaction_batch_id = p_transaction_batch_id
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
                                                                                                                                                                     AND p_transaction_type_name not like 'WIP%'
                                                                                                                                                                     AND p_transfer_transaction_id IS NULL
                                                                                                                                                                     AND mmt1.transaction_set_id = p_transaction_set_id
                                                                                                                                                                     AND mmt1.transaction_batch_id = p_transaction_batch_id
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
                                                                                                                                             AND mmt1.transaction_set_id = p_transaction_set_id
                                                                                                                                             AND mmt1.transaction_batch_id = p_transaction_batch_id
                                                                                                                                             AND ROWNUM = 1))
                                                                                                        ),null),null) owning_supplier
                                                                                                        into l_owning_supplier from dual;                */                            
return l_owning_supplier;
EXCEPTION WHEN OTHERS THEN
        RETURN NULL;
end get_owning_supplier;      
 PROCEDURE main_cnc ( errbuf IN OUT VARCHAR2
 , retcode IN OUT VARCHAR2
 , P__APPLICATION_ID IN NUMBER
 , P__ORG_ID IN NUMBER
 , P__GL_PERIOD IN VARCHAR2
 , P__FECHA_DESDE IN VARCHAR2
 , P__FECHA_HASTA IN VARCHAR2
 , P__EVENT_CLASS_GROUP_CODE IN VARCHAR2
 , P__TRANSACTION_TYPE_ID IN NUMBER
 , P__SOLO_ERRORES IN VARCHAR2
 , P_DEST_DIR IN VARCHAR2
 , P_USR IN VARCHAR2
 , P_PWD IN VARCHAR2
 , P_TIMEOUT IN VARCHAR2
 ) IS
 
cursor c_q1 is select 
                         ledger_name, legal_entity_name, operating_unit, modo, event_class_group_code, event_class, event_type,
                        event_class_code,ae_header_id,entity_code, event_number, event_date, accounting_date, transaction_id,
                        clase_costo,clase_costo_descr, clase_gl, clase_gl_descr, clase_prod, clase_prod_descr, product_line,
                        resources,item_code, item_description, transaction_date, order_number, carta_porte, numero_liquidacion,
                        productor_liquidacion, usuario_trx, transaction_type_id, transaction_type_name, organization_code, 
                        organization_name, subinventory_code, subinventory_desc, reason_name, reason_description, je_category_name,
                        ae_line_num, accounting_class_code, accounting_class_meaning, lote, owning_supplier, transaction_quantity,
                        primary_uom_code, code_combination_id, titulo_cuenta, concatenated_segments, descr_cuenta, currency_code,
                        entered_dr, entered_cr, accounted_dr, accounted_cr, gl_transfer_date, event_id, error_description,po_number,
                        project_id, task_id, project_number, project_name, task_number, task_name, pa_expenditure_org_id,
                        pa_expenditure_org, expenditure_type, wip_entity_name
 from  bolinf.XX_OPM_SUB_LEGDER_GRAL_GT;

 r_q1 c_q1%ROWTYPE;

 l_p_ou_name VARCHAR2(150);
 l_p_trx_type VARCHAR2(255);
 l_p_fechas VARCHAR2(150);

 l_acc_date_from DATE;
 l_acc_date_to DATE;
 l_line_out CLOB;
 l_cloblen NUMBER;
 l_file UTL_FILE.file_type;
 l_ora_dir VARCHAR2(255) := 'XX_CONCURRENT_OUT';
 l_host_path VARCHAR2(255);
 l_line VARCHAR2(255);
 l_status NUMBER;
 l_outfile_name VARCHAR2(255);
 l_file_cnt NUMBER;

 l_result BOOLEAN;
 BEGIN
 P_APPLICATION_ID := P__APPLICATION_ID;
 P_ORG_ID := P__ORG_ID;
 P_GL_PERIOD := P__GL_PERIOD;
 P_FECHA_DESDE := P__FECHA_DESDE;
 P_FECHA_HASTA := P__FECHA_HASTA;
 P_EVENT_CLASS_GROUP_CODE := P__EVENT_CLASS_GROUP_CODE;
 P_TRANSACTION_TYPE_ID := P__TRANSACTION_TYPE_ID;
 P_SOLO_ERRORES := P__SOLO_ERRORES;

 l_result := BeforeReportTrigger;

 SELECT (SELECT name FROM hr_operating_units WHERE organization_id = P_ORG_ID) ou_name
 , (SELECT transaction_type_name FROM mtl_transaction_types WHERE transaction_type_id = P_TRANSACTION_TYPE_ID) tipo_trx
 , P_FECHA_DESDE||' al '||P_FECHA_HASTA fecha
 INTO l_p_ou_name, l_p_trx_type, l_p_fechas
 FROM DUAL
 ;

 SELECT NVL (MAX (directory_path),'X') l_host_path, FND_GLOBAL.Conc_Request_ID||'.txt' outfile_name
 INTO l_host_path, l_outfile_name
 FROM ALL_DIRECTORIES
 WHERE directory_name = l_ora_dir;

 IF l_host_path = 'X' THEN
 raise_application_error(-10001, 'Directorio XX_CONCURRENT_OUT no definido');
 END IF;


 FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Creando directorio...');
 dbms_output.disable;
 dbms_output.enable;
 dbms_java.set_output(1023);
 host_command ('cd '||l_host_path||';/usr/bin/mkdir '||FND_GLOBAL.Conc_Request_ID );
 dbms_output.get_line (l_line, l_status);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'line = '||l_line);
 FND_FILE.PUT_LINE(FND_FILE.LOG, '- Creando directorio...');

 FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Escribiendo archivo...');
 l_file := UTL_FILE.FOPEN(l_ora_dir, l_outfile_name,'W',32767);

 UTL_FILE.PUT_LINE(l_file, 'XX OPM Informe Detallado de Submayor');
 UTL_FILE.PUT_LINE(l_file, ' ');
 UTL_FILE.PUT_LINE(l_file, 'Unidad Operativa:|'||l_p_ou_name);
 UTL_FILE.PUT_LINE(l_file, 'Fechas:|'||l_p_fechas);
 UTL_FILE.PUT_LINE(l_file, 'Cat. Proceso:|'||P_EVENT_CLASS_GROUP_CODE);
 UTL_FILE.PUT_LINE(l_file, 'Tipo TransacciÃ³n:|'||l_p_trx_type);
 UTL_FILE.PUT_LINE(l_file, 'Solo Errores:|'||P_SOLO_ERRORES);
 UTL_FILE.PUT_LINE(l_file, ' ');


 --FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'"LEDGER_NAME"|"LEGAL_ENTITY_NAME"|"OPERATING_UNIT"|"MODO"|"EVENT_CLASS_GROUP_CODE"|"EVENT_CLASS"|"EVENT_TYPE"|"EVENT_NUMBER"|"EVENT_DATE"|"ACCOUNTING_DATE"|"TRANSACTION_ID"|"CLASE_COSTO"|"CLASE_COSTO_DESCR"|"CLASE_GL"|"CLASE_GL_DESCR"|"ITEM_CODE"|"ITEM_DESCRIPTION"|"TRANSACTION_DATE"|"ORDER_NUMBER"|"CARTA_PORTE"|"USUARIO_TRX"|"TRANSACTION_TYPE_ID"|"TRANSACTION_TYPE_NAME"|"ORGANIZATION_CODE"|"ORGANIZATION_NAME"|"SUBINVENTORY_CODE"|"SUBINVENTORY_DESC"|"REASON_NAME"|"REASON_DESCRIPTION"|"JE_CATEGORY_NAME"|"AE_LINE_NUM"|"ACCOUNTING_CLASS_CODE"|"ACCOUNTING_CLASS_MEANING"|"LOTE"|"TRANSACTION_QUANTITY"|"PRIMARY_UOM_CODE"|"TITULO_CUENTA"|"CONCATENATED_SEGMENTS"|"DESCR_CUENTA"|"CURRENCY_CODE"|"ENTERED_DR"|"ENTERED_CR"|"ACCOUNTED_DR"|"ACCOUNTED_CR"|"GL_TRANSFER_DATE"|"EVENT_ID"|"ERROR_DESCRIPTION"|"PO_NUMBER"|"PRODUCT_LINE"|"TASK_ID"|"PROJECT_NUMBER"|"PROJECT_NAME"|"TASK_NUMBER"|"TASK_NAME"|"PA_EXPENDITURE_ORG_ID"|"PA_EXPENDITURE_ORG"|"EXPENDITURE_TYPE"|"WIP_ENTITY_NAME"|"RESOURCES"');
 UTL_FILE.PUT_LINE(l_file, '"Libro"|"Entidad Legal"|"Modo"|"Clase Costo"|"DescripciÃ³n"|"Clase GL"|"DescripciÃ³n"|"Linea Producto"|"Recurso"|"ArtÃ­culo"|"DescripciÃ³n"|"Fecha Trans."|"Tipo TransacciÃ³n"|"ID TransacciÃ³n"|"Org. Inv"|"DescripciÃ³n"|"Subinventario"|"DescripciÃ³n"|"Motivo"|"DescripciÃ³n Motivo"|"'||'Owner"|"'/*adm CR2243 - CH1751 */||'Cantidad"|"UM"|"Lote"|"Orden de Trabajo"|"Orden de Compra"|"Orden de Venta"|"Carta de Porte"|"NÃºmero LiquidaciÃ³n"|"Productor LiquidaciÃ³n"|"Clase de Evento"|"Tipo de Evento"|"Proyecto"|"Tarea"|"Tipo ErogaciÃ³n"|"CategorÃ­a de Asiento"|"Fecha Contable"|"LÃ­nea"|"Tipo Linea Asiento"|"TÃ­tulo Cuenta "|"Cuenta"|"DescripciÃ³n Cuenta"|"Divisa"|"DÃ©bito Base"|"CrÃ©dito Base"|"DÃ©bito Divisa"|"CrÃ©dito Divisa"|"ID Evento"|"Usuario Trans."|"Errores"|');



 OPEN c_q1;
 LOOP
 FETCH c_q1 INTO r_q1;
 EXIT WHEN c_q1%NOTFOUND;
 --FND_FILE.PUT_LINE (FND_FILE.OUTPUT, r_q1.LEDGER_NAME||';'||r_q1.LEGAL_ENTITY_NAME||'|'||r_q1.OPERATING_UNIT||'|'||r_q1.MODO||'|'||r_q1.EVENT_CLASS_GROUP_CODE||'|'||r_q1.EVENT_CLASS||'|'||r_q1.EVENT_TYPE||'|'||r_q1.EVENT_NUMBER||'|'||r_q1.EVENT_DATE||'|'||r_q1.ACCOUNTING_DATE||'|'||r_q1.TRANSACTION_ID||'|'||r_q1.CLASE_COSTO||'|'||r_q1.CLASE_COSTO_DESCR||'|'||r_q1.CLASE_GL||'|'||r_q1.CLASE_GL_DESCR||'|'||r_q1.ITEM_CODE||'|'||r_q1.ITEM_DESCRIPTION||'|'||r_q1.TRANSACTION_DATE||'|'||r_q1.ORDER_NUMBER||'|'||r_q1.CARTA_PORTE||'|'||r_q1.USUARIO_TRX||'|'||r_q1.TRANSACTION_TYPE_ID||'|'||r_q1.TRANSACTION_TYPE_NAME||'|'||r_q1.ORGANIZATION_CODE||'|'||r_q1.ORGANIZATION_NAME||'|'||r_q1.SUBINVENTORY_CODE||'|'||r_q1.SUBINVENTORY_DESC||'|'||r_q1.REASON_NAME||'|'||r_q1.REASON_DESCRIPTION||'|'||r_q1.JE_CATEGORY_NAME||'|'||r_q1.AE_LINE_NUM||'|'||r_q1.ACCOUNTING_CLASS_CODE||'|'||r_q1.ACCOUNTING_CLASS_MEANING||'|'||r_q1.LOTE||'|'||r_q1.TRANSACTION_QUANTITY||'|'||r_q1.PRIMARY_UOM_CODE||'|'||r_q1.TITULO_CUENTA||'|'||r_q1.CONCATENATED_SEGMENTS||'|'||r_q1.DESCR_CUENTA||'|'||r_q1.CURRENCY_CODE||'|'||r_q1.ENTERED_DR||'|'||r_q1.ENTERED_CR||'|'||r_q1.ACCOUNTED_DR||'|'||r_q1.ACCOUNTED_CR||'|'||r_q1.GL_TRANSFER_DATE||'|'||r_q1.EVENT_ID||'|'||r_q1.ERROR_DESCRIPTION||'|'||r_q1.PO_NUMBER||'|'||r_q1.PRODUCT_LINE||'|'||r_q1.TASK_ID||'|'||r_q1.PROJECT_NUMBER||'|'||r_q1.PROJECT_NAME||'|'||r_q1.TASK_NUMBER||'|'||r_q1.TASK_NAME||'|'||r_q1.PA_EXPENDITURE_ORG_ID||'|'||r_q1.PA_EXPENDITURE_ORG||'|'||r_q1.EXPENDITURE_TYPE||'|'||r_q1.WIP_ENTITY_NAME||'|'||r_q1.RESOURCES);

 l_line_out := r_q1.LEDGER_NAME||'|'
                 ||r_q1.LEGAL_ENTITY_NAME||'|'
                 ||r_q1.MODO||'|'
                 ||r_q1.CLASE_COSTO||'|'
                 ||r_q1.CLASE_COSTO_DESCR||'|'
                 ||r_q1.CLASE_GL||'|'
                 ||r_q1.CLASE_GL_DESCR||'|'
                 ||r_q1.PRODUCT_LINE||'|'
                 ||r_q1.RESOURCES||'|'
                 ||r_q1.ITEM_CODE||'|'
                 ||r_q1.ITEM_DESCRIPTION||'|'
                 ||r_q1.TRANSACTION_DATE||'|'
                 ||r_q1.TRANSACTION_TYPE_NAME||'|'
                 ||r_q1.TRANSACTION_ID||'|'
                 ||r_q1.ORGANIZATION_CODE||'|'
                 ||r_q1.ORGANIZATION_NAME||'|'
                 ||r_q1.SUBINVENTORY_CODE||'|'
                 ||r_q1.SUBINVENTORY_DESC||'|'
                 ||r_q1.REASON_NAME||'|'
                 ||r_q1.REASON_DESCRIPTION||'|'
                 ||r_q1.OWNING_SUPPLIER||'|' -- adm CR2243 - CH1751
                 ||r_q1.TRANSACTION_QUANTITY||'|'
                 ||r_q1.PRIMARY_UOM_CODE||'|'
                 ||r_q1.LOTE||'|'
                 ||r_q1.WIP_ENTITY_NAME||'|'
                 ||r_q1.PO_NUMBER||'|'
                 ||r_q1.ORDER_NUMBER||'|'
                 ||r_q1.CARTA_PORTE||'|'
                 ||r_q1.NUMERO_LIQUIDACION||'|'
                 ||r_q1.PRODUCTOR_LIQUIDACION||'|'
                 ||r_q1.EVENT_CLASS||'|'
                 ||r_q1.EVENT_TYPE||'|'
                 ||r_q1.PROJECT_NUMBER||'|'
                 ||r_q1.TASK_NUMBER||'|'
                 ||r_q1.EXPENDITURE_TYPE||'|'
                 ||r_q1.JE_CATEGORY_NAME||'|'
                 ||r_q1.ACCOUNTING_DATE||'|'
                 ||r_q1.AE_LINE_NUM||'|'
                 ||r_q1.ACCOUNTING_CLASS_MEANING||'|'
                 ||r_q1.TITULO_CUENTA||'|'
                 ||r_q1.CONCATENATED_SEGMENTS||'|'
                 ||r_q1.DESCR_CUENTA||'|'
                 ||r_q1.CURRENCY_CODE||'|'
                 ||r_q1.ENTERED_DR||'|'
                 ||r_q1.ENTERED_CR||'|'
                 ||r_q1.ACCOUNTED_DR||'|'
                 ||r_q1.ACCOUNTED_CR||'|'
                 ||r_q1.EVENT_ID||'|'
                 ||r_q1.USUARIO_TRX||'|'
                 ||r_q1.ERROR_DESCRIPTION||'|'
 
 ;

 l_cloblen := DBMS_LOB.GETLENGTH(l_line_out);

 IF l_cloblen > 32767 THEN
 FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'La lÃ­nea es demasiado larga...'||l_cloblen);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'LEDGER_NAME '||r_q1.LEDGER_NAME);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'LEGAL_ENTITY_NAME '||r_q1.LEGAL_ENTITY_NAME);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'MODO '||r_q1.MODO);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'CLASE_COSTO '||r_q1.CLASE_COSTO);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'CLASE_COSTO_DESCR '||r_q1.CLASE_COSTO_DESCR);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'CLASE_GL '||r_q1.CLASE_GL);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'CLASE_GL_DESCR '||r_q1.CLASE_GL_DESCR);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'PRODUCT_LINE '||r_q1.PRODUCT_LINE);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'RESOURCES '||r_q1.RESOURCES);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'ITEM_CODE '||r_q1.ITEM_CODE);
 --FND_FILE.PUT_LINE(FND_FILE.LOG, 'ITEM_DESCRIPTION '||r_q1.ITEM_DESCRIPTION);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'TRANSACTION_DATE '||r_q1.TRANSACTION_DATE);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'TRANSACTION_TYPE_NAME '||r_q1.TRANSACTION_TYPE_NAME);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'TRANSACTION_ID '||r_q1.TRANSACTION_ID);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'ORGANIZATION_CODE '||r_q1.ORGANIZATION_CODE);
 --FND_FILE.PUT_LINE(FND_FILE.LOG, 'ORGANIZATION_NAME '||r_q1.ORGANIZATION_NAME);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'SUBINVENTORY_CODE '||r_q1.SUBINVENTORY_CODE);
 --FND_FILE.PUT_LINE(FND_FILE.LOG, 'SUBINVENTORY_DESC '||r_q1.SUBINVENTORY_DESC);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'REASON_NAME '||r_q1.REASON_NAME);
 --FND_FILE.PUT_LINE(FND_FILE.LOG, 'REASON_DESCRIPTION '||r_q1.REASON_DESCRIPTION);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'OWNING_SUPPLIER '||r_q1.OWNING_SUPPLIER);  -- adm CR2243 - CH1751
 --FND_FILE.PUT_LINE(FND_FILE.LOG, 'TRANSACTION_QUANTITY '||r_q1.TRANSACTION_QUANTITY);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'PRIMARY_UOM_CODE '||r_q1.PRIMARY_UOM_CODE);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'LOTE '||r_q1.LOTE);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'WIP_ENTITY_NAME '||r_q1.WIP_ENTITY_NAME);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'PO_NUMBER '||r_q1.PO_NUMBER);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'ORDER_NUMBER '||r_q1.ORDER_NUMBER);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'CARTA_PORTE '||r_q1.CARTA_PORTE);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'NUMERO_LIQUIDACION '||r_q1.NUMERO_LIQUIDACION);
 --FND_FILE.PUT_LINE(FND_FILE.LOG, 'PRODUCTOR_LIQUIDACION '||r_q1.PRODUCTOR_LIQUIDACION);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'EVENT_CLASS '||r_q1.EVENT_CLASS);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'EVENT_TYPE '||r_q1.EVENT_TYPE);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'PROJECT_NUMBER '||r_q1.PROJECT_NUMBER);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'TASK_NUMBER '||r_q1.TASK_NUMBER);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'EXPENDITURE_TYPE '||r_q1.EXPENDITURE_TYPE);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'JE_CATEGORY_NAME '||r_q1.JE_CATEGORY_NAME);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'ACCOUNTING_DATE '||r_q1.ACCOUNTING_DATE);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'AE_LINE_NUM '||r_q1.AE_LINE_NUM);
 --FND_FILE.PUT_LINE(FND_FILE.LOG, 'ACCOUNTING_CLASS_MEANING '||r_q1.ACCOUNTING_CLASS_MEANING);
 --FND_FILE.PUT_LINE(FND_FILE.LOG, 'TITULO_CUENTA '||r_q1.TITULO_CUENTA);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'CONCATENATED_SEGMENTS '||r_q1.CONCATENATED_SEGMENTS);
 --FND_FILE.PUT_LINE(FND_FILE.LOG, 'DESCR_CUENTA '||r_q1.DESCR_CUENTA);
 --FND_FILE.PUT_LINE(FND_FILE.LOG, 'CURRENCY_CODE '||r_q1.CURRENCY_CODE);
 --FND_FILE.PUT_LINE(FND_FILE.LOG, 'ENTERED_DR '||r_q1.ENTERED_DR);
 --FND_FILE.PUT_LINE(FND_FILE.LOG, 'ENTERED_CR '||r_q1.ENTERED_CR);
 --FND_FILE.PUT_LINE(FND_FILE.LOG, 'ACCOUNTED_DR '||r_q1.ACCOUNTED_DR);
 --FND_FILE.PUT_LINE(FND_FILE.LOG, 'ACCOUNTED_CR '||r_q1.ACCOUNTED_CR);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'EVENT_ID '||r_q1.EVENT_ID);
 --FND_FILE.PUT_LINE(FND_FILE.LOG, 'USUARIO_TRX '||r_q1.USUARIO_TRX);
 --FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR_DESCRIPTION '||r_q1.ERROR_DESCRIPTION);
 FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
 ELSE
 UTL_FILE.PUT_LINE(l_file, l_line_out);
 END IF;

 IF c_q1%ROWCOUNT = 1 THEN
 l_file_cnt := 1;
 END IF;
 END LOOP;
 CLOSE c_q1;

 UTL_FILE.FCLOSE(l_file);
 FND_FILE.PUT_LINE(FND_FILE.LOG, '- Escribiendo archivo...');

 --IF NVL(l_file_cnt,0) > 0 THEN muevo el archivo sin importar si tiene datos
 FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Moviendo archivo...');
 dbms_output.disable;
 dbms_output.enable;
 dbms_java.set_output(255);
 host_command ('cd '||l_host_path||';/usr/bin/mv '||l_outfile_name||' '||FND_GLOBAL.Conc_Request_ID );
 dbms_output.get_line (l_line, l_status);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'line (0) = '||l_line);
 FND_FILE.PUT_LINE(FND_FILE.LOG, '- Moviendo archivo...');

 FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Comprimiendo directorio...');
 dbms_output.disable;
 dbms_output.enable;
 dbms_java.set_output(255);
 host_command ('cd '||l_host_path||';/usr/bin/zip -r '||FND_GLOBAL.Conc_Request_ID||'.zip '||FND_GLOBAL.Conc_Request_ID );
 dbms_output.get_line (l_line, l_status);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'line = '||l_line);
 FND_FILE.PUT_LINE(FND_FILE.LOG, '- Comprimiendo directorio...');

 FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Moviendo archivo al disco compartido...');
 dbms_output.disable;
 dbms_output.enable;
 dbms_java.set_output(255);
 host_command ('cd '||l_host_path||';/usr/bin/smbclient //192.168.200.69/Company2 -U '||p_usr||'%'||p_pwd||' -W CORP.ADECOAGRO.COM -c "cd '||SUBSTR(p_dest_dir ,4)||';timeout '||p_timeout||';put '||FND_GLOBAL.Conc_Request_ID||'.zip"');
 dbms_output.get_line (l_line, l_status);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'line = '||l_line);
 FND_FILE.PUT_LINE(FND_FILE.LOG, '- Moviendo archivo al disco compartido...');

 FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Moviendo archivo...');
 dbms_output.disable;
 dbms_output.enable;
 dbms_java.set_output(255);
 host_command ('cd '||l_host_path||';/usr/bin/mv '||REPLACE(l_outfile_name,'.txt', '.zip')||' '||FND_GLOBAL.Conc_Request_ID );
 dbms_output.get_line (l_line, l_status);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'line (0) = '||l_line);
 FND_FILE.PUT_LINE(FND_FILE.LOG, '- Moviendo archivo...');

 FND_FILE.PUT_LINE(FND_FILE.LOG, '+ Eliminando archivo...');
 dbms_output.disable;
 dbms_output.enable;
 dbms_java.set_output(255);
 host_command ('cd '||l_host_path||';/usr/bin/rm '||FND_GLOBAL.Conc_Request_ID||'/'||l_outfile_name );
 dbms_output.get_line (l_line, l_status);
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'line (0) = '||l_line);
 FND_FILE.PUT_LINE(FND_FILE.LOG, '- Eliminando archivo...');

 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Se genero el archivo '||FND_GLOBAL.Conc_Request_ID||'.zip en el directorio '||p_dest_dir);
 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Se genero el archivo '||FND_GLOBAL.Conc_Request_ID||'.zip en el directorio '||p_dest_dir);

 --END IF;
 EXCEPTION
 WHEN OTHERS THEN
 FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
 END main_cnc;


 FUNCTION BeforeReportTrigger RETURN boolean IS
 errbuf varchar2(200);
 retcode number;

 l_acc_date_from DATE;
 l_acc_date_to DATE;
 
 
 BEGIN
 fnd_file.put_line(fnd_file.log, 'BEGIN');
 fnd_file.put_line(fnd_file.log, 'P_APPLICATION_ID = '||P_APPLICATION_ID );
 fnd_file.put_line(fnd_file.log, 'P_ORG_ID = '||P_ORG_ID );
 fnd_file.put_line(fnd_file.log, 'P_GL_PERIOD = '||P_GL_PERIOD );
 fnd_file.put_line(fnd_file.log, 'P_FECHA_DESDE = '||P_FECHA_DESDE );
 fnd_file.put_line(fnd_file.log, 'P_FECHA_HASTA = '||P_FECHA_HASTA );
 fnd_file.put_line(fnd_file.log, 'P_EVENT_CLASS_GROUP_CODE = '||P_EVENT_CLASS_GROUP_CODE );
 fnd_file.put_line(fnd_file.log, 'P_TRANSACTION_TYPE_ID = '||P_TRANSACTION_TYPE_ID );
 fnd_file.put_line(fnd_file.log, 'P_SOLO_ERRORES = '||P_SOLO_ERRORES );


 fnd_file.put_line(fnd_file.log, 'fnd_global.org_id = '||fnd_global.org_id );
 fnd_file.put_line(fnd_file.log, 'fnd_global.user_id = '||fnd_global.user_id );
 fnd_file.put_line(fnd_file.log, 'fnd_global.resp_id = '||fnd_global.resp_id );
 fnd_file.put_line(fnd_file.log, 'fnd_global.resp_appl_id = '||fnd_global.resp_appl_id );

 l_acc_date_from := TO_DATE (P_FECHA_DESDE,'dd-mm-yyyy hh24:mi:ss');
 l_acc_date_to := TO_DATE (substr (P_FECHA_HASTA, 1, 10)||' 23:59:59','dd-mm-yyyy hh24:mi:ss');
 fnd_file.put_line(fnd_file.log, 'l_acc_date_from = '|| l_acc_date_from );
 fnd_file.put_line(fnd_file.log, 'l_acc_date_to = '|| l_acc_date_to );


 fnd_file.put_line(fnd_file.log, 'BEGIN xx_rcv_transactions '||to_char (sysdate, 'dd/mm/yyyy hh24:mi:ss'));
 EXECUTE IMMEDIATE 'truncate table apps.XX_RCV_TRANSACTIONS';
 INSERT INTO xx_rcv_transactions
 ( TRANSACTION_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, TRANSACTION_TYPE, TRANSACTION_DATE, QUANTITY, UNIT_OF_MEASURE, SHIPMENT_HEADER_ID, SHIPMENT_LINE_ID, USER_ENTERED_FLAG, INTERFACE_SOURCE_CODE, INTERFACE_SOURCE_LINE_ID, INV_TRANSACTION_ID, SOURCE_DOCUMENT_CODE, DESTINATION_TYPE_CODE, PRIMARY_QUANTITY, PRIMARY_UNIT_OF_MEASURE, UOM_CODE, EMPLOYEE_ID
 , PARENT_TRANSACTION_ID, PO_HEADER_ID, PO_RELEASE_ID, PO_LINE_ID, PO_LINE_LOCATION_ID, PO_DISTRIBUTION_ID, PO_REVISION_NUM, REQUISITION_LINE_ID, PO_UNIT_PRICE, CURRENCY_CODE, CURRENCY_CONVERSION_TYPE, CURRENCY_CONVERSION_RATE, CURRENCY_CONVERSION_DATE, ROUTING_HEADER_ID, ROUTING_STEP_ID, DELIVER_TO_PERSON_ID, DELIVER_TO_LOCATION_ID, VENDOR_ID, VENDOR_SITE_ID, ORGANIZATION_ID, SUBINVENTORY, LOCATOR_ID, WIP_ENTITY_ID, WIP_LINE_ID, WIP_REPETITIVE_SCHEDULE_ID
 , WIP_OPERATION_SEQ_NUM, WIP_RESOURCE_SEQ_NUM, BOM_RESOURCE_ID, LOCATION_ID, SUBSTITUTE_UNORDERED_CODE, RECEIPT_EXCEPTION_FLAG, INSPECTION_STATUS_CODE, ACCRUAL_STATUS_CODE, INSPECTION_QUALITY_CODE, VENDOR_LOT_NUM, RMA_REFERENCE, COMMENTS, ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, REQ_DISTRIBUTION_ID
 , DEPARTMENT_CODE, REASON_ID, DESTINATION_CONTEXT, LOCATOR_ATTRIBUTE, CHILD_INSPECTION_FLAG, SOURCE_DOC_UNIT_OF_MEASURE, SOURCE_DOC_QUANTITY, INTERFACE_TRANSACTION_ID, GROUP_ID, MOVEMENT_ID, INVOICE_ID, INVOICE_STATUS_CODE, QA_COLLECTION_ID, MRC_CURRENCY_CONVERSION_TYPE, MRC_CURRENCY_CONVERSION_DATE, MRC_CURRENCY_CONVERSION_RATE, COUNTRY_OF_ORIGIN_CODE, MVT_STAT_STATUS, QUANTITY_BILLED, MATCH_FLAG, AMOUNT_BILLED, MATCH_OPTION, OE_ORDER_HEADER_ID, OE_ORDER_LINE_ID
 , CUSTOMER_ID, CUSTOMER_SITE_ID, LPN_ID, TRANSFER_LPN_ID, MOBILE_TXN, SECONDARY_QUANTITY, SECONDARY_UNIT_OF_MEASURE, QC_GRADE, SECONDARY_UOM_CODE, PA_ADDITION_FLAG, CONSIGNED_FLAG, SOURCE_TRANSACTION_NUM, FROM_SUBINVENTORY, FROM_LOCATOR_ID, AMOUNT, DROPSHIP_TYPE_CODE, LPN_GROUP_ID, JOB_ID, TIMECARD_ID, TIMECARD_OVN, PROJECT_ID, TASK_ID, REQUESTED_AMOUNT, MATERIAL_STORED_AMOUNT, REPLENISH_ORDER_LINE_ID, LCM_SHIPMENT_LINE_ID, UNIT_LANDED_COST, RECEIPT_CONFIRMATION_EXTRACTED, XML_DOCUMENT_ID, LCM_ADJUSTMENT_NUM)
 SELECT TRANSACTION_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, TRANSACTION_TYPE, TRANSACTION_DATE, QUANTITY, UNIT_OF_MEASURE, SHIPMENT_HEADER_ID, SHIPMENT_LINE_ID, USER_ENTERED_FLAG, INTERFACE_SOURCE_CODE, INTERFACE_SOURCE_LINE_ID, INV_TRANSACTION_ID, SOURCE_DOCUMENT_CODE, DESTINATION_TYPE_CODE
 , PRIMARY_QUANTITY, PRIMARY_UNIT_OF_MEASURE, UOM_CODE, EMPLOYEE_ID, PARENT_TRANSACTION_ID, PO_HEADER_ID, PO_RELEASE_ID, PO_LINE_ID, PO_LINE_LOCATION_ID, PO_DISTRIBUTION_ID, PO_REVISION_NUM, REQUISITION_LINE_ID, PO_UNIT_PRICE, CURRENCY_CODE, CURRENCY_CONVERSION_TYPE, CURRENCY_CONVERSION_RATE, CURRENCY_CONVERSION_DATE, ROUTING_HEADER_ID, ROUTING_STEP_ID, DELIVER_TO_PERSON_ID, DELIVER_TO_LOCATION_ID
 , VENDOR_ID, VENDOR_SITE_ID, ORGANIZATION_ID, SUBINVENTORY, LOCATOR_ID, WIP_ENTITY_ID, WIP_LINE_ID, WIP_REPETITIVE_SCHEDULE_ID, WIP_OPERATION_SEQ_NUM, WIP_RESOURCE_SEQ_NUM, BOM_RESOURCE_ID, LOCATION_ID, SUBSTITUTE_UNORDERED_CODE, RECEIPT_EXCEPTION_FLAG, INSPECTION_STATUS_CODE, ACCRUAL_STATUS_CODE, INSPECTION_QUALITY_CODE, VENDOR_LOT_NUM, RMA_REFERENCE, COMMENTS
 , ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, REQ_DISTRIBUTION_ID, DEPARTMENT_CODE, REASON_ID, DESTINATION_CONTEXT, LOCATOR_ATTRIBUTE, CHILD_INSPECTION_FLAG, SOURCE_DOC_UNIT_OF_MEASURE, SOURCE_DOC_QUANTITY
 , INTERFACE_TRANSACTION_ID, GROUP_ID, MOVEMENT_ID, INVOICE_ID, INVOICE_STATUS_CODE, QA_COLLECTION_ID, MRC_CURRENCY_CONVERSION_TYPE, MRC_CURRENCY_CONVERSION_DATE, MRC_CURRENCY_CONVERSION_RATE, COUNTRY_OF_ORIGIN_CODE, MVT_STAT_STATUS, QUANTITY_BILLED, MATCH_FLAG, AMOUNT_BILLED, MATCH_OPTION, OE_ORDER_HEADER_ID, OE_ORDER_LINE_ID, CUSTOMER_ID, CUSTOMER_SITE_ID, LPN_ID, TRANSFER_LPN_ID, MOBILE_TXN
 , SECONDARY_QUANTITY, SECONDARY_UNIT_OF_MEASURE, QC_GRADE, SECONDARY_UOM_CODE, PA_ADDITION_FLAG, CONSIGNED_FLAG, SOURCE_TRANSACTION_NUM, FROM_SUBINVENTORY, FROM_LOCATOR_ID, AMOUNT, DROPSHIP_TYPE_CODE, LPN_GROUP_ID, JOB_ID, TIMECARD_ID, TIMECARD_OVN, PROJECT_ID, TASK_ID, REQUESTED_AMOUNT, MATERIAL_STORED_AMOUNT, REPLENISH_ORDER_LINE_ID, LCM_SHIPMENT_LINE_ID, UNIT_LANDED_COST, RECEIPT_CONFIRMATION_EXTRACTED, XML_DOCUMENT_ID, LCM_ADJUSTMENT_NUM
 FROM rcv_transactions rt
 WHERE rt.transaction_date BETWEEN l_acc_date_from --TO_DATE ('01/12/2018 00:00:00', 'dd/mm/yyyy hh24:mi:ss')
 AND l_acc_date_to--TO_DATE ('31/12/2018 '||'23:59:59','dd/mm/yyyy hh24:mi:ss')
 ;

 fnd_file.put_line(fnd_file.log, 'end xx_rcv_transactions '||to_char (sysdate, 'dd/mm/yyyy hh24:mi:ss') || ' RC = '||sql%Rowcount);

 fnd_file.put_line(fnd_file.log, 'BEGIN xx_gmf_xla_extract_headers '||to_char (sysdate, 'dd/mm/yyyy hh24:mi:ss'));

 EXECUTE IMMEDIATE 'truncate table apps.xx_gmf_xla_extract_headers';
 INSERT INTO xx_gmf_xla_extract_headers
 ( HEADER_ID, REFERENCE_NO, EVENT_ID, ENTITY_CODE, EVENT_CLASS_CODE, EVENT_TYPE_CODE, LEGAL_ENTITY_ID, LEDGER_ID, XFER_LEGAL_ENTITY_ID, XFER_LEDGER_ID, OPERATING_UNIT, BASE_CURRENCY, TRANSACTION_ID, TRANSACTION_DATE, VALUATION_COST_TYPE_ID, VALUATION_COST_TYPE, INVENTORY_ITEM_ID, ORGANIZATION_ID, LOT_NUMBER, TRANSACTION_QUANTITY, TRANSACTION_UOM, TRANSACTION_SOURCE_TYPE_ID
 , TRANSACTION_ACTION_ID, TRANSACTION_TYPE_ID, TRANSACTION_VALUE, TRANSACTION_VALUE_RAW, TRANSACTION_CURRENCY, TXN_SOURCE, SOURCE_DOCUMENT_ID, SOURCE_LINE_ID, CURRENCY_CODE, CURRENCY_CONVERSION_DATE, CURRENCY_CONVERSION_TYPE, RESOURCES, LINE_TYPE, AR_TRX_TYPE_ID, ORDER_TYPE, ACCOUNTED_FLAG, ACTUAL_POSTING_DATE, SHIPMENT_COSTED, INVOICED_FLAG, CURRENCY_CONVERSION_RATE, ITEM_REVISION, REASON_ID, CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, REQUEST_ID)
 SELECT HEADER_ID, REFERENCE_NO, EVENT_ID, ENTITY_CODE, EVENT_CLASS_CODE, EVENT_TYPE_CODE, LEGAL_ENTITY_ID, LEDGER_ID, XFER_LEGAL_ENTITY_ID, XFER_LEDGER_ID, OPERATING_UNIT, BASE_CURRENCY, TRANSACTION_ID, TRANSACTION_DATE, VALUATION_COST_TYPE_ID, VALUATION_COST_TYPE, INVENTORY_ITEM_ID, ORGANIZATION_ID, LOT_NUMBER, TRANSACTION_QUANTITY, TRANSACTION_UOM, TRANSACTION_SOURCE_TYPE_ID, TRANSACTION_ACTION_ID
 , TRANSACTION_TYPE_ID, TRANSACTION_VALUE, TRANSACTION_VALUE_RAW, TRANSACTION_CURRENCY, TXN_SOURCE, SOURCE_DOCUMENT_ID, SOURCE_LINE_ID, CURRENCY_CODE, CURRENCY_CONVERSION_DATE, CURRENCY_CONVERSION_TYPE, RESOURCES, LINE_TYPE, AR_TRX_TYPE_ID, ORDER_TYPE, ACCOUNTED_FLAG, ACTUAL_POSTING_DATE, SHIPMENT_COSTED, INVOICED_FLAG, CURRENCY_CONVERSION_RATE, ITEM_REVISION, REASON_ID, CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, REQUEST_ID
 FROM gmf_xla_extract_headers gxh
 WHERE gxh.transaction_date BETWEEN l_acc_date_from --TO_DATE ('01/12/2018 00:00:00', 'dd/mm/yyyy hh24:mi:ss')
 AND l_acc_date_to--TO_DATE ('31/12/2018 '||'23:59:59','dd/mm/yyyy hh24:mi:ss')
 ;

 fnd_file.put_line(fnd_file.log, 'END xx_gmf_xla_extract_headers '||to_char (sysdate, 'dd/mm/yyyy hh24:mi:ss')|| ' RC = '||sql%Rowcount);

 fnd_file.put_line(fnd_file.log, 'BEGIN xx_wip_transactions '||to_char (sysdate, 'dd/mm/yyyy hh24:mi:ss'));

 EXECUTE IMMEDIATE 'truncate table apps.xx_wip_transactions';
 INSERT INTO xx_wip_transactions
 ( TRANSACTION_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, ORGANIZATION_ID, WIP_ENTITY_ID, PRIMARY_ITEM_ID, ACCT_PERIOD_ID, DEPARTMENT_ID, TRANSACTION_TYPE, TRANSACTION_DATE, GROUP_ID, LINE_ID, SOURCE_CODE, SOURCE_LINE_ID, OPERATION_SEQ_NUM, RESOURCE_SEQ_NUM, EMPLOYEE_ID, RESOURCE_ID, AUTOCHARGE_TYPE, STANDARD_RATE_FLAG, USAGE_RATE_OR_AMOUNT, BASIS_TYPE
 , TRANSACTION_QUANTITY, TRANSACTION_UOM, PRIMARY_QUANTITY, PRIMARY_UOM, ACTUAL_RESOURCE_RATE, STANDARD_RESOURCE_RATE, CURRENCY_CODE, CURRENCY_CONVERSION_DATE, CURRENCY_CONVERSION_TYPE, CURRENCY_CONVERSION_RATE, CURRENCY_ACTUAL_RESOURCE_RATE, ACTIVITY_ID, REASON_ID, REFERENCE, MOVE_TRANSACTION_ID, PO_HEADER_ID, PO_LINE_ID, RCV_TRANSACTION_ID
 , ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15
 , REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, COST_UPDATE_ID, PM_COST_COLLECTED, PM_COST_COLLECTOR_GROUP_ID, PROJECT_ID, TASK_ID, COMPLETION_TRANSACTION_ID, CHARGE_DEPARTMENT_ID, INSTANCE_ID, ENCUMBRANCE_TYPE_ID, ENCUMBRANCE_AMOUNT, ENCUMBRANCE_QUANTITY, ENCUMBRANCE_CCID)
 SELECT TRANSACTION_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, ORGANIZATION_ID, WIP_ENTITY_ID, PRIMARY_ITEM_ID, ACCT_PERIOD_ID, DEPARTMENT_ID, TRANSACTION_TYPE, TRANSACTION_DATE, GROUP_ID, LINE_ID, SOURCE_CODE, SOURCE_LINE_ID, OPERATION_SEQ_NUM, RESOURCE_SEQ_NUM, EMPLOYEE_ID, RESOURCE_ID, AUTOCHARGE_TYPE, STANDARD_RATE_FLAG
 , USAGE_RATE_OR_AMOUNT, BASIS_TYPE, TRANSACTION_QUANTITY, TRANSACTION_UOM, PRIMARY_QUANTITY, PRIMARY_UOM, ACTUAL_RESOURCE_RATE, STANDARD_RESOURCE_RATE, CURRENCY_CODE, CURRENCY_CONVERSION_DATE, CURRENCY_CONVERSION_TYPE, CURRENCY_CONVERSION_RATE, CURRENCY_ACTUAL_RESOURCE_RATE, ACTIVITY_ID, REASON_ID, REFERENCE, MOVE_TRANSACTION_ID, PO_HEADER_ID, PO_LINE_ID, RCV_TRANSACTION_ID
 , ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15
 , REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, COST_UPDATE_ID, PM_COST_COLLECTED, PM_COST_COLLECTOR_GROUP_ID, PROJECT_ID, TASK_ID, COMPLETION_TRANSACTION_ID, CHARGE_DEPARTMENT_ID, INSTANCE_ID, ENCUMBRANCE_TYPE_ID, ENCUMBRANCE_AMOUNT, ENCUMBRANCE_QUANTITY, ENCUMBRANCE_CCID
 FROM wip_transactions wt
 WHERE wt.transaction_date BETWEEN l_acc_date_from --TO_DATE ('01/12/2018 00:00:00', 'dd/mm/yyyy hh24:mi:ss')
 AND l_acc_date_to--TO_DATE ('31/12/2018 '||'23:59:59','dd/mm/yyyy hh24:mi:ss')
 ;

 fnd_file.put_line(fnd_file.log, 'END xx_wip_transactions '||to_char (sysdate, 'dd/mm/yyyy hh24:mi:ss')|| ' RC = '||sql%Rowcount);


 fnd_file.put_line(fnd_file.log, 'BEGIN xx_mtl_material_transactions '||to_char (sysdate, 'dd/mm/yyyy hh24:mi:ss'));

 EXECUTE IMMEDIATE 'truncate table apps.xx_mtl_material_transactions';
 INSERT INTO xx_mtl_material_transactions
 ( TRANSACTION_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, INVENTORY_ITEM_ID, REVISION, ORGANIZATION_ID, SUBINVENTORY_CODE, LOCATOR_ID, TRANSACTION_TYPE_ID, TRANSACTION_ACTION_ID, TRANSACTION_SOURCE_TYPE_ID, TRANSACTION_SOURCE_ID, TRANSACTION_SOURCE_NAME, TRANSACTION_QUANTITY, TRANSACTION_UOM
 , PRIMARY_QUANTITY, TRANSACTION_DATE, VARIANCE_AMOUNT, ACCT_PERIOD_ID, TRANSACTION_REFERENCE, REASON_ID, DISTRIBUTION_ACCOUNT_ID, ENCUMBRANCE_ACCOUNT, ENCUMBRANCE_AMOUNT, COST_UPDATE_ID, COSTED_FLAG, TRANSACTION_GROUP_ID, INVOICED_FLAG, ACTUAL_COST, TRANSACTION_COST, PRIOR_COST, NEW_COST, CURRENCY_CODE, CURRENCY_CONVERSION_RATE, CURRENCY_CONVERSION_TYPE, CURRENCY_CONVERSION_DATE, USSGL_TRANSACTION_CODE, QUANTITY_ADJUSTED, EMPLOYEE_CODE, DEPARTMENT_ID, OPERATION_SEQ_NUM, MASTER_SCHEDULE_UPDATE_CODE, RECEIVING_DOCUMENT, PICKING_LINE_ID, TRX_SOURCE_LINE_ID, TRX_SOURCE_DELIVERY_ID
 , REPETITIVE_LINE_ID, PHYSICAL_ADJUSTMENT_ID, CYCLE_COUNT_ID, RMA_LINE_ID, TRANSFER_TRANSACTION_ID, TRANSACTION_SET_ID, RCV_TRANSACTION_ID, MOVE_TRANSACTION_ID, COMPLETION_TRANSACTION_ID, SHORTAGE_PROCESS_CODE, SOURCE_CODE, SOURCE_LINE_ID, VENDOR_LOT_NUMBER, TRANSFER_ORGANIZATION_ID, TRANSFER_SUBINVENTORY, TRANSFER_LOCATOR_ID, SHIPMENT_NUMBER, TRANSFER_COST, TRANSPORTATION_DIST_ACCOUNT, TRANSPORTATION_COST, TRANSFER_COST_DIST_ACCOUNT, WAYBILL_AIRBILL, FREIGHT_CODE, NUMBER_OF_CONTAINERS, VALUE_CHANGE, PERCENTAGE_CHANGE
 , ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, MOVEMENT_ID, TASK_ID, TO_TASK_ID, PROJECT_ID, TO_PROJECT_ID, SOURCE_PROJECT_ID, PA_EXPENDITURE_ORG_ID, SOURCE_TASK_ID, EXPENDITURE_TYPE, ERROR_CODE, ERROR_EXPLANATION, PRIOR_COSTED_QUANTITY, TRANSFER_PRIOR_COSTED_QUANTITY, FINAL_COMPLETION_FLAG, PM_COST_COLLECTED, PM_COST_COLLECTOR_GROUP_ID, SHIPMENT_COSTED
 , TRANSFER_PERCENTAGE, MATERIAL_ACCOUNT, MATERIAL_OVERHEAD_ACCOUNT, RESOURCE_ACCOUNT, OUTSIDE_PROCESSING_ACCOUNT, OVERHEAD_ACCOUNT, COST_GROUP_ID, TRANSFER_COST_GROUP_ID, FLOW_SCHEDULE, QA_COLLECTION_ID, OVERCOMPLETION_TRANSACTION_QTY, OVERCOMPLETION_PRIMARY_QTY, OVERCOMPLETION_TRANSACTION_ID, MVT_STAT_STATUS, COMMON_BOM_SEQ_ID, COMMON_ROUTING_SEQ_ID, ORG_COST_GROUP_ID, COST_TYPE_ID, PERIODIC_PRIMARY_QUANTITY, MOVE_ORDER_LINE_ID, TASK_GROUP_ID, PICK_SLIP_NUMBER, LPN_ID, TRANSFER_LPN_ID, PICK_STRATEGY_ID, PICK_RULE_ID, PUT_AWAY_STRATEGY_ID, PUT_AWAY_RULE_ID
 , CONTENT_LPN_ID, PICK_SLIP_DATE, COST_CATEGORY_ID, ORGANIZATION_TYPE, TRANSFER_ORGANIZATION_TYPE, OWNING_ORGANIZATION_ID, OWNING_TP_TYPE, XFR_OWNING_ORGANIZATION_ID, TRANSFER_OWNING_TP_TYPE, PLANNING_ORGANIZATION_ID, PLANNING_TP_TYPE, XFR_PLANNING_ORGANIZATION_ID, TRANSFER_PLANNING_TP_TYPE, SECONDARY_UOM_CODE, SECONDARY_TRANSACTION_QUANTITY, TRANSACTION_GROUP_SEQ, SHIP_TO_LOCATION_ID, RESERVATION_ID, TRANSACTION_MODE, TRANSACTION_BATCH_ID, TRANSACTION_BATCH_SEQ, INTRANSIT_ACCOUNT, FOB_POINT, PARENT_TRANSACTION_ID, LOGICAL_TRX_TYPE_CODE, TRX_FLOW_HEADER_ID, LOGICAL_TRANSACTIONS_CREATED
 , LOGICAL_TRANSACTION, INTERCOMPANY_COST, INTERCOMPANY_PRICING_OPTION, INTERCOMPANY_CURRENCY_CODE, ORIGINAL_TRANSACTION_TEMP_ID, TRANSFER_PRICE, EXPENSE_ACCOUNT_ID, COGS_RECOGNITION_PERCENT, SO_ISSUE_ACCOUNT_TYPE, OPM_COSTED_FLAG, XML_DOCUMENT_ID, MATERIAL_EXPENSE_ACCOUNT, TRANSACTION_EXTRACTED, MCC_CODE)
 SELECT TRANSACTION_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, INVENTORY_ITEM_ID, REVISION, ORGANIZATION_ID, SUBINVENTORY_CODE, LOCATOR_ID, TRANSACTION_TYPE_ID, TRANSACTION_ACTION_ID, TRANSACTION_SOURCE_TYPE_ID, TRANSACTION_SOURCE_ID, TRANSACTION_SOURCE_NAME, TRANSACTION_QUANTITY, TRANSACTION_UOM, PRIMARY_QUANTITY
 , TRANSACTION_DATE, VARIANCE_AMOUNT, ACCT_PERIOD_ID, TRANSACTION_REFERENCE, REASON_ID, DISTRIBUTION_ACCOUNT_ID, ENCUMBRANCE_ACCOUNT, ENCUMBRANCE_AMOUNT, COST_UPDATE_ID, COSTED_FLAG, TRANSACTION_GROUP_ID, INVOICED_FLAG, ACTUAL_COST, TRANSACTION_COST, PRIOR_COST, NEW_COST, CURRENCY_CODE, CURRENCY_CONVERSION_RATE, CURRENCY_CONVERSION_TYPE, CURRENCY_CONVERSION_DATE, USSGL_TRANSACTION_CODE, QUANTITY_ADJUSTED, EMPLOYEE_CODE, DEPARTMENT_ID, OPERATION_SEQ_NUM
 , MASTER_SCHEDULE_UPDATE_CODE, RECEIVING_DOCUMENT, PICKING_LINE_ID, TRX_SOURCE_LINE_ID, TRX_SOURCE_DELIVERY_ID, REPETITIVE_LINE_ID, PHYSICAL_ADJUSTMENT_ID, CYCLE_COUNT_ID, RMA_LINE_ID, TRANSFER_TRANSACTION_ID, TRANSACTION_SET_ID, RCV_TRANSACTION_ID, MOVE_TRANSACTION_ID, COMPLETION_TRANSACTION_ID, SHORTAGE_PROCESS_CODE, SOURCE_CODE, SOURCE_LINE_ID, VENDOR_LOT_NUMBER, TRANSFER_ORGANIZATION_ID, TRANSFER_SUBINVENTORY, TRANSFER_LOCATOR_ID, SHIPMENT_NUMBER
 , TRANSFER_COST, TRANSPORTATION_DIST_ACCOUNT, TRANSPORTATION_COST, TRANSFER_COST_DIST_ACCOUNT, WAYBILL_AIRBILL, FREIGHT_CODE, NUMBER_OF_CONTAINERS, VALUE_CHANGE, PERCENTAGE_CHANGE, ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, MOVEMENT_ID, TASK_ID, TO_TASK_ID, PROJECT_ID, TO_PROJECT_ID, SOURCE_PROJECT_ID
 , PA_EXPENDITURE_ORG_ID, SOURCE_TASK_ID, EXPENDITURE_TYPE, ERROR_CODE, ERROR_EXPLANATION, PRIOR_COSTED_QUANTITY, TRANSFER_PRIOR_COSTED_QUANTITY, FINAL_COMPLETION_FLAG, PM_COST_COLLECTED, PM_COST_COLLECTOR_GROUP_ID, SHIPMENT_COSTED, TRANSFER_PERCENTAGE, MATERIAL_ACCOUNT, MATERIAL_OVERHEAD_ACCOUNT, RESOURCE_ACCOUNT, OUTSIDE_PROCESSING_ACCOUNT, OVERHEAD_ACCOUNT, COST_GROUP_ID, TRANSFER_COST_GROUP_ID, FLOW_SCHEDULE, QA_COLLECTION_ID, OVERCOMPLETION_TRANSACTION_QTY, OVERCOMPLETION_PRIMARY_QTY, OVERCOMPLETION_TRANSACTION_ID
 , MVT_STAT_STATUS, COMMON_BOM_SEQ_ID, COMMON_ROUTING_SEQ_ID, ORG_COST_GROUP_ID, COST_TYPE_ID, PERIODIC_PRIMARY_QUANTITY, MOVE_ORDER_LINE_ID, TASK_GROUP_ID, PICK_SLIP_NUMBER, LPN_ID, TRANSFER_LPN_ID, PICK_STRATEGY_ID, PICK_RULE_ID, PUT_AWAY_STRATEGY_ID, PUT_AWAY_RULE_ID, CONTENT_LPN_ID, PICK_SLIP_DATE, COST_CATEGORY_ID, ORGANIZATION_TYPE, TRANSFER_ORGANIZATION_TYPE, OWNING_ORGANIZATION_ID, OWNING_TP_TYPE, XFR_OWNING_ORGANIZATION_ID, TRANSFER_OWNING_TP_TYPE
 , PLANNING_ORGANIZATION_ID, PLANNING_TP_TYPE, XFR_PLANNING_ORGANIZATION_ID, TRANSFER_PLANNING_TP_TYPE, SECONDARY_UOM_CODE, SECONDARY_TRANSACTION_QUANTITY, TRANSACTION_GROUP_SEQ, SHIP_TO_LOCATION_ID, RESERVATION_ID, TRANSACTION_MODE, TRANSACTION_BATCH_ID, TRANSACTION_BATCH_SEQ, INTRANSIT_ACCOUNT, FOB_POINT, PARENT_TRANSACTION_ID, LOGICAL_TRX_TYPE_CODE, TRX_FLOW_HEADER_ID, LOGICAL_TRANSACTIONS_CREATED, LOGICAL_TRANSACTION
 , INTERCOMPANY_COST, INTERCOMPANY_PRICING_OPTION, INTERCOMPANY_CURRENCY_CODE, ORIGINAL_TRANSACTION_TEMP_ID, TRANSFER_PRICE, EXPENSE_ACCOUNT_ID, COGS_RECOGNITION_PERCENT, SO_ISSUE_ACCOUNT_TYPE, OPM_COSTED_FLAG, XML_DOCUMENT_ID, MATERIAL_EXPENSE_ACCOUNT, TRANSACTION_EXTRACTED, MCC_CODE
 FROM mtl_material_transactions mmt
 WHERE mmt.transaction_date BETWEEN l_acc_date_from --TO_DATE ('01/12/2018 00:00:00', 'dd/mm/yyyy hh24:mi:ss')
 AND l_acc_date_to--TO_DATE ('31/12/2018 '||'23:59:59','dd/mm/yyyy hh24:mi:ss')
 ;

 fnd_file.put_line(fnd_file.log, 'END xx_mtl_material_transactions '||to_char (sysdate, 'dd/mm/yyyy hh24:mi:ss')|| ' RC = '||sql%Rowcount);
 fnd_file.put_line(fnd_file.log, 'BEGIN pop xx_category_sets '||to_char (sysdate, 'dd/mm/yyyy hh24:mi:ss'));

 EXECUTE IMMEDIATE 'truncate table apps.xx_category_sets';
 INSERT INTO xx_category_sets
 --(ORGANIZATION_ID, INVENTORY_ITEM_ID, SEGMENT1, DESCRIPTION, category_concat_segs, CATEGORY_SET_NAME)
 (ORGANIZATION_ID, INVENTORY_ITEM_ID, SEGMENT1, DESCRIPTION, category_concat_segs, CATEGORY_SET_NAME)
 SELECT q.organization_id, q.inventory_item_id, NVL(q1.segment1, q2.segment1) segment1, NVL (q1.description, q2.description) description, NVL (q1.category_concat_segs, q2.category_concat_segs) category_concat_segs , q.category_set_name
 --, q2.segment1, q2.description, q2.category_concat_segs
 FROM ( SELECT mic.organization_id, mic.inventory_item_id, mcb.segment1, mc.description, mcbk.CONCATENATED_SEGMENTS category_concat_segs, mic.category_set_id
 FROM inv.mtl_item_categories mic
 , MTL_CATEGORIES_B_KFV mcbk
 , inv.mtl_categories_b mcb
 , mtl_categories mc
 WHERE mcb.category_id = mic.category_id
 --AND mic.organization_id = p.master_organization_id
 AND mcb.rowid = mcbk.row_id
 AND mcb.category_id = mc.category_id
 ) q1
 , ( SELECT mic.organization_id, mic.inventory_item_id, mcb.segment1, mc.description, mcbk.CONCATENATED_SEGMENTS category_concat_segs, mic.category_set_id
 FROM inv.mtl_item_categories mic
 , MTL_CATEGORIES_B_KFV mcbk
 , inv.mtl_categories_b mcb
 , mtl_categories mc
 WHERE mcb.category_id = mic.category_id
 --AND mic.organization_id = p.master_organization_id
 AND mcb.rowid = mcbk.row_id
 AND mcb.category_id = mc.category_id
 ) q2
 , mtl_parameters p
 --, mtl_system_items msi
 , ( SELECT sq.organization_id, sq.inventory_item_id, mcst.category_set_id , mcst.category_set_name
 FROM ( SELECT DISTINCT organization_id, inventory_item_id
 FROM xx_gmf_xla_extract_headers
 UNION
 SELECT
 DISTINCT xrt.organization_id, rsl.item_id
 FROM xx_rcv_transactions xrt
 , rcv_shipment_lines rsl
 WHERE xrt.shipment_line_id = rsl.shipment_line_id(+)
 UNION
 SELECT DISTINCT organization_id, primary_item_id
 FROM xx_wip_transactions
 UNION
 SELECT DISTINCT organization_id, inventory_item_id
 FROM xx_mtl_material_transactions
 ) sq
 , ( SELECT mcst.category_set_id, mcst.category_set_name
 FROM inv.MTL_CATEGORY_SETS_TL MCST
 WHERE mcst.language = USERENV('LANG')
 AND mcst.category_set_name IN ('CategorÃ­a Contable OPM', 'CategorÃ­a de Producto OPM', 'CategorÃ­a Costos OPM')
 ) mcst
 ) q
 WHERE 1=1
 --AND mic.category_set_id = 1100000042
 --AND msi.inventory_item_id = mic.inventory_item_id
 AND q.organization_id = p.organization_id (+)
 --AND p.organization_id = 310
 -- AND mic.inventory_item_id = 10919
 -- AND mic.organization_id = 1166
 --AND mic.organization_id = 1166 and mic.inventory_item_id = 3160495
 --1 = 1
 AND q1.inventory_item_id (+) = q.inventory_item_id
 AND q1.organization_id (+)= q.organization_id
 AND q1.category_set_id (+) = q.category_set_id
 AND q2.inventory_item_id (+) = q.inventory_item_id
 AND q2.organization_id (+) = p.master_organization_id
 AND q2.category_set_id (+) = q.category_set_id
 AND q.inventory_item_id IS NOT NULL
 ;
 /*
 SELECT ic.organization_id,
 ic.inventory_item_id,
 mc.segment1,
 mc.description,
 ic.category_concat_segs
 , ic.category_set_name
 FROM mtl_item_categories_v ic,
 mtl_categories mc
 WHERE
 mc.category_id = ic.category_id

 AND ic.category_set_name IN

 ('CategorÃ­a Contable OPM', 'CategorÃ­a de Producto OPM', 'CategorÃ­a Costos OPM')
 ;
 */

 fnd_file.put_line(fnd_file.log, 'END pop xx_category_sets '||to_char (sysdate, 'dd/mm/yyyy hh24:mi:ss')|| ' RC = '||sql%Rowcount);

 fnd_file.put_line(fnd_file.log, 'BEGIN pop xx_msi_cat '||to_char (sysdate, 'dd/mm/yyyy hh24:mi:ss'));

 EXECUTE IMMEDIATE 'truncate table apps.xx_msi_cat';
 INSERT INTO xx_msi_cat
 ( ORGANIZATION_ID, ORGANIZATION_CODE, INVENTORY_ITEM_ID, ITEM_CODE, ITEM_DESCRIPTION, LOT_CONTROL_CODE, PRIMARY_UOM_CODE
 , CLASE_COSTO, CLASE_COSTO_DESCR, CLASE_GL, CLASE_GL_DESCR, CLASE_PROD, CLASE_PROD_DESCR, CAT)
 SELECT p.organization_id, p.organization_code, msi.inventory_item_id, msi.segment1 item_code, msi.description item_description, msi.lot_control_code, msi.primary_uom_code
 , cat_cost.segment1 clase_costo, cat_cost.description clase_costo_descr, cat_gl.segment1 clase_gl, cat_gl.description clase_gl_descr, cat_prod.segment1 clase_prod, cat_prod.description clase_prod_descr, cat_prod.category_concat_segs cat
 FROM mtl_system_items msi,
 mtl_parameters p,
 ( SELECT organization_id, inventory_item_id, segment1, description
 FROM xx_category_sets
 WHERE category_set_name = 'CategorÃ­a Costos OPM'
 ) cat_cost,
 ( SELECT organization_id, inventory_item_id, segment1, description, category_concat_segs
 FROM xx_category_sets
 WHERE category_set_name = 'CategorÃ­a de Producto OPM'
 ) cat_prod,
 ( SELECT organization_id, inventory_item_id, segment1, description
 FROM xx_category_sets
 WHERE category_set_name = 'CategorÃ­a Contable OPM'
 ) cat_gl
 WHERE 1=1
 AND msi.organization_id = p.organization_id
 AND cat_cost.organization_id = p.organization_id
 AND cat_cost.inventory_item_id = msi.inventory_item_id
 AND cat_gl.organization_id = p.organization_id
 AND cat_gl.inventory_item_id = msi.inventory_item_id
 AND cat_prod.organization_id = p.organization_id
 AND cat_prod.inventory_item_id = msi.inventory_item_id
 ;
 fnd_file.put_line(fnd_file.log, 'END end xx_msi_cat '||to_char (sysdate, 'dd/mm/yyyy hh24:mi:ss')|| ' RC = '||sql%Rowcount);
 
  
 EXECUTE IMMEDIATE 'truncate table bolinf.XX_OPM_SUB_LEGDER_GRAL_GT';
 -- Q1 xx_gmf_xla_extract_headers (en tabla de memoria)
 insert into bolinf.XX_OPM_SUB_LEGDER_GRAL_GT
 SELECT DISTINCT
         gld.ledger_name,
         gld.legal_entity_name,
         gxh.operating_unit,
         xah.accounting_entry_status_code modo,
         xat.event_class_group_code,
         xec.NAME event_class,
         xet.NAME event_type,
         xec.event_class_code,
         xah.ae_header_id,
         xet.entity_code,
         xev.event_number,
         xev.event_date,
         xah.accounting_date,
         gxh.transaction_id,
         gxh.clase_costo,
         gxh.clase_costo_descr,
         gxh.clase_gl,
         gxh.clase_gl_descr,
         gxh.clase_prod,
         gxh.clase_prod_descr,
         gxh.cat product_line,
         gxh.resources,
         gxh.item_code item_code,
         gxh.item_description,
         gxh.transaction_date,
         gxh.order_number,
         gxh.carta_porte,
         (SELECT liq.numero_liquidacion
                     FROM xx_tcg_liquidaciones liq
                     WHERE liq.liquidacion_id = gxh.liquidacion_id
                     AND gxh.transaction_type_id IN (181, 182)
                     ) numero_liquidacion,
         (SELECT hp.party_name
                     FROM xx_tcg_liquidaciones liq
                     , hz_parties hp
                     WHERE 1=1
                     AND hp.party_id = liq.empresa_origen_party_id
                     AND liq.liquidacion_id = gxh.liquidacion_id
                     AND gxh.transaction_type_id IN (181, 182)
                     ) productor_liquidacion,
         usr.user_name usuario_trx,
         gxh.transaction_type_id,
         gxh.transaction_type_name,
         gxh.organization_code,
         gxh.organization_name,
         gxh.subinventory_code,
         gxh.subinventory_desc,
         gxh.reason_name,
         gxh.reason_description,
         (SELECT user_je_category_name
                     FROM gl_je_categories
                     WHERE je_category_name = xah.je_category_name
                     AND LANGUAGE = USERENV ('LANG')) je_category_name,
         xal.ae_line_num,
         xal.accounting_class_code,
         (SELECT meaning
                     FROM xla_lookups
                     WHERE lookup_type = 'XLA_ACCOUNTING_CLASS'
                     AND lookup_code = xal.accounting_class_code) accounting_class_meaning,
         gxh.lote,
         gxh.owning_supplier,
         case when xal.AE_LINE_NUM = 2 AND xec.event_class_code = 'SUBINV_XFER'  THEN
                 gxh.transaction_quantity * (-1)
                 ELSE
                 gxh.transaction_quantity
                 END transaction_quantity,
         case when gxh.event_class_code = 'BATCH_RESOURCE'  then gxh.resource_uom
                 else gxh.primary_uom_code
                 end primary_uom_code,
         gcc.code_combination_id,
         gxh.journal_line_type titulo_cuenta,
         gcc.concatenated_segments,
         CASE  WHEN gcc.concatenated_segments IS NOT NULL  THEN
                 gl_flexfields_pkg. get_concat_description ( gcc.chart_of_accounts_id, gcc.code_combination_id)
                 END descr_cuenta,
         xal.currency_code,
         xal.entered_dr,
         xal.entered_cr,
         xal.accounted_dr,
         xal.accounted_cr,
         xah.gl_transfer_date,
         xev.event_id,
         (SELECT DISTINCT substr(TRANSLATE (TRANSLATE (TRANSLATE (message_number || '-' || encoded_msg, CHR (10) || CHR (13), '  '), CHR (10), ' '), CHR (13), ' ') , 1, 255) err
                     FROM xla_accounting_errors xae
                     WHERE   xae.event_id = xev.EVENT_ID
                     AND (NVL(xae.ae_line_num,-1) = xal.ae_line_num
                               OR (xae.ae_line_num IS NULL and xev.process_status_code in ('E','I','R'))
                            )
                     AND ROWNUM = 1)  error_description, -- CR2430  Si line_num es null , se verifica el status
         gxh.po_number,
         gxh.project_id,
         gxh.task_id,
         gxh.project_number,
         gxh.project_name,
         gxh.task_number,
         gxh.task_name,
         gxh.pa_expenditure_org_id,
         gxh.pa_expenditure_org,
         gxh.expenditure_type,
         gxh.wip_entity_name
 FROM gl_ledger_le_bsv_specific_v gld,
         xla_event_classes_vl xec,
         xla_event_class_attrs xat,
         xla_event_types_vl xet,
         xla_events xev,
         xla_ae_headers xah,
         xla_ae_lines xal,
         gl_code_combinations_kfv gcc,
         fnd_user usr,
         ( SELECT gxh.event_id,
             dl.ae_header_id,
             dl.ae_line_num,
             gxl.journal_line_type,
             gxh.operating_unit,
             CASE              WHEN gxh.entity_code = 'REVALUATION'             AND gxh.event_type_code = 'COSTREVAL'             THEN
                                     (SELECT created_by
                                     FROM gmf_period_balances
                                     WHERE period_balance_id =
                                     gxh.transaction_id)
                             WHEN gxh.entity_code = 'REVALUATION'             AND gxh.event_type_code = 'ACTCOSTADJ'             THEN
                                                         (SELECT created_by
                                                         FROM cm_adjs_dtl
                                                         WHERE cost_adjust_id =
                                                         gxh.transaction_id)
                             WHEN gxh.entity_code = 'REVALUATION'             AND gxh.event_type_code = 'LOTCOSTADJ'             THEN
                                                         (SELECT created_by
                                                         FROM gmf_lot_cost_adjustment_dtls
                                                         WHERE adjustment_id =
                                                         gxh.transaction_id)
                             WHEN gxh.entity_code = 'REVALUATION'             AND gxh.event_type_code = 'GLCOSTALOC'             THEN
                                                         (SELECT created_by
                                                         FROM gl_aloc_dtl
                                                         WHERE allocdtl_id = gxh.transaction_id)
                             WHEN gxh.entity_code = 'PURCHASING'             AND gxh.event_class_code = 'RECEIVE'             THEN
                                                         (SELECT created_by
                                                         FROM gmf_rcv_accounting_txns
                                                         WHERE accounting_txn_id =
                                                         gxh.transaction_id)
                             ELSE
                                                             (SELECT created_by
                                                             FROM mtl_material_transactions
                                                             WHERE transaction_id =
                                                             gxh.transaction_id)
                             END
                             trx_created_by,
             CASE       WHEN mtt.transaction_type_id IN (18, 36)                    OR (gxh.entity_code = 'PURCHASING'                             AND gxh.event_class_code =  'RECEIVE')                             THEN
                             (SELECT gxrt1.purchase_number po_number
                             FROM gmf_xla_rcv_txns_v gxrt1
                             WHERE gxrt1.transaction_id =
                             gxh.transaction_id)
                             ELSE
                             NULL
                             END
                             po_number,
             p.organization_id,
             p.organization_code,
             o.organization_name,
             msiq.inventory_item_id,
             msiq.item_code,
             gxh.resources,
             gxh.event_class_code,
             msiq.item_description,
             msiq.clase_costo,
             msiq.clase_costo_descr,
             msiq.clase_gl,
             msiq.clase_gl_descr,
             msiq.clase_prod,
             msiq.clase_prod_descr,
             msiq.cat,
             gxh.transaction_id,
             gxh.transaction_date,
             NVL (mmt.subinventory_code, gxl.subinventory_code) subinventory_code,
             mtt.transaction_type_id,
             mtt.transaction_type_name,
             mtst.transaction_source_type_name,
             mtr.reason_name,
             mtr.description reason_description,
             gxh.transaction_quantity,
             msiq.primary_uom_code primary_uom_code,
             gxh.transaction_uom resource_uom,
             gxh.lot_number gxh_lot,
             CASE              WHEN msiq.lot_control_code > 1              THEN
             NVL (gxh.lot_number,  (SELECT CASE   WHEN NVL (MAX (lot_number),0) = NVL (MIN (lot_number),0)
                                                             THEN
                                                             MIN (lot_number)
                                                             ELSE
                                                             'Varios Lotes'
                                                             END
                                                         FROM mtl_transaction_lot_numbers
                                                         WHERE transaction_id =
                                                         mmt.transaction_id))
                      END             lote,
                       xx_opm_sub_ledger_pkg.get_owning_supplier(p_process_enabled_flag  => p.process_enabled_flag
                                           , p_eam_enabled_flag => p.eam_enabled_flag
                                            , p_owning_tp_type => mmt.owning_tp_type
                                            , p_owning_organization_id =>  mmt.owning_organization_id
                                            , p_transaction_type_name => mtt.transaction_type_name
                                            , p_transfer_transaction_id =>  mmt.transfer_transaction_id
                                            , p_transaction_set_id => mmt.transaction_set_id
                                            , p_transaction_batch_id => mmt.transaction_batch_id)       owning_supplier,
             -- Fin adm CR2243 - CH1751
             CASE              WHEN mmt.transaction_source_type_id IN              (2, 8, 12, 13)             THEN
                                         (SELECT mso.segment1
                                         FROM mtl_sales_orders mso
                                         WHERE mso.sales_order_id =
                                         mmt.transaction_source_id)
                      END              order_number,
             CASE              WHEN mmt.transaction_source_type_id IN             (2, 8, 12, 13)             THEN
                                 (SELECT ool_dfv.xx_om_carta_porte
                                 FROM oe_order_lines_all ool,
                                 oe_order_lines_all_dfv ool_dfv
                                 WHERE ool.ROWID = ool_dfv.row_id
                                 AND ool.line_id =
                                 mmt.trx_source_line_id)
                     END             carta_porte,
             msei.description subinventory_desc,
             DECODE (mtt.type_class, 1, 'Si', 'No')
             proyecto,
             mmt.source_project_id project_id,
             mmt.source_task_id task_id,
             pjm_project.all_proj_idtonum (mmt.source_project_id)              project_number,
             pjm_project.all_proj_idtoname (mmt.source_project_id)             project_name,
             pjm_project.all_task_idtonum (mmt.source_task_id)                   task_number,
             pjm_project.all_task_idtoname (mmt.source_task_id)                  task_name,
             mmt.pa_expenditure_org_id,
             (SELECT organization_name
                                     FROM org_organization_definitions ood
                                     WHERE organization_id =
                                     mmt.pa_expenditure_org_id)
                                     pa_expenditure_org,
             mmt.expenditure_type,
             CASE             WHEN mtt.transaction_type_name LIKE 'WIP%' THEN
                             (SELECT we.wip_entity_name
                             FROM wip_entities we
                             WHERE we.wip_entity_id =
                             mmt.transaction_source_id
                             )
                             else
                             (SELECT we.wip_entity_name
                             FROM wip_entities we
                             WHERE we.wip_entity_id =
                             gxh.source_document_id
                             )
                             END
             wip_entity_name,
             mmt.attribute2 liquidacion_id
             FROM xx_gmf_xla_extract_headers gxh,
                     gmf_xla_extract_lines gxl,
                     xla_distribution_links dl,
                     xx_msi_cat msiq,
                     mtl_parameters p,
                     org_organization_definitions o,
                     mtl_material_transactions mmt,
                     mtl_transaction_reasons mtr,
                     mtl_transaction_types mtt,
                     mtl_txn_source_types mtst,
                     mtl_secondary_inventories msei
             WHERE 1=1
             AND gxh.header_id = gxl.header_id
             AND dl.event_id = gxh.event_id
             AND dl.application_id = P_APPLICATION_ID
             AND dl.source_distribution_type = gxh.entity_code
             AND dl.source_distribution_id_num_1 = gxl.line_id
             AND gxh.organization_id = msei.organization_id(+)
             AND gxl.subinventory_code = msei.secondary_inventory_name(+)
             and (nvl(gxl.subinventory_code, '-99') = nvl(nvl(mmt.subinventory_code, gxl.subinventory_code), '-99')
                           or        (gxh.event_class_code  in ('SUBINV_XFER','FOB_SHIP_RECIPIENT_SHIP') and  gxl.xfer_subinventory_code = mmt.subinventory_code))    -- T#16099  CR2430 agregado para que tome tambiÃ©n las de distinta configuracions 
             AND gxh.inventory_item_id = msiq.inventory_item_id (+)
             AND gxh.organization_id = msiq.organization_id (+)
             AND gxh.organization_id = p.organization_id
             AND p.organization_id = o.organization_id
             AND gxh.reason_id = mtr.reason_id(+)
             AND gxh.transaction_id = mmt.transaction_id(+)
             AND gxh.transaction_type_id = mtt.transaction_type_id(+)
             AND gxh.transaction_source_type_id = mtst.transaction_source_type_id(+)
             GROUP BY gxh.event_id,
                         dl.ae_header_id,
                         dl.ae_line_num,
                         gxl.subinventory_code,
                         mtt.type_class,
                         mmt.organization_id,
                         gxh.entity_code,
                         gxh.event_type_code,
                         gxh.event_class_code,gxh.resources,
                         gxh.operating_unit,
                         gxl.journal_line_type,
                         mtt.transaction_type_id,gxh.source_document_id,
                         p.organization_id,
                         p.organization_code,
                         p.process_enabled_flag,
                         p.eam_enabled_flag,
                         o.organization_name,
                         msiq.inventory_item_id,
                         msiq.item_code,
                         msiq.item_description,
                         msiq.clase_costo,
                         msiq.clase_costo_descr,
                         msiq.cat,
                         msiq.clase_gl,
                         msiq.clase_gl_descr,
                         msiq.clase_prod,
                         msiq.clase_prod_descr,
                         gxh.transaction_id,
                         gxh.transaction_date,
                         mmt.subinventory_code,
                         mtt.transaction_type_id,
                         mtt.transaction_type_name,
                         mtst.transaction_source_type_name,
                         mtr.reason_name,
                         mtr.description,
                         gxh.transaction_quantity,
                         msiq.primary_uom_code,
                         gxh.transaction_uom,
                         gxh.lot_number,
                         msiq.lot_control_code,
                         mmt.transaction_source_type_id,
                         msei.description,
                         mmt.transaction_id,
                         mmt.transaction_source_id,
                         mmt.trx_source_line_id,
                         mmt.source_project_id,
                         mmt.source_task_id,
                         pjm_project.all_proj_idtonum (mmt.source_project_id),
                         pjm_project.all_proj_idtoname (mmt.source_project_id),
                         pjm_project.all_task_idtonum (mmt.source_task_id),
                         pjm_project.all_task_idtoname (mmt.source_task_id),
                         mmt.pa_expenditure_org_id,
                         mmt.expenditure_type,
                         mmt.attribute2,
                         mmt.owning_tp_type,
                         mmt.owning_organization_id,
                         mmt.transaction_set_id,
                         mmt.transaction_batch_id,
                         mmt.transfer_transaction_id
         ) gxh
 WHERE 1 = 1
     AND xah.application_id = P_APPLICATION_ID
     AND xal.application_id = P_APPLICATION_ID
     AND xet.application_id = P_APPLICATION_ID
     AND xah.ledger_id = gld.ledger_id
     AND xah.event_type_code = xet.event_type_code
     AND xet.application_id = xec.application_id
     AND xet.entity_code = xec.entity_code
     AND xet.event_class_code = xec.event_class_code
     AND xat.application_id = xec.application_id
     AND xat.entity_code = xec.entity_code
     AND xat.event_class_code = xec.event_class_code
     AND xev.event_id = xah.event_id
     AND xev.event_status_code <> 'N'
     AND xal.code_combination_id =     gcc.code_combination_id(+)
     AND xah.ae_header_id = xal.ae_header_id
     --AND XEV.event_id = GXH.event_id
     AND xah.ae_header_id = gxh.ae_header_id
     --TK968 AND xal.ae_line_num = gxh.ae_line_num
     AND ( gxh.transaction_type_id IN (52, 145, 146, 185) OR
     ( NVL(gxh.transaction_type_id,-1) NOT IN (52, 145, 146, 185) AND
     xal.ae_line_num = gxh.ae_line_num
     )
     )
     AND gxh.trx_created_by = usr.user_id(+)
     AND gxh.operating_unit = P_ORG_ID
     AND (gxh.transaction_type_id = P_TRANSACTION_TYPE_ID OR      P_TRANSACTION_TYPE_ID IS NULL)
     AND (xat.event_class_group_code = P_EVENT_CLASS_GROUP_CODE OR      P_EVENT_CLASS_GROUP_CODE IS NULL)
     AND (P_SOLO_ERRORES = 'N' OR 
             P_SOLO_ERRORES = 'Y' AND      EXISTS (SELECT 'X'     FROM xla_accounting_errors xae     WHERE xae.event_id = xev.event_id     AND (xae.ae_line_num = xal.ae_line_num OR     xae.ae_line_num IS NULL  ) )
             )
   ;
    -- Q2 xx_rcv_transactions
    insert into bolinf.XX_OPM_SUB_LEGDER_GRAL_GT
 SELECT gld.ledger_name,
             gld.legal_entity_name,
             ood.operating_unit,
             xah.accounting_entry_status_code modo,
             xat.event_class_group_code,
             xec.NAME event_class,
             xet.NAME event_type,
             xec.event_class_code,
             xah.ae_header_id,
             xet.entity_code,
             xev.event_number,
             xev.event_date,
             xah.accounting_date,
             rt.transaction_id,
             msiq.clase_costo,
             msiq.clase_costo_descr,
             msiq.clase_gl,
             msiq.clase_gl_descr,
             msiq.clase_prod,
             msiq.clase_prod_descr,
             msiq.cat product_line,
             null resources,
             msiq.item_code item_code ,
             msiq.item_description,
             rt.transaction_date,
             NULL order_number,
             NULL carta_porte,
             NULL numero_liquidacion,
             NULL productor_liquidacion,
             usr.user_name usuario_trx,
             NULL transaction_type_id,
             rt.transaction_type transaction_type_name,
             ood.organization_code,
             ood.organization_name,
              nvl(rt.subinventory, rt_inv.subinventory) subinventory_code, -- CR2430 Se incorporo rt_inv para llegar a subinventario
             ( select msei.description  from                           mtl_secondary_inventories msei
                where nvl(rt.subinventory,rt_inv.subinventory) = msei.secondary_inventory_name
                             AND rt.organization_id = msei.organization_id)   subinventory_desc,  -- CR2430 Se incorporo rt_inv para llegar a subinventario,
             mtr.reason_name,
             mtr.description reason_description,
             (SELECT user_je_category_name
             FROM gl_je_categories
             WHERE je_category_name = xah.je_category_name
             AND LANGUAGE = USERENV ('LANG')) je_category_name,
             xal.ae_line_num,
             xal.accounting_class_code,
             (SELECT meaning            FROM xla_lookups             WHERE lookup_type = 'XLA_ACCOUNTING_CLASS'             AND lookup_code = xal.accounting_class_code) accounting_class_meaning,
             NULL lote,
             DECODE( mp.process_enabled_flag,'Y',DECODE( mp.eam_enabled_flag,'N',
                     CASE
                      WHEN msiq.organization_id IS NOT NULL
                      THEN (SELECT x.vendor_name
                                || '-'
                                || z.vendor_site_code
                              FROM po_vendor_sites_all z
                                 , po_vendors x
                             WHERE x.vendor_id = z.vendor_id
                               AND z.vendor_site_id = msiq.organization_id)
                      ELSE
                        NULL
                     END
                    ,null),null) owning_supplier, -- adm CR2243 - CH1751
             case when xal.AE_LINE_NUM = 2 AND xec.event_class_code = 'SUBINV_XFER'              THEN
                         rt.quantity * (-1)
                         ELSE
                         rt.quantity
                         END transaction_quantity,
             case when xec.event_class_code = 'BATCH_RESOURCE'
                     then null
                     else msik.PRIMARY_UOM_CODE
                     end primary_uom_code,
             gcc.code_combination_id,
             NULL titulo_cuenta,
             gcc.concatenated_segments,
             CASE             WHEN gcc.concatenated_segments IS NOT NULL              THEN
                     GL_FLEXFIELDS_PKG.GET_CONCAT_DESCRIPTION (  GCC.CHART_OF_ACCOUNTS_ID,   GCC.CODE_COMBINATION_ID)
                     END             descr_cuenta,
             xal.currency_code,
             xal.entered_dr,
             xal.entered_cr,
             xal.accounted_dr,
             xal.accounted_cr,
             xah.gl_transfer_date,
             xev.event_id,
              (SELECT DISTINCT substr(TRANSLATE (TRANSLATE (TRANSLATE (message_number || '-' || encoded_msg, CHR (10) || CHR (13), '  '), CHR (10), ' '), CHR (13), ' ') , 1, 255) err
                             FROM xla_accounting_errors xae
                             WHERE   xae.event_id = xev.EVENT_ID
                             AND (NVL(xae.ae_line_num,-1) = xal.ae_line_num
                                       OR (xae.ae_line_num IS NULL and xev.process_status_code in ('E','I','R'))
                                    )
                             AND ROWNUM = 1)  error_description, -- CR2430  Si line_num es null , se verifica el status
             poh.segment1 po_number,
             rt.PROJECT_ID PROJECT_ID,
             rt.TASK_ID task_id,
             pjm_project.all_proj_idtonum (rt.PROJECT_ID)             project_number,
             pjm_project.all_proj_idtoname (rt.PROJECT_ID)             project_name,
             pjm_project.all_task_idtonum (rt.TASK_ID) task_number,
             pjm_project.all_task_idtoname (rt.TASK_ID) task_name,
             NULL pa_expenditure_org_id,
             NULL pa_expenditure_org,
             NULL expenditure_type,
             CASE WHEN rt.transaction_type LIKE 'WIP%'               THEN
                         (SELECT we.wip_entity_name                         FROM wip_entities we
                         WHERE we.wip_entity_id = rt.wip_entity_id                         )
                         END             wip_entity_name
 FROM gl_ledger_le_bsv_specific_v gld,
             xla_event_classes_vl xec,
             xla_event_class_attrs xat,
             xla_event_types_vl xet,
             xla_events xev,
             xla_ae_headers xah,
             xla_ae_lines xal,
             xla_distribution_links xdl,
             gl_code_combinations_kfv gcc,
             xx_rcv_transactions rt,
             rcv_transactions rt_inv,  -- CR2430 Se incorporo rt_inv para llegar a subinventario
             rcv_shipment_headers rsh,
             rcv_shipment_lines rsl,
             mtl_transaction_reasons mtr,
             org_organization_definitions ood,
             po_vendors pov,
             po_headers_all poh,
             po_lines_all pol,
             po_line_locations_all poll,
             po_distributions_all pod,
             mtl_system_items_kfv msik,
             rcv_receiving_sub_ledger rae,
             mtl_parameters mp,
             fnd_user usr,
             xx_msi_cat msiq
 WHERE 1=1
             AND xah.application_id = P_APPLICATION_ID
             AND xal.application_id = P_APPLICATION_ID
             AND xet.application_id = P_APPLICATION_ID
             AND xah.ledger_id = gld.ledger_id
             AND xah.event_type_code = xet.event_type_code
             AND xet.application_id = xec.application_id
             AND xet.entity_code = xec.entity_code
             AND xet.event_class_code = xec.event_class_code
             AND xat.application_id = xec.application_id
             AND xat.entity_code = xec.entity_code
             AND xat.event_class_code = xec.event_class_code
             AND xev.event_id = xah.event_id
             AND xev.event_status_code <> 'N'
             AND xal.code_combination_id = gcc.code_combination_id(+)
             AND xah.ae_header_id = xal.ae_header_id
             AND rt.po_header_id = poh.po_header_id
             AND rsl.created_by = usr.user_id(+)
             AND xah.event_id = xdl.event_id
             AND xal.ae_header_id = xdl.ae_header_id
             AND xal.ae_line_num = xdl.ae_line_num
            -- CR2430 Se incorporo rt_inv para llegar a subinventario
             AND rt_inv.parent_transaction_id(+) = rt.transaction_id 
             AND rt_inv.DESTINATION_TYPE_CODE(+) = 'INVENTORY'                          
             -- evita full access al distrib
             AND xdl.event_id = xah.event_id
             AND xdl.application_id = P_APPLICATION_ID
             AND xdl.source_distribution_id_num_1 = rae.rcv_sub_ledger_id
             AND xdl.SOURCE_DISTRIBUTION_TYPE = 'RCV_RECEIVING_SUB_LEDGER'
             -- evita full access al distrib
             AND rt.po_line_id = pol.po_line_id
             AND rt.po_line_location_id = poll.line_location_id
             AND rt.po_distribution_id = pod.po_distribution_id
             AND poh.vendor_id = pov.vendor_id
             AND rt.shipment_header_id = rsh.shipment_header_id(+)
             AND rt.shipment_line_id = rsl.shipment_line_id(+)
             AND rae.rcv_transaction_id = rt.transaction_id(+)
             AND msik.organization_id(+) = rt.organization_id
             AND msik.inventory_item_id(+) = rsl.item_id
             AND mp.organization_id = rt.organization_id
             AND rsl.item_id = msiq.inventory_item_id(+)
             AND mp.organization_id = msiq.organization_id(+)
             AND rt.reason_id = mtr.reason_id(+)
             AND rt.organization_id = ood.organization_id
             AND gld.legal_entity_id = ood.legal_entity
             AND ood.operating_unit = P_ORG_ID
             AND (xat.event_class_group_code = P_EVENT_CLASS_GROUP_CODE OR             P_EVENT_CLASS_GROUP_CODE IS NULL)
             AND (P_SOLO_ERRORES = 'N' OR
                    P_SOLO_ERRORES = 'Y' AND     EXISTS (SELECT 'X'   FROM xla_accounting_errors xae   WHERE xae.event_id = xev.event_id  AND (xae.ae_line_num = xal.ae_line_num OR  xae.ae_line_num IS NULL  ) )
                    )
 ;
   -- Q3 xx_wip_transactions

  insert into bolinf.XX_OPM_SUB_LEGDER_GRAL_GT
 SELECT gld.ledger_name,
             gld.legal_entity_name,
             ood.operating_unit,
             xah.accounting_entry_status_code modo,
             xat.event_class_group_code,
             xec.NAME event_class,
             xet.NAME event_type,
             xec.event_class_code,
             xah.ae_header_id,
             xet.entity_code,
             xev.event_number,
             xev.event_date,
             xah.accounting_date,
             wt.transaction_id,
             msiq.clase_costo,
             msiq.clase_costo_descr,
             msiq.clase_gl,
             msiq.clase_gl_descr,
             msiq.clase_prod,
             msiq.clase_prod_descr,
             msiq.cat product_line,
             null resources,
             msik_wt.concatenated_segments item_code ,
             msik_wt.description item_description,
             wt.transaction_date,
             NULL order_number,
             NULL carta_porte,
             NULL numero_liquidacion,
             NULL productor_liquidacion,
             usr.user_name usuario_trx,
             wt.transaction_type transaction_type_id,
             ml1.meaning transaction_type_name,
             ood.organization_code,
             ood.organization_name,
             NULL subinventory_code,
             NULL subinventory_desc,
             mtr.reason_name,
             mtr.description reason_description,
             (SELECT user_je_category_name              FROM gl_je_categories             WHERE je_category_name = xah.je_category_name             AND LANGUAGE = USERENV ('LANG'))             je_category_name,
             xal.ae_line_num,
             xal.accounting_class_code,
             (SELECT meaning              FROM xla_lookups             WHERE lookup_type = 'XLA_ACCOUNTING_CLASS'             AND lookup_code = xal.accounting_class_code)             accounting_class_meaning,
             NULL lote,
             DECODE( mp.process_enabled_flag,'Y',DECODE( mp.eam_enabled_flag,'N',
                 CASE                   WHEN msiq.organization_id IS NOT NULL
                  THEN (SELECT x.vendor_name
                            || '-'
                            || z.vendor_site_code
                          FROM po_vendor_sites_all z
                             , po_vendors x
                         WHERE x.vendor_id = z.vendor_id
                           AND z.vendor_site_id = msiq.organization_id)
                  ELSE
                    NULL
                 END
                         ,null),null) owning_supplier, -- adm CR2243 - CH1751
             case when xal.AE_LINE_NUM = 2 AND xec.event_class_code = 'SUBINV_XFER'             THEN
                         wt.transaction_quantity * (-1)
                         ELSE
                         wt.transaction_quantity
                         END transaction_quantity,
             case when xec.event_class_code = 'BATCH_RESOURCE'
                         then null
                         else wt.transaction_uom
                         end primary_uom_code ,
             gcc.code_combination_id,
             NULL titulo_cuenta,
             gcc.concatenated_segments,
             CASE   WHEN gcc.concatenated_segments IS NOT NULL
                         THEN
                         GL_FLEXFIELDS_PKG.
                         GET_CONCAT_DESCRIPTION (
                         GCC.CHART_OF_ACCOUNTS_ID,
                         GCC.CODE_COMBINATION_ID)
                         END
             descr_cuenta,
             xal.currency_code,
             xal.entered_dr,
             xal.entered_cr,
             xal.accounted_dr,
             xal.accounted_cr,
             xah.gl_transfer_date,
             xev.event_id,
              (SELECT DISTINCT substr(TRANSLATE (TRANSLATE (TRANSLATE (message_number || '-' || encoded_msg, CHR (10) || CHR (13), '  '), CHR (10), ' '), CHR (13), ' ') , 1, 255) err
                                 FROM xla_accounting_errors xae
                                 WHERE   xae.event_id = xev.EVENT_ID
                                 AND (NVL(xae.ae_line_num,-1) = xal.ae_line_num
                                           OR (xae.ae_line_num IS NULL and xev.process_status_code in ('E','I','R'))
                                        )
                                 AND ROWNUM = 1)  error_description, -- CR2430  Si line_num es null , se verifica el status
             poh.segment1 po_number,
             wt.PROJECT_ID PROJECT_ID,
             wt.TASK_ID task_id,
             pjm_project.all_proj_idtonum (wt.PROJECT_ID)             project_number,
             pjm_project.all_proj_idtoname (wt.PROJECT_ID)             project_name,
             pjm_project.all_task_idtonum (wt.TASK_ID) task_number,
             pjm_project.all_task_idtoname (wt.TASK_ID) task_name,
             bd.PA_EXPENDITURE_ORG_ID,
             (SELECT organization_name             FROM org_organization_definitions ood             WHERE organization_id = bd.PA_EXPENDITURE_ORG_ID)             pa_expenditure_org,
             NULL expenditure_type,
             we.wip_entity_name
 FROM xla.xla_distribution_links xdl,
         xx_wip_transactions wt,
         wip_transaction_accounts wta,
         wip_entities we
         , xla_ae_headers xah
         , xla_ae_lines xal
         , xla.xla_events xev
         , xla_event_classes_vl xec
         , xla_event_class_attrs xat
         , xla_event_types_vl xet
         --
         , gl_code_combinations_kfv gcc
         , gl_ledger_le_bsv_specific_v gld
         --
         , bom_resources br
         , bom_departments bd
         --
         , mtl_system_items_kfv msik_wt
         , mtl_system_items_kfv msik_we
         , mtl_parameters mp
         --
         , mtl_transaction_reasons mtr
         --, mfg_lookups lu
         , fnd_user usr
         , org_organization_definitions ood
         , po_headers_all poh
         , mfg_lookups ml1
         , xx_msi_cat msiq
 WHERE 1 = 1
         AND wt.transaction_id = wta.transaction_id
         AND wt.wip_entity_id = we.wip_entity_id
         AND xdl.application_id = P_APPLICATION_ID
         AND xdl.source_distribution_id_num_1 = wta.wip_sub_ledger_id
         AND xdl.source_distribution_type = 'WIP_TRANSACTION_ACCOUNTS'
         AND xal.ae_header_id = xdl.ae_header_id
         AND xal.ae_line_num = xdl.ae_line_num
         AND xah.ae_header_id = xdl.ae_header_id
         AND xah.application_id = xdl.application_id
         AND xev.event_id = xdl.event_id
         AND xev.application_id =xdl.application_id
         --
         AND xec.application_id = xdl.application_id
         AND xec.event_class_code =xdl.event_class_code
         --
         AND xat.application_id = xec.application_id
         AND xat.entity_code = xec.entity_code
         AND xat.event_class_code = xec.event_class_code
         --
         AND xet.application_id = xec.application_id
         AND xet.entity_code = xec.entity_code
         AND xet.event_class_code = xec.event_class_code
         --
         AND xal.code_combination_id = gcc.code_combination_id(+)
         AND xal.ledger_id = gld.ledger_id
         --
         AND wta.resource_id = br.resource_id(+)
         AND wt.organization_id = NVL (br.organization_id, wt.organization_id)
         AND wt.department_id = bd.department_id(+)
         AND wt.organization_id = NVL (bd.organization_id, wt.organization_id)
         --
         AND wt.organization_id = mp.organization_id
         AND wt.primary_item_id = msik_wt.inventory_item_id(+)
         AND wt.organization_id = msik_wt.organization_id(+)
         AND we.primary_item_id = msik_we.inventory_item_id(+)
         AND we.organization_id = msik_we.organization_id(+)
         --
         AND wt.reason_id = mtr.reason_id(+)
         AND wta.created_by = usr.user_id(+)
         --
         AND wt.organization_id = ood.organization_id
         AND wt.po_header_id = poh.po_header_id(+)
         --
         AND ml1.lookup_type = 'WIP_TRANSACTION_TYPE'
         AND ml1.lookup_code = wt.transaction_type
         --
         AND wt.primary_item_id = msiq.inventory_item_id (+)
         AND wt.organization_id = msiq.organization_id (+)
         AND ood.operating_unit = P_ORG_ID
         AND (xat.event_class_group_code = P_EVENT_CLASS_GROUP_CODE OR
                                P_EVENT_CLASS_GROUP_CODE IS NULL)
         AND (P_SOLO_ERRORES = 'N' OR 
                 P_SOLO_ERRORES = 'Y' AND
                         EXISTS (SELECT 'X'  FROM xla_accounting_errors xae WHERE xae.event_id = xev.event_id AND (xae.ae_line_num = xal.ae_line_num OR xae.ae_line_num IS NULL ))
                )
 ;
  -- Q4 xx_mtl_material_transactions para  source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
  insert into bolinf.XX_OPM_SUB_LEGDER_GRAL_GT
 SELECT gld.ledger_name,
                     gld.legal_entity_name,
                     ood.operating_unit,
                     xah.accounting_entry_status_code modo,
                     xat.event_class_group_code,
                     xec.NAME event_class,
                     xet.NAME event_type,
                     xec.event_class_code,
                     xah.ae_header_id,
                     ---- xev.event_id -- Ids para prueba
                     -- -- ,GXH.organization_id, GXH.inventory_item_id
                     --
                     -- ,
                     xet.entity_code,
                     xev.event_number,
                     xev.event_date,
                     xah.accounting_date,
                     mmt.transaction_id,
                     msiq.clase_costo,
                     msiq.clase_costo_descr,
                     msiq.clase_gl,
                     msiq.clase_gl_descr,
                     msiq.clase_prod,
                     msiq.clase_prod_descr,
                     msiq.cat product_line,
                     null resources,
                     msik_mmt.concatenated_segments item_code ,
                     msik_mmt.description item_description,
                     mmt.transaction_date,
                     NULL order_number,
                     NULL carta_porte,
                     NULL numero_liquidacion,
                     NULL productor_liquidacion,
                     usr.user_name usuario_trx,
                     mmt.transaction_type_id transaction_type_id,
                     mtt.transaction_type_name,
                     ood.organization_code,
                     ood.organization_name,
                     mmt.subinventory_code  subinventory_code, --cr2430 -- Se incorporÃ³ el subinventario
                     msei.description subinventory_desc, --cr2430 -- Se incorporÃ³ el subinventario
                     mtr.reason_name,
                     mtr.description reason_description,
                     (SELECT user_je_category_name
                     FROM gl_je_categories
                     WHERE je_category_name = xah.je_category_name
                     AND LANGUAGE = USERENV ('LANG'))
                     je_category_name,
                     xal.ae_line_num,
                     xal.accounting_class_code,
                     (SELECT meaning
                     FROM xla_lookups
                     WHERE lookup_type = 'XLA_ACCOUNTING_CLASS'
                     AND lookup_code = xal.accounting_class_code)
                     accounting_class_meaning,
                     NULL lote,
                     xx_opm_sub_ledger_pkg.get_owning_supplier(p_process_enabled_flag  => mp.process_enabled_flag
                                                                                       , p_eam_enabled_flag => mp.eam_enabled_flag
                                                                                       , p_owning_tp_type => mmt.owning_tp_type
                                                                                       , p_owning_organization_id =>  mmt.owning_organization_id
                                                                                       , p_transaction_type_name => mtt.transaction_type_name
                                                                                       , p_transfer_transaction_id =>  mmt.transfer_transaction_id
                                                                                       , p_transaction_set_id => mmt.transaction_set_id
                                                                                       , p_transaction_batch_id => mmt.transaction_batch_id) owning_supplier,
                     -- Fin adm CR2243 - CH1751
                     case when xal.AE_LINE_NUM = 2 AND xec.event_class_code = 'SUBINV_XFER'
                                 THEN
                                 mmt.transaction_quantity * (-1)
                                 ELSE
                                 mmt.transaction_quantity
                                 END transaction_quantity,
                     -- mmt.transaction_quantity transaction_quantity,
                     case when xec.event_class_code = 'BATCH_RESOURCE'
                                     then null
                                     else mmt.transaction_uom
                                     end primary_uom_code,
                     gcc.code_combination_id,
                     NULL titulo_cuenta,
                     gcc.concatenated_segments,
                     CASE                      WHEN gcc.concatenated_segments IS NOT NULL                      THEN
                             GL_FLEXFIELDS_PKG.GET_CONCAT_DESCRIPTION ( GCC.CHART_OF_ACCOUNTS_ID, GCC.CODE_COMBINATION_ID)
                             END                     descr_cuenta,
                     xal.currency_code,
                     xal.entered_dr,
                     xal.entered_cr,
                     xal.accounted_dr,
                     xal.accounted_cr,
                     xah.gl_transfer_date,
                     xev.event_id,
                     (SELECT DISTINCT substr(TRANSLATE (TRANSLATE (TRANSLATE (message_number || '-' || encoded_msg, CHR (10) || CHR (13), '  '), CHR (10), ' '), CHR (13), ' ') , 1, 255) err
                                         FROM xla_accounting_errors xae
                                         WHERE   xae.event_id = xev.EVENT_ID
                                         AND (NVL(xae.ae_line_num,-1) = xal.ae_line_num
                                                   OR (xae.ae_line_num IS NULL and xev.process_status_code in ('E','I','R'))
                                                )
                                         AND ROWNUM = 1)  error_description, -- CR2430  Si line_num es null , se verifica el status
                     NULL po_number,
                     mmt.SOURCE_PROJECT_ID PROJECT_ID,
                     mmt.source_task_id task_id,
                     pjm_project.all_proj_idtonum (mmt.SOURCE_PROJECT_ID)                     project_number,
                     pjm_project.all_proj_idtoname (mmt.SOURCE_PROJECT_ID)                     project_name,
                     pjm_project.all_task_idtonum (mmt.source_task_id)                     task_number,
                     pjm_project.all_task_idtoname (mmt.source_task_id)                     task_name,
                     mmt.pa_expenditure_org_id,
                     (SELECT organization_name            FROM org_organization_definitions ood                     WHERE organization_id = mmt.pa_expenditure_org_id)                     pa_expenditure_org,
                     mmt.expenditure_type,
                     CASE                      WHEN mtt.transaction_type_name LIKE 'WIP%'
                                 THEN
                                 (SELECT we.wip_entity_name
                                 FROM wip_entities we
                                 WHERE we.wip_entity_id =
                                 mmt.transaction_source_id-- AND mmt.organization_id = we.organization_id
                                 )
                                 END                                 wip_entity_name
 FROM gl_ledger_le_bsv_specific_v gld,
         xla_event_classes_vl xec,
         xla_event_class_attrs xat,
         xla_event_types_vl xet,
         xla_events xev,
         xla_ae_headers xah,
         xla_ae_lines xal,
         xla_distribution_links xdl,
         gl_code_combinations_kfv gcc,
         mtl_transaction_accounts mta,
         xx_mtl_material_transactions mmt,
         mtl_system_items_kfv msik_mmt,
         mtl_transaction_reasons mtr,
         mtl_transaction_types mtt,
         mtl_parameters mp,
         fnd_user usr,
         org_organization_definitions ood,
         xx_msi_cat msiq,
          mtl_secondary_inventories msei --cr2430 -- Se incorporÃ³ el subinventario
 WHERE 1=1
         AND xah.application_id = P_APPLICATION_ID
         AND xal.application_id = P_APPLICATION_ID
         AND xet.application_id = P_APPLICATION_ID
         AND xah.ledger_id = gld.ledger_id
         AND xah.event_type_code = xet.event_type_code
         AND xet.application_id = xec.application_id
         AND xet.entity_code = xec.entity_code
         AND xet.event_class_code = xec.event_class_code
         AND xat.application_id = xec.application_id
         AND xat.entity_code = xec.entity_code
         AND xat.event_class_code = xec.event_class_code
         AND xev.event_id = xah.event_id
         AND xev.event_status_code <> 'N'
         AND xal.code_combination_id = gcc.code_combination_id(+)
         AND xah.ae_header_id = xal.ae_header_id
         AND mmt.created_by = usr.user_id(+)
         AND xah.event_id = xdl.event_id
         AND xal.ae_header_id = xdl.ae_header_id
         AND xal.ae_line_num = xdl.ae_line_num
         -- evita full access al distrib
         AND xdl.event_id = xah.event_id
         AND xdl.application_id = P_APPLICATION_ID
         AND xdl.source_distribution_id_num_1 = mta.inv_sub_ledger_id
         AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
         -- evita full access al distrib
         AND mta.transaction_id = mmt.transaction_id
         AND mta.organization_id = mp.organization_id
         AND mmt.organization_id = msik_mmt.organization_id
         AND mmt.inventory_item_id = msik_mmt.inventory_item_id
         AND mmt.organization_id = msiq.organization_id (+)
         AND mmt.inventory_item_id = msiq.inventory_item_id (+)
         AND mmt.organization_id = ood.organization_id
         AND mmt.transaction_type_id = mtt.transaction_type_id
         AND mmt.reason_id = mtr.reason_id(+)
           --cr2430 -- Se incorporÃ³ el subinventario                   
          AND mmt.organization_id = msei.organization_id(+)
          AND mmt.subinventory_code = msei.secondary_inventory_name(+)
         --Parametros
         AND ood.OPERATING_UNIT = P_ORG_ID
         AND (mmt.transaction_type_id = P_TRANSACTION_TYPE_ID OR          P_TRANSACTION_TYPE_ID IS NULL) --15 rma rece
         AND (xat.event_class_group_code = P_EVENT_CLASS_GROUP_CODE OR          P_EVENT_CLASS_GROUP_CODE IS NULL)
         AND (P_SOLO_ERRORES = 'N' OR          P_SOLO_ERRORES = 'Y' AND
                    EXISTS (SELECT 'X'      FROM xla_accounting_errors xae         WHERE xae.event_id = xev.event_id         AND (xae.ae_line_num = xal.ae_line_num OR         xae.ae_line_num IS NULL         )         )
                )
 ;
 fnd_file.put_line(fnd_file.log, 'END  XX_OPM_SUB_LEGDER_GRAL_GT '||to_char (sysdate, 'dd/mm/yyyy hh24:mi:ss')|| ' RC = '||sql%Rowcount);

 RETURN(TRUE);
 END BeforeReportTrigger;
END XX_OPM_SUB_LEDGER_PKG;
/

exit
