CREATE OR REPLACE PACKAGE BODY APPS."XX_AR_TUC_COEF_PER_PKG"
AS

g_nls_req FND_CONCURRENT_REQUESTS.NLS_NUMERIC_CHARACTERS%TYPE;

FUNCTION CDATA(P_STR IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  return '<![CDATA[' || p_str || ']]>';
END CDATA;

PROCEDURE PROCESS_EXC(P_STATUS          OUT VARCHAR2
                     ,P_ERROR_MESSAGE   OUT VARCHAR2
                     ,P_GRUPO_EMP       IN  VARCHAR2
                     ,P_ORG_ID          IN  NUMBER
                     ,P_CUSTOMER_ID     IN  NUMBER
                     ,P_TAX_CATEGORY    IN  VARCHAR2
                     ,P_DRAFT           IN  VARCHAR2)
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

  cursor c_data(p_tax_code varchar2,p_org_id number,p_customer_id NUMBER)
  is
  select xx_ar_coef_tuc_rec(address_id, tax_category_id, coeficiente, alicuota, date_from, date_to, tax_code)
    from ( select hcas.cust_acct_site_id address_id,
                  jzatc.tax_category_id,
                  to_number(xx.coeficiente,'999999D9999','nls_numeric_characters='||g_nls_req) coeficiente,
                  to_number(xx.alicuota,'999999D9999','nls_numeric_characters='||g_nls_req) alicuota,
                  to_date(xx.fecha_vigencia_desde, 'ddmmyyyy') date_from,
                  to_date(xx.fecha_vigencia_hasta, 'ddmmyyyy') date_to,
                  p_tax_code tax_code
             from hz_cust_acct_sites_all hcas,
                  hz_cust_accounts hca,
                  hz_parties hp,
                  jl_zz_ar_tx_categ_all jzatc,
                  xxarpilcptuc xx
            where jzatc.tax_category  = P_TAX_CATEGORY--'TOPTU' Valor por parametro
              and hcas.org_id         = jzatc.org_id
              and hca.cust_account_id = hcas.cust_account_id
              and hp.party_id         = hca.party_id
              /*Agregado Khronus/ESly 20190225*/
              and hca.cust_account_id = NVL(p_customer_id,hca.cust_account_id)
              and hcas.org_id         = p_org_id
              /*Fin Agregado Khronus/ESly 20190225*/
              and xx.nro_cuit         = hp.jgzz_fiscal_code || hca.global_attribute12 );

   /*Modificado Khronus/E.Sly 20190225*/
  /*cursor c_tax
  is
  select attribute2,
         tax_attribute_value
    from jl_zz_ar_tx_att_val*/
  cursor c_tax (p_org_id NUMBER)
  is
  select attribute2,
         tax_attribute_value
    from jl_zz_ar_tx_att_val_all
   where attribute3 = 'CM'
     and org_id = p_org_id;
  /*FIn Modificado Khronus/E.Sly 20190225*/

  l_data_tbl             XX_AR_COEF_TUC_TBL;

  l_tax_code             varchar2(240);
  l_tax_attribute_value  varchar2(240);

  l_user_id              number := fnd_global.user_id;
  l_login_id             number := fnd_global.login_id;
  /*Modificado Khronus/E.Sly 20190225 Etapa 2*/
  --l_org_id               number := fnd_profile.value('ORG_ID');
  /*Fin Modificado Khronus/E.Sly 20190225 Etapa 2*/

BEGIN

  fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.PROCESS_EXC (+)');

  fnd_file.put_line(fnd_file.output,'  <LIST_G_EXC>');
  fnd_file.put_line(fnd_file.output,'  <G_EXC>');

  fnd_file.put_line(fnd_file.output,'  <LIST_G_ORGS>');

  FOR r_org in c_orgs (p_grupo_emp, p_org_id, p_tax_category) LOOP

      fnd_file.put_line(fnd_file.output,'  <G_ORGS>');
      fnd_file.put_line(fnd_file.output,'  <ORG_NAME>'||cdata(r_org.name)||'</ORG_NAME>');
      fnd_file.put_line(fnd_file.output,'  <LIST_G_LINES>');

      /*Modificado Khronus/E.Sly 20190225*/
      --open c_tax;
      open c_tax (r_org.organization_id);
      /*Fin Modificado Khronus/E.Sly 20190225*/
      fetch c_tax into l_tax_code, l_tax_attribute_value;
      close c_tax;

      /*Modificado Khronus/E.Sly 20190225*/
      --open c_data(l_tax_code);
      open c_data(l_tax_code,r_org.organization_id,p_customer_id);
      /*Fin Modificado Khronus/E.Sly 20190225*/
      fetch c_data bulk collect into l_data_tbl;
      close c_data;

      if l_data_tbl.count > 0 then

        merge into jl.jl_zz_ar_tx_exc_cus_all jzatec
             using ( select * from table(cast(l_data_tbl as XX_AR_COEF_TUC_TBL)) ) tbl
                on (     jzatec.address_id        = tbl.address_id
                     and jzatec.tax_category_id   = tbl.tax_category_id
                     and jzatec.end_date_active   = tbl.date_to )
              when matched then
                update set jzatec.last_update_date   = sysdate,
                           jzatec.last_updated_by    = l_user_id,
                           jzatec.tax_code           = tbl.tax_code,
                           jzatec.base_rate          = trunc(-100 + ( tbl.coeficiente * tbl.alicuota ), 4),
                           jzatec.attribute_category = 'AR',
                           jzatec.attribute1         = tbl.alicuota,
                           jzatec.attribute2         = tbl.coeficiente,
                           jzatec.last_update_login  = l_login_id
              when not matched then
                insert (exc_cus_id,
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
                        tbl.address_id,
                        tbl.tax_category_id,
                        tbl.date_to,
                        sysdate,
                        l_user_id,
                        tbl.tax_code,
                        trunc(-100 + ( tbl.coeficiente * tbl.alicuota ), 4),
                        tbl.date_from,
                        'AR',
                        tbl.alicuota,
                        tbl.coeficiente,
                        /*Modificado Khronus/E.Sly 20190225*/
                        --l_org_id,
                        r_org.organization_id,
                        /*Fin Modificado Khronus/E.Sly 20190225*/
                        l_login_id,
                        sysdate,
                        l_user_id);

        merge into jl.jl_zz_ar_tx_cus_cls_all jzatcc
             using ( select tbl_aux.* ,
                            hcas_dfv.contributor_class tax_attr_class_code,
                            jzatc.cus_tax_attribute tax_attribute_name,
                            l_tax_attribute_value tax_attribute_value,
                            hcas.org_id
                       from table(cast(l_data_tbl as XX_AR_COEF_TUC_TBL)) tbl_aux,
                            hz_cust_acct_sites_all hcas,
                            hz_cust_acct_sites_all1_dfv hcas_dfv,
                            jl_zz_ar_tx_categ_all jzatc
                      where hcas.cust_acct_site_id = tbl_aux.address_id
                        and hcas_dfv.row_id        = hcas.rowid
                        and hcas.org_id = r_org.organization_id
                        and jzatc.org_id = hcas.org_id
                        and jzatc.tax_category_id  = tbl_aux.tax_category_id ) tbl
                on (     jzatcc.address_id          = tbl.address_id
                     and jzatcc.tax_attr_class_code = tbl.tax_attr_class_code
                     and jzatcc.tax_category_id     = tbl.tax_category_id
                     and jzatcc.org_id              = tbl.org_id
                     and jzatcc.tax_attribute_name  = tbl.tax_attribute_name
                     --and jzatcc.tax_attribute_value = tbl.tax_attribute_value
                      )
              when matched then
                update set jzatcc.enabled_flag      = 'Y',
                           jzatcc.last_updated_by   = l_user_id,
                           jzatcc.last_update_date  = sysdate,
                           jzatcc.last_update_login = l_login_id
              when not matched then
                insert(jzatcc.cus_class_id,
                       jzatcc.address_id,
                       jzatcc.tax_attr_class_code,
                       jzatcc.tax_category_id,
                       jzatcc.tax_attribute_name,
                       jzatcc.tax_attribute_value,
                       jzatcc.enabled_flag,
                       jzatcc.org_id,
                       jzatcc.last_update_date,
                       jzatcc.last_updated_by,
                       jzatcc.last_update_login,
                       jzatcc.creation_date,
                       jzatcc.created_by)
                values(jl_zz_ar_tx_cus_cls_s.nextval,
                       tbl.address_id,
                       tbl.tax_attr_class_code,
                       tbl.tax_category_id,
                       tbl.tax_attribute_name,
                       tbl.tax_attribute_value,
                       'Y',
                       /*Modificado Khronus/E.Sly 20190225*/
                       --l_org_id,
                       r_org.organization_id,
                       /*Fin Modificado Khronus/E.Sly 20190225*/
                       sysdate,
                       l_user_id,
                       l_login_id,
                       sysdate,
                       l_user_id);

        for r_report in ( select hp.party_name,
                                 hl.address1 || ', ' || hl.address2 || ', ' || hl.address3 || ', ' || hl.address4 address_line,
                                 tbl.coeficiente,
                                 tbl.alicuota,
                                 to_char(tbl.date_from, 'dd/mm/yyyy') date_from,
                                 to_char(tbl.date_to, 'dd/mm/yyyy') date_to,
                                 tbl.tax_code
                            from table(cast(l_data_tbl as XX_AR_COEF_TUC_TBL)) tbl,
                                 hz_cust_acct_sites hcas,
                                 hz_party_sites hps,
                                 hz_locations hl,
                                 hz_cust_accounts hca,
                                 hz_parties hp
                           where hcas.cust_acct_site_id = tbl.address_id
                             and hps.party_site_id      = hcas.party_site_id
                             and hl.location_id         = hps.location_id
                             and hca.cust_account_id    = hcas.cust_account_id
                             and hp.party_id            = hca.party_id )
        loop
          fnd_file.put_line(fnd_file.output,'    <G_LINES>');
          fnd_file.put_line(fnd_file.output,'      <PARTY_NAME>'   || cdata(r_report.party_name)   || '</PARTY_NAME>');
          fnd_file.put_line(fnd_file.output,'      <ADDRESS_LINE>' || cdata(r_report.address_line) || '</ADDRESS_LINE>');
          fnd_file.put_line(fnd_file.output,'      <COEFICIENTE>'  || r_report.coeficiente         || '</COEFICIENTE>');
          fnd_file.put_line(fnd_file.output,'      <ALICUOTA>'     || r_report.alicuota            || '</ALICUOTA>');
          fnd_file.put_line(fnd_file.output,'      <DATE_FROM>'    || r_report.date_from           || '</DATE_FROM>');
          fnd_file.put_line(fnd_file.output,'      <DATE_TO>'      || r_report.date_to             || '</DATE_TO>');
          fnd_file.put_line(fnd_file.output,'      <TAX_CODE>'     || r_report.tax_code            || '</TAX_CODE>');
          fnd_file.put_line(fnd_file.output,'    </G_LINES>');
        end loop;

      end if;
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

  fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.PROCESS_EXC (-)');

EXCEPTION
   WHEN OTHERS THEN
    p_status := 'W';
    p_error_message := 'Exception OTHERS en PROCESS_EXC. Error: '||SQLERRM;
    fnd_file.put_line(fnd_file.log,p_error_message);
    fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.PROCESS_EXC (!)');
END PROCESS_EXC;

  FUNCTION INSERTAR_IIBB_SITE( p_address_id          IN jl_zz_ar_tx_cus_cls_all.address_id%TYPE
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

    fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.INSERT_IIBB_SITE (+)');


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

     fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.INSERT_IIBB_SITE (-)');

   RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.INSERT_IIBB_SITE (!)');
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


PROCEDURE PROCESS_CAST (P_STATUS          OUT VARCHAR2
                       ,P_ERROR_MESSAGE   OUT VARCHAR2
                       ,P_GRUPO_EMP       IN  VARCHAR2
                       ,P_ORG_ID          IN  NUMBER
                       ,P_CUSTOMER_ID     IN  NUMBER
                       ,P_TAX_CATEGORY    IN  VARCHAR2
                       ,P_TAX_ATTR_VAL_CAST IN VARCHAR2
                       ,P_DRAFT           IN  VARCHAR2) IS

CURSOR c_orgs ( pc_grupo_emp  IN VARCHAR2,
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
         AND jzatc.tax_category           = NVL (p_tax_category, jzatc.tax_category);

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
                   , TO_NUMBER (jzatc_dfv.xx_ar_tasa_castigo,'999999D99','nls_numeric_characters='||g_nls_req) tax_rate
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
                    FROM xxarpilcptuc xaip
                   WHERE hp.jgzz_fiscal_code = substr( xaip.nro_cuit,1,10) )
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

    fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.PROCESS_CAST (+)');

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

        fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.PROCESS_CAST (-)');

EXCEPTION
 WHEN e_cust_exception THEN
   p_status := 'W';
   fnd_file.put_line (fnd_file.log,p_error_message);
   fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.PROCESS_CAST (!)');
 WHEN OTHERS THEN
   p_status := 'W';
   p_error_message := 'Error OTHERS en  PROCESS_CAST. Error: '||SQLERRM;
   fnd_file.put_line (fnd_file.log,p_error_message);
   fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.PROCESS_CAST (!)');
END;

PROCEDURE MAIN (RETCODE OUT NUMBER
               ,ERRBUF OUT VARCHAR2
               /*Agregado Khronus/E.Sly 20190225 Etapa 2*/
               ,p_grupo_emp IN VARCHAR2
               ,p_org_id IN NUMBER
               ,p_customer_id IN NUMBER
               ,P_PERIOD_NAME IN VARCHAR2
               ,p_tax_category IN VARCHAR2
               ,p_tax_attr_val_cast IN VARCHAR2
               ,p_draft IN VARCHAR2) IS
               /*Fin Agregado Khronus/E.Sly 20190225*/

/*Agregado Khronus/E.Sly 20190225 Etapa 2*/
v_status        VARCHAR2(1);
v_error_message VARCHAR2(2000);

v_fiscal_period VARCHAR2(20);
v_found         VARCHAR2(1);

e_cust_exception EXCEPTION;
/*Fin Agregado Khronus/E.Sly 20190225 Etapa 2*/

BEGIN

    fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.MAIN (+)');
    
    g_nls_req := '.,';

    /*Obtengo datos del periodo*/
    BEGIN
        SELECT TO_CHAR(TRUNC(gps.start_date),'YYYYMM')
          INTO v_fiscal_period
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

    /*Verifico que el padron de IIBB de Tucuman tenga datos.*/
    BEGIN
        SELECT 'Y'
          INTO v_found
          FROM DUAL
        WHERE EXISTS ( SELECT 1
                         FROM xxarpilcptuc
                        WHERE v_fiscal_period = periodo);
    EXCEPTION
        WHEN no_data_found THEN
          v_error_message := 'El padron de IIBB de Tucuman no tiene datos para el periodo: '||v_fiscal_period;
          RAISE e_cust_exception;
        WHEN others THEN
          v_error_message := 'Error verificando que el padron ' ||
                          'de IIBB de Tucuman tenga datos. '  ||
                          SQLERRM;
          RAISE e_cust_exception;
    END;
    /*Fin Agregado Khronus/E.Sly 20190225 Etapa 2*/

    fnd_file.put_line(fnd_file.output,'<?xml version="1.0" encoding="ISO-8859-1"?>');
    fnd_file.put_line(fnd_file.output,'<XX_AR_TUC_COEF_PER>');

    PROCESS_EXC (p_status        => v_status
                ,p_error_message => v_error_message
                 ,P_GRUPO_EMP  => p_grupo_emp
                 ,P_ORG_ID     => p_org_id
                 ,P_CUSTOMER_ID  => p_customer_id
                 ,P_TAX_CATEGORY  => p_tax_category
                 ,P_DRAFT         => p_draft);

    IF v_status != 'S' THEN
      RAISE e_cust_exception;
    END IF;

    PROCESS_CAST (p_status        => v_status
                 ,p_error_message => v_error_message
                 ,P_GRUPO_EMP  => p_grupo_emp
                 ,P_ORG_ID     => p_org_id
                 ,P_CUSTOMER_ID  => p_customer_id
                 ,P_TAX_CATEGORY  => p_tax_category
                 ,p_tax_attr_val_cast => p_tax_attr_val_cast
                 ,P_DRAFT         => p_draft);

    IF v_status != 'S' THEN
      RAISE e_cust_exception;
    END IF;

    fnd_file.put_line(fnd_file.output,'</XX_AR_TUC_COEF_PER>');

    fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.MAIN (-)');

EXCEPTION
  WHEN e_cust_exception THEN
     retcode := 1;
     errbuf := v_error_message;
     fnd_file.put_line(fnd_file.log,errbuf);
     RAISE_APPLICATION_ERROR(-20001,'Error Inesperado en los procedimientos internos');
     fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.MAIN (!)');
  WHEN OTHERS THEN
     retcode := 2;
     errbuf := 'Exception OTHERS en MAIN_PROCESS. Error: '||SQLERRM;
     fnd_file.put_line(fnd_file.log,errbuf);
     fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.MAIN (!)');
     RAISE_APPLICATION_ERROR(-20001,'Error Inesperado en los procedimientos internos');
END;

/*Agregado KHRONUS/E.Sly 20200113 Se agrega logica para AP*/

FUNCTION insert_applicability (p_supp_awt_type_id IN NUMBER
                              ,p_primary_flag IN VARCHAR2
                              ,p_tax_id IN NUMBER
                              ,p_org_id IN NUMBER) RETURN NUMBER IS

v_message VARCHAR2(2000);
v_supp_awt_code_id NUMBER;
BEGIN

    SELECT jl_zz_ap_sup_awt_cd_s.NEXTVAL
    INTO v_supp_awt_code_id
    FROM dual;

    INSERT INTO jl_zz_ap_sup_awt_cd_all
           (supp_awt_code_id,
            supp_awt_type_id,
            tax_id,
            primary_tax_flag,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            org_id)
      VALUES
            (v_supp_awt_code_id
           ,p_supp_awt_type_id
           ,p_tax_id
           ,p_primary_flag
           ,fnd_global.user_id
           ,SYSDATE
           ,fnd_global.user_id
           ,SYSDATE
           ,p_org_id);

      fnd_file.put_line(fnd_file.log,'Registros insertados en JL_ZZ_AP_SUP_AWT_CD: '||SQL%ROWCOUNT);

RETURN (v_supp_awt_code_id);

EXCEPTION
WHEN OTHERS THEN
v_message := 'Error al insertar registro en . Error: '||SQLERRM;
fnd_file.put_line(fnd_file.log,v_message);
RETURN (0);
END;


FUNCTION insert_supp_awt_type(p_vendor_id IN NUMBER
                             ,p_awt_type_code IN VARCHAR2) RETURN NUMBER IS

v_supp_awt_type_id NUMBER;

BEGIN

    SELECT jl_zz_ap_supp_awt_types_s.nextval
    INTO v_supp_awt_type_id
    FROM dual;

    INSERT INTO jl_zz_ap_supp_awt_types
               (supp_awt_type_id
               ,vendor_id
               ,awt_type_code
               ,wh_subject_flag
               ,created_by
               ,creation_date
               ,last_updated_by
               ,last_update_date)
          VALUES
               (v_supp_awt_type_id
               ,p_vendor_id
               ,p_awt_type_code
               ,'Y'
               ,fnd_global.user_id
               ,SYSDATE
               ,fnd_global.user_id
               ,SYSDATE);

    fnd_file.put_line(fnd_file.log,'Registros insertados en JL_ZZ_AP_SUPP_AWT_TYPES: '||SQL%ROWCOUNT);

    RETURN (v_supp_awt_type_id);

EXCEPTION
WHEN OTHERS THEN
fnd_file.put_line(fnd_file.log,'Error al insertar impuesto de Retencion en Aplicabilidad de Proveedor. Error: '||SQLERRM);
RETURN(0);
END;

FUNCTION check_jg_zz_entity_assoc (p_error_message    OUT VARCHAR2
                                  ,P_vendor_id         IN NUMBER
                                  ,p_tax_authority_id  IN NUMBER
                                  ,p_date_from         IN DATE
                                  ,p_date_to           IN DATE) RETURN BOOLEAN IS

v_exists NUMBER;
v_effective_date DATE;
e_cust_exception EXCEPTION;

CURSOR c_vendor IS
SELECT *
FROM po_vendors pv
where pv.vendor_id = p_vendor_id
and enabled_flag = 'Y';

BEGIN


    fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.CHECK_JG_ZZ_ENTITY_ASSOC (+)');

    FOR asup IN c_vendor LOOP

      BEGIN

        BEGIN

            select 1
              into v_exists
              from jg_zz_entity_assoc asoc
             where asoc.primary_id_number = asup.num_1099
               and id_type = '25'
               and nvl(ineffective_date,p_date_to) >= p_date_to
               and associated_entity_id = p_tax_authority_id;

        EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_exists := 0;
         WHEN OTHERS THEN
            v_exists := 1;
            p_error_message := 'Error: '||SQLERRM;
            fnd_file.put_line(fnd_file.log,p_error_message);
        END;

        fnd_file.put_line(fnd_file.log,'Existe: '||v_exists);
        fnd_file.put_line(fnd_file.log,'Fecha To: '||to_char(p_date_to,'YYYY/MM/DD HH24:MI:SS'));

        IF v_exists = 0 THEN

            BEGIN

                select max(ineffective_date) + 1
                  into v_effective_date
                  from jg_zz_entity_assoc asoc
                 where asoc.primary_id_number = asup.num_1099
                   and id_type = '25'
                   and ineffective_date > p_date_from
                   and ineffective_date is not null
                   and associated_entity_id = p_tax_authority_id;

            EXCEPTION
             WHEN NO_DATA_FOUND THEN
                v_effective_date := p_date_from;
             WHEN OTHERS THEN
                p_error_message := 'Error al obtener ultima fecha de las entidads relacion comercial. Error: '||SQLERRM;
                RAISE e_cust_exception;
            END;

            IF v_effective_date is null then
               v_effective_date := p_date_from;
            END IF;

            INSERT INTO jg.JG_ZZ_ENTITY_ASSOC (entity_association_id,
                                               associated_entity_id,
                                               created_by,
                                               last_updated_by,
                                               primary_id_number,
                                               id_type,
                                               id_number,
                                               effective_date,
                                               ineffective_date,
                                               creation_date,
                                               last_update_date,
                                               last_update_login)
                                       select  jg_zz_entity_assoc_s.nextval
                                              ,p_tax_authority_id
                                              ,fnd_global.user_id
                                              ,fnd_global.user_id
                                              ,num_1099
                                              ,'25'
                                              ,'924'
                                              ,TRUNC(v_effective_date)
                                              ,TRUNC(p_date_to)
                                              ,SYSDATE
                                              ,SYSDATE
                                              ,fnd_global.login_id
                                          FROM ap_suppliers
                                         where vendor_id = asup.vendor_id;

            fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.CHECK_JG_ZZ_ENTITY_ASSOC (-)');
            RETURN (TRUE);

        END IF;

        fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.CHECK_JG_ZZ_ENTITY_ASSOC (-)');
        RETURN (TRUE);

      EXCEPTION
        WHEN e_cust_exception THEN
           RETURN (FALSE);
        WHEN OTHERS THEN
           p_error_message := 'Error al generar relacion entidad comercial para el proveedor: '||asup.vendor_name||'. Error: '||SQLERRM;
           RETURN (FALSE);
      END;

    END LOOP;

    fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.CHECK_JG_ZZ_ENTITY_ASSOC (-)');
    RETURN (TRUE);

EXCEPTION
 WHEN OTHERS THEN
   fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.CHECK_JG_ZZ_ENTITY_ASSOC (!)');
   p_error_message := 'Error OTHERS en CHECK_JG_ZZ_ENTITY_ASSOC. Error: '||SQLERRM;
   RETURN (FALSE);
END;

PROCEDURE save_awt_rate (p_vendor_id IN NUMBER,p_supp_awt_code_id IN NUMBER,p_date_from IN DATE,p_date_to IN DATE,p_coef IN NUMBER,p_alicuota IN NUMBER) IS

v_rate_exists NUMBER;

BEGIN
       BEGIN
            SELECT count(1)
              INTO v_rate_exists
              FROM XX_AP_IIBB_AWT_RATES
             WHERE vendor_id = p_vendor_id
               AND supp_awt_code_id = p_supp_awt_code_id
               AND date_from = p_date_from
               and date_to = p_date_to;

       EXCEPTION
         WHEN OTHERS THEN
         v_rate_Exists := 1;
       END;

       IF v_rate_exists = 0 then

            INSERT INTO XX_AP_IIBB_AWT_RATES
            SELECT  bolinf.xx_ap_iibb_awt_rates_s.nextval,
                    p_vendor_id,
                    p_supp_awt_code_id,
                    p_date_from,
                    p_date_to,
                    p_coef,
                    p_alicuota,
                    fnd_global.conc_request_id,
                    SYSDATE,
                    fnd_global.user_id,
                    sysdate,
                    fnd_global.user_id
               FROM DUAL;

           fnd_file.put_line(fnd_file.log,'Registro insertado en XX_AP_IIBB_AWT_RATES');

       ELSE

            UPDATE XX_AP_IIBB_AWT_RATES
               SET rate = p_alicuota
                  ,request_id = fnd_global.conc_request_id
                  ,last_updated_by = fnd_global.user_id
                  ,last_update_date = sysdate
             WHERE vendor_id = p_vendor_id
               AND supp_awt_code_id = p_supp_awt_code_id
               AND date_from = p_date_from
               and date_to = p_date_to;

           fnd_file.put_line(fnd_file.log,'Registro actualizado en XX_AP_IIBB_AWT_RATES');

       END IF;

EXCEPTION
 WHEN OTHERS THEN
  NULL;
END;

PROCEDURE PROCESS_AP_AWT_CODES (p_status OUT VARCHAR2
                               ,p_error_message  OUT VARCHAR2
                               ,p_grupo_emp IN VARCHAR2
                               ,p_org_id IN NUMBER
                               ,p_vendor_id IN NUMBER
                               ,p_period_name IN VARCHAR2
                               ,p_awt_type_code IN VARCHAR2
                               ,p_awt_type_code_cast IN VARCHAR2
                               ,p_rtu_0 IN VARCHAR2
                               ,p_rtu_0_cast IN VARCHAR2
                               ,p_rtu_local IN VARCHAR2
                               ,p_rtu_cmi IN VARCHAR2
                               ,p_rtu_ni IN VARCHAR2
                               ,p_rtu_cmi_no_sede IN VARCHAR2
                               ,p_zero_rate IN VARCHAR2) IS


CURSOR c_orgs ( pc_grupo_emp   IN VARCHAR2,
               p_org_id        IN NUMBER,
               p_awt_type_code IN VARCHAR2)
    IS
      SELECT hla1d.xx_grupo_emp,
             hla2d.establishment_type,
             haou.organization_id org_id,
             haou.name
        FROM hr_locations_all2_dfv        hla2d,
             hr_locations_all             hla,
             hr_all_organization_units    haou,
             hr_locations_all1_dfv        hla1d,
             hr_organization_information  hoi
       WHERE hla.ROWID                    = hla2d.row_id
         AND hla.ROWID                    = hla1d.row_id
         AND haou.organization_id         = hoi.organization_id
         AND hoi.org_information1         = 'OPERATING_UNIT'
         AND haou.location_id             = hla.location_id
         AND hla1d.xx_grupo_emp           = NVL (p_grupo_emp, hla1d.xx_grupo_emp)
         AND haou.organization_id         = NVL (p_org_id, haou.organization_id)
         and exists (select 1
                       from ap_tax_codes_all atc
                       ,ap_awt_tax_rates_all aatra
                      where atc.tax_type = 'AWT'
                        and atc.global_attribute4 = p_awt_type_code
                        and haou.organization_id = atc.org_id
                        and atc.org_id = aatra.org_id
                        and atc.name = aatra.tax_name
                        and NVL(aatra.start_date,trunc(sysdate)) <= trunc(sysdate)
                        and NVL(aatra.end_date,trunc(sysdate)) >= trunc(sysdate)
                        and NVL(atc.inactive_date,trunc(sysdate)) >= trunc(sysdate));

CURSOR c_vend (p_org_id NUMBER,p_periodo VARCHAR2,p_vendor_id NUMBER,p_zero_rate NUMBER,p_province_code VARCHAR2) is
  SELECT asup.vendor_id
          ,asup.vendor_name
          ,NVL(asup.global_attribute15,'N') multilateral_contributer
          ,tuc.nro_cuit
          ,tuc.nro_establecimiento
          ,to_number(tuc.coeficiente,'999999D9999','nls_numeric_characters='||g_nls_req) coeficiente
          ,tuc.exclusion
          ,tuc.exento
          ,tuc.periodo
          ,to_number(tuc.alicuota,'999999D9999','nls_numeric_characters='||g_nls_req) alicuota
          ,to_date(tuc.fecha_vigencia_desde, 'ddmmyyyy') date_from
          ,to_date(tuc.fecha_vigencia_hasta, 'ddmmyyyy') date_to
          ,trunc(100 - ( 1 * to_number(tuc.alicuota,'999999D9999','nls_numeric_characters='||g_nls_req) ), 4) porc_exc
          ,CASE
           WHEN to_number(tuc.coeficiente,'999999D9999','nls_numeric_characters='||g_nls_req) = 0 and exclusion  = 'E' THEN
             100
           WHEN to_number(tuc.coeficiente,'999999D9999','nls_numeric_characters='||g_nls_req) = 0 and exclusion  is null THEN
             TRUNC(100 - (p_zero_rate), 4)
           ELSE
            TRUNC(100 - ( to_number(tuc.coeficiente,'999999D9999','nls_numeric_characters='||g_nls_req) * to_number(tuc.alicuota,'999999D9999','nls_numeric_characters='||g_nls_req) ), 4)
            END coef_porc_exc
          ,'Y' padron
  FROM xxarpilcptuc tuc
  ,ap_suppliers asup
  ,ap_supplier_sites_all assa
  ,po_vendors1_dfv  pvg
  where periodo = p_period_name
  and tuc.nro_cuit = asup.num_1099||asup.global_attribute12
  and asup.vendor_id = assa.vendor_id
  and assa.org_id = p_org_id
  and asup.vendor_id = NVL(p_vendor_id,asup.vendor_id)
  and pvg.row_id = asup.rowid
  and asup.enabled_flag = 'Y'
  and nvl(asup.end_date_active,trunc(sysdate)) >= TRUNC(sysdate)
  and nvl(assa.inactive_date,trunc(sysdate)) >= TRUNC(sysdate)
  group by asup.vendor_id
          ,asup.vendor_name
          ,NVL(asup.global_attribute15,'N')
          ,tuc.nro_cuit
          ,tuc.nro_establecimiento
          ,tuc.coeficiente
          ,tuc.exclusion
          ,tuc.exento
          ,tuc.periodo
          ,tuc.alicuota
          ,tuc.fecha_vigencia_desde
          ,tuc.fecha_vigencia_hasta
 UNION ALL
    SELECT asup.vendor_id
          ,asup.vendor_name
          ,NVL(asup.global_attribute15,'N') multilateral_contributer
          ,asup.num_1099||asup.global_attribute12
          ,null
          ,null
          ,null
          ,null
          ,null
          ,null
          ,to_date(to_char(sysdate,'MM/YYYY'),'MM/YYYY')
          ,TRUNC(last_day(sysdate))
          ,null
          ,null
          ,'N' padron
     from po_vendors asup
         ,ap_supplier_sites_all assa
    where 1 = 1
      and asup.vendor_id = assa.vendor_id
      and assa.org_id = p_org_id
      and asup.enabled_flag = 'Y'
      and asup.vendor_id = nvl(p_vendor_id,asup.vendor_id)
      and nvl(asup.end_date_active,trunc(sysdate)) >= TRUNC(sysdate)
      and nvl(assa.inactive_date,trunc(sysdate)) >= TRUNC(sysdate)
      and not exists (select 1
                        from xxarpilcptuc tuc
                       where tuc.nro_cuit = asup.num_1099||asup.global_attribute12)
      and (not exists (select 1
                       FROM jl_zz_ap_supp_awt_types jzasat
                           ,jl_zz_ap_sup_awt_cd_all jzasaca
                      WHERE wh_subject_flag = 'Y'
                        and vendor_id = asup.vendor_id
                        AND awt_type_code = p_awt_type_code_cast
                        AND jzasaca.supp_awt_type_id  = jzasat.supp_awt_type_id
                        and primary_tax_flag = 'Y'
                        AND jzasaca.tax_id = (select tax_id
                                                from ap_tax_codes_all atc
                                               where atc.tax_type = 'AWT'
                                                 and atc.org_id = p_org_id
                                                 and atc.global_attribute4 = p_awt_type_code_cast
                                                 and atc.name = p_rtu_ni
                                                 and NVL(TRUNC(atc.start_date),trunc(sysdate)) <= trunc(sysdate)
                                                 and NVL(TRUNC(atc.inactive_date),trunc(sysdate)) >= trunc(sysdate)))
        OR (exists (select 1
                       FROM jl_zz_ap_supp_awt_types jzasat
                      WHERE wh_subject_flag = 'Y'
                        and vendor_id = asup.vendor_id
                        AND awt_type_code IN (p_awt_type_code,p_awt_type_code_cast))));

e_cust_exception EXCEPTION;
e_vend_exception EXCEPTION;
v_tax_id AP_TAX_CODES_ALL.TAX_ID%TYPE;
v_tax_name AP_TAX_CODES_ALL.NAME%TYPE;
v_supp_awt_type_id Jl_zz_ap_supp_awt_types.supp_awt_type_id%type;
v_wh_subject_flag jl_zz_ap_supp_awt_types.wh_subject_flag%typE;
v_supp_awt_code_id jl_zz_ap_sup_awt_cd_all.supp_awt_code_id%type;
v_exists NUMBER;
v_alic NUMBER;

/*Modificado KHRONUS/E.Sly 20200413*/
v_tax_rate NUMBER;
/*FIn Modificado KHRONUS/E.Sly 20200413*/


v_province_code    jl_zz_ap_awt_types.province_code%type;
v_tax_authority_id jl_zz_ap_awt_types.tax_authority_id%type;

BEGIN

    fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.PROCESS_AP_AWT_CODES (+)');

    fnd_file.put_line(fnd_file.output,' <LIST_G_AWT>');
    fnd_file.put_line(fnd_file.output,' <G_AWT>');

    fnd_file.put_line(fnd_file.output,' <LIST_G_ORGS>');

    /*Obtengo la provincia del tipo de retencion*/
     BEGIN
       SELECT jzaat.province_code,tax_authority_id
         INTO v_province_code,v_tax_authority_id
         FROM jl_zz_ap_awt_types  jzaat
        WHERE jzaat.awt_type_code = p_awt_type_code;
     EXCEPTION
       WHEN no_data_found THEN
         p_error_message := 'No se encontro el tipo de retencion: ' ||
                         p_awt_type_code;
         RAISE e_cust_exception;
       WHEN others THEN
         p_error_message := 'Error buscando el tipo de retencion: ' ||
                         p_awt_type_code                         ||
                         '. '                                    ||
                         SQLERRM;
         RAISE e_cust_exception;
     END;

    FOR r_org in c_orgs (p_grupo_emp,p_org_id,p_awt_type_code) LOOP

        fnd_file.put_line(fnd_file.output,' <G_ORGS>');
        fnd_file.put_line(fnd_file.output,' <NAME>'||r_org.name||' </NAME>');
        fnd_file.put_line(fnd_file.output,' <LIST_G_VENDORS>');

        FOR r_vendor in c_vend (r_org.org_id,p_period_name,p_vendor_id,to_number(p_zero_rate,'999999D9999','nls_numeric_characters='||g_nls_req),v_province_code) LOOP

          BEGIN

           fnd_file.put_line(fnd_file.output,' <G_VENDORS>');

           fnd_file.put_line(fnd_file.output,' <VENDOR_NAME>'||XX_UTIL_PK.xml_escape_chars(r_vendor.vendor_name)||'</VENDOR_NAME>');
           fnd_file.put_line(fnd_file.output,'<VENDOR_CUIT>'||r_vendor.nro_cuit||'</VENDOR_CUIT>');
           fnd_file.put_line(fnd_file.output,' <CONT_MULTI>'||r_vendor.multilateral_contributer||'</CONT_MULTI>');
           fnd_file.put_line(fnd_file.output,' <PADRON>'||r_vendor.padron||'</PADRON>');

           fnd_file.put_line(fnd_file.log,'Proveedor: '||r_vendor.vendor_name);

           IF r_vendor.padron = 'Y' THEN

                    /*Verificamos si no tiene la relacion entidad activa*/
                       IF NOT check_jg_zz_entity_assoc(p_error_message,r_vendor.vendor_id,v_tax_authority_id,r_vendor.date_from,r_vendor.date_to) THEN
                        RAISE e_vend_exception;
                       END IF;

                    /*Actualizamos el Wh_Subject_flag de RIBB_TU_CASTIGO en N*/

                    /*Verifico si el proveedor ya tiene una aplicabilidad para este impuesto*/
                    fnd_file.put_line(fnd_file.log,'Verificando Aplicabilidad del Proveedor PARA RIBB_TU');
                    BEGIN

                        SELECT 1
                        INTO v_exists
                        FROM jl_zz_ap_supp_awt_types
                        WHERE vendor_id = r_vendor.vendor_id
                        AND awt_type_code = p_awt_type_code_cast
                        AND wh_subject_flag = 'N';

                    EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                           /*Si no tiene un type, lo creo*/
                           UPDATE jl_zz_ap_supp_awt_types
                              SET wh_subject_flag = 'N'
                            WHERE vendor_id = r_vendor.vendor_id
                              AND awt_type_code = p_awt_type_code_cast
                              AND wh_subject_flag = 'Y';

                     WHEN OTHERS THEN
                         p_error_message := 'Error al verificar Tipo de Aplicabilidad para el proveedor: '||r_vendor.vendor_name;
                         RAISE e_vend_exception;
                    END;

                IF r_vendor.multilateral_contributer = 'N' THEN --ES LOCAL, CALCULO SOLAMENTE RTU_LOCAL y RTU_0 como primario para que lo tome la derivacion

                    /*RTU_LOCAL*/
                    BEGIN
                                select atc.tax_id,atc.name
                                  into v_tax_id,v_tax_name
                                  from ap_tax_codes_all atc
                                      ,ap_awt_tax_rates_all aatra
                                 where atc.tax_type = 'AWT'
                                   and atc.org_id = r_org.org_id
                                   and atc.org_id = aatra.org_id
                                   and atc.global_attribute4 = p_awt_type_code
                                   and atc.name = p_rtu_local
                                   and atc.NAME = aatra.tax_name
                                   and NVL(TRUNC(atc.start_date),trunc(sysdate)) <= trunc(sysdate)
                                   and NVL(TRUNC(atc.inactive_date),trunc(sysdate)) >= trunc(sysdate)
                                   and NVL(TRUNC(aatra.start_date),trunc(sysdate)) <= trunc(sysdate)
                                   and NVL(TRUNC(aatra.end_date),trunc(sysdate)) >= trunc(sysdate);

                    EXCEPTION
                      WHEN OTHERS THEN
                         p_error_message := 'Error al obtener datos del impuesto para : '||p_rtu_local||'. Error: '||SQLERRM;
                         RAISE e_vend_exception;
                    END;

                    IF v_tax_id IS NOT NULL THEN

                        /*Verifico si el proveedor ya tiene una aplicabilidad para este impuesto*/
                        fnd_file.put_line(fnd_file.log,'Verificando Aplicabilidad del Proveedor');
                        BEGIN

                            SELECT supp_awt_type_id
                                  ,wh_subject_flag
                              INTO v_supp_awt_type_id
                                  ,v_wh_subject_flag
                              FROM jl_zz_ap_supp_awt_types
                            WHERE vendor_id = r_vendor.vendor_id
                            AND awt_type_code = p_awt_type_code;

                        EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                               /*Si no tiene un type, lo creo*/
                               fnd_file.put_line(fnd_file.log,'Creando aplicabilidad del proveedor');
                               v_supp_awt_type_id := insert_supp_awt_type(p_vendor_id => r_vendor.vendor_id
                                                                         ,p_awt_type_code => p_awt_type_code);
                               v_wh_subject_flag := 'Y';

                               IF v_supp_awt_type_id = 0 THEN
                                  p_error_message := 'Error al crear aplicabilidad de retencion (Tipo) en el proveedor';
                                  RAISE e_vend_exception;
                               END IF;

                         WHEN OTHERS THEN
                             p_error_message := 'Error al verificar Tipo de Aplicabilidad para el proveedor: '||r_vendor.vendor_name;
                             RAISE e_vend_exception;
                        END;

                        IF v_wh_subject_flag = 'N' THEN

                            fnd_file.put_line(fnd_file.log,'Activando Aplicabilidad del Proveedor');

                            UPDATE jl_zz_ap_supp_awt_types
                            set wh_subject_flag = 'Y'
                            WHERE vendor_id = r_vendor.vendor_id
                            AND awt_type_code = p_awt_type_code;

                            v_wh_subject_flag := 'Y';

                        END IF;

                        IF v_wh_subject_flag = 'Y' THEN

                            /*Verifico si el codigo de la retencion es primaria*/
                            fnd_file.put_line(fnd_file.log,'Verificando si tiene RTU_LOCAL y Primario');
                            BEGIN

                                SELECT supp_awt_code_id
                                INTO v_supp_awt_code_id
                                FROM jl_zz_ap_sup_awt_cd_all
                                WHERE supp_awt_type_id  = v_supp_awt_type_id
                                AND primary_tax_flag = 'Y'
                                AND tax_id = v_tax_id
                                and org_id = r_org.org_id;

                            EXCEPTION
                              WHEN OTHERS THEN
                              v_supp_awt_code_id := 0;
                            END;

                            IF v_supp_awt_code_id != 0 THEN /*Actualizamos la exencion*/

                                fnd_file.put_line(fnd_file.log,'Actualizando impuesto a No Primario');
                                UPDATE jl_zz_ap_sup_awt_cd_all
                                   SET PRIMARY_TAX_FLAG = 'N'
                                      ,attribute_category = 'AR'
                                      ,attribute1 = r_vendor.alicuota
                                      ,attribute2 = 1
                                      ,exemption_start_date =  r_vendor.date_from
                                      ,exemption_end_date  = r_vendor.date_to
                                      ,exemption_rate = r_vendor.porc_exc
                                    WHERE supp_awt_code_id = v_supp_awt_code_id;

                                    /*Guardo la alicuota para las cintas*/
                                    save_awt_rate(r_vendor.vendor_id,v_supp_awt_code_id,r_vendor.date_from,r_vendor.date_to,1,r_vendor.alicuota);

                            ELSE

                                /*Verifico si existe pero NO primaria*/
                                fnd_file.put_line(fnd_file.log,'Verificando si existe el impuesto no primario');
                                BEGIN

                                    SELECT supp_awt_code_id
                                    INTO v_supp_awt_code_id
                                    FROM jl_zz_ap_sup_awt_cd_all
                                    WHERE supp_awt_type_id  = v_supp_awt_type_id
                                    AND primary_tax_flag = 'N'
                                    AND tax_id = v_tax_id
                                    and org_id = r_org.org_id;

                                EXCEPTION
                                  WHEN OTHERS THEN
                                  v_supp_awt_code_id := 0;
                                END;

                                /*Si el codigo existe y no es primario*/
                                IF v_supp_awt_code_id = 0 THEN

                                    /*Creo el impuesto como primario*/
                                    fnd_file.put_line(fnd_file.log,'No existe, insertando RTU_LOCAL no primario');
                                      v_supp_awt_code_id := insert_applicability (p_supp_awt_type_id => v_supp_awt_type_id
                                                                                 ,p_primary_flag => 'N'
                                                                                 ,p_tax_id => v_tax_id
                                                                                 ,p_org_id => r_org.org_id);

                                END IF;

                                IF v_supp_awt_code_id  = 0 THEN
                                        p_error_message := 'Error al insertar codigo de retencion.';
                                        RAISE e_vend_exception;
                                ELSE

                                    fnd_file.put_line(fnd_file.log,'actualizando exemption y dff');

                                        UPDATE jl_zz_ap_sup_awt_cd_all
                                           SET attribute_category = 'AR'
                                              ,attribute1 = TO_CHAR(r_vendor.alicuota)
                                              ,attribute2 = 1
                                              ,exemption_start_date =  r_vendor.date_from
                                              ,exemption_end_date  = r_vendor.date_to
                                              ,exemption_rate = r_vendor.porc_exc
                                            WHERE supp_awt_code_id = v_supp_awt_code_id;

                                     /*Guardo la alicuota para las cintas*/
                                     save_awt_rate(r_vendor.vendor_id,v_supp_awt_code_id,r_vendor.date_from,r_vendor.date_to,1,r_vendor.alicuota);


                                     fnd_file.put_line(fnd_file.output,'<G_TAX>');
                                     fnd_file.put_line(fnd_file.output,'<TAX>'||v_tax_name||'</TAX>');
                                     /*fnd_file.put_line(fnd_file.output,'<ALICUOTA>'||XX_UTIL_PK.xml_num_display(r_vendor.alicuota)||'</ALICUOTA>');
                                     fnd_file.put_line(fnd_file.output,'<COEF>'||XX_UTIL_PK.xml_num_display(r_vendor.coeficiente)||'</COEF>');
                                     fnd_file.put_line(fnd_file.output,'<DATE_FROM>'||TO_CHAR(r_vendor.date_from,'DD/MM/YYYY')||'</DATE_FROM>');
                                     fnd_file.put_line(fnd_file.output,'<DATE_TO>'||TO_CHAR(r_vendor.date_to,'DD/MM/YYYY')||'</DATE_TO>');
                                     fnd_file.put_line(fnd_file.output,'<PORC_EXC>'||XX_UTIL_PK.xml_num_display(r_vendor.porc_exc)||'</PORC_EXC>');*/
                                     fnd_file.put_line(fnd_file.output,'<ALICUOTA>'||XX_UTIL_PK.xml_num_display(r_vendor.alicuota,'.,')||'</ALICUOTA>');
                                     fnd_file.put_line(fnd_file.output,'<COEF>'||XX_UTIL_PK.xml_num_display(r_vendor.coeficiente,'.,')||'</COEF>');
                                     fnd_file.put_line(fnd_file.output,'<DATE_FROM>'||TO_CHAR(r_vendor.date_from,'DD/MM/YYYY')||'</DATE_FROM>');
                                     fnd_file.put_line(fnd_file.output,'<DATE_TO>'||TO_CHAR(r_vendor.date_to,'DD/MM/YYYY')||'</DATE_TO>');
                                     fnd_file.put_line(fnd_file.output,'<PORC_EXC>'||XX_UTIL_PK.xml_num_display(r_vendor.porc_exc,'.,')||'</PORC_EXC>');
                                     fnd_file.put_line(fnd_file.output,'</G_TAX>');

                                END IF;

                            END IF;

                        END IF;

                    END IF;

                   /*RTU_0*/
                    BEGIN
                                select atc.tax_id,atc.name
                                  into v_tax_id,v_tax_name
                                  from ap_tax_codes_all atc
                                      ,ap_awt_tax_rates_all aatra
                                 where atc.tax_type = 'AWT'
                                   and atc.org_id = r_org.org_id
                                   and atc.global_attribute4 = p_awt_type_code
                                   and atc.name = p_rtu_0
                                   and atc.NAME = aatra.tax_name
                                   and atc.org_id = aatra.org_id
                                   and NVL(TRUNC(atc.start_date),trunc(sysdate)) <= trunc(sysdate)
                                   and NVL(TRUNC(atc.inactive_date),trunc(sysdate)) >= trunc(sysdate)
                                   and NVL(TRUNC(aatra.start_date),trunc(sysdate)) <= trunc(sysdate)
                                   and NVL(TRUNC(aatra.end_date),trunc(sysdate)) >= trunc(sysdate);

                    EXCEPTION
                      WHEN OTHERS THEN
                         p_error_message := 'Error al obtener datos del impuesto para : '||p_rtu_0||'. Error: '||SQLERRM;
                         RAISE e_vend_exception;
                    END;

                    fnd_file.put_line(fnd_file.log,'Tax_id: '||v_tax_id);

                    IF v_tax_id IS NOT NULL THEN

                        /*Verifico si el proveedor ya tiene una aplicabilidad para este impuesto*/
                        fnd_file.put_line(fnd_file.log,'Verificando Aplicabilidad del Proveedor');
                        BEGIN

                            SELECT supp_awt_type_id
                                  ,wh_subject_flag
                            INTO v_supp_awt_type_id
                                ,v_wh_subject_flag
                            FROM jl_zz_ap_supp_awt_types
                            WHERE vendor_id = r_vendor.vendor_id
                            AND awt_type_code = p_awt_type_code;

                        EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                               /*Si no tiene un type, lo creo*/
                               fnd_file.put_line(fnd_file.log,'Creando aplicabilidad del proveedor');
                               v_supp_awt_type_id := insert_supp_awt_type(p_vendor_id => r_vendor.vendor_id
                                                                         ,p_awt_type_code => p_awt_type_code);
                               v_wh_subject_flag := 'Y';

                               IF v_supp_awt_type_id = 0 THEN
                                  p_error_message := 'Error al crear aplicabilidad de retencion (Tipo) en el proveedor';
                                  RAISE e_vend_exception;
                               END IF;

                         WHEN OTHERS THEN
                             p_error_message := 'Error al verificar Tipo de Aplicabilidad para el proveedor: '||r_vendor.vendor_name;
                             RAISE e_vend_exception;
                        END;
                        IF v_wh_subject_flag = 'N' THEN

                            fnd_file.put_line(fnd_file.log,'Activando Aplicabilidad del Proveedor');

                            UPDATE jl_zz_ap_supp_awt_types
                            set wh_subject_flag = 'Y'
                            WHERE vendor_id = r_vendor.vendor_id
                            AND awt_type_code = p_awt_type_code;

                            v_wh_subject_flag := 'Y';

                        END IF;

                        IF v_wh_subject_flag = 'Y' THEN

                            /*Verifico si el codigo de la retencion es primaria*/
                            fnd_file.put_line(fnd_file.log,'Verificando si tiene RTU_0 y Primario');
                            BEGIN

                                SELECT supp_awt_code_id
                                INTO v_supp_awt_code_id
                                FROM jl_zz_ap_sup_awt_cd_all
                                WHERE supp_awt_type_id  = v_supp_awt_type_id
                                AND primary_tax_flag = 'Y'
                                AND tax_id = v_tax_id
                                and org_id = r_org.org_id;

                            EXCEPTION
                              WHEN OTHERS THEN
                              v_supp_awt_code_id := 0;
                            END;

                            IF v_supp_awt_code_id = 0 THEN /*Actualizamos la exencion*/

                                /*Verifico si existe pero NO primaria*/
                                fnd_file.put_line(fnd_file.log,'Verificando si existe el impuesto no primario');
                                BEGIN

                                    SELECT supp_awt_code_id
                                    INTO v_supp_awt_code_id
                                    FROM jl_zz_ap_sup_awt_cd_all
                                    WHERE supp_awt_type_id  = v_supp_awt_type_id
                                    AND primary_tax_flag = 'N'
                                    AND tax_id = v_tax_id
                                    and org_id = r_org.org_id;

                                EXCEPTION
                                  WHEN OTHERS THEN
                                  v_supp_awt_code_id := 0;
                                END;

                                /*Si el codigo existe y no es primario*/
                                IF v_supp_awt_code_id != 0 THEN

                                    BEGIN
                                        /*Busco si hay un otro impuesto primario*/
                                        fnd_file.put_line(fnd_file.log,'Verificando si existe otro impuesto primario');
                                        SELECT count(1)
                                        INTO v_exists
                                        FROM jl_zz_ap_sup_awt_cd_all
                                        WHERE supp_awt_type_id  = v_supp_awt_type_id
                                        AND tax_id != v_tax_id
                                        AND PRIMARY_TAX_FLAG = 'Y'
                                        and org_id = r_org.org_id;

                                    EXCEPTION
                                      WHEN OTHERS THEN
                                      v_exists := 0;
                                    END;

                                    /*Si hay un otro impuesto primario*/
                                    IF v_exists > 0 THEN

                                     /*Actualizo el primario en NO Primario*/
                                      update jl_zz_ap_sup_awt_cd_all
                                       SET primary_tax_flag = 'N'
                                      WHERE supp_awt_type_id  = v_supp_awt_type_id
                                        AND tax_id != v_tax_id
                                        AND primary_tax_flag = 'Y'
                                        and org_id = r_org.org_id;

                                    END IF;

                                        /*Actualizo el impuesto en Primario*/
                                        fnd_file.put_line(fnd_file.log,'Actualizo RTU_0 como primario');
                                        UPDATE jl_zz_ap_sup_awt_cd_all
                                        SET primary_tax_flag = 'Y'
                                      WHERE supp_awt_type_id  = v_supp_awt_type_id
                                        AND tax_id = v_tax_id
                                        AND primary_tax_flag = 'N'
                                        and org_id = r_org.org_id;

                                ELSE  /*Si el codigo no existe*/

                                    /*Valido si no hay otro codigo primario*/
                                    BEGIN

                                        SELECT count(1)
                                        INTO v_exists
                                        FROM jl_zz_ap_sup_awt_cd_all
                                        WHERE supp_awt_type_id  = v_supp_awt_type_id
                                        AND tax_id != v_tax_id
                                        and org_id = r_org.org_id
                                        and primary_tax_flag = 'Y';

                                    EXCEPTION
                                      WHEN OTHERS THEN
                                      v_exists := 0;
                                    END;

                                    /*Si no hay marco al nuevo como primario*/
                                    IF v_exists != 0 THEN
                                        /*Si hay marco el primario como NO primario*/
                                        update jl_zz_ap_sup_awt_cd_all
                                        set primary_tax_flag = 'N'
                                            ,last_update_date = sysdate
                                            ,last_updated_by = fnd_global.user_id
                                        WHERE supp_awt_type_id  = v_supp_awt_type_id
                                        AND  primary_tax_flag = 'Y'
                                        AND tax_id != v_tax_id
                                        and org_id = r_org.org_id;

                                    END IF;

                                    /*Creo el impuesto como primario*/
                                    fnd_file.put_line(fnd_file.log,'Creo RTU_0 como primario');
                                      v_supp_awt_code_id := insert_applicability (p_supp_awt_type_id => v_supp_awt_type_id
                                                                                 ,p_primary_flag => 'Y'
                                                                                 ,p_tax_id => v_tax_id
                                                                                 ,p_org_id => r_org.org_id);

                                END IF;

                                IF v_supp_awt_code_id  = 0 THEN
                                        p_error_message := 'Error al insertar codigo de retencion.';
                                        RAISE e_vend_exception;
                                ELSE

                                     fnd_file.put_line(fnd_file.output,'<G_TAX>');
                                     fnd_file.put_line(fnd_file.output,'<TAX>'||v_tax_name||'</TAX>');
                                     fnd_file.put_line(fnd_file.output,'</G_TAX>');

                                END IF;

                            END IF;

                        END IF;

                    END IF;


                ELSE  --Si es CMI, calculo RTU_CMI (NO Primaria),RTU_NO_SEDE (NO Primaria),RTU_0 (Primaria), para activar la derivacion


                    /*RTU_CMI*/
                    fnd_file.put_line(fnd_file.log,'Impuesto: '||p_rtu_cmi);
                    fnd_file.put_line(fnd_file.log,'Obteniendo ID');

                    BEGIN
                                select atc.tax_id,atc.name
                                  into v_tax_id,v_tax_name
                                  from ap_tax_codes_all atc
                                      ,ap_awt_tax_rates_all aatra
                                 where atc.tax_type = 'AWT'
                                   and atc.org_id = r_org.org_id
                                   and atc.org_id = aatra.org_id
                                   and atc.global_attribute4 = p_awt_type_code
                                   and atc.name = p_rtu_cmi
                                   and atc.NAME = aatra.tax_name
                                   and NVL(TRUNC(atc.start_date),trunc(sysdate)) <= trunc(sysdate)
                                   and NVL(TRUNC(atc.inactive_date),trunc(sysdate)) >= trunc(sysdate)
                                   and NVL(TRUNC(aatra.start_date),trunc(sysdate)) <= trunc(sysdate)
                                   and NVL(TRUNC(aatra.end_date),trunc(sysdate)) >= trunc(sysdate);

                    EXCEPTION
                      WHEN OTHERS THEN
                         p_error_message := 'Error al obtener datos del impuesto para : '||p_rtu_cmi||'. Error: '||SQLERRM;
                         RAISE e_vend_exception;
                    END;

                    fnd_file.put_line(fnd_file.log,'Tax ID: '||v_tax_id);

                    IF v_tax_id IS NOT NULL THEN

                        /*Verifico si el proveedor ya tiene una aplicabilidad para este impuesto*/
                        fnd_file.put_line(fnd_file.log,'Verificando Aplicabilidad del Proveedor');
                        BEGIN

                            SELECT supp_awt_type_id
                                  ,wh_subject_flag
                            INTO v_supp_awt_type_id
                                ,v_wh_subject_flag
                            FROM jl_zz_ap_supp_awt_types
                            WHERE vendor_id = r_vendor.vendor_id
                            AND awt_type_code = p_awt_type_code;

                        EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                               /*Si no tiene un type, lo creo*/
                               fnd_file.put_line(fnd_file.log,'Creando aplicabilidad del proveedor');
                               v_supp_awt_type_id := insert_supp_awt_type(p_vendor_id => r_vendor.vendor_id
                                                                         ,p_awt_type_code => p_awt_type_code);
                               v_wh_subject_flag := 'Y';

                               IF v_supp_awt_type_id = 0 THEN
                                  p_error_message := 'Error al crear aplicabilidad de retencion (Tipo) en el proveedor';
                                  RAISE e_vend_exception;
                               END IF;

                         WHEN OTHERS THEN
                             p_error_message := 'Error al verificar Tipo de Aplicabilidad para el proveedor: '||r_vendor.vendor_name;
                             RAISE e_vend_exception;
                        END;
                        IF v_wh_subject_flag = 'N' THEN

                            fnd_file.put_line(fnd_file.log,'Activando Aplicabilidad del Proveedor');

                            UPDATE jl_zz_ap_supp_awt_types
                            set wh_subject_flag = 'Y'
                            WHERE vendor_id = r_vendor.vendor_id
                            AND awt_type_code = p_awt_type_code;

                            v_wh_subject_flag := 'Y';

                        END IF;

                        IF v_wh_subject_flag = 'Y' THEN

                            /*Verifico si el codigo de la retencion es primaria*/
                            fnd_file.put_line(fnd_file.log,'Verificando si tiene RTU_CMI y Primario');
                            BEGIN

                                SELECT supp_awt_code_id
                                INTO v_supp_awt_code_id
                                FROM jl_zz_ap_sup_awt_cd_all
                                WHERE supp_awt_type_id  = v_supp_awt_type_id
                                AND primary_tax_flag = 'Y'
                                AND tax_id = v_tax_id
                                and org_id = r_org.org_id;

                            EXCEPTION
                              WHEN OTHERS THEN
                              v_supp_awt_code_id := 0;
                            END;

                            IF v_supp_awt_code_id != 0 THEN /*Actualizamos la exencion*/

                                UPDATE jl_zz_ap_sup_awt_cd_all
                                   SET primary_tax_flag = 'N'
                                      ,attribute_category = 'AR'
                                      ,attribute1 = r_vendor.alicuota
                                      ,attribute2 = 1
                                      ,exemption_start_date =  r_vendor.date_from
                                      ,exemption_end_date  = r_vendor.date_to
                                      ,exemption_rate = r_vendor.porc_exc
                                    WHERE supp_awt_code_id = v_supp_awt_code_id;

                                    /*Guardo la alicuota para las cintas*/
                                    save_awt_rate(r_vendor.vendor_id,v_supp_awt_code_id,r_vendor.date_from,r_vendor.date_to,1,r_vendor.alicuota);

                            ELSE

                                /*Verifico si existe pero NO primaria*/
                                BEGIN

                                    SELECT supp_awt_code_id
                                    INTO v_supp_awt_code_id
                                    FROM jl_zz_ap_sup_awt_cd_all
                                    WHERE supp_awt_type_id  = v_supp_awt_type_id
                                    AND primary_tax_flag = 'N'
                                    AND tax_id = v_tax_id
                                    and org_id = r_org.org_id;

                                EXCEPTION
                                  WHEN OTHERS THEN
                                  v_supp_awt_code_id := 0;
                                END;

                                /*Si el codigo existe y no es primario*/
                                IF v_supp_awt_code_id = 0 THEN

                                    /*Creo el impuesto como primario*/
                                      v_supp_awt_code_id := insert_applicability (p_supp_awt_type_id => v_supp_awt_type_id
                                                                                 ,p_primary_flag => 'N'
                                                                                 ,p_tax_id => v_tax_id
                                                                                 ,p_org_id => r_org.org_id);

                                END IF;

                                IF v_supp_awt_code_id  = 0 THEN
                                        p_error_message := 'Error al insertar codigo de retencion.';
                                        RAISE e_vend_exception;
                                ELSE

                                        UPDATE jl_zz_ap_sup_awt_cd_all
                                           SET attribute_category = 'AR'
                                              ,attribute1 = r_vendor.alicuota
                                              ,attribute2 = r_vendor.coeficiente
                                              ,exemption_start_date =  r_vendor.date_from
                                              ,exemption_end_date  = r_vendor.date_to
                                              ,exemption_rate = r_vendor.porc_exc
                                            WHERE supp_awt_code_id = v_supp_awt_code_id;

                                            /*Guardo la alicuota para las cintas*/
                                    save_awt_rate(r_vendor.vendor_id,v_supp_awt_code_id,r_vendor.date_from,r_vendor.date_to,r_vendor.coeficiente,r_vendor.alicuota);

                                     fnd_file.put_line(fnd_file.output,'<G_TAX>');
                                     fnd_file.put_line(fnd_file.output,'<TAX>'||v_tax_name||'</TAX>');
                                     fnd_file.put_line(fnd_file.output,'<ALICUOTA>'||XX_UTIL_PK.xml_num_display(r_vendor.alicuota,'.,')||'</ALICUOTA>');
                                     fnd_file.put_line(fnd_file.output,'<COEF>'||XX_UTIL_PK.xml_num_display(r_vendor.coeficiente,'.,')||'</COEF>');
                                     fnd_file.put_line(fnd_file.output,'<DATE_FROM>'||TO_CHAR(r_vendor.date_from,'DD/MM/YYYY')||'</DATE_FROM>');
                                     fnd_file.put_line(fnd_file.output,'<DATE_TO>'||TO_CHAR(r_vendor.date_to,'DD/MM/YYYY')||'</DATE_TO>');
                                     fnd_file.put_line(fnd_file.output,'<PORC_EXC>'||XX_UTIL_PK.xml_num_display(r_vendor.porc_exc,'.,')||'</PORC_EXC>');
                                     fnd_file.put_line(fnd_file.output,'</G_TAX>');

                                END IF;

                            END IF;

                        END IF;

                    END IF;

                    /*RTU_NO_SEDE*/
                    BEGIN
                                select atc.tax_id,atc.name
                                  into v_tax_id,v_tax_name
                                  from ap_tax_codes_all atc
                                      ,ap_awt_tax_rates_all aatra
                                 where atc.tax_type = 'AWT'
                                   and atc.org_id = r_org.org_id
                                   and atc.org_id = aatra.org_id
                                   and atc.global_attribute4 = p_awt_type_code
                                   and atc.name = p_rtu_cmi_no_sede
                                   and atc.NAME = aatra.tax_name
                                   and NVL(TRUNC(atc.start_date),trunc(sysdate)) <= trunc(sysdate)
                                   and NVL(TRUNC(atc.inactive_date),trunc(sysdate)) >= trunc(sysdate)
                                   and NVL(TRUNC(aatra.start_date),trunc(sysdate)) <= trunc(sysdate)
                                   and NVL(TRUNC(aatra.end_date),trunc(sysdate)) >= trunc(sysdate);

                    EXCEPTION
                      WHEN OTHERS THEN
                         p_error_message := 'Error al obtener datos del impuesto para : '||p_rtu_cmi_no_sede||'. Error: '||SQLERRM;
                         RAISE e_vend_exception;
                    END;

                    IF v_tax_id IS NOT NULL THEN

                        /*Verifico si el proveedor ya tiene una aplicabilidad para este impuesto*/
                        fnd_file.put_line(fnd_file.log,'Verificando Aplicabilidad del Proveedor');
                        BEGIN

                            SELECT supp_awt_type_id
                                  ,wh_subject_flag
                            INTO v_supp_awt_type_id
                                ,v_wh_subject_flag
                            FROM jl_zz_ap_supp_awt_types
                            WHERE vendor_id = r_vendor.vendor_id
                            AND awt_type_code = p_awt_type_code;

                        EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                               /*Si no tiene un type, lo creo*/
                               fnd_file.put_line(fnd_file.log,'Creando aplicabilidad del proveedor');
                               v_supp_awt_type_id := insert_supp_awt_type(p_vendor_id => r_vendor.vendor_id
                                                                         ,p_awt_type_code => p_awt_type_code);
                               v_wh_subject_flag := 'Y';

                               IF v_supp_awt_type_id = 0 THEN
                                  p_error_message := 'Error al crear aplicabilidad de retencion (Tipo) en el proveedor';
                                  RAISE e_vend_exception;
                               END IF;

                         WHEN OTHERS THEN
                             p_error_message := 'Error al verificar Tipo de Aplicabilidad para el proveedor: '||r_vendor.vendor_name;
                             RAISE e_vend_exception;
                        END;
                        IF v_wh_subject_flag = 'N' THEN

                            fnd_file.put_line(fnd_file.log,'Activando Aplicabilidad del Proveedor');

                            UPDATE jl_zz_ap_supp_awt_types
                            set wh_subject_flag = 'Y'
                            WHERE vendor_id = r_vendor.vendor_id
                            AND awt_type_code = p_awt_type_code;

                            v_wh_subject_flag := 'Y';

                        END IF;

                        IF v_wh_subject_flag = 'Y' THEN

                            /*Verifico si el codigo de la retencion es primaria*/
                            BEGIN

                                SELECT supp_awt_code_id
                                INTO v_supp_awt_code_id
                                FROM jl_zz_ap_sup_awt_cd_all
                                WHERE supp_awt_type_id  = v_supp_awt_type_id
                                AND primary_tax_flag = 'Y'
                                AND tax_id = v_tax_id
                                and org_id = r_org.org_id;

                            EXCEPTION
                              WHEN OTHERS THEN
                              v_supp_awt_code_id := 0;
                            END;

                            IF v_supp_awt_code_id != 0 THEN /*Actualizamos la exencion*/

                                UPDATE jl_zz_ap_sup_awt_cd_all
                                   SET primary_tax_flag = 'N'
                                      ,attribute_category = 'AR'
                                      ,attribute1 = r_vendor.alicuota
                                      ,attribute2 = r_vendor.coeficiente
                                      ,exemption_start_date =  r_vendor.date_from
                                      ,exemption_end_date  = r_vendor.date_to
                                      ,exemption_rate = r_vendor.coef_porc_exc
                                    WHERE supp_awt_code_id = v_supp_awt_code_id;

                                    /*Guardo la alicuota para las cintas*/
                                    save_awt_rate(r_vendor.vendor_id,v_supp_awt_code_id,r_vendor.date_from,r_vendor.date_to,r_vendor.coeficiente,r_vendor.alicuota);

                                    fnd_file.put_line(fnd_file.output,'<G_TAX>');
                                     fnd_file.put_line(fnd_file.output,'<TAX>'||v_tax_name||'</TAX>');
                                     fnd_file.put_line(fnd_file.output,'<ALICUOTA>'||XX_UTIL_PK.xml_num_display(r_vendor.alicuota,'.,')||'</ALICUOTA>');
                                     fnd_file.put_line(fnd_file.output,'<COEF>'||XX_UTIL_PK.xml_num_display(r_vendor.coeficiente,'.,')||'</COEF>');
                                     fnd_file.put_line(fnd_file.output,'<DATE_FROM>'||TO_CHAR(r_vendor.date_from,'DD/MM/YYYY')||'</DATE_FROM>');
                                     fnd_file.put_line(fnd_file.output,'<DATE_TO>'||TO_CHAR(r_vendor.date_to,'DD/MM/YYYY')||'</DATE_TO>');
                                     fnd_file.put_line(fnd_file.output,'<PORC_EXC>'||XX_UTIL_PK.xml_num_display(r_vendor.coef_porc_exc,'.,')||'</PORC_EXC>');
                                     fnd_file.put_line(fnd_file.output,'</G_TAX>');

                            ELSE

                                /*Verifico si existe pero NO primaria*/
                                BEGIN

                                    SELECT supp_awt_code_id
                                    INTO v_supp_awt_code_id
                                    FROM jl_zz_ap_sup_awt_cd_all
                                    WHERE supp_awt_type_id  = v_supp_awt_type_id
                                    AND primary_tax_flag = 'N'
                                    AND tax_id = v_tax_id
                                    and org_id = r_org.org_id;

                                EXCEPTION
                                  WHEN OTHERS THEN
                                  v_supp_awt_code_id := 0;
                                END;

                                /*Si el codigo existe y no es primario*/
                                IF v_supp_awt_code_id = 0 THEN

                                    /*Creo el impuesto como primario*/
                                      v_supp_awt_code_id := insert_applicability (p_supp_awt_type_id => v_supp_awt_type_id
                                                                                 ,p_primary_flag => 'N'
                                                                                 ,p_tax_id => v_tax_id
                                                                                 ,p_org_id => r_org.org_id);

                                END IF;

                                IF v_supp_awt_code_id  = 0 THEN
                                        p_error_message := 'Error al insertar codigo de retencion.';
                                        RAISE e_vend_exception;
                                ELSE

                                        UPDATE jl_zz_ap_sup_awt_cd_all
                                           SET attribute_category = 'AR'
                                              ,attribute1 = r_vendor.alicuota
                                              ,attribute2 = r_vendor.coeficiente
                                              ,exemption_start_date =  r_vendor.date_from
                                              ,exemption_end_date  = r_vendor.date_to
                                              ,exemption_rate = r_vendor.coef_porc_exc
                                            WHERE supp_awt_code_id = v_supp_awt_code_id;

                                     /*Guardo la alicuota para las cintas*/
                                     save_awt_rate(r_vendor.vendor_id,v_supp_awt_code_id,r_vendor.date_from,r_vendor.date_to,r_vendor.coeficiente,r_vendor.alicuota);

                                     fnd_file.put_line(fnd_file.output,'<G_TAX>');
                                     fnd_file.put_line(fnd_file.output,'<TAX>'||v_tax_name||'</TAX>');
                                     fnd_file.put_line(fnd_file.output,'<ALICUOTA>'||XX_UTIL_PK.xml_num_display(r_vendor.alicuota,'.,')||'</ALICUOTA>');
                                     fnd_file.put_line(fnd_file.output,'<COEF>'||XX_UTIL_PK.xml_num_display(r_vendor.coeficiente,'.,')||'</COEF>');
                                     fnd_file.put_line(fnd_file.output,'<DATE_FROM>'||TO_CHAR(r_vendor.date_from,'DD/MM/YYYY')||'</DATE_FROM>');
                                     fnd_file.put_line(fnd_file.output,'<DATE_TO>'||TO_CHAR(r_vendor.date_to,'DD/MM/YYYY')||'</DATE_TO>');
                                     fnd_file.put_line(fnd_file.output,'<PORC_EXC>'||XX_UTIL_PK.xml_num_display(r_vendor.coef_porc_exc,'.,')||'</PORC_EXC>');
                                     fnd_file.put_line(fnd_file.output,'</G_TAX>');

                                END IF;

                            END IF;

                        END IF;

                    END IF;

                   /*RTU_0*/
                    BEGIN
                                select atc.tax_id,atc.name
                                  into v_tax_id,v_tax_name
                                  from ap_tax_codes_all atc
                                      ,ap_awt_tax_rates_all aatra
                                 where atc.tax_type = 'AWT'
                                   and atc.org_id = r_org.org_id
                                   and atc.org_id = aatra.org_id
                                   and atc.global_attribute4 = p_awt_type_code
                                   and atc.name = p_rtu_0
                                   and atc.NAME = aatra.tax_name
                                   and NVL(TRUNC(atc.start_date),trunc(sysdate)) <= trunc(sysdate)
                                   and NVL(TRUNC(atc.inactive_date),trunc(sysdate)) >= trunc(sysdate)
                                   and NVL(TRUNC(aatra.start_date),trunc(sysdate)) <= trunc(sysdate)
                                   and NVL(TRUNC(aatra.end_date),trunc(sysdate)) >= trunc(sysdate);

                    EXCEPTION
                      WHEN OTHERS THEN
                         p_error_message := 'Error al obtener datos del impuesto para : '||p_rtu_0||'. Error: '||SQLERRM;
                         RAISE e_vend_exception;
                    END;

                    IF v_tax_id IS NOT NULL THEN

                        /*Verifico si el proveedor ya tiene una aplicabilidad para este impuesto*/
                        fnd_file.put_line(fnd_file.log,'Verificando Aplicabilidad del Proveedor');
                        BEGIN

                            SELECT supp_awt_type_id
                                  ,wh_subject_flag
                            INTO v_supp_awt_type_id
                                ,v_wh_subject_flag
                            FROM jl_zz_ap_supp_awt_types
                            WHERE vendor_id = r_vendor.vendor_id
                            AND awt_type_code = p_awt_type_code;

                        EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                               /*Si no tiene un type, lo creo*/
                               fnd_file.put_line(fnd_file.log,'Creando aplicabilidad del proveedor');
                               v_supp_awt_type_id := insert_supp_awt_type(p_vendor_id => r_vendor.vendor_id
                                                                         ,p_awt_type_code => p_awt_type_code);
                               v_wh_subject_flag := 'Y';

                               IF v_supp_awt_type_id = 0 THEN
                                  p_error_message := 'Error al crear aplicabilidad de retencion (Tipo) en el proveedor';
                                  RAISE e_vend_exception;
                               END IF;

                         WHEN OTHERS THEN
                             p_error_message := 'Error al verificar Tipo de Aplicabilidad para el proveedor: '||r_vendor.vendor_name;
                             RAISE e_vend_exception;
                        END;
                        IF v_wh_subject_flag = 'N' THEN

                            fnd_file.put_line(fnd_file.log,'Activando Aplicabilidad del Proveedor');

                            UPDATE jl_zz_ap_supp_awt_types
                            set wh_subject_flag = 'Y'
                            WHERE vendor_id = r_vendor.vendor_id
                            AND awt_type_code = p_awt_type_code;

                            v_wh_subject_flag := 'Y';

                        END IF;

                        IF v_wh_subject_flag = 'Y' THEN

                            /*Verifico si el codigo de la retencion es primaria*/
                            fnd_file.put_line(fnd_file.log,'Verificando si tiene RTU_0 y Primario');
                            BEGIN

                                SELECT supp_awt_code_id
                                INTO v_supp_awt_code_id
                                FROM jl_zz_ap_sup_awt_cd_all
                                WHERE supp_awt_type_id  = v_supp_awt_type_id
                                AND primary_tax_flag = 'Y'
                                AND tax_id = v_tax_id
                                and org_id = r_org.org_id;

                            EXCEPTION
                              WHEN OTHERS THEN
                              v_supp_awt_code_id := 0;
                            END;

                            IF v_supp_awt_code_id != 0 THEN /*Actualizamos la exencion*/

                                fnd_file.put_line(fnd_file.output,'<G_TAX>');
                                fnd_file.put_line(fnd_file.output,'<TAX>'||v_tax_name||'</TAX>');
                                fnd_file.put_line(fnd_file.output,'</G_TAX>');

                            ELSE

                                /*Verifico si existe pero NO primaria*/
                                BEGIN

                                    SELECT supp_awt_code_id
                                    INTO v_supp_awt_code_id
                                    FROM jl_zz_ap_sup_awt_cd_all
                                    WHERE supp_awt_type_id  = v_supp_awt_type_id
                                    AND primary_tax_flag = 'N'
                                    AND tax_id = v_tax_id
                                    and org_id = r_org.org_id;

                                EXCEPTION
                                  WHEN OTHERS THEN
                                  v_supp_awt_code_id := 0;
                                END;

                                /*Si el codigo existe y no es primario*/
                                IF v_supp_awt_code_id != 0 THEN

                                    BEGIN
                                        /*Busco si hay un otro impuesto primario*/
                                        SELECT count(1)
                                        INTO v_exists
                                        FROM jl_zz_ap_sup_awt_cd_all
                                        WHERE supp_awt_type_id  = v_supp_awt_type_id
                                        AND tax_id != v_tax_id
                                        AND PRIMARY_TAX_FLAG = 'Y'
                                        and org_id = r_org.org_id;

                                    EXCEPTION
                                      WHEN OTHERS THEN
                                      v_exists := 0;
                                    END;

                                    /*Si hay un otro impuesto primario*/
                                    IF v_exists > 0 THEN

                                     /*Actualizo el primario en NO Primario*/
                                      update jl_zz_ap_sup_awt_cd_all
                                       SET primary_tax_flag = 'N'
                                      WHERE supp_awt_type_id  = v_supp_awt_type_id
                                        AND tax_id != v_tax_id
                                        AND primary_tax_flag = 'Y'
                                        and org_id = r_org.org_id;

                                    END IF;

                                        /*Actualizo el impuesto en Primario*/
                                        UPDATE jl_zz_ap_sup_awt_cd_all
                                        SET primary_tax_flag = 'Y'
                                      WHERE supp_awt_type_id  = v_supp_awt_type_id
                                        AND tax_id = v_tax_id
                                        AND primary_tax_flag = 'N'
                                        and org_id = r_org.org_id;

                                ELSE  /*Si el codigo no existe*/

                                    /*Valido si no hay otro codigo primario*/
                                    BEGIN

                                        SELECT count(1)
                                        INTO v_exists
                                        FROM jl_zz_ap_sup_awt_cd_all
                                        WHERE supp_awt_type_id  = v_supp_awt_type_id
                                        AND tax_id != v_tax_id
                                        and org_id = r_org.org_id
                                        and primary_tax_flag = 'Y';

                                    EXCEPTION
                                      WHEN OTHERS THEN
                                      v_exists := 0;
                                    END;

                                    /*Si no hay marco al nuevo como primario*/
                                    IF v_exists != 0 THEN

                                        /*Si hay marco el primario como NO primario*/
                                        update jl_zz_ap_sup_awt_cd_all
                                        set primary_tax_flag = 'N'
                                            ,last_update_date = sysdate
                                            ,last_updated_by = fnd_global.user_id
                                        WHERE supp_awt_type_id  = v_supp_awt_type_id
                                        AND  primary_tax_flag = 'Y'
                                        AND tax_id != v_tax_id
                                        and org_id = r_org.org_id;

                                    END IF;

                                    /*Creo el impuesto como primario*/
                                      v_supp_awt_code_id := insert_applicability (p_supp_awt_type_id => v_supp_awt_type_id
                                                                                 ,p_primary_flag => 'Y'
                                                                                 ,p_tax_id => v_tax_id
                                                                                 ,p_org_id => r_org.org_id);

                                END IF;

                                IF v_supp_awt_code_id  = 0 THEN
                                        p_error_message := 'Error al insertar codigo de retencion.';
                                        RAISE e_vend_exception;
                                ELSE

                                     fnd_file.put_line(fnd_file.output,'<G_TAX>');
                                     fnd_file.put_line(fnd_file.output,'<TAX>'||v_tax_name||'</TAX>');
                                     fnd_file.put_line(fnd_file.output,'</G_TAX>');

                                END IF;

                            END IF;

                        END IF;

                    END IF;


                END IF;
           ELSE

                    /*Actualizamos el Wh_Subject_flag de RIBB_TU en N*/

                    /*Verifico si el proveedor ya tiene una aplicabilidad para este impuesto*/
                    fnd_file.put_line(fnd_file.log,'Verificando Aplicabilidad del Proveedor PARA RIBB_TU');
                    BEGIN

                        SELECT 1
                        INTO v_exists
                        FROM jl_zz_ap_supp_awt_types
                        WHERE vendor_id = r_vendor.vendor_id
                        AND awt_type_code = p_awt_type_code
                        AND wh_subject_flag = 'N';

                    EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                           /*Si no tiene un type, lo creo*/
                           UPDATE jl_zz_ap_supp_awt_types
                              SET wh_subject_flag = 'N'
                            WHERE vendor_id = r_vendor.vendor_id
                              AND awt_type_code = p_awt_type_code
                              AND wh_subject_flag = 'Y';

                     WHEN OTHERS THEN
                         p_error_message := 'Error al verificar Tipo de Aplicabilidad para el proveedor: '||r_vendor.vendor_name;
                         RAISE e_vend_exception;
                    END;

                   /*RTU_0_CAST Aplica 0 Para que lo actualice XX_AP_REEMPLAZO_AWT_PK si no esta en tabla de derivaciones*/
                    BEGIN
                                select atc.tax_id,atc.name
                                  into v_tax_id,v_tax_name
                                  from ap_tax_codes_all atc
                                      ,ap_awt_tax_rates_all aatra
                                 where atc.tax_type = 'AWT'
                                   and atc.org_id = r_org.org_id
                                   and atc.org_id = aatra.org_id
                                   and atc.global_attribute4 = p_awt_type_code_cast
                                   and atc.name = p_rtu_0_cast
                                   and atc.NAME = aatra.tax_name
                                   and NVL(TRUNC(atc.start_date),trunc(sysdate)) <= trunc(sysdate)
                                   and NVL(TRUNC(atc.inactive_date),trunc(sysdate)) >= trunc(sysdate)
                                   and NVL(TRUNC(aatra.start_date),trunc(sysdate)) <= trunc(sysdate)
                                   and NVL(TRUNC(aatra.end_date),trunc(sysdate)) >= trunc(sysdate);

                    EXCEPTION
                      WHEN OTHERS THEN
                         p_error_message := 'Error al obtener datos del impuesto para : '||p_rtu_0_cast||'. Error: '||SQLERRM;
                         RAISE e_vend_exception;
                    END;

                    IF v_tax_id IS NOT NULL THEN

                        /*Verifico si el proveedor ya tiene una aplicabilidad para este impuesto*/
                        fnd_file.put_line(fnd_file.log,'Verificando Aplicabilidad del Proveedor');
                        BEGIN

                            SELECT supp_awt_type_id
                                  ,wh_subject_flag
                            INTO v_supp_awt_type_id
                                ,v_wh_subject_flag
                            FROM jl_zz_ap_supp_awt_types
                            WHERE vendor_id = r_vendor.vendor_id
                            AND awt_type_code = p_awt_type_code_cast;

                        EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                               /*Si no tiene un type, lo creo*/
                               fnd_file.put_line(fnd_file.log,'Creando aplicabilidad del proveedor');
                               v_supp_awt_type_id := insert_supp_awt_type(p_vendor_id => r_vendor.vendor_id
                                                                         ,p_awt_type_code => p_awt_type_code_cast);
                               v_wh_subject_flag := 'Y';

                               IF v_supp_awt_type_id = 0 THEN
                                  p_error_message := 'Error al crear aplicabilidad de retencion (Tipo) en el proveedor';
                                  RAISE e_vend_exception;
                               END IF;

                         WHEN OTHERS THEN
                             p_error_message := 'Error al verificar Tipo de Aplicabilidad para el proveedor: '||r_vendor.vendor_name;
                             RAISE e_vend_exception;
                        END;
                        IF v_wh_subject_flag = 'N' THEN

                            fnd_file.put_line(fnd_file.log,'Activando Aplicabilidad del Proveedor');

                            UPDATE jl_zz_ap_supp_awt_types
                            set wh_subject_flag = 'Y'
                            WHERE vendor_id = r_vendor.vendor_id
                            AND awt_type_code = p_awt_type_code_cast;

                            v_wh_subject_flag := 'Y';

                        END IF;

                        IF v_wh_subject_flag = 'Y' THEN

                            /*Verifico si el codigo de la retencion es primaria*/
                            BEGIN

                                SELECT supp_awt_code_id
                                INTO v_supp_awt_code_id
                                FROM jl_zz_ap_sup_awt_cd_all
                                WHERE supp_awt_type_id  = v_supp_awt_type_id
                                AND primary_tax_flag = 'Y'
                                AND tax_id = v_tax_id
                                and org_id = r_org.org_id;

                            EXCEPTION
                              WHEN OTHERS THEN
                              v_supp_awt_code_id := 0;
                            END;

                            IF v_supp_awt_code_id != 0 THEN /*Actualizamos la exencion*/

                                UPDATE jl_zz_ap_sup_awt_cd_all
                                   SET primary_tax_flag = 'N'
                                    WHERE supp_awt_code_id = v_supp_awt_code_id;

                            ELSE

                                /*Verifico si existe pero NO primaria*/
                                BEGIN

                                    SELECT supp_awt_code_id
                                    INTO v_supp_awt_code_id
                                    FROM jl_zz_ap_sup_awt_cd_all
                                    WHERE supp_awt_type_id  = v_supp_awt_type_id
                                    AND primary_tax_flag = 'N'
                                    AND tax_id = v_tax_id
                                    and org_id = r_org.org_id;

                                EXCEPTION
                                  WHEN OTHERS THEN
                                  v_supp_awt_code_id := 0;
                                END;

                                /*Si el codigo existe y no es primario*/
                                IF v_supp_awt_code_id = 0 THEN

                                    /*Creo el impuesto como primario*/
                                      v_supp_awt_code_id := insert_applicability (p_supp_awt_type_id => v_supp_awt_type_id
                                                                                 ,p_primary_flag => 'N'
                                                                                 ,p_tax_id => v_tax_id
                                                                                 ,p_org_id => r_org.org_id);

                                END IF;

                                IF v_supp_awt_code_id  = 0 THEN
                                        p_error_message := 'Error al insertar codigo de retencion.';
                                        RAISE e_vend_exception;
                                END IF;

                            END IF;

                        END IF;

                    END IF;

               /*RTU_NI*/
                BEGIN
                            select atc.tax_id,atc.name,aatra.tax_rate
                              into v_tax_id,v_tax_name,v_tax_rate
                              from ap_tax_codes_all atc
                                  ,ap_awt_tax_rates_all aatra
                             where atc.tax_type = 'AWT'
                               and atc.org_id = r_org.org_id
                               and atc.org_id = aatra.org_id
                               and atc.global_attribute4 = p_awt_type_code_cast
                               and atc.name = p_rtu_ni
                               and atc.NAME = aatra.tax_name
                               and NVL(TRUNC(atc.start_date),trunc(sysdate)) <= trunc(sysdate)
                               and NVL(TRUNC(atc.inactive_date),trunc(sysdate)) >= trunc(sysdate)
                               and NVL(TRUNC(aatra.start_date),trunc(sysdate)) <= trunc(sysdate)
                               and NVL(TRUNC(aatra.end_date),trunc(sysdate)) >= trunc(sysdate);

                EXCEPTION
                  WHEN OTHERS THEN
                     p_error_message := 'Error al obtener datos del impuesto para : '||p_rtu_0||'. Error: '||SQLERRM;
                     RAISE e_vend_exception;
                END;

                IF v_tax_id IS NOT NULL THEN

                    /*Verifico si el proveedor ya tiene una aplicabilidad para este impuesto*/
                    fnd_file.put_line(fnd_file.log,'Verificando Aplicabilidad del Proveedor');
                    BEGIN

                        SELECT supp_awt_type_id
                              ,wh_subject_flag
                          INTO v_supp_awt_type_id
                              ,v_wh_subject_flag
                          FROM jl_zz_ap_supp_awt_types
                         WHERE vendor_id = r_vendor.vendor_id
                           AND awt_type_code = p_awt_type_code_cast;

                    EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                           /*Si no tiene un type, lo creo*/
                           fnd_file.put_line(fnd_file.log,'Creando aplicabilidad del proveedor');

                           v_supp_awt_type_id := insert_supp_awt_type(p_vendor_id => r_vendor.vendor_id
                                                                     ,p_awt_type_code => p_awt_type_code_cast);
                           v_wh_subject_flag := 'Y';

                           IF v_supp_awt_type_id = 0 THEN
                              p_error_message := 'Error al crear aplicabilidad de retencion (Tipo) en el proveedor';
                              RAISE e_vend_exception;
                           END IF;

                     WHEN OTHERS THEN
                         p_error_message := 'Error al verificar Tipo de Aplicabilidad para el proveedor: '||r_vendor.vendor_name;
                         RAISE e_vend_exception;
                    END;
                    IF v_wh_subject_flag = 'N' THEN

                        fnd_file.put_line(fnd_file.log,'Activando Aplicabilidad del Proveedor');

                        UPDATE jl_zz_ap_supp_awt_types
                        set wh_subject_flag = 'Y'
                        WHERE vendor_id = r_vendor.vendor_id
                        AND awt_type_code = p_awt_type_code_cast;

                        v_wh_subject_flag := 'Y';

                    END IF;

                    IF v_wh_subject_flag = 'Y' THEN

                        /*Verifico si el codigo de la retencion es primaria*/
                        fnd_file.put_line(fnd_file.log,'Verificando si tiene RTU_NI y Primario');

                        BEGIN

                            SELECT supp_awt_code_id
                              INTO v_supp_awt_code_id
                              FROM jl_zz_ap_sup_awt_cd_all
                             WHERE supp_awt_type_id  = v_supp_awt_type_id
                               AND primary_tax_flag = 'Y'
                               AND tax_id = v_tax_id
                               AND org_id = r_org.org_id;

                        EXCEPTION
                          WHEN OTHERS THEN
                             v_supp_awt_code_id := 0;
                        END;

                        IF v_supp_awt_code_id = 0 THEN /*Actualizamos la exencion*/

                            /*Verifico si existe pero NO primaria*/
                            BEGIN

                                SELECT supp_awt_code_id
                                INTO v_supp_awt_code_id
                                FROM jl_zz_ap_sup_awt_cd_all
                                WHERE supp_awt_type_id  = v_supp_awt_type_id
                                AND primary_tax_flag = 'N'
                                AND tax_id = v_tax_id
                                and org_id = r_org.org_id;

                            EXCEPTION
                              WHEN OTHERS THEN
                              v_supp_awt_code_id := 0;
                            END;

                            /*Si el codigo existe y no es primario*/
                            IF v_supp_awt_code_id != 0 THEN

                                BEGIN
                                    /*Busco si hay un otro impuesto primario*/
                                    SELECT count(1)
                                      INTO v_exists
                                      FROM jl_zz_ap_sup_awt_cd_all
                                     WHERE supp_awt_type_id  = v_supp_awt_type_id
                                       AND tax_id != v_tax_id
                                       AND PRIMARY_TAX_FLAG = 'Y'
                                       and org_id = r_org.org_id;

                                EXCEPTION
                                  WHEN OTHERS THEN
                                  v_exists := 0;
                                END;

                                /*Si hay un otro impuesto primario*/
                                IF v_exists > 0 THEN

                                 /*Actualizo el primario en NO Primario*/
                                  update jl_zz_ap_sup_awt_cd_all
                                   SET primary_tax_flag = 'N'
                                  WHERE supp_awt_type_id  = v_supp_awt_type_id
                                    AND tax_id != v_tax_id
                                    AND primary_tax_flag = 'Y'
                                    and org_id = r_org.org_id;

                                END IF;

                                    /*Actualizo el impuesto en Primario*/
                                    UPDATE jl_zz_ap_sup_awt_cd_all
                                    SET primary_tax_flag = 'Y'
                                  WHERE supp_awt_type_id  = v_supp_awt_type_id
                                    AND tax_id = v_tax_id
                                    AND primary_tax_flag = 'N'
                                    and org_id = r_org.org_id;

                                    save_awt_rate(r_vendor.vendor_id,v_supp_awt_code_id,r_vendor.date_from,r_vendor.date_to,1,v_tax_rate);

                                    fnd_file.put_line(fnd_file.output,'<G_TAX>');
                                    fnd_file.put_line(fnd_file.output,'<TAX>'||v_tax_name||'</TAX>');
                                    fnd_file.put_line(fnd_file.output,'</G_TAX>');

                            ELSE  /*Si el codigo no existe*/

                                /*Valido si no hay otro codigo primario*/
                                BEGIN

                                    SELECT count(1)
                                    INTO v_exists
                                    FROM jl_zz_ap_sup_awt_cd_all
                                    WHERE supp_awt_type_id  = v_supp_awt_type_id
                                    AND tax_id != v_tax_id
                                    and org_id = r_org.org_id
                                    and primary_tax_flag = 'Y';

                                EXCEPTION
                                  WHEN OTHERS THEN
                                  v_exists := 0;
                                END;

                                /*Si no hay marco al nuevo como primario*/
                                IF v_exists != 0 THEN

                                    /*Si hay marco el primario como NO primario*/
                                    update jl_zz_ap_sup_awt_cd_all
                                       set primary_tax_flag = 'N'
                                        ,last_update_date = sysdate
                                        ,last_updated_by = fnd_global.user_id
                                    WHERE supp_awt_type_id  = v_supp_awt_type_id
                                    AND  primary_tax_flag = 'Y'
                                    AND tax_id != v_tax_id
                                    and org_id = r_org.org_id;

                                END IF;

                                /*Creo el impuesto como primario*/
                                  v_supp_awt_code_id := insert_applicability (p_supp_awt_type_id => v_supp_awt_type_id
                                                                             ,p_primary_flag => 'Y'
                                                                             ,p_tax_id => v_tax_id
                                                                             ,p_org_id => r_org.org_id);

                            END IF;

                            IF v_supp_awt_code_id  = 0 THEN
                                    p_error_message := 'Error al insertar codigo de retencion.';
                                    RAISE e_vend_exception;
                            ELSE

                                 save_awt_rate(r_vendor.vendor_id,v_supp_awt_code_id,r_vendor.date_from,r_vendor.date_to,1,v_tax_rate);

                                 fnd_file.put_line(fnd_file.output,'<G_TAX>');
                                 fnd_file.put_line(fnd_file.output,'<TAX>'||v_tax_name||'</TAX>');
                                 fnd_file.put_line(fnd_file.output,'</G_TAX>');

                            END IF;
                        ELSE

                            fnd_file.put_line(fnd_file.output,'<G_TAX>');
                            fnd_file.put_line(fnd_file.output,'<TAX>'||v_tax_name||'</TAX>');
                            fnd_file.put_line(fnd_file.output,'</G_TAX>');

                        END IF;

                    END IF;

                END IF;


           END IF;

           fnd_file.put_line(fnd_file.output,' </G_VENDORS>');


           EXCEPTION
            WHEN e_vend_exception THEN
              fnd_file.put_line(fnd_file.output,' </G_VENDORS>');
            WHEN OTHERS THEN
              fnd_file.put_line(fnd_file.output,' </G_VENDORS>');
           END;

        END LOOP;

        fnd_file.put_line(fnd_file.output,' </LIST_G_VENDORS>');
        fnd_file.put_line(fnd_file.output,' </G_ORGS>');

    END LOOP;

    fnd_file.put_line(fnd_file.output,' </LIST_G_ORGS>');
    fnd_file.put_line(fnd_file.output,' </G_AWT>');
    fnd_file.put_line(fnd_file.output,' </LIST_G_AWT>');

    IF p_status is null then
       p_status := 'S';
    END IF;

    fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.PROCESS_AP_AWT_CODES (-)');

EXCEPTION
 WHEN e_cust_exception THEN
   p_status := 'W';
   fnd_file.put_line(fnd_file.log,p_error_message);
   fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.PROCESS_AP_AWT_CODES (!)');
 WHEN OTHERS THEN
   p_status := 'W';
   p_error_message := 'Error OTHERS en PROCESS_AP_AWT_CODES. Error: '||SQLERRM;
   fnd_file.put_line(fnd_file.log,p_error_message);
   fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.PROCESS_AP_AWT_CODES (!)');
END;

PROCEDURE MAIN_AP_PROCESS (RETCODE OUT NUMBER
                          ,ERRBUF  OUT VARCHAR2
                          ,p_grupo_emp IN VARCHAR2
                          ,p_org_id IN NUMBER
                          ,p_vendor_id IN NUMBER
                          ,P_PERIOD_NAME IN VARCHAR2
                          ,p_awt_type_code IN VARCHAR2
                          ,p_awt_type_code_cast IN VARCHAR2
                          ,p_rtu_0 IN VARCHAR2
                          ,p_rtu_0_cast IN VARCHAR2
                          ,p_rtu_local IN VARCHAR2
                          ,p_rtu_cmi IN VARCHAR2
                          ,p_rtu_ni IN VARCHAR2
                          ,p_rtu_cmi_no_sede IN VARCHAR2
                          ,p_zero_rate IN VARCHAR2) IS

v_fiscal_period VARCHAR2(30);
v_found VARCHAr2(1);
v_status VARCHAR2(1);
v_error_message VARCHAR2(2000);
e_cust_exception EXCEPTION;

BEGIN


    fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.MAIN_AP_PROCESS (+)');

    g_nls_req := '.,';

    /*Obtengo datos del periodo*/
    BEGIN
        SELECT TO_CHAR(TRUNC(gps.start_date),'YYYYMM')
          INTO v_fiscal_period
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

    /*Verifico que el padron de IIBB de Tucuman tenga datos.*/
    BEGIN
        SELECT 'Y'
          INTO v_found
          FROM DUAL
        WHERE EXISTS ( SELECT 1
                         FROM xxarpilcptuc
                        WHERE v_fiscal_period = periodo);
    EXCEPTION
        WHEN no_data_found THEN
          v_error_message := 'El padron de IIBB de Tucuman no tiene datos para el periodo: '||v_fiscal_period;
          RAISE e_cust_exception;
        WHEN others THEN
          v_error_message := 'Error verificando que el padron ' ||
                          'de IIBB de Tucuman tenga datos. '  ||
                          SQLERRM;
          RAISE e_cust_exception;
    END;

    fnd_file.put_line(fnd_file.output,'<?xml version="1.0" encoding="ISO-8859-1"?>');
    fnd_file.put_line(fnd_file.output,'<XXAPTCPP>');

    PROCESS_AP_AWT_CODES (p_status => v_status
                         ,p_error_message => v_error_message
                         ,p_grupo_emp => p_grupo_emp
                         ,p_org_id => p_org_id
                         ,p_vendor_id => p_vendor_id
                         ,P_PERIOD_NAME => v_fiscal_period
                         ,p_awt_type_code => p_awt_type_code
                         ,p_awt_type_code_cast => p_awt_type_code_cast
                         ,p_rtu_0 => p_rtu_0
                         ,p_rtu_0_cast => p_rtu_0_cast
                         ,p_rtu_local => p_rtu_local
                         ,p_rtu_cmi => p_rtu_cmi
                         ,p_rtu_ni => p_rtu_ni
                         ,p_rtu_cmi_no_sede => p_rtu_cmi_no_sede
                         ,p_zero_rate => p_zero_rate);

    fnd_file.put_line(fnd_file.output,'</XXAPTCPP>');

    fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.MAIN_AP_PROCESS (-)');


EXCEPTION
  WHEN e_cust_exception THEN
     retcode := 1;
     errbuf := v_error_message;
     fnd_file.put_line(fnd_file.log,errbuf);
     RAISE_APPLICATION_ERROR(-20001,'Error Inesperado en los procedimientos internos');
     fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.MAIN_AP_PROCESS (!)');
  WHEN OTHERS THEN
     retcode := 2;
     errbuf := 'Exception OTHERS en MAIN_AP_PROCESS. Error: '||SQLERRM;
     fnd_file.put_line(fnd_file.log,errbuf);
     fnd_file.put_line(fnd_file.log,'XX_AR_TUC_COEF_PER_PKG.MAIN_AP_PROCESS (!)');
     RAISE_APPLICATION_ERROR(-20001,'Error Inesperado en los procedimientos internos');
END;
/*Fin Agregado KHRONUS/E.Sly 20200113 Se agrega logica para AP*/

END XX_AR_TUC_COEF_PER_PKG;
/
EXIT