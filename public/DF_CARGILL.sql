
DECLARE

CURSOR c_cargill is
select DISTINCT hcas.cust_acct_site_id,hl.address1
from hz_cust_accounts hca
,hz_cust_acct_sites_all hcas
,hz_parties hp
,hz_locations hl
,hz_party_sites hps
where hp.party_id = hca.party_id
and hca.cust_account_id = hcas.cust_account_id
and hp.party_name = 'CARGILL S.A.C.I.'
and hcas.org_id = 104
and hcas.party_site_id = hps.party_site_id
and hps.location_id = hl.location_id;

v_dummy NUMBER := 0;

BEGIN

    FOR r_car in c_cargill LOOP 
    
        dbms_output.put_line('Domicilio: '||r_car.address1);
    
        BEGIN
        
            SELECT 1 
            into v_dummy
            from jl.jl_zz_ar_tx_exc_cus_all
            where org_id = 104
            and address_id = r_car.cust_acct_site_id
            and start_date_active >= TO_DATE('01/07/2020','DD/MM/YYYY')
            and tax_category_id = 53;
            
        EXCEPTION
         WHEN OTHERS THEN
           v_dummy := 0;
        END;
        
        IF v_dummy > 0 THEN
        
             update jl.jl_zz_ar_tx_exc_cus_all jzatec
                               set jzatec.last_update_date   = sysdate,
                                   jzatec.last_updated_by    = 2070,
                                   jzatec.last_update_login  = fnd_global.login_id,
                                   jzatec.tax_code           = 'IVAPERC 0%',
                                   jzatec.base_rate          = -100,
                                   jzatec.end_date_active    = TO_DATE('31/12/2999','DD/MM/YYYY')
                             where jzatec.address_id        = r_car.cust_acct_site_id
                               and jzatec.tax_category_id   = 53
                               and jzatec.org_id            = 104;
        
            dbms_output.put_line('Exencion Actualizada');
        
        ELSE
        
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
                                                     org_id,
                                                     last_update_login,
                                                     creation_date,
                                                     created_by)
                                             values (jl_zz_ar_tx_exc_cus_s.nextval,
                                                     r_car.cust_acct_site_id,
                                                     53,
                                                     TO_DATE('31/12/2999','DD/MM/YYYY'),
                                                     sysdate,
                                                     fnd_global.user_id,
                                                     'IVAPERC 0%',
                                                     -100,
                                                     TO_DATE('01/07/2020','DD/MM/YYYY'),
                                                     104,
                                                     fnd_global.login_id,
                                                     sysdate,
                                                     2070);
               commit;
               dbms_output.put_line('Exencion Insertada');
        END IF;
                                  
    END LOOP;
    
END;