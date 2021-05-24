create or replace PACKAGE BODY        "XX_WS_EFACTURAURU3_PUB" AS
PROCEDURE actualizar_rta ( p_xmldoc dbms_xmldom.domdocument
, x_status_code OUT VARCHAR2
, x_error_code OUT VARCHAR2
, x_error_dtl OUT VARCHAR2
) IS
l_nodelist dbms_xmldom.domnodelist;
l_xmllength NUMBER;
l_currentnode dbms_xmldom.domnode;
l_currentnodename  VARCHAR2(4000);
l_firstchild dbms_xmldom.domnode;
l_firstchildvalue VARCHAR2(4000);
BEGIN
l_nodelist    := dbms_xmldom.getelementsbytagname(p_xmldoc, '*');
l_xmllength   := dbms_xmldom.getlength(l_nodelist);
--fnd_file.put_line(fnd_file.log,'l_xmllength = '||l_xmllength);
FOR i IN 0 .. l_xmllength -1
LOOP
l_currentnode := dbms_xmldom.item(l_nodelist, i);
l_currentnodename := dbms_xmldom.getnodename(l_currentnode);
l_firstchild := dbms_xmldom.getfirstchild(l_currentnode);
l_firstchildvalue := dbms_xmldom.getnodevalue(l_firstchild);
IF  l_currentnodename = 'Estado' THEN
x_status_code := l_firstchildvalue;
ELSIF  l_currentnodename = 'Motivo' AND x_status_code IN ('BE','BR') THEN
x_error_code := l_firstchildvalue;
ELSIF  x_status_code IN ('BE','BR') AND l_currentnodename = 'Detalle'  THEN
x_error_dtl := l_firstchildvalue;
END IF;
END LOOP;
END actualizar_rta;
PROCEDURE actualizar_template_reporte ( p_fecha_reporte IN DATE , p_seq IN VARCHAR2, p_doc IN OUT dbms_xmldom.domdocument, x_cnt OUT NUMBER, p_rut IN VARCHAR2) IS
CURSOR c_caratula IS
WITH nums AS (
SELECT ROWNUM rn FROM (SELECT 1, 2, 3 FROM dual GROUP BY CUBE (1, 2, 3)) WHERE ROWNUM <= 4)
SELECT node_name, node_value FROM
(SELECT DECODE(rn, 1, 'ns1:FechaResumen', 2, 'ns1:CantComprobantes' , 3, 'ns1:SecEnvio', 4, 'ns1:TmstFirmaEnv') node_name,
DECODE(rn, 1, trx_date, 2, cnt, 3, seq, 4, tmst) node_value
FROM
(
SELECT
apar.fecha trx_date
, apar.cnt
, NVL (xardu.seq,0) +1  seq
,  TO_CHAR (SYSDATE, 'YYYY-MM-DD')||'T'||TO_CHAR(SYSDATE,'hh24:mi:ss')||'-03:00'   tmst
FROM
(SELECT TO_CHAR (fecha, 'RRRR-MM-DD') fecha, seq FROM  xx_ar_rpte_diario_uy) xardu
,
(
SELECT q.fecha , SUM (q.cnt_utl) cnt
FROM
(
SELECT
TO_CHAR (TO_DATE (xrruz.trx_date , 'DDMMYYYY'),'RRRR-MM-DD') fecha
, COUNT (1) cnt_utl
FROM  -- bolinf.xx_ws_efactura_uy_zz  xweuz
xx_rpt_rsm_uy_zz xrruz
WHERE
xrruz.trx_date = TO_CHAR (p_fecha_reporte, 'DDMMYYYY')
AND xrruz.org_id = fnd_global.org_id
GROUP BY TO_CHAR (TO_DATE (xrruz.trx_date , 'DDMMYYYY'),'RRRR-MM-DD')
) q
GROUP BY q.fecha
) apar
WHERE
xardu.fecha (+)  = apar.fecha
) qrya
, nums);
r_caratula c_caratula%ROWTYPE;
CURSOR c_main IS
SELECT
xrruz2.rpt_tag, xrruz2.cnt_rech, xrruz2.xx_tipo_cbte_uy, --rownum, xrruz2.serie,
--XmlElement ("ns1:TipoComp", xrruz2.xx_tipo_cbte_uy ,
XmlElement ("ns1:RsmnData" , xmlattributes ( 'http://cfe.dgi.gub.uy' as "xmlns:ns1" )
, XmlElement ("ns1:Montos"
, XmlElement ("ns1:Mnts_FyT_Item"
, XmlElement ("ns1:Fecha", xrruz2.trx_date2 ) --to_char (to_date (xrruz2.trx_date, 'ddmmyyyy'), 'yyyy-mm-dd'))
, XmlElement ("ns1:CodSuc", decode (fnd_global.org_id, 194, '6', '1'))
, XmlElement ("ns1:TotMntNoGrv", xrruz2.t_amnt_ngrv)
, XmlElement ("ns1:TotMntExpyAsim", xrruz2.t_amnt_exp)
,
CASE
WHEN xrruz2.xx_tipo_cbte_uy IN ('111', '112', '113') THEN
XmlElement ("ns1:TotMntIVATasaMin", xrruz2.t_amnt_tmin )
ELSE
NULL
END
,
CASE
WHEN xrruz2.xx_tipo_cbte_uy IN ('111', '112', '113') THEN
XmlElement ("ns1:TotMntIVATasaBas", xrruz2.t_amnt_tbas )
ELSE
NULL
END
,
CASE
WHEN xrruz2.xx_tipo_cbte_uy IN ('111', '112', '113')   AND xrruz2.rate_tmin > 0 THEN
XmlElement ("ns1:MntIVATasaMin", xrruz2.amnt_tmin )
ELSE
NULL
END
,
CASE
WHEN xrruz2.xx_tipo_cbte_uy IN ('111', '112', '113') AND xrruz2.rate_tbas > 0 THEN
XmlElement ("ns1:MntIVATasaBas", xrruz2.amnt_tbas )
ELSE
NULL
END
,
CASE
WHEN xrruz2.xx_tipo_cbte_uy IN ('111', '112', '113') AND xrruz2.rate_tmin > 0 THEN
XmlElement ("ns1:IVATasaMin", xrruz2.rate_tmin )
ELSE
NULL
END
,
CASE
WHEN xrruz2.xx_tipo_cbte_uy IN ('111', '112', '113') AND xrruz2.rate_tbas > 0 THEN
XmlElement ("ns1:IVATasaBas", xrruz2.rate_tbas )
ELSE
NULL
END
, XmlElement ("ns1:TotMntTotal", xrruz2.amnt)
)
)
, XmlElement ("ns1:CantDocsUtil", xrruz2.cnt)
, CASE
WHEN xrruz2.xx_tipo_cbte_uy IN ('101', '102', '103') THEN
XmlElement ("ns1:CantDocsMay_topeUI", xrruz2.cnt_ui )
ELSE
NULL
END
, XmlElement ("ns1:CantDocsAnulados", xrruz2.cnt_rech)
, XmlElement ("ns1:CantDocsEmi", xrruz2.cnt_emi)
, XmlElement ("ns1:RngDocsUtil"
, ( SELECT XMLAGG (
XmlElement ("ns1:RDU_Item" ,
XmlElement ("ns1:Serie" , qryser.serie)
, XmlElement ("ns1:NroDesde", qryser.nrodesde)
, XmlElement ("ns1:NroHasta", qryser.nrohasta)
)
) FROM
(
SELECT
xrruz22.serie
, xrruz22.nrodesde
, xrruz22.nrohasta
FROM xx_rpt_rsm_uy_serie xrruz22 WHERE xrruz22.xx_tipo_cbte_uy = xrruz2.xx_tipo_cbte_uy
) qryser
)
--, XmlElement ("ns1:Serie", xrruz2.serie)
--, XmlElement ("ns1:NroDesde", xrruz2.nrodesde)
--, XmlElement ("ns1:NroHasta", xrruz2.nrohasta)
)
)
xmldata
FROM
(
SELECT
xrruz.xx_tipo_cbte_uy
, xrruz.trx_date
, TO_CHAR (rcta.trx_date,'RRRR-MM-DD') trx_date2
, xrruz.rpt_tag
--, xrruz.serie
, LTRIM (TO_CHAR (ABS(SUM ( DECODE (xrruz.status, 'AE', xrruz.amnt, 0))),'9999999999.99')) amnt
,
SUM(
CASE WHEN xrruz.xx_tipo_cbte_uy IN ('101' , '102', '103') AND xrruz.status IN ('AE') AND (xrruz.amnt > qry_ui.ui_limit) THEN
1
ELSE
0
END
) cnt_ui
, LTRIM (TO_CHAR (ABS(SUM ( DECODE (xrruz.status, 'AE',xrruz.amnt_tmin,0))),'9999999999.99')) amnt_tmin
, LTRIM (TO_CHAR (ABS(SUM ( DECODE (xrruz.status, 'AE',xrruz.amnt_tbas, 0))),'9999999999.99')) amnt_tbas
, MAX ( xrruz.rate_tbas ) rate_tbas
, MAX (  xrruz.rate_tmin ) rate_tmin
, LTRIM (TO_CHAR (ABS(SUM (DECODE (xrruz.status, 'AE',xrruz.t_amnt_tmin,0) )),'9999999999.99')) t_amnt_tmin
, LTRIM (TO_CHAR (ABS(SUM ( DECODE (xrruz.status, 'AE', xrruz.t_amnt_tbas,0))),'9999999999.99')) t_amnt_tbas
, LTRIM (TO_CHAR (ABS(SUM ( DECODE (xrruz.status, 'AE', xrruz.t_amnt_exp,0))),'9999999999.99')) t_amnt_exp
, LTRIM (TO_CHAR (ABS(SUM( DECODE (xrruz.status, 'AE',xrruz.t_amnt_ngrv,0))),'9999999999.99')) t_amnt_ngrv
, COUNT (DISTINCT (xrruz.id_emisor)) cnt
, COUNT (DISTINCT (DECODE (xrruz.status /* rctad.xx_ar_acuse_recibo_dgi_uy */,'BE',xrruz.id_emisor,null))) cnt_rech
, COUNT (DISTINCT (DECODE (xrruz.status /* rctad.xx_ar_acuse_recibo_dgi_uy */,'AE',xrruz.id_emisor,null))) cnt_emi
, MIN ( TO_NUMBER (SUBSTR (xrruz.trx_number,8,8)) ) nrodesde
, MAX ( TO_NUMBER (SUBSTR (xrruz.trx_number,8,8)) ) nrohasta
FROM
xx_rpt_rsm_uy_zz xrruz
,  ra_customer_trx_all rcta
, (              SELECT CONVERSION_DATE, NVL (MAX (conversion_rate * 10000), 0) ui_limit -- INTO l_ui_limit
FROM gl_daily_rates WHERE to_currency = 'UYU'
--AND CONVERSION_DATE = Trunc (SYSDATE)
AND FROM_CURRENCY = 'UI_UYU'
GROUP BY CONVERSION_DATE
) qry_ui
WHERE
xrruz.id_emisor = rcta.customer_trx_id
AND rcta.org_id = fnd_global.org_id
AND qry_ui.CONVERSION_DATE = to_date (xrruz.trx_date, 'ddmmyyyy') -- trunc (SYSDATE)--to_date ('28012020', 'ddmmyyyy') --to_date (xrruz.trx_date, 'ddmmyyyy')
GROUP BY
xrruz.xx_tipo_cbte_uy
, xrruz.trx_date
,TO_CHAR (rcta.trx_date,'RRRR-MM-DD')
, xrruz.rpt_tag
--, xrruz.serie
) xrruz2
WHERE xrruz2.trx_date = TO_CHAR (p_fecha_reporte,'ddmmyyyy') --'05022020'
UNION ALL
SELECT
--xrruz3.rpt_tag, xrruz3.cnt_rech, rownum,
xrruz3.rpt_tag, xrruz3.cnt_rech, xrruz3.xx_tipo_cbte_uy , -- rownum, xrruz3.serie,
XmlElement ("ns1:RsmnData"
, xmlattributes ( 'http://cfe.dgi.gub.uy' as "xmlns:ns1" )
, XmlElement ("ns1:Montos"
, XmlElement ("ns1:Mnts_Res_Item"
, XmlElement ("ns1:Fecha", xrruz3.trx_date2) --to_char (to_date (xrruz3.trx_date, 'ddmmyyyy'), 'yyyy-mm-dd'))
, XmlElement ("ns1:CodSuc", decode (fnd_global.org_id, 194, '6', '1'))
-- , XmlElement ("ns1:TotMntTotal", xrruz3.amnt)
, XmlElement ("ns1:TotMntRetenido", xrruz3.amnt)
--  , XmlElement ("ns1:TotMntCredFisc", xrruz3.amnt)
)
)
, XmlElement ("ns1:CantDocsUtil", xrruz3.cnt)
, XmlElement ("ns1:CantDocsAnulados", xrruz3.cnt_rech)
, XmlElement ("ns1:CantDocsEmi", xrruz3.cnt_emi)
, XmlElement ("ns1:RngDocsUtil"
, XmlElement ("ns1:RDU_Item"
, XmlElement ("ns1:Serie", xrruz3.serie)
, XmlElement ("ns1:NroDesde", xrruz3.nrodesde)
, XmlElement ("ns1:NroHasta", xrruz3.nrohasta)
)
)
)
xmldata
FROM
(
SELECT
xrruz.xx_tipo_cbte_uy
, xrruz.trx_date
, TO_CHAR (aca.check_date,'RRRR-MM-DD') trx_date2
, xrruz.rpt_tag
, xrruz.serie
, COUNT (1) cnt_emit
, SUM (DECODE (xrruz.status, 'AE',
--CASE
--WHEN acad.XX_AP_ERESGUY_FECHA_ANUL_SOBRE = xrruz.trx_date THEN
xrruz.amnt_anul
--WHEN acad.XX_AP_ERESGUY_FECHA_SOBRE = xrruz.trx_date THEN
+ xrruz.amnt
--ELSE
--0
--END
,0)) amnt
, MIN (xrruz.trx_number ) nrodesde
, MAX (xrruz.trx_number ) nrohasta
, COUNT (DISTINCT (xrruz.trx_number)) cnt
, COUNT (DISTINCT (DECODE (xrruz.status /* rctad.xx_ar_acuse_recibo_dgi_uy */,'BE',xrruz.trx_number,null))) cnt_rech
, COUNT (DISTINCT (DECODE (xrruz.status /* rctad.xx_ar_acuse_recibo_dgi_uy */,'AE',xrruz.trx_number,null))) cnt_emi
FROM
ap_checks_all aca
, ap_checks_all_dfv acad
, xx_rpt_rsm_uy_zz xrruz
WHERE
1 = 1
AND aca.check_id = xrruz.id_emisor
AND aca.rowid = acad.row_id
AND aca.org_id = fnd_global.org_id
GROUP BY
xrruz.xx_tipo_cbte_uy
, xrruz.trx_date
, TO_CHAR (aca.check_date,'RRRR-MM-DD')
, xrruz.Rpt_TAG
, xrruz.serie
) xrruz3
WHERE xrruz3.trx_date = TO_CHAR (p_fecha_reporte,'ddmmyyyy') --'05022020'
;
r_main c_main%ROWTYPE;
CURSOR c_anulados (p_xx_tipo_cbte_uy IN VARCHAR2, p_report_date IN VARCHAR2) IS
SELECT decode (xrruz.module, 'AR', SUBSTR (xrruz.trx_number,8,8), xrruz.trx_number) trx_number
, status, trx_date, xrruz.xx_tipo_cbte_uy, xrruz.serie
FROM xx_rpt_rsm_uy_zz xrruz
WHERE
xrruz.xx_tipo_cbte_uy = to_number (p_xx_tipo_cbte_uy)
AND xrruz.trx_date = p_report_date
AND xrruz.org_id = fnd_global.org_id
ORDER BY 1
;
r_anulados c_anulados%ROWTYPE;
l_status VARCHAR2(15);
l_nro_incial VARCHAR2(31);
l_nro_final VARCHAR2(31);
l_anulados_node_cnt NUMBER := 0;
l_rgo_anulados_node_cnt NUMBER := 0;
l_rownum NUMBER := 0;
l_cod_suc VARCHAR2(15);
BEGIN
x_cnt :=0;
fnd_file.put_line(fnd_file.log,  ' p_fecha_reporte = '|| TO_CHAR (p_fecha_reporte, 'DDMMYYYY') );
insert into xx_rpt_rsm_uy_serie
select
trx_date, xx_tipo_cbte_uy ,
xrruz.serie
, MIN ( TO_NUMBER (SUBSTR (xrruz.trx_number,8,8)) ) nrodesde
, MAX ( TO_NUMBER (SUBSTR (xrruz.trx_number,8,8)) ) nrohasta
from xx_rpt_rsm_uy_zz xrruz
where xrruz.trx_date = TO_CHAR (p_fecha_reporte, 'DDMMYYYY')
and xrruz.org_id = fnd_global.org_id
group by trx_date, xx_tipo_cbte_uy  , xrruz.serie ;
/* UPDATE caratula */
OPEN c_caratula;
LOOP
FETCH c_caratula INTO r_caratula;
EXIT WHEN c_caratula%NOTFOUND;
xx_ws_common_uy_pub.updateNodeValue (p_doc, r_caratula.node_name, r_caratula.node_value);
IF r_caratula.node_name = 'ns1:CantComprobantes' THEN
x_cnt := To_Number ( r_caratula.node_value);
END IF;
END LOOP;
CLOSE c_caratula;
xx_ws_common_uy_pub.updateNodeValue (p_doc, 'ns1:RUCEmisor', p_rut);
IF x_cnt = 0 THEN

SELECT decode (fnd_global.org_id, 194, '6', '1') INTO l_cod_suc FROM dual;
xx_ws_common_uy_pub.updateNodeValue (p_doc, 'ns1:CantComprobantes' , '0');
xx_ws_common_uy_pub.updateNodeValue (p_doc, 'ns1:FechaResumen' , TO_CHAR (p_fecha_reporte,'RRRR-MM-DD'));
xx_ws_common_uy_pub.updateNodeValue (p_doc, 'ns1:SecEnvio' , p_seq);
xx_ws_common_uy_pub.updateNodeValue (p_doc, 'ns1:CodSuc' , l_cod_suc);
xx_ws_common_uy_pub.updateNodeValue (p_doc, 'ns1:TmstFirmaEnv' , TO_CHAR (SYSDATE, 'YYYY-MM-DD')||'T'||TO_CHAR(SYSDATE,'hh24:mi:ss')||'-03:00');
xx_ws_common_uy_pub.updateNodeValue (p_doc, 'ns1:Fecha' , TO_CHAR (p_fecha_reporte,'RRRR-MM-DD'));
ELSE
OPEN c_main;
LOOP
FETCH c_main INTO r_main;
EXIT WHEN c_main%NOTFOUND;
l_rownum := l_rownum +1;
fnd_file.put_line(fnd_file.log,  ' r_main.rpt_tag = '||r_main.rpt_tag);
fnd_file.put_line(fnd_file.log,  ' r_main.xx_tipo_cbte_uy = '||r_main.xx_tipo_cbte_uy);
xx_ws_common_uy_pub.insertNewNode (p_doc,'ns1:Reporte', 'ns1:'||r_main.rpt_tag, NULL, 1);
xx_ws_common_uy_pub.insertNewNode (p_doc,'ns1:'||r_main.rpt_tag,'ns1:TipoComp', r_main.xx_tipo_cbte_uy, 1);
xx_ws_common_uy_pub.insertNewNode (p_doc,'xmlns:ns1="http://cfe.dgi.gub.uy"', 'ns1:Reporte'||'/'||'ns1:'||r_main.rpt_tag, r_main.xmldata);
IF r_main.cnt_rech > 0 THEN
fnd_file.put_line(fnd_file.log,  'Hay rechazados : '||r_main.cnt_rech);
l_rgo_anulados_node_cnt := l_rgo_anulados_node_cnt +1;
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns1:RsmnData', 'ns1:RngDocsAnulados', NULL, l_rownum);
fnd_file.put_line(fnd_file.log,  'Anulados loop');
OPEN c_anulados (r_main.xx_tipo_cbte_uy, TO_CHAR (p_fecha_reporte, 'DDMMYYYY'));
LOOP
FETCH c_anulados  INTO r_anulados;
EXIT WHEN c_anulados%NOTFOUND;
l_status := r_anulados.status;
fnd_file.put_line(fnd_file.log,  'l_status = '||l_status);
IF l_status = 'BE' THEN
l_nro_incial := r_anulados.trx_number;
END IF;
WHILE (r_anulados.status = 'BE' AND l_status = r_anulados.status AND  c_anulados%FOUND )
LOOP
l_nro_final := r_anulados.trx_number;
FETCH c_anulados INTO r_anulados;
END LOOP;
IF l_status = 'BE' THEN
l_anulados_node_cnt := l_anulados_node_cnt +1;
fnd_file.put_line(fnd_file.log,  ' l_nro_incial = '||l_nro_incial);
fnd_file.put_line(fnd_file.log,  ' l_nro_final = '||l_nro_final);
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns1:RngDocsAnulados', 'ns1:RDA_Item', NULL, l_rgo_anulados_node_cnt);
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns1:RDA_Item',  'ns1:Serie', r_anulados.serie , l_anulados_node_cnt);
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns1:RDA_Item',  'ns1:NroDesde', l_nro_incial ,  l_anulados_node_cnt);
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns1:RDA_Item',  'ns1:NroHasta', l_nro_final , l_anulados_node_cnt);
END IF;
END LOOP;
--END IF;
CLOSE c_anulados;
END IF;
END LOOP;
CLOSE c_main;
END IF;
END;
/****************************************************************************
*                                                                          *
* Name    : reporte_diario                                                 *
* Purpose : Invocacion al servicio EFACRECEPCIONREPORTE para enviar        *
*            Reporte Diario a DGI UY                                       *
*                                                                          *
****************************************************************************/
PROCEDURE reporte_diario(
errbuf OUT VARCHAR2,
retcode OUT VARCHAR2,
p_fecha_reporte IN VARCHAR2) IS
CURSOR c_sin_cae (p_fecha_sobre IN VARCHAR2) IS
SELECT
xrruz.xx_tipo_cbte_uy,
xrruz.id_emisor
,xrruz.trx_number, rownum
FROM xx_rpt_rsm_uy_zz xrruz
WHERE
trx_date = p_fecha_sobre
AND xrruz.status NOT IN ('AE', 'BE')
AND xrruz.org_id = fnd_global.org_id
;
r_sin_cae c_sin_cae%ROWTYPE;
l_xmlType           XMLTYPE;
l_doc               dbms_xmldom.domdocument;
l_clob              CLOB;
l_report_name       VARCHAR2(255);
l_report_date       DATE;
l_ofilename         VARCHAR2(255);
l_bfileo                BFILE;
l_file_exists           NUMBER;
l_oXmlType              XMLTYPE;
l_oDoc                  dbms_xmldom.domdocument;
l_oclob                 CLOB;
x_status_code           VARCHAR2 (255);
x_error_code            VARCHAR2 (255);
x_error_dtl             VARCHAR2 (1023);
x_cnt_cfe               NUMBER := 0;
l_host_path             VARCHAR2(255);
e_sin_cae EXCEPTION;
e_sin_ui_rate EXCEPTION;
l_outputline     VARCHAR2(255);
l_seq            NUMBER;
l_rut                VARCHAR2(15);
l_cfe_cnt        NUMBER;
BEGIN
fnd_file.put_line(fnd_file.log, 'p_fecha_reporte = '||p_fecha_reporte);
-- obtengo directorio
SELECT NVL (MAX (directory_path),'X')  INTO l_host_path
FROM all_directories WHERE directory_name = 'XX_AR_FEUY_TEMPLATE';
IF l_host_path = 'X' THEN
raise_application_error(-10001, 'Directorio XX_AR_FEUY_TEMPLATE no definido');
END IF;
l_report_date := TO_DATE (p_fecha_reporte , 'YYYY/MM/DD HH24:MI:SS'); --2016/06/23 00:00:00
SELECT
NVL (MAX( hlad1.xx_ap_numero_iibb ) , 'X')
INTO l_rut
FROM  hr_locations_all             hl
, hr_locations_all1_dfv      hlad1
, hr_all_organization_units haou
WHERE   hl.rowid = hlad1.row_id
AND haou.location_id = hl.location_id
AND haou.organization_id = fnd_global.org_id;
IF l_rut = 'X' THEN
raise_application_error(-10001, 'Rut para UO no definido');
END IF;
l_report_name := 'rptduy_'||TO_CHAR(l_report_date,'DDMMYYYY')||'_'||fnd_global.org_id||'.xml';
fnd_file.put_line(fnd_file.log, 'p_fecha_reporte (2) = '||TO_CHAR(l_report_date,'DDMMYYYY'));
OPEN c_sin_cae (TO_CHAR(l_report_date,'DDMMYYYY'));
LOOP
FETCH  c_sin_cae  INTO r_sin_cae;
EXIT WHEN  c_sin_cae%NOTFOUND;
IF r_sin_cae.rownum = 1 THEN
fnd_file.put_line(fnd_file.output, 'REPORTE DIARIO '|| TO_CHAR(l_report_date,'DDMMYYYY')||' FINALIZO CON ERRORES');
fnd_file.put_line(fnd_file.output, '_______________________________');
fnd_file.put_line(fnd_file.output, '|Existen Transacciones SIN CAE |');
fnd_file.put_line(fnd_file.output, '_______________________________');
fnd_file.put_line(fnd_file.output, '|Tipo CFE |Numero CFE          |');
fnd_file.put_line(fnd_file.output, '-------------------------------');
END IF;
SELECT  '|'||RPad ( r_sin_cae.xx_tipo_cbte_uy,9)||'|'
||RPad (r_sin_cae.trx_number, 20)||'|'
INTO l_outputline
FROM DUAL;
fnd_file.put_line(fnd_file.output, l_outputline);
END LOOP;
CLOSE c_sin_cae;
IF r_sin_cae.rownum IS NOT NULL THEN
raise_application_error(-20001, 'Existen Transacciones SIN CAE');
END IF;
SELECT COUNT(1) INTO l_cfe_cnt
FROM -- bolinf.xx_ws_efactura_uy_zz zweuz
xx_rpt_rsm_uy_zz
WHERE trx_date = TO_CHAR (l_report_date, 'DDMMYYYY')
AND org_id = fnd_global.org_id
;
SELECT NVL (MAX (seq) + 1, 1)
INTO l_seq
FROM xx_ar_rpte_diario_uy WHERE fecha = l_report_date;
fnd_file.put_line(fnd_file.log, 'l_cfe_cnt = '||l_cfe_cnt);
--SELECT XMLTYPE(bfilename('XX_AR_FEUY_TEMPLATE', 'template_rpt.xml'), nls_charset_id('UTF8'))
SELECT XMLTYPE(bfilename('XX_AR_FEUY_TEMPLATE', Decode (l_cfe_cnt /*l_cpbte_cnt + l_eresg_cnt*/, 0, 'template_rpted_zero.xml', 'template_rpt.xml')), nls_charset_id('UTF8'))
INTO l_xmlType
FROM dual;
fnd_file.put_line(fnd_file.log, 'template loaded OK');
l_doc := dbms_xmldom.newdomdocument(l_xmlType);
fnd_file.put_line(fnd_file.log, 'xmldom OK');
actualizar_template_reporte (l_report_date,  TO_CHAR (l_seq), l_doc, x_cnt_cfe, l_rut);
fnd_file.put_line(fnd_file.log, 'actualizar_template_reporte OK');
--IF x_cnt_cfe > 0 THEN
dbms_lob.createtemporary(l_clob, true);
dbms_xmldom.writetoclob(l_doc, l_clob, 'ISO-8859-1');
fnd_file.put_line(fnd_file.log, 'writetoclobe OK');
xx_ws_common_uy_pub.genera_attachment (TO_CHAR(l_report_date,'DDMMYYYY'),l_clob, l_report_name, 'XX_AR_RPTE_DIARIO_UY', 'MISC');
dbms_xslprocessor.clob2file(l_clob, 'XX_AR_FEUY_TEMPLATE', l_report_name);
dbms_lob.freetemporary (l_clob);
l_ofilename := 'ACK_'||l_report_name;
fnd_file.put_line(fnd_file.log, 'cd '||l_host_path||';./efacturaws_uy_host EFACRECEPCIONREPORTE '||l_report_name||' '||l_ofilename||' '||l_rut);
host_command (p_command =>  'cd '||l_host_path||';./efacturaws_uy_host EFACRECEPCIONREPORTE '||l_report_name||' '||l_ofilename||' '||l_rut);
l_bfileo := bfilename('XX_AR_FEUY_TEMPLATE', l_ofilename);
l_file_exists := dbms_lob.fileexists (l_bfileo);
IF l_file_exists = 1 THEN
fnd_file.put_line(fnd_file.log, l_ofilename ||' file exists ');
SELECT XMLTYPE(l_bfileo, nls_charset_id('UTF8'))
INTO l_oXmlType
FROM dual;
l_oDoc := dbms_xmldom.newdomdocument(l_oXmlType);
actualizar_rta ( l_oDoc, x_status_code,x_error_code,x_error_dtl );
fnd_file.put_line(fnd_file.log, ' x_status_code = '||x_status_code);
fnd_file.put_line(fnd_file.log, ' x_error_dtl = '||x_error_dtl);
fnd_file.put_line(fnd_file.log, ' x_cnt_cfe = '||x_cnt_cfe);
dbms_lob.createtemporary(l_oclob, true);
dbms_xmldom.writetoclob(l_oDoc, l_oclob, 'ISO-8859-1');
xx_ws_common_uy_pub.genera_attachment (TO_CHAR(l_report_date,'DDMMYYYY'),l_oclob, l_ofilename, 'XX_AR_RPTE_DIARIO_UY', 'MISC');
dbms_lob.freetemporary (l_oclob);
fnd_file.put_line(fnd_file.log, 'xx_ws_common_uy_pub.genera_attachment OK');
ELSE
x_status_code := 'E';
x_error_dtl := 'Error al invocar WS';
END IF;  -- IF l_file_exists = 1 THEN
--ELSE
--  x_status_code := 'E';
--  x_error_dtl := 'No existen CFEs para informar ';
--END IF; -- IF x_cnt_cfe > 0 THEN
UPDATE
bolinf.xx_ar_rpte_diario_uy SET seq = DECODE (x_status_code, 'AR', seq + 1, seq), status =x_status_code, error_msg= SubStr (x_error_dtl,1,145)  , cnt_cfe = Nvl(x_cnt_cfe,0)
WHERE TO_CHAR(fecha,'DDMMYYYY') = TO_CHAR(l_report_date,'DDMMYYYY') AND ORG_ID = fnd_global.org_id;
fnd_file.put_line(fnd_file.log, 'update OK');
IF SQL%ROWCOUNT=0 AND x_status_code = 'AR' THEN
INSERT INTO bolinf.xx_ar_rpte_diario_uy (fecha, seq, status, error_msg, cnt_cfe, org_id) VALUES (l_report_date, 1,x_status_code,x_error_dtl,Nvl(x_cnt_cfe,0), fnd_global.org_id );
fnd_file.put_line(fnd_file.log, 'insert OK');
END IF;
IF x_status_code = 'AR' THEN
fnd_file.put_line(fnd_file.output, 'REPORTE DIARIO '|| TO_CHAR(l_report_date,'DDMMYYYY')||' PROCESADO SATISFACTORIAMENTE');
ELSE
retcode := '1';
fnd_file.put_line(fnd_file.output, 'REPORTE DIARIO '|| TO_CHAR(l_report_date,'DDMMYYYY')||' FINALIZO CON ERRORES');
fnd_file.put_line(fnd_file.output, 'Mensaje de error : '||x_error_dtl);
END IF;
EXCEPTION WHEN e_sin_cae THEN
retcode := '1';
WHEN e_sin_ui_rate THEN
fnd_file.put_line(fnd_file.output, 'No esta definida la unidad indexada  ');
retcode := '1';
WHEN OTHERS THEN
fnd_file.put_line(fnd_file.Log, 'error  :' ||SubStr (SQLERRM, 1, 1023));
retcode := '1';
END reporte_diario;
END XX_WS_EFACTURAURU3_PUB;