CREATE OR REPLACE PACKAGE XXOD_ATRB_AUTO_REQ_K IS

  -- $Header XXOD_ATRB_AUTO_REQ_K.pks 120.0 2017/12/16 00:00:00 fgoeldi $
  -- +=================================================================+
  -- |               Copyright (c) 2018 Odebrecht                      |
  -- |                   All rights reserved.                          |
  -- +=================================================================+
  -- | FILENAME                                                        |
  -- |   XXOD_ATRB_AUTO_REQ_K.pls                                      |
  -- |                                                                 |
  -- | PURPOSE                                                         |
  -- |                                                                 |
  -- | DESCRIPTION                                                     |
  -- |                                                                 |
  -- | PARAMETERS                                                      |
  -- |                                                                 |
  -- | CREATED BY                                                      |
  -- |    Felipe Goeldi        16/12/2017                              |
  -- | UPDATED BY                                                      |
  -- |                                                                 |
  -- +=================================================================+
  --
  PROCEDURE AUTO_ATRIB_P(r_status  OUT VARCHAR
                    ,r_message OUT VARCHAR);
END;
/
CREATE OR REPLACE PACKAGE BODY XXOD_ATRB_AUTO_REQ_K IS

  -- $Header XXOD_ATRB_AUTO_REQ_K.pkb 120.1 2019/03/01 00:00:00 fgoeldi $
  -- +=================================================================+
  -- |               Copyright (c) 2018 Odebrecht                      |
  -- |                   All rights reserved.                          |
  -- +=================================================================+
  -- | FILENAME                                                        |
  -- |   XXOD_ATRB_AUTO_REQ_K.plb                                      |
  -- |                                                                 |
  -- | PURPOSE                                                         |
  -- |    Atribuir o comprador na linha da requisicao de compra        |
  -- |                                                                 |
  -- | DESCRIPTION                                                     |
  -- |    Processo de atribuicao automatica de comprador a linha da    |
	-- |    requisicao de compra                                         |
  -- |                                                                 |
  -- | PARAMETERS                                                      |
  -- |                                                                 |
  -- | CREATED BY                                                      |
  -- |    Felipe Goeldi        16/12/2017                              |
  -- | UPDATED BY                                                      |
  -- | #01 Eberton Ballista                      01/03/2019            |
  -- |                                                                 |
  -- | #02 Jovian Regis Silva                    22/02/2021            |
  -- |                                                                 |
  -- +=================================================================+
  --
    PROCEDURE AUTO_ATRIB_P(r_status OUT VARCHAR, r_message OUT VARCHAR) IS
      CURSOR C_REQ IS
        SELECT DISTINCT HAOU.NAME ORGANIZACAO,
                        haou.attribute21 SONDA,
                        PRH.SEGMENT1 REQUISICAO,
                        PRL.LINE_NUM REQUISITION_LINE_NUM,
                        PRL.item_description ITEM,
                        PRH.type_lookup_code DOCR,
                        PRH.CREATION_DATE DATA_CRIACAO,
                        PRH.AUTHORIZATION_STATUS STATUS,
                        PRH.approved_date DATA_APROVACAO,
                        PRH.REQUISITION_HEADER_ID,
                        PRL.REQUISITION_LINE_ID,
                        prl.item_id,
                        prl.blanket_po_header_id,
                        (SELECT MC.SEGMENT1
                           FROM MTL_CATEGORIES MC, MTL_ITEM_CATEGORIES MIC
                          WHERE MC.CATEGORY_ID = MIC.CATEGORY_ID
                            AND MIC.CATEGORY_SET_ID = 1
                            AND MIC.ORGANIZATION_ID = prl.DESTINATION_ORGANIZATION_ID
                            AND MIC.INVENTORY_ITEM_ID = prl.item_id) GRUPO,
                        (SELECT MC.SEGMENT2
                           FROM MTL_CATEGORIES MC, MTL_ITEM_CATEGORIES MIC
                          WHERE MC.CATEGORY_ID = MIC.CATEGORY_ID
                            AND MIC.CATEGORY_SET_ID = 1
                            AND MIC.ORGANIZATION_ID = prl.DESTINATION_ORGANIZATION_ID
                            AND MIC.INVENTORY_ITEM_ID = prl.item_id) SUB_GRUPO_1,
                        (SELECT MC.SEGMENT3
                           FROM MTL_CATEGORIES MC, MTL_ITEM_CATEGORIES MIC
                          WHERE MC.CATEGORY_ID = MIC.CATEGORY_ID
                            AND MIC.CATEGORY_SET_ID = 1
                            AND MIC.ORGANIZATION_ID = prl.DESTINATION_ORGANIZATION_ID
                            AND MIC.INVENTORY_ITEM_ID = prl.item_id) SUB_GRUPO_2
                        -- #01 incluido por Eberton
                        , prl.suggested_buyer_id
          FROM APPS.PO_REQUISITION_HEADERS_ALL PRH,
               APPS.PO_REQUISITION_LINES_ALL   PRL,
               APPS.PO_REQ_DISTRIBUTIONS_ALL   PRD,
               APPS.HR_ALL_ORGANIZATION_UNITS  HAOU

         WHERE PRH.REQUISITION_HEADER_ID = PRL.REQUISITION_HEADER_ID
           AND HAOU.ORGANIZATION_ID = PRh.org_id
           AND PRH.TYPE_LOOKUP_CODE = 'PURCHASE'
           AND PRL.SOURCE_TYPE_CODE = 'VENDOR'
           AND PRH.AUTHORIZATION_STATUS = 'APPROVED'
           AND NVL(PRH.CANCEL_FLAG, 'N') = 'N'
           AND NVL(PRL.CANCEL_FLAG, 'N') = 'N'
           AND PRL.REQS_IN_POOL_FLAG = 'Y'
           -- #02 - inicio
           AND haou.attribute1 IN ( SELECT ffv.flex_value
                                      FROM fnd_flex_values     ffv
                                         , fnd_flex_value_sets ffvs
                                     WHERE ffvs.flex_value_set_name = 'XXOD_ATRB_AUTO_REQ_UOS'
                                       AND ffvs.flex_value_set_id   = ffv.flex_value_set_id
                                       AND NVL (ffv.enabled_flag, 'N') = 'Y'
                                       AND SYSDATE BETWEEN NVL (start_date_active, SYSDATE)
                                                       AND NVL (end_date_active, SYSDATE + 1) )
/*           AND PRH.org_id in (2125,
                              2126,
                              2127,
                              2128,
                              7572,
                              7573,
                              12808,
                              14488,
                              7581,
                              7584,
                              7586,
                              7588,
                              7589,
                              8308,
                              12809,
                              7601,
                              7602,
                              9808,
                              9809,
                              9810,
                              12750,
                              16668)
*/
           -- #02 - fim 
           AND PRL.REQUISITION_LINE_ID = PRD.REQUISITION_LINE_ID;

      L_REQ C_REQ%ROWTYPE;

      CURSOR C_RULES (x_sonda          VARCHAR2
			               ,x_grupo          VARCHAR2
										 ,x_subgrupo1      VARCHAR2
										 ,x_subgrupo2      varchar2) IS
             SELECT *
						 FROM   XXOD_REGRAS_PARAMETRIZACAO
						 WHERE  sonda      = x_sonda
             AND    grupo      = x_grupo
             AND    subgrupo_1 = x_subgrupo1
             AND    subgrupo_2 = x_subgrupo2;
      L_RULES C_RULES%ROWTYPE;

      L_SONDA L_REQ.SONDA%TYPE;
      L_GRUPO L_REQ.GRUPO%TYPE;
      L_SUB_GRUPO_1 L_REQ.SUB_GRUPO_1%TYPE;
      L_SUB_GRUPO_2 L_REQ.SUB_GRUPO_2%TYPE;
			--#01
			L_ROUTING_RULE  VARCHAR2(1);

    BEGIN
      OPEN C_REQ;
      LOOP
           FETCH C_REQ INTO L_REQ;
           EXIT WHEN C_REQ%NOTFOUND;

           L_SONDA := L_REQ.SONDA;
           L_GRUPO := L_REQ.GRUPO;
           L_SUB_GRUPO_1 := L_REQ.SUB_GRUPO_1;
           L_SUB_GRUPO_2 := L_REQ.SUB_GRUPO_2;

           OPEN C_RULES (l_req.sonda, l_req.grupo, l_req.sub_grupo_1, l_req.sub_grupo_2);
           LOOP
               FETCH C_RULES INTO L_RULES;
               EXIT WHEN C_RULES%NOTFOUND;
               --validacao vinculo acordo de compra precisa estar nulo
               IF L_REQ.blanket_po_header_id IS NULL THEN
                 --#01 Inicio da Alteração (Eberton)
								 BEGIN
									     SELECT DISTINCT 'Y'
											 INTO   l_routing_rule
                       FROM   apps.wf_routing_rules  wrr
                           ,  apps.fnd_user          fu
                       WHERE  1                  = 1
                       AND    SYSDATE            BETWEEN wrr.begin_date
                                                 AND     wrr.end_date
                       AND    wrr.role           = fu.user_name
                       AND    fu.employee_Id     = l_req.suggested_buyer_id;
								 EXCEPTION
									 WHEN no_data_found THEN
										    l_routing_rule  := 'N';
								 END;
								 --
								 IF ((l_routing_rule = 'Y') OR  (l_routing_rule = 'N' AND l_req.suggested_buyer_id IS NULL ))THEN
								 --#01 Final da Alteração (Eberton)
                    UPDATE PO_REQUISITION_LINES_ALL
										SET    SUGGESTED_BUYER_ID  = L_RULES.ID_COMPRADOR
                    WHERE  REQUISITION_LINE_ID = L_REQ.REQUISITION_LINE_ID;
                    --
                    COMMIT;
                 END IF;
							END IF; --#01

           END LOOP;
           CLOSE C_RULES;

      END LOOP;
      CLOSE C_REQ;
    END AUTO_ATRIB_P;
END;
/
