/* Product: StandardInstallation, File: ConfigCheck.sql, Version: 06_10_007 */
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- This script will identify missing parts in your Oracle configuration, and give information on how to fix it.
-- No database changes will be made by this script.
-- The output is a script file FixMissing_<database name>_<timestamp>.sql which can be run to apply the required fixes.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PARAMETERS -----------------------------------------------------------------------------------------------------------------------------------------------------------
   --IN THIS SECTION YOU CAN SET PARAMETERS REQUIRED IN YOUR ENVIRONMENT
   ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
   --Database parameters ------------------------------------------------------------------------------------------------------------------------------------------------
   def Unicode=true                                     --TRUE (=UNICODE usage) or FALSE (=ASCII usage)
   --USERS --------------------------------------------------------------------------------------------------------------------------------------------------------------
   def UserList=klbrmo_qa_oper,klbrmo_qa_tact,klbrmo_qa_util                        --Comma-separated list of usernames, e.g. CUSTOMER_PLS_PROD; ALL=all users will be checked; NONE=none checked; suffixes _FCT/_SOP/_OPR/_UTL will be added automatically when not specified; maintenance user OMDBA will be checked automatically if needed.
   def OMDINUser=OMDIN                                   -- Name of the user used for Data Inspector (DIN)                          Default=OMDIN
   --Tablespace sizes ---------------------------------------------------------------------------------------------------------------------------------------------------
   def TablespaceSize_OMPARTNERS=6000m                   --Required size of tablespace OMPARTNERS, specify in mb.                   Default=6000m
   def TablespaceSize_INDEXES=3000m                      --Required size of tablespace INDEXES, specify in mb.                      Default=3000m
   def TablespaceSize_TEMP=1000m                         --Required size of tablespace TEMP, specify in mb.                         Default=1000m
   def TablespaceSize_SYSTEM=1000m                       --Required size of tablespace SYSTEM, specify in mb                        Default=1000m
   def TablespaceSize_SYSAUX=1000m                       --Required size of tablespace SYSAUX, specify in mb                        Default=512m
   def TablespaceSize_OMDBA=50m                          --Required size of tablespace OM, specify in mb                            Default=50m
   --Memory sizes -------------------------------------------------------------------------------------------------------------------------------------------------------
   def shared_pool_size=2000m                            --Required for OM Partners applications                                    Default=2000m
   def db_cache_size=6000m                               --Required for performance                                                 Default=6000m
   def pga_aggregate_target=400m                         --Required to provide PGA memory for server processes                      Default=400m
   --Other database parameters ------------------------------------------------------------------------------------------------------------------------------------------
   def OMPApplicationVersion=06_08                       --Version of OMPartners applications used, eg. 05_54                       Default=06_10
   def dml_locks=2000                                    --Data Manipulation Locks initial reservation at startup                   Default=2000
   def processes=500                                     --Amount of sessions connecting concurrently.                              Default=500
   def OMPDP_directory_path=<Default_DATA_PUMP_DIR_path> --Location of directory OMPDP to be used with datapump                     Default=<Default_DATA_PUMP_DIR_path>
   --Other script parameters --------------------------------------------------------------------------------------------------------------------------------------------
   def info=true                                         --Show additional information output, TRUE or FALSE                        Default=true
   def SkipSharedPackages=false                          --Skip checking shared packages only true if shared OMDBA is not allowed   Default=false
   def SkipSharedSleep=false                             --Skip using shared sleep procedure                                        Default=false
   def SkipOMDBA=false                                   --Skip testing of OMDBA                                                    Default=false
   def SkipOMDIN=false                                   --Skip testing of OMDIN                                                    Default=false
   def SkipPublicSynonyms=false                          --Skip proposing public synonyms, use private instead                      Default=false
   def SkipVViews=false                                  --Skip usage of V$ views, use MYV$ instead                                 Default=false
   def SkipDBLink=false                                  --Skip usage of DBLink                                                     Default=false
   def SkipOMDBADINDBTests=false                         --Skip Data Inspector database level test requirements for user OMDBA      Default=false
   def SkipAddingPlanningLayerSuffix=true                --Skip auto-adding missing suffixes _FCT|SOP|OPR|UTL to above Userlist     Default=false
   def SkipOMPDPDirectory=false                          --Skip creation of directory OMPDP for use with datapump                   Default=false
   def SkipBounceMode=false                         	 --Skip DB Bounce, a safe mode prefix '--SM', no pfile/spfile usage         Default=false
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------
-- S T A R T    O F    S C R I P T --------------------------------------------------
-- DO NOT MODIFY --------------------------------------------------------------------
-------------------------------------------------------------------------------------
set echo off
set serveroutput on format wrapped
set verify off
set feedback off
set timing off
set heading off
set lines 200
set trimspool on
set newpage none
set tab off

clear screen


--Variable declarations
var ErrorCount                    number
var warningcount                  number
var info                          number
var NLSCHARACTERSET               varchar2(160)
var NLSNCHARCHARACTERSET          varchar2(160)
var NLSRDBMSVERSION               varchar2(160)
var text                          varchar2(2000)
var xdigit                        varchar2(160)
var NLSRDBMSVERSION00             varchar2(170)
var Vxx                           varchar2(2)
var Vxx_yy                        varchar2(5)
var Line                          varchar2(2000)
var ParameterValue                varchar2(2000)
var OMPApplicationVersion         varchar2(40)
var NEWLINE                       varchar2(2)
var rqSharedPoolSize              varchar2(2000)
var rqDbCacheSize                 varchar2(2000)
var rqPgaAggregateTarget          varchar2(2000)
var rqSgaMaxSize                  varchar2(2000)
var rqDmlLocks                    number
var rqProcesses                   number
var UserList                      varchar2(2000)
var OMDINUser                     varchar2(2000)
var FullUserList                  varchar2(2000)
var SkipSharedPackages            number
var SkipOMDBA                     number
var SkipOMDIN                     number
var SkipPublicSynonyms            number
var SkipV$Views                   number
var SkipDBLink                    number
var SkipSharedSleep               number
var SkipOMDBADINDBTests           number
var SkipAddingPlanningLayerSuffix number
var SkipOMPDPDirectory            number
var SkipBounceMode				  number
var SafeMode                      varchar2(40);
var PortString                    varchar2(2000)
var OSWINNT                       varchar2(2000)
var ClientOSWINNT                 varchar2(2000)
var ClientProgram                 varchar2(2000)
var UserListRequiringMJobCreation CLOB
var UserListLocked                CLOB

var WorkingDirectory              varchar2(2000)
var ClientPathSeparator           varchar2(1)
var OracleASM                     number
var PhysicalMemory                number
var ProcessorType                 varchar2(2000)
var OSBootTime                    varchar2(2000)
var OSUpTime                      varchar2(2000)
var DirectoryOMPDPExists          number

--Variables used to determine the db_securefile options
var notsecurefile                 number
var db_securefileinfo             varchar2(2000)
var db_securefileoption           varchar2(2000)

--Variables used for pfile adjustments:
var ChangePfile                   number
var AddPfileParameters            varchar2(2000)
var MyPfile                       varchar2(2000)
var MyPfileDir                    varchar2(2000)
var MySpfile                      varchar2(2000)
var DisablingAMMorASMM            number
var RemoveParameterList           varchar2(2000)
var AddParameterList              varchar2(2000)
var xV                            varchar2(2)
var xV$SESSION                    varchar2(2000)
var xV_$SESSION                   varchar2(2000)
var xV_$LOCK                      varchar2(2000)
var xV_$LOCKED_OBJECT             varchar2(2000)

--Variables used in pretests:
var V$Parameter                   number
var V$SgaInfo                     number
var V$Session                     number
var V$Database                    number
var DbaDataFiles                  number
var DbaTempFiles                  number
var DbaTablespaces                number
var NlsDatabaseParameters         number
var DbaRoles                      number
var DbaRolePrivs                  number
var DbaSysPrivs                   number
var DbaUsers                      number
var DbaViews                      number
var DbaSynonyms                   number
var DbaSource                     number
var DbaErrors                     number
var DbaSchedulerJobs              number
var V$Instance                    number
var V$SpParameter                 number
var DbaObjects                    number
var DbaLibraries                  number
var DbaFreeSpace                  number
var registry$history              number
var DbaRegistrySqlPatch           number
var DbmsUtility                   number
var ProductComponentVersion       number
var EnterpriseEdition             number
var DbaTsQuotas                   number
var DBATables                     number
var V$JobTable                    number
var DbaSegments                   number
var DbaTabStatistics              number
var SystemSqlplusProductProfile   number
var DbmsSystem                    number
var DbaTriggers                   number
var v$MemoryDynamicComponents     number

-- Database name variable
var dbvar	                      varchar2(15)

--Collect the database name
exec select SYS_CONTEXT('USERENV','DB_NAME') into :dbvar from dual;

-- put the value of dbvar in a bind variable (datab) and do the same for the systemtime (timestamp)
set termout off
column db NEW_VAL datab
select :dbvar db from dual;
column ts NEW_VAL timestamp
select to_char(sysdate,'yyyy_mm_dd-hh24miss') ts from dual;
set termout on

-- the spoolfile will contain the name of the database (datab) and a timestamp (timestamp) in the filename/path
spool FixMissing_&datab._&timestamp..sql

--Pretests
begin
	:OMPApplicationVersion:='&OMPApplicationVersion';
	if :OMPApplicationVersion>='06_07' then
		:xV                := 'GV';
	else                                         
		:xV                := 'V';
	end if;
	:xV$SESSION        := :xV||'$SESSION'        ;
	:xV_$SESSION       := :xV||'_$SESSION'       ;
	:xV_$LOCK          := :xV||'_$LOCK'          ;
	:xV_$LOCKED_OBJECT := :xV||'_$LOCKED_OBJECT' ;
end;
/


begin
	SELECT least(count(9),1) into :v$Parameter                 FROM all_tab_privs where table_schema='SYS'    and table_name='V_$PARAMETER';
	SELECT least(count(9),1) into :V$SgaInfo                   FROM all_tab_privs where table_schema='SYS'    and table_name='V_$SGAINFO';
	SELECT least(count(9),1) into :v$Session                   FROM all_tab_privs where table_schema='SYS'    and table_name='V_$SESSION';
	SELECT least(count(9),1) into :v$Database                  FROM all_tab_privs where table_schema='SYS'    and table_name='V_$DATABASE';
	SELECT least(count(9),1) into :DbaDataFiles                FROM all_tab_privs where table_schema='SYS'    and table_name='DBA_DATA_FILES';
	SELECT least(count(9),1) into :DbaTempFiles                FROM all_tab_privs where table_schema='SYS'    and table_name='DBA_TEMP_FILES';
	SELECT least(count(9),1) into :DbaTablespaces              FROM all_tab_privs where table_schema='SYS'    and table_name='DBA_TABLESPACES';
	SELECT least(count(9),1) into :DbaRoles                    FROM all_tab_privs where table_schema='SYS'    and table_name='DBA_ROLES';
	SELECT least(count(9),1) into :DbaRolePrivs                FROM all_tab_privs where table_schema='SYS'    and table_name='DBA_ROLE_PRIVS';
	SELECT least(count(9),1) into :DbaSysPrivs                 FROM all_tab_privs where table_schema='SYS'    and table_name='DBA_SYS_PRIVS';
	SELECT least(count(9),1) into :DbaUsers                    FROM all_tab_privs where table_schema='SYS'    and table_name='DBA_USERS';
	SELECT least(count(9),1) into :DbaViews                    FROM all_tab_privs where table_schema='SYS'    and table_name='DBA_VIEWS';
	SELECT least(count(9),1) into :DbaSynonyms                 FROM all_tab_privs where table_schema='SYS'    and table_name='DBA_SYNONYMS';
	SELECT least(count(9),1) into :DbaSource                   FROM all_tab_privs where table_schema='SYS'    and table_name='DBA_SOURCE';
	SELECT least(count(9),1) into :DbaErrors                   FROM all_tab_privs where table_schema='SYS'    and table_name='DBA_ERRORS';
	SELECT least(count(9),1) into :DbaSchedulerJobs            FROM all_tab_privs where table_schema='SYS'    and table_name='DBA_SCHEDULER_JOBS';
	SELECT least(count(9),1) into :v$Instance                  FROM all_tab_privs where table_schema='SYS'    and table_name='V_$INSTANCE';
	SELECT least(count(9),1) into :v$SpParameter               FROM all_tab_privs where table_schema='SYS'    and table_name='V_$SPPARAMETER';
	SELECT least(count(9),1) into :DbaObjects                  FROM all_tab_privs where table_schema='SYS'    and table_name='DBA_OBJECTS';
	SELECT least(count(9),1) into :DbaLibraries                FROM all_tab_privs where table_schema='SYS'    and table_name='DBA_LIBRARIES';
	SELECT least(count(9),1) into :DbaFreeSpace                FROM all_tab_privs where table_schema='SYS'    and table_name='DBA_FREE_SPACE';
	SELECT least(count(9),1) into :DbaTsQuotas                 FROM all_tab_privs where table_schema='SYS'    and table_name='DBA_TS_QUOTAS';
	SELECT least(count(9),1) into :DbmsUtility                 FROM all_tab_privs where table_schema='SYS'    and table_name='DBMS_UTILITY';
	SELECT least(count(9),1) into :ProductComponentVersion     FROM all_tab_privs where table_schema='SYS'    and table_name='PRODUCT_COMPONENT_VERSION';
	SELECT least(count(9),1) into :DBATables                   FROM all_tab_privs where table_schema='SYS'    and table_name='DBA_TABLES';
	SELECT least(count(9),1) into :NlsDatabaseParameters       FROM all_views     where owner=       'SYS'    and view_name ='NLS_DATABASE_PARAMETERS';
	SELECT least(count(9),1) into :registry$history            FROM all_tables    where owner=       'SYS'    and table_name='REGISTRY$HISTORY';
	SELECT least(count(9),1) into :DbaRegistrySqlPatch         FROM all_tab_privs where table_schema='SYS'    and table_name='DBA_REGISTRY_SQLPATCH';
	SELECT least(count(*),1) into :V$JobTable                  FROM all_tab_privs where table_schema='SYS'    and table_name='DBA_JOBS';
	SELECT least(count(9),1) into :DbaSegments                 FROM all_tab_privs where table_schema='SYS'    and table_name='DBA_SEGMENTS';
	SELECT least(count(9),1) into :DbaTabStatistics            FROM all_tab_privs where table_schema='SYS'    and table_name='DBA_TAB_STATISTICS';
	SELECT least(count(9),1) into :SystemSqlplusProductProfile FROM all_tables    where owner=       'SYSTEM' and table_name='SQLPLUS_PRODUCT_PROFILE';
	SELECT least(count(9),1) into :DbmsSystem                  FROM all_tab_privs where table_schema='SYS'    and table_name='DBMS_SYSTEM';
	SELECT least(count(9),1) into :v$MemoryDynamicComponents   FROM all_tab_privs where table_schema='SYS'    and table_name='V_$MEMORY_DYNAMIC_COMPONENTS';
end;
/


--Initialization global variables & version info
--Wide output for long userlists
set lines 2000
declare
	i                      number;
	Info                   varchar2(2500);
begin
	:Line:='--------------------------------------------------------------------------------------------------------------------------------------------------';
	:ErrorCount:=0;
	:WarningCount:=0;
	:NEWLINE:=chr(13)||chr(10);
	:NEWLINE:=chr(10);
	if upper('&info')='TRUE' then :info:=1; else :info:=0; end if;
	--Keeping track of Oracle ASM usage will be done when looking at datafiles; for now assume ASM is not used:
	:OracleASM:=0;

	:rqSharedPoolSize     :='&shared_pool_size';
	:rqDbCacheSize        :='&db_cache_size';
	:rqPgaAggregateTarget :='&pga_aggregate_target';
	:rqDmlLocks           :='&dml_locks';
	:rqProcesses          :='&processes';
	:UserList             :=upper('&UserList');
	:OMDINUser            :=upper('&OMDINUser');
   :FullUserList         :='';
   :PhysicalMemory      :=0;

	:UserListRequiringMJobCreation:='';
	:UserListLocked:='';
    
	if upper('&SkipSharedPackages')            = 'TRUE' then :SkipSharedPackages:=1;              else :SkipSharedPackages:=0;              end if;
	if upper('&SkipOMDBA')                     = 'TRUE' then :SkipOMDBA:=1;                       else :SkipOMDBA:=0;                       end if;
	if upper('&SkipOMDIN')                     = 'TRUE' then :SkipOMDIN:=1;                       else :SkipOMDIN:=0;                       end if;
	if upper('&SkipPublicSynonyms')            = 'TRUE' then :SkipPublicSynonyms:=1;              else :SkipPublicSynonyms:=0;              end if;
	if upper('&SkipVViews')                    = 'TRUE' then :SkipV$Views:=1;                     else :SkipV$Views:=0;                     end if;
	if upper('&SkipDBLink')                    = 'TRUE' then :SkipDBLink:=1;                      else :SkipDBLink:=0;                      end if;
	if upper('&SkipSharedSleep')               = 'TRUE' then :SkipSharedSleep:=1;                 else :SkipSharedSleep:=0;                 end if;
	if upper('&SkipOMDBADINDBTests')           = 'TRUE' then :SkipOMDBADINDBTests:=1;             else :SkipOMDBADINDBTests:=0;             end if;
	if upper('&SkipAddingPlanningLayerSuffix') = 'TRUE' then :SkipAddingPlanningLayerSuffix:=1;   else :SkipAddingPlanningLayerSuffix:=0;   end if;
	if upper('&SkipOMPDPDirectory')            = 'TRUE' then :SkipOMPDPDirectory:=1;              else :SkipOMPDPDirectory:=0;              end if;
    
	if upper('&SkipBounceMode')                = 'TRUE' 
	then 
	   :SkipBounceMode := 1;    
       :SafeMode       := '--SM ';	   
	else 
	   :SkipBounceMode := 0;                  
	   :SafeMode       := '';
	end if; 
    
	--Dependency between parameters: SkipOMDBA will overrule SkipSharedPackages !!!:
	if :SkipOMDBA=1 then :SkipSharedPackages:=1; end if;

	dbms_output.put_line('--   ConfigCheck script started on '||to_char(sysdate,'YYYY-MM-DD HH24:MI:SS')||'.');
	dbms_output.put_line('--   Build 06_10_007, 16-Oct-2019 09:56:45'||'.');

	--PortString (needed to let script switch between WIN_NT and LINUX/UNIX versions)
	--pretest
	if :DbmsUtility=0 or :ProductComponentVersion=0 then
		if :DbmsUtility=0 then dbms_output.put_line('--!  Result: Error: You do not have access to ''DBMS_UTILITY''. Run the ConfigCheck script ''AS SYSDBA''.'); :ErrorCount:=:ErrorCount+1; end if;
		if :ProductComponentVersion=0 then dbms_output.put_line('--!  Result: Error: You do not have access to ''PRODUCT_COMPONENT_VERSION''. Run the ConfigCheck script ''AS SYSDBA''.'); :ErrorCount:=:ErrorCount+1; end if;
		:OSWINNT:=-1; ---1 means OS could not be determined
	else
		execute immediate 'select dbms_utility.port_string from dual' into :PortString;
		if substr(:portstring,1,12)='IBMPC/WIN_NT' then
			:OSWINNT:=1;
		else
			:OSWINNT:=0;
		end if;
	end if;


	--EE
	if :ProductComponentVersion=0 then
		if :ProductComponentVersion=0 then 
			dbms_output.put_line('--!  Result: Error: You do not have access to ''PRODUCT_COMPONENT_VERSION''. Run the ConfigCheck script ''AS SYSDBA''.');
			:ErrorCount:=:ErrorCount+1;
			:EnterPriseEdition:=-1; --not known
		end if;
	else
		execute immediate 'select least(count(9),1) from product_component_version where product like ''%Enterprise Edition%''' into :EnterPriseEdition;
	end if;

	--Client info
	if :V$Session=0 then
		:ClientOSWINNT:=-1; ---1 means ClientOS could not be determined
	else
		--Keep track whether ConfigCheck is being run from Windows or not
		--Assuming here that you run ConfigCheck having privileges to v$session
		select program into :ClientProgram from v$session where sid = sys_context('userenv', 'sid');
		dbms_output.put_line('--   Run from program ' ||:ClientProgram||'.');

		if lower(:ClientProgram)<>'sqlplus.exe' then
			:ClientOSWINNT:=0;
			:ClientPathSeparator:='/';
		else
			:ClientOSWINNT:=1;
			:ClientPathSeparator:='\';
		end if;
		--dbms_output.put_line(:ClientOSWINNT);
	end if;

	--NLS_RDBMS_VERSION:
	--pretest
	if :NlsDatabaseParameters=0 then
		dbms_output.put_line('--!  Result: Error: You do not have access to ''NLS_RDBMS_VERSION''. Run the ConfigCheck script ''AS SYSDBA''.');
		:ErrorCount:=:ErrorCount+1;
	else
		execute immediate 'select value from SYS.NLS_DATABASE_PARAMETERS where parameter=''NLS_RDBMS_VERSION''' into :NLSRDBMSVERSION;
		--Add leading 0
		:NLSRDBMSVERSION00:='';
		:text:=:NLSRDBMSVERSION||'.';
		while length(:text)>0
		loop
			i:=instr(:text,'.'); -- POS .
			:xdigit:=substr(:text,1,i-1);
			:NLSRDBMSVERSION00:=:NLSRDBMSVERSION00||lpad(:xdigit,2,0)||'.';
			:text:=substr(:text,i+1,999);
		End loop;
		:NLSRDBMSVERSION00:=substr(:NLSRDBMSVERSION00,1,length(:NLSRDBMSVERSION00)-1);
		--End Add leading 0
		--Put the Major database release number (e.g. 12) in variable with shorter name:Keep short version:
		:Vxx:=substr(:NLSRDBMSVERSION00,1,2);
		:Vxx_yy:=substr(:NLSRDBMSVERSION00,1,5);
	end if;
end;
/
set lines 200

--Hostnames
select '--   Script started from hostname '||SYS_CONTEXT('USERENV','HOST')||'.' from dual;
select '--   Database hostname is '||SYS_CONTEXT('USERENV','SERVER_HOST')||' with database instance name '||SYS_CONTEXT('USERENV','DB_NAME')||'.' from dual;

--SqlPlus working directory
set termout off
set lines 32767
spool OM__defWorkingDirectory.cmd
begin
	if :ClientOSWINNT=1 then
		dbms_output.put_line('@echo exec :WorkingDirectory:=''%CD%''>OM__defWorkingDirectory.sql');
	else
		dbms_output.put_line('echo exec :WorkingDirectory:=\''$(pwd)\''>OM__defWorkingDirectory.sql');
	end if;
end;
/
spool off
host chmod u+x OM__defWorkingDirectory.cmd 2>>OM__Error
host OM__defWorkingDirectory.cmd 2>>OM__Error
host ./OM__defWorkingDirectory.cmd 2>>OM__Error
@OM__defWorkingDirectory.sql
set termout on

spool FixMissing_&datab._&timestamp..sql append
begin
	dbms_output.put_line('--   Working directory is "'||:WorkingDirectory||'".');
	dbms_output.put_line('--   Output of this script is available in file "'||:WorkingDirectory||:ClientPathSeparator||'FixMissing_'||'&datab'||'_'||'&timestamp'||'.sql".');

	dbms_output.put_line(:Line);
	--Display used script parameters
	dbms_output.put_line('--   Script parameters used:');
	dbms_output.put_line('--      Unicode=&Unicode');
	dbms_output.put_line('--      UserList=&UserList                                             ');
	dbms_output.put_line('--      OMDINUser=&OMDINUser                                           ');
	dbms_output.put_line('--      TablespaceSize_OMPARTNERS=&TablespaceSize_OMPARTNERS           ');
	dbms_output.put_line('--      TablespaceSize_INDEXES=&TablespaceSize_INDEXES                 ');
	dbms_output.put_line('--      TablespaceSize_TEMP=&TablespaceSize_TEMP                       ');
	dbms_output.put_line('--      TablespaceSize_SYSTEM=&TablespaceSize_SYSTEM                   ');
	dbms_output.put_line('--      TablespaceSize_SYSAUX=&TablespaceSize_SYSAUX                   ');
	dbms_output.put_line('--      TablespaceSize_OMDBA=&TablespaceSize_OMDBA                     ');
	dbms_output.put_line('--      shared_pool_size=&shared_pool_size                             ');
	dbms_output.put_line('--      db_cache_size=&db_cache_size                                   ');
	dbms_output.put_line('--      pga_aggregate_target=&pga_aggregate_target                     ');
	dbms_output.put_line('--      OMPApplicationVersion=&OMPApplicationVersion                   ');
	dbms_output.put_line('--      dml_locks=&dml_locks                                           ');
	dbms_output.put_line('--      processes=&processes                                           ');
	dbms_output.put_line('--      OMPDP_directory_path=&OMPDP_directory_path                     ');
	dbms_output.put_line('--      info=&info                                                     ');
	dbms_output.put_line('--      SkipSharedPackages=&SkipSharedPackages                         ');
	dbms_output.put_line('--      SkipSharedSleep=&SkipSharedSleep                               ');
	dbms_output.put_line('--      SkipOMDBA=&SkipOMDBA                                           ');
	dbms_output.put_line('--      SkipOMDIN=&SkipOMDIN                                           ');
	dbms_output.put_line('--      SkipPublicSynonyms=&SkipPublicSynonyms                         ');
	dbms_output.put_line('--      SkipVViews=&SkipVViews                                         ');
	dbms_output.put_line('--      SkipDBLink=&SkipDBLink                                         ');
	dbms_output.put_line('--      SkipOMDBADINDBTests=&SkipOMDBADINDBTests                       ');
	dbms_output.put_line('--      SkipAddingPlanningLayerSuffix=&SkipAddingPlanningLayerSuffix   ');
	dbms_output.put_line('--      SkipOMPDPDirectory=&SkipOMPDPDirectory                         ');
	dbms_output.put_line('--      SkipBounceMode=&SkipBounceMode                                 ');
	dbms_output.put_line(:Line);
end;
/

declare
	Info                   varchar2(2500);
	NLSRDBMSVERSIONShort   varchar2(20);
begin
	dbms_output.put_line('--   Requirement: release must be supported.');
	--Show the release info
	NLSRDBMSVERSIONShort:=substr(:NLSRDBMSVERSION,1,instr(:NLSRDBMSVERSION,'.',1,4)-1); --e.g. 12.1.0.1
	--Show full release/version info
	execute immediate 'select product ||''Release ''||version||'' - ''||status||'', on '' || portstring from product_component_version,(select dbms_utility.port_string portstring from dual) where product like ''%Oracle Database%''' into Info;
	--We will now display the Info, even if :Info=0 because this is too important to leave away
	dbms_output.put_line('--   Info: ' ||Info||'.');
	case
		when '06_10_007'='%%'||'RELEASE' then
				dbms_output.put_line('--!  Error: You are using an unofficial build of the ConfigCheck script.');
				dbms_output.put_line('--   Solution: Please contact OM Partners for an updated version of the ConfigCheck script.');
				:errorcount:=:errorcount+1;
		when :OMPApplicationVersion>substr('06_10_007',1,instr('06_10_007','_',1,2)-1) then
				dbms_output.put_line('--!  Error: This ConfigCheck script version 06_10_007 cannot be used to validate OMP application version '||:OMPApplicationVersion||'.');
				dbms_output.put_line('--   Solution: Please contact OM Partners for an updated version of the ConfigCheck script.');
				:errorcount:=:errorcount+1;
		else
			case
				when :NLSRDBMSVERSION00 > '12.02.00.01.99' then
					dbms_output.put_line('--!  Error: OM Partners applications do not yet support Oracle versions higher than 12.1.0.2.');
					:errorcount:=:errorcount+1;
				when :NLSRDBMSVERSION00 >= '12.01.00.02' and (:OMPApplicationVersion='05_54' or upper(:OMPApplicationVersion)='05_54A') then
					dbms_output.put_line('--!  Error: The product OMP Forecaster '||:OMPApplicationVersion||' is not supported on Oracle 12.1.0.2. Other '||:OMPApplicationVersion||' applications are supported.');
					:errorcount:=:errorcount+1;
				when :NLSRDBMSVERSION00 >= '12.01.00.02' and :OMPApplicationVersion<'05_54' then
						dbms_output.put_line('--!  Error: Oracle version 12.1.0.2 is not supported by OMP Application version '||:OMPApplicationVersion||'.');
					:errorcount:=:errorcount+1;
				when :NLSRDBMSVERSION00 >= '11.02.00' and :OMPApplicationVersion<'05_40' then
					dbms_output.put_line('--!  Error: Oracle version 11.2.0 requires OMP Application version 05_40 or higher.');
					:errorcount:=:errorcount+1;
				when :NLSRDBMSVERSION00 >= '11.01.00.06' and :OMPApplicationVersion<'05_22' then
					dbms_output.put_line('--!  Error: Oracle version 11.1.0 requires OMP Application version 05_22 or higher.');
					:errorcount:=:errorcount+1;
				when :NLSRDBMSVERSION00 >= '10.02.00' and :OMPApplicationVersion<'04_52' then
					dbms_output.put_line('--!  Error: Oracle version 10.2.0 requires OMP Application version 04_52 or higher.');
					:errorcount:=:errorcount+1;
				when :NLSRDBMSVERSION00 < '10.02.00' or :OMPApplicationVersion<'04_52' then
					dbms_output.put_line('--(!) Warning: This version of ConfigCheck cannot verify application '||:OMPApplicationVersion||' compatibility with this version of Oracle. Please contact OM Partners for more information.');
					:errorcount:=:errorcount+1;
				else
					dbms_output.put_line('--   Result: OK, OM Partners applications version '||:OMPApplicationVersion||' exist for Oracle release '|| NLSRDBMSVERSIONShort||'.');
			end case;
		end case;
	dbms_output.put_line(:Line);
end;
/

--No container database
--since expdp recommended, directory obj mandatory
declare
	CDB varchar(10);
begin
	if :NLSRDBMSVERSION00>='12' then
		dbms_output.put_line('--   Requirement: Database should not be a container database.');
		if :V$Database=0 then
			dbms_output.put_line('--!  Result: Error: You do not have access to ''V_$DATABASE''. Run the ConfigCheck script ''AS SYSDBA''.');
			:ErrorCount:=:ErrorCount+1;
		else
			execute immediate 'SELECT CDB FROM V$DATABASE' into CDB;
			if CDB='NO' then
				dbms_output.put_line('--   Result: OK.');
			else --CDB='YES', other values do not exist.
				dbms_output.put_line('--!  Error: The database was installed as a container database.');
				:errorcount:=:errorcount+1;
				dbms_output.put_line('--   Solution: Reinstall the database, this time not as a container database.');
			end if;
		end if;
		dbms_output.put_line(:Line);
	--else Container database did not exist until Oracle 12; silently skip this test since it is irrelevant
	end if;
end;
/

declare
	OMPDPDIR            number;
	RqOMPDPPath         varchar2(2000);
	OMPDPPath           varchar2(2000);
	GrantOMPDP          number:=0;
	DefaultSpecified    number:=0;
begin
	:DirectoryOMPDPExists:=0; --Assume it exists; this will suppress further privilege checking in Users section when OMPDP is not relevant.
	if :SkipOMPDPDirectory<>1 then
		if upper(substr(SYS_CONTEXT('USERENV','HOST'),0,10))<>'OMPARTNERS' then
			if :OMPApplicationVersion>='06_04' then
				dbms_output.put_line('--   Requirement: Database should have a directory object named OMPDP to be used with datapump.');
	
				--Get default if needed
				if lower('&OMPDP_directory_path')=lower('<Default_DATA_PUMP_DIR_path>') or lower('&OMPDP_directory_path')=lower('Default') then
					DefaultSpecified:=1;
					execute immediate 'select directory_path from all_directories where directory_name =''DATA_PUMP_DIR'''into RqOMPDPPath;
					--Fix mixed slashes on Windows
					if :OSWINNT=1 then RqOMPDPPath:=replace(RqOMPDPPath,'/','\'); end if;
					dbms_output.put_line('--   Info: The ConfigCheck header does not specify a custom path for your OMPDP directory. Defaulting to '''||RqOMPDPPath||'''.');
				else
					RqOMPDPPath:='&OMPDP_directory_path';
				end if;
	
				execute immediate 'select count(1) from all_directories where directory_name =''OMPDP''' into OMPDPDIR;
				if OMPDPDIR=1 then
					:DirectoryOMPDPExists:=1;
					execute immediate 'select directory_path from all_directories where directory_name =''OMPDP'''into OMPDPPath;
					if :info=1 then dbms_output.put_line('--   Info: Directory object OMPDP exists and points to '''||OMPDPPath||'''.'); end if;
					if OMPDPPath=RqOMPDPPath or DefaultSpecified=1 then
						if OMPDPPath<>RqOMPDPPath then
							dbms_output.put_line('--   Info: The OMPDP folder '''||OMPDPPath||''' is not the default location, but we assume this was set up intentionally.');
							dbms_output.put_line('--   Result: OK.');
						else
							dbms_output.put_line('--   Result: OK.');
						end if;
					else
						dbms_output.put_line('--(!)Warning: The OMPDP directory path points to '''||OMPDPPath||''' instead of to '''||RqOMPDPPath||'''. If this is unwanted execute the following solution:');
						:warningcount:=:warningcount+1;
						dbms_output.put_line('--   Solution: re-create a directory object with the following statement:');
						dbms_output.put_line('create or replace directory OMPDP as '''||RqOMPDPPath||''';'); --Note that this will preserve privileges.
					end if;
				else --OMPDPDIR=0, other values not expected
					:DirectoryOMPDPExists:=0;
					dbms_output.put_line('--!  Error: OMPDP directory object does not exist. ');
					:errorcount:=:errorcount+1;
					dbms_output.put_line('--   Solution: create a directory object with the following statement:');
					dbms_output.put_line('create directory OMPDP as '''||RqOMPDPPath||''';');
					dbms_output.put_line('grant read, write on directory ompdp to ompuser;');
					GrantOMPDP:=2;
				end if;
				dbms_output.put_line(:Line);
				
			--else
				--usage of expdp is recommended as of 12c, not mandatory on lower versions
			end if;
		--else
			--ConfigCheck header is configured to skip checking OMPDP directory
		end if;
	--else
		--In OMPARTNERS OMPDP is different and depending on server vs laptop/desktop, we can ignore this test internally.
	end if;
end;
/


--Logged in as sysdba ?
begin
	dbms_output.put_line('--   Requirement: Run the ConfigCheck script ''AS SYSDBA''.');
	if :info>=1 then dbms_output.put_line('--   Info: LOGIN: '||'&_USER@&_CONNECT_IDENTIFIER'||' '||'&_PRIVILEGE'||'.'); end if;
	if '''&_PRIVILEGE'''<>'''AS SYSDBA''' then
		dbms_output.put_line('--!  Result: Error: Incorrect login. Run the ConfigCheck script ''AS SYSDBA''.');
		:ErrorCount:=:ErrorCount+1;
		dbms_output.put_line('--   Solution: Reconnect ''AS SYSDBA'' and try again:');
		dbms_output.put_line('connect sys@&_connect_identifier as sysdba');
	else
		dbms_output.put_line('--   Result: OK.');
	end if;
	dbms_output.put_line(:Line);
end;
/

--Data validation
declare
	NumberText                        varchar2(2000); --e.g. 400m
	NumberUNIT                        varchar2(1);    --e.g. M   (K,M,G,T)
	NumberNumber                      number;         --e.g. 400
	
	function IsValidKMGValue (numbertext IN varchar2) return boolean as
begin
		if instr('KMG0123456789',substr(upper(numbertext),-1,1))>0 --last char should be 0-9|K|M|G
		   and 
		   translate(substr(upper(numbertext),0,length(numbertext)-1),'A0123456789','A') is null --other chars should be all 0-9
		then
			return TRUE;
		else
			return FALSE;
		end if;
	end;
	
	procedure ReportError(Name IN varchar2, value IN varchar2) as
	begin
		dbms_output.put_line('--! ERROR: The provided parameter '||Name||' has invalid value '||Value||'. Please review the ConfigCheck header lines.');
		:ErrorCount:=:ErrorCount+1;
		dbms_output.put_line(:Line);
	end;

begin
	--Validation of numeric parameters provided
   if not IsValidKMGValue('&shared_pool_size'         ) then ReportError('shared_pool_size'          ,'&shared_pool_size'         ); end if;
   if not IsValidKMGValue('&db_cache_size'            ) then ReportError('db_cache_size'             ,'&db_cache_size'            ); end if;
   if not IsValidKMGValue('&pga_aggregate_target'     ) then ReportError('pga_aggregate_target'      ,'&pga_aggregate_target'     ); end if;
   if not IsValidKMGValue('&dml_locks'                ) then ReportError('dml_locks'                 ,'&dml_locks'                ); end if;
   if not IsValidKMGValue('&processes'                ) then ReportError('processes'                 ,'&processes'                ); end if;
   if not IsValidKMGValue('&TablespaceSize_OMPARTNERS') then ReportError('TablespaceSize_OMPARTNERS' ,'&TablespaceSize_OMPARTNERS'); end if;
   if not IsValidKMGValue('&TablespaceSize_INDEXES'   ) then ReportError('TablespaceSize_INDEXES'    ,'&TablespaceSize_INDEXES'   ); end if;
   if not IsValidKMGValue('&TablespaceSize_SYSTEM'    ) then ReportError('TablespaceSize_SYSTEM'     ,'&TablespaceSize_SYSTEM'    ); end if;
   if not IsValidKMGValue('&TablespaceSize_SYSAUX'    ) then ReportError('TablespaceSize_SYSAUX'     ,'&TablespaceSize_SYSAUX'    ); end if;
   if not IsValidKMGValue('&TablespaceSize_TEMP'      ) then ReportError('TablespaceSize_TEMP'       ,'&TablespaceSize_TEMP'      ); end if;
   if not IsValidKMGValue('&TablespaceSize_OMDBA'     ) then ReportError('TablespaceSize_OMDBA'      ,'&TablespaceSize_OMDBA'     ); end if;

	if IsValidKMGValue('&shared_pool_size'         ) then
	--Shared_pool_size should have been specified as at least 400m
	NumberText:=:rqSharedPoolSize;
	NumberUNIT:=upper(substr(NUMBERTEXT,-1,1));
	NumberNumber:=translate(NUMBERTEXT,'0123456789kKmMgG','0123456789')*power(1024,instr('KMG',NUMBERUNIT,1));
	if NumberNumber<400*1024*1024 then
			dbms_output.put_line('--(!)Result: WARNING: OMPartners applications typically need shared_pool_size of at least 400m. Review parametervalue '||NumberText||' in ConfigCheck header lines.');
		:warningcount:=:warningcount+1;
		dbms_output.put_line(:Line);
	end if;
	end if;
end;
/


-------------------------------------------------------------------------------------
-- ASCII/UNICODE --------------------------------------------------------------------
-------------------------------------------------------------------------------------

begin
	--NLSCHARACTERSET
	dbms_output.put_line('--   Requirement: Database must have appropriate characterset.');
	--pretest
	if :NlsDatabaseParameters=0 then
		--We can use Oracle DUMP function as alternative for this parameter
		select substr(dump(dummy, 1010), instr(dump(dummy, 1010), '=', 1, 3)+1, instr(dump(dummy, 1010), ':') - instr(dump(dummy, 1010), '=', 1, 3) - 1) "DB Character Set" into :NLSCHARACTERSET from dual;
	else
		execute immediate 'select value from SYS.NLS_DATABASE_PARAMETERS where parameter=''NLS_CHARACTERSET''' into :NLSCHARACTERSET;
	end if;
	if :info>=1 then dbms_output.put_line('--   Info: NLS_CHARACTERSET='||:NLSCHARACTERSET||'.'); end if;
	if upper('&Unicode')='TRUE' then
		if :NLSCHARACTERSET='AL32UTF8' then
			dbms_output.put_line('--   Result: OK.');
		else
			dbms_output.put_line('--!  Result: Error: Database is not set up correctly for UNICODE use.');
			:ErrorCount:=:ErrorCount+1;
			dbms_output.put_line('--   Reason: NLS_CHARACTERSET='||:NLSCHARACTERSET||' but must be=AL32UTF8.');
			dbms_output.put_line('--   Solution: RECREATE DATABASE with NLS_CHARACTERSET=AL32UTF8.');
		end if;
	else --ASCII
		if :NLSCHARACTERSET='WE8ISO8859P15' then
			dbms_output.put_line('--   Result: OK.');
		else
			dbms_output.put_line('--!  Result: Error: Database is not set up correctly for ASCII use.');
			:ErrorCount:=:ErrorCount+1;
			dbms_output.put_line('--   Reason: NLS_CHARACTERSET='||:NLSCHARACTERSET||' but must be=WE8ISO8859P15.');
			dbms_output.put_line('--   Solution: RECREATE DATABASE with NLS_CHARACTERSET=WE8ISO8859P15.');
		end if;
	end if;
	dbms_output.put_line(:Line);
end;
/

begin
	--NLS_NCHAR_CHARACTERSET
	dbms_output.put_line('--   Requirement: Database must have appropriate national characterset');
	--Should be AL16UTF16, even for ASCII implementations (note that adstatdparameter table has Nvarchar2 even in ascii implementations)
	--pretest
	if :NlsDatabaseParameters=0 then
		dbms_output.put_line('--!  Result: Error: You do not have access to ''NLS_NCHAR_CHARACTERSET''. Run the ConfigCheck script ''AS SYSDBA''.');
		:ErrorCount:=:ErrorCount+1;
	else
		execute immediate 'select value from SYS.NLS_DATABASE_PARAMETERS where parameter=''NLS_NCHAR_CHARACTERSET''' into :NLSNCHARCHARACTERSET;
		if :info>=1 then dbms_output.put_line('--   Info: NLS_NCHAR_CHARACTERSET='||:NLSNCHARCHARACTERSET); end if;
		if :NLSNCHARCHARACTERSET='AL16UTF16' then
			dbms_output.put_line('--   Result: OK.');
		else
			dbms_output.put_line('--!  Result: Error: Database is not set up correctly');
			:ErrorCount:=:ErrorCount+1;
			dbms_output.put_line('--   Reason: NLS_NCHAR_CHARACTERSET='||:NLSNCHARCHARACTERSET||' but must be=AL16UTF16');
			dbms_output.put_line('--   Reason: Using AL16UTF16 is typically faster than UTF8, and avoids conversion bugs.');
			dbms_output.put_line('--   Solution: Recreate database');
		end if;
	end if;
	dbms_output.put_line(:Line);
end;
/

begin
	--NLS_RDBMS_VERSION - UNICODE only
	if upper('&Unicode')='TRUE' then
		dbms_output.put_line('--   Requirement: Database must be at least version 10.2 for UNICODE 4.0 support');
		--pretest
		if :NlsDatabaseParameters=0 then
			dbms_output.put_line('--!  Result: Error: You do not have access to ''NLS_RDBMS_VERSION''. Run the ConfigCheck script ''AS SYSDBA''.');
			:ErrorCount:=:ErrorCount+1;
		else
			--:NLSRDBMSVERSION00 was already defined above
			if :NLSRDBMSVERSION00>='10.02.00.01.00' then
				dbms_output.put_line('--   Result: OK.');
			else
				dbms_output.put_line('--!  Result: Error: Database does not support the required UNICODE 4.0');
				:ErrorCount:=:ErrorCount+1;
				dbms_output.put_line('--   Reason: NLS_RDBMS_VERSION='||:NLSRDBMSVERSION||' but must be at least 10.2.0.1.0');
				dbms_output.put_line('--   Solution: Upgrade database to higher Oracle version');
			end if;
		end if;
		dbms_output.put_line(:Line);
	end if;
end;
/

-------------------------------------------------------------------------------------
-- GET FREEDISKSPACE OF INSTANCE HOST LOCAL DISKS -----------------------------------
-------------------------------------------------------------------------------------
begin
	if :Info>0 then dbms_output.put_line('--   Info: System information:'); end if;
	if :OSWINNT=0 then
		if :Info>0 then dbms_output.put_line('--      Disk info:               Please check disk space in your operating system.'); end if;
	else
		if :Info>0 then dbms_output.put_line('--      Disk info:'); end if;
	end if;
end;
/
--Get available diskspace
--Method used (Windows):
--   .cmd will be created (spool) which uses WMIC to collect available diskspace.
--   Collection is limited to local harddrives (no network shares or removable media).
--   The results of WMIC are written to an .sql file, which is executed to store the results in global variables
--   Collection is limited to drives belonging to the hostname of the server instance.
var freediskspaceA              number
var freediskspaceB              number
var freediskspaceC              number
var freediskspaceD              number
var freediskspaceE              number
var freediskspaceF              number
var freediskspaceG              number
var freediskspaceH              number
var freediskspaceI              number
var freediskspaceJ              number
var freediskspaceK              number
var freediskspaceL              number
var freediskspaceM              number
var freediskspaceN              number
var freediskspaceO              number
var freediskspaceP              number
var freediskspaceQ              number
var freediskspaceR              number
var freediskspaceS              number
var freediskspaceT              number
var freediskspaceU              number
var freediskspaceV              number
var freediskspaceW              number
var freediskspaceX              number
var freediskspaceY              number
var freediskspaceZ              number
var FreediskspaceInfoAvailable  number
begin
	:FreediskspaceInfoAvailable:=0;
end;
/

--WIN_NT BEGIN-----------------------------------------------------------------
set echo off
SET SERVEROUTPUT ON FORMAT WRAPPED
set verify off
set feedback off
set timing off
set heading off
set lines 2000
set trimspool on
spool OM__GetOSInfo.cmd
set termout off
declare
	Ihostname varchar2(100);
begin
	--pretest
	if :v$instance=0 then
		dbms_output.put_line('@echo off');
		--looking for disk space not possible, so create empty .sql so further script execution continues without errors
		if :ClientOSWINNT=1 then
			dbms_output.put_line('type nul> OM__defOSInfo.sql');
		else
			dbms_output.put_line('echo -->OM__defOSInfo.sql');
		end if;
	else
		execute immediate 'select host_name from sys.v_$instance' into Ihostname;
		if :ClientOSWINNT=1 then
			--header
			dbms_output.put_line('@echo off');
			dbms_output.put_line('if exist OM__defOSInfo.sql del OM__defOSInfo.sql');
			dbms_output.put_line('echo begin>> OM__defOSInfo.sql');
			--Free diskspace
			dbms_output.put_line('if exist OM__freediskspaceError.txt del OM__freediskspaceError.txt');
			dbms_output.put_line('wmic /output:OM__freediskspace.txt /node:"'||Ihostname||'" logicaldisk where drivetype=3 get deviceid,drivetype,freespace,systemname 2>OM__FreediskspaceError.txt');
			dbms_output.put_line('for /F "skip=1 tokens=1-4 delims=: " %%A in (''type OM__freediskspace.txt'') do ('); --type does required file format conversion
			dbms_output.put_line('   if "%%D"=="'||Ihostname||'" echo :freediskspace%%A:=%%C;>> OM__defOSInfo.sql');
			dbms_output.put_line('   )');
			dbms_output.put_line('for %%R in (OM__FreediskspaceError.txt) do if %%~zR equ 0 (echo :FreediskspaceInfoAvailable:=1;>> OM__defOSInfo.sql) else (echo :FreediskspaceInfoAvailable:=0;>> OM__defOSInfo.sql)');
			dbms_output.put_line('echo null;>> OM__defOSInfo.sql'); --needed if no drives were found to avoid empty block
			dbms_output.put_line('if exist OM__freediskspace.txt del OM__freediskspace.txt'); --cleanup .txt
			--Physical memory
			dbms_output.put_line('for /F "skip=1" %%a in (''wmic memorychip get capacity ^| findstr /r /v "^$" '') do @echo :PhysicalMemory:=:PhysicalMemory+1.0*%%a;>> OM__defOSInfo.sql');
			--Processortype
			dbms_output.put_line('wmic cpu get name > OM__CpuType.txt');
			dbms_output.put_line('wmic cpu get name > OM__CpuType.txt');
			dbms_output.put_line('for /F "tokens=*" %%a in (''type OM__CpuType.txt ^| findstr /r /v /c:"^$" /c:^Name '') do @echo :ProcessorType:=trim(''%%a'');>> OM__defOSInfo.sql');
			dbms_output.put_line('if exist OM__CpuType.txt del OM__CpuType.txt');
			--OSBootTime
			dbms_output.put_line('for /F "skip=1" %%a in (''wmic OS Get LastBootUpTime ^| findstr /r /v "^$" '') do @echo :OSBootTime:=''%%a'';>> OM__defOSInfo.sql');
			--footer
			dbms_output.put_line('echo end;>> OM__defOSInfo.sql');
			dbms_output.put_line('echo />> OM__defOSInfo.sql');
		else
			--header
			dbms_output.put_line('echo begin>OM__defOSInfo.sql');
			--Processortype
			dbms_output.put_line('cat /proc/cpuinfo | grep "model name" | sort -u | awk ''{print ":ProcessorType:=\47" substr($0, index($0,$4)) "\47\;"}''\;>>OM__defOSInfo.sql');
			--Physical memory
			dbms_output.put_line('(awk ''/MemTotal/ {print ":PhysicalMemory:=1024.0*"$2";"}'' /proc/meminfo)>>OM__defOSInfo.sql');
			--OSBootTime
			dbms_output.put_line('echo :OSBootTime:=\''$(who -b |  sed  ''s/system boot//'' | { read mydate; date -d "$mydate" "+%Y%m%d%H%M%S";} )\''\;>> OM__defOSInfo.sql');
			--footer
			dbms_output.put_line('echo end\;>> OM__defOSInfo.sql');
			dbms_output.put_line('echo />>OM__defOSInfo.sql');
			--Unix commands to be added here in next version
			--Remark that the script below is executed on the CLIENT which runs configcheck (can be Windows or Unix)
			dbms_output.put_line('echo -->>OM__defOSInfo.sql');
		end if;
	end if;
end;
/

spool off
--continue original spoolfile
spool FixMissing_&datab._&timestamp..sql append
--Run the script in Windows and Unix; this will create the defGetOSInfo.sql which will be executed further
host OM__GetOSInfo.cmd 2>>OM__Error
host chmod u+x OM__GetOSInfo.cmd 2>>OM__Error
host ./OM__GetOSInfo.cmd 2>>OM__Error
--Cleanup of generating .cmd
host del OM__GetOSInfo.cmd 2>>OM__Error
host rm OM__GetOSInfo.cmd 2>>OM__Error
--Import the obtained info by running the generated .sql
start OM__defOSInfo.sql

--Cleanup .sql
host del OM__defOSInfo.sql 2>>OM__Error
host rm OM__defOSInfo.sql 2>>OM__Error
set termout on

--Report on OS info
declare
	Ihostname     varchar2(100);
	Shostname     varchar2(100);
	DbStartupTime varchar2(100);
	DbUpTime      varchar2(100);
	OSBootDate    date;
	OutputText    varchar2(2000);
	
	function NumberToKMGtext (NumberIn in number) return varchar2 as
		NumberUNIT                         varchar2(1);
		NumberText                         varchar2(2000);
		Units                              varchar2(10):='KMG';
	begin
		if NumberIn<>0 then
			NumberUNIT:=' ';
			NumberText:=NumberIn;
			for i in 1..length(Units) loop
				if numbertext mod 1024 = 0 then
					numberunit:=substr(Units,i,1);
					numbertext:=numbertext/1024;
				end if;
			end loop;
			return numbertext||' '||trim(numberunit);
		else
			return '0';
		end if;
	end;

begin
	if :V$instance>0 then
		execute immediate 'select host_name from v$instance' into Ihostname;
		--dbms_output.put_line('Ihostname='||Ihostname);
		execute immediate 'select SYS_CONTEXT(''USERENV'',''HOST'') from dual' into Shostname;
		--In Win_NT, domain is added to above HOST, therefore let's now strip the domain prefix (if any); in Linux nothing will have to be stripped; as long as host does not contain '\', we do not have to differentiate between Win/Linux.
		Shostname:=substr(Shostname,instr(Shostname,'\')+1);
		--dbms_output.put_line('Ihostname='||Shostname);
		if Ihostname<>Shostname then
			dbms_output.put_line('--!  Error: You must run the ConfigCheck script from machine '||IHostname||' to enable checking system information like memory and free disk space.');
			:errorcount:=:errorcount+1;
			dbms_output.put_line(:Line);
			--Keep difference info
		else
			if :info>=1 then
				if :freediskspaceA>0 then dbms_output.put_line('--         Free space on disk A:'|| lpad(round(:freediskspaceA/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceB>0 then dbms_output.put_line('--         Free space on disk B:'|| lpad(round(:freediskspaceB/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceC>0 then dbms_output.put_line('--         Free space on disk C:'|| lpad(round(:freediskspaceC/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceD>0 then dbms_output.put_line('--         Free space on disk D:'|| lpad(round(:freediskspaceD/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceE>0 then dbms_output.put_line('--         Free space on disk E:'|| lpad(round(:freediskspaceE/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceF>0 then dbms_output.put_line('--         Free space on disk F:'|| lpad(round(:freediskspaceF/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceG>0 then dbms_output.put_line('--         Free space on disk G:'|| lpad(round(:freediskspaceG/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceH>0 then dbms_output.put_line('--         Free space on disk H:'|| lpad(round(:freediskspaceH/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceI>0 then dbms_output.put_line('--         Free space on disk I:'|| lpad(round(:freediskspaceI/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceJ>0 then dbms_output.put_line('--         Free space on disk J:'|| lpad(round(:freediskspaceJ/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceK>0 then dbms_output.put_line('--         Free space on disk K:'|| lpad(round(:freediskspaceK/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceL>0 then dbms_output.put_line('--         Free space on disk L:'|| lpad(round(:freediskspaceL/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceM>0 then dbms_output.put_line('--         Free space on disk M:'|| lpad(round(:freediskspaceM/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceN>0 then dbms_output.put_line('--         Free space on disk N:'|| lpad(round(:freediskspaceN/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceO>0 then dbms_output.put_line('--         Free space on disk O:'|| lpad(round(:freediskspaceO/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceP>0 then dbms_output.put_line('--         Free space on disk P:'|| lpad(round(:freediskspaceP/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceQ>0 then dbms_output.put_line('--         Free space on disk Q:'|| lpad(round(:freediskspaceQ/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceR>0 then dbms_output.put_line('--         Free space on disk R:'|| lpad(round(:freediskspaceR/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceS>0 then dbms_output.put_line('--         Free space on disk S:'|| lpad(round(:freediskspaceS/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceT>0 then dbms_output.put_line('--         Free space on disk T:'|| lpad(round(:freediskspaceT/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceU>0 then dbms_output.put_line('--         Free space on disk U:'|| lpad(round(:freediskspaceU/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceV>0 then dbms_output.put_line('--         Free space on disk V:'|| lpad(round(:freediskspaceV/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceW>0 then dbms_output.put_line('--         Free space on disk W:'|| lpad(round(:freediskspaceW/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceX>0 then dbms_output.put_line('--         Free space on disk X:'|| lpad(round(:freediskspaceX/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceY>0 then dbms_output.put_line('--         Free space on disk Y:'|| lpad(round(:freediskspaceY/1024/1024/1024,0),6) ||' Gb.'); end if;
				if :freediskspaceZ>0 then dbms_output.put_line('--         Free space on disk Z:'|| lpad(round(:freediskspaceZ/1024/1024/1024,0),6) ||' Gb.'); end if;
				if not :ProcessorType is null then dbms_output.put_line('--      Processor type:          '|| :ProcessorType||'.'); end if;
	--			dbms_output.put_line(':PhysicalMemory='||:PhysicalMemory||'.');
				if :PhysicalMemory>0 then
					OutputText:='--      Physical memory:         '|| NumberToKMGText(:PhysicalMemory)||'b';
					if NumberToKMGText(:PhysicalMemory)<>replace(NumberToKMGText(:PhysicalMemory),'G','') and round(:PhysicalMemory/1024/1024/1024)>0.0 /*otherwise 0.0 Gb is useless info*/ then
						OutputText:=OutputText||'.';
					else
						OutputText:=OutputText||' ('||ltrim(to_char(:PhysicalMemory/1024/1024/1024,'99999990.0'))||' Gb).';
					end if;
					dbms_output.put_line(OutputText);
				end if;
	--			dbms_output.put_line(':OSBootTime='||:OSBootTime||'.');
				if not :OSBootTime    is null then
					OSBootDate:=to_date(substr(:OsBootTime,0,14),'YYYYMMDDHH24MISS'||'.');
	--				dbms_output.put_line('OSBootDate='||OSBootDate);
					dbms_output.put_line('--      System last boot time:   '|| to_char(OSBootDate,'DD-MON-YYYY HH24:MI:SS')||'.');
					dbms_output.put_line('--      System uptime:           '|| floor(sysdate - OSBootDate)||' day(s) '||trunc( 24*((sysdate-OSBootDate)-trunc(sysdate-OSBootDate)))||' hour(s) '||mod(trunc(1440*((sysdate-OSBootDate)-trunc(sysdate-OSBootDate))), 60) ||' minute(s) '||mod(trunc(86400*((sysdate-OSBootDate)-trunc(sysdate-OSBootDate))), 60) ||' second(s)'||'.');
				end if;
			end if;
		end if;
		
		--Add generic database info like database StartupTime/UpTime
		if :info>=1 then
			execute immediate 'select to_char(startup_time,''DD-MON-YYYY HH24:MI:SS'') startup_time from sys.v$instance' into DbStartupTime;
			execute immediate 'select floor(sysdate - startup_time)||'' day(s) ''||trunc( 24*((sysdate-startup_time)-trunc(sysdate-startup_time)))||'' hour(s) ''||mod(trunc(1440*((sysdate-startup_time)-trunc(sysdate-startup_time))), 60) ||'' minute(s) ''||mod(trunc(86400*((sysdate-startup_time)-trunc(sysdate-startup_time))), 60) ||'' second(s)'' from v$instance' into DbUpTime;
			dbms_output.put_line('--      Database startup time:   '||DbStartupTime||'.');
			dbms_output.put_line('--      Database uptime:         '||DbUpTime||'.');
		end if;
	else
		dbms_output.put_line('--!  Result: Error: You do not have access to ''V$INSTANCE''. Run the ConfigCheck script ''AS SYSDBA''.');
		:errorcount:=:errorcount+1;
	end if;
	--End of system information
	dbms_output.put_line(:Line);
end;
/

--From now on, global variables freediskpaceA-Z will contain the freediskspace for each local harddrive of the instance host, if it could be obtained.
--WIN_NT END -----------------------------------------------------------------


-------------------------------------------------------------------------------------
-- TABLESPACES ----------------------------------------------------------------------
-------------------------------------------------------------------------------------
--Give info on existing situation
declare
	FormatMb                                 varchar2(30);
	FormatPct                                varchar2(30);
	type TablespaceRecord is                 record (Tablespace_Name varchar2(30), TotalMB number, UsedMB number, FreeMB number, UsedPct number, FreePct number);
	type TablespaceRecords is table of       TablespaceRecord;
	ExistingTablespaces                      TablespaceRecords:=TablespaceRecords();
	type TSFile is                           record (Tablespace_Name varchar2(30), File_Name varchar2(513), FilesizeMB number, Status varchar2(9), AutoExtensible varchar2(3), MaxSizeMB number);
	type TSFiles is table of                 TSFile;
	ExistingTSFiles                          TSFiles:=TSFiles();
begin
	if :Info>0 then
		dbms_output.put_line('--   Info: Overview of actual tablespace usage:');
		FormatMb :='99999990.9';
		FormatPct:='990.9';

		--TABLESPACE TOTALS
		--pretest
		if :DbaDataFiles=0 or :DbaFreeSpace=0 then
			if :DbaDataFiles=0 then
				dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_DATA_FILES''. Run the ConfigCheck script ''AS SYSDBA''.');
				:ErrorCount:=:ErrorCount+1;
			end if;
			if :DbaFreeSpace=0 then
				dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_FREE_SPACE''. Run the ConfigCheck script ''AS SYSDBA''.');
				:ErrorCount:=:ErrorCount+1;
			end if;
		else -- Pretest ok
			execute immediate 'select	df.TABLESPACE_NAME tablespace_name, df.BYTES/1024/1024 TotalMb, (df.Bytes-nvl(fs.bytes,0))/1024/1024 UsedMb, fs.BYTES/1024/1024 FreeMb, (df.BYTES-nvl(fs.BYTES,0))*100/df.BYTES UsedPct, (nvl(fs.BYTES,0))*100/df.BYTES FreePct from (select  TABLESPACE_NAME, sum(BYTES) BYTES from  SYS.DBA_DATA_FILES  group  by TABLESPACE_NAME ) df, (select  TABLESPACE_NAME,sum(BYTES) BYTES from  SYS.DBA_free_space group  by TABLESPACE_NAME)fs where df.TABLESPACE_NAME=fs.TABLESPACE_NAME(+) order by df.TABLESPACE_NAME' bulk collect into ExistingTablespaces;
			dbms_output.put_line('--      Tablespace_Name                  TotalMB    UsedMB    FreeMB UsedPct FreePct');
			dbms_output.put_line('--      ------------------------------ --------- --------- --------- ------- -------');
			FOR t in 1 .. ExistingTablespaces.count LOOP
				dbms_output.put_line('--      '||rpad(ExistingTablespaces(t).tablespace_name,30)||lpad(to_char(ExistingTablespaces(t).TotalMb,FormatMb),10)||lpad(to_char(ExistingTablespaces(t).UsedMb,FormatMb),10)||lpad(nvl(to_char(ExistingTablespaces(t).FreeMb,FormatMb),' '),10)||lpad(to_char(ExistingTablespaces(t).UsedPct,FormatPct),8)||lpad(to_char(ExistingTablespaces(t).FreePct,FormatPct),8));
			END LOOP;
		end if;

		--FILES
		if :DbaDataFiles=0 or :DbaTempFiles=0 then
			if :DbaDataFiles=0 then
				dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_DATA_FILES''. Run the ConfigCheck script ''AS SYSDBA''.');
				:ErrorCount:=:ErrorCount+1;
			end if;
			if :DbaTempFiles=0 then
				dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_TEMP_FILES''. Run the ConfigCheck script ''AS SYSDBA''.');
				:ErrorCount:=:ErrorCount+1;
			end if;
		else -- Pretest ok
		--execute immediate 'SELECT TABLESPACE_NAME /*, FILE_NAME, BYTES/1024/1024 FilesizeMb, STATUS, autoextensible, MAXBYTES/1024/1024 MaxsizeMb*/ from SYS.DBA_DATA_FILES  order by tablespace_name, file_name' bulk collect into ExistingTSFiles;
		execute immediate 'select * from (SELECT TABLESPACE_NAME, FILE_NAME, BYTES/1024/1024 FilesizeMb, STATUS, autoextensible, MAXBYTES/1024/1024 MaxsizeMb from SYS.DBA_DATA_FILES UNION ALL SELECT TABLESPACE_NAME, FILE_NAME, BYTES/1024/1024 FilesizeMb, STATUS, autoextensible, MAXBYTES/1024/1024 MaxsizeMb from SYS.DBA_temp_files) order by tablespace_name, file_name' bulk collect into ExistingTSFiles;
			dbms_output.put_line('--   Info: Overview of actual file usage:');
			dbms_output.put_line('--      Tablespace_Name                File_Name                                                    FilesizeMB Status    AutoExtensible  MaxSizeMB');
			dbms_output.put_line('--      ------------------------------ ------------------------------------------------------------ ---------- --------- -------------- ----------');
			FOR f in 1 .. ExistingTSFiles.count LOOP
				dbms_output.put_line('--      '||rpad(ExistingTSFiles(f).tablespace_name,31)||rpad(ExistingTSFiles(f).file_name,61)||lpad(to_char(ExistingTSFiles(f).FilesizeMb,FormatMb),10)||lpad(lower(ExistingTSFiles(f).Status),10)||lpad(lower(ExistingTSFiles(f).Autoextensible),15)||lpad(to_char(ExistingTSFiles(f).MaxsizeMb,FormatMb),11));
				
				--Also keep track of Oracle ASM usage
				if substr(ExistingTSFiles(f).file_name,1,1)='+' then
					:OracleASM:=1;
				end if;

			END LOOP;
		end if;
		dbms_output.put_line(:Line);
	end if;
end;
/

--Tablespace size OMPARTNERS, INDEXES, UNDO, SYSTEM, SYSAUX, TEMP, OMDBA
declare
	type Tablespaces is table of          varchar2(513);
	RequiredTablespaces Tablespaces:=Tablespaces('OMPARTNERS','INDEXES','UNDO','SYSTEM','SYSAUX','TEMP');
	type FilenameBytes is                 record (FileName varchar2(513), Bytes number);
	type Files is table of                FilenameBytes;
	ExistingFiles                         Files:=Files();
	SumBytes                              number;
	MaxSumBytes                           number;
	AEGrowth                              number;
	requiredTSbytes                       number;
	i                                     number;
	r                                     number;
	TS                                    varchar2(513);
	MaxDatabaseFilesizeBytes              number;
	SpaceleftBytes                        number;
	NewSizeBytes                          number;
	ShortageBytes                         number;
	Filecounter                           number;
	Newfilename                           varchar2(513);
	UndoTSs                               number;
	DataTemp                              varchar2(4);
	PathNewDataFile                       varchar2(513);
	Continue                              number;
	DiskspaceErrorGiven                   number;
	DiskspaceWarningGiven                 number;
	statement                             varchar2(2500);
	SuitableDriveFound                    number;
	TSExists                              number;
	TSAutoextensible                      number;
	FileAutoextensible                    number;
	Magnitude                             number;
	PathSeparator                         varchar2(1);

	type DriveInfo                        is record (Drive varchar2(1), freediskspace number, RemainingFreediskspace number);
	type Drives is                        table of DriveInfo;
	myDrives                              Drives:=Drives();
	myDriveInfo                           DriveInfo;

	SuitableDriveList                     varchar2(100);

	function KMGtextToNumber (numbertext IN varchar2) return number as
		NumberUNIT                         varchar2(1);    --e.g. M   (K,M,G,T)
	begin
		NumberUNIT:=upper(substr(NUMBERTEXT,-1,1));
		Return translate(NUMBERTEXT,'0123456789kKmMgG','0123456789')*power(1024,instr('KMG',NUMBERUNIT,1));
	end;

	function isnumber (numbertext in varchar2) return number as
	begin
		if translate(numbertext,'A1234567890kKmMgG','A') is null then
			return 1;
		else
			return 0;
		end if;
	end;

	function NumberToKMGtext (NumberIn in number) return varchar2 as
		NumberUNIT                         varchar2(1);
		NumberText                         varchar2(2000);
		Units                              varchar2(10):='KMG';
	begin
		if NumberIn<>0 then
			NumberUNIT:=' ';
			NumberText:=NumberIn;
			for i in 1..length(Units) loop
				if numbertext mod 1024 = 0 then
					numberunit:=substr(Units,i,1);
					numbertext:=numbertext/1024;
				end if;
			end loop;
			return numbertext||trim(numberunit);
		else
			return '0';
		end if;
	end;

	procedure LoadMyDrives as
	begin
		myDrives.extend; myDriveInfo.Drive:='A';myDriveInfo.freediskspace:=:freediskspaceA; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='B';myDriveInfo.freediskspace:=:freediskspaceB; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='C';myDriveInfo.freediskspace:=:freediskspaceC; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='D';myDriveInfo.freediskspace:=:freediskspaceD; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='E';myDriveInfo.freediskspace:=:freediskspaceE; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='F';myDriveInfo.freediskspace:=:freediskspaceF; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='G';myDriveInfo.freediskspace:=:freediskspaceG; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='H';myDriveInfo.freediskspace:=:freediskspaceH; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='I';myDriveInfo.freediskspace:=:freediskspaceI; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='J';myDriveInfo.freediskspace:=:freediskspaceJ; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='K';myDriveInfo.freediskspace:=:freediskspaceK; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='L';myDriveInfo.freediskspace:=:freediskspaceL; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='M';myDriveInfo.freediskspace:=:freediskspaceM; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='N';myDriveInfo.freediskspace:=:freediskspaceN; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='O';myDriveInfo.freediskspace:=:freediskspaceO; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='P';myDriveInfo.freediskspace:=:freediskspaceP; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='Q';myDriveInfo.freediskspace:=:freediskspaceQ; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='R';myDriveInfo.freediskspace:=:freediskspaceR; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='S';myDriveInfo.freediskspace:=:freediskspaceS; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='T';myDriveInfo.freediskspace:=:freediskspaceT; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='U';myDriveInfo.freediskspace:=:freediskspaceU; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='V';myDriveInfo.freediskspace:=:freediskspaceV; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='W';myDriveInfo.freediskspace:=:freediskspaceW; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='X';myDriveInfo.freediskspace:=:freediskspaceX; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='Y';myDriveInfo.freediskspace:=:freediskspaceY; myDrives(myDrives.count):=myDriveInfo;
		myDrives.extend; myDriveInfo.Drive:='Z';myDriveInfo.freediskspace:=:freediskspaceZ; myDrives(myDrives.count):=myDriveInfo;

		for d in 1..myDrives.count loop
			myDrives(d).RemainingFreediskspace:=myDrives(d).Freediskspace;
		end loop;
	end;

begin
	LoadMyDrives;
	if :DbaTablespaces=0 then
		dbms_output.put_line('--   Requirement: Tablespaces must exist and have required sizes.');
		dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_TABLESPACES''. Run the ConfigCheck script ''AS SYSDBA''.');
		:ErrorCount:=:ErrorCount+1;
	 	dbms_output.put_line(:Line);
	else -- Pretest ok
		if :SkipOMDBA=0 then /* Without user OMDBA, there' s also no need for a tablespace OMDBA */
			RequiredTablespaces.extend;RequiredTablespaces(RequiredTablespaces.count):='OMDBA';
		end if;

		for i in RequiredTablespaces.First .. RequiredTablespaces.Last
		loop
			TS:=RequiredTablespaces(i);
			DataTemp:='data';
			case TS
				when 'OMPARTNERS' then
					requiredTSbytes:=KMGtextToNumber('&TablespaceSize_OMPARTNERS');
				when 'INDEXES'    then
					requiredTSbytes:=KMGtextToNumber('&TablespaceSize_INDEXES');
				when 'UNDO'       then
					-- 25% of OMPARTNERS+INDEXES
					requiredTSbytes:=(KMGtextToNumber('&TablespaceSize_OMPARTNERS')+KMGtextToNumber('&TablespaceSize_INDEXES'))/4;
					--Allow for situation that UNDO tablespace has alternative name; default remains UNDO
						if :v$Parameter=0 then
							dbms_output.put_line('--!  Result: Error: You do not have access to ''V$PARAMETER''. Run the ConfigCheck script ''AS SYSDBA''.');
							:ErrorCount:=:ErrorCount+1;
						else --pretest ok
							execute immediate 'select upper(value) from v$parameter where name=''undo_tablespace''' into TS ;
						end if;
				when 'SYSTEM'     then
					requiredTSbytes:=KMGtextToNumber('&TablespaceSize_SYSTEM');
				when 'SYSAUX'     then
					requiredTSbytes:=KMGtextToNumber('&TablespaceSize_SYSAUX');
				when 'TEMP'       then
					requiredTSbytes:=KMGtextToNumber('&TablespaceSize_TEMP');
					DataTemp:='temp';
				when 'OMDBA'       then
					requiredTSbytes:=KMGtextToNumber('&TablespaceSize_OMDBA');
			end case;
			dbms_output.put_line('--   Requirement: Tablespace '||TS||' must exist and have required size of '||NumberToKMGText(requiredTSbytes)||'.');


			--First check whether TS exists
			--Pretest
			execute immediate 'SELECT count(9) FROM SYS.DBA_tablespaces where tablespace_name='''||TS||''' ' into TSExists;
			if TSExists=0 then -- it doesn't exist
				if TS='OMDBA' then -- give warning
					dbms_output.put_line('--(!)Result: Warning: Database does not have a tablespace named '''||TS||'''.');
					dbms_output.put_line('--                    It is recommended to give the special user OMDBA its own tablespace OMDBA.');
					:Warningcount:=:WarningCount+1;
				else -- give error
					dbms_output.put_line('--!  ERROR: Tablespace '||TS||' does not exist.');
					:ErrorCount:=:ErrorCount+1;
				end if;

				dbms_output.put_line('--   Solution: Add tablespace '||TS||' by executing the following statement:');
				--The statement will be given further, when files for TS not having required size are being added.
			end if;

			if (:DbaDataFiles=0 and TS<>'TEMP') or (:DbaTempFiles=0 and TS='TEMP') then
				dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_'||upper(datatemp)||'_FILES''. Run the ConfigCheck script ''AS SYSDBA''.');
				:ErrorCount:=:ErrorCount+1;
			else -- Previous pretest ok
				--Next pretest=V$Parameter
				if :v$Parameter=0 then
					dbms_output.put_line('--!  Result: Error: You do not have access to ''V$PARAMETER''. Run the ConfigCheck script ''AS SYSDBA''.');
					:ErrorCount:=:ErrorCount+1;
				else --pretest ok
					--Get largest possible filesize: we will go from 1. exact to 2. nice maximum size:
					--1. Exact maximum size:
					execute immediate 'select value*(4*1024*1024-1) from v$parameter where name=''db_block_size''' into MaxDatabaseFilesizeBytes; --4m blocks-1 is maximum
					--2. The real maximum obtained in step 1. looks pretty ugly (e.g. with default blocksize of 8192 this becomes 33554424K), so let's put in Mb and floor it to the first decimal in Mb
					--   For example 33554424K will become 30000m (with blocksize 8192), or 67108848K will become 60000m (with blocksize 16384)
					Magnitude:=floor(log(10,MaxDatabaseFilesizeBytes/1024/1024));
					MaxDatabaseFilesizeBytes:=floor(MaxDatabaseFilesizeBytes/1024/1024/power(10,Magnitude))*1024*1024*power(10,Magnitude) ;
--					dbms_output.put_line('Max='||MaxDatabaseFilesizeBytes);

					if TSExists=0 then
						ShortageBytes:=requiredTSbytes;
					else
						--TS exists, so first investigate if actual file sizes are ok or can be increased.

						execute immediate 'select sum(bytes) SumBytes from SYS.DBA_'||datatemp||'_files where tablespace_name='''||TS||''' 'into SumBytes ;
						if :Info>0 then dbms_output.put_line('--   Info: Actual size of '||TS||' is '||NumberToKMGText(SumBytes)||'.'); end if;

						execute immediate 'select count(9) from SYS.DBA_'||datatemp||'_files where tablespace_name='''||TS||''' and autoextensible=''YES''' into TSAutoextensible;

						if TSAutoextensible>0 then
							dbms_output.put_line('--   Info: Tablespace '||TS||' has autoextensible '||datatemp||'files. Please monitor disk space in your operating system.');
							--SumBytes:
							execute immediate 'select sum (case when autoextensible=''YES'' then (case when bytes>maxbytes then bytes else maxbytes end) else bytes end) SumBytes from SYS.DBA_'||datatemp||'_files where tablespace_name='''||TS||''' 'into MaxSumBytes;
							if :Info>0 then
								dbms_output.put_line('--   Info: Maximum size of '||TS||' is '||NumberToKMGText(MaxSumBytes)||'.');
								dbms_output.put_line('--   Info: Possible growth of '||TS||' is '||NumberToKMGText(MaxSumBytes-SumBytes)||'.');
							end if;

							if MaxSumBytes>SumBytes then
									AEGrowth:=MaxSumBytes-SumBytes;
							else
									AEGrowth:=0;
							end if;
						else
							MaxSumBytes:=SumBytes;
							AEGrowth:=0;
						end if;

						ShortageBytes:=requiredTSbytes-MaxSumBytes;
						if ShortageBytes<=0 then
						    dbms_output.put_line('--   Result: OK.');
						    --
						    -- 9/2/2017 BEGIN : Switch Autoextend for TEMP tablespaces
						    IF (TSAutoextensible = 0) AND (datatemp = 'temp')
						    THEN
						      dbms_output.put_line(:Line);
								dbms_output.put_line('--   Requirement: Temporary tablespace should be AUTOEXTEND.');
			               dbms_output.put_line('--!  Result: Error: No file in tablespace '||TS||' is autoextensible. This can lead to unexpected space shortage issues.');
								:ErrorCount:=:ErrorCount+1;
								dbms_output.put_line('--   Solution: Set tempfile to AUTOEXTEND by executing the following statement:');
						      for my in (select file_name from sys.dba_temp_files where file_id = (select min(file_id) from sys.dba_temp_files)) loop
							      dbms_output.put_line('alter database '||datatemp||'file '''||my.file_name||''' autoextend on next 50m maxsize 30g;');
	                     end loop;
						    END IF;																	
						    -- 9/2/2017 END : Switch Autoextend for TEMP tablespaces
						else
		--						dbms_output.put_line('requiredTSbytes='||NumberToKMGText(requiredTSbytes));
		--						dbms_output.put_line('SumBytes='||NumberToKMGText(SumBytes));
		--						dbms_output.put_line('MaxSumBytes='||NumberToKMGText(MaxSumBytes));
		--						dbms_output.put_line('ShortageBytes='||NumberToKMGText(ShortageBytes));
		--						dbms_output.put_line('AEGrowth='||NumberToKMGText(AEGrowth));
							dbms_output.put_line('--!  Result: Error: Tablespace '||TS||' is not large enough. Actual size is '||NumberToKMGText(SumBytes)||', '|| case when TSAutoextensible>0 then 'maximum size is '||NumberToKMGText(MaxSumBytes)||', possible autoextensible growth is '||NumberToKMGText(AEGrowth)||', ' end ||'shortage is '||NumberToKMGText(ShortageBytes)||'.');
							:ErrorCount:=:ErrorCount+1;
							dbms_output.put_line('--   Solution: Expand tablespace '||TS||' by executing the following statement(s): ');
							--First try to increase size of existing datafiles
							--Collect filenames and sizes
							execute immediate 'select file_name, bytes from SYS.DBA_'||datatemp||'_files where tablespace_name='''||TS||''' ' bulk collect into ExistingFiles;
							DiskspaceErrorGiven:=0;
							DiskspaceWarningGiven:=0;
							for i in 1 .. ExistingFiles.count
							loop
	--							dbms_output.put_line('Shortage='||ShortageBytes);--
	--							dbms_output.put_line(ExistingFiles(i).FileName||'='||NumberToKMGText(ExistingFiles(i).Bytes)||'.');
								--Is this file suitable to extend, i.e. is it smaller than maximum file size
								Spaceleftbytes:=MaxDatabaseFilesizeBytes-ExistingFiles(i).Bytes;
	--								dbms_output.put_line('Spaceleftbytes='||Spaceleftbytes);
								if ShortageBytes>0 and SpaceleftBytes>0 then -- filesize should and can be increased, now allocate new size
									execute immediate 'select count(9) from SYS.DBA_'||datatemp||'_files where file_name='''||ExistingFiles(i).FileName||''' and autoextensible=''YES''' into FileAutoextensible;
									if ShortageBytes>SpaceleftBytes then -- take max for this file, continue later with subsequent (or new) file(s)
										NewSizeBytes:=MaxDatabaseFilesizeBytes;
									else
	--										dbms_output.put_line('existing='||NumberToKMGText(ExistingFiles(i).Bytes));
	--										dbms_output.put_line('Shortage='||NumberToKMGText(ShortageBytes));
										--In case of Autoextensible tablespace, when there is shortage, increase the size immediately to the required size including possible autoextensible-growth (rather than increasing MaxBytes to allow for more autoextensible growth)
										NewSizeBytes:=ExistingFiles(i).Bytes+ShortageBytes+AEGrowth;
									end if;
	--									dbms_output.put_line('NewSizeBytes='||NewSizeBytes);

									--Only give a resize statement if there is sufficient disk space left; give a warning if no disk info was obtained.
									Continue:=0;
									if :FreediskspaceInfoAvailable=0 then --No info was found, give warning
										if DiskspaceWarningGiven=0 then
											dbms_output.put_line('--(!)Warning: Verify that there is sufficient disk space available for the next statement(s):');
											:warningcount:=:warningcount+1;
											DiskspaceWarningGiven:=1;
										end if;
										--Statement to resize can be given
										Continue:=1;
									else --use the available info
										for d in 1..myDrives.count loop
											if myDrives(d).Drive=substr(ExistingFiles(i).FileName,1,1) then --this is the drive I want to use
--												dbms_output.put_line('Drive '||myDrives(d).Drive||' has '||NumberToKMGText(myDrives(d).RemainingFreediskspace)||' remaining free.');
												if myDrives(d).RemainingFreediskspace>=NewSizeBytes then
													--all ok give statement
													Continue:=1;
												else
													--not enough space, skip this file
													if :info>=1 then
														if :Info>0 then dbms_output.put_line('--   Info: File '||ExistingFiles(i).FileName||' will not be enlarged because there is not sufficient disk space on its drive'); end if;
														if myDrives(d).RemainingFreediskspace<myDrives(d).Freediskspace then --Some free diskspace has been consumed with earlier resize/add statements
															dbms_output.put_line(          '--         if also the above disk-consuming modifications are being applied.');
														end if;
														dbms_output.put_line('--         Will try to increase another file or add a new file on another disk.');
													end if;
												end if;
											end if;
										end loop;
									end if;
									if Continue=1 then --ok to give resize statement
										dbms_output.put_line('alter database '||datatemp||'file '''||ExistingFiles(i).FileName||''' resize '||NumberToKMGText(NewSizeBytes)||'   /* to increase its size with '||NumberToKMGText(NewSizeBytes-ExistingFiles(i).Bytes) ||' from '||NumberToKMGText(ExistingFiles(i).Bytes)||' to '||NumberToKMGText(NewSizeBytes)||'. */;');
										ShortageBytes:=ShortageBytes-(NewSizeBytes-ExistingFiles(i).Bytes);
										--Correct RemaingFreediskspace because we are using diskspace here
										for d in 1..myDrives.count loop
											if myDrives(d).Drive=substr(ExistingFiles(i).FileName,1,1) then
												myDrives(d).RemainingFreediskspace:=myDrives(d).RemainingFreediskspace-(NewSizeBytes-ExistingFiles(i).Bytes);
												if myDrives(d).RemainingFreediskspace<0 then myDrives(d).RemainingFreediskspace:=0; end if;
	--												if :FreediskspaceInfoAvailable=1 then dbms_output.put_line('Remaining on '||myDrives(d).Drive||'='||NumberToKMGText(myDrives(d).RemainingFreediskspace)||'.'); end if;
											end if;
										end loop;
									end if;
								end if; --resizing
							end loop; --Existingfiles
						    	--
						    	-- 9/2/2017 BEGIN : Switch Autoextend for TEMP tablespaces
						    	IF (TSAutoextensible = 0) AND (datatemp = 'temp')
						    	THEN
						      	dbms_output.put_line(:Line);
								   dbms_output.put_line('--   Requirement: Temporary tablespace should be AUTOEXTEND.');
			                  dbms_output.put_line('--!  Result: Error: No file in tablespace '||TS||' is autoextensible. This can lead to unexpected space shortage issues.');
								   :ErrorCount:=:ErrorCount+1;
								   dbms_output.put_line('--   Solution: Set tempfile to AUTOEXTEND by executing the following statement:');
						      	for my in (select file_name from sys.dba_temp_files where file_id = (select min(file_id) from sys.dba_temp_files)) loop
							         dbms_output.put_line('alter database '||datatemp||'file '''||my.file_name||''' autoextend on next 50m maxsize 30g;');
	                        end loop;
						    	END IF;																	
						    	-- 9/2/2017 END : Switch Autoextend for TEMP tablespaces
						end if;
					end if; --TSExists

					--If still needed, create additional files

					if ShortageBytes>0 then
						--A new file must be created; first check if OS uses / or \ as path separator
						execute immediate 'select case when count(9)>0 then ''\'' else ''/'' end from SYS.DBA_'||datatemp||'_files where instr(file_name,''\'',-1)>0' into PathSeparator; --' OS uses / or \
					end if;

					filecounter:=0;

					DiskspaceErrorGiven:=0;
					DiskspaceWarningGiven:=0;
					while ShortageBytes>0
					loop
--						dbms_output.put_line('There is still shortage of '||ShortageBytes);

						--Determine new size
						if ShortageBytes>MaxDatabaseFilesizeBytes then
							NewSizeBytes:=MaxDatabaseFilesizeBytes;
						else
							NewSizeBytes:=ShortageBytes;
						end if;
--						dbms_output.put_line('NewSizeBytes='||NewSizeBytes);


						--Find suitable path: use path most recently used having sufficient disk space
						if :FreediskspaceInfoAvailable=0 then --No info was found, give warning
							--Only give warning once:
							if DiskspaceWarningGiven=0 then
								dbms_output.put_line('--(!)Warning: Verify that there is sufficient disk space available for the next statement(s):');
								DiskspaceWarningGiven:=1;
							end if;
							--No disk info available, for path take most recently used
							if TSExists=1 then
								--Take most recently used path for TS
								execute immediate 'select substr(file_name,1,instr(file_name,'''||PathSeparator||''',-1)) path from (select file_name, creation_time,file_id  from SYS.DBA_'||datatemp||'_files ddf, v$'||datatemp||'file vdf where ddf.file_id=vdf.file# and tablespace_name='''||TS||''' /* most recent*/ order by creation_time desc, file_id desc) where rownum=1'  into PathNewDataFile;
							else
								--Take most recently used path for any file
								execute immediate 'select substr(file_name,1,instr(file_name,'''||PathSeparator||''',-1)) path from (select file_name, creation_time,file_id  from SYS.DBA_'||datatemp||'_files ddf, v$'||datatemp||'file vdf where ddf.file_id=vdf.file#                                  /* most recent*/ order by creation_time desc, file_id desc) where rownum=1'  into PathNewDataFile;
							end if;
						else --use the available disk info
							--First keep list of drives still having sufficient disk space
							SuitableDriveList:='';
							for d in 1..myDrives.count loop
								if myDrives(d).RemainingFreediskspace>=NewSizeBytes then SuitableDriveList:=SuitableDriveList||''''||myDrives(d).Drive||''','; end if;
							end loop;
							--trim trailing separator
							if length(SuitableDriveList)>0 then SuitableDriveList:=substr(SuitableDriveList,1,length(SuitableDriveList)-1); end if;
--							dbms_output.put_line('SuitableDriveList='||SuitableDriveList||'.');

							if SuitableDriveList is null then
								--No suitable drive found; continue further with most recently used
								SuitableDriveFound:=0;
							else
								--There are drives with sufficient free space,
								--now try to get the most interesting suitable path, i.e. path used most recently for datafile creation (for the tablespace TS if it already exists), having sufficient diskspace
								if TSExists=1 then
									--Take most recently used suitable path for TS
									statement:= 'select substr(file_name,1,instr(file_name,'''||PathSeparator||''',-1)) path from (select file_name, creation_time,file_id  from SYS.DBA_'||datatemp||'_files ddf, v$'||datatemp||'file vdf where ddf.file_id=vdf.file# and tablespace_name='''||TS||''' and /* drive should have space */ substr(file_name,1,1) in ('||SuitableDriveList||') /* most recent*/ order by creation_time desc, file_id desc) where rownum=1';
								else
									--Take most recently used suitable path for any file
									statement:= 'select substr(file_name,1,instr(file_name,'''||PathSeparator||''',-1)) path from (select file_name, creation_time,file_id  from SYS.DBA_'||datatemp||'_files ddf, v$'||datatemp||'file vdf where ddf.file_id=vdf.file#                                  and /* drive should have space */ substr(file_name,1,1) in ('||SuitableDriveList||') /* most recent*/ order by creation_time desc, file_id desc) where rownum=1';
								end if;
	--							dbms_output.put_line(statement);
								execute immediate 'select count(9) from ('||statement||')' into SuitableDriveFound;
							end if;

							--If no drives had free space, or no drives from existing tablespacefiles had free space, then:
							if SuitableDriveFound=0 then --Inform user, and update statement to ignore lack of available drives
								if DiskspaceErrorGiven=0 then
									dbms_output.put_line('--!  ERROR: There is not enough diskspace for adding new file(s) with the next statement(s).');
									:errorcount:=:errorcount+1;
									DiskspaceErrorGiven:=1;
									dbms_output.put_line('--   Solution: Check disk space and adjust the path and filename in the next statement(s) accordingly before executing them!');
								end if;
								if TSExists=1 then
									statement:='select substr(file_name,1,instr(file_name,'''||PathSeparator||''',-1)) path from (select file_name, creation_time,file_id  from SYS.DBA_'||datatemp||'_files ddf, v$'||datatemp||'file vdf where ddf.file_id=vdf.file# and tablespace_name='''||TS||''' /* most recent*/ order by creation_time desc, file_id desc) where rownum=1';
								else
									statement:='select substr(file_name,1,instr(file_name,'''||PathSeparator||''',-1)) path from (select file_name, creation_time,file_id  from SYS.DBA_'||datatemp||'_files ddf, v$'||datatemp||'file vdf where ddf.file_id=vdf.file#                                  /* most recent*/ order by creation_time desc, file_id desc) where rownum=1';
								end if;
							else
								--reset DiskspaceErrorGiven if needed
								if DiskspaceErrorGiven=1 then
									dbms_output.put_line('--   Info: There should be enough diskspace for the next statement(s).');
									DiskspaceErrorGiven:=0;
								end if;
							end if;

							--Now
							execute immediate statement into PathNewDataFile;

						end if;
	--					dbms_output.put_line('Path used will be ' ||PathNewDataFile);

						--Determine suitable filename
						Newfilename:='x';
						while Newfilename='x' and filecounter<=99 loop
							filecounter:=filecounter+1;
	--						dbms_output.put_line('In loop filecounter='||filecounter);
							Newfilename:=(PathNewDataFile||TS||to_char(filecounter,'FM00')||'.dbf'); --FM00 is without space for sign
	--						dbms_output.put_line('Newfilename='''||Newfilename||'''.');
							--Check whether Newfilename already exists in database
							for i in 1 .. ExistingFiles.count loop
								--we ignore case, to avoid that 2 files with extensions .dbf and DBF are considered to be unequal; after all we want to focus on the numbering of the files, not on their case.
								if upper((ExistingFiles(i).FileName))=upper(Newfilename) then
									--throw away filename
	--								dbms_output.put_line('Newfilename='''||Newfilename||''' already exists.');
									Newfilename:='x';
								end if;
							end loop;
	--						dbms_output.put_line('In loop filecounter='||filecounter);
						end loop;
						if filecounter=100 then
							Newfilename:=(PathNewDataFile||TS||'<filename>'||'.dbf');
							dbms_output.put_line('--(!)Warning: In the statement given below, replace <filename> with an appropriate filename');
							:warningcount:=:warningcount+1;
						end if;

						--Now give statement
						if TSExists=0 then
						  if (substr(TS,1,10) = 'OMPARTNERS')
						  then
							dbms_output.put_line('Create '||case when substr(TS,1,4)='UNDO' then 'UNDO ' else '' end||'tablespace '||TS||' datafile '''   ||Newfilename||''' size '||NumberToKMGText(NewSizeBytes)||' FORCE LOGGING EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M SEGMENT SPACE MANAGEMENT AUTO;');
                          else
						    if (substr(TS,1,5) = 'TEMP')
							then
							  dbms_output.put_line('Create temporary tablespace '||TS||' tempfile '''   ||Newfilename||''' size '||NumberToKMGText(NewSizeBytes)||' AuTOEXTEND ON;');
							else
							  dbms_output.put_line('Create '||case when substr(TS,1,4)='UNDO' then 'UNDO ' else '' end||'tablespace '||TS||' datafile '''   ||Newfilename||''' size '||NumberToKMGText(NewSizeBytes)||' FORCE LOGGING EXTENT MANAGEMENT LOCAL AUTOALLOCATE SEGMENT SPACE MANAGEMENT AUTO;');
							end if;
                          end if;						  
						else
							dbms_output.put_line('alter tablespace '||TS||' add datafile '''||Newfilename||''' size '||NumberToKMGText(NewSizeBytes)||';');
						end if;
						ShortageBytes:=ShortageBytes-NewSizeBytes;
						--Correct RemaingFreediskspace because we are using diskspace here
						for d in 1..myDrives.count loop
							if myDrives(d).Drive=substr(NewFileName,1,1) then
								myDrives(d).RemainingFreediskspace:=myDrives(d).RemainingFreediskspace-NewSizeBytes;
								if myDrives(d).RemainingFreediskspace<0 then myDrives(d).RemainingFreediskspace:=0; end if;
--								if :FreediskspaceInfoAvailable=1 then dbms_output.put_line('Remaining on '||myDrives(d).Drive||'='||NumberToKMGText(myDrives(d).RemainingFreediskspace)||'.'); end if;
							end if;
						end loop;
					end loop; --while ShortageBytes>0
				end if; --v$parameter
			end if; -- / dba_temp_files
			dbms_output.put_line(:Line);
		end loop; --RequiredTS
	end if; --dba_tablespaces
end;
/

set lines 2000
-- Check tablespace creation parameters for securefile lob storage
declare
	type tses is table of varchar2(30);
	tsestotest tses:=tses('OMPARTNERS');
	type tsstat is record (block_size number, initial_extent number, segment_space_management varchar2(6), extent_management varchar2(9), allocation_type varchar2(9) );
	tstats tsstat;
	type tsstats is table of tsstat;
	tablesstats tsstats:=tsstats();
	type datafiles is table of varchar2(260);
	dtfls datafiles:=datafiles();
	
	sqltextcreate varchar2(2000);
	sqltextdrop varchar2(2000);
	
	tsexists number;
	extentsize number;
	segs number;
begin
	:db_securefileoption:='(''IGNORE'',''NEVER'',''PERMITTED'')'; --Start with default; will be updated further if needed
	if :NLSRDBMSVERSION00>='11' then
		-- let's start by pretending all's well
		:notsecurefile:=0;
		-- pretests: can I check the tablespace parameters?
		if :DbaTablespaces=0 or :DbaSegments=0 then
			dbms_output.put_line('--   Requirement: Tablespaces need correct parameters set for securefile storage for best performance.');
			-- I can't, so make that clear to the user
			if :DbaTablespaces=0 then dbms_output.put_line('--!  Result: Error: You do not have access to ''DBA_TABLESPACES''. Run the ConfigCheck script ''AS SYSDBA''.'); end if;
			if :DbaSegments=0 then dbms_output.put_line('--!  Result: Error: You do not have access to ''DBA_SEGMENTS''. Run the ConfigCheck script ''AS SYSDBA''.'); end if;
			dbms_output.put_line(:Line);
		else
			-- woot: I can get to work:
			-- I going through the list of tablespace names defined up top (tsestotest)
			for i in tsestotest.first .. tsestotest.last loop
				-- check whether the tablespace exists if this is the case continue with the test (no use testing a tablespace that doesn't exist)
				execute immediate 'select count(9) from dba_tablespaces where tablespace_name='''||upper(tsestotest(i))||''' ' into tsexists;
				if tsexists=1 then
					-- get the stats and all the datafiles for the tablespace
					execute immediate 'select block_size,initial_extent,segment_space_management,extent_management,allocation_type from dba_tablespaces where tablespace_name='''||upper(tsestotest(i))||''' ' into tstats;
					execute immediate 'select file_name from DBA_DATA_FILES where tablespace_name= '''||upper(tsestotest(i))||''' ' bulk collect into dtfls;
					dbms_output.put_line('--   Requirement: Tablespace '||upper(tsestotest(i))||' needs to have the required storage parameters for securefile storage, required for best performance.');
					dbms_output.put_line('--   Info: Actual value of Extent Size: '||tstats.initial_extent||', Segment Management: '||tstats.extent_management||'.');
					if  (tstats.allocation_type != 'UNIFORM') 
					and (tsestotest(i) = 'OMPARTNERS')
					then
						dbms_output.put_line('-- Info: Actual value of extent management option: ' || tstats.allocation_type || '. Will be changed to UNIFORM for tablespace : ' ||tsestotest(i));
					end if;
					-- check whether the stats I found are best for the securefile storage
					if not tstats.segment_space_management = 'AUTO' or not (tstats.initial_extent/tstats.block_size)>14 then
						-- they aren't, so create the drop and create statements for the tablespace first
						sqltextdrop   := 'DROP TABLESPACE '   || upper(tsestotest(i))||' INCLUDING CONTENTS KEEP DATAFILES CASCADE CONSTRAINTS;'; -- keep the datafiles, recreating them would take to long (and have no benefit)
						sqltextcreate := 'CREATE TABLESPACE ' || upper(tsestotest(i))||' DATAFILE ';
						-- tablespace could contain multiple datafiles, so add the reuse clauses for every file I found (last one doesn't need the trailing comma)
						for j in dtfls.first .. dtfls.last loop
							if j < dtfls.last then
								sqltextcreate:=sqltextcreate||''''||dtfls(j)||''' REUSE,';
							else
								sqltextcreate:=sqltextcreate||''''||dtfls(j)||''' REUSE ';
							end if;
						end loop;
						-- we want to use the same blocksize as before
						sqltextcreate := sqltextcreate||'BLOCKSIZE '||tstats.block_size||'';
						-- specify the ideal extent size, which will be automatically ok to create the securefile lobs
						extentsize := 1; 
						sqltextcreate := sqltextcreate||' FORCE LOGGING'; -- this is our default
						IF (tsestotest(i) = 'OMPARTNERS' )
						THEN
						  sqltextcreate := sqltextcreate||' EXTENT MANAGEMENT '||tstats.extent_management||' '||'UNIFORM'||' SIZE '||extentsize||' M'; -- reuse the parameters as they were before we dropped the tablespace (not just the OMP defaults)
						ELSE
						  -- except for ompartners everythings else will take the oracle default of AUTOALLOCATE
						  sqltextcreate := sqltextcreate||' EXTENT MANAGEMENT '||tstats.extent_management||' '||'AUTOALLOCATE'; -- reuse the parameters as they were before we dropped the tablespace (not just the OMP defaults)
						END IF;
	                    --
						sqltextcreate := sqltextcreate||' SEGMENT SPACE MANAGEMENT AUTO'; -- this is required for the securefile storage
						sqltextcreate := sqltextcreate||';';
						-- starting the output of the message we need the user to consider, add to the total error count
						dbms_output.put_line('--!  Result: Error: Tablespace '||upper(tsestotest(i))||' has'||case when not tstats.extent_management = 'AUTO' then ' extent management set to '||tstats.extent_management end||''||case when not tstats.extent_management = 'AUTO' and not (tstats.initial_extent/tstats.block_size) > 14 then ' and' else '' end||''||case when (not (tstats.initial_extent/tstats.block_size) > 14) then ' an initial extent smaller than 14*blocksize+1' end||'. Performance will be suboptimal.');
						:ErrorCount:=:ErrorCount+1;
						-- add to the tablespace error counter for the db_securefile test (see further down)
						:notsecurefile:=:notsecurefile+1;
						-- check whether the tablespace is empty
						execute immediate 'select count(9) from DBA_SEGMENTS where tablespace_name='''||upper(tsestotest(i))||'''' into segs;
						if not segs=0 then
							-- it isn't so we might not want to blindly drop and recreate the tablespace, so we comment out the statements and require the dba to put his thinking hat on
							sqltextcreate := '--'||sqltextcreate;
							sqltextdrop := '--'||sqltextdrop;
							dbms_output.put_line('--   Warning: The tablespace '||upper(tsestotest(i))||' is not empty!');
							dbms_output.put_line('--   If losing data in this tablespace is not a problem, uncomment the next lines:');
						end if;
						dbms_output.put_line(sqltextdrop);
						dbms_output.put_line(sqltextcreate);
					else
						-- all's peace and quiet, so we'll just comfort the user that he can rest easy
						dbms_output.put_line('--   Result: OK.');
					end if;
					dbms_output.put_line(:Line);
				--else
					--Tablespace does not exist, statements to create it correctly -including appropriate securefile storage support- have been given above
				end if;
			end loop;
		end if;
		
		--So far we checked the tablespaces. Now, finally, let's check what we can set the database parameter db_securefile to
		--We have a two tier choice system here
		--   first: if the tablespaces are not set up correctly it should be ignore, otherwise trouble ahead
		--   second: if the database is version 12(c) then option should be preferred, for performance sake
		--           if the database is version 11 then option should be permitted, best not always, but should be imho (let's not generate unnecessary errors)
		if :notsecurefile = 0 then
			if :Vxx=11 then
				:db_securefileoption:='(''PERMITTED'',''ALWAYS'')';
				:db_securefileinfo:=' to allow for securefile lob storage for performance gain.';
			else --:Vxx>=12
				:db_securefileoption:='(''PREFERRED'',''PERMITTED'',''ALWAYS'')';
				:db_securefileinfo:=' securefile should be default because it has better query performance.';
			end if;
		else
			:db_securefileoption:='(''IGNORE'',''NEVER'',''PERMITTED'')'; -- standard we'll put it to ignore
			--Add informative text which will be shown below in the Database parameters section
			:db_securefileinfo:=', because the tablespaces are not configured correctly, allowing for the creation of securefile lobs should be ignored.--   (If you wish you could recreate the tablespaces to allow for securefile lobs, look at the statements for the inididual tablespaces)';
		end if;
	--else
		--Securefile storage was introduced in Oracle 11 so this version of Oracle does not support this; an info message is provided below in the database parameters section
	end if;
end;
/
set lines 200

-------------------------------------------------------------------------------------
-- FIXED TABLE STATISTICS -----------------------------------------------------------
-------------------------------------------------------------------------------------
declare
	FixedTableStatsMissingCount number;
begin
	dbms_output.put_line('--   Requirement: Fixed Table statistics must be available and not stale.');
	if :DbaTabStatistics=0 then
		dbms_output.put_line('--!  Result: Error: You do not have access to ''DBA_TAB_STATISTICS''. Run the ConfigCheck script ''AS SYSDBA''.');
		:ErrorCount:=:ErrorCount+1;
	else
		execute immediate 'select count(9) from DBA_TAB_STATISTICS WHERE OBJECT_TYPE=''FIXED TABLE'' and (last_analyzed is null or stale_stats=''YES'') and num_rows is not null' into FixedTableStatsMissingCount ;
			if FixedTableStatsMissingCount=0 then
				dbms_output.put_line('--   Result: OK.');
			else
				dbms_output.put_line('--!  Error: Not all fixed tables have associated non-stale statistics. Oracle strongly recommends you to manually gather fixed objects statistics.');
				:errorcount:=:errorcount+1;
				dbms_output.put_line('--   Solution: Issue the following statement during representative workload:');
				dbms_output.put_line('exec DBMS_STATS.GATHER_FIXED_OBJECTS_STATS');
			end if;
	end if;
	dbms_output.put_line(:Line);
end;
/

-------------------------------------------------------------------------------------
-- DATABASE PARAMETERS --------------------------------------------------------------
-------------------------------------------------------------------------------------
declare
	type Parameter is                 record (Name varchar2(80), Comp varchar2(20), Value varchar2(2000), Env varchar2(2000), Suffix varchar2(2000), InPfile number, Info varchar2(2000), Severity varchar2(20));
	type Parameters is table of       Parameter;
	rqPRs                             Parameters:=Parameters();
	rqPR                              Parameter;

	type ChangeParameter is           record (Name varchar2(80), Comp varchar2(20), OldValue varchar2(2000), NewValue varchar2(2000));
	type ChangeParameters is table of ChangeParameter;

	AddPRs                            ChangeParameters:=ChangeParameters();
	AddPR                             ChangeParameter;
	RemovePRs                         ChangeParameters:=ChangeParameters();
	RemovePR                          ChangeParameter;

	dbPValue                          varchar2(2000);
	dbPValueNumberCorrection          number;
	dbPisSysModifiable                varchar2(80);
	suffix                            varchar2(2000);
	dbPValueCount                     number;
	Result                            number;
	NumberText                        varchar2(2000); --e.g. 400m
	RqNumberNumber                    number;         --e.g. 419430400 (equivalent of 400m)
	Bounce                            number;
	MySID                             varchar2(2000);
	OracleHome                        varchar2(2000);
	PathSeparator                     varchar2(1);
	Prefix                            varchar2(2000);

	Comment                           varchar2(10);
	workfile                          nvarchar2(2000);
	NewPfile                          nvarchar2(2000);
	pretext                           nvarchar2(2000);
	posttext                          nvarchar2(2000);
	newparametervalue                 varchar2(2000);
	sqltext                           varchar2(2000);
	pretestresult                     varchar2(2000);

	StreamsPoolSize                   number;
	GranuleSize                       number;
	SharedPoolSize                    number;
	SharedIOPoolSize                  number;

	function KMGtextToNumber (numbertext IN varchar2) return number as
		NumberUNIT                    varchar2(1);    --e.g. M   (K,M,G,T)
	begin
		NumberUNIT:=upper(substr(NUMBERTEXT,-1,1));
		Return translate(NUMBERTEXT,'0123456789kKmMgG','0123456789')*power(1024,instr('KMG',NUMBERUNIT,1));
	end;

	function IsNumber (numbertext in varchar2) return number as
	begin
		if translate(numbertext,'A1234567890kKmMgG','A') is null then
			return 1;
		else
			return 0;
		end if;
	end;

	Function IfNumber(numbertext In varchar2, truevalue In varchar2) return varchar2 as
	Begin
			if translate(numbertext,'A1234567890kKmMgG','A') is null then
				return truevalue;
			else
				return numbertext;
			end if;
	End;

	function NumberToKMGtext (NumberIn in number) return varchar2 as
		NumberUNIT                         varchar2(1);
		NumberText                         varchar2(2000);
		Units                              varchar2(10):='KMG';
	begin
		if NumberIn<>0 then
			NumberUNIT:=' ';
			NumberText:=NumberIn;
			for i in 1..length(Units) loop
				if numbertext mod 1024 = 0 then
					numberunit:=substr(Units,i,1);
					numbertext:=numbertext/1024;
				end if;
			end loop;
			return numbertext||trim(numberunit);
		else
			return '0';
		end if;
	end;

	function SqlPretest (SqlIn in varchar2) return varchar2 as
			--This function scans the SqlIn for tablenames starting with 'DBA_', and then checks if the user has select privileges on this table in the SYS schema.
			--It returns the tablenames (with SYS. prefix) for which there are no select privileges.
			text        varchar2(2000);
			pos         number;
			tablename   varchar2(2000);
			i           number;
			priv        number;
			missingpriv varchar2(2000);
		begin
			--Find dba_
			text:=sqlIn;
			while length(text)>0 loop
				pos:=instr(upper(text),upper('dba_'));
				if pos>0 then
					text:=substr(text,pos);
					--dbms_output.put_line('text='|| text ||'.');
					--search for space or comma or tab
					i:=0;
					while i<=length(text) loop
					  -- dbms_output.put_line('i='||i);
						if substr(text,i,1) IN (' ',',',chr(9)) then
							tablename:=substr(text,1,i-1);
							--dbms_output.put_line('tablename='||tablename||'.');
							--table found; now do the pretest
							SELECT count(9) into priv FROM all_tab_privs where table_schema='SYS' and table_name=upper(tablename) and privilege='SELECT';
							if priv=0 then
								missingpriv:=missingpriv||'''SYS.'||upper(tablename)||''', ';
							end if;
							i:=length(text);
						end if;
						i:=i+1;
					end loop;
				end if;
				--search next:
				text:=substr(text,length(tablename)+1);
				--text:='';
			end loop;
			--remove trailing delimiter
			missingpriv:=rtrim(missingpriv,', ');
			return missingpriv;
		end;

begin
	--Initialize
	dbms_output.put_line('--   Requirement: Server must have sufficient physical memory for the memory parameters provided.');

	if :PhysicalMemory>0 then
		if :PhysicalMemory<
									 KMGtextToNumber(:rqSharedPoolSize)
									+KMGtextToNumber(:rqDbCacheSize)
									+KMGtextToNumber(:rqPgaAggregateTarget)
									+KMGtextToNumber(1024*1024*1024) --keep for OS and overhead
		then
			dbms_output.put_line('--!  ERROR: The server has less physical memory than the required Oracle memory components (shared pool+cache+pga+OS overhead.)');
			:errorcount:=:errorcount+1;
			dbms_output.put_line('--  Solution: increase server memory first before applying any of the changes below.');
		else
			dbms_output.put_line('--   Result:OK');
		end if;
			--we can set sga_max_size equal to PhysicalMemory so we have flexibility in increase memory components, 
			-- but from oracle version 12.2 we can't do that anymore without really consuming all the memory (different behaviour) 
			--  so that a second instance like this would be impossible to install on the same server even if enough memory because all would have been taken by the first installation
			if :NLSRDBMSVERSION00 < '12.02.00.01'
            then			
		      :rqSgaMaxSize:=NumberToKMGtext(:PhysicalMemory);
			else 
		      :rqSgaMaxSize:=NumberToKMGtext(0);
			end if;
		
	else --When memory could not be obtained
		--TODO: Stop user from applying memory changes without knowing what is physically available
		dbms_output.put_line('--!  ERROR: The script could not detect the amount of physical server memory, please make sure sufficient memory is available for the memory parameters provided.');
		:errorcount:=:errorcount+1;
		:rqSgaMaxSize:=KMGtextToNumber(:rqSharedPoolSize)
							+KMGtextToNumber(:rqDbCacheSize)
							+KMGtextToNumber(:rqPgaAggregateTarget)
							+KMGtextToNumber(1024*1024*1024) --keep for OS and overhead
							;
	end if;
	dbms_output.put_line(:Line);

	--Parameters and their values
	--Remark that if a parameter has to be different (<>) from some value, then the value should be defined elsewhere also; e.g. pga_aggregate_target
	--Remark that if a required (hidden) parameter is not yet available in the database (e.g. _optim_peek_user_binds on 11.2), then it is assumed that it can be added with "scope=both". To be refined if needed for additional parameters were scope cannot be "both".
	rqPR.Name:='shared_servers'             ;rqPR.Comp:='='  ;rqPR.Value:='0'                   ;rqPR.InPfile:=0; rqPR.severity:='error'                                            ;rqPR.Info:='because we use "Oracle non-blocking server mode", which is incompatible with "Oracle connection pooling" and "Oracle shared servers/dispatchers"';rqPR.Env:=''                                                                                                                                                                                    ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='parallel_max_servers'       ;rqPR.Comp:='='  ;rqPR.Value:='0'                   ;rqPR.InPfile:=0; rqPR.severity:='error'                                            ;rqPR.Info:='to avoid some performance, disconnection and sort order issues'                                                                                  ;rqPR.Env:=''''||:OMPApplicationVersion||'''<''05_41'''                                                                                                                                          ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='undo_retention'             ;rqPR.Comp:='>=' ;rqPR.Value:='3600'                ;rqPR.InPfile:=0; rqPR.severity:='error'                                            ;rqPR.Info:='to allow for large batch jobs'                                                                                                                   ;rqPR.Env:=''                                                                                                                                                                                    ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='undo_management'            ;rqPR.Comp:='='  ;rqPR.Value:='AUTO'                ;rqPR.InPfile:=0; rqPR.severity:='error'                                            ;rqPR.Info:='to enable Oracle to manage undo tablespaces'                                                                                                     ;rqPR.Env:=''                                                                                                                                                                                    ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='open_cursors'               ;rqPR.Comp:='>=' ;rqPR.Value:='5000'                ;rqPR.InPfile:=0; rqPR.severity:='error'                                            ;rqPR.Info:='to avoid the error ''ORA-01000 maximum open cursors exceeded'''                                                                                  ;rqPR.Env:=''                                                                                                                                                                                    ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='open_cursors'               ;rqPR.Comp:='<=' ;rqPR.Value:='50000'               ;rqPR.InPfile:=0; rqPR.severity:='warning'                                          ;rqPR.Info:='because a value much larger than needed (more than 10x the required 5000) is suboptimal use of memory'                                           ;rqPR.Env:=''                                                                                                                                                                                    ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='_optim_peek_user_binds'     ;rqPR.Comp:='='  ;rqPR.Value:='FALSE'               ;rqPR.InPfile:=0; rqPR.severity:=case when :Vxx>=12 then 'warning' else 'error' end ;rqPR.Info:='to avoid disconnection issues and unstable performance'                                                                                          ;rqPR.Env:=''''||:Vxx_yy||'''>=''11.02'''                                                                                                                                                        ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='deferred_segment_creation'  ;rqPR.Comp:='='  ;rqPR.Value:='FALSE'               ;rqPR.InPfile:=0; rqPR.severity:='error'                                            ;rqPR.Info:='to make sure export (with exp.exe) also exports empty tables.'                                                                                   ;rqPR.Env:=''''||:Vxx_yy||'''>=''11.02'' and '||:EnterpriseEdition||'=1'                                                                                                                         ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='_enable_row_shipping'       ;rqPR.Comp:='='  ;rqPR.Value:='FALSE'               ;rqPR.InPfile:=0; rqPR.severity:='error'                                            ;rqPR.Info:='to avoid Oracle bug 8222774 with error ''ORA-03124: two-task internal error'' on statement ''SELECT ... =:1 '''                                  ;rqPR.Env:=''''||:Vxx_yy||'''=''11.01'''                                                                                                                                                         ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='recyclebin'                 ;rqPR.Comp:='='  ;rqPR.Value:='OFF'                 ;rqPR.InPfile:=0; rqPR.severity:='error'                                            ;rqPR.Info:='because its advantages do not outweigh the disadvantages'                                                                                        ;rqPR.Env:=''                                                                                                                                                                                    ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='undo_suppress_errors'       ;rqPR.Comp:='='  ;rqPR.Value:='TRUE'                ;rqPR.InPfile:=1; rqPR.severity:='error'                                            ;rqPR.Info:='to suppress the Oracle ORA-30019 error'                                                                                                          ;rqPR.Env:=''''||:Vxx_yy||''' in (''10.01'',''09.02'') and (select count(9) from v$parameter where name=''undo_management'' and value=''AUTO'')=1 and '''||:OMPApplicationVersion||'''<''04_14''';rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='memory_target'              ;rqPR.Comp:='='  ;rqPR.Value:='0'                   ;rqPR.InPfile:=1; rqPR.severity:='error'                                            ;rqPR.Info:='to disable Oracle Automatic Memory Management'                                                                                                   ;rqPR.Env:=''''||:Vxx||'''>=''11'''                                                                                                                                                              ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='sga_target'                 ;rqPR.Comp:='='  ;rqPR.Value:='0'                   ;rqPR.InPfile:=1; rqPR.severity:='error'                                            ;rqPR.Info:='to disable Oracle Automatic Shared Memory Management'                                                                                            ;rqPR.Env:=''                                                                                                                                                                                    ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='memory_max_target'          ;rqPR.Comp:='>=' ;rqPR.Value:=:rqSgaMaxSize         ;rqPR.InPfile:=0; rqPR.severity:='warning'                                          ;rqPR.Info:='to avoid ORA-00849 at startup when memory_max_size is less than sga_max_size'                                                                    ;rqPR.Env:='(select isdefault from v$parameter where name=''memory_max_target'')=''FALSE'''                                                                                                      ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR; --in Linux this throws ORA-00849 at startup when memory_max_size is less than sga_max_size; setting memory_max_target also requires memory_target which would enable unwanted AMM
    if (:NLSRDBMSVERSION00 < '12.02.00.01')
    then			
  	  rqPR.Name:='sga_max_size'             ;rqPR.Comp:='='  ;rqPR.Value:=:rqSgaMaxSize         ;rqPR.InPfile:=0; rqPR.severity:='warning'                                          ;rqPR.Info:='to provide sufficient memory for SGA components and allow changes (manually) up to server memory ('||NumberToKMGText(:PhysicalMemory)||')'       ;rqPR.Env:=''                                                                                                                                                                                    ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
    end if;	  
	rqPR.Name:='shared_pool_size'           ;rqPR.Comp:='>=' ;rqPR.Value:=:rqSharedPoolSize     ;rqPR.InPfile:=0; rqPR.severity:='error'                                            ;rqPR.Info:='to ensure a sufficiently large shared pool'                                                                                                      ;rqPR.Env:=''                                                                                                                                                                                    ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='db_cache_size'              ;rqPR.Comp:='>=' ;rqPR.Value:=:rqDbCacheSize        ;rqPR.InPfile:=0; rqPR.severity:='error'                                            ;rqPR.Info:='at startup for performance by caching in buffer pools and for use of streams (e.g. datapump)'                                                    ;rqPR.Env:=''                                                                                                                                                                                    ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='pga_aggregate_target'       ;rqPR.Comp:='<>' ;rqPR.Value:='0'                   ;rqPR.InPfile:=0; rqPR.severity:='error'                                            ;rqPR.Info:='to enable automatic PGA memory management which is strongly recommend by Oracle'                                                                 ;rqPR.Env:=''                                                                                                                                                                                    ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='workarea_size_policy'       ;rqPR.Comp:='='  ;rqPR.Value:='AUTO'                ;rqPR.InPfile:=0; rqPR.severity:='error'                                            ;rqPR.Info:='to enable automatic PGA memory management which is strongly recommend by Oracle'                                                                 ;rqPR.Env:=''                                                                                                                                                                                    ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='pga_aggregate_target'       ;rqPR.Comp:='>=' ;rqPR.Value:=:rqPgaAggregateTarget ;rqPR.InPfile:=0; rqPR.severity:='error'                                            ;rqPR.Info:='to be large enough'                                                                                                                              ;rqPR.Env:=''                                                                                                                                                                                    ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='dml_locks'                  ;rqPR.Comp:='>=' ;rqPR.Value:=:rqDmlLocks           ;rqPR.InPfile:=0; rqPR.severity:='error'                                            ;rqPR.Info:='to avoid locking problems'                                                                                                                       ;rqPR.Env:=''                                                                                                                                                                                    ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='dml_locks'                  ;rqPR.Comp:='<=' ;rqPR.Value:=:rqDmlLocks*10        ;rqPR.InPfile:=0; rqPR.severity:='warning'                                          ;rqPR.Info:='because a value much larger than needed (more than 10x the required '||:rqDmlLocks||') is suboptimal use of memory'                              ;rqPR.Env:=''                                                                                                                                                                                    ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='processes'                  ;rqPR.Comp:='>=' ;rqPR.Value:=:rqProcesses          ;rqPR.InPfile:=0; rqPR.severity:='error'                                            ;rqPR.Info:='to enable sufficient concurrent connections'                                                                                                     ;rqPR.Env:=''                                                                                                                                                                                    ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='processes'                  ;rqPR.Comp:='<=' ;rqPR.Value:=:rqProcesses*10       ;rqPR.InPfile:=0; rqPR.severity:='warning'                                          ;rqPR.Info:='because a value much larger than needed (more than 10x the required '||:rqProcesses||') is suboptimal use of memory'                             ;rqPR.Env:=''                                                                                                                                                                                    ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='job_queue_processes'        ;rqPR.Comp:='>=' ;rqPR.Value:='4'                   ;rqPR.InPfile:=0; rqPR.severity:='error'                                            ;rqPR.Info:='to allow creation of processes for the execution of jobs'                                                                                        ;rqPR.Env:=''                                                                                                                                                                                    ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='db_securefile'              ;rqPR.Comp:='in' ;rqPR.Value:=:db_securefileoption  ;rqPR.InPfile:=0; rqPR.severity:='error'                                            ;rqPR.Info:=:db_securefileinfo                                                                                                                                ;rqPR.Env:=''''||:Vxx||'''>=''11'''                                                                                                                                                              ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='optimizer_dynamic_sampling' ;rqPR.Comp:='='  ;rqPR.Value:='11'                  ;rqPR.InPfile:=0; rqPR.severity:='error'                                            ;rqPR.Info:='ensure best possible performance by allowing the optimizer to use dynamic statistics automatically'                                              ;rqPR.Env:=''''||substr(:NLSRDBMSVERSION00,1,11)||'''>=''12.01.00.02'''                                                                                                                          ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR; --Parameter exists as from 11.2.0.4; however a value of 11 gives Oracle bug 17632286 when patching when version is below 12.1.0.2, therefore we do not change it when below 12.1.0.2; if you need it in lower version, you can still do so manually; see also Bug 17632286 - ORA-600 [qksdsUpdTabStatsCbk:0] when dynamic_sampling=11 (Doc ID 17632286.8)
	rqPR.Name:='_b_tree_bitmap_plans'       ;rqPR.Comp:='='  ;rqPR.Value:='FALSE'               ;rqPR.InPfile:=0; rqPR.severity:='error'                                            ;rqPR.Info:='to avoid unstable performance with bitmap convertion to rowid execution plans, OMP does not have bitmapped indexes'                              ;rqPR.Env:=''''||:Vxx||'''>=''12'''                                                                                                                                                              ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='_no_or_expansion'           ;rqPR.Comp:='='  ;rqPR.Value:='TRUE'                ;rqPR.InPfile:=0; rqPR.severity:='error'                                            ;rqPR.Info:='to avoid Oracle bug 17752995 shared pool memory leak'                                                                                            ;rqPR.Env:=''''||substr(:NLSRDBMSVERSION00,1,11)||'''=''12.01.00.01'' or '''||substr(:NLSRDBMSVERSION00,1,11)||'''=''11.02.00.04'''                                                              ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='optimizer_mode'             ;rqPR.Comp:='='  ;rqPR.Value:='ALL_ROWS'            ;rqPR.InPfile:=0; rqPR.severity:='error'                                            ;rqPR.Info:='for performance'                                                                                                                                 ;rqPR.Env:=''                                                                                                                                                                                    ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	rqPR.Name:='archive_lag_target'         ;rqPR.Comp:='='  ;rqPR.Value:='1800'                ;rqPR.InPfile:=0; rqPR.severity:='warning'                                          ;rqPR.Info:='to limit the amount of data that can be lost by producing archive logs in periods of low(er) activity and make them available for backup'        ;rqPR.Env:=''                                                                                                                                                                                    ;rqPRs.extend; rqPRs(rqPRs.count):=rqPR;
	
	
	bounce:=0;
	:DisablingAMMorASMM:=0;
	:ChangePfile:=0;
	:AddPfileParameters:='';
	:MyPfile:='';
	:MySpfile:='';


	if :v$Parameter=0 or :V$SgaInfo=0 then
		dbms_output.put_line('--   Requirement: Parameters must have appropriate values.');
		if :v$Parameter=0 then
			dbms_output.put_line('--!  Result: Error: You do not have access to ''V$PARAMETER''. Run the ConfigCheck script ''AS SYSDBA''.');
			:ErrorCount:=:ErrorCount+1;
		end if;
		if :V$SgaInfo=0 then
			dbms_output.put_line('--!  Result: Error: You do not have access to ''V$SGAINFO''. Run the ConfigCheck script ''AS SYSDBA''.');
			:ErrorCount:=:ErrorCount+1;
		end if;
		dbms_output.put_line(:Line);
	else -- V$Parameter pretest ok
		for i in 1 .. rqPRs.count
		loop
			if rqPRs(i).Comp='in' then rqPRs(i).Comp:=' in '; end if;
			--Is parameter relevant (cfr. Environment)
			pretestresult:='';
			if rqPRs(i).Env is null then  /* no Environment defined, so parameter should be checked anyway */
				Result:=1;
			else /* verify Environment */
				sqltext:='select case when '||rqPRs(i).Env||' then 1 else 0 end from dual';
	--			dbms_output.put_line('sqltext='||sqltext);
				pretestresult:=sqlpretest(sqltext);
				if not pretestresult is null then
					--Pretesterror
					dbms_output.put_line('--!  Result: Error: Cannot evaluate if parameter ' ||rqPRs(i).name ||' is required in this environment, because');
					dbms_output.put_line('--                  you do not have access to '||pretestresult||'. Run the ConfigCheck script ''AS SYSDBA''.');
					:ErrorCount:=:ErrorCount+1;
					dbms_output.put_line(:Line);
				else
					execute immediate sqltext into Result;
				end if;
			end if;

			if pretestresult is null then
				--No pretesterror for this parameter
				if Result=0 then
					if :info>=1 then
						dbms_output.put_line('--   Info: Parameter: ' ||rqPRs(i).name||rqPRs(i).Comp||rqPRs(i).value ||' is not required in this environment and will not be checked.');
						dbms_output.put_line(:Line);
					end if;
				else
					 --                                                             name||   <  =  >  ||  if value is number, then upper(value) to obtain consistency, e.g. 400M for Megabytes (not 400m) even if input was lowercase
					dbms_output.put_line('--   Requirement: Parameter: ' ||rqPRs(i).name||rqPRs(i).Comp||IfNumber(rqPRs(i).Value,upper(rqPRs(i).Value))||'.');
					--Does parameter exist
					execute immediate 'select count(9) from v$parameter where name=''' ||rqPRs(i).Name || '''' into dbPValueCount;

					--Search Parameter value
					dbPValueNumberCorrection:=0; --initialization
					if dbPValueCount=0 then
						--Parameter does not exist
						if :info>=1 then dbms_output.put_line('--   Info: Parameter does not exist.'); end if;
						dbPValue:='';
					else
						execute immediate 'select value from v$parameter where name=''' ||rqPRs(i).Name || '''' into dbPValue;

						if :info>=1 then 
							dbms_output.put_line('--   Info: actual value: ' ||rqPRs(i).name||'='||case when IsNumber(dbPValue)=1 then NumberToKMGtext(dbPValue) else dbPValue end ||'.');
						end if;


						--Exception has to be made for db_cache_size, since the streams_pool_size and shared IO pool is taken from db_cache_size when needed; update the original database value (like at startup, before transfer to streams or shared io pools) accordingly
						if rqPRs(i).name='db_cache_size' then
							execute immediate 'select value from v$parameter where name=''streams_pool_size''' into StreamsPoolSize;
							execute immediate 'select bytes from V$SgaInfo   where name = ''Granule Size'''    into GranuleSize     ;
	--						dbms_output.put_line('Originally required in ConfigCheck header '||rqPRs(i).name||'='||rqPRs(i).value);
	--						dbms_output.put_line('StreamsPoolSize='||StreamsPoolSize||' ('||NumberToKMGText(StreamsPoolSize)||')');
	--						dbms_output.put_line('GranuleSize='||GranuleSize||' ('||NumberToKMGText(GranuleSize)||')');

							--StreamsPoolSize
							if StreamsPoolSize>0 then
								if :info>=1 then dbms_output.put_line('--   Info: From the original db_cache_size Oracle has already taken '||NumberToKMGText(StreamsPoolSize)||' and assigned it as streams_pool_size.'); end if;
								dbPValueNumberCorrection:=dbPValueNumberCorrection+StreamsPoolSize;
							else
								--Streams_pool_size is now 0, but when using data pump then a value equal to 10% of shared_pool_size will be taken from buffer pool
								execute immediate 'select value from v$parameter where name=''shared_pool_size''' into SharedPoolSize;
								StreamsPoolSize:=10/100*(greatest(SharedPoolSize,KMGtextToNumber(:rqSharedPoolSize)));
								--take into account memory granule size: round up to multiple of GranuleSize
								StreamsPoolSize:=ceil(StreamsPoolSize/GranuleSize)*GranuleSize;
								if :info>=1 then dbms_output.put_line('--   Info: From the actual db_cache_size Oracle will take '||NumberToKMGText(StreamsPoolSize)||' when using datapump and assign it as streams_pool_size.'); end if;
							end if;

							--SharedIOPoolSize
							if :v$MemoryDynamicComponents>0 then
								execute immediate 'select current_size from v$memory_dynamic_components where component=''Shared IO Pool''' into SharedIOPoolSize;
		--						dbms_output.put_line('SharedIOPoolSize='||SharedIOPoolSize||' ('||NumberToKMGText(SharedIOPoolSize)||')');
								if SharedIOPoolSize>0 then
									if :info>=1 then dbms_output.put_line('--   Info: From the original db_cache_size Oracle has already taken '||NumberToKMGText(SharedIOPoolSize)||' and assigned it as shared IO pool.'); end if;
									dbPValueNumberCorrection:=dbPValueNumberCorrection+SharedIOPoolSize;
								else
									--SharedIOPoolSize is now 0, but when Oracle deems it necessary it will assign 4% of buffer cache to Shared IO Pool.
									execute immediate 'select value from v$parameter where name=''shared_pool_size''' into SharedPoolSize;
									SharedIOPoolSize:=4/100*(dbPValue);
									--take into account memory granule size: round up to multiple of GranuleSize
									SharedIOPoolSize:=ceil(SharedIOPoolSize/GranuleSize)*GranuleSize;
									if :info>=1 then dbms_output.put_line('--   Info: From the actual db_cache_size Oracle will take '||NumberToKMGText(StreamsPoolSize)||' for securefile lobs operations when nocache (default) is used for the lobs.'); end if;
								end if;
							end if;

						end if;

						--Now we can obtain the result by comparing the value in the database with the requirement (rqPRs(i).value) using the correct comparison method (rqPRs(i).Comp)
						--Select statements below are slightly different depending on data type of parameter value (number/text), therefore code is split per data type
						--When an IN is required with numbers we keep them treated as text
						if IsNumber(rqPRs(i).Value)=1 then /* Parameter value is a number, taking into account possibility of unit=K/M/G, and allow for comma-separated list of values for IN comparison */
	--						dbms_output.put_line('Parameter '||rqPRs(i).name||': value '||rqPRs(i).Value||' will be treated as a NUMBER');
							RqNumberNumber:=KMGtextToNumber(rqPRs(i).Value);
	--						dbms_output.put_line('select case when value+'||dbPValueNumberCorrection||rqPRs(i).Comp||RqNumberNumber||' then 1 else 0 end from v$parameter where name=''' ||rqPRs(i).Name || '''');
							execute immediate 'select case when value+'||dbPValueNumberCorrection||rqPRs(i).Comp||RqNumberNumber||' then 1 else 0 end from v$parameter where name=''' ||rqPRs(i).Name || '''' into Result;
							--Prepare output in correct KMG format:
							dbPValue:=NumberToKMGtext(dbPValue);

						else /* Parameter value is text */
	--						dbms_output.put_line('Parameter '||rqPRs(i).name||': value '||rqPRs(i).Value||' will be treated as TEXT');
							if rqPRs(i).Comp=' in ' then
	--							dbms_output.put_line('select case when '''||dbPValue||''' in '             ||rqPRs(i).value||'   then 1 else 0 end  from v$parameter where name=''' ||rqPRs(i).Name || '''');
								execute immediate    'select case when '''||dbPValue||''' in '             ||rqPRs(i).value||'   then 1 else 0 end  from v$parameter where name=''' ||rqPRs(i).Name || '''' into Result;
							else
	--							dbms_output.put_line('select case when value'||rqPRs(i).Comp||''''||rqPRs(i).value||''' then 1 else 0 end  from v$parameter where name=''' ||rqPRs(i).Name || '''');
								execute immediate    'select case when value'||rqPRs(i).Comp||''''||rqPRs(i).value||''' then 1 else 0 end  from v$parameter where name=''' ||rqPRs(i).Name || '''' into Result;
							end if;
	--						dbms_output.put_line('Result='||Result);
						end if;
						
					end if;

					if Result=1 and dbPValue is not null then
						dbms_output.put_line('--   Result: OK.');
					else
						
						if rqPRs(i).severity	='warning' then
							dbms_output.put_line('--(!)Result: Warning: Invalid parameter value.');
							:WarningCount:=:WarningCount+1;
						else
							dbms_output.put_line('--!  Result: Error: Invalid parameter value.');
							:ErrorCount:=:ErrorCount+1;
						end if;
						dbms_output.put_line('--   Reason: Parameter ' ||rqPRs(i).name||' should be '||ltrim(rqPRs(i).Comp)||rqPRs(i).value||' '||rqPRs(i).Info||'.');
						newparametervalue:=rqPRs(i).value;
						--If rqPRs(i).value is not one value, but a list of values (evaluated with IN operator), then the FIRST value will be used to set the parameter
						--so value AAA should remain AAA, but value ('AA','BB','CC') should become AA
						--Method: add a ', then take the string up to the first ', and trim the leading ('
						--This is done on the next line
						newparametervalue:=ltrim(substr(rqPRs(i).value,1,instr(rqPRs(i).value||''',',''',')-1),'(''');

						--An exception is required for sga_max_size when the database is now running in AMM/ASMM, then the sga_max_size should not be changed before the switch to MMM
						if rqPRs(i).Name in ('sga_max_size','memory_max_target','db_cache_size','pga_aggregate_target','shared_pool_size','dml_locks') and :DisablingAMMorASMM=1 then
							rqPRs(i).InPfile:=1;
						end if;
						--Also when processes has to be increased:
						if rqPRs(i).Name in ('processes') and KMGTextToNumber(dbPValue)<KMGTextToNumber(newparametervalue) and :DisablingAMMorASMM=1 then
							rqPRs(i).InPfile:=1;
						end if;

						if rqPRs(i).Comp='<>' then
							--Ignore parameters with "<>" requirement, like pga_aggregate_target<>0; their correct setting will need to be set in another parameter loop, e.g. pga_aggregate_target=:rqPgaAggregateTarget
							--In other words: you can set a parameter 'to' some value, but you cannot set a value to 'different from' some value
							dbms_output.put_line('--   Solution: Parameter needs modification; this will be set elsewhere in this script.');
						else
							if rqPRs(i).InPfile=1 then --pfile corrections will be grouped together and output later
								:ChangePfile:=1;
								if rqPRs(i).Name in ('memory_target','sga_target') then --All memory parameters will need to be set
									:DisablingAMMorASMM:=1;
									--also sga_max_target and memory_max_target need to be removed (if set, i.e. when ISDEFAULT from v$parameter is FALSE; we'll just propose to remove them anyway)
									RemovePR.Name:='sga_max_target';
									RemovePRs.extend;
									RemovePRs(RemovePRs.count):=RemovePR;
									RemovePR.Name:='memory_max_target';
									RemovePRs.extend;
									RemovePRs(RemovePRs.count):=RemovePR;
								end if;
								AddPR.Name:=rqPRs(i).Name;
								AddPR.Comp:=rqPRs(i).Comp;
								AddPR.NewValue:=newparametervalue;
								AddPR.OldValue:=DBPValue;
								AddPRs.extend;
								AddPRs(AddPRs.count):=AddPR;
								:AddPfileParameters:=:AddPfileParameters||:NEWLINE||''||rqPRs(i).Name||'='||newparametervalue;
								dbms_output.put_line('--   Solution: Set parameter by modifying pfile; see instructions below.');
							else --Parameters which can be corrected dynamically
								dbms_output.put_line('--   Solution: Set parameter by executing the following statement:');
								--Add keyword 'scope=both' or 'deferred' as required:
								if dbPValueCount=0 then
									--Parameter does not exist; assume IsSys_Modifiable=IMMEDIATE ==> scope=both (e.g. _optim_peek_user_binds)
									dbPisSysModifiable:='IMMEDIATE';
								else
									execute immediate 'select IsSys_Modifiable from v$parameter where name=''' ||rqPRs(i).Name || '''' into dbPisSysModifiable;
								end if;
								if dbPisSysModifiable='DEFERRED' then
									Suffix:='deferred';
									bounce:=bounce+1;
   							  	    dbms_output.put_line(REPLACE('--   This statement also requires a database restart to become active; therefore issue also the shutdown/startup statements:','--',:SafeMode));
								elsif dbPisSysModifiable='FALSE' or rqPRs(i).name='db_cache_size' then
                                  --Note on handling db_cache_size using spfile: 
								  --   The Oracle db_cache_size memory value has a different meaning depending on the timing: at startup it will still include memory to be transferred from cache to streams and/or shared IO,
                                  --   but later (e.g. after using datapump) memory will have been transferred from cache to these other pools.
								  --   Therefore modifying this parameter using scope=both could be incorrect: the spfile value includes the memory to be transferred after bounce, but the memory value will exclude this.
								  --   Otherwise said, using scope=both would set the memory db_cache_size parameter too high when streams_pool_size of Shared IO pool is nonzero.
                                  Suffix:='scope=spfile';
								  bounce:=bounce+1;
                                  --
                                  dbms_output.put_line(REPLACE('--   This statement also requires a database restart to become active; therefore issue also the shutdown/startup statements:','--',:SafeMode));
								else
									Suffix:='scope=both';
								end if;
 							    dbms_output.put_line(:SafeMode || 'alter system set '||case substr(rqPRs(i).name,1,1) when '_' then '"'|| rqPRs(i).name||'"' else rqPRs(i).name end||'='||newparametervalue||' '||Suffix||';');
								
								--When isSys_Modifiable is deferred/false, we should bounce. We should not wait in doing so, because subsequent parameter changes might be dependent on this change (e.g. maybe sga_max_size (type deferred) has to be increased before db_cache_size can be increased)
								if bounce>0 then
								  dbms_output.put_line(:SafeMode || 'shutdown immediate');
								  dbms_output.put_line(:SafeMode || 'startup');
								  --
                                  bounce:=bounce-1;
								end if;

								--Additional statments or note(s) for specific parameters
								case rqPRs(i).name
									when 'shared_servers' then
										dbms_output.put_line('--   Info: An alternative solution if shared_servers cannot be set to 0, is to specify ''SERVER=DEDICATED'' in TNSNAMES.ORA. See OM Partners Oracle server installation manual for more info and example.');
									else
										null;
								end case;
							end if;
						end if;
					end if;
					dbms_output.put_line(:Line);
				end if;
--   			dbms_output.put_line('ChangePfile='||:ChangePfile);
			--else
				--stop further execution for this parameter because of PretestError; errortext is already given earlier
			end if;
		end loop;

		If :ChangePfile=1 then --Pfile has to be created and checked
			dbms_output.put_line('--   Some of the above parameters can only be set reliably by modifying the PFILE.');
			dbms_output.put_line('--   Steps to follow:');
			execute immediate 'select value from v$parameter where name=''spfile''' into :MySpfile;
			execute immediate 'select value from v$parameter where name=''instance_name''' into MySID;

			if :OSWINNT=1 then
				PathSeparator:='\';
			else
				PathSeparator:='/'; --'
			end if;

			prefix:='OM_';


			if :MySpfile is null then
				--The database was started from a pfile and not from spfile, provide assumed pfile name
				--find Oracle_home
				--pretest
				if :DbaLibraries=1 then
					execute immediate 'select substr(file_spec, 1, instr(file_spec, '''||PathSeparator||''', -1, 2) -1) from SYS.DBA_libraries where library_name = ''DBMS_SUMADV_LIB''' into OracleHome;
				end if;
--				dbms_output.put_line('Oracle_home='||OracleHome);
				if :OSWINNT=1 then
					:MyPfileDir:=OracleHome||PathSeparator||'database'||PathSeparator;
				else
					:MyPfileDir:=OracleHome||PathSeparator||'dbs'||PathSeparator;
				end if;
				:MyPfile:=:MyPfileDir||'init'||MySID||'.ora';--Prefix is NOT added here

				dbms_output.put_line('--(!)Warning: The database was started from a pfile and not from spfile. Assuming the pfile is the default '||:MyPfile||'.');
				:warningcount:=:warningcount+1;
				--Test whether assumed :MyPfile exists
			else
--				dbms_output.put_line('MySpfile='||:MySpfile);
				--Now define the directory of the pfile to be created
				
				if :OracleASM=1 then
					--when using Oracle ASM then create pfile in your working directory because we will modify this file with OS statements
					:MyPfileDir:=:WorkingDirectory||:ClientPathSeparator;
				else
					--use the same directory as the Spfile
					:MyPfileDir:=substr(:MySpfile,1,instr(:MySpfile,PathSeparator,-1));
				end if;
 				:MyPfile:=:MyPfileDir||prefix||'init'||MySID||'.ora';
				
--				dbms_output.put_line(':MyPfile='||:MyPfile);
				dbms_output.put_line('--   create pfile from existing configuration:');
				dbms_output.put_line(:SafeMode || 'create pfile='''||:MyPfile||''' from spfile;');
			end if;

			--The actual changes to the pfile will be initiated outside this PLSQL block.

			for r in 1..RemovePRs.count loop
				if :OSWinnt=1 then
					:RemoveParameterList:=:RemoveParameterList||' '||RemovePRs(r).name;
				else
					:RemoveParameterList:=:RemoveParameterList||'|'||RemovePRs(r).name;
				end if;
			end loop;
--			dbms_output.put_line(':RemoveParameterList='||:RemoveParameterList||'.');
			--remove leading separator
			if :OSWinnt=1 then
				:RemoveParameterList:=substr(:RemoveParameterList,2,length(:RemoveParameterList)-1);
			else
				:RemoveParameterList:=substr(:RemoveParameterList,2,length(:RemoveParameterList)-1);
			end if;
--			dbms_output.put_line(':RemoveParameterList='||:RemoveParameterList||'.');

			for r in 1..AddPRs.count loop
				if :OSWinnt=1 then
					:AddParameterList:=:AddParameterList||' '||AddPRs(r).name;
				else
					:AddParameterList:=:AddParameterList||'|'||AddPRs(r).name;
				end if;
			end loop;
			--remove leading separator
			if :OSWinnt=1 then
				:AddParameterList:=substr(:AddParameterList,2,length(:AddParameterList)-1);
			else
				:AddParameterList:=substr(:AddParameterList,2,length(:AddParameterList)-1);
			end if;
--			dbms_output.put_line(':AddParameterList='||:AddParameterList);
			if :AddPfileParameters is not null then
				--remove leading NEWLINE
				:AddPfileParameters:=regexp_replace(:AddPfileParameters,:NEWLINE,'',1,1);
			end if;

		elsif bounce>0 then
			dbms_output.put_line(REPLACE('-- ' || bounce ||' of the above statements require a database restart; therefore issue also the following statements','-- ',:SafeMode));
			dbms_output.put_line(:SafeMode || 'shutdown immediate');
			dbms_output.put_line(:SafeMode || 'startup');
			dbms_output.put_line(:SafeMode || :Line);
		end if;
	end if;
end;
/

--Store AddPfileParameters in files for later use (e.g. findstr)
set termout off
spool OM__AddPfileParameters.txt
begin
	dbms_output.put_line(:AddPfileParameters);
end;
/
spool off


set termout on
--Continue original spoolfile
spool FixMissing_&datab._&timestamp..sql append

--Create copy of pfile which will become the new Pfile (if needed)
set termout off
set lines 32767
spool OM__AdjustPfile0.sql
declare
	NewPfile    nvarchar2(2000);
	Ihostname   varchar2(100);
	Shostname   varchar2(100);
	ErrorText   varchar2(1000);
begin
	if :ChangePfile=1 and :MySpfile is not null then
		--to create pfile the SYSDBA or SYSOPER privilege is required
		if '''&_PRIVILEGE'''='''AS SYSDBA''' or '''&_PRIVILEGE'''='''AS SYSOPER'''then
		  --Working with pfile is only possible if you are running sqlplus from the database server itself:
			if :V$instance>0 then
				execute immediate 'select host_name from v$instance' into Ihostname;
				execute immediate 'select SYS_CONTEXT(''USERENV'',''HOST'') from dual' into Shostname;
				--In Win_NT, domain is added to above HOST, therefore let's now strip the domain prefix (if any); in Linux nothing will have to be stripped; as long as host does not contain '\', we do not have to differentiate between Win/Linux.
				Shostname:=substr(Shostname,instr(Shostname,'\')+1);
				--dbms_output.put_line('Ihostname='||Shostname);
				if Ihostname<>Shostname then
					Errortext:='--!  Error: You have to run the ConfigCheck script from machine '''||IHostname||''' (and not from the actual machine '''||SHostname||''').';
					:errorcount:=:errorcount+1;
				else
					--Now we are ready to work with the pfile
					dbms_output.put_line('set termout off');
					NewPfile:='OM_NewPfile.ora';
					dbms_output.put_line(:SafeMode || 'create pfile='''||:MyPfile||''' from spfile;');
					if :ClientOSWINNT=1 then
						dbms_output.put_line(':SafeMode || host move /y "'||:MyPfile||'" "'||NewPfile||'">>OM__Error');
					else
						dbms_output.put_line(':SafeMode || host mv -f "'||:MyPfile||'" "'||NewPfile||'">>OM__Error');
					end if;
					dbms_output.put_line('set termout on');
				end if;
			else
				ErrorText:='--!  Result: Error: You do not have access to ''V$INSTANCE''. Run the ConfigCheck script ''AS SYSDBA''.';
				:errorcount:=:errorcount+1;
				dbms_output.put_line(:Line);
			end if;
		else
			ErrorText:='--!  ERROR: You must be logged on ''AS SYSDBA''.';
	  		:errorcount:=:errorcount+1;
	  		--Keep Ihostname so we can put it in errormessage
	  		if :V$instance>0 then
	  		   execute immediate 'select host_name from v$instance' into Ihostname;
	  		else
	  		   Ihostname:='the database server';
	  		end if;
		end if;
		--If an ErrorText was prepared above, this has to be shown.
		if Errortext is not null then
			--Error has to be in spoolfile and termout
			--Error itself will be given when OM__AdjustPfile0.sql is executed
			dbms_output.put_line('set termout on');
			--Continue original spoolfile
			dbms_output.put_line('spool FixMissing_'||'&datab'||'_'||'&timestamp'||'.sql'||' append');

			dbms_output.put_line('exec dbms_output.put_line('''||replace(ErrorText,'''','''''')||''');');
			dbms_output.put_line('exec dbms_output.put_line(''--   Due to above error, this output will not contain the statements to modify the pfile. Execute this script again on '||IHostname||' as SYSDBA,'');');
			dbms_output.put_line('exec dbms_output.put_line(''--   or follow this manual procedure:'');');
			dbms_output.put_line('exec dbms_output.put_line(''--      - Remove from the pfile all hidden parameters starting with __ and ending in size, like __shared_pool_size'');');
			dbms_output.put_line('exec dbms_output.put_line(''--        (which is hard to spot through "show parameter", hard to get rid of without this procedure, but always overrules shared_pool_size)'');');
			dbms_output.put_line('exec dbms_output.put_line(''--      - Make sure the following values are set in the pfile:'');');
			dbms_output.put_line('exec dbms_output.put_line(''--           memory_target=0'');');
			dbms_output.put_line('exec dbms_output.put_line(''--           memory_max_target=0'');');
			dbms_output.put_line('exec dbms_output.put_line(''--           sga_target=0'');');
			dbms_output.put_line('exec dbms_output.put_line(''--           pga_aggregate_target=''||:rqPgaAggregateTarget);');
			dbms_output.put_line('exec dbms_output.put_line(''--           db_cache_size=''||:rqDbCacheSize);');
			dbms_output.put_line('exec dbms_output.put_line(''--           shared_pool_size=''||:rqSharedPoolSize);');
			dbms_output.put_line('exec dbms_output.put_line(''--      - Issue the following statements to make the new parameters active (first with pfile, then with spfile):'');');
			dbms_output.put_line('exec dbms_output.put_line(''--           shutdown immediate'');');
			dbms_output.put_line('exec dbms_output.put_line(''--           startup pfile='''''||:MyPfile||''''''');');
			dbms_output.put_line('exec dbms_output.put_line(''--           create spfile from pfile='''''||:MyPfile||''''';'');');			
			dbms_output.put_line('exec dbms_output.put_line(''--           shutdown immediate'');');
			dbms_output.put_line('exec dbms_output.put_line(''--           startup'');');

			--Stop further output regarding automatic pfile modifications
			:ChangePfile:=0;
			dbms_output.put_line('exec dbms_output.put_line('''||:Line||''')');
		
		end if;
	else
		--Nothing to do (because no changes required, or because started from pfile); empty spoolfile OM__AdjustPfile.sql will have been created anyway.
		null;
	end if;
end;
/
spool off
set lines 200
@OM__AdjustPfile0.sql
host del OM__AdjustPfile0.sql 2>>OM__Error
host rm OM__AdjustPfile0.sql 2>>OM__Error

--If started from pfile (not spfile), check whether assumed filename exists
set termout off
set lines 32767
spool OM__AdjustPfile2.cmd
begin
	--Create empty .sql so further script execution continues without errors, also when the pfile exists in the OS
	if :ClientOSWINNT=1 then
		dbms_output.put_line('@type nul> OM__AdjustPfile2.sql');
	else
		dbms_output.put_line('echo -->OM__AdjustPfile2.sql');
	end if;
	--add resetting :MyPfile to '' if file is not found in the OS
	if :MySpfile is null and :ClientOSWINNT<>-1 then
		if :ClientOSWINNT=1 then
			dbms_output.put_line('@if not exist "'||:MyPfile||'" echo exec :MyPfile:='||''''||'''>OM__AdjustPfile2.sql');
		else
			--escape ampersand by putting it at end of string
			dbms_output.put_line('[ ! -f "'||:MyPfile||'" ] &' ||'&' ||' echo exec :MyPfile:='||'\'''||'\''>OM__AdjustPfile2.sql');
		end if;
	--else started from spfile so pfile should not be checked; empty .sql is already created to avoid Unable-to-open-file  errors
	end if;
	--Reporting the results will be done afterwards
end;
/
spool off

set lines 200
--Execute .cmd
host OM__AdjustPfile2.cmd 2>>OM__Error
host chmod u+x OM__AdjustPfile2.cmd 2>>OM__Error
host ./OM__AdjustPfile2.cmd 2>>OM__Error
set termout on

--Continue original spoolfile
spool FixMissing_&datab._&timestamp..sql append
--Execute newly created .sql
start OM__AdjustPfile2.sql

begin
	if :ChangePfile=1 and :MySpfile is null then
		--In this situation we will have an assumed pfile, which was checked in the block above. We can now report the results.
		if :MyPfile is null then
			dbms_output.put_line('--!  ERROR: Pfile could not be found.');
			:ErrorCount:=:Errorcount+1;
			dbms_output.put_line('--   Solution: Start database from spfile or use default pfile mentioned above.');
			dbms_output.put_line(:Line);
		else
			if :Info>0 then dbms_output.put_line('--   Info: pfile '''||:MyPfile||''' exists.'); end if;
		end if;
	end if;
end;
/


set termout off
set lines 32767
--Important note to understand the block below:
--In order to be able to show the output of OS commands (e.g. parameters to be removed with findstr/grep) in the output spool file FixMissing.sql,
--all further output is given using echos in OM__AdjustPfile.cmd (which output their echo to OM__AdjustPfile.sql, which subsequently shows the actual final output).
spool OM__AdjustPfile.cmd
declare
	Comment     varchar2(10);
	workfile    nvarchar2(2000);
	NewPfile    nvarchar2(2000);
	pretext     nvarchar2(2000);
	posttext    nvarchar2(2000);
	OSstatement nvarchar2(2000);

begin
	--Set comment identifier to be used in command files
	if :ClientOSWINNT=1 then
		Comment:='REM ';
	else
		Comment :='# ';
	end if;

	if :ChangePfile=1 and :MyPfile is not null then
		if :ClientOSWINNT=1 then
			dbms_output.put_line('@echo off');
			dbms_output.put_line('type nul>OM__AdjustPfile.sql');
		else
			dbms_output.put_line('echo -->OM__AdjustPfile.sql');
		end if;


		if :MyPfile is null then
			--Continue trying with assumed pfile
			null;
		else
			null;
		end if;


		if '''&_PRIVILEGE'''='''AS SYSDBA''' or '''&_PRIVILEGE'''='''AS SYSOPER''' then --to create pfile the SYSDBA or SYSOPER privilege is required
			NewPfile:='OM_NewPfile.ora';
			workfile:='OM_Workfile';
			if :ClientOSWINNT=1 then
				dbms_output.put_line('echo exec dbms_output.put_line(''--   Create copy of pfile as working copy'')>>OM__AdjustPfile.sql');
				dbms_output.put_line('echo exec dbms_output.put_line(''host copy /y "''||:MyPfile||''" "'||NewPfile||'"'')>>OM__AdjustPfile.sql');
			else
				dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''--"   "Create copy of pfile as working copy\'''||''')'''||'>>OM__AdjustPfile.sql');
				dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''host cp \"'||:MyPfile||'\" \"'||NewPfile||'\"\'''||''')'''||'>>OM__AdjustPfile.sql');
			end if;

			--REMOVE
			if :RemoveParameterList is not null then
				--Add empty separator line:

				if :ClientOSWINNT=1 then
					--Add empty separator line:
					dbms_output.put_line('echo exec dbms_output.put_line('''')>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line(''--   PARAMETERS TO BE REMOVED:'')>>OM__AdjustPfile.sql');
					--A. display what will be removed:
					--A.1. First put parameters that will be removed in OM_Workfile
					OSstatement:='(findstr /i    "'||:RemoveParameterList||'" "'||NewPfile||'")>OM_Workfile';
					dbms_output.put_line(OSstatement);
					--A.2. Then show the contents of the OM_Workfile
					--empty line
					OSstatement:='for /f "tokens=*" %%g in (om_workfile) do echo exec dbms_output.put_line(''--      %%g'');>>OM__AdjustPfile.sql';
					dbms_output.put_line(OSstatement);

					--B. give statement to do the actual removal
					dbms_output.put_line('echo exec dbms_output.put_line(''--   Therefore issue the next statements:'')>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line(''host (findstr /i /v "'||:RemoveParameterList||'" "'||NewPfile||'")^>OM_Workfile'')>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line(''host move /y "'||workfile||'" "'||NewPfile||'"'')>>OM__AdjustPfile.sql');
				else
					--Add empty separator line:
					dbms_output.put_line('echo exec dbms_output.put_line\(\''\''\)>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''--"   "PARAMETERS TO BE REMOVED:\'''||''')'''||'>>OM__AdjustPfile.sql');
					--A. display what will be removed:
					--A.1. First put parameters that will be removed in OM_Workfile
					OSstatement:='(grep -i "'||:RemoveParameterList||'" "'||NewPfile||'")>OM_Workfile';
					dbms_output.put_line(OSstatement);

					--A.2. Then show the contents of the OM_Workfile
					--empty line
					dbms_output.put_line('while read line; do echo exec dbms_output.put_line\(\''--"      "$line\''\)\;; done<OM_Workfile>>OM__AdjustPfile.sql');

					--B. give statement to do the actual removal
					dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''--"   "Therefore issue the next statements:\'''||''')'''||'>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''host grep -i -v \"'||replace(replace(replace(:RemoveParameterList,'\','\\'),'<','\<'),'|','\\\|')||'\" \"'||NewPfile||'\"\>OM_Workfile\'''||''')'''||'>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''host mv -f \"'||workfile||'\" \"'||NewPfile||'\"\'''||''')'''||'>>OM__AdjustPfile.sql');

				end if;
			end if;
			--END_REMOVE


			--DISABLING AMM/ASMM
			if :DisablingAMMorASMM=1 then
				--Add empty separator line:
				if :ClientOSWINNT=1 then
					dbms_output.put_line('echo exec dbms_output.put_line('''')>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line(''--   PARAMETERS TO BE REMOVED BECAUSE OF AUTOMATIC MEMORY MANAGEMENT'')>>OM__AdjustPfile.sql');

					dbms_output.put_line('echo exec dbms_output.put_line(''--   Parameters starting with two underscores and ending in "size", like __shared_pool_size,'')>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line(''--   are hard to spot through "show parameter", hard to get rid of without this procedure, but always overrule shared_pool_size;'')>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line(''--   they will have to be removed also:'')>>OM__AdjustPfile.sql');

					--A. display what will be removed:
					--A.1. First show parameters that will be removed in OM_Workfile
					OSstatement:='(findstr /i    "\<__.*size" "'||NewPfile||'")>OM_Workfile';
					dbms_output.put_line(OSstatement);
					--A.2. Then show the contents of the OM_Workfile
					OSstatement:='for /f "tokens=*" %%g in (om_workfile) do echo exec dbms_output.put_line(''--      %%g'');>>OM__AdjustPfile.sql';
					dbms_output.put_line(OSstatement);

					--B. give statement to do the actual removal
					dbms_output.put_line('echo exec dbms_output.put_line(''--   with the next statements:'')>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line(''host (findstr /i /v "\<__.*size" "'||NewPfile||'")^>OM_Workfile'')>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line(''host move /y "'||workfile||'" "'||NewPfile||'"'')>>OM__AdjustPfile.sql');
				else
					--Add empty separator line:
					dbms_output.put_line('echo exec dbms_output.put_line\(\''\''\)>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''--"   "PARAMETERS TO BE REMOVED BECAUSE OF AUTOMATIC MEMORY MANAGEMENT\'''||''')'''||'>>OM__AdjustPfile.sql');

					dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''--"   "Parameters starting with two underscores and ending in \"size\", like __shared_pool_size,\'''||''')'''||'>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''--"   "are hard to spot through \"show parameter\", hard to get rid of without this procedure, but always overrule shared_pool_size\;\'''||''')'''||'>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''--"   "they will have to be removed also:\'''||''')'''||'>>OM__AdjustPfile.sql');

					--A. display what will be removed:
					--A.1. First put parameters that will be removed in OM_Workfile
					OSstatement:='(grep -i -w "\<__.*size" "'||NewPfile||'")>OM_Workfile';
					dbms_output.put_line(OSstatement);

					--A.2. Then show the contents of the OM_Workfile
					--empty line
					dbms_output.put_line('while read line; do echo exec dbms_output.put_line\(\''--"      "$line\''\)\;; done<OM_Workfile>>OM__AdjustPfile.sql');

					--B. give statement to do the actual removal
					dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''--"   "Therefore issue the next statements:\'''||''')'''||'>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''host grep -i -v -w \"\\\<__.*size\" \"'||NewPfile||'\"\>OM_Workfile\'''||''')'''||'>>OM__AdjustPfile.sql');--"
					dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''host mv -f \"'||workfile||'\" \"'||NewPfile||'\"\'''||''')'''||'>>OM__AdjustPfile.sql');--"
				end if;
			end if;
			--END DISABLING AMM/ASMM

			--ADD
			if :AddParameterList is not null then

				if :ClientOSWINNT=1 then
					--Add empty separator line:
					dbms_output.put_line('echo exec dbms_output.put_line('''')>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line(''--   PARAMETERS TO BE ADDED OR MODIFIED:'')>>OM__AdjustPfile.sql');
					OSstatement:='for /f "tokens=*" %%g in (OM__AddPfileParameters.txt) do echo exec dbms_output.put_line(''--      %%g'');>>OM__AdjustPfile.sql';
					dbms_output.put_line(OSstatement);
					dbms_output.put_line('echo exec dbms_output.put_line(''--   This includes first removing the following parameters with their old values:'')>>OM__AdjustPfile.sql');

					--A. display what will be removed:
					--A.1. First put parameters that will be removed in OM_Workfile
					OSstatement:='(findstr /i    "'||:AddParameterList||'" "'||NewPfile||'")>OM_Workfile';
					dbms_output.put_line(OSstatement);
					--A.2. Then show the contents of the OM_Workfile
					OSstatement:='for /f "tokens=*" %%g in (om_workfile) do echo exec dbms_output.put_line(''--      %%g'');>>OM__AdjustPfile.sql';
					dbms_output.put_line(OSstatement);

					--B. give statement to do the actual removal
					dbms_output.put_line('echo exec dbms_output.put_line(''--   with the next statements:'')>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line(''host (findstr /i /v "'||:AddParameterList||'" "'||NewPfile||'")^>OM_Workfile'')>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line(''host move /y "'||workfile||'" "'||NewPfile||'"'')>>OM__AdjustPfile.sql');

					--C. Add the parameters with their new values
					dbms_output.put_line('echo exec dbms_output.put_line(''--   Add the parameters and their new values:'')>>OM__AdjustPfile.sql');
					OSstatement:='for /f "tokens=*" %%g in (OM__AddPfileParameters.txt) do echo exec dbms_output.put_line(''--      *.%%g'');>>OM__AdjustPfile.sql';
					dbms_output.put_line(OSstatement);
					dbms_output.put_line('echo exec dbms_output.put_line(''--   with the next statements:'')>>OM__AdjustPfile.sql');
					OSstatement:='for /f "tokens=*" %%g in (OM__AddPfileParameters.txt) do echo exec dbms_output.put_line(''host (echo *.%%g)^>^>'||NewPfile||''');>>OM__AdjustPfile.sql';
					dbms_output.put_line(OSstatement);

				else
					--Add empty separator line:
					dbms_output.put_line('echo exec dbms_output.put_line\(\''\''\)>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''--"   "PARAMETERS TO BE ADDED OR MODIFIED:\'''||''')'''||'>>OM__AdjustPfile.sql');
					dbms_output.put_line('while read line; do echo exec dbms_output.put_line\(\''--"      "$line\''\)\;; done<OM__AddPfileParameters.txt>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''--"   "This includes first removing the following parameters with their old values:\'''||''')'''||'>>OM__AdjustPfile.sql');

					--A. display what will be removed:
					--A.1. First put parameters that will be removed in OM_Workfile
					OSstatement:='(grep -i "'||replace(:AddParameterList,'|','\|')||'" "'||NewPfile||'")>OM_Workfile';
					dbms_output.put_line(OSstatement);


					--A.2. Then show the contents of the OM_Workfile
					--empty line
					dbms_output.put_line('while read line; do echo exec dbms_output.put_line\(\''--"      "$line\''\)\;; done<OM_Workfile>>OM__AdjustPfile.sql');

					--B. give statement to do the actual removal
					dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''--"   "Therefore issue the next statements:\'''||''')'''||'>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''host grep -i -v \"'||replace(replace(replace(:AddParameterList,'\','\\'),'<','\<'),'|','\\\|')||'\" \"'||NewPfile||'\"\>OM_Workfile\'''||''')'''||'>>OM__AdjustPfile.sql');--"
					dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''host mv -f \"'||workfile||'\" \"'||NewPfile||'\"\'''||''')'''||'>>OM__AdjustPfile.sql');--"

					--C. Add the parameters with their new values
					dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''--"   "Add the parameters and their new values:\'''||''')'''||'>>OM__AdjustPfile.sql');
					dbms_output.put_line('while read line; do echo exec dbms_output.put_line\(\''--"      "*.$line\''\)\;; done<OM__AddPfileParameters.txt>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''--"   "with the next statements:\'''||''')'''||'>>OM__AdjustPfile.sql');
					dbms_output.put_line('while read line; do echo exec dbms_output.put_line\(\''host echo *.$line\>\>'||NewPfile||'\''\)\;; done<OM__AddPfileParameters.txt>>OM__AdjustPfile.sql');
				end if;
			end if;
			--END_Add

			--Shutdown and start from new pfile
			if :ClientOSWINNT=1 then
			
				if :OracleASM=0 then
					dbms_output.put_line('echo exec dbms_output.put_line(''--   Move the new pfile to the default location:'')>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line(''host move /y "'||NewPfile||'" "'||:MyPfileDir||'"'')>>OM__AdjustPfile.sql');
				end if;
                
				
				dbms_output.put_line(REPLACE('echo exec dbms_output.put_line(''--   Shutdown and start from new pfile:'')>>OM__AdjustPfile.sql','--',:SafeMode));
				dbms_output.put_line('echo exec dbms_output.put_line(''' || :SafeMode || 'shutdown immediate'')>>OM__AdjustPfile.sql');
				dbms_output.put_line('echo exec dbms_output.put_line(''' || :SafeMode || 'startup pfile='||''''||''''||:MyPfileDir||NewPfile||''''||''''||''')>>OM__AdjustPfile.sql');

				dbms_output.put_line(REPLACE('echo exec dbms_output.put_line(''--   Create new default spfile and start from it:'')>>OM__AdjustPfile.sql','--',:SafeMode));
				if :OracleASM=1 then
					dbms_output.put_line('echo exec dbms_output.put_line(''' || :SafeMode || 'create spfile='||''''||''''||:MySPfile||''''||''''||' from pfile='||''''||''''||:MyPfileDir||NewPfile||''''||''''||';'')>>OM__AdjustPfile.sql');
				else
					dbms_output.put_line('echo exec dbms_output.put_line(''' || :SafeMode || 'create spfile from pfile='||''''||''''||:MyPfileDir||NewPfile||''''||''''||';'')>>OM__AdjustPfile.sql');
				end if;

				dbms_output.put_line('echo exec dbms_output.put_line(''' || :SafeMode || 'shutdown immediate'')>>OM__AdjustPfile.sql');
				dbms_output.put_line('echo exec dbms_output.put_line(''' || :SafeMode || 'startup'')>>OM__AdjustPfile.sql');

			else
				if :OracleASM=0 then
					dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''--"   "Move the new pfile to the default location:\'''||''')'''||'>>OM__AdjustPfile.sql');
					dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''host mv -f \"'||NewPfile||'\" \"'||:MyPfileDir||'\"\'''||''')'''||'>>OM__AdjustPfile.sql');--"
				--else: when using Oracle ASM then pfile has already been created in your working directory
				end if;

				dbms_output.put_line(REPLACE('echo exec dbms_output.put_line'||'''('''||'\''--"   "Shutdown and start from new pfile:\'''||''')'''||'>>OM__AdjustPfile.sql','--',:SafeMode));
				dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''' || :SafeMode || 'shutdown immediate\'''||''')'''||'>>OM__AdjustPfile.sql');
				dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''' || :SafeMode || 'startup pfile=\''\'''||:MyPfileDir||NewPfile||'\''\''\'''||''')'''||'>>OM__AdjustPfile.sql');

				dbms_output.put_line(REPLACE('echo exec dbms_output.put_line'||'''('''||'\''--   Create new default spfile and start from it:\'''||''')'''||'>>OM__AdjustPfile.sql','--',:SafeMode));
				dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''' || :SafeMode || 'create spfile from pfile=\''\'''||:MyPfileDir||NewPfile||'\''\''\;\'''||''')'''||'>>OM__AdjustPfile.sql');
				dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''' || :SafeMode || 'shutdown immediate\'''||''')'''||'>>OM__AdjustPfile.sql');
				dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''' || :SafeMode || 'startup\'''||''')'''||'>>OM__AdjustPfile.sql');
			end if;
		else --no SYSDBA/SYSOPER
			:ErrorCount:=:ErrorCount+1;
			if :ClientOSWINNT=1 then
				dbms_output.put_line('@echo exec dbms_output.put_line(''--!  Result: Error: Cannot continue giving further steps to follow. Run the ConfigCheck script ''''AS SYSDBA''''.'')>>OM__AdjustPfile.sql');
			else
				dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\''--!"  "Result: Error: Incorrect login. Run the ConfigCheck script ''''AS SYSDBA''''.\'''||''')'''||'>>OM__AdjustPfile.sql');
			end if;
		end if;

		--Modifying pfile finished, add line
		if :ClientOSWINNT=1 then
			dbms_output.put_line('echo exec dbms_output.put_line('''||:Line||''')>>OM__AdjustPfile.sql');
		else
			dbms_output.put_line('echo exec dbms_output.put_line'||'''('''||'\'''||:Line||'\'''||''')'''||'>>OM__AdjustPfile.sql');--'
		end if;

	else

		--create empty .sql to avoid Unable-to-open-file  errors
		  if :ClientOSWINNT=1 then
			dbms_output.put_line('@type nul>OM__AdjustPfile.sql');
		else
			dbms_output.put_line('echo -- >OM__AdjustPfile.sql');
		end if;
	end if;
end;
/
--Now the .cmd has been prepared and has to be executed.
spool off

set lines 200
--If pfile was adjusted, we still have to activate it:
--start .cmd to create .sql

host OM__AdjustPfile.cmd 2>>OM__Error
host chmod u+x OM__AdjustPfile.cmd 2>>OM__Error
host ./OM__AdjustPfile.cmd  2>>OM__Error
set termout on

--Continue original spoolfile
spool FixMissing_&datab._&timestamp..sql append
--Execute newly created .sql
start OM__AdjustPfile.sql



-------------------------------------------------------------------------------------
-- PATCHES --------------------------------------------------------------------------
-------------------------------------------------------------------------------------
declare
	statement       varchar2(2000);
	PatchResult     varchar2(2000);
	
	type PatchActionRecord is           record (patch_id number, version varchar2(20), flags varchar2(10), action varchar2(15), status varchar2(15), action_time timestamp(6), description varchar2(100), bundle_series varchar2(30), bundle_id number);
	type PatchActionRecords is table of PatchActionRecord;
	PatchActions                        PatchActionRecords:=PatchActionRecords();
	LastPatchApplied                    PatchActionRecord;
	Patch_idLength                      number:=8;
	VersionLength                       number:=7;
	FlagsLength                         number:=5;
	ActionLength                        number:=6;
	StatusLength                        number:=6;
	Action_timeLength                   number:=11;
	DescriptionLength                   number:=11;
	Bundle_seriesLength                 number:=13;
	Bundle_idLength                     number:=9;
	header                              number:=0;
begin
--	dbms_output.put_line(:NLSRDBMSVERSION00);

--Display patch history
	if :info=1 then
		case
		when :Vxx_yy <= '11.02' then --registry$history based
			if :Registry$History=0 then
				dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.REGISTRY$HISTORY''. Run the ConfigCheck script ''AS SYSDBA''.');
				:ErrorCount:=:ErrorCount+1;
			else
				--Patch actions
				execute immediate 'select id patch_id, '''' version, '''' flags, action, ''''status, action_time, comments description, '''' bundle_series, '''' bundle_id from registry$history order by action_time' bulk collect into PatchActions;
				if PatchActions.count>0 then
					--Prepare patch actions layout
					FOR t in 1 .. PatchActions.count LOOP
						Patch_idLength     :=greatest(Patch_idLength     ,length(PatchActions(t).Patch_id     ));
						ActionLength       :=greatest(ActionLength       ,length(PatchActions(t).Action       ));
						StatusLength       :=greatest(StatusLength       ,length(PatchActions(t).Status       ));
						Action_timeLength  :=greatest(Action_timeLength  ,length(PatchActions(t).Action_time  ));
						DescriptionLength  :=greatest(DescriptionLength  ,length(PatchActions(t).Description  ));
					END LOOP;

					--Report patch actions
					FOR t in 1 .. PatchActions.count LOOP
						if header=0 then
							dbms_output.put_line('--   Info: Patch history:');
							dbms_output.put_line('--      '||' '||rpad('PATCH_ID',patch_idLength)||' '||rpad('ACTION',actionlength)||' '||rpad('STATUS',statuslength)||' '||rpad('ACTION_TIME',action_timelength)||' '||rpad('DESCRIPTION',descriptionlength));
							dbms_output.put_line('--      '||' '||rpad('-',patch_idlength,'-')||' '||rpad('-',actionlength,'-')||' '||rpad('-',statuslength,'-')||' '||rpad('-',action_timelength,'-')||' '||rpad('-',descriptionlength,'-'));
							header:=1;
						end if;
						dbms_output.put_line('--      '||' '||rpad(PatchActions(t).patch_id,patch_idLength)||' '||rpad(PatchActions(t).action,actionlength)||' '||rpad(PatchActions(t).status,statuslength)||' '||rpad(PatchActions(t).action_time,action_timelength)||' '||rpad(PatchActions(t).description,descriptionlength));
--						dbms_output.put_line('--      patch_id, version, flags,action,status,action_time,description, bundle_series,bundle_id ');
					END LOOP;
				else
					dbms_output.put_line('--   Info: No patches could be found in the database.');
				end if;
			end if;
		when :NLSRDBMSVERSION00 = '12.01.00.01.00' then --DBA_REGISTRY_SQLPATCH based
			if :DbaRegistrySqlPatch=0 then
				dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_REGISTRY_SQLPATCH''. Run the ConfigCheck script ''AS SYSDBA''.');
				:ErrorCount:=:ErrorCount+1;
			else
				--Patch actions
				execute immediate 'select patch_id, '''' version, '''' flags, action, status, action_time, description, '''' bundle_series, '''' bundle_id from dba_registry_sqlpatch order by action_time' bulk collect into PatchActions;
				if PatchActions.count>0 then
					--Prepare patch actions layout
					FOR t in 1 .. PatchActions.count LOOP
						Patch_idLength     :=greatest(Patch_idLength     ,length(PatchActions(t).Patch_id     ));
						ActionLength       :=greatest(ActionLength       ,length(PatchActions(t).Action       ));
						StatusLength       :=greatest(StatusLength       ,length(PatchActions(t).Status       ));
						Action_timeLength  :=greatest(Action_timeLength  ,length(PatchActions(t).Action_time  ));
						DescriptionLength  :=greatest(DescriptionLength  ,length(PatchActions(t).Description  ));
					END LOOP;

					--Report patch actions
					FOR t in 1 .. PatchActions.count LOOP
						if header=0 then
							dbms_output.put_line('--   Info: Patch history:');
							dbms_output.put_line('--      '||' '||rpad('PATCH_ID',patch_idLength)||' '||rpad('ACTION',actionlength)||' '||rpad('STATUS',statuslength)||' '||rpad('ACTION_TIME',action_timelength)||' '||rpad('DESCRIPTION',descriptionlength));
							dbms_output.put_line('--      '||' '||rpad('-',patch_idlength,'-')||' '||rpad('-',actionlength,'-')||' '||rpad('-',statuslength,'-')||' '||rpad('-',action_timelength,'-')||' '||rpad('-',descriptionlength,'-'));
							header:=1;
						end if;
						dbms_output.put_line('--      '||' '||rpad(PatchActions(t).patch_id,patch_idLength)||' '||rpad(PatchActions(t).action,actionlength)||' '||rpad(PatchActions(t).status,statuslength)||' '||rpad(PatchActions(t).action_time,action_timelength)||' '||rpad(PatchActions(t).description,descriptionlength));
--						dbms_output.put_line('--      patch_id, version, flags,action,status,action_time,description, bundle_series,bundle_id ');
					END LOOP;
				else
					dbms_output.put_line('--   Info: No patches could be found in the database.');
				end if;
			end if;
		when :NLSRDBMSVERSION00 >= '12.01.00.02'  then --DBA_REGISTRY_SQLPATCH based with extra columns compared to 12.1.0.1
			if :DbaRegistrySqlPatch=0 then
				dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_REGISTRY_SQLPATCH''. Run the ConfigCheck script ''AS SYSDBA''.');
				:ErrorCount:=:ErrorCount+1;
			else
				--Patch actions
				execute immediate 'select patch_id, version, nvl(flags,'' '') flags, action, status, action_time, description, nvl(bundle_series,'' '') bundle_series, bundle_id from dba_registry_sqlpatch order by action_time' bulk collect into PatchActions;
				if PatchActions.count>0 then
					--Prepare patch actions layout
					FOR t in 1 .. PatchActions.count LOOP
						Patch_idLength     :=greatest(Patch_idLength     ,nvl(length(PatchActions(t).Patch_id     ),0));
						VersionLength      :=greatest(VersionLength      ,nvl(length(PatchActions(t).Version      ),0));
						FlagsLength        :=greatest(FlagsLength        ,nvl(length(PatchActions(t).Flags        ),0));
						ActionLength       :=greatest(ActionLength       ,nvl(length(PatchActions(t).Action       ),0));
						StatusLength       :=greatest(StatusLength       ,nvl(length(PatchActions(t).Status       ),0));
						Action_timeLength  :=greatest(Action_timeLength  ,nvl(length(PatchActions(t).Action_time  ),0));
						DescriptionLength  :=greatest(DescriptionLength  ,nvl(length(PatchActions(t).Description  ),0));
						Bundle_seriesLength:=greatest(Bundle_seriesLength,nvl(length(PatchActions(t).Bundle_series),0));
						Bundle_idLength    :=greatest(Bundle_idLength    ,nvl(length(PatchActions(t).Bundle_id    ),0));
					END LOOP;

--					patch_id, version, flags,action,status,action_time,description, bundle_series,bundle_id 
					--Report patch actions
					FOR t in 1 .. PatchActions.count LOOP
						if header=0 then
							dbms_output.put_line('--   Info: Patch history in chronological order:');
							dbms_output.put_line('--      '||rpad('PATCH_ID',patch_idLength)||' '||rpad('VERSION',versionLength)||' '||rpad('FLAGS',flagslength)||' '||rpad('ACTION',actionlength)||' '||rpad('STATUS',statuslength)||' '||rpad('ACTION_TIME',action_timelength)||' '||rpad('BUNDLE_SERIES',Bundle_serieslength)||' '||rpad('BUNDLE_ID',bundle_idlength)||' '||rpad('DESCRIPTION',descriptionlength));
							dbms_output.put_line('--      '||rpad('-',patch_idlength,'-')||' '||rpad('-',versionlength,'-')||' '||rpad('-',flagslength,'-')||' '||rpad('-',actionlength,'-')||' '||rpad('-',statuslength,'-')||' '||rpad('-',action_timelength,'-')||' '||rpad('-',Bundle_serieslength,'-')||' '||rpad('-',bundle_idlength,'-')||' '||rpad('-',descriptionlength,'-'));
							header:=1;
						end if;
						dbms_output.put_line('--      '||rpad(PatchActions(t).patch_id,patch_idLength)||' '||rpad(PatchActions(t).version,versionLength)||' '||rpad(PatchActions(t).flags,flagslength)||' '||rpad(PatchActions(t).action,actionlength)||' '||rpad(PatchActions(t).status,statuslength)||' '||rpad(PatchActions(t).action_time,action_timelength)||' '||rpad(PatchActions(t).Bundle_series,Bundle_serieslength)||' '||rpad(PatchActions(t).bundle_id,bundle_idlength)||' '||rpad(PatchActions(t).description,descriptionlength));
					END LOOP;
				else
					dbms_output.put_line('--   Info: No patches could be found in the database.');
				end if;
			end if;
		else
			null;
		end case;
		dbms_output.put_line(:Line);
	end if;

	--Verify latest patch applied
	case
	when :Vxx_yy in ('11.02','11.01','10.02') then
		dbms_output.put_line('--   Requirement: Patch for Oracle bug 9577583 ("False ORA-942 or other errors when multiple schemas have identical object names") is required.');
		case substr(:NLSRDBMSVERSION00,1,11)
			when '11.02.00.01' then
				--Patch 13 must be applied on 11.2.0.1 systems:
				dbms_output.put_line('--                Oracle 11.2.0.1 requires patch set 4 or higher; we recommend to install patch set 13 or higher.');
				--pretest
				if :registry$history=0 then
					dbms_output.put_line('--!  Result: Error: You do not have access to ''REGISTRY$HISTORY''. Run the ConfigCheck script ''AS SYSDBA''.');
					:ErrorCount:=:ErrorCount+1;
				else
					--statement:= Highest Patch level applied (and not rolled back) above Patch 3 (See also Oracle ID 1114533.1).
					statement:='select max(rh.comments) from sys.registry$history rh, (select comments,version,max(action_time) action_time from sys.registry$history where comments not in (''Patch 1'',''Patch 2'',''Patch 3'') and version=''11.2.0.1'' group by comments,version) lastpatchaction where lastpatchaction.comments=rh.comments and lastpatchaction.version=rh.version and lastpatchaction.action_time=rh.action_time and rh.action=''APPLY''';
					execute immediate statement into PatchResult;
					if PatchResult is null then
						dbms_output.put_line('--!  Result: Error: Oracle 11.2.0.1 requires installing patch set 4 or higher.');
						:ErrorCount:=:ErrorCount+1;
						dbms_output.put_line('--   Reason: On Oracle 11.2.0.1 databases having multiple schemas, it is necessary to install patch set 4 or higher');
						dbms_output.put_line('--           because this includes the fix for Oracle bug 9577583 ("False ora-942 or other errors with multiple schemas having identical objects").');
						dbms_output.put_line('--   Solution: Install patch set 13. This patch set can be obtained from your Oracle vendor.');
					else
						dbms_output.put_line('--   Result: OK.');
					end if;
				end if;
			when '11.02.00.02' then
				dbms_output.put_line('--   Result: OK, this Oracle version already contains the required fix.');
			when '11.02.00.03' then
				dbms_output.put_line('--   Result: OK, this Oracle version already contains the required fix.');
			when '11.02.00.04' then
				dbms_output.put_line('--   Result: OK, this Oracle version already contains the required fix.');
			else
				--Patch required but database is not 11.2.0.1/2/3/4 ==> no detailed instructions for patch installation implemented ==> give warning to check manually
				dbms_output.put_line('--(!)Warning: This version of Oracle requires installing a patch for Oracle bug 9577583. This script does not verify whether this patch is installed on this Oracle version: please check it manually.');
				dbms_output.put_line('--   Solution: Obtain the required patch from your Oracle vendor and ensure it is installed.');
				:WarningCount:=:WarningCount+1;
		end case;
 		dbms_output.put_line(:Line);
	when substr(:NLSRDBMSVERSION00,1,11) = '12.01.00.01' then
			--No patch requirements for 12.1.0.1, so no need to find the latest one
			null;
			--12.1.0.1 patches according to Oracle doc ID 1454618.1 :
			-- Description  PSU                          GI PSU                                   Bundle Patch (Windows)
			-- JUL2016       23054354 (12.1.0.1.160719)  i23273935 / k23273958  (12.1.0.1.160719) 23530410 (12.1.0.1.160719) 
			-- APR2016       22291141 (12.1.0.1.160419)  i22654153 / k22654166 (12.1.0.1.160419)  22617408 (12.1.0.1.160419) 
			-- JAN2016       21951844 (12.1.0.1.160119)  j22191492 / k22191511 (12.1.0.1.160119)  22494866 (12.1.0.2.160119) 
			-- OCT2015       21352619 (12.1.0.1.9)       j21551666 / k21551685 (12.1.0.1.9)       21744907 (12.1.0.1.21) 
			-- JUL2015       20831107 (12.1.0.1.8)       j20996901 / k20996911 (12.1.0.1.8)       21076681 (12.1.0.1.20) 
			-- APR2015       20299016 (12.1.0.1.7)       j20485762 / k19971331 (12.1.0.1.7)       20558101 (12.1.0.1.18) 
			-- JAN2015       19769486 (12.1.0.1.6)       j19971324 / k19971331 (12.1.0.1.6)       20160748 (12.1.0.1.16) 
			-- OCT2014       19121550 (12.1.0.1.5)       j19392372 / k19392451 (12.1.0.1.5)       19542943 (12.1.0.1.14) 
			-- JUL2014       18522516 (12.1.0.1.4)       j18705901 / k18705972 (12.1.0.1.4)       19062327 (12.1.0.1.11) 
			-- APR2014       18031528 (12.1.0.1.3)       j18139660 / k18413105  (12.1.0.1.3)      18448604 (12.1.0.1.7) 
			-- JAN2014       17552800 (12.1.0.1.2)       17735306 (12.1.0.1.2)                    17977915 (12.1.0.1.3) 
			-- OCT2013       17027533 (12.1.0.1.1)       17272829 (12.1.0.1.1)                    17363796 (12.1.0.1.1 64bit)  17363795 (12.1.0.1.1 32bit) 
			-- i only for platforms HP OpenVMS Itanium / HP OpenVMS Alpha
			-- j For Linux x86-64, Solaris X64 and Solaris SPARC     
			-- k For AIX, HP IA / zLinux only contains DB PSU sub-patch and no clusterware sub-patches
	when (:NLSRDBMSVERSION00 >= '12.01.00.02') AND (:NLSRDBMSVERSION00 <= '12.02.00.01') then
		--Patch 12.1.0.2
		 dbms_output.put_line('--   Requirement: Oracle 12.1.0.2 can contain critical Oracle bugs and must be patched.');
		if :DbaRegistrySqlPatch=0 then
			dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_REGISTRY_SQLPATCH''. Run the ConfigCheck script ''AS SYSDBA''.');
			:ErrorCount:=:ErrorCount+1;
		else
			--Highest Patch level applied (and not rolled back)
			statement:='with PatchesApplied as (select r.patch_id, version, flags,action,status,r.action_time,description, bundle_series,bundle_id from dba_registry_sqlpatch r, (select patch_id, max(action_time) action_time from dba_registry_sqlpatch group by patch_id) lastpatchaction where lastpatchaction.patch_id=r.patch_id and lastpatchaction.action_time=r.action_time and r.action=''APPLY'') select * from PatchesApplied where action_time=(select max(action_time) from PatchesApplied)';
			begin
				execute immediate statement into LastPatchApplied;
				dbms_output.put_line('--   Info: Highest patch applied is the '||LastPatchApplied.patch_id||'.');
			exception
				when NO_DATA_FOUND then
					dbms_output.put_line('--   Info: No patches found in dba_registry_sqlpatch.');
				when others then raise;
			end;

			--12.1.0.2 patches according to Oracle doc ID 1454618.1 :
			-- Description  PSU                         GI PSU                       Proactive Bundle Patch      Bundle Patch (Windows 32/64bit) 
			-- OCT2016      24006101 (12.1.0.2.161018)  24412235 (12.1.0.2.161018)   24448103 (12.1.0.2.161018)  24591642 (12.1.0.2.161018) 
			-- JUL2016      23054246 (12.1.0.2.160719)  23273629 (12.1.0.2.160719)   23273686 (12.1.0.2.160719)  23530387 (12.1.0.2.160719) 
			-- APR2016      22291127 (12.1.0.2.160419)  22646084 (12.1.0.2.160419)   22899531                    22809813 (12.1.0.2.160419) 
			-- JAN2016      21948354 (12.1.0.2.160119)  22191349 (12.1.0.2.160119)   22243551                    22310559 (12.1.0.2.160119) 
			-- OCT2015      21359755 (12.1.0.2.5)       21523234 (12.1.0.2.5)        21744410 (12.1.0.2.13)      21821214 (12.1.0.2.10) 
			-- JUL2015      20831110 (12.1.0.2.4)       20996835 (12.1.0.2.4)        21188742 (12.1.0.2.10)      21126814 (12.1.0.2.7) 
			-- APR2015      20299023 (12.1.0.2.3)       20485724 (12.1.0.2.3)        20698050 (12.1.0.2.7)       20684004 (12.1.0.2.4) 
			-- JAN2015      19769480 (12.1.0.2.2)       19954978 (12.1.0.2.2)        20141343 (12.1.0.2.4)       19720843 (12.1.0.2.1) 
			-- OCT2014      19303936 (12.1.0.2.1)       19392646 (12.1.0.2.1)        19404326 (12.1.0.2.1)       N/A 

			if regexp_like(to_char(LastPatchApplied.patch_id),/*APR2015*/ '20299023|20485724|20698050|20684004') or LastPatchApplied.patch_id>20698050 then
				dbms_output.put_line('--   Result: OK.');
			else
				dbms_output.put_line('--!  Result: Error: This Oracle database is not sufficiently patched; it contains Oracle bugs and must be patched as follows:');
				:ErrorCount:=:ErrorCount+1;
				 dbms_output.put_line('--   Solution: Install at least the Oracle April 2015 PSU (20299023) / GI PSU (20485724) / Proactive Bundle Patch (20698050) / Bundle Patch (20684004).');
				 dbms_output.put_line('--             This bundle patch can be obtained from your Oracle vendor.');
				 dbms_output.put_line('--             OM Partners has tested the October 2015 bundle patch (12.1.0.2.4/21821214 on Windows) and proposes to use this bundle patch or a more recent bundle patch.');
			end if;
		end if;
		dbms_output.put_line(:Line);
	else
		null;
	end case;
end;
/

--No product_user_profile limitations
declare
	type PupRec is          record (product varchar2(30), userid varchar2(30), attribute varchar2(240), char_value varchar2(240));
	type TableOfPupRec is   table of PupRec;
	Pups                    TableOfPupRec:=TableOfPupRec();
	i                       number;
	ProductSize             number;
	UserIDSize              number;
	AttributeSize           number;
	Char_ValueSize          number;
begin
	dbms_output.put_line('--   Requirement: Access to database tables and SQL*Plus commands should not be limited by specifying entries in PRODUCT_USER_PROFILE.');

	if '''&_PRIVILEGE'''<>'''AS SYSDBA''' then
		dbms_output.put_line('--!  Result: Error: Cannot verify the existence of PRODUCT_USER_PROFILE. Run the ConfigCheck script ''AS SYSDBA''.');
		:errorcount:=:errorcount+1;
	else
		if :SystemSqlplusProductProfile=0 then
				dbms_output.put_line('--   Info: Table SYSTEM.PRODUCT_USER_PROFILE does not exist. Probably pupbld.sql was never run by SYSTEM.');
				dbms_output.put_line('--   Result: OK.');
				:ErrorCount:=:ErrorCount+1;
		else
			--Note that system.product_user_profile is synonym to table system.SQLPLUS_PRODUCT_PROFILE, and is different from the public synonym product_user_profile which points to a view with a "where USER..." clause, so we do need to use the one owned by SYSTEM.
			execute immediate 'select product, userid, attribute, char_value from system.sqlplus_product_profile' bulk collect into Pups;
			if Pups.Count=0 then
				dbms_output.put_line('--   Info: Table SYSTEM.PRODUCT_USER_PROFILE is empty.');
				dbms_output.put_line('--   Result: OK.');
			else
				dbms_output.put_line('--!  Error: The following '||Pups.count||' records exist in SYSTEM.PRODUCT_USER_PROFILE which might block OM Partners applications:');
				:errorcount:=:errorcount+1;
				--Determine size for nice output
				ProductSize:=length('Product');
				UserIdSize:=length('UserId');
				AttributeSize:=length('Attribute');
				Char_ValueSize:=length('Char_Value');
				for i in Pups.first .. Pups.Last loop
					if length(Pups(i).Product)>ProductSize then ProductSize:=length(Pups(i).Product); end if;
					if length(Pups(i).UserId)>UserIDSize then UserIDSize:=length(Pups(i).UserID); end if;
					if length(Pups(i).Attribute)>AttributeSize then AttributeSize:=length(Pups(i).Attribute); end if;
					if length(Pups(i).char_value)>char_valueSize then char_valueSize:=length(Pups(i).char_value); end if;
				end loop;
				--Output
				--Header
				dbms_output.put_line('--      '||rpad('PRODUCT',ProductSize)||' '||rpad('USERID',UserIDSize)||' '||rpad('ATTRIBUTE',AttributeSize)||' '||rpad('CHAR_VALUE',Char_ValueSize));
				dbms_output.put_line('--      '||rpad('-',ProductSize,'-')||' '||rpad('-',UserIDSize,'-')||' '||rpad('-',AttributeSize,'-')||' '||rpad('-',Char_ValueSize,'-'));
				--Content
				for i in Pups.first .. Pups.Last loop
					dbms_output.put_line('--      '||rpad(Pups(i).Product,ProductSize) ||' '|| rpad(Pups(i).userid,UserIdSize) ||' '|| rpad(Pups(i).attribute,AttributeSize) ||' '|| rpad(Pups(i).char_value,Char_ValueSize));
				end loop;
				dbms_output.put_line('--   Solution: Delete the limitations with the following statements:');
				dbms_output.put_line('delete from system.product_user_profile;');
				dbms_output.put_line('commit;');
			end if;
		end if;
	end if;
	dbms_output.put_line(:Line);
end;
/

-------------------------------------------------------------------------------------
-- PROCEDURE SYS.SLEEP --------------------------------------------------------------
-------------------------------------------------------------------------------------
declare
	SysSleepExists number;
begin
	if not (:SkipSharedSleep=1) then
		dbms_output.put_line('--   Requirement: Procedure SYS.SLEEP must exist.');
		--pretest
		if :DbaObjects=0 then
			dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_OBJECTS''. Run the ConfigCheck script ''AS SYSDBA''.');
			:ErrorCount:=:ErrorCount+1;
		else
			execute immediate 'select count(9) from SYS.DBA_objects where object_name=''SLEEP'' and object_type=''PROCEDURE'' and OWNER=''SYS''' into SysSleepExists;
			if SysSleepExists=0 then
				dbms_output.put_line('--!  Result: Error: Procedure SYS.SLEEP does not exist.');
				:ErrorCount:=:ErrorCount+1;
				dbms_output.put_line('--   Solution: Add the procedure with the following statements:');
				dbms_output.put_line('create or replace procedure sleep (Sleep_TIME IN NUMBER)  is');
				dbms_output.put_line('begin');
				dbms_output.put_line('   sys.dbms_lock.sleep(Sleep_Time);');
				dbms_output.put_line('end;');
				dbms_output.put_line('/');
				dbms_output.put_line('create or replace public synonym sleep for sys.sleep;');
				dbms_output.put_line('grant execute on sleep to public;');
			else
				dbms_output.put_line('--   Result: OK.');
			end if;
		end if;
		dbms_output.put_line(:Line);
	else
		--Situation of Local Sleep procedure will be evaluated later, per user.
		null;
	end if;
end;
/

-------------------------------------------------------------------------------------
-- VIEWS ----------------------------------------------------------------------------
-------------------------------------------------------------------------------------
--Report on missing MYV$ views, if needed; this is not user-specific so let's do this now, before accessing users; also we should report this BEFORE reporting missing grants to it
Declare
  	MYVSessionView                  number;
	MYVLockView                     number;
	MYVLockedObjectView             number;
	i                               number;

	ViewName                        varchar2(30);
	type ToV is                     table of varchar2(30);
	LackingViews                    ToV:=ToV();

Begin
	--This is only relevant when SkipV$Views=1
	If :SkipV$Views=1 then
		--SESSION should always be checked:

		--Show requirement
		--The views MYV$SESSION, MYV$LOCK and MYV$LOCKED_OBJECT should always exist when :SkipV$Views=1
		dbms_output.put_line('--   Requirement: Views SYS.MYV$SESSION, SYS.MYV$LOCK, SYS.MYV$LOCKED_OBJECT must exist.');

		--Collect actual situation
		--Pretest
		--pretest DBA
		if :DbaViews=0 then
			dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_VIEWS''. Run the ConfigCheck script ''AS SYSDBA''.');
			:ErrorCount:=:ErrorCount+1;
		else
			--Let's check them all; if e.g. Lock is not required, we'll suppress the output
			execute immediate 'select count(9) from dba_views        where view_name   =''MYV$SESSION''       and owner=''SYS''                      ' into MYVSessionView;
			execute immediate 'select count(9) from dba_views        where view_name   =''MYV$LOCK''          and owner=''SYS''                      ' into MYVLockView;
			execute immediate 'select count(9) from dba_views        where view_name   =''MYV$LOCKED_OBJECT'' and owner=''SYS''                      ' into MYVLockedObjectView;

			--Debug output
			--dbms_output.put_line('--   MYVSessionView     ='||MYVSessionView);
			--dbms_output.put_line('--   MYVLockView        ='||MYVLockView);
			--dbms_output.put_line('--   MYVLockedObjectView='||MYVLockedObjectView);

			if MYVSessionView=0 then
				LackingViews.extend;
				LackingViews(LackingViews.count):='SESSION';
			else
				if :info>=1 then dbms_output.put_line('--   Info: view SYS.MYV$SESSION exists.'); end if;
			end if;
			if MYVLockView=0 then
				LackingViews.extend;
				LackingViews(LackingViews.count):='LOCK';
			else
				if :info>=1 then dbms_output.put_line('--   Info: view SYS.MYV$LOCK exists.'); end if;
			end if;
			if MYVLockedObjectView=0 then
				LackingViews.extend;
				LackingViews(LackingViews.count):='LOCKED_OBJECT';
			else
				if :info>=1 then dbms_output.put_line('--   Info: view SYS.MYV$LOCKED_OBJECT exists.'); end if;
			end if;

			For i in 1..LackingViews.count loop
				dbms_output.put_line('--!  Error: View SYS.'||LackingViews(i)||' is missing.');
				:Errorcount:=:Errorcount+1;
			End loop;

			if LackingViews.count>0 then
				dbms_output.put_line('--   Solution: create the missing views with the following statements');
				if 'SESSION' member of LackingViews then
					dbms_output.put_line('create or replace view sys.myv$session as select * from sys.'||lower(:xV_$SESSION)||' ' );
					dbms_output.put_line('where username in (' );
					dbms_output.put_line('   --Users should see themselves' );
					dbms_output.put_line('   user,' );
					dbms_output.put_line('   --Users should also see similar users having different planninglayer suffix:' );
					dbms_output.put_line('   regexp_replace(user,''_FCT$|_SOP$|_OPR$|_UTL$'',''_FCT''),' );
					dbms_output.put_line('   regexp_replace(user,''_FCT$|_SOP$|_OPR$|_UTL$'',''_SOP''),' );
					dbms_output.put_line('   regexp_replace(user,''_FCT$|_SOP$|_OPR$|_UTL$'',''_OPR''),' );
					dbms_output.put_line('   regexp_replace(user,''_FCT$|_SOP$|_OPR$|_UTL$'',''_UTL''),' );
					dbms_output.put_line('   --DataOwners should also see (optional) DataUsers:' );
					dbms_output.put_line('   regexp_replace(user,''_FCT$|_SOP$|_OPR$|_UTL$'',''_USER_FCT''),' );
					dbms_output.put_line('   regexp_replace(user,''_FCT$|_SOP$|_OPR$|_UTL$'',''_USER_SOP''),' );
					dbms_output.put_line('   regexp_replace(user,''_FCT$|_SOP$|_OPR$|_UTL$'',''_USER_OPR''),' );
					dbms_output.put_line('   regexp_replace(user,''_FCT$|_SOP$|_OPR$|_UTL$'',''_USER_UTL''),' );
					dbms_output.put_line('   --DataUsers (optional) should also see DataOwners:' );
					dbms_output.put_line('   regexp_replace(user,''_USER_FCT$|_USER_SOP$|_USER_OPR$|_UTL$'',''_FCT''),' );
					dbms_output.put_line('   regexp_replace(user,''_USER_FCT$|_USER_SOP$|_USER_OPR$|_UTL$'',''_SOP''),' );
					dbms_output.put_line('   regexp_replace(user,''_USER_FCT$|_USER_SOP$|_USER_OPR$|_UTL$'',''_OPR''),' );
					dbms_output.put_line('   regexp_replace(user,''_USER_FCT$|_USER_SOP$|_USER_OPR$|_UTL$'',''_UTL'')' );
					dbms_output.put_line(');');
				end if;
				if 'LOCK' member of LackingViews then
					dbms_output.put_line('create or replace view sys.myv$lock as select * from sys.'||lower(:xV_$LOCK)||' where sid in (select sid from sys.myv$session);');
				end if;
				if 'LOCKED_OBJECT' member of LackingViews then
					dbms_output.put_line('create or replace view sys.myv$locked_object as select * from sys.'||lower(:xV_$LOCKED_OBJECT)||' where oracle_username in (select username from sys.myv$session);');
				end if;
			else
				dbms_output.put_line('--   Result: OK.');
			end if;

			--Synonyms to these views will be checked later, per user

end if;
	dbms_output.put_line(:Line);
	end if;
end;
/

declare
	type Triggers           is table of all_triggers%rowtype;
	MyTriggers              Triggers:=Triggers();
	SearchString            varchar2(100):='10949';
	Position                number;
	statement               varchar2(2000);
	event                   number:=10949;
	event_level             number;
	eventset                number;
	EventSetInSpfile        number;
	ValueInSpfile           varchar2(2000);
	triggerfound            number:=0;
	trigger_body            varchar2(32000);
	
begin
	if :NLSRDBMSVERSION00<'12.02' then
		dbms_output.put_line('--   Requirement: Tables should be cached consistently by enabling event 10949 because of Oracle bug 18498878.');
		--pretest
		if :DbmsSystem=0 then
			dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBMS_SYSTEM''. Run the ConfigCheck script ''AS SYSDBA''.');
			:ErrorCount:=:ErrorCount+1;
		else
			statement:='begin sys.dbms_system.read_ev(10949,:event_level); end;';
			execute immediate statement using OUT event_level;
			if (event_level > 0) then
				dbms_output.put_line('--   Info: Event '||event||' is set at level '||	to_char(event_level)||'.');
				eventset:=1;
			else
				dbms_output.put_line('--   Info: Event '||event||' is not set.');
				eventset:=0;
			end if;

			--Is event set in spfile
			if :v$SpParameter=0 then
				dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.V$SPPARAMETER''. Run the ConfigCheck script ''AS SYSDBA''.');
				:ErrorCount:=:ErrorCount+1;
			else
				execute immediate 'select count(value) from v$spparameter where value like '''||SearchString||' trace name context forever%''' into EventSetInSpfile;
				if EventSetInSpfile=1 then
					execute immediate 'select value from v$spparameter where value like '''||SearchString||' trace name context forever%''' into ValueInSpfile;
					dbms_output.put_line('--   Info: Event is set in spfile: '||ValueInSpfile||'.');
				else
					dbms_output.put_line('--   Info: Event is not set in spfile.');
				end if;
			end if;

			if EventSet=0 then
				if EventSetInSpfile=1 then
   				    :ErrorCount:=:ErrorCount+1;
				    --
					dbms_output.put_line(REPLACE('--!  Result: Error: Event '||SearchString||' is specified in spfile but is not active, maybe it was disabled. Please bounce the database to activate it again:','--',:SafeMode));
					dbms_output.put_line(:SafeMode || 'shutdown immediate');
					dbms_output.put_line(:SafeMode || 'startup');
				else
					--Maybe the event is not set at this moment, but all the precautions have been taken to enable it when possible: a trigger can exist which enables the event when there is enough memory available.
					if :DbaTriggers=0 then
						dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_TRIGGERS''. Run the ConfigCheck script ''AS SYSDBA''.');
						:ErrorCount:=:ErrorCount+1;
					else
				      for MyTriggers in (select * from dba_triggers where trim(triggering_event)='STARTUP' and status='ENABLED') loop
				      	trigger_body:=MyTriggers.trigger_body;
				      	position:=regexp_instr(trigger_body,'alter.*system.*set.*events.*'||SearchString||'.*trace.*name.*context.*forever',1,1,0,'i');
			--	      	dbms_output.put_line('Position='||position);
				      	if position>0 then
				         	dbms_output.put_line('--   Info: Trigger ''' || MyTriggers.trigger_name || ''' manipulates event '||SearchString||'.');
				         	triggerfound:=1;
				         end if;
				   	end loop;
		
			      	if triggerfound=1 then
			      		dbms_output.put_line('--(!)Result: Warning: event '||SearchString||' is not set but there seems to be a trigger which can enable it. Performance can be improved with sufficicient memory and enabling event '||SearchString||'.');
			      		:WarningCount:=:WarningCount+1;
			         else
			         	dbms_output.put_line('--(!)Result: Error: Event '||to_char(event)||' is not set and there is no trigger to enable it at startup of the database.');
			         	:ErrorCount:=:ErrorCount+1;
		               dbms_output.put_line('--   Info: You can enable the event in the spfile.');
		               dbms_output.put_line('--         We propose the following trigger which will take into account memory and data size to avoid having the event enabled with insufficient memory.');
		               dbms_output.put_line('--   Solution: Enable event 10949 when appropriate with the following statements:');
		               dbms_output.put_line(rtrim('CREATE OR REPLACE TRIGGER Enable_Big_Table_Caching AFTER STARTUP ON DATABASE                                                                    '));
		               dbms_output.put_line(rtrim('declare                                                                                                                                         '));
		               dbms_output.put_line(rtrim('   db_cache_size_GB    float;                                                                                                                   '));
		               dbms_output.put_line(rtrim('   tablespace_size_GB  float;                                                                                                                   '));
		               dbms_output.put_line(rtrim('   free_space_GB       float;                                                                                                                   '));
		               dbms_output.put_line(rtrim('   used_size_GB        float;                                                                                                                   '));
		               dbms_output.put_line(rtrim('BEGIN                                                                                                                                           '));
		               dbms_output.put_line(rtrim('   select value/1024/1024/1024 gb      into db_cache_size_GB    from v$parameter where name=''db_cache_size'';                                  '));
		               dbms_output.put_line(rtrim('   select sum(bytes)/1024/1024/1024 gb into free_space_GB       from dba_free_space where tablespace_name in (''OMPARTNERS'',''INDEXES'');      '));
		               dbms_output.put_line(rtrim('   select sum(bytes)/1024/1024/1024 gb into tablespace_size_GB  from dba_data_files where tablespace_name in (''OMPARTNERS'',''INDEXES'');      '));
		               dbms_output.put_line(rtrim('   used_size_GB:=tablespace_size_GB-free_space_GB;                                                                                              '));
		               dbms_output.put_line(rtrim('   if (used_size_GB*80/100)<=db_cache_size_GB then                                                                                              '));
		               dbms_output.put_line(rtrim('      /* Enable big table caching when db_cache_size is larger than 80% of actual datasize */                                                   '));
		               dbms_output.put_line(rtrim('    EXECUTE IMMEDIATE ''alter system  set events ''''10949 trace name context forever, level 1'''''' ;                                          '));
		               dbms_output.put_line(rtrim('    /* To disable: alter session set events ''10949 trace name context off''; */                                                                '));
		               dbms_output.put_line(rtrim('   end if;                                                                                                                                      '));
		               dbms_output.put_line(rtrim('END Enable_Big_Table_Caching;                                                                                                                   '));
		               dbms_output.put_line(rtrim('/                                                                                                                                               '));
		            end if;
		      	end if;
		      end if;
			else --Eventset=1 is OK
				dbms_output.put_line('--   Result: OK.');
			end if;
		end if;
		dbms_output.put_line(:Line);
	--else
		-- Oracle bug 18498878 was fixed in 12.2
	end if;
end;
/

-------------------------------------------------------------------------------------
-- EVENT 10262 PGA memory leak reporting --------------------------------------------
-------------------------------------------------------------------------------------
-- It is possible to observe the "ORA-00600 [723]" error: this about a memory leak in the Oracle software.
-- Information from Oracle (summarized from Doc ID 39308.1)
-- -   The PGA memory is checked for Space Leaks at logoff time. This error is reported when a leak was found.
-- -   There is no data corruption with this error.
-- -   Suggestion: Event 10262 can be set to safely ignore small memory leaks. This requires a database restart.
-- -   There are some known bugs related to this leak, which are solved in higher versions
-- We propose to follow the suggestion from Oracle and set the abovementioned event, and ignore memory leaks of less 5% of actual PGA size.

declare
	SearchString            varchar2(100):='10262';
	Position                number;
	statement               varchar2(2000);
	event                   number:=10949;
	event_level             number;
	eventset                number;
	EventSetInSpfile        number;
	ValueInSpfile           varchar2(2000);
	pga							number;
	pgatext                 varchar2(2000);
	ShowStatement           number:=0;
	
	function NumberToKMGtext (NumberIn in number) return varchar2 as
		NumberUNIT                         varchar2(1);
		NumberText                         varchar2(2000);
		Units                              varchar2(10):='KMG';
	begin
		if NumberIn<>0 then
			NumberUNIT:=' ';
			NumberText:=NumberIn;
			for i in 1..length(Units) loop
				if numbertext mod 1024 = 0 then
					numberunit:=substr(Units,i,1);
					numbertext:=numbertext/1024;
				end if;
			end loop;
			return numbertext||''||trim(numberunit);
		else
			return '0';
		end if;
	end;

begin
	dbms_output.put_line('--   Requirement: Follow suggestion from Oracle (Doc ID 39308.1) to set event 10262 to avoid reporting of small pga memory leaks. This test defines ''small'' as maximum 5%.');
	--pretest
	if :DbmsSystem=0 then
		dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBMS_SYSTEM''. Run the ConfigCheck script ''AS SYSDBA''.');
		:ErrorCount:=:ErrorCount+1;
	else
		statement:='begin sys.dbms_system.read_ev(10262,:event_level); end;';
		execute immediate statement using OUT event_level;
		if (event_level > 0) then
			dbms_output.put_line('--   Info: Event '||event||' is set at level '||	to_char(event_level)||' in memory.');
			eventset:=1;
		else
			dbms_output.put_line('--   Info: Event '||event||' is not set in memory.');
			eventset:=0;
		end if;

		--Is event set in spfile
		if :v$SpParameter=0 then
			dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.V$SPPARAMETER''. Run the ConfigCheck script ''AS SYSDBA''.');
			:ErrorCount:=:ErrorCount+1;
		else
			execute immediate 'select count(value) from v$spparameter where value like '''||SearchString||' trace name context forever%''' into EventSetInSpfile;
			if EventSetInSpfile=1 then
				execute immediate 'select value from v$spparameter where value like '''||SearchString||' trace name context forever%''' into ValueInSpfile;
				
				dbms_output.put_line('--   Info: Event is set in spfile: '||ValueInSpfile||'.');
			else
				dbms_output.put_line('--   Info: Event is not set in spfile.');
			end if;
		end if;

		--Get PGA value
		if :v$Parameter=0 then
			dbms_output.put_line('--!  ERROR: You do not have access to ''SYS.V$PARAMETER''. Run the ConfigCheck script ''AS SYSDBA''.');
			:ErrorCount:=:ErrorCount+1;
		else
			begin
				execute immediate 'select value from v$parameter where name like ''pga_aggregate_target''' into pga;
				execute immediate 'select display_value from v$parameter where name like ''pga_aggregate_target''' into pgatext;
				if pga=0 then
					dbms_output.put_line('--!  Error: the value for parameter pga_aggregate_target could not be obtained. Fix memory configuration issues first, then run ConfigCheck again.');
				else
				if :Info=1 then dbms_output.put_line('--   Info: Parameter pga_aggregate_target='||pgatext||', 5% of this value is '||pga*0.05||' ('||NumberToKMGText(pga*0.05)||').'); end if;
					if EventSet=0 then
						if EventSetInSpfile=1 
                        then
  						 :ErrorCount:=:ErrorCount+1;
                         --
						 dbms_output.put_line(REPLACE('--!  Result: Error: Event '||SearchString||' is specified in spfile but is not active.','--',:SafeMode));
						 dbms_output.put_line(REPLACE('--   Solution: to activate it bounce the database with the following statements, then run ConfigCheck again:',:SafeMode));
						 dbms_output.put_line(:Safemode || 'shutdown immediate');
						 dbms_output.put_line(:Safemode || 'startup');						 
 						else
							--Event is not set at all
							dbms_output.put_line('--!  ERROR: The event is not set.');
							:errorcount:=:errorcount+1;
							dbms_output.put_line('--   Solution: set the event at the correct level (5% of pga_aggregate_target) with the following statements:');
							ShowStatement:=1; --Statement given below
						end if;
					else
						--check the value as it should be 5% of pga.
						if event_level>=pga*0.05 then
							dbms_output.put_line('--   Result: OK.');
						else
							dbms_output.put_line('--!  ERROR: Event is not set to a value between 5% of pga_aggregate_target.');
							:errorcount:=:errorcount+1;
							dbms_output.put_line('--   Solution: set the event at the correct level with the following statements:');
							ShowStatement:=1; 
						end if;
					end if;
				end if;
			exception
				when NO_DATA_FOUND then
					dbms_output.put_line('--!  Error: the parameter pga_aggregate_target does not exist. Fix memory configuration issues first, then run ConfigCheck again.');
					:errorcount:=:errorcount+1;
				when OTHERS then RAISE;
			end;

		end if;
	end if;
	
	if ShowStatement=1 then
		dbms_output.put_line(:SafeMode || 'alter system set event = ''10262 trace name context forever, level '||ceil(pga*0.05)||''' scope=spfile;');
		dbms_output.put_line(:SafeMode || 'shutdown immediate');
		dbms_output.put_line(:SafeMode || 'startup');	
	end if;
	
	dbms_output.put_line(:Line);
end;
/

-------------------------------------------------------------------------------------
-- USERS (including role OMPUSER) and PRIVILEGES ------------------------------------
-------------------------------------------------------------------------------------
begin
	if :info>0 then
		dbms_output.put_line('--   Info: Start retrieving detailed information for users now.');
	end if;
end;
/
declare
	type Users is table of          varchar2(30);
	MyUsers                         Users:=Users();
	myUser                          varchar2(30);
	Result                          number;
	UserExists                      number;
	OracleMaintainedExists          number;

	type PrivilegeRec is            record (Privilege varchar2(200), Usage varchar2(300), Directly number, UserIn varchar2(200),UserNotIn varchar2(200), PackOwner number); --74=Privilege(40)||' ON '(4)||table_name(30)
	type UserPrivilege is table of  varchar2(200);
	Usagetype                       varchar2(300);
	type Privileges is              table of PrivilegeRec;
	type UserPrivileges is          table of UserPrivilege;
	rqPRs                           Privileges:=Privileges();
	rqPR                            PrivilegeRec;
	type PrivilegePathRec is        record (RoleOrPrivilege varchar2(200), Grantee varchar2(30), Level number, Path varchar2(2000));
	type UserPrivilegePathRecs is   table of PrivilegePathRec;
	UserHasPsPath                   UserPrivilegePathRecs;
	UserHasPs                       UserPrivilege:=UserPrivilege(); --Privileges the user has
	UserHasPsDirect                 UserPrivilege:=UserPrivilege(); --Privileges the user has through direct grant (not via role)
	UserRqPs                        UserPrivilege:=UserPrivilege(); --Privileges the user requires
	PublicHasPs                     UserPrivilege:=UserPrivilege(); --Privileges PUBLIC has
	PublicHasPsPath                 UserPrivilegePathRecs;

	OMPUserHasPs                    UserPrivilege:=UserPrivilege(); --Privileges OMPUSER has
	UserLacksPs                     UserPrivilege:=UserPrivilege(); --Privileges the user lacks
	UserLacksPsReason               UserPrivilege:=UserPrivilege(); --Reason of existence of the lacking privileges
	type ToN is					        table of number;
	UserLacksPsDirectYN               ToN:=ToN();                     --Requirement to grant directly (not via role) for lacking privileges (0 or 1)
	UserLacksdirectPs               UserPrivilege:=UserPrivilege(); --Privileges to be granted directly   the user lacks
	UserLacksindirectPs				  UserPrivilege:=UserPrivilege(); --Privileges to be granted indirectly the user lacks
	UserEmptyPs                     UserPrivilege:=UserPrivilege(); --Empty

	RoleChange							  number;                         --For keeping track on required role membership changes, so the 'alter user default role all' can be provided
	UserLacksOmpuserPs              UserPrivilege:=UserPrivilege(); --Lacking privilege which could be provided by OMPUSER role
	
	
	PrivilegeHasMaxLength           number;
	PrivilegeLacksMaxLength         number;

	AddGrants                       number;
	UserRole                        varchar2(30);

	dba_role_privs_error		        number;
	GrantingOMPUSER                 number; -- 1=Role OMPUSER granted, 0=role not granted
	OMPUSERExists                   number;
	OMPUSEROK                       number;
	OMDBAMaintenancePacksRequired	  number;
	UserHasOMPUSER                  number;
	DefaultTablespace               varchar2(2000);
	TemporaryTablespace             varchar2(2000);
	ExecText                        varchar2(2500);
	continue 				           number;
	AlternativeMYV$SessionSyn       number;
	AlternativeMYV$LockSyn          number;
	AlternativeMYV$LockedObjectSyn  number;
	TablesWithoutSegmentsCount      number;
	

	--Synonyms
	AlternativeMYV$viewnameSyn       number;
	viewname                         varchar2(30);
	PublicV$viewnameSynProp          varchar2(30); --GV viewname
	PublicV$SessionSynProp           varchar2(30); --GV Session
	PublicV$LockSynProp              varchar2(30); --GV Lock
	PublicV$Locked_objectSynProp     varchar2(30); --GV Locked_object
	PublicMYV$viewnameSynProp        varchar2(30); --MYV viewname
	PublicMYV$SessionSynProp         varchar2(30); --MYV Session
	PublicMYV$LockSynProp            varchar2(30); --MYV Lock
	PublicMYV$Locked_objectSynProp   varchar2(30); --MYV Locked_object
	SYSVViewNamePublicSyn            number;
	SYSVViewNamePrivSyn              number;
	SYSMYVViewNameView               number;
	PrivMYVViewNameView              number;
	SYSMYVViewNamePublicSyn          number;
	SYSMYVViewNamePrivSyn            number;
	PrivMYVViewNamePrivSyn           number;


	type Packages is                table of varchar2(30); --Packages the user has
	RqPackages                      Packages:=Packages('OM_TOOLS','OM_DBA','OM_CLEANUP');
	UserHasOMPackagespecs			  Packages:=Packages();
	UserHasOMPackagebodies			  Packages:=Packages();
	OMDBAHasOMPackagespecs			  Packages:=Packages();
	MissingPacks                    Packages:=Packages();
	PackageVersion					     varchar2(2000);

	type ErrorRec is                record (owner varchar2(30), name varchar2(30), line number, position number, text varchar2(4000));
	type Errors is                  table of ErrorRec;
	UserErrors                      Errors:=Errors();

	type ObjectRec is               record (owner varchar2(30), objectname varchar2(30), objecttype varchar2(19), status varchar2(7));
	type Objects is                 table of ObjectRec;
	UserInvalidObjects              Objects:=Objects();

	type TSUsageRecord is           record (Tablespace_Name varchar2(30), UsedMB number);
	type TSUsageRecords is table of TSUsageRecord;
	SchemaUsagePerTS                TSUsageRecords:=TSUsageRecords();
	EmptyTSUsage                    TSUsageRecords:=TSUsageRecords();
	SchemaUsageTotal                number;
	SchemaUsageTotalFormatLength    number;

	UserIsPackOwner                 number;
	UserHasJob					        number;
	JobUsesMPSchema                 varchar2(30);

	JobLastStartDdate               varchar2(100);
	JobLastRunDuration              varchar2(100);
	JobNextRunDdate                 varchar2(100);
	JobRepeatInterval               varchar2(100);
	JobState                        varchar2(100);
	JobTZName                       varchar2(100);

	UserSleepExists                 number;
	UserCount                       number;
	u                               number;
	UserWithoutPlanningLayer        varchar2(30);

	ExpiryDate                      date;
	PasswordLifeTime                varchar2(40);
	UserProfile                     varchar2(30);
	AccountStatus                   varchar2(32);
	AccountIsLocked                 number;
	
	cursor TSq is select 'OMPARTNERS' TSname from dual union select 'OMDBA' TSname from dual union select 'INDEXES' TSname from dual order by TSname desc;
	TSQuota                         number;

	Type SpecificTables is table of varchar2(30);
	LockedStatisticsTables          SpecificTables:=SpecificTables();
	TablesWithoutSegments           SpecificTables:=SpecificTables();
	s                               number;
	SchemaSizeM                     number;
	FormatMb                        varchar2(30):='99999990.9';
	UserCreated                     date;

	bodyerror 						     EXCEPTION;
	PRAGMA EXCEPTION_INIT(bodyerror, -4063);
	invalididentifier               EXCEPTION;
	PRAGMA EXCEPTION_INIT(invalididentifier, -904);

	procedure InsertPrivilege (Privilege_in IN varchar2, Usage IN varchar2, Directly IN number, UserIn IN varchar2, UserNotIn IN varchar2, PackOwner IN number) as
		rqPR PrivilegeRec;
	begin
		rqPR.Privilege:=Privilege_in;
		rqPR.Usage:=Usage;
		rqPR.Directly:=Directly;
		rqPR.UserIn:=UserIn;
		rqPR.UserNotIn:=UserNotIn;
		rqPR.PackOwner:=PackOwner;
		rqPRs.extend;
		rqPRs(rqPRs.count):=rqPR;
	end;

	function NumberToKMGtext (NumberIn in number) return varchar2 as
		NumberUNIT                         varchar2(1);
		NumberText                         varchar2(2000);
		Units                              varchar2(10):='KMG';
	begin
		if NumberIn<>0 then
			NumberUNIT:=' ';
			NumberText:=NumberIn;
			for i in 1..length(Units) loop
				if numbertext mod 1024 = 0 then
					numberunit:=substr(Units,i,1);
					numbertext:=numbertext/1024;
				end if;
			end loop;
			return numbertext||trim(numberunit);
		else
			return '0';
		end if;
	end;


begin
	--            Target, Privilege                          Usage                                                              Directly    UserIn          UserNotIn    PackOwner
	--            ------  ----------------------------       -----------------------------------------------------------------  --------    -----------     ----------   ---------
	InsertPrivilege('OMPUSER'                                ,  'required to avoid having to give grants to individual users'      ,     '' ,  ''             , ''             , ''          );
	InsertPrivilege('CREATE SESSION'                         ,  'required for normal use and configuration'                        ,     '' ,  ''             , ''             , ''          );
	InsertPrivilege('ALTER SESSION'                          ,  'required for normal use and configuration'                        ,     '' ,  ''             , ''             , ''          );
	InsertPrivilege('SELECT ON SYS.'||:xV_$SESSION||''       ,  'required for normal use and configuration'                        ,     '' ,  ''             , ''             , 0           ); --PackOwners get their own requirement (direct grant)
	InsertPrivilege('SELECT ON SYS.'||:xV_$LOCK||''          ,  'required for configuration only'                                  ,     '' ,  ''             , ''             , 0           ); --PackOwners get their own requirement (direct grant)
	InsertPrivilege('SELECT ON SYS.'||:xV_$SESSION||''       ,  'required for normal use, configuration, and maintenance packages' ,      1 ,  ''             , ''             , 1           );
	InsertPrivilege('SELECT ON SYS.'||:xV_$LOCK||''          ,  'required for normal use, configuration, and maintenance packages' ,      1 ,  ''             , ''             , 1           );
	InsertPrivilege('SELECT ON SYS.GV_$PARAMETER'            ,  'recommended for using maintenance packages'                       ,      1 ,  ''             , ''             , 1           );
	InsertPrivilege('SELECT ON SYS.'||:xV_$LOCKED_OBJECT||'' ,  'required for using maintenance packages'                          ,      1 ,  ''             , ''             , 1           );
	if :NLSRDBMSVERSION00 >= '12.01' then
		InsertPrivilege('SELECT ON SYS.DBA_REGISTRY_SQLPATCH' ,  'required for normal use and configuration'                        ,      1 ,  ''             , ''             , 1           );
	else
		InsertPrivilege('SELECT ON SYS.DBA_REGISTRY_HISTORY'  ,  'required for normal use and configuration'                        ,      1 ,  ''             , ''             , 1           );
	end if;
	if not (:SkipDBLink=1) then
		InsertPrivilege('CREATE DATABASE LINK'                ,  'required for configuration only'                                  ,     '' ,  ''             , ''             , ''          );
	end if;
	InsertPrivilege('CREATE JOB'                             ,  'required for configuration only'                                  ,     '' ,  ''             , ''             , ''          );
	InsertPrivilege('CREATE PROCEDURE'                       ,  'required for configuration only'                                  ,     '' ,  ''             , ''             , ''          );
	InsertPrivilege('CREATE SEQUENCE'                        ,  'required for configuration only'                                  ,     '' ,  ''             , ''             , ''          );
	InsertPrivilege('CREATE SYNONYM'                         ,  'required for configuration only'                                  ,     '' ,  ''             , ''             , ''          );
	InsertPrivilege('CREATE TABLE'                           ,  'required for configuration only'                                  ,     '' ,  ''             , ''             , ''          );
	InsertPrivilege('CREATE TRIGGER'                         ,  'required for configuration only'                                  ,     '' ,  ''             , ''             , ''          );
	InsertPrivilege('CREATE VIEW'                            ,  'required for configuration only'                                  ,     '' ,  ''             , ''             , ''          );
	InsertPrivilege('EXECUTE ON SYS.DBMS_SQL'                ,  'required for normal use and daily maintenance'                    ,     '' ,  ''             , ''             , ''          );
	InsertPrivilege('EXECUTE ON SYS.DBMS_FLASHBACK'          ,  'required for normal use of simulation management'                 ,     '' ,  ''             , ''             , ''          );
	if not (:SkipSharedSleep=1) then
		InsertPrivilege('EXECUTE ON SYS.SLEEP'                ,  'required for using maintenance packages'                          ,      1 ,  ''             , ''             , 1           );
	else
		InsertPrivilege('EXECUTE ON SYS.DBMS_LOCK'            ,  'required for using maintenance packages'                          ,     '' ,  ''             , ''             , 1           );
	end if;
	InsertPrivilege('EXECUTE ON OMDBA.OM_DBA'                ,  'required for normal use and daily maintenance'                    ,     '' ,  ''             , ''             , 0           );
	InsertPrivilege('EXECUTE ON OMDBA.OM_CLEANUP'            ,  'required for normal use and daily maintenance'                    ,     '' ,  ''             , ''             , 0           );
	InsertPrivilege('EXECUTE ON OMDBA.OM_TOOLS'              ,  'required for normal use and daily maintenance'                    ,     '' ,  ''             , ''             , 0           );
	--Additional privileges for using shared OMBA           required
	InsertPrivilege('SELECT ANY TABLE'                       ,  'required for using OMDBA shared packages'                         ,      1 ,  '''OMDBA'''    , ''             , ''          );
	InsertPrivilege('INSERT ANY TABLE'                       ,  'required for using OMDBA shared packages'                         ,      1 ,  '''OMDBA'''    , ''             , ''          );
	InsertPrivilege('DELETE ANY TABLE'                       ,  'required for using OMDBA shared packages'                         ,      1 ,  '''OMDBA'''    , ''             , ''          );
	InsertPrivilege('UPDATE ANY TABLE'                       ,  'required for using OMDBA shared packages'                         ,      1 ,  '''OMDBA'''    , ''             , ''          );
	InsertPrivilege('LOCK ANY TABLE'                         ,  'required for using OMDBA shared packages'                         ,      1 ,  '''OMDBA'''    , ''             , ''          );
	InsertPrivilege('SELECT ANY SEQUENCE'                    ,  'required for using OMDBA shared packages'                         ,      1 ,  '''OMDBA'''    , ''             , ''          );
	InsertPrivilege('ALTER ANY INDEX'                        ,  'required for using OMDBA shared packages'                         ,      1 ,  '''OMDBA'''    , ''             , ''          );
	--Additional privileges when using MYV$ views instead of V_$ views
	--These privileges should only be checked for non-DBArequired  packge owners, and these will only serve as alternative for OMDBA's shared packages, see user configuration further.
	InsertPrivilege('SELECT ON SYS.MYV$SESSION'              ,  'required for normal use and configuration'                        ,     '' , ''              , ''             , 0           );--Synonym V$SESSION in user schema (for view SYS.MYV$SESSION) is dealt with further
	InsertPrivilege('SELECT ON SYS.MYV$LOCK'                 ,  'required for normal use and configuration'                        ,     '' , ''              , ''             , 0           );
	InsertPrivilege('SELECT ON SYS.MYV$LOCKED_OBJECT'        ,  'required for normal use and configuration'                        ,     '' , ''              , ''             , 0           );
	InsertPrivilege('SELECT ON SYS.MYV$SESSION'              ,  'required for normal use and configuration'                        ,      1 , ''              , ''             , 1           );--Synonym V$SESSION in user schema (for view SYS.MYV$SESSION) is dealt with further
	InsertPrivilege('SELECT ON SYS.MYV$LOCK'                 ,  'required for normal use and configuration'                        ,      1 , ''              , ''             , 1           );
	InsertPrivilege('SELECT ON SYS.MYV$LOCKED_OBJECT'        ,  'required for normal use and configuration'                        ,      1 , ''              , ''             , 1           );
	if not (:SkipOMDBADINDBTests=1) then
		InsertPrivilege('DBA'                                 , 'required for OMP Data Inspector database level tests'              ,     '' , '''OMDBA'''     , ''             , ''          );
	end if;
	InsertPrivilege('SELECT ANY TABLE'                       ,  'required for OMP Data Inspector database level tests and ASH'     ,      1 , ''''||:OMDINUser||'''', ''             , 0            );
	InsertPrivilege('SELECT ANY DICTIONARY'                  ,  'required for OMP Data Inspector database level tests and ASH'     ,      1 , ''''||:OMDINUser||'''', ''             , 0            );
	if :DirectoryOMPDPExists=1 then --else the grant is given above at creation
		InsertPrivilege('READ ON DIRECTORY OMPDP'             ,  'required for exports with datapump'                               ,     '' , ''             , ''             , ''           );
		InsertPrivilege('WRITE ON DIRECTORY OMPDP'            ,  'required for exports with datapump'                               ,     '' , ''             , ''             , ''           );
	end if;
	if not :SkipSharedPackages=1 then
		InsertPrivilege('SELECT ON SYS.DBA_TAB_PRIVS'         ,  'required for using maintenance packages'                          ,      1 , ''             , ''             , 1            );
	end if;

	dba_role_privs_error:=0;

	--create the Userlist if needed (if =ALL) and add role OMPUSER
	----When investigating the users we will decide if OMDBA maintenance packages are required; now say no.
	OMDBAMaintenancePacksRequired:=0;
	case :Userlist
		when 'ALL' then
			--find and fill all users
			select count(*) into OracleMaintainedExists from all_tab_columns where column_name='ORACLE_MAINTAINED' and owner='SYS' and table_name='ALL_USERS';
			if OracleMaintainedExists>0 then
				execute immediate 'select username FROM all_users where Oracle_Maintained=''N'' and username not in (''OMDBA'') order by username' bulk collect into myUsers;
			else
				execute immediate 'select username FROM all_users where username not in (''OMDBA'',''SYS'',''SYSTEM'',''TSMSYS'',''APPQOSSYS'',''CTXSYS'',''DBSNMP'',''DMSYS'',''DIP'',''EXFSYS'',''MDSYS'',''OLAPSYS'',''ORACLE_OCM'',''ORDPLUGINS'',''ORDSYS'',''OUTLN'',''SYSMAN'',''WKSYS'',''WK_TEST'',''WMSYS'',''XDB'',''ANONYMOUS'',''AUDSYS'',''GSMADMIN_INTERNAL'',''GSMCATUSER'',''GSMUSER'',''SYSBACKUP'',''SYSDG'',''SYSKM'',''XS$NULL'') order by username' bulk collect into myUsers;
			end if;
			
			if myUsers.count=0 and not :SkipSharedPackages=1 then
				--ALL users had to be checked, but no users found, so they still have to be created; this requires the packages to be in OMDBA, because by default the users will be created without packages
				--However (only) when SkipSharedPackages is forced (=1) then we should not do this.
				OMDBAMaintenancePacksRequired:=1;
			end if;

			--Role OMPUSER can follow the same logic
			--add OMPUSER as first item and OMDBA as last item
			myUsers.extend;
			--shift to make room for OMPUSER before other users
			for i in reverse 1..MyUsers.count-1 loop
				MyUsers(i+1):=MyUsers(i);
			end loop;
			--add OMPUSER as first item
			MyUsers(1):='OMPUSER';
		when 'NONE' then
			myUsers.extend; MyUsers(MyUsers.Count):='OMPUSER';
	  		--No other users will be checked, so we go for the default which means that OMDBA will be required.
	  		--However (only) when SkipSharedPackages is forced (=1) then we should not do this.
			if not :SkipSharedPackages=1 then
				OMDBAMaintenancePacksRequired:=1;
			end if;
		else
			--Users were specified
			--Add User OMDBA if not forced to work without
			--Role OMPUSER can follow the same logic
			myUsers.extend; MyUsers(MyUsers.Count):='OMPUSER';
			--(Convert comma-separated UserList into Users-table rqUsers; from stackoverflow answer 3 (Oracle 9 compliant) from Rob, see http://stackoverflow.com/questions/1089508/how-to-best-split-csv-strings-in-oracle-9i)
			for r in ( select substr ( str , instr(str,',',1,level) + 1 , instr(str,',',1,level+1) - instr(str,',',1,level) - 1 ) element from (select ',' || :UserList || ',' str from dual) connect by level <= length(str) - length(replace(str,',')) - 1 ) loop
				UserWithoutPlanningLayer:=regexp_replace(regexp_replace(regexp_replace(regexp_replace(substr(r.element,1,greatest(length(r.element),length(r.element)-4)),'_FCT$',''),'_SOP$',''),'_OPR$',''),'_UTL$','');
				if case when :OMPApplicationVersion<>'06_10' then to_number(substr(:OMPApplicationVersion,1,2)) else /*consider 06_10 (not built!) as +6 */ 99 end>=6 and r.element=UserWithoutPlanningLayer and :SkipAddingPlanningLayerSuffix=0 then
					MyUsers.Extend;
					MyUsers(MyUsers.Count):=r.element||'_FCT';
					MyUsers.Extend;
					MyUsers(MyUsers.Count):=r.element||'_SOP';
					MyUsers.Extend;
					MyUsers(MyUsers.Count):=r.element||'_OPR';
					MyUsers.Extend;
					MyUsers(MyUsers.Count):=r.element||'_UTL';
				else
					MyUsers.Extend;
					MyUsers(MyUsers.Count):=r.element;
				end if;
			end loop;
	end case;
	--Add OMDBA user, unless explicitly requested not to do so
	if not :SkipOMDBA=1 then
		--Normal situation
		--add OMDBA as last item
		myUsers.extend;
		MyUsers(myUsers.count):='OMDBA';
	end if;
	--Add OMDIN user, unless explicitly requested not to do so
	if not :SkipOMDIN=1 then
		--Normal situation
		--add OMDIN as last item
		myUsers.extend;
		MyUsers(myUsers.count):=:OMDINUser;
	end if;

	dbms_output.put_line('--   Users/roles which will be checked:');
	for u in 1..MyUsers.count loop
		myUser:=MyUsers(u);
		dbms_output.put_line('--      '||myUser);
	end loop;
	dbms_output.put_line(:Line);

	--Keep FullUserList in global variable for use in other blocks
	for u in 1..MyUsers.count loop
		:FullUserList:=:FullUserList||','||upper(MyUsers(u));
	end loop;
	--Trim leading comma
	:FullUserList:=ltrim(:FullUserList,',');

	--When a user lacks grants to omdba.packages because these packages do not exist at all in omdba,
	--then we should shut up about these missing privileges. Errors will be given about the missing
	--omdba packages (if needed), and grants are included in package installs.
	--pretest
	if :DbaSource=0 then
		dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_SOURCE''. Run the ConfigCheck script ''AS SYSDBA''.');
		:ErrorCount:=:ErrorCount+1;
	else
		execute immediate 'select object_name from SYS.DBA_objects where object_name in (''OM_DBA'',''OM_TOOLS'',''OM_CLEANUP'') and object_type=''PACKAGE''      and owner=''OMDBA'' ' bulk collect into  OMDBAHasOMPackagespecs;      --'
	end if;

	--FOR every user
	for u in 1..MyUsers.count loop
		myUser:=upper(MyUsers(u));
		--Hide OMDBA when not not needed:
		--OMDBA is last user in userlist; when all other users are configured correctly (with maintenance packages and required grants), we should not report on OMDBA
		if myUser<>'OMDBA' or OMDBAMaintenancePacksRequired=1 then --else it's OMDBA _and_ OMDBA is not required

			if myUser='OMPUSER' then
				UserRole:='Role';
			else
				UserRole:='User';
			end if;

			dbms_output.put_line('--   Requirement: '||UserRole||' '||myUser||' must exist with required privileges.');

			--EXISTENCE
			if myUser='OMPUSER' then
				--pretest
				if :DbaRolePrivs=0 then
					dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_ROLE_PRIVS''. Run the ConfigCheck script ''AS SYSDBA''.');
					:ErrorCount:=:ErrorCount+1;
					--keep track of this error to avoid mentioning this error once more further on
					dba_role_privs_error:=1;
				else
					execute immediate 'select count(9) from SYS.DBA_roles where role=''OMPUSER''' into UserExists;
					OMPUSERExists:=UserExists;
					if UserExists=0 then
						dbms_output.put_line('--(!)Result: Warning: Role OMPUSER facilitates privilege management but does not exist.');
						:warningcount:=:warningcount+1;
						dbms_output.put_line('--   Solution: Create role OMPUSER and give privileges by executing the following statements:');
						dbms_output.put_line('create role OMPUSER not identified;');
					end if;
				end if;
			else --A user (not a role)
				--(pretest not needed for all_users)
				execute immediate 'select count(9) from all_users where username='''||myUser||'''' into UserExists;
				if UserExists=0 then
					dbms_output.put_line('--!  Result: Error: User '||myUser|| ' does not exist.');
					:ErrorCount:=:ErrorCount+1;
					dbms_output.put_line('--   Solution: create user and give privileges by executing the following statements:');
					dbms_output.put_line('create user '||MyUser||' identified by '||lower(MyUser)||' default TABLESPACE ' || case when myUSER='OMDBA' or myUSER=:OMDINUser then 'OMDBA' else 'OMPARTNERS' end || ' temporary tablespace TEMP ' || case when myUSER='OMDBA' or myUSER=:OMDINUser then 'quota unlimited on OMDBA ' else '' end || 'quota unlimited on OMPARTNERS quota unlimited on INDEXES;');
					--User has to be set up completely, recommended setup also requires OMDBA:
					OMDBAMaintenancePacksRequired:=1;
				else
					execute immediate 'select created from all_users where username='''||myUser||'''' into UserCreated;
					if :info=1 then dbms_output.put_line('--   Info: User '||myUser||' was created on '||UserCreated||'.'); end if;
				end if;
			end if;

			--Report actual size, useful when using ConfigCheck on existing environments
			if myUser<>'OMPUSER' and UserExists=1 then
				SchemaUsagePerTS:=EmptyTSUsage;--initialize per user
				SchemaUsageTotal:=0;
				if :info>=1 then
					if :DbaSegments=1 or myUser=USER then --we can report on the amount of segments used
						--Collect usage
						if myUser=USER	 then --no DBA needed to find your own segments
							execute immediate 'select tablespace_name, sum(bytes)/1024/1024 mb from user_segments group by tablespace_name order by tablespace_name' bulk collect into SchemaUsagePerTS;
						else
							execute immediate 'select tablespace_name, sum(bytes)/1024/1024 mb from dba_segments where owner='''||myUser||''' group by tablespace_name order by tablespace_name' bulk collect into SchemaUsagePerTS;
						end if;
						--Calculate total usage
						FOR t in 1 .. SchemaUsagePerTS.count LOOP
							SchemaUsageTotal:=SchemaUsageTotal+SchemaUsagePerTS(t).UsedMb;
						END LOOP;
						SchemaUsageTotalFormatLength:=length(trim(to_char(SchemaUsageTotal,FormatMb)));--for formatting below
						--Report usage
						dbms_output.put_line('--   Info: User '||myUser||' actually uses '||trim(to_char(SchemaUsageTotal,FormatMb))||' Mb' ||case when SchemaUsageTotal=0.0 then '.' else ':' end);
						FOR t in 1 .. SchemaUsagePerTS.count LOOP
							dbms_output.put_line('--      '||myUser||' uses '||lpad(trim(to_char(SchemaUsagePerTS(t).UsedMb,FormatMb)),SchemaUsageTotalFormatLength)||' Mb of tablespace '||SchemaUsagePerTS(t).tablespace_name||case when t<SchemaUsagePerTS.count then ',' else '.' end);
						END LOOP;
					else
						dbms_output.put_line('--!  Result: Error: You do not have access to ''DBA_SEGMENTS''. Run the ConfigCheck script ''AS SYSDBA''.');
						:errorcount:=:errorcount+1;
					end if;
				end if;
			end if;

			--PACKAGES (part 1/2)
			--Recommended default setup is to have maintenance packages in shared OMDBA user
			UserHasOMPackagespecs.delete;
			UserHasOMPackagebodies.delete;
			if myUser=USER	 then --no DBA needed to find your own privileges
				execute immediate 'select object_name from user_objects where object_name in (''OM_DBA'',''OM_TOOLS'',''OM_CLEANUP'') and object_type=''PACKAGE''     ' bulk collect into  UserHasOMPackagespecs;      --'
				execute immediate 'select object_name from user_objects where object_name in (''OM_DBA'',''OM_TOOLS'',''OM_CLEANUP'') and object_type=''PACKAGE BODY''' bulk collect into  UserHasOMPackagebodies; --'
			else
				--pretest
				if :DbaSource=0 then
					dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_SOURCE''. Run the ConfigCheck script ''AS SYSDBA''.');
					:ErrorCount:=:ErrorCount+1;
				else
					execute immediate 'select object_name from SYS.DBA_objects where object_name in (''OM_DBA'',''OM_TOOLS'',''OM_CLEANUP'') and object_type=''PACKAGE''      and owner='''||myUser||''' ' bulk collect into  UserHasOMPackagespecs;      --'
					execute immediate 'select object_name from SYS.DBA_objects where object_name in (''OM_DBA'',''OM_TOOLS'',''OM_CLEANUP'') and object_type=''PACKAGE BODY'' and owner='''||myUser||''' ' bulk collect into  UserHasOMPackagebodies; --'
				end if;
			end if;


			--PACKAGE OWNERSHIP
			--If the user is OMDBA, or as soon as the user has one of the maintenance packag specs installed, or if PrivatePackages are forced, myUser will be considered to be a package owner and needs to be checked further
			if (
					myUser in ('OMDBA')
					or UserHasOMPackagespecs.count>0
					or :SkipSharedPackages=1
				 ) and
				 myUser not in ('OMPUSER') then
					UserIsPackOwner:=1;
					if :info>=1 and UserExists=1 then
						dbms_output.put_line('--   Info: The user ' ||myUser||' is considered to be package owner because:');
						if :SkipSharedPackages=1         then dbms_output.put_line('--      Script parameter SkipSharedPackages=true'); end if;
	  			      if myUser in ('OMDBA')           then dbms_output.put_line('--      This is user OMDBA, which should always be package owner'); end if;
						if UserHasOMPackagespecs.count>0 then dbms_output.put_line('--      '||myUser||' has already '||UserHasOMPackagespecs.count||' OM package specifications installed'); end if;
					end if;
			else
				UserIsPackOwner:=0;
			end if;

			--As soon as we encounter any user (not OMPUSER) is not PackOwner, OMDBA will be required
			--Remark that situation with SkipSharedPackages=1 already implies that UserIsPackOwner:=1, so we do not have to duplicate that logic here
			if UserIsPackOwner=0 and myUser<>'OMPUSER' then
				OMDBAMaintenancePacksRequired:=1;
			end if;

			--GRANTS
			--Initialize for every new user
			AddGrants:=0;
			UsageType:=' ';
			UserHasPs:=UserEmptyPs;
			UserHasPsDirect:=UserEmptyPs;
			UserRqPs:=UserEmptyPs;
			UserLacksPs:=UserEmptyPs;
			UserLacksPsDirectYN.delete;
			UserLacksdirectPs:=UserEmptyPs;
			UserLacksindirectPs:=UserEmptyPs;
			UserLacksPsReason:=UserEmptyPs;
			PrivilegeHasMaxLength:=0;
			PrivilegeLacksMaxLength:=0;
			RoleChange:=0;
			UserLacksOmpuserPs:=UserEmptyPs;
			
			AlternativeMYV$SessionSyn:=0;
			AlternativeMYV$LockSyn:=0;
			AlternativeMYV$LockedObjectSyn:=0;

			--Search for existing privs
			if :DbaRolePrivs=0 and :DbaSysPrivs=0 and myUser=USER	 then --no DBA available, but USER can find its own privileges
				--                                                                              < roles                                                    >       <sys privs through roles                         >       <direct sys privs                                        >       <all tab privs                                                                         >
				execute immediate 'select privilege RoleOrPrivilege, grantee, 0, grantee from ( select distinct user grantee, role privilege from role_sys_privs union select role grantee, privilege from role_sys_privs union select username grantee, privilege from user_sys_privs union select grantee, privilege||'' ON ''||table_schema||''.''||table_name from all_tab_privs) order by privilege' bulk collect into UserHasPsPath;
				-- levels not shown here, cfr. DBA
			else
				--pretest DBA
				if :DbaRolePrivs=0 or :DbaSysPrivs=0 then
					if :DbaRolePrivs=0 and dba_role_privs_error=0 then dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_ROLE_PRIVS''. Run the ConfigCheck script ''AS SYSDBA''.'); :ErrorCount:=:ErrorCount+1; end if;
					if :DbaSysPrivs=0  then dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_SYS_PRIVS''. Run the ConfigCheck script ''AS SYSDBA''.'); :ErrorCount:=:ErrorCount+1; end if;
				else
					exectext:='select  granted_role RoleOrPrivilege, grantee, level, rtrim(reverse(SYS_CONNECT_BY_PATH (reverse(grantee), ''>'')),''>'') ROLES from '               ||
									  '( select grantee, granted_role                  from SYS.DBA_role_privs '          ||
									  'union '                                                                        ||
									  'select grantee, privilege                       from SYS.DBA_sys_privs '           ||
									  'union '                                                                        ||
									  'select grantee, privilege||'' ON ''||owner||''.''||table_name from SYS.DBA_tab_privs) '          ||
									  'start with grantee=:1'                                                        ||
									  'connect by grantee =  prior granted_role order by granted_role, level';
					--dbms_output.put_line(exectext);
					execute immediate exectext bulk collect into UserHasPsPath    using myUser;
					execute immediate exectext bulk collect into PublicHasPsPath  using 'PUBLIC';
					
					--update syntax for directories
					for i in 1..UserHasPsPath.count loop
					   case UserHasPsPath(i).RoleOrPrivilege
							when 'READ ON SYS.OMPDP' then
								UserHasPsPath(i).RoleOrPrivilege:='READ ON DIRECTORY OMPDP';
							when 'WRITE ON SYS.OMPDP' then
								UserHasPsPath(i).RoleOrPrivilege:='WRITE ON DIRECTORY OMPDP';
							else
								null;
						end case;
					end loop;
					for i in 1..PublicHasPsPath.count loop
					   case PublicHasPsPath(i).RoleOrPrivilege
							when 'READ ON SYS.OMPDP' then
								PublicHasPsPath(i).RoleOrPrivilege:='READ ON DIRECTORY OMPDP';
							when 'WRITE ON SYS.OMPDP' then
								PublicHasPsPath(i).RoleOrPrivilege:='WRITE ON DIRECTORY OMPDP';
							else
								null;
						end case;
					end loop;
					
					--View PUBLIC privileges together with User's privileges :
					UserHasPsPath:=UserHasPsPath multiset union all PublicHasPsPath;
				end if;
			end if;

			--Collect existing and missing privileges BY CATEGORY
			if (not (:DbaRolePrivs=0 or :DbaSysPrivs=0)) or myUser=USER then --we are dba or myUser=ourselves so continuation is meaningful because data about myUser will be available

				--Copy UserHasPsPath.Privilege to UserHasPs for easier searches (member)
				for i in 1..UserHasPsPath.count loop
					UserHasPs.Extend;
					UserHasPs(UserHasPs.count):=UserHasPsPath(i).RoleOrPrivilege;
					--if granted directly to user, keep this info in separate collection.
					if UserHasPsPath(i).path in (myUser,'PUBLIC') then
						UserHasPsDirect.Extend;
						UserHasPsDirect(UserHasPsDirect.count):=UserHasPsPath(i).RoleOrPrivilege;
					end if;
				end loop;

				for i in rqPRs.First .. rqPRs.Last loop
					--Is the required privilege relevant for this user
					--This requires it is listed in UserIn (or UserIn is null), AND  not listed in UserNotIn (or UserNotIn is null)
					if nvl(instr(rqPRs(i).UserIn,''''||myUser||''''),1)>0       AND  nvl(instr(rqPRs(i).UserNotIn,''''||myUser||''''),0)=0  and  nvl(rqPRs(i).PackOwner,UserIsPackOwner)=UserIsPackOwner then
						--dbms_output.put_line('Privilege '||rpad(rqPRs(i).privilege,35) ||' is relevant, ' || case when rqPRs(i).directly=1 then '   ' else 'NOT' end || ' to be granted directly. (Directly='''||rqPRs(i).directly||''', UserIn='''||rqPRs(i).UserIn||''', UserNotIn='''||rqPRs(i).UserNotIn||''', PackOwner='''||rqPRs(i).Packowner||'''.');
						UserRqPs.extend;
						UserRqPs(UserRqPs.count):=rqPRs(i).privilege;
						case rqPRs(i).privilege
							when 'OMPUSER' then --do not throw missing OMPUSER role together with other privileges
								if 'OMPUSER' member of UserHasPs then
									UserHasOMPUSER:=1;
								else
									UserHasOMPUSER:=0;
								end if;
						else
							--dbms_output.put_line('relevant privilege '||rqPRs(i).privilege);
							--Add missing privileges.
							--If privilege must be granted directly (for plsql usage, e.g. omdba packages)
							if  (not (rqPRs(i).privilege member of UserHasPs)) --a privilege is missing
								or
								(not (rqPRs(i).privilege member of UserHasPsDirect) and rqPRs(i).Directly=1) then --a privilege which has to be granted directly is not granted directly

								--Now handle situations where missing privilege can be tolerated:
								--   'Select on MYV$SESSION' is equivalent to 'Select on GV_$SESSION', so if one of both is ok, the other is not missing. (synonyms will be checked later)
								--   'A fully configured OMDBA user is equivalent to the MYV$LOCK,MYV$LOCKED_OBJECT requirement, so if one of both is ok, the other is not missing.
								--Reporting will be done later together with all (lacking privileges) reporting
								--dbms_output.put_line('lacking '||rqPRs(i).privilege);
								continue:=1;
								case rqPrs(i).Privilege
									when 'EXECUTE ON OMDBA.OM_DBA' then
										if 'EXECUTE ON '||myUser||'.OM_DBA' member of UserHasPs and 'OM_DBA' member of UserHasOMPackagebodies then
											continue:=0; --local package is alternative
										else
											if not 'OM_DBA' member of OMDBAHasOMPackageSpecs then
												continue:=0; --shut up about missing omdba.packages, if omdba does not yet have these packages. Grants will be included in package installation.
											end if;
										end if;
									when 'EXECUTE ON OMDBA.OM_CLEANUP' then
										if 'EXECUTE ON '||myUser||'.OM_CLEANUP' member of UserHasPs and 'OM_CLEANUP' member of UserHasOMPackagebodies then
											continue:=0; --local package is alternative
										else
											if not 'OM__OM_CLEANUP' member of OMDBAHasOMPackageSpecs then
												continue:=0; --shut up about missing omdba.packages, if omdba does not yet have these packages. Grants will be included in package installation.
											end if;
										end if;
									when 'EXECUTE ON OMDBA.OM_TOOLS' then
										if 'EXECUTE ON '||myUser||'.OM_TOOLS' member of UserHasPs and 'OM_TOOLS' member of UserHasOMPackagebodies then
											continue:=0; --local package is alternative
										else
											if not 'OM_TOOLS' member of OMDBAHasOMPackageSpecs then
												continue:=0; --shut up about missing omdba.packages, if omdba does not yet have these packages. Grants will be included in package installation.
											end if;
										end if;
									when 'SELECT ON SYS.'||:xV_$SESSION||'' then
										--Maybe MYV is alternative
										--remark that if MYV$ view does not exist, or the view exists but the synonym does not (=MYVSession[Public]Syn=0), an error will be given stating that select on sys.gv_$session is still lacking, because this is the prior recommended solution.***
										if :SkipV$Views=1 --Don't worry about the missing 'SELECT ON SYS.V_$', do not even report it as missing.
															  --The check whether MYV is missing or not will come automatically because both the V$ and MYV$ privileges are listed in RqPrs.
											or (rqPrs(i).Directly=1 and 'SELECT ON SYS.MYV$SESSION'       member of UserHasPsDirect)
											or (rqPrs(i).Directly=0 and 'SELECT ON SYS.MYV$SESSION'       member of UserHasPs) then
											continue:=0; --MYV$ is a view with select privileges so this is an alternative for V_$
											AlternativeMYV$SessionSyn:=1; --Keep track of this alternative to use further when investigating synonyms
										end if;
										--***Add warning when OMDBA has to use MYV and packages are shared ==> T1 will not be able to obtain sessioninfo
									when 'SELECT ON SYS.V_$LOCK' then
										if :SkipV$Views=1 --Don't worry about the missing 'SELECT ON SYS.V_$', do not even report it as missing.
															  --The check whether MYV is missing or not will come automatically because both the V$ and MYV$ privileges are listed in RqPrs.
											or (rqPrs(i).Directly=1 and 'SELECT ON SYS.MYV$LOCK'          member of UserHasPsDirect)
											or (rqPrs(i).Directly=0 and 'SELECT ON SYS.MYV$LOCK'          member of UserHasPs) then
											continue:=0; --MYV$ is a view with select privileges so this is an alternative for V_$
											AlternativeMYV$LockSyn:=1; --Keep track of this alternative to use further when investigating synonyms
										end if;
									when 'SELECT ON SYS.V_$LOCKED_OBJECT' then
										if :SkipV$Views=1 --Don't worry about the missing 'SELECT ON SYS.V_$', do not even report it as missing.
															  --The check whether MYV is missing or not will come automatically because both the V$ and MYV$ privileges are listed in RqPrs.
											or (rqPrs(i).Directly=1 and 'SELECT ON SYS.MYV$LOCKED_OBJECT' member of UserHasPsDirect)
											or (rqPrs(i).Directly=0 and 'SELECT ON SYS.MYV$LOCKED_OBJECT' member of UserHasPs) then
											continue:=0; --MYV$ is a view with select privileges so this is an alternative for V_$
											AlternativeMYV$LockedObjectSyn:=1; --Keep track of this alternative to use further when investigating synonyms
										end if;
									--Never consider MYV$SESSION, MYV$LOCK, or MYV$LOCKED object as lacking, because using the V_$ views are recommended (rather than the MYV$ views)....
									--....except when parameter SkipV$Views=TRUE was specified
									when 'SELECT ON SYS.MYV$SESSION' then
										if :SkipV$Views=0 then
											continue:=0;
										end if;
									when 'SELECT ON SYS.MYV$LOCK' then
										if :SkipV$Views=0 then
											continue:=0;
										end if;
									when 'SELECT ON SYS.MYV$LOCKED_OBJECT' then
										if :SkipV$Views=0 then
											continue:=0;
										end if;
									else
										null;
								end case;
								--if it is still really missing:
								if continue=1 then
									--dbms_output.put_line('Still lacking '||rqPRs(i).privilege);
									--The lacking privilege
									UserLacksPs.Extend;
									UserLacksPs(UserLacksPs.count):=rqPRs(i).privilege;
									--Also keep track of the reason
									UserLacksPsReason.Extend;
									UserLacksPsReason(UserLacksPsReason.count):=rqPRs(i).Usage;
									--Also keep track whether it should be granted directly (otherwise via role is good enough)
									UserLacksPsDirectYN.Extend; --ToN, 0 or 1
									UserLacksPsDirectYN(UserLacksPsReason.count):=rqPRs(i).Directly;
									--If it has to granted directly, then also put it in list containing only the lacking privileges to be granted directly
									if rqPRs(i).Directly=1 then
										UserLacksdirectPs.Extend;
										UserLacksdirectPs(UserLacksdirectPs.count):=rqPRs(i).privilege;
									else
										UserLacksindirectPs.Extend;
										UserLacksindirectPs(UserLacksindirectPs.count):=rqPRs(i).privilege;
										if rqPRs(i).UserIn is null and rqPRs(i).UserNotIn is null then --Privilege which is not Directly and for all users can be put in OMPUSER
											UserLacksOmpuserPs.Extend;
											UserLacksOmpuserPs(UserLacksOmpuserPs.count):=rqPRs(i).privilege;
										end if;
									end if;
									--if the missing privilege was needed for PackOwners, we will need OMDBA to have valid maintenance packages.
									if rqPRs(i).PackOwner=1 then
										OMDBAMaintenancePacksRequired:=1;
									end if;
								end if;
							end if;
						end case;
					end if;
				end loop;
				--Lacking privileges to be granted directly = all lacking  -  lacking to be granted directly

				--Keep track of length to RPAD later
				for i in 1 .. UserHasPs.count loop
					if userhasps(i) member of UserRqPs then --only consider length when privilege is relevant
						if PrivilegeHasMaxLength<length(UserHasPs(i)) then PrivilegeHasMaxLength:=length(UserHasPs(i)); end if;
					end if;
				end loop;
				--Now do the same for lacking privileges (relevant by definition, otherwise it was not lacking)
				for i in 1 .. UserLacksPs.count loop
					if PrivilegeLacksMaxLength<length(UserLacksPs(i)) then PrivilegeLacksMaxLength:=length(UserLacksPs(i)); end if;
				end loop;
				--Display details: HAS privileges
				if UserExists=1 then
					for i in 1 .. UserHasPs.count loop
						if userhasps(i) member of UserRqPs then
							--List of all priviliges which might be relevant now or later.
							--Please note that also privileges which might not be immediately relevant to this user will be listed; this helps in understanding and troubleshooting setup.
							if :info>=1 then dbms_output.put_line('--   Info: '||UserRole||' '||myUser||' has   '||rpad(userhaspsPath(i).RoleOrPrivilege,PrivilegeHasMaxLength) || '  granted to ' || userhaspsPath(i).Path ||'.'); end if;
						end if;
					end loop;
				else
					--It is useless to list PUBLIC privileges for a user/role which does not yet exist
					null;
				end if;

				--Keep track of OMPUSER result to use it when handling users
				if myUSER='OMPUSER'	then
					OMPUSEROK:=0;
					if UserLacksPs.count=0 then
						OMPUSEROK:=1;
					end if;
				end if;

				--REPORT LACKING + SOLUTIONS
				if UserLacksPs.count=0 then
					dbms_output.put_line('--   Result: OK: '||UserRole||' '||myUser||' exists and has the required privileges.');
					--User is ok but if it did not yet get OMPUSER, we'll suggest to use it:
					if :info>=1 then
						if UserHasOMPUSER=0 and myUSER not in ('OMPUSER','OMDBA') and UserIsPackOwner=0 then
							dbms_output.put_line('--   Info: Using role OMPUSER can simplify user privilege management.');
							if OMPUSEROK=1 then
								dbms_output.put_line('--         To use this alternative approach, issue the statement:');
							else
								dbms_output.put_line('--         To use this alternative approach, fix OMPUSER privileges (see above) and issue the statement:');
							end if;
							dbms_output.put_line('--      grant OMPUSER to '||myUser||';');
							dbms_output.put_line('--      alter user '||myUser||' default role all;');
						else --user is ok and has OMPUSER; nothing should change here
							null;
						end if;
					end if;
				else --user is not ok
					--report what's missing, but only if the user already exists
					if UserExists=1  then
						dbms_output.put_line('--!  Result: Error(s): '||UserRole||' '||MyUser||' exists but lacks the following privilege(s):');
						if UserLacksPs.count>0 then
							for i in UserLacksPs.First .. UserLacksPs.Last loop
								case when substr(UserLacksPs(i),1,7)='SYNONYM' then --remark: different layout of create synonym and grant is best.
									dbms_output.put_line('--!     create '||UserLacksPs(i)||';     ('||UserLacksPsReason(i)||')');
								else
									continue:=1;
									dbms_output.put('--!     grant '||rpad(UserLacksPs(i),PrivilegeLacksMaxLength)||' to '||myUser||';  ('||UserLacksPsReason(i));
									dbms_output.put(case when UserLacksPsDirectYN(i)=1 then '; to be granted directly to user ' || myUser ||' (or to PUBLIC)' else '' end);
									dbms_output.put_line(')');
								end case;
								:ErrorCount:=:ErrorCount+1;
							end loop;
						end if;
					end if;

					--Now let's solve it
	--				dbms_output.put_line('lacks='||UserLacksPs.count||', lacksdirect='||UserLacksdirectPs.count);
	--				dbms_output.put_line(userlacksindirectps.count);
					if myUSER<>'OMPUSER' and UserLacksOmpuserPs.count>0 then  --easiest solution is to grant OMPUSER rather than granting individual privileges, but only if there are privileges which can be granted trough OMPUSER
						if UserHasOMPUSER=0 then
							if UserExists=1 then --otherwise it already mentioned that creation also requires grants
								dbms_output.put_line('--   Solution: grant role OMPUSER is the recommended solution: issue the following statements:');
							end if;
							dbms_output.put_line('grant OMPUSER to '||myUser||';');
							RoleChange:=1;
							if OMPUSEROK=0 then --Warn that the proposed solution will only work if OMPUSER will be fixed also
								dbms_output.put_line('--   Remark that the previous solution will only work if you also give role OMPUSER the required grants (see above), otherwise you will have to grant all privileges to every user individually.');
							end if;

						else --user has OMPUSER, but still grants are not ok: this means OMPUSER is not ok
							dbms_output.put_line('--   Solution: Fix grants to role OMPUSER (see above)');
							dbms_output.put_line('--             (Alternative solution is to give individual grants to every user)');
						end if;
					end if;
					--Now do the same for privileges which cannot be given through OMPUSER
					if (UserLacksPs.count-UserLacksOmpuserPs.count)>0 or (myUser='OMPUSER' and UserLacksPs.count>0) then  --Give individual grants
						if UserExists=1 then --otherwise it is already mentioned that creation will also require grants
							dbms_output.put_line('--   Solution: add privileges with the following statement(s):');
						end if;
						for i in UserLacksPs.First .. UserLacksPs.Last loop
							if not UserLacksPs(i) member of UserLacksOmpuserPs or myUser='OMPUSER' then
								case
									when substr(UserLacksPs(i),1,7)='SYNONYM' then --remark: different layout of create synonym and grant is best.
										dbms_output.put_line('create '||UserLacksPs(i)||';     ('||UserLacksPsReason(i)||')');
								else
									dbms_output.put_line('grant '||rpad(UserLacksPs(i),PrivilegeLacksMaxLength)||' to '||myUser||';');
									if UserLacksPs(i)='DBA' then --It's a role
										RoleChange:=1;
									end if;
								end case;
							end if;
						end loop;
					end if;
					if RoleChange=1 then
						dbms_output.put_line('alter user '||myUser||' default role all;');
					end if;
				end if;
			end if;

			--User existence and Grants finished

			--End this section with a line, but only if (above) user creation is not followed by package installation (follows below)
			if (UserIsPackOwner=1 and UserExists=1) or myUser='OMPUSER' then
				dbms_output.put_line(:Line);
			end if;

			--Account status: The actual test on account status (should not be LOCKED) can be found further down; because we also have to take this into account when installing packages, we already retrieve the info now.
			--Initialize for every user
			AccountIsLocked:=0;
			if UserExists=1 and myUser not in ('OMPUSER') then
				if :DbaUsers=0 then
					dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_USERS''. Run the ConfigCheck script ''AS SYSDBA''.');
					:ErrorCount:=:ErrorCount+1;
				else
					--Get account_status
  					execute immediate 'select account_status from SYS.DBA_users where username='''||myUser||'''' into AccountStatus;
					if instr(AccountStatus,'LOCKED')>0  then
						AccountIsLocked:=1;
						--Add the user to the global variable :UserListLocked for usage in combination with job creation.
						if myUser in ('OMDBA') then --Only do this for users which should not be unlocked; at the time of writing this is only OMDBA
							:UserListLocked:=:UserListLocked||myUser||',';
						end if;
					end if;
				end if;
			end if;


			--PACKAGES (part 2/2)
			--Collection UserHasOMPackagebodies has been collected above in part 1/2; now continue
			if UserIsPackOwner=1 then
				--pretest
				if :DbaSource=0 and myUser<>user then --then Part 1/2 will not have been able to collect meaningful info
					dbms_output.put_line('--   Requirement: Existence and status of OM maintenance packages in schema '||myUser||'.');
					dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_SOURCE''. Run the ConfigCheck script ''AS SYSDBA''.');
					:ErrorCount:=:ErrorCount+1;
				else
					if UserExists=1 then --minimize output when user doesn't exist
						dbms_output.put_line('--   Requirement: Existence of OM maintenance package specifications in schema '||myUser||'.');
						--Inform why packages will be checked for this user
						if :info>=1 then
							dbms_output.put_line('--   Info: user ' ||myUser||' is considered to be owner of OM maintenance packages because:');
							--Remark that similar output is also given above in the Privileges section; here we are talking about packages.
							if :SkipSharedPackages=1         then dbms_output.put_line('--      Script parameter SkipSharedPackages=true'); end if;
							if UserHasOMPackagespecs.count>0 then dbms_output.put_line('--      '||myUser||' has already '||UserHasOMPackagespecs.count||' OM package specifications installed'); end if;
	  			         if myUser in ('OMDBA')           then dbms_output.put_line('--      This is user OMDBA, which should always be package owner'); end if;
						end if;
					end if;

					--PACKAGE SPECS EXIST?
					if rqPackages=UserHasOMPackagespecs then
						dbms_output.put_line('--   Result: OK: OM maintenance package specifications exist in schema '||myUser||'.');
					else
						--ERROR:
						MissingPacks:=rqPackages multiset except UserHasOMPackagespecs;
						if UserExists=1 then --minimize output when user doesn't exist
							dbms_output.put_line('--!  Result: Error: The following OM package specifications do not exist in schema '||myUser||':');
							for p in 1..MissingPacks.count loop
								dbms_output.put_line('--!     '||MissingPacks(p));
								:ErrorCount:=:ErrorCount+1;
							end loop;
							--SOLUTION:
							dbms_output.put_line('--!  Solution: install the OM maintenance package specifications by executing the following script:');
						end if;
						--start the work
						dbms_output.put_line('alter session set current_schema='||myUser||';');
						for p in 1..MissingPacks.count loop
							dbms_output.put_line('start '||lower(MissingPacks(p))||'_spec.ora');
						end loop;
						if userexists=1 then dbms_output.put_line('alter session set current_schema='||user||';'); end if; --else bodies follow
						--if we're checking a non-OMDBA user, and any of the packages are missing, we will still need OMDBA to have valid maintenance packages.
						OMDBAMaintenancePacksRequired:=1;
					end if;
					if UserExists=1 then --minimize output when user doesn't exist
						dbms_output.put_line(:Line);
					end if;

					--PACKAGE BODIES  EXIST?
					if UserExists=1 then --minimize output when user doesn't exist
						dbms_output.put_line('--   Requirement: Existence of OM maintenance package bodies in schema '||myUser||'.');
					end if;
					if rqPackages=UserHasOMPackagebodies then
						dbms_output.put_line('--   Result: OK: OM maintenance package bodies exist in schema '||myUser||'.');
					else
						MissingPacks:=rqPackages multiset except UserHasOMPackagebodies;
						if UserExists=1 then --minimize output when user doesn't exist
							--ERROR:
							dbms_output.put_line('--!  Result: Error: The following maintenance package bodies do not exist in schema '||myUser||':');
							for p in 1..MissingPacks.count loop
								dbms_output.put_line('--!     '||MissingPacks(p));
								:ErrorCount:=:ErrorCount+1;
							end loop;
							--SOLUTION:
							dbms_output.put_line('--!  Solution: install the maintenance package bodies by executing the following script:');
						end if;
						--start the work
						if userexists=1 then dbms_output.put_line('alter session set current_schema='||myUser||';'); end if; --else session was already altered with specs above
						for p in 1..MissingPacks.count loop
							dbms_output.put_line('start '||lower(MissingPacks(p))||'_body.ora');
						end loop;
						dbms_output.put_line('alter session set current_schema='||user||';'); --reset to original schema
						--if we're checking a non-OMDBA user, and any of the packages are missing, we will still need OMDBA to have valid maintenance packages.
						OMDBAMaintenancePacksRequired:=1;
					end if;
					if UserExists=1 then --minimize output when user doesn't exist
						dbms_output.put_line(:Line);
					end if;


					if UserExists=1 then --minimize output when user doesn't exist; also testing for version and errors is useless when the user does not exist (so packages won't exist neither)
						--PACKAGE VERSION+ERRORS

						--PACKAGE VERSIONs
						dbms_output.put_line('--   Requirement: OM maintenance package in schema '||myUser||' must be at least version '||:OMPApplicationVersion||'.');
						--useful side-effect of checking version is that errors (if any) will show up in next step when package body has been used by retrieving version.
						if UserHasOMPackagebodies.count>0 then
							PackageVersion:='';
							for s in UserHasOMPackagebodies.First .. UserHasOMPackagebodies.Last loop
								--get version + raise error if needed
								begin
									execute immediate 'select '||myUser||'.'||UserHasOMPackagebodies(s)||'.version from dual' into PackageVersion;
									if :info>0 then
										dbms_output.put_line('--   Info: package '||myUser||'.'||rpad(UserHasOMPackagebodies(s),10)||'  version is '||PackageVersion||'.');
									end if;
									if substr(ltrim(PackageVersion,'R'),0,5)>=:OMPApplicationVersion then
										dbms_output.put_line('--   Result: OK.');
									else
										:errorcount:=:errorcount+1;
										dbms_output.put_line('--!  ERROR: package '||myUser||'.'||rpad(UserHasOMPackagebodies(s),10)||' version '||PackageVersion||' is lower than the expected OMP Application version '||:OMPApplicationVersion||'.');
										dbms_output.put_line('--   Solution: replace package '||myUser||'.'||UserHasOMPackagebodies(s)||' with newer version with following statements:');
										dbms_output.put_line('alter session set current_schema='||myUser||';');
										dbms_output.put_line('start '||lower(UserHasOMPackagebodies(s))||'_spec.ora');
										dbms_output.put_line('start '||lower(UserHasOMPackagebodies(s))||'_body.ora');
										dbms_output.put_line('alter session set current_schema='||user||';'); --reset to original schema
									end if;
	
								exception
									when bodyerror then
										dbms_output.put_line('--!  ERROR: package '||myUser||'.'||rpad(UserHasOMPackagebodies(s),10)||' version could not be obtained because this package body has errors.');
										dbms_output.put_line('--   Solution: see next section where packages are checked for errors.');
										:errorcount:=:errorcount+1;
									when invalididentifier then
										dbms_output.put_line('--!  ERROR: package '||myUser||'.'||rpad(UserHasOMPackagebodies(s),10)||' version could not be obtained because the package specification is missing.');
										dbms_output.put_line('--   Solution: install package specification as specified in section above.');
										:errorcount:=:errorcount+1;
									when others then --Errors will be listed further.
										dbms_output.put_line('--!  ERROR: package '||myUser||'.'||rpad(UserHasOMPackagebodies(s),10)||' version could not be obtained.');
										dbms_output.put_line('--   Solution: see next section where packages are checked for errors.');
										:errorcount:=:errorcount+1;
								end;
							end loop;
						else
							dbms_output.put_line('--(!)Result: WARNING: Requirement cannot be tested because packages do not exist.');
							:WarningCount:=:WarningCount+1;
						end if; --UserHasOMPackagebodies.count
						dbms_output.put_line(:Line);


						--ERRORS in the packages?
						dbms_output.put_line('--   Requirement: '||myUser||' packages should be error-free.');
						if UserHasOMPackagebodies.count=0 then
							dbms_output.put_line('--(!)Result: WARNING: Requirement cannot be tested because packages do not exist.');
							:WarningCount:=:WarningCount+1;
						else
							UserErrors.delete;

							for s in UserHasOMPackagebodies.First .. UserHasOMPackagebodies.Last loop
								--package exists, now check for errors
								if myUser=USER	 then --no DBA needed to find your own errors
									execute immediate 'select '''||myUser||''',name,line,position,text from user_errors where name='''||UserHasOMPackagebodies(s)||''' order by sequence' bulk collect into UserErrors; --'
									execute immediate 'select '''||myUser||''',object_name,object_type,status from user_objects where object_name='''||UserHasOMPackagebodies(s)||''' and status=''INVALID''' bulk collect into UserInvalidObjects; --'
								else
									--pretest
									if :DbaErrors=0 then
										dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_ERRORS''. Run the ConfigCheck script ''AS SYSDBA''.');
										:ErrorCount:=:ErrorCount+1;
									else
										execute immediate 'select owner,name,line,position,text from SYS.DBA_errors where name='''||UserHasOMPackagebodies(s)||''' and owner='''||myUser||''' order by sequence' bulk collect into UserErrors; --'
								end if;

									if :DbaObjects=0 then
										dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_OBJECTS''. Run the ConfigCheck script ''AS SYSDBA''.');
										:ErrorCount:=:ErrorCount+1;
									else
										execute immediate 'select owner,object_name ,object_type,status from dba_objects where object_name='''||UserHasOMPackagebodies(s)||''' and object_type=''PACKAGE BODY'' and owner='''||myUser||''' and status=''INVALID''' bulk collect into UserInvalidObjects; --'
									end if;

								end if;
								--Only continue if you were able to obtain info:
 								--dbms_output.put_line('UserErrors.count='|| UserErrors.count||', UserInvalidObjects.count='||UserInvalidObjects.count);
 								if myUser=USER or (:DbaErrors!=0 and :DbaObjects!=0) then
									if (UserErrors.count=0 and UserInvalidObjects.count=0) then --package is errorfree and not invalid
										dbms_output.put_line('--   Result for package '||myUser||'.'||rpad(UserHasOMPackagebodies(s),10)||': OK.');
									else --package has errors or is invalid
										if not UserErrors.count=0 then --package is not errorfree
											dbms_output.put_line('--!  Result for package '||myUser||'.'||rpad(UserHasOMPackagebodies(s),10) ||': Error: package contains '||UserErrors.count||' errors.');
											--Show all errors
													for e in 1..UserErrors.count loop
												dbms_output.put_line('--!     Error in '||UserErrors(e).name ||' ['||UserErrors(e).line||'/'||UserErrors(e).position||'] '||UserErrors(e).text);
												:ErrorCount:=:ErrorCount+1;
											end loop;
											--if we're checking a non-OMDBA user, and any of the packages are missing, we will still need OMDBA to have valid maintenance packages.
											OMDBAMaintenancePacksRequired:=1;
										else
		  								   if not UserInvalidObjects.count=0 then --package is invalid
												dbms_output.put_line('--   Result for package '||myUser||'.'||rpad(UserHasOMPackagebodies(s),10) ||': Error: the package''s object status  is ''INVALID''.');
												--if we're checking a non-OMDBA user, and any of the packages is invalid, we will still need OMDBA to have valid maintenance packages.
												OMDBAMaintenancePacksRequired:=1;
											end if;
										end if;

										--Now let's solve it:
										--Ensure package specs are also installed
										if not UserHasOMPackagebodies(s) member of UserHasOMPackagespecs then
											dbms_output.put_line('--   Solution: ensure the package specifications are also installed; see error+solution in previous section.');
										end if;
										--Ensure required grants are given
										if 'SELECT ON SYS.'||:xV_$SESSION||'' member of UserlacksdirectPs
											or 'SELECT ON SYS.V_$PARAMETER' member of UserlacksdirectPs
											or 'SELECT ON SYS.V_$LOCK' member of UserlacksdirectPs
											or 'SELECT ON SYS.V_$LOCKED_OBJECT' member of UserlacksdirectPs
											then
											dbms_output.put_line('--   Solution: ensure the required grants are given to the user (see above)');
											dbms_output.put_line('alter package ' ||myUser||'.'||UserHasOMPackagebodies(s)|| ' compile;');
										else
											if UserErrors.count=0 then --so it's INVALID but without errors; compile should be enough (might raise errors which then will be seen in subsequent run)
												dbms_output.put_line('--   Solution: try to recompile the package with the following statement:');
												dbms_output.put_line('alter package ' ||myUser||'.'||UserHasOMPackagebodies(s)|| ' compile;');
											else --Something else is wrong, suggest reinstalling
												dbms_output.put_line('--   Solution: Reinstall the package with the following statements:');
												dbms_output.put_line('alter session set current_schema='||myUser||';');
												dbms_output.put_line('start '||lower(UserHasOMPackagebodies(s) )||'_spec.ora');
												dbms_output.put_line('start '||lower(UserHasOMPackagebodies(s) )||'_body.ora');
												dbms_output.put_line('alter session set current_schema='||user||';');--reset to original schema
											end if;
										end if;
									end if; --(UserErrors.count=0 and UserInvalidObjects.count=0)
								end if; --myUser=USER or (:DbaErrors!=0 and :DbaObjects!=0)
							end loop; --UserHasOMPackagebodies
						end if; --UserHasOMPackagebodies.count
					end if; --UserExists
				end if; --pretest
			end if; --User is PackOwner

			if UserExists=1 and myUser<>'OMPUSER' then
				dbms_output.put_line(:Line);
			end if;



			--LOCAL SLEEP procedure
			if :SkipSharedSleep=1 then
				if myUser<>'OMPUSER' then
					--pretest
					if :DbaObjects=0 and myUser<>user then
						dbms_output.put_line('--   Requirement: Procedure '||myUser||'.SLEEP must exist.');
						dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_OBJECTS''. Run the ConfigCheck script ''AS SYSDBA''.');
						:ErrorCount:=:ErrorCount+1;
					else
						UserSleepExists:=0;
						if UserExists=1 then --minimize output when user doesn't exist, + don't have to investigate if the user even does not exist
							dbms_output.put_line('--   Requirement: Procedure '||myUser||'.SLEEP must exist.');

							--Find if it exists or not
							if :DbaObjects=0 then
								execute immediate 'select count(9) from user_objects where object_name=''SLEEP'' and object_type=''PROCEDURE'' ' into UserSleepExists;
							else
								execute immediate 'select count(9) from SYS.DBA_objects where object_name=''SLEEP'' and object_type=''PROCEDURE'' and OWNER='''||myUser||'''' into UserSleepExists;
							end if;
						end if;

						--Conclusion
						if UserSleepExists>0 then
							dbms_output.put_line('--   Result: OK.');
						else
							if UserExists=1 then
								dbms_output.put_line('--!  Result: Error: Procedure '||myUser||'.SLEEP must exist.');
								:ErrorCount:=:ErrorCount+1;
								dbms_output.put_line('--   Solution: Add the procedure with the following statements:');
							end if;
							dbms_output.put_line('create or replace procedure '||myUser||'.sleep (Sleep_TIME IN NUMBER)  is');
							dbms_output.put_line('begin');
							dbms_output.put_line('   sys.dbms_lock.sleep(Sleep_Time);');
							dbms_output.put_line('end;');
							dbms_output.put_line('/');
						end if;
					end if;
				else
					--OMPUSer is a role and does not required sleep procedure
					null;
				end if;
			 else
				--Existence of SYS.SLEEP was investigated earlier.
				null;
			end if;

			if UserExists=0 and myUser<>'OMPUSER' /* otherwise line was already provided */ then
				dbms_output.put_line(:Line);
			end if;




			--Report on missing synonyms, if needed
			--Determine if view and synonym MYV$SESSION exist, required to evaluate privileges to V$SESSION or MYV$SESSION (+ similarly for LOCK, LOCKED_OBJECT)
			if myUser not in ('OMPUSER') then
				--Loop will contina 3 items: SESSION, LOCK and LOCKED_OBJECT
				for variableview in (select name from (select 'SESSION' name, 1 position from dual union select 'LOCK' name, 2 position from dual union select 'LOCKED_OBJECT' name, 3 position from dual) order by position) loop
					viewname:=variableview.name;
					dbms_output.put_line('--   Requirement: Access to required '||viewname||' synonym for user '||myUser||'.');

					--recover info kept previously
					case viewname
						when 'SESSION'       then
							AlternativeMYV$viewnameSyn:=AlternativeMYV$SESSIONSyn;
							PublicV$viewnameSynProp   :=PublicV$SESSIONSynProp;
							PublicMYV$viewnameSynProp :=PublicMYV$SESSIONSynProp;
						when 'LOCK'          then
							AlternativeMYV$viewnameSyn:=AlternativeMYV$LOCKSyn;
							PublicV$viewnameSynProp   :=PublicV$LOCKSynProp;
							PublicMYV$viewnameSynProp :=PublicMYV$LOCKSynProp;
						when 'LOCKED_OBJECT' then
							AlternativeMYV$viewnameSyn:=AlternativeMYV$LOCKEDOBJECTSyn;
							PublicV$viewnameSynProp   :=PublicV$LOCKED_OBJECTSynProp;
							PublicMYV$viewnameSynProp :=PublicMYV$LOCKED_OBJECTSynProp;
					end case;

					Continue:=1;
					if myUser=USER then
						execute immediate 'select count(9) from all_synonyms  where synonym_name=''V$'  ||viewname||'''  and owner=''PUBLIC'' and table_owner=''SYS'' and table_name=''V_$'           ||viewname||'''      ' into SYSVViewNamePublicSyn;
						execute immediate 'select count(9) from user_synonyms where synonym_name=''V$'  ||viewname||'''                       and table_owner=''SYS'' and table_name=''V_$'           ||viewname||'''      ' into SYSVViewNamePrivSyn;
						execute immediate 'select count(9) from all_views     where view_name   =''MYV$'||viewname||'''  and owner=''SYS''                                                                                 ' into SYSMYVViewNameView;
						execute immediate 'select count(9) from user_views    where view_name   =''MYV$'||viewname||'''                                                                                                    ' into PrivMYVViewNameView;
						execute immediate 'select count(9) from all_synonyms  where synonym_name=''V$'  ||viewname||'''  and owner=''PUBLIC'' and table_owner=''SYS'' and table_name=''MYV$'          ||viewname||'''      ' into SYSMYVViewNamePublicSyn;
						execute immediate 'select count(9) from user_synonyms where synonym_name=''V$'  ||viewname||'''                       and table_owner=''SYS'' and table_name=''MYV$'          ||viewname||'''      ' into SYSMYVViewNamePrivSyn;
						--situation of Private view with Public synonym is ridiculous and will not be investigated
						execute immediate 'select count(9) from user_synonyms where synonym_name=''V$'  ||viewname||'''                       and table_owner='''||myUser||''' and table_name=''MYV$' ||viewname||'''      ' into PrivMYVViewNamePrivSyn;

					else
						--pretest DBA
						if :DbaSynonyms=0 then
							dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_SYNONYMS''. Run the ConfigCheck script ''AS SYSDBA''.');
							:ErrorCount:=:ErrorCount+1;
							Continue:=0;
						else
							execute immediate 'select count(9) from SYS.DBA_synonyms where synonym_name=''V$'  ||viewname||'''       and owner=''PUBLIC''       and table_owner=''SYS''          and table_name=''V_$' ||viewname||''' ' into SYSVViewNamePublicSyn;
							execute immediate 'select count(9) from SYS.DBA_synonyms where synonym_name=''V$'  ||viewname||'''       and owner='''||myUser||''' and table_owner=''SYS''          and table_name=''V_$' ||viewname||''' ' into SYSVViewNamePrivSyn;
							execute immediate 'select count(9) from dba_views        where view_name   =''MYV$'||viewname||'''       and owner=''SYS''                                                                                 ' into SYSMYVViewNameView;
							execute immediate 'select count(9) from dba_views        where view_name   =''MYV$'||viewname||'''       and owner='''||myUser||'''                                                                        ' into PrivMYVViewNameView;
							execute immediate 'select count(9) from dba_synonyms     where synonym_name=''V$'  ||viewname||'''       and owner=''PUBLIC''       and table_owner=''SYS''          and table_name=''MYV$'||viewname||''' ' into SYSMYVViewNamePublicSyn;
							execute immediate 'select count(9) from SYS.DBA_synonyms where synonym_name=''V$'  ||viewname||'''       and owner='''||myUser||''' and table_owner=''SYS''          and table_name=''MYV$'||viewname||''' ' into SYSMYVViewNamePrivSyn;
							execute immediate 'select count(9) from SYS.DBA_synonyms where synonym_name=''V$'  ||viewname||'''       and owner='''||myUser||''' and table_owner='''||myUser||''' and table_name=''MYV$'||viewname||''' ' into PrivMYVViewNamePrivSyn;
						end if;
					end if;
					if Continue=1 then
						if :info>=1 then
							dbms_output.put_line('--   Info:');
							dbms_output.put_line('--      Public  synonym '||:xV||'$'  ||viewname||'   for SYS.'||:xV||'_$'      ||viewname||'      '                ||case SYSVViewNamePublicSyn    when 0 then 'does not exist.' else 'exists.' end);
							dbms_output.put_line('--      Private synonym '||:xV||'$'  ||viewname||'   for SYS.'||:xV||'_$'      ||viewname||'      '                ||case SYSVViewNamePrivSyn      when 0 then 'does not exist.' else 'exists.' end);
							dbms_output.put_line('--      SYS     view    MYV$'||viewname||'              '      ||rpad(' ',length(viewname))||'    '||case SYSMYVViewNameView       when 0 then 'does not exist.' else 'exists.' end);
							dbms_output.put_line('--      Private view    MYV$'||viewname||'              '      ||rpad(' ',length(viewname))||'    '||case PrivMYVViewNameView      when 0 then 'does not exist.' else 'exists.' end);
							dbms_output.put_line('--      Public  synonym '||:xV||'$'  ||viewname||'   for SYS.MYV$'             ||viewname||'     '                 ||case SYSMYVViewNamePublicSyn  when 0 then 'does not exist.' else 'exists.' end);
							dbms_output.put_line('--      Private synonym '||:xV||'$'  ||viewname||'   for SYS.MYV$'             ||viewname||'     '                 ||case SYSMYVViewNamePrivSyn    when 0 then 'does not exist.' else 'exists.' end);
							dbms_output.put_line('--      Private synonym '||:xV||'$'  ||viewname||'   for private MYV$'         ||viewname||' '                     ||case PrivMYVViewNamePrivSyn   when 0 then 'does not exist.' else 'exists.' end);
						end if;

						--If the corresponding privilege is missing, this will have been reported before
						--Always suggest public synonyms, except if SkipPublicSynonyms=1
						--Always suggest synonyms for V$ views, except if SkipV$Views=1

						--dbms_output.put_line('AlternativeMYV$SESSIONSyn='||AlternativeMYV$SESSIONSyn);
						--dbms_output.put_line('PublicV$SESSIONSynProp   ='||PublicV$SESSIONSynProp   );
						--dbms_output.put_line('PublicMYV$SESSIONSynProp ='||PublicMYV$SESSIONSynProp );
						If :SkipV$Views=0 and AlternativeMYV$viewnameSyn=0 then --Synonym should point to GV_$ views;
						--except if the privileges on the GV_$ was missing but a privilege on MYV$ was available, then MYV$ can be a valid alternative if also the synonym follows
							if SYSVViewNamePrivSyn=1 or SYSVViewNamePublicSyn=1 then --***Not covered: if private is garbage
								dbms_output.put_line('--   Result: OK.');
							else
								dbms_output.put_line('--!  ERROR: user '||myUser||' has no synonym for SYS.'||:xV||'_$'||viewname||'.');
								:ErrorCount:=:ErrorCount+1;
								if PublicV$viewnameSynProp is null then
									dbms_output.put_line('--   Solution: Create synonym with the following statement:');
									if :SkipPublicSynonyms=0 then --create public
										dbms_output.put_line('create or replace public synonym '||:xV||'$'||viewname||' for SYS.'||:xV||'_$'||viewname||';');
										--Keep track that the suggestion was given to create public synonym; this has to be done per type viewname (could be moved to end of for loop when similar cases were added)
					  			      case viewname
											when 'SESSION'       then PublicV$SessionSynProp      :=myUser;
											when 'LOCK'          then PublicV$LockSynProp         :=myUser;
											when 'LOCKED_OBJECT' then PublicV$Locked_objectSynProp:=myUser;
										end case;
									else -- create private
										dbms_output.put_line('create or replace synonym '||myUser||'.'||:xV||'$'||viewname||' for SYS.'||:xV||'_$'||viewname||';');
									end if;
								else
									dbms_output.put_line('--   Solution: The solution to create a public synonym for SYS.'||:xV||'_$'||viewname||' has already proposed above, see user '||PublicV$viewnameSynProp||'.');
								end if;
							end if;
						else --Synonyms should point to MYV$ views
							if SYSMYVViewNamePrivSyn=1 or SYSMYVViewNamePublicSyn=1 then --***Not covered: if private is garbage
									dbms_output.put_line('--   Result: OK.');
							else
								dbms_output.put_line('--!  ERROR: user '||myUser||' has no synonym for SYS.MYV$'||viewname||'.');
								:ErrorCount:=:ErrorCount+1;
								if PublicMYV$viewnameSynProp is null then
									dbms_output.put_line('--   Solution: Create synonym with the following statement:');
									if :SkipPublicSynonyms=0 then --create public
										dbms_output.put_line('create or replace public synonym '||:xV||'$'||viewname||' for SYS.MYV$'||viewname||';');
										--Keep track that the suggestion was given to create public synonym; this has to be done per type viewname:
					  			      case viewname
											when 'SESSION'       then PublicMYV$SessionSynProp      :=myUser;
											when 'LOCK'          then PublicMYV$LockSynProp         :=myUser;
											when 'LOCKED_OBJECT' then PublicMYV$Locked_objectSynProp:=myUser;
										end case;
									else -- create private
										dbms_output.put_line('create or replace synonym '||myUser||'.'||:xV||'$'||viewname||' for SYS.MYV$'||viewname||';');
									end if;
								else
									dbms_output.put_line('--   Solution: The solution to create a public synonym for SYS.MYV$'||viewname||' has already proposed above, see user '||PublicMYV$viewnameSynProp||'.');
								end if;
							end if;
						end if;
					else
						--Insufficient privileges to give further output. Next please.
						null;
					end if;
					dbms_output.put_line(:Line);
				end loop;
			-- else --OMPUSER is role which cannot have synonym
			end if;

			--Unlimited quota on OMPARTNERS and INDEXES
			if UserExists<>0 and myUser<>'OMPUSER' then
				if myUser='OMDBA' then
	  				dbms_output.put_line('--   Requirement: User '||myUser||' must have unlimited quota on tablespaces OMDBA, OMPARTNERS and INDEXES.');
	  			else
	  				dbms_output.put_line('--   Requirement: User '||myUser||' must have unlimited quota on tablespaces OMPARTNERS and INDEXES.');
	  			end if;

				--Loop OMPARTNERS+INDEXES+OMDBA
				for TS in TSq loop
					--Skip checking quota on tablespace OMDBA when user is not OMDBA
					if myUser='OMDBA' or TS.TSName!='OMDBA' then
						--First check if there are any quotas given
						if myUser=USER	 then --no DBA needed to find your own quota
							execute immediate 'select count(9) from user_ts_quotas where tablespace_name='''||TS.TSname||'''' into TSQuota;
						else
							--pretest
							if :DbaTSQuotas=0 then
								dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_TS_QUOTAS''. Run the ConfigCheck script ''AS SYSDBA''.');
								:ErrorCount:=:ErrorCount+1;
							else
								execute immediate 'select count(9) from dba_ts_quotas where tablespace_name='''||TS.TSname||''' and username='''||myUser||'''' into TSQuota;
							end if;
						end if;
	
						if myUser=user or :DbaSource<>0 then
			 				if TSQuota=0 then
								dbms_output.put_line('--!  Result: Error: User '||myUser|| ' has no quota on '||TS.TSname||'.');
								:errorcount:=:errorcount+1;
								dbms_output.put_line('--   Solution: give unlimited quota with the following statement:');
								dbms_output.put_line('alter user '||myUser||' quota unlimited on '||TS.TSname||';');
							else
								--Some quota exists, now check whether it is unlimited
								if myUser=USER	 then --no DBA needed to find your own quota
									execute immediate 'select max_bytes from user_ts_quotas where tablespace_name='''||TS.TSname||'''' into TSQuota;
								else
									execute immediate 'select max_bytes from dba_ts_quotas where tablespace_name='''||TS.TSname||''' and username='''||myUser||'''' into TSQuota;
								end if;
	
								if TSQuota=-1 then
									dbms_output.put_line('--   Result: OK for '||TS.TSname||'.');
								else
									if :info>=1 then dbms_output.put_line('--   Info: User '||MyUser||' has quota '||NumberToKMGtext(TSQuota)||' on tablespace '||TS.TSname||'.'); end if;
									dbms_output.put_line('--!  Result: Error: User '||myUser|| ' does not have unlimited quota on '||TS.TSname||'.');
									:errorcount:=:errorcount+1;
									dbms_output.put_line('--   Solution: give unlimited quota with the following statement:');
									dbms_output.put_line('alter user '||myUser||' quota unlimited on '||TS.TSname||';');
								end if;
							end if;
						else
							--Quota reporting not possible when data could not be obtained
							null;
		  			   end if;
		  			end if;
				end loop; --Tablespaces OMPARTNERS+INDEXES+OMDBA
				dbms_output.put_line(:Line);
			else
				--User does not exist, quota will be specified in create user statement
				null;
			end if;

			--MAINTENANCE JOB
			if myUser<>'OMPUSER' and upper(substr(SYS_CONTEXT('USERENV','HOST'),0,10))<>'OMPARTNERS' then --No default job class and hence no default jobs when inside OMPartners domain.
				--pretest
				if :DbaSchedulerJobs=0 and myUser<>user then
					dbms_output.put_line('--   Requirement: Existence of OM maintenance job in schema '||myUser||'.');
					dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_SCHEDULER_JOBS''. Run the ConfigCheck script ''AS SYSDBA''.');
					:ErrorCount:=:ErrorCount+1;
				else
					if UserExists=1 then --minimize output when user doesn't exist
						dbms_output.put_line('--   Requirement: Existence of OM maintenance job in schema '||myUser||'.');
					end if;
					if :DbaSchedulerJobs=0 then
						execute immediate 'select count(9) from user_scheduler_jobs where upper(job_name)=''OMP_CLEANUP_JOB''' into UserHasJob;
					else
						execute immediate 'select count(9) from SYS.DBA_scheduler_jobs where upper(job_name)=''OMP_CLEANUP_JOB'' and owner='''||myUser||'''' into UserHasJob;
					end if;
					if UserHasJob>0 then
						dbms_output.put_line('--   Result: OK: User has maintenance job ''OMP_CLEANUP_JOB''.');
						--Show some info about this job
						if :DbaSchedulerJobs=0 then
							execute immediate 'select count(9)                                  from user_scheduler_jobs where upper(job_name)=''OMP_CLEANUP_JOB''' into UserHasJob;
							execute immediate 'select to_char(last_start_date)                  from user_scheduler_jobs where upper(job_name)=''OMP_CLEANUP_JOB''' into JobLastStartDdate;
							execute immediate 'select to_char(last_run_duration)                from user_scheduler_jobs where upper(job_name)=''OMP_CLEANUP_JOB''' into JobLastRunDuration;
							execute immediate 'select to_char(next_run_date)                    from user_scheduler_jobs where upper(job_name)=''OMP_CLEANUP_JOB''' into JobNextRunDdate;
							execute immediate 'select to_char(repeat_interval)                  from user_scheduler_jobs where upper(job_name)=''OMP_CLEANUP_JOB''' into JobRepeatInterval;
							execute immediate 'select state                                     from user_scheduler_jobs where upper(job_name)=''OMP_CLEANUP_JOB''' into JobState;
							execute immediate 'select extract(timezone_region from start_date)  from user_scheduler_jobs where upper(job_name)=''OMP_CLEANUP_JOB''' into JobTZName;
						else
							execute immediate 'select count(9)                                  from SYS.DBA_scheduler_jobs where upper(job_name)=''OMP_CLEANUP_JOB'' and owner='''||myUser||'''' into UserHasJob;
							execute immediate 'select to_char(last_start_date)                  from SYS.DBA_scheduler_jobs where upper(job_name)=''OMP_CLEANUP_JOB'' and owner='''||myUser||'''' into JobLastStartDdate;
							execute immediate 'select to_char(last_run_duration)                from SYS.DBA_scheduler_jobs where upper(job_name)=''OMP_CLEANUP_JOB'' and owner='''||myUser||'''' into JobLastRunDuration;
							execute immediate 'select to_char(next_run_date)                    from SYS.DBA_scheduler_jobs where upper(job_name)=''OMP_CLEANUP_JOB'' and owner='''||myUser||'''' into JobNextRunDdate;
							execute immediate 'select to_char(repeat_interval)                  from SYS.DBA_scheduler_jobs where upper(job_name)=''OMP_CLEANUP_JOB'' and owner='''||myUser||'''' into JobRepeatInterval;
							execute immediate 'select state                                     from SYS.DBA_scheduler_jobs where upper(job_name)=''OMP_CLEANUP_JOB'' and owner='''||myUser||'''' into JobState;
							execute immediate 'select extract(timezone_region from start_date)  from SYS.DBA_scheduler_jobs where upper(job_name)=''OMP_CLEANUP_JOB'' and owner='''||myUser||'''' into JobTZName;
						end if;

						if :info>=1 then
							dbms_output.put_line('--   Info: last_start_date   = '||JobLastStartDdate);
							dbms_output.put_line('--   Info: last_run_duration = '||JobLastRunDuration);
							dbms_output.put_line('--   Info: next_run_date     = '||JobNextRunDdate);
							dbms_output.put_line('--   Info: repeat_interval   = '||JobRepeatInterval);
						end if;

						--Now check additional requirement that job must have status SCHEDULED
						dbms_output.put_line(:Line);
						dbms_output.put_line('--   Requirement: OM maintenance job in schema '||myUser||' must be in SCHEDULED state.');
						if :info>=1 then dbms_output.put_line('--   Info: state             = '||JobState); end if;
						if JobState<>'SCHEDULED' then
							:ErrorCount:=:ErrorCount+1;
							dbms_output.put_line('--!  Result: Error: Job does not have state ''SCHEDULED''.');
							if JobState='DISABLED' then
								dbms_output.put_line('--   Solution: Enable the job with the following statement:');
								dbms_output.put_line('exec dbms_scheduler.enable('''||myUser||'.'||'OMP_CLEANUP_JOB'');');
							else
								dbms_output.put_line('--   Solution: Investigate manually why job is not scheduled.');
							end if;
						else
							dbms_output.put_line('--   Result: OK.');
						end if;

						--Now check additional requirement that the timezone should be a timezone NAME in order to be able to follow daylight saving adjustments.
						dbms_output.put_line(:Line);
						dbms_output.put_line('--   Requirement: OM maintenance job in schema '||myUser||' must have named timezone to allow for daylight savings adjustments.');
						if JobTZName='UNKNOWN' then
							dbms_output.put_line('--!  Result: Error: Job has an absolute offset time zone, so daylight savings adjustments will not be applied.');
							:ErrorCount:=:ErrorCount+1;
							dbms_output.put_line('--   Solution: Change the job''s timezone to a named timezone. The next statements adjust the job to the scheduler''s default timezone name:');

							execute immediate 'select extract(timezone_region from dbms_scheduler.stime) from dual' into JobTZName;
							if JobTZName='UNKNOWN' then JobTZName:='Europe/Brussels'; end if;
							dbms_output.put_line('alter session set time_zone='''||JobTZName||''';');
							dbms_output.put_line('exec dbms_scheduler.set_attribute( name => '''||myUser||'."OMP_CLEANUP_JOB"'' , attribute => ''start_date'' , value => sysdate );');
						else
	  						dbms_output.put_line('--   Result: OK: Job has named timezone '''||JobTZName||'''.');
						end if;

					else
						if UserExists=1 then
							dbms_output.put_line('--!  Result: Error: No job found.');
							:errorcount:=:errorcount+1;
							dbms_output.put_line('--   Solution: create the OMP_CLEANUP_JOB job for user '||myUser||'. The statements to do this will be given below.');
						else
							dbms_output.put_line('--   This new user will also need the OMP_CLEANUP_JOB maintenance job. The statements to do this will be given below.');
						end if;
						if UserIsPackOwner=1 and rqPackages=UserHasOMPackagebodies then --user has packages, so use them (could still contain errors, but this is mentioned as separate error above)
							JobUsesMPSchema:='';
						else
							JobUsesMPSchema:='omdba.';
						end if;
						--Add the user to the global variable :UserListRequiringMJobCreation; statements to create job for these users will be given at the end, because SYS cannot do this reliably.
						:UserListRequiringMJobCreation:=:UserListRequiringMJobCreation||JobUsesMPSchema||myUser||',';
				end if;
				end if;
				dbms_output.put_line(:Line);
			end if; --Maintenance job section: myUser<>'OMPUSER' and outside OM Partners domain


			--USER's TABLESPACEs
			if UserExists=1 and myUser<>'OMPUSER' then
				dbms_output.put_line('--   Requirement: Default_tablespace   for user '||myUser||' must be '||case myUser when 'OMDBA' then 'OMDBA' else 'OMPARTNERS' end||', and');
				dbms_output.put_line('--                Temporary_tablespace for user '||myUser||' must be TEMP.');
				if :DbaUsers>0 or myUser=USER then
					if myUser=USER then
						execute immediate 'select default_tablespace from user_users' into DefaultTablespace;
						execute immediate 'select temporary_tablespace from user_users' into TemporaryTablespace;
					else
						execute immediate 'select default_tablespace from SYS.DBA_users where username='''||myUser||'''' into DefaultTablespace;
						execute immediate 'select temporary_tablespace from SYS.DBA_users where username='''||myUser||'''' into TemporaryTablespace;
					end if;


					--DEFAULT_TABLESPACE
					if :info>=1 then dbms_output.put_line('--   Info: user '||myUser||'''s default tablespace is '||DefaultTablespace||'.'); end if;
					Result:=1;
					case 
						when myUser='OMDBA' or myUser=:OMDINUser then
							case DefaultTablespace
								when 'OMDBA' then
									dbms_output.put_line('--   Result: OK for default tablespace of user '||myUser||'.');
								when 'OMPARTNERS'  then
									dbms_output.put_line('--(!)Warning: We recommend to give '||myUser||' default tablespace OMDBA');
									:warningcount:=:warningcount+1;
									dbms_output.put_line('--   Solution: modify user''s default tablespace with the following statement:');
									dbms_output.put_line('alter user '||myUser||' default tablespace OMDBA;');
								else
									Result:=0;
							end case;
						else
							case DefaultTablespace
								when 'OMPARTNERS' then
									dbms_output.put_line('--   Result: OK for default tablespace of user '||myUser||'.');
								else
									Result:=0;
						end case;
					end case;
					if Result=0 then
						dbms_output.put_line('--!  Result: Error: User '||myUser||' has incorrect default_tablespace.');
						:ErrorCount:=:ErrorCount+1;
						dbms_output.put_line('--   Solution: modify user''s default tablespace with the following statement:');
						dbms_output.put_line('alter user '||myUser||' default tablespace '||case myUser when 'OMDBA' then 'OMDBA' when :OMDINUser then 'OMDBA' else 'OMPARTNERS' end||';');
					end if;

					--TEMPORARY_TABLESPACE
					if :info>=1 then dbms_output.put_line('--   Info: user '||myUser||'''s temporary tablespace is '||TemporaryTablespace||'.'); end if;
					if TemporaryTablespace='TEMP' then
						dbms_output.put_line('--   Result: OK for temporary tablespace of user '||myUser||'.');
					else
						dbms_output.put_line('--!  Result: Error: User '||myUser||' has incorrect temporary_tablespace.');
						:ErrorCount:=:ErrorCount+1;
						dbms_output.put_line('--   Solution: modify user''s temporary tablespace with the following statement:');
						dbms_output.put_line('alter user '||myUser||' temporary tablespace TEMP;');
					end if;

				else
					dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_USERS''. Run the ConfigCheck script ''AS SYSDBA''.');
					:ErrorCount:=:ErrorCount+1;
				end if;

				dbms_output.put_line(:Line);
			end if;

			--USER's EXPIRY status
			if UserExists=1 and myUser<>'OMPUSER' then
				dbms_output.put_line('--   Requirement: Password for user '||myUser||' should not expire.');
				if :DbaUsers=0 then
					dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_USERS''. Run the ConfigCheck script ''AS SYSDBA''.');
					:ErrorCount:=:ErrorCount+1;
					dbms_output.put_line(:Line);
				else
					--Expiry date
  					execute immediate 'select expiry_date from SYS.DBA_users where username='''||myUser||'''' into ExpiryDate;
					if :info>=1 then
						if expirydate is null then
							dbms_output.put_line('--   Info: The password for user '||MyUser||' does not expire.');
						else
							dbms_output.put_line('--   Info: The password for user '||MyUser||' expires on '||to_char(ExpiryDate,'DD-MM-YYYY HH24:MI:SS'));
						end if;
					end if;

				 if expirydate is null then
					 dbms_output.put_line('--   Result: OK.');
				 else
					 dbms_output.put_line('--(!)Result: Warning: The password of user '||myUser||' will expire. To modify this execute the following statement(s):');
					 :WarningCount:=:WarningCount+1;
					 execute immediate 'SELECT limit FROM dba_profiles p, dba_users u WHERE u.profile=p.profile and u.username='''||myUser||''' and resource_name=''PASSWORD_LIFE_TIME''' into PasswordLifeTime;
					 execute immediate 'select profile from dba_users where username='''||myUser||'''' into UserProfile;

					 if PasswordLifeTime<>'UNLIMITED' then
						 dbms_output.put_line('--   Remark: The next statement will affect all users having profile '||UserProfile||':');
						 dbms_output.put_line('alter profile '||UserProfile||' limit password_life_time unlimited;');
					 end if;
					 execute immediate 'select account_status from dba_users where username='''||myUser||'''' into AccountStatus;
					 if substr(AccountStatus,1,7)='EXPIRED' then
						 --Additional password reset required because the password was already expired
						 dbms_output.put_line('alter user '||myUser||' identified by '||lower(myUser)||';');
					 end if;
					 dbms_output.put_line('--   Remark: Alternatively you could give the user another profile (different from '||UserProfile||') having password_life_time unlimited.');
				 end if;

					dbms_output.put_line(:Line);
				end if;
			end if;

			--USER's ACCOUNT OPEN/LOCKED status
			if UserExists=1 and myUser not in ('OMPUSER','OMDBA') then
				dbms_output.put_line('--   Requirement: User '||myUser||' account status should not be LOCKED.');
				--Account_status was already retrieved above
				if :DbaUsers=0 then
					--Account_status was already retrieved above; however mentioning that the info could not be retrieved is useful to repeat, so it is clear that this required cannot be checked
					dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_USERS''. Run the ConfigCheck script ''AS SYSDBA''.');
					:ErrorCount:=:ErrorCount+1;
				else
					if :info>=1 then
						dbms_output.put_line('--   Info: The account_status for user '||MyUser||' is '||AccountStatus||'.');
					end if;

					if AccountIsLocked=0 then
						dbms_output.put_line('--   Result: OK.');
					else
						dbms_output.put_line('--!  Result: Error: The user account '||myUser||' is locked. To modify this execute the following statement(s):');
						:ErrorCount:=:ErrorCount+1;
						dbms_output.put_line('alter user '||myUser||' account unlock;');
					end if;
				end if;
				dbms_output.put_line(:Line);
			end if;

			-------------------------------------------------------------------------------------
			-- TABLES WITH DEFERRED SEGMENT CREATION --------------------------------------------
			-------------------------------------------------------------------------------------
			if (:ProductComponentVersion=1 and :EnterPriseEdition=0 /*non-Enterprise Edition can be skipped*/) or :NLSRDBMSVERSION00<'11.02.00.01' /* deferred N/A */then
				null;
			else
				if UserExists=1 and myUser<>'OMPUSER' then
					dbms_output.put_line('--   Requirement: User '||myUser||' should not have tables without segments to ensure that export (with exp.exe) also exports empty tables.');
					if :DbaTables=1 or myUser=USER then --we can report on the tables
						execute immediate 'select count(*) from all_tables where owner='''||myUser||''' and /* only for tables without extent */ (segment_created = ''NO'' or segment_created is null)' into TablesWithoutSegmentsCount ;
						if TablesWithoutSegmentsCount>0 then
							dbms_output.put_line('--!  Result: Error: User '||myUser||' has '||TablesWithoutSegmentsCount||' '||case when TablesWithoutSegmentsCount=1 then 'table' else 'tables' end ||' without segments, possibly created when the database parameter deferred_segment_creation was set to true.');
							:ErrorCount:=:ErrorCount+1;
							dbms_output.put_line('--   Solution: Create segments for empty tables without segments by running the following statements:');
							execute immediate 'SELECT table_name from all_tables where owner='''||myUser||''' and (segment_created = ''NO'' or segment_created is null)' bulk collect into TablesWithoutSegments;
							FOR i IN TablesWithoutSegments.First .. TablesWithoutSegments.Last LOOP
								dbms_output.put_line('alter table ' ||myUser||'.'|| TablesWithoutSegments(i) ||' allocate extent;');
							END LOOP;
						else
								dbms_output.put_line('--   Result: OK.');
						end if;
					else
						dbms_output.put_line('--!  Result: Error: You do not have access to ''DBA_TABLES''. Run the ConfigCheck script ''AS SYSDBA''.');
						:errorcount:=:errorcount+1;
					end if;
					dbms_output.put_line(:Line);
				end if;
			end if;
			-------------------------------------------------------------------------------------
			-- LOCKED STATISTICS -----------------------------------------------------------
			-------------------------------------------------------------------------------------
			if UserExists=1 and myUser<>'OMPUSER' then
				dbms_output.put_line('--   Requirement: User '||myUser||' should not have tables with locked statistics.');
				execute immediate 'select table_name from all_tab_statistics where owner='''||myUser||''' and stattype_locked is not null' bulk collect into LockedStatisticsTables ;
				if LockedStatisticsTables.count>0 then
					dbms_output.put_line('--!  Result: Error: Some table(s) have locked statistics.');
					:ErrorCount:=:ErrorCount+1;
					dbms_output.put_line('--   Solution: unlock the statistics by issueing the following statement(s):');
					for s in 1..LockedStatisticsTables.count loop 
						dbms_output.put_line('exec dbms_stats.unlock_table_stats('''||myUser||''','''||LockedStatisticsTables(s)||''')');
					end loop;
				else
					dbms_output.put_line('--   Result: OK.');
				end if;
				dbms_output.put_line(:Line);
			end if;

		else --User is OMDBA but it seems not be required
			dbms_output.put_line('--(!)Warning: The recommended setup is to have a user OMDBA created also.');
			:WarningCount:=:WarningCount+1;
			dbms_output.put_line(:Line);
		end if;
	end loop;
end;
/

-------------------------------------------------------------------------------------
-- INVALID OBJECTS ------------------------------------------------------------------
-------------------------------------------------------------------------------------
declare
	type Object is          record (owner varchar2(30), object_name varchar2(128), object_type varchar2(19), status varchar2(7));
	type TableOfObject is   table of Object;
	InvalidObjects          TableOfObject:=TableOfObject();
	type Users is table of  varchar2(30);
	MyUsers                 Users:=Users();
   FullUserList            varchar2(10000);
	OwnerSize               number;
	Object_NameSize         number;
	Object_TypeSize         number;
	statusSize              number;
	i                       integer;
begin
	dbms_output.put_line('--   Requirement: Database should not have invalid objects.');
	
	--Add users which should also be checked here
	FullUserList:=:FullUserList;
	--FullUserList:='SYS,SYSTEM,'||:FullUserList;
	--Populate collection MyUsers using :FullUSERList created before
	for r in ( select substr ( str , instr(str,',',1,level) + 1 , instr(str,',',1,level+1) - instr(str,',',1,level) - 1 ) element from (select ',' || FullUSERList || ',' str from dual) connect by level <= length(str) - length(replace(str,',')) - 1 ) loop
		MyUsers.Extend;
		MyUsers(MyUsers.Count):=r.element;
	end loop;
	
	if :DbaObjects=0 then
		dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_OBJECTS''. Run the ConfigCheck script ''AS SYSDBA''.');
		:ErrorCount:=:ErrorCount+1;
		--try to find invalid in user scheme instead
		execute immediate 'select owner, object_name, object_type, status from all_objects where status=''INVALID'' order by owner, object_name, object_type' bulk collect into InvalidObjects;
	else
		execute immediate 'select owner, object_name, object_type, status from dba_objects where status=''INVALID'' order by owner, object_name, object_type' bulk collect into InvalidObjects;
	end if;

	--Filter out irrelevant users
	if InvalidObjects.count>0 then
		for i in reverse InvalidObjects.First .. InvalidObjects.Last loop
			if InvalidObjects.Exists(i) then
				if not InvalidObjects(i).Owner member of MyUsers then
					InvalidObjects.delete(i);
				end if;
			end if;
		end loop;
	end if;
	
	if InvalidObjects.Count=0 then
		dbms_output.put_line('--   Result: OK.');
	else
		dbms_output.put_line('--!  Error: The following '||case when InvalidObjects.count=1 then 'invalid object has' else InvalidObjects.count||' invalid objects have' end||' been found:');
		:errorcount:=:errorcount+1;
		--Determine size per column for nice output
		--Header text lengths:
		OwnerSize      :=length('Owner');
		Object_NameSize:=length('Object_Name');
		Object_TypeSize:=length('Object_Type');
		StatusSize     :=length('Status');
		--Data text lengths:
		i:=InvalidObjects.First;
		while i is not null
		loop 
			if length(InvalidObjects(i).Owner)>OwnerSize             then OwnerSize      :=length(InvalidObjects(i).Owner)       ;end if;
			if length(InvalidObjects(i).Object_Name)>Object_NameSize then Object_NameSize:=length(InvalidObjects(i).Object_Name) ;end if;
			if length(InvalidObjects(i).Object_Type)>Object_TypeSize then Object_TypeSize:=length(InvalidObjects(i).Object_Type) ;end if;
			if length(InvalidObjects(i).Status)>StatusSize           then StatusSize     :=length(InvalidObjects(i).Status)      ;end if;
			i:=InvalidObjects.Next(i);
		end loop;
		--Output
		--Header
		dbms_output.put_line('--      '||rpad('Owner',OwnerSize)||' '||rpad('Object_Name',Object_NameSize)||' '||rpad('Object_Type',Object_TypeSize)||' '||rpad('status',statusSize));
		dbms_output.put_line('--      '||rpad('-',OwnerSize,'-')||' '||rpad('-',Object_NameSize,'-')||' '||rpad('-',Object_TypeSize,'-')||' '||rpad('-',statusSize,'-'));
		--Content
		for i in InvalidObjects.First..InvalidObjects.Last loop
			if InvalidObjects.exists(i) then 
				dbms_output.put_line('--      '||rpad(InvalidObjects(i).Owner,OwnerSize) ||' '|| rpad(InvalidObjects(i).Object_Name,Object_NameSize) ||' '|| rpad(InvalidObjects(i).Object_Type,Object_TypeSize) ||' '|| rpad(InvalidObjects(i).status,statusSize));
			end if;
		end loop;
		dbms_output.put_line('--   Solution: Recompile all invalid objects with the following statement; if this does not fix the issue, investigate manually why the object is invalid.');
		dbms_output.put_line('exec utl_recomp.recomp_serial');
	end if;

	dbms_output.put_line(:Line);
	
end;
/




--SECTION FOR STATEMENTS REQUIRING USER LOGIN
--Maintenance job creation
declare
	type Users is table of          varchar2(40);
	TheUsers                        Users:=Users();
	TheUsersLocked                  Users:=Users();
	Username                        varchar2(40);
	JobUsesMPSchema                 varchar2(30);
	JobTZName                       varchar2(100);
	JobGap                          number;

begin
	--remove trailing comma
	:UserListRequiringMJobCreation:=substr(:UserListRequiringMJobCreation,1,length(:UserListRequiringMJobCreation)-1);
	--dbms_output.put_line('UserListRequiringMJobCreation='||:UserListRequiringMJobCreation);
	--Verify time zone for job creation
	JobTZName:='';
	execute immediate 'select extract(timezone_region from dbms_scheduler.stime) from dual' into JobTZName;
	if JobTZName='UNKNOWN' then JobTZName:='Europe/Brussels'; end if;

	--(Convert comma-separated UserList into Users-table rqUsers; from stackoverflow answer 3 (Oracle 9 compliant) from Rob, see http://stackoverflow.com/questions/1089508/how-to-best-split-csv-strings-in-oracle-9i)
	if  length(:UserListRequiringMJobCreation)>0 then
		for r in ( select substr ( str , instr(str,',',1,level) + 1 , instr(str,',',1,level+1) - instr(str,',',1,level) - 1 ) element from (select ',' || :UserListRequiringMJobCreation || ',' str from dual) connect by level <= length(str) - length(replace(str,',')) - 1 ) loop
			TheUsers.Extend;
			TheUsers(TheUsers.Count):=r.element;
		end loop;
		--dbms_output.put_line('TheUsers.count='||TheUsers.count);
		JobGap:=0;
		
		--Maybe a user was locked
		if  length(:UserListLocked)>0 then
	  		--remove trailing comma
	  		:UserListLocked:=substr(:UserListLocked,1,length(:UserListLocked)-1);
			for r in ( select substr ( str , instr(str,',',1,level) + 1 , instr(str,',',1,level+1) - instr(str,',',1,level) - 1 ) element from (select ',' || :UserListLocked || ',' str from dual) connect by level <= length(str) - length(replace(str,',')) - 1 ) loop
				TheUsersLocked.Extend;
				TheUsersLocked(TheUsersLocked.Count):=r.element;
			end loop;
		end if;
		
		for u in 1..TheUsers.count loop
			--select x,instr(x,'.'),substr(x,instr(x,'.')+1) Username, '|'||substr(x,1,length(x)-length(   substr(x,instr(x,'.')+1)   ))||'|' MPSchema from test;
			Username:=TheUsers(u);
			--Split username from possible 'omdba.' prefix
			Username:=substr(Username,instr(Username,'.')+1);
			JobUsesMPSchema:=substr(TheUsers(u),1,length(TheUsers(u))-length(UserName)); --will be null or '.omdba'
			--Now give the statements to connect to user and create the job
			dbms_output.put_line('--   Create maintenance job OMP_CLEANUP_JOB for user ' ||Username||'.');
			if Username member of TheUsersLocked then
				dbms_output.put_line('alter user '||UserName||' account unlock;');
			end if;
			dbms_output.put_line('connect '||Username||'/'||lower(Username)||'@&_connect_identifier');
 		   if JobTZName is not null then
 		      dbms_output.put_line('alter session set time_zone='''||JobTZName||''';');
 		   end if;
			dbms_output.put_line('BEGIN');
			dbms_output.put_line('dbms_scheduler.create_job(');
			dbms_output.put_line('job_name => ''OMP_CLEANUP_JOB'',');
			dbms_output.put_line('job_type => ''PLSQL_BLOCK'',');
			dbms_output.put_line('job_action => ');
			dbms_output.put_line('''begin');
			dbms_output.put_line('   '||JobUsesMPSchema||'om_cleanup.setadstatd();');
			dbms_output.put_line('   '||JobUsesMPSchema||'om_dba.deletealldeleted(TLMLIMIT_IN=> sysdate-3);');
			dbms_output.put_line('   '||JobUsesMPSchema||'/*om_dba.rebuildallindexes();*/');
			dbms_output.put_line('end;'',');
			dbms_output.put_line('repeat_interval => ''FREQ=DAILY;byhour='||to_char(2+trunc(JobGap/60))||';byminute='||to_char(mod(JobGap,60))||';bysecond=0'',');
			dbms_output.put_line('enabled => TRUE);');
			dbms_output.put_line('END;');
			dbms_output.put_line('/');
			if Username member of TheUsersLocked then
				dbms_output.put_line('alter user '||Username||' account lock;');
			end if;
			dbms_output.put_line('disconnect');
			dbms_output.put_line(:Line);
			JobGap:=JobGap+15;
		end loop;
	end if;

end;
/

-- Check whether there are any obsolete dbms_job remaining on the database, but only those created in the context of OMP.
-- If so, create the statements to remove them from the database (to enhance performance).
declare
	type jobrec	is record (Job number, priv_user varchar2(128));
	type jobtbl	is table of jobrec;
	jobobjs	jobtbl:= jobtbl();
begin
	if :V$JobTable=0 then
		dbms_output.put_line('--!  Result: Error: You do not have access to ''SYS.DBA_JOBS''. Run the ConfigCheck script ''AS SYSDBA''.');
		:ErrorCount:=:ErrorCount+1;
		dbms_output.put_line(:Line);
	else
		execute immediate 'SELECT job, priv_user FROM dba_jobs where what like ''%om_dba.%'' or what like ''%om_cleanup.%''' bulk collect into jobobjs;
		if jobobjs.count<>0 then
			dbms_output.put_line('--	There are obsolete jobs on the database!');
			dbms_output.put_line('--	Create removal statements for the obsolete jobs.');
			for dbs in 1..jobobjs.count loop
				dbms_output.put_line('connect '||jobobjs(dbs).priv_user||'/'||lower(jobobjs(dbs).priv_user)||'@&_connect_identifier');
				dbms_output.put_line('BEGIN');
				dbms_output.put_line('	dbms_job.remove('||jobobjs(dbs).job||')');
				dbms_output.put_line('	commit;');
				dbms_output.put_line('END;');
				dbms_output.put_line('/');
				dbms_output.put_line('disconnect');
				dbms_output.put_line(:Line);
			end loop;
		end if;
	end if;
end;
/

spool OM__FileCleanup.cmd
set termout off
begin
	if :ClientOSWINNT=1 then
		dbms_output.put_line('@echo off');
		dbms_output.put_line('if exist OM__AddPfileParameters.txt  del OM__AddPfileParameters.txt');
		dbms_output.put_line('if exist OM__AdjustPfile.cmd         del OM__AdjustPfile.cmd');
		dbms_output.put_line('if exist OM__AdjustPfile.sql         del OM__AdjustPfile.sql');
		dbms_output.put_line('if exist OM__AdjustPfile2.cmd        del OM__AdjustPfile2.cmd');
		dbms_output.put_line('if exist OM__AdjustPfile2.sql        del OM__AdjustPfile2.sql');
		dbms_output.put_line('if exist OM__FreediskspaceError.txt  del OM__FreediskspaceError.txt');
		dbms_output.put_line('if exist OM__defWorkingDirectory.cmd                 del OM__defWorkingDirectory.cmd');
		dbms_output.put_line('if exist OM__defWorkingDirectory.sql                 del OM__defWorkingDirectory.sql');
		dbms_output.put_line('if exist OM_NewPfile.ora             del OM_NewPfile.ora');
		dbms_output.put_line('if exist OM_Workfile                 del OM_Workfile');
		--OM_Error normally onif exist ontains errors related to OS switching in this script
		dbms_output.put_line('if exist OM__Error                   del OM__Error');
	else
		dbms_output.put_line('[ -f OM__AddPfileParameters.txt ] &'||'&'||' rm OM__AddPfileParameters.txt');
		dbms_output.put_line('[ -f OM__AdjustPfile.cmd        ] &'||'&'||' rm OM__AdjustPfile.cmd');
		dbms_output.put_line('[ -f OM__AdjustPfile.sql        ] &'||'&'||' rm OM__AdjustPfile.sql');
		dbms_output.put_line('[ -f OM__AdjustPfile2.cmd       ] &'||'&'||' rm OM__AdjustPfile2.cmd');
		dbms_output.put_line('[ -f OM__AdjustPfile2.sql       ] &'||'&'||' rm OM__AdjustPfile2.sql');
		dbms_output.put_line('[ -f OM__FreediskspaceError.txt ] &'||'&'||' rm OM__FreediskspaceError.txt');
		dbms_output.put_line('[ -f OM__defWorkingDirectory.cmd                ] &'||'&'||' rm OM__defWorkingDirectory.cmd');
		dbms_output.put_line('[ -f OM__defWorkingDirectory.sql                ] &'||'&'||' rm OM__defWorkingDirectory.sql');
		dbms_output.put_line('[ -f OM_NewPfile.ora            ] &'||'&'||' rm OM_NewPfile.ora');
		dbms_output.put_line('[ -f OM_Workfile                ] &'||'&'||' rm OM_Workfile');
		--OM_Error normally only contains errors related to OS switching in this script
		dbms_output.put_line('[ -f OM__Error              ] &'||'&'||' rm OM__Error');
		--Linux script can be self-destructing:
		dbms_output.put_line('rm $0');
	end if;
end;
/
spool off
set lines 200
--start .cmd
host OM__FileCleanup.cmd 2>nul
--Windows scripts cannot be self-destructing:
host del OM__FileCleanup.cmd 2>nul
host chmod u+x OM__FileCleanup.cmd 2>nul
host ./OM__FileCleanup.cmd  2>nul
host rm nul 2>nul
set termout on
--continue original spoolfile
spool FixMissing_&datab._&timestamp..sql append

declare
begin
	dbms_output.put_line('--   FINISHED');
	dbms_output.put_line('--   Result: !Errors='||:ErrorCount||', (!)Warnings='||:WarningCount);
end;
/


undef Unicode
undef TablespaceSize_OMPARTNERS
undef TablespaceSize_INDEXES
undef TablespaceSize_TEMP
undef TablespaceSize_SYSTEM
undef TablespaceSize_SYSAUX
undef TablespaceSize_OMDBA
undef shared_pool_size
undef db_cache_size
undef pga_aggregate_target
undef UserList
undef OMPApplicationVersion
undef PackageLocation
undef dml_locks
undef processes
undef info
undef SkipSharedPackages
undef SkipOMDBA
undef SkipOMDIN
undef SkipPublicSynonyms
undef SkipVViews
undef SkipDBLink
undef WorkingDirectory
undef OMPDP_directory_path
undef SKIPSHAREDSLEEP
undef SKIPOMDBADINDBTESTS
undef SKIPADDINGPLANNINGLAYERSUFFIX
undef SKIPOMPDPDIRECTORY
undef SKIPBOUNCEMODE

exec dbms_output.put_line(:Line);
spool off
exec dbms_output.put_line('The output of this script is available in file '||:WorkingDirectory||:ClientPathSeparator||'FixMissing_'||'&datab'||'_'||'&timestamp'||'.sql')

set verify on
set feedback 1
set timing on
set heading on
set echo on



