  set define off;

  CREATE OR REPLACE PACKAGE "APPS"."XX_TCG_FUNCTIONS_PKG" AS

TYPE trOrgInfo IS RECORD
     ( operating_unit                   org_organization_definitions.operating_unit%type
     , operating_unit_name              hr_operating_units.name%type
     , operating_unit_cuit              xx_tcg_parametros_compania.operating_unit_cuit%type
     , legal_entity                     org_organization_definitions.legal_entity%type
     , set_of_books_id                  org_organization_definitions.set_of_books_id%type
     , chart_of_accounts_id             org_organization_definitions.chart_of_accounts_id%type
     , organization_id                  org_organization_definitions.organization_id%type
     , organization_code                org_organization_definitions.organization_code%type
     , organization_name                org_organization_definitions.organization_name%type
     , location_id                      hr_organization_units.location_id%type
     , secondary_inventory_name         mtl_secondary_inventories.secondary_inventory_name%type
     , secondary_inventory_desc         mtl_secondary_inventories.description%type
     , secondary_inventory_type         mtl_secondary_inventories_dfv.xx_tcg_tipos%type
     , secondary_inventory_vendor       mtl_secondary_inventories_dfv.xx_tcg_empresa%type
     , secondary_inventory_oncca        mtl_secondary_inventories_dfv.xx_tcg_especie_oncca%type
     , establecimiento_id               xx_opm_establecimientos.establecimiento_id%type
     , xx_tcg_establecimientos          mtl_secondary_inventories_dfv.xx_tcg_establecimientos%type
     );


  c_main_cursor_stmt VARCHAR2(4000) :=
  'SELECT od.operating_unit '||chr(10)
||'     , opu.name operating_unit_name '||chr(10)
||'     , pc.operating_unit_cuit '||chr(10)
||'     , od.legal_entity, od.set_of_books_id, od.chart_of_accounts_id '||chr(10)
||'     , od.organization_id, od.organization_code, od.organization_name '||chr(10)
||'     , ou.location_id '||chr(10)
||'     , msi.secondary_inventory_name '||chr(10)
||'     , msi.description secondary_inventory_desc '||chr(10)
||'     , msi_dfv.xx_tcg_tipos secondary_inventory_type '||chr(10)
||'     , msi_dfv.xx_tcg_empresa       secondary_inventory_vendor '||chr(10)
||'     , msi_dfv.xx_tcg_especie_oncca secondary_inventory_oncca '||chr(10)
||'     , est.establecimiento_id '||chr(10)
||'     , est.campo establecimiento '||chr(10)
||'FROM org_organization_definitions   od '||chr(10)
||'   , hr_operating_units             opu '||chr(10)
||'   , xx_tcg_parametros_compania     pc '||chr(10)
||'   , hr_organization_units          ou '||chr(10)
||'   , mtl_secondary_inventories      msi '||chr(10)
||'   , mtl_secondary_inventories_dfv  msi_dfv '||chr(10)
||'   , xx_opm_establecimientos        est '||chr(10)
||'WHERE 1=1 '||chr(10)
||'AND opu.organization_id = od.operating_unit '||chr(10)
||'AND pc.operating_unit(+) = od.operating_unit '||chr(10)
||'AND ou.organization_id  = od.organization_id '||chr(10)
||'AND msi.organization_id = od.organization_id '||chr(10)
||'AND msi_dfv.source_type(+) = msi.attribute_category '||chr(10)
||'AND msi_dfv.row_id(+)      = msi.rowid '||chr(10)
||'AND est.establecimiento_id(+) = msi_dfv.xx_tcg_establecimientos '||chr(10)
||'AND ( od.disable_date IS NULL OR od.disable_date > SYSDATE ) '||chr(10);


  FUNCTION getMainCursor RETURN VARCHAR2;


  FUNCTION getOrgName ( p_organization_id NUMBER ) RETURN VARCHAR2;


  FUNCTION getEstabName ( p_establecimiento_id NUMBER ) RETURN VARCHAR2;


  FUNCTION getMasterOrg RETURN VARCHAR2;

  FUNCTION Valida_Acceso_Org ( p_user_id  NUMBER
                             , p_org_id   NUMBER
                             ) RETURN BOOLEAN;

  FUNCTION Valida_Acceso_Org_c ( p_user_id  NUMBER
                               , p_org_id   NUMBER
                               ) RETURN VARCHAR2;

/****************************************************************************
 *                                                                          *
 * Name    : Es_Empresa_Grupo                                               *
 * Purpose : Retorna verdadero si el cuit esta dentro de                    *
 *           xx_tcg_parametros_compania                                     *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Es_Empresa_Grupo (p_cuit NUMBER) RETURN BOOLEAN;


/****************************************************************************
 *                                                                          *
 * Name    : Es_Empresa_Grupo                                               *
 * Purpose : Retorna Y si el cuit esta dentro de xx_tcg_parametros_compania *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Es_Empresa_Grupo_c (p_cuit NUMBER) RETURN VARCHAR2;


/****************************************************************************
 *                                                                          *
 * Name    : Obtener_CUIT                                                   *
 * Purpose : Retorna el CUIT correspondiente al party_id                    *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Obtener_CUIT (p_party_id NUMBER) RETURN NUMBER;


/****************************************************************************
 *                                                                          *
 * Name    : Valida_CUIT                                                    *
 * Purpose : Validar si el cuit es valido                                   *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Valida_CUIT ( p_cuit VARCHAR2
                       , p_msg  OUT VARCHAR2
                       ) RETURN BOOLEAN;


/***************************************************************************
 *                                                                          *
 * Name    : Valida_CUIT_DDBB                                               *
 * Purpose : Valida que el CUIT ingresado encuentre en como partie          *
 *                                                                          *
 ****************************************************************************/
  PROCEDURE Valida_CUIT_DDBB ( p_cuit              VARCHAR2
                             , p_country           VARCHAR2
                             , x_party_id   IN OUT NUMBER
                             , x_party_name IN OUT VARCHAR2
                             );


/***************************************************************************
 *                                                                          *
 * Name    : Valida_CUIT_DDBB                                               *
 * Purpose : Valida que el CUIT ingresado encuentre en como partie          *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Valida_CUIT_DDBB ( p_cuit VARCHAR2 ) RETURN BOOLEAN;


/***************************************************************************
 *                                                                          *
 * Name    : CUIT_Party_ID                                                  *
 * Purpose : Devuelve el Party_ID de un determinado CUIT                    *
 *                                                                          *
 ****************************************************************************/
  FUNCTION CUIT_Party_ID ( p_cuit    VARCHAR2
                         , p_country VARCHAR2 DEFAULT 'AR'
                         ) RETURN NUMBER;


/***************************************************************************
 *                                                                          *
 * Name    : CUIT_OPERATING_UNIT                                            *
 * Purpose : Devuelve la unidad operativa de un CUIT si es empresa de grupo *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Cuit_Operating_Unit ( p_cuit VARCHAR2 ) RETURN NUMBER;


/***************************************************************************
 *                                                                          *
 * Name    : OPERATING_UNIT_CUIT                                            *
 * Purpose : Devuelve el CUIT de una unidad operativa si es empresa de grupo *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Operating_Unit_CUIT ( p_operating_unit NUMBER ) RETURN NUMBER;


/***************************************************************************
 *                                                                          *
 * Name    : OU_PARTY_NAME                                                  *
 * Purpose : Devuelve el Party Name de una Unidad Operativa                 *
 *                                                                          *
 ****************************************************************************/
  FUNCTION OU_Party_Name ( p_ou NUMBER ) RETURN VARCHAR2;


/***************************************************************************
 *                                                                          *
 * Name    : OU_PARTY_ID                                                    *
 * Purpose : Devuelve el Party ID de una Unidad Operativa                   *
 *                                                                          *
 ****************************************************************************/
  FUNCTION OU_Party_ID ( p_ou NUMBER ) RETURN NUMBER;


/***************************************************************************
 *                                                                          *
 * Name    : Valida_Estab_OU                                                *
 * Purpose : Valida que el establecimiento pertenezca a la unidad operativa *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Valida_Estab_OU ( p_operating_unit_cuit VARCHAR2
                           , p_establecimiento_id  NUMBER
                           ) RETURN NUMBER;


/***************************************************************************
 *                                                                          *
 * Name    : Valida_Estab_Pesaje                                            *
 * Purpose : Valida que el establecimiento tenga balanza asociada           *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Valida_Estab_Pesaje ( p_establecimiento_id  NUMBER ) RETURN NUMBER;


/***************************************************************************
 *                                                                          *
 * Name    : Valida_Estab_Pesaje_Org                                        *
 * Purpose : Valida que el establecimiento pertenezca a la unidad operativa *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Valida_Estab_Pesaje_Org ( p_organization_id     NUMBER
                                   , p_establecimiento_id  NUMBER
                                   , p_viaje_id            NUMBER DEFAULT NULL
                                   ) RETURN NUMBER;


/***************************************************************************
 *                                                                          *
 * Name    : Valida_Peso_Maximo                                             *
 * Purpose : Valida_Peso_Maximo                                             *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Valida_Peso_Maximo ( p_item_name     VARCHAR2
                              , p_weight        NUMBER
                              , p_ou            VARCHAR2
                              , p_mode_of_trans VARCHAR2
                              , x_msg       OUT VARCHAR2 ) RETURN BOOLEAN;


/***************************************************************************
 *                                                                          *
 * Name    : Valida_SubInv_Estab                                            *
 * Purpose : Valida el subinventario pertenezca al establecimiento          *
 *           y unidad operativa                                             *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Valida_SubInv_Estab ( p_operating_unit      NUMBER
                               , p_establecimiento_id  NUMBER
                               , p_subinv_name         VARCHAR2
                               ) RETURN VARCHAR2;


/***************************************************************************
 *                                                                          *
 * Name    : Proveedor_Reac                                                 *
 * Purpose :VERDADERO si la clasificacion del proveedor es REACONDICIONADOR *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Proveedor_Reac ( p_party_id  NUMBER ) RETURN VARCHAR2;


/***************************************************************************
 *                                                                          *
 * Name    : Valida_Contrato_Compra                                         *
 * Purpose :Valida que el contrato sea valido para los intervinientes       *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Valida_Contrato_Compra ( p_titular_cp_id         NUMBER
                                  , p_titular_cp_tipo       VARCHAR2
                                  , p_titular_cp_site_id    NUMBER
                                  , p_intermediario_id      NUMBER
                                  , p_intermediario_tipo    VARCHAR2
                                  , p_intermediario_retiro  VARCHAR2
                                  , p_rtte_comercial_id     NUMBER
                                  , p_rtte_comercial_tipo   VARCHAR2
                                  , p_rtte_comercial_retiro VARCHAR2
                                  , p_destinatario_id       NUMBER
                                  , p_destino_id            NUMBER
                                  , p_destino_site_id       NUMBER
                                  , p_destino_zona          VARCHAR2
                                  --
                                  , p_contrato_id           NUMBER
                                  , p_item_id               NUMBER
                                  , p_lot_no                VARCHAR2
                                  , p_fecha_recepcion       DATE
                                  , p_interviniente         VARCHAR2
                                  ) RETURN NUMBER;


/****************************************************************************
 *                                                                          *
 * Name    : Contratos_Compra_boletin                                       *
 * Purpose :Valida que el contrato sea valido para el boletin de calidad    *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Contratos_Compra_boletin ( p_titular_cp_cuit       NUMBER
                                    , p_titular_cp_estab_id   NUMBER
                                    , p_provincia_origen      VARCHAR2
                                    , p_localidad_origen      VARCHAR2
                                    , p_destino_cuit          NUMBER
                                    , p_destino_estab_id      NUMBER
                                    , p_provincia_destino     VARCHAR2
                                    , p_localidad_destino     VARCHAR2
                                    --
                                    , p_item_id               NUMBER
                                    , p_lot_no                VARCHAR2
                                    , p_operating_unit        NUMBER
                                    , p_retiro_propio_flag           VARCHAR2   -- CR2382 Abre las marca de retiro
                                    , p_retiro_terceros_flag           VARCHAR2    -- CR2382 Abre las marca de retiro       
                                    , p_contrato_id           NUMBER
                                    ) RETURN NUMBER;


/***************************************************************************
 *                                                                          *
 * Name    : Cliente_PV                                                     *
 * Purpose : Devuelve el party_id de los intervinientes habilitados como    *
 *           clientes para la asociacion de PV                              *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Cliente_PV ( p_carta_porte_id        NUMBER
                      , p_empresa_id            NUMBER
                      , p_reacondicionadora     VARCHAR2 DEFAULT NULL
                      ) RETURN NUMBER;


/***************************************************************************
 *                                                                          *
 * Name    : Interviene_CP                                                  *
 * Purpose : Devuelve 1 si la unidad operativa donde estoy parado existe    *
 *           entre los intervinientes de la CP                              *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Interviene_CP ( p_carta_porte_id        NUMBER
                         , p_operating_unit        NUMBER
                         ) RETURN NUMBER;


 /***************************************************************************
 *                                                                          *
 * Name    : Calcular_Costo_Distancia                                       *
 * Purpose : Calcula el costo del transporte del grano                      *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Calcular_Costo_Distancia ( p_origen                  IN  NUMBER
                                    , p_direccion_origen        IN  NUMBER
                                    , p_localidad_origen        IN  VARCHAR2
                                    --
                                    , p_destino                 IN  NUMBER
                                    , p_direccion_destino       IN  NUMBER
                                    , p_localidad_destino       IN  VARCHAR2
                                    , p_zona_destino            IN  VARCHAR2
                                    --
                                    , p_actividad               IN  VARCHAR2
                                    , p_transportista           IN  NUMBER
                                    , p_producto_oncca          IN  VARCHAR2
                                    , p_fecha_envio             IN  DATE
                                    , p_grupo_control           IN  VARCHAR2
                                    , p_kg_neto                 IN  NUMBER
                                    , p_enganchada              IN  VARCHAR2
                                    --
                                    , x_distancia              OUT NUMBER
                                    , x_tiempo_maximo          OUT NUMBER
                                    , x_tarifa_cp_xton         OUT NUMBER
                                    , x_costo_flete_xton       OUT NUMBER
                                    , x_costo_flete_final      OUT NUMBER
                                    , x_distancia_id           OUT NUMBER
                                    , x_negociacion_id         OUT NUMBER
                                    ) RETURN VARCHAR2;


  /***************************************************************************
  *                                                                          *
  * Name    : Recalcular_Costo_Distancia                                     *
  * Purpose : Devuelve los datos necesarios para el calculo de distancia     *
  *                                                                          *
  ****************************************************************************/
  FUNCTION Recalcular_Costo_Distancia ( p_negociacion_id     IN  NUMBER
                                      , p_costo_flete_xton   IN  NUMBER
                                      , p_kg_neto            IN  NUMBER
                                      --
                                      , x_costo_flete_final  OUT NUMBER
                                      ) RETURN VARCHAR2;


  /***************************************************************************
  *                                                                          *
  * Name    : Obtiene_Codigo_ONCCA                                           *
  * Purpose : Devuelve el código ONCCA del artículo dado                     *
  *                                                                          *
  ****************************************************************************/
  FUNCTION Obtiene_Codigo_ONCCA ( p_item_id  NUMBER ) RETURN VARCHAR2;


  /***************************************************************************
  *                                                                          *
  * Name    : Obtiene_Especie_ONCCA                                          *
  * Purpose : Devuelve la especie ONCCA del artículo dado                    *
  *                                                                          *
  ****************************************************************************/
  FUNCTION Obtiene_Especie_ONCCA ( p_item_id  NUMBER ) RETURN VARCHAR2;


  /***************************************************************************
  *                                                                          *
  * Name    : Es_Ubicacion_COM                                               *
  * Purpose : Devuelve si es ubicación comercial                             *
  *                                                                          *
  ****************************************************************************/
  FUNCTION Es_Ubicacion_COM ( p_inv_location_id  NUMBER ) RETURN VARCHAR2;



  /***************************************************************************
  *                                                                          *
  * Name    : Derivar_PTT                                                    *
  * Purpose : Derivar proyecto, tarea y tipo de erogacion para ubi COM       *
  *                                                                          *
  ****************************************************************************/
  PROCEDURE Derivar_PTT ( p_titular_cuit           NUMBER
                        , p_titular_estab          NUMBER
                        , p_item_id                NUMBER
                        , p_lot_no                 VARCHAR2
                        , x_proyecto_id     IN OUT NUMBER
                        , x_tarea_id        IN OUT NUMBER
                        , x_tipo_erogacion  IN OUT VARCHAR2
                        , x_error_msg       IN OUT VARCHAR2
                        );


  /***************************************************************************
  *                                                                          *
  * Name    : Get_Grupo_Control_CP_CTG                                       *
  * Purpose : Derivar el valor de control de grupo                           *
  *                                                                          *
  ****************************************************************************/
  FUNCTION Get_Grupo_Control_CP_CTG (p_carta_porte_id IN NUMBER DEFAULT NULL,
                                     p_nro_ctg        IN NUMBER DEFAULT NULL) RETURN VARCHAR2;


END XX_TCG_FUNCTIONS_PKG;
/


  CREATE OR REPLACE PACKAGE BODY "APPS"."XX_TCG_FUNCTIONS_PKG" AS

  FUNCTION getMainCursor RETURN VARCHAR2 IS
  BEGIN
    RETURN c_main_cursor_stmt;
  END;


  FUNCTION getOrgName ( p_organization_id NUMBER ) RETURN VARCHAR2 IS
    l_org_name VARCHAR2(250);
  BEGIN
    SELECT organization_name
    INTO l_org_name
    FROM org_organization_definitions
    WHERE organization_id = p_organization_id;

    RETURN l_org_name;
  EXCEPTION
    WHEN Others THEN
      RETURN NULL;
  END getOrgName;


  FUNCTION getEstabName ( p_establecimiento_id NUMBER ) RETURN VARCHAR2 IS
    l_estab_name VARCHAR2(250);
  BEGIN
    SELECT campo
    INTO l_estab_name
    FROM xx_opm_establecimientos
    WHERE establecimiento_id = p_establecimiento_id;

    RETURN l_estab_name;
  EXCEPTION
    WHEN Others THEN
      RETURN NULL;
  END getEstabName;


  FUNCTION getMasterOrg RETURN VARCHAR2 IS
    l_org_id   NUMBER;
  BEGIN
    SELECT organization_id
    INTO l_org_id
    FROM org_organization_definitions
    WHERE organization_code = '1MI';

    RETURN l_org_id;
  EXCEPTION
    WHEN OTHERS THEN RETURN NULL;
  END;


  FUNCTION Valida_Acceso_Org ( p_user_id  NUMBER
                             , p_org_id   NUMBER
                             ) RETURN BOOLEAN IS
    l_acceso VARCHAR2(1);
  BEGIN
    IF NVL(FND_PROFILE.Value('XX_INV_HABILITA_SEGURIDAD_ACCESOS'), 'N') = 'N' THEN
      RETURN TRUE;
    END IF;

    SELECT DISTINCT 'Y'
    INTO l_acceso
    FROM xx_inv_user_org_access_v
    WHERE 1=1
    AND user_id = p_user_id
    AND ( organization_id = p_org_id OR
          operating_unit_id = ( SELECT operating_unit FROM org_organization_definitions WHERE organization_id = p_org_id )
        )
    ;

    IF l_acceso = 'Y' THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  END Valida_Acceso_Org;


  FUNCTION Valida_Acceso_Org_c ( p_user_id  NUMBER
                               , p_org_id   NUMBER
                               ) RETURN VARCHAR2 IS
    l_acceso VARCHAR2(1);
  BEGIN
    IF Valida_Acceso_Org(p_user_id, p_org_id) THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;

  END Valida_Acceso_Org_c;


/****************************************************************************
 *                                                                          *
 * Name    : Es_Empresa_Grupo                                               *
 * Purpose : Retorna verdadero si el cuit esta dentro de                    *
 *           xx_tcg_parametros_compania                                     *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Es_Empresa_Grupo (p_cuit NUMBER) RETURN BOOLEAN IS
    l_dummy_num NUMBER;
  BEGIN
    IF p_cuit IS NULL THEN
      RETURN FALSE;
    END IF;

    SELECT operating_unit_cuit
    INTO l_dummy_num
    FROM xx_tcg_parametros_compania
    WHERE 1=1
    AND operating_unit_cuit = p_cuit;

    RETURN TRUE;
  EXCEPTION
    WHEN Others THEN
      RETURN FALSE;
  END Es_Empresa_Grupo;


/****************************************************************************
 *                                                                          *
 * Name    : Es_Empresa_Grupo                                               *
 * Purpose : Retorna Y si el cuit esta dentro de xx_tcg_parametros_compania *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Es_Empresa_Grupo_c (p_cuit NUMBER) RETURN VARCHAR2 IS
    l_dummy_num NUMBER;
  BEGIN
    IF p_cuit IS NULL THEN
      RETURN 'N';
    END IF;

    SELECT operating_unit_cuit
    INTO l_dummy_num
    FROM xx_tcg_parametros_compania
    WHERE 1=1
    AND operating_unit_cuit = p_cuit;

    RETURN 'Y';
  EXCEPTION
    WHEN Others THEN
      RETURN 'N';
  END Es_Empresa_Grupo_c;


/****************************************************************************
 *                                                                          *
 * Name    : Obtener_CUIT                                                   *
 * Purpose : Retorna el CUIT correspondiente al party_id                    *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Obtener_CUIT (p_party_id NUMBER) RETURN NUMBER IS
    l_cuit   NUMBER;
  BEGIN
    SELECT cuit
    INTO l_cuit
    FROM
    ( SELECT hp.party_id
           , DECODE( s.attribute_category
                   , 'AR', hp.jgzz_fiscal_code||s.global_attribute12
                   , 'UY', s.vat_registration_num
                   ) CUIT
      FROM hz_parties   hp
         , hz_party_usg_assignments hpa
         , ap_suppliers s
      WHERE 1=1
      AND hpa.party_id = hp.party_id
      AND s.party_id   = hp.party_id
      AND hpa.party_usage_code = 'SUPPLIER'
      AND hp.status    = 'A'
      UNION
      SELECT hp.party_id
           , DECODE( c.attribute_category
                   , 'AR', hp.jgzz_fiscal_code||c.global_attribute12
                   , 'UY', c.attribute13
                   ) CUIT
      FROM hz_parties       hp
         , hz_party_usg_assignments hpa
         , hz_cust_accounts c
      WHERE 1=1
      AND hpa.party_id = hp.party_id
      AND c.party_id   = hp.party_id
      AND hpa.party_usage_code = 'CUSTOMER'
      AND hp.status    = 'A'
      AND NOT EXISTS
      (SELECT pa.party_id
       FROM hz_party_usg_assignments pa
          , ap_suppliers             s
       WHERE 1=1
       AND s.party_id = pa.party_id
       AND DECODE( s.attribute_category
                 , 'AR', hp.jgzz_fiscal_code||s.global_attribute12
                 , 'UY', s.vat_registration_num
                 ) =
           DECODE( c.attribute_category
                 , 'AR', hp.jgzz_fiscal_code||c.global_attribute12
                 , 'UY', c.attribute13
                 )
       AND pa.party_usage_code = 'SUPPLIER'
      )
    ) WHERE party_id = p_party_id;

    RETURN l_cuit;
  EXCEPTION
    WHEN Others THEN
      RETURN NULL;
  END Obtener_CUIT;


/****************************************************************************
 *                                                                          *
 * Name    : Valida_CUIT                                                    *
 * Purpose : Validar si el cuit es valido                                   *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Valida_CUIT ( p_cuit VARCHAR2
                       , p_msg  OUT VARCHAR2
                       ) RETURN BOOLEAN IS
    l_result              VARCHAR2(20);
    l_taxpayer_id         VARCHAR2(50);
    l_global_attribute12  VARCHAR2(5);
  BEGIN
    l_taxpayer_id        := SUBSTR(p_cuit, 1, LENGTH(p_cuit)-1);
    l_global_attribute12 := SUBSTR(p_cuit, LENGTH(p_cuit),1);

    l_result := JG_TAXID_VAL_PKG.Check_Numeric( p_taxpayer_id => p_cuit );

    IF l_result = 'FALSE' THEN
      p_msg := 'El CUIT ingreado no es numérico';
      RETURN FALSE;
    END IF;

    l_result := JG_TAXID_VAL_PKG.check_length( p_country_code  => 'AR'
                                             , p_num_digits    => 11
                                             , p_taxpayer_id   => p_cuit
                                             );

    IF l_result = 'FALSE' THEN
      p_msg := 'Longitud inválida para el CUIT ingresado.';
      RETURN FALSE;
    END IF;

    l_result := JG_TAXID_VAL_PKG.check_algorithm ( p_taxpayer_id        => l_taxpayer_id
                                                 , p_country            => 'AR'
                                                 , p_global_attribute12 => l_global_attribute12
                                                 );

    IF l_result = 'TRUE'THEN
      RETURN TRUE;
    ELSE
      p_msg := 'El CUIT ingresado es inválido';
      RETURN FALSE;
    END IF;
  END Valida_CUIT;


/***************************************************************************
 *                                                                          *
 * Name    : Valida_CUIT_DDBB                                               *
 * Purpose : Valida que el CUIT ingresado encuentre en como partie          *
 *                                                                          *
 ****************************************************************************/
  PROCEDURE Valida_CUIT_DDBB ( p_cuit              VARCHAR2
                             , p_country           VARCHAR2
                             , x_party_id   IN OUT NUMBER
                             , x_party_name IN OUT VARCHAR2
                             ) IS
    l_party_id   NUMBER;
    l_party_name VARCHAR2(300);
  BEGIN
    SELECT party_id, party_name
    INTO l_party_id, l_party_name
    FROM
    ( SELECT hp.party_id, hp.party_name
           , DECODE( s.attribute_category
                   , 'AR', hp.jgzz_fiscal_code||s.global_attribute12
                   , 'UY', s.vat_registration_num
                   ) CUIT
      FROM hz_parties   hp
         , hz_party_usg_assignments hpa
         , ap_suppliers s
      WHERE 1=1
      AND hpa.party_id = hp.party_id
      AND s.party_id   = hp.party_id
      AND hpa.party_usage_code = 'SUPPLIER'
      AND hp.status    = 'A'
      AND s.attribute_category = p_country
      UNION
      SELECT hp.party_id, hp.party_name
           , DECODE( c.attribute_category
                   , 'AR', hp.jgzz_fiscal_code||c.global_attribute12
                   , 'UY', c.attribute13
                   ) CUIT
      FROM hz_parties       hp
         , hz_party_usg_assignments hpa
         , hz_cust_accounts c
      WHERE 1=1
      AND hpa.party_id = hp.party_id
      AND c.party_id   = hp.party_id
      AND hpa.party_usage_code = 'CUSTOMER'
      AND hp.status    = 'A'
      AND c.attribute_category = p_country
      AND NOT EXISTS
      (SELECT pa.party_id
       FROM hz_party_usg_assignments pa
          , ap_suppliers             s
       WHERE 1=1
       AND s.party_id = pa.party_id
       AND DECODE( s.attribute_category
                 , 'AR', hp.jgzz_fiscal_code||s.global_attribute12
                 , 'UY', s.vat_registration_num
                 ) =
           DECODE( c.attribute_category
                 , 'AR', hp.jgzz_fiscal_code||c.global_attribute12
                 , 'UY', c.attribute13
                 )
       AND pa.party_usage_code = 'SUPPLIER'
      )
    ) WHERE CUIT = p_cuit;

    x_party_id   := l_party_id;
    x_party_name := l_party_name;
  EXCEPTION
    WHEN Others THEN
      x_party_id   := NULL;
      x_party_name := NULL;
  END;


/***************************************************************************
 *                                                                          *
 * Name    : Valida_CUIT_DDBB                                               *
 * Purpose : Valida que el CUIT ingresado encuentre en como partie          *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Valida_CUIT_DDBB ( p_cuit  VARCHAR2 ) RETURN BOOLEAN IS
    CURSOR c1 IS
      SELECT party_id, party_name
      FROM
      ( SELECT hp.party_id, hp.party_name
             , DECODE( s.attribute_category
                     , 'AR', hp.jgzz_fiscal_code||s.global_attribute12
                     , 'UY', s.vat_registration_num
                     ) CUIT
        FROM hz_parties   hp
           , hz_party_usg_assignments hpa
           , ap_suppliers s
        WHERE 1=1
        AND hpa.party_id = hp.party_id
        AND s.party_id   = hp.party_id
        AND hpa.party_usage_code = 'SUPPLIER'
        AND hp.status    = 'A'
        AND s.attribute_category IN ('AR', 'UY')
        UNION
        SELECT hp.party_id, hp.party_name
             , DECODE( c.attribute_category
                     , 'AR', hp.jgzz_fiscal_code||c.global_attribute12
                     , 'UY', c.attribute13
                     ) CUIT
        FROM hz_parties       hp
           , hz_party_usg_assignments hpa
           , hz_cust_accounts c
        WHERE 1=1
        AND hpa.party_id = hp.party_id
        AND c.party_id   = hp.party_id
        AND hpa.party_usage_code = 'CUSTOMER'
        AND hp.status    = 'A'
        AND c.attribute_category IN ('AR', 'UY')
        AND NOT EXISTS
        (SELECT pa.party_id
         FROM hz_party_usg_assignments pa
            , ap_suppliers             s
         WHERE 1=1
         AND s.party_id = pa.party_id
         AND DECODE( s.attribute_category
                   , 'AR', hp.jgzz_fiscal_code||s.global_attribute12
                   , 'UY', s.vat_registration_num
                   ) =
             DECODE( c.attribute_category
                   , 'AR', hp.jgzz_fiscal_code||c.global_attribute12
                   , 'UY', c.attribute13
                   )
         AND pa.party_usage_code = 'SUPPLIER'
        )
      ) WHERE CUIT = p_cuit;

    r1  c1%ROWTYPE;
  BEGIN
    OPEN c1;
    FETCH c1 INTO r1;

    IF c1%FOUND THEN
      CLOSE c1;
      RETURN TRUE;
    ELSE
      CLOSE c1;
      RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN Others THEN
      RETURN FALSE;
  END;


/***************************************************************************
 *                                                                          *
 * Name    : CUIT_Party_ID                                                  *
 * Purpose : Devuelve el Party_ID de un determinado CUIT                    *
 *                                                                          *
 ****************************************************************************/
  FUNCTION CUIT_Party_ID ( p_cuit    VARCHAR2
                         , p_country VARCHAR2 DEFAULT 'AR'
                         ) RETURN NUMBER IS
    l_party_id   NUMBER;
    l_party_name VARCHAR2(300);
  BEGIN
    SELECT party_id, party_name
    INTO l_party_id, l_party_name
    FROM
    ( SELECT hp.party_id, hp.party_name
           , DECODE( s.attribute_category
                   , 'AR', hp.jgzz_fiscal_code||s.global_attribute12
                   , 'UY', s.vat_registration_num
                   ) CUIT
      FROM hz_parties   hp
         , hz_party_usg_assignments hpa
         , ap_suppliers s
      WHERE 1=1
      AND hpa.party_id = hp.party_id
      AND s.party_id   = hp.party_id
      AND hpa.party_usage_code = 'SUPPLIER'
      AND hp.status    = 'A'
      AND s.attribute_category = p_country
      UNION
      SELECT hp.party_id, hp.party_name
           , DECODE( c.attribute_category
                   , 'AR', hp.jgzz_fiscal_code||c.global_attribute12
                   , 'UY', c.attribute13
                   ) CUIT
      FROM hz_parties       hp
         , hz_party_usg_assignments hpa
         , hz_cust_accounts c
      WHERE 1=1
      AND hpa.party_id = hp.party_id
      AND c.party_id   = hp.party_id
      AND hpa.party_usage_code = 'CUSTOMER'
      AND hp.status    = 'A'
      AND c.attribute_category = p_country
      AND NOT EXISTS
      (SELECT pa.party_id
       FROM hz_party_usg_assignments pa
          , ap_suppliers             s
       WHERE 1=1
       AND s.party_id = pa.party_id
       AND DECODE( s.attribute_category
                 , 'AR', hp.jgzz_fiscal_code||s.global_attribute12
                 , 'UY', s.vat_registration_num
                 ) =
           DECODE( c.attribute_category
                 , 'AR', hp.jgzz_fiscal_code||c.global_attribute12
                 , 'UY', c.attribute13
                 )
       AND pa.party_usage_code = 'SUPPLIER'
      )
    ) WHERE CUIT = p_cuit;

    RETURN l_party_id;
  EXCEPTION
    WHEN Others THEN
      RETURN NULL;
  END CUIT_Party_ID;


/***************************************************************************
 *                                                                          *
 * Name    : CUIT_OPERATING_UNIT                                            *
 * Purpose : Devuelve la unidad operativa de un CUIT si es empresa de grupo *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Cuit_Operating_Unit ( p_cuit VARCHAR2 ) RETURN NUMBER IS
    l_ou NUMBER;
  BEGIN
    SELECT operating_unit
    INTO l_ou
    FROM xx_tcg_parametros_compania
    WHERE operating_unit_cuit = p_cuit;

    RETURN l_ou;
  EXCEPTION
    WHEN Others THEN
      RETURN NULL;
  END Cuit_Operating_Unit;


/***************************************************************************
 *                                                                          *
 * Name    : OPERATING_UNIT_CUIT                                            *
 * Purpose : Devuelve el CUIT de una unidad operativa si es empresa de grupo *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Operating_Unit_CUIT ( p_operating_unit NUMBER ) RETURN NUMBER IS
    l_cuit NUMBER;
  BEGIN
    SELECT operating_unit_cuit
    INTO l_cuit
    FROM xx_tcg_parametros_compania
    WHERE operating_unit = p_operating_unit;

    RETURN l_cuit;
  EXCEPTION
    WHEN Others THEN
      RETURN NULL;
  END Operating_Unit_CUIT;


/***************************************************************************
 *                                                                          *
 * Name    : OPERATING_UNIT_PARTY_NAME                                      *
 * Purpose : Devuelve el Party Name de una Unidad Operativa                 *
 *                                                                          *
 ****************************************************************************/
  FUNCTION OU_Party_Name ( p_ou NUMBER ) RETURN VARCHAR2 IS
    l_party_name  VARCHAR2(250);
  BEGIN
    SELECT hp.party_name
    INTO l_party_name
    FROM xx_tcg_parametros_compania pc
       , ap_suppliers  s
       , hz_parties    hp
    WHERE 1=1
    AND s.vendor_id = pc.vendor_id
    AND hp.party_id = s.party_id
    AND pc.operating_unit = p_ou
    ;

    RETURN l_party_name;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END OU_Party_Name;


/***************************************************************************
 *                                                                          *
 * Name    : OU_PARTY_ID                                                    *
 * Purpose : Devuelve el Party ID de una Unidad Operativa                   *
 *                                                                          *
 ****************************************************************************/
  FUNCTION OU_Party_ID ( p_ou NUMBER ) RETURN NUMBER IS
    l_party_id  NUMBER;
  BEGIN
    SELECT s.party_id
    INTO l_party_id
    FROM xx_tcg_parametros_compania pc
       , ap_suppliers  s
    WHERE 1=1
    AND s.vendor_id = pc.vendor_id
    AND pc.operating_unit = p_ou
    ;

    RETURN l_party_id;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END OU_Party_ID;


/***************************************************************************
 *                                                                          *
 * Name    : Valida_Estab_OU                                                *
 * Purpose : Valida que el establecimiento pertenezca a la unidad operativa *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Valida_Estab_OU ( p_operating_unit_cuit VARCHAR2
                           , p_establecimiento_id  NUMBER
                           ) RETURN NUMBER IS
    TYPE mainCurTyp    IS REF CURSOR;
    l_main_cursor      mainCurTyp;
    l_rec              trOrgInfo;
    l_main_cursor_stmt VARCHAR2(4000);
    l_estab            NUMBER;
  BEGIN
    l_main_cursor_stmt := c_main_cursor_stmt
    ||'AND pc.operating_unit_cuit = '''||p_operating_unit_cuit||''' '||chr(10)
    ||'AND est.establecimiento_id = '||p_establecimiento_id||' ';

    OPEN l_main_cursor FOR l_main_cursor_stmt;
    LOOP
      FETCH l_main_cursor INTO l_rec;
      IF l_rec.establecimiento_id = p_establecimiento_id THEN
        l_estab := l_rec.establecimiento_id;
        EXIT;
      END IF;
      EXIT WHEN l_main_cursor%NOTFOUND;
    END LOOP;

    CLOSE l_main_cursor;

    RETURN l_estab;

  EXCEPTION
    WHEN Others THEN
      RETURN NULL;
  END;


/***************************************************************************
 *                                                                          *
 * Name    : Valida_Estab_Pesaje                                            *
 * Purpose : Valida que el establecimiento tenga balanza asociada           *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Valida_Estab_Pesaje ( p_establecimiento_id  NUMBER ) RETURN NUMBER IS
    l_estab_id  NUMBER;
  BEGIN
    SELECT DISTINCT p_establecimiento_id
    INTO l_estab_id
    FROM xx_tcg_balanza_estab
    WHERE establecimiento_id = p_establecimiento_id;

    RETURN NVL(l_estab_id, -1);
  EXCEPTION
    WHEN Others THEN
      RETURN -1;
  END Valida_Estab_Pesaje;


/***************************************************************************
 *                                                                          *
 * Name    : Valida_Estab_Pesaje_Org                                        *
 * Purpose : Valida que el establecimiento pertenezca a la unidad operativa *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Valida_Estab_Pesaje_Org ( p_organization_id     NUMBER
                                   , p_establecimiento_id  NUMBER
                                   , p_viaje_id            NUMBER DEFAULT NULL
                                   ) RETURN NUMBER IS
    TYPE mainCurTyp    IS REF CURSOR;
    l_main_cursor      mainCurTyp;
    l_rec              trOrgInfo;
    l_main_cursor_stmt VARCHAR2(4000);
    l_estab_id         NUMBER;
    l_estab_id_viaje   NUMBER;
  BEGIN
    l_main_cursor_stmt := c_main_cursor_stmt
    ||'AND est.establecimiento_id = '||p_establecimiento_id||' '||chr(10)
    --||'AND msi.secondary_inventory_name = ( SELECT organization_code FROM org_organization_definitions WHERE organization_id = '||p_organization_id||' ) '||chr(10)
    ||'AND od.organization_id = '||p_organization_id||' '||chr(10)
    ||'AND EXISTS ( SELECT balance_id FROM xx_tcg_balanza_estab WHERE establecimiento_id = '||p_establecimiento_id||' )';

    OPEN l_main_cursor FOR l_main_cursor_stmt;
    LOOP
      FETCH l_main_cursor INTO l_rec;
      IF l_rec.establecimiento_id = p_establecimiento_id THEN
        l_estab_id := l_rec.establecimiento_id;
        EXIT;
      END IF;
      EXIT WHEN l_main_cursor%NOTFOUND;
    END LOOP;

    CLOSE l_main_cursor;

    IF p_viaje_id IS NOT NULL THEN
      BEGIN
        SELECT estab_carga_id
        INTO l_estab_id_viaje
        FROM xx_tcg_control_viajes
        WHERE viaje_id = p_viaje_id;
      EXCEPTION
        WHEN Others THEN
          l_estab_id_viaje := -1;
      END;

      l_estab_id := l_estab_id_viaje;
    END IF;

    RETURN NVL(l_estab_id,-1);

  EXCEPTION
    WHEN Others THEN
      RETURN -1;
  END Valida_Estab_Pesaje_Org;


/***************************************************************************
 *                                                                          *
 * Name    : Valida_Peso_Maximo                                             *
 * Purpose : Valida_Peso_Maximo                                             *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Valida_Peso_Maximo ( p_item_name     VARCHAR2
                              , p_weight        NUMBER
                              , p_ou            VARCHAR2
                              , p_mode_of_trans VARCHAR2
                              , x_msg       OUT VARCHAR2 ) RETURN BOOLEAN IS
    l_max_peso_neto         NUMBER;
    l_max_peso_bruto        NUMBER;
    l_tolerancia_tb         NUMBER;
    --l_ou                    VARCHAR2(10) := NAME_IN('PARAMETER.OPERATING_UNIT');
    --l_mode_of_transport_frm VARCHAR2(50) := NAME_IN('XX_TCG_CARTAS_PORTE.MODE_OF_TRANSPORT');
  BEGIN
    BEGIN
      SELECT DECODE(p_mode_of_trans
                   , XX_TCG_UTIL_PKG.MODO_TRANSPORTE_TREN, peso_bruto_tren
                   , peso_bruto_camion)
           , DECODE(p_mode_of_trans
                   , XX_TCG_UTIL_PKG.MODO_TRANSPORTE_TREN, peso_neto_tren
                   , peso_neto_camion)
           , NVL(tolerancia_tb, 0) tolerancia_tb
      INTO l_max_peso_bruto, l_max_peso_neto, l_tolerancia_tb
      FROM xx_tcg_parametros_compania
      WHERE operating_unit = p_ou;
    EXCEPTION
      WHEN OTHERS THEN
        l_max_peso_bruto := NULL;
        l_max_peso_neto  := NULL;
        l_tolerancia_tb  := 0;
    END;

    IF l_max_peso_bruto IS NULL AND
       l_max_peso_neto  IS NULL THEN
      RETURN TRUE;
    END IF;

    IF p_item_name IN ('PESO_NETO', 'PESO_BRUTO') THEN --Ticket Balanza
      l_max_peso_bruto := l_max_peso_bruto + l_tolerancia_tb;
      l_max_peso_neto  := l_max_peso_neto + l_tolerancia_tb;
    END IF;

    IF p_item_name IN ('PESO_ESTIMADO', 'PESO_NETO_ENVIO', 'PESO_NETO_RECEPCION', 'PESO_NETO') THEN
      IF l_max_peso_neto IS NOT NULL AND
         p_weight > l_max_peso_neto THEN

        SELECT 'El Peso '
             ||DECODE( p_item_name
                     , 'PESO_ESTIMADO', 'Estimado '
                     , 'PESO_NETO_ENVIO', 'Neto de Envío '
                     , 'PESO_NETO_RECEPCION', 'Neto de Recepción '
                     , 'PESO_NETO', 'Neto ')
             ||'supera el máximo permitido ('||l_max_peso_neto||').'
        INTO x_msg
        FROM DUAL;

        RETURN FALSE;
      END IF;

      IF p_item_name IN ('PESO_NETO_ENVIO', 'PESO_NETO', 'PESO_NETO_RECEPCION') AND
         p_weight <= 0 THEN
        x_msg := 'El Peso Neto no puede ser menor o igual a 0.';
        RETURN FALSE;
      END IF;
      --
    ELSIF p_item_name IN ('PESO_BRUTO_ENVIO', 'PESO_BRUTO_RECEPCION', 'PESO_BRUTO') THEN
      IF l_max_peso_bruto IS NOT NULL AND
         p_weight > l_max_peso_bruto THEN

        SELECT 'El Peso '
             ||DECODE( p_item_name
                     , 'PESO_BRUTO_ENVIO', 'Bruto de Envío '
                     , 'PESO_BRUTO_RECEPCION', 'Bruto de Recepción '
                     , 'PESO_BRUTO', 'Bruto ')
             ||'supera el máximo permitido ('||l_max_peso_bruto||').'
        INTO x_msg
        FROM DUAL;

        RETURN FALSE;
      END IF;
      --
    END IF;

    RETURN TRUE;
  END;


/***************************************************************************
 *                                                                          *
 * Name    : Valida_SubInv_Estab                                            *
 * Purpose : Valida el subinventario pertenezca al establecimiento          *
 *           y unidad operativa                                             *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Valida_SubInv_Estab ( p_operating_unit      NUMBER
                               , p_establecimiento_id  NUMBER
                               , p_subinv_name         VARCHAR2
                               ) RETURN VARCHAR2 IS
    TYPE mainCurTyp    IS REF CURSOR;
    l_main_cursor      mainCurTyp;
    l_rec              trOrgInfo;
    l_main_cursor_stmt VARCHAR2(4000);
    l_subinv           VARCHAR2(50);
  BEGIN
    l_main_cursor_stmt := c_main_cursor_stmt
    ||'AND od.operating_unit = '||p_operating_unit||' '||chr(10)
    ||'AND est.establecimiento_id = '||p_establecimiento_id||' '||chr(10)
    ||'AND msi.secondary_inventory_name != od.organization_code ';

    OPEN l_main_cursor FOR l_main_cursor_stmt;
    LOOP
      FETCH l_main_cursor INTO l_rec;
      IF l_rec.secondary_inventory_name = p_subinv_name THEN
        l_subinv := l_rec.secondary_inventory_name;
        EXIT;
      END IF;
      EXIT WHEN l_main_cursor%NOTFOUND;
    END LOOP;

    CLOSE l_main_cursor;

    RETURN l_subinv;

  EXCEPTION
    WHEN Others THEN
      RETURN NULL;
  END;

/***************************************************************************
 *                                                                          *
 * Name    : Proveedor_Reac                                                 *
 * Purpose :VERDADERO si la clasificacion del proveedor es REACONDICIONADOR *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Proveedor_Reac ( p_party_id  NUMBER ) RETURN VARCHAR2 IS
    l_party_id NUMBER;
  BEGIN

    SELECT party_id
    INTO l_party_id
    FROM ap_suppliers
    WHERE party_id = p_party_id
    AND vendor_type_lookup_code = 'REACONDICIONADOR';

    RETURN 'Y';
  EXCEPTION
    WHEN Others THEN
      RETURN 'N';
  END;


/***************************************************************************
 *                                                                          *
 * Name    : Valida_Contrato_Compra                                         *
 * Purpose :Valida que el contrato sea valido para los intervinientes       *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Valida_Contrato_Compra ( p_titular_cp_id         NUMBER
                                  , p_titular_cp_tipo       VARCHAR2
                                  , p_titular_cp_site_id    NUMBER
                                  , p_intermediario_id      NUMBER
                                  , p_intermediario_tipo    VARCHAR2
                                  , p_intermediario_retiro  VARCHAR2
                                  , p_rtte_comercial_id     NUMBER
                                  , p_rtte_comercial_tipo   VARCHAR2
                                  , p_rtte_comercial_retiro VARCHAR2
                                  , p_destinatario_id       NUMBER
                                  , p_destino_id            NUMBER
                                  , p_destino_site_id       NUMBER
                                  , p_destino_zona          VARCHAR2
                                  --
                                  , p_contrato_id           NUMBER
                                  , p_item_id               NUMBER
                                  , p_lot_no                VARCHAR2
                                  , p_fecha_recepcion       DATE
                                  , p_interviniente         VARCHAR2
                                  ) RETURN NUMBER IS

    CURSOR cCont ( p_contrato_id     NUMBER
                 , p_item_id         NUMBER
                 , p_lot_no          VARCHAR2
                 , p_fecha_recepcion DATE
                 , p_productor_id    NUMBER
                 , p_productor_tipo  VARCHAR2
                 , p_interviniente_cuit NUMBER
                 , p_destino_id      NUMBER
                 , p_destino_site_id NUMBER
                 , p_destino_zona    VARCHAR2
                 ) IS
      SELECT cc.contrato_id, cc.numero_contrato, cc.descripcion
      FROM xx_tcg_contratos_compra      cc
         , org_organization_definitions od
         , xx_tcg_parametros_compania   pc
      WHERE 1=1
      AND od.organization_id   = cc.organization_id
      AND pc.operating_unit    = od.operating_unit
      AND cc.cerrado_flag      = 'N'
      AND cc.contrato_id       = p_contrato_id
      AND cc.inventory_item_id = p_item_id
      AND cc.lot_number        = p_lot_no
      AND p_fecha_recepcion BETWEEN cc.fecha_recepcion_desde AND NVL(cc.fecha_recepcion_hasta,p_fecha_recepcion)
      AND cc.productor_id      = p_productor_id
      AND ( ( p_productor_tipo = 'PRODUCTOR' AND
              cc.tipo_produccion = 'PRODUCTOR'
            ) OR
            ( p_productor_tipo = 'ACONDICIONAMIENTO' AND
              cc.tipo_contrato = 'ACONDICIONAMIENTO'
            ) OR
            ( p_productor_tipo NOT IN ('PRODUCTOR', 'ACONDICIONAMIENTO') AND
              cc.tipo_produccion != 'PRODUCTOR'
            )
          )
      AND pc.operating_unit_cuit = p_interviniente_cuit
      AND ( XX_TCG_FUNCTIONS_PKG.Proveedor_Reac (p_destino_id) = 'Y' OR
            ( NVL(XX_TCG_FUNCTIONS_PKG.Proveedor_Reac (p_destino_id),'N') = 'N' AND
              ( ( cc.empresa_destino_id = p_destino_id AND
                  cc.establecimiento_destino_id = p_destino_site_id
                ) OR
                ( cc.empresa_destino_id = p_destino_id AND
                  cc.establecimiento_destino_id IS NULL
                ) OR
                ( cc.empresa_destino_id IS NULL AND
                  cc.zona_destino_code  = p_destino_zona
                )
              )
            )
          )
      /*AND ( cc.empresa_destino_id = p_destino_id OR
            cc.zona_destino_code  = p_destino_zona
          )*/
      ORDER BY cc.establecimiento_destino_id, cc.zona_destino_code DESC, cc.empresa_destino_id
      ;

    rCont                cCont%ROWTYPE;
    l_productor_id       NUMBER;
    l_productor_tipo     VARCHAR2(150);
    l_destino_id         NUMBER;
    l_destino_site_id    NUMBER;
    l_destino_zona       VARCHAR2(150);
    l_interviniente_cuit NUMBER;
    l_contrato_id        NUMBER;
  BEGIN
    l_destino_id      := p_destino_id;
    l_destino_site_id := p_destino_site_id;
    l_destino_zona    := p_destino_zona;


    IF p_interviniente = 'INTERMEDIARIO' THEN
      l_productor_id   := p_titular_cp_id;
      l_productor_tipo := p_titular_cp_tipo;
      l_interviniente_cuit := Obtener_CUIT(p_intermediario_id);

    ELSIF p_interviniente = 'RTTE_COMERCIAL' THEN
      IF p_intermediario_id IS NOT NULL THEN
        l_productor_id   := p_intermediario_id;
        l_productor_tipo := p_intermediario_tipo;
        l_interviniente_cuit := Obtener_CUIT(p_rtte_comercial_id);

      ELSE
        l_productor_id   := p_titular_cp_id;
        l_productor_tipo := p_titular_cp_tipo;
        l_interviniente_cuit := Obtener_CUIT(p_rtte_comercial_id);

      END IF;

    ELSIF p_interviniente = 'DESTINATARIO' THEN
      IF p_rtte_comercial_id IS NOT NULL THEN
        l_productor_id   := p_rtte_comercial_id;
        l_productor_tipo := p_rtte_comercial_tipo;
        l_interviniente_cuit := Obtener_CUIT(p_destinatario_id);

      ELSIF p_intermediario_id IS NOT NULL THEN
        l_productor_id   := p_intermediario_id;
        l_productor_tipo := p_intermediario_tipo;
        l_interviniente_cuit := Obtener_CUIT(p_destinatario_id);

      ELSE
        l_productor_id   := p_titular_cp_id;
        l_productor_tipo := p_titular_cp_tipo;
        l_interviniente_cuit := Obtener_CUIT(p_destinatario_id);

      END IF;

    ELSIF p_interviniente = 'DESTINO' THEN
      l_productor_id   := p_destinatario_id;
      l_productor_tipo := 'ACONDICIONAMIENTO';
      l_interviniente_cuit := Obtener_CUIT(p_destino_id);

    ELSIF p_interviniente = 'TITULAR_CP' THEN
      l_destino_id      := p_titular_cp_id;
      l_destino_site_id := p_titular_cp_site_id;
      l_destino_zona    := NULL;

      IF p_intermediario_id IS NOT NULL AND
         p_intermediario_retiro = 'Y' THEN
        l_productor_id   := p_intermediario_id;
        l_productor_tipo := p_intermediario_tipo;
        l_interviniente_cuit := Obtener_CUIT(p_titular_cp_id);

      ELSIF p_rtte_comercial_id IS NOT NULL AND
            p_rtte_comercial_retiro = 'Y' THEN
        l_productor_id   := p_rtte_comercial_id;
        l_productor_tipo := p_rtte_comercial_tipo;
        l_interviniente_cuit := Obtener_CUIT(p_titular_cp_id);

      END IF;

    END IF;

    OPEN cCont ( p_contrato_id     => p_contrato_id
               , p_item_id         => p_item_id
               , p_lot_no          => p_lot_no
               , p_fecha_recepcion => p_fecha_recepcion
               , p_productor_id    => l_productor_id
               , p_productor_tipo  => NVL(l_productor_tipo, 'OPERADOR')
               , p_interviniente_cuit => l_interviniente_cuit
               , p_destino_id      => l_destino_id
               , p_destino_site_id => l_destino_site_id
               , p_destino_zona    => l_destino_zona
               );
    LOOP
      FETCH cCont INTO rCont;
      l_contrato_id := rCont.contrato_id;
      EXIT WHEN cCont%NOTFOUND OR l_contrato_id = p_contrato_id;
    END LOOP;
    CLOSE cCont;

    RETURN l_contrato_id;
  EXCEPTION
    WHEN Others THEN
      RETURN NULL;
  END Valida_Contrato_Compra;


/****************************************************************************
 *                                                                          *
 * Name    : Contratos_Compra_boletin                                       *
 * Purpose :Valida que el contrato sea valido para el boletin de calidad    *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Contratos_Compra_boletin ( p_titular_cp_cuit       NUMBER
                                    , p_titular_cp_estab_id   NUMBER
                                    , p_provincia_origen      VARCHAR2
                                    , p_localidad_origen      VARCHAR2
                                    , p_destino_cuit          NUMBER
                                    , p_destino_estab_id      NUMBER
                                    , p_provincia_destino     VARCHAR2
                                    , p_localidad_destino     VARCHAR2
                                    --
                                    , p_item_id               NUMBER
                                    , p_lot_no                VARCHAR2
                                    , p_operating_unit        NUMBER
                                    , p_retiro_propio_flag           VARCHAR2   -- CR2382 Abre las marca de retiro
                                    , p_retiro_terceros_flag           VARCHAR2    -- CR2382 Abre las marca de retiro                                    
                                    , p_contrato_id           NUMBER
                                    ) RETURN NUMBER IS
    CURSOR c1 IS
      SELECT titular_cp_cuit, titular_cp_contrato_id
           , intermediario_cuit, intermediario_contrato_id
           , rtte_comercial_cuit, rtte_comercial_contrato_id
           , destinatario_cuit, destinatario_contrato_id
           , destino_cuit, destino_contrato_id
      FROM xx_tcg_cartas_porte_all
      WHERE 1=1
      AND anulado_flag = 'N'
      AND pesaje_salida_flag = 'N'
       -- CR2382 Cambia la lógica de la obtencion de retiros
      AND (CASE 
                when p_retiro_propio_flag = 'Y'  
                        AND (intermediario_retiro = 'Y' or  rtte_comercial_retiro = 'Y')
                        AND  titular_cp_contrato_id                  is null 
                        AND  intermediario_contrato_id            is null
                        AND  rtte_comercial_contrato_id          is null 
                        AND destinatario_contrato_id               is null
                        AND destino_contrato_id                     IS NULL then
                        'Y'
                when p_retiro_terceros_flag  = 'Y'  
                        AND (intermediario_retiro = 'Y' OR  rtte_comercial_retiro = 'Y')
                        AND  titular_cp_contrato_id is not null then 
                        'Y'
                when  p_retiro_propio_flag = 'N' 
                         AND  p_retiro_terceros_flag  = 'N' 
                        AND intermediario_retiro = 'N' 
                        AND   rtte_comercial_retiro = 'N'
                         AND  titular_cp_contrato_id is null                        
                        AND  ( intermediario_contrato_id               is not null
                                  OR  rtte_comercial_contrato_id        is not null 
                                 OR destinatario_contrato_id             is not null
                                OR destino_contrato_id                    is not null ) then
                           'Y'              
                when  p_retiro_propio_flag = 'N' 
                         AND  p_retiro_terceros_flag  = 'N' 
                         AND (intermediario_retiro = 'Y' or  rtte_comercial_retiro = 'Y')
                         AND  titular_cp_contrato_id is null 
                         AND  ( intermediario_contrato_id           is not null
                              OR  rtte_comercial_contrato_id          is not null 
                              OR destinatario_contrato_id               is not null
                             OR destino_contrato_id                      is not null ) then
                             'Y'
                  ELSE
                            'N'
                  END) = 'Y'
     /* AND ( ( p_retiro_flag = 'N' AND
              intermediario_retiro = 'N' AND
              rtte_comercial_retiro = 'N'
            )OR
            ( p_retiro_flag = 'Y' AND
              ( intermediario_retiro = 'Y' OR
                rtte_comercial_retiro = 'Y'
              )
            )
          )*/
           -- CR2382 fin
      AND item_id = p_item_id
      AND lot_no  = p_lot_no
      AND titular_cp_cuit = p_titular_cp_cuit
      AND ( titular_cp_estab_id = p_titular_cp_estab_id OR
            ( titular_cp_provincia = p_provincia_origen AND
              titular_cp_localidad = p_localidad_origen
            )
          )
      AND destino_cuit = p_destino_cuit
      AND ( destino_estab_id = p_destino_estab_id OR
            ( destino_provincia = p_provincia_destino AND
              destino_localidad = p_localidad_destino
            )
          );

    l_ou_cuit     NUMBER;
    l_cc_flag     BOOLEAN := FALSE;
  BEGIN
    SELECT operating_unit_cuit
    INTO l_ou_cuit
    FROM xx_tcg_parametros_compania
    WHERE operating_unit = p_operating_unit;


    FOR r1 IN c1 LOOP
      IF ( l_ou_cuit = r1.titular_cp_cuit AND
           p_contrato_id = r1.titular_cp_contrato_id
         ) OR
         ( l_ou_cuit = r1.intermediario_cuit AND
           p_contrato_id = r1.intermediario_contrato_id
         ) OR
         ( l_ou_cuit = r1.rtte_comercial_cuit AND
           p_contrato_id = r1.rtte_comercial_contrato_id
         ) OR
         ( l_ou_cuit = r1.destinatario_cuit AND
           p_contrato_id = r1.destinatario_contrato_id
         ) OR
         ( l_ou_cuit = r1.destino_cuit AND
           p_contrato_id = r1.destino_contrato_id
         ) THEN
        l_cc_flag := TRUE;
        EXIT;
      END IF;
    END LOOP;

    IF l_cc_flag THEN
      RETURN p_contrato_id;
    ELSE
      RETURN -1;
    END IF;
  END Contratos_Compra_boletin;


/***************************************************************************
 *                                                                          *
 * Name    : Cliente_PV                                                     *
 * Purpose : Devuelve el party_id de los intervinientes habilitados como    *
 *           clientes para la asociacion de PV                              *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Cliente_PV ( p_carta_porte_id        NUMBER
                      , p_empresa_id            NUMBER
                      , p_reacondicionadora     VARCHAR2 DEFAULT NULL
                      ) RETURN NUMBER IS
    CURSOR cClientes ( p_empresa_id NUMBER ) IS
      SELECT cliente_id, retiro, reacondicionadora, orden
      FROM
      ( SELECT cp.titular_cp_id cliente_id
             , 'N' retiro
             , 'N' reacondicionadora
             , 1 orden
        FROM xx_tcg_cartas_porte cp
        WHERE cp.carta_porte_id = p_carta_porte_id
        AND ( p_empresa_id IS NULL OR
              ( p_empresa_id IS NOT NULL AND
                XX_TCG_FUNCTIONS_PKG.Es_Empresa_Grupo_c(XX_TCG_FUNCTIONS_PKG.Obtener_CUIT(cp.titular_cp_id)) = 'Y' AND
                ( ( cp.intermediario_cuit IS NULL AND
                    cp.rtte_comercial_cuit IS NULL
                  ) OR
                  ( cp.intermediario_cuit IS NOT NULL AND
                    cp.intermediario_cuit != cp.titular_cp_cuit
                  ) OR
                  ( cp.intermediario_cuit IS NULL AND
                    cp.rtte_comercial_cuit IS NOT NULL AND
                    cp.rtte_comercial_cuit != cp.titular_cp_cuit
                  )
                )
              )
            )
        UNION ALL
        SELECT cp.intermediario_id     cliente_id
             , cp.intermediario_retiro retiro
             , 'N' reacondicionadora
             , 2 orden
        FROM xx_tcg_cartas_porte cp
        WHERE cp.carta_porte_id = p_carta_porte_id
        AND ( p_empresa_id IS NULL OR
              ( p_empresa_id IS NOT NULL AND
                XX_TCG_FUNCTIONS_PKG.Es_Empresa_Grupo_c(XX_TCG_FUNCTIONS_PKG.Obtener_CUIT(cp.intermediario_id)) = 'Y' AND
                ( cp.rtte_comercial_cuit IS NULL OR
                  ( cp.rtte_comercial_cuit IS NOT NULL AND
                    cp.rtte_comercial_cuit != cp.intermediario_cuit
                  )
                )
              )
            )
        UNION ALL
        SELECT cp.rtte_comercial_id     cliente_id
             , cp.rtte_comercial_retiro retiro
             , 'N' reacondicionadora
             , 3 orden
        FROM xx_tcg_cartas_porte cp
        WHERE cp.carta_porte_id = p_carta_porte_id
        AND ( p_empresa_id IS NULL OR
              ( p_empresa_id IS NOT NULL AND
                XX_TCG_FUNCTIONS_PKG.Es_Empresa_Grupo_c(XX_TCG_FUNCTIONS_PKG.Obtener_CUIT(cp.rtte_comercial_id)) = 'Y'
              )
            )
        UNION ALL
        SELECT cp.destinatario_id cliente_id
             , 'N' retiro
             , 'N' reacondicionadora
             , 4 orden
        FROM xx_tcg_cartas_porte cp
        WHERE cp.carta_porte_id = p_carta_porte_id
        AND ( p_empresa_id IS NULL OR
              ( p_empresa_id IS NOT NULL AND
                XX_TCG_FUNCTIONS_PKG.Es_Empresa_Grupo_c(XX_TCG_FUNCTIONS_PKG.Obtener_CUIT(cp.destinatario_id)) = 'Y'
              )
            )
        UNION ALL
        SELECT cp.destino_id cliente_id
             , 'N' retiro
             , XX_TCG_FUNCTIONS_PKG.Proveedor_Reac(cp.destino_id) reacondicionadora
             , 5 orden
        FROM xx_tcg_cartas_porte cp
        WHERE cp.carta_porte_id = p_carta_porte_id
        AND ( p_empresa_id IS NULL OR
              ( p_empresa_id IS NOT NULL AND
                ( XX_TCG_FUNCTIONS_PKG.Es_Empresa_Grupo_c(XX_TCG_FUNCTIONS_PKG.Obtener_CUIT(cp.destino_id)) = 'Y' OR
                  XX_TCG_FUNCTIONS_PKG.Proveedor_Reac(cp.destino_id) = 'Y'
                )
              )
           )
      )
      WHERE 1=1
      AND ( p_empresa_id IS NULL OR p_empresa_id = cliente_id )
      ORDER BY orden;

    rClientes               cClientes%ROWTYPE;
    l_titular_id            NUMBER;
    l_intermediario_id      NUMBER;
    l_intermediario_retiro  VARCHAR2(1);
    l_rtte_comercial_id     NUMBER;
    l_rtte_comercial_retiro VARCHAR2(1);
    l_destinatario_id       NUMBER;
    l_destino_id            NUMBER;
    l_destino_reac          VARCHAR2(1);
    l_orden                 NUMBER;
  BEGIN
    OPEN cClientes (p_empresa_id);
    FETCH cClientes INTO rClientes;
    l_orden := rClientes.orden;
    CLOSE cClientes;

    FOR rClientes IN cClientes (NULL) LOOP
      IF rClientes.orden = 1 THEN
        l_titular_id := rClientes.cliente_id;
      ELSIF rClientes.orden = 2 THEN
        l_intermediario_id     := rClientes.cliente_id;
        l_intermediario_retiro := rClientes.retiro;
      ELSIF rClientes.orden = 3 THEN
        l_rtte_comercial_id     := rClientes.cliente_id;
        l_rtte_comercial_retiro := rClientes.retiro;
      ELSIF rClientes.orden = 4 THEN
        l_destinatario_id := rClientes.cliente_id;
      ELSIF rClientes.orden = 5 THEN
        l_destino_id := rClientes.cliente_id;
        l_destino_reac := rClientes.reacondicionadora;
      END IF;
    END LOOP;

    --Excepciones
    IF l_orden = 4 AND --evaluo destinatario
       ( l_destinatario_id = l_destino_id OR
         l_destino_reac = 'Y'
       ) THEN
      --DBMS_OUTPUT.PUT_LINE('NULL');
      RETURN NULL;
    ELSIF l_orden = 4 AND
          l_destinatario_id IS NOT NULL THEN
      --DBMS_OUTPUT.PUT_LINE('-2001');
      RETURN -2001;
    END IF;

    IF p_reacondicionadora IS NULL THEN
      IF l_orden = 1 THEN
        IF NVL(l_intermediario_id,p_empresa_id) != p_empresa_id THEN
          --DBMS_OUTPUT.PUT_LINE(l_intermediario_id);
          IF l_intermediario_retiro = 'Y' THEN
            RETURN -2001;
          ELSE
            RETURN l_intermediario_id;
          END IF;
        END IF;
      END IF;

      IF l_orden IN (1,2) THEN
        IF NVL(l_rtte_comercial_id,p_empresa_id) != p_empresa_id THEN
          --DBMS_OUTPUT.PUT_LINE(l_rtte_comercial_id);
          IF l_rtte_comercial_retiro = 'Y' THEN
            RETURN -2001;
          ELSE
            RETURN l_rtte_comercial_id;
          END IF;
        END IF;
      END IF;

      IF l_orden IN (1,2,3) THEN
        IF NVL(l_destinatario_id,p_empresa_id) != p_empresa_id THEN
          --DBMS_OUTPUT.PUT_LINE(l_destinatario_id);
          RETURN l_destinatario_id;
        END IF;
      END IF;

      IF l_orden IN (1,2,3,4) THEN
        IF NVL(l_destino_id,p_empresa_id) != p_empresa_id THEN
          --DBMS_OUTPUT.PUT_LINE(l_destino_id);
          RETURN l_destino_id;
        END IF;
      END IF;
    ELSIF p_reacondicionadora = 'Y' AND
          l_destino_reac = 'Y' AND
          l_destinatario_id != l_destino_id THEN
      IF l_orden = 3 OR
         ( l_orden = 2 AND
           l_rtte_comercial_id IS NULL
         ) OR
         ( l_orden = 1 AND
           l_rtte_comercial_id IS NULL AND
           l_intermediario_id IS NULL
         ) THEN
        RETURN l_destino_id;
      END IF;

    END IF;

    RETURN NULL;

  END Cliente_PV;


/***************************************************************************
 *                                                                          *
 * Name    : Interviene_CP                                                  *
 * Purpose : Devuelve 1 si la unidad operativa donde estoy parado existe    *
 *           entre los intervinientes de la CP                              *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Interviene_CP ( p_carta_porte_id        NUMBER
                         , p_operating_unit        NUMBER
                         ) RETURN NUMBER IS
    l_operating_unit_cuit NUMBER;
    l_return  NUMBER;
  BEGIN
    SELECT operating_unit_cuit
    INTO l_operating_unit_cuit
    FROM xx_tcg_parametros_compania
    WHERE operating_unit = p_operating_unit;

    SELECT DISTINCT 1
    INTO l_return
    FROM xx_tcg_cartas_porte
    WHERE 1=1
    AND carta_porte_id = p_carta_porte_id
    AND ( titular_cp_cuit     = l_operating_unit_cuit OR
          intermediario_cuit  = l_operating_unit_cuit OR
          rtte_comercial_cuit = l_operating_unit_cuit OR
          destinatario_cuit   = l_operating_unit_cuit OR
          destino_cuit        = l_operating_unit_cuit
        );

    RETURN 1;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END Interviene_CP;


 /***************************************************************************
 *                                                                          *
 * Name    : Calcular_Costo_Distancia                                       *
 * Purpose : Calcula el costo del transporte del grano                      *
 *                                                                          *
 ****************************************************************************/
  FUNCTION Calcular_Costo_Distancia ( p_origen                  IN  NUMBER
                                    , p_direccion_origen        IN  NUMBER
                                    , p_localidad_origen        IN  VARCHAR2
                                    --
                                    , p_destino                 IN  NUMBER
                                    , p_direccion_destino       IN  NUMBER
                                    , p_localidad_destino       IN  VARCHAR2
                                    , p_zona_destino            IN  VARCHAR2
                                    --
                                    , p_actividad               IN  VARCHAR2
                                    , p_transportista           IN  NUMBER
                                    , p_producto_oncca          IN  VARCHAR2
                                    , p_fecha_envio             IN  DATE
                                    , p_grupo_control           IN  VARCHAR2
                                    , p_kg_neto                 IN  NUMBER
                                    , p_enganchada              IN  VARCHAR2
                                    --
                                    , x_distancia              OUT NUMBER
                                    , x_tiempo_maximo          OUT NUMBER
                                    , x_tarifa_cp_xton         OUT NUMBER
                                    , x_costo_flete_xton       OUT NUMBER
                                    , x_costo_flete_final      OUT NUMBER
                                    , x_distancia_id           OUT NUMBER
                                    , x_negociacion_id         OUT NUMBER
                                    ) RETURN VARCHAR2 IS

    CURSOR cDistancia IS
      SELECT DISTINCT
             dist.distancia_id
           , dist.distancia
           , dist.tarifa_impresion
           , dist.tarifa_enganchada
           , dist.tiempo_minimo
           , dist.tiempo_maximo
           , dist.vigencia_hasta
           , dist.localidad_origen
           , loc.zona      zona_origen
           , loc.subzona   sub_zona_origen
           , dist.grupo_control
           , DECODE(dist.tipo_origen
                   , 'Tercero', 1
                   , 'Propio', 2
                   , 'Localidad', 3
                   ) priority_orig
           , DECODE(dist.tipo_destino
                   , 'Tercero', 1
                   , 'Propio', 2
                   , 'Localidad', 3
                   , 'Zona', 4
                   ) priority_dest
      FROM xx_aco_tarifa_distancia  dist
         , xx_tcg_localidades       loc
      WHERE 1=1
      AND loc.loc_codigo(+) = dist.localidad_origen
      -- Origen
      AND (  ( dist.tipo_origen         = 'Tercero' AND
               dist.origen_id           = p_origen  AND
               dist.direccion_origen_id = p_direccion_origen
             ) OR
             ( dist.tipo_origen = 'Propio' AND
               dist.origen_id    = p_origen
             ) OR
             ( dist.tipo_origen      = 'Localidad' AND
               dist.localidad_origen = p_localidad_origen
             )
          )
      -- Destino
      AND ( ( dist.tipo_destino         = 'Tercero' AND
              dist.destino_id           = p_destino AND
              dist.direccion_destino_id = p_direccion_destino
            ) OR
            ( dist.tipo_destino  = 'Propio' AND
              dist.destino_id    = p_destino
            ) OR
            ( dist.tipo_destino         = 'Localidad' AND
              dist.localidad_destino    = p_localidad_destino
            ) OR
            ( dist.tipo_destino         = 'Zona' AND
              dist.direccion_destino_id = p_zona_destino
            )
         )
      -- Vigencia
      AND TRUNC(p_fecha_envio) <= NVL(dist.vigencia_hasta, SYSDATE+1)
      AND dist.grupo_control = p_grupo_control
      --AND z.zona        IS NOT NULL
      ORDER BY priority_orig, priority_dest;


    CURSOR cNegocia ( p_distancia  NUMBER
                    , p_localidad  VARCHAR2
                    , p_zona       VARCHAR2
                    , p_sub_zona   VARCHAR2
                    ) IS
      SELECT negociacion_id
           , tarifa_ref_hdr_id
           , margen
           , importe
           , aforo_um
           , aforo
           , vigencia_desde
           , vigencia_hasta
           , grupo_control
           , CASE
             WHEN ( transportista_id   = p_transportista   AND
                    item_oncca_code    = p_producto_oncca  AND
                    establecimiento_id = p_origen
                  ) THEN 1
             WHEN ( transportista_id   = p_transportista     AND
                    item_oncca_code    = p_producto_oncca    AND
                    productor_id       = p_origen            AND
                    sucursal_id        = p_direccion_origen
                  ) THEN 2
             WHEN ( transportista_id   = p_transportista   AND
                    item_oncca_code    = p_producto_oncca  AND
                    establecimiento_id IS NULL             AND
                    productor_id       IS NULL             AND
                    localidad          = p_localidad       AND
                    zona               = p_zona            AND
                    sub_zona           = p_sub_zona
                  ) THEN 3
             WHEN ( transportista_id   = p_transportista   AND
                    item_oncca_code    = p_producto_oncca  AND
                    establecimiento_id IS NULL             AND
                    productor_id       IS NULL             AND
                    localidad          IS NULL             AND
                    zona               = p_zona            AND
                    sub_zona           = p_sub_zona
                  ) THEN 4
             WHEN ( transportista_id   = p_transportista   AND
                    item_oncca_code    = p_producto_oncca  AND
                    establecimiento_id IS NULL             AND
                    productor_id       IS NULL             AND
                    localidad          IS NULL             AND
                    zona               = p_zona            AND
                    sub_zona           IS NULL
                  ) THEN 5
             WHEN ( transportista_id   = p_transportista   AND
                    item_oncca_code    IS NULL             AND
                    establecimiento_id = p_origen          AND
                    productor_id       IS NULL
                  ) THEN 6
             WHEN ( transportista_id   = p_transportista     AND
                    item_oncca_code    IS NULL               AND
                    establecimiento_id IS NULL               AND
                    productor_id       = p_origen            AND
                    sucursal_id        = p_direccion_origen
                  ) THEN 7
             WHEN ( transportista_id   = p_transportista   AND
                    item_oncca_code    IS NULL             AND
                    establecimiento_id IS NULL             AND
                    productor_id       IS NULL             AND
                    localidad          = p_localidad       AND
                    zona               = p_zona            AND
                    sub_zona           = p_sub_zona
                  ) THEN 8
             WHEN ( transportista_id   = p_transportista   AND
                    item_oncca_code    IS NULL             AND
                    establecimiento_id IS NULL             AND
                    productor_id       IS NULL             AND
                    localidad          IS NULL             AND
                    zona               = p_zona            AND
                    sub_zona           = p_sub_zona
                  ) THEN 9
             WHEN ( transportista_id   = p_transportista   AND
                    item_oncca_code    IS NULL             AND
                    establecimiento_id IS NULL             AND
                    productor_id       IS NULL             AND
                    localidad          IS NULL             AND
                    zona               = p_zona            AND
                    sub_zona           IS NULL
                  ) THEN 10
             WHEN ( transportista_id   IS NULL             AND
                    item_oncca_code    = p_producto_oncca  AND
                    establecimiento_id = p_origen          AND
                    productor_id       IS NULL
                  ) THEN 11
             WHEN ( transportista_id   IS NULL             AND
                    item_oncca_code    = p_producto_oncca  AND
                    establecimiento_id IS NULL             AND
                    productor_id       = p_origen          AND
                    sucursal_id        = p_direccion_origen
                  ) THEN 12
             WHEN ( transportista_id   IS NULL             AND
                    item_oncca_code    = p_producto_oncca  AND
                    establecimiento_id IS NULL             AND
                    productor_id       IS NULL             AND
                    localidad          = p_localidad       AND
                    zona               = p_zona            AND
                    sub_zona           = p_sub_zona
                  ) THEN 13
             WHEN ( transportista_id   IS NULL             AND
                    item_oncca_code    = p_producto_oncca  AND
                    establecimiento_id IS NULL             AND
                    productor_id       IS NULL             AND
                    localidad          IS NULL             AND
                    zona               = p_zona            AND
                    sub_zona           = p_sub_zona
                  ) THEN 14
             WHEN ( transportista_id   IS NULL             AND
                    item_oncca_code    = p_producto_oncca  AND
                    establecimiento_id IS NULL             AND
                    productor_id       IS NULL             AND
                    localidad          IS NULL             AND
                    zona               = p_zona            AND
                    sub_zona           IS NULL
                  ) THEN 15
             WHEN ( transportista_id   IS NULL    AND
                    item_oncca_code    IS NULL    AND
                    establecimiento_id = p_origen AND
                    productor_id       IS NULL
                  ) THEN 16
             WHEN ( transportista_id   IS NULL    AND
                    item_oncca_code    IS NULL    AND
                    establecimiento_id IS NULL    AND
                    productor_id       = p_origen AND
                    sucursal_id        = p_direccion_origen
                  ) THEN 17
             WHEN ( transportista_id   IS NULL  AND
                    item_oncca_code    IS NULL  AND
                    establecimiento_id IS NULL  AND
                    productor_id       IS NULL  AND
                    localidad          = p_localidad AND
                    zona               = p_zona AND
                    sub_zona           = p_sub_zona
                  ) THEN 18
             WHEN ( transportista_id   IS NULL  AND
                    item_oncca_code    IS NULL  AND
                    establecimiento_id IS NULL  AND
                    productor_id       IS NULL  AND
                    localidad          IS NULL  AND
                    zona               = p_zona AND
                    sub_zona           = p_sub_zona
                  ) THEN 19
             WHEN ( transportista_id   IS NULL  AND
                    item_oncca_code    IS NULL  AND
                    establecimiento_id IS NULL  AND
                    productor_id       IS NULL  AND
                    localidad          IS NULL  AND
                    zona               = p_zona AND
                    sub_zona           IS NULL
                  ) THEN 20
             END priority_line
      FROM xx_aco_tarifa_negociaciones
      WHERE 1=1
      AND actividad     = p_actividad
      AND grupo_control = p_grupo_control
      AND estado        = 'APPROVED'
      AND TRUNC(p_fecha_envio) BETWEEN vigencia_desde AND NVL(vigencia_hasta, SYSDATE+1)
      AND ( km_desde IS NULL OR
            p_distancia BETWEEN km_desde AND NVL(km_hasta, p_distancia)
          )
      --
      AND ( ( transportista_id   = p_transportista   AND
              item_oncca_code    = p_producto_oncca  AND
              establecimiento_id = p_origen
            ) OR
            ( transportista_id   = p_transportista     AND
              item_oncca_code    = p_producto_oncca    AND
              productor_id       = p_origen            AND
              sucursal_id        = p_direccion_origen
            ) OR
            ( transportista_id   = p_transportista   AND
              item_oncca_code    = p_producto_oncca  AND
              establecimiento_id IS NULL             AND
              productor_id       IS NULL             AND
              localidad          = p_localidad       AND
              zona               = p_zona            AND
              sub_zona           = p_sub_zona
            ) OR
            ( transportista_id   = p_transportista   AND
              item_oncca_code    = p_producto_oncca  AND
              establecimiento_id IS NULL             AND
              productor_id       IS NULL             AND
              localidad          IS NULL             AND
              zona               = p_zona            AND
              sub_zona           = p_sub_zona
            ) OR
            ( transportista_id   = p_transportista   AND
              item_oncca_code    = p_producto_oncca  AND
              establecimiento_id IS NULL             AND
              productor_id       IS NULL             AND
              localidad          IS NULL             AND
              zona               = p_zona            AND
              sub_zona           IS NULL
            ) OR
            ( transportista_id   = p_transportista   AND
              item_oncca_code    IS NULL             AND
              establecimiento_id = p_origen          AND
              productor_id       IS NULL
            ) OR
            ( transportista_id   = p_transportista   AND
              item_oncca_code    IS NULL             AND
              establecimiento_id IS NULL             AND
              productor_id       = p_origen          AND
              sucursal_id        = p_direccion_origen
            ) OR
            ( transportista_id   = p_transportista   AND
              item_oncca_code    IS NULL             AND
              establecimiento_id IS NULL             AND
              productor_id       IS NULL             AND
              localidad          = p_localidad       AND
              zona               = p_zona            AND
              sub_zona           = p_sub_zona
            ) OR
            ( transportista_id   = p_transportista   AND
              item_oncca_code    IS NULL             AND
              establecimiento_id IS NULL             AND
              productor_id       IS NULL             AND
              localidad          IS NULL             AND
              zona               = p_zona            AND
              sub_zona           = p_sub_zona
            ) OR
            ( transportista_id   = p_transportista   AND
              item_oncca_code    IS NULL             AND
              establecimiento_id IS NULL             AND
              productor_id       IS NULL             AND
              localidad          IS NULL             AND
              zona               = p_zona            AND
              sub_zona           IS NULL
            ) OR
            ( transportista_id   IS NULL             AND
              item_oncca_code    = p_producto_oncca  AND
              establecimiento_id = p_origen          AND
              productor_id       IS NULL
            ) OR
            ( transportista_id   IS NULL             AND
              item_oncca_code    = p_producto_oncca  AND
              establecimiento_id IS NULL             AND
              productor_id       = p_origen          AND
              sucursal_id        = p_direccion_origen
            ) OR
            ( transportista_id   IS NULL             AND
              item_oncca_code    = p_producto_oncca  AND
              establecimiento_id IS NULL             AND
              productor_id       IS NULL             AND
              localidad          = p_localidad       AND
              zona               = p_zona            AND
              sub_zona           = p_sub_zona
            ) OR
            ( transportista_id   IS NULL             AND
              item_oncca_code    = p_producto_oncca  AND
              establecimiento_id IS NULL             AND
              productor_id       IS NULL             AND
              localidad          IS NULL             AND
              zona               = p_zona            AND
              sub_zona           = p_sub_zona
            ) OR
            ( transportista_id   IS NULL             AND
              item_oncca_code    = p_producto_oncca  AND
              establecimiento_id IS NULL             AND
              productor_id       IS NULL             AND
              localidad          IS NULL             AND
              zona               = p_zona            AND
              sub_zona           IS NULL
            ) OR
            ( transportista_id   IS NULL    AND
              item_oncca_code    IS NULL    AND
              establecimiento_id = p_origen AND
              productor_id       IS NULL
            ) OR
            ( transportista_id   IS NULL    AND
              item_oncca_code    IS NULL    AND
              establecimiento_id IS NULL    AND
              productor_id       = p_origen AND
              sucursal_id        = p_direccion_origen
            ) OR
            ( transportista_id   IS NULL  AND
              item_oncca_code    IS NULL  AND
              establecimiento_id IS NULL  AND
              productor_id       IS NULL  AND
              localidad          = p_localidad AND
              zona               = p_zona AND
              sub_zona           = p_sub_zona
            ) OR
            ( transportista_id   IS NULL  AND
              item_oncca_code    IS NULL  AND
              establecimiento_id IS NULL  AND
              productor_id       IS NULL  AND
              localidad          IS NULL  AND
              zona               = p_zona AND
              sub_zona           = p_sub_zona
            ) OR
            ( transportista_id   IS NULL  AND
              item_oncca_code    IS NULL  AND
              establecimiento_id IS NULL  AND
              productor_id       IS NULL  AND
              localidad          IS NULL  AND
              zona               = p_zona AND
              sub_zona           IS NULL
            ) )
      ORDER BY priority_line, km_desde;

    rDist      cDistancia%ROWTYPE;
    rNegocia   cNegocia%ROWTYPE;

    l_tarifa               NUMBER;
    l_precio_margen        NUMBER;
    l_precio_aforo         NUMBER;
  BEGIN
    OPEN cDistancia;
    FETCH cDistancia INTO rDist;

    IF cDistancia%NOTFOUND THEN
      RETURN 'No existe distancia configurada.';
      CLOSE cDistancia;
    END IF;
    CLOSE cDistancia;

    x_distancia       := rDist.distancia;
    IF NVL(p_enganchada,'N') = 'N' THEN
      x_tarifa_cp_xton := rDist.tarifa_impresion;
    ELSE
      x_tarifa_cp_xton := rDist.tarifa_enganchada;
    END IF; --SD1976 de apuro

    OPEN cNegocia (rDist.distancia, rDist.localidad_origen, rDist.zona_origen, rDist.sub_zona_origen);
    FETCH cNegocia INTO rNegocia;

    IF cNegocia%NOTFOUND THEN
      RETURN 'No existe negociación configurada.';
      CLOSE cNegocia;
    END IF;
    CLOSE cNegocia;

    BEGIN
      SELECT tarifa
      INTO l_tarifa
      FROM xx_aco_tarifa_ref_dtl
      WHERE 1=1
      AND tarifa_ref_hdr_id = rNegocia.tarifa_ref_hdr_id
      AND distancia = rDist.distancia;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 'No existe tarifa configurada.';
    END;

    IF rNegocia.margen IS NOT NULL THEN
      x_costo_flete_xton := l_tarifa + (l_tarifa * rNegocia.margen / 100);
    ELSIF rNegocia.importe IS NOT NULL THEN
      x_costo_flete_xton := rNegocia.importe;
    END IF;

    IF NVL(p_enganchada,'N') = 'N' THEN
      x_tarifa_cp_xton := rDist.tarifa_impresion;
    ELSE
      x_tarifa_cp_xton := rDist.tarifa_enganchada;
      x_costo_flete_xton := rDist.tarifa_enganchada;
    END IF;

    IF rNegocia.aforo IS NOT NULL THEN
      IF rNegocia.aforo_um = 'KG' THEN
        x_costo_flete_final := x_costo_flete_xton * rNegocia.aforo / 1000;
      ELSIF rNegocia.aforo_um = '%' THEN
        x_costo_flete_xton := (x_costo_flete_xton + (x_costo_flete_xton * rNegocia.aforo / 100));
        x_costo_flete_final := x_costo_flete_xton * p_kg_neto;
      END IF;
    ELSE
      x_costo_flete_final := x_costo_flete_xton * p_kg_neto;
    END IF;

    x_distancia       := rDist.distancia;
    x_tiempo_maximo   := rDist.tiempo_maximo;
    x_distancia_id    := rDist.distancia_id;
    x_negociacion_id  := rNegocia.negociacion_id;

    RETURN NULL;
  END Calcular_Costo_Distancia;


  /***************************************************************************
  *                                                                          *
  * Name    : Recalcular_Costo_Distancia                                     *
  * Purpose : Devuelve los datos necesarios para el calculo de distancia     *
  *                                                                          *
  ****************************************************************************/
  FUNCTION Recalcular_Costo_Distancia ( p_negociacion_id     IN  NUMBER
                                      , p_costo_flete_xton   IN  NUMBER
                                      , p_kg_neto            IN  NUMBER
                                      --
                                      , x_costo_flete_final  OUT NUMBER
                                      ) RETURN VARCHAR2 IS
    l_aforo_um     VARCHAR2(50);
    l_aforo        NUMBER;
  BEGIN

    BEGIN
      SELECT aforo_um, aforo
      INTO l_aforo_um, l_aforo
      FROM xx_aco_tarifa_negociaciones
      WHERE 1=1
      AND negociacion_id = p_negociacion_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_aforo_um := NULL;
        l_aforo    := NULL;
    END;

    IF l_aforo IS NOT NULL THEN
      IF l_aforo_um = 'KG' THEN
        x_costo_flete_final := p_costo_flete_xton * l_aforo / 1000;
      ELSIF l_aforo_um = '%' THEN
        x_costo_flete_final := (p_costo_flete_xton + (p_costo_flete_xton * l_aforo / 100)) * p_kg_neto;
      END IF;
    ELSE
      x_costo_flete_final := p_costo_flete_xton * p_kg_neto;
    END IF;

    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN SQLERRM;
  END;


  /***************************************************************************
  *                                                                          *
  * Name    : Obtiene_Codigo_ONCCA                                           *
  * Purpose : Devuelve el código ONCCA del artículo dado                     *
  *                                                                          *
  ****************************************************************************/
  FUNCTION Obtiene_Codigo_ONCCA ( p_item_id  NUMBER ) RETURN VARCHAR2 IS
    l_oncca_code  VARCHAR2(150);
  BEGIN
    SELECT msi_dfv.xx_aco_codigo_oncca
    INTO l_oncca_code
    FROM mtl_system_items       msi
       , mtl_system_items_b_dfv msi_dfv
       , fnd_lookup_values_vl   lv
       , fnd_lookup_values_dfv  lv_dfv
    WHERE 1=1
    AND msi_dfv.row_id  = msi.rowid
    AND msi.enabled_flag = 'Y'
    AND msi_dfv.xx_aco_codigo_oncca IS NOT NULL
    AND lv.lookup_code  = msi_dfv.xx_aco_codigo_oncca
    AND lv.lookup_type  = 'XX_ACO_ESPECIES_ONCCA'
    AND lv_dfv.row_id   = lv.row_id
    AND lv_dfv.context  = lv.attribute_category
    AND msi.inventory_item_id = p_item_id
    AND msi.organization_id   = XX_TCG_FUNCTIONS_PKG.getMasterOrg
    ;

    RETURN l_oncca_code;
  EXCEPTION
    WHEN OTHERS THEN RETURN NULL;
  END;


  /***************************************************************************
  *                                                                          *
  * Name    : Obtiene_Especie_ONCCA                                          *
  * Purpose : Devuelve la especie ONCCA del artículo dado                    *
  *                                                                          *
  ****************************************************************************/
  FUNCTION Obtiene_Especie_ONCCA ( p_item_id  NUMBER ) RETURN VARCHAR2 IS
    l_especie_oncca  VARCHAR2(150);
  BEGIN
    SELECT lv_dfv.xx_aco_especies_oncca
    INTO l_especie_oncca
    FROM mtl_system_items       msi
       , mtl_system_items_b_dfv msi_dfv
       , fnd_lookup_values_vl   lv
       , fnd_lookup_values_dfv  lv_dfv
    WHERE 1=1
    AND msi_dfv.row_id  = msi.rowid
    AND msi.enabled_flag = 'Y'
    AND msi_dfv.xx_aco_codigo_oncca IS NOT NULL
    AND lv.lookup_code  = msi_dfv.xx_aco_codigo_oncca
    AND lv.lookup_type  = 'XX_ACO_ESPECIES_ONCCA'
    AND lv_dfv.row_id   = lv.row_id
    AND lv_dfv.context  = lv.attribute_category
    AND msi.inventory_item_id = p_item_id
    AND msi.organization_id   = XX_TCG_FUNCTIONS_PKG.getMasterOrg
    ;

    RETURN l_especie_oncca;
  EXCEPTION
    WHEN OTHERS THEN RETURN NULL;
  END;


  /***************************************************************************
  *                                                                          *
  * Name    : Es_Ubicacion_COM                                               *
  * Purpose : Devuelve si es ubicación comercial                             *
  *                                                                          *
  ****************************************************************************/
  FUNCTION Es_Ubicacion_COM ( p_inv_location_id  NUMBER ) RETURN VARCHAR2 IS
    l_ub_com VARCHAR2(10);
  BEGIN
    SELECT mil_dfv.xx_aco_ubicacion_comercial
    INTO l_ub_com
    FROM mtl_item_locations     mil
       , mtl_item_locations_dfv mil_dfv
    WHERE 1=1
    AND mil_dfv.row_id = mil.rowid
    AND mil.inventory_location_id = p_inv_location_id;

    RETURN NVL(l_ub_com, 'N');
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END Es_Ubicacion_COM;


  /***************************************************************************
  *                                                                          *
  * Name    : Derivar_PTT                                                    *
  * Purpose : Derivar proyecto, tarea y tipo de erogacion para ubi COM       *
  *                                                                          *
  ****************************************************************************/
  PROCEDURE Derivar_PTT ( p_titular_cuit           NUMBER
                        , p_titular_estab          NUMBER
                        , p_item_id                NUMBER
                        , p_lot_no                 VARCHAR2
                        , x_proyecto_id     IN OUT NUMBER
                        , x_tarea_id        IN OUT NUMBER
                        , x_tipo_erogacion  IN OUT VARCHAR2
                        , x_error_msg       IN OUT VARCHAR2
                        ) IS
    l_main_cursor_stmt   VARCHAR2(4000);
    TYPE mainCurTyp      IS REF CURSOR;
    l_main_cursor        mainCurTyp;
    rOrgInfo             XX_TCG_FUNCTIONS_PKG.trOrgInfo;
    l_org_id             NUMBER;
    eError               EXCEPTION;
  BEGIN
    l_main_cursor_stmt := XX_TCG_FUNCTIONS_PKG.getMainCursor
    ||'AND pc.operating_unit_cuit = '||p_titular_cuit||' '||chr(10)
    ||'AND est.establecimiento_id = '||p_titular_estab||' '||chr(10)
    ||'AND msi_dfv.xx_tcg_tipos NOT IN (''REACONDICIONADOR'', ''PUERTO'') ';

    OPEN l_main_cursor FOR l_main_cursor_stmt;
    FETCH l_main_cursor INTO rOrgInfo;
    l_org_id := rOrgInfo.organization_id;
    CLOSE l_main_cursor;

    IF l_org_id IS NULL THEN
      x_error_msg := 'Error derivando proyecto y tarea. No fue posible deriviar Organización.';
      RAISE eError;
    END IF;

    BEGIN
      SELECT ppa.project_id
           , pt.task_id
      INTO x_proyecto_id
         , x_tarea_id
      FROM pa_projects_all        ppa
         , pa_tasks               pt
         , pa_tasks_dfv           pt_dfv
         , mtl_system_items       msi
         , mtl_system_items_b_dfv msi_dfv
      WHERE 1=1
      AND pt.project_id = ppa.project_id
      AND pt_dfv.rowid  = pt.rowid
      AND msi_dfv.rowid = msi.rowid
      AND msi_dfv.xx_aco_producto = pt_dfv.xx_pa_product
      --
      AND ppa.template_flag != 'Y'
      AND ppa.enabled_flag   = 'Y'
      AND ppa.project_status_code in ('PENDING_CLOSE', 'APPROVED')
      AND pt_dfv.xx_opm_tt = 'Alta'
      AND msi.organization_id = XX_TCG_FUNCTIONS_PKG.getMasterOrg
      --
      AND ppa.carrying_out_organization_id = l_org_id
      AND ppa.segment1  LIKE '%'||p_lot_no||'%'
      AND msi.inventory_item_id  = p_item_id
      ;
    EXCEPTION
      WHEN OTHERS THEN
        x_error_msg := 'Error derivando proyecto y tarea. '||SQLERRM;
        RAISE eError;
    END;


    BEGIN
      SELECT pet.expenditure_type
      INTO x_tipo_erogacion
      FROM pa_transaction_controls  ptc
         , pa_expenditure_types     pet
         , pa_expenditure_types_dfv pet_dfv
      WHERE 1=1
      AND pet.expenditure_category = ptc.expenditure_category
      AND pet_dfv.row_id     = pet.rowid
      --
      AND pet_dfv.xx_opm_ipt = 'YES'
      --
      AND ptc.project_id = x_proyecto_id
      AND ptc.task_id    = x_tarea_id
      ;
    EXCEPTION
      WHEN OTHERS THEN
        x_error_msg := 'Error derivando tipo de erogación. '||SQLERRM;
        RAISE eError;
    END;

  EXCEPTION
    WHEN eError THEN
      NULL;
    WHEN OTHERS THEN
      x_error_msg := 'Error derivando proyecto, tarea y tipo de erogación. '||SQLERRM;
  END Derivar_PTT;


  FUNCTION GET_GRUPO_CONTROL_CP_CTG (p_carta_porte_id IN NUMBER DEFAULT NULL,
                                     p_nro_ctg        IN NUMBER DEFAULT NULL) RETURN VARCHAR2
  IS

    l_grupo_ctrl     VARCHAR2(5);
    l_grupo_1        NUMBER := 0;
    l_grupo_2        NUMBER := 0;

    TYPE r_GC IS RECORD
    (CUIT             VARCHAR2(20),
     GRUPO_CONTROL    VARCHAR2(5));

    TYPE t_GC_CTG IS TABLE OF r_GC INDEX BY BINARY_INTEGER;

    l_gc      t_GC_CTG;


  BEGIN

    IF (p_carta_porte_id IS NOT NULL) THEN

      BEGIN

        SELECT grupo_control
          INTO l_grupo_ctrl
          FROM XX_TCG_CARTAS_PORTE_ALL     xtcp
             , XX_TCG_PARAMETROS_COMPANIA  xtpc
         WHERE xtcp.carta_porte_id = p_carta_porte_id
           AND xtcp.operating_unit = xtpc.operating_unit;

      EXCEPTION
        WHEN no_data_found THEN
          l_grupo_ctrl := NULL;
      END;

    ELSIF (p_nro_ctg IS NOT NULL) THEN


      SELECT cuit_canjeador
           , cuit_corredor
           , cuit_remitente_comercial
           , cuit_solicitante
           , cuit_destino
           , cuit_destinatario
        INTO l_gc(1).cuit
           , l_gc(2).cuit
           , l_gc(3).cuit
           , l_gc(4).cuit
           , l_gc(5).cuit
           , l_gc(6).cuit
        FROM XX_ACO_CTGS_B
       WHERE nro_ctg = p_nro_ctg;


      FOR i IN 1..6 LOOP

        BEGIN
          SElECT grupo_control
            INTO l_gc(i).grupo_control
            FROM XX_TCG_PARAMETROS_COMPANIA xap
               , PO_VENDORS                 pv
           WHERE xap.vendor_id = pv.vendor_id
             AND pv.num_1099   = SUBSTR(l_gc(i).cuit,1,10);
        EXCEPTION
          WHEN no_data_found THEN
            l_gc(i).grupo_control := NULL;
        END;

        IF (l_gc(i).grupo_control = '01') THEN
          l_grupo_1 := l_grupo_1 + 1;
        ELSIF (l_gc(i).grupo_control = '02') THEN
          l_grupo_2 := l_grupo_2 + 1;
        END IF;

      END LOOP;

      IF (l_grupo_1 = 0 AND l_grupo_2 = 0) THEN
        RETURN NULL;
      ELSIF (l_grupo_1 > 0 AND l_grupo_2 = 0) THEN
        RETURN '01';
      ELSIF (l_grupo_1 = 0 AND l_grupo_2 > 0) THEN
        RETURN '02';
      ELSIF (l_grupo_1 > 0 AND l_grupo_2 > 0) THEN
        RETURN '99';
      END IF;

    END IF;


  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;

  END GET_GRUPO_CONTROL_CP_CTG;


END XX_TCG_FUNCTIONS_PKG;
/

exit
