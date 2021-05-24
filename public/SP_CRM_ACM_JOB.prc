CREATE OR REPLACE PROCEDURE SP_CRM_ACM_JOB(P_DATA DATE) IS
BEGIN

  BEGIN
    insert into TB_LOG_SP_CRM_ACM_JOB
    values
      (sysdate, 'inicio SP_SORT_VOLUME_ACUMULADO');
    commit;

    SP_SORT_VOLUME_ACUMULADO;

    SP_ENVIA_EMAIL('oracle@braspress.com.br',
                   'ti.bruno@braspress.com.br',
                   NULL,
                   'JOB (SP_SORT_VOLUME_ACUMULADO) ',
                   'Job realizado com sucesso! Termino : ' ||
                   TO_CHAR(SYSDATE, 'dd/mm/rr hh24:mi:ss'));



    insert into TB_LOG_SP_CRM_ACM_JOB
    values
      (sysdate, 'Fim SP_SORT_VOLUME_ACUMULADO');
    commit;

  EXCEPTION
    WHEN OTHERS THEN
      SP_ENVIA_EMAIL('oracle@braspress.com.br',
                     'ti.bruno@braspress.com.br',
                     NULL,
                     'JOB (SP_SORT_VOLUME_ACUMULADO) ',
                     'ATENCAO: Ocorreu um erro na execucao deste JOB! Termino : ' ||
                     TO_CHAR(SYSDATE, 'dd/mm/rr hh24:mi:ss') || ' ERRO: ' ||
                     SQLERRM);
  END;

  BEGIN

    insert into TB_LOG_SP_CRM_ACM_JOB
    values
      (sysdate, 'Inicio SP_GRAVA_TAXAS_JOB');
    commit;

    SP_GRAVA_TAXAS_JOB(DT => P_DATA);

    insert into TB_LOG_SP_CRM_ACM_JOB
    values
      (sysdate, 'FIM SP_GRAVA_TAXAS_JOB');
    commit;

  EXCEPTION
    WHEN OTHERS THEN
      SP_ENVIA_EMAIL('oracle@braspress.com.br',
                     'ti.bruno@braspress.com.br',
                     NULL,
                     'JOB (SP_GRAVA_TAXAS_JOB) ',
                     'ATENCAO: Ocorreu um erro na execucao deste JOB! Termino : ' ||
                     TO_CHAR(SYSDATE, 'dd/mm/rr hh24:mi:ss') || ' ERRO: ' ||
                     SQLERRM);
  END;

  BEGIN

    insert into TB_LOG_SP_CRM_ACM_JOB
    values
      (sysdate, 'Inicio PCK_CRM_ACM.SP_GERA_ACM_CRM SP_GRAVA_TAXAS_JOB');
    commit;

    PCK_CRM_ACM.SP_GERA_ACM_CRM(DATA_BASE => P_DATA);

    SP_ENVIA_EMAIL('oracle@braspress.com.br',
                   'ti.bruno@braspress.com.br',
                   NULL,
                   'JOB (SP_CRM_ACM_JOB) ',
                   'Job realizado com sucesso! Termino : ' ||
                   TO_CHAR(SYSDATE, 'dd/mm/rr hh24:mi:ss'));

    insert into TB_LOG_SP_CRM_ACM_JOB
    values
      (sysdate, 'Fim PCK_CRM_ACM.SP_GERA_ACM_CRM SP_GRAVA_TAXAS_JOB');
    commit;

  EXCEPTION
    WHEN OTHERS THEN

      SP_ENVIA_EMAIL('oracle@braspress.com.br',
                     'ti.bruno@braspress.com.br',
                     NULL,
                     'JOB (SP_CRM_ACM_JOB)',
                     'ATENCAO: Ocorreu um erro na execucao deste JOB! Termino : ' ||
                     TO_CHAR(SYSDATE, 'dd/mm/rr hh24:mi:ss') || ' ERRO: ' ||
                     SQLERRM);
  END;

  /*Solicitação para retirada de rotina para controle de negocio CH200925398
    BEGIN

    insert into TB_LOG_SP_CRM_ACM_JOB
    values
      (sysdate, 'Inicio SP_CRM_CONTROLE_NEG_AUTOMATICO P_MODAL => R');
    commit;

    SP_CRM_CONTROLE_NEG_AUTOMATICO(DATA_BASE => P_DATA - 1, P_MODAL => 'R'); --RODO

    insert into TB_LOG_SP_CRM_ACM_JOB
    values
      (sysdate, 'Fim SP_CRM_CONTROLE_NEG_AUTOMATICO P_MODAL => R');
    commit;

    insert into TB_LOG_SP_CRM_ACM_JOB
    values
      (sysdate, 'Inicio SP_CRM_CONTROLE_NEG_AUTOMATICO P_MODAL => A');
    commit;

    SP_CRM_CONTROLE_NEG_AUTOMATICO(DATA_BASE => P_DATA - 1, P_MODAL => 'A'); --AERO

    insert into TB_LOG_SP_CRM_ACM_JOB
    values
      (sysdate, 'Fim SP_CRM_CONTROLE_NEG_AUTOMATICO P_MODAL => A');
    commit;

  EXCEPTION
    WHEN OTHERS THEN

      SP_ENVIA_EMAIL('oracle@braspress.com.br',
                     'ti.bruno@braspress.com.br',
                     NULL,
                     'JOB (SP_CRM_CONTROLE_NEG_AUTOMATICO)',
                     'ATENCAO: Ocorreu um erro na execucao deste JOB! Termino : ' ||
                     TO_CHAR(SYSDATE, 'dd/mm/rr hh24:mi:ss') || ' ERRO: ' ||
                     SQLERRM);
  END;*/

END;
/
