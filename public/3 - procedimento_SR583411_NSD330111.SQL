declare
  v_count_ok   number;
  v_count_err  number;
  v_count      number;
  v_pref_email varchar2(10);
begin
  --
  begin
    select null
      into v_pref_email 
      from v$instance
     where 1 = 1
       and instance_name = 'PRDEBS';
  exception
    when others then
      v_pref_email := 'TST';
  end;
  --
  -- E-MAIL HCP
  --
  v_count_ok := 0;
  v_count_err := 0;
  for l_hcp in (select *
                  from apps.stn_sr_583411_base_upd ss5bu
                 where 1 = 1
                   and nvl(ss5bu.flag_hcp_email,'N') <> 'Y'
                   and ss5bu.party_site_id is not null) loop
    begin
      --
      begin
        update apps.hz_contact_points hcp
           set hcp.email_address = v_pref_email||l_hcp.hcp_email_address
         where 1 = 1
           and hcp.owner_table_id = l_hcp.party_site_id
           and hcp.owner_table_name = 'HZ_PARTY_SITES'
           and hcp.contact_point_type = 'EMAIL'
           and hcp.primary_flag = 'Y'
           and hcp.status = 'A';
        --
        if sql%notfound then
          update apps.stn_sr_583411_base_upd ss5bu
             set ss5bu.flag_hcp_email = 'N'
               , ss5bu.msg_hcp_email = 'Registro nao localizado'
           where 1 = 1
             and ss5bu.vendor_site_id = l_hcp.vendor_site_id
             and ss5bu.party_site_id = l_hcp.party_site_id;
          --
          v_count_err := v_count_err + 1;
          --
        else
          v_count := sql%rowcount;
          update apps.stn_sr_583411_base_upd ss5bu
             set ss5bu.flag_hcp_email = 'Y'
               , ss5bu.msg_hcp_email = v_count||' - Registro atualizado'
           where 1 = 1
             and ss5bu.vendor_site_id = l_hcp.vendor_site_id
             and ss5bu.party_site_id = l_hcp.party_site_id;
           --
           v_count_ok := v_count_ok + 1;
           v_count := 0;
           --
        end if;     
      exception
        when others then
          dbms_output.put_line('Erro update: '||sqlerrm);
      end;
    exception
      when others then
        dbms_output.put_line('Erro l_hcp:'||sqlerrm);  
    end;
  end loop;
  --  
  dbms_output.put_line('Registros l_hcp');  
  dbms_output.put_line('Registros ok: '||v_count_ok);  
  dbms_output.put_line('Registros erro: '||v_count_err); 
  --
  commit;
  --
  -- E-MAIL ASSA
  --
  v_count_ok := 0;
  v_count_err := 0;
  for l_assa in (select *
                  from apps.stn_sr_583411_base_upd ss5bu
                 where 1 = 1
                   and nvl(ss5bu.flag_assa_email,'N') <> 'Y') loop
    begin
      --
      begin
        update apps.ap_supplier_sites_all assa
           set assa.email_address = v_pref_email||l_assa.assa_email_address
         where 1 = 1
           and assa.vendor_site_id = l_assa.vendor_site_id;
        --
        if sql%notfound then
          update apps.stn_sr_583411_base_upd ss5bu
             set ss5bu.flag_assa_email = 'N'
               , ss5bu.msg_assa_email = 'Registro nao localizado'
           where 1 = 1
             and ss5bu.vendor_site_id = l_assa.vendor_site_id;
          --
          v_count_err := v_count_err + 1;
          --
        else
          v_count := sql%rowcount;
          update apps.stn_sr_583411_base_upd ss5bu
             set ss5bu.flag_assa_email = 'Y'
               , ss5bu.msg_assa_email = v_count||' - Registro atualizado'
           where 1 = 1
             and ss5bu.vendor_site_id = l_assa.vendor_site_id;
           --
           v_count_ok := v_count_ok + 1;
           v_count := 0;
           --
        end if;     
      exception
        when others then
          dbms_output.put_line('Erro update: '||sqlerrm);
      end;
    exception
      when others then
        dbms_output.put_line('Erro l_hcp:'||sqlerrm);  
    end;
  end loop;
  --  
  dbms_output.put_line('Registros l_assa');  
  dbms_output.put_line('Registros ok: '||v_count_ok);  
  dbms_output.put_line('Registros erro: '||v_count_err); 
  --
  commit;
  --
  -- E-MAIL IEPA
  --
  v_count_ok := 0;
  v_count_err := 0;
  for l_iepa in (select *
                  from apps.stn_sr_583411_base_upd ss5bu
                 where 1 = 1
                   and nvl(ss5bu.flag_iepa_email,'N') <> 'Y') loop
    begin
      --
      begin
        --
        update apps.iby_external_payees_all iepa
           set iepa.remit_advice_email = v_pref_email||l_iepa.iepa_remit_advice_email
         where 1 = 1
           and iepa.supplier_site_id  = l_iepa.vendor_site_id;
        --
        if sql%notfound then
          update apps.stn_sr_583411_base_upd ss5bu
             set ss5bu.flag_iepa_email = 'N'
               , ss5bu.msg_iepa_email = 'Registro nao localizado'
           where 1 = 1
             and ss5bu.vendor_site_id = l_iepa.vendor_site_id;
          --
          v_count_err := v_count_err + 1;
          --
        else
          v_count := sql%rowcount;
          update apps.stn_sr_583411_base_upd ss5bu
             set ss5bu.flag_iepa_email = 'Y'
               , ss5bu.msg_iepa_email = v_count||' - Registro atualizado'
           where 1 = 1
             and ss5bu.vendor_site_id = l_iepa.vendor_site_id;
           --
           v_count_ok := v_count_ok + 1;
           v_count := 0;
           --
        end if;     
      exception
        when others then
          dbms_output.put_line('Erro update: '||sqlerrm);
      end;
    exception
      when others then
        dbms_output.put_line('Erro l_hcp:'||sqlerrm);  
    end;
  end loop;
  --  
  dbms_output.put_line('Registros l_iepa');  
  dbms_output.put_line('Registros ok: '||v_count_ok);  
  dbms_output.put_line('Registros erro: '||v_count_err); 
  --
  commit;
  --    
exception
  when others then
    dbms_output.put_line('Erro execucao:'||sqlerrm);  
end;
