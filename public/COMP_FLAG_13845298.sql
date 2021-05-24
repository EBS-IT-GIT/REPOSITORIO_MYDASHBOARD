 DECLARE 
   l_return_status    VARCHAR2 (100);
   l_message_count    NUMBER;
   l_message_data     VARCHAR2 (1000);
   lv_error_message   VARCHAR2 (800);
BEGIN
   mo_global.set_policy_context ('S', 104);
   fnd_global.apps_initialize(1335,50857,222);
   ar_transaction_grp.complete_transaction
                           (p_api_version           => 1.0,
                            p_init_msg_list         => fnd_api.g_true,
                            p_commit                => fnd_api.g_false,
                            p_validation_level      => fnd_api.g_valid_level_none,
                            p_customer_trx_id       => 13845298,
                            x_return_status         => l_return_status,
                            x_msg_count             => l_message_count,
                            x_msg_data              => l_message_data
                           );
   COMMIT;

   IF l_return_status IN ('E', 'U')
   THEN
      FOR i IN 1 .. l_message_count
      LOOP
         lv_error_message :=
                         lv_error_message || '--' || fnd_msg_pub.get (i, 'F');
         DBMS_OUTPUT.put_line ('l_return_status-' || l_return_status);
      END LOOP;

      DBMS_OUTPUT.put_line (   'API Failed. Error:'
                            || SUBSTR (lv_error_message, 1, 800)
                           );
   ELSE
      DBMS_OUTPUT.put_line ('AR Invoice Complete sucessfully');
      DBMS_OUTPUT.put_line ('lv_return_status-' || l_return_status);
   END IF;
END ;
EXIT