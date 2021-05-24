update apps.XX_TCG_TICKETS_BALANZA set 
BALANZA_TARA_ID =23,
last_updated_by = 2070,
last_update_date = sysdate, 
TARA =  16240,
TARA_fECHA =to_date('26/07/2020','dd/mm/yyyy'),
TARA_USER_ID =  40237
 where carta_porte_id = 446453 and  TICKET_NUMERO = 20740 AND ITEM_ID = 13253589;