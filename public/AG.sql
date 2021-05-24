SET NOEXEC OFF;
GO
:on error exit
GO
/*
Detecta o modo SQLCMD e desabilita a execução do script se o modo SQLCMD não tiver suporte.
Para reabilitar o script após habilitar o modo SQLCMD, execute o comando a seguir:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'O modo SQLCMD deve ser habilitado para executar esse script com êxito.';
        SET NOEXEC ON;
    END
GO

:setvar DatabaseName "TESTE"
:setvar CommitMode "SYNCHRONOUS_COMMIT"

:setvar Principal  "SPSRVPRD0312"
:setvar Secundario "SPSRVPRD0316"



--- YOU MUST EXECUTE THE FOLLOWING SCRIPT IN SQLCMD MODE.
:Connect $(Principal)

IF (SELECT state FROM sys.endpoints WHERE name = N'endpoint_mirroring') <> 0
BEGIN
	grant connect on endpoint::[endpoint_mirroring] to [KLABIN\$(Secundario)$]
	ALTER ENDPOINT [endpoint_mirroring] STATE = STARTED
END


GO

:Connect $(Principal)

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER WITH (STARTUP_STATE=ON);
END
IF NOT EXISTS(SELECT * FROM sys.dm_xe_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER STATE=START;
END

GO

:Connect $(Secundario)

IF (SELECT state FROM sys.endpoints WHERE name = N'endpoint_mirroring') <> 0
BEGIN
    grant connect on endpoint::[endpoint_mirroring] to [KLABIN\$(Principal)$]
	ALTER ENDPOINT [endpoint_mirroring] STATE = STARTED
END


GO

:Connect $(Secundario)

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER WITH (STARTUP_STATE=ON);
END
IF NOT EXISTS(SELECT * FROM sys.dm_xe_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER STATE=START;
END

GO

:Connect $(Principal)

ALTER DATABASE [$(DatabaseName)] SET RECOVERY FULL
ALTER AUTHORIZATION ON DATABASE::[$(DatabaseName)] TO sa

BACKUP DATABASE [$(DatabaseName)] TO  DISK = N'\\$(Principal)\ClusterShare$\$(DatabaseName).bak' WITH FORMAT, INIT, COMPRESSION,  STATS = 5

GO

:Connect $(Secundario)

RESTORE DATABASE [$(DatabaseName)] FROM  DISK = N'\\$(Principal)\ClusterShare$\$(DatabaseName).bak' WITH  NORECOVERY,  NOUNLOAD,  STATS = 5

GO

:Connect $(Principal)

BACKUP LOG [$(DatabaseName)] TO  DISK = N'\\$(Principal)\ClusterShare$\$(DatabaseName)_.trn' WITH FORMAT, INIT, COMPRESSION,  STATS = 5

GO

:Connect $(Secundario)

RESTORE LOG [$(DatabaseName)] FROM  DISK = N'\\$(Principal)\ClusterShare$\$(DatabaseName)_.trn' WITH  NORECOVERY,  NOUNLOAD,  STATS = 5

GO

:Connect $(Principal)

USE [master]

GO

CREATE AVAILABILITY GROUP [$(DatabaseName)_AG]
WITH (AUTOMATED_BACKUP_PREFERENCE = PRIMARY,
BASIC,
DB_FAILOVER = ON,
DTC_SUPPORT = NONE)
FOR DATABASE [$(DatabaseName)]
REPLICA ON 
    N'$(Principal)' WITH (ENDPOINT_URL = N'TCP://$(Principal).klabin.net:5022', FAILOVER_MODE = MANUAL, AVAILABILITY_MODE = $(CommitMode), SECONDARY_ROLE(ALLOW_CONNECTIONS = NO)),
	N'$(Secundario)' WITH (ENDPOINT_URL = N'TCP://$(Secundario).klabin.net:5022', FAILOVER_MODE = MANUAL, AVAILABILITY_MODE = $(CommitMode), SECONDARY_ROLE(ALLOW_CONNECTIONS = NO));

GO

:Connect $(Secundario)

ALTER AVAILABILITY GROUP [$(DatabaseName)_AG] JOIN;

GO


:Connect $(Secundario)


-- Wait for the replica to start communicating
begin try
declare @conn bit
declare @count int
declare @replica_id uniqueidentifier 
declare @group_id uniqueidentifier
set @conn = 0
set @count = 30 -- wait for 5 minutes 

if (serverproperty('IsHadrEnabled') = 1)
	and (isnull((select member_state from master.sys.dm_hadr_cluster_members where upper(member_name COLLATE Latin1_General_CI_AS) = upper(cast(serverproperty('ComputerNamePhysicalNetBIOS') as nvarchar(256)) COLLATE Latin1_General_CI_AS)), 0) <> 0)
	and (isnull((select state from master.sys.database_mirroring_endpoints), 1) = 0)
begin
    select @group_id = ags.group_id from master.sys.availability_groups as ags where name = N'$(DatabaseName)_AG'
	select @replica_id = replicas.replica_id from master.sys.availability_replicas as replicas where upper(replicas.replica_server_name COLLATE Latin1_General_CI_AS) = upper(@@SERVERNAME COLLATE Latin1_General_CI_AS) and group_id = @group_id
	while @conn <> 1 and @count > 0
	begin
		set @conn = isnull((select connected_state from master.sys.dm_hadr_availability_replica_states as states where states.replica_id = @replica_id), 1)
		if @conn = 1
		begin
			-- exit loop when the replica is connected, or if the query cannot find the replica status
			break
		end
		waitfor delay '00:00:10'
		set @count = @count - 1
	end
end
end try
begin catch
	-- If the wait loop fails, do not stop execution of the alter database statement
end catch
ALTER DATABASE [$(DatabaseName)] SET HADR AVAILABILITY GROUP = [$(DatabaseName)_AG];

GO