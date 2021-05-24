--
SET Serveroutput On;
--
DECLARE
   --
   x_invoice_id         NUMBER;
   x_hold_lookup_code   VARCHAR2 (200);
   x_hold_type          VARCHAR2 (200);
   x_hold_reason        VARCHAR2 (200);
   x_held_by            NUMBER;
   x_calling_sequence   VARCHAR2 (200);
   v_check_flag         VARCHAR2 (1);
   v_context            VARCHAR2 (10);
   --
   FUNCTION set_context ( i_user_name  IN VARCHAR2
                        , i_resp_name  IN VARCHAR2
                        , i_org_id     IN   NUMBER) RETURN VARCHAR2
   IS
      v_user_id        NUMBER;
      v_resp_id        NUMBER;
      v_resp_appl_id   NUMBER;
      v_lang           VARCHAR2 (100);
      v_session_lang   VARCHAR2 (100) := fnd_global.current_language;
      v_return         VARCHAR2 (10)  := 'T';
      v_nls_lang       VARCHAR2 (100);
      v_org_id         NUMBER         := i_org_id;

/* Cursor to get the user id information based on the input user name */
      CURSOR cur_user
      IS
         SELECT user_id
           FROM fnd_user
          WHERE user_name = i_user_name;

/* Cursor to get the responsibility information */
      CURSOR cur_resp
      IS
         SELECT responsibility_id, application_id, LANGUAGE
           FROM fnd_responsibility_tl
          WHERE responsibility_name = i_resp_name;

/* Cursor to get the nls language information for setting the language context */
      CURSOR cur_lang (p_lang_code VARCHAR2)
      IS
         SELECT nls_language
           FROM fnd_languages
          WHERE language_code = p_lang_code;
   BEGIN
      /* To get the user id details */
      OPEN cur_user;

      FETCH cur_user
       INTO v_user_id;

      IF cur_user%NOTFOUND THEN
         v_return := 'F';
      END IF;  --IF cur_user%NOTFOUND

      CLOSE cur_user;

      /* To get the responsibility and responsibility application id */
      OPEN cur_resp;

      FETCH cur_resp
       INTO v_resp_id, v_resp_appl_id, v_lang;

      IF cur_resp%NOTFOUND THEN
         v_return := 'F';
      END IF;     --IF cur_resp%NOTFOUND

      CLOSE cur_resp;

      /* Setting the oracle applications context for the particular session */
      fnd_global.apps_initialize (user_id           => v_user_id
                                 ,resp_id           => v_resp_id
                                 ,resp_appl_id      => v_resp_appl_id
                                 );
      /* Setting the org context for the particular session */
      mo_global.set_policy_context ('S', v_org_id);

      /* setting the nls context for the particular session */
      IF v_session_lang != v_lang THEN
         OPEN cur_lang (v_lang);

         FETCH cur_lang
          INTO v_nls_lang;

         CLOSE cur_lang;

         fnd_global.set_nls_context (v_nls_lang);
      END IF;                                    --IF v_session_lang != v_lang
      --
      RETURN v_return;
      --
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 'F';
   END set_context;
   --
BEGIN
   DBMS_OUTPUT.put_line ('Inicio Hold..');

--1. Set applications context if not already set.
   v_context := set_context ('IVAMCARDOSO', 'SAE_EBS_AP_SUPORTE', 82);
   --
   IF v_context = 'F' THEN
      DBMS_OUTPUT.put_line ('Error while setting the context');
   END IF;
   --
   mo_global.init ('SQLAP');
   --
 For reg in (Select aia.invoice_id, aia.vendor_id, aia.invoice_num, aia.amount_paid, aia.amount_applicable_to_discount, aia.pay_curr_invoice_amount, aia.cancelled_date
               , asp.vendor_name
            From ap.ap_invoices_all aia
               , ap.ap_suppliers asp
           Where 1=1
             And asp.vendor_id = aia.vendor_id
             And aia.vendor_id In (Select supplier_id From apps.sae_pos_inactive_suppliers)
             And NVL(aia.payment_status_flag,'N') <> 'Y'
             And aia.cancelled_date Is Null
             And Not Exists (SELECT aha.invoice_id From ap_holds_all aha 
                              Where aha.hold_lookup_code = 'Fornecedor com Restrição'
                                And aha.Release_Reason is null
                                And aha.invoice_id = aia.invoice_id) )  
   loop
      --
      x_invoice_id := reg.invoice_id;  --4775253;
      x_hold_lookup_code := 'Fornecedor com Restrição';     -- 'Fornecedor com Restrição'
      x_hold_type := 'INVOICE HOLD REASON';                 -- 'Motivo da Retenção NFF'
      x_hold_reason := 'Fornecedor na lista de restrição';  -- 'Fornecedor na lista de restrição'
      x_held_by := 5;
      x_calling_sequence := NULL;
      --
      apps.AP_HOLDS_PKG.INSERT_SINGLE_HOLD( x_invoice_id       => x_invoice_id
                                          , x_hold_lookup_code => x_hold_lookup_code
                                          , x_hold_type        => x_hold_type
                                          , x_hold_reason      => x_hold_reason
                                          , x_held_by          => x_held_by
                                          , x_calling_sequence => x_calling_sequence
                                          );
      --
--      DBMS_OUTPUT.put_line ('Hold aplicado.');
      --
      BEGIN
         SELECT 'Y'
           INTO v_check_flag
           FROM ap_holds_all
          WHERE invoice_id = x_invoice_id AND hold_lookup_code = 'Fornecedor com Restrição';
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_check_flag := 'N';
      END;
      --
      commit;
      DBMS_OUTPUT.put_line ('Hold Aplicado (Y/N) : '||v_check_flag||' - INVOICE_ID : '||reg.invoice_id||' - INVOICE_NUM : '||reg.invoice_num);
   --
   End Loop;
   --
END;

