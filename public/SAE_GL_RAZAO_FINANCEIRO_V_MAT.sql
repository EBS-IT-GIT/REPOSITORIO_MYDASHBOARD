set define off;
--
DROP MATERIALIZED VIEW SAE_GL_RAZAO_FINANCEIRO_V_MAT;
--
CREATE MATERIALIZED VIEW SAE_GL_RAZAO_FINANCEIRO_V_MAT 
LOGGING 
TABLESPACE APPS_TS_TX_DATA 
PCTFREE 10 
INITRANS 1 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOCOMPRESS 
NO INMEMORY 
NOCACHE 
NOPARALLEL 
USING INDEX 
REFRESH START WITH TO_DATE('23-04-2020 05:00:00', 'DD-MM-YYYY HH24:MI:SS')
NEXT SYSDATE + 1   
COMPLETE 
USING DEFAULT LOCAL ROLLBACK SEGMENT 
DISABLE QUERY REWRITE 
AS
  SELECT v.CENTRO_CUSTO,
    NVL (v.classificacao, '**Pendente de classificação Orçamentária') Classificacao,
    DECODE(v.CONTA_ORCAMENTARIA,'Pedente de Reclassificação','**Pendente de classificação Orçamentária',v.CONTA_ORCAMENTARIA) CONTA_ORCAMENTARIA,
    v.conta,
    v.CONTA_ORIG,
    NVL(v.PROGRAMA,'0000000') programa,
    v.lote,
    NVL ( v.pacote, '**Pendente de classificação Orçamentária') pacote,
    DECODE( NVL(v.FORNECEDOR,v.USER_JE_SOURCE_NAME),'VETORH', 'Folha de Pagamento','Spreadsheet', 'Lançamento Manual','Planilha', 'Lançamento Manual',NVL(v.FORNECEDOR,v.USER_JE_SOURCE_NAME)) FORNECEDOR,
    DECODE( NVL(v.NRO_PO,v.USER_JE_SOURCE_NAME),'VETORH', 'Folha de Pagamento','Spreadsheet', 'Lançamento Manual','Planilha', 'Lançamento Manual',NVL(v.NRO_PO,v.USER_JE_SOURCE_NAME)) PO,
    DECODE( NVL(v.NRO_CONTRATO,v.USER_JE_SOURCE_NAME),'VETORH', 'Folha de Pagamento','Spreadsheet', 'Lançamento Manual','Planilha', 'Lançamento Manual',NVL(v.NRO_CONTRATO,v.USER_JE_SOURCE_NAME)) CONTRATO,
    DECODE( NVL(v.nro_nf,v.USER_JE_SOURCE_NAME),'VETORH', 'Folha de Pagamento','Spreadsheet', 'Lançamento Manual','Planilha', 'Lançamento Manual',NVL(v.nro_nf,v.USER_JE_SOURCE_NAME)) NF,
    TO_CHAR(v.DATA_EFETIVA_CONTAB,'MM/YYYY') Mes,
    v.DATA_EFETIVA_CONTAB,
    v.historico,
    0 Valor_Orcado,
    v.vl_net Valor_Realizado,
    v.VL_CONTAB_DEB,
    v.VL_CONTAB_cred,
    TO_CHAR(sysdate, 'HH24:MI:SS DD/MM/YYYY') ULTIMA_ATUALIZACAO
  FROM SAE_GL_RAZAO_FINANCEIRO_V v ,
    (SELECT SICP.TIPO_CONTA_CONTABIL ,
      RPad(SICP.CONTA_CONTABIL_DE,18,'0') CONTA_CONTABIL_DE ,
      RPad(SICP.CONTA_CONTABIL_ATE,18,'9') CONTA_CONTABIL_ATE
    FROM apps.SAE_INTERVALO_CONTA_PADRAO SICP
    ) CP
  WHERE v.DATA_EFETIVA_CONTAB >=to_date('01/01/2019','DD/MM/YYYY')
  AND v.conta BETWEEN CP.CONTA_CONTABIL_DE AND CP.CONTA_CONTABIL_ATE
  AND CP.TIPO_CONTA_CONTABIL        IN ('ATIVO','PASSIVO','RESULTADO','P&D')
  AND v.DESC_CLASSIFICAO_GERENCIAL1 IN ('Gerenciável')
  AND v.empresa                      ='01'
  UNION ALL
  SELECT cc,
    NVL(
    (SELECT C.CLASSIFICACAO
    FROM SAE_GL_CONTA_ORCAMENTARIA C
    WHERE C.CONTA_ORCAMENTARIA=g.CONTA
    AND c.pacote              =g.pacote
    AND rownum                =1
    ),'**Pendente de Classificação Orçamentária'),
    conta,
    NULL,
    NULL,
    NVL(SUBSTR(desc_item,0,7),'0000000'),
    NULL,
    pacote,
    'Orçado',
    'Orçado',
    'Orçado',
    'Orçado',
    TO_CHAR(mes,'MM/YYYY'),
    mes,
    'Orçado',
    valor,
    0,
    0,
    0,
    TO_CHAR(sysdate, 'HH24:MI:SS DD/MM/YYYY')
  FROM apps.SAE_GL_RAZAO_ORCAMENTO_GRADUS g;
--
CREATE INDEX SAE_GL_RAZAO_INDEX1 ON SAE_GL_RAZAO_FINANCEIRO_V_MAT (CENTRO_CUSTO ASC, CONTA_ORCAMENTARIA ASC, PROGRAMA ASC, DATA_EFETIVA_CONTAB ASC) 
LOGGING 
TABLESPACE APPS_TS_TX_DATA 
PCTFREE 10 
INITRANS 2 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;
--
COMMENT ON MATERIALIZED VIEW SAE_GL_RAZAO_FINANCEIRO_V_MAT IS 'snapshot table for snapshot APPS.SAE_GL_RAZAO_FINANCEIRO_V_MAT';
--
grant select on apps.SAE_GL_RAZAO_FINANCEIRO_V_MAT to softexpert;
GRANT SELECT ON apps.SAE_GL_RAZAO_FINANCEIRO_V_MAT TO APPS_CONSULT;
--





