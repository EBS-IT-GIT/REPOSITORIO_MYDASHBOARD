DECLARE

p_customer_trx_id NUMBER := 14038532;

v_batch_source_id NUMBER;
v_org_id NUMBER;
v_error_message VARCHAR2(3000);

l_seq_name                VARCHAR2 (3000);
l_seq_no                  NUMBER;
l_errcode3                NUMBER;
l_trx_number              ra_customer_trx_all.trx_number%TYPE;

l_branch_number varchar2(40);
l_document_letter varchar2(100);

v_step VARCHAR2(200);

BEGIN

    v_step := 'OBTENGO_BATCH_S_ID';

    SELECT batch_source_id,org_id
      INTO v_batch_source_id,v_org_id
      FROM ra_customer_trx_all
      where customer_trx_id = p_customer_trx_id;
      
      v_step := 'OBT LETRA Y PTO VENTA';

    SELECT SUBSTR (a.global_attribute2,1,4) 
        , SUBSTR (a.global_attribute3,1,1) 
        into l_branch_number
        ,l_document_letter
     FROM ra_batch_sources_all a
    WHERE batch_source_id = v_batch_source_id;
    
    v_step := 'OBTENGO_SEQ_NAME';

/* Se arma el nombre de la sequencia relacionada con el Batch*/
   l_seq_name             :=    'JL.JL_ZZ_TRX_NUM_' --'RA_TRX_NUMBER_'
                                  || TO_CHAR (v_batch_source_id)
                                  || '_'
                                  || TO_CHAR(v_org_id)
                                  || '_S';
                                  
                                  v_step := 'LLAMO GET_NEXT';
   
   /* Se recupera el siguiente numero de la secuencia*/
      jl_zz_ar_library_1_pkg.get_next_seq_number ( l_seq_name
                                                   , l_seq_no
                                                   , 1
                                                   , l_errcode3);
                                                   
        v_step := 'ERRCODE: '||to_char(l_errcode3);
      /* Si no existen errores se formatea.*/
      IF l_errcode3 = 0 THEN
         l_trx_number      :=    l_document_letter
                                     || '-'
                                     || l_branch_number
                                     || '-'
                                     || LPAD (TO_CHAR (l_seq_no),8,'0');
                                     
                                     v_step:= 'TRX_NUMBER:'||l_trx_number;
                                     
         /* se devuelve el numero generado*/
         update ra_customer_trx_all
            set trx_number      = l_trx_number
          where customer_trx_id = p_customer_trx_id;
          
          v_step := 'UPDATED';
                    
      ELSE
         dbms_output.put_line('error al obtener numero de la sequencia');
      END IF;
      
      /* Valido el prefijo del numero generado.*/
        EXCEPTION
         WHEN OTHERS THEN
         v_error_message:= v_step||'Error al actualizar el numero de transaccion. Error: '||sqlerrm;
         dbms_output.put_line(v_error_message); 
END;