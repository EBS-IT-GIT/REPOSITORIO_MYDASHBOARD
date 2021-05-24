-- UPDATE_RA_BATCH_SOURCES_ALL_NFE --

UPDATE RA_BATCH_SOURCES_ALL rbs SET RBS.GLOBAL_ATTRIBUTE5 = 'Y', RBS.GLOBAL_ATTRIBUTE6 = '55'
where upper(rbs.name) like 'NFE%'
   And Nvl(Rbs.End_Date, Sysdate) >= Sysdate
   and RBS.GLOBAL_ATTRIBUTE5 = 'Y'
   And Rbs.Status = 'A';
