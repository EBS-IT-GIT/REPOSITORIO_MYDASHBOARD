  set define off;

CREATE OR REPLACE PACKAGE APPS."XX_OPM_REPORTES_PKG" AS

  PROCEDURE Detalle_Costo_Unitario ( errbuf               IN OUT NOCOPY VARCHAR2
                                   , retcode              IN OUT NOCOPY VARCHAR2
                                   , p_operating_unit     NUMBER
                                   , p_organization_id    NUMBER
                                   , p_calendar           VARCHAR2
                                   , p_periodo_desde      VARCHAR2
                                   , p_periodo_hasta      VARCHAR2
                                   , p_categoria_contable VARCHAR2
                                   , p_item_id            NUMBER
                                   , p_cost_type_id       NUMBER -- ADM CH14608 
                                   );

  PROCEDURE Ajustes_Agronomo ( errbuf               IN OUT NOCOPY VARCHAR2
                             , retcode              IN OUT NOCOPY VARCHAR2
                             , p_org_id             NUMBER
                             , p_organization_id    NUMBER
                             , p_fecha_desde        VARCHAR2
                             , p_fecha_hasta        VARCHAR2
                             );

END XX_OPM_REPORTES_PKG;
/

CREATE OR REPLACE PACKAGE BODY APPS."XX_OPM_REPORTES_PKG" AS

  g_xml_hdr     VARCHAR2(250) := '<?xml version="1.0" encoding="UTF-8"?>';
  g_data        VARCHAR2(32767);
  g_yes_no      VARCHAR2(20);
  g_param_desc  VARCHAR2(500);


  FUNCTION xml_escape_chars ( p_data VARCHAR2 ) RETURN VARCHAR IS
    l_data VARCHAR2(32767);
  BEGIN
    l_data := REPLACE(REPLACE(REPLACE(p_data, '&', '&amp;'), '<', '&lt;'), '>', '&gt;');
    RETURN l_data;
  END xml_escape_chars;


   PROCEDURE Detalle_Costo_Unitario ( errbuf               IN OUT NOCOPY VARCHAR2
                                   , retcode              IN OUT NOCOPY VARCHAR2
                                   , p_operating_unit     NUMBER
                                   , p_organization_id    NUMBER
                                   , p_calendar           VARCHAR2
                                   , p_periodo_desde      VARCHAR2
                                   , p_periodo_hasta      VARCHAR2
                                   , p_categoria_contable VARCHAR2
                                   , p_item_id            NUMBER
                                   , p_cost_type_id       NUMBER -- ADM CH14608 
                                   ) IS

    TYPE tColPivot IS RECORD
         ( col_name      VARCHAR2(250)
         , col_name_as   VARCHAR2(250)
         );

    TYPE tbColPivot IS TABLE OF tColPivot;
    rCol tbColPivot;

    TYPE tOut       IS TABLE OF CLOB;
    rOut            tOut;

      c_main_query  VARCHAR2(4000) :=
      'FROM cm_cmpt_dtl                  ccd '||chr(10)
    ||'   , cm_cmpt_mst_vl               ccmv '||chr(10)
    ||'   , mtl_system_items             msib '||chr(10)
    ||'   , cm_mthd_mst                  cmm '||chr(10)
    ||'   , org_organization_definitions mp '||chr(10)
    ||'   , gmf_period_statuses          xop '||chr(10)
    ||'   , gmf_calendar_assignments     gca '||chr(10)
    ||'WHERE 1 = 1 '||chr(10)
    ||'AND ccmv.cost_cmpntcls_id  = ccd.cost_cmpntcls_id '||chr(10)
    ||'AND msib.inventory_item_id = ccd.inventory_item_id '||chr(10)
    ||'AND msib.organization_id   = ccd.organization_id '||chr(10)
    ||'AND cmm.cost_type_id       = ccd.cost_type_id '||chr(10)
    ||'AND mp.organization_id     = ccd.organization_id '||chr(10)
    ||'AND gca.legal_entity_id    = mp.legal_entity '||chr(10)
    ||'AND xop.calendar_code      = gca.calendar_code '||chr(10)
    ||'AND cmm.cost_mthd_code     = ''STD'' '||chr(10)
    ||'AND ccd.period_id          = xop.period_id '||chr(10)
    ||'AND ccd.delete_mark        = 0 '||chr(10)
    ||'AND ccd.cmpnt_cost        != 0 '||chr(10)
    ;

    l_main_stmt           VARCHAR2(4000);
    l_main_stmt_v         VARCHAR2(4000);
    l_col_select          VARCHAR2(2000);
    l_col_sum             VARCHAR2(2000);
    l_cursor              sys_refcursor;

    l_ou_name             VARCHAR2(250);
    l_organization_name   VARCHAR2(250);
    l_calendar_desc       VARCHAR2(150);
    l_periodo_desde       VARCHAR2(20);
    l_periodo_desde_desc  VARCHAR2(150);
    l_periodo_hasta_desc  VARCHAR2(150);
    l_start_date          DATE;
    l_end_date            DATE;
    l_cat_contable_desc   VARCHAR2(300);
    l_item_desc           VARCHAR2(300);
    l_cost_type_desc      VARCHAR2(300);
    l_titulos             VARCHAR2(4000);

    l_error_msg           VARCHAR2(2000);
    eCommonErrors         EXCEPTION;
    eNotFound             EXCEPTION;
  BEGIN
    FND_FILE.Put_Line(FND_FILE.LOG, '------------------------------------------');
    FND_FILE.Put_Line(FND_FILE.LOG, 'p_operating_unit:    '||p_operating_unit);
    FND_FILE.Put_Line(FND_FILE.LOG, 'p_organization_id:   '||p_organization_id);
    FND_FILE.Put_Line(FND_FILE.LOG, 'p_calendar:          '||p_calendar);
    FND_FILE.Put_Line(FND_FILE.LOG, 'p_periodo_desde:     '||p_periodo_desde);
    FND_FILE.Put_Line(FND_FILE.LOG, 'p_periodo_hasta:     '||p_periodo_hasta);
    FND_FILE.Put_Line(FND_FILE.LOG, 'p_categoria_contable '||p_categoria_contable);
    FND_FILE.Put_Line(FND_FILE.LOG, 'p_item_id:           '||p_item_id);
    FND_FILE.Put_Line(FND_FILE.LOG, 'p_cost_type_id:      '||p_cost_type_id); -- ADM CH14608 
    FND_FILE.Put_Line(FND_FILE.LOG, '------------------------------------------');
    FND_FILE.Put_Line(FND_FILE.LOG, ' ');

    BEGIN
      SELECT name
      INTO l_ou_name
      FROM hr_operating_units
      WHERE 1=1
      AND organization_id = p_operating_unit;
    EXCEPTION
      WHEN OTHERS THEN
        l_error_msg := 'Error obteniendo nombre del unidad operativa. '||SQLERRM;
        RAISE eCommonErrors;
    END;

    IF p_organization_id IS NOT NULL THEN
      BEGIN
        SELECT organization_name
        INTO l_organization_name
        FROM org_organization_definitions
        WHERE 1=1
        AND organization_id = p_organization_id;
      EXCEPTION
        WHEN OTHERS THEN
          l_error_msg := 'Error obteniendo nombre de la organización. '||SQLERRM;
          RAISE eCommonErrors;
      END;
    END IF;

    BEGIN
      SELECT calendar_desc
      INTO l_calendar_desc
      FROM cm_cldr_hdr ch
      WHERE calendar_code = p_calendar;
    EXCEPTION
      WHEN OTHERS THEN
        l_error_msg := 'Error obteniendo descripción del calendario. '||SQLERRM;
        RAISE eCommonErrors;
    END;

    l_periodo_desde := NVL(p_periodo_desde, TO_CHAR(SYSDATE, 'YYMM'));

    BEGIN
      SELECT period_desc, TRUNC(start_date) start_date, TRUNC(end_date) end_date
      INTO l_periodo_desde_desc, l_start_date, l_end_date
      FROM cm_cldr_dtl
      WHERE 1=1
      AND calendar_code = p_calendar
      AND period_code   = l_periodo_desde;
    EXCEPTION
      WHEN OTHERS THEN
        l_error_msg := 'Error obteniendo datos del período ('||l_periodo_desde||'). '||SQLERRM;
        RAISE eCommonErrors;
    END;

    IF p_periodo_hasta IS NOT NULL THEN
      BEGIN
        SELECT period_desc, TRUNC(end_date) end_date
        INTO l_periodo_hasta_desc, l_end_date
        FROM cm_cldr_dtl
        WHERE 1=1
        AND calendar_code = p_calendar
        AND period_code   = p_periodo_hasta;
      EXCEPTION
        WHEN OTHERS THEN
          l_error_msg := 'Error obteniendo datos del período ('||p_periodo_hasta||'). '||SQLERRM;
          RAISE eCommonErrors;
      END;
    END IF;

    IF p_categoria_contable IS NOT NULL THEN
      BEGIN
        SELECT description
        INTO l_cat_contable_desc
        FROM mtl_categories_v
        WHERE category_id =  p_categoria_contable
        ;
      EXCEPTION
        WHEN OTHERS THEN
          l_error_msg := 'Error obteniendo descripción de la categoria contable. '||SQLERRM;
          RAISE eCommonErrors;
      END;
    END IF;

    IF p_item_id IS NOT NULL THEN
      BEGIN
        SELECT segment1||' - '||description
        INTO l_item_desc
        FROM mtl_system_items
        WHERE 1=1
        AND inventory_item_id = p_item_id
        AND organization_id   = XX_TCG_FUNCTIONS_PKG.GetMasterOrg;
      EXCEPTION
        WHEN OTHERS THEN
          l_error_msg := 'Error obteniendo descripción del producto. '||SQLERRM;
          RAISE eCommonErrors;
      END;
    END IF;
    
    --Inicio ADM CH14608 
    IF p_cost_type_id IS NOT NULL THEN
      BEGIN
        SELECT cost_mthd_code||' - '||cost_mthd_desc
        INTO l_cost_type_desc
        FROM cm_mthd_mst mthd
        WHERE 1=1
        AND cost_type_id = p_cost_type_id;
      EXCEPTION
        WHEN OTHERS THEN
          l_error_msg := 'Error obteniendo descripción del Tipo de Costo. '||SQLERRM;
          RAISE eCommonErrors;
      END;
    END IF;
    --Fin ADM CH14608 


    FND_FILE.Put_Line(FND_FILE.LOG, 'Fecha Desde '||l_start_date);
    FND_FILE.Put_Line(FND_FILE.LOG, 'Fecha hasta '||l_end_date);

    l_main_stmt := 'SELECT DISTINCT '||chr(10)
                 ||'       ccd.cost_level || ''-'' || ccmv.cost_cmpntcls_code col_name '||chr(10)
                 ||'     , REPLACE(REPLACE(ccmv.cost_cmpntcls_code, ''.'', '' ''), '' '', ''_'')||''_''||ccd.cost_level col_as '||chr(10)
                 ||c_main_query
                 ||'AND mp.operating_unit      = '||p_operating_unit||chr(10);
    IF p_organization_id IS NOT NULL THEN
      l_main_stmt := l_main_stmt
                 ||'AND mp.organization_id     = '||p_organization_id||chr(10);
    END IF;
    l_main_stmt := l_main_stmt
                 ||'AND xop.calendar_code      = '''||p_calendar||''' '||chr(10)
                 ||'AND TRUNC(xop.start_date) >= TO_DATE('||TO_CHAR(l_start_date, 'yyyymmdd')||', ''yyyymmdd'') '||chr(10)
                 ||'AND TRUNC(xop.end_date)   <= TO_DATE('||TO_CHAR(l_end_date, 'yyyymmdd')||', ''yyyymmdd'') '||chr(10);
    IF p_categoria_contable IS NOT NULL THEN
      l_main_stmt := l_main_stmt
                 ||'AND msib.inventory_item_id IN '||chr(10)
                 ||'    (SELECT mic.inventory_item_id FROM mtl_item_categories_v mic '||chr(10)
                 ||'     WHERE mic.organization_id = XX_TCG_FUNCTIONS_PKG.GetMasterOrg '||chr(10)
                 ||'     AND mic.category_set_name = ''Categoría Contable OPM'' '||chr(10)
                 ||'     AND mic.category_id = '||p_categoria_contable||') '||chr(10);
    END IF;
    
    IF p_item_id IS NOT NULL THEN
      l_main_stmt := l_main_stmt
                 ||'AND msib.inventory_item_id = '||p_item_id||chr(10);
    END IF;
    
    --Inicio ADM CH14608 
    IF p_cost_type_id IS NOT NULL THEN
      l_main_stmt := l_main_stmt
                 ||'AND gca.cost_type_id = '||p_cost_type_id||chr(10);
    END IF;
    --Fin ADM CH14608 

    OPEN l_cursor FOR l_main_stmt;
    FETCH l_cursor BULK COLLECT INTO rCol;
    CLOSE l_cursor;

    IF rCol.count = 0 THEN
      RAISE eNotFound;
    END IF;

    l_main_stmt := 'SELECT * '||chr(10)
                 ||'FROM  '||chr(10)
                 ||'( '||chr(10)
                 ||'SELECT mp.operating_unit, '||chr(10)
                 ||'       mp.organization_code, '||chr(10)
                 ||'       xop.calendar_code, '||chr(10)
                 ||'       xop.period_code, '||chr(10)
                 ||'       TRUNC (xop.start_date) start_date, '||chr(10)
                 ||'       TRUNC (xop.end_date) end_date, '||chr(10)
                 ||'       msib.segment1 item_no, '||chr(10)
                 ||'       msib.description item_desc, '||chr(10)
                 ||'              (SELECT micd.description '||chr(10)
                 ||'               FROM mtl_item_categories_v mic, cln_inv_category_v micd '||chr(10)
                 ||'               WHERE 1=1 '||chr(10)
                 ||'               AND mic.organization_id   = msib.organization_id '||chr(10)
                 ||'               AND mic.inventory_item_id = msib.inventory_item_id '||chr(10)
                 ||'               AND micd.organization_id  = msib.organization_id '||chr(10)
                 ||'               AND micd.category_id      = mic.category_id '||chr(10)
                 ||'               AND mic.category_set_name = ''Categoría Contable OPM'') opm_gl_class, '||chr(10)
                 ||'       msib.primary_unit_of_measure uom, '||chr(10)
                 ||'       cmm.cost_mthd_code, '||chr(10)
                 ||'       cost_level || ''-'' || ccmv.cost_cmpntcls_code '||chr(10)
                 ||'       cost_component_class, '||chr(10)
                 ||'       ccd.cost_analysis_code, '||chr(10)
                 ||'       ccd.cmpnt_cost'||chr(10)
                 ||c_main_query
                 ||'AND mp.operating_unit      = '||p_operating_unit||chr(10);
    IF p_organization_id IS NOT NULL THEN
      l_main_stmt := l_main_stmt
                 ||'AND mp.organization_id     = '||p_organization_id||chr(10);
    END IF;
    l_main_stmt := l_main_stmt
                 ||'AND xop.calendar_code      = '''||p_calendar||''' '||chr(10)
                 ||'AND TRUNC(xop.start_date) >= TO_DATE('||TO_CHAR(l_start_date, 'yyyymmdd')||', ''yyyymmdd'') '||chr(10)
                 ||'AND TRUNC(xop.end_date)   <= TO_DATE('||TO_CHAR(l_end_date, 'yyyymmdd')||', ''yyyymmdd'') '||chr(10);
    IF p_categoria_contable IS NOT NULL THEN
      l_main_stmt := l_main_stmt
                 ||'AND msib.inventory_item_id IN '||chr(10)
                 ||'    (SELECT mic.inventory_item_id FROM mtl_item_categories_v mic '||chr(10)
                 ||'     WHERE mic.organization_id = XX_TCG_FUNCTIONS_PKG.GetMasterOrg '||chr(10)
                 ||'     AND mic.category_set_name = ''Categoría Contable OPM'' '||chr(10)
                 ||'     AND mic.category_id = '||p_categoria_contable||') '||chr(10);
    END IF;
    IF p_item_id IS NOT NULL THEN
      l_main_stmt := l_main_stmt
                 ||'AND msib.inventory_item_id = '||p_item_id||chr(10);
    END IF;
    --Inicio ADM CH14608 
    IF p_cost_type_id IS NOT NULL THEN
      l_main_stmt := l_main_stmt
                 ||'AND gca.cost_type_id = '||p_cost_type_id||chr(10);
    END IF;
    --Fin ADM CH14608 
    l_main_stmt := l_main_stmt
             ||') PIVOT (SUM (cmpnt_cost) FOR cost_component_class IN '||chr(10)
                 ||'  (';

    FOR i IN rCol.first .. rCol.last LOOP
      IF i = 1 THEN
        l_main_stmt := l_main_stmt ||''''||rCol(i).col_name||''' AS "'||rCol(i).col_name_as||'"'||chr(10);
      ELSE
        l_main_stmt := l_main_stmt ||', '''||rCol(i).col_name||''' AS "'||rCol(i).col_name_as||'"'||chr(10);
      END IF;
    END LOOP;

    l_main_stmt := l_main_stmt ||'  ))';

    l_main_stmt_v := 'CREATE OR REPLACE FORCE VIEW XX_OPM_COST_UNIT_PIVOT AS ('||l_main_stmt||')';
FND_FILE.Put_Line(FND_FILE.LOG,l_main_stmt_v);
    EXECUTE IMMEDIATE l_main_stmt_v;

    BEGIN
      /*SELECT LISTAGG(column_name, '||''|''||') WITHIN GROUP (ORDER BY column_id) col
           , 'NVL('||LISTAGG(column_name, ',0)+NVL(') WITHIN GROUP (ORDER BY column_id)||',0)' col_sum*/
      SELECT 'XX_UTIL_PK.XML_NUM_DISPLAY(NVL('||LISTAGG(column_name, ',0))||''|''||XX_UTIL_PK.XML_NUM_DISPLAY(NVL(') WITHIN GROUP (ORDER BY column_id)||',0))' col
           , 'XX_UTIL_PK.XML_NUM_DISPLAY(NVL('||LISTAGG(column_name, ',0)+NVL(') WITHIN GROUP (ORDER BY column_id)||',0))' col_sum
      INTO l_col_select, l_col_sum
      FROM dba_tab_columns
      WHERE table_name = 'XX_OPM_COST_UNIT_PIVOT'
      AND column_id > 12
      ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE eNotFound;
    END;

    l_main_stmt :=
'SELECT PERIOD_CODE
||''|''||CALENDAR_CODE
||''|''||ORGANIZATION_CODE
||''|''||ITEM_NO
||''|''||ITEM_DESC
||''|''||OPM_GL_CLASS
||''|''||UOM
||''|''||COST_MTHD_CODE
||''|''||COST_ANALYSIS_CODE
||''|''||('||l_col_sum||')
||''|''||'||l_col_select||
' FROM xx_opm_cost_unit_pivot ORDER BY organization_code, period_code, item_desc';

    OPEN l_cursor FOR l_main_stmt;
    FETCH l_cursor BULK COLLECT INTO rOut;
    CLOSE l_cursor;

    FND_FILE.Put_Line(FND_FILE.Output,  g_xml_hdr);
    FND_FILE.Put_Line(FND_FILE.Output, '<XXOPMCOSTOUNI>');
    FND_FILE.Put_Line(FND_FILE.Output, '  <REPORT_NAME>XX OPM Detalle de Costo Unitario</REPORT_NAME>');
    FND_FILE.Put_Line(FND_FILE.Output, '  <FECHA_EMISION>Fecha Emisión|'||TO_CHAR(SYSDATE, 'DD-MM-YYYY HH24:MI:SS')||'</FECHA_EMISION>');
    FND_FILE.Put_Line(FND_FILE.Output, '  <P_OU>Unidad Operativa|'||l_ou_name||'</P_OU>');
    FND_FILE.Put_Line(FND_FILE.Output, '  <P_ORG>Organización|'||l_organization_name||'</P_ORG>');
    FND_FILE.Put_Line(FND_FILE.Output, '  <P_CALENDAR>Calendario de Costos|'||l_calendar_desc||'</P_CALENDAR>');
    FND_FILE.Put_Line(FND_FILE.Output, '  <P_PERIOD_FROM>Período Desde|'||l_periodo_desde||'</P_PERIOD_FROM>');
    FND_FILE.Put_Line(FND_FILE.Output, '  <P_PERIOD_TO>Período Hasta|'||p_periodo_hasta||'</P_PERIOD_TO>');
    FND_FILE.Put_Line(FND_FILE.Output, '  <P_CAT_CONTABLE>Categoría Contable|'||l_cat_contable_desc||'</P_CAT_CONTABLE>');
    FND_FILE.Put_Line(FND_FILE.Output, '  <P_ITEM>Producto|'||l_item_desc||'</P_ITEM>');
    FND_FILE.Put_Line(FND_FILE.Output, '  <P_COST_TYPE>Tipo de Costo|'||l_cost_type_desc||'</P_COST_TYPE>'); -- ADM CH14608 

    l_titulos := 'PERIODO'
        ||'|'||'CALENDARIO'
        ||'|'||'ORGANIZACION'
        ||'|'||'ARTICULO'
        ||'|'||'DESCRIPCION'
        ||'|'||'CATEGORIA CONTABLE'
        ||'|'||'UOM'
        ||'|'||'TIPO_COSTO'
        ||'|'||'ANALYSIS_CODE'
        ||'|'||'COSTO TOTAL';

    FOR i IN rCol.first .. rCol.last LOOP
      l_titulos := l_titulos ||'|'|| rCol(i).col_name;
    END LOOP;

    FND_FILE.Put_Line(FND_FILE.Output, '  <C_TITULOS>'||l_titulos||'</C_TITULOS>');
    FOR i IN rOut.first .. rOut.last LOOP
      FND_FILE.Put_Line(FND_FILE.Output, '  <G_DATA>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <DATA>'||rOut(i)||'</DATA>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <DUMMY>_</DUMMY>');
      FND_FILE.Put_Line(FND_FILE.Output, '  </G_DATA>');
    END LOOP;

    FND_FILE.Put_Line(FND_FILE.Output, '</XXOPMCOSTOUNI>');

  EXCEPTION
    WHEN eNotFound THEN
      errbuf  := 'No se encontraron datos para los parámetros especificados.';
      retcode := 0;
      FND_FILE.Put_Line(FND_FILE.LOG, errbuf);
    WHEN eCommonErrors THEN
      FND_FILE.Put_Line(FND_FILE.LOG, l_error_msg);
      errbuf  := l_error_msg;
      retcode := 2;
    WHEN OTHERS THEN
      ROLLBACK;
      errbuf  := SQLERRM;
      retcode := 2;
  END Detalle_Costo_Unitario;


  PROCEDURE Ajustes_Agronomo ( errbuf               IN OUT NOCOPY VARCHAR2
                             , retcode              IN OUT NOCOPY VARCHAR2
                             , p_org_id             NUMBER
                             , p_organization_id    NUMBER
                             , p_fecha_desde        VARCHAR2
                             , p_fecha_hasta        VARCHAR2
                             ) IS

    CURSOR c1 IS

      SELECT ai.*, od.operating_unit, ou.name operating_unit_name
      FROM xx_agronomo_interface        ai
         , org_organization_definitions od
         , hr_operating_units           ou
      WHERE 1=1
      AND od.organization_code = ai.organizacion_codigo
      AND ou.organization_id   = od.operating_unit
      AND od.operating_unit    = NVL(p_org_id, od.operating_unit)
      AND od.organization_id   = NVL(p_organization_id, od.organization_id)
      AND ( p_fecha_desde IS NULL OR
            TRUNC(NVL(ai.fecha_certifica, ai.orden_trabajo_fecha)) >= TRUNC(TO_DATE(p_fecha_desde, 'YYYY-MM-DD HH24:MI:SS'))
          )
      AND ( p_fecha_hasta IS NULL OR
            TRUNC(NVL(ai.fecha_certifica, ai.orden_trabajo_fecha)) <= TRUNC(TO_DATE(p_fecha_hasta, 'YYYY-MM-DD HH24:MI:SS'))
          )
      ORDER BY orden_trabajo, mov_fecha, mov_id
      ;

    l_ou_name             VARCHAR2(250);
    l_organization_name   VARCHAR2(250);
    l_calendar_desc       VARCHAR2(150);
    l_fecha_desde         DATE;
    l_fecha_hasta         DATE;
    l_cantidad            NUMBER;

    l_error_msg           VARCHAR2(2000);
  BEGIN
    FND_FILE.Put_Line(FND_FILE.LOG, '------------------------------------------');
    FND_FILE.Put_Line(FND_FILE.LOG, 'p_operating_unit:  '||p_org_id);
    FND_FILE.Put_Line(FND_FILE.LOG, 'p_organization_id: '||p_organization_id);
    FND_FILE.Put_Line(FND_FILE.LOG, 'p_fecha_desde:     '||p_fecha_desde);
    FND_FILE.Put_Line(FND_FILE.LOG, 'p_fecha_hasta:     '||p_fecha_hasta);
    FND_FILE.Put_Line(FND_FILE.LOG, '------------------------------------------');
    FND_FILE.Put_Line(FND_FILE.LOG, ' ');

    BEGIN
      SELECT name
      INTO l_ou_name
      FROM hr_operating_units
      WHERE 1=1
      AND organization_id = p_org_id;
    EXCEPTION
      WHEN OTHERS THEN
        FND_FILE.Put_Line(FND_FILE.LOG, 'Error obteniendo nombre del unidad operativa.');
    END;

    IF p_organization_id IS NOT NULL THEN
      BEGIN
        SELECT organization_name
        INTO l_organization_name
        FROM org_organization_definitions
        WHERE 1=1
        AND organization_id = p_organization_id;
      EXCEPTION
        WHEN OTHERS THEN
          FND_FILE.Put_Line(FND_FILE.LOG, 'Error obteniendo nombre de la organización.');
      END;
    END IF;

    FND_FILE.Put_Line(FND_FILE.Output,  g_xml_hdr);
    FND_FILE.Put_Line(FND_FILE.Output, '<XXINVAGRONOAJU>');
    FND_FILE.Put_Line(FND_FILE.Output, '  <REPORT_NAME>XX INV Reporte Interfaz de Ajustes Agronomo</REPORT_NAME>');
    FND_FILE.Put_Line(FND_FILE.Output, '  <FECHA_EMISION>'||TO_CHAR(SYSDATE, 'DD-MM-YYYY HH24:MI:SS')||'</FECHA_EMISION>');
    FND_FILE.Put_Line(FND_FILE.Output, '  <P_OU>'||l_ou_name||'</P_OU>');
    FND_FILE.Put_Line(FND_FILE.Output, '  <P_ORG>'||l_organization_name||'</P_ORG>');
    FND_FILE.Put_Line(FND_FILE.Output, '  <P_FECHA_DESDE>'||SUBSTR(p_fecha_desde, 1, 10)||'</P_FECHA_DESDE>');
    FND_FILE.Put_Line(FND_FILE.Output, '  <P_FEHCA_HASTA>'||SUBSTR(p_fecha_hasta, 1, 10)||'</P_FEHCA_HASTA>');

    FOR r1 IN c1 LOOP
      FND_FILE.Put_Line(FND_FILE.Output, '  <G_DATA>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <ORDEN_TRABAJO>'||r1.ORDEN_TRABAJO||'</ORDEN_TRABAJO>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <ORDEN_TRABAJO_FECHA>'||TO_CHAR(NVL(r1.FECHA_CERTIFICA, r1.ORDEN_TRABAJO_FECHA), 'DD-MM-YYYY')||'</ORDEN_TRABAJO_FECHA>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <OPERATING_UNIT_NAME>'||r1.OPERATING_UNIT_NAME||'</OPERATING_UNIT_NAME>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <ORGANIZACION_CODIGO>'||r1.ORGANIZACION_CODIGO||'</ORGANIZACION_CODIGO>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <SUB_INVENTARIO_CODIGO>'||r1.SUB_INVENTARIO_CODIGO||'</SUB_INVENTARIO_CODIGO>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <LOCALIZADOR>'||r1.LOCALIZADOR||'</LOCALIZADOR>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <ALQUILADO_DIRECCION>'||xml_escape_chars(r1.ALQUILADO_DIRECCION)||'</ALQUILADO_DIRECCION>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <LOTE>'||xml_escape_chars(r1.LOTE)||'</LOTE>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <SUPERFICIE>'||XX_UTIL_PK.xml_num_display(r1.SUPERFICIE, '.,', 'N')||'</SUPERFICIE>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <MOV_ID>'||r1.MOV_ID||'</MOV_ID>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <MOV_FECHA>'||TO_CHAR(r1.MOV_FECHA, 'DD-MM-YYYY')||'</MOV_FECHA>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <PRODUCTO_NUMERO>'||r1.PRODUCTO_NUMERO||'</PRODUCTO_NUMERO>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <PRODUCTO_DESC>'||xml_escape_chars(r1.PRODUCTO_DESC)||'</PRODUCTO_DESC>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <PRODUCTO_LOTE>'||xml_escape_chars(r1.PRODUCTO_LOTE)||'</PRODUCTO_LOTE>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <UOM>'||r1.UOM||'</UOM>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <MOV_TIPO>'||r1.MOV_TIPO||'</MOV_TIPO>');
      IF r1.MOV_TIPO = 'ENTREGAS' THEN
        l_cantidad := r1.MOV_CANTIDAD * -1;
      ELSE
        l_cantidad := r1.MOV_CANTIDAD;
      END IF;
      FND_FILE.Put_Line(FND_FILE.Output, '    <MOV_CANTIDAD>'||XX_UTIL_PK.xml_num_display(l_cantidad, '.,', 'N')||'</MOV_CANTIDAD>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <PROYECTO>'||r1.PROYECTO||'</PROYECTO>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <TAREA>'||r1.TAREA||'</TAREA>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <TIPO_EROGACION>'||r1.TIPO_EROGACION||'</TIPO_EROGACION>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <TIPO_EROGACION_ORG>'||r1.TIPO_EROGACION_ORG||'</TIPO_EROGACION_ORG>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <MOV_REFERENCIA>'||r1.MOV_REFERENCIA||'</MOV_REFERENCIA>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <IMPORTADO_FLAG>'||r1.IMPORTADO_FLAG||'</IMPORTADO_FLAG>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <MENSAJE_ERROR>'||r1.MENSAJE_ERROR||'</MENSAJE_ERROR>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <CREATION_DATE>'||TO_CHAR(r1.CREATION_DATE, 'DD-MM-YYYY HH24:MI')||'</CREATION_DATE>');
      FND_FILE.Put_Line(FND_FILE.Output, '    <LAST_UPDATE_DATE>'||TO_CHAR(r1.LAST_UPDATE_DATE, 'DD-MM-YYYY HH24:MI')||'</LAST_UPDATE_DATE>');
      FND_FILE.Put_Line(FND_FILE.Output, '  </G_DATA>');
    END LOOP;
    FND_FILE.Put_Line(FND_FILE.Output, '</XXINVAGRONOAJU>');

  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := SQLERRM;
      retcode := 2;
  END Ajustes_Agronomo;


END XX_OPM_REPORTES_PKG;
/

exit
