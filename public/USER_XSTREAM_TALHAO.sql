	CREATE USER xstrm_talhao IDENTIFIED BY "Wa#e$Oglujgfq+TxI7+rl9#"  DEFAULT TABLESPACE XSTREAM_TBS QUOTA UNLIMITED ON XSTREAM_TBS;
	GRANT CREATE SESSION TO xstrm_talhao;
	GRANT FLASHBACK ANY TABLE TO xstrm_talhao;
	GRANT SELECT ON SYS.V_$DATABASE to xstrm_talhao;
	GRANT select_catalog_role TO xstrm_talhao;


	grant select on "SAPSR3"."T001K" to xstrm_talhao;
	grant select on "SAPSR3"."T001W" to xstrm_talhao;
	grant select on "SAPSR3"."LFB1" to xstrm_talhao;
	grant select on "SAPSR3"."ADRC" to xstrm_talhao;
	grant select on "SAPSR3"."LFA1" to xstrm_talhao;
	grant select on "SAPSR3"."VIBDRO" to xstrm_talhao;
	grant select on "SAPSR3"."ZRE_RO_CICLO" to xstrm_talhao;
	grant select on "SAPSR3"."ZRE_RO_ROTACAO" to xstrm_talhao;
	grant select on "SAPSR3"."ZRE_RO_REC_TEC" to xstrm_talhao;
	grant select on "SAPSR3"."ZRE_RO_MAT_GEN" to xstrm_talhao;
	grant select on "SAPSR3"."ZRET_RO_REC_TAL" to xstrm_talhao;
	grant select on "SAPSR3"."VIBDMEAS" to xstrm_talhao;
	grant select on "SAPSR3"."TJ30T" to xstrm_talhao;
	grant select on "SAPSR3"."EQKT" to xstrm_talhao;
	grant select on "SAPSR3"."EQUZ" to xstrm_talhao;


	alter table "SAPSR3"."T001K" ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
	alter table "SAPSR3"."T001W"ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
	alter table "SAPSR3"."LFB1" ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
	alter table "SAPSR3"."ADRC" ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
	alter table "SAPSR3"."LFA1" ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
	alter table "SAPSR3"."VIBDRO" ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
	alter table "SAPSR3"."ZRE_RO_CICLO" ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
	alter table "SAPSR3"."ZRE_RO_ROTACAO" ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
	alter table "SAPSR3"."ZRE_RO_REC_TEC" ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
	alter table "SAPSR3"."ZRE_RO_MAT_GEN" ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
	alter table "SAPSR3"."ZRET_RO_REC_TAL" ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
	alter table "SAPSR3"."VIBDMEAS" ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
	alter table "SAPSR3"."TJ30T" ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
	alter table "SAPSR3"."EQKT" ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
	alter table "SAPSR3"."EQUZ" ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;