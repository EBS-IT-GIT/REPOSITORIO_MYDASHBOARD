CREATE OR REPLACE PACKAGE APPS."XX_INV_RESUMEN_TRX_PKG"
IS
   PROCEDURE main ( errbuf                     OUT      VARCHAR2
                  , retcode                    OUT      VARCHAR2
                  , p_org_id                   IN       NUMBER
                  , p_organization_id          IN       NUMBER
                  , p_subinventory_code        IN       VARCHAR2
                  , p_locator_id               IN       NUMBER
                  , p_period_name_from         IN       VARCHAR2                                      -- amanukyan 20180130 issue 131
                  , p_period_name_to           IN       VARCHAR2                                      -- amanukyan 20180130 issue 131
                  , p_cat_gl                   IN       NUMBER
                  , p_item_id                  IN       NUMBER
                  , p_lote_desde               IN       VARCHAR2
                  , p_lote_hasta               IN       VARCHAR2 --SD1119
                  , p_source_carta_porte       IN       VARCHAR2                       --amanukyan 20180205 issue 140 cartas de porte
                  , p_stock_init_flag          IN       VARCHAR2                         -- issue 159 amanukyan  mejora stock inicial
                 );


   FUNCTION get_productor ( p_tipo_doc         IN VARCHAR2
                          , p_carta_porte_id   IN NUMBER
                          ) RETURN VARCHAR2;


   FUNCTION get_nro_contrato ( p_tipo_doc        IN VARCHAR2
                             , p_party_id_le     IN NUMBER
                             , p_carta_porte_id  IN NUMBER
                             ) RETURN VARCHAR2;


   FUNCTION get_transferido_flag ( p_tipo_doc        IN VARCHAR2
                                 , p_carta_porte_id  IN NUMBER
                                 ) RETURN VARCHAR2;


   FUNCTION get_recibido_flag (  p_tipo_doc         IN  VARCHAR2
                              , p_carta_porte_id    IN  NUMBER
                              ) RETURN VARCHAR2;


   FUNCTION get_cmv ( p_tipo_doc         IN  VARCHAR2
                    , p_org_id           IN  NUMBER
                    , p_carta_porte_id   IN  NUMBER
                   ) RETURN VARCHAR2;


END xx_inv_resumen_trx_pkg;
/

