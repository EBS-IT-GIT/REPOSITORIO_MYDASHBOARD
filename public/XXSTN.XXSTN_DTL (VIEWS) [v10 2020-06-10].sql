CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_ACCOUNTING_BOOK AS
--LIVROS CONTABEIS (SET_OF_BOOKS)
    SELECT
--IDENTIFICATION        
        ldg.ledger_id                      AS accounting_book_id,
--CHARTS RELATIONS        
        ldg.chart_of_accounts_id,
--SEGMENT PROPERTIES        
        ldg.bal_seg_value_set_id           AS segment_id,
        ldg.bal_seg_column_name            AS segment_column,
        ldg.ret_earn_code_combination_id   AS retained_account_reference_id,
--DESCRIPTION          
        ldg.name                           AS book_name,
        ldg.short_name                     AS book_short_name,
        ldg.description                    AS book_description,
--MAIN PROPERTIES        
        ldg.currency_code,
        ldg.ledger_category_code           AS book_category_code,
--BOOK ATTRIBUTES
        ldg.ledger_attributes              AS book_attributes,
        ldg.object_type_code               AS book_type_code,
        ldg.le_ledger_type_code            AS book_legal_type_code,
--PERIOD PROPERTIES        
        ldg.period_set_name,
        ldg.accounted_period_type,
        ldg.first_ledger_period_name,
        ldg.latest_opened_period_name,
        ldg.latest_encumbrance_year,
        ldg.future_enterable_periods_limit,
--SECURITY        
        ldg.implicit_access_set_id,
--LINEAGE          
        TO_TIMESTAMP(TO_CHAR(ldg.last_update_date, 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        ldg.last_updated_by,
        TO_TIMESTAMP(TO_CHAR(ldg.creation_date, 'DD-MON-RR HH:MI:SS AM')) AS creation_date,
        ldg.created_by,
        ldg.last_update_login
    FROM
        gl.gl_ledgers ldg
    ;
	

----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_ACCOUNTING_CALENDAR AS
    SELECT 
--IDENTIFIER
        ps.period_set_id     AS calendar_id,
        ps.period_set_name   AS calendar_name,    
--DESCRIPTION
        ps.description       AS calendar_description,
--SECURITY    
        ps.security_flag     AS is_secure,
--LINEAGE 
        TO_TIMESTAMP(TO_CHAR(ps.last_update_date, 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        ps.last_updated_by,
        TO_TIMESTAMP(TO_CHAR(ps.creation_date, 'DD-MON-RR HH:MI:SS AM')) AS creation_date,
        ps.created_by,
        ps.last_update_login
    FROM
        gl.gl_period_sets ps
    ;
	
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD AS
--FIRST PERIOD 31-JAN-10
--LAST PEDIOD 31-DEC-25
    SELECT 
--IDENTIFICATION   
        gps.ledger_id                AS accounting_book_id,
        gps.application_id,
        gps.period_name,   
--DESCRIPTION     
        gps.start_date,
        gps.end_date,
        gps.effective_period_num,
        gps.closing_status,
--MAIN PROPERTIES              
        gps.period_num,
        gps.period_type,
        gps.period_year,
        gps.year_start_date,
        gps.quarter_num,
        gps.quarter_start_date,  
--PROPERTIES            
        gps.adjustment_period_flag   AS is_adjustment_period,
        gps.elimination_confirmed_flag AS is_elimination_confirmed,
        gps.migration_status_code,
--LINEAGE          
        TO_TIMESTAMP(TO_CHAR(gps.last_update_date, 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        gps.last_updated_by,
        TO_TIMESTAMP(TO_CHAR(gps.creation_date, 'DD-MON-RR HH:MI:SS AM')) AS creation_date,
        gps.created_by,
        gps.last_update_login
    FROM
        gl.gl_period_statuses gps        
    ;

----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE AS
--CODE COMBINATION
    SELECT
--IDENTIFICATION 
        c.code_combination_id            As accounting_reference_id,
--RELATIONSHIP      
        c.chart_of_accounts_id,
--DESCRIPTION    
        c.padded_concatenated_segments   AS accounting_reference,
        c.segment1,
        c.segment2,
        c.segment3,
        c.segment4,
        c.segment5,
        c.segment6,
        c.segment7,
        c.segment8,
--VALIDITY         
        c.enabled_flag                   AS is_enabled,
        c.start_date_active,
        c.end_date_active,
--PROPERTIES
        c.summary_flag                   AS is_summary,
        c.gl_account_type                AS account_type,
        c.gl_control_account             AS is_control_account,
        c.reconciliation_flag            AS is_reconciliation,
        c.detail_budgeting_allowed       AS is_budgeting_allowed,
        c.detail_posting_allowed         AS is_posting_allowed,
        c.igi_balanced_budget_flag       AS is_budget_enforced,
--LINEAGE 
        TO_TIMESTAMP(TO_CHAR(c.last_update_date, 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        c.last_updated_by
    FROM
        apps.gl_code_combinations_kfv c        
        ;
		
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_ACCOUNTING_SEGMENT AS
--SEGMENTOS CONTABEIS
    SELECT 
--IDENTIFICATION          
        fsg.flex_value_set_id         AS segment_id,
--RELATIONSHIP
        fsg.id_flex_num               AS chart_of_accounts_id,      
--DESCRIPTION          
        fsg.segment_num,
        fsg.application_column_name   AS segment_column,
        fsg.segment_name,
--VALIDITY         
        fsg.enabled_flag              AS is_enabled,
--PROPERTIES           
        fsg.required_flag             AS is_required,
        fsg.security_enabled_flag     AS is_secure,
        fsg.display_flag              AS is_displayed,
        fsg.display_size,
--LINEAGE     
        TO_TIMESTAMP(TO_CHAR(fsg.last_update_date, 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        fsg.last_updated_by,
        TO_TIMESTAMP(TO_CHAR(fsg.creation_date, 'DD-MON-RR HH:MI:SS AM')) AS creation_date,
        fsg.created_by,
        fsg.last_update_login
    FROM
        applsys.fnd_id_flex_segments fsg
    WHERE
        fsg.application_id = 101 --GL Application
        AND fsg.id_flex_code = 'GL#' --GL Module     
        ;
		
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_ACCOUNT_BALANCE AS
    SELECT 
--IDENTIFICATION 
		b.ledger_id             AS accounting_book_id,
        b.code_combination_id   AS accounting_reference_id,
--RELATIONSHIP		
        b.currency_code,
        b.period_name,
--DESCRIPTION 
        b.period_type,
        b.period_year,
        b.period_num,
--PROPERTIES
        b.actual_flag           AS balance_type,
        b.translated_flag       AS is_translated, 
--BALANCE VALUES
        b.period_net_dr,
        b.period_net_cr,
        b.quarter_to_date_dr,
        b.quarter_to_date_cr,
        b.project_to_date_dr,
        b.project_to_date_cr,
        b.begin_balance_dr,
        b.begin_balance_cr,
--LINEAGE 
        TO_TIMESTAMP(TO_CHAR(b.last_update_date, 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        b.last_updated_by
    FROM
        gl.gl_balances b    
        ;
		
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_ACCOUNT_UNIT AS
--CONTA CONTABIL
    SELECT      
--IDENTIFICATION         
        fv.flex_value_id           AS account_unit_id,
--RELATIONSHIP         
        fvs.id_flex_num            AS chart_of_accounts_id,
        fv.flex_value_set_id       AS segment_id,
        fvs.segment_num,
        fvs.segment_name,
        fset.flex_value_set_name   AS category_name,
--DESCRIPTION        
        fv.flex_value              AS account_unit,
        ptb.description            AS account_name_ptb,
        us.description             AS account_name_us,
--VALIDITY         
        fv.enabled_flag            AS is_enabled,
        fv.start_date_active,
        fv.end_date_active,
--PROPERTIES          
        fv.summary_flag            AS is_summary,
        substr(fv.compiled_value_attributes, 1, 1) AS is_budgeting_allowed,
        substr(fv.compiled_value_attributes, 3, 1) AS is_posting_allowed,
        substr(fv.compiled_value_attributes, 5, 1) AS account_type,
        substr(fv.compiled_value_attributes, 7, 1) AS is_third_party_control,
        substr(fv.compiled_value_attributes, 9, 1) AS is_reconcile,
        fv.attribute1,
--LINEAGE        
        to_timestamp(to_char(greatest(
                                    fv.last_update_date, 
                                    fvs.last_update_date, 
                                    fset.last_update_date, 
                                    ptb.last_update_date,
                                    us.last_update_date), 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        fv.last_updated_by,
        to_timestamp(to_char(fv.creation_date, 'DD-MON-RR HH:MI:SS AM')) AS creation_date,
        fv.created_by,
        fv.last_update_login
    FROM
        apps.fnd_flex_values           fv
        JOIN applsys.fnd_id_flex_segments   fvs ON fv.flex_value_set_id = fvs.flex_value_set_id
        JOIN applsys.fnd_flex_values_tl     ptb ON ptb.flex_value_id = fv.flex_value_id
                                               AND ptb.language = 'PTB'
        JOIN applsys.fnd_flex_values_tl     us ON us.flex_value_id = fv.flex_value_id
                                              AND us.language = 'US'
        JOIN applsys.fnd_flex_value_sets    fset ON fset.flex_value_set_id = fvs.flex_value_set_id
    WHERE
        fvs.application_id = 101 --GL Application
        AND fvs.id_flex_code = 'GL#' --GL Module                
        AND ( ( fvs.segment_num = 4
                AND fvs.id_flex_num <> 50408 ) --(NOT COSIF)
              OR ( fvs.segment_num = 3
                   AND fvs.id_flex_num = 50408 ) ) --(COSIF-IFRS)            
                   ;
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_APPLICATION AS
    SELECT
--IDENTIFICATION      
        app.application_id,
--DESCRIPTION      
        app.application_short_name,        
        app.product_code,
        ptb.application_name   AS application_name_ptb,
        us.application_name    AS application_name_us,  
--LINEAGE 
        to_timestamp(to_char(greatest(
                                    app.last_update_date, 
                                    ptb.last_update_date,
                                    us.last_update_date), 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        app.last_updated_by,
        to_timestamp(to_char(app.creation_date, 'DD-MON-RR HH:MI:SS AM')) AS creation_date,
        app.created_by,
        app.last_update_login
    FROM
        applsys.fnd_application      app
        JOIN applsys.fnd_application_tl   ptb ON app.application_id = ptb.application_id
                                               AND ptb.source_lang = 'PTB'
        JOIN applsys.fnd_application_tl   us ON app.application_id = us.application_id
                                              AND us.source_lang = 'US'
    WHERE
        app.application_id IN (
            SELECT DISTINCT
                application_id
            FROM
                gl.gl_period_statuses
        );
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_APPLICATION_USERS AS
    SELECT 
--IDENTIFICATION   
        u.user_id,   
--DESCRIPTION     
        u.user_name,
        u.description as full_name,
--VALIDITY
        u.start_date,
        u.end_date,
--RELATIONSHIP
        u.employee_id,
        CASE
            WHEN instr(u.email_address, '@') = 0 THEN
                NULL
            ELSE
                replace(u.email_address, 'CLONE.', '')
        END AS email_address,
        u.customer_id,
        u.person_party_id, 
--LINEAGE          
        TO_TIMESTAMP(TO_CHAR(u.last_update_date, 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        u.last_updated_by,
        TO_TIMESTAMP(TO_CHAR(u.creation_date, 'DD-MON-RR HH:MI:SS AM')) AS creation_date,
        u.created_by,
        u.last_update_login
    FROM
        applsys.fnd_user u
    ;

----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_BRAND AS
--BANDEIRA
    SELECT
--IDENTIFICATION      
        fv.flex_value_id           AS brand_id,
--RELATIONSHIP        
        fvs.id_flex_num            AS chart_of_accounts_id,
        fv.flex_value_set_id       AS segment_id,
        fvs.segment_num,
        fvs.segment_name,
        fset.flex_value_set_name   AS category_name,
--DESCRIPTION            
        fv.flex_value              AS brand_code,
        ptb.description            AS brand_name_ptb,
        us.description             AS brand_name_us,
--VALIDITY    
        fv.enabled_flag            AS is_enabled,
        fv.start_date_active,
        fv.end_date_active,
--PROPERTIES    
        fv.summary_flag            AS is_summary,
        substr(fv.compiled_value_attributes, 1, 1) AS is_budgeting_allowed,
        substr(fv.compiled_value_attributes, 3, 1) AS is_posting_allowed,
        fv.attribute1,
--LINEAGE 
        to_timestamp(to_char(greatest(
                                    fv.last_update_date, 
                                    fvs.last_update_date, 
                                    fset.last_update_date, 
                                    ptb.last_update_date,
                                    us.last_update_date), 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        fv.last_updated_by,
        to_timestamp(to_char(fv.creation_date, 'DD-MON-RR HH:MI:SS AM')) AS creation_date,
        fv.created_by,
        fv.last_update_login
    FROM
        apps.fnd_flex_values_vl        fv
        JOIN applsys.fnd_id_flex_segments   fvs ON fv.flex_value_set_id = fvs.flex_value_set_id
        JOIN applsys.fnd_flex_values_tl     ptb ON ptb.flex_value_id = fv.flex_value_id
                                               AND ptb.language = 'PTB'
        JOIN applsys.fnd_flex_values_tl     us ON us.flex_value_id = fv.flex_value_id
                                              AND us.language = 'US'
        JOIN applsys.fnd_flex_value_sets    fset ON fset.flex_value_set_id = fvs.flex_value_set_id
    WHERE
        fvs.application_id = 101
        AND fvs.id_flex_code = 'GL#'
        AND fvs.segment_num = 2
        AND fvs.id_flex_num <> 50408 --(NOT COSIF)
        ;
----------------------------------------------------------------------------------------------------
create or replace view XXSTN.XXSTN_DTL_BUSINESS_UNIT as
--BUSINESS UNIT
    SELECT
--IDENTIFICATION      
        fv.flex_value_id           AS business_unit_id,
--RELATIONSHIP        
        fvs.id_flex_num            AS chart_of_accounts_id,
        fv.flex_value_set_id       AS segment_id,
        fvs.segment_num,
        fvs.segment_name,
        fset.flex_value_set_name   AS category_name,
--DESCRIPTION            
        fv.flex_value              AS business_unit,
        ptb.description            AS business_unit_name_ptb,
        us.description             AS business_unit_name_us,
--VALIDITY    
        fv.enabled_flag            AS is_enabled,
        fv.start_date_active,
        fv.end_date_active,
--PROPERTIES    
        fv.summary_flag            AS is_summary,
        substr(fv.compiled_value_attributes, 1, 1) AS is_budgeting_allowed,
        substr(fv.compiled_value_attributes, 3, 1) AS is_posting_allowed,
        fv.attribute1,
--LINEAGE 
        to_timestamp(to_char(greatest(
                                    fv.last_update_date, 
                                    fvs.last_update_date, 
                                    fset.last_update_date, 
                                    ptb.last_update_date,
                                    us.last_update_date), 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        fv.last_updated_by,
        to_timestamp(to_char(fv.creation_date, 'DD-MON-RR HH:MI:SS AM')) AS creation_date,
        fv.created_by,
        fv.last_update_login
    FROM
        apps.fnd_flex_values_vl        fv
        JOIN applsys.fnd_id_flex_segments   fvs ON fv.flex_value_set_id = fvs.flex_value_set_id
        JOIN applsys.fnd_flex_values_tl     ptb ON ptb.flex_value_id = fv.flex_value_id
                                               AND ptb.language = 'PTB'
        JOIN applsys.fnd_flex_values_tl     us ON us.flex_value_id = fv.flex_value_id
                                              AND us.language = 'US'
        JOIN applsys.fnd_flex_value_sets    fset ON fset.flex_value_set_id = fvs.flex_value_set_id
    WHERE
        fvs.application_id = 101
        AND fvs.id_flex_code = 'GL#'
        AND fvs.segment_num = 7
        AND fvs.id_flex_num <> 50408 --(NOT COSIF)
        ;
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_CHART_OF_ACCOUNTS AS
--PLANOS DE CONTAS
    SELECT
    --IDENTIFICATION
        fst.id_flex_num                     AS chart_of_accounts_id,
    --RELATIONSHIPS
        fst.application_id,
        fst.id_flex_code                    AS application_code,
    --DESCRIPTION        
        fst.structure_view_name             AS chart_of_accounts_name,
        fst.id_flex_structure_code          AS chart_of_accounts_code,
    --VALIDITY        
        fst.enabled_flag                    AS is_enabled,
    --PROPERTIES        
        fst.concatenated_segment_delimiter,
        fst.cross_segment_validation_flag   AS is_cross_segment_validation,
        fst.dynamic_inserts_allowed_flag    AS is_dynamic_inserts_allowed,
        fst.freeze_flex_definition_flag     AS is_frozen_flex_definition,
        fst.freeze_structured_hier_flag     AS is_frozen_structured_hierarchy,
        fst.shorthand_enabled_flag          AS is_shorthand_enabled,
        fst.shorthand_length,
    --LINEAGE        
        to_timestamp(to_char(fst.last_update_date, 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        fst.last_updated_by,
        to_timestamp(to_char(fst.creation_date, 'DD-MON-RR HH:MI:SS AM')) AS creation_date,
        fst.created_by,
        fst.last_update_login
    FROM
        applsys.fnd_id_flex_structures fst
    WHERE
        fst.application_id = 101 --GL Application
        AND fst.id_flex_code = 'GL#' --GL Module
        ;
	
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_COMPANY AS
    SELECT
--IDENTIFICATION      
        fv.flex_value_id           AS company_id,
--RELATIONSHIP              
        fvs.id_flex_num            AS chart_of_accounts_id,
        fv.flex_value_set_id       AS segment_id,
        fvs.segment_num,
        fvs.segment_name,
        fset.flex_value_set_name   AS category_name,
--DESCRIPTION            
        fv.flex_value              AS company_code,
        ptb.description            AS company_name_ptb,
        us.description             AS company_name_us,
--VALIDITY    
        fv.enabled_flag            AS is_enabled,
        fv.start_date_active,
        fv.end_date_active,
--PROPERTIES    
        fv.summary_flag            AS is_summary,
        substr(fv.compiled_value_attributes, 1, 1) AS is_budgeting_allowed,
        substr(fv.compiled_value_attributes, 3, 1) AS is_posting_allowed,
        fv.attribute1,
--LINEAGE 
        to_timestamp(to_char(greatest(
                                    fv.last_update_date, 
                                    fvs.last_update_date, 
                                    fset.last_update_date, 
                                    ptb.last_update_date,
                                    us.last_update_date), 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        fv.last_updated_by,
        to_timestamp(to_char(fv.creation_date, 'DD-MON-RR HH:MI:SS AM')) AS creation_date,
        fv.created_by,
        fv.last_update_login
    FROM
        apps.fnd_flex_values_vl        fv
        JOIN applsys.fnd_id_flex_segments   fvs ON fv.flex_value_set_id = fvs.flex_value_set_id
        JOIN applsys.fnd_flex_values_tl     ptb ON ptb.flex_value_id = fv.flex_value_id
                                               AND ptb.language = 'PTB'
        JOIN applsys.fnd_flex_values_tl     us ON us.flex_value_id = fv.flex_value_id
                                              AND us.language = 'US'
        JOIN applsys.fnd_flex_value_sets    fset ON fset.flex_value_set_id = fvs.flex_value_set_id
    WHERE
        fvs.application_id = 101
        AND fvs.id_flex_code = 'GL#'
        AND fvs.segment_num = 1;
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_COSIF_ACCOUNT AS
--COSIF
    SELECT
--IDENTIFICATION      
        fv.flex_value_id           AS cosif_account_id,
--RELATIONSHIP        
        fvs.id_flex_num            AS chart_of_accounts_id,
        fv.flex_value_set_id       AS segment_id,
        fvs.segment_num,
        fvs.segment_name,
        fset.flex_value_set_name   AS category_name,

--DESCRIPTION            
        fv.flex_value              AS cosif_account_unit,
        ptb.description            AS cosif_account_name_ptb,
        us.description             AS cosif_account_name_us,
--VALIDITY    
        fv.enabled_flag            AS is_enabled,
        fv.start_date_active,
        fv.end_date_active,
--PROPERTIES    
        fv.summary_flag            AS is_summary,
        substr(fv.compiled_value_attributes, 1, 1) AS is_budgeting_allowed,
        substr(fv.compiled_value_attributes, 3, 1) AS is_posting_allowed,
        substr(fv.compiled_value_attributes, 5, 1) AS account_type,
        substr(fv.compiled_value_attributes, 7, 1) AS is_third_party_control,
        substr(fv.compiled_value_attributes, 9, 1) AS is_reconcile,
        fv.attribute1,
--LINEAGE 
        to_timestamp(to_char(greatest(
                                    fv.last_update_date, 
                                    fvs.last_update_date, 
                                    fset.last_update_date, 
                                    ptb.last_update_date,
                                    us.last_update_date), 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        fv.last_updated_by,
        to_timestamp(to_char(fv.creation_date, 'DD-MON-RR HH:MI:SS AM')) AS creation_date,
        fv.created_by,
        fv.last_update_login
    FROM
        apps.fnd_flex_values_vl        fv
        JOIN applsys.fnd_id_flex_segments   fvs ON fv.flex_value_set_id = fvs.flex_value_set_id
        JOIN applsys.fnd_flex_values_tl     ptb ON ptb.flex_value_id = fv.flex_value_id
                                               AND ptb.language = 'PTB'
        JOIN applsys.fnd_flex_values_tl     us ON us.flex_value_id = fv.flex_value_id
                                              AND us.language = 'US'
        JOIN applsys.fnd_flex_value_sets    fset ON fset.flex_value_set_id = fvs.flex_value_set_id
    WHERE
        fvs.application_id = 101
        AND fvs.id_flex_code = 'GL#'
        AND fvs.segment_num = 2
        AND fvs.id_flex_num = 50408 --(COSIF)
        ;
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_COST_CENTER AS
--CENTROS DE CUSTO
    SELECT
--IDENTIFICATION      
        fv.flex_value_id           AS cost_center_id,
--RELATIONSHIP        
        fvs.id_flex_num            AS chart_of_accounts_id,
        fv.flex_value_set_id       AS segment_id,
        fvs.segment_num,
        fvs.segment_name,
        fset.flex_value_set_name   AS category_name,
--DESCRIPTION            
        fv.flex_value              AS cost_center,
        ptb.description            AS cost_center_name_ptb,
        us.description             AS cost_center_name_us,
--VALIDITY    
        fv.enabled_flag            AS is_enabled,
        fv.start_date_active,
        fv.end_date_active,
--PROPERTIES    
        fv.summary_flag            AS is_summary,
        substr(fv.compiled_value_attributes, 1, 1) AS is_budgeting_allowed,
        substr(fv.compiled_value_attributes, 3, 1) AS is_posting_allowed,
        fv.attribute1,
--LINEAGE 
        to_timestamp(to_char(greatest(
                                    fv.last_update_date, 
                                    fvs.last_update_date, 
                                    fset.last_update_date, 
                                    ptb.last_update_date,
                                    us.last_update_date), 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        fv.last_updated_by,
        to_timestamp(to_char(fv.creation_date, 'DD-MON-RR HH:MI:SS AM')) AS creation_date,
        fv.created_by,
        fv.last_update_login
    FROM
        apps.fnd_flex_values           fv
        JOIN applsys.fnd_id_flex_segments   fvs ON fv.flex_value_set_id = fvs.flex_value_set_id
        JOIN applsys.fnd_flex_values_tl     ptb ON ptb.flex_value_id = fv.flex_value_id
                                               AND ptb.language = 'PTB'
        JOIN applsys.fnd_flex_values_tl     us ON us.flex_value_id = fv.flex_value_id
                                              AND us.language = 'US'
        JOIN applsys.fnd_flex_value_sets    fset ON fset.flex_value_set_id = fvs.flex_value_set_id
    WHERE
        fvs.application_id = 101
        AND fvs.id_flex_code = 'GL#'
        AND fvs.segment_num = 5
        AND fvs.id_flex_num <> 50408 --(NOT COSIF)
        ;
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_ESTABLISHMENT AS
    SELECT 
--IDENTIFICATION   
        stb.establishment_id,
--RELATIONSHIP        
        stb.legal_entity_id, --headquarters
        lep_reg.location_id            AS main_location_id,
        stb_reg.location_id            AS location_id,
        coalesce(lep.le_information_context, 
                 stb.etb_information_context, 
                 lep_reg.reg_information_context, 
                 stb_reg.reg_information_context) AS country_code,        
--VALIDITY
        p.status                       AS entity_status,        
--PROPERTIES
        glev.flex_segment_value        AS company_code,
        fed_jur.registration_code_le as federal_tax_document,
        CASE WHEN coalesce(lep.le_information_context, 
                 stb.etb_information_context, 
                 lep_reg.reg_information_context, 
                 stb_reg.reg_information_context) = 'BR' 
            THEN
                 replace(replace(replace(lep_reg.registration_number,'.',''),'-',''),'/','')
            ELSE 
                 lep_reg.registration_number
        END                            AS main_registration_number,
        CASE WHEN coalesce(lep.le_information_context, 
                 stb.etb_information_context, 
                 lep_reg.reg_information_context, 
                 stb_reg.reg_information_context) = 'BR' 
            THEN
                 replace(replace(replace(stb_reg.registration_number,'.',''),'-',''),'/','')
            ELSE
                 stb_reg.registration_number   
        END                            AS registration_number,     
        
         state_jur_reg.registration_code_le AS state_tax_document,
         state_jur_reg.registration_number  AS state_registration,
         munic_jur_reg.registration_code_le AS municipal_tax_document,
         munic_jur_reg.registration_number  AS municipal_registration,
--HEADQUARTERS / BRANCH OFFICE        
        stb.main_establishment_flag    AS is_main_establishment,
        CASE
            WHEN stb.main_establishment_flag = 'Y' THEN
                coalesce(stb.main_effective_from, lep_reg.effective_from)
            ELSE
                stb.main_effective_from
        END                            AS main_effective_from,
        CASE
            WHEN stb.main_establishment_flag = 'Y' THEN
                coalesce(stb.main_effective_to, lep_reg.effective_to)
            ELSE
                stb.main_effective_to 
        END                            AS main_effective_to,
        stb_reg.effective_from         AS effective_from,--    
        stb_reg.effective_to           AS effective_to,--           
--DESCRIPTION        
        UPPER(lep_reg.registered_name) AS registered_name,
        UPPER(stb.name)                AS alternate_name,     
--LINEAGE
        to_timestamp(to_char(greatest(stb.last_update_date, 
                                      lep.last_update_date, 
                                      stb_reg.last_update_date, 
                                      lep_reg.last_update_date, 
                                      fed_jur.last_update_date,
                                      state_jur_reg.last_update_date,
                                      munic_jur_reg.last_update_date,
                                      glev.last_update_date,
                                      p.last_update_date), 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        stb.last_updated_by,
        stb.created_by,
        to_timestamp(to_char(stb.creation_date), 'DD-MON-RR HH:MI:SS AM') AS creation_date,
        stb.last_update_login        
    FROM
        xle.xle_entity_profiles          lep
        JOIN xle.xle_etb_profiles        stb     ON lep.legal_entity_id = stb.legal_entity_id
        JOIN xle.xle_registrations       stb_reg ON stb.establishment_id = stb_reg.source_id
                                                    AND stb_reg.source_table = 'XLE_ETB_PROFILES'
                                                    AND stb_reg.identifying_flag = 'Y'
        JOIN xle.xle_jurisdictions_b fed_jur ON stb_reg.jurisdiction_id = fed_jur.jurisdiction_id
        
        JOIN xle.xle_registrations       lep_reg ON lep.legal_entity_id = lep_reg.source_id
                                                    AND lep_reg.source_table = 'XLE_ENTITY_PROFILES'
                                                    AND lep_reg.identifying_flag = 'Y'
                                                    
        LEFT JOIN (SELECT DISTINCT state_reg.source_id AS establishment_id, 
                         state_jur.registration_code_le,
                         state_reg.registration_number,
                         state_jur.last_update_date
                FROM xle.xle_jurisdictions_b state_jur 
                JOIN xle.xle_registrations   state_reg ON state_reg.jurisdiction_id = state_jur.jurisdiction_id 
                                                         AND state_reg.source_table = 'XLE_ETB_PROFILES'
                                                         AND state_reg.identifying_flag = 'N'
                                                         AND state_jur.legislative_cat_code = 'INCOME_TAX'
                ) state_jur_reg                  ON state_jur_reg.establishment_id = stb.establishment_id
                
        LEFT JOIN (SELECT DISTINCT munic_reg.source_id AS establishment_id, 
                         munic_jur.registration_code_le,
                         munic_reg.registration_number,
                         munic_jur.last_update_date
                FROM xle.xle_jurisdictions_b munic_jur 
                JOIN xle.xle_registrations   munic_reg ON munic_reg.jurisdiction_id = munic_jur.jurisdiction_id 
                                                         AND munic_reg.source_table = 'XLE_ETB_PROFILES'
                                                         AND munic_reg.identifying_flag = 'N'
                                                         AND munic_jur.legislative_cat_code = 'COMPANY_LAW'
                ) munic_jur_reg                  ON munic_jur_reg.establishment_id = stb.establishment_id
                                                    
        JOIN gl.gl_legal_entities_bsvs   glev    ON glev.legal_entity_id = lep.legal_entity_id
        JOIN apps.hz_parties             p       ON lep.party_id = p.party_id
                                                    AND p.party_type = 'ORGANIZATION'
    WHERE
        lep.transacting_entity_flag = 'Y'
    ;
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_FUTURE AS
--FUTURO
    SELECT
--IDENTIFICATION      
        fv.flex_value_id           AS future_id,
--RELATIONSHIP        
        fvs.id_flex_num            AS chart_of_accounts_id,
        fv.flex_value_set_id       AS segment_id,
        fvs.segment_num,
        fvs.segment_name,
        fset.flex_value_set_name   AS category_name,

--DESCRIPTION            
        fv.flex_value              AS future_code,
        ptb.description            AS future_name_ptb,
        us.description             AS future_name_us,
--VALIDITY    
        fv.enabled_flag            AS is_enabled,
        fv.start_date_active,
        fv.end_date_active,
--PROPERTIES    
        fv.summary_flag            AS is_summary,
        substr(fv.compiled_value_attributes, 1, 1) AS is_budgeting_allowed,
        substr(fv.compiled_value_attributes, 3, 1) AS is_posting_allowed,
        fv.attribute1,
--LINEAGE 
        to_timestamp(to_char(greatest(
                                    fv.last_update_date, 
                                    fvs.last_update_date, 
                                    fset.last_update_date, 
                                    ptb.last_update_date,
                                    us.last_update_date), 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        fv.last_updated_by,
        to_timestamp(to_char(fv.creation_date, 'DD-MON-RR HH:MI:SS AM')) AS creation_date,
        fv.created_by,
        fv.last_update_login
    FROM
        apps.fnd_flex_values_vl        fv
        JOIN applsys.fnd_id_flex_segments   fvs ON fv.flex_value_set_id = fvs.flex_value_set_id
        JOIN applsys.fnd_flex_values_tl     ptb ON ptb.flex_value_id = fv.flex_value_id
                                               AND ptb.language = 'PTB'
        JOIN applsys.fnd_flex_values_tl     us ON us.flex_value_id = fv.flex_value_id
                                              AND us.language = 'US'
        JOIN applsys.fnd_flex_value_sets    fset ON fset.flex_value_set_id = fvs.flex_value_set_id
    WHERE
        fvs.application_id = 101
        AND fvs.id_flex_code = 'GL#'
        AND fvs.segment_num = 8
        AND fvs.id_flex_num <> 50408 --(NOT COSIF)
        ;
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_INTERCOMPANY AS
    SELECT 
--IDENTIFICATION      
        fv.flex_value_id           AS intercompany_id,
--RELATIONSHIP        
        fvs.id_flex_num            AS chart_of_accounts_id,
        fv.flex_value_set_id       AS segment_id,
        fvs.segment_num,
        fvs.segment_name,
        fset.flex_value_set_name   AS category_name,

--DESCRIPTION            
        fv.flex_value              AS intercompany_code,
        ptb.description            AS intercompany_name_ptb,
        us.description             AS intercompany_name_us,
--VALIDITY    
        fv.enabled_flag            AS is_enabled,
        fv.start_date_active,
        fv.end_date_active,
--PROPERTIES    
        fv.summary_flag            AS is_summary,
        substr(fv.compiled_value_attributes, 1, 1) AS is_budgeting_allowed,
        substr(fv.compiled_value_attributes, 3, 1) AS is_posting_allowed,
        fv.attribute1,
--LINEAGE 
        to_timestamp(to_char(greatest(
                                    fv.last_update_date, 
                                    fvs.last_update_date, 
                                    fset.last_update_date, 
                                    ptb.last_update_date,
                                    us.last_update_date), 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        fv.last_updated_by,
        to_timestamp(to_char(fv.creation_date, 'DD-MON-RR HH:MI:SS AM')) AS creation_date,
        fv.created_by,
        fv.last_update_login
    FROM
        apps.fnd_flex_values_vl        fv
        JOIN applsys.fnd_id_flex_segments   fvs ON fv.flex_value_set_id = fvs.flex_value_set_id
        JOIN applsys.fnd_flex_values_tl     ptb ON ptb.flex_value_id = fv.flex_value_id
                                               AND ptb.language = 'PTB'
        JOIN applsys.fnd_flex_values_tl     us ON us.flex_value_id = fv.flex_value_id
                                              AND us.language = 'US'
        JOIN applsys.fnd_flex_value_sets    fset ON fset.flex_value_set_id = fvs.flex_value_set_id
    WHERE
        fvs.application_id = 101
        AND fvs.id_flex_code = 'GL#'
        AND ( ( fvs.segment_num = 6
                AND fvs.id_flex_num <> 50408 ) --(NOT COSIF)
              OR ( fvs.segment_num = 4
                   AND fvs.id_flex_num = 50408 ) ) --(COSIF)
                   ;
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_LEGAL_ENTITY AS
    SELECT 
--IDENTIFICATION         
        lep.legal_entity_id, --headquarters
--RELATIONSHIP        
        stb.establishment_id          AS main_establishment_id,
        lep_reg.location_id           AS main_location_id,      
        coalesce(lep.le_information_context, 
                 stb.etb_information_context, 
                 lep_reg.reg_information_context, 
                 stb_reg.reg_information_context) AS country_code,        
--VALIDITY
        p.status                      AS entity_status,
--PROPERTIES
        glev.flex_segment_value       AS company_code,
        fed_jur.registration_code_le as federal_tax_document,
        CASE WHEN coalesce(lep.le_information_context, 
                 stb.etb_information_context, 
                 lep_reg.reg_information_context, 
                 stb_reg.reg_information_context) = 'BR' 
            THEN
                 replace(replace(replace(lep_reg.registration_number,'.',''),'-',''),'/','')
            ELSE 
                 lep_reg.registration_number
        END                           AS main_registration_number,     
--DESCRIPTION
        UPPER(lep_reg.registered_name) AS registered_name,
        UPPER(stb.name)                AS alternate_name,   
--LINEAGE        
        to_timestamp(to_char(greatest(stb.last_update_date, 
                                      lep.last_update_date, 
                                      stb_reg.last_update_date, 
                                      lep_reg.last_update_date, 
									  fed_jur.last_update_date,
                                      glev.last_update_date,
                                      p.last_update_date
                                      ), 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        stb.last_updated_by,
        stb.created_by,
        to_timestamp(to_char(stb.creation_date), 'DD-MON-RR HH:MI:SS AM') AS creation_date,
        stb.last_update_login
    FROM
        xle.xle_entity_profiles          lep
        JOIN xle.xle_etb_profiles        stb     ON lep.legal_entity_id = stb.legal_entity_id
        JOIN xle.xle_registrations       stb_reg ON stb.establishment_id = stb_reg.source_id
                                                    AND stb_reg.source_table = 'XLE_ETB_PROFILES'
                                                    AND stb_reg.identifying_flag = 'Y'
        JOIN xle.xle_jurisdictions_b fed_jur ON stb_reg.jurisdiction_id = fed_jur.jurisdiction_id                                                    
        JOIN xle.xle_registrations       lep_reg ON lep.legal_entity_id = lep_reg.source_id
                                                    AND lep_reg.source_table = 'XLE_ENTITY_PROFILES'
                                                    AND lep_reg.identifying_flag = 'Y'
        JOIN gl.gl_legal_entities_bsvs   glev    ON glev.legal_entity_id = lep.legal_entity_id
        JOIN ar.hz_parties               p       ON lep.party_id = p.party_id
                                                    AND p.party_type = 'ORGANIZATION'
    WHERE
        lep.transacting_entity_flag = 'Y'        
        AND stb.main_establishment_flag = 'Y'
        AND lep_reg.registration_number = stb_reg.registration_number --HEADQUARTERS    
        ;
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_LOCATION AS
    SELECT 
--IDENTIFICATION      
        loc.location_id,
--DESCRIPTION
        loc.location_code,
--PROPERTIES         
        ter.territory_code         AS country_code, --Country or Kingdom. 
        ter.iso_territory_code,
        ptb.territory_short_name   AS territory_name_ptb,
        us.territory_short_name    AS territory_name_us,
        loc.region_2               AS state_region, --State, Region or Province.
        loc.town_or_city           AS city_town, --City, Town or District name.
        upper(rtrim(loc.address_line_1, ',')) AS street_address, --Street address, P.O. box, company name, c/o.
        upper(rtrim(nullif(loc.address_line_2, '0'), ',')) AS street_number, --Street number.
        upper(rtrim(loc.address_line_3, ','))              AS address_line2, --Apartment, suite, unit, building, floor, etc.
        upper(rtrim(loc.region_1, ','))                    AS neighborhood, --Neighbourhood, Village or Area.
        loc.postal_code, --Postal Code
--LINEAGE          
        to_timestamp(to_char(greatest(loc.last_update_date, 
                                      ter.last_update_date, 
                                      ptb.last_update_date, 
                                      us.last_update_date
                            ), 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        loc.last_updated_by,
        loc.created_by,
        to_timestamp(to_char(loc.creation_date), 'DD-MON-RR HH:MI:SS AM') AS creation_date,
        loc.last_update_login
    FROM
        hr.hr_locations_all               loc
        JOIN applsys.fnd_territories      ter ON loc.country = ter.territory_code
        JOIN applsys.fnd_territories_tl   ptb ON ter.territory_code = ptb.territory_code
                                                AND ptb.language = 'PTB'
        JOIN applsys.fnd_territories_tl   us ON ter.territory_code = us.territory_code
                                                AND us.language = 'US'
    WHERE
        EXISTS (SELECT * FROM xle.xle_registrations reg
                WHERE reg.location_id = loc.location_id
                    AND reg.source_table IN ('XLE_ETB_PROFILES', 'XLE_ENTITY_PROFILES')
                    AND reg.identifying_flag = 'Y')
    ;
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_MOVEMENT_BATCH AS
    SELECT
--IDENTIFICATION
        b.je_batch_id            AS batch_id,
--RELATIONSHIPS    
        b.chart_of_accounts_id,    
--MAIN PROPERTIES						       
		b.default_period_name,		
		TO_TIMESTAMP(TO_CHAR(b.date_created, 'DD-MON-RR HH:MI:SS AM')) AS date_created,
		TO_TIMESTAMP(TO_CHAR(b.posted_date, 'DD-MON-RR HH:MI:SS AM')) AS posted_date,
        b.default_effective_date, 
		TO_TIMESTAMP(TO_CHAR(b.earliest_postable_date, 'DD-MON-RR HH:MI:SS AM')) AS earliest_postable_date,		
		b.accounted_period_type,		
		b.period_set_name        AS period_calendar,        
--VALIDITY
        b.status,
        b.status_verified,
        b.actual_flag            AS balance_type,      
--DESCRIPTION
        b.name                   AS batch_name,
        b.description            AS batch_description,
--ADDITIONAL PROPERTIES     
        b.average_journal_flag   AS is_average_journal,
        b.budgetary_control_status,
        b.parent_je_batch_id     AS parent_batch_id,
--SECURITY AND APPROVAL    
        b.approval_status_code,
        b.posting_run_id,
        b.request_id,
        b.org_id,
        b.posted_by,
        b.group_id,
        b.approver_employee_id,
--LINEAGE        
        to_timestamp(to_char(b.last_update_date, 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        b.last_updated_by,
        to_timestamp(to_char(b.creation_date, 'DD-MON-RR HH:MI:SS AM')) AS creation_date,
        b.created_by,        
        b.last_update_login
    FROM
        gl.gl_je_batches b
    ;
	
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_MOVEMENT_HEADER AS
    SELECT 
--IDENTIFICATION
        h.je_header_id                   AS header_id,
--RELATIONSHIPS
        h.ledger_id                      AS accounting_book_id,
        h.je_batch_id                    AS batch_id,
        h.period_name,
--MAIN PROPERTIES
        h.status,
        h.currency_code,		
		TO_TIMESTAMP(TO_CHAR(h.date_created, 'DD-MON-RR HH:MI:SS AM')) AS date_created,
		TO_TIMESTAMP(TO_CHAR(h.posted_date, 'DD-MON-RR HH:MI:SS AM')) AS posted_date,        
		h.default_effective_date,
        TO_TIMESTAMP(TO_CHAR(h.earliest_postable_date, 'DD-MON-RR HH:MI:SS AM')) AS earliest_postable_date,		
--DESCRIPTION      
        h.je_category                    AS category,
        h.je_source                      AS source,
        h.name                           AS header_name,
        h.description                    AS header_description,    
--ADDITIONAL PROPERTIES        
        h.accrual_rev_flag               AS is_accrual_rev,
        h.multi_bal_seg_flag             AS is_multi_bal_seg,
        h.actual_flag                    AS balance_type,
        h.tax_status_code,
        h.conversion_flag                AS is_conversion,
        h.balanced_je_flag               AS is_balanced,
        h.balancing_segment_value        AS balancing_company,
        h.accrual_rev_period_name,
        h.accrual_rev_status,
        h.accrual_rev_je_header_id       AS accrual_rev_header_id,
        h.accrual_rev_change_sign_flag   AS is_accrual_rev_change_sign,        
        h.parent_je_header_id            AS parent_header_id,
        h.reversed_je_header_id          AS reversed_header_id,
        h.je_from_sla_flag               AS is_from_sla,
--LINEAGE     
        TO_TIMESTAMP(TO_CHAR(h.last_update_date, 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        h.last_updated_by,
        TO_TIMESTAMP(TO_CHAR(h.creation_date, 'DD-MON-RR HH:MI:SS AM')) AS creation_date,
        h.created_by,        
		h.last_update_login
    FROM
        gl.gl_je_headers h
        ;
		

----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_MOVEMENT_LINES AS
    SELECT 
--IDENTIFICATION
        cast(ln.je_header_id || lpad(ln.je_line_num, 6, '0') as number(15,0)) AS line_id,
        ln.je_header_id          AS header_id,
        ln.je_line_num           AS line_num,
--RELATIONSHIPS    
        ln.ledger_id             AS accounting_book_id,
        ln.code_combination_id   AS accounting_reference_id,
        ln.period_name,
--MAIN PROPERTIES
        ln.effective_date,
        ln.status,
--ENTRY VALUES
        ln.entered_dr,
        ln.entered_cr,
        ln.accounted_dr,
        ln.accounted_cr,
--DESCRIPTION  
        ln.description           AS movement_description,
        ln.line_type_code,
--ADDITIONAL PROPERTIES
        ln.reference_1,
        ln.reference_2,
        ln.reference_3,
        ln.reference_4,
        ln.reference_5,
        ln.reference_6,
        ln.reference_7,
        ln.reference_8,
        ln.reference_9,
        ln.reference_10,
        ln.context2,
        ln.no1,
        ln.ignore_rate_flag      AS ignore_rate,
--LINEAGE 
        TO_TIMESTAMP(TO_CHAR(ln.last_update_date, 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        ln.last_updated_by,
        TO_TIMESTAMP(TO_CHAR(ln.creation_date, 'DD-MON-RR HH:MI:SS AM')) AS creation_date,
        ln.created_by,
        ln.last_update_login
    FROM
        gl.gl_je_lines ln    
    ;

----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_ORGANIZATION_UNIT AS
    SELECT 
--IDENTIFICATION          
        o.organization_id,  
--RELATIONSHIP           
        o.location_id,
        o3.org_information3   AS accounting_book_id,
        o3.org_information2   AS legal_entity_id,
        ref.segment1          AS company_code,
--DESCRIPTION           
        ptb.name              AS organization_name_ptb,
        us.name               AS organization_name_us,
--PROPERTIES 
        o3.org_information5   AS organization_code,
--VALIDITY            
        o.date_from,
        o.date_to,
--LINEAGE         
        to_timestamp(to_char(greatest(o.last_update_date, 
                                     o2.last_update_date, 
                                     o3.last_update_date, 
                                     ptb.last_update_date, 
                                     us.last_update_date,
                                     nvl(fin.last_update_date, o.last_update_date), 
                                     nvl(ref.last_update_date, o.last_update_date)
                            ), 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        o.last_updated_by,
        o.created_by,
        to_timestamp(to_char(o.creation_date), 'DD-MON-RR HH:MI:SS AM') AS creation_date,
        o.last_update_login
    FROM
        hr.hr_all_organization_units        o
        JOIN hr.hr_all_organization_units_tl        ptb ON o.organization_id = ptb.organization_id
                                                           AND ptb.language = 'PTB'
        JOIN hr.hr_all_organization_units_tl        us  ON o.organization_id = us.organization_id
                                                           AND us.language = 'US'
        JOIN hr.hr_organization_information         o2  ON o.organization_id = o2.organization_id
        JOIN hr.hr_organization_information         o3  ON o.organization_id = o3.organization_id
        LEFT JOIN apps.financials_system_params_all fin ON o.organization_id = fin.org_id
        LEFT JOIN apps.gl_code_combinations         ref ON ref.code_combination_id = fin.accts_pay_code_combination_id
    WHERE
        o2.org_information_context || '' = 'CLASS'        
        AND o2.org_information1 = 'OPERATING_UNIT'
        AND o2.org_information2 = 'Y' --Is legal Entity        
        AND o3.org_information_context = 'Operating Unit Information'
        ;
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_PERIOD_TYPE AS
    SELECT 
    --IDENTIFICATION   
        pt.period_type_id,
        pt.period_type,
--DESCRIPTION               
        pt.user_period_type                           AS period_type_name,
        coalesce(pt.description, pt.user_period_type) AS period_type_description,
--PROPERTIES
        pt.number_per_fiscal_year,
        pt.year_type_in_name,
--LINEAGE         
        TO_TIMESTAMP(TO_CHAR(pt.last_update_date, 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        pt.last_updated_by,
        TO_TIMESTAMP(TO_CHAR(pt.creation_date, 'DD-MON-RR HH:MI:SS AM')) AS creation_date,
        pt.created_by,
        pt.last_update_login
    FROM
        gl.gl_period_types pt
    ;

----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_PRODUCT AS
    SELECT
--IDENTIFICATION      
        fv.flex_value_id           AS product_id,
--RELATIONSHIP  
        fvs.id_flex_num            AS chart_of_accounts_id,
        fv.flex_value_set_id       AS segment_id,
        fvs.segment_num,
        fvs.segment_name,
        fset.flex_value_set_name   AS category_name,
--DESCRIPTION            
        fv.flex_value              AS product_code,
        ptb.description            product_name_ptb,
        us.description             product_name_us,
--VALIDITY    
        fv.enabled_flag            AS is_enabled,
        fv.start_date_active,
        fv.end_date_active,
--PROPERTIES    
        fv.summary_flag            AS is_summary,
        substr(fv.compiled_value_attributes, 1, 1) AS is_budgeting_allowed,
        substr(fv.compiled_value_attributes, 3, 1) AS is_posting_allowed,
        fv.attribute1,
--LINEAGE 
        to_timestamp(to_char(greatest(
                                    fv.last_update_date, 
                                    fvs.last_update_date, 
                                    fset.last_update_date, 
                                    ptb.last_update_date,
                                    us.last_update_date), 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        fv.last_updated_by,
        to_timestamp(to_char(fv.creation_date, 'DD-MON-RR HH:MI:SS AM')) AS creation_date,
        fv.created_by,
        fv.last_update_login
    FROM
        apps.fnd_flex_values_vl        fv
        JOIN applsys.fnd_id_flex_segments   fvs ON fv.flex_value_set_id = fvs.flex_value_set_id
        JOIN applsys.fnd_flex_values_tl     ptb ON ptb.flex_value_id = fv.flex_value_id
                                               AND ptb.language = 'PTB'
        JOIN applsys.fnd_flex_values_tl     us ON us.flex_value_id = fv.flex_value_id
                                              AND us.language = 'US'
        JOIN applsys.fnd_flex_value_sets    fset ON fset.flex_value_set_id = fvs.flex_value_set_id
    WHERE
        fvs.application_id = 101
        AND fvs.id_flex_code = 'GL#'
        AND fvs.segment_num = 3
        AND fvs.id_flex_num <> 50408 --(NOT COSIF)
        ;
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW XXSTN.XXSTN_DTL_SEGMENT_CATEGORY AS
--CATEGORIA CONTABIL
    SELECT        
--IDENTIFICATION          
        fvs.flex_value_set_id           AS segment_id,
--DESCRIPTION 
        fvs.flex_value_set_name         AS category_name,
        fvs.description                 AS category_description,
--PROPERTIES         
        fvs.protected_flag              AS is_protected,
        fvs.security_enabled_flag       AS is_security_enabled,
        fvs.format_type,        
        fvs.maximum_size,
        fvs.alphanumeric_allowed_flag   AS is_alphanumeric_allowed,
        fvs.uppercase_only_flag         AS is_uppercase_only,
        fvs.numeric_mode_enabled_flag   AS is_numeric_mode_enabled,
        fvs.minimum_value,
        fvs.maximum_value,
        fvs.number_precision,
--LINEAGE   
        TO_TIMESTAMP(TO_CHAR(fvs.last_update_date, 'DD-MON-RR HH:MI:SS AM')) AS last_update_date,
        fvs.last_updated_by,
        TO_TIMESTAMP(TO_CHAR(fvs.creation_date, 'DD-MON-RR HH:MI:SS AM')) AS creation_date,
        fvs.created_by,
        fvs.last_update_login
    FROM
        applsys.fnd_flex_value_sets fvs
    WHERE
        EXISTS (
            SELECT
                *
            FROM
                applsys.fnd_id_flex_segments fsg
            WHERE
                fsg.application_id = 101 --GL Application
                AND fsg.id_flex_code = 'GL#' --GL Module
                AND fsg.flex_value_set_id = fvs.flex_value_set_id
        );

----------------------------------------------------------------------------------------------------
