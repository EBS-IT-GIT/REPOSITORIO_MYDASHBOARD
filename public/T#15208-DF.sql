UPDATE APPS.XX_TCG_CARTAS_PORTE_CTG SET LOT_NO = '1819' WHERE  NUMERO_CARTA_PORTE = '0005-81490174';
COMMIT;
delete from  apps.XX_ACO_LOTE_LINES
where 
(item_id = 20999662 and lote = 'CCO2-207-C') OR
(item_id = 2408959 and lote = 'CCO2-211E') OR
(item_id = 20999662 and lote = 'CCO2-219 B') OR
(item_id = 18013662 and lote = 'CCO2-219A') OR
(item_id = 13253589 and lote = 'CCO2-220') OR
(item_id = 20917662 and lote = 'CCO2-503-A') OR
(item_id = 1002 and lote = 'CCO2-503-B') OR
(item_id = 13253589 and lote = 'CCO2-505-A') OR
(item_id = 996 and lote = 'CCO2-505-B') OR
(item_id = 18013662 and lote = 'CCO2-604A') OR
(item_id = 13253589 and lote = 'CCO1-7C') OR
(item_id = 13253589 and lote = 'CCO1-7D') OR
(item_id = 20917662 and lote = 'CCO1-11B1') OR
(item_id = 18013662 and lote = 'CCO1-11B2');
commit;
