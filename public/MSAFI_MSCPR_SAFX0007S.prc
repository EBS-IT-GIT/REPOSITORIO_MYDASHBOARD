CREATE OR REPLACE PROCEDURE MSAFI_MSCPR_SAFX0007S
                (
                        PRC_PAR_COMPANY_CODE    IN     VARCHAR2, -- CODIGO DA EMPRESA ( ORACLE APPLICATIONS )
                        PRC_PAR_ESTAB_CODE      IN     VARCHAR2, -- CODIGO DO ESTABELECIMENTO ( ORACLE APPLICATIONS )
                        PRC_PAR_BEGIN_DATE      IN     VARCHAR2, -- DATA DE PESQUISA INICIAL
                        PRC_PAR_FINAL_DATE      IN     VARCHAR2, -- DATA DE PESQUISA FINAL
                        PPST_ID                 IN     NUMBER,
                        PPST_ID_FILTRO          IN     NUMBER,
                        PRC_PAR_ERRORS_OCURRED  IN OUT NUMBER    -- INDICADOR DE ERROS OCORRIDOS
                ) IS
------------------------------------------------------------------------------------------------------------------------
--NOME OBJETO.........: MSAFI_MSFPR_SAFX0007S
--NOME FISICO.........: MSAFI_MSFPR_SAFX0007S.SQL
--TIPO_OBJETO.........: PROCEDURE
--NUMERO..............:
--REFERENCIA..........:
--VIEW CLL  ..........:
--AUTOR...............: MASTERSAF
--DATA................: 09/10/2010
--PRE-REQUISITOS......: SPED
--MODIFICACOES........: 2000 - CRIACAO DA PACKAGE
--                    : 2002 - MODIFICADO
--                    : 2004 - MODIFICADO
--                    : 2.0.007 - OS-00034.00000 - 07/10/2010 - PADRONIZACAO CABECALHO
--                    : 2.0.008 - OS-00066.93560 - 10/11/2010 - TRATAMENTO NOTAS COM ITENS IDENTICOS (VIEW DE CAPA MAS TRATA NIVEL ITEM)
--                    : 2.0.008 - OS-00075.93910 - 17/11/2010 - Correcao tratamento campo NORM_DEV - SAFX07S
--                    : 2.0.009 - OS-00097.94311 - 02/12/2010 - AJUSTE DO TRATAMENTO DOS CAMPOS DE VLR_CONTAB_COMPL
--                    : 2.0.009 - OS-00099.94968 - 03/12/2010 - AJUSTE ATRIBUI真O CAMPO COD_CLASS_DOC_FIS
--                    : 2.0.010 - OS-00115.00000 - 21/12/2010 - APLICA真O FILTROS POR PROCEDIMENTO
--                    : 2.0.010 - OS-00126.96767 - 07/01/2011 - TRATAMENTO DO VALOR TOTAL DA NOTA E VALOR CONTABIL COMPLEMENTAR DE NOTAS CONJUGADAS SAFX07S
--                    : 2.0.011 - OS-00130.96767 - 20/01/2011 - NOVO AJUSTE DO VALOR TOTAL DA NOTA E VALOR CONTABIL COMPLEMENTAR DE NOTAS CONJUGADAS
--                    : 2.0.013 - OS-00183.000000 - 11/04/2011 - REVISAO DOS CAMPOS FILTRO XXISV/MSAFI
--                    : 2.0.015 - OS-00226.000000 - 01/08/2011 - IMPLEMENTA真O MAPEAMENTO PIS / COFINS
--                    : 2.0.016 - OS-00257.119075 - 21/11/2011 - REVERSAO AJUSTE ZEROS A ESQUERDA NUM_DOCFIS
--                    : 2.0.016 - OS-00259.000000 - 25/11/2011 - ATUALIZACAO E ORDENACAO DOS INSERTs DAS PROCEDURES
--                    : 2.0.017 - OS-00298.000000 - 24/02/2012 - EQUALIZACAO INTERDADOS X MASTERSAF-DW (PATCH 32)
--                    : 2.0.018 - OS-00314.000000 - 24/02/2012 - EQUALIZACAO INTERDADOS X MASTERSAF-DW (PATCH 38)
--                    : 2.0.019 - OS-00325.019530 - 08/08/2012 - EQUALIZACAO IMPLEMENTACAO CAMPO SUB_SERIE SAFXS(07E,08E,09E,07S,08S,09S,07F,112,114E,116E,114S,116S)
--                    : 2.0.019 - OS-00330.000000 - 29/08/2012 - EQUALIZACAO INTERDADOS X MASTERSAF-DW (PATCH 45)
--CUSTOMIZACOES.......:
--                    : 001
-- DATA               : 28/11/2012
-- AUTOR              : ROGER TADEU MUNHOZ
-- MODIFICA真O        : Quando a informa真o do NUM_DOCFIS_REF for igual ao dado do campo "NUM_DOCFIS" carregar nullo

--                    : 002
-- DATA               : 11/08/2014
-- AUTOR              : Michelle Campos
-- MODIFICA真O        : preencher o campo IND_NFE_DENEG_INUT = 2 quando a nota for inutilizada
------------------------------------------------------------------------------------------------------------------------
--                    : 003
-- DATA               : 29/05/2017
-- AUTOR              : Julio Renze
-- MODIFICA真O        : incluido Codigo Modelo Cotepe
------------------------------------------------------------------------------------------------------------------------
--                    : 004
-- DATA               : 30/05/2017
-- AUTOR              : Julio Renze
-- MODIFICA真O        : incluido Valor ICMS e IPI NDESTAC
------------------------------------------------------------------------------------------------------------------------
--                    : EAM 001
-- DATA               : 24/06/2017
-- AUTOR              : EDUARDO AMBRIZZI
-- MODIFICA真O        : BASE IPI
------------------------------------------------------------------------------------------------------------------------
--                    : 005
-- DATA               : 13/09/2017
-- AUTOR              : Wesley Souza - Ninecon
-- MODIFICA真O        : Inclusao da Natureza de Operacao
------------------------------------------------------------------------------------------------------------------------
--                    : 006
-- DATA               : 27/09/2017
-- AUTOR              : Wesley Souza - Ninecon
-- MODIFICA真O        : Tratamento para preenchimento de BASE_ISEN_IPI e BASE_OUTR_IPI
------------------------------------------------------------------------------------------------------------------------
--                    : 007
-- DATA               : 20/10/2017
-- AUTOR              : Wesley Souza - Ninecon
-- MODIFICA真O        : Tratamento para preenchimento de BASE_ISEN_ICMS e BASE_OUTR_ICMS
------------------------------------------------------------------------------------------------------------------------
--                    : 008
-- DATA               : 22/10/2017
-- AUTOR              : Wesley Souza - Ninecon
-- MODIFICA真O        : Tratamento para preenchimento de VLR_ICMS e VLR_ICMS_NDESTAC
------------------------------------------------------------------------------------------------------------------------
--                    : 010
-- DATA               : 24/06/2019
-- AUTOR              : Vinicius Ferreira
-- MODIFICA真O        : Ajustes no campo de IND_NFE_DENEG_INUT
------------------------------------------------------------------------------------------------------------------------

  /******************************************************************************

     PARAMETROS DE ENTRADA.......: PRC_PAR_COMPANY_CODE ..: CNPJ DA EMPRESA QUE SE
                                   DESEJA GERAR OS DADOS.

                                   PRC_PAR_ESTAB_CODE ....: ESTAB DA EMPRESA QUE SE
                                   DESEJA GERAR OS DADOS.

                                   PRC_PAR_BEGIN_DATE.....: DATA INICIAL DA PESQUISA

                                   PRC_PAR_FINAL_DATE.....: DATA FINAL DA PESQUISA

                                   PRC_PAR_BEGIN_LOADER...: 'S' - CARGA INICIAL
                                                            'N' - EXPORT DATA

                                   PPST_ID              ..: NUMERO DO ID DA EXECUCAO

                                   PRC_PAR_ERRORS_OCURRED.: 1 - ERRO DURANTE O
                                                                PROCESSAMENTO

                                                            0 - PROCESSAMENTO OK

  ****************************************************************************** */

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  --
  -- CURSORES DE PARAMETRIZAC?O DA NOTA FISCAL DE SAIDA
  --
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  -- ******************************************************************
  -- ****
  -- *** 01. PARAMETRIZAC?O PARA VERIFICAR SE HAVER?O DADOS DE ENTRADA
  -- **      NO AR
  -- *

  CURSOR CRS_MSPM07E1( P_CRS_PAR_COMPANY_CODE VARCHAR2 ) IS
     SELECT IND_NFE_AR
     FROM MSAFI_MSFTS_PM07E_1
     WHERE COD_EMPRESA = P_CRS_PAR_COMPANY_CODE;

     RECORD_MSPM07E1 CRS_MSPM07E1%ROWTYPE;
     BFOUND_MSPM07E1_COMPANY  BOOLEAN := FALSE;
     BFOUND_MSPM07E1_TODOS    BOOLEAN := FALSE;


  -- ******************************************************************
  -- ****
  -- *** 02. IDENTIFICAC?O DA PARAMETRIZAC?O DO LIVRO FISCAL
  -- **
  -- *

  CURSOR CRS_MSPM07S1( CRS_PAR_COMPANY_CODE VARCHAR2 ) IS
     SELECT IND_CLASS_NFS
     FROM MSAFI_MSFTS_PM07S_1
     WHERE CRS_PAR_COMPANY_CODE = COD_EMPRESA;

     RECORD_MSPM07S1           CRS_MSPM07S1%ROWTYPE;
     BFOUND_MSPM07S1_COMPANY   BOOLEAN:= FALSE;
     BFOUND_MSPM07S1_TODOS     BOOLEAN:= FALSE;
     CVAR_MSPM07S1_CONFIG      MSAFI_MSFTS_PM07S_1.COD_EMPRESA%TYPE:= NULL;

  -- ******************************************************************
  -- **********
  -- *** 03. TIPO FISCAL ITEM
  -- *

  CURSOR CRS_MSPM07S2 (CRS_PAR_COMPANY_CODE    MSAFI_MSFTS_PM07S_2.COD_EMPRESA%TYPE,
                       CRS_PAR_TP_FISCAL_ITEM  MSAFI_MSFTS_PM07S_2.TP_FISCAL_ITEM%TYPE) IS

    SELECT TP_FISCAL_ITEM,
           COD_CLASS_DOC_FIS
    FROM MSAFI_MSFTS_PM07S_2
    WHERE CRS_PAR_COMPANY_CODE = COD_EMPRESA
      AND ((CRS_PAR_TP_FISCAL_ITEM IS NULL) OR (CRS_PAR_TP_FISCAL_ITEM = TP_FISCAL_ITEM));

    RECORD_MSPM07S2          CRS_MSPM07S2%ROWTYPE;
    BFOUND_ITENS07S2         BOOLEAN:= FALSE;
    BFOUND_MSPM07S2_COMPANY  BOOLEAN:= FALSE;
    BFOUND_MSPM07S2_TODOS    BOOLEAN:= FALSE;
    CVAR_MSPM07S2_CONFIG     MSAFI_MSFTS_PM07S_2.COD_EMPRESA%TYPE:= NULL;

  -- ******************************************************************
  -- **********
  -- *** 04. CODIGO DO CFOP DE SAIDA
  -- *

  CURSOR CRS_MSPM07S3 (CRS_PAR_COMPANY_CODE MSAFI_MSFTS_PM07S_3.COD_EMPRESA%TYPE,
                       CRS_PAR_COD_CFO      MSAFI_MSFTS_PM07S_3.COD_CFO%TYPE
                      ) IS

     SELECT COD_CFO,COD_CLASS_DOC_FIS
     FROM MSAFI_MSFTS_PM07S_3
     WHERE CRS_PAR_COMPANY_CODE = COD_EMPRESA
     AND ((CRS_PAR_COD_CFO IS NULL) OR (CRS_PAR_COD_CFO = COD_CFO));

    RECORD_MSPM07S3          CRS_MSPM07S3%ROWTYPE;
    BFOUND_ITENS07S3         BOOLEAN:= FALSE;
    BFOUND_MSPM07S3_COMPANY  BOOLEAN:= FALSE;
    BFOUND_MSPM07S3_TODOS    BOOLEAN:= FALSE;
    CVAR_MSPM07S3_CONFIG     MSAFI_MSFTS_PM07S_3.COD_EMPRESA%TYPE:= NULL;

  -- ******************************************************************
  -- **********
  -- *** 05. CODIGO DO CFOP DE ENTRADA
  -- *
  CURSOR CRS_MSPM07E3 (CRS_PAR_COMPANY_CODE MSAFI_MSFTS_PM07E_3.COD_EMPRESA%TYPE,
                       CRS_PAR_COD_CFO      MSAFI_MSFTS_PM07E_3.COD_CFO%TYPE
                      ) IS

     SELECT COD_CFO,
            COD_CLASS_DOC_FIS
     FROM MSAFI_MSFTS_PM07E_3
     WHERE ((COD_EMPRESA = CRS_PAR_COMPANY_CODE) OR (COD_EMPRESA = 'TODOS'))
     AND ((CRS_PAR_COD_CFO IS NULL) OR (CRS_PAR_COD_CFO = COD_CFO));

     RECORD_MSPM07E3      CRS_MSPM07E3%ROWTYPE;
     BFOUND_ITENS07E3     BOOLEAN:= FALSE;

  -- ******************************************************************
  -- **********
  -- *** 06. CURSOR PARA LEITURA DOS MOVIMENTOS DE SAIDA
  -- *

  CURSOR CRS_07_HEADER IS
    SELECT DISTINCT
        T.PST_ID
       , T.COD_EMPRESA
       , T.COD_ESTAB
       , T.ORG_ID
       , T.COD_DOCTO
       , T.TIPO
       , T.IND_FIS_JUR
       , T.COD_CLIENTE_SHIP
       , T.NUM_DOCFIS
       , T.SERIE
       , T.ORIGEM
       , T.MOVTO_E_S
       , T.DATA_EMISSAO
       , T.COD_CFO
       , T.DATA_EXPEDICAO
       , T.VLR_FRETE
       , T.VLR_SEGURO
       , T.VLR_OUTRAS
       , T.STATUS_NF
       , T.CUSTOMER_TRX_ID
       , T.ID_CTA_REC
       , T.INTERFACE_HEADER_ATTRIBUTE10
       , T.CUST_TRX_TYPE_ID
       , T.IND_FATURA
       , T.NUM_DOCFIS_PAI
       , T.SERIE_NF_PAI
       , T.ID_NOTA_PAI
       , T.TIPO_ESTAB
       , T.CIDADE
       , T.CEP
       , T.IND_CLASS_NFS
       , T.TIPO_NOTA
       , T.VLR_TOT_MERC
       , T.VLR_TOT_SERV
       , T.VLR_IMPOSTO_ICMS
       , T.ALIQUOTA_ICMS
       , T.VLR_BASE_ICMS
       , T.VLR_IMPOSTO_IPI
       , T.ALIQUOTA_IPI
       , T.VLR_BASE_IPI
       , T.VLR_IMPOSTO_IR
       , T.ALIQUOTA_IR
       , T.VLR_BASE_IR
       , T.VLR_IMPOSTO_ISS
       , T.ALIQUOTA_ISS
       , T.VLR_BASE_ISS
       , T.VLR_IMPOSTO_INSS
       , T.ALIQUOTA_INSS
       , T.VLR_BASE_INSS
       , T.VLR_IMPOSTO_ICMS_S
       , T.ALIQUOTA_ICMS_S
       , T.VLR_BASE_ICMS_S
       , T.COD_CONTA
       , T.SITUACAO
       , T.VLR_DESCONTO
       , T.IND_BASE1_ICMS
       , T.IND_BASE2_ICMS
       , T.IND_BASE1_IPI
       , T.IND_BASE2_IPI
       , T.NUM_AUTENTIC_NFE
       --002 inicio
       ,decode(T.NUM_AUTENTIC_NFE,null,'2','') IND_NFE_DENEG_INUT
       --002 fim
        --OS-00226 - INI
       , T.VLR_BASE_PIS
       , T.VLR_PIS
       , T.VLR_BASE_COFINS
       , T.VLR_COFINS
       , T.VLR_PIS_RETIDO
       , T.VLR_COFINS_RETIDO
       , T.DAT_FATO_GERADOR
       --OS-00226 - FIM
       , T.NUM_NFTS
       , T.SUB_SERIE_DOCFIS
       , T.IND_NF_VENDA_TERCEIROS
       , T.AUX01
       , T.AUX02
       , T.AUX03
       , T.AUX04
       , T.AUX05
       , T.AUX06
       , T.AUX07
       , T.AUX08
       , T.AUX09
       , T.AUX10
       , T.AUX11
       , T.AUX12
       , T.AUX13
       , T.AUX14
       , T.AUX15
       , T.AUX16
       , T.AUX17
       , T.AUX18
       , T.AUX19
       , T.AUX20
       , T.AUX21
       , T.AUX22
       , T.AUX23
       , T.AUX24
       , T.AUX25
       , T.AUX26
       , T.AUX27
       , T.AUX28
       , T.AUX29
       , T.AUX30
     FROM MSAFI_MSFSY_KED0057 T
         ,MSAFI_MSFTB_KEF0000 B
   WHERE
   /* FILTRA DADOS PELO ID FILTRO   */
        T.PST_ID         = PPST_ID_FILTRO
   /* POSICIONA REGISTROS DO FILTRO PELA CHAVE PST_ID/PST_ID_FILTRO */
   AND  B.PST_ID           = PPST_ID
   AND  B.PST_ID_FILTRO    = T.PST_ID
   AND MSAFI_MSFFN_KEF0000(T.NUM_DOCFIS                        ,B.PARAM01) = 1   /* NUM_DOCFIS   */
   AND MSAFI_MSFFN_KEF0000(TO_CHAR(T.DATA_EMISSAO,'DD/MM/YYYY'),B.PARAM02) = 1   /* DATA_EMISSAO */
   AND MSAFI_MSFFN_KEF0000(T.COD_CLIENTE_SHIP                  ,B.PARAM03) = 1;  /* COD_FIS_JUR  */

  -- VARIAVEIS DO CURSOR PRINCIPAL
   RECORD_07_HEADER        CRS_07_HEADER%ROWTYPE;
   BFOUND_07_HEADER        BOOLEAN := FALSE;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  --
  -- VARIAVEIS UTILIZADAS NA CONSTRUCAO DO PROCEDIMENTO DE GERACAO SAFX07
  --
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   RTAB_DEST               MSAFI_MSFTB_KPT0007%ROWTYPE;

   V_COD_ESTAB             MSAFI_MSFTB_KPT0007.COD_ESTAB%TYPE;

   V_DEVOLUCAO             BOOLEAN := TRUE;
   V_CUST_TRX_TYPE_ID      MSAFI_MSFSY_KED0057.CUST_TRX_TYPE_ID%TYPE;

   V_IND_SITUACAO_ESP      MSAFI_MSFTB_KPT0007.IND_SITUACAO_ESP%TYPE;
   V_IE                    MSAFI_MSFTB_KPT0007.INSC_ESTADUAL%TYPE;

   VAR_TIPO_ESTAB          MSAFI_MSFSY_KED0057.TIPO_ESTAB%TYPE;
   VAR_IND_CPVD            VARCHAR2(2);
   V_BASE_ICMS_ORIGDEST    MSAFI_MSFTB_KPT0007.BASE_ICMS_ORIGDEST%TYPE;
   V_VLR_ICMS_ORIGDEST     MSAFI_MSFTB_KPT0007.VLR_ICMS_ORIGDEST%TYPE;
   V_ALIQ_ICMS_ORIGDEST    MSAFI_MSFTB_KPT0007.ALIQ_ICMS_ORIGDEST%TYPE;
   V_IND_TRANSF_CRED       MSAFI_MSFTB_KPT0007.IND_TRANSF_CRED%TYPE := NULL;
   VAR_OBS_ICMS            MSAFI_MSFTB_KPT0007.OBS_ICMS%TYPE;

   V_NOME_CIDADE           MSAFI_MSFSY_KED0057.CIDADE%TYPE;
   V_NOME_CIDADE_MSAF      MSAFI_MSFSY_KED0057.CIDADE%TYPE;
   V_CEP                   MSAFI_MSFSY_KED0057.CEP%TYPE;
   V_CEP_MSAF              MSAFI_MSFSY_KED0057.CEP%TYPE;
   V_UF_ORIGEM             MSAFI_MSFTB_KPT0007.UF_ORIG_DEST%TYPE;
   V_COD_MUNIC_ORIGEM      MSAFI_MSFTB_KPT0007.COD_MUNICIPIO_ORIG%TYPE;
   V_COD_MUNIC_ORIGEM_MSAF MSAFI_MSFTB_KPT0007.COD_MUNICIPIO_ORIG%TYPE;
   V_UF_DESTINO            MSAFI_MSFTB_KPT0007.UF_DESTINO%TYPE;
   V_COD_MUNIC_DESTINO     MSAFI_MSFTB_KPT0007.COD_MUNICIPIO_DEST%TYPE;

   CVAR_ENTRADA_DADOS_AR      VARCHAR2(10):= NULL;

   -- TRATAMENTOS DE ERROS
   CVAR_ERRO_GLOBAL           LONG:= NULL;
   CVAR_SELECT_ERROR_CODE     NUMBER:= 0; -- VARIAVEL QUE IDENTIFICA O ERRO APOS A EXCEPTION
   CVAR_SELECT_ERROR_MESS     VARCHAR2(4000):= NULL; -- VARIAVEL QUE IDENTIFICA A MENSAGEM DE ERRO PERTENCENTE A EXCEPTION

   -- TRATA CANCELAMENTO (NOTAS CANCELADAS)
   BINSERT                    BOOLEAN := TRUE;
   VAR_NUM_CONTROLE_DOCTO     MSAFI_MSFTB_KPT0007.NUM_CONTROLE_DOCTO%TYPE;

  -- BEGIN 004
  VAR_VLR_ICMS_NDESTAC     MSAFI_MSFTB_KPT0008.VLR_ICMS_NDESTAC%TYPE    := NULL;
  VAR_VLR_IPI_NDESTAC      MSAFI_MSFTB_KPT0008.VLR_IPI_NDESTAC%TYPE     := NULL;
  -- END 004

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- PROCEDURE UTILIZADAS DENTRO DO PROCESSO DE GERAC?O DE CARGA DE DADOS
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  --
  -- 01. GRAVAC?O DOS DADOS

  PROCEDURE PRC_07_GRAVACAO (PRC_PAR_SYSTEM_ID1       IN NUMBER,
                             PRC_PAR_SYSTEM_ID2       IN NUMBER,
                             PRC_PAR_RECORDS_UPDATED  IN OUT NUMBER
                            ) IS

    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- LEITURA DOS ITENS DA NOTA FISCAL DE SAIDA / COM O CURSOR PRINCIPAL
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CURSOR CRS_07_LINES (PRC_PAR_ORG_ID           MSAFI_MSFSY_KED0057.ORG_ID%TYPE,
                         PRC_PAR_CUSTOMER_TRX_ID  MSAFI_MSFSY_KED0057.CUSTOMER_TRX_ID%TYPE
                        ) IS

       SELECT DISTINCT CUSTOMER_TRX_LINE_ID,
                       TP_FISCAL_ITEM,
                       ITE_COD_CFO,
                       VLR_INCLUI_IMPOSTO,
                       NVL(VALOR_ITEM      , 0) VALOR_ITEM,
                       NVL(PRECO_TOTAL     , 0) PRECO_TOTAL,
                       NVL(VALOR_TOTAL_ITEM, 0) VALOR_TOTAL_ITEM,
                       COD_SIT_TRIB_EST    , -- TRIBUTAC?O ICMS
                       COD_SIT_TRIB_FED    , -- TRIBUTAC?O IPI
                       ORGANIZATION_ID     ,
                       WAREHOUSE_CNPJ        -- ESTAB ESCRITURADOR
       FROM MSAFI_MSFSY_KED0057 TL
       WHERE TL.ORG_ID = PRC_PAR_ORG_ID
       AND   TL.CUSTOMER_TRX_ID = PRC_PAR_CUSTOMER_TRX_ID
       AND   TL.PST_ID          = PPST_ID;


    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- SITUAC?O TRIBUTARIA PARA ICMS / ANALISAR INCLUIR CURSOR PRINCIPAL
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    CURSOR CRS_MS_PM07S_4 (PRC_PAR_COMPANY_CODE  MSAFI_MSFTS_PM07S_4.COD_EMPRESA%TYPE,
                           PRC_PAR_TRIBUTA_ICMS  MSAFI_MSFTS_PM07S_4.TRIB_ICMS%TYPE
                          ) IS

       SELECT IND_BASE2,
              IND_BASE1
       FROM MSAFI_MSFTS_PM07S_4
       WHERE PRC_PAR_COMPANY_CODE = COD_EMPRESA
       AND PRC_PAR_TRIBUTA_ICMS = TRIB_ICMS;

    RECORD_MSPM07S4          CRS_MS_PM07S_4%ROWTYPE;
    BFOUND_MSPM07S4_COMPANY  BOOLEAN:= FALSE;
    BFOUND_MSPM07S4_TODOS    BOOLEAN:= FALSE;

    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- SITUAC?O TRIBUTARIA PARA IPI
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    CURSOR CRS_MS_PM07S_5 (PRC_PAR_COMPANY_CODE  MSAFI_MSFTS_PM07S_5.COD_EMPRESA%TYPE,
                           PRC_PAR_TRIBUTA_IPI   MSAFI_MSFTS_PM07S_5.TRIB_IPI%TYPE) IS

       SELECT IND_BASE2,
              IND_BASE1
       FROM MSAFI_MSFTS_PM07S_5
       WHERE PRC_PAR_COMPANY_CODE = COD_EMPRESA
       AND PRC_PAR_TRIBUTA_IPI = TRIB_IPI;

    RECORD_MSPM07S5          CRS_MS_PM07S_5%ROWTYPE;
    BFOUND_MSPM07S5_COMPANY  BOOLEAN:= FALSE;
    BFOUND_MSPM07S5_TODOS    BOOLEAN:= FALSE;

    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- VARIAVEIS UTILIZADAS NO PROCEDIMENTO
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    VAR_MOVTO_E_S              MSAFI_MSFTB_KPT0007.MOVTO_E_S%TYPE            := NULL  ;
    VAR_NORM_DEV               VARCHAR2(06)                                  := NULL  ;
    VAR_COD_CLASS_DOC_FIS      MSAFI_MSFTB_KPT0007.COD_CLASS_DOC_FIS%TYPE    := NULL  ;
    VAR_NUM_DOCFIS_REF         MSAFI_MSFTB_KPT0007.NUM_DOCFIS_REF%TYPE       := NULL  ;
    VAR_SERIE_DOCFIS_REF       MSAFI_MSFTB_KPT0007.SERIE_DOCFIS_REF%TYPE     := NULL  ;

    VAR_VLR_PRODUTO            MSAFI_MSFTB_KPT0007.VLR_PRODUTO%TYPE          := NULL  ;
    VAR_VLR_TOT_NOTA           MSAFI_MSFTB_KPT0007.VLR_TOT_NOTA%TYPE         := NULL  ;
    VAR_CONTRIB_FINAL          MSAFI_MSFTB_KPT0007.CONTRIB_FINAL%TYPE        := NULL  ;
    VAR_SITUACAO               MSAFI_MSFTB_KPT0007.SITUACAO%TYPE             := NULL  ;

    VAR_COD_CONTA              MSAFI_MSFTB_KPT0007.COD_CONTA%TYPE            := NULL  ;
    VAR_VLR_CONTAB_COMPL       MSAFI_MSFTB_KPT0007.VLR_CONTAB_COMPL%TYPE     := NULL  ;
    VAR_VLR_DESCONTO           NUMBER                                        := 0     ;
    VAR_GRAVA_DADOS_07S        BOOLEAN                                       := TRUE  ;

    --
    -- VARIAVEIS PARA CONTROLE DO CAMPO COD_CLASS_DOC_FIS
    --
    VAR_CLASS_DOC_FIS_TYPE          MSAFI_MSFTS_PM07S_2.COD_CLASS_DOC_FIS%TYPE:= NULL;
    VAR_CLASS_DOC_FIS_TYPE_MERC     BOOLEAN:= FALSE;
    VAR_CLASS_DOC_FIS_TYPE_SERV     BOOLEAN:= FALSE;

    --
    -- VARIAVEIS PARA CONTROLE DO CAMPO CONTRIB_FINAL
    --
    VAR_VLR_INCLUI_IMPOSTO        BOOLEAN:= FALSE;

    --
    -- VARIAVEIS PARA SOMATORIA DO VALOR TOTAL PRODUTO E TOTAL DA NOTA
    --
    VAR_TPRODUTO_CLASS_DOC_MERC   NUMBER:=0; -- VARIAVEL AUXILIAR PARA TOTALIZAR SOMENTE O VALOR DO PRODUTO PARA CLASSIFICAC?O FISCAL TIPO 1 ( MERCADORIAS )
    VAR_TPRODUTO_CLASS_DOC        NUMBER:=0; -- VARIAVEL AUXILIAR PARA TOTALIZAR SOMENTE O VALOR DO PRODUTO ( GERAL )
    VAR_TNOTAFIS_CLASS_DOC_MERC   NUMBER:=0; -- VARIAVEL AUXILIAR PARA TOTALIZAR SOMENTE O VALOR TOTAL DA NOTA PARA CLASSIFICAC?O FISCAL TIPO 1 ( MERCADORIAS )
    VAR_TNOTAFIS_CLASS_DOC        NUMBER:=0; -- VARIAVEL AUXILIAR PARA TOTALIZAR SOMENTE O VALOR TOTAL ( GERAL )
    VAR_TPRODUTO_CLASS_DOC_SERV   NUMBER:=0; -- VARIAVEL AUXILIAR PARA TOTALIZAR SOMENTE O VALOR DO PRODUTO PARA CLASSIFICAC?O FISCAL TIPO 2 ( SERVICOS )

    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- VARIAVEIS UTILIZADAS PARA CALCULO DO CAMPO VLR_ICMS
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VAR_VLR_ICMS                  MSAFI_MSFTB_KPT0007.VLR_ICMS%TYPE:= NULL; -- OK
    VAR_ITEM_VLR_ICMS             NUMBER:= 0; -- VALOR DO IMPOSTO
    VAR_ITEM_VLR_ALIQ_ICMS        NUMBER:= 0; -- ALIQUOTA DE IMPOSTO
    VAR_ITEM_BASE_ICMS            NUMBER:= 0; -- BASE

    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- VARIAVEIS UTILIZADAS PARA CALCULO DO CAMPO VLR_IPI
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VAR_VLR_IPI                   MSAFI_MSFTB_KPT0007.VLR_IPI%TYPE:= NULL;
    VAR_ITEM_VLR_IPI              NUMBER:= 0; -- VALOR DO IMPOSTO
    VAR_ITEM_VLR_ALIQ_IPI         NUMBER:= 0; -- ALIQUOTA DE IMPOSTO
    VAR_ITEM_BASE_IPI             NUMBER:= 0; -- BASE

    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- VARIAVEIS UTILIZADAS PARA CALCULO DO CAMPO VLR_IR
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VAR_VLR_IR                    MSAFI_MSFTB_KPT0007.VLR_IR%TYPE:= NULL;
    VAR_ITEM_VLR_IR               NUMBER:= 0; -- VALOR DO IMPOSTO
    VAR_ITEM_VLR_ALIQ_IR          NUMBER:= 0; -- ALIQUOTA DE IMPOSTO
    VAR_ITEM_BASE_IR              NUMBER:= 0; -- BASE

    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- VARIAVEIS UTILIZADAS PARA CALCULO DO CAMPO VLR_INSS
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VAR_VLR_INSS                  MSAFI_MSFTB_KPT0007.VLR_INSS_RETIDO%TYPE:= NULL;
    VAR_ITEM_VLR_INSS             NUMBER:= 0; -- VALOR DO IMPOSTO
    VAR_ITEM_VLR_ALIQ_INSS        NUMBER:= 0; -- ALIQUOTA DE IMPOSTO
    VAR_ITEM_BASE_INSS            NUMBER:= 0; -- BASE

    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- VARIAVEIS UTILIZADAS PARA CALCULO DO CAMPO VLR_ISS
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VAR_VLR_ISS                   MSAFI_MSFTB_KPT0007.VLR_ISS%TYPE:= NULL;
    VAR_ITEM_VLR_ISS              NUMBER:= 0; -- VALOR DO IMPOSTO
    VAR_ITEM_VLR_ALIQ_ISS         NUMBER:= 0; -- ALIQUOTA DE IMPOSTO
    VAR_ITEM_BASE_ISS             NUMBER:= 0; -- BASE

    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- VARIAVEIS UTILIZADAS PARA CALCULO DO CAMPO VLR_SUBST_ICMS
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VAR_SUBST_ICMS                MSAFI_MSFTB_KPT0007.VLR_SUBST_ICMS%TYPE:= NULL;
    VAR_VLR_ALIQ_SUB_ICMS         NUMBER:= 0;
    VAR_ITEM_VLR_SICMS            NUMBER:= 0; -- VALOR DO IMPOSTO
    VAR_ITEM_VLR_ALIQ_SICMS       NUMBER:= 0; -- ALIQUOTA DE IMPOSTO
    VAR_ITEM_BASE_SICMS           NUMBER:= 0; -- BASE

    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- VARIAVEIS UTILIZADAS PARA CALCULO DOS CAMPOS BASE_TRIB_ICMS,
    -- BASE_ISEN_ICMS, BASE_OUTR_ICMS, BASE_REDU_ICMS
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VAR_BASE_TRIB_ICMS            MSAFI_MSFTB_KPT0007.BASE_TRIB_ICMS%TYPE:= NULL;
    VAR_BASE_ISEN_ICMS            MSAFI_MSFTB_KPT0007.BASE_ISEN_ICMS%TYPE:= NULL;
    VAR_BASE_OUTR_ICMS            MSAFI_MSFTB_KPT0007.BASE_OUTR_ICMS%TYPE:= NULL;
    VAR_BASE_REDU_ICMS            MSAFI_MSFTB_KPT0007.BASE_REDU_ICMS%TYPE:= NULL;

    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- VARIAVEIS UTILIZADAS PARA CALCULO DOS CAMPOS BASE_TRIB_IPI,
    -- BASE_ISEN_IPI, BASE_OUTR_IPI, BASE_REDU_IPI
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VAR_BASE_TRIB_IPI             MSAFI_MSFTB_KPT0007.BASE_TRIB_IPI%TYPE:= NULL;
    VAR_BASE_ISEN_IPI             MSAFI_MSFTB_KPT0007.BASE_ISEN_IPI%TYPE:= NULL;
    VAR_BASE_OUTR_IPI             MSAFI_MSFTB_KPT0007.BASE_OUTR_IPI%TYPE:= NULL;
    VAR_BASE_REDU_IPI             MSAFI_MSFTB_KPT0007.BASE_REDU_IPI%TYPE:= NULL;

    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- VARIAVEIS UTILIZADAS PARA CALCULO DOS CAMPOS BASE_TRIB_IR
    -- BASE_ISEN_IR
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VAR_BASE_TRIB_IR              MSAFI_MSFTB_KPT0007.BASE_TRIB_IR%TYPE:= NULL;
    VAR_BASE_ISEN_IR              MSAFI_MSFTB_KPT0007.BASE_ISEN_IR%TYPE:= NULL;

    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- VARIAVEIS UTILIZADAS PARA CALCULO DOS CAMPOS BASE_TRIB_ISS
    -- BASE_ISEN_ISS
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VAR_BASE_TRIB_ISS             MSAFI_MSFTB_KPT0007.BASE_TRIB_ISS%TYPE:= NULL;
    VAR_BASE_ISEN_ISS             MSAFI_MSFTB_KPT0007.BASE_ISEN_ISS%TYPE:= NULL;

    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- VARIAVEIS UTILIZADAS PARA CALCULO DOS CAMPOS BASE_SUB_TRIB_ICMS
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VAR_BASE_SUB_TRIB_ICMS        MSAFI_MSFTB_KPT0007.BASE_SUB_TRIB_ICMS%TYPE:= NULL;

    VAR_ITE_COD_CFO               MSAFI_MSFTB_KPT0007.COD_CFO%TYPE:= NULL;

  -- BEGIN PRC_GRAVA_DADOS
  BEGIN

    MSAFI_MSFSY_PCK_PROG.V_GLOBAL_PST_ID := PPST_ID;

    FOR DADOS IN CRS_07_HEADER LOOP
       -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
       -- LIMPANDO AS VARIAVEIS UTILIZADAS DURANTE O PROCESSAMENTO
       -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

       VAR_GRAVA_DADOS_07S   := TRUE;
       VAR_VLR_INCLUI_IMPOSTO:= FALSE;

       VAR_TPRODUTO_CLASS_DOC      := 0;
       VAR_TNOTAFIS_CLASS_DOC      := 0;
       VAR_TPRODUTO_CLASS_DOC_MERC := 0;
       VAR_TNOTAFIS_CLASS_DOC_MERC := 0;
       VAR_TPRODUTO_CLASS_DOC_SERV := 0;

       VAR_VLR_ICMS     := 0;
       VAR_VLR_IPI      := 0;
       VAR_VLR_IR       := 0;
       VAR_VLR_ISS      := 0;
       VAR_SUBST_ICMS   := 0;

       VAR_BASE_TRIB_ICMS := 0;
       VAR_BASE_ISEN_ICMS := 0;
       VAR_BASE_OUTR_ICMS := 0;
       VAR_BASE_REDU_ICMS := 0;

       VAR_BASE_TRIB_IPI  := 0;
       VAR_BASE_ISEN_IPI  := 0;
       VAR_BASE_OUTR_IPI  := 0;
       VAR_BASE_REDU_IPI  := 0;
       VAR_BASE_TRIB_IR   := 0;
       VAR_BASE_ISEN_IR   := 0;
       VAR_BASE_TRIB_ISS  := 0;
       VAR_BASE_ISEN_ISS  := 0;
       VAR_BASE_SUB_TRIB_ICMS := 0;

       VAR_CLASS_DOC_FIS_TYPE_MERC:= FALSE;
       VAR_CLASS_DOC_FIS_TYPE_SERV:= FALSE;

       VAR_ITE_COD_CFO := 0;

       -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
       -- ELABORANDO A LEITURA DOS ITENS DA NOTA FISCAL DE SAIDA
       -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
       V_DEVOLUCAO := TRUE;
       V_CUST_TRX_TYPE_ID := DADOS.CUST_TRX_TYPE_ID;

       -- VERIFICANDO SE E NOTA DE DEVOLUCAO
       IF V_CUST_TRX_TYPE_ID IS NULL THEN
          V_DEVOLUCAO := FALSE;
       ELSE
          V_DEVOLUCAO := TRUE;
       END IF;

       IF NOT V_DEVOLUCAO THEN -- CONTINUA O PROCESSAMENTO E GRAVA NA TB
          FOR LINES IN CRS_07_LINES(DADOS.ORG_ID, DADOS.CUSTOMER_TRX_ID) LOOP
             -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             -- 01. VERIFICANDO A CLASSIFICAC?O FISCAL DOS ITENS
             --     PERTENCENTES A NOTA FISCAL
             -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

             VAR_CLASS_DOC_FIS_TYPE := NULL;

             IF (DADOS.IND_CLASS_NFS = 1) THEN
                -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                -- CLASSIFICAC?O FISCAL DO ITEM CONFIGURADA POR
                -- TIPO FISCAL DO ITEM
                -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                IF ( RTRIM( LTRIM( LINES.TP_FISCAL_ITEM ) ) IS NULL ) THEN

                   -- ESTE CAMPO N?O PODE SER NULO
                   VAR_CLASS_DOC_FIS_TYPE := NULL ;
                   MSAFI_MSFSY_GENERATE_LOG.PRC_LOG_MSG(1, 'NUM_DOCFIS: ' || DADOS.NUM_DOCFIS || ' SEM VALOR DE TIPO FISCAL');
                ELSE
                   VAR_ITE_COD_CFO := LINES.ITE_COD_CFO;
                   VAR_CLASS_DOC_FIS_TYPE := DADOS.TIPO_NOTA;

                   IF ((VAR_CLASS_DOC_FIS_TYPE IS NULL) OR (VAR_CLASS_DOC_FIS_TYPE NOT IN ('1', '2', '3'))) THEN
                      VAR_GRAVA_DADOS_07S := FALSE;
                      MSAFI_MSFSY_GENERATE_LOG.PRC_LOG_MSG(1, 'ANALISAR PARAMETRIZACAO TIPO DE ITEM POR TIPO FISCAL. TIPO FISCAL: ' || LINES.TP_FISCAL_ITEM || ' SEM PARAMETRIZACAO');
                   END IF;

                END IF;
             ELSE
                -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                -- CLASSIFICAC?O FISCAL DO ITEM CONFIGURADA POR
                -- CFOP
                -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                IF (RTRIM(LTRIM(LINES.ITE_COD_CFO)) IS NULL) THEN
                   -- ESTE CAMPO N?O PODE SER NULO, PORTANTO DEVERA
                   -- GRAVAR NULO NO MESMO, PARA QUE SEJA PEGO NO MASTERSAF
                   VAR_CLASS_DOC_FIS_TYPE := NULL;
                   MSAFI_MSFSY_GENERATE_LOG.PRC_LOG_MSG(1, 'NUM_DOCFIS: ' || DADOS.NUM_DOCFIS || ' SEM VALOR DE CFOP');
                ELSE
                   VAR_ITE_COD_CFO := LINES.ITE_COD_CFO;
                   VAR_CLASS_DOC_FIS_TYPE := DADOS.TIPO_NOTA;

                   IF ((VAR_CLASS_DOC_FIS_TYPE IS NULL) OR (VAR_CLASS_DOC_FIS_TYPE NOT IN ('1', '2', '3'))) THEN
                      VAR_GRAVA_DADOS_07S := FALSE;
                      MSAFI_MSFSY_GENERATE_LOG.PRC_LOG_MSG(1, 'ANALISAR PARAMETRIZACAO TIPO DE ITEM POR CFOP. CFOP: ' || LINES.ITE_COD_CFO || ' SEM PARAMETRIZACAO');

                      IF RECORD_MSPM07E1.IND_NFE_AR = 'S' THEN
                         OPEN CRS_MSPM07E3(DADOS.COD_EMPRESA, LINES.ITE_COD_CFO);
                         FETCH CRS_MSPM07E3 INTO RECORD_MSPM07E3;
                         BFOUND_ITENS07E3 := CRS_MSPM07E3%FOUND;
                         CLOSE CRS_MSPM07E3;

                         IF (NOT(BFOUND_ITENS07E3)) THEN
                            VAR_GRAVA_DADOS_07S := FALSE;
                         ELSE
                            VAR_CLASS_DOC_FIS_TYPE := RECORD_MSPM07E3.COD_CLASS_DOC_FIS;
                         END IF;
                      END IF;
                   ELSE
                      VAR_CLASS_DOC_FIS_TYPE := DADOS.TIPO_NOTA;
                   END IF;
                END IF;
            END IF;
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- SE HOUVER PROBLEMAS DE PARAMETRIZAC?O A NOTA FISCAL
            -- DEVE SER IGNORADA E DEVE-SE PARAR A LEITURA DOS ITENS
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            IF (NOT(VAR_GRAVA_DADOS_07S)) THEN
               EXIT;
            ELSE
               IF (VAR_CLASS_DOC_FIS_TYPE = '1') THEN
                  VAR_CLASS_DOC_FIS_TYPE_MERC := TRUE ;
                     -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                     -- ACUMULANDO OS TOTAIS PRODUTO E NOTA
                     -- SOMENTE PARA MERCADORIAS
                     -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                     VAR_TPRODUTO_CLASS_DOC_MERC := VAR_TPRODUTO_CLASS_DOC_MERC + TRUNC(NVL(LINES.VALOR_ITEM, 0), 2);
                     VAR_TNOTAFIS_CLASS_DOC_MERC := VAR_TNOTAFIS_CLASS_DOC_MERC + TRUNC(NVL(LINES.VALOR_TOTAL_ITEM, 0), 2);

               ELSIF (VAR_CLASS_DOC_FIS_TYPE = '2') THEN
                     VAR_CLASS_DOC_FIS_TYPE_SERV := TRUE ;
                     --OS-00126 - INI
                     VAR_TPRODUTO_CLASS_DOC_MERC :=0;
                     --OS-00126 - FIM
                     VAR_TPRODUTO_CLASS_DOC_SERV := VAR_TPRODUTO_CLASS_DOC_SERV + TRUNC(NVL(LINES.VALOR_ITEM, 0), 2);

               ELSIF (VAR_CLASS_DOC_FIS_TYPE = '3') THEN
                     VAR_CLASS_DOC_FIS_TYPE_SERV := TRUE ;
                     --OS-00126 - INI
                     VAR_TPRODUTO_CLASS_DOC_MERC := VAR_TPRODUTO_CLASS_DOC_MERC + TRUNC(NVL(LINES.VALOR_ITEM, 0), 2);
                     --OS-00126 - FIM
                     VAR_TPRODUTO_CLASS_DOC_SERV := VAR_TPRODUTO_CLASS_DOC_SERV + TRUNC(NVL(LINES.VALOR_ITEM, 0), 2);
               END IF;
            END IF;
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- 02. VERIFICANDO O CONTEUDO DO CAMPO VLR_INCLUI_IMPOSTO
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            IF (LINES.VLR_INCLUI_IMPOSTO = 'S') THEN
               VAR_VLR_INCLUI_IMPOSTO := TRUE;
            END IF;

            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- ACUMULANDO OS TOTAIS PRODUTO E NOTA ( GERAL )
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            VAR_TPRODUTO_CLASS_DOC := VAR_TPRODUTO_CLASS_DOC + TRUNC(NVL(LINES.VALOR_ITEM, 0), 2);
            VAR_TNOTAFIS_CLASS_DOC := VAR_TNOTAFIS_CLASS_DOC + TRUNC(NVL(LINES.VALOR_TOTAL_ITEM, 0), 2);

            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- CALCULANDO O VALOR DO ICMS
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            CVAR_ERRO_GLOBAL := NULL ;
            CVAR_ERRO_GLOBAL := '07S-001 : '
                                ||
                                'DOCTO : '
                                ||
                                DADOS.NUM_DOCFIS
                                ||
                                ' - '
                                ||
                                'CALCULO DE IMPOSTOS ( ICMS ) : '
                                ||
                                ' VALOR............: '
                                ||
                                TO_CHAR( VAR_ITEM_VLR_ICMS )
                                ||
                                ' VALOR ALIQUOTA..: '
                                ||
                                TO_CHAR( VAR_ITEM_VLR_ALIQ_ICMS )
                                ||
                                ' BASE............: '
                                ||
                                TO_CHAR( VAR_ITEM_BASE_ICMS ) ;


            VAR_ITEM_VLR_ICMS        := DADOS.VLR_IMPOSTO_ICMS;   -- VALOR DO IMPOSTO
            VAR_ITEM_VLR_ALIQ_ICMS   := DADOS.ALIQUOTA_ICMS;      -- ALIQUOTA DE IMPOSTO
            VAR_ITEM_BASE_ICMS       := DADOS.VLR_BASE_ICMS;      -- BASE


            VAR_VLR_ICMS := VAR_VLR_ICMS + TRUNC( NVL( VAR_ITEM_VLR_ICMS, 0 ), 2 ) ; -- VALOR ICMS NOTA

            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- CALCULANDO O VALOR DO IPI
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            CVAR_ERRO_GLOBAL := NULL ;
            CVAR_ERRO_GLOBAL := '07S-002 : '
                                ||
                                'DOCTO : '
                                ||
                                DADOS.NUM_DOCFIS
                                ||
                                ' - '
                                ||
                                'CALCULO DE IMPOSTOS ( IPI ) : '
                                ||
                                ' VALOR............: '
                                ||
                                TO_CHAR( VAR_ITEM_VLR_IPI )
                                ||
                                ' VALOR ALIQUOTA..: '
                                ||
                                TO_CHAR( VAR_ITEM_VLR_ALIQ_IPI )
                                ||
                                ' BASE............: '
                                ||
                                TO_CHAR( VAR_ITEM_BASE_IPI ) ;

            VAR_ITEM_VLR_IPI       := DADOS.VLR_IMPOSTO_IPI;     -- VALOR DO IMPOSTO
            VAR_ITEM_VLR_ALIQ_IPI  := DADOS.ALIQUOTA_IPI;        -- ALIQUOTA DE IMPOSTO
            VAR_ITEM_BASE_IPI      := DADOS.VLR_BASE_IPI;        -- BASE

            VAR_VLR_IPI := VAR_VLR_IPI + TRUNC( NVL( VAR_ITEM_VLR_IPI, 0 ), 2 ) ; -- VALOR IPI NOTA

            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- CALCULANDO O VALOR DO IR
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            CVAR_ERRO_GLOBAL := NULL ;
            CVAR_ERRO_GLOBAL := '07S-003 : '
                                ||
                                'DOCTO : '
                                ||
                                DADOS.NUM_DOCFIS
                                ||
                                ' - '
                                ||
                                'CALCULO DE IMPOSTOS ( IR ) : '
                                ||
                                ' VALOR............: '
                                ||
                                TO_CHAR( VAR_ITEM_VLR_IR )
                                ||
                                ' VALOR ALIQUOTA..: '
                                ||
                                TO_CHAR( VAR_ITEM_VLR_ALIQ_IR )
                                ||
                                ' BASE............: '
                                ||
                                TO_CHAR( VAR_ITEM_BASE_IR ) ;

            VAR_ITEM_VLR_IR        := DADOS.VLR_IMPOSTO_IR;     -- VALOR DO IMPOSTO
            VAR_ITEM_VLR_ALIQ_IR   := DADOS.ALIQUOTA_IR;        -- ALIQUOTA DE IMPOSTO
            VAR_ITEM_BASE_IR       := DADOS.VLR_BASE_IR;        -- BASE

            VAR_VLR_IR  := VAR_VLR_IR + TRUNC( NVL( VAR_ITEM_VLR_IR, 0 ), 2 );  -- VALOR IR NOTA

            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- CALCULANDO O VALOR DO INSS
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            CVAR_ERRO_GLOBAL := NULL ;
            CVAR_ERRO_GLOBAL := '07S-003 : '
                                ||
                                'DOCTO : '
                                ||
                                DADOS.NUM_DOCFIS
                                ||
                                ' - '
                                ||
                                'CALCULO DE IMPOSTOS ( INSS ) : '
                                ||
                                ' VALOR............: '
                                ||
                                TO_CHAR( VAR_ITEM_VLR_INSS )
                                ||
                                ' VALOR ALIQUOTA..: '
                                ||
                                TO_CHAR( VAR_ITEM_VLR_ALIQ_INSS )
                                ||
                                ' BASE............: '
                                ||
                                TO_CHAR( VAR_ITEM_BASE_INSS ) ;

            VAR_ITEM_VLR_INSS        := DADOS.VLR_IMPOSTO_INSS;     -- VALOR DO IMPOSTO
            VAR_ITEM_VLR_ALIQ_INSS   := DADOS.ALIQUOTA_INSS;        -- ALIQUOTA DE IMPOSTO
            VAR_ITEM_BASE_INSS       := DADOS.VLR_BASE_INSS;        -- BASE

             VAR_VLR_INSS  := VAR_VLR_INSS + TRUNC(NVL(VAR_ITEM_VLR_INSS, 0), 2);  -- VALOR INSS NOTA

            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- CALCULANDO O VALOR DO ISS
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            CVAR_ERRO_GLOBAL := NULL ;
            CVAR_ERRO_GLOBAL := '07S-004 : '
                                ||
                                'DOCTO : '
                                ||
                                DADOS.NUM_DOCFIS
                                ||
                                ' - '
                                ||
                                'CALCULO DE IMPOSTOS ( ISS ) : '
                                ||
                                ' VALOR............: '
                                ||
                                TO_CHAR( VAR_ITEM_VLR_ISS )
                                ||
                                ' VALOR ALIQUOTA..: '
                                ||
                                TO_CHAR( VAR_ITEM_VLR_ALIQ_ISS )
                                ||
                                ' BASE............: '
                                ||
                                TO_CHAR( VAR_ITEM_BASE_ISS ) ;

            VAR_ITEM_VLR_ISS        := DADOS.VLR_IMPOSTO_ISS;     -- VALOR DO IMPOSTO
            VAR_ITEM_VLR_ALIQ_ISS   := DADOS.ALIQUOTA_ISS;        -- ALIQUOTA DE IMPOSTO
            VAR_ITEM_BASE_ISS       := DADOS.VLR_BASE_ISS;        -- BASE

             VAR_VLR_ISS := VAR_VLR_ISS + TRUNC( NVL( VAR_ITEM_VLR_ISS, 0 ), 2 );  -- VALOR ISS NOTA

            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- CALCULANDO O VALOR DE SUBSTITUIC?O DO ICMS
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            CVAR_ERRO_GLOBAL := NULL ;
            CVAR_ERRO_GLOBAL := '07S-005 : '
                                ||
                                'DOCTO : '
                                ||
                                DADOS.NUM_DOCFIS
                                ||
                                ' - '
                                ||
                                'CALCULO DE IMPOSTOS ( ICMS-S ) : '
                                ||
                                ' VALOR............: '
                                ||
                                TO_CHAR( VAR_ITEM_VLR_SICMS )
                                ||
                                ' VALOR ALIQUOTA..: '
                                ||
                                TO_CHAR( VAR_ITEM_VLR_ALIQ_SICMS )
                                ||
                                ' BASE............: '
                                ||
                                TO_CHAR( VAR_ITEM_BASE_SICMS ) ;

            VAR_ITEM_VLR_SICMS        := DADOS.VLR_IMPOSTO_ICMS_S;   -- VALOR DO IMPOSTO
            VAR_ITEM_VLR_ALIQ_SICMS   := DADOS.ALIQUOTA_ICMS_S;      -- ALIQUOTA DE IMPOSTO
            VAR_ITEM_BASE_SICMS       := DADOS.VLR_BASE_ICMS_S;      -- BASE

            VAR_SUBST_ICMS := VAR_SUBST_ICMS + TRUNC( NVL( VAR_ITEM_VLR_SICMS, 0 ), 2 ); --VALOR ICMS_S NOTA

            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- EFETUANDO O CALCULO DAS BASES ATRAVES DA SITUAC?O TRIBUTARIA
            -- DE CADA ITEM ( ICMS )
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            IF (DADOS.IND_BASE1_ICMS IS NOT NULL) THEN
                 -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                 -- AVERIGUANDO A BASE 1
                 -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                 IF    ( DADOS.IND_BASE1_ICMS = '1' ) THEN
                         VAR_BASE_TRIB_ICMS := VAR_BASE_TRIB_ICMS + TRUNC( NVL( VAR_ITEM_BASE_ICMS, 0 ), 2 );
                 ELSIF ( DADOS.IND_BASE1_ICMS = '2' ) THEN
                         VAR_BASE_ISEN_ICMS := VAR_BASE_ISEN_ICMS + TRUNC( NVL( VAR_ITEM_BASE_ICMS, 0 ), 2 );
                 ELSIF ( DADOS.IND_BASE1_ICMS = '3' ) THEN
                         VAR_BASE_OUTR_ICMS := VAR_BASE_OUTR_ICMS + TRUNC( NVL( VAR_ITEM_BASE_ICMS, 0 ), 2 );
                 ELSIF ( DADOS.IND_BASE1_ICMS = '4' ) THEN
                         VAR_BASE_REDU_ICMS := VAR_BASE_REDU_ICMS + TRUNC( NVL( VAR_ITEM_BASE_ICMS, 0 ), 2 );
                 END IF ;
                 -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                 -- AVERIGUANDO A BASE 2 PARA ICMS
                 -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                 IF ( NVL( VAR_ITEM_BASE_ICMS, 0 ) > 0 ) THEN
                      IF ( ( NVL( LINES.VALOR_ITEM, 0 ) - NVL( VAR_ITEM_BASE_ICMS, 0 ) ) > 0 ) THEN
                             IF    ( DADOS.IND_BASE2_ICMS = '1' ) THEN
                                     VAR_BASE_TRIB_ICMS := VAR_BASE_TRIB_ICMS + TRUNC ((NVL( LINES.VALOR_ITEM, 0 ) - NVL( VAR_ITEM_BASE_ICMS, 0 )),2);
                             ELSIF ( DADOS.IND_BASE2_ICMS = '2' ) THEN
                                     VAR_BASE_ISEN_ICMS := VAR_BASE_ISEN_ICMS + TRUNC ((NVL( LINES.VALOR_ITEM, 0 ) - NVL( VAR_ITEM_BASE_ICMS, 0 )),2);
                             ELSIF ( DADOS.IND_BASE2_ICMS = '3' ) THEN
                                     VAR_BASE_OUTR_ICMS := VAR_BASE_OUTR_ICMS + TRUNC ((NVL( LINES.VALOR_ITEM, 0 ) - NVL( VAR_ITEM_BASE_ICMS, 0 )),2);
                             ELSIF ( DADOS.IND_BASE2_ICMS = '4' ) THEN
                                     VAR_BASE_REDU_ICMS := VAR_BASE_REDU_ICMS + TRUNC ((NVL( LINES.VALOR_ITEM, 0 ) - NVL( VAR_ITEM_BASE_ICMS, 0 )),2);
                             END IF ; -- ( ICMS ) VERIFICAC?O DO TIPO DE BASE CONFORME SITUAC?O TRIBUTARIA
                      END IF ; -- ( ICMS ) VERIFICAC?O DA BASE 2
                 END IF ; -- ( ICMS ) VERIFICANDO SE A BASE E MAIOR QUE ZEROS
            ELSE
               MSAFI_MSFSY_GENERATE_LOG.PRC_LOG_MSG(1, 'ANALISAR PARAMETRIZACAO DE TRIBUTACAO DE ICMS PARA SAIDAS. TRIB ICMS: ' || LINES.COD_SIT_TRIB_EST || ' NAO PARAMETRIZADO.');
            END IF ; -- ( ICMS ) VERIFICAC?O DA EXISTENCIA DE PARAMETRIZAC?O
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- EFETUANDO O CALCULO DAS BASES ATRAVES DA SITUAC?O TRIBUTARIA
            -- DE CADA ITEM ( IPI )
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            IF ( DADOS.IND_BASE1_IPI IS NOT NULL ) THEN
                 -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                 -- AVERIGUANDO A BASE 1 ( IPI )
                 -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                 -- EAM 001
                 /*IF NVL(VAR_ITEM_BASE_IPI,0) = 0 THEN
                   VAR_ITEM_BASE_IPI := VAR_TPRODUTO_CLASS_DOC;
                 END IF;*/
                 -- EAM 001
                 IF    ( DADOS.IND_BASE1_IPI = '1' ) THEN
                         VAR_BASE_TRIB_IPI  := VAR_BASE_TRIB_IPI  + TRUNC( NVL( VAR_ITEM_BASE_IPI, 0 ) , 2 );
                 ELSIF ( DADOS.IND_BASE1_IPI = '2' ) THEN
                         VAR_BASE_ISEN_IPI  := VAR_BASE_ISEN_IPI  + TRUNC( NVL( VAR_ITEM_BASE_IPI, 0 ) , 2 );
                 ELSIF ( DADOS.IND_BASE1_IPI = '3' ) THEN
                         VAR_BASE_OUTR_IPI  := VAR_BASE_OUTR_IPI  + TRUNC( NVL( VAR_ITEM_BASE_IPI, 0 ) , 2 );
                 ELSIF ( DADOS.IND_BASE1_IPI = '4' ) THEN
                         VAR_BASE_REDU_IPI  := VAR_BASE_REDU_IPI  + TRUNC( NVL( VAR_ITEM_BASE_IPI, 0 ) , 2 );
                 END IF ;
                 -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                 -- AVERIGUANDO A BASE 2 PARA IPI
                 -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                IF ( NVL( VAR_ITEM_BASE_IPI, 0 )  > 0 ) THEN
                      IF ( ( NVL( LINES.VALOR_ITEM, 0 ) - NVL( VAR_ITEM_BASE_IPI, 0 ) ) > 0 ) THEN
                             IF    ( DADOS.IND_BASE2_IPI = '1' ) THEN
                                     VAR_BASE_TRIB_IPI  := VAR_BASE_TRIB_IPI + TRUNC((NVL( LINES.VALOR_ITEM, 0 ) - NVL( VAR_ITEM_BASE_IPI, 0 )),2);
                             ELSIF ( DADOS.IND_BASE2_IPI = '2' ) THEN
                                     VAR_BASE_ISEN_IPI  := VAR_BASE_ISEN_IPI + TRUNC((NVL( LINES.VALOR_ITEM, 0 ) - NVL( VAR_ITEM_BASE_IPI, 0 )),2);
                             ELSIF ( DADOS.IND_BASE2_IPI = '3' ) THEN
                                     VAR_BASE_OUTR_IPI  := VAR_BASE_OUTR_IPI + TRUNC((NVL( LINES.VALOR_ITEM, 0 ) - NVL( VAR_ITEM_BASE_IPI, 0 )),2);
                             ELSIF ( DADOS.IND_BASE2_IPI = '4' ) THEN
                                     VAR_BASE_REDU_IPI  := VAR_BASE_REDU_IPI + TRUNC((NVL( LINES.VALOR_ITEM, 0 ) - NVL( VAR_ITEM_BASE_IPI, 0 )),2);
                             END IF ; -- ( IPI ) VERIFICAC?O DO TIPO DE BASE CONFORME SITUAC?O TRIBUTARIA
                      END IF ; -- ( IPI ) VERIFICAC?O DA BASE 2
                 END IF ; -- ( IPI ) VERIFICANDO SE A BASE E MAIOR QUE ZEROS
            ELSE
               MSAFI_MSFSY_GENERATE_LOG.PRC_LOG_MSG(1, 'ANALISAR PARAMETRIZACAO DE TRIBUTACAO DE IPI PARA SAIDAS. TRIB IPI: ' || LINES.COD_SIT_TRIB_FED || ' NAO PARAMETRIZADO.');
            END IF ; -- ( IPI ) VERIFICAC?O DA EXISTENCIA DE PARAMETRIZAC?O

            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- EFETUANDO O CALCULO DAS BASES ATRAVES DA SITUAC?O TRIBUTARIA
            -- DE CADA ITEM ( IR )
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            IF ( VAR_ITEM_VLR_IR > 0 ) THEN
                 VAR_BASE_TRIB_IR := VAR_BASE_TRIB_IR + NVL( VAR_ITEM_BASE_IR, 0 ) ;
            ELSE
                 VAR_BASE_ISEN_IR := VAR_BASE_ISEN_IR + NVL( VAR_ITEM_BASE_IR, 0 ) ;
            END IF ;

            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- EFETUANDO O CALCULO DAS BASES ATRAVES DA SITUAC?O TRIBUTARIA
            -- DE CADA ITEM ( ISS )
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            IF ( VAR_ITEM_VLR_ISS > 0 ) THEN
                 VAR_BASE_TRIB_ISS := VAR_BASE_TRIB_ISS + NVL( VAR_ITEM_BASE_ISS, 0 ) ;
            ELSE
                 VAR_BASE_ISEN_ISS := VAR_BASE_ISEN_ISS + NVL( VAR_ITEM_BASE_ISS, 0 ) ;
            END IF ;

            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- EFETUANDO O CALCULO DAS BASES ATRAVES DA SITUAC?O TRIBUTARIA
            -- DE CADA ITEM ( ICMS - SUBSTITUIC?O TRIBUTARIA )
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            IF ( VAR_ITEM_BASE_SICMS > 0 ) THEN
                 VAR_BASE_SUB_TRIB_ICMS := VAR_BASE_SUB_TRIB_ICMS + NVL( VAR_ITEM_BASE_SICMS, 0 ) ;
            END IF ;

            -- TRATA ESTABELECIMENTO ESCRITURADOR CORRETO NOTAS CARREGADAS VIA INTERFACE AR
            V_COD_ESTAB := NULL;

            IF LINES.WAREHOUSE_CNPJ IS NOT NULL THEN
               V_COD_ESTAB := SUBSTR(LINES.WAREHOUSE_CNPJ,9,4);
            END IF;

       END LOOP; -- LOOP LINES

        --
        -- SE N?O HOUVER PROBLEMAS COM OS DADOS DOS ITENS DA NOTA FISCAL
        -- COM RELAC?O A PARAMETRIZAC?O POR CFOP OU TIPO FISCAL DO ITEM.
        -- A NOTA FISCAL DEVERA CONTINUAR A SER PROCESSADA E GRAVADA
        --
     IF ( VAR_GRAVA_DADOS_07S ) THEN
             -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             -- FORMATANDO O CAMPO "COD_CLASS_DOC_FIS"
             -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             IF    (DADOS.TIPO_NOTA = '3') THEN
                     --
                     -- HA ITENS COM TIPO 1 E 2 (MERCADORIA E SERVICO)
                     --
                     VAR_COD_CLASS_DOC_FIS := '3' ; -- (CONJUGADA)
             ELSIF (DADOS.TIPO_NOTA = '1') THEN
                     --
                     -- HA ITENS COM TIPO 1
                     --
                     VAR_COD_CLASS_DOC_FIS := '1' ; -- (MERCADORIA)
             ELSIF (DADOS.TIPO_NOTA = '2') THEN
                     --
                     -- HA ITENS COM TIPO 2
                     --
                     VAR_COD_CLASS_DOC_FIS := '2' ; -- SERVICO
             ELSE
                     --
                     -- QUALQUER OUTRO VALOR QUE SEJA APRESENTADO
                     -- DEVE SER APRESENTADO NO MASTERSAF COMO
                     -- ERRO... PARA TANTO, GRAVA-SE NULL
                     --
                     VAR_COD_CLASS_DOC_FIS := NULL ;
             END IF ;
             -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             -- FORMATANDO OS CAMPOS NUM_DOCFIS_REF E SERIE_DOCFIS_REF
             -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             VAR_NUM_DOCFIS_REF   := NULL ;
             VAR_SERIE_DOCFIS_REF := NULL ;

             IF ((DADOS.NUM_DOCFIS = DADOS.NUM_DOCFIS_PAI) OR (DADOS.NUM_DOCFIS_PAI IS NULL)) THEN
                VAR_NUM_DOCFIS_REF   := NULL ;
                VAR_SERIE_DOCFIS_REF := NULL ;
             ELSE
                VAR_NUM_DOCFIS_REF   := DADOS.NUM_DOCFIS_PAI ;
                VAR_SERIE_DOCFIS_REF := DADOS.SERIE_NF_PAI ;
             END IF;

             -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             -- FORMATANDO O CAMPO COD_CONTA
             -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             CVAR_ERRO_GLOBAL := NULL ;
             CVAR_ERRO_GLOBAL := '07S-006 : ' || 'DOCTO : ' || DADOS.NUM_DOCFIS || ' - ' || 'BUSCANDO CODIGO DA CONTA' ;
             VAR_COD_CONTA := NULL ;
             -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             -- FORMATANDO O CAMPO "SITUACAO" E DEDUZINDO CONTA CONTABIL
             -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             IF ( DADOS.STATUS_NF = 'OP' ) THEN
                VAR_COD_CONTA  := DADOS.COD_CONTA;
                VAR_SITUACAO   := DADOS.SITUACAO;
                BINSERT        := TRUE;  -- NAO E NOTA CANCELADA
             ELSE
                VAR_COD_CONTA := '@';
                VAR_SITUACAO  := 'S' ;
                -- CONFIRMA SE E CANCELAMENTO OU NAO PARA MONTAR O INSERT CORRETO
                IF (DADOS.ID_NOTA_PAI IS NULL) THEN
                   BINSERT := TRUE;
                ELSE
                   BINSERT := FALSE;
                END IF;
             END IF;
             -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             -- FORMATANDO O CAMPO VLR_PRODUTO E VLR_TOT_NOTA
             -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             VAR_VLR_PRODUTO  := 0 ;
             VAR_VLR_TOT_NOTA := 0 ;
             IF ( VAR_COD_CLASS_DOC_FIS = '3' ) THEN
                  -- OS-00126 - INI
                  VAR_VLR_PRODUTO  := DADOS.VLR_TOT_MERC ;
                  VAR_VLR_TOT_NOTA := DADOS.VLR_TOT_SERV + DADOS.VLR_TOT_MERC;
             ELSIF ( VAR_COD_CLASS_DOC_FIS = '2' ) THEN
                  VAR_VLR_PRODUTO  := 0;
                  VAR_VLR_TOT_NOTA := VAR_TNOTAFIS_CLASS_DOC ;
                  -- OS-00126 - FIM
             ELSE
                  VAR_VLR_PRODUTO  := VAR_TPRODUTO_CLASS_DOC ;
                  VAR_VLR_TOT_NOTA := VAR_TNOTAFIS_CLASS_DOC ;
             END IF ;
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             -- FORMATANDO O CAMPO VLR_CONTAB_COMPL
             -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             IF ( VAR_COD_CLASS_DOC_FIS = '3' ) THEN
                  -- OS-00126 - INI
                  VAR_VLR_CONTAB_COMPL := DADOS.VLR_TOT_SERV ;
                  -- OS-00126 - FIM
             ELSE
                  VAR_VLR_CONTAB_COMPL := NULL;
             END IF ;
             -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             -- FORMATANDO O CAMPO MOVTO_E_S E NORM_DEV
             -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
              -- NORM_DEV RECEBE COD_CFO, POIS UTILIZA A REGRA 103 PARA DEFINIR 1 - NORMAL 2 - DEVOLUCAO
             VAR_NORM_DEV :=  VAR_ITE_COD_CFO;
             VAR_MOVTO_E_S := DADOS.MOVTO_E_S;

             CVAR_ERRO_GLOBAL := NULL ;
             CVAR_ERRO_GLOBAL := '07S-007 : ' || 'DOCTO : ' || DADOS.NUM_DOCFIS || ' - ' || 'INSERINDO O REGISTRO NA TABELA MSAFI_MSFTB_KPT0007' ;

             --RECUPERA O CODIGO DO MUNICIPIO CADASTRADO NO MASTERSAF (ESTABELECIMENTO)

             IF V_COD_ESTAB IS NULL THEN
                V_COD_ESTAB := DADOS.COD_ESTAB;
             END IF;

             BEGIN
                  SELECT B.COD_ESTADO,A.CIDADE, A.CEP, COD_MUNICIPIO
                  INTO V_UF_ORIGEM, V_NOME_CIDADE_MSAF, V_CEP_MSAF, V_COD_MUNIC_ORIGEM_MSAF
                  FROM ESTABELECIMENTO A, ESTADO B
                  WHERE SUBSTR(A.CGC,1,12) = DADOS.COD_EMPRESA || V_COD_ESTAB
                    AND A.IDENT_ESTADO  =  B.IDENT_ESTADO
                    AND ROWNUM = 1;

                  IF LTRIM(RTRIM(V_UF_ORIGEM)) <> 'AM' THEN
                     V_IE := '@';
                  END IF;

                  -- BUSCA O CODIGO DO MUNICIPIO
                  IF V_COD_MUNIC_ORIGEM_MSAF IS NULL THEN
                     V_COD_MUNIC_ORIGEM_MSAF := MSAFI_MSFSY_COD_MUNICIPIO(V_UF_ORIGEM, V_NOME_CIDADE_MSAF, V_CEP_MSAF);
                  END IF;
             EXCEPTION
                  WHEN OTHERS THEN
                     V_IE               := '@';
                     V_UF_ORIGEM        := '@';
                     V_COD_MUNIC_ORIGEM_MSAF := '@';
             END;

            /*******************************************/
            /*   IDENTIFICADOR DE ICMS ORIG/DEST       */
            /*******************************************/
            IF (V_COD_MUNIC_ORIGEM_MSAF IS NULL OR V_COD_MUNIC_ORIGEM_MSAF = '@') THEN
              VAR_TIPO_ESTAB  := DADOS.TIPO_ESTAB;
              V_NOME_CIDADE   := DADOS.CIDADE;
              V_CEP           := DADOS.CEP;
              V_COD_MUNIC_ORIGEM := MSAFI_MSFSY_COD_MUNICIPIO(V_UF_ORIGEM, V_NOME_CIDADE, V_CEP);
            END IF;

            /******************************************************************/
            /********** CALCULOS PARA VALOR DE DESCONTO  **********************/
            /******************************************************************/
             VAR_VLR_DESCONTO := DADOS.VLR_DESCONTO;

            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- FORMATANDO O CAMPO CONTRIB_FINAL
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

            -- VALIDAR EM CADA CLIENTE QUAL DAS DUAS REGRAS
            -- PARA O CAMPO ABAIXO

            VAR_CONTRIB_FINAL := NULL ;

            IF ( VAR_VLR_INCLUI_IMPOSTO ) THEN
                 VAR_CONTRIB_FINAL := 'S' ;
            ELSE
                 VAR_CONTRIB_FINAL := 'N' ;
            END IF ;

            -- PARA CLIENTES DA INDUSTRIA AUTOMOBILISTICA
            -- VALIDAR EM CADA CLIENTE
            VAR_IND_CPVD    := NULL;

            IF  VAR_TIPO_ESTAB = 'CLIENTE PF' THEN
                 VAR_CONTRIB_FINAL    := NULL;
                 VAR_IND_CPVD         := 'FD';
                 VAR_CONTRIB_FINAL    := 'S' ;
                 V_ALIQ_ICMS_ORIGDEST := VAR_VLR_ALIQ_SUB_ICMS;
                 V_BASE_ICMS_ORIGDEST := VAR_BASE_SUB_TRIB_ICMS;
                 V_VLR_ICMS_ORIGDEST  := VAR_SUBST_ICMS;
            ELSE
                 VAR_CONTRIB_FINAL    := NULL;
                 VAR_CONTRIB_FINAL    := 'N' ;
                 V_ALIQ_ICMS_ORIGDEST := NULL;
                 V_BASE_ICMS_ORIGDEST := NULL;
                 V_VLR_ICMS_ORIGDEST  := NULL;
            END IF ;

             V_IND_SITUACAO_ESP := '@'; -- VALIDAR EM CADA CLIENTE NOTAS FISCAIS ESPECIAIS

--           BEGIN 004
            -- DEFININDO ICMS NAO DESTACADO
            IF (DADOS.IND_BASE1_ICMS = '3') THEN
               VAR_VLR_ICMS_NDESTAC := VAR_VLR_ICMS;
               VAR_VLR_ICMS := 0;
            ELSE
               VAR_VLR_ICMS_NDESTAC := NULL;
            END IF;

            -- DEFININDO IPI NAO DESTACADO
            IF (DADOS.IND_BASE1_IPI = '3') THEN
               VAR_VLR_IPI_NDESTAC := VAR_VLR_IPI;
               VAR_VLR_IPI := 0;
            ELSE
               VAR_VLR_IPI_NDESTAC := NULL;
            END IF;
--           END 004

          IF BINSERT THEN -- NOTAS OP OU CM QUE DEVEM SER INSERIDAS

             V_IE := NULL; -- DEPENDE DO SETUP DO AR ( IDEM A SERIE E ESTABELECIMENTO )
             V_IND_TRANSF_CRED := NULL; -- VALIDAR EM CADA CLIENTE - SUGEST?O AMARRAR COM A NOP VIA REGRA
             VAR_OBS_ICMS := NULL; -- VALIDAR EM CADA CLIENTE
             VAR_NUM_CONTROLE_DOCTO := DADOS.CUSTOMER_TRX_ID || DADOS.ORG_ID;

          BEGIN

                -- 001 - Inicio
                if VAR_NUM_DOCFIS_REF = DADOS.NUM_DOCFIS then
                   VAR_NUM_DOCFIS_REF := null;
                   VAR_SERIE_DOCFIS_REF := null;
                end if;
                -- 001 - Fim

                --006
                VAR_BASE_ISEN_IPI := DADOS.AUX02;
                VAR_BASE_OUTR_IPI := DADOS.AUX03;
                --006

                --007
                VAR_BASE_TRIB_ICMS := DADOS.AUX04;
                VAR_BASE_ISEN_ICMS := DADOS.AUX05;
                VAR_BASE_OUTR_ICMS := DADOS.AUX06;

                IF (NVL(VAR_BASE_ISEN_ICMS,0) + NVL(VAR_BASE_OUTR_ICMS,0)) = VAR_VLR_TOT_NOTA THEN
                  VAR_ITEM_VLR_ALIQ_ICMS := 0;
                END IF;
                --007

                --008
                VAR_VLR_ICMS := DADOS.AUX07;

                IF NVL(VAR_BASE_OUTR_ICMS,0) > 0 THEN
                  VAR_VLR_ICMS_NDESTAC := VAR_VLR_ICMS;
                  VAR_VLR_ICMS         := 0;
                ELSE
                  VAR_VLR_ICMS_NDESTAC := 0;
                END IF;
                --008

                --009
                --DADOS.IND_NFE_DENEG_INUT := NVL(DADOS.AUX08,DADOS.IND_NFE_DENEG_INUT);
                --009


                -- Begin - Vinicius Ferreira 24/06/2019 -- 010
                IF DADOS.AUX09 = '5' THEN
                  DADOS.SITUACAO := 'S';
                  DADOS.IND_NFE_DENEG_INUT := '1';
                ELSIF DADOS.AUX09 = '6' THEN
                  DADOS.SITUACAO := 'S';
                  DADOS.IND_NFE_DENEG_INUT := '2';
                END IF;
                -- End - Vinicius Ferreira 24/06/2019 -- 010


                RTAB_DEST := NULL;

                RTAB_DEST.PST_ID                 := DADOS.PST_ID;               -- 00
                RTAB_DEST.COD_EMPRESA            := DADOS.COD_EMPRESA;          -- 01
                RTAB_DEST.COD_ESTAB              := V_COD_ESTAB;                -- 02
                RTAB_DEST.MOVTO_E_S              := DADOS.MOVTO_E_S;            -- 03
                RTAB_DEST.NORM_DEV               := VAR_NORM_DEV;               -- 04
                RTAB_DEST.COD_DOCTO              := DADOS.TIPO;                 -- 05
                RTAB_DEST.IDENT_FIS_JUR          := DADOS.IND_FIS_JUR;          -- 06
                RTAB_DEST.COD_FIS_JUR            := DADOS.COD_CLIENTE_SHIP;     -- 07
                RTAB_DEST.NUM_DOCFIS             := DADOS.NUM_DOCFIS;           -- 08
                RTAB_DEST.SERIE_DOCFIS           := DADOS.SERIE;                -- 09
                RTAB_DEST.SUB_SERIE_DOCFIS       := DADOS.SUB_SERIE_DOCFIS;     -- 10
                RTAB_DEST.DATA_EMISSAO           := DADOS.DATA_EMISSAO;         -- 11
                RTAB_DEST.COD_CLASS_DOC_FIS      := VAR_COD_CLASS_DOC_FIS;      -- 12
                RTAB_DEST.COD_MODELO             := DADOS.COD_DOCTO;            -- 13
                RTAB_DEST.COD_CFO                := VAR_ITE_COD_CFO;            -- 14
                --005
                --RTAB_DEST.COD_NATUREZA_OP        := NULL;                       -- 15
                RTAB_DEST.COD_NATUREZA_OP        := DADOS.AUX01;                       -- 15
                --005
                RTAB_DEST.NUM_DOCFIS_REF         := VAR_NUM_DOCFIS_REF;         -- 16
                RTAB_DEST.SERIE_DOCFIS_REF       := VAR_SERIE_DOCFIS_REF;       -- 17
                RTAB_DEST.S_SER_DOCFIS_REF       := NULL;                       -- 18
                RTAB_DEST.NUM_DEC_IMP_REF        := NULL;                       -- 19
                RTAB_DEST.DATA_SAIDA_REC         := DADOS.DATA_EXPEDICAO;       -- 20
                RTAB_DEST.INSC_ESTAD_SUBSTIT     := NULL;                       -- 21
                RTAB_DEST.VLR_PRODUTO            := VAR_VLR_PRODUTO;            -- 22
                RTAB_DEST.VLR_TOT_NOTA           := VAR_VLR_TOT_NOTA;           -- 23
                RTAB_DEST.VLR_FRETE              := DADOS.VLR_FRETE;            -- 24
                RTAB_DEST.VLR_SEGURO             := DADOS.VLR_SEGURO;           -- 25
                RTAB_DEST.VLR_OUTRAS             := DADOS.VLR_OUTRAS;           -- 26
                RTAB_DEST.VLR_BASE_DIF_FRETE     := NULL;                       -- 27
                RTAB_DEST.VLR_DESCONTO           := DADOS.VLR_DESCONTO;         -- 28
                RTAB_DEST.CONTRIB_FINAL          := VAR_CONTRIB_FINAL;          -- 29
                RTAB_DEST.SITUACAO               := DADOS.SITUACAO;             -- 30
                RTAB_DEST.COD_INDICE             := NULL;                       -- 31
                RTAB_DEST.VLR_NOTA_CONV          := NULL;                       -- 32
                RTAB_DEST.COD_CONTA              := VAR_COD_CONTA;              -- 33
                RTAB_DEST.VLR_ALIQ_ICMS          := VAR_ITEM_VLR_ALIQ_ICMS;     -- 34
                RTAB_DEST.VLR_ICMS               := VAR_VLR_ICMS;               -- 35
                RTAB_DEST.DIF_ALIQ_ICMS          := NULL;                       -- 36
                RTAB_DEST.OBS_ICMS               := NULL;                       -- 37
                RTAB_DEST.COD_APUR_ICMS          := NULL;                       -- 38
                RTAB_DEST.VLR_ALIQ_IPI           := VAR_ITEM_VLR_ALIQ_IPI;      -- 39
                RTAB_DEST.VLR_IPI                := VAR_VLR_IPI;                -- 40
                RTAB_DEST.OBS_IPI                := NULL;                       -- 41
                RTAB_DEST.COD_APUR_IPI           := NULL;                       -- 42
                RTAB_DEST.VLR_ALIQ_IR            := VAR_ITEM_VLR_ALIQ_IR;       -- 43
                RTAB_DEST.VLR_IR                 := VAR_VLR_IR;                 -- 44
                RTAB_DEST.VLR_ALIQ_ISS           := VAR_ITEM_VLR_ALIQ_ISS;      -- 45
                RTAB_DEST.VLR_ISS                := VAR_VLR_ISS;                -- 46
                RTAB_DEST.VLR_ALIQ_SUB_ICMS      := VAR_ITEM_VLR_ALIQ_SICMS;    -- 47
                RTAB_DEST.VLR_SUBST_ICMS         := VAR_SUBST_ICMS;             -- 48
                RTAB_DEST.OBS_SUBST_ICMS         := NULL;                       -- 49
                RTAB_DEST.COD_APUR_SUB_ICMS      := NULL;                       -- 50
                RTAB_DEST.BASE_TRIB_ICMS         := VAR_BASE_TRIB_ICMS;         -- 51
                RTAB_DEST.BASE_ISEN_ICMS         := VAR_BASE_ISEN_ICMS;         -- 52
                RTAB_DEST.BASE_OUTR_ICMS         := VAR_BASE_OUTR_ICMS;         -- 53
                RTAB_DEST.BASE_REDU_ICMS         := VAR_BASE_REDU_ICMS;         -- 54
                RTAB_DEST.BASE_TRIB_IPI          := VAR_BASE_TRIB_IPI;          -- 55
                RTAB_DEST.BASE_ISEN_IPI          := VAR_BASE_ISEN_IPI;          -- 56
                RTAB_DEST.BASE_OUTR_IPI          := VAR_BASE_OUTR_IPI;          -- 57
                RTAB_DEST.BASE_REDU_IPI          := VAR_BASE_REDU_IPI;          -- 58
                RTAB_DEST.BASE_TRIB_IR           := VAR_BASE_TRIB_IR;           -- 59
                RTAB_DEST.BASE_ISEN_IR           := VAR_BASE_ISEN_IR;           -- 60
                RTAB_DEST.BASE_TRIB_ISS          := VAR_BASE_TRIB_ISS;          -- 61
                RTAB_DEST.BASE_ISEN_ISS          := VAR_BASE_ISEN_ISS;          -- 62
                RTAB_DEST.BASE_REAL_TERC_ISS     := NULL;                       -- 63
                RTAB_DEST.BASE_SUB_TRIB_ICMS     := VAR_BASE_SUB_TRIB_ICMS;     -- 64
                RTAB_DEST.NUM_MAQ_REG            := NULL;                       -- 65
                RTAB_DEST.NUM_CUPON_FISC         := NULL;                       -- 66
                RTAB_DEST.IND_MODELO_CUPOM       := NULL;                       -- 67
                RTAB_DEST.VLR_CONTAB_COMPL       := VAR_VLR_CONTAB_COMPL;       -- 68
                RTAB_DEST.NUM_CONTROLE_DOCTO     := VAR_NUM_CONTROLE_DOCTO;     -- 69
                RTAB_DEST.VLR_ALIQ_DESTINO       := NULL;                       -- 70
                RTAB_DEST.IND_NF_ESPECIAL        := NULL;                       -- 71
                RTAB_DEST.IND_TP_FRETE           := NULL;                       -- 72
                RTAB_DEST.COD_MUNICIPIO          := V_COD_MUNIC_DESTINO;        -- 73
                RTAB_DEST.IND_TRANSF_CRED        := NULL;                       -- 74
                RTAB_DEST.DAT_DI                 := NULL;                       -- 75
                RTAB_DEST.VLR_TOM_SERVICO        := NULL;                       -- 76
                RTAB_DEST.DAT_ESCR_EXTEMP        := NULL;                       -- 77
                RTAB_DEST.COD_TRIB_INT           := NULL;                       -- 78
                RTAB_DEST.COD_REGIAO             := NULL;                       -- 79
                RTAB_DEST.DAT_AUTENTIC           := NULL;                       -- 80
                RTAB_DEST.COD_CANAL_DISTRIB      := NULL;                       -- 81
                RTAB_DEST.IND_CRED_ICMSS         := NULL;                       -- 82
                RTAB_DEST.VLR_ICMS_NDESTAC       := VAR_VLR_ICMS_NDESTAC;       -- 83
                RTAB_DEST.VLR_IPI_NDESTAC        := VAR_VLR_IPI_NDESTAC;        -- 84
                RTAB_DEST.VLR_BASE_INSS          := VAR_VLR_INSS;               -- 85
                RTAB_DEST.VLR_ALIQ_INSS          := VAR_ITEM_VLR_ALIQ_INSS;     -- 86
                RTAB_DEST.VLR_INSS_RETIDO        := ABS(VAR_ITEM_VLR_INSS);     -- 87
                RTAB_DEST.VLR_MAT_APLIC_ISS      := NULL;                       -- 88
                RTAB_DEST.VLR_SUBEMPR_ISS        := NULL;                       -- 89
                RTAB_DEST.IND_MUNIC_ISS          := NULL;                       -- 90
                RTAB_DEST.IND_CLASSE_OP_ISS      := NULL;                       -- 91
                RTAB_DEST.VLR_OUTROS1            := NULL;                       -- 92
                RTAB_DEST.DAT_FATO_GERADOR       := DADOS.DAT_FATO_GERADOR;     -- 93
                RTAB_DEST.DAT_CANCELAMENTO       := NULL;                       -- 94
                RTAB_DEST.NUM_PAGINA             := NULL;                       -- 95
                RTAB_DEST.NUM_LIVRO              := NULL;                       -- 96
                RTAB_DEST.NRO_AIDF_NF            := NULL;                       -- 97
                RTAB_DEST.DAT_VALID_DOC_AIDF     := NULL;                       -- 98
                RTAB_DEST.IND_FATURA             := DADOS.IND_FATURA;           -- 99
                RTAB_DEST.COD_QUITACAO           := NULL;                       -- 100
                RTAB_DEST.NUM_SELO_CONT_ICMS     := NULL;                       -- 101
                RTAB_DEST.VLR_BASE_PIS           := DADOS.VLR_BASE_PIS;         -- 102
                RTAB_DEST.VLR_PIS                := DADOS.VLR_PIS;              -- 103
                RTAB_DEST.VLR_BASE_COFINS        := DADOS.VLR_BASE_COFINS;      -- 104
                RTAB_DEST.VLR_COFINS             := DADOS.VLR_COFINS;           -- 105
                RTAB_DEST.BASE_ICMS_ORIGDEST     := NULL;                       -- 106
                RTAB_DEST.VLR_ICMS_ORIGDEST      := NULL;                       -- 107
                RTAB_DEST.ALIQ_ICMS_ORIGDEST     := NULL;                       -- 108
                RTAB_DEST.VLR_DESC_CONDIC        := VAR_VLR_DESCONTO;           -- 109
                RTAB_DEST.VLR_BASE_ISE_ICMSS     := NULL;                       -- 110
                RTAB_DEST.VLR_BASE_OUT_ICMSS     := NULL;                       -- 111
                RTAB_DEST.VLR_RED_BASE_ICMSS     := NULL;                       -- 112
                RTAB_DEST.PERC_RED_BASE_ICMS     := NULL;                       -- 113
                RTAB_DEST.IND_FISJUR_CPDIR       := NULL;                       -- 114
                RTAB_DEST.COD_FISJUR_CPDIR       := NULL;                       -- 115
                RTAB_DEST.IND_MEDIDAJUDICIAL     := NULL;                       -- 116
                RTAB_DEST.UF_ORIG_DEST           := V_UF_ORIGEM;                -- 117
                RTAB_DEST.IND_COMPRA_VENDA       := NULL;                       -- 118
                RTAB_DEST.COD_TP_DISP_SEG        := NULL;                       -- 119
                RTAB_DEST.NUM_CTR_DISP           := NULL;                       -- 120
                RTAB_DEST.NUM_FIM_DOCTO          := NULL;                       -- 121
                RTAB_DEST.UF_DESTINO             := V_UF_DESTINO;               -- 122
                RTAB_DEST.SERIE_CTR_DISP         := NULL;                       -- 123
                RTAB_DEST.SUB_SERIE_CTR_DISP     := NULL;                       -- 124
                RTAB_DEST.IND_SITUACAO_ESP       := V_IND_SITUACAO_ESP;         -- 125
                RTAB_DEST.INSC_ESTADUAL          := NULL;                       -- 126
                RTAB_DEST.COD_PAGTO_INSS         := NULL;                       -- 127
                RTAB_DEST.DAT_INTERN_AM          := NULL;                       -- 128
                RTAB_DEST.IND_FISJUR_LSG         := NULL;                       -- 129
                RTAB_DEST.COD_FISJUR_LSG         := NULL;                       -- 130
                RTAB_DEST.COMPROV_EXP            := NULL;                       -- 131
                RTAB_DEST.NUM_FINAL_CRT_DISP     := NULL;                       -- 132
                RTAB_DEST.NUM_ALVARA             := NULL;                       -- 133
                RTAB_DEST.NOTIFICA_SEFAZ         := NULL;                       -- 134
                RTAB_DEST.INTERNA_SUFRAMA        := NULL;                       -- 135
                RTAB_DEST.COD_AMPARO             := NULL;                       -- 136
                RTAB_DEST.IND_NOTA_SERVICO       := NULL;                       -- 137
                RTAB_DEST.COD_MOTIVO             := NULL;                       -- 138
                RTAB_DEST.UF_AMPARO_LEGAL        := NULL;                       -- 139
                RTAB_DEST.OBS_COMPL_MOTIVO       := NULL;                       -- 140
                RTAB_DEST.IND_TP_RET             := NULL;                       -- 141
                RTAB_DEST.IND_TP_TOMADOR         := NULL;                       -- 142
                RTAB_DEST.COD_ANTEC_ST           := NULL;                       -- 143
                RTAB_DEST.CNPJ_ARMAZ_ORIG        := NULL;                       -- 144
                RTAB_DEST.UF_ARMAZ_ORIG          := NULL;                       -- 145
                RTAB_DEST.INS_EST_ARMAZ_ORIG     := NULL;                       -- 146
                RTAB_DEST.CNPJ_ARMAZ_DEST        := NULL;                       -- 147
                RTAB_DEST.UF_ARMAZ_DEST          := NULL;                       -- 148
                RTAB_DEST.INS_EST_ARMAZ_DEST     := NULL;                       -- 149
                RTAB_DEST.OBS_INF_ADIC_NF        := NULL;                       -- 150
                RTAB_DEST.VLR_BASE_INSS_2        := NULL;                       -- 151
                RTAB_DEST.VLR_ALIQ_INSS_2        := NULL;                       -- 152
                RTAB_DEST.VLR_INSS_RETIDO_2      := NULL;                       -- 153
                RTAB_DEST.COD_PAGTO_INSS_2       := NULL;                       -- 154
                RTAB_DEST.VLR_BASE_PIS_ST        := NULL;                       -- 155
                RTAB_DEST.VLR_ALIQ_PIS_ST        := NULL;                       -- 156
                RTAB_DEST.VLR_PIS_ST             := NULL;                       -- 157
                RTAB_DEST.VLR_BASE_COFINS_ST     := NULL;                       -- 158
                RTAB_DEST.VLR_ALIQ_COFINS_ST     := NULL;                       -- 159
                RTAB_DEST.VLR_COFINS_ST          := NULL;                       -- 160
                RTAB_DEST.VLR_BASE_CSLL          := NULL;                       -- 161
                RTAB_DEST.VLR_ALIQ_CSLL          := NULL;                       -- 162
                RTAB_DEST.VLR_CSLL               := NULL;                       -- 163
                RTAB_DEST.VLR_ALIQ_PIS           := NULL;                       -- 164
                RTAB_DEST.VLR_ALIQ_COFINS        := NULL;                       -- 165
                RTAB_DEST.BASE_ICMSS_SUBSTITUIDO := NULL;                       -- 166
                RTAB_DEST.VLR_ICMSS_SUBSTITUIDO  := NULL;                       -- 167
                RTAB_DEST.IND_SITUACAO_ESP_ST    := NULL;                       -- 168
                RTAB_DEST.VLR_ICMSS_NDESTAC      := NULL;                       -- 169
                RTAB_DEST.IND_DOCTO_REC          := NULL;                       -- 170
                --RTAB_DEST.DAT_PAGTO_GNRE_DARJ   := NULL;                      -- 171
                RTAB_DEST.COD_CEI                := NULL;                       -- 172
                RTAB_DEST.VLR_JUROS_INSS         := NULL;                       -- 173
                RTAB_DEST.VLR_MULTA_INSS         := NULL;                       -- 174
                RTAB_DEST.DT_PAGTO_NF            := NULL;                       -- 175
                RTAB_DEST.HORA_SAIDA             := NULL;                       -- 176
                RTAB_DEST.COD_SIT_DOCFIS         := NULL;                       -- 177
                RTAB_DEST.COD_OBSERVACAO         := NULL;                       -- 178
                RTAB_DEST.COD_SITUACAO_A         := NULL;                       -- 179
                RTAB_DEST.COD_SITUACAO_B         := NULL;                       -- 180
                RTAB_DEST.NUM_CONT_REDUC         := NULL;                       -- 181
                RTAB_DEST.COD_MUNICIPIO_ORIG     := V_COD_MUNIC_ORIGEM;         -- 182
                RTAB_DEST.COD_MUNICIPIO_DEST     := V_COD_MUNIC_DESTINO;        -- 183
                RTAB_DEST.COD_CFPS               := NULL;                       -- 184
                RTAB_DEST.NUM_LANCAMENTO         := NULL;                       -- 185
                RTAB_DEST.VLR_MAT_PROP           := NULL;                       -- 186
                RTAB_DEST.VLR_MAT_TERC           := NULL;                       -- 187
                RTAB_DEST.VLR_BASE_ISS_RETIDO    := NULL;                       -- 188
                RTAB_DEST.VLR_ISS_RETIDO         := NULL;                       -- 189
                RTAB_DEST.VLR_DEDUCAO_ISS        := NULL;                       -- 190
                RTAB_DEST.COD_MUNIC_ARMAZ_ORIG   := NULL;                       -- 191
                RTAB_DEST.INS_MUNIC_ARMAZ_ORIG   := NULL;                       -- 192
                RTAB_DEST.COD_MUNIC_ARMAZ_DEST   := NULL;                       -- 193
                RTAB_DEST.INS_MUNIC_ARMAZ_DEST   := NULL;                       -- 194
                RTAB_DEST.COD_CLASSE_CONSUMO     := NULL;                       -- 195
                RTAB_DEST.IND_ESPECIF_RECEITA    := NULL;                       -- 196
                RTAB_DEST.NUM_CONTRATO           := NULL;                       -- 197
                RTAB_DEST.COD_AREA_TERMINAL      := NULL;                       -- 198
                RTAB_DEST.COD_TP_UTIL            := NULL;                       -- 199
                RTAB_DEST.GRUPO_TENSAO           := NULL;                       -- 200
                RTAB_DEST.DATA_CONSUMO_INI       := NULL;                       -- 201
                RTAB_DEST.DATA_CONSUMO_FIM       := NULL;                       -- 202
                RTAB_DEST.DATA_CONSUMO_LEIT      := NULL;                       -- 203
                RTAB_DEST.QTD_CONTRATADA_PONTA   := NULL;                       -- 204
                RTAB_DEST.QTD_CONTRATADA_FPONTA  := NULL;                       -- 205
                RTAB_DEST.QTD_CONSUMO_TOTAL      := NULL;                       -- 206
                RTAB_DEST.UF_CONSUMO             := NULL;                       -- 207
                RTAB_DEST.COD_MUNIC_CONSUMO      := NULL;                       -- 208
                RTAB_DEST.COD_OPER_ESP_ST        := NULL;                       -- 209
                RTAB_DEST.ATO_NORMATIVO          := NULL;                       -- 210
                RTAB_DEST.NUM_ATO_NORMATIVO      := NULL;                       -- 211
                RTAB_DEST.ANO_ATO_NORMATIVO      := NULL;                       -- 212
                RTAB_DEST.CAPITULACAO_NORMA      := NULL;                       -- 213
                RTAB_DEST.VLR_OUTRAS_ENTID       := NULL;                       -- 214
                RTAB_DEST.VLR_TERCEIROS          := NULL;                       -- 215
                RTAB_DEST.IND_TP_COMPL_ICMS      := NULL;                       -- 216
                RTAB_DEST.VLR_BASE_CIDE          := NULL;                       -- 217
                RTAB_DEST.VLR_ALIQ_CIDE          := NULL;                       -- 218
                RTAB_DEST.VLR_CIDE               := NULL;                       -- 219
                RTAB_DEST.COD_VERIFIC_NFE        := NULL;                       -- 220
                RTAB_DEST.COD_TP_RPS_NFE         := NULL;                       -- 221
                RTAB_DEST.NUM_RPS_NFE            := NULL;                       -- 222
                RTAB_DEST.SERIE_RPS_NFE          := NULL;                       -- 223
                RTAB_DEST.DAT_EMISSAO_RPS_NFE    := NULL;                       -- 224
                RTAB_DEST.DSC_SERVICO_NFE        := NULL;                       -- 225
                RTAB_DEST.NUM_AUTENTIC_NFE       := DADOS.NUM_AUTENTIC_NFE;     -- 226
                RTAB_DEST.NUM_DV_NFE             := NULL;                       -- 227
                RTAB_DEST.MODELO_NF_DMS          := NULL;                       -- 228
                RTAB_DEST.COD_MODELO_COTEPE      := DADOS.COD_DOCTO;            -- 229 -- 003
                RTAB_DEST.VLR_COMISSAO           := NULL;                       -- 230
                --002 inicio
                --RTAB_DEST.IND_NFE_DENEG_INUT     := NULL;                       -- 231
                RTAB_DEST.IND_NFE_DENEG_INUT     := DADOS.IND_NFE_DENEG_INUT;   -- 231
                --002 fim
                RTAB_DEST.IND_NF_REG_ESPECIAL    := NULL;                       -- 232
                RTAB_DEST.VLR_ABAT_NTRIBUTADO    := NULL;                       -- 233
                RTAB_DEST.VLR_OUTROS_ICMS        := NULL;                       -- 234
                RTAB_DEST.HORA_EMISSAO           := NULL;                       -- 235
                RTAB_DEST.OBS_DADOS_FATURA       := NULL;                       -- 236
                RTAB_DEST.IND_FIS_CONCES         := NULL;                       -- 237
                RTAB_DEST.COD_FIS_CONCES         := NULL;                       -- 238
                RTAB_DEST.COD_AUTENTIC           := NULL;                       -- 239
                RTAB_DEST.IND_PORT_CAT44         := NULL;                       -- 240
                RTAB_DEST.VLR_BASE_INSS_RURAL    := NULL;                       -- 241
                RTAB_DEST.VLR_ALIQ_INSS_RURAL    := NULL;                       -- 242
                RTAB_DEST.VLR_INSS_RURAL         := NULL;                       -- 243
--                RTAB_DEST.DATA_ATUALIZACAO       := NULL;
                RTAB_DEST.COD_CLASSE_CONSUMO_SEF_PE := NULL;                    -- 244
                RTAB_DEST.VLR_PIS_RETIDO         := DADOS.VLR_PIS_RETIDO;       -- 245
                RTAB_DEST.VLR_COFINS_RETIDO      := DADOS.VLR_COFINS_RETIDO;    -- 246
                RTAB_DEST.DAT_LANC_PIS_COFINS    := NULL;                       -- 247
                RTAB_DEST.IND_PIS_COFINS_EXTEMP  := NULL;                       -- 248
                RTAB_DEST.COD_SIT_PIS            := NULL;                       -- 249
                RTAB_DEST.COD_SIT_COFINS         := NULL;                       -- 250
                RTAB_DEST.IND_NAT_FRETE          := NULL;                       -- 251
                RTAB_DEST.COD_NAT_REC            := NULL;                       -- 252
                RTAB_DEST.IND_VENDA_CANC         := NULL;                       -- 253
                RTAB_DEST.IND_NAT_BASE_CRED      := NULL;                       -- 254
                RTAB_DEST.IND_NF_CONTINGENCIA    := NULL;                       -- 255
                RTAB_DEST.VLR_ACRESCIMO          := NULL;                       -- 256
                RTAB_DEST.VLR_ANTECIP_TRIB       := NULL;                       -- 257
                RTAB_DEST.IND_IPI_NDESTAC_DF     := NULL;                       -- 258
                RTAB_DEST.DSC_RESERVADO1         := NULL;                       -- 259
                RTAB_DEST.DSC_RESERVADO2         := NULL;                       -- 260
                RTAB_DEST.DSC_RESERVADO3         := NULL;                       -- 261
                RTAB_DEST.NUM_NFTS               := DADOS.NUM_NFTS;             -- 262
                RTAB_DEST.IND_NF_VENDA_TERCEIROS := DADOS.IND_NF_VENDA_TERCEIROS; -- 263
                RTAB_DEST.AUX01                  := DADOS.AUX01;                -- a01
                RTAB_DEST.AUX02                  := DADOS.AUX02;                -- a02
                RTAB_DEST.AUX03                  := DADOS.AUX03;                -- a03
                RTAB_DEST.AUX04                  := DADOS.AUX04;                -- a04
                RTAB_DEST.AUX05                  := DADOS.AUX05;                -- a05
                RTAB_DEST.AUX06                  := DADOS.AUX06;                -- a06
                RTAB_DEST.AUX07                  := DADOS.AUX07;                -- a07
                RTAB_DEST.AUX08                  := DADOS.AUX08;                -- a08
                RTAB_DEST.AUX09                  := DADOS.AUX09;                -- a09
                RTAB_DEST.AUX10                  := DADOS.AUX10;                -- a10
                RTAB_DEST.AUX11                  := DADOS.AUX11;                -- a11
                RTAB_DEST.AUX12                  := DADOS.AUX12;                -- a12
                RTAB_DEST.AUX13                  := DADOS.AUX13;                -- a13
                RTAB_DEST.AUX14                  := DADOS.AUX14;                -- a14
                RTAB_DEST.AUX15                  := DADOS.AUX15;                -- a15
                RTAB_DEST.AUX16                  := DADOS.AUX16;                -- a16
                RTAB_DEST.AUX17                  := DADOS.AUX17;                -- a17
                RTAB_DEST.AUX18                  := DADOS.AUX18;                -- a18
                RTAB_DEST.AUX19                  := DADOS.AUX19;                -- a19
                RTAB_DEST.AUX20                  := DADOS.AUX20;                -- a20
                RTAB_DEST.AUX21                  := DADOS.AUX21;                -- a21
                RTAB_DEST.AUX22                  := DADOS.AUX22;                -- a22
                RTAB_DEST.AUX23                  := DADOS.AUX23;                -- a23
                RTAB_DEST.AUX24                  := DADOS.AUX24;                -- a24
                RTAB_DEST.AUX25                  := DADOS.AUX25;                -- a25
                RTAB_DEST.AUX26                  := DADOS.AUX26;                -- a26
                RTAB_DEST.AUX27                  := DADOS.AUX27;                -- a27
                RTAB_DEST.AUX28                  := DADOS.AUX28;                -- a28
                RTAB_DEST.AUX29                  := DADOS.AUX29;                -- a29
                RTAB_DEST.AUX30                  := DADOS.AUX30;                -- a30

                --INSERINDO DADOS NA TABELA TEMPORARIA
                INSERT INTO MSAFI_MSFTB_KPT0007 VALUES RTAB_DEST;

                IF ( PRC_PAR_RECORDS_UPDATED >= 200 ) THEN
                  PRC_PAR_RECORDS_UPDATED := 0;
                  COMMIT ;
                ELSE
                  PRC_PAR_RECORDS_UPDATED := PRC_PAR_RECORDS_UPDATED + 1;
                END IF ;

         EXCEPTION
           WHEN OTHERS THEN
             MSAFI_MSFSY_GENERATE_LOG.PRC_LOG_MSG
             ( 1, 'ERRO AO INSERIR DADOS NA TABELA MSAFI_MSFTB_KPT0007 ..'||'NUMDOCFIS = '|| DADOS.NUM_DOCFIS||'  COD EMPRESA : ' ||DADOS.COD_EMPRESA)  ;
             PRC_PAR_ERRORS_OCURRED := 1;
         END;
       END IF; -- BINSERT PARA NOTAS CANCELADAS OU NEGATIVAS CM

      ELSE
             -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             -- GRAVANDO O LOG DA NOTA FISCAL IGNORADA POR FALTA
             -- DE PARAMETRIZAC?O
             -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
              MSAFI_MSFSY_GENERATE_LOG.PRC_LOG_MSG
              (
                1,
                'SAFX07 ( SAIDA ) : NOTA FISCAL ( '
                ||
                RTRIM(LTRIM(DADOS.NUM_DOCFIS))
                ||
                ' ) COM FALTA DE PARAMETRIZAC?O DE CLASSIFICAC?O FISCAL..., FAVOR AVERIGUAR...'
              ) ;
              MSAFI_MSFSY_GENERAL.BVAR_GLOBAL_ERRORS_FOUND := TRUE ;
              PRC_PAR_ERRORS_OCURRED := 1;
       END IF ; -- GRAVAC?O DAS NOTAS FISCAIS DE SAIDA PERANTE A PARAMETRIZAC?O
      END IF; -- FILTRO DE NOTAS DE DEVOLUCAO
      COMMIT ;
    END LOOP ;  -- HEADER

  END PRC_07_GRAVACAO ;

  --
  -- 02. DEFINIC?O DO TIPO DE LEITURA DE DADOS ( CARGA INICIAL OU TABELA DE
  --     NOTIFICAC?O )
  --
  PROCEDURE PRC_07S_LEITURA IS
    --
    -- VARIAVEIS UTILIZADAS
    --
    NVAR_RECORDS_UPDATED   NUMBER  := 0     ; -- CONTROLE DA QTDE. DE REGISTROS GRAVADOS
    CVAR_PRC_DSCMSG_FOUND  LONG    := NULL  ; -- MENSAGENS DE ERRO
    BVAR_PRC_ERRORS_FOUND  BOOLEAN := FALSE ; -- VERIFICAC?O DE ERROS
  BEGIN
         -- DEVERA ELABORAR A CARGA INICIAL DE DADOS
         --
         OPEN CRS_07_HEADER;
         FETCH CRS_07_HEADER INTO RECORD_07_HEADER ;
         BFOUND_07_HEADER := CRS_07_HEADER%FOUND ;
         CLOSE CRS_07_HEADER ;
         IF ( NOT( BFOUND_07_HEADER ) ) THEN
              -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
              -- N?O HA REGISTROS NA TABELA CAIBR_AR_NFS
              -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
              MSAFI_MSFSY_GENERATE_LOG.PRC_LOG_MSG
              (
                1,
                'SAFX07 ( SAIDA ) : N?O HA REGISTROS PARA ELABORAC?O DA CARGA INICIAL DE DADOS..., FAVOR AVERIGUAR...'
              ) ;

              MSAFI_MSFSY_GENERAL.BVAR_GLOBAL_ERRORS_FOUND := TRUE ;
              PRC_PAR_ERRORS_OCURRED := 1;
         ELSE
              --
              -- ELABORANDO A GRAVAC?O DOS DADOS
              --
              CVAR_ERRO_GLOBAL := NULL ;
              CVAR_ERRO_GLOBAL := '07S-008 : PROCESSANDO ROTINA DE GRAVACAO' ;
              PRC_07_GRAVACAO (NULL,NULL,NVAR_RECORDS_UPDATED);
         END IF ;
  END PRC_07S_LEITURA ;
BEGIN

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- LIMPANDO A TABELA AUXILIAR MSAFI_MSFTB_KPT0007
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   DELETE FROM MSAFI_MSFTB_KPT0007 ;
  COMMIT ;

  --
  -- DEFININDO SE A LEITURA DOS DADOS CONTERA DADOS SOMENTE DE SAIDA, OU TAMBEM
  -- DADOS DE ENTRADA ( AR )
  --
  OPEN CRS_MSPM07E1( PRC_PAR_COMPANY_CODE ) ;
  FETCH CRS_MSPM07E1 INTO RECORD_MSPM07E1 ;
  BFOUND_MSPM07E1_COMPANY := CRS_MSPM07E1%FOUND ;
  CLOSE CRS_MSPM07E1 ;
  IF ( NOT( BFOUND_MSPM07E1_COMPANY ) ) THEN
       --
       -- OBTENDO A CONFIGURAC?O DOS DADOS DO "AR" DEFINIDOS PARA A ORGANIZAC?O,
       -- ATRAVES DA LITERAL "TODOS"
       --
       OPEN CRS_MSPM07E1( 'TODOS' ) ;
       FETCH CRS_MSPM07E1 INTO RECORD_MSPM07E1 ;
       BFOUND_MSPM07E1_TODOS := CRS_MSPM07E1%FOUND ;
       CLOSE CRS_MSPM07E1 ;
  END IF ;
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- VERIFICANDO SE HA PARAMETRIZAC?O PARA OS DADOS PROVENIENTES DO "AR"
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  IF ( NOT( BFOUND_MSPM07E1_COMPANY ) AND NOT( BFOUND_MSPM07E1_TODOS ) ) THEN
       -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
       -- N?O HA PARAMETRIZAC?O PARA OS DADOS DO "AR"
       -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
       MSAFI_MSFSY_GENERATE_LOG.PRC_LOG_MSG
         (
           1,
           'SAFX07 ( SAIDA ) : PARAMETRIZAC?O DE LEITURA DOS DADOS DO "AR" N?O CONFIGURADA..., FAVOR AVERIGUAR...'
         ) ;
       MSAFI_MSFSY_GENERAL.BVAR_GLOBAL_ERRORS_FOUND := TRUE ;
       PRC_PAR_ERRORS_OCURRED := 1;
  ELSE
       IF ( RTRIM( LTRIM( RECORD_MSPM07E1.IND_NFE_AR ) ) IS NULL ) THEN
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- PARAMETRIZAC?O COM PREENCHIMENTO INVALIDO...
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            MSAFI_MSFSY_GENERATE_LOG.PRC_LOG_MSG
              (
                1,
                 'SAFX07 ( SAIDA ) : PARAMETRIZAC?O DE LEITURA DOS DADOS DO "AR" INVALIDA..., FAVOR AVERIGUAR...'
              ) ;
            MSAFI_MSFSY_GENERAL.BVAR_GLOBAL_ERRORS_FOUND := TRUE ;
            PRC_PAR_ERRORS_OCURRED := 1;
       ELSE
            IF ( RECORD_MSPM07E1.IND_NFE_AR = 'S') THEN
                 --
                 -- DEVER?O SER OBTIDOS TODOS OS REGISTROS CONTIDOS NA TABELA DE ORIGEM,
                 -- OU SEJA, MOVIMENTOS DE ENTRADA E SAIDA
                 --
                 CVAR_ENTRADA_DADOS_AR := NULL ;
            ELSE
                 --
                 -- DEVER?O SER OBTIDOS SOMENTE OS REGISTROS DE MOVIMENTOS DE SAIDA
                 --
                 CVAR_ENTRADA_DADOS_AR := 'EXIT' ;
            END IF ;

            --
            -- VERIFICANDO A PARAMETRIZAC?O DO TIPO DE CLASSIFICAC?O FISCAL DO ITEM
            -- ( AVERIGUANDO SE O MESMO ESTA POR TIPO FISCAL OU CFOP )
            --
            OPEN CRS_MSPM07S1( PRC_PAR_COMPANY_CODE ) ;
            FETCH CRS_MSPM07S1 INTO RECORD_MSPM07S1 ;
            BFOUND_MSPM07S1_COMPANY := CRS_MSPM07S1%FOUND ;
            CLOSE CRS_MSPM07S1 ;
            IF ( NOT( BFOUND_MSPM07S1_COMPANY ) ) THEN
                 OPEN CRS_MSPM07S1( 'TODOS' ) ;
                 FETCH CRS_MSPM07S1 INTO RECORD_MSPM07S1 ;
                 BFOUND_MSPM07S1_TODOS := CRS_MSPM07S1%FOUND ;
                 CLOSE CRS_MSPM07S1 ;
                 IF ( BFOUND_MSPM07S1_TODOS ) THEN
                      --
                      -- PESQUISA DOS ITENS POR ORGANIZAC?O NA PARAMETRIZAC?O
                      --
                      CVAR_MSPM07S1_CONFIG := 'TODOS' ;
                 END IF ;
            ELSE
                 --
                 -- PESQUISA DOS ITENS POR EMPRESA NA PARAMETRIZAC?O
                 --
                 CVAR_MSPM07S1_CONFIG := PRC_PAR_COMPANY_CODE ;
            END IF ;
            IF ( NOT( BFOUND_MSPM07S1_COMPANY ) AND NOT( BFOUND_MSPM07S1_TODOS ) ) THEN
                 --
                 -- N?O HA PARAMETRIZAC?O DA CLASSIFICAC?O FISCAL DO ITEM
                 --
                 MSAFI_MSFSY_GENERATE_LOG.PRC_LOG_MSG
                 (
                   1,
                   'SAFX07 ( SAIDA ) : PARAMETRIZAC?O DO TIPO DE CLASSIFICAC?O FISCAL DOS ITENS N?O EXISTENTE..., FAVOR AVERIGUAR...'
                 ) ;
                 MSAFI_MSFSY_GENERAL.BVAR_GLOBAL_ERRORS_FOUND := TRUE ;
                 PRC_PAR_ERRORS_OCURRED := 1 ;
            ELSE
                 -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                 -- VERIFICAC?O DO TIPO DE CLASSIFICAC?O FISCAL PARA AVERIGUAC?O
                 -- DA PARAMETRIZAC?O PARA OS ITENS
                 -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                 IF ( RECORD_MSPM07S1.IND_CLASS_NFS = 1 ) THEN
                      --
                      -- CLASSIFICAC?O FISCAL DO ITEM CONFIGURADA POR
                      -- TIPO FISCAL DO ITEM
                      --
                      OPEN CRS_MSPM07S2( PRC_PAR_COMPANY_CODE, NULL ) ;
                      FETCH CRS_MSPM07S2 INTO RECORD_MSPM07S2 ;
                      BFOUND_MSPM07S2_COMPANY := CRS_MSPM07S2%FOUND ;
                      CLOSE CRS_MSPM07S2 ;
                      IF ( NOT( BFOUND_MSPM07S2_COMPANY ) ) THEN
                           OPEN CRS_MSPM07S2( 'TODOS', NULL ) ;
                           FETCH CRS_MSPM07S2 INTO RECORD_MSPM07S2 ;
                           BFOUND_MSPM07S2_TODOS := CRS_MSPM07S2%FOUND ;
                           CLOSE CRS_MSPM07S2 ;
                           IF ( BFOUND_MSPM07S2_TODOS ) THEN
                                --
                                -- PARAMETRIZAC?O POR TIPO FISCAL ( ORGANIZAC?O )
                                --
                                CVAR_MSPM07S2_CONFIG := 'TODOS' ;
                           END IF ;
                      ELSE
                           --
                           -- PARAMETRIZAC?O POR TIPO FISCAL ( EMPRESA )
                           --
                           CVAR_MSPM07S2_CONFIG := PRC_PAR_COMPANY_CODE ;
                      END IF ;
                      IF ( NOT( BFOUND_MSPM07S2_COMPANY ) AND NOT( BFOUND_MSPM07S2_TODOS ) ) THEN
                           --
                           -- N?O HA PARAMETRIZAC?O DA CLASSIFICAC?O FISCAL DO ITEM
                           --
                           MSAFI_MSFSY_GENERATE_LOG.PRC_LOG_MSG
                           (
                             1,
                             'SAFX07 ( SAIDA ) : PARAMETRIZAC?O DOS ITENS POR "TIPO FISCAL" N?O EXISTENTE..., FAVOR AVERIGUAR...'
                           ) ;
                           MSAFI_MSFSY_GENERAL.BVAR_GLOBAL_ERRORS_FOUND := TRUE ;
                           PRC_PAR_ERRORS_OCURRED := 1 ;
                      ELSE
                           --
                           -- INICIAR A LEITURA DOS DADOS
                           --
                           PRC_07S_LEITURA ;
                      END IF ;
                 ELSE
                      --
                      -- CLASSIFICAC?O FISCAL DO ITEM CONFIGURADA POR
                      -- CFOP
                      --
                      OPEN CRS_MSPM07S3( PRC_PAR_COMPANY_CODE, NULL ) ;
                      FETCH CRS_MSPM07S3 INTO RECORD_MSPM07S3 ;
                      BFOUND_MSPM07S3_COMPANY := CRS_MSPM07S3%FOUND ;
                      CLOSE CRS_MSPM07S3 ;
                      IF ( NOT( BFOUND_MSPM07S3_COMPANY ) ) THEN
                           OPEN CRS_MSPM07S3( 'TODOS', NULL ) ;
                           FETCH CRS_MSPM07S3 INTO RECORD_MSPM07S3 ;
                           BFOUND_MSPM07S3_TODOS := CRS_MSPM07S3%FOUND ;
                           CLOSE CRS_MSPM07S3 ;
                           IF ( BFOUND_MSPM07S3_TODOS ) THEN
                                --
                                -- PARAMETRIZAC?O POR CFOP ( ORGANIZAC?O )
                                --
                                CVAR_MSPM07S3_CONFIG := 'TODOS' ;
                           END IF ;
                      ELSE
                           --
                           -- PARAMETRIZAC?O POR CFOP ( EMPRESA )
                           --
                           CVAR_MSPM07S3_CONFIG := PRC_PAR_COMPANY_CODE ;
                      END IF ;
                      IF ( NOT( BFOUND_MSPM07S3_COMPANY ) AND NOT( BFOUND_MSPM07S3_TODOS ) ) THEN
                           --
                           -- N?O HA PARAMETRIZAC?O DA CLASSIFICAC?O FISCAL DO ITEM
                           --
                           MSAFI_MSFSY_GENERATE_LOG.PRC_LOG_MSG
                           (
                             1,
                             'SAFX07 ( SAIDA ) : PARAMETRIZAC?O DOS ITENS POR "CFOP" N?O EXISTENTE..., FAVOR AVERIGUAR...'
                           ) ;
                           MSAFI_MSFSY_GENERAL.BVAR_GLOBAL_ERRORS_FOUND := TRUE ;
                           PRC_PAR_ERRORS_OCURRED := 1 ;
                      ELSE
                           --
                           -- INICIAR A LEITURA DOS DADOS
                           --
                           CVAR_ERRO_GLOBAL := NULL ;
                           CVAR_ERRO_GLOBAL := '07S-009 : PROCESSANDO ROTINA DE LEITURA' ;
                           PRC_07S_LEITURA ;
                      END IF ; -- AVERIGUAC?O DA PARAMETRIZAC?O POR CFOP
                 END IF ; -- VERIFICAC?O DA CLASSIFICAC?O FISCAL DO ITEM
            END IF ; -- VERIFICAC?O DA EXISTENCIA DA PARAMETRIZAC?O DA CLASSIFICAC?O FISCAL DO ITEM
       END IF ; -- PREENCHIMENTO INVALIDO DA PARAMETRIZAC?O DOS DADOS PROVENIENTES DO "AR"
  END IF ; -- PARAMETRIZAC?O DOS DADOS PROVENIENTES DO "AR"

EXCEPTION
  WHEN OTHERS THEN
       MSAFI_MSFSY_GENERAL.CVAR_GLOBAL_RECORDS_REJECTS := -1 ;
       CVAR_SELECT_ERROR_CODE := SQLCODE ;
       CVAR_SELECT_ERROR_MESS := SQLERRM ;
       -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
       -- JOGANDO VALOR NEGATIVOS PARA A VARIAVEL DE CONTAGEM DE REGISTROS NEGATIVOS
       -- PARA QUE INDIQUE QUE O PROCEDIMENTO ATUAL N?O PODE SER EXECUTADO DEVIDO A
       -- FALHAS ENCONTRADAS NO SELECT...
       -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
       MSAFI_MSFSY_GENERATE_LOG.PRC_LOG_MSG
         ( 1,
           'SAFX07 ( SAIDAS ) PROCESSADA COM ERRO : '
           ||
           CVAR_ERRO_GLOBAL
           ||
           CHR( 13 )
           ||
           'ERRO ORACLE : '
           ||
           RTRIM( LTRIM( TO_CHAR( CVAR_SELECT_ERROR_CODE ) ) )
           ||
           ' - '
           ||
           SUBSTR( CVAR_SELECT_ERROR_MESS, 1, 50 )
         ) ;
END;
/
