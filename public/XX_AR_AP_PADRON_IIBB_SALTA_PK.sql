SET DEFINE OFF;
CREATE OR REPLACE PACKAGE BODY APPS."XX_AR_AP_PADRON_IIBB_SALTA_PK" AS


PROCEDURE print_log (p_message IN VARCHAR2) IS
BEGIN
fnd_file.put_line(fnd_file.log,p_message);
END;

FUNCTION CDATA(P_STR IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  return '<![CDATA[' || p_str || ']]>';
END CDATA;

PROCEDURE load_files (retcode   OUT NUMBER
                     ,errbuf    OUT VARCHAR2
                     ,p_path     IN VARCHAR2
                     ,p_file_ae  IN VARCHAR2
                     ,p_file_rf  IN VARCHAR2) IS

v_request_id        NUMBER;
v_conc_phase        VARCHAR2 (50);
v_conc_status       VARCHAR2 (50);
v_conc_dev_phase    VARCHAR2 (50);
v_conc_dev_status   VARCHAR2 (50);
v_conc_message      VARCHAR2 (2000);
v_message           VARCHAR2 (2000);
e_cust_exception EXCEPTION;

BEGIN

    print_log ('XX_AR_AP_PADRON_IIBB_SALTA_PK.LOAD_FILES (+)');

    /*Ejecuto el Loader de Padron Actividades Economicas Salta*/
    v_request_id := fnd_request.submit_request(
                                                'XBOL'
                                               ,'XXARPSAE'
                                               , ''
                                               , ''
                                               , FALSE
                                               , p_path||'/'||p_file_ae);
    IF v_request_id = 0 THEN
        v_message := fnd_message.get;
        print_log( 'Error ejecutando el concurrente XX OM Loader Padron Actividades Economicas Salta, Error: ' ||v_message || ', ' || sqlerrm);
        RAISE e_cust_exception;
    END IF;

    COMMIT;

    IF NOT fnd_concurrent.wait_for_request(
                          v_request_id
                         ,10
                         ,18000
                         ,v_conc_phase
                         ,v_conc_status
                         ,v_conc_dev_phase
                         ,v_conc_dev_status
                         ,v_conc_message) THEN
        v_message := fnd_message.get;
        print_log( 'Error ejecutando FND_REQUEST.WAIT_FOR_REQUEST. ' ||v_message || ' ' || SQLERRM);
        RAISE e_cust_exception;
    END IF;

    IF v_conc_dev_phase != 'COMPLETE' or v_conc_dev_status NOT IN ('NORMAL','WARNING') THEN
        v_message := fnd_message.get;
        print_log( 'Error en la ejecucion del concurrente XX OM Loader Padron Actividades Economicas Salta con nro. solicitud '     || to_char(v_request_id) || '. ' || v_message || ' ' || sqlerrm);
        print_log(       'Es posible que el archivo no haya sido encontrado o tenga algun error')      ;
        RAISE e_cust_exception;
    END IF;

    /*Ejecuto el Loader de Padron Riesgo Fiscal Salta*/
    v_request_id := fnd_request.submit_request(
                                                'XBOL'
                                               ,'XXARPSRF'
                                               , ''
                                               , ''
                                               , FALSE
                                               , p_path||'/'||p_file_rf);
    IF v_request_id = 0 THEN
        v_message := fnd_message.get;
        print_log( 'Error ejecutando el concurrente XX AR Loader Padron Riesgo Fiscal Salta, Error: ' ||v_message || ', ' || sqlerrm);
        RAISE e_cust_exception;
    END IF;

    COMMIT;

    IF NOT fnd_concurrent.wait_for_request(
                          v_request_id
                         ,10
                         ,18000
                         ,v_conc_phase
                         ,v_conc_status
                         ,v_conc_dev_phase
                         ,v_conc_dev_status
                         ,v_conc_message) THEN
        v_message := fnd_message.get;
        print_log( 'Error ejecutando FND_REQUEST.WAIT_FOR_REQUEST. ' ||v_message || ' ' || SQLERRM);
        RAISE e_cust_exception;
    END IF;

    IF v_conc_dev_phase != 'COMPLETE' or v_conc_dev_status NOT IN ('NORMAL','WARNING') THEN
        v_message := fnd_message.get;
        print_log( 'Error en la ejecucion del concurrente XX AR Loader Padron Riesgo Fiscal Salta con nro. solicitud '     || to_char(v_request_id) || '. ' || v_message || ' ' || sqlerrm);
        print_log(       'Es posible que el archivo no haya sido encontrado o tenga algun error')      ;
        RAISE e_cust_exception;
    END IF;

    print_log ('XX_AR_AP_PADRON_IIBB_SALTA_PK.LOAD_FILES (-)');

EXCEPTION
 WHEN e_cust_exception THEN
   retcode := 1;
   print_log (errbuf);
   print_log ('XX_AR_AP_PADRON_IIBB_SALTA_PK.LOAD_FILES (!)');
 WHEN OTHERS THEN
   retcode := 2;
   errbuf  := 'Error OTHERS en LOAD_FILES. Error: '||SQLERRM;
   print_log (errbuf);
   Print_log ('XX_AR_AP_PADRON_IIBB_SALTA_PK.LOAD_FILES (!)');
   RAISE_APPLICATION_ERROR(-20000,errbuf);
END;

FUNCTION INSERTAR_IIBB_SITE  ( p_address_id          IN jl_zz_ar_tx_cus_cls_all.address_id%TYPE
                             , p_org_id              IN jl_zz_ar_tx_cus_cls_all.org_id%TYPE
                             , p_contributor_class   IN jl_zz_ar_tx_att_cls_all.tax_attr_class_code%TYPE
                             , p_tax_category_id     IN jl_zz_ar_tx_att_cls_all.tax_category_id%TYPE       DEFAULT NULL
                             , p_tax_attribute_value IN jl_zz_ar_tx_cus_cls_all.tax_attribute_value%TYPE   DEFAULT NULL
                             ) RETURN BOOLEAN IS

    r_iibb_padron_pkg    jl_zz_ar_tx_cus_cls_all%ROWTYPE;

    CURSOR c_tax_vals ( c_org_id                 jl_zz_ar_tx_att_cls_all.org_id%TYPE
                      , c_tax_attr_class_code    jl_zz_ar_tx_att_cls_all.tax_attr_class_code%TYPE
                      , c_address_id             jl_zz_ar_tx_cus_cls_all.address_id%TYPE
                      , c_tax_category_id        jl_zz_ar_tx_att_cls_all.tax_category_id%TYPE
                      , c_tax_attribute_value    jl_zz_ar_tx_att_cls_all.tax_attribute_value%TYPE
                      ) IS
      SELECT c_tax_attr_class_code tax_attr_class_code
           , to_number(c_tax_category_id) tax_category_id
           , cus_tax_attribute tax_attribute_name
           , c_tax_attribute_value tax_attribute_value
        FROM JL_ZZ_AR_TX_CATEG_ALL
       WHERE org_Id          = c_org_id
         AND tax_category_Id = c_tax_category_id
         AND NOT EXISTS (SELECT 1
                           FROM APPS.jl_zz_ar_tx_cus_cls_all  jzatcca
                          WHERE jzatcca.tax_category_id     = c_tax_category_id
                            AND jzatcca.org_id              = c_org_id
                            AND jzatcca.tax_attribute_name  = cus_tax_attribute
                            AND jzatcca.tax_attr_class_code = c_tax_attr_class_code
                            AND jzatcca.address_id          = c_address_id);

    r_tax_vals      c_tax_vals%rowtype;

    e_message VARCHAR2(2000);

  BEGIN

    fnd_file.put_line(fnd_file.log,'XX_AR_AP_PADRON_IIBB_SALTA_PK.INSERT_IIBB_SITE (+)');


    OPEN c_tax_vals ( c_org_id              => p_org_id
                    , c_tax_attr_class_code => p_contributor_class
                    , c_address_id          => p_address_id
                    , c_tax_category_id     => p_tax_category_id
                    , c_tax_attribute_value => p_tax_attribute_value);

    LOOP
      FETCH c_tax_vals INTO r_tax_vals;
      EXIT WHEN c_tax_vals%NOTFOUND;

      -- valores comunes para todos
      r_iibb_padron_pkg.address_id       := p_address_id;
      r_iibb_padron_pkg.enabled_flag     := 'Y';
      r_iibb_padron_pkg.last_update_date := sysdate;
      r_iibb_padron_pkg.last_updated_by  := fnd_profile.value('USER_ID');
      r_iibb_padron_pkg.org_id           := p_org_id;
      r_iibb_padron_pkg.creation_date    := sysdate;
      r_iibb_padron_pkg.created_by       := fnd_profile.value('USER_ID');

      -- valores propios del cursor
      r_iibb_padron_pkg.tax_attr_class_code  := r_tax_vals.tax_attr_class_code;
      r_iibb_padron_pkg.tax_category_id        := r_tax_vals.tax_category_id ;
      r_iibb_padron_pkg.tax_attribute_name   := r_tax_vals.tax_attribute_name;
      r_iibb_padron_pkg.tax_attribute_value   := r_tax_vals.tax_attribute_value;

      BEGIN
        SELECT jl_zz_ar_tx_cus_cls_s.NEXTVAL
          INTO r_iibb_padron_pkg.cus_class_id
          FROM dual;
      EXCEPTION
        WHEN OTHERS THEN
          e_message:= 'Error al buscar secuencia para r_iibb_padron_pkg';
          fnd_file.put_line(fnd_file.log, e_message);
          RETURN FALSE;
      END;

      IF r_iibb_padron_pkg.TAX_ATTRIBUTE_VALUE is null THEN
         e_message:= 'Error al buscar tax_attribute_value de address_id: '||p_address_id;
         fnd_file.put_line(fnd_file.log, e_message);
         RETURN FALSE;
      END IF;

      IF r_iibb_padron_pkg.CUS_CLASS_ID is not null and
         r_iibb_padron_pkg.ADDRESS_ID is not null and
         r_iibb_padron_pkg.TAX_ATTR_CLASS_CODE is not null and
         r_iibb_padron_pkg.TAX_CATEGORY_ID is not null and
         r_iibb_padron_pkg.TAX_ATTRIBUTE_NAME is not null and
         r_iibb_padron_pkg.TAX_ATTRIBUTE_VALUE is not null and
         r_iibb_padron_pkg.ENABLED_FLAG is not null THEN

         fnd_file.put_line(fnd_file.log, 'inserta ='||
                                         r_iibb_padron_pkg.CUS_CLASS_ID||'-'||
                                         r_iibb_padron_pkg.ADDRESS_ID||'-'||
                                         r_iibb_padron_pkg.TAX_ATTR_CLASS_CODE||'-'||
                                         r_iibb_padron_pkg.TAX_CATEGORY_ID||'-'||
                                         r_iibb_padron_pkg.TAX_ATTRIBUTE_NAME||'-'||
                                         r_iibb_padron_pkg.TAX_ATTRIBUTE_VALUE||'-'||
                                         r_iibb_padron_pkg.ENABLED_FLAG);

      INSERT INTO jl_zz_ar_tx_cus_cls_all
           VALUES r_iibb_padron_pkg;

      r_iibb_padron_pkg := null;

      ELSE
        e_message := 'no inserta por nulos ='||
                     r_iibb_padron_pkg.CUS_CLASS_ID||'-'||
                     r_iibb_padron_pkg.ADDRESS_ID||'-'||
                     r_iibb_padron_pkg.TAX_ATTR_CLASS_CODE||'-'||
                     r_iibb_padron_pkg.TAX_CATEGORY_ID||'-'||
                     r_iibb_padron_pkg.TAX_ATTRIBUTE_NAME||'-'||
                     r_iibb_padron_pkg.TAX_ATTRIBUTE_VALUE||'-'||
                     r_iibb_padron_pkg.ENABLED_FLAG;
        fnd_file.put_line(fnd_file.log, e_message);
        RETURN FALSE;
      END IF;

    END LOOP;
    CLOSE c_tax_vals;

    UPDATE hz_cust_acct_sites_all
       SET global_attribute9 = 'Y'
         , last_update_date  = sysdate
         , last_updated_by   =fnd_profile.value('USER_ID')
         , last_update_login = fnd_profile.value('LOGIN_ID')
     WHERE cust_acct_site_id  = p_address_id;

     fnd_file.put_line(fnd_file.log,'XX_AR_AP_PADRON_IIBB_SALTA_PK.INSERT_IIBB_SITE (-)');

   RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'XX_AR_AP_PADRON_IIBB_SALTA_PK.INSERT_IIBB_SITE (!)');
      e_message := 'Error general insertar_iibb_site, sqlerrm: '||sqlerrm;
      fnd_file.put_line(fnd_file.log, e_message);
      RETURN FALSE;

  END INSERTAR_IIBB_SITE;

    FUNCTION trae_location ( p_address_id  IN hz_cust_acct_sites_all.cust_acct_site_id%type,
                           pc_cust       IN hz_cust_acct_sites_all.cust_account_id%type,
                           pc_org        IN jl_zz_ar_tx_cus_cls_all.org_id%TYPE ) RETURN VARCHAR2
    IS
    l_retorna   varchar2(200);
  BEGIN
    BEGIN
      SELECT SUBSTR(NVL (arp_addr_pkg.format_address(hl.address_style
           , hl.address1
           , hl.address2
           , hl.address3
           , hl.address4
           , hl.city
           , hl.county
           , hl.state
           , hl.province
           , hl.postal_code
           , ftv.territory_short_name ), 'N/A') ,1,199)
        INTO l_retorna
        FROM hz_locations hl,
             fnd_territories_vl  ftv,
             hz_cust_acct_sites_all hcasa,
             hz_party_sites hps
       WHERE hcasa.cust_acct_site_id  = p_address_id
         AND hl.country               = ftv.territory_code(+)
         AND hps.location_id          = hl.location_id
         AND hcasa.party_site_id      = hps.party_site_id
         AND hcasa.cust_account_id    = pc_cust
         AND hcasa.org_id             = pc_org;
    EXCEPTION
      WHEN OTHERS THEN
        l_retorna :='N/D';
    END;
    RETURN SUBSTR(l_retorna,1,199);
  END;

PROCEDURE PROCESS_PADRON(P_STATUS            OUT VARCHAR2
                        ,P_ERROR_MESSAGE     OUT VARCHAR2
                        ,P_GRUPO_EMP         IN  VARCHAR2
                        ,P_ORG_ID            IN  NUMBER
                        ,P_CUSTOMER_ID       IN  NUMBER
                        ,P_START_DATE        IN  DATE
                        ,P_END_DATE          IN  DATE
                        ,P_TAX_CATEGORY      IN  VARCHAR2 --TOPSA
                        ,P_TAX_CATEGORY_VAT  IN  VARCHAR2
                        ,P_TAX_ATTR_LOC      IN  VARCHAR2 --Local
                        ,P_TAX_ATTR_LOC_RF   IN  VARCHAR2 --Local con Riesgo Fiscal
                        ,P_TAX_ATTR_MON      IN  VARCHAR2 --Monotributista
                        ,P_TAX_ATTR_MON_RF   IN  VARCHAR2 --Monotributista Con Riesgo Fiscal
                        ,P_TAX_ATTR_CM       IN  VARCHAR2 --Convenio Multilateral
                        ,P_TAX_ATTR_CM_RF    IN  VARCHAR2 --Convenio Multilateral con Riesgo Fiscal
                        ,P_TAX_ATTR_EX       IN  VARCHAR2 --Exento
                        ,P_COEF_CM_BI        IN  NUMBER
                        ,P_DRAFT             IN  VARCHAR2)
IS

  CURSOR c_orgs ( p_grupo_emp    IN VARCHAR2,
                  p_org_id       IN NUMBER,
                  p_tax_category IN VARCHAR2)
    IS
      SELECT hla1d.xx_grupo_emp,
             hla2d.establishment_type,
             haou.organization_id,
             haou.name,
             jzatc.tax_category,
             jzatc.tax_category_id,
             jzatc_dfv.xx_ar_tasa_castigo,
             jzatg.group_tax_id
        FROM hr_locations_all2_dfv        hla2d,
             hr_locations_all             hla,
             hr_all_organization_units    haou,
             hr_locations_all1_dfv        hla1d,
             hr_organization_information  hoi,
             jl_zz_ar_tx_att_cls_all      jzataca,
             jl_zz_ar_tx_categ_all        jzatc,
             jl_zz_ar_tx_categ_all_dfv    jzatc_dfv,
             jl_zz_ar_tx_groups_all       jzatg
       WHERE hla.ROWID                    = hla2d.row_id
         AND hla.ROWID                    = hla1d.row_id
         AND jzatc.ROWID                  = jzatc_dfv.row_id
         AND haou.organization_id         = hoi.organization_id
         AND jzatg.tax_category_id        = jzatc.tax_category_id
         AND jzatg.org_id                 = jzatc.org_id
         AND jzatg.start_date_active     <= TRUNC(SYSDATE)
         AND jzatg.end_date_active       >= TRUNC(SYSDATE)
         AND hoi.org_information1         = 'OPERATING_UNIT'
         AND haou.location_id             = hla.location_id
         AND hla1d.xx_grupo_emp           = NVL (p_grupo_emp, hla1d.xx_grupo_emp)
         AND haou.organization_id         = NVL (p_org_id, haou.organization_id)
         AND jzataca.org_id               = haou.organization_id
         AND jzatc.org_id                 = haou.organization_id
         AND jzataca.tax_attr_class_code  = hla2d.establishment_type
         AND jzataca.tax_category_id      = jzatc.tax_category_id
         AND jzataca.tax_attribute_value  = 'APPLICABLE'
         AND jzatc.tax_category        = NVL (p_tax_category, jzatc.tax_category)
         GROUP BY hla1d.xx_grupo_emp,
             hla2d.establishment_type,
             haou.organization_id,
             haou.name,
             jzatc.tax_category,
             jzatc.tax_category_id,
             jzatc_dfv.xx_ar_tasa_castigo,
             jzatg.group_tax_id;

  cursor c_sites(p_org_id number,p_customer_id NUMBER,p_tax_category VARCHAR2)
  is
  SELECT customer_name,
             customer_number,
             cuit,
             address_id,
             contributor_class,
             (SELECT DISTINCT 'Y'
                FROM jl_zz_ar_tx_cus_cls_all jzatcc
               WHERE jzatcc.tax_attr_class_code = q.contributor_class
                 AND jzatcc.org_id = q.org_id
                 AND jzatcc.tax_category_id = q.tax_category_id
                 AND address_id = q.address_id
             )
             existe_perfiles,
             province,
             customer_id,
             xx_convenio_mult,
             activity_code,
             xx_ar_provincia
        FROM (SELECT jzatc.org_id
                   , substrb(hp.party_name,1,50)              customer_name
                   , hca.account_number                       customer_number
                   , jzatc.tax_category
                   , hca.cust_account_id                      customer_id
                   , hcas.cust_acct_site_id                   address_id
                   , hl.province                              province
                   , hcas.global_attribute8                   contributor_class
                   , jzatc.tax_category_id
                   , hp.jgzz_fiscal_code||hca.global_attribute12     cuit
                   , hca_dfv.xx_convenio_mult
                   , xapusa.activity_code
                   , jzatc_dfv.xx_ar_provincia
                FROM hz_parties                 hp
                   , hz_cust_accounts           hca
                   , hz_cust_accounts_dfv       hca_dfv
                   , hz_party_sites             hps
                   , hz_cust_acct_sites_all     hcas
                   , hz_locations               hl
                   , jl_zz_ar_tx_categ_all      jzatc
                   , jl_zz_ar_tx_categ_all_dfv  jzatc_dfv
                   , xx_ar_padron_iibb_salta_ae xapusa
               WHERE hp.party_id               = hca.party_id
                 AND hp.party_id               = hps.party_id
                 AND hca.rowid                 = hca_dfv.row_id
                 AND hps.party_site_id         = hcas.party_site_id
                 AND hps.location_id           = hl.location_id
                 AND jzatc.ROWID               = jzatc_dfv.row_id
                 AND jzatc.org_id              = hcas.org_id
                 AND tax_category              = p_tax_category
                 AND hp.jgzz_fiscal_code = substr( xapusa.cuit,1,10)
              ) q
        WHERE q.customer_id  = NVL (p_customer_id, q.customer_id)
          AND q.org_id       = NVL (p_org_id, q.org_id)
          AND q.tax_category = NVL (p_tax_category, q.tax_category);

  l_tax_attribute_value  varchar2(240);
  l_tax_anterior         VARCHAR2(100);
  l_location             VARCHAR2(200);
  v_rf                   NUMBER;
  v_mon                  VARCHAR2(1);
  v_coef                 NUMBER;
  v_nrp                  NUMBER;
  v_exist_exc            NUMBER;
  l_user_id              number := fnd_global.user_id;
  l_login_id             number := fnd_global.login_id;
  v_tax_code             jl_zz_ar_tx_groups_all.tax_code%type;
  v_tax_vat              jl_zz_ar_tx_cus_cls_all.tax_attribute_value%type;
  e_sites_exception      EXCEPTION;
  e_cust_exception       EXCEPTION;

BEGIN

  fnd_file.put_line(fnd_file.log,'XX_AR_AP_PADRON_IIBB_SALTA_PK.PROCESS_PADRON (+)');


  fnd_file.put_line(fnd_file.output,'  <LIST_G_EXC>');
  fnd_file.put_line(fnd_file.output,'  <G_EXC>');

  fnd_file.put_line(fnd_file.output,'  <LIST_G_ORGS>');

  FOR r_orgs in c_orgs (p_grupo_emp, p_org_id, p_tax_category) LOOP

      fnd_file.put_line(fnd_file.output,'  <G_ORGS>');
      fnd_file.put_line(fnd_file.output,'  <ORG_NAME>'||cdata(r_orgs.name)||'</ORG_NAME>');
      fnd_file.put_line(fnd_file.output,'  <LIST_G_LINES>');

      FOR r_sites in c_sites (r_orgs.organization_id, p_customer_id, r_orgs.tax_category) LOOP
            fnd_file.put_line (fnd_file.log,'*****  c_sites para customer_name= '||r_sites.customer_name);
            fnd_file.put_line (fnd_file.log,' r_orgs.organization_id='||r_orgs.organization_id||' hay='||c_sites%rowcount);

            l_location  :=  trae_location (r_sites.address_id, r_sites.customer_id, r_orgs.organization_id);

            BEGIN

                fnd_file.put_line(fnd_file.output,' <G_LINES>');

                BEGIN

                  l_tax_anterior := '';

                  SELECT tax_attribute_value
                    INTO l_tax_anterior
                    FROM jl_zz_ar_tx_cus_cls_all
                   WHERE tax_attr_class_code = r_sites.contributor_class
                     AND address_id = r_sites.address_id
                     and org_id = r_orgs.organization_id
                     AND tax_category_id = r_orgs.tax_category_id ;

                EXCEPTION
                  WHEN OTHERS THEN
                    l_tax_anterior := '-';
                END;

                BEGIN
                   SELECT count(1) --Si hay un registro duplicado
                     INTO v_rf
                     FROM xx_ar_padron_iibb_salta_rf
                    WHERE cuit = r_sites.cuit
                      AND activity_code = r_sites.activity_code
                      AND nivel_riesgo_fiscal != 'SR'
                      AND status = 'N';
                EXCEPTION
                 WHEN no_data_found then
                   v_rf := 0;
                 WHEN too_many_rows then
                   v_rf := 1;
                 WHEN OTHERS THEN
                   v_rf := 0;
                END;

                print_log ('v_rf: '||v_rf);

                BEGIN
                  SELECT tax_attribute_value
                    INTO v_tax_vat
                    FROM jl_zz_ar_tx_cus_cls_all jzatcca
                        ,jl_zz_ar_tx_categ_all jzatca
                   WHERE jzatcca.tax_attr_class_code = r_sites.contributor_class
                     AND jzatcca.address_id = r_sites.address_id
                     and jzatcca.org_id = r_orgs.organization_id
                     and jzatcca.org_id = jzatca.org_id
                     AND jzatcca.tax_category_id = jzatca.tax_category_id
                     AND jzatca.tax_category = p_tax_category_vat;

                EXCEPTION
                  WHEN OTHERS THEN
                    v_tax_vat := null;
                END;

                print_log ('v_tax_vat: '||v_tax_vat);

                /*Calculamos el coeficiente*/
                IF v_tax_vat = 'MONOTRIBUTISTA' THEN --Si es monotributista
                   IF v_rf = 0 THEN
                     l_tax_attribute_value := P_TAX_ATTR_MON;
                   ELSE
                     l_tax_attribute_value := P_TAX_ATTR_MON_RF;
                   END IF;
                ELSIF v_tax_vat = 'END CONSUMER' THEN
                   l_tax_attribute_value := P_TAX_ATTR_EX; --Es exento
                ELSIF v_tax_vat = 'EXPORTACION' THEN
                   l_tax_attribute_value := NULL; --No debe aplicar nada
                ELSIF v_tax_vat = 'MIPYME' THEN
                   l_tax_attribute_value := NULL; --No debe aplicar nada
                ELSIF v_tax_vat IN ('EXEMPT','INSCRIPTO') THEN
                    /*Calcula el impuesto correspondiente*/
                    IF r_sites.activity_code = 'JU' THEN
                        IF v_rf = 0 THEN
                          l_tax_attribute_value := P_TAX_ATTR_LOC;
                        ELSE
                          l_tax_attribute_value := P_TAX_ATTR_LOC_RF;
                        END IF;
                    ELSIF r_sites.activity_code = 'CM' THEN
                        IF v_rf = 0 THEN
                          l_tax_attribute_value := P_TAX_ATTR_CM;
                        ELSE
                          l_tax_attribute_value := P_TAX_ATTR_CM_RF;
                        END IF;
                    ELSIF r_sites.activity_code = 'EX' THEN

                        l_tax_attribute_value := P_TAX_ATTR_EX;

                    END IF;

                END IF;

                print_log ('l_tax_attribute_value: '||l_tax_attribute_value);

                IF NVL (r_sites.existe_perfiles, 'N') = 'N' THEN
                  fnd_file.put_line (fnd_file.LOG, 'r_sites.customer_name='
                                                 || r_sites.customer_name
                                                 || ' r_sites.address_id = '
                                                 || r_sites.address_id
                                                 || ' r_orgs.tax_category_id ='
                                                 || r_orgs.tax_category_id
                                                 || ' r_sites.contributor_class ='
                                                 || r_sites.contributor_class
                                                 || '  r_orgs.organization_id ='
                                                 || r_orgs.organization_id
                                                 || 'r_sites.existe_perfiles='
                                                 || r_sites.existe_perfiles);
                  IF NVL (p_draft,'N') = 'N' THEN

                    IF NOT insertar_iibb_site (r_sites.address_id ,
                                               r_orgs.organization_id ,
                                               r_sites.contributor_class ,
                                               r_orgs.tax_category_id,
                                               l_tax_attribute_value) THEN
                      p_error_message := 'Error al insertar Site';
                      RAISE e_sites_exception;
                    END IF;
                  END IF;
                ELSE
                  fnd_file.put_line (fnd_file.LOG, 'r_sites.tax_code='
                                                || l_tax_attribute_value
                                                || ' -r_sites.contributor_class='
                                                || r_sites.contributor_class
                                                || ' -r_sites.address_id='
                                                || r_sites.address_id );
                  IF NVL (p_draft,'N') = 'N' THEN
                    UPDATE jl_zz_ar_tx_cus_cls_all
                       SET tax_attribute_value = l_tax_attribute_value,
                           last_update_date    = SYSDATE,
                           last_updated_by     = fnd_profile.value('USER_ID')  ,
                           last_update_login   = fnd_profile.value('LOGIN_ID')
                     WHERE tax_attr_class_code = r_sites.contributor_class
                       AND tax_attribute_value != l_tax_attribute_value
                       AND address_id = r_sites.address_id
                       AND tax_category_id = r_orgs.tax_category_id ;
                  END IF;
                END IF;

                /*Tomo el impuesto configurado en las reglas*/
                  BEGIN

                        select jzatg.tax_code
                          into v_tax_code
                          from jl_zz_ar_tx_groups_all jzatg
                              ,jl_zz_ar_tx_categ_all jzatca
                         where jzatg.org_id = r_orgs.organization_id
                           and jzatg.tax_category_id = jzatca.tax_category_id
                           and jzatg.org_id = jzatca.org_id
                           and jzatca.tax_category = r_orgs.tax_category
                           and group_tax_id = r_orgs.group_tax_id
                           and jzatg.contributor_type = l_tax_attribute_value
                           and NVL(jzatg.start_date_active,TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
                           and NVL(jzatg.end_date_active,TRUNC(SYSDATE)) >= TRUNC(SYSDATE);

                  EXCEPTION
                     WHEN OTHERS THEN
                        p_error_message := 'Error al obtener Codigo de impuesto configurado en las reglas de impuesto. Error: '||SQLERRM;
                        RAISE e_sites_exception;
                  END;

                  print_log ('Tax_code: '||v_tax_code);

                IF NVL(l_tax_attribute_value,'*') IN (P_TAX_ATTR_LOC,P_TAX_ATTR_LOC_RF,P_TAX_ATTR_MON,P_TAX_ATTR_MON_RF,P_TAX_ATTR_CM,P_TAX_ATTR_CM_RF) THEN

                  BEGIN  --Si el padron indica que no debe calcular retener
                    select 1
                      into v_nrp
                      from xx_ar_padron_iibb_salta_ae
                     where TRIM(replace(cert_num,chr(13))) = 'NRP'
                       and cuit = r_sites.cuit
                       and status = 'N';
                  EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                     v_nrp := 0;
                   WHEN TOO_MANY_ROWS THEN
                     v_nrp := 1;
                   WHEN OTHERS THEN
                     v_nrp := 0;
                  END;

                  print_log ('v_nrp: '||v_nrp);
                  v_coef := null;

                  IF v_nrp = 1 THEN

                        v_coef := 0; --no tiene coeficiente, debe ser exento por certificado valido

                        BEGIN
                           select count(1) --Por algun motivo hay mas de uno
                             into v_exist_exc
                             from jl.jl_zz_ar_tx_exc_cus_all jzatec
                            where jzatec.address_id        = r_sites.address_id
                              and jzatec.tax_category_id   = r_orgs.tax_category_id
                              --and tax_code                 = v_tax_code
                              and jzatec.org_id            = r_orgs.organization_id
                              and nvl(jzatec.end_date_active,p_end_date)   = p_end_date;

                        EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            v_exist_exc := 0;
                         WHEN TOO_MANY_ROWS THEN
                            v_exist_exc := 1;
                         WHEN OTHERS THEN
                            v_exist_exc := 0;
                        END;

                        print_log ('v_exist_exc: '||v_exist_exc);

                        IF v_exist_exc != 0 then --update

                          IF NVL (p_draft,'N') = 'N' THEN

                            print_log ('Actualizo exencion');

                            update jl.jl_zz_ar_tx_exc_cus_all jzatec
                               set jzatec.last_update_date   = sysdate,
                                   jzatec.last_updated_by    = l_user_id,
                                   jzatec.last_update_login  = l_login_id,
                                   jzatec.tax_code           = v_tax_code,
                                   jzatec.base_rate          = ROUND(-100 + (100*v_coef) , 4),
                                   jzatec.end_date_active    = p_end_date,
                                   attribute_category        = 'AR',
                                   attribute1                = null,
                                   attribute2                = null
                             where jzatec.address_id        = r_sites.address_id
                               and jzatec.tax_category_id   = r_orgs.tax_category_id
                               --and tax_code                 = v_tax_code
                               and jzatec.org_id            = r_orgs.organization_id
                               and nvl(jzatec.end_date_active,p_end_date) = p_end_date;

                          END IF;

                        ELSE --Insert

                          IF NVL (p_draft,'N') = 'N' THEN

                             print_log ('Inserto exencion');

                             INSERT INTO jl.jl_zz_ar_tx_exc_cus_all jzatec
                                        (exc_cus_id,
                                         address_id,
                                         tax_category_id,
                                         end_date_active,
                                         last_update_date,
                                         last_updated_by,
                                         tax_code,
                                         base_rate,
                                         start_date_active,
                                         attribute_category,
                                         attribute1,
                                         attribute2,
                                         org_id,
                                         last_update_login,
                                         creation_date,
                                         created_by)
                                 values (jl_zz_ar_tx_exc_cus_s.nextval,
                                         r_sites.address_id,
                                         r_orgs.tax_category_id,
                                         p_end_date,
                                         sysdate,
                                         fnd_global.user_id,
                                         v_tax_code,
                                         ROUND(-100 + (100*v_coef) , 4),
                                         p_start_date,
                                         'AR',
                                         null,
                                         v_coef,
                                         r_orgs.organization_id,
                                         /*Fin Modificado Khronus/E.Sly 20190225*/
                                         l_login_id,
                                         sysdate,
                                         l_user_id);
                          END IF;
                        END IF;

                  ELSE

                      IF r_sites.activity_code != 'JU' THEN  --Solo convenio

                        IF r_sites.province = r_sites.xx_ar_provincia THEN  -- Si entrega en Salta
                           v_coef := p_coef_cm_bi;
                        ELSE
                           v_coef := 1;-- Tomar Coef
                           BEGIN

                             select coef
                               into v_coef
                               from xx_ar_ap_coef_cm05 xaacc
                                   ,hz_cust_accounts hca
                              where hca.party_id  = xaacc.party_id
                                and hca.cust_account_id = r_sites.customer_id
                                and NVL(start_date_active,trunc(sysdate)) <= trunc(sysdate)
                                and NVL(end_date_active,trunc(sysdate)) >= trunc(sysdate);

                           EXCEPTION
                            WHEN OTHERS THEN
                              v_coef := 1;
                           END;
                        END IF;

                        BEGIN
                           select count(1) --Por algun motivo hay mas de uno
                             into v_exist_exc
                             from jl.jl_zz_ar_tx_exc_cus_all jzatec
                            where jzatec.address_id        = r_sites.address_id
                              and jzatec.tax_category_id   = r_orgs.tax_category_id
                              --and tax_code                 = v_tax_code
                              and jzatec.org_id            = r_orgs.organization_id
                              and nvl(jzatec.end_date_active,p_end_date)   = p_end_date;

                        EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            v_exist_exc := 0;
                         WHEN TOO_MANY_ROWS THEN
                            v_exist_exc := 1;
                         WHEN OTHERS THEN
                            v_exist_exc := 0;
                        END;

                        print_log ('v_exist_exc: '||v_exist_exc);

                        IF v_exist_exc != 0 then --update

                          IF NVL (p_draft,'N') = 'N' THEN

                           print_log ('Actualizo exencion');

                            update jl.jl_zz_ar_tx_exc_cus_all jzatec
                               set jzatec.last_update_date   = sysdate,
                                   jzatec.last_updated_by    = l_user_id,
                                   jzatec.last_update_login  = l_login_id,
                                   jzatec.tax_code           = v_tax_code,
                                   jzatec.base_rate          = round(-100 + (100*v_coef), 4),
                                   jzatec.end_date_active    = p_end_date,
                                   attribute_category        = 'AR',
                                   attribute1                = null,
                                   attribute2                = v_coef
                             where jzatec.address_id        = r_sites.address_id
                               and jzatec.tax_category_id   = r_orgs.tax_category_id
                               --and tax_code                 = v_tax_code
                               and jzatec.org_id            = r_orgs.organization_id
                               and nvl(jzatec.end_date_active,p_end_date) = p_end_date;

                          END IF;

                        ELSE --Insert

                          IF NVL (p_draft,'N') = 'N' THEN

                             print_log ('Inserto exencion');

                             INSERT INTO jl.jl_zz_ar_tx_exc_cus_all jzatec
                                        (exc_cus_id,
                                         address_id,
                                         tax_category_id,
                                         end_date_active,
                                         last_update_date,
                                         last_updated_by,
                                         tax_code,
                                         base_rate,
                                         start_date_active,
                                         attribute_category,
                                         attribute1,
                                         attribute2,
                                         org_id,
                                         last_update_login,
                                         creation_date,
                                         created_by)
                                 values (jl_zz_ar_tx_exc_cus_s.nextval,
                                         r_sites.address_id,
                                         r_orgs.tax_category_id,
                                         p_end_date,
                                         sysdate,
                                         fnd_global.user_id,
                                         v_tax_code,
                                         ROUND(-100 + (100*v_coef), 4),
                                         p_start_date,
                                         'AR',
                                         null,
                                         v_coef,
                                         r_orgs.organization_id,
                                         /*Fin Modificado Khronus/E.Sly 20190225*/
                                         l_login_id,
                                         sysdate,
                                         l_user_id);
                          END IF;
                        END IF;
                      ELSE

                       BEGIN
                           select count(1) --Por algun motivo hay mas de uno
                             into v_exist_exc
                             from jl.jl_zz_ar_tx_exc_cus_all jzatec
                            where jzatec.address_id        = r_sites.address_id
                              and jzatec.tax_category_id   = r_orgs.tax_category_id
                              --and tax_code                 = v_tax_code
                              and jzatec.org_id            = r_orgs.organization_id
                              and nvl(jzatec.end_date_active,p_end_date)   = p_end_date;

                       EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            v_exist_exc := 0;
                         WHEN TOO_MANY_ROWS THEN
                            v_exist_exc := 1;
                         WHEN OTHERS THEN
                            v_exist_exc := 0;
                       END;

                       print_log ('v_exist_exc: '||v_exist_exc);

                       IF  v_exist_exc > 0 THEN

                        IF NVL (p_draft,'N') = 'N' THEN

                          /*print_log ('Actualizo exencion');

                          update jl.jl_zz_ar_tx_exc_cus_all jzatec
                               set jzatec.last_update_date  = sysdate,
                                   jzatec.last_updated_by   = l_user_id,
                                   jzatec.last_update_login = l_login_id,
                                   jzatec.end_date_active   = p_start_date ,
                                   jzatec.base_rate         = ROUND(-100 + (100*v_coef) , 4)
                             where jzatec.address_id        = r_sites.address_id
                               and jzatec.tax_category_id   = r_orgs.tax_category_id
                               and tax_code                 = v_tax_code
                               and nvl(jzatec.end_date_active,p_end_date) = p_end_date;*/

                               print_log ('Elimino exencion');

                            delete jl.jl_zz_ar_tx_exc_cus_all jzatec
                             where jzatec.address_id        = r_sites.address_id
                               and jzatec.tax_category_id   = r_orgs.tax_category_id
                               --and tax_code                 = v_tax_code
                               and jzatec.org_id            = r_orgs.organization_id
                               and nvl(jzatec.end_date_active,p_end_date) = p_end_date;

                        END IF;
                       END IF;
                      END IF;
                  END IF;
                END IF;

                fnd_file.put_line(fnd_file.output,'      <PARTY_NAME>'      || cdata(r_sites.customer_name)   || '</PARTY_NAME>');
                fnd_file.put_line(fnd_file.output,'      <ADDRESS_LINE>'    || cdata(l_location)              || '</ADDRESS_LINE>');
                fnd_file.put_line(fnd_file.output,'      <TAX_ATTR_ANT>'    || l_tax_anterior                 || '</TAX_ATTR_ANT>');
                fnd_file.put_line(fnd_file.output,'      <TAX_ATTR>'        || l_tax_attribute_value          || '</TAX_ATTR>');
                fnd_file.put_line(fnd_file.output,'      <COEF>'            || v_coef                         || '</COEF>');
                fnd_file.put_line(fnd_file.output,'      <TAX_CODE>'        || v_tax_code                     || '</TAX_CODE>');
                fnd_file.put_line(fnd_file.output,'  </G_LINES>');

            EXCEPTION
             WHEN e_sites_exception THEN
                fnd_file.put_line(fnd_file.output,'      <PARTY_NAME>'      || cdata(r_sites.customer_name)   || '</PARTY_NAME>');
                fnd_file.put_line(fnd_file.output,'      <ADDRESS_LINE>'    || cdata(l_location)              || '</ADDRESS_LINE>');
                fnd_file.put_line(fnd_file.output,'      <TAX_ATTR_ANT>'    || l_tax_anterior                 || '</TAX_ATTR_ANT>');
                fnd_file.put_line(fnd_file.output,'      <TAX_ATTR>'        || l_tax_attribute_value          || '</TAX_ATTR>');
                fnd_file.put_line(fnd_file.output,'      <COEF>'            || v_coef                         || '</COEF>');
                fnd_file.put_line(fnd_file.output,'      <TAX_CODE>'        || v_tax_code                     || '</TAX_CODE>');
                fnd_file.put_line(fnd_file.output,'      <ERROR_MESSAGE>'   || p_error_message                || '</ERROR_MESSAGE>');
                fnd_file.put_line(fnd_file.output,'  </G_LINES>');
             WHEN OTHERS THEN
                /*Agregado KHRONUS/E.Sly 20200601*/
                --NULL;
                fnd_file.put_line(fnd_file.output,'      <PARTY_NAME>'      || cdata(r_sites.customer_name)   || '</PARTY_NAME>');
                fnd_file.put_line(fnd_file.output,'      <ADDRESS_LINE>'    || cdata(l_location)              || '</ADDRESS_LINE>');
                fnd_file.put_line(fnd_file.output,'      <TAX_ATTR_ANT>'    || l_tax_anterior                 || '</TAX_ATTR_ANT>');
                fnd_file.put_line(fnd_file.output,'      <TAX_ATTR>'        || l_tax_attribute_value          || '</TAX_ATTR>');
                fnd_file.put_line(fnd_file.output,'      <COEF>'            || v_coef                         || '</COEF>');
                fnd_file.put_line(fnd_file.output,'      <TAX_CODE>'        || v_tax_code                     || '</TAX_CODE>');
                p_error_message := SQLERRM;
                fnd_file.put_line(fnd_file.output,'      <ERROR_MESSAGE>'   || p_error_message                || '</ERROR_MESSAGE>');
                fnd_file.put_line(fnd_file.output,'  </G_LINES>');
                /*Agregado KHRONUS/E.Sly 20200601*/
            END;

      END LOOP;

      fnd_file.put_line (fnd_file.log,  '     CLOSE c_sites ' ||'-'|| r_orgs.organization_id ||'-'|| p_customer_id ||'-'|| r_orgs.tax_category);

      fnd_file.put_line(fnd_file.output,'  </LIST_G_LINES>');
      fnd_file.put_line(fnd_file.output,'  </G_ORGS>');

  end loop;

  fnd_file.put_line(fnd_file.output,'  </LIST_G_ORGS>');

  fnd_file.put_line(fnd_file.output,'  </G_EXC>');
  fnd_file.put_line(fnd_file.output,'  </LIST_G_EXC>');

  IF p_draft = 'Y' THEN
   ROLLBACK;
  END IF;

  IF p_status IS NULL THEN
    p_status := 'S';
  END IF;

  fnd_file.put_line(fnd_file.log,'XX_AR_AP_PADRON_IIBB_SALTA_PK.PROCESS_PADRON (-)');

EXCEPTION
   WHEN OTHERS THEN
    p_status := 'W';
    p_error_message := 'Exception OTHERS en PROCESS_PADRON. Error: '||SQLERRM;
    fnd_file.put_line(fnd_file.log,p_error_message);
    fnd_file.put_line(fnd_file.log,'XX_AR_AP_PADRON_IIBB_SALTA_PK.PROCESS_PADRON (!)');
END PROCESS_PADRON;

PROCEDURE PROCESS_CAST (P_STATUS          OUT VARCHAR2
                       ,P_ERROR_MESSAGE   OUT VARCHAR2
                       ,P_GRUPO_EMP       IN  VARCHAR2
                       ,P_ORG_ID          IN  NUMBER
                       ,P_CUSTOMER_ID     IN  NUMBER
                       ,P_TAX_CATEGORY    IN  VARCHAR2
                       ,P_TAX_ATTR_VAL_CAST IN VARCHAR2
                       ,P_DRAFT           IN  VARCHAR2) IS

  CURSOR c_orgs ( p_grupo_emp    IN VARCHAR2,
                  p_org_id       IN NUMBER,
                  p_tax_category IN VARCHAR2)
    IS
      SELECT hla1d.xx_grupo_emp,
             hla2d.establishment_type,
             haou.organization_id,
             haou.name,
             jzatc.tax_category,
             jzatc.tax_category_id,
             jzatc_dfv.xx_ar_tasa_castigo
        FROM hr_locations_all2_dfv        hla2d,
             hr_locations_all             hla,
             hr_all_organization_units    haou,
             hr_locations_all1_dfv        hla1d,
             hr_organization_information  hoi,
             jl_zz_ar_tx_att_cls_all      jzataca,
             jl_zz_ar_tx_categ_all        jzatc,
             jl_zz_ar_tx_categ_all_dfv    jzatc_dfv
       WHERE hla.ROWID                    = hla2d.row_id
         AND hla.ROWID                    = hla1d.row_id
         AND jzatc.ROWID                  = jzatc_dfv.row_id
         AND haou.organization_id         = hoi.organization_id
         AND hoi.org_information1         = 'OPERATING_UNIT'
         AND haou.location_id             = hla.location_id
         AND hla1d.xx_grupo_emp           = NVL (p_grupo_emp, hla1d.xx_grupo_emp)
         AND haou.organization_id         = NVL (p_org_id, haou.organization_id)
         AND jzataca.org_id               = haou.organization_id
         AND jzatc.org_id                 = haou.organization_id
         AND jzataca.tax_attr_class_code  = hla2d.establishment_type
         AND jzataca.tax_category_id      = jzatc.tax_category_id
         AND jzataca.tax_attribute_value  = 'APPLICABLE'
         AND jzatc.tax_category        = NVL (p_tax_category, jzatc.tax_category);

    CURSOR c_sites ( p_org_id          hr_operating_units.organization_id%TYPE,
                     p_customer_id     ra_customers.customer_id%TYPE,
                     p_tax_category    jl_zz_ar_tx_categ_all.TAX_CATEGORY%TYPE)
    IS
      SELECT customer_name,
             customer_number,
             cuit,
             address_id,
             contributor_class,
             (SELECT DISTINCT 'Y'
                FROM jl_zz_ar_tx_cus_cls_all jzatcc
               WHERE jzatcc.tax_attr_class_code = q.contributor_class
                 AND jzatcc.org_id = q.org_id
                 AND jzatcc.tax_category_id = q.tax_category_id
                 AND address_id = q.address_id
             )
             existe_perfiles,
             tax_rate,
             customer_id
        FROM (SELECT jzatc.org_id
                   , substrb(hp.party_name,1,50)              customer_name
                   , hca.account_number                       customer_number
                   , jzatc.tax_category
                   , hca.cust_account_id                      customer_id
                   , hcas.cust_acct_site_id                   address_id
                   , hl.province
                   , TO_NUMBER (jzatc_dfv.xx_ar_tasa_castigo,'9999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') tax_rate
                   , hcas.global_attribute8                   contributor_class
                   , jzatc.tax_category_id
                   , SUBSTR (hp.jgzz_fiscal_code, 1, 10)      cuit
                FROM hz_parties                 hp
                   , hz_cust_accounts           hca
                   , hz_party_sites             hps
                   , hz_cust_acct_sites         hcas
                   , hz_locations               hl
                   , jl_zz_ar_tx_categ      jzatc
                   , jl_zz_ar_tx_categ_all_dfv  jzatc_dfv
               WHERE hp.party_id               = hca.party_id
                 AND hp.party_id               = hps.party_id
                 AND hps.party_site_id         = hcas.party_site_id
                 AND hps.location_id           = hl.location_id
                 AND jzatc.ROWID               = jzatc_dfv.row_id
                 AND jzatc.org_id              = hcas.org_id
                 AND jzatc_dfv.xx_ar_provincia = hl.province
                 AND hl.country = fnd_profile.value('XX_AR_IIBB_COUNTRY')
                 AND jzatc_dfv.xx_ar_tasa_castigo IS NOT NULL
                 AND TAX_CATEGORY = p_tax_category
                 AND NOT EXISTS ( SELECT 1
                                    FROM XX_AR_PADRON_IIBB_SALTA_AE xapusa
                                   WHERE hp.jgzz_fiscal_code = substr( xapusa.cuit,1,10) )
                 AND NOT EXISTS ( SELECT 1
                                    FROM XX_AR_PADRON_IIBB_SALTA_RF xapusr
                                   WHERE hp.jgzz_fiscal_code = substr( xapusr.cuit,1,10) )
              ) q
        WHERE q.customer_id  = NVL (p_customer_id, q.customer_id)
          AND q.org_id       = NVL (p_org_id, q.org_id)
          AND q.tax_category = NVL (p_tax_category, q.tax_category);

    r_orgs                 c_orgs%ROWTYPE;
    r_sites                c_sites%ROWTYPE;

    e_cust_exception EXCEPTION;

    l_tax_anterior          VARCHAR2(100);
    l_location              VARCHAR2(200);


BEGIN

    fnd_file.put_line(fnd_file.log,'XX_AR_AP_PADRON_IIBB_SALTA_PK.PROCESS_CAST (+)');

    fnd_file.put_line(fnd_file.output,' <LIST_G_CAST>');
    fnd_file.put_line(fnd_file.output,' <G_CAST>');

    fnd_file.put_line(fnd_file.output,' <LIST_G_ORGS>');

    OPEN c_orgs (p_grupo_emp, p_org_id, p_tax_category);
    LOOP

          FETCH c_orgs INTO r_orgs;
          EXIT WHEN c_orgs%NOTFOUND;

          fnd_file.put_line(fnd_file.output,' <G_ORGS>');

          fnd_file.put_line(fnd_file.output,' <ORG_NAME>'||cdata(r_orgs.name)||'</ORG_NAME>');
          fnd_file.put_line(fnd_file.output,' <LIST_G_LINES>');

          OPEN c_sites (r_orgs.organization_id, p_customer_id, r_orgs.tax_category);
          LOOP

            FETCH c_sites INTO r_sites;
            fnd_file.put_line (fnd_file.log,  '  c_sites para r_orgs.organization_id='||r_orgs.organization_id||' hay='||c_sites%rowcount);
            EXIT WHEN c_sites%NOTFOUND;

            fnd_file.put_line(fnd_file.output,' <G_LINES>');

            BEGIN
              l_tax_anterior := '';

              SELECT tax_attribute_value
                INTO l_tax_anterior
                FROM jl_zz_ar_tx_cus_cls_all
               WHERE tax_attr_class_code = r_sites.contributor_class
                 AND address_id = r_sites.address_id
                 AND tax_category_id = r_orgs.tax_category_id ;
            EXCEPTION
              WHEN OTHERS THEN
                l_tax_anterior := '-';
            END;

            IF NVL (r_sites.existe_perfiles, 'N') = 'N' THEN
              fnd_file.put_line (fnd_file.LOG, 'r_sites.customer_name='
                                             || r_sites.customer_name
                                             || ' r_sites.address_id = '
                                             || r_sites.address_id
                                             || ' r_orgs.tax_category_id ='
                                             || r_orgs.tax_category_id
                                             || ' r_sites.contributor_class ='
                                             || r_sites.contributor_class
                                             || '  r_orgs.organization_id ='
                                             || r_orgs.organization_id
                                             || 'r_sites.existe_perfiles='
                                             || r_sites.existe_perfiles);
              IF NVL (p_draft,'N') = 'N' THEN

                IF NOT insertar_iibb_site (r_sites.address_id ,
                                           r_orgs.organization_id ,
                                           r_sites.contributor_class ,
                                           r_orgs.tax_category_id,
                                           P_TAX_ATTR_VAL_CAST) THEN
                  p_error_message := 'Error al insertar Site';
                  RAISE e_cust_exception;
                END IF;
              END IF;
            ELSE
              fnd_file.put_line (fnd_file.LOG, '*********** r_sites.tax_code='
                                            || P_TAX_ATTR_VAL_CAST
                                            || ' -r_sites.contributor_class='
                                            || r_sites.contributor_class
                                            || ' -r_sites.address_id='
                                            || r_sites.address_id );
              IF NVL (p_draft,'N') = 'N' THEN
                UPDATE jl_zz_ar_tx_cus_cls_all
                   SET tax_attribute_value = p_tax_attr_val_cast,
                       last_update_date    = SYSDATE,
                       last_updated_by     = fnd_profile.value('USER_ID')  ,
                       last_update_login   = fnd_profile.value('LOGIN_ID')
                 WHERE tax_attr_class_code = r_sites.contributor_class
                   AND tax_attribute_value != p_tax_attr_val_cast
                   AND address_id = r_sites.address_id
                   AND tax_category_id = r_orgs.tax_category_id ;
              END IF;
            END IF;

            l_location  :=  trae_location (r_sites.address_id, r_sites.customer_id, r_orgs.organization_id);

            --fnd_file.put_line (fnd_file.output, r_orgs.name||';'||r_sites.customer_name||';'||r_sites.customer_number||';'||r_sites.cuit||';'||l_location||';'|| l_tax_anterior||';'||r_sites.tax_code);
              fnd_file.put_line(fnd_file.output,'      <PARTY_NAME>'      || cdata(r_sites.customer_name)   || '</PARTY_NAME>');
              fnd_file.put_line(fnd_file.output,'     <ADDRESS_LINE>'    || cdata(l_location)               || '</ADDRESS_LINE>');
              fnd_file.put_line(fnd_file.output,'      <ALICUOTA>'        || r_sites.tax_rate               || '</ALICUOTA>');
              fnd_file.put_line(fnd_file.output,'      <TAX_CODE_ANT>'    || l_tax_anterior                 || '</TAX_CODE_ANT>');
              fnd_file.put_line(fnd_file.output,'      <TAX_CODE>'        || p_tax_attr_val_cast            || '</TAX_CODE>');

            fnd_file.put_line (fnd_file.log,  '     r_sites.existe_perfiles= ' ||r_sites.existe_perfiles);

            fnd_file.put_line(fnd_file.output,'  </G_LINES>');

          END LOOP;

          fnd_file.put_line (fnd_file.log,  '     CLOSE c_sites ' ||'-'|| r_orgs.organization_id ||'-'|| p_customer_id ||'-'|| r_orgs.tax_category);
          CLOSE c_sites;

          fnd_file.put_line(fnd_file.output,'  </LIST_G_LINES>');

          fnd_file.put_line(fnd_file.output,'  </G_ORGS>');
    END LOOP;
    CLOSE c_orgs;

    fnd_file.put_line(fnd_file.output,'  </LIST_G_ORGS>');

    fnd_file.put_line(fnd_file.output,'  </G_CAST>');

    fnd_file.put_line(fnd_file.output,'  </LIST_G_CAST>');

    IF p_status IS nUll then
     p_status := 'S';
    end if;

    fnd_file.put_line(fnd_file.log,'XX_AR_AP_PADRON_IIBB_SALTA_PK.PROCESS_CAST (-)');

EXCEPTION
 WHEN e_cust_exception THEN
   p_status := 'W';
   fnd_file.put_line (fnd_file.log,p_error_message);
   fnd_file.put_line(fnd_file.log,'XX_AR_AP_PADRON_IIBB_SALTA_PK.PROCESS_CAST (!)');
 WHEN OTHERS THEN
   p_status := 'W';
   p_error_message := 'Error OTHERS en  PROCESS_CAST. Error: '||SQLERRM;
   fnd_file.put_line (fnd_file.log,p_error_message);
   fnd_file.put_line(fnd_file.log,'XX_AR_AP_PADRON_IIBB_SALTA_PK.PROCESS_CAST (!)');
END;

PROCEDURE process_ar (retcode             OUT NUMBER
                     ,errbuf              OUT VARCHAR2
                     ,p_grupo_emp          IN VARCHAR2
                     ,p_org_id             IN NUMBER
                     ,p_customer_id        IN NUMBER
                     ,p_period_name        IN VARCHAR2
                     ,p_tax_category       IN VARCHAR2
                     ,p_tax_category_vat   IN VARCHAR2
                     ,p_tax_attr_loc       IN VARCHAR2 --LOCAL
                     ,p_tax_attr_loc_rf    IN VARCHAR2 --LOCAL C/ RIESGO
                     ,p_tax_attr_mon       IN VARCHAR2 --MONOTRIBUTISTA
                     ,p_tax_attr_mon_rf    IN VARCHAR2 --MONOTRIBUTISTA C/Riesgo
                     ,p_tax_attr_cm        IN VARCHAR2 --CONT MULTILATERAL
                     ,p_tax_attr_cm_rf     IN VARCHAR2 --CONT MULTILATERAL C/Riesgo
                     ,p_tax_attr_ex        IN VARCHAR2 --Exento
                     ,p_coef_cm_bi         IN NUMBER   --0.5 sobre la base imponible
                     ,p_draft              IN VARCHAR2) IS

v_status         VARCHAR2(1);
v_error_message  VARCHAR2(2000);
v_start_date     gl_period_statuses.start_date%type;
v_end_date       gl_period_statuses.end_date%type;
v_found          VARCHAR2(1);
e_cust_exception exception;

BEGIN

   Print_log ('XX_AR_AP_PADRON_IIBB_SALTA_PK.PROCESS_AR (+)');

   print_log ('Parametros: ');
   print_log ('------------');
   print_log ('');
   print_log ('p_grupo_emp: '||p_grupo_emp);
   print_log ('p_org_id: '||p_org_id);
   print_log ('p_customer_id: '||p_customer_id);
   print_log ('p_period_name: '||p_period_name);
   print_log ('p_tax_category: '||p_tax_category);
   print_log ('p_tax_category_vat: '||p_tax_category_vat);
   print_log ('p_tax_attr_loc: '||p_tax_attr_loc);
   print_log ('p_tax_attr_loc_rf: '||p_tax_attr_loc_rf);
   print_log ('p_tax_attr_mon: '||p_tax_attr_mon);
   print_log ('p_tax_attr_mon_rf: '||p_tax_attr_mon_rf);
   print_log ('p_tax_attr_cm: '||p_tax_attr_cm);
   print_log ('p_tax_attr_cm_rf: '||p_tax_attr_cm_rf);
   print_log ('p_tax_attr_ex: '||p_tax_attr_ex);
   print_log ('p_coef_cm_bi: '||p_coef_cm_bi);
   print_log ('p_draft: '||p_draft);
   print_log ('');

       /*Obtengo datos del periodo*/
    BEGIN
        SELECT gps.start_date,gps.end_date
          INTO v_start_date,v_end_date
          FROM gl_period_statuses  gps
         WHERE gps.application_id  = 101
           AND gps.set_of_books_id = fnd_profile.value('GL_SET_OF_BKS_ID')
           AND gps.period_name     = p_period_name;
    EXCEPTION
        WHEN no_data_found THEN
          v_error_message := 'No se encontro el periodo: ' || p_period_name;
          RAISE e_cust_exception;
        WHEN others THEN
          v_error_message := 'Error buscando el periodo: '||p_period_name||'. '||SQLERRM;
          RAISE e_cust_exception;
    END;

    BEGIN
        SELECT 'Y'
          INTO v_found
          FROM dual
         WHERE EXISTS ( SELECT 1
                          FROM XX_AR_PADRON_IIBB_SALTA_AE
                         WHERE status = 'N');
    EXCEPTION
        WHEN no_data_found THEN
          v_error_message := 'No se ha ejecutado el loader de IIBB Salta Actividades Economicas. No hay datos para procesar. ';
          RAISE e_cust_exception;
        WHEN others THEN
          v_error_message := 'Error verificando que el loader de IIBB Salta Actividades Economicas se haya ejecutado ' ||
                          SQLERRM;
          RAISE e_cust_exception;
    END;

        BEGIN
        SELECT 'Y'
          INTO v_found
          FROM dual
         WHERE EXISTS ( SELECT 1
                          FROM XX_AR_PADRON_IIBB_SALTA_RF
                         WHERE status = 'N');
    EXCEPTION
        WHEN no_data_found THEN
          v_error_message := 'No se ha ejecutado el loader de IIBB Salta Riesgo Fiscal. No hay datos para procesar: ';
          RAISE e_cust_exception;
        WHEN others THEN
          v_error_message := 'Error verificando que el loader de IIBB Salta Riesgo Fiscal se haya ejecutado ' ||
                          SQLERRM;
          RAISE e_cust_exception;
    END;

   fnd_file.put_line(fnd_file.output,'<?xml version="1.0" encoding="ISO-8859-1"?>');
   fnd_file.put_line(fnd_file.output,'<XXARPPIS>');

   PROCESS_PADRON (p_status             => v_status
                  ,p_error_message      => v_error_message
                  ,p_grupo_emp          => p_grupo_emp
                  ,p_org_id             => p_org_id
                  ,p_customer_id        => p_customer_id
                  ,p_start_date         => v_start_date
                  ,p_end_date           => v_end_date
                  ,p_tax_category       => p_tax_category
                  ,p_tax_category_vat   => p_tax_category_vat
                  ,p_tax_attr_loc       => p_tax_attr_loc
                  ,p_tax_attr_loc_rf    => p_tax_attr_loc_rf
                  ,p_tax_attr_mon       => p_tax_attr_mon
                  ,p_tax_attr_mon_rf    => p_tax_attr_mon_rf
                  ,p_tax_attr_cm        => p_tax_attr_cm
                  ,p_tax_attr_cm_rf     => p_tax_attr_cm_rf
                  ,p_tax_attr_ex        => p_tax_attr_ex
                  ,p_coef_cm_bi         => p_coef_cm_bi
                  ,p_draft              => p_draft);

   IF v_status != 'S' THEN
      RAISE e_cust_exception;
   END IF;

   /*PROCESS_CAST (p_status        => v_status
                 ,p_error_message => v_error_message
                 ,p_grupo_emp  => p_grupo_emp
                 ,p_org_id     => p_org_id
                 ,p_customer_id  => p_customer_id
                 ,p_tax_category  => p_tax_category
                 ,p_tax_attr_val_cast => p_tax_attr_val_cast
                 ,p_draft         => p_draft);

   IF v_status != 'S' THEN
     RAISE e_cust_exception;
   END IF;*/

   UPDATE XX_AR_PADRON_IIBB_SALTA_AE
      SET status = 'P'
    WHERE NVL(status,'N') = 'N';

   UPDATE XX_AR_PADRON_IIBB_SALTA_RF
      SET status = 'P'
    WHERE NVL(status,'N') = 'N';

   fnd_file.put_line(fnd_file.output,'</XXARPPIS>');

   Print_log ('XX_AR_AP_PADRON_IIBB_SALTA_PK.PROCESS_AR (-)');

EXCEPTION
 WHEN e_cust_exception THEN
   retcode := 1;
   errbuf := v_error_message;
   print_log (errbuf);
   RAISE_APPLICATION_ERROR(-20001,errbuf);
   print_log ('XX_AR_AP_PADRON_IIBB_SALTA_PK.PROCESS_AR (!)');
 WHEN OTHERS THEN
   retcode := 2;
   errbuf  := 'Error OTHERS en PROCESS_AR. Error: '||SQLERRM;
   print_log (errbuf);
   Print_log ('XX_AR_AP_PADRON_IIBB_SALTA_PK.PROCESS_AR (!)');
   RAISE_APPLICATION_ERROR(-20000,errbuf);
END;

END;
/

EXIT