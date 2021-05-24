set serveroutput on size 900000 
set linesize 200
declare 
   cursor itens is
      select 'ACUCAR CRISTAL SACHE' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'ADOCANTE LIQUIDO SUCRALOSE' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'ADOCANTE PO SUCRALOSE SACHE' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'ALCOOL GEL 65 INPM' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'ALCOOL LIQUIDO 70 INPM ITAJA FR 1L' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'ALMOFADA PARA CARIMBO PRETA' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'ALMOFADA PARA CARIMBO AZUL' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'APAGADOR PARA QUADRO BRANCO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'APOIO PARA PES AJUSTAVEL MULTIVISAO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'APOIO PARA PULSO MULTILASER EM GEL' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'BARRA MORANGO COM CHOCOLATE' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'BARRA NUTS ORIGINAL' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'BATERIA ALCALINA 9 V' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'BISCOITO AMANTEIGADO BANANA CANELA' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'BISCOITO AMANTEIGADO CHOCOLATE' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'BISCOITO AMANTEIGADO LEITE' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'BISCOITO BAUDUCCO COOKIES GOTAS DE CHOCOLATE' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'BLOCO ADESIVO POST-IT CUBO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'BLOCO ADESIVO POST-IT 3M 38X50MM AMARELO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'BLOCO ADESIVO POST-IT 3M 76X76MM AMARELO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'BLOCO FLIP CHART  56G 64X84CM' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'BORRACHA CAPA PLASTICA' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'CADERNO ESPIRAL CAPA DURA 1/4 D+ 96 FOLHAS' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'CADERNO PEQUENO ESPIRAL CAPA FLEXIVEL 1/4 96FLS' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'CADERNO UNIVERSITARIO CAPA FLEXIVEL 1 MAT. 96FLS' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'CADERNO UNIVERSITARIO ESPIRAL CAPA DURA 1MT 96F ' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'CAFE EM PO  PCT 500G' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'CAIXA CORRESPONDENCIA ARTICULAVEL TRIPLA CRISTAL UNID' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'CALCULADORA BRW 12 DIGITOS' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'CANETA ESFEROGRAFICACRISTAL AZUL' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'CANETA ESFEROGRAFICA CRISTAL PRETA' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'CANETA ESFEROGRAFICA CRISTAL VERMELHA' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'CANETA MARCA TEXTO AMARELA ' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'CANETA MARCA TEXTOLARANJA' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'CANETA MARCA TEXTO ROSA ' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'CANETA MARCA TEXTO VERDE ' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'CANETA PARA RETROPROJETOR PILOT PRETO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'CHA  BOLDO ' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'CHA  CAMOMILA' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'CHA  CIDREIRA' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'CHA  CIDRERA LARANJA E LIMAO ' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'CHA  ERVA DOCE' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'CHA  HORTELA' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'CHA  MACA COM CANELA' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'CHA  MATTE COM LIMAO ' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'CHA  MATTE NATURAL ' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'CHA  MORANGO ' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'CHA  PRETO' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'CHA  VERDE' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'CLIPS N 1 GALVANIZADO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'CLIPS GALVANIZADO 3/0 FIO 1,10MM' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'CLIPS GALVANIZADO 8/0 FIO 1,60MM ' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'COLA EM BASTAO BRANCA' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'COPO PS 180ML BRANCO NORMATIZADO ABNT' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'COPO PS 80ML BRANCO NORMATIZADO ABNT ' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'CORRETIVO LIQUIDO 18ML' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'DESODORIZADOR BOM AR AEROSSOL LAVANDA' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'DETERGENTE LAVA LOUCAS NEUTRO 5L' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'DISPENSER DE COPOS ACRILICO 180/200ML ' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'DISPENSER SABONETE LIQUIDO C/ RESERV SOFTPAPER TRANSP UN' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'ELASTICO DE BORRACHA N18  ' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'ENVELOPE KN 176X250 80G' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'ENVELOPE OFFSET 176X250 90G ' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'ENVELOPE OFFSET BRANCO LISO SEM RPC OFICIO 114X229' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'ENVELOPE OFFSET BRANCO OFICIO 240X340 ' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'ENVELOPE SEMI KRAFT NATURAL OFICIO 240X340 ' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'ESPONJA WAVE SCOTCH BRITE' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'ESTILETE PLASTICO C/ LAMINA LARGA 18MM' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'ETIQUETA COLACRIL CC182 ( 6182 ) C/100 FLS' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'ETIQUETA  CARTA 279,4X215,9MM' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'ETIQUETA CARTA 25,4X66,7MM' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'ETIQUETA CARTA 25,4X101,6MM' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'ETIQUETA CARTA 12,7X44,4MM' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'ETIQUETA A4 38,1X63,5MM' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'EXTRATOR DE GRAMPO ESPATULA' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'FITA ADESIVA 12 X 50' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'FITA ADESIVA 12MM X 30M' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'FITA ADESIVA TRANSPARENTE 45MM X 45M' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'FITA ADESIVA TRANSPARENTE 18 MM X 50 M' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'FITA DUPLA FACE  FIXA FORTE TRANSPARENTE 19MMX2M' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'FITA PARA ROTULADOR BROTHER PT85/65 12MM M231 BR/PT' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'FLANELA BRANCA 28X38CM' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'FLANELA EVERCLEAN BRANCA 50X50CM' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'FLIP CHART BRANCO EM MADEIRA 90X54CM' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'GARRAFA TERMICA TERMOLAR INOX 1,8L' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'GARRAFA TERMICA INOX 1L ' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'GRAMPEADOR 20FLS' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'GRAMPO PARA GRAMPEADOR GALVANIZADO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'GUARDANAPO FOLHA SIMPLES 20X23CM' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'LACRE P/MALOTE EM PP AZ 16CM' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'LAPIS GRAFITE REDONDO PRETO ' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'LIVRO PROTOCOLO CORRESPONDENCIA 1/4 100 FOLHAS' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'LUSTRA MOVEIS LAVANDA 200ML' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'MARCADOR DE PAGINA' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'MARCADOR DE QUADRO BRANCO PRETO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'MARCADOR DE QUADRO BRANCO VERDE' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'MARCADOR DE QUADRO BRANCO VERMELHO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'MARCADOR DE QUADRO BRANCO AZUL' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'MARCADOR PERMANENTE AZUL ' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'MARCADOR PERMANENTE PRETO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'MARCADOR PERMANENTE VERMELHO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'MEXEDOR DE CAFE 11CM' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'MEXEDOR DE CAFE 8,5CM ' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'MOUSE PAD COM APOIO GEL PEQUENO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'PANO DE LIMPEZA BRANCO ' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'PANO DESCARTAVEL AZUL' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'PAPEL A4 BRANCO ' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'PAPEL PARDO 120CM LARGURA BOBINA C/12 KG' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'PAPEL SULFITE A3 75G' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'PASTA CATALOGO ACP COM VISOR 0,12 MC 250X340 ' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'PASTA EM L A4 CRISTAL ' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'PASTA SUSPENSA AZUL, PLASTIFICADA' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'PILHA ALCALINA AA' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'PILHA ALCALINA AAA' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'PINCEL ATOMICO DUPLO AZUL ' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'PINCEL ATOMICO DUPLO PRETO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'PINCEL MARCADOR PERMANENTE RECARREGAVEL AZUL' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'PINCEL MARCADOR PERMANENTE RECARREGAVEL PRETO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'PINCEL MARCADOR PERMANENTE RECARREGAVEL VERDE' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'PINCEL MARCADOR PERMANENTE RECARREGAVEL VERMELHO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'PLASTICO BOLHA BOBINA COM 1,30 X 80M' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'PRENDEDOR DE PAPEL 15MM PRETO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'PRENDEDOR DE PAPEL 19MM PRETO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'PRENDEDOR DE PAPEL 32MM PRETO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'PRENDEDOR DE PAPEL 51MM PRETO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'REGUA  3MM 30CM' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'SACO PARA LIXO UP BAG ALTA RESIST ABNT CINZA 110L PCT 50UN' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'SACO PARA LIXO UP BAG ALTA RESIST ABNT PRETO 110L PCT 50UN' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'SACO PARA LIXO UP BAG BASIC AZUL 50L PCT 50UN' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'SACO PARA LIXO UP BAG BASIC PRETO 30L PCT 50UN' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'SACO PARA LIXO UP BAG BASIC PRETO 50L PCT 50UN' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'SACO PARA LIXO UP BAG BASIC TRANSPARENTE 30L PCT 50UN' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'SACO PARA LIXO UP BAG BASIC TRANSPARENTE 50L PCT 50UN' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'SACO PARA LIXO UP BAG FORTE AMARELO 110L PCT 50UN' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'SACO PARA LIXO UP BAG FORTE AZUL 110L PCT 50UN' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'SACO PARA LIXO UP BAG FORTE PRETO 110L PCT 50UN' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'SACO PARA LIXO UP BAG FORTE TRANSPARENTE 110L PCT 50UN' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'SACO PARA LIXO UP BAG FORTE VERDE 110L PCT 50UN' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'SACO PARA LIXO UP BAG FORTE VERMELHO  110L PCT 50UN' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'SACO PLAST OFICIO 4 FUROS 0,12MM 240X325MM' desc_item, 'COPA E COZINHA' categoria from dual union
        select 'SUPORTE PARA MONITOR MULTILASER' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'SUPORTE PARA NOTEBOOK PRETO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'TELA DE PRIVACIDADE' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'TESOURA MULTIUSO 21 CM' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'TINTA AZUL PARA MARCADOR DE QUADRO BRANCO ' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'TINTA PARA PINCEL ATOMICO  40ML VERMELHA' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'TINTA PARA PINCEL ATOMICO 40ML PRETO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'TINTA PARA PINCEL ATOMICO VERDE' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'TINTA PARA PINCEL ATOMICO AZUL' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'TINTA PRETA PARA MARCADOR DE QUADRO BRANCO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual union
        select 'TINTA VERMELHA PARA MARCADOR DE QUADRO BRANCO' desc_item, 'MATERIAL DE ESCRITORIO' categoria from dual
        ; 
--
   cursor org is 
      select organization_id, organization_code, organization_name
        from apps.org_organization_definitions
        where 1 = 1
          and operating_unit = 322
          and disable_date is null
      ;

l_segment1 number;
l_category_id number;     
l_inventory_item_id number;
x_error_code varchar2(100);
x_msg_data varchar2(100);
---=======
    l_nRequest_Id NUMBER;
    --l_tResp_name varchar2(100):= 'STONE LOG INV Super User';
    l_tResp_name varchar2(100):= 'GLOBAL INV Super User'; --QA
    l_tUser_Name varchar2(100):= 'CRISTIANO.BERG_9CON';
    l_tAppl_Short_name varchar2(100):= '';
    l_tConc_name       varchar2(100):= 'FNDWFBG';
    l_nResp_id         NUMBER;
    l_nAppl_id         NUMBER;
    l_nUser_Id         NUMBER;
    l_vPhase           VARCHAR2(4000);
    l_vStatus          VARCHAR2(4000);
    l_vDev_Phase       VARCHAR2(4000);
    l_vDev_Status      VARCHAR2(4000);
    l_vMessage         VARCHAR2(4000);
    l_bReturn         BOOLEAN;   
    l_nInterval       NUMBER := 15;
    l_nMax_Wait       NUMBER := 7200;
------------------------------------------------------
   -- Variaiveis da API - Atualizacao Item
   ------------------------------------------------------
   l_Api_Version    Number;
   l_Init_Msg_List  Varchar2(2);
   l_Commit         Varchar2(2);
   l_Item_Tbl       Ego_Item_Pub.Item_Tbl_Type;
   l_Role_Grant_Tbl Ego_Item_Pub.Role_Grant_Tbl_Type;
   x_Item_Tbl       Ego_Item_Pub.Item_Tbl_Type;
   x_Message_List   Error_Handler.Error_Tbl_Type;
   x_Return_Status  Varchar2(2);
   x_Msg_Count      Number;
   k_Item           Number;
   l_Account_Id	  Number;
------------------------------------
   -- Variaiveis adicionais
   ------------------------------------
   l_Item_Id        Number;
   l_Org_Id         Number;
   i number := 0;
   
Begin
   -----------------------------------------------
   -- Inicializando variaveis
   -----------------------------------------------
   l_Api_Version    := 1.0;
   l_Init_Msg_List  := Fnd_Api.g_True;
   l_Commit         := Fnd_Api.g_True;
   l_Role_Grant_Tbl := Ego_Item_Pub.g_Miss_Role_Grant_Tbl;
   x_Msg_Count      := 0;     
   ---========================
   Select vl.responsibility_Id, v.application_id
      into l_nResp_id, l_nAppl_id
      from FND_RESPONSIBILITY_TL vl, FND_RESPONSIBILITY v
     where vl.responsibility_Id = v.responsibility_Id
       and vl.responsibility_name like '%'|| l_tResp_name || '%'
       and rownum = 1
    ;
    --
    select user_id into l_nUser_Id
      from fnd_user where user_name = l_tUser_Name
    ;
      --
    SELECT fa.application_short_name
      into l_tAppl_Short_name
      from FND_CONCURRENT_PROGRAMS_VL c, fnd_application fa
     Where c.concurrent_program_name = l_tConc_name
       and c.application_id = fa.application_id
    ;
    --
      apps.fnd_global.apps_initialize( 
           user_id      => l_nUser_Id
          ,resp_id      => l_nResp_id
          ,resp_appl_id => l_nAppl_id 
      );
    --
    MO_GLOBAL.INIT('INV');
   --
   --Recuperar ultimo item criado.
   select max(to_number(a.segment1))
   into l_segment1
    from apps.mtl_system_items          a
        ,apps.mtl_parameters            b
        ,apps.hr_all_organization_units c
        ,apps.gl_code_combinations      d
        ,apps.per_all_people_f          e
        ,apps.mtl_categories_b          f
        ,apps.mtl_categories_b_kfv      g
        ,apps.mtl_item_categories       h
        
    where 1=1
    and   a.organization_id      = b.organization_id
    and   a.organization_id      = c.organization_id
    and a.creation_date > sysdate  -100
    and   a.expense_account      = d.code_combination_id (+)
    and   a.buyer_id (+)         = e.person_id
    and   h.inventory_item_id    = a.inventory_item_id
    and   h.organization_id      = a.organization_id
    and   h.category_id          = f.category_id
    and   g.structure_id         = f.structure_id
    and   g.category_id          = f.category_id
    and   a.purchasing_item_flag       = 'Y'
    and   substr(a.segment1,1,1) = '2' --Produtos
    --and   substr(a.segment1,1,1) = '1' --Serviços
    and   a.inventory_item_status_code = 'Active'
    and   f.segment1             <> '00000000'
    and   c.organization_id   = 89
    
    ;

   for x in itens loop
      --
      l_segment1 := l_segment1 + 100;
      --
         --
         ---------------------------------------------------------------------------------------
         -- Inicializando os atributos necessarios para chamar a API de atualizacao de itens
         ---------------------------------------------------------------------------------------
         l_Item_Tbl(1).Transaction_Type  := 'CREATE';
         l_Item_Tbl(1).Organization_Id   := 89; 
         l_Item_Tbl(1).item_number       := l_segment1;
         l_Item_Tbl(1).Description       := x.desc_item;
         l_Item_Tbl(1).Long_Description  := x.desc_item;
         l_Item_Tbl(1).PRIMARY_UOM_CODE  := 'UN'; 
         l_Item_Tbl(1).inventory_item_status_code := 'Active';
         l_Item_Tbl(1).global_attribute2 := 'USO E CONSUMO';
         l_Item_Tbl(1).GLOBAL_ATTRIBUTE_CATEGORY := 'JL.BR.INVIDITM.XX.Fiscal' ;
         l_Item_Tbl(1).GLOBAL_ATTRIBUTE8 := 'INV';   
         l_Item_Tbl(1).buyer_id         := 8594; --
         l_Item_Tbl(1).PURCHASING_ITEM_FLAG := 'Y';
         --l_Item_Tbl(1).expense_account := null;
         l_Item_Tbl(1).PURCHASING_ENABLED_FLAG := 'Y';
         l_Item_Tbl(1).Attribute20 := 'SR-534548';
         ----------------------------------------------------------------
         -- Executando a API Ego_Item_Pub.Process_Items
         ----------------------------------------------------------------
         Begin
            Ego_Item_Pub.Process_Items(p_Api_Version    => l_Api_Version
                                      ,p_Init_Msg_List  => l_Init_Msg_List
                                      ,p_Commit         => l_Commit
                                      ,p_Item_Tbl       => l_Item_Tbl
                                      ,p_Role_Grant_Tbl => l_Role_Grant_Tbl
                                      ,x_Item_Tbl       => x_Item_Tbl
                                      ,x_Return_Status  => x_Return_Status
                                      ,x_Msg_Count      => x_Msg_Count);
            --
            If (x_Return_Status <> apps.Fnd_Api.g_Ret_Sts_Success) Then
               --Dbms_Output.Put_Line('Erro API  ==>  ' || x_Return_Status);
               --Dbms_Output.Put_Line('x_Msg_Count  ==>  ' || x_Msg_Count);
               DBMS_OUTPUT.PUT_LINE('Error Messages :');
               Error_Handler.GET_MESSAGE_LIST(x_message_list=>x_message_list);
              FOR j IN 1..x_message_list.COUNT LOOP
               DBMS_OUTPUT.PUT_LINE(x_message_list(j).message_text);
             END LOOP;
            Else
               Null;
            End If;
            --
         Exception
            When Others Then
               DBMS_OUTPUT.PUT_LINE('When Others Then');
         End;  
         ---
         commit;
         --atribui categoria de compras
         --
         begin
            select inventory_item_id
            into l_inventory_item_id
            from apps.mtl_system_items_b
            where organization_id = 89
            and segment1 = l_segment1
            ;
         exception
            when others then
               null;
         end;
         --
         l_category_id := null;
         --
         begin
            SELECT category_id 
            INTO l_category_id 
            FROM apps.mtl_categories_b 
            WHERE segment1 =  x.categoria;
         exception
            when others then
               null;
               --raise_application_error(-20001,'Erro ao pesquisar categoria');
         end;
         --
         Dbms_Output.Put_Line('categoria ==> ' || l_category_id);
         
         EGO_ITEM_PUB.Process_Item_Cat_Assignment
             (
                    l_api_version      
                  , l_init_msg_list    
                  , l_commit           
                  , l_category_id      
                  , 1100000041 --l_category_set_id  
                  , 2123
                  , l_inventory_item_id --itm.inventory_item_id
                  , 89 --itm.organization_id  
                  , 'UPDATE' --l_transaction_type 
                  , x_return_status    
                  , x_error_code        
                  , x_msg_count        
                  , x_msg_data         
             );
         --
         --atribui categoria fiscal
         EGO_ITEM_PUB.Process_Item_Cat_Assignment
             (
                    l_api_version      
                  , l_init_msg_list    
                  , l_commit           
                  , 2218 --l_category_id      
                  , 1100000022 --l_category_set_id  
                  , null
                  , l_inventory_item_id --itm.inventory_item_id
                  , 89 --itm.organization_id  
                  , 'CREATE' --l_transaction_type 
                  , x_return_status    
                  , x_error_code        
                  , x_msg_count        
                  , x_msg_data         
             );
         --atribui itens 
          for y in org loop
             --
             Dbms_Output.Put_Line('Item ==> ' || l_segment1);
             Dbms_Output.Put_Line('org ==> ' || y.organization_code);
             --
             EGO_ITEM_PUB.ASSIGN_ITEM_TO_ORG( 
                                     P_API_VERSION          => l_api_version
                                  ,  P_INIT_MSG_LIST        => l_init_msg_list
                                  ,  P_COMMIT               => l_commit
                                  ,  P_INVENTORY_ITEM_ID    => null --l_item_id   -- Use INVENTORY_ITEM_ID, ORGANIZATION_ID instead of ITEM_NUMBER, ORGANIZATION_CODE
                                  ,  P_ITEM_NUMBER          => l_segment1  
                                  ,  P_ORGANIZATION_ID      => y.organization_id
                                  ,  P_ORGANIZATION_CODE    => NULL 
                                  ,  P_PRIMARY_UOM_CODE     => null
                                  ,  X_RETURN_STATUS        => x_return_status
                                  ,  X_MSG_COUNT            => x_msg_count
                                ); 
             --
          end loop; --org
      --
      
      --
   end loop; --itens
   --
   commit;
      --
end;
