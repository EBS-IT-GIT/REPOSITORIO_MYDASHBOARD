CREATE OR REPLACE PACKAGE BODY "XXCLK_PO_INTERFACE_PKG" IS
--
-- +===================================================================+
-- |                            TRI-CS                                 |
-- |                  Todos os direitos reservado                      |
-- +===================================================================+
-- |                                                                   |
-- | Nome     : XXCLK_PO_INTERFACE_PKG                                 |
-- |                                                                   |
-- | Descrição: Package responsavel pela Integração entre Oracle EBS   |
-- |               x Comlink                                           |
-- |                                                                   |
-- | Historico:                                                        |
-- | ==========                                                        |
-- | Versão   Data          Autor            Descrição                 |
-- | =======  ============  ==============   ========================= |
-- | 1.0      26-ABR-2018   Guilherme M.     Versão Inicial            |
-- | 2.0      02-MAI-2019   Joao Adami       Melhorias                 |
-- | 3.0      16-AUG-2019   Joao Adami       TRUNC supplier address    |
-- | 4.0      28-AUG-2019   Joao Adami       Add IPI|CST in unit price |
-- | 5.0      02-OCT-2019   Joao Adami       TRUNC column ENDBAI       |
-- | 6.0      22-OCT-2019   Weslley Rodri.   Alte. campo Descrição Item|
-- | 7.0      28-OCT-2019   Joao Adami       Allow delete SDC lines    |
-- | 8.0      31-OCT-2019   Mariana Andrade  Enviar info. COMLINK      |
-- | 9.0      31-OCT-2019   Weslley Rodri.   Alte. Retorno Forne. COML.|
-- | 10.0     16-NOV-2019   Mariana Andrade  Alte. info. COMLINK       |
-- | 11.0     25-NOV-2019   Joao Adami       Linhas Add SDC nao enviada|
-- | 12.0	  12-FEB-2020   Rafael Cazarim   Var. info. Fornecedor 	   |
-- +===================================================================+
--

   --
   -- +=======================================================================+
   -- | Nome: log_p                                                           |
   -- |                                                                       |
   -- | Descrição: Procedure responsavel por printar o log no concurrent      |
   -- |              request                                                  |
   -- |                                                                       |
   -- | Parametros:                                                           |
   -- |    p_name   VARCHAR2 - Nome da procedure a ser printado               |
   -- |    p_msg    VARCHAR2 - Mensagem                                       |
   -- |                                                                       |
   -- | Retorno:                                                              |
   -- |    NA                                                                 |
   -- +=======================================================================+
   --
   PROCEDURE log_p( p_name   IN VARCHAR2
                   ,p_msg    IN VARCHAR2) IS
      --
      l_log_msg fnd_log_messages.message_text%TYPE;
      --
   BEGIN
      --
      l_log_msg := ' -> XXCLK_PO_INTERFACE_PKG.' || p_name || ' = ' || p_msg;
      --
      IF g_debug THEN -- IF debug
         --
         dbms_output.put_line(l_log_msg);
         --
      ELSE -- IF l_debug
         --
         fnd_file.put_line(fnd_file.log, l_log_msg);
         --
      END IF; -- IF l_debug
      --
   END;

   --
   -- +=======================================================================+
   -- | Nome: output_p                                                        |
   -- |                                                                       |
   -- | Descrição: Procedure responsavel por printar a saida sumarizada no    |
   -- |              concurrent request                                       |
   -- |                                                                       |
   -- | Parametros:                                                           |
   -- |    p_type               VARCHAR2  - Tipo Principal do Output          |
   -- |    p_subtype            VARCHAR2  - Sub-Tipo do Output                |
   -- |    p_sdc                VARCHAR2  - Numero SDC                        |
   -- |    p_qnt_fornecedor     NUMBER    - Quantidades Fornecedores          |
   -- |    p_vendor_name        VARCHAR2  - Nome Fornecedores                 |
   -- |    p_supplier_doc       VARCHAR2  - Documento Fornecedores            |
   -- |    p_item_segment1      VARCHAR2  - Segment1 do Item SDC              |
   -- |    p_quantity           NUMBER    - Quantidade Item SDC               |
   -- |    p_uom                VARCHAR2  - Unidade de Medida Item SDC        |
   -- |    p_send_rfq_msg       VARCHAR2  - Mensagem envio SDC                |
   -- |    p_supplier_new       BOOLEAN   - Se fornecedor ? novo ou não       |
   -- |    p_line_seq           NUMBER    - Numero da Linha OC                |
   -- |    p_item_qnt           NUMBER    - Quantidate Linha OC               |
   -- |    p_item_vlr           NUMBER    - Valor Linha OC                    |
   -- |    p_oc                 NUMBER    - Numero da OC                      |
   -- |    p_create_oc_msg      VARCHAR2  - Mensagem Criação OC               |
   -- |    p_send_oc_msg        VARCHAR2  - Mensagem envia OC                 |
   -- |                                                                       |
   -- | Retorno:                                                              |
   -- |    NA                                                                 |
   -- +=======================================================================+
   --
   PROCEDURE output_p ( p_type           IN VARCHAR2
                       ,p_subtype        IN VARCHAR2 DEFAULT NULL
                       ,p_buyer          IN VARCHAR2 DEFAULT NULL
                       -- Send RFQ
                       ,p_sdc            IN VARCHAR2 DEFAULT NULL
                       ,p_qnt_fornecedor IN NUMBER DEFAULT NULL
                       ,p_vendor_name    IN VARCHAR2 DEFAULT NULL
                       ,p_supplier_doc   IN VARCHAR2 DEFAULT NULL
                       ,p_item_segment1  IN VARCHAR2 DEFAULT NULL
                       ,p_quantity       IN NUMBER DEFAULT NULL
                       ,p_uom            IN VARCHAR2 DEFAULT NULL
                       ,p_send_rfq_msg   IN VARCHAR2 DEFAULT NULL
                       -- Create OC
                       ,p_supplier_new   IN BOOLEAN  DEFAULT FALSE
                       ,p_line_seq       IN NUMBER DEFAULT 0
                       ,p_item_qnt       IN NUMBER DEFAULT 0
                       ,p_item_vlr       IN NUMBER DEFAULT 0
                       ,p_create_oc_msg  IN VARCHAR2 DEFAULT NULL
                       -- Send OC
                       ,p_oc             IN NUMBER DEFAULT 0
                       ,p_send_oc_msg    IN VARCHAR2 DEFAULT NULL
                       ) IS
      --
   BEGIN
      --
      IF p_type = 'GENERAL' THEN -- IF p_type = 'GENERAL'
         --
         fnd_file.put_line(fnd_file.output, '+----------------------------------------------------------------------------------------------------------------+');
         fnd_file.put_line(fnd_file.output, '|                                  Sumario Interface Oracle EBS x Comlink                                        |');
         fnd_file.put_line(fnd_file.output, '+----------------------------------------------------------------------------------------------------------------+');
         --
      ELSIF p_type = 'SEND_RFQ' THEN -- IF p_type = 'GENERAL'
         --
         IF p_subtype = 'HEADER' THEN -- IF p_subtype = 'HEADER'
            --
            fnd_file.put_line(fnd_file.output, '+----------------------------------------------------------------------------------------------------------------+');
            fnd_file.put_line(fnd_file.output, '|                                      Envio da Cotação para Comlink                                             |');
            fnd_file.put_line(fnd_file.output, '+----------------------------------------------------------------------------------------------------------------+');
            fnd_file.put_line(fnd_file.output, '|                                                                                                                |');
            fnd_file.put_line(fnd_file.output, '|         SDC: ' || RPAD(p_sdc,97,' ')                                                                      || ' |');
            fnd_file.put_line(fnd_file.output, '|   Comprador: ' || RPAD(p_buyer,97,' ')                                                                    || ' |');
            fnd_file.put_line(fnd_file.output, '|                                                                                                                |');
            --
         ELSIF p_subtype = 'SUPPLIER' THEN -- IF p_subtype = 'HEADER'
            --
            fnd_file.put_line(fnd_file.output, '|   FORNECEDORES (Cadastrados/Publicos): ' || RPAD(p_qnt_fornecedor,71,' ')                                 || ' |');
            --
         ELSIF p_subtype = 'SUPPLIER_LINES' THEN -- IF p_subtype = 'HEADER'
            --
            fnd_file.put_line(fnd_file.output, '|        ' || RPAD(p_vendor_name,40,' ') || ' - ' ||  RPAD(p_supplier_doc,60,' ')                           || ' |');
            --
         ELSIF p_subtype = 'LINES' THEN -- IF p_subtype = 'HEADER'
            --
            fnd_file.put_line(fnd_file.output, '|                                                                                                                |');
            fnd_file.put_line(fnd_file.output, '|   LINHAS:                                                                                                      |');
            --
         ELSIF p_subtype = 'LINES_LINES' THEN -- IF p_subtype = 'HEADER'
            --
            fnd_file.put_line(fnd_file.output, '|        ' || RPAD(p_item_segment1,40,' ') || ' - ' ||  RPAD(p_quantity,4,' ') || ' ' || RPAD(p_uom,55,' ') || ' |');
            --
         ELSIF p_subtype = 'FOOTER_LINES' THEN -- IF p_subtype = 'HEADER'
            --
            fnd_file.put_line(fnd_file.output, '|                                                                                                                |');
            fnd_file.put_line(fnd_file.output, '|   ' || RPAD(p_send_rfq_msg,108,' ')                                                                       || ' |');
            fnd_file.put_line(fnd_file.output, '|                                                                                                                |');
            fnd_file.put_line(fnd_file.output, '+----------------------------------------------------------------------------------------------------------------+');
            --
         ELSIF p_subtype = 'FOOTER' THEN -- IF p_subtype = 'HEADER'
            --
            fnd_file.put_line(fnd_file.output, '+----------------------------------------------------------------------------------------------------------------+');
            --
         END IF;
         --
      ELSIF p_type = 'CREATE_PURCHASE_ORDER' THEN -- IF p_type = 'GENERAL'
         --
         IF p_subtype = 'HEADER' THEN -- IF p_subtype = 'HEADER'
            --
            fnd_file.put_line(fnd_file.output, '+----------------------------------------------------------------------------------------------------------------+');
            fnd_file.put_line(fnd_file.output, '|                                        Criação Pedido(s) de Compra                                             |');
            fnd_file.put_line(fnd_file.output, '+----------------------------------------------------------------------------------------------------------------+');
            fnd_file.put_line(fnd_file.output, '|                                                                                                                |');
            --
         ELSIF p_subtype = 'LINES' THEN -- IF p_subtype = 'HEADER'
            --
            fnd_file.put_line(fnd_file.output, '+================================================================================================================+');
            fnd_file.put_line(fnd_file.output, '|                                                                                                                |');
            fnd_file.put_line(fnd_file.output, '|               Cotação: ' || RPAD(p_sdc,87,' ')                                                            || ' |');
            fnd_file.put_line(fnd_file.output, '|   Fornecedor CNPJ/CPF: ' || RPAD(p_supplier_doc,87,' ')                                                   || ' |');
            fnd_file.put_line(fnd_file.output, '|             Comprador: ' || RPAD(p_buyer,87,' ')                                                          || ' |');
            IF p_supplier_new THEN -- IF p_supplier_new
               --
               fnd_file.put_line(fnd_file.output, '|          Novo fornecedor criado                                                                                |');
               --
            ELSE
               --
               fnd_file.put_line(fnd_file.output, '|          Fornecedor já existente                                                                               |');
               --
            END IF; -- IF p_supplier_new
            --
            fnd_file.put_line(fnd_file.output, '|                                                                                                                |');
            fnd_file.put_line(fnd_file.output, '|          LINHAS                                                                                                |');
            --
         ELSIF p_subtype = 'LINES_LINES' THEN -- IF p_subtype = 'HEADER'
            --
            fnd_file.put_line(fnd_file.output, '|                Item: ' || RPAD(p_item_segment1,89,' ')                                                    || ' |');
            fnd_file.put_line(fnd_file.output, '|                 Qnt: ' || RPAD(p_item_qnt,89,' ')                                                         || ' |');
            fnd_file.put_line(fnd_file.output, '|               Valor: ' || RPAD(p_item_vlr,89,' ')                                                         || ' |');
            --
         ELSIF p_subtype = 'FOOTER_LINES' THEN -- IF p_subtype = 'HEADER'
            --
            fnd_file.put_line(fnd_file.output, '|                                                                                                                |');
            fnd_file.put_line(fnd_file.output, '|      OC Gerada: ' || RPAD(p_oc,94)                                                                        || ' |');
            fnd_file.put_line(fnd_file.output, '|                                                                                                                |');
            fnd_file.put_line(fnd_file.output, '|   ' || RPAD(p_create_oc_msg,108,' ')                                                                      || ' |');
            fnd_file.put_line(fnd_file.output, '|                                                                                                                |');
            fnd_file.put_line(fnd_file.output, '+----------------------------------------------------------------------------------------------------------------+');
            --
         ELSIF p_subtype = 'FOOTER' THEN -- IF p_subtype = 'HEADER'
            --
            fnd_file.put_line(fnd_file.output, '+----------------------------------------------------------------------------------------------------------------+');
            --
         END IF;
         --
      ELSIF p_type = 'SEND_PURCHASE_ORDER' THEN -- IF p_type = 'GENERAL'
          --
          IF p_subtype = 'HEADER' THEN -- IF p_subtype = 'HEADER'
             --
             fnd_file.put_line(fnd_file.output, '+----------------------------------------------------------------------------------------------------------------+');
             fnd_file.put_line(fnd_file.output, '|                                          Envio Pedido(s) de Compra                                             |');
             fnd_file.put_line(fnd_file.output, '+----------------------------------------------------------------------------------------------------------------+');
             fnd_file.put_line(fnd_file.output, '|                                                                                                                |');
             --
          ELSIF p_subtype = 'LINES' THEN -- IF p_subtype = 'HEADER'
             --
             fnd_file.put_line(fnd_file.output, '+================================================================================================================+');
             fnd_file.put_line(fnd_file.output, '|                                                                                                                |');
             --
             fnd_file.put_line(fnd_file.output, '|   Ordem de Compra: ' || RPAD(p_oc,91,' ')                                                                 || ' |');
             fnd_file.put_line(fnd_file.output, '|        Fornecedor: ' || RPAD(p_vendor_name,91,' ')                                                        || ' |');
             fnd_file.put_line(fnd_file.output, '|       Cotação Ref: ' || RPAD(p_sdc,91,' ')                                                                || ' |');
             fnd_file.put_line(fnd_file.output, '|         Comprador: ' || RPAD(p_buyer,91,' ')                                                              || ' |');
             --
             fnd_file.put_line(fnd_file.output, '|                                                                                                                |');
             fnd_file.put_line(fnd_file.output, '|          LINHAS                                                                                                |');
             --
          ELSIF p_subtype = 'LINES_LINES' THEN -- IF p_subtype = 'HEADER'
             --
             fnd_file.put_line(fnd_file.output, '|               Linha: ' || RPAD(p_line_seq,89,' ')                                                         || ' |');
             fnd_file.put_line(fnd_file.output, '|                Item: ' || RPAD(p_item_segment1,89,' ')                                                    || ' |');
             fnd_file.put_line(fnd_file.output, '|                 Qnt: ' || RPAD(p_item_qnt,89,' ')                                                         || ' |');
             --
          ELSIF p_subtype = 'FOOTER_LINES' THEN -- IF p_subtype = 'HEADER'
             --
             fnd_file.put_line(fnd_file.output, '|                                                                                                                |');
             fnd_file.put_line(fnd_file.output, '|   ' || RPAD(p_send_oc_msg,108,' ')                                                                        || ' |');
             fnd_file.put_line(fnd_file.output, '|                                                                                                                |');
             --
          ELSIF p_subtype = 'FOOTER' THEN -- IF p_subtype = 'HEADER'
             --
             fnd_file.put_line(fnd_file.output, '+----------------------------------------------------------------------------------------------------------------+');
             --
          END IF;
          --
      END IF; -- IF p_type = 'SEND_RFQ'
      --
   END;


   --
   -- +=======================================================================+
   -- | Nome: insert_attachments_po_p                                         |
   -- |                                                                       |
   -- | Descrição: Procedure responsavel por gravar o link do mapa de cotacao |
   -- |            como anexo da PO                                           |
   -- |                                                                       |
   -- | Parametros:                                                           |
   -- |    p_po_header_id  NUMBER   - ID da PO                                |
   -- |    p_description   NUMBER   - Descricao e titulo do anexo             |
   -- |                                                                       |
   -- | Retorno:                                                              |
   -- |    NA                                                                 |
   -- +=======================================================================+
   --
   PROCEDURE insert_attachments_po_p ( p_po_header_id  NUMBER
                                     , p_description   VARCHAR2
                                     , p_url           VARCHAR2
                                     ) IS

     l_rowid                ROWID;
     l_attached_document_id NUMBER;
     l_document_id          NUMBER;
     l_category_id          NUMBER;
     l_seq_num              NUMBER;
     l_fnd_user_id          NUMBER := fnd_global.user_id;
     l_short_datatype_id    NUMBER;
     l_media_id             NUMBER;

   BEGIN

     fnd_global.apps_initialize(fnd_global.user_id
                               ,fnd_global.resp_id
                               ,fnd_global.resp_appl_id
                               );

       -- Select Category id for Attachments
       SELECT category_id
         INTO l_category_id
         FROM apps.fnd_document_categories_tl
        WHERE user_name = 'Diversos'
          AND LANGUAGE  = 'PTB';

       SELECT fnd_documents_s.NEXTVAL
         INTO l_document_id
         FROM DUAL;

       SELECT fnd_attached_documents_s.NEXTVAL
         INTO l_attached_document_id
         FROM DUAL;

       SELECT NVL (MAX (seq_num), 0) + 10
         INTO l_seq_num
         FROM fnd_attached_documents
        WHERE pk1_value   = p_po_header_id
          AND entity_name = 'PO_HEADERS';

       -- Get Data type id for Short Text types of attachments
       SELECT datatype_id
         INTO l_short_datatype_id
         FROM apps.fnd_document_datatypes
        WHERE NAME     = 'WEB_PAGE'
          AND LANGUAGE = 'PTB';

       -- This package allows user to share file across multiple orgs or restrict to single org
       fnd_documents_pkg.insert_row ( x_rowid             => l_rowid
                                    , x_document_id       => l_document_id
                                    , x_creation_date     => SYSDATE
                                    , x_created_by        => l_fnd_user_id
                                    , x_last_update_date  => SYSDATE
                                    , x_last_updated_by   => l_fnd_user_id
                                    , x_last_update_login => fnd_global.login_id
                                    , x_datatype_id       => l_short_datatype_id
                                    , X_security_id       => NULL
                                    , x_publish_flag      => 'Y'
                                    , x_category_id       => l_category_id
                                    , x_security_type     => 1
                                    , x_usage_type        => 'O'
                                    , x_language          => 'PTB'
                                    , x_description       => p_description
                                    , X_title             => p_description
                                    , x_file_name         => NULL
                                    , x_media_id          => l_media_id
                                    , x_url               => p_url
                                    );
       COMMIT;

       fnd_documents_pkg.insert_tl_row ( x_document_id       => l_document_id
                                       , x_creation_date     => SYSDATE
                                       , x_created_by        => l_fnd_user_id
                                       , x_last_update_date  => SYSDATE
                                       , x_last_updated_by   => l_fnd_user_id
                                       , x_last_update_login => fnd_global.login_id
                                       , x_language          => 'PTB'
                                       , x_description       => p_description
                                       , X_title             => p_description
                                       );
       COMMIT;

       fnd_attached_documents_pkg.insert_row ( x_rowid                    => l_rowid
                                             , x_attached_document_id     => l_attached_document_id
                                             , x_document_id              => l_document_id
                                             , x_creation_date            => SYSDATE
                                             , x_created_by               => l_fnd_user_id
                                             , x_last_update_date         => SYSDATE
                                             , x_last_updated_by          => l_fnd_user_id
                                             , x_last_update_login        => fnd_global.login_id
                                             , x_seq_num                  => l_seq_num
                                             , x_entity_name              => 'PO_HEADERS'
                                             , x_column1                  => NULL
                                             , x_pk1_value                => p_po_header_id
                                             , x_pk2_value                => NULL
                                             , x_pk3_value                => NULL
                                             , x_pk4_value                => NULL
                                             , x_pk5_value                => NULL
                                             , x_automatically_added_flag => 'N'
                                             , x_datatype_id              => l_short_datatype_id
                                             , x_category_id              => l_category_id
                                             , x_security_type            => 1
                                             , X_security_id              => NULL
                                             , x_publish_flag             => 'Y'
                                             , x_language                 => 'PTB'
                                             , x_description              => p_description
                                             , X_title                    => p_description
                                             , x_file_name                => NULL
                                             , x_media_id                 => l_media_id
                                             );
       COMMIT;

   END insert_attachments_po_p;

   --
   -- +=======================================================================+
   -- | Nome: main_p                                                          |
   -- |                                                                       |
   -- | Descrição: Main procedure responsavel por iniciar o processo de       |
   -- |             Interface entre Oracle EBS x Comlink                      |
   -- |                                                                       |
   -- | Parametros:                                                           |
   -- |    errbuf          VARCHAR2 - Mensagem de retorno do concurrent(Core) |
   -- |    retcode         NUMBER   - Codigo de retorno do concurrent(Core)   |
   -- |    p_po_header_id  NUMBER   - ID da SDC (Utilizado envio de SDC)      |
   -- |                                                                       |
   -- | Retorno:                                                              |
   -- |    NA                                                                 |
   -- +=======================================================================+
   --
   PROCEDURE main_p ( errbuf         OUT VARCHAR2
                     ,retcode        OUT NUMBER
                     ,p_po_header_id IN  NUMBER) IS
      --
      l_name                    VARCHAR2(100);
      --
   BEGIN
      --
      l_name := 'MAIN_P';
      --
      log_p(l_name,' ');
      log_p(l_name,'Iniciando Interface Oracle EBS x Comlink');
      log_p(l_name,' ');
      log_p(l_name,'Parametros do Concurrent');
      log_p(l_name,' PO Header Id: ' || p_po_header_id);
      log_p(l_name,' ');
      --
      output_p ( p_type    => 'GENERAL');
      --
      send_terms_p;
      --
      IF p_po_header_id IS NOT NULL THEN -- IF p_po_header_id IS NOT NULL
         --
         send_rfq_p( p_po_header_id => p_po_header_id -- IN
                    );
         --
      ELSE  -- IF p_po_header_id IS NOT NULL
         --
         create_purchase_order_p;
         --
         send_purchase_order_p;
         --
         release_requisitions_p;
         --
      END IF; -- IF p_po_header_id IS NOT NULL
      --
   END;

   --
   -- +=======================================================================+
   -- | Nome: send_rfq_p                                                      |
   -- |                                                                       |
   -- | Descrição: Procedure responsavel por iniciar o processo de envio da   |
   -- |             Cotação para o Comlink                                    |
   -- |                                                                       |
   -- | Parametros:                                                           |
   -- |    p_po_header_id  NUMBER   - ID da SDC (Utilizado envio de SDC)      |
   -- |                                                                       |
   -- | Retorno:                                                              |
   -- |    NA                                                                 |
   -- +=======================================================================+
   --
   PROCEDURE send_rfq_p ( p_po_header_id IN  NUMBER) IS
      --
      l_name            VARCHAR2(100);
      l_send_rfq_msg    VARCHAR2(1000);
      l_cmtobs          VARCHAR2(1000);
      l_cmtucpnf        VARCHAR2(1000);
      l_cmtucpund       VARCHAR2(100);
      l_cmtucpcmp       VARCHAR2(1000);
      l_cmtucpfor       VARCHAR2(1000);
      l_cmtucpempcod    VARCHAR2(100);
      l_cmtucpfilcod    VARCHAR2(100);
      --
      l_error           BOOLEAN := FALSE;
      --
      l_cotnum_s        NUMBER;
      l_exist_cadpes    NUMBER;
      l_part_numb_count NUMBER;
      l_cmtucpqtd       NUMBER;
      l_cmtucpprc       NUMBER;
      --
      l_cmtucpdta       DATE;
      --
      CURSOR c_rfq_header IS
         SELECT pha.segment1                                 cotclinum
               ,pha.revision_num                             ccbseq
               ,SUBSTR(xr.registration_number,1,8)           empcod
               ,SUBSTR(xr.registration_number,9,6)           filcod
               ,FND_PROFILE.VALUE('XXCLK_CCBCLICOD')         ccbclicod
               ,xr.registration_number                       ccbsisdoc
               ,xr.registered_name                           ccbsisemp
               ,pha.creation_date                            ccbdta
               ,NULL                                         ccbclinec
               ,NULL                                         ccbdtaent
               ,NULL                                         ccbdtaenc
               ,NULL                                         ccbdtaret
               ,((TRUNC(pha.RFQ_CLOSE_DATE) - TRUNC(pha.creation_date)) * 24) ccbprzvld
               ,(SELECT COUNT(*) + nvl(pha.attribute15,0)
                   FROM po_rfq_vendors prv
                  WHERE prv.po_header_id = pha.po_header_id) ccbmaxfor
               ,papf.first_name || ' ' || papf.last_name     ccbcmpnom
               ,'N'                                          ccburg
               ,NULL                                         ccbdtalib
               ,'S'                                          ccbstatus
               ,papf.first_name || ' ' || papf.last_name     ccbsolicnom
               ,'N'                                          ccbnegociado
               ,NULL                                         ccbdtaretcorp
               ,NULL                                         ccbusrretcorp
               ,papf.email_address                           ccbmailcompr
               ,NULL                                         ccbobs
               ,'S'                                          ccbpubweb
               ,NULL                                         ccbhist
               ,NULL                                         ccbdtacanc
               ,DECODE(pha.quote_type_lookup_code, 
                       'SDC CONTRATO',    2, NULL)           ccbtpcot --sgarcia jan-2020
               ,NULL                                         ccbdescr
               ,NULL                                         ccblocret
               ,'C'                                          ccbstaclk
               ,'ORACLE'                                     ccborigem
               ,NULL                                         ccbequipo
               ,pha.created_by                               usercod
               ,NULL                                         ccbtipcanc
               ,NULL                                         ccbcoddiv
               ,NULL                                         ccbstatusresp
               ,NULL                                         ccburlexpneg
          FROM po_headers_all     pha
              ,hr_operating_units hou
              ,xle_registrations  xr
              ,per_all_people_f   papf
         WHERE pha.po_header_id             = p_po_header_id
           AND pha.type_lookup_code         = 'RFQ'
           AND pha.org_id                   = hou.organization_id
           AND hou.default_legal_context_id = xr.source_id
           AND xr.identifying_flag          = 'Y'
           AND papf.person_id               = pha.agent_id
           AND sysdate BETWEEN papf.effective_start_date AND papf.effective_end_date
           AND pha.attribute13              = 'Integração COMLINK'
           AND pha.attribute14              = 'Pendente';
      --
      CURSOR c_rfq_vendors IS
         SELECT SUBSTR(aps.vendor_name,1,40 + LENGTH(SUBSTR(aps.vendor_name,1,40)) - LENGTHB(SUBSTR(aps.vendor_name,1,40)))          pesnom
               ,SUBSTR(NVL(aps.vendor_name_alt,aps.vendor_name),1,20 + LENGTH(SUBSTR(NVL(aps.vendor_name_alt,aps.vendor_name),1,20)) - LENGTHB(SUBSTR(NVL(aps.vendor_name_alt,aps.vendor_name),1,20)))  pesnomres
               ,DECODE(apssa.global_attribute9,1,regexp_replace(apssa.global_attribute10 || apssa.global_attribute12,'([0-9]{3})([0-9]{3})([0-9]{3})([0-9]{2})','\1.\2.\3-\4')
                                              ,2,regexp_replace(SUBSTR(apssa.global_attribute10,2) || apssa.global_attribute11 || apssa.global_attribute12,'([0-9]{2})([0-9]{3})([0-9]{3})([0-9]{4})([0-9]{2})','\1.\2.\3/\4-\5')) doc
               ,apssa.global_attribute13                                 pesinsest
               ,apssa.global_attribute14                                 pesinsmun
               ,DECODE(apssa.global_attribute9,1,'F',2,'J')              pestpp
               ,hl.address1 || ' ' || hl.address2                        endend
               ,hl.address3                                              endcmp
               ,hl.address4                                              endbai
               ,hl.city                                                  endcid
               ,hl.postal_code                                           endcep
               ,translate(apssa.phone ,' -',' ')                         endtl1
               ,translate(apsc.phone ,' -',' ')                          endtl2
               ,NULL                                                     endtl3
               ,apssa.fax                                                endfax
               ,NULL                                                     endcxp
               ,apssa.email_address                                      endeml
               ,apsc.first_name || ' ' || apsc.last_name                 endcnt
               ,hl.state                                                 enduf
               ,LTRIM(translate(apssa.area_code ,' ()',' '),0)           enddddtel
               ,LTRIM(translate(apssa.fax_area_code ,' ()',' '),0)       enddddfax
               ,NULL                                                     pescod
               ,NULL                                                     blqcod
               ,NULL                                                     pesaceite
               ,NULL                                                     pesdiacob
               ,NULL                                                     pesdataconf
               ,decode(apssa.inactive_date,NULL,1,0)                     ativo
               ,'S'                                                      cfnpub
               ,pha.comments                                             cfnobs --#8.0
           FROM po_rfq_vendors        prv
               ,ap_suppliers          aps
               ,ap_supplier_sites_all apssa
               ,ap_supplier_contacts  apsc
               ,hz_locations          hl
               ,po_headers_all        pha --#8.0
          WHERE pha.po_header_id           = p_po_header_id
            AND prv.vendor_id          = aps.vendor_id
            AND prv.vendor_id          = apssa.vendor_id
            AND prv.vendor_site_id     = apssa.vendor_site_id
            AND prv.vendor_contact_id  = apsc.vendor_contact_id (+)
            AND apssa.vendor_id        = aps.vendor_id
            AND hl.location_id         = apssa.location_id
            AND prv.po_header_id       = pha.po_header_id; --#8.0
            --
      CURSOR c_rfq_lines IS
         SELECT pla.item_id
               ,rownum                                                                   cmtitm
               ,pla.line_num                                                             cmrseq
               ,msib.segment1                                                            cmtmatcli
               ,SUBSTR(msib.description,1,40 + LENGTH(SUBSTR(msib.description,1,40)) - LENGTHB(SUBSTR(msib.description,1,40)))    cmtnomres
               ,nvl(msit.description,msit.long_description)                              cmtcrtfis --custom ADECOAGRO
               ,NULL                                                                     cmtapl
               ,NULL                                                                     cmtemb
               ,'N'                                                                      cmtgen
               ,hr.address_line_1 ||
                ', '              ||
                hr.address_line_2 ||
                ' - '             ||
                hr.address_line_3 ||
                ', '              ||
                hr.region_1       ||
                ', '              ||
                hr.postal_code    ||
                ', '              ||
                hr.town_or_city   ||
                ' - '             ||
                hr.region_2                                                              cmtobs
               ,muomt.uom_code                                                           cmtund
               ,nvl(prla.quantity,pla.quantity)                                          cmtqtd
               ,(SELECT SUBSTR(a.name, 1, 20)
                   FROM ap_terms_vl a
                  WHERE a.term_id = plla.terms_id
                    AND rownum = 1)                                                      cmtucpcpg --#8.0
               ,plla.line_location_id                                                    cmtchavemp
               ,NULL                                                                     cmtiva
               ,NULL                                                                     cmticms
               ,NULL                                                                     cmtipi
               ,NULL                                                                     cmtucpobs
               ,SUBSTR(cffea.document_number,1,8)                                        raiz_cnpj
               ,SUBSTR(cffea.document_number,9,6)                                        compl_cnpj
               ,hr.location_id
               ,msib.organization_id
               ,pla.org_id --#10.0
           FROM po_lines_all                 pla
               ,po_line_locations_all        plla
               ,mtl_system_items_b           msib
               ,mtl_system_items_tl          msit
               ,mtl_units_of_measure_tl      muomt
               ,po_requisition_lines_all     prla
               ,hr_locations                 hr
               ,cll_f189_fiscal_entities_all cffea
          WHERE pla.po_header_id             = p_po_header_id
            AND plla.po_header_id            = pla.po_header_id
            AND plla.po_line_id              = pla.po_line_id
            AND pla.item_id                  = msib.inventory_item_id
            AND msib.inventory_item_id       = msit.inventory_item_id
            AND msib.organization_id         = msit.organization_id
            AND msit.language                = 'PTB'
            AND msib.organization_id         = plla.ship_to_organization_id
            AND muomt.unit_of_measure        = pla.unit_meas_lookup_code
            AND muomt.language               = 'PTB'
            AND prla.requisition_line_id     = plla.from_line_id
            AND hr.location_id               = plla.ship_to_location_id
            AND cffea.location_id            = prla.deliver_to_location_id;
            --ntory_item_id
      CURSOR c_part_number (pc_item_id IN NUMBER, pc_organization_id IN NUMBER /*Custom ADECOAGRO*/) IS
/*       --Custom ADECOAGRO
         SELECT mm.manufacturer_name cmrfbr
           FROM mtl_mfg_part_numbers    mmpn
               ,mtl_manufacturers       mm
          WHERE mmpn.inventory_item_id = pc_item_id
            AND mm.manufacturer_id     = mmpn.manufacturer_id;*/
         SELECT attribute5 cmrfbr
           FROM mtl_system_items_b
          WHERE inventory_item_id = pc_item_id
            AND organization_id   = pc_organization_id;
   BEGIN
      --
      l_name := 'SEND_RFQ_P';
      --
      log_p(l_name,' ');
      log_p(l_name,'Iniciando o envio da Cotação para o Comlink');
      log_p(l_name,' ');
      --
      log_p(l_name,'Executando a trava para as requisições desta Cotação');
      --
      FOR r_rfq_header IN c_rfq_header LOOP -- FOR r_rfq_header IN c_rfq_header
         --
         log_p(l_name,'RFQ: ' || r_rfq_header.cotclinum);
         --
         output_p ( p_type    => 'SEND_RFQ'
                   ,p_subtype => 'HEADER'
                   ,p_sdc     => r_rfq_header.cotclinum
                   ,p_buyer   => r_rfq_header.ccbcmpnom);
         --
         log_p(l_name,'Executando a inserção na tabela MOVCCB');
         --
         output_p ( p_type           => 'SEND_RFQ'
                   ,p_subtype        => 'SUPPLIER'
                   ,p_qnt_fornecedor =>  r_rfq_header.ccbmaxfor);
         --
         BEGIN
            --
            SELECT xxclk_cotnum_s.nextval
              INTO l_cotnum_s
              FROM dual;
            --
         END;
         --
         BEGIN
            --
            INSERT INTO movccb VALUES ( l_cotnum_s -- SEQUENCE
                                       ,r_rfq_header.cotclinum
                                       ,r_rfq_header.ccbseq
                                       ,r_rfq_header.empcod
                                       ,r_rfq_header.filcod
                                       ,r_rfq_header.ccbclicod
                                       ,r_rfq_header.ccbsisdoc
                                       ,r_rfq_header.ccbsisemp
                                       ,r_rfq_header.ccbdta
                                       ,r_rfq_header.ccbclinec
                                       ,r_rfq_header.ccbdtaent
                                       ,r_rfq_header.ccbdtaenc
                                       ,r_rfq_header.ccbdtaret
                                       ,r_rfq_header.ccbprzvld
                                       ,r_rfq_header.ccbmaxfor
                                       ,r_rfq_header.ccbcmpnom
                                       ,r_rfq_header.ccburg
                                       ,r_rfq_header.ccbdtalib
                                       ,r_rfq_header.ccbstatus
                                       ,r_rfq_header.ccbsolicnom
                                       ,r_rfq_header.ccbnegociado
                                       ,r_rfq_header.ccbdtaretcorp
                                       ,r_rfq_header.ccbusrretcorp
                                       ,r_rfq_header.ccbmailcompr
                                       ,r_rfq_header.ccbobs
                                       ,r_rfq_header.ccbpubweb
                                       ,r_rfq_header.ccbhist
                                       ,r_rfq_header.ccbdtacanc
                                       ,r_rfq_header.ccbtpcot
                                       ,r_rfq_header.ccbdescr
                                       ,r_rfq_header.ccblocret
                                       ,r_rfq_header.ccbstaclk
                                       ,r_rfq_header.ccborigem
                                       ,r_rfq_header.ccbequipo
                                       ,r_rfq_header.usercod
                                       ,r_rfq_header.ccbtipcanc
                                       ,r_rfq_header.ccbcoddiv
                                       ,r_rfq_header.ccbstatusresp
                                       ,r_rfq_header.ccburlexpneg);
            --
            log_p(l_name,'Registro inserido com sucesso na tabela MOVCCB');
            --
         EXCEPTION
            WHEN OTHERS THEN
               --
               l_error := TRUE;
               --
               log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               log_p(l_name,'ERRO: Insert na tabela MOVCCB não foi realizado ' || SQLERRM);
               log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               --
         END;
         --
         IF NOT l_error THEN -- IF NOT l_error THEN
            --
            FOR r_rfq_vendors IN c_rfq_vendors LOOP -- FOR r_rfq_vendors IN c_rfq_vendors
               --
               log_p(l_name,'Fornecedor: ' || r_rfq_vendors.pesnom);
               log_p(l_name,'Documento: '  || r_rfq_vendors.doc);
               --
               output_p ( p_type          => 'SEND_RFQ'
                         ,p_subtype       => 'SUPPLIER_LINES'
                         ,p_vendor_name   => r_rfq_vendors.pesnom
                         ,p_supplier_doc  => r_rfq_vendors.doc);
               --
               log_p(l_name,'Executando a inserção na tabela MOVCFN');
               --
               BEGIN
                  --
                  INSERT INTO movcfn VALUES ( l_cotnum_s -- SEQUENCE
                                             ,r_rfq_vendors.doc
                                             ,r_rfq_vendors.cfnobs
                                             ,r_rfq_vendors.doc     --CFNCTRL
                                             ,r_rfq_vendors.cfnpub);
                  --
                  log_p(l_name,'Registro inserido com sucesso na tabela MOVCFN');
                  --
               EXCEPTION
                  WHEN OTHERS THEN
                     --
                     l_error := TRUE;
                     --
                     log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                     log_p(l_name,'ERRO: Insert na tabela MOVCFN não foi realizado ' || SQLERRM);
                     log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                     --
               END;
               --
               IF NOT l_error THEN -- IF NOT l_error THEN
                  --
                  BEGIN
                     --
                     SELECT 1
                       INTO l_exist_cadpes
                       FROM cadpes
                      where doc = r_rfq_vendors.doc;
                     --
                     log_p(l_name,'Fornecedor já existe na tabela CADPES');
                     --
                  EXCEPTION
                     WHEN OTHERS THEN
                        --
                        log_p(l_name,'Fornecedor não existe na tabela CADPES');
                        --
                        l_exist_cadpes := 0;
                        --
                  END;
                  --
                  IF l_exist_cadpes = 0 THEN -- IF l_exist_cadpes = 0
                     --
                     log_p(l_name,'Executando a inserção na tabela CADPES');
                     --
                     BEGIN
                        --
                        INSERT INTO cadpes VALUES ( r_rfq_vendors.doc
                                                   ,r_rfq_vendors.pesnom
                                                   ,r_rfq_vendors.pesnomres
                                                   ,r_rfq_vendors.pesinsest
                                                   ,r_rfq_vendors.pesinsmun
                                                   ,r_rfq_vendors.pestpp
                                                   ,substr(r_rfq_vendors.endend,1,50) --custom AdecoAgro
                                                   ,r_rfq_vendors.endcmp
                                                   ,substr(r_rfq_vendors.endbai,1,40) --custom AdecoAgro
                                                   ,r_rfq_vendors.endcid
                                                   ,r_rfq_vendors.endcep
                                                   ,r_rfq_vendors.endtl1
                                                   ,r_rfq_vendors.endtl2
                                                   ,r_rfq_vendors.endtl3
                                                   ,r_rfq_vendors.endfax
                                                   ,r_rfq_vendors.endcxp
                                                   ,r_rfq_vendors.endeml
                                                   ,r_rfq_vendors.endcnt
                                                   ,r_rfq_vendors.enduf
                                                   ,r_rfq_vendors.enddddtel
                                                   ,r_rfq_vendors.enddddfax
                                                   ,r_rfq_vendors.pescod
                                                   ,r_rfq_vendors.blqcod
                                                   ,r_rfq_vendors.pesaceite
                                                   ,r_rfq_vendors.pesdiacob
                                                   ,r_rfq_vendors.pesdataconf
                                                   ,r_rfq_vendors.ativo);
                        --
                        log_p(l_name,'Registro inserido com sucesso na tabela CADPES');
                        --
                     EXCEPTION
                        WHEN OTHERS THEN
                           --
                           l_error := TRUE;
                           --
                           log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                           log_p(l_name,'ERRO: Insert na tabela CADPES não foi realizado ' || SQLERRM);
                           log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                           --
                     END;
                     --
                  END IF; -- IF l_exist_cadpes = 0
                  --
               END IF; -- IF NOT l_error THEN
               --
            END LOOP; -- FOR r_rfq_vendors IN c_rfq_vendors
            --
            IF NOT l_error THEN -- IF NOT l_error THEN
               --
               output_p ( p_type          => 'SEND_RFQ'
                         ,p_subtype       => 'LINES');
               --
               FOR r_rfq_lines IN c_rfq_lines LOOP -- FOR c_rfq_lines IN c_rfq_lines
                  --
                  log_p(l_name,'Executando a inserção na tabela MOVCMR');
                  --
                  output_p ( p_type          => 'SEND_RFQ'
                            ,p_subtype       => 'LINES_LINES'
                            ,p_item_segment1 => r_rfq_lines.cmtmatcli
                            ,p_quantity      => r_rfq_lines.cmtqtd
                            ,p_uom           => r_rfq_lines.cmtund);
                  --
                  l_part_numb_count := 0;
                  --
                  FOR r_part_number IN c_part_number (r_rfq_lines.item_id, r_rfq_lines.organization_id /*Custom ADECOAGRO*/) LOOP -- FOR r_part_number IN c_part_number (r_rfq_lines.cmtitm)
                     --
                     l_part_numb_count := l_part_numb_count + 1;
                     --
                     log_p(l_name,' Marca do Item a ser cotada: ' || r_part_number.cmrfbr);
                     --
                     BEGIN
                        --
                        INSERT INTO movcmr VALUES ( l_cotnum_s -- SEQUENCE
                                                   ,r_rfq_lines.cmtitm
                                                   ,-1 --l_part_numb_count --Custom ADECOAGRO
                                                   ,NULL --Custom ADECOAGRO
                                                   ,r_rfq_lines.cmtmatcli
                                                   ,NULL
                                                   ,r_part_number.cmrfbr --Custom ADECOAGRO
                                                   );
                        --
                        log_p(l_name,'Registro inserido com sucesso na tabela MOVCMR');
                        --
                     EXCEPTION
                        WHEN OTHERS THEN
                           --
                           l_error := TRUE;
                           --
                           log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                           log_p(l_name,'ERRO: Insert na tabela MOVCMR não foi realizado ' || SQLERRM);
                           log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                           --
                     END;
                     --
                  END LOOP; -- FOR r_part_number IN c_part_number (r_rfq_lines.cmtitm)
                  --
                  log_p(l_name,'Verificando se o Local de Entrega deve ser outro');
                  --
                  l_cmtobs := NULL;
                  --
                  BEGIN
                    --
                    SELECT hr1.address_line_1 ||
                           ', '               ||
                           hr1.address_line_2 ||
                           ' - '              ||
                           hr1.address_line_3 ||
                           ', '               ||
                           hr1.region_1       ||
                           ', '               ||
                           hr1.postal_code    ||
                           ', '               ||
                           hr1.town_or_city   ||
                           ' - '              ||
                           hr1.region_2
                      INTO l_cmtobs
                      FROM hr_locations      hr
                          ,fnd_lookup_values flv
                          ,hr_locations      hr1
                     where hr.location_id     = r_rfq_lines.location_id
                       AND flv.lookup_type    = 'XXCLK_PO_LOCAL_ENTREGA'
                       AND flv.language       = 'PTB'
                       AND hr.location_code   = flv.lookup_code
                       AND hr1.location_code  = flv.description;
                    --
                  EXCEPTION
                    WHEN OTHERS THEN
                       --
                       l_cmtobs := r_rfq_lines.cmtobs;
                       --
                  END;
                  --
                  log_p(l_name,'Recuperando os dados da ultima compra para o item');
                  --
                  l_cmtucpdta    := NULL;
                  l_cmtucpnf     := NULL;
                  l_cmtucpqtd    := NULL;
                  l_cmtucpund    := NULL;
                  l_cmtucpprc    := NULL;
                  l_cmtucpcmp    := NULL;
                  l_cmtucpfor    := NULL;
                  l_cmtucpempcod := NULL;
                  l_cmtucpfilcod := NULL;
                  --
                  BEGIN
                    --
                    SELECT pha1.creation_date
                          ,pha1.segment1
                          ,pla1.quantity
                          ,muomt1.uom_code
                          ,pla1.unit_price
                          ,(papf1.first_name || ' ' || papf1.last_name) full_name
                          ,SUBSTR(NVL(aps1.vendor_name_alt,aps1.vendor_name),1,20+ LENGTH(SUBSTR(NVL(aps1.vendor_name_alt,aps1.vendor_name),1,20)) - LENGTHB(SUBSTR(NVL(aps1.vendor_name_alt,aps1.vendor_name),1,20))) cmtucpfor
                          ,SUBSTR(xr1.registration_number,1,8) raiz_cnpj
                          ,SUBSTR(xr1.registration_number,9,6) compl_cnpj
                          --,xr1.registration_number
                          --,pla1.item_id
                      INTO l_cmtucpdta
                          ,l_cmtucpnf
                          ,l_cmtucpqtd
                          ,l_cmtucpund
                          ,l_cmtucpprc
                          ,l_cmtucpcmp
                          ,l_cmtucpfor
                          ,l_cmtucpempcod
                          ,l_cmtucpfilcod
                      FROM po_headers_all          pha1
                          ,po_lines_all            pla1
                          ,mtl_units_of_measure_tl muomt1
                          ,per_all_people_f        papf1
                          ,ap_suppliers            aps1
                          ,hr_operating_units      hou1
                          ,xle_registrations       xr1
                     WHERE pla1.item_id                  = r_rfq_lines.item_id
                       AND pha1.po_header_id             = pla1.po_header_id
                       AND pha1.type_lookup_code         = 'STANDARD'
                       AND pha1.authorization_status     = 'APPROVED'
                       AND muomt1.unit_of_measure        = pla1.unit_meas_lookup_code
                       AND muomt1.language               = 'PTB'
                       AND papf1.person_id               = pha1.agent_id
                       AND sysdate BETWEEN papf1.effective_start_date AND papf1.effective_end_date
                       AND aps1.vendor_id                = pha1.vendor_id
                       AND pha1.org_id                   = hou1.organization_id
                       AND hou1.default_legal_context_id = xr1.source_id
                       AND xr1.identifying_flag          = 'Y'
                       --AND pha1.attribute3               = 'NORMAL'
                       AND pla1.org_id                   = r_rfq_lines.org_id --#10.0
                       AND pla1.line_num                 = (SELECT MAX(pla2.line_num)
                                                              FROM po_headers_all pha2
                                                                  ,po_lines_all   pla2
                                                             WHERE pha2.po_header_id         = pla2.po_header_id
                                                               AND pha2.type_lookup_code     = 'STANDARD'
                                                               AND pha2.authorization_status = 'APPROVED'
                                                               AND pla2.item_id              = pla1.item_id
                                                               AND pha2.creation_date        = pha1.creation_date
                                                               AND pla2.org_id               = pla1.org_id) --#10.0
                       AND pha1.creation_date            = (SELECT MAX(pha2.creation_date)
                                                              FROM po_headers_all pha2
                                                                  ,po_lines_all   pla2
                                                             WHERE pha2.po_header_id         = pla2.po_header_id
                                                               AND pha2.type_lookup_code     = 'STANDARD'
                                                               AND pha2.authorization_status = 'APPROVED'
                                                               AND pla2.item_id              = pla1.item_id
                                                               AND pla2.org_id               = pla1.org_id); --#10.0
                    --
                  EXCEPTION
                    WHEN OTHERS THEN
                       --
                       log_p(l_name,'Item não utilizado em nenhuma OC');
                       --
                       l_cmtucpdta    := NULL;
                       l_cmtucpnf     := NULL;
                       l_cmtucpqtd    := NULL;
                       l_cmtucpund    := NULL;
                       l_cmtucpprc    := NULL;
                       l_cmtucpcmp    := NULL;
                       l_cmtucpfor    := NULL;
                       l_cmtucpempcod := NULL;
                       l_cmtucpfilcod := NULL;
                       --
                  END;
                  --
                  log_p(l_name,'Executando a inserção na tabela MOVCMT');
                  --
                  BEGIN
                     --
                     INSERT INTO movcmt VALUES ( l_cotnum_s -- SEQUENCE
                                                ,r_rfq_lines.cmtitm
                                                ,r_rfq_lines.cmtmatcli
                                                ,r_rfq_lines.cmtnomres
                                                ,r_rfq_lines.cmtcrtfis
                                                ,r_rfq_lines.cmtapl
                                                ,r_rfq_lines.cmtemb
                                                ,r_rfq_lines.cmtgen
                                                ,l_cmtobs
                                                ,r_rfq_lines.cmtund
                                                ,r_rfq_lines.cmtqtd
                                                ,l_cmtucpdta
                                                ,l_cmtucpnf
                                                ,l_cmtucpqtd
                                                ,l_cmtucpund
                                                ,l_cmtucpprc
                                                ,l_cmtucpcmp
                                                ,l_cmtucpfor
                                                ,r_rfq_lines.cmtucpcpg
                                                ,l_cmtucpempcod
                                                ,l_cmtucpfilcod
                                                ,r_rfq_lines.cmtchavemp
                                                ,r_rfq_lines.cmtiva
                                                ,r_rfq_lines.cmticms
                                                ,r_rfq_lines.cmtipi
                                                ,r_rfq_lines.cmtucpobs);
                     --
                     log_p(l_name,'Registro inserido com sucesso na tabela MOVCMT');
                     --
                  EXCEPTION
                     WHEN OTHERS THEN
                        --
                        l_error := TRUE;
                        --
                        log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                        log_p(l_name,'ERRO: Insert na tabela MOVCMT não foi realizado ' || SQLERRM);
                        log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                        --
                  END;
                  --
                  log_p(l_name,'Executando a inserção na tabela MOVMEF');
                  --
                  BEGIN
                     --
                     INSERT INTO movmef VALUES ( l_cotnum_s -- SEQUENCE
                                                ,r_rfq_lines.cmtitm
                                                ,r_rfq_lines.raiz_cnpj
                                                ,r_rfq_lines.compl_cnpj
                                                ,r_rfq_lines.cmtchavemp
                                                ,NULL
                                                ,r_rfq_lines.cmtqtd
                                                ,NULL --r_rfq_header.ccbsolicnom
                                                ,r_rfq_header.ccbprzvld
                                                );
                     --
                     log_p(l_name,'Registro inserido com sucesso na tabela MOVMEF');
                     --
                  EXCEPTION
                     WHEN OTHERS THEN
                        --
                        l_error := TRUE;
                        --
                        log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                        log_p(l_name,'ERRO: Insert na tabela MOVMEF não foi realizado ' || SQLERRM);
                        log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                        --
                  END;
                  --
               END LOOP; -- FOR c_rfq_lines IN c_rfq_lines
               --
            END IF; --IF NOT l_error THEN
            --
         END IF; -- IF NOT l_error THEN
         --
         IF l_error THEN -- IF l_error
            --
            log_p(l_name,'Falha ao inserir o registro nas tabelas do Comlink');
            --
            l_send_rfq_msg := 'Falha ao inserir o registro nas tabelas do Comlink. Verifique o Log para mais detalhes';
            --
            ROLLBACK;
            --
         ELSE -- IF l_error
            --
            UPDATE po_headers_all
               SET attribute14          = 'Cotação Enviada'
                 , attribute12          = 'REQ: ' || fnd_global.conc_request_id
--                  ,status_lookup_code  = 'C'
             WHERE po_header_id = p_po_header_id;
            --
            log_p(l_name,'Registro inserido com Sucesso nas tabelas da Comlink');
            --
            l_send_rfq_msg := 'Registro inserido com Sucesso nas tabelas da Comlink';
            --
            COMMIT;
            --
         END IF; -- IF l_error
         --
         output_p ( p_type          => 'SEND_RFQ'
                   ,p_subtype       => 'FOOTER_LINES'
                   ,p_send_rfq_msg  => l_send_rfq_msg);
         --
      END LOOP; -- FOR r_rfq_header IN c_rfq_header
      --
      output_p ( p_type          => 'SEND_RFQ'
                ,p_subtype       => 'FOOTER');
      --
      log_p(l_name,' ');
      log_p(l_name,'Fim do envio da Cotação para o Comlink');
      log_p(l_name,' ');
      --
   END;

   --
   -- +=======================================================================+
   -- | Nome: create_purchase_order_p                                         |
   -- |                                                                       |
   -- | Descrição: Procedure responsavel por criar a ordem de compra com base |
   -- |             nas Cotação retornadas da Comlink                         |
   -- |                                                                       |
   -- | Parametros:                                                           |
   -- |    NA                                                                 |
   -- |                                                                       |
   -- | Retorno:                                                              |
   -- |    NA                                                                 |
   -- +=======================================================================+
   --
   PROCEDURE create_purchase_order_p IS
      --
      l_error                BOOLEAN := FALSE;
      l_supplier_new         BOOLEAN := FALSE;
      --
      l_document_id          NUMBER;
      l_msg_count            NUMBER;
      l_num_lines_processed  NUMBER;
      l_interface_header_id  NUMBER;
      l_interface_line_id    NUMBER;
      l_vendor_id            NUMBER;
      l_vendor_site_id       NUMBER;
      l_line_num_oc          NUMBER;
      l_ship_to_location     NUMBER;
      l_conc_request_id      NUMBER;
      --
      l_name                 VARCHAR2(100);
      l_msg_data             VARCHAR2(5000);
      l_vendor_name          VARCHAR2(1000);
      l_vendor_site_code     VARCHAR2(1000);
      l_return_status        VARCHAR2(1);
      l_item_key             VARCHAR2(100);
      l_create_oc_msg        VARCHAR2(1000);
      l_send_approval_flag   VARCHAR2(1);
      l_freight_code         VARCHAR2(100);
      l_unit_price_with_tax  NUMBER := 0;
      l_inactive_date        DATE; --custom AdecoAgro
      --
      l_document_number      po_headers_all.segment1%TYPE;
      --
      CURSOR c_ret_cot IS
         SELECT mped.doc
               ,mped.cotnum
               ,pha.po_header_id
               ,flv.meaning pedfrms
               ,nvl(mped.pedcpgtocoderp,mped.pedcpgto) pedcpgtocoderp
               ,pha.agent_id
               ,pha.org_id
               ,pha.segment1
               ,prla.deliver_to_location_id
               ,plla.ship_to_location_id
               ,DECODE(mcrf.moesmb,'US$','USD','BRL') moesmb
               ,mped.tracod
               ,papf.first_name || ' ' || papf.last_name buyer
               ,mccb.ccburlexpneg
               ,pha.attribute13
               ,pha.attribute14
               ,pha.attribute15
               ,DECODE(pha.QUOTE_TYPE_LOOKUP_CODE,'SDC CONTRATO', 'BLANKET', 'STANDARD' ) QUOTE_TYPE--sgarcia 
           FROM po_headers_all           pha
               ,movccb                   mccb
               ,movped                   mped
               ,moventr                  mentr
               ,movmefn                  mmefn
               ,fnd_lookup_values        flv
               ,hr_operating_units       hou
               ,xle_registrations        xr
               ,po_lines_all             pla
               ,po_line_locations_all    plla
               ,po_requisition_lines_all prla
               ,movcrf                   mcrf
               ,movcre                   mcre
               ,per_all_people_f         papf
          WHERE pha.type_lookup_code         = 'RFQ'
            AND pha.attribute13              = 'Integração COMLINK'
            AND pha.segment1                 = mccb.cotclinum
            AND mped.cotnum                  = mccb.cotnum
            AND DECODE(mped.pedfrms,'C','C'
                                   ,'F','F'
                                   ,'N')     = flv.lookup_code
            AND flv.lookup_type              = 'CLL_F189_CIF_FOB_FREIGHT'
            AND flv.language                 = 'PTB'
            AND pha.org_id                   = hou.organization_id
            AND hou.default_legal_context_id = xr.source_id
            AND xr.identifying_flag          = 'Y'
            AND xr.registration_number       = mccb.ccbsisdoc
            AND pha.po_header_id             = pla.po_header_id
            AND mentr.cotnum                 = mped.cotnum
            AND mentr.doc                    = mped.doc
            AND mentr.empcod                 = mped.empcod
            AND mentr.filcod                 = mped.filcod
            AND mentr.mefordem               = plla.line_location_id
            AND plla.po_header_id            = pha.po_header_id
            AND plla.po_line_id              = pla.po_line_id
            AND prla.requisition_line_id     = plla.from_line_id
            AND mmefn.doc                    = mped.doc
            AND mmefn.cotnum                 = mped.cotnum
            AND mmefn.mefordem               = plla.line_location_id
            AND mcrf.cotnum                  = mped.cotnum
            AND mcrf.doc                     = mped.doc
            AND mccb.ccbtipcanc              IS NULL
            AND mcre.cotnum                  = mmefn.cotnum
            AND mcre.doc                     = mmefn.doc
            AND mcre.cmtitm                  = mmefn.cmtitm
            AND mcre.crevlrneg               > 0
            AND papf.person_id               = pha.agent_id
            AND sysdate BETWEEN papf.effective_start_date AND papf.effective_end_date
            AND NOT EXISTS(SELECT plla.attribute1
                             FROM po_line_locations_all plla1
                                 ,ap_supplier_sites_all apssa
                                 ,po_headers_all pha_oc
                            WHERE plla1.line_location_id = plla.line_location_id
                              AND plla1.attribute1       = pha_oc.segment1
                              AND pha_oc.org_id          = pha.org_id
                              AND apssa.vendor_site_id   = pha_oc.vendor_site_id
                              AND DECODE(apssa.global_attribute9,1,regexp_replace(apssa.global_attribute10 || apssa.global_attribute12,'([0-9]{3})([0-9]{3})([0-9]{3})([0-9]{2})','\1.\2.\3-\4')
                                                                ,2,regexp_replace(SUBSTR(apssa.global_attribute10,2) || apssa.global_attribute11 || apssa.global_attribute12,'([0-9]{2})([0-9]{3})([0-9]{3})([0-9]{4})([0-9]{2})','\1.\2.\3/\4-\5')) = mped.doc)
       GROUP BY mped.doc
               ,mped.cotnum
               ,pha.po_header_id
               ,flv.meaning
               ,nvl(mped.pedcpgtocoderp,mped.pedcpgto)
               ,pha.agent_id
               ,pha.org_id
               ,pha.segment1
               ,prla.deliver_to_location_id
               ,plla.ship_to_location_id
               ,mcrf.moesmb
               ,mped.tracod
               ,papf.first_name || ' ' || papf.last_name
               ,mccb.ccburlexpneg
               ,pha.attribute13
               ,pha.attribute14
               ,pha.attribute15
               ,pha.QUOTE_TYPE_LOOKUP_CODE;
      --
      CURSOR c_ret_cot_lines( pc_doc                 IN VARCHAR2
                             ,pc_cotnum              IN NUMBER
                             ,pc_ship_to_location_id IN NUMBER) IS
         SELECT mmefn.cmtitm
               ,prla.item_id
               ,mmefn.creseq
               ,mcre.creqtdneg
               ,mcre.crevlrneg
               ,plla.from_line_id
               ,prla.deliver_to_location_id
               ,mcre.creref
               ,plla.line_location_id
               ,mccb.cotnum
               ,mcre.cremarca
               ,mcmt.cmtmatcli
               ,mcre.creentr
               ,mcre.crefbr --custom ADECOAGRO
               ,mcre.crepctipi --custom ADECOAGRO
               ,mcre.crepercst --custom ADECOAGRO
           FROM movccb                   mccb
               ,movcmt                   mcmt
               ,moventr                  mentr
               ,movmefn                  mmefn
               ,movcre                   mcre
               ,po_line_locations_all    plla
               ,po_requisition_lines_all prla
          WHERE mccb.cotnum                 = mcmt.cotnum
            AND mentr.cotnum                = mcmt.cotnum
            AND mentr.mefordem              = mcmt.cmtchavemp
            AND mentr.cotnum                = mmefn.cotnum
            AND mentr.doc                   = mmefn.doc
            AND mentr.cmtitm                = mmefn.cmtitm
            AND mcre.cotnum                 = mmefn.cotnum
            AND mcre.doc                    = mmefn.doc
            AND mcre.cmtitm                 = mmefn.cmtitm
            AND mentr.mefordem              = plla.line_location_id
            AND prla.requisition_line_id    = plla.from_line_id
            AND mcre.crevlrneg              > 0
            AND mmefn.doc                   = pc_doc
            AND mccb.cotnum                 = pc_cotnum
            AND prla.deliver_to_location_id = pc_ship_to_location_id;
      --
   BEGIN
      --
      mo_global.init('PO');
      --
      l_name := 'CREATE_PURCHASE_ORDER_P';
      --
      l_conc_request_id := fnd_global.conc_request_id;
      --
      log_p(l_name,' ');
      log_p(l_name,'Iniciando a Criação das Ordens de Compra para o Retorno da Comlink');
      log_p(l_name,' ');
      --
      output_p ( p_type           => 'CREATE_PURCHASE_ORDER'
                ,p_subtype        => 'HEADER');
      --
      l_send_approval_flag := FND_PROFILE.VALUE('XXCLK_SENDAPPROVAL');
      --
      FOR r_ret_cot IN c_ret_cot LOOP -- FOR r_ret_cot IN c_ret_cot
         --
         l_error := FALSE;
         --
         log_p(l_name,'-------------------------------------------------------');
         log_p(l_name,'            Cotação: ' || r_ret_cot.segment1 );
         log_p(l_name,'Fornecedor CNPJ/CPF: ' || r_ret_cot.doc );
         log_p(l_name,'              Local: ' || r_ret_cot.deliver_to_location_id );
         --Begin SR21931
		 l_inactive_date := null;
		 l_vendor_site_id := null;
		 l_vendor_name := null;
		 l_vendor_site_code := null;
		 --End SR21931
         BEGIN
            --
            SELECT apssa.vendor_id
                  ,apssa.vendor_site_id
                  ,aps.vendor_name
                  ,apssa.vendor_site_code
              INTO l_vendor_id
                  ,l_vendor_site_id
                  ,l_vendor_name
                  ,l_vendor_site_code
              FROM ap_supplier_sites_all apssa
                  ,ap_suppliers          aps
             WHERE DECODE(apssa.global_attribute9,1,apssa.global_attribute10 || apssa.global_attribute12
                                                 ,2,SUBSTR(apssa.global_attribute10,2) || apssa.global_attribute11 || apssa.global_attribute12) = TRANSLATE(r_ret_cot.doc,' ./-',' ')
               AND apssa.org_id  = r_ret_cot.org_id
               AND aps.vendor_id = apssa.vendor_id
               AND NVL(apssa.inactive_date, SYSDATE +1)  >  SYSDATE;
               --
               log_p(l_name,'Fornecedor encontrado - ' || l_vendor_name || ' - ' || l_vendor_site_code);
               --
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
       
                BEGIN  -- Custom AdecoAgro  #9.0  *Início*

                 SELECT apssa.vendor_id
                       ,apssa.vendor_site_id
                       ,aps.vendor_name
                       ,apssa.vendor_site_code
                       ,apssa.inactive_date
                   INTO l_vendor_id
                       ,l_vendor_site_id
                       ,l_vendor_name
                       ,l_vendor_site_code
                       ,l_inactive_date
                   FROM ap_supplier_sites_all apssa
                       ,ap_suppliers          aps
                  WHERE DECODE(apssa.global_attribute9,1,apssa.global_attribute10 || apssa.global_attribute12
                                                      ,2,SUBSTR(apssa.global_attribute10,2) || apssa.global_attribute11 || apssa.global_attribute12) = TRANSLATE(r_ret_cot.doc,' ./-',' ')
                    AND apssa.org_id  = r_ret_cot.org_id
                    AND aps.vendor_id = apssa.vendor_id;
                    --
                    log_p(l_name,'Fornecedor inativo encontrado - ' || l_vendor_name || ' - ' || l_vendor_site_code);   -- Custom AdecoAgro #9.0  *Fim*
                    --
                 EXCEPTION

                     WHEN NO_DATA_FOUND THEN
                       --
                       log_p(l_name,'Fornecedor não encontrado.');
                       --
                       l_vendor_id      := 0;
                       l_vendor_site_id := 0;

                 END;

            WHEN OTHERS THEN
               --
               l_error := TRUE;
               --
               log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               log_p(l_name,'ERRO: Falha ao recuperar o vendor_id do Fornecedor ' || SQLERRM);
               log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               --
         END;
         --
         IF l_inactive_date IS NOT NULL THEN --Custom AdecoAgro Start
           log_p(l_name,'Fornecedor esta inativo desde - ' || l_inactive_date);
         ELSE
           --
           IF l_vendor_id = 0 AND l_vendor_site_id = 0 THEN -- IF l_vendor_id = 0 AND l_vendor_site_id = 0
              --
              create_supplier_p ( p_doc            => r_ret_cot.doc
                                 ,p_org_id         => r_ret_cot.org_id
                                 ,x_vendor_id      => l_vendor_id
                                 ,x_vendor_site_id => l_vendor_site_id
                                 ,x_error          => l_error
                                );
              --
              l_supplier_new := TRUE;
              --
           END IF; -- IF l_vendor_id = 0 AND l_vendor_site_id = 0
           --
           output_p ( p_type           => 'CREATE_PURCHASE_ORDER'
                     ,p_subtype        => 'LINES'
                     ,p_sdc            => r_ret_cot.segment1
                     ,p_supplier_doc   => r_ret_cot.doc
                     ,p_supplier_new   => l_supplier_new
                     ,p_buyer          => r_ret_cot.buyer
                     );
           --
           BEGIN
              --
              SELECT po_headers_interface_s.nextval
                INTO l_interface_header_id
                FROM dual;
              --
           END;
           --
           log_p(l_name,'Verificando se o Local de Entrega deve ser outro');
           --
           l_ship_to_location := NULL;
           --
           BEGIN
             --
             SELECT hr1.location_id
               INTO l_ship_to_location
               FROM hr_locations      hr
                   ,fnd_lookup_values flv
                   ,hr_locations      hr1
              WHERE hr.location_id     = r_ret_cot.ship_to_location_id
                AND flv.lookup_type    = 'XXCLK_PO_LOCAL_ENTREGA'
                AND flv.language       = 'PTB'
                AND hr.location_code   = flv.lookup_code
                AND hr1.location_code  = flv.description;
             --
           EXCEPTION
             WHEN OTHERS THEN
                --
                l_ship_to_location := r_ret_cot.ship_to_location_id;
                --
           END;
           --
           BEGIN
              --
              SELECT wc.freight_code
                INTO l_freight_code
                FROM wsh_carriers    wc
               WHERE wc.carrier_id = r_ret_cot.tracod;
              --
           EXCEPTION
              WHEN OTHERS THEN
                 --
                 l_freight_code := NULL;
                 --
           END;
           --
           log_p(l_name,'Inserindo o registro na tabela de Interface do PO');
           --
           BEGIN
              --
              INSERT INTO po_headers_interface ( interface_header_id    -- 1
                                                ,interface_source_code  -- 2
                                                ,batch_id               -- 3
                                                ,process_code           -- 4
                                                ,action                 -- 5
                                                ,document_type_code     -- 6
                                                ,document_subtype       -- 7
                                                ,document_num           -- 8
                                                ,freight_terms          -- 9
                                                ,fob                    -- 10
                                                --,payment_terms          -- 11
                                                ,terms_id               -- 11
                                                ,group_code             -- 12
                                                ,vendor_id              -- 13
                                                ,vendor_site_id         -- 14
                                                ,agent_id               -- 15
                                                ,currency_code          -- 16
                                                ,creation_date          -- 17
                                                ,created_by             -- 18
                                                ,last_update_date       -- 19
                                                ,last_updated_by        -- 20
                                                ,style_id               -- 21
                                                ,approval_status        -- 22
                                                ,org_id                 -- 23
                                                ,comments               -- 24
                                                ,ship_to_location_id    -- 25
                                                ,bill_to_location_id    -- 26
                                                ,freight_carrier        -- 27
                                                ,attribute13            -- 28
                                                ,attribute14            -- 29
                                                ,attribute15            -- 30
                                               )
                                        VALUES ( l_interface_header_id                  -- 1
                                                ,'PO'                                   -- 2
                                                ,l_interface_header_id                  -- 3
                                                ,'NEW'                                  -- 4
                                                ,'NEW'                                  -- 5
                                                ,'PO'                                   -- 6 
                                                , --'STANDARD'            
                                                r_ret_cot.QUOTE_TYPE    --              -- 7 sgarcia BLANKET 
                                                ,NULL                                   -- 8
                                                ,r_ret_cot.pedfrms                      -- 9
                                                ,r_ret_cot.pedfrms                      -- 10
                                                ,r_ret_cot.pedcpgtocoderp               -- 11
                                                ,'DEFAULT'                              -- 12
                                                ,l_vendor_id                            -- 13
                                                ,l_vendor_site_id                       -- 14
                                                ,r_ret_cot.agent_id                     -- 15
                                                ,r_ret_cot.moesmb                       -- 16
                                                ,SYSDATE                                -- 17
                                                ,-1                                     -- 18
                                                ,SYSDATE                                -- 19
                                                ,-1                                     -- 20
                                                ,1                                      -- 21
                                                ,'INCOMPLETE'                           -- 22
                                                ,r_ret_cot.org_id                       -- 23
                                                ,'COMLINK: SDC: ' || r_ret_cot.segment1 -- 24
                                                ,l_ship_to_location                     -- 25
                                                ,r_ret_cot.deliver_to_location_id       -- 26
                                                ,l_freight_code                         -- 27
                                                ,r_ret_cot.attribute13                  -- 28
                                                ,r_ret_cot.attribute14                  -- 29
                                                ,r_ret_cot.attribute15                  -- 30
                                                );
              --
              log_p(l_name,'Registro com ID ' || l_interface_header_id ||   ' inserido com sucesso na tabela PO_HEADERS_INTERFACE');
              --
           EXCEPTION
              WHEN OTHERS THEN
                 --
                 l_error := TRUE;
                 --
                 log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                 log_p(l_name,'ERRO: Insert na tabela PO_HEADERS_INTERFACE não foi realizado ' || SQLERRM);
                 log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                 --
           END;
           --
           IF NOT l_error THEN -- IF NOT l_error
              --
              l_line_num_oc := 0;
              --
              FOR r_ret_cot_lines IN c_ret_cot_lines( pc_doc                 => r_ret_cot.doc
                                                     ,pc_cotnum              => r_ret_cot.cotnum
                                                     ,pc_ship_to_location_id => r_ret_cot.deliver_to_location_id) LOOP -- FOR r_ret_cot_lines IN c_ret_cot_lines
                 l_unit_price_with_tax := 0; --custom ADECOAGRO
                 --
                 log_p(l_name,'------------');
                 log_p(l_name,'Item ID: ' || r_ret_cot_lines.item_id);
                 log_p(l_name,'    Qnt: ' || r_ret_cot_lines.creqtdneg);
                 log_p(l_name,'  Valor: ' || r_ret_cot_lines.crevlrneg);
                 log_p(l_name,'    IPI: ' || r_ret_cot_lines.crepctipi);
                 log_p(l_name,'    CST: ' || r_ret_cot_lines.crepercst);
                 --
                 output_p ( p_type           => 'CREATE_PURCHASE_ORDER'
                           ,p_subtype        => 'LINES_LINES'
                           ,p_item_segment1  => r_ret_cot_lines.cmtmatcli
                           ,p_item_qnt       => r_ret_cot_lines.creqtdneg
                           ,p_item_vlr       => r_ret_cot_lines.crevlrneg
                          );
                 --
                 BEGIN
                    --
                    SELECT po_lines_interface_s.nextval
                      INTO l_interface_line_id
                      FROM dual;
                    --
                 END;
                 --
                 log_p(l_name,'Inserindo o registro na tabela de Linhas da Interface do PO');
                 --
                 l_line_num_oc := l_line_num_oc + 1;
                 --custom ADECOAGRO Start
                 BEGIN
                   l_unit_price_with_tax := nvl(r_ret_cot_lines.crevlrneg,0) +
                                            nvl(r_ret_cot_lines.crevlrneg,0) * (nvl(r_ret_cot_lines.crepctipi,0)/100) +
                                            nvl(r_ret_cot_lines.crevlrneg,0) * (nvl(r_ret_cot_lines.crepercst,0)/100);
                 EXCEPTION
                   WHEN OTHERS THEN
                     log_p(l_name,'Erro inesperado agregando os valores de IPI e CST ao preco unitario do item. ' || SQLERRM);
                     l_unit_price_with_tax := nvl(r_ret_cot_lines.crevlrneg,0);
                 END;
                 --custom ADECOAGRO End
                 BEGIN
                    --
                    INSERT INTO po_lines_interface ( interface_header_id          -- 1
                                                    ,interface_line_id            -- 2
                                                    ,requisition_line_id          -- 3
                                                    ,item_id                      -- 4
                                                    ,line_num                     -- 5
                                                    ,quantity                     -- 6
                                                    ,unit_price                   -- 7
                                                    ,creation_date                -- 8
                                                    ,created_by                   -- 9
                                                    ,last_update_date             -- 10
                                                    ,last_updated_by              -- 11
                                                    ,from_line_id                 -- 12
                                                    ,vendor_product_num           -- 13
                                                    ,need_by_date                 -- 14
                                                    ,promised_date                -- 15
                                                    ,line_attribute12             -- 16 --custom ADECOAGRO
                                                   )
                                            VALUES ( l_interface_header_id              -- 1
                                                    ,l_interface_line_id                -- 2
                                                    ,r_ret_cot_lines.from_line_id       -- 3
                                                    ,r_ret_cot_lines.item_id            -- 4
                                                    ,l_line_num_oc                      -- 5
                                                    ,r_ret_cot_lines.creqtdneg          -- 6
                                                    ,l_unit_price_with_tax              -- 7 --custom ADECOAGRO
                                                    ,SYSDATE                            -- 8
                                                    ,-1                                 -- 9
                                                    ,SYSDATE                            -- 10
                                                    ,-1                                 -- 11
                                                    ,r_ret_cot_lines.line_location_id   -- 12
                                                    ,r_ret_cot_lines.cremarca           -- 13
                                                    ,r_ret_cot_lines.creentr            -- 14
                                                    ,r_ret_cot_lines.creentr            -- 15
                                                    ,r_ret_cot_lines.crefbr             -- 16 --custom ADECOAGRO
                                                   );
                    --
                    log_p(l_name,'Registro com ID '|| l_interface_line_id || ' inserido com sucesso na tabela PO_LINES_INTERFACE');
                    --
                 EXCEPTION
                    WHEN OTHERS THEN
                       --
                       l_error := TRUE;
                       --
                       log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                       log_p(l_name,'ERRO: Insert na tabela PO_LINES_INTERFACE não foi realizado ' || SQLERRM);
                       log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                       --
                 END;
                 --
              END LOOP; -- FOR r_ret_cot_lines IN c_ret_cot_lines
              --
           END IF; -- IF NOT l_error
           --
           IF l_error OR l_line_num_oc = 0 THEN -- IF l_error
              --
              log_p(l_name,'Falha ao inserir o registro nas tabelas da Inteface do PO');
              --
              l_create_oc_msg := 'Falha ao inserir o registro nas tabelas da Inteface do PO. Verifique o Log para mais informações';
              --
              ROLLBACK;
              --
           ELSE -- IF l_error
              --
              log_p(l_name,'Registro inserido com Sucesso nas tabelas da Inteface do PO');
              --
              COMMIT;
              --
              l_document_id     := NULL;
              l_document_number := NULL;
              --
              BEGIN
                 --
                 po_interface_s.create_documents ( p_api_version              => 1.0
                                                  ,x_return_status            => l_return_status
                                                  ,x_msg_count                => l_msg_count
                                                  ,x_msg_data                 => l_msg_data
                                                  ,p_batch_id                 => l_interface_header_id
                                                  ,p_req_operating_unit_id    => r_ret_cot.org_id
                                                  ,p_purch_operating_unit_id  => r_ret_cot.org_id
                                                  ,x_document_id              => l_document_id
                                                  ,x_number_lines             => l_num_lines_processed
                                                  ,x_document_number          => l_document_number
                                                  ,p_document_creation_method => 'AUTOCREATE'
                                                  ,p_sourcing_k_doc_type      => NULL
                                                  ,p_conterms_exist_flag      => NULL
                                                  ,p_orig_org_id              => NULL);

                 --
                 log_p(l_name,'Retorno da Criação da Ordem de Compra');
                 log_p(l_name,'       Status: ' || l_return_status);
                 log_p(l_name,'    Msg Count: ' || l_msg_count);
                 log_p(l_name,'          Msg: ' || SUBSTR(l_msg_data,1,240));
                 log_p(l_name,' po_header_id: ' || l_document_id);
                 log_p(l_name,'       Nro OC: ' || l_document_number);
                 --
                 log_p(l_name,'Ordem de Compra criada com sucesso!');
                 --
              EXCEPTION
                 WHEN OTHERS THEN
                    --
                    l_error := TRUE;
                    --
                    log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                    log_p(l_name,'ERRO: Falha ao chamar a API po_interface_s.create_documents ' || SQLERRM);
                    log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                    --
              END;
              --
              IF l_document_id IS NOT NULL AND l_document_number IS NOT NULL THEN -- IF l_document_id IS NOT NULL AND l_document_number IS NOT NULL
                 --
                 log_p(l_name,'Atualizando as linhas da SDC com a OC criada.');
                 --
                 BEGIN
                    --
                    UPDATE po_line_locations_all plla
                       SET plla.attribute1          = l_document_number
                     WHERE plla.attribute_category  = 'Integração COMLINK'
                       AND plla.line_location_id IN (SELECT pla1.from_line_id
                                                       FROM po_lines_all pla1
                                                      WHERE pla1.po_header_id = l_document_id);
                    --
                    UPDATE po_headers_all
                       SET attribute14         = 'Cotação Retornada'
                          ,status_lookup_code  = 'C'
                          ,attribute12         = attribute12 || ' / OC: ' || l_conc_request_id
                     WHERE po_header_id        = r_ret_cot.po_header_id
                       AND attribute13         = 'Integração COMLINK';
                    --
                    COMMIT;
                    --
                 EXCEPTION
                    WHEN OTHERS THEN
                       --
                       l_error := TRUE;
                       --
                       log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                       log_p(l_name,'ERRO: Update na tabela PO_HEADERS_ALL para a SDC não foi realizado ' || SQLERRM);
                       log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                       --
                 END;
                 --
                 IF NOT l_error AND l_send_approval_flag = 'Y' THEN -- IF NOT l_error AND l_send_approval_flag = 'Y'
                    --
                    log_p(l_name,'Enviando a Ordem de Compra para aprovação');
                    --
                    BEGIN
                      --
                      SELECT l_document_id || '-' || TO_CHAR(po_wf_itemkey_s.nextval)
                        INTO l_item_key
                        FROM dual;
                      --
                    END;
                    --
                    BEGIN
                       --
                       po_reqapproval_init1.start_wf_process ( itemtype                 => 'POAPPRV'
                                                              ,itemkey                  => l_item_key
                                                              ,workflowprocess          => 'POAPPRV_TOP'
                                                              ,actionoriginatedfrom     => 'PO_FORM'
                                                              ,documentid               => l_document_id
                                                              ,documentnumber           => l_document_number
                                                              ,preparerid               => r_ret_cot.agent_id
                                                              ,documenttypecode         => 'PO'
                                                              ,--documentsubtype          => 'STANDARD' --sgarcia
                                                               documentsubtype          => r_ret_cot.QUOTE_TYPE
                                                              ,submitteraction          => 'APPROVE'
                                                              ,forwardtoid              => NULL
                                                              ,forwardfromid            => NULL
                                                              ,defaultapprovalpathid    => NULL
                                                              ,note                     => NULL
                                                              ,printflag                => 'N'
                                                              ,faxflag                  => 'N'
                                                              ,faxnumber                => NULL
                                                              ,emailflag                => 'N'
                                                              ,emailaddress             => NULL
                                                              ,createsourcingrule       => 'N'
                                                              ,releasegenmethod         => 'N'
                                                              ,updatesourcingrule       => 'N'
                                                              ,massupdatereleases       => 'N'
                                                              ,retroactivepricechange   => 'N'
                                                              ,orgassignchange          => 'N'
                                                              ,communicatepricechange   => 'N'
                                                              ,p_background_flag        => 'N'
                                                              ,p_initiator              => NULL
                                                              ,p_xml_flag               => NULL
                                                              ,fpdsngflag               => 'N'
                                                              ,p_source_type_code       => NULL);
                       --
                       COMMIT;
                       --
                       log_p(l_name,'Ordem de Compra enviada para aprovação');
                       --
                       l_create_oc_msg := 'Ordem de Compra criada e enviada para aprovação';
                       --
                    EXCEPTION
                       WHEN OTHERS THEN
                          --
                          l_error := TRUE;
                          --
                          log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                          log_p(l_name,'ERRO: Falha ao chamar a api de aprovação do Workflow ' || SQLERRM);
                          log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                          --
                    END;
                    --
                 ELSE
                    --
                    l_create_oc_msg := 'Ordem de Compra criada e está pendente para ação do Comprador';
                    --
                 END IF; -- IF NOT l_error AND l_send_approval_flag = 'Y'
                 --
                 IF r_ret_cot.ccburlexpneg IS NOT NULL THEN
                   --
                   log_p(l_name,'Criando anexo no cabeçalho da PO com o link do mapa de Cotação');
                   --
                   BEGIN
                     --
                     insert_attachments_po_p(p_po_header_id => l_document_id
                                            ,p_description  => 'Mapa de Cotação'
                                            ,p_url          => r_ret_cot.ccburlexpneg
                                            );
                     --
                   EXCEPTION
                     WHEN OTHERS THEN
                       --
                       l_error := TRUE;
                       --
                       log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                       log_p(l_name,'ERRO: Falha ao chamar a api de aprovação do Workflow ' || SQLERRM);
                       log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                       --
                   END;
                 ELSE
                   log_p(l_name,'Link do mapa de Cotação não dispon?vel para Criação do anexo no cabeçalho da PO.');
                 END IF;
              ELSE
                 --
                 l_create_oc_msg := 'Falha ao criar a Ordem de Compra. Verifique o Log para mais informações';
                 --
                 ROLLBACK;
                 --
              END IF; -- IF l_document_id IS NOT NULL AND l_document_number IS NOT NULL
              --
           END IF; -- IF l_error
           --
           output_p ( p_type           => 'CREATE_PURCHASE_ORDER'
                     ,p_subtype        => 'FOOTER_LINES'
                     ,p_oc             => l_document_number
                     ,p_create_oc_msg  => l_create_oc_msg
                    );
           --
        END IF; --Custom AdecoAgro End
      END LOOP; -- FOR r_ret_cot IN c_ret_cot
      --
      output_p ( p_type           => 'CREATE_PURCHASE_ORDER'
                ,p_subtype        => 'FOOTER'
               );
      --
      log_p(l_name,' ');
      log_p(l_name,'Fim da Criação das Ordens de Compra para o Retorno da Comlink');
      log_p(l_name,' ');
      --
   END;
   --

   --
   -- +=======================================================================+
   -- | Nome: send_purchase_order_p                                           |
   -- |                                                                       |
   -- | Descrição: Procedure responsavel por enviar a ordem de compra para    |
   -- |             Comlink                                                   |
   -- |                                                                       |
   -- | Parametros:                                                           |
   -- |    NA                                                                 |
   -- |                                                                       |
   -- | Retorno:                                                              |
   -- |    NA                                                                 |
   -- +=======================================================================+
   --
   PROCEDURE send_purchase_order_p IS
      --
      l_error           BOOLEAN := FALSE;
      --
      l_name            VARCHAR2(100);
      l_send_oc_msg     VARCHAR2(1000);
      l_pedobs          movped.pedobs%TYPE;
      --
      l_pedid_s         NUMBER;
      l_pedvlrtot       NUMBER;
      l_itmipi          NUMBER;
      l_itmicm          NUMBER;
      l_nExist          NUMBER;
      l_conc_request_id NUMBER;
      --
      CURSOR c_ret_purchase_order IS
         SELECT DISTINCT pha.po_header_id
               ,pha.segment1                                          pednum
               ,SUBSTR(xr.registration_number,1,8)                    empcod
               ,FND_PROFILE.VALUE('XXCLK_CCBCLICOD')                  clicod
               ,xr.registered_name                                    empnom
               ,cffea.document_number                                 empdoc
               ,cffea.ie                                              empinsc
               ,hr1.telephone_number_1                                empfone
               ,hr1.address_line_1 || ' ' || hr1.address_line_2       empend
               ,hr1.postal_code                                       empcep
               ,hr1.town_or_city                                      empcid
               ,hr1.region_2                                          empuf
               ,'J'                                                   emptp
               ,papf.first_name || ' ' || papf.last_name              pedcmp
               ,NULL                                                  peddtalib
               ,pha.creation_date                                     peddtaemi
               ,NULL                                                  peddtaenv
               ,(SELECT MAX(plla.promised_date)
                   FROM po_line_locations_all plla
                  WHERE plla.po_header_id = pha.po_header_id)         pedprzent
               ,flv.lookup_code                                       pedfrm
               ,(SELECT asup.vendor_name
                   FROM ap_suppliers          asup
                      , ap_supplier_sites_all asups
                  WHERE asup.vendor_id = asups.vendor_id
                    AND asups.global_attribute10||asups.global_attribute11||asups.global_attribute12 = LPAD(pha.ship_via_lookup_code,15,'0')
                    AND rownum = 1)                                                  pedtra
               ,NULL                                                  pedhora
               ,'Autorizamos o fornecimento dos materiais e/ou serviços constantes deste pedido de acordo com as condições a seguir estipuladas' pedinfo
               ,NULL                                                  pedapl
               ,pha.comments                                          pedobs
               ,hr1.address_line_1 || ' ' ||
                hr1.address_line_2 || ' - ' ||
                hr1.address_line_3 || ' - ' ||
                hr1.region_1       || ' - ' ||
                hr1.town_or_city   || ' - ' ||
                hr1.region_2       || ' - ' ||
                hr1.postal_code                                       pedcob
               ,NULL                                                  pedapr
               ,apt.name                                              pedcpgto
               ,hr2.address_line_1 || ' ' ||
                hr2.address_line_2 || ' - ' ||
                hr2.address_line_3 || ' - ' ||
                hr2.region_1       || ' - ' ||
                hr2.town_or_city   || ' - ' ||
                hr2.region_2       || ' - ' ||
                hr2.postal_code                                       pedentrega
               ,NULL                                                  pedadiant
               ,NULL                                                  pedstatus
               ,NULL                                                  peddtaapr
               ,0                                                     pedvlrtot -- Valor vai ser atualizado com o valor do Looping das linhas ap?s a leitura de todas
               ,substr(aps.vendor_name,1,40)                          pedvnd
               ,'N'                                                   pedok
               ,pha1.segment1                                         pedcotclinum
               ,pha.ship_via_lookup_code                              tradoc
               ,hr1.region_1                                          empbai
               ,hr1.telephone_number_2                                empfax
               ,papf.email_address                                    empemail
               ,NULL                                                  empalmox
               ,NULL                                                  pedordem
               ,NULL                                                  pedsolic
               ,NULL                                                  pedvlracres
               ,NULL                                                  pedvlrdesco
               ,NULL                                                  pedvlrdespe
               ,NULL                                                  pedvlrfrete
               ,NULL                                                  pedvlricms
               ,NULL                                                  pedvlripi
               -- Vendor
               ,NULL                                                  forcod
               ,DECODE(apssa.global_attribute9,1,regexp_replace(apssa.global_attribute10 || apssa.global_attribute12,'([0-9]{3})([0-9]{3})([0-9]{3})([0-9]{2})','\1.\2.\3-\4')
                                              ,2,regexp_replace(SUBSTR(apssa.global_attribute10,2) || apssa.global_attribute11 || apssa.global_attribute12,'([0-9]{2})([0-9]{3})([0-9]{3})([0-9]{4})([0-9]{2})','\1.\2.\3/\4-\5')) fordoc
               ,apssa.global_attribute14                              forins
               ,DECODE(apssa.global_attribute9,1,'F',2,'J')           pestpp
               ,substr(aps.vendor_name,1,40)                          fornom
               ,SUBSTR(NVL(aps.vendor_name_alt,aps.vendor_name),1,19) fornomres
               ,NULL                                                  tepcod
               ,hz.address1                                           endend
               ,hz.address2                                           endendnro
               ,hz.address3                                           endcmp
               ,substr(hz.address4,1,40)                              endbai
               ,hz.city                                               cidnom
               ,hz.postal_code                                        endcep
               ,hz.state                                              ufcod
               ,apssa.area_code || ' - ' || apssa.phone               endtel1
               ,NULL                                                  endtel2
               ,NULL                                                  endtel3
               ,apssa.fax_area_code || ' - ' || apssa.fax             endfax
               ,NULL                                                  endcxp
               ,apssa.email_address                                   endeml
               ,NULL                                                  endcnt
               ,NULL                                                  forobs
               ,pha1.po_header_id                                     po_header_id_rfq
               ,DECODE(pha.currency_code,'USD','US$','R$')            moesmb
               ,TRUNC(pha.rate,4)                                     rate
           FROM po_headers_all     pha
               ,hr_operating_units hou
               ,xle_registrations  xr
               ,cll_f189_fiscal_entities_all  cffea
               ,hr_locations       hr1
               ,hr_locations       hr2
               ,per_all_people_f   papf
               ,fnd_lookup_values  flv
               ,ap_terms           apt
               ,ap_suppliers       aps
               ,ap_supplier_sites_all apssa
               ,po_headers_all     pha1
               ,po_line_locations_all plla1
               ,hz_locations       hz
          WHERE pha.type_lookup_code         = 'STANDARD' --sgarcia
            AND pha.org_id                   = hou.organization_id
            AND hou.default_legal_context_id = xr.source_id
            AND xr.identifying_flag          = 'Y'
            AND cffea.location_id            = pha.bill_to_location_id
            AND hr1.location_id              = pha.bill_to_location_id
            AND papf.person_id               = pha.agent_id
            AND sysdate BETWEEN papf.effective_start_date AND papf.effective_end_date
            AND flv.meaning                  = pha.freight_terms_lookup_code
            AND flv.lookup_type              = 'CLL_F189_CIF_FOB_FREIGHT'
            AND flv.language                 = 'PTB'
            AND apt.term_id                  = pha.terms_id
            AND aps.vendor_id                = pha.vendor_id
            AND apssa.vendor_id              = aps.vendor_id
            AND apssa.vendor_site_id         = pha.vendor_site_id
            AND apssa.location_id            = hz.location_id
            AND plla1.attribute1             = pha.segment1
            AND plla1.po_header_id           = pha1.po_header_id
            AND plla1.org_id                 = pha.org_id
            AND plla1.attribute2             = 'não'
            AND hr2.location_id              = pha.ship_to_location_id
            AND pha.authorization_status     = 'APPROVED';
      --
      CURSOR c_ret_purchase_order_lin (pc_po_header_id IN NUMBER) IS
         SELECT pla.item_id                   itmnum
               ,pla.line_num                  itmseq
               ,pla.quantity                  itmqtd
               ,muomt.uom_code                itmund
               ,msib.segment1                 itmmatcli
               ,NULL                          itmreq
               ,nvl(msit.description,msit.long_description) || ' - ' || pla.attribute12    itmdescr --custom ADECOAGRO
               ,pla.unit_price                itmvlruni
               ,pla.quantity * pla.unit_price itmvlrtot
               ,0                             itmicm
               ,0                             itmipi
               ,NULL                          itmdesc
               ,NULL                          itmdtaemi
               ,plla.promised_date            itmprzent
               ,NULL                          itmfrm
               ,NULL                          itmtra
               ,NULL                          itmhora
               ,NULL                          itminfo
               ,NULL                          itmapl
               ,NULL                          itmobs
               ,NULL                          itmcob
               ,NULL                          itmapr
               ,NULL                          itmcpgto
               ,NULL                          itmstatus
               ,NULL                          itmitcri
               ,NULL                          itmarm
               ,pla.po_line_id
               ,plla.ship_to_organization_id
               ,plla.ship_to_location_id
               ,hrl.region_2
           FROM po_lines_all            pla
               ,mtl_units_of_measure_tl muomt
               ,po_line_locations_all   plla
               ,hr_locations            hrl
               ,mtl_system_items_b      msib
               ,mtl_system_items_tl     msit
          WHERE pla.po_header_id       = pc_po_header_id
            AND muomt.unit_of_measure  = pla.unit_meas_lookup_code
            AND muomt.language         = 'PTB'
            AND pla.po_line_id         = plla.po_line_id
            AND hrl.location_id        = plla.ship_to_location_id
            AND msib.inventory_item_id = pla.item_id
            AND msib.organization_id   = plla.ship_to_organization_id
            AND msit.inventory_item_id = msib.inventory_item_id
            AND msit.organization_id   = msib.organization_id
            AND msit.language          = 'PTB' ;
      --
   BEGIN
      --
      l_name := 'SEND_PURCHASE_ORDER_P';
      --
      l_conc_request_id := fnd_global.conc_request_id;
      --
      log_p(l_name,' ');
      log_p(l_name,'Iniciando o envio das Ordens de Compra para a Comlink');
      log_p(l_name,' ');
      --
      output_p ( p_type           => 'SEND_PURCHASE_ORDER'
                ,p_subtype        => 'HEADER'
               );
      --
      FOR r_ret_purchase_order IN c_ret_purchase_order LOOP -- FOR r_ret_purchase_order IN c_ret_purchase_order
          --
          BEGIN
            SELECT 1
              INTO l_nExist
              FROM pedccb
             WHERE pednum = r_ret_purchase_order.pednum;
          EXCEPTION
            WHEN OTHERS THEN
              l_nExist := 0;
          END;
          --
          IF l_nExist = 0 THEN
            --
            l_error := FALSE;
            --
            log_p(l_name,'------------------------------------------------');
            log_p(l_name,'Ordem de Compra: ' || r_ret_purchase_order.pednum);
            log_p(l_name,'     Fornecedor: ' || r_ret_purchase_order.pedvnd);
            log_p(l_name,'    Cotação Ref: ' || r_ret_purchase_order.pedcotclinum);
            --
            output_p ( p_type           => 'SEND_PURCHASE_ORDER'
                      ,p_subtype        => 'LINES'
                      ,p_oc             => r_ret_purchase_order.pednum
                      ,p_vendor_name    => r_ret_purchase_order.pedvnd
                      ,p_sdc            => r_ret_purchase_order.pedcotclinum
                      ,p_buyer          => r_ret_purchase_order.pedcmp
                     );
            --
            log_p(l_name,'Executando a inserção na tabela PEDCCB');
            --
            l_pedvlrtot := 0;
            --
            BEGIN
               --
               SELECT xxclk_pedid_s.nextval
                 INTO l_pedid_s
                 FROM dual;
               --
            END;
            --
            l_pedobs := NULL;
            BEGIN
               --
/*               SELECT mped.pedobs
                 INTO l_pedobs
                 FROM po_headers_all           pha
                    , po_lines_all             pla
                    , po_line_locations_all    pll
                    , movccb                   mccb
                    , movped                   mped
                WHERE pha.type_lookup_code         = 'RFQ'
                  AND pha.attribute13              = 'Integração COMLINK'
                  AND pha.po_header_id             = pla.po_header_id
                  AND pla.po_line_id               = pll.po_line_id
                  AND pha.segment1                 = mccb.cotclinum
                  AND mped.cotnum                  = mccb.cotnum
                  AND pll.attribute1               = r_ret_purchase_order.pednum
                  AND rownum                       = 1;*/
               SELECT mped.pedobs
                 INTO l_pedobs
                 FROM po_headers_all           pha
                    , po_lines_all             pla
                    , po_line_locations_all    pll
                    , movccb                   mccb
                    , movped                   mped
                WHERE pha.type_lookup_code         = 'RFQ'
                  AND pha.attribute13              = 'Integração COMLINK'
                  AND pha.po_header_id             = pla.po_header_id
                  AND pla.po_line_id               = pll.po_line_id
                  AND pha.po_header_id             = pll.po_header_id
                  AND pha.segment1                 = mccb.cotclinum
                  AND mped.cotnum                  = mccb.cotnum
                  AND mccb.ccbtipcanc              IS NULL
                  AND pll.attribute1               = r_ret_purchase_order.pednum
                  AND EXISTS (SELECT 1
                                FROM po_line_locations_all plla1
                                    ,ap_supplier_sites_all apssa
                                    ,po_headers_all        pha_oc
                               WHERE plla1.line_location_id = pll.line_location_id
                                 AND plla1.attribute1       = pha_oc.segment1
                                 AND pha_oc.org_id          = pha.org_id
                                 AND apssa.vendor_site_id   = pha_oc.vendor_site_id
                                 AND DECODE(apssa.global_attribute9,1,regexp_replace(apssa.global_attribute10 || apssa.global_attribute12,'([0-9]{3})([0-9]{3})([0-9]{3})([0-9]{2})','\1.\2.\3-\4')
                                                                   ,2,regexp_replace(SUBSTR(apssa.global_attribute10,2) || apssa.global_attribute11 || apssa.global_attribute12,'([0-9]{2})([0-9]{3})([0-9]{3})([0-9]{4})([0-9]{2})','\1.\2.\3/\4-\5')) = mped.doc);
               --
            EXCEPTION
               WHEN OTHERS THEN
                  l_pedobs := NULL;
            END;
            --
            BEGIN
               --
               INSERT INTO pedccb VALUES ( l_pedid_s -- SEQUENCE
                                          ,r_ret_purchase_order.pednum
                                          ,r_ret_purchase_order.empcod
                                          ,r_ret_purchase_order.clicod
                                          ,r_ret_purchase_order.empnom
                                          ,r_ret_purchase_order.empdoc
                                          ,r_ret_purchase_order.empinsc
                                          ,r_ret_purchase_order.empfone
                                          ,r_ret_purchase_order.empend
                                          ,r_ret_purchase_order.empcep
                                          ,r_ret_purchase_order.empcid
                                          ,r_ret_purchase_order.empuf
                                          ,r_ret_purchase_order.emptp
                                          ,r_ret_purchase_order.pedcmp
                                          ,r_ret_purchase_order.peddtalib
                                          ,r_ret_purchase_order.peddtaemi
                                          ,r_ret_purchase_order.peddtaenv
                                          ,r_ret_purchase_order.pedprzent
                                          ,r_ret_purchase_order.pedfrm
                                          ,r_ret_purchase_order.pedtra
                                          ,r_ret_purchase_order.pedhora
                                          ,r_ret_purchase_order.pedinfo
                                          ,r_ret_purchase_order.pedapl
                                          ,r_ret_purchase_order.pedobs || chr(10) || l_pedobs
                                          ,r_ret_purchase_order.pedcob
                                          ,r_ret_purchase_order.pedapr
                                          ,r_ret_purchase_order.pedcpgto
                                          ,r_ret_purchase_order.pedentrega
                                          ,r_ret_purchase_order.pedadiant
                                          ,r_ret_purchase_order.pedstatus
                                          ,r_ret_purchase_order.peddtaapr
                                          ,r_ret_purchase_order.pedvlrtot
                                          ,r_ret_purchase_order.pedvnd
                                          ,r_ret_purchase_order.pedok
                                          ,r_ret_purchase_order.pedcotclinum
                                          ,r_ret_purchase_order.tradoc
                                          ,r_ret_purchase_order.empbai
                                          ,r_ret_purchase_order.empfax
                                          ,r_ret_purchase_order.empemail
                                          ,r_ret_purchase_order.empalmox
                                          ,r_ret_purchase_order.pedordem
                                          ,r_ret_purchase_order.pedsolic
                                          ,r_ret_purchase_order.pedvlracres
                                          ,r_ret_purchase_order.pedvlrdesco
                                          ,r_ret_purchase_order.pedvlrdespe
                                          ,r_ret_purchase_order.pedvlrfrete
                                          ,r_ret_purchase_order.pedvlricms
                                          ,r_ret_purchase_order.pedvlripi
                                          ,r_ret_purchase_order.moesmb);
               --
               log_p(l_name,'Registro inserido com sucesso na tabela PEDCCB');
               --
            EXCEPTION
               WHEN OTHERS THEN
                  --
                  l_error := TRUE;
                  --
                  log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                  log_p(l_name,'ERRO: Insert na tabela PEDCCB não foi realizado ' || SQLERRM);
                  log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                  --
            END;
            --
            log_p(l_name,'Executando a inserção na tabela PEDFOR (Fornecedor do Pedido)');
            --
            BEGIN
               --
               INSERT INTO pedfor VALUES ( l_pedid_s -- SEQUENCE
                                          ,r_ret_purchase_order.forcod
                                          ,r_ret_purchase_order.fordoc
                                          ,r_ret_purchase_order.forins
                                          ,r_ret_purchase_order.pestpp
                                          ,r_ret_purchase_order.fornom
                                          ,r_ret_purchase_order.fornomres
                                          ,r_ret_purchase_order.tepcod
                                          ,r_ret_purchase_order.endend
                                          ,r_ret_purchase_order.endendnro
                                          ,r_ret_purchase_order.endcmp
                                          ,r_ret_purchase_order.endbai
                                          ,r_ret_purchase_order.cidnom
                                          ,r_ret_purchase_order.endcep
                                          ,r_ret_purchase_order.ufcod
                                          ,r_ret_purchase_order.endtel1
                                          ,r_ret_purchase_order.endtel2
                                          ,r_ret_purchase_order.endtel3
                                          ,r_ret_purchase_order.endfax
                                          ,r_ret_purchase_order.endcxp
                                          ,r_ret_purchase_order.endeml
                                          ,r_ret_purchase_order.endcnt
                                          ,r_ret_purchase_order.forobs);
               --
               log_p(l_name,'Registro inserido com sucesso na tabela PEDFOR');
               --
            EXCEPTION
               WHEN OTHERS THEN
                  --
                  l_error := TRUE;
                  --
                  log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                  log_p(l_name,'ERRO: Insert na tabela PEDFOR não foi realizado ' || SQLERRM);
                  log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                  --
            END;
            --
            FOR r_ret_purchase_order_lin IN c_ret_purchase_order_lin (r_ret_purchase_order.po_header_id) LOOP -- FOR c_ret_purchase_order_lin IN c_ret_purchase_order_lin
               --
               log_p(l_name,'      Linha: ' || r_ret_purchase_order_lin.itmseq);
               log_p(l_name,'       Item: ' || r_ret_purchase_order_lin.itmmatcli);
               log_p(l_name,' Quantidade: ' || r_ret_purchase_order_lin.itmqtd);
               --
               output_p ( p_type           => 'SEND_PURCHASE_ORDER'
                         ,p_subtype        => 'LINES_LINES'
                         ,p_line_seq       => r_ret_purchase_order_lin.itmseq
                         ,p_item_segment1  => r_ret_purchase_order_lin.itmmatcli
                         ,p_item_qnt       => r_ret_purchase_order_lin.itmqtd
                        );
               --
               -- Regra para pegar a aliquota do IPI baseado no setup do RI (Nao esta sendo utilizada, porem a regra esta montada)
               log_p(l_name,'Verificando o % do IPI');
               --
               BEGIN
                  --
                  SELECT cffcd.tax_perc
                    INTO l_itmipi
                    FROM po_lines_all                  pla
                        ,po_line_locations_all         plla
                        ,mtl_system_items_b            msib
                        ,mtl_item_categories_v         mic
                        ,cll_f189_fiscal_class         cffc
                        ,cll_f189_fiscal_class_details cffcd
                   WHERE pla.po_line_id               = r_ret_purchase_order_lin.po_line_id
                     AND pla.item_id                  = msib.inventory_item_id
                     AND pla.po_line_id               = plla.po_line_id
                     AND plla.ship_to_organization_id = msib.organization_id
                     AND mic.organization_id          = msib.organization_id
                     AND msib.inventory_item_id       = mic.inventory_item_id
                     AND mic.category_set_name        = 'FISCAL_CLASSIFICATION'
                     AND cffc.classification_code     = mic.category_concat_segs
                     AND cffc.classification_id       = cffcd.classification_id
                     AND cffcd.tax_code               = 'IPI';
                  --
               EXCEPTION
                  WHEN OTHERS THEN
                     l_itmipi := 0;
                     --
                     --l_error := TRUE;
                     --
                     --log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++');
                     --log_p(l_name,'ERRO: Falha ao verificar o % do IPI ' || SQLERRM);
                     --log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++');
                     --
               END;
               --
               -- Regra para pegar a aliquota do ICMS baseado no setup do RI (Nao esta sendo utilizada, porem a regra esta montada)
               log_p(l_name,'Verificando o % do ICMS');
               log_p(l_name,'   Estado Origem: ' || r_ret_purchase_order.ufcod);
               log_p(l_name,'  Estado Destino: ' || r_ret_purchase_order_lin.region_2);
               --
               IF r_ret_purchase_order_lin.region_2 = r_ret_purchase_order.ufcod THEN -- IF r_ret_purchase_order_lin.region_2 = r_ret_purchase_order.ufcod
                  --
                  BEGIN
                     --
                     SELECT cfs.internal_icms_tax
                       INTO l_itmicm
                       FROM cll_f189_states cfs
                      WHERE cfs.state_code = 'SP';
                     --
                  EXCEPTION
                     WHEN OTHERS THEN
                        l_itmicm := 0;
                        --
                        --l_error := TRUE;
                        --
                        --log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++');
                        --log_p(l_name,'ERRO: 01 Falha ao verificar o % do ICMS ' || SQLERRM);
                        --log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++');
                        --
                  END;
                  --
               ELSE -- IF r_ret_purchase_order_lin.region_2 = r_ret_purchase_order.ufcod
                  --
                  BEGIN
                     --
                     SELECT cfsr.icms_tax
                       INTO l_itmicm
                       FROM cll_f189_state_relations cfsr
                           ,cll_f189_states cfs
                           ,cll_f189_states cfs1
                      WHERE cfsr.source_state_id      = cfs.state_id
                        AND cfsr.destination_state_id = cfs1.state_id
                        AND cfs.state_code            = r_ret_purchase_order.ufcod
                        AND cfs1.state_code           = r_ret_purchase_order_lin.region_2;
                     --
                  EXCEPTION
                     WHEN OTHERS THEN
                        l_itmicm := 0;
                        --
                        --l_error := TRUE;
                        --
                        --log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++');
                        --log_p(l_name,'ERRO: 02 Falha ao verificar o % do ICMS ' || SQLERRM);
                        --log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++');
                        --
                  END;
                  --
               END IF; -- IF r_ret_purchase_order_lin.region_2 = r_ret_purchase_order.ufcod
               --
               IF NOT l_error THEN -- IF NOT l_error
                  --
                  log_p(l_name,'Executando a inserção na tabela PEDITM');
                  --
                  BEGIN
                     --
                     INSERT INTO peditm VALUES ( l_pedid_s -- SEQUENCE
                                                ,r_ret_purchase_order_lin.itmnum
                                                ,r_ret_purchase_order_lin.itmseq
                                                ,r_ret_purchase_order_lin.itmqtd
                                                ,r_ret_purchase_order_lin.itmund
                                                ,r_ret_purchase_order_lin.itmmatcli
                                                ,r_ret_purchase_order_lin.itmreq
                                                ,r_ret_purchase_order_lin.itmdescr
                                                ,r_ret_purchase_order_lin.itmvlruni * nvl(r_ret_purchase_order.rate,1)
                                                ,r_ret_purchase_order_lin.itmvlrtot * nvl(r_ret_purchase_order.rate,1)
                                                ,r_ret_purchase_order_lin.itmicm
                                                ,r_ret_purchase_order_lin.itmipi
                                                ,r_ret_purchase_order_lin.itmdesc
                                                ,r_ret_purchase_order_lin.itmdtaemi
                                                ,r_ret_purchase_order_lin.itmprzent
                                                ,r_ret_purchase_order_lin.itmfrm
                                                ,r_ret_purchase_order_lin.itmtra
                                                ,r_ret_purchase_order_lin.itmhora
                                                ,r_ret_purchase_order_lin.itminfo
                                                ,r_ret_purchase_order_lin.itmapl
                                                ,r_ret_purchase_order_lin.itmobs
                                                ,r_ret_purchase_order_lin.itmcob
                                                ,r_ret_purchase_order_lin.itmapr
                                                ,r_ret_purchase_order_lin.itmcpgto
                                                ,r_ret_purchase_order_lin.itmstatus
                                                ,r_ret_purchase_order_lin.itmitcri
                                                ,r_ret_purchase_order_lin.itmarm
                                                ,decode(r_ret_purchase_order.moesmb,'US$',r_ret_purchase_order_lin.itmvlruni,null)
                                                ,decode(r_ret_purchase_order.moesmb,'US$',r_ret_purchase_order_lin.itmvlrtot,null)
                                                );
                     --
                     log_p(l_name,'Registro inserido com sucesso na tabela PEDITM');
                     --
                     l_pedvlrtot := l_pedvlrtot + r_ret_purchase_order_lin.itmvlrtot;
                     --
                  EXCEPTION
                     WHEN OTHERS THEN
                        --
                        l_error := TRUE;
                        --
                        log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                        log_p(l_name,'ERRO: Insert na tabela PEDITM não foi realizado ' || SQLERRM);
                        log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                        --
                  END;
                  --
               END IF; -- IF NOT l_error
               --
            END LOOP; -- FOR c_ret_purchase_order_lin IN c_ret_purchase_order_lin
            --
            IF l_error THEN -- IF l_error
               --
               log_p(l_name,'Falha ao inserir o registro nas tabelas de Pedido da Comlink');
               --
               l_send_oc_msg := 'Falha ao inserir o registro nas tabelas de Pedido da Comlink. Verifique o Log para mais informações';
               --
               ROLLBACK;
               --
            ELSE -- IF l_error
               --
               UPDATE pedccb
                  SET pedvlrtot = l_pedvlrtot
                WHERE pedid     = l_pedid_s;
               --
               UPDATE po_line_locations_all
                  SET attribute2   = 'Sim'
                WHERE line_location_id IN (SELECT pla.from_line_id
                                             FROM po_lines_all pla
                                            WHERE pla.po_header_id = r_ret_purchase_order.po_header_id);

               UPDATE po_headers_all
                  SET attribute12  = attribute12 || ' / ENVIO: ' || l_conc_request_id
                WHERE po_header_id = r_ret_purchase_order.po_header_id
                  AND attribute13  = 'Integração COMLINK';
               --
               log_p(l_name,'Registro inserido com Sucesso nas tabelas de Pedido da Comlink');
               --
               l_send_oc_msg := 'Registro inserido com Sucesso nas tabelas de Pedido da Comlink';
               --
               COMMIT;
               --
            END IF; -- IF l_error
            --
            output_p ( p_type           => 'SEND_PURCHASE_ORDER'
                      ,p_subtype        => 'FOOTER_LINES'
                      ,p_send_oc_msg    => l_send_oc_msg
                     );
          --
          ELSE
            UPDATE po_line_locations_all
               SET attribute2   = 'Sim'
             WHERE line_location_id IN (SELECT pla.from_line_id
                                          FROM po_lines_all pla
                                         WHERE pla.po_header_id = r_ret_purchase_order.po_header_id);
          END IF;
      END LOOP; -- FOR r_ret_purchase_order IN c_ret_purchase_order
      --
      output_p ( p_type           => 'SEND_PURCHASE_ORDER'
                ,p_subtype        => 'FOOTER'
               );
      --
      log_p(l_name,' ');
      log_p(l_name,'Fim do envio das Ordens de Compra para a Comlink');
      log_p(l_name,' ');
      --
   END;
   --

   --
   -- +=======================================================================+
   -- | Nome: release_requisitions_p                                          |
   -- |                                                                       |
   -- | Descrição: Procedure responsavel por liberar as requisições na bancada|
   -- |             do comprador                                              |
   -- |                                                                       |
   -- | Parametros:                                                           |
   -- |    NA                                                                 |
   -- |                                                                       |
   -- | Retorno:                                                              |
   -- |    NA                                                                 |
   -- +=======================================================================+
   --
   PROCEDURE release_requisitions_p IS
      --
      CURSOR c_release_req IS
         SELECT prha.segment1
               ,prla.line_num
               ,prla.requisition_line_id
           FROM po_requisition_lines_all prla
               ,po_req_distributions_all prda
               ,po_requisition_headers_all prha
          WHERE prla.reference_num LIKE 'COMLINK SDC:%'
            AND prda.requisition_line_id = prla.requisition_line_id
            AND prha.requisition_header_id = prla.requisition_header_id
            AND NOT EXISTS (SELECT 1
                              FROM po_distributions_all pda
                             WHERE req_distribution_id = prda.distribution_id)
            --Custom AdecoAgro Inicio
            AND EXISTS (SELECT 1
                          FROM po_distributions_archive_all pdaa
                             , po_line_locations_all        plla
                         WHERE pdaa.req_distribution_id  = prda.distribution_id
                           AND pdaa.po_header_id         = plla.po_header_id
                           AND pdaa.po_line_id           = plla.po_line_id
                           AND pdaa.line_location_id     = plla.line_location_id
                           AND NVL(plla.cancel_flag,'x') = 'Y')
/*            AND NOT EXISTS (SELECT 1
                              FROM po_line_locations_all plla
                                  ,po_headers_all    pha
                             WHERE plla.from_line_id    = prla.requisition_line_id
                               AND pha.po_header_id     = plla.po_header_id
                               AND pha.segment1         = REPLACE(prla.reference_num,'COMLINK SDC: ','')
                               AND pha.type_lookup_code = 'RFQ')*/ --Custom AdecoAgro Fim
                               ;
      --
      CURSOR c_cot_cancelada IS
         SELECT pha.po_header_id
               ,mccb.cotclinum
           FROM po_headers_all        pha
               ,movccb                mccb
               ,hr_operating_units    hou
               ,xle_registrations     xr
          WHERE pha.type_lookup_code         = 'RFQ'
            AND pha.attribute14              = 'Cotação Enviada'
            AND pha.segment1                 = mccb.cotclinum
            AND pha.org_id                   = hou.organization_id
            AND hou.default_legal_context_id = xr.source_id
            AND xr.identifying_flag          = 'Y'
            AND xr.registration_number       = mccb.ccbsisdoc
            AND mccb.ccbtipcanc              = 0;
      --
      CURSOR c_line_cot_cancelada IS
         SELECT plla.line_location_id
               ,mcmt.cmtnomres
               ,mccb.cotclinum
           FROM po_headers_all        pha
               ,movccb                mccb
               ,movcmt                mcmt
               ,hr_operating_units    hou
               ,xle_registrations     xr
               ,po_line_locations_all plla
          WHERE pha.type_lookup_code         = 'RFQ'
            AND pha.attribute14              = 'Cotação Retornada'
            AND pha.segment1                 = mccb.cotclinum
            AND mccb.cotnum                  = mcmt.cotnum
            AND pha.org_id                   = hou.organization_id
            AND hou.default_legal_context_id = xr.source_id
            AND xr.identifying_flag          = 'Y'
            AND xr.registration_number       = mccb.ccbsisdoc
            AND plla.po_header_id            = pha.po_header_id
            AND plla.line_location_id        = mcmt.cmtchavemp
            AND plla.attribute1             <> 'Linha Cancelada'
            AND NOT EXISTS (SELECT 1
                              FROM moventr mentr
                             WHERE mentr.mefordem = mcmt.cmtchavemp
                               AND mentr.cotnum   = mcmt.cotnum);
      --
      CURSOR c_oc_cancelada IS
         SELECT prha.segment1
               ,prla.line_num
               ,prla.requisition_line_id
               ,prla.reference_num
               ,plla.attribute1
           FROM po_requisition_lines_all prla
               ,po_req_distributions_all prda
               ,po_requisition_headers_all prha
               ,po_line_locations_all      plla
               ,po_headers_all             pha
          WHERE prla.reference_num LIKE 'COMLINK SDC:%'
            AND prda.requisition_line_id   =  prla.requisition_line_id
            AND prha.requisition_header_id =  prla.requisition_header_id
            AND plla.from_line_id          =  prla.requisition_line_id
            AND plla.po_header_id          =  pha.po_header_id
            AND pha.attribute14            =  'Cotação Retornada'
            AND plla.attribute1            <> 'Pendente'
            AND EXISTS (SELECT *
                          FROM po_lines_all pla
                         WHERE pla.from_line_id = plla.line_location_id
                           AND pla.cancel_flag = 'Y' );
      --
      l_name          VARCHAR2(100);
      l_release_msg   VARCHAR2(1000);
      --
      l_error         BOOLEAN := FALSE;
      --
   BEGIN
      --
      l_name := 'RELEASE_REQUISITIONS_P';
      --
      log_p(l_name,' ');
      log_p(l_name,'Iniciando o processo de liberação de requisições');
      log_p(l_name,' ');
      --
      FOR r_release_req IN c_release_req LOOP -- FOR r_release_req IN c_release_req
         --
         BEGIN
            --
            UPDATE po_requisition_lines_all
               SET reference_num = null
             WHERE requisition_line_id = r_release_req.requisition_line_id;
            --
            log_p(l_name,'Requisição ' || r_release_req.segment1 || ' Linha: ' || r_release_req.line_num || ' foi liberada para futuras cota??es.');
            --
            l_release_msg := 'Requisição liberada com sucesso.';
            --
         EXCEPTION
            --
            WHEN OTHERS THEN
               --
               l_error := TRUE;
               --
               log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               log_p(l_name,'ERRO: Liberação da Requisição não realizada ' || SQLERRM);
               log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               --
               l_release_msg := 'Requisição não foi liberada. Verifique o Log para mais informações';
               --
         END;
         --
      END LOOP; -- FOR r_release_req IN c_release_req
      --
      FOR r_cot_cancelada IN c_cot_cancelada LOOP -- FOR r_cot_cancelada IN c_cot_cancelada
         --
         log_p(l_name,'Cotação ' || r_cot_cancelada.cotclinum || ' não foi negociada.');
         --
         BEGIN
            --
            UPDATE po_headers_all
               SET attribute14         = 'Cotação Cancelada'
                  ,status_lookup_code  = 'C'
             WHERE po_header_id = r_cot_cancelada.po_header_id;
             --
             log_p(l_name,'Status da Cotação atualizada com sucesso');
             --
         EXCEPTION
            WHEN OTHERS THEN
               --
               l_error := TRUE;
               --
               log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               log_p(l_name,'ERRO: Status da Cotação não foi atualizado - ' || SQLERRM);
               log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               --
               l_release_msg := 'Status da Cotação não foi atualizado. Verifique o Log para mais informações';
               --
         END;
         --
         BEGIN
            --
            UPDATE po_requisition_lines_all
               SET reference_num = null
             WHERE requisition_line_id IN (SELECT plla.from_line_id
                                             FROM po_line_locations_all plla
                                            WHERE plla.po_header_id = r_cot_cancelada.po_header_id);
             --
             log_p(l_name,'requisições liberadas da Cotação: ' || r_cot_cancelada.cotclinum);
             --
         EXCEPTION
            WHEN OTHERS THEN
               --
               l_error := TRUE;
               --
               log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++');
               log_p(l_name,'ERRO: Requisic?es não foram liberadas para a Cotação: ' || r_cot_cancelada.cotclinum || ' - ' || SQLERRM);
               log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++');
               --
               l_release_msg := 'Requisic?es não foram liberadas para a Cotação: ' || r_cot_cancelada.cotclinum || '.Verifique o Log para mais informações';
               --
         END;
         --
      END LOOP; -- FOR r_cot_cancelada IN c_cot_cancelada
      --
      FOR r_line_cot_cancelada IN c_line_cot_cancelada LOOP -- FOR r_line_cot_cancelada IN c_line_cot_cancelada
         --
         log_p(l_name,'Item ' || r_line_cot_cancelada.cmtnomres || ' da Cotação ' || r_line_cot_cancelada.cotclinum || ' não foi negociada.');
         --
         BEGIN
            --
            UPDATE po_line_locations_all
               SET attribute1          = 'Linha Cancelada'
             WHERE line_location_id = r_line_cot_cancelada.line_location_id;
             --
             log_p(l_name,'Status da Linha da Cotação atualizada com sucesso');
             --
         EXCEPTION
            WHEN OTHERS THEN
               --
               l_error := TRUE;
               --
               log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               log_p(l_name,'ERRO: Status da Linha da Cotação não foi atualizado - ' || SQLERRM);
               log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               --
               l_release_msg := 'Status da Linha da Cotação não foi atualizado. Verifique o Log para mais informações';
               --
         END;
         --
         BEGIN
            --
            UPDATE po_requisition_lines_all
               SET reference_num = null
             WHERE requisition_line_id IN (SELECT plla.from_line_id
                                             FROM po_line_locations_all plla
                                            WHERE plla.line_location_id = r_line_cot_cancelada.line_location_id);
             --
             log_p(l_name,'Requisição referente a Linha foi liberada.');
             --
         EXCEPTION
            WHEN OTHERS THEN
               --
               l_error := TRUE;
               --
               log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               log_p(l_name,'ERRO: Requisição referente a Linha não foi liberada. - ' || SQLERRM);
               log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               --
               l_release_msg := 'Requisição referente a Linha não foi liberada.Verifique o Log para mais informações';
               --
         END;
         --
      END LOOP; -- FOR r_line_cot_cancelada IN c_line_cot_cancelada
      --
      FOR r_oc_cancelada IN c_oc_cancelada LOOP -- FOR r_oc_cancelada IN c_oc_cancelada
         --
         log_p(l_name,'Linha da OC ' || r_oc_cancelada.attribute1 || ' foi cancelada.');
         --
         BEGIN
            --
            UPDATE po_requisition_lines_all
               SET reference_num = null
             WHERE requisition_line_id = r_oc_cancelada.requisition_line_id;
             --
             log_p(l_name,'Requisição referente a Linha da OC foi liberada.');
             --
         EXCEPTION
            WHEN OTHERS THEN
               --
               l_error := TRUE;
               --
               log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               log_p(l_name,'ERRO: Requisição referente a Linha não foi liberada. - ' || SQLERRM);
               log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               --
               l_release_msg := 'Requisição referente a Linha da OC não foi liberada. Verifique o Log para mais informações';
               --
         END;
         --
      END LOOP; -- FOR r_oc_cancelada IN c_oc_cancelada
      --
      COMMIT;
      --
   END;
   --

   --
   -- +=======================================================================+
   -- | Nome: create_supplier_p                                               |
   -- |                                                                       |
   -- | Descrição: Procedure responsavel pela Criação de novos fornecedores   |
   -- |             (Fornecedor Publico)                                      |
   -- |                                                                       |
   -- | Parametros:                                                           |
   -- |    p_doc             VARCHAR2 - Documento do fornecedor               |
   -- |    p_org_id          NUMBER   - Org Id                                |
   -- |    x_vendor_id       NUMBER   - Vendor Id Gerado                      |
   -- |    x_vendor_site_id  NUMBER   - Vendor Site Id Gerado                 |
   -- |    x_error           BOOLEAN  - Boleano de Erro                       |
   -- |                                                                       |
   -- | Retorno:                                                              |
   -- |    NA                                                                 |
   -- +=======================================================================+
   --
   PROCEDURE create_supplier_p ( p_doc            IN  VARCHAR2
                                ,p_org_id         IN  NUMBER
                                ,x_vendor_id      OUT NUMBER
                                ,x_vendor_site_id OUT NUMBER
                                ,x_error          OUT BOOLEAN) IS
      --
      l_vendor_rec_type       ap_vendor_pub_pkg.r_vendor_rec_type;
      l_vendor_site_rec_type  ap_vendor_pub_pkg.r_vendor_site_rec_type;
      --
      l_validation_level      NUMBER := FND_API.G_VALID_LEVEL_FULL;
      l_msg_count             NUMBER;
      l_vendor_site_id        NUMBER;
      l_party_site_id         NUMBER;
      l_location_id           NUMBER;
      l_vendor_id             NUMBER;
      l_msg_index_out         NUMBER;
      l_party_id              NUMBER;
      --
      l_cnpjcpf               VARCHAR2(30);
      l_pesinsest             VARCHAR2(50);
      l_endeml                VARCHAR2(50);
      l_enddddtel             VARCHAR2(50);
      l_endtl1                VARCHAR2(50);
      l_name                  VARCHAR2(100);
      l_pesnom                VARCHAR2(100);
      l_pesnomres             VARCHAR2(100);
      l_endcid                VARCHAR2(100);
      l_endend                VARCHAR2(100);
      l_enduf                 VARCHAR2(5);
      l_endcmp                VARCHAR2(100);
      l_endbai                VARCHAR2(100);
      l_endcep                VARCHAR2(15);
      l_pestpp                VARCHAR2(1);
      l_msg_data              VARCHAR2(2000);
      l_return_status         VARCHAR2(2000);
      --
      l_error                 BOOLEAN := FALSE;
      --
   BEGIN
      --
      l_name := 'CREATE_SUPPLIER_P';
      --
      log_p(l_name,' ');
      log_p(l_name,'Iniciando o processo de Criação do fornecedor');
      log_p(l_name,' ');
      --
      log_p(l_name,'Executando a consulta na tabela CADPES');
      --
      BEGIN
         --
         SELECT TRANSLATE(doc,' ./-',' ') doc
               ,pesnom
               ,pesnomres
               ,endcid
               ,REPLACE(endend, ',',' ')
               ,enduf
               ,endcmp
               ,endbai
               ,endcep
               ,pestpp
               ,nvl(REPLACE(pesinsest,'.',''),'ISENTO') pesinsest
               ,endeml
               ,enddddtel
               ,endtl1
           INTO l_cnpjcpf
               ,l_pesnom
               ,l_pesnomres
               ,l_endcid
               ,l_endend
               ,l_enduf
               ,l_endcmp
               ,l_endbai
               ,l_endcep
               ,l_pestpp
               ,l_pesinsest
               ,l_endeml
               ,l_enddddtel
               ,l_endtl1
           FROM cadpes
          WHERE doc = p_doc;
         --
      EXCEPTION
         WHEN OTHERS THEN
            --
            l_error := TRUE;
            --
            log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
            log_p(l_name,'ERRO: Falha ao executar a consulta na tabela CADPES ' || SQLERRM);
            log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
            --
      END;
      --
      log_p(l_name,'Verificando se o Fornecedor já existe');
      --
      BEGIN
         --
         SELECT vendor_id
           INTO l_vendor_id
           FROM ap_suppliers
          WHERE segment1 = SUBSTR(l_cnpjcpf,1,8);
         --
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            --
            l_vendor_id := 0;
            --
         WHEN OTHERS THEN
            --
            l_error := TRUE;
            --
            log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
            log_p(l_name,'ERRO: Falha ao verificar se o fornecedor já existe ' || SQLERRM);
            log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
            --
      END;
      --
      IF l_vendor_id = 0 THEN  -- IF l_vendor_id = 0
         --
         log_p(l_name,'Setando os valores para o vendor record');
         --
         BEGIN
            --
            l_vendor_rec_type.segment1                           := SUBSTR(l_cnpjcpf,1,8);
            l_vendor_rec_type.vendor_name                        := l_pesnom;
            l_vendor_rec_type.vendor_type_lookup_code            := 'VENDOR';
            l_vendor_rec_type.vendor_name_alt                    := l_pesnomres;
            --
         EXCEPTION
            WHEN OTHERS THEN
               --
               l_error := TRUE;
               --
               log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               log_p(l_name,'ERRO: Falha ao setar os valores para o vendor record ' || SQLERRM);
               log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               --
         END;
         --
         IF NOT l_error THEN -- IF NOT l_error
            --
            log_p(l_name,'Chamando a API para Criação do fornecedor');
            --
            BEGIN
               --
               ap_vendor_pub_pkg.create_vendor ( p_api_version      => 1.0
                                                ,p_init_msg_list    => 'T'
                                                ,p_commit           => 'F'
                                                ,p_validation_level => l_validation_level
                                                ,p_vendor_rec       => l_vendor_rec_type
                                                ,x_return_status    => l_return_status
                                                ,x_msg_count        => l_msg_count
                                                ,x_msg_data         => l_msg_data
                                                ,x_vendor_id        => l_vendor_id
                                                ,x_party_id         => l_party_id
                                               );
               --
            EXCEPTION
               WHEN OTHERS THEN
                  --
                  l_error := TRUE;
                  --
                  log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                  log_p(l_name,'ERRO: Falha chamar a API para Criação do fornecedor ' || SQLERRM);
                  log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                  --
            END;
            --
            IF l_return_status <> 'S' AND l_return_status IS NOT NULL THEN -- IF l_return_status <> 'S' AND l_return_status IS NOT NULL
               --
               fnd_msg_pub.get(p_msg_index => 1, p_encoded => 'F', p_data => l_msg_data, p_msg_index_out => l_msg_index_out);
               --
               log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               log_p(l_name,'ERRO: Falha no retorno da API (' || l_msg_count || ')' ||' - ' || l_msg_data );
               log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               --
               l_error := TRUE;
               --
            ELSE -- IF l_return_status <> 'S' AND l_return_status IS NOT NULL
               --
               log_p(l_name,'Fornecedor criado com sucesso. Vendor Id: ' || l_vendor_id);
               --
            END IF; -- IF l_return_status <> 'S' AND l_return_status IS NOT NULL
            --
         END IF; -- IF NOT l_error
         --
      END IF; -- IF l_vendor_id = 0
      --
      IF l_vendor_id > 0 AND NOT l_error THEN -- IF l_vendor_id > 0 AND NOT l_error
         --
         log_p(l_name,'Setando os valores para o vendor site record');
         --
         BEGIN
            --
            l_vendor_site_rec_type.vendor_id                            := l_vendor_id;
            l_vendor_site_rec_type.vendor_site_code                     := SUBSTR(l_cnpjcpf,9,6);
            l_vendor_site_rec_type.org_id                               := p_org_id;
            l_vendor_site_rec_type.address_style                        := 'BR';
            l_vendor_site_rec_type.country                              := 'BR';
            l_vendor_site_rec_type.city                                 := l_endcid;
            l_vendor_site_rec_type.address_line1                        := TRIM(REGEXP_REPLACE(l_endend ,'[0-9]*+$','' ));
            l_vendor_site_rec_type.address_line2                        := TRIM(REGEXP_SUBSTR(l_endend ,'[0-9]*+$'));
            l_vendor_site_rec_type.address_line3                        := l_endcmp;
            l_vendor_site_rec_type.address_line4                        := l_endbai;
            l_vendor_site_rec_type.state                                := l_enduf;
            l_vendor_site_rec_type.zip                                  := REPLACE(l_endcep,'-','');
            l_vendor_site_rec_type.purchasing_site_flag                 := 'Y';
            l_vendor_site_rec_type.email_address                        := l_endeml;
            l_vendor_site_rec_type.area_code                            := l_enddddtel;
            l_vendor_site_rec_type.phone                                := l_endtl1;
            --
            IF (l_pestpp = 'J') THEN
               --
               l_vendor_site_rec_type.global_attribute9                 := '2';
               l_vendor_site_rec_type.global_attribute10                := '0' || SUBSTR(l_cnpjcpf,1,8);
               l_vendor_site_rec_type.global_attribute11                := SUBSTR(l_cnpjcpf,9,4);
               l_vendor_site_rec_type.global_attribute12                := SUBSTR(l_cnpjcpf,13,2);
               l_vendor_site_rec_type.global_attribute13                := l_pesinsest;
               --
            ELSIF (l_pestpp = 'F') THEN
               --
               l_vendor_site_rec_type.global_attribute9                 := '1';
               l_vendor_site_rec_type.global_attribute10                := SUBSTR(l_cnpjcpf,1,9);
               l_vendor_site_rec_type.global_attribute11                := '0000';
               l_vendor_site_rec_type.global_attribute12                := SUBSTR(l_cnpjcpf,10,2);
               l_vendor_site_rec_type.global_attribute13                := l_pesinsest;
               --
            END IF;
            --
         EXCEPTION
            WHEN OTHERS THEN
               --
               l_error := TRUE;
               --
               log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               log_p(l_name,'ERRO: Falha ao setar os valores para o vendor site record ' || SQLERRM);
               log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               --
         END;
         --
         IF NOT l_error THEN -- IF NOT l_error
            --
            log_p(l_name,'Chamando a API para Criação do site do fornecedor');
            --
            BEGIN
               --
               ap_vendor_pub_pkg.create_vendor_site ( p_api_version        => 1.0
                                                     ,p_init_msg_list      => 'T'
                                                     ,p_commit             => 'F'
                                                     ,p_validation_level   => l_validation_level
                                                     ,p_vendor_site_rec    => l_vendor_site_rec_type
                                                     ,x_return_status      => l_return_status
                                                     ,x_msg_count          => l_msg_count
                                                     ,x_msg_data           => l_msg_data
                                                     ,x_vendor_site_id     => l_vendor_site_id
                                                     ,x_party_site_id      => l_party_site_id
                                                     ,x_location_id        => l_location_id
                                                     );
            EXCEPTION
               WHEN OTHERS THEN
                  --
                  l_error := TRUE;
                  --
                  log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                  log_p(l_name,'ERRO: Falha chamar a API para Criação do site do fornecedor ' || SQLERRM);
                  log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                  --
            END;
            --
            IF l_return_status <> 'S' AND l_return_status IS NOT NULL THEN -- IF l_return_status <> 'S' AND l_return_status IS NOT NULL
               --
               fnd_msg_pub.get(p_msg_index => 1, p_encoded => 'F', p_data => l_msg_data, p_msg_index_out => l_msg_index_out);
               --
               log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               log_p(l_name,'ERRO: Falha no retorno da API (' || l_msg_count || ')' ||' - ' || l_msg_data );
               log_p(l_name,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               --
               l_error := TRUE;
               --
            ELSE -- IF l_return_status <> 'S' AND l_return_status IS NOT NULL
               --
               log_p(l_name,'Site do Fornecedor criado com sucesso. Vendor Site Id: ' || l_vendor_site_id);
               --
            END IF; -- IF l_return_status <> 'S' AND l_return_status IS NOT NULL
            --
         END IF; -- IF NOT l_error
         --
      END IF; -- IF l_vendor_id > 0 AND NOT l_error
      --
      x_error          := l_error;
      x_vendor_id      := l_vendor_id;
      x_vendor_site_id := l_vendor_site_id;
      --
   END;
   --

   --
   -- +=======================================================================+
   -- | Nome: set_rfq_attributes                                              |
   -- |                                                                       |
   -- | Descrição: Fun??o para attribuir valores nos atributes da SDC         |
   -- |                                                                       |
   -- | Parametros:                                                           |
   -- |    p_header_id         NUMBER - Id da SDC                             |
   -- |                                                                       |
   -- | Retorno:                                                              |
   -- |    N/A                                                                |
   -- +=======================================================================+
   --
   PROCEDURE set_rfq_attributes_f (p_header_id IN NUMBER) IS
      --
      l_error        BOOLEAN := FALSE;
      --
      l_error_msg           VARCHAR2(1000);
      l_return_msg          VARCHAR2(1000);
      l_attribute_category  VARCHAR2(1000);
      --
      l_from_line_id NUMBER;
      l_segment1     NUMBER;
      --
   BEGIN
      --
      BEGIN
         --
         SELECT pha.segment1
               ,pha.attribute13
           INTO l_segment1
               ,l_attribute_category
           FROM po_headers_all pha
          WHERE pha.po_header_id  = p_header_id;
         --
      EXCEPTION
         WHEN OTHERS THEN
            --
            l_error     := TRUE;
            --
            l_error_msg := '00 - ' || SQLERRM;
            --
      END;
      --
      IF l_attribute_category != 'Integração COMLINK' OR l_attribute_category IS NULL THEN -- IF l_attribute_category != 'Integração COMLINK'
         --
         BEGIN
            --
            UPDATE po_headers_all
               SET attribute_category = 'BR'
                  ,attribute13        = 'Integração COMLINK'
                  ,attribute14        = 'Pendente'
             WHERE po_header_id       = p_header_id;
            --
         EXCEPTION
            WHEN OTHERS THEN
               --
               l_error     := TRUE;
               --
               l_error_msg := '01 - ' || SQLERRM;
               --
         END;
         --
      END IF; -- IF l_attribute_category != 'Integração COMLINK'
      --
      FOR r_rfq_lines IN (SELECT plla.line_location_id
                            FROM po_line_locations_all plla
                           WHERE plla.po_header_id = p_header_id
                             AND (  plla.attribute_category IS NULL
                                 OR plla.attribute_category <> 'Integração COMLINK')) LOOP
         --
         BEGIN
            --
            SELECT rla.requisition_line_id
              INTO l_from_line_id
              FROM po_requisition_headers_all rha
                  ,po_requisition_lines_all   rla
                  ,po_headers_all             pha
                  ,po_lines_all               pla
                  ,po_line_locations_all      plla
                  ,hr_locations               hr
             WHERE rha.requisition_header_id = rla.requisition_header_id
               AND rla.last_update_date      = plla.creation_date
               AND pla.po_header_id          = pha.po_header_id
               AND rla.on_rfq_flag           = 'Y'
               AND rla.item_id               = pla.item_id
               AND pla.po_line_id            = plla.po_line_id
               AND pha.po_header_id          = plla.po_header_id
               AND plla.ship_to_location_id  = hr.ship_to_location_id
               AND hr.location_id            = rla.deliver_to_location_id
               AND plla.line_location_id     = r_rfq_lines.line_location_id
               AND plla.quantity             = rla.quantity
               AND rla.reference_num         IS NULL
               AND ROWNUM                   = 1; -- Necesario para casos de linhas de requisições diferentes com mesmo item, quantidade e entrega
            --
         EXCEPTION
            WHEN OTHERS THEN
               --
               l_error     := TRUE;
               --
               l_error_msg := '02 - ' || SQLERRM;
               --
         END;
         --
         BEGIN
            --
            UPDATE po_line_locations_all
               SET from_line_id     = l_from_line_id
                  ,attribute_category = 'Integração COMLINK'
                  ,attribute1         = 'Pendente'
                  ,attribute2         = 'não'
             WHERE line_location_id = r_rfq_lines.line_location_id;
            --
         EXCEPTION
            WHEN OTHERS THEN
               --
               l_error     := TRUE;
               --
               l_error_msg := '03 - ' || SQLERRM;
               --
         END;
         --
         BEGIN
            --
            UPDATE po_requisition_lines_all
               SET reference_num       = 'COMLINK SDC: ' || l_segment1
             WHERE requisition_line_id = l_from_line_id;
            --
         EXCEPTION
            WHEN OTHERS THEN
               --
               l_error := TRUE;
               --
               l_error_msg := '04 - ' || SQLERRM;
               --
         END;
         --
      END LOOP;
      --
      IF l_error THEN -- IF l_error
         --
         l_return_msg := 'Falha ao criar a SDC: ' || l_segment1 || ' [' ||  l_error_msg || ']';
         --
         ROLLBACK;
         --
      ELSIF NOT l_error THEN -- IF l_error
         --
         l_return_msg := 'SDC: ' || l_segment1 || ' criada com sucesso.';
         --
         COMMIT;
         --
      END IF; -- IF l_error
      --
   END;
   --

   --
   -- +=======================================================================+
   -- | Nome: send_terms_p                                                    |
   -- |                                                                       |
   -- | Descrição: Procedure para enviar o cadastro com termos de pagamento   |
   -- |                                                                       |
   -- | Parametros:                                                           |
   -- |    N/A                                                                |
   -- |                                                                       |
   -- | Retorno:                                                              |
   -- |    N/A                                                                |
   -- +=======================================================================+
   --
   PROCEDURE send_terms_p IS
      --
      l_name        VARCHAR2(100);
      --
      l_error       BOOLEAN;
      --
      l_count_lines NUMBER;
      --
      CURSOR c_terms IS
         SELECT atl.term_id                     cpgtocod
               ,nvl(atl.description,atl.name)   cpgtodesc
               ,SUBSTR(atl.name,1,12)           cpgtodescr
               ,atl.name
           FROM ap_terms_tl atl
          WHERE atl.language = 'PTB'
            AND atl.end_date_active IS NULL
            AND NOT EXISTS (SELECT 1
                              FROM cadcpgto
                             WHERE cpgtocod =  atl.term_id)
            AND EXISTS (SELECT 1
                          FROM ap_terms_lines atl2
                         WHERE atl2.term_id = atl.term_id
                           AND (atl2.calendar  IS NOT NULL
                             OR atl2.due_days  IS NOT NULL));
      --
      CURSOR c_terms_lines (pc_term_id NUMBER) IS
         SELECT atl.sequence_num                               cadparccod
               ,NVL(atl.due_days, aop.due_date - aop.end_date) cadparcdia
               ,atl.due_percent                                cadparcporc
           FROM ap_terms_lines   atl
               ,ap_other_periods aop
          WHERE atl.term_id    = pc_term_id
            AND aop.module (+) = 'PAYMENT TERMS'
            AND atl.calendar   = aop.period_type (+)
            AND SYSDATE BETWEEN aop.start_date  (+)
                            AND aop.end_date    (+)
       ORDER BY atl.sequence_num;
      --
   BEGIN
      --
      l_name := 'SEND_TERMS_P';
      --
      log_p(l_name,' ');
      log_p(l_name,'Iniciando o processo de Criação do termo de pagamento no Comlink');
      log_p(l_name,' ');
      --
      FOR r_terms IN c_terms LOOP -- FOR r_terms IN c_terms
         --
         l_error := FALSE;
         --
         log_p(l_name,'----');
         log_p(l_name,' Termo: ' || r_terms.name);
         --
         log_p(l_name,'Executando a inserção na tabela CADCPGTO');
         --
         BEGIN
            --
            INSERT INTO cadcpgto VALUES ( r_terms.cpgtocod
                                         ,r_terms.cpgtodesc
                                         ,r_terms.cpgtodescr
                                         ,r_terms.cpgtocod
                                         ,NULL
                                         );
            --
            log_p(l_name,'Registro inserido com sucesso na tabela CADCPGTO');
            --
         EXCEPTION
            WHEN OTHERS THEN
               --
               l_error := TRUE;
               --
               log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               log_p(l_name,'ERRO: Insert na tabela CADCPGTO não foi realizado ' || SQLERRM);
               log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               --
         END;
         --
         l_count_lines := 0;
         --
         FOR r_terms_lines IN c_terms_lines(r_terms.cpgtocod) LOOP -- FOR r_terms_lines IN c_terms_lines(r_terms.cpgtocod)
            --
            l_count_lines := l_count_lines + 1;
            --
            log_p(l_name,'Executando a inserção na tabela CADPARC');
            --
            log_p(l_name,'  Sequencia: ' || r_terms_lines.cadparccod);
            --
            BEGIN
               --
               INSERT INTO cadparc VALUES ( r_terms.cpgtocod
                                           ,r_terms_lines.cadparccod
                                           ,r_terms_lines.cadparcdia
                                           ,r_terms_lines.cadparcporc
                                           ,NULL
                                           );
               --
               log_p(l_name,'Registro inserido com sucesso na tabela CADPARC');
               --
            EXCEPTION
               WHEN OTHERS THEN
                  --
                  l_error := TRUE;
                  --
                  log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                  log_p(l_name,'ERRO: Insert na tabela CADCPGTO não foi realizado ' || SQLERRM);
                  log_p(l_name,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                  --
            END;
            --
         END LOOP; -- FOR r_terms_lines IN c_terms_lines(r_terms.cpgtocod)
         --
         IF l_count_lines = 0 THEN -- IF l_count_lines = 0
            --
            log_p(l_name,'não possui dados de linha para este termo');
            --
            ROLLBACK;
            --
         END IF; -- IF l_count_lines = 0
         --
         IF l_error THEN -- IF l_error
            --
            log_p(l_name,'Falha ao inserir o registro nas tabelas do Comlink');
            --
            ROLLBACK;
            --
         ELSE -- IF l_error
            --
            log_p(l_name,'Registro inserido com Sucesso nas tabelas da Comlink');
            --
            COMMIT;
            --
         END IF; -- IF l_error
         --
      END LOOP; -- FOR r_terms IN c_terms
      --
   END;
   --
END XXCLK_PO_INTERFACE_PKG;
/
END;
