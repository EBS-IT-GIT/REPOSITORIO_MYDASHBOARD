-- UPDATE_RA_BATCH_SOURCES_ALL_NFSE --

UPDATE RA_BATCH_SOURCES_ALL rbs SET RBS.GLOBAL_ATTRIBUTE5 = 'Y', RBS.GLOBAL_ATTRIBUTE6 = '99'
where upper(rbs.name) like 'NFSE%'
and nvl(rbs.end_date, sysdate) >= sysdate
and rbs.status = 'A';
