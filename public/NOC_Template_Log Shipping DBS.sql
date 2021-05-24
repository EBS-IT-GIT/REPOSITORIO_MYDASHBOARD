IF (SELECT DATEPART(HH,GETDATE())) NOT BETWEEN 2 AND 5
BEGIN
	SELECT
		 MAX(restore_date)							AS ULTIMO_RESTORE
		,DATEDIFF(HH, MAX(restore_date), GETDATE()) AS HORAS_ULT_RESTORE
		,destination_database_name					AS NOME_BANCO
	FROM [msdb].[dbo].[restorehistory]
	WHERE destination_database_name = 'Qualitor_Reports'
		AND restore_type = 'L'  --LOG
	GROUP BY destination_database_name
	HAVING DATEDIFF(mi, MAX(restore_date), GETDATE()) > 60
END