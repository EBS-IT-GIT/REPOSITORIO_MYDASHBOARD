create or replace 
package                          apps.klass_integracao authid definer IS

/************************************************************************************
   Function que faz a limpeza dos processos que ficaram pendentes por problema no
   processamento
*************************************************************************************/

FUNCTION retorna_acao_pendencia RETURN VARCHAR2;


/************************************************************************************
   Function que retorna o retorna_code_combination_id de uma determinada combinação
   de contas contábeis
*************************************************************************************/

FUNCTION retorna_code_combination_id(p_combinacao IN VARCHAR2, p_erro OUT VARCHAR2) RETURN number;



/************************************************************************************
   Function que ajusta o registro de integração que será enviado para a OPEN 
   de acordo com especificidades do cliente
*************************************************************************************/
PROCEDURE customiza_por_cliente(r_mtl_system_items_interface   IN OUT mtl_system_items_interface%rowtype,
                                 organization_id                IN NUMBER, 
                                 item_gabarito                  IN VARCHAR2);
                                 
/************************************************************************************
   Function que retorna a versão compilada da package
*************************************************************************************/

FUNCTION retorna_versao RETURN VARCHAR2;


/********************************************************************************************
Função para setar a responsabilidade que irá rodar o concorrente
*********************************************************************************************/

FUNCTION seta_responsabilidade RETURN VARCHAR2;


/**********************************************************************************************
   Função responsável por enviar e-mail dos erros de processamento em algum ponto do concorrente
***********************************************************************************************/

FUNCTION envia_email(p_mensagem         IN VARCHAR2
                      ,p_assunto_inclusao IN VARCHAR2
                      ,p_email_klassmatt  IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 ;


/****************************************************************************************************
   Função que verifica se existe algum concorrente de integração (inclusão/alteração de item)
   rodando, ou seja, com status P na tabela de controle. Se possuir, a tabela de concorrentes
   do ebs deve ser acessada para certificar se esse concorrente está com status P. Se estiver, um erro
   deverá ser disparado, pois somente um concorrente de integração poderá ser rodado por vez.
*****************************************************************************************************/

FUNCTION verifica_integracao_pendente RETURN VARCHAR2;

/****************************************************************************
   Procedure que altera a tabela de controle
*****************************************************************************/
PROCEDURE altera_tabela_controle(p_mensagem IN VARCHAR2) ;

/***************************************************************************
   Função que executa o concorrente NATIVO de inclusão ou alteração de itens
****************************************************************************/

FUNCTION executa_concorrente( p_tipo_operacao  IN VARCHAR2
                             ,p_request_id    OUT NUMBER) RETURN VARCHAR2;


/***************************************************************************
   Função que retorna o status do concorrente mestre se rodou ok
****************************************************************************/

FUNCTION status_concorrente(p_request_id IN NUMBER)
                 RETURN VARCHAR2;


/*************************************************************
   Procedure para gerar o log a ser gravado passo a passo
*************************************************************/

PROCEDURE gera_log_tabela(p_id_processamento       IN NUMBER
                         ,p_mensagem               IN VARCHAR2
                         ,p_data_processamento     IN DATE
                         ,p_status                 IN VARCHAR2
                         ,p_nome_concorrente       IN VARCHAR2
                         ,p_debug                  IN VARCHAR2);


  /**************************************************************
   Função que faz a integração do klassmatt com o ebs em relação
   aos itens e sua referência com os itens dos fornecedores
  ***************************************************************/

  FUNCTION manutencao_item_fornecedor (p_id_item_klassmatt       IN VARCHAR2
                                      ,p_codigo_item             IN VARCHAR2
                                      ,p_tipo_chamada            IN VARCHAR2 )  -- I - interna   E - externa
                                       RETURN VARCHAR2;
                     
/**************************************************************
   Função que faz a integração do klassmatt com o ebs em relação
   aos anexos
***************************************************************/

 FUNCTION manutencao_item_anexos(p_id_item_klassmatt       IN VARCHAR2,
                                 p_codigo_item             IN VARCHAR2,
                                p_tipo_chamada            IN VARCHAR2 )  -- I - interna   E - externa
                                       RETURN VARCHAR2;
									   
/**************************************************************
   Função que faz a integração do klassmatt com o ebs em relação
   aos itens Relacionados MTL_RELATED_ITEMS
  ***************************************************************/

 FUNCTION manutencao_item_related(p_id_item_klassmatt       IN VARCHAR2,
                                  p_codigo_item             IN VARCHAR2,
                                  p_tipo_chamada            IN VARCHAR2 )  -- I - interna   E - externa
                                       RETURN VARCHAR2;
                                       
 /*************************************************************
   Function que faz a verificação de tudo que está com status S na tabela
   de controle, ou seja, que rodou nessa aplicação. Todas as interfaces
   geradas que estão com erros, deverão ser retornadas ao klassmatt e
   enviar e-mail cadastrado em uma profile.
  *************************************************************/

  FUNCTION verifica_status_interfaces (p_parametro  IN VARCHAR2) RETURN VARCHAR2;

/*************************************************************
   Procedure de controle de execução dos concorrentes
*************************************************************/

FUNCTION controle_concurrent (p_debug       IN VARCHAR2
                               ,p_envia_email IN VARCHAR2)  --- 'S' ou 'N'
                 RETURN VARCHAR2 ;

/*******************************************************************************************
   Procedure que faz a inclusão do item da tabela de integração na interface de itens
   e categorias de itens, indicando o tipo de operação a ser realizada : incluão ou alteração
********************************************************************************************/

PROCEDURE concorrente_integracao( msg_retorno OUT VARCHAR2);


--PROCEDURE concorrente_validacao( msg_retorno OUT VARCHAR2 );


/*******************************************************************************************
   Function que faz a inclusão do item na interface de item e categoria de item
********************************************************************************************/

FUNCTION inclusao_item_interface ( v_rowid             IN  VARCHAR2
                                  ,master_organization IN VARCHAR2
                                  ,v_codigo_item       IN  VARCHAR2)  RETURN VARCHAR2;

/*******************************************************************************************
   Function que faz a inclusão do item na interface de item e categoria de item a partir do
   item gabarito
  ********************************************************************************************/

  FUNCTION inclusao_item_gabarito ( v_rowid             IN  VARCHAR2
                                    ,master_organization IN  VARCHAR2
                                    ,v_codigo_item       IN  VARCHAR2 )
  RETURN VARCHAR2;

/*******************************************************************************************
   Function que faz a alteração do item na interface de item e categoria de item tipo INV_AG
********************************************************************************************/

FUNCTION alteracao_item_interface ( v_rowid  IN  VARCHAR2
                                   ,master_organization IN VARCHAR2)  RETURN VARCHAR2;

/****************************************************************************
 Procedure de limpeza das tabelas - ela roda a partir de outro concorrente
*****************************************************************************/

PROCEDURE exclui_tab_int_klassmatt (p_set_process_id IN NUMBER);

/****************************************************************************
 Função de limpeza das tabelas - exclui registros de erro de processamentos
 anteriores 
*****************************************************************************/

FUNCTION exclui_erros_interf RETURN VARCHAR2;

/****************************************************************************
   Função que retorna se o item ebs está ativo ou não para a organização mestre
   Usada externamente pelo klassmatt
  *****************************************************************************/

  FUNCTION status_item_mestre(p_segment1 IN  VARCHAR2
                             ,p_msg_erro OUT VARCHAR2) RETURN VARCHAR2;

/****************************************************************************
   Função que retorna as OIs pertencentes a um item
*****************************************************************************/

FUNCTION retorna_oi_item_ebs ( p_segment1    IN VARCHAR2
                              ,p_lista_oi   OUT VARCHAR2
                              ) RETURN VARCHAR2;

/****************************************************************************
   Função que retorna o nome e o código de uma OI
*****************************************************************************/

FUNCTION retorna_dados_oi ( p_organization_id    IN NUMBER
                           ,p_organization_name OUT VARCHAR2
                           ,p_organization_code OUT VARCHAR2
                           ) RETURN VARCHAR2;

/****************************************************************************
   Função que retorna as linguagens ativas no EBS
*****************************************************************************/

FUNCTION retorna_linguagens_ebs ( p_linguagem_desc   OUT VARCHAR2
                                 ,p_linguagem_code   OUT VARCHAR2
                                 ,p_linguagem_type   OUT VARCHAR2
                                 ) RETURN VARCHAR2;

/****************************************************************
   Função que altera o item na mtl_system_items_tl
  ****************************************************************/
  FUNCTION altera_desc_linguagem ( p_inventory_item_id  IN NUMBER
                                  ,p_description        IN VARCHAR2
                                  ,p_long_description   IN VARCHAR2
                                  ,p_organization_id    IN NUMBER
                                  ) RETURN VARCHAR2;

/****************************************************************************
   Função que retorna as UOs ativas no EBS
*****************************************************************************/

FUNCTION retorna_uo_ebs ( p_id_uo   OUT VARCHAR2
                         ) RETURN VARCHAR2;


/****************************************************************************
   Função que retorna o nome de uma UO do EBS e suas OIs.
*****************************************************************************/

FUNCTION retorna_dados_uo_ebs ( p_id_uo       IN  NUMBER
                               ,p_nome_uo     OUT VARCHAR2
                               ,p_relacao_oi  OUT VARCHAR2
                              ) RETURN VARCHAR2;

end klass_integracao;
/

create or replace 
package body      apps.klass_integracao IS

  erro                        exception;
  v_sequencia_processamento   NUMBER;
  v_nome_concorrente          VARCHAR2(100);
  v_debug                     VARCHAR2(10);
  v_linha                     NUMBER DEFAULT 0;  --- total de processamento
  venvia_email                VARCHAR2(30);
  --
  vid_item_klassmatt          NUMBER;
  vempresa_integracao         VARCHAR2(100);
  vid_organizacao_mestre      NUMBER;
  vcreate_organizations       VARCHAR2(100);
  vgrava_log_open_interface   VARCHAR2(100);
  g_nls_language              VARCHAR2(3000);
  
  
/****************************************************************
   Função que faz a limpeza na interface de itens do EBS dos itens
   a serem integrados que já possuem registros integrados
   nessas tabelas.   
*****************************************************************/

  FUNCTION exclui_erros_interf RETURN VARCHAR2
    IS PRAGMA AUTONOMOUS_TRANSACTION;
    
  BEGIN
   
    ---
    
    DELETE FROM mtl_system_items_interface
        WHERE item_number iN( select codigo from klass_integracao_ebs where status =1);
        
        
    DELETE FROM mtl_item_categories_interface
    WHERE item_number iN( select codigo from klass_integracao_ebs where status =1);  
       
 
    DELETE FROM mtl_item_revisions_interface
        WHERE item_number iN( select codigo from klass_integracao_ebs where status =1);
    
    --------
    COMMIT;
    --------
      
    RETURN('OK');
    
    
    EXCEPTION

     WHEN OTHERS THEN
         RETURN('Erro funcao exclui_erros_interf - ' || SQLERRM);

  END;

/************************************************************************************
   Function que faz a limpeza dos processos que ficaram pendentes por problema no
   processamento
*************************************************************************************/

FUNCTION retorna_acao_pendencia RETURN VARCHAR2 IS

  vcont        NUMBER;
  vretorno     VARCHAR2(3000);

BEGIN

  --> verifica se está executando o concorrente ebs de manutenção de itens
   --> Se existir registros não pode limpar as tabelas de integração, pois tem alguma coisa rodando

  SELECT COUNT(1)
    INTO vcont
    FROM fnd_concurrent_requests    fcr
        ,fnd_concurrent_programs    fcp
   WHERE fcp.concurrent_program_id   = fcr.concurrent_program_id
     AND fcp.concurrent_program_name = 'INCOIN'
     AND fcr.phase_code <> 'C';

   IF vcont > 0 THEN

       ---> Acessa a interface para os status pendentes dos rodados pelo klass
       /*
       PROCESS_FLAG BOM_INTERFACE_STATUS MFG_LOOKUPS
            1 Awaiting validation
            2 Validation started
            3 Validation failed
            4 Validation succeeded
            5 Processing started
            6 Processing failed
            7 Processing succeeded
       */

      SELECT COUNT(*)
        INTO vcont
        FROM mtl_system_items_interface
       WHERE set_process_id IN (60,70)
         AND process_flag   IN (2,4,5);

       IF vcont > 0 THEN
            vretorno := 'Existe integracao NATIVA pendente rodando no EBS - concorrente INCOIN.';
       END IF;

   END IF;


   IF vretorno IS NULL THEN

         ---> altera para 1 na tabela de integração de tudo que está na tabela de controle como pendente

         UPDATE klass_integracao_ebs
            SET status = 1
           WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                          FROM klass_integracao_controle
                                         WHERE status_execucao NOT IN ('C','E')
                                      );

          UPDATE klass_integracao_oi_item
            SET status = 1
           WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                          FROM klass_integracao_controle
                                         WHERE status_execucao NOT IN ('C','E')
                                      );

          UPDATE klass_integracao_linguagem
            SET status = 1
           WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                          FROM klass_integracao_controle
                                         WHERE status_execucao NOT IN ('C','E')
                                      );


          vretorno := 'Existe processamento pendente - Total de Linhas alteradas tabela klass_integracao_ebs para status = 1 : ' || SQL%ROWCOUNT;

         ---> limpa a tabela de controle das pendencias

         DELETE FROM klass_integracao_controle
                 WHERE status_execucao NOT IN ('C','E');


         vretorno := vretorno || ' -- Total de Linhas excluidas tabela klass_integracao_controle com status C e E : ' || SQL%ROWCOUNT;

         ---> Exclui registros da tabela de interface de itens que estão pendentes e parados

         DELETE
           FROM mtl_system_items_interface
          WHERE set_process_id IN (60,70)
            AND process_flag   IN (2,4,5);

         --------
         COMMIT;
         --------

   END IF;

   RETURN(vretorno);


END retorna_acao_pendencia;

/************************************************************************************
   Function que retorna o retorna_code_combination_id de uma determinada combinação
   de contas contábeis
*************************************************************************************/

FUNCTION retorna_code_combination_id(p_combinacao IN VARCHAR2, p_erro OUT VARCHAR2) RETURN NUMBER IS
  l_ccid    NUMBER;
  l_msg     varchar2(20000);
  l_status  varchar2(1) := '';
BEGIN

   -- xxesp_gl_create_account_prc(p_combinacao, l_ccid, l_msg, l_status);
  
  if(l_status = 'S')then
    p_erro := '';
    return l_ccid;
  else
    p_erro := l_msg;
    return 0;
  end if;
  
END retorna_code_combination_id;

/************************************************************************************
   Function que retorna a versão compilada da package
*************************************************************************************/

FUNCTION retorna_versao RETURN VARCHAR2 IS

  vdata_comp       VARCHAR2(100);

BEGIN

  SELECT to_char(last_ddl_time,'dd/mm/yyyy hh24:mi:ss')
    INTO vdata_comp
    FROM Dba_Objects
   WHERE object_name = 'KLASS_INTEGRACAO'
     AND object_type = 'PACKAGE BODY';


  RETURN('Versão 6.64 do aplicativo em ' || to_char(SYSDATE,'dd/mm/yyyy hh24:mi:ss') || ' hrs. Compilado em ' ||
         vdata_comp || ' hrs.' );

END;

/*************************************************************************************
  Function que recebe o id do item e sua organização e retorna o registro de cópia desse
  item referente a tabela mtl_system_items_interface
*************************************************************************************/

FUNCTION tab_mtl_system_items_interface
           ( p_inventory_item_id             IN  mtl_system_items_b.inventory_item_id%TYPE
            ,p_organization_id               IN  mtl_system_items_b.organization_id%TYPE
            ,p_mtl_system_items_interface    OUT mtl_system_items_interface%ROWTYPE)
  RETURN VARCHAR2 IS


BEGIN


   FOR r1 IN (
               SELECT *
                 FROM mtl_system_items_b
                WHERE organization_id   = p_organization_id
                  AND inventory_item_id = p_inventory_item_id
             )
   LOOP

      p_mtl_system_items_interface.divergence                      := r1.divergence;
      p_mtl_system_items_interface.config_orgs                     := r1.config_orgs;
      p_mtl_system_items_interface.config_match                    := r1.config_match;
      p_mtl_system_items_interface.global_attribute11              := r1.global_attribute11;
      p_mtl_system_items_interface.global_attribute12              := r1.global_attribute12;
      p_mtl_system_items_interface.global_attribute15              := r1.global_attribute15;
      p_mtl_system_items_interface.global_attribute13              := r1.global_attribute13;
      p_mtl_system_items_interface.global_attribute16              := r1.global_attribute16;
      p_mtl_system_items_interface.global_attribute14              := r1.global_attribute14;
      p_mtl_system_items_interface.global_attribute17              := r1.global_attribute17;
      p_mtl_system_items_interface.global_attribute18              := r1.global_attribute18;
      p_mtl_system_items_interface.global_attribute19              := r1.global_attribute19;
      p_mtl_system_items_interface.global_attribute20              := r1.global_attribute20;
      p_mtl_system_items_interface.auto_created_config_flag        := r1.auto_created_config_flag;
      p_mtl_system_items_interface.item_type                       := r1.item_type;
      p_mtl_system_items_interface.model_config_clause_name        := r1.model_config_clause_name;
      p_mtl_system_items_interface.ship_model_complete_flag        := r1.ship_model_complete_flag;
      p_mtl_system_items_interface.mrp_planning_code               := r1.mrp_planning_code;
      p_mtl_system_items_interface.return_inspection_requirement   := r1.return_inspection_requirement;
      p_mtl_system_items_interface.ato_forecast_control            := r1.ato_forecast_control;
      p_mtl_system_items_interface.release_time_fence_code         := r1.release_time_fence_code;
      p_mtl_system_items_interface.release_time_fence_days         := r1.release_time_fence_days;
      p_mtl_system_items_interface.container_item_flag             := r1.container_item_flag;
      p_mtl_system_items_interface.vehicle_item_flag               := r1.vehicle_item_flag;
      p_mtl_system_items_interface.maximum_load_weight             := r1.maximum_load_weight;
      p_mtl_system_items_interface.minimum_fill_percent            := r1.minimum_fill_percent;
      p_mtl_system_items_interface.container_type_code             := r1.container_type_code;
      p_mtl_system_items_interface.internal_volume                 := r1.internal_volume;
      p_mtl_system_items_interface.wh_update_date                  := r1.wh_update_date;
      p_mtl_system_items_interface.product_family_item_id          := r1.product_family_item_id;
      p_mtl_system_items_interface.purchasing_tax_code             := r1.purchasing_tax_code;
      p_mtl_system_items_interface.overcompletion_tolerance_type   := r1.overcompletion_tolerance_type;
      p_mtl_system_items_interface.overcompletion_tolerance_value  := r1.overcompletion_tolerance_value;
      p_mtl_system_items_interface.effectivity_control             := r1.effectivity_control;
      p_mtl_system_items_interface.global_attribute_category       := r1.global_attribute_category;
      p_mtl_system_items_interface.global_attribute1               := r1.global_attribute1;
      p_mtl_system_items_interface.global_attribute2               := r1.global_attribute2;
      p_mtl_system_items_interface.global_attribute3               := r1.global_attribute3;
      p_mtl_system_items_interface.global_attribute4               := r1.global_attribute4;
      p_mtl_system_items_interface.global_attribute5               := r1.global_attribute5;
      p_mtl_system_items_interface.global_attribute6               := r1.global_attribute6;
      p_mtl_system_items_interface.global_attribute7               := r1.global_attribute7;
      p_mtl_system_items_interface.global_attribute8               := r1.global_attribute8;
      p_mtl_system_items_interface.global_attribute9               := r1.global_attribute9;
      p_mtl_system_items_interface.global_attribute10              := r1.global_attribute10;
      p_mtl_system_items_interface.over_shipment_tolerance         := r1.over_shipment_tolerance;
      p_mtl_system_items_interface.under_shipment_tolerance        := r1.under_shipment_tolerance;
      p_mtl_system_items_interface.over_return_tolerance           := r1.over_return_tolerance;
      p_mtl_system_items_interface.under_return_tolerance          := r1.under_return_tolerance;
      p_mtl_system_items_interface.equipment_type                  := r1.equipment_type;
      p_mtl_system_items_interface.recovered_part_disp_code        := r1.recovered_part_disp_code;
      p_mtl_system_items_interface.defect_tracking_on_flag         := r1.defect_tracking_on_flag;
      p_mtl_system_items_interface.usage_item_flag                 := r1.usage_item_flag;
      p_mtl_system_items_interface.event_flag                      := r1.event_flag;
      p_mtl_system_items_interface.electronic_flag                 := r1.electronic_flag;
      p_mtl_system_items_interface.downloadable_flag               := r1.downloadable_flag;
      p_mtl_system_items_interface.vol_discount_exempt_flag        := r1.vol_discount_exempt_flag;
      p_mtl_system_items_interface.coupon_exempt_flag              := r1.coupon_exempt_flag;
      p_mtl_system_items_interface.comms_nl_trackable_flag         := r1.comms_nl_trackable_flag;
      p_mtl_system_items_interface.asset_creation_code             := r1.asset_creation_code;
      p_mtl_system_items_interface.comms_activation_reqd_flag      := r1.comms_activation_reqd_flag;
      p_mtl_system_items_interface.orderable_on_web_flag           := r1.orderable_on_web_flag;
      p_mtl_system_items_interface.back_orderable_flag             := r1.back_orderable_flag;
      p_mtl_system_items_interface.web_status                      := r1.web_status;
      p_mtl_system_items_interface.indivisible_flag                := r1.indivisible_flag;
      p_mtl_system_items_interface.organization_id                 := r1.organization_id;
      p_mtl_system_items_interface.last_update_date                := r1.last_update_date;
      p_mtl_system_items_interface.last_updated_by                 := r1.last_updated_by;
      p_mtl_system_items_interface.creation_date                   := r1.creation_date;
      p_mtl_system_items_interface.created_by                      := r1.created_by;
      p_mtl_system_items_interface.last_update_login               := r1.last_update_login;
      p_mtl_system_items_interface.summary_flag                    := r1.summary_flag;
      p_mtl_system_items_interface.enabled_flag                    := r1.enabled_flag;
      p_mtl_system_items_interface.start_date_active               := r1.start_date_active;
      p_mtl_system_items_interface.end_date_active                 := r1.end_date_active;
      p_mtl_system_items_interface.description                     := r1.description;
      p_mtl_system_items_interface.buyer_id                        := r1.buyer_id;
      p_mtl_system_items_interface.accounting_rule_id              := r1.accounting_rule_id;
      p_mtl_system_items_interface.invoicing_rule_id               := r1.invoicing_rule_id;
      p_mtl_system_items_interface.segment1                        := r1.segment1;
      p_mtl_system_items_interface.segment2                        := r1.segment2;
      p_mtl_system_items_interface.segment3                        := r1.segment3;
      p_mtl_system_items_interface.segment4                        := r1.segment4;
      p_mtl_system_items_interface.segment5                        := r1.segment5;
      p_mtl_system_items_interface.segment6                        := r1.segment6;
      p_mtl_system_items_interface.segment7                        := r1.segment7;
      p_mtl_system_items_interface.segment8                        := r1.segment8;
      p_mtl_system_items_interface.segment9                        := r1.segment9;
      p_mtl_system_items_interface.segment10                       := r1.segment10;
      p_mtl_system_items_interface.segment11                       := r1.segment11;
      p_mtl_system_items_interface.segment12                       := r1.segment12;
      p_mtl_system_items_interface.segment13                       := r1.segment13;
      p_mtl_system_items_interface.segment14                       := r1.segment14;
      p_mtl_system_items_interface.segment15                       := r1.segment15;
      p_mtl_system_items_interface.segment16                       := r1.segment16;
      p_mtl_system_items_interface.segment17                       := r1.segment17;
      p_mtl_system_items_interface.segment18                       := r1.segment18;
      p_mtl_system_items_interface.segment19                       := r1.segment19;
      p_mtl_system_items_interface.segment20                       := r1.segment20;
      p_mtl_system_items_interface.attribute_category              := r1.attribute_category;
      p_mtl_system_items_interface.attribute1                      := r1.attribute1;
      p_mtl_system_items_interface.attribute2                      := r1.attribute2;
      p_mtl_system_items_interface.attribute3                      := r1.attribute3;
      p_mtl_system_items_interface.attribute4                      := r1.attribute4;
      p_mtl_system_items_interface.attribute5                      := r1.attribute5;
      p_mtl_system_items_interface.attribute6                      := r1.attribute6;
      p_mtl_system_items_interface.attribute7                      := r1.attribute7;
      p_mtl_system_items_interface.attribute8                      := r1.attribute8;
      p_mtl_system_items_interface.attribute9                      := r1.attribute9;
      p_mtl_system_items_interface.attribute10                     := r1.attribute10;
      p_mtl_system_items_interface.attribute11                     := r1.attribute11;
      p_mtl_system_items_interface.attribute12                     := r1.attribute12;
      p_mtl_system_items_interface.attribute13                     := r1.attribute13;
      p_mtl_system_items_interface.attribute14                     := r1.attribute14;
      p_mtl_system_items_interface.attribute15                     := r1.attribute15;
      p_mtl_system_items_interface.purchasing_item_flag            := r1.purchasing_item_flag;
      p_mtl_system_items_interface.shippable_item_flag             := r1.shippable_item_flag;
      p_mtl_system_items_interface.customer_order_flag             := r1.customer_order_flag;
      p_mtl_system_items_interface.internal_order_flag             := r1.internal_order_flag;
      p_mtl_system_items_interface.service_item_flag               := r1.service_item_flag;
      p_mtl_system_items_interface.inventory_item_flag             := r1.inventory_item_flag;
      p_mtl_system_items_interface.eng_item_flag                   := r1.eng_item_flag;
      p_mtl_system_items_interface.inventory_asset_flag            := r1.inventory_asset_flag;
      p_mtl_system_items_interface.purchasing_enabled_flag         := r1.purchasing_enabled_flag;
      p_mtl_system_items_interface.customer_order_enabled_flag     := r1.customer_order_enabled_flag;
      p_mtl_system_items_interface.internal_order_enabled_flag     := r1.internal_order_enabled_flag;
      p_mtl_system_items_interface.so_transactions_flag            := r1.so_transactions_flag;
      p_mtl_system_items_interface.mtl_transactions_enabled_flag   := r1.mtl_transactions_enabled_flag;
      p_mtl_system_items_interface.stock_enabled_flag              := r1.stock_enabled_flag;
      p_mtl_system_items_interface.bom_enabled_flag                := r1.bom_enabled_flag;
      p_mtl_system_items_interface.build_in_wip_flag               := r1.build_in_wip_flag;
      p_mtl_system_items_interface.revision_qty_control_code       := r1.revision_qty_control_code;
      p_mtl_system_items_interface.item_catalog_group_id           := r1.item_catalog_group_id;
      p_mtl_system_items_interface.catalog_status_flag             := r1.catalog_status_flag;
      p_mtl_system_items_interface.check_shortages_flag            := r1.check_shortages_flag;
      p_mtl_system_items_interface.returnable_flag                 := r1.returnable_flag;
      p_mtl_system_items_interface.default_shipping_org            := r1.default_shipping_org;
      p_mtl_system_items_interface.collateral_flag                 := r1.collateral_flag;
      p_mtl_system_items_interface.taxable_flag                    := r1.taxable_flag;
      p_mtl_system_items_interface.qty_rcv_exception_code          := r1.qty_rcv_exception_code;
      p_mtl_system_items_interface.allow_item_desc_update_flag     := r1.allow_item_desc_update_flag;
      p_mtl_system_items_interface.inspection_required_flag        := r1.inspection_required_flag;
      p_mtl_system_items_interface.receipt_required_flag           := r1.receipt_required_flag;
      p_mtl_system_items_interface.market_price                    := r1.market_price;
      p_mtl_system_items_interface.hazard_class_id                 := r1.hazard_class_id;
      p_mtl_system_items_interface.rfq_required_flag               := r1.rfq_required_flag;
      p_mtl_system_items_interface.qty_rcv_tolerance               := r1.qty_rcv_tolerance;
      p_mtl_system_items_interface.list_price_per_unit             := r1.list_price_per_unit;
      p_mtl_system_items_interface.un_number_id                    := r1.un_number_id;
      p_mtl_system_items_interface.price_tolerance_percent         := r1.price_tolerance_percent;
      p_mtl_system_items_interface.asset_category_id               := r1.asset_category_id;
      p_mtl_system_items_interface.rounding_factor                 := r1.rounding_factor;
      p_mtl_system_items_interface.unit_of_issue                   := r1.unit_of_issue;
      p_mtl_system_items_interface.enforce_ship_to_location_code   := r1.enforce_ship_to_location_code;
      p_mtl_system_items_interface.allow_substitute_receipts_flag  := r1.allow_substitute_receipts_flag;
      p_mtl_system_items_interface.allow_unordered_receipts_flag   := r1.allow_unordered_receipts_flag;
      p_mtl_system_items_interface.allow_express_delivery_flag     := r1.allow_express_delivery_flag;
      p_mtl_system_items_interface.days_early_receipt_allowed      := r1.days_early_receipt_allowed;
      p_mtl_system_items_interface.days_late_receipt_allowed       := r1.days_late_receipt_allowed;
      p_mtl_system_items_interface.receipt_days_exception_code     := r1.receipt_days_exception_code;
      p_mtl_system_items_interface.receiving_routing_id            := r1.receiving_routing_id;
      p_mtl_system_items_interface.invoice_close_tolerance         := r1.invoice_close_tolerance;
      p_mtl_system_items_interface.receive_close_tolerance         := r1.receive_close_tolerance;
      p_mtl_system_items_interface.auto_lot_alpha_prefix           := r1.auto_lot_alpha_prefix;
      p_mtl_system_items_interface.start_auto_lot_number           := r1.start_auto_lot_number;
      p_mtl_system_items_interface.lot_control_code                := r1.lot_control_code;
      p_mtl_system_items_interface.shelf_life_code                 := r1.shelf_life_code;
      p_mtl_system_items_interface.shelf_life_days                 := r1.shelf_life_days;
      p_mtl_system_items_interface.serial_number_control_code      := r1.serial_number_control_code;
      p_mtl_system_items_interface.start_auto_serial_number        := r1.start_auto_serial_number;
      p_mtl_system_items_interface.dimension_uom_code              := r1.dimension_uom_code;
      p_mtl_system_items_interface.unit_length                     := r1.unit_length;
      p_mtl_system_items_interface.unit_width                      := r1.unit_width;
      p_mtl_system_items_interface.unit_height                     := r1.unit_height;
      p_mtl_system_items_interface.bulk_picked_flag                := r1.bulk_picked_flag;
      p_mtl_system_items_interface.lot_status_enabled              := r1.lot_status_enabled;
      p_mtl_system_items_interface.default_lot_status_id           := r1.default_lot_status_id;
      p_mtl_system_items_interface.serial_status_enabled           := r1.serial_status_enabled;
      p_mtl_system_items_interface.default_serial_status_id        := r1.default_serial_status_id;
      p_mtl_system_items_interface.lot_split_enabled               := r1.lot_split_enabled;
      p_mtl_system_items_interface.lot_merge_enabled               := r1.lot_merge_enabled;
      p_mtl_system_items_interface.inventory_carry_penalty         := r1.inventory_carry_penalty;
      p_mtl_system_items_interface.operation_slack_penalty         := r1.operation_slack_penalty;
      p_mtl_system_items_interface.financing_allowed_flag          := r1.financing_allowed_flag;
      p_mtl_system_items_interface.eam_item_type                   := r1.eam_item_type;
      p_mtl_system_items_interface.eam_activity_type_code          := r1.eam_activity_type_code;
      p_mtl_system_items_interface.eam_activity_cause_code         := r1.eam_activity_cause_code;
      p_mtl_system_items_interface.eam_act_notification_flag       := r1.eam_act_notification_flag;
      p_mtl_system_items_interface.eam_act_shutdown_status         := r1.eam_act_shutdown_status;
      p_mtl_system_items_interface.dual_uom_control                := r1.dual_uom_control;
      p_mtl_system_items_interface.secondary_uom_code              := r1.secondary_uom_code;
      p_mtl_system_items_interface.dual_uom_deviation_high         := r1.dual_uom_deviation_high;
      p_mtl_system_items_interface.dual_uom_deviation_low          := r1.dual_uom_deviation_low;
      p_mtl_system_items_interface.contract_item_type_code         := r1.contract_item_type_code;
      p_mtl_system_items_interface.subscription_depend_flag        := r1.subscription_depend_flag;
      p_mtl_system_items_interface.serv_req_enabled_code           := r1.serv_req_enabled_code;
      p_mtl_system_items_interface.serv_billing_enabled_flag       := r1.serv_billing_enabled_flag;
      p_mtl_system_items_interface.serv_importance_level           := r1.serv_importance_level;
      p_mtl_system_items_interface.planned_inv_point_flag          := r1.planned_inv_point_flag;
      p_mtl_system_items_interface.lot_translate_enabled           := r1.lot_translate_enabled;
      p_mtl_system_items_interface.default_so_source_type          := r1.default_so_source_type;
      p_mtl_system_items_interface.create_supply_flag              := r1.create_supply_flag;
      p_mtl_system_items_interface.substitution_window_code        := r1.substitution_window_code;
      p_mtl_system_items_interface.substitution_window_days        := r1.substitution_window_days;
      p_mtl_system_items_interface.tracking_quantity_ind           := r1.tracking_quantity_ind;
      p_mtl_system_items_interface.ont_pricing_qty_source          := r1.ont_pricing_qty_source;
      p_mtl_system_items_interface.secondary_default_ind           := r1.secondary_default_ind;
      p_mtl_system_items_interface.vmi_minimum_units               := r1.vmi_minimum_units;
      p_mtl_system_items_interface.vmi_minimum_days                := r1.vmi_minimum_days;
      p_mtl_system_items_interface.vmi_maximum_units               := r1.vmi_maximum_units;
      p_mtl_system_items_interface.vmi_maximum_days                := r1.vmi_maximum_days;
      p_mtl_system_items_interface.vmi_fixed_order_quantity        := r1.vmi_fixed_order_quantity;
      p_mtl_system_items_interface.so_authorization_flag           := r1.so_authorization_flag;
      p_mtl_system_items_interface.consigned_flag                  := r1.consigned_flag;
      p_mtl_system_items_interface.asn_autoexpire_flag             := r1.asn_autoexpire_flag;
      p_mtl_system_items_interface.vmi_forecast_type               := r1.vmi_forecast_type;
      p_mtl_system_items_interface.forecast_horizon                := r1.forecast_horizon;
      p_mtl_system_items_interface.exclude_from_budget_flag        := r1.exclude_from_budget_flag;
      p_mtl_system_items_interface.days_tgt_inv_supply             := r1.days_tgt_inv_supply;
      p_mtl_system_items_interface.days_tgt_inv_window             := r1.days_tgt_inv_window;
      p_mtl_system_items_interface.days_max_inv_supply             := r1.days_max_inv_supply;
      p_mtl_system_items_interface.days_max_inv_window             := r1.days_max_inv_window;
      p_mtl_system_items_interface.drp_planned_flag                := r1.drp_planned_flag;
      p_mtl_system_items_interface.critical_component_flag         := r1.critical_component_flag;
      p_mtl_system_items_interface.continous_transfer              := r1.continous_transfer;
      p_mtl_system_items_interface.convergence                     := r1.convergence;
      p_mtl_system_items_interface.auto_serial_alpha_prefix        := r1.auto_serial_alpha_prefix;
      p_mtl_system_items_interface.source_type                     := r1.source_type;
      p_mtl_system_items_interface.source_organization_id          := r1.source_organization_id;
      p_mtl_system_items_interface.source_subinventory             := r1.source_subinventory;
      p_mtl_system_items_interface.expense_account                 := r1.expense_account;
      p_mtl_system_items_interface.encumbrance_account             := r1.encumbrance_account;
      p_mtl_system_items_interface.restrict_subinventories_code    := r1.restrict_subinventories_code;
      p_mtl_system_items_interface.unit_weight                     := r1.unit_weight;
      p_mtl_system_items_interface.weight_uom_code                 := r1.weight_uom_code;
      p_mtl_system_items_interface.volume_uom_code                 := r1.volume_uom_code;
      p_mtl_system_items_interface.unit_volume                     := r1.unit_volume;
      p_mtl_system_items_interface.restrict_locators_code          := r1.restrict_locators_code;
      p_mtl_system_items_interface.location_control_code           := r1.location_control_code;
      p_mtl_system_items_interface.shrinkage_rate                  := r1.shrinkage_rate;
      p_mtl_system_items_interface.acceptable_early_days           := r1.acceptable_early_days;
      p_mtl_system_items_interface.planning_time_fence_code        := r1.planning_time_fence_code;
      p_mtl_system_items_interface.demand_time_fence_code          := r1.demand_time_fence_code;
      p_mtl_system_items_interface.lead_time_lot_size              := r1.lead_time_lot_size;
      p_mtl_system_items_interface.std_lot_size                    := r1.std_lot_size;
      p_mtl_system_items_interface.cum_manufacturing_lead_time     := r1.cum_manufacturing_lead_time;
      p_mtl_system_items_interface.overrun_percentage              := r1.overrun_percentage;
      p_mtl_system_items_interface.mrp_calculate_atp_flag          := r1.mrp_calculate_atp_flag;
      p_mtl_system_items_interface.acceptable_rate_increase        := r1.acceptable_rate_increase;
      p_mtl_system_items_interface.acceptable_rate_decrease        := r1.acceptable_rate_decrease;
      p_mtl_system_items_interface.cumulative_total_lead_time      := r1.cumulative_total_lead_time;
      p_mtl_system_items_interface.planning_time_fence_days        := r1.planning_time_fence_days;
      p_mtl_system_items_interface.demand_time_fence_days          := r1.demand_time_fence_days;
      p_mtl_system_items_interface.end_assembly_pegging_flag       := r1.end_assembly_pegging_flag;
      p_mtl_system_items_interface.repetitive_planning_flag        := r1.repetitive_planning_flag;
      p_mtl_system_items_interface.planning_exception_set          := r1.planning_exception_set;
      p_mtl_system_items_interface.bom_item_type                   := r1.bom_item_type;
      p_mtl_system_items_interface.pick_components_flag            := r1.pick_components_flag;
      p_mtl_system_items_interface.replenish_to_order_flag         := r1.replenish_to_order_flag;
      p_mtl_system_items_interface.base_item_id                    := r1.base_item_id;
      p_mtl_system_items_interface.atp_components_flag             := r1.atp_components_flag;
      p_mtl_system_items_interface.atp_flag                        := r1.atp_flag;
      p_mtl_system_items_interface.fixed_lead_time                 := r1.fixed_lead_time;
      p_mtl_system_items_interface.variable_lead_time              := r1.variable_lead_time;
      p_mtl_system_items_interface.wip_supply_locator_id           := r1.wip_supply_locator_id;
      p_mtl_system_items_interface.wip_supply_type                 := r1.wip_supply_type;
      p_mtl_system_items_interface.wip_supply_subinventory         := r1.wip_supply_subinventory;
      p_mtl_system_items_interface.primary_uom_code                := r1.primary_uom_code;
      p_mtl_system_items_interface.primary_unit_of_measure         := r1.primary_unit_of_measure;
      p_mtl_system_items_interface.allowed_units_lookup_code       := r1.allowed_units_lookup_code;
      p_mtl_system_items_interface.cost_of_sales_account           := r1.cost_of_sales_account;
      p_mtl_system_items_interface.sales_account                   := r1.sales_account;
      p_mtl_system_items_interface.default_include_in_rollup_flag  := r1.default_include_in_rollup_flag;
      p_mtl_system_items_interface.inventory_item_status_code      := r1.inventory_item_status_code;
      p_mtl_system_items_interface.inventory_planning_code         := r1.inventory_planning_code;
      p_mtl_system_items_interface.planner_code                    := r1.planner_code;
      p_mtl_system_items_interface.planning_make_buy_code          := r1.planning_make_buy_code;
      p_mtl_system_items_interface.fixed_lot_multiplier            := r1.fixed_lot_multiplier;
      p_mtl_system_items_interface.rounding_control_type           := r1.rounding_control_type;
      p_mtl_system_items_interface.carrying_cost                   := r1.carrying_cost;
      p_mtl_system_items_interface.postprocessing_lead_time        := r1.postprocessing_lead_time;
      p_mtl_system_items_interface.preprocessing_lead_time         := r1.preprocessing_lead_time;
      p_mtl_system_items_interface.full_lead_time                  := r1.full_lead_time;
      p_mtl_system_items_interface.order_cost                      := r1.order_cost;
      p_mtl_system_items_interface.mrp_safety_stock_percent        := r1.mrp_safety_stock_percent;
      p_mtl_system_items_interface.mrp_safety_stock_code           := r1.mrp_safety_stock_code;
      p_mtl_system_items_interface.min_minmax_quantity             := r1.min_minmax_quantity;
      p_mtl_system_items_interface.max_minmax_quantity             := r1.max_minmax_quantity;
      p_mtl_system_items_interface.minimum_order_quantity          := r1.minimum_order_quantity;
      p_mtl_system_items_interface.fixed_order_quantity            := r1.fixed_order_quantity;
      p_mtl_system_items_interface.fixed_days_supply               := r1.fixed_days_supply;
      p_mtl_system_items_interface.maximum_order_quantity          := r1.maximum_order_quantity;
      p_mtl_system_items_interface.atp_rule_id                     := r1.atp_rule_id;
      p_mtl_system_items_interface.picking_rule_id                 := r1.picking_rule_id;
      p_mtl_system_items_interface.reservable_type                 := r1.reservable_type;
      p_mtl_system_items_interface.positive_measurement_error      := r1.positive_measurement_error;
      p_mtl_system_items_interface.negative_measurement_error      := r1.negative_measurement_error;
      p_mtl_system_items_interface.engineering_ecn_code            := r1.engineering_ecn_code;
      p_mtl_system_items_interface.engineering_item_id             := r1.engineering_item_id;
      p_mtl_system_items_interface.engineering_date                := r1.engineering_date;
      p_mtl_system_items_interface.service_starting_delay          := r1.service_starting_delay;
      p_mtl_system_items_interface.vendor_warranty_flag            := r1.vendor_warranty_flag;
      p_mtl_system_items_interface.serviceable_component_flag      := r1.serviceable_component_flag;
      p_mtl_system_items_interface.serviceable_product_flag        := r1.serviceable_product_flag;
      p_mtl_system_items_interface.base_warranty_service_id        := r1.base_warranty_service_id;
      p_mtl_system_items_interface.payment_terms_id                := r1.payment_terms_id;
      p_mtl_system_items_interface.preventive_maintenance_flag     := r1.preventive_maintenance_flag;
      p_mtl_system_items_interface.primary_specialist_id           := r1.primary_specialist_id;
      p_mtl_system_items_interface.secondary_specialist_id         := r1.secondary_specialist_id;
      p_mtl_system_items_interface.serviceable_item_class_id       := r1.serviceable_item_class_id;
      p_mtl_system_items_interface.time_billable_flag              := r1.time_billable_flag;
      p_mtl_system_items_interface.material_billable_flag          := r1.material_billable_flag;
      p_mtl_system_items_interface.expense_billable_flag           := r1.expense_billable_flag;
      p_mtl_system_items_interface.prorate_service_flag            := r1.prorate_service_flag;
      p_mtl_system_items_interface.coverage_schedule_id            := r1.coverage_schedule_id;
      p_mtl_system_items_interface.service_duration_period_code    := r1.service_duration_period_code;
      p_mtl_system_items_interface.service_duration                := r1.service_duration;
      p_mtl_system_items_interface.warranty_vendor_id              := r1.warranty_vendor_id;
      p_mtl_system_items_interface.max_warranty_amount             := r1.max_warranty_amount;
      p_mtl_system_items_interface.response_time_period_code       := r1.response_time_period_code;
      p_mtl_system_items_interface.response_time_value             := r1.response_time_value;
      p_mtl_system_items_interface.invoiceable_item_flag           := r1.invoiceable_item_flag;
      p_mtl_system_items_interface.tax_code                        := r1.tax_code;
      p_mtl_system_items_interface.invoice_enabled_flag            := r1.invoice_enabled_flag;
      p_mtl_system_items_interface.must_use_approved_vendor_flag   := r1.must_use_approved_vendor_flag;
      p_mtl_system_items_interface.request_id                      := r1.request_id;
      p_mtl_system_items_interface.program_application_id          := r1.program_application_id;
      p_mtl_system_items_interface.program_id                      := r1.program_id;
      p_mtl_system_items_interface.program_update_date             := r1.program_update_date;
      p_mtl_system_items_interface.outside_operation_flag          := r1.outside_operation_flag;
      p_mtl_system_items_interface.outside_operation_uom_type      := r1.outside_operation_uom_type;
      p_mtl_system_items_interface.safety_stock_bucket_days        := r1.safety_stock_bucket_days;
      p_mtl_system_items_interface.auto_reduce_mps                 := r1.auto_reduce_mps;
      p_mtl_system_items_interface.costing_enabled_flag            := r1.costing_enabled_flag;
      p_mtl_system_items_interface.cycle_count_enabled_flag        := r1.cycle_count_enabled_flag;
      p_mtl_system_items_interface.ib_item_instance_class          := r1.ib_item_instance_class;
      p_mtl_system_items_interface.config_model_type               := r1.config_model_type;
      p_mtl_system_items_interface.lot_substitution_enabled        := r1.lot_substitution_enabled;
      p_mtl_system_items_interface.minimum_license_quantity        := r1.minimum_license_quantity;
      p_mtl_system_items_interface.eam_activity_source_code        := r1.eam_activity_source_code;
      p_mtl_system_items_interface.lifecycle_id                    := r1.lifecycle_id;
      p_mtl_system_items_interface.current_phase_id                := r1.current_phase_id;
	  p_mtl_system_items_interface.process_execution_enabled_flag  := r1.process_execution_enabled_flag;
	  p_mtl_system_items_interface.recipe_enabled_flag	           := r1.recipe_enabled_flag;

   END LOOP;

   RETURN('OK');

   EXCEPTION
      WHEN OTHERS THEN
         RETURN('Erro ao preencher registro da tabela mtl_system_items_interface - ' || SQLERRM);

END tab_mtl_system_items_interface;


/*************************************************************************************
  Function que recebe o id do item e sua organização e retorna o registro de cópia desse
  item referente a tabela mtl_system_items_interface
*************************************************************************************/

FUNCTION attribute_items_interface
           (  p_rowid_tab_integ              IN VARCHAR2
             ,p_organization_id              IN NUMBER    --- usado nas tabelas de OI
             ,p_mtl_system_items_interface   IN OUT mtl_system_items_interface%ROWTYPE)
  RETURN VARCHAR2 IS

  
  wid_item_klassmatt  NUMBER;
  v_erro        varchar(20000);
  
BEGIN

  ---> Faz a leitura da tabela de integração do klassmatt
  
  FOR r1 IN ( SELECT *
                FROM klass_integracao_ebs
               WHERE ROWID = p_rowid_tab_integ
             )
  LOOP

     wid_item_klassmatt := r1.id_item_klassmatt;  ---> variável usada na leitura dos attributes da OI
  
     ---> Consiste se os attributes estão preenchidos e se estiverem faz a mudança na interface
  
     IF r1.attribute_category IS NOT NULL THEN
           p_mtl_system_items_interface.attribute_category := r1.attribute_category;
     END IF;
     
     IF r1.attribute1 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute1 := r1.attribute1;
     END IF;
     
     IF r1.attribute2 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute2 := r1.attribute2;
     END IF;
     
     IF r1.attribute3 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute3 := r1.attribute3;
     END IF;
     
     IF r1.attribute4 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute4 := r1.attribute4;
     END IF;
     
     IF r1.attribute5 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute5 := r1.attribute5;
     END IF;
     
     IF r1.attribute6 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute6 := r1.attribute6;
     END IF;
     
     IF r1.attribute7 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute7 := r1.attribute7;
     END IF;
     
     IF r1.attribute8 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute8 := r1.attribute8;
     END IF;
     
     IF r1.attribute9 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute9 := r1.attribute9;
     END IF;
     
     IF r1.attribute10 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute10 := r1.attribute10;
     END IF;
     
     IF r1.attribute11 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute11 := r1.attribute11;
     END IF;
     
     IF r1.attribute12 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute12 := r1.attribute12;
     END IF;
     
     IF r1.attribute13 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute13 := r1.attribute13;
     END IF;
     
     IF r1.attribute14 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute14 := r1.attribute14;
     END IF;
     
     IF r1.attribute15 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute15 := r1.attribute15;
     END IF;
     
     ------------------------------------------------------------------
     
     IF r1.attribute16 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute16 := r1.attribute16;
     END IF;
     
     IF r1.attribute17 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute17 := r1.attribute17;
     END IF;
     
     IF r1.attribute18 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute18 := r1.attribute18;
     END IF;
     
     IF r1.attribute19 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute19 := r1.attribute19;
     END IF;
     
     IF r1.attribute20 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute20 := r1.attribute20;
     END IF;
     
     IF r1.attribute21 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute21 := r1.attribute21;
     END IF;
     
     IF r1.attribute22 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute22 := r1.attribute22;
     END IF;
     
     IF r1.attribute23 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute23 := r1.attribute23;
     END IF;
     
     IF r1.attribute24 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute24 := r1.attribute24;
     END IF;
     
     IF r1.attribute25 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute25 := r1.attribute25;
     END IF;
     
     IF r1.attribute26 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute26 := r1.attribute26;
     END IF;
     
     IF r1.attribute27 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute27 := r1.attribute27;
     END IF;
     
     IF r1.attribute28 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute28 := r1.attribute28;
     END IF;
     
     IF r1.attribute29 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute29 := r1.attribute29;
     END IF;
     
     IF r1.attribute30 IS NOT NULL THEN
           p_mtl_system_items_interface.attribute30 := r1.attribute30;
     END IF;
     
     ------------------------------------------------------------------
     
     ---> Consiste se os global_attributes estão preenchidos e se estiverem faz a mudança na interface
  
     IF r1.global_attribute_category IS NOT NULL THEN
           p_mtl_system_items_interface.global_attribute_category := r1.global_attribute_category;
     END IF;
     
     IF r1.global_attribute1 IS NOT NULL THEN
           p_mtl_system_items_interface.global_attribute1 := r1.global_attribute1;
     END IF;
     
     IF r1.global_attribute2 IS NOT NULL THEN
           p_mtl_system_items_interface.global_attribute2 := r1.global_attribute2;
     END IF;
     
     IF r1.global_attribute3 IS NOT NULL THEN
           p_mtl_system_items_interface.global_attribute3 := r1.global_attribute3;
     END IF;
     
     IF r1.global_attribute4 IS NOT NULL THEN
           p_mtl_system_items_interface.global_attribute4 := r1.global_attribute4;
     END IF;
     
     IF r1.global_attribute5 IS NOT NULL THEN
           p_mtl_system_items_interface.global_attribute5 := r1.global_attribute5;
     END IF;
     
     IF r1.global_attribute6 IS NOT NULL THEN
           p_mtl_system_items_interface.global_attribute6 := r1.global_attribute6;
     END IF;
     
     IF r1.global_attribute7 IS NOT NULL THEN
           p_mtl_system_items_interface.global_attribute7 := r1.global_attribute7;
     END IF;
     
     IF r1.global_attribute8 IS NOT NULL THEN
           p_mtl_system_items_interface.global_attribute8 := r1.global_attribute8;
     END IF;
     
     IF r1.global_attribute9 IS NOT NULL THEN
           p_mtl_system_items_interface.global_attribute9 := r1.global_attribute9;
     END IF;
     
     IF r1.global_attribute10 IS NOT NULL THEN
           p_mtl_system_items_interface.global_attribute10 := r1.global_attribute10;
     END IF;
     
     IF r1.global_attribute11 IS NOT NULL THEN
           p_mtl_system_items_interface.global_attribute11 := r1.global_attribute11;
     END IF;
     
     IF r1.global_attribute12 IS NOT NULL THEN
           p_mtl_system_items_interface.global_attribute12 := r1.global_attribute12;
     END IF;
          
     IF r1.global_attribute13 IS NOT NULL THEN
           p_mtl_system_items_interface.global_attribute13 := r1.global_attribute13;
     END IF;
     
     IF r1.global_attribute14 IS NOT NULL THEN
           p_mtl_system_items_interface.global_attribute14 := r1.global_attribute14;
     END IF;
     
     IF r1.global_attribute15 IS NOT NULL THEN
           p_mtl_system_items_interface.global_attribute15 := r1.global_attribute15;
     END IF;
     
     IF r1.global_attribute16 IS NOT NULL THEN
           p_mtl_system_items_interface.global_attribute16 := r1.global_attribute16;
     END IF;
     
     IF r1.global_attribute17 IS NOT NULL THEN
           p_mtl_system_items_interface.global_attribute17 := r1.global_attribute17;
     END IF;
     
     IF r1.global_attribute18 IS NOT NULL THEN
           p_mtl_system_items_interface.global_attribute18 := r1.global_attribute18;
     END IF;
     
     IF r1.global_attribute19 IS NOT NULL THEN
           p_mtl_system_items_interface.global_attribute19 := r1.global_attribute19;
     END IF;
     
     IF r1.global_attribute20 IS NOT NULL THEN
           p_mtl_system_items_interface.global_attribute20 := r1.global_attribute20;
     END IF;
     
  END LOOP;

  
  ---> A prioridade do dado retornado dos attributes é o que está gravado na tabela de OIs e por isso vem por último
  
  FOR r1 IN ( 
               SELECT *
                 FROM klass_integracao_oi_item
                WHERE id_item_klassmatt = wid_item_klassmatt
                  AND status            = 2
                  AND organization_id   = P_Organization_id
            )
  LOOP
  
           ---> Consiste se os attributes estão preenchidos e se estiverem faz a mudança na interface
        
           IF r1.attribute_category IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute_category := r1.attribute_category;
           END IF;
           
           IF r1.attribute1 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute1 := r1.attribute1;
           END IF;
           
           IF r1.attribute2 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute2 := r1.attribute2;
           END IF;
           
           IF r1.attribute3 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute3 := r1.attribute3;
           END IF;
           
           IF r1.attribute4 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute4 := r1.attribute4;
           END IF;
           
           IF r1.attribute5 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute5 := r1.attribute5;
           END IF;
           
           IF r1.attribute6 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute6 := r1.attribute6;
           END IF;
           
           IF r1.attribute7 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute7 := r1.attribute7;
           END IF;
           
           IF r1.attribute8 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute8 := r1.attribute8;
           END IF;
           
           IF r1.attribute9 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute9 := r1.attribute9;
           END IF;
           
           IF r1.attribute10 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute10 := r1.attribute10;
           END IF;
           
           IF r1.attribute11 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute11 := r1.attribute11;
           END IF;
           
           IF r1.attribute12 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute12 := r1.attribute12;
           END IF;
           
           IF r1.attribute13 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute13 := r1.attribute13;
           END IF;
           
           IF r1.attribute14 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute14 := r1.attribute14;
           END IF;
           
           IF r1.attribute15 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute15 := r1.attribute15;
           END IF;
  
           ------------------------------------------------------------------
     
           IF r1.attribute16 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute16 := r1.attribute16;
           END IF;
           
           IF r1.attribute17 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute17 := r1.attribute17;
           END IF;
           
           IF r1.attribute18 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute18 := r1.attribute18;
           END IF;
           
           IF r1.attribute19 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute19 := r1.attribute19;
           END IF;
           
           IF r1.attribute20 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute20 := r1.attribute20;
           END IF;
           
           IF r1.attribute21 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute21 := r1.attribute21;
           END IF;
           
           IF r1.attribute22 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute22 := r1.attribute22;
           END IF;
           
           IF r1.attribute23 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute23 := r1.attribute23;
           END IF;
           
           IF r1.attribute24 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute24 := r1.attribute24;
           END IF;
           
           IF r1.attribute25 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute25 := r1.attribute25;
           END IF;
           
           IF r1.attribute26 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute26 := r1.attribute26;
           END IF;
           
           IF r1.attribute27 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute27 := r1.attribute27;
           END IF;
           
           IF r1.attribute28 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute28 := r1.attribute28;
           END IF;
           
           IF r1.attribute29 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute29 := r1.attribute29;
           END IF;
           
           IF r1.attribute30 IS NOT NULL THEN
                 p_mtl_system_items_interface.attribute30 := r1.attribute30;
           END IF;
       
       ------------------------------------------------------------------
       if r1.expense_account_txt is not null and r1.expense_account is null then
        r1.expense_account := retorna_code_combination_id(r1.expense_account_txt, v_erro);
        if( r1.expense_account = 0 ) then
          RETURN('Erro ao atribuir conta contábil - CONTA: EXPENSE_ACCOUNT - OI: ' || P_Organization_id || ' -  COMBINACAO: ' || r1.expense_account_txt || ' -  ERRO: ' || v_erro);
        end if;
       END IF;
       
       IF r1.expense_account IS NOT NULL THEN
                 p_mtl_system_items_interface.expense_account := r1.expense_account;
           END IF;
       
       if r1.cost_of_sales_account_txt is not null and r1.cost_of_sales_account is null then
        r1.cost_of_sales_account := retorna_code_combination_id(r1.cost_of_sales_account_txt, v_erro);
        if( r1.cost_of_sales_account = 0 ) then
          RETURN('Erro ao atribuir conta contábil - CONTA: COST_OF_SALES_ACCOUNT - OI: ' || P_Organization_id || ' -  COMBINACAO: ' || r1.cost_of_sales_account_txt || ' -  ERRO: ' || v_erro);
        end if;
       END IF;
             
       IF r1.cost_of_sales_account IS NOT NULL THEN
                 p_mtl_system_items_interface.cost_of_sales_account := r1.cost_of_sales_account;
           END IF;
             
       if r1.sales_account_txt is not null and r1.sales_account is null then
        r1.sales_account := retorna_code_combination_id(r1.sales_account_txt, v_erro);
        if( r1.sales_account = 0 ) then
          RETURN('Erro ao atribuir conta contábil - CONTA: sales_account - OI: ' || P_Organization_id || ' -  COMBINACAO: ' || r1.sales_account_txt || ' -  ERRO: ' || v_erro);
        end if;
       END IF;
       
       IF r1.sales_account IS NOT NULL THEN
                 p_mtl_system_items_interface.sales_account := r1.sales_account;
           END IF;
       
       ------------------------------------------------------------------
         
      ----------------------------------------------------------------------------------
      IF r1.min_minmax_quantity IS NOT NULL THEN
        p_mtl_system_items_interface.min_minmax_quantity      := r1.min_minmax_quantity;
      END IF;

      IF r1.max_minmax_quantity IS NOT NULL THEN
        p_mtl_system_items_interface.max_minmax_quantity      := r1.max_minmax_quantity;
      END IF;
      ----------------------------------------------------------------------------------


  END LOOP;
  
  
  -------------
  RETURN('OK');
  -------------

   EXCEPTION
      WHEN OTHERS THEN
         RETURN('Erro ao integrar os attributes da tabela integracao com a interface do item - ' || SQLERRM);

END attribute_items_interface;


/*************************************************************************************
  Function para validar as categorias alteráveis do item
*************************************************************************************/

FUNCTION valida_categoria ( p_nome_Categoria  IN VARCHAR2
                           ,p_structure_id    IN NUMBER
                           ,p_rowid           IN VARCHAR2
                           ,p_category_id    OUT NUMBER )

  RETURN VARCHAR2 IS

   msg_retorno         VARCHAR2(4000);

   vselect             VARCHAR2(5000);
   vwhere              VARCHAR2(5000);
   i                   NUMBER;
   j                   NUMBER;
   vvar                VARCHAR2(100);

   vselect_config      VARCHAR2(1000);
   vwhere_config       VARCHAR2(1000);
   vcampo              VARCHAR2(1000);
   vvalor              VARCHAR2(1000);
   vmsg_erro           VARCHAR2(2000);


BEGIN

   p_category_id := NULL;

   ---> faz a leitura do registro do item lido da tabela de integração

   FOR r1 IN (
               SELECT ROWID
                     ,categ_segment1
                     ,categ_segment2
                     ,categ_segment3
                     ,categ_segment4
                 FROM klass_integracao_ebs
                WHERE ROWID = p_rowid
             )
   LOOP


         vselect := 'SELECT category_id
                         FROM mtl_categories_b ';

         vwhere    := ' WHERE structure_id        = ' || p_structure_id ;


         ---> MONTA AND DO WHERE

         FOR r2 IN (
                     SELECT *
                       FROM klass_configuracao
                      WHERE tipo       = 'SETA_CATEGORIA'
                        AND attribute1 = p_nome_categoria
                    )
         LOOP


             J := 1;

             FOR i IN 4 .. (3 + r2.attribute2 )
             LOOP

                  vselect_config := 'select attribute' || i || ' from klass_configuracao ';
                  vwhere_config  := 'where tipo = ''SETA_CATEGORIA'' and attribute1 = ''' || p_nome_categoria || '''';

                  execute immediate vselect_config || vwhere_config
                      into vcampo;

                  vmsg_erro := vmsg_erro || vcampo;

              --    dbms_output.put_line(vcampo);

                  vselect_config := 'select ' || vcampo ||' from klass_integracao_ebs ';
                  vwhere_config  := 'where rowid = ''' || r1.ROWID || '''';

                  execute immediate vselect_config || vwhere_config
                      into vvalor;

                  vmsg_erro := vmsg_erro || ' = ' || vvalor || '; ';

                  ---> Se valor na interface é nulo então retorna

                  IF vvalor IS NULL THEN
                      p_category_id := NULL;
                      RETURN ('OK');
                  END IF;

              --    dbms_output.put_line(vvalor);


               IF r2.attribute3 = 'NUMERICO' THEN

                   vwhere := vwhere ||
                              ' AND to_number(SEGMENT' || j || ') = ' || to_number(vvalor);

               ELSE

                     vwhere := vwhere ||
                              ' AND SEGMENT' || j || ' = ''' || vvalor || '''';
               END IF;

               J := J + 1;

             END LOOP;

       ---dbms_output.put_line(vselect || vwhere );

       BEGIN

         execute immediate vselect || vwhere || ' AND ROWNUM = 1'
              into p_category_id;

          EXCEPTION
            WHEN OTHERS THEN

                  msg_retorno := 'Dados da categoria ' || p_nome_Categoria || ' não encontrados : ' ||
                                 vmsg_erro;
                  RAISE erro;

        END;

          IF p_category_id IS NOT NULL THEN
             EXIT;
          END IF;

       END LOOP;

       ---> se não encontrou a categoria dá msg de erro

        IF p_category_id IS NULL THEN

              msg_retorno := 'Dados da categoria ' || p_nome_Categoria || ' não entrou na validação da package : ' ||
                             vmsg_erro;
              RAISE erro;

        END IF;

  END LOOP;


  IF p_category_id IS NULL THEN
       msg_retorno := 'Dados da categoria ' || p_nome_Categoria || ' e estructure_id  ' || p_structure_id || ' não entrou na validação da package';
       RETURN(msg_retorno);
  END IF;


  RETURN('OK');


   EXCEPTION
     WHEN erro THEN
        RETURN(msg_retorno);

     WHEN OTHERS THEN
         RETURN('Erro funcao valida categoria : rowid = ' || p_rowid || ' - ' || SQLERRM);

END valida_categoria;

  /********************************************************************************************
    Função para setar a responsabilidade que irá rodar o concorrente
  *********************************************************************************************/

  FUNCTION seta_responsabilidade RETURN VARCHAR2 IS

    vuser_id               NUMBER;
    vresponsibility_id     NUMBER;
    vapplication_id        NUMBER;
    vmsg                   VARCHAR2(5000);

  BEGIN

  ---> Acessa a tabela de configuração

  FOR r1 IN ( SELECT attribute1   --- nome usuário
                    ,attribute2   --- nome responsabilidade super usuário
                FROM klass_configuracao
               WHERE tipo = 'SETA_RESPONSABILIDADE'
             )
  LOOP

      ---> Busca o id do usuário

      BEGIN

          SELECT user_id
            INTO vuser_id
            FROM fnd_user
           WHERE user_name = R1.ATTRIBUTE1;

          EXCEPTION
             WHEN OTHERS THEN
                vmsg := 'Erro ao setar responsabilidade - user id : ' || SQLERRM;
                RAISE erro;

      END;

      ---> Busca o id da responsabilidade e aplicação

      BEGIN

          SELECT responsibility_id
                ,application_id
            INTO vresponsibility_id
                ,vapplication_id
            FROM fnd_responsibility
           WHERE responsibility_key = R1.ATTRIBUTE2;

          EXCEPTION
             WHEN OTHERS THEN
                vmsg := 'Erro ao setar responsabilidade - responsibility id : ' || SQLERRM;
                RAISE erro;

      END;

  END LOOP;

  IF vuser_id IS NULL THEN
     vmsg := 'Erro ao setar responsabilidade - tipo SETA_RESPONSABILIDADE não encontrado na tabela de configuracao.';
     RAISE erro;
  END IF;

  ---> Seta usuário e responsabilidade

   BEGIN
        FND_GLOBAL.APPS_INITIALIZE(vuser_id
                                  ,vresponsibility_id
                                  ,vapplication_id
                                  );
   END;



   ---> GRAVA NA GLOBAL O CONTEXTO DA LINGUAGEM

   SELECT nls_language
     INTO g_nls_language
     FROM fnd_languages
    WHERE language_code = userenv('LANG');


   RETURN('OK');


  EXCEPTION

  WHEN erro THEN
     RETURN(vmsg);

  WHEN OTHERS THEN
     RETURN('Erro ao setar a responsabilidade : ' || SQLERRM);

  END seta_responsabilidade;

  /**********************************************************************************************
   Função responsável por enviar e-mail dos erros de processamento em algum ponto do concorrente
  ***********************************************************************************************/

  FUNCTION envia_email(p_mensagem         IN VARCHAR2
                      ,p_assunto_inclusao IN VARCHAR2
                      ,p_email_klassmatt  IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 IS


    --> Variáveis para conexão e envio do email

    mailhost         VARCHAR2(1000);
    sender           VARCHAR2(1000);
    l_connection     utl_smtp.connection;

    v_email          VARCHAR2(1000);
    v_email_criado   VARCHAR2(1000);
    v_email_erro     VARCHAR2(1000);
    v_from           VARCHAR2(1000);
    msg_retorno      VARCHAR2(5000);
    v_assunto        VARCHAR2(5000);
    v_connection     VARCHAR2(1000);
    i                NUMBER;
    lim              NUMBER := 1;
    vambiente        VARCHAR2(200);

  BEGIN


       gera_log_tabela(v_sequencia_processamento
                      ,'Enviando email ...'
                      ,SYSDATE
                      ,'P'
                      ,v_nome_concorrente
                      ,v_debug);

       ---> verifica se vai enviar email

       IF nvl(venvia_email,'X') = 'N' THEN
          RETURN('OK');
       END IF;

       ------------------------------------
       ---> VARIAVEL DE AMBIENTE (TSA, HMA, PRD)

       BEGIN
             SELECT NAME
               INTO vambiente
               FROM v$database;

             EXCEPTION
                    WHEN OTHERS THEN
                        msg_retorno := 'Erro ao acessar a variavel de ambiente - ' || SQLERRM;
                        RAISE erro;

       END;
       ------------------------------------
       ---> MONTAGEM DAS VARIAVEIS DOS EMAILS

       FOR r1 IN (
                   SELECT attribute1
                         ,attribute2
                     FROM klass_configuracao
                    WHERE tipo = 'SETA_PARAMETROS_EMAIL'
                 )
       LOOP

           IF r1.attribute1 = 'HOST' THEN
               mailhost := r1.attribute2;
           END IF;

           IF r1.attribute1 = 'SENDER' THEN
               sender   := r1.attribute2;
           END IF;

           IF r1.attribute1 = 'EMAIL_ITEM_CRIADO' THEN
               v_email_criado := r1.attribute2;
           END IF;

           IF r1.attribute1 = 'EMAIL_ERRO_INTEG' THEN
               v_email_erro    := r1.attribute2;
           END IF;

           IF r1.attribute1 = 'FROM' THEN
               v_from := r1.attribute2;
           END IF;

           IF r1.attribute1 = 'CONNECTION' THEN
               v_connection := r1.attribute2;
           END IF;

       END LOOP;

       IF mailhost       IS NULL OR
          sender         IS NULL OR
          v_from         IS NULL OR
          v_connection   IS NULL THEN

           msg_retorno := 'Erro - nao existe um dos parametros de enviar email.';
           RAISE erro;

       END IF;
       ------------------------------------

       IF p_assunto_inclusao IS NULL THEN  ---> email de erro de integração

             v_assunto := 'ERRO integracao EBS-KLASSMATT : ' || to_char(SYSDATE,'DD/MM/YYYY HH24:MI:SS')
                       || ' concorrente ' || v_sequencia_processamento ;

              ---> acessa o e-mail cadastrado na profile

              v_email := v_email_erro;

       ELSE  ---> EMAIL DE ITEM CRIADO

             v_assunto := p_assunto_inclusao;

             ---> acessa o e-mail cadastrado na profile

              v_email := v_email_criado;

       END IF;

        ---> verifica se o valor está vazio

        IF v_email IS NULL THEN
            msg_retorno := 'Erro - valor da profile de email esta nulo';
            RAISE erro;
        END IF;

        v_assunto := vambiente || ' ' || v_assunto;

        ---> se item criado manda email para os dois, senão somente para um.

        FOR i IN 1 .. lim
        LOOP

                BEGIN
                  l_connection := utl_smtp.open_connection(mailhost,25);
                  utl_smtp.helo( l_connection, v_connection);
                  utl_smtp.mail( l_connection, sender);
                  utl_smtp.rcpt( l_connection,v_email);
                  utl_smtp.open_data(l_connection);
                  utl_smtp.write_data(l_connection,'from'|| ': ' || v_from || utl_tcp.CRLF);
                  utl_smtp.write_data(l_connection,'to'|| ': ' || v_email|| utl_tcp.CRLF);
                  utl_smtp.write_data(l_connection,'subject'|| ': ' || v_assunto|| utl_tcp.CRLF);
                  utl_smtp.write_data (l_connection,utl_tcp.CRLF|| p_mensagem);
                  utl_smtp.close_data(l_connection);
                  utl_smtp.quit( l_connection );
                EXCEPTION
                  WHEN erro THEN
                     utl_smtp.quit( l_connection );
                     gera_log_tabela(v_sequencia_processamento
                              ,msg_retorno
                              ,SYSDATE
                              ,'P'
                              ,v_nome_concorrente
                              ,v_debug);

                     RETURN(msg_retorno);
                  WHEN OTHERS THEN
                    utl_smtp.quit( l_connection );
                    gera_log_tabela(v_sequencia_processamento
                              ,'Erro ao enviar e-mail. erro: '||SQLERRM
                              ,SYSDATE
                              ,'P'
                              ,v_nome_concorrente
                              ,v_debug);

                    RETURN('Erro ao enviar e-mail. erro: '||SQLERRM);
                END;

        END LOOP;

        RETURN('OK');


    EXCEPTION

        WHEN erro THEN
             RETURN(msg_retorno);

        WHEN OTHERS THEN
            RETURN('Erro ao enviar e-mail. erro: '||SQLERRM);

  END envia_email;

 /****************************************************************
   Função que altera o item na mtl_system_items_tl
   Somente das linguagens que não seja a padrão, pois essa tem que
   ser feita via interface para alterar a mtl_system_items_b também
  ****************************************************************/

  FUNCTION altera_desc_linguagem ( p_inventory_item_id  IN NUMBER
                                  ,p_description        IN VARCHAR2
                                  ,p_long_description   IN VARCHAR2
                                  ,p_organization_id    IN NUMBER
                                  ) RETURN VARCHAR2 IS

  v_item_rec         apps.inv_item_api.item_rec_type;
  v_return_status    VARCHAR2(20);
  v_flag             NUMBER := 0;

BEGIN


FOR v_item_rec IN inv_item_api.item_csr (p_inventory_item_id, p_organization_id)
LOOP
    BEGIN

      v_item_rec.description      := p_description;
      v_item_rec.long_description := p_long_description;

      INV_ITEM_API.UPDATE_ITEM_ROW ( p_item_rec       => v_item_rec,
                                     p_update_item_tl => TRUE,
                                     p_lang_flag      => 'B',
                                     x_return_status  => v_return_status);

      IF v_return_status = FND_API.G_RET_STS_SUCCESS THEN
          RETURN('OK');
      ELSE
          RETURN('Problema ao alterar a linguagem.');
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        RETURN ('EXCEPTION : ' || SQLERRM);
    END;

END LOOP;

END altera_desc_linguagem;
   
  ------------------------------------------------------------------------------------------------
  /************************************************************** 
   Função que fará a consistência das informações de referência 
   item fornecedor e colocará o end_date nas que não vierem no item
  ***************************************************************/  
  
  FUNCTION item_fornecedor_end_date ( p_id_item_klassmatt       IN VARCHAR2
                                     ,p_codigo_item             IN VARCHAR2
                                     ,p_tipo_chamada            IN VARCHAR2 )  -- I - interna   E - externa
                                RETURN VARCHAR2 IS

    vmsg                     VARCHAR2(3000);
    vmsg_retorno             VARCHAR2(3000);
    vinventory_item_id       NUMBER;
    vcount NUMBER;
    
  BEGIN
  
    -- SE TEM REGISTROS PARA ESSE ITEM NA TABELA E ESTÃO COM 3 OU 4 É 
    -- PORQUE ESTÁ REPROCESSANDO SOMENTE A KLASS_INTEGRACAO_EBS. 
    -- ENTAO, NÃO DEVE INATIVAR NENHUMA REFERENCIA
    SELECT COUNT(1) 
    INTO vcount
    FROM KLASS_INTEGRACAO_EBS_REF
    WHERE id_item_klassmatt = p_id_item_klassmatt
    AND STATUS IN( 3, 4);
        
    IF (vcount > 0)  THEN
      RETURN('OK');
    END IF;
  
                             
   BEGIN
    
      SELECT inventory_item_id
      INTO vinventory_item_id
      FROM mtl_system_items_b
       WHERE segment1        = p_codigo_item
       AND organization_id IN (SELECT to_number(attribute1)
                     FROM klass_configuracao
                    WHERE tipo = 'ID_ORGANIZACAO_MESTRE' );
                   
      EXCEPTION
       WHEN OTHERS THEN
        vmsg := 'Erro ao acessar o inventory_item_id do item ' || p_codigo_item || ' da tabela de integracao ' ||
            'KLASS_INTEGRACAO_EBS_REF id_item_klassmatt ' || p_id_item_klassmatt || ' - ' || SQLERRM;
        RAISE erro;
   END;
     
     ---> Por cada fabricante analisa os itens que não vieram na interface e atualiza o ebs nesses itens com o end_date
   
     BEGIN
            
       UPDATE mtl_mfg_part_numbers  
         SET end_date = SYSDATE,
       last_update_date = SYSDATE,
       last_updated_by = fnd_profile.value('user_id'),
       last_update_login = fnd_profile.value('user_id')
         WHERE inventory_item_id = vinventory_item_id
           AND NOT EXISTS ( SELECT 1
                  FROM KLASS_INTEGRACAO_EBS_REF   KR
                  INNER JOIN MTL_MANUFACTURERS MF
                  ON MF.attribute10 = KR.codigo_fabricante_klass
                   WHERE KR.id_item_klassmatt = p_id_item_klassmatt
                     AND MF.manufacturer_id = mtl_mfg_part_numbers.manufacturer_id
                     AND KR.mfg_part_num    = mtl_mfg_part_numbers.mfg_part_num  );
     
     END;

  
  --------------
  RETURN('OK');
  --------------
  
  
  EXCEPTION
      WHEN erro THEN
      
          BEGIN
                  UPDATE klass_integracao_ebs_ref
                           SET status    = 4        --- integração erro
                              ,desc_erro = vmsg
                   WHERE  id_item_klassmatt = p_id_item_klassmatt
                     AND status = 2 ;

                  EXCEPTION
                      WHEN OTHERS THEN
                         vmsg_retorno := '1 - Erro ao alterar a tabela klass_integracao_ebs_ref : p_id_item_klassmatt ' ||
                                         p_id_item_klassmatt || ' - ' || SQLERRM;
                         RETURN(vmsg_retorno);
          END;
      
          --------------
          RETURN('OK');
          --------------

      WHEN OTHERS THEN       
        RETURN ('Erro Geral funcao ITEM_FORNECEDOR_END_DATE: '|| SQLERRM);    
   
  END item_fornecedor_end_date;
   
  ------------------------------------------------------------------------------------------------
  /************************************************************** 
   Função que fará a consistência das informações de referência 
   item fornecedor e fará a gravação das informações no ebs
  ***************************************************************/ 
   
  FUNCTION consiste_item_fornecedor ( p_id_item_klassmatt       IN NUMBER
                                     ,p_codigo_item             IN VARCHAR2
                                     ,p_manufacturer_name       IN VARCHAR2
                                     ,p_description             IN VARCHAR2
                                     ,p_codigo_fabricante_klass IN VARCHAR2
                                     ,p_mfg_part_num            IN VARCHAR2
                                     ,p_attribute_Category      IN VARCHAR2
                                     )
                                RETURN VARCHAR2 IS
         
      vmsg                     VARCHAR2(3000);     
      vinventory_item_id       NUMBER;  
      vcont                    NUMBER;   
      vmanufacturer_id         NUMBER;   
                                
  BEGIN
   
    ---> As informaçõe do fabricante são NOT NULL na tabela de integração e por isso não vai ser preciso
    ---  testar se vieram ou não. O que tem que ser acessado é o inventory_item_id do cõdigo enviado para 
    ---  gravar na tabela do ebs
    
    BEGIN
    
        SELECT inventory_item_id
          INTO vinventory_item_id
          FROM mtl_system_items_b
         WHERE segment1        = p_codigo_item
           AND organization_id IN (SELECT to_number(attribute1)
                                     FROM klass_configuracao
                                    WHERE tipo = 'ID_ORGANIZACAO_MESTRE' );
                                 
        EXCEPTION
           WHEN OTHERS THEN
              vmsg := 'Erro ao acessar o inventory_item_id do item ' || p_codigo_item || ' da tabela de integracao ' ||
                      'KLASS_INTEGRACAO_EBS_REF id_item_klassmatt ' || p_id_item_klassmatt || ' - ' || SQLERRM;
              RAISE erro;
    END;
    
    
    ---> Verifica se o fabricante já está cadastrado no ebs
    
    SELECT COUNT(1)
      INTO vcont
      FROM mtl_manufacturers
     WHERE ( attribute10 = p_codigo_fabricante_klass OR manufacturer_name = p_manufacturer_name );
     
    IF vcont = 0 THEN
    
       BEGIN
       
           SELECT mtl_manufacturers_s.NEXTVAL
             INTO vmanufacturer_id
             FROM dual;
    
            EXCEPTION
                 WHEN OTHERS THEN
                    vmsg := 'Erro ao acessar o id do fabricante a partir da sequence - id_item_klassmatt ' || p_id_item_klassmatt || ' - ' || SQLERRM;
                    RAISE erro;
       END; 
       
       ---> Inclui o fabricante
       
       BEGIN
       
            INSERT INTO mtl_manufacturers
                      ( manufacturer_id
                       ,manufacturer_name
                       ,last_update_date
                       ,last_updated_by
                       ,creation_date
                       ,created_by
                       ,last_update_login
                       ,description
                       ,attribute_category
                       ,attribute10 -- codigo fabricante klassmatt
                      )
                VALUES
                      ( vmanufacturer_id              -- manufacturer_id
                       ,p_manufacturer_name           -- manufacturer_name
                       ,SYSDATE                       -- last_update_date
                       ,fnd_profile.value('user_id')  -- last_updated_by
                       ,SYSDATE                       -- creation_date
                       ,fnd_profile.value('user_id')  -- created_by
                       ,fnd_profile.value('user_id')  -- last_update_login
                       ,p_description                 -- description
                       ,p_attribute_category          -- attribute_category
                       ,p_codigo_fabricante_klass     -- attribute10 -- codigo fabricante klassmatt
                      );
          
             EXCEPTION
                 WHEN OTHERS THEN
                    vmsg := 'Erro ao incluir o fabricante - id_item_klassmatt ' || p_id_item_klassmatt || ' - ' || SQLERRM;
                    RAISE erro;
                    
        END;
          
    ELSE
    
        ---> Acessa o id do fabricante já cadastrado para depois usar no vínculo do item
        
        BEGIN
            SELECT manufacturer_id
              INTO vmanufacturer_id
              FROM mtl_manufacturers
             WHERE ( attribute10 = p_codigo_fabricante_klass OR manufacturer_name = p_manufacturer_name );
             
            EXCEPTION
                 WHEN OTHERS THEN
                    vmsg := 'Erro ao acessar o id do fabricante - id_item_klassmatt ' || p_id_item_klassmatt || ' - ' || SQLERRM;
                    RAISE erro;
        END;
        
        ---> Altera as informações do fabricante
        
        BEGIN
        
              UPDATE mtl_manufacturers
                 SET manufacturer_name  = p_manufacturer_name
                    ,last_update_date   = SYSDATE
                    ,last_updated_by    = fnd_profile.value('user_id')
                    ,last_update_login  = fnd_profile.value('user_id')
                    ,description        = p_description                    
               WHERE attribute10        = p_codigo_fabricante_klass 
           AND manufacturer_name != p_manufacturer_name;
          
               EXCEPTION
                       WHEN OTHERS THEN
                          vmsg := 'Erro ao alterar o fabricante - id_item_klassmatt ' || p_id_item_klassmatt || ' - ' || SQLERRM;
                          RAISE erro;
        END;
    
    END IF;
    
    
    ---> vínculo item ebs com o item do fabricante -- acessando todas as UOS do item
    
    FOR r1 IN (
                SELECT organization_id
                  FROM mtl_system_items_b
                 WHERE inventory_item_id = vinventory_item_id
              )
    LOOP
    
        SELECT COUNT(1)
          INTO vcont
          FROM mtl_mfg_part_numbers  
         WHERE manufacturer_id   = vmanufacturer_id
           AND mfg_part_num      = p_mfg_part_num 
           AND inventory_item_id = vinventory_item_id
           AND organization_id   = r1.organization_id;
           
        IF vcont = 0 THEN
        
           BEGIN
           
              INSERT INTO mtl_mfg_part_numbers
                       ( manufacturer_id
                        ,mfg_part_num
                        ,inventory_item_id
                        ,last_update_date
                        ,last_updated_by
                        ,creation_date
                        ,last_update_login
                        ,created_by
                        ,organization_id
                       )
                    VALUES
                      ( vmanufacturer_id              -- manufacturer_id
                       ,p_mfg_part_num                -- mfg_part_num
                       ,vinventory_item_id            -- inventory_item_id
                       ,SYSDATE                       -- last_update_date
                       ,fnd_profile.value('user_id')  -- last_updated_by
                       ,SYSDATE                       -- creation_date
                       ,fnd_profile.value('user_id')  -- last_update_login
                       ,fnd_profile.value('user_id')  -- created_by
                       ,r1.organization_id            -- organization_id
                       );
           
              EXCEPTION
                   WHEN OTHERS THEN
                       vmsg := 'Erro ao inserir o vinculo item X fabricante - item ebs : ' || p_codigo_item || ' - ' || SQLERRM;
                       RAISE erro;           
           END;
        
        ELSE
        
            ---> Altera e ativa o end_date se não estiver nulo
            
            BEGIN
                
                UPDATE mtl_mfg_part_numbers  
                   SET end_date = NULL, 
               last_update_date = SYSDATE,
             last_updated_by = fnd_profile.value('user_id'),
             last_update_login = fnd_profile.value('user_id')
                 WHERE manufacturer_id   = vmanufacturer_id
                   AND mfg_part_num      = p_mfg_part_num 
                   AND inventory_item_id = vinventory_item_id
                   AND organization_id   = r1.organization_id
                   AND end_date          IS NOT NULL;
                
                EXCEPTION
                           WHEN OTHERS THEN
                              vmsg := 'Erro ao alterar o item fabricante - id_item_klassmatt ' || p_id_item_klassmatt || ' - ' || SQLERRM;
                              RAISE erro;
            END;
        
        END IF;
   
    END LOOP;
    
   
    -------------
    RETURN ('OK');
    -------------

  EXCEPTION
      WHEN erro THEN
        RETURN (vmsg);

      WHEN OTHERS THEN       
        RETURN ('Erro Geral funcao CONSISTE_ITEM_FORNECEDOR : '|| SQLERRM); 
   
  END consiste_item_fornecedor;
  
  
  ------------------------------------------------------------------------------------------------
  
  /**************************************************************
   Função que faz a integração do klassmatt com o ebs em relação
   aos itens Relacionados MTL_RELATED_ITEMS
  ***************************************************************/

 FUNCTION manutencao_item_related(p_id_item_klassmatt       IN VARCHAR2,
                                  p_codigo_item             IN VARCHAR2,
                                  p_tipo_chamada            IN VARCHAR2 )  -- I - interna   E - externa
                                       RETURN VARCHAR2 
 IS                                     
    l_fnd_user_id varchar(100);
    vmsg                     VARCHAR2(3000);
    vmsg_retorno             VARCHAR2(3000);
    v_Rowid VARCHAR2(400);
    vcount number;
    
BEGIN
 
     ---> se for chamada externa então seta a responsabilidade
     
     gera_log_tabela(v_sequencia_processamento
                             ,'manutencao_item_related - INI - p_id_item_klassmatt =  ' || p_id_item_klassmatt
                             ,SYSDATE
                             ,'P'
                             ,v_nome_concorrente
                             ,v_debug);
                             
                             
     IF nvl(p_tipo_chamada,'E') = 'E' THEN
     
         vmsg := seta_responsabilidade;
        
          SELECT attribute1
            INTO vid_organizacao_mestre   --- variavel global
            FROM klass_configuracao
           WHERE tipo = 'ID_ORGANIZACAO_MESTRE';

     END IF; 
 
    l_fnd_user_id := fnd_profile.value('user_id');


    -- SE TEM REGISTROS PARA ESSE ITEM NA TABELA E ESTÃO COM 3 OU 4 É 
    -- PORQUE ESTÁ REPROCESSANDO SOMENTE A KLASS_INTEGRACAO_EBS. 
    -- ENTAO, NÃO DEVE INATIVAR NENHUM RELACIONAMENTO
    SELECT COUNT(1) 
    INTO vcount
    FROM KLASS_INTEGRACAO_RELACIONA
    WHERE id_item_klassmatt = p_id_item_klassmatt
    AND STATUS IN( 3, 4);
        
    IF (vcount = 0)  THEN
    
          DELETE FROM MTL_RELATED_ITEMS 
          WHERE rowid in(
              SELECT REL.rowid
              FROM MTL_SYSTEM_ITEMS_B B1 
              INNER JOIN MTL_RELATED_ITEMS REL ON B1.INVENTORY_ITEM_ID = REL.INVENTORY_ITEM_ID 
              INNER JOIN MTL_SYSTEM_ITEMS_B B2 ON B2.INVENTORY_ITEM_ID = REL.RELATED_ITEM_ID
              WHERE B1.Segment1 =  p_codigo_item
              AND NOT EXISTS( 
                  SELECT 1 FROM KLASS_INTEGRACAO_RELACIONA R 
                  WHERE R.CODIGO_EBS = B1.SEGMENT1 AND R.CODIGO_EBS_RELATED = B2.SEGMENT1) 
          );
   
    END IF;
    
    
     ---> O parâmetro p_id_item_klassmatt deve vir sempre preenchido. 
     ---  O código do item irá vir preenchido quando for uma chamada interna do procedimento
     ---  quando for uma chamada externa, direta, o código poderá vir em branco e ele irá pegar da tabela.       
     
     FOR r1 IN (
                  SELECT R.ID_ITEM_KLASSMATT, I1.INVENTORY_ITEM_ID, I2.INVENTORY_ITEM_ID RELATED_ITEM_ID, R.RELATIONSHIP_TYPE_ID, R.RECIPROCAL_FLAG,  
                         REL.ROWID ROWID_REL, R.ROWID ROWID_INTEGRACAO
                  FROM KLASS_INTEGRACAO_RELACIONA R
                  INNER JOIN MTL_SYSTEM_ITEMS_B I1 ON I1.Segment1 = R.CODIGO_EBS AND I1.organization_id = 121 --vid_organizacao_mestre
                  INNER JOIN MTL_SYSTEM_ITEMS_B I2 ON I2.Segment1 = R.CODIGO_EBS_RELATED AND I2.organization_id = 121 --vid_organizacao_mestre
                  LEFT JOIN MTL_RELATED_ITEMS REL ON REL.INVENTORY_ITEM_ID = I1.INVENTORY_ITEM_ID AND  REL.RELATED_ITEM_ID = I2.INVENTORY_ITEM_ID
                  WHERE R.id_item_klassmatt = p_id_item_klassmatt
                    AND ( ( nvl(p_tipo_chamada,'E') = 'E' AND status <= 1 ) OR
                          ( nvl(p_tipo_chamada,'E') = 'I' AND status  = 2 )
                        )
               )
     LOOP
     
         vmsg         := NULL;
     
          IF r1.ROWID_REL IS NULL THEN
          
            MTL_RELATED_ITEMS_PKG.INSERT_ROW(
                X_Rowid => v_Rowid, 
                X_Inventory_Item_Id => r1.INVENTORY_ITEM_ID,    
                X_Organization_Id => vid_organizacao_mestre,    
                X_Related_Item_Id =>  r1.RELATED_ITEM_ID,    
                X_Relationship_Type_Id => r1.RELATIONSHIP_TYPE_ID,
                X_Reciprocal_Flag => r1.RECIPROCAL_FLAG,    
                X_Planning_Enabled_Flag => 'N',
                X_Start_Date => NULL,           
                X_End_Date  => NULL,            
                X_Attr_Context    => NULL,       
                X_Attr_Char1   => NULL,     
                X_Attr_Char2   => NULL,     
                X_Attr_Char3   => NULL,     
                X_Attr_Char4   => NULL,     
                X_Attr_Char5   => NULL,     
                X_Attr_Char6   => NULL,     
                X_Attr_Char7   => NULL,     
                X_Attr_Char8   => NULL,     
                X_Attr_Char9   => NULL,     
                X_Attr_Char10  => NULL,        
                X_Attr_Num1    => NULL,      
                X_Attr_Num2     => NULL,     
                X_Attr_Num3      => NULL,    
                X_Attr_Num4        => NULL,  
                X_Attr_Num5        => NULL,  
                X_Attr_Num6       => NULL,   
                X_Attr_Num7      => NULL,    
                X_Attr_Num8       => NULL,   
                X_Attr_Num9       => NULL,   
                X_Attr_Num10     => NULL,  
                X_Attr_Date1     => NULL,    
                X_Attr_Date2     => NULL,    
                X_Attr_Date3     => NULL,    
                X_Attr_Date4     => NULL,    
                X_Attr_Date5      => NULL,   
                X_Attr_Date6     => NULL,    
                X_Attr_Date7      => NULL,   
                X_Attr_Date8       => NULL,  
                X_Attr_Date9       => NULL,  
                X_Attr_Date10       => NULL, 
                X_Last_Update_Date    => sysdate,  
                X_Last_Updated_By       => l_fnd_user_id,
                X_Creation_Date        => sysdate,   
                X_Created_By            => l_fnd_user_id,
                X_Object_Version_Number  => 1 ,
                X_Last_Update_Login     => NULL  
  
              );
          ELSE
          
              MTL_RELATED_ITEMS_PKG.UPDATE_ROW(
                X_Rowid => r1.ROWID_REL, 
                X_Inventory_Item_Id => r1.INVENTORY_ITEM_ID,    
                X_Organization_Id => vid_organizacao_mestre,    
                X_Related_Item_Id =>  r1.RELATED_ITEM_ID,    
                X_Relationship_Type_Id => r1.RELATIONSHIP_TYPE_ID,
                X_Reciprocal_Flag => r1.RECIPROCAL_FLAG,    
                X_Planning_Enabled_Flag => 'N',
                X_Start_Date => NULL,           
                X_End_Date  => NULL,            
                X_Attr_Context    => NULL,       
                X_Attr_Char1   => NULL,     
                X_Attr_Char2   => NULL,     
                X_Attr_Char3   => NULL,     
                X_Attr_Char4   => NULL,     
                X_Attr_Char5   => NULL,     
                X_Attr_Char6   => NULL,     
                X_Attr_Char7   => NULL,     
                X_Attr_Char8   => NULL,     
                X_Attr_Char9   => NULL,     
                X_Attr_Char10  => NULL,        
                X_Attr_Num1    => NULL,      
                X_Attr_Num2     => NULL,     
                X_Attr_Num3      => NULL,    
                X_Attr_Num4        => NULL,  
                X_Attr_Num5        => NULL,  
                X_Attr_Num6       => NULL,   
                X_Attr_Num7      => NULL,    
                X_Attr_Num8       => NULL,   
                X_Attr_Num9       => NULL,   
                X_Attr_Num10     => NULL,  
                X_Attr_Date1     => NULL,    
                X_Attr_Date2     => NULL,    
                X_Attr_Date3     => NULL,    
                X_Attr_Date4     => NULL,    
                X_Attr_Date5      => NULL,   
                X_Attr_Date6     => NULL,    
                X_Attr_Date7      => NULL,   
                X_Attr_Date8       => NULL,  
                X_Attr_Date9       => NULL,  
                X_Attr_Date10       => NULL, 
                X_Last_Update_Date    => sysdate,  
                X_Last_Updated_By       => l_fnd_user_id,
                X_Last_Update_Login     => NULL  
  
              );
              
          
          END IF;
          
          BEGIN
          UPDATE KLASS_INTEGRACAO_RELACIONA
                   SET status    = 3
           WHERE ROWID = r1.ROWID_INTEGRACAO;
      
          EXCEPTION
              WHEN OTHERS THEN
                 vmsg_retorno := '1 - Erro ao alterar a tabela KLASS_INTEGRACAO_RELACIONA : p_id_item_klassmatt ' ||
                                 r1.id_item_klassmatt || ' - ' || SQLERRM;
                 RAISE erro;
          END;
        
     END LOOP;
     
     -- MARCA COM ERRO OS QUE NÃO ENTRARAM NO CURSOR - INVENTORY_ITEM_ID INEXISTENTE
     UPDATE KLASS_INTEGRACAO_RELACIONA
         SET status    = 4
     WHERE status = 2 AND id_item_klassmatt = p_id_item_klassmatt
        AND ( ( nvl(p_tipo_chamada,'E') = 'E' AND status <= 1 ) OR
              ( nvl(p_tipo_chamada,'E') = 'I' AND status  = 2 ));
       
     IF SQL%ROWCOUNT > 0 THEN
        vmsg_retorno :=  'ALGUNS DOS ITENS RELACIONADOS NÃO EXISTEM NO EBS';
     ELSE
        vmsg_retorno := 'OK';
     END IF;
     
     IF nvl(p_tipo_chamada,'E') = 'E' THEN
          -------
          COMMIT;
          -------
     END IF;
    
     -------------
     RETURN vmsg_retorno;
     -------------

  EXCEPTION
      WHEN erro THEN
        RETURN (vmsg_retorno);

      WHEN OTHERS THEN
        RETURN ('Erro Geral funcao manutencao_item_related : '|| SQLERRM);

  
END manutencao_item_related;

------------------------------------------------------------------------------------------------

/**************************************************************
   Função que faz a integração do klassmatt com o ebs em relação
   aos anexos
***************************************************************/

FUNCTION manutencao_item_anexos(p_id_item_klassmatt       IN VARCHAR2,
                                p_codigo_item             IN VARCHAR2,
                                p_tipo_chamada            IN VARCHAR2 )  -- I - interna   E - externa
                                       RETURN VARCHAR2 
IS

    l_fnd_user_id varchar(100);
    vmsg                     VARCHAR2(3000);
    vmsg_retorno             VARCHAR2(3000);
    vcount number;
    
    l_document_id NUMBER; 
    l_media_id NUMBER;
    l_attached_document_id NUMBER; 
    l_qtd_documents number;
    l_ja_existe_doc number;
    
    
BEGIN
 
     ---> se for chamada externa então seta a responsabilidade
     
     gera_log_tabela(v_sequencia_processamento
                             ,'manutencao_item_anexos - INI - p_id_item_klassmatt =  ' || p_id_item_klassmatt
                             ,SYSDATE
                             ,'P'
                             ,v_nome_concorrente
                             ,v_debug);
                             
                             
     IF nvl(p_tipo_chamada,'E') = 'E' THEN
         vmsg := seta_responsabilidade;
         
          SELECT attribute1
            INTO vid_organizacao_mestre   --- variavel global
            FROM klass_configuracao
         WHERE tipo = 'ID_ORGANIZACAO_MESTRE';
           
     END IF; 
 
    l_fnd_user_id := fnd_profile.value('user_id');
    
    -- SE TEM REGISTROS PARA ESSE ITEM NA TABELA E ESTÃO COM 3 OU 4 É 
    -- PORQUE ESTÁ REPROCESSANDO SOMENTE A KLASS_INTEGRACAO_EBS. 
    -- ENTAO, NÃO DEVE INATIVAR NENHUM ANEXO
    SELECT COUNT(1) 
    INTO vcount
    FROM KLASS_INTEGRACAO_ANEXO
    WHERE id_item_klassmatt = p_id_item_klassmatt
    AND STATUS IN( 3, 4);
        
    IF (vcount = 0)  THEN
      
      -- APAGA OS ANEXOS QUE NÃO EXISTEM MAIS
      DELETE FROM fnd_attached_documents 
      WHERE attached_document_id IN(
        SELECT att.attached_document_id FROM mtl_system_items_b b 
        INNER JOIN apps.fnd_attached_documents att ON b.INVENTORY_ITEM_ID = att.pk2_value 
        INNER JOIN fnd_documents_tl doc ON doc.document_id = att.document_id
        WHERE b.segment1 = p_codigo_item AND att.created_by = l_fnd_user_id
        AND NOT EXISTS(
          SELECT 1 FROM klass_integracao_anexo kia
          WHERE  kia.codigo_ebs = b.segment1 
          AND    kia.title = doc.title 
          AND    kia.description = doc.description)
      );

    END IF;
    
    
    


     ---> O parâmetro p_id_item_klassmatt deve vir sempre preenchido. 
     ---  O código do item irá vir preenchido quando for uma chamada interna do procedimento
     ---  quando for uma chamada externa, direta, o código poderá vir em branco e ele irá pegar da tabela.       
     
     FOR r1 IN (
                 SELECT a.ROWID
                       ,a.*, I.INVENTORY_ITEM_ID
                   FROM KLASS_INTEGRACAO_ANEXO   a
                   INNER JOIN mtl_system_items_b I
                   ON i.segment1 = a.codigo_ebs AND i.organization_id = vid_organizacao_mestre
                  WHERE a.id_item_klassmatt = p_id_item_klassmatt
                    AND ( ( nvl(p_tipo_chamada,'E') = 'E' AND status <= 1 ) OR
                          ( nvl(p_tipo_chamada,'E') = 'I' AND status  = 2 )
                        )
               )
     LOOP
     
         vmsg         := NULL;
     
        -- VALIDA SE EXISTE O DOCUMENTO
        
        SELECT MAX(DOCUMENT_ID) 
        INTO l_document_id
        FROM apps.fnd_documents_tl
        WHERE TITLE = r1.TITLE AND DESCRIPTION = r1.DESCRIPTION
        AND CREATED_BY = l_fnd_user_id;
                                                         
        
        IF( l_document_id = 0 or l_document_id IS NULL ) THEN
                    
            -- CRIA O DOCUMENTO    
            SELECT apps.fnd_documents_short_text_s.NEXTVAL, apps.fnd_documents_s.NEXTVAL
            INTO l_media_id, l_document_id
            FROM DUAL;
            
            INSERT INTO apps.fnd_documents 
            (document_id, 
            creation_date, 
            created_by, 
            last_update_date, 
            last_updated_by, 
            datatype_id, 
            category_id, 
            security_type, 
            security_id, 
            publish_flag, 
            usage_type , 
            media_id
            ) 
            VALUES 
            (l_document_id, 
            SYSDATE, 
            l_fnd_user_id, 
            SYSDATE, 
            l_fnd_user_id, 
            r1.DATATYPE, 
            r1.DOC_CATEGORY, 
            1, -- 'Organization' Level Security 
            vid_organizacao_mestre, -- Organization id for Inventory Item Master Org 
            'Y', -- Publish_flag 
            'S',
            l_media_id
            ); 
            
            INSERT INTO apps.fnd_documents_tl (document_id, creation_date,created_by, last_update_date, last_updated_by,  language,  description,  title, media_id,  source_lang )  
            VALUES  (l_document_id,  SYSDATE,  l_fnd_user_id,  SYSDATE,  l_fnd_user_id,  'ESA',  r1.description,  r1.title, null, 'PTB' ); 
            
            INSERT INTO apps.fnd_documents_tl (document_id, creation_date,created_by, last_update_date, last_updated_by,  language,  description,  title, media_id,  source_lang )  
            VALUES  (l_document_id,  SYSDATE,  l_fnd_user_id,  SYSDATE,  l_fnd_user_id,  'PTB',  r1.description,  r1.title, null,  'PTB' ); 
    
            INSERT INTO apps.fnd_documents_tl (document_id, creation_date,created_by, last_update_date, last_updated_by,  language,  description,  title, media_id,  source_lang )  
            VALUES  (l_document_id,  SYSDATE,  l_fnd_user_id,  SYSDATE,  l_fnd_user_id,  'US',  r1.description,  r1.title, null,  'PTB' ); 
       
             
            INSERT INTO fnd_documents_short_text
            (media_id, 
            short_text 
            ) 
            VALUES 
            (l_media_id, 
            r1.long_description
            ); 
    
      END IF;
      
      SELECT COUNT(1), COUNT( CASE WHEN document_id = l_document_id THEN 1 ELSE NULL END )
      INTO l_qtd_documents, l_ja_existe_doc
      FROM apps.fnd_attached_documents 
      WHERE pk2_value = TO_CHAR(r1.INVENTORY_ITEM_ID);
      
      IF( l_ja_existe_doc = 0 or l_ja_existe_doc IS NULL ) THEN    
      
        l_qtd_documents := (l_qtd_documents + 1) * 10;
        
        INSERT INTO apps.fnd_attached_documents (attached_document_id, document_id, creation_date, created_by, last_update_date, last_updated_by, seq_num, entity_name, pk1_value, pk2_value, automatically_added_flag, category_id ) 
        VALUES (apps.fnd_attached_documents_s.NEXTVAL, l_document_id, SYSDATE, l_fnd_user_id, SYSDATE, l_fnd_user_id, 
        l_qtd_documents, -- Sequence Number of attachment. 
        'MTL_SYSTEM_ITEMS', -- Entity_name Table Name assoicated with attachment 
        vid_organizacao_mestre, -- Organization id for Inventory Item Master Org 
        r1.INVENTORY_ITEM_ID, -- Inventory Item Id 
        'N', -- Automatically_added_flag 
        r1.DOC_CATEGORY
        );
    
      END IF;
      
      BEGIN
          UPDATE KLASS_INTEGRACAO_ANEXO
                   SET status    = 3
           WHERE ROWID = r1.ROWID;
      
          EXCEPTION
              WHEN OTHERS THEN
                 vmsg_retorno := '1 - Erro ao alterar a tabela KLASS_INTEGRACAO_ANEXO : p_id_item_klassmatt ' ||
                                 r1.id_item_klassmatt || ' - ' || SQLERRM;
                 RAISE erro;
      END;

     END LOOP;
     
    
     ---> Se o código do item é nulo, indica que é uma chamada externa e tem que dar commit
     
     IF nvl(p_tipo_chamada,'E') = 'E' THEN
          -------
          COMMIT;
          -------
     END IF;
    
     -------------
     RETURN ('OK');
     -------------

  EXCEPTION
      WHEN erro THEN
        RETURN (vmsg_retorno);

      WHEN OTHERS THEN
        RETURN ('Erro Geral funcao MANUTENCAO_ITEM_ANEXOS : '|| SQLERRM);

  END manutencao_item_anexos;
  
  ------------------------------------------------------------------------------------------------
  /**************************************************************
   Função que faz a integração do klassmatt com o ebs em relação
   aos itens e sua referência com os itens dos fornecedores
  ***************************************************************/

  FUNCTION manutencao_item_fornecedor (p_id_item_klassmatt       IN VARCHAR2
                                      ,p_codigo_item             IN VARCHAR2
                                      ,p_tipo_chamada            IN VARCHAR2 )  -- I - interna   E - externa
                                       RETURN VARCHAR2 IS

    vmsg                     VARCHAR2(3000);
    vmsg_retorno             VARCHAR2(3000);
    vcodigo_item             VARCHAR2(100);
   

  BEGIN
 
 
   
  gera_log_tabela(v_sequencia_processamento
                             ,'item_fornecedor_end_date - INI - p_id_item_klassmatt =  ' || p_id_item_klassmatt
                             ,SYSDATE
                             ,'P'
                             ,v_nome_concorrente
                             ,v_debug);
                             
                             
     ---> se for chamada externa então seta a responsabilidade
     
     IF nvl(p_tipo_chamada,'E') = 'E' THEN
         vmsg := seta_responsabilidade;
     END IF; 
 
     
     ---> Verifica o end_date se tem ou não que atualizar
     
     vmsg_retorno := item_fornecedor_end_date ( p_id_item_klassmatt     
                                               ,p_codigo_item            
                                               ,p_tipo_chamada   );
                                       
     IF vmsg_retorno <> 'OK' THEN
         RAISE erro;
     END IF; 
 
 
     ---> O parâmetro p_id_item_klassmatt deve vir sempre preenchido. 
     ---  O código do item irá vir preenchido quando for uma chamada interna do procedimento
     ---  quando for uma chamada externa, direta, o código poderá vir em branco e ele irá pegar da tabela.       
     
     FOR r1 IN (
                 SELECT ROWID
                       ,a.*
                   FROM klass_integracao_ebs_ref   a
                  WHERE a.id_item_klassmatt = p_id_item_klassmatt
                    AND ( ( nvl(p_tipo_chamada,'E') = 'E' AND status = 0 ) OR
                          ( nvl(p_tipo_chamada,'E') = 'I' AND status = 2 )
                        )
               )
     LOOP
     
         vcodigo_item := NULL;
         vmsg         := NULL;
     
         ---> o código do item é a base para integração e por isso a consistência dele é inicial
     
         IF p_codigo_item IS NOT NULL THEN
             vcodigo_item := p_codigo_item;
         ELSE
             IF r1.codigo_ebs IS NULL THEN
                vmsg := 'Erro na funcao MANUTENCAO_ITEM_FORNECEDOR - codigo item ebs não encontrado - id_item_klassmatt = ' ||
                                r1.id_item_klassmatt;
             ELSE
                vcodigo_item := r1.codigo_ebs;
             END IF;
         END IF;
          
     
         ---> Consiste informações da interface de referência e faz a gravação nas tabelas do ebs
     
         IF vcodigo_item IS NOT NULL THEN
     
               vmsg := consiste_item_fornecedor ( p_id_item_klassmatt       => p_id_item_klassmatt
                                                 ,p_codigo_item             => vcodigo_item
                                                 ,p_manufacturer_name       => r1.manufacturer_name
                                                 ,p_description             => r1.description
                                                 ,p_codigo_fabricante_klass => r1.codigo_fabricante_klass
                                                 ,p_mfg_part_num            => r1.mfg_part_num
                                                 ,p_attribute_Category      => r1.attribute_category
                                                 );                                                 
         END IF;
         
         
         IF vmsg <> 'OK' THEN
              
              BEGIN
                  UPDATE klass_integracao_ebs_ref
                           SET status    = 4        --- integração erro
                              ,desc_erro = vmsg
                   WHERE ROWID = r1.ROWID;
              
                  EXCEPTION
                      WHEN OTHERS THEN
                         vmsg_retorno := '1 - Erro ao alterar a tabela klass_integracao_ebs_ref : p_id_item_klassmatt ' ||
                                         r1.id_item_klassmatt || ' - ' || SQLERRM;
                         RAISE erro;
              END;
              
         ELSE
         
              BEGIN
                  UPDATE klass_integracao_ebs_ref
                           SET status    = 3 -- sucesso EBS
                   WHERE ROWID = r1.ROWID;
              
                  EXCEPTION
                      WHEN OTHERS THEN
                         vmsg_retorno := '2 - Erro ao alterar a tabela klass_integracao_ebs_ref : p_id_item_klassmatt ' ||
                                         r1.id_item_klassmatt || ' - ' || SQLERRM;
                         RAISE erro;
              END;
              
         END IF;
     
     END LOOP;
     
    
     ---> Se o código do item é nulo, indica que é uma chamada externa e tem que dar commit
     
     IF nvl(p_tipo_chamada,'E') = 'E' THEN
          -------
          COMMIT;
          -------
     END IF;
    
     -------------
     RETURN ('OK');
     -------------

  EXCEPTION
      WHEN erro THEN
        RETURN (vmsg_retorno);

      WHEN OTHERS THEN
        RETURN ('Erro Geral funcao MANUTENCAO_ITEM_FORNECEDOR : '|| SQLERRM);

  END manutencao_item_fornecedor;

  ------------------------------------------------------------------------------------------------
  /**************************************************************
   Função que verifica se tem alteração de linguagem que, pelo nativo,
   é feito via trigger a partir de um update na TL.
  ***************************************************************/

  FUNCTION verifica_alteracao_linguagem (p_id_item_klassmatt       IN VARCHAR2
                                        ,p_codigo_item             IN VARCHAR2 ) RETURN VARCHAR2 IS

    vmsg                     VARCHAR2(3000);
    vinventory_item_id       NUMBER;
    vdescription             VARCHAR2(1000);
    vlong_description        VARCHAR2(1000);
    vlanguage_context        VARCHAR2(1000);
    vcont                    NUMBER;

  BEGIN

        ---> verifica se jã fez para o item ou não

        SELECT COUNT(*)
          INTO vcont
          FROM klass_integracao_linguagem
          WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                         FROM klass_integracao_ebs
                                        WHERE id_item_klassmatt = p_id_item_klassmatt )
            AND status = 2;

        IF vcont = 0 THEN
            RETURN ('OK');
        END IF;

        ---> Guarda as informações de descrição e descrição longa da mestre em português para fazer e acertar por último

        SELECT description
              ,long_description
              ,inventory_item_id
          INTO vdescription
              ,vlong_description
              ,vinventory_item_id
          FROM mtl_system_items_tl
         WHERE LANGUAGE          = 'PTB'
           AND inventory_item_id IN ( SELECT inventory_item_id
                                        FROM mtl_system_items_b
                                       WHERE segment1 = p_codigo_item )
           AND organization_id = (SELECT to_number(attribute1)
                                    FROM klass_configuracao
                                   WHERE tipo = 'ID_ORGANIZACAO_MESTRE' );

        ---> Acessa as languages que irão ser alteradas menos o PTB

        FOR r1 IN ( SELECT *
                      FROM klass_integracao_linguagem
                      WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                                     FROM klass_integracao_ebs
                                                    WHERE id_item_klassmatt = p_id_item_klassmatt )
                        AND status = 2
                        AND linguagem_code <> 'PTB'
                  )
        LOOP

           ---> encontra o language context

           SELECT nls_language
             INTO vlanguage_context
             FROM apps.fnd_languages
            WHERE language_code = r1.linguagem_code;

           ---> Seta a linguagem

           fnd_global.set_nls_context(vlanguage_context);

           ---> Primeiro faz a mestre

           FOR r2 IN (
                      SELECT to_number(attribute1)  organization_id
                        FROM klass_configuracao
                       WHERE tipo = 'ID_ORGANIZACAO_MESTRE'
                     )
           LOOP

               vmsg := altera_desc_linguagem ( p_inventory_item_id => vinventory_item_id
                                              ,p_description       => substr(r1.descricao_media,1,240)
                                              ,p_long_description  => r1.descricao_completa
                                              ,p_organization_id   => r2.organization_id
                                              );

               IF vmsg <> 'OK' THEN
                      RAISE erro;
               END IF;

           END LOOP;


           ---> Depois de fazer a mestre, faz os filhos


           FOR r2 IN (
                        SELECT DISTINCT organization_id
                          FROM mtl_system_items_b
                         WHERE segment1 = p_codigo_item
                           AND organization_id NOT IN ( SELECT to_number(attribute1)
                                                           FROM klass_configuracao
                                                          WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
                     )
           LOOP

              vmsg := altera_desc_linguagem ( p_inventory_item_id => vinventory_item_id
                                             ,p_description       => substr(r1.descricao_media,1,240)
                                             ,p_long_description  => r1.descricao_completa
                                             ,p_organization_id   => r2.organization_id
                                              );

               IF vmsg <> 'OK' THEN
                   RAISE erro;
               END IF;

           END LOOP;

      END LOOP; --- languages

      ----------------------------
      -- Agora faz o acerto do PTB
      ----------------------------

      ---> Seta a linguagem PARA PTB

       fnd_global.set_nls_context('BRAZILIAN PORTUGUESE');

       ---> Primeiro faz a mestre

       FOR r2 IN (
                  SELECT to_number(attribute1)   organization_id
                    FROM klass_configuracao
                   WHERE tipo = 'ID_ORGANIZACAO_MESTRE'
                 )
       LOOP

           vmsg := altera_desc_linguagem ( p_inventory_item_id => vinventory_item_id
                                          ,p_description       => vdescription
                                          ,p_long_description  => vlong_description
                                          ,p_organization_id   => r2.organization_id
                                          );

           IF vmsg <> 'OK' THEN
                  RAISE erro;
           END IF;

       END LOOP;


       ---> Depois de fazer a mestre, faz os filhos


       FOR r2 IN (
                    SELECT DISTINCT organization_id
                      FROM mtl_system_items_b
                     WHERE segment1 = p_codigo_item
                       AND organization_id NOT IN ( SELECT to_number(attribute1)
                                                       FROM klass_configuracao
                                                      WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
                 )
       LOOP

          vmsg := altera_desc_linguagem ( p_inventory_item_id => vinventory_item_id
                                         ,p_description       => vdescription
                                         ,p_long_description  => vlong_description
                                         ,p_organization_id   => r2.organization_id
                                          );

           IF vmsg <> 'OK' THEN
               RAISE erro;
           END IF;

       END LOOP;

       ---> Seta o status da tabela de interface

      UPDATE klass_integracao_linguagem
         SET status    = 3
       WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                         FROM klass_integracao_ebs
                                        WHERE id_item_klassmatt = p_id_item_klassmatt )
          AND status = 2;


     ---> volta a linguagem original

     fnd_global.set_nls_context(g_nls_language);

     -------------
     RETURN ('OK');
     -------------

  EXCEPTION
      WHEN erro THEN
        fnd_global.set_nls_context(g_nls_language);
        RETURN (vmsg);

      WHEN OTHERS THEN
        fnd_global.set_nls_context(g_nls_language);
        RETURN ('Erro Geral funcao VERIFICA_ALTERACAO_LINGUAGEM : '|| SQLERRM);

  END verifica_alteracao_linguagem;


  /****************************************************************************************************
   Função que verifica se existe algum concorrente de integração (inclusão/alteração de item)
   rodando, ou seja, com status P na tabela de controle. Se possuir, a tabela de concorrentes
   do ebs deve ser acessada para certificar se esse concorrente está com status P. Se estiver, um erro
   deverá ser disparado, pois somente um concorrente de integração poderá ser rodado por vez.
  *****************************************************************************************************/

  FUNCTION verifica_integracao_pendente
  RETURN VARCHAR2 IS

      msg_retorno          VARCHAR2(5000);
      contador             NUMBER;

  BEGIN

      msg_retorno := 'OK';

      ---> leitura dos concorrentes da tabela de controle com status_execucao = S

      SELECT COUNT(*)
        INTO contador
        FROM klass_integracao_controle
       WHERE status_execucao NOT IN ('C','E');

      IF contador > 0 THEN

          ---> Ajusta as tabelas com problemas - klass_integracao somente é chamada de 1 em 1 vez
          ---  Se chamasse duas vezes concomitamente não seria possível limpar automaticamente

          msg_retorno := retorna_acao_pendencia;

      END IF;

      RETURN(msg_retorno);

  END verifica_integracao_pendente;

  /****************************************************************************
   Procedure que altera a tabela de controle
  *****************************************************************************/
  PROCEDURE altera_tabela_controle(p_mensagem  IN  VARCHAR2) IS PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN

   gera_log_tabela(v_sequencia_processamento
                           ,'Excluindo tabela de controle em S e colocando 2 na tabela integracao klassmatt'
                           ,SYSDATE
                           ,'P'
                           ,v_nome_concorrente
                           ,v_debug);

    ---> Altera registros para com erro na tabela integração do klassmatt

    FOR r1 IN (
                SELECT *
                  FROM klass_integracao_controle
                 WHERE status_execucao = 'S'
              )
    LOOP

       ---> Coloca a msg de erro na linha lida do klassmatt

       UPDATE klass_integracao_oi_item
         SET status    = 4        --- integração erro
        WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                       FROM klass_integracao_ebs
                                      WHERE id_item_klassmatt = r1.id_item_klassmatt
                                        AND status            = 2 )
          AND status = 2;

          
       UPDATE klass_integracao_linguagem
         SET status    = 4        --- integração erro
        WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                       FROM klass_integracao_ebs
                                      WHERE id_item_klassmatt = r1.id_item_klassmatt
                                        AND status            = 2 )
          AND status = 2;
          
          
       UPDATE klass_integracao_ebs_ref
         SET status    = 4        --- integração erro
            ,desc_erro = p_mensagem
        WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                       FROM klass_integracao_ebs
                                      WHERE id_item_klassmatt = r1.id_item_klassmatt
                                        AND status            = 2 )
          AND status = 2;
          

       UPDATE klass_integracao_ebs
         SET status    = 4        --- integração erro
            ,desc_erro = p_mensagem
        WHERE ROWID = r1.rowid_tabela_integracao;


    END LOOP;

    ---> exclui registros com status S na tabela de controle

    DELETE FROM klass_integracao_controle
      WHERE status_execucao = 'S';    --- pendente na interface

    COMMIT;

    EXCEPTION

    WHEN OTHERS THEN
            gera_log_tabela(v_sequencia_processamento
                           ,'20020 - Erro Oracle: '||sqlerrm
                           ,SYSDATE
                           ,'P'
                           ,v_nome_concorrente
                           ,v_debug);
            raise_application_error(-20020,'Erro Oracle: '||sqlerrm);

  END;

  /***************************************************************************
   Função que executa o concorrente NATIVO de inclusão ou alteração de itens
  ****************************************************************************/

  FUNCTION executa_concorrente( p_tipo_operacao  IN VARCHAR2
                               ,p_request_id    OUT NUMBER)
                 RETURN VARCHAR2 IS

    wrequest_id              NUMBER DEFAULT 0;
    v_argumento7             VARCHAR2(10);    --- tipo operação alteração / inclusão
    v_argumento6             VARCHAR2(10);    --- set_process_id
    v_argumento5             VARCHAR2(10);    --- exclui as linhas com sucesso da interface


  BEGIN

  
     /*
      Como irão ser rodados quase que juntos os concorrentes de alteração e inclusão,
      eles deverão estar em set_process_id diferentes (v_argumento6). Contudo, as interfaces
      de itens e categorias de itens deverão possuir o mesmo process_id.
     */

     IF p_tipo_operacao = 'CREATE' THEN
          v_argumento7 := '1';
          v_argumento6 := '60';
     ELSE
          v_argumento7 := '2';
          v_argumento6 := '70';
     END IF;

     ---> Se é para debugar a package então não exclui registros integrados da interface

     IF v_debug = 'S' THEN
         v_argumento5 := '2';
     ELSE
         v_argumento5 := '1';
     END IF;


     gera_log_tabela(v_sequencia_processamento
                      ,'Executando concorrente ' || p_tipo_operacao || ' ...'
                      ,SYSDATE
                      ,'P'
                      ,v_nome_concorrente
                      ,v_debug);


     wrequest_id := fnd_request.submit_request(application =>  'INV',          --- Aplicação
                                                program     => 'INCOIN',       --- Executável
                                                description => NULL,
                                                start_time  => NULL,
                                                sub_request => FALSE,
                                                argument1   => fnd_profile.value('ORG_ID'),
                                                argument2   => '1',            --- sim
                                                argument3   => '1',            --- 1 - sim
                                                argument4   => '1',            --- sim
                                                argument5   => v_argumento5,   --- SIM --- EXCLUI AS LINHAS COM SUCESSO
                                                argument6   => v_argumento6,   --- PROCESS_ID A SER EXECUTADO
                                                argument7   => v_argumento7);  --- 1 - inclusão , 2 - alteração
    IF wrequest_id = 0 THEN
        RAISE erro;
    END IF;

    p_request_id:= wrequest_id;

    RETURN 'OK';

  EXCEPTION
    WHEN erro THEN
      ROLLBACK;
      gera_log_tabela(v_sequencia_processamento
                      ,'-20013 - Solicitacao voltou zerada. Não gerou o concorrente.'
                      ,SYSDATE
                      ,'P'
                      ,v_nome_concorrente
                      ,v_debug);
      RETURN '-20013 - Solicitacao voltou zerada. Não gerou o concorrente.';
    WHEN OTHERS THEN
      ROLLBACK;
      RETURN '-20003, Erro ao enviar solicitação. '||SQLERRM;

  END executa_concorrente;


  /***************************************************************************
   Função que retorna o status do concorrente mestre se rodou ok
  ****************************************************************************/

  FUNCTION status_concorrente(p_request_id IN NUMBER)
                 RETURN VARCHAR2 IS


    wcontrole          NUMBER;
    wphase_code        fnd_concurrent_requests.phase_code%TYPE;

    BEGIN

      gera_log_tabela(v_sequencia_processamento
                      ,'Verificando status execucao concorrente - ' || p_request_id
                      ,SYSDATE
                      ,'P'
                      ,v_nome_concorrente
                      ,v_debug);


      wcontrole  := 10000;
      wphase_code:= 'X';

      WHILE wphase_code <> 'C' LOOP

        wcontrole:=wcontrole - 1;

        IF wcontrole = 0 THEN

           BEGIN

               SELECT phase_code
                 INTO wphase_code
                 FROM fnd_concurrent_requests
                WHERE request_id = p_request_id;

               EXCEPTION
                  WHEN no_data_found THEN
                     wphase_code:='C';

           END;

           wcontrole:=10000;

        END IF;

      END LOOP;

      RETURN 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      gera_log_tabela(v_sequencia_processamento
                      ,'Erro ao aguardar execução do concorrente. '||SQLERRM
                      ,SYSDATE
                      ,'P'
                      ,v_nome_concorrente
                      ,v_debug);

      RETURN('Erro ao aguardar execução do concorrente. '||SQLERRM);

  END status_concorrente;


  /*************************************************************
   Procedure para gerar o log a ser gravado passo a passo
  *************************************************************/

  PROCEDURE gera_log_tabela(p_id_processamento       IN NUMBER
                           ,p_mensagem               IN VARCHAR2
                           ,p_data_processamento     IN DATE
                           ,p_status                 IN VARCHAR2
                           ,p_nome_concorrente       IN VARCHAR2
                           ,p_debug                  IN VARCHAR2)
    IS PRAGMA AUTONOMOUS_TRANSACTION;

       v_sequencia             NUMBER;

    BEGIN

    ---> sequencia do log

    SELECT klass_integracao_seq.NEXTVAL
      INTO v_sequencia
      FROM dual;


    IF ( p_debug = 'S' AND p_status IS NOT NULL ) OR
       ( p_status IS NULL ) THEN   ---> Só grava se debug = SIM

      INSERT INTO klass_integracao_log
                       ( id_processamento
                        ,mensagem
                        ,data_processamento
                        ,status
                        ,nome_concorrente
                        ,sequencia
                        )
                  VALUES
                       ( p_id_processamento
                        ,p_mensagem
                        ,p_data_processamento
                        ,p_status
                        ,p_nome_concorrente
                        ,v_sequencia
                       );
      COMMIT;

    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20004,'Erro Oracle: '||sqlerrm);

  END gera_log_tabela;


  /*************************************************************
   Function que faz a verificação de tudo que está com status S na tabela
   de controle, ou seja, que rodou nessa aplicação. Todas as interfaces
   geradas que estão com erros, deverão ser retornadas ao klassmatt e
   enviar e-mail cadastrado em uma profile.
  *************************************************************/

  FUNCTION verifica_status_interfaces (p_parametro  IN VARCHAR2)  RETURN VARCHAR2 IS

       msg_retorno            VARCHAR2(5000);
       mensagem               VARCHAR2(5000);
       erro_interface         NUMBER;
       vparametro             VARCHAR2(1000);
       vcont                  NUMBER;
       msg_retorno_email      VARCHAR2(1000);
       vprocess_flag          NUMBER;
       vtransaction_id        NUMBER;


  BEGIN

     gera_log_tabela(v_sequencia_processamento
                      ,'Verificando os status das interfaces ...'
                      ,SYSDATE
                      ,'P'
                      ,v_nome_concorrente
                      ,v_debug);


     vparametro := p_parametro;  -- inicial ou final

     ---> acessa o cursor de todos as execuções pendentes na tabela de controle

     FOR r1 IN (
                 SELECT *
                   FROM klass_integracao_controle
                  WHERE status_execucao = 'S'
               )
     LOOP

         erro_interface := 0;

         ---> se operaçao for update e somente existir a mestre, o parametro entra como final

         IF ( r1.tipo_operacao = 'UPDATE' AND p_parametro = 'inicial' ) THEN

             SELECT COUNT(*)
               INTO vcont
               FROM mtl_system_items_b
              WHERE segment1        = r1.codigo_item
                AND organization_id NOT IN (SELECT to_number(attribute1)
                                              FROM klass_configuracao
                                             WHERE tipo = 'ID_ORGANIZACAO_MESTRE' );

             IF vcont = 0 THEN
                 vparametro := 'final';
             END IF;

         END IF;

         IF r1.tipo_operacao      = 'CREATE' THEN
              IF vcreate_organizations = 'N' THEN
                  vparametro := 'final';
              ELSE
                  ---> quando for gabarito ele pode incluir somente a mestre
                  ---  quando for só a mestre o parâmetro tem que ser final

                  SELECT COUNT(*)
                    INTO vcont
                    FROM klass_integracao_ebs
                   WHERE status            = 2
                     AND id_item_klassmatt = r1.id_item_klassmatt
                     AND item_gabarito     IS NOT NULL;

                  IF vcont > 0 THEN

                        SELECT COUNT(*)
                          INTO vcont
                          FROM klass_integracao_ebs
                         WHERE status            = 2
                           AND id_item_klassmatt = r1.id_item_klassmatt
                           AND item_gabarito     IS NOT NULL
                           AND EXISTS ( SELECT 1
                                          FROM klass_integracao_oi_item
                                         WHERE status            = 2
                                           AND id_item_klassmatt = klass_integracao_oi_item.id_item_klassmatt
                                           AND organization_id NOT IN (SELECT to_number(attribute1)
                                                                         FROM klass_configuracao
                                                                        WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
                                      );

                        IF vcont = 0 THEN
                            vparametro := 'final';
                        END IF;

                   END IF;

              END IF;
         END IF;


         ---> Para cada registro, pelo request_id, acessa as interfaces de itens e
         ---  categorias relativas. Se erro, monta msg e manda e-mail, bem como atualiza
         ---  o registro na tabela de controle como erro (status_execucao = E) e a tabela
         ---  de interface do klassmatt.

         ---> interface de itens

         gera_log_tabela(v_sequencia_processamento
                      ,'Verificando os status das interfaces do item ' ||
                        r1.codigo_item || ' organization_id ' || r1.organization_id
                      ,SYSDATE
                      ,'P'
                      ,v_nome_concorrente
                      ,v_debug);


         msg_retorno := NULL;

         BEGIN

              SELECT process_flag
                    ,transaction_id
                INTO vprocess_flag
                    ,vtransaction_id
                FROM mtl_system_items_interface
               WHERE request_id      = r1.request_id
                 AND segment1        = r1.codigo_item
                 AND organization_id = r1.organization_id;

             EXCEPTION
                 WHEN OTHERS THEN
                    mensagem  := 'Erro ao acessar o transaction_id e o process_flag ' ||
                                   'mtl_system_items_interface : req '  ||
                                   r1.request_id || ' - ' || ' item ' ||
                                         r1.codigo_item || ' - ' || ' org ' || r1.organization_id ||
                                         ' - ' || SQLERRM;

        END;

             IF vprocess_flag <> 7 THEN

                 ---> acessa o erro e envia o e-mail

                 BEGIN
                       SELECT message_name || '-coluna ' || column_name || '-' || error_message
                         INTO mensagem
                         FROM mtl_interface_errors
                        WHERE transaction_id  = vtransaction_id
                          AND rownum          = 1;

                       EXCEPTION
                         WHEN OTHERS THEN
                            mensagem  := 'Erro ao acessar o erro da interface ' ||
                                           'mtl_system_items_interface : trans '  ||
                                           vtransaction_id || ' - ' || ' item ' ||
                                                 r1.codigo_item || ' - ' || SQLERRM;

                 END;

                 ---> envia e-mail para a profile cadastrada

                 msg_retorno := envia_email(mensagem,NULL);

                 ---> altera o status_execucao da tabela

                 BEGIN

                    UPDATE klass_integracao_controle
                       SET status_execucao = 'E'
                      WHERE id_item_klassmatt       = r1.id_item_klassmatt
                        AND organization_id         = r1.organization_id
                        AND request_id              = r1.request_id
                        AND codigo_item             = r1.codigo_item
                        AND rowid_tabela_integracao = r1.rowid_tabela_integracao;

                    EXCEPTION
                       WHEN OTHERS THEN
                         msg_retorno := 'Erro ao alterar a tabela klass_integracao_controle (item) : ' ||
                                        'rowid_tabela_integracao ' || r1.rowid_tabela_integracao ||
                                        ' - ' || SQLERRM;
                         RAISE erro;

                 END;

                 ---> altera a tabela de integração do klassmatt


                 BEGIN

                    UPDATE klass_integracao_oi_item
                       SET status    = 4        --- integração erro
                      WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                                     FROM klass_integracao_ebs
                                                    WHERE id_item_klassmatt = r1.id_item_klassmatt
                                                      AND status            = 2 )
                        AND status = 2;

                     UPDATE klass_integracao_linguagem
                       SET status    = 4        --- integração erro
                      WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                                      FROM klass_integracao_ebs
                                                    WHERE id_item_klassmatt = r1.id_item_klassmatt
                                                      AND status            = 2 )
                       AND status = 2;

                       
                    UPDATE klass_integracao_ebs_ref
                       SET status    = 4        --- integração erro
                          ,desc_erro = mensagem
                      WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                                      FROM klass_integracao_ebs
                                                    WHERE id_item_klassmatt = r1.id_item_klassmatt
                                                      AND status            = 2 )
                       AND status = 2;
                       
                       
                    UPDATE klass_integracao_ebs
                       SET status    = 4
                          ,desc_erro = mensagem
                          ,atualizadoKlassmatt = 0
                      WHERE ROWID = r1.rowid_tabela_integracao;


                    EXCEPTION
                      WHEN OTHERS THEN
                         msg_retorno := 'Erro ao alterar a tabela klass_integracao_ebs (item) : ' ||
                                        'rowid_tabela_integracao ' || r1.rowid_tabela_integracao ||
                                        ' - ' || SQLERRM;
                         RAISE erro;
                 END;

                 erro_interface := 1;

                 gera_log_tabela(v_sequencia_processamento
                      ,'Erro na interface de cadastro do item : ' ||
                       r1.codigo_item || ' organization_id ' || r1.organization_id
                      ,SYSDATE
                      ,'P'
                      ,v_nome_concorrente
                      ,v_debug);

             END IF;


         ---> interface de categorias
         ---  acessa quando a mensagem for nula, caso contrário não precisa, pois já deu
         ---  problema acima.

         IF msg_retorno IS NULL AND
            erro_interface = 0 THEN

               gera_log_tabela(v_sequencia_processamento
                      ,'Verificando os status das interfaces de categorias do item ' ||
                       r1.codigo_item || ' organization_id ' || r1.organization_id
                      ,SYSDATE
                      ,'P'
                      ,v_nome_concorrente
                      ,v_debug);


               ---> Verifica se tem registros a processar com process_flag <> 7

               SELECT COUNT(1)
                 INTO vcont
                 FROM mtl_item_categories_interface
                WHERE request_id      = r1.request_id
                  AND item_number     = r1.codigo_item
                  AND organization_id = r1.organization_id
                  AND process_flag   <> '7' ;

               IF vcont > 0 THEN

                     FOR r2 IN (
                                  SELECT process_flag
                                        ,transaction_id
                                    FROM mtl_item_categories_interface
                                   WHERE request_id      = r1.request_id
                                     AND item_number     = r1.codigo_item
                                     AND organization_id = r1.organization_id
                                     AND process_flag   <> '7'
                               )
                     LOOP

                  --       IF r2.process_flag <> 7 THEN

                             ---> acessa o erro e envia o e-mail

                             BEGIN
                                   SELECT message_name || '-coluna ' || column_name
                                           || '-' || error_message
                                     INTO mensagem
                                     FROM mtl_interface_errors
                                    WHERE transaction_id  = r2.transaction_id
                                      AND rownum          = 1;

                                   EXCEPTION
                                     WHEN OTHERS THEN
                                       mensagem    := 'Erro ao acessar o erro da interface ' ||
                                                       'mtl_item_categories_interface : trans '  ||
                                                       r2.transaction_id || ' - ' || ' item ' ||
                                                       r1.codigo_item || ' - ' || SQLERRM;

                             END;

                             ---> envia e-mail para a profile cadastrada

                             msg_retorno := envia_email(mensagem,NULL);

                             ---> altera o status_execucao da tabela

                             BEGIN

                                UPDATE klass_integracao_controle
                                   SET status_execucao = 'E'
                                  WHERE id_item_klassmatt       = r1.id_item_klassmatt
                                    AND organization_id         = r1.organization_id
                                    AND request_id              = r1.request_id
                                    AND codigo_item             = r1.codigo_item
                                    AND rowid_tabela_integracao = r1.rowid_tabela_integracao;

                                EXCEPTION
                                   WHEN OTHERS THEN
                                     msg_retorno := 'Erro ao alterar a tabela klass_integracao_controle (categ) : ' ||
                                                    'rowid_tabela_integracao ' || r1.rowid_tabela_integracao ||
                                                    ' - ' || SQLERRM;
                                     RAISE erro;

                             END;

                             ---> altera a tabela de integração do klassmatt


                             BEGIN

                                UPDATE klass_integracao_oi_item
                                   SET status    = 4        --- integração erro
                                  WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                                                 FROM klass_integracao_ebs
                                                                WHERE id_item_klassmatt = r1.id_item_klassmatt
                                                                  AND status            = 2 )
                                    AND status = 2;

                                 UPDATE klass_integracao_linguagem
                                   SET status    = 4        --- integração erro
                                  WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                                                 FROM klass_integracao_ebs
                                                                WHERE id_item_klassmatt = r1.id_item_klassmatt
                                                                  AND status            = 2 )
                                    AND status = 2;

                                    
                               UPDATE klass_integracao_ebs_ref
                                   SET status    = 4        --- integração erro
                                      ,desc_erro = mensagem
                                  WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                                                  FROM klass_integracao_ebs
                                                                WHERE id_item_klassmatt = r1.id_item_klassmatt
                                                                  AND status            = 2 )
                                   AND status = 2; 
                                    
                                    
                                UPDATE klass_integracao_ebs
                                   SET status    = 4
                                      ,desc_erro = mensagem
                                      , atualizadoKlassmatt = 0
                                  WHERE ROWID = r1.rowid_tabela_integracao;


                                EXCEPTION
                                  WHEN OTHERS THEN
                                     msg_retorno := 'Erro ao alterar a tabela klass_integracao_ebs (categ) : ' ||
                                                    'rowid_tabela_integracao ' || r1.rowid_tabela_integracao ||
                                                    ' - ' || SQLERRM;
                                     RAISE erro;
                             END;

                             gera_log_tabela(v_sequencia_processamento
                                            ,'Erro na interface de cadastro de categorias do item : ' ||
                                             r1.codigo_item || ' organization_id ' || r1.organization_id
                                            ,SYSDATE
                                            ,'P'
                                            ,v_nome_concorrente
                                            ,v_debug);

                             erro_interface := 1;

                --         END IF;

                     END LOOP;   -- tabela interface de categorias

               END IF; -- process_flag <> 7

         END IF;  --- se a mensagem do item vier nula

         /*
             Se a msg for nula para categorias também, o item processou corretamente
             com isso será alterado o status da tabela de controle para Q
             - leitura para encerramento
         */

        IF erro_interface = 0 THEN

              BEGIN

                  UPDATE klass_integracao_controle
                     SET status_execucao = 'Q'
                    WHERE id_item_klassmatt       = r1.id_item_klassmatt
                      AND organization_id         = r1.organization_id
                      AND request_id              = r1.request_id
                      AND codigo_item             = r1.codigo_item
                      AND rowid_tabela_integracao = r1.rowid_tabela_integracao;

                  EXCEPTION
                     WHEN OTHERS THEN
                       msg_retorno := 'Erro ao alterar a tabela klass_integracao_controle (status Q) : ' ||
                                      'rowid_tabela_integracao ' || r1.rowid_tabela_integracao ||
                                      ' - ' || SQLERRM;
                       RAISE erro;

               END;

               ---> Atualiza a tabela do klassmatt para 3 - sucesso EBS

               IF vparametro = 'final' THEN

                     BEGIN

                             UPDATE klass_integracao_oi_item
                                   SET status    = 3    --        integração sucesso
                                  WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                                                 FROM klass_integracao_ebs
                                                                WHERE id_item_klassmatt = r1.id_item_klassmatt
                                                                  AND status            = 2 )
                                    AND status = 2;

								---> verifica se criou nas OIs
								SELECT COUNT(1)
								 INTO vcont
								 FROM mtl_system_items_b
								WHERE segment1      = r1.codigo_item;
				  
				  
								IF vcont <= 1 THEN
								
									UPDATE klass_integracao_ebs
									 SET status    = 4
										, desc_erro = 'FALHA NO PROCESSAMENTO DAS OIS - AGUARDE RETENTATIVA'
										,atualizadoKlassmatt = 0
									WHERE ROWID = r1.rowid_tabela_integracao;
								
								
								ELSE
								
								
								  UPDATE klass_integracao_ebs
									 SET status    = 3        --- integração sucesso
										,atualizadoKlassmatt = 0
									WHERE ROWID = r1.rowid_tabela_integracao;


								   ---> Antes de finalizar os que rodaram ok, verificar se não tem alteração de linguagem a ser feito

								   msg_retorno := verifica_alteracao_linguagem ( r1.id_item_klassmatt
																				,r1.codigo_item );

								   IF msg_retorno <> 'OK' THEN
									   RAISE erro;
								   END IF;
								   
								   
								   ---> Faz a integração dos anexos
								  msg_retorno := manutencao_item_anexos (p_id_item_klassmatt  => r1.id_item_klassmatt
																		  ,p_codigo_item        => r1.codigo_item
																			 ,p_tipo_chamada       => 'I' );
																
																 
								   IF msg_retorno <> 'OK' THEN
									   RAISE erro;
								   END IF;
								   
								   
									---> Faz a integração dos itens relacionados - 
								  msg_retorno := manutencao_item_related (p_id_item_klassmatt  => r1.id_item_klassmatt
																			,p_codigo_item        => r1.codigo_item
																			 ,p_tipo_chamada       => 'I' );
																							 
								   IF msg_retorno <> 'OK' THEN
									   RAISE erro;
								   END IF;
								   
								   ---> Faz a integração das referências do fornecedor se existir
								   msg_retorno := manutencao_item_fornecedor (p_id_item_klassmatt  => r1.id_item_klassmatt
																			 ,p_codigo_item        => r1.codigo_item
																			 ,p_tipo_chamada       => 'I' );
								   
								   
								   
								   
								   IF msg_retorno <> 'OK' THEN
									   RAISE erro;
								   END IF;
								   
								END IF; 

                               
                              EXCEPTION
                                WHEN OTHERS THEN
                                   msg_retorno := 'Erro ao alterar a tabela klass_integracao_ebs (item) : ' ||
                                                  'rowid_tabela_integracao ' || r1.rowid_tabela_integracao ||
                                                  ' - ' || SQLERRM;
                                   RAISE erro;

                      END;



               END IF;

         END IF;

     END LOOP;   -- tabela de controle

     RETURN('OK');

  --
     EXCEPTION

       WHEN erro THEN
          gera_log_tabela(v_sequencia_processamento
                      ,msg_retorno
                      ,SYSDATE
                      ,'P'
                      ,v_nome_concorrente
                      ,v_debug);

          RETURN(msg_retorno);

       WHEN OTHERS THEN
          gera_log_tabela(v_sequencia_processamento
                      ,'Erro oracla na verificacao dos STATUS das interfaces - ' || SQLERRM
                      ,SYSDATE
                      ,'P'
                      ,v_nome_concorrente
                      ,v_debug);

          RETURN('Erro oracla na verificacao dos STATUS das interfaces - ' || SQLERRM);



  END verifica_status_interfaces;

  ------------------------------------------------------------------------------------------------
  /**************************************************************************************
   Procedure que verifica se um item que vai ser processado é de alteração.
   Nesse caso, ele verifica se tem oi_item informada e se tem alguma que não existe no
   código. Se não existir inclui essa nova OI antes de começar o processamento
   propriamente dito.
  **************************************************************************************/

  PROCEDURE verifica_alteracao_oi_nova AS

    msg_retorno                       VARCHAR2(4000);
    r_mtl_system_items_interface      mtl_system_items_interface%ROWTYPE;
    vexiste_registro                  NUMBER := 0;
    wrequest_id_inc                   NUMBER;
    vinventory_item_id                NUMBER;

  BEGIN

     FOR r1 IN (
                 SELECT a.*,
                        ROWID
                   FROM klass_integracao_ebs a
                  WHERE status   = 2
                    AND EXISTS ( SELECT 1
                                   FROM mtl_system_items_b
                                  WHERE organization_id IN (SELECT to_number(attribute1)
                                                              FROM klass_configuracao
                                                             WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
                                    AND segment1        = codigo
                                )    --- existe na mestre, ou seja, está cadastrado
                    AND EXISTS ( SELECT 1
                                   FROM klass_integracao_oi_item
                                  WHERE status  = 2
                                    AND id_item_klassmatt = a.id_item_klassmatt
                                    AND NOT EXISTS ( SELECT 1
                                                       FROM mtl_system_items_b
                                                      WHERE organization_id = klass_integracao_oi_item.organization_id
                                                        AND segment1        = codigo
                                                    )
                                )  -- existe uma oi pelo menos
               )

     LOOP


       BEGIN

          ---> Acessa o inventory_item_id do item na mestre

          BEGIN

              SELECT inventory_item_id
                INTO vinventory_item_id
                FROM mtl_system_items_b
               WHERE organization_id IN (SELECT to_number(attribute1)
                                           FROM klass_configuracao
                                          WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
                 AND segment1        = r1.codigo;


              EXCEPTION
                    WHEN OTHERS THEN
                       msg_retorno := 'Erro ao acessar o id do item da mestre - '
                                      || 'item klassmat ' || r1.id_item_klassmatt ||
                                      ' - erro ' || SQLERRM;

                       RAISE erro;

          END;


          ---> Faz a leitura das OI que estão na tabela de configuração e não estão no item

          FOR r2 IN (
                      SELECT organization_id
                       FROM klass_integracao_oi_item
                      WHERE id_item_klassmatt = r1.id_item_klassmatt
                        AND status            = 2
                        AND organization_id IN (SELECT organization_id
                                                  FROM org_organization_definitions
                                                 WHERE organization_id = klass_integracao_oi_item.organization_id
                                                   AND disable_date   IS NULL )  -- seja válida
                        AND organization_id NOT IN (SELECT organization_id
                                                      FROM mtl_system_items_b
                                                     WHERE segment1 = r1.codigo ) -- não esteja no codigo
                     )
          LOOP

              gera_log_tabela(v_sequencia_processamento
                             ,'Lendo as OIs nova do item ' || r1.codigo || ' org ' || r2.organization_id
                             ,SYSDATE
                             ,'P'
                             ,v_nome_concorrente
                             ,v_debug);


              ------------------------------------------------------------------------

              r_mtl_system_items_interface.set_process_id           := 60;
              r_mtl_system_items_interface.process_flag             := 1;
              r_mtl_system_items_interface.transaction_type         := 'CREATE';
              r_mtl_system_items_interface.inventory_item_id        := vinventory_item_id;
              r_mtl_system_items_interface.organization_id          := r2.organization_id;
              r_mtl_system_items_interface.last_update_date         := SYSDATE;
              r_mtl_system_items_interface.last_updated_by          := fnd_profile.value('user_id');
              r_mtl_system_items_interface.creation_date            := SYSDATE;
              r_mtl_system_items_interface.created_by               := fnd_profile.value('user_id');
              r_mtl_system_items_interface.last_update_login        := fnd_profile.value('user_id');

              -------------------------------------------------------------------------

              vexiste_registro := vexiste_registro + 1;

              customiza_por_cliente( r_mtl_system_items_interface, r2.organization_id, r1.item_gabarito);
              
              BEGIN

                 insert into mtl_system_items_interface
                                     VALUES  r_mtl_system_items_interface ;

                IF  vgrava_log_open_interface = 'S'  THEN
            insert into  klassmatt.dbg_mtl_system_items_interface
              values r_mtl_system_items_interface ;
                 END IF;
                    
                 EXCEPTION
                    WHEN OTHERS THEN
                       msg_retorno := 'Erro ao incluir na tabela mtl_system_items_interface - '
                                      || 'item klassmat ' || r1.id_item_klassmatt ||
                                      ' - erro ' || SQLERRM;

                       RAISE erro;
              END;


             ---> As categorias serão copiadas todas da mestre e por isso não será necessário o processamento para popular
             ---  a interface de categorias

             ----------------------- grava a tabela de controle --------------------------

              gera_log_tabela(v_sequencia_processamento
                             ,'Gravando a tabela de controle do item ' || r1.codigo || ' org ' || r2.organization_id
                             ,SYSDATE
                             ,'P'
                             ,v_nome_concorrente
                             ,v_debug);


              ---> insere tabela de controle

              BEGIN

                     INSERT INTO klass_integracao_controle
                                         ( id_processamento
                                          ,request_id
                                          ,status_execucao
                                          ,id_item_klassmatt
                                          ,id_item_alterado
                                          ,codigo_item
                                          ,organization_id
                                          ,tipo_operacao
                                          ,rowid_tabela_integracao
                                          ,dt_criacao
                                          ,dt_atualizacao )
                                 VALUES
                                         ( v_sequencia_processamento
                                          ,NULL
                                          ,'S'      --- stand by esperando execução
                                          ,r1.id_item_klassmatt
                                          ,NULL
                                          ,r1.codigo
                                          ,r2.organization_id
                                          ,'CREATE'
                                          ,r1.rowid
                                          ,SYSDATE
                                          ,SYSDATE );

                         EXCEPTION

                             WHEN OTHERS THEN
                                 msg_retorno := 'Erro ao incluir a tabela klass_integracao_controle - '
                                                || SQLERRM || ' id_item_klassmatt ' ||
                                                r1.id_item_klassmatt;
                                 RAISE erro;

                  END;


          END LOOP; -- r2



         EXCEPTION

                WHEN erro THEN
                        gera_log_tabela(v_sequencia_processamento
                                       ,msg_retorno
                                       ,SYSDATE
                                       ,'P'
                                       ,v_nome_concorrente
                                       ,v_debug);

                        UPDATE klass_integracao_ebs
                                   SET status = 4
                                      ,desc_erro = msg_retorno
                                 WHERE id_item_klassmatt = r1.id_item_klassmatt
                                   AND status            = 2;


                WHEN OTHERS THEN

                    msg_retorno := 'Erro geral procedure verifica_alteracao_oi_nova - ' || SQLERRM;

                    gera_log_tabela(v_sequencia_processamento
                                       ,msg_retorno
                                       ,SYSDATE
                                       ,'P'
                                       ,v_nome_concorrente
                                       ,v_debug);

                    UPDATE klass_integracao_ebs
                                   SET status = 4
                                      ,desc_erro = msg_retorno
                                 WHERE id_item_klassmatt = r1.id_item_klassmatt
                                   AND status            = 2;


       END;

     END LOOP; -- r1


     ---> Se existirem registros chama o concorrente

     IF vexiste_registro > 0 THEN

            gera_log_tabela(v_sequencia_processamento
                      ,'Chamando concorrente OI nova'
                      ,SYSDATE
                      ,NULL
                      ,v_nome_concorrente
                      ,v_debug);



             msg_retorno := executa_concorrente( 'CREATE'
                                                ,wrequest_id_inc );


             gera_log_tabela(v_sequencia_processamento
                      ,'Concorrente OI nova na fila execucao'
                      ,SYSDATE
                      ,NULL
                      ,v_nome_concorrente
                      ,v_debug);


             IF msg_retorno <> 'OK' THEN
                 RAISE erro;
             END IF;


             ---> atualiza tabela de controle com o id do concorrente

             BEGIN

                   UPDATE klass_integracao_controle
                      SET request_id = wrequest_id_inc
                    WHERE id_processamento = v_sequencia_processamento
                      AND tipo_operacao    = 'CREATE'
                      AND request_id      IS NULL
                      AND status_execucao  = 'S';

                EXCEPTION
                     WHEN OTHERS THEN
                        msg_retorno := 'Erro ao alterar a tabela klass_integracao_controle - inclusao intem. Erro ' ||
                                        SQLERRM;
                        RAISE erro;
             END;


             COMMIT;


             ---> Verifica se o concorrente rodou

             gera_log_tabela(v_sequencia_processamento
                      ,'Espera rodar Concorrente OI nova'
                      ,SYSDATE
                      ,NULL
                      ,v_nome_concorrente
                      ,v_debug);

             msg_retorno := status_concorrente(wrequest_id_inc);


             gera_log_tabela(v_sequencia_processamento
                      ,'Termino execucao Concorrente OI nova'
                      ,SYSDATE
                      ,NULL
                      ,v_nome_concorrente
                      ,v_debug);


             IF msg_retorno <> 'OK' THEN
                RAISE erro;
             END IF;


             ---> Verifica se não teve erro de interface

             msg_retorno := verifica_status_interfaces('inicial');

             IF msg_retorno <> 'OK' THEN
                 RAISE erro;
             END IF;

     END IF;



  EXCEPTION

    WHEN erro THEN
             gera_log_tabela(v_sequencia_processamento
                             ,msg_retorno
                             ,SYSDATE
                             ,'P'
                             ,v_nome_concorrente
                             ,v_debug);


    WHEN OTHERS THEN
             gera_log_tabela(v_sequencia_processamento
                           ,'Erro geral procedure verifica_alteracao_oi_nova - ' || SQLERRM
                           ,SYSDATE
                           ,'P'
                           ,v_nome_concorrente
                           ,v_debug);


  END verifica_alteracao_oi_nova;

  ------------------------------------------------------------------------------------------------
  /*************************************************************
   Procedure de controle de execução dos concorrentes
  *************************************************************/

  FUNCTION controle_concurrent (p_debug       IN VARCHAR2
                               ,p_envia_email IN VARCHAR2)  --- 'S' ou 'N'
                 RETURN VARCHAR2 IS

    msg_retorno                 VARCHAR2(3000);
    msg_retorno_email           VARCHAR2(3000);


    BEGIN

      v_debug            := p_debug;
      venvia_email       := p_envia_email;

      v_nome_concorrente := 'Integração Klassmatt - EBS';

      msg_retorno := seta_responsabilidade;

      IF msg_retorno <> 'OK' THEN
          RAISE erro;
      END IF;


      ---> Verifica empresa integracao
      BEGIN

          SELECT attribute1
            INTO vid_organizacao_mestre   --- variavel global
            FROM klass_configuracao
           WHERE tipo = 'ID_ORGANIZACAO_MESTRE';

          EXCEPTION
             WHEN OTHERS THEN
                msg_retorno := 'Erro - parametro ID_ORGANIZACAO_MESTRE não cadastrado. - ' || SQLERRM;
                RAISE erro;
      END;
      
      ---> Verifica empresa integracao

      BEGIN

          SELECT attribute1
            INTO vempresa_integracao   --- variavel global
            FROM klass_configuracao
           WHERE tipo = 'SETA_EMPRESA_INTEGRACAO';

          EXCEPTION
             WHEN OTHERS THEN
                msg_retorno := 'Erro - parametro empresa integracao não cadastrado. - ' || SQLERRM;
                RAISE erro;
      END;


      ---> Verifica se vai incluir para todas as organizações do gabarito

      BEGIN

          SELECT attribute1
            INTO vcreate_organizations   --- variavel global
            FROM klass_configuracao
           WHERE tipo = 'CREATE_ORGANIZATIONS';

          EXCEPTION
             WHEN no_data_found THEN
                 vcreate_organizations := 'N';

             WHEN OTHERS THEN
                msg_retorno := 'Erro ao acessar parâmetro CREATE_ORGANIZATIONS. - ' || SQLERRM;
                RAISE erro;
      END;

    ---> Verifica se vai gravar log de debug (LOG_OPEN_INTERFACE)

      BEGIN

          SELECT attribute1
            INTO vgrava_log_open_interface   --- variavel global
            FROM klass_configuracao
           WHERE tipo = 'LOG_OPEN_INTERFACE';

          EXCEPTION
             WHEN no_data_found THEN
                 vgrava_log_open_interface := 'N';

             WHEN OTHERS THEN
                msg_retorno := 'Erro ao acessar parâmetro LOG_OPEN_INTERFACE. - ' || SQLERRM;
                RAISE erro;
      END;
    
      ---> VERIFICA A SEQUENCIA DO PROCESSAMENTO

      SELECT klass_integracao_seq.NEXTVAL
        INTO v_sequencia_processamento
        FROM dual;
             --
      gera_log_tabela(v_sequencia_processamento
                      ,'Inicio da Integracao Klassmatt - EBS : ' ||
                                     to_char(SYSDATE,'dd/mm/yyyy hh24:mi:ss') || ' . Verificando integração pendente'
                      ,SYSDATE
                      ,NULL
                      ,v_nome_concorrente
                      ,v_debug);


      ---> Antes de rodar a integração, o concorrente deverá verificar se existe algum concorrente
      ---  de integração rodando, ou seja, em status pendente. Se estiver algum, esse concorrente aqui
      ---  deverá ser abortado

      msg_retorno := verifica_integracao_pendente;

      IF msg_retorno = 'OK' THEN

          gera_log_tabela(v_sequencia_processamento
                      ,'Integração pendente inexistente - início do processamento CONCORRENTE_INTEGRACAO'
                      ,SYSDATE
                      ,'P'
                      ,v_nome_concorrente
                      ,v_debug);

          concorrente_integracao( msg_retorno );

     END IF;


      IF msg_retorno <> 'OK' THEN
          RAISE erro;
      ELSE
          gera_log_tabela(v_sequencia_processamento
                      ,'Processamento de integracao terminado com SUCESSO !'
                      ,SYSDATE
                      ,NULL
                      ,v_nome_concorrente
                      ,v_debug);

           RETURN(msg_retorno);
      END IF;

      ---> exception da procedure  ---> todos os erros tratados convergem para essa
      ---  procedure. No exception será startado o email para a profile definida.

      EXCEPTION
          WHEN erro THEN
            gera_log_tabela(v_sequencia_processamento
                      ,'Processamento terminou com ERRO ' || msg_retorno
                      ,SYSDATE
                      ,'P'
                      ,v_nome_concorrente
                      ,v_debug);

            msg_retorno_email := envia_email(msg_retorno,NULL);

            ---> exclui tudo que está em "S" na tabela de controle

            altera_tabela_controle(msg_retorno);

            raise_application_error(-20001,msg_retorno);

            RETURN(msg_retorno);

          WHEN OTHERS THEN
            gera_log_tabela(v_sequencia_processamento
                      ,'Processamento terminou com ERRO Oracle: '||SQLERRM
                      ,SYSDATE
                      ,'P'
                      ,v_nome_concorrente
                      ,v_debug);

            msg_retorno_email := envia_email('-20002, Erro Oracle: '||sqlerrm,NULL);


            ---> exclui tudo que está em "S" na tabela de controle

            altera_tabela_controle(msg_retorno);

            raise_application_error(-20002,'Erro Oracle: '||sqlerrm);

            RETURN('Erro Oracle: '||sqlerrm);

    END  controle_concurrent;
  --

  /*******************************************************************************************
   Procedure que faz a inclusão do item da tabela de integração na interface de itens
   e categorias de itens, indicando o tipo de operação a ser realizada : incluão ou alteração
  ********************************************************************************************/

  PROCEDURE concorrente_integracao ( msg_retorno OUT VARCHAR2 ) IS

      contador                  NUMBER;
      wrequest_id_inc           NUMBER;
      wrequest_id_alt           NUMBER;
      wrequest_id_inc_mestre    NUMBER;
      wrequest_id_alt_mestre    NUMBER;
      ind_mestre                NUMBER;
      v_mestre                  VARCHAR2(10);
      v_codigo_item             VARCHAR2(100);

  BEGIN

          ---> verifica se o parâmetro da mestre está cadastrado

          SELECT COUNT(*)
            INTO contador
            FROM klass_configuracao
           WHERE tipo = 'ID_ORGANIZACAO_MESTRE' ;

          IF contador = 0 THEN
               msg_retorno := 'Tabela de configuraçao não contém informações da mestre.';
               RAISE erro;
           END IF;

           ---> Limpa a tabela de controle dos itens a serem lidos

           DELETE FROM klass_integracao_controle
            WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                           FROM klass_integracao_ebs
                                          WHERE status = 1 );


            ---> Antes de fazer o processamento dos itens excluir da interface todos os registros com erro          
            msg_retorno := exclui_erros_interf;
            
            IF msg_retorno <> 'OK' THEN
                 RAISE erro;
            END IF;
                                          
                                          
           ---> marca o lote a ser lido internamente - status interno 2

            BEGIN

              UPDATE klass_integracao_ebs
                 SET status    = 2, desc_erro = NULL
                WHERE status   = 1;

              UPDATE klass_integracao_oi_item
                 SET status    = 2
               WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                              FROM klass_integracao_ebs
                                             WHERE status = 2)
                 AND status = 1;
                 

              UPDATE klass_integracao_linguagem
                 SET status    = 2
               WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                              FROM klass_integracao_ebs
                                             WHERE status = 2)
                 AND status = 1;

              
              ---> Somente processa as integrações que estão relacionadas com os itens na interface klassmatt
              
              UPDATE klass_integracao_ebs_ref
                 SET status    = 2
               WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                              FROM klass_integracao_ebs
                                             WHERE status = 2)
                 AND status = 1;   
                 
                 
              UPDATE klass_integracao_anexo
                 SET status    = 2
               WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                              FROM klass_integracao_ebs
                                             WHERE status = 2)
                 AND status = 1;   
                 
              UPDATE klass_integracao_relaciona
                 SET status    = 2
               WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                              FROM klass_integracao_ebs
                                             WHERE status = 2)
                 AND status = 1;   
                 
                 
              EXCEPTION
                WHEN OTHERS THEN
                   msg_retorno := 'Erro ao alterar a tabela klass_integracao_ebs (status - 2)' ||
                                  ' - ' || SQLERRM;
                   RAISE erro;
            END;


            gera_log_tabela(v_sequencia_processamento
                      ,'Verifica se tem OI para incluir em alteracao'
                      ,SYSDATE
                      ,'P'
                      ,v_nome_concorrente
                      ,v_debug);


            -------------------------------------------
            verifica_alteracao_oi_nova;
            -------------------------------------------

            ---> Se não teve problemas então zera a tabela de controle no status = 2 para continuar o processamento

            DELETE FROM klass_integracao_controle
            WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                           FROM klass_integracao_ebs
                                          WHERE status = 2 );


           gera_log_tabela(v_sequencia_processamento
                      ,'Dados integracao ok'
                      ,SYSDATE
                      ,'P'
                      ,v_nome_concorrente
                      ,v_debug);


          ---> Faz a leitura por mestre e depois seus filhos - inclusão e alteração
          ---  do mestre e depois inclusão e alteração dos filhos

          ---> Faz a leitura do mestre e depois de seus filhos

          FOR ind_mestre IN 1..2      ---> faria a inclusão/alteração dos filhos
          LOOP

              wrequest_id_alt := NULL;
              wrequest_id_inc := NULL;

              SELECT decode(ind_mestre,1,'Y','N')  -- Y - mestre     N - filhos
                INTO v_mestre
                FROM dual;

               ---> se for o processamento dos filhos, tem que se certificar que o
                ---  concorrente da mestre já rodou e foi OK.
                --- wrequest_id gerado antes

                msg_retorno := 'OK';

                ---> verifica status do concorrente inclusão da mestre

                IF v_mestre        = 'N' AND
                   wrequest_id_inc_mestre IS not NULL THEN

                    gera_log_tabela(v_sequencia_processamento
                      ,'Espera rodar Concorrente inclusao mestre'
                      ,SYSDATE
                      ,NULL
                      ,v_nome_concorrente
                      ,v_debug);

                    msg_retorno := status_concorrente(wrequest_id_inc_mestre);

                    gera_log_tabela(v_sequencia_processamento
                      ,'Termino execucao Concorrente inclusao mestre'
                      ,SYSDATE
                      ,NULL
                      ,v_nome_concorrente
                      ,v_debug);

                END IF;

                IF msg_retorno <> 'OK' THEN
                   RAISE erro;
                END IF;

                ---> verifica status do concorrente alteração da mestre

                IF v_mestre        = 'N' AND
                   wrequest_id_alt_mestre IS NOT NULL THEN

                    gera_log_tabela(v_sequencia_processamento
                      ,'Espera rodar Concorrente alteracao mestre'
                      ,SYSDATE
                      ,NULL
                      ,v_nome_concorrente
                      ,v_debug);

                    msg_retorno := status_concorrente(wrequest_id_alt_mestre);

                    gera_log_tabela(v_sequencia_processamento
                      ,'Termino execucao Concorrente alteracao mestre'
                      ,SYSDATE
                      ,NULL
                      ,v_nome_concorrente
                      ,v_debug);

                END IF;

                IF msg_retorno <> 'OK' THEN
                   RAISE erro;
                END IF;

                ---> Verifica a interface gerada da mestre e depois, se ok,
                ---- insere os subinventários da mestre

                IF v_mestre        = 'N' AND
                   ( wrequest_id_alt_mestre IS NOT NULL OR
                     wrequest_id_inc_mestre IS not NULL ) THEN

                        /*
                            Agora verifica todos os registros da tabela de controle que estão com
                            status_execucao = 'S' para acessar a interface e verificar se rodou ok.
                         */

                         msg_retorno := verifica_status_interfaces('inicial');

                         IF msg_retorno <> 'OK' THEN
                             RAISE erro;
                         END IF;


                         gera_log_tabela(v_sequencia_processamento
                                        ,'Status mestre verificado ok'
                                        ,SYSDATE
                                        ,'P'
                                        ,v_nome_concorrente
                                        ,v_debug);

                         COMMIT;

                end IF;

                ----------------------------------------------------------
                ---> Faz a nova leitura

                gera_log_tabela(v_sequencia_processamento
                      ,'Fazendo leitura mestre = ' || v_mestre
                      ,SYSDATE
                      ,'P'
                      ,v_nome_concorrente
                      ,v_debug);


                ---------------------------------------------------
                ---> Faz a leitura dos registros a serem incluídos - somente quando for mestre
                ---------------------------------------------------

                FOR r1 IN (
                           SELECT id_item_klassmatt
                                 ,codigo
                                 ,origem
                                 ,item_gabarito
                                 ,unidade_medida
                                 ,ncm_classificacao_fiscal
                                 ,ipi
                                 ,codbarras
                                 ,categ_segment1
                                 ,categ_segment2
                                 ,categ_segment3
                                 ,categ_segment4
                                 ,descricao_resumida
                                 ,descricao_media
                                 ,descricao_completa
                                 ,item_origem
                                 ,empresa
                                 ,email
                                 ,status
                                 ,desc_erro
                                 ,ROWID
                             FROM klass_integracao_ebs
                            WHERE status   = 2
                              AND ( item_origem IS NOT NULL OR
                                    item_gabarito IS NOT NULL )
                              AND ( ( v_mestre = 'Y' AND
                                      NOT EXISTS ( SELECT 1
                                                     FROM mtl_system_items_b
                                                    WHERE organization_id IN (SELECT to_number(attribute1)
                                                                                FROM klass_configuracao
                                                                               WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
                                                      AND segment1        = codigo )  ) ---> inclusão não existe na mestre
                                    OR
                                    (  v_mestre = 'N' AND vcreate_organizations = 'S' AND
                                          ( NOT EXISTS  ( SELECT 1
                                                           FROM mtl_system_items_b
                                                          WHERE organization_id NOT IN (SELECT to_number(attribute1)
                                                                                          FROM klass_configuracao
                                                                                         WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
                                                            AND segment1        = codigo ) ---> inclusão filhos não pode estar em nenhuma OI sem ser a mestre
                                         )
                                    )
                                  )
                         )
               LOOP

               --
                  gera_log_tabela(v_sequencia_processamento
                              ,'Linha : '                   || '-' ||
                                r1.id_item_klassmatt        || '-' ||
                                r1.codigo                   || '-' ||
                                r1.origem                   || '-' ||
                                r1.unidade_medida           || '-' ||
                                r1.ncm_classificacao_fiscal || '-' ||
                                r1.ipi                      || '-' ||
                                r1.codbarras                || '-' ||
                                r1.categ_segment1           || '-' ||
                                r1.categ_segment2           || '-' ||
                                r1.categ_segment3           || '-' ||
                                r1.categ_segment4           || '-' ||
                                r1.descricao_resumida       || '-' ||
                                r1.descricao_media          || '-' ||
                                r1.descricao_completa       || '-' ||
                                r1.item_origem              || '-' ||
                                r1.empresa                  || '-' ||
                                r1.email                    || '-' ||
                                r1.status                   || '-' ||
                                r1.desc_erro
                              ,SYSDATE
                              ,'P'
                              ,v_nome_concorrente
                              ,v_debug );


                     ---> Para cada inclusão acessa o novo código do item
                     ---  Se item já foi processado ou é a inclusão dos filhos da mestre
                     ---  ou ainda, estava com problemas na interface anteriormente
                     ---  a função irá retornar o código do item que está na tabela de controle

                     v_codigo_item := r1.codigo;


                     ---> Somente inclui os filhos dos mestres que não tiveram problemas
                     ---  na interface

                     IF v_mestre = 'N' THEN

                         SELECT COUNT(*)
                           INTO contador
                           FROM dual
                          WHERE EXISTS ( SELECT 1
                                           FROM mtl_system_items_interface
                                          WHERE request_id      = wrequest_id_inc_mestre
                                            AND segment1        = r1.codigo
                                            AND organization_id IN (SELECT to_number(attribute1)
                                                                      FROM klass_configuracao
                                                                     WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
                                            AND process_flag    <> 7 )
                             OR EXISTS ( SELECT 1
                                           FROM mtl_item_categories_interface
                                          WHERE request_id      = wrequest_id_inc_mestre
                                            AND item_number     = r1.codigo
                                            AND organization_id IN (SELECT to_number(attribute1)
                                                                      FROM klass_configuracao
                                                                     WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
                                            AND process_flag    <> 7 );

                     ELSE

                        contador := 0;

                     END IF;


                     IF contador = 0 THEN

                           gera_log_tabela(v_sequencia_processamento
                                          ,'Codigo item ' || v_codigo_item
                                          ,SYSDATE
                                          ,'P'
                                          ,v_nome_concorrente
                                          ,v_debug);


                           ---> chama a inclusão do item

                           IF r1.item_origem IS NOT NULL THEN

                                 msg_retorno := inclusao_item_interface ( r1.ROWID
                                                                         ,v_mestre
                                                                         ,v_codigo_item);
                           ELSE
                               IF r1.item_gabarito IS NOT NULL THEN

                                  msg_retorno := inclusao_item_gabarito ( r1.ROWID
                                                                         ,v_mestre
                                                                         ,v_codigo_item);

                               END IF;

                           END IF;

                           ---

                           IF msg_retorno <> 'OK' THEN

                                 BEGIN

                                    UPDATE klass_integracao_controle
                                       SET status_execucao = 'E'
                                      WHERE id_item_klassmatt       = r1.id_item_klassmatt
                                        AND codigo_item             = v_codigo_item
                                        AND rowid_tabela_integracao = r1.ROWID;

                                    EXCEPTION
                                       WHEN OTHERS THEN
                                         msg_retorno := 'Erro ao alterar a tabela klass_integracao_controle (retorno inclusao) : ' ||
                                                        'rowid_tabela_integracao ' || r1.ROWID ||
                                                        ' - ' || SQLERRM;
                                         RAISE erro;

                                 END;

                                 ---> altera a tabela de integração do klassmatt


                                 BEGIN
                                    UPDATE klass_integracao_oi_item
                                       SET status    = 4        --- integração erro
                                      WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                                                     FROM klass_integracao_ebs
                                                                    WHERE id_item_klassmatt = r1.id_item_klassmatt
                                                                      AND status            = 2 )
                                        AND status = 2;

                                     UPDATE klass_integracao_linguagem
                                       SET status    = 4        --- integração erro
                                      WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                                                     FROM klass_integracao_ebs
                                                                    WHERE id_item_klassmatt = r1.id_item_klassmatt
                                                                      AND status            = 2 )
                                        AND status = 2;

                                    
                                    UPDATE klass_integracao_ebs_ref
                                       SET status    = 4        --- integração erro
                                          ,desc_erro = msg_retorno
                                      WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                                                     FROM klass_integracao_ebs
                                                                    WHERE id_item_klassmatt = r1.id_item_klassmatt
                                                                      AND status            = 2 )
                                        AND status = 2;
                                        
                                        
                                    UPDATE klass_integracao_ebs
                                       SET status    = 4
                                          ,desc_erro = msg_retorno
                                          , atualizadoKlassmatt = 0
                                      WHERE ROWID = r1.ROWID;


                                    EXCEPTION
                                      WHEN OTHERS THEN
                                         msg_retorno := 'Erro ao alterar a tabela klass_integracao_ebs (retorno inclusao) : ' ||
                                                        'rowid_tabela_integracao ' || r1.ROWID ||
                                                        ' - ' || SQLERRM;
                                         RAISE erro;
                                 END;

                           END IF;


                           gera_log_tabela(v_sequencia_processamento
                                          ,'Inclusao ' || v_codigo_item || ' ok'
                                          ,SYSDATE
                                          ,'P'
                                          ,v_nome_concorrente
                                          ,v_debug);


                        END IF;

               END LOOP;  --- leitura tabela integração inclusão


               ---------------------------------------------------
                ---> Faz a leitura dos registros a serem alterados
               ---------------------------------------------------

                gera_log_tabela(v_sequencia_processamento
                                    ,'Leitura dos itens a alterar ...'
                                    ,SYSDATE
                                    ,'P'
                                    ,v_nome_concorrente
                                    ,v_debug);


                FOR r1 IN (
                           SELECT id_item_klassmatt
                                 ,codigo
                                 ,origem
                                 ,unidade_medida
                                 ,ncm_classificacao_fiscal
                                 ,ipi
                                 ,codbarras
                                 ,categ_segment1
                                 ,categ_segment2
                                 ,categ_segment3
                                 ,categ_segment4
                                 ,descricao_resumida
                                 ,descricao_media
                                 ,descricao_completa
                                 ,item_origem
                                 ,empresa
                                 ,email
                                 ,status
                                 ,desc_erro
                                 ,ROWID
                             FROM klass_integracao_ebs
                            WHERE status   = 2
                              AND EXISTS ( SELECT 1
                                             FROM mtl_system_items_b
                                            WHERE organization_id IN (SELECT to_number(attribute1)
                                                                        FROM klass_configuracao
                                                                       WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
                                              AND segment1        = codigo )  ---> alteração
                              AND NOT EXISTS ( SELECT 1
                                                FROM klass_integracao_controle
                                               WHERE id_item_klassmatt = klass_integracao_ebs.id_item_klassmatt
                                                 AND tipo_operacao     = 'CREATE' )

                         )
               LOOP

               --
                  gera_log_tabela(v_sequencia_processamento
                              ,'Linha : '                   || '-' ||
                                r1.id_item_klassmatt        || '-' ||
                                r1.codigo                   || '-' ||
                                r1.origem                   || '-' ||
                                r1.unidade_medida           || '-' ||
                                r1.ncm_classificacao_fiscal || '-' ||
                                r1.ipi                      || '-' ||
                                r1.codbarras                || '-' ||
                                r1.categ_segment1                  || '-' ||
                                r1.categ_segment2                    || '-' ||
                                r1.categ_segment3                 || '-' ||
                                r1.categ_segment4          || '-' ||
                                r1.descricao_resumida       || '-' ||
                                r1.descricao_media          || '-' ||
                                r1.descricao_completa       || '-' ||
                                r1.item_origem              || '-' ||
                                r1.empresa                  || '-' ||
                                r1.email                    || '-' ||
                                r1.status                   || '-' ||
                                r1.desc_erro
                              ,SYSDATE
                              ,'P'
                              ,v_nome_concorrente
                              ,v_debug );


                 ---> Somente inclui os filhos dos mestres que não tiveram problemas
                 ---  na interface

                     IF v_mestre = 'N' THEN

                         SELECT COUNT(*)
                           INTO contador
                           FROM dual
                          WHERE EXISTS ( SELECT 1
                                           FROM mtl_system_items_interface
                                          WHERE request_id      = wrequest_id_alt_mestre
                                            AND segment1        = r1.codigo
                                            AND organization_id IN (SELECT to_number(attribute1)
                                                                      FROM klass_configuracao
                                                                     WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
                                            AND process_flag    <> 7 )
                             OR EXISTS ( SELECT 1
                                           FROM mtl_item_categories_interface
                                          WHERE request_id      = wrequest_id_alt_mestre
                                            AND item_number     = r1.codigo
                                            AND organization_id IN (SELECT to_number(attribute1)
                                                                      FROM klass_configuracao
                                                                     WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
                                            AND process_flag    <> 7 );

                     ELSE

                         contador := 0;

                     END IF;

                     IF contador = 0 THEN

                       ---> chama o concorrente para alteração

                       msg_retorno := alteracao_item_interface ( r1.ROWID
                                                                ,v_mestre );

                       IF msg_retorno <> 'OK' THEN

                           BEGIN

                              UPDATE klass_integracao_controle
                                 SET status_execucao = 'E'
                                WHERE id_item_klassmatt       = r1.id_item_klassmatt
                                  AND codigo_item             = r1.codigo
                                  AND rowid_tabela_integracao = r1.ROWID;

                              EXCEPTION
                                 WHEN OTHERS THEN
                                   msg_retorno := 'Erro ao alterar a tabela klass_integracao_controle (retorno alteracao) : ' ||
                                                  'rowid_tabela_integracao ' || r1.ROWID ||
                                                  ' - ' || SQLERRM;
                                   RAISE erro;

                           END;

                           ---> altera a tabela de integração do klassmatt


                           BEGIN

                              UPDATE klass_integracao_oi_item
                                 SET status    = 4        --- integração erro
                                WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                                               FROM klass_integracao_ebs
                                                              WHERE id_item_klassmatt = r1.id_item_klassmatt
                                                                AND status            = 2 )
                                  AND status = 2;

                               UPDATE klass_integracao_linguagem
                                 SET status    = 4        --- integração erro
                                WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                                               FROM klass_integracao_ebs
                                                              WHERE id_item_klassmatt = r1.id_item_klassmatt
                                                                AND status            = 2 )
                                  AND status = 2;

                              
                              UPDATE klass_integracao_ebs_ref
                                 SET status    = 4        --- integração erro
                                    ,desc_erro = msg_retorno
                                WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                                                FROM klass_integracao_ebs
                                                              WHERE id_item_klassmatt = r1.id_item_klassmatt
                                                                AND status            = 2 )
                                 AND status = 2;
                              
                              
                              UPDATE klass_integracao_ebs
                                 SET status    = 4
                                    ,desc_erro = msg_retorno
                                    , atualizadoKlassmatt = 0
                                WHERE ROWID = r1.ROWID;


                              EXCEPTION
                                WHEN OTHERS THEN
                                   msg_retorno := 'Erro ao alterar a tabela klass_integracao_ebs (retorno alteracao) : ' ||
                                                  'rowid_tabela_integracao ' || r1.ROWID ||
                                                  ' - ' || SQLERRM;
                                   RAISE erro;
                           END;

                       END IF;


                       gera_log_tabela(v_sequencia_processamento
                                          ,'Item alterado - ' || r1.codigo || ' ok'
                                          ,SYSDATE
                                          ,'P'
                                          ,v_nome_concorrente
                                          ,v_debug);

                  END IF;

              END LOOP;  --- leitura da integração para alteração


              ---------------------------------------------------
              -- Chama os concorrentes para inclusão e alteração
              -- somente se existirem elementos para gerar
              ---------------------------------------------------

              ---> chama o concorrente para gerar o item

              gera_log_tabela(v_sequencia_processamento
                    ,'Preparando para gerar os concorrentes do processamento ' || v_sequencia_processamento
                    ,SYSDATE
                    ,'P'
                    ,v_nome_concorrente
                    ,v_debug);

              msg_retorno := NULL;

              ---> verifica se tem item para inclusão

             SELECT COUNT(*)
               INTO contador
               FROM klass_integracao_controle
              WHERE id_processamento = v_sequencia_processamento
                AND tipo_operacao    = 'CREATE'
                AND request_id      IS NULL
                AND status_execucao  = 'S';

             IF contador <> 0 THEN


                 gera_log_tabela(v_sequencia_processamento
                    ,'Chama Concorrente inclusão de item - mestre = ' || v_mestre
                    ,SYSDATE
                    ,NULL
                    ,v_nome_concorrente
                    ,v_debug);


                 msg_retorno := executa_concorrente( 'CREATE'
                                                    ,wrequest_id_inc );


                 gera_log_tabela(v_sequencia_processamento
                    ,'Concorrente inclusão de item  na fila de execucao - mestre = ' || v_mestre
                    ,SYSDATE
                    ,NULL
                    ,v_nome_concorrente
                    ,v_debug);


                 IF msg_retorno <> 'OK' THEN
                     RAISE erro;
                 END IF;


                 ---> atualiza tabela de controle com o id do concorrente

                 BEGIN

                       UPDATE klass_integracao_controle
                          SET request_id = wrequest_id_inc
                        WHERE id_processamento = v_sequencia_processamento
                          AND tipo_operacao    = 'CREATE'
                          AND request_id      IS NULL
                          AND status_execucao  = 'S';

                    EXCEPTION
                         WHEN OTHERS THEN
                            msg_retorno := 'Erro ao alterar a tabela klass_integracao_controle - inclusao intem. Erro ' ||
                                            SQLERRM;
                            RAISE erro;
                 END;

                 IF v_mestre = 'Y' THEN
                     wrequest_id_inc_mestre := wrequest_id_inc;
                 END IF;

                 gera_log_tabela(v_sequencia_processamento
                                ,'Concorrente de inclusao ' || wrequest_id_inc || ' do processamento ' || v_sequencia_processamento
                                ,SYSDATE
                                ,'P'
                                ,v_nome_concorrente
                                ,v_debug);

                 COMMIT;

             END IF;    -- contador CREATE


             ---> chama o concorrente para alterar o item

             ---> verifica se tem item para alteração

             SELECT COUNT(*)
               INTO contador
               FROM klass_integracao_controle
              WHERE id_processamento = v_sequencia_processamento
                AND tipo_operacao    = 'UPDATE'
                AND request_id       IS NULL
                AND status_execucao  = 'S';

             IF contador <> 0 THEN


                 gera_log_tabela(v_sequencia_processamento
                    ,'Chama Concorrente alteracao de item - mestre = ' || v_mestre
                    ,SYSDATE
                    ,NULL
                    ,v_nome_concorrente
                    ,v_debug);


                 msg_retorno := executa_concorrente( 'UPDATE'
                                                    ,wrequest_id_alt );


                 gera_log_tabela(v_sequencia_processamento
                    ,'Concorrente alteracao de item na fila de execucao - mestre = ' || v_mestre
                    ,SYSDATE
                    ,NULL
                    ,v_nome_concorrente
                    ,v_debug);


                 IF msg_retorno <> 'OK' THEN
                     RAISE erro;
                 END IF;

                 ---> atualiza tabela de controle com o id do concorrente

                 BEGIN

                     UPDATE klass_integracao_controle
                        SET request_id = wrequest_id_alt
                      WHERE id_processamento = v_sequencia_processamento
                        AND tipo_operacao    = 'UPDATE'
                        AND request_id       IS NULL
                        AND status_execucao  = 'S';

                    EXCEPTION
                       WHEN OTHERS THEN
                          msg_retorno := 'Erro ao alterar a tabela klass_integracao_controle - alteracao intem. Erro ' ||
                                          SQLERRM;
                          RAISE erro;

                 END;

                  IF v_mestre = 'Y' THEN
                      wrequest_id_alt_mestre := wrequest_id_alt;
                  END IF;

                 gera_log_tabela(v_sequencia_processamento
                                ,'Concorrente de alteracao ' || wrequest_id_alt || ' do processamento ' || v_sequencia_processamento
                                ,SYSDATE
                                ,'P'
                                ,v_nome_concorrente
                                ,v_debug);

                 COMMIT;

             END IF;



          END LOOP; -- for do mestre ou filhos


     ---> Espera rodar os concorrentes dos filhos
     ---  Se tiver concorrente para os filhos o wrequest_id inc e/ou alt devem estar
     ---  preenchidos.


     gera_log_tabela(v_sequencia_processamento
                    ,'Verificando o status das execucoes dos concorrentes dos filhos'
                    ,SYSDATE
                    ,'P'
                    ,v_nome_concorrente
                    ,v_debug);

     msg_retorno := 'OK';

     IF wrequest_id_inc IS NOT NULL THEN

        gera_log_tabela(v_sequencia_processamento
                      ,'Espera rodar Concorrente inclusao filhos'
                      ,SYSDATE
                      ,NULL
                      ,v_nome_concorrente
                      ,v_debug);

        msg_retorno := status_concorrente(wrequest_id_inc);


        gera_log_tabela(v_sequencia_processamento
                      ,'Termino execucao Concorrente inclusao filhos'
                      ,SYSDATE
                      ,NULL
                      ,v_nome_concorrente
                      ,v_debug);

     END IF;

     IF msg_retorno <> 'OK' THEN
       RAISE erro;
     END IF;

     ------------

     IF wrequest_id_alt IS NOT NULL THEN

        gera_log_tabela(v_sequencia_processamento
                      ,'Espera rodar Concorrente alteracao filhos'
                      ,SYSDATE
                      ,NULL
                      ,v_nome_concorrente
                      ,v_debug);

        msg_retorno := status_concorrente(wrequest_id_alt);


        gera_log_tabela(v_sequencia_processamento
                      ,'Termino execucao Concorrente alteracao filhos'
                      ,SYSDATE
                      ,NULL
                      ,v_nome_concorrente
                      ,v_debug);

     END IF;

     IF msg_retorno <> 'OK' THEN
       RAISE erro;
     END IF;

     /*
        Agora verifica todos os registros da tabela de controle que estão com
        status_execucao = 'S' para acessar a interface e verificar se rodou ok.
     */

     msg_retorno := verifica_status_interfaces('final');

     IF msg_retorno <> 'OK' THEN
         RAISE erro;
     END IF;
     

     gera_log_tabela(v_sequencia_processamento
                    ,'Status verificado ok'
                    ,SYSDATE
                    ,'P'
                    ,v_nome_concorrente
                    ,v_debug);


     ---> Rodou o processo e finalizou OK

     IF msg_retorno = 'OK' THEN

           ---> Chama a function que vai inserir todos os subinventários e endereços dos itens
           ---  que estão na tabela de controle com status = Q e operacao CREATE. Os registros com status = 'S'
           ---  será enviado um e-mail ao responsável, pois esse registro está com problemas e
           ---  está trancado na tabela.

           gera_log_tabela(v_sequencia_processamento
                    ,'Verificando insercao de subinventarios e enderecos filhos ...'
                    ,SYSDATE
                    ,'P'
                    ,v_nome_concorrente
                    ,v_debug);


           ---> Finaliza o status de execução da tabela de controle para 'C'

           BEGIN

                   UPDATE klass_integracao_controle
                       SET status_execucao = 'C'
                      WHERE status_execucao = 'Q';

                   EXCEPTION
                     WHEN OTHERS THEN
                         msg_retorno := 'Erro ao alterar a tabela de controle para status ''C'' ' ||
                                            ' - ' || SQLERRM;
                         RAISE erro;
          END;

          ---> acerta os que não entraram e não processaram na query mas entraram no processamento

            UPDATE klass_integracao_oi_item
               SET status = 4
               WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                              FROM klass_integracao_ebs
                                             WHERE status = 2 )
                 AND status = 2;

            UPDATE klass_integracao_linguagem
               SET status = 4
               WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                              FROM klass_integracao_ebs
                                             WHERE status = 2 )
                 AND status = 2;

             
            UPDATE klass_integracao_ebs_ref
               SET status = 4
                  ,desc_erro = 'Não entrou na selecao principal. Verifique os dados antes de reenviar.'
               WHERE id_item_klassmatt IN ( SELECT id_item_klassmatt
                                              FROM klass_integracao_ebs
                                             WHERE status = 2 )
                 AND status = 2;    
                 
                 
            UPDATE klass_integracao_ebs
               SET status    = 4
                  ,desc_erro = 'Não entrou na selecao principal. Verifique os dados antes de reenviar.'
                  , atualizadoKlassmatt = 0
              WHERE status = 2;


           ---> Altera as tabelas filho klass_integracao_linguagem e klass_integracao_oi_item para os mesmos status das processadas

            COMMIT;


           ---> finaliza o log com sucesso

           gera_log_tabela(v_sequencia_processamento
                             ,'Processamento ' || v_sequencia_processamento || ' finalizado com SUCESSO !' ||
                             ' Total de itens Processados = ' || v_linha
                             ,SYSDATE
                             ,'F'
                             ,v_nome_concorrente
                             ,v_debug);


     END IF;


     ---> Não tem item para processar na tabela de interface

     IF msg_retorno IS NULL THEN

            gera_log_tabela(v_sequencia_processamento
                           ,'Processamento ' || v_sequencia_processamento || ' finalizado com SUCESSO - '
                            || ' nao existem dados para processar.'
                           ,SYSDATE
                           ,'F'
                           ,v_nome_concorrente
                           ,v_debug);

            msg_retorno := 'OK';

     END IF;

     /**********************************************************/

     EXCEPTION
          WHEN erro THEN

            gera_log_tabela(v_sequencia_processamento
                           ,msg_retorno
                           ,SYSDATE
                           ,'P'
                           ,v_nome_concorrente
                           ,v_debug);
            ROLLBACK;

          WHEN OTHERS THEN

            gera_log_tabela(v_sequencia_processamento
                           ,'Erro Oracle: '||sqlerrm
                           ,SYSDATE
                           ,'P'
                           ,v_nome_concorrente
                           ,v_debug);
            dbms_output.put_line('Processamento terminou com ERRO. Verifique LOG !');
            raise_application_error(-20010,'Erro Oracle: '||sqlerrm);
            ROLLBACK;

  END concorrente_integracao;
  
  PROCEDURE customiza_por_cliente(r_mtl_system_items_interface   IN OUT mtl_system_items_interface%rowtype,
                                 organization_id                IN NUMBER, 
                                 item_gabarito                  IN VARCHAR2)
  IS
  BEGIN
    
     ----------------------------------------------------------------------------------
      ---> SAE 27/01/2016
      IF( vempresa_integracao = 'KLASS_SAE') THEN
      
         --   FOR x IN ( SELECT DISTINCT 1 FROM mtl_system_items_b WHERE segment1 = r1.codigo AND inventory_item_flag = 'Y')
         --     LOOP
         --     r_mtl_system_items_interface.inventory_item_flag := 'Y'; 
         --   END LOOP;
     
        --- DEMANDA 11265 -- INI
        IF( organization_id = 122 ) THEN  -- ORG SÃO PAULO

            r_mtl_system_items_interface.reservable_type := 2;
            r_mtl_system_items_interface.mtl_transactions_enabled_flag := 'N';
            r_mtl_system_items_interface.stock_enabled_flag := 'N';
            r_mtl_system_items_interface.inventory_item_flag  := 'Y';
            r_mtl_system_items_interface.check_shortages_flag := 'N';
    
        ELSIF( item_gabarito = 'EPI' OR  item_gabarito = 'ESTOQUE REP C/ SERIE' OR  item_gabarito = 'ESTOQUE REP S/ SERIE' OR  item_gabarito = 'ESTOQUE NAO REP S/ SERIE' OR  item_gabarito = 'ESTOQUE NAO REP C/ SERIE'  ) THEN
      
            r_mtl_system_items_interface.reservable_type := 1;
            r_mtl_system_items_interface.mtl_transactions_enabled_flag := 'Y';
            r_mtl_system_items_interface.stock_enabled_flag :='Y';
            r_mtl_system_items_interface.inventory_item_flag  := 'Y';
            r_mtl_system_items_interface.check_shortages_flag := 'Y';
      
        ELSIF( item_gabarito = 'NAO ESTOCAVEL') THEN
            
            r_mtl_system_items_interface.reservable_type := 2;
            r_mtl_system_items_interface.mtl_transactions_enabled_flag := 'N';
            r_mtl_system_items_interface.stock_enabled_flag := 'N';
            r_mtl_system_items_interface.inventory_item_flag  := 'Y';
            r_mtl_system_items_interface.check_shortages_flag := 'N';
                
        ELSIF( item_gabarito = 'ATIVO REP C/ SERIE' OR item_gabarito = 'ATIVO REP S/ SERIE' OR item_gabarito = 'ATIVO NAO REP C/ SERIE' OR item_gabarito = 'ATIVO NAO REP S/ SERIE') THEN
            
            r_mtl_system_items_interface.reservable_type := 1;
            r_mtl_system_items_interface.mtl_transactions_enabled_flag := 'Y';
            r_mtl_system_items_interface.stock_enabled_flag := 'Y';
            r_mtl_system_items_interface.inventory_item_flag  := 'Y';
            r_mtl_system_items_interface.check_shortages_flag := 'N';
      
        ELSIF( item_gabarito = 'SERVICO' ) THEN
            
           r_mtl_system_items_interface.reservable_type := 2;
            r_mtl_system_items_interface.mtl_transactions_enabled_flag := 'N';
            r_mtl_system_items_interface.stock_enabled_flag := 'N';
            r_mtl_system_items_interface.inventory_item_flag  := 'N';
            r_mtl_system_items_interface.check_shortages_flag := 'N';
			r_mtl_system_items_interface.costing_enabled_flag := 'Y';
			r_mtl_system_items_interface.inventory_asset_flag := 'Y';
			r_mtl_system_items_interface.create_supply_flag := 'Y';
			r_mtl_system_items_interface.build_in_wip_flag := 'N';
			r_mtl_system_items_interface.invoiceable_item_flag := 'Y';
			r_mtl_system_items_interface.invoice_enabled_flag := 'Y';
			r_mtl_system_items_interface.process_execution_enabled_flag := 'N';
			r_mtl_system_items_interface.recipe_enabled_flag := 'N';
			

        END IF;
      END IF;
       --- DEMANDA 11265 -- FIM
       
  
  
  
    RETURN;
    
  END customiza_por_cliente;
  

  /*******************************************************************************************
   Function que faz a inclusão do item na interface de item e categoria de item
  ********************************************************************************************/

  FUNCTION inclusao_item_interface ( v_rowid             IN  VARCHAR2
                                    ,master_organization IN  VARCHAR2
                                    ,v_codigo_item       IN  VARCHAR2 )
  RETURN VARCHAR2
  IS

      v_category_id                     NUMBER;
      msg_retorno                       VARCHAR2(5000);
      r_mtl_system_items_interface      mtl_system_items_interface%ROWTYPE;
      v_primary_unit_of_measure         VARCHAR2(500);
      contador                          NUMBER;
      vexiste_item_origem               NUMBER := 0;

      vsomente_oi_tabela                VARCHAR2(100);

  BEGIN

       gera_log_tabela(v_sequencia_processamento
                      ,'Inicio do processamento da inclusao de item' || v_codigo_item
                      ,SYSDATE
                      ,'P'
                      ,v_nome_concorrente
                      ,v_debug);

       ---> faz a leitura do registro do item lido da tabela de integração

       FOR r1 IN (
                   SELECT *
                     FROM klass_integracao_ebs
                    WHERE ROWID = v_rowid
                 )
       LOOP

       
          ---> verifica se a tabela de OIs está preenchida para o id klassmatt lido
          ---  Se estiver então pega somente as OIs do item origem que estão nessa tabela
          ---  Mas somente quando não for a leitura da mestre

          SELECT COUNT(*)
            INTO contador
            FROM klass_integracao_oi_item
           WHERE id_item_klassmatt = r1.id_item_klassmatt
             AND status            = 2;

          IF contador > 0 THEN
              vsomente_oi_tabela := 'S';
          ELSE
              vsomente_oi_tabela := 'N';
          END IF;


          ---> Faz a leitura do item_origem do ebs para cada organização

          FOR r2 IN (
                     SELECT *
                       FROM mtl_system_items_b
                      WHERE segment1 = r1.item_origem
                        AND ( ( master_organization = 'Y' AND
                                organization_id    IN (SELECT to_number(attribute1)
                                                         FROM klass_configuracao
                                                        WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
                              )
                                OR
                              ( master_organization = 'N' AND
                                organization_id     NOT IN (SELECT to_number(attribute1)
                                                              FROM klass_configuracao
                                                             WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
                                AND organization_id IN (SELECT organization_id
                                                          FROM org_organization_definitions
                                                         WHERE organization_id = mtl_system_items_b.organization_id
                                                           AND disable_date   IS NULL )
                                AND organization_id NOT IN (SELECT organization_id
                                                              FROM mtl_system_items_b
                                                             WHERE segment1 = v_codigo_item )
                                AND ( ( vsomente_oi_tabela = 'N' ) OR
                                      ( vsomente_oi_tabela = 'S' AND
                                        organization_id IN ( SELECT organization_id
                                                               FROM klass_integracao_oi_item
                                                              WHERE id_item_klassmatt = r1.id_item_klassmatt
                                                                AND status            = 2
                                                                AND organization_id   = mtl_system_items_b.organization_id
                                                            )
                                      )
                                    )
                               )
                            )
                     )
          LOOP

             gera_log_tabela(v_sequencia_processamento
                            ,'Processamento do item origem ' || r2.inventory_item_id || ' org ' || r2.organization_id ||
                             ' codigo gerado ' || v_codigo_item
                            ,SYSDATE
                            ,'P'
                            ,v_nome_concorrente
                            ,v_debug);

             vexiste_item_origem := 1;

             ---> Monta os campos para inclusão do item usando os campos da tabela de integração

            r_mtl_system_items_interface := NULL;
             
            msg_retorno := tab_mtl_system_items_interface
                                                ( r2.inventory_item_id
                                                 ,r2.organization_id
                                                 ,r_mtl_system_items_interface);

            IF msg_retorno <> 'OK' THEN
                RAISE erro;
            END IF;

            
            --->  Verifica se tem attributes e globals a serem trocados
            
            msg_retorno := attribute_items_interface
                                   (  p_rowid_tab_integ             => v_rowid
                                     ,p_organization_id             => r2.organization_id
                                     ,p_mtl_system_items_interface  => r_mtl_system_items_interface );
            
            IF msg_retorno <> 'OK' THEN
                RAISE erro;
            END IF;
            
            
            ---> Encontra o campo necessário UNIT_OF_MEASURE da unidade

            BEGIN

                  SELECT unit_of_measure
                    INTO v_primary_unit_of_measure
                    FROM mtl_units_of_measure
                   WHERE uom_code = r1.unidade_medida;

                 EXCEPTION
                    WHEN OTHERS THEN
                       msg_retorno := 'Erro ao acessar a unidade de medida do item no EBS - '
                                      || 'item klassmat ' || r1.id_item_klassmatt ||
                                      ' - erro ' || SQLERRM;
                       RAISE erro;
            END;


            ---> Verifica se não tem que alterar o status do item

            IF nvl(r1.inativa_item,'N') = 'S'   THEN
                 r_mtl_system_items_interface.inventory_item_status_code := 'Inactive';
            ELSE
                 r_mtl_system_items_interface.inventory_item_status_code := 'Active';
            END IF;


             ---> Verifica se não tem que alterar o tipo do item

             IF r1.item_type IS NOT NULL THEN
                 r_mtl_system_items_interface.item_type := r1.item_type;   --- item_type da interface klassmatt
             END IF;


            r_mtl_system_items_interface.set_process_id           := 60;
            r_mtl_system_items_interface.process_flag             := 1;
            r_mtl_system_items_interface.transaction_type         := 'CREATE';
            r_mtl_system_items_interface.item_number              := v_codigo_item;
            r_mtl_system_items_interface.description              := substr(r1.descricao_media,1,240);
            r_mtl_system_items_interface.primary_uom_code         := r1.unidade_medida;
            r_mtl_system_items_interface.primary_unit_of_measure  := v_primary_unit_of_measure;
            r_mtl_system_items_interface.segment1                 := v_codigo_item;
            r_mtl_system_items_interface.long_description         := r1.descricao_completa;
            r_mtl_system_items_interface.last_update_date         := SYSDATE;
            r_mtl_system_items_interface.last_updated_by          := fnd_profile.value('user_id');
            r_mtl_system_items_interface.creation_date            := SYSDATE;
            r_mtl_system_items_interface.created_by               := fnd_profile.value('user_id');
            r_mtl_system_items_interface.last_update_login        := fnd_profile.value('user_id');
            r_mtl_system_items_interface.global_attribute2        := r1.classe_cond_transacao;
            r_mtl_system_items_interface.global_attribute3        := r1.origem;
      
            IF r1.flag_compravel IS NOT NULL THEN
                
                SELECT decode(r1.flag_compravel,'N','N','Y')
                  INTO r_mtl_system_items_interface.purchasing_enabled_flag 
                  FROM dual;
                
                
                SELECT decode(r1.flag_compravel,'N','N','Y')
                  INTO r_mtl_system_items_interface.purchasing_item_flag 
                  FROM dual;
                   
            END IF;
            
            
            ---> Verifica como será tratado a classificação fiscal, se como um global_attribute ou uma categoria
            ---  De acordo com a empresa de integração
            ---> slc é como um global_attribute

            IF vempresa_integracao = 'KLASS_EMPRESA_2' THEN
                  r_mtl_system_items_interface.global_attribute1        := r1.ncm_classificacao_fiscal;
          
            END IF;

            ----------------------------------------------------------------------------------

            customiza_por_cliente( r_mtl_system_items_interface, r2.organization_id, r1.item_gabarito);
            
            BEGIN

                 insert into mtl_system_items_interface
                                     VALUES  r_mtl_system_items_interface ;

         IF  vgrava_log_open_interface = 'S'  THEN
            insert into  klassmatt.dbg_mtl_system_items_interface
              values r_mtl_system_items_interface ;
                 END IF;
         
                 EXCEPTION
                    WHEN OTHERS THEN
                       msg_retorno := 'Erro ao incluir na tabela mtl_system_items_interface - '
                                      || 'item klassmat ' || r1.id_item_klassmatt ||
                                      ' - erro ' || SQLERRM;
                       RAISE erro;
             END;


             ---> Monta os campos para inclusão das categorias do item usando os campos das categorias do item
             ---  origem, tirando o v_category_set_id, o qual representa o INV_AG que deverá ser incluso a parte
             ---  acessados a partir da organização lida

             gera_log_tabela(v_sequencia_processamento
                            ,'Processamento categorias do item ' || r2.inventory_item_id || ' org ' || r2.organization_id
                            ,SYSDATE
                            ,'P'
                            ,v_nome_concorrente
                            ,v_debug);


             FOR R3 IN (
                              SELECT i.category_set_id
                                   , i.category_id
                                   , s.category_set_name
                                   , s.structure_id
                                FROM mtl_item_categories i
                                    ,mtl_categories_b    c
                                    ,mtl_category_sets   s
                               WHERE i.category_set_id   = s.category_set_id
                                 AND i.category_id       = c.category_id
                                 AND c.structure_id      = s.structure_id
                                 AND i.inventory_item_id = r2.inventory_item_id
                                 AND i.organization_id   = r2.organization_id
                                 AND ( r2.organization_id IN (SELECT to_number(attribute1)
                                                                FROM klass_configuracao
                                                                WHERE tipo = 'ID_ORGANIZACAO_MESTRE' ) OR
                                     ( r2.organization_id NOT IN (SELECT to_number(attribute1)
                                                                    FROM klass_configuracao
                                                                   WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
                                            AND control_level <> 1) )
                       )
             LOOP

                    ---> se categoria for AS CATEGORIAS SEM SER A ORIGINADA DA MESTRE deve ser buscado o category_id que
                    ---  está vindo na integração

                    v_category_id := NULL;

                    SELECT COUNT(*)
                      INTO contador
                      FROM klass_configuracao
                     WHERE upper(attribute1) = upper(r3.category_set_name)
                       AND tipo       = 'SETA_CATEGORIA';

                    IF contador > 0 THEN

                          msg_retorno := valida_categoria (upper(r3.category_set_name)
                                                          ,r3.structure_id
                                                          ,v_rowid
                                                          ,v_category_id );

                          IF msg_retorno <> 'OK' THEN

                                ---> exclui o item criado na interface

                                DELETE FROM mtl_system_items_interface
                                  WHERE item_number     = v_codigo_item
                                    AND organization_id = r2.organization_id;
                                    
                                    
                                DELETE FROM mtl_item_categories_interface
                                  WHERE item_number     = v_codigo_item
                                    AND organization_id = r2.organization_id;
                                    
                                    
                                DELETE FROM mtl_item_revisions_interface
                                 WHERE item_number     = v_codigo_item
                                   AND organization_id = r2.organization_id;

                                RAISE erro;

                          END IF;

                          IF v_category_id IS NULL THEN
                              v_category_id := r3.category_id;
                          END IF;


                    ELSE
                         v_category_id := r3.category_id;
                    END IF;

                   ---> inclui a categoria

                   IF v_category_id IS NOT NULL THEN

                         gera_log_tabela(v_sequencia_processamento
                                      ,'Categoria do item ' || r2.inventory_item_id || ' org ' || r2.organization_id ||
                                        ' categ ' || r3.category_id || ' category_set_id ' ||
                                        r3.category_set_id
                                      ,SYSDATE
                                      ,'P'
                                      ,v_nome_concorrente
                                      ,v_debug);


                         BEGIN

                               insert into mtl_item_categories_interface
                                           ( set_process_id
                                            ,process_flag
                                            ,transaction_type
                                            ,item_number
                                            ,organization_id
                                            ,category_set_id
                                            ,category_id
                                            ,old_category_id
                                            ,last_update_date
                                            ,last_updated_by
                                            ,creation_date
                                            ,created_by
                                            ,last_update_login )
                                     values
                                           ( 60
                                            ,1
                                            ,'CREATE'
                                            ,v_codigo_item
                                            ,r2.organization_id
                                            ,r3.category_set_id
                                            ,v_category_id
                                            ,NULL --r3.category_id
                                            ,SYSDATE
                                            ,fnd_profile.value('user_id')
                                            ,SYSDATE
                                            ,fnd_profile.value('user_id')
                                            ,fnd_profile.value('user_id') );

                              EXCEPTION
                                 WHEN OTHERS THEN
                                      msg_retorno := 'Erro oracle ao incluir a category_id :'     ||
                                                           ' structure_id = ' || r3.structure_id         ||
                                                           ' categ_segment2 = '        || r1.categ_segment2               ||
                                                           ' categ_segment3 = '     || r1.categ_segment3            ||
                                                           ' categ_segment1 = '      || r1.categ_segment1             ||
                                                           ' principio ativo = ' || r1.categ_segment4;
                                      RAISE erro;
                          END;

                   END IF;

              END LOOP;  --- r3


              ----------------------- grava a tabela de controle --------------------------

              gera_log_tabela(v_sequencia_processamento
                             ,'Gravando a tabela de controle do item origem ' || r2.inventory_item_id || ' org ' || r2.organization_id
                             ,SYSDATE
                             ,'P'
                             ,v_nome_concorrente
                             ,v_debug);

              v_linha := v_linha + 1;

              ---> verifica se o cara está na tabela de controle

              SELECT COUNT(*)
                INTO contador
                FROM klass_integracao_controle
               WHERE id_item_klassmatt = r1.id_item_klassmatt
                 AND organization_id   = r2.organization_id
                 AND status_execucao   = 'P';

              IF contador = 0 THEN

                  BEGIN

                        INSERT INTO klass_integracao_controle
                                         ( id_processamento
                                          ,request_id
                                          ,status_execucao
                                          ,id_item_klassmatt
                                          ,id_item_alterado
                                          ,codigo_item
                                          ,organization_id
                                          ,tipo_operacao
                                          ,rowid_tabela_integracao
                                          ,dt_criacao
                                          ,dt_atualizacao )
                                 VALUES
                                         ( v_sequencia_processamento
                                          ,NULL
                                          ,'S'      --- stand by esperando execução
                                          ,r1.id_item_klassmatt
                                          ,NULL
                                          ,v_codigo_item
                                          ,r2.organization_id
                                          ,'CREATE'
                                          ,v_rowid
                                          ,SYSDATE
                                          ,SYSDATE );

                         EXCEPTION

                             WHEN OTHERS THEN
                                 msg_retorno := 'Erro ao incluir a tabela klass_integracao_controle - '
                                                || SQLERRM || ' id_item_klassmatt ' ||
                                                r1.id_item_klassmatt;
                                 RAISE erro;

                  END;

              ELSE

                   UPDATE klass_integracao_controle
                           SET id_processamento = v_sequencia_processamento
                              ,status_execucao  = 'S'
                    WHERE id_item_klassmatt = r1.id_item_klassmatt
                      AND organization_id   = r2.organization_id
                      AND status_execucao   = 'P';
              END IF;

              -----------------------------------------------------------------------------

          END LOOP;  -- r2

          IF vexiste_item_origem = 0 THEN
              msg_retorno := 'Item origem informado não existe - id_item_klassmatt ' ||
                                                r1.id_item_klassmatt;
              RAISE erro;
          END IF;

       END LOOP;  -- r1

       RETURN('OK');

       EXCEPTION
          WHEN erro THEN
            gera_log_tabela(v_sequencia_processamento
                           ,msg_retorno
                           ,SYSDATE
                           ,'P'
                           ,v_nome_concorrente
                           ,v_debug);
            RETURN(msg_retorno);

          WHEN OTHERS THEN
            gera_log_tabela(v_sequencia_processamento
                           ,'Erro Oracle: '||sqlerrm
                           ,SYSDATE
                           ,'P'
                           ,v_nome_concorrente
                           ,v_debug);
            dbms_output.put_line('Processamento terminou com ERRO. Verifique LOG !');
            raise_application_error(-20011,'Erro Oracle: '||sqlerrm);


  END inclusao_item_interface;


  /*******************************************************************************************
   Function que faz a inclusão do item na interface de item e categoria de item a partir do
   item gabarito
  ********************************************************************************************/

  FUNCTION inclusao_item_gabarito ( v_rowid             IN  VARCHAR2
                                    ,master_organization IN  VARCHAR2
                                    ,v_codigo_item       IN  VARCHAR2 )
  RETURN VARCHAR2
  IS

      v_category_id                     NUMBER;
      msg_retorno                       VARCHAR2(5000);
      r_mtl_system_items_interface      mtl_system_items_interface%ROWTYPE;
      v_primary_unit_of_measure         VARCHAR2(500);
      contador                          NUMBER;
      vinventory_item_id                NUMBER;


  BEGIN

       gera_log_tabela(v_sequencia_processamento
                      ,'Inicio do processamento da inclusao de item ' || v_codigo_item
                      ,SYSDATE
                      ,'P'
                      ,v_nome_concorrente
                      ,v_debug);


       ---> faz a leitura do registro do item lido da tabela de integração

       FOR r1 IN (
                   SELECT *
                     FROM klass_integracao_ebs
                    WHERE ROWID = v_rowid
                 )
       LOOP
       
          ---> Faz a leitura das organizações que serão criadas a partir do gabarito

          FOR r2 IN (
                      SELECT to_number(attribute1)  organization_id
                        FROM klass_configuracao
                       WHERE tipo = 'ID_ORGANIZACAO_MESTRE'
                         AND master_organization = 'Y'

                      UNION

                      SELECT organization_id
                        FROM klass_integracao_oi_item
                       WHERE id_item_klassmatt = r1.id_item_klassmatt
                         AND status            = 2
                         AND (
                               master_organization = 'N' AND
                                organization_id     NOT IN (SELECT to_number(attribute1)
                                                              FROM klass_configuracao
                                                             WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
                                AND organization_id IN (SELECT organization_id
                                                          FROM org_organization_definitions
                                                         WHERE organization_id = klass_integracao_oi_item.organization_id
                                                           AND disable_date   IS NULL )
                                AND organization_id NOT IN (SELECT organization_id
                                                              FROM mtl_system_items_b
                                                             WHERE segment1 = v_codigo_item )
                             )
                       )
          LOOP

             gera_log_tabela(v_sequencia_processamento
                            ,'Processamento do item gabarito ' || r1.item_gabarito || ' org ' || r2.organization_id ||
                             ' codigo gerado ' || v_codigo_item
                            ,SYSDATE
                            ,'P'
                            ,v_nome_concorrente
                            ,v_debug);

                            
            r_mtl_system_items_interface := NULL;                
                            
            ---> Se for a mestre faz o processamento e preenche de acordo com o que está abaixo

            IF master_organization = 'Y' THEN

                  ---> Encontra o campo necessário UNIT_OF_MEASURE da unidade

                  BEGIN

                        SELECT unit_of_measure
                          INTO v_primary_unit_of_measure
                          FROM mtl_units_of_measure
                         WHERE uom_code = r1.unidade_medida;

                       EXCEPTION
                          WHEN OTHERS THEN
                             msg_retorno := 'Erro ao acessar a unidade de medida do item no EBS - '
                                            || 'item klassmat ' || r1.id_item_klassmatt ||
                                            ' - erro ' || SQLERRM;
                             RAISE erro;
                  END;

                  ---> Move sempre fixo o global_attribute_category

                  r_mtl_system_items_interface.global_attribute_category := 'JL.BR.INVIDITM.XX.Fiscal';


                  ---> Verifica se não tem que alterar o status do item

                  IF nvl(r1.inativa_item,'N') = 'S'   THEN
                       r_mtl_system_items_interface.inventory_item_status_code := 'Inactive';
                  ELSE
                       r_mtl_system_items_interface.inventory_item_status_code := 'Active';
                  END IF;


                   ---> Verifica se não tem que alterar o tipo do item

                   IF r1.item_type IS NOT NULL THEN
                       r_mtl_system_items_interface.item_type := r1.item_type;   --- item_type da interface klassmatt
                   END IF;


                  r_mtl_system_items_interface.organization_id          := r2.organization_id;
                  r_mtl_system_items_interface.template_name            := r1.item_gabarito;

                  r_mtl_system_items_interface.set_process_id           := 60;
                  r_mtl_system_items_interface.process_flag             := 1;
                  r_mtl_system_items_interface.transaction_type         := 'CREATE';
                  r_mtl_system_items_interface.item_number              := v_codigo_item;
                  r_mtl_system_items_interface.description              := substr(r1.descricao_media,1,240);
                  r_mtl_system_items_interface.primary_uom_code         := r1.unidade_medida;
                  r_mtl_system_items_interface.primary_unit_of_measure  := v_primary_unit_of_measure;
                  r_mtl_system_items_interface.segment1                 := v_codigo_item;
                  r_mtl_system_items_interface.long_description         := r1.descricao_completa;
                  r_mtl_system_items_interface.last_update_date         := SYSDATE;
                  r_mtl_system_items_interface.last_updated_by          := fnd_profile.value('user_id');
                  r_mtl_system_items_interface.creation_date            := SYSDATE;
                  r_mtl_system_items_interface.created_by               := fnd_profile.value('user_id');
                  r_mtl_system_items_interface.last_update_login        := fnd_profile.value('user_id');
                  r_mtl_system_items_interface.global_attribute2        := r1.classe_cond_transacao;
                  r_mtl_system_items_interface.global_attribute3        := r1.origem;

                  IF r1.flag_compravel IS NOT NULL THEN
                
                      SELECT decode(r1.flag_compravel,'N','N','Y')
                        INTO r_mtl_system_items_interface.purchasing_enabled_flag 
                        FROM dual;
                
                
                      SELECT decode(r1.flag_compravel,'N','N','Y')
                        INTO r_mtl_system_items_interface.purchasing_item_flag 
                        FROM dual;
                         
                  END IF;
          
          IF vempresa_integracao = 'KLASS_EMPRESA_3' THEN
          r_mtl_system_items_interface.attribute3 := replace(r1.ITEM_OWNER, 'OOG-', '');
          END IF;
                                    
                  --->  Verifica se tem attributes e globals a serem trocados
            
                  msg_retorno := attribute_items_interface
                                         (  p_rowid_tab_integ             => v_rowid
                                           ,p_organization_id             => r2.organization_id
                                           ,p_mtl_system_items_interface  => r_mtl_system_items_interface );
                  
                  IF msg_retorno <> 'OK' THEN
                      RAISE erro;
                  END IF;
                  
                  
                  ---> Verifica como será tratado a classificação fiscal, se como um global_attribute ou uma categoria
                  ---  De acordo com a empresa de integração
                  ---> slc é como um global_attribute

                  IF vempresa_integracao = 'KLASS_EMPRESA_2' THEN
                        r_mtl_system_items_interface.global_attribute1        := r1.ncm_classificacao_fiscal;
                  END IF;

            ELSE   ---> os filhos, a partir do gabarito, são copiados a partir da organização mestre

                ---> Acessa o inventory_item_id do item na mestre

                BEGIN

                    SELECT inventory_item_id
                      INTO vinventory_item_id
                      FROM mtl_system_items_b
                     WHERE organization_id IN (SELECT to_number(attribute1)
                                                 FROM klass_configuracao
                                                WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
                       AND segment1        = v_codigo_item;


                    EXCEPTION
                          WHEN OTHERS THEN
                             msg_retorno := 'Erro ao acessar o id do item da mestre - '
                                            || 'item klassmat ' || r1.id_item_klassmatt ||
                                            ' - erro ' || SQLERRM;

                             RAISE erro;

                END;


                ------------------------------------------------------------------------

                r_mtl_system_items_interface.template_name              := NULL;

                r_mtl_system_items_interface.item_number                := NULL;
                r_mtl_system_items_interface.description                := NULL;
                r_mtl_system_items_interface.primary_uom_code           := NULL;
                r_mtl_system_items_interface.primary_unit_of_measure    := NULL;
                r_mtl_system_items_interface.segment1                   := NULL;
                r_mtl_system_items_interface.long_description           := NULL;
                r_mtl_system_items_interface.item_type                  := NULL;
                r_mtl_system_items_interface.inventory_item_status_code := NULL;

                r_mtl_system_items_interface.set_process_id             := 60;
                r_mtl_system_items_interface.process_flag               := 1;
                r_mtl_system_items_interface.transaction_type           := 'CREATE';
                r_mtl_system_items_interface.inventory_item_id          := vinventory_item_id;
                r_mtl_system_items_interface.organization_id           := r2.organization_id;
                r_mtl_system_items_interface.last_update_date           := SYSDATE;
                r_mtl_system_items_interface.last_updated_by            := fnd_profile.value('user_id');
                r_mtl_system_items_interface.creation_date              := SYSDATE;
                r_mtl_system_items_interface.created_by                 := fnd_profile.value('user_id');
                r_mtl_system_items_interface.last_update_login          := fnd_profile.value('user_id');

                IF r1.flag_compravel IS NOT NULL THEN
                
                    SELECT decode(r1.flag_compravel,'N','N','Y')
                      INTO r_mtl_system_items_interface.purchasing_enabled_flag 
                      FROM dual;
                
                
                    SELECT decode(r1.flag_compravel,'N','N','Y')
                      INTO r_mtl_system_items_interface.purchasing_item_flag 
                      FROM dual;
                       
                END IF;
                
                
                --->  Verifica se tem attributes e globals a serem trocados
            
                msg_retorno := attribute_items_interface
                                       (  p_rowid_tab_integ             => v_rowid
                                         ,p_organization_id             => r2.organization_id
                                         ,p_mtl_system_items_interface  => r_mtl_system_items_interface );
                
                IF msg_retorno <> 'OK' THEN
                    RAISE erro;
                END IF;
                
                -------------------------------------------------------------------------

            END IF;

            ----------------------------------------------------------------------------------

            customiza_por_cliente( r_mtl_system_items_interface, r2.organization_id, r1.item_gabarito);
            
            BEGIN

                 INSERT INTO mtl_system_items_interface
                                     VALUES  r_mtl_system_items_interface ;

                 IF  vgrava_log_open_interface = 'S'  THEN
            insert into  klassmatt.dbg_mtl_system_items_interface
              values r_mtl_system_items_interface ;
                 END IF;
                                      
                 EXCEPTION
                    WHEN OTHERS THEN
                       msg_retorno := 'Erro ao incluir na tabela mtl_system_items_interface - '
                                      || 'item klassmat ' || r1.id_item_klassmatt ||
                                      ' - erro ' || SQLERRM;
                       RAISE erro;
             END;


             ---> Monta os campos para inclusão das categorias do item usando a categoria da tabela de integração
             ---  As categorias de nível mestre serão gravadas como default

             gera_log_tabela(v_sequencia_processamento
                                ,'Processamento categorias do item gabarito ' || r1.item_gabarito || ' org ' || r2.organization_id
                                ,SYSDATE
                                ,'P'
                                ,v_nome_concorrente
                                ,v_debug);

             ---> as categorias sem ser a originada da mestre deve ser buscado o category_id que
             ---  está vindo na integração


             FOR r3 IN (
                         SELECT c.structure_id
                               ,c.category_set_name
                               ,c.category_set_id
                           FROM klass_configuracao   k
                               ,mtl_category_sets    c
                          WHERE upper(k.attribute1)   = upper(c.category_set_name)
                            AND k.tipo                = 'SETA_CATEGORIA'
                            AND ( r2.organization_id IN (SELECT to_number(attribute1)
                                                                FROM klass_configuracao
                                                                WHERE tipo = 'ID_ORGANIZACAO_MESTRE' ) OR
                                   ( r2.organization_id NOT IN (SELECT to_number(attribute1)
                                                                  FROM klass_configuracao
                                                                 WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
                                          AND control_level <> 1 ) )
                        )
             LOOP

                    v_category_id := NULL;

                    msg_retorno := valida_categoria (upper(r3.category_set_name)
                                                    ,r3.structure_id
                                                    ,v_rowid
                                                    ,v_category_id );

                    IF msg_retorno <> 'OK' THEN

                          ---> exclui o item criado na interface

                          DELETE FROM mtl_system_items_interface
                            WHERE item_number     = v_codigo_item
                              AND organization_id = r2.organization_id;
                              
                              
                          DELETE FROM mtl_item_categories_interface
                           WHERE item_number     = v_codigo_item
                             AND organization_id = r2.organization_id;   
                             
                             
                          DELETE FROM mtl_item_revisions_interface
                           WHERE item_number     = v_codigo_item
                             AND organization_id = r2.organization_id;

                          RAISE erro;

                    END IF;


                   ---> inclui a categoria

                   IF v_category_id IS NOT NULL THEN

                         gera_log_tabela(v_sequencia_processamento
                                      ,'Categoria do item gabarito ' || r1.item_gabarito || ' org ' || r2.organization_id ||
                                        ' categ ' || v_category_id || ' category_set_id ' ||
                                        r3.category_set_id
                                      ,SYSDATE
                                      ,'P'
                                      ,v_nome_concorrente
                                      ,v_debug);


                         BEGIN

                               insert into mtl_item_categories_interface
                                           ( set_process_id
                                            ,process_flag
                                            ,transaction_type
                                            ,item_number
                                            ,organization_id
                                            ,category_set_id
                                            ,category_id
                                            ,old_category_id
                                            ,last_update_date
                                            ,last_updated_by
                                            ,creation_date
                                            ,created_by
                                            ,last_update_login )
                                     values
                                           ( 60
                                            ,1
                                            ,'CREATE'
                                            ,v_codigo_item
                                            ,r2.organization_id
                                            ,r3.category_set_id
                                            ,v_category_id
                                            ,NULL --r3.category_id
                                            ,SYSDATE
                                            ,fnd_profile.value('user_id')
                                            ,SYSDATE
                                            ,fnd_profile.value('user_id')
                                            ,fnd_profile.value('user_id') );

                              EXCEPTION
                                 WHEN OTHERS THEN
                                      msg_retorno := 'Erro oracle ao incluir a category_id :'     ||
                                                           ' structure_id = ' || r3.structure_id         ||
                                                           ' categ_segment2 = '        || r1.categ_segment2               ||
                                                           ' categ_segment3 = '     || r1.categ_segment3            ||
                                                           ' categ_segment1 = '      || r1.categ_segment1             ||
                                                           ' principio ativo = ' || r1.categ_segment4;
                                      RAISE erro;
                          END;

                   END IF;


              END LOOP;  --- r3


              ----------------------- grava a tabela de controle --------------------------

              gera_log_tabela(v_sequencia_processamento
                             ,'Gravando a tabela de controle do item gabarito ' || r1.item_gabarito || ' org ' || r2.organization_id
                             ,SYSDATE
                             ,'P'
                             ,v_nome_concorrente
                             ,v_debug);

              v_linha := v_linha + 1;

              ---> verifica se o cara está na tabela de controle

              SELECT COUNT(*)
                INTO contador
                FROM klass_integracao_controle
               WHERE id_item_klassmatt = r1.id_item_klassmatt
                 AND organization_id   = r2.organization_id
                 AND status_execucao   = 'P';

              IF contador = 0 THEN

                  BEGIN

                        INSERT INTO klass_integracao_controle
                                         ( id_processamento
                                          ,request_id
                                          ,status_execucao
                                          ,id_item_klassmatt
                                          ,id_item_alterado
                                          ,codigo_item
                                          ,organization_id
                                          ,tipo_operacao
                                          ,rowid_tabela_integracao
                                          ,dt_criacao
                                          ,dt_atualizacao )
                                 VALUES
                                         ( v_sequencia_processamento
                                          ,NULL
                                          ,'S'      --- stand by esperando execução
                                          ,r1.id_item_klassmatt
                                          ,NULL
                                          ,v_codigo_item
                                          ,r2.organization_id
                                          ,'CREATE'
                                          ,v_rowid
                                          ,SYSDATE
                                          ,SYSDATE );

                         EXCEPTION

                             WHEN OTHERS THEN
                                 msg_retorno := 'Erro ao incluir a tabela klass_integracao_controle - '
                                                || SQLERRM || ' id_item_klassmatt ' ||
                                                r1.id_item_klassmatt;
                                 RAISE erro;

                  END;

              ELSE

                   UPDATE klass_integracao_controle
                           SET id_processamento = v_sequencia_processamento
                              ,status_execucao  = 'S'
                    WHERE id_item_klassmatt = r1.id_item_klassmatt
                      AND organization_id   = r2.organization_id
                      AND status_execucao   = 'P';
              END IF;

          -----------------------------------------------------------------------------

          END LOOP;  -- r2


       END LOOP;  -- r1

       RETURN('OK');

       EXCEPTION
          WHEN erro THEN
            gera_log_tabela(v_sequencia_processamento
                           ,msg_retorno
                           ,SYSDATE
                           ,'P'
                           ,v_nome_concorrente
                           ,v_debug);
            RETURN(msg_retorno);

          WHEN OTHERS THEN
            gera_log_tabela(v_sequencia_processamento
                           ,'Erro Oracle: '||sqlerrm
                           ,SYSDATE
                           ,'P'
                           ,v_nome_concorrente
                           ,v_debug);
            dbms_output.put_line('Processamento terminou com ERRO. Verifique LOG !');
            raise_application_error(-20011,'Erro Oracle: '||sqlerrm);


  END inclusao_item_gabarito;


   /*******************************************************************************************
   Function que faz a alteração do item na interface de item e categoria de item tipo INV_AG
  ********************************************************************************************/

  FUNCTION alteracao_item_interface ( v_rowid             IN  VARCHAR2
                                     ,master_organization IN VARCHAR2 )
  RETURN VARCHAR2
  IS

      v_category_id                NUMBER;
      msg_retorno                  VARCHAR2(5000);
      contador                     NUMBER;

      v_segment1                         VARCHAR2(200);
      v_segment2                         VARCHAR2(200);
      v_segment3                         VARCHAR2(200);
      v_segment4                         VARCHAR2(200);
      v_segment5                         VARCHAR2(200);
      v_segment6                         VARCHAR2(200);
      v_segment7                         VARCHAR2(200);
      v_segment8                         VARCHAR2(200);
      v_code_combination_id              NUMBER;
      vexpense_account                   NUMBER;
      vutilizacao_fiscal                 VARCHAR2(1000);
      vinventory_item_status_code        VARCHAR2(200);
      vitem_type                         VARCHAR2(300);
      vpurchasing_enabled_flag           VARCHAR2(300);
      vpurchasing_item_flag              VARCHAR2(300);
      vtransaction_type                  VARCHAR2(300);
      vold_category_id                   NUMBER;
      r_mtl_system_items_interface       mtl_system_items_interface%ROWTYPE;
      vglobal_attribute1                 VARCHAR2(150);

  BEGIN

       gera_log_tabela(v_sequencia_processamento
                      ,'Inicio do processamento da alteracao de item'
                      ,SYSDATE
                      ,'P'
                      ,v_nome_concorrente
                      ,v_debug);

       ---> faz a leitura do registro do item lido da tabela de integração

       FOR r1 IN (
                   SELECT *
                     FROM klass_integracao_ebs
                    WHERE ROWID = v_rowid
                 )
       LOOP


       gera_log_tabela(v_sequencia_processamento
                      ,'Leu rowid do item'
                      ,SYSDATE
                      ,'P'
                      ,v_nome_concorrente
                      ,v_debug);


          ---> Faz a leitura do item_number do ebs para cada organização

          FOR r2 IN (
                     SELECT *
                       FROM mtl_system_items_b
                      WHERE segment1 = r1.codigo
                        AND ( ( master_organization = 'Y' AND
                                organization_id    IN (SELECT to_number(attribute1)
                                                         FROM klass_configuracao
                                                        WHERE tipo = 'ID_ORGANIZACAO_MESTRE' ) )
                                OR
                              ( master_organization = 'N' AND
                                organization_id     NOT IN (SELECT to_number(attribute1)
                                                              FROM klass_configuracao
                                                             WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
                                AND organization_id IN (SELECT organization_id
                                                          FROM org_organization_definitions
                                                         WHERE organization_id = mtl_system_items_b.organization_id
                                                           AND disable_date    IS NULL ) ))
                    )
          LOOP

             gera_log_tabela(v_sequencia_processamento
                            ,'Processamento do item alterado ' || r2.inventory_item_id || ' org ' || r2.organization_id
                            ,SYSDATE
                            ,'P'
                            ,v_nome_concorrente
                            ,v_debug);


            ----------------------------------------------------------------------------------

            r_mtl_system_items_interface := NULL;
            
            
            ---> Verifica se não tem que alterar o status do item

            IF nvl(r1.inativa_item,'N') = 'S'   THEN

                 vinventory_item_status_code := 'Inactive';

                 ---> somente para a empresa 3 tem que fazer essa condiçáo quando desativar o item

                 IF vempresa_integracao = 'KLASS_EMPRESA_3' THEN
                     vpurchasing_enabled_flag    := 'N';
                     vpurchasing_item_flag       := 'N';
                 END IF;

            ELSE
                 vinventory_item_status_code := NULL;
                 vpurchasing_enabled_flag    := NULL;
                 vpurchasing_item_flag       := NULL;
            END IF;


             ---> Verifica se não tem que alterar o tipo do item

			IF vempresa_integracao = 'KLASS_EMPRESA_1' THEN
				vitem_type := NULL;
			ELSE
				 IF r1.item_type IS NULL THEN
					 vitem_type := r2.item_type;   --- item_type do item
				 ELSE
					 vitem_type := r1.item_type;   --- item_type da interface klassmatt
				 END IF;			
			END IF;


             SELECT decode(vempresa_integracao,'KLASS_EMPRESA_2',r1.ncm_classificacao_fiscal,NULL)
               INTO vglobal_attribute1
               FROM dual;
               
             
             ---> Monta os campos para alteração do item usando os campos da tabela de integração
             ---> Na alteração de itens a unidade não é permitida
             
             r_mtl_system_items_interface.set_process_id              := 70;
             r_mtl_system_items_interface.process_flag                := 1;
             r_mtl_system_items_interface.transaction_type            := 'UPDATE';
             r_mtl_system_items_interface.item_number                 := r2.segment1;
             r_mtl_system_items_interface.organization_id             := r2.organization_id;
             r_mtl_system_items_interface.DESCRIPTION                 := substr(r1.descricao_media,1,240);
             r_mtl_system_items_interface.global_attribute1           := vglobal_attribute1;
             r_mtl_system_items_interface.global_attribute2           := r1.classe_cond_transacao;
             r_mtl_system_items_interface.global_attribute3           := r1.origem;
             r_mtl_system_items_interface.long_description            := r1.descricao_completa;
             r_mtl_system_items_interface.last_update_date            := SYSDATE;
             r_mtl_system_items_interface.last_updated_by             := fnd_profile.value('user_id');
             r_mtl_system_items_interface.creation_date               := SYSDATE;
             r_mtl_system_items_interface.created_by                  := fnd_profile.value('user_id');
             r_mtl_system_items_interface.last_update_login           := fnd_profile.value('user_id');
             r_mtl_system_items_interface.inventory_item_status_code  := vinventory_item_status_code;
             r_mtl_system_items_interface.item_type                   := vitem_type;
             r_mtl_system_items_interface.purchasing_enabled_flag     := vpurchasing_enabled_flag;
             r_mtl_system_items_interface.purchasing_item_flag        := vpurchasing_item_flag;

             r_mtl_system_items_interface.stock_enabled_flag            := r2.stock_enabled_flag;
             r_mtl_system_items_interface.mtl_transactions_enabled_flag := r2.mtl_transactions_enabled_flag;

                 
             IF r1.flag_compravel IS NOT NULL THEN
                
                ---> alterado 27/02/2014
                
                IF(r1.flag_compravel='Y') THEN
                    r_mtl_system_items_interface.purchasing_enabled_flag := 'Y';
                    r_mtl_system_items_interface.purchasing_item_flag := 'Y';
                END IF;            
                   
             END IF;
             
             --->  Verifica se tem attributes e globals a serem trocados
            
             msg_retorno := attribute_items_interface
                                     (  p_rowid_tab_integ             => v_rowid
                                       ,p_organization_id             => r2.organization_id
                                       ,p_mtl_system_items_interface  => r_mtl_system_items_interface );
              
             IF msg_retorno <> 'OK' THEN
                 RAISE erro;
             END IF;
                          
             ----------------------------------------------------------------------------------
             
             customiza_por_cliente( r_mtl_system_items_interface, r2.organization_id, r1.item_gabarito);
             
             BEGIN

                   INSERT INTO mtl_system_items_interface
                                     VALUES  r_mtl_system_items_interface ;
                        
                  IF  vgrava_log_open_interface = 'S'  THEN
            insert into  klassmatt.dbg_mtl_system_items_interface
              values r_mtl_system_items_interface ;
                 END IF;
                    
                  EXCEPTION
                    WHEN OTHERS THEN
                       msg_retorno := 'Erro ao incluir na tabela mtl_system_items_interface - '
                                      || 'item klassmat ' || r1.id_item_klassmatt ||
                                      ' - erro ' || SQLERRM;
                       RAISE erro;

             END;

             ---> A categoria que pode ser alterada é a que vem na tabela de integração.
             ---- Verifica se o item possui esse conjunto de  categoria e se possuir
             ---  verifica se a category_id que está na integração é diferente do já cadastrado.
             ---  Se for monta a interface.

             IF nvl(r1.inativa_item,'N') <> 'S' THEN

                    FOR R3 IN (
                               SELECT c.structure_id
                                     ,c.category_set_name
                                     ,c.category_set_id
                                 FROM klass_configuracao   k
                                     ,mtl_category_sets    c
                                WHERE upper(k.attribute1)   = upper(c.category_set_name)
                                  AND k.tipo                = 'SETA_CATEGORIA'
                                  AND ( r2.organization_id IN (SELECT to_number(attribute1)
                                                                      FROM klass_configuracao
                                                                      WHERE tipo = 'ID_ORGANIZACAO_MESTRE' ) OR
                                         ( r2.organization_id NOT IN (SELECT to_number(attribute1)
                                                                        FROM klass_configuracao
                                                                       WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
                                                AND control_level <> 1 ) )
                             )

                   LOOP

                          v_category_id := NULL;


                          msg_retorno := valida_categoria (upper(r3.category_set_name)
                                                          ,r3.structure_id
                                                          ,v_rowid
                                                          ,v_category_id );

                          IF msg_retorno <> 'OK' THEN
                                 
                                ---> exclui o item criado na interface

                                DELETE FROM mtl_system_items_interface
                                  WHERE item_number     = r2.segment1
                                    AND organization_id = r2.organization_id;
                                    
                                    
                                DELETE FROM mtl_item_categories_interface
                                 WHERE item_number     = r2.segment1
                                   AND organization_id = r2.organization_id;   
                                   
                                   
                                DELETE FROM mtl_item_revisions_interface
                                 WHERE item_number     = r2.segment1
                                   AND organization_id = r2.organization_id;

                                RAISE erro;

                          END IF;


                         ---> inclui a categoria

                         IF v_category_id IS NOT NULL THEN

                               gera_log_tabela(v_sequencia_processamento
                                            ,'Categoria do item ' || r2.inventory_item_id || ' org ' || r2.organization_id ||
                                              ' categ ' || v_category_id|| ' category_set_id ' ||
                                              r3.category_set_id
                                            ,SYSDATE
                                            ,'P'
                                            ,v_nome_concorrente
                                            ,v_debug);

                               ---> Verifica se o category_set_id existe para o item na organização e se
                               ---> o category_id é o mesmo

                               SELECT COUNT(*)
                                 INTO contador
                                 FROM mtl_item_categories
                                WHERE organization_id   = r2.organization_id
                                  AND inventory_item_id = r2.inventory_item_id
                                  AND category_set_id   = r3.category_set_id;


                               IF contador > 0 THEN

                                   SELECT category_id
                                     INTO vold_category_id
                                     FROM mtl_item_categories
                                    WHERE organization_id   = r2.organization_id
                                      AND inventory_item_id = r2.inventory_item_id
                                      AND category_set_id   = r3.category_set_id;

                                   vtransaction_type := 'UPDATE';

                               ELSE

                                   vold_category_id  := v_category_id;
                                   vtransaction_type := 'CREATE';

                               END IF;


                               IF ( vtransaction_type = 'CREATE' ) OR
                                  ( vtransaction_type = 'UPDATE' AND
                                    vold_category_id <> v_category_id ) THEN

                                   BEGIN

                                     insert into mtl_item_categories_interface
                                                 ( set_process_id
                                                  ,process_flag
                                                  ,transaction_type
                                                  ,item_number
                                                  ,organization_id
                                                  ,category_set_id
                                                  ,category_id
                                                  ,old_category_id
                                                  ,last_update_date
                                                  ,last_updated_by
                                                  ,creation_date
                                                  ,created_by
                                                  ,last_update_login )
                                           values
                                                 ( 70
                                                  ,1
                                                  ,vtransaction_type
                                                  ,r2.segment1
                                                  ,r2.organization_id
                                                  ,r3.category_set_id
                                                  ,v_category_id
                                                  ,vold_category_id
                                                  ,SYSDATE
                                                  ,fnd_profile.value('user_id')
                                                  ,SYSDATE
                                                  ,fnd_profile.value('user_id')
                                                  ,fnd_profile.value('user_id') );

                                     EXCEPTION
                                       WHEN OTHERS THEN
                                            msg_retorno := 'Erro oracle ao incluir a category_id :'     ||
                                                                 ' structure_id = ' || r3.structure_id         ||
                                                                 ' categ_segment2 = '        || r1.categ_segment2               ||
                                                                 ' categ_segment3 = '     || r1.categ_segment3            ||
                                                                 ' categ_segment1 = '      || r1.categ_segment1             ||
                                                                 ' principio ativo = ' || r1.categ_segment4;
                                            RAISE erro;

                                     END;

                              END IF; -- create ou update

                           END IF;  -- v_category_id is not null


                    END LOOP;  --- r3

              END IF;  -- inativa item

              ----------------------- grava a tabela de controle --------------------------

              gera_log_tabela(v_sequencia_processamento
                             ,'Gravando a tabela de controle do item origem ' || r2.inventory_item_id || ' org ' || r2.organization_id
                             ,SYSDATE
                             ,'P'
                             ,v_nome_concorrente
                             ,v_debug);

              v_linha := v_linha + 1;

              ---> verifica se o cara está na tabela de controle

              SELECT COUNT(*)
                INTO contador
                FROM klass_integracao_controle
               WHERE id_item_klassmatt = r1.id_item_klassmatt
                 AND organization_id   = r2.organization_id
                 AND status_execucao   = 'P';

              IF contador = 0 THEN

                    BEGIN

                          INSERT INTO klass_integracao_controle
                                           ( id_processamento
                                            ,request_id
                                            ,status_execucao
                                            ,id_item_klassmatt
                                            ,id_item_alterado
                                            ,codigo_item
                                            ,organization_id
                                            ,tipo_operacao
                                            ,rowid_tabela_integracao
                                            ,dt_criacao
                                            ,dt_atualizacao )
                                   VALUES
                                           ( v_sequencia_processamento
                                            ,NULL
                                            ,'S'      --- stand by esperando execução
                                            ,r1.id_item_klassmatt
                                            ,r2.inventory_item_id
                                            ,r2.segment1
                                            ,r2.organization_id
                                            ,'UPDATE'
                                            ,v_rowid
                                            ,SYSDATE
                                            ,SYSDATE );
                           EXCEPTION

                               WHEN OTHERS THEN
                                   msg_retorno := 'Erro ao incluir a tabela klass_integracao_controle - '
                                                  || SQLERRM || ' id_item_klassmatt ' ||
                                                  r1.id_item_klassmatt;
                                   RAISE erro;

                    END;
              ELSE

                   UPDATE klass_integracao_controle
                           SET id_processamento = v_sequencia_processamento
                              ,status_execucao  = 'S'
                    WHERE id_item_klassmatt = r1.id_item_klassmatt
                      AND organization_id   = r2.organization_id
                      AND status_execucao   = 'P';
              END IF;
              -----------------------------------------------------------------------------


          END LOOP;   -- r2


       END LOOP;  -- r1

       RETURN('OK');

       EXCEPTION
          WHEN erro THEN

            gera_log_tabela(v_sequencia_processamento
                           ,msg_retorno
                           ,SYSDATE
                           ,'P'
                           ,v_nome_concorrente
                           ,v_debug);
            RETURN(msg_retorno);

          WHEN OTHERS THEN

            gera_log_tabela(v_sequencia_processamento
                           ,'Erro Oracle: '||sqlerrm
                           ,SYSDATE
                           ,'P'
                           ,v_nome_concorrente
                           ,v_debug);
            dbms_output.put_line('Processamento terminou com ERRO. Verifique LOG !');
            raise_application_error(-20012,'Erro Oracle: '||sqlerrm);


  END alteracao_item_interface;

  ----------------- FINAL DO CONCORRENTE INTEGRAÇÃO KLASSMATT - EBS --------------------

  /****************************************************************************
   Procedure de limpreza das tabelas - ela roda a partir de outro concorrente
  *****************************************************************************/

  PROCEDURE exclui_tab_int_klassmatt (p_set_process_id IN NUMBER) is

    msg_retorno                 VARCHAR2(3000);

    BEGIN

      ---> Tabela de log de integração

      BEGIN

         DELETE FROM klass_integracao_log;

         EXCEPTION
            WHEN OTHERS THEN
                msg_retorno := 'Erro ao excluir registros - tabela klass_integracao_log - ' ||
                               SQLERRM;
                RAISE erro;

      END;


     ---> Tabela de controle de integração

      BEGIN

         DELETE FROM klass_integracao_controle;

         EXCEPTION
            WHEN OTHERS THEN
                msg_retorno := 'Erro ao excluir registros - tabela klass_integracao_controle - ' ||
                               SQLERRM;
                RAISE erro;

      END;

      -------------> Tabelas de interface do EBS <-------------

      BEGIN

         DELETE FROM mtl_item_revisions_interface
            WHERE set_process_id = p_set_process_id;
        
         EXCEPTION
            WHEN OTHERS THEN
                msg_retorno := 'Erro ao excluir registros - tabela mtl_item_revisions_interface - ' ||
                               SQLERRM;
                RAISE erro;

      END;


      BEGIN

         DELETE FROM mtl_item_categories_interface
            WHERE set_process_id = p_set_process_id;

         EXCEPTION
            WHEN OTHERS THEN
                msg_retorno := 'Erro ao excluir registros - tabela mtl_item_categories_interface - ' ||
                               SQLERRM;
                RAISE erro;

      END;

      -----

      BEGIN

         DELETE FROM mtl_system_items_interface
            WHERE set_process_id = p_set_process_id;

         EXCEPTION
            WHEN OTHERS THEN
                msg_retorno := 'Erro ao excluir registros - tabela mtl_system_items_interface - ' ||
                               SQLERRM;
                RAISE erro;

      END;

      COMMIT;


      ---> exception da procedure  ---> todos os erros tratados convergem para essa
      ---  procedure. No exception será startado o email para a profile definida.

      EXCEPTION
          WHEN erro THEN
            dbms_output.put_line('Processamento terminou com ERRO. Verifique LOG !');
            raise_application_error(-20001,msg_retorno);

          WHEN OTHERS THEN
            dbms_output.put_line('Processamento terminou com ERRO. Verifique LOG !');
            raise_application_error(-20002,'Erro Oracle: '||sqlerrm);

    END  exclui_tab_int_klassmatt;

    ----------------- FINAL DO CONCORRENTE DE LIMPEZA DAS TABELAS --------------------

  /****************************************************************************
   Função que retorna se o item ebs está ativo ou não para a organização mestre
   Usada externamente pelo klassmatt
  *****************************************************************************/

  FUNCTION status_item_mestre(p_segment1 IN  VARCHAR2
                             ,p_msg_erro OUT VARCHAR2) RETURN VARCHAR2 IS

    mensagem       VARCHAR2(1000);
    contador       NUMBER;
    status_item    VARCHAR2(10);

  BEGIN

     mensagem := NULL;

     ---> Verifica se o item veio preenchido

     IF p_segment1 IS NULL THEN
          mensagem := 'Parâmetro codigo do item está nulo.';
          RAISE erro;
     END IF;

     ---> Verifica se o item existe na mestre

     SELECT COUNT(*)
       INTO contador
       FROM mtl_system_items_b
      WHERE organization_id IN (SELECT to_number(attribute1)
                                  FROM klass_configuracao
                                 WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
        AND segment1        = p_segment1;

     IF contador = 0 THEN
         mensagem := 'Parâmetro codigo do item não existe no EBS.';
         RAISE erro;
     END IF;

     ---> verifica se o status do item está ativo ou não

     SELECT decode(inventory_item_status_code,'Active','A','I')
       INTO status_item
       FROM mtl_system_items_b
      WHERE organization_id IN (SELECT to_number(attribute1)
                                  FROM klass_configuracao
                                 WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
        AND segment1        = p_segment1;

    RETURN status_item;


    EXCEPTION
          WHEN erro THEN
             p_msg_erro := mensagem;
             RETURN 'E';

          WHEN OTHERS THEN
             p_msg_erro := 'Erro Oracle: '||SQLERRM;
             RETURN 'E';

  END ;

-------------------------------------------------------------------------
/****************************************************************************
   Função que retorna as OIs pertencentes a um item
*****************************************************************************/

FUNCTION retorna_oi_item_ebs ( p_segment1    IN VARCHAR2
                              ,p_lista_oi   OUT VARCHAR2
                              ) RETURN VARCHAR2 IS

BEGIN

    p_lista_oi := NULL;

    FOR r1 IN ( SELECT msi.organization_id
                  FROM mtl_system_items_b   msi
                 WHERE msi.segment1 = p_segment1 -----
                   AND msi.organization_id IN ( SELECT organization_id
                                                  FROM org_organization_definitions
                                                 WHERE organization_id = msi.organization_id
                                                   AND disable_date    IS NULL
                                              )
                 ORDER BY msi.organization_id
               )
    LOOP

        p_lista_oi := p_lista_oi || r1.organization_id || ';';

    END LOOP;

    --------------
    RETURN('OK');
    --------------

    EXCEPTION

          WHEN OTHERS THEN

             RETURN 'Erro oracle na funcao RETORNA_OI_ITEM_EBS - ' || SQLERRM;

END retorna_oi_item_ebs;

-------------------------------------------------------------------------
/****************************************************************************
   Função que retorna o nome e o código de uma OI
*****************************************************************************/

FUNCTION retorna_dados_oi ( p_organization_id    IN NUMBER
                           ,p_organization_name OUT VARCHAR2
                           ,p_organization_code OUT VARCHAR2
                           ) RETURN VARCHAR2 IS

BEGIN

    SELECT organization_name
          ,organization_code
      INTO p_organization_name
          ,p_organization_code
      FROM org_organization_definitions
     WHERE organization_id = p_organization_id; --

    --------------
    RETURN('OK');
    --------------

    EXCEPTION

          WHEN OTHERS THEN

             RETURN 'Erro oracle na funcao RETORNA_DADOS_OI - ' || SQLERRM;

END retorna_dados_oi;

-----------------------------------------------------------------------------
/****************************************************************************
   Função que retorna as linguagens ativas no EBS
*****************************************************************************/

FUNCTION retorna_linguagens_ebs ( p_linguagem_desc   OUT VARCHAR2
                                 ,p_linguagem_code   OUT VARCHAR2
                                 ,p_linguagem_type   OUT VARCHAR2
                                 ) RETURN VARCHAR2 IS

BEGIN

    FOR r1 IN (
                SELECT language_code
                      ,decode(installed_flag,'I','PADRAO','SECUNDARIA')  language_type
                      ,description
                  FROM fnd_languages_vl
                 WHERE installed_flag <> 'D'
              )
    LOOP

        p_linguagem_desc := p_linguagem_desc || r1.description   || ';' ;
        p_linguagem_code := p_linguagem_code || r1.language_code || ';' ;
        p_linguagem_type := p_linguagem_type || r1.language_type || ';' ;

    END LOOP;

    --------------
    RETURN('OK');
    --------------

    EXCEPTION

          WHEN OTHERS THEN

             RETURN 'Erro oracle na funcao RETORNA_LINGUAGENS_EBS - ' || SQLERRM;

END retorna_linguagens_ebs;

-----------------------------------------------------------------------------
/****************************************************************************
   Função que retorna as UOs ativas no EBS
*****************************************************************************/

FUNCTION retorna_uo_ebs ( p_id_uo    OUT VARCHAR2
                        ) RETURN VARCHAR2 IS

BEGIN

    FOR r1 IN (
                SELECT organization_id
                  FROM hr_operating_units
                 WHERE date_to IS NULL
                 ORDER BY organization_id
              )
    LOOP

        p_id_uo   := p_id_uo   || r1.organization_id   || ';' ;


    END LOOP;

    --------------
    RETURN('OK');
    --------------

    EXCEPTION

          WHEN OTHERS THEN

             RETURN 'Erro oracle na funcao RETORNA_UO_EBS - ' || SQLERRM;

END retorna_uo_ebs;

-----------------------------------------------------------------------------
/****************************************************************************
   Função que retorna o nome de uma UO do EBS e suas OIs.
*****************************************************************************/

FUNCTION retorna_dados_uo_ebs ( p_id_uo       IN  NUMBER
                               ,p_nome_uo     OUT VARCHAR2
                               ,p_relacao_oi  OUT VARCHAR2
                              ) RETURN VARCHAR2 IS

BEGIN

    FOR r1 IN (
                SELECT NAME
                  FROM hr_operating_units
                 WHERE organization_id = p_id_uo   ---
                   AND date_to IS NULL
              )
    LOOP

        p_nome_uo   := r1.NAME;

        ---> Lista das OIs ativas da UO menos a mestre

        FOR r2 IN (
                    SELECT organization_id
                      FROM org_organization_definitions
                     WHERE operating_unit = p_id_uo --
                       AND disable_date   IS NULL
                       AND organization_id NOT IN (SELECT to_number(attribute1)
                                                     FROM klass_configuracao
                                                    WHERE tipo = 'ID_ORGANIZACAO_MESTRE' )
                     ORDER BY organization_id
                   )
        LOOP

           p_relacao_oi   := p_relacao_oi   || r2.organization_id   || ';' ;

        END LOOP;


    END LOOP;

    --------------
    RETURN('OK');
    --------------

    EXCEPTION

          WHEN OTHERS THEN

             RETURN 'Erro oracle na funcao RETORNA_DADOS_UO_EBS - ' || SQLERRM;

END retorna_dados_uo_ebs;

-------------------------------------------------------------------------

end klass_integracao;
/
