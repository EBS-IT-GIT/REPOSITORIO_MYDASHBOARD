SELECT
	 j.name													AS NOME_JOB
	,max(msdb.dbo.agent_datetime(jh.run_date, jh.run_time)) AS ULTIMA_EXECUCAO
	,jh.run_status											AS STATUS_EXECUCAO
	,' #'													AS SEPARADOR
FROM msdb.dbo.sysjobhistory jh
INNER JOIN msdb.dbo.sysjobs j
	ON jh.job_id = j.job_id
	AND j.enabled = 1
	AND j.name like 'EBSIT - Maintenance%'
WHERE jh.run_status <> 1
GROUP BY j.name, jh.run_status