--Executar como xstrmadmin

REM execute DBMS_XSTREAM_ADM.DROP_OUTBOUND(server_name     =>  'AWSSRV007_ECCPRD_OUT_TALHAO')

DECLARE
 tables DBMS_UTILITY.UNCL_ARRAY;
 schemas DBMS_UTILITY.UNCL_ARRAY;
BEGIN
tables(1) := 'SAPSR3.T001K';
tables(2) := 'SAPSR3.T001W';
tables(3) := 'SAPSR3.LFB1';
tables(4) := 'SAPSR3.ADRC';
tables(5) := 'SAPSR3.LFA1';
tables(6) := 'SAPSR3.VIBDRO';
tables(7) := 'SAPSR3.ZRE_RO_CICLO';
tables(8) := 'SAPSR3.ZRE_RO_ROTACAO';
tables(9) := 'SAPSR3.ZRE_RO_REC_TEC';
tables(10) := 'SAPSR3.ZRE_RO_MAT_GEN';
tables(11) := 'SAPSR3.ZRET_RO_REC_TAL';
tables(12) := 'SAPSR3.VIBDMEAS';
tables(13) := 'SAPSR3.TJ30T';
tables(14) := 'SAPSR3.EQKT';
tables(15) := 'SAPSR3.EQUZ';


tables(16) := NULL;

schemas(1) := NULL;
  DBMS_XSTREAM_ADM.CREATE_OUTBOUND(
    server_name     =>  'AWSSRV007_ECCPRD_OUT_TALHAO',
    table_names     =>  tables,
    schema_names    =>  schemas,
    include_ddl     =>  TRUE,
    capture_name    =>  'CAP$_AWSSRV007_ECCPRD_OUT_TALHAO');

  DBMS_XSTREAM_ADM.ALTER_OUTBOUND(
    server_name  => 'AWSSRV007_ECCPRD_OUT_TALHAO',
    connect_user => 'xstrm_talhao');

    dbms_capture_adm.set_parameter('CAP$_AWSSRV007_ECCPRD_OUT_TALHAO','_SGA_SIZE','10');

END;


/*
     SELECT SERVER_NAME, 
               CONNECT_USER, 
               CAPTURE_USER, 
               CAPTURE_NAME,
               STATUS,
               SOURCE_DATABASE,
               QUEUE_OWNER,
               QUEUE_NAME
          FROM DBA_XSTREAM_OUTBOUND
          where SERVER_NAME='AWSSRV007_ECCPRD_OUT_TALHAO';
          
     SELECT distinct STREAMS_NAME, 
       SCHEMA_NAME,
       OBJECT_NAME,
       RULE_TYPE
  FROM DBA_XSTREAM_RULES where streams_type='APPLY'
   and STREAMS_NAME='AWSSRV007_ECCPRD_OUT_TALHAO'
   order by SCHEMA_NAME,OBJECT_NAME;
   
   
select * from DBA_XSTREAM_RULES


select * from V$LOCKED_OBJECT
*/


