create or replace PACKAGE BODY        "XX_WS_EFACTURAURU2_PUB" AS
PROCEDURE actualizar_nodos (p_check_id  IN ap_checks_all.check_id%TYPE, p_doc dbms_xmldom.domdocument
, p_anulacion IN VARCHAR2 DEFAULT 'N'
) IS
CURSOR c_idDoc (p_check_id IN NUMBER ) IS
WITH nums AS (SELECT ROWNUM rn FROM (SELECT 1, 2,3 FROM dual GROUP BY CUBE (1, 2 ,3)) WHERE ROWNUM <= 4)
SELECT node_name, node_value FROM
(SELECT DECODE(rn, 1, 'ns0:TipoCFE', 2, 'ns0:Serie', 3, 'ns0:Nro', 4, 'ns0:FchEmis' ) node_name,
DECODE(rn, 1, tipo_cbte_uy, 2, serie, 3, nro, 4, fechae  ) node_value
FROM
(
SELECT
xwet.nro_constancia
, NVL (xwet.ultimo_nro, xwet.nro_inicial -1) + 1 nro
--, LPAD(  NVL (xwet.ultimo_nro, xwet.nro_inicial -1) + 1 ,8, '0')  ultimo_nro
, xwet.serie
,  abaad.xx_ap_pago_eresg tipo_cbte_uy
, TO_CHAR (aca.check_date,'RRRR-MM-DD') fechae
FROM ap_checks_all aca
--r11, ap_bank_accounts_all abaa
--r11, ap_bank_accounts_all_dfv  abaad
/*r12*/,  ce_bank_accounts abaa
/*r12*/,  ce_bank_accounts_dfv  abaad
, xx_ws_efactura_talonario xwet
, CE_BANK_ACCT_USES_ALL cbaua
WHERE
aca.CE_BANK_ACCT_USE_ID = cbaua.BANK_ACCT_USE_ID
AND cbaua.bank_account_id  = abaa.bank_account_id
AND aca.check_id = p_check_id
--AND aca.CE_BANK_ACCT_USE_ID /* aca.bank_account_id r12*/ = abaa.bank_account_id
AND abaad.row_id =  abaa.ROWID
AND xwet.tipo_cbte =  abaad.xx_ap_pago_eresg
AND xwet.estado = 'A'
AND SYSDATE BETWEEN xwet.fecha_emision AND xwet.fecha_vto
AND NVL (xwet.ultimo_nro, 0) < xwet.nro_final
) qrya
, nums)
;
r_IdDoc  c_IdDoc%ROWTYPE;
CURSOR c_emisor IS
WITH nums AS (
SELECT ROWNUM rn FROM (SELECT 1, 2, 3 FROM dual GROUP BY CUBE (1, 2, 3)) WHERE ROWNUM <= 6)
SELECT node_name, node_value FROM
(SELECT DECODE(rn, 1, 'ns0:RUCEmisor', 2, 'ns0:RznSoc', 3, 'ns0:CdgDGISucur', 4, 'ns0:DomFiscal', 5, 'ns0:Ciudad', 6, 'ns0:Departamento') node_name,
DECODE(rn, 1, xx_ap_numero_iibb, 2, company_name, 3, decode ( qrya.xx_ap_numero_iibb, '214947790015', '6', '1') , 4, address_line_1, 5, city, 6, province  ) node_value
FROM
(
/* r11
SELECT  hlad2.company_name   , hlad.address_line_1, hlad.city , hlad.province  , hlad1.xx_ap_numero_iibb
FROM hr_locations_all hl
, hr_locations_all2_dfv hlad2
, hr_locations_all1_dfv hlad1
, hr_locations_all_dfv hlad
, hr_all_organization_units haou
, ap_checks_all aca
WHERE  hl.rowid = hlad.row_id
AND  hl.rowid = hlad1.row_id
AND  hl.rowid = hlad2.row_id
AND haou.location_id = hl.location_id
AND haou.organization_id = aca.org_id
AND aca.check_id = p_check_id
*/
/* r12 >>>> */
SELECT hlad2.company_name   , hlad.address_line_1, hg.geography_name province , hg2.geography_name city, hlad1.xx_ap_numero_iibb
FROM hr_locations_all             hl
, hr_locations_all2_dfv      hlad2
, hr_locations_all1_dfv      hlad1
, hr_locations_all_dfv        hlad
, hr_all_organization_units haou
, hz_geographies hg
, hz_geographies hg2
, ap_checks_all aca
WHERE  hl.rowid = hlad.row_id
AND  hl.rowid = hlad1.row_id
AND  hl.rowid = hlad2.row_id
AND haou.location_id = hl.location_id
AND hg.geography_type = 'PROVINCE' AND hg.country_code = 'UY' AND SYSDATE BETWEEN hg.start_date AND hg.end_date
AND hg2.geography_type = 'CITY' AND hg2.country_code = 'UY' AND SYSDATE BETWEEN hg2.start_date AND hg2.end_date
AND hg2.geography_element2 = hg.geography_name
AND hg.geography_code =  hlad.DEPARTAMENTO
AND hg2.geography_code =  hlad.LOCALIDAD
AND haou.organization_id = aca.org_id
AND aca.check_id = p_check_id
) qrya
, nums);
r_emnisor c_emisor%ROWTYPE;
CURSOR c_receptor IS
WITH nums AS (
SELECT ROWNUM rn FROM (SELECT 1,2,3 FROM dual GROUP BY CUBE (1, 2,3)) WHERE ROWNUM <= 8)
SELECT node_name, node_value FROM
(SELECT DECODE(rn, 1, 'ns0:TipoDocRecep', 2, 'ns0:CodPaisRecep', 3, 'ns0:DocRecep', 4, 'ns0:RznSocRecep', 5, 'ns0:DirRecep', 6, 'ns0:CiudadRecep', 7, 'ns0:DeptoRecep', 8, 'ns0:PaisRecep') node_name,
DECODE(rn, 1, xx_dgi_tipo_doc_fe, 2, cod_pais, 3, vat_registration_num, 4, vendor_name, 5, address1, 6, city, 7, state, 8, description ) node_value
FROM
(
SELECT
aca.vendor_id ,  ffv.xx_dgi_tipo_doc_fe   , xapfe.cod_pais , pv.vendor_name, pv.vat_registration_num, pvs.ADDRESS_LINE1  address1, Nvl (pvs.CITY, pvs.county)  city, pvs.state , xapfe.description
FROM
ap_checks_all aca
, po_vendors pv
, po_vendors_dfv pvd
, /* po_vendor_sites  r12 */ po_vendor_sites_all pvs
,
(
select ffvd.xx_dgi_tipo_doc_fe, ffv.flex_value from fnd_flex_value_sets ffvs, fnd_flex_values ffv,fnd_flex_values_dfv ffvd
where ffvs.flex_value_set_name = 'XX_AP_RUT_URUGUAY'
and ffvs.flex_value_set_id = ffv.flex_value_set_id
and ffv.rowid = ffvd.row_id
) ffv
,
(SELECT NVL (flvd.xx_uy_cod_iso3166, fl.lookup_code) cod_pais , fl.description , fl.lookup_code FROM fnd_lookups fl , fnd_lookup_values_dfv flvd WHERE lookup_type = 'XX_AR_PAIS_FACTURA_ELECTRONICA'
AND flvd.row_id = fl.ROWID
)
xapfe
WHERE
aca.check_id = p_check_id
AND aca.vendor_id =  pv.vendor_id
AND pv.ROWID = pvd.row_id
AND ffv.flex_value = pvd.xx_ap_identificacion_fiscal
AND pvs.vendor_id = pv.vendor_id
AND pvs.vendor_site_id = aca.vendor_site_id
--AND xapfe.lookup_code = pvs.country
AND xapfe.lookup_code = nvl(pvd.xx_ap_pais,'UY')
) qrya
, nums);
r_receptor c_receptor%ROWTYPE;
CURSOR c_totales IS
SELECT 'ns0:TpoMoneda' node_name , 'UYU' /* aca.currency_code */ node_value--TpoMoneda
FROM ap_checks_all aca WHERE  aca.check_id = p_check_id
/*
UNION ALL
SELECT 'ns0:TpoCambio' node_name , NVL (TO_CHAR (Nvl(exchange_rate,0), '999999999.99'),'1') node_value--TpoMoneda
FROM ap_checks_all aca WHERE  aca.check_id = p_check_id
*/
UNION ALL
SELECT 'ns0:MntTotRetenido' node_name , q.amount node_value--TpoMoneda
FROM
(
SELECT
TRIM (TO_CHAR (NVL (
--ABS (
--SUM ( aida.base_amount * (-1))* Nvl (aida.exchange_rate,1)  )
SUM ( decode (p_anulacion, 'Y', NVL(aida.base_amount, aida.amount) *(-1)   , NVL(aida.base_amount, aida.amount) *(-1) ))
--)
,0), '999999999.99') )
amount
FROM ap_invoice_payments_all aipa
,  ap_invoice_distributions_all aida
WHERE aipa.check_id = p_check_id
AND aida.awt_invoice_payment_id = aipa.invoice_payment_id
/*20181024 */
AND (
(p_anulacion = 'Y'  AND aipa.reversal_flag = 'Y' AND aipa.reversal_inv_pmt_id IS NOT NULL )
OR
(p_anulacion= 'N' AND aipa.reversal_inv_pmt_id IS  NULL )
)
/*20181024 */
) q
UNION ALL
SELECT 'ns0:CantLinDet' node_name , NVL (TO_CHAR (q.cnt, '999999'),'1') node_value--TpoMoneda
FROM
(
/*
SELECT COUNT (DISTINCT aida.tax_code_id)  cnt
FROM ap_invoice_payments_all aipa
,  ap_invoice_distributions_all aida
WHERE aipa.check_id = p_check_id
AND aida.awt_invoice_payment_id = aipa.invoice_payment_id
AND aida.amount != 0
*/
SELECT COUNT (aipa.invoice_id)  cnt
FROM ap_invoice_payments_all aipa
WHERE aipa.check_id = p_check_id
AND EXISTS (SELECT 1 FROM ap_invoice_distributions_all aida
WHERE aida.awt_invoice_payment_id = aipa.invoice_payment_id
AND aida.amount != 0
)
/*20181024 */
AND (
(p_anulacion = 'Y'  AND aipa.reversal_flag = 'Y' AND aipa.reversal_inv_pmt_id IS NOT NULL )
OR
(p_anulacion= 'N' AND aipa.reversal_inv_pmt_id IS  NULL )
)
/*20181024 */
) q
;
r_totales c_totales%ROWTYPE;
CURSOR c_totales_perc (p_cod_ret IN VARCHAR2)  IS
WITH nums AS (
SELECT ROWNUM rn FROM (SELECT 1, 2 FROM dual GROUP BY CUBE (1, 2)) WHERE ROWNUM <= 2)
SELECT node_name, node_value FROM
(SELECT DECODE(rn, 1, 'ns0:CodRet', 2, 'ns0:ValRetPerc') node_name,
DECODE(rn, 1, cod_ret, 2, amount ) node_value
FROM
(
SELECT jzaat.dgi_tax_type_code|| /* atcad.dgi_tax_regime_code r12 */atcad.TAX_AUTHORITY_CATEGORY cod_ret
, TRIM ( TO_CHAR (
-- ABS (
--SUM ((aida.amount * (-1) ) * Nvl (aida.exchange_rate,1) )
SUM ( decode (p_anulacion, 'Y', NVL(aida.base_amount, aida.amount) * (-1), NVL(aida.base_amount, aida.amount)* (-1) ))
--)
, '999999999.99') ) amount
FROM
ap_invoice_payments_all aipa
,  ap_invoice_distributions_all aida
, ap_tax_codes_all atca
, ap_tax_codes_all1_dfv atcad
, jl_zz_ap_awt_types jzaat
, ap_awt_tax_rates_all aatra
WHERE aipa.check_id = p_check_id
--AND aipa.invoice_id = p_invoice_id
AND aida.awt_invoice_payment_id = aipa.invoice_payment_id
/* AND atca.tax_id = aida.tax_code_id r12*/
AND atca.name = aatra.tax_name /* r12*/
AND aatra.tax_rate_id = aida.awt_tax_rate_id /* r12*/
AND atca.org_id = aatra.org_id /* r12*/
AND aida.org_id = aatra.org_id /* r12*/
AND atca.rowid = atcad.row_id
AND jzaat.awt_type_code =  /* atcad.dgi_transaction_code r12 */ atcad.WITHHOLDING_TYPE
AND  aida.amount != 0
AND jzaat.dgi_tax_type_code|| /* atcad.dgi_tax_regime_code r12 */atcad.TAX_AUTHORITY_CATEGORY =  p_cod_ret
/*20181024 */
AND (
(p_anulacion = 'Y'  AND aipa.reversal_flag = 'Y' AND aipa.reversal_inv_pmt_id IS NOT NULL )
OR
(p_anulacion= 'N' AND aipa.reversal_inv_pmt_id IS  NULL )
)
/*20181024 */
GROUP BY jzaat.dgi_tax_type_code|| /* atcad.dgi_tax_regime_code r12 */atcad.TAX_AUTHORITY_CATEGORY
) qrya
, nums)
;
r_totales_perc c_totales_perc%ROWTYPE;
CURSOR c_taxes IS
SELECT
DISTINCT jzaat.dgi_tax_type_code|| /* atcad.dgi_tax_regime_code r12 */atcad.TAX_AUTHORITY_CATEGORY cod_ret
FROM
ap_invoice_payments_all aipa
,  ap_invoice_distributions_all aida
, ap_tax_codes_all atca
, ap_tax_codes_all1_dfv atcad
, jl_zz_ap_awt_types jzaat
, ap_awt_tax_rates_all aatra /*r12*/
WHERE
aipa.check_id = p_check_id
AND aida.awt_invoice_payment_id = aipa.invoice_payment_id
/* AND atca.tax_id = aida.tax_code_id r12*/
AND atca.name = aatra.tax_name /*r12*/
AND aatra.tax_rate_id = aida.awt_tax_rate_id /*r12*/
AND atca.org_id = aatra.org_id /* r12 */
AND aida.org_id = aatra.org_id /* r12 */
AND atca.rowid = atcad.row_id
AND jzaat.awt_type_code =  /* atcad.dgi_transaction_code r12 */ atcad.WITHHOLDING_TYPE
AND  aida.amount != 0
/*20181024 */
AND (
(p_anulacion = 'Y'  AND aipa.reversal_flag = 'Y' AND aipa.reversal_inv_pmt_id IS NOT NULL )
OR
(p_anulacion= 'N' AND aipa.reversal_inv_pmt_id IS  NULL )
)
/*20181024 */
;
r_taxes c_taxes%ROWTYPE;
CURSOR c_invoice_taxes (p_invoice_id IN NUMBER) IS
SELECT
DISTINCT aida.awt_tax_rate_id tax_id /* r12 atca.tax_id */
FROM
ap_invoice_payments_all aipa
,  ap_invoice_distributions_all aida
, ap_tax_codes_all atca
, ap_awt_tax_rates_all aatra /* r12 */
WHERE
aipa.check_id = p_check_id
AND aida.awt_invoice_payment_id = aipa.invoice_payment_id
AND aipa.invoice_id = p_invoice_id
/* AND atca.tax_id = aida.tax_code_id r12*/
AND atca.name = aatra.tax_name /*r12*/
AND aatra.tax_rate_id = aida.awt_tax_rate_id /*r12*/
AND atca.org_id = aatra.org_id /* r12 */
AND aida.org_id = aatra.org_id /* r12 */
AND  aida.amount != 0
/*20181024 */
AND (
(p_anulacion = 'Y'  AND aipa.reversal_flag = 'Y' AND aipa.reversal_inv_pmt_id IS NOT NULL )
OR
(p_anulacion= 'N' AND aipa.reversal_inv_pmt_id IS  NULL )
)
/*20181024 */
;
r_invoice_taxes  c_invoice_taxes%ROWTYPE;
CURSOR c_items (p_invoice_id IN NUMBER, p_tax_id IN NUMBER) IS
WITH nums AS (
SELECT ROWNUM rn FROM (SELECT 1, 2, 3 FROM dual GROUP BY CUBE (1, 2, 3)) WHERE ROWNUM <= 4)
SELECT node_name, node_value FROM
(SELECT DECODE(rn, 1, 'ns0:CodRet', 2, 'ns0:Tasa', 3, 'ns0:MntSujetoaRet', 4, 'ns0:ValRetPerc') node_name,
DECODE(rn, 1,  cod_ret, 2, tax_rate, 3, awt_gross_amount, 4, amount ) node_value
FROM
(
SELECT jzaat.dgi_tax_type_code || /* atcad.dgi_tax_regime_code r12 */atcad.TAX_AUTHORITY_CATEGORY cod_ret, To_Char  (aatra.tax_rate, '99.99') tax_rate
,  TRIM ( TO_CHAR (
ABS (
SUM (aida.awt_gross_amount * Nvl (aipa.exchange_rate,1) )
)
, '999999999.99') )   awt_gross_amount
,  TRIM ( TO_CHAR (
ABS (
-- Sum (aida.amount * Nvl (aida.exchange_rate,1) )
SUM ( NVL(aida.base_amount, aida.amount) )
)
, '999999999.99') )   amount
--, aida.*
FROM
ap_invoice_payments_all aipa
,  ap_invoice_distributions_all aida
, ap_tax_codes_all atca
, ap_tax_codes_all1_dfv atcad
, jl_zz_ap_awt_types jzaat
, ap_awt_tax_rates_all aatra /* r12 */
WHERE aipa.check_id = p_check_id
AND aipa.invoice_id = p_invoice_id
/*AND atca.tax_id = p_tax_id r12 */
AND aida.awt_invoice_payment_id = aipa.invoice_payment_id
/*AND atca.tax_id = aida.tax_code_id r12 */
AND atca.rowid = atcad.row_id
AND jzaat.awt_type_code =  /* atcad.dgi_transaction_code r12 */ atcad.WITHHOLDING_TYPE
AND aatra.tax_name =  atca.name /* r12 */
AND atca.org_id = aatra.org_id /* r12 */
AND aida.org_id = aatra.org_id /* r12 */
AND aida.awt_tax_rate_id = p_tax_id /* r12 */
AND aatra.tax_rate_id = aida.awt_tax_rate_id
AND  aida.amount != 0
/*20181024 */
AND (
(p_anulacion = 'Y'  AND aipa.reversal_flag = 'Y' AND aipa.reversal_inv_pmt_id IS NOT NULL )
OR
(p_anulacion= 'N' AND aipa.reversal_inv_pmt_id IS  NULL )
)
/*20181024 */
GROUP BY jzaat.dgi_tax_type_code || /* atcad.dgi_tax_regime_code r12 */atcad.TAX_AUTHORITY_CATEGORY, To_Char  (aatra.tax_rate, '99.99')
) qrya
, nums)
;
r_items c_items%ROWTYPE;
l_item_nmb NUMBER;
CURSOR c_invoices IS
SELECT aida.invoice_id, Sum (1) tot_perc, Sum (
CASE
WHEN decode (p_anulacion, 'Y', aida.amount  * (-1), aida.amount * (-1) ) < 0 THEN 1
--WHEN decode (p_anulacion, 'Y', aida.amount  * (-1) , aida.amount  ) < 0 THEN 1
ELSE
0
END
) has_negative
FROM ap_invoice_payments_all aipa, ap_invoice_distributions_all aida
WHERE aipa.check_id = p_check_id
AND  aida.awt_invoice_payment_id = aipa.invoice_payment_id  AND  aida.amount != 0
/*20181024 */
AND (
(p_anulacion = 'Y'  AND aipa.reversal_flag = 'Y' AND aipa.reversal_inv_pmt_id IS NOT NULL )
OR
(p_anulacion= 'N' AND aipa.reversal_inv_pmt_id IS  NULL )
)
/*20181024 */
GROUP BY aida.invoice_id
ORDER BY invoice_id
;
r_invoices c_invoices%ROWTYPE;
CURSOR c_invoices2 IS
SELECT aipa.invoice_id FROM ap_invoice_payments_all aipa
, ap_invoices_all aia
, ap_invoices_all2_dfv  aiad
, (SELECT lookup_code FROM fnd_lookup_values_vl WHERE lookup_type = 'XX_AR_TIPO_CBTE_UY')  flvv
WHERE aipa.check_id = p_check_id
AND aia.invoice_id = aipa.invoice_id
AND aiad.tax_authority_transaction_type = flvv.lookup_code
AND aiad.row_id = aia.ROWID
AND EXISTS (SELECT 1 FROM ap_invoice_distributions_all aida WHERE  aida.awt_invoice_payment_id = aipa.invoice_payment_id  AND  aida.amount != 0)
/*20181024 */
AND (
(p_anulacion = 'Y'  AND aipa.reversal_flag = 'Y' AND aipa.reversal_inv_pmt_id IS NOT NULL )
OR
(p_anulacion= 'N' AND aipa.reversal_inv_pmt_id IS  NULL )
)
/*20181024 */
ORDER BY invoice_id
;
r_invoices2 c_invoices2%ROWTYPE;
CURSOR c_ref (p_invoice_id IN NUMBER) IS
WITH nums AS (
SELECT ROWNUM rn FROM (SELECT 1, 2, 3 FROM dual GROUP BY CUBE (1, 2, 3)) WHERE ROWNUM <= 3)
SELECT node_name, node_value FROM
(SELECT DECODE(rn, 1,  'ns0:TpoDocRef'  , 2, 'ns0:Serie', 3, 'ns0:NroCFERef') node_name,
DECODE(rn, 1, tax_authority_transaction_type, 2, transaction_letter, 3,   NroCFERef) node_value
FROM
(
SELECT DISTINCT aiad.tax_authority_transaction_type , aiad.transaction_letter , SUBSTR ( aia.invoice_num ,7,8) NroCFERef
FROM
ap_invoice_payments_all aipa
, ap_invoices_all aia
, ap_invoices_all2_dfv  aiad
, (SELECT lookup_code FROM fnd_lookup_values_vl WHERE lookup_type = 'XX_AR_TIPO_CBTE_UY')  flvv
WHERE aipa.check_id = p_check_id
AND aipa.invoice_id = p_invoice_id
AND aia.invoice_id = aipa.invoice_id
AND aiad.tax_authority_transaction_type = flvv.lookup_code
AND aiad.row_id = aia.ROWID
/*20181024 */
AND (
(p_anulacion = 'Y'  AND aipa.reversal_flag = 'Y' AND aipa.reversal_inv_pmt_id IS NOT NULL )
OR
(p_anulacion= 'N' AND aipa.reversal_inv_pmt_id IS  NULL )
)
/*20181024 */
) qrya
, nums)
;
r_ref c_ref%ROWTYPE;
CURSOR c_ref2 IS
SELECT DISTINCT
'ns0:RazonRef'  node_name
, 'Documento Nro. '||  aiad.transaction_letter ||'-'|| TO_CHAR (SUBSTR ( aia.invoice_num ,6,8))   node_value
FROM
ap_invoice_payments_all aipa
, ap_invoices_all aia
, ap_invoices_all2_dfv  aiad
WHERE aipa.check_id = p_check_id
AND aia.invoice_id = aipa.invoice_id
AND aiad.row_id = aia.ROWID
AND NOT EXISTS (SELECT 1
FROM  fnd_lookup_values_vl flvv WHERE flvv.lookup_type = 'XX_AR_TIPO_CBTE_UY'
AND aiad.tax_authority_transaction_type = flvv.lookup_code
);
r_ref2 c_ref2%ROWTYPE;
l_nroLineaRef NUMBER := 0;
CURSOR
c_TmstFirma IS
SELECT 'ns0:TmstFirma' node_name,  REPLACE (TO_CHAR (sysdate,'RRRR-MM-DD HH24:MI:SS'),' ', 'T')||'-03:00'  node_value
FROM dual;
r_tmpstfirma c_TmstFirma%ROWTYPE;
l_tpo_moneda VARCHAR2(15) := 'XXX';
CURSOR
c_referencias IS
WITH nums AS (SELECT ROWNUM rn
FROM (SELECT 1, 2, 3
FROM dual
GROUP BY CUBE (1, 2, 3))
WHERE ROWNUM <= 5)
SELECT node_name
, node_value
FROM (SELECT DECODE(rn, 1, 'ns0:NroLinRef', 2, 'ns0:TpoDocRef', 3, 'ns0:Serie', 4, 'ns0:NroCFERef', 5, 'ns0:FechaCFEref') node_name,
DECODE(rn, 1, p_refNum, 2, TpoDocRef, 3, Serie, 4, NroCFERef, 5, FechaCFEref ) node_value
FROM  (
SELECT
'1' p_refNum
, abaad.xx_ap_pago_eresg  TpoDocRef
, xwet.serie Serie
, acad.xx_ap_eresguy_nro NroCFERef
-- , acad.xx_ap_eresguy_status
, TO_CHAR (to_date (acad.xx_ap_eresguy_fecha_sobre, 'DDMMYYYY'), 'RRRR-MM-DD')   FechaCFEref
FROM ap_checks_all aca
, ap_checks_all_dfv acad
--r11, ap_bank_accounts_all abaa
--r11, ap_bank_accounts_all_dfv  abaad
/*r12*/,  ce_bank_accounts abaa
/*r12*/,  ce_bank_accounts_dfv  abaad
, xx_ws_efactura_talonario xwet
, CE_BANK_ACCT_USES_ALL cbaua
WHERE
aca.CE_BANK_ACCT_USE_ID = cbaua.BANK_ACCT_USE_ID
AND cbaua.bank_account_id  = abaa.bank_account_id
--    WHERE
--  1 = 1
AND aca.check_id = p_check_id --4591071
-- AND aca.CE_BANK_ACCT_USE_ID /* aca.bank_account_id r12*/ = abaa.bank_account_id
AND abaad.row_id =  abaa.ROWID
AND acad.row_id = aca.rowid
AND xwet.tipo_cbte =  abaad.xx_ap_pago_eresg
AND acad.xx_ap_eresguy_nro BETWEEN xwet.nro_inicial AND xwet.nro_final
AND to_date (acad.xx_ap_eresguy_fecha_sobre, 'DDMMYYYY') BETWEEN xwet.fecha_emision AND xwet.fecha_vto
)   qrya
, nums)   ;
r_referencias c_referencias%ROWTYPE;
l_taxes_cnt NUMBER;
l_invoice_taxes_cnt NUMBER;
l_tipodocrecep VARCHAR2(15);
BEGIN
OPEN c_TmstFirma;
LOOP
FETCH c_TmstFirma INTO r_tmpstfirma;
EXIT WHEN c_TmstFirma%NOTFOUND;
xx_ws_common_uy_pub.updateNodeValue (p_doc, r_tmpstfirma.node_name, r_tmpstfirma.node_value);
END LOOP;
CLOSE c_TmstFirma;
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'actualizar_nodos c_IdDoc');
/* UPDATE idDoc */
OPEN c_IdDoc (p_check_id);
LOOP
FETCH c_IdDoc INTO r_IdDoc;
EXIT WHEN c_IdDoc%NOTFOUND;
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:IdDoc', r_IdDoc.node_name, r_IdDoc.node_value, 1);
END LOOP;
CLOSE c_IdDoc;
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'actualizar_nodos c_emisor');
/* UPDATE EMISOR */
OPEN c_emisor;
LOOP
FETCH c_emisor INTO r_emnisor;
EXIT WHEN c_emisor%NOTFOUND;
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:Emisor', r_emnisor.node_name, r_emnisor.node_value, 1);
END LOOP;
CLOSE c_emisor;
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'actualizar_nodos c_receptor');
/* UPDATE RECEPTOR */
OPEN c_receptor;
LOOP
FETCH c_receptor INTO r_receptor;
EXIT WHEN c_receptor%NOTFOUND;
IF  r_receptor.node_name = 'ns0:TipoDocRecep' THEN
l_tipodocrecep :=  r_receptor.node_value;
END IF;
IF r_receptor.node_name = 'ns0:DocRecep' AND  l_tipodocrecep IN ('4', '5', '6') THEN
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:Receptor', 'ns0:DocRecepExt', r_receptor.node_value, 1);
ELSIF r_receptor.node_name = 'ns0:PaisRecep' AND  l_tipodocrecep NOT IN ('4', '5', '6') THEN
NULL;
ELSE
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:Receptor', r_receptor.node_name, r_receptor.node_value, 1);
END IF;
--xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:Receptor', r_receptor.node_name, r_receptor.node_value, 1);
END LOOP;
CLOSE c_receptor;
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'actualizar_nodos c_totales');
/* UPDATE totales */
OPEN c_totales;
LOOP
FETCH c_totales INTO r_totales;
EXIT WHEN c_totales%NOTFOUND;
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => ' r_totales.node_value = '||r_totales.node_value);
IF r_totales.node_name = 'ns0:TpoMoneda' -- AND r_totales.node_value != 'UYU'
THEN
l_tpo_moneda := r_totales.node_value;
END IF;
IF  r_totales.node_name = 'ns0:TpoCambio' AND l_tpo_moneda = 'UYU' THEN
NULL;
ELSE
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:Totales', r_totales.node_name, r_totales.node_value, 1);
END IF;
END LOOP;
CLOSE c_totales;
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'actualizar_nodos c_totales_perc');
/* UPDATE totales perc */
l_taxes_cnt := 0;
OPEN c_taxes;
LOOP
FETCH c_taxes INTO r_taxes;
EXIT WHEN c_taxes%NOTFOUND;
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:Totales', 'ns0:RetencPercep',NULL,1);
l_taxes_cnt := l_taxes_cnt + 1;
OPEN c_totales_perc (r_taxes.cod_ret);
LOOP
FETCH c_totales_perc INTO r_totales_perc;
EXIT WHEN c_totales_perc%NOTFOUND;
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => ' r_totales_perc.node_name = '||r_totales_perc.node_name);
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => ' r_totales_perc.node_value = '||r_totales_perc.node_value);
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:RetencPercep', r_totales_perc.node_name, r_totales_perc.node_value, l_taxes_cnt);
END LOOP;
CLOSE c_totales_perc;
END LOOP;
CLOSE c_taxes;
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'actualizar_nodos c_items ');
l_item_nmb := 0;
l_invoice_taxes_cnt := 0;
OPEN c_invoices;
LOOP
FETCH c_invoices INTO r_invoices;
EXIT WHEN c_invoices%NOTFOUND;
l_item_nmb := l_item_nmb +1;
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => ' c_items r_invoices.invoice_id = '|| r_invoices.invoice_id);
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:Detalle', 'ns0:Item',NULL, 1);
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:Item', 'ns0:NroLinDet', To_Char (l_item_nmb), l_item_nmb);
IF r_invoices.has_negative > 0 THEN
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:Item', 'ns0:IndFact', '9', l_item_nmb);
END IF;
OPEN c_invoice_taxes (r_invoices.invoice_id);
LOOP
FETCH c_invoice_taxes  INTO r_invoice_taxes;
EXIT WHEN c_invoice_taxes%NOTFOUND;
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => ' c_items r_invoice_taxes.tax_id = '|| r_invoice_taxes.tax_id);
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:Item', 'ns0:RetencPercep', NULL, l_item_nmb);
l_invoice_taxes_cnt := l_invoice_taxes_cnt + 1;
/* UPDATE ITEMS */
OPEN c_items (r_invoices.invoice_id, r_invoice_taxes.tax_id);
LOOP
FETCH c_items INTO r_items;
EXIT WHEN c_items%NOTFOUND;
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:RetencPercep', r_items.node_name, r_items.node_value, l_taxes_cnt + l_invoice_taxes_cnt);
END LOOP;
CLOSE c_items;
--l_invoice_taxes_cnt := l_invoice_taxes_cnt + 1;
END LOOP;
CLOSE c_invoice_taxes;
END LOOP;
CLOSE c_invoices;
/* UPDATE totales perc */
IF p_anulacion = 'Y' THEN
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'anulacion ');
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:Referencia', 'ns0:Referencia', NULL, 1);
OPEN c_referencias ;
LOOP
FETCH c_referencias INTO r_referencias;
EXIT WHEN c_referencias%NOTFOUND;
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:Referencia', r_referencias.node_name, r_referencias.node_value, 2  );
END LOOP;
CLOSE c_referencias;
ELSE
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'actualizar_nodos c_ref ');
l_nroLineaRef := 0;
OPEN c_invoices2;
LOOP
FETCH c_invoices2 INTO r_invoices2;
EXIT WHEN c_invoices2%NOTFOUND;
l_nroLineaRef := l_nroLineaRef +1;
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:Referencia', 'ns0:Referencia', NULL, 1);
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:Referencia',  'ns0:NroLinRef' , To_Char (l_nroLineaRef) , l_nroLineaRef + 1);
OPEN c_ref (r_invoices2.invoice_id);
LOOP
FETCH c_ref INTO r_ref;
EXIT WHEN c_ref%NOTFOUND;
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'l_nroLineaRef : '|| l_nroLineaRef);
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'r_ref.node_name : '|| r_ref.node_name);
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'r_ref.node_value : '|| r_ref.node_value);
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:Referencia', r_ref.node_name, r_ref.node_value, l_nroLineaRef + 1  );
END LOOP;
CLOSE c_ref;
END LOOP;
CLOSE c_invoices2;
OPEN c_ref2;
LOOP
FETCH c_ref2 INTO r_ref2;
EXIT WHEN c_ref2%NOTFOUND;
l_nroLineaRef := l_nroLineaRef +1 ;
--IF r_ref.node_name = 'ns0:IndGlobal' THEN
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:Referencia', 'ns0:Referencia', NULL, 1);
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:Referencia',  'ns0:NroLinRef' , To_Char (l_nroLineaRef) , l_nroLineaRef + 1);
--END IF;
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:Referencia',    'ns0:IndGlobal', '1', l_nroLineaRef + 1);
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:Referencia', r_ref2.node_name, r_ref2.node_value, l_nroLineaRef + 1);
END LOOP;
CLOSE c_ref2;
END IF;  --IF p_anulacion = 'Y' THEN
END actualizar_nodos;
PROCEDURE actualizar_rta ( p_xmldoc dbms_xmldom.domdocument
, x_status_code OUT VARCHAR2
, x_error_code OUT VARCHAR2
, x_error_msg OUT VARCHAR2
, x_sobre OUT VARCHAR2
, x_error_dtl OUT VARCHAR2
, x_token OUT VARCHAR2
) IS
l_nodelist dbms_xmldom.domnodelist;
l_xmllength NUMBER;
l_currentnode dbms_xmldom.domnode;
l_currentnodename VARCHAR2(4000);
l_firstchild dbms_xmldom.domnode;
l_firstchildvalue VARCHAR2(4000);
BEGIN
l_nodelist := dbms_xmldom.getelementsbytagname(p_xmldoc, '*');
l_xmllength := dbms_xmldom.getlength(l_nodelist);
--dbms_output.put_line ('l_xmllength = '||l_xmllength);
FOR i IN 0 .. l_xmllength -1
LOOP
l_currentnode := dbms_xmldom.item(l_nodelist, i);
l_currentnodename := dbms_xmldom.getnodename(l_currentnode);
l_firstchild := dbms_xmldom.getfirstchild(l_currentnode);
l_firstchildvalue := dbms_xmldom.getnodevalue(l_firstchild);
--fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module => 'APPS.XX_WS_EFACTURAURU_PUB' , message => 'l_currentnodename = '|| l_currentnodename);
IF l_currentnodename = 'IDReceptor' THEN
--dbms_output.put_line ('Sobre = '|| l_firstchildvalue);
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU_PUB' , message   => 'Sobre = '|| l_firstchildvalue);
x_sobre := l_firstchildvalue;
ELSIF  l_currentnodename = 'Estado' THEN
--dbms_output.put_line ('Estado = '|| l_firstchildvalue);
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU_PUB' , message   => 'Estado = '|| l_firstchildvalue);
x_status_code := l_firstchildvalue;
ELSIF  l_currentnodename = 'Motivo' AND x_status_code = 'BS' THEN
--dbms_output.put_line ('Motivo = '|| l_firstchildvalue);
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU_PUB' , message   => 'Motivo = '|| l_firstchildvalue);
x_error_code := l_firstchildvalue;
ELSIF  x_status_code = 'BS' AND l_currentnodename = 'Detalle'  THEN
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU_PUB' , message   => 'x_error_dtl = '|| l_firstchildvalue);
--dbms_output.put_line ('Detalle = '|| l_firstchildvalue);
x_error_dtl := l_firstchildvalue;
ELSIF  x_status_code = 'AS' AND l_currentnodename = 'Token'  THEN
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU_PUB' , message   => 'x_token = '|| l_firstchildvalue);
x_token := l_firstchildvalue;
END IF;
END LOOP;
END actualizar_rta;
PROCEDURE get_trx_number (p_check_id IN NUMBER
, x_ultimo_nro OUT NUMBER
, x_nro_constancia OUT NUMBER
, x_trx_number OUT VARCHAR2
)
IS
CURSOR c_talonario IS
SELECT
xwet.nro_constancia
, NVL (xwet.ultimo_nro, xwet.nro_inicial -1) + 1 nro
--, LPAD(  NVL (xwet.ultimo_nro, xwet.nro_inicial -1) + 1 ,8, '0')  ultimo_nro
, xwet.serie
,  abaad.xx_ap_pago_eresg tipo_cbte_uy
,  aca.check_date fechae
FROM ap_checks_all aca
--r11, ap_bank_accounts_all abaa
--r11, ap_bank_accounts_all_dfv  abaad
/*r12*/,  ce_bank_accounts abaa
/*r12*/,  ce_bank_accounts_dfv  abaad
, xx_ws_efactura_talonario xwet
, CE_BANK_ACCT_USES_ALL cbaua
WHERE
aca.CE_BANK_ACCT_USE_ID = cbaua.BANK_ACCT_USE_ID
AND cbaua.bank_account_id  = abaa.bank_account_id
--    WHERE
-- 1 = 1
AND aca.check_id = Nvl (p_check_id, aca.check_id)
--AND aca.CE_BANK_ACCT_USE_ID /* aca.bank_account_id r12*/ = abaa.bank_account_id
-- aca.check_id = p_check_id
--AND aca.bank_account_id = abaa.bank_account_id
AND abaad.row_id =  abaa.ROWID
AND xwet.tipo_cbte =  abaad.xx_ap_pago_eresg
AND xwet.estado = 'A'
AND SYSDATE BETWEEN xwet.fecha_emision AND xwet.fecha_vto
AND NVL (xwet.ultimo_nro, 0) < xwet.nro_final
FOR UPDATE;
r_talonario c_talonario%ROWTYPE;
l_trx_number VARCHAR2(255);
BEGIN
x_ultimo_nro := -1;
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'OPEN c_talonario');
OPEN c_talonario;
LOOP
FETCH c_talonario INTO r_talonario;
EXIT WHEN c_talonario%NOTFOUND;
x_ultimo_nro := r_talonario.nro;
x_nro_constancia := r_talonario.nro_constancia;
x_trx_number := LPAD( r_talonario.nro ,8, '0');
END LOOP;
CLOSE c_talonario;
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'CLOSE c_talonario');
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'x_ultimo_nro '||x_ultimo_nro);
EXCEPTION
WHEN OTHERS THEN
x_ultimo_nro := -1;
END;
PROCEDURE genera_nodos_cae  ( p_doc dbms_xmldom.domdocument, p_nro_constancia IN NUMBER
) IS
CURSOR
c_cae IS
WITH nums AS (
SELECT ROWNUM rn FROM (SELECT 1, 2, 3 FROM dual GROUP BY CUBE (1, 2, 3)) WHERE ROWNUM <= 4)
SELECT node_name, node_value FROM
(SELECT DECODE(rn, 1, 'ns0:CAE_ID', 2, 'ns0:DNro', 3, 'ns0:HNro', 4, 'ns0:FecVenc') node_name,
DECODE(rn, 1, nro_constancia, 2, nro_inicial, 3, nro_final, 4, fecha_vto ) node_value
FROM
(
SELECT To_Char (nro_constancia) nro_constancia, To_Char (nro_inicial) nro_inicial, To_Char (nro_final) nro_final , To_Char (fecha_vto, 'YYYY-MM-DD') fecha_vto
FROM xx_ws_efactura_talonario
WHERE nro_constancia =  p_nro_constancia
)
qrya
, nums)
;
r_cae c_cae%ROWTYPE;
l_tipo_cbte  VARCHAR2(15);
BEGIN
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:eResg', 'ns0:CAEData',NULL,1);
OPEN c_cae;
LOOP
FETCH c_cae INTO r_cae;
EXIT WHEN c_cae%NOTFOUND;
xx_ws_common_uy_pub.insertNewNode (p_doc, 'ns0:CAEData', r_cae.node_name, r_cae.node_value, 1);
END LOOP;
CLOSE c_cae;
END genera_nodos_cae;
/****************************************************************************
*                                                                          *
* Name    : acuse_recibo_eresguardo                                        *
* Purpose : Invocacion al servicio EFACRECEPCIONSOBRE para obtener         *
*            recibo de pago (resguardo) en UY                              *
*                                                                          *
****************************************************************************/
PROCEDURE acuse_recibo_eresguardo(
p_check_id  IN ap_checks_all.check_id%TYPE
, x_status_code OUT VARCHAR2
, x_error_code OUT VARCHAR2
, x_error_msg OUT VARCHAR2
, x_sobre OUT VARCHAR2
, x_error_dtl OUT VARCHAR2
, p_anulacion IN VARCHAR2 DEFAULT 'N'
) IS
l_ifilename VARCHAR2(255);     /* REQ */
l_xmlType XMLTYPE;             /* REQ */
l_doc dbms_xmldom.domdocument; /* REQ */
l_clob CLOB;                   /* REQ */
l_bfileo BFILE;
l_file_exists NUMBER;
l_ofilename VARCHAR2(255);      /* RES */
l_oXmlType XMLTYPE;             /* RES */
l_oDoc dbms_xmldom.domdocument; /* RES */
l_oclob CLOB;                   /* RES */
l_sfilename VARCHAR2(255);      /* REQ_SIGNED */
l_sXmlType XMLTYPE;             /* REQ_SIGNED */
l_sDoc dbms_xmldom.domdocument; /* REQ_SIGNED */
l_sclob CLOB;                   /* REQ_SIGNED */
l_token_filename VARCHAR (255);      /* TOKEN */
l_tokenXmlType XMLTYPE;              /* TOKEN */
l_tokenDoc dbms_xmldom.domdocument;  /* TOKEN */
l_tokenClob CLOB;                    /* TOKEN */
l_template_name VARCHAR2(255);
l_token VARCHAR2 (1023);
l_ultimo_numero     NUMBER(15);
l_nro_constancia    NUMBER(15);
l_host_path         VARCHAR2(255);
l_trx_number        VARCHAR2(31);
l_rut                VARCHAR2(15);
l_id_receptor         VARCHAR2 (15);
l_ya_existeAS         EXCEPTION;
BEGIN
NULL;
-- Check
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'BEGIN ');
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'actualizar_trx_number  ');
-- obtengo directorio
SELECT NVL (MAX (directory_path),'X')  INTO l_host_path
FROM all_directories WHERE directory_name = 'XX_AR_FEUY_TEMPLATE';
IF l_host_path = 'X' THEN
raise_application_error(-10001, 'Directorio XX_AR_FEUY_TEMPLATE no definido');
END IF;
SELECT
NVL (MAX( hlad1.xx_ap_numero_iibb ) , 'X')
INTO l_rut
FROM  hr_locations_all             hl
, hr_locations_all1_dfv      hlad1
, hr_all_organization_units haou
WHERE   hl.rowid = hlad1.row_id
AND haou.location_id = hl.location_id
AND haou.organization_id = fnd_global.org_id
;
IF l_rut = 'X' THEN
raise_application_error(-10001, 'Rut para UO no definido');
END IF;
SELECT
NVL(MAX (id_receptor),'X') INTO l_id_receptor
FROM
bolinf.xx_ws_efactura_uy_zz xweuz
WHERE xweuz.id_emisor = p_check_id
AND xweuz.status = 'AS';
IF l_id_receptor != 'X' THEN
raise l_ya_existeAS;
--raise_application_error(-10001, 'Documento ya enviado a DGI IdReceptor = '||l_id_receptor);
END IF;
-- generar numero de trsnsaccion
get_trx_number (p_check_id, l_ultimo_numero, l_nro_constancia, l_trx_number);
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'l_trx_number =   '||l_trx_number);
IF l_ultimo_numero < 0 THEN
x_status_code := 'ES';
x_error_dtl := 'Error al obtener Talonario';
ELSE
-- ARMO XML
dbms_lob.createtemporary(l_clob, true);
dbms_lob.createtemporary(l_oclob, true);
dbms_lob.createtemporary(l_sclob, true);
dbms_lob.createtemporary(l_tokenClob, true);
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'createtemporary ');
IF p_anulacion = 'Y' THEN
l_ifilename := to_char(p_check_id)||'_RA_REQ.xml';
l_ofilename := to_char(p_check_id)||'_RA_RES.xml';
l_sfilename := to_char(p_check_id)||'_RA_REQ_signed.xml';
l_token_filename := 'TOKEN_RA_'||to_char(p_check_id)||'.xml';
ELSE
l_ifilename := to_char(p_check_id)||'_R_REQ.xml';
l_ofilename := to_char(p_check_id)||'_R_RES.xml';
l_sfilename := to_char(p_check_id)||'_R_REQ_signed.xml';
l_token_filename := 'TOKEN_R_'||to_char(p_check_id)||'.xml';
END IF;
l_template_name := 'template_eres.xml';
-- LEVANTO TEMPLATE
SELECT XMLTYPE(bfilename('XX_AR_FEUY_TEMPLATE', l_template_name), nls_charset_id('UTF8'))
INTO l_xmlType
FROM dual;
l_doc := dbms_xmldom.newdomdocument(l_xmlType);
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'XX_AR_FEUY_TEMPLATE loaded OK');
-- POBLAR VALORES
actualizar_nodos (p_check_id, l_doc, p_anulacion );
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'actualizar_nodos OK');
genera_nodos_cae ( l_doc, l_nro_constancia);
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'genera_nodos_cae OK');
dbms_xmldom.writetoclob(l_doc, l_clob, 'ISO-8859-1');
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'dbms_xmldom.writetoclob OK');
-- INSERTO ATTACHMENT
xx_ws_common_uy_pub.genera_attachment (to_char(p_check_id),l_clob, l_ifilename, 'AP_CHECKS');
-- genero archivo
dbms_xslprocessor.clob2file(l_clob, 'XX_AR_FEUY_TEMPLATE', l_ifilename);
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'xx_ws_common_uy_pub.genera_attachment OK');
-- Invoca SH para WS
--dbms_output.put_line ('invoca sh');
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => l_host_path||'/efacturaws_uy_host EFACRECEPCIONSOBRE '||l_ifilename||' '||l_ofilename||' '||l_rut);
host_command (p_command =>  'cd '||l_host_path||';./efacturaws_uy_host EFACRECEPCIONSOBRE '||l_ifilename||' '||l_ofilename||' '||l_rut);
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => l_host_path||'/efacturaws_uy_host EFACRECEPCIONSOBRE ok');
l_bfileo := bfilename('XX_AR_FEUY_TEMPLATE', l_ofilename);
l_file_exists := dbms_lob.fileexists (l_bfileo);
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'l_file_exists = '||l_file_exists);
/* si el archivo existe, entonces el WS se ejecuto satisfactoriamente */
IF l_file_exists = 1 THEN
SELECT XMLTYPE(l_bfileo, nls_charset_id('UTF8'))
INTO l_oXmlType
FROM dual;
l_oDoc := dbms_xmldom.newdomdocument(l_oXmlType);
actualizar_rta (l_oDoc, x_status_code,x_error_code,x_error_msg,x_sobre,x_error_dtl, l_token );
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => ' actualizar_rta ok ');
dbms_xmldom.writetoclob(l_oDoc, l_oclob, 'ISO-8859-1');
/* se agrega el firmado */
l_bfileo := bfilename('XX_AR_FEUY_TEMPLATE', l_sfilename);
l_file_exists := dbms_lob.fileexists (l_bfileo);
IF l_file_exists = 1 THEN
SELECT XMLTYPE(l_bfileo, nls_charset_id('UTF8'))
INTO l_sXmlType
FROM dual;
l_sDoc := dbms_xmldom.newdomdocument(l_sXmlType);
dbms_xmldom.writetoclob(l_sDoc, l_sclob, 'ISO-8859-1');
xx_ws_common_uy_pub.genera_attachment (to_char(p_check_id),l_sclob, l_sfilename, 'AP_CHECKS');
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => ' genera_attachment s ok ');
END IF;
xx_ws_common_uy_pub.genera_attachment (to_char(p_check_id),l_oclob, l_ofilename, 'AP_CHECKS');
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => ' genera_attachment o ok ');
ELSE
x_status_code := 'ES';
x_error_dtl := 'Error al invocar WS DGI';
END IF;  --IF l_file_exists = 1 THEN
IF x_status_code = 'AS' THEN
INSERT INTO bolinf.xx_ws_efactura_uy_zz
(
id_emisor
, id_receptor
, trx_number
, trx_date
, status
)
values (
p_check_id
, x_sobre
, l_trx_number
, TO_CHAR (SYSDATE, 'DDMMYYYY')
, x_status_code
);
/* Genero attachment con token para obtener cae */
SELECT XMLTYPE(bfilename('XX_AR_FEUY_TEMPLATE', 'template_cae.xml'), nls_charset_id('UTF8'))
INTO l_tokenXmlType
FROM dual;
l_tokenDoc := dbms_xmldom.newdomdocument(l_tokenXmlType);
xx_ws_common_uy_pub.updateNodeValue (l_tokenDoc, 'IdReceptor', x_sobre);
xx_ws_common_uy_pub.updateNodeValue (l_tokenDoc, 'Token', l_token);
dbms_xmldom.writetoclob(l_tokenDoc, l_tokenClob, 'ISO-8859-1');
xx_ws_common_uy_pub.genera_attachment (to_char(p_check_id),l_tokenClob, l_token_filename , 'AP_CHECKS');
UPDATE
xx_ws_efactura_talonario
SET ultimo_nro = l_ultimo_numero
WHERE nro_constancia = l_nro_constancia;
--END IF;
END IF;  -- IF x_status_code = 'AS' THEN
--UTL_FILE.FREMOVE  ('XX_AR_FEUY_TEMPLATE', l_ifilename);
--UTL_FILE.FREMOVE  ('XX_AR_FEUY_TEMPLATE', l_ofilename);
dbms_lob.freetemporary (l_clob);
dbms_lob.freetemporary (l_oclob);
dbms_lob.freetemporary (l_sclob);
dbms_lob.freetemporary (l_tokenClob);
END IF; --  IF l_ultimo_numero < 0 THEN
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'x_status_code = '||x_status_code);
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'x_error_msg = '||x_error_msg);
fnd_log.string(log_level => fnd_log.LEVEL_STATEMENT, module    => 'XX_WS_EFACTURAURU2_PUB' , message   => 'x_sobre = '||x_sobre);
IF p_anulacion = 'N' THEN
UPDATE
ap_checks_all
SET
attribute10 =  Decode (x_status_code, 'AS', 'EAS', 'BS', 'EBS', 'ES', 'EES') -- STATUS
, attribute11 = substr (x_error_dtl,1,145)
, attribute12 = l_ultimo_numero -- E-Resg: Numero de Comprobante E-Resguardo
-- , attribute9 = x_status_code -- status usuario
, attribute13 =   TO_CHAR (SYSDATE, 'DDMMYYYY') -- E-Resg: Fecha de Sobre
, attribute_category = 'UY'
WHERE
check_id = p_check_id
;
ELSE
UPDATE
ap_checks_all
SET
attribute10 =  Decode (x_status_code, 'AS', 'NAS', 'BS', 'NBS', 'ES', 'NES') -- STATUS
, attribute11 = substr (x_error_dtl,1,145)
, attribute_category = 'UY'
, attribute14 =  l_ultimo_numero -- E-Resg: Numero de Comprobante E-Resguardo Anulado
, attribute15 = TO_CHAR (SYSDATE, 'DDMMYYYY')-- E-Resg: Fecha de Anulación Sobre
WHERE
check_id = p_check_id
;
END IF;
EXCEPTION
WHEN l_ya_existeAS  THEN
--raise_application_error(-20001, 'Documento ya enviado a DGI IdReceptor = '||l_id_receptor);
x_status_code := 'ES';
x_error_dtl := 'Documento ya enviado a DGI IdReceptor : '||l_id_receptor;
WHEN OTHERS THEN
DECLARE
l_err VARCHAR2 (150) := SubStr (SQLERRM,1,149);
BEGIN
x_status_code := 'EES';
x_error_dtl := l_err;
UPDATE
ap_checks_all
SET
attribute10 =  x_status_code -- STATUS
, attribute11 = substr (l_err,1,145)
WHERE
check_id = p_check_id
;
END;
END acuse_recibo_eresguardo;
END xx_ws_efacturauru2_pub;
/