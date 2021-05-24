SET DEFINE OFF
update apps.XX_AR_AP_COEF_CM05 set end_date_active = TRUNC(SYSDATE-1) where party_id = 11063714;
--1 Row Update
/
INSERT INTO XX_AR_AP_COEF_CM05 values (118,11063714,'09',0.0170,trunc(sysdate),null,-1,sysdate,0,sysdate,0,null);
--1 Row Insert
/
EXIT