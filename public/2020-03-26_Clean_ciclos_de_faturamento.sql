delete from FMB_DENERGIA.d_bill_items
where   d_bill_id in (
            select  d_bill_id
            from    FMB_DENERGIA.d_invoices 
            where   deleted_date is null and
                    grupo_pre_fatura_id in (
                        select id from FMB_DENERGIA.grupo_pre_faturas where to_char(base_date, 'YYYY-MM') >= '2020-04' and deleted_date is null
                    ) and
                    id not in (
                        select integracao_erps.d_invoices_id from FMB_DENERGIA.integracao_erps where to_char(base_date, 'YYYY-MM') >= '2020-04'
                    )
        );

delete from FMB_DENERGIA.payment_alocation 
where d_payment_maturities_id in (
    select  id
    from    FMB_DENERGIA.d_payment_maturities 
    where   d_invoice_id in (
                select  id
                from    FMB_DENERGIA.d_invoices 
                where   deleted_date is null and
                        grupo_pre_fatura_id in (
                            select id from FMB_DENERGIA.grupo_pre_faturas where to_char(base_date, 'YYYY-MM') >= '2020-04' and deleted_date is null
                        ) and
                        id not in (
                            select integracao_erps.d_invoices_id from FMB_DENERGIA.integracao_erps where to_char(base_date, 'YYYY-MM') >= '2020-04'
                        )
            )
);

        
delete from FMB_DENERGIA.d_payment_maturities 
where   d_invoice_id in (
            select  id
            from    FMB_DENERGIA.d_invoices 
            where   deleted_date is null and
                    grupo_pre_fatura_id in (
                        select id from FMB_DENERGIA.grupo_pre_faturas where to_char(base_date, 'YYYY-MM') >= '2020-04' and deleted_date is null
                    ) and
                    id not in (
                        select integracao_erps.d_invoices_id from FMB_DENERGIA.integracao_erps where to_char(base_date, 'YYYY-MM') >= '2020-04'
                    )
        );

update FMB_DENERGIA.d_bills set deleted = 1, deleted_date = sysdate
where   id in (
            select  d_bill_id
            from    FMB_DENERGIA.d_invoices 
            where   deleted_date is null and
                    grupo_pre_fatura_id in (
                        select id from FMB_DENERGIA.grupo_pre_faturas where to_char(base_date, 'YYYY-MM') >= '2020-04' and deleted_date is null
                    ) and
                    id not in (
                        select integracao_erps.d_invoices_id from FMB_DENERGIA.integracao_erps where to_char(base_date, 'YYYY-MM') >= '2020-04'
                    )
        );

update fmb_denergia.d_invoices set deleted = 1, deleted_date = sysdate
where   deleted_date is null and
        grupo_pre_fatura_id in (
            select id from fmb_denergia.grupo_pre_faturas where to_char(base_date, 'YYYY-MM') >= '2020-04' and deleted_date is null
        ) and
        id not in (
            select integracao_erps.d_invoices_id from FMB_DENERGIA.integracao_erps where to_char(base_date, 'YYYY-MM') >= '2020-04'
        );

commit;