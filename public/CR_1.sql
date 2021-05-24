UPDATE apps.XX_TCG_CARTAS_PORTE_ALL
   SET PAGADOR_FLETE_ID = PROVISIONADO_POR, LAST_UPDATE_DATE = SYSDATE
 WHERE NUMERO_CARTA_PORTE IN
          ('0005-82040936',                                             -- MME
           '0005-82040831',                                              --MME
           '0005-82040207',                                             -- MFR
           '0005-82040195',                                             -- MFR
           '0005-82040594',                                              --MSS
           '0005-82040803')                                              --MSS
--6