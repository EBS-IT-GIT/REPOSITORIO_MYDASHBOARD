DECLARE
  --
  p_ou_from          apps.ap_supplier_sites_all.org_id%TYPE;--  := 81;--'&ORG_ID_ORIGEM';
  p_ou_to            apps.ap_supplier_sites_all.org_id%TYPE;--  := 386; 
  p_vendor_id        apps.ap_suppliers.vendor_id%TYPE := NULL;--'&VENDOR_ID';
  p_vendor_site_id   apps.ap_suppliers.vendor_id%TYPE := NULL;--'&VENDOR_SITE_ID';
  p_count            NUMBER := 0;
  p_countOk          NUMBER := 0;  
  p_countErro        NUMBER := 0;    
  --
  CURSOR c_site_origem( pc_vendor_id       apps.ap_supplier_sites_all.vendor_id%TYPE
                      , pc_org_id          apps.ap_supplier_sites_all.org_id%TYPE
                      , pc_vendor_site_id  apps.ap_supplier_sites_all.vendor_site_id%TYPE
                       ) IS                  
    SELECT assa.*
      FROM apps.ap_supplier_sites_all assa
     WHERE assa.vendor_id                    = NVL(pc_vendor_id,assa.vendor_id)
       AND assa.vendor_site_id               = NVL(pc_vendor_site_id,assa.vendor_site_id)
       AND NVL(assa.inactive_date,SYSDATE+1) >= SYSDATE
       AND assa.VENDOR_ID                     IN  (1736,
1654,
1710,
8016,
1725,
1541,
10018,
1358,
1219,
1041,
1062,
1268,
995,
1225,
390062,
1070,
1092,
15091,
215067,
784,
871,
877,
898,
832,
645,
581,
719,
729,
613,
2001,
464,
7410,
514,
264,
7160,
7060,
121,
7259,
290062,
235,
364062,
13,
21)  
       AND assa.org_id                       = NVL(pc_org_id,assa.org_id)
union
    SELECT assa.*
      FROM apps.ap_supplier_sites_all assa
           ,APPS.AP_SUPPLIERS ASU
     WHERE assa.vendor_id                    = NVL(pc_vendor_id,assa.vendor_id)
       AND assa.vendor_site_id               = NVL(pc_vendor_site_id,assa.vendor_site_id)
       AND NVL(assa.inactive_date,SYSDATE+1) >= SYSDATE
       AND ASSA.VENDOR_ID = ASU.VENDOR_ID
       AND ASU.VENDOR_NAME                  IN  ('Chorus Call, Inc.',
'CONFERENCE CALL DO BRASIL S.A.',
'EXECUTIVO PARK SERVICOS DE ESTACIONAMENTO LTDA',
'FATOR SEGURADORA SA',
'FREIRE LOUREIRO EMPREENDIMENTOS E PARTICIPACOES LTDA',
'MZ CONSULT - SERVICOS E NEGOCIOS LTDA',
'PRODUTIV SERVICOS DE SUPORTE LOGISTICO E TECNOLOGICOS LTDA',
'SICLOS PAGAMENTOS LTDA') 
       AND assa.org_id                       = NVL(pc_org_id,assa.org_id)       
       
       ;                
  --
  l_rSite_Origem c_site_origem%ROWTYPE;
  --
  CURSOR c_dest( pc_ou_from           apps.ap_supplier_sites_all.org_id%TYPE  
               , pc_ou_to             apps.ap_supplier_sites_all.org_id%TYPE
               , pc_vendor_id         apps.ap_supplier_sites_all.vendor_id%TYPE
               , pc_vendor_site_code  apps.ap_supplier_sites_all.vendor_site_code%TYPE
               ) IS
      SELECT hou.organization_id org_id
        FROM hr_operating_units hou
       WHERE nvl( hou.date_to, TRUNC( SYSDATE ) ) >= TRUNC( SYSDATE )
         AND hou.organization_id != pc_ou_from
         AND hou.organization_id = NVL(pc_ou_to,hou.organization_id)
         AND NOT EXISTS( SELECT 1
                           FROM apps.ap_supplier_sites_all assa_dest
                          WHERE assa_dest.vendor_id                               = pc_vendor_id
                            AND assa_dest.org_id                                  = hou.organization_id
                            AND assa_dest.vendor_site_code                        = pc_vendor_site_code
                            AND nvl( assa_dest.inactive_date, trunc( SYSDATE ) ) >= trunc( SYSDATE )
                       )
       ORDER BY organization_id;
    l_rDest c_dest%ROWTYPE;
    --
    l_rVendor_Site   AP_VENDOR_PUB_PKG.r_vendor_site_rec_type;
    l_vReturn_Status VARCHAR2(100);
    l_nMsg_Count     NUMBER;
    l_vMsg_Data      VARCHAR2(4000);
    l_vMsg_Error     VARCHAR2(4000);
    l_nVendor_Site_Id ap_supplier_sites_all.vendor_site_id%TYPE;
    l_nParty_Site_Id  ap_supplier_sites_all.party_site_id%TYPE;
    l_nLocation_Id    ap_supplier_sites_all.location_id%TYPE;
    --
  BEGIN
    --
    dbms_output.put_line( ' *** Parâmetros *** ' );
    dbms_output.put_line( 'ORG_ID_ORIGEM     : ' || p_ou_from );
    dbms_output.put_line( 'ORG_ID_DESTINO    : ' || p_ou_to );
    dbms_output.put_line( 'VENDOR_ID         : ' || p_vendor_id );
    dbms_output.put_line( 'VENDOR_SITE_ID    : ' || p_vendor_site_id );    
    dbms_output.put_line( ' ****************** ' );
    --              
    select organization_id   
      into p_ou_from
     from apps.hr_operating_units
    where name = 'OU_STNCO_BR';
    --
    select organization_id   
      into p_ou_to
     from apps.hr_operating_units
    where name = 'OU_STNPAR';
    --    
    FOR l_rSite_Origem IN  c_site_origem(  pc_vendor_id      => p_vendor_id
                                         , pc_org_id         => p_ou_from
                                         , pc_vendor_site_id => p_vendor_site_id ) LOOP
      --           
      OPEN c_dest( pc_ou_from           => p_ou_from
                 , pc_ou_to             => p_ou_to       
                 , pc_vendor_id        => l_rSite_Origem.vendor_id
                 , pc_vendor_site_code => l_rSite_Origem.vendor_site_code
                 );  
      --
      LOOP
        l_rDest := NULL;
        FETCH c_dest INTO l_rDest; 
        --
        IF ( c_dest%NOTFOUND AND p_count = 0 ) THEN
          dbms_output.put_line('Fornecedor ja existe na org: '||p_ou_to 
                             ||'. Vendor site code: '||l_rSite_Origem.vendor_site_code);       
          dbms_output.put_line( ' ****************** ' );                             
        END IF;
        --
        EXIT WHEN c_dest%NOTFOUND;
        --
        BEGIN
          SELECT accts_pay_code_combination_id
               , prepay_code_combination_id
               , ship_to_location_id
               , bill_to_location_id
               , ship_via_lookup_code
            INTO l_rVendor_Site.accts_pay_code_combination_id
               , l_rVendor_Site.prepay_code_combination_id
               , l_rVendor_Site.ship_to_location_id
               , l_rVendor_Site.bill_to_location_id
               , l_rVendor_Site.ship_via_lookup_code
            FROM financials_system_params_all
           WHERE org_id = l_rDest.org_id;
        EXCEPTION
          WHEN no_data_found THEN
            dbms_output.put_line( 'Erro ao recuperar informações do Setup(FINANCIALS_SYSTEM_PARAMETERS) da OU ' || l_rDest.org_id );
        END;
        --
        p_count := p_count + 1;
        --
        l_rVendor_Site.org_id                        := l_rDest.org_id;
        --
        l_rVendor_Site.location_id                   := l_rSite_Origem.location_id;
        l_rVendor_Site.party_site_id                 := l_rSite_Origem.party_site_id;
        l_rVendor_Site.vendor_id                     := l_rSite_Origem.vendor_id;
        l_rVendor_Site.vendor_site_code              := l_rSite_Origem.vendor_site_code;
        l_rVendor_Site.vendor_site_code_alt          := l_rSite_Origem.vendor_site_code_alt;
        l_rVendor_Site.purchasing_site_flag          := l_rSite_Origem.purchasing_site_flag;
        l_rVendor_Site.rfq_only_site_flag            := l_rSite_Origem.rfq_only_site_flag;
        l_rVendor_Site.pay_site_flag                 := l_rSite_Origem.pay_site_flag;
        l_rVendor_Site.attention_ar_flag             := l_rSite_Origem.attention_ar_flag;
        l_rVendor_Site.address_line1                 := l_rSite_Origem.address_line1;
        l_rVendor_Site.address_lines_alt             := l_rSite_Origem.address_lines_alt;
        l_rVendor_Site.address_line2                 := l_rSite_Origem.address_line2;
        l_rVendor_Site.address_line3                 := l_rSite_Origem.address_line3;
        l_rVendor_Site.city                          := l_rSite_Origem.city;
        l_rVendor_Site.state                         := l_rSite_Origem.state;
        l_rVendor_Site.zip                           := l_rSite_Origem.zip;
        l_rVendor_Site.province                      := l_rSite_Origem.province;
        l_rVendor_Site.country                       := l_rSite_Origem.country;
        l_rVendor_Site.area_code                     := l_rSite_Origem.area_code;
        l_rVendor_Site.phone                         := l_rSite_Origem.phone;
        l_rVendor_Site.customer_num                  := l_rSite_Origem.customer_num;
        l_rVendor_Site.freight_terms_lookup_code     := l_rSite_Origem.freight_terms_lookup_code;
        l_rVendor_Site.fob_lookup_code               := l_rSite_Origem.fob_lookup_code;
        l_rVendor_Site.inactive_date                 := l_rSite_Origem.inactive_date;
        l_rVendor_Site.fax                           := l_rSite_Origem.fax;
        l_rVendor_Site.fax_area_code                 := l_rSite_Origem.fax_area_code;
        l_rVendor_Site.telex                         := l_rSite_Origem.telex;
        l_rVendor_Site.terms_date_basis              := l_rSite_Origem.terms_date_basis;
        l_rVendor_Site.vat_code                      := l_rSite_Origem.vat_code;
        l_rVendor_Site.distribution_set_id           := l_rSite_Origem.distribution_set_id;
        l_rVendor_Site.pay_group_lookup_code         := l_rSite_Origem.pay_group_lookup_code;
        l_rVendor_Site.payment_priority              := l_rSite_Origem.payment_priority;
        l_rVendor_Site.terms_id                      := l_rSite_Origem.terms_id;
        l_rVendor_Site.invoice_amount_limit          := l_rSite_Origem.invoice_amount_limit;
        l_rVendor_Site.pay_date_basis_lookup_code    := l_rSite_Origem.pay_date_basis_lookup_code;
        l_rVendor_Site.always_take_disc_flag         := l_rSite_Origem.always_take_disc_flag;
        l_rVendor_Site.invoice_currency_code         := l_rSite_Origem.invoice_currency_code;
        l_rVendor_Site.payment_currency_code         := l_rSite_Origem.payment_currency_code;
        l_rVendor_Site.hold_all_payments_flag        := l_rSite_Origem.hold_all_payments_flag;
        l_rVendor_Site.hold_future_payments_flag     := l_rSite_Origem.hold_future_payments_flag;
        l_rVendor_Site.hold_reason                   := l_rSite_Origem.hold_reason;
        l_rVendor_Site.hold_unmatched_invoices_flag  := l_rSite_Origem.hold_unmatched_invoices_flag;
        l_rVendor_Site.ap_tax_rounding_rule          := l_rSite_Origem.ap_tax_rounding_rule;
        l_rVendor_Site.auto_tax_calc_flag            := l_rSite_Origem.auto_tax_calc_flag;
        l_rVendor_Site.amount_includes_tax_flag      := l_rSite_Origem.amount_includes_tax_flag;
        l_rVendor_Site.tax_reporting_site_flag       := l_rSite_Origem.tax_reporting_site_flag;
        l_rVendor_Site.attribute_category            := l_rSite_Origem.attribute_category;
        l_rVendor_Site.attribute1                    := l_rSite_Origem.attribute1;
        l_rVendor_Site.attribute2                    := l_rSite_Origem.attribute2;
        l_rVendor_Site.attribute3                    := l_rSite_Origem.attribute3;
        l_rVendor_Site.attribute4                    := l_rSite_Origem.attribute4;
        l_rVendor_Site.attribute5                    := l_rSite_Origem.attribute5;
        l_rVendor_Site.attribute6                    := l_rSite_Origem.attribute6;
        l_rVendor_Site.attribute7                    := l_rSite_Origem.attribute7;
        l_rVendor_Site.attribute8                    := l_rSite_Origem.attribute8;
        l_rVendor_Site.attribute9                    := l_rSite_Origem.attribute9;
        l_rVendor_Site.attribute10                   := l_rSite_Origem.attribute10;
        l_rVendor_Site.attribute11                   := l_rSite_Origem.attribute11;
        l_rVendor_Site.attribute12                   := l_rSite_Origem.attribute12;
        l_rVendor_Site.attribute13                   := l_rSite_Origem.attribute13;
        l_rVendor_Site.attribute14                   := l_rSite_Origem.attribute14;
        l_rVendor_Site.attribute15                   := l_rSite_Origem.attribute15;
        l_rVendor_Site.validation_number             := l_rSite_Origem.validation_number;
        l_rVendor_Site.exclude_freight_from_discount := l_rSite_Origem.exclude_freight_from_discount;
        l_rVendor_Site.vat_registration_num          := l_rSite_Origem.vat_registration_num;
        l_rVendor_Site.check_digits                  := l_rSite_Origem.check_digits;
        l_rVendor_Site.address_line4                 := l_rSite_Origem.address_line4;
        l_rVendor_Site.county                        := l_rSite_Origem.county;
        l_rVendor_Site.address_style                 := l_rSite_Origem.address_style;
        l_rVendor_Site.language                      := l_rSite_Origem.language;
        l_rVendor_Site.allow_awt_flag                := l_rSite_Origem.allow_awt_flag;
        l_rVendor_Site.awt_group_id                  := l_rSite_Origem.awt_group_id;
        l_rVendor_Site.global_attribute1             := l_rSite_Origem.global_attribute1;
        l_rVendor_Site.global_attribute2             := l_rSite_Origem.global_attribute2;
        l_rVendor_Site.global_attribute3             := l_rSite_Origem.global_attribute3;
        l_rVendor_Site.global_attribute4             := l_rSite_Origem.global_attribute4;
        l_rVendor_Site.global_attribute5             := l_rSite_Origem.global_attribute5;
        l_rVendor_Site.global_attribute6             := l_rSite_Origem.global_attribute6;
        l_rVendor_Site.global_attribute7             := l_rSite_Origem.global_attribute7;
        l_rVendor_Site.global_attribute8             := l_rSite_Origem.global_attribute8;
        l_rVendor_Site.global_attribute9             := l_rSite_Origem.global_attribute9;
        l_rVendor_Site.global_attribute10            := l_rSite_Origem.global_attribute10;
        l_rVendor_Site.global_attribute11            := l_rSite_Origem.global_attribute11;
        l_rVendor_Site.global_attribute12            := l_rSite_Origem.global_attribute12;
        l_rVendor_Site.global_attribute13            := l_rSite_Origem.global_attribute13;
        l_rVendor_Site.global_attribute14            := l_rSite_Origem.global_attribute14;
        l_rVendor_Site.global_attribute15            := l_rSite_Origem.global_attribute15;
        l_rVendor_Site.global_attribute16            := l_rSite_Origem.global_attribute16;
        l_rVendor_Site.global_attribute17            := l_rSite_Origem.global_attribute17;
        l_rVendor_Site.global_attribute18            := l_rSite_Origem.global_attribute18;
        l_rVendor_Site.global_attribute19            := l_rSite_Origem.global_attribute19;
        l_rVendor_Site.global_attribute20            := l_rSite_Origem.global_attribute20;
        l_rVendor_Site.global_attribute_category     := l_rSite_Origem.global_attribute_category;
        l_rVendor_Site.edi_transaction_handling      := l_rSite_Origem.edi_transaction_handling;
        l_rVendor_Site.edi_id_number                 := l_rSite_Origem.edi_id_number;
        l_rVendor_Site.edi_payment_method            := l_rSite_Origem.edi_payment_method;
        l_rVendor_Site.edi_payment_format            := l_rSite_Origem.edi_payment_format;
        l_rVendor_Site.edi_remittance_method         := l_rSite_Origem.edi_remittance_method;
        l_rVendor_Site.bank_charge_bearer            := l_rSite_Origem.bank_charge_bearer;
        l_rVendor_Site.edi_remittance_instruction    := l_rSite_Origem.edi_remittance_instruction;
        l_rVendor_Site.pay_on_code                   := l_rSite_Origem.pay_on_code;
        l_rVendor_Site.default_pay_site_id           := l_rSite_Origem.default_pay_site_id;
        l_rVendor_Site.pay_on_receipt_summary_code   := l_rSite_Origem.pay_on_receipt_summary_code;
        l_rVendor_Site.tp_header_id                  := l_rSite_Origem.tp_header_id;
        l_rVendor_Site.ece_tp_location_code          := l_rSite_Origem.ece_tp_location_code;
        l_rVendor_Site.pcard_site_flag               := l_rSite_Origem.pcard_site_flag;
        l_rVendor_Site.match_option                  := l_rSite_Origem.match_option;
        l_rVendor_Site.country_of_origin_code        := l_rSite_Origem.country_of_origin_code;
        l_rVendor_Site.create_debit_memo_flag        := l_rSite_Origem.create_debit_memo_flag;
        l_rVendor_Site.offset_tax_flag               := l_rSite_Origem.offset_tax_flag;
        l_rVendor_Site.supplier_notif_method         := l_rSite_Origem.supplier_notif_method;
        l_rVendor_Site.email_address                 := l_rSite_Origem.email_address;
        l_rVendor_Site.remittance_email              := l_rSite_Origem.remittance_email;
        l_rVendor_Site.primary_pay_site_flag         := l_rSite_Origem.primary_pay_site_flag;
        l_rVendor_Site.shipping_control              := l_rSite_Origem.shipping_control;
        l_rVendor_Site.selling_company_identifier    := l_rSite_Origem.selling_company_identifier;
        l_rVendor_Site.gapless_inv_num_flag          := l_rSite_Origem.gapless_inv_num_flag;
        l_rVendor_Site.duns_number                   := l_rSite_Origem.duns_number;
        l_rVendor_Site.tolerance_id                  := l_rSite_Origem.tolerance_id;
        l_rVendor_Site.services_tolerance_id         := l_rSite_Origem.services_tolerance_id;
        l_rVendor_Site.retainage_rate                := l_rSite_Origem.retainage_rate;
        l_rVendor_Site.pay_awt_group_id              := l_rSite_Origem.pay_awt_group_id;
        l_rVendor_Site.cage_code                     := l_rSite_Origem.cage_code;
        l_rVendor_Site.legal_business_name           := l_rSite_Origem.legal_business_name;
        l_rVendor_Site.doing_bus_as_name             := l_rSite_Origem.doing_bus_as_name;
        l_rVendor_Site.division_name                 := l_rSite_Origem.division_name;
        l_rVendor_Site.small_business_code           := l_rSite_Origem.small_business_code;
        l_rVendor_Site.ccr_comments                  := l_rSite_Origem.ccr_comments;
        l_rVendor_Site.debarment_start_date          := l_rSite_Origem.debarment_start_date;
        l_rVendor_Site.debarment_end_date            := l_rSite_Origem.debarment_end_date;
        --     
        BEGIN
          --
          apps.AP_VENDOR_PUB_PKG.create_vendor_site
            ( p_api_version      => 1.0
            , p_init_msg_list    => fnd_api.g_true
            , p_commit           => fnd_api.g_false
            , p_validation_level => fnd_api.g_valid_level_full
            , x_return_status    => l_vReturn_Status
            , x_msg_count        => l_nMsg_Count
            , x_msg_data         => l_vMsg_Data
            , p_vendor_site_rec  => l_rVendor_Site
            , x_vendor_site_id   => l_nVendor_Site_Id
            , x_party_site_id    => l_nParty_Site_Id
            , x_location_id      => l_nLocation_Id
            );
          --
          IF l_vReturn_Status != FND_API.g_ret_sts_success THEN
            --
            IF l_nMsg_Count = 1 THEN
              l_vMsg_Error := 'Error - AP_VENDOR_PUB_PKG.create_vendor_site: ' || l_vMsg_Data; 
              dbms_output.put_line( 'Vendor_Site_Id Nao Criado: ' || l_vMsg_Error );
              dbms_output.put_line( 'Vendor site id: '|| l_nVendor_Site_Id ||'. '||l_vMsg_Data );             
            ELSE
              --   
              dbms_output.put_line( ' ****************** ' );                  
              dbms_output.put_line( '  - ERRO AO CRIAR LOCAL:  ' || l_rVendor_Site.vendor_site_code );            
              --
              FOR l_nIndex in 1..l_nMsg_Count LOOP
                --    
                dbms_output.put_line( l_nIndex || ' - ' || substr( fnd_msg_pub.get( p_encoded => fnd_api.g_false ), 1, 255 ) );
                --l_vMsg_Error := l_vMsg_Error || substr( fnd_msg_pub.get( p_encoded => fnd_api.g_false ), 1, 255 );
                --dbms_output.put_line(l_nMsg_Count || ' - ' || l_vMsg_Error);--
                --
              END LOOP;
              --
            END IF;
            --    
            p_countErro := p_countErro + 1;
            --raise_application_error( -20050, l_vMsg_Error );
          ELSE
            --
           p_countOk := p_countOk + 1; -- CRIOU o SITE
           -- dbms_output.put_line( 'Vendor_Site_Id Criado: ' || l_nVendor_Site_Id 
           --                    || '. Org id: '|| l_rVendor_Site.org_id 
           --                    || '. Vendor site Code: ' || l_rVendor_Site.vendor_site_code);
          END IF;
          --
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line( 'API - Erro ao chamar para: ' || l_rVendor_Site.vendor_site_code );   
        END;
        --        
        END LOOP;
      CLOSE c_dest;
      --
    --END IF;   
    END LOOP;    
    --CLOSE c_site_origem;
    dbms_output.put_line( ' ****************** ' );
    dbms_output.put_line( ' Total de site criado:  ' ||p_countOk );    
    dbms_output.put_line( ' Total Erro:            ' ||p_countErro );          
    --                 
    COMMIT;--ROLLBACK;
  END;
  --
