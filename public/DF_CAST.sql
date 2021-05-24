DELETE jl_zz_ap_sup_awt_cd_all jzasaca
WHERE SUPP_AWT_CODE_ID IN (
    SELECT SUPP_AWT_CODE_ID
    FROM jl_zz_ap_supp_awt_types jzasat
        ,jl_zz_ap_sup_awt_cd_all jzasaca
        ,ap_tax_codes_all atc
        ,po_vendors pv
    WHERE jzasat.supp_awt_type_id = jzasaca.supp_awt_type_id
    AND jzasaca.tax_id = atc.tax_id
    AND name = 'RTU_NI'
    AND jzasat.awt_type_code = 'RIBB_TU'
    AND jzasat.vendor_id = pv.vendor_id);
    --14062 Rows
    EXIT
 
