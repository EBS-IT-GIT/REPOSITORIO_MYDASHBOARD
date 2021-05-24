CREATE OR REPLACE PACKAGE BODY APPS."XX_AR_TAX_RETURN_NC_PKG"
IS

PROCEDURE PRINT_REPORT (retcode  OUT NUMBER
                       ,errbuf   OUT VARCHAR2
                       ,p_date_from IN  VARCHAR2
                       ,p_date_to   IN  VARCHAR2) IS

CURSOR c_query IS
SELECT hou.name org_name
      ,hp.party_name
      ,rbs_nc.name nc_source
      ,TO_CHAR(rcta_nc.trx_date,'DD/MM/YYYY') trx_date_nc
      ,rcta_nc.trx_number trx_number_nc
      ,rcta_nc.comments
      ,rbs_fc.name fc_source
      ,rcta_fc.trx_number trx_number_fc
      ,(select he2.full_name
          from hr_employees he2
              ,fnd_user fu2
              ,oe_order_lines_all oola
         where oola.line_id = rctla_nc.interface_line_attribute6
           and oola.created_by = fu2.user_id
           and fu2.employee_id = he2.employee_id) oe_created_by
      ,he.full_name nc_created_by
      ,avt_fc.tax_code
      ,avt_fc.tax_rate
      ,SUM(rctla_fc_tax.extended_amount) amount
      ,rcta_fc.customer_trx_id trx_id_fc
 FROM apps.ra_batch_sources_all rbs_fc
     ,apps.ra_batch_sources_all rbs_nc
     ,apps.ra_customer_trx_all rcta_fc
     ,apps.ra_customer_trx_all rcta_nc
     ,apps.ra_cust_trx_types_all rctt_fc
     ,apps.ra_cust_trx_types_all rctt_nc
     ,apps.ra_customer_trx_lines_all rctla_fc
     ,apps.ra_customer_trx_lines_all rctla_fc_tax
     ,apps.ra_customer_trx_lines_all rctla_nc
     ,apps.ra_customer_trx_lines_all_dfv rctla_nc_dfv
     ,apps.hz_cust_accounts hca
     ,apps.hz_parties hp
     ,apps.fnd_user fu
     ,apps.hr_employees he
     ,apps.hr_operating_units hou
     ,apps.ar_vat_tax_all avt_fc
WHERE 1 = 1
     and rbs_fc.batch_source_id = rcta_fc.batch_source_id
     and rbs_nc.batch_source_id = rcta_nc.batch_source_id
     and rcta_nc.customer_trx_id = rctla_nc.customer_trx_id
     and rctla_nc.rowid=rctla_nc_dfv.row_id
     and TO_NUMBER(rctla_nc_dfv.xx_ar_inv_source_line_id) =rctla_fc.customer_trx_line_id
     and rcta_fc.customer_trx_id = rctla_fc.customer_trx_id
     and rctt_fc.cust_trx_type_id = rcta_fc.cust_trx_type_id
     and rctt_fc.type != 'CM'
     and rctt_nc.cust_trx_type_id = rcta_nc.cust_trx_type_id
     and rctt_nc.type = 'CM'
     and rcta_nc.bill_to_customer_id = hca.cust_account_id
     and hca.party_id = hp.party_id
     and fu.user_id = rcta_nc.created_by
     and fu.employee_id = he.employee_id
     and hou.organization_id = rcta_nc.org_id
     and rctla_fc.line_type = 'LINE'
     and rctla_nc.line_type = 'LINE'
     AND rctla_fc_tax.link_to_cust_trx_line_id = rctla_fc.customer_trx_line_id
     and rctla_fc_tax.line_type = 'TAX'
     and rctla_fc_tax.vat_tax_id = avt_fc.vat_tax_id
     and not exists ( select 1
                    from ra_customer_trx_lines_all rctla_tax_nc
                   where rctla_tax_nc.link_to_cust_trx_line_id = rctla_nc.customer_trx_line_id
                     and rctla_tax_nc.line_type = 'TAX'
                     and rctla_tax_nc.vat_tax_id = avt_fc.vat_tax_id)
     and rcta_nc.trx_date >= TRUNC(TO_DATE(p_date_from,'YYYY/MM/DD HH24:MI:SS'))
     and rcta_nc.trx_date <= TRUNC(TO_DATE(p_date_to,'YYYY/MM/DD HH24:MI:SS'))
     GROUP BY hou.name
      ,hp.party_name
      ,rbs_nc.name
      ,TO_CHAR(rcta_nc.trx_date,'DD/MM/YYYY')
      ,rcta_nc.trx_number
      ,rcta_nc.comments
      ,rbs_fc.name
      ,rcta_fc.trx_number
      ,rctla_nc.interface_line_attribute6
      ,he.full_name
      ,avt_fc.tax_code
      ,avt_fc.tax_rate,rcta_fc.customer_trx_id;

BEGIN

    fnd_file.put_line(fnd_file.LOG,'XX_AR_TAX_RETURN_NC_PKG.PRINT_REPORT (+)');

    fnd_file.put_line(fnd_file.output,'<XXARTNRL>');

    fnd_file.put_line(fnd_file.output,'<LIST_G_QUERY>');

    FOR r_trx IN c_query LOOP

       fnd_file.put_line(fnd_file.output,'  <G_QUERY>');

       fnd_file.put_line(fnd_file.output,'    <ORG_NAME>'||r_trx.org_name||'</ORG_NAME>');
       fnd_file.put_line(fnd_file.output,'    <PARTY_NAME>'||r_trx.party_name||'</PARTY_NAME>');
       fnd_file.put_line(fnd_file.output,'    <TRX_NUMBER_NC>'||r_trx.trx_number_nc||'</TRX_NUMBER_NC>');
       fnd_file.put_line(fnd_file.output,'    <TRX_DATE_NC>'||r_trx.trx_date_nc||'</TRX_DATE_NC>');
       fnd_file.put_line(fnd_file.output,'    <COMMENTS>'||r_trx.comments||'</COMMENTS>');
       fnd_file.put_line(fnd_file.output,'    <TRX_NUMBER_FC>'||r_trx.trx_number_fc||'</TRX_NUMBER_FC>');
       fnd_file.put_line(fnd_file.output,'    <OE_CREATED_BY>'||r_trx.oe_created_by||'</OE_CREATED_BY>');
       fnd_file.put_line(fnd_file.output,'    <NC_CREATED_BY>'||r_trx.nc_created_by||'</NC_CREATED_BY>');
       fnd_file.put_line(fnd_file.output,'    <TAX_CODE>'||r_trx.tax_code||'</TAX_CODE>');
       fnd_file.put_line(fnd_file.output,'    <TAX_RATE>'||r_trx.tax_rate||'</TAX_RATE>');
       fnd_file.put_line(fnd_file.output,'    <AMOUNT>'||r_trx.amount||'</AMOUNT>');

       fnd_file.put_line(fnd_file.output,'  </G_QUERY>');

    END LOOP;

    fnd_file.put_line(fnd_file.output,'</LIST_G_QUERY>');

    fnd_file.put_line(fnd_file.output,'</XXARTNRL>');

    fnd_file.put_line(fnd_file.LOG,'XX_AR_TAX_RETURN_NC_PKG.PRINT_REPORT (-)');

EXCEPTION
    WHEN OTHERS THEN
       retcode := 1;
       errbuf := 'Error OTHERS en RUN_REPORT_DIF. Error: '||SQLERRM;
       fnd_file.put_line(fnd_file.LOG,errbuf);
       fnd_file.put_line(fnd_file.LOG,'XX_AR_TAX_RETURN_NC_PKG.PRINT_REPORT (!)');
       IF NOT FND_CONCURRENT.set_completion_status('Warning',errbuf) THEN
         fnd_file.put_line(fnd_file.LOG,'Error Seteando Estado De Finalizacion');
       ELSE
         fnd_file.put_line(fnd_file.LOG,'Estado de finalizacion seteado');
       END IF;
END;

PROCEDURE RUN_REPORT_DIF (retcode     OUT NUMBER
                         ,errbuf      OUT VARCHAR2
                         ,p_date_from IN  VARCHAR2
                         ,p_date_to   IN  VARCHAR2
                         ,p_email_to  IN  VARCHAR2) IS

v_conc_phase        VARCHAR2 (50);
v_conc_status       VARCHAR2 (50);
v_conc_dev_phase    VARCHAR2 (50);
v_conc_dev_status   VARCHAR2 (50);
v_conc_message      VARCHAR2 (250);

e_cust_exception EXCEPTION;
l_template_appl_name           xdo_templates_b.application_short_name%TYPE;
l_template_code                xdo_templates_b.template_code%TYPE;
l_template_language            xdo_templates_b.default_language%TYPE;
l_template_territory           xdo_templates_b.default_territory%TYPE;
l_output_format                VARCHAR2(10);

v_request_id NUMBER;

BEGIN

    fnd_file.put_line(fnd_file.LOG,'XX_AR_TAX_RETURN_NC_PKG.RUN_REPORT_DIF (+)');

    IF p_email_to IS NOT NULL THEN

    IF NOT  fnd_request.add_delivery_option (TYPE             => 'E', -- EMAIL
                                             p_argument1      => 'Listado de Diferencias de Impuesto',-- SUBJECT
                                             p_argument2      => 'noreply@adecoagro.com',-- FROM
                                             p_argument3      => p_email_to,   -- TO
                                             p_argument4      => null ) THEN   -- CC

      errbuf := 'Error al configurar emails de destino. Error: '||SQLERRM;
      RAISE e_cust_exception;
    END IF;

    END IF;

      BEGIN
        SELECT application_short_name, template_code, default_language, default_territory , default_output_type
        INTO   l_template_appl_name,
               l_template_code,
               l_template_language,
               l_template_territory,
               l_output_format
        FROM   xdo_templates_b
        WHERE  template_code = 'XXARTNRL';--cambien al codigo de template suyo
      EXCEPTION
       WHEN OTHERS THEN
           errbuf := 'Error al buscar los datos del template correspondiente al codigo: XXARTNRL: '||sqlerrm;
           raise e_cust_exception;
      END;

      IF NOT fnd_request.add_layout (template_appl_name => l_template_appl_name,
                                    template_code => l_template_code,
                                    template_language => l_template_language,
                                    template_territory => l_template_territory,
                                    output_format => l_output_format ) THEN
         errbuf := 'Error al setear el Template Publisher';
         raise e_cust_exception;
      END IF;

    v_request_id := fnd_request.submit_request('XBOL'
                                              ,'XXARTNRL'
                                              , ''
                                              , ''
                                              , FALSE
                                              , p_date_from
                                              , p_date_to);
    IF v_request_id = 0 THEN
        errbuf := fnd_message.get;
        fnd_file.put_line(fnd_file.log, 'Error ejecutando el concurrente XXARTNRL, Error: ' ||errbuf || ', ' || sqlerrm);
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
        errbuf := fnd_message.get;
        fnd_file.put_line(fnd_file.log,  'Error ejecutando FND_REQUEST.WAIT_FOR_REQUEST. ' ||errbuf || ' ' || SQLERRM);
        RAISE e_cust_exception;
    END IF;

    fnd_file.put_line(fnd_file.LOG,'XX_AR_TAX_RETURN_NC_PKG.RUN_REPORT_DIF (-)');

EXCEPTION
 WHEN e_cust_exception THEN
       retcode := 1;
       fnd_file.put_line(fnd_file.LOG,errbuf);
       fnd_file.put_line(fnd_file.LOG,'XX_AR_TAX_RETURN_NC_PKG.RUN_REPORT_DIF (!)');
       IF NOT FND_CONCURRENT.set_completion_status('Warning',errbuf) THEN
         fnd_file.put_line(fnd_file.LOG,'Error Seteando Estado De Finalizacion');
       ELSE
         fnd_file.put_line(fnd_file.LOG,'Estado de finalizacion seteado');
       END IF;
 WHEN OTHERS THEN
    retcode := 2;
    errbuf := 'Error OTHERS en RUN_REPORT_DIF. Error: '||SQLERRM;
    fnd_file.put_line(fnd_file.LOG,errbuf);
    fnd_file.put_line(fnd_file.LOG,'XX_AR_TAX_RETURN_NC_PKG.RUN_REPORT_DIF (!)');
    RAISE_APPLICATION_ERROR(-20001,errbuf);
END;

PROCEDURE update_uom_code(p_customer_trx_id IN NUMBER) IS

CURSOR c_lines IS
SELECT rctla_dfv.xx_ar_inv_source_line_id,rctla.*
FROM ra_customer_trx_lines_all rctla
,ra_customer_trx_lines_all_dfv rctla_dfv
where rctla.customer_trx_id = p_customer_trx_id
and rctla.rowid = rctla_dfv.row_id;

v_uom_code RA_CUSTOMER_TRX_LINES_ALL.UOM_CODE%TYPE;

BEGIN

    FOR r_lines in c_lines LOOP

        /*Obtengo la udm de la linea de la factura*/
        BEGIN

            SELECT uom_code
              INTO v_uom_code
              FROM ra_customer_trx_lines_all
             WHERE customer_trx_line_id = r_lines.xx_ar_inv_source_line_id;

        EXCEPTION
         WHEN OTHERS THEN
           NULL;
        END;

        IF v_uom_code is not null then
          update ra_customer_trx_lines_all
             set uom_code = v_uom_code
           where customer_trx_id = r_lines.customer_trx_id
             AND customer_trx_line_id = r_lines.customer_trx_line_id;
        END IF;

    END LOOP;

    COMMIT;

EXCEPTION
 WHEN OTHERS THEN
   NULL;
END;

FUNCTION obtener_warehouse_id(p_org_id IN NUMBER) RETURN NUMBER
  IS
      l_warehouse_id NUMBER;
  BEGIN
       BEGIN
       SELECT parameter_value
        INTO l_warehouse_id
        FROM oe_sys_parameters_all
       WHERE parameter_code = 'MASTER_ORGANIZATION_ID'
         AND org_id = p_org_id;

        EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 l_warehouse_id := 0;
              WHEN OTHERS THEN
                 l_warehouse_id := 0;
       END;
       RETURN l_warehouse_id;
  END obtener_warehouse_id;

PROCEDURE apply_credit_memos (p_status              OUT VARCHAR2
                             ,p_error_message       OUT VARCHAR2
                             ,p_customer_trx_id      IN NUMBER
                             ,p_customer_trx_id_cm   IN NUMBER
                             ,p_trx_number_cm        IN VARCHAR2
                             ,p_cm_amount            IN NUMBER
                             ,p_customer_trx_id_int  IN NUMBER
                             ,p_trx_number_int       IN VARCHAR2
                             ,p_int_amount           IN NUMBER) IS

   v_cm_payment_schedule NUMBER;
   v_inv_payment_schedule NUMBER;
   v_int_payment_schedule NUMBER;
   v_ussgl_transaction_code    varchar2(1024);
   v_null_flex                 varchar2(1024);
   v_out_rec_application_id    number;
   v_acctd_amount_applied_from number;
   v_acctd_amount_applied_to   number;
   v_amount_due_remaining      number;

   e_cust_exception EXCEPTION;

BEGIN
        fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.APPLY_CREDIT_MEMOS (+)');

          BEGIN
                select payment_schedule_id,amount_due_remaining
                into v_inv_payment_schedule,v_amount_due_remaining
                from ar_payment_schedules_all ps
                where ps.customer_trx_id = p_customer_trx_id;

          EXCEPTION
           WHEN OTHERS THEN
              p_error_message := 'Error al obtener datos primarios para realizar las Aplicaciones (Payment_schedule_id). Error: '||SQLERRM;
              RAISE e_cust_exception;
          END;

          IF v_amount_due_remaining != 0 OR v_amount_due_remaining >= ABS(p_cm_amount) THEN

            /*Creo la Aplicacion de la NC a la FC/ND*/
            IF p_customer_trx_id_cm is not null then

                 BEGIN

                    select payment_schedule_id
                    into v_cm_payment_schedule
                    from ar_payment_schedules_all ps
                    where ps.customer_trx_id = p_customer_trx_id_cm;

               EXCEPTION
               WHEN OTHERS THEN
                  p_error_message := 'Error al obtener datos primarios para realizar las Aplicaciones (Payment_schedule_id). Error: '||SQLERRM;
                  RAISE e_cust_exception;
               END;

               BEGIN

                  arp_process_application.cm_application(
                    p_cm_ps_id                  => v_cm_payment_schedule,
                    p_invoice_ps_id             => v_inv_payment_schedule,
                    p_amount_applied            => ROUND(p_cm_amount,2)*-1,
                    p_apply_date                => TRUNC(SYSDATE),
                    p_gl_date                   => TRUNC(SYSDATE),
                    p_ussgl_transaction_code    => v_ussgl_transaction_code, -- NULL
                    p_attribute_category        => v_null_flex, -- NULL
                    p_attribute1                => v_null_flex, -- NULL
                    p_attribute2                => v_null_flex, -- NULL
                    p_attribute3                => v_null_flex, -- NULL
                    p_attribute4                => v_null_flex, -- NULL
                    p_attribute5                => v_null_flex, -- NULL
                    p_attribute6                => v_null_flex, -- NULL
                    p_attribute7                => v_null_flex, -- NULL
                    p_attribute8                => v_null_flex, -- NULL
                    p_attribute9                => v_null_flex, -- NULL
                    p_attribute10               => v_null_flex, -- NULL
                    p_attribute11               => v_null_flex, -- NULL
                    p_attribute12               => v_null_flex, -- NULL
                    p_attribute13               => v_null_flex, -- NULL
                    p_attribute14               => v_null_flex, -- NULL
                    p_attribute15               => v_null_flex, -- NULL
                    p_global_attribute_category => v_null_flex, -- NULL
                    p_global_attribute1         => v_null_flex, -- NULL
                    p_global_attribute2         => v_null_flex, -- NULL
                    p_global_attribute3         => v_null_flex, -- NULL
                    p_global_attribute4         => v_null_flex, -- NULL
                    p_global_attribute5         => v_null_flex, -- NULL
                    p_global_attribute6         => v_null_flex, -- NULL
                    p_global_attribute7         => v_null_flex, -- NULL
                    p_global_attribute8         => v_null_flex, -- NULL
                    p_global_attribute9         => v_null_flex, -- NULL
                    p_global_attribute10        => v_null_flex, -- NULL
                    p_global_attribute11        => v_null_flex, -- NULL
                    p_global_attribute12        => v_null_flex, -- NULL
                    p_global_attribute13        => v_null_flex, -- NULL
                    p_global_attribute14        => v_null_flex, -- NULL
                    p_global_attribute15        => v_null_flex, -- NULL
                    p_global_attribute16        => v_null_flex, -- NULL
                    p_global_attribute17        => v_null_flex, -- NULL
                    p_global_attribute18        => v_null_flex, -- NULL
                    p_global_attribute19        => v_null_flex, -- NULL
                    p_global_attribute20        => v_null_flex, -- NULL
                    p_customer_trx_line_id      => NULL,
                    p_comments                  => 'XXARCTTR',
                    p_module_name               => NULL,
                    p_module_version            => '1.0',
                    p_out_rec_application_id    => v_out_rec_application_id,
                    p_acctd_amount_applied_from => v_acctd_amount_applied_from,
                    p_acctd_amount_applied_to   => v_acctd_amount_applied_from
                  );

                  COMMIT;
                  fnd_file.put_line(fnd_file.output,'');
                  fnd_file.put_line(fnd_file.output,'NOTA DE CREDITO '||p_trx_number_cm||' APLICADA');

                EXCEPTION
                WHEN OTHERS THEN
                  p_error_message := 'Error en Aplicacion de Nota de Credito: '||p_trx_number_cm||' .Error: '||SQLERRM;
                  RAISE e_cust_exception;
               END;

            END IF;

        END IF;
        /*Fin de aplicacion NC Real*/

        IF p_status is null then
          p_status := 'S';
        END IF;

        fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.APPLY_CREDIT_MEMOS (-)');
EXCEPTION
WHEN e_cust_exception THEN
   p_status := 'W';
   fnd_file.put_line(fnd_file.log,p_error_message);
   fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.APPLY_CREDIT_MEMOS (!)');
END;

PROCEDURE call_cae_process ( p_status               OUT VARCHAR2
                           , p_error_message        OUT VARCHAR2
                           , p_batch_source_id       IN NUMBER
                           , p_customer_trx_id       IN NUMBER) IS

v_request_id        NUMBER;
v_status            VARCHAR2 (1);
v_conc_phase        VARCHAR2 (50);
v_conc_status       VARCHAR2 (50);
v_conc_dev_phase    VARCHAR2 (50);
v_conc_dev_status   VARCHAR2 (50);
v_error_message     VARCHAR2 (2000);
v_conc_message      VARCHAR2 (2000);
v_message           VARCHAR2 (2000);

v_cae_error VARCHAR2(2000);

e_cust_exception EXCEPTION;
v_cae VARCHAR2(50);
v_cae_date DATE;


CURSOR c_msg IS
select fe_error_code,fe_error_msg
              from XXW_FE_ERRORES_AFIP_CAE
             where id = p_customer_trx_id;


BEGIN

    fnd_file.put_line(fnd_file.log, 'XX_AR_TAX_RETURN_NC_PKG.CALL_CAE_PROCESS (+)');


    v_request_id := fnd_request.submit_request(
                                                'XBOL'
                                               ,'XXARFECI'
                                               , ''
                                               , ''
                                               , FALSE
                                               , p_batch_source_id
                                               , p_customer_trx_id
                                               , 'N'
                                               , TO_CHAR(TRUNC(SYSDATE),'YYYY/MM/DD HH24:MI:SS'));
    IF v_request_id = 0 THEN
        p_error_message := fnd_message.get;
        fnd_file.put_line(fnd_file.log, 'Error ejecutando el concurrente XX AR Obtener Cae FEAR, Error: ' ||p_error_message || ', ' || sqlerrm);
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
        p_error_message := fnd_message.get;
        fnd_file.put_line(fnd_file.log,  'Error ejecutando FND_REQUEST.WAIT_FOR_REQUEST. ' ||p_error_message || ' ' || SQLERRM);
        RAISE e_cust_exception;
    END IF;


    BEGIN

        SELECT cae,fecha_vto_cae,fex_error_msg
          INTO v_cae,v_cae_date,v_cae_error
          FROM xxw_fac_tmp
         WHERE id =p_customer_trx_id;
    EXCEPTION
      WHEN OTHERS THEN
       v_cae := NULL;
    END;

    IF v_cae is null and v_cae_error is not null then


        p_error_message := 'ERROR AL OBTENER CAE: '||v_cae_error;

        fnd_file.put_line(fnd_file.output,'');
        fnd_file.put_line(fnd_file.output,p_error_message);

        RAISE e_cust_exception;

    ELSIF v_cae is null and v_cae_error is null then

        p_error_message := 'Error ejecutando el concurrente XX AR Obtener Cae FEAR, Error: ' || sqlerrm;
        RAISE e_cust_exception;

    ELSE

        fnd_file.put_line(fnd_file.output,'');
        fnd_file.put_line(fnd_file.output,'CAE:             '||v_cae);
        fnd_file.put_line(fnd_file.output,'FECHA VENC CAE:  '||to_char(v_cae_date,'DD/MM/YYYY HH24:MI:SS'));

    END IF;

    IF p_status IS NULL THEN
     p_status := 'S';
    END IF;

    fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.CALL_CAE_PROCESS (-)');

EXCEPTION
  WHEN e_cust_exception THEN
     p_status := 'W';
     fnd_file.put_line(fnd_file.log,p_error_message);
     fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.CALL_CAE_PROCESS (!)');
  WHEN OTHERS THEN
     p_status := 'W';
     p_error_message := 'Error OTHERS en CALL_CAE_PROCESS. Error: '||SQLERRM;
     fnd_file.put_line(fnd_file.log,p_error_message);
     fnd_file.put_line(fnd_file.output,'ERROR:           '||p_error_message);
     fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.CALL_CAE_PROCESS (!)');
END;

PROCEDURE GEN_TRX          ( p_status               OUT VARCHAR2
                           , p_error_message        OUT VARCHAR2
                           , p_customer_trx_id       IN NUMBER
                           , p_batch_source_id_cm    IN NUMBER
                           , p_cust_trx_type_id_cm   IN NUMBER
                           , p_order_number          IN VARCHAR2 DEFAULT NULL
                           , p_total_parcial         IN VARCHAR2
                           , p_comments              IN VARCHAR2
                           , p_customer_trx_id_cm   OUT NUMBER
                           , p_trx_number_cm        OUT VARCHAR2
                           , p_amount_cm            OUT NUMBER)  IS


   cursor list_errors is
   SELECT trx_header_id, trx_line_id, trx_salescredit_id, trx_dist_id,
          trx_contingency_id, error_message, invalid_value
   FROM   ar_trx_errors_gt;

   cursor list_headers is
   SELECT trx_header_id,
          customer_trx_id
   FROM   ar_trx_header_gt;

e_cust_exception EXCEPTION;
e_lines_exception EXCEPTION;

/*NC Normales*/
l_batch_source_rec     ar_invoice_api_pub.batch_source_rec_type;
l_trx_header_tbl       ar_invoice_api_pub.trx_header_tbl_type;
l_trx_lines_tbl        ar_invoice_api_pub.trx_line_tbl_type;
l_trx_dist_tbl         ar_invoice_api_pub.trx_dist_tbl_type;
l_trx_salescredits_tbl ar_invoice_api_pub.trx_salescredits_tbl_type;

v_line_number NUMBER;
v_dist_number NUMBER;
x_customer_trx_id     NUMBER;
x_trx_number          ra_customer_trx_all.trx_number%TYPE;
p_mesg_error          VARCHAR2(2000);
l_return_status        varchar2(1);
l_msg_count            number;
l_msg_data             varchar2(2000);
l_cnt                  number := 0;

CURSOR c_trx (p_customer_trx_id NUMBER) IS
select rcta.set_of_books_id
      ,rcta.trx_number
      ,rcta.sold_to_customer_id
      ,rcta.bill_to_customer_id
      ,rcta.bill_to_site_use_id
      ,rcta.ship_to_customer_id
      ,rcta.ship_to_site_use_id
      ,hcsub.cust_acct_site_id bill_to_address_id
      ,hcsus.cust_acct_site_id ship_to_address_id
      ,hca.account_number
      ,hp.party_name
      ,rcta.invoice_currency_code
      ,rcta.org_id
      ,nvl(rcta.exchange_rate_type,'User') exchange_rate_type
      ,trunc(nvl(rcta.exchange_date,sysdate)) exchange_date
      ,decode(nvl(rcta.exchange_rate_type,'User'),'Corporate',null,nvl(rcta.exchange_rate,'1')) exchange_rate
      ,rcta.customer_trx_id
      ,rcta.receipt_method_id
      ,rcta.paying_customer_id
      ,rcta.paying_site_use_id
      ,rcta.trx_date
      ,rbs.name batch_source_name
      ,rcta.comments
      ,rcta.primary_salesrep_id
      ,rctt.type rctt_type
  from ra_customer_trx rcta
      ,ra_batch_sources rbs
      ,hz_cust_site_uses hcsub
      ,hz_cust_site_uses hcsus
      ,hz_cust_accounts hca
      ,hz_parties hp
      ,ra_cust_trx_types rctt
 where rcta.batch_source_id = rbs.batch_source_id
   and rcta.customer_trx_id = p_customer_trx_id
   and rcta.cust_trx_type_id = rctt.cust_trx_type_id
   and rcta.bill_to_site_use_id = hcsub.site_use_id
   and rcta.ship_to_site_use_id = hcsus.site_use_id
   and rcta.bill_to_customer_id = hca.cust_account_id
   and hca.party_id        = hp.party_id;

   CURSOR c_lines( p_customer_trx_id   NUMBER)
   IS
       select rctla_fc.customer_trx_id
             ,rctla_fc.customer_trx_line_id orig_customer_trx_line_id
             ,NVL( rila.cm_int_line_id,rctla_fc.customer_trx_line_id) customer_trx_line_id
             ,null link_to_cust_trx_line_id
             ,rila.line_number
             ,rila.line_type
             ,rila.quantity*-1 quantity_invoiced
             ,rila.unit_selling_price
             ,rila.amount*-1 extended_amount
             ,rila.description
             ,rila.memo_line_id
             ,rila.inventory_item_id
             ,rila.vat_tax_id
             ,rila.org_id
             ,rctla_fc.ship_to_customer_id
             ,rctla_fc.ship_to_site_use_id
             ,rila.line_gdf_attr_category global_attribute_category
             ,rila.line_gdf_attribute1 global_attribute1
             ,rila.line_gdf_attribute2 global_attribute2
             ,rila.line_gdf_attribute3 global_attribute3
             ,rila.line_gdf_attribute4 global_attribute4
             ,rila.line_gdf_attribute5 global_attribute5
             ,rila.line_gdf_attribute6 global_attribute6
             ,rila.line_gdf_attribute7 global_attribute7
             ,rila.line_gdf_attribute8 global_attribute8
             ,rila.line_gdf_attribute9 global_attribute9
             ,rila.line_gdf_attribute10 global_attribute10
             ,rila.line_gdf_attribute11 global_attribute11
             ,rila.line_gdf_attribute12 global_attribute12
             ,rila.line_gdf_attribute13 global_attribute13
             ,rila.line_gdf_attribute14 global_attribute14
             ,rila.line_gdf_attribute15 global_attribute15
             ,rila.sales_order
             ,rila.sales_order_line
             ,rila.sales_order_date
             ,rila.sales_order_source
             ,rila.attribute_category
             ,rila.attribute1
             ,rila.attribute2
             ,rila.attribute3
             ,rila.attribute4
             ,rila.attribute5
             ,rila.attribute6
             ,rila.attribute7
             ,rila.attribute8
             ,rila.attribute9
             ,rila.attribute10
             ,rila.attribute11
             ,rila.attribute12
             ,rila.attribute13
             ,rila.attribute14
             ,rila.attribute15
             ,rila.warehouse_id
             ,rila.interface_line_context
             ,rila.interface_line_attribute1
             ,rila.interface_line_attribute2
             ,rila.interface_line_attribute3
             ,rila.interface_line_attribute4
             ,rila.interface_line_attribute5
             ,rila.interface_line_attribute6
             ,rila.interface_line_attribute7
             ,rila.interface_line_attribute8
             ,rila.interface_line_attribute9
             ,rila.interface_line_attribute10
             ,rila.interface_line_attribute11
             ,rila.interface_line_attribute12
             ,rila.interface_line_attribute13
             ,rila.interface_line_attribute14
             ,rila.interface_line_attribute15
             ,rila.uom_code
         from xx_ar_cm_int_lines_all rila
             ,ra_customer_trx_lines_all rctla_fc
        where rila.reference_line_id = rctla_fc.customer_trx_line_id
          and rctla_fc.interface_line_context = 'ORDER ENTRY'
          and rila.interface_line_attribute1 = p_order_number
          and rctla_fc.customer_trx_id = p_customer_trx_id
          --and p_total_parcial = 'P'
          AND p_order_number IS NOT NULL
          UNION ALL ---Los impuestos calculados a las lineas que devuelve el PVD
           SELECT rctla_fc.customer_trx_id
             ,rctla_tax.customer_trx_line_id --- orig_customer_trx_line_id
             ,rownum customer_trx_line_id
             ,NVL( rila.cm_int_line_id,rctla_tax.link_to_cust_trx_line_id) link_to_cust_trx_line_id
             ,rctla_tax.line_number
             ,rctla_tax.line_type
             ,rctla_tax.quantity_invoiced*-1
             ,rctla_tax.unit_selling_price
             ,CASE
                WHEN rctla_tax.extended_amount = 0 THEN 0
              ELSE
                ROUND((rila.amount*(select percentage_rate from zx_rates_b avt where avt.tax_rate_id = rctla_tax.vat_tax_id))/100,2)*-1
              END extended_amount
             ,rctla_tax.description
             ,rctla_tax.memo_line_id
             ,rctla_tax.inventory_item_id
             ,rctla_tax.vat_tax_id
             ,rctla_tax.org_id
             ,rctla_tax.ship_to_customer_id
             ,rctla_tax.ship_to_site_use_id
             ,rctla_tax.global_attribute_category
             ,rctla_tax.global_attribute1
             ,rctla_tax.global_attribute2
             ,rctla_tax.global_attribute3
             ,rctla_tax.global_attribute4
             ,rctla_tax.global_attribute5
             ,rctla_tax.global_attribute6
             ,rctla_tax.global_attribute7
             ,rctla_tax.global_attribute8
             ,rctla_tax.global_attribute9
             ,rctla_tax.global_attribute10
             ,rctla_tax.global_attribute11
             ,rctla_tax.global_attribute12
             ,rctla_tax.global_attribute13
             ,rctla_tax.global_attribute14
             ,rctla_tax.global_attribute15
             ,null sales_order
             ,null sales_order_line
             ,null sales_order_date
             ,null sales_order_source
             ,rctla_tax.attribute_category
             ,rctla_tax.attribute1
             ,rctla_tax.attribute2
             ,rctla_tax.attribute3
             ,rctla_tax.attribute4
             ,rctla_tax.attribute5
             ,rctla_tax.attribute6
             ,rctla_tax.attribute7
             ,rctla_tax.attribute8
             ,rctla_tax.attribute9
             ,rctla_tax.attribute10
             ,rctla_tax.attribute11
             ,rctla_tax.attribute12
             ,rctla_tax.attribute13
             ,rctla_tax.attribute14
             ,rctla_tax.attribute15
             ,rctla_tax.warehouse_id
             ,null interface_line_context
              ,null interface_line_attribute1
              ,null interface_line_attribute2
              ,null interface_line_attribute3
              ,null interface_line_attribute4
              ,null interface_line_attribute5
              ,null interface_line_attribute6
              ,null interface_line_attribute7
              ,null interface_line_attribute8
              ,null interface_line_attribute9
              ,null interface_line_attribute10
              ,null interface_line_attribute11
              ,null interface_line_attribute12
              ,null interface_line_attribute13
              ,null interface_line_attribute14
              ,null interface_line_attribute15
              ,rila.uom_code
         from xx_ar_cm_int_lines_all rila
             ,ra_customer_trx_lines_all rctla_fc
             ,ra_customer_trx_lines_all rctla_tax
        where rila.reference_line_id = rctla_fc.customer_trX_line_id
          and rctla_fc.interface_line_context = 'ORDER ENTRY'
          and rila.interface_line_attribute1 = p_order_number
          and rctla_fc.customer_trx_id = p_customer_trx_id
          and rctla_fc.customer_trx_line_id = rctla_tax.link_to_cust_trx_line_id
          and rctla_fc.line_type = 'LINE'
          and rctla_tax.line_type = 'TAX'
          --and p_total_parcial = 'P'
          and p_order_number is not null
          UNION ALL
          SELECT rctl.customer_trx_id
              ,rctl.customer_trx_line_id --orig_customer_trx_line_id
              ,rctl.customer_trx_line_id
              ,rctl.link_to_cust_trx_line_id
              ,rctl.line_number
              ,rctl.line_type
              ,rctl.quantity_invoiced
              ,rctl.unit_selling_price
              ,rctl.extended_amount
              ,rctl.description
              ,rctl.memo_line_id
              ,rctl.inventory_item_id
              ,rctl.vat_tax_id
              ,rctl.org_id
              ,rctl.ship_to_customer_id
              ,rctl.ship_to_site_use_id
              ,rctl.global_attribute_category
              ,rctl.global_attribute1
              ,rctl.global_attribute2
              ,rctl.global_attribute3
              ,rctl.global_attribute4
              ,rctl.global_attribute5
              ,rctl.global_attribute6
              ,rctl.global_attribute7
              ,rctl.global_attribute8
              ,rctl.global_attribute9
              ,rctl.global_attribute10
              ,rctl.global_attribute11
              ,rctl.global_attribute12
              ,rctl.global_attribute13
              ,rctl.global_attribute14
              ,rctl.global_attribute15
              ,rctl.sales_order
              ,rctl.sales_order_line
              ,rctl.sales_order_date
              ,rctl.sales_order_source
              ,rctl.attribute_category
              ,rctl.attribute1
              ,rctl.attribute2
              ,rctl.attribute3
              ,rctl.attribute4
              ,rctl.attribute5
              ,rctl.attribute6
              ,rctl.attribute7
              ,rctl.attribute8
              ,rctl.attribute9
              ,rctl.attribute10
              ,rctl.attribute11
              ,rctl.attribute12
              ,rctl.attribute13
              ,rctl.attribute14
              ,rctl.attribute15
              ,rctl.warehouse_id
              /*Modificado KHRONUS/E.Sly 20200204 En caso de ser devolucion de un pedido de venta pero manual, debe respetar los valores por bonificaciones*/
              /*,DECODE(rctl.line_type,'LINE','XX_AR_DEVOLUCION_NC',null) interface_line_context
              ,DECODE(rctl.line_type,'LINE',rct.trx_number,null) interface_line_attribute1
              ,DECODE(rctl.line_type,'LINE',TO_CHAR(rctl.customer_trx_id),null) interface_line_attribute2
              ,DECODE(rctl.line_type,'LINE',TO_CHAR(rctl.customer_trx_line_id),null) interface_line_attribute3
              ,DECODE(rctl.line_type,'LINE',to_char(sysdate, 'DDMMRR')||TO_CHAR(fnd_global.conc_request_id),null) interface_line_attribute4
              ,DECODE(rctl.line_type,'LINE','-1',null) interface_line_attribute5
              ,null interface_line_attribute6
              ,null interface_line_attribute7
              ,null interface_line_attribute8
              ,null interface_line_attribute9
              ,null interface_line_attribute10
              ,null interface_line_attribute11
              ,null interface_line_attribute12
              ,null interface_line_attribute13
              ,null interface_line_attribute14
              ,null interface_line_attribute15*/
              ,DECODE(rctl.line_type,'LINE',DECODE(rctl.interface_line_context,'ORDER ENTRY',rctl.interface_line_context,'XX_AR_FC_PERCEP',rctl.interface_line_context,'XX_AR_DEVOLUCION_NC'),null) interface_line_attribute1
              ,DECODE(rctl.line_type,'LINE',DECODE(rctl.interface_line_context,'ORDER ENTRY',rctl.interface_line_attribute1,rct.trx_number),null) interface_line_attribute1
              ,DECODE(rctl.line_type,'LINE',DECODE(rctl.interface_line_context,'ORDER ENTRY',rctl.interface_line_attribute2,TO_CHAR(rctl.customer_trx_id)),null) interface_line_attribute2
              ,DECODE(rctl.line_type,'LINE',DECODE(rctl.interface_line_context,'ORDER ENTRY',rctl.interface_line_attribute3,TO_CHAR(rctl.customer_trx_line_id)),null) interface_line_attribute3
              ,DECODE(rctl.line_type,'LINE',DECODE(rctl.interface_line_context,'ORDER ENTRY',rctl.interface_line_attribute4,'XX_AR_FC_PERCEP',fnd_global.conc_request_id,to_char(sysdate, 'DDMMRR')||TO_CHAR(fnd_global.conc_request_id)),null) interface_line_attribute4
              ,DECODE(rctl.line_type,'LINE',DECODE(rctl.interface_line_context,'ORDER ENTRY','-'||rctl.interface_line_attribute5,'XX_AR_FC_PERCEP',rctl.org_id,'-1'),null) interface_line_attribute5
              ,DECODE(rctl.line_type,'LINE',DECODE(rctl.interface_line_context,'ORDER ENTRY',rctl.interface_line_attribute6,null),null) interface_line_attribute6
              ,DECODE(rctl.line_type,'LINE',DECODE(rctl.interface_line_context,'ORDER ENTRY',rctl.interface_line_attribute7,null),null) interface_line_attribute7
              ,DECODE(rctl.line_type,'LINE',DECODE(rctl.interface_line_context,'ORDER ENTRY',rctl.interface_line_attribute8,null),null) interface_line_attribute8
              ,DECODE(rctl.line_type,'LINE',DECODE(rctl.interface_line_context,'ORDER ENTRY',rctl.interface_line_attribute9,null),null) interface_line_attribute9
              ,DECODE(rctl.line_type,'LINE',DECODE(rctl.interface_line_context,'ORDER ENTRY',rctl.interface_line_attribute10,null),null) interface_line_attribute10
              ,DECODE(rctl.line_type,'LINE',DECODE(rctl.interface_line_context,'ORDER ENTRY',rctl.interface_line_attribute11,null),null) interface_line_attribute11
              ,DECODE(rctl.line_type,'LINE',DECODE(rctl.interface_line_context,'ORDER ENTRY',rctl.interface_line_attribute12,null),null) interface_line_attribute12
              ,DECODE(rctl.line_type,'LINE',DECODE(rctl.interface_line_context,'ORDER ENTRY',rctl.interface_line_attribute13,null),null) interface_line_attribute13
              ,DECODE(rctl.line_type,'LINE',DECODE(rctl.interface_line_context,'ORDER ENTRY',rctl.interface_line_attribute14,null),null) interface_line_attribute14
              ,DECODE(rctl.line_type,'LINE',DECODE(rctl.interface_line_context,'ORDER ENTRY',rctl.interface_line_attribute15,null),null) interface_line_attribute15
              /*Fin Modificado KHRONUS/E.Sly 20200204 En caso de ser devolucion de un pedido de venta pero manual, debe respetar los valores por bonificaciones*/
              ,rctl.uom_code
          FROM ra_customer_trx_lines_all rctl
          ,ra_customer_trx_all rct
         WHERE rctl.customer_trx_id = p_customer_trx_id
         and rct.customer_trx_id = rctl.customer_trx_id
           AND p_ordeR_number is null
          ;

   CURSOR c_dist(p_customer_trx_id      NUMBER
                ,p_customer_trx_line_id NUMBER)
   IS
   SELECT *
      FROM ra_cust_trx_line_gl_dist_all
     WHERE customer_trx_id=p_customer_trx_id
       AND  ((p_customer_trx_line_id IS NOT NULL
          AND customer_trx_line_id = p_customer_trx_line_id)
          OR (p_customer_trx_line_id IS NULL
          AND customer_trx_line_id IS NULL));

   v_interface_line_attribute3  ra_customer_trx_lines_all.interface_line_attribute3%TYPE;
   v_start_date  DATE;
   v_cust_trx_type_id           NUMBER;
   v_qty NUMBER;
   v_void_level varchar2(10);
   v_void_term varchar2(10);

   /*Agregado KHRONUS/E.Sly 20190802 Se agrega cambio de Fecha por periodo cerrado*/
   v_period_open NUMBER;
   v_trx_date DATE;
   /*Fin Agregado KHRONUS/E.Sly 20190802 Se agrega cambio de Fecha por periodo cerrado*/

   v_status VARCHAR2(10);
   v_error_message VARCHAR2(2000);

   v_amount NUMBER;

   v_batch_source_name_cm ra_batch_sources_all.name%type;
   v_batch_source_name_int ra_batch_sources_all.name%type;

   v_exc_base_rate JL_ZZ_AR_TX_EXC_CUS_all.base_rate%type;
   v_exc_amount NUMBER;

   e_api_exception   EXCEPTION;

BEGIN

    fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.GEN_TRX (+)');

    fnd_file.put_line(fnd_file.log,'P_CUSTOMER_TRX_ID: '||p_customer_trx_id);
    fnd_file.put_line(fnd_file.log,'P_BATCH_SOURCE_ID_CM: '||p_batch_source_id_cm);
    fnd_file.put_line(fnd_file.log,'P_CUST_TRX_TYPE_ID_CM: '||p_cust_trx_type_id_cm);
    fnd_file.put_line(fnd_file.log,'P_ORDER_NUMBER: '||p_order_number);
    fnd_file.put_line(fnd_file.log,'P_TOTAL_PARCIAL: '||p_total_parcial);
    fnd_file.put_line(fnd_file.log,'P_COMMENTS: '||p_comments);


    fnd_file.put_line(fnd_file.log,'Genero Interface_line_attribute3');

      SELECT to_char(sysdate, 'DDMMRR')||fnd_global.conc_request_id
        INTO v_interface_line_attribute3
        FROM dual;

    fnd_file.put_line(fnd_file.log,'Inicializo tablas de la API');

      BEGIN

        l_trx_header_tbl.DELETE;
        l_trx_lines_tbl.DELETE;
        l_trx_dist_tbl.DELETE;

      EXCEPTION
        WHEN OTHERS THEN
          p_error_message := 'Error en DELETE';
          raise e_cust_exception;
      END;

      fnd_file.put_line(fnd_file.log,'Recorro los comprobantes');

      v_dist_number := 0;
      x_trx_number := null;

      FOR r_fc IN c_trx (p_customer_Trx_id) LOOP

           v_amount := 0;

           fnd_file.put_line(fnd_file.log,'Transaccion Nro: '||r_fc.trx_number);

           fnd_file.put_line(fnd_file.output,'ORIGEN FC/ND:    '||r_fc.batch_source_name);
           fnd_file.put_line(fnd_file.output,'TRANSACCION NRO: '||r_fc.trx_number);
           fnd_file.put_line(fnd_file.output,'');

           BEGIN

            SELECT cust_trx_type_id
              INTO v_cust_trx_type_id
              FROM ra_cust_trx_types rctt
             WHERE rctt.cust_trx_type_id = p_cust_trx_type_id_cm
               AND NVL(start_date,trunc(sysdate)) <= trunc(sysdate)
               and NVL(end_date,trunc(sysdate)) >= trunc(sysdate);

           EXCEPTION
             WHEN NO_DATA_FOUND THEN
               p_error_message := 'El tipo de transaccion asociado no es valido. Error: '||SQLERRM;
               raise e_cust_exception;
             WHEN OTHERS THEN
               p_error_message := 'Error al validar el tipo de transaccion para la NC. Error: '||SQLERRM;
               raise e_cust_exception;
           END;

           BEGIN

            SELECT name
              INTO v_batch_source_name_cm
              FROM ra_batch_sources rbs
             WHERE rbs.batch_source_id = p_batch_source_id_cm
               AND NVL(rbs.start_date,trunc(sysdate)) <= trunc(sysdate)
            and NVL(rbs.end_date,trunc(sysdate)) >= trunc(sysdate);

           EXCEPTION
             WHEN NO_DATA_FOUND THEN
               p_error_message := 'El Origen de Nota de Credito no es valido. Error: '||SQLERRM;
               raise e_cust_exception;
             WHEN OTHERS THEN
               p_error_message := 'Error al validar el Origen de Nota de Credito. Error: '||SQLERRM;
               raise e_cust_exception;
           END;

           /*IF p_total_parcial = 'T' THEN

               BEGIN

                SELECT COUNT(1)
                  INTO v_qty
                  FROM ar_receivable_applications_all
                  WHERE (customer_trx_id = p_customer_trx_id
                  OR applied_customer_trx_id = p_customer_trx_id)
                  AND display = 'Y' --El ultimo movimiento
                  AND status = 'APP'; --est aplicado

               EXCEPTION
                  WHEN OTHERS THEN
                      v_qty := 0;
               END;

               IF v_qty > 0 THEN
                    p_error_message := 'La Transaccion ya esta aplicada.';
                    RAISE e_cust_exception;
               END IF;

           END IF;*/

           BEGIN

            l_trx_header_tbl(1).trx_header_id             := r_fc.customer_trx_id;
            l_trx_header_tbl(1).bill_to_customer_id       := r_fc.bill_to_customer_id;
            l_trx_header_tbl(1).bill_to_site_use_id       := r_fc.bill_to_site_use_id;
            l_trx_header_tbl(1).ship_to_customer_id       := r_fc.ship_to_customer_id;
            l_trx_header_tbl(1).ship_to_site_use_id       := r_fc.ship_to_site_use_id;
            l_trx_header_tbl(1).bill_to_address_id        := r_fc.bill_to_address_id;
            l_trx_header_tbl(1).ship_to_address_id        := r_fc.ship_to_address_id;

            l_trx_header_tbl(1).trx_currency              := r_fc.invoice_currency_code;

            IF l_trx_header_tbl(1).trx_currency != 'ARS' THEN

                l_trx_header_tbl(1).exchange_date             := r_fc.exchange_date;
                l_trx_header_tbl(1).exchange_rate_type        := r_fc.exchange_rate_type;
                l_trx_header_tbl(1).exchange_rate             := r_fc.exchange_rate;

            END IF;

            l_trx_header_tbl(1).receipt_method_id         := r_fc.receipt_method_id;
            IF LENGTH(p_comments||r_fc.comments) > 1760 THEN
             l_trx_header_tbl(1).comments                  := SUBSTR(p_comments,1,LENGTH(r_fc.comments)-(LENGTH(p_comments||r_fc.comments) - 1761))||'-'||r_fc.comments;
            ELSE
             l_trx_header_tbl(1).comments                  := p_comments||r_fc.comments;
            END IF;
            l_trx_header_tbl(1).paying_customer_id        := r_fc.paying_customer_id;
            l_trx_header_tbl(1).paying_site_use_id        := r_fc.paying_site_use_id;

            /*Modificado KHRONUS/E.Sly 20190802 Se agrega cambio de Fecha por periodo cerrado*/
            --l_trx_header_tbl(1).trx_date                    :=  TRUNC(SYSDATE);
            --l_trx_header_tbl(1).gl_date                     :=  TRUNC(SYSDATE);

            /*Si el periodo esta cerrado, tomo el ultimo dia del ultimo periodo abierto*/
            BEGIN

                select 1
                  into v_period_open
                  from gl_period_statuses
                 where start_date <= TRUNC(SYSDATE)
                   and end_date >= TRUNC(SYSDATE)
                   and set_of_books_id = r_fc.set_of_books_id
                   and closing_status = 'O'
                   and application_id = 222; --AR

            EXCEPTION
             WHEN NO_DATA_FOUND THEN
              v_period_open := 0;
            END;

            IF v_period_open = 0 THEN

                BEGIN

                    SELECT end_date
                      INTO v_trx_date
                      FROM gl_period_statuses gps
                     WHERE gps.set_of_books_id = r_fc.set_of_books_id
                       AND gps.closing_status = 'O'
                       AND gps.application_id = 222 --AR
                       AND gps.end_date = (SELECT MAX(gps2.end_date)
                                             FROM gl_period_statuses gps2
                                            WHERE gps2.set_of_books_id = gps.set_of_books_id
                                              AND gps2.application_id = gps.application_id
                                              AND gps2.closing_status = 'O'
                                              AND end_date < TRUNC(SYSDATE));
                EXCEPTION
                 WHEN OTHERS THEN
                   p_error_message := 'Error al obtener fecha contable de un periodo abierto. Error: '||SQLERRM;
                   RAISE e_cust_exception;
                END;

            ELSE

                v_trx_date := TRUNC(SYSDATE);

            END IF;

            l_trx_header_tbl(1).trx_date := v_trx_date;
            l_trx_header_tbl(1).gl_date  := v_trx_date;

            fnd_file.put_line(fnd_file.log,'Fecha Transaccion: '||TO_CHAR(l_trx_header_tbl(1).trx_date,'DD/MM/YYYY'));
            fnd_file.put_line(fnd_file.log,'Fecha Contable: '||TO_CHAR(l_trx_header_tbl(1).gl_date,'DD/MM/YYYY'));
            /*Modificado KHRONUS/E.Sly 20190802 Se agrega cambio de Fecha por periodo cerrado*/

            l_trx_header_tbl(1).org_id                      :=  r_fc.org_id;
            l_trx_header_tbl(1).status_trx                  := 'OP';
            l_trx_header_tbl(1).default_tax_exempt_flag     :=  NULL;
            l_trx_header_tbl(1).printing_option             := 'PRI';
            l_trx_header_tbl(1).global_attribute_category   := 'JL.AR.ARXTWMAI.TGW_HEADER';
            /*l_trx_header_tbl(1).interface_header_context    := 'XX_AR_DEVOLUCION_NC';
            l_trx_header_tbl(1).interface_header_attribute1 := r_fc.trx_number;
            l_trx_header_tbl(1).interface_header_attribute2 := r_fc.customer_trx_id;*/
            l_trx_header_tbl(1).primary_salesrep_id         := r_fc.primary_salesrep_id;

            l_trx_header_tbl(1).cust_trx_type_id            := v_cust_trx_type_id;
            l_batch_source_rec.batch_source_id              := p_batch_source_id_cm;

           EXCEPTION
              WHEN OTHERS THEN
                 p_error_message := 'Error al completar campos de cabecera';
                 raise e_cust_exception;
           END;

           IF p_total_parcial = 'T' THEN --Parciales calcula a lo ultimo por la suma total

            FOR r_dist IN c_dist (r_fc.customer_trx_id,null) LOOP

                v_dist_number := v_dist_number + 1;
                l_trx_dist_tbl(v_dist_number).trx_dist_id                 := r_dist.cust_trx_line_gl_dist_id;
                l_trx_dist_tbl(v_dist_number).trx_line_id                 := r_dist.customer_trx_line_id;
                l_trx_dist_tbl(v_dist_number).trx_header_id               := r_fc.customer_trx_id;
                l_trx_dist_tbl(v_dist_number).account_class               := r_dist.account_class;
                l_trx_dist_tbl(v_dist_number).percent                     := r_dist.percent;
                l_trx_dist_tbl(v_dist_number).code_combination_id         := r_dist.code_combination_id;
                l_trx_dist_tbl(v_dist_number).amount                      := r_dist.amount*-1;

            END LOOP;

           END IF;

        v_line_number := 0;

        fnd_file.put_line(fnd_file.output,'Lineas');
        fnd_file.put_line(fnd_file.output,'------');
        fnd_file.put_line(fnd_file.output,'');
        fnd_file.put_line(fnd_file.output,'Tipo  Nro Linea  Descripcion              ');
        fnd_file.put_line(fnd_file.output,'----  ---------  -------------------------');
        fnd_file.put_line(fnd_file.output,'');

        FOR r_lines in c_lines (r_fc.customer_trx_id) LOOP


            BEGIN

            v_line_number := v_line_number + 1;

            l_trx_lines_tbl(v_line_number) := null;

            l_trx_lines_tbl(v_line_number).trx_header_id               := r_fc.customer_trx_id;
            l_trx_lines_tbl(v_line_number).line_number                 := v_line_number;
            l_trx_lines_tbl(v_line_number).trx_line_id                 := r_lines.customer_trx_line_id;
            l_trx_lines_tbl(v_line_number).line_type                   := r_lines.line_type;

            IF r_lines.line_type = 'LINE' THEN
              l_trx_lines_tbl(v_line_number).quantity_ordered         := r_lines.quantity_invoiced * -1;
              l_trx_lines_tbl(v_line_number).quantity_invoiced         := r_lines.quantity_invoiced * -1;
              l_trx_lines_tbl(v_line_number).unit_selling_price        := r_lines.unit_selling_price;
              l_trx_lines_tbl(v_line_number).amount                    := r_lines.extended_amount * -1;
              v_amount                                                 := v_amount +  l_trx_lines_tbl(v_line_number).amount;

              l_trx_lines_tbl(v_line_number).description               := r_lines.description;
              l_trx_lines_tbl(v_line_number).memo_line_id              := r_lines.memo_line_id;
              l_trx_lines_tbl(v_line_number).inventory_item_id         := r_lines.inventory_item_id;
              l_trx_lines_tbl(v_line_number).taxable_flag              := 'N';

              l_trx_lines_tbl(v_line_number).sales_order               := r_lines.sales_order;
              l_trx_lines_tbl(v_line_number).sales_order_line          := r_lines.sales_order_line;
              l_trx_lines_tbl(v_line_number).sales_order_date          := r_lines.sales_order_date;
              l_trx_lines_tbl(v_line_number).sales_order_source        := r_lines.sales_order_source;

              fnd_file.put_line(fnd_file.output,RPAD(r_lines.line_type,4,' ')||'  '||RPAD(r_lines.line_number,9,' ')||'  '||r_lines.description);

            ELSE

                /*Aplicar calculo segun lookup*/
                 BEGIN
                    SELECT tax_rate_code
                         , percentage_rate
                         , tax_regime_code
                         , tax
                         , tax_status_code
                         , tax_rate_code
                      INTO l_trx_lines_tbl(v_line_number).description
                         , l_trx_lines_tbl(v_line_number).tax_rate
                         , l_trx_lines_tbl(v_line_number).tax_regime_code
                         , l_trx_lines_tbl(v_line_number).tax
                         , l_trx_lines_tbl(v_line_number).tax_status_code
                         , l_trx_lines_tbl(v_line_number).tax_rate_code
                     FROM zx_rates_b
                    WHERE tax_rate_id = r_lines.vat_tax_id;
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       p_error_message:= 'Error: No se encontro datos de impuesto para: '||r_lines.vat_tax_id;
                       RAISE e_lines_exception;
                    WHEN OTHERS THEN
                       p_error_message:= 'Error general buscando datos de impuesto para: '||r_lines.vat_tax_id||' Error sql:'||sqlerrm;
                       RAISE e_lines_exception;
                 END;

                 IF p_total_parcial = 'T' THEN

                         BEGIN

                            SELECT xx_ar_void_level,xx_ar_void_term
                              INTO v_void_level,v_void_term
                              FROM fnd_lookup_values_vl flv
                                  ,fnd_lookup_values_dfv flv_dfv
                             WHERE flv.lookup_type = 'XX_AR_CM_TAX_JURISDICTION'
                               AND flv.rowid = flv_dfv.row_id
                               AND lookup_code = l_trx_lines_tbl(v_line_number).tax;

                         EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              p_error_message:= 'No se encontro jurisdiccion: '||l_trx_lines_tbl(v_line_number).tax||'en Lookup XX_AR_CM_TAX_JURISDICTION.';
                              RAISE e_lines_exception;
                           WHEN OTHERS THEN
                              p_error_message:= 'Error al obtener datos de Lookup XX_AR_CM_TAX_JURISDICTION para: '|| l_trx_lines_tbl(v_line_number).tax||' Error sql:'||sqlerrm;
                              RAISE e_lines_exception;
                         END;

                 ELSE


                    BEGIN

                            SELECT 'P',null
                              into v_void_level,v_void_term
                              FROM ar_vat_tax_all_b avt
                                  ,ar_vat_tax_all_b1_dfv avt_dfv
                                  ,jl_zz_ar_tx_categ_all categ
                             WHERE vat_tax_id = r_lines.vat_tax_id
                               and avt.rowid = avt_dfv.row_id
                               and avt_dfv.tax_category = categ.tax_category_id
                               and categ.org_id = avt.org_id
                               and categ.attribute7 is null; --si no es TOP% debe calcular siempre

                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                       v_void_level := 'N';
                      WHEN TOO_MANY_ROWS THEN
                       v_void_level := 'S';
                      WHEN OTHERS THEN
                       p_error_message:= 'Error al verificar si el impuesto: '||l_trx_lines_tbl(v_line_number).tax||' debe calcularse en NC Parcial. Error sql:'||sqlerrm;
                       RAISE e_lines_exception;
                    END;

                 END IF;

                 IF v_void_level = 'N' THEN
                      fnd_file.put_line(fnd_file.output,RPAD(r_lines.line_type,4,' ')||'  '||RPAD(r_lines.line_number,9,' ')||'  '||l_trx_lines_tbl(v_line_number).tax ||' -  No Aplica (Ver Lookup XX_AR_CM_TAX_JURISDICTION)');
                      l_trx_lines_tbl(v_line_number) := null;
                      v_line_number := v_line_number -1;
                      CONTINUE;
                 END IF;

                 IF p_total_parcial = 'T' THEN

                     IF NVL(v_void_term,'*') = '*' and v_void_level != 'N' THEN
                         p_error_message:= 'No se ha indicado un plazo en la lookup XX_AR_CM_TAX_JURISDICTION para: '|| l_trx_lines_tbl(v_line_number).tax;
                         RAISE e_lines_exception;
                     END IF;

                 END IF;

                 IF p_total_parcial = 'T' THEN

                     --IF NVL(v_void_term,'*') = 'E' AND '01/'||TO_CHAR(TRUNC(r_fc.trx_date),'MM/YYYY') < '01/'||TO_CHAR(TRUNC(SYSDATE),'MM/YYYY') then
                     IF NVL(v_void_term,'*') = 'E' AND '01/'||TO_CHAR(TRUNC(r_fc.trx_date),'MM/YYYY') < '01/'||TO_CHAR(v_trx_date,'MM/YYYY') then
                         fnd_file.put_line(fnd_file.output,RPAD(r_lines.line_type,4,' ')||'  '||RPAD(r_lines.line_number,9,' ')||'  '||l_trx_lines_tbl(v_line_number).tax ||' -  Mes no vigente (Ver Lookup XX_AR_CM_TAX_JURISDICTION) ');
                         l_trx_lines_tbl(v_line_number) := null;
                         v_line_number := v_line_number -1;
                         CONTINUE;
                     END IF;

                 END IF;

                 IF v_void_level IN ('T','P') THEN /*Por definicion todas van a ser Devoluciones Totales*/


                    IF p_order_number IS NOT NULL THEN

                    --Calculos las exenciones, si la devolucion es parcial, no tengo el monto y debo calcularlo
                    BEGIN

                        select base_rate
                          into v_exc_base_rate
                          from  jl_zz_ar_tx_exc_cus_all jzateca
                               ,ar_vat_tax_all_b avt
                               ,ar_vat_tax_all_b1_dfv avt_dfv
                          where jzateca.org_id = r_lines.org_id
                          and address_id IN (select cust_acct_site_id
                                               from hz_cust_site_uses_all hcsu
                                               ,ra_customer_trx_all rcta
                                               where site_use_id = rcta.ship_to_site_use_id
                                               and rcta.customer_trx_id = r_lines.customer_trx_id)
                          and NVL(start_date_active,trunC(sysdate)) <= v_trx_date
                          and NVL(end_date_active,trunC(sysdate)) >= v_trx_date
                          and tax_category_id =avt_dfv.tax_category
                          and vat_tax_id = r_lines.vat_tax_id
                          and avt.rowid = avt_dfv.row_id
                          and jzateca.org_id = avt.org_id;

                    EXCEPTION
                     WHEN OTHERS THEN
                      v_exc_base_rate := 0;
                    END;

                        v_exc_amount := ((100+(v_exc_base_rate))/100)*r_lines.extended_amount;

                        l_trx_lines_tbl(v_line_number).amount                    := v_exc_amount * -1;
                        fnd_file.put_line(fnd_file.log,'Monto Orig: '||r_lines.extended_amount);
                        fnd_file.put_line(fnd_file.log,'Monto Linea: '||l_trx_lines_tbl(v_line_number).amount);

                    ELSE

                        l_trx_lines_tbl(v_line_number).amount       := r_lines.extended_amount * -1;

                    END IF;


                    v_amount := v_amount +  l_trx_lines_tbl(v_line_number).amount;
                    l_trx_lines_tbl(v_line_number).description               :=  r_lines.description;
                    fnd_file.put_line(fnd_file.output,RPAD(r_lines.line_type,4,' ')||'  '||RPAD(r_lines.line_number,9,' ')||'  '||l_trx_lines_tbl(v_line_number).tax);
                 END IF;

                 ------DATOS ASOCIACION
                 l_trx_lines_tbl(v_line_number).link_to_trx_line_id := r_lines.link_to_cust_trx_line_id;

            END IF;

            IF r_lines.warehouse_id IS NULL THEN
              l_trx_lines_tbl(v_line_number).warehouse_id := obtener_warehouse_id(r_lines.org_id);
            ELSE
              l_trx_lines_tbl(v_line_number).warehouse_id := r_lines.warehouse_id;
            END IF;

            --l_trx_lines_tbl(v_line_number).amount_includes_tax_flag  := 'N';


            l_trx_lines_tbl(v_line_number).interface_line_context    := r_lines.interface_line_context;
            l_trx_lines_tbl(v_line_number).interface_line_attribute1 := r_lines.interface_line_attribute1;--r_fc.trx_number;
            l_trx_lines_tbl(v_line_number).interface_line_attribute2 := r_lines.interface_line_attribute2;--r_fc.customer_trx_id; --l_line_data.interface_line_attribute2;
            l_trx_lines_tbl(v_line_number).interface_line_attribute3 := r_lines.interface_line_attribute3;--r_lines.customer_trx_line_id; --l_line_data.interface_line_attribute3;
            l_trx_lines_tbl(v_line_number).interface_line_attribute4 := r_lines.interface_line_attribute4;--v_interface_line_attribute3;
            l_trx_lines_tbl(v_line_number).interface_line_attribute5 := r_lines.interface_line_attribute5;
            l_trx_lines_tbl(v_line_number).interface_line_attribute6 := r_lines.interface_line_attribute6;
            l_trx_lines_tbl(v_line_number).interface_line_attribute7 := r_lines.interface_line_attribute7;
            l_trx_lines_tbl(v_line_number).interface_line_attribute8 := r_lines.interface_line_attribute8;
            l_trx_lines_tbl(v_line_number).interface_line_attribute9 := r_lines.interface_line_attribute9;
            l_trx_lines_tbl(v_line_number).interface_line_attribute10 := r_lines.interface_line_attribute10;
            l_trx_lines_tbl(v_line_number).interface_line_attribute11 := r_lines.interface_line_attribute11;
            l_trx_lines_tbl(v_line_number).interface_line_attribute12 := r_lines.interface_line_attribute12;
            l_trx_lines_tbl(v_line_number).interface_line_attribute13 := r_lines.interface_line_attribute13;
            l_trx_lines_tbl(v_line_number).interface_line_attribute14 := r_lines.interface_line_attribute14;
            l_trx_lines_tbl(v_line_number).interface_line_attribute15 := r_lines.interface_line_attribute15;

            l_trx_lines_tbl(v_line_number).attribute_category := NVL(r_lines.attribute_category,'AR'); --guardo el customer_trx_line_id de la factura
            l_trx_lines_tbl(v_line_number).attribute1         := r_lines.attribute1;
            l_trx_lines_tbl(v_line_number).attribute2         := r_lines.attribute2;
            l_trx_lines_tbl(v_line_number).attribute3         := r_lines.attribute3;
            l_trx_lines_tbl(v_line_number).attribute4         := r_lines.attribute4;
            l_trx_lines_tbl(v_line_number).attribute5         := r_lines.attribute5;
            l_trx_lines_tbl(v_line_number).attribute6         := r_lines.attribute6;
            l_trx_lines_tbl(v_line_number).attribute7         := r_lines.orig_customer_trx_line_id; --guardo el customer_trx_line_id de la factura
            l_trx_lines_tbl(v_line_number).attribute8         := r_lines.attribute8;
            l_trx_lines_tbl(v_line_number).attribute9         := r_lines.attribute9;
            l_trx_lines_tbl(v_line_number).attribute10        := r_lines.attribute10;
            l_trx_lines_tbl(v_line_number).attribute11        := r_lines.attribute11;
            l_trx_lines_tbl(v_line_number).attribute12        := r_lines.attribute12;
            l_trx_lines_tbl(v_line_number).attribute13        := r_lines.attribute13;
            l_trx_lines_tbl(v_line_number).attribute14        := r_lines.attribute14;
            l_trx_lines_tbl(v_line_number).attribute15        := r_lines.attribute15;

            l_trx_lines_tbl(v_line_number).global_attribute_category    := r_lines.global_attribute_category;
            l_trx_lines_tbl(v_line_number).global_attribute1            := r_lines.global_attribute1;
            l_trx_lines_tbl(v_line_number).global_attribute2            := r_lines.global_attribute2;
            l_trx_lines_tbl(v_line_number).global_attribute3            := r_lines.global_attribute3;
            l_trx_lines_tbl(v_line_number).global_attribute4            := r_lines.global_attribute4;
            l_trx_lines_tbl(v_line_number).global_attribute5            := r_lines.global_attribute5;
            l_trx_lines_tbl(v_line_number).global_attribute6            := r_lines.global_attribute6;
            l_trx_lines_tbl(v_line_number).global_attribute7            := r_lines.global_attribute7;
            l_trx_lines_tbl(v_line_number).global_attribute8            := r_lines.global_attribute8;
            l_trx_lines_tbl(v_line_number).global_attribute9            := r_lines.global_attribute9;
            l_trx_lines_tbl(v_line_number).global_attribute10           := r_lines.global_attribute10;
            l_trx_lines_tbl(v_line_number).global_attribute11           := r_lines.global_attribute11;
            l_trx_lines_tbl(v_line_number).global_attribute12           := r_lines.global_attribute12;
            l_trx_lines_tbl(v_line_number).global_attribute13           := r_lines.global_attribute13;
            l_trx_lines_tbl(v_line_number).global_attribute14           := r_lines.global_attribute14;
            l_trx_lines_tbl(v_line_number).global_attribute15           := r_lines.global_attribute15;

            l_trx_lines_tbl(v_line_number).vat_tax_id                   := r_lines.vat_tax_id;
            l_trx_lines_tbl(v_line_number).tax_exempt_flag              := 'S';

            FOR r_dist IN c_dist (r_lines.customer_trx_id,r_lines.orig_customer_trx_line_id) LOOP

                v_dist_number := v_dist_number + 1;
                --l_trx_dist_tbl(v_dist_number).trx_dist_id                 := r_lines.customer_trx_line_id||r_dist.cust_trx_line_gl_dist_id;
                l_trx_dist_tbl(v_dist_number).trx_dist_id                 := v_dist_number;
                l_trx_dist_tbl(v_dist_number).trx_line_id                 := r_lines.customer_trx_line_id;
                l_trx_dist_tbl(v_dist_number).trx_header_id               := r_fc.customer_trx_id;
                l_trx_dist_tbl(v_dist_number).account_class               := r_dist.account_class;
                l_trx_dist_tbl(v_dist_number).percent                     := r_dist.percent;
                l_trx_dist_tbl(v_dist_number).code_combination_id         := r_dist.code_combination_id;
                l_trx_dist_tbl(v_dist_number).amount                      := l_trx_lines_tbl(v_line_number).amount;
                fnd_file.put_line(fnd_file.log,'Monto Dist: '||l_trx_dist_tbl(v_dist_number).amount);

            END LOOP;

          EXCEPTION
           WHEN e_lines_exception THEN
             raise e_cust_exception;
           WHEN OTHERS THEN
             p_error_message := 'Error al completar lineas. Nro de linea: '||v_line_number||'. Error: '||SQLERRM;
             raise e_cust_exception;
          END;

        END LOOP;

        IF p_total_parcial = 'P' THEN --Parciales calcula a lo ultimo por la suma total

            FOR r_dist IN c_dist (r_fc.customer_trx_id,null) LOOP

                v_dist_number := v_dist_number + 1;
                l_trx_dist_tbl(v_dist_number).trx_dist_id                 := r_dist.cust_trx_line_gl_dist_id;
                l_trx_dist_tbl(v_dist_number).trx_line_id                 := r_dist.customer_trx_line_id;
                l_trx_dist_tbl(v_dist_number).trx_header_id               := r_fc.customer_trx_id;
                l_trx_dist_tbl(v_dist_number).account_class               := r_dist.account_class;
                l_trx_dist_tbl(v_dist_number).percent                     := r_dist.percent;
                l_trx_dist_tbl(v_dist_number).code_combination_id         := r_dist.code_combination_id;
                l_trx_dist_tbl(v_dist_number).amount                      := v_amount;

            END LOOP;

        END IF;

           /*Calculo los interface_header_context*/

        FOR i IN  l_trx_lines_tbl.FIRST .. l_trx_lines_tbl.LAST LOOP
            IF l_trx_lines_tbl(i).interface_line_context IS NOT NULL THEN
                  l_trx_header_tbl(1).interface_header_context     := l_trx_lines_tbl(i).interface_line_context;
                  l_trx_header_tbl(1).interface_header_attribute1  := l_trx_lines_tbl(i).interface_line_attribute1;
                  l_trx_header_tbl(1).interface_header_attribute2  := l_trx_lines_tbl(i).interface_line_attribute2;
                  l_trx_header_tbl(1).interface_header_attribute3  := l_trx_lines_tbl(i).interface_line_attribute3;
                  l_trx_header_tbl(1).interface_header_attribute4  := l_trx_lines_tbl(i).interface_line_attribute4;
                  l_trx_header_tbl(1).interface_header_attribute5  := l_trx_lines_tbl(i).interface_line_attribute5;
                  l_trx_header_tbl(1).interface_header_attribute6  := l_trx_lines_tbl(i).interface_line_attribute6;
                  l_trx_header_tbl(1).interface_header_attribute7  := l_trx_lines_tbl(i).interface_line_attribute7;
                  l_trx_header_tbl(1).interface_header_attribute8  := l_trx_lines_tbl(i).interface_line_attribute8;
                  l_trx_header_tbl(1).interface_header_attribute9  := l_trx_lines_tbl(i).interface_line_attribute9;
                  l_trx_header_tbl(1).interface_header_attribute10 := l_trx_lines_tbl(i).interface_line_attribute10;
                  l_trx_header_tbl(1).interface_header_attribute11 := l_trx_lines_tbl(i).interface_line_attribute11;
                  l_trx_header_tbl(1).interface_header_attribute12 := l_trx_lines_tbl(i).interface_line_attribute12;
                  l_trx_header_tbl(1).interface_header_attribute13 := l_trx_lines_tbl(i).interface_line_attribute13;
                  l_trx_header_tbl(1).interface_header_attribute14 := l_trx_lines_tbl(i).interface_line_attribute14;
                  l_trx_header_tbl(1).interface_header_attribute15 := l_trx_lines_tbl(i).interface_line_attribute15;
                EXIT;
            END IF;
        END LOOP;

        BEGIN

        AR_INVOICE_API_PUB.create_single_invoice( p_api_version          => 1.0,
                                                  p_batch_source_rec     => l_batch_source_rec,
                                                  p_trx_header_tbl       => l_trx_header_tbl,
                                                  p_trx_lines_tbl        => l_trx_lines_tbl,
                                                  p_trx_dist_tbl         => l_trx_dist_tbl,
                                                  p_trx_salescredits_tbl => l_trx_salescredits_tbl,
                                                  x_customer_trx_id      => x_customer_trx_id,
                                                  x_return_status        => l_return_status,
                                                  x_msg_count            => l_msg_count,
                                                  x_msg_data             => l_msg_data);

        EXCEPTION
          WHEN OTHERS THEN
             p_error_message := 'Error al ejecutar API para Creacion de NC';
             raise e_cust_exception;
        END;

        BEGIN

           FND_FILE.PUT_LINE(FND_FILE.LOG,'Estado: '||l_return_status);
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Mensaje: '||l_msg_data);

            SELECT count(*)
              INTO   l_cnt
              FROM   ar_trx_header_gt;

          IF l_cnt != 0 THEN
             FOR i in list_headers LOOP
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'customer_trx_id: '||i.customer_trx_id);
             END LOOP;
          END IF;

          SELECT count(*)
          INTO   l_cnt
          FROM   ar_trx_errors_gt;

          FND_FILE.PUT_LINE(FND_FILE.LOG,'ar_trx_errors_gt (count): '||l_cnt);

          IF l_cnt != 0 THEN

             FOR i in list_errors LOOP
                 fnd_file.put_line(fnd_file.log,i.error_message);
                 p_mesg_error := p_mesg_error ||' - '||i.error_message;
             END LOOP;

             p_error_message := p_mesg_error;
             RAISE e_api_exception;

          ELSE

            BEGIN

                    SELECT trx_number
                    INTO x_trx_number
                    FROM ra_customer_trx_all
                    WHERE customer_trx_id = x_customer_trx_id;

            EXCEPTION
             WHEN OTHERS THEN
               x_trx_number := null;
            END;

          END IF;

          IF x_trx_number is null and l_return_status  = 'S' then
            p_error_message := 'Error al crear la Nota de Credito';
            RAISE e_api_exception;
          ELSIF x_trx_number is null and l_return_status  = 'U' then
            p_error_message := 'Error al crear la Nota de Credito';
            RAISE e_api_exception;
          ELSE
            fnd_file.put_line(fnd_file.log,'Nota de Credito: '||x_trx_number);
            /*Agregado KHRONUS/E.Sly 20200204 Relacion de NC a FC*/
            insert into xxw_cmp_asoc values (x_customer_trx_id,p_customer_trx_id,r_fc.trx_number,r_fc.rctt_type);
            /*Fin Agregado KHRONUS/E.Sly 20200204 Relacion de NC a FC*/
          END IF;

        EXCEPTION
          WHEN e_api_exception THEN
             raise e_cust_exception;
          WHEN OTHERS THEN
             p_error_message := 'Error al verificar resultado API';
             raise e_cust_exception;
        END;

        fnd_file.put_line(fnd_file.output,'');
        fnd_file.put_line(fnd_file.output,'ORIGEN NC:          '||v_batch_source_name_cm);
        fnd_file.put_line(fnd_file.output,'NRO TRX NC:         '||x_trx_number);

        COMMIT;

        IF x_trx_number is not null then
           p_customer_trx_id_cm := x_customer_trx_id;
           p_trx_number_cm      := x_trx_number;
           p_amount_cm          := v_amount;

           /*Agregado Khronus/E.Sly 20200318 Se actualiza el uom_code en NC*/
           update_uom_code (x_customer_trx_id);
           /*Agregado Khronus/E.Sly 20200318 Se actualiza el uom_code en NC*/
        ELSE
           p_error_message := 'Error en API. El comprobante no ha sido creado.';
           RAISE e_cust_exception;
        END IF;

      END LOOP;


    IF p_status is null THEN
     p_status := 'S';
    END IF;

    fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.GEN_TRX (-)');


EXCEPTION
  WHEN e_cust_exception THEN
    p_status := 'W';
    fnd_file.put_line(fnd_file.log,p_error_message);
    fnd_file.put_line(fnd_file.output,'ERROR:           '||p_error_message);
    fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.GEN_TRX (!)');
  WHEN OTHERS THEN
    p_status := 'W';
    p_error_message := 'Error OTHERS en GEN_TRX. Error: '||SQLERRM;
    fnd_file.put_line(fnd_file.log,p_error_message);
    fnd_file.put_line(fnd_file.output,'ERROR:           '||p_error_message);
    fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.GEN_TRX (!)');
END GEN_TRX;

PROCEDURE MAIN_PROCESS(errbuf                       OUT VARCHAR2
                      ,retcode                      OUT NUMBER
                      ,p_batch_source_id             IN NUMBER
                      ,p_customer_trx_id             IN NUMBER
                      ,p_batch_source_id_cm          IN NUMBER
                      ,p_order_number                IN VARCHAR2
                      ,p_total_parcial               IN VARCHAR2
                      ,p_comments                    IN VARCHAR2) IS

        v_trx_type                   ra_cust_trx_types_all.type%type;
        v_trx_type_rev               ra_cust_trx_types_all.type%type;
        v_cust_trx_type_id           ra_cust_trx_types_all.cust_trx_type_id%type;
        v_cust_trx_type_name         ra_cust_trx_types_all.name%type;
        --v_cust_trx_type_id_int       ra_cust_trx_types_all.cust_trx_type_id%type;
        --v_batch_source_id_int        ra_batch_sources_all.batch_source_id%type;
        --v_int_memo_line_id           ar_memo_lines_vl.memo_line_id%type;
        v_pto_venta_cm VARCHAR2(4);
        v_pto_venta_fc VARCHAR2(4);
        v_fc_letter    VARCHAR2(1);
        v_es_fce NUMBER;
        v_batch_source_id_cm         ra_batch_sources_all.batch_source_id%type;

        v_batch_source_letter        ra_batch_sources_all.global_attribute3%type;

        x_customer_trx_id_cm         NUMBER;
        x_trx_number_cm              RA_CUSTOMER_TRX_ALL.TRX_NUMBER%TYPE;
        x_amount_cm                  NUMBER;
        x_customer_trx_id_int        NUMBER;
        x_trx_number_int             RA_CUSTOMER_TRX_ALL.TRX_NUMBER%TYPE;
        x_amount_int                 NUMBER;

        v_status VARCHAR2(1);
        v_error_message VARCHAR2(2000);
        e_cust_exception EXCEPTION;

BEGIN

    fnd_file.put_line(fnd_file.log,'P_BATCH_SOURCE_ID:    '  ||p_batch_source_id);
    fnd_file.put_line(fnd_file.log,'P_CUSTOMER_TRX_ID:    '  ||p_customer_trx_id);
    fnd_file.put_line(fnd_file.log,'P_BATCH_SOURCE_ID_CM: '  ||p_batch_source_id_cm);
    fnd_file.put_line(fnd_file.log,'P_COMMENTS:           '  ||p_comments);
    fnd_file.put_line(fnd_file.log,'P_ORDER_NUMBER: '        ||p_order_number);
    fnd_file.put_line(fnd_file.log,'P_TOTAL_PARCIAL: '       ||p_total_parcial);
    fnd_file.put_line(fnd_file.log,'');


    fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.MAIN_PROCESS (+)');


    fnd_file.put_line(fnd_file.output,'XX AR Devolucion Impositiva para Facturas');
    fnd_file.put_line(fnd_file.output,'-----------------------------------------');
    fnd_file.put_line(fnd_file.output,'');

      BEGIN

        SELECT TYPE
          INTO v_trx_type
          FROM ra_customer_trx_all rct
              ,ra_cust_trx_types_all rctt
         WHERE rct.customer_trx_id =p_customer_trx_id
           AND rct.cust_trx_type_id=rctt.cust_trx_type_id;

      EXCEPTION
        WHEN OTHERS THEN
            v_trx_type := NULL;
      END;

      BEGIN

        select global_attribute3 --letter
              ,global_attribute2
          into v_batch_source_letter
              ,v_pto_venta_cm
          from ra_batch_sources
         where batch_source_id = p_batch_source_id_cm
           and batch_source_type = 'FOREIGN';
      EXCEPTION
        WHEN OTHERS THEN
           v_error_message := 'Error al obtener Letra y Punto de Venta de Nota de Credito. Error: '||SQLERRM;
           RAISE e_cust_exception;
      END;

      BEGIN

            select substr(trx_number,3,4),substr(trx_number,1,1)
              into v_pto_venta_fc,v_fc_letter
              from ra_customer_trx
             where customer_trx_id = p_customer_trx_id;

      EXCEPTION
       WHEN OTHERS THEN
         v_error_message := 'Error al obtenerl punto de venta y letra del origen FC. Error: '||SQLERRM;
         RAISE e_cust_exception;
      END;

      IF v_fc_letter != v_batch_source_letter THEN
         v_error_message := 'La Letra del origen de NC no coincide con el origen de FC';
         RAISE e_cust_exception;
      END IF;

      IF v_pto_venta_fc != v_pto_venta_cm THEN

            /*Verifico si el origen FC es FCE*/
            BEGIN

                select 1
                  into v_es_fce
                  from ra_batch_sources_all rbs
                      ,ra_batch_sources_all_dfv rbs_dfv
                 where rbs.rowid = rbs_dfv.row_id
                   and rbs_dfv.xx_ar_fce_source = p_batch_source_id --rbs_id de la fc
                   and rbs.global_attribute2 = v_pto_venta_cm;
            EXCEPTION
              WHEN OTHERS THEN
                v_es_fce := 0;
            END;

            IF v_es_fce = 0 THEN
               v_error_message := 'El Punto de Venta de la Factura no coincide con Punto de Venta del origen de Nota de Credito. Error: '||SQLERRM;
               RAISE e_cust_exception;
            ELSE

                BEGIN
                    SELECT rbs_dfv.xx_ar_fce_source
                      INTO v_batch_source_id_cm
                      FROM ra_batch_sources_all rbs
                          ,ra_batch_sources_all_dfv rbs_dfv
                    WHERE rbs.rowid = rbs_dfv.row_id
                      AND rbs.batch_source_id = p_batch_source_id_cm
                      AND rbs_dfv.xx_ar_fce_source is not null;
                EXCEPTION
                 WHEN OTHERS THEN
                    v_error_message := 'Error a obtener el origen NCE asociado a al batch_source_id: '||p_batch_source_id_cm||'. Error: '||SQLERRM;
                    RAISE e_cust_exception;
                END;

            END IF;

      ELSE
        v_batch_source_id_cm := p_batch_source_id_cm;
      END IF;


        BEGIN

          select rctt.cust_trx_type_id
                ,rctt.name
                ,rctt.type
            into v_cust_trx_type_id
                ,v_cust_trx_type_name
                ,v_trx_type_rev
            from ra_cust_trx_types rctt
                ,ra_cust_Trx_types_all_dfv rctt_dfv
                ,jg_zz_ar_src_trx_ty st
           where rctt.cust_trx_type_id = st.cust_trx_type_id
             and st.batch_sourcE_id = v_batch_source_id_cm
             and rctt.rowid = rctt_dfv.row_id
             and NVL(rctt_dfv.xx_ar_tipo_trx_void,'N') = 'Y';


        EXCEPTION
          WHEN OTHERS THEN
            v_error_message := 'Error al obtener Tipo de Transaccion de Nota de Credito. Error: '||SQLERRM;
            RAISE e_cust_exception;

        END;

        BEGIN

            select jzastt.cust_trx_type_id
            into v_cust_trx_type_id
            from jg_zz_ar_src_trx_ty jzastt
           where jzastt.cust_trx_type_id = v_cust_trx_type_id
             and jzastt.batch_source_id  = v_batch_source_id_cm;

        EXCEPTION
          WHEN OTHERS THEN
            v_error_message := 'El tipo de Transaccion: '||v_cust_trx_type_name||' no esta asociado al origen de Nota de Credito ID: '||v_batch_source_id_cm||'. Error: '||SQLERRM;
            RAISE e_cust_exception;
        END;

      fnd_file.put_line(fnd_file.log,'Tipo Transaccion Origen: '||v_trx_type);
      fnd_file.put_line(fnd_file.log,'Tipo Transaccion Destino: '||v_trx_type_rev);

      IF v_trx_type IN ('INV','DM') THEN

        IF v_trx_type_rev = 'CM' THEN

            /*BEGIN


                select rbs.batch_source_id
                  into v_batch_source_id_int
                  from ra_batch_sources rbs
                      ,fnd_lookup_values_vl flv
                 where global_attribute2 = flv.meaning
                   and name like '%Intern%'
                   and rbs.status = 'A'
                   AND nvl(rbs.start_date, TRUNC(sysdate)) <= trunc(sysdate)
                   AND nvl(rbs.end_date, TRUNC(sysdate)) >= TRUNC(sysdate)
                   and NVL(TRUNC(flv.start_date_active),TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
                   and NVL(TRUNC(flv.end_date_active),TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                   and flv.lookup_type = 'XX_AR_TAX_RETURN_SETUP'
                   and flv.lookup_code = 'INT_BATCH_SOURCE'
                   and global_attribute3 = (select rbs2.global_attribute3
                                              from ra_batch_sources rbs2
                                             where batch_source_id = p_batch_source_id_cm);
            EXCEPTION
             WHEN OTHERS THEN
                v_error_message := 'Error al obtener ID de Origen de Nota de Credito Interna. Error: '||SQLERRM;
                RAISE e_cust_exception;
            END;

            BEGIN

               select rctt.cust_trx_type_id
                into v_cust_trx_type_id_int
                from ra_cust_trx_types rctt
                    ,fnd_lookup_values_vl flv
               where 1 = 1
                 and rctt.name = flv.meaning
                 and NVL(TRUNC(rctt.start_date),TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
                 and NVL(TRUNC(rctt.end_date),TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                 and NVL(TRUNC(flv.start_date_active),TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
                 and NVL(TRUNC(flv.end_date_active),TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                 and flv.lookup_type = 'XX_AR_TAX_RETURN_SETUP'
                 and flv.lookup_code = 'INT_CUST_TRX_TYPE_'||v_batch_source_letter;

            EXCEPTION
              WHEN OTHERS THEN
                v_error_message := 'Error al obtener ID del Tipo de Transaccion de Nota de Credito Interna. Error: '||SQLERRM;
                RAISE e_cust_exception;
            END;

            BEGIN

               select memo_line_id
                 into v_int_memo_line_id
                 from ar_memo_lines_vl aml
                 ,fnd_lookup_values_vl flv
                 where 1 = 1
                 and NVL(TRUNC(aml.start_date),TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
                 and NVL(TRUNC(aml.end_date),TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                 and NVL(TRUNC(flv.start_date_active),TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
                 and NVL(TRUNC(flv.end_date_active),TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                 and aml.name = flv.meaning
                 and flv.lookup_type = 'XX_AR_TAX_RETURN_SETUP'
                 and flv.lookup_code = 'INT_MEMO_LINE_ID';

            EXCEPTION
              WHEN OTHERS THEN
                v_error_message := 'Error al obtener ID del Memo Line para Nota de Credito Interna. Error: '||SQLERRM;
                RAISE e_cust_exception;
            END;*/

              gen_trx(p_status               => v_status
                     ,p_error_message        => v_error_message
                     ,p_customer_trx_id      => p_customer_trx_id
                     ,p_batch_source_id_cm   => v_batch_source_id_cm
                     ,p_cust_trx_type_id_cm  => v_cust_trx_type_id
                     ,p_order_number         => p_order_number
                     ,p_total_parcial        => p_total_parcial
                     ,p_comments             => p_comments
                     ,p_customer_trx_id_cm   => x_customer_trx_id_cm
                     ,p_trx_number_cm        => x_trx_number_cm
                     ,p_amount_cm            => x_amount_cm);

          IF v_status != 'S' THEN
            RAISE e_cust_exception;
          END IF;

          /*llamo al concurrente para obtener cae*/
            call_cae_process (p_status          => v_status,
                              p_error_message   => v_error_message,
                              p_batch_source_id => v_batch_source_id_cm,
                              p_customer_trx_id => x_customer_trx_id_cm);

            IF NVL(v_status,'*') != 'S' THEN
                RAISE e_cust_exception;
            END IF;

          /*gen_trx_int(p_status               => v_status
                     ,p_error_message        => v_error_message
                     ,p_customer_trx_id      => p_customer_trx_id
                     ,p_batch_source_id_cm   => v_batch_source_id_int
                     ,p_cust_trx_type_id_cm  => v_cust_trx_type_id_int
                     ,p_memo_line_id_int     => v_int_memo_line_id
                     ,p_order_number         => p_order_number
                     ,p_total_parcial        => p_total_parcial
                     ,p_comments             => p_comments
                     ,p_customer_trx_id_int  => x_customer_trx_id_int
                     ,p_trx_number_int       => x_trx_number_int
                     ,p_amount_int           => x_amount_int);

           IF v_status != 'S' THEN
             RAISE e_cust_exception;
           END IF;*/

           fnd_file.put_line(fnd_file.log,'P_CUSTOMER_TRX_ID: '||P_CUSTOMER_TRX_ID);
           fnd_file.put_line(fnd_file.log,'X_CUSTOMER_TRX_ID_CM: '||X_CUSTOMER_TRX_ID_CM);
           fnd_file.put_line(fnd_file.log,'X_TRX_NUMBER_CM: '||X_TRX_NUMBER_CM);
           fnd_file.put_line(fnd_file.log,'X_AMOUNT_CM: '||X_AMOUNT_CM);
           /*fnd_file.put_line(fnd_file.log,'X_CUSTOMER_TRX_ID_INT: '||X_CUSTOMER_TRX_ID_INT);
           fnd_file.put_line(fnd_file.log,'X_TRX_NUMBER_INT: '||X_TRX_NUMBER_INT);
           fnd_file.put_line(fnd_file.log,'X_AMOUNT_INT: '||X_AMOUNT_INT);*/

            apply_credit_memos (p_status              => v_status,
                                p_error_message       => v_error_message,
                                p_customer_trx_id     => p_customer_trx_id,
                                p_customer_trx_id_cm  => x_customer_trx_id_cm,
                                p_trx_number_cm       => x_trx_number_cm,
                                p_cm_amount           => x_amount_cm,
                                p_customer_trx_id_int => x_customer_trx_id_int,
                                p_trx_number_int      => x_trx_number_int,
                                p_int_amount          => x_amount_int);

            IF NVL(v_status,'*') != 'S' THEN
                RAISE e_cust_exception;
            END IF;

        ELSE
            v_error_message := 'El Tipo de Comprobante Destino Debe ser una Nota de Credito';
            RAISE e_cust_exception;
        END IF;

      ELSE
         v_error_message := 'El Tipo de Comprobante Origen Debe ser una Nota de Debito o Factura';
         RAISE e_cust_exception;
      END IF;

      fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.MAIN_PROCESS (-)');

EXCEPTION
   WHEN e_cust_exception THEN
       retcode := 1;
       errbuf := v_error_message;
       fnd_file.put_line(fnd_file.log,errbuf);
       fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.MAIN_PROCESS (!)');
   WHEN OTHERS THEN
       retcode := 2;
       errbuf := 'Error OTHERS en MAIN_PROCESS. Error: '||SQLERRM;
       fnd_file.put_line(fnd_file.log,errbuf);
       fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.MAIN_PROCESS (!)');
END MAIN_PROCESS;

PROCEDURE process_data(p_status        OUT VARCHAR2
                      ,p_error_message OUT VARCHAR2
                      ,p_org_id         IN NUMBER) IS

CURSOR c_int IS
SELECT rila.interface_line_context
      ,rila.interface_line_attribute1
      ,rila.interface_line_attribute2
      ,rila.interface_line_attribute3
      ,rila.interface_line_attribute4
      ,rila.interface_line_attribute5
      ,rila.batch_source_name
      ,rila.cust_trx_type_id
      ,rila.orig_system_bill_customer_id
      ,rila.orig_system_bill_address_id
      ,rila.orig_system_ship_customer_id
      ,rila.orig_system_ship_address_id
      ,rila.currency_code
      ,rila.org_id
      ,rila.status
      ,sum(rila.quantity)*-1 total_quantity
      ,rctla.customer_trx_id
      ,rcta.trx_number
      ,rcta.batch_source_id
from xx_ar_cm_int_lines_all rila
    ,ra_customer_trx_lines_all rctla
    ,ra_customer_trx_all rcta
where 1 = 1
and rila.line_type = 'LINE'
and rila.interface_line_context IN ('ORDER ENTRY')
and rila.status IN ('T','P')
and rila.reference_line_id = rctla.customer_trx_line_id
and rctla.customer_trx_id  = rcta.customer_trx_id
and rila.org_id = p_org_id
GROUP BY rila.interface_line_context
        ,rila.interface_line_attribute1
      ,rila.interface_line_attribute2
      ,rila.interface_line_attribute3
      ,rila.interface_line_attribute4
      ,rila.interface_line_attribute5
      ,rila.batch_source_name
      ,rila.cust_trx_type_id
      ,rila.orig_system_bill_customer_id
      ,rila.orig_system_bill_address_id
      ,rila.orig_system_ship_customer_id
      ,rila.orig_system_ship_address_id
      ,rila.currency_code
      ,rila.org_id
      ,rila.status
      ,rctla.customer_trx_id
      ,rcta.trx_number
      ,rcta.batch_source_id;

v_batch_source_id_cm NUMBER;
v_batch_source_id_nce NUMBER;
v_batch_source_id_int NUMBER;
v_cust_trx_type_id NUMBER;
v_cust_trx_type_id_int NUMBER;

v_int_memo_line_id NUMBER;
v_comments VARCHAR2(80);

v_status VARCHAR2(10);
v_error_message VARCHAR2(2000);

  v_request_id        NUMBER;
  v_conc_phase        VARCHAR2 (50);
  v_conc_status       VARCHAR2 (50);
  v_conc_dev_phase    VARCHAR2 (50);
  v_conc_dev_status   VARCHAR2 (50);
  v_conc_message      VARCHAR2 (2000);
  v_message           VARCHAR2 (2000);

  v_trx_status VARCHAR2(1);
  v_rem        NUMBER;
  v_orig       NUMBER;
  v_exists     NUMBER;

e_trx_exception  EXCEPTION;
e_cust_exception EXCEPTION;

BEGIN

    fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.PROCESS_DATA (+)');

    FOR r_int IN c_int LOOP

        v_trx_status := null;
        fnd_file.put_line(fnd_file.log,'Procesando Pedido: '||r_int.interface_line_attribute1);
        fnd_file.put_line(fnd_file.log,'Procesando Transaccion: '||r_int.trx_number);

       BEGIN

          BEGIN

            BEGIN

                 select rbs.batch_source_id,rbs_dfv.xx_ar_fce_source
                   into v_batch_source_id_cm,v_batch_source_id_nce
                   from ra_batch_sources_all rbs,
                        ra_batch_sources_all_dfv rbs_dfv
                  where rbs.org_id = r_int.org_id
                    and rbs.rowid = rbs_dfv.row_id
                    and rbs.name = r_int.batch_source_name;
            EXCEPTION
             WHEN OTHERS THEN
                v_error_message := 'Error al obtener ID del Origen de Nota de Credito. Error: '||SQLERRM;
                RAISE e_trx_exception;
            END;

            IF r_int.status = 'T' THEN

                BEGIN

                    SELECT 1
                      INTO v_exists
                      FROM ra_customer_trx rct_fc
                          ,ra_customer_trx rct_nc
                          ,ra_cust_trx_types rctt_fc
                          ,ra_cust_trx_types rctt_nc
                          ,ra_customer_trx_lines rctl_fc
                          ,ra_customer_trx_lines rctl_nc
                          ,ra_customer_trx_lines_all_dfv rctl_nc_dfv
                     WHERE 1 = 1
                     and rct_nc.batch_source_id IN ( v_batch_source_id_cm,NVL(v_batch_source_id_nce,-1))
                     and rct_nc.customer_trx_id = rctl_nc.customer_trx_id
                     and rctl_nc.rowid=rctl_nc_dfv.row_id
                     and TO_NUMBER(rctl_nc_dfv.xx_ar_inv_source_line_id) =rctl_fc.customer_trx_line_id
                     and rct_fc.customer_trx_id = rctl_fc.customer_trx_id
                     and rct_fc.trx_number = r_int.trx_number
                     and rctt_fc.cust_trx_type_id = rct_fc.cust_trx_type_id
                     and rctt_fc.type != 'CM'
                     and rctt_nc.cust_trx_type_id = rct_nc.cust_trx_type_id
                     and rctt_nc.type = 'CM';

                EXCEPTION
                 WHEN TOO_MANY_ROWS THEN
                  v_exists := 1;
                 WHEN OTHERS THEN
                  v_exists := 0;
                END;

                IF v_exists = 1 THEN
                    v_error_message := 'Ya existe una Nota de credito creada para esta Factura';
                    fnd_file.put_line(fnd_file.log,v_error_message);
                    RAISE e_trx_exception;
                END IF;

                /*BEGIN

                    select amount_due_remaining,amount_due_original
                    into v_rem,v_orig
                    from ar_payment_schedules_all
                    where customer_trx_id = r_trx.customer_trx_id
                    and org_id = r_int.org_id;

                EXCEPTION
                  WHEN OTHERS THEN
                    v_rem := 0;
                END;

                IF v_rem = 0 THEN
                    v_error_message := 'La transacion no tiene saldo pendiente';
                    fnd_file.put_line(fnd_file.log,v_error_message);
                    RAISE e_trx_exception;
                ELSIF v_rem != 0 and v_rem != v_orig AND r_int.status = 'T' THEN
                    v_error_message := 'La transacion tiene aplicaciones';
                    fnd_file.put_line(fnd_file.log,v_error_message);
                    RAISE e_trx_exception;
                END IF;*/

            END IF;

            /*BEGIN

               select meaning
                 into v_comments
                 from fnd_lookup_values_vl flv
                 where 1 = 1
                 and NVL(TRUNC(flv.start_date_active),TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
                 and NVL(TRUNC(flv.end_date_active),TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                 and flv.lookup_type = 'XX_AR_TAX_RETURN_SETUP'
                 and flv.lookup_code = 'INT_COMMENTS';

            EXCEPTION
              WHEN OTHERS THEN
                v_error_message := 'Error al obtener ID del Memo Line para Nota de Credito Interna. Error: '||SQLERRM;
                RAISE e_trx_exception;
            END;*/

            /*Seteo el org_id*/
            mo_global.set_policy_context('S',r_int.org_id);

            v_request_id := fnd_request.submit_request('XBOL'
                                                      ,'XXARCTTR'
                                                      , ''
                                                      , ''
                                                      , FALSE
                                                      , r_int.batch_source_id
                                                      , r_int.customer_trx_id
                                                      , v_batch_source_id_cm
                                                      , r_int.interface_line_attribute1
                                                      , r_int.status
                                                      , v_comments||' Dev s/ FC: '||r_int.trx_number||'. Pedido Dev: '||r_int.interface_line_attribute1);
            IF v_request_id = 0 THEN
                v_message := fnd_message.get;
                v_error_message := v_message;
                fnd_file.put_line(fnd_file.log, 'Error ejecutando el concurrente XX AR Devolucion Impositiva para Facturas, Error: ' ||v_message || ', ' || sqlerrm);
                RAISE e_trx_exception;
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
                v_error_message := v_message;
                fnd_file.put_line(fnd_file.log, 'Error ejecutando FND_REQUEST.WAIT_FOR_REQUEST. ' ||v_message || ' ' || SQLERRM);
                RAISE e_trx_exception;
            END IF;

            IF v_conc_dev_phase != 'COMPLETE' or v_conc_dev_status NOT IN ('NORMAL') THEN

               /*Agregado KHRONUS/E.SLy 20190705 Aunque finalice el concurrente en error valido si creo el comprobante*/

               BEGIN

                    SELECT 1
                      INTO v_exists
                      FROM ra_customer_trx rct_fc
                          ,ra_customer_trx rct_nc
                          ,ra_customer_trx_lines rctl_fc
                          ,ra_customer_trx_lines rctl_nc
                          ,ra_customer_trx_lines_all_dfv rctl_nc_dfv
                          ,ra_cust_trx_types rctta
                     WHERE 1 = 1
                     --and rct_nc.batch_source_id = v_batch_source_id_cm
                     and rct_nc.batch_source_id IN ( v_batch_source_id_cm,NVL(v_batch_source_id_nce,-1))
                     and rct_nc.customer_trx_id = rctl_nc.customer_trx_id
                     and rctl_nc.rowid=rctl_nc_dfv.row_id
                     and TO_NUMBER(rctl_nc_dfv.xx_ar_inv_source_line_id) =rctl_fc.customer_trx_line_id
                     and rct_fc.customer_trx_id = rctl_fc.customer_trx_id
                     and rct_fc.trx_number = r_int.trx_number
                     and rctta.cust_trx_type_id = rct_nc.cust_trx_type_id
                     and rctta.type = 'CM'
                     and rct_nc.creation_date > sysdate-1
                     and rownum = 1;

               EXCEPTION
                WHEN TOO_MANY_ROWS THEN
                  v_exists := 1;
                WHEN OTHERS THEN
                  v_exists := 0;
               END;

               IF v_exists = 0 THEN

                    update xx_ar_cm_int_lines_all
                       set status = 'E'
                          ,error_message = 'Error al procesar. Revisar Log del ID de Solicitud: '||v_request_id
                      WHERE interface_line_context       = r_int.interface_line_context
                       and interface_line_attribute1    = r_int.interface_line_attribute1
                       and orig_system_bill_customer_id = r_int.orig_system_bill_customer_id
                       and orig_system_bill_address_id  = r_int.orig_system_bill_address_id
                       and orig_system_ship_customer_id = r_int.orig_system_ship_customer_id
                       and orig_system_ship_address_id  = r_int.orig_system_ship_address_id
                       and batch_source_name            = r_int.batch_source_name
                       and cust_trx_type_id             = r_int.cust_trx_type_id
                       and currency_code                = r_int.currency_code
                       and org_id = r_int.org_id
                       and status = 'N';

                       p_status := 'W';
                       RAISE e_trx_exception;

               END IF;

            END IF;

          EXCEPTION
            WHEN e_trx_exception THEN
                v_trx_status := 'E';
          END;

        IF NVL(v_trx_status,'*') = 'E' THEN

                 UPDATE xx_ar_cm_int_lines_all
                    SET status = 'E'
                       ,error_message = v_error_message
                       ,copy_last_update_date = sysdate
                       ,copy_last_updated_by = fnd_global.user_id
                  WHERE interface_line_context       = r_int.interface_line_context
                    and interface_line_attribute1    = r_int.interface_line_attribute1
                    and orig_system_bill_customer_id = r_int.orig_system_bill_customer_id
                    and orig_system_bill_address_id  = r_int.orig_system_bill_address_id
                    and orig_system_ship_customer_id = r_int.orig_system_ship_customer_id
                    and orig_system_ship_address_id  = r_int.orig_system_ship_address_id
                    and batch_source_name            = r_int.batch_source_name
                    and cust_trx_type_id             = r_int.cust_trx_type_id
                    and currency_code                = r_int.currency_code
                    and org_id = r_int.org_id
                    and status IN ('T','P');

                    p_status := 'W';
                    RAISE e_cust_exception;
        ELSE

                update xx_ar_cm_int_lines_all
                    set status = 'S'
                       ,copy_last_update_date = sysdate
                       ,copy_last_updated_by = fnd_global.user_id
                  WHERE interface_line_context       = r_int.interface_line_context
                    and interface_line_attribute1    = r_int.interface_line_attribute1
                    and orig_system_bill_customer_id = r_int.orig_system_bill_customer_id
                    and orig_system_bill_address_id  = r_int.orig_system_bill_address_id
                    and orig_system_ship_customer_id = r_int.orig_system_ship_customer_id
                    and orig_system_ship_address_id  = r_int.orig_system_ship_address_id
                    and batch_source_name            = r_int.batch_source_name
                    and cust_trx_type_id             = r_int.cust_trx_type_id
                    and currency_code                = r_int.currency_code
                    and org_id = r_int.org_id
                    and status IN ('T','P');

                 INSERT INTO bolinf.xx_ar_iface_lines_all
                 SELECT * FROM ra_interface_lines_all
                     WHERE interface_line_context       = r_int.interface_line_context
                       and interface_line_attribute1    = r_int.interface_line_attribute1
                       and orig_system_bill_customer_id = r_int.orig_system_bill_customer_id
                       and orig_system_bill_address_id  = r_int.orig_system_bill_address_id
                       and orig_system_ship_customer_id = r_int.orig_system_ship_customer_id
                       and orig_system_ship_address_id  = r_int.orig_system_ship_address_id
                       and batch_source_name            = r_int.batch_source_name
                       and cust_trx_type_id             = r_int.cust_trx_type_id
                       and currency_code                = r_int.currency_code
                       and org_id = p_org_id;

                 DELETE ra_interface_lines_all
                     WHERE interface_line_context       = r_int.interface_line_context
                       and interface_line_attribute1    = r_int.interface_line_attribute1
                       and orig_system_bill_customer_id = r_int.orig_system_bill_customer_id
                       and orig_system_bill_address_id  = r_int.orig_system_bill_address_id
                       and orig_system_ship_customer_id = r_int.orig_system_ship_customer_id
                       and orig_system_ship_address_id  = r_int.orig_system_ship_address_id
                       and batch_source_name            = r_int.batch_source_name
                       and cust_trx_type_id             = r_int.cust_trx_type_id
                       and currency_code                = r_int.currency_code
                       and org_id = p_org_id;

                  COMMIT;

        END IF;

       EXCEPTION
        WHEN e_cust_exception THEN
         p_status := 'W';
         p_error_message := v_error_message;
       END;

    END LOOP;

    IF p_status is null then
       p_status := 'S';
    END IF;

    fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.PROCESS_DATA (-)');

EXCEPTION
 WHEN OTHERS THEN
   p_status := 'W';
   p_error_message := 'Error al validar Procesar Notas de Credito. Error: '||SQLERRM;
   fnd_file.put_line(fnd_file.log,p_error_message);
   fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.PROCESS_DATA (!)');
END;

PROCEDURE check_total (p_status        OUT VARCHAR2
                      ,p_error_message OUT VARCHAR2
                      ,p_org_id         IN NUMBER) IS

CURSOR c_int IS
SELECT rila.interface_line_context
      ,rila.interface_line_attribute1
      ,rila.interface_line_attribute2
      --,rila.interface_line_attribute3
      ,rila.interface_line_attribute4
      --,rila.interface_line_attribute5
      ,rila.batch_source_name
      ,rila.cust_trx_type_id
      ,rila.orig_system_bill_customer_id
      ,rila.orig_system_bill_address_id
      ,rila.orig_system_ship_customer_id
      ,rila.orig_system_ship_address_id
      ,rila.currency_code
      ,sum(rila.quantity)*-1 total_quantity
from xx_ar_cm_int_lines_all rila
where 1 = 1
and line_type = 'LINE'
and interface_line_context IN ('ORDER ENTRY')
and status = 'N'
and org_id = p_org_id
GROUP BY rila.interface_line_context
        ,rila.interface_line_attribute1
      ,rila.interface_line_attribute2
      --,rila.interface_line_attribute3
      ,rila.interface_line_attribute4
      --,rila.interface_line_attribute5
      ,rila.batch_source_name
      ,rila.cust_trx_type_id
      ,rila.orig_system_bill_customer_id
      ,rila.orig_system_bill_address_id
      ,rila.orig_system_ship_customer_id
      ,rila.orig_system_ship_address_id
      ,rila.currency_code;

CURSOR c_fc (p_interface_line_context VARCHAR2
                    ,p_interface_line_attribute1 VARCHAR2
                    ,p_interface_line_attribute2 VARCHAR2
                    --,p_interface_line_attribute3 VARCHAR2
                    ,p_interface_line_attribute4 VARCHAR2
                    --,p_interface_line_attribute5 VARCHAR2
                    ,p_bill_customer_id NUMBER
                    ,p_bill_address_id NUMBER
                    ,p_ship_customer_id NUMBER
                    ,p_ship_address_id NUMBER
                    ,p_org_id NUMBER) IS
SELECT rctla.customer_trx_id
      ,(select sum(quantity_ordered) from ra_customer_trx_lines_all rctla2 where rctla2.customer_trx_id = rctla.customer_trx_id) cant_fc
      ,sum(rila.quantity)*-1 cant_int
from xx_ar_cm_int_lines_all rila
,ra_customer_trx_lines_all rctla
where 1 = 1
and rila.line_type = 'LINE'
and rila.interface_line_context IN ('ORDER ENTRY')
and rila.status = 'N'
and rila.interface_line_context = p_interface_line_context
and rila.interface_line_attribute1 = p_interface_line_attribute1
and rila.interface_line_attribute2 = p_interface_line_attribute2
--and rila.interface_line_attribute3 = p_interface_line_attribute3
and rila.interface_line_attribute4 = p_interface_line_attribute4
--and rila.interface_line_attribute5 = p_interface_line_attribute5
and rila.orig_system_bill_customer_id = p_bill_customer_id
and rila.orig_system_bill_address_id = p_bill_address_id
and rila.orig_system_ship_customer_id = p_ship_customer_id
and rila.orig_system_ship_address_id = p_ship_address_id
and rila.org_id = p_org_id
and rila.reference_line_id = rctla.customer_trx_line_id
GROUP BY rctla.customer_trx_id;

v_trx_qty NUMBER;
v_int_qty NUMBER;
v_customer_trx_id NUMBER;
v_last_customer_trx_id NUMBER;
v_same_trx NUMBER;
v_total_trx NUMBER;

e_loop_exception EXCEPTION;
e_cust_exception EXCEPTION;

BEGIN

    v_trx_qty:= 0;
    fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.CHECK_TOTAL (+)');

    FOR r_int IN c_int LOOP

        v_int_qty := 0;
        v_same_trx := null;
        v_last_customer_trx_id := null;

        fnd_file.put_line(fnd_file.log,'Obteniendo cantidad de Facturas para pedido: '||r_int.interface_line_attribute1);
        fnd_file.put_line(fnd_file.log,'Cantidad Total de la NC: '||r_int.total_quantity);

        FOR r_fc IN c_fc (r_int.interface_line_context
                                      ,r_int.interface_line_attribute1
                                      ,r_int.interface_line_attribute2
                                      --,r_int.interface_line_attribute3
                                      ,r_int.interface_line_attribute4
                                      --,r_int.interface_line_attribute5
                                      ,r_int.orig_system_bill_customer_id
                                      ,r_int.orig_system_bill_address_id
                                      ,r_int.orig_system_ship_customer_id
                                      ,r_int.orig_system_ship_address_id
                                      ,p_org_id) LOOP

                   IF r_fc.cant_fc = r_fc.cant_int THEN

                        UPDATE xx_ar_cm_int_lines_all
                           SET status = 'T'
                         WHERE interface_line_context       = r_int.interface_line_context
                           and interface_line_attribute1    = r_int.interface_line_attribute1
                           and orig_system_bill_customer_id = r_int.orig_system_bill_customer_id
                           and orig_system_bill_address_id  = r_int.orig_system_bill_address_id
                           and orig_system_ship_customer_id = r_int.orig_system_ship_customer_id
                           and orig_system_ship_address_id  = r_int.orig_system_ship_address_id
                           and batch_source_name            = r_int.batch_source_name
                           and cust_trx_type_id             = r_int.cust_trx_type_id
                           and currency_code                = r_int.currency_code
                           and reference_line_id            IN (select customer_trx_line_id from ra_customer_trx_lines_all where customer_trx_id = r_fc.customer_trx_id)
                           and status = 'N'
                           and org_id = p_org_id;

                   ELSIF r_fc.cant_fc > r_fc.cant_int THEN

                       UPDATE xx_ar_cm_int_lines_all
                           SET status = 'P'
                         WHERE interface_line_context       = r_int.interface_line_context
                           and interface_line_attribute1    = r_int.interface_line_attribute1
                           and orig_system_bill_customer_id = r_int.orig_system_bill_customer_id
                           and orig_system_bill_address_id  = r_int.orig_system_bill_address_id
                           and orig_system_ship_customer_id = r_int.orig_system_ship_customer_id
                           and orig_system_ship_address_id  = r_int.orig_system_ship_address_id
                           and batch_source_name            = r_int.batch_source_name
                           and cust_trx_type_id             = r_int.cust_trx_type_id
                           and currency_code                = r_int.currency_code
                           and reference_line_id            IN (select customer_trx_line_id from ra_customer_trx_lines_all where customer_trx_id = r_fc.customer_trx_id)
                           and status = 'N'
                           and org_id = p_org_id;
                   END IF;

         END LOOP;


    END LOOP;

p_status := 'S';
    fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.CHECK_TOTAL (-)');

EXCEPTION
 WHEN e_cust_exception THEN
   p_status := 'W';
   fnd_file.put_line(fnd_file.log,p_error_message);
   fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.CHECK_TOTAL (!)');
 WHEN OTHERS THEN
   p_status := 'W';
   p_error_message := 'Error al validar NC totales. Error: '||SQLERRM;
   fnd_file.put_line(fnd_file.log,p_error_message);
   fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.CHECK_TOTAL (!)');
END;

PROCEDURE copy_rows (p_status        OUT VARCHAR2
                     ,p_error_message OUT VARCHAR2
                     ,p_org_id         IN NUMBER
                     ,p_request_id     IN NUMBER) IS

CURSOR c_rig IS
--DEVOLUCIONES DE OM
SELECT rila.interface_line_context
      ,rila.interface_line_attribute1
      ,rila.interface_line_attribute2
      ,rila.interface_line_attribute3
      ,rila.interface_line_attribute4
      ,rila.interface_line_attribute5
      ,rila.batch_source_name
      ,rila.cust_trx_type_id
      ,rila.orig_system_bill_customer_id
      ,rila.orig_system_bill_address_id
      ,rila.orig_system_ship_customer_id
      ,rila.orig_system_ship_address_id
      ,rila.currency_code
from ra_interface_lines_all rila
,ra_cust_trx_types_all rctta
where (rila.cust_trx_type_id = rctta.cust_trx_type_id
    OR rila.cust_trx_type_name = rctta.name)
and rila.org_id = rctta.org_id
and rila.org_id = p_org_id
and rctta.type = 'CM'
and line_type = 'LINE'
and interface_line_context IN ('ORDER ENTRY')
and NVL(interface_status,'*') != 'P'
AND NOT EXISTS (SELECT 1
                  FROM xx_ar_cm_int_lines_all xacila
                 WHERE xacila.interface_line_context       = rila.interface_line_context
                   AND xacila.interface_line_attribute1    = rila.interface_line_attribute1
                   AND xacila.interface_line_attribute2    = rila.interface_line_attribute2
                   AND xacila.interface_line_attribute3    = rila.interface_line_attribute3
                   AND xacila.interface_line_attribute4    = rila.interface_line_attribute4
                   AND xacila.interface_line_attribute5    = rila.interface_line_attribute5
                   AND xacila.batch_source_name            = rila.batch_source_name
                   AND xacila.cust_trx_type_id             = rila.cust_trx_type_id
                   AND xacila.orig_system_bill_customer_id = rila.orig_system_bill_customer_id
                   AND xacila.orig_system_bill_address_id  = rila.orig_system_bill_address_id
                   AND xacila.orig_system_ship_customer_id = rila.orig_system_ship_customer_id
                   AND xacila.orig_system_ship_address_id  = rila.orig_system_ship_address_id
                   AND xacila.currency_code                = rila.currency_code
                   AND NVL(xacila.status,'N') = 'N'
                   and NVL(xacila.request_id,1) != p_request_id)
/*Modificado Khronus/E.Sly 20190821 Aplica para todas las companias de Argentina*/
AND XX_JG_ZZ_SHARED_PKG.get_country(p_org_id => MO_GLOBAL.get_current_org_id) = 'AR'
--AND EXISTS (select 1
--              from fnd_lookup_values_vl flv
--             where flv.lookup_code like 'ORG_'||to_char(p_org_id)
--               and flv.lookup_type = 'XX_AR_TAX_RETURN_SETUP')
/*Fin Modificado Khronus/E.Sly 20190821 Aplica para todas las companias de Argentina*/
GROUP BY rila.interface_line_context
        ,rila.interface_line_attribute1
      ,rila.interface_line_attribute2
      ,rila.interface_line_attribute3
      ,rila.interface_line_attribute4
      ,rila.interface_line_attribute5
      ,rila.batch_source_name
      ,rila.cust_trx_type_id
      ,rila.orig_system_bill_customer_id
      ,rila.orig_system_bill_address_id
      ,rila.orig_system_ship_customer_id
      ,rila.orig_system_ship_address_id
      ,rila.currency_code;

cursor c_lines ( p_interface_line_attribute1 VARCHAR2
                ,p_interface_line_attribute2 VARCHAR2
                --,p_interface_line_attribute3 VARCHAR2
                ,p_interface_line_attribute4 VARCHAR2
                --,p_interface_line_attribute5 VARCHAR2
                ,p_batch_source_name VARCHAR2
                ,p_cust_trx_type_id NUMBER
                ,p_orig_system_bill_customer_id NUMBER
                ,p_orig_system_bill_address_id NUMBER
                ,p_orig_system_ship_customer_id NUMBER
                ,p_orig_system_ship_address_id NUMBER
                ,p_currency_code VARCHAR2
                ,p_interface_line_context VARCHAR2) is
select rila.*
from ra_interface_lines_all rila
where  interface_line_context = p_interface_line_context
and interface_line_attribute1 = p_interface_line_attribute1
and interface_line_attribute2 = p_interface_line_attribute2
--and ((interface_line_attribute3 = p_interface_line_attribute3 and p_interface_line_attribute3 is not null) OR p_interface_line_attribute3 is null)
and ((interface_line_attribute4 = p_interface_line_attribute4 and p_interface_line_attribute4 is not null) OR p_interface_line_attribute4 is null)
--and ((interface_line_attribute5 = p_interface_line_attribute5 and p_interface_line_attribute4 is not null) OR p_interface_line_attribute5 is null)
and batch_source_name = p_batch_source_name
and cust_trx_type_id = p_cust_trx_type_id
and rila.org_id = p_org_id
and orig_system_bill_customer_id = p_orig_system_bill_customer_id
and orig_system_bill_address_id = p_orig_system_bill_address_id
and orig_system_ship_customer_id = p_orig_system_ship_customer_id
and orig_system_ship_address_id = p_orig_system_ship_address_id
and currency_code = p_currency_code;

v_cm_int_line_id NUMBER;

BEGIN

    fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.COPY_ROWS (+)');

    FOR r_rig IN c_rig LOOP

        fnd_file.put_line(fnd_file.log,'Copiando Registros Pedido: '||r_rig.interface_line_attribute1);

        FOR r_line in c_lines (r_rig.interface_line_attribute1,r_rig.interface_line_attribute2
                              --,r_rig.interface_line_attribute3
                              ,r_rig.interface_line_attribute4
                              --,r_rig.interface_line_attribute5
                              ,r_rig.batch_source_name
                              ,r_rig.cust_trx_type_id,r_rig.orig_system_bill_customer_id,r_rig.orig_system_bill_address_id
                              ,r_rig.orig_system_ship_customer_id,r_rig.orig_system_ship_address_id,r_rig.currency_code
                              ,r_rig.interface_line_context) LOOP

            SELECT xx_ar_cm_int_lines_s.NEXTVAL
              INTO v_cm_int_line_id
              FROM dual;

            INSERT INTO xx_ar_cm_int_lines_all
                 VALUES (v_cm_int_line_id
                        ,r_line.interface_line_id
                        ,r_line.interface_line_context
                        ,r_line.interface_line_attribute1,r_line.interface_line_attribute2,r_line.interface_line_attribute3,r_line.interface_line_attribute4
                        ,r_line.interface_line_attribute5,r_line.interface_line_attribute6,r_line.interface_line_attribute7,r_line.interface_line_attribute8
                        ,r_line.batch_source_name
                        ,r_line.set_of_books_id
                        ,r_line.line_type
                        ,r_line.description
                        ,r_line.currency_code
                        ,r_line.amount
                        ,r_line.cust_trx_type_name
                        ,r_line.cust_trx_type_id
                        ,r_line.term_name
                        ,r_line.term_id
                        ,r_line.orig_system_batch_name
                        ,r_line.orig_system_bill_customer_ref
                        ,r_line.orig_system_bill_customer_id
                        ,r_line.orig_system_bill_address_ref
                        ,r_line.orig_system_bill_address_id
                        ,r_line.orig_system_bill_contact_ref
                        ,r_line.orig_system_bill_contact_id
                        ,r_line.orig_system_ship_customer_ref
                        ,r_line.orig_system_ship_customer_id
                        ,r_line.orig_system_ship_address_ref
                        ,r_line.orig_system_ship_address_id
                        ,r_line.orig_system_ship_contact_ref
                        ,r_line.orig_system_ship_contact_id
                        ,r_line.orig_system_sold_customer_ref
                        ,r_line.orig_system_sold_customer_id
                        ,r_line.link_to_line_id
                        ,r_line.link_to_line_context
                        ,r_line.link_to_line_attribute1,r_line.link_to_line_attribute2,r_line.link_to_line_attribute3,r_line.link_to_line_attribute4
                        ,r_line.link_to_line_attribute5,r_line.link_to_line_attribute6,r_line.link_to_line_attribute7
                        ,r_line.receipt_method_name
                        ,r_line.receipt_method_id
                        ,r_line.conversion_type
                        ,r_line.conversion_date
                        ,r_line.conversion_rate
                        ,r_line.customer_trx_id
                        ,r_line.trx_date
                        ,r_line.gl_date
                        ,r_line.document_number
                        ,r_line.trx_number
                        ,r_line.line_number
                        ,r_line.quantity
                        ,r_line.quantity_ordered
                        ,r_line.unit_selling_price
                        ,r_line.unit_standard_price
                        ,r_line.printing_option
                        ,r_line.interface_status
                        ,r_line.request_id
                        ,r_line.related_batch_source_name
                        ,r_line.related_trx_number
                        ,r_line.related_customer_trx_id
                        ,r_line.previous_customer_trx_id
                        ,r_line.credit_method_for_acct_rule
                        ,r_line.credit_method_for_installments
                        ,r_line.reason_code
                        ,r_line.tax_rate
                        ,r_line.tax_code
                        ,r_line.tax_precedence
                        ,r_line.exception_id
                        ,r_line.exemption_id
                        ,r_line.ship_date_actual
                        ,r_line.fob_point
                        ,r_line.ship_via
                        ,r_line.waybill_number
                        ,r_line.invoicing_rule_name
                        ,r_line.invoicing_rule_id
                        ,r_line.accounting_rule_name
                        ,r_line.accounting_rule_id
                        ,r_line.accounting_rule_duration
                        ,r_line.rule_start_date
                        ,r_line.primary_salesrep_number
                        ,r_line.primary_salesrep_id
                        ,r_line.sales_order
                        ,r_line.sales_order_line
                        ,r_line.sales_order_date
                        ,r_line.sales_order_source
                        ,r_line.sales_order_revision
                        ,r_line.purchase_order
                        ,r_line.purchase_order_revision
                        ,r_line.purchase_order_date
                        ,r_line.agreement_name
                        ,r_line.agreement_id
                        ,r_line.memo_line_name
                        ,r_line.memo_line_id
                        ,r_line.inventory_item_id
                        ,r_line.mtl_system_items_seg1,r_line.mtl_system_items_seg2,r_line.mtl_system_items_seg3,r_line.mtl_system_items_seg4
                        ,r_line.mtl_system_items_seg5,r_line.mtl_system_items_seg6,r_line.mtl_system_items_seg7,r_line.mtl_system_items_seg8
                        ,r_line.mtl_system_items_seg9,r_line.mtl_system_items_seg10,r_line.mtl_system_items_seg11,r_line.mtl_system_items_seg12
                        ,r_line.mtl_system_items_seg13,r_line.mtl_system_items_seg14,r_line.mtl_system_items_seg15,r_line.mtl_system_items_seg16
                        ,r_line.mtl_system_items_seg17,r_line.mtl_system_items_seg18,r_line.mtl_system_items_seg19,r_line.mtl_system_items_seg20
                        ,r_line.reference_line_id
                        ,r_line.reference_line_context
                        ,r_line.reference_line_attribute1,r_line.reference_line_attribute2
                        ,r_line.reference_line_attribute3,r_line.reference_line_attribute4
                        ,r_line.reference_line_attribute5,r_line.reference_line_attribute6,r_line.reference_line_attribute7
                        ,r_line.territory_id
                        ,r_line.territory_segment1,r_line.territory_segment2,r_line.territory_segment3,r_line.territory_segment4
                        ,r_line.territory_segment5,r_line.territory_segment6,r_line.territory_segment7,r_line.territory_segment8
                        ,r_line.territory_segment9,r_line.territory_segment10,r_line.territory_segment11,r_line.territory_segment12
                        ,r_line.territory_segment13,r_line.territory_segment14,r_line.territory_segment15,r_line.territory_segment16
                        ,r_line.territory_segment17,r_line.territory_segment18,r_line.territory_segment19,r_line.territory_segment20
                        ,r_line.attribute_category
                        ,r_line.attribute1,r_line.attribute2,r_line.attribute3,r_line.attribute4,r_line.attribute5,r_line.attribute6,r_line.attribute7,r_line.attribute8
                        ,r_line.attribute9,r_line.attribute10,r_line.attribute11,r_line.attribute12,r_line.attribute13,r_line.attribute14,r_line.attribute15
                        ,r_line.header_attribute_category
                        ,r_line.header_attribute1,r_line.header_attribute2,r_line.header_attribute3,r_line.header_attribute4,r_line.header_attribute5
                        ,r_line.header_attribute6,r_line.header_attribute7,r_line.header_attribute8,r_line.header_attribute9,r_line.header_attribute10
                        ,r_line.header_attribute11,r_line.header_attribute12,r_line.header_attribute13,r_line.header_attribute14,r_line.header_attribute15
                        ,r_line.comments
                        ,r_line.internal_notes
                        ,r_line.initial_customer_trx_id
                        ,r_line.ussgl_transaction_code_context
                        ,r_line.ussgl_transaction_code
                        ,r_line.acctd_amount
                        ,r_line.customer_bank_account_id
                        ,r_line.customer_bank_account_name
                        ,r_line.uom_code
                        ,r_line.uom_name
                        ,r_line.document_number_sequence_id
                        ,r_line.link_to_line_attribute10,r_line.link_to_line_attribute11,r_line.link_to_line_attribute12,r_line.link_to_line_attribute13
                        ,r_line.link_to_line_attribute14,r_line.link_to_line_attribute15,r_line.link_to_line_attribute8,r_line.link_to_line_attribute9
                        ,r_line.reference_line_attribute10,r_line.reference_line_attribute11,r_line.reference_line_attribute12
                        ,r_line.reference_line_attribute13,r_line.reference_line_attribute14,r_line.reference_line_attribute15
                        ,r_line.reference_line_attribute8,r_line.reference_line_attribute9,r_line.interface_line_attribute10
                        ,r_line.interface_line_attribute11,r_line.interface_line_attribute12,r_line.interface_line_attribute13
                        ,r_line.interface_line_attribute14,r_line.interface_line_attribute15,r_line.interface_line_attribute9
                        ,r_line.vat_tax_id
                        ,r_line.reason_code_meaning
                        ,r_line.last_period_to_credit
                        ,r_line.paying_customer_id
                        ,r_line.paying_site_use_id
                        ,r_line.tax_exempt_flag
                        ,r_line.tax_exempt_reason_code
                        ,r_line.tax_exempt_reason_code_meaning
                        ,r_line.tax_exempt_number
                        ,r_line.sales_tax_id
                        ,r_line.created_by
                        ,r_line.creation_date
                        ,r_line.last_updated_by
                        ,r_line.last_update_date
                        ,r_line.last_update_login
                        ,r_line.location_segment_id
                        ,r_line.movement_id
                        ,r_line.org_id
                        ,r_line.amount_includes_tax_flag
                        ,r_line.header_gdf_attr_category
                        ,r_line.header_gdf_attribute1,r_line.header_gdf_attribute2,r_line.header_gdf_attribute3,r_line.header_gdf_attribute4
                        ,r_line.header_gdf_attribute5,r_line.header_gdf_attribute6,r_line.header_gdf_attribute7,r_line.header_gdf_attribute8
                        ,r_line.header_gdf_attribute9,r_line.header_gdf_attribute10,r_line.header_gdf_attribute11,r_line.header_gdf_attribute12
                        ,r_line.header_gdf_attribute13,r_line.header_gdf_attribute14,r_line.header_gdf_attribute15,r_line.header_gdf_attribute16
                        ,r_line.header_gdf_attribute17,r_line.header_gdf_attribute18,r_line.header_gdf_attribute19,r_line.header_gdf_attribute20
                        ,r_line.header_gdf_attribute21,r_line.header_gdf_attribute22,r_line.header_gdf_attribute23,r_line.header_gdf_attribute24
                        ,r_line.header_gdf_attribute25,r_line.header_gdf_attribute26,r_line.header_gdf_attribute27,r_line.header_gdf_attribute28
                        ,r_line.header_gdf_attribute29,r_line.header_gdf_attribute30
                        ,r_line.line_gdf_attr_category
                        ,r_line.line_gdf_attribute1,r_line.line_gdf_attribute2,r_line.line_gdf_attribute3,r_line.line_gdf_attribute4
                        ,r_line.line_gdf_attribute5,r_line.line_gdf_attribute6,r_line.line_gdf_attribute7,r_line.line_gdf_attribute8
                        ,r_line.line_gdf_attribute9,r_line.line_gdf_attribute10,r_line.line_gdf_attribute11,r_line.line_gdf_attribute12
                        ,r_line.line_gdf_attribute13,r_line.line_gdf_attribute14,r_line.line_gdf_attribute15,r_line.line_gdf_attribute16
                        ,r_line.line_gdf_attribute17,r_line.line_gdf_attribute18,r_line.line_gdf_attribute19,r_line.line_gdf_attribute20
                        ,r_line.reset_trx_date_flag
                        ,r_line.payment_server_order_num
                        ,r_line.approval_code
                        ,r_line.address_verification_code
                        ,r_line.warehouse_id
                        ,r_line.translated_description
                        ,r_line.cons_billing_number
                        ,r_line.promised_commitment_amount
                        ,r_line.payment_set_id
                        ,r_line.original_gl_date
                        ,r_line.contract_line_id
                        ,r_line.contract_id
                        ,r_line.source_data_key1,r_line.source_data_key2,r_line.source_data_key3,r_line.source_data_key4,r_line.source_data_key5
                        ,r_line.invoiced_line_acctg_level
                        ,r_line.override_auto_accounting_flag
                        ,r_line.rule_end_date
                        ,r_line.mandate_last_trx_flag
                        ,r_line.source_application_id
                        ,r_line.source_event_class_code
                        ,r_line.source_entity_code
                        ,r_line.source_trx_id
                        ,r_line.source_trx_line_id
                        ,r_line.source_trx_line_type
                        ,r_line.source_trx_detail_tax_line_id
                        ,r_line.historical_flag
                        ,r_line.tax_regime_code
                        ,r_line.tax
                        ,r_line.tax_status_code
                        ,r_line.tax_rate_code
                        ,r_line.tax_jurisdiction_code
                        ,r_line.taxable_amount
                        ,r_line.taxable_flag
                        ,r_line.legal_entity_id
                        ,r_line.parent_line_id
                        ,r_line.deferral_exclusion_flag
                        ,r_line.payment_trxn_extension_id
                        ,r_line.payment_attributes
                        ,r_line.application_id
                        ,r_line.billing_date
                        ,r_line.trx_business_category
                        ,r_line.product_fisc_classification
                        ,r_line.product_category
                        ,r_line.product_type
                        ,r_line.line_intended_use
                        ,r_line.assessable_value
                        ,r_line.document_sub_type
                        ,r_line.default_taxation_country
                        ,r_line.user_defined_fisc_class
                        ,r_line.taxed_upstream_flag
                        ,r_line.payment_type_code
                        ,r_line.tax_invoice_date
                        ,r_line.tax_invoice_number
                        ,r_line.rev_rec_application
                        ,r_line.document_type_id
                        ,r_line.document_creation_date
                        ,r_line.doc_line_id_int_1,r_line.doc_line_id_int_2,r_line.doc_line_id_int_3,r_line.doc_line_id_int_4,r_line.doc_line_id_int_5
                        ,r_line.doc_line_id_char_1,r_line.doc_line_id_char_2,r_line.doc_line_id_char_3,r_line.doc_line_id_char_4
                        ,r_line.doc_line_id_char_5
                        ,'N'
                        ,NULL
                        ,SYSDATE
                        ,fnd_global.user_id
                        ,SYSDATE
                        ,fnd_global.user_id
                        ,p_request_id);
       END LOOP;

    END LOOP;

    p_status := 'S';
    fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.COPY_ROWS (-)');

EXCEPTION
  WHEN OTHERS THEN
    p_status := 'W';
    p_error_message := 'Error al obtener registros de la tabla de Interfaz. Error: '||SQLERRM;
    fnd_file.put_line(fnd_file.log, p_error_message);
    fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.COPY_ROWS (!)');
END;

PROCEDURE PROCESS_NC (p_status        OUT VARCHAR2
                     ,p_error_message OUT VARCHAR2
                     ,p_org_id         IN NUMBER
                     ,p_request_id     IN NUMBER) IS

e_cust_exception EXCEPTION;

v_status VARCHAR2(5);
v_error_message VARCHAR2(2000);

BEGIN

    fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.PROCESS_NC (+)');

    delete xx_ar_cm_int_lines_all where status = 'E';

    commit;

    /*Copio los registros de la tabla de interfaz a la tabla custom*/
    copy_rows (p_status        => v_status
              ,p_error_message => v_error_message
              ,p_org_id        => p_org_id
              ,p_request_id    => p_request_id);

    IF NVL(v_status,'*') != 'S' THEN
      RAISE e_cust_exception;
    END IF;

    /*Analizo cuales son facturas por total o parciales*/
    /*Las Parciales las marco como procesadas, las completa para procesar*/
    check_total (p_status        => v_status
                ,p_error_message => v_error_message
                ,p_org_id        => p_org_id);

    process_data (p_status        => v_status
                 ,p_error_message => v_error_message
                 ,p_org_id        => p_org_id);

    IF NVL(v_status,'*') != 'S' THEN
      RAISE e_cust_exception;
    END IF;

    p_status := 'S';

    fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.PROCESS_NC (-)');

EXCEPTION
  WHEN e_cust_exception THEN
    p_status := 'W';
    fnd_file.put_line(fnd_file.log,p_error_message);
    fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.PROCESS_NC (!)');
  WHEN OTHERS THEN
    p_status := 'W';
    p_error_message := 'Error OTHERS en XX_AR_TAX_RETURN_NC_PKG.PROCESS_NC. Error: '||SQLERRM;
    fnd_file.put_line(fnd_file.log,p_error_message);
    fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.PROCESS_NC (!)');
END;

PROCEDURE create_int  (p_status        OUT VARCHAR2
                      ,p_error_message OUT VARCHAR2
                      ,p_date_from     IN  VARCHAR2
                      ,p_date_to       IN  VARCHAR2
                      ,p_period_name   IN  VARCHAR2
                      ,p_debug         IN  VARCHAR2) IS


CURSOR c_trx is
select rctta_nc.type,rctta_nc.name,rcta_inv.customer_trx_id inv_customer_trx_id,rcta_nc.customer_trx_id cm_customer_trx_id,rcta_inv.trx_number trx_number_inv,rcta_nc.trx_number trx_number_nc
      ,rcta_inv.set_of_books_id
      ,rcta_inv.sold_to_customer_id
      ,rcta_inv.bill_to_customer_id
      ,rcta_inv.bill_to_site_use_id
      ,rcta_inv.ship_to_customer_id
      ,rcta_inv.ship_to_site_use_id
      ,hcsub.cust_acct_site_id bill_to_address_id
      ,hcsus.cust_acct_site_id ship_to_address_id
      ,rcta_inv.invoice_currency_code
      ,rcta_inv.org_id
      ,NVL(rcta_inv.exchange_rate_type,'User') exchange_rate_type
      ,TRUNC(NVL(rcta_inv.exchange_date,SYSDATE)) exchange_date
      ,DECODE(NVL(rcta_inv.exchange_rate_type,'User'),'Corporate',NULL,NVL(rcta_inv.exchange_rate,'1')) exchange_rate
      ,rcta_inv.customer_trx_id
      ,rcta_inv.receipt_method_id
      ,rcta_inv.paying_customer_id
      ,rcta_inv.paying_site_use_id
      ,rcta_inv.trx_date
      ,rcta_inv.primary_salesrep_id
     from ra_customer_Trx rcta_inv
         ,ra_cust_trx_types rctta_inv
         ,ra_customer_trx rcta_nc
         ,ra_cust_trx_types rctta_nc
         ,ar_receivable_applications araa
         ,hz_cust_site_uses hcsub
         ,hz_cust_site_uses hcsus
         ,hz_cust_accounts hca
         ,hz_parties hp
    where rcta_inv.customer_trx_id = araa.applied_customer_trx_id
    and araa.customer_trx_id = rcta_nc.customer_trx_id
    and rcta_inv.cust_trx_type_id = rctta_inv.cust_trx_type_id
    and rctta_inv.type IN ('INV','DM')
    and rcta_nc.cust_trx_type_id = rctta_nc.cust_trx_type_id
    and rctta_nc.type = 'CM'
    and rcta_nc.interface_header_context IN ('XX_AR_DEVOLUCION_NC','XX_AR_CERTIFICADOS','XX_AR_FC_PERCEP')
    and araa.display = 'Y'
    and rcta_inv.bill_to_site_use_id = hcsub.site_use_id
    and rcta_inv.ship_to_site_use_id = hcsus.site_use_id
    and rcta_inv.bill_to_customer_id = hca.cust_account_id
    and hca.party_id        = hp.party_id
    and rcta_inv.trx_date >= NVL(TRUNC(TO_DATE(p_date_from,'YYYY/MM/DD HH24:MI:SS')),TRUNC(SYSDATE))
    and rcta_inv.trx_date <= NVL(TRUNC(TO_DATE(p_date_to,'YYYY/MM/DD HH24:MI:SS')),TRUNC(SYSDATE))
    and not exists (select 1
                  from ar_receivable_applications araa_int
                      ,ra_customer_trx rcta_int
                      ,ra_cust_trx_types rctta_int
                 where rcta_inv.customer_trx_id = araa_int.applied_customer_trx_id
                   and rcta_int.customer_trx_id = araa_int.customer_trx_id
                   and rcta_int.cust_trx_type_id = rctta_int.cust_trx_type_id
                   and rcta_int.interface_header_attribute1 = rcta_nc.trx_number
                   and rctta_int.type = 'CM'
                   and araa_int.display = 'Y'
                   and SUBSTR(rcta_int.trx_number,3,4) = (select flv.meaning
                  from fnd_lookup_values_vl flv
                 where NVL(TRUNC(flv.start_date_active),TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
                   and NVL(TRUNC(flv.end_date_active),TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                   and flv.lookup_type = 'XX_AR_TAX_RETURN_SETUP'
                   and flv.lookup_code = 'INT_BATCH_SOURCE'))
    /*Que la NC no sea interna*/
    AND NOT EXISTS (SELECT 1
                    from fnd_lookup_values_vl flv
                 where NVL(TRUNC(flv.start_date_active),TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
                   and NVL(TRUNC(flv.end_date_active),TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                   and flv.lookup_type = 'XX_AR_TAX_RETURN_SETUP'
                   and flv.lookup_code = 'INT_BATCH_SOURCE'
                   and SUBSTR(rcta_nc.trx_number,3,4) = flv.meaning)
    /*Que tenga saldo*/
    and (select NVL(sum(NVL(amount_due_remaining,0)),0) from ar_payment_schedules where customer_trx_id = rcta_inv.customer_trx_id) != 0
    /*Que tengan percepciones */
    and exists (select 1
                  from ra_customer_trx_lines rctla_inv
                      ,zx_rates_b zr
                 where rctla_inv.customer_trx_id = rcta_inv.customer_trx_id
                   and rctla_inv.line_type = 'TAX'
                   and rctla_inv.vat_tax_id = zr.tax_rate_id
                   and zr.tax like 'TOP%'
                   /*Que no se calcularon a la NC*/
                   and not exists (select 1
                                     from ra_customer_trx_lines rctla_nc
                                    where rctla_nc.customer_trx_id = rcta_nc.customer_trx_id
                                      and rctla_nc.line_type = 'TAX'
                                      and rctla_nc.vat_tax_id = zr.tax_rate_id));

/*CURSOR c_lines (p_cm_customer_trx_id NUMBER) IS
select customer_trx_line_id
      ,extended_amount
  from ra_customer_trx_lines rctla
 where rctla.customer_trx_id = p_cm_customer_trx_id
   and rctla.line_type = 'LINE';*/

/*Impuestos TOP de la factura*/
CURSOR c_tax (p_inv_customer_trx_id NUMBER
             ,p_cm_customer_trx_id NUMBER) is
   select rcta_inv.customer_trx_id inv_customer_trx_id,rctla_inv.customer_trx_line_id
         ,rctla_inv.link_to_cust_trx_line_id
         ,zr.tax_rate_code
         ,rctla_inv.vat_tax_id
         ,zr.percentage_rate tax_rate
         ,zr.tax_regime_code
         ,zr.tax
         ,zr.tax_status_code
         ,case
          when taxable_amount = (SELECT SUM(extended_amount)
                                   from ra_customer_trx_lines_all rctla_item
                                  where customer_trx_id =  p_inv_customer_trx_id
                                  and rctla_item.customer_trX_line_id = rctla_inv.link_to_cust_trx_line_id
                                    and line_type = 'LINE') + (SELECT rctla_tax.extended_amount
                                   from ra_customer_trx_lines_all rctla_tax
                                       ,ar_vat_tax_all avt
                                  where rctla_tax.customer_trx_id =  p_inv_customer_trx_id
                                    and rctla_tax.link_to_cust_trx_line_id = rctla_inv.link_to_cust_trx_line_id
                                    and line_type = 'TAX'
                                    and rctla_tax.vat_tax_id = avt.vat_tax_id
                                    and avt.global_attribute1 = 51
                                    and rctla_tax.extendeD_amount != 0) THEN
          'Y'
          else
          'N'
          end incl_iva
     from ra_customer_Trx rcta_inv
         ,ra_customer_trx_lines rctla_inv
         ,zx_rates_b zr
    where rcta_inv.customer_trx_id = p_inv_customer_trx_id
    and rctla_inv.customer_trx_id = rcta_inv.customer_trx_id
    and rctla_inv.line_type = 'TAX'
    and zr.tax like 'TOP%'
    and rctla_inv.vat_tax_id = zr.tax_rate_id
    and rctla_inv.extended_amount != 0
    /*Que no se calcularon a la NC*/
    and not exists (select 1
                      from ra_customer_trx_lines rctla_nc
                     where rctla_nc.customer_trx_id = p_cm_customer_trx_id
                       and rctla_nc.line_type = 'TAX'
                       and rctla_nc.vat_tax_id = zr.tax_rate_id)
    GROUP BY rcta_inv.customer_trx_id,zr.tax_rate_code,rctla_inv.vat_tax_id,zr.percentage_rate
         ,zr.tax_regime_code
         ,zr.tax
         ,zr.tax_status_code,taxable_amount,rctla_inv.link_to_cust_trx_line_id,rctla_inv.customer_trx_line_id;

      CURSOR c_dist(p_customer_trx_id      NUMBER
                ,p_customer_trx_line_id NUMBER)
   IS
   SELECT *
      FROM ra_cust_trx_line_gl_dist
     WHERE customer_trx_id=p_customer_trx_id
       AND  ((p_customer_trx_line_id IS NOT NULL
          AND customer_trx_line_id = p_customer_trx_line_id)
          OR (p_customer_trx_line_id IS NULL
          AND customer_trx_line_id IS NULL));

    cursor list_errors is
   SELECT trx_header_id, trx_line_id, trx_salescredit_id, trx_dist_id,
          trx_contingency_id, error_message, invalid_value
   FROM   ar_trx_errors_gt;

   cursor list_headers is
   SELECT trx_header_id,
          customer_trx_id
   FROM   ar_trx_header_gt;

    v_batch_source_id_int  NUMBER;
    v_batch_source_name_int VARCHAR2(50);
    v_cust_trx_type_id_int NUMBER;
    v_int_memo_line_id     NUMBER;
    v_gl_date DATE;

    e_cust_exception EXCEPTION;
    e_trx_exception EXCEPTION;
    e_api_exception EXCEPTION;

    l_batch_source_rec     ar_invoice_api_pub.batch_source_rec_type;
    l_trx_header_tbl       ar_invoice_api_pub.trx_header_tbl_type;
    l_trx_lines_tbl        ar_invoice_api_pub.trx_line_tbl_type;
    l_trx_dist_tbl         ar_invoice_api_pub.trx_dist_tbl_type;
    l_trx_salescredits_tbl ar_invoice_api_pub.trx_salescredits_tbl_type;

    v_line_number NUMBER;
    v_dist_number NUMBER;
    v_imp_amount NUMBER;
    v_imp2_amount NUMBER;
    v_int_amount NUMBER;
    v_impo_amount NUMBER;
    v_tax_amount NUMBER;
    v_tax2_amount NUMBER;
    x_customer_trx_id     NUMBER;
    x_trx_number          ra_customer_trx_all.trx_number%TYPE;
    p_mesg_error          VARCHAR2(2000);
    l_return_status        varchar2(1);
    l_msg_count            number;
    l_msg_data             varchar2(2000);
    l_cnt                  number := 0;
    v_interface_line_attribute3 VARCHAR2(360);

    v_inv_payment_schedule NUMBER;
    v_cm_payment_schedule NUMBER;

    v_ussgl_transaction_code    varchar2(1024);
    v_null_flex                 varchar2(1024);
    v_out_rec_application_id    number;
    v_acctd_amount_applied_from number;
    v_acctd_amount_applied_to   number;


BEGIN

    fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.CREATE_INT (+)');

    fnd_file.put_line(fnd_file.log,'Genero Interface_line_attribute3');

      SELECT to_char(sysdate, 'DDMMRR')||fnd_global.conc_request_id
        INTO v_interface_line_attribute3
        FROM dual;

    fnd_file.put_line(fnd_file.log,'Valido la fecha ingresada');

    IF p_period_name is not null then

        BEGIN

                select end_date
                  into v_gl_date
                  from gl_period_statuses gps
                 where closing_status = 'O'
                   and gps.application_id = 222
                   and period_name = p_period_name
                   and set_of_books_id = (select set_of_books_id
                                            from hr_operating_units
                                           where organization_id = MO_GLOBAL.GET_CURRENT_ORG_ID);

        EXCEPTION
         WHEN OTHERS THEN
          p_error_message := 'Error al verificar la fecha contable';
          RAISE e_cust_exception;
        END;

    END IF;

      fnd_file.put_line(fnd_file.log,'Recorro los comprobantes');

    FOR r_trx in c_trx LOOP

        v_line_number := 0;
           v_int_amount := 0;

       BEGIN

        fnd_file.put_line(fnd_file.output,'TRANSACCION FC/ND ORIGINAL NRO: '||r_trx.trx_number_inv);

        SAVEPOINT s_trx;

          fnd_file.put_line(fnd_file.log,'Inicializo tablas de la API');

          BEGIN

            l_trx_header_tbl.DELETE;
            l_trx_lines_tbl.DELETE;
            l_trx_dist_tbl.DELETE;

          EXCEPTION
            WHEN OTHERS THEN
              p_error_message := 'Error en DELETE';
              raise e_trx_exception;
          END;

          v_dist_number := 0;
          x_trx_number := null;

          fnd_file.put_line(fnd_file.log,'Obtengo Origen de Nota de Credito Interna');

            BEGIN


                select rbs.batch_source_id
                      ,rbs.name
                  into v_batch_source_id_int
                      ,v_batch_source_name_int
                  from ra_batch_sources rbs
                      ,fnd_lookup_values_vl flv
                 where global_attribute2 = flv.meaning
                   and name like '%Intern%'
                   and rbs.status = 'A'
                   AND nvl(rbs.start_date, TRUNC(sysdate)) <= trunc(sysdate)
                   AND nvl(rbs.end_date, TRUNC(sysdate)) >= TRUNC(sysdate)
                   and NVL(TRUNC(flv.start_date_active),TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
                   and NVL(TRUNC(flv.end_date_active),TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                   and flv.lookup_type = 'XX_AR_TAX_RETURN_SETUP'
                   and flv.lookup_code = 'INT_BATCH_SOURCE'
                   and global_attribute3 = SUBSTR(r_trx.trx_number_inv,1,1);
            EXCEPTION
             WHEN OTHERS THEN
                p_error_message := 'Error al obtener ID de Origen de Nota de Credito Interna. Error: '||SQLERRM;
                RAISE e_trx_exception;
            END;

            fnd_file.put_line(fnd_file.log,'Obtengo Tipo de Transaccion Interna');

            BEGIN

               select rctt.cust_trx_type_id
                into v_cust_trx_type_id_int
                from ra_cust_trx_types rctt
                    ,fnd_lookup_values_vl flv
               where 1 = 1
                 and rctt.name = flv.meaning
                 and NVL(TRUNC(rctt.start_date),TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
                 and NVL(TRUNC(rctt.end_date),TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                 and NVL(TRUNC(flv.start_date_active),TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
                 and NVL(TRUNC(flv.end_date_active),TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                 and flv.lookup_type = 'XX_AR_TAX_RETURN_SETUP'
                 and flv.lookup_code = 'INT_CUST_TRX_TYPE_'||SUBSTR(r_trx.trx_number_inv,1,1);

            EXCEPTION
              WHEN OTHERS THEN
                p_error_message := 'Error al obtener ID del Tipo de Transaccion de Nota de Credito Interna. Error: '||SQLERRM;
                RAISE e_cust_exception;
            END;

            fnd_file.put_line(fnd_file.log,'Obtengo Memo Line Interna');

            BEGIN

               select memo_line_id
                 into v_int_memo_line_id
                 from ar_memo_lines_vl aml
                 ,fnd_lookup_values_vl flv
                 where 1 = 1
                 and NVL(TRUNC(aml.start_date),TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
                 and NVL(TRUNC(aml.end_date),TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                 and NVL(TRUNC(flv.start_date_active),TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
                 and NVL(TRUNC(flv.end_date_active),TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                 and aml.name = flv.meaning
                 and flv.lookup_type = 'XX_AR_TAX_RETURN_SETUP'
                 and flv.lookup_code = 'INT_MEMO_LINE_ID';

            EXCEPTION
              WHEN OTHERS THEN
                p_error_message := 'Error al obtener ID del Memo Line para Nota de Credito Interna. Error: '||SQLERRM;
                RAISE e_trx_exception;
            END;

            BEGIN

            l_trx_header_tbl(1) := null;
            l_trx_header_tbl(1).trx_header_id             := r_trx.customer_trx_id;
            l_trx_header_tbl(1).bill_to_customer_id       := r_trx.bill_to_customer_id;
            l_trx_header_tbl(1).bill_to_site_use_id       := r_trx.bill_to_site_use_id;
            l_trx_header_tbl(1).ship_to_customer_id       := r_trx.ship_to_customer_id;
            l_trx_header_tbl(1).ship_to_site_use_id       := r_trx.ship_to_site_use_id;
            l_trx_header_tbl(1).bill_to_address_id        := r_trx.bill_to_address_id;
            l_trx_header_tbl(1).ship_to_address_id        := r_trx.ship_to_address_id;

            l_trx_header_tbl(1).trx_currency              := r_trx.invoice_currency_code;

            IF l_trx_header_tbl(1).trx_currency != 'ARS' THEN

                l_trx_header_tbl(1).exchange_date             := r_trx.exchange_date;
                l_trx_header_tbl(1).exchange_rate_type        := r_trx.exchange_rate_type;
                l_trx_header_tbl(1).exchange_rate             := r_trx.exchange_rate;

            END IF;

            l_trx_header_tbl(1).receipt_method_id         := r_trx.receipt_method_id;
            l_trx_header_tbl(1).comments                  := 'Devolucion Nota de Credito Interna para: '||r_trx.trx_number_inv;
            l_trx_header_tbl(1).paying_customer_id        := r_trx.paying_customer_id;
            l_trx_header_tbl(1).paying_site_use_id        := r_trx.paying_site_use_id;

            l_trx_header_tbl(1).trx_date                    :=  TRUNC(SYSDATE);
            l_trx_header_tbl(1).gl_date                     :=  TRUNC(SYSDATE);
            l_trx_header_tbl(1).org_id                      :=  r_trx.org_id;
            l_trx_header_tbl(1).status_trx                  := 'OP';
            l_trx_header_tbl(1).default_tax_exempt_flag     :=  NULL;
            l_trx_header_tbl(1).printing_option             := 'PRI';
            l_trx_header_tbl(1).global_attribute_category   := 'JL.AR.ARXTWMAI.TGW_HEADER';
            l_trx_header_tbl(1).interface_header_context    := 'XX_AR_DEVOLUCION_NC';
            l_trx_header_tbl(1).interface_header_attribute1 := r_trx.trx_number_nc;
            l_trx_header_tbl(1).interface_header_attribute2 := r_trx.customer_trx_id;
            l_trx_header_tbl(1).primary_salesrep_id         := r_trx.primary_salesrep_id;

            l_trx_header_tbl(1).cust_trx_type_id            := v_cust_trx_type_id_int;
            l_batch_source_rec.batch_source_id              := v_batch_source_id_int;

            IF p_debug = 'Y' THEN

                fnd_file.put_line(fnd_file.log,'l_trx_header_tbl(1).trx_header_id: '||l_trx_header_tbl(1).trx_header_id);
                fnd_file.put_line(fnd_file.log,'l_trx_header_tbl(1).bill_to_customer_id: '||l_trx_header_tbl(1).bill_to_customer_id);
                fnd_file.put_line(fnd_file.log,'l_trx_header_tbl(1).bill_to_site_use_id: '||l_trx_header_tbl(1).bill_to_site_use_id);
                fnd_file.put_line(fnd_file.log,'l_trx_header_tbl(1).ship_to_customer_id: '||l_trx_header_tbl(1).ship_to_customer_id);
                fnd_file.put_line(fnd_file.log,'l_trx_header_tbl(1).ship_to_site_use_id: '||l_trx_header_tbl(1).ship_to_site_use_id);
                fnd_file.put_line(fnd_file.log,'l_trx_header_tbl(1).bill_to_address_id: '||l_trx_header_tbl(1).bill_to_address_id);
                fnd_file.put_line(fnd_file.log,'l_trx_header_tbl(1).ship_to_address_id: '||l_trx_header_tbl(1).ship_to_address_id);
                fnd_file.put_line(fnd_file.log,'l_trx_header_tbl(1).trx_currency: '||l_trx_header_tbl(1).trx_currency);
                fnd_file.put_line(fnd_file.log,'l_trx_header_tbl(1).receipt_method_id: '||l_trx_header_tbl(1).receipt_method_id);
                fnd_file.put_line(fnd_file.log,'l_trx_header_tbl(1).comments: '||l_trx_header_tbl(1).comments);
                fnd_file.put_line(fnd_file.log,'l_trx_header_tbl(1).paying_customer_id: '||l_trx_header_tbl(1).paying_customer_id);
                fnd_file.put_line(fnd_file.log,'l_trx_header_tbl(1).paying_site_use_id: '||l_trx_header_tbl(1).paying_site_use_id);
                fnd_file.put_line(fnd_file.log,'l_trx_header_tbl(1).trx_date: '||l_trx_header_tbl(1).trx_date);
                fnd_file.put_line(fnd_file.log,'l_trx_header_tbl(1).gl_date: '||l_trx_header_tbl(1).gl_date);
                fnd_file.put_line(fnd_file.log,'l_trx_header_tbl(1).org_id: '||l_trx_header_tbl(1).org_id);
                fnd_file.put_line(fnd_file.log,'l_trx_header_tbl(1).status_trx: '||l_trx_header_tbl(1).status_trx);
                fnd_file.put_line(fnd_file.log,'l_trx_header_tbl(1).printing_option: '||l_trx_header_tbl(1).printing_option);
                fnd_file.put_line(fnd_file.log,'l_trx_header_tbl(1).global_attribute_category: '||l_trx_header_tbl(1).global_attribute_category);
                fnd_file.put_line(fnd_file.log,'l_trx_header_tbl(1).primary_salesrep_id: '||l_trx_header_tbl(1).primary_salesrep_id);
                fnd_file.put_line(fnd_file.log,'l_trx_header_tbl(1).cust_trx_type_id: '||l_trx_header_tbl(1).cust_trx_type_id);
                fnd_file.put_line(fnd_file.log,'l_batch_source_rec.batch_source_id: '||l_batch_source_rec.batch_source_id);

            END IF;

            v_dist_number := 1; --Reservo el uno para el total

           EXCEPTION
              WHEN OTHERS THEN
                 p_error_message := 'Error al completar campos de cabecera';
                 raise e_trx_exception;
           END;

           v_line_number := 0;
           v_int_amount := 0;

            FOR r_tax in c_tax (r_trx.inv_customer_trx_id,r_trx.cm_customer_trx_id) LOOP


                IF LENGTH(r_tax.tax_rate_code) > 30 THEN
                   fnd_file.put_line(fnd_file.log,'el impuesto: '||r_tax.tax_rate_code||' no se genera por error en el standard.');
                   CONTINUE;
                END IF;

                  fnd_file.put_line(fnd_file.log,'Obtengo el monto imponible de la Nota de Credito aplicada');
                   /*Obtengo el monto imponible de la Nota de Credito aplicada*/
                   BEGIN
                    SELECT sum(extended_amount)
                      INTO v_imp_amount
                      FROM ra_customer_trx_lines rctla
                     WHERE rctla.customer_trx_id = r_trx.cm_customer_trx_id
                       and rctla.interfacE_line_attribute3 = r_tax.link_to_cust_trx_line_id
                       AND rctla.line_type = 'LINE';
                   EXCEPTION
                    WHEN OTHERS THEN
                      p_error_message := 'Error al obtener el monto imponible';
                      RAISE e_trx_exception;
                   END;

                   fnd_file.put_line(fnd_file.log,'MONTO IMPONIBLE: '||v_imp_amount);

                  fnd_file.put_line(fnd_file.log,'Imp_amount: '||v_imp_amount);

                  IF r_tax.incl_iva  = 'Y' THEN

                    BEGIN

                       SELECT NVL(SUM(NVL(rctla_tax.extended_amount,0)),0)
                         into v_tax2_amount
                         from ra_customer_trx_lines_all rctla_tax
                             ,ar_vat_tax_all avt
                        where rctla_tax.customer_trx_id =  r_trx.cm_customer_trx_id
                          and line_type = 'TAX'
                          and rctla_tax.vat_tax_id = avt.vat_tax_id
                          and avt.global_attribute1 = 51
                          and rctla_tax.extendeD_amount != 0;
                    EXCEPTION
                     WHEN OTHERS THEN
                         v_tax2_amount := 0;
                    END;

                    fnd_file.put_line(fnd_file.log,'tax_amount: '||v_tax2_amount);

                     v_imp2_amount := v_imp_amount + v_tax2_amount;

                  ELSE
                     v_imp2_amount := v_imp_amount;
                  END IF;

                      fnd_file.put_line(fnd_file.log,'v_imp2_amount: '||v_imp2_amount);
                      fnd_file.put_line(fnd_file.log,'Calculado: '||ROUND((v_imp2_amount*r_tax.tax_rate)/100,2));

                  IF ROUND((v_imp2_amount*r_tax.tax_rate)/100,2) != 0 THEN
                       v_impo_amount := 0.01;
                       v_tax_amount := ROUND((v_imp2_amount*r_tax.tax_rate)/100,2)+0.01;
                  ELSE
                   v_impo_amount := 0;
                   v_tax_amount := 0;
                  END IF;

                  IF p_debug = 'Y' THEN
                    fnd_file.put_line(fnd_file.log,'v_impo_amount: '||v_impo_amount);
                    fnd_file.put_line(fnd_file.log,'v_tax_amount: '||v_tax_amount);
                  END IF;

                  v_line_number := v_line_number + 1;

                  l_trx_lines_tbl(v_line_number) := null;
                  l_trx_lines_tbl(v_line_number).trx_header_id               := r_trx.customer_trx_id;
                  l_trx_lines_tbl(v_line_number).line_number                 := v_line_number;
                  l_trx_lines_tbl(v_line_number).trx_line_id                 := r_tax.customer_trx_line_id;
                  l_trx_lines_tbl(v_line_number).line_type                   := 'LINE';

                  l_trx_lines_tbl(v_line_number).quantity_invoiced           := -1;
                  l_trx_lines_tbl(v_line_number).unit_selling_price          :=  v_impo_amount;
                  l_trx_lines_tbl(v_line_number).amount                      :=  v_impo_amount*-1;
                  v_int_amount := v_int_amount + l_trx_lines_tbl(v_line_number).amount;
                  l_trx_lines_tbl(v_line_number).description                 := 'Devolucion impuesto: '||r_tax.tax;
                  l_trx_lines_tbl(v_line_number).memo_line_id                := v_int_memo_line_id;
                  l_trx_lines_tbl(v_line_number).taxable_flag                := 'N';

                  l_trx_lines_tbl(v_line_number).interface_line_context       := 'XX_AR_DEVOLUCION_NC'; --l_line_data.interface_line_context;
                  l_trx_lines_tbl(v_line_number).interface_line_attribute1    := r_trx.trx_number_nc;
                  l_trx_lines_tbl(v_line_number).interface_line_attribute2    := r_trx.customer_trx_id; --l_line_data.interface_line_attribute2;
                  l_trx_lines_tbl(v_line_number).interface_line_attribute3    := r_tax.customer_trx_line_id; --l_line_data.interface_line_attribute3;
                  l_trx_lines_tbl(v_line_number).interface_line_attribute4    := v_interface_line_attribute3;
                  l_trx_lines_tbl(v_line_number).interface_line_attribute5    := -1;
                  l_trx_lines_tbl(v_line_number).vat_tax_id                   := r_tax.vat_tax_id;
                  l_trx_lines_tbl(v_line_number).tax_exempt_flag              := 'S';


                  IF p_debug = 'Y' THEN

                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').trx_header_id: '||l_trx_lines_tbl(v_line_number).trx_header_id);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').line_number: '||l_trx_lines_tbl(v_line_number).line_number);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').trx_line_id: '||l_trx_lines_tbl(v_line_number).trx_line_id);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').line_type: '||l_trx_lines_tbl(v_line_number).line_type);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').quantity_invoiced: '||l_trx_lines_tbl(v_line_number).quantity_invoiced);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').unit_selling_price: '||l_trx_lines_tbl(v_line_number).unit_selling_price);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').amount: '||l_trx_lines_tbl(v_line_number).amount);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').description: '||l_trx_lines_tbl(v_line_number).description);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').memo_line_id: '||l_trx_lines_tbl(v_line_number).memo_line_id);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').taxable_flag: '||l_trx_lines_tbl(v_line_number).taxable_flag);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').interface_line_context: '||l_trx_lines_tbl(v_line_number).interface_line_context);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').interface_line_attribute1: '||l_trx_lines_tbl(v_line_number).interface_line_attribute1);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').interface_line_attribute2: '||l_trx_lines_tbl(v_line_number).interface_line_attribute2);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').interface_line_attribute3: '||l_trx_lines_tbl(v_line_number).interface_line_attribute3);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').interface_line_attribute4: '||l_trx_lines_tbl(v_line_number).interface_line_attribute4);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').interface_line_attribute5: '||l_trx_lines_tbl(v_line_number).interface_line_attribute5);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').vat_tax_id: '||l_trx_lines_tbl(v_line_number).vat_tax_id);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').tax_exempt_flag: '||l_trx_lines_tbl(v_line_number).tax_exempt_flag);

                  END IF;

                  FOR r_dist IN c_dist (r_trx.inv_customer_trx_id,r_tax.customer_trx_line_id) LOOP

                        v_dist_number := v_dist_number + 1;

                        l_trx_dist_tbl(v_dist_number) := null;
                        l_trx_dist_tbl(v_dist_number).trx_header_id               := r_tax.inv_customer_trx_id;
                        l_trx_dist_tbl(v_dist_number).trx_line_id                 := r_dist.customer_trx_line_id;
                        l_trx_dist_tbl(v_dist_number).trx_dist_id                 := r_dist.cust_trx_line_gl_dist_id;
                        l_trx_dist_tbl(v_dist_number).account_class               := 'REV';
                        l_trx_dist_tbl(v_dist_number).percent                     := r_dist.percent;
                        l_trx_dist_tbl(v_dist_number).code_combination_id         := r_dist.code_combination_id;
                        l_trx_dist_tbl(v_dist_number).amount                      := l_trx_lines_tbl(v_line_number).amount;

                        IF p_debug = 'Y' THEN

                            fnd_file.put_line(fnd_file.log,'l_trx_dist_tbl('||v_dist_number||').trx_dist_id: '||l_trx_dist_tbl(v_dist_number).trx_dist_id);
                            fnd_file.put_line(fnd_file.log,'l_trx_dist_tbl('||v_dist_number||').trx_line_id: '||l_trx_dist_tbl(v_dist_number).trx_line_id);
                            fnd_file.put_line(fnd_file.log,'l_trx_dist_tbl('||v_dist_number||').trx_header_id: '||l_trx_dist_tbl(v_dist_number).trx_header_id);
                            fnd_file.put_line(fnd_file.log,'l_trx_dist_tbl('||v_dist_number||').account_class: '||l_trx_dist_tbl(v_dist_number).account_class);
                            fnd_file.put_line(fnd_file.log,'l_trx_dist_tbl('||v_dist_number||').percent: '||l_trx_dist_tbl(v_dist_number).percent);
                            fnd_file.put_line(fnd_file.log,'l_trx_dist_tbl('||v_dist_number||').code_combination_id: '||l_trx_dist_tbl(v_dist_number).code_combination_id);
                            fnd_file.put_line(fnd_file.log,'l_trx_dist_tbl('||v_dist_number||').amount: '||l_trx_dist_tbl(v_dist_number).amount);

                        END IF;

                  END LOOP;

                  /*Cargo su impuesto*/
                  v_line_number := v_line_number + 1;
                  l_trx_lines_tbl(v_line_number) := null;

                  l_trx_lines_tbl(v_line_number).trx_header_id               := r_tax.inv_customer_trx_id; --Multiplicao por 10 para no mezclar con la no interna
                  l_trx_lines_tbl(v_line_number).line_number                 := v_line_number;
                  l_trx_lines_tbl(v_line_number).trx_line_id                 := 10*r_tax.customer_trx_line_id;
                  l_trx_lines_tbl(v_line_number).line_type                   := 'TAX';
                  l_trx_lines_tbl(v_line_number).amount                      := v_tax_amount;
                  v_int_amount := v_int_amount + l_trx_lines_tbl(v_line_number).amount;

                  l_trx_lines_tbl(v_line_number).tax_rate                     := r_tax.tax_rate;
                  l_trx_lines_tbl(v_line_number).tax_regime_code              := r_tax.tax_regime_code;
                  l_trx_lines_tbl(v_line_number).tax                          := r_tax.tax;
                  l_trx_lines_tbl(v_line_number).tax_status_code              := r_tax.tax_status_code;
                  l_trx_lines_tbl(v_line_number).tax_rate_code                := r_tax.tax_rate_code;
                      ------DATOS ASOCIACION
                  l_trx_lines_tbl(v_line_number).link_to_trx_line_id          := r_tax.customer_trx_line_id;

                  IF p_debug = 'Y' THEN

                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').trx_header_id: '||l_trx_lines_tbl(v_line_number).trx_header_id);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').line_number: '||l_trx_lines_tbl(v_line_number).line_number);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').trx_line_id: '||l_trx_lines_tbl(v_line_number).trx_line_id);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').line_type: '||l_trx_lines_tbl(v_line_number).line_type);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').amount: '||l_trx_lines_tbl(v_line_number).amount);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').tax_rate: '||l_trx_lines_tbl(v_line_number).tax_rate);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').tax_regime_code: '||l_trx_lines_tbl(v_line_number).tax_regime_code);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').tax: '||l_trx_lines_tbl(v_line_number).tax);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').tax_status_code: '||l_trx_lines_tbl(v_line_number).tax_status_code);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').tax_rate_code: '||l_trx_lines_tbl(v_line_number).tax_rate_code);
                      fnd_file.put_line(fnd_file.log,'l_trx_lines_tbl('||v_line_number||').link_to_trx_line_id: '||l_trx_lines_tbl(v_line_number).link_to_trx_line_id);
                    END IF;

                  FOR r_dist IN c_dist (r_trx.inv_customer_trx_id,r_tax.customer_trx_line_id) LOOP

                        v_dist_number := v_dist_number + 1;
                        l_trx_dist_tbl(v_dist_number) := null;
                        l_trx_dist_tbl(v_dist_number).trx_header_id               := r_tax.inv_customer_trx_id;
                        l_trx_dist_tbl(v_dist_number).trx_line_id                 := 10*r_dist.customer_trx_line_id;
                        l_trx_dist_tbl(v_dist_number).trx_dist_id                 := 10*r_dist.cust_trx_line_gl_dist_id;
                        l_trx_dist_tbl(v_dist_number).account_class               := 'TAX';
                        l_trx_dist_tbl(v_dist_number).percent                     := r_dist.percent;
                        l_trx_dist_tbl(v_dist_number).code_combination_id         := r_dist.code_combination_id;
                        l_trx_dist_tbl(v_dist_number).amount                      := l_trx_lines_tbl(v_line_number).amount;

                        IF p_debug = 'Y' THEN

                            fnd_file.put_line(fnd_file.log,'l_trx_dist_tbl('||v_dist_number||').trx_dist_id: '||l_trx_dist_tbl(v_dist_number).trx_dist_id);
                            fnd_file.put_line(fnd_file.log,'l_trx_dist_tbl('||v_dist_number||').trx_line_id: '||l_trx_dist_tbl(v_dist_number).trx_line_id);
                            fnd_file.put_line(fnd_file.log,'l_trx_dist_tbl('||v_dist_number||').trx_header_id: '||l_trx_dist_tbl(v_dist_number).trx_header_id);
                            fnd_file.put_line(fnd_file.log,'l_trx_dist_tbl('||v_dist_number||').account_class: '||l_trx_dist_tbl(v_dist_number).account_class);
                            fnd_file.put_line(fnd_file.log,'l_trx_dist_tbl('||v_dist_number||').percent: '||l_trx_dist_tbl(v_dist_number).percent);
                            fnd_file.put_line(fnd_file.log,'l_trx_dist_tbl('||v_dist_number||').code_combination_id: '||l_trx_dist_tbl(v_dist_number).code_combination_id);
                            fnd_file.put_line(fnd_file.log,'l_trx_dist_tbl('||v_dist_number||').amount: '||l_trx_dist_tbl(v_dist_number).amount);

                        END IF;

                  END LOOP;

            END LOOP;

            FOR r_dist IN c_dist (r_trx.inv_customer_trx_id,null) LOOP

                v_dist_number := 1;
                l_trx_dist_tbl(v_dist_number) := null;
                l_trx_dist_tbl(v_dist_number).trx_dist_id                 := 1;
                l_trx_dist_tbl(v_dist_number).trx_line_id                 := null;
                l_trx_dist_tbl(v_dist_number).trx_header_id               := r_trx.inv_customer_trx_id;
                l_trx_dist_tbl(v_dist_number).account_class               := r_dist.account_class;
                l_trx_dist_tbl(v_dist_number).percent                     := r_dist.percent;
                l_trx_dist_tbl(v_dist_number).code_combination_id         := r_dist.code_combination_id;
                l_trx_dist_tbl(v_dist_number).amount                      := v_int_amount;

                IF p_debug = 'Y' THEN

                    fnd_file.put_line(fnd_file.log,'l_trx_dist_tbl('||v_dist_number||').trx_dist_id: '||l_trx_dist_tbl(v_dist_number).trx_dist_id);
                    fnd_file.put_line(fnd_file.log,'l_trx_dist_tbl('||v_dist_number||').trx_line_id: '||l_trx_dist_tbl(v_dist_number).trx_line_id);
                    fnd_file.put_line(fnd_file.log,'l_trx_dist_tbl('||v_dist_number||').trx_header_id: '||l_trx_dist_tbl(v_dist_number).trx_header_id);
                    fnd_file.put_line(fnd_file.log,'l_trx_dist_tbl('||v_dist_number||').account_class: '||l_trx_dist_tbl(v_dist_number).account_class);
                    fnd_file.put_line(fnd_file.log,'l_trx_dist_tbl('||v_dist_number||').percent: '||l_trx_dist_tbl(v_dist_number).percent);
                    fnd_file.put_line(fnd_file.log,'l_trx_dist_tbl('||v_dist_number||').code_combination_id: '||l_trx_dist_tbl(v_dist_number).code_combination_id);
                    fnd_file.put_line(fnd_file.log,'l_trx_dist_tbl('||v_dist_number||').amount: '||l_trx_dist_tbl(v_dist_number).amount);

                END IF;

            END LOOP;


            BEGIN

                AR_INVOICE_API_PUB.create_single_invoice( p_api_version          => 1.0,
                                                          p_batch_source_rec     => l_batch_source_rec,
                                                          p_trx_header_tbl       => l_trx_header_tbl,
                                                          p_trx_lines_tbl        => l_trx_lines_tbl,
                                                          p_trx_dist_tbl         => l_trx_dist_tbl,
                                                          p_trx_salescredits_tbl => l_trx_salescredits_tbl,
                                                          x_customer_trx_id      => x_customer_trx_id,
                                                          x_return_status        => l_return_status,
                                                          x_msg_count            => l_msg_count,
                                                          x_msg_data             => l_msg_data);

            EXCEPTION
              WHEN OTHERS THEN
                 p_error_message := 'Error al ejecutar API para Creacion de NC Interna';
                 raise e_trx_exception;
            END;

            BEGIN

               FND_FILE.PUT_LINE(FND_FILE.LOG,'Estado: '||l_return_status);

                SELECT count(*)
                  INTO   l_cnt
                  FROM   ar_trx_header_gt;

              IF l_cnt != 0 THEN
                 FOR i in list_headers LOOP
                     FND_FILE.PUT_LINE(FND_FILE.LOG,'customer_trx_id: '||i.customer_trx_id);
                 END LOOP;
              END IF;

              SELECT count(*)
              INTO   l_cnt
              FROM   ar_trx_errors_gt;

              IF l_cnt != 0 THEN

                 FOR i in list_errors LOOP
                     fnd_file.put_line(fnd_file.log,i.error_message);
                     p_mesg_error := p_mesg_error ||' - '||i.error_message;
                 END LOOP;
                 p_error_message := p_mesg_error;
                 RAISE e_api_exception;
              ELSE

                BEGIN

                        SELECT trx_number
                        INTO x_trx_number
                        FROM ra_customer_trx
                        WHERE customer_trx_id = x_customer_trx_id;

                EXCEPTION
                 WHEN OTHERS THEN
                   x_trx_number := null;
                END;

              END IF;

              IF x_trx_number is null and l_return_status  = 'S' then
                p_error_message := 'Error al crear la Nota de Credito Interna';
                RAISE e_api_exception;
              ELSE
                fnd_file.put_line(fnd_file.log,'Nota de Credito Interna: '||x_trx_number);
                commit;
              END IF;

            EXCEPTION
              WHEN e_api_exception THEN
                 raise e_trx_exception;
              WHEN OTHERS THEN
                 p_error_message := 'Error al verificar resultado API';
                 raise e_trx_exception;
            END;

            fnd_file.put_line(fnd_file.output,'');
            fnd_file.put_line(fnd_file.output,'ORIGEN NC INTERNA: '||v_batch_source_name_int);
            fnd_file.put_line(fnd_file.output,'NRO TRX NC INTERNA:'||x_trx_number);
            fnd_file.put_line(fnd_file.output,'');

            fnd_file.put_line(fnd_file.log,'Comienzo aplicacion');

            IF x_customer_trx_id is not null and x_trx_number is not null then

             BEGIN

                select payment_schedule_id
                into v_inv_payment_schedule
                from ar_payment_schedules ps
                where ps.customer_trx_id = r_trx.inv_customer_trx_id;

                select payment_schedule_id
                into v_cm_payment_schedule
                from ar_payment_schedules ps
                where ps.customer_trx_id = x_customer_trx_id;

             EXCEPTION
               WHEN OTHERS THEN
                  p_error_message := 'Error al obtener datos primarios para realizar las Aplicaciones (Payment_schedule_id). Error: '||SQLERRM;
                  RAISE e_trx_exception;
             END;

            BEGIN

              arp_process_application.cm_application(
                p_cm_ps_id                  => v_cm_payment_schedule,
                p_invoice_ps_id             => v_inv_payment_schedule,
                p_amount_applied            => v_int_amount*-1,
                p_apply_date                => TRUNC(SYSDATE),
                p_gl_date                   => TRUNC(SYSDATE),
                p_ussgl_transaction_code    => v_ussgl_transaction_code, -- NULL
                p_attribute_category        => v_null_flex, -- NULL
                p_attribute1                => v_null_flex, -- NULL
                p_attribute2                => v_null_flex, -- NULL
                p_attribute3                => v_null_flex, -- NULL
                p_attribute4                => v_null_flex, -- NULL
                p_attribute5                => v_null_flex, -- NULL
                p_attribute6                => v_null_flex, -- NULL
                p_attribute7                => v_null_flex, -- NULL
                p_attribute8                => v_null_flex, -- NULL
                p_attribute9                => v_null_flex, -- NULL
                p_attribute10               => v_null_flex, -- NULL
                p_attribute11               => v_null_flex, -- NULL
                p_attribute12               => v_null_flex, -- NULL
                p_attribute13               => v_null_flex, -- NULL
                p_attribute14               => v_null_flex, -- NULL
                p_attribute15               => v_null_flex, -- NULL
                p_global_attribute_category => v_null_flex, -- NULL
                p_global_attribute1         => v_null_flex, -- NULL
                p_global_attribute2         => v_null_flex, -- NULL
                p_global_attribute3         => v_null_flex, -- NULL
                p_global_attribute4         => v_null_flex, -- NULL
                p_global_attribute5         => v_null_flex, -- NULL
                p_global_attribute6         => v_null_flex, -- NULL
                p_global_attribute7         => v_null_flex, -- NULL
                p_global_attribute8         => v_null_flex, -- NULL
                p_global_attribute9         => v_null_flex, -- NULL
                p_global_attribute10        => v_null_flex, -- NULL
                p_global_attribute11        => v_null_flex, -- NULL
                p_global_attribute12        => v_null_flex, -- NULL
                p_global_attribute13        => v_null_flex, -- NULL
                p_global_attribute14        => v_null_flex, -- NULL
                p_global_attribute15        => v_null_flex, -- NULL
                p_global_attribute16        => v_null_flex, -- NULL
                p_global_attribute17        => v_null_flex, -- NULL
                p_global_attribute18        => v_null_flex, -- NULL
                p_global_attribute19        => v_null_flex, -- NULL
                p_global_attribute20        => v_null_flex, -- NULL
                p_customer_trx_line_id      => NULL,
                p_comments                  => 'XXARCTTR',
                p_module_name               => NULL,
                p_module_version            => '1.0',
                p_out_rec_application_id    => v_out_rec_application_id,
                p_acctd_amount_applied_from => v_acctd_amount_applied_from,
                p_acctd_amount_applied_to   => v_acctd_amount_applied_from
              );

              COMMIT;
              fnd_file.put_line(fnd_file.output,'NOTA DE CREDITO INTERNA '||x_trx_number||' APLICADA');
              fnd_file.put_line(fnd_file.output,'');
              fnd_file.put_line(fnd_file.output,'--------------------------------------------');

            EXCEPTION
             WHEN OTHERS THEN
              p_error_message := 'Error en Aplicacion de Nota de Credito interna: '||x_trx_number||' .Error: '||SQLERRM;
              fnd_file.put_line(fnd_file.output,p_error_message);
              fnd_file.put_line(fnd_file.output,'');
              fnd_file.put_line(fnd_file.output,'--------------------------------------------');
              RAISE e_trx_exception;
            END;

           END IF;

        EXCEPTION
          WHEN e_trx_exception THEN
            fnd_file.put_line(fnd_file.log,p_error_message);
            if x_trx_number is null then
              ROLLBACK TO S_TRX;
            end if;
            p_status := 'W';
        END;

    END LOOP;

    IF p_status IS NULL THEN
     p_status := 'S';
    ELSE
     RAISE e_cust_exception;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'XX_AR_TAX_RETURN_NC_PKG.CREATE_INT (-)');

EXCEPTION
 WHEN e_cust_exception THEN
   p_status := 'W';
   fnd_file.put_line(fnd_file.log,p_error_message);
   fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.CREATE_INT (!)');
 WHEN OTHERS THEN
   p_status := 'W';
   p_error_message := 'Error OTHERS en CREATE_INT. Error: '||SQLERRM;
   fnd_file.put_line(fnd_file.log,p_error_message);
   fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.CREATE_INT (!)');
END;

PROCEDURE PROCESS_INT      (errbuf                 OUT VARCHAR2
                           ,retcode                OUT NUMBER
                           ,p_date_from            IN  VARCHAR2
                           ,p_date_to              IN  VARCHAR2
                           ,p_period_name          IN  VARCHAR2
                           ,p_debug                IN  VARCHAR2) IS

v_status        VARCHAR2(1);
v_error_message VARCHAR2(2000);

e_cust_exception EXCEPTION;

BEGIN

      fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.PROCESS_INT (+)');

      create_int (p_status => v_status
                 ,p_error_message => v_error_message
                 ,p_date_from => p_date_from
                 ,p_date_to => p_date_to
                 ,p_period_name => p_period_name
                 ,p_debug => p_debug);

      IF v_status != 'S' THEN
        RAISE e_cust_exception;
      END IF;

      fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.PROCESS_INT (-)');

EXCEPTION
   WHEN e_cust_exception THEN
       retcode := 1;
       errbuf := v_error_message;
       fnd_file.put_line(fnd_file.log,errbuf);
       fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.PROCESS_INT (!)');
   WHEN OTHERS THEN
       retcode := 2;
       errbuf := 'Error OTHERS en MAIN_PROCESS. Error: '||SQLERRM;
       fnd_file.put_line(fnd_file.log,errbuf);
       fnd_file.put_line(fnd_file.log,'XX_AR_TAX_RETURN_NC_PKG.PROCESS_INT (!)');
END;

END XX_AR_TAX_RETURN_NC_PKG;
/
EXIT