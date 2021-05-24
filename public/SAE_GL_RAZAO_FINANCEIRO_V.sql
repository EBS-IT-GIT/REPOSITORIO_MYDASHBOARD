set define off;
--
CREATE OR REPLACE VIEW APPS.SAE_GL_RAZAO_FINANCEIRO_V AS
--
-- $Header: %f% %v% %d% %u% ship                             $
-- $Id: SAE_GL_RAZAO_FINANCEIRO_V 120.0 2019-05-17 00:00:00  $
-- +=================================================================+
-- |                       Sao Paulo, Brasil                         |
-- +=================================================================+
-- | FILENAME                                                        |
-- |    SAE_GL_RAZAO_FINANCEIRO_V.sql                                |
-- | PURPOSE                                                         |
-- | Razão Financeiro, view criada para trazer as informações do     |
-- | Razão GL agregado com informações das contas orçamentárias      |
-- | Para atender esta associação foi criado novas tabelas com as    |
-- | informações das contas orçamentárias que são:                   |
-- |    APPS.SAE_GL_CONTA_ORCAMENTARIA SGCO                          |
-- |    APPS.SAE_GL_STRUTURA_RAZAO_FINANC SGSRF                      |
-- |                                                                 |
-- | DESCRIPTION                                                     |
-- |   View                                                          |
-- | CREATED BY  <Nome do Desenvolvedor> / 05/06/2019                |
-- | UPDATED BY  <Nome do Desenvolvedor> / data                      |
-- |             Ivam Cardoso            / 21/02/2020                |
-- |                Implementar CASE para separar conta contábil de  |
-- |                abastecimento                                    |
-- |                                                                 |
-- +=================================================================+
-- 
Select gjh.ACTUAL_FLAG
     , gjst.user_je_source_name
     , gjst.description USER_JE_SOURCE_DESCRIPTION
     , gjct.user_je_category_name
     , gjct.je_category_key
     , gjh.je_header_id
     , gjl.je_line_num
     , dtap.SOURCE
     , gjl.LEDGER_ID
     , gjl.PERIOD_NAME  PERIODO
     , DECODE(gcc.segment3,'211999000000100335', DECODE(NVL(dtap.SOURCE,'XXX'),'FUNDIARIO','615011999000001174',NVL(Decode(NVL(MCR.ATTRIBUTE4,NVL(MCC.ATTRIBUTE4,NVL(mccr.ATTRIBUTE4,cowip.ATTRIBUTE4)))
                                                                                                                   ,'1'
                                                                                                                   ,Decode(NVL(MCR.ATTRIBUTE2,NVL(MCC.ATTRIBUTE2,NVL(mccr.ATTRIBUTE2,cowip.ATTRIBUTE2)))
                                                                                                                          ,'1'
                                                                                                                          ,NVL(MCR.ATTRIBUTE3,NVL(MCC.ATTRIBUTE3,NVL(mccr.ATTRIBUTE3,cowip.ATTRIBUTE3)))
                                                                                                                          ,NVL(MCR.ATTRIBUTE2,NVL(MCC.ATTRIBUTE2,NVL(mccr.ATTRIBUTE2,cowip.ATTRIBUTE2))))
                                                                                                                   ,NVL(MCR.ATTRIBUTE4,NVL(MCC.ATTRIBUTE4,NVL(mccr.ATTRIBUTE4,cowip.ATTRIBUTE4))))
                                                                                                            ,NVL(gjl.ATTRIBUTE6,dtap.ATTRIBUTE6))), gcc.segment3) CONTA_ORIG
     , (SELECT FVAL.DESCRIPTION DESCR_CONTA
          FROM apps.FND_ID_FLEX_SEGMENTS FSEG
             , APPS.FND_FLEX_VALUES_VL FVAL
         WHERE FSEG.ID_FLEX_NUM = 50368
           AND FSEG.ID_FLEX_CODE = 'GL#'
           AND FSEG.SEGMENT_NAME = 'CONTA'
           AND FVAL.FLEX_VALUE = DECODE(gcc.segment3,'211999000000100335', DECODE(NVL(dtap.SOURCE,'XXX'),'FUNDIARIO','615011999000001174',NVL(Decode(NVL(MCR.ATTRIBUTE4,NVL(MCC.ATTRIBUTE4,NVL(mccr.ATTRIBUTE4,cowip.ATTRIBUTE4)))
                                                                                                                                             ,'1'
                                                                                                                                             ,Decode(NVL(MCR.ATTRIBUTE2,NVL(MCC.ATTRIBUTE2,NVL(mccr.ATTRIBUTE2,cowip.ATTRIBUTE2)))
                                                                                                                                                    ,'1'
                                                                                                                                                    ,NVL(MCR.ATTRIBUTE3,NVL(MCC.ATTRIBUTE3,NVL(mccr.ATTRIBUTE3,cowip.ATTRIBUTE3)))
                                                                                                                                                    ,NVL(MCR.ATTRIBUTE2,NVL(MCC.ATTRIBUTE2,NVL(mccr.ATTRIBUTE2,cowip.ATTRIBUTE2))))
                                                                                                                                             ,NVL(MCR.ATTRIBUTE4,NVL(MCC.ATTRIBUTE4,NVL(mccr.ATTRIBUTE4,cowip.ATTRIBUTE4))))
                                                                                                                                      ,NVL(gjl.ATTRIBUTE6,dtap.ATTRIBUTE6))), gcc.segment3)
           AND FVAL.FLEX_VALUE_SET_ID = FSEG.FLEX_VALUE_SET_ID ) DESCR_CONTA_ORIG
     , gcc.segment1 EMPRESA
--     , gcc.segment3 CONTA
     , CASE
          WHEN ((gcc.segment3 = '615011121060101308')
         --And ((cowip.ACTIVITY_TYPE_DISP Like '%ABASTECIMENTO%') Or (gjct.user_je_category_name = 'CLL F189 INTEGRATED RCV'))
           And TAB1.CENTRO_CUSTO In ('020101','020102','020201','020301','020302','020400','020401','020402'
                                 ,'020403','020404','020405','020501','020601','020701','030000','030101'
                                 ,'030200','030201','030202','030203','030204','030205','030206','030301','040502')) THEN
             '615011111050500459'
          WHEN ((gcc.segment3 = '615014111999900605')--'615014111140000605')
         --And ((cowip.ACTIVITY_TYPE_DISP Like '%ABASTECIMENTO%') Or (gjct.user_je_category_name = 'CLL F189 INTEGRATED RCV'))
           And TAB1.CENTRO_CUSTO In ('010101', '010102', '010103', '040101', '040201', '040202', '040301', '040401'
                                    ,'040501', '040601', '040701', '040703', '040801', '050101', '050201', '050301'
                                    , '060101', '070101')) THEN
             '615014111140000604'
          ELSE
             gcc.segment3
       END CONTA
--     , TAB1.DESCR_CONTA
     , CASE
          WHEN ((gcc.segment3 = '615011121060101308')
         --And ((cowip.ACTIVITY_TYPE_DISP Like '%ABASTECIMENTO%') Or (gjct.user_je_category_name = 'CLL F189 INTEGRATED RCV'))
           And TAB1.CENTRO_CUSTO In ('020101','020102','020201','020301','020302','020400','020401','020402'
                                 ,'020403','020404','020405','020501','020601','020701','030000','030101'
                                 ,'030200','030201','030202','030203','030204','030205','030206','030301','040502')) THEN
             'MATERIAL - COMBUSTIVEL OUTROS'
          WHEN ((gcc.segment3 = '615014111999900605')--'615014111140000605')
         --And ((cowip.ACTIVITY_TYPE_DISP Like '%ABASTECIMENTO%') Or (gjct.user_je_category_name = 'CLL F189 INTEGRATED RCV'))
           And TAB1.CENTRO_CUSTO In ('010101', '010102', '010103', '040101', '040201', '040202', '040301', '040401'
                                    ,'040501', '040601', '040701', '040703', '040801', '050101', '050201', '050301'
                                    , '060101', '070101')) THEN
             'COMBUSTIVEIS E LUBRIFICANTES'
          ELSE
             TAB1.DESCR_CONTA
       END DESCR_CONTA
     , TAB1.CENTRO_CUSTO CENTRO_CUSTO
     , TAB1.DESCR_CENTRO_CUSTO
     , gcc.segment4 PROGRAMA
     , TAB1.DESCR_PROGRAMA
     , gcc.segment5 CLASS_ATIVO
     , gcc.segment6 FUTURO1
     , gcc.segment7 RUTORU2
     , gcc.CODE_COMBINATION_ID
--     , gcc.segment3||TAB1.CENTRO_CUSTO||gcc.segment4 CONCAT_CONTA_CC_PROG
     , CASE
          WHEN ((gcc.segment3 = '615011121060101308')
         --And ((cowip.ACTIVITY_TYPE_DISP Like '%ABASTECIMENTO%') Or (gjct.user_je_category_name = 'CLL F189 INTEGRATED RCV'))
           And TAB1.CENTRO_CUSTO In ('020101','020102','020201','020301','020302','020400','020401','020402'
                                 ,'020403','020404','020405','020501','020601','020701','030000','030101'
                                 ,'030200','030201','030202','030203','030204','030205','030206','030301','040502')) THEN
             '615011111050500459'||TAB1.CENTRO_CUSTO||gcc.segment4
          WHEN ((gcc.segment3 = '615014111999900605')--'615014111140000605')
         --And ((cowip.ACTIVITY_TYPE_DISP Like '%ABASTECIMENTO%') Or (gjct.user_je_category_name = 'CLL F189 INTEGRATED RCV'))
           And TAB1.CENTRO_CUSTO In ('010101', '010102', '010103', '040101', '040201', '040202', '040301', '040401'
                                    ,'040501', '040601', '040701', '040703', '040801', '050101', '050201', '050301'
                                    , '060101', '070101')) THEN
             '615014111140000604'||TAB1.CENTRO_CUSTO||gcc.segment4
          ELSE
             gcc.segment3||TAB1.CENTRO_CUSTO||gcc.segment4
       END CONCAT_CONTA_CC_PROG
     , gjl.effective_date  DATA_EFETIVA_CONTAB
     , gjl.description     HISTORICO
     , gjh.description     Referencia_documento_lote
     , 'NOME:'|| NVL(gjh.NAME,'**************')|| CHR(10)
              || 'LOTE:'||NVL(gjb.NAME,'**************') LOTE
     , (SELECT GCC.CONCATENATED_SEGMENTS
          FROM apps.GL_JE_LINES gjl1
             , apps.GL_CODE_COMBINATIONS_KFV GCC
         WHERE gjl1.JE_HEADER_ID = gjl.JE_HEADER_ID
           AND gjl1.JE_LINE_NUM <> gjl.JE_LINE_NUM
           AND GCC.CODE_COMBINATION_ID = gjl1.CODE_COMBINATION_ID
           AND EXISTS (SELECT COUNT(1)
                            , gjl2.JE_HEADER_ID
                         FROM GL_JE_LINES gjl2
                        WHERE gjl2.JE_HEADER_ID = gjl.JE_HEADER_ID
                        GROUP BY gjl2.JE_HEADER_ID HAVING COUNT(1) = 2
                                                      AND SUM(NVL(gjl2.ACCOUNTED_DR,0) - NVL(gjl2.ACCOUNTED_CR,0) ) = 0)
       ) CONTRAPARTIDA
     , NVL(gjl.ACCOUNTED_DR,0) VL_CONTAB_DEB
     , NVL(gjl.ACCOUNTED_CR,0) VL_CONTAB_CRED
     , NVL(gjl.ACCOUNTED_DR,0) - NVL(gjl.ACCOUNTED_CR,0) AS VL_NET
     , RPad(Decode(gjh.je_source,'Manual','M','Spreadsheet','M','S'), 01,' ') M_Manual_S_Sistema
     , gjh.posted_date         Data_registro_contabil
     , gjh.currency_code       Moeda
     , gjh.status
       ----- fornecedor'
     , ASSA.GLOBAL_ATTRIBUTE10||ASSA.GLOBAL_ATTRIBUTE11||ASSA.GLOBAL_ATTRIBUTE12 CNPJ_CPF
     , APS.VENDOR_NAME   FORNECEDOR
     , NVL(PHA.SEGMENT1,cowip.PO_NUM)        NRO_PO
     , NVL(PHA.attribute9,cowip.CONTRAT_NUM) NRO_CONTRATO
     , Nvl(dtap.Invoice_Num,CFI.INVOICE_NUM) NRO_NF
       ----- orçamentária'
     , TAB1.DESC_GERENCIA
     , TAB1.DESC_DIRETORIA
     , CASE
          WHEN ((gjl.description LIKE '%LWART%')
            OR (gjct.je_category_key In ('Depreciation','Deferred Depreciation','Unitizacao','Retirement'))
            OR ((gcc.segment3='112951000000000743') and (upper(gjb.NAME) like '%ENCERRAMENTO%PROJETO%'))) THEN
            'Não gerenciável'
         WHEN (gcc.segment4 In ('0011111','CT00102')) THEN
            'Não gerenciável'
         ELSE
            TAB1.DESC_CLASSIFICAO_GERENCIAL1
      END DESC_CLASSIFICAO_GERENCIAL1
     , TAB1.DESC_CLASSIFICAO_GERENCIAL2
     , TAB1.DESC_CLASSIFICAO_GERENCIAL3
     , TAB1.DESC_CLASSIFICAO_DRE_GEREN
     , TAB1.DESC_PROG_CLASS_GERENCIAL3
     , TAB1.DESC_PROG_SOCIOAMBIENTAL
       --
     , NVL(SGSRF.CONTA_ORCAMENTARIA,'Pendente de Reclassificação') CONTA_ORCAMENTARIA
     , SGCO.PACOTE  PACOTE
     , SGCO.CLASSIFICACAO  CLASSIFICACAO
       --
     , gjl.REFERENCE_1
     , gjl.REFERENCE_3
     , gjl.REFERENCE_4
     , gjl.REFERENCE_7
     , NVL(MCR.CATEGORY_ID,NVL(MCC.CATEGORY_ID,NVL(mccr.CATEGORY_ID,cowip.MTL_CATEGORY_ID))) MTL_CATEGORY_ID
     , NVL(MCR.DESCRIPTION,NVL(MCC.DESCRIPTION,NVL(mccr.DESCRIPTION,cowip.MTL_CATEGORY_NAME))) MTL_CATEGORY_NAME
       --
--Select *
  From gl.gl_je_lines gjl           -- Linhas contabilizada
     , gl.gl_code_combinations gcc  -- Combinação contábil
     , gl.gl_je_headers gjh         -- Header das linhas contabilizadas
     , gl.GL_JE_BATCHES gjb         -- Lote contabilizado
     , gl.gl_ledgers gls            -- Livros
     , gl.gl_periods gp             -- Período contábil
     , gl.gl_je_categories_tl gjct  -- Categoria da contabilização
     , gl.gl_je_sources_tl gjst     -- Origem da contabilização
     , (SELECT CASE WHEN FVAL3.FLEX_VALUE = '132011997000001570'
                     AND FVAL4.FLEX_VALUE = 'C000329'
                     AND FVAL2.FLEX_VALUE = '000000' THEN
                  '020401'
               ELSE
                  FVAL2.FLEX_VALUE
               END CENTRO_CUSTO
             , CASE WHEN FVAL3.FLEX_VALUE = '132011997000001570'
                     AND FVAL4.FLEX_VALUE = 'C000329'
                     AND FVAL2.FLEX_VALUE = '000000' THEN
                  'GERENCIA DE O&M'
               ELSE
                  FVAL2.DESCRIPTION
               END DESCR_CENTRO_CUSTO
             , (SELECT FFVV.DESCRIPTION
                  FROM APPS.FND_FLEX_VALUES_VL FFVV
                     , APPS.FND_FLEX_VALUE_SETS FFVS
                 WHERE FFVV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
                   AND FFVV.FLEX_VALUE = FVAL2.ATTRIBUTE15
                   AND FFVS.FLEX_VALUE_SET_NAME = 'SAE_GL_CCUSTO_GERENCIA'
                   AND FFVS.FLEX_VALUE_SET_ID = FFVV.FLEX_VALUE_SET_ID)  DESC_GERENCIA
               , (SELECT FFVV.DESCRIPTION
                    FROM APPS.FND_FLEX_VALUES_VL FFVV
                       , APPS.FND_FLEX_VALUE_SETS FFVS
                   WHERE FFVV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
                     AND FFVV.FLEX_VALUE = FVAL2.ATTRIBUTE16
                     AND FFVS.FLEX_VALUE_SET_NAME = 'SAE_GL_CCUSTO_DIRETORIA'
                     AND FFVS.FLEX_VALUE_SET_ID = FFVV.FLEX_VALUE_SET_ID)   DESC_DIRETORIA
             , FVAL3.FLEX_VALUE CONTA
             , FVAL3.DESCRIPTION DESCR_CONTA
             , (SELECT FFVV.DESCRIPTION
                  FROM APPS.FND_FLEX_VALUES_VL FFVV
                     , APPS.FND_FLEX_VALUE_SETS FFVS
                 WHERE FFVV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
                   AND FFVV.FLEX_VALUE = FVAL3.ATTRIBUTE15
                   AND FFVS.FLEX_VALUE_SET_NAME = 'SAE_GL_CONTA_CLASSIFICACAO1'
                   AND FFVS.FLEX_VALUE_SET_ID = FFVV.FLEX_VALUE_SET_ID)   DESC_CLASSIFICAO_GERENCIAL1
             , (SELECT FFVV.DESCRIPTION
                  FROM APPS.FND_FLEX_VALUES_VL FFVV
                     , APPS.FND_FLEX_VALUE_SETS FFVS
                 WHERE FFVV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
                   AND FFVV.FLEX_VALUE = FVAL3.ATTRIBUTE16
                   AND FFVS.FLEX_VALUE_SET_NAME = 'SAE_GL_CONTA_CLASSIFICACAO2'
                   AND FFVS.FLEX_VALUE_SET_ID = FFVV.FLEX_VALUE_SET_ID)   DESC_CLASSIFICAO_GERENCIAL2
             , (SELECT FFVV.DESCRIPTION
                  FROM APPS.FND_FLEX_VALUES_VL FFVV
                     , APPS.FND_FLEX_VALUE_SETS FFVS
                 WHERE FFVV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
                   AND FFVV.FLEX_VALUE = FVAL3.ATTRIBUTE17
                   AND FFVS.FLEX_VALUE_SET_NAME = 'SAE_GL_CONTA_CLASSIFICACAO3'
                   AND FFVS.FLEX_VALUE_SET_ID = FFVV.FLEX_VALUE_SET_ID)   DESC_CLASSIFICAO_GERENCIAL3
             , (SELECT FFVV.DESCRIPTION
                  FROM APPS.FND_FLEX_VALUES_VL FFVV
                     , APPS.FND_FLEX_VALUE_SETS FFVS
                 WHERE FFVV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
                   AND FFVV.FLEX_VALUE = FVAL3.ATTRIBUTE18
                   AND FFVS.FLEX_VALUE_SET_NAME = 'SAE_GL_CONTA_CLASS_DRE_GEREN'
                   AND FFVS.FLEX_VALUE_SET_ID = FFVV.FLEX_VALUE_SET_ID)  DESC_CLASSIFICAO_DRE_GEREN
             , FVAL4.FLEX_VALUE PROGRAMA
             , FVAL4.DESCRIPTION DESCR_PROGRAMA
             , (SELECT FFVV.DESCRIPTION
                  FROM APPS.FND_FLEX_VALUES_VL FFVV
                     , APPS.FND_FLEX_VALUE_SETS FFVS
                 WHERE FFVV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
                   AND FFVV.FLEX_VALUE = FVAL4.ATTRIBUTE17
                   AND FFVS.FLEX_VALUE_SET_NAME = 'SAE_GL_PROG_CLASSIFICACAO3'
                   AND FFVS.FLEX_VALUE_SET_ID = FFVV.FLEX_VALUE_SET_ID) DESC_PROG_CLASS_GERENCIAL3
             , (SELECT FFVV.DESCRIPTION
                  FROM APPS.FND_FLEX_VALUES_VL FFVV
                     , APPS.FND_FLEX_VALUE_SETS FFVS
                 WHERE FFVV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
                   AND FFVV.FLEX_VALUE = FVAL4.ATTRIBUTE18
                   AND FFVS.FLEX_VALUE_SET_NAME = 'SAE_GL_PROG_SOCIOAMBIENTAL'
                   AND FFVS.FLEX_VALUE_SET_ID = FFVV.FLEX_VALUE_SET_ID) DESC_PROG_SOCIOAMBIENTAL
             , GCC.CODE_COMBINATION_ID
          FROM apps.FND_ID_FLEX_SEGMENTS FSEG2
             , apps.FND_ID_FLEX_SEGMENTS FSEG3
             , apps.FND_ID_FLEX_SEGMENTS FSEG4
             , apps.FND_FLEX_VALUES_VL FVAL2
             , apps.FND_FLEX_VALUES_VL FVAL3
             , apps.FND_FLEX_VALUES_VL FVAL4
             , apps.GL_CODE_COMBINATIONS GCC
         WHERE FSEG2.ID_FLEX_NUM = 50368
           AND FSEG2.ID_FLEX_CODE = 'GL#'
           AND FSEG2.SEGMENT_NAME = 'CENTRO CUSTO'
           AND FVAL2.FLEX_VALUE_SET_ID = FSEG2.FLEX_VALUE_SET_ID
           AND FVAL2.FLEX_VALUE = GCC.SEGMENT2||''
           --
           AND FSEG3.ID_FLEX_NUM = 50368
           AND FSEG3.ID_FLEX_CODE = 'GL#'
           AND FSEG3.SEGMENT_NAME = 'CONTA'
           AND FVAL3.FLEX_VALUE_SET_ID = FSEG3.FLEX_VALUE_SET_ID
           AND FVAL3.FLEX_VALUE = GCC.SEGMENT3||''
           --
           AND FSEG4.ID_FLEX_NUM = 50368
           AND FSEG4.ID_FLEX_CODE = 'GL#'
           AND FSEG4.SEGMENT_NAME = 'PROGRAMA'
           AND FVAL4.FLEX_VALUE_SET_ID = FSEG4.FLEX_VALUE_SET_ID
           AND FVAL4.FLEX_VALUE = GCC.SEGMENT4||''
     ) TAB1
     , APPS.SAE_GL_STRUTURA_RAZAO_FINANC SGSRF -- Tabela customizada Strutura contábil para associar com o Razão
     , APPS.SAE_GL_CONTA_ORCAMENTARIA SGCO --Tabela customizada com a informaão da Conta Orçaamentária
       --
     , APPS.CLL_F189_INVOICE_DIST CFID
     , APPS.CLL_F189_INVOICES CFI
     , APPS.PO_DISTRIBUTIONS_ALL PDA
     , APPS.PO_HEADERS_ALL PHA
     , APPS.PO_LINES_ALL PLA
     , APPS.PO_REQ_DISTRIBUTIONS_ALL PRD
     , APPS.PO_REQUISITION_LINES_ALL PRL
     , APPS.MTL_CATEGORIES_V MCR
     , APPS.MTL_CATEGORIES_V MCC
     , xla.xla_ae_lines XAL                -- Tabelas do SLA utilizada para realizar o Drill down com a orgiem
     , xla.xla_distribution_links XDLINV   -- Tabelas do SLA utilizada para realizar o Drill down no INV para capturar a orgiem
       -- Busca quando Origem for INV, buscar informação Conta Origem da Categori do Intem
     , inv.mtl_transaction_accounts mtar
     , apps.mtl_material_transactions mmtr
     , po.rcv_shipment_lines rslr
     , apps.mtl_categories_v mccr
       -- Busca as informações do fornecedor
     , APPS.AP_SUPPLIER_SITES_ALL ASSA
     , APPS.AP_SUPPLIERS APS
       -- Busca quando Origem for AP, busca conta origem disponbilizada no ATTRIBUTE6 da lines
     , (
        Select distinct gjlx.je_header_id
             , gjlx.je_line_num
             , aia.vendor_site_id
             , aia.vendor_id
             , aia.Invoice_Num
             , aia.SOURCE
             , aila.ATTRIBUTE6
             , aila.line_type_lookup_code
          From gl.gl_je_lines gjlx
             , xla.xla_ae_lines XAL             -- Tabelas do SLA utilizada para realizar o Drill down com a orgiem
             , xla.xla_distribution_links XDL   -- Tabelas do SLA utilizada para realizar o Drill down com a orgiem
             , ap.ap_invoice_distributions_all aida -- Origem AP - Integra com XLA
             , ap.ap_invoice_lines_all aila         -- Origem AP vetorh/IEX/PAG.DIRET
             , AP.AP_INVOICES_ALL aia               -- Origem AP Afetado/IEX/PAG.DIRET
         WHERE 1 = 1
           And xal.gl_sl_link_id(+) = gjlx.gl_sl_link_id+0
           And xdl.SOURCE_DISTRIBUTION_TYPE(+) = 'AP_INV_DIST'
           And xdl.application_id(+) = xal.application_id+0
           And xdl.ae_header_id(+) = xal.AE_HEADER_ID+0
           And xdl.ae_line_num(+) = xal.ae_line_num
           And xdl.SOURCE_DISTRIBUTION_TYPE(+) = 'AP_INV_DIST'
           And aida.invoice_distribution_id(+) = xdl.source_distribution_id_num_1
           And aila.invoice_id(+) = aida.invoice_id+0
           And aila.line_number(+) = aida.invoice_line_number
           And aia.invoice_id(+) = aila.invoice_id+0
       ) dtap
       -- Busca conta orgiem do Gerenciamento de custo WIP
     , (
        Select distinct gjl.je_header_id
             , gjl.JE_LINE_NUM
             , pha.segment1    PO_NUM
             , pha.Attribute9 CONTRAT_NUM
             , pha.vendor_site_id
             , pha.vendor_id
             , NVL(MCR.CATEGORY_ID,MCC.CATEGORY_ID) MTL_CATEGORY_ID
             , NVL(MCR.DESCRIPTION,MCC.DESCRIPTION) MTL_CATEGORY_NAME
             , NVL(MCR.ATTRIBUTE2,MCC.ATTRIBUTE2) ATTRIBUTE2
             , NVL(MCR.ATTRIBUTE3,MCC.ATTRIBUTE3) ATTRIBUTE3
             , NVL(MCR.ATTRIBUTE4,MCC.ATTRIBUTE4) ATTRIBUTE4
             , EWOV.ASSET_NUMBER
             , EWOV.ACTIVITY_TYPE_DISP
          From gl.gl_je_lines gjl
             , xla.xla_ae_lines xal
             , xla.xla_distribution_links xdl
             , apps.wip_transaction_accounts wta
             , apps.wip_transactions wt
             , APPS.EAM_WORK_ORDERS_V EWOV
             , po.po_distributions_all pda
             , po.po_headers_all pha
             , APPS.PO_LINES_ALL PLA
             , APPS.PO_REQ_DISTRIBUTIONS_ALL PRD
             , APPS.PO_REQUISITION_LINES_ALL PRL
             , APPS.MTL_CATEGORIES_V MCR
             , APPS.MTL_CATEGORIES_V MCC
         Where xal.gl_sl_link_id(+) = gjl.gl_sl_link_id
           And xdl.ae_header_id(+) = xal.ae_header_id
           And xdl.ae_line_num(+) = xal.ae_line_num
           And xdl.SOURCE_DISTRIBUTION_TYPE(+) = 'WIP_TRANSACTION_ACCOUNTS'
           And wta.wip_sub_ledger_id(+) = xdl.source_distribution_id_num_1
           And wt.transaction_id(+) = wta.transaction_id
           AND EWOV.WIP_ENTITY_ID(+) = wt.WIP_ENTITY_ID
           And pda.wip_entity_id(+) = wt.wip_entity_id
           And pda.wip_operation_seq_num(+) = wt.operation_seq_num
           And pda.wip_resource_seq_num(+) = wt.resource_seq_num
           And pda.po_header_id(+) = wt.po_header_id
           And pda.po_line_id(+) = wt.po_line_id
           And PLA.PO_LINE_ID(+) = PDA.PO_LINE_ID
           And PHA.PO_HEADER_ID(+) = PDA.PO_HEADER_ID
           And PRD.DISTRIBUTION_ID(+) = PDA.REQ_DISTRIBUTION_ID
           And PRL.REQUISITION_LINE_ID(+) = PRD.REQUISITION_LINE_ID
           And MCR.CATEGORY_ID(+) = PRL.CATEGORY_ID
           And MCC.CATEGORY_ID(+) = PLA.CATEGORY_ID
       ) cowip
 Where 1=1
   And gcc.code_combination_id   = gjl.code_combination_id+0
   And gcc.segment1||''         in ('01','02')
   And gjh.je_header_id          = gjl.je_header_id+0
   And gjh.status                = 'P'
   AND gjh.actual_flag           = 'A'
   AND gjb.JE_BATCH_ID           = gjh.JE_BATCH_ID+0
   AND gjb.AVERAGE_JOURNAL_FLAG  = 'N'
   AND gls.ledger_id             = gjh.ledger_id
   And gls.name                  = 'SAE'
   And gp.period_name            = gjh.period_name
   AND gjct.je_category_name     =  gjh.je_category
   AND gjct.language             = 'PTB'
   And gjst.je_source_name       = gjh.je_source
   And gjst.language             = 'PTB'
   And TAB1.CODE_COMBINATION_ID  = gjl.CODE_COMBINATION_ID+0
   ---
   And SGSRF.CENTRO_DE_CUSTOS(+) = TAB1.CENTRO_CUSTO --gcc.segment2||''
--   And SGSRF.CONTA_CONTABIL(+) = gcc.segment3||''
   And SGSRF.CONTA_CONTABIL(+) =  CASE
                                     WHEN ((gcc.segment3 = '615011121060101308')
                                    --And ((cowip.ACTIVITY_TYPE_DISP Like '%ABASTECIMENTO%') Or (gjct.user_je_category_name = 'CLL F189 INTEGRATED RCV'))
                                      And TAB1.CENTRO_CUSTO In ('020101','020102','020201','020301','020302','020400','020401','020402'
                                                            ,'020403','020404','020405','020501','020601','020701','030000','030101'
                                                            ,'030200','030201','030202','030203','030204','030205','030206','030301','040502')) THEN
                                        '615011111050500459'
                                     WHEN ((gcc.segment3 = '615014111999900605')--'615014111140000605')
                                    --And ((cowip.ACTIVITY_TYPE_DISP Like '%ABASTECIMENTO%') Or (gjct.user_je_category_name = 'CLL F189 INTEGRATED RCV'))
                                      And TAB1.CENTRO_CUSTO In ('010101', '010102', '010103', '040101', '040201', '040202', '040301', '040401'
                                                               ,'040501', '040601', '040701', '040703', '040801', '050101', '050201', '050301'
                                                               , '060101', '070101')) THEN
                                        '615014111140000604'
                                     ELSE
                                        gcc.segment3
                                  END 
   And SGSRF.PROGRAMA(+) = gcc.segment4||''
   And SGCO.CONTA_ORCAMENTARIA(+) = SGSRF.CONTA_ORCAMENTARIA||''
   ---
   AND CFID.ORGANIZATION_ID(+) = To_number(gjl.REFERENCE_1)
   AND CFID.INVOICE_ID(+) = To_number(gjl.REFERENCE_7)
   AND CFID.INVOICE_LINE_ID(+) = To_number(gjl.REFERENCE_3)
   AND CFID.PO_DISTRIBUTION_ID(+) = To_number(gjl.REFERENCE_4)
   ---
   AND CFI.INVOICE_ID(+) = CFID.INVOICE_ID
   AND PDA.PO_DISTRIBUTION_ID(+) = CFID.PO_DISTRIBUTION_ID
   ---
   AND PLA.PO_LINE_ID(+) = PDA.PO_LINE_ID
   AND PHA.PO_HEADER_ID(+) = PDA.PO_HEADER_ID
   AND PRD.DISTRIBUTION_ID(+) = PDA.REQ_DISTRIBUTION_ID
   AND PRL.REQUISITION_LINE_ID(+) = PRD.REQUISITION_LINE_ID
   AND MCR.CATEGORY_ID(+) = PRL.CATEGORY_ID
   AND MCC.CATEGORY_ID(+) = PLA.CATEGORY_ID
   ---
   And xal.gl_sl_link_id(+) = gjl.gl_sl_link_id
   And xdlinv.SOURCE_DISTRIBUTION_TYPE(+) = 'MTL_TRANSACTION_ACCOUNTS'
   And xdlinv.application_id(+) = xal.application_id
   And xdlinv.ae_header_id(+) = xal.AE_HEADER_ID
   And xdlinv.ae_line_num(+) = xal.ae_line_num
   And xdlinv.EVENT_ID(+) = To_number(gjl.REFERENCE_6)
   ---
   And mtar.INV_SUB_LEDGER_ID(+) = xdlinv.source_distribution_id_num_1
   And mmtr.transaction_id(+) = mtar.transaction_id
   And rslr.mmt_transaction_id(+) = NVL(mmtr.parent_transaction_id,mtar.transaction_id)
   And mccr.category_id(+) = rslr.category_id
   ---
   And dtap.je_header_id = gjl.je_header_id+0
   And dtap.je_line_num = gjl.je_line_num
   ---
   And cowip.je_header_id = gjl.je_header_id+0
   And cowip.je_line_num = gjl.je_line_num
   ---
   AND ASSA.VENDOR_SITE_ID(+) = NVL(CFID.VENDOR_SITE_ID, NVL(dtap.vendor_site_id,cowip.vendor_site_id))
   AND APS.VENDOR_ID(+) = assa.vendor_id
Order By gjl.je_header_id
       , gjl.je_line_num;
--
GRANT SELECT ON APPS.SAE_GL_RAZAO_FINANCEIRO_V TO SOFTEXPERT;
GRANT SELECT ON APPS.SAE_GL_RAZAO_FINANCEIRO_V TO APPS_CONSULT;
--
