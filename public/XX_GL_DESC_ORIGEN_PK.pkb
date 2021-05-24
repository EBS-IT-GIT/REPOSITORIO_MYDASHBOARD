CREATE OR REPLACE PACKAGE BODY APPS."XX_GL_DESC_ORIGEN_PK" AS
  FUNCTION principal$NonSLA  ( p_source_code           IN VARCHAR2
                     , p_category_code         IN VARCHAR2
                     , p_header_id             IN NUMBER
                     , p_line_num              IN VARCHAR2
                     , p_code_comb_id          IN NUMBER
                     , p_reference_1           IN VARCHAR2
                     , p_reference_2           IN VARCHAR2
                     , p_reference_3           IN VARCHAR2
                     , p_reference_4           IN VARCHAR2
                     , p_reference_5           IN VARCHAR2
                     , p_reference_9           IN VARCHAR2
                     , p_reference_6           IN VARCHAR2
                     , p_reference_7           IN VARCHAR2
                     , p_reference_8           IN VARCHAR2
                     , p_reference_10          IN VARCHAR2
                     , p_debit                 IN NUMBER
                     , p_credit                IN NUMBER
                     --, p_desc_origen          OUT VARCHAR2
                     , p_vendor_customer      OUT VARCHAR2
                     , p_factura_recibo       OUT VARCHAR2
                     , p_recepcion_CP         OUT VARCHAR2
                     , p_o_compra_venta_pago  OUT VARCHAR2
                     , p_fecha                OUT VARCHAR2
                     , p_no_cuenta            OUT VARCHAR2
                     , p_no_cheque            OUT VARCHAR2
                     , p_no_producto_activo   OUT VARCHAR2
                     , p_desc_producto_activo OUT VARCHAR2
                     , p_uom_producto_activo  OUT VARCHAR2
                     , p_cant_producto_activo OUT VARCHAR2
                     , p_chr_journal_comment  OUT VARCHAR2
                     , p_otros                OUT VARCHAR2
                     , p_cia_origen           OUT VARCHAR2
                     , p_org_origen           OUT VARCHAR2
                     ) RETURN BOOLEAN IS
    v_sep         VARCHAR2(10) := '; ';
    v_desc_origen VARCHAR2(2000);
    e_nodatafo1   EXCEPTION;
    e_nodatafo2   EXCEPTION;
    e_nodatafo3   EXCEPTION;
    e_nodatafo4   EXCEPTION;
    e_nodatafo5   EXCEPTION;
    e_nodatafo6   EXCEPTION;
    e_nodatafo7   EXCEPTION;
    e_nodatafo8   EXCEPTION;
    e_nodatafo9   EXCEPTION;
    e_nodatafo10  EXCEPTION;
    e_nodatafo11  EXCEPTION;
    e_nodatafo12  EXCEPTION;
    e_nodatafo13  EXCEPTION;
    e_nodatafo14  EXCEPTION;
    e_nodatafo15  EXCEPTION;
    e_nodatafo16  EXCEPTION;
    e_toomaro     EXCEPTION;
    e_others      EXCEPTION;
    lv_item_id            mtl_system_items.inventory_item_id%TYPE;
    lv_organization_id    mtl_system_items.organization_id%TYPE;
    lv_item_description   rcv_shipment_lines.item_description%TYPE;
    l_dummy_chr   VARCHAR2(2000);

  CURSOR c_receivables ( p_je_header_id     IN NUMBER
                        ,p_je_category_code IN VARCHAR2
                        ,p_line_num         IN NUMBER   ) IS
    -- R.reference_10              = 'AR_CASH_RECEIPT_HISTORY'
    -- se divide en dos UNIONS por performance
    SELECT Decode(CR.receipt_number, NULL, NULL, CR.receipt_number) recibo
         , Decode(CR.receipt_date, NULL, NULL, CR.receipt_date) fecha
         , Decode(CUST_ACCT.account_number, NULL, NULL, CUST_ACCT.account_number) no_cuenta
         , Decode(SubStrB(party.party_name,1,50), NULL, NULL, SubStrB(party.party_name,1,50)) cliente
    FROM gl_import_references        R
       , ar_cash_receipt_history_all CRH
       , ar_cash_receipts_all        CR
       , hz_cust_accounts            CUST_ACCT
       , hz_parties                  PARTY
    WHERE 1=1
    AND R.je_header_id        = p_je_header_id
    AND r.je_line_num         = p_line_num
    AND R.reference_10        = 'AR_CASH_RECEIPT_HISTORY'
    -- cuando el reference_8 es TRADE, la informacion en el
    -- reference_2 se guarda de la forma
    -- cash_receipt_id||'C'||cash_receipt_history_id
    AND (     R.reference_8 ='TRADE'
          AND SUBSTR( R.reference_2  ,1, INSTR (R.reference_2 , 'C') - 1) = cr.cash_receipt_id
          AND SUBSTR( R.reference_2 , INSTR (R.reference_2, 'C') + 1)     = crh.cash_receipT_history_id
        )
    AND NVL( CRH.org_id,-99 ) = NVL ( CR.org_id, -99 )
    AND CR.pay_from_customer  = CUST_ACCT.cust_account_id(+)
    AND CUST_ACCT.party_id    = PARTY.party_id(+)
    AND p_je_category_code    IN ('Trade Receipts', 'Rate Adjustments', 'Misc Receipts', 'Cross Currency')
    UNION ALL
    SELECT Decode(CR.receipt_number, NULL, NULL, CR.receipt_number) recibo
         , Decode(CR.receipt_date, NULL, NULL, CR.receipt_date) fecha
         , Decode(CUST_ACCT.account_number, NULL, NULL, CUST_ACCT.account_number) no_cuenta
         , Decode(SubStrB(party.party_name,1,50), NULL, NULL, SubStrB(party.party_name,1,50)) cliente
    FROM gl_import_references        R
       , ar_cash_receipt_history_all CRH
       , ar_cash_receipts_all        CR
       , hz_cust_accounts            CUST_ACCT
       , hz_parties                  PARTY
    WHERE 1=1
    AND R.je_header_id     = p_je_header_id
    AND r.je_line_num      = p_line_num
    AND R.reference_10     = 'AR_CASH_RECEIPT_HISTORY'
    -- cuando el reference_8 es MISC, la informacion en el reference_2 se guarda de la forma
    -- cash_receipt_id => reference_2 y cash_receipt_history_id => reference_5
    AND (     R.reference_8 ='MISC'
          AND CR.cash_receipt_id = TO_NUMBER( R.reference_2 )
          AND CRH.cash_receipt_history_id = TO_NUMBER( r.reference_5 )
        )
    AND Nvl(CRH.org_id,-99)     = Nvl(CR.org_id, -99)
    AND CR.pay_from_customer    = CUST_ACCT.cust_account_id(+)
    AND CUST_ACCT.party_id      = PARTY.party_id(+)
    AND p_je_category_code      IN ('Trade Receipts', 'Rate Adjustments', 'Misc Receipts', 'Cross Currency')
    UNION ALL
    SELECT Decode(Decode(RA.applied_customer_trx_id, NULL, RPad(CR.receipt_number, 30), RPad(CT.trx_number, 20)), NULL, NULL, Decode(RA.applied_customer_trx_id, NULL, RPad(CR.receipt_number, 30), RPad(CT.trx_number, 20))) recibo
         , Decode(CR.receipt_date, NULL, NULL,CR.receipt_date)
         ||Decode(CT.trx_date, NULL, NULL, v_sep||'Fecha TRX: '||CT.trx_date) fecha
         , Decode(CUST_ACCT.account_number, NULL, NULL, CUST_ACCT.account_number) no_cuenta
         , Decode(SubStrB(PARTY.party_name,1,50), NULL, NULL, SubStrB(PARTY.party_name,1,50)) cliente
    FROM gl_import_references           R
       , ar_receivable_applications_all RA
       , ar_cash_receipts_all           CR
       , hz_cust_accounts               CUST_ACCT
       , hz_parties                     PARTY
       , ra_customer_trx_all            CT
       , ar_cash_basis_dists_all        CBD
    WHERE R.je_header_id                 = p_je_header_id
    AND r.je_line_num         = p_line_num
    AND R.reference_10                 = 'AR_CASH_BASIS_DISTRIBUTIONS'
    AND CBD.source                     IN ('GL', 'ADJ')
    AND CBD.cash_basis_distribution_id = To_Number(R.reference_3)
    AND RA.receivable_application_id   = CBD.receivable_application_id
    AND RA.application_type            = 'CASH'
    AND RA.status                      = 'APP'
    AND Nvl(RA.postable, 'Y')          = 'Y'
    AND RA.cash_receipt_id             = CR.cash_receipt_id
    AND Nvl(RA.org_id, -99)            = Nvl(CR.org_id, -99)
    AND CR.pay_from_customer           = CUST_ACCT.cust_account_id(+)
    AND CUST_ACCT.party_id             = PARTY.party_id(+)
    AND RA.applied_customer_trx_id     = CT.customer_trx_id(+)
    AND Nvl(RA.org_id, -99)            = Nvl(CT.org_id(+), -99)
    AND p_je_category_code             IN ('Trade Receipts', 'Rate Adjustments', 'Cross Currency')
    UNION ALL
    SELECT RPad(CR.receipt_number, 30) recibo
         , Decode(CR.receipt_date, NULL,NULL, CR.receipt_date)   fecha
         , Decode(CUST_ACCT.account_number, NULL,NULL, CUST_ACCT.account_number) no_cuenta
         , Decode(SubStrB(PARTY.party_name,1,50), NULL,NULL, SubStrB(PARTY.party_name,1,50)) cliente
    FROM gl_import_references           R
       , ar_receivable_applications_all RA
       , ar_cash_receipts_all           CR
       , hz_cust_accounts               CUST_ACCT
       , hz_parties                     PARTY
       , ra_customer_trx_all            CT
    WHERE R.je_header_id    = p_je_header_id
    AND r.je_line_num       = p_line_num
    AND R.reference_10      = 'AR_RECEIVABLE_APPLICATIONS'
    AND (     R.reference_8 ='TRADE'
          AND SUBSTR( R.reference_2  ,1, INSTR (R.reference_2 , 'C') - 1) = cr.cash_receipt_id
          AND SUBSTR( R.reference_2 , INSTR (R.reference_2, 'C') + 1)     = ra.receivable_application_id
        )
    AND RA.application_type          = 'CASH'
    AND RA.cash_receipt_id           = CR.cash_receipt_id
    AND nvl(RA.org_id, -99)          = nvl(CR.org_id, -99)
    AND CR.pay_from_customer         = CUST_ACCT.cust_account_id(+)
    AND CUST_ACCT.party_id           = PARTY.party_id(+)
    AND RA.applied_customer_trx_id   = CT.customer_trx_id(+)
    AND nvl(RA.org_id, -99)          = nvl(CT.org_id(+), -99)
    AND p_je_category_code           IN ('Trade Receipts', 'Rate Adjustments', 'Cross Currency')
    UNION ALL
    SELECT Decode(CR.receipt_number, NULL, NULL, CR.receipt_number) recibo
         , Decode(CR.receipt_date, NULL, NULL, CR.receipt_date) fecha
         , null no_cuenta
         , null cliente
    FROM gl_import_references           R
      , ar_misc_cash_distributions_all MCD
      , ar_cash_receipts_all           CR
    WHERE R.je_header_id              = p_je_header_id
    AND r.je_line_num                 = p_line_num
    AND R.reference_10                = 'AR_MISC_CASH_DISTRIBUTIONS'
    AND MCD.misc_cash_distribution_id = (R.reference_5)
    AND MCD.cash_receipt_id           = CR.cash_receipt_id
    AND Nvl(MCD.org_id,-99)           = Nvl(CR.org_id,-99)
    AND p_je_category_code            = 'Misc Receipts';

  CURSOR c_cm_items (p_debit_credit_sign NUMBER) IS
    SELECT s.fiscal_year,
           s.period,
           s.voucher_id,
           s.acctg_unit_no,
           s.acct_no ,
           s.resource_item_no,
           s.resource_item_no_desc,
           s.debit_credit_sign,
           s.trans_qty_usage_um,
           s.trans_qty_usage,
          --              decode(debit_credit_sign,1,SUM( s.amount_base), null) debit,
          --            decode(debit_credit_sign,-1,SUM( s.amount_base), null) credit
          ( SELECT sum(ic.loct_onhand)
            FROM ic_perd_bal ic
               , ic_whse_mst wh
               , gl_subr_sta st
            WHERE  ic.whse_code           = wh.whse_code
            AND wh.mtl_organization_id  =  p_reference_9 --:_doc_id
            AND ic.item_id                          = s.line_id
            AND st.reference_no               = s.reference_no --v_reference_no
            AND st.crev_inv_prev_cal       = ic.fiscal_year
            AND st.crev_inv_prev_per      = ic.period
            GROUP BY ic.item_id,ic.whse_code
            HAVING SUM(ic.loct_onhand) <> 0
          )  rval_quantity
    FROM gl_subr_led_vw s  ,
         gl_code_combinations_kfv gcc
    WHERE 1=1
    AND s.doc_type      =  p_reference_8   --'RVAL'
    AND s.doc_id        =  p_reference_9
    AND s.voucher_id =  p_reference_4  -- reference1 y reference4
    AND s.fiscal_year =  p_reference_6
    AND s.period         =  p_reference_7
    AND s.co_code || '-' || s.acct_no = gcc.concatenated_segments
    AND gcc.code_combination_id = p_code_comb_id
    AND s.debit_credit_sign = p_debit_credit_sign ; --1;

  CURSOR c_pur_items (p_debit_credit_sign NUMBER, p_order VARCHAR2 ) IS
    SELECT DISTINCT
           rsh.receipt_num
         , pv.segment1          vendor_num
         , pv.vendor_name
         , t.transaction_date
         , ph.segment1          po_num
         , i.item_no            resource_item_no
         , i.item_desc1         resource_item_no_desc
         , uom.um_code          trans_qty_usage_um
         , t.quantity
         , t.po_unit_price      otros
    FROM gl_subr_led s
       , gl_acct_mst a
       , gl_accu_mst au
       , gl_acct_ttl AT
       , gl_sevt_mst sb
       , gl_srce_mst sr
       , ic_tran_pnd pnd
       , rcv_transactions t
       , rcv_shipment_headers rsh
       , rcv_shipment_lines rsl
       , sy_uoms_mst uom
       , ic_item_mst i
       , po_vendors pv
       , gl_je_lines gjl
       , gl_je_headers gjh
       , gl_code_combinations_kfv gcck
       , po_headers_all ph
    WHERE s.acct_ttl_type   = AT.acct_ttl_type
    AND s.sub_event_type    = sb.sub_event_type
    AND s.trans_source_type = sr.trans_source_type
    AND s.acct_id           = a.acct_id
    AND s.acctg_unit_id     = au.acctg_unit_id
    AND s.doc_type          = 'PORC'
    AND pnd.doc_type        = s.doc_type
    AND pnd.doc_id          = s.doc_id
    AND pnd.line_id         = s.line_id
    AND pnd.line_id         = t.transaction_id
    AND t.shipment_header_id = rsh.shipment_header_id
    AND t.shipment_line_id  = rsl.shipment_line_id
    AND t.po_header_id      = ph.po_header_id
    AND rsh.receipt_source_code IN ('VENDOR', 'INTERNAL ORDER')
    AND t.source_document_code  IN ('PO', 'REQ')
    AND pnd.item_id         = i.item_id
    AND pv.vendor_id        = t.vendor_id
    AND s.doc_id            = gjl.reference_9                                    --31045
    AND gjh.je_header_id    = gjl.je_header_id
    AND gcck.code_combination_id = gjl.code_combination_id
    AND gjh.status          = 'P'
    AND t.unit_of_measure   = uom.unit_of_measure
    AND gcck.concatenated_segments = au.acctg_unit_no || '-' || a.acct_no
    --
    AND s.fiscal_year       = p_reference_6
    AND s.period            = p_reference_7
    AND gjl.je_header_id    = p_header_id
    AND gjl.je_line_num     = p_line_num
    AND gjl.code_combination_id = p_code_comb_id
    AND s.debit_credit_sign = p_debit_credit_sign  --1;
    --
    ORDER BY DECODE(p_order, 1, rsh.receipt_num
                           , 2, pv.segment1
                           , 3, t.transaction_date
                           , 4, ph.segment1
                           , 5, i.item_no )
    ;
-- 27-MAR-2009
-- Payables / Purchase invoices
-- Cuando se trata de la cuenta de pasivo
-- ya que no tiene distribution line number
-- asociado, es el total de la factura

  CURSOR c_purch_inv (p_reference_1 IN VARCHAR2,
                      p_reference_5 IN VARCHAR2,
                      p_reference_2 IN NUMBER) IS
    SELECT distinct
           ph.segment1                 po_num
         , pv.SEGMENT1                 vendor_num
         , ai.invoice_date             invoice_date
         , p_reference_1               vendor_customer
         , p_reference_5               factura_recibo
         , plv.item_number
         , aid.description             desc_producto_activo
         , aid.quantity_invoiced       cant_producto_activo
         , aid.matched_uom_lookup_code uom_producto_activo
         , Decode(aid.unit_price, NULL, NULL, 'Precio Unit: '||aid.unit_price)
         ||Decode(aid.unit_price*aid.quantity_invoiced, NULL, NULL, 'Precio Unit x Cantidad Fac: '||aid.unit_price*aid.quantity_invoiced) otros
    FROM ap_invoices_all              ai
       , ap_invoice_distributions_all aid
       , po_vendors pv
       , po_distributions_all pda
       , po_headers_all ph
       , po_lines_v     plv
    WHERE -- Invoices
          ai.invoice_id                    = To_Number(p_reference_2)
    AND pda.po_line_id = plv.po_line_id(+)
    AND -- Distributions
        ai.invoice_id                    = aid.invoice_id (+)
    AND pv.vendor_id = ai.vendor_id(+)
    AND pda.po_distribution_id(+) = aid.po_distribution_id
    AND ph.po_header_id(+) = pda.po_header_id;


  -- Agregado 24-02-2012 asilva
  -- se agrega cursor para concatenar productos
  CURSOR c_om_items_omsp (p_header_id    IN NUMBER,
                          p_line_num     IN VARCHAR2,
                          p_code_comb_id IN NUMBER) IS

    SELECT gjl.effective_date,
           SUM (itp.trans_qty) trans_qty,
           itp.trans_um,
           iim.item_no,
           iim.item_desc1,
           ooh.order_number,
           rc.customer_number,
           rc.customer_name
    FROM gl_je_lines gjl
       , gl_je_headers gjh
       , gl_code_combinations_kfv gcck
       , gl_acct_mst gam1
       , gl_accu_mst gam2
       , gl_subr_led gsl
       , ic_tran_pnd itp
       , ic_item_mst iim
      --
       , oe_order_lines_all ool
       , oe_order_headers_all ooh
       --, ra_customers rc
       , oe_ra_customers_v rc --R12
      --
    WHERE  gjh.je_source     in ('OM')
    AND    gjh.je_category   = 'OMSP'
    AND    gjh.je_header_id     = gjl.je_header_id
    AND    gcck.code_combination_id = gjl.code_combination_id
    AND    gjh.status = 'P'
    AND    gam2.acctg_unit_id = gsl.acctg_unit_id
    AND    gsl.acct_id = gam1.acct_id
    AND    gsl.voucher_id||'' = gjl.reference_4  /* 13-feb-2012 Watea - MG - agregado */
    AND    gjl.reference_9 = gsl.doc_id
    -- Modificado KHRONUS/PBonadeo 20170925: Se agrega condicion para uso de indice. Requerimiento segun CR2905
    AND    gjl.reference_8 = gsl.doc_type
    -- Fin Modificado KHRONUS/PBonadeo 20170925
    AND    gjl.reference_8 = itp.doc_type
    AND    gcck.concatenated_segments = gam2.acctg_unit_no||'-'||gam1.acct_no
    AND    gsl.line_id = itp.line_id
    AND    itp.item_id = iim.item_id
    AND    gsl.gl_trans_date = itp.trans_date
    AND    ool.line_id(+) = itp.line_id
    AND    ooh.header_id(+) = ool.header_id
    AND    ooh.sold_to_org_id = rc.customer_id(+)
    AND    gjh.je_header_id  = p_header_id
    AND    gjl.je_line_num   = p_line_num
    AND    gjl.code_combination_id = p_code_comb_id
    GROUP BY ooh.order_number,
             gjl.effective_date,
             rc.customer_number,
             rc.customer_name,
             iim.item_no,
             iim.item_desc1,
             itp.trans_um;


  CURSOR c_om_items_rma (p_header_id    IN NUMBER,
                         p_line_num     IN VARCHAR2,
                         p_code_comb_id IN NUMBER) IS

    SELECT gjl.effective_date,
           SUM(tp.trans_qty)   trans_qty,
           tp.trans_um,
           im.item_no,
           im.item_desc1,
           oh.order_number,
           rc.customer_number,
           rc.customer_name
    FROM   oe_order_lines_all ol,
           oe_order_headers_all oh,
           --ra_customers      rc,
           oe_ra_customers_v rc, --R12
           mtl_system_items si,
           ic_item_mst   im,
           ic_whse_mst   wm,
           ic_tran_pnd   tp,
           gl_code_combinations_kfv gcck,
           gl_acct_mst   gam1,
           gl_accu_mst   gam2,
           gl_subr_led   sl,
           gl_je_lines   gjl,
           gl_period_statuses gps,
           gl_je_headers gjh,
           gl_je_batches b
    WHERE  gjl.je_header_id    = p_header_id
    AND  gjl.je_line_num     = p_line_num
    AND  gjl.reference_8     = 'PORC'
    AND  gjh.je_header_id    = gjl.je_header_id
    AND  b.je_batch_id       = gjh.je_batch_id
    --
    AND  gps.application_id  = 401  /* Inventario */
    --AND  gps.set_of_books_id = gjh.set_of_books_id                  --11i
    AND  gps.ledger_id       = gjh.ledger_id                          --R12
    AND  gjl.effective_date BETWEEN gps.start_date AND gps.end_date
    --
    AND  sl.doc_type         = gjl.reference_8
    AND  sl.doc_id           = gjl.reference_9
    AND  sl.voucher_id||''   = gjl.reference_4
    AND  ( ( sl.debit_credit_sign = 1 AND gjl.entered_dr IS NOT NULL )
          OR
           ( sl.debit_credit_sign = -1 AND gjl.entered_cr IS NOT NULL )
         )
    AND  tp.doc_type         = sl.doc_type
    AND  tp.co_code          = sl.co_code
    AND  tp.line_id          = sl.line_id
    AND  tp.trans_date       = sl.gl_doc_date
    --
    AND  wm.whse_code        = tp.whse_code
    AND  im.item_id          = tp.item_id
    AND  si.segment1         = im.item_no
    AND  si.organization_id  = wm.mtl_organization_id
    --
    AND  gam2.acctg_unit_id  = sl.acctg_unit_id
    AND  gam1.acct_id        = sl.acct_id
    AND  gcck.concatenated_segments = gam2.acctg_unit_no||'-'||gam1.acct_no
    --
    AND  ol.line_category_code = 'RETURN'
    AND  ol.ship_from_org_id = si.organization_id
    AND  ol.inventory_item_id = si.inventory_item_id
    AND  TRUNC(ol.request_date) BETWEEN gps.start_date AND gps.end_date
    AND  oh.header_id = ol.header_id
    --
    AND  inv_convert.inv_um_convert( si.inventory_item_id, 2, ol.ordered_quantity, ol.order_quantity_uom, tp.trans_um,'','') = tp.trans_qty
    --
    AND    rc.customer_id = ol.sold_to_org_id
    GROUP BY
         gjl.effective_date,
         tp.trans_um,
         im.item_no,
         im.item_desc1,
         rc.customer_number,
         rc.customer_name,
         oh.order_number;
--

  -- Agregado asilva 26/03/2012
  CURSOR c_ic_items_piph (p_voucher_id    NUMBER,
                          p_company_code  VARCHAR2,
                          p_doc_type      VARCHAR2,
                          p_doc_id        NUMBER,
                          p_fiscal_year   NUMBER,
                          p_period        NUMBER,
                          p_code_comb_id  NUMBER) IS
    SELECT distinct itm.item_no,
           si.description,
           cmp.trans_um,
           cmp.trans_qty
    FROM gl_code_combinations_kfv gcck,
         gl_acct_mst              gam1,
         gl_accu_mst              gam2,
         mtl_system_items         si,
         mtl_parameters           mp,
         hr_all_organization_units hou,
         ic_item_mst              itm,
         ic_tran_cmp              cmp,
         gl_subr_led              sl
    WHERE  sl.voucher_id            = p_voucher_id
    AND    sl.co_code               = p_company_code
    AND    sl.doc_type              = p_doc_type
    AND    sl.doc_id                = p_doc_id
    AND    sl.fiscal_year           = p_fiscal_year
    AND    sl.period                = p_period
    AND    gcck.code_combination_id = p_code_comb_id
    --
    AND    gam2.acctg_unit_id  = sl.acctg_unit_id
    AND    gam1.acct_id        = sl.acct_id
    AND    gam2.acctg_unit_no||'-'||gam1.acct_no = gcck.concatenated_segments
    --
    --
    AND    cmp.doc_type = sl.doc_type
    AND    cmp.doc_id = sl.doc_id
    AND    cmp.line_id = sl.line_id
    AND    (  ( sl.debit_credit_sign=1 AND cmp.trans_qty >= 0 )
           OR
              ( sl.debit_credit_sign=-1 AND cmp.trans_qty < 0 )
           )
    --
    AND    itm.item_id = cmp.item_id
    AND    mp.organization_code = cmp.whse_code
    AND    si.segment1 = itm.item_no
    AND    si.organization_id = mp.organization_id
    AND    hou.organization_Id = mp.organization_id;


  CURSOR c_ic_items (p_header_id IN NUMBER,
                     p_line_num  IN NUMBER,
                     p_code_comb_id IN NUMBER) IS
    SELECT iaj.item_no
         , iaj.item_desc1
         , item_um
         , Decode( gjh.je_category, 'IADJ', QTY, TO_QTY) Descripcion_Origen
         -- Agregado Quanam SR 30-03-2010
         , NVL(iaj.journal_comment,' ') journal_comment
         --
    FROM ic_jrnl_mst                ijm
       , ic_adjs_jnl_vw           iaj
       , gl_je_lines              gjl
       , gl_je_headers            gjh
       , gl_code_combinations_kfv gcck
    WHERE  ijm.journal_id           = iaj.journal_id
    AND    iaj.doc_id               = gjl.reference_9
    AND    gjl.reference_9          = iaj.doc_id
    AND    gjh.je_header_id         = gjl.je_header_id
    AND    gcck.code_combination_id = gjl.code_combination_id
    AND    gjh.status               = 'P'
    AND    gjl.je_header_id         = p_header_id
    AND    gjl.je_line_num          = p_line_num
    AND    gjl.code_combination_id  = p_code_comb_id;
    --


  -- Agregado por Quanam 30-06-2010 CGR
  -- Declaro variables flag y auxiliares para no repetir datos
  v_po_num_flag               NUMBER:=0;
  v_po_num_aux                VARCHAR2(50);
  v_vendor_num_flag           NUMBER:=0;
  v_vendor_num_aux            VARCHAR2(50);
  v_inv_date_flag             NUMBER:=0;
  v_inv_date_aux              VARCHAR2(50);
  v_vendor_cust_flag          NUMBER:=0;
  v_vendor_cust_aux           VARCHAR2(50);
  v_fact_rec_flag             NUMBER:=0;
  v_fact_rec_aux              VARCHAR2(50);
  v_item_num_flag             NUMBER:=0;
  v_item_num_aux              VARCHAR2(50);
  v_desc_prod_flag            NUMBER:=0;
  v_desc_prod_aux             VARCHAR2(50);
  v_cant_prod_flag            NUMBER:=0;
  v_cant_prod_aux             VARCHAR2(50);
  v_uom_prod_flag             NUMBER:=0;
  v_uom_prod_aux              VARCHAR2(50);
  v_otros_flag                NUMBER:=0;
  v_otros_aux                 VARCHAR2(1000);
  l_cc_id_provision           NUMBER;
  l_cp_id_flete               NUMBER;

  BEGIN

    BEGIN
      SELECT provision_account_id
      INTO l_cc_id_provision
      FROM xx_aco_parametros_compania
      WHERE provision_account_id = p_code_comb_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_cc_id_provision := NULL;
    END;

    IF (p_source_code  = 'Payables') THEN
      IF (p_category_code IN ('Payments','Reconciled Payments','Cross Currency')) THEN
        BEGIN
            -- 29-ene-2009 rmoreno inicion modificacion.
            -- Se modifica porque se necesita obtener le nro de o. de pago
            -- y el nro de proveedor
            --
            SELECT doc_sequence_value
                 , pv.segment1
                 , Decode(p_reference_1, NULL, NULL, p_reference_1)
                 , Decode(p_reference_5, NULL, NULL, p_reference_5)
                 , Decode(p_reference_4, NULL, NULL, p_reference_4) Descripcion_Origen
             INTO p_o_compra_venta_pago
                , p_no_cuenta
                , p_vendor_customer
                , p_factura_recibo
                , p_no_cheque
             FROM gl_import_references r,
                  ap_ae_lines_all      ael,
                  ap_ae_headers_all    aeh,
                  ap_accounting_events_all ae,
                  ap_checks_all        c,
                  po_vendors           pv
             WHERE 200 = 200
             AND   je_header_id = p_header_id
             AND   je_line_num = p_line_num
             AND   r.gl_sl_link_id = ael.gl_sl_link_id
             AND   c.check_id = ae.source_id
             AND   ae.source_table = 'AP_CHECKS'
             AND   ae.accounting_event_id = aeh.accounting_event_id
             AND   aeh.ae_header_id = ael.ae_header_id
             AND   pv.vendor_id = c.vendor_id ;
             -- 29-ene-2009 rmoreno inicion modificacion.

             RETURN (TRUE);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RAISE e_nodatafo1;
          WHEN TOO_MANY_ROWS THEN
            RAISE e_toomaro;
          WHEN OTHERS THEN
            RAISE e_others;
        END;
      ELSIF (p_category_code = 'Purchase Invoices') THEN
        BEGIN
          IF p_reference_3 IS NOT NULL THEN
            SELECT
               -- 26-ENE-2009 rmoreno inicio mod
                 ph.segment1      -- orden de compra
               , pv.SEGMENT1    -- nro proveedor
               , ai.invoice_date
               -- 26-ENE-2009 rmoreno fin mod
               , Decode(p_reference_1, NULL, NULL, p_reference_1)
               , Decode(p_reference_5, NULL, NULL, p_reference_5)
               , Decode(aid.description, NULL, NULL, aid.description)
               , Decode(aid.quantity_invoiced, NULL, NULL, aid.quantity_invoiced)
               , Decode(aid.matched_uom_lookup_code, NULL, NULL, aid.matched_uom_lookup_code)
               , Decode(aid.unit_price, NULL, NULL, 'Precio Unit: '||aid.unit_price)
               ||Decode(aid.unit_price*aid.quantity_invoiced, NULL, NULL, v_sep||'Precio Unit x Cantidad Fac: '||aid.unit_price*aid.quantity_invoiced) Descripcion_Origen
               , aid.attribute10 --cp_id CR2567
            INTO
               -- 26-ENE-2009 rmoreno fin mod
                 p_o_compra_venta_pago
               , p_no_cuenta
               , p_fecha
               -- 26-ENE-2009 rmoreno fin mod
               , p_vendor_customer
               , p_factura_recibo
               , p_desc_producto_activo
               , p_cant_producto_activo
               , p_uom_producto_activo
               , p_otros
               , l_cp_id_flete
            FROM ap_invoices_all              ai
               , ap_invoice_distributions_all aid
               -- 26-ENE-2009 rmoreno inicio mod
               , po_vendors pv
               , po_distributions_all pda
               , po_headers_all ph
               -- 26-ENE-2009 rmoreno fin mod
            WHERE 1=1
            -- Invoices
            AND ai.invoice_id  = TO_NUMBER(p_reference_2)
            -- Distributions
            AND ai.invoice_id  = aid.invoice_id (+)
            AND aid.distribution_line_number (+) = TO_NUMBER(p_reference_3)
            -- 26-ENE-2009 rmoreno inicio mod
            AND pv.vendor_id   = ai.vendor_id(+)
            AND pda.po_distribution_id(+) = aid.po_distribution_id
            AND ph.po_header_id(+) = pda.po_header_id;
            -- 26-ENE-2009 rmoreno fin mod

            IF l_cc_id_provision IS NOT NULL AND
               l_cp_id_flete IS NOT NULL THEN
              BEGIN
                SELECT cp.numero_carta_porte
                     , iim.item_no
                     , iim.item_desc1
                INTO p_recepcion_CP
                   , p_no_producto_activo
                   , p_desc_producto_activo
                FROM xx_aco_cartas_porte_b cp
                   , ic_item_mst           iim
                WHERE 1=1
                AND iim.item_id = cp.item_id
                AND cp.carta_porte_id = l_cp_id_flete;
              EXCEPTION
                WHEN OTHERS THEN
                  p_recepcion_CP         := NULL;
                  p_no_producto_activo   := NULL;
                  p_desc_producto_activo := NULL;
              END;
            END IF;

            IF l_cp_id_flete IS NOT NULL THEN
              BEGIN
                SELECT ( SELECT vendor_name
                         FROM po_vendors
                         WHERE vendor_id = DECODE(cp.orgn_code_origen, NULL, cp.productor_id, pc.vendor_id) ) cia_origen
                     , ( SELECT whse_code||' - '||whse_name
                         FROM ic_whse_mst
                         WHERE whse_code = cp.whse_code_origen ) org_origen
                INTO p_cia_origen, p_org_origen
                FROM xx_aco_parametros_compania  pc
                   , xx_aco_cartas_porte_v       cp
                WHERE 1=1
                AND cp.org_id_from = pc.org_id
                AND cp.org_id_from = cp.org_id
                AND cp.carta_porte_id = l_cp_id_flete
                AND EXISTS
                ( SELECT DISTINCT ccm.segment2
                  FROM xx_aco_parametros_compania pc
                     , gl_code_combinations       cc1
                     , gl_code_combinations       cc2
                     , gl_code_combinations       cc3
                     , gl_code_combinations       cc4
                     , gl_code_combinations       ccm
                  WHERE 1=1
                  AND cc1.code_combination_id = pc.provision_account_id
                  AND cc2.code_combination_id = pc.flete_corto_terc_account_id
                  AND cc3.code_combination_id = pc.flete_corto_propio_account_id
                  AND cc4.code_combination_id = pc.flete_por_venta_account_id
                  AND ( cc1.segment2 = ccm.segment2 OR
                        cc2.segment2 = ccm.segment2 OR
                        cc3.segment2 = ccm.segment2 OR
                        cc4.segment2 = ccm.segment2
                      )
                  AND ccm.code_combination_id = p_code_comb_id
                );
              EXCEPTION
                WHEN OTHERS THEN
                  p_cia_origen := NULL;
                  p_org_origen := NULL;
              END;
            END IF;

          ELSE
           -- Para que la cuenta de pasivo muestre la lista
           -- de las ordenes de compra asociadas
           -- a esa factura
            FOR  r_c_purch_inv IN c_purch_inv (p_reference_1 ,
                                               p_reference_5 ,
                                               p_reference_2)
            LOOP

                -- p_o_compra_venta_pago :=  r_c_purch_inv.po_num ||' / '|| p_o_compra_venta_pago;
                -- Agregado por Quanam 30-06-2010 CGR
                -- Agrego logica para que no se repitan los datos
                IF (v_po_num_flag = 0 AND r_c_purch_inv.po_num IS NOT NULL) THEN
                    v_po_num_aux := r_c_purch_inv.po_num;
                    p_o_compra_venta_pago := r_c_purch_inv.po_num;
                    v_po_num_flag := 1;
                ELSE
                    IF (r_c_purch_inv.po_num != v_po_num_aux AND r_c_purch_inv.po_num IS NOT NULL) THEN
                        v_po_num_aux := r_c_purch_inv.po_num;
                        p_o_compra_venta_pago := p_o_compra_venta_pago||' / '||r_c_purch_inv.po_num;
                    END IF;
                END IF;

                -- p_no_cuenta:= r_c_purch_inv.vendor_num ||' / '|| p_no_cuenta;
                IF (v_vendor_num_flag = 0 AND r_c_purch_inv.vendor_num IS NOT NULL) THEN
                    v_vendor_num_aux := r_c_purch_inv.vendor_num;
                    p_no_cuenta := r_c_purch_inv.vendor_num;
                    v_vendor_num_flag := 1;
                ELSE
                    IF (r_c_purch_inv.vendor_num != v_vendor_num_aux AND r_c_purch_inv.vendor_num IS NOT NULL) THEN
                        v_vendor_num_aux := r_c_purch_inv.vendor_num;
                        p_no_cuenta := p_no_cuenta||' / '||r_c_purch_inv.vendor_num;
                    END IF;
                END IF;

                -- p_fecha    :=  r_c_purch_inv.invoice_date ||' / '|| p_fecha;
                IF (v_inv_date_flag = 0 AND r_c_purch_inv.invoice_date IS NOT NULL) THEN
                    v_inv_date_aux := r_c_purch_inv.invoice_date;
                    p_fecha := r_c_purch_inv.invoice_date;
                    v_inv_date_flag := 1;
                ELSE
                    IF (r_c_purch_inv.invoice_date != v_inv_date_aux AND r_c_purch_inv.invoice_date IS NOT NULL) THEN
                        v_inv_date_aux := r_c_purch_inv.invoice_date;
                        p_fecha := p_fecha||' / '||r_c_purch_inv.invoice_date;
                    END IF;
                END IF;

                -- p_vendor_customer := r_c_purch_inv.vendor_customer ||' / '||p_vendor_customer;
                IF (v_vendor_cust_flag = 0 AND r_c_purch_inv.vendor_customer IS NOT NULL) THEN
                    v_vendor_cust_aux := r_c_purch_inv.vendor_customer;
                    p_vendor_customer := r_c_purch_inv.vendor_customer;
                    v_vendor_cust_flag := 1;
                ELSE
                    IF (r_c_purch_inv.vendor_customer != v_vendor_cust_aux AND r_c_purch_inv.vendor_customer IS NOT NULL) THEN
                        v_vendor_cust_aux := r_c_purch_inv.vendor_customer;
                        p_vendor_customer := p_vendor_customer||' / '||r_c_purch_inv.vendor_customer;
                    END IF;
                END IF;

                -- p_factura_recibo  := r_c_purch_inv.factura_recibo ||' / '||p_factura_recibo;
                IF (v_fact_rec_flag = 0 AND r_c_purch_inv.factura_recibo IS NOT NULL) THEN
                    v_fact_rec_aux := r_c_purch_inv.factura_recibo;
                    p_factura_recibo := r_c_purch_inv.factura_recibo;
                    v_fact_rec_flag := 1;
                ELSE
                    IF (r_c_purch_inv.factura_recibo != v_fact_rec_aux AND r_c_purch_inv.factura_recibo IS NOT NULL) THEN
                        v_fact_rec_aux := r_c_purch_inv.factura_recibo;
                        p_factura_recibo := p_factura_recibo||' / '||r_c_purch_inv.factura_recibo;
                    END IF;
                END IF;

                -- p_no_producto_activo   := r_c_purch_inv.item_number||' / '||p_no_producto_activo;
                IF (v_item_num_flag = 0 AND r_c_purch_inv.item_number IS NOT NULL) THEN
                    v_item_num_aux := r_c_purch_inv.item_number;
                    p_no_producto_activo := r_c_purch_inv.item_number;
                    v_item_num_flag := 1;
                ELSE
                    IF (r_c_purch_inv.item_number != v_item_num_aux AND r_c_purch_inv.item_number IS NOT NULL) THEN
                        v_item_num_aux := r_c_purch_inv.item_number;
                        p_no_producto_activo := p_no_producto_activo||' / '||r_c_purch_inv.item_number;
                    END IF;
                END IF;

                -- p_desc_producto_activo := r_c_purch_inv.desc_producto_activo ||' / '||p_desc_producto_activo;
                IF (v_desc_prod_flag = 0 AND r_c_purch_inv.desc_producto_activo IS NOT NULL) THEN
                    v_desc_prod_aux := r_c_purch_inv.desc_producto_activo;
                    p_desc_producto_activo := r_c_purch_inv.desc_producto_activo;
                    v_desc_prod_flag := 1;
                ELSE
                    IF (r_c_purch_inv.desc_producto_activo != v_desc_prod_aux AND r_c_purch_inv.desc_producto_activo IS NOT NULL) THEN
                        v_desc_prod_aux := r_c_purch_inv.desc_producto_activo;
                        p_desc_producto_activo := p_desc_producto_activo||' / '||r_c_purch_inv.desc_producto_activo;
                    END IF;
                END IF;

                -- p_cant_producto_activo := r_c_purch_inv.cant_producto_activo ||' / '||p_cant_producto_activo;
                IF (v_cant_prod_flag = 0 AND r_c_purch_inv.cant_producto_activo IS NOT NULL) THEN
                    v_cant_prod_aux := r_c_purch_inv.cant_producto_activo;
                    p_cant_producto_activo := r_c_purch_inv.cant_producto_activo;
                    v_cant_prod_flag := 1;
                ELSE
                    IF (r_c_purch_inv.cant_producto_activo != v_cant_prod_aux AND r_c_purch_inv.cant_producto_activo IS NOT NULL) THEN
                        v_cant_prod_aux := r_c_purch_inv.cant_producto_activo;
                        p_cant_producto_activo := p_cant_producto_activo||' / '||r_c_purch_inv.cant_producto_activo;
                    END IF;
                END IF;

                -- p_uom_producto_activo  := r_c_purch_inv.uom_producto_activo ||' / '||p_uom_producto_activo;
                IF (v_uom_prod_flag = 0 AND r_c_purch_inv.uom_producto_activo IS NOT NULL) THEN
                    v_uom_prod_aux := r_c_purch_inv.uom_producto_activo;
                    p_uom_producto_activo := r_c_purch_inv.uom_producto_activo;
                    v_uom_prod_flag := 1;
                ELSE
                    IF (r_c_purch_inv.uom_producto_activo != v_uom_prod_aux AND r_c_purch_inv.uom_producto_activo IS NOT NULL) THEN
                        v_uom_prod_aux := r_c_purch_inv.uom_producto_activo;
                        p_uom_producto_activo := p_uom_producto_activo||' / '||r_c_purch_inv.uom_producto_activo;
                    END IF;
                END IF;

                -- p_otros                := r_c_purch_inv.otros ||' / '||p_otros;
                IF (v_otros_flag = 0 AND r_c_purch_inv.otros IS NOT NULL) THEN
                    v_otros_aux := r_c_purch_inv.otros;
                    p_otros := r_c_purch_inv.otros;
                    v_otros_flag := 1;
                ELSE
                    IF (r_c_purch_inv.otros != v_otros_aux AND r_c_purch_inv.otros IS NOT NULL) THEN
                        v_otros_aux := r_c_purch_inv.otros;
                        p_otros := p_otros||' / '||r_c_purch_inv.otros;
                    END IF;
                END IF;

               END LOOP;
            -- Agregado por Quanam 30-06-2010 CGR
            -- Inicializo las variables para una nueva corrida
            v_po_num_flag := 0;
            v_po_num_aux := NULL;
            v_vendor_num_flag := 0;
            v_vendor_num_aux := NULL;
            v_inv_date_flag := 0;
            v_inv_date_aux := NULL;
            v_vendor_cust_flag := 0;
            v_vendor_cust_aux := NULL;
            v_fact_rec_flag    := 0;
            v_fact_rec_aux := NULL;
            v_item_num_flag := 0;
            v_item_num_aux := NULL;
            v_desc_prod_flag := 0;
            v_desc_prod_aux    := NULL;
            v_cant_prod_flag := 0;
            v_cant_prod_aux := NULL;
            v_uom_prod_flag := 0;
            v_uom_prod_aux := NULL;
            v_otros_flag := 0;
            v_otros_aux := NULL;

          END IF;
          RETURN (TRUE);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RAISE e_nodatafo2;
          WHEN TOO_MANY_ROWS THEN
            RAISE e_toomaro;
          WHEN OTHERS THEN
            RAISE e_others;
        END;
      END IF;
    END IF;

    IF (p_source_code = 'Purchasing') THEN
      BEGIN
        SELECT Decode( p_reference_4, NULL, NULL, p_reference_4)
           -- Modificado por Quanam 14-06-2010 CGR
           -- , Decode( rct.quantity, NULL, NULL, rct.quantity)
           , DECODE(rct.transaction_type, 'RETURN TO VENDOR',(rct.quantity * -1)
                                        , 'RETURN TO RECEIVING',(rct.quantity * -1)
                                        , rct.quantity)
           -- Fin 14-06-2010 CGR
           , Decode( rct.uom_code, NULL, NULL, rct.uom_code)
           , Decode( rct.po_unit_price, NULL, NULL, rct.po_unit_price) Descripcion_Origen
           , pv.segment1
           , pv.vendor_name
           , rsh.RECEIPT_NUM
           , trunc(rct.transaction_date)
           , rsl.item_id
           , rct.organization_id
           , rsl.item_description
        INTO p_o_compra_venta_pago
           , p_cant_producto_activo
           , p_uom_producto_activo
           , p_otros
           , p_no_cuenta
           , p_vendor_customer
           , p_recepcion_cp
           , p_fecha
           , lv_item_id
           , lv_organization_id
           , lv_item_description
        FROM gl_import_references r
           , rcv_receiving_sub_ledger rrs
           , rcv_transactions rct
           , rcv_shipment_headers rsh
           , rcv_shipment_lines rsl
           , po_vendors pv
        WHERE 1=1
        AND    rrs.gl_sl_link_id           = r.gl_sl_link_id
        AND    rrs.rcv_transaction_id = TO_NUMBER (r.reference_5)
        AND    r.reference_5                = p_reference_5
        AND    r.gl_sl_link_table = 'RSL'
        AND    r.je_header_id      = p_header_id
        AND    r.je_line_num       = p_line_num
        AND    rct.transaction_id = rrs.rcv_transaction_id
        AND    rsh.shipment_header_id = rct.shipment_header_id
        AND    rsl.shipment_line_id         = rct.shipment_line_id
        AND   pv.vendor_id                           = rct.vendor_id   ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE e_nodatafo3;
        WHEN TOO_MANY_ROWS THEN
          RAISE e_toomaro;
        WHEN OTHERS THEN
          RAISE e_others;
      END;
      BEGIN
        IF lv_item_id IS NOT NULL THEN
          SELECT Decode( msi_kfv.description, NULL, NULL, msi_kfv.description)
               , msi_kfv.concatenated_segments
          INTO p_desc_producto_activo
             , p_no_producto_activo
          FROM mtl_system_items_kfv msi_kfv
          WHERE msi_kfv.inventory_item_id = lv_item_id
          AND lv_organization_id          = msi_kfv.organization_id;
        ELSE
          p_desc_producto_activo := lv_item_description;
        END IF;

        RETURN ( TRUE );
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE e_nodatafo3;
        WHEN TOO_MANY_ROWS THEN
          RAISE e_toomaro;
        WHEN OTHERS THEN
          RAISE e_others;
      END;

      RETURN (TRUE);
    END IF;

    IF (p_source_code = 'Assets') THEN
      IF (p_category_code = 'Depreciation') THEN
        BEGIN
          SELECT Decode(p_reference_2, NULL, NULL, p_reference_2) Descripcion_Origen
          INTO p_no_producto_activo
          FROM dual;

          RETURN (TRUE);
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
            RAISE e_nodatafo4;
          WHEN TOO_MANY_ROWS THEN
            RAISE e_toomaro;
          WHEN OTHERS THEN
            RAISE e_others;
        END;
      ELSIF (p_category_code != 'Depreciation') THEN
        BEGIN
          SELECT Decode(p_reference_2, NULL, NULL, p_reference_2)
               , Decode(fthtv.asset_number_desc, NULL, NULL, fthtv.asset_number_desc) Descripcion_Origen
          INTO p_no_producto_activo
             , p_desc_producto_activo
          FROM fa_transaction_history_trx_v fthtv
          WHERE fthtv.transaction_header_id = To_Number(p_reference_1);

          RETURN (TRUE);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RAISE e_nodatafo5;
          WHEN TOO_MANY_ROWS THEN
            RAISE e_toomaro;
          WHEN OTHERS THEN
            RAISE e_others;
        END;
      END IF;
    END IF;

    -- IC OPM Inventory Ctrl
    -- OP OPM Order Processing
    -- CM OPM costing
    IF ((p_source_code = 'IC') AND (p_category_code IN ('IADJ','INTA')) )THEN

      /* 14-feb-2012 Watea - MG: agregado tratamiento PIPH - inicio */
      IF P_REFERENCE_8 = 'PIPH' THEN
        BEGIN

          FOR r_ic_items_piph IN c_ic_items_piph (P_REFERENCE_1,
                                                  P_REFERENCE_5,
                                                  P_REFERENCE_8,
                                                  P_REFERENCE_9,
                                                  P_REFERENCE_6,
                                                  P_REFERENCE_7,
                                                  P_CODE_COMB_ID)
          LOOP
            p_no_producto_activo  := r_ic_items_piph.item_no     || '/ ' || p_no_producto_activo;
            p_desc_producto_activo:= r_ic_items_piph.description || '/ ' || p_desc_producto_activo;
            p_otros               := r_ic_items_piph.trans_um    || '/ ' || p_otros;
            p_cant_producto_activo:= r_ic_items_piph.trans_qty   || '/ ' || p_cant_producto_activo;
          END LOOP;
          --

          p_no_producto_activo  := substr(p_no_producto_activo,1,length(p_no_producto_activo)-2);
          p_desc_producto_activo:= substr(p_desc_producto_activo,1,length(p_desc_producto_activo)-2);
          p_otros               := substr(p_otros,1,length(p_otros)-2);
          p_cant_producto_activo:= substr(p_cant_producto_activo,1,length(p_cant_producto_activo)-2);

          RETURN (TRUE);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 RAISE e_nodatafo6;
            WHEN OTHERS THEN
                 RAISE e_others;
        END;
      END IF;
      /* 14-feb-2012 Watea - MG: agregado tratamiento PIPH - fin */

       BEGIN
        --OPM Inv Move-Intra
        --OPM Adjustments
        FOR r_ic_items IN c_ic_items (P_HEADER_ID,
                                      P_LINE_NUM,
                                      P_CODE_COMB_ID)
        LOOP

          p_no_producto_activo  := r_ic_items.item_no             || '/ ' || p_no_producto_activo;
          p_desc_producto_activo:= r_ic_items.item_desc1          || '/ ' || p_desc_producto_activo;
          p_otros               := r_ic_items.item_um             || '/ ' || p_otros;
          p_cant_producto_activo:= r_ic_items.descripcion_origen  || '/ ' || p_cant_producto_activo;
          p_chr_journal_comment := r_ic_items.journal_comment     || '/ ' || p_chr_journal_comment;

        END LOOP;

        p_no_producto_activo  := substr(p_no_producto_activo,1,length(p_no_producto_activo)-2);
        p_desc_producto_activo:= substr(p_desc_producto_activo,1,length(p_desc_producto_activo)-2);
        p_otros               := substr(p_otros,1,length(p_otros)-2);
        p_cant_producto_activo:= substr(p_cant_producto_activo,1,length(p_cant_producto_activo)-2);
        p_chr_journal_comment := substr(p_chr_journal_comment,1,length(p_chr_journal_comment)-2);

        RETURN (TRUE);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE e_nodatafo6;
        WHEN OTHERS THEN
          RAISE e_others;
      END;
    END IF;


  -- OPM Costing
    IF (p_source_code = 'CM')  THEN
      BEGIN
        IF ( nvl(  p_debit , 0) <> 0  OR ( p_debit = 0  AND p_debit = p_credit ) )THEN
          FOR  r_c_items IN c_cm_items (1) LOOP
            p_no_producto_activo :=  r_c_items.resource_item_no ||' / '|| p_no_producto_activo;
            p_desc_producto_activo:= r_c_items.resource_item_no_desc ||' / '|| p_desc_producto_activo;
            p_otros :=  r_c_items.trans_qty_usage_um ||' / '|| p_otros;
            p_cant_producto_activo := r_c_items.rval_quantity ||' / '||p_cant_producto_activo;
          END LOOP;
        ELSIF nvl(p_credit, 0)  <> 0 THEN
          FOR  r_c_items IN c_cm_items (-1) LOOP
            p_no_producto_activo :=  r_c_items.resource_item_no ||' / '|| p_no_producto_activo;
            p_desc_producto_activo:= r_c_items.resource_item_no_desc ||' / '|| p_desc_producto_activo;
            p_otros :=  r_c_items.trans_qty_usage_um ||' / '|| p_otros;
            p_cant_producto_activo := r_c_items.rval_quantity ||' / '||p_cant_producto_activo;
          END LOOP;
        END IF;

        p_no_producto_activo :=  p_no_producto_activo ||'.';
        p_desc_producto_activo:= p_desc_producto_activo ||'.';
        p_otros :=  p_otros||'.';
        p_cant_producto_activo := p_cant_producto_activo||'.';

        RETURN (TRUE);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE e_nodatafo6;
        WHEN TOO_MANY_ROWS THEN
          RAISE e_toomaro;
        WHEN OTHERS THEN
          RAISE e_others;
      END;
    END IF;

    IF (p_source_code = 'Receivables') THEN
      IF (p_category_code = 'Adjustment') THEN
        BEGIN
          SELECT Decode(cust_acct.account_number, NULL, NULL, cust_acct.account_number)
               , Decode(SubStrB(party.party_name,1,50), NULL, NULL, SubStrB(party.party_name,1,50))
               , Decode(RPad(adj.adjustment_number,20,' '), NULL, NULL, 'Numero Ajuste: '||RPad(adj.adjustment_number,20,' ')) Descripcion_Origen
            INTO p_no_cuenta
               , p_vendor_customer
               , p_otros
            FROM gl_import_references r
               , ar_distributions_all ard
               , ar_adjustments_all   adj
               , hz_cust_accounts     cust_acct
               , hz_parties           party
           WHERE r.je_header_id            = p_header_id
             AND r.je_line_num         = p_line_num
             AND ard.line_id               = To_Number(r.reference_3)
             AND ard.source_table          = 'ADJ'
             AND ard.source_id             = adj.adjustment_id
             AND Nvl(ard.org_id,-99)       = Nvl(adj.org_id,-99)
             AND cust_acct.cust_account_id = ard.third_party_id
             AND cust_acct.party_id        = party.party_id;
           RETURN (TRUE);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RAISE e_nodatafo7;
          WHEN TOO_MANY_ROWS THEN
            RAISE e_toomaro;
          WHEN OTHERS THEN
            RAISE e_others;
        END;
      ELSIF (p_category_code IN ('Credit Memos','Debit Memos','Sales Invoices')) THEN
        BEGIN
          SELECT Decode(CT.trx_number, NULL, NULL, CT.trx_number)
               , Decode(CT.trx_date, NULL, NULL, CT.trx_date)
               , Decode(cust_acct.account_number, NULL, NULL, cust_acct.account_number)
               , Decode(SubStrB(party.party_name,1,50), NULL, NULL, SubStrB(party.party_name,1,50))
               , Decode(Decode(CTL.line_number,NULL, RPad(CT.trx_number,20), Decode(CTL2.line_number,NULL, Decode(CTL.line_number,NULL,NULL, LPad(To_Number(CTL.line_number),15,'0') ), LPad(To_Number(CTL2.line_number),15,'0') || ', ' || LPad(To_Number(CTL.line_number),15,'0')) ), NULL, NULL, v_sep||'Numero Linea: '||Decode(CTL.line_number,NULL, RPad(CT.trx_number,20), Decode(CTL2.line_number,NULL, Decode(CTL.line_number,NULL,NULL, LPad(To_Number(CTL.line_number),15,'0') ), LPad(To_Number(CTL2.line_number),15,'0') || ', ' || LPad(To_Number(CTL.line_number),15,'0')) ))
               , Decode(CTL.quantity_invoiced, NULL, NULL, CTL.quantity_invoiced)
               , Decode(CTL.sales_order, NULL, NULL, CTL.sales_order)
               , Decode(MUOM.unit_of_measure, NULL, NULL, MUOM.unit_of_measure) Descripcion_Origen
               -- CR739 2013-06-10  apetrocelli
               , NVL( ( SELECT DISTINCT item_no
                        FROM ic_item_mst_b
                        WHERE 1=1
                        AND ( (     item_id = CTL.inventory_item_id
                                AND CTL.inventory_item_id IS NOT NULL ) OR
                              (     item_desc1 = CTL.description
                                AND CTL.inventory_item_id IS NULL )
                            )
                      ),
                      ( SELECT DISTINCT segment1
                        FROM mtl_system_items si
                        WHERE 1=1
                        AND ( (     si.inventory_item_id = CTL.inventory_item_id
                                AND CTL.inventory_item_id IS NOT NULL ) OR
                              (     si.description = CTL.description
                                AND CTL.inventory_item_id IS NULL )
                            )
                      )
                 ) item_no
               , CTL.description
               --
            INTO p_factura_recibo
               , p_fecha
               , p_no_cuenta
               , p_vendor_customer
               , p_otros
               , p_cant_producto_activo
               , p_o_compra_venta_pago
               , p_uom_producto_activo
               , p_no_producto_activo
               , p_desc_producto_activo
            FROM gl_import_references         R
               , ra_customer_trx_all          CT
               , hz_cust_accounts             CUST_ACCT
               , hz_parties                   PARTY
               , ra_customer_trx_lines_all    CTL
               , ra_customer_trx_lines_all    CTL2
               , mtl_units_of_measure         MUOM
               , ra_cust_trx_line_gl_dist_all CTLGD
           WHERE R.je_header_id                 = p_header_id
             AND R.je_line_num =  p_line_num
             AND R.reference_10                 = 'RA_CUST_TRX_LINE_GL_DIST'
             AND CT.bill_to_customer_id         = CUST_ACCT.cust_account_id
             AND CUST_ACCT.party_id             = PARTY.party_id
             AND CTL.link_to_cust_trx_line_id   = CTL2.customer_trx_line_id(+)
             AND Nvl(CTL.org_id,-99)            = Nvl(CTL2.org_id(+),-99)
             AND MUOM.uom_code(+)               = CTL.uom_code
             AND CTLGD.customer_trx_line_id     = CTL.customer_trx_line_id(+)
             AND Nvl(CTLGD.org_id,-99)          = Nvl(CTL.org_id(+),-99)
             AND CTLGD.account_set_flag         = 'N'
             AND CT.customer_trx_id             = CTLGD.customer_trx_id
             AND Nvl(CT.org_id,-99)             = Nvl(CTLGD.org_id,-99)
             AND CTLGD.cust_trx_line_gl_dist_id = To_Number(R.reference_3);
           RETURN (TRUE);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RAISE e_nodatafo8;
          WHEN TOO_MANY_ROWS THEN
            RAISE e_toomaro;
          WHEN OTHERS THEN
            RAISE e_others;
        END;
      ELSIF (p_category_code = 'Credit Memo Applications') THEN
        BEGIN
          SELECT Decode(CTCM.trx_number, NULL, NULL, CTCM.trx_number)
               , Decode(CTCM.trx_date, NULL, NULL, CTCM.trx_date)
               , Decode(CUST_ACCT.account_number, NULL, NULL, CUST_ACCT.account_number)
               , Decode(SubStrB(PARTY.party_name,1,50), NULL, NULL, SubStrB(PARTY.party_name,1,50))
               , Decode(CTINV.trx_number, NULL, NULL, 'Numero TRX Aplicada: '||CTINV.trx_number)
               || Decode(CTINV.trx_date, NULL, NULL, v_sep||'Fecha TRX Aplicada: '||CTINV.trx_date) Descripcion_Origen
               -- CR739 2013-06-10  apetrocelli
               , NVL( ( SELECT DISTINCT item_no
                        FROM ic_item_mst_b
                        WHERE 1=1
                        AND ( (     item_id = CTLINV.inventory_item_id
                                AND CTLINV.inventory_item_id IS NOT NULL ) OR
                              (     item_desc1 = CTLINV.description
                                AND CTLINV.inventory_item_id IS NULL )
                            )
                      ),
                      ( SELECT DISTINCT segment1
                        FROM mtl_system_items si
                        WHERE 1=1
                        AND ( (     si.inventory_item_id = CTLINV.inventory_item_id
                                AND CTLINV.inventory_item_id IS NOT NULL ) OR
                              (     si.description = CTLINV.description
                                AND CTLINV.inventory_item_id IS NULL )
                            )
                      )
                 ) item_no
               , CTLINV.description
               --
            INTO --p_o_compra_venta_pago
                 p_factura_recibo
               , p_fecha
               , p_no_cuenta
               , p_vendor_customer
               , p_otros
               , p_no_producto_activo
               , p_desc_producto_activo
            FROM gl_import_references           R
               , ar_receivable_applications_all RA
               , ra_customer_trx_all            CTCM
               , ar_distributions_all           ARD
               , ra_customer_trx_all            CTINV
               , ra_customer_trx_lines_all      CTLINV
               , hz_cust_accounts               CUST_ACCT
               , hz_parties                     PARTY
           WHERE R.je_header_id                 = p_header_id
             AND r.je_line_num                  = p_line_num
             AND ARD.line_id                    = To_Number(R.reference_3)
             AND ARD.source_table               = 'RA'
             AND ARD.source_id                  = RA.receivable_application_id
             AND Nvl(ARD.org_id,-99)            = Nvl(RA.org_id,-99)
             AND RA.application_type            = 'CM'
             AND Nvl(RA.postable,'Y')           = 'Y'
             AND Nvl(RA.confirmed_flag,'Y')     = 'Y'
             AND RA.customer_trx_id             = CTCM.customer_trx_id
             AND Nvl(RA.org_id,-99)             = Nvl(CTCM.org_id,-99)
             AND CTINV.customer_trx_id          = RA.applied_customer_trx_id
             AND Nvl(CTINV.org_id,-99)          = Nvl(RA.org_id,-99)
             AND CTLINV.customer_trx_line_id(+) = RA.applied_customer_trx_line_id
             AND Nvl(CTLINV.org_id(+),-99)      = Nvl(RA.org_id,-99)
             AND ard.third_party_id             = CUST_ACCT.cust_account_id
             AND CUST_ACCT.party_id             = PARTY.party_id;
        RETURN (TRUE);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RAISE e_nodatafo9;
          WHEN TOO_MANY_ROWS THEN
            RAISE e_toomaro;
          WHEN OTHERS THEN
            RAISE e_others;
        END;
      ELSIF (p_category_code IN ('Cross Currency','Misc Receipts','Trade Receipts')) THEN
        BEGIN
          FOR r_receivables IN c_receivables (p_header_id, p_category_code, p_line_num) LOOP
            --v_desc_origen := SubStr(v_desc_origen||' '||r_receivables.Descripcion_Origen, 1, 2000);
            p_factura_recibo  := substr(p_factura_recibo ||' '||r_receivables.recibo, 1, 2000);
            p_fecha           := substr(p_fecha          ||' '||r_receivables.fecha, 1, 2000);
            p_no_cuenta       := substr(p_no_cuenta      ||' '||r_receivables.no_cuenta, 1, 2000);
            p_vendor_customer := substr(p_vendor_customer||' '||r_receivables.cliente, 1, 2000);
          END LOOP;
          RETURN (TRUE);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RAISE e_nodatafo10;
          WHEN TOO_MANY_ROWS THEN
            RAISE e_toomaro;
          WHEN OTHERS THEN
            RAISE e_others;
        END;
      END IF;
    END IF;

    IF (p_source_code = 'Project Accounting') THEN
      BEGIN
        SELECT Decode(pp.name, NULL, NULL, 'Nombre Proyecto:'||pp.name)
             ||Decode(pt.task_name, NULL, NULL, v_sep||'Nombre Tarea: '||pt.task_name) Descripcion_Origen
          INTO p_otros
          FROM gl_code_combinations_kfv       gcck
             , pa_cost_distribution_lines_all pcdl
             , pa_projects_all                pp
             , pa_tasks                       pt
         WHERE gcck.code_combination_id = p_code_comb_id
           AND pcdl.batch_name          = p_reference_1
           AND pcdl.project_id          = pp.project_id
           AND pcdl.project_id          = pt.project_id
           AND pcdl.task_id             = pt.task_id;
          RETURN (TRUE);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE e_nodatafo11;
        WHEN TOO_MANY_ROWS THEN
          RAISE e_toomaro;
        WHEN OTHERS THEN
          RAISE e_others;
      END;
    END IF;

    IF p_source_code = 'XX_ACOPIO' THEN
      BEGIN
        SELECT Decode(p_reference_2, NULL, NULL, p_reference_2) Descripcion_Origen
          INTO p_o_compra_venta_pago
          FROM gl_code_combinations_kfv gcck
         WHERE gcck.code_combination_id = p_code_comb_id;
          RETURN (TRUE);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE e_nodatafo12;
        WHEN TOO_MANY_ROWS THEN
          RAISE e_toomaro;
        WHEN OTHERS THEN
          RAISE e_others;
      END;
    END IF;
-- -----------------------------------------------------------------------------
-- Agrego los origenes que faltaban
-- -----------------------------------------------------------------------------
    IF p_source_code = 'Acopio Fletes' THEN
      BEGIN
        SELECT ( SELECT vendor_name
                 FROM po_vendors
                 WHERE vendor_id = DECODE(cp.orgn_code_origen, NULL, cp.productor_id, pc.vendor_id) ) cia_origen
             , ( SELECT whse_code||' - '||whse_name
                 FROM ic_whse_mst
                 WHERE whse_code = cp.whse_code_origen ) org_origen
        INTO p_cia_origen, p_org_origen
        FROM xx_aco_parametros_compania  pc
           , xx_aco_cartas_porte_v       cp
        WHERE 1=1
        AND cp.org_id_from = pc.org_id
        AND cp.org_id_from = cp.org_id
        AND cp.carta_porte_id = p_reference_1
        AND EXISTS
        ( SELECT DISTINCT ccm.segment2
          FROM xx_aco_parametros_compania pc
             , gl_code_combinations       cc1
             , gl_code_combinations       cc2
             , gl_code_combinations       cc3
             , gl_code_combinations       cc4
             , gl_code_combinations       ccm
          WHERE 1=1
          AND cc1.code_combination_id = pc.provision_account_id
          AND cc2.code_combination_id = pc.flete_corto_terc_account_id
          AND cc3.code_combination_id = pc.flete_corto_propio_account_id
          AND cc4.code_combination_id = pc.flete_por_venta_account_id
          AND ( cc1.segment2 = ccm.segment2 OR
                cc2.segment2 = ccm.segment2 OR
                cc3.segment2 = ccm.segment2 OR
                cc4.segment2 = ccm.segment2
              )
          AND ccm.code_combination_id = p_code_comb_id
        );

        p_otros := NULL;
      EXCEPTION
        WHEN OTHERS THEN
          p_cia_origen := NULL;
          p_org_origen := NULL;
      END;

      IF p_category_code = 'Provision Acopio' THEN
        BEGIN
          SELECT DECODE(gjh.currency_conversion_date, NULL, NULL, 'Fecha contable '||gjh.currency_conversion_date)
                 ||DECODE(gjl.effective_date, NULL, NULL, v_sep||'Fecha transaccion '|| gjl.effective_date) FECHA,
                 (SELECT numero_carta_porte
                    FROM xx_aco_cartas_porte_b
                   WHERE carta_porte_id = gjl.reference_1
                     AND rownum = 1)    "C.P. Ref Interna",
                 DECODE(gjl.reference_3, NULL, NULL, gjl.reference_3) "Proveedor",
                 DECODE(gjl.reference_4, NULL, NULL, 'Origen '||gjl.reference_4)    "Origen"
          INTO   p_fecha
               , p_recepcion_CP
               , p_vendor_customer
               , p_otros
          FROM   gl_je_lines gjl,
                 gl_je_headers gjh,
                 gl_code_combinations_kfv gcck,
                 gl_je_sources gjs,
                 gl_je_categories gjc
          WHERE gjl.je_header_id = gjh.je_header_id
          and   gcck.code_combination_id = gjl.code_combination_id
          and   gjh.je_source =  gjs.je_source_name
          and   gjh.je_category =  gjc.je_category_name
          and   gjl.status = 'P'
          and   gjh.je_source = 'Acopio Fletes'
          and   gjh.je_header_id =  p_header_id
          and   gjl.je_line_num  =  p_line_num
          and   gjl.code_combination_id = p_code_comb_id ;

          IF p_cia_origen IS NOT NULL THEN
            p_otros := NULL;
          END IF;

          BEGIN
            SELECT ai.invoice_num
                 , iim.item_no
                 , iim.item_desc1
            INTO p_factura_recibo
               , p_no_producto_activo
               , p_desc_producto_activo
            FROM xx_aco_cartas_porte_b cp
               , ap_invoices_all       ai
               , ic_item_mst           iim
            WHERE 1=1
            AND ai.invoice_id(+) = cp.id_factura_ap
            AND iim.item_id(+)   = cp.item_id
            AND cp.numero_carta_porte = p_recepcion_CP;
          EXCEPTION
            WHEN OTHERS THEN
              p_factura_recibo       := NULL;
              p_no_producto_activo   := NULL;
              p_desc_producto_activo := NULL;
          END;

          RETURN ( TRUE );
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RAISE e_nodatafo13;
          WHEN TOO_MANY_ROWS THEN
            RAISE e_toomaro;
          WHEN OTHERS THEN
            RAISE e_others;
        END;
      END IF;

    END IF;

    IF p_source_code = 'OM' THEN

      BEGIN

        IF (p_category_code = 'OMSP') THEN


          FOR  r_c_om_items_omsp IN c_om_items_omsp (p_header_id,
                                                     p_line_num,
                                                     p_code_comb_id)
          LOOP

            p_fecha               := r_c_om_items_omsp.effective_date ||'/ '|| p_fecha;
            p_cant_producto_activo:= r_c_om_items_omsp.trans_qty      ||'/ '|| p_cant_producto_activo;
            p_otros               := r_c_om_items_omsp.trans_um       ||'/ '|| p_otros;
            p_no_producto_activo  := r_c_om_items_omsp.item_no        ||'/ '|| p_no_producto_activo;
            p_desc_producto_activo:= r_c_om_items_omsp.item_desc1     ||'/ '|| p_desc_producto_activo;
            p_o_compra_venta_pago := r_c_om_items_omsp.order_number   ||'/ '|| p_o_compra_venta_pago;
            p_no_cuenta           := r_c_om_items_omsp.customer_number||'/ '|| p_no_cuenta;
            p_vendor_customer     := r_c_om_items_omsp.customer_name  ||'/ '|| p_vendor_customer;

          END LOOP;

          p_fecha               := substr(p_fecha,1,length(p_fecha)-2);
          p_cant_producto_activo:= substr(p_cant_producto_activo,1,length(p_cant_producto_activo)-2)||'.';
          p_otros               := substr(p_otros,1,length(p_otros)-2);
          p_no_producto_activo  := substr(p_no_producto_activo,1,length(p_no_producto_activo)-2);
          p_desc_producto_activo:= substr(p_desc_producto_activo,1,length(p_desc_producto_activo)-2);
          p_o_compra_venta_pago := substr(p_o_compra_venta_pago,1,length(p_o_compra_venta_pago)-2);
          p_no_cuenta           := substr(p_no_cuenta,1,length(p_no_cuenta)-2);
          p_vendor_customer     := substr(p_vendor_customer,1,length(p_vendor_customer)-2);

        ELSIF (p_category_code = 'RMA') THEN


          FOR r_c_om_items_rma IN c_om_items_rma (p_header_id,
                                                  p_line_num,
                                                  p_code_comb_id)
          LOOP

            p_fecha               := r_c_om_items_rma.effective_date ||'/ '|| p_fecha;
            p_cant_producto_activo:= r_c_om_items_rma.trans_qty      ||'/ '|| p_cant_producto_activo;
            p_otros               := r_c_om_items_rma.trans_um       ||'/ '|| p_otros;
            p_no_producto_activo  := r_c_om_items_rma.item_no        ||'/ '|| p_no_producto_activo;
            p_desc_producto_activo:= r_c_om_items_rma.item_desc1     ||'/ '|| p_desc_producto_activo;
            p_o_compra_venta_pago := r_c_om_items_rma.order_number   ||'/ '|| p_o_compra_venta_pago;
            p_no_cuenta           := r_c_om_items_rma.customer_number||'/ '|| p_no_cuenta;
            p_vendor_customer     := r_c_om_items_rma.customer_name  ||'/ '|| p_vendor_customer;

          END LOOP;

          p_fecha               := substr(p_fecha,1,length(p_fecha)-2);
          p_cant_producto_activo:= substr(p_cant_producto_activo,1,length(p_cant_producto_activo)-2)||'.';
          p_otros               := substr(p_otros,1,length(p_otros)-2);
          p_no_producto_activo  := substr(p_no_producto_activo,1,length(p_no_producto_activo)-2);
          p_desc_producto_activo:= substr(p_desc_producto_activo,1,length(p_desc_producto_activo)-2);
          p_o_compra_venta_pago := substr(p_o_compra_venta_pago,1,length(p_o_compra_venta_pago)-2);
          p_no_cuenta           := substr(p_no_cuenta,1,length(p_no_cuenta)-2);
          p_vendor_customer     := substr(p_vendor_customer,1,length(p_vendor_customer)-2);

        END IF;

        RETURN ( TRUE );
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RAISE e_nodatafo14;
          WHEN TOO_MANY_ROWS THEN
            RAISE e_toomaro;
          WHEN OTHERS THEN
            RAISE e_others;
        END;
    END IF;

    IF p_source_code = '41' THEN
      BEGIN
        SELECT DECODE(gjh.currency_conversion_date, NULL, NULL, 'Fecha contable '||gjh.currency_conversion_date)
               ||DECODE(gjl.effective_date, NULL, NULL, v_sep||'Fecha transaccion '|| gjl.effective_date) FECHA,
               (SELECT numero_carta_porte
                  FROM xx_aco_cartas_porte_b
                 WHERE carta_porte_id = gjl.reference_1
                   AND rownum = 1)    "C.P. Ref Interna",
               DECODE(gjl.reference_3, NULL, NULL, gjl.reference_3) "Proveedor",
               DECODE(gjl.reference_4, NULL, NULL, 'Origen '||gjl.reference_4)    "Origen",
               xac.numero_contrato
        INTO   p_fecha
             , p_recepcion_CP
             , p_vendor_customer
             , p_otros
             , p_o_compra_venta_pago
        FROM   gl_je_lines gjl,
               gl_je_headers gjh,
               gl_code_combinations_kfv gcck,
               gl_je_sources gjs,
               gl_je_categories gjc ,
               ic_whse_mst  iwm,
               xx_aco_contratos xac
        WHERE gjl.je_header_id = gjh.je_header_id and
              gcck.code_combination_id = gjl.code_combination_id and
              gjh.je_source =  gjs.je_source_name and
              gjh.je_category =  gjc.je_category_name and
              gjl.status = 'P' and
              gjh.je_source = p_source_code
        and gjh.je_header_id =  p_header_id
        and gjl.je_line_num  =  p_line_num
        and gjl.code_combination_id = p_code_comb_id
        and  xac.whse_code_origen = iwm.whse_code(+)
        and  xac.numero_contrato(+) = gjl.reference_2;

        RETURN ( TRUE );
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE e_nodatafo15;
        WHEN TOO_MANY_ROWS THEN
          RAISE e_toomaro;
        WHEN OTHERS THEN
          RAISE e_others;
      END;
    END IF;

   --  Obtengo los datos para las lineas
   --  con origen Purchasing/ OPM
   --  je_source = 'PUR'
    IF p_source_code ='PUR' THEN
      --
      --           t.quantity
      --       , uom.um_code          trans_qty_usage_um
      --       , t.po_unit_price         otros
      --       , pv.segment1          vendor_num
      --       , pv.vendor_name
      --       , rsh.receipt_num
      --       , t.transaction_date
      --       , i.item_no                    resource_item_no
      --       , i.item_desc1             resource_item_no_desc
      --       , ph.segment1             po_num
      --
      IF ( nvl(  p_debit , 0) <> 0  OR ( p_debit = 0  AND p_debit = p_credit ) )THEN
        FOR  r_c_pur_items IN c_pur_items (1, 1) LOOP --Receipt
          IF c_pur_items%ROWCOUNT = 1 THEN
            l_dummy_chr    := r_c_pur_items.receipt_num;
            p_recepcion_CP := r_c_pur_items.receipt_num;
          ELSIF l_dummy_chr != r_c_pur_items.receipt_num THEN
            l_dummy_chr    := r_c_pur_items.receipt_num;
            p_recepcion_CP := p_recepcion_CP||' / '||r_c_pur_items.receipt_num;
          END IF;
        END LOOP; --Receipt

        FOR  r_c_pur_items IN c_pur_items (1, 2) LOOP --Vendor
          IF c_pur_items%ROWCOUNT = 1 THEN
            l_dummy_chr        := r_c_pur_items.vendor_num;
            p_no_cuenta        := r_c_pur_items.vendor_num;
            p_vendor_customer  := r_c_pur_items.vendor_name;
          ELSIF l_dummy_chr != r_c_pur_items.vendor_num THEN
            l_dummy_chr        := r_c_pur_items.vendor_num;
            p_no_cuenta        := p_no_cuenta       ||' / '||r_c_pur_items.vendor_num;
            p_vendor_customer  := p_vendor_customer ||' / '||r_c_pur_items.vendor_name;
          END IF;
        END LOOP; --Vendor

        FOR  r_c_pur_items IN c_pur_items (1, 3) LOOP --Trx_Date
          IF c_pur_items%ROWCOUNT = 1 THEN
            l_dummy_chr := TO_CHAR(r_c_pur_items.transaction_date, 'YYYY/MM/DD HH24:MI:SS');
            p_fecha     := r_c_pur_items.transaction_date;
          ELSIF l_dummy_chr != TO_CHAR(r_c_pur_items.transaction_date, 'YYYY/MM/DD HH24:MI:SS') THEN
            l_dummy_chr := TO_CHAR(r_c_pur_items.transaction_date, 'YYYY/MM/DD HH24:MI:SS');
            p_fecha     := r_c_pur_items.transaction_date;
          END IF;
        END LOOP; --Trx_Date

        FOR  r_c_pur_items IN c_pur_items (1, 4) LOOP --PO_Num
          IF c_pur_items%ROWCOUNT = 1 THEN
            l_dummy_chr           := r_c_pur_items.po_num;
            p_o_compra_venta_pago := r_c_pur_items.po_num;
          ELSIF l_dummy_chr != r_c_pur_items.po_num THEN
            l_dummy_chr           := r_c_pur_items.po_num;
            p_o_compra_venta_pago := p_o_compra_venta_pago||' / '||r_c_pur_items.po_num;
          END IF;
        END LOOP; --PO_Num

        FOR  r_c_pur_items IN c_pur_items (1, 5) LOOP --Item
          IF c_pur_items%ROWCOUNT = 1 THEN
            l_dummy_chr              := r_c_pur_items.resource_item_no;
            p_no_producto_activo     := r_c_pur_items.resource_item_no;
            p_desc_producto_activo   := r_c_pur_items.resource_item_no_desc;
            p_otros                  := r_c_pur_items.trans_qty_usage_um;
            p_cant_producto_activo   := r_c_pur_items.quantity;
          ELSIF l_dummy_chr != r_c_pur_items.resource_item_no THEN
            l_dummy_chr              := r_c_pur_items.resource_item_no;
            p_no_producto_activo     := p_no_producto_activo  ||' / '||r_c_pur_items.resource_item_no;
            p_desc_producto_activo   := p_desc_producto_activo||' / '||r_c_pur_items.resource_item_no_desc;
            p_otros                  := p_otros               ||' / '||r_c_pur_items.trans_qty_usage_um;
            p_cant_producto_activo   := p_cant_producto_activo||' / '||r_c_pur_items.quantity;
          END IF;
        END LOOP; --Item

      ELSIF nvl(p_credit, 0)  <> 0 THEN
        FOR  r_c_pur_items IN c_pur_items (-1, 1) LOOP --Receipt
          IF c_pur_items%ROWCOUNT = 1 THEN
            l_dummy_chr    := r_c_pur_items.receipt_num;
            p_recepcion_CP := r_c_pur_items.receipt_num;
          ELSIF l_dummy_chr != r_c_pur_items.receipt_num THEN
            l_dummy_chr    := r_c_pur_items.receipt_num;
            p_recepcion_CP := p_recepcion_CP||' / '||r_c_pur_items.receipt_num;
          END IF;
        END LOOP; --Receipt

        FOR  r_c_pur_items IN c_pur_items (-1, 2) LOOP --Vendor
          IF c_pur_items%ROWCOUNT = 1 THEN
            l_dummy_chr        := r_c_pur_items.vendor_num;
            p_no_cuenta        := r_c_pur_items.vendor_num;
            p_vendor_customer  := r_c_pur_items.vendor_name;
          ELSIF l_dummy_chr != r_c_pur_items.vendor_num THEN
            l_dummy_chr        := r_c_pur_items.vendor_num;
            p_no_cuenta        := p_no_cuenta       ||' / '||r_c_pur_items.vendor_num;
            p_vendor_customer  := p_vendor_customer ||' / '||r_c_pur_items.vendor_name;
          END IF;
        END LOOP; --Vendor

        FOR  r_c_pur_items IN c_pur_items (-1, 3) LOOP --Trx_Date
          IF c_pur_items%ROWCOUNT = 1 THEN
            l_dummy_chr := TO_CHAR(r_c_pur_items.transaction_date, 'YYYY/MM/DD HH24:MI:SS');
            p_fecha     := r_c_pur_items.transaction_date;
          ELSIF l_dummy_chr != TO_CHAR(r_c_pur_items.transaction_date, 'YYYY/MM/DD HH24:MI:SS') THEN
            l_dummy_chr := TO_CHAR(r_c_pur_items.transaction_date, 'YYYY/MM/DD HH24:MI:SS');
            p_fecha     := r_c_pur_items.transaction_date;
          END IF;
        END LOOP; --Trx_Date

        FOR  r_c_pur_items IN c_pur_items (-1, 4) LOOP --PO_Num
          IF c_pur_items%ROWCOUNT = 1 THEN
            l_dummy_chr           := r_c_pur_items.po_num;
            p_o_compra_venta_pago := r_c_pur_items.po_num;
          ELSIF l_dummy_chr != r_c_pur_items.po_num THEN
            l_dummy_chr           := r_c_pur_items.po_num;
            p_o_compra_venta_pago := p_o_compra_venta_pago||' / '||r_c_pur_items.po_num;
          END IF;
        END LOOP; --PO_Num

        FOR  r_c_pur_items IN c_pur_items (-1, 5) LOOP --Item
          IF c_pur_items%ROWCOUNT = 1 THEN
            l_dummy_chr              := r_c_pur_items.resource_item_no;
            p_no_producto_activo     := r_c_pur_items.resource_item_no;
            p_desc_producto_activo   := r_c_pur_items.resource_item_no_desc;
            p_otros                  := r_c_pur_items.trans_qty_usage_um;
            p_cant_producto_activo   := r_c_pur_items.quantity;
          ELSIF l_dummy_chr != r_c_pur_items.resource_item_no THEN
            l_dummy_chr              := r_c_pur_items.resource_item_no;
            p_no_producto_activo     := p_no_producto_activo  ||' / '||r_c_pur_items.resource_item_no;
            p_desc_producto_activo   := p_desc_producto_activo||' / '||r_c_pur_items.resource_item_no_desc;
            p_otros                  := p_otros               ||' / '||r_c_pur_items.trans_qty_usage_um;
            p_cant_producto_activo   := p_cant_producto_activo||' / '||r_c_pur_items.quantity;
          END IF;
        END LOOP; --Item
      END IF;

      p_no_producto_activo :=  p_no_producto_activo ||'.';
      p_desc_producto_activo:= p_desc_producto_activo ||'.';
      p_otros :=  p_otros||'.';
      p_cant_producto_activo := p_cant_producto_activo||'.';

      RETURN (TRUE);
    END IF;

    RETURN ( TRUE );
  EXCEPTION
    WHEN e_nodatafo1 THEN
      xx_debug_pk.debug('Datos: je header id: '||p_header_id||', je line num: '||p_line_num||', je source: '||p_source_code||'y je category: '||p_category_code||'. Texto: '||SQLERRM);
      p_otros := 'No hay datos 1';
      RETURN (TRUE);
    WHEN e_nodatafo2 THEN
      xx_debug_pk.debug('Datos: je header id: '||p_header_id||', je line num: '||p_line_num||', je source: '||p_source_code||'y je category: '||p_category_code||'. Texto: '||SQLERRM);
      p_otros := 'No hay datos 2';
      RETURN (TRUE);
    WHEN e_nodatafo3 THEN
      xx_debug_pk.debug('Datos: je header id: '||p_header_id||', je line num: '||p_line_num||', je source: '||p_source_code||'y je category: '||p_category_code||'. Texto: '||SQLERRM);
      p_otros := 'No hay datos 3';
      RETURN (TRUE);
    WHEN e_nodatafo4 THEN
      xx_debug_pk.debug('Datos: je header id: '||p_header_id||', je line num: '||p_line_num||', je source: '||p_source_code||'y je category: '||p_category_code||'. Texto: '||SQLERRM);
      p_otros := 'No hay datos 4';
      RETURN (TRUE);
    WHEN e_nodatafo5 THEN
      xx_debug_pk.debug('Datos: je header id: '||p_header_id||', je line num: '||p_line_num||', je source: '||p_source_code||'y je category: '||p_category_code||'. Texto: '||SQLERRM);
      p_otros := 'No hay datos 5';
      RETURN (TRUE);
    WHEN e_nodatafo6 THEN
      xx_debug_pk.debug('Datos: je header id: '||p_header_id||', je line num: '||p_line_num||', je source: '||p_source_code||'y je category: '||p_category_code||'. Texto: '||SQLERRM);
      p_otros := 'No hay datos 6';
      RETURN (TRUE);
    WHEN e_nodatafo7 THEN
      xx_debug_pk.debug('Datos: je header id: '||p_header_id||', je line num: '||p_line_num||', je source: '||p_source_code||'y je category: '||p_category_code||'. Texto: '||SQLERRM);
      p_otros := 'No hay datos 7';
      RETURN (TRUE);
    WHEN e_nodatafo8 THEN
      xx_debug_pk.debug('Datos: je header id: '||p_header_id||', je line num: '||p_line_num||', je source: '||p_source_code||'y je category: '||p_category_code||'. Texto: '||SQLERRM);
      p_otros := 'No hay datos 8';
      RETURN (TRUE);
    WHEN e_nodatafo9 THEN
      xx_debug_pk.debug('Datos: je header id: '||p_header_id||', je line num: '||p_line_num||', je source: '||p_source_code||'y je category: '||p_category_code||'. Texto: '||SQLERRM);
      p_otros := 'No hay datos 9';
      RETURN (TRUE);
    WHEN e_nodatafo10 THEN
      xx_debug_pk.debug('Datos: je header id: '||p_header_id||', je line num: '||p_line_num||', je source: '||p_source_code||'y je category: '||p_category_code||'. Texto: '||SQLERRM);
      p_otros := 'No hay datos 10';
      RETURN (TRUE);
    WHEN e_nodatafo11 THEN
      xx_debug_pk.debug('Datos: je header id: '||p_header_id||', je line num: '||p_line_num||', je source: '||p_source_code||'y je category: '||p_category_code||'. Texto: '||SQLERRM);
      p_otros := 'No hay datos 11';
      RETURN (TRUE);
    WHEN e_nodatafo12 THEN
      xx_debug_pk.debug('Datos: je header id: '||p_header_id||', je line num: '||p_line_num||', je source: '||p_source_code||'y je category: '||p_category_code||'. Texto: '||SQLERRM);
      p_otros := 'No hay datos 12';
      RETURN (TRUE);
    WHEN e_nodatafo13 THEN
      xx_debug_pk.debug('Datos: je header id: '||p_header_id||', je line num: '||p_line_num||', je source: '||p_source_code||'y je category: '||p_category_code||'. Texto: '||SQLERRM);
      p_otros := 'No hay datos 13';
      RETURN (TRUE);
    WHEN e_nodatafo14 THEN
      xx_debug_pk.debug('Datos: je header id: '||p_header_id||', je line num: '||p_line_num||', je source: '||p_source_code||'y je category: '||p_category_code||'. Texto: '||SQLERRM);
      p_otros := 'No hay datos 14';
      RETURN ( TRUE );
     WHEN e_nodatafo15 THEN
      xx_debug_pk.debug('Datos: je header id: '||p_header_id||', je line num: '||p_line_num||', je source: '||p_source_code||'y je category: '||p_category_code||'. Texto: '||SQLERRM);
      p_otros := 'No hay datos 15';
      RETURN ( TRUE );
     WHEN e_nodatafo16 THEN
      xx_debug_pk.debug('Datos: je header id: '||p_header_id||', je line num: '||p_line_num||', je source: '||p_source_code||'y je category: '||p_category_code||'. Texto: '||SQLERRM);
      p_otros := 'No hay datos 16';
      RETURN (TRUE);
    WHEN e_toomaro THEN
      xx_debug_pk.debug('Datos: je header id: '||p_header_id||', je line num: '||p_line_num||', je source: '||p_source_code||'y je category: '||p_category_code||'. Texto: '||SQLERRM);
  -- Agregado 13/12/2011 asilva
      p_no_producto_activo:= '';
      p_desc_producto_activo:= 'Varios items';
   --
      p_otros := 'Varias filas';
      RETURN (TRUE);
    WHEN e_others THEN
      xx_debug_pk.debug('Datos: je header id: '||p_header_id||', je line num: '||p_line_num||', je source: '||p_source_code||'y je category: '||p_category_code||'. Texto: '||SQLERRM);
      p_otros := 'Error otros';
      RETURN (TRUE);
  END principal$NonSLA;

--New R12, 11i version rename to principal$NonSLA
  FUNCTION principal ( p_source_code           IN VARCHAR2
                     , p_category_code         IN VARCHAR2
                     , p_header_id             IN NUMBER
                     , p_line_num              IN NUMBER
                     , p_code_comb_id          IN NUMBER
                     , p_reference_1           IN VARCHAR2
                     , p_reference_2           IN VARCHAR2
                     , p_reference_3           IN VARCHAR2
                     , p_reference_4           IN VARCHAR2
                     , p_reference_5           IN VARCHAR2
                     , p_reference_9           IN VARCHAR2
                     , p_reference_6           IN VARCHAR2
                     , p_reference_7           IN VARCHAR2
                     , p_reference_8           IN VARCHAR2
                     , p_reference_10          IN VARCHAR2
                     , p_debit                 IN NUMBER
                     , p_credit                IN NUMBER
                     --, p_desc_origen          OUT VARCHAR2
                     , p_vendor_customer      OUT VARCHAR2
                     , p_factura_recibo       OUT VARCHAR2
                     , p_recepcion_CP         OUT VARCHAR2
                     , p_o_compra_venta_pago  OUT VARCHAR2
                     , p_fecha                OUT VARCHAR2
                     , p_no_cuenta            OUT VARCHAR2
                     , p_no_cheque            OUT VARCHAR2
                     , p_no_producto_activo   OUT VARCHAR2
                     , p_desc_producto_activo OUT VARCHAR2
                     , p_uom_producto_activo  OUT VARCHAR2
                     , p_cant_producto_activo OUT VARCHAR2
                     , p_chr_journal_comment  OUT VARCHAR2
                     , p_otros                OUT VARCHAR2
                     , p_cia_origen           OUT VARCHAR2
                     , p_org_origen           OUT VARCHAR2
                     ) RETURN BOOLEAN IS

    l_sep CONSTANT VARCHAR2(2) := '; ';
    x_sep          VARCHAR2(1);

    t_gl_sl_link_id     VARCHAR2(2000);
    l_gl_sl_link_id     gl_import_references.gl_sl_link_id%TYPE;
    l_gl_sl_link_table  gl_import_references.gl_sl_link_table%TYPE;
    l_je_from_sla_flag  VARCHAR2(1);
    l_je_category       gl_je_headers.je_category%TYPE;
    l_je_source         gl_je_headers.je_source%TYPE;
    l_application_id    NUMBER(15);
    l_entity_code       VARCHAR2(30);
    l_source_id_int_1   NUMBER(38);
    l_source_id_int_2   NUMBER(38);
    l_source_id_int_3   NUMBER(38);
    l_source_id_char_1  VARCHAR2(30);
    l_source_line_table VARCHAR2(30);
    l_source_line_id    NUMBER(38);
    l_ae_header_id      NUMBER(38);
    l_ae_line_num       NUMBER(38);
    l_inv_org_id        NUMBER(38);

    l_return_status     BOOLEAN;
    l_calling_sequence  VARCHAR2(2000);
    l_debug_info        VARCHAR2(2000);

    l_vendor_customer      VARCHAR2_TABLE_2000 DEFAULT VARCHAR2_TABLE_2000();
    l_factura_recibo       VARCHAR2_TABLE_2000 DEFAULT VARCHAR2_TABLE_2000();
    l_recepcion_CP         VARCHAR2_TABLE_2000 DEFAULT VARCHAR2_TABLE_2000();
    l_o_compra_venta_pago  VARCHAR2_TABLE_2000 DEFAULT VARCHAR2_TABLE_2000();
    l_fecha                VARCHAR2_TABLE_2000 DEFAULT VARCHAR2_TABLE_2000();
    l_no_cuenta            VARCHAR2_TABLE_2000 DEFAULT VARCHAR2_TABLE_2000();
    l_no_cheque            VARCHAR2_TABLE_2000 DEFAULT VARCHAR2_TABLE_2000();
    l_no_producto_activo   VARCHAR2_TABLE_2000 DEFAULT VARCHAR2_TABLE_2000();
    l_desc_producto_activo VARCHAR2_TABLE_2000 DEFAULT VARCHAR2_TABLE_2000();
    l_uom_producto_activo  VARCHAR2_TABLE_2000 DEFAULT VARCHAR2_TABLE_2000();
    l_cant_producto_activo VARCHAR2_TABLE_2000 DEFAULT VARCHAR2_TABLE_2000();
    l_chr_journal_comment  VARCHAR2_TABLE_2000 DEFAULT VARCHAR2_TABLE_2000();
    l_otros                VARCHAR2_TABLE_2000 DEFAULT VARCHAR2_TABLE_2000();
    l_cia_origen           VARCHAR2_TABLE_2000 DEFAULT VARCHAR2_TABLE_2000();
    l_org_origen           VARCHAR2_TABLE_2000 DEFAULT VARCHAR2_TABLE_2000();

    x_vendor_customer      VARCHAR2(4000);
    x_factura_recibo       VARCHAR2(4000);
    x_recepcion_CP         VARCHAR2(4000);
    x_o_compra_venta_pago  VARCHAR2(4000);
    x_fecha                VARCHAR2(4000);
    x_no_cuenta            VARCHAR2(4000);
    x_no_cheque            VARCHAR2(4000);
    x_no_producto_activo   VARCHAR2(4000);
    x_desc_producto_activo VARCHAR2(4000);
    x_uom_producto_activo  VARCHAR2(4000);
    x_cant_producto_activo VARCHAR2(4000);
    x_chr_journal_comment  VARCHAR2(4000);
    x_otros                VARCHAR2(4000);
    x_cia_origen           VARCHAR2(4000);
    x_org_origen           VARCHAR2(4000);

    FUNCTION uniq(buff VARCHAR2) RETURN VARCHAR2 IS
      retval VARCHAR2(32767);
    BEGIN
      IF buff IS NULL OR buff = '|' THEN RETURN NULL; END IF;
      SELECT LISTAGG(column_value, '|') WITHIN GROUP (ORDER BY 1) column_value
      INTO   retval
      FROM   (
      SELECT DISTINCT REGEXP_SUBSTR(buff, '[^|]+', 1, LEVEL) column_value
      FROM   sys.dual
      CONNECT BY      REGEXP_SUBSTR(buff, '[^|]+', 1, LEVEL) IS NOT NULL);
      RETURN ( retval );
    EXCEPTION
      WHEN others THEN
        RETURN ( buff );
    END;
    -- joins the elements of an array into a string, and returns the string
    FUNCTION join(arr VARCHAR2_TABLE_2000) RETURN VARCHAR2 IS
      retval VARCHAR2(32767);
    BEGIN
      IF arr.COUNT = 0 THEN RETURN NULL; END IF;
      FOR i IN arr.FIRST..arr.LAST LOOP
        retval := retval || '|' || REPLACE(REPLACE(arr(i), '|', '/'), CHR(10), ' ');
      END LOOP;
      retval := TRIM(BOTH '|' FROM retval);
      retval := TRIM(BOTH ' ' FROM retval);
      --retval := uniq(retval);
      RETURN ( retval );
    EXCEPTION
      WHEN others THEN
        RETURN ( retval );
    END;
  BEGIN
    l_calling_sequence := 'GET INV ORG ID';
    l_inv_org_id := /*AR_RAAPI_UTIL.inv_org_id*/135; --1MI

    l_calling_sequence := 'GET SLA LINK ID';
    BEGIN
      --SELECT r.gl_sl_link_id, r.gl_sl_link_table, nvl(h.je_from_sla_flag, 'N') je_from_sla_flag, h.je_category, h.je_source
      SELECT listagg(r.gl_sl_link_id, '\n') WITHIN GROUP (ORDER BY 1) gl_sl_link_id, r.gl_sl_link_table,
             nvl(h.je_from_sla_flag, 'N') je_from_sla_flag, h.je_category, h.je_source,
             decode(h.reversed_je_header_id, null, null, l.reference_7) ae_header_id,
             decode(h.reversed_je_header_id, null, null, l.reference_8) ae_line_num
      INTO   t_gl_sl_link_id, l_gl_sl_link_table, l_je_from_sla_flag, l_je_category, l_je_source, l_ae_header_id, l_ae_line_num
      FROM   gl_je_headers h, gl_je_lines l, gl_import_references r
      WHERE  h.je_header_id = l.je_header_id
      AND    l.je_header_id = r.je_header_id (+)
      AND    l.je_line_num = r.je_line_num (+)
      AND    l.je_header_id = P_HEADER_ID
      AND    l.je_line_num = P_LINE_NUM
      GROUP BY r.gl_sl_link_table, nvl(h.je_from_sla_flag, 'N'), h.je_category, h.je_source,
             decode(h.reversed_je_header_id, null, null, l.reference_7),
             decode(h.reversed_je_header_id, null, null, l.reference_8);
    EXCEPTION
      WHEN no_data_found THEN l_je_from_sla_flag := null;
    END;

-- JE_FROM_SLA_FLAG: Journal propagated from subledger flag
-- Y - Journal Created from SLA in Release12
-- U - Journal Created in 11i whose subledger information has been upgraded to SLA
-- N - Journal Entry has no reference to SLA data
-- Null - Journal created in 11i but subledger information is not available in SLA
    IF ((l_je_from_sla_flag = 'Y' OR l_je_from_sla_flag = 'U') AND t_gl_sl_link_id IS NOT NULL AND l_gl_sl_link_table IS NOT NULL)
    OR  (l_je_from_sla_flag = 'N' AND l_ae_header_id IS NOT NULL AND l_ae_line_num IS NOT NULL) THEN
    FOR r IN (
      SELECT to_number(regexp_substr(T_GL_SL_LINK_ID, '[^\n]+', 1, LEVEL)) AS gl_sl_link_id
      FROM   sys.dual CONNECT BY regexp_substr(T_GL_SL_LINK_ID, '[^\n]+', 1, LEVEL) IS NOT NULL
    ) LOOP
      l_gl_sl_link_id := r.gl_sl_link_id;
      l_calling_sequence := 'GET APPLICATION SOURCE ID''s';
      IF l_gl_sl_link_id IS NOT NULL THEN
        SELECT xte.application_id, xte.entity_code
        ,      nvl(xte.source_id_int_1,(-99)) source_id_int_1
        ,      nvl(xte.source_id_int_2,(-99)) source_id_int_2
        ,      nvl(xte.source_id_int_3,(-99)) source_id_int_3
        ,      xte.source_id_char_1
        ,      xal.source_table source_line_table, nvl(xal.source_id,(-99)) source_line_id
        ,      xal.ae_header_id, xal.ae_line_num
        INTO   l_application_id, l_entity_code
        ,      l_source_id_int_1
        ,      l_source_id_int_2
        ,      l_source_id_int_3
        ,      l_source_id_char_1
        ,      l_source_line_table, l_source_line_id
        ,      l_ae_header_id, l_ae_line_num
        FROM   xla.xla_transaction_entities xte,
               xla_events xev,
               xla_ae_headers xah,
               xla_ae_lines xal
        WHERE  xte.entity_id = xev.entity_id
        AND    xte.application_id = xev.application_id
        AND    xev.application_id = xah.application_id
        AND    xev.event_id = xah.event_id
        AND    xah.ae_header_id = xal.ae_header_id
        AND    xah.application_id = xal.application_id
        AND    xal.gl_sl_link_id = L_GL_SL_LINK_ID
        AND    xal.gl_sl_link_table = L_GL_SL_LINK_TABLE;
      ELSE
        SELECT xte.application_id, xte.entity_code
        ,      nvl(xte.source_id_int_1,(-99)) source_id_int_1
        ,      nvl(xte.source_id_int_2,(-99)) source_id_int_2
        ,      nvl(xte.source_id_int_3,(-99)) source_id_int_3
        ,      xte.source_id_char_1
        ,      xal.source_table source_line_table, nvl(xal.source_id,(-99)) source_line_id
        ,      xal.ae_header_id, xal.ae_line_num
        INTO   l_application_id, l_entity_code
        ,      l_source_id_int_1
        ,      l_source_id_int_2
        ,      l_source_id_int_3
        ,      l_source_id_char_1
        ,      l_source_line_table, l_source_line_id
        ,      l_ae_header_id, l_ae_line_num
        FROM   xla.xla_transaction_entities xte,
               xla_events xev,
               xla_ae_headers xah,
               xla_ae_lines xal
        WHERE  xte.entity_id = xev.entity_id
        AND    xte.application_id = xev.application_id
        AND    xev.application_id = xah.application_id
        AND    xev.event_id = xah.event_id
        AND    xah.ae_header_id = xal.ae_header_id
        AND    xah.application_id = xal.application_id
        AND    xal.ae_header_id = L_AE_HEADER_ID
        AND    xal.ae_line_num = L_AE_LINE_NUM;
      END IF;
      IF    l_je_source = 'Assets' THEN
        IF    l_entity_code = 'DEPRECIATION' THEN
          l_calling_sequence := l_je_source||'.'||l_entity_code;
          SELECT DISTINCT
                 dep.asset_number
          ,      dep.description
          BULK COLLECT
          INTO   l_no_producto_activo
          ,      l_desc_producto_activo
          FROM   fa_deprn_events_v dep
          WHERE  dep.asset_id = L_SOURCE_ID_INT_1
          AND    dep.period_counter = L_SOURCE_ID_INT_2
          AND    dep.book_type_code = L_SOURCE_ID_CHAR_1;
        ELSIF l_entity_code = 'TRANSACTIONS' THEN
          l_calling_sequence := l_je_source||'.'||l_entity_code;
          SELECT DISTINCT
                 trx.asset_number
          ,      trx.description
          BULK COLLECT
          INTO   l_no_producto_activo
          ,      l_desc_producto_activo
          FROM   fa_transactions_v trx
          WHERE  trx.transaction_header_id = L_SOURCE_ID_INT_1
          AND    trx.book_type_code = L_SOURCE_ID_CHAR_1;
        END IF; --entity_code
      ELSIF l_je_source = 'Cost Management' THEN
        IF    l_entity_code = 'MTL_ACCOUNTING_EVENTS' THEN
          l_calling_sequence := l_je_source||'.'||l_entity_code;
          SELECT inv.item_name
          ,     (SELECT msi.description FROM mtl_system_items msi WHERE msi.segment1 = inv.item_name AND msi.organization_id = inv.organization_id) item_description
          ,      mmt.transaction_quantity
          ,      mmt.transaction_uom
          ,      muom.unit_of_measure transaction_unit_of_measure
          BULK COLLECT
          INTO   l_no_producto_activo
          ,      l_desc_producto_activo
          ,      l_cant_producto_activo
          ,      l_uom_producto_activo
          ,      l_otros
          FROM   cst_xla_inv_v inv,
                 mtl_material_transactions mmt,
                 mtl_units_of_measure muom
          WHERE  mmt.transaction_id = inv.transaction_id
          AND    mmt.transaction_uom = muom.uom_code (+)
          AND    inv.transaction_id = L_SOURCE_ID_INT_1
          AND    inv.organization_id = L_SOURCE_ID_INT_2
          AND    inv.transaction_source_type_id = L_SOURCE_ID_INT_3;
        ELSIF l_entity_code = 'RCV_ACCOUNTING_EVENTS' THEN
          l_calling_sequence := l_je_source||'.'||l_entity_code;
          SELECT rcv.po_number
          ,     (SELECT min(sup.segment1) FROM ap_suppliers sup WHERE sup.vendor_name = rcv.vendor_name) supplier_number
          ,      rcv.vendor_name
          ,      rcv.receipt_num
          ,      FND_DATE.date_to_chardate(rcv.transaction_date) transaction_date
          ,      rcv.item_name
          ,      rcv.item_description
          ,      DECODE(rcv.rcv_txn_type,
                        'RETURN TO RECEIVING', (-1) * rae.transaction_quantity,
                        'RETURN TO VENDOR'   , (-1) * rae.transaction_quantity,
                                                      rae.transaction_quantity) transaction_quantity
          ,      muom.uom_code
          ,      rae.transaction_unit_of_measure
          BULK COLLECT
          INTO   l_o_compra_venta_pago
          ,      l_no_cuenta
          ,      l_vendor_customer
          ,      l_recepcion_cp
          ,      l_fecha
          ,      l_no_producto_activo
          ,      l_desc_producto_activo
          ,      l_cant_producto_activo
          ,      l_uom_producto_activo
          ,      l_otros
          FROM   cst_xla_rcv_v rcv,
                 rcv_accounting_events rae,
                 mtl_units_of_measure muom
          WHERE  rae.rcv_transaction_id = rcv.transaction_id
          AND    rae.transaction_unit_of_measure = muom.unit_of_measure (+)
          AND    rcv.transaction_id = L_SOURCE_ID_INT_1
          AND    rcv.accounting_event_id = L_SOURCE_ID_INT_2
          AND    rcv.organization_id = L_SOURCE_ID_INT_3;
        END IF; --entity_code
      ELSIF l_je_source = 'Inventory' THEN
        IF    l_entity_code = 'INVENTORY' THEN
          l_calling_sequence := l_je_source||'.'||l_entity_code;
          SELECT txn.item_number
          ,      txn.item_description
          ,      txn.transaction_quantity
          ,      txn.transaction_uom
          ,      txn.transaction_unit_of_measure
          BULK COLLECT
          INTO   l_no_producto_activo
          ,      l_desc_producto_activo
          ,      l_cant_producto_activo
          ,      l_uom_producto_activo
          ,      l_otros
          --FROM   gmf_xla_inventory_txns_v txn
          FROM   (
          SELECT
            mmt.transaction_id,
            mmt.transaction_date,
            mtt.transaction_type_name transaction_type,
            mp.organization_code,
            mmt.subinventory_code,
            item.concatenated_segments item_number,
            item.description item_description,
            mmt.transaction_quantity,
            mmt.transaction_uom,
            muom.unit_of_measure transaction_unit_of_measure,
            mmt.transaction_source_id,
            mmt.transaction_reference,
            mtr.reason_name,
            led.ledger_id,
            led.name ledger_name,
            eh.valuation_cost_type_id,
            eh.valuation_cost_type,
            eh.event_class_code
          FROM
            mtl_parameters mp,
            mtl_system_items_b_kfv item,
            mtl_transaction_types mtt,
            mtl_transaction_reasons mtr,
            mtl_material_transactions mmt,
            mtl_units_of_measure muom,
            gmf_xla_extract_headers eh,
            gl_ledgers led
          WHERE
            mmt.reason_id = mtr.reason_id (+)
          AND    mmt.transaction_type_id = mtt.transaction_type_id
          AND    eh.organization_id = item.organization_id
          AND    eh.inventory_item_id = item.inventory_item_id
          AND    eh.organization_id = mp.organization_id
          AND    eh.transaction_id = mmt.transaction_id
          AND    mmt.transaction_uom = muom.uom_code (+)
          AND    led.ledger_id = eh.ledger_id
          )      txn
          WHERE  txn.transaction_id = L_SOURCE_ID_INT_1
          AND    txn.ledger_id = L_SOURCE_ID_INT_2
          AND    txn.valuation_cost_type_id = L_SOURCE_ID_INT_3
          AND    txn.event_class_code = L_SOURCE_ID_CHAR_1;
        ELSIF l_entity_code = 'ORDERMANAGEMENT' THEN
          l_calling_sequence := l_je_source||'.'||l_entity_code;
          SELECT txn.customer_number
          ,      txn.customer_name
          ,      FND_DATE.date_to_chardate(txn.transaction_date) transaction_date
          ,      txn.order_number
          ,      txn.item_number
          ,      txn.item_description
          ,      substr(txn.primary_quantity, 1, instr(txn.primary_quantity, ' ') - 1) transaction_quantity
          ,      txn.transaction_uom
          ,      muom.unit_of_measure transaction_unit_of_measure
          BULK COLLECT
          INTO   l_no_cuenta
          ,      l_vendor_customer
          ,      l_fecha
          ,      l_o_compra_venta_pago
          ,      l_no_producto_activo
          ,      l_desc_producto_activo
          ,      l_cant_producto_activo
          ,      l_uom_producto_activo
          ,      l_otros
          FROM   gmf_xla_so_txns_v txn,
                 mtl_units_of_measure muom
          WHERE  txn.transaction_uom = muom.uom_code (+)
          AND    txn.transaction_id = L_SOURCE_ID_INT_1
          AND    txn.ledger_id = L_SOURCE_ID_INT_2
          AND    txn.valuation_cost_type_id = L_SOURCE_ID_INT_3
          AND    txn.event_class_code = L_SOURCE_ID_CHAR_1;
        ELSIF l_entity_code = 'PRODUCTION' THEN
          l_calling_sequence := l_je_source||'.'||l_entity_code;
          SELECT txn.item_number
          ,      txn.item_description
          ,      substr(txn.primary_quantity, 1, instr(txn.primary_quantity, ' ') - 1) transaction_quantity
          ,      txn.transaction_uom
          ,      muom.unit_of_measure transaction_unit_of_measure
          BULK COLLECT
          INTO   l_no_producto_activo
          ,      l_desc_producto_activo
          ,      l_cant_producto_activo
          ,      l_uom_producto_activo
          ,      l_otros
          FROM   gmf_xla_pm_txns_v txn,
                 mtl_units_of_measure muom
          WHERE  txn.transaction_uom = muom.uom_code (+)
          AND    txn.transaction_id = L_SOURCE_ID_INT_1
          AND    txn.ledger_id = L_SOURCE_ID_INT_2
          AND    txn.valuation_cost_type_id = L_SOURCE_ID_INT_3
          AND    txn.event_class_code = L_SOURCE_ID_CHAR_1;
        ELSIF l_entity_code = 'PURCHASING' THEN
          l_calling_sequence := l_je_source||'.'||l_entity_code;
          SELECT txn.receipt_number
          ,     (SELECT min(sup.segment1) FROM ap_suppliers sup WHERE sup.vendor_name = txn.supplier_name) supplier_number
          ,      txn.supplier_name
          ,      FND_DATE.date_to_chardate(txn.transaction_date) transaction_date
          ,      txn.purchase_number
          ,      txn.item_number
          ,      txn.item_description
          ,      txn. transaction_quantity
          ,      txn.transaction_uom
          ,      txn.transaction_unit_of_measure
          BULK COLLECT
          INTO   l_recepcion_cp
          ,      l_no_cuenta
          ,      l_vendor_customer
          ,      l_fecha
          ,      l_o_compra_venta_pago
          ,      l_no_producto_activo
          ,      l_desc_producto_activo
          ,      l_cant_producto_activo
          ,      l_uom_producto_activo
          ,      l_otros
          FROM   (
          SELECT txn.receipt_number
          ,      txn.supplier_name
          ,      txn.transaction_date
          ,      txn.purchase_number
          ,      txn.item_number
          ,      txn.item_description
          ,      DECODE(rt.transaction_type,
                        'RETURN TO RECEIVING', (-1) * rt.quantity,
                        'RETURN TO VENDOR'   , (-1) * rt.quantity,
                                                      rt.quantity) transaction_quantity
          ,      txn.transaction_uom
          ,      muom.unit_of_measure transaction_unit_of_measure
          FROM   gmf_xla_rcv_txns_v txn,
                 rcv_transactions rt,
                 mtl_units_of_measure muom
          WHERE  rt.shipment_header_id = txn.source_document_id
          AND    rt.transaction_id = txn.source_line_id
          AND    rt.uom_code = muom.uom_code (+)
          AND    txn.transaction_id = L_SOURCE_ID_INT_1
          AND    txn.ledger_id = L_SOURCE_ID_INT_2
          AND    txn.valuation_cost_type_id = L_SOURCE_ID_INT_3
          AND    txn.event_class_code = L_SOURCE_ID_CHAR_1
          UNION ALL
          SELECT txn.receipt_number
          ,      txn.supplier_name
          ,      txn.transaction_date
          ,      txn.purchase_number
          ,      txn.item_number
          ,      txn.item_description
          ,      mmt.transaction_quantity
          ,      mmt.transaction_uom
          ,      muom.unit_of_measure transaction_unit_of_measure
          FROM   gmf_xla_rcv_txns_v txn,
                 mtl_material_transactions mmt,
                 mtl_units_of_measure muom
          WHERE  mmt.transaction_id = txn.transaction_id
          AND    mmt.transaction_uom = muom.uom_code (+)
          AND    txn.transaction_id = L_SOURCE_ID_INT_1
          AND    txn.ledger_id = L_SOURCE_ID_INT_2
          AND    txn.valuation_cost_type_id = L_SOURCE_ID_INT_3
          AND    txn.event_class_code = L_SOURCE_ID_CHAR_1
          AND    NOT EXISTS (
          SELECT null
          FROM   rcv_transactions rt
          WHERE  rt.shipment_header_id = txn.source_document_id
          AND    rt.transaction_id = txn.source_line_id )
          )      txn;
        ELSIF l_entity_code = 'REVALUATION' THEN
          l_calling_sequence := l_je_source||'.'||l_entity_code;
          SELECT cost.item_number
          ,      cost.item_description
          ,      cost.primary_quantity
          ,      cost.primary_uom_code
          ,      cost.primary_unit_of_measure
          BULK COLLECT
          INTO   l_no_producto_activo
          ,      l_desc_producto_activo
          ,      l_cant_producto_activo
          ,      l_uom_producto_activo
          ,      l_otros
          --FROM   gmf_xla_cost_rval_v cost
          FROM   (
          SELECT
            bal.period_balance_id transaction_id,
            led.ledger_id,
            eh.valuation_cost_type_id,
            eh.event_class_code,
            mp.organization_code,
            bal.subinventory_code,
            item.item_number,
            item.description item_description,
            bal.lot_number,
            bal.primary_quantity,
            item.primary_uom_code,
            muom.unit_of_measure primary_unit_of_measure,
            eh.transaction_date
          FROM
            gmf_period_balances bal,
            gmf_xla_extract_headers eh,
            mtl_item_flexfields item,
            mtl_units_of_measure muom,
            mtl_parameters mp,
            gl_ledgers led,
            org_acct_periods oacp
          WHERE
            eh.transaction_id = bal.period_balance_id
          AND    eh.organization_id = bal.organization_id
          AND    eh.inventory_item_id = bal.inventory_item_id
          AND    item.organization_id = bal.organization_id
          AND    item.inventory_item_id = bal.inventory_item_id
          AND    mp.organization_id = bal.organization_id
          AND    led.ledger_id = eh.ledger_id
          AND    oacp.acct_period_id = bal.acct_period_id
          AND    item.primary_uom_code = muom.uom_code (+)
          )      cost
          WHERE  cost.transaction_id = L_SOURCE_ID_INT_1
          AND    cost.ledger_id = L_SOURCE_ID_INT_2
          AND    cost.valuation_cost_type_id = L_SOURCE_ID_INT_3
          AND    cost.event_class_code = L_SOURCE_ID_CHAR_1;
        END IF; --entity_code
      ELSIF l_je_source = 'Payables' THEN
        IF    l_entity_code = 'AP_INVOICES' THEN
          IF l_source_line_table <> 'AP_INVOICE_DISTRIBUTIONS' THEN
            l_source_line_id := (-99);
          END IF;
          l_calling_sequence := l_je_source||'.'||l_entity_code;
          SELECT poh.segment1 po_num
          ,      as1.segment1 vendor_num
          ,      FND_DATE.date_to_chardate(ai.invoice_date) invoice_date
          ,      as1.vendor_name vendor_customer
          ,      ai.invoice_num factura_recibo
          ,      substr(msi.segment1, 1, 40) item_number
          ,      aid.description desc_producto_activo
          ,      aid.quantity_invoiced cant_producto_activo
          ,      aid.matched_uom_lookup_code uom_producto_activo
          ,      decode(aid.unit_price, null, null, 'Precio Unit: '||aid.unit_price)
               ||decode(aid.unit_price*aid.quantity_invoiced, null, null, l_sep||' Precio Unit x Cantidad Fac: '||aid.unit_price*aid.quantity_invoiced) otros
          BULK COLLECT
          INTO   l_o_compra_venta_pago
          ,      l_no_cuenta
          ,      l_fecha
          ,      l_vendor_customer
          ,      l_factura_recibo
          ,      l_no_producto_activo
          ,      l_desc_producto_activo
          ,      l_cant_producto_activo
          ,      l_uom_producto_activo
          ,      l_otros
          FROM   ap_invoices_all ai, ap_suppliers as1,
                 ap_invoice_distributions_all aid,
                 po_distributions_all pod,
                 po_lines_all pol,
                 po_headers_all poh,
                 mtl_system_items msi
          WHERE  msi.inventory_item_id(+) = pol.item_id
          AND    msi.organization_id(+) = po_lines_sv4.get_inventory_orgid(pol.org_id)
          AND    pol.po_line_id(+) = pod.po_line_id
          AND    poh.po_header_id(+) = pod.po_header_id
          AND    pod.po_distribution_id(+) = aid.po_distribution_id
          AND    as1.vendor_id(+) = ai.vendor_id
          AND    aid.invoice_id = ai.invoice_id
          AND    ai.invoice_id = L_SOURCE_ID_INT_1
          AND   ((-99) = L_SOURCE_LINE_ID OR (aid.invoice_distribution_id = L_SOURCE_LINE_ID OR aid.old_distribution_id = L_SOURCE_LINE_ID));
        ELSIF l_entity_code = 'AP_PAYMENTS' THEN
        DECLARE
          l_invoice_num VARCHAR2(50);
        BEGIN
          BEGIN
            IF    l_source_line_table = 'AP_INVOICES' THEN
              SELECT ai.invoice_num
              INTO   l_invoice_num
              FROM   ap_invoices_all ai
              WHERE  ai.invoice_id = L_SOURCE_LINE_ID;
            ELSIF l_source_line_table = 'AP_INVOICE_PAYMENTS' THEN
              SELECT ai.invoice_num
              INTO   l_invoice_num
              FROM   ap_invoice_payments_all ip, ap_invoices_all ai
              WHERE  ai.invoice_id = ip.invoice_id AND ip.invoice_payment_id = L_SOURCE_LINE_ID;
            ELSE
              l_invoice_num := null;
            END IF;
          EXCEPTION
            WHEN no_data_found THEN l_invoice_num := null;
          END;
          l_calling_sequence := l_je_source||'.'||l_entity_code;
          SELECT ac.doc_sequence_value
          ,      ap.segment1
          ,     (SELECT hp.party_name FROM hz_parties hp WHERE hp.party_id = ac.party_id) vendor_name
          ,      decode(l_invoice_num, null,
                (SELECT replace(regexp_replace(listagg(ai.invoice_num, '|') WITHIN GROUP (ORDER BY 1), '([^|]*)(\|\1)*(\||$)', '\1\3'), '|', l_sep) invoice_num
                 FROM   ap_invoices_all ai, ap_invoice_payments_all aip
                 WHERE  ai.invoice_id = aip.invoice_id AND aip.check_id = ac.check_id
                ), l_invoice_num) invoice_number
          ,      ac.check_number
          BULK COLLECT
          INTO   l_o_compra_venta_pago
          ,      l_no_cuenta
          ,      l_vendor_customer
          ,      l_factura_recibo
          ,      l_no_cheque
          FROM   ap_checks_all ac
          ,      ap_suppliers ap
          ,      ce_bank_acct_uses_all cbau
          ,      ce_bank_accounts cba
          ,      ce_bank_branches_v cbb
          ,      ce_payment_documents cpd
          WHERE  ac.ce_bank_acct_use_id = cbau.bank_acct_use_id(+)
          AND    cbau.bank_account_id = cba.bank_account_id(+)
          AND    cba.bank_branch_id = cbb.branch_party_id(+)
          AND    ac.payment_document_id = cpd.payment_document_id(+)
          AND    ac.vendor_id = ap.vendor_id(+)
          AND    ac.check_id = L_SOURCE_ID_INT_1;
        END;
        END IF; --entity_code
      ELSIF l_je_source = 'Project Accounting' THEN
          l_calling_sequence := l_je_source||'.'||l_entity_code;
          SELECT decode(pp.name, null, null, 'Nombre Proyecto: '||pp.name)
               ||decode(pt.task_name, null, null, l_sep||' Nombre Tarea: '||pt.task_name) Descripcion_Origen
          BULK COLLECT
          INTO   l_otros
          FROM   pa_expenditure_items_all exp
          ,      pa_expenditures_all pex
          ,      pa_tasks pt
          ,      pa_projects_all pp
          ,      pa_expenditure_types et
          WHERE  exp.project_id = pp.project_id
          AND    exp.project_id = pt.project_id
          AND    exp.task_id = pt.task_id
          AND    exp.expenditure_id = pex.expenditure_id
          AND    exp.expenditure_type = et.expenditure_type
          AND    exp.expenditure_item_id = L_SOURCE_ID_INT_1;
      ELSIF l_je_source = 'Receivables' THEN
        IF    l_entity_code = 'ADJUSTMENTS' THEN
          l_calling_sequence := l_je_source||'.'||l_entity_code;
          SELECT adj.customer_number
          ,      adj.customer_name
          ,      decode(rpad(adj.adjustment_number,20,' '), null, null, 'Numero Ajuste: '||rpad(adj.adjustment_number,20,' ')) descripcion_origen
          BULK COLLECT
          INTO   l_no_cuenta
          ,      l_vendor_customer
          ,      l_otros
          FROM   ar_adj_inf_v adj
          WHERE  adj.adjustment_id = L_SOURCE_ID_INT_1;
        ELSIF l_entity_code = 'TRANSACTIONS' THEN
          l_calling_sequence := l_je_source||'.'||l_entity_code;
          SELECT trx_number
          ,      FND_DATE.date_to_chardate(trx_date) trx_date
          ,      third_party_number
          ,      third_party_name
          ,      ae_line_reference
          ,      sales_order_number
          ,      trx_quantity
          ,      trx_item
          ,      trx_desc
          ,      trx_uom
          BULK COLLECT
          INTO   l_factura_recibo
          ,      l_fecha
          ,      l_no_cuenta
          ,      l_vendor_customer
          ,      l_otros
          ,      l_o_compra_venta_pago
          ,      l_cant_producto_activo
          ,      l_no_producto_activo
          ,      l_desc_producto_activo
          ,      l_uom_producto_activo
          FROM   (
          SELECT ael.trx_number_displayed trx_number
          ,      ael.trx_date
          ,      ael.third_party_number
          ,      ael.third_party_name
          ,      ael.ae_line_reference
          ,      ael.sales_order_number
          ,      ael.trx_quantity
          ,      ctl.uom_code trx_uom
          ,      uom.unit_of_measure trx_unit_of_measure
          ,      si.segment1 trx_item
          ,      ctl.description trx_desc
          FROM   ar_ael_sl_inv_v ael
          ,      ra_customer_trx_lines_all ctl, ra_cust_trx_line_gl_dist_all ctlgd
          ,      mtl_units_of_measure uom, mtl_system_items si
          WHERE  ael.trx_hdr_id = L_SOURCE_ID_INT_1
          AND    ael.ael_id IN (
          SELECT xdl.source_distribution_id_num_1
          FROM   xla_distribution_links xdl
          WHERE  xdl.application_id = 222
          AND    xdl.ae_header_id = L_AE_HEADER_ID
          AND    xdl.ae_line_num  = L_AE_LINE_NUM)
          AND    'CTLGD' = ael.ael_table
          AND    ctlgd.cust_trx_line_gl_dist_id = ael.ael_id
          AND    ctl.customer_trx_line_id (+) = ctlgd.customer_trx_line_id
          AND    uom.uom_code (+) = ctl.uom_code
          AND    si.inventory_item_id (+) = ctl.inventory_item_id
          AND    si.organization_id (+) = L_INV_ORG_ID
          UNION
          SELECT ael.trx_number_displayed
          ,      ael.trx_date
          ,      ael.third_party_number
          ,      ael.third_party_name
          ,      ael.ae_line_reference
          ,      ael.sales_order_number
          ,      ael.trx_quantity
          ,      ctl.uom_code trx_uom
          ,      uom.unit_of_measure trx_unit_of_measure
          ,      si.segment1 trx_item
          ,      ctl.description trx_desc
          FROM   ar_ael_sl_inv_v ael
          ,      ra_customer_trx_lines_all ctl, ar_distributions_all ard
          ,      mtl_units_of_measure uom, mtl_system_items si
          WHERE  ael.trx_hdr_id = L_SOURCE_ID_INT_1
          AND    ael.ael_id IN (
          SELECT xdl.source_distribution_id_num_1
          FROM   xla_distribution_links xdl
          WHERE  xdl.application_id = 222
          AND    xdl.ae_header_id = L_AE_HEADER_ID
          AND    xdl.ae_line_num  = L_AE_LINE_NUM)
          AND    'ARD' = ael.ael_table
          AND    ard.line_id = ael.ael_id
          AND    ctl.customer_trx_line_id (+) = ard.ref_customer_trx_line_id
          AND    uom.uom_code (+) = ctl.uom_code
          AND    si.inventory_item_id (+) = ctl.inventory_item_id
          AND    si.organization_id (+) = L_INV_ORG_ID);
        ELSIF l_entity_code = 'RECEIPTS' THEN
          l_calling_sequence := l_je_source||'.'||l_entity_code;
          SELECT cr.receipt_number receipt_number
          ,      cr.receipt_creation_date receipt_creation_date
          ,      cr.customer_number customer_number
          ,      cr.customer_name customer_name
          BULK COLLECT
          INTO   l_factura_recibo
          ,      l_fecha
          ,      l_no_cuenta
          ,      l_vendor_customer
          FROM   ar_cr_inf_v cr
          WHERE  cr.cash_receipt_id = L_SOURCE_ID_INT_1;
        END IF; --entity_code
      END IF; --je_source
      l_calling_sequence := 'OUT PARAMETERS';
      x_vendor_customer      := SUBSTRB(uniq(p_vendor_customer      || x_sep || join(l_vendor_customer)), 1, 4000);
      x_factura_recibo       := SUBSTRB(uniq(p_factura_recibo       || x_sep || join(l_factura_recibo)), 1, 4000);
      x_recepcion_CP         := SUBSTRB(uniq(p_recepcion_CP         || x_sep || join(l_recepcion_CP)), 1, 4000);
      x_o_compra_venta_pago  := SUBSTRB(uniq(p_o_compra_venta_pago  || x_sep || join(l_o_compra_venta_pago)), 1, 4000);
      x_fecha                := SUBSTRB(uniq(p_fecha                || x_sep || join(l_fecha)), 1, 4000);
      x_no_cuenta            := SUBSTRB(uniq(p_no_cuenta            || x_sep || join(l_no_cuenta)), 1, 4000);
      x_no_cheque            := SUBSTRB(uniq(p_no_cheque            || x_sep || join(l_no_cheque)), 1, 4000);
      x_no_producto_activo   := SUBSTRB(uniq(p_no_producto_activo   || x_sep || join(l_no_producto_activo)), 1, 4000);
      x_desc_producto_activo := SUBSTRB(uniq(p_desc_producto_activo || x_sep || join(l_desc_producto_activo)), 1, 4000);
      x_uom_producto_activo  := SUBSTRB(uniq(p_uom_producto_activo  || x_sep || join(l_uom_producto_activo)), 1, 4000);
      x_cant_producto_activo := SUBSTRB(uniq(p_cant_producto_activo || x_sep || join(l_cant_producto_activo)), 1, 4000);
      x_chr_journal_comment  := SUBSTRB(uniq(p_chr_journal_comment  || x_sep || join(l_chr_journal_comment)), 1, 4000);
      x_otros                := SUBSTRB(uniq(p_otros                || x_sep || join(l_otros)), 1, 4000);
      x_cia_origen           := SUBSTRB(uniq(p_cia_origen           || x_sep || join(l_cia_origen)), 1, 4000);
      x_org_origen           := SUBSTRB(uniq(p_org_origen           || x_sep || join(l_org_origen)), 1, 4000);
      x_sep := '|';
      l_return_status := TRUE;
    END LOOP;
      p_vendor_customer      := SUBSTRB(REPLACE(x_vendor_customer, '|', l_sep), 1, 240);
      p_factura_recibo       := SUBSTRB(REPLACE(x_factura_recibo, '|', l_sep), 1, 240);
      p_recepcion_CP         := SUBSTRB(REPLACE(x_recepcion_CP, '|', l_sep), 1, 240);
      p_o_compra_venta_pago  := SUBSTRB(REPLACE(x_o_compra_venta_pago, '|', l_sep), 1, 240);
      p_fecha                := SUBSTRB(REPLACE(x_fecha, '|', l_sep), 1, 240);
      p_no_cuenta            := SUBSTRB(REPLACE(x_no_cuenta, '|', l_sep), 1, 240);
      p_no_cheque            := SUBSTRB(REPLACE(x_no_cheque, '|', l_sep), 1, 240);
      p_no_producto_activo   := SUBSTRB(REPLACE(x_no_producto_activo, '|', l_sep), 1, 240);
      p_desc_producto_activo := SUBSTRB(REPLACE(x_desc_producto_activo, '|', l_sep), 1, 240);
      p_uom_producto_activo  := SUBSTRB(REPLACE(x_uom_producto_activo, '|', l_sep), 1, 240);
      p_cant_producto_activo := SUBSTRB(REPLACE(x_cant_producto_activo, '|', l_sep), 1, 240);
      p_chr_journal_comment  := SUBSTRB(REPLACE(x_chr_journal_comment, '|', l_sep), 1, 240);
      p_otros                := SUBSTRB(REPLACE(x_otros, '|', l_sep), 1, 240);
      p_cia_origen           := SUBSTRB(REPLACE(x_cia_origen, '|', l_sep), 1, 240);
      p_org_origen           := SUBSTRB(REPLACE(x_org_origen, '|', l_sep), 1, 240);
    ELSE
      l_calling_sequence := 'CALL principal$NonSLA';
      l_return_status := principal$NonSLA ( p_source_code
                     , p_category_code
                     , p_header_id
                     , p_line_num
                     , p_code_comb_id
                     , p_reference_1
                     , p_reference_2
                     , p_reference_3
                     , p_reference_4
                     , p_reference_5
                     , p_reference_9
                     , p_reference_6
                     , p_reference_7
                     , p_reference_8
                     , p_reference_10
                     , p_debit
                     , p_credit
                     --, p_desc_origen
                     , p_vendor_customer
                     , p_factura_recibo
                     , p_recepcion_CP
                     , p_o_compra_venta_pago
                     , p_fecha
                     , p_no_cuenta
                     , p_no_cheque
                     , p_no_producto_activo
                     , p_desc_producto_activo
                     , p_uom_producto_activo
                     , p_cant_producto_activo
                     , p_chr_journal_comment
                     , p_otros
                     , p_cia_origen
                     , p_org_origen
                     );
    END IF;

    RETURN (l_return_status);
  EXCEPTION
    WHEN no_data_found THEN
      xx_debug_pk.debug('Datos: je header id: '||p_header_id||', je line num: '||p_line_num||', je source: '||p_source_code||', je category: '||p_category_code||'. '||l_calling_sequence||', '||SQLERRM);
      p_otros := l_calling_sequence||': '||'No se ha encontrado ning¿n dato.';
      RETURN (TRUE);
    WHEN too_many_rows THEN
      xx_debug_pk.debug('Datos: je header id: '||p_header_id||', je line num: '||p_line_num||', je source: '||p_source_code||', je category: '||p_category_code||'. '||l_calling_sequence||', '||SQLERRM);
      p_otros := l_calling_sequence||': '||'Se han encontrado m¿ltiples registros en lugar de un registro ¿nico.';
      RETURN (TRUE);
    WHEN others THEN
      xx_debug_pk.debug('Datos: je header id: '||p_header_id||', je line num: '||p_line_num||', je source: '||p_source_code||', je category: '||p_category_code||'. '||sys.dbms_utility.format_error_stack()||sys.dbms_utility.format_error_backtrace());
      p_otros := SUBSTRB(sys.dbms_utility.format_error_stack()||sys.dbms_utility.format_error_backtrace(), 1, 240);
      RETURN (TRUE);
  END principal;

   FUNCTION muestra_CCID ( p_code_combination_id IN NUMBER
                         , p_ledger_id           IN NUMBER
                         , p_period_year         IN NUMBER
                         , p_period_num          IN NUMBER
                         ) RETURN VARCHAR2 IS
     l_yesno VARCHAR2(1) := 'N';
   BEGIN

     SELECT
         'Y'
     INTO
         l_yesno
     FROM
     (
        SELECT
            c.account_type,
            SUM(DECODE(b.period_num,1,b.begin_balance_dr - b.begin_balance_cr,0) ) saldo_inicial,
            SUM(b.period_net_dr) db_anual,
            SUM(b.period_net_cr) cr_anual
        FROM
            gl_balances b,
            gl_period_statuses p,
            gl_code_combinations c
        WHERE
            b.ledger_id = p_ledger_id
        AND   b.period_name = p.period_name
        AND   p.application_id = 101
        AND   p.ledger_id = p_ledger_id
        AND   p.effective_period_num BETWEEN ( p_period_year * 10000 + 1 ) AND ( p_period_year * 10000 + p_period_num )
        AND   b.actual_flag = 'A'
        AND   b.code_combination_id = c.code_combination_id
        AND   c.code_combination_id = p_code_combination_id
        GROUP BY
            c.account_type
        ) b
        WHERE ( (account_type IN ('E','R') AND (db_anual != 0 OR cr_anual != 0 ))
        OR      (account_type IN ('A','L','O') AND (saldo_inicial != 0 OR (db_anual != 0 OR cr_anual != 0)) )
     );

     RETURN (l_yesno);
   EXCEPTION
     WHEN no_data_found THEN RETURN ('N');
   END muestra_CCID;

   PROCEDURE filtra_CCIDs ( p_chart_of_accounts_id IN NUMBER
                          , p_ledger_id            IN NUMBER
                          , p_period_year          IN NUMBER
                          , p_period_num           IN NUMBER
                          , p_where_condition      IN VARCHAR2
                          ) IS
     l_sql_stmt VARCHAR2(4000);
   BEGIN

     DELETE FROM gl_interface_summary_gt; COMMIT;
     l_sql_stmt := q'[INSERT INTO gl_interface_summary_gt (code_combination_id)
SELECT
    code_combination_id
FROM
    gl_summary_combinations_v
WHERE
    chart_of_accounts_id = :world$chart_of_accounts_id
AND   NVL(ledger_id, :world$ledger_id) = :world$ledger_id
AND   EXISTS (
SELECT
    1
FROM
(
SELECT
    SUM(DECODE(b.period_num,1,b.begin_balance_dr - b.begin_balance_cr,0) ) saldo_inicial,
    SUM(b.period_net_dr) db_anual,
    SUM(b.period_net_cr) cr_anual
FROM
    gl_balances b,
    gl_period_statuses p
WHERE
    b.ledger_id = :world$ledger_id
AND   b.period_name = p.period_name
AND   p.application_id = 101
AND   p.ledger_id = :world$ledger_id
AND   p.effective_period_num BETWEEN ( :world$period_year * 10000 + 1 ) AND ( :world$period_year * 10000 + :world$to_period_num )
AND   b.actual_flag = 'A'
AND   b.code_combination_id = gl_summary_combinations_v.code_combination_id
) b
WHERE ( (account_type IN ('E','R') /*AND (b.db_anual != 0 OR b.cr_anual != 0 )*/) -- C1666 26/03/2020 ADM Se comenta porque se pidió filtra el error "No se encontraron combinaciones contables para el rango ingresado" del from XXGLMAYOR para cuando el saldo es 0
OR      (account_type IN ('A','L','O') /*AND (b.saldo_inicial != 0 OR (b.db_anual != 0 OR b.cr_anual != 0))*/ ) -- C1666 26/03/2020 ADM Se comenta porque se pidió filtra el error "No se encontraron combinaciones contables para el rango ingresado" del from XXGLMAYOR para cuando el saldo es 0
)
) ]';
     l_sql_stmt := l_sql_stmt || p_where_condition;

     EXECUTE IMMEDIATE l_sql_stmt
       USING p_chart_of_accounts_id, p_ledger_id, p_ledger_id,
             p_ledger_id, p_ledger_id, p_period_year, p_period_year, p_period_num;

   EXCEPTION
     WHEN others THEN
       xx_debug_aux_pk.debug(NULL,1,'XX_GL_DESC_ORIGEN_PK',SUBSTRB('filtra_CCIDs(p_chart_of_accounts_id:'||p_chart_of_accounts_id||', p_ledger_id:'||p_ledger_id||', p_period_year:'||p_period_year||', p_period_num:'||p_period_num||', p_where_condition:'||p_where_condition||') '||SQLERRM||CHR(10)||l_sql_stmt,1,4000),NULL,NULL,NULL);
       RETURN;
   END filtra_CCIDs;

END XX_GL_DESC_ORIGEN_PK;
/
