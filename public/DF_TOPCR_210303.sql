
DECLARE

CURSOR c_exc IS
select hcas.cust_acct_site_id,hp.party_name,hp.party_id,hl.address1,hcas.org_id,haou.name
  from apps.hz_parties hp
      ,apps.hz_cust_accounts hca
      ,apps.hz_cust_Acct_sites_all hcas
      ,apps.hz_party_sites hps
      ,apps.hz_locations hl
      ,apps.hr_all_organization_units haou
 where hp.party_id = hca.party_id
   and hca.cust_account_id = hcas.cust_account_id
   and hcas.party_site_id = hps.party_site_id
   and hps.location_id = hl.location_id
   and haou.organization_id = hcas.org_id
   and hp.party_id IN (11003756,11026055)
   and hcas.org_id IN (102,104,2235,190,182,1022,1219,1219,1357);

v_start_date date;
v_end_date date;
v_exists NUMBER;
v_count NUMBER;

BEGIN

dbms_output.put_line('Org;Cliente;Dir');

FOR r_add in c_exc LOOP

    v_start_date := to_date('01/03/2021','DD/MM/YYYY');

    IF r_add.party_id = 11003756 THEN --CARGILL
      v_end_date :=to_date('01/09/2021','DD/MM/YYYY');
    ELSE
      v_end_date :=to_date('05/08/2021','DD/MM/YYYY');
    END IF;

    BEGIN
     select count(1)
       into v_exists
       from jl_zz_ar_tx_exc_cus_all
      where address_id = r_add.cust_acct_site_id
        and tax_category_id = 56
        and end_date_active = v_end_date
        and start_date_active = v_start_date;
     
    EXCEPTION
     WHEN OTHERS THEN
       v_exists := 0;
    END;
    
    IF v_exists = 0 THEN

        insert into jl_zz_ar_tx_exc_cus_all 
            values (jl_zz_ar_tx_exc_cus_s.NEXTVAL
                   ,r_add.cust_acct_site_id
                   ,56
                   ,v_end_date
                   ,SYSDATE
                   ,33597 --
                   ,'PERC IB CTES EXENTO 0%'
                   ,-100
                   ,v_start_date
                   ,r_add.org_id
                   ,151651918 --login
                   ,sysdate
                   ,33597 --
                   ,'AR'
                   ,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
                   
                   v_count := v_count + 1;
                   
                   commit;
   
       dbms_output.put_line(r_add.name||';'||r_add.party_name||';'||r_add.address1); 
        
    END IF;
    
END LOOP;

dbms_output.put_line('Exenciones aplicadas: '||v_count);

end;
/
EXIT
 