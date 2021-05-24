CREATE OR REPLACE PROCEDURE SP_CRM_GERA_COMISSAO_GT_APOIO(P_ID_FILIAL       NUMBER,
                                                          P_ID_TP_DOCUMENTO VARCHAR2,
                                                          P_ID_DOCUMENTO    NUMBER,
                                                          P_VALOR_TITULO    NUMBER,
                                                          P_CIF_FOB         CHAR,
                                                          P_DT_OCORRENCIA   DATE,
                                                          P_ID_TAR_MODAL    CHAR,
                                                          P_ID_CLI_BASICO   NUMBER) IS

  V_PERC_COMISSAO     NUMBER;
  V_VLR_COMISSAO      NUMBER;
  V_PERC_COMISSAO_CIF NUMBER;
  V_PERC_COMISSAO_FOB NUMBER;
  V_INSERE_REG        CHAR(1);
  V_COMIS_APOIO       CHAR(1);

BEGIN

  FOR USERS IN (SELECT DISTINCT U.ID_COM_USUARIO, U.ID_USUARIO, U.ID_FUNCAO
                  FROM COM_TP_GESTOR G, COM_USUARIO U
                 WHERE U.USUCOM_ATIVO = 'S'
                   AND G.ID_COM_USUARIO = U.ID_COM_USUARIO
                   AND U.ID_TAR_MODAL = P_ID_TAR_MODAL) LOOP

    V_INSERE_REG := 'N';
    V_PERC_COMISSAO_CIF := 0;
    V_PERC_COMISSAO_FOB := 0;
    BEGIN
      SELECT F.CRM_FUN_COMIS_APOIO
        INTO V_COMIS_APOIO
        FROM TOOLDBA.CRM_FUNCAO F
       WHERE F.ID_CRM_FUNCAO = USERS.ID_FUNCAO;
    END;

    IF (V_COMIS_APOIO = 'S') AND (P_ID_FILIAL > 0) THEN
      BEGIN
        -- ** BUSCA VALOR POR APOIO **
        SELECT NVL(GF.TPGF_COMISSAO_CIF_APOIO, 0),
               NVL(GF.TPGF_COMISSAO_FOB_APOIO, 0)
          INTO V_PERC_COMISSAO_CIF, V_PERC_COMISSAO_FOB
          FROM COM_TP_GESTOR G, COM_USUARIO U, COM_TP_GESTOR_FILIAL GF
         WHERE U.USUCOM_ATIVO = 'S'
           AND U.ID_COM_USUARIO = USERS.ID_COM_USUARIO
           AND G.ID_COM_USUARIO = U.ID_COM_USUARIO
           AND GF.ID_COM_USUARIO = G.ID_COM_USUARIO
           AND GF.ID_FILIAL = P_ID_FILIAL
           AND U.ID_TAR_MODAL = P_ID_TAR_MODAL;
           
      IF (V_PERC_COMISSAO_CIF > 0) OR (V_PERC_COMISSAO_FOB >0) THEN
         V_INSERE_REG := 'S';
      END IF;
      EXCEPTION
        WHEN OTHERS THEN
          V_PERC_COMISSAO_CIF := 0;
          V_PERC_COMISSAO_FOB := 0;
          V_INSERE_REG        := 'N';
      END;
    END IF;

    IF V_INSERE_REG = 'S' THEN

      IF P_CIF_FOB = 'C' THEN
        V_PERC_COMISSAO := V_PERC_COMISSAO_CIF; --USERS.TPGF_COMISSAO_CIF;
      ELSIF P_CIF_FOB = 'F' THEN
        V_PERC_COMISSAO := V_PERC_COMISSAO_FOB; --USERS.TPGF_COMISSAO_FOB;
      END IF;

      V_VLR_COMISSAO := P_VALOR_TITULO * V_PERC_COMISSAO / 100;

      COM_COMISSAO_INSERE_CC(V_ID_COM_USUARIO       => USERS.ID_COM_USUARIO,
                             V_ID_USUARIO           => USERS.ID_USUARIO,
                             V_ID_FUNCAO            => USERS.ID_FUNCAO,
                             V_COMCC_VLR_REFERENCIA => P_VALOR_TITULO,
                             V_COMCC_PERC_COMISSAO  => V_PERC_COMISSAO,
                             V_COMCC_VLR_COMISSAO   => V_VLR_COMISSAO,
                             V_COMCC_TP_DOCUMENTO   => P_ID_TP_DOCUMENTO,
                             V_COMCC_ID_DOCUMENTO   => P_ID_DOCUMENTO,
                             V_COMCC_CIF_FOB        => P_CIF_FOB,
                             V_ID_COM_TIPO_COMISSAO => 'AP',
                             V_COMCC_NIVEL          => 0,
                             V_ID_USUARIO_VENDEDOR  => NULL,
                             V_ID_TAR_MODAL         => P_ID_TAR_MODAL,
                             V_ID_EMPRESA           => 5,
                             V_ID_COM_CARTEIRA      => NULL,
                             V_ID_FILIAL            => P_ID_FILIAL,
                             V_DT_OCORRENCIA        => P_DT_OCORRENCIA,
                             V_ID_CLI_BASICO        => P_ID_CLI_BASICO,
                             V_COMCC_BLOQUEADO      => 'N');

    END IF;

  END LOOP;

END;
