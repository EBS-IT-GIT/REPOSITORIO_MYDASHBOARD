set serveroutput on size 1000000;
set verify off;

declare
begin

   DELETE FROM lib_lic_modulos;
  
   UPDATE empresa  
      SET CNPJ_CONTRATANTE = NULL, 
          DAT_EMISSAO_LIC  = NULL,
          VALIDADOR_SENHA_LIC = NULL,
	  DATA_1 = NULL,
    ORDEM_LIC = NULL;
   --where TRIM(CNPJ_CONTRATANTE) is not null;
   
   IF SQL%NOTFOUND THEN
     dbms_output.put_line(' ');
     dbms_output.put_line('Não há empresas licenciadas!');
     ROLLBACK;
   ELSE
     COMMIT;                                                                                                                                               
     
     dbms_output.put_line(' ');
     dbms_output.put_line('Procedimento concluido com sucesso!');
   END IF;
   
exception
   when others then
      dbms_output.put_line(' ');
      dbms_output.put_line('Erro no procedimento!');
      dbms_output.put_line('Mensagem Oracle: ' || sqlerrm);
end;
/
