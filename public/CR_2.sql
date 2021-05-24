UPDATE apps.XX_TCG_LIQUIDACIONES_1116A
SET ESTADO_COE = 'ASIGNADO',
    LAST_UPDATE_DATE = sysdate
WHERE NUMERO_LIQUIDACION LIKE '3320-089%'
AND FECHA_LIQUIDACION = TO_DATE('15-01-2020', 'DD-MM-YYYY')
AND CONTRATO_ID IN ( 7986, 7990)
--9