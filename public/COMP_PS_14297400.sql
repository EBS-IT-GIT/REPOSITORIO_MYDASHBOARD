declare
l_applied_commitment_amt NUMBER;
begin

    update apps.ra_customer_trx_all
       set complete_flag = 'Y'
     where customer_trx_id = 14297400;

    commit;

     arp_maintain_ps.maintain_payment_schedules(
                    'I',
                    14297400,
                    NULL,   -- ps_id
                    NULL,   -- line_amount
                    NULL,   -- tax_amount
                    NULL,   -- frt_amount
                    NULL,   -- charge_amount
                    l_applied_commitment_amt);
                    
     commit;
                    
END;
/
EXIT