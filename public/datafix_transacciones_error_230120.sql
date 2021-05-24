spool datafix_transacciones_error_230120.log
PROMPT ##################
PROMPT ##Adecoagro - 23-01-2020##
PROMPT ##################
PROMPT Descripcion: DATAFIX Se cambia el transaction_reference 
PROMPT              de las declaraciones de produccion por el lpn sin el prefijo
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
   AND xwii.message_id = 'IHTHGNADECOMSS000001277994'
;

DELETE FROM apps.xx_wms_integration_in xwii
 WHERE 1=1
   AND xwii.message_id = 'IHTHGNADECOMSS000001277994'
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
