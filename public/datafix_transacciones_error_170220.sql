spool datafix_transacciones_error_170220.log
PROMPT ##################
PROMPT ##Adecoagro - 17-02-2020##
PROMPT ##################
PROMPT Descripcion: DATAFIX Se dejan con error las transacciones que no se hizo la declarion de produccion
PROMPT              para los lpn DSS00015221, DSS00015222, DSS00015223, DSS00015224
set feedback off
select to_char(sysdate,'YYYY-MM-DD HH24:MI:SS') Fecha_Inicio from dual;

set feedback on

PROMPT 


/*###################
##Ejecucion Datafix##
###################*/
PROMPT ######################
PROMPT ##Ejecutando Datafix##
PROMPT ######################

SELECT count(1) cantidad_transacciones
  FROM apps.xx_wms_integration_in xwii
 WHERE 1=1
   AND message_id = 'IHTHGNADECODSS0000053103'
   AND lpn_nbr in ('DSS00015221', 'DSS00015222', 'DSS00015223', 'DSS00015224');

UPDATE apps.xx_wms_integration_in xwii
   SET status = 'ERROR'
 WHERE 1=1
   AND message_id = 'IHTHGNADECODSS0000053103'
   AND lpn_nbr in ('DSS00015221', 'DSS00015222', 'DSS00015223', 'DSS00015224');

;


set feedback off
select  to_char(sysdate,'YYYY-MM-DD HH24:MI:SS') Fecha_Fin from dual;

/*########
##Commit##
########*/
prompt

prompt ----------------------------------------------------------------------------------

prompt Actualizacion Completa.
prompt Escribir commit, rollback para cancelar o exit para salir, luego presione Enter.
prompt ----------------------------------------------------------------------------------

spool off
