WHENEVER SQLERROR EXIT FAILURE ROLLBACK
CONNECT &1/&2
WHENEVER SQLERROR CONTINUE

SET DEFINE OFF

CREATE OR REPLACE PACKAGE BODY sae_ap_caucao_report_pk IS
--
-- $Header: SAE_AP_CAUCAO_REPORT_PKB.pls 121.2 01/04/2020 10:00:00 appldev ship $
-- +=================================================================+
-- |                      SANTO ANTONIO ENERGIA                      |
-- |                       All rights reserved.                      |
-- +=================================================================+
-- | FILENAME                                                        |
-- |   SAE_AP_CAUCAO_REPORT_PKB.pls                                  |
-- |                                                                 |
-- | PURPOSE                                                         |
-- |   RelatÛrio de Caucao                                           |
-- |                                                                 |
-- | DESCRIPTION                                                     |
-- |                                                                 |
-- | PARAMETERS                                                      |
-- |                                                                 |
-- | CREATED BY  Renan Camarota            01/04/2020                |
-- |                                                                 |
-- | UPDATE BY                                                       |
-- |                                                                 |
-- +=================================================================+
--
  PROCEDURE gera_xml_p( errbuf         IN OUT VARCHAR2
                      , retcode        IN OUT VARCHAR2
                      , p_data_incial  IN VARCHAR2
                      , p_data_final   IN VARCHAR2
                      , p_fornecedor   IN VARCHAR2
                      , p_contrato     IN VARCHAR2
                      , p_tipo         IN VARCHAR2) IS


    ld_data_inicial    DATE          := TO_DATE(fnd_date.canonical_to_date(p_data_incial), 'DD/MM/RRRR');
    ld_data_fim        DATE          := TO_DATE(fnd_date.canonical_to_date(p_data_final), 'DD/MM/RRRR');
    lv_data            VARCHAR2(30)  := TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MM:SS');
    l_vVendor_name     po_vendors.vendor_name%TYPE;

  BEGIN

    BEGIN
      SELECT vendor_name
        INTO l_vVendor_name
        FROM po_vendors
       WHERE vendor_id = p_fornecedor;
    EXCEPTION
      WHEN no_data_found THEN
        l_vVendor_name := 'N„o informado';
      WHEN OTHERS THEN
        l_vVendor_name := '';
     END;

    fnd_file.put_line(fnd_file.output,'<?xml version="1.0" encoding="ISO-8859-1"?>');
    fnd_file.put_line(fnd_file.output, '<DADOS>');
    fnd_file.put_line(fnd_file.output, '  <PARAMETERS>');
    fnd_file.put_line(fnd_file.output, '    <P_DATA_INICIAL>'   ||  ld_data_inicial                  || '</P_DATA_INICIAL>');
    fnd_file.put_line(fnd_file.output, '    <P_DATA_FIM>'       ||  ld_data_fim                      || '</P_DATA_FIM>');
    fnd_file.put_line(fnd_file.output, '    <P_DATA_ATUAL>'     ||  lv_data                          || '</P_DATA_ATUAL>');
    fnd_file.put_line(fnd_file.output, '    <P_FORNECEDOR>'     ||  l_vVendor_name                   || '</P_FORNECEDOR>');
    fnd_file.put_line(fnd_file.output, '    <P_CONTRATO>'       ||  NVL(p_contrato,'N„o informado')  || '</P_CONTRATO>');
    fnd_file.put_line(fnd_file.output, '    <P_TIPO>'           ||  NVL(p_tipo,'N„o informado')      || '</P_TIPO>');
    fnd_file.put_line(fnd_file.output, '  </PARAMETERS>');
    fnd_file.put_line(fnd_file.output, '  <G_MAIN>');

    FOR r_rec_data IN (SELECT SUBSTR(pvsa.global_attribute10, 2, 2) || '.' || SUBSTR(pvsa.global_attribute10, 4, 3)
                        || '.' || SUBSTR(pvsa.global_attribute10, 7, 3) || '/' || pvsa.global_attribute11
                        || '-' || pvsa.global_attribute12     cnpj_fornecedor
                         , pv.vendor_name                      fornecedor
                        , pha.attribute9                      numero_contrato
                        , pha.segment1                        codigo_da_po
                        , rsh.shipment_num                    codigo_medicao
                        , aia.invoice_num                     num_nff
                        , aia.invoice_date                    data_emissao_nff
                        , SUM(ida.amount * - 1)               valor_retido
                        , aia.description                     descricao_nff
                        , glc.segment3                        conta_contabil
                        , ida.accounting_date                 data_gl
                        , pha.po_header_id                    id_po
                        , aia.invoice_id                      id_nff
                        , 'Valor Retido CauÁ„o'               tipo
                     FROM apps.ap_invoices_all                aia
                        , apps.po_vendors                     pv
                        , apps.po_vendor_sites_all            pvsa
                        , apps.ap_invoice_lines_all           aila
                        , apps.ap_invoice_distributions_all   ida
                        , apps.gl_code_combinations           glc
                        , apps.po_headers_all                 pha
                        , apps.po_lines_all                   pla
                        , apps.cll_f189_invoices              cfi
                        , apps.cll_f189_invoice_lines         cfil
                        , apps.cll_f189_work_confs            cfw
                        , apps.rcv_shipment_headers           rsh
                        , apps.rcv_shipment_lines             rsl
                    WHERE aia.invoice_type_lookup_code IN ('STANDARD','CREDIT')
                      AND aia.invoice_amount           <> 0
                      AND pv.vendor_id                 = aia.vendor_id
                      AND pvsa.vendor_site_id          = aia.vendor_site_id
                      AND aila.invoice_id              = aia.invoice_id
                      AND aila.line_type_lookup_code   = 'ITEM'
                      AND ida.invoice_id               = aila.invoice_id
                      AND ida.invoice_line_number      = aila.line_number
                      AND ida.line_type_lookup_code    = 'RETAINAGE'
                      AND glc.code_combination_id (+)  = ida.dist_code_combination_id
                      AND pha.po_header_id (+)         = aila.po_header_id
                      AND pla.po_line_id (+)           = aila.po_line_id
                      AND pla.po_header_id (+)         = aila.po_header_id
                      AND pla.po_header_id (+)         = pha.po_header_id
                      AND cfil.invoice_line_id (+)     = aila.reference_key1
                      AND cfi.invoice_id (+)           = cfil.invoice_id
                      AND cfw.invoice_line_id (+)      = cfil.invoice_line_id
                      AND rsl.shipment_line_id (+)     = cfw.shipment_line_id
                      AND rsh.shipment_header_id (+)   = rsl.shipment_header_id
                      AND ida.accounting_date          BETWEEN ld_data_inicial AND ld_data_fim
                      AND pv.vendor_id                 = NVL(p_fornecedor,pv.vendor_id)
                      AND NVL(pha.attribute9,'1')      = NVL(p_contrato,NVL(pha.attribute9,'1'))
                    GROUP BY SUBSTR(pvsa.global_attribute10, 2, 2) || '.' || SUBSTR(pvsa.global_attribute10, 4, 3)
                        || '.' || SUBSTR(pvsa.global_attribute10, 7, 3) || '/' || pvsa.global_attribute11
                        || '-' || pvsa.global_attribute12, pv.vendor_name
                        , pha.attribute9
                        , pha.segment1
                        , rsh.shipment_num
                        , aia.invoice_num
                        , aia.invoice_date
                        , aila.accounting_date
                        , aia.description
                        , glc.segment3
                        , ida.accounting_date
                        , pha.po_header_id
                        , aia.invoice_id
                    UNION ALL
                    SELECT SUBSTR(pvsa.global_attribute10, 2, 2)|| '.'|| SUBSTR(pvsa.global_attribute10, 4, 3)|| '.'
                             || SUBSTR(pvsa.global_attribute10, 7, 3)
                             || '/'|| pvsa.global_attribute11|| '-'|| pvsa.global_attribute12 cnpj
                        , pv.vendor_name
                        , CASE WHEN ((aia.attribute7 IS NULL) AND (UPPER(aia.invoice_num) LIKE '%CT%' )) THEN
                            aia.invoice_num
                          ELSE aia.attribute7
                        END contrato
                        , NULL
                        , NULL
                        , CASE WHEN UPPER(aia.invoice_num) LIKE '%CT%' THEN
                            NULL
                           ELSE aia.invoice_num
                        END numero_nff
                        , aia.invoice_date          data_fatura
                        , aia.amount_paid * - 1     valor_liq_pago
                        , aia.description           descricao
                        , glc.segment3              conta_contabil
                        , ida.accounting_date       data_gl
                        , NULL
                        , aia.invoice_id            id_nff
                        , 'Pagamento CauÁ„o'
                      FROM apps.ap_invoices_all                aia
                         , apps.ap_invoice_lines_all           aila
                         , apps.ap_invoice_distributions_all   ida
                         , apps.po_vendors                     pv
                         , apps.po_vendor_sites_all            pvsa
                         , apps.gl_code_combinations           glc
                     WHERE aia.invoice_type_lookup_code = 'RETAINAGE RELEASE'
                       AND aia.source                   IN ('Manual Invoice Entry','SAESP')
                       AND aia.payment_status_flag      = 'Y'
                       AND aia.invoice_amount           <> 0
                       AND aila.invoice_id              = aia.invoice_id
                       AND aila.amount                  <> 0
                       AND aila.line_type_lookup_code   IN ('RETAINAGE RELEASE','ITEM')
                       AND ida.invoice_id               = aia.invoice_id
                       AND ida.line_type_lookup_code    = 'ITEM'
                       AND pv.vendor_id                 = aia.vendor_id
                       AND aia.vendor_site_id           = pvsa.vendor_site_id
                       AND glc.code_combination_id      = ida.dist_code_combination_id
                       AND ida.accounting_date          BETWEEN ld_data_inicial AND ld_data_fim
                       AND pv.vendor_id                 = NVL(p_fornecedor, pv.vendor_id)
                       AND (aia.invoice_num             = NVL(p_contrato,aia.invoice_num)
                        OR NVL(aia.attribute7,'1')      = NVL(p_contrato,NVL(aia.attribute7,'1')))
                     GROUP BY aia.invoice_id
                            , aila.line_number
                            , pvsa.global_attribute10
                            , pvsa.global_attribute11
                            , pvsa.global_attribute12
                            , pv.vendor_name
                            , aia.attribute7
                            , aia.invoice_num
                            , aia.invoice_date
                            , aia.amount_paid
                            , aia.description
                            , glc.segment3
                            , ida.accounting_date
                            , NULL
                            , aia.invoice_id
                     ORDER BY 7 DESC) LOOP

      IF (p_tipo = r_rec_data.tipo OR p_tipo IS NULL) THEN
      -- Tipo  - (Lista de Valores - Valor Retido CauÁ„o, Pagamento CauÁ„o ou nulo. Caso for nulo deve trazer os dois tipos)

        fnd_file.put_line(fnd_file.output, '    <G_DADOS>');
        fnd_file.put_line(fnd_file.output, '      <CNPJ_FORNECEDOR>'    || r_rec_data.cnpj_fornecedor              || '</CNPJ_FORNECEDOR>');
        fnd_file.put_line(fnd_file.output, '      <FORNECEDOR>'         || translate_f(r_rec_data.fornecedor)      || '</FORNECEDOR>');
        fnd_file.put_line(fnd_file.output, '      <NUMERO_CONTRATO>'    || translate_f(r_rec_data.numero_contrato) || '</NUMERO_CONTRATO>');
        fnd_file.put_line(fnd_file.output, '      <CODIGO_DA_PO>'       || r_rec_data.codigo_da_po                 || '</CODIGO_DA_PO>');
        fnd_file.put_line(fnd_file.output, '      <CODIGO_MEDICAO>'     || r_rec_data.codigo_medicao               || '</CODIGO_MEDICAO>');
        fnd_file.put_line(fnd_file.output, '      <NUM_NFF>'            || translate_f(r_rec_data.num_nff)         || '</NUM_NFF>');
        fnd_file.put_line(fnd_file.output, '      <DATA_EMISSAO_NFF>'   || TO_CHAR(r_rec_data.data_emissao_nff,'DD/MM/RRRR')   || '</DATA_EMISSAO_NFF>');
        fnd_file.put_line(fnd_file.output, '      <VALOR_RETIDO>'       || REPLACE(r_rec_data.valor_retido,',','.')            || '</VALOR_RETIDO>');
        fnd_file.put_line(fnd_file.output, '      <DESCRICAO_NFF>'      || translate_f(r_rec_data.descricao_nff)    || '</DESCRICAO_NFF>');
        fnd_file.put_line(fnd_file.output, '      <CONTA_CONTABIL>'     || r_rec_data.conta_contabil                || '</CONTA_CONTABIL>');
        fnd_file.put_line(fnd_file.output, '      <DATA_GL>'            || TO_CHAR(r_rec_data.data_gl,'DD/MM/RRRR') || '</DATA_GL>');
        fnd_file.put_line(fnd_file.output, '      <ID_PO>'              || r_rec_data.id_po                         || '</ID_PO>');
        fnd_file.put_line(fnd_file.output, '      <ID_NFF>'             || r_rec_data.id_nff                        || '</ID_NFF>');
        fnd_file.put_line(fnd_file.output, '      <TIPO>'               || r_rec_data.tipo                          || '</TIPO>');
        fnd_file.put_line(fnd_file.output, '    </G_DADOS>');

      END IF;

    END LOOP;

    fnd_file.put_line(fnd_file.output, '  </G_MAIN>');
    fnd_file.put_line(fnd_file.output, '</DADOS>');

  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := SUBSTR(SQLERRM,1,150);
      retcode := SQLCODE;
      fnd_file.put_line(fnd_file.output, 'Error in Package sae_ap_caucao_report_pk : '||errbuf);
      raise_application_error(-20001,'Error '||errbuf);

  END gera_xml_p;

  FUNCTION translate_f(p_vString IN VARCHAR2) RETURN VARCHAR2 IS
    l_vString VARCHAR2(2000);
  BEGIN
    l_vString := UPPER(TRANSLATE(p_vString,'„√ı’Á«¸‹‚¬Í Ù‘·¡‡¿È…ÌÕÛ”˙⁄&<>','aAoOcCuUaAeEoOaAaAeEiIoOuUe--'));
    RETURN l_vString;
  END translate_f;

END sae_ap_caucao_report_pk;
-- Indicativo de final de arquivo. Nao deve ser removido.
/
COMMIT;
EXIT;